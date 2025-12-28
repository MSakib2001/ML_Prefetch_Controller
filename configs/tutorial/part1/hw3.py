# HW3 config (gem5 v21.0 style) — ARM SE, single core, L1 16kB 8-way, L2 128kB 16-way, DDR3_1600_8x8
import os
import m5
from m5.objects import (
    System, SrcClockDomain, VoltageDomain, AddrRange,
    MemCtrl, SystemXBar, L2XBar, Process, Root, SEWorkload,
    TimingSimpleCPU, MinorCPU, O3CPU,        # ARM classes (v21.0)
    TournamentBP,                             # branch predictor
    DDR3_1600_8x8
)



m5.util.addToPath(os.path.join(os.path.dirname(__file__), "..", ".."))
from common import SimpleOpts
from common.Caches import L1_ICache, L1_DCache, L2Cache

# ----------------- CLI options (minimal) -----------------
SimpleOpts.add_option("--cpu-type", default="timing",
    help="CPU model: timing | minor | o3 (default: timing)")
SimpleOpts.add_option("--cpu-clock", default="2GHz", help="CPU clock (default 2GHz)")
SimpleOpts.add_option("--sys-clock", default="2GHz", help="System clock (default 2GHz)")
SimpleOpts.add_option("--mem-size",  default="2GB",  help="Memory size (default 2GB)")
SimpleOpts.add_option("--binary", nargs="?", default=None, help="Path to AArch64 binary")
args = SimpleOpts.parse_args()

if not args.binary:
    m5.fatal("Please pass the AArch64 binary path (use --binary).")

# ----------------- Build SE system -----------------
system = System()
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = args.sys_clock
system.clk_domain.voltage_domain = VoltageDomain()
system.mem_mode = "timing"
system.mem_ranges = [AddrRange(args.mem_size)]

# CPU
cpu_sel = args.cpu_type.lower()
if cpu_sel == "timing":
    system.cpu = TimingSimpleCPU()
elif cpu_sel == "minor":
    system.cpu = MinorCPU()
elif cpu_sel == "o3":
    system.cpu = O3CPU()
else:
    m5.fatal(f"Unknown --cpu-type '{args.cpu_type}' (use timing|minor|o3)")

# CPU frequency
system.cpu.clk_domain = SrcClockDomain()
system.cpu.clk_domain.clock = args.cpu_clock
system.cpu.clk_domain.voltage_domain = VoltageDomain()


# Caches: L1I/L1D 16kB 8-way, unified L2 128kB 16-way
# L1s
system.cpu.icache = L1_ICache(size="16kB", assoc=8)
system.cpu.dcache = L1_DCache(size="16kB", assoc=8)

# L2 + crossbars
system.l2bus  = L2XBar()
system.l2cache = L2Cache(size="128kB", assoc=16)
system.membus = SystemXBar()

# Memory controller: DDR3_1600_8x8 (McPAT supports up to DDR3 only)
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]


# ---- Port wiring (explicit, version-proof) ----
# CPU <-> L1
system.cpu.icache.cpu_side = system.cpu.icache_port
system.cpu.dcache.cpu_side = system.cpu.dcache_port

# L1 <-> L2 XBar (toward L2)
system.cpu.icache.mem_side = system.l2bus.cpu_side_ports
system.cpu.dcache.mem_side = system.l2bus.cpu_side_ports

# L2 <-> L2 XBar
system.l2cache.cpu_side = system.l2bus.mem_side_ports

# L2 <-> Mem XBar (toward memory)
system.l2cache.mem_side = system.membus.cpu_side_ports

# System port <-> Mem XBar
system.system_port = system.membus.cpu_side_ports

# DRAM ctrl <-> Mem XBar
system.mem_ctrl.port = system.membus.mem_side_ports


# Some ISAs need interrupts wiring; guard it so it doesn't break on SE
if hasattr(system.cpu, "createInterruptController"):
    system.cpu.createInterruptController()
    if hasattr(system.cpu, "interrupts"):
        try:
            system.cpu.interrupts[0].pio = system.membus.mem_side_ports
            system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
            system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports
        except Exception:
            pass


# Workload (AArch64 static binaries using m5ops for ROI)
system.workload = SEWorkload.init_compatible(args.binary)
proc = Process()
proc.cmd = [args.binary]
system.cpu.workload = proc
system.cpu.createThreads()

# Run
root = Root(full_system=False, system=system)
m5.instantiate()
print("Beginning simulation!")
ev = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {ev.getCause()}")
