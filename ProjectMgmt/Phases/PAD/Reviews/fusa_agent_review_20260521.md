# Ethernet IP PAD Gate Review — 功能安全视角评审记录

> **评审日期**: 2026-05-21  
> **评审角色**: FuSa Agent (Critical Quality Gatekeeper)  
> **评审对象**:  
> 1. `Docs/FuSa/safety_concept.md` (v1.0, 2026-05-11)  
> 2. `Docs/Arch/ethernet_arch_spec.md` (v1.8c, 2026-05-21)  
> **评审阶段**: PAD (Preliminary Architecture Design) Gate  
> **评审性质**: 功能安全合规性审查，为 EDR (Engineering Design Review) 输入准备  

---

## 1. 评审范围

本次评审聚焦以下两个文档在 PAD 阶段的功能安全完整性：

| 文档 | 版本 | 关注章节 | 评审重点 |
|------|------|----------|----------|
| `Docs/FuSa/safety_concept.md` | v1.0 | §1 安全目标 (SG-ETH-01~06)、§2 安全机制、§3 DC/FHTI、§4 安全状态机、§5 ASIL 分解 | 安全目标覆盖度、DC 量化可信度、ASIL 分解合规性、FHTI 最坏情况分析 |
| `Docs/Arch/ethernet_arch_spec.md` | v1.8c | §1.4.3 功能安全参数、§3.3 PTP 时间子系统、§4.3 资源估算、§8 安全架构 | 参数化安全影响、PTP 故障模式、安全冗余资源、架构与概念一致性 |

**新增功能安全关注点** (Arch Spec v1.8c 新增参数)：
- `SUPPORT_EEE` (802.3az 低功耗 PHY 模式)
- `SUPPORT_IPSEC` / `SUPPORT_SECOC` / `SUPPORT_DTLS` (安全加速器卸载接口)
- `PHY_x_DUPLEX` (半双工/全双工模式)
- `SUPPORT_AVTP` / `SUPPORT_AVTP_CTL` (IEEE 1722 AVTP 流识别)
- 双 PHC + vPHC 虚拟化架构

---

## 2. 功能安全检查项

### 2.1 安全目标 (Safety Goals) 覆盖度

| 检查项 | 标准 | 检查结果 | 备注 |
|--------|------|:--------:|------|
| SG-ETH-01: 防止 MAC/DMA 数据通路故障导致的安全关键帧丢失/篡改 | ASIL-B | ✅ | 覆盖存储器 bit 翻转、总线数据损坏 |
| SG-ETH-02: 防止时钟失效导致时间同步精度退化 | ASIL-B | ✅ | 覆盖 PLL 失锁、时钟毛刺、频率漂移 |
| SG-ETH-03: 防止配置错误导致安全功能意外关闭 | ASIL-B | ✅ | 覆盖 CSR 写入错误、软错误翻转 |
| SG-ETH-04: 防止 DMA 超时挂起导致安全数据流中断 | ASIL-B | ✅ | 覆盖 DMA Engine 死锁、总线仲裁饥饿 |
| SG-ETH-05: 防止 FSM 状态机跳转错误导致非预期硬件行为 | ASIL-B | ✅ | 覆盖 SEU、时钟域违规 |
| SG-ETH-06: 防止 Bridge 转发表损坏导致安全帧路由错误 | ASIL-B | ✅ | 覆盖 Bridge 表 bit 翻转、VLAN 配置错误 |
| **PTP/PHC 时间基准故障** | — | ❌ **缺失** | 双 PHC 计数器跳变、Crossbar 错误绑定、vPHC 虚拟化隔离失效等无对应 SG |
| **安全加速器接口故障** (`SUPPORT_IPSEC`/`SECOC`/`DTLS`) | — | ❌ **缺失** | 外部 CSS/HSE 加速器接口故障导致安全关键 PDU 认证失败无对应 SG |
| **EEE 低功耗模式链路恢复延迟** (`SUPPORT_EEE`) | — | ❌ **缺失** | LPI 唤醒延迟可能导致安全关键帧在 FHTI 内无法传输 |
| **半双工碰撞检测对 TSN 确定性的影响** (`PHY_x_DUPLEX=0`) | — | ❌ **缺失** | CSMA/CD 在半双工 10M/100M 下引入非确定性延迟，与安全目标 SG-ETH-02 (TSN 确定性) 冲突 |
| **Switch Core FDB/VLAN/L3 表 ECC 覆盖** | — | ⚠️ 部分 | Arch Spec §8.1 提到 ECC 覆盖 Switch FDB/VLAN/L3 表，但 Safety Concept §1.2 分解中 FSC-ETH-01.4 仅提及 Bridge 转发表 ECC，未涵盖 L3 路由表 |

