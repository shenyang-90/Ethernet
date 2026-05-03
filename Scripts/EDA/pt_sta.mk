# pt_sta.mk - Synopsys PrimeTime STA 集成
#
# 集成到主Makefile: include pt_sta.mk
# Author: AI Yang
# Version: v3.0

PT ?= pt_shell

# --- 脚本生成 ---
sta-script:
	@echo "=== Generate PrimeTime Script ==="
	mkdir -p $(STA_DIR)/scripts $(STA_DIR)/reports
	@echo "# PrimeTime STA Script" > $(STA_DIR)/scripts/sta.tcl
	@echo "set target_library $(TECH_LIB)" >> $(STA_DIR)/scripts/sta.tcl
	@echo "set link_path \"* $(TECH_LIB)\"" >> $(STA_DIR)/scripts/sta.tcl
	@echo "read_verilog $(SYNTH_DIR)/netlist/$(RTL_TOP)_synth.v" >> $(STA_DIR)/scripts/sta.tcl
	@echo "link_design $(RTL_TOP)" >> $(STA_DIR)/scripts/sta.tcl
	@echo "source $(CONSTRAINTS)" >> $(STA_DIR)/scripts/sta.tcl
	@echo "set_propagated_clock [all_clocks]" >> $(STA_DIR)/scripts/sta.tcl
	@echo "update_timing -full" >> $(STA_DIR)/scripts/sta.tcl
	@echo "report_timing -delay_type max -max_paths 20 -nworst 2 > $(STA_DIR)/reports/setup.rpt" >> $(STA_DIR)/scripts/sta.tcl
	@echo "report_timing -delay_type min -max_paths 20 -nworst 2 > $(STA_DIR)/reports/hold.rpt" >> $(STA_DIR)/scripts/sta.tcl
	@echo "report_constraint -all_violators > $(STA_DIR)/reports/all_violations.rpt" >> $(STA_DIR)/scripts/sta.tcl
	@echo "report_clock_timing -type summary > $(STA_DIR)/reports/clock_summary.rpt" >> $(STA_DIR)/scripts/sta.tcl
	@echo "report_analysis_coverage > $(STA_DIR)/reports/coverage.rpt" >> $(STA_DIR)/scripts/sta.tcl
	@echo "exit" >> $(STA_DIR)/scripts/sta.tcl
	@echo "Script: $(STA_DIR)/scripts/sta.tcl"

# --- STA ---
sta: sta-script
	@echo "=== PrimeTime STA: $(RTL_TOP) ==="
	$(PT) -no_gui -f $(STA_DIR)/scripts/sta.tcl | tee $(STA_DIR)/pt.log
	@echo "STA complete"

# --- 报告 ---
sta-setup:
	@cat $(STA_DIR)/reports/setup.rpt 2>/dev/null || echo "No setup report"

sta-hold:
	@cat $(STA_DIR)/reports/hold.rpt 2>/dev/null || echo "No hold report"

sta-all: sta sta-report
	@echo "STA analysis complete"

# --- 报告解析 ---
sta-report:
	@echo "=== STA Summary ==="
	@python3 -c "import re; setup = open('$(STA_DIR)/reports/setup.rpt').read(); violations = len(re.findall(r'VIOLATED', setup)); print(f'Setup violations: {violations}')" 2>/dev/null || echo "No setup report"
	@python3 -c "import re; hold = open('$(STA_DIR)/reports/hold.rpt').read(); violations = len(re.findall(r'VIOLATED', hold)); print(f'Hold violations: {violations}')" 2>/dev/null || echo "No hold report"

# --- 时钟检查 ---
sta-clock:
	@echo "=== Clock Quality ==="
	@python3 -c "import re; clock = open('$(STA_DIR)/reports/clock_summary.rpt').read(); skew = re.search(r'skew\s+([\d.]+)', clock, re.I); print(f'Skew: {skew.group(1)} ns' if skew else 'No skew data')" 2>/dev/null || echo "No clock report"

# 快捷别名
sta: sta-all
