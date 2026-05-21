# PM Agent Review: Ethernet IP PAD Gate Review

**评审日期**: 2026-05-21
**评审角色**: PM Agent (项目管理视角)
**评审范围**: Ethernet IP PAD 阶段全部交付物的项目管理合规性
**项目ID**: IP_20260502_001

---

## 1. 评审范围

本次评审覆盖 PAD 阶段 7 类核心交付物及其项目管理属性：

| # | 交付物 | 路径 | 预期版本 | 评审重点 |
|---|--------|------|---------|---------|
| 1 | Architecture Specification | `Docs/Arch/ethernet_arch_spec.md` | v1.8c | 版本追溯、变更日志完整性 |
| 2 | Protocol Analysis | `Docs/Arch/protocol_analysis.md` | v2.2 | 版本状态、与 Arch Spec 对齐 |
| 3 | Interface Specification | `Docs/Arch/ethernet_interface_spec.md` | v1.0 | 与 Arch Spec 版本一致性 |
| 4 | Clock/Reset Specification | `Docs/Arch/ethernet_clock_reset_spec.md` | v1.0 | 与 Arch Spec 版本一致性 |
| 5 | Safety Concept | `Docs/FuSa/safety_concept.md` | v1.0 | 版本状态、FuSa 流程合规 |
| 6 | PICS 分析 (8 文件) | `Docs/Arch/PICS/` | — | 文件完整性、可追溯性 |
| 7 | Design Specification (微架构) | `Docs/Design/ethernet/ethernet_design_spec.md` | v1.0 | 版本状态、下游依赖清晰度 |

此外评审项目级管理交付物：
- 项目计划 (`ProjectMgmt/Planning/project_plan.md`)
- 排期表 (`ProjectMgmt/Planning/schedule.md`)
- 风险登记册 (缺失)
- 人力估算 (缺失)

---

## 2. 项目管理检查项

### 2.1 交付物存在性与非空性

| 检查项 | 结果 | 说明 |
|--------|:----:|------|
| Arch Spec 存在且非空 | ✅ | 1721 行，98.8KB |
| Protocol Analysis 存在且非空 | ✅ | 2814 行，93.5KB |
| Interface Spec 存在且非空 | ✅ | 390 行，~15KB |
| Clock/Reset Spec 存在且非空 | ✅ | 287 行，~12KB |
| Safety Concept 存在且非空 | ✅ | 384 行，~18KB |
| PICS 7 协议原生文件 + 汇总 | ✅ | 8 文件，共 ~148KB |
| Design Spec 存在且非空 | ✅ | 709 行，~38KB |
| **项目计划存在** | ✅ | `project_plan.md` 已更新 |
| **排期表存在** | ✅ | `schedule.md` 已更新 |
| **风险登记册** | ❌ | 缺失，待创建 |
| **人力估算** | ❌ | 缺失，未估算各阶段人天 |

**结论**: 技术交付物 8/8 全部存在且非空；项目级管理交付物 2/4 存在，风险登记册和人力估算缺失。

### 2.2 版本号一致性与可追溯性

| 交付物 | 文件版本 | 最后更新日期 | 版本历史条目数 | 问题 |
|--------|:-------:|:----------:|:------------:|------|
| Arch Spec | **v1.8c** | 2026-05-21 | 8 条 | ⚠️ 版本历史缺少 v1.8, v1.8a, v1.8b, v1.8c 的变更记录；条目顺序混乱 (v1.7 之后是 v1.4.1) |
| Protocol Analysis | **v2.2** | 2026-05-21 | 0 (仅 header) | ⚠️ 无正式版本历史章节，变更记录仅在 header 中以单行文本嵌入 |
| Interface Spec | **v1.0** | 2026-05-11 | 2 条 | ⚠️ **版本严重滞后**：Arch Spec 自 v1.0 起历经 8 次重大修订 (Switch/PHC/vPHC/DMA全局池/erratum/全平台并集)，Interface Spec 未同步升级 |
| Clock/Reset Spec | **v1.0** | 2026-05-11 | 2 条 | ⚠️ **版本严重滞后**：同上，新增 PHY_x_DUPLEX、EEE 时钟门控、5G USXGMII 625MHz 时钟树等均未反映在版本历史中 |
| Safety Concept | **v1.0** | 2026-05-11 | 1 条 | ⚠️ 会议记录标注为 v1.1+，但文件仍为 v1.0；且未反映 Arch Spec 中新增的参数安全影响 |
| Design Spec | **v1.0** | 2026-05-12 | 1 条 (header 引用) | ⚠️ 前置依赖声明为 Arch Spec **v1.8d**，但实际 Arch Spec 最新版本为 **v1.8c**，版本引用不匹配 |
| PICS Summary | — | 2026-05-21 | — | ✅ 日期与 Arch Spec 一致，8 文件完整 |

