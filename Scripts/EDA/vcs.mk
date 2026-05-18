# vcs.mk - Synopsys VCS 仿真集成
#
# 集成到主Makefile: include vcs.mk
# Author: AI Yang
# Version: v3.0

VCS ?= vcs
UVM_HOME ?= /tools/synopsys/uvm-1.2
DVE ?= dve
VERDI ?= verdi

VCS_FLAGS = -full64 -sverilog -debug_access+all -kdb -timescale=1ns/1ps +v2k +acc+rn -CFLAGS "-DVCS" -l $(SIM_DIR)/vcs_compile.log

ifdef USE_UVM
VCS_FLAGS += -ntb_opts uvm-1.2 +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv
endif

VCS_COV_FLAGS = -cm line+cond+fsm+tgl+branch+assert -cm_dir $(SIM_DIR)/coverage.vdb -cm_hier $(SIM_DIR)/coverage.cfg

# --- Lint ---
lint-vcs:
	@echo "=== VCS Compile Check: $(RTL_TOP) ==="
	mkdir -p $(SIM_DIR)
	$(VCS) $(VCS_FLAGS) \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		$(TB_DIR)/*.v $(TB_DIR)/*.sv \
		-top $(RTL_TOP) \
		-o $(SIM_DIR)/simv \
		2>&1 | tee $(SIM_DIR)/lint_vcs.log
	@echo "Compile check complete"

# --- Simulation ---
sim-compile-vcs:
	@echo "=== VCS Compile: $(RTL_TOP) ==="
	mkdir -p $(SIM_DIR)
	$(VCS) $(VCS_FLAGS) \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		$(TB_DIR)/*.v $(TB_DIR)/*.sv \
		-top $(RTL_TOP) \
		-o $(SIM_DIR)/simv \
		-l $(SIM_DIR)/vcs_compile.log
	@echo "Compile complete"

sim-run-vcs:
	@echo "=== VCS Run: $(RTL_TOP) ==="
	cd $(SIM_DIR) && ./simv \
		+UVM_VERBOSITY=UVM_MEDIUM \
		+ntb_random_seed=$(SEED) \
		2>&1 | tee $(SIM_DIR)/sim_$(RTL_TOP).log
	@echo "Simulation complete"

sim-vcs: sim-compile-vcs sim-run-vcs
	@echo "VCS simulation complete"

# --- GUI ---
sim-gui:
	@echo "=== VCS GUI ==="
	mkdir -p $(SIM_DIR)
	$(VCS) $(VCS_FLAGS) -debug_access+all -kdb -R \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		$(TB_DIR)/*.v $(TB_DIR)/*.sv \
		-top $(RTL_TOP) \
		-o $(SIM_DIR)/simv \
		+UVM_VERBOSITY=UVM_LOW \
		2>&1 | tee $(SIM_DIR)/sim_gui.log

# --- Coverage ---
coverage-vcs-compile:
	@echo "=== VCS Coverage Compile ==="
	mkdir -p $(SIM_DIR)
	$(VCS) $(VCS_FLAGS) $(VCS_COV_FLAGS) \
		$(RTL_DIR)/*.v $(RTL_DIR)/*.sv \
		$(TB_DIR)/*.v $(TB_DIR)/*.sv \
		-top $(RTL_TOP) \
		-o $(SIM_DIR)/simv_cov \
		-l $(SIM_DIR)/vcs_cov_compile.log

coverage-vcs-run:
	@echo "=== VCS Coverage Run ==="
	cd $(SIM_DIR) && ./simv_cov \
		+UVM_VERBOSITY=UVM_LOW \
		+ntb_random_seed=$(SEED) \
		2>&1 | tee $(SIM_DIR)/coverage_run.log

coverage-vcs-report:
	@echo "=== VCS Coverage Report ==="
	urg -dir $(SIM_DIR)/coverage.vdb -format both -report $(SIM_DIR)/coverage_report -metrics line+cond+fsm+tgl+branch+assert
	@echo "Coverage report: $(SIM_DIR)/coverage_report"

coverage: coverage-vcs-compile coverage-vcs-run coverage-vcs-report
	@echo "VCS coverage collection complete"

# --- Regression ---
REGRESSION_SEEDS ?= 42 123 456 789 2024
regression-vcs:
	@echo "=== VCS Regression ==="
	@for seed in $(REGRESSION_SEEDS); do \
		echo "Running seed=$$seed..."; \
		cd $(SIM_DIR) && ./simv +ntb_random_seed=$$seed 2>&1 | tee $(SIM_DIR)/regression_seed_$$seed.log; \
	done
	@echo "Regression complete"

# --- View ---
view:
	@echo "=== Open DVE ==="
	$(DVE) -full64 -vpd $(SIM_DIR)/dump.vpd &

view-verdi:
	@echo "=== Open Verdi ==="
	$(VERDI) -ssf $(SIM_DIR)/dump.fsdb &

# 快捷别名
lint: lint-vcs
sim: sim-vcs
regression: regression-vcs
