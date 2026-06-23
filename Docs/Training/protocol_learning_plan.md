# Ethernet IP 协议学习计划

> **适用对象**: 实体 Yang  
> **项目**: Ethernet IP (IP_20260502_001)  
> **当前阶段**: PAD 完成，EDR/IDR 入口  
> **目标**: 建立每个协议的"可验证理解"，足以评审 RTL 实现和验证策略  
> **总时间预估**: 6-8 周（每天 1-2 小时）

---

## 学习原则

1. **不要读完整标准** — 每个标准 500-1000 页，读不完。只读与你实现相关的章节。
2. **带着问题读** — 每读完一章，必须能回答 "如果我实现这个，RTL 状态机怎么画？"
3. **建立溯源卡** — 每个协议建一张 A4 纸/一页 Markdown，记录：我实现了什么 + 标准出处 + 未实现什么 + 歧义点
4. **用代码验证理解** — 学完一个协议，写一段伪代码或 SVA 断言

---

## P0 协议（核心，必须先学）

### 1. IEEE 802.3 Ethernet MAC（基础中的基础）

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.3-2022 |
| **优先级** | P0 — 所有上层协议的基础 |
| **关键章节** | Clause 3 (MAC Frame), Clause 4 (MAC Operation), Clause 22 (MII), Clause 35 (GMII), Clause 36 (RGMII) |
| **学习时长** | 3-4 天 |

#### 学习路径

**Day 1: 建立直觉（不读标准）**
- [ ] Wireshark 抓包 100 个帧，观察：
  - DA/SA 的格式，哪些是多播？哪些是广播？
  - Type/Length 字段的值分布
  - FCS 是否存在（开启/关闭抓包选项对比）
- [ ] 读 Linux kernel `drivers/net/ethernet/` 中一个简单驱动的 RX/TX 路径（如 `fec_main.c` 或 `stmmac`）
- [ ] 记录：帧从 PHY 进入 MAC，经历了哪些步骤？

**Day 2: 精读帧格式 + 状态机**
- [ ] IEEE 802.3-2022 **Clause 3.1-3.3**（帧格式，逐字节）
  - 重点：Preamble/SFD/DA/SA/Type/Length/Payload/Pad/FCS 的精确字节偏移
  - 重点：最小帧 64B（不含 Preamble），最大 1518B/1522B（含 VLAN）
  - 重点：I/G 位和 U/L 位在 DA 中的位置（Bit 0 和 Bit 1 of first byte）
- [ ] **Clause 4.2**（MAC 操作 — 传输和接收状态机）
  - 画 TX 状态机：IDLE → PREAMBLE → SFD → DATA → PAD → FCS → IFG
  - 画 RX 状态机：IDLE → PREAMBLE → SFD → DATA → FCS → IFG
- [ ] 对比你的 `protocol_analysis.md` §2.1，看是否有遗漏

**Day 3: PHY 接口时序**
- [ ] **Clause 22 (MII)**：TX_EN, TX_ER, RX_DV, RX_ER, CRS, COL 的时序关系
  - 重点：CRS 和 COL 在半双工模式下的行为
  - 重点：TX_ER 什么时候拉高？
- [ ] **Clause 35 (GMII)**：与 MII 的区别（8-bit data, 125MHz）
- [ ] **RGMII**：查文档（非 802.3 标准，是工业标准），关注 DDR 时序和 clock skew

**Day 4: 边界条件 + 错误处理**
- [ ] 列出所有错误场景：
  - Runt frame (< 64B) → 怎么处理？
  - Giant frame (> 1518B 或 jumbo) → 截断还是报错？
  - FCS error → 丢弃还是上送？
  - RX_ER 在帧中间拉高 → 帧无效
  - Late collision → 什么情况下会发生？
- [ ] 对照你的 `ethernet_arch_spec.md` §4.1.4（AXI 接口定义），确认错误如何报告到软件

#### 溯源卡模板（以 802.3 为例）

```markdown
## IEEE 802.3 MAC — 我的实现范围

### 已实现
- [x] 全双工 MAC (§4.2.1)
- [x] MII/GMII/RGMII 接口 (§22, §35)
- [x] VLAN tag 识别 (802.1Q, not 802.3)
- [x] Jumbo frame 支持 (configurable, 9018B)

### 未实现（显式决策）
- [ ] 半双工 + CSMA/CD (§4.2.2) → 仅 10BASE-T1S 用 PLCA，非 CSMA/CD
- [ ] Flow Control (802.3x) → 用 802.1Qav CBS 替代
- [ ] MAC Control frame (§31) → 不支持

### 歧义点
- RGMII clock skew 要求 1.5-2.0ns，我的 PHY 是否支持？→ 查 PHY datasheet
- FCS 检查失败时，是否更新统计计数器？→ Arch Spec 未明确
```

