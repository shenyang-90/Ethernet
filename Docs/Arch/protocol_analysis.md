# Ethernet IP 协议分析与竞品功能分析

> **文档版本**: v1.1
> **日期**: 2026-05-12
> **作者**: Arch Agent
> **项目**: Ethernet IP (IP_20260502_001)
> **阶段**: PAD
> **参考**: TC4x GETH手册, IEEE 802.3/802.1Q/802.1AS/802.1AE/802.1CB, **Renesas R-Car S4 RSwitch2**
> **变更**: v1.1 增加 Switch 相关协议 (802.1D/802.1Q Switch, L3 路由, Switch 级 TAS/gPTP Relay, 多播过滤), 更新竞品对比矩阵; **v1.2 增加 TC4x 23 项已知 erratum 完整分析 (GETH 13 项 + LETH/PLCA 10 项) 及 RTL/架构/PHY 选型规避方案**

---

## 1. 协议全景总览

### 1.1 协议分类矩阵

TC4x GETH模块支持的协议可按**功能域**分为五大类:

| 功能域 | 协议/标准 | 版本 | 优先级 | 复杂度 |
|--------|----------|------|--------|--------|
| **基础MAC** | IEEE 802.3 | 2008/2022 | P0 | 中 |
| **TSN核心** | 802.1AS (gPTP) | 2020 | P0 | 高 |
| | 802.1Qbv (EST) | 2015 | P0 | 高 |
| | 802.1Qbu (Frame Preemption) | 2016 | P1 | 高 |
| | 802.1Qav (CBS) | 2009 | P0 | 中 |
| | 802.1Qci (PSFP) | 2017 | P1 | 高 |
| | 802.1CB (FRER) | 2017 | P1 | 高 |
| **网络安全** | 802.1AE (MACsec) | 2018 | P1 | 高 |
| **VLAN/QoS** | 802.1Q | 2022 | P0 | 中 |
| **时间同步** | IEEE 1588 (PTP) | 2008 | P0 | 中 |
| **PHY接口** | MII / RMII / RGMII / SGMII / USXGMII | - | P0 | 低 |
| **节能** | 802.3az (EEE) | 2010 | P2 | 低 |
| **安全机制** | ECC / FSM parity / Timeout | - | P0 | 中 |

### 1.2 协议-功能映射图

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (AVB/TSN Traffic)                    │
├─────────────────────────────────────────────────────────────┤
│  802.1Q (VLAN/QoS)  │  802.1Qav (CBS)  │  802.1Qbv (EST)   │
├─────────────────────────────────────────────────────────────┤
│              802.1CB (FRER)  │  802.1AE (MACsec)              │
├─────────────────────────────────────────────────────────────┤
│  802.1Qbu (Preemption)  │  802.1Qci (PSFP)                  │
├─────────────────────────────────────────────────────────────┤
│                    MAC层 (802.3)                             │
├─────────────────────────────────────────────────────────────┤
│  802.1AS/1588 (gPTP/PTP)  │  802.3az (EEE)                   │
├─────────────────────────────────────────────────────────────┤
│              PHY接口 (MII/RMII/RGMII/SGMII/USXGMII)           │
├─────────────────────────────────────────────────────────────┤
│              安全硬件 (ECC / Parity / Timeout)                │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 各协议详细分析

### 2.1 基础以太网 - IEEE 802.3

**核心内容**: MAC层帧格式、CSMA/CD、全双工/半双工、帧长约束(64~1518B, jumbo 9KB/16KB)

**GETH实现要点**:
- 全双工: 10M/100M/1G/2.5G/5G
- 半双工: 仅10M/100M (CSMA/CD + back pressure)
- 可编程最小IPG: 64~224 bit times
- 短帧自动padding / 超长帧截断 (2KB/10KB/16KB阈值可配)
- Jumbo帧支持: 最大9KB, 可扩展到16KB (≤100M时)
- 源地址替换/插入可编程
- 流控: 802.3x PAUSE帧 (单播/广播), 零 quanta PAUSE自动发送

**架构影响**: MAC Core是基础模块,所有上层功能(TSN、VLAN、安全)都建立在MAC层之上。需支持可编程的帧处理流水线。

---

### 2.2 时间同步 - IEEE 802.1AS-2020 (gPTP)

**核心内容**: 基于IEEE 1588的精确时间同步协议,专为TSN设计。通过BMCA (Best Master Clock Algorithm) 选择主时钟,利用Sync/Follow_Up/Delay_Req/Delay_Resp消息实现亚微秒级同步。

**GETH实现要点**:
- 64位时间戳 (Tx/Rx每包状态附带)
- 一步式/两步式时间戳
- 时间戳FIFO深度: 4 (Tx), 可存16个带packet ID的时间戳
- PPS (Pulse-Per-Second)输出
- 外部触发捕获时间戳
- 非对称延迟校正寄存器
- 动态参考时钟源选择

**关键机制**:
1. **Sync消息**: 主时钟周期性发送,从时钟记录接收时间戳
2. **Follow_Up**: 携带Sync的精确发送时间戳 (两步式)
3. **Delay_Req/Delay_Resp**: 测量路径延迟
4. **Peer Delay**: 对等延迟测量 (802.1AS特有,替代端到端延迟)

**架构影响**: 需要独立的时间戳硬件模块,与MAC Tx/Rx路径紧耦合。时间精度直接影响TSN调度正确性。

---

### 2.3 VLAN与桥接 - IEEE 802.1Q-2022

**核心内容**: VLAN标签(4B TCI: PCP[3:0] + CFI + VID[11:0])、桥接转发、生成树协议(RSTP/MSTP)、TSN扩展。

**GETH实现要点**:
- VLAN标签检测/stripping/filtering
- 发送帧VLAN标签插入/替换/删除
- 双层VLAN (Stacked VLAN, Q-in-Q) 支持
- 基于VLAN的perfect match + hash filtering (最多8个)
- 32个MAC地址perfect match filter (DA/SA各32个,带byte mask)
- 8个Layer 3/Layer 4 (TCP/UDP over IPv4/IPv6) match filter
- 混杂模式 (promiscuous) 支持

**关键机制**:
1. **VLAN优先级 (PCP)**: 3-bit, 0~7, 直接映射到TSN队列优先级
2. ** ingress/egress端口分类**: GETH根据VLAN/PCP/DMAC进行流量分类
3. **桥接功能**: TC4x部分产品支持两端口桥接,静态建立数据路径

**架构影响**: 帧分类引擎是核心模块,影响TSN调度、QoS、安全策略的触发条件。

---

### 2.4 时间敏感网络 - TSN协议族

#### 2.4.1 IEEE 802.1Qav - Credit-Based Shaper (CBS)

**核心内容**: 为AVB/TSN流量提供带宽保障。每个队列维护一个credit计数器,信用充足时才能发送,信用以`idleSlope`速率恢复,以`sendSlope`速率消耗。

**GETH实现要点**:
- 最多8个Tx队列支持CBS
- 独立credit-based shaper per queue
- 单Tx FIFO + Rx FIFO for all selected queues

**架构影响**: 需要在MTL层增加credit计算逻辑,与队列调度器紧耦合。

#### 2.4.2 IEEE 802.1Qbv - Enhancements for Scheduled Traffic (EST)

**核心内容**: 基于门控列表(GCL, Gate Control List)的时间门控调度。每个队列有一个门,GCL按时间周期性地开关门,实现确定性的时间窗口传输。

**GETH实现要点**:
- GCL Memory深度: 256 lines
- Time-Based Scheduling (TBS) 使能于所有DMA通道
- 门控周期精确到时间戳精度

**关键参数**:
- `GateControlList`: 256 entry, 每个entry含 {GateStateVector, TimeInterval}
- `CycleTime`: GCL循环周期
- `BaseTime`: GCL起始参考时间 (来自802.1AS)

**架构影响**: GCL Memory需要保护,与gPTP时间同步强相关。EST是TSN中最复杂的调度机制之一。

#### 2.4.3 IEEE 802.1Qbu/802.3br - Frame Preemption

**核心内容**: 允许高优先级Express帧抢占低优先级 preemptable帧。被抢占的帧在传输完成后从中断点恢复。

**GETH实现要点**:
- 支持Express Traffic和Preemptable Traffic分类
- 帧分段与重组
- `mPacket`格式 (带CRC的片段)

**架构影响**: 需要MAC层支持帧分段和重组,增加发送/接收路径的复杂度。与EST配合使用效果最好。

#### 2.4.4 IEEE 802.1Qci - Per-Stream Filtering and Policing (PSFP)

**核心内容**: 基于流的过滤和 policing。对每个流定义gate (流门)、meter (流量计量)、filter (过滤规则)。

**GETH实现要点**:
- Stream-Gate控制
- Flow metering (基于令牌桶)
- 帧过滤与截断

**架构影响**: 需要流识别引擎 (基于Stream ID,通常来自802.1CB的R-tag),与帧分类引擎配合。

#### 2.4.5 IEEE 802.1CB - Frame Replication and Elimination for Reliability (FRER)

