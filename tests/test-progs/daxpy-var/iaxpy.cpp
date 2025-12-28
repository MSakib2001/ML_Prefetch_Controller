#include "common.hpp"

int main() {
  static int32_t X[N], Y[N];
  const int32_t alpha = 2;

  fill_rand_int(X, Y, N, /*seed=*/1, /*range=*/1024);

  ROI_BEGIN();
  for (int i = 0; i < N; ++i) {
    Y[i] = alpha * X[i] + Y[i];
  }
  ROI_END();

  long long sum = 0;
  for (int i = 0; i < N; ++i) sum += (long long)Y[i];
  std::printf("%lld\n", sum);
  return 0;
}
