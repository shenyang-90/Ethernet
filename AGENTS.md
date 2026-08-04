# AGENTS.md - ethernet IP Project

> **项目**: ethernet (IP_20260502_001)  
> **类型**: IP (复用 SoC PAD/EDR/IDR 节点)  
> **当前阶段**: ip  
> **工作流**: 遵循 `workflow/SOC_WORKFLOW.md` / `workflow/IP_WORKFLOW.md`  

---

## 1. Workflow 体系

### 6 阶段设计模型

```
PCD ──→ PAD ──→ EDR ──→ IDR ──→ FDR ──→ Post Silicon
(2-4w)  (2-4w)  (3-6w)  (8-16w) (6-12w) (3-6m)
  │       │       │       │       │       │
  ▼       ▼       ▼       ▼       ▼       ▼
立项    架构    文档    Code    Tape    量产
        冻结    冻结    Freeze  out
```

**IP 开发复用**: PAD → EDR → IDR（定义与 SoC 完全一致）

### 阶段交付物路径

| 阶段 | 任务目录 | Review 目录 | 交付物示例 |
|------|---------|------------|-----------|
| PCD | `ProjectMgmt/Phases/PCD/Tasks/` | `ProjectMgmt/Phases/PCD/Reviews/` | 立项文档 |
| PAD | `ProjectMgmt/Phases/PAD/Tasks/` | `ProjectMgmt/Phases/PAD/Reviews/` | Arch Spec, Interface Spec, SystemC 建模计划/报告 |
| EDR | `ProjectMgmt/Phases/EDR/Tasks/` | `ProjectMgmt/Phases/EDR/Reviews/` | Design Spec, Verification Plan, DFT Spec, FuSa Doc |
| IDR | `ProjectMgmt/Phases/IDR/Tasks/` | `ProjectMgmt/Phases/IDR/Reviews/` | RTL, UVM Env |
| FDR | `ProjectMgmt/Phases/FDR/Tasks/` | `ProjectMgmt/Phases/FDR/Reviews/` | Netlist, Backend, FMEDA |
| PostSilicon | `ProjectMgmt/Phases/PostSilicon/Tasks/` | `ProjectMgmt/Phases/PostSilicon/Reviews/` | 硅后验证 |

---

## 2. 任务交互方式

### 核心机制：项目仓库 = 共享状态机

Agent 之间不直接通信，而是通过**修改共享仓库中的任务文件**来投递和接收任务。

```
┌─────────────┐     git push      ┌─────────────┐
│  云端 Agent  │  ◄────────────►  │  本地 Agent  │
│ PM / AI Yang │   共享仓库同步    │ Design Coding│
│   (计划/检查) │                  │ /Flow/Coding │
└─────────────┘                  │    Yang      │
       │                         └─────────────┘
       ▼                                │
  ProjectMgmt/Phases/<PHASE>/Tasks/    │
  └── [AgentName]/TASK-xxx.md ◄────────┘
```

### 任务文件格式

每个任务以 Markdown 文件存储于 `ProjectMgmt/Phases/<PHASE>/Tasks/` 下：

```markdown
# TASK-009-Design_Coding_Agent-rtl
- **task_id**: TASK-009
- **agent**: Design_Coding_Agent
- **phase**: IDR
- **priority**: P1
- **status**: COMPLETED
- **title**: ethernet RTL 编码
- **description**: 实现 ethernet_top.sv
- **working_directory**: Design/RTL/ip/ethernet
- **auto_trigger_review**: true
```

### 任务状态流转

```
PM Agent 创建任务 (对话触发)
    ↓
status = PENDING
    ↓
auto_task_router.py 扫描 → 按类型自动分配
    ↓
status = ASSIGNED
    ↓
本地 Agent 发现 → 标记 RUNNING → 执行
    ↓
├─ 成功 → status = COMPLETED
│         ↓
│         auto_pipeline.py 检测到 COMPLETED
│         ↓
│         自动创建 Coding Yang review 任务
│         ↓
│         Coding Yang 审查: APPROVED / REJECTED
│         ↓
│         APPROVED → 触发 AI Yang Gate Check
│         ↓
│         Gate PASS → PM Agent 推进阶段
│
└─ 失败 → status = FAILED → 告警/重试
```

---

## 3. 自动化管道

### 3 个核心脚本