**评审结论**: SG-ETH-01~06 覆盖了基线 Ethernet MAC/DMA/Bridge 故障模式，但 **Arch Spec v1.8c 引入的 7 项新增功能特性中，有 4 项未在 Safety Concept 中建立安全目标映射**。这构成 **Major 缺陷**。

---

### 2.2 诊断覆盖 (Diagnostic Coverage, DC) 量化

| 安全机制 | 声称 DC | 声称来源 | ASIL-B 要求 | 合规性 | 评审意见 |
|----------|:-------:|----------|:-----------:|:------:|----------|
| ECC (SECDED) — 存储器单 bit | 99% | Infineon TC4x Safety Manual | ≥90% (中) | ✅ | 引用来源可信，但需本 IP 工艺库验证 |
| ECC (SECDED) — 存储器双 bit | 99% | Infineon TC4x Safety Manual | ≥90% (中) | ✅ | 同上 |
| FSM Parity — 逻辑 stuck-at | 90% | 未标明来源 | ≥60% (低) | ✅ | **缺乏量化方法说明** |
| FSM Parity — 逻辑 SEU | 90% | 未标明来源 | ≥60% (低) | ✅ | **缺乏量化方法说明** |
| Clock Monitor — 频率故障 | 99% | 未标明来源 | ≥90% (中) | ✅ | **缺乏量化方法说明** |
| Clock Monitor — 毛刺故障 | 90% | 未标明来源 | ≥60% (低) | ✅ | **缺乏量化方法说明** |
| Timeout — DMA/CSR/Bus | 95% | 未标明来源 | ≥60% (低) | ✅ | **缺乏量化方法说明** |
| CSR Write-Once Lock | 95% | 未标明来源 | ≥60% (低) | ✅ | **缺乏量化方法说明** |
| 总线 Parity (AXI, 可选) | 90% | 未标明来源 | ≥60% (低) | ✅ | ASIL-B 时可选，ASIL-C 时推荐 |

**关键问题**:

1. **DC "实测"值来源不明**: Safety Concept §3.2 中标注 "DC 实测 ≥99%" 等数值，但除 ECC 引用 TC4x 手册外，其余 7 项安全机制均无 DC 计算过程或验证来源。ISO 26262-5:2018 要求 DC 必须基于定量分析（故障注入、形式验证、或标准参考值）。**在 PAD 阶段，这些 DC 值应至少标明计算方法（如故障注入覆盖率、形式验证状态机可达性分析），而非直接标为"实测"**。

2. **Switch Core 安全机制 DC 未单独评估**: Arch Spec §8.1 列出 Switch Core 的 ECC/FSM Parity/Timeout 覆盖，但 Safety Concept §2.2 覆盖矩阵中未单独列出 Switch Core 的 DC。Switch Core 包含 FDB/VLAN/L3 表（SRAM 16KB）、Crossbar 状态机、TAS GCL（256-entry），其故障模式与端点 MAC 不同，不应复用同一 DC 值。

3. **PTP/Timestamp 模块 DC 未评估**: 双 PHC 计数器、Crossbar 绑定逻辑、vPHC Xen IO Ring 均无 DC 量化。

**评审结论**: DC 量化 **部分可信（ECC 有引用来源），但大部分缺乏计算依据**。建议在 EDR 阶段通过故障注入仿真补充 DC 验证数据。此为 **Major 缺陷**。

---

### 2.3 ASIL 分解合规性 (ISO 26262-9)

| 检查项 | 标准要求 | 文档声明 | 评审意见 |
|--------|----------|----------|----------|
| 分解策略 | 独立性要求 (独立性等级 D 或 E) | IP 内部 ASIL-B，SoC 级 ASIL-D | 策略合理，但需确认分解依据 |
| 元素共存分析 | 独立元素与相关元素的区分 | Safety Concept §5.3 说明 IP 不内嵌 Lockstep | **缺乏共存分析 (Coexistence Analysis)** |
| 共因失效 (CCF) | ASIL-D 分解必须考虑 CCF | 提及 SoC 级 SMU + PMIC + SafeTlib | **但 IP ↔ SoC 接口的 CCF 未分析** |
| 分配依据 | 分解后的 ASIL 等级必须分配到具体元素 | ASIL-B 分配给 IP 内 ECC/Parity/Timeout，ASIL-D 分配给 SoC Lockstep/SMU | **安全要求未追踪到具体硬件模块** |

**关键问题**:

1. **模块级 ASIL-B ≠ 系统级 ASIL-D 的分解逻辑**: Safety Concept §5.3 明确声明 "本 IP 模块内部安全机制仅达 ASIL-B"，ASIL-D 需 "SoC 提供 Lockstep CPU + SMU 双冗余 + 外部 PMIC"。这本质上是 **ASIL-D 分解为 ASIL-B(D) + ASIL-D(D)** 的分解模式（ISO 26262-9:2018 §5）。但文档中：
   - 未声明分解后的 **独立性要求**（分解元素间是否满足独立性等级 D）
   - 未提供 **分解理由**（为何 Lockstep 必须放在 SoC 而非 IP 内）
   - 未分析 **SMU_ALERT[3:0] 接口** 作为分解边界的安全完整性

