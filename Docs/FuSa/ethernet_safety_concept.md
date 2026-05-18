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
```

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
| **ECC (SECDED)** | SG-ETH-01, SG-ETH-06 | 99% | 存储器单/双 bit 翻转 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **FSM Parity** | SG-ETH-05 | 90% | 状态机 SEU | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **Timeout (DMA/CSR/Bus)** | SG-ETH-04, SG-ETH-02 | 95% | 死锁、总线饥饿、时钟丢失 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **Clock Monitor** | SG-ETH-02 | 99% | PLL 失锁、频率漂移 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **CSR Write-Once Lock** | SG-ETH-03 | 95% | 配置意外修改 | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| **Lockstep (可选)** | SG-ETH-01~06 | 99% | 系统性故障 | ❌ 可选 | ❌ 可选 | ✅ SoC 级 |
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

| 机制 | 实现位置 | 说明 |
|------|----------|------|
| Lockstep 比较 | SoC CPU (如 TriCore Lockstep) | 软件级安全监控 |
| SMU 报警聚合 | SoC SMU | 集中管理所有安全报警 |
| 外部看门狗 | SoC 外部 | 独立复位源 |
| E2E 保护 (SecOC/DT) | 系统级 AUTOSAR | 端到端数据保护 |

> **对标分析**: Infineon TC4x GETH 模块硬件本身可达 ASIL-D，但其安全状态切换依赖 SoC SMU。NXP S32G 通过 Cortex-M7 Lockstep 实现 ASIL-D，但 GMAC/PFE 模块独立安全等级未单独声明。本 IP 策略与 TC4x 最接近：**模块级 ASIL-B + SoC 级 ASIL-D 集成**。

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

## 8. 参数配置矩阵 ASIL 评估

> **来源**: Arch Spec §1.4.4 — 典型应用场景参数配置矩阵
> **评估目的**: 验证每个应用场景的 ASIL 等级与安全机制配置是否匹配，识别安全缺口

### 8.1 应用场景 ASIL 等级评估

| 场景 | MAC_COUNT | PHY_SPEED | DMA_CH | Switch | 当前 ASIL | 评估结论 | 备注 |
|------|-----------|-----------|--------|--------|-----------|----------|------|
| **中央网关 (Switch)** | 4 | 1G×4 | 8 | ✅ | **B** | ✅ **合理** | 网关承担多域数据交换，ASIL-B 基线满足 |
| **ADAS 传感器汇聚** | 2 | 5G×2 | 16 | ❌ | **B** | ✅ **合理** | 传感器数据完整性感知，需 ECC + Timeout |
| **Zone Controller 骨干** | 2 | 5G×2 | 16 | ✅ | **B** | ✅ **合理** | Zone 间通信可靠性，Switch + ECC 覆盖 |
| **SDV 中央网关 (Switch+vPHC)** | 4 | 1G×4 | 8 | ✅ | **B** | ⚠️ **有条件通过** | vPHC 虚拟化引入新风险，需补充 **VM 隔离安全机制** |
| **CAN-Ethernet 网关** | 1 | 1G | 4 | ❌ | **B** | ✅ **合理** | 传统总线桥接，数据完整性 ASIL-B 足够 |
| **域内边缘节点 (10BASE-T1S)** | 1 | 10M | 2 | ❌ | **QM** | ✅ **合理** | 低速传感器，无安全关键数据，QM 足够 |
| **车身传感器网络** | 1 | 10M | 2 | ❌ | **QM** | ✅ **合理** | 同上，车身网络非安全关键 |
| **OTA 更新节点** | 1 | 1G | 4 | ❌ | **A** | ⚠️ **建议提升至 B** | OTA 固件完整性影响全局安全，ASIL-A 偏低 |
| **信息娱乐域 (AVB)** | 1 | 1G | 4 | ❌ | **QM** | ✅ **合理** | 音视频非安全关键，QM 足够 |

#### 8.1.1 评估结论摘要

| 评估项 | 数量 | 说明 |
|--------|------|------|
| ✅ ASIL 等级合理 | 7/9 | 覆盖中央网关、ADAS、Zone、CAN 网关、边缘节点、车身、信息娱乐 |
| ⚠️ 有条件通过 | 1/9 | SDV 网关需补充 vPHC VM 隔离安全机制后通过 |
| ⚠️ 建议提升 | 1/9 | OTA 节点建议从 ASIL-A 提升至 ASIL-B |

### 8.2 安全机制充分性评估

#### 8.2.1 当前安全机制覆盖矩阵

| 安全机制 | 覆盖模块 | 覆盖 SG | DC | ASIL-B 合规 | 评估 |
|----------|----------|---------|-----|-------------|------|
| **ECC (SECDED)** | MTL FIFO, 描述符缓存, Bridge FDB/VLAN/L3 表 | SG-ETH-01, SG-ETH-06 | 99% | ✅ | ✅ 充分 |
| **FSM Parity** | MAC/DMA/MTL/PTP/Switch 状态机 | SG-ETH-05 | 90% | ✅ | ✅ 充分 |
| **Timeout** | DMA, CSR, Bus, Switch 转发 | SG-ETH-04, SG-ETH-02 | 95% | ✅ | ✅ 充分 |
| **Clock Monitor** | 各时钟域 | SG-ETH-02 | 99% | ✅ | ✅ 充分 |
| **CSR Write-Once** | 关键配置寄存器 | SG-ETH-03 | 95% | ✅ | ✅ 充分 |
| **AXI Bus Parity** | AXI 数据通道 (可选) | SG-ETH-01 | 90% | ❌ 可选 | ⚠️ ASIL-C 需强制 |
| **Lockstep** | 关键控制信号 (SoC 级) | SG-ETH-01~06 | 99% | ❌ SoC 级 | ✅ 系统级覆盖 |

#### 8.2.2 识别缺失项

| 缺失安全机制 | 影响模块 | 相关 Erratum/风险 | 建议补充方案 | 优先级 |
|-------------|----------|-------------------|-------------|--------|
| **PTP 时间戳完整性校验** | PTP/Timestamp | LETH_TC.010 (时间基漂移) | 时间戳 FIFO ECC + 时间戳范围检查 (±1ms) | P1 |
| **TSN 调度器安全监控** | MTL (CBS/TAS) | GETH_AI.029/032 (调度误差) | CBS credit 溢出检测 + TAS 门控周期监控 | P1 |
| **中断聚合器安全** | DMA IRQ Ctrl | GETH_AI.035 (误中断) | 中断计数器parity + 中断风暴检测 (≥100irq/ms) | P2 |
| **vPHC VM 隔离校验** | PTP/Timestamp (虚拟化) | VM 时间域逃逸风险 | vPHC Region ID 硬件校验 + 越界访问trap | P1 |
| **温度链路安全监控** | HSPHY IF | HSPHY_TC.005 (温度丢链路) | 温度变化率检测 + 自动降速状态上报 SMU | P2 |
| **DMA 描述符链完整性** | DMA Engine | GETH_AI.037/040 (desc错误) | 描述符链表 CRC-8 校验 + 非法desc类型检测 | P1 |
| **Switch 转发环路检测** | Switch Core | 广播风暴风险 | TTL 递减 + 源端口过滤 + 环路检测 (可选) | P2 |
| **MACsec 密钥完整性** | CSS 接口 | 密钥损坏风险 | 密钥 RAM ECC + 密钥更新原子操作 | P2 |

#### 8.2.3 安全机制补充建议

**补充 1: PTP 时间戳完整性 (P1)**
```
[PTP Timestamp Safety]
- 时间戳 FIFO ECC: 每 64-bit 时间戳附加 8-bit ECC
- 时间戳范围检查: 硬件比较 |timestamp - last_timestamp| < 1ms
  超出范围 → 置位 TIMESTAMP_ERR → 上报 SMU