| 脚本 | 功能 | 触发方式 |
|------|------|----------|
| `auto_task_router.py` | 扫描 PENDING 任务，按类型路由到对应 Agent | `make assign` / cron |
| `auto_pipeline.py` | 监听状态变化，自动触发下一步（编码完成→审查→门禁→推进） | `make pipeline` / 持续运行 |
| `auto_dashboard.py` | 每 5 分钟扫描项目状态，更新 Dashboard.md | `make dashboard` / cron |

### 快速命令

```bash
cd Scripts
make info           # 项目信息
make lint           # Lint检查
make sim            # 运行仿真
make coverage       # 覆盖率
make dashboard      # 更新Dashboard
make assign         # 自动分配任务
make pipeline       # 启动自动化管道
make watch          # 后台完整自动化 (dashboard + pipeline)
```

---

## 4. Agent 体系与触发方式

### 云端 Agent（对话触发）

| Agent | 触发关键词 | 职责 |
|-------|-----------|------|
| **PM Agent** | "项目计划" / "里程碑" / "进度" / "任务分配" | 计划、排期、任务分配、进度跟踪 |
| **AI Yang** | "review" / "gate check" / "检查" / "质量" | 质量检查、Checklist审核、节点状态总结 |
| **Coding Yang** | "Coding Yang 检查 [模块名]" / "code review" / "lint check" | RTL代码审查、Lint/CDC质量检查、编码规范门禁 |

### 本地 Agent（文件系统触发 / 守护进程）

本地 Agent 通过 `agent_daemon.py` 持续轮询（默认 30 秒）扫描任务目录：

```bash
# 启动方式示例
python3 workflow/templates/scripts_workflow/agent_daemon.py \
    --agent Design_Coding_Agent --project ./
```

| Agent | 任务类型 | 工作目录 |
|-------|---------|---------|
| **Design_Coding_Agent** | `rtl_implementation` | `Design/RTL/` |
| **Verification_Coding_Agent** | `verification` | `Verification/` |
| **Flow_Agent** | `eda_run` / `synthesis` / `pr` / `sta` / `dft` | `Design/Netlist/`, `Design/GDS/` |
| **Coding_Yang** | `review` / `lint_check` / `cdc_check` | `ProjectMgmt/Reviews/` |
| **Design_Agent** | `doc_writing` | `Docs/` |
| **Verification_Agent** | `verification_plan` / `coverage_plan` | `Docs/Verification/` |
| **DFT_Agent** | `dft_spec` / `atpg` | `Docs/DFT/` |
| **FuSa_Agent** | `fusa_analysis` / `safety_doc` | `Docs/FuSa/` |
| **Arch_Agent** | `arch_spec` / `micro_arch` | `Docs/Arch/` |

---

## 5. 目录结构与 Agent 工作空间

```
eternet/
├── ProjectMgmt/              # 任务状态、Dashboard、Reviews (git提交)
│   ├── Phases/
│   │   ├── PAD/Tasks/       # Arch_Agent, Design_Agent 任务
│   │   ├── EDR/Tasks/       # Design_Agent, Verification_Agent, DFT_Agent, FuSa_Agent 任务
│   │   ├── IDR/Tasks/       # Design_Coding_Agent, Verification_Coding_Agent 任务
│   │   ├── FDR/Tasks/       # Flow_Agent, FuSa_Agent 任务
│   │   └── PostSilicon/Tasks/
│   ├── Planning/            # project_plan.md, schedule.md
│   └── StatusReports/       # 周报/月报模板
├── Docs/                    # 文档 (git提交)
│   ├── Arch/                # Arch_Agent 产出
│   ├── Design/              # Design_Agent 产出
│   ├── Verification/        # Verification_Agent 产出
│   ├── DFT/                 # DFT_Agent 产出
│   ├── FuSa/                # FuSa_Agent 产出
│   └── Firmware/            # Firmware 相关文档
├── Design/                  # 设计数据 (git提交)
│   ├── SystemC/             # SystemC 架构/性能模型 (Arch_Agent, Design_Agent 可使用)
│   │   ├── models/          # SystemC 事务级/架构模型 (Switch/MAC/PHC/vPHC/DMA/Host/TrafficGen/Top)
│   │   ├── tests/           # SystemC 模型测试平台 (单元测试 77/77，集成测试 10/10，系统测试 5/5)
│   │   ├── utils/           # 建模辅助脚本与工具 (statistics/trace/dummy/tlm_mm)
│   │   └── Makefile         # SystemC 2.3.3-pthreads 构建脚本
│   └── RTL/ip/ethernet/     # Design_Coding_Agent 产出
├── Verification/            # 验证环境 (git提交)
│   ├── Env/                 # Verification_Coding_Agent 产出
│   ├── Testcases/           # 测试用例
│   └── Regression/          # 回归列表
├── Scripts/                 # EDA脚本 (git提交)
│   ├── Makefile             # 统一入口
│   └── EDA/                 # dc_synth.mk, pt_sta.mk, vcs.mk, verilator.mk
├── Reference/               # 参考文档 (git提交)
│   ├── 8023-2022/           # IEEE 802.3 标准
│   ├── 8021Q-2022/          # IEEE 802.1Q 标准
│   ├── 8021AS-2020/         # IEEE 802.1AS 标准
│   ├── 8021AE-2018/         # IEEE 802.1AE 标准
│   ├── 8021CB-2017/         # IEEE 802.1CB 标准
│   ├── Infineon/            # 英飞凌 TC4x 参考
│   └── Kimi_Agent_TC4x_Ethernet/  # Agent 研究产出
└── Temp/                    # EDA临时文件 (.gitignored)
    ├── Design_Coding_Agent/ # Lint日志、编译输出
    ├── Coding_Yang/         # review日志
    ├── Verification_Coding_Agent/ # 仿真日志、波形
    └── Flow_Agent/          # 综合日志、STA报告
```

