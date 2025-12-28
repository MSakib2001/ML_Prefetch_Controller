#include <stdlib.h>
#include <stdio.h>
#define N (1 << 18)
#define STRIDE1 64
#define STRIDE2 128

int arr[N];

int main() {
    volatile int sum = 0;

    for (int r = 0; r < 30; r++) {
        // Phase A
        for (int i = 0; i < N; i += STRIDE1)
            sum += arr[i];

        // Phase B
        for (int i = 0; i < N; i += STRIDE2)
            sum += arr[i];
    }

    printf("%d\n", sum);
}
