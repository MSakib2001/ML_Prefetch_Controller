#include "common.hpp"

int main() {
  static double X[N], Y[N];
  const double alpha = 0.5;

  // init outside ROI
  fill_uniform<double>(X, Y, N, /*seed=*/1);

  // ROI: kernel only
  ROI_BEGIN();
  for (int i = 0; i < N; ++i) {
    Y[i] = alpha * X[i] + Y[i];
  }
  ROI_END();

  // Post-ROI checksum (like HW2)
  double sum = 0.0;
  for (int i = 0; i < N; ++i) sum += Y[i];
  std::printf("%lf\n", sum);
  return 0;
}