**关键原则**: 只有 `ProjectMgmt/`、`Design/`、`Docs/`、`Verification/`、`Scripts/`、`Reference/` 的内容提交 git，`Temp/` 不提交。

---

## 6. 门禁检查清单

每个阶段完成后必须执行对应 Checklist：

| 阶段 | Checklist 文件 | 路径 |
|------|---------------|------|
| PAD | `checklists/PAD_CHECKLIST.md` | `ProjectMgmt/Phases/PAD/Reviews/checklist.md` |
| EDR | `checklists/EDR_CHECKLIST.md` | `ProjectMgmt/Phases/EDR/Reviews/checklist.md` |
| IDR | `checklists/IDR_CHECKLIST.md` | `ProjectMgmt/Phases/IDR/Reviews/checklist.md` |
| FDR | `checklists/FDR_CHECKLIST.md` | `ProjectMgmt/Phases/FDR/Reviews/checklist.md` |

**自动门禁检查命令**:
```bash
python3 workflow/gate/gate_check.py --phase IDR --project .
```

---

## 7. 冲突解决

多 Agent 同时修改任务文件时，采用 **git rebase + 指数退避重试**:

```
1. git pull origin main --rebase
2. git add / git commit
3. git push origin main
4. 失败则等待 2^attempt 秒后重试 (最多 3 次)
```

---

## 8. 人工不可跳过的环节

| 环节 | 为什么必须人工 | 决策者 |
|------|--------------|--------|
| **架构选型** | AI 不能做技术选型 | 实体 Yang |
| **Code Freeze 批准** | 涉及 Tapeout 承诺 | 实体 Yang |
| **Bug 优先级判定** | 需要工程判断 | Design Lead |
| **覆盖率缺口补充** | 需要理解设计意图 | 验证工程师 |
| **最终 Sign-off** | 法律责任 | 项目经理 + 实体 Yang |
| **Tapeout** | 不可逆决策 | 实体 Yang |

**原则**: 自动化负责"收集、路由、通知、触发"，人类负责"判断、决策、批准"。

---

## 9. 本项目已有的任务

| 阶段 | 任务ID | Agent | 内容 | 状态 |
|------|--------|-------|------|------|
| PAD | TASK-003 | Arch_Agent | arch_spec | 已完成 |
| PAD | TASK-004 | Design_Agent | micro_arch | 已完成 |
| PAD | TASK-014 | PM_Agent | pad_planning | 已完成 |
| EDR | TASK-005 | Design_Agent | design_spec | 已完成 |
| EDR | TASK-006 | Verification_Agent | vplan | 已完成 |
| EDR | TASK-007 | DFT_Agent | dft_spec | 已完成 |
| EDR | TASK-008 | FuSa_Agent | safety | 已完成 |
| IDR | TASK-009 | Design_Coding_Agent | rtl | 已完成 |
| IDR | TASK-010 | Verification_Coding_Agent | uvm | 已完成 |
| FDR | TASK-011 | Flow_Agent | backend | 待完成 |
| FDR | TASK-013 | FuSa_Agent | fmeda | 待完成 |

---

*文件: sandbox/ethernet/AGENTS.md*  
*版本: v1.0*  
*说明: ethernet IP 项目的 Agent 工作指南与任务交互规范*