2. **与竞品的对标存在误读风险**: §5.3 声称 "与 Infineon TC4x 策略一致"，但 §6.1 竞品表中 TC4x GETH 标注为 **"ASIL-D"**（模块级）。实际上 TC4x 整芯片 ASIL-D，GETH 模块单独不声明独立 ASIL 等级——这与本 IP "模块级 ASIL-B" 的策略 **并不完全一致**。TC4x 的 GETH 内部 ECC/FSM/Timeout 机制密度可能高于本 IP 基线（所有存储器 + 寄存器 ECC）。

3. **Arch Spec 与 Safety Concept 的 ASIL 声明不一致**: Arch Spec §8.1 列出 "Lockstep (可选)" 作为安全机制，但 Safety Concept §5.3 明确说 "本 IP 不内嵌 Lockstep"。这是一个 **文档间不一致**。

**评审结论**: ASIL 分解策略在高层合理，但 **缺乏 ISO 26262-9 要求的分解依据、独立性分析和边界接口安全完整性声明**。此为 **Major 缺陷**。

---

### 2.4 故障处理时间间隔 (FHTI) 分析

| 安全目标 | FHTI 典型值 | FHTI 最坏情况 | 检测+恢复延迟 | 评审意见 |
|----------|:-----------:|:-------------:|:-------------:|----------|
| SG-ETH-01 (ECC 单 bit) | 1 μs | 5 μs | <1 μs | ✅ 合理，ECC 实时纠正 |
| SG-ETH-01 (ECC 双 bit) | 1 μs | 10 μs | <2 μs | ✅ 合理，Trap + SMU 报警 |
| SG-ETH-02 (时钟丢失) | 10 μs | **100 μs** | <15 μs | ⚠️ **最坏 100 μs 缺乏依据**，检测<5μs + 恢复<5μs 为何最坏扩大 10 倍？ |
| SG-ETH-03 (CSR 错误) | 1 ms | 10 ms | <110 μs | ⚠️ **典型值 1ms 过于宽松**，Parity 检测 <1μs，为何典型 FHTI 放大 ~1000 倍？ |
| SG-ETH-04 (DMA 超时) | 10 μs | 100 μs | "可配置" | ⚠️ **超时阈值可配置 1μs~10ms，但典型值仅标 10μs**，未说明默认配置 |
| SG-ETH-05 (FSM 错误) | 1 μs | 5 μs | <2 μs | ✅ 合理 |
| SG-ETH-06 (Bridge 表错误) | 1 μs | 10 μs | <2 μs | ✅ 合理 |

**关键问题**:

1. **FHTI 典型值与最坏值差距缺乏分析**: SG-ETH-02 检测+恢复 <15μs，但最坏 FHTI 标 100μs（6.7 倍差距）；SG-ETH-03 检测+恢复 <110μs，但典型 FHTI 标 1ms（9 倍差距）。这些差距的来源（时钟域跨越延迟、仲裁延迟、总线竞争）未说明。ISO 26262 要求 FHTI 必须基于最坏情况分析 (WCA)。

2. **Switch Core 转发超时的 FHTI 未定义**: Arch Spec §6.2.7 提到 Switch Core 有 "独立 ingress/egress FIFO (各 2KB~8KB)" 和 "背压不丢帧"，但 Safety Concept 未定义 Switch 转发超时（如 FDB 查表阻塞、Crossbar 仲裁饥饿）的 FHTI。

3. **PTP 时间同步错误的 FHTI 未定义**: 若 PHC 计数器因时钟故障跳变，导致 gPTP 同步偏移超过 802.1AS 容限（如从 ±10ns 恶化到 >1μs），其 FHTI 应为多少？

**评审结论**: FHTI 基线值合理，但 **典型/最坏差距缺乏 WCA 支撑，且 Switch/PTP 模块的 FHTI 缺失**。此为 **Major 缺陷**。

---

### 2.5 新增参数的安全影响评估

