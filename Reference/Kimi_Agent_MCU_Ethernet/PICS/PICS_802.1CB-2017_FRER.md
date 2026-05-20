# PICS — IEEE Std 802.1CB-2017 — Frame Replication and Elimination for Reliability (FRER)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 802.1CB-2017 — Frame Replication and Elimination for Reliability (FRER)
> **PICS来源**: Annex A（规范性附录）原生PICS完整提取
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能
> **生成日期**: 2025年

---

## 2. PICS提取与说明

### 2.1 PICS来源

本协议**已包含标准PICS proforma**，位于Annex A（第78-86页）。PICS proforma按照ISO/IEC 9646-1和ITU-T X.290系列规范编写，包含以下主要部分：
- A.2.1 Major capabilities/options（主要能力/选项）
- A.2.2 Stream identification component（流识别组件）
- A.2.3 Talker end system（Talker端系统）
- A.2.4 Listener end system（Listener端系统）
- A.2.5 Relay system（中继系统）
- A.2.6 FRER 802.1Q C-component（C组件）
- A.2.7 Common requirements（通用要求）

### 2.2 状态符号说明

| 符号 | 含义 |
|-----|------|
| **M** | Mandatory（强制） |
| **O** | Optional（可选） |
| **O.n** | 可选但至少一个同组选项必须实现 |
| **O/n** | 可选且仅能实现同组中的一个 |
| **C** | Conditional（条件性） |
| **X** | 排除 |
| **!** | 否定 |

---

## 3. PICS表格（完整提取）

### 3.1 Major Capabilities/Options（主要能力/选项）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| BG | FRER C-component 是否实现？ | 5.15 | O | Yes / No | — |
| IS | Stream identification 系统是否实现？ | 5.3, 5.4, 5.5 | O.1 | Yes / No | IS/TE/LE/RS中至少一个必须为Yes |
| TE | Talker end system 是否实现？ | 5.6, 5.7, 5.8 | O.1 | Yes / No | IS/TE/LE/RS中至少一个必须为Yes |
| LE | Listener end system 是否实现？ | 5.9, 5.10, 5.11 | O.1 | Yes / No | IS/TE/LE/RS中至少一个必须为Yes |
| RS | Relay system 是否实现？ | 5.12, 5.13, 5.14, 5.15:b, 5.15:c | BG:M + O.1 | Yes / No | IS/TE/LE/RS中至少一个必须为Yes |

### 3.2 Stream Identification Component（流识别组件）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| IS1 | 系统是否能使用Null Stream identification功能识别帧？ | 5.3:b, 6.4 | IS: M | Yes | — |
| IS2 | 系统是否实现了Clause 9要求的managed objects？ | 5.3:c, 9 | IS: M | Yes | — |
| IS3 | 系统是否能使用Active Destination MAC and VLAN Stream identification编码帧？ | 5.4:a, 6.6 | IS: O | Yes / No | — |
| IS4 | 系统是否能使用IP Stream identification识别数据包？ | 5.5:c, 6.7 | IS: O | Yes / No | — |
| IS5 | 系统可配置哪些额外的Stream解码功能？ | 5.5:d | IS: O | — | 需说明具体内容 |
| IS6 | 说明上述功能可在哪些端口上配置的限制。 | 5.5:a | IS: O | — | 需说明端口限制 |
| IS7 | 说明上述功能可为多少条Stream配置的限制。 | 5.5:b | IS: O | — | 需说明Stream数量限制 |

### 3.3 Talker End System（Talker端系统）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| TE8 | 系统是否能使用Null Stream identification功能识别帧？ | 5.6:b, 6.4 | TE: M | Yes | — |
| TE9 | 系统是否能配置Sequence generation功能？ | 5.6:c, 7.4.1 | TE: M | Yes | **FrerSeqGen核心功能** |
| TE10 | 系统是否能配置Sequence encode/decode功能？ | 5.6:d, 7.8 | TE: M | Yes | **R-TAG编解码** |
| TE11 | 系统是否实现了Clause 9和Clause 10的managed objects（10.7不要求）？ | 5.6:e, 9, 10 | TE: M | Yes | — |
| TE12 | 系统是否能使用Active Destination MAC and VLAN Stream identification编码帧？ | 5.7:a, 6.6 | TE: O | Yes / No | — |
| TE13 | 系统是否能配置Stream splitting功能？ | 5.7:b, 7.7 | TE: M | Yes | **帧复制功能** |
| TE14 | 系统是否能使用IP Stream identification识别数据包？ | 5.8:c, 6.7 | TE: O | Yes / No | — |
| TE15 | 系统可配置哪些额外的Stream解码功能？ | 5.8:d | TE: O | — | 需说明具体内容 |
| TE16 | 系统是否能使用HSR sequence tag编码帧？ | 5.8:e, 7.9 | TE: O | Yes / No | **兼容HSR** |
| TE17 | 系统是否能使用PRP sequence trailer编码帧？ | 5.8:f, 7.10 | TE: O | Yes / No | **兼容PRP** |
| TE18 | 系统可配置哪些额外的Sequence encode/decode功能？ | 5.8:g | TE: O | — | 需说明具体内容 |
| TE19 | 说明上述功能可在哪些端口上配置的限制。 | 5.8:a | TE: O | — | 需说明端口限制 |
| TE20 | 说明上述功能可为多少条Stream配置的限制。 | 5.8:b | TE: O | — | 需说明Stream数量限制 |

