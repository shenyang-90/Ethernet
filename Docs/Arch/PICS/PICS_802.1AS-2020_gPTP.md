# PICS — IEEE Std 802.1AS-2020 — Timing and Synchronization for Time-Sensitive Applications (gPTP)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 802.1AS-2020 — Timing and Synchronization for Time-Sensitive Applications (gPTP)
> **PICS来源**: Annex A（规范性附录）原生PICS完整提取
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能
> **生成日期**: 2025年

---

## 2. PICS提取 — 来自Annex A（规范性附录）

### 2.1 PICS说明

IEEE 802.1AS-2020在**Annex A**中提供了完整的Protocol Implementation Conformance Statement (PICS) proforma。PICS是实现者用来声明其协议实现能力的标准化表格。

**状态符号定义**:
| 符号 | 含义 |
|------|------|
| M | Mandatory（必选） |
| O | Optional（可选） |
| O.n | Optional组，至少支持n个选项 |
| X | Prohibited（禁止） |
| pred: S | 条件项，pred为真时状态为S（M或O） |
| ¬ | 逻辑非 |
| N/A | Not Applicable（不适用） |

### 2.2 Major Capabilities（主要能力）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| DOM0 | 支持domain number为0的PTP Instance | 5.4 item a), 8.1 | M | Yes | 所有实现必须支持domain 0 |
| DOMADD | 支持domain number 1-127的额外PTP Instance | 5.4.2 item f), 8.1 | O | Yes/No | 多域支持，用于冗余和不同时间尺度 |
| MINTA | 至少支持一个具有最小需求的PTP Port | 10.2.13, 5.4 item c), A.7 | M | Yes | 最基本的时间感知系统需求 |
| BMC | 实现Best Master Clock Algorithm | 10.2.13, 5.4 item f), 10.3, A.9 | M | Yes | 自动Grandmaster选择 |
| SIG | 发送Signaling消息 | 5.4.2 item e), 10.6.4, A.8 | O | Yes/No | 用于消息间隔控制和gPTP能力信令 |
| GMCAP | 能够作为Grandmaster PTP Instance | 5.4.2 item c), 10.1.3, A.10 | O | Yes/No | 需要外部高精度时钟源（如GNSS） |
| BRDG | 在两个或多个PTP Port上作为PTP Relay Instance | 5.4.2 item d), 5.4.3 | O | Yes/No | **Zonal Controller with Switch必须支持** |
| MIMSTR | 在至少一个PTP Port上支持media-independent master功能 | GMCAP或BRDG:M, 5.4.2 item b), A.11 | C(M) | Yes/N/A | 条件：若支持GMCAP或BRDG则为必选 |
| MIPERF | 支持性能需求 | 5.4 item j), B.1, B.2.4, A.12 | M | Yes | 包括时钟精度和PTP Instance性能 |
| EXT | 支持external port configuration | 5.4.2 item g), A.21 | O | Yes/No | 用于确定性拓扑配置（替代BMCA） |
| MDFDPP | 在至少一个PTP Port上支持全双工点对点媒体相关功能 | 5.5, Clause 11, A.6, A.13 | O.1 | Yes/No | **车载以太网必须支持** |
| MDDOT11 | 在至少一个PTP Port上支持IEEE 802.11链路功能 | 5.6, Clause 12, A.6, A.14 | O.1 | Yes/No | 无线链路 |
| MDEPON | 支持IEEE 802.3 EPON | 5.7, Clause 13, A.6, A.15 | O.1 | Yes/No | 无源光网络 |
| MDGHN | 在至少一个PTP Port上支持ITU-T G.hn功能 | 5.8 item b), 16.6.3, A.18 | O.1 | Yes/No | 同轴/HomePlug |
| MDMOCA | 在至少一个PTP Port上支持MoCA功能 | 5.8 item b), 16.6.2, A.17 | O.1 | Yes/No | 同轴多媒体 |
| MDCSN | 在至少一个PTP Port上支持CSN功能 | MDGHN或MDMOCA:M, 5.8, Clause 16, A.6, A.16 | C(M) | Yes/No | 条件：若支持MDGHN或MDMOCA则为必选 |
| MGT | 支持PTP Instance管理 | 5.4.2 item j), Clause 14 | O | Yes/No | YANG/MIB管理对象 |
| RMGT | 支持远程管理协议 | MGT:O, 5.4.2 item k), A.19 | C(O) | Yes/No/N/A | 条件：若支持MGT则为可选 |
| APPL | 支持一个或多个应用接口 | 5.4.2 item i), Clause 9, A.20 | O | Yes/No | ClockSourceTime等接口 |

