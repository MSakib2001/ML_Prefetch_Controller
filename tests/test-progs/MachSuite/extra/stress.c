#include <stdint.h>
#include <stdlib.h>

#define STREAM_BYTES   (256 * 1024)    // 256 KB
#define RANDOM_BYTES   (1 * 1024 * 1024) // 1 MB random walk
#define ITERS 2                         // small loop count for speed

#define N_STREAM   (STREAM_BYTES / sizeof(double))
#define N_RANDOM   (RANDOM_BYTES / sizeof(double))

static double *stream_arr;
static double *random_arr;
static uint32_t *idx;

static uint32_t lcg(uint32_t x) {
    return 1664525u * x + 1013904223u;
}

int main(void)
{
    stream_arr = malloc(STREAM_BYTES);
    random_arr = malloc(RANDOM_BYTES);
    idx        = malloc(N_RANDOM * sizeof(uint32_t));

    if (!stream_arr || !random_arr || !idx)
        return 1;

    for (size_t i = 0; i < N_STREAM; ++i)
        stream_arr[i] = (double)i;

    for (size_t i = 0; i < N_RANDOM; ++i)
        random_arr[i] = (double)i;

    // Create pseudo-random walk
    uint32_t x = 1;
    for (size_t i = 0; i < N_RANDOM; ++i) {
        x = lcg(x);
        idx[i] = x & (N_RANDOM - 1);   // Faster mod with power of 2 size
    }

    volatile double sink = 0.0;

    for (int iter = 0; iter < ITERS; ++iter)
    {
        // ---- Phase 1: streaming (Tagged good) ----
        for (size_t i = 0; i < N_STREAM; ++i)
            sink += stream_arr[i];

        // ---- Phase 2: random (Tagged very bad) ----
        for (size_t i = 0; i < N_RANDOM; ++i)
            sink += random_arr[idx[i]];
    }

    if (sink == 123.456)
        return 2;

    return 0;
}