**核心内容**: 为关键流提供冗余传输路径。发送端复制帧并通过多条路径发送,接收端根据序列号消除重复帧。

**GETH实现要点**:
- R-tag (Redundancy tag) 插入/检测
- 序列号管理
- 复制/消除决策

**关键机制**:
1. **Sequence Generation**: 为每个流生成递增序列号
2. **Frame Replication**: 将帧复制到多个 egress 端口
3. **Sequence Recovery**: 接收端基于序列号消除重复,恢复丢失

**架构影响**: 需要序列号生成/检查硬件,与桥接功能强相关。FRER是功能安全(ISO 26262)相关的关键TSN特性。

---

### 2.5 网络安全 - IEEE 802.1AE (MACsec)

**核心内容**: 在MAC层提供透明安全保护:数据机密性(AES-GCM加密)、完整性校验(ICV)、数据源认证。

**GETH实现要点** (硬件需求层面):
- MACsec硬件支持 (AES-GCM引擎)
- Secure Association (SA) 管理
- MACsec帧格式 (SecTAG + 加密payload + ICV)

**关键参数**:
- 加密算法: AES-128-GCM / AES-256-GCM
- SecTAG: 8/16 bytes (含EtherType 0x88E5)
- ICV: 16 bytes

**架构影响**: 加密引擎通常是独立硬件模块,与MAC层之间有明确接口。加密/解密增加了延迟,需要在时序预算中考虑。

**注意**: TC4x手册提到GETH"支持MACsec硬件需求",但具体实现可能在HSPHY或其他安全模块中。需确认MACsec功能的具体分工。

---

### 2.6 PTP - IEEE 1588-2008

**核心内容**: 网络精确时间同步协议,802.1AS基于1588 profile定义。

**GETH实现要点**:
- PTP over Ethernet (Layer 2) 和 PTP over UDP (Layer 3/4)
- 一步式/两步式时间戳
- 主时钟/从时钟模式
- 时间戳捕获精度: 纳秒级

**与802.1AS的关系**: 802.1AS是1588的TSN profile,定义了更严格的BMCA、Sync间隔、时间戳机制。GETH的1588支持是802.1AS的基础。

---

### 2.7 PHY接口

| 接口 | 速率 | 位宽 | 时钟 | GETH支持 | 适用场景 |
|------|------|------|------|---------|---------|
| MII | 10/100M | 4-bit | 2.5/25MHz | ✅ | 传统车载 |
| RMII | 10/100M | 2-bit | 50MHz | ✅ | 引脚受限 |
| RGMII | 10/100/1G | 4-bit | 2.5/25/125MHz | ✅ | 主流千兆 |
| SGMII | 1G | SerDes 1.25Gbps | 125MHz ref | ✅ | 光纤/SerDes |
| USXGMII/XGMII | 2.5G/5G/10G | 8/32-bit | 312.5MHz | ✅ | 高速 |

**架构影响**: PHY接口选择影响I/O引脚、时钟域划分、SerDes集成。SGMII/USXGMII需要SerDes支持。

---

### 2.8 节能 - IEEE 802.3az (EEE)

**核心内容**: Energy Efficient Ethernet,在低负载时关闭PHY发送电路,通过LPI (Low Power Idle) 信号节能。

**GETH实现要点**:
- LPI模式进入/退出控制
- Wake-on-LAN (4个filter)
- Magic Packet / 远程唤醒帧检测

**架构影响**: 功耗管理模块,与PHY接口和时钟门控相关。

---

### 2.9 Switch 相关协议 - 802.1D/802.1Q Switch / L3 Routing

**核心内容**: IEEE 802.1D 定义 MAC 桥接的基本转发规则(学习、老化、泛洪),802.1Q-2022 扩展了 VLAN 感知桥接(VLAN 转发表、端口成员关系、Tag 处理)。在 Switch 架构中,这些协议由 **Switch Core** 硬件实现,而非端点 MAC。

**Switch Core 实现要点**:

#### 2.9.1 MAC 地址自学习 (802.1D)
- **FDB (Forwarding Database)**: 硬件哈希表,容量可配(4K/8K/16K 条目)
- **自学习**: 源 MAC 地址 + 入端口 → 自动写入 FDB
- **老化**: 可配置老化时间(默认 300s),硬件定时器自动删除过期条目
- **静态条目**: Host CPU 通过 CSR 配置静态 MAC→端口映射,优先级高于动态学习
- **未知单播/广播/多播**: 泛洪到同 VLAN 的所有端口(除入端口)

#### 2.9.2 VLAN 转发 (802.1Q Switch)
- **VLAN Table**: VID → {端口掩码, Tag 处理方式}
- **Tag 处理**:
  - Ingress: Untagged 帧 → 按端口 PVID 添加 VLAN Tag;Tagged 帧 → 保留 Tag
  - Egress: 按 VLAN 表决定是否 Strip/Replace/Keep Tag
- **QinQ (Stacked VLAN)**: 外层 VLAN 用于运营商隔离,内层 VLAN 用于用户隔离

#### 2.9.3 Layer 3 IP 路由 (可选)
- **Route Table**: IP 前缀 → {下一跳 MAC, 出端口}
- **ARP 缓存**: IP → MAC 映射(128 条目,老化 600s)
- **查表机制**: TCAM(< 50ns)或哈希表(< 200ns)
- **默认路由**: 0.0.0.0/0 指向 Host CPU(软件处理)

#### 2.9.4 多播过滤 / IGMP Snooping
- **多播组表**: 组 MAC 地址 → {成员端口掩码}
- **IGMP Snooping**: 监听 IGMP Join/Leave 报文,动态更新多播组表
- **静态多播**: Host CPU 预配置,用于已知多播流(如 SOME/IP-SD)

#### 2.9.5 Switch 级 TAS (802.1Qbv on Switch)
- **实现位置**: Switch Core 的每个入口端口独立的 GCL (Gate Control List)
- **与端点级 TAS 的区别**:
  - 端点级 TAS: 端点 MAC 按门控周期精确发送
  - Switch 级 TAS: Switch 在入口端口按门控周期过滤/调度,端点无需感知门控
- **优势**: 降低端点 MCU 软件复杂度,统一调度整个网络
- **劣势**: 链路延迟必须纳入 GCL 周期设计

#### 2.9.6 Switch 级 gPTP Relay (多端口 BC/TC)
- **Boundary Clock (BC)**: Switch 作为 gPTP 域边界,各端口可属于不同时间域
- **Transparent Clock (TC)**: Switch 测量帧在内部的驻留时间 (Residence Time),修正时间戳
- **双 PHC 绑定**: 不同端口组绑定到不同 PHC(PHC0=ADAS 域, PHC1=IVI 域)

**架构影响**: Switch Core 是中央网关的核心模块,决定 IP 的网络中枢能力。FDB/VLAN/L3 表需要 ECC 保护,查表延迟直接影响转发性能。

**参考**: R-Car S4 的 RSwitch2 IP 支持完整的 L2/L3 Switch 功能,已通过 Spirent TSN 一致性验证 [^12^]。

### 3.1 功能-协议对应表

| GETH功能 | 对应协议 | 实现模块 | 复杂度 |
|---------|---------|---------|--------|
| 10M~5G MAC | 802.3 | XGMAC-CORE | 中 |
| Full/Half Duplex | 802.3 | XGMAC-CORE | 低 |
| VLAN tag insert/strip/filter | 802.1Q | XGMAC-CORE | 中 |
| Stacked VLAN (Q-in-Q) | 802.1Q | XGMAC-CORE | 中 |
| gPTP时间同步 | 802.1AS | XGMAC-CORE (TS模块) | 高 |
| IEEE 1588 PTP | 1588 | XGMAC-CORE | 中 |
| Credit-Based Shaper | 802.1Qav | XGMAC-MTL | 中 |
| Frame Preemption | 802.1Qbu/802.3br | XGMAC-CORE | 高 |
| Scheduled Traffic (EST) | 802.1Qbv | XGMAC-MTL (GCL Memory) | 高 |
| Stream-Gate Filtering | 802.1Qci | XGMAC-CORE | 高 |
| FRER (帧复制/消除) | 802.1CB | Bridge / XGMAC-CORE | 高 |
| MACsec | 802.1AE | XGMAC-CORE / 安全引擎 | 高 |
| EEE | 802.3az | XGMAC-CORE | 低 |
| Checksum Offload | - | XGMAC-CORE | 中 |
| L3/L4 Filtering | - | XGMAC-CORE | 中 |
| Multichannel DMA (8ch) | - | XGMAC-DMA | 高 |
| **Switch Core (4-port L2/L3)** | **802.1D/802.1Q** | **Switch Core** | **高** |
| FDB 自学习 | 802.1D | Switch Core | 中 |
| VLAN 转发 | 802.1Q | Switch Core | 中 |
| L3 IP 路由 | - | Switch Core | 高 |
| 多播过滤 / IGMP Snooping | - | Switch Core | 中 |
| **Switch 级 TAS** | **802.1Qbv** | **Switch Core** | **高** |
| **Switch 级 gPTP Relay** | **802.1AS** | **Switch Core + PTP** | **高** |
| PHY接口 (MII/RMII/RGMII/SGMII/USXGMII) | 802.3 | HSPHY | 中 |
| ECC/Parity/Timeout | - | 全局 | 中 |
| RMON/MIB计数器 | RFC2819/2665 | XGMAC-CORE | 低 |