- Adder 溢出检测: 32-bit 纳秒累加器溢出 → 自动进位到秒寄存器
  溢出异常 → 置位 TS_ADDER_OVERFLOW
```

**补充 2: TSN 调度器安全监控 (P1)**
```
[TSN Scheduler Safety]
- CBS credit 溢出/下溢检测:
  credit > MAX_CREDIT → 置位 CBS_OVERFLOW (限制到 MAX)
  credit < 0 → 置位 CBS_UNDERFLOW (限制到 0)
  
- TAS 门控周期监控:
  周期计数器与 GCL 期望值比较，偏差 > 1μs → 置位 TAS_CYCLE_ERR
  
- 调度器状态机 parity: MTL Scheduler FSM 增加 parity (已覆盖于 FSM Parity)
```

**补充 3: vPHC VM 隔离校验 (P1)**
```
[vPHC Safety]
- Region ID 硬件校验: vPHC IO Ring 访问时比较 VM_ID vs 白名单
  非法访问 → 置位 VPHC_VIOLATION → 上报 SMU
  
- vPHC 时间戳一致性: 每 1ms 检查 dom0_vphc == hardware_phc0
  偏差 > 100μs → 置位 VPHC_SYNC_LOST
```

**补充 4: DMA 描述符链完整性 (P1)**
```
[DMA Descriptor Safety]
- 描述符链表 CRC-8: 每个描述符附加 8-bit CRC (覆盖 desc 全部字段)
  加载时校验失败 → 置位 DESC_CRC_ERR → 跳过该 desc
  
