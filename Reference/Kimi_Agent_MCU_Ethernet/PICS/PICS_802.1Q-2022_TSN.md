# PICS — IEEE Std 802.1Q-2022 — Bridges and Bridged Networks (TSN: Qav/Qbv/Qbu/Qci)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 802.1Q-2022 — Bridges and Bridged Networks (TSN: Qav/Qbv/Qbu/Qci)
> **PICS来源**: Annex A（桥接实现）+ Annex B（端站实现）TSN相关PICS完整提取
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能
> **生成日期**: 2025年

---

## 2. PICS提取 — 桥接实现 (Annex A)

### 2.1 主要功能（Major Capabilities）— TSN相关条目

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| FQTSS | Forwarding and Queuing Enhancements for time-sensitive streams | 5.4.1.5, Clause 34 | O | Yes/No | 对应802.1Qav/CBS功能 |
| SRP | Stream Reservation Protocol | Clause 35 | O | Yes/No | 流预留协议 |
| PFC | Priority-based Flow Control | 5.11, Clause 36 | O | Yes/No | 基于优先级的流量控制 |
| ETS | Enhanced Transmission Selection | Clause 37 | O | Yes/No | 增强传输选择 |
| SCHED | Scheduled traffic | 5.4.1, 5.13.1, 8.6.8, 8.6.9, 12.29, 17.7.22 | O | Yes/No | 对应802.1Qbv/TAS |
| PRE | Frame preemption | 5.4.1, 5.13.1, 6.7.2, 8.6.8, 12.30, 17.7.23 | O | Yes/No | 对应802.1Qbu |
| PSFP | Per-Stream Filtering and Policing | 8.6.5.2.1, 8.6.6 items d) and e), 8.6.10, 12.31 | O | Yes/No | 对应802.1Qci |
| ATS | Asynchronous Traffic Shaping | 5.4.1.10, 5.13.1.3, 8.6.5.2.2, 8.6.6 items d) and e), 8.6.8, 8.6.8.5, 8.6.11, 12.31 | O | Yes/No | 对应802.1Qcr |
| CQF | Cyclic Queuing and Forwarding | 5.4.1.9, 5.13.1.2 | O | Yes/No | 循环排队转发 |
| PCR | Path Control and Reservation | Clause 45 | O | Yes/No | 对应802.1Qca |

### 2.2 A.29 — Forwarding and Queuing Enhancements for Time-Sensitive Streams (FQTSS/802.1Qav)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| FQTSS前提 | FQTSS支持前提检查 | 5.4.1.5, Clause 34 | 条件 | N/A | 不支持则标记N/A跳过 |
| FQTSS:E1 | 最少支持2个traffic classes，1个严格优先级+1个SR class | 5.4.1.5, 8.6.8.1, Clause 34 | FQTSS:M | Yes/N/A | CBS基础要求 |
| FQTSS:E2 | 所有端口支持credit-based shaper算法 | 5.4.1.5, 8.6.8.2, Clause 34 | FQTSS:M | Yes/N/A | 硬件或软件实现 |
| FQTSS:E3 | SR class "B"边界端口优先级再生覆盖 | 5.4.1.5, 6.9.4, Table 6-5, Clause 34 | FQTSS:M | Yes/N/A | 域边界处理 |
| FQTSS:E4 | 优先级到traffic class映射表和过程 | 5.4.1.5, Clause 34, 34.5 | FQTSS:M | Yes/N/A | 映射配置 |
| FQTSS:E5 | 支持2个以上SR classes（最多7个），credit-based shaper操作 | 5.4.1.5, 8.6.8.2, 34.6 | FQTSS:O | Yes/No | 需在PICS中声明SR class数量 |
| FQTSS:E6 | SR class "A"边界端口优先级再生覆盖，额外SR class默认值声明 | 5.4.1.5, 6.9.4, Table 6-5, 34.6 | FQTSS:O | Yes/No | 多SR class支持 |

