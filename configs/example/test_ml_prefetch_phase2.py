# Simple standalone test for Phase 2: ML Prefetch Controller wrapper
import os, sys

# Get the absolute path to gem5 root (two levels up from this file)
gem5_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

# (Optional) add gem5_root to sys.path if you need to import configs
sys.path.append(gem5_root)

from m5.objects import *
from m5.util import addToPath
from configs.common.Caches import *

# Path to hello binary
hello_path = os.path.join(
    os.getcwd(), "tests/test-progs/hello/bin/x86/linux/hello"
)

# ---------------------------------------------------------------------
# 1. System Setup
# ---------------------------------------------------------------------
system = System()
system.clk_domain = SrcClockDomain(clock="1GHz", voltage_domain=VoltageDomain())
system.mem_mode = "timing"
system.mem_ranges = [AddrRange("512MB")]

system.cpu = TimingSimpleCPU()
system.membus = SystemXBar()

# ---------------------------------------------------------------------
# 2. Cache and Prefetcher Setup (THE FIX IS HERE)
# ---------------------------------------------------------------------
system.cpu.dcache = L1_DCache(
    size="32kB",
    assoc=2,
    prefetcher=MLPrefetchController(
        current_action=0,  # start with first prefetcher
        
        # *** BUG FIX: The parameter is 'children', not 'child_prefetchers' ***
        children=[
            StridePrefetcher(degree=2, distance=1), # Child 0 (Queued)
            TaggedPrefetcher(),                   # Child 1 (Not Queued)
        ],
    ),
)

system.cpu.icache = L1_ICache(size="32kB", assoc=2)

# Connect caches
system.cpu.icache_port = system.cpu.icache.cpu_side
system.cpu.dcache_port = system.cpu.dcache.cpu_side

# ---------------------------------------------------------------------
# 3. Memory and Interrupts
# ---------------------------------------------------------------------
system.cpu.icache.mem_side = system.membus.cpu_side_ports  
system.cpu.dcache.mem_side = system.membus.cpu_side_ports

system.cpu.createInterruptController()
# Note: These connections are for X86 only
system.cpu.interrupts[0].pio = system.membus.mem_side_ports
system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports

system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

system.system_port = system.membus.cpu_side_ports

# ---------------------------------------------------------------------
# 4. Workload
# ---------------------------------------------------------------------


hello_path = os.path.join(
    gem5_root, "tests/test-progs/hello/bin/x86/linux/hello"
)

# Check if the hello binary exists
if not os.path.exists(hello_path):
    m5.fatal(f"Hello binary not found at: {hello_path}\n"
             "Please build it: 'cd tests/test-progs/hello && make'")

system.workload = SEWorkload.init_compatible(hello_path)
process = Process(cmd=[hello_path])
system.cpu.workload = process
system.cpu.createThreads()

# ---------------------------------------------------------------------
# 5. Run Simulation
# ---------------------------------------------------------------------
root = Root(full_system=False, system=system)
m5.instantiate()

print("\n===== Starting simulation (Phase 2: ML Prefetch Controller) =====\n")
exit_event = m5.simulate()
print(f"\nExiting @ tick {m5.curTick()} because {exit_event.getCause()}\n")