---

### 2. IEEE 802.1Q — VLAN & Priority

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1Q-2022 |
| **优先级** | P0 — Switch 和 QoS 的基础 |
| **关键章节** | Clause 5 (VLAN Tag), Clause 6 (Bridge Operation), Clause 8 (FDB), Clause 12 (Priority) |
| **学习时长** | 3-4 天 |

#### 学习路径

**Day 1: VLAN Tag 格式**
- [ ] **Clause 5.1** (Tag header format)：TPID (0x8100) + TCI (PCP[3] + CFI[1] + VID[12])
  - 重点：Priority Code Point (PCP) 3-bit，8 个优先级
  - 重点：VID 0x000 = null VLAN, 0xFFF = reserved
- [ ] **Double Tag (Q-in-Q)**：TPID 0x88A8 (outer), 0x8100 (inner) — 你的实现支持吗？

**Day 2: Filtering Database (FDB)**
- [ ] **Clause 8.1-8.5**（MAC 地址学习、老化、查询）
  - 重点：学习条件（源 MAC + VID + 入端口）
  - 重点：老化时间（默认 300s，可配）
  - 重点：静态条目 vs 动态条目
  - 重点：Hash 冲突处理（你的 FDB 微架构用 8-way hash？）
- [ ] 对照你的 `switch_fdb_microarch.md`，确认：
  - 8K 条目如何映射到 hash bucket？
  - 冲突链/多路相联如何工作？
  - 学习速率 vs 查询速率的性能要求

**Day 3: Forwarding 逻辑**
- [ ] **Clause 6.1-6.4**（帧转发决策）
  - 已知单播 → 查 FDB，单端口转发
  - 未知单播 → 泛洪（flooding）到同 VLAN 的所有端口（除入端口）
  - 多播 → 查 GMRP/IGMP snooping 或泛洪
  - 广播 → 泛洪
- [ ] **Clause 6.5**（生成树 — STP/RSTP）— 你支持吗？如果不支持，怎么防止环路？

**Day 4: Priority & Egress Queueing**
- [ ] **Clause 12.1-12.5**（优先级映射）
  - PCP → 内部流量类 (Traffic Class) 的映射表
  - 重点：你的 Switch 支持几个队列？（通常 8 个）
  - 重点：严格优先级 (SP) vs WRR vs CBS

---

### 3. IEEE 802.1AS — gPTP（时间同步，最难的之一）

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1AS-2020 |
| **优先级** | P0 — TSN 的灵魂 |
| **关键章节** | Clause 10 (Sync), Clause 11 (Time), Clause 14 (BMCA) |
| **学习时长** | 5-7 天 |

#### 学习路径

