# -*- coding: utf-8 -*-
# HW2 config with option for TimingSimpleCPU or MinorCPU (with FU latency tweaks)

import os
import m5
from m5.objects import (
    System, SrcClockDomain, VoltageDomain, AddrRange,
    MemCtrl, SystemXBar, L2XBar, Process, Root, SEWorkload,
    TimingSimpleCPU, X86MinorCPU, MinorFUPool,
    MinorDefaultIntFU, MinorDefaultIntMulFU, MinorDefaultIntDivFU,
    MinorDefaultFloatSimdFU, MinorDefaultMemFU, MinorDefaultMiscFU,
    DDR3_1600_8x8, DDR3_2133_8x8, DDR4_2400_8x8, DDR5_4400_4x8,
    LPDDR2_S4_1066_1x32, HBM_1000_4H_1x64, HBM_2000_4H_1x64,
)

m5.util.addToPath("../../")
from common import SimpleOpts
#from caches import L1ICache, L1DCache, L2Cache
from caches import *

# ----------------- CLI options -----------------
thispath = os.path.dirname(os.path.realpath(__file__))
default_binary = os.path.join(
    thispath,
    "../../../",
    "tests/test-progs/daxpy-X86/daxpy",
)

SimpleOpts.add_option("--cpu-type", default="timing",
    help="CPU model: timing | minor (default: timing)")
SimpleOpts.add_option("--clk", default="4GHz", help="CPU/system clock")
SimpleOpts.add_option("--mem-type", default="HBM_1000_4H_1x64")
SimpleOpts.add_option("--mem-size", default="512MiB")
SimpleOpts.add_option("binary", nargs="?", default=default_binary)

# Cache options
SimpleOpts.add_option("--l1i-size", default="32KiB")
SimpleOpts.add_option("--l1d-size", default="32KiB")
SimpleOpts.add_option("--l2-size",  default="64KiB")

# Part 3 settings
SimpleOpts.add_option("--fpu-issue-lat", default=None)
SimpleOpts.add_option("--fpu-op-lat",    default=None)
SimpleOpts.add_option("--enforce-sum7", action="store_true", default=False)

# Part 4 settings
SimpleOpts.add_option("--int-op-lat", default=None)
SimpleOpts.add_option("--fp-op-lat",  default=None)

args = SimpleOpts.parse_args()

# ----------------- FU customizations for Minor -----------------
class MyFloatSIMDFU(MinorDefaultFloatSimdFU):
    def __init__(self, options=None):
        super(MyFloatSIMDFU, self).__init__()
        if not options:
            return
        fi, fo = options.fpu_issue_lat, options.fpu_op_lat
        if options.enforce_sum7 and (fi is None) ^ (fo is None):
            if fi is not None: fi, fo = int(fi), 7 - int(fi)
            else: fo, fi = int(fo), 7 - int(fo)
        if fi is not None: self.issueLat = int(fi)
        if fo is not None: self.opLat = int(fo)
        if options.fp_op_lat is not None: self.opLat = int(options.fp_op_lat)

class MyFUPool(MinorFUPool):
    def __init__(self, options=None):
        super(MyFUPool, self).__init__()
        self.funcUnits = [
            MinorDefaultIntFU(), MinorDefaultIntFU(),
            MinorDefaultIntMulFU(), MinorDefaultIntDivFU(),
            MinorDefaultMemFU(), MinorDefaultMiscFU(),
            MyFloatSIMDFU(options),
        ]
        if args.int_op_lat is not None:
            for fu in self.funcUnits:
                if isinstance(fu, MinorDefaultIntFU):
                    fu.opLat = int(args.int_op_lat)

class MyMinorCPU(X86MinorCPU):
    def __init__(self, options=None):
        super(MyMinorCPU, self).__init__()
        self.executeFuncUnits = MyFUPool(options)

# ----------------- Build SE system -----------------
system = System()
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = args.clk
system.clk_domain.voltage_domain = VoltageDomain()
system.mem_mode = "timing"
system.mem_ranges = [AddrRange(args.mem_size)]

# Choose CPU type
cpu_sel = args.cpu_type.lower()
if cpu_sel == "timing":
    system.cpu = TimingSimpleCPU()
elif cpu_sel == "minor":
    system.cpu = MyMinorCPU(args)
else:
    m5.fatal(f"Unknown --cpu-type '{args.cpu_type}' (use 'timing' or 'minor')")

# Caches
system.cpu.icache = L1ICache(args); system.cpu.icache.size = "32KiB"
system.cpu.dcache = L1DCache(args); system.cpu.dcache.size = "32KiB"
system.cpu.icache.connectCPU(system.cpu)
system.cpu.dcache.connectCPU(system.cpu)

system.l2bus = L2XBar()
system.cpu.icache.connectBus(system.l2bus)
system.cpu.dcache.connectBus(system.l2bus)

system.l2cache = L2Cache(args); system.l2cache.size = "64KiB"
system.l2cache.connectCPUSideBus(system.l2bus)

system.membus = SystemXBar()
system.l2cache.connectMemSideBus(system.membus)

system.cpu.createInterruptController()
system.cpu.interrupts[0].pio = system.membus.mem_side_ports
system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports
system.system_port = system.membus.cpu_side_ports

# Memory controller
mem_map = {
    "DDR3_1600_8x8": DDR3_1600_8x8,
    "DDR3_2133_8x8": DDR3_2133_8x8,
    "DDR4_2400_8x8": DDR4_2400_8x8,
    "DDR5_4400_4x8": DDR5_4400_4x8,
    "LPDDR2_S4_1066_1x32": LPDDR2_S4_1066_1x32,
    "HBM_1000_4H_1x64": HBM_1000_4H_1x64,
    "HBM_2000_4H_1x64": HBM_2000_4H_1x64,
}
if args.mem_type not in mem_map:
    m5.fatal(f"Unknown --mem-type '{args.mem_type}'")
system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = mem_map[args.mem_type]()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

# Workload
system.workload = SEWorkload.init_compatible(args.binary)
proc = Process(); proc.cmd = [args.binary]
system.cpu.workload = proc
system.cpu.createThreads()

# Run
root = Root(full_system=False, system=system)
m5.instantiate()
print("Beginning simulation!")
ev = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {ev.getCause()}")
