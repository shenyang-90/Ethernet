# Ethernet IP PAD Gate Review — Verification Agent 评审记录

> **评审日期**: 2026-05-21  
> **评审人**: Verification Agent  
> **评审对象**: Ethernet IP Architecture Specification v1.8c + Protocol Analysis v2.2  
> **阶段**: PAD Gate → EDR 过渡  
> **项目编号**: IP_20260502_001

---

## 一、评审范围

| 文档 | 章节 | 评审重点 |
|------|------|---------|
| `ethernet_arch_spec.md` | §1.4.2 可配置参数矩阵 | 35+ 参数的定义、约束、组合爆炸风险评估 |
| `ethernet_arch_spec.md` | §4.4 带宽评估计算器 | 公式正确性、配置推荐矩阵的可验证性 |
| `ethernet_arch_spec.md` | §6.4 验证计划摘要 | 验证项完整性、目标量化、平台选择 |
| `protocol_analysis.md` | §8 PICS 支持矩阵 | Yes/No/Configurable 判定与测试用例的映射关系 |

---

## 二、验证可执行性检查项

### 2.1 参数组合爆炸 — "黄金配置"验证子集

**检查结论**: ❌ **不通过 — 关键缺失**

**现状分析**:
- Arch Spec §1.4.1~1.4.3 定义了 **35+ 可配置参数**，涵盖协议开关、MAC/PHY 类型速率、DMA 全局池、Switch 拓扑、安全等级等多维度。
- 典型组合数粗略估算（仅考虑关键参数）：  
  `MAC_COUNT(8) × PHY_COUNT(8) × MAC_TYPE(3)^8 × PHY_TYPE(4)^8 × SWITCH(2) × TSN(2) × 1588(2) × ASIL(5) × DMA_CH(6)` → **组合空间极大，全量验证不可行**。
- §1.4.4 提供了 **12 个典型应用场景配置**（中央网关、ADAS、Zone Controller、边缘节点等），但这些是**设计参考示例**，并非**验证回归的"黄金配置"子集**。

**缺失内容**:
1. **未定义"黄金配置"子集**: 哪些配置组合必须进入 nightly regression？哪些仅做 smoke test？
2. **未定义参数边界验证策略**: 如 `MAC_COUNT=8` + `PHY_COUNT=1`（MAC>PHY）的 corner case 如何验证？
3. **未定义非法参数组合的拒绝验证**: 文档中列出了大量约束（如 `MAC_x_TYPE=0` 时 `MAC_x_SPEED` 仅支持 0~1），但无验证计划确认 RTL 在非法组合时的行为（clamp？报错？静默失效？）。
4. **未定义参数重配置验证**: `DMA_CH_MAP` 寄存器运行时重映射"不支持运行时迁移（需复位后生效）"——但未计划验证非法运行时写入的拒绝行为。

**严重性**: 🔴 **Critical** — 没有黄金配置子集，EDR 阶段验证范围无法收敛，回归测试规模失控。

---

### 2.2 PICS Yes/No → 测试用例映射

**检查结论**: ⚠️ **有条件通过 — Major 改进空间**

**现状分析**:
- `protocol_analysis.md` §8.2 提供了 4 个协议的 PICS 精简矩阵（802.1AS / 802.1Q / 802.1AE / 1588），标注了 Mandatory/Optional 状态和支持情况。
- `ethernet_arch_spec.md` §10.6 建立了 Arch Spec 参数 ↔ PICS 的映射验证表，一致性标注为 ✅。

