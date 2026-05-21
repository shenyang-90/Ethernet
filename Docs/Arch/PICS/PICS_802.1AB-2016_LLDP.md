# PICS — IEEE Std 802.1AB-2016 — Station and Media Access Control Connectivity Discovery (LLDP)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 802.1AB-2016 — Station and Media Access Control Connectivity Discovery (LLDP)
> **PICS来源**: Annex A（规范性附录）原生PICS完整提取
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能
> **生成日期**: 2025年

---

## 2. PICS 提取（Annex A）

### 2.1 PICS 概览

IEEE Std 802.1AB-2016 在 **Annex A（normative）** 中提供了完整的 PICS（Protocol Implementation Conformance Statement）proforma。PICS 是声明实现符合本标准所必须填写的标准化问卷。

**状态符号说明**：

| 符号 | 含义 |
|:---:|:---|
| **M** | Mandatory - 强制要求 |
| **O** | Optional - 可选 |
| **O.n** | 可选，但至少支持同一数字 n 标记的一个选项 |
| **C** | Conditional - 条件性的 |
| **X** | Prohibited - 禁止 |
| **N/A** | Not Applicable - 不适用 |

### 2.2 实施标识（A.3.5）

| 项目 | 内容 |
|:---|:---|
| Supplier | （供应商名称） |
| Contact point | （查询联系人） |
| Implementation Name(s) and Version(s) | （实现名称和版本） |
| Other information | （机器/操作系统名称和版本） |

### 2.3 主要能力与选项 PICS（A.4）

#### 2.3.1 端口访问控制与寻址

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **cntrlport** | 如果端口访问由 IEEE Std 802.1X 控制，LLDP 交换是否通过受控端口支持？ | 5.3, 6 | M | Yes / N/A | 强制要求通过 802.1X 受控端口支持 LLDP |
| **uncntrlport** | 如果端口访问由 IEEE Std 802.1X 控制，LLDP 交换是否通过非受控端口支持？ | 5.4, 6 | O | Yes / No / N/A | 可选支持通过非受控端口交换 |

#### 2.3.2 LLDP 寻址与 EtherType 编码

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **addr** | LLDP 寻址和 LLDP EtherType 编码是否符合定义的要求？ | — | — | — | 寻址能力总项 |
| **addr/1** | DA = 任意组播 MAC 地址 | 7.1 | O | Yes / No | 所有系统可选 |
| **addr/2** | DA = 任意单播 MAC 地址 | 7.1 | O | Yes / No | 所有系统可选 |
| **addr/3** | SA = 站点 MAC 地址 | 7.2 | M | Yes | 源地址强制要求 |
| **addr/4** | LLDP EtherType 编码 | 7.3 | M | Yes | EtherType = 0x88CC |
| **addr/5** | C-VLAN Bridge: DA = 最近桥地址 | 7.1 | M | Yes / N/A | C-VLAN 桥强制 |
| **addr/6** | C-VLAN Bridge: DA = 最近非 TPMR 桥地址 | 7.1 | M | Yes / N/A | C-VLAN 桥强制 |
| **addr/7** | C-VLAN Bridge: DA = 最近客户桥地址 | 7.1 | X | No / N/A | **C-VLAN 桥禁止** |
| **addr/8** | S-VLAN Bridge: DA = 最近桥地址 | 7.1 | M | Yes / N/A | S-VLAN 桥强制 |
| **addr/9** | S-VLAN Bridge: DA = 最近非 TPMR 桥地址 | 7.1 | M | Yes / N/A | S-VLAN 桥强制 |
| **addr/10** | S-VLAN Bridge: DA = 最近客户桥地址 | 7.1 | X | No / N/A | **S-VLAN 桥禁止** |
| **addr/11** | TPMR Bridge: DA = 最近桥地址 | 7.1 | X | No / N/A | **TPMR 桥禁止** |
| **addr/12** | TPMR Bridge: DA = 最近非 TPMR 桥地址 | 7.1 | X | No / N/A | **TPMR 桥禁止** |
| **addr/13** | TPMR Bridge: DA = 最近客户桥地址 | 7.1 | X | No / N/A | **TPMR 桥禁止** |
| **addr/14** | End Station: DA = 最近桥地址 | 7.1 | M | Yes / N/A | 终端站强制 |
| **addr/15** | End Station: DA = 最近非 TPMR 桥地址 | 7.1 | O | Yes / No / N/A | 终端站可选 |
| **addr/16** | End Station: DA = 最近客户桥地址 | 7.1 | O | Yes / No / N/A | 终端站可选 |

