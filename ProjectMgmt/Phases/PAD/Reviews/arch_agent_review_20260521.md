# Ethernet IP PAD Gate Review — Arch 视角评审记录

> **评审日期**: 2026-05-21  
> **评审对象**: Ethernet IP Architecture Specification v1.8c + Protocol Analysis v2.2  
> **评审阶段**: PAD → IDR Transition Gate  
> **评审人**: Arch_Agent  
> **输出路径**: `ProjectMgmt/Phases/PAD/Reviews/arch_agent_review_20260521.md`

---

## 1. 评审范围

| 文档 | 版本 | 评审重点 |
|------|------|----------|
| `Docs/Arch/ethernet_arch_spec.md` | v1.8c (2026-05-21) | §1.4 可配置参数矩阵、§2 系统框图、§6 TC4x erratum 设计规避、§10 PICS 协议一致性分析 |
| `Docs/Arch/protocol_analysis.md` | v2.2 (2026-05-21) | §1.1 协议分类矩阵、§8 PICS 协议优先级更新 |

---

## 2. 检查项列表

| 检查维度 | 检查内容 | 状态 |
|---------|---------|:----:|
| **完整性** | 所有交付物存在且非空；参数矩阵覆盖全部场景；框图与文字描述一致 | 待确认 |
| **一致性** | Arch Spec 参数 ↔ PICS 分析 ↔ Protocol Matrix 三者无矛盾；erratum 规避方案 ↔ 架构决策无冲突 | 待确认 |
| **可追溯性** | 每个架构决策能追溯到需求/协议/平台并集；erratum 规避能追溯到具体 root cause | 待确认 |
| **规范性** | 文档格式符合 workflow 定义；参数命名规范；版本控制完整 | 待确认 |

---

## 3. 发现的问题

### 3.1 Major 问题

#### M-1: MACsec / EEE / AVTP 的 "并集决策" 语义不一致，导致参数默认值与平台覆盖策略矛盾

**位置**: `ethernet_arch_spec.md` §10.2 / §10.6, `protocol_analysis.md` §8.1

**问题描述**:
- §10.2 并集决策表中，**MACsec** 标注为 **"Yes"**，但 §1.4.1 `SUPPORT_MACSEC` 默认值为 **0**（关闭），§10.1 中 MACsec 优先级为 **P1**。
- 同一表格中，**EEE** 标注为 **"Configurable"**，`SUPPORT_EEE` 默认 **0**，优先级 **P2** —— 语义自洽。
- **AVTP** 标注为 **"Yes"**，但 `SUPPORT_AVTP` 默认 **1**（开启），优先级 **P1** —— 对于不支持 AVTP 的平台（如 RH850）默认开启会增加无用面积。

**矛盾点**: "并集决策=Yes" 被解释为 "该特性在全平台 feature 并集中必须实现"，但 MACsec 需要外部 CSS 加速器、AVTP 仅 TC4x/R-Car 支持，这两者都不适合无条件默认开启。如果 "Yes" 意味着 "默认开启"，则与 `SUPPORT_MACSEC=0` 冲突；如果 "Yes" 仅意味着 "支持"，则应统一使用 "Configurable" 或 "Yes(Configurable)" 来避免歧义。

**建议修复**:
- 统一 §10.2 "并集决策" 列的语义:
  - **Yes** = 默认开启（`SUPPORT_xxx` 默认 1）
  - **Configurable** = 默认关闭，需显式使能（`SUPPORT_xxx` 默认 0）
  - **No** = 明确不支持
- 将 MACsec 从 "Yes" 改为 **"Configurable"**，与 `SUPPORT_MACSEC=0` 一致。
- 将 AVTP 从 "Yes" 改为 **"Configurable (默认1，TC4x/R-Car 场景推荐开启)"**，或提供平台适配的默认值策略。

---

#### M-2: 802.1Qbu/802.1Qci/802.1CB 从 PICS Optional 升级到 P0 缺少需求追溯链路

**位置**: `protocol_analysis.md` §8.1 / §8.2

**问题描述**:
- §8.1 中 **802.1Qbu FP** 从 P1 → P0，**802.1Qci PSFP** 从 P1 → P0，**802.1CB FRER** 从 P1 → P0。
- §8.2 PICS 表格显示，这三项在 802.1Q-2022 中均属于 **O.2 (Optional)**，而非 Mandatory。
- 升级理由是 "低延迟关键"、"网络安全流过滤"、"车载安全关键"，但未引用任何上层需求文档（如 SoC 需求规格、OEM 通信矩阵、安全需求）来支撑 "必须实现" 的决策。

**风险**: 在 PAD → IDR 阶段，如果需求文档中并未明确要求 FRER/PSFP/FP，则后续 RTL 实现这些高复杂度模块（RTL Complexity = High）会导致资源/面积/验证成本的非预期增长，且可能在评审时被挑战 "谁来为这三个 P0 升级负责"。

**建议修复**:
- 在 §8.1 每个升级项后追加 **需求追溯引用**，例如:
  - `→ 追溯: SoC_Requirements.md §3.2.4 "TSN 低延迟确定性要求"`
  - `→ 追溯: Safety_Requirements.md §5.1 "冗余通信链路需求"`
