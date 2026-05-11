# Ethernet IP Micro-Architecture Design Specification

> **项目**: Ethernet IP (IP_20260502_001)
> **模块**: Gigabit Ethernet MAC + PHY Subsystem
> **版本**: v0.5
> **日期**: 2026-05-12
> **作者**: Arch Agent (PAD Orchestrator Auto-Start)
> **评审状态**: Draft — 基于Arch Spec v1.3 / Kimi Agent TC4x研究材料
> **前置文档**: `Docs/Arch/ethernet_arch_spec.md`, `Docs/Arch/ethernet_interface_spec.md`, `Docs/Arch/ethernet_clock_reset_spec.md`

---

## 1. 微架构总览

### 1.1 顶层模块划分

基于Arch Spec v1.3的架构定义和TC4x GETH对标分析，本IP微架构划分为**7个顶层功能模块**和**1个集成Bridge模块**:

```
+========================================================================================+
|                           Ethernet IP Top-Level Partition                              |
+========================================================================================+
|                                                                                        |
|  +------------------------+     +------------------------+     +--------------------+   |
|  |   AXI Crossbar /       |     |   CSR Register Block   |     |   Interrupt        |   |
|  |   Arbiter (Internal)   |     |   (AXI4-Lite Slave)    |     |   Aggregator       |   |
|  +-----------|------------+     +-----------|------------+     +---------|----------+   |
|              |                              |                           |               |
|  +-----------v------------+     +-----------v------------+     +---------v----------+   |
|  |   DMA Engine (8ch)     |<--->|   MTL Layer            |<--->|   XGMAC Core       |   |
|  |   - TX DMA × 8         |     |   - TX FIFO 32KB       |     |   - TBU / TFC / TPE|   |
|  |   - RX DMA × 8         |     |   - RX FIFO 32KB       |     |   - AFM / Rx Parser|   |
|  |   - Descriptor Mgr     |     |   - 8 TX Queues        |     |   - VLAN / TSN     |   |
|  |   - AXI Master (64b)   |     |   - 8 RX Queues        |     |   - Checksum HW    |   |
|  +-----------|------------+     +-----------|------------+     +---------|----------+   |
|              |                              |                           |               |
|              |         +--------------------v--------------------+     |               |
|              |         |   Bridge (MAC-to-MAC Forwarding)        |<----|               |
|              |         |   - FDB (Forwarding DB)                 |     |               |
|              |         |   - Frame Replication (FRER)            |     |               |
|              |         |   - Stream Identification              |     |               |
|              |         +--------------------|--------------------+     |               |
|              |                              |                           |               |
|  +-----------v------------+     +-----------v------------+     +---------v----------+   |
|  |   HSPHY Interface      |     |   PTP / Timestamp Unit   |     |   Safety Monitor   |   |
|  |   - MII / RMII         |     |   - 64b NS Counter       |     |   - ECC Checker    |   |
|  |   - RGMII              |     |   - Addend Accumulator     |     |   - Parity Gen     |   |
|  |   - SGMII / USXGMII    |     |   - PPS Generator (4ch)    |     |   - Timeout Watch  |   |
|  |   - MDIO Master        |     |   - Timestamp Capture      |     |   - SMU_ALERT (4b) |   |
|  +-----------|------------+     +-----------|------------+     +---------|----------+   |
|              |                              |                           |               |
|              v                              v                           v               |
|         [External PHY]                [External Time Master]      [SoC SMU]            |
|                                                                                        |
+========================================================================================+
```

### 1.2 模块职责矩阵

