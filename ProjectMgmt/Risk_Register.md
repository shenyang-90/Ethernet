# Ethernet IP 风险登记册 (Risk Register)

> **项目**: Ethernet IP (IP_20260502_001)  
> **阶段**: PAD 补完 / EDR 准备  
> **版本**: v1.0  
> **日期**: 2026-05-22  
> **作者**: PM Agent  
> **评审关联**: PAD Gate Review 2026-05-21 (checklist.md)  
> **决策基础**: 实体 Yang 2026-05-21 18:54 决策 — 全部 29 个问题关闭 + PAD 补完交付物到位后方可进入 EDR

---

## 1. 登记册说明

### 1.1 风险等级矩阵

|          | 影响低 (L) | 影响中 (M) | 影响高 (H) |
|----------|:----------:|:----------:|:----------:|
| **概率高 (H)** | **中** (H×L) | **高** (H×M) | **极高** (H×H) |
| **概率中 (M)** | **低** (M×L) | **中** (M×M) | **高** (M×H) |
| **概率低 (L)** | **极低** (L×L) | **低** (L×M) | **中** (L×H) |

### 1.2 概率定义

| 等级 | 定义 | 量化参考 |
|------|------|----------|
| **高 (H)** | 未来 3 个月内几乎必然发生 | > 70% |
| **中 (M)** | 未来 3~6 个月内可能发生 | 30% ~ 70% |
| **低 (L)** | 未来 6 个月内不太可能发生 | < 30% |

### 1.3 影响定义

| 等级 | 技术影响 | 进度影响 | 成本影响 |
|------|----------|----------|----------|
| **高 (H)** | 架构/RTL 重大返工，模块重构 | 阶段推迟 > 2 周 | 预算超支 > 20% |
| **中 (M)** | 局部设计修改，参数调整 | 阶段推迟 1~2 周 | 预算超支 10~20% |
| **低 (L)** | 文档更新，验证条目补充 | 阶段推迟 < 1 周 | 预算超支 < 10% |

### 1.4 跟踪状态定义

| 状态 | 说明 |
|------|------|
| 🟡 **已识别 (Identified)** | 风险已登记，缓解措施已制定，尚未触发 |
| 🟠 **监控中 (Monitoring)** | 风险指标持续跟踪，接近触发阈值 |
| 🔴 **已触发 (Triggered)** | 风险事件已发生，进入问题处理流程 |
| 🟢 **已关闭 (Closed)** | 风险消除或影响已降至可接受范围 |
| ⚪ **已接受 (Accepted)** | 风险影响可控，不采取额外缓解措施 |
| ⬜ **降级 (N/A)** | 经项目决策，风险项不再适用 |

---

## 2. 风险条目

---

### RISK-001: Switch Core 复杂度风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-001 |
| **描述** | Switch Core 将 4-port L2/L3 交换、8K FDB 自学习、TAS 门控调度 (GCL)、FRER 序列号管理、VLAN 转发、Crossbar 全并发仲裁全部集成于单一模块。Arch Spec §4.3 估算 N=8 时 Switch Core 逻辑约 **90 kGE**、SRAM 约 **250 KB**；整个 IP 中央网关扩展配置 (Config-D) 达 **~280 kGE / ~210 KB SRAM**。该复杂度可能导致：(a) RTL 编码周期超预期；(b) 模块级验证覆盖率难以收敛；(c) 后端布局布线拥塞；(d) 时序闭合困难 (300 MHz @ clk_mac)。 |
| **概率** | **中 (M)** — 当前 4-port 微架构已产出 (FDB/仲裁器)，但 N=8 扩展路径仅参数化声明，未验证综合可行性 |
| **影响** | **高 (H)** — 若 N=8 综合面积或时序不达标，需架构级拆分 (如 FDB→独立 SRAM 控制器、Crossbar→多级) 或降级 Switch 功能，属重大架构返工 |
| **风险等级** | **高 (M×H)** |
| **缓解措施** | 1. **架构级拆分预案**: 若综合面积 > 100 kGE (N=4) 或 > 200 kGE (N=8)，启动 Switch Core 子模块物理隔离 (FDB/VLAN/L3/TAS 各为独立模块，保留 Crossbar 集中仲裁)  
2. **分阶段综合验证**: EDR 阶段完成 N=4 RTL 综合面积/时序预评估 (目标: ≤ 40 kGE 逻辑 + ≤ 100 KB SRAM)，通过后方可扩展 N=8  
3. **功能降级开关**: 定义 `SWITCH_LITE_MODE` 参数，关闭 L3/Switch_TAS/FRER 时将面积降至 ~60%  
4. **面积监控 Checklist**: IDR 阶段每个 RTL 模块提交时强制附综合面积报告 |
| **责任人** | Arch Agent (架构拆分预案) / RTL_Coding_Agent (综合面积评估) / Backend Agent (布局布线预评估) |
| **跟踪状态** | 🟡 **已识别** |
| **关联 Gate Review 问题 ID** | RTL-CRIT-001 (FDB 微架构空白 → 已关闭), RTL-CRIT-002 (仲裁算法缺失 → 已关闭), Arch Major M-1 (MACsec/EEE/AVTP 并集决策语义不一致), RTL Major M-1~2 (无时序约束目标、无 AXI outstanding/QoS) |
| **触发条件** | EDR 阶段 N=4 RTL 综合面积 > 100 kGE 或 clk_mac 时序裕量 < 10% |
| **升级路径** | 触发 → 召开架构评审会议 → Arch Agent 48h 内输出拆分方案 → 实体 Yang 决策 |