| 新增参数 | Arch Spec 默认值 | Safety Concept 评估 | 风险等级 | 评审意见 |
|----------|:--------------:|:-------------------|:--------:|----------|
| `SUPPORT_EEE` | 0 (Configurable) | **未评估** | **Major** | EEE LPI 模式唤醒延迟 <10μs (§4.2.2)，但安全关键帧在 FHTI 内是否允许进入 LPI？未定义安全策略 |
| `SUPPORT_IPSEC` | 0 (Configurable) | **未评估** | **Major** | IPsec ESP/AH 卸载接口故障可能导致安全关键 PDU 解密失败或延迟。需定义接口超时 + 降级策略 |
| `SUPPORT_SECOC` | 0 (Configurable) | **未评估** | **Major** | SecOC PDU 认证失败需定义安全响应（丢弃/放行 + 报警），与安全目标 SG-ETH-01 (数据完整性) 关联 |
| `SUPPORT_DTLS` | 0 (Configurable) | **未评估** | **Minor** | D/TLS 主要用于非实时管理通道，安全影响较低 |
| `PHY_x_DUPLEX` | 1 (全双工) | **未评估** | **Major** | 半双工模式 (10M/100M) 引入 CSMA/CD 碰撞退避，与 SG-ETH-02 (TSN 确定性) 存在潜在冲突 |
| `SUPPORT_AVTP` | 1 (Yes) | **未评估** | **Minor** | AVTP 流识别主要影响 QoS，非安全关键 |
| `SUPPORT_AVTP_CTL` | 0 (Configurable) | **未评估** | **Minor** | AVTP 控制表非安全关键 |
| `PHC_COUNT=2` / `SUPPORT_VPHC` | 2 / 0 | **未评估** | **Major** | 双 PHC + vPHC 虚拟化引入跨域时间隔离故障模式，需定义 PHC 漂移检测 + vPHC 逃逸检测 |

**关键问题**:

1. **参数化安全机制的遗漏**: Arch Spec §1.4.3 功能安全参数中，`ASIL_LEVEL` 可配置 0(QM)~4(ASIL-D)，但 Safety Concept 仅覆盖 `ASIL_LEVEL=2 (ASIL-B)` 场景。当用户配置 `ASIL_LEVEL=0 (QM)` 时，所有安全机制关闭，此时安全目标 SG-ETH-01~06 是否仍然适用？ISO 26262 不允许在安全相关系统中 "关闭" 安全目标，只允许降低 ASIL 等级并相应调整安全机制。

2. **半双工的安全目标冲突**: `PHY_x_DUPLEX=0` (半双工) 仅对 10M/100M 有效。半双工模式下 CSMA/CD 碰撞退避时间不可预测（0~5.12μs for 100M），这直接破坏 TSN 确定性。若某安全关键应用（如制动信号通过 100BASE-T1 传输）使用半双工，SG-ETH-02 的时钟监控无法覆盖碰撞退避引入的延迟抖动。

3. **EEE 低功耗与安全状态的交互**: EEE 进入 LPI 后，PHY 侧链路处于低功耗，唤醒序列（Wake-up signal + TS）需要 <10μs。但如果 SMU 触发 SAFE_STATE 时链路处于 LPI，TX 停止前是否需要先唤醒 PHY？Safety Concept §4.1 安全状态机未描述此交互。

**评审结论**: **7 项新增参数中，4 项存在 Major 安全风险且 Safety Concept 完全未评估**。此为 **Critical 缺陷**。

---

### 2.6 安全状态机与降级模式

| 检查项 | Safety Concept 声明 | Arch Spec 支持 | 一致性 |
|--------|---------------------|----------------|:------:|
| NORMAL → DEGRADED (ECC 单 bit 计数≥阈值) | §4.1 | `SAFETY_ERR_CNT` (0x704), `SAFETY_DEGRADED_MASK` (0x708) | ✅ |
| NORMAL → SAFE_STATE (ECC 双 bit / FSM Parity / 时钟丢失) | §4.1 | `SAFETY_STATE` (0x700), `SAFETY_SMU_ALERT` (0x718) | ✅ |
| DEGRADED → NORMAL (故障通道修复 + 软件确认) | §4.2 | 需 SMU/EcuM 确认 | ⚠️ **缺乏 EcuM 接口定义** |
| DEGRADED → SAFE_STATE (降级模式超时) | §4.2 | `SAFETY_TIMEOUT_CFG` (0x70C) "可配置" | ⚠️ **超时默认值未定义** |
| SAFE_STATE → NORMAL (外部复位 + BIST) | §4.2 | `SAFETY_BIST_CTRL` (0x714) | ✅ |

**关键问题**:

1. **降级模式通道屏蔽位宽不足**: `SAFETY_DEGRADED_MASK` (0x708) 定义为 "每 bit 对应一个通道"，但未说明位宽。Arch Spec 中 `DMA_CH_COUNT` 最大 32，`MAC_COUNT` 最大 8，`PHY_COUNT` 最大 8。若 `SAFETY_DEGRADED_MASK` 为 8-bit，则无法覆盖 32 个 DMA 通道；若为 32-bit，则无法同时覆盖 MAC/PHY。寄存器定义需明确映射关系。

2. **DEGRADED 模式的软件确认机制未定义**: §4.2 声明 "需 SMU/EcuM 确认"，但 Arch Spec 中无 EcuM 接口定义。`SAFETY_STATE` 为 RO，`SAFETY_DEGRADED_MASK` 为 Write-Once，软件如何清除 DEGRADED 状态？

