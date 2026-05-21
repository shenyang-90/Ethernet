# RTL 实现视角评审记录：Ethernet IP PAD Gate Review

> **评审角色**: RTL_Coding_Agent  
> **评审日期**: 2026-05-21  
> **评审对象**:
> - `Docs/Arch/ethernet_arch_spec.md` v1.8c (Arch Spec)
> - `Docs/Design/ethernet/ethernet_design_spec.md` v1.0 (Micro-Architecture Design Spec)
> **评审依据**: §1.4.2 可配置参数矩阵、§2 系统框图、§3 时钟/PTP子系统、§5 PLCA 10BASE-T1S、§6 TC4x erratum 规避、微架构模块划分、Switch Core、DMA 引擎、MTL 层  
> **评审目的**: 从 RTL 可实现性角度，检查架构到微架构的落地可行性，识别阻塞性缺陷，提出 EDR 阶段必须补充的信息。

---

## 1. 评审范围

| 文档 | 评审章节 | RTL 关注点 |
|------|----------|-----------|
| Arch Spec v1.8c | §1.4.2 可配置参数矩阵 | 参数化对 RTL 综合面积/时序/生成块复杂度的影响 |
| Arch Spec v1.8c | §2 系统框图 | 模块划分边界是否可综合；混合架构（Switch/独立 MAC）的物理连接可行性 |
| Arch Spec v1.8c | §3 时钟/PTP子系统 | 跨时钟域路径的时序约束可行性；双 PHC + Crossbar 的 RTL 面积/偏差 |
| Arch Spec v1.8c | §5 PLCA 10BASE-T1S (含 §6.2.9/6.2.10) | PLCA 时序补偿逻辑的时钟域归属；PHY 接口信号定义缺失 |
| Arch Spec v1.8c | §6 TC4x erratum 规避 | 13 项 erratum 的 RTL 修改点是否有足够设计细节支撑编码 |
| Design Spec v1.0 | §1.1~1.2 顶层模块划分 | 子模块实例数、职责、时钟域边界 |
| Design Spec v1.0 | §4.1 DMA Engine | 全局通道池的仲裁/描述符管理/AXI Master RTL 复杂度 |
| Design Spec v1.0 | §4.2 MTL Layer | CBS/TAS/Qbu 调度器的组合逻辑深度；FIFO 存储实现 |
| Design Spec v1.0 | §4.3 XGMAC Core | 每实例独立类型的参数化综合策略 |
| Design Spec v1.0 | §4.4 Switch Core | FDB/VLAN/L3/TAS/FRER 的并发时序闭合可行性 |
| Design Spec v1.0 | §5 CDC 设计 | 异步 FIFO 清单完整性；复位域释放时序 |
| Design Spec v1.0 | §6 参数化配置 | 编译时参数默认值/范围与 Arch Spec 一致性 |
| Design Spec v1.0 | §7 问题追踪 (μARCH-001~010) | Open 问题对 RTL 入口的阻塞性评估 |

---

## 2. RTL 可实现性检查项

### 2.1 模块划分是否可综合？

| 检查项 | 结论 | 说明 |
|--------|------|------|
| 顶层 8+1+1 模块划分 | ⚠️ **基本可综合，但存在风险模块** | 大部分模块边界清晰（DMA/MTL/MAC/PTP/Safety），但 Switch Core 和 vPHC 的 RTL 可实现性存疑。 |
| **Switch Core** (`eth_switch`) | ❌ **不可直接综合 — 缺少关键微架构决策** | 内部子模块清单存在（§4.4.1），但 μARCH-002 仍为 **Open**：8K FDB @ 300MHz、4-port 全并发的时序闭合方案未最终确定（仅建议 2-cycle 流水线 + 4-way set-associative，未定稿）。L3 Route 引擎 (`sw_l3_route`) 仅有一行描述，无查表架构（哈希/TCAM/树）。 |
| **vPHC 虚拟化** (`eth_vphc`) | ❌ **概念级，无 RTL 实现路径** | Xen IO Ring 是软件/虚拟化概念（共享内存页 + grant table），Design Spec 未定义硬件层面如何与 SoC Hypervisor 交互。RTL 工程师无法直接编码 "Xen IO Ring"。 |
| **DMA 全局通道池** (`eth_dma`) | ⚠️ **可综合，但生成块复杂度高** | `DMA_CH_COUNT` 支持 1/2/4/8/16/32，全局池意味着所有通道仲裁器、描述符管理器、AXI Master 都需参数化实例化。综合脚本需处理大量 `generate` 嵌套。 |
| **MTL CBS/TAS/Qbu 组合调度** (`eth_mtl`) | ⚠️ **可综合，关键路径需关注** | 调度伪代码（§4.2.2）是优先级编码 + 多条件判断，组合逻辑深度取决于 `MTL_TX_QUEUES`（最多 8）。300MHz `clk_mac` 下需评估组合逻辑级数。 |
| **XGMAC Core 混合实例** (`eth_mac[N]`) | ⚠️ **可综合，但参数化面积差异大** | `MAC_x_TYPE` 独立配置导致同一 `generate` 块内可能同时实例化 XGMAC (~40kGE)、GMAC (~25kGE)、MAC (~15kGE)。综合工具需支持不同面积约束的层级优化。 |