### 2.3 Media Access Control Methods（媒体访问控制方法）— A.6

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MAC-IEEE-802.3 | 实现符合IEEE 802.3 MAC标准 | 11.1 | O:2 | Yes/No | 车载以太网必选 |
| MAC-IEEE-802.11 | 实现符合IEEE 802.11 MAC标准 | 12.1 | O:2 | Yes/No | 无线 |
| MAC-1 | 已为实现的每种MAC方法完成PICS | - | M | Yes | - |
| MAC-2 | 所有实现的MAC方法支持MAC Timing aware Service | Clause 11/12/13 | M | Yes | - |

### 2.4 Minimal Time-Aware System（最小时间感知系统）— A.7

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MINTA-1 | 所有PTP Instance实现SiteSyncSync状态机 | 5.4 item g), 10.2.7 | M | Yes | 域内同步分发 |
| MINTA-2 | 所有PTP Instance在每个PTP Port上实现PortSyncSyncReceive状态机 | 5.4 item d) | M | Yes | 接收同步信息 |
| MINTA-3 | 所有PTP Instance实现ClockSlaveSync状态机 | 10.2.13, 5.4 item e) | M | Yes | 从时钟同步 |
| MINTA-4 | 发送Signaling消息含message interval request TLV时调整syncReceiptTimeoutTimeInterval | SIG:M, 10.6.4.3.7 | C(M) | Yes/N/A | 动态超时调整 |
| MINTA-5 | clockIdentity按8.5.2.2要求构造 | 8.5.2.2 | M | Yes | EUI-48映射 |
| MINTA-6 | 所有发送消息的domain number在0-127范围 | 8.1 | M | Yes | - |
| MINTA-7 | 所有gPTP域消息的majorSdoId为0x1，minorSdoId为0x0 | 8.1 | M | Yes | sdoId = 0x100 |
| MINTA-8 | 至少一个gPTP域的domain number符合8.1要求 | 8.1 | M | Yes | domain 0必须 |
| MINTA-9 | domain 0的时间相对PTP epoch测量 | 8.2.2 | M | Yes | PTP timescale (TAI-37s) |
| MINTA-10 | 路径延迟不对称建模符合8.3要求 | 8.3 | O | Yes/No | 光纤不对称补偿 |
| MINTA-11 | 所有传输的派生数据类型符合6.4.4 | 6.4.4 | M | Yes | 字节序和格式 |
| MINTA-12 | 本地时钟粒度<=40ns | B.1.2 | M | Yes | **硬件实现关键指标** |
| MINTA-13 | 本地时钟频率相对TAI偏差在±100ppm内 | B.1.1 | M | Yes | 晶振精度要求 |
| MINTA-14 | 忽略无法解析的non-propagating TLV并尝试解析下一个 | 10.6.1 | M | Yes | TLV前向兼容 |
| MINTA-15 | 支持signaling gPTP capability相关状态机 | 5.4 item h), 10.4 | M | Yes | gPTP能力发现 |
| MINTA-16 | 支持除Announce和Signaling外所有消息的收发要求 | 5.4 item i), 10.5-10.7 | M | Yes | 消息格式和时序 |
| MINTA-17 | 支持Clause 8的gPTP要求，包括PTP Instance属性 | 5.4 item a), Clause 8, 8.6.2 | M | Yes | 数据集管理 |
| MINTA-18 | 支持时间同步状态机要求 | 5.4 item b) | M | Yes | - |
| MINTA-19 | 实现path trace TLV（接收Announce中处理，发送Announce中附加） | 10.3.11, 10.3.13-16 | M | Yes | 路径追踪 |
| MINTA-20 | 按10.6.1要求转发TLV | 10.6.1 | M | Yes | - |

