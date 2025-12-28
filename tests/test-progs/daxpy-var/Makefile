GEM5_DIR ?= /home/sakib/ECE752/gem5
M5_INC   := $(GEM5_DIR)/include
M5_LIB   := $(GEM5_DIR)/util/m5/build/arm64/out/libm5.a

CXX := aarch64-linux-gnu-g++
CXXFLAGS := -O3 -static -std=c++17 -I$(M5_INC)

APPS := daxpy dax iaxpy iax saxpy sax

all: $(APPS:%=bin/%)

bin/%: %.cpp | bin
	$(CXX) $(CXXFLAGS) -o $@ $< $(M5_LIB)   # lib LAST is important

bin:
	mkdir -p bin

clean:
	rm -rf bin
