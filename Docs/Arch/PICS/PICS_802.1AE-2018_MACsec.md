# PICS — IEEE Std 802.1AE-2018 — MAC Security (MACsec)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 802.1AE-2018 — MAC Security (MACsec)
> **PICS来源**: Annex A（规范性附录）原生PICS完整提取
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含Switch功能
> **生成日期**: 2025年

---

## 二、PICS提取 (Annex A)

IEEE Std 802.1AE-2018 **已包含完整的PICS proforma**（Annex A，规范性附录）。以下是从标准中提取的PICS表格。

### 2.1 PICS说明符号

| 符号 | 含义 |
|------|------|
| M | Mandatory (必选) |
| O | Optional (可选) |
| O.n | 可选，但至少支持同一编号组中的一个 |
| X | Excluded/Prohibited (禁止) |
| pred: S | Conditional (条件性，pred为真时状态为S) |
| ¬ | 逻辑非 |

---

### 2.2 Major Capabilities (主要能力)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| SAP | 每个SecY的MAC Security Entity实现是否支持Controlled和Uncontrolled Port，并使用Common Port | 5.3(a), Clause 10, A.6 | M | Yes | 核心SecY架构 |
| STAT | 是否支持Controlled和Uncontrolled Port的MAC状态和点对点参数 | 5.3(b), 6.4, 6.5, 10.7, A.7 | M | Yes | MAC操作状态 |
| GEN | 是否按Secure Frame Generation (10.5)规范处理Controlled Port的transmit请求 | 5.3(c), 10.5, A.8 | M | Yes | 安全帧生成 |
| VER | 是否按Secure Frame Verification (10.6)规范处理Common Port的receive indication | 5.3(d), 10.6, A.9 | M | Yes | 安全帧验证 |
| FMT | 是否按Clause 9规范编码和解码MACsec PDU | 5.3(e), Clause 9, A.10 | M | Yes | PDU格式 |
| SCI | 是否使用48-bit MAC Address和16-bit Port Identifier标识每个transmit SCI | 5.3(f), 8.2.1 | M | Yes | SCI标识 |
| PERF | 是否满足Table 10-3和8.2.2规定的性能要求 | 5.3(g), 10.1, Table 10-3, 8.2.2 | M | Yes | 性能要求 |
| FCS | 是否引入比保留原始FCS更高的未检测帧错误率 | 5.3(n), 10.4, 6.10 | X | No | 帧错误率限制 |
| KAY | 是否支持Key Agreement Entity要求的LMI操作 | 5.3(h), Clause 10, A.11 | M | Yes | 密钥协商接口 |
| MGT | 是否提供10.7规定的管理功能 | 5.3(i), 10.7, A.12.1 | M | Yes | 管理功能 |
| MIB | 是否支持通过SNMPv3和Clause 13的MIB模块访问MACsec参数 | 5.3(a), Clause 13 | O | Yes/No | SNMPv3管理 |
| SNMX | 是否支持SNMPv3之前的版本访问MACsec参数 | 5.3(p) | X | No | 禁止旧版SNMP |
| MSC | 是否支持多于一个receive SC | 5.4(b) | O | Yes/No | 多接收SC |
| MSAK | 是否支持多于两个receive SAK | 5.4(c) | O | Yes/No | 多接收SAK |
| CS | 是否使用14.1规定的Cipher Suite实现保护和验证MACsec PDU | 5.3(j), 14.1 | M | Yes | Cipher Suite使用 |
| CSI | 是否使用Default Cipher Suite支持完整性保护 | 5.3(k), Clause 14, 14.5 | M | Yes | 默认套件完整性 |
| CSC | 是否使用Default Cipher Suite支持无confidentiality offset的机密性保护 | 5.4(e), Clause 14, 14.5 | ¬CSO:O / CSO:M | Yes/No | 默认套件机密性 |
| CSO | 是否使用Default Cipher Suite支持带confidentiality offset的机密性保护 | 5.4(f), Clause 14, 14.5 | O | Yes/No | 偏移机密性 |
| CSA | 是否包含Clause 14中除Default Cipher Suite外的其他Cipher Suite | 5.4(g), A.13 | O | Yes/No | 额外标准套件 |
| CSX | 是否包含不符合14.2/14.3/14.4.1标准的额外Cipher Suite | 5.3(o), 14.2, 14.3, 14.4.1 | X | No | 禁止非标准套件 |
| CSV | 是否包含符合14.2/14.3/14.4.1标准但非Clause 14规定的Cipher Suite | 5.4(i), A.14 | O | Yes/No | 变体套件 |
| CSR | 每个实现的Cipher Suite是否至少支持1个receive SC、2个receive SAK、1个transmit SC、1个用于传输的receive SAK | 5.3(l), Clause 14 | M | Yes | 最小资源要求 |
| CSS | 是否为每个实现的Cipher Suite声明最大receive SCs/SAKs/transmit SCs数量 | 5.3(m), A.13, A.14 | M | Yes | 最大资源声明 |
| CSRC | Default Cipher Suite支持的最大receive SC数量 | 5.3(m) | M | 数值 | |
| CSRK | Default Cipher Suite支持的最大receive SAK数量 | 5.3(m) | M | 数值 | |
| CSTC | Default Cipher Suite支持的最大transmit SC数量 | 5.3(m) | M | 数值 | |
| TC | 是否支持多于一个transmit SC | 5.4(d) | O | Yes/No | 多发送SC |
| TCT | 是否实现了Traffic Class Table | TC:M, 5.4(h), 10.7.17 | M (if TC) | Yes/N/A | 流量类别表 |
| TCAPT | 是否实现了Access Priority Table | TC:M, 5.4(h), 10.7.17 | M (if TC) | Yes/N/A | 访问优先级表 |
| FULL | 是否声明full conformance | CSV:X / ¬CSV:O | O | Yes/No | 完全一致性 |
| VAR | 是否声明cipher suite variance conformance | 5.3 | M | Yes/No | 变体一致性 |