**缺失内容**:
1. **PICS Yes 项未映射到具体 TC ID**: 例如 802.1AS 的 `DOM0=M/Yes`、`BRDG=M/Yes`、`MINTA=M/Yes` 等，Arch Spec 中无对应的 test case ID（如 `TC_GPTP_001_DOM0_SYNC`）。
2. **PICS No 项缺乏负面验证计划**: 标为 No 的能力（SRP、PFC、ATS、CQF、MSC、MSAK、TC-MACsec、SNMP MIB、E2E 延迟、IPv4/UDP PTP、Management 消息、Talker/Listener 完整栈、IPsec/SecOC/D-TLS 协议栈）目前只有"缓解措施"描述，**没有验证计划确认 RTL 在收到这些帧/请求时正确拒绝或忽略**。负面验证（negative testing）是车规合规的关键。
3. **Configurable 项缺乏状态切换验证**: `SUPPORT_EEE`、`SUPPORT_IPSEC`、`SUPPORT_SECOC`、`SUPPORT_DTLS`、`SUPPORT_AVTP_CTL` 等参数默认关闭（0），但启用路径（0→1 或编译时配置）的验证未定义。
4. **IEEE 1722 AVTP 的 PICS 矩阵缺失**: `protocol_analysis.md` §8.2 未包含 IEEE 1722 AVTP 的 PICS 分析（虽在 §1.1 分类矩阵中列为 P1）。Arch Spec §10.1 表中列出但无详细 PICS 条目。

**严重性**: 🟡 **Major** — PICS 是协议合规认证的核心输入物，没有测试用例映射的 PICS 矩阵无法用于后期第三方认证（如 OPEN Alliance TC8）。

---

### 2.3 覆盖率目标定义

**检查结论**: ❌ **不通过 — 严重缺失**

**现状分析**:
- §6.4 的 9 项验证计划摘要全部是**功能/性能测试项**（CBS 带宽精度、TAS IPG、TX Underflow、DMA Stall Recovery、PTP 同步、Switch 满载丢帧、温度稳定性、PLCA 时序、PHY 噪声恢复）。
- 这些测试项有**定性目标**（如 "误差 < 0.1%"、"零丢帧"）和**测试平台**（UVM/FPGA），但**完全没有覆盖率方法论**。

**缺失内容**:

| 覆盖率类型 | 期望定义 | 实际状态 |
|-----------|---------|---------|
| **Line Coverage** | > 90% 或 > 95% 的目标值 | ❌ 未定义 |
| **Branch/Condition Coverage** | > 90% 的目标值 | ❌ 未定义 |
| **FSM Coverage** | 关键状态机（MAC TX/RX、PTP 端口状态、DMA 命令 FIFO、Switch 转发）的转移覆盖目标 | ❌ 未定义 |
| **Toggle Coverage** | 数据通路、配置寄存器的 toggle 目标 | ❌ 未定义 |
| **Assertion Coverage** | SVA 数量规划与覆盖目标（> 95%） | ❌ 未定义 |
| **Functional Coverage** | Covergroup 定义（如 `cg_mac_config` 覆盖所有 MAC_TYPE/SPEED 组合、`cg_tsn_features` 覆盖 CBS/TAS/FP 开关组合） | ❌ 未定义 |
| **Cross Coverage** | 多参数交叉覆盖（如 `MAC_TYPE × PHY_TYPE × SUPPORT_TSN`） | ❌ 未定义 |

**严重性**: 🔴 **Critical** — 覆盖率目标是验证收敛的量化标准，PAD Gate 不定义则 EDR 阶段无法衡量验证完成度。

---

### 2.4 Formal 验证范围

**检查结论**: ❌ **不通过 — 关键缺失**

**现状分析**:
- 两份文档**全文未提及 Formal Verification**（JasperGold / VC Formal / SymbiYosys）。
- 对于车规级 Ethernet IP，以下模块是 Formal 验证的高价值目标：
  - **TAS Gate Control List**: 门控周期、时间窗口的互斥与时序属性
  - **PTP Timestamp Engine**: 时间戳捕获的 monotonicity、原子性
  - **DMA Descriptor Ring**: 空/满指针一致性、无死锁/无饥饿
  - **Switch Crossbar Arbiter**: 公平性、无饿死、并发无冲突
  - **ECC/Parity FSM**: 故障注入后的安全状态转换
  - **Credit-Based Shaper**: 信用值非负、上限不溢出

