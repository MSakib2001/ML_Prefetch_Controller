#include <cstdio>
#include <random>



#if defined(ENABLE_M5OPS)
  #include "gem5/m5ops.h"
  #define ROI_BEGIN() m5_dump_reset_stats(0,0)
  #define ROI_END()   m5_dump_reset_stats(0,0)
#else
  #define ROI_BEGIN() do{}while(0)
  #define ROI_END()   do{}while(0)
#endif


int main()
{
  const int N = 4096;
  double X[N], Y[N], alpha = 0.5;
  std::random_device rd; std::mt19937 gen(rd());
  std::uniform_real_distribution<> dis(1, 2);
  for (int i = 0; i < N; ++i)
  {
	X[i] = dis(gen);
	Y[i] = dis(gen);
  }
  
  ROI_BEGIN();            // ROI begin

  // Start of daxpy loop
  for (int i = 0; i < N; ++i)
  {
	Y[i] = alpha * X[i] + Y[i];
  }
  // End of daxpy loop
  
  ROI_END();           // ROI end

  double sum = 0;
  for (int i = 0; i < N; ++i)
  {
	sum += Y[i];
  }
  printf("%lf\n", sum);
  return 0;
}