---

### 2.3 Service Access Points (SAP) 支持

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| SAP-1 | Uncontrolled Port的每个transmit request是否产生一个参数相同的Common Port request | 10.4 | M | Yes | 透传请求 |
| SAP-2 | Common Port的每个receive indication是否产生一个参数相同的Uncontrolled Port indication | 10.4 | M | Yes | 透传指示 |
| SAP-3 | Controlled Port的每个transmit request是否最多产生一个Common Port request | 10.4 | M | Yes | 受控请求 |
| SAP-4 | Common Port的每个receive indication是否最多产生一个Controlled Port indication | 10.4 | M | Yes | 受控指示 |
| SAP-5 | 是否存在不对应Uncontrolled或Controlled Port请求的Common Port transmit request | 10.4 | X | No | 禁止额外请求 |
| SAP-6 | 是否存在不对应Common Port indication的Uncontrolled/Controlled Port receive indication | 10.4 | X | No | 禁止额外指示 |
| SAP-7 | Common Port请求顺序是否与Uncontrolled Port请求顺序一致 | 10.4 | M | Yes | 顺序保持 |
| SAP-8 | Common Port请求顺序是否与Controlled Port请求顺序一致 | 10.4 | M | Yes | 顺序保持 |
| SAP-9 | Uncontrolled Port receive indication顺序是否与Common Port接收顺序一致 | 10.4 | M | Yes | 顺序保持 |
| SAP-10 | Controlled Port的每个transmit request是否按Secure Frame Generation规范处理 | 10.4, 10.5 | M | Yes | 安全帧生成 |
| SAP-11 | Common Port的每个receive indication是否按Secure Frame Verification规范处理 | 10.4, 10.6 | M | Yes | 安全帧验证 |

---