3. **Switch Core 的降级策略缺失**: 当 Switch Core 内部 FDB ECC 双 bit 错误或 Crossbar FSM Parity 错误时，是整个 Switch 进入 SAFE_STATE，还是仅关闭故障端口？Safety Concept 未定义 Switch 级粒度降级策略。

**评审结论**: 安全状态机高层设计合理，但 **降级模式粒度、软件确认机制、Switch 级降级策略存在模糊性**。此为 **Major 缺陷**。

---

### 2.7 资源估算中的安全冗余

| 模块 | Arch Spec §4.3 门数 | 安全机制覆盖 | 评审意见 |
|------|:-------------------:|--------------|----------|
| Safety/ECC | ~15 kGE (固定) | ECC 编解码器 + FSM Parity + Timeout + Clock Monitor | ⚠️ **"固定"门数与 MAC_COUNT 无关，但 SRAM 总量随 MAC_COUNT 线性增长** |
| MTL (每 MAC) | ~10 kGE + 32 KB SRAM | TX/RX FIFO ECC | ✅ |
| DMA (每 MAC) | ~20 kGE + 2 KB SRAM | 描述符缓存 ECC | ✅ |
| Switch Core | ~80 kGE + 16 KB SRAM | FDB + VLAN + L3 表 ECC + Crossbar FSM Parity | ⚠️ **Switch Core 安全冗余未单独估算** |
| PTP/Timestamp | ~10 + 10×(PHC_COUNT-1) kGE | PHC 计数器无 ECC? | ❌ **PHC 计数器本身是否受 ECC 保护未说明** |

**关键问题**:

1. **Safety/ECC "固定" 15kGE 的面积假设**: 当 `MAC_COUNT=1` (边缘节点) 与 `MAC_COUNT=8` (多端口网关) 时，ECC 控制器数量差异显著（MTL FIFO 32KB×MAC_COUNT、描述符缓存 2KB×MAC_COUNT、Switch FDB 16KB）。Safety Concept §5.1 声称 ECC 面积代价为 "+8% SRAM 面积"，但未区分不同配置下的绝对门数。Arch Spec §4.3 的 "~15kGE 固定" 可能低估了高配置场景。

2. **PHC 计数器的安全保护缺失**: 64-bit PHC 计数器是 gPTP 同步的核心时间基准，但其本身是否受 ECC/Parity 保护？Arch Spec §3.3.2 描述 PHC 为 "64-bit 计数器"，但未提及任何错误检测机制。若 PHC 计数器因 SEU 发生 bit 翻转，gPTP 同步将产生系统性偏移，影响 SG-ETH-02。

3. **vPHC 虚拟化的安全隔离**: vPHC 基于 Xen IO Rings，不同 VM 的时间域隔离依赖 Hypervisor。Safety Concept 完全未涉及软件虚拟化层的安全影响（这属于系统级分析，但 PAD 阶段应至少声明范围边界）。

**评审结论**: 资源估算中 **Safety/ECC 面积公式过于简化，PHC 计数器安全保护缺失**。此为 **Major 缺陷**。

---

### 2.8 Arch Spec 与 Safety Concept 的文档间一致性

| 检查点 | Safety Concept | Arch Spec | 一致性 |
|--------|----------------|-----------|:------:|
| ASIL 目标 | 模块级 ASIL-B | 模块级 ASIL-B，SoC 级 ASIL-D | ✅ |
| Lockstep | IP 内部不内嵌 (§5.3) | §8.1 列出 "Lockstep (可选)" | ❌ **不一致** |
| Bus Parity | ASIL-B 时可选 (§2.2) | `ENABLE_BUS_TIMEOUT=1` 默认开启，Bus Parity 未单独参数化 | ⚠️ 安全参数中无 Bus Parity 使能位 |
| ECC 数据位宽 | `ECC_DATA_WIDTH=64` (§5.1 ASIL-C 要求) | §1.4.3 默认 64，可配置 32 | ⚠️ ASIL-B 时允许 32-bit，但 §2.2 未说明 32-bit ECC 的 DC |
| SMU 报警位宽 | `SMU_ALERT[3:0]` (§5.3) | `SMU_ALERT_WIDTH` 默认 4，可配置 1/2/4 | ✅ |
| 安全状态寄存器 | §4.3 地址映射 0x700~0x718 | Arch Spec 未提及这些 CSR 地址 | ⚠️ **安全寄存器未纳入 Arch Spec CSR 地址空间** |

**评审结论**: **Lockstep 声明不一致、安全 CSR 地址未纳入 Arch Spec 地址空间**。此为 **Major 缺陷**。

---

## 3. 发现的问题汇总