#### 2.3.3 LLDPDU 封装与 TLV 格式

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **lldpdu** | LLDPDU 封装是否符合 TLV 顺序规范？ | 7.3, 8.2 | M | Yes | 强制 TLV 顺序：Chassis ID → Port ID → TTL |
| **tlvfmt** | 基本 TLV 格式能力是否实现？ | 8.4 | M | Yes | 基本 TLV 格式强制 |
| **basictlv** | 基本管理 TLV 集中的每个 TLV 是否都实现了？ | — | — | — | 基本管理集总项 |
| **basictlv/1** | End Of LLDPDU TLV | 8.5.1 | O | Yes / No | 可选 |
| **basictlv/2** | Chassis ID TLV | 8.5.2 | M | Yes | **强制** - 必须作为第一个 TLV |
| **basictlv/3** | Port ID TLV | 8.5.3 | M | Yes | **强制** - 必须作为第二个 TLV |
| **basictlv/4** | Time To Live TLV | 8.5.4 | M | Yes | **强制** - 必须作为第三个 TLV |
| **basictlv/5** | Port Description TLV | 8.5.5 | M | Yes | **强制实现能力**（传输可选） |
| **basictlv/6** | System Name TLV | 8.5.6 | M | Yes | **强制实现能力**（传输可选） |
| **basictlv/7** | System Description TLV | 8.5.7 | M | Yes | **强制实现能力**（传输可选） |
| **basictlv/8** | System Capabilities TLV | 8.5.8 | M | Yes | **强制实现能力**（传输可选） |
| **basictlv/9** | Management Address TLV | 8.5.9 | M | Yes | **强制实现能力**（传输可选） |
| **xtlvfmt** | Organizationally Specific TLV 能力是否实现？ | 8.6 | O | Yes / No | 可选扩展 TLV 支持 |

> **注**：根据 5.3 j)，如果支持接收 LLDPDU，则对于支持的每个 TLV 集（基本管理集和任何组织特定集），必须实现接收该集中定义的每个 TLV。根据 5.3 k)，如果支持发送 LLDPDU，则必须实现发送该集中定义的每个 TLV。

#### 2.3.4 操作模式

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **optxrx** | 实现了哪些操作模式？ | — | — | — | 至少选择 O.1 组中的一项 |
| **optxrx/1** | 发送和接收（Transmit and receive） | 6.1 | O.1 | Yes / No | 推荐模式 |
| **optxrx/2** | 仅发送（Transmit only） | 6.1 | O.1 | Yes / No | — |
| **optxrx/3** | 仅接收（Receive only） | 6.1 | O.1 | Yes / No | — |
| **txmode** | 发送模式是否符合表 9-1 中 Tx 模式的所有操作规范？ | Clause 9 | M (optxrx OR optx) | Yes / N/A | 条件强制 |
| **rxmode** | 接收模块是否符合表 9-1 中 Rx 模式的所有操作规范？ | Clause 9 | M (optxrx OR oprx) | Yes / N/A | 条件强制 |

#### 2.3.5 数据存储与检索

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **mib** | 实现了哪种类型的数据存储/检索？ | — | — | — | 至少选择 O.2 组中的一项 |
| **mib/1** | SNMP MIB 支持 | 11.5, 5.3 | O.2 | Yes / No | 标准 SNMP 方式 |
| **mib/2** | SNMP MIB 不支持 | 10.1, 5.3 | O.2 | Yes / No | 需等效功能 |
| **snmpmib** | MIB 模块是否符合表 11-1 中针对所实现操作模式的 MIB 部分？ | 11.5, 5.3 | M (mib) | Yes / N/A | 如果支持 SNMP 则强制 |
| **snmpsupport/1** | 使用 IETF RFC 3417 定义的传输映射 | 5.3, 5.4 | O.3 (mib) | Yes / No / N/A | SNMP over UDP |
| **snmpsupport/2** | 使用 IETF RFC 4789 定义的传输映射 | 5.3, 5.4 | O.3 (mib) | Yes / No / N/A | SNMP over IEEE 802 |
| **equivstor** | 如果不支持 SNMP，是否为所实现的操作模式提供了功能等效的存储和检索能力？ | 10.1 | M (nomib) | Yes / N/A | 如果不支持 SNMP 则强制 |