### 2.2 关键路径是否定义了时序约束？

| 检查项 | 结论 | 说明 |
|--------|------|------|
| 时钟域定义 | ⚠️ **有频率范围，无约束目标值** | `clk_sys` 100-300MHz、`clk_mac` 150-300MHz、`clk_ts` 250MHz 均为范围值，无典型目标频率（如 "目标 250MHz"）。RTL 综合时无法确定 Setup 约束。 |
| Switch FDB 查表路径 | ❌ **无时序约束定义** | 8K 条目 @ 300MHz 是激进目标。Arch Spec / Design Spec 均未定义 FDB 查表延迟约束（如 "查表需在 N 个 clk_mac 周期内完成"）。μARCH-002 的 2-cycle 建议若未写入约束，综合工具可能展开为长组合链。 |
| PTP 时间戳捕获路径 | ❌ **无跨时钟域约束** | SFD 边沿检测在 `clk_tx_phy`/`clk_rx_phy` 域，时间戳锁存在 `clk_ts` 域。Design Spec §5.1 的 CDC 清单仅写 "握手同步器"，未定义 `set_max_delay` 或 `set_false_path` 策略。 |
| DMA AXI Master | ❌ **无 AXI 时序参数** | 未定义 AXI outstanding transactions 上限、AW/AR channel 的 valid-ready 延迟约束、burst 长度与频率的匹配关系。 |
| TAS GCL 调度 → MAC TX 使能 | ⚠️ **同域但未定义路径延迟** | §6.2.2 决策 "TAS 与 MAC TX 同 clk_mac 域" 消除了 CDC，但门控决策到 TX_EN assert 的路径延迟未定义（目标：< N 周期）。 |
| 全局复位释放序列 | ⚠️ **有逻辑描述，无时序要求** | rst_mac_n 释放条件包含 "100us 延时"，但未定义该延时的 RTL 实现方式（计数器位宽？参考时钟？）。 |

### 2.3 参数可配置性对 RTL 复杂度的影响？