| 模块 | 英文缩写 | 职责描述 | 时钟域 | 关键参数 |
|------|---------|---------|--------|---------|
| DMA引擎 | `eth_dma` | 8路独立TX/RX通道，描述符管理，AXI Master | `clk_sys` | 64b AXI, 8ch, 描述符环 |
| MTL传输层 | `eth_mtl` | FIFO缓冲，队列调度，QoS整形 | `clk_mac` | 32KB TX/RX, 8Q, CBS/TAS |
| XGMAC核心 | `eth_mac` | MAC协议引擎，帧过滤，TSN特性 | `clk_mac` | 5Gbps, 802.1Qav/bv/bu |
| Bridge模块 | `eth_bridge` | MAC-to-MAC转发，FDB，FRER | `clk_mac` | 2端口, 流识别, 1:6多播 |
| HSPHY接口 | `eth_hsphy` | PHY接口适配，SerDes/并行 | `clk_tx_phy` / `clk_rx_phy` | MII/RMII/RGMII/SGMII/USXGMII |
| PTP时间戳 | `eth_ptp` | gPTP/PTP硬件时间戳，PPS | `clk_ts` | 64b NS, 4×PPS, SFD级精度 |
| 安全监控 | `eth_safety` | ECC/Parity/Timeout，SMU告警 | `clk_sys` / `clk_mac` | ASIL-B, SECDED, 4b ALERT |
| CSR寄存器 | `eth_csr` | 全模块配置寄存器，AXI4-Lite | `clk_sys` | 32b, 地址映射见Interface Spec |
| 中断聚合 | `eth_irq` | 通道中断汇总，NIS/AIS分类 | `clk_sys` | 每通道+NIS+AIS |

---

## 2. 数据通路设计

### 2.1 发送数据通路 (TX Path)

```
[系统内存] ──AXI64──► [TX DMA Channel i] ──68b(ATI)──► [MTL TX Queue i]
                                                              │
                                                              │ 阈值/存储转发模式
                                                              ▼
                                                    [MTL TX Scheduler]
                                                              │
                                                              │ CBS / TAS / SP / WRR
                                                              ▼
                                                    [TBU + TFC + TPE]
                                                              │
                                                              │ 插入VLAN / SA替换
                                                              │ 计算IP/TCP/UDP校验和
                                                              ▼
                                                    [XGMAC TX FIFO]
                                                              │
                                                              │ MII/GMII/XGMII
                                                              ▼
                                                    [HSPHY TX Interface]
                                                              │
                                                              ▼
                                                    [External PHY] ──► [线口]
```

#### 2.1.1 TX DMA → MTL 接口 (`ati_tx_if`)

| 信号 | 宽度 | 方向 | 描述 |
|------|------|------|------|
| `ati_tx_data` | 64+4b | DMA → MTL | 数据+控制位 (byte enable / 帧边界) |
| `ati_tx_valid` | 1 | DMA → MTL | 数据有效 |
| `ati_tx_ready` | 1 | MTL → DMA | FIFO可接收 |
| `ati_tx_chid` | 3 | DMA → MTL | 通道ID (0-7) |

#### 2.1.2 MTL → MAC 发送接口 (`mac_tx_if`)

| 信号 | 宽度 | 方向 | 描述 |
|------|------|------|------|
| `mtl_tx_data` | 64b | MTL → MAC | 发送帧数据 |
| `mtl_tx_sof` | 1 | MTL → MAC | 帧起始 |
| `mtl_tx_eof` | 1 | MTL → MAC | 帧结束 |
| `mtl_tx_valid` | 1 | MTL → MAC | 数据有效 |
| `mtl_tx_ready` | 1 | MAC → MTL | MAC可接收 |
| `mtl_tx_status` | 8b | MAC → MTL | 发送状态反馈 (成功/欠流/冲突) |

### 2.2 接收数据通路 (RX Path)

```
[线口] ──► [External PHY] ──► [HSPHY RX Interface]
                                    │
                                    │ MII/GMII/XGMII / RGMII / SGMII
                                    ▼
                              [XGMAC RX Parser + AFM]
                                    │
                                    │ DA/SA过滤，VLAN过滤，IP/Port过滤
                                    │ FFP流识别 → Gate Control
                                    ▼
                              [MTL RX Queue j] (按优先级/哈希分发)
                                    │
                                    │ 阈值/存储转发模式
                                    ▼
                              [RX DMA Channel j]
                                    │
                                    │ 描述符写回 (状态+时间戳)
                                    ▼
                              [系统内存] ◄──AXI64──
```

#### 2.2.1 MAC → MTL 接收接口 (`mac_rx_if`)

| 信号 | 宽度 | 方向 | 描述 |
|------|------|------|------|
| `mac_rx_data` | 64b | MAC → MTL | 接收帧数据 |
| `mac_rx_sof` | 1 | MAC → MTL | 帧起始 |
| `mac_rx_eof` | 1 | MAC → MTL | 帧结束 |
| `mac_rx_valid` | 1 | MAC → MTL | 数据有效 |
| `mac_rx_ready` | 1 | MTL → MAC | MTL可接收 |
| `mac_rx_err` | 4b | MAC → MTL | 接收错误 (CRC/长帧/短帧/对齐) |
| `mac_rx_timestamp` | 64b | MAC → MTL | 64位纳秒时间戳 (SFD捕获时刻) |

