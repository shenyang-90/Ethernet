# dc_synth.mk - Synopsys Design Compiler 综合集成
#
# 集成到主Makefile: include dc_synth.mk
# Author: AI Yang
# Version: v3.0

DC ?= dc_shell
DC_FLAGS = -no_gui -f $(SYNTH_DIR)/scripts/synth.tcl | tee $(SYNTH_DIR)/dc.log

# --- 脚本生成 ---
synth-script:
	@echo "=== Generate DC Script ==="
	mkdir -p $(SYNTH_DIR)/scripts $(SYNTH_DIR)/reports $(SYNTH_DIR)/netlist
	@echo "# DC Synthesis Script" > $(SYNTH_DIR)/scripts/synth.tcl
	@echo "set target_library $(TECH_LIB)" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "set link_library \"* $(TECH_LIB)\"" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "read_verilog $(RTL_DIR)/*.v" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "read_verilog $(RTL_DIR)/*.sv" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "link_design $(RTL_TOP)" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "source $(CONSTRAINTS)" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "compile -map_effort medium" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "compile -incremental -map_effort high" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "write -format verilog -hierarchy -output $(SYNTH_DIR)/netlist/$(RTL_TOP)_synth.v" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "write -format ddc -hierarchy -output $(SYNTH_DIR)/netlist/$(RTL_TOP)_synth.ddc" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "report_qor > $(SYNTH_DIR)/reports/qor.rpt" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "report_timing -max_paths 10 > $(SYNTH_DIR)/reports/timing.rpt" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "report_area > $(SYNTH_DIR)/reports/area.rpt" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "report_power > $(SYNTH_DIR)/reports/power.rpt" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "report_constraints -all_violators > $(SYNTH_DIR)/reports/violations.rpt" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "exit" >> $(SYNTH_DIR)/scripts/synth.tcl
	@echo "Script: $(SYNTH_DIR)/scripts/synth.tcl"

# --- 综合 ---
synth: synth-script
	@echo "=== DC Synthesis: $(RTL_TOP) ==="
	mkdir -p $(SYNTH_DIR)
	$(DC) $(DC_FLAGS)
	@echo "Synthesis complete"
	@echo "Netlist: $(SYNTH_DIR)/netlist/$(RTL_TOP)_synth.v"

# --- 网表检查 ---
netlist-check:
	@echo "=== Netlist Check ==="
	@python3 -c "import re; netlist = open('$(SYNTH_DIR)/netlist/$(RTL_TOP)_synth.v').read(); latches = len(re.findall(r'\\b(LATCH|LD|latch)\\b', netlist, re.I)); print(f'Latch count: {latches}')" 2>/dev/null || echo "No netlist found"

# --- 报告 ---
area-report:
	@cat $(SYNTH_DIR)/reports/area.rpt 2>/dev/null || echo "No area report"

power-report:
	@cat $(SYNTH_DIR)/reports/power.rpt 2>/dev/null || echo "No power report"

timing-report:
	@cat $(SYNTH_DIR)/reports/timing.rpt 2>/dev/null || echo "No timing report"

# --- 质量检查 ---
quality-check:
	@echo "=== Quality Check ==="
	@python3 -c "import re; timing = open('$(SYNTH_DIR)/reports/timing.rpt').read(); violations = len(re.findall(r'VIOLATED', timing)); print(f'Timing violations: {violations}')" 2>/dev/null || echo "No timing report"

# 快捷别名
synth_opt: synth quality-check