| 问题 ID | 问题描述 | 严重程度 | 影响文档 | 状态 |
|:-------:|----------|:--------:|----------|:----:|
| **FUSA-PAD-001** | 新增参数 `SUPPORT_EEE`/`SUPPORT_IPSEC`/`SUPPORT_SECOC`/`PHY_x_DUPLEX` 的安全影响未评估，安全目标缺失 | **Critical** | Safety Concept | 待修复 |
| **FUSA-PAD-002** | 双 PHC + vPHC 虚拟化的时间基准故障模式未定义安全目标，PHC 计数器无 ECC 保护 | **Major** | Safety Concept / Arch Spec | 待修复 |
| **FUSA-PAD-003** | DC 量化缺乏计算依据（除 ECC 外），"实测"值来源不明 | **Major** | Safety Concept §3.2 | 待修复 |
| **FUSA-PAD-004** | ASIL 分解缺乏 ISO 26262-9 要求的独立性分析、共存分析和边界接口安全完整性声明 | **Major** | Safety Concept §5.3 | 待修复 |
| **FUSA-PAD-005** | FHTI 典型/最坏差距缺乏 WCA 支撑；Switch/PTP 模块 FHTI 缺失 | **Major** | Safety Concept §3.1 | 待修复 |
| **FUSA-PAD-006** | 降级模式通道屏蔽位宽未明确；Switch 级降级策略缺失；DEGRADED→NORMAL 软件确认机制未定义 | **Major** | Safety Concept §4 / Arch Spec §8 | 待修复 |
| **FUSA-PAD-007** | Safety/ECC 面积估算固定 15kGE 与 MAC_COUNT 无关，可能低估高配置场景 | **Major** | Arch Spec §4.3 | 待修复 |
| **FUSA-PAD-008** | Arch Spec §8.1 列出 "Lockstep (可选)" 与 Safety Concept §5.3 "不内嵌 Lockstep" 矛盾 | **Major** | Arch Spec §8.1 / Safety Concept §5.3 | 待修复 |
| **FUSA-PAD-009** | 安全状态寄存器地址空间 (0x700~0x718) 未纳入 Arch Spec CSR 地址映射 | **Major** | Arch Spec | 待修复 |
| **FUSA-PAD-010** | `ASIL_LEVEL=0 (QM)` 配置时安全目标 SG-ETH-01~06 的适用性未声明 | **Minor** | Arch Spec §1.4.3 / Safety Concept §2.1 | 待修复 |
| **FUSA-PAD-011** | 半双工模式与 TSN 确定性 (SG-ETH-02) 的潜在冲突未分析 | **Minor** | Arch Spec §1.4.1b / Safety Concept §1.1 | 待修复 |
| **FUSA-PAD-012** | Switch Core FDB/VLAN/L3 表 ECC 在 Safety Concept 分解中未完整覆盖 (FSC-ETH-01.4 仅提 Bridge 表) | **Minor** | Safety Concept §1.2 | 待修复 |

---

## 4. 推荐决策

### 4.1 PAD Gate 通过性评估

| 维度 | 评估 | 说明 |
|------|:----:|------|
| 安全目标完整性 | ❌ **不通过** | 新增 7 项功能特性中 4 项无安全目标映射 |
| DC 量化可信度 | ❌ **不通过** | 7/8 项安全机制缺乏 DC 计算依据 |
| ASIL 分解合规性 | ⚠️ **有条件通过** | 策略合理，但缺乏 ISO 26262-9 要求的分析依据 |
| FHTI 合理性 | ⚠️ **有条件通过** | 基线值合理，但 WCA 缺失，Switch/PTP FHTI 未定义 |
| 安全状态机完整性 | ⚠️ **有条件通过** | 高层设计合理，但降级粒度、软件确认机制模糊 |
| 文档间一致性 | ❌ **不通过** | Lockstep 声明矛盾，安全 CSR 未纳入 Arch Spec |

**综合推荐**: **有条件通过 (Conditional Pass)**

> **有条件通过的前提**: 以下 3 项 Critical/Major 问题必须在 EDR 阶段启动前完成修复或形成明确修复计划：
> 1. **FUSA-PAD-001**: 补充新增参数的安全影响评估（至少 `SUPPORT_EEE`、`SUPPORT_IPSEC`、`SUPPORT_SECOC`、`PHY_x_DUPLEX`）
> 2. **FUSA-PAD-003**: 提供 DC 量化计算方法说明（故障注入策略或形式验证覆盖率）
> 3. **FUSA-PAD-008**: 消除 Arch Spec 与 Safety Concept 间 Lockstep 声明矛盾

### 4.2 PAD → EDR 过渡建议