#### 2.2.2 MTL → RX DMA 接口 (`ari_rx_if`)

| 信号 | 宽度 | 方向 | 描述 |
|------|------|------|------|
| `ari_rx_data` | 64+4b | MTL → DMA | 数据+控制位 |
| `ari_rx_valid` | 1 | MTL → DMA | 数据有效 |
| `ari_rx_ready` | 1 | DMA → MTL | DMA可接收 |
| `ari_rx_chid` | 3 | MTL → DMA | 目标通道ID |
| `ari_rx_status` | 32b | MTL → DMA | 接收状态+时间戳低32b |

### 2.3 Bridge 数据通路 (MAC-to-MAC Forwarding)

```
[XGMAC0 RX] ──► [Bridge Ingress Port 0]
                      │
                      │ FDB Lookup (DA → {端口掩码, 流ID})
                      │ Stream ID → FRER Sequence Number
                      ▼
              [Bridge Egress Scheduler]
                      │
                      ├──► [XGMAC1 TX] (侧向转发)
                      ├──► [XGMAC0 TX] (环回/自学习)
                      └──► [Host DMA RX] (上报CPU)

[XGMAC1 RX] ──► [Bridge Ingress Port 1] (对称路径)
```

---

## 3. 控制通路设计

### 3.1 CSR → 模块配置通路

所有模块配置通过统一的 `eth_csr` 块下发，AXI4-Lite 32位访问:

```
[CPU] ──AXI4-Lite──► [eth_csr]
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   [eth_dma]      [eth_mtl]         [eth_mac]
   描述符基址       队列阈值           MAC配置
   中断使能         CBS参数            VLAN表
   通道优先级      TAS门控列表        过滤规则
        │                │                │
        ▼                ▼                ▼
   [eth_ptp]      [eth_bridge]      [eth_safety]
   时间基准         转发规则           诊断使能
   PPS配置          FRER参数           超时阈值
```

### 3.2 中断上报通路

```
[模块中断源]
   │
   ├── DMA_CH[i]: TI (发送完成) / RI (接收完成) / RBU (接收缓冲区不可用)
   ├── MTL: 溢出 / 欠流 / 状态变化
   ├── MAC: 链路状态 / 远程唤醒 / 时间戳事件
   ├── PTP: PPS输出 / 时间同步失锁
   └── Safety: ECC错误 / Parity错误 / 超时告警
   │
   ▼
[eth_irq Aggregator] ──按通道/类型汇总──► [INTERRUPT] ──► [SoC IR]
   │
   └── NIS (Normal Interrupt Summary, bit 15)
   └── AIS (Abnormal Interrupt Summary, bit 14)
```

### 3.3 安全告警通路

```
[eth_safety Monitor]
   │
   ├── ECC Single-bit Correctable ──► 记录日志，可屏蔽告警
   ├── ECC Double-bit Uncorrectable ──► SMU_ALERT[0] = 1 (致命)
   ├── FSM Parity Error ──► SMU_ALERT[1] = 1 (严重)
   ├── CSR Access Timeout ──► SMU_ALERT[2] = 1 (严重)
   └── 非法状态机跳转 ──► SMU_ALERT[3] = 1 (严重)
   │
   ▼
[SMU_ALERT[3:0]] ──► [SoC SMU] ──► NMI / 复位 / 中断
```

---

## 4. 子模块详细设计

### 4.1 DMA Engine (`eth_dma`)

#### 4.1.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `dma_ch_ctrl` | 8 | 每通道状态机 (STOP/START/SUSPENDED)，描述符获取/写回 |
| `dma_arbiter` | 1 | 8通道轮询/固定优先级仲裁，AXI Master接口复用 |
| `dma_desc_mgr` | 8 | 描述符环管理 (基址+长度+尾指针)，支持链式和环形模式 |
| `dma_axi_master` | 1 | 64位AXI4 Master，突发传输优化，outstanding支持 |
| `dma_ch_fifo` | 16 | 每通道TX/RX异步FIFO (深度=16，位宽=68b) |

#### 4.1.2 TX DMA 状态机

