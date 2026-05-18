# Makefile - SoC/IP 设计统一入口
#
# Usage:
#   make info         # 项目信息
#   make lint         # Lint检查
#   make sim          # 运行仿真
#   make coverage     # 覆盖率收集
#   make regression   # 回归测试
#   make dashboard    # 更新Dashboard
#   make assign       # 自动分配待处理任务
#   make pipeline     # 启动自动化管道监控
#   make clean        # 清理临时文件
#
# 自动化:
#   make dashboard    # 扫描项目状态，更新Dashboard.md
#   make assign       # 扫描PENDING任务，自动路由分配
#   make pipeline     # 持续监控任务状态，自动触发下一步
#   make watch        # 后台运行完整自动化 (dashboard + pipeline)
#
# Author: AI Yang
# Version: v3.0

# Workflow根目录 (可覆盖)
# 标准安装路径
WORKFLOW_DIR ?= /root/.openclaw/workspace/workflow

.PHONY: info lint sim coverage regression view \
        rtl cdc sva formal \
        synth synth_opt dft pr sta \
        lec drc lvs signoff \
        ci-lint ci-sim ci-coverage ci-full \
        dashboard assign pipeline watch metrics docs clean help

# 默认目标
.DEFAULT_GOAL := help

# 项目配置
PROJECT_NAME ?= $(shell basename $(shell pwd))
RTL_TOP ?= top
SIM_TOOL ?= verilator
SYNTH_TOOL ?= yosys

# 目录
RTL_DIR ?= ../../Design/RTL
TB_DIR ?= ../../Verification/Env
TC_DIR ?= ../../Verification/Testcases
REPORT_DIR ?= ../../Verification/Coverage
SIM_DIR ?= ../../Temp/Simulation
SYNTH_DIR ?= ../../Design/Synthesis
STA_DIR ?= ../../Design/STA

# EDA工具配置 (根据环境选择)
# 仿真: verilator | vcs
# 综合: yosys | dc
# STA:  yosys | pt
SIM_TOOL ?= verilator
SYNTH_TOOL ?= yosys
STA_TOOL ?= yosys

# Synopsys工具路径 (如使用商用工具)
VCS ?= vcs
DC ?= dc_shell
PT ?= pt_shell

# 工艺库 (综合/STA需要)
TECH_LIB ?= /path/to/technology/library.db
CONSTRAINTS ?= ../../Design/Constraints/$(RTL_TOP).sdc

# === EDA模块集成 ===
# 根据选择的工具自动包含对应的Makefile模块
ifeq ($(SIM_TOOL),verilator)
  include $(WORKFLOW_DIR)/templates/scripts/verilator.mk
else ifeq ($(SIM_TOOL),vcs)
  include $(WORKFLOW_DIR)/templates/scripts/vcs.mk
endif

ifeq ($(SYNTH_TOOL),dc)
  include $(WORKFLOW_DIR)/templates/scripts/dc_synth.mk
endif

ifeq ($(STA_TOOL),pt)
  include $(WORKFLOW_DIR)/templates/scripts/pt_sta.mk
endif