### 3.4 Listener End System（Listener端系统）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| LE1 | 系统是否能使用Null Stream identification识别帧？ | 5.9:b, 6.4 | LE: M | Yes | — |
| LE2 | 系统是否能配置至少两个Individual recovery功能？ | 5.9:c, 7.5 | LE: M | Yes | **帧消除基础要求** |
| LE3 | 系统是否能配置至少一个使用MatchRecoveryAlgorithm的Sequence recovery功能？ | 5.9:c, 7.4.2, 7.4.3.5 | LE: M | Yes | **FrerSeqRcvy核心** |
| LE4 | 系统是否支持使用VectorRecoveryAlgorithm且`frerSeqRcvyHistoryLength >= 2`的Sequence recovery功能？ | 5.9:c, 7.4.2, 7.4.3.4 | LE: M | Yes | **Bulk Stream支持** |
| LE5 | 系统是否能配置至少两个使用MatchRecoveryAlgorithm的Individual recovery功能？ | 5.9:d, 7.5, 7.4.3.5 | LE: M | Yes | — |
| LE6 | 系统是否能配置Sequence decoding功能？ | 5.9:e, 7.8 | LE: M | Yes | **R-TAG解码** |
| LE7 | 系统是否实现了Clause 9和Clause 10的managed objects（10.7不要求）？ | 5.9:f, 9, 10 | LE: M | Yes | — |
| LE8 | Base recovery function是否在FCS验证之前处理帧？ | 7.4.3 | LE: M | No | **FCS先于恢复处理** |
| LE9 | 系统是否能使用Active Destination MAC and VLAN Stream identification解码帧？ | 5.10:a, 6.6 | LE: O | Yes / No | — |
| LE10 | 系统是否能使用IP Stream identification解码数据包？ | 5.11:c, 6.7 | LE: O | Yes / No | — |
| LE11 | 系统可配置哪些额外的Stream解码功能？ | 5.11:d | LE: O | — | 需说明具体内容 |
| LE12 | 系统是否能使用HSR sequence tag解码帧？ | 5.11:e, 7.9 | LE: O | Yes / No | **兼容HSR** |
| LE13 | 系统是否能使用PRP sequence trailer解码帧？ | 5.11:f, 7.10 | LE: O | Yes / No | **兼容PRP** |
| LE14 | 系统可配置哪些额外的Sequence decoding功能？ | 5.11:g | LE: O | — | 需说明具体内容 |
| LE15 | 系统是否能配置至少两个使用VectorRecoveryAlgorithm的Individual recovery功能？ | 5.11:h, 7.5, 7.4.3.4 | LE: O | Yes / No | — |
| LE16 | 说明上述功能可在哪些端口上配置的限制。 | 5.11:a | LE: O | — | 需说明端口限制 |
| LE17 | 说明上述功能可为多少条Stream配置的限制。 | 5.11:b | LE: O | — | 需说明Stream数量限制 |