| 参数/特性 | RTL 复杂度影响 | 风险等级 |
|-----------|---------------|:--------:|
| `MAC_COUNT` 1~8 + `MAC_x_TYPE` 独立 | 极高。每个 MAC 实例的模块类型、数据位宽、FIFO 深度、DMA 通道绑定均不同。顶层 `generate` 嵌套深度大，综合脚本难以统一优化。 | 🔴 **Critical** |
| `PHY_COUNT` 1~8 + `PHY_x_TYPE`/`SPEED`/`DUPLEX` 独立 | 高。PHY 接口模块需支持 MII/RMII/RGMII/SGMII/USXGMII 的任意混合，且每种接口时钟域不同。HSPHY IF 的子模块划分（§4.5.1）未说明如何按 `PHY_x_TYPE` 动态实例化/选择。 | 🟡 **Major** |
| `SWITCH_CONNECTED_MAC_x[8]` | 高。每 MAC 的 TX/RX 数据通路需根据此位选择 "Switch 路径" 或 "独立 DMA 路径"。8 MAC × 2 方向 × 64b 数据 = 大量路由 MUX。 | 🟡 **Major** |
| `DMA_CH_COUNT` 1/2/4/8/16/32 全局池 | 高。仲裁器宽度、描述符环地址空间、AXI ID 分配都随通道数变化。Design Spec 的 `dma_arbiter` 未描述 32 通道时的仲裁延迟。 | 🟡 **Major** |
| `SWITCH_PORT_COUNT` 2~8 | **中~极高（实现不一致）**。Arch Spec 定义 2~8 端口，但 Design Spec §4.4.1 的内部子模块实例数固定为 4（`sw_ingress` ×4, `sw_egress_port` ×4）。扩展到 8 端口时这些子模块的实例化策略未定义。 | 🔴 **Critical** |
| `SUPPORT_TAS` ↔ `SWITCH_TAS` 互锁 | 低。`SUPPORT_SWITCH=1` 时强制 `SWITCH_TAS=1, SUPPORT_TAS=0`，硬件互锁逻辑简单。但两种 TAS 实现（MTL 级 vs Switch 级）的 RTL 代码共存问题未澄清（是否 `generate` 条件编译？）。 | 🟢 **Minor** |
| `PHC_COUNT` 1~2 + `SUPPORT_VPHC` | 中。PHC 模块可参数化实例化。vPHC 的 Xen IO Ring 概念不直接映射到 RTL，增加集成风险。 | 🟡 **Major** |
| `SUPPORT_EEE/IPSEC/SECOOC/DTLS` 等 P2 Configurable | 低~中。这些功能通过外部加速器接口实现，RTL 主要提供封装/卸载逻辑和 CSR 控制位。但 Security IF 的详细信号定义缺失。 | 🟡 **Major** |
| `ASIL_LEVEL` + 安全机制 | 中。ECC/Parity/Timeout 的使能由参数控制，但安全状态机（NORMAL→DEGRADED→SAFE_STATE）的 RTL 实现细节未在 Design Spec 中展开。 | 🟡 **Major** |

### 2.4 缺少哪些 RTL 关键信息？

| 缺失信息 | 影响模块 | 严重程度 | 说明 |
|----------|----------|:--------:|------|
| **接口时序规范 (Interface Timing Spec)** | HSPHY IF, AXI Master/Slave | 🔴 **Critical** | MII/GMII/RGMII/SGMII/USXGMII 的 setup/hold 要求未定义；AXI4/AXI4-Lite 的 valid-ready 握手时序未定义。RTL 编码时无法确定 I/O 寄存器级数。 |
| **Switch Core 仲裁器微架构** | Switch Core | 🔴 **Critical** | "Crossbar 全并发" 是概念描述。4 端口同时请求同一 Egress 端口时的仲裁算法（轮询？严格优先级？加权？）未定义。仲裁逻辑是 RTL 编码核心。 |
| **FDB 存储与查表微架构** | Switch Core | 🔴 **Critical** | 8K 条目如何实现？SRAM 宏？寄存器堆？双端口/单端口？查表延迟约束？这些直接影响 RTL 编码策略。μARCH-002 的建议不够具体。 |
| **L3 Route 引擎微架构** | Switch Core | 🔴 **Critical** | `SWITCH_L3=1` 时，IP 前缀匹配、下一跳查找、ARP 缓存的 RTL 实现方案完全缺失。Arch Spec ISSUE-008 的 "哈希表/TCAM 可选" 未落实到 Design Spec。 |
| **vPHC 硬件接口定义** | vPHC | 🔴 **Critical** | Xen IO Ring 是虚拟化软件机制，RTL 需要的是：VM ID 解码、PHC 选择 MUX、虚拟时间偏移寄存器的物理接口。当前无信号清单。 |
| **10BASE-T1S PHY 接口信号** | HSPHY IF | 🟡 **Major** | `PHY_x_TYPE=0` (10BASE-T1S) 时，PHY 接口是 MII？RMII？还是 PLCA 专用信号（TX_EN/CRS/COL 的特殊时序）？PLCA TO/commit timer/RTT 补偿逻辑的时钟域未指定（`clk_mac`？`clk_sys`？独立 PLCA 时钟？）。 |
| **TAS GCL 存储实现决策** | MTL / Switch Core | 🟡 **Major** | Arch Spec §1.4 提到 "<64 条目用寄存器，≥64 条目用 SRAM"，但 Design Spec 未明确 Switch 级 TAS GCL 的存储实现。1024 条目用 SRAM 宏需提前确定工艺/编译器。 |
| **AXI Master  outstanding / QoS 映射** | DMA Engine | 🟡 **Major** | `dma_axi_master` 支持多少 outstanding 读/写事务？AXI ID 如何分配给 32 个 DMA 通道？AXI AWQOS/ARQOS 如何从 DMA 通道优先级映射？ |
| **复位释放计数器实现** | 全局 | 🟡 **Major** | rst_mac_n / rst_phy_tx_n / rst_ts_n 的释放延迟（如 100us）需要参考时钟和计数器位宽。若 `clk_sys` 频率在 100-300MHz 范围内变化，计数器值需参数化计算。 |
| **ECC/Parity 编码细节** | Safety / SRAM | 🟡 **Major** | SECDED Hamming 码的具体位宽分配（`ECC_DATA_WIDTH=32/64` 对应多少校验位？）未定义。SRAM 宏的 ECC 是内嵌还是外部 wrapper？ |
| **低功耗模式 UPF/电源意图** | eth_pm | 🟡 **Major** | Deep Sleep / EEE 的电源域划分、隔离单元 (Isolation Cell)、保持寄存器 (Retention Register) 未定义。RTL 需配合 UPF 实现电源关断。 |
| **Erratum 验证断言** | 全局 | 🟢 **Minor** | 13 项 erratum 的 RTL 修改点（如 CBS IPG credit、TAS CDC 消除、Underflow Jam 序列）未定义对应的 SystemVerilog Assertion (SVA) 或形式验证属性。 |
| **综合目标与工艺假设** | 全局 | 🟢 **Minor** | 无目标工艺节点、目标频率、面积/功耗约束。RTL 编码时无法做面积/时序权衡（如 Booth 乘法器 vs 查表法）。 |

