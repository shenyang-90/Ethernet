# Makefile for Ethernet IP SystemC/TLM 2.0 Unit Tests
# SystemC 2.3.3 + TLM 2.0 (pthreads)

SYSTEMC_HOME ?= /home/CALTERAH/yshen/tools/systemc-2.3.3-pthreads
SYSTEMC_INC  := $(SYSTEMC_HOME)/include
SYSTEMC_LIB  := $(SYSTEMC_HOME)/lib-linux64

CXX      := g++
CXXFLAGS := -std=c++17 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable -Wno-unused-but-set-variable -O2 -g
INCLUDES := -I$(SYSTEMC_INC) -I./models -I./tests -I./utils
LDFLAGS  := -L$(SYSTEMC_LIB) -Wl,-rpath,$(SYSTEMC_LIB)
LIBS     := -lsystemc -lpthread

# 构建目录（所有编译产物输出到此）
BUILD_DIR := build

# 单元测试
UNIT_SRCS := \
    tests/test_switch_core.cc \
    tests/test_phc.cc \
    tests/test_mac.cc \
    tests/test_dma.cc \
    tests/test_vphc.cc \
    tests/test_traffic_gen.cc

UNIT_BINS := $(UNIT_SRCS:tests/%.cc=%)
UNIT_TARGETS := $(addprefix $(BUILD_DIR)/,$(UNIT_BINS))

# 集成测试
INTEG_SRCS := \
    tests/test_mac_to_switch.cc \
    tests/test_dma_to_switch.cc \
    tests/test_phc_to_mac.cc

INTEG_BINS := $(INTEG_SRCS:tests/%.cc=%)
INTEG_TARGETS := $(addprefix $(BUILD_DIR)/,$(INTEG_BINS))

# 系统测试
SYS_SRCS := \
    tests/throughput_test.cc \
    tests/latency_test.cc \
    tests/sc02_tsn_test.cc \
    tests/sc04_vphc_test.cc \
    tests/sc05_error_test.cc \
    tests/sc01_linerate_simple.cc \
    tests/sc02_tsn_simple.cc \
    tests/sc03_concurrent_simple.cc \
    tests/sc04_vphc_simple.cc \
    tests/sc05_error_simple.cc

SYS_BINS := $(SYS_SRCS:tests/%.cc=%)
SYS_TARGETS := $(addprefix $(BUILD_DIR)/,$(SYS_BINS))

.PHONY: all unit integ sys clean help test-compile $(UNIT_BINS) $(INTEG_BINS) $(SYS_BINS)

all: unit integ sys

unit: $(UNIT_TARGETS)

integ: $(INTEG_TARGETS)

sys: $(SYS_TARGETS)

# 便捷别名：允许 make throughput_test 等
# 使用 eval 生成显式规则
$(foreach bin,$(UNIT_BINS) $(INTEG_BINS) $(SYS_BINS),$(eval $(bin): $(BUILD_DIR)/$(bin)))

# 创建构建目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# 编译规则：.o 放到 build/
$(BUILD_DIR)/%.o: tests/%.cc | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

# 链接规则：输出到 build/
$(BUILD_DIR)/%: $(BUILD_DIR)/%.o
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(LDFLAGS) -o $@ $^ $(LIBS)

# 仅编译检查
test-compile:
	@for src in $(UNIT_SRCS) $(INTEG_SRCS) $(SYS_SRCS); do \
		echo "Checking $$src..."; \
		$(CXX) $(CXXFLAGS) $(INCLUDES) -fsyntax-only $$src || exit 1; \
	done
	@echo "All syntax checks passed"

# 运行单元测试
run-unit: unit
	@for t in $(UNIT_TARGETS); do \
		echo "\n>>> Running $$(basename $$t) <<<"; \
		./$$t || true; \
	done

# 运行集成测试
run-integ: integ
	@for t in $(INTEG_TARGETS); do \
		echo "\n>>> Running $$(basename $$t) <<<"; \
		./$$t || true; \
	done

# 运行系统测试
run-sys: sys
	@for t in $(SYS_TARGETS); do \
		echo "\n>>> Running $$(basename $$t) <<<"; \
		timeout 30 ./$$t || true; \
	done

# 运行所有测试
run-all: all
	@for t in $(UNIT_TARGETS) $(INTEG_TARGETS) $(SYS_TARGETS); do \
		echo "\n>>> Running $$(basename $$t) <<<"; \
		timeout 30 ./$$t || true; \
	done

clean:
	rm -rf $(BUILD_DIR) tmp/

help:
	@echo "Targets:"
	@echo "  all          - Build all tests (output to build/)"
	@echo "  unit         - Build unit tests only"
	@echo "  integ        - Build integration tests only"
	@echo "  sys          - Build system tests only"
	@echo "  run-unit     - Run unit tests"
	@echo "  run-integ    - Run integration tests"
	@echo "  run-sys      - Run system tests"
	@echo "  run-all      - Run all tests"
	@echo "  test-compile - Syntax check only"
	@echo "  clean        - Remove build/ and tmp/"
	@echo "  help         - Show this help"
	@echo ""
	@echo "Directory structure:"
	@echo "  build/                        - Compiled executables (ELF)"
	@echo "  tmp/<case_name>/waveform.vcd    - VCD waveform"
	@echo "  tmp/<case_name>/simulation.log  - Simulation log"
	@echo "  tmp/<case_name>/metrics.csv     - Metrics CSV"
	@echo "  tmp/<case_name>/metrics.json    - Metrics JSON"
	@echo "  tmp/<case_name>/frame_trace.csv - Frame trace"
