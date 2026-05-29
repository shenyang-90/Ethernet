# PICS — IEEE Std 1722-2016 — Audio Video Transport Protocol (AVTP)

> **Protocol Implementation Conformance Statement (PICS)**
> **标准**: IEEE Std 1722-2016 — Audio Video Transport Protocol (AVTP)
> **PICS来源**: 自创 (Clause 4~9 条款提取 + 车载场景扩展)
> **应用场景**: 车载MCU区域控制器（Zonal Controller）含AVTP Talker/Listener/Switch功能
> **生成日期**: 2026-05-29
> **关联**: IEEE 1722.1-2013 (AVDECC 控制协议), IEEE 802.1BA-2021 (AVB 系统配置)

---

## 1. 范围与说明

### 1.1 协议范围

IEEE 1722 定义了 Layer 2 时间敏感流传输协议，用于在以太网上承载同步的音频、视频、控制数据（CAN/LIN 封装）和时钟信息。在车载场景下，AVTP 主要用于：
- **ADAS 传感器数据流**: 摄像头/雷达原始数据通过 AVTP 流汇聚
- **信息娱乐**: 多通道音频流传输
- **控制数据隧道**: ACF (AVTP Control Format) 封装 CAN/LIN 帧
- **TSN 协同**: AVTP 流映射到 802.1Q TSN 调度队列

### 1.2 PICS 状态符号

| 符号 | 含义 |
|------|------|
| **M** | Mandatory（必选） |
| **O** | Optional（可选） |
| **O.n** | 可选但至少支持 n 个同组选项 |
| **C** | Conditional（条件性，前置条件满足时为 M） |
| **X** | Prohibited（禁止） |
| **N/A** | Not Applicable（不适用） |

---

## 2. Major Capabilities（主要能力）

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| **TK** | Talker 端系统 (AVTP 流发送) | 4.3.1, 4.4.2, 5.2 | O.1 | **Yes** | 车载 ECU 作为 AVTP Talker |
| **LS** | Listener 端系统 (AVTP 流接收) | 4.3.1, 4.4.2, 5.2 | O.1 | **Yes** | 车载 ECU 作为 AVTP Listener |
| **SW** | Switch AVTP 感知 (流识别与转发) | 4.3.3, 8.2 | O.1 | **Yes** | **Zonal Controller 必须支持** |
| **SID** | Stream ID / Destination Address 映射 | 4.4.3, 5.3, 7.1 | TK+LS+SW: M | **Yes** | Stream 识别与路由基础 |
| **TS** | 时间戳生成与解析 | 5.5, 6.2, 7.2 | TK+LS: M | **Yes** | gPTP 同步时间戳 |
| **PM** | TSN 优先级映射 (AVTP → QoS 队列) | 4.4.3, 8.2, 802.1Q | SW:M | **Yes** | AVTP 流到 TSN 队列映射 |
| **ACF** | AVTP Control Format (CAN/LIN 封装) | Clause 9 | O | **Yes** | 车载控制数据隧道 |
| **ACM** | ACF CAN Multiple (多 CAN 帧聚合) | 9.3.2 | ACF: O | **Yes** | 多帧聚合传输 |
| **ACB** | ACF CAN Brief (精简 CAN 封装) | 9.3.3 | ACF: O | **Yes** | 低开销 CAN 封装 |
| **ACL** | ACF LIN 封装 | 9.4 | ACF: O | **No** | 车载 LIN 场景较少 |
| **CTL** | IEEE 1722.1 AVDECC 控制协议 | 1722.1 | O | **No** | 软件层实现，非硬件 |
| **SRF** | Stream Reservation 失败处理 | 4.4.3, 8.2 | SW: M | **Yes** | 未预留流丢弃/转发 |

---

## 3. Talker 功能详细 PICS

