import glob
import re
import csv
import os

METRIC_LIST = [
    "system.cpu.numCycles",
    "system.cpu.cpi",
    "system.cpu.ipc",
    "system.cpu.instsIssued",

    "system.l2cache.demandHits::total",
    "system.l2cache.demandMisses::total",
    "system.l2cache.overallHits::total",
    "system.l2cache.overallMisses::total",
    "system.l2cache.demandMissRate::total",
    "system.l2cache.overallMissRate::total",

    "system.l2cache.demandMissLatency::total",
    "system.l2cache.overallMissLatency::total",
    "system.l2cache.demandAvgMissLatency::total",
    "system.l2cache.overallAvgMissLatency::total",

    "system.l2cache.prefetcher.demandMshrMisses",
    "system.l2cache.prefetcher.pfIssued",
    "system.l2cache.prefetcher.pfUnused",
    "system.l2cache.prefetcher.pfUseful",
    "system.l2cache.prefetcher.accuracy",
    "system.l2cache.prefetcher.coverage",
    "system.l2cache.prefetcher.pfLate",
    "system.l2cache.prefetcher.pfIdentified",

    "system.l2cache.prefetcher.actionUse_0",
    "system.l2cache.prefetcher.actionUse_1",
    "system.l2cache.prefetcher.actionUse_2",
    "system.l2cache.prefetcher.actionUse_3",

    "system.l2cache.prefetcher.children0.pfIssued",
    "system.l2cache.prefetcher.children0.pfUseful",
    "system.l2cache.prefetcher.children0.pfRedundant",
    "system.l2cache.prefetcher.children1.pfIssued",
    "system.l2cache.prefetcher.children1.pfUseful",
    "system.l2cache.prefetcher.children1.pfRedundant",
    "system.l2cache.prefetcher.children2.pfIssued",
    "system.l2cache.prefetcher.children2.pfUseful",
    "system.l2cache.prefetcher.children2.pfRedundant",
]

GENERIC_REGEX = r"^{metric}\s+([\d\.Ee+-]+)"

files = sorted(glob.glob("stats_*_ml_prefetched.txt"))
if not files:
    print("No stats_*_ml_prefetched.txt files found.")
    exit()

rows = []

for fname in files:
    with open(fname) as f:
        lines = f.readlines()

    row = {"benchmark": os.path.basename(fname)
                          .replace("stats_", "")
                          .replace("_ml_prefetched.txt", "")}

    # initialize all fields
    for metric in METRIC_LIST:
        row[metric] = ""

    # full-scan: keep the LAST match for each metric
    for line in lines:
        for metric in METRIC_LIST:
            pattern = GENERIC_REGEX.replace("{metric}", re.escape(metric))
            m = re.search(pattern, line)
            if m:
                row[metric] = m.group(1)  # overwrite previous values

    rows.append(row)

output_file = "machsuite_prefetch_summary.csv"
with open(output_file, "w", newline="") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=["benchmark"] + METRIC_LIST)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)

print(f"✔ Wrote {output_file} with {len(rows)} benchmarks.")