### 2.5 Signaling（信令）— A.8

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| SIG-1 | Signaling消息序列号符合10.5.7 | SIG:M, 10.5.7 | C(M) | Yes | - |
| SIG-2 | Signaling消息体符合10.6.4.1和Table 10-13 | SIG:M, 10.6.4.1 | C(M) | Yes | - |
| SIG-3 | Signaling消息头符合10.6.2 | SIG:M, 10.6.2 | C(M) | Yes | - |
| SIG-4 | Signaling消息保留字段为0 | SIG:M, 10.6.1 | C(M) | Yes | - |
| SIG-5 | Signaling消息目的MAC=01:80:C2:00:00:0E | SIG:M, 10.5.3 | C(M) | Yes | 非转发多播地址 |
| SIG-6 | Signaling消息EtherType=88-F7 | SIG:M, 10.5.4 | C(M) | Yes | - |
| SIG-7 | Signaling消息的message interval request TLV符合10.6.4.3 | SIG:M, 10.6.4.3 | C(M) | Yes | 含logSyncInterval等 |

### 2.6 Best Master Clock（最佳主时钟）— A.9

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| BMC-1 | 每个PTP Port实现PortAnnounceReceive状态机 | 10.3.11 | M | Yes | Announce消息接收 |
| BMC-2 | 每个PTP Port实现PortAnnounceInformation状态机 | 10.3.12 | M | Yes | Announce信息处理 |
| BMC-3 | 每个PTP Port实现PortStateSelection状态机 | 10.3.13 | M | Yes | 端口状态选择 |
| BMC-4 | clockA的SystemIdentity小于clockB时选择clockA为GM | 10.3.2 | M | Yes | BMCA比较规则 |
| BMC-5 | priority1值符合8.6.2.1 | 8.6.2.1 | M | Yes | 默认128(ETH)/IEEE 802.1Q优先级 |
| BMC-6 | clockClass值符合8.6.2.2 | 8.6.2.2 | M | Yes | 6=GM锁定，7=GM未锁定，etc. |
| BMC-7 | priority2值符合8.6.2.5 | 8.6.2.5 | M | Yes | 默认248 |
| BMC-8 | clockAccuracy值符合8.6.2.3 | 8.6.2.3 | M | Yes | 0x21=<1us, 0x22=<10us |
| BMC-9 | offsetScaledLogVariance值符合8.6.2.4 | 8.6.2.4 | M | Yes | 时钟稳定性度量 |
| BMC-10 | timeSource值符合8.6.2.7和Table 8-2 | 8.6.2.7 | M | Yes | 0x20=GNSS, 0x30=PTP |
| BMC-11 | 非Bridge的PTP Port number=1 | ¬BRDG:M, 8.5.2.3 | C(M) | Yes/N/A | End station端口编号 |
| BMC-12 | PTP Ports编号1到N | 8.5.2.3 | M | Yes | - |
| BMC-13 | clockIdentity字段符合8.5.2.2 | 8.5.2.2 | M | Yes | - |
| BMC-14 | 无GM可用时行为符合10.2.13.2（clockSlaveTime由本地时钟提供） | 10.2.13.2 | M | Yes | 保持模式(holdover) |
| BMC-15 | announceReceiptTimeout值符合10.7.3.2 | 10.7.3.2 | M | Yes | 默认3个interval |
| BMC-16 | SlavePort在announceReceiptTimeout超后从BMCA选择中移除 | 10.7.3.2 | M | Yes | 链路故障检测 |
| BMC-17 | syncReceiptTimeout值符合10.7.3.1 | 10.7.3.1 | M | Yes | 默认3个interval |
| BMC-18 | SlavePort在syncReceiptTimeout超后从BMCA选择中移除 | 10.7.3.1 | M | Yes | 同步丢失检测 |
| BMC-19 | 发送message interval request Signaling后调整announceReceiptTimeout | SIG:M, 10.6.4.3.8 | C(M) | Yes/N/A | - |
| BMC-20 | 若实现ClockSourceTime接口，lastGmPhaseChange值符合9.2.2 | 9.2.2 | O | Yes/No | 相位变化追踪 |
| BMC-21 | 传输的定时信息符合10.3.1（externalPortConfigurationEnabled=false） | GMCAP:M, 10.3.1 | C(M) | Yes/N/A | 标准BMCA模式 |
| BMC-22 | 实现未在前面列出的BMCA要求 | 10.3.2-10.3.10 | M | Yes | 完整BMCA合规 |