### 3.1 AVTP 帧生成 (Talker)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| TK-1 | 支持 AVTPDU 格式 (Common Header + Stream ID) | 5.2, Table 5-1 | TK: M | Yes | AVTP 公共头 12-byte |
| TK-2 | Common Header 中 sv (stream_valid) 位正确设置 | 5.2.2, Table 5-2 | TK: M | Yes | 1=流有效，0=流暂停/终止 |
| TK-3 | Common Header 中 version=0 | 5.2.2 | TK: M | Yes | 固定版本 0 |
| TK-4 | Common Header 中 mr (media_reset) 位支持 | 5.2.2 | TK: M | Yes | 媒体时钟重置标记 |
| TK-5 | Common Header 中 gv (gateway_valid) 位支持 | 5.2.2 | TK: O | Yes | 网关有效标记 (ACF) |
| TK-6 | Common Header 中 tv (timestamp_valid) 位支持 | 5.2.2 | TK: M | Yes | 时间戳有效标记 |
| TK-7 | Common Header 中 sequence_num 递增 | 5.2.2 | TK: M | Yes | 8-bit 序列号 wrap-around |
| TK-8 | Stream ID (64-bit) 正确填充 | 5.3, 7.1 | TK: M | Yes | 高 48-bit = Talker Entity ID |
| TK-9 | AVTP 时间戳 (AVTP_timestamp) 使用 gPTP 时间基准 | 5.5, 6.2.2 | TK: M | Yes | **gPTP 同步时间戳** |
| TK-10 | 支持 CRF (Clock Reference Format) Talker | 6.3 | TK: O | Yes | 媒体时钟参考分发 |
| TK-11 | 支持 AAF (AVTP Audio Format) Talker | 6.4 | TK: O | No | 信息娱乐场景，硬件不直接支持 |
| TK-12 | 支持 CVF (AVTP Compressed Video Format) Talker | 6.5 | TK: O | No | 视频压缩流，软件处理 |
| TK-13 | 支持 RVF (AVTP Raw Video Format) Talker | 6.6 | TK: O | Yes | **ADAS 原始视频数据** |
| TK-14 | 支持 RAF (AVTP Raw Audio Format) Talker | 6.7 | TK: O | No | 原始音频流 |
| TK-15 | 支持 IIDC (AVTP IIDC Format) Talker | 6.8 | TK: O | No | 工业相机，不适用 |
| TK-16 | 支持 VSF (Vendor Specific Format) Talker | 6.9 | TK: O | No | 厂商特定格式 |

### 3.2 AVTP 时间戳格式 (Talker)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| TS-TK-1 | AVTP_timestamp 使用 IEEE 1722 定义的 32-bit 秒 + 32-bit 纳秒格式 | 5.5.2 | TK: M | Yes | 与 gPTP 时间格式一致 |
| TS-TK-2 | AVTP_timestamp 使用 gPTP (IEEE 802.1AS) 提供的 Grandmaster 时间 | 5.5.2, 802.1AS 9.2 | TK: M | Yes | 依赖 gPTP 同步 |
| TS-TK-3 | 时间戳采样点在媒体数据出口处 (presentation time) | 5.5.2 | TK: M | Yes | 非捕获时间，是呈现时间 |
| TS-TK-4 | 支持 CRF 媒体时钟同步 (media_clock_recovery) | 6.3.2 | TK: O | Yes | 从设备时钟恢复 |
| TS-TK-5 | 时间戳精度 ≤ 1μs (相对 gPTP 时间) | 802.1BA | TK: M | Yes | **车载精度要求** |
| TS-TK-6 | 支持 PTP 时间域选择 (domainNumber) | 5.5.2, 802.1AS 8.1 | TK: O | Yes | PHC_COUNT=2 支持多域 |

---

## 4. Listener 功能详细 PICS