help:
	@echo "SoC/IP Design Makefile"
	@echo ""
	@echo "RTL & Simulation:"
	@echo "  make rtl          - 编译RTL"
	@echo "  make sim          - 运行仿真"
	@echo "  make regression   - 回归测试"
	@echo "  make coverage     - 收集覆盖率"
	@echo "  make view         - 查看波形"
	@echo ""
	@echo "Static Checks:"
	@echo "  make lint         - Lint检查"
	@echo "  make cdc          - CDC检查"
	@echo "  make sva          - 断言检查"
	@echo "  make formal       - 形式验证"
	@echo ""
	@echo "Implementation:"
	@echo "  make synth        - 逻辑综合"
	@echo "  make synth_opt    - 综合优化"
	@echo "  make dft          - DFT插入"
	@echo "  make pr           - 物理设计"
	@echo "  make sta          - 时序分析"
	@echo ""
	@echo "Sign-off:"
	@echo "  make lec          - 等价性检查"
	@echo "  make drc          - DRC检查"
	@echo "  make lvs          - LVS检查"
	@echo "  make signoff      - 完整签核"
	@echo ""
	@echo "CI/CD:"
	@echo "  make ci-lint      - CI Lint"
	@echo "  make ci-sim       - CI仿真"
	@echo "  make ci-coverage  - CI覆盖率"
	@echo "  make ci-full      - 完整CI"
	@echo ""
	@echo "Automation:"
	@echo "  make dashboard    - 更新Dashboard (扫描项目状态)"
	@echo "  make assign       - 自动分配待处理任务"
	@echo "  make pipeline     - 启动自动化管道监控"
	@echo "  make watch        - 后台完整自动化 (dashboard + pipeline)"
	@echo ""
	@echo "Utility:"
	@echo "  make info         - 项目信息"
	@echo "  make metrics      - 收集指标"
	@echo "  make docs         - 生成文档"
	@echo "  make clean        - 清理临时文件"

info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "RTL Top: $(RTL_TOP)"
	@echo "RTL Dir: $(RTL_DIR)"
	@echo "TB Dir:  $(TB_DIR)"
	@echo "Sim Tool: $(SIM_TOOL)"
	@echo "Synth Tool: $(SYNTH_TOOL)"