### 3.5 Relay System（中继系统）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| RS1 | 系统是否能使用Null Stream identification功能识别帧？ | 5.12:b, 6.4 | RS: M | Yes | — |
| RS2 | 系统是否能配置Sequence generation功能？ | 5.12:c, 7.4.1 | RS: M | Yes | **中间节点SeqGen** |
| RS3 | 系统是否能配置至少两个Individual recovery功能？ | 5.12:e, 7.5 | RS: M | Yes | — |
| RS4 | 系统是否能配置至少一个使用MatchRecoveryAlgorithm的Sequence recovery功能？ | 5.12:e, 7.4.2, 7.4.3.5 | RS: M | Yes | — |
| RS5 | 系统是否支持使用VectorRecoveryAlgorithm且`frerSeqRcvyHistoryLength >= 2`的Sequence recovery功能？ | 5.12:e, 7.4.2, 7.4.3.4 | RS: M | Yes | — |
| RS6 | 系统是否能配置至少两个使用MatchRecoveryAlgorithm的Individual recovery功能？ | 5.12:f, 7.5, 7.4.3.5 | RS: M | Yes | — |
| RS7 | 系统是否能配置Sequence encode/decode功能？ | 5.12:d, 7.8 | RS: M | Yes | — |
| RS8 | 系统是否实现了Clause 9和Clause 10的managed objects（含10.7）？ | 5.12:g, 9, 10 | RS: M | Yes | — |
| RS9 | Base recovery function是否在FCS验证之前处理帧？ | 7.4.3 | RS: M | No | **FCS先于恢复处理** |
| RS10 | 系统是否能使用Active Destination MAC and VLAN Stream identification编解码帧？ | 5.13:a, 6.6 | RS: O | Yes / No | — |
| RS11 | 系统是否能使用IP Stream identification识别数据包？ | 5.13:b, 6.7 | RS: O | Yes / No | — |
| RS12 | 系统可配置哪些额外的Stream identification功能？ | 5.14:c | RS: O | — | 需说明具体内容 |
| RS13 | 系统是否能配置Stream splitting功能？ | 5.14:d, 7.7 | RS: O | Yes / No | — |
| RS14 | 系统是否能使用HSR sequence tag编解码帧？ | 5.14:e, 7.9 | RS: O | Yes / No | **兼容HSR** |
| RS15 | 系统是否能使用PRP sequence trailer编解码帧？ | 5.14:f, 7.10 | RS: O | Yes / No | **兼容PRP** |
| RS16 | 系统可配置哪些额外的Sequence encode/decode功能？ | 5.14:g | RS: O | — | 需说明具体内容 |
| RS17 | 系统是否能配置至少两个使用VectorRecoveryAlgorithm的Individual recovery功能？ | 5.14:i, 7.5, 7.4.3.4 | RS: O | Yes / No | — |
| RS18 | 系统是否能通过Managed objects配置Autoconfiguration功能？ | 5.14:j, 7.11, 10.7 | RS: O | Yes / No | **零配置运行** |
| RS19 | 说明上述功能可在哪些端口上配置的限制。 | 5.14:a | RS: O | — | 需说明端口限制 |
| RS20 | 说明上述功能可为多少条Stream配置的限制。 | 5.14:b | RS: O | — | 需说明Stream数量限制 |
| RS21 | 说明上述功能可在in-facing或out-facing位置的配置限制。 | 5.14:h | RS: O | — | 需说明位置限制 |

### 3.6 FRER 802.1Q C-component

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| CB1 | FRER 802.1Q C-component是否符合IEEE 802.1Q C-VLAN组件的强制和可选行为要求？ | 5.15:a | BG: M | Yes | **基础C-VLAN桥接** |
| CB2 | FRER 802.1Q C-component是否符合Clause 8定义的FRER功能放置要求？ | 5.15:d, 8 | BG: M | Yes | **FRER功能集成** |
| CB3 | FRER 802.1Q C-component是否实现了所有强制的managed objects？ | 8.4 | BG: M | Yes | — |

### 3.7 Common Requirements（通用要求）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| COM1 | R-TAG是否使用指定的EtherType（0xF1C1）？ | 7.8.1 | M | Yes | **R-TAG EtherType固定值** |
| COM1-1 | R-TAG的Reserved字段是否发送为0并在接收时忽略？ | 7.1.1:d | M | Yes | — |
| COM2 | 所有managed object计数器是否在达到最大值后回绕至0？ | 10.1 | M | Yes | — |
| COM3 | 系统是否能配置latent error detection功能？ | 7.4.4 | LE+RS: M | N/A / Yes | **潜在错误检测** |
| COM4 | `frerSeqRcvyLatentErrorPeriod`的最小支持值是否不大于1秒？ | 10.4.1.12.2 | LE+RS: M | N/A / Yes | — |
| COM5 | RemainingTicks是否以至少100 ticks/s的速率递减？ | 7.4.3.2.5 | LE+RS: M | N/A / Yes | — |
| COM6 | 当尝试配置冲突要求时，系统是否返回错误？ | 10 | M | Yes | — |
| COM7 | `frerSeqRcvyLatentResetPeriod`的最小支持值是否不大于1秒？ | 10.4.1.12.4 | LE+RS: M | N/A / Yes | — |
| COM8 | 在速率超过650 Mbit/s的链路上，所有计数器是否为64位长度？ | 10.8, 10.9 | M | N/A / Yes | — |

---