### 4.1 AVTP 帧解析 (Listener)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| LS-1 | 正确解析 AVTPDU Common Header | 5.2, Table 5-1 | LS: M | Yes | 12-byte 公共头解析 |
| LS-2 | 根据 Stream ID 匹配注册的数据流 | 5.3, 7.1 | LS: M | Yes | 64-bit Stream ID 匹配 |
| LS-3 | 验证 sequence_num 连续性 (丢帧检测) | 5.2.2, 5.4.2 | LS: M | Yes | 序列号 gap 检测 |
| LS-4 | 处理 tv=0 (timestamp_invalid) 的帧 | 5.2.2 | LS: M | Yes | 无时间戳帧的接收处理 |
| LS-5 | 处理 sv=0 (stream_invalid) 的帧 | 5.2.2 | LS: M | Yes | 流终止/暂停处理 |
| LS-6 | 支持多种 subtype 格式解析 | 5.2.2, Clause 6 | LS: M | Yes | 根据 subtype 分发处理 |
| LS-7 | 支持 CRF Listener (接收媒体时钟参考) | 6.3 | LS: O | Yes | 媒体时钟恢复输入 |
| LS-8 | 支持 RVF Listener (原始视频接收) | 6.6 | LS: O | Yes | **ADAS 视频汇聚** |

### 4.2 时间戳解析与媒体时钟恢复 (Listener)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| TS-LS-1 | 从 AVTP_timestamp 提取呈现时间 | 5.5.2, 5.4.2 | LS: M | Yes | 32-bit sec + 32-bit nsec |
| TS-LS-2 | 比较呈现时间与 gPTP 当前时间，计算播放延迟 | 5.4.2, 802.1BA | LS: M | Yes | 缓冲与同步 |
| TS-LS-3 | 支持 media_clock_recovery 通过 CRF | 6.3.2 | LS: O | Yes | 从 CRF 恢复采样时钟 |
| TS-LS-4 | 检测时间戳过期 (presentation_time < current_time - threshold) | 5.4.2 | LS: M | Yes | 过期帧丢弃 |
| TS-LS-5 | 检测时间戳超前 (presentation_time > current_time + max_latency) | 5.4.2 | LS: M | Yes | 超前帧缓冲或丢弃 |

---

## 5. Stream ID / Destination Address 映射

### 5.1 Stream 识别与映射 (Switch AVTP Awareness)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------|
| SID-1 | 根据 AVTPDU 中 Stream ID (64-bit) 识别数据流 | 5.3, 7.1 | SW: M | Yes | 高 48-bit Entity ID + 低 16-bit Unique ID |
| SID-2 | Stream ID 到目的 MAC 地址 (DA) 的映射表配置 | 4.4.3, 7.1 | SW: M | Yes | 静态/动态映射表 |
| SID-3 | 支持至少 32 条 Stream ID → DA 映射条目 | 7.1 | SW: O | Yes | 车载场景流数量 |
| SID-4 | 支持 Stream ID 到 VLAN ID 的联合映射 | 4.4.3, 802.1Q | SW: O | Yes | AVTP 流与 VLAN 隔离 |
| SID-5 | Stream ID 映射表支持硬件查表 (TCAM/SRAM) | 7.1 | SW: O | Yes | 线速查表 |
| SID-6 | 未匹配 Stream ID 的帧按默认规则处理 | 4.4.3, 8.2 | SW: M | Yes | 丢弃或泛洪 |
| SID-7 | 支持 Stream ID 匹配失败统计计数器 | 7.1, 8.2 | SW: O | Yes | 诊断支持 |
| SID-8 | 支持 AVTP EtherType=0x22F0 识别 | 4.2 | SW: M | Yes | AVTP 帧类型识别 |

### 5.2 IEEE 1722.1 AVDECC 控制协议映射

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| SID-CTL-1 | 支持 AVDECC Talker/Listener 发现协议 (ADP) | 1722.1 Clause 5 | CTL: O | No | 软件实现 |
| SID-CTL-2 | 支持 AVDECC 连接管理 (ACMP) | 1722.1 Clause 8 | CTL: O | No | 软件实现 |
| SID-CTL-3 | 支持 AVDECC 流预留 (MSRP 交互) | 1722.1, 802.1Q SRP | CTL: O | No | 软件实现，802.1Q SRP=No |
| SID-CTL-4 | Entity ID 与 MAC 地址映射 (EUI-48) | 1722.1 5.2 | CTL: M | N/A | 硬件使用 MAC 直接映射 |

---

## 6. 时间戳格式: IEEE 1722 vs gPTP

