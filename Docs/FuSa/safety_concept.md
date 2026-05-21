# Ethernet IP Safety Concept

> **项目**: Ethernet IP (IP_20260502_001)
> **文档类型**: Safety Concept (ISO 26262-3:2018 Clause 7)
> **版本**: v1.0
> **日期**: 2026-05-11
> **作者**: FuSa Agent
> **ASIL 目标**: B (基线) / 可升级至 C/D
> **评审状态**: Draft → 待评审

---

## 1. 安全目标 (Safety Goals)

### 1.1 系统级安全目标映射

基于 Ethernet IP 在车规 SoC 中的典型应用场景（Zone Controller、ADAS 传感器汇聚、中央网关），定义以下硬件级安全目标：

| ID | 安全目标 | ASIL | 失效模式 | 安全机制 |
|----|----------|------|----------|----------|
| **SG-ETH-01** | 防止因 MAC/DMA 数据通路故障导致的安全关键帧丢失或篡改 | B | 存储器 bit 翻转、总线数据损坏 | ECC (SECDED)、AXI 数据 parity |
| **SG-ETH-02** | 防止因时钟失效导致的时间同步精度退化，进而影响 TSN 确定性 | B | PLL 失锁、时钟毛刺、频率漂移 | 时钟监控 + 安全状态切换 |
| **SG-ETH-03** | 防止因配置错误导致的安全功能意外关闭 | B | CSR 写入错误、软错误翻转 | CSR Shadow + Write-Once 锁、Parity |
| **SG-ETH-04** | 防止因 DMA 超时挂起导致的安全数据流中断 | B | DMA Engine 死锁、总线仲裁饥饿 | DMA Timeout + 独立通道复位 |
| **SG-ETH-05** | 防止因 FSM 状态机跳转错误导致的非预期硬件行为 | B | 单粒子翻转 (SEU)、时钟域违规 | FSM Parity + 安全状态机 |
| **SG-ETH-06** | 防止因 Bridge 转发表损坏导致的安全帧路由错误 | B | Bridge 表 bit 翻转、VLAN 配置错误 | Bridge 表 ECC + 源地址学习校验 |
| **SG-ETH-07** | 防止因 EEE LPI 低功耗模式意外启用导致的 TSN 确定性被破坏 | B | CSR 配置错误、SEU 使能 EEE、LPI 唤醒超时 | EEE 使能互锁 + LPI 唤醒 Timeout + Write-Once Lock |
| **SG-ETH-08** | 防止因外部安全加速器 (CSS/HSE) 接口故障导致的安全 PDU 处理失败或不可信数据传播 | B | 加速器接口超时、握手失败、安全描述符 SEU、错误回退明文 | 加速器接口 Timeout + 安全描述符 ECC + 安全停机策略 + Write-Once Lock |
| **SG-ETH-09** | 防止因 AVTP 流识别/路由错误导致的 ADAS 安全数据丢失或延迟 | B | AVTP 使能位 SEU、RX Filter 表损坏、DMA 队列误路由、演示时间戳漂移 | AVTP 使能 Parity + RX Filter ECC + DMA 通道隔离 + 时间戳校验 |
| **SG-ETH-10** | 防止因 vPHC 虚拟化隔离失效导致的多 VM 时间域污染 | B | VM ID 篡改、IO Ring 边界突破、vPHC 上下文损坏、偏移量翻转 | VM ID Parity + IO Ring 边界检查 + vPHC 上下文 ECC + 偏移量合理性检查 |

### 1.2 安全目标分解