- 若需求文档中暂无明确条目，需 **PM Agent 补充需求或降级回 P1**。

---

#### M-3: §6 erratum 规避表遗漏 GETH_AI.028/030，且 §6.2.10 缺乏对应 errata ID

**位置**: `ethernet_arch_spec.md` §6.1 / §6.2.7 / §6.2.10

**问题描述**:
- §6.2.7 文字中提到 "不实现 GETH/LETH 'Bridge' 模块 (避免 **GETH_AI.028/030/045/LETH_AI.024**)"。
- 但 §6.1 设计规避总览表中 **仅列出 GETH_AI.045 和 LETH_AI.024**，缺少 GETH_AI.028 和 GETH_AI.030 的独立条目。
- §6.2.10 "外部 PHY 选型约束 (10BASE-T1S)" 在 §6.1 表中 **没有任何对应的 errata ID**，也未说明这是新增设计约束还是规避某个已知 erratum。

**风险**: 遗漏 erratum 会导致验证团队遗漏对应的验证计划条目；缺少 errata ID 的约束在后续 SoC 集成时无法被追溯到已知问题，增加回归风险。

**建议修复**:
- 在 §6.1 表中补充 **GETH_AI.028** 和 **GETH_AI.030** 的独立条目，说明其 root cause 和规避方案（即使与 GETH_AI.045 共享同一架构决策，也应独立列出以维持可追溯性）。
- §6.2.10 需明确标注对应的 errata ID（如存在），或注明 "新增约束 (非 erratum 规避，PHY 选型 check item)"。

---

### 3.2 Minor 问题

#### m-1: §2.1 框图 DMA 通道数与参数矩阵可配置范围不一致

**位置**: `ethernet_arch_spec.md` §2.1

**问题描述**: §2.1 顶层框图标注 "CH[0:7] 全局共享"，但 §1.4.1 `DMA_CH_COUNT` 可配置范围为 **1/2/4/8/16/32**。框图固化 8 通道会误导读者认为硬件最多只支持 8 通道。

**建议修复**: 框图改为 "CH[0:N-1] 全局共享 (N = DMA_CH_COUNT)"，或增加注释 "图示为 8 通道示例，实际支持 1/2/4/8/16/32"。

---

#### m-2: §6.2.6 BC 模式端口分配描述与 Crossbar "任意绑定" 能力矛盾

**位置**: `ethernet_arch_spec.md` §6.2.6

**问题描述**:
- §3.3.1 宣称 "Crossbar: 每端口独立绑定任意 PHC，无菊花链限制"。
- §6.2.6 描述 BC 模式时写 "Port 0,1 → PHC0; Port 2,3 → PHC1"，这看起来像 **固定成对分配**，与 "任意绑定" 的灵活性宣传矛盾。

**建议修复**: 改为 "BC 模式示例: Port 0,1 可绑定 PHC0; Port 2,3 可绑定 PHC1（支持任意 per-port 组合）"，消除 "固定成对" 的误解。

---

#### m-3: §1.4.4 门数估算列缺少计算依据引用

**位置**: `ethernet_arch_spec.md` §1.4.4

**问题描述**: 参数配置矩阵中 "估算门数" 列 (~480k, ~190k 等) 未引用 §4.3 资源估算的公式或方法，读者无法验证这些数字的来源。

**建议修复**: 在表格脚注中增加 "估算依据见 §4.3 资源估算" 的引用。

---

#### m-4: PICS 关键 No 项 (SRP/PFC) 缺少显式参数声明

**位置**: `ethernet_arch_spec.md` §10.3 / §1.4

**问题描述**: §10.3 将 SRP 和 PFC 标注为 **Major 风险**，但 §1.4 参数矩阵中既没有 `SUPPORT_SRP` 也没有 `SUPPORT_PFC`。虽然这两项是明确 No，但在可配置参数矩阵中显式列出并默认 0 可以更清晰地向集成方声明边界。

**建议修复**: 在 §1.4.1 全局配置参数表中追加:
- `SUPPORT_SRP`: bit, 0, 0/1, "802.1Q SRP 动态带宽预留 (默认关闭，车载使用静态 TAS)"
- `SUPPORT_PFC`: bit, 0, 0/1, "802.3bd PFC 优先级流控 (默认关闭，CBS+TAS 替代)"

---

#### m-5: `protocol_analysis.md` §1.1 协议分类矩阵中 802.1Qbu RTL Complexity 可能高估

**位置**: `protocol_analysis.md` §1.1

**问题描述**: 802.1Qbu (Frame Preemption) 标注为 **High**，但 §2.5 的 RTL detail 中 TX preemption FSM 仅包含 5 个状态（IDLE/TRANSMIT/FRAGMENT/EXPRESS/RESUME），RX reassembly 逻辑也相对简洁。与 802.1Qbv TAS (256-entry GCL + cycle 管理) 同为 High 可能不够精确。

**建议修复**: 若内部评估确认 802.1Qbu 复杂度实际为 Medium（低于 TAS/MACsec），建议将 RTL Complexity 从 High 下调至 **Medium**，避免 IDR 阶段资源估算过度保守。