### 6.1 时间基准一致性

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| TS-FMT-1 | AVTP_timestamp 使用与 gPTP 相同的 PTP 时间刻度 (TAI-37s) | 5.5.2, 802.1AS 8.2.2 | TK+LS: M | Yes | 时间基准一致 |
| TS-FMT-2 | AVTP_timestamp 秒字段使用 32-bit unsigned (PTP epoch 起始) | 5.5.2 | TK+LS: M | Yes | 1970-01-01T00:00:00Z 起 |
| TS-FMT-3 | AVTP_timestamp 纳秒字段使用 32-bit unsigned (0~999,999,999) | 5.5.2 | TK+LS: M | Yes | 有效范围检查 |
| TS-FMT-4 | gPTP 同步精度 (±10ns) 满足 AVTP 时间戳精度要求 | 802.1AS B.1, 802.1BA | TK+LS: M | Yes | 精度继承 |
| TS-FMT-5 | 支持 PTP 域跨域时间转换 (domainNumber 映射) | 802.1AS 8.1 | TK+LS: O | Yes | 多 PHC 场景 |
| TS-FMT-6 | AVTP 时间戳与 PTP 时间戳格式双向转换 | 5.5.2, 1588 6.4.3 | TK+LS: M | Yes | 48-bit sec + 32-bit ns ↔ 32-bit sec + 32-bit ns |
| TS-FMT-7 | 支持 CRF 时间戳格式 (32-bit sec + 32-bit ns + 32-bit pull) | 6.3.2.2 | TK+LS: O | Yes | 媒体时钟参考 |

### 6.2 车载场景时间戳映射表

| 时间戳类型 | 格式 | 来源 | 用途 | 支持状态 |
|-----------|------|------|------|:--------:|
| **AVTP_timestamp** | 32-bit sec + 32-bit ns | gPTP Grandmaster | 呈现时间标记 | **Yes** |
| **gPTP Sync** | 48-bit sec + 32-bit ns | 802.1AS Sync 消息 | 网络时间同步 | **Yes** |
| **CRF_timestamp** | 32-bit sec + 32-bit ns + 32-bit pull | CRF Talker | 媒体时钟恢复 | **Yes** |
| **PTP Local Clock** | 64-bit (48+32) | Local PHC | 本地时间基准 | **Yes** |
| **DMA Timestamp** | 32-bit ns (截断) | MTL 入口/出口 | 传输延迟测量 | **Yes** |

---

## 7. TSN 优先级映射 (AVTP 流 → QoS 队列)

### 7.1 AVB/TSN 优先级映射 (IEEE 802.1BA 推荐)

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| PM-1 | 支持 AVTP 流映射到 SR Class A (优先级 3) | 802.1BA 6.3, 802.1Q Table 34-1 | SW: M | Yes | 最高优先级 AVTP 流 |
| PM-2 | 支持 AVTP 流映射到 SR Class B (优先级 2) | 802.1BA 6.3, 802.1Q Table 34-1 | SW: M | Yes | 标准优先级 AVTP 流 |
| PM-3 | 支持 AVTP 控制流 (ACF/AVDECC) 映射到 Best Effort 队列 | 802.1BA 6.3 | SW: M | Yes | 控制流不占用 SR 带宽 |
| PM-4 | AVTP 流到 traffic class 映射可配置 | 802.1Q 5.4.1.5, 34.5 | SW: M | Yes | 寄存器/表格配置 |
| PM-5 | 支持 AVTP 流与 CBS (Credit-Based Shaper) 联合使用 | 802.1Qav, 802.1BA | SW: M | Yes | SR Class A/B 信用整形 |
| PM-6 | 支持 AVTP 流与 TAS (Time-Aware Shaper) 门控协同 | 802.1Qbv, 802.1BA | SW: O | Yes | **Switch 级 TAS 门控** |
| PM-7 | AVTP 流通过 TSN 门控时保证最大传输延迟 (maxTransitTime) | 802.1BA 6.3, 802.1Qbv | SW: M | Yes | 确定性延迟保证 |
| PM-8 | 支持 AVTP 流带宽预留静态配置 (替代 SRP) | 802.1BA, 802.1Q SRP | SW: M | Yes | **静态 SMD/SMC 配置** |
| PM-9 | 支持 AVTP 流与 FRER (帧复制消除) 联合使用 | 802.1CB, 802.1BA | SW: O | Yes | 冗余 AVTP 流 |
| PM-10 | AVTP 流映射表支持 Stream ID → {Priority, VLAN, DestPort} 多字段 | 4.4.3, 802.1Q | SW: M | Yes | 完整转发信息 |
| PM-11 | 支持 Class Measurement Interval (SR class A: 125μs, B: 250μs) | 802.1Q 34.3, 802.1BA | SW: M | Yes | SR 类测量间隔 |
| PM-12 | AVTP 突发流在 CBS 信用约束下整形输出 | 802.1Qav 34.6, 802.1BA | SW: M | Yes | 突发平滑 |

