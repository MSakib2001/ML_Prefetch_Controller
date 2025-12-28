# ------------------------------------------------------------
# MacheSuite-ready ML Prefetch Controller Test Config
# ------------------------------------------------------------

import os, sys

gem5_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
sys.path.append(gem5_root)

from m5.objects import *
from configs.common.Caches import *

# ------------------------------------------------------------
# 1. System + Clock + Memory
# ------------------------------------------------------------
system = System()
system.clk_domain = SrcClockDomain(clock="4GHz",
                                   voltage_domain=VoltageDomain())
system.mem_mode = "timing"
system.mem_ranges = [AddrRange("512MB")]

system.cpu = O3CPU()

# ------------------------------------------------------------
# 2. L1 + L2 Cache Hierarchy (MacheSuite recommended)
# ------------------------------------------------------------
# L1 caches
system.cpu.icache = L1_ICache(size="16kB", assoc=4)
system.cpu.dcache = L1_DCache(size="16kB", assoc=4)

# L2 bus + L2
system.l2bus = L2XBar()

system.l2cache = L2Cache(
    size="32kB",
    assoc=4,
)

#system.l2cache.mshrs = 4
#system.l2cache.tgts_per_mshr = 4


# ------------------------------------------------------------
# 3. Attach the ML Prefetch Controller *to the L2 Cache*
# ------------------------------------------------------------
system.l2cache.prefetcher = MLPrefetchController(
    cpu             = system.cpu,
    cache_name      = "system.l2cache",
    current_action  = 0,
    ticks_per_epoch = 2_000_000,
    learning_rate   = 0.0,#0.3,
    explore_rate    = 0.0,#0.1, 
    debug_logging = False,  
    # optional but use if using custom trained qtable:
    # qtable_file   = "qtable_machsuite.bin",
    children = [
        StridePrefetcher(degree=1, distance=1), 
        StridePrefetcher(degree=4, distance=2), 
        #AMPMPrefetcher(),
       #DCPTPrefetcher(),
        TaggedPrefetcher(),
    ]
)

#system.l2cache.prefetcher = TaggedPrefetcher( 
#    degree = 4,
#    distance = 2,
#)

# ------------------------------------------------------------
# 4. Memory system + DRAM
# ------------------------------------------------------------
system.membus = SystemXBar()

system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = HBM_2000_4H_1x64()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

# ------------------------------------------------------------
# 5. Port Wiring (explicit and version-safe)
# ------------------------------------------------------------

# CPU <-> L1
system.cpu.icache.cpu_side = system.cpu.icache_port
system.cpu.dcache.cpu_side = system.cpu.dcache_port

# L1 <-> L2 bus
system.cpu.icache.mem_side = system.l2bus.cpu_side_ports
system.cpu.dcache.mem_side = system.l2bus.cpu_side_ports

# L2 <-> L2 bus
system.l2cache.cpu_side = system.l2bus.mem_side_ports

# L2 <-> Main memory bus
system.l2cache.mem_side = system.membus.cpu_side_ports

# System port <-> memory bus
system.system_port = system.membus.cpu_side_ports

# ------------------------------------------------------------
# 6. Interrupt Controller (required for O3CPU)
# ------------------------------------------------------------
system.cpu.createInterruptController()

if hasattr(system.cpu, "interrupts"):
    system.cpu.interrupts[0].pio           = system.membus.mem_side_ports
    system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
    system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports

# ------------------------------------------------------------
# 7. Workload Setup (MacheSuite binary)
# ------------------------------------------------------------
machsuite_name = "beta_test1"
machsuite_dir = os.path.join(gem5_root, "tests/test-progs/MachSuite/extra")

machsuite_path = os.path.join(machsuite_dir, machsuite_name)

if not os.path.exists(machsuite_path):
    m5.fatal(f"MacheSuite binary not found: {machsuite_path}")

# Correct: arguments should be just filenames
inputs = ["input.data", "check.data"]

process = Process(
    cmd=[machsuite_path] + inputs,
    cwd=machsuite_dir     # VERY IMPORTANT
)


system.workload = SEWorkload.init_compatible(machsuite_path)
system.cpu.workload = process
system.cpu.createThreads()

root = Root(full_system=False, system=system)

# ------------------------------------------------------------
# 8. Run Simulation
# ------------------------------------------------------------
m5.instantiate()

print("\n===== Starting ML Prefetch Controller + MacheSuite Test =====\n")
event = m5.simulate()
print(f"\nExited @ tick {m5.curTick()} because: {event.getCause()}\n")