### 2.4 MAC Status and Point-to-Point Parameters

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| STAT-1 | Uncontrolled Port的MAC_Operational和operPointToPointMAC是否与Common Port相同 | 6.4, 10.7.2 | M | Yes | 状态同步 |
| STAT-2 | 若encodingSA不可用且protectFrames设置，Controlled Port的MAC_Operational是否为False | 6.4, 10.5.1, 7.1 | M | Yes | SA不可用保护 |
| STAT-3 | 若encodingSA的nextPN为0或2^32，Controlled Port MAC_Operational是否为False | 6.4, 10.5.2 | M | Yes | PN耗尽保护 |
| STAT-4 | Controlled Port MAC_Operational为True是否仅当MAC_Enabled为True且Common Port MAC_Operational为True | 6.4, 10.7.4 | M | Yes | 状态依赖 |
| STAT-5 | Controlled Port的operPointToPointMAC值是否始终按10.7.4规定 | 6.5, 10.7.4 | M | Yes | 点对点参数 |

---

### 2.5 Secure Frame Generation (安全帧生成)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| GEN-1 | protectFrames为False时，Controlled Port的transmit request是否原样传递到Common Port | 10.5 | M | Yes | 旁路模式 |
| GEN-2 | protectFrames为True时，是否按10.5规范保护帧 | 10.5 | M | Yes | 保护模式 |
| GEN-3 | 受保护帧是否分配到AN对应encodingSA当前值的SA | 10.5.1 | M | Yes | SA分配 |
| GEN-4 | 若分配SA不可用，帧是否被丢弃 | 10.5.1 | M | Yes | SA不可用丢弃 |
| GEN-5 | PN值零是否被使用 | 10.5.2 | X | No | 禁止PN=0 |
| GEN-6 | 同一SA的下一帧是否分配递增的PN值 | 10.5.2 | M | Yes | PN递增 |
| GEN-7 | SecTAG是否按Clause 9编码 | 10.5.3, Clause 9 | M | Yes | SecTAG格式 |
| GEN-8 | ES bit是否按useES和alwaysIncludeSCI管理控制正确设置/清除 | 10.5.3 | M | Yes | ES位控制 |
| GEN-9 | SC bit和SCI显式编码是否按useES/useSCB/alwaysIncludeSCI和receive SC数量正确设置 | 10.5.3 | M | Yes | SC位控制 |
| GEN-10 | SCB bit是否按useSCB和alwaysIncludeSCI管理控制正确设置/清除 | 10.5.3 | M | Yes | SCB位控制 |
| GEN-11 | 机密性保护时E bit是否设置，否则清除 | 9.5 | M | Yes | E位指示加密 |
| GEN-12 | Secure Data与User Data不同或ICV非16 octets时C bit是否设置 | 9.5 | M | Yes | C位指示变化 |
| GEN-13 | protectFrames设置时，Controlled Port发送的帧是否使用Cipher Suite保护 | 10.5 | M | Yes | 加密保护 |
| GEN-14 | 提供机密性保护时OutOctetsEncrypted是否增加User Data octets数，否则OutOctetsProtected增加 | 10.5.4 | M | Yes | 统计计数 |
| GEN-15 | MACsec PDU不超过Common Port最大数据单元大小时是否传输，否则丢弃 | 10.5.5 | M | Yes | 帧长检查 |

---