### 7.2 车载场景优先级映射表

| AVTP 流类型 | 推荐 SR Class | 优先级 (PCP) | Traffic Class | TSN 整形器 | 说明 |
|------------|:-------------:|:-----------:|:-------------:|:----------:|------|
| **ADAS 原始视频 (RVF)** | SR Class A | 3 | TC 0 (最高) | CBS + TAS | 低延迟关键流 |
| **ADAS 雷达/激光雷达** | SR Class A | 3 | TC 0 | CBS + TAS | 同步传感器数据 |
| **信息娱乐音频** | SR Class B | 2 | TC 1 | CBS | 带宽容错较高 |
| **ACF CAN 控制数据** | Best Effort | 0 | TC 3 | 无 | 非时间敏感 |
| **AVDECC 控制协议** | Best Effort | 0 | TC 3 | 无 | 软件层管理 |
| **CRF 媒体时钟** | SR Class A | 3 | TC 0 | CBS + TAS | 时钟同步关键 |

### 7.3 TSN 门控协同参数

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| PM-TAS-1 | TAS Gate Control List (GCL) 包含 AVTP 流门控窗口 | 802.1Qbv 8.6.9 | PM-TAS: M | Yes | AVTP 专用门控时段 |
| PM-TAS-2 | AVTP 流门控窗口与 gPTP 时钟同步 | 802.1Qbv 5.4.1, 802.1AS | PM-TAS: M | Yes | 全局时间基准 |
| PM-TAS-3 | 支持 AVTP 流门控周期与 CBS credit 刷新周期对齐 | 802.1Qbv + 802.1Qav | PM-TAS: M | Yes | 周期一致性 |
| PM-TAS-4 | AVTP 门控窗口内支持 Express 帧抢占 (Frame Preemption) | 802.1Qbu, 802.3br | PM-TAS: O | Yes | 紧急控制帧插入 |
| PM-TAS-5 | 门控窗口边界处 AVTP 帧截断保护 | 802.1Qbv 8.6.9 | PM-TAS: M | Yes | 帧完整性保护 |
| PM-TAS-6 | 未在门控窗口内到达的 AVTP 帧按溢出策略处理 | 802.1Qbv, 802.1BA | PM-TAS: M | Yes | 丢弃或延迟队列 |

---

## 8. AVTP Control Format (ACF) — 车载控制数据隧道

### 8.1 ACF 通用封装

| 项目编号 | 功能名称 | 引用条款 | 状态 | 支持值 | 备注 |
|:--------:|---------|:-------:|:----:|:------:|------ |
| ACF-1 | 支持 ACF 公共头解析 (acft + acfhdrlen) | 9.2 | ACF: M | Yes | ACF 类型与长度 |
| ACF-2 | 支持 ACF CAN 封装 (acft=0x01) | 9.3 | ACF: M | Yes | **车载 CAN 隧道** |
| ACF-3 | 支持 ACF CAN Multiple (acft=0x02) 多帧聚合 | 9.3.2 | ACM: O | Yes | 多 CAN ID 聚合 |
| ACF-4 | 支持 ACF CAN Brief (acft=0x03) 精简封装 | 9.3.3 | ACB: O | Yes | 低开销 CAN 封装 |
| ACF-5 | 支持 ACF LIN (acft=0x04) 封装 | 9.4 | ACL: O | No | 车载 LIN 场景少 |
| ACF-6 | CAN payload 字段正确映射到 AVTPDU | 9.3.1, Table 9-1 | ACF: M | Yes | CAN ID + DLC + Data |
| ACF-7 | ACF CAN 帧时间戳使用 gPTP 时间 | 9.3.1.3 | ACF: M | Yes | 与 AVTP 时间戳一致 |
| ACF-8 | 支持 ACF CAN 到内部 CAN 控制器的桥接 | 9.3, 车载扩展 | ACF: M | Yes | **Zonal Controller 核心功能** |
| ACF-9 | ACF 消息网关有效位 (gv) 正确设置 | 5.2.2, 9.2 | ACF: M | Yes | 网关帧标记 |