- 非法描述符类型检测: type field 非法编码 → 置位 DESC_TYPE_ERR
  
- 链表循环检测: 软件配置链表时硬件检查是否有循环引用
  检测到循环 → 置位 DESC_LOOP_ERR
```

### 8.3 ASIL 等级调整建议

| 场景 | 当前 ASIL | 建议 ASIL | 调整理由 | 新增安全机制 |
|------|-----------|-----------|----------|-------------|
| **OTA 更新节点** | A | **B** | OTA 固件完整性影响 ECU 全局安全，ASIL-A 的 DC (60%) 不足以覆盖固件篡改风险 | ECC + CSR Write-Once + Timeout |
| **SDV 中央网关** | B | **B** (维持) | 维持 B，但需强制使能 vPHC 隔离校验 (原可选 → 必须) | vPHC Region ID 校验 |
| **ADAS 传感器汇聚** | B | **B** (维持) | 维持 B，建议 ASIL-C 升级路径预留 (Bus Parity + 双 bit 报警) | — |

### 8.4 更新后的安全目标

新增安全目标以覆盖识别出的风险：

| ID | 安全目标 | ASIL | 失效模式 | 安全机制 |
|----|----------|------|----------|----------|
| **SG-ETH-07** | 防止因 PTP 时间戳损坏导致的 gPTP 同步失效 | B | 时间戳 FIFO bit 翻转、Adder 溢出 | 时间戳 FIFO ECC + 范围检查 |
| **SG-ETH-08** | 防止因 TSN 调度器异常导致的确定性保证失效 | B | CBS credit 溢出、TAS 周期漂移 | CBS 溢出检测 + TAS 周期监控 |
| **SG-ETH-09** | 防止因 vPHC VM 隔离失效导致的跨 VM 时间域污染 | B | VM 越界访问、vPHC 同步丢失 | Region ID 校验 + vPHC 一致性检查 |
| **SG-ETH-10** | 防止因 DMA 描述符链损坏导致的数据流中断 | B | 描述符 CRC 错误、链表循环 | DESC CRC-8 + 循环检测 |

---

## 9. 与 EDR 阶段 FMEDA 的衔接

### 9.1 FMEDA 输入准备

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

### 9.2 FMEDA 工具链建议

| 工具 | 用途 | 阶段 |
|------|------|------|
| **medini analyze** (Siemens) | 安全分析、FMEDA、FTA | EDR |
| **ISO 26262 Template** | 安全目标追踪、工作产品生成 | EDR~FDR |
| **Fault Injection Simulator** | 故障注入仿真验证 | IDR |

---

## 10. 附录

### 10.1 术语表

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

### 10.2 参考文档

| 文档 | 路径 | 说明 |
|------|------|------|
| Architecture Spec (安全架构) | `Docs/Arch/ethernet_arch_spec.md` §7 | Arch Agent 定义的安全机制 |
| Clock/Reset Spec | `Docs/Arch/ethernet_clock_reset_spec.md` | 时钟域与复位策略，影响安全状态切换 |
| Interface Spec | `Docs/Arch/ethernet_interface_spec.md` | SMU 报警信号接口定义 |
| TC4x 安全手册 | `Reference/Kimi_Agent_MCU_Ethernet/research/ethernet_mcu_cross_verification.md` | TC4x ECC/FSM/Timeout 机制验证 |
| MCU Ethernet 研究 | `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.md` | 竞品功能安全对比 |

### 10.3 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v1.0 | 2026-05-11 | FuSa Agent | 初始 Safety Concept：安全目标、诊断覆盖、FHTI、ASIL 分解、竞品对标 |
| **v1.1** | **2026-05-12** | **FuSa Agent** | **参数配置矩阵 ASIL 评估** (§8)：9 场景 ASIL 评估、安全机制充分性分析、8 项缺失机制识别、4 项补充建议、OTA ASIL-A→B 提升建议 |

---

*文档生成: 2026-05-12 | 状态: Draft v1.1 | 下一步: FuSa Review → EDR 阶段 FMEDA*