| 建议项 | 优先级 | 负责人 | 交付物 |
|--------|:------:|--------|--------|
| 补充 `SUPPORT_EEE`/`IPSEC`/`SECOC`/`DTLS`/`PHY_x_DUPLEX` 的安全目标和安全机制 | **P0** | FuSa Agent | Safety Concept v1.1 §1.3 "扩展安全目标" |
| 补充双 PHC + vPHC 的时间基准故障模式分析和安全机制 (PHC ECC/漂移检测) | **P0** | FuSa Agent | Safety Concept v1.1 §1.4 "PTP 安全目标" |
| 提供 DC 量化计算方法文档 (故障注入覆盖率报告模板) | **P0** | Verification Agent + FuSa Agent | `Docs/FuSa/dc_quantification_method.md` |
| 完成 ASIL 分解的独立性分析和共存分析 | **P0** | FuSa Agent | Safety Concept v1.1 §5.4 "分解依据" |
| 完成 FHTI 最坏情况分析 (WCA)，补充 Switch/PTP FHTI | **P1** | Arch Agent + FuSa Agent | Safety Concept v1.1 §3.4 "WCA 报告" |
| 修正 Arch Spec §8.1 Lockstep 声明，统一为 "IP 内部不内嵌，SoC 级可选" | **P0** | Arch Agent | Arch Spec v1.8d §8.1 |
| 将安全状态寄存器 (0x700~0x718) 纳入 Arch Spec CSR 地址空间 | **P1** | Arch Agent | Arch Spec v1.8d §1.4.5 "安全 CSR" |
| 明确 `SAFETY_DEGRADED_MASK` 位宽和通道映射关系 | **P1** | Arch Agent | Arch Spec v1.8d §8.2 "降级模式寄存器" |
| 补充 Switch Core 粒度降级策略 (端口级 vs 模块级) | **P1** | FuSa Agent | Safety Concept v1.1 §4.4 "Switch 降级策略" |

---

## 5. EDR 阶段需补充的安全分析

以下分析项在 PAD 阶段因信息不足或超出范围未覆盖，需在 EDR 阶段补充：

### 5.1 FMEDA 前置输入 (参考 Safety Concept §8.1)

| 输入项 | 当前状态 | EDR 阶段任务 |
|--------|:--------:|--------------|
| 硬件元器件失效率 (FIT) | ⬜ 需工艺库数据 | 基于目标工艺节点 (如 22nm/12nm) 的 SRAM/逻辑 FIT 数据 |
| 安全机制失效率 | ⬜ 需工艺库数据 | ECC 编解码器、FSM Parity 逻辑、Timeout 计数器的 FIT |
| 共因失效 (CCF) 分析 | ⬜ 需模块级详细设计 | 基于 IEC 62380 / SN 29500 的 CCF 分析，特别是多通道 ECC 共享编解码器场景 |
| 多点故障检测间隔 (MPFDI) 验证 | ⚠️ 已定义数值 | 需仿真验证 MPFDI 是否满足 (如 ECC 错误计数器 1000 周期阈值) |

### 5.2 PTP/时间子系统安全分析

| 分析项 | 说明 | EDR 交付物 |
|--------|------|------------|
| PHC 计数器 SEU 故障模式 | 64-bit 计数器 bit 翻转对 gPTP 同步精度的影响 | FMEDA 中 PHC 模块的 FIT + DC |
| Crossbar 错误绑定故障 | 端口绑定错误 PHC 导致的时间域混叠 | FTA (Fault Tree Analysis) 顶事件 |
| vPHC 虚拟化隔离失效 | Xen IO Ring 权限逃逸导致 VM 间时间干扰 | 系统级安全分析 (SoC 层面) |
| PTP 状态机 (INITIALIZING→MASTER/SLAVE) 非法跳转 | 端口状态机 SEU 导致错误 BMCA 决策 | FSM Parity 覆盖范围验证 |

### 5.3 新增参数的安全分析

| 参数 | EDR 分析项 |
|------|------------|
| `SUPPORT_EEE=1` | LPI 唤醒延迟对 FHTI 的影响量化；EEE 模式下安全状态机交互 |
| `SUPPORT_IPSEC=1` | CSS/HSE 加速器接口故障模式；安全关键帧绕过 IPsec 的降级策略 |
| `SUPPORT_SECOC=1` | SecOC Freshness 值溢出/重放攻击检测；MAC-I 验证失败的 SMU 报警 |
| `PHY_x_DUPLEX=0` | 半双工 CSMA/CD 碰撞退避对 TSN 确定性 (SG-ETH-02) 的影响分析；是否需在半双工时降级 ASIL |
| `SUPPORT_AVTP=1` | AVTP 流识别错误导致的安全关键帧误分类 (如制动帧被送入信息娱乐队列) |

### 5.4 故障注入验证计划

