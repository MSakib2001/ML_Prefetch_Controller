from m5.params import *
from m5.SimObject import Parent
from m5.objects import BasePrefetcher, QueuedPrefetcher, BaseCPU

class MLPrefetchController(QueuedPrefetcher):
    type = "MLPrefetchController"
    cxx_class = "gem5::prefetch::MLPrefetchController"
    cxx_header = "mem/cache/prefetch/ml_prefetch_controller.hh"

    # Child prefetchers (stride, tagged, etc.)
    children = VectorParam.BasePrefetcher(
        "List of child prefetchers managed by RL"
    )

    # Parent cache object name (string to avoid SimObject cycles)
    cache_name = Param.String("", "Name (path) of parent cache SimObject")

    # RL parameters
    current_action  = Param.Int(0, "Initial action index")
    ticks_per_epoch = Param.Tick(1_000_000, "Epoch duration in ticks")
    learning_rate   = Param.Float(0.2, "Learning rate")
    explore_rate    = Param.Float(0.05, "Exploration probability")

    # CPU pointer (needed for IPC-based reward)
    cpu = Param.BaseCPU("CPU pointer for IPC reward")

    # Debug CSV logging
    debug_logging = Param.Bool(False, "Enable CSV logging for RL debugging")

    # NEW: persistent Q-table filename (optional)
    qtable_file = Param.String("", "Override Q-table filename (optional)")