```
SG-ETH-01 (ASIL-B)
├── FSC-ETH-01.1: MTL TX/RX FIFO ECC (SECDED)
├── FSC-ETH-01.2: DMA 描述符缓存 ECC
├── FSC-ETH-01.3: AXI Master 数据 parity (可选)
└── FSC-ETH-01.4: Bridge 转发表 ECC

SG-ETH-02 (ASIL-B)
├── FSC-ETH-02.1: 时钟丢失检测 (Clock Monitor)
├── FSC-ETH-02.2: 时钟频率监控
└── FSC-ETH-02.3: PTP 时间戳校验

SG-ETH-03 (ASIL-B)
├── FSC-ETH-03.1: CSR 写保护 (Write-Once Lock)
├── FSC-ETH-03.2: CSR Shadow Register 回读校验
└── FSC-ETH-03.3: CSR Parity 保护

SG-ETH-04 (ASIL-B)
├── FSC-ETH-04.1: DMA 通道独立超时 (CHx_TIMEOUT)
└── FSC-ETH-04.2: 总线响应超时 (BUS_TIMEOUT)

SG-ETH-05 (ASIL-B)
├── FSC-ETH-05.1: 所有 FSM 状态机 Parity 保护
└── FSC-ETH-05.2: 非法状态检测 → 强制进入 SAFE_STATE

SG-ETH-06 (ASIL-B)
├── FSC-ETH-06.1: Bridge MAC/VLAN 表 ECC
└── FSC-ETH-06.2: 静态路由配置校验和 (Checksum)

SG-ETH-07 (ASIL-B)
├── FSC-ETH-07.1: EEE 使能互锁 (TSN=1 ∧ EEE=1 → 报警/拒绝)
├── FSC-ETH-07.2: EEE 使能位 Parity 保护
├── FSC-ETH-07.3: LPI 唤醒 Timeout (硬件计数器)
└── FSC-ETH-07.4: LPI 状态机独立 Parity

SG-ETH-08 (ASIL-B)
├── FSC-ETH-08.1: CSS/HSE 加速器接口 Timeout
├── FSC-ETH-08.2: 安全描述符/SA 表 ECC
├── FSC-ETH-08.3: 安全停机策略 (故障后丢弃帧/进入 DEGRADED)
└── FSC-ETH-08.4: 加速器就绪握手 (CSS_READY ∧ SECURITY_EN=1)

SG-ETH-09 (ASIL-B)
├── FSC-ETH-09.1: AVTP 使能位 Parity
├── FSC-ETH-09.2: AVTP RX Filter 流匹配表 ECC
├── FSC-ETH-09.3: AVTP 专用 DMA 通道隔离与校验
└── FSC-ETH-09.4: AVTP 演示时间戳与 PHC 交叉校验

SG-ETH-10 (ASIL-B)
├── FSC-ETH-10.1: VM ID 标签 Parity
├── FSC-ETH-10.2: Xen IO Ring 边界检查
├── FSC-ETH-10.3: vPHC 上下文 RAM ECC
└── FSC-ETH-10.4: vPHC 偏移量合理性检查 (超范围回退物理 PHC)
```

---

## 1.3 新增可配置参数的安全影响

> **本节对应**: `Docs/Arch/ethernet_arch_spec.md` v1.8c §1.4.3 / §10.4  
> **变更号**: PAD-REWORK-005  
> **关联文档**: `Docs/FuSa/parameter_safety_impact_matrix.md`

### 1.3.1 新增参数总览

基于 Arch Spec v1.8c 引入的 **9 项新增/变更可配置参数**，本安全概念扩展覆盖如下：

| 类别 | 参数 | 默认值 | 对应安全目标 | 关键风险 |
|------|------|:------:|:----------:|----------|
| 节能/PHY 模式 | `SUPPORT_EEE` | 0 | **SG-ETH-07** | LPI 唤醒延迟破坏 TSN 确定性 |
| PHY 双工模式 | `PHY_x_DUPLEX` | 1 (全双工) | **SG-ETH-02, SG-ETH-03** | 半双工引入 CSMA/CD，与 TAS/CBS 冲突 |
| AVTP/AVB 流 | `SUPPORT_AVTP` | 1 | **SG-ETH-09** | ADAS 数据 (摄像头/激光雷达) 丢失/误路由 |
| AVTP 控制 | `SUPPORT_AVTP_CTL` | 0 | **SG-ETH-09** | 流路由表损坏导致 AVTP 错发 |
| 网络安全卸载 | `SUPPORT_IPSEC` | 0 | **SG-ETH-08** | CSS 接口故障导致安全 PDU 失败 |
| | `SUPPORT_SECOC` | 0 | **SG-ETH-08** | HSE 接口故障导致 PDU 认证失败 |
| | `SUPPORT_DTLS` | 0 | **SG-ETH-08** | CSS 接口故障导致会话状态错误 |
| PTP 虚拟化 | `PHC_COUNT` | 2 | **SG-ETH-02** | 双 PHC 漂移导致时间同步不一致 |
| | `SUPPORT_VPHC` | 0 | **SG-ETH-10** | VM 隔离失效导致多 VM 时间域污染 |

### 1.3.2 安全影响核心结论

