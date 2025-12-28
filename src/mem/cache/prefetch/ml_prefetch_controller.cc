#include "mem/cache/prefetch/ml_prefetch_controller.hh"

#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <cctype>

#include "cpu/base.hh"
#include "debug/MLPrefetcher.hh"
#include "mem/cache/base.hh"
#include "sim/cur_tick.hh"
#include "sim/sim_object.hh"

namespace
{

// Log every N epochs when debugLogging is enabled.
static const unsigned long long EPOCH_PRINT_INTERVAL = 20;

// Global CSV file for all instances.
static std::ofstream gCsvFile;
static bool gCsvInitialized = false;

// Smoothing factor for miss rate (exponential moving average).
static constexpr double MISS_SMOOTH_ALPHA = 0.3;

// Exploration decay parameters.
static constexpr double EXPLORE_MIN    = 0.01;
static constexpr double EXPLORE_DECAY  = 0.9995;

// Max span for normalized accuracy based on miss-rate improvement.
static constexpr double ACC_MAX_SPAN = 0.2; // 20 percentage points of miss-rate

} // anonymous namespace

namespace gem5
{
namespace prefetch
{

MLPrefetchController::MLPrefetchController(const Params &p)
    : Queued(p),
      cachePtr(nullptr),
      cacheName(p.cache_name),
      children(p.children.begin(), p.children.end()),
      currentAction(p.current_action),
      numActions(p.children.size() + 1),       // +1 for OFF bandit index
      epoch_ticks(p.ticks_per_epoch),
      update_event([this]{ updateModel(); }, name() + ".update_event"),
      learningRate(p.learning_rate),
      exploreRate(p.explore_rate),
      debugLogging(p.debug_logging),
      cpuPtr(p.cpu),
      lastTotalOps(0),
      lastIpc(0.0),
      lastIpcTick(curTick())
{
    if (currentAction < -1 ||
        currentAction >= (int)children.size()) {
        warn("MLPrefetchController '%s': initial action %d invalid, "
             "resetting to 0\n", name(), currentAction);
        currentAction = 0;
    }

    if (cpuPtr)
        lastTotalOps = cpuPtr->totalOps();
    else
        warn("MLPrefetchController '%s': CPU pointer null; IPC reward disabled\n",
             name());

    // Initialize per-action penalties (simple heuristic):
    // - Children 0,1,2,... may be increasingly aggressive.
    // - Last bandit index = OFF → no penalty.
    actionPenalties.assign(numActions, 0.0);
    if (numActions >= 2)
        actionPenalties[1] = 0.02; // mildly penalize 2nd action
    if (numActions >= 3)
        actionPenalties[2] = 0.03; // a bit more for 3rd, etc.

    // CSV init (once)
    if (debugLogging && !gCsvInitialized) {
        gCsvInitialized = true;
        gCsvFile.open("mlprefetch_stats.csv",
                      std::ios::out | std::ios::trunc);
        if (gCsvFile.is_open()) {
            gCsvFile << "epoch,tick,state,miss_rate,delta_miss,"
                        "ipc,delta_ipc,accuracy,action\n";
        } else {
            warn("MLPrefetchController '%s': could not open "
                 "mlprefetch_stats.csv\n", name());
        }
    }

    // Auto-generate Q-table file name:
    //    qtable_<cacheName>.bin (sanitized)
    std::string safeName = cacheName.empty() ? name() : cacheName;
    for (auto &ch : safeName) {
        if (!std::isalnum(static_cast<unsigned char>(ch)))
            ch = '_';
    }
    qfileName = "qtable_" + safeName + ".bin";
}

void
MLPrefetchController::startup()
{
    // Load previously saved Q-table if available & compatible
    loadQTable();

    // Resolve BaseCache pointer from cacheName string param.
    if (!cacheName.empty()) {
        SimObject *obj = SimObject::find(cacheName.c_str());
        cachePtr = dynamic_cast<BaseCache*>(obj);

        if (!cachePtr) {
            warn("MLPrefetchController '%s': cache '%s' not found or not "
                 "BaseCache; miss-based state disabled.\n",
                 name(), cacheName.c_str());
        } else {
            lastAccesses = cachePtr->getRuntimeAccesses();
            lastMisses   = cachePtr->getRuntimeMisses();
        }
    } else {
        warn("MLPrefetchController '%s': cache_name not set; "
             "miss-based state disabled.\n", name());
    }

    schedule(update_event, curTick() + epoch_ticks);
}

void
MLPrefetchController::regStats()
{
    // IMPORTANT: register all base/parent stats FIRST
    Queued::regStats();

    // RL action usage (bandit index 0..3; 3 usually OFF)
    actionUse0
        .name(csprintf("%s.actionUse_0", name()))
        .desc("Number of epochs where RL selected bandit index 0");
    actionUse1
        .name(csprintf("%s.actionUse_1", name()))
        .desc("Number of epochs where RL selected bandit index 1");
    actionUse2
        .name(csprintf("%s.actionUse_2", name()))
        .desc("Number of epochs where RL selected bandit index 2");
    actionUse3
        .name(csprintf("%s.actionUse_3", name()))
        .desc("Number of epochs where RL selected bandit index 3 (OFF)");

    // Per-child issued
    child0PfIssued
        .name(csprintf("%s.children0.pfIssued", name()))
        .desc("Prefetches issued (attributed) to child 0");
    child1PfIssued
        .name(csprintf("%s.children1.pfIssued", name()))
        .desc("Prefetches issued (attributed) to child 1");
    child2PfIssued
        .name(csprintf("%s.children2.pfIssued", name()))
        .desc("Prefetches issued (attributed) to child 2");
    child3PfIssued
        .name(csprintf("%s.children3.pfIssued", name()))
        .desc("Prefetches issued (attributed) to child 3");

    // Per-child useful
    child0PfUseful
        .name(csprintf("%s.children0.pfUseful", name()))
        .desc("Useful prefetches (demand hit prefetched line) for child 0");
    child1PfUseful
        .name(csprintf("%s.children1.pfUseful", name()))
        .desc("Useful prefetches (demand hit prefetched line) for child 1");
    child2PfUseful
        .name(csprintf("%s.children2.pfUseful", name()))
        .desc("Useful prefetches (demand hit prefetched line) for child 2");
    child3PfUseful
        .name(csprintf("%s.children3.pfUseful", name()))
        .desc("Useful prefetches (demand hit prefetched line) for child 3");

    // Per-child redundant
    child0PfRedundant
        .name(csprintf("%s.children0.pfRedundant", name()))
        .desc("Redundant prefetch candidates (already tracked) for child 0");
    child1PfRedundant
        .name(csprintf("%s.children1.pfRedundant", name()))
        .desc("Redundant prefetch candidates (already tracked) for child 1");
    child2PfRedundant
        .name(csprintf("%s.children2.pfRedundant", name()))
        .desc("Redundant prefetch candidates (already tracked) for child 2");
    child3PfRedundant
        .name(csprintf("%s.children3.pfRedundant", name()))
        .desc("Redundant prefetch candidates (already tracked) for child 3");
}

void
MLPrefetchController::notify(const CacheAccessProbeArg &acc,
                             const PrefetchInfo &pfi)
{
    epochAccesses++;
    if (pfi.isCacheMiss())
        epochMisses++;

    if (!pfi.isCacheMiss()) {
        Addr a = pfi.getAddr();
        trackUsefulForAddr(a);
    }

    // IMPORTANT: do NOT forward notify() to children here.
    // They will be "trained" via calculatePrefetch() calls instead.

    Queued::notify(acc, pfi);
}

void
MLPrefetchController::calculatePrefetch(
    const PrefetchInfo &pfi,
    std::vector<AddrPriority> &addresses,
    const CacheAccessor &cache)
{
    // If we're OFF, we still want children to *train*, but we don't issue.
    const int active = currentAction;

    for (int i = 0; i < (int)children.size(); ++i) {
        auto *child = dynamic_cast<Queued*>(children[i]);
        if (!child)
            continue;

        std::vector<AddrPriority> tmp;
        child->calculatePrefetch(pfi, tmp, cache);

        // DEBUG: see if children are actually generating candidates
        DPRINTF(MLPrefetcher, "CHILD %d GENERATED %zu candidates\n",
                i, tmp.size());

        // Only the RL-selected child actually issues prefetches
        if (i == active) {
            for (const auto &ap : tmp) {
                addresses.push_back(ap);
                trackIssuedForChild(i, ap.first);
            }
        }
        // For i != active: tmp is purely for training (Stride/Tagged update
        // internal tables), then we discard the candidates.
    }
}

// ---- Discretization helpers ------------------------------------------------

int
MLPrefetchController::encodeDeltaMiss(double d) const
{
    // Rough thresholds: large / small changes in smoothed miss rate.
    if (d < -0.10) return 0;  // large decrease
    if (d < -0.02) return 1;  // small decrease
    if (d <  0.02) return 2;  // stable
    if (d <  0.10) return 3;  // small increase
    return 4;                 // large increase
}

int
MLPrefetchController::encodeDeltaIpc(double d) const
{
    // IPC deltas are small, so use tight thresholds.
    if (d < -1e-4) return 0;   // IPC down
    if (d <  1e-4) return 1;   // stable
    return 2;                  // IPC up
}

int
MLPrefetchController::encodeAccuracy(double a) const
{
    // a is assumed in [0,1]
    if (a <= 0.20) return 0;   // very low accuracy / pollution
    if (a <= 0.60) return 1;   // medium
    return 2;                  // high
}

// ---- RL core ----------------------------------------------------------------

int
MLPrefetchController::selectAction(uint64_t state)
{
    auto &row = qTable[state];
    if (row.size() < (size_t)numActions)
        row.resize(numActions, 0.0);

    // ε-greedy
    double r = (double)random() / (double)RAND_MAX;
    if (r < exploreRate) {
        int i = random() % numActions;
        return i;  // bandit index (0..numActions-1)
    }

    int bestIdx = 0;
    double bestVal = row[0];
    for (int i = 1; i < numActions; ++i) {
        if (row[i] > bestVal) {
            bestVal = row[i];
            bestIdx = i;
        }
    }
    return bestIdx;
}

void
MLPrefetchController::endEpoch()
{
    // ------------------------
    // 1. Compute REAL miss rate from BaseCache stats (per-epoch delta).
    // ------------------------
    double missRate = 0.0;

    if (cachePtr) {
        uint64_t totalAccesses = cachePtr->getRuntimeAccesses();
        uint64_t totalMissesC  = cachePtr->getRuntimeMisses();

        uint64_t dAcc = totalAccesses - lastAccesses;
        uint64_t dMis = totalMissesC  - lastMisses;

        lastAccesses = totalAccesses;
        lastMisses   = totalMissesC;

        missRate = (dAcc > 0) ? (double)dMis / (double)dAcc : 0.0;
    }

    // ------------------------
    // 2. IPC and ΔIPC (for reward shaping)
    // ------------------------
    double newIpc = lastIpc;
    double ipcDelta = 0.0;

    if (cpuPtr) {
        uint64_t nowOps = cpuPtr->totalOps();
        Tick now = curTick();
        Tick dt  = now - lastIpcTick;

        if (dt > 0) {
            newIpc = (double)(nowOps - lastTotalOps) / (double)dt;
            ipcDelta = newIpc - lastIpc;
        }

        lastTotalOps = nowOps;
        lastIpcTick  = now;
    }

    // ------------------------
    // 3. Smoothed miss-rate and Δmiss (for state & accuracy)
    // ------------------------
    double deltaSmoothedMiss = 0.0;
    if (!haveSmoothedMiss) {
        smoothedMissRate = missRate;
        lastSmoothedMiss = missRate;
        haveSmoothedMiss = true;
        deltaSmoothedMiss = 0.0;
    } else {
        lastSmoothedMiss = smoothedMissRate;
        smoothedMissRate = MISS_SMOOTH_ALPHA * missRate
                         + (1.0 - MISS_SMOOTH_ALPHA) * smoothedMissRate;
        deltaSmoothedMiss = smoothedMissRate - lastSmoothedMiss;
    }

    // Accuracy: normalized improvement in smoothed miss rate.
    //
    // raw_improve = lastSmoothedMiss - smoothedMissRate
    // clamp to [-ACC_MAX_SPAN, +ACC_MAX_SPAN] then map to [0,1]
    double raw_improve = lastSmoothedMiss - smoothedMissRate;
    if (raw_improve >  ACC_MAX_SPAN) raw_improve =  ACC_MAX_SPAN;
    if (raw_improve < -ACC_MAX_SPAN) raw_improve = -ACC_MAX_SPAN;

    double accuracy = (raw_improve + ACC_MAX_SPAN) / (2.0 * ACC_MAX_SPAN);

    // Update history for next epoch (raw miss & IPC).
    lastMissRate = missRate;
    lastIpc      = newIpc;

    // ------------------------
    // 4. Build discrete state from Δmiss, ΔIPC, accuracy.
    // ------------------------
    int missBin = encodeDeltaMiss(deltaSmoothedMiss);
    int ipcBin  = encodeDeltaIpc(ipcDelta);
    int accBin  = encodeAccuracy(accuracy);

    uint64_t state = (uint64_t)(accBin * 100 + missBin * 10 + ipcBin);

    // ------------------------
    // 5. Reward shaping: IPC sign + accuracy - action penalty.
    // ------------------------
    double ipcSign = 0.0;
    if (ipcDelta >  1e-6) ipcSign =  1.0;
    if (ipcDelta < -1e-6) ipcSign = -1.0;

    double accCentered = 2.0 * accuracy - 1.0; // [0,1] -> [-1,1]

    double reward = 0.5 * ipcSign + 0.5 * accCentered;

    if (lastAction >= 0 && lastAction < (int)actionPenalties.size()) {
        reward -= actionPenalties[lastAction];
    }

    lastReward = reward;

    // ------------------------
    // 6. RL bandit update (single-step reward)
    // ------------------------
    auto &row = qTable[lastState];
    if (row.size() < (size_t)numActions)
        row.resize(numActions, 0.0);

    if (lastAction >= 0 && lastAction < numActions) {
        double oldVal = row[lastAction];
        row[lastAction] = oldVal + learningRate * (reward - oldVal);
    }

    // ------------------------
    // 7. Select next action (ε-greedy with decaying ε).
    // ------------------------
    int nextBanditIdx = selectAction(state);

    // Map bandit index to semantic action:
    // 0..children.size()-1 → that child
    // last index (numActions-1) → OFF (-1)
    int nextAction;
    if (nextBanditIdx == numActions - 1)
        nextAction = -1;
    else
        nextAction = nextBanditIdx;

    // Track action usage stats (bandit indices)
    switch (nextBanditIdx) {
      case 0: actionUse0++; break;
      case 1: actionUse1++; break;
      case 2: actionUse2++; break;
      case 3: actionUse3++; break;
      default: break;
    }

    // Decay exploration rate.
    exploreRate = std::max(EXPLORE_MIN, exploreRate * EXPLORE_DECAY);

    // ------------------------
    // 8. CSV logging (simplified) if debugLogging enabled
    // ------------------------
    static unsigned long long epoch = 0;
    ++epoch;

    if (debugLogging && gCsvFile.is_open() &&
        (epoch % EPOCH_PRINT_INTERVAL == 0)) {
        gCsvFile << epoch             << ","
                 << curTick()         << ","
                 << state             << ","
                 << missRate          << ","
                 << deltaSmoothedMiss << ","
                 << newIpc            << ","
                 << ipcDelta          << ","
                 << accuracy          << ","
                 << nextAction        << "\n";
    }

    // ------------------------
    // 9. Switch action and update RL history
    // ------------------------
    switchTo(nextAction);

    lastState  = state;
    lastAction = nextBanditIdx;

    // Debug counters reset
    epochAccesses = 0;
    epochMisses   = 0;
}

void
MLPrefetchController::updateModel()
{
    endEpoch();

    // Persist Q-table every epoch (you can make this periodic if desired)
    saveQTable();

    schedule(update_event, curTick() + epoch_ticks);
}

void
MLPrefetchController::switchTo(int index)
{
    // index is semantic: -1 = OFF, >=0 = child index.
    currentAction = index;
}

// ---- Per-child tracking helpers -------------------------------------------

void
MLPrefetchController::trackIssuedForChild(int childIndex, Addr addr)
{
    if (childIndex < 0)
        return;

    // Limit table size to avoid unbounded growth.
    if (childPfTable.size() >= MaxTrackedPrefetches)
        childPfTable.clear();

    auto it = childPfTable.find(addr);
    if (it != childPfTable.end()) {
        // Redundant prefetch candidate: already tracked.
        switch (childIndex) {
          case 0: child0PfRedundant++; break;
          case 1: child1PfRedundant++; break;
          case 2: child2PfRedundant++; break;
          case 3: child3PfRedundant++; break;
          default: break;
        }
        // Overwrite with newest metadata.
        it->second.actionIndex = childIndex;
        it->second.issueTick   = curTick();
    } else {
        ChildPfMeta meta;
        meta.actionIndex = childIndex;
        meta.issueTick   = curTick();
        childPfTable.emplace(addr, meta);

        // Count as an issued prefetch attributed to this child.
        switch (childIndex) {
          case 0: child0PfIssued++; break;
          case 1: child1PfIssued++; break;
          case 2: child2PfIssued++; break;
          case 3: child3PfIssued++; break;
          default: break;
        }
    }
}

void
MLPrefetchController::trackUsefulForAddr(Addr addr)
{
    auto it = childPfTable.find(addr);
    if (it == childPfTable.end())
        return;

    int childIndex = it->second.actionIndex;

    switch (childIndex) {
      case 0: child0PfUseful++; break;
      case 1: child1PfUseful++; break;
      case 2: child2PfUseful++; break;
      case 3: child3PfUseful++; break;
      default: break;
    }

    // Remove so we don't double-count usefulness.
    childPfTable.erase(it);
}

// ---- Q-table persistence + children signature -----------------------------

std::string
MLPrefetchController::childrenSignature() const
{
    std::ostringstream oss;
    for (auto *c : children) {
        oss << c->name() << ";";
    }
    return oss.str();
}

void
MLPrefetchController::saveQTable() const
{
    std::ofstream out(qfileName, std::ios::binary | std::ios::trunc);
    if (!out.is_open()) {
        warn("MLPrefetchController: could not save Q-table to %s\n",
             qfileName.c_str());
        return;
    }

    // 1) Write signature (length + string)
    std::string sig = childrenSignature();
    uint32_t sigLen = static_cast<uint32_t>(sig.size());
    out.write(reinterpret_cast<const char*>(&sigLen), sizeof(sigLen));
    out.write(sig.data(), sigLen);

    // 2) Write number of states
    uint64_t numStates = qTable.size();
    out.write(reinterpret_cast<const char*>(&numStates), sizeof(numStates));

    // 3) Dump state → row entries
    for (auto &entry : qTable) {
        uint64_t state = entry.first;
        auto &row = entry.second;

        uint32_t rowLen = static_cast<uint32_t>(row.size());

        out.write(reinterpret_cast<const char*>(&state), sizeof(state));
        out.write(reinterpret_cast<const char*>(&rowLen), sizeof(rowLen));
        out.write(reinterpret_cast<const char*>(row.data()),
                  rowLen * sizeof(double));
    }

    out.close();
    inform("MLPrefetchController: Q-table saved (%s, %llu states)\n",
           qfileName.c_str(), (unsigned long long)qTable.size());
}

void
MLPrefetchController::loadQTable()
{
    std::ifstream in(qfileName, std::ios::binary);
    if (!in.is_open()) {
        warn("MLPrefetchController: no saved Q-table (%s)\n",
             qfileName.c_str());
        return;
    }

    // 1) Read signature
    uint32_t sigLen = 0;
    in.read(reinterpret_cast<char*>(&sigLen), sizeof(sigLen));
    if (!in.good()) {
        warn("MLPrefetchController: failed to read signature length from %s\n",
             qfileName.c_str());
        return;
    }

    std::string savedSig(sigLen, '\0');
    in.read(&savedSig[0], sigLen);
    if (!in.good()) {
        warn("MLPrefetchController: failed to read signature from %s\n",
             qfileName.c_str());
        return;
    }

    std::string currentSig = childrenSignature();

    // SIG MISMATCH → ignore file
    if (savedSig != currentSig) {
        warn("MLPrefetchController: Q-table signature mismatch.\n"
             "Saved children = %s\nCurrent children = %s\n"
             "Ignoring saved Q-table.\n",
             savedSig.c_str(), currentSig.c_str());
        return;
    }

    // 2) Read number of states
    uint64_t numStates = 0;
    in.read(reinterpret_cast<char*>(&numStates), sizeof(numStates));
    if (!in.good()) {
        warn("MLPrefetchController: failed to read number of states from %s\n",
             qfileName.c_str());
        return;
    }

    qTable.clear();

    // 3) Read each state row
    for (uint64_t i = 0; i < numStates; i++) {
        uint64_t state;
        uint32_t rowLen;

        in.read(reinterpret_cast<char*>(&state), sizeof(state));
        in.read(reinterpret_cast<char*>(&rowLen), sizeof(rowLen));
        if (!in.good()) {
            warn("MLPrefetchController: failed to read state header "
                 "from %s\n", qfileName.c_str());
            qTable.clear();
            return;
        }

        std::vector<double> row(rowLen);
        in.read(reinterpret_cast<char*>(row.data()),
                rowLen * sizeof(double));
        if (!in.good()) {
            warn("MLPrefetchController: failed to read state row "
                 "from %s\n", qfileName.c_str());
            qTable.clear();
            return;
        }

        qTable[state] = row;
    }

    qtableLoaded = true;
    inform("MLPrefetchController: Loaded Q-table from %s (%llu states)\n",
           qfileName.c_str(), (unsigned long long)numStates);
}

} // namespace prefetch
} // namespace gem5