---

### RISK-002: SRAM 面积与宏选型风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-002 |
| **描述** | FDB 单表 (8K 条目, 2-way SA, ECC) 即需 **~84 KB SRAM** (2×4K×84-bit 双端口宏)。Arch Spec v1.8c §4.3 原 Switch Core SRAM 预算仅为 **16 KB** (FDB+VLAN+L3+TAS GCL 合计)，与实际 FDB ~84 KB 差距 **5×**。整个 IP N=8 配置总 SRAM 达 **~210 KB**。工艺节点未确定 (28nm? 22nm? 16nm?)，SRAM 宏供应商 (TSMC / GF / SMIC) 和硬 IP 可用性直接影响面积、功耗和时序。若所选工艺节点无适配的 2R1W 双端口 SRAM 宏，需改用寄存器堆或单端口宏分时复用，面积/性能代价显著。 |
| **概率** | **高 (H)** — 工艺节点未定 + SRAM 预算低估 5× 为确定性矛盾，几乎必然在 RTL→综合阶段暴露 |
| **影响** | **高 (H)** — SRAM 宏选型错误可导致面积超预算 > 30%、时序无法闭合 (单端口分时复用引入 2× 查表延迟)、功耗超标 |
| **风险等级** | **极高 (H×H)** |
| **缓解措施** | 1. **SRAM 预算修正**: Arch Spec 下一版本 (v1.8d/v1.9) 将 Switch Core SRAM 预算从 16 KB 修正为 **~128 KB** (FDB 84K + VLAN 8K + L3 16K + TAS GCL 16K + 余量)，总 IP SRAM 预算修正为 **~220 KB**  
2. **工艺节点锁定**: IDR 阶段启动前必须锁定目标工艺节点 (建议 28nm 或 22nm，兼顾成本与车规成熟度)  
3. **SRAM 宏预评估**: EDR 阶段委托后端/Foundry 提供 2R1W SRAM 宏 datasheet (4K×84, 8K×84, 16K×84 三种深度)，评估面积/时序/功耗  
4. **替代方案备案**: 若 2R1W 不可用，准备 (a) 2× 单端口宏乒乓切换 或 (b) 伪双端口 (1R1W + shadow bank) 方案，评估面积/性能折中  
5. **ECC 宏复用**: 与 Safety Agent 协同，确保 SECDED ECC wrapper 与 SRAM 宏硬 IP 兼容，避免软核 ECC 面积惩罚 |
| **责任人** | Arch Agent (预算修正) / PM Agent (工艺节点锁定排期) / RTL_Coding_Agent (SRAM 替代方案 RTL 原型) |
| **跟踪状态** | 🔴 **已触发** — SRAM 预算低估已在 FDB 微架构评审中确认，需立即修正 |
| **关联 Gate Review 问题 ID** | RTL-CRIT-001 (FDB 微架构 → 已关闭, 但暴露面积预算问题), Arch Major M-1 (并集决策语义), RTL Major M-1 (无时序约束), PM-001 (Interface Spec 版本滞后) |
| **触发条件** | 已触发 — FDB microarch.md 明确标注 "Arch Spec §4.3 估算需升级" |
| **升级路径** | 已触发 → Arch Agent 在 EDR 启动前输出 Arch Spec v1.8d 修正 SRAM 预算 → 后端/Foundry 同步提供 SRAM 宏评估 |

---

### RISK-003: 验证收敛与组合爆炸风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-003 |
| **描述** | 本 IP 支持 **35+ 可配置参数** (MAC_COUNT 1~8, MAC_x_TYPE 0~2, MAC_x_SPEED 0~5, PHY_x_TYPE 0~3, SWITCH_PORT_COUNT 2~8, 协议开关 10+ 个等)。完整参数空间组合为天文数字。虽已定义 **5 个黄金配置** 作为 nightly regression 基线，但：(a) 5 个配置无法覆盖 corner case 组合；(b) 每个配置需要模块级 (UT) + 子系统级 (IT) + 系统级 (ST) 三层验证，时间开销巨大；(c) 35+ 参数的非法组合约束验证 (negative test) 尚未系统化；(d) **Formal 验证已决策不投入**，复杂协议属性 (TAS 时序单调性、DMA 无死锁、PTP 同步边界) 缺乏静态证明，依赖仿真穷尽度有限。 nightly regression 若无法 < 12h 完成，将阻塞快速迭代。 |
| **概率** | **高 (H)** — 35+ 参数 + 3 层验证 × 5 配置 = 至少 15 个验证环境构建任务，nightly regression 时间超预算概率 > 70% |
| **影响** | **中 (M)** — 验证收敛延迟可导致 EDR→IDR 阶段边界推迟 1~2 周，但不会引发架构返工 |
| **风险等级** | **高 (H×M)** |
| **缓解措施** | 1. **黄金配置分层回归**:  
   - Tier-1 (Nightly, < 8h): 2 个核心配置 (最小 + 中央网关)  
   - Tier-2 (Weekly, < 24h): 3 个扩展配置 (ADAS + 安全 + 边缘)  
   - Tier-3 (Milestone): 参数组合 smoke test (仅编译 + 基本连通性)  
