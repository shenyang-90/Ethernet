# ethernet

## 项目信息

- **项目ID**: IP_20260502_001
- **项目名称**: ethernet
- **项目类型**: IP
- **创建日期**: 2026-05-02

## 工作流

本项目遵循 workflow/SOC_WORKFLOW.md。

## 快速命令

```bash
cd Scripts
make info           # 项目信息
make lint           # Lint检查
make sim            # 运行仿真
make coverage       # 覆盖率
make dashboard      # 更新Dashboard
make assign         # 自动分配任务
make pipeline       # 启动自动化管道
make watch          # 后台完整自动化
```

## 目录结构

- ProjectMgmt/: 项目管理文档
- Docs/: 项目文档 (Arch/Design/Verification/FuSa/Firmware/DFT)
- Design/: 设计数据 (RTL/Netlist/GDS)
- Verification/: 验证环境 (UVM+Non-UVM双模式，统一tb_top)
- Scripts/: EDA脚本 (Makefile统一入口)
- Temp/: EDA临时文件 (不提交git)

## 状态

当前阶段: **ip**
