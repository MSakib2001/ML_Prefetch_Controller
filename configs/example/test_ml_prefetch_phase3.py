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
system.cpu.icache = L1_ICache(size="16kB", assoc=8)
system.cpu.dcache = L1_DCache(size="16kB", assoc=8)

# L2 bus + L2
system.l2bus = L2XBar()

system.l2cache = L2Cache(
    size="256kB",
    assoc=16,
)

# ------------------------------------------------------------
# 3. Attach the ML Prefetch Controller *to the L2 Cache*
# ------------------------------------------------------------
system.l2cache.prefetcher = MLPrefetchController(
    cpu             = system.cpu,
    cache_name      = "system.l2cache",
    current_action  = 0,
    ticks_per_epoch = 5_000_000,
    learning_rate   = 0.2,
    explore_rate    = 0.05,
    debug_logging = False,   # <-- T/F flipped, logs if false
    children = [
        StridePrefetcher(degree=1, distance=1),
        StridePrefetcher(degree=4, distance=2),
        TaggedPrefetcher(),
    ]
)

# ------------------------------------------------------------
# 4. Memory system + DRAM
# ------------------------------------------------------------
system.membus = SystemXBar()

system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
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
machsuite_name = "gemm"    # <---- EDIT THIS
machsuite_path = os.path.join(
    #gem5_root, "tests/test-progs/machsuite/bin", machsuite_name
    gem5_root, "tests/test-progs/project/phase3-test"
)

if not os.path.exists(machsuite_path):
    m5.fatal(f"MacheSuite binary not found: {machsuite_path}")

system.workload = SEWorkload.init_compatible(machsuite_path)
process = Process(cmd=[machsuite_path])
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