### 2.7 Grandmaster-Capable PTP Instance — A.10

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| GMCAP-1 | 实现ClockMasterSyncSend状态机 | GMCAP:M, 10.2.9 | C(M) | Yes/N/A | GM发送Sync |
| GMCAP-2 | 实现ClockMasterSyncOffset状态机 | GMCAP:M, 10.2.10 | C(M) | Yes/N/A | GM频率偏移计算 |
| GMCAP-3 | 实现ClockMasterSyncReceive状态机 | GMCAP:M, 10.2.11 | C(M) | Yes/N/A | GM接收上游时间 |

### 2.8 Media-Independent Master — A.11

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MIMSTR-1 | 每个PTP Port实现AnnounceIntervalSetting状态机 | MIMSTR:M, 10.3.17 | C(M) | Yes/N/A | Announce间隔管理 |
| MIMSTR-2 | 每个PTP Port实现PortSyncSyncSend状态机 | MIMSTR:M, 10.2.12 | C(M) | Yes/N/A | 发送同步信息 |
| MIMSTR-3 | 每个PTP Port实现PortAnnounceTransmit状态机 | MIMSTR:M, 10.3.16 | C(M) | Yes/N/A | Announce传输 |
| MIMSTR-4 | Announce消息目的MAC=01:80:C2:00:00:0E | MIMSTR:M, 10.5.3 | C(M) | Yes | - |
| MIMSTR-5 | Announce消息EtherType=88-F7 | MIMSTR:M, 10.5.4 | C(M) | Yes | - |
| MIMSTR-6 | Announce消息序列号符合10.5.7 | MIMSTR:M, 10.5.7 | C(M) | Yes | - |
| MIMSTR-7 | Announce消息头符合10.6.2 | MIMSTR:M, 10.6.2 | C(M) | Yes | - |
| MIMSTR-8 | Announce消息体符合10.6.3.1和Table 10-11 | MIMSTR:M, 10.6.3.1 | C(M) | Yes | - |
| MIMSTR-9 | Announce消息保留字段为0 | MIMSTR:M, 10.6.1 | C(M) | Yes | - |
| MIMSTR-10 | logAnnounceInterval为0或在允许范围 | MIMSTR:M, 10.7.2.1 | C(M) | Yes | 默认1秒 |
| MIMSTR-11 | currentUtcOffset值符合8.2.3 | MIMSTR:M, 8.2.3 | C(M) | Yes | TAI-UTC差值 |
| MIMSTR-12 | leap59/leap61/currentUtcOffsetValid标志符合10.3.8 | MIMSTR:M, 10.3.8 | C(M) | Yes | 闰秒处理 |
| MIMSTR-13 | 确保消息不带VLAN tag传输（11.3.3） | MIMSTR:M, 11.3.3 | C(M) | Yes | **车载switch注意** |
| MIMSTR-14 | 按10.2.8.3计算cumulative rateRatio | MIMSTR:M, 10.2.8.3 | C(M) | Yes | 频率偏移累积 |
| MIMSTR-15 | Announce消息收发支持消息要求 | MIMSTR:M, 10.5-10.7 | C(M) | Yes | - |