### 2.3 A.44 — Scheduled Traffic (802.1Qbv / TAS)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| SCHED前提 | Scheduled traffic或CQF支持前提 | 5.4.1, 5.13.1, 8.6.8, 8.6.9, 12.29, 17.7.22 | 条件 | N/A | 均不支持则标记N/A |
| SCHED1 | 支持8.6.9中定义的状态机和相关定义 | 5.4.1, 5.13.1, 8.6.8, 8.6.9 | SCHED OR CQF:M | Yes/N/A | 核心TAS状态机 |
| SCHED2 | 支持12.29中定义的管理实体 | 5.4.1 item ad), 5.4.1.9 item c), 5.13.1.2 item c), 12.29 | SCHED OR CQF:M | Yes/N/A | GCL配置管理 |
| SCHED3 | IEEE8021-ST-MIB模块完全支持 | 5.4.1 item ad), 5.4.1.9 item c), 12.29, 17.7.22 | MIB AND (SCHED OR CQF):O | Yes/No/N/A | SNMP MIB支持 |

**TAS状态机说明：**
- **Cycle Timer State Machine** (8.6.9.1)：启动gate control list执行，维护端口门控周期时间
- **List Execute State Machine** (8.6.9.2)：顺序执行gate control list中的门控操作
- **List Config State Machine** (8.6.9.3)：管理活动调度表的动态更新
- **关键变量**：AdminBaseTime, AdminControlList, AdminCycleTime, AdminCycleTimeExtension, AdminGateStates, OperBaseTime, OperControlList, OperCycleTime, ConfigChange, ConfigPending等

### 2.4 A.45 — Frame Preemption (802.1Qbu)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| PRE前提 | Frame preemption支持前提 | 5.4.1, 5.13.1, 6.7.2, 8.6.8, 12.30, 17.7.23 | 条件 | N/A | 不支持则标记N/A |
| PRE1 | 支持6.7.2和8.6.8中定义的帧抢占功能 | 5.4.1, 5.13.1, 6.7.2, 8.6.8 | PRE:M | Yes/N/A | Express/Preemptable帧处理 |

**帧抢占技术细节：**
- Express帧可以中断正在传输的可抢占帧
- 被抢占的帧在传输完成后从断点继续
- 需要802.3br MAC Merge子层支持
- preemption验证通过对端状态协商确定

### 2.5 A.46 — Per-Stream Filtering and Policing (802.1Qci)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| PSFP前提 | PSFP或CQF支持前提 | 5.4.1.9, 5.13.1.2, 8.6.5.2, 8.6.10, 12.31, 17.7.24 | 条件 | N/A | 均不支持则标记N/A |
| PSFP1 | 支持8.6.10中定义的状态机和相关定义 | 5.4.1.9 item b), 5.13.1.2 item b), 8.6.5, 8.6.10 | PSFP OR CQF:M | Yes/N/A | Stream gate control状态机 |
| PSFP2 | 支持12.31中定义的PSFP管理实体 | 5.4.1.9 item e), 5.13.1.2 item e), 8.6.5.2, 8.6.10, 12.31 | PSFP OR CQF:M | Yes/N/A | PSFP配置管理 |
| PSFP3 | IEEE8021-PSFP-MIB模块完全支持 | 5.4.1.9 item e), 5.13.1.2 item e), 12.31, 17.7.24 | MIB AND (PSFP OR CQF):O | Yes/No/N/A | SNMP MIB支持 |

**PSFP核心机制：**
- **Stream Filter**：基于规则匹配识别流（stream identification）
- **Stream Gate**：Open/Closed状态控制，支持Gate Control List调度
- **Flow Meter**：srTCM（Single Rate Three Color Marker）算法，Green/Yellow/Red标记
- **IntervalOctetsMax**：每个时间间隔允许通过的最大字节数