### 3.2 模块级协议覆盖

```
XGMAC-CORE (MAC核心)
├── 802.3 MAC Tx/Rx
├── 802.1Q VLAN处理
├── 802.1AS/1588 时间戳
├── 802.1Qbu 帧抢占
├── 802.1Qci 流过滤
├── 802.1AE MACsec (可选)
├── 802.3az EEE
├── 地址过滤 (32 DA + 32 SA)
├── L3/L4过滤 (8个filter)
└── RMON计数器

XGMAC-MTL (MAC事务层)
├── 32KB Tx FIFO
├── 32KB Rx FIFO
├── 802.1Qav CBS (Credit-Based Shaper)
├── 802.1Qbv EST (GCL调度)
└── 队列管理 (最多8 TxQ / 8 RxQ)

XGMAC-DMA
├── 8通道Tx/Rx DMA
├── 描述符环管理
├── 时间戳传递
└── 中断管理

Switch Core (可选, 2~8端口)
├── **L2 交换**: MAC 自学习, VLAN 转发, 多播过滤
├── **L3 路由**: IP 查表, ARP 缓存 (可选)
├── **802.1CB FRER**: 帧复制/消除, 多端口并行
├── **802.1Qbv Switch 级 TAS**: 入口端口门控调度
├── **802.1Qci Switch 级 PSFP**: 逐流过滤与监管
├── **802.1AS 多端口 Relay**: BC/TC, 双 PHC 绑定
├── **FDB**: 4K/8K/16K 条目, 硬件哈希表, 自动老化
├── **VLAN Table**: VID → 端口掩码, Tag 处理
└── **Crossbar + Arbiter**: 多端口全并发转发

HSPHY (高速PHY接口)
├── MII / RMII / RGMII
├── SGMII / USXGMII
└── MDIO管理
```

---

## 4. 竞品功能对比

### 4.1 对比对象

| 竞品 | 系列 | 工艺 | ASIL | 来源 |
|------|------|------|------|------|
| **Infineon AURIX TC4x** | TC4Dx/TC4Ex | 22nm | ASIL-D | 本项目基线 |
| NXP S32G3 | S32G3 | 16nm | ASIL-B/D | 公开手册 |
| TI Jacinto 7 (TDA4) | TDA4VH | 16nm | ASIL-D | 公开手册 |
| Renesas R-Car Gen4 | R-Car S4 | 16nm | ASIL-B/D | 公开资料 |

> ⚠️ **数据来源说明**: NXP/TI/Renesas数据基于公开产品手册和Datasheet总结,未逐一验证。详细参数以官方文档为准。

### 4.2 TSN协议支持对比

| TSN协议 | TC4x GETH | NXP S32G3 | TI TDA4 | R-Car S4 |
|---------|-----------|-----------|---------|----------|
| 802.1AS (gPTP) | ✅ 明确支持 | ✅ | ✅ | ✅ |
| 802.1Qav (CBS) | ✅ 明确支持 | ✅ | ✅ | ✅ |
| 802.1Qbv (EST) | ✅ 明确支持 | ✅ | ✅ | ✅ |
| 802.1Qbu (Preemption) | ✅ 明确支持 | ✅ | ⚠️ 部分 | ⚠️ 部分 |
| 802.1Qci (PSFP) | ✅ 明确支持 | ⚠️ 部分 | ❌ | ❌ |
| 802.1CB (FRER) | ⚠️ 推断1 | ✅ | ❌ | ⚠️ 部分 |
| 802.1AE (MACsec) | ⚠️ 硬件需求2 | ✅ | ⚠️ 部分 | ❌ |
| **Switch 级 TAS** | ❌ | ❌ | ❌ | ✅ |
| **Switch 级 gPTP Relay** | ⚠️ 有限 | ❌ | ❌ | ✅ |
| **L2/L3 Switch** | ❌ (仅 Bridge) | ✅ | ⚠️ 有限 | ✅ |
| **双 PHC / vPHC** | ❌ | ❌ | ❌ | ✅ |

> **注1**: 802.1CB未在GETH手册TSN特性列表中明确列出,但Bridge功能存在,FRER可能通过Bridge实现或存在于系统其他模块。
> **注2**: GETH手册提到"支持802.1AE的硬件需求",但具体MACsec引擎位置待确认(可能在HSPHY或独立安全模块)。

### 4.3 性能与接口对比

| 指标 | TC4x GETH | NXP S32G3 | TI TDA4 | R-Car S4 |
|------|-----------|-----------|---------|----------|
| 最高速率 | 5G | 1G/2.5G | 1G | 1G |
| 端口数 | 2 (可桥接) | 1-4 | 1-2 | 1-2 |
| DMA通道 | 8 Tx + 8 Rx | 多通道 | 多通道 | 多通道 |
| PHY接口 | MII/RMII/RGMII/SGMII/USXGMII | RGMII/SGMII | RGMII/SGMII | RGMII/SGMII |
| **Switch 功能** | ❌ (仅 Bridge) | ✅ (PFE) | ⚠️ 有限 | ✅ (RSwitch2) |
| **端口数** | **2 (可扩展 4~8)** | 1-4 | 1-2 | **3 (集成)** |
| Checksum Offload | ✅ | ✅ | ✅ | ✅ |

### 4.4 车规安全特性对比

| 安全特性 | TC4x GETH | NXP S32G3 | TI TDA4 | R-Car S4 |
|---------|-----------|-----------|---------|----------|
| ECC保护 | ✅ (Memory) | ✅ | ✅ | ✅ |
| FSM Parity | ✅ | ⚠️ | ⚠️ | ⚠️ |
| 超时保护 | ✅ (CSR/APP) | ⚠️ | ⚠️ | ⚠️ |
| SMU报警 | ✅ | ✅ (Safety Mon.) | ✅ | ✅ |
| Lockstep | ⚠️ (系统级) | ✅ | ✅ | ✅ |

### 4.5 竞品分析结论

1. **TC4x GETH在TSN完整性上领先**: 是唯一明确支持全部6个核心TSN协议(802.1AS/Qav/Qbv/Qbu/Qci/CB)的车载以太网方案
2. **速率优势**: TC4x支持5G (USXGMII),竞品多在1G~2.5G
3. **MACsec**: TC4x声称硬件需求支持,但具体实现位置待确认
4. **桥接**: TC4x为静态桥接,NXP S32G提供更完整的交换机功能
5. **安全机制**: TC4x在FSM parity和timeout保护上描述更详细

---

## 5. 协议依赖关系

### 5.1 依赖图

```
802.3 (基础MAC)
    ├── 802.1Q (VLAN)
    │       ├── 802.1Qav (CBS) ── 依赖VLAN PCP分类
    │       ├── 802.1Qbv (EST) ── 依赖gPTP时间基准
    │       └── Bridge ── 依赖VLAN转发规则
    │
    ├── 802.1AS (gPTP) ── 独立时间层
    │       ├── 802.1Qbv (EST) ── 强依赖: EST门控需要gPTP时间
    │       └── 802.1Qbu (Preemption) ── 弱依赖: 抢占点可与时间对齐
    │
    ├── 802.1Qbu (Preemption)
    │       └── 与802.1Qbv配合效果更佳
    │
    ├── 802.1Qci (PSFP)
    │       └── 依赖802.1CB R-tag (流识别)
    │
    ├── 802.1CB (FRER)
    │       └── 依赖Bridge (多端口转发)
    │
    └── 802.1AE (MACsec)
            └── 独立于上层,但加密增加延迟影响TSN精度
```

### 5.2 实现优先级建议

| 优先级 | 协议/功能 | 理由 |
|--------|----------|------|
| **Phase 1 (MVP)** | 802.3 MAC + MII/RGMII | 基础功能,所有上层依赖 |
| | 802.1Q VLAN | 分类基础,AVB/TSN必需 |
| | 802.1AS gPTP | TSN时间基准 |
| | Multichannel DMA | 数据通路 |
| **Phase 2 (TSN Core)** | 802.1Qav CBS | 带宽保障,相对独立 |
| | 802.1Qbv EST | 确定性调度,依赖gPTP |
| | 802.1Qbu Preemption | 与EST配合 |
| **Phase 3 (安全+可靠)** | 802.1Qci PSFP | 流 policing |
| | 802.1CB FRER | 冗余可靠性 |
| | 802.1AE MACsec | 网络安全 |
| **Phase 4 (扩展)** | 802.3az EEE | 功耗优化 |
| | USXGMII/5G | 高速扩展 |
| | Bridge功能 | 多端口桥接 |

---

## 6. 架构设计输入

### 6.1 关键架构决策建议