### 2.6 Secure Frame Verification (安全帧验证)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| VER-1 | Secure Frame Verification是否检查SecTAG并按9.12验证，按9.3-9.9解码SecTAG，按9.10/9.11提取User Data和ICV | 10.6, 9.3-9.12 | M | Yes | 验证流程 |
| VER-2 | 无SecTAG的接收帧在validateFrames非Strict时是否交付Controlled Port，否则丢弃 | 10.6 | M | Yes | 无Tag处理 |
| VER-3 | SecTAG E bit设置且C bit清除的接收帧是否丢弃 | 10.6 | M | Yes | 无效组合丢弃 |
| VER-4 | SC未知且validateFrames为Strict或C bit设置时是否丢弃，否则交付 | 10.6.1 | M | Yes | 未知SC处理 |
| VER-5 | SA未使用且validateFrames为Strict或C bit设置时是否丢弃，否则交付 | 10.6.1 | M | Yes | 未用SA处理 |
| VER-6 | PN小于SA最低可接受PN且replayProtect启用时是否丢弃 | 10.6.2, 10.6.4 | M | Yes | 重放保护 |
| VER-7 | 接收帧因非数据原因丢弃时InPktsOverrun计数器是否递增 | 10.6.3 | M | Yes | 溢出统计 |
| VER-8 | validateFrames为Disabled时是否跳过Cipher Suite验证，C bit未设置时交付 | 10.6.3, 10.6.5 | M | Yes | 禁用验证模式 |
| VER-9 | validateFrames非Disabled时是否使用Cipher Suite验证 | 10.6.3 | M | Yes | 启用验证 |
| VER-10 | 验证失败帧在validateFrames为Strict或C bit设置时是否丢弃 | 10.6.5 | M | Yes | 严格模式丢弃 |
| VER-11 | 成功验证后next expected和lowest acceptable PN是否按10.6.5更新 | 10.6.5 | M | Yes | PN更新 |
| VER-12 | 未被Secure Frame Verification丢弃的接收帧是否去除SecTAG和ICV后交付Controlled Port | 10.6 | M | Yes | 正常交付 |
| VER-13 | validateFrames为Null时所有接收帧是否未经修改交付Controlled Port | 10.6 | M | Yes | Null模式 |
| VER-14 | validateFrames为Null时protectFrames是否设为False | 10.6 | M | Yes | Null联动 |

---

### 2.7 MACsec PDU Encoding and Decoding

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| FMT-1 | 每个传输的MACsec PDU是否包含整数个octets | 9.1 | M | Yes | 整数octet |
| FMT-2 | 每个MACsec PDU是否包含SecTAG、Secure Data和ICV | 9.1, 9.2, 9.3 | M | Yes | PDU组成 |
| FMT-3 | SecTAG中的EtherType是否按Table 9-1编码 | 9.3, 9.4 | M | Yes | EtherType值 |
| FMT-4 | SecTAG版本号是否编码为0 | 9.5 | M | Yes | 版本0 |
| FMT-5 | ES bit设置时SC bit是否清除且SCI不显式编码 | 9.5 | M | Yes | ES模式 |
| FMT-6 | SCI显式编码时SC bit是否设置，否则清除 | 9.5 | M | Yes | SC位规则 |
| FMT-7 | SCB bit设置时SC bit是否清除 | 9.5 | M | Yes | SCB模式 |
| FMT-8 | SecTAG第4 octet的bits 7和8是否为零 | 9.7 | M | Yes | 保留位 |
| FMT-9 | 每个接收的MACsec PDU是否按9.12验证 | 9.5 | M | Yes | PDU验证 |

---

### 2.8 Key Agreement Entity LMI (Layer Management Interface)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| KAY-1 | KaY是否能读取MAC_Enabled、MAC_Operational、operPointToPointMAC参数值 | 10.7.2 | M | Yes | 状态读取 |
| KAY-2 | KaY是否能设置和清除ControlledPortEnabled参数 | 10.7.4, 10.7.5 | M | Yes | 端口控制 |
| KAY-3 | KaY是否能发现哪些Cipher Suite已实现及每个支持多少receive SC | 10.2, 10.7.7, 10.7.16, 10.7.25 | M | Yes | 能力发现 |
| KAY-4 | KaY是否能创建receive SC | 10.6.1, 10.7.11 | M | Yes | 创建接收SC |
| KAY-5 | KaY是否能按10.7.13创建receive SAs | 10.7.13 | M | Yes | 创建接收SA |
| KAY-6 | KaY是否能控制每个receive SA的使用并更新next expected PN和lowest acceptable PN | 10.7.15 | M | Yes | SA控制 |
| KAY-7 | KaY是否能按10.7.22创建transmit SAs | 10.7.22, 10.5.2 | M | Yes | 创建发送SA |
| KAY-8 | KaY是否能按10.7.24控制每个transmit SA的使用 | 10.7.24, 10.5.1, 10.5.2 | M | Yes | 发送SA控制 |
| KAY-9 | KaY是否能监控每个transmit SA的nextPN以便PN耗尽前创建新SA | 10.7.2 | M | Yes | PN监控 |
| KAY-10 | KaY是否能按10.7.27选择Current Cipher Suite | 10.7.27 | M | Yes | 套件选择 |
| KAY-11 | KaY是否能按10.7.26和10.7.28创建和控制SAK | 10.7.26, 10.7.28 | M | Yes | SAK管理 |

