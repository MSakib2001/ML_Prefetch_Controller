# -*- coding: utf-8 -*-
# Copyright (c) 2025 Alex Smith and Matthew D. Sinclair
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Authors: Alex Smith and Matt Sinclair

import argparse
import os
import re
import xml.etree.ElementTree as ET

 
class McPATValidator:
    def __init__(self, xml_stats_path, gem5_stats_path, is_ooo, verbose):
        """
        Making the assumption that the core is
        the only thing to be validated right now...
        """
        self._filename = xml_stats_path
        self._xml_tree = None
        self._gem5_stats_path = gem5_stats_path
        self._gem5_stats = {}
        self._is_ooo = is_ooo
        self._verbose = verbose
        self.parse_gem5_stats()
        self.open_xml()
        self.results_to_xml()

    def open_xml(self):
        try:
            self._xml_tree = ET.parse(self._filename)
        except Exception as e:
            raise RuntimeError(f"Failed to parse template XML '{self._filename}': {e}")
    
    def _zero_all_stats_in_component(self, comp):
        for stat in comp.iter("stat"):
            stat.attrib["value"] = "0"


    def print_tree(self):
        root = self._xml_tree.getroot()
        ET.indent(root)
        print(ET.tostring(root, encoding="unicode"))

    def dump_tree_to_file(self, destination):
        self._xml_tree.write(destination)

    def parse_gem5_stats(self):
        with open(self._gem5_stats_path) as file:
            for line in file:
                line = line.strip()
                # Skip empty lines and header/footer
                if not line or line.startswith("---"):
                    continue

                # Split into parts, handling multiple spaces
                parts = [p for p in line.split(" ") if p]

                # Ensure we have at least 3 parts (name, value, comment)
                if len(parts) >= 2:
                    stat_name = parts[0]
                    stat_value = parts[1]
                    self._gem5_stats[stat_name] = stat_value
    def get_gem5_stat(self, stat_name):
        try:
            return float(
                self._gem5_stats.get(
                    stat_name, f"Statistic '{stat_name}' not found"
                )
            )
        except:
            if self._verbose:
                print(f"{stat_name} was not found! returning 0!")
            return 0

    def results_to_xml(self):
        if self._xml_tree == None:
            return None
        xml_root = self._xml_tree.getroot()
        root_str = "system.cpu."
        root_cache_str = "system.cpu."
        root_sys_str = "system."
        idle_cycles = self.get_gem5_stat(root_str + "idleCycles")
        num_cycles = self.get_gem5_stat(root_str + "numCycles")
        for comp in xml_root.iter("component"):
        
            
            
            for param in comp.iter("param"):
                if comp.attrib["name"] == "core0":
                   if param.attrib["name"] == "machine_type":
                        if self._is_ooo:
                            param.attrib["value"] = "0"
                        else:
                            param.attrib["value"] = "1"
                if comp.attrib["name"] == "mc":
                   if param.attrib["name"] == "number_mcs":
                      param.attrib["value"] = "1"
                   elif param.attrib["name"] == "peak_transfer_rate":
                      param.attrib["value"] = str(self.get_gem5_stat(
                           root_sys_str + "mem_ctrl.dram.peakBW"
                      ))
                      
                # ---- early handling: zero whole components and skip further mapping ----
                if comp.attrib["name"] in ("itlb", "dtlb", "L1Directory0", "L2Directory0"):
                    self._zero_all_stats_in_component(comp)
                    continue  # don't let later stat-mapping override zeros      
                   
            for stat in comp.iter("stat"):
                if comp.attrib["name"] == "system":
                    if stat.attrib["name"] == "total_cycles":
                        stat.attrib["value"] = num_cycles
                    elif stat.attrib["name"] == "busy_cycles":
                        stat.attrib["value"] = num_cycles - idle_cycles
                    elif stat.attrib["name"] == "idle_cycles":
                        stat.attrib["value"] = idle_cycles
                elif comp.attrib["name"] == "core0":
                    if stat.attrib["name"] == "total_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "fetchStats0.numInsts"
                        )
                    elif stat.attrib["name"] == "int_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numIntInsts"
                        )
                    elif stat.attrib["name"] == "fp_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numFpInsts"
                        )
                        
                        
                    elif comp.attrib["name"] == "dcache":
                        
                        if stat.attrib["name"] == "write_misses":
                            # v25 fallback if WriteReq.misses is missing
                            wmiss = self.get_gem5_stat(root_cache_str + "dcache.WriteReq.misses::total")
                            if wmiss == 0:
                                overall = self.get_gem5_stat(root_cache_str + "dcache.overallMisses::total")
                                rmiss   = self.get_gem5_stat(root_cache_str + "dcache.ReadReq.misses::total")
                                wmiss   = max(0.0, overall - rmiss)
                            stat.attrib["value"] = wmiss

                        elif comp.attrib["name"] == "L20":
                            if stat.attrib["name"] == "read_accesses":
                                val = self.get_gem5_stat(root_sys_str + "l2cache.ReadExReq.accesses::total")
                                if val == 0:
                                    val = self.get_gem5_stat(root_sys_str + "l2cache.ReadReq.accesses::total")
                                    if val == 0:
                                        val = self.get_gem5_stat(root_sys_str + "l2cache.overallAccesses::total")
                                stat.attrib["value"] = val
                            elif stat.attrib["name"] == "read_misses":
                                val = self.get_gem5_stat(root_sys_str + "l2cache.ReadExReq.misses::total")
                                if val == 0:
                                    val = self.get_gem5_stat(root_sys_str + "l2cache.ReadReq.misses::total")
                                stat.attrib["value"] = val

                        # normalize to string for every stat
                        stat.attrib["value"] = str(stat.attrib["value"])    
                            
                        
                        
                    elif stat.attrib["name"] == "branch_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "branchPred.condPredicted"
                        )
                    elif stat.attrib["name"] == "branch_mispredictions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "branchPred.condIncorrect"
                        )
                    elif stat.attrib["name"] == "load_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numLoadInsts"
                        )
                    elif stat.attrib["name"] == "store_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numStoreInsts"
                        )
                    if stat.attrib["name"] == "committed_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numInsts"
                        )
                    elif stat.attrib["name"] == "committed_int_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numIntInsts"
                        )
                    elif stat.attrib["name"] == "committed_fp_instructions":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.numFpInsts"
                        )
                    elif stat.attrib["name"] == "int_regfile_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "executeStats0.numIntRegReads"
                        )
                    elif stat.attrib["name"] == "float_regfile_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "executeStats0.numFpRegReads"
                        )
                    elif stat.attrib["name"] == "int_regfile_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "executeStats0.numIntRegWrites"
                        )
                    elif stat.attrib["name"] == "float_regfile_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "executeStats0.numFpRegWrites"
                        )
                    elif stat.attrib["name"] == "function_calls":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "commitStats0.functionCalls"
                        )
                    elif stat.attrib["name"] == "ialu_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "issuedInstType_0::IntAlu"
                        )
                    elif stat.attrib["name"] == "fpu_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatAdd"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatMult"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatMultAcc"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatDiv"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatMisc"
                        )
                    elif stat.attrib["name"] == "mul_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "issuedInstType_0::IntDiv"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::IntMult"
                        )
                    elif stat.attrib["name"] == "cdb_alu_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "issuedInstType_0::IntAlu"
                        )
                    elif stat.attrib["name"] == "cdb_fpu_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatAdd"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatMult"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatMultAcc"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatDiv"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::FloatMisc"
                        )
                    elif stat.attrib["name"] == "cdb_mul_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "issuedInstType_0::IntDiv"
                        )
                        stat.attrib["value"] += self.get_gem5_stat(
                            root_str + "issuedInstType_0::IntMult"
                        )
                    elif stat.attrib["name"] == "rename_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "rename.intLookups"
                        )
                    elif stat.attrib["name"] == "rename_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "rename.intReturned"
                        )
                        """
                          try:
                            stat.attrib['value'] = "0" if not self._is_ooo else int(
                               (self.get_gem5_stat(root_str + "rename.intLookups") / self.get_gem5_stat(root_str + "rename.lookups")) * self.get_gem5_stat(root_str + "rename.renamedOperands"))
                          except:
                            stat.attrib['value'] = "0"
                          """
                    elif stat.attrib["name"] == "fp_rename_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "rename.fpLookups"
                        )
                    elif stat.attrib["name"] == "fp_rename_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "rename.fpReturned"
                        )
                        """
                          try:
                            stat.attrib['value'] = "0" if not self._is_ooo else int(
                               (self.get_gem5_stat(root_str + "rename.fpLookups") / self.get_gem5_stat(root_str + "rename.lookups")) * self.get_gem5_stat(root_str + "rename.renamedOperands"))
                          except:
                            stat.attrib['value'] = "0"
                          """
                    elif stat.attrib["name"] == "inst_window_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "intInstQueueReads"
                        )
                    elif stat.attrib["name"] == "inst_window_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "intInstQueueWrites"
                        )
                    elif stat.attrib["name"] == "inst_window_wakeup_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "intInstQueueWakeupAccesses"
                        )
                    elif stat.attrib["name"] == "fp_inst_window_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "fpInstQueueReads"
                        )
                    elif stat.attrib["name"] == "fp_inst_window_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "fpInstQueueWrites"
                        )
                    elif (
                        stat.attrib["name"] == "fp_inst_window_wakeup_accesses"
                    ):
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "fpInstQueueWakeupAccesses"
                        )
                elif comp.attrib["name"] == "BTB":
                    if stat.attrib["name"] == "read_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str + "branchPred.BTBLookups"
                        )
                    elif stat.attrib["name"] == "write_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_str
                            + "branchPred.BTBHits"
                        )
                elif comp.attrib["name"] == "dcache":
                    if stat.attrib["name"] == "read_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_cache_str
                            + "dcache.ReadReq.accesses::total"
                        )
                    elif stat.attrib["name"] == "write_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_cache_str
                            + "dcache.WriteReq.accesses::total"
                        )
                    elif stat.attrib["name"] == "read_misses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_cache_str + "dcache.ReadReq.misses::total"
                        )
                    elif stat.attrib["name"] == "write_misses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_cache_str + "dcache.WriteReq.misses::total"
                        )
                    stat.attrib["value"] = int(stat.attrib["value"])
                elif comp.attrib["name"] == "icache":
                    if stat.attrib["name"] == "read_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_cache_str
                            + "icache.ReadReq.accesses::total"
                        )
                    elif stat.attrib["name"] == "read_misses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_cache_str + "icache.ReadReq.misses::total"
                        )
                    stat.attrib["value"] = int(stat.attrib["value"])
                elif comp.attrib["name"] == "L20":
                    if stat.attrib["name"] == "read_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str
                            + "l2cache.ReadExReq.accesses::total"
                        )
                    elif stat.attrib["name"] == "write_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str + "l2cache.overallAccesses::total"
                        ) + self.get_gem5_stat(
                            root_sys_str
                            + "l2cache.WritebackClean.accesses::total"
                        )
                    elif stat.attrib["name"] == "read_misses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str + "l2cache.ReadExReq.misses::total"
                        )
                    elif stat.attrib["name"] == "write_misses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str + "l2cache.overallMisses::total"
                        ) - self.get_gem5_stat(
                            root_sys_str + "l2cache.ReadExReq.misses::total"
                        )
                elif comp.attrib["name"] == "mc":
                    if stat.attrib["name"] == "memory_reads":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str + "mem_ctrl.readReqs"
                        )
                    elif stat.attrib["name"] == "memory_writes":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str + "mem_ctrl.writeReqs"
                        )
                    elif stat.attrib["name"] == "memory_accesses":
                        stat.attrib["value"] = self.get_gem5_stat(
                            root_sys_str + "mem_ctrl.readReqs"
                        ) + self.get_gem5_stat(
                            root_sys_str + "mem_ctrl.writeReqs"
                        )
                stat.attrib["value"] = str(stat.attrib["value"])

def main(args):
    is_ooo = True if args.cpu_type == "out-of-order" else False
    if args.verbose:
        print(f"Processor is {args.cpu_type}")

    m = McPATValidator(
        f"{args.template_xml}", args.m5_stats, is_ooo, args.verbose
    )
    
    m.dump_tree_to_file(f"{args.output_xml}")
    
    
def parse_cli_args():
    parser = argparse.ArgumentParser()
    
    parser.add_argument(
        "--cpu_type",
        type=str,
        choices=["in-order", "out-of-order"],
        default="in-order",
        help="The CPU type your processor is",
    )

    parser.add_argument(
        "--m5_stats",
        type=str,
        default="./m5out/stats.txt",
        help="Path to gem5 stats file (assumes ./m5out/stats.txt if not specified)",
    )

    parser.add_argument(
        "--template_xml",
        type=str,
        default="temp.xml",
        help="Template XML File",
    )
    
    parser.add_argument(
        "--output_xml",
        type=str,
        default="temp.xml",
        help="Filename of XML output",
    )

    parser.add_argument("--verbose", "-v", action="store_true")

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_cli_args()
    main(args)
