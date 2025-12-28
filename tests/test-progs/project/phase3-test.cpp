#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <vector>
#include <chrono>

// ------------------------------
//  FAST RL TEST PARAMETERS
// ------------------------------
static const int N = 32 * 1024;      // 128 KB array (good L1/L2 stress)
static const int OPS = 50000;        // 50K accesses per phase (FAST)
static const int PRINT_INTERVAL = 4; // Print IPC/miss signature every 4 phases

volatile int sink = 0;

// ------------------------------
//  UTILITY: Read cycle counter
// ------------------------------
inline uint64_t rdtsc() {
    unsigned hi, lo;
    asm volatile("rdtsc" : "=a"(lo), "=d"(hi));
    return ((uint64_t)hi << 32) | lo;
}

// ------------------------------
//  ACCESS PATTERNS
// ------------------------------
void seq_phase(int *a) {
    for (int i = 0; i < OPS; i++)
        sink += a[i % N];
}

void rand_phase(int *a) {
    for (int i = 0; i < OPS; i++)
        sink += a[rand() % N];
}

void stride_phase(int *a) {
    for (int i = 0; i < OPS; i++)
        sink += a[(i * 8) % N];   // stride-8 → predictable but harder
}

void pointer_phase(int *a, int *next) {
    int p = 0;
    for (int i = 0; i < OPS; i++) {
        p = next[p];
        sink += a[p];
    }
}

// ------------------------------
//   MAIN
// ------------------------------
int main() {
    printf("=== FAST RL PREFETCH TEST ===\n");

    int *arr  = (int*) malloc(sizeof(int) * N);
    int *next = (int*) malloc(sizeof(int) * N);

    for (int i = 0; i < N; i++) {
        arr[i] = i * 3;
        next[i] = (i * 13 + 7) % N;  // weird pointer permutation
    }

    uint64_t start, end;

    // Run several short rounds
    for (int round = 0; round < 20; round++) {
        if (round % PRINT_INTERVAL == 0)
            printf("\n--- ROUND %d ---\n", round);

        // SEQUENTIAL
        start = rdtsc();
        seq_phase(arr);
        end = rdtsc();
        if (round % PRINT_INTERVAL == 0)
            printf("[SEQ] cycles=%lu\n", end - start);

        // RANDOM
        start = rdtsc();
        rand_phase(arr);
        end = rdtsc();
        if (round % PRINT_INTERVAL == 0)
            printf("[RAND] cycles=%lu\n", end - start);

        // STRIDE
        start = rdtsc();
        stride_phase(arr);
        end = rdtsc();
        if (round % PRINT_INTERVAL == 0)
            printf("[STRIDE] cycles=%lu\n", end - start);

        // POINTER CHASE
        start = rdtsc();
        pointer_phase(arr, next);
        end = rdtsc();
        if (round % PRINT_INTERVAL == 0)
            printf("[PCHASE] cycles=%lu\n", end - start);
    }

    printf("\nDONE. sink=%d\n", sink);
    return 0;
}