2. **参数化验证环境**: UVM 环境支持 `parameter` 传递，单个 testbench 通过重编译覆盖多种配置，避免复制 5 套独立环境  
3. **覆盖率智能采样**: 对 35+ 参数采用 **pair-wise / n-wise** 组合采样策略 (如 PICT 工具)，而非全组合  
4. **Formal 降级补偿**: 虽 Formal 不投入，但在 UVM 中增加 **SVA 断言密度** 以覆盖关键属性 (TAS GCL 单调性、DMA 描述符无泄漏、FDB 查表 2-cycle 约束)  
5. **FPGA 加速**: 对长时间稳定性测试 (erratum 回归、PLCA 时序) 使用 FPGA 原型加速 10~100×  
6. **回归时间门控**: 设定 nightly regression 硬性时限 (12h)，超时自动触发 "配置裁剪" 评审 |
| **责任人** | Verification Agent (验证策略/环境/回归) / Arch Agent (参数合法组合约束定义) |
| **跟踪状态** | 🟡 **已识别** |
| **关联 Gate Review 问题 ID** | VERIF-CRIT-001 (黄金配置缺失 → 已关闭), VERIF-CRIT-002 (覆盖率目标缺失 → 已关闭), VERIF-CRIT-003 (Formal 范围未定义 → **降级为 N/A / 项目决策不投入**), Verification Major M-1~5 (PICS 未映射 testcase / erratum 防退化 / AVTP PICS 缺失 / 非法参数组合 / ASIL 切换验证) |
| **触发条件** | Nightly regression 首次运行 > 12h 或 Tier-1 覆盖率 < 80% |
| **升级路径** | 触发 → Verification Agent 48h 内输出回归优化方案 (参数采样 / FPGA 加速 / 断言增补) → 实体 Yang 决策是否追加资源 |

---

### RISK-004: EDA 工具链与人才资源风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-004 |
| **描述** | 项目涉及车规级芯片全流程：(a) **前端**: 复杂 TSN/Switch 协议 RTL 编码 + UVM 验证环境搭建，需熟练 SystemVerilog + 协议栈知识人才；(b) **后端**: 28nm/22nm 车规工艺 P&R、时序闭合、SI/PI 分析，需 3~5 年后端经验；(c) **FuSa**: ISO 26262 ASIL-B→D 升级路径、FMEDA、FTA，需功能安全认证经验；(d) **Formal 不投入后的验证覆盖缺口**: 原计划的 JasperGold/VC Formal 静态验证已取消，复杂并发属性 (DMA 无死锁、TAS 时序边界) 需依赖 UVM + SVA 补偿，验证工程师技能要求更高。当前项目计划仅有角色分配比例，**无具体人天估算**，资源缺口难以量化。 |
| **概率** | **中 (M)** — 车规 EDA + FuSa 复合人才市场稀缺，但项目初期可用外部咨询/培训补充 |
| **影响** | **高 (H)** — 关键岗位人才缺口可导致 IDR/FDR 阶段阻塞，FuSa 认证延迟直接影响车规量产时间 |
| **风险等级** | **高 (M×H)** |
| **缓解措施** | 1. **人天估算立即补充**: IDR 阶段准入条件 — PM Agent 输出 WBS 到工作包级人天估算 (`effort_estimate.md`)，验证排期可行性  
2. **外部资源预案**:  
   - 后端: 与 Foundry/Turnkey 合作 (如 GUC / Faraday 提供 P&R 服务)  
   - FuSa: 聘请第三方认证机构 (SGS TÜV / DEKRA) 进行差距分析和认证辅导  
   - 验证: 若 UVM 环境搭建延迟，评估外包给验证服务公司 (如 VeriSilicon / Andes)  
3. **内部培训加速**: EDR 阶段安排 2 周 TSN 协议栈培训 (802.1AS/Qbv/Qbu/CB) + 1 周车规流程培训 (ISO 26262 + AEC-Q100)  
4. **Formal 缺口专项**: Verification Agent 在 verification plan 中新增 "SVA 密集型验证" 章节，明确用断言替代 Formal 的模块清单和覆盖率目标  
5. **技能矩阵跟踪**: 建立团队技能矩阵表，每月更新，缺口 > 20% 时启动外部招聘/外包 |
| **责任人** | PM Agent (人天估算/资源计划) / 实体 Yang (外部资源审批) / Verification Agent (SVA 补偿方案) |
| **跟踪状态** | 🟡 **已识别** |
| **关联 Gate Review 问题 ID** | PM-006 (风险登记册缺失 → 本文件), PM OBS-002 (人力估算完全缺失), VERIF-CRIT-003 (Formal 不投入), FuSa Major M-4 (ASIL 分解独立性分析缺失) |
| **触发条件** | IDR 阶段 WBS 人天估算显示任一技能缺口 > 30% 或 EDR 验证环境搭建延迟 > 1 周 |
| **升级路径** | 触发 → PM Agent 72h 内输出资源缺口报告 → 实体 Yang 决策外部资源投入 |

---