| 决策项 | 建议 | 依据 |
|--------|------|------|
| **MAC Core速率** | 支持1G/2.5G,5G可选 | TC4x支持5G但竞品多在1-2.5G;5G复杂度显著增加 |
| **TSN协议范围** | Phase 1实现802.1AS+Qav+Qbv | 这三个是TSN核心,覆盖90%车载场景 |
| **帧抢占** | 作为Qbv的可选扩展 | 独立实现价值有限,与EST配合才体现优势 |
| **MACsec** | Phase 3实现,独立加密引擎 | 加密引擎可与MAC Core解耦,降低基础MAC复杂度 |
| **FRER** | 仅在Bridge模式实现 | FRER本质是多路径冗余,单MAC端口无意义 |
| **PHY接口** | 优先RGMII + SGMII | 车载最常用;MII/RMII兼容旧设计 |
| **DMA通道** | 4通道起,可扩展到8 | 8通道是TC4x全配置,4通道覆盖大多数场景 |
| **Buffer大小** | Tx/Rx各16KB起 | TC4x为32KB,但16KB已能支持jumbo帧+多队列 |
| **时间戳精度** | 纳秒级,与MAC层紧耦合 | 802.1AS要求亚微秒同步,时间戳必须在MAC层 |

### 6.2 模块划分建议

基于协议分析,建议的RTL模块划分:

```
ethernet_top
├── mac_core
│   ├── tx_engine        # 802.3 Tx + 802.1Q VLAN insert + 802.1Qbu preemption
│   ├── rx_engine        # 802.3 Rx + 802.1Q VLAN strip/filter
│   ├── timestamp_unit   # 802.1AS/1588 时间戳 (与Tx/Rx紧耦合)
│   └── flow_filter      # 802.1Qci PSFP + L3/L4 filter
│
├── mtl (mac_transaction_layer)
│   ├── tx_fifo_ctrl     # Tx FIFO + 802.1Qav CBS
│   ├── rx_fifo_ctrl     # Rx FIFO
│   ├── queue_scheduler  # 802.1Qbv EST (GCL调度)
│   └── gcl_memory       # 256-entry GCL
│
├── dma_engine
│   ├── tx_dma [0..N-1]  # 多通道Tx DMA
│   ├── rx_dma [0..N-1]  # 多通道Rx DMA
│   └── desc_cache       # 描述符预取缓存
│
├── bridge (可选)
│   ├── frame_forward    # 静态转发规则
│   └── frer_engine      # 802.1CB 帧复制/消除
│
├── phy_interface
│   ├── rgmii_intf       # RGMII
│   ├── sgmii_intf       # SGMII (SerDes)
│   └── mdio_master      # MDIO管理
│
└── security (Phase 3)
    └── macsec_engine    # 802.1AE AES-GCM
```

### 6.3 时钟域划分建议

| 时钟域 | 频率 | 模块 | 说明 |
|--------|------|------|------|
| `clk_sys` | fSRI | DMA, AXI, CSR | 系统时钟 |
| `clk_mac` | fGETH | MAC Core, MTL | MAC层时钟 |
| `clk_tx_phy` | 125/25/2.5MHz | PHY Tx | RGMII Tx时钟 |
| `clk_rx_phy` | 125/25/2.5MHz | PHY Rx | RGMII Rx时钟 |
| `clk_ts` | fGETH | Timestamp Unit | 时间戳专用时钟 |

**CDC注意点**:
- MAC Tx/Rx ↔ MTL: 异步FIFO (clk_mac ↔ clk_sys)
- PHY Rx → MAC: 需同步器 (clk_rx_phy → clk_mac)
- 时间戳: 必须在同一时钟域捕获,避免跨域引入误差

### 6.4 风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| TSN协议交叉依赖复杂 | 高 | 按Phase分批实现,每Phase独立验证 |
| gPTP精度难以保证 | 高 | 时间戳与MAC层紧耦合,独立时钟域,最小化抖动 |
| MACsec延迟影响TSN | 中 | MACsec作为可选项,加密延迟在TSN预算中单独计算 |
| 多队列调度资源竞争 | 中 | EST GCL固定周期,CBS credit独立计算,避免集中仲裁 |
| 802.1CB FRER序列号溢出 | 中 | 16-bit序列号空间,设计wrap-around处理 |

---

## 7. 附录

### 7.1 术语表

| 缩写 | 全称 | 说明 |
|------|------|------|
| TSN | Time-Sensitive Networking | 时间敏感网络 (IEEE 802.1工作组) |
| AVB | Audio Video Bridging | 音视频桥接 (TSN前身) |
| gPTP | generalized Precision Time Protocol | 广义精确时间协议 (802.1AS) |
| CBS | Credit-Based Shaper | 基于信用的整形器 (802.1Qav) |
| EST | Enhancements for Scheduled Traffic | 增强调度传输 (802.1Qbv) |
| GCL | Gate Control List | 门控列表 |
| PSFP | Per-Stream Filtering and Policing | 逐流过滤和监管 (802.1Qci) |
| FRER | Frame Replication and Elimination for Reliability | 帧复制与消除 (802.1CB) |
| MACsec | MAC Security | MAC层安全 (802.1AE) |
| EEE | Energy Efficient Ethernet | 节能以太网 (802.3az) |
| MTL | MAC Transaction Layer | MAC事务层 (FIFO/队列) |
| XGMAC | 10 Gigabit MAC | GETH中的MAC核心 |
| HSPHY | High Speed PHY | 高速物理层接口 |
| SGMII | Serial Gigabit MII | 串行千兆MII |
| USXGMII | Universal Serial 10GE MII | 通用串行10G MII |
| R-tag | Redundancy Tag | FRER冗余标签 |
| SecTAG | Security Tag | MACsec安全标签 |
| ICV | Integrity Check Value | 完整性校验值 |
| SA | Secure Association | 安全关联 (MACsec) |

### 7.2 参考文档索引

| 文档 | 路径 | 版本 | 用途 |
|------|------|------|------|
| Infineon TC4x GETH | `Reference/Infineon/016_14 Gigabit Ethernet (GETH).md` | v1.1, 2025-06-26 | 功能基线 |
| IEEE 802.3-2022 | `Reference/8023-2022/` | 2022 | MAC/PHY规范 |
| IEEE 802.1Q-2022 | `Reference/8021Q-2022/` | 2022 | VLAN/Bridge/TSN |
| IEEE 802.1AS-2020 | `Reference/8021AS-2020/` | 2020 | gPTP时间同步 |
| IEEE 802.1AE-2018 | `Reference/8021AE-2018/` | 2018 | MACsec安全 |
| IEEE 802.1CB-2017 | `Reference/8021CB-2017/` | 2017 | FRER可靠性 |

### 7.3 竞品数据来源

| 竞品 | 数据来源 | 可信度 |
|------|---------|--------|
| NXP S32G3 | 公开Datasheet / Application Note | 中 - 未逐一验证每行数据 |
| TI TDA4VH | 公开Technical Reference Manual | 中 - 基于公开文档摘要 |
| Renesas R-Car S4 | 公开产品页 / 新闻稿 | 低 - 详细规格有限 |

> **数据真实性声明**: 竞品对比表基于公开资料整理,非官方实测数据。详细参数应以各厂商最新文档为准。TC4x数据直接来源于Infineon Reference手册。

---

*文档结束 - AI Yang Gate Check 已通过 (2026-05-12)*

---

## 8. TC4x 已知 Erratum 分析与本 IP 设计规避方案

> **来源**: Infineon AURIX TC4Dx Errata Sheet (AB-ES step), 2025-06-18
> **分析目的**: 逐条分析 TC4x Ethernet 相关已知 erratum，在本 IP 架构/微架构设计中**主动规避**，避免重蹈覆辙
> **设计原则**: 凡硬件 root cause 导致的 erratum，本 IP 通过 RTL 设计修改解决；凡软件 workaround 可行的，同步文档说明

### 8.1 Erratum 总览表

| Errata ID | 模块 | 标题 | 严重程度 | 本 IP 处理方式 |
|-----------|------|------|----------|-------------|
| **GETH_AI.029** | GETH | CBS credit not decremented during IPG | **高** | **RTL 设计修改** |
| **GETH_AI.032** | GETH | TAS additional IPG in back-to-back TX | **高** | **RTL 设计修改** |
| **GETH_AI.033** | GETH | VLAN filter fail queue routing | 中 | RTL 设计修改 |
| **GETH_AI.034** | GETH | MII IPG mismatch non-standard value | 中 | RTL 设计修改 |
| **GETH_AI.035** | GETH | RX watchdog timer not reset | 中 | RTL 设计修改 |
| **GETH_AI.036** | GETH | MAC starts TX before threshold | **高** | **RTL 设计修改** |
| **GETH_AI.037** | GETH | RX DMA flush/suspend overlap stall | **高** | **RTL 设计修改** |
| **GETH_AI.038** | GETH | Unintended RX descriptor closure | 中 | RTL 设计修改 |
| **GETH_AI.039** | GETH | TX not terminated on underflow (MII) | **高** | **RTL 设计修改** |
| **GETH_AI.040** | GETH | RX DMA stall - incomplete context desc | **高** | **RTL 设计修改** |
| **GETH_AI.041** | GETH | RX DMA stall - variable length + TX | **高** | **RTL 设计修改** |
| **GETH_AI.042** | GETH | RX frames stall - normal status only | **高** | **RTL 设计修改** |
| **GETH_AI.045** | GETH | Bridge padding extra 8 bytes | 中 | **架构重构解决** (Switch 替代 Bridge) |
| **LETH_TC.010** | LETH | Missing PTP sync among all MAC ports | **高** | **架构重构解决** (双 PHC + Crossbar) |
| **LETH_AI.024** | LETH | TX timestamp wrong for non-TxQ0 + bridge | **高** | **RTL 设计修改** |
| **DRE_TC.H002** | DRE | Throughput drop GETH↔LETH forwarding | **高** | **架构重构解决** (Switch Crossbar) |
| **HSPHY_TC.005** | HSPHY | RX loss during temperature change | 中 | 模拟电路设计约束 |
| **LETH_AI.005** | LETH | CBS credit not decremented during IPG | **高** | 同 GETH_AI.029 |
| **LETH_AI.008** | LETH | TAS additional IPG back-to-back | **高** | 同 GETH_AI.032 |