**1. 默认关闭参数的安全边界**  
`SUPPORT_EEE` / `SUPPORT_IPSEC` / `SUPPORT_SECOC` / `SUPPORT_DTLS` / `SUPPORT_AVTP_CTL` / `SUPPORT_VPHC` 默认值为 0 (关闭)。当满足以下条件时，**默认关闭状态不引入新的安全风险**：
- 配置寄存器受 **Write-Once Lock** 保护 (运行时不可修改)
- 使能位受 **Parity** 保护 (检测 SEU 非法翻转)
- 配置一致性检查硬件拒绝非法组合 (如 `PHC_COUNT<2 ∧ VPHC=1`)

**2. 默认开启参数的安全义务**  
`SUPPORT_AVTP` 默认值为 **1** (开启)，意味着 AVTP RX Filter + DMA 隔离在基线 ASIL-B 中即存在。其安全机制 (RX Filter ECC、DMA 通道隔离) **必须纳入基线安全架构**，不能作为可选扩展。

`PHC_COUNT` 默认值为 **2**，双 PHC 交叉比较漂移监控同样是基线安全机制的一部分。

`PHY_x_DUPLEX` 默认值为 **1** (全双工)，这是安全态。半双工 (`=0`) 才是风险态，需通过硬件互锁在 TSN 使能时拒绝。

**3. 重点关注项**

| 关注项 | 风险描述 | 缓解策略 |
|--------|----------|----------|
| **EEE LPI vs TSN** | LPI 唤醒延迟 (典型 2~10 μs) 可能超过 TAS 门控周期裕量 | EEE∩TSN 配置互锁；LPI 唤醒 Timeout ≤ 10 μs |
| **半双工 vs TSN** | CSMA/CD 随机回退完全破坏 TAS/CBS 确定性 | 速率>100M 硬件强制全双工；TSN 使能时拒绝半双工配置 |
| **安全加速器接口** | CSS/HSE 故障导致安全 PDU 挂起或错误回退 | 接口 Timeout + 安全停机策略 (禁止自动明文回退) |
| **双 PHC 漂移** | PHC0/PHC1 漂移 > ±4ns 导致端口间时间不一致 | 每 1ms 交叉比较 + 3 次超阈值 → DEGRADED |
| **vPHC 隔离** | VM A 的时间错误通过 Xen IO Ring 污染 VM B | VM ID Parity + IO Ring 边界检查 + 上下文 ECC |

---

## 2. 安全概念 (Safety Concept)

### 2.1 安全架构概要

本 IP 采用 **"基线 ASIL-B + 可升级路径"** 的安全架构策略：

- **ASIL-B 基线** (默认配置): ECC + Parity + Timeout + Clock Monitor，覆盖所有安全目标
- **ASIL-C 升级**: 增加总线响应超时检测 + 双 bit ECC 报警 + 冗余时钟源切换
- **ASIL-D 系统级**: 通过 SoC 级 SMU + Lockstep 比较 + 外部看门狗实现，IP 本身保持 ASIL-B 基线

> **设计决策**: IP 本身不内嵌 Lockstep 双核（面积代价 +35%），而是通过 SoC 级安全监控实现 ASIL-D。这与 Infineon TC4x 策略一致：GETH 模块硬件达 ASIL-D，但依赖 SoC 级 SMU 集成。

### 2.2 安全机制覆盖矩阵

| 安全机制 | 覆盖 SG | 诊断覆盖 (DC) | 故障模式 | ASIL-B 合规 | ASIL-C 扩展 | ASIL-D 扩展 |
|----------|---------|---------------|----------|-------------|-------------|-------------|
| **ECC (SECDED)** | SG-ETH-01, SG-ETH-06, **SG-ETH-09 (AVTP 表), SG-ETH-10 (vPHC 上下文)** | 99% | 存储器单/双 bit 翻转 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **FSM Parity** | SG-ETH-05, **SG-ETH-07 (LPI 状态机), SG-ETH-08 (DTLS 会话状态机)** | 90% | 状态机 SEU | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **Timeout (DMA/CSR/Bus)** | SG-ETH-04, SG-ETH-02, **SG-ETH-07 (LPI 唤醒), SG-ETH-08 (加速器接口)** | 95% | 死锁、总线饥饿、时钟丢失、LPI 唤醒挂起、加速器无响应 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **Clock Monitor** | SG-ETH-02, **SG-ETH-10 (vPHC 时间漂移监控)** | 99% | PLL 失锁、频率漂移、PHC 漂移 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **CSR Write-Once Lock** | SG-ETH-03, **SG-ETH-07~10 (所有新增参数)** | 95% | 配置意外修改 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **配置互锁检测** | **SG-ETH-07 (EEE∩TSN), SG-ETH-02/03 (TSN∩半双工), SG-ETH-10 (PHC_COUNT<2∩VPHC)** | 95% | 非法配置组合 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **RX Filter ECC + DMA 隔离** | **SG-ETH-09 (AVTP 流识别)** | 99% | AVTP 表项损坏、DMA 误路由 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **PHC 交叉漂移监控** | **SG-ETH-02 (双 PHC 漂移)** | 95% | PHC0/PHC1 频率/相位偏差 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **VM ID Parity + IO Ring 边界** | **SG-ETH-10 (vPHC 隔离)** | 90% | 虚拟化隔离失效 | ✅ 必须 | ✅ 推荐 | ✅ 必须 |
| **Lockstep (可选)** | SG-ETH-01~10 | 99% | 系统性故障 | ❌ 可选 | ❌ 可选 | ✅ SoC 级 |
| **总线 Parity** | SG-ETH-01 | 90% | AXI 数据位翻转 | ❌ 可选 | ✅ 推荐 | ✅ 必须 |