### RISK-005: 工艺节点未确定风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-005 |
| **描述** | 目标工艺节点至今 **未确定** (候选: 28nm / 22nm / 16nm)。该不确定性阻塞多项下游工作：(a) **SRAM 宏选型**: 不同工艺节点的 SRAM 宏供应商、位单元面积、读写裕量差异巨大；(b) **时序闭合策略**: 28nm 典型 fmax ~500 MHz (逻辑), 22nm ~700 MHz, 16nm ~1.2 GHz，但 300 MHz clk_mac 在所有节点均轻松闭合，真正的挑战在于 AXI 总线 (500 MHz) 和 PHY 接口 (625 MHz for 5G USXGMII) 的 I/O 时序；(c) **功耗预算**: 28nm 漏电较高，22nm FD-SOI 可体偏压调节，16nm FinFET 漏电最低但 IP 授权成本高；(d) **车规认证**: 28nm 车规成熟度最高 (TSMC 28HPC+ 有完整 AEC-Q100 数据), 22nm FD-SOI 车规数据较少, 16nm 车规 IP 授权周期长。工艺节点每推迟 2 周决定，IDR 启动推迟 1 周。 |
| **概率** | **高 (H)** — 工艺节点为 SoC 级决策，Ethernet IP 为子系统，通常被动等待 SoC 决策，推迟概率 > 70% |
| **影响** | **高 (H)** — 阻塞 SRAM 宏选型、后端流程启动、功耗 signoff，影响 EDR→IDR 阶段切换 |
| **风险等级** | **极高 (H×H)** |
| **缓解措施** | 1. **多工艺基线并行**: EDR 阶段同时基于 28nm 和 22nm 两套工艺库进行综合面积预评估 (RTL 工艺无关，只需替换 SRAM 宏模型 + 标准单元库)，确保无论最终节点如何决策，RTL 代码均兼容  
2. **SRAM 宏抽象层**: RTL 中 SRAM 实例通过 wrapper 封装 (`sram_2r1w_wrapper.sv`)，工艺相关部分 (foundry SRAM 宏 + ECC wrapper) 集中在该模块，切换工艺时仅替换此文件  
3. **工艺决策 deadline**: 设定硬性 deadline — **IDR 启动前 2 周必须锁定工艺节点**，否则 IDR 启动推迟  
4. **候选供应商预沟通**: PM Agent 在 EDR 阶段联系 TSMC (28HPC+), GF (22FDX), SMIC (28nm) 获取车规 SRAM 宏初步报价和交付周期  
5. **功耗模型多节点化**: Arch Spec 功耗估算章节补充 28nm/22nm/16nm 三节点对比，供 SoC 架构师决策参考 |
| **责任人** | PM Agent (工艺决策跟踪 / 供应商沟通) / Arch Agent (多工艺基线 RTL 策略) / Backend Agent (SRAM 宏评估) |
| **跟踪状态** | 🟠 **监控中** — 工艺节点为 SoC 级决策，当前被动等待，需推动 deadline 设定 |
| **关联 Gate Review 问题 ID** | RTL Major M-1 (无时序约束目标 — 根因之一为工艺未定), Arch Major M-3 (erratum 规避表遗漏), PM OBS-003 (EDR 21 天排期可能不足) |
| **触发条件** | IDR 启动前 2 周工艺节点仍未锁定 |
| **升级路径** | 触发 → 实体 Yang 直接推动 SoC 架构决策 → 若 SoC 未定，采用 28nm 作为保守基线先行启动 IDR |

---

### RISK-006: 竞品迭代与需求漂移风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-006 |
| **描述** | 竞品 (Infineon TC4x GETH / NXP S32G PFE / NXP S32K3 / Renesas R-Car S4) 持续迭代，feature 并集可能扩大。当前 Arch Spec v1.8c 已基于全部平台 feature 并集定义，但：(a) TC4x 下一代 (TC4xy?) 可能新增 10G MAC / TSN 增强 / 安全加速器升级；(b) S32G 后续型号可能扩展 Switch 端口数；(c) 客户 SoC 需求可能在 EDR/IDR 阶段提出新 feature (如时间敏感网络与 PCIe 融合、AI 加速器接口)。需求漂移将导致：(1) Arch Spec 重新修订；(2) 已完成的微架构 (FDB/仲裁器) 不适用；(3) 验证计划范围扩大；(4) 进度/成本超支。 |
| **概率** | **中 (M)** — 车规以太网 IP 市场相对稳定，但 2026~2027 年 TSN 标准化加速期，新增协议修正案 (802.1Qdd / 802.1Q ++) 概率 30~50% |
| **影响** | **中 (M)** — 局部需求调整可通过参数化吸收，但大规模 feature 新增将导致 2~4 周返工 |
| **风险等级** | **中 (M×M)** |
| **缓解措施** | 1. **版本冻结窗口**: EDR 启动后 Arch Spec 进入 **变更控制 (Change Control)**，任何修改需走 CR (Change Request) 流程，评估影响后由实体 Yang 审批  
2. **参数化预留**: 当前 35+ 参数架构已预留大部分扩展空间 (如 MAC_COUNT 1~8, SPEED 0~5)，新需求优先通过参数化实现而非架构变更  
3. **竞品监控机制**: 每季度更新一次竞品 feature 矩阵 (TC4x/S32G/R-Car 新发布 datasheet)，评估是否需纳入下一阶段 (FDR/POST)  
4. **需求基线锁定**: IDR 启动前与 SoC 产品经理签署需求基线 (Requirements Baseline)，明确 IDR 后不接受新 P0 需求  
5. **向后兼容承诺**: Arch Spec 承诺所有 v1.8c 参数在后续版本中保持兼容，新增参数通过 `SUPPORT_XXX` 开关隔离，不影响已有验证环境 |
| **责任人** | Arch Agent (版本冻结 / CR 流程) / PM Agent (竞品监控 / 需求基线管理) |
| **跟踪状态** | 🟡 **已识别** |
| **关联 Gate Review 问题 ID** | Arch Major M-1 (MACsec/EEE/AVTP "并集决策" 语义不一致 — 根因之一为并集范围模糊), Arch Major M-2 (802.1Qbu/Qci/Qcb 升级到 P0 缺少需求追溯), PM-001 (Interface Spec 版本滞后) |
| **触发条件** | SoC 产品经理提出 IDR 后新 P0 需求 或 竞品发布颠覆性新 feature |
| **升级路径** | 触发 → Arch Agent 48h 内输出 CR 影响评估 → 实体 Yang 决策是否接受 |

