ML-Based Adaptive Prefetch Controller in gem5

This repository contains the implementation and evaluation of an online machine-learning–based adaptive prefetch controller integrated into the gem5 simulator. The controller uses a contextual multi-armed bandit (Q-learning) formulation to dynamically select among multiple hardware prefetching strategies at runtime, aiming to provide robust performance across diverse workloads and cache configurations.

The project was developed as part of a graduate-level computer architecture course and is intended for research and educational use.

Overview

Modern hardware prefetchers are typically configured statically, which can lead to suboptimal performance when application memory behavior varies across phases or workloads. This project explores whether lightweight online learning can be used to adaptively select among heterogeneous prefetchers without requiring complex neural models or offline training.

We implement an MLPrefetchController that:

Observes runtime cache and prefetch statistics

Selects one of several candidate prefetchers (or disables prefetching)

Learns from feedback using a reward signal derived from performance metrics

Operates fully online, with optional training-and-freeze modes

The controller is evaluated using gem5 across a range of microbenchmarks and application kernels under varying cache sizes and resource constraints.

Key Contributions

Online adaptive prefetch selection using a contextual bandit framework

Integration into gem5 as a custom prefetcher SimObject

Support for training, freezing, and Q-table reuse

Extensive evaluation across:

Multiple cache configurations (L1/L2 size and associativity)

Static baseline prefetchers (Stride, Tagged, No Prefetch)

Phase-varying and adversarial memory access patterns

Detailed analysis of accuracy, coverage, pollution, and IPC trade-offs

Prefetchers Supported

The ML controller dynamically selects among the following child prefetchers:

Stride (1,1) — conservative sequential stride prefetcher

Stride (4,2) — aggressive stride prefetcher

Tagged Prefetcher — correlation-based tagged prefetching

OFF — no prefetching

Each child prefetcher is treated as an independent “arm” in the bandit formulation.

Learning Model

Algorithm: Contextual multi-armed bandit (Q-learning–style update)

State: Aggregated cache and prefetch statistics per epoch

Action: Select child prefetcher (or disable prefetching)

Reward: Function of IPC improvement, useful prefetches, and pollution penalties

Exploration: ε-greedy (configurable)

Operation modes:

Fully online

Train-then-freeze

Q-table persistence across runs

The design is inspired by prior work on bandit-based prefetch control, but differs in its integration, state representation, and reward formulation.

Repository Structure
.
├── src/
│   ├── mem/
│   │   └── MLPrefetchController.{hh,cc}
│   └── python/
│       └── ML_prefetch.py
├── configs/
│   └── custom_cache_configs.py
├── benchmarks/
│   ├── microbenchmarks/
│   └── machsuite/
├── scripts/
│   ├── run_experiments.sh
│   └── parse_stats.py
├── results/
│   ├── raw_stats/
│   └── plots/
├── README.md

Building and Running
Prerequisites

gem5 (tested with develop branch)

Python 3.x

GCC for benchmark compilation

Build gem5
scons build/X86/gem5.opt -j$(nproc)

Running a Benchmark
build/X86/gem5.opt configs/custom_cache_configs.py \
    --prefetcher=ml \
    --benchmark=gemm_blocked

Training and Freezing

Training is enabled by default

Freeze learning by setting:

learning rate = 0

exploration rate = 0

Q-tables can be saved and reused across runs

Evaluation Metrics

We report and analyze:

IPC

Prefetch accuracy and coverage

Useful vs. unused prefetches

MSHR hits and late prefetches

Cache pollution effects

Results show that while the ML controller does not always outperform the single best static prefetcher, it consistently avoids worst-case behavior and provides robust, adaptive performance across workloads and cache configurations.

Key Findings

Static prefetchers often dominate on workloads well-matched to their heuristics

The ML controller excels at robustness, rarely being the worst option

Exploration and delayed reward effects limit peak performance

Cache size and MSHR pressure strongly influence learning effectiveness

Online learning is viable but requires richer state and reward modeling

Limitations

Evaluation confined to gem5 simulation

Limited state representation

Reward does not explicitly model MLP or contention

No phase detection or hierarchical decision-making

These limitations are discussed in detail in the accompanying report.

Future Work

MSHR-aware and concurrency-sensitive reward shaping

Phase detection and temporal context

Cooperative multi-prefetcher blending

Hardware cost and feasibility modeling

Extension to cache replacement and coherence-aware control

Related Work

This project is inspired by prior work on adaptive and ML-based prefetching, including contextual bandit approaches and dynamic prefetch reconfiguration. See the report for a detailed discussion of related work and references.

Team

M Sadman Sakib
Design of RL controller, reward formulation, gem5 implementation, testing and tuning

Munasib Ilham
Benchmark setup, configuration scripts, simulation runs, baseline evaluation, and result visualization

Both authors collaborated on debugging, analysis, and interpretation of results.

License

This project is provided for academic and research use only. Also acknowledging use of open source gem5 simulator developed by the community.
See LICENSE for details.