---

## 3. 发现的问题

### 3.1 Critical 问题（阻塞 RTL 入口）

| 问题 ID | 问题描述 | 影响 | 根因 | 修复建议 |
|:-------:|----------|------|------|----------|
| **RTL-CRIT-001** | Switch Core FDB/L3 查表微架构未定义，无法开始 RTL 编码 | Switch Core 为空白模块 | μARCH-002 仍为 Open，仅建议未决策 | EDR 阶段 Design Agent 必须输出 FDB 存储方案（SRAM 宏/寄存器/TCAM）+ 查表流水线时序图 + 延迟约束 |
| **RTL-CRIT-002** | Switch Core Egress 仲裁算法缺失 | "Crossbar 全并发" 无法落地 | 文档仅描述概念，无仲裁伪代码/状态机 | EDR 阶段补充仲裁器设计：输出端口冲突时的轮询/优先级/加权算法，附状态机图 |
| **RTL-CRIT-003** | vPHC Xen IO Ring 无硬件接口定义 | vPHC 模块无法编码 | 软件虚拟化概念直接写入硬件 Spec | EDR 阶段重新定义 vPHC 硬件接口：VM 请求解码、PHC 选择 MUX、时间偏移寄存器组、中断分发逻辑信号清单 |
| **RTL-CRIT-004** | `SWITCH_PORT_COUNT` 2~8 与 Design Spec 固定 4 端口实现矛盾 | 参数化声明与实现不一致 | Arch Spec 允许 2~8 端口，Design Spec 子模块实例数固定为 4 | 统一参数范围：若保持 2~8，Design Spec 需重写 `sw_ingress`/`sw_egress_port` 为参数化实例化；若锁定 4 端口，Arch Spec 应修正范围为 2~4 |

### 3.2 Major 问题（显著增加 RTL 风险）