---

### RISK-007: 安全认证 (FuSa) 升级路径风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-007 |
| **描述** | 当前 Safety Concept v1.1 定义 **ASIL-B 基线**，声称 "可升级至 C/D"，但该升级路径 **未经验证**：(a) ASIL-B → ASIL-D 需满足 ISO 26262-5 硬件度量指标 (SPFM ≥ 99%, LFM ≥ 90%)，当前 ECC/Parity/Timeout 组合是否能达标缺乏 FMEDA 量化计算；(b) **FuSa Agent Review M-3**: DC (Diagnostic Coverage) 量化缺乏计算依据 — 除 ECC 外 7 项安全机制均无 DC 计算过程；(c) **FuSa Agent Review M-4**: ASIL 分解缺乏 ISO 26262-9 独立性分析 — 未声明分解元素间的独立性等级 D；(d) **FuSa Agent Review M-8**: Arch Spec §8.1 "Lockstep (可选)" 与 Safety Concept §5.3 "不内嵌 Lockstep" 矛盾；(e) 部分安全机制标注 "**待 EDR 验证**" (如 EEE LPI 唤醒 Timeout 的 FHTI 分析、CSS/HSE 接口故障模式)。ASIL-D 若无法达标，将限制本 IP 在最高安全等级域控制器中的应用。 |
| **概率** | **中 (M)** — ASIL-B 基线当前可达，但 ASIL-D 升级路径的 FMEDA 计算复杂，独立性和 DC 达标概率 40~60% |
| **影响** | **高 (H)** — 若 ASIL-D 无法达标，需额外投入 Lockstep CPU 集成、冗余总线、SMU 联动等系统级安全机制，属重大架构变更 |
| **风险等级** | **高 (M×H)** |
| **缓解措施** | 1. **FMEDA 立即启动**: FuSa Agent 在 EDR 阶段输出初版 FMEDA (基于 ASIL-B 基线)，量化 SPFM/LFM/DC，明确 ASIL-D 差距  
2. **DC 量化补完**: 针对 M-3 问题，每个安全机制 (CSR Shadow/Parity/Timeout/FSM Parity/时钟监控等) 补充 DC 计算依据和故障注入覆盖率目标  
3. **ASIL 分解独立性分析**: 针对 M-4 问题，输出 ISO 26262-9 要求的独立性分析报告，证明各 FSC (Functional Safety Concept) 分解元素满足独立性等级 D  
4. **Lockstep 矛盾解决**: 针对 M-8 问题，统一决策 — 要么 Arch Spec 删除 "Lockstep (可选)" 声明，要么 Safety Concept 升级包含 Lockstep 集成方案  
5. **分阶段认证**: 先追求 ASIL-B 认证 (IDR 阶段完成 FMEDA 初版)，FDR 阶段评估 ASIL-C/D 升级可行性，避免一次性追求 D 导致进度失控  
6. **第三方预审**: FDR 阶段前聘请 TÜV / DEKRA 进行 FuSa 差距分析 (Gap Analysis)，提前发现认证 blocker |
| **责任人** | FuSa Agent (FMEDA / DC 量化 / ASIL 分解分析) / Arch Agent (Lockstep 矛盾统一) / PM Agent (第三方认证机构预约) |
| **跟踪状态** | 🟠 **监控中** — 多项 FuSa Major 问题待 EDR 阶段关闭，M-3/M-4/M-8 为关键路径 |
| **关联 Gate Review 问题 ID** | FUSA-PAD-001 (新增参数安全影响 → 已关闭), FuSa Major M-3 (DC 量化缺乏依据), FuSa Major M-4 (ASIL 分解缺乏独立性分析), FuSa Major M-8 (Lockstep 声明矛盾), FuSa Major M-2 (PHC 故障模式), FuSa Major M-5 (FHTI WCA 缺失), FuSa Major M-6/M-7 (参数化安全机制遗漏) |
| **触发条件** | EDR 阶段 FMEDA 初版显示 SPFM < 99% 或 LFM < 90% (ASIL-D 阈值) |
| **升级路径** | 触发 → FuSa Agent 72h 内输出 ASIL-D 差距分析报告 → 实体 Yang 决策: (a) 接受 ASIL-C 目标 或 (b) 追加 Lockstep/冗余机制 |

---

### RISK-008: 项目 Schedule 与 PAD 补完工作量风险

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-008 |
| **描述** | PAD 补完工作量显著超预期。原计划 PAD 阶段 15 天 (5/11-5/25)，实际 Gate Review 发现 **29 个问题** (8 Critical + 23 Major + 18 Minor)，新增 **10 个 Rework 任务** (TASK-PAD-REWORK-001 ~ 010)。截至目前 **6/10 已完成**，剩余 4 个任务 (Arch Major M-1~3、RTL Major M-1~7、FuSa Major M-2~8、PM Minor PM-001~006) 分布在多个 Agent。EDR 原计划 21 天 (5/26-6/15)，需完成 Design Spec + Verification Plan + DFT Spec + FuSa Analysis + 4 个 Gate Review 修复，未经验证工作量估算。Arch Spec 在 5/11-5/21 的 10 天内历经 **8 次版本迭代** (v1.0→v1.8c)，迭代密度 0.8 版本/天，暴露初期需求定义不充分。若 PAD 补完推迟至 6/5 之后，EDR 压缩至 < 10 天，IDR 启动将整体推迟。 |
| **概率** | **高 (H)** — 剩余 4 个 rework 任务涉及跨 Agent 协作，且 EDR 排期未经验证，推迟概率 > 70% |
| **影响** | **高 (H)** — EDR/IDR 整体推迟 2~4 周，影响芯片 Tapeout 时间表 |
| **风险等级** | **极高 (H×H)** |
| **缓解措施** | 1. **剩余任务并行化**:  
   - Arch Agent + RTL Agent 并行修复 Major 问题 (Arch M-1~3 与 RTL M-1~7 无依赖)  
   - FuSa Agent 独立推进 M-2~8 (与 RTL 修复无硬依赖)  
   - PM Agent 同步修复 Minor (版本对齐/风险登记册/人力估算)  
