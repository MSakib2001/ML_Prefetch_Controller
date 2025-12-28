#pragma once
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <random>

extern "C" {
  #include <gem5/m5ops.h>
}

// ----- Problem size -----
static constexpr int N = 4096;

// ----- ROI macros: dump exactly once for the kernel -----
// Begin: reset counters (no print)
// End:   dump kernel stats, then reset counters again so the
//        final auto-dump at program end is ~zero and easy to ignore.
#define ROI_BEGIN()           m5_reset_stats(0,0)
#define ROI_END()             do { m5_dump_stats(0,0); m5_reset_stats(0,0); } while(0)

// ----- Initializers (outside ROI) -----

// Float/double uniform [1,2)
template <typename T>
inline void fill_uniform(T* X, T* Y, int n, uint32_t seed=1, double lo=1.0, double hi=2.0) {
  std::mt19937 gen(seed);
  std::uniform_real_distribution<double> dis(lo, hi);
  for (int i = 0; i < n; ++i) {
    X[i] = static_cast<T>(dis(gen));
    Y[i] = static_cast<T>(dis(gen));
  }
}

// Integers using rand(); small range to avoid overflow with alpha=2
inline void fill_rand_int(int32_t* X, int32_t* Y, int n, unsigned seed=1, int range=1024) {
  std::srand(seed);
  for (int i = 0; i < n; ++i) {
    X[i] = std::rand() % range;
    Y[i] = std::rand() % range;
  }
}