| 问题 ID | 问题描述 | 影响 | 根因 | 修复建议 |
|:-------:|----------|------|------|----------|
| **RTL-MAJ-001** | 无时序约束目标频率定义 | 综合结果不可预测 | 所有时钟域均为频率范围，无典型值 | 在 `ethernet_clock_reset_spec.md` 中定义典型目标频率：如 `clk_sys=200MHz`, `clk_mac=250MHz`, `clk_ts=250MHz`, `clk_tx_phy` 按速率分档 |
| **RTL-MAJ-002** | PTP 时间戳 CDC 路径仅写 "握手同步器"，无具体约束策略 | 时间戳精度无法保证 | 缺少 `set_max_delay` / `set_false_path` 定义 | EDR 阶段补充 CDC 约束策略文档：clk_phy → clk_ts 的握手同步器 max delay 要求（如 < 2ns） |
| **RTL-MAJ-003** | 10BASE-T1S PLCA 时序补偿逻辑的时钟域未指定 | PLCA 模块集成风险 | §6.2.9 描述 PLCA timer 但未写参考时钟（80ns 周期暗示 12.5MHz？未确认） | 明确 PLCA timer 的参考时钟（如 `clk_mac` 分频或独立低速时钟），补充时钟域交叉设计 |
| **RTL-MAJ-004** | DMA 全局通道池的 AXI outstanding / QoS 映射未定义 | AXI 总线性能/死锁风险 | 32 通道共享 AXI Master 时， outstanding 控制是防死锁关键 | EDR 阶段定义：每通道 outstanding 上限、AXI ID 分配表、QoS 优先级映射规则 |
| **RTL-MAJ-005** | μARCH-001/005/007/008/009/010 仍为 Open | 对应模块 RTL 设计不确定 | FIFO 单/双端口、帧抢占 FIFO 独立/共享、PHC 偏差、vPHC 延迟、低功耗序列、DMA 仲裁公平性均未定稿 | PM Agent 应在 EDR 前关闭或转移这些 Open 问题，至少给出 RTL 编码的默认决策 |
| **RTL-MAJ-006** | 缺少综合/DFT/Low Power 基本假设 | RTL 编码缺乏约束边界 | 无工艺节点、无目标频率、无面积上限、无电源域划分 | EDR 阶段在 Design Spec 附录中补充：目标工艺（如 22nm）、目标频率表、面积上限（kGE）、UPF 电源域初稿 |
| **RTL-MAJ-007** | `MAC_x_TYPE`/`PHY_x_TYPE` 独立配置导致顶层 `generate` 复杂度极高 | 综合/ lint / CDC 检查难度陡增 | 同一 IP 内混合 XGMAC/GMAC/MAC 是创新但激进 | EDR 阶段输出顶层参数化模板 (`eth_top.sv`)，验证 `generate` 嵌套在目标综合工具中可正确处理 |

### 3.3 Minor 问题（建议优化）

| 问题 ID | 问题描述 | 修复建议 |
|:-------:|----------|----------|
| **RTL-MIN-001** | Erratum 规避的 RTL 修改点缺少对应 SVA / 形式验证属性 | EDR 阶段为 13 项 erratum 各编写一条 SVA，绑定到 UVM 验证计划 |
| **RTL-MIN-002** | Design Spec §6 参数默认值与 Arch Spec §1.4 不一致（如 `MAC_COUNT` 4 vs 2, `DMA_CH_COUNT` 8 vs 16） | 统一两文档参数默认值，以 Arch Spec 为基准 |
| **RTL-MIN-003** | 无 lint / CDC 规则规范（如 RDC / SpyGlass 规则集） | EDR 阶段定义 RTL 编码规范：时钟域命名规则、复位策略规则、异步 FIFO 必须使用同步 Gray 码等 |
| **RTL-MIN-004** | Safety 状态机（NORMAL→DEGRADED→SAFE_STATE）无 RTL 状态转移图 | EDR 阶段补充安全状态机的状态转移条件和输出逻辑 |

---

## 4. 推荐决策

### 4.1 节点通过性评估

| 评估维度 | 评分 | 说明 |
|----------|:----:|------|
| 交付物完整性 | ⚠️ **有条件通过** | Arch Spec 和 Design Spec 均已存在且内容较完整，但缺少 RTL 入口必需的接口时序、Switch 微架构、vPHC 硬件定义等关键信息。 |
| 内部一致性 | ❌ **不通过** | `SWITCH_PORT_COUNT` 2~8 与 Design Spec 固定 4 端口矛盾；部分参数默认值在两文档间不一致；10BASE-T1S PLCA 时钟域未统一。 |
| 质量评估 | **中** | 概念设计充分，TC4x erratum 规避方案详尽，但 RTL 落地信息（时序、仲裁、存储实现）严重不足。 |