**关键发现**:
1. **Interface Spec 和 Clock/Reset Spec 自 2026-05-11 起未更新**，而 Arch Spec 在同日经历了 v1.0 → v1.1 → v1.2 → v1.4 → v1.6 → v1.7 → v1.8c 的密集迭代。新增参数 (`SWITCH_CONNECTED_MAC_x[]`, `PHC_COUNT=2`, `vPHC` 寄存器, `PHY_x_DUPLEX`, `SUPPORT_EEE`, `SUPPORT_IPSEC` 等) 未在 Interface/Clock 文档中登记版本变更。
2. **版本历史规范性不足**: Arch Spec 的 §9.1 版本历史表格条目顺序不升序排列 (v1.7 之后出现 v1.4.1)，不符合标准文档规范；Protocol Analysis 完全缺失版本历史章节，仅依赖 header 中的单行描述。
3. **Design Spec 依赖版本漂移**: Design Spec 声明依赖 Arch Spec v1.8d，但实际文件为 v1.8c。虽然差异极小 (c vs d 为同日补丁级修订)，但在可追溯性审计中属于 **不一致项**。

### 2.3 变更日志完整性

| 交付物 | 变更日志位置 | 每版变更粒度 | 变更原因可追溯 | 问题 |
|--------|-----------|:----------:|:------------:|------|
| Arch Spec | §9.1 表格 | 中等 | 是 | 缺失中间版本 (v1.3, v1.5, v1.8a/b/c) |
| Protocol Analysis | 无独立章节 | 粗粒度 | 部分 | 仅有单行 header 描述，无分条目日志 |
| Interface Spec | §9.1 表格 | 粗粒度 | 是 | 仅 v0.1→v1.0 一次升级，未记录后续对齐修订 |
| Clock/Reset Spec | §5.1 表格 | 粗粒度 | 是 | 同上 |
| Safety Concept | §9.3 表格 | 粗粒度 | 是 | 仅 1 个版本，无迭代记录 |
| Design Spec | header 引用 | 中等 | 是 | 引用版本号与实际不符 |

**变更日志完整性评估**: **部分满足**。Arch Spec 虽有版本历史，但粒度不足以支撑 8 次密集迭代的全审计追踪；其余 Spec 文档的变更日志形同虚设，无法反映与 Arch Spec 的同步修订关系。

### 2.4 已知风险登记状态

| 风险项 | 登记位置 | 严重程度 | 状态 |
|--------|---------|:-------:|:----:|
| TSN 协议栈复杂度高，协议间交叉依赖 | `project_plan.md` §6 | 高 | 🟡 已识别但未量化 |
| IEEE 标准文档学习周期长 | `project_plan.md` §6 | 中 | 🟡 已识别 |
| 竞品分析数据来源受限 | `project_plan.md` §6 | 中 | 🟡 已识别 |
| 半双工 CRS/CD 时钟域未定义 | Interface/Clock Spec 待解决问题 | — | 未进入风险登记册 |
| EEE RTL 模块划分缺失 | Design Spec 下游 | — | 未进入风险登记册 |
| Security IF 物理接口未定义 | 会议共识问题 #3 | — | 未进入风险登记册 |
| 35+ 参数组合爆炸 (验证) | Verification Agent 发言 | — | 未进入风险登记册 |

**结论**: 仅 3 项宏观风险在项目计划中有登记，全部 8 个 Gate Review 共识 Minor 问题**未纳入风险登记册**，也未分配风险 ID、概率/影响量化、触发条件和责任人。从项目管理合规性角度，这属于 **流程缺口**。

### 2.5 下游任务依赖清晰度