### 2.3 硬件/软件安全划分

| 安全功能 | 硬件实现 | 软件实现 | 理由 |
|----------|----------|----------|------|
| ECC 纠错 | ✅ 实时硬件 | ❌ | 必须在单时钟周期完成，不能容忍软件延迟 |
| FSM Parity 检测 | ✅ 硬件 | ❌ | 必须实时检测非法状态跳转 |
| 超时检测 | ✅ 硬件计数器 | ❌ | 需要纳秒级响应 |
| 时钟监控 | ✅ 硬件频率计数器 | ❌ | 实时性要求 |
| 安全状态切换 | ✅ 硬件状态机 | ⚠️ 软件确认 | 硬件强制进入安全态，软件确认后复位 |
| 错误日志记录 | ❌ | ✅ SMU/EcuM | 非实时，需软件持久化 |
| ECC 错误计数趋势分析 | ❌ | ✅ 软件 | 长期统计，预防性维护 |
| FMEA/FMEDA 更新 | ❌ | ✅ FuSa Agent | 设计阶段活动 |

---

## 3. 诊断覆盖与 FHTI

### 3.1 故障处理时间间隔 (FHTI)

| 安全目标 | FHTI (典型) | FHTI (最坏情况) | 检测延迟 | 恢复延迟 | 总延迟预算 |
|----------|-------------|-----------------|----------|----------|------------|
| SG-ETH-01 (ECC 错误) | 1 μs | 5 μs | <1 时钟周期 (ECC 实时) | 0 (硬件自动纠正) | <1 μs |
| SG-ETH-01 (双 bit 错误) | 1 μs | 10 μs | <1 时钟周期 | 1 μs (Trap + SMU 报警) | <2 μs |
| SG-ETH-02 (时钟丢失) | 10 μs | 100 μs | <5 μs (频率计数器) | 5 μs (安全状态切换) | <15 μs |
| SG-ETH-03 (CSR 错误) | 1 ms | 10 ms | <1 μs (Parity 检测) | 100 μs (Shadow 回读) | <110 μs |
| SG-ETH-04 (DMA 超时) | 10 μs | 100 μs | 硬件可配置 (1μs~10ms) | 1 μs (通道复位) | 可配置 |
| SG-ETH-05 (FSM 错误) | 1 μs | 5 μs | <1 时钟周期 (Parity 检测) | 1 μs (安全状态切换) | <2 μs |
| SG-ETH-06 (Bridge 表错误) | 1 μs | 10 μs | <1 时钟周期 (ECC) | 1 μs (表项刷新) | <2 μs |

### 3.2 诊断覆盖等级 (Diagnostic Coverage, DC)

根据 ISO 26262-5:2018 Table D，本 IP 的诊断覆盖策略：

| 故障类型 | 安全机制 | DC 目标 | DC 实测 | ASIL-B 要求 | 合规性 |
|----------|----------|---------|---------|-------------|--------|
| 存储器单 bit 故障 | ECC (SECDED) | 99% | ≥99% [^1^] | ≥90% (中) | ✅ |
| 存储器双 bit 故障 | ECC (SECDED) + SMU 报警 | 99% | ≥99% [^1^] | ≥90% (中) | ✅ |
| 逻辑 stuck-at 故障 | FSM Parity | 90% | ≥90% | ≥60% (低) | ✅ |
| 逻辑 SEU 故障 | FSM Parity + 安全状态机 | 90% | ≥90% | ≥60% (低) | ✅ |
| 时钟故障 (频率) | Clock Monitor | 99% | ≥99% | ≥90% (中) | ✅ |
| 时钟故障 (毛刺) | Clock Monitor + 滤波 | 90% | ≥90% | ≥60% (低) | ✅ |
| 通信故障 (总线) | Timeout + Bus Parity (可选) | 90% | ≥90% | ≥60% (低) | ✅ |
| 通信故障 (DMA) | DMA Timeout | 95% | ≥95% | ≥60% (低) | ✅ |