### 4.2 推荐决策

> **推荐决策**: **有条件通过 PAD Gate，但必须在 EDR 阶段前补充以下阻塞项，否则 RTL 入口将被阻塞。**

### 4.3 实体 Yang 需重点检查

1. **Switch Core 的复杂度与面积风险**: 4-port L2/L3 Switch + 8K FDB + TAS GCL + FRER 在一个模块内，目标 ~80kGE 是否过于乐观？建议要求 EDR 阶段提供 FDB 查表的初步综合结果（哪怕用行为级模型）。
2. **vPHC 的必要性**: Xen IO Ring 是软件概念，若目标芯片无 Hypervisor 支持，vPHC 模块将永久闲置。建议确认 SDV 场景是否为 P0 需求，否则可将 `SUPPORT_VPHC` 降为 P2 并延后实现。
3. **混合 MAC 类型的价值 vs 复杂度**: 同一 IP 内混合 XGMAC/GMAC/MAC 是差异化卖点，但会显著增加验证空间（需覆盖所有类型组合）。建议评估是否锁定为 "全 XGMAC" 或 "全 GMAC" 以简化首批流片。

---

## 5. EDR 阶段需补充的 RTL 信息

### 5.1 阻塞性补充项（RTL 入口前必须完成）

| 序号 | 补充内容 | 负责角色 | 产出物 |
|:----:|----------|----------|--------|
| 1 | **Switch Core 仲裁器设计**：输出端口冲突时的仲裁算法（轮询/优先级/加权）及 RTL 状态机图 | Design Agent | `Docs/Design/ethernet/sw_arbiter_design.md` |
| 2 | **FDB 存储与查表微架构**：8K 条目实现方案（SRAM 宏型号/端口数/位宽）、查表流水线级数、时序约束 | Design Agent | `Docs/Design/ethernet/fdb_microarch.md` |
| 3 | **L3 Route 引擎设计**：IP 前缀匹配方案（哈希表/TCAM 接口）、ARP 缓存 RTL 结构、默认路由逻辑 | Design Agent | `Docs/Design/ethernet/l3_route_design.md` |
| 4 | **vPHC 硬件接口重新定义**：替代 Xen IO Ring 概念，输出 VM 请求解码、PHC MUX、虚拟时间偏移寄存器的信号清单和时序 | Design Agent | `Docs/Design/ethernet/vphc_hw_interface.md` |
| 5 | **统一 `SWITCH_PORT_COUNT` 范围**：Arch Spec 与 Design Spec 统一为 2~4 或 2~8，并更新子模块实例化策略 | Arch Agent | Arch Spec v1.8e / Design Spec v1.1 |
| 6 | **接口时序规范**：MII/GMII/RGMII/SGMII/USXGMII 的 setup/hold；AXI4/AXI4-Lite 的 valid-ready 时序；PTP SFD 捕获的 max delay | Design Agent | `Docs/Arch/ethernet_interface_spec.md` 更新 |
| 7 | **时钟目标频率表**：定义典型值（如 `clk_sys=200MHz`, `clk_mac=250MHz`），作为 RTL 综合约束基准 | Arch Agent / Design Agent | 写入 `ethernet_clock_reset_spec.md` |
| 8 | **AXI Master outstanding / QoS / ID 分配规则**：32 通道场景下的防死锁设计 | Design Agent | `Docs/Design/ethernet/dma_axi_protocol.md` |
| 9 | **10BASE-T1S PLCA 时钟域与 PHY 接口信号定义**：明确 PLCA timer 参考时钟、MII/PLCA 接口信号、COL/CRS 特殊时序 | Design Agent | `Docs/Design/ethernet/plca_phy_interface.md` |
| 10 | **综合/DFT/Low Power 基本假设**：目标工艺节点、频率、面积上限、UPF 电源域初稿 | Design Agent / FuSa Agent | `Docs/Design/ethernet/rtl_constraints.md` |

