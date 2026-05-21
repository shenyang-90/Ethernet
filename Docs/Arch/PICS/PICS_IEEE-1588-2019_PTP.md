# PICS — IEEE Std 1588-2019 — Precision Clock Synchronization Protocol (PTP)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 1588-2019 — Precision Clock Synchronization Protocol (PTP)
> **PICS来源**: 基于Clause 20（Conformance）及全协议条款创建的PICS
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能
> **生成日期**: 2025年

---

## 二、PICS（Protocol Implementation Conformance Statement）

### 2.1 PICS说明

**PICS来源**: IEEE 1588-2019标准正文中**未包含**现成的PICS Annex。本PICS根据以下条款创建：
- Clause 20（Conformance）中的一致性要求
- Clause 6-17 中的必选（shall）和可选（may/optional）功能
- Annex I（Default PTP Profiles）中的Profile要求
- 各选项条款中的实现要求

**PICS状态说明**：
- **M** (Mandatory): 必选功能，所有实现必须支持
- **O** (Optional): 可选功能，由实现决定
- **C** (Conditional): 条件必选，满足特定条件时必须支持
- **X** (Excluded): 排除功能，本实现不支持
- **NA** (Not Applicable): 不适用

### 2.2 PICS表格

#### 2.2.1 协议基础支持能力

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-BASE-01 | PTP协议版本支持 (versionPTP = 2) | 7.3.2, 13.3.2.4 | M | Yes | 所有实现必须支持PTPv2.1 |
| PTP-BASE-02 | PTP次要版本支持 (minorVersionPTP) | 13.3.2.5 | M | Yes | 2019版要求minorVersion=1 |
| PTP-BASE-03 | domainNumber支持 | 7.1.1, 8.2.5.1 | M | Yes | 默认domainNumber=0 |
| PTP-BASE-04 | sdoId支持 (Profile隔离) | 7.1.2, 16.5 | M | Yes | 2019版新增，支持多SDO Profile共存 |
| PTP-BASE-05 | 单域操作 | 6.2 | M | Yes | 基础单域同步功能 |
| PTP-BASE-06 | 多域操作支持 | 6.2, 7.1.1 | O | — | 同一设备参与多个PTP域 |

#### 2.2.2 时钟类型支持

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-CLK-01 | Ordinary Clock (OC) | 3.1.40, 6.5.2 | C | — | 至少实现一种时钟类型时为必选 |
| PTP-CLK-02 | Boundary Clock (BC) | 3.1.10, 6.5.3 | O | — | 多端口桥接场景必选 |
| PTP-CLK-03 | Transparent Clock — E2E | 3.1.77, Clause 10 | O | — | 端到端透明时钟 |
| PTP-CLK-04 | Transparent Clock — P2P | 3.1.78, Clause 10 | O | — | 对等透明时钟 |
| PTP-CLK-05 | 单端口PTP Instance | 6.5.2 | C | — | OC实现时为M |
| PTP-CLK-06 | 多端口PTP Instance | 6.5.3 | C | — | BC实现时为M |
| PTP-CLK-07 | 每个域独立数据集 | 8.1.4.2 | M | Yes | 多域/BC需要 |
| PTP-CLK-08 | Local PTP Clock | 3.1.28, 12.2 | M | Yes | 本地PTP时钟 |
| PTP-CLK-09 | Local Clock (非PTP时钟) | 3.1.26 | O | — | 与PTP时钟分离的本地时钟 |

#### 2.2.3 延迟测量机制

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-DLY-01 | Delay Request-Response机制 (E2E) | 11.3, I.3 | C | — | E2E Profile或OC/BC使用E2E时为M |
| PTP-DLY-02 | Peer-to-Peer Delay机制 (P2P) | 11.4, I.4 | C | — | P2P Profile或TC-P2P使用P2P时为M |
| PTP-DLY-03 | Pdelay_Req消息处理 | 11.4.2 | C | — | P2P机制实现时为M |
| PTP-DLY-04 | Pdelay_Resp消息处理 | 11.4.2 | C | — | P2P机制实现时为M |
| PTP-DLY-05 | Pdelay_Resp_Follow_Up消息处理 | 11.4.2 | C | — | two-step P2P端口时为M |
| PTP-DLY-06 | Delay_Req消息处理 | 11.3.1 | C | — | E2E Slave端口时为M |
| PTP-DLY-07 | Delay_Resp消息处理 | 11.3.1 | C | — | E2E Master端口时为M |
| PTP-DLY-08 | NO_MECHANISM配置 | 8.2.15.4.4 | O | — | 仅频率同步不测量延迟 |
| PTP-DLY-09 | CUMULATIVE_RATE_RATIO TLV | 16.10 | O | — | 累积频率比率传递 |
| PTP-DLY-10 |  neighborRateRatio计算 | 16.6, 16.10 | C | — | CMLDS或P2P机制实现时为M |