---

### 2.9 Management — Control and Status Information (管理控制与状态)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| MGT1-1 | 是否可通过管理读取SecY的SCI | 10.7.1 | M | Yes | SCI读取 |
| MGT1-2 | 是否可读取Uncontrolled Port的MAC_Enabled/MAC_Operational/operPointToPointMAC | 10.7.2 | M | Yes | 非控端口状态 |
| MGT1-3 | 是否可读取Controlled Port的MAC_Enabled/MAC_Operational/operPointToPointMAC | 10.7.4 | M | Yes | 受控端口状态 |
| MGT1-4 | 是否可读取最大同时使用的receive SCs和SAKs数量 | 10.7.7 | M | Yes | 最大能力 |
| MGT1-5 | 是否可读取validateFrames/replayProtect/replayWindow | 10.7.8 | M | Yes | 验证参数 |
| MGT1-6 | 是否可读取每个receive SC的SCI/receiving/createdTime/startedTime/stoppedTime | 10.7.12 | M | Yes | 接收SC信息 |
| MGT1-7 | 是否可读取每个receive SA的inUse/nextPN/lowestPN/createdTime/startedTime/stoppedTime/Key Identifier | 10.7.14 | M | Yes | 接收SA信息 |
| MGT1-8 | 是否可读取可同时用于传输的最大SAKs数量 | 10.7.16 | M | Yes | 发送SAK容量 |
| MGT1-9 | 是否可读取protectFrames/useES/useSCB/alwaysIncludeSCI | 10.7.17 | M | Yes | 保护控制 |
| MGT1-10 | 是否可读取transmit SC的transmitting/createdTime/startedTime/stoppedTime | 10.7.21 | M | Yes | 发送SC信息 |
| MGT1-11 | 是否可读取每个transmit SA的inUse/nextPN/lowestPN/createdTime/startedTime/stoppedTime/Key Identifier | 10.7.23 | M | Yes | 发送SA信息 |
| MGT1-12 | 是否可读取currentCipherSuite标识符和confidentialityOffset | 10.7.27 | M | Yes | 当前套件 |
| MGT1-13 | 是否可读取每个SAK的transmits/receives/createdTime | 10.7.29 | M | Yes | SAK状态 |
| MGT1-14 | 是否可读取每个实现的Cipher Suite的管理信息 | 10.7.25 | M | Yes | 套件信息 |

---

