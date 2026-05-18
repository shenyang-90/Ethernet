# Verilator.mk - 开源Lint与仿真集成
# 
# 集成到主Makefile: include verilator.mk
# 提供目标: lint, sim, coverage
#
# Author: AI Yang
# Version: v3.0

VERILATOR ?= verilator
VERILATOR_FLAGS ?= -Wall -Wno-fatal -trace
VERILATOR_OPT_FLAGS ?= -O3 -x-assign fast -x-initial fast -noassert

# --- Lint ---
lint-verilator:
	@echo "=== Verilator Lint: $(RTL_TOP) ==="
	$(VERILATOR) --lint-only $(VERILATOR_FLAGS) \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		2>&1 | tee $(SIM_DIR)/lint_verilator.log
	@echo "Lint report: $(SIM_DIR)/lint_verilator.log"

lint-parse-verilator:
	@python3 -c "import re, sys; log = open('$(SIM_DIR)/lint_verilator.log').read(); errors = len(re.findall(r'%Error', log)); warnings = len(re.findall(r'%Warning', log)); print(f'Verilator Lint: {errors} errors, {warnings} warnings'); sys.exit(1 if errors > 0 else 0)" || echo "Lint has errors!"

# --- Simulation ---
sim-verilator-compile:
	@echo "=== Verilator Compile: $(RTL_TOP) ==="
	mkdir -p $(SIM_DIR)/obj_dir
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_OPT_FLAGS) \
		--cc --exe --build \
		-C $(SIM_DIR)/obj_dir \
		-Mdir $(SIM_DIR)/obj_dir \
		--top-module $(RTL_TOP) \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		$(TB_DIR)/tb_$(RTL_TOP).cpp \
		-o $(SIM_DIR)/sim_$(RTL_TOP)

sim-verilator-run:
	@echo "=== Verilator Run: $(RTL_TOP) ==="
	cd $(SIM_DIR) && ./obj_dir/sim_$(RTL_TOP) \
		+trace 2>&1 | tee $(SIM_DIR)/sim_$(RTL_TOP).log

sim-verilator: sim-verilator-compile sim-verilator-run
	@echo "Verilator simulation complete"

# --- Coverage ---
verilator-coverage:
	@echo "=== Verilator Coverage ==="
	$(VERILATOR) $(VERILATOR_FLAGS) --coverage \
		--cc --exe --build \
		-C $(SIM_DIR)/obj_dir_cov \
		--top-module $(RTL_TOP) \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		$(TB_DIR)/tb_$(RTL_TOP).cpp
	cd $(SIM_DIR)/obj_dir_cov && ./sim_$(RTL_TOP)
	verilator_coverage $(SIM_DIR)/obj_dir_cov/coverage.dat --write-info $(SIM_DIR)/coverage.info
	genhtml $(SIM_DIR)/coverage.info -o $(SIM_DIR)/coverage_html
	@echo "Coverage report: $(SIM_DIR)/coverage_html/index.html"

# 快捷别名
lint: lint-verilator
sim: sim-verilator