### 2.9 Media-Independent Performance Requirements — A.12

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MIPERF-1 | 符合LocalClock性能要求B.1 | B.1 | M | Yes | 时钟精度、抖动、漂移 |
| MIPERF-2 | 符合PTP Instance性能要求B.2.4 | B.2.4 | M | Yes | rateRatio测量误差 |
| MIPERF-3 | 符合性能推荐B.2.2（residence time<=10ms） | B.2.2 | O | Yes/No | **车载推荐<1ms** |
| MIPERF-4 | 符合性能推荐B.2.3（pdelay turnaround<=10ms） | B.2.3 | O | Yes/No | **车载推荐<100us** |

### 2.10 Media-Dependent, Full-Duplex Point-to-Point Link — A.13

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MDFDPP-1 | 实现MDSyncReceiveSM状态机 | MDFDPP:M, 11.2.14 | C(M) | Yes | Sync接收处理 |
| MDFDPP-2 | 实现MDSyncSendSM状态机 | MIMSTR∧MDFDPP:M, 11.2.15 | C(M) | Yes | Sync发送处理 |
| MDFDPP-3 | 实现MDPdelayReq状态机 | MDFDPP:M, 11.2.19 | C(M) | Yes | Pdelay请求 |
| MDFDPP-4 | 实现MDPdelayResp状态机 | MDFDPP:M, 11.2.20 | C(M) | Yes | Pdelay响应 |
| MDFDPP-5 | 实现SyncIntervalSetting状态机 | MDFDPP:M, 10.3.18, 5.5 item c) | C(M) | Yes | Sync间隔设置 |
| MDFDPP-6 | 实现LinkDelayIntervalSetting状态机 | MDFDPP:M, 11.2.21 | C(M) | Yes | Pdelay间隔设置 |
| MDFDPP-7 | Sync消息ingress时按LocalClock时间戳 | MDFDPP:M, 11.3.2.1 | C(M) | Yes | **硬件时间戳** |
| MDFDPP-8 | Sync消息egress时按LocalClock时间戳 | MIMSTR∧MDFDPP:M, 11.3.2.1 | C(M) | Yes | **硬件时间戳** |
| MDFDPP-9 | Pdelay_Req消息ingress/egress时间戳 | MDFDPP:M, 11.3.2.1 | C(M) | Yes | **硬件时间戳** |
| MDFDPP-10 | Pdelay_Resp消息ingress/egress时间戳 | MDFDPP:M, 11.3.2.1 | C(M) | Yes | **硬件时间戳** |
| MDFDPP-11 | 所有消息不带Q-tag发送 | MDFDPP:M, 11.3.3 | C(M) | Yes | 非VLAN感知 |
| MDFDPP-12 | 消息目的MAC=01-80-C2-00-00-0E | MDFDPP:M, 11.3.4 | C(M) | Yes | - |
| MDFDPP-13 | 消息源MAC为端口分配地址 | MDFDPP:M, 11.3.4 | C(M) | Yes | - |
| MDFDPP-14 | 消息EtherType=88-F7 | MDFDPP:M, 11.3.5 | C(M) | Yes | - |
| MDFDPP-15 | 消息头符合11.4.2和Table 10-7 | MDFDPP:M, 11.4.2 | C(M) | Yes | gPTP通用头 |
| MDFDPP-16 | Sync消息体符合11.4.3和Table 11-8/9 | MDFDPP:M, 11.4.3 | C(M) | Yes | - |
| MDFDPP-17 | Follow_Up消息体符合11.4.4和Table 11-10 | MDFDPP:M, 11.4.4 | C(M) | Yes | 含Follow_Up TLV |
| MDFDPP-18 | Pdelay_Req消息体符合11.4.5和Table 11-12 | MDFDPP:M, 11.4.5 | C(M) | Yes | - |
| MDFDPP-19 | Pdelay_Resp消息体符合11.4.6和Table 11-13 | MDFDPP:M, 11.4.6 | C(M) | Yes | - |
| MDFDPP-20 | Pdelay_Resp_Follow_Up消息体符合11.4.7和Table 11-14 | MDFDPP:M, 11.4.7 | C(M) | Yes | - |
| MDFDPP-21 | 保留字段设置为0 | MDFDPP:M, 11.4.1 | C(M) | Yes | - |
| MDFDPP-22 | Sync消息序列号符合11.3.8 | MIMSTR∧MDFDPP:M, 11.3.8 | C(M) | Yes | - |
| MDFDPP-23 | Pdelay_Req消息序列号符合11.3.8 | MDFDPP:M, 11.3.8 | C(M) | Yes | - |
| MDFDPP-24 | Pdelay平均请求发送间隔符合11.5.2.2 | MDFDPP:M, 11.5.2.2 | C(M) | Yes | 默认1s |
| MDFDPP-25 | Sync平均发送间隔符合11.5.2.3 | MDFDPP:M, 11.5.2.3 | C(M) | Yes | 默认125ms |
| MDFDPP-26 | 全双工媒体相关层按11.2.2设置asCapable | MDFDPP:M, 11.2.2 | C(M) | Yes | 链路能力检测 |
| MDFDPP-27 | 流控使用符合11.2.3和11.2.4 | MDFDPP:M, 11.2.3-4 | C(M) | Yes | 避免Pdelay阻塞 |
| MDFDPP-28 | 未收到有效Pdelay响应时不交换Pdelay消息 | MDFDPP:M, 11.5.3 | C(M) | Yes | asCapable置FALSE |
| MDFDPP-29 | 忽略无法解析的TLV并尝试下一个 | MDFDPP:M, 11.4.1 | C(M) | Yes | 前向兼容 |
| MDFDPP-30 | 按11.2.2初始化meanLinkDelayThresh | MDFDPP:M, 11.2.2 | C(M) | Yes | 默认400ns(100M)/800ns(1G) |
| MDFDPP-31 | 支持asymmetry measurement mode | MDFDPP:O, 14.13, 14.18, 10.2.5等 | C(O) | Yes/No | 光纤不对称测量 |
| MDFDPP-32 | 支持one-step receive | MDFDPP:O, 11.2.14 | C(O) | Yes/No | **TC4x硬件支持** |
| MDFDPP-33 | 支持one-step transmit | MDFDPP:O, 11.2.15 | C(O) | Yes/No | **TC4x硬件支持** |
| MDFDPP-34 | 实现OneStepTxOperSetting状态机 | MDFDPP:O, 11.2.16 | C(O) | Yes/No | one-step运行控制 |
| MDFDPP-35 | 支持propagation delay averaging | MDFDPP:O, 11.2.19.3.4 | C(O) | Yes/No | 减少测量噪声 |

