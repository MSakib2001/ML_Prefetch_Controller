#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>

#define N 20000
#define REPS 12   // keep runtime reasonable in gem5

uint64_t *stride_arr;
uint64_t *ptr_arr;

static void shuffle(uint64_t *a, size_t n)
{
    for (size_t i = n - 1; i > 0; i--) {
        size_t j = rand() % (i + 1);
        uint64_t tmp = a[i];
        a[i] = a[j];
        a[j] = tmp;
    }
}

int main()
{
    srand(1);

    // Separate arrays to avoid cross-phase locality
    stride_arr = aligned_alloc(64, N * sizeof(uint64_t));
    ptr_arr    = aligned_alloc(64, N * sizeof(uint64_t));

    if (!stride_arr || !ptr_arr) {
        perror("alloc");
        return 1;
    }

    // -------- Phase 1 setup: clean stride pattern --------
    for (uint64_t i = 0; i < N; i++)
        stride_arr[i] = i;

    // -------- Phase 2 setup: random pointer cycle --------
    uint64_t *perm = malloc(N * sizeof(uint64_t));
    for (uint64_t i = 0; i < N; i++)
        perm[i] = i;

    shuffle(perm, N);

    for (uint64_t i = 0; i < N - 1; i++)
        ptr_arr[perm[i]] = perm[i + 1];
    ptr_arr[perm[N - 1]] = perm[0];   // close the cycle

    free(perm);

    volatile uint64_t sum = 0;

    for (int r = 0; r < REPS; r++) {

        // ==========================
        // Phase 1: Stride-friendly
        // ==========================
        for (uint64_t i = 0; i < N; i += 8)
            sum += stride_arr[i];

        // ==========================
        // Phase 2: Prefetch-hostile
        // ==========================
        uint64_t idx = r % N;
        for (uint64_t i = 0; i < N; i++)
            idx = ptr_arr[idx];

        sum += idx;
    }

    printf("%lu\n", sum);
    return 0;
}