**Day 1-2: 建立直觉（不要读标准）**
- [ ] 读 [gPTP Tutorial - Intel TSN](https://www.intel.com/content/www/us/en/products/network-io/programmable-ethernet-switch/tsn.html) 或搜 "gPTP tutorial PDF"
- [ ] 理解核心概念：
  - Master/Slave 角色
  - Sync/Follow_Up 消息对（为什么分两个消息？）
  - Pdelay_Req/Pdelay_Resp/Pdelay_Resp_Follow_Up（测量链路延迟）
  - 频率补偿（rateRatio）
- [ ] 画一张时序图：从 Master 发送 Sync 到 Slave 调整本地时钟的完整流程

**Day 3: 精读 Sync 机制**
- [ ] **Clause 10.2**（Sync 消息发送和接收）
  - syncInterval：默认 125ms（802.1AS 要求），可配
  - 重点：时间戳在哪里打？（MII/GMII 的介质独立层边界）
  - 重点：Follow_Up 携带 preciseOriginTimestamp + rateRatio
- [ ] **Clause 10.3**（BMCA — Best Master Clock Algorithm）
  - 优先级向量：Priority1 > ClockClass > ClockAccuracy > Priority2 > ClockIdentity
  - 状态机：INITIALIZING → LISTENING → MASTER/SLAVE/UNCALIBRATED
  - 对照你的 Arch Spec §3.3，确认 BMCA 状态机是否完整

**Day 4: 精读 Pdelay 机制 + 时间戳**
- [ ] **Clause 11.1-11.3**（Pdelay 测量）
  - Pdelay = [(t4 - t1) - (t3 - t2)] / 2
  - 画四张图：Pdelay_Req, Pdelay_Resp, 对应时间戳
  - 重点：为什么用 Pdelay 而不是 Delay_Req/Resp？（因为 gPTP 要求对端也支持）
- [ ] **Clause 11.2**（时间戳捕获点）
  - 在 PHY/MAC 边界捕获（接近 wire）
  - 你的实现：时间戳在 MAC 还是 PHY？（通常 MAC 侧，RGMII 在 FPGA 内部）
  - 对照你的 `ethernet_clock_reset_spec.md`：clk_ts = 250MHz，每 4ns 一个 tick

**Day 5: RTL 实现关注点**
- [ ] 你的 Arch Spec 中 PTP 模块的时钟域：
  - MAC 时钟（125MHz/300MHz）→ 时间戳逻辑
  - 系统时钟 → 寄存器访问
  - 怎么跨时钟域传递时间戳？（FIFO？握手？）
- [ ] PTP 时间格式：48-bit seconds + 32-bit nanoseconds（还是 48+16？）
- [ ] 你的 vPHC（虚拟 PTP Hardware Clock）接口：怎么和软件栈交互？

**Day 6-7: 边界条件 + 异常**
- [ ] 如果 Sync 消息丢失 3 个连续周期 → Slave 进入 HOLDOVER
- [ ] 如果 BMCA 计算结果和当前角色不一致 → 状态切换
- [ ] 频率补偿的精度要求：802.1AS 要求多少 ppm？
- [ ] 对照 PICS_802.1AS-2020_gPTP.md，逐条确认实现状态

---

### 4. IEEE 802.1Qbv — Time-Aware Shaper (TAS)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1Qbv-2015 (并入 802.1Q-2022) |
| **优先级** | P0 — 确定性传输的核心 |
| **关键章节** | 802.1Q-2022 Clause 8.6.8, Annex V |
| **学习时长** | 3-4 天 |

#### 学习路径

**Day 1: 核心概念**
- [ ] 理解：为什么需要 TAS？
  - 没有 TAS：高优先级帧可能在低优先级帧传输中间到达，需要等待 → 非确定性
  - 有 TAS：时间门控，特定时间段只开特定队列的门
- [ ] 读 Tutorial：搜 "802.1Qbv tutorial" 或 "Time-Aware Shaper explained"
- [ ] 理解 Gate Control List (GCL)：
  - 一个循环列表，每个 entry 定义：时间偏移 + 每个队列的 gate 状态（Open/Closed）
  - 周期 = 所有 entry 的 time 总和

**Day 2: 标准精读**
- [ ] **Clause 8.6.8.4**（Gate Control List 配置）
  - 重点：每个队列一个 gate，Open = 可以传输，Closed = 不能传输
  - 重点：Admin 状态 vs Oper 状态（配置 vs 运行）
- [ ] **Clause 8.6.8.5**（Cycle Time）
  - Cycle Time 怎么确定？固定？还是由 GCL 推导？
  - 你的实现：支持动态更新 GCL 吗？（运行时换表）

**Day 3: 与 gPTP 的关系**
- [ ] TAS 的 GCL 时间基准是什么？
  - 答案：gPTP 同步后的网络时间（PTP 时间）
  - 所以 TAS 必须在 gPTP 同步完成后才能正确工作
- [ ] 时间对齐问题：
  - GCL 的 cycle start 必须对齐到 PTP 时间边界（如整秒）
  - 你的实现怎么保证？（软件配置？硬件自动对齐？）

**Day 4: RTL 实现**
- [ ] 画 TAS 的硬件框图：
  - 输入：8 个队列的帧就绪信号 + GCL 内存 + PTP 时间
  - 输出：每个队列的 gate open/close 信号
  - 核心：一个比较器，比较当前 PTP 时间和 GCL entry 的时间戳
- [ ] 边界条件：
  - 如果一个帧在 gate close 前开始传输，但结束时 gate 已经 closed → 允许完成（frame is not preempted）
  - 如果 gate open 时间内帧太长传不完 → 下一个 cycle 继续？

---

### 5. IEEE 802.1Qbu — Frame Preemption

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1Qbu-2016 (并入 802.1Q-2022) |
| **优先级** | P0 |
| **关键章节** | 802.1Q-2022 Clause 6.7, Annex N |
| **学习时长** | 2-3 天 |

#### 学习路径

**Day 1: 概念理解**
- [ ] 为什么需要 Frame Preemption？
  - 低优先级帧正在传，高优先级紧急帧来了
  - 没有 preemption：高优先级等低优先级传完 → 延迟 = 最大帧长（~12μs @ 1G）
  - 有 preemption：把低优先级帧打断，传高优先级，然后恢复低优先级
- [ ] 理解 Express MAC (eMAC) 和 Preemptable MAC (pMAC)
  - 你的实现：是双 MAC 还是单 MAC 内部逻辑？

**Day 2: 标准精读**
- [ ] **Clause 6.7**（Frame Preemption 操作）
  - 重点：什么帧可以被打断？（pMAC 的帧，不是 eMAC 的）
  - 重点：mPacket 格式：fragment 或 complete frame
  - 重点：CRC-32 vs mCRC（fragment 用 mCRC = CRC-32 的前 16-bit）
- [ ] **Annex N**（与 802.3br 的交互）
  - 重点：Verify / Respond 机制（两端都支持 preemption 才能启用）

**Day 3: RTL 关注点**
- [ ] Fragmentation 逻辑：
  - 正在传一个 1500B 帧，传了 500B 时被打断
  - 怎么记录断点？（字节计数器？buffer pointer？）
  - 恢复时从断点继续
- [ ] mCRC 计算：CRC-32 的前 16-bit，怎么快速算？

---

### 6. IEEE 802.1Qav — Credit-Based Shaper (CBS)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1Qav-2009 (并入 802.1Q-2022) |
| **优先级** | P0 |
| **关键章节** | 802.1Q-2022 Clause 8.6.8.2 |
| **学习时长** | 2 天 |

#### 学习路径

**Day 1: 概念 + 数学**
- [ ] CBS 的核心：每个 SR 类（Stream Reservation Class，通常是 Class A 和 B）有一个 credit 计数器
- [ ] 三种状态：
  - 递增（idleSlope，当帧在排队但 gate 没开）
  - 递减（sendSlope，当帧正在传输）
  - 冻结（门关闭时）
- [ ] 关键参数：
  - idleSlope：配置值，决定带宽分配（如 20% = 20Mbps @ 100M）
  - sendSlope：- (portTransmitRate - idleSlope)
  - hiCredit / loCredit：边界

**Day 2: RTL 实现**
- [ ] 画状态机：IDLE → ACCUMULATING → TRANSMITTING → IDLE
- [ ] 精度问题：credit 用定点数还是浮点数？（定点，通常是 32-bit 整数，单位是 bit-time 或 byte-time）
- [ ] 与 TAS 的交互：TAS 关闭 gate 时，CBS credit 应该冻结还是继续累积？

---

### 7. IEEE 802.1Qci — Per-Stream Filtering and Policing (PSFP)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1Qci-2017 (并入 802.1Q-2022) |
| **优先级** | P0 |
| **关键章节** | 802.1Q-2022 Clause 8.6.5, Annex T |
| **学习时长** | 3-4 天 |

#### 学习路径

**Day 1: 概念理解**
- [ ] PSFP 解决什么问题？
  - 防止故障节点发送过多流量（traffic policing）
  - 防止未授权的流进入网络（filtering）
- [ ] 三个组件：
  - Stream Filter：根据 Stream ID 匹配
  - Stream Gate：时间门控（类似 TAS 但 per-stream）
  - Flow Meter：令牌桶或 leaky bucket 算法

**Day 2-3: 标准精读**
- [ ] **Clause 8.6.5.1**（Stream Filter）
  - 匹配条件：Stream ID（通常来自 802.1CB 的 R-tag 或 1722 的 stream_id）
  - 动作：允许 / 丢弃 / 重定向
- [ ] **Clause 8.6.5.2**（Stream Gate）
  - 与 TAS 类似，但是 per-stream
  - Gate Control List 控制每个 stream 的传输窗口
- [ ] **Clause 8.6.5.3**（Flow Meter）
  - 令牌桶算法：CIR (Committed Information Rate), CBS (Committed Burst Size), EBS
  - 三色标记：Green / Yellow / Red

**Day 4: RTL 关注点**
- [ ] Stream Filter 表：有多少条目？怎么索引？（通常用 Stream ID 做 hash）
- [ ] 令牌桶实现：
  - 每来一个 token time 加一次 credit？还是每帧来时计算？
  - 精度 vs 面积 trade-off
- [ ] 与 Switch 的集成点：PSFP 在 FDB 查找之前还是之后？（通常在之前，入端口处）

---

### 8. IEEE 802.1CB — Frame Replication and Elimination for Reliability (FRER)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1CB-2017 |
| **优先级** | P0 |
| **关键章节** | Clause 7 (Sequence Generation), Clause 8 (Sequence Recovery), Clause 9 (FRER Encode/Decode) |
| **学习时长** | 3-4 天 |

#### 学习路径

**Day 1: 概念理解**
- [ ] FRER 解决什么问题？
  - 关键控制流量需要高可靠性，走两条独立路径
  - 发送端：复制帧，打上序列号（R-tag），从两个端口发出
  - 接收端：收到两个副本，去重，只留一个
- [ ] 两种模式：
  - Sequence Generation / Recovery（端到端）
  - FRER Encode / Decode（逐跳）

**Day 2: R-tag 格式 + 序列号管理**
- [ ] **Clause 9**（R-tag 格式）
  - TPID = 0xF1C1（R-tag）
  - Sequence Number: 16-bit，范围 0-65535，循环
  - 重点：序列号怎么分配？（每 stream 一个独立计数器）
- [ ] **Clause 7**（Sequence Generation）
  - 什么时候增加序列号？（每复制一个帧时）
  - 序列号溢出处理：0xFFFF → 0x0000

**Day 3: 序列号恢复 / 去重**
- [ ] **Clause 8**（Sequence Recovery）
  - 接收端维护一个"期望序列号"窗口
  - 如果收到的序列号在窗口内且未见过 → 接受
  - 如果序列号 < 窗口下沿 → 重复或乱序，丢弃
  - 如果序列号 > 窗口上沿 → 乱序，接受并移动窗口
- [ ] 窗口大小怎么选？（通常 2-4 个序列号）
- [ ] 边界条件：
  - 两条路径延迟差异很大 → 窗口需要多大？
  - 一条路径完全断开 → 另一条路径的帧怎么处理？

**Day 4: RTL 关注点**
- [ ] 去重表：每个 stream 需要维护多少状态？
- [ ] 与 Switch 的集成：
  - FRER 在 FDB 查找之前还是之后处理 R-tag？
  - 复制逻辑：一个入帧变成两个出帧，怎么管理 buffer？
- [ ] 对照 PICS_802.1CB-2017_FRER.md，确认实现范围

---

### 9. PHY 接口：MII / RGMII / SGMII / USXGMII

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.3 Clause 22, 35, 36 + 工业规范 |
| **优先级** | P0 |
| **学习时长** | 2-3 天 |

#### 学习路径

**Day 1: MII / GMII**
- [ ] **Clause 22 (MII)**：
  - 信号：TX_CLK, TXD[3:0], TX_EN, TX_ER, RX_CLK, RXD[3:0], RX_DV, RX_ER, CRS, COL
  - 时序：TX_EN 在 TX_CLK 上升沿有效，TXD 同时有效
  - 速率：100Mbps → 25MHz, 10Mbps → 2.5MHz
- [ ] **Clause 35 (GMII)**：
  - 数据宽度 8-bit，时钟 125MHz（1000Mbps）
  - 信号与 MII 类似，但 8-bit 数据

**Day 2: RGMII**
- [ ] RGMII 不是 IEEE 标准，是工业规范（RGMII v2.0, HP/Marvell）
- [ ] 核心特点：
  - 4-bit 数据，DDR（双边沿采样）→ 等效 8-bit @ 125MHz
  - TXC / RXC 由 PHY 提供
  - Clock skew：要求 1.5-2.0ns（setup/hold 需求）
  - 你的实现：FPGA 内部怎么调 skew？（IDELAY/ODELAY？PLL phase shift？）
- [ ] 对照你的 `ethernet_clock_reset_spec.md` §3.2

**Day 3: SGMII / USXGMII**
- [ ] SGMII：SerDes 接口，1.25Gbps line rate，8b/10b 编码
  - 与 PCS 的关系：SGMII = MII over SerDes
- [ ] USXGMII：10G 版本，64b/66b 编码
  - 你的实现支持吗？（P1 优先级）
- [ ] 关注：SerDes 的 clock recovery，怎么保证 MAC 侧时钟稳定？

---

### 10. Safety / ECC / FSM Parity

| 项目 | 内容 |
|------|------|
| **标准** | ISO 26262-5, 项目 Safety Concept |
| **优先级** | P0 |
| **学习时长** | 2 天 |

#### 学习路径

**Day 1: ISO 26262-5 硬件安全要求**
- [ ] 读你的 `safety_concept.md`：
  - ASIL-B 基线的安全机制有哪些？
  - ECC 覆盖范围：哪些 memory 需要 ECC？（FDB？描述符 ring？packet buffer？）
  - FSM parity / duplication 的覆盖率要求
- [ ] 对照 ISO 26262-5 Table D.1-D.4：
  - 安全分析中推荐的诊断措施
  - 你的实现覆盖了多少？

**Day 2: RTL 实现**
- [ ] ECC 编码/解码器：
  - Hamming code？SECDED？
  - 数据宽度 32-bit / 64-bit 对应多少校验位？
- [ ] FSM 安全状态：
  - 非法状态检测 → 进入 safe state
  - Safe state 是什么？（复位？停止收发？）
- [ ] 看门狗：
  - TX/RX 超时检测
  - PTP 同步丢失检测

---

## P1 协议（重要，次之）

### 11. IEEE 802.1AE — MACsec

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1AE-2018 |
| **优先级** | P1 |
| **关键章节** | Clause 7 (SecTAG), Clause 8 (Encryption), Clause 9 (Key Agreement) |
| **学习时长** | 4-5 天 |

#### 学习路径

**Day 1: 概念建立**
- [ ] MACsec 解决什么问题？
  - 链路层加密 + 认证，防止中间人攻击
  - 与 IPsec 的区别：MACsec 在 Layer 2，对上层透明
- [ ] SecTAG 格式：
  - TCI (Tag Control Information): ES(1) + SC(1) + SCB(1) + E(1) + C(1)
  - SCI (Secure Channel Identifier): 8 bytes (MAC+Port)
  - PN (Packet Number): 32-bit，每帧递增，防重放

**Day 2: 加密和认证**
- [ ] **Clause 8**：AES-GCM 加密
  - AES-128-GCM（必须）+ AES-256-GCM（可选）
  - IV 生成：SCI + PN
  - 认证标签 (ICV)：128-bit
- [ ] 性能考虑：
  - 线速加密需要多少 AES 核？（1Gbps ≈ 1 个 AES-128 pipeline）
  - 你的实现：纯硬件？还是硬件加速 + 软件密钥管理？

**Day 3: 密钥管理**
- [ ] **Clause 9**：MACsec Key Agreement (MKA)
  - 802.1X EAPOL-Key 消息交换
  - Secure Association Key (SAK) 派生
  - 注意：MKA 通常是软件实现，但硬件需要支持 SAK 的在线更换

**Day 4-5: RTL 关注点**
- [ ] SecTAG 插入/剥离位置：在 MAC 和 PHY 之间
- [ ] 加密流水线：怎么做到线速？（多 stage pipeline，每 cycle 处理 128-bit）
- [ ] 重放检测：PN 窗口机制（接收端维护一个 PN 窗口，小于下沿的丢弃）
- [ ] 对照 PICS_802.1AE-2018_MACsec.md

---

### 12. IEEE 1722 — AVTP (Audio Video Transport Protocol)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 1722-2016 |
| **优先级** | P1 — AVB/TSN 的媒体传输层 |
| **关键章节** | Clause 5 (Common Header), Clause 6 (AVTPDU), Clause 7 (ACF) |
| **学习时长** | 3 天 |

#### 学习路径

**Day 1: AVTP 通用头部**
- [ ] **Clause 5**：
  - cd (control/data): 1-bit，区分控制消息和数据消息
  - subtype: 7-bit，定义负载类型（IEC 61883/AAF/CVF/CRF/...）
  - sv (stream_valid): 1-bit
  - version: 3-bit
  - mr (media_clock_restart): 1-bit
  - tv (timestamp_valid): 1-bit
  - sequence_num: 8-bit
  - timestamp: 32-bit (gPTP 时间，nanoseconds)
  - stream_id: 64-bit (unique stream identifier)

**Day 2: 具体格式**
- [ ] **Clause 6 (AVTPDU)**：
  - IEC 61883/IIDC：摄像机/工业相机常用
  - AAF (AVTP Audio Format)：音频流
  - CVF (AVTP Compressed Video Format)：压缩视频
  - CRF (Clock Reference Format)：时钟参考
- [ ] 你的实现：支持哪些 subtype？（看 protocol_analysis.md 中的 feature union）

**Day 3: 与 802.1Q 的集成**
- [ ] AVTP 帧的 VLAN PCP 应该设多少？（通常是 6 或 5，SR Class A/B）
- [ ] AVTP 帧怎么过 TAS 门控？（GCL 必须为 AVB 流量预留时间槽）
- [ ] 对照 PICS_IEEE_1722_AVTP_PICS.md

---

### 13. IEEE 802.1AB — LLDP

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.1AB-2016 |
| **优先级** | P1 — 链路发现和管理 |
| **关键章节** | Clause 7 (LLDPDU), Clause 8 (Timing), Clause 9 (Management) |
| **学习时长** | 2-3 天 |

#### 学习路径

**Day 1: LLDPDU 格式**
- [ ] **Clause 7**：
  - Chassis ID TLV, Port ID TLV, TTL TLV（必须）
  - 可选 TLV：Port Description, System Name, System Description, Management Address, 802.1 (VLAN), 802.3 (MAC/PHY), 802.1Q (TSN capabilities)
- [ ] 重点：802.1Q TLV 包含 TSN 能力（是否支持 TAS/CBS/PSFP/FRER）

**Day 2: 状态机和时序**
- [ ] **Clause 8**：
  - msgTxInterval：默认 30s
  - msgTxHold：默认 4（TTL = msgTxInterval × msgTxHold = 120s）
  - reinitDelay：默认 2s
- [ ] LLDP 状态机：
  - TX：IDLE → TX_LLDP_INITIALIZE → TX_IDLE → TX_INFO_FRAME → WAIT_FOR_ACK
  - RX：LLDP_WAIT_PORT_OPERATIONAL → LLDP_RX_PROCESS → LLDP_RX_DISCARD

**Day 3: RTL 关注点**
- [ ] LLDP 通常是软件实现的协议，但你的实现里硬件负责什么？
  - 可能是：硬件提供时间戳、帧收发接口、MAC 地址
  - 软件组装 LLDPDU 内容
- [ ] 对照 PICS_802.1AB-2016_LLDP.md

---

### 14. 10BASE-T1S / PLCA (IEEE 802.3cg)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.3cg-2019 |
| **优先级** | P1 — 车载以太网物理层 |
| **关键章节** | Clause 148 (10BASE-T1S), Clause 149 (PLCA) |
| **学习时长** | 2-3 天 |

#### 学习路径

**Day 1: 10BASE-T1S 物理层**
- [ ] 为什么车载用 10BASE-T1S？
  - 低成本、短距离（<25m）、多点总线（max 8 nodes）
  - 单对双绞线，半双工
- [ ] 物理层参数：
  - 速率：10 Mbps
  - 编码：4B/5B + PAM3
  - 时钟：12.5 MHz symbol rate

**Day 2: PLCA (Physical Layer Collision Avoidance)**
- [ ] **Clause 149**：
  - 为什么不用 CSMA/CD？（车载要求确定性，CSMA/CD 非确定）
  - PLCA 机制：
    - 每个 node 有一个唯一的 ID（0-7）
    - 一个 cycle 内，按 ID 顺序给每个 node 发送机会
    - 如果 node 没有数据要发，立即把机会传给下一个
  - 关键信号：PLCA_BEACON（master node 发送，cycle 开始）

**Day 3: RTL 关注点**
- [ ] PLCA 与 MAC 的接口：
  - MAC 告诉 PHY "我有帧要发"
  - PHY 的 PLCA 逻辑决定什么时候真正开始传输
- [ ] 对照你的 `ethernet_clock_reset_spec.md`：PLCA 时钟域 12.5MHz
- [ ] 边界条件：
  - 如果 master 掉线怎么办？（backup master 机制？）
  - 如果某个 node 一直不发，但 cycle 还在等它 → 超时机制

---

### 15. MultiGBASE-T1 (2.5G/5G/10G)

| 项目 | 内容 |
|------|------|
| **标准** | IEEE 802.3ch (2.5G/5G/10G), 802.3cu (10G), 802.3cv (2.5G/5G) |
| **优先级** | P1 |
| **关键章节** | Clause 149-150 (PCS/PMA/PMD) |
| **学习时长** | 2-3 天 |

#### 学习路径

**Day 1: 物理层架构**
- [ ] PCS (Physical Coding Sublayer)：
  - 2.5G/5G/10G 用不同的编码
  - 2.5G：64b/66b (Clause 49)
  - 5G/10G：128b/132b (Clause 151)
- [ ] PMA (Physical Medium Attachment)：
  - SerDes 接口
  - 时钟恢复 (CDR)

**Day 2: 与 MAC 的接口**
- [ ] 10G 以上通常用 XGMII/USXGMII，而不是 GMII
- [ ] 速率自适应：怎么从 10G 降到 2.5G？（Auto-Negotiation？）

**Day 3: RTL 关注点**
- [ ] SerDes 的时钟域：
  - 从 SerDes 恢复出的时钟通常有 jitter，怎么处理？
  - FIFO 跨时钟域（SerDes clock → MAC clock）
- [ ] 你的实现：支持哪些速率？自动协商？

---

## P2 协议（可选/低优先级）

| 协议 | 标准 | 说明 |
|------|------|------|
| IEEE 802.3az (EEE) | 802.3az-2010 | 节能以太网，低功耗时钟管理 |
| IPsec (ESP/AH) | RFC 4301-4303 | 网络层安全，车载中可能用 |
| SecOC | AUTOSAR | PDU 安全认证 |
| D/TLS | RFC 6347 | 传输层安全 |
| IEEE 1722.1 | — | AVTP 控制层，发现/连接管理 |
| IEEE 802.1Qcr (ATS) | — | 异步流量整形，已标记为 No |
| IEEE 802.1Qch (CQF) | — | 循环排队转发，已标记为 No |

**建议**：P2 协议在项目后期或特定需求出现时再学。现在只需知道它们存在、解决什么问题、与已实现协议的关系。

---

## 学习工具和方法

### 1. 标准文档获取
- IEEE 标准：$20-30 下载 PDF（推荐），或通过公司/学校订阅
- 替代：IEEE 802.1 [官方页面](https://1.ieee802.org/) 有免费 summary 和 tutorial
- IETF RFC：完全免费 [rfc-editor.org](https://www.rfc-editor.org/)

### 2. 开源参考实现
```
Linux kernel:
  - drivers/net/ethernet/       # MAC 驱动
  - net/8021q/vlan.c            # VLAN
  - net/ieee802154/             # 不相关，只是对比
  - drivers/ptp/                # PTP 硬件时钟

Open vSwitch:
  - ofproto/                    # OpenFlow + VLAN + QoS

Wireshark:
  - epan/dissectors/            # 协议解析器（看帧格式定义）
```

### 3. 实验环境
- **FPGA 板**：如果有，抓 RGMII/SGMII 信号（ILA）看真实时序
- **仿真**：用 Vivado/Questa 跑一个简单的 MAC TX/RX testbench，观察波形
- **软件**：用 `tcpreplay` + `tcpdump` 生成和捕获测试流量

### 4. 学习检查清单（每周自查）

```markdown
## Week X 学习检查

### 本周学习协议: [名称]

- [ ] 我能画出协议的核心状态机吗？
- [ ] 我能写出帧格式的逐字节定义吗？
- [ ] 我能列出 5 个边界条件/错误场景吗？
- [ ] 我能指出这个协议在我们项目中的实现位置吗？（哪个模块/文件）
- [ ] 我能写出至少一个 SVA 断言来验证协议合规性吗？

### 未解决的疑问:
1.
2.

### 下周计划:
```

---

## 总时间线建议

| 周 | 协议 | 优先级 | 每日投入 |
|----|------|--------|---------|
| 1 | IEEE 802.3 MAC | P0 | 2h |
| 2 | IEEE 802.1Q (VLAN/FDB) | P0 | 2h |
| 3 | IEEE 802.1AS (gPTP) | P0 | 2h |
| 4 | IEEE 802.1Qbv (TAS) + 802.1Qbu (Preemption) | P0 | 2h |
| 5 | IEEE 802.1Qav (CBS) + 802.1Qci (PSFP) | P0 | 2h |
| 6 | IEEE 802.1CB (FRER) | P0 | 2h |
| 7 | PHY 接口 (RGMII/SGMII) + Safety/ECC | P0 | 2h |
| 8 | 802.1AE (MACsec) + 802.1AB (LLDP) | P1 | 2h |
| 9 | IEEE 1722 (AVTP) + 802.3cg (PLCA) | P1 | 2h |
| 10 | MultiGBASE-T1 + 复习/补漏 | P1 | 2h |

---

## 关键提醒

1. **不要追求完美理解** — 协议标准 80% 的内容与你无关。学会快速定位相关章节。
2. **用输出倒逼输入** — 每学完一个协议，更新 `protocol_learning_notes.md`，写一个溯源卡。
3. **和团队对齐** — 把你的溯源卡和 RTL 负责人对齐，确认理解一致。
4. **接受"暂时不知道"** — 有些细节（如 exact CRC 多项式的初始值）可以在 RTL 编码阶段再查。

---

> **"我不需要知道协议的所有细节。我需要知道的是：当 RTL 实现和标准冲突时，我能找到标准原文并做出正确决策。"**