### 2.11 Media-Dependent IEEE 802.11 Link — A.14

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MDDOT11-1 | 802.11 MAC实现master port功能 | MDDOT11∧MIMSTR:M, 5.6, 12.5.1 | C(M) | Yes | FTM/TM机制 |
| MDDOT11-2 | 802.11 MAC实现slave port功能 | MDDOT11:M, 5.6, 12.5.2 | C(M) | Yes | - |
| MDDOT11-3 | 按12.4确定asCapable值 | MDDOT11:M, 12.4 | C(M) | Yes | - |
| MDDOT11-4 | 按12.8确定同步消息平均间隔 | MDDOT11∧MIMSTR:M, 12.8 | C(M) | Yes | - |
| MDDOT11-5 | 支持VendorSpecific IE承载端到端定时信息 | MDDOT11:M, 12.7 | C(M) | Yes | - |
| MDDOT11-6 | 实现Fine Timing Measurement作为master port | MDDOT11-1:O, 5.6, 12.5.1 | C(O) | Yes/No | 802.11mc FTM |
| MDDOT11-7 | 实现Fine Timing Measurement作为slave port | MDDOT11-2:O, 5.6, 12.5.2 | C(O) | Yes/No | - |

### 2.12 Media-Dependent IEEE 802.3 EPON Link — A.15

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MDEPON-1 | TIMESYNC消息格式符合13.3和Table 13-1 | MDEPON:M, 13.3 | C(M) | Yes | MPCP帧封装 |
| MDEPON-2 | 实现requester状态机 | MDEPON∧MIMSTR:M, 13.8.1 | C(M) | Yes | OLT/ONU发现 |
| MDEPON-3 | 实现responder状态机 | MDEPON:M, 13.8.2 | C(M) | Yes | - |
| MDEPON-4 | TIMESYNC消息发送间隔符合13.9.1-2 | MDEPON:M, 13.9 | C(M) | Yes | - |
| MDEPON-5 | Best master selection符合13.1.3 | MDEPON:M, 13.1.3 | C(M) | Yes | OLT为master |
| MDEPON-6 | asCapable确定符合13.4 | MDEPON:M, 13.4 | C(M) | Yes | - |