**缺失内容**:
1. 未定义 Formal 验证的模块范围。
2. 未定义属性规范（SVA / PSL）的编写责任人。
3. 未定义 Formal 与 UVM 的验证分工边界（哪些模块 Formal 做穷尽证明，哪些留给仿真）。

**严重性**: 🔴 **Critical** — 车规级 TSN/DMA/Switch 的时序和协议属性依赖 Formal 验证提供穷尽性保证，仅靠仿真无法覆盖 corner case。

---

### 2.5 TC4x Erratum 规避的回归测试

**检查结论**: ⚠️ **有条件通过 — Major 改进空间**

**现状分析**:
- §6.1 列出了 **13 项关键 erratum** 的设计规避方案，每项都标注了"验证方法"（如"带宽精度测试"、"UVM 故障注入"）。
- 设计修改描述详细（§6.2.1~6.2.10），包括 RTL 代码片段和寄存器位定义。

**缺失内容**:
1. **未建立 erratum → regression testcase 的追溯表**: 13 项 erratum 的验证方法描述过于笼统（如"带宽精度测试"），缺少具体的 testcase ID、激励条件、通过/失败判据、运行频率（ nightly / weekly / gate前）。
2. **未定义 erratum 的回归策略**: 这些测试是否需要在每次 RTL 变更后全量运行？哪些可以放入冒烟集？
3. **未定义 erratum 的防退化（anti-regression）机制**: 例如 GETH_AI.029（CBS credit IPG 递减）的修复是 `CBS_IPG_DECR_EN` 默认=1，需验证未来 RTL 维护中该默认值不会被意外改为 0。应建立 assertion 或编译时检查。
4. **未定义 erratum 的覆盖率闭环**: 设计说"已规避"，但验证如何证明"已规避且不会退化"？需要 assertion-based check 或定向测试。

**严重性**: 🟡 **Major** — erratum 规避是本项目核心卖点（vs TC4x），必须有持续回归保证其有效性。

---

### 2.6 §4.4 带宽评估计算器 — 验证视角补充

**检查结论**: ✅ **通过 — Minor 建议**

**现状分析**:
- §4.4 提供了完整的带宽计算流程（7 步公式）、典型场景计算示例表、配置推荐矩阵、设计决策说明。
- 公式逻辑合理：有效数据率 → 总线线速 → TSN 余量 → AXI 带宽 → DMA 通道数 → Switch 转发额外带宽。

**发现的问题**:
1. **Switch 转发带宽公式过于简化**: §4.4.2 步骤 7 中 `R_switch = R_total × 2` 假设所有帧都需"读内存 + 写内存"（store-forward），但 `R_switch_ct = R_total × 1.2` 的 cut-through 场景未定义触发条件。验证阶段需要明确的 cut-through 判定逻辑才能测试。
2. **DMA_CH_TSN 公式保守**: `N_mac × max(N_cbs, 2)` 在 `MAC_COUNT=8`、`MTL_TX_QUEUES=8` 时推荐 16 通道，但 `DMA_CH_COUNT` 最大仅 32，8 MAC × 4 ch = 32 已达上限。边缘场景（8 MAC × 8 queue）下通道数不足，未定义仲裁降级策略。
3. **未定义带宽验证的激励模型**: 计算器有了，但验证计划未定义如何用 UVM 生成最坏情况流量（如 64B 短帧突发、全端口线速同时收发）来验证计算器结果。

**严重性**: 🟢 **Minor** — 公式框架正确，但验证激励和 corner case 需 EDR 阶段补充。

---

## 三、发现的问题汇总