| 下游阶段 | 任务ID | 依赖输入 | 输入版本 | 衔接清晰度 |
|---------|--------|---------|---------|:--------:|
| EDR | TASK-005 (Design Spec) | Micro-Arch Spec v1.0 | v1.0 | ✅ 明确 |
| EDR | TASK-007 (DFT Spec) | Micro-Arch Spec v1.0 | v1.0 | ✅ 明确 |
| EDR | TASK-008 (FuSa FMEDA) | Micro-Arch Spec v1.0 | v1.0 | ✅ 明确 |
| IDR | TASK-009 (RTL Coding) | Micro-Arch Spec v1.0 + Arch Spec v1.8d | v1.0 / v1.8d | ⚠️ 版本引用不匹配 (实际 v1.8c) |
| IDR | TASK-010 (UVM Env) | Micro-Arch Spec v1.0 | v1.0 | ✅ 明确 |
| EDR | TASK-EDR-002 (LCB2SRI) | ISSUE-002 转移 | Arch Spec v1.8c | ✅ 明确 (从待解决问题转移) |

**下游依赖总体评价**: ✅ 下游任务与输入文档的映射关系在 Design Spec §8 中已清晰定义。但 Arch Spec 引用版本号不一致 (v1.8d vs v1.8c) 可能导致后续阶段困惑。

### 2.6 资源与人力估算

| 检查项 | 状态 | 说明 |
|--------|:----:|------|
| 各阶段人天估算 | ❌ 缺失 | 无各 Agent 工作量人天估算 |
| 资源分配矩阵 | ⚠️ 粗粒度 | project_plan.md §4 仅有角色分配比例，无具体人天 |
| 排期缓冲 | ⚠️ 不足 | PAD 阶段 15 天 (5/11-5/25)，实际 Arch Spec 经历了 8 次密集修订，时间线已极度压缩 |
| EDR 阶段排期 | 🟡 待验证 | 21 天 (5/26-6/15) 需覆盖 Design Spec + Verification Plan + DFT + FuSa，未验证可行性 |

**关键发现**: Arch Spec 在 5/11 至 5/21 的 10 天内经历了从 v1.0 到 v1.8c 的 8 次版本迭代，平均每天 0.8 个版本。这种迭代密度表明：
- (a) 初期需求定义不够充分，导致后期大量补丁级修订；
- (b) 文档版本控制流程不严格，存在同一日内多次跳版本的现象 (v1.1/v1.2 同日，v1.4/v1.6/v1.7 同日)。
从项目管理角度，这不构成交付物质量缺陷，但属于 **流程成熟度不足**，应在 IDR 阶段引入版本冻结规则。

---

## 3. 发现的问题

### 3.1 Critical 问题 (0 项)

无。

### 3.2 Major 问题 (0 项)

无。

### 3.3 Minor 问题 (6 项)