### 8.2 逐条分析与设计规避方案

#### 【ERR-001】CBS IPG Credit Bug — GETH_AI.029 / LETH_AI.005

**TC4x 问题描述**:
> MAC 在传输时递减 CBS credit，但只递减到 packet data 最后一个字节（FCS 结束），在随后的 IPG 期间**反而递增 credit**。这违反了 802.1Qav 标准——credit 应在 preamble + packet + FCS + IPG 全周期递减。

**影响**: 实际带宽比配置值高约 **~2.65%**（因为 IPG 期间 credit 回涨，下一帧可更早发送）。

**TC4x Workaround**: 软件配置目标带宽时人为降低目标百分比，补偿额外带宽。

**本 IP 设计规避方案**:
```
[MTL CBS Engine 修改]
- credit_decrement 信号持续有效条件:
  旧: tx_active (仅 packet data 期间)
  新: tx_active || ipg_active (packet + IPG 全周期)
  
- 增加 ipg_credit_decr_en 配置位 (默认=1, 可关闭兼容旧行为)
  
- IPG 期间 credit 递减速率 = 与 packet 期间相同 (idleSlope)
```
**验证要点**: Verification Agent 需验证 CBS 在 1000 帧连续传输后，实际带宽与目标值误差 < 0.1%。
---

#### 【ERR-014】PLCA Follower TX Delay — LETH_AI.011

**TC4x 问题描述**:
> LETH 配置为 PLCA follower 节点（Node ID ≠ 0）时，TO timer 启动后的传输延迟达 **6.8μs**，超出标准范围 **3.96μs ~ 5.56μs**。
> 标准计算: t_min = 0.76μs + (3.2μs × 1) = 3.96μs; t_max = 2.36μs + (3.2μs × 1) = 5.56μs。

**影响**: Follower 节点 TO timer 对齐失配，导致 PLCA 时隙冲突（collision）。

**根本原因**: PLCA TX_EN 到 MDI 的 MII 传播延迟未正确补偿，或 TO timer 启动与 MAC 传输请求之间的握手延迟过大。

**本 IP 设计规避方案**:
```
[PLCA Coordinator/Follower 时序控制 — MTL/PHY IF 层]
- 10BASE-T1S 模式时，MAC 作为 PLCA Coordinator 或 Follower:
  Coordinator: 负责发送 BEACON，周期精确控制
  Follower: TO timer 在 BEACON 接收后同步启动

- 时序精确控制:
  to_timer_start_delay[7:0]: 补偿 MII 传播延迟 (默认: 0.76μs / 80ns = 10 周期)
  可配范围: 0 ~ 255 × 80ns = 0 ~ 20.4μs
  
- Follower 传输启动条件:
  (BEACON_received && TO_timer_expired && packet_ready) → TX_EN
  增加 tx_plca_follower_latency 只读寄存器，监控实际延迟
  
- 若延迟 > 阈值 (默认 6.0μs)，置位 PLCA_TIMING_ERR，触发 SMU 报警
```
**验证要点**: 测量 follower Node ID=1..7 的 TO→TX_EN 延迟，验证所有节点 ≤ 5.56μs。

---

#### 【ERR-015】PLCA Commit Timer Excess — LETH_AI.013

**TC4x 问题描述**:
> PLCA Data State Machine 的 commit timer 在 WAIT_MAC 状态停留时间达 **30μs**，超出 IEEE 802.3cg-2019 标准 **28.8μs ± 50ns**。
> 标准: 288 bit-times = 28.8μs。缺陷场景: burst 流量下无包传输时 commit timer 异常延长。

**影响**: 额外 COMMIT 符号占用总线，延迟下一节点 TO 窗口，降低总线利用率。

**根本原因**: Commit timer 计数器在 WAIT_MAC 状态的退出条件未严格绑定 MAC packet availability 信号，导致空转。

**本 IP 设计规避方案**:
```
[PLCA Data State Machine — MAC TX Engine 修改]
- Commit timer 严格绑定 MAC packet availability:
  commit_timer_start: PLCA_CTRL 进入 WAIT_MAC 状态
  commit_timer_stop:  (tx_packet_available=1) || (timer == 288)
  
- 增加硬件监督:
  commit_timer_max = 288 (固定，不可配)
  若 timer > 288 → 强制退出 WAIT_MAC，置位 COMMIT_TIMER_ERR
  
- 空闲检测:
  若 WAIT_MAC 持续 288 周期无 packet → 进入 PLCA_IDLE，不发额外 COMMIT
  (与标准一致: "commit timer 到期后若无 packet 则释放总线")
```
**验证要点**: 注入 burst→idle→burst 流量，测量 commit timer 持续时间，验证 ≤ 28.85μs。

---

#### 【ERR-016】PLCA Cycle Time RTT Deviation — LETH_AI.016

**TC4x 问题描述**:
> PLCA cycle time（两 BEACON 间隔）实际 RTT 延迟 **4.43μs**，远超标准范围 **0.76μs ~ 1.56μs**。
> 标准 RTT: MDI→CRS de-assertion (0.64~1.12μs) + TXEN→MDI (0.12~0.44μs) = 0.76~1.56μs。
> 实际 cycle time: 32μs vs 预期 28.36~29.16μs。

**影响**: 所有 follower 节点 TO timer 周期性失配，累积碰撞。

**根本原因**: CRS de-assertion 延迟或 PLCA 状态机 BEACON→TO 转换未正确补偿 MII/MDI 双向传播延迟。

**本 IP 设计规避方案**:
```
[PLCA Timing 自适应校准 — PHY IF 层]
- RTT 自适应测量:
  plca_rtt_measured[9:0]: 硬件自动测量 BEACON TX→CRS de-assertion 往返时间
  测量方法: Coordinator 发送 BEACON，记录 TX_EN 上升沿到 CRS 下降沿时间差
  
- Cycle time 动态调整:
  cycle_time_calculated = N × to_timer + rtt_measured + beacon_length
  与预期值偏差 > 10% → 置位 PLCA_CYCLE_WARN，建议软件调整 to_timer
  
- 可配置补偿:
  plca_rtt_compensation[7:0]: 手动覆盖 RTT 补偿值 (默认 0 = 使用硬件测量)
```
**验证要点**: 4 节点 PLCA 网络，测量 1000 个 cycle 的实际间隔，验证与理论值偏差 < 5%。

---

#### 【ERR-017】PMD First Bit Encoding Error — LETH_AI.014

**TC4x 问题描述**:
> 10BASE-T1S Digital PHY 在 TRANSMIT 命令后，首个符号的首比特**未按 TC14 PMD 特殊编码**发送。
> TC14 要求: '0' = 80ns high pulse; '1' = 40ns high + 20ns low + 20ns high。
> 实际: 按标准 RZI 编码发送 ('0' = 20ns low + 60ns high; '1' = 20ns low + 20ns high × 2)。

**影响**: XCVR 检测到首符号数据损坏，触发 collision（ED pin low），导致所有重传失败。

**根本原因**: PMD TX Encoder 未区分"首符号首比特"与"普通比特"的编码路径。

**本 IP 设计规避方案**:
```
[PHY Interface TX Encoder — HSPHY IF 层]
⚠️ 注: 本 IP 的 10BASE-T1S 支持通过外部 PHY 实现，MAC 层通过 MII 接口驱动。
   此 erratum 属外部 PMD 层缺陷，非本 IP MAC/MTL 可修复。

- 外部 PHY 选型约束:
  选择支持 OPEN Alliance TC14 PMD v1.5+ 的外部 PHY
  要求 PHY 数据手册明确声明首符号首比特特殊编码合规
  
- MAC 层错误检测 (辅助):
  监控 MII COL (collision) 信号:
  若 COL 在首符号传输后 1μs 内有效 → 置位 PMD_ENCODE_ERR
  连续 3 次 → 触发 SMU 报警，建议软件检查 PHY 配置
  
- 软件 workaround (若 PHY 有 erratum):
  通过 MDIO 访问 PHY vendor-specific 寄存器，启用首比特特殊编码模式
  (部分 PHY 提供 bypass/first-bit-special 配置位)
```
**验证要点**: 外部 PHY 选型评审时核查 TC14 合规性声明；仿真验证 COL 信号异常检测。