### 2.10 Management — Basic Controls (基本管理控制)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| MGT2-1 | validateFrames是否可由管理独立写入 | 10.7.8, 10.6 | O | Yes/No | 验证模式控制 |
| MGT2-2 | replayProtect是否可由管理独立写入 | 10.7.8, 10.6.2, 10.6.4 | O | Yes/No | 重放保护控制 |
| MGT2-3 | replayWindow是否可由管理独立写入 | 10.7.8, 10.6.5 | O | Yes/No | 重放窗口控制 |
| MGT2-4 | protectFrames是否可由管理独立写入 | 10.7.17, 10.5 | O | Yes/No | 保护使能控制 |
| MGT2-5 | useES是否可由管理独立写入 | 10.7.17, 10.5.3 | O | Yes/No | ES控制 |
| MGT2-6 | useSCB是否可由管理独立写入 | 10.7.17, 10.5.3 | O | Yes/No | SCB控制 |
| MGT2-7 | alwaysIncludeSCI是否可由管理独立写入 | 10.7.17, 10.5.3 | O | Yes/No | SCI包含控制 |
| MGT2-15 | enableUse是否可由管理为每个Cipher Suite独立写入 | 10.7.26 | O | Yes/No | 套件使能 |
| MGT2-16 | requireConfidentiality是否可由管理为每个Cipher Suite独立写入 | 10.7.26 | O | Yes/No | 机密性要求 |
| MGT2-8 | validateFrames的管理写入是否可单独禁用 | MGT2-1:M | 10.7.8 | M (if MGT2-1) | Yes | 写保护 |
| MGT2-9 | replayProtect的管理写入是否可单独禁用 | MGT2-2:M | 10.7.8 | M (if MGT2-2) | Yes | 写保护 |
| MGT2-10 | replayWindow的管理写入是否可单独禁用 | MGT2-3:M | 10.7.8 | M (if MGT2-3) | Yes | 写保护 |
| MGT2-11 | protectFrames的管理写入是否可单独禁用 | MGT2-4:M | 10.7.17 | M (if MGT2-4) | Yes | 写保护 |
| MGT2-12 | useES的管理写入是否可单独禁用 | MGT2-5:M | 10.7.17 | M (if MGT2-5) | Yes | 写保护 |
| MGT2-13 | useSCB的管理写入是否可单独禁用 | MGT2-6:M | 10.7.17 | M (if MGT2-6) | Yes | 写保护 |
| MGT2-14 | alwaysIncludeSCI的管理写入是否可单独禁用 | MGT2-7:M | 10.7.17 | M (if MGT2-7) | Yes | 写保护 |
| MGT2-17 | enableUse的管理写入是否可为每个Cipher Suite单独禁用 | MGT2-15:M | 10.7.26 | M (if MGT2-15) | Yes | 写保护 |
| MGT2-18 | requireConfidentiality的管理写入是否可为每个Cipher Suite单独禁用 | MGT2-16:M | 10.7.26 | M (if MGT2-16) | Yes | 写保护 |

---

### 2.11 Management — Control Over Secure Communication (安全通信管理控制)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| MGT3-1 | Receive SCs和SAs是否可由管理创建/控制/选择 | 10.7.11, 10.7.13, 10.7.15 | O | Yes/No | 接收SC管理 |
| MGT3-2 | Transmit SAs是否可由管理创建/控制/选择 | 10.7.22, 10.7.24 | O | Yes/No | 发送SA管理 |
| MGT3-3 | 当前CipherSuite是否可由管理选择 | 10.7.27 | O | Yes/No | 套件选择管理 |
| MGT3-4 | confidentialityOffset是否可由管理设置 | 10.7.27 | O | Yes/No | 偏移管理 |
| MGT3-5 | SAKs是否可由管理创建和控制 | 10.7.28, 10.7.29 | O | Yes/No | SAK管理 |
| MGT3-1d | Receive SCs/SAs的管理创建/控制是否可单独禁用 | MGT3-1:M | 10.7.11 | M (if MGT3-1) | Yes | 创建保护 |
| MGT3-2d | Transmit SAs的管理创建/控制是否可单独禁用 | MGT3-2:M | 10.7.22, 10.7.24 | M (if MGT3-2) | Yes | 创建保护 |
| MGT3-3d | CipherSuite选择的管理是否可单独禁用 | MGT3-3:M | 10.7.27 | M (if MGT3-3) | Yes | 选择保护 |
| MGT3-4d | confidentialityOffset的管理设置是否可单独禁用 | MGT3-4:M | 10.7.27 | M (if MGT3-4) | Yes | 偏移保护 |
| MGT3-5d | SAKs管理创建/控制是否可单独禁用 | MGT3-5:M | 10.7.27 | M (if MGT3-5) | Yes | SAK保护 |

---