```
      +---------+
      │  STOP   │◄──────────────────────────┐
      +----+----+                           │
           │ SW_START                        │ SW_STOP / Error
           ▼                                 │
      +---------+     描述符获取成功         │
      │ FETCH   │────────────────────────►  │
      +----+----+                           │
           │ 数据在系统内存                  │
           ▼                                 │
      +---------+     ATI接口传输完成        │
      │ XFER    │────────────────────────►  │
      +----+----+                           │
           │ 帧边界+状态写回                 │
           ▼                                 │
      +---------+     写回完成                │
      │ WB      │────────────────────────►  │
      +----+----+                           │
           │ 中断触发 (TI)                   │
           ▼                                 │
      +---------+     下一描述符              │
      │ IDLE    │───────────────────────────┘
      +---------+
```

### 4.2 MTL Layer (`eth_mtl`)

#### 4.2.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `mtl_tx_fifo` | 1 | 32KB TX FIFO，8个逻辑队列分区 |
| `mtl_rx_fifo` | 1 | 32KB RX FIFO，8个逻辑队列分区 |
| `mtl_tx_sched` | 1 | 发送调度器: SP(严格优先)/WRR(加权轮询)/CBS/TAS |
| `mtl_rx_dispatch` | 1 | 接收分发器: 按VLAN优先级/哈希/DMA通道映射 |
| `mtl_cbs_shaper` | 4 | 802.1Qav CBS整形器 (每队列独立credit计数) |
| `mtl_tas_gcl` | 1 | 802.1Qbv TAS门控列表 (64-1024条目，循环执行) |
| `mtl_qbu_preempt` | 1 | 802.1Qbu帧抢占: pMAC/eMAC双队列管理 |

#### 4.2.2 TX Scheduler 仲裁逻辑

```verilog
// 伪代码: 调度优先级 (从高到低)
if (tas_gcl.current_gate == OPEN && queue_has_frame) begin
    // TAS门控打开且队列有帧 → 按TAS周期调度
    selected_queue = tas_gcl.queue_id;
end else if (cbs_shaper[i].credit >= 0 && cbs_queue_ready[i]) begin
    // CBS整形器有credit → AVB流量
    selected_queue = cbs_queue_id;
end else if (preempt_queue.has express_frame) begin
    // 帧抢占: Express流量 (pMAC) 优先
    selected_queue = preempt_express_qid;
end else begin
    // 默认: 严格优先级 (Queue 7 > 6 > ... > 0)
    selected_queue = highest_ready_sp_queue;
end
```

### 4.3 XGMAC Core (`eth_mac`)

#### 4.3.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `mac_tx_tbu` | 1 | Transmit Bus Interface: VLAN插入/替换/删除，SA操作 |
| `mac_tx_tfc` | 1 | Transmit Frame Controller: 两级寄存器流水线控制 |
| `mac_tx_tpe` | 1 | Transmit Protocol Engine: 802.3发送状态机，CRC生成 |
| `mac_rx_afm` | 1 | Address Filtering Module: DA/SA/VLAN/IP/Port多层过滤 |
| `mac_rx_fpe` | 1 | Frame Parser Engine: FFP流识别，GCL映射，PC计量 |
| `mac_rx_rpe` | 1 | Receive Protocol Engine: 802.3接收状态机，CRC校验 |
| `mac_checksum` | 1 | 硬件校验和引擎: IP/TCP/UDP头部校验和计算/验证 |
| `mac_vlan` | 1 | VLAN处理: QinQ支持，哈希过滤，灵活标签操作 |
| `mac_ts_insert` | 1 | 时间戳插入: 发送帧时间戳捕获，接收帧时间戳附加 |

### 4.4 Bridge (`eth_bridge`)

#### 4.4.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `brd_ingress` | 2 | 入口处理: 帧有效性检查，流ID提取 (IS-ID) |
| `brd_fdb` | 1 | Forwarding Database: 8K条目，MAC+VID → 端口掩码 |
| `brd_frer` | 1 | FRER引擎: 序列号生成/消除，1:6复制，R-Tag处理 |
| `brd_egress_sched` | 1 | 出口调度: 按端口优先级仲裁，防头阻 |
| `brd_learning` | 1 | 自学习引擎: 源MAC+VID → FDB动态更新 (可关闭) |

### 4.5 HSPHY Interface (`eth_hsphy`)