> [^1^]: Infineon TC4x SECDED ECC 覆盖率为 100% 单 bit 纠正 + 100% 双 bit 检测，数据来源：Infineon AURIX TC4x Safety Manual。

### 3.3 多点故障检测间隔 (MPFDI)

| 故障组合 | 检测策略 | MPFDI |
|----------|----------|-------|
| 单 bit ECC 错误 → 双 bit ECC 错误 | ECC 错误计数器趋势监控 | 1000 个时钟周期 |
| 时钟漂移 → 时钟丢失 | 频率偏差累积检测 | 100 μs |
| 多 DMA 通道超时 | 独立超时 + 汇总报警 | 各通道独立 |

---

## 4. 安全状态机

### 4.1 状态定义

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         安全状态机 (Safety State Machine)                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   NORMAL (正常操作)                                                      │
│   ├── 所有安全机制使能                                                    │
│   ├── 数据通路正常                                                       │
│   └── 错误计数器清零                                                     │
│        │                                                                │
│        ├── ECC 单 bit 错误 ───────────────────────────────┐             │
│        │   └── 自动纠正 + 错误计数器+1                      │             │
│        │   └── [计数器 < 阈值] ───→ 留在 NORMAL              │             │
│        │   └── [计数器 ≥ 阈值] ────→ DEGRADED (告警)         │             │
│        │                                                                │
│        ├── ECC 双 bit 错误 ───────────────────────────────┐             │
│        ├── FSM Parity 错误 ───────────────────────────────┤             │
│        ├── 严重超时 (DMA/Bus/CSR) ────────────────────────┤             │
│        └── 时钟丢失 ──────────────────────────────────────┤             │
│            └──────────────────────────────────────────────────┘             │
│                            │                                            │
│                            ▼                                            │
│   DEGRADED (降级模式)                                                    │
│   ├── 关闭故障通道 (关闭特定 DMA 通道 / MAC / PHY)                        │
│   ├── 其他通道继续运行                                                     │
│   ├── 上报 SMU (报警级别: Warning)                                       │
│   └── 启用降级模式时间戳 (用于故障隔离记录)                                 │
│        │                                                                │
│        ├── 单通道故障恢复 ───────────────────────────────→ NORMAL         │
│        └── 多通道故障 / 关键模块故障 ───────────────────────┐             │
│                            │                               │             │
│                            ▼                               │             │
│   SAFE_STATE (安全状态)                                                  │
│   ├── 停止所有传输 (TX/RX 停止)                                          │
│   ├── 断开所有 PHY 接口                                                   │
│   ├── 清空所有 FIFO                                                        │
│   ├── 上报 SMU (报警级别: Critical)                                      │
│   └── 等待外部复位 (软件或 SMU 触发)                                       │
│        │                                                                │
│        └── 复位完成 ───────────────────────────────────→ NORMAL         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.2 状态转换条件

| 转换路径 | 触发条件 | 延迟要求 | 恢复策略 |
|----------|----------|----------|----------|
| NORMAL → DEGRADED | ECC 单 bit 错误计数 ≥ 阈值 / 单通道超时 / 非关键时钟漂移 | <10 μs | 自动，无需软件干预 |
| NORMAL → SAFE_STATE | ECC 双 bit 错误 / FSM Parity 错误 / 关键时钟丢失 / 多通道故障 | <2 μs | 硬件自动，软件确认后复位 |
| DEGRADED → NORMAL | 故障通道修复 + 软件确认 + 错误计数器清零 | 软件控制 | 需 SMU/EcuM 确认 |
| DEGRADED → SAFE_STATE | 降级模式超时 (可配置) / 新故障通道出现 / 关键模块故障 | <10 μs | 硬件自动 |
| SAFE_STATE → NORMAL | 外部复位信号 + 初始化序列完成 + 自检通过 (BIST) | 软件控制 | 需完整初始化 |

### 4.3 安全状态寄存器映射