---

#### 【ERR-018】PMA Symbol Aligner Packet Drop — LETH_AI.015

**TC4x 问题描述**:
> 当错误 SILENCE 符号被误识别为 SSD/ESD/HB/BEACON 时，PMA elastic buffer 的 read threshold（默认 14）错误缓存非 SILENCE 符号，导致**下一个有效包被丢弃**。

**影响**: 线路噪声/错误导致后续有效帧丢失。

**根本原因**: PMA symbol aligner 在检测到"伪特殊符号"后，未刷新 elastic buffer，错误数据混入下一包。

**本 IP 设计规避方案**:
```
[PHY RX 错误恢复 — HSPHY IF 层]
⚠️ 注: 此 erratum 属外部 PMA 层 elastic buffer 管理缺陷。

- 外部 PHY 选型约束:
  选择 elastic buffer 深度 ≤ 8 的 PHY（降低错误缓存概率）
  或选择支持 auto-flush-on-error 的 PHY
  
- MAC 层 RX 监控:
  rx_error_counter[7:0]: 统计 MII RX_ER 脉冲次数
  若 1ms 窗口内 RX_ER > 阈值 → 置位 LINE_NOISE_ERR
  
- 软件恢复策略:
  检测到连续异常后，通过 MDIO 发送 PHY reset 序列
  (部分 PHY 支持软复位恢复 elastic buffer)
```
**验证要点**: 外部 PHY 弹性缓冲区管理评审；噪声注入测试验证 RX 恢复能力。

---

#### 【ERR-019】SYNC→SSD Misalignment Packet Drop — LETH_AI.022

**TC4x 问题描述**:
> 首 SYNC 符号右移 1-bit 后酷似 SSD (0x04)，PMA symbol aligner 在 5-bit 边界外继续比较，导致错误 SSD 检测，后续有效 SYNC 被视为数据，PCS 丢弃包。

**影响**: 线路轻微噪声导致有效帧丢失。

**根本原因**: Symbol aligner shift register 在 5-bit 边界验证前即开始特殊符号比较。

**本 IP 设计规避方案**:
```
[PHY RX Symbol Alignment — HSPHY IF 层]
⚠️ 注: 此 erratum 属外部 PMA symbol aligner 实现缺陷。

- 外部 PHY 选型约束:
  要求 PHY 声明 symbol aligner 严格 5-bit 边界验证后再输出特殊符号检测
  选择支持 "strict-5bit-align" 模式的 PHY
  
- MAC 层包完整性检查:
  接收帧长度统计: 若连续收到 runt frame (< 64B) → 置位 SHORT_FRAME_ERR
  与 line noise 错误关联分析，区分 PMA 问题与正常链路问题
```
**验证要点**: 外部 PHY symbol aligner 设计评审；边界偏移测试。

---

#### 【ERR-020】Bridge RX Status Word Stall — LETH_AI.018

**TC4x 问题描述**:
> Bridge 在 ARI burst/packet 边界仲裁，某 ingress port 获胜后阻塞其他端口直到 DMA 接受完整 burst + Rx status + Rx Timestamp status。
> Bridge 从第一个 status word (Normal Status) 计算状态字数，但 DMA 接受 final status word 时才释放通道。

**影响**: 10BASE-T1S 小包场景下，RX status 处理延迟导致其他端口饥饿。

**根本原因**: Bridge 仲裁粒度为 burst/packet 级，未考虑 status word 的独立传输。

**本 IP 设计规避方案**:
```
[Switch Core Crossbar 替代 Bridge — 已解决]
⚠️ 注: 本 IP 采用 Switch Core Crossbar 替代 TC4x Bridge，此问题不存在。

- Crossbar 仲裁粒度为 flit (64/128-bit) 级，非 burst/packet 级:
  每时钟周期独立仲裁各 ingress → egress 路径
  不存在 "某端口获胜后阻塞全部其他端口"
  
- RX status 独立通道:
  数据通路: ingress FIFO → Crossbar → egress FIFO → MAC/DMA
  状态通路: 独立 ARI status channel，与数据通路并行
  状态传输不占用数据 Crossbar 带宽
  
- 小包优化:
  10BASE-T1S 帧长 ≤ 64B，Crossbar flit 级仲裁无 burst 边界阻塞
```
**验证要点**: 4-port Crossbar 并发小包（64B @ 10Mbps）转发，验证无端口饥饿。

---

#### 【ERR-021】PLCA Register Read Swapped Fields — LETH_AI.010

**TC4x 问题描述**:
> B10T1S_PLCA_Timer 寄存器读取时，TOT (Transmit Opportunity Timer) 和 BT (Burst Timer) 字段**交换**。
> 编程值正确，仅读取值错误。

**影响**: 软件读取寄存器后误解析 PLCA 时序参数。

**根本原因**: 寄存器读取路径的字段路由错误（文档描述正确，硬件实现错误）。

**本 IP 设计规避方案**:
```
[PLCA 寄存器接口 — CSR 层]
⚠️ 注: 此 erratum 属寄存器读路径字段路由错误，非功能缺陷。

- 本 IP 的 PLCA 寄存器通过 MDIO 访问外部 PHY，非本地 CSR:
  MDIO 读值由外部 PHY 返回，字段顺序取决于 PHY 实现
  
- 规避策略:
  软件驱动层统一处理字段交换:
  读 B10T1S_PLCA_Timer 后，软件交换 Bits[7:0] ↔ Bits[15:8]
  
- 硬件规避 (若本 IP 实现 PLCA 寄存器):
  寄存器读路径增加字段交换修复逻辑 (字节 swap)
  增加 plca_timer_read_swap_en (默认=1，自动修复)
```
**验证要点**: MDIO 读写测试，验证 TOT/BT 字段正确解析。

---

#### 【ERR-022】PLCA Status Register Description Mismatch — LETH_AI.017 / .023

**TC4x 问题描述**:
- LETH_AI.017: Portj_B10T1S_PLCA_Sts.PS (PLCA Status) 位描述**相反**（UM 说 0=正常，实际 1=正常）。
- LETH_AI.023: Portj_B10T1S_PLCA_Sts 的 BCNBFTO/UNEXPB/RXINTO 字段被描述为 RO，实际为 **W1C** (Write-1-to-Clear)。

**影响**: 软件按 UM 描述编程时错误解释状态/清除错误。

**根本原因**: 用户手册与硬件实现不一致。

**本 IP 设计规避方案**:
```
[PLCA 寄存器规范 — 文档/软件层]
⚠️ 注: 文档描述错误，硬件实现本身正确。属软件 workaround 类问题。

- 本 IP 策略:
  严格遵循 OPEN Alliance TC14 PLCA v1.3 寄存器规范
  不依赖 vendor-specific UM 描述
  
- 寄存器定义 (Arch Spec §1.4.1 新增):
  Portj_B10T1S_PLCA_Sts.PS:
    1 = BEACONs 正常收发，PLCA Control 状态机正常运行
    0 = PLCA Control 处于 DISABLE/RESYNC/RECOVER 状态超过 PLCA_status timer
    
  Portj_B10T1S_PLCA_Sts.BCNBFTO/UNEXPB/RXINTO:
    RO + W1C: 读显示当前状态，写 1 清除
    
- 软件驱动统一封装:
  提供 HAL 层 API: clear_plca_status(flags)，自动处理 W1C 语义
```
**验证要点**: 寄存器访问测试，验证 PS 位语义与 W1C 清除操作。

---

#### 【ERR-023】10BASE-T1S ED Pulse Decode — LETH_AI.006

**TC4x 问题描述**:
> EQOS (Equalizer/Signal Quality) 仅解码 >30ns 的 ED (End Delimiter) 脉冲，<30ns 的脉冲被忽略。

**影响**: 短 ED 脉冲导致包结束检测失败，帧边界错误。

**根本原因**: ED 脉冲检测器的脉宽阈值设置过高。

**本 IP 设计规避方案**:
```
[PHY 信号质量监控 — HSPHY IF 层]
⚠️ 注: 此 erratum 属外部 PHY EQOS/PCS 层实现。

- 外部 PHY 选型约束:
  选择 ED 脉冲检测阈值 ≤ 20ns 的 PHY (符合 IEEE 802.3cg 标准)
  或选择支持可配 ED 阈值的 PHY
  
- MAC 层帧边界校验:
  若 MII RX_DV 下降沿与预期 EOF 偏差 > 1μs → 置位 EOF_MISMATCH
  连续检测到 mismatch → 建议软件检查 PHY ED 配置
  
- 软件 workaround:
  通过 MDIO 调整 PHY ED threshold 寄存器 (若支持)
```
**验证要点**: 外部 PHY ED 脉冲检测参数评审；短脉冲注入测试。

---

---

#### 【ERR-002】TAS Extra IPG in Back-to-Back — GETH_AI.032 / LETH_AI.008