2. **EDR 任务优先级重排**: 将 EDR 任务分为 **Must-Have** (Design Spec 更新 + Verification Plan 维护) 和 **Nice-to-Have** (DFT Spec 详细化)，Must-Have 优先保障  
3. **排期重新基线**: PM Agent 在风险登记册完成后 48h 内输出修订版 `schedule.md`，基于实际 rework 耗时重新估算 EDR/IDR 排期  
4. **每日站会机制**: PAD 补完阶段引入每日 15min 同步 (异步飞书消息)，阻塞问题 4h 内升级至实体 Yang  
5. **IDR 准入条件弹性化**: 若 PAD 补完 6/5 仍未完成，允许 "有条件进入 EDR" — 已完成交付物先行移交 EDR，剩余修复在 EDR 阶段并行进行 (风险: EDR 输入基线不稳定)  
6. **版本冻结规则**: EDR 启动后 Arch Spec 进入冻结，任何修改必须走 CR，防止 0.8 版本/天的迭代密度再现 |
| **责任人** | PM Agent (排期重基线 / 站会 / 任务跟踪) / 各 Agent (并行修复各自 Major) / 实体 Yang (弹性准入决策) |
| **跟踪状态** | 🟠 **监控中** — 6/10 rework 已完成，剩余 4 任务进度每日跟踪 |
| **关联 Gate Review 问题 ID** | PM-001~006 (全部 6 个 Minor), Arch Major M-1~3, RTL Major M-1~7, FuSa Major M-2~8, PM OBS-003 (EDR 21 天排期不足), PM OBS-004 (排期表甘特图偏差) |
| **触发条件** | PAD 补完任一任务 > deadline 2 天 或 EDR 启动日 (5/26) 仍有未关闭交付物 |
| **升级路径** | 触发 → PM Agent 立即召开排期紧急评审 → 实体 Yang 决策: (a) 压缩 EDR 范围 或 (b) 推迟 IDR 启动 |

---

### RISK-009: 接口与时钟规范版本滞后风险 *(补充登记)*

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-009 |
| **描述** | Interface Spec (v1.0, 2026-05-11) 和 Clock/Reset Spec (v1.0, 2026-05-11) 自 5/11 后 **未再更新**，而 Arch Spec 在同日历经 8 次重大修订 (Switch/PHC/vPHC/DMA 全局池/erratum/全平台并集)。新增参数 (`SWITCH_CONNECTED_MAC_x[]`, `PHC_COUNT=2`, `vPHC` 寄存器, `PHY_x_DUPLEX`, `SUPPORT_EEE`, `SUPPORT_IPSEC` 等) 未在 Interface/Clock 文档中登记。下游 Design Agent 和 RTL Coding Agent 可能基于过时的接口/时钟定义展开工作，导致 RTL 编码阶段的信号名/位宽/时钟域错误，引发 EDR→IDR 边界返工。 |
| **概率** | **高 (H)** — 两个 Spec 已滞后 10+ 天，Arch Spec 新增 15+ 个参数未同步，下游误用概率 > 70% |
| **影响** | **中 (M)** — 信号/时钟域错误通常在 RTL 综合或验证阶段暴露，局部修改即可，但涉及多个模块时需 3~5 天协调修复 |
| **风险等级** | **高 (H×M)** |
| **缓解措施** | 1. **立即升级至 v1.1**: Arch Agent 在 EDR 启动前 (最晚 5/25) 输出 Interface Spec v1.1 和 Clock/Reset Spec v1.1，对齐 Arch Spec v1.8c 全部新增参数  
2. **交叉检查清单**: PM Agent 编制 "Arch Spec 新增参数 → Interface/Clock 映射表"，逐项确认每个新增参数在 Interface/Clock 中有对应信号/时钟定义  
3. **RTL 编码前基线审查**: IDR 启动前强制审查 Interface Spec 版本号，若 < v1.1 则阻塞 RTL 编码启动  
4. **版本联动机制**: 建立 Arch Spec → Interface Spec → Clock/Reset Spec → Design Spec 的版本联动规则，主文档升级时依赖文档必须同步升级或明确标注 "待更新" |
| **责任人** | Arch Agent (Spec 升级) / PM Agent (交叉检查 / 映射表) / RTL_Coding_Agent (RTL 编码前基线审查) |
| **跟踪状态** | 🟠 **监控中** — PM-001 已识别，列为 EDR 初期必须完成项 |
| **关联 Gate Review 问题 ID** | PM-001 (Interface/Clock-Reset Spec 版本严重滞后), PM-002 (Arch Spec 版本历史不完整), PM-003 (Protocol Analysis 缺失版本历史), PM-004 (Design Spec 引用版本不匹配) |
| **触发条件** | EDR 启动时 Interface Spec / Clock-Reset Spec 仍为 v1.0 |
| **升级路径** | 触发 → 阻塞 RTL 编码启动 → Arch Agent 72h 内输出 v1.1 → 实体 Yang 审批 |

---