#### 4.5.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `phy_mii_if` | 1 | MII/RMII并行接口: 2.5/25/125MHz时钟域，4b/8b数据 |
| `phy_rgmii_if` | 1 | RGMII接口: DDR时钟，DLL偏斜控制 |
| `phy_sgmii_if` | 1 | SGMII串行接口: 8b/10b编码，125MHz/312.5MHz |
| `phy_usxgmii_if` | 1 | USXGMII接口: 64b/66b编码，625MHz/1.25GHz |
| `phy_mdio_master` | 1 | MDIO管理接口: MDC/MDIO， Clause 22/45 |
| `phy_pcs` | 3 | Physical Coding Sublayer: 每MP8G PHY实例一个 |

### 4.6 PTP Unit (`eth_ptp`)

#### 4.6.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `ptp_counter` | 1 | 64位纳秒计数器，80位扩展 (48b秒 + 32b纳秒) |
| `ptp_addend` | 1 | Addend累加器: 频率补偿，典型2^32增量/周期 |
| `ptp_timestamp` | 1 | 时间戳捕获: SFD检测触发，亚纳秒精度 |
| `ptp_pps_gen` | 4 | PPS输出生成器: 可编程周期/脉宽/相位 |
| `ptp_8021as` | 1 | gPTP状态机: Best Master Clock算法，Sync/Delay_Req处理 |
| `ptp_peer_delay` | 1 | P2P透明时钟: 驻留时间计算，修正域更新 |

### 4.7 Safety Monitor (`eth_safety`)

#### 4.7.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `sft_ecc_enc` | N | 写数据ECC编码: SECDED (Hamming + 1 parity) |
| `sft_ecc_dec` | N | 读数据ECC解码: 单错纠正，双错检测 |
| `sft_parity` | M | FSM状态机parity生成与校验: 所有关键控制FSM |
| `sft_timeout` | K | CSR访问超时监控: 可编程阈值，锁存告警 |
| `sft_illegal_state` | M | 非法状态检测: 所有FSM定义合法状态向量 |
| `sft_alert_arb` | 1 | 告警仲裁: 优先级编码，去抖，SMU_ALERT格式化 |

---

## 5. 时钟域交叉 (CDC) 设计

### 5.1 异步FIFO清单

| 接口 | 源时钟域 | 目标时钟域 | FIFO深度 | 位宽 | CDC方式 |
|------|---------|-----------|---------|------|---------|
| DMA→MTL TX | `clk_sys` | `clk_mac` | 16 | 68b | 异步FIFO (Gray码指针) |
| MTL→DMA RX | `clk_mac` | `clk_sys` | 16 | 68b | 异步FIFO (Gray码指针) |
| MAC→HSPHY TX | `clk_mac` | `clk_tx_phy` | 8 | 8b/32b | 异步FIFO + 握手 |
| HSPHY→MAC RX | `clk_rx_phy` | `clk_mac` | 8 | 8b/32b | 异步FIFO + 握手 |
| PTP→MAC TS | `clk_ts` | `clk_mac` | 4 | 64b | 握手同步器 |
| CSR→Safety | `clk_sys` | `clk_mac` | — | 32b | 多级触发器同步 |

### 5.2 复位域划分

```
rst_n (全局异步复位，低有效)
   │
   ├──► rst_sys_n ──► eth_dma / eth_csr / eth_irq (clk_sys域)
   │
   ├──► rst_mac_n ──► eth_mtl / eth_mac / eth_bridge (clk_mac域)
   │       └── 释放条件: rst_sys_n已释放 + clk_mac稳定 + 100us延时
   │
   ├──► rst_phy_tx_n ──► eth_hsphy TX侧 (clk_tx_phy域)
   │       └── 释放条件: rst_mac_n已释放 + PHY锁定
   │
   ├──► rst_phy_rx_n ──► eth_hsphy RX侧 (clk_rx_phy域)
   │       └── 释放条件: rst_mac_n已释放 + PHY CDR锁定
   │
   └──► rst_ts_n ──► eth_ptp (clk_ts域)
           └── 释放条件: rst_sys_n已释放 + 时间基准就绪
```

---

## 6. 参数化配置

### 6.1 编译时参数 (SystemVerilog `parameter`)