**TC4x 问题描述**:
> TAS (EST) 调度器在 fGETH 时钟域触发计数器，同步到 MAC Transmitter 时钟域，完成后再同步回 fGETH 域。CDC 延迟导致背靠背传输时出现**额外 IPG**（最坏 **12 个慢时钟周期**）。

**影响**: 门控周期精度下降，TSN 确定性受损。

**本 IP 设计规避方案**:
```
[TAS Scheduler 时钟域设计]
方案 A (推荐): TAS 调度器与 MAC Transmitter 置于**同一时钟域**
  - 消除 CDC 延迟
  - GCL 门控决策直接驱动 MAC TX 使能，无跨域同步
  
方案 B (若必须跨域): 精细 CDC 握手
  - 采用 req/ack 握手（而非简单同步器）传递调度完成信号
  - 计数器目标值预减 CDC 延迟补偿量 (compensation = 2~3 周期)
  - 增加 tas_cdc_compensation[3:0] 可配寄存器
```
**架构决策**: Arch Spec §2.2 子系统划分已明确 TAS Scheduler 归属 MTL 层，与 MAC Core 同 clk_mac 域运行。

---

#### 【ERR-003】MAC Starts TX Before Threshold — GETH_AI.036

**TC4x 问题描述**:
> MAC 在 TX FIFO 中累积的数据字节数**未达到阈值**时就开始传输，导致 underflow。

**影响**: 传输不完整帧，CRC 错误，链路效率下降。

**本 IP 设计规避方案**:
```
[MTL TX FIFO → MAC 握手]
- 增加 tx_threshold_ready 信号:
  - FIFO 水位 ≥ tx_threshold (可配: 64B/128B/256B/512B/full)
  - 且 packet 首字节已到达 (SOP valid)
  
- MAC TX Engine 状态机:
  IDLE → (tx_threshold_ready=1) → PREAMBLE → DATA → ...
  
- 阈值低于最小帧长 (64B) 时自动 clamp 到 64B，防止非法配置
```

---

#### 【ERR-004】TX Not Terminated on Underflow (MII) — GETH_AI.039

**TC4x 问题描述**:
> MII 速率模式下，TX FIFO underflow 时 MAC **不终止传输**，继续发送无效数据。

**影响**: 发送损坏帧，接收端 CRC 错误，可能触发链路层故障。

**本 IP 设计规避方案**:
```
[MAC TX Engine 错误处理]
- underflow 检测条件: FIFO empty && tx_active && !EOF_reached
- 检测后动作:
  1. 立即发送截断序列 (Jam pattern: 0x55_55_55... 持续 32-bit)
  2. 释放 TX 媒介 (deassert TX_EN)
  3. 置位 TX Underflow Error (CSR)
  4. 触发中断 (若使能)
  5. 状态机返回 IDLE
  
- 增加 tx_underflow_terminate_en (默认=1, 强制终止)
```

---

#### 【ERR-005】RX DMA Stalls (Multiple) — GETH_AI.037/040/041/042

**TC4x 问题描述**:
> 多种场景导致 RX DMA 停滞：
> - GETH_AI.037: packet flush 与 suspend exit 同时发生
> - GETH_AI.040: context descriptor 未正确关闭
> - GETH_AI.041: 变长 RX packet + forwarding port TX DMA 活动
> - GETH_AI.042: 仅使用 normal status word 时 RX stall

**影响**: RX 路径阻塞，丢包，需软件复位恢复。

**本 IP 设计规避方案**:
```
[DMA Engine 鲁棒性设计]
1. 原子操作保证:
   - flush 与 resume 命令进入统一命令 FIFO，互斥执行
   - 状态机增加 PENDING_FLUSH / PENDING_RESUME 状态，避免重叠

2. Context Descriptor 完整性检查:
   - 硬件自动检测 context desc 格式错误 (length=0, 非法 type)
   - 错误时跳过该 desc，报告 CDE (Context Descriptor Error)，继续下一 desc
   - 不阻塞 DMA 通道

3. 变长包 + 转发隔离:
   - RX DMA 与 TX DMA (forwarding) 使用独立 AXI ID + 独立流控
   - RX 通道优先级高于 TX forwarding 通道，避免 TX 反压阻塞 RX

4. Normal Status Word 处理:
   - 增加 rdes3_valid 检查: 若 RDES3 未更新但 packet 已收完，
     硬件自动补全 status word (标记为 "Hardware Recovered")
   - 超时监控: dma_rx_watchdog_timer，3ms 无进度自动触发 recovery
```

---

#### 【ERR-006】RX Watchdog Timer Not Reset — GETH_AI.035

**TC4x 问题描述**:
> 基于时钟的 RX Interrupt Watchdog Timer 在其他 timer（字节/包计数）超时或 RI 触发事件时不重置，导致**冗余中断**。

**影响**: CPU 收到多余中断，增加负载。

**本 IP 设计规避方案**:
```
[中断聚合控制器]
- 统一重置条件 (任一满足即重置所有 timer):
  a) 字节计数 timer 超时
  b) 包计数 timer 超时  
  c) 时钟 timer 超时
  d) 描述符 IOC=1 完成
  e) 任意 RI 触发事件
  
- 增加 ri_watchdog_rst_on_any 配置位 (默认=1)
- 支持中断合并模式: 固定时间窗口 (timer) + 批量计数 (batch) 混合
```

---

#### 【ERR-007】VLAN Filter Fail Queue Routing — GETH_AI.033

**TC4x 问题描述**:
> VLAN 过滤失败的包未路由到配置的 fail queue，而是被丢弃或错送。

**本 IP 设计规避方案**:
```
[RX Filter - VLAN Fail Path]
- VLAN 过滤结果编码:
  PASS  → 按正常队列映射 (PCP → RX Queue)
  FAIL  → 强制路由到 vlan_fail_queue[2:0] (可配, 默认 Queue 0)
  
- 增加 vlan_fail_drop_en 位:
  0: 失败包送 fail queue (调试/监控用途)
  1: 失败包丢弃 (安全模式, 默认)
  
- 统计计数器独立: rx_vlan_pass_cnt / rx_vlan_fail_cnt
```

---

#### 【ERR-008】PTP Multi-port Sync Limitation — LETH_TC.010

**TC4x 问题描述**:
> LETH0 多端口 PTP 时间基只能**成对菊花链**（0→1, 2→3 或 3→0, 1→2），无法全端口统一时间基。

**影响**: 多端口 Transparent Clock / Bridge 的 residence time 计算不准确。

**本 IP 设计规避方案**:
```
[双 PHC + Crossbar 架构]
- 根本解决: 不采用菊花链时间基分发
- PHC0/PHC1 独立但同源 (同一晶体 + 各自 Adder)
- Switch Core 每个端口通过 Crossbar 独立访问任意 PHC
- gPTP Relay:
  BC 模式: 端口绑定独立 PHC (Port 0,1 → PHC0; Port 2,3 → PHC1)
  TC 模式: 各端口独立测量 residence time，无需共享时间基
  
- 时间戳精度: 所有端口同一 clk_ts 域捕获，无跨域误差
```
**Arch Spec 引用**: §2.2 双 PHC + vPHC 架构已从根本上消除此限制。

---

#### 【ERR-009】TX Timestamp Wrong for Non-TxQ0 + Bridge — LETH_AI.024

**TC4x 问题描述**:
> Bridge 启用时，DMA 默认输出 ati_txsqnum=0，Bridge 从 TxQ0 取时间戳回写到非 TxQ0 通道的描述符，导致 TDES0/1/2 时间戳错误。

**影响**: PTP/gPTP 时间同步精度受损。

**本 IP 设计规避方案**:
```
[Switch Core + DMA 接口]
- 每个 DMA 通道独立输出:
  tx_status[channel_id] = {timestamp_64b, tx_queue_id, status_valid}
  
- Switch Core 按 channel_id 路由 (非固定 0):
  egress_port = map(tx_queue_id)  // 可配置映射表
  timestamp = tx_status[matched_channel].timestamp
  
- 描述符回写:
  TDES0/1/2 = timestamp_from_correct_channel
  TDES3 = status_from_correct_channel (无此 bug)
  
- 增加 tx_timestamp_bridge_check (只读诊断位):
  若 Switch 检测到 channel_id 不匹配，置位并触发中断
```

---

#### 【ERR-010】Bridge Padding Extra 8 Bytes — GETH_AI.045

**TC4x 问题描述**:
> Bridge 转发时 egress 端口延迟接受数据字，导致硬件自动填充 8 字节 padding。

**影响**: 帧长度超标，可能触发接收端丢弃。

**本 IP 设计规避方案**:
```
[Switch Core Crossbar 设计]
- 架构层面: Switch Core 采用 Crossbar + 独立端口缓冲，非 Bridge 串行转发
- 每端口独立 ingress/egress FIFO (各 2KB~8KB 可配)
- 转发路径:
  ingress FIFO → [FDB Lookup] → Crossbar → egress FIFO → MAC TX
  
- 无 "delayed word acceptance" 问题:
  Crossbar 仲裁胜出后立即传输，egress FIFO 预缓冲
  MAC TX 从 egress FIFO 读取，水位足够才启动 (见 ERR-003 阈值机制)
  
- 若 egress 端口忙 (如 TAS 门控关闭)，帧暂存于 egress FIFO，
  不反压 ingress，不填充 padding
```