### 2.12 Management — Statistics (管理统计)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| MGT4-1 | Controlled Port是否提供ifInOctets统计 | 10.7.6 | M | Yes | 输入字节 |
| MGT4-2 | Controlled Port是否提供ifInUcastPkts/ifInMulticastPkts/ifInBroadcastPkts | 10.7.6 | M | Yes | 输入包数 |
| MGT4-3 | Controlled Port是否提供ifInDiscards统计 | 10.7.6 | M | Yes | 输入丢弃 |
| MGT4-4 | Controlled Port是否提供ifInErrors统计 | 10.7.6 | M | Yes | 输入错误 |
| MGT4-5 | Controlled Port是否提供ifOutOctets统计 | 10.7.6 | M | Yes | 输出字节 |
| MGT4-6 | Controlled Port是否提供ifOutUcastPkts/ifOutMulticastPkts/ifOutBroadcastPkts | 10.7.6 | M | Yes | 输出包数 |
| MGT4-7 | Controlled Port是否提供ifOutErrors统计 | 10.7.6 | M | Yes | 输出错误 |
| MGT4-8 | 是否记录InPktsUntagged统计 | 10.7.9, 10.6, Figure 10-4 | M | Yes | 无Tag帧 |
| MGT4-9 | 是否记录InPktsNoTag统计 | 10.7.9, 10.6, Figure 10-4 | M | Yes | 无MACsec Tag |
| MGT4-10 | 是否记录InPktsBadTag统计 | 10.7.9, 10.6, Figure 10-4 | M | Yes | 错误Tag |
| MGT4-11 | 是否记录InPktsNoSARcv统计 | 10.7.9, 10.6.1 | M | Yes | 无SA接收 |
| MGT4-12 | 是否记录InPktsNoSADiscard统计 | 10.7.9, 10.6.1 | M | Yes | 无SA丢弃 |
| MGT4-13 | 是否记录InPktsOverrun统计 | 10.7.9, 10.6.3 | M | Yes | 溢出计数 |
| MGT4-14 | 是否为每个receive SC记录InPktsUnchecked | 10.7.9, 10.6.5 | M | Yes | 未检查帧 |
| MGT4-15 | 是否为每个receive SC记录InPktsDelayed | 10.7.9, 10.6.5 | M | Yes | 延迟帧 |
| MGT4-16 | 是否为每个receive SC记录InPktsLate | 10.7.9, 10.6.2, 10.6.4 | M | Yes | 过期帧 |
| MGT4-17 | 是否为每个receive SC记录InPktsOK | 10.7.9, 10.6.5 | M | Yes | 有效帧 |
| MGT4-18 | 是否为每个receive SC记录InPktsInvalid | 10.7.9, 10.6.5 | M | Yes | 无效帧 |
| MGT4-19 | 是否为每个receive SC记录InPktsNotValid | 10.7.9, 10.6.5 | M | Yes | 未验证帧 |
| MGT4-22 | 是否记录InOctetsValidated统计 | 10.7.10 | M | Yes | 验证字节 |
| MGT4-23 | 是否记录InOctetsDecrypted统计 | 10.7.10 | M | Yes | 解密字节 |
| MGT4-24 | 是否记录OutPktsUntagged统计 | 10.7.18, 10.5 | M | Yes | 未保护发送 |
| MGT4-25 | 是否记录OutPktsTooLong统计 | 10.7.18, 10.5.5, Figure 10-3 | M | Yes | 过长丢弃 |
| MGT4-26 | 是否为每个transmit SC记录OutPktsProtected | 10.7.18, 10.5.4 | M | Yes | 保护帧数 |
| MGT4-27 | 是否为每个transmit SC记录OutPktsEncrypted | 10.7.18, 10.5.4 | M | Yes | 加密帧数 |
| MGT4-28 | 是否记录OutOctetsProtected统计 | 10.7.19 | M | Yes | 保护字节 |
| MGT4-29 | 是否记录OutOctetsEncrypted统计 | 10.7.19 | M | Yes | 加密字节 |

---

### 2.13 Additional Fully Conformant Cipher Suite Capabilities (A.13)

对每个除Default Cipher Suite外实现的Clause 14 Cipher Suite，需完成下表：

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| CSA-1 | Cipher Suite名称 | — | M | 文本 | 套件标识 |
| CSA-2 | Cipher Suite实现是否提供无机密性的完整性保护 | 14.2(a) | O | Yes/No | 仅完整性 |
| CSA-3 | Cipher Suite实现是否对所有User Data octets提供机密性保护 | 14.2(d), 14.3(c) | ¬CSV-19:O / CSV-19:M | Yes/No | 完全机密性 |
| CSA-4 | Cipher Suite实现是否提供User Data的offset机密性保护 | 14.2(e), 14.3(c) | O | Yes/No | 偏移机密性 |
| CSA-5 | Cipher Suite实现支持的最大receive SCs数量 | 5.3(m) | M | 数值 | 容量声明 |
| CSA-6 | Cipher Suite实现支持的最大receive SAKs数量 | 5.3(m) | M | 数值 | 容量声明 |
| CSA-7 | Cipher Suite实现支持的最大transmit SCs数量 | 5.3(m) | M | 数值 | 容量声明 |