### RISK-010: 新增参数安全影响持续演化风险 *(补充登记)*

| 字段 | 内容 |
|------|------|
| **风险 ID** | RISK-010 |
| **描述** | Arch Spec v1.8c 新增 7 个可配置参数 (`SUPPORT_EEE`, `SUPPORT_AVTP`, `SUPPORT_AVTP_CTL`, `SUPPORT_IPSEC`, `SUPPORT_SECOC`, `SUPPORT_DTLS`, `PHY_x_DUPLEX`)，其安全影响已在 Safety Concept v1.1 (PAD-REWORK-005) 中初步评估并定义了安全状态路径。但：(a) 这些参数在 EDR/IDR 阶段可能引入新的故障模式 (如 `SUPPORT_IPSEC` 开启时 CSS 加速器接口超时导致的安全 PDU 泄漏)；(b) 部分参数的故障处理时间间隔 (FHTI) 和故障响应时间 (FRTI) 尚未量化；(c) 参数化安全机制 (如 `ECC_ENABLE` / `PARITY_ENABLE`) 与新增参数的交互未完全分析。若新增参数在 IDR 后仍有变更，FuSa 文档需同步迭代，可能导致认证基线漂移。 |
| **概率** | **中 (M)** — 新增参数安全路径已初步定义，但 FHTI/FRTI 量化通常在 RTL 完成后才能精确计算，存在中期调整概率 40~60% |
| **影响** | **中 (M)** — FuSa 文档更新和验证条目补充，预计 3~5 天工作量，不阻塞 RTL 编码 |
| **风险等级** | **中 (M×M)** |
| **缓解措施** | 1. **参数安全影响矩阵维护**: FuSa Agent 维护 `parameter_safety_impact_matrix.md` 为活文档，每次 Arch Spec 参数变更时同步更新  
2. **FHTI/FRTI 分阶段量化**: EDR 阶段输出 "目标 FHTI/FRTI 范围" (如 10~50 ms)，IDR 阶段 RTL 实现后精确到 cycle 级  
3. **新增参数验证覆盖**: Verification Agent 在验证计划中定义每个新增参数的故障注入 testcase (如 EEE LPI 超时、IPSec CSS 超时、AVTP 流识别错误)  
4. **参数冻结 deadline**: IDR 启动后所有 `SUPPORT_XXX` 参数默认值和范围冻结，任何变更需走 FuSa CR |
| **责任人** | FuSa Agent (安全影响矩阵 / FHTI 量化) / Verification Agent (故障注入 testcase) / Arch Agent (参数变更控制) |
| **跟踪状态** | 🟡 **已识别** |
| **关联 Gate Review 问题 ID** | FUSA-PAD-001 (新增参数安全影响评估 → 已关闭), FuSa Major M-5 (FHTI WCA 缺失), FuSa Major M-6/M-7 (参数化安全机制遗漏), Verification Major M-5 (ASIL 切换验证未定义) |
| **触发条件** | IDR 阶段新增参数引入未预见的故障模式或 FHTI 实测值超出目标范围 2× |
| **升级路径** | 触发 → FuSa Agent 24h 内输出影响评估 → 实体 Yang 决策是否调整参数默认值或安全状态路径 |

---

## 3. 风险统计汇总

| 风险等级 | 数量 | 风险 ID |
|----------|:----:|---------|
| **极高** | 2 | RISK-002 (SRAM 面积), RISK-008 (Schedule) |
| **高** | 4 | RISK-001 (Switch Core 复杂度), RISK-003 (验证收敛), RISK-004 (人才资源), RISK-007 (FuSa 认证), RISK-009 (接口版本滞后) |
| **中** | 2 | RISK-006 (竞品迭代), RISK-010 (参数安全演化) |
| **低** | 0 | — |
| **极低** | 0 | — |

**已登记风险总数**: **10 项** (满足 ≥ 8 项要求)

| 跟踪状态 | 数量 | 风险 ID |
|----------|:----:|---------|
| 🟡 已识别 | 4 | RISK-001, RISK-003, RISK-004, RISK-006, RISK-010 |
| 🟠 监控中 | 3 | RISK-005, RISK-007, RISK-008, RISK-009 |
| 🔴 已触发 | 1 | RISK-002 |
| 🟢 已关闭 | 0 | — |
| ⚪ 已接受 | 0 | — |
| ⬜ 降级 | 0 | — |

---

## 4. 与 Gate Review 问题清单联动矩阵