#### 2.3.6 状态机符合性

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **rxsm** | 接收状态机（Receive State Machine）是否符合规范？ | 9.2.9 | M (Rx 模式) | Yes / N/A | 接收模式强制 |
| **txsm** | 发送状态机（Transmit State Machine）是否符合规范？ | 9.2.8 | M (Tx 模式) | Yes / N/A | 发送模式强制 |
| **txtsm** | 发送定时器状态机（Transmit Timer State Machine）是否符合规范？ | 9.2.10 | M (Tx 模式) | Yes / N/A | 发送模式强制 |
| **rxinit** | 接收初始化（rxInitializeLLDP）是否正确实现？ | 9.2.7.1 | M (Rx 模式) | Yes / N/A | — |
| **rxprocess** | 接收处理（rxProcessFrame）是否正确实现？ | 9.2.7.2 | M (Rx 模式) | Yes / N/A | 包括帧验证和 MIB 更新 |
| **txinit** | 发送初始化（txInitializeLLDP）是否正确实现？ | 9.2.7.3 | M (Tx 模式) | Yes / N/A | — |
| **txframe** | 正常 LLDPDU 构造和发送是否正确实现？ | 9.1.2.1 | M (Tx 模式) | Yes / N/A | — |
| **shutdown** | Shutdown LLDPDU（TTL=0）发送是否正确实现？ | 9.1.2.2 | M (Tx 模式) | Yes / N/A | 端口关闭通知 |
| **ttlcompute** | TTL 计算（txTTL = msgTxInterval × msgTxHold）是否正确实现？ | 9.2.5.22 | M (Tx 模式) | Yes / N/A | — |
| **timers** | 所有定时器（txTTR, txDelayWhile, rxInfoTTL 等）是否符合规范？ | 9.2.2 | M | Yes / N/A | — |

#### 2.3.7 MIB 对象组（Table 11-1 交叉引用）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **lldpConfigGroup** | LLDP 配置对象组 | 11.5 | M | Yes | 基本配置参数 |
| **lldpConfigRxGroup** | LLDP 接收配置对象组 | 11.5 | M (Rx 模式) | Yes / N/A | 接收通知间隔等 |
| **lldpConfigTxGroup** | LLDP 发送配置对象组 | 11.5 | M (Tx 模式) | Yes / N/A | 发送间隔、Hold 乘数等 |
| **lldpStatsRxGroup** | LLDP 接收统计对象组 | 11.5 | M (Rx 模式) | Yes / N/A | 接收帧统计 |
| **lldpStatsTxGroup** | LLDP 发送统计对象组 | 11.5 | M (Tx 模式) | Yes / N/A | 发送帧统计 |
| **lldpLocSysGroup** | LLDP 本地系统信息对象组 | 11.5 | M | Yes | 本地 Chassis/Port 信息 |
| **lldpRemSysGroup** | LLDP 远程系统信息对象组 | 11.5 | M (Rx 模式) | Yes / N/A | 邻居信息表 |
| **lldpNotificationsGroup** | LLDP 通知对象组 | 11.5 | M | Yes | RemTablesChange 通知 |

#### 2.3.8 TLV 传输使能管理

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **tlvtxenable** | 是否实现了让用户确定在特定 LLDPDU 中包含哪些可选 TLV 的能力？ | 5.3 l) | M (Tx 模式) | Yes | 强制 - 需支持按端口配置可选 TLV |
| **tlvtx/portdesc** | Port Description TLV 传输使能 | 10.2.2 | O | Yes / No / N/A | — |
| **tlvtx/sysname** | System Name TLV 传输使能 | 10.2.2 | O | Yes / No / N/A | — |
| **tlvtx/sysdesc** | System Description TLV 传输使能 | 10.2.2 | O | Yes / No / N/A | — |
| **tlvtx/syscaps** | System Capabilities TLV 传输使能 | 10.2.2 | O | Yes / No / N/A | — |
| **tlvtx/mgmtaddr** | Management Address TLV 传输使能 | 10.2.2 | O | Yes / No / N/A | — |

#### 2.3.9 组织特定 TLV 集支持（可选扩展）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:---:|:---|:---|:---:|:---:|:---|
| **ieee8021_tlv** | IEEE 802.1 Organizationally Specific TLVs | 802.1Q Annex D | O | Yes / No | DCBX、EVB 等扩展 |
| **ieee8023_tlv** | IEEE 802.3 Organizationally Specific TLVs | 802.3 Clause 79 | O | Yes / No | MAC/PHY 配置、PoE 等 |
| **lldp_med_tlv** | LLDP-MED TLVs (TIA-1057) | 外部标准 | O | Yes / No | 媒体终端发现（需单独标准） |
| **custom_tlv** | 自定义组织特定 TLVs | 8.6 | O | Yes / No | 厂商自定义 |

---