| 参数名 | 类型 | 默认值 | 范围 | 说明 |
|--------|------|--------|------|------|
| `MAC_COUNT` | int | 2 | 1-8 | XGMAC实例数 |
| `DMA_CH_COUNT` | int | 8 | 1-8 | DMA通道数 |
| `MTL_TX_FIFO_DEPTH` | int | 32K | 4K/8K/16K/32K | TX FIFO深度 (字节) |
| `MTL_RX_FIFO_DEPTH` | int | 32K | 4K/8K/16K/32K | RX FIFO深度 (字节) |
| `MTL_TXQ_COUNT` | int | 8 | 1-8 | 发送队列数 |
| `MTL_RXQ_COUNT` | int | 8 | 1-8 | 接收队列数 |
| `PHY_TYPE` | enum | RGMII | MII/RMII/RGMII/SGMII/USXGMII | PHY接口类型 |
| `TSN_ENABLE` | bit | 1 | 0/1 | TSN协议栈使能 |
| `CBS_SHAPER_COUNT` | int | 4 | 0-8 | CBS整形器数量 |
| `TAS_GCL_DEPTH` | int | 64 | 16-1024 | TAS门控列表深度 |
| `PREEMPT_ENABLE` | bit | 1 | 0/1 | 帧抢占使能 |
| `MACSEC_ENABLE` | bit | 1 | 0/1 | MACsec安全加速接口使能 |
| `ECC_ENABLE` | bit | 1 | 0/1 | ECC保护使能 |
| `PARITY_ENABLE` | bit | 1 | 0/1 | FSM parity保护使能 |
| `ASIL_TARGET` | enum | B | B/C/D | 功能安全等级目标 |
| `BRIDGE_ENABLE` | bit | 1 | 0/1 | Bridge转发使能 |
| `FDB_DEPTH` | int | 8K | 1K/2K/4K/8K | FDB条目数 |
| `FRER_ENABLE` | bit | 1 | 0/1 | FRER帧复制消除使能 |
| `PTP_PPS_COUNT` | int | 4 | 1-4 | PPS输出通道数 |
| `AXI_DATA_WIDTH` | int | 64 | 32/64/128 | AXI Master数据位宽 |
| `AXI_ADDR_WIDTH` | int | 32 | 32/40/64 | AXI地址位宽 |

---

## 7. 问题追踪与决策记录

| ID | 描述 | 状态 | 决策 |
|----|------|------|------|
| μARCH-001 | MTL FIFO单端口/双端口选择 | Open | 建议双端口SRAM实现TX/RX独立读写，面积增加~15%但避免仲裁冲突 |
| μARCH-002 | Bridge FDB查表时序: 8K条目@300MHz | Open | 建议2-cycle流水线查表，或4-way set-associative缓存 |
| μARCH-003 | DMA描述符环位置: SRAM vs 系统内存 | Open | 默认系统内存 (灵活性)，可选internal SRAM (低延迟) |
| μARCH-004 | TAS GCL存储: 寄存器文件 vs SRAM | Open | <64条目用寄存器，≥64条目用SRAM |
| μARCH-005 | 帧抢占pMAC/eMAC: 共享FIFO或独立FIFO | Open | 建议独立FIFO避免express帧被阻塞 |

---

## 8. 与下游阶段衔接

| 阶段 | 输入文档 | 下游任务 | 衔接要点 |
|------|---------|---------|---------|
| EDR | 本Micro-Arch Spec | TASK-005 Design Spec | 模块划分 → RTL编码，接口定义 → port清单 |
| EDR | 本Micro-Arch Spec | TASK-007 DFT Spec | 扫描链插入策略，BIST覆盖范围 |
| EDR | 本Micro-Arch Spec | TASK-008 FuSa FMEDA | 安全机制清单 → FIT计算，诊断覆盖率量化 |
| IDR | 本Micro-Arch Spec | TASK-009 RTL Coding | 参数化配置 → 顶层parameter，FSM定义 → RTL状态机 |
| IDR | 本Micro-Arch Spec | TASK-010 UVM Env | 模块划分 → agent划分，接口定义 → UVM interface |

---

*文档状态: PAD阶段微架构初稿，待Arch Review评审*
*生成时间: 2026-05-12 02:04:00 (PAD Orchestrator Auto-Start)*
*依赖: TASK-003 COMPLETED, Arch Spec v1.3, Kimi Agent TC4x研究材料*
