# 项目计划: ethernet

## 1. 项目信息
| 项目 | 内容 |
|------|------|
| 项目ID | IP_20260502_001 |
| 项目名称 | ethernet |
| 项目类型 | IP |
| 阶段 | PAD |
| 计划日期 | 2026-05-11 |
| PM | PM Agent |

## 2. 里程碑

| 阶段 | 计划开始 | 计划结束 | 实际开始 | 实际结束 | 状态 |
|------|---------|---------|---------|---------|------|
| PAD | 2026-05-11 | 2026-05-25 | 2026-05-11 | | 🟡 进行中 |
| EDR | 2026-05-26 | 2026-06-15 | | | ⬜ |
| IDR | 2026-06-16 | 2026-08-15 | | | ⬜ |
| FDR | 2026-08-16 | 2026-09-30 | | | ⬜ |

## 3. PAD阶段WBS (详细任务分解)

| 任务ID | 任务名称 | 负责人 | 计划开始 | 计划结束 | 依赖 | 状态 |
|--------|----------|--------|----------|----------|------|------|
| TASK-014 | PAD阶段项目计划与里程碑管理 | PM Agent | 2026-05-11 | 2026-05-11 | - | 🟢 完成 |
| TASK-015 | **协议分析文档** (Protocol Analysis) | Arch Agent | 2026-05-11 | 2026-05-13 | TASK-014 | 🟢 完成 |
| TASK-003 | Architecture Specification (含 Interface Spec + Clock/Reset Spec) | Arch Agent | 2026-05-13 | 2026-05-18 | TASK-015 | 🟢 完成 |
| TASK-004 | 微架构设计与模块划分 | Arch_Agent | 2026-05-20 | 2026-05-25 | TASK-003 | ⬜ |
| **TASK-006** | **功能安全概念定义 + Arch Spec v1.4 Switch/PHC 升级** | **FuSa Agent / Arch Agent** | **2026-05-11** | **2026-05-13** | **TASK-003** | **🟢 完成** |
| TASK-PAD-SC-001 | SystemC/TLM 建模计划制定 (建模范围/抽象层级/接口定义) | Arch Agent | 2026-05-18 | 2026-05-19 | TASK-003 | 🟢 完成 |
| TASK-PAD-SC-002 | TLM 平台代码开发 (事务级模型搭建) | Design Agent | 2026-05-19 | 2026-05-22 | TASK-PAD-SC-001 | 🟢 完成 |
| TASK-PAD-SC-003 | SystemC 建模报告 (模型验证与性能评估) | Arch Agent / Design Agent | 2026-05-22 | 2026-05-24 | TASK-PAD-SC-002 | 🟢 完成 |
| TASK-PAD-REV | PAD阶段评审 (Gate Check) | AI Yang | 2026-05-25 | 2026-05-25 | 全部完成 | ⬜ |

## 4. 资源分配

| 角色 | Agent | 分配比例 | 状态 |
|------|-------|---------|------|
| 项目经理 | PM Agent | 10% | 🟢 |
| 系统架构 | Arch Agent | 50% | 🟡 |
| 设计 | Design Agent | 30% | 🟡 |
| AI Yang | AI Yang | 10% | 🟡 |

## 5. PAD阶段交付物清单

| 交付物 | 路径 | 负责人 | 状态 |
|--------|------|--------|------|
| 协议分析文档 | `Docs/Arch/protocol_analysis.md` | Arch Agent | 🟢 完成 |
| 架构规格书 (含Interface + Clock/Reset) | `Docs/Arch/ethernet_arch_spec.md` | Arch Agent | 🟢 完成 |
| 微架构设计 | `Docs/Design/ethernet/ethernet_design_spec.md` | Arch_Agent | ⬜ 待EDR阶段 |
| SystemC/TLM 建模计划 | `Docs/Arch/systemc_modeling_plan.md` | Arch Agent | 🟢 完成 |
| TLM 平台代码 | `Design/SystemC/` | Design Agent | 🟢 完成 |
| SystemC 建模报告 | `Docs/Arch/systemc_modeling_report.md` | Arch Agent / Design Agent | 🟢 完成 |
| PAD评审Checklist | `ProjectMgmt/Phases/PAD/Reviews/checklist.md` | AI Yang | ⬜ |

## 6. 风险跟踪

| 风险ID | 描述 | 影响 | 缓解措施 | 负责人 | 状态 |
|--------|------|------|---------|--------|------|
| R001 | TSN协议栈复杂度高，协议间存在交叉依赖 | 高 | 协议分析阶段充分梳理依赖关系，分优先级实现 | Arch Agent | 🟡 |
| R002 | IEEE标准文档数量多，学习周期长 | 中 | 聚焦TC4x已实现功能，不做全协议栈 | Arch Agent | 🟡 |
| R003 | 竞品分析数据来源受限 | 中 | 以公开文档(Infineon/NXP手册)为主 | Arch Agent | 🟡 |
| R-SC-001 | SystemC/TLM 模型与后续 RTL 实现的一致性难以保证 | 高 | 建立模型-RTL 对照验证机制，关键事务场景双向比对 | Arch Agent | 🟡 |
| R-SC-002 | TLM 建模引入额外工作量，挤占 PAD 微架构设计时间 | 中 | 建模与微架构设计并行推进，严格控制建模范围与抽象层级 | PM Agent | 🟡 |
| R-SC-003 | 团队 SystemC/TLM 建模经验不足，模型质量不确定 | 中 | 参考既有 TLM 范例，建模代码纳入评审流程 | Design Agent | 🟡 |
| R-SC-004 | TLM 平台与后续 UVM 验证环境的集成风险 | 中 | 提前定义事务接口边界与抽象层级，EDR 阶段验证接口兼容性 | Arch Agent | 🟡 |
| R-SC-005 | SystemC 2.3.3 pthreads 版本线程数/事件密度限制 | 中 | 线程合并（Switch+DMA 减少 50%+），仿真时间控制在 10us 内 | Design Agent | 🟢 已缓解 |

---

*更新: 2026-05-11 — PAD阶段正式启动，新增TASK-015协议分析文档*  
*更新: 2026-05-18 — PAD阶段新增 SystemC/TLM 建模任务 (TASK-PAD-SC-001~003)，调整 Arch/Design Agent 资源比例，新增交付物与风险 R-SC-001~004*  
*更新: 2026-07-30 — SystemC/TLM 建模完成：单元测试 77/77 通过，集成测试 10/10 通过，系统测试 5/5 通过。线程合并优化完成，SystemC 2.3.3-pthreads 安装至 `/home/CALTERAH/yshen/tools/systemc-2.3.3-pthreads`*