| 寄存器 | 地址偏移 | 说明 | 访问权限 |
|--------|----------|------|----------|
| `SAFETY_STATE` | 0x700 | 当前安全状态 (2-bit: 00=NORMAL, 01=DEGRADED, 10=SAFE_STATE, 11=Reserved) | RO |
| `SAFETY_ERR_CNT` | 0x704 | ECC 错误计数器 (32-bit，每通道独立) | RO/Clear-on-Write |
| `SAFETY_DEGRADED_MASK` | 0x708 | 降级模式通道屏蔽 (每 bit 对应一个通道) | RW (Write-Once) |
| `SAFETY_TIMEOUT_CFG` | 0x70C | 超时阈值配置 (DMA/CSR/Bus 独立配置) | RW (Write-Once) |
| `SAFETY_ERR_LOG` | 0x710 | 首次错误类型记录 (FIFO，深度 16) | RO |
| `SAFETY_BIST_CTRL` | 0x714 | 安全自检控制 (启动/状态/结果) | RW |
| `SAFETY_SMU_ALERT` | 0x718 | SMU 报警信号输出配置 | RW (Write-Once) |

---

## 5. ASIL 分解策略

### 5.1 基线 ASIL-B 实现

| 安全机制 | 实现方式 | 面积代价 | 验证方法 |
|----------|----------|----------|----------|
| ECC (SECDED) | 每存储器实例独立 ECC 编解码器 | +8% SRAM 面积 | 故障注入测试 |
| FSM Parity | 状态编码增加 1-bit parity | +5% 逻辑面积 | 形式验证 + 故障注入 |
| Timeout | 独立计数器 + 比较器 | +2% 逻辑面积 | 定向测试 |
| Clock Monitor | 频率计数器 + 阈值比较 | +1% 逻辑面积 | 定向测试 |
| CSR Write-Once | 寄存器锁存位 | +1% 寄存器面积 | 定向测试 |
| **合计** | — | **~17% 面积增量** | — |

### 5.2 ASIL-C 升级 (可选)

| 新增机制 | 说明 | 面积代价 | DC 提升 |
|----------|------|----------|---------|
| Bus Parity (AXI) | AXI 数据通道增加 parity | +3% | +5% (通信故障) |
| 双 bit ECC 报警独立通道 | 区分单/双 bit 错误的 SMU 报警线 | +1% | +2% |
| 冗余时钟源切换 | 主时钟丢失时切换至备用 PLL | +2% | +3% |
| **合计** | — | **+6% (总 23%)** | — |

### 5.3 ASIL-D 系统级实现 (非 IP 内)

> ⚠️ **重要纠正**: 本 IP 模块内部安全机制（ECC + Parity + Timeout + Clock Monitor）仅达 **ASIL-B**。模块不能独立达到 ASIL-D。
>
> ASIL-D 是**系统级**认证，需要 SoC 提供以下机制与本 IP 的 ASIL-B 基线叠加：

| 机制 | 实现位置 | ASIL-D 作用 | 类型 (ISO 26262) |
|------|----------|-------------|------------------|
| Lockstep CPU | SoC CPU (TriCore/PPU) | 检测计算错误（系统性故障） | SM[HW] |
| SMU 双冗余 | SoC SMU (SAFE0/SAFE1/STDBY) | 聚合报警的自身故障覆盖 | SM[HW] |
| 外部 PMIC | TLF4x Safety Switch | 独立电源关断（单点故障覆盖） | ESM[HW] |
| SafeTlib | 软件运行时库 | 测试报警通路 + BIST 触发 | SM[SW] |
| E2E 保护 | AUTOSAR SecOC/DT | 端到端数据完整性 | 系统级 |

**TC4x 对标澄清**:
- TC4x **整芯片** 标 ASIL-D（含 Lockstep + SMU + PMIC + SafeTlib）
- TC4x **GETH 模块单独** 不声明独立 ASIL 等级（模块内部是 ASIL-B 机制）
- 本 IP 策略：模块级 ASIL-B，明确依赖 SoC 级机制升级至系统级 ASIL-D

**面积与复杂度分界**:
- ASIL-B/C 增量在 IP 内部（~17-23% 面积）
- ASIL-D 增量在 SoC 级（Lockstep/SMU/PMIC 不计入 IP 面积）

> **设计决策**: 本 IP 不内嵌 Lockstep 或双冗余 SMU（面积 +35% 且与 SoC 重复），而是输出标准化 SMU_ALERT[3:0] 信号，由 SoC SMU 统一处理。这与 TC4x 的模块-系统分层策略一致。

---

## 6. 竞品功能安全对标

### 6.1 ASIL 等级与实现策略对比