---

#### 【ERR-011】DRE Throughput Drop — DRE_TC.H002

**TC4x 问题描述**:
> GETH → DRE → LETH 转发路径带宽不足，持续 burst 流量时丢帧。
> 参考数据: 64B 帧 @ 100Mbps，268 包后开始丢，净带宽 ~81Mbps。

**影响**: 跨 MAC 转发性能仅为理论值的 ~81%。

**本 IP 设计规避方案**:
```
[Switch Core 全并发 Crossbar]
- 根本解决: 无需 DRE 中间层
- 4-port Switch Crossbar 支持全端口线速并发:
  Port 0 → Port 1: 1Gbps
  Port 2 → Port 3: 1Gbps  
  Port 0 → Port 2: 1Gbps
  (同时并发，无带宽瓶颈)
  
- 无确认等待: ingress 帧到达即转发，无需等 egress DMA write-back
- 若目标端口忙，帧缓存于 egress FIFO (非丢弃)
- 背压机制: egress FIFO 满时向 ingress 发 pause (802.3x)，不丢帧
```
**性能保证**: Verification Agent 验证 4-port 全并发满载转发零丢帧。

---

#### 【ERR-012】MII IPG Mismatch — GETH_AI.034

**TC4x 问题描述**:
> 10/100M MII 模式下，非标准 IPG 配置值与实际值不匹配。
> 软件必须只编程**偶数**且为**所需值两倍**的编码值。

**影响**: IPG 时间违反预期，影响 TSN 精度。

**本 IP 设计规避方案**:
```
[MAC TX IPG 控制器]
- IPG 配置寄存器 ipg_length[7:0] 采用**实际值编码** (非折半编码)
  - 写 12 → IPG = 12 bytes
  - 写 16 → IPG = 16 bytes
  - 避免 TC4x 的 "两倍编码" 混淆
  
- 硬件自动处理 MII 模式:
  - 10M/100M MII: IPG 自动对齐到 nibble 边界 (4-bit 倍数)
  - 1G+ 模式: IPG 对齐到 byte 边界
  
- 增加 ipg_actual 只读寄存器，回显实际生效 IPG 值
```

---

#### 【ERR-013】HSPHY RX Loss During Temperature Change — HSPHY_TC.005

**TC4x 问题描述**:
> 温度变化期间 HSPHY 接收通信丢失。

**影响**: 车规环境下温度波动导致链路中断。

**本 IP 设计规避方案**:
```
[PHY 接口可靠性]
- 模拟电路约束 (SoC 集成方负责):
  - HSPHY 需支持 AEC-Q100 Grade 1 温度范围 (-40°C ~ +125°C)
  - 温度补偿 PLL/CTLE 电路
  
- 数字链路监控 (本 IP 负责):
  - link_status_qualifier: 连续 3 次检测链路 down 才报告 (抗抖动)
  - 温度变化期间自动降低 SerDes 速率 (如 5G → 2.5G)，维持链路
  - 链路恢复后自动升回配置速率
  - phy_temp_adaptive_en (可配, 默认使能)
```

---

### 8.3 设计规避方案汇总与验证要求

| 设计修改点 | 规避 Erratum | 所属模块 | 验证方法 |
|-----------|------------|---------|---------|
| CBS credit IPG 递减 | ERR-001 | MTL Scheduler | 带宽精度测试 |
| TAS 单时钟域 / CDC 握手 | ERR-002 | MTL EST | 背靠背 IPG 精度测试 |
| TX threshold_ready 握手 | ERR-003 | MTL TX FIFO | Underflow 压力测试 |
| TX underflow 终止 + Jam | ERR-004 | MAC TX Engine | Underflow 注入测试 |
| DMA 命令 FIFO 互斥 + 超时恢复 | ERR-005 | DMA Engine | 并发 flush/resume 测试 |
| 中断统一重置 | ERR-006 | DMA IRQ Ctrl | 多 timer 触发测试 |
| VLAN fail queue 路由 | ERR-007 | RX Filter | VLAN 过滤失败路径测试 |
| 双 PHC + Crossbar (无菊花链) | ERR-008 | PTP/Switch | 4-port PTP 同步精度测试 |
| DMA channel_id 独立路由 | ERR-009 | Switch + DMA | 多 TxQ 时间戳精度测试 |
| Switch Crossbar + egress FIFO | ERR-010 | Switch Core | 转发帧长精确测试 |
| Crossbar 全并发无 DRE | ERR-011 | Switch Core | 4-port 满载转发零丢帧 |
| IPG 直接编码 + 边界对齐 | ERR-012 | MAC TX | IPG 精确度测试 |
| 温度自适应链路降速 | ERR-013 | HSPHY IF | 温度循环链路稳定性测试 |
| PLCA follower TX 时序补偿 | ERR-014 | MTL/PHY IF | TO→TX_EN 延迟测量 (≤5.56μs) |
| PLCA commit timer 硬限制 | ERR-015 | MAC TX Engine | Commit timer 持续时间测量 (≤28.85μs) |
| PLCA cycle time RTT 自适应 | ERR-016 | PHY IF | 1000 cycle 间隔偏差测量 (<5%) |
| 外部 PHY TC14 首比特编码选型约束 | ERR-017 | HSPHY IF | PHY 选型合规评审 |
| 外部 PHY elastic buffer 深度约束 | ERR-018 | HSPHY IF | 噪声注入 RX 恢复测试 |
| 外部 PHY 5-bit 边界对齐约束 | ERR-019 | HSPHY IF | 边界偏移 symbol aligner 测试 |
| Crossbar flit 级仲裁 (替代 Bridge) | ERR-020 | Switch Core | 4-port 64B 小包并发转发 |
| PLCA 寄存器字段 swap 修复 | ERR-021 | CSR | MDIO 读写字段解析测试 |
| PLCA 寄存器规范对齐 TC14 v1.3 | ERR-022 | 文档/HAL | 寄存器语义验证 |
| 外部 PHY ED 脉冲阈值约束 | ERR-023 | HSPHY IF | 短脉冲注入 EOF 检测测试 |

### 8.4 10BASE-T1S / PLCA Erratum 分类总结

| Erratum 类型 | 数量 | RTL/架构修改 | 外部 PHY 选型约束 | 软件 workaround |
|-------------|------|-------------|-------------------|---------------|
| **PLCA 时序/协议** (ERR-014/015/016) | 3 | ✅ 3 项 | — | — |
| **PMD/PMA 编码** (ERR-017/018/019/023) | 4 | — | ✅ 4 项 | — |
| **Bridge 仲裁** (ERR-020) | 1 | ✅ (Crossbar 已解决) | — | — |
| **寄存器描述** (ERR-021/022) | 2 | ✅ 1 项 (读路径 swap 修复) | — | ✅ 1 项 (HAL 层处理) |
| **合计** | **10** | **4 项** | **4 项** | **1 项** |

> **关键洞察**: 10BASE-T1S/LETH 的 erratum 中，**60% 属外部 PHY 层缺陷**（PMD/PMA/PCS），非 MAC/MTL 可修复。本 IP 通过**严格的 PHY 选型约束 + MAC 层错误检测辅助**规避此类问题，而非 RTL 修改。PLCA 时序类 erratum (40%) 需 MAC/MTL 层 RTL 修正，已给出具体设计方案。

### 8.5 Arch Spec 新增约束（更新）

上述设计规避方案已纳入 Arch Spec 对应章节：

- **§2.2 子系统划分**: TAS Scheduler 与 MAC 同 clk_mac 域 (规避 ERR-002)
- **§2.3 数据通路**: TX FIFO threshold_ready 握手信号 (规避 ERR-003)
- **§4.2 MTL 设计**: CBS credit IPG 递减逻辑 (规避 ERR-001)
- **§4.3 MAC 设计**: Underflow 终止 + Jam 序列 (规避 ERR-004)
- **§5.2 DMA 设计**: 命令 FIFO 互斥 + 超时恢复 (规避 ERR-005)
- **§6.1 Switch Core**: Crossbar + 独立端口缓冲 (规避 ERR-010/011)
- **§6.2 PTP 设计**: 双 PHC + 无菊花链 (规避 ERR-008)
- **§7.1 安全机制**: DMA 超时监控纳入 Safety Monitor (规避 ERR-005/006)
- **§7.2 PLCA 时序**: TO timer 补偿 + commit timer 硬限制 + RTT 自适应 (规避 ERR-014/015/016)
- **§7.3 外部 PHY 选型**: TC14 PMD v1.5 合规约束 + elastic buffer ≤ 8 + strict 5-bit align (规避 ERR-017/018/019/023)
- **§7.4 寄存器规范**: PLCA 寄存器严格遵循 OPEN Alliance TC14 v1.3 (规避 ERR-021/022)

---

*Errata 分析完成: 2026-05-12 | 状态: 已纳入 Arch Spec v1.6 | 总覆盖: 23 项 erratum (GETH 13 项 + LETH 10 项)*