#### 2.2.4 时间戳与同步模式

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-TS-01 | 一步法时间戳 (One-Step) | 7.3.3.1, 11.1.1 | O | — | 需要硬件PTP引擎支持 |
| PTP-TS-02 | 两步法时间戳 (Two-Step) | 7.3.3.2, 11.1.2 | O | — | 软件友好，推荐用于MCU |
| PTP-TS-03 | Follow_Up消息处理 | 13.6, 9.5.4 | C | — | two-step Master端口时为M |
| PTP-TS-04 | 事件消息时间戳 | 7.3.4, 9.5.5 | M | Yes | Sync/Delay_Req/Pdelay_Req等 |
| PTP-TS-05 | 硬件时间戳支持 | 7.3.4, A.5.3 | O | — | 高精度实现必选 |
| PTP-TS-06 | 软件时间戳支持 | 7.3.4 | O | — | 较低精度容忍场景 |
| PTP-TS-07 | 出端口延迟校正 (egressLatency) | 7.3.4.2, 16.7 | O | — | timestampCorrectionPortDS |
| PTP-TS-08 | 入端口延迟校正 (ingressLatency) | 7.3.4.2, 16.7 | O | — | timestampCorrectionPortDS |
| PTP-TS-09 | 消息时间戳点延迟 (messageTimestampPointLatency) | 7.3.4.2 | O | — | 高精度Profile推荐 |
| PTP-TS-10 | 延迟非对称校正 (delayAsymmetry) | 7.4.2, 16.8 | O | — | 介质非对称补偿 |

#### 2.2.5 BMCA与状态机

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-BMCA-01 | 默认BMCA (9.3.2) | 9.3.2, I.3.3 | M | Yes | 标准数据集比较算法 |
| PTP-BMCA-02 | 替代BMCA | 9.3.1 | O | — | Profile可指定替代算法 |
| PTP-BMCA-03 | Announce消息发送 | 9.5.8, 13.5 | M | Yes | BMCA运行必需 |
| PTP-BMCA-04 | Announce消息接收处理 | 9.3.2.5 | M | Yes | 数据集比较基础 |
| PTP-BMCA-05 | 端口状态机 | 9.2.5 | M | Yes | INITIALIZING/LISTENING/MASTER/SLAVE等 |
| PTP-BMCA-06 | slaveOnly模式 | 8.2.5.4, 9.2.2.1 | O | — | 仅作为Slave运行 |
| PTP-BMCA-07 | masterOnly模式 | 8.2.15.5.2, 9.2.2.2 | O | — | 仅作为Master运行 |
| PTP-BMCA-08 | announceReceiptTimeout处理 | 9.2.6.12 | M | Yes | Announce接收超时机制 |
| PTP-BMCA-09 | stepsRemoved更新 | 9.3.2.2, 8.2.6.1 | M | Yes | 跳数跟踪 |

#### 2.2.6 消息处理

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-MSG-01 | Sync消息处理 | 13.4, 9.5.4 | M | Yes | 核心时间同步消息 |
| PTP-MSG-02 | Announce消息处理 | 13.5, 9.5.8 | M | Yes | BMCA决策消息 |
| PTP-MSG-03 | Signaling消息处理 | 13.8, 14.1 | C | — | 使用Signaling选项时为M |
| PTP-MSG-04 | Management消息处理 | Clause 15 | O | — | PTP管理协议 |
| PTP-MSG-05 | 组播通信模式 | 7.3.1 | M | Yes | 默认通信模式 |
| PTP-MSG-06 | 单播通信模式 | 7.3.1, 16.1 | O | — | 单播协商选项 |
| PTP-MSG-07 | 消息序列号管理 (sequenceId) | 7.3.7, 13.3.2.6 | M | Yes | 每条消息独立序列号 |
| PTP-MSG-08 | PTP通用消息头处理 | 13.3 | M | Yes | 所有消息的基础格式 |
| PTP-MSG-09 | Message Length Extension | 16.13 | O | — | 消息长度对齐选项 |