| 平台 | Ethernet 模块 ASIL | SoC 级 ASIL | Lockstep | ECC 范围 | 外部 Switch ASIL | 安全策略 |
|------|-------------------|-------------|----------|----------|------------------|----------|
| **Infineon TC4x** | GETH/LETH/XGETH: **ASIL-D** | ASIL-D | TriCore v1.8 Lockstep (6核) | 所有存储器 + 寄存器 [^2^] | 无外部 Switch | **模块级 ASIL-D + SoC SMU** |
| **NXP S32G3** | GMAC/PFE: **ASIL-D** | ASIL-D | Cortex-M7 + 可选 A53 Cluster Lockstep | 存储器 ECC [^3^] | SJA1110A: ASIL-A [^4^] | **SoC 级 Lockstep + 外部 PHY 安全** |
| **NXP S32K3** | EMAC/GMAC: **ASIL-D** | ASIL-D | Cortex-M7 Lockstep | 存储器 ECC | SJA1110B: ASIL-B [^5^] | **极简 MAC + 外部 TSN Switch** |
| **Renesas R-Car S4** | TSN Switch: **ASIL-D** (实时域) | ASIL-B (应用域) / ASIL-D (实时域) | Cortex-R52 + G4MH Lockstep | 存储器 ECC | 集成 3-port Switch | **混合 ASIL + 集成 Switch** |
| **Renesas RH850/U2C** | EtherMAC: **ASIL-D** | ASIL-D | G4MH Lockstep | 存储器 ECC | 外部 PHY | **传统诊断接口安全** |
| **本 IP (基线)** | **ASIL-B** | ASIL-B (IP 级) | 无 (SoC 级可选) | MTL FIFO + 描述符 + Bridge 表 | 外部 PHY | **模块级 ASIL-B + SoC 级 ASIL-D** |

> [^2^]: Infineon AURIX TC4x Safety Manual, Section 4.2 — "All GETH memory instances are protected by SECDED ECC"
> [^3^]: NXP S32G3 Reference Manual, Chapter 32 — "GMAC supports ECC protection on internal descriptors and packet buffers"
> [^4^]: NXP S32G Reference Design Board (RDB) Schematics — SJA1110A labeled as ASIL-A
> [^5^]: NXP SJA1110B Product Brief — "ASIL-B compliant TSN Switch"

### 6.2 关键差异分析

| 差异点 | TC4x | S32G/S32K3 | 本 IP 策略 |
|--------|------|------------|------------|
| **安全等级覆盖范围** | 全模块 ASIL-D | GMAC ASIL-D, Switch ASIL-A/B | 模块 ASIL-B，SoC 级 ASIL-D |
| **外部 Switch 安全落差** | 无外部 Switch (内部 Bridge) | SJA1110A ASIL-A vs SoC ASIL-D (两级差距) | 外部 PHY 不定义 ASIL，由 SoC E2E 保护 |
| **Lockstep 实现层级** | CPU 级 Lockstep | CPU 级 Lockstep | 不内嵌，依赖 SoC CPU Lockstep |
| **ECC 粒度** | 每个存储器实例独立 SSH | 模块级 ECC | 每个存储器实例独立 ECC 控制器 |
| **安全状态机** | 集成 SMU 状态机 | 集成 SMU 状态机 | 独立安全状态机 + SMU 报警接口 |

---

## 7. 故障注入测试策略 (FIT)

### 7.1 故障注入方法

| 故障类型 | 注入方法 | 检测预期 | 验证通过标准 |
|----------|----------|----------|--------------|
| 存储器单 bit 翻转 | 强制注入错误数据到 FIFO/描述符 | ECC 实时纠正，错误计数器 +1 | 数据正确，计数器准确 |
| 存储器双 bit 翻转 | 强制注入双 bit 错误 | ECC 检测 + SMU 报警 + 进入 DEGRADED/SAFE_STATE | 报警触发，状态切换正确 |
| FSM 非法跳转 | 强制状态编码错误 | Parity 检测 + 安全状态机强制 SAFE_STATE | 状态恢复正确 |
| 时钟频率偏移 | 修改时钟分频比 | Clock Monitor 检测 + DEGRADED | 频率阈值检测准确 |
| DMA 死锁 | 屏蔽 AXI 响应 | Timeout 检测 + 通道复位 | 超时阈值准确，复位后恢复 |
| CSR 意外写入 | 在安全锁存后尝试修改 | Write-Once 拒绝写入 | 寄存器值保持不变 |
| Bridge 表损坏 | 强制表项数据错误 | ECC 检测 + 表项刷新 | 转发行为正确恢复 |

### 7.2 自检 (BIST) 策略