| 验证项 | 目标 | 平台 | EDR 负责人 |
|--------|------|------|-----------|
| ECC 故障注入 (单/双 bit) | DC ≥99% 验证 | UVM + 形式验证 | Verification Agent |
| FSM Parity 故障注入 | DC ≥90% 验证 | 形式验证 (非法状态可达性) | Verification Agent |
| 时钟监控故障注入 | DC ≥99% 验证 | UVM (频率跳变/毛刺) | Verification Agent |
| DMA 超时故障注入 | DC ≥95% 验证 | UVM (总线屏蔽/仲裁饥饿) | Verification Agent |
| Switch Core 故障注入 | DC 未定义 → 需目标值 | UVM (FDB 错误/ Crossbar 阻塞) | Verification Agent |
| PHC 计数器故障注入 | DC 未定义 → 需目标值 | UVM (计数器跳变/ Crossbar 错误绑定) | Verification Agent |
| 新增参数故障注入 | 未定义 | UVM (EEE LPI/ IPsec 接口超时/ 半双工碰撞) | Verification Agent |

---

## 6. 竞品功能安全对标补充意见

Safety Concept §6 的竞品对标表整体准确，但存在以下需注意的差异：

1. **TC4x GETH "ASIL-D" 标注**: 表中 TC4x GETH 标为 "ASIL-D"，但实际 TC4x 整芯片 ASIL-D，GETH 模块单独不声明独立 ASIL 等级。本 IP "模块级 ASIL-B" 的策略与 TC4x 模块内部策略接近，但 TC4x GETH 的 ECC 覆盖范围（所有存储器 + 寄存器）可能高于本 IP 基线（MTL FIFO + 描述符 + Bridge 表）。建议在 EDR 阶段补充寄存器级 ECC 差距分析。

2. **NXP S32G3 SJA1110A ASIL-A**: 表中正确标注了外部 Switch ASIL-A 与 SoC ASIL-D 的两级差距。本 IP 的 Switch Core 集成在 IP 内部且标 ASIL-B，这比 S32G3 的外部 ASIL-A Switch 更安全，但需通过 FMEDA 验证。

3. **Renesas R-Car S4 混合 ASIL**: R-Car S4 实时域 ASIL-D / 应用域 ASIL-B 的混合策略与本 IP 的 "模块 ASIL-B + SoC ASIL-D" 有相似之处，但 R-Car S4 的 TSN Switch 在实时域内，其 ASIL-D 可能包含 Lockstep。建议 EDR 阶段补充对标分析。

---

## 7. 评审结论

| 维度 | 评分 | 说明 |
|------|:----:|------|
| 交付物完整性 | ⚠️ **中** | 安全目标基线存在，但新增参数映射缺失；DC 量化不完整；文档间存在不一致 |
| 内部一致性 | ❌ **低** | Lockstep 声明矛盾；安全 CSR 未纳入 Arch Spec；FHTI 差距缺乏 WCA |
| 质量评估 | **中** | 高层架构和安全概念合理，但 PAD 阶段功能安全细节不足以支撑 EDR 启动 |

### 推荐决策

> **有条件通过 (Conditional Pass)**

PAD 阶段的功能安全基线（SG-ETH-01~06、ASIL-B 安全机制、安全状态机）已经建立，满足 **"方向正确、框架完整"** 的 PAD 标准。但以下缺陷必须在 EDR 启动前修复：

1. **Critical**: 新增参数安全影响评估（FUSA-PAD-001）
2. **Major**: DC 量化依据补充（FUSA-PAD-003）
3. **Major**: 文档间 Lockstep 声明矛盾消除（FUSA-PAD-008）

### 实体 Yang 需重点检查

- **Safety Concept v1.0 §1.2**: ASIL 分解树是否满足 ISO 26262-9 的独立性要求？
- **Arch Spec v1.8c §1.4.3**: 功能安全参数 `ASIL_LEVEL` 的 QM 配置是否意味着安全目标可关闭？这与产品安全概念是否冲突？
- **Arch Spec v1.8c §3.3**: 双 PHC + vPHC 架构在目标应用场景（SDV 中央网关）中的时间隔离安全策略是否足够？
- **Arch Spec v1.8c §4.3**: Safety/ECC 固定 15kGE 在 8-MAC 配置下是否足够？是否需要按实例累加？

### 全部交付物清单

- [x] `Docs/FuSa/safety_concept.md` v1.0
- [x] `Docs/Arch/ethernet_arch_spec.md` v1.8c
- [ ] **待补充**: Safety Concept v1.1 (新增参数安全目标 + DC 方法 + ASIL 分解依据)
- [ ] **待补充**: `Docs/FuSa/dc_quantification_method.md`
- [ ] **待补充**: Arch Spec v1.8d (安全 CSR 地址映射 + Lockstep 声明修正)

---

> **评审人**: FuSa Agent (AI Yang — Critical Quality Gatekeeper)  
> **日期**: 2026-05-21  
> **签名**: 🔍 发现 12 项问题（1 Critical + 8 Major + 3 Minor），推荐有条件通过