#### 2.2.7 TLV支持

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-TLV-01 | 传播TLV处理 (propagating TLV) | 14.2.2.2 | M | Yes | 透传型TLV |
| PTP-TLV-02 | 非传播TLV处理 (nonpropagating TLV) | 14.2.2.1 | M | Yes | 本地处理不转发 |
| PTP-TLV-03 | ORGANIZATION_EXTENSION TLV | 14.3 | O | — | 厂商扩展 |
| PTP-TLV-04 | PATH_TRACE TLV | 16.2 | O | — | 路径跟踪选项 |
| PTP-TLV-05 | ALTERNATE_TIME_OFFSET_INDICATOR TLV | 16.3 | O | — | 替代时标偏移 |
| PTP-TLV-06 | CUMULATIVE_RATE_RATIO TLV | 16.10 | O | — | 累积频率比率 |
| PTP-TLV-07 | AUTHENTICATION TLV | 16.14 | O | — | 安全认证选项 |
| PTP-TLV-08 | SLAVE_RX_SYNC_TIMING_DATA TLV | 16.11 | O | — | Slave事件监控 |
| PTP-TLV-09 | SLAVE_RX_SYNC_COMPUTED_DATA TLV | 16.11 | O | — | Slave计算数据监控 |
| PTP-TLV-10 | SLAVE_TX_EVENT_TIMESTAMPS TLV | 16.11 | O | — | Slave发送事件监控 |
| PTP-TLV-11 | ENHANCED_ACCURACY_METRICS TLV | 16.12 | O | — | 增强精度指标 |
| PTP-TLV-12 | L1_SYNC TLV | L.6 | C | — | L1Sync选项启用时为M |

#### 2.2.8 可选功能 (Clause 16)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-OPT-01 | 单播消息协商 (Unicast Message Negotiation) | 16.1 | O | — | 单播Announce/Sync协商 |
| PTP-OPT-02 | 路径跟踪 (Path Trace) | 16.2 | O | — | 防止环路 |
| PTP-OPT-03 | 替代时标偏移 (Alternate Timescales) | 16.3 | O | — | 多时区支持 |
| PTP-OPT-04 | 保持升级 (Holdover Upgrade) | 16.4 | O | — | 高保持能力节点优先 |
| PTP-OPT-05 | Profile隔离 (Profile Isolation) | 16.5 | O | — | sdoId-based域隔离 |
| PTP-OPT-06 | 通用平均链路延迟服务 (CMLDS) | 16.6 | O | — | 多域共享P2P延迟测量 |
| PTP-OPT-07 | 时间戳可配置校正 | 16.7 | O | — | egress/ingress latency校正 |
| PTP-OPT-08 | 特定介质延迟非对称计算 | 16.8 | O | — | 光纤等介质非对称补偿 |
| PTP-OPT-09 | 混合组播/单播操作 | 16.9 | O | — | 混合通信模式 |
| PTP-OPT-10 | Slave事件监控 | 16.11 | O | — | Slave端监控诊断 |
| PTP-OPT-11 | 增强同步精度指标 | 16.12 | O | — | 精度指标传递 |
| PTP-OPT-12 | 消息长度扩展 | 16.13 | O | — | 消息长度对齐 |
| PTP-OPT-13 | PTP集成安全机制 | 16.14 | O | — | AUTHENTICATION TLV安全 |

#### 2.2.9 状态配置选项 (Clause 17)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-CFG-01 | Grandmaster集群 (Grandmaster Clusters) | 17.2 | O | — | 快速GM切换 |
| PTP-CFG-02 | 替代Master (Alternate Master) | 17.3 | O | — | 备用Master监控 |
| PTP-CFG-03 | 单播发现 (Unicast Discovery) | 17.4 | O | — | 无组播网络发现 |
| PTP-CFG-04 | 可接受Master表 (Acceptable Master Table) | 17.5 | O | — | 安全GM选择 |
| PTP-CFG-05 | PTP端口状态外部配置 | 17.6 | O | — | 外部控制端口状态 |
| PTP-CFG-06 | 简化状态集/foreignMasterList特性 | 17.7 | O | — | 资源受限实现 |