### 2.13 Media-Dependent CSN Link — A.16

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MDCSN-1 | 实现MDSyncSendSM状态机 | MDCSN∧MIMSTR:M, 11.2.15 | C(M) | Yes | CSN backbone |
| MDCSN-2 | 实现MDSyncReceiveSM状态机 | MDCSN:M, 11.2.14 | C(M) | Yes | - |
| MDCSN-3 | 按16.4要求计算path delay | MDCSN:M, 16.4 | C(M) | Yes | CSN路径延迟 |
| MDCSN-4 | 按16.5要求传播同步时间 | MDCSN:M, 16.5 | C(M) | Yes | - |
| MDCSN-5 | 按16.7要求作为Grandmaster PTP Instance | GMCAP∧MDCSN:M, 16.7 | C(M) | Yes/N/A | CSN GM能力 |
| MDCSN-6 | 符合16.8性能要求 | GMCAP∧MDCSN:M, 16.8 | C(M) | Yes/N/A | CSN时钟性能 |

### 2.14 Media-Dependent MoCA Link — A.17

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MDMOCA-1 | MoCA MD实体按16.6.2传播Sync消息 | MDMOCA:M, 16.6.2 | C(M) | Yes | MoCA控制帧封装 |

### 2.15 Media-Dependent ITU-T G.hn Link — A.18

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| MDGHN-1 | GHN MD实体按16.6.3传播Sync消息 | MDGHN:M, 16.6.3 | C(M) | Yes | G.hn帧封装 |

### 2.16 Remote Management — A.19

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| RMGT-1 | 支持的远程管理协议标准 | RMGT:M, 5.4.2 item k)1) | C(M) | 文本 | SNMP/YANG等 |
| RMGT-2 | 支持的管理对象定义和编码标准 | RMGT:M, 5.4.2 item k)2) | C(M) | 文本 | SMIv2等 |
| RMGT-3 | 若支持SNMP，IEEE 8021-AS-MIB模块完全支持 | RMGT:O, 5.4.2 item k)3), Clause 15 | C(O) | Yes/No | MIB compliance |

### 2.17 Application Interfaces — A.20

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| APPL-1 | 支持的应用接口 | APPL:M, 5.4.2 item i) | C(M) | 文本 | ClockSourceTime/ClockTarget等 |

### 2.18 External Port Configuration — A.21

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|----------|----------|------|--------|------|
| EXT-1 | 支持externalPortConfigurationEnabled=true的规范 | EXT:M, 10.3.1 | C(M) | Yes/N/A | **车载确定性拓扑推荐** |
| EXT-2 | 支持PortAnnounceInformationExt状态机 | EXT:M, 10.3.14 | C(M) | Yes/N/A | 外部端口信息 |
| EXT-3 | 支持PortStateSettingExt状态机 | EXT:M, 10.3.15 | C(M) | Yes/N/A | 外部端口状态设置 |

---