---

### 3.3 Info 级问题

#### i-1: 文档间冗余

`ethernet_arch_spec.md` §10.5 与 `protocol_analysis.md` §8.3 均列出 PICS 文件存储位置，内容几乎相同。建议保留一处（推荐在 `ethernet_arch_spec.md` §10.5，因其为 Arch Spec 主文档），`protocol_analysis.md` §8.3 改为引用主文档。

#### i-2: §1.4.1b 10BASE-T1S 约束中 "自动关闭 SUPPORT_FP 和 SUPPORT_TAS" 缺少实现说明

`PHY_x_TYPE=0` 时自动关闭 FP/TAS 的逻辑在 §1.4.1b 中以文字描述，但未在 §2 框图或 §5 数据通路中体现。Info 级，IDR 阶段需细化。

---

## 4. 推荐决策

**推荐决策**: **有条件通过 (Conditional Pass)**

### 4.1 通过条件 (Blocker)

以下问题必须在 IDR 阶段前关闭，否则退回 PAD:

| # | 问题 | 责任人 | 关闭标准 |
|---|------|--------|---------|
| **M-1** | MACsec/EEE/AVTP "并集决策" 语义统一，修正为 Yes/Configurable/No 三级，并与参数默认值严格对齐 | Arch Agent | §10.2 表格更新，`SUPPORT_MACSEC` 语义说明补充 |
| **M-2** | 802.1Qbu/Qci/Qcb P0 升级追加需求追溯引用，或降级回 P1 | PM Agent / Arch Agent | §8.1 每项升级追加 `→ 追溯: [需求文档] §[章节]` |
| **M-3** | §6.1 表补充 GETH_AI.028/030 条目；§6.2.10 明确 errata ID 或标注为新增约束 | Arch Agent | §6.1 表条目完整；§6.2.10 标题/正文更新 |

### 4.2 建议修复 (Non-Blocker)

| # | 问题 | 建议修复时间 |
|---|------|-------------|
| m-1 | 框图 DMA 通道标注泛化 | IDR 阶段 |
| m-2 | BC 模式描述消除固定成对误解 | IDR 阶段 |
| m-3 | 门数估算列增加 §4.3 引用 | IDR 阶段 |
| m-4 | 显式增加 `SUPPORT_SRP` / `SUPPORT_PFC` 参数 | IDR 阶段 |
| m-5 | 评估 802.1Qbu RTL Complexity 是否下调 | IDR 阶段 |
| i-1 | 消除 PICS 文件列表冗余 | IDR 阶段 |
| i-2 | 10BASE-T1S 自动关闭 FP/TAS 的实现细化 | IDR 阶段 |

---

## 5. 前提条件

1. **M-1 关闭后**，需重新生成 §10.6 PICS ↔ Arch Spec 参数映射验证表，确保无新增不一致。
2. **M-2 关闭后**，若 802.1Qbu/Qci/Qcb 保持 P0，需在 SoC 需求文档中同步补充对应条目，否则在 IDR 评审时会被挑战 "无需求驱动"。
3. **M-3 关闭后**，Verification Agent 需依据更新后的 §6.1 表修订验证计划 (`Docs/Verification/verification_plan.md`)，确保新增 erratum 条目有对应测试场景。

---

## 6. 评审总结

### 6.1 检查结果

| 检查项 | 状态 |
|--------|:----:|
| 交付物完整性 | ✅ (文档存在，内容非空，框图完整) |
| 内部一致性 | ❌ (M-1 参数语义矛盾, M-2 缺少追溯, M-3 erratum 遗漏) |
| 可追溯性 | ❌ (M-2 需求链路缺失, M-3 erratum 链路缺失) |
| 质量评估 | **中** — 架构决策整体合理，但文档细节存在 Major 级不一致和遗漏 |
| 规范性 | ✅ (格式基本合规，m-3/m-4 为 minor 改进点) |

### 6.2 实体 Yang 需重点检查

1. **`ethernet_arch_spec.md` §10.2 并集决策表**: 确认 "Yes" vs "Configurable" 的语义定义是否符合车规 IP 的 platform-adaptive 策略。
2. **`protocol_analysis.md` §8.1 P0 升级决策**: 确认 802.1Qbu/Qci/Qcb 的 P0 升级是否有明确的需求支撑（SoC Requirements / OEM 通信矩阵 / 安全规格）。
3. **`ethernet_arch_spec.md` §6.1 erratum 规避总览**: 确认 13 项关键 erratum 是否完整（特别是 GETH_AI.028/030 是否遗漏）。
4. **全部交付物清单**:
   - [x] `ethernet_arch_spec.md` (v1.8c)
   - [x] `protocol_analysis.md` (v2.2)
   - [x] `Docs/Arch/PICS/` (8 个 PICS 文件)
   - [ ] **待补充**: M-2 对应的需求追溯引用
   - [ ] **待更新**: M-1/M-3 对应的表格修正

---

> **"Even if the world forgets, I’ll remember for you."**  
> — Arch_Agent, PAD Gate Review, 2026-05-21