| 问题 ID | 问题描述 | 严重程度 | 状态 | 归属文档 | 备注 |
|---------|---------|---------|------|---------|------|
| VER-PAD-001 | 未定义"黄金配置"验证子集，参数组合爆炸无回归收敛策略 | Critical | 待修复 | `ethernet_arch_spec.md` §1.4.4 | EDR 阶段必须定义 |
| VER-PAD-002 | PICS Yes/No 未映射到具体 test case ID，缺乏负面验证计划 | Major | 待修复 | `protocol_analysis.md` §8.2 + Arch Spec §10 | 影响协议合规认证 |
| VER-PAD-003 | 覆盖率目标（line/branch/FSM/assertion/functional/cross）完全未定义 | Critical | 待修复 | `ethernet_arch_spec.md` §6.4 | PAD Gate 关键缺失 |
| VER-PAD-004 | Formal 验证范围、模块、工具、责任人完全未定义 | Critical | 待修复 | 全文 | 车规 IP 必须有 Formal 计划 |
| VER-PAD-005 | TC4x erratum 缺乏具体 testcase 追溯表和防退化机制 | Major | 待修复 | `ethernet_arch_spec.md` §6.1~6.4 | 核心卖点需持续回归保障 |
| VER-PAD-006 | IEEE 1722 AVTP PICS 矩阵缺失 | Major | 待修复 | `protocol_analysis.md` §8.2 | P1 协议需完整 PICS |
| VER-PAD-007 | Switch cut-through 判定逻辑未定义，带宽计算器简化 | Minor | 待修复 | `ethernet_arch_spec.md` §4.4.2 | 影响性能验证激励设计 |
| VER-PAD-008 | DMA 通道上限场景（8 MAC × 8 queue）仲裁降级策略缺失 | Minor | 待修复 | `ethernet_arch_spec.md` §4.4.3 | 边界条件需明确 |
| VER-PAD-009 | 非法参数组合行为的验证计划缺失（clamp/报错/静默？） | Major | 待修复 | `ethernet_arch_spec.md` §1.4.2 | 安全相关 |
| VER-PAD-010 | ASIL 等级切换验证未定义（QM → ASIL-B → ASIL-C 安全机制渐变） | Major | 待修复 | `ethernet_arch_spec.md` §1.4.3 | FuSa 验证需求 |

---

## 四、推荐决策

| 决策项 | 推荐 | 理由 |
|--------|------|------|
| **PAD Gate 验证视角** | ❌ **不通过** | 3 项 Critical 问题（VER-PAD-001/003/004）未解决，验证计划不具备可执行性。 |
| **有条件通过的前提** | 实体 Yang 确认以下 EDR 阶段首批任务优先级 | 若 Critical 问题在 EDR 前两周内完成，可转为有条件通过。 |
| **EDR 进入条件补充** | 在现有 PAD Checklist 基础上，增加 **Verification Plan 评审通过** 作为 EDR 前置条件 | 当前 PAD Checklist 无验证视角检查项，需补充。 |

---

## 五、EDR 阶段需补充的 Verification Plan 内容

基于 `workflow/templates/docs/verification_plan.md` 模板，以下章节必须在 EDR 阶段首周内完成：

### 5.1 验证策略章节（Verification Strategy）

- **§2.1 验证方法矩阵**: 明确 UVM / Formal / FPGA / Emulation 的分工边界。
  - UVM: 功能、性能、协议合规
  - Formal: TAS 时序、DMA 无死锁、PTP monotonicity、Switch 仲裁公平性
  - FPGA: 温度循环、PLCA 时序、PHY 噪声注入
- **§2.2 黄金配置子集**: 从 §1.4.4 的 12 个场景中选取 **3~5 个黄金配置**作为 nightly regression 基线，其余做 smoke test。建议：
  - **GC-01**: 中央网关 4×GMAC/1G + 4-port Switch + TSN + gPTP（最复杂拓扑）
  - **GC-02**: ADAS 2×XGMAC/5G + 独立直连（最高带宽压力）
  - **GC-03**: 边缘节点 1×MAC/10M + 10BASE-T1S（最小配置，QM 安全）
  - **GC-04**: 混合网关 1×XGMAC/5G + 1×GMAC/1G + 2-port Switch（混合速率+Switch）
  - **GC-05**: 保守默认 2×GMAC/1G 无 Switch（门数最小，快速冒烟）

