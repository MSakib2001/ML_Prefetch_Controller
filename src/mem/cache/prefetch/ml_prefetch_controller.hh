#ifndef __MEM_CACHE_PREFETCH_ML_PREFETCH_CONTROLLER_HH__
#define __MEM_CACHE_PREFETCH_ML_PREFETCH_CONTROLLER_HH__

#include <vector>
#include <map>
#include <string>
#include <unordered_map>

#include "mem/cache/prefetch/queued.hh"
#include "params/MLPrefetchController.hh"
#include "sim/eventq.hh"

namespace gem5
{

class BaseCPU;
class BaseCache;
class CacheAccessor;

namespace prefetch
{

/**
 * MLPrefetchController
 *
 * RL-style bandit controller over a set of child prefetchers.
 * State is a compact encoding of:
 *   - ΔmissRate (smoothed change in L2 miss rate)
 *   - ΔIPC      (change in IPC)
 *   - accuracy  (normalized improvement in smoothed miss rate)
 *
 * Reward is shaped from:
 *   - IPC delta sign
 *   - accuracy (centered around 0)
 *   - small per-action penalties (for more aggressive prefetchers)
 *
 * This controller issues prefetches centrally, while children are used
 * as pattern providers. Per-child statistics are tracked explicitly.
 */
class MLPrefetchController : public Queued
{
  public:
    PARAMS(MLPrefetchController);
    MLPrefetchController(const Params &p);

    void startup() override;

    void calculatePrefetch(const PrefetchInfo &pfi,
                           std::vector<AddrPriority> &addresses,
                           const CacheAccessor &cache) override;

    void notify(const CacheAccessProbeArg &acc,
                const PrefetchInfo &pfi) override;

    void regStats() override;

  private:
    // ---- Parent cache (resolved via cache_name string in params) ----
    BaseCache   *cachePtr  = nullptr;
    std::string  cacheName;

    // ---- RL child prefetchers + action space ----
    std::vector<Base *> children;
    int currentAction;    // semantic: -1 = OFF, >=0 = index into children
    int numActions;       // children.size() + 1 (for OFF)

    // ---- Epoch timing ----
    const Tick epoch_ticks;
    EventFunctionWrapper update_event;

    // ---- Cache stats snapshots for REAL miss rate ----
    uint64_t lastAccesses = 0;
    uint64_t lastMisses   = 0;

    // ---- Notify-based stats (debug only, not used for RL) ----
    uint64_t epochAccesses = 0;
    uint64_t epochMisses   = 0;

    // ---- Miss-rate history (for ΔmissRate & accuracy) ----
    double lastMissRate       = 0.0;  // raw last miss rate (for logging)
    double smoothedMissRate   = 0.0;  // smoothed current miss rate
    double lastSmoothedMiss   = 0.0;  // smoothed miss from previous epoch
    bool   haveSmoothedMiss   = false;

    // ---- RL value table ----
    // state -> Q-values per bandit action (0..numActions-1)
    std::map<uint64_t, std::vector<double>> qTable;
    uint64_t lastState   = 0;
    int      lastAction  = 0;   // bandit index (0..numActions-1)
    double   lastReward  = 0.0;

    // ---- RL hyperparameters ----
    double learningRate;
    double exploreRate;         // decays over time
    std::vector<double> actionPenalties; // mild bias per action
    bool   debugLogging;        // controls CSV / verbose logging

    // ---- IPC-based reward tracking ----
    BaseCPU *cpuPtr       = nullptr;
    uint64_t lastTotalOps = 0;
    double   lastIpc      = 0.0;  // last epoch's IPC (for ΔIPC & reward)
    Tick     lastIpcTick  = 0;

    // ---- Per-child prefetch attribution ----
    struct ChildPfMeta
    {
        int  actionIndex;  // semantic child index (0..children.size()-1)
        Tick issueTick;
    };

    // Map from block address -> metadata about issuing child.
    std::unordered_map<Addr, ChildPfMeta> childPfTable;
    static const size_t MaxTrackedPrefetches = 2048;

    // ---- Stats: RL action usage (bandit indices) ----
    statistics::Scalar actionUse0;
    statistics::Scalar actionUse1;
    statistics::Scalar actionUse2;
    statistics::Scalar actionUse3;

    // ---- Stats: per-child issued / useful / redundant prefetches ----
    // These are indexed by *semantic* child index: 0,1,2,...
    // (OFF action has no children and no per-child stats.)
    statistics::Scalar child0PfIssued;
    statistics::Scalar child1PfIssued;
    statistics::Scalar child2PfIssued;
    statistics::Scalar child3PfIssued;

    statistics::Scalar child0PfUseful;
    statistics::Scalar child1PfUseful;
    statistics::Scalar child2PfUseful;
    statistics::Scalar child3PfUseful;

    statistics::Scalar child0PfRedundant;
    statistics::Scalar child1PfRedundant;
    statistics::Scalar child2PfRedundant;
    statistics::Scalar child3PfRedundant;

    // ---- Q-table persistence support ----
    std::string qfileName;     // file to save/load Q-table
    bool qtableLoaded = false; // diagnostic

    // Build child signature (stable identity)
    std::string childrenSignature() const;

    // Save Q-table to disk
    void saveQTable() const;

    // Load Q-table from disk (if exists and compatible)
    void loadQTable();

    // ---- Internal helpers ----
    void updateModel();
    void endEpoch();

    int  encodeDeltaMiss(double d) const;
    int  encodeDeltaIpc(double d) const;
    int  encodeAccuracy(double a) const;
    int  selectAction(uint64_t state);
    void switchTo(int index);   // semantic index in [-1, children.size()-1]

    void trackIssuedForChild(int childIndex, Addr addr);
    void trackUsefulForAddr(Addr addr);
};

} // namespace prefetch
} // namespace gem5

#endif // __MEM_CACHE_PREFETCH_ML_PREFETCH_CONTROLLER_HH__