| Gate Review 问题 ID | 问题描述 | 关联风险 ID | 风险责任人 | 问题状态 |
|--------------------|----------|------------|-----------|----------|
| RTL-CRIT-001 | FDB/L3 查表微架构完全缺失 | RISK-001, RISK-002 | RTL_Coding_Agent | ✅ 已关闭 |
| RTL-CRIT-002 | Egress 仲裁算法缺失 | RISK-001 | RTL_Coding_Agent | ✅ 已关闭 |
| RTL-CRIT-003 | vPHC Xen IO Ring 无硬件接口定义 | RISK-001 | RTL_Coding_Agent | ✅ 已关闭 |
| RTL-CRIT-004 | `SWITCH_PORT_COUNT` 2~8 与 Design Spec 固定 4 端口矛盾 | RISK-001, RISK-008 | Arch Agent | ✅ 已关闭 |
| FUSA-PAD-001 | 新增参数安全影响完全未评估 | RISK-007, RISK-010 | FuSa Agent | ✅ 已关闭 |
| VERIF-CRIT-001 | 未定义黄金配置 - 参数组合爆炸 | RISK-003 | Verification Agent | ✅ 已关闭 |
| VERIF-CRIT-002 | 覆盖率目标完全未定义 | RISK-003 | Verification Agent | ✅ 已关闭 |
| VERIF-CRIT-003 | Formal 验证范围完全未定义 | RISK-003, RISK-004 | Verification Agent | ⬜ 降级 N/A |
| Arch Major M-1 | MACsec/EEE/AVTP "并集决策" 语义不一致 | RISK-001, RISK-006 | Arch Agent | ⬜ 待处理 |
| Arch Major M-2 | 802.1Qbu/Qci/Qcb 升级到 P0 缺少需求追溯 | RISK-006 | Arch Agent | ⬜ 待处理 |
| Arch Major M-3 | §6 erratum 规避表遗漏 GETH_AI.028/030 | RISK-005 | Arch Agent | ⬜ 待处理 |
| RTL Major M-1~7 | 无时序约束、AXI outstanding/QoS、PLCA 时钟域等 | RISK-001, RISK-005 | RTL Agent | ⬜ 待处理 |
| FuSa Major M-3 | DC 量化缺乏计算依据 | RISK-007 | FuSa Agent | ⬜ 待处理 |
| FuSa Major M-4 | ASIL 分解缺乏 ISO 26262-9 独立性分析 | RISK-007 | FuSa Agent | ⬜ 待处理 |
| FuSa Major M-8 | Arch Spec "Lockstep (可选)" 与 Safety Concept "不内嵌" 矛盾 | RISK-007 | Arch Agent + FuSa Agent | ⬜ 待处理 |
| PM-001 | Interface/Clock-Reset Spec 版本滞后 | RISK-009 | Arch Agent | ⬜ 待处理 |
| PM-002 | Arch Spec 版本历史不完整 | RISK-009 | Arch Agent | ⬜ 待处理 |
| PM-003 | Protocol Analysis 缺失版本历史 | RISK-009 | Arch Agent | ⬜ 待处理 |
| PM-004 | Design Spec 引用版本不匹配 | RISK-009 | RTL Agent | ⬜ 待处理 |
| PM-005 | Safety Concept 版本不一致 | RISK-007 | FuSa Agent | ⬜ 待处理 |
| PM-006 | 风险登记册缺失 | — | PM Agent | ✅ 本文件关闭 |

---

## 5. 项目宏观风险 (源于 project_plan.md)

| # | 风险项 | 原登记位置 | 严重程度 | 状态 | 是否纳入本登记册 |
|---|--------|-----------|:-------:|:----:|:----------------:|
| 1 | TSN 协议栈复杂度高，协议间交叉依赖 | `project_plan.md` §6 | 高 | 🟡 已识别 | ✅ 分解为 RISK-001/RISK-003 |
| 2 | IEEE 标准文档学习周期长 | `project_plan.md` §6 | 中 | 🟡 已识别 | ✅ 分解为 RISK-004 |
| 3 | 竞品分析数据来源受限 | `project_plan.md` §6 | 中 | 🟡 已识别 | ✅ 分解为 RISK-006 |
| 4 | 半双工 CRS/CD 时钟域未定义 | Interface/Clock Spec | — | 未登记 | ✅ 纳入 RISK-009 |
| 5 | EEE RTL 模块划分缺失 | Design Spec 下游 | — | 未登记 | ✅ 纳入 RISK-001/RISK-010 |
| 6 | Security IF 物理接口未定义 | 会议共识 #3 | — | 未登记 | ✅ 纳入 RISK-009/RISK-010 |
| 7 | 35+ 参数组合爆炸 | Verification Agent | — | 未登记 | ✅ 纳入 RISK-003 |

---

## 6. 风险评审与维护

### 6.1 评审周期

| 评审类型 | 频率 | 参与人 |
|----------|------|--------|
| **日常监控** | 每日站会 (15min 异步) | 各 Agent |
| **周度评审** | 每周五 17:00 | PM Agent + 各 Agent Lead |
| **阶段关口评审** | 每个 Gate Review 前 | 全部 Agent + AI Yang + 实体 Yang |
| **紧急评审** | 风险触发时 4h 内 | 相关 Agent + PM Agent + 实体 Yang |

### 6.2 维护规则

1. **新增风险**: 任何 Agent 发现新风险时，24h 内提交 PM Agent，PM Agent 48h 内完成风险评估并更新本登记册
2. **风险状态更新**: 责任人每周五更新风险状态，PM Agent 汇总
3. **风险关闭**: 满足以下条件方可关闭:
   - 触发条件已消除 或
   - 缓解措施已实施且影响降至低等级 或
   - 项目决策明确接受该风险
4. **版本控制**: 本登记册随项目阶段迭代，版本号规则: v{大版本}.{小版本}，大版本对应阶段切换 (PAD→EDR→IDR→FDR)

---

## 7. 版本历史

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|----------|
| **v1.0** | 2026-05-22 | PM Agent | 初始创建。登记 10 项风险，覆盖 Switch Core 复杂度、SRAM 面积、验证收敛、人才资源、工艺节点、竞品迭代、FuSa 认证、Schedule、接口版本滞后、参数安全演化。关联全部 29 个 Gate Review 问题。 |

---

*登记册路径*: `ProjectMgmt/Risk_Register.md`  
*关联文档*: `ProjectMgmt/Phases/PAD/Reviews/checklist.md`, `ProjectMgmt/Planning/project_plan.md`, `ProjectMgmt/Planning/schedule.md`  
*维护人*: PM Agent  
*下次评审*: 2026-05-26 (EDR 启动前)