#### 2.2.10 数据集支持

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-DS-01 | defaultDS数据集 | 8.2.1 | M | Yes | 默认数据集 |
| PTP-DS-02 | currentDS数据集 | 8.2.2 | C | — | OC/BC实现时为M，TC不实现 |
| PTP-DS-03 | parentDS数据集 | 8.2.3 | C | — | OC/BC实现时为M，TC不实现 |
| PTP-DS-04 | timePropertiesDS数据集 | 8.2.4 | C | — | OC/BC实现时为M |
| PTP-DS-05 | portDS数据集 | 8.2.5 | M | Yes | 每个端口的数据集 |
| PTP-DS-06 | transparentClockDefaultDS | 8.3.2 | C | — | TC实现时为M |
| PTP-DS-07 | transparentClockPortDS | 8.3.3 | C | — | TC实现时为M |
| PTP-DS-08 | pathTraceDS | 16.2.3 | C | — | 路径跟踪选项实现时为M |
| PTP-DS-09 | acceptableMasterTableDS | 17.5.3 | C | — | 可接受Master表选项时为M |
| PTP-DS-10 | acceptableMasterPortDS | 17.5.4 | C | — | 可接受Master表选项时为M |
| PTP-DS-11 | externalPortConfigurationPortDS | 17.6.3 | C | — | 外部配置选项时为M |
| PTP-DS-12 | slaveMonitoringPortDS | 16.11.6 | C | — | Slave监控选项时为M |
| PTP-DS-13 | performanceMonitoringDS | Annex J | C | — | 性能监控选项时为M |
| PTP-DS-14 | L1SyncBasicPortDS | L.5 | C | — | L1Sync选项时为M |

#### 2.2.11 Profile支持

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-PRF-01 | Delay Request-Response Default PTP Profile | I.3 | C | — | 声明支持E2E Profile时为M |
| PTP-PRF-02 | Peer-to-Peer Default PTP Profile | I.4 | C | — | 声明支持P2P Profile时为M |
| PTP-PRF-03 | High-Accuracy Delay Request-Response Default PTP Profile | I.5 | C | — | 声明支持HA Profile时为M |
| PTP-PRF-04 | Profile标识 (profileIdentifier) | 20.3.3 | M | Yes | 每个Profile唯一标识 |
| PTP-PRF-05 | Profile声明能力 | 20.2.3 | M | Yes | 至少声明一个支持的Profile |

#### 2.2.12 传输映射支持

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-TRN-01 | IPv4/UDP传输映射 | Annex D | C | — | 使用IP/UDP传输时为M |
| PTP-TRN-02 | IPv6/UDP传输映射 | Annex E | C | — | 使用IPv6传输时为M |
| PTP-TRN-03 | IEEE 802.3/Ethernet传输映射 | Annex F | C | — | 车载以太网场景推荐 |
| PTP-TRN-04 | DeviceNet传输映射 | Annex G | C | — | DeviceNet场景 |
| PTP-TRN-05 | ControlNet传输映射 | Annex H | C | — | ControlNet场景 |
| PTP-TRN-06 | PROFINET传输映射 | Annex H | C | — | PROFINET场景 |

#### 2.2.13 安全管理 (L1 Sync与高精度)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-L1-01 | L1Sync使能控制 (L1SyncEnabled) | L.4.1, L.5.2.1 | C | — | L1Sync选项时为M |
| PTP-L1-02 | 发送相干端口要求 (txCoherentIsRequired) | L.4.2, L.5.2.2 | C | — | L1Sync选项时为M |
| PTP-L1-03 | 接收相干端口要求 (rxCoherentIsRequired) | L.4.3, L.5.2.3 | C | — | L1Sync选项时为M |
| PTP-L1-04 | 一致性端口要求 (congruentIsRequired) | L.4.4, L.5.2.4 | C | — | L1Sync选项时为M |
| PTP-L1-05 | L1Sync状态机 | L.7 | C | — | L1Sync选项时为M |
| PTP-L1-06 | L1_SYNC TLV收发 | L.6 | C | — | L1Sync选项时为M |
| PTP-L1-07 | 可选相位偏移参数 | L.8 | C | — | L1Sync optParamsEnabled时为M |

#### 2.2.14 一致性声明

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|---------|---------|---------|------|--------|------|
| PTP-CNF-01 | 符合Clause 20一致性要求 | 20.2 | M | Yes | 一致性基础要求 |
| PNP-CNF-02 | 声明支持的PTP Profile | 20.2.3 | M | Yes | 至少声明一个Profile |
| PTP-CNF-03 | 声明支持的传输映射 | 20.2.2 | M | Yes | 使用的传输映射 |
| PTP-CNF-04 | 声明实现的选项列表 | 20.2.1 | M | Yes | 所有实现的选项 |
| PTP-CNF-05 | 声明时钟类型 | 20.2.1 | M | Yes | OC/BC/TC等 |
| PTP-CNF-06 | 声明路径延迟机制 | 20.3.1.2 | M | Yes | E2E/P2P |
| PTP-CNF-07 | 声明精度指标 | 20.3.1.2 | O | — | 精度/保持能力等 |

---