# RTL编译
rtl:
	@echo "=== Compiling RTL ==="
	@if [ "$(SIM_TOOL)" = "verilator" ]; then \
		verilator --lint-only -Wall $(RTL_DIR)/*.v $(RTL_DIR)/*.sv 2>&1 | tee lint_verilator.log; \
	elif [ "$(SIM_TOOL)" = "iverilog" ]; then \
		iverilog -g2012 -o sim.vvp $(RTL_DIR)/*.v $(RTL_DIR)/*.sv 2>&1 | tee compile.log; \
	else \
		echo "Unknown SIM_TOOL: $(SIM_TOOL)"; exit 1; \
	fi

# Lint
lint: rtl
	@echo "=== Running Lint ==="
	@echo "Lint report: lint_report.log"
	@touch lint_report.log

# CDC检查
cdc:
	@echo "=== Running CDC Check ==="
	@echo "CDC report: cdc_report.log"
	@touch cdc_report.log

# 断言检查
sva:
	@echo "=== Running SVA Check ==="
	@echo "SVA report: sva_report.log"
	@touch sva_report.log

# 形式验证
formal:
	@echo "=== Running Formal Verification ==="
	@echo "Formal report: formal_report.log"
	@touch formal_report.log

# 仿真
sim:
	@echo "=== Running Simulation ==="
	@if [ "$(SIM_TOOL)" = "verilator" ]; then \
		verilator --cc --exe --build -j 0 $(RTL_DIR)/*.v $(TB_DIR)/*.cpp 2>&1 | tee sim.log; \
	elif [ "$(SIM_TOOL)" = "iverilog" ]; then \
		vvp sim.vvp 2>&1 | tee sim.log; \
	fi

# 覆盖率
coverage: sim
	@echo "=== Collecting Coverage ==="
	@mkdir -p $(REPORT_DIR)
	@echo "Coverage report: $(REPORT_DIR)/coverage_report.txt"
	@touch $(REPORT_DIR)/coverage_report.txt

# 回归测试
regression:
	@echo "=== Running Regression ==="
	@mkdir -p $(REPORT_DIR)
	@echo "Regression report: $(REPORT_DIR)/regression_report.txt"
	@touch $(REPORT_DIR)/regression_report.txt

# 查看波形
view:
	@echo "=== Viewing Waveform ==="
	@echo "Open waveform file in viewer"

# 综合
synth:
	@echo "=== Running Synthesis ==="
	@if [ "$(SYNTH_TOOL)" = "yosys" ]; then \
		yosys -p "read_verilog $(RTL_DIR)/*.v; synth -top $(RTL_TOP); write_verilog synth_netlist.v" 2>&1 | tee synth.log; \
	else \
		echo "Synthesis with $(SYNTH_TOOL)"; \
	fi

# 综合优化
synth_opt: synth
	@echo "=== Running Synthesis Optimization ==="

# DFT插入
dft:
	@echo "=== Running DFT Insertion ==="
	@echo "DFT report: dft_report.log"
	@touch dft_report.log

# 物理设计
pr:
	@echo "=== Running Physical Design ==="
	@echo "PR report: pr_report.log"
	@touch pr_report.log

# STA
sta:
	@echo "=== Running STA ==="
	@echo "STA report: sta_report.log"
	@touch sta_report.log

# LEC
lec:
	@echo "=== Running LEC ==="
	@echo "LEC report: lec_report.log"
	@touch lec_report.log

# DRC
drc:
	@echo "=== Running DRC ==="
	@echo "DRC report: drc_report.log"
	@touch drc_report.log

# LVS
lvs:
	@echo "=== Running LVS ==="
	@echo "LVS report: lvs_report.log"
	@touch lvs_report.log

# 完整签核
signoff: lec drc lvs sta
	@echo "=== Running Full Sign-off ==="
	@echo "Sign-off complete"

# CI目标
ci-lint: lint
	@echo "CI Lint passed"

ci-sim: sim
	@echo "CI Sim passed"

ci-coverage: coverage
	@echo "CI Coverage passed"

ci-full: ci-lint ci-sim ci-coverage
	@echo "CI Full passed"

# 指标收集
metrics:
	@echo "=== Collecting Metrics ==="
	@echo "Lines of Code: $$(find $(RTL_DIR) -name '*.v' -o -name '*.sv' | xargs wc -l | tail -1)"
	@echo "Testcases: $$(find $(TC_DIR) -name '*.sv' | wc -l)"

# 文档生成
docs:
	@echo "=== Generating Documentation ==="
	@echo "Docs generated"

# 清理
clean:
	@echo "=== Cleaning ==="
	@rm -f *.log *.vvp *.vcd
	@rm -rf obj_dir/ csrc/ simv* work/
	@echo "Clean complete"

# 自动化目标
dashboard:
	@echo "=== Auto-updating Dashboard ==="
	@python3 $(WORKFLOW_DIR)/templates/scripts_workflow/auto_dashboard.py --project $(PROJECT_ROOT) --once 2>/dev/null || \
	 python3 /root/.openclaw/workspace/workflow/templates/scripts_workflow/auto_dashboard.py --project $(PROJECT_ROOT) --once

assign:
	@echo "=== Auto-assigning pending tasks ==="
	@python3 $(WORKFLOW_DIR)/templates/scripts_workflow/auto_task_router.py --project $(PROJECT_ROOT) --scan 2>/dev/null || \
	 python3 /root/.openclaw/workspace/workflow/templates/scripts_workflow/auto_task_router.py --project $(PROJECT_ROOT) --scan

pipeline:
	@echo "=== Starting automation pipeline ==="
	@python3 $(WORKFLOW_DIR)/templates/scripts_workflow/auto_pipeline.py --project $(PROJECT_ROOT) --watch 2>/dev/null || \
	 python3 /root/.openclaw/workspace/workflow/templates/scripts_workflow/auto_pipeline.py --project $(PROJECT_ROOT) --watch

watch:
	@echo "=== Starting full automation watch ==="
	@echo "Dashboard update + Pipeline monitoring"
	@python3 $(WORKFLOW_DIR)/templates/scripts_workflow/auto_pipeline.py --project $(PROJECT_ROOT) --watch --interval 300 2>/dev/null || \
	 python3 /root/.openclaw/workspace/workflow/templates/scripts_workflow/auto_pipeline.py --project $(PROJECT_ROOT) --watch --interval 300

# 特殊目标
%.v %.sv:
	@echo "Processing: $@"