---

### 2.14 Additional Variant Cipher Suite Capabilities (A.14)

对每个非Clause 14规定但符合14.2/14.3/14.4.1标准的Cipher Suite，需完成下表：

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|----------|---------|----------|------|--------|------|
| CSV-1 | Cipher Suite名称或常用标识 | — | M | 文本 | 套件标识 |
| CSV-2 | Cipher Suite规范标识及获取信息 | 14.3 | M | 文本 | 规范来源 |
| CSV-3 | 规范是否包含按14.1参数指定的可互操作保护和验证过程 | 14.3, 14.1 | M | Yes | 互操作性 |
| CSV-4 | 规范是否声明：是否提供机密性、User Data与Secure Data最大长度差、ICV长度、密钥长度和属性 | 14.3(a)-(d) | M | Yes | 参数声明 |
| CSV-5 | Cipher Suite算法有效密钥长度是否>=128位，块密码块宽是否>=128位 | 14.4.1(a) | M | Yes | 密钥强度 |
| CSV-6 | 若由独立算法实现，认证和机密性机制属性是否按公认安全结果可组合 | 14.4.1(b) | M | Yes | 算法组合 |
| CSV-7a | 底层密码是否由国家/国际标准机构或政府机构批准 | 14.4.1(c)(1) | O.1 | Yes/No | 标准批准 |
| CSV-7b | 额外Cipher Suite是否符合14.4.1(c)(2)条件 | 14.4.1(c)(2) | O.1 | Yes/No | 替代条件 |
| CSV-8 | Cipher Suite是否满足14.4.1的消息认证要求 | CSV-7b:M, 14.4.1(c)(2)(i) | M (if CSV-7b) | Yes | 消息认证 |
| CSV-9 | Cipher Suite是否满足14.4.1的机密性要求 | CSV-7b:M, 14.4.1(c)(2)(ii) | M (if CSV-7b) | Yes | 机密性 |
| CSV-10 | Cipher Suite是否以与安全性证明一致的方式使用机密性和认证机制 | CSV-7b:M, 14.4.1(c)(2)(iii)(iv) | M (if CSV-7b) | Yes | 一致使用 |
| CSV-11 | Cipher Suite是否对SCI/PN/Source Address/Destination Address/SecTAG/User Data提供完整性保护 | 14.2(a) | M | Yes | 完整性范围 |
| CSV-12 | Cipher Suite是否使用单一SAK为至少2^32-1次调用提供保护 | 14.2(b) | M | Yes | 保护能力 |
| CSV-13 | 给定特定User Data octets数，Cipher Suite是否生成可预测的Secure Data和ICV octets数 | 14.2(c) | M | Yes | 确定性输出 |
| CSV-14 | Secure Data加ICV octets数是否不超过User Data加896 octets | 14.2(f) | M | Yes | 扩展限制 |
| CSV-15 | Cipher Suite是否不修改或限制SCI/PN/地址/SecTAG字段值 | 14.2(g) | M | Yes | 字段不变性 |
| CSV-16 | Cipher Suite是否需要超过1024位的SAK | 14.2(h) | M | Yes | 密钥长度限制 |
| CSV-17 | Cipher Suite是否需要不同的protect和validate密钥 | 14.2(i) | M | Yes | 密钥一致性 |
| CSV-18 | Cipher Suite是否提供完整性保护而不提供机密性，Secure Data与User Data相同，ICV 16 octets | — | M | Yes | 默认套件兼容 |
| CSV-19 | 变体Cipher Suite是否提供无confidentiality offset的机密性保护 | — | O | Yes/No | 完全机密性 |

---

