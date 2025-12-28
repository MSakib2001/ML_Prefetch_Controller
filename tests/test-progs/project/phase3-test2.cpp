#include <cstdio>
#include <cstdlib>

static const int N = 200000;
static const int STRIDE = 16;   // Try 4, 8, 16, 32

int main() {
    int *A = (int*)malloc(sizeof(int) * N);

    for (int i = 0; i < N; i++)
        A[i] = i;

    long long sum = 0;

    // Strided access pattern
    for (int i = 0; i < N; i += STRIDE)
        sum += A[i];

    printf("SUM = %lld\n", sum);
    free(A);
    return 0;
}