| # | 问题描述 | 涉及交付物 | 严重程度 | 影响 | 建议修复 | 责任阶段 |
|---|---------|---------|:-------:|------|---------|---------|
| PM-001 | **Interface Spec 和 Clock/Reset Spec 版本严重滞后于 Arch Spec**。两文档最后更新日期为 2026-05-11，而 Arch Spec 在 5/11-5/21 间历经 8 次重大修订 (Switch/PHC/vPHC/DMA 全局池/erratum/全平台并集)。新增参数未在两文档中体现版本升级。 | Interface Spec, Clock/Reset Spec | Minor | 下游 Design Agent 可能基于过时的接口/时钟定义展开工作 | EDR 初期升级至 v1.1，同步 Arch Spec v1.8c 的全部新增参数 | EDR |
| PM-002 | **Arch Spec 版本历史不完整且顺序混乱**。版本历史表格中 v1.7 (5/12) 之后出现 v1.4.1 (5/12)，未按升序排列；且缺少 v1.3, v1.5, v1.8, v1.8a/b/c 的变更记录。 | Arch Spec | Minor | 文档审计和变更追溯困难 | 整理版本历史为严格升序，补录缺失的中间版本或注明合并原因 | 立即 |
| PM-003 | **Protocol Analysis 缺失独立版本历史章节**。变更信息仅以单行文本嵌入 header (`v2.0 → v2.1 → v2.2`)，无分条目变更日志。 | Protocol Analysis | Minor | 无法追溯具体章节或内容的变更 | 增设 §X "版本历史"，按条目列出各版本的主要章节增删改 | EDR |
| PM-004 | **Design Spec 引用的 Arch Spec 版本号不匹配**。Design Spec header 声明依赖 Arch Spec v1.8d，但实际文件为 v1.8c。 | Design Spec | Minor | 下游 RTL Coding Agent 可能困惑于 "d 版在哪里" | 修正为 v1.8c，或若存在 v1.8d 则应补发并统一引用 | 立即 |
| PM-005 | **Safety Concept 文件版本 (v1.0) 与会议共识 (v1.1+) 不一致**。文件未反映 Arch Spec 新增参数 (`SUPPORT_EEE`, `SUPPORT_IPSEC`, `PHY_x_DUPLEX`) 的安全影响评估。 | Safety Concept | Minor | FuSa Agent 后续需补充参数安全影响矩阵时，版本基线混乱 | 明确版本号 (v1.0 或 v1.1)，在 EDR 阶段完成参数安全影响评估并升级版本 | EDR/IDR |
| PM-006 | **风险登记册 (Risk Register) 缺失**。Gate Review 中 8 个共识 Minor 问题未纳入风险登记册，无风险 ID、概率/影响矩阵、触发条件、升级机制。 | 项目管理交付物 | Minor | 问题跟踪依赖会议纪要和 Agent 个人记忆，缺乏制度化风险管理 | IDR 阶段创建 `ProjectMgmt/Risk_Register.md`，将 8 个 Minor 问题以及 3 个宏观风险全部纳入 | IDR |

### 3.4 观察项 (Observations, 非阻塞)

| # | 观察 | 说明 |
|---|------|------|
| OBS-001 | Arch Spec 版本迭代密度过高 (10 天 8 个版本) | 建议在 EDR 阶段引入 "版本冻结窗口" 规则，例如：EDR 启动后 Arch Spec 进入变更控制，任何修改需走变更请求 (CR) 流程 |
| OBS-002 | 人力估算完全缺失 | 当前项目计划仅有角色分配比例，无各阶段/各 Agent 的具体人天。建议在 IDR 阶段补充 WBS 到工作包级别的人力估算 |
| OBS-003 | EDR 阶段 21 天排期可能不足 | EDR 需完成 Design Spec + Verification Plan + DFT Spec + FuSa Analysis + 4 个 Gate Review Minor 修复，排期未经过工作量估算验证 |
| OBS-004 | 排期表甘特图与实际情况已发生偏差 | schedule.md 中 Arch Spec 计划为 5/13-5/18 (6 天)，实际迭代延续至 5/21，且 Interface/Clock Spec 计划为 5/16-5/20，实际未在 5/11 后更新 |

---

## 4. 推荐决策

### 4.1 对 PAD Gate 的推荐

**推荐决策**: **有条件通过 (Conditional Pass)**

**理由**:
- 全部 8 项技术交付物存在且非空，内容质量经多 Agent 交叉评审确认为高
- Arch Spec → Protocol Analysis → Design Spec → Safety Concept 的追溯链路完整
- 0 项 Critical / 0 项 Major 问题
- 发现的 6 项 Minor 问题均不阻塞 EDR 阶段启动，可在 EDR/IDR 阶段并行修复

**前提条件** (EDR 启动前必须完成):
1. PM-004 (Design Spec 版本引用不匹配) — **立即修正**，确保下游任务基线一致
2. PM-002 (Arch Spec 版本历史顺序) — **立即整理**，避免审计问题

### 4.2 对实体 Yang 的决策建议

| 决策项 | 建议 | 说明 |
|--------|------|------|
| 签署 PAD Gate Approval | ✅ 建议签署 | 技术交付物质量达标，Minor 问题不阻塞下游 |
| 解锁 EDR 任务启动 | ✅ 建议解锁 | TASK-005/TASK-006/TASK-008/TASK-EDR-002 已具备输入条件 |
| 要求 IDR 前完成风险登记册 | ⚠️ 强烈建议 | 将 PM-006 纳入 IDR 阶段准入条件 (Entry Criteria) |
| 要求人力估算纳入 IDR 计划 | ⚠️ 建议 | 验证 EDR/IDR/FDR 排期可行性 |

