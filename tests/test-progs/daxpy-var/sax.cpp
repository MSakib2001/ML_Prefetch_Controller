#include "common.hpp"

int main() {
  static float X[N], Y[N];
  const float alpha = 0.5f;

  fill_uniform<float>(X, Y, N, /*seed=*/1);

  ROI_BEGIN();
  for (int i = 0; i < N; ++i) {
    Y[i] = alpha * X[i];
  }
  ROI_END();

  double sum = 0.0;
  for (int i = 0; i < N; ++i) sum += Y[i];
  std::printf("%lf\n", sum);
  return 0;
}