### 2.6 A.43 — Path Control and Reservation (802.1Qca)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| PCR前提 | PCR支持前提 | Clause 45 | 条件 | N/A | 不支持则标记N/A |
| PCR-1 | 支持ISIS-PCR协议 | Clause 45 | PCR:M | Yes/N/A | IS-IS扩展 |
| PCR-2 | 支持SPB Link Metric sub-TLV | 28.12.7 | PCR:M | Yes/N/A | 链路度量 |
| PCR-3 | 支持SPB Base VLAN-Identifiers sub TLV | 28.12.4 | PCR:M | Yes/N/A | VLAN标识 |
| PCR-4 | 支持SPB Instance sub-TLV | 28.12.5 | PCR:M | Yes/N/A | SPB实例 |
| PCR-5 | 支持SPBV MAC address sub-TLV | 28.12.9 | PCR:M | Yes/N/A | MAC地址 |
| PCR-6 | 支持SPBM Service Identifier and Unicast Address sub-TLV | 28.12.10 | BEB AND PCR:M | Yes/N/A | BEB特定 |
| PCR-7 | 支持Topology sub-TLV | 45.1.9 | PCR:M | Yes/N/A | 拓扑信息 |
| PCR-8 | 支持Hop sub-TLV | 45.1.10 | PCR:M | Yes/N/A | 跳数信息 |
| PCR-9 | 支持ST ECT Algorithm | 45.1.2 | PCR:M | Yes/N/A | Shortest Tree |
| PCR-10 | 支持LT ECT Algorithm | 45.1.2 | PCR:O | Yes/No | Loop-free Tree |
| PCR-11 | 支持LTS ECT Algorithm | 45.1.2 | PCR:O | Yes/No | Loop-free Tree by Steiner |
| PCR-12 | 支持MRT ECT Algorithm | 45.1.2, 45.3.3 | PCR:O | Yes/No | Maximally Redundant Trees |
| PCR-13 | 支持MRTG ECT Algorithm | 45.1.2, 45.3.4 | PCR:O | Yes/No | MRT Grouped |
| PCR-14 | 支持Extended IS Reachability TLV | 45.1.8, IETF RFC 5305 | PCR:O | Yes/No | 扩展可达性 |
| PCR-15 | 支持Min/Max Unidirectional Link Delay sub-TLV | 45.1.8, IETF RFC 7810 | PCR:O | Yes/No | 链路延迟 |
| PCR-16 | 支持Unidirectional Delay Variation sub-TLV | 45.1.8, IETF RFC 7810 | PCR:O | Yes/No | 延迟变化 |
| PCR-17 | 支持Unidirectional Link Loss sub-TLV | 45.1.8, IETF RFC 7810 | PCR:O | Yes/No | 链路丢包 |
| PCR-18 | 支持Unidirectional Residual Bandwidth sub-TLV | 45.1.8, IETF RFC 7810 | PCR:O | Yes/No | 残余带宽 |
| PCR-19 | 支持Unidirectional Available Bandwidth sub-TLV | 45.1.8, IETF RFC 7810 | PCR:O | Yes/No | 可用带宽 |
| PCR-20 | 支持Unidirectional Utilized Bandwidth sub-TLV | 45.1.8, IETF RFC 7810 | PCR:O | Yes/No | 已用带宽 |
| PCR-21 | 支持Shared Risk Link Group TLV | 45.1.8, IETF RFC 5307 | PCR:O | Yes/No | 共享风险组 |
| PCR-22 | 支持Administrative Group sub-TLV | 45.1.11 | PCR:O | Yes/No | 管理组 |
| PCR-23 | 支持Bandwidth Constraint sub-TLV | 45.1.12 | PCR:O | Yes/No | 带宽约束 |
| PCR-24 | 支持Bandwidth Assignment sub-TLV | 45.2.1 | PCR:O | Yes/No | 带宽分配 |
| PCR-25 | 支持Timestamp sub-TLV | 45.2.2 | PCR:O | Yes/No | 时间戳 |