### 5.2 重要补充项（EDR 阶段内完成）

| 序号 | 补充内容 | 负责角色 |
|:----:|----------|----------|
| 11 | 关闭 μARCH-001/005/007/008/009/010 并给出 RTL 默认决策 | PM Agent / Design Agent |
| 12 | TAS GCL 存储实现决策（寄存器 vs SRAM）及工艺宏选型建议 | Design Agent |
| 13 | ECC SECDED 编码位宽分配表（32/64-bit 数据对应的校验位） | FuSa Agent |
| 14 | 顶层参数化 SystemVerilog 模板 (`eth_top.sv`) 及 `generate` 嵌套验证报告 | RTL Lead |
| 15 | 13 项 TC4x erratum 的 SVA / 形式验证属性初稿 | Verification Agent |
| 16 | 安全状态机（NORMAL→DEGRADED→SAFE_STATE）RTL 状态转移图 | FuSa Agent |
| 17 | 复位释放计数器的 RTL 实现方案（参考时钟、计数器位宽、各域释放时序图） | Design Agent |
| 18 | 统一 Arch Spec 与 Design Spec 的参数默认值差异 | Arch Agent |

---

## 6. 全部交付物清单

### Arch Spec v1.8c 相关交付物

- [x] §1.4.2 可配置参数矩阵（协议/DMA/安全参数）
- [x] §2 系统框图与混合架构说明
- [x] §3 时钟/PTP子系统（双 PHC + Crossbar + vPHC）
- [x] §5 PLCA 10BASE-T1S 约束（分散于参数矩阵和 §6.2.9/6.2.10）
- [x] §6 TC4x erratum 规避（13 项，RTL 修改方案详尽）
- [ ] **缺失**: §6 中 PLCA 时钟域未明确
- [ ] **缺失**: 接口时序规范未在 Arch Spec 中定义（依赖 Interface Spec）

### Design Spec v1.0 相关交付物

- [x] 顶层模块划分（8+1+1）与职责矩阵
- [x] 数据通路设计（TX/RX/Switch）
- [x] 控制通路设计（CSR/中断/安全告警）
- [x] DMA/MTL/MAC/Switch/PTP/Safety/vPHC/PM 子模块清单
- [x] CDC 异步 FIFO 清单
- [x] 复位域划分
- [x] 编译时参数表
- [x] μARCH-001~010 问题追踪
- [ ] **缺失**: Switch Core 仲裁器设计
- [ ] **缺失**: FDB/L3 查表微架构
- [ ] **缺失**: vPHC 硬件接口信号清单
- [ ] **缺失**: AXI Master 协议参数（outstanding/QoS/ID）
- [ ] **缺失**: 时序约束目标值
- [ ] **缺失**: 综合/工艺/面积假设

---

## 7. 评审结论

> **RTL_Coding_Agent 评审结论**:
>
> 本 Ethernet IP 的架构设计和微架构设计在概念层面是完整且先进的——混合 MAC 类型、全局 DMA 通道池、双 PHC + Crossbar、Switch 级 TAS、TC4x erratum 规避等特性均体现了对标车规标杆的设计深度。
>
> 然而，从 **RTL 可实现性** 角度审视，当前交付物存在 **4 项 Critical 缺陷**（Switch 仲裁/FDB 微架构缺失、vPHC 无硬件定义、`SWITCH_PORT_COUNT` 参数矛盾）和 **7 项 Major 风险**（无时序约束、无 AXI 协议细节、无综合假设等）。这些缺陷意味着 RTL 工程师拿到当前 Spec 后，**无法直接开始 Switch Core、vPHC、HSPHY PLCA 等关键模块的编码**，必须等待 EDR 阶段补充大量微架构细节。
>
> **推荐决策**: **有条件通过 PAD Gate**。条件为：EDR 阶段必须在 RTL 入口前完成 §5.1 所列 10 项阻塞性补充项。建议实体 Yang 重点关注 Switch Core 的面积/时序可行性和 vPHC 的必要性，必要时在 EDR 阶段进行早期面积评估（preliminary synthesis）。

---

*评审记录生成: 2026-05-21*  
*评审人: RTL_Coding_Agent*  
*状态: 待实体 Yang 审阅*