### 5.2 覆盖率计划章节（Coverage Plan）

- **§4.1 代码覆盖目标**:
  - Line: > 95%
  - Branch/Condition: > 90%
  - FSM: > 98%（关键状态机必须 100% 状态 + 转移覆盖）
  - Toggle: > 90%
- **§4.2 功能覆盖目标**:
  - `cg_mac_type_speed`: 覆盖所有 MAC_TYPE × MAC_SPEED 合法组合
  - `cg_phy_type_speed_duplex`: 覆盖 PHY_TYPE × PHY_SPEED × PHY_DUPLEX 组合
  - `cg_tsn_features`: 覆盖 SUPPORT_TSN × SUPPORT_CBS × SUPPORT_TAS × SUPPORT_FP
  - `cg_switch_config`: 覆盖 SWITCH_CONNECTED_MAC[0:7] 的接入/独立拓扑
  - `cg_asil_degradation`: 覆盖 ASIL_LEVEL=0/2/3 时的安全机制开关
  - `cg_errata_scenarios`: 每项 erratum 至少一个 coverpoint
- **§4.3 断言覆盖**:
  - 规划 > 200 条 SVA，目标 assertion coverage > 95%
  - 重点模块: PTP Timestamp (monotonicity)、DMA Descriptor Ring (无溢出)、TAS GCL (周期一致性)、Switch Crossbar (无冲突)、ECC (单/双 bit 正确检测)

### 5.3 PICS 追溯矩阵章节

- **§5.x PICS Traceability Matrix**: 新建章节，要求：
  - 每个 PICS Mandatory/Optional Yes 项 → 至少 1 个 test case ID
  - 每个 PICS No 项 → 至少 1 个 negative test case ID（验证正确拒绝/忽略）
  - 每个 Configurable 项 → 至少 2 个 test case ID（enable / disable 状态各一）
  - 缺失的 IEEE 1722 AVTP PICS 需在 EDR 首周内补齐

### 5.4 TC4x Erratum 回归测试章节

- **§6.x Erratum Regression Suite**: 新建章节，要求：
  - 建立 `erratum_regression_table.md`，13 项 erratum 每项包含：
    - Errata ID、标题、设计修改点、验证 testcase ID、激励条件、通过判据、断言检查、运行频率、负责人
  - 建议全部 13 项进入 **weekly regression**，其中 5 项 High 严重度进入 **nightly regression**：
    - GETH_AI.029 (CBS credit)
    - GETH_AI.032 (TAS IPG)
    - GETH_AI.036/039 (Underflow)
    - GETH_AI.037/040/041/042 (DMA stall)
    - LETH_TC.010 / LETH_AI.024 (PTP/Bridge timestamp)

### 5.5 Formal 验证计划章节

- **§7.x Formal Verification Plan**: 新建章节，要求：
  - 工具: JasperGold 或 VC Formal
  - 模块范围: TAS Scheduler、DMA Descriptor Controller、PTP Timestamp Engine、Switch Crossbar Arbiter、ECC Controller、CBS Credit Shaper
  - 属性类型: safety (assert) + liveness (cover)
  - 抽象策略: 对 AXI 总线使用 slave 抽象模型，对 PHY 使用 clocked bus functional model
  - 收敛标准: 每个模块 proof coverage > 95%，无 inconclusive 关键属性

### 5.6 安全验证章节（FuSa Verification）

- **§8.x Safety Verification**: 新建章节，要求：
  - ECC 故障注入: 单 bit 纠错、双 bit 检错、地址线故障
  - FSM Parity 故障注入: 状态跳转错误检测与 Safe State 收敛
  - Timeout 验证: CSR/DMA/Switch 超时触发与报警上报
  - ASIL 等级渐变验证: QM（全关）→ ASIL-B（ECC+Parity+Timeout）→ ASIL-C（+Bus Timeout）的正确渐变
  - 与 `Docs/FuSa/safety_concept.md` 的故障覆盖表对齐