---

## 9. 本 IP AVTP 实现决策汇总

### 9.1 支持功能

| 功能 | 支持值 | 实现方式 | 备注 |
|------|:------:|---------|------|
| AVTP Talker (RVF/CRF) | **Yes** | 硬件 MTL 描述符扩展 | ADAS 视频/时钟发送 |
| AVTP Listener (RVF/CRF) | **Yes** | 硬件 MTL 流匹配 + DMA 路由 | ADAS 视频/时钟接收 |
| Switch AVTP 感知 | **Yes** | 硬件 Stream ID → DA/优先级 查表 | 线速转发 |
| Stream ID 映射 | **Yes** | SRAM 表 (32+ 条目) | 可配置 |
| ACF CAN/CAN-Multiple/CAN-Brief | **Yes** | 硬件 ACF 解析 + CAN 桥接 | 控制数据隧道 |
| TSN 优先级映射 (SR Class A/B) | **Yes** | 硬件 traffic class 映射 + CBS | 与 802.1Q 协同 |
| TAS 门控协同 | **Yes** | Switch 级 TAS GCL 包含 AVTP 窗口 | 与 802.1Qbv 协同 |
| FRER 冗余 AVTP 流 | **Yes** | 与 802.1CB 序列号协同 | 冗余传感器数据 |
| gPTP 时间戳 | **Yes** | PHC 直接采样 | 精度 ≤ 1μs |

### 9.2 不支持功能

| 功能 | 支持值 | 不实现理由 |
|------|:------:|---------|
| AAF (Audio Format) | No | 硬件不直接处理音频，软件后处理 |
| CVF (Compressed Video) | No | 压缩视频由软件编解码器处理 |
| IIDC / VSF | No | 车载场景不使用 |
| ACF LIN | No | LIN 场景较少，CAN 已覆盖 |
| IEEE 1722.1 AVDECC 完整栈 | No | 软件层实现 (控制面) |
| SRP 动态预留 | No | 静态配置替代 (与 802.1Q SRP=No 一致) |
| IP 层 AVTP 传输 | No | 车载 L2 直接传输 |

---

## 10. 与现有 PICS 的交叉引用

| AVTP PICS 项 | 依赖协议 | 依赖 PICS 项 | 说明 |
|-------------|---------|-------------|------|
| TK/LS (Talker/Listener) | 802.1AS-2020 | DOM0, MINTA, BRDG | gPTP 时间基准必须 |
| TS-FMT (时间戳) | 802.1AS-2020 | MDFDPP, MIMSTR | 硬件时间戳依赖 |
| PM (优先级映射) | 802.1Q-2022 | FQTSS, ETS, SCHED | TSN 队列与整形器依赖 |
| PM-TAS (门控协同) | 802.1Q-2022 | SCHED, PRE | TAS + 帧抢占依赖 |
| ACF-CAN (控制隧道) | 802.3-2022 | 100/1000BASE-T1 | 车载以太网 PHY 依赖 |
| SID+FRER | 802.1CB-2017 | IS, TE, LE, RS | 冗余 AVTP 流依赖 FRER |
| SID+MACsec | 802.1AE-2018 | GEN, VER | 安全 AVTP 流加密依赖 |

---

*文档完成: 2026-05-29*
*作者: Verification Agent*
*任务: PAD-REWORK-014 / VERIF-MAJ-003*