### 2.7 A.52 — Asynchronous Traffic Shaping (802.1Qcr / ATS)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| ATS前提 | ATS支持前提 | 5.4.1.10, 5.13.1.3, 8.6.5.2.2, 8.6.6 items d) and e), 8.6.8.5, 8.6.8, 8.6.11, 12.31 | 条件 | N/A | 不支持则标记N/A |
| ATS-1 | 支持8.6.5.2.2中定义的ATS逐流分类和计量 | 5.4.1.10, 5.13.1.3, 8.6.5.2.2 | ATS:M | Yes/N/A | 流分类+srTCM计量 |
| ATS-2 | 支持8.6.8.5中定义的ATS传输选择算法 | 5.4.1.10, 5.13.1.3, 8.6.8.5 | ATS:M | Yes/N/A | ATS整形算法 |
| ATS-3 | 支持8.6.11中定义的ATS调度器状态机 | 5.4.1.10, 5.13.1.3, 8.6.11 | ATS:M | Yes/N/A | 调度状态机 |
| ATS-4 | 支持12.31中定义的ATS管理实体 | 5.4.1.10, 5.13.1.3, 12.31 | ATS:M | Yes/N/A | 管理配置 |

### 2.8 A.31 — Stream Reservation Protocol (SRP)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| SRP前提 | SRP支持前提 | Clause 35 | 条件 | N/A | 不支持则标记N/A |
| SRP-1 | 支持使用MRPDU格式交换MSRP信息 | 10.8, 35.2.2.8.1, 35.2.2.9.1, 35.2.2.10.1 | M | Yes | MSRP数据单元交换 |
| SRP-2 | MSRP Application按Clause 35定义实现 | Clause 35 | M | Yes | 完整SRP协议栈 |

---

## 3. 端站PICS — Annex B TSN相关条目

端站（End Station）PICS与Bridge PICS结构类似，以下列出TSN相关的差异点：

### 3.1 B章节 — 端站TSN Major Capabilities

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| FQTSS-ES | 端站支持FQTSS | 5.13.1, 5.13.1.2 item f) | O | Yes/No | 端站CBS支持 |
| SCHED-ES | 端站支持Scheduled traffic | 5.13.1 | O | Yes/No | 端站TAS支持 |
| PRE-ES | 端站支持Frame preemption | 5.13.1 | O | Yes/No | 端站帧抢占支持 |
| PSFP-ES | 端站支持PSFP | 5.27 | O | Yes/No | 端站PSFP支持 |
| ATS-ES | 端站支持ATS | 5.13.1.3 | O | Yes/No | 端站ATS支持 |

### 3.2 B章节 — 端站TSN详细PICS条目

端站PSFP PICS条目（B章节）：

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| PSFP前提-ES | PSFP或CQF支持前提 | 5.27 | 条件 | N/A | 端站PSFP前提 |
| PSFP1-ES | 支持8.6.5.2.1和8.6.6 items d) e)中定义的PSFP | 5.27 | PSFP OR CQF:M | Yes/N/A | 流过滤 |
| PSFP2-ES | 支持12.31中定义的PSFP管理实体 | 5.27 | PSFP OR CQF:M | Yes/N/A | 管理配置 |
| PSFP3-ES | IEEE8021-PSFP-MIB模块完全支持 | 5.27 | MIB AND (PSFP OR CQF):O | Yes/No/N/A | MIB支持 |

端站ATS PICS条目（B章节）：

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| ATS前提-ES | ATS支持前提 | 5.13.1.3, 8.6.5.2.2, 8.6.6, 8.6.8.5, 8.6.11, 12.31 | 条件 | N/A | 端站ATS前提 |
| ATS1-ES | 支持另一个traffic class上ATS调度器组实例 | 5.13.1.3, 8.6.8.5 | ATS:M | Yes/N/A | ATS调度 |
| ATS2-ES | 支持ATS调度器状态机 | 5.13.1.3, 8.6.11 | ATS:M | Yes/N/A | 状态机 |
| ATS3-ES | 支持ATS管理实体 | 5.13.1.3, 8.6.5.2.2, 8.6.6, 8.6.8.5, 8.6.11, 12.31 | ATS:M | Yes/N/A | 管理配置 |

端站Frame Preemption PICS条目（B.16）：

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|-------|------|
| PRE前提-ES | Frame preemption支持前提 | 5.13.1 | 条件 | N/A | 端站帧抢占前提 |
| PRE1-ES | 支持帧抢占功能 | 5.13.1, 6.7.1, 6.7.2, 8.6.8 | PRE:M | Yes/N/A | 端站帧抢占 |

---