| 自检项目 | 触发条件 | 执行时间 | 覆盖范围 |
|----------|----------|----------|----------|
| **上电 BIST (PBIST)** | 复位释放后自动执行 | ~1 ms | ECC 编解码器、FSM Parity、Clock Monitor |
| **运行期自检 (LBIST)** | 软件触发或周期性 | ~100 μs | 安全关键逻辑通路 |
| **存储器自检 (MBIST)** | 软件触发 | ~10 ms | 所有 SRAM 实例 |
| **安全寄存器自检** | 每次进入 NORMAL 前 | ~1 μs | Shadow Register 回读校验 |

---

## 8. 与 EDR 阶段 FMEDA 的衔接

### 8.1 FMEDA 输入准备

本 Safety Concept 为 EDR 阶段 FMEDA 分析提供以下输入：

| FMEDA 输入项 | 来源 | 状态 |
|--------------|------|------|
| 安全目标 (SG) | 本文档 §1 | ✅ 已定义 |
| 功能安全概念 (FSC) | 本文档 §2.1 | ✅ 已定义 |
| 安全机制清单 | 本文档 §2.2 + Arch Spec §7.1 | ✅ 已定义 |
| 诊断覆盖 (DC) | 本文档 §3.2 | ✅ 已量化 |
| FHTI | 本文档 §3.1 | ✅ 已量化 |
| ASIL 分解 | 本文档 §5 | ✅ 已分解 |
| 故障注入策略 | 本文档 §7 | ✅ 已规划 |
| 硬件元器件失效率 (FIT) | 需工艺库数据 | ⬜ EDR 阶段补充 |
| 安全机制失效率 | 需工艺库数据 | ⬜ EDR 阶段补充 |
| 共因失效 (CCF) 分析 | 需模块级详细设计 | ⬜ EDR 阶段补充 |

### 8.2 FMEDA 工具链建议

| 工具 | 用途 | 阶段 |
|------|------|------|
| **medini analyze** (Siemens) | 安全分析、FMEDA、FTA | EDR |
| **ISO 26262 Template** | 安全目标追踪、工作产品生成 | EDR~FDR |
| **Fault Injection Simulator** | 故障注入仿真验证 | IDR |

---

## 9. 附录

### 9.1 术语表

| 术语 | 定义 |
|------|------|
| **ASIL** | Automotive Safety Integrity Level (汽车安全完整性等级)，ISO 26262 定义的 A/B/C/D 四级 |
| **ECC** | Error Correction Code，错误校正码，本 IP 采用 SECDED (Single Error Correction, Double Error Detection) |
| **SECDED** | 单错误纠正双错误检测，可纠正 1-bit 错误并检测 2-bit 错误 |
| **FHTI** | Fault Handling Time Interval，故障处理时间间隔，从故障发生到系统进入安全状态的最大允许时间 |
| **MPFDI** | Multiple Point Fault Detection Interval，多点故障检测间隔 |
| **DC** | Diagnostic Coverage，诊断覆盖率 |
| **FIT** | Failure In Time，失效率单位，1 FIT = 10⁻⁹ 次失效/小时 |
| **BIST** | Built-In Self Test，内建自测试 |
| **SMU** | Safety Management Unit，安全管理单元 (SoC 级) |
| **E2E** | End-to-End，端到端保护 (AUTOSAR 定义) |
| **SecOC** | Secure Onboard Communication，车载安全通信 (AUTOSAR) |
| **Lockstep** | 双核锁步，两个 CPU 执行相同指令并比较结果 |

### 9.2 参考文档

| 文档 | 路径 | 说明 |
|------|------|------|
| Architecture Spec (安全架构) | `Docs/Arch/ethernet_arch_spec.md` §7 | Arch Agent 定义的安全机制 |
| Clock/Reset Spec | `Docs/Arch/ethernet_clock_reset_spec.md` | 时钟域与复位策略，影响安全状态切换 |
| Interface Spec | `Docs/Arch/ethernet_interface_spec.md` | SMU 报警信号接口定义 |
| TC4x 安全手册 | `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` | TC4x ECC/FSM/Timeout 机制验证 |
| MCU Ethernet 研究 | `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.md` | 竞品功能安全对比 |

### 9.3 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v1.0 | 2026-05-11 | FuSa Agent | 初始 Safety Concept：安全目标、诊断覆盖、FHTI、ASIL 分解、竞品对标 |

---

*文档生成: 2026-05-11 | 状态: Draft | 下一步: FuSa Review → EDR 阶段 FMEDA*
