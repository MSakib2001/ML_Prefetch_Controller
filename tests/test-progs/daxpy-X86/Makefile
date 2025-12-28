# --- Paths to gem5 headers/libs ---
GEM5 ?= $(GEM5_ROOT)
M5_INC := -I$(GEM5)/include
M5_LIB := $(GEM5)/util/m5/build/x86/out/libm5.a

# --- Build settings---
CXX := g++
OPT := -O3 -std=gnu++20

LDFLAGS := -static-libgcc -static-libstdc++
LDLIBS  :=

# ROI toggle: 0 = no ROI (Problem 1), 1 = ROI (Problems 2–4)
ROI ?= 0
ifeq ($(ROI),1)
  CXXFLAGS_EXTRA := -DENABLE_M5OPS $(M5_INC)
  LDLIBS += $(M5_LIB)
else
  CXXFLAGS_EXTRA :=
endif

# --- Targets ---
all: daxpy

daxpy: daxpy.cpp
	$(CXX) $(OPT) $(CXXFLAGS_EXTRA) -o $@ $< $(LDFLAGS) $(LDLIBS)

# Generate assembly for the current ROI setting 
asm:
	$(CXX) -S $(OPT) $(CXXFLAGS_EXTRA) -fverbose-asm -o daxpy.s daxpy.cpp

clean:
	rm -f daxpy daxpy.s