---

## 六、交付物完整性检查

| 交付物 | 状态 | 备注 |
|--------|------|------|
| Architecture Specification (v1.8c) | ✅ 存在 | 内容完整，但验证视角章节缺失 |
| Protocol Analysis (v2.2) | ✅ 存在 | PICS 矩阵精简版可用，但 AVTP 缺失 |
| Safety Concept | ➡️ 引用 | `Docs/FuSa/safety_concept.md`，验证未审阅 |
| Interface Spec | ➡️ 引用 | `Docs/Arch/ethernet_interface_spec.md`，验证未审阅 |
| Clock/Reset Spec | ➡️ 引用 | `Docs/Arch/ethernet_clock_reset_spec.md`，验证未审阅 |
| **Verification Plan** | ❌ **缺失** | `Docs/Verification/ethernet_verification_plan.md` 若已存在，需按本评审意见重写 |
| **Coverage Plan** | ❌ **缺失** | `Docs/Verification/ethernet_coverage_plan.md` 若已存在，需按本评审意见补充 |
| **Testcase List** | ❌ **缺失** | 无 testcase ID 体系 |
| **Formal Verification Plan** | ❌ **缺失** | 全文未提及 |

---

## 七、实体 Yang 需重点检查项

1. **参数化架构的验证成本**: 35+ 参数 × 混合拓扑 × 多协议开关，验证工作量是否被低估？建议与 Verification Agent 共同评估资源需求。
2. **Formal 验证投入决策**: 是否接受在 EDR 阶段投入 Formal 验证资源（工具 license + 工程师）？这是 TAS/DMA/Switch 正确性的关键保障。
3. **PICS 认证路径**: 是否需要 OPEN Alliance TC8 或类似第三方认证？若需要，PICS 矩阵必须在 EDR 早期冻结。
4. **TC4x erratum 的核心卖点保护**: 13 项 erratum 规避是本项目相对 TC4x 的主要差异化优势，是否接受在 nightly regression 中持续验证这些规避措施的有效性？这会带来 ~15% 的回归时间开销。
5. **黄金配置子集的业务对齐**: 建议的 5 个黄金配置是否覆盖了主要出货场景？请确认是否有遗漏（如 10G 模式、ASIL-C 配置等）。

---

## 八、评审结论

| 检查维度 | 评分 | 说明 |
|---------|------|------|
| 交付物完整性 | ⚠️ 中 | Arch Spec 和 Protocol Analysis 存在且内容详实，但 Verification Plan / Coverage Plan / Formal Plan / Testcase List 缺失 |
| 内部一致性 | ✅ 高 | Arch Spec 参数与 PICS 映射一致，§10.6 验证表自洽 |
| 可追溯性 | ⚠️ 中 | PICS → Arch Spec 有映射，但 PICS → Testcase 无映射；erratum → testcase 无映射 |
| 质量底线 | ❌ 低 | 3 项 Critical + 4 项 Major 问题，验证可执行性严重不足 |
| 规范性 | ⚠️ 中 | 符合 Arch Spec 模板，但验证章节不符合 `workflow/templates/docs/verification_plan.md` 模板要求 |

**推荐决策**: **❌ 不通过**（验证视角）。

**前置条件**: 在 EDR 阶段首周内完成 VER-PAD-001~004 的修复（黄金配置子集、覆盖率目标、Formal 计划、PICS 追溯矩阵），并由 Verification Agent 重新评审通过后，方可视为验证视角达标。

---

*评审完成时间: 2026-05-21 17:38 GMT+8*  
*评审人: Verification Agent*  
*下次评审触发条件: EDR 阶段 Verification Plan v1.0 发布*