---

## 5. IDR/EDR 阶段需补充的管理交付物

### 5.1 EDR 阶段 (必须)

| 交付物 | 路径建议 | 责任人 | 说明 |
|--------|---------|--------|------|
| Interface Spec v1.1 | `Docs/Arch/ethernet_interface_spec.md` | Arch Agent | 对齐 Arch Spec v1.8c 新增参数 |
| Clock/Reset Spec v1.1 | `Docs/Arch/ethernet_clock_reset_spec.md` | Arch Agent | 补充 CRS/CD 时钟域、EEE 时钟门控、5G USXGMII 625MHz |
| Protocol Analysis 版本历史 | `Docs/Arch/protocol_analysis.md` | Arch Agent | 增设独立变更日志章节 |
| Arch Spec 版本历史整理 | `Docs/Arch/ethernet_arch_spec.md` | Arch Agent | 升序排列，补录缺失版本 |

### 5.2 IDR 阶段 (必须)

| 交付物 | 路径建议 | 责任人 | 说明 |
|--------|---------|--------|------|
| **风险登记册 (Risk Register)** | `ProjectMgmt/Risk_Register.md` | PM Agent | 含 8 个 Gate Review Minor 问题 + 3 个宏观风险 + 概率/影响矩阵 |
| **人力估算 (Effort Estimation)** | `ProjectMgmt/Planning/effort_estimate.md` | PM Agent | WBS 到工作包级的人天估算，验证排期可行性 |
| 安全参数影响矩阵 | `Docs/FuSa/safety_concept.md` v1.2 | FuSa Agent | 评估 `SUPPORT_EEE`, `SUPPORT_IPSEC`, `PHY_x_DUPLEX` 对 SG 的影响 |
| 排期表更新 | `ProjectMgmt/Planning/schedule.md` | PM Agent | 根据实际 PAD 完成日期 (5/21) 修订 EDR/IDR 起止时间 |

### 5.3 FDR 阶段 (建议)

| 交付物 | 说明 |
|--------|------|
| 版本冻结与变更控制流程 | 定义 Arch Spec 在 RTL 编码阶段的变更控制委员会 (CCB) 规则 |
| 交付物基线审计模板 | 标准化各 Gate Review 的 PM 合规检查清单 |

---

## 6. 版本对齐矩阵 (PM 审计快照)

| 交付物 | 当前版本 | 最后更新 | 应同步的 Arch Spec 版本 | 对齐状态 |
|--------|:-------:|:-------:|:---------------------:|:-------:|
| Arch Spec | v1.8c | 2026-05-21 | — | ✅ 基线 |
| Protocol Analysis | v2.2 | 2026-05-21 | v1.8c | ✅ 日期对齐 |
| Interface Spec | v1.0 | 2026-05-11 | v1.8c | ❌ **滞后 10 天** |
| Clock/Reset Spec | v1.0 | 2026-05-11 | v1.8c | ❌ **滞后 10 天** |
| Safety Concept | v1.0 | 2026-05-11 | v1.8c | ❌ **滞后 10 天** |
| Design Spec | v1.0 | 2026-05-12 | v1.8c | ⚠️ 引用声明 v1.8d |
| PICS (8 文件) | — | 2026-05-21 | v1.8c | ✅ 日期对齐 |

---

## 7. 评审结论

从项目管理合规性视角，Ethernet IP PAD 阶段的技术交付物 **内容完整、质量达标、可追溯链路清晰**，满足 Gate Review 的技术准入条件。

但在 **文档版本控制规范性** (版本历史不完整、版本号不匹配、多文档版本不同步) 和 **项目级管理交付物完备性** (风险登记册、人力估算缺失) 方面存在不足。

**最终推荐**: **有条件通过 PAD Gate**，PM-002 和 PM-004 应在 EDR 启动前立即修正，其余 Minor 问题在 EDR/IDR 阶段并行处理。建议将风险登记册和人力估算纳入 IDR 阶段的准入条件 (Entry Criteria)。

---

*评审人: PM Agent*
*评审日期: 2026-05-21*
*评审状态: COMPLETED*
*下一步: 提交 AI Yang 汇总至实体 Yang*
