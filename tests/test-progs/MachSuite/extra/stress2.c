#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

#ifndef PHASE1_REPEATS
#define PHASE1_REPEATS  8    // streaming passes
#endif

#ifndef PHASE2_REPEATS
#define PHASE2_REPEATS  8    // pointer-chase passes
#endif

// Size of each phase’s working set (in ints).
// 65536 ints = 256 KB, which is exactly your L2 size.
#define N1   (64 * 1024)   // Phase 1 array length
#define N2   (64 * 1024)   // Phase 2 array length

static int phase1_array[N1];
static int phase2_array[N2];

// Pointer-chase: index -> next index in a random permutation.
static int phase2_next[N2];

// To prevent the compiler from optimizing everything away.
volatile int global_sink = 0;

/**
 * Simple Fisher–Yates shuffle to create a random permutation
 * over [0, N2).
 */
static void
init_pointer_chase_pattern(unsigned seed)
{
    for (int i = 0; i < N2; i++) {
        phase2_next[i] = i;
    }

    srand(seed);
    for (int i = N2 - 1; i > 0; i--) {
        int j = rand() % (i + 1);
        int tmp = phase2_next[i];
        phase2_next[i] = phase2_next[j];
        phase2_next[j] = tmp;
    }

    // Now phase2_next[] is a permutation, but not yet a cycle.
    // Make it a single cycle so we chase through all elements.
    // next[idx_k] = idx_{k+1}, last points to first.
    int visited[N2] = {0};
    int prev = -1;
    int first = -1;
    for (int i = 0; i < N2; i++) {
        int idx = phase2_next[i];
        if (!visited[idx]) {
            visited[idx] = 1;
            if (first < 0) first = idx;
            if (prev >= 0) phase2_next[prev] = idx;
            prev = idx;
        }
    }
    if (prev >= 0 && first >= 0) {
        phase2_next[prev] = first;
    }
}

/**
 * Phase 1: regular streaming with stride-1 accesses.
 * This should strongly favor stride prefetchers (especially
 * your Stride(4,2) child) with high coverage and good IPC.
 */
static int
run_phase1(void)
{
    int sum = 0;

    // Initialize the array in a simple way
    for (int i = 0; i < N1; i++) {
        phase1_array[i] = i & 0xFF;
    }

    for (int rep = 0; rep < PHASE1_REPEATS; rep++) {
        // Perfectly sequential forward walk
        for (int i = 0; i < N1; i++) {
            sum += phase1_array[i];
        }
    }

    return sum;
}

/**
 * Phase 2: dependent pointer-chasing over a random permutation.
 * This is hostile to *all* your prefetchers:
 *  - Stride(1,1) and Stride(4,2) see no stride pattern.
 *  - Tagged prefetcher gets very noisy/low-value correlations.
 *  - Turning prefetch OFF is often best.
 */
static int
run_phase2(void)
{
    int sum = 0;

    // Initialize the array to some values.
    for (int i = 0; i < N2; i++) {
        phase2_array[i] = (i * 7) & 0xFF;
    }

    // Build a random pointer-chase cycle over phase2_next.
    init_pointer_chase_pattern(12345);

    int idx = 0;
    // Each pass walks through the entire permutation once.
    // Total loads = N2 * PHASE2_REPEATS.
    for (int rep = 0; rep < PHASE2_REPEATS; rep++) {
        for (int k = 0; k < N2; k++) {
            sum += phase2_array[idx];
            idx = phase2_next[idx];  // data-dependent → hard to prefetch
        }
    }

    return sum;
}

int
main(int argc, char **argv)
{
    (void)argc; (void)argv;  // unused

    int total = 0;

    // Phase 1: stride-friendly
    total += run_phase1();

    // Phase 2: pointer-chasing (prefetch-unfriendly)
    total += run_phase2();

    // Keep the compiler from removing everything.
    global_sink = total;

    // Optional: print something so you can sanity-check runs.
    printf("Done. Total = %d\n", total);
    return 0;
}
