# Simple standalone test for MLPrefetchController
import os, sys

# Get the absolute path to gem5 root (two levels up from this file)
gem5_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

# Now build the path to the hello binary
hello_path = os.path.join(gem5_root, 'tests/test-progs/hello/bin/x86/linux/hello')

# (Optional) add gem5_root to sys.path if you need to import configs
sys.path.append(gem5_root)

from m5.objects import *
from m5.util import addToPath
from configs.common.Caches import *



system = System()

# Basic clock and voltage
system.clk_domain = SrcClockDomain(clock="1GHz", voltage_domain=VoltageDomain())
system.mem_mode = "timing"
system.mem_ranges = [AddrRange("512MB")]

# CPU
system.cpu = TimingSimpleCPU()

# Memory bus
system.membus = SystemXBar()

# L1 Data Cache with ML prefetcher
system.cpu.dcache = L1_DCache(
    size="32kB",
    assoc=2,
    prefetcher=MLPrefetchController(
        degree=2,
        distance=1,
        use_requestor_id=True,
        confidence_threshold=50,
        table_entries="64",
        table_assoc=4,
    ),
)

# L1 Instruction Cache (no prefetcher needed)
system.cpu.icache = L1_ICache(size="32kB", assoc=2)

# Connect caches
system.cpu.icache_port = system.cpu.icache.cpu_side
system.cpu.dcache_port = system.cpu.dcache.cpu_side

# create the interrupt controller for the CPU (x86 only)
system.cpu.createInterruptController()

# connect the CPU interrupt ports to the memory bus (x86-specific)
system.cpu.interrupts[0].pio = system.membus.mem_side_ports
system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports



# Connect caches to memory
system.cpu.icache.mem_side = system.membus.cpu_side_ports
system.cpu.dcache.mem_side = system.membus.cpu_side_ports

# Simple memory controller
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

# System port (for functional accesses)
system.system_port = system.membus.cpu_side_ports

# Run a simple binary (replace with one you have)
system.workload = SEWorkload.init_compatible(hello_path)
process = Process(cmd=[hello_path])
system.cpu.workload = process
system.cpu.createThreads()

# Root and start
root = Root(full_system=False, system=system)
m5.instantiate()

print("\n===== Starting simulation with MLPrefetchController =====\n")
exit_event = m5.simulate()
print("\nExiting @ tick {} because {}\n".format(m5.curTick(), exit_event.getCause()))