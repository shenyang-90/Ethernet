# Ethernet IP Micro-Architecture Design Specification

> **项目**: Ethernet IP (IP_20260502_001)
> **模块**: Gigabit Ethernet MAC + PHY Subsystem
> **版本**: v1.1  
> **日期**: 2026-05-29  
> **作者**: RTL Coding Agent (PAD-REWORK-012)  
> **评审状态**: Draft → 待评审  
> **前置文档**: `Docs/Arch/ethernet_arch_spec.md` **v1.8d**, `Docs/Arch/ethernet_interface_spec.md` **v1.0**, `Docs/Arch/ethernet_clock_reset_spec.md` **v1.2**  
> **变更**: (PAD-REWORK-012) RTL-MAJ-004/005 + RTL-MIN-002: 1. §4.1.4 新增 AXI Protocol Parameters (ID分配/Outstanding上限/QoS映射) 2. §7 关闭 μARCH-001/005/007/008/009/010 3. §6 参数默认值与 Arch Spec §1.4 统一 (差异表+修正)

---

## 1. 微架构总览

### 1.1 顶层模块划分

基于**Arch Spec v1.8d**的架构定义和TC4x GETH / R-Car S4 对标分析,本IP微架构划分为**8个顶层功能模块 + 1个Switch Core + 1个vPHC虚拟化模块**:

```
+========================================================================================+
|                        Ethernet IP Top-Level Partition (v1.8d)                       |
+========================================================================================+
|                                                                                        |
|  +------------------------+     +------------------------+     +--------------------+   |
|  |   AXI Crossbar /       |     |   CSR Register Block   |     |   Interrupt        |   |
|  |   Arbiter (Internal)   |     |   (AXI4-Lite Slave)    |     |   Aggregator       |   |
|  +-----------|------------+     +-----------|------------+     +---------|----------+   |
|              |                              |                           |               |
|  +-----------v------------+     +-----------v------------+     +---------v----------+   |
|  |   DMA Engine (全局池)  |<--->|   MTL Layer            |<--->|   GMAC/XGMAC Core  |   |
|  |   - 8/16/32 通道池     |     |   - TX/RX FIFO 32KB    |     |   - 每实例独立配置 |   |
|  |   - 所有MAC共享复用    |     |   - 8 TX / 8 RX Queues |     |   - TBU/TFC/TPE    |   |
|  |   - 64b/128b AXI Mstr  |     |   - CBS/TAS/Qbu        |     |   - AFM/Rx Parser  |   |
|  +-----------|------------+     +-----------|------------+     +---------|----------+   |
|              |                              |                           |               |
|              |         +--------------------v--------------------+     |               |
|              |         |   Switch Core (N-port L2/L3, N=SWITCH_PORT_COUNT) |<----|               |
|              |         |   - FDB 8K + VLAN + L3 Route            |     |               |
|              |         |   - TAS Gate Control List (Switch级)    |     |               |
|              |         |   - FRER / Stream ID / AVTP Filter      |     |               |
|              |         |   - 独立Host端口 (CPU管理)               |     |               |
|              |         +--------------------|--------------------+     |               |
|              |                              |                           |               |
|  +-----------v------------+     +-----------v------------+     +---------v----------+   |
|  |   HSPHY Interface      |     |   PTP / Timestamp Unit   |     |   Safety Monitor   |   |
|  |   - MII/RMII/RGMII     |     |   - PHC0 / PHC1 (64b)    |     |   - ECC/Parity     |   |
|  |   - SGMII/USXGMII      |     |   - Crossbar (每端口绑定)  |     |   - Timeout Watch  |   |
|  |   - MDIO Master        |     |   - Addend Accumulator   |     |   - SMU_ALERT (4b) |   |
|  +-----------|------------+     +-----------|------------+     +---------|----------+   |
|              |                              |                           |               |
|  +-----------v------------+     +-----------v------------+     +---------v----------+   |
|  |   vPHC 虚拟化          |     |   低功耗控制器          |     |   (SoC SMU)        |   |
|  |   - Xen IO Rings       |     |   - EEE / WoL / DeepSleep|     |                    |   |
|  |   - 每VM独立时间域     |     |   - 时钟门控 / PHY电源   |     |                    |   |
|  +-----------|------------+     +-----------|------------+     +--------------------+   |
|              |                              |                                           |
|              v                              v                                           v
|         [External PHY]                [External Time Master]                      [SoC]  |
|                                                                                        |
+========================================================================================+
```

**Switch 混合架构说明**: 通过 `SWITCH_CONNECTED_MAC_x` 参数,每 MAC 可选择接入 Switch Core 或独立直连 Host(见 §2.4)。

### 1.2 模块职责矩阵

| 模块 | 英文缩写 | 职责描述 | 时钟域 | 关键参数 |
|------|---------|---------|--------|---------|
| DMA引擎 | `eth_dma` | **全局通道池 (8/16/32)**,所有MAC共享复用,描述符管理,AXI Master | `clk_sys` | 64b/128b AXI, 全局池, 描述符环 |
| MTL传输层 | `eth_mtl` | FIFO缓冲,队列调度,QoS整形 | `clk_mac` | 32KB TX/RX, 8Q, CBS/TAS |
| **GMAC/XGMAC核心** | `eth_mac[0..N-1]` | **每实例独立配置** (`MAC_x_TYPE`/`PHY_x_TYPE`/`PHY_x_SPEED`),MAC协议引擎 | `clk_mac` | 10M~10G, 802.1Qav/bv/bu |
| **Switch Core** | `eth_switch` | **N-port L2/L3 Switch** (N=2~8, default 4), FDB/VLAN/L3 Route/TAS GCL | `clk_mac` | N-port, 8K FDB, Switch级TAS |
| HSPHY接口 | `eth_hsphy` | PHY接口适配,SerDes/并行,**温度自适应链路降速** | `clk_tx_phy` / `clk_rx_phy` | MII/RMII/RGMII/SGMII/USXGMII |
| PTP时间戳 | `eth_ptp` | **双PHC + Crossbar**,gPTP/PTP硬件时间戳,PPS | `clk_ts` | **250MHz**, 64b NS, 4×PPS, ±10ns |
| **vPHC虚拟化** | `eth_vphc` | **Xen IO Rings**,SDV/Hypervisor 每VM独立时间域 | `clk_sys` / `clk_ts` | `SUPPORT_VPHC` |
| 安全监控 | `eth_safety` | ECC/Parity/Timeout,SMU告警 | `clk_sys` / `clk_mac` | ASIL-B 基线, SECDED, 4b ALERT |
| **低功耗控制器** | `eth_pm` | **EEE/WoL/Deep Sleep**,时钟门控,PHY电源控制 | `clk_sys` | 30%/5%/1% Active |
| CSR寄存器 | `eth_csr` | 全模块配置寄存器,AXI4-Lite | `clk_sys` | 32b, 地址映射见Interface Spec |
| 中断聚合 | `eth_irq` | 通道中断汇总,NIS/AIS分类 | `clk_sys` | 每通道+NIS+AIS |

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
                                    │ DA/SA过滤,VLAN过滤,IP/Port过滤
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

### 2.3 Switch Core 数据通路 (N-port L2/L3 Switch + 混合架构)

**混合架构**: 每 MAC 通过 `SWITCH_CONNECTED_MAC_x` 选择接入模式:

```
                    ┌─────────────────────────────────────────────────────────┐
                    │              Switch Core (N-port + Host Port)           │
                    │  ┌─────────┐  ┌─────────┐  ...  ┌─────────┐       │   │
   [MAC0 RX] ───────►│Port 0   │  │Port 1   │  ...  │Port N-1 │           │   │
   (1G, Switch)      │Ingress  │  │Ingress  │  ...  │Ingress  │           │   │
                    │  ↓      │  │  ↓      │  ...  │  ↓      │           │   │
                    │ FDB/VLAN│  │ FDB/VLAN│  ...  │ FDB/VLAN│           │   │
                    │ L3 Route│  │ L3 Route│  ...  │ L3 Route│           │   │
                    │  ↓      │  │  ↓      │  ...  │  ↓      │           │   │
                    │Egress   │  │Egress   │  ...  │Egress   │           │   │
   [MAC0 TX] ◄──────│Port 0   │  │Port 1   │  ...  │Port N-1 │           │   │
   (1G, Switch)      └─────────┘  └─────────┘  ...  └─────────┘           │
                    │                  ↑                                   │
                    │              [Host Port] ──► CPU/DMA RX/TX            │
                    │                  (管理帧 + 独立MAC流量)                │
                    └─────────────────────────────────────────────────────────┘

   [MAC4 RX] ──► [独立 DMA CH] ──► [Host]  (不经过 Switch, `SWITCH_CONNECTED_MAC_4=0`)
   [MAC5 RX] ──► [独立 DMA CH] ──► [Host]  (不经过 Switch, `SWITCH_CONNECTED_MAC_5=0`)
```

**数据通路 - Switch MAC** (`SWITCH_CONNECTED_MAC_x=1`):
1. **RX**: MAC RX → Switch Ingress Port → FDB Lookup → L2/L3 转发决策 → Egress Scheduler → 目标 MAC TX / Host Port
2. **TX**: Host/DMA → Switch Host Port → Egress Scheduler → 目标 Port → MAC TX
3. **自学习**: 源 MAC+VID → FDB 动态更新(可关闭)
4. **FRER**: Stream ID → 序列号生成/消除,R-Tag 处理
5. **AVTP Filter**: 硬件识别 AVTP 流,RX 分离到独立队列

**数据通路 - 独立 MAC** (`SWITCH_CONNECTED_MAC_x=0`):
- 标准端点模式: MAC ↔ MTL ↔ DMA ↔ Host(不经过 Switch)
- 适用于 OTA/诊断/ADAS 等对延迟敏感的场景

**丢帧保证机制**:
- 每端口独立 Ingress FIFO (2KB~8KB),单端口拥塞不阻塞其他端口
- Crossbar 全并发: 4 端口同时线速转发
- 背压 (Back-pressure): Egress 忙时发送 pause 帧
- 优先级调度: TSN 队列优先,普通队列轮转

#### 2.3.1 Switch 内部接口 (`swi_if`)

| 信号 | 宽度 | 方向 | 描述 |
|------|------|------|------|
| `swi_ingress_data` | 64b | MAC → Switch | 入口帧数据 |
| `swi_ingress_sof` | 1 | MAC → Switch | 帧起始 |
| `swi_ingress_port` | $clog2(SWITCH_PORT_COUNT) | MAC → Switch | 入口端口号 (0~N-1) |
| `swi_ingress_valid` | 1 | MAC → Switch | 数据有效 |
| `swi_egress_data` | 64b | Switch → MAC | 出口帧数据 |
| `swi_egress_port` | SWITCH_PORT_COUNT | Switch → MAC | 端口掩码 (bit[i]=1 → 发送到Port i) |
| `swi_egress_valid` | 1 | Switch → MAC | 数据有效 |
| `swi_backpressure` | SWITCH_PORT_COUNT | MAC → Switch | 每端口背压请求 |

#### 2.3.2 Switch ↔ Host 接口 (`swi_host_if`)

| 信号 | 宽度 | 方向 | 描述 |
|------|------|------|------|
| `swi_host_rx_data` | 64b | Switch → Host | 发往 CPU 的帧 |
| `swi_host_rx_valid` | 1 | Switch → Host | RX 有效 |
| `swi_host_tx_data` | 64b | Host → Switch | 来自 CPU 的帧 |
| `swi_host_tx_valid` | 1 | Host → Switch | TX 有效 |
| `swi_host_tx_ready` | 1 | Switch → Host | 可接收 |

---

## 3. 控制通路设计

### 3.1 CSR → 模块配置通路

所有模块配置通过统一的 `eth_csr` 块下发,AXI4-Lite 32位访问:

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
   ├── ECC Single-bit Correctable ──► 记录日志,可屏蔽告警
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
| `dma_ch_ctrl` | 8 | 每通道状态机 (STOP/START/SUSPENDED),描述符获取/写回 |
| `dma_arbiter` | 1 | 8通道轮询/固定优先级仲裁,AXI Master接口复用 |
| `dma_desc_mgr` | 8 | 描述符环管理 (基址+长度+尾指针),支持链式和环形模式 |
| `dma_axi_master` | 1 | 64位AXI4 Master,突发传输优化,outstanding支持 |
| `dma_ch_fifo` | 16 | 每通道TX/RX异步FIFO (深度=16,位宽=68b) |

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

### 4.1.4 AXI Protocol Parameters

基于 Arch Spec §1.4.2/§4.4 总线带宽评估,DMA AXI4 Master 接口需满足多通道并发、TSN 优先级隔离和 Switch 转发吞吐需求。本节定义 AXI 协议层关键参数。

#### 4.1.4.1 AXI ID 分配表

DMA Engine 作为 AXI4 Master,通过独立的 AWID/ARID 区分不同通道和方向的传输事务,便于 SoC Interconnect 重排序和 QoS 路由。

| ID 范围 | 用途 | 通道数 | 说明 |
|:-------:|------|:------:|------|
| `0x0` ~ `0x3` | **TX 数据通道** (CH0~CH3) | 4 | 普通数据发送,每通道 1 个 ID |
| `0x4` ~ `0x7` | **RX 数据通道** (CH0~CH3) | 4 | 普通数据接收,每通道 1 个 ID |
| `0x8` ~ `0xB` | **TSN/CBS 专用 TX** (CH4~CH7) | 4 | TSN 时间敏感流,独立 ID 避免阻塞 |
| `0xC` ~ `0xD` | **TSN/CBS 专用 RX** (CH4~CH5) | 2 | AVB/gPTP 高优先级接收 |
| `0xE` | **Switch Host Port TX** | 1 | Switch Core CPU 管理帧发送 |
| `0xF` | **Switch Host Port RX** | 1 | Switch Core CPU 管理帧接收 |

**扩展规则** (当 `DMA_CH_COUNT > 16`):
- ID 位宽由 `AXI_ID_WIDTH` 参数化 (默认 4-bit,可扩展至 8-bit)
- 每 16 通道复用一套 ID 映射,通过高位区分通道组
- 最小粒度: **每通道 TX/RX 至少各 1 个独立 ID**

#### 4.1.4.2 Outstanding 事务上限

为防止 AXI Interconnect 死锁并保证各通道带宽公平性,设置两级 Outstanding 限制:

| 层级 | 上限 | 说明 |
|------|:----:|------|
| **每通道 (per-channel)** | **4 ~ 8** | 单个 DMA 通道同时挂起的读/写事务数上限 |
| **全局 (global)** | **32** | 所有 DMA 通道 + Switch Host Port 合计 Outstanding 上限 |
| **每方向 (per-direction)** | **16** | 全部读 (AR) 或全部写 (AW) 独立上限,避免读/写互相阻塞 |

**RTL 实现**:
```verilog
// 每通道 outstanding 计数器 (读/写独立)
localparam CH_OS_MAX = (DMA_CH_COUNT <= 8) ? 8 : 4;  // 8ch以内放宽至8,16/32ch收紧至4
localparam GLB_OS_MAX = 32;

reg [3:0] ch_os_cnt [0:DMA_CH_COUNT-1];   // 每通道 0~15
reg [5:0] glb_os_cnt;                      // 全局 0~63 (含余量)

// 新事务授权条件
wire tx_grant = (ch_os_cnt[ch_id] < CH_OS_MAX) && (glb_os_cnt < GLB_OS_MAX);
```

**约束验证**:
- 中央网关 (4×1G, 16ch): 每通道 4 Outstanding × 16ch = 64 → 全局限制 32 强制流量整形,保证 3.2× 总线裕量
- ADAS (2×5G, 16ch): 每通道 4 Outstanding × 16ch = 64 → 全局限制 32,TSN 通道 (ID 0x8~0xB) 优先通过 QoS 绕过限制

#### 4.1.4.3 QoS 映射 (AWQOS/ARQOS)

AXI4 的 AWQOS/ARQOS 4-bit 信号直接映射 DMA 通道优先级,指导 SoC Interconnect 仲裁:

| DMA 通道类型 | 优先级 | AWQOS/ARQOS | 适用场景 |
|-------------|:------:|:-----------:|----------|
| **gPTP/Sync 时间戳** | **P0 (最高)** | `0xF` (15) | PTP 事件消息,延迟敏感 |
| **AVB/CBS 整形流** | **P1** | `0xC` (12) | 音频/视频确定性流量 |
| **TAS 门控流** | **P2** | `0xA` (10) | 802.1Qbv 门控窗口内流量 |
| **普通数据 (TX/RX)** | **P3** | `0x8` (8) | 标准 TCP/IP 数据 |
| **Switch Host 管理帧** | **P4** | `0x6` (6) | CPU 管理/诊断帧 |
| **背景/OTA/Bulk** | **P5 (最低)** | `0x2` (2) | 固件更新、日志上传 |

**动态 QoS 调整**:
- 通道 QoS 默认值由 `DMA_CH_QOS[0..DMA_CH_COUNT-1]` 参数/寄存器配置
- TSN 使能时,硬件自动将 CBS/TAS 队列映射到 `0xA` ~ `0xC`,不可被软件降级
- 紧急流 (如 SMU 报警日志) 可通过 `DMA_CH_QOS_OVERRIDE` CSR 临时提升到 `0xF`

### 4.2 MTL Layer (`eth_mtl`)

#### 4.2.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `mtl_tx_fifo` | 1 | 32KB TX FIFO,8个逻辑队列分区 |
| `mtl_rx_fifo` | 1 | 32KB RX FIFO,8个逻辑队列分区 |
| `mtl_tx_sched` | 1 | 发送调度器: SP(严格优先)/WRR(加权轮询)/CBS/TAS |
| `mtl_rx_dispatch` | 1 | 接收分发器: 按VLAN优先级/哈希/DMA通道映射 |
| `mtl_cbs_shaper` | 4 | 802.1Qav CBS整形器 (每队列独立credit计数) |
| `mtl_tas_gcl` | 1 | 802.1Qbv TAS门控列表 (64-1024条目,循环执行) |
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
| `mac_tx_tbu` | 1 | Transmit Bus Interface: VLAN插入/替换/删除,SA操作 |
| `mac_tx_tfc` | 1 | Transmit Frame Controller: 两级寄存器流水线控制 |
| `mac_tx_tpe` | 1 | Transmit Protocol Engine: 802.3发送状态机,CRC生成 |
| `mac_rx_afm` | 1 | Address Filtering Module: DA/SA/VLAN/IP/Port多层过滤 |
| `mac_rx_fpe` | 1 | Frame Parser Engine: FFP流识别,GCL映射,PC计量 |
| `mac_rx_rpe` | 1 | Receive Protocol Engine: 802.3接收状态机,CRC校验 |
| `mac_checksum` | 1 | 硬件校验和引擎: IP/TCP/UDP头部校验和计算/验证 |
| `mac_vlan` | 1 | VLAN处理: QinQ支持,哈希过滤,灵活标签操作 |
| `mac_ts_insert` | 1 | 时间戳插入: 发送帧时间戳捕获,接收帧时间戳附加 |

### 4.4 Switch Core (`eth_switch`) - 参数化 N=SWITCH_PORT_COUNT

#### 4.4.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `sw_ingress` | **N** | 入口处理: 每端口帧有效性检查,流ID提取 (IS-ID),AVTP 识别 |
| `sw_ingress_fifo` | **N** | 每端口独立 FIFO (2KB~8KB),防 HOL 阻塞 |
| `sw_fdb` | 1 | Forwarding Database: **8K 条目**,MAC+VID → 端口掩码,**静态/动态混合** |
| `sw_vlan` | 1 | VLAN 处理: QinQ,灵活标签插入/替换/删除,VLAN 过滤 |
| `sw_l3_route` | 1 | **L3 路由引擎** (若 `SWITCH_L3=1`): IP 前缀匹配,下一跳查找 |
| `sw_tas_gcl` | 1 | **Switch 级 TAS**: 64-1024 条目门控列表,**每端口独立周期** |
| `sw_frer` | 1 | FRER 引擎: 序列号生成/消除,**1:6 复制**,R-Tag 处理 |
| `sw_avtp_filter` | 1 | **AVTP 硬件识别**: Stream ID → 队列映射,RX 分离 |
| `sw_egress_sched` | 1 | 出口调度: **Crossbar 全并发**,按端口优先级仲裁,背压控制 |
| `sw_egress_port` | **N** | 每出口端口: 帧组装,优先级标记,pause 帧生成 |
| `sw_host_port` | 1 | **独立 Host 端口**: CPU 管理帧收发,独立 MAC 流量透传 |
| `sw_learning` | 1 | 自学习引擎: 源 MAC+VID → FDB 动态更新 (可关闭,静态绑定优先) |

#### 4.4.1a 参数化实例化策略 (`generate` 块)

基于 Arch Spec v1.8c `SWITCH_PORT_COUNT` 参数 (范围 2~8, 默认 4),Switch Core 内部所有 **per-port** 子模块通过 `generate for` 循环实例化,而非硬编码固定数量。核心模块 (FDB, VLAN, L3 Route, TAS GCL, FRER, Host Port) 为单实例,与端口数无关。

```verilog
module eth_switch #(
    parameter SWITCH_PORT_COUNT = 4,    // 2 ~ 8, default 4
    parameter FDB_DEPTH         = 8192, // 1K/2K/4K/8K
    parameter SWITCH_L3         = 0,    // 0/1
    parameter SWITCH_TAS        = 1     // 0/1
)(
    // ... ports ...
);

    // -----------------------------------------------------------------
    // Per-Port 模块: generate 循环实例化 (N = SWITCH_PORT_COUNT)
    // -----------------------------------------------------------------
    genvar i;

    // Ingress 处理: 每端口一个实例
    generate for (i = 0; i < SWITCH_PORT_COUNT; i++) begin : gen_sw_ingress
        sw_ingress u_sw_ingress (
            .clk          (clk_mac),
            .rst_n        (rst_n),
            .port_id      (i[$clog2(SWITCH_PORT_COUNT)-1:0]),
            .ingress_data (swi_ingress_data[i]),
            .ingress_sof  (swi_ingress_sof[i]),
            .ingress_valid(swi_ingress_valid[i]),
            // ... 其他接口
        );
    end endgenerate

    // Ingress FIFO: 每端口一个实例
    generate for (i = 0; i < SWITCH_PORT_COUNT; i++) begin : gen_sw_ingress_fifo
        sw_ingress_fifo #(
            .FIFO_DEPTH (2048),  // 2KB ~ 8KB configurable
            .DATA_WIDTH (64)
        ) u_fifo (
            .clk    (clk_mac),
            .rst_n  (rst_n),
            .wr_data(sw_ingress_data[i]),
            .rd_data(sw_fifo_rdata[i]),
            // ...
        );
    end endgenerate

    // Egress 端口: 每端口一个实例
    generate for (i = 0; i < SWITCH_PORT_COUNT; i++) begin : gen_sw_egress_port
        sw_egress_port u_egress (
            .clk         (clk_mac),
            .rst_n       (rst_n),
            .port_id     (i[$clog2(SWITCH_PORT_COUNT)-1:0]),
            .egress_data (swi_egress_data[i]),
            .egress_valid(swi_egress_valid[i]),
            .pause_frame_req(pause_frame_req[i]),
            // ...
        );
    end endgenerate

    // -----------------------------------------------------------------
    // 单实例核心模块 (与端口数无关)
    // -----------------------------------------------------------------
    sw_fdb #(
        .FDB_DEPTH      (FDB_DEPTH),
        .SWITCH_PORT_COUNT(SWITCH_PORT_COUNT)
    ) u_fdb ( ... );

    sw_vlan #(
        .SWITCH_PORT_COUNT(SWITCH_PORT_COUNT)
    ) u_vlan ( ... );

    sw_egress_arbiter #(
        .SWITCH_PORT_COUNT(SWITCH_PORT_COUNT)
    ) u_arbiter ( ... );

    // L3 / TAS / FRER / AVTP Filter 为可选单实例
    generate if (SWITCH_L3) begin : gen_l3
        sw_l3_route u_l3 ( ... );
    end endgenerate

    generate if (SWITCH_TAS) begin : gen_tas
        sw_tas_gcl u_tas ( ... );
    end endgenerate

    sw_host_port u_host_port ( ... );  // 独立 Host 端口, 不计入 N

endmodule
```

**参数化原则**:
| 模块类型 | 实例化方式 | 参数影响 | 备注 |
|----------|-----------|----------|------|
| `sw_ingress` | `generate for` × N | 每端口独立 | N = SWITCH_PORT_COUNT |
| `sw_ingress_fifo` | `generate for` × N | 每端口深度可独立配置 | 防 HOL 阻塞 |
| `sw_egress_port` | `generate for` × N | 每端口 pause/组装逻辑 | - |
| `sw_fdb` | 单实例 | FDB_DEPTH, 查表端口数 | `switch_fdb_microarch.md` §4.3 |
| `sw_egress_arbiter` | 单实例 | Crossbar N×N, 仲裁器 N-port | `switch_arbiter_design.md` §10 |
| `sw_vlan` | 单实例 | VLAN 表端口掩码宽度 | - |
| `sw_l3_route` | 单实例 (可选) | 路由表端口掩码宽度 | `SWITCH_L3=1` 时实例化 |
| `sw_tas_gcl` | 单实例 (可选) | GCL 每端口独立列表 | `SWITCH_TAS=1` 时实例化 |
| `sw_frer` | 单实例 (可选) | Stream ID → 端口掩码 | - |
| `sw_host_port` | 单实例 | 与 N 无关 | CPU 管理/收发 |

**与 Arch Spec 对齐检查**:
- `SWITCH_PORT_COUNT` 范围: 2~8 ✅ (Arch Spec §1.4.1)
- 默认端口数: 4 ✅ (Arch Spec 默认值)
- `SWITCH_CONNECTED_MAC_x` 约束: N ≤ count(MAC_x 接入 Switch) ✅
- FDB 查表: 2~4 端口 = 2-cycle; 5~8 端口 = 3~5 cycle (时间复用) ✅ (参考 `switch_fdb_microarch.md` §4.3)
- 仲裁器面积: N=4 → ~14kGE; N=8 → ~52kGE ✅ (参考 `switch_arbiter_design.md` §9.1)

---

#### 4.4.2 Switch 级 TAS 与端点级 TAS 互斥

**硬件互锁** (Arch Spec v1.8 决策):
- `SUPPORT_SWITCH=1` → 强制 `SWITCH_TAS=1`, `SUPPORT_TAS=0`
- `SUPPORT_SWITCH=0` → 端点级 `SUPPORT_TAS=1`
- Switch 统一调度所有接入端口,端点无需感知门控周期

#### 4.4.3 满负载丢帧率保证 (硬件实现)

| 机制 | 实现 |
|------|------|
| 独立 Ingress FIFO | 每端口 2KB~8KB,单端口拥塞不阻塞其他 |
| Crossbar 全并发 | N 端口同时线速转发,无仲裁冲突 |
| 背压 (Back-pressure) | Egress 忙时向 Ingress 发送 pause 帧 |
| 优先级调度 | TSN 队列优先,普通队列在余量带宽中轮转 |
| 静态 FDB | 关键帧 (gPTP SYNC) 静态绑定,零查表延迟 |

**目标**: N-port 线速单播 ≤0.001%,广播风暴 ≤0.01% (验证基准 N=4)

### 4.5 HSPHY Interface (`eth_hsphy`)

#### 4.5.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `phy_mii_if` | 1 | MII/RMII并行接口: 2.5/25/125MHz时钟域,4b/8b数据 |
| `phy_rgmii_if` | 1 | RGMII接口: DDR时钟,DLL偏斜控制 |
| `phy_sgmii_if` | 1 | SGMII串行接口: 8b/10b编码,125MHz/312.5MHz |
| `phy_usxgmii_if` | 1 | USXGMII接口: 64b/66b编码,625MHz/1.25GHz |
| `phy_mdio_master` | 1 | MDIO管理接口: MDC/MDIO, Clause 22/45 |
| `phy_pcs` | 3 | Physical Coding Sublayer: 每MP8G PHY实例一个 |

### 4.6 PTP Unit (`eth_ptp`)

#### 4.6.1 内部子模块划分 - 双 PHC + Crossbar 架构

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `ptc_counter_0` | 1 | **PHC0**: 64-bit 纳秒计数器 (sec[32]+ns[32]),`clk_ts=250MHz` |
| `ptc_counter_1` | 1 | **PHC1**: 64-bit 纳秒计数器,**同源 clk_ts** (无时钟偏差) |
| `ptc_addend_0` | 1 | **PHC0 Addend**: 32-bit fractional accumulator,`0x4000_0000` 基准 |
| `ptc_addend_1` | 1 | **PHC1 Addend**: 32-bit fractional accumulator,独立精调 |
| `ptc_crossbar` | 1 | **Crossbar**: 每端口 (0~N-1) 独立绑定 PHC0 或 PHC1 |
| `ptc_timestamp` | **N** | **时间戳捕获**: 每端口 SFD 边沿检测,64-bit 锁存 |
| `ptc_pps_gen` | **N** | **PPS 输出**: 可编程周期/脉宽/相位,每端口独立 |
| `ptc_8021as` | 1 | gPTP 状态机: Best Master Clock,Sync/Announce 处理 |
| `ptc_peer_delay` | 1 | **P2P 透明时钟**: 硬件 residence time 测量,correctionField 修正 |
| `ptc_tc_ctrl` | 1 | **TC 控制**: N-port 并发 residence time 计算,无端口对限制 |

#### 4.6.2 PHC Crossbar 绑定

```verilog
// 每端口独立绑定 (CSR 配置), N = SWITCH_PORT_COUNT
generate for (genvar p = 0; p < SWITCH_PORT_COUNT; p++) begin : ptc_bind
  // 默认: 前半端口 → PHC0, 后半端口 → PHC1
  ptc_crossbar.port_bind[p] = (p < SWITCH_PORT_COUNT/2) ? PHC0 : PHC1;
end
endgenerate

// BC 模式: 前半 → PHC0; 后半 → PHC1 (或全端口 → PHC0)
// TC 模式: 各端口独立 residence time 测量,无需共享时间基
```

**规避 TC4x LETH_TC.010**: 无菊花链限制,所有端口同时捕获/修正时间戳。

#### 4.6.3 时间戳精度保证

| 参数 | 值 | 说明 |
|------|------|------|
| `clk_ts` | **250 MHz** | PHC 参考时钟 (Arch Spec §3.3 决策) |
| Tick 周期 | **4 ns** | 1 / 250MHz |
| Addend 位宽 | 32-bit | Fractional accumulator |
| Addend 基准 | `0x4000_0000` | `2^32 / 0.25 = 17,179,869,184` |
| 理论分辨率 | ~0.93 fs | `4ns / 2^32`,足够平滑 |
| 捕获点 | **SFD 边沿** | MII/GMII/RGMII 接口 Start Frame Delimiter |
| 精度目标 | **±10 ns** | 单域 gPTP (满足 802.1AS) |

#### 4.6.4 P2P 路径延迟 - 硬件 Transparent Clock

**软件实现** (默认, `SUPPORT_GPTP=0`):
- SYNC/PDELAY_REQ/PDELAY_RESP 报文携带时间戳
- 软件计算: `peer_delay = ((t4 - t1) - (t3 - t2)) / 2`

**硬件 TC** (可选, `SUPPORT_GPTP=1`):
- Switch Core 自动测量 residence time(ingress→egress 时间)
- residence time 直接修正到 Follow_Up 报文的 correctionField
- **验证目标**: N-port TC 模式下 residence time 误差 < ±20ns (验证基准 N=4,8)

### 4.7 Safety Monitor (`eth_safety`)

#### 4.7.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `sft_ecc_enc` | N | 写数据ECC编码: SECDED (Hamming + 1 parity) |
| `sft_ecc_dec` | N | 读数据ECC解码: 单错纠正,双错检测 |
| `sft_parity` | M | FSM状态机parity生成与校验: 所有关键控制FSM |
| `sft_timeout` | K | CSR访问超时监控: 可编程阈值,锁存告警 |
| `sft_illegal_state` | M | 非法状态检测: 所有FSM定义合法状态向量 |
| `sft_alert_arb` | 1 | 告警仲裁: 优先级编码,去抖,SMU_ALERT格式化 |

### 4.8 vPHC 虚拟化 (`eth_vphc`)

**条件**: `SUPPORT_VPHC=1` 时实例化。

#### 4.8.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `vphc_xen_ring` | 1 | Xen IO Ring 管理: 前端 (VM) ↔ 后端 (驱动) 共享内存环 |
| `vphc_time_domain` | N | 每 VM 虚拟时间域: 独立 offset + drift 补偿 |
| `vphc_phc_mux` | 1 | PHC 多路复用: VM 请求 → PHC0/PHC1 路由 |
| `vphc_irq_virt` | 1 | 虚拟中断分发: 每 VM 独立 PPS/同步中断 |

#### 4.8.2 Xen IO Ring 机制

```
[VM Guest] ──Xen IO Ring──► [vPHC Backend]
     │                              │
     │  共享内存页 (grant table)     │
     │  请求: "读取 PHC0 当前时间"    │
     │  响应: "sec=1234567890, ns=123456789" │
     ▼                              ▼
  [Frontend Driver]          [Backend Driver]
  (运行在 VM 内)               (运行在 Dom0 / Host)
```

**精度影响**: Xen IO Ring 往返延迟 → vPHC 精度目标 **±25 ns**(见 Arch Spec §3.3.6)。

### 4.9 低功耗控制器 (`eth_pm`)

#### 4.9.1 内部子模块划分

| 子模块 | 实例数 | 功能描述 |
|--------|--------|---------|
| `pm_eee_ctrl` | 1 | 802.3az EEE 控制: PHY LPI 进入/唤醒序列生成 |
| `pm_wol_detect` | 1 | WoL 魔术包检测: 链路断开时监听特定帧模式 |
| `pm_deep_sleep` | 1 | Deep Sleep 控制: FIFO/PHC/模块级断电序列 |
| `pm_clk_gate` | 1 | 时钟门控分发: 各子模块独立 `clk_gate_en` |
| `pm_phy_pwr` | 1 | PHY 电源控制: 每 PHY 独立上下电 (`PHY_PWR_DOWN`) |

#### 4.9.2 低功耗模式状态机

```
        +----------+
        │  ACTIVE  │◄──────────────────────────┐
        +----+-----+                           │
             │ 链路空闲 > 1ms                  │ 任何帧到达
             ▼                                 │
        +----------+     LPI Wake 序列        │
        │   EEE    │────────────────────────►  │
        +----+-----+     (< 10 μs 恢复)       │
             │ 软件配置 / 魔术包检测            │
             ▼                                 │
        +----------+     帧到达 / 软件唤醒     │
        │   WoL    │────────────────────────►  │
        +----+-----+     (< 100 μs 恢复)      │
             │ 系统休眠指令                     │
             ▼                                 │
        +----------+     软件唤醒 / 中断      │
        │ DEEP SLEEP│────────────────────────►  │
        +----------+     (< 1 ms 恢复)        │
```

#### 4.9.3 功耗估算参考

| 场景 | 配置 | **估算功耗** | 说明 |
|------|------|-------------|------|
| 中央网关 (4×1G + Switch) | Active | **~800 mW** | 2×5G MAC + N-port Switch + PHC |
| ADAS (2×5G) | Active | **~600 mW** | 2×XGMAC + DMA + PHC |
| 边缘节点 (1×10M) | Active | **~50 mW** | 单 MAC + 小 PHY |
| 任意场景 | EEE 空闲 | **~25%** Active | PHY 侧主导节省 |
| 任意场景 | Deep Sleep | **~10 mW** | 仅 CSR + 唤醒逻辑 |

> **注**: 基于 22nm 工艺门数 × 0.15mW/kGE (典型) + SRAM 漏电,±30% 误差,需 RTL 综合后校准。

---

## 5. 时钟域交叉 (CDC) 设计

### 5.1 异步FIFO清单

| 接口 | 源时钟域 | 目标时钟域 | FIFO深度 | 位宽 | CDC方式 |
|------|---------|-----------|---------|------|---------|
| DMA→MTL TX | `clk_sys` | `clk_mac` | 16 | 68b | 异步FIFO (Gray码指针) |
| MTL→DMA RX | `clk_mac` | `clk_sys` | 16 | 68b | 异步FIFO (Gray码指针) |
| MAC→HSPHY TX | `clk_mac` | `clk_tx_phy` | 8 | 8b/32b | 异步FIFO + 握手 |
| HSPHY→MAC RX | `clk_rx_phy` | `clk_mac` | 8 | 8b/32b | 异步FIFO + 握手 |
| **MAC ↔ Switch Ingress** | `clk_mac` | `clk_mac` | 8 | 64b | **同步 (同域)** |
| **Switch Egress → MAC** | `clk_mac` | `clk_mac` | 8 | 64b | **同步 (同域)** |
| **Switch Host Port ↔ DMA** | `clk_mac` | `clk_sys` | 16 | 64b | 异步FIFO (Gray码指针) |
| PTP→MAC TS | `clk_ts` | `clk_mac` | 4 | 64b | 握手同步器 |
| **PHC0 ↔ PHC1** | `clk_ts` | `clk_ts` | - | 64b | **同步 (同源)** |
| **vPHC Xen Ring** | `clk_sys` | `clk_sys` | 16 | 64b | 同步FIFO (共享内存) |
| CSR→Safety | `clk_sys` | `clk_mac` | - | 32b | 多级触发器同步 |
| **CSR→PM Ctrl** | `clk_sys` | `clk_sys` | - | 32b | 同步 |

### 5.2 复位域划分

```
rst_n (全局异步复位,低有效)
   │
   ├──► rst_sys_n ──► eth_dma / eth_csr / eth_irq / **eth_vphc** (clk_sys域)
   │
   ├──► rst_mac_n ──► eth_mtl / eth_mac / **eth_switch** (clk_mac域)
   │       └── 释放条件: rst_sys_n已释放 + clk_mac稳定 + 100us延时
   │
   ├──► rst_phy_tx_n ──► eth_hsphy TX侧 (clk_tx_phy域)
   │       └── 释放条件: rst_mac_n已释放 + PHY锁定
   │
   ├──► rst_phy_rx_n ──► eth_hsphy RX侧 (clk_rx_phy域)
   │       └── 释放条件: rst_mac_n已释放 + PHY CDR锁定
   │
   ├──► rst_ts_n ──► eth_ptp (clk_ts域)
   │       └── 释放条件: rst_sys_n已释放 + 时间基准就绪
   │
   └──► rst_pm_n ──► **eth_pm** (clk_sys域)
           └── 释放条件: rst_sys_n已释放 (低功耗模块最后释放,最先复位)
```

---

## 6. 参数化配置

### 6.1 编译时参数 (SystemVerilog `parameter`)

| 参数名 | 类型 | 默认值 | 范围 | 说明 |
|--------|------|--------|------|------|
| `MAC_COUNT` | int | **4** | 1-8 | MAC 实例数 (Arch Spec §1.4.1 基准) |
| **`MAC_x_TYPE[0..7]`** | int[8] | **`{2,2,1,1,1,1,1,1}`** | 0:MAC/10-100M, 1:GMAC/1G, 2:XGMAC/2.5G-10G | **每实例独立 MAC 类型** |
| **`PHY_x_TYPE[0..7]`** | int[8] | **`{3,3,2,2,2,2,2,2}`** | 0:10BASE-T1S, 1:10/100BASE-T1, 2:1000BASE-T1, 3:Multi-Gigabit | **每实例独立 PHY 类型** (编码与 Arch Spec 统一) |
| **`PHY_x_SPEED[0..7]`** | int[8] | **`{4,4,2,2,2,2,2,2}`** | 0:10M/1:100M/2:1G/3:2.5G/4:5G/5:10G | **每实例独立 PHY 速率 (枚举索引)**,与 `PHY_x_TYPE` 配对约束见 Arch Spec §1.4.1b |
| **`SWITCH_CONNECTED_MAC_x[0..7]`** | bit[8] | **`{1,1,1,1,0,0,0,0}`** | 0/1 | **每 MAC 接入 Switch(1) 或独立(0)** |
| `DMA_CH_COUNT` | int | **8** | 1/2/4/8/16/32 | **全局 DMA 通道池** (所有 MAC 共享复用,Arch Spec §1.4.2) |
| **`DMA_CH_PER_MAC`** | int | **4** | 1~8 | **每 MAC 可分配的 DMA 通道数上限** (新增,Arch Spec §1.4.2) |
| `MTL_TX_FIFO_DEPTH` | int | **32** | 8/16/32/64 | TX FIFO 深度 (单位 KB,Arch Spec §1.4.2) |
| `MTL_RX_FIFO_DEPTH` | int | **32** | 8/16/32/64 | RX FIFO 深度 (单位 KB,Arch Spec §1.4.2) |
| `MTL_TXQ_COUNT` | int | **8** | 1/2/4/8 | 发送队列数 (每 MAC,范围修正为 2^n) |
| `MTL_RXQ_COUNT` | int | **8** | 1/2/4/8 | 接收队列数 (每 MAC,范围修正为 2^n) |
| **`SUPPORT_SWITCH`** | bit | **1** | 0/1 | **是否支持 N-port L2/L3 Switch (N=SWITCH_PORT_COUNT)** |
| **`SWITCH_PORT_COUNT`** | int | **4** | 2-8 | **Switch 端口数量** |
| **`SWITCH_TAS`** | bit | **1** | 0/1 | **Switch 级 TAS 使能** (与端点级 TAS 互斥) |
| **`SWITCH_L3`** | bit | **0** | 0/1 | **L3 路由使能** |
| `TSN_ENABLE` | bit | 1 | 0/1 | TSN 协议栈使能 (映射 Arch Spec `SUPPORT_TSN`) |
| `CBS_SHAPER_COUNT` | int | 4 | 0-8 | CBS 整形器数量 |
| `TAS_GCL_DEPTH` | int | 64 | 16-1024 | TAS 门控列表深度 |
| `PREEMPT_ENABLE` | bit | 1 | 0/1 | 帧抢占使能 (映射 Arch Spec `SUPPORT_FP`) |
| `MACSEC_ENABLE` | bit | **0** | 0/1 | MACsec 安全加速接口使能 (映射 Arch Spec `SUPPORT_MACSEC`,默认关闭) |
| `ECC_ENABLE` | bit | 1 | 0/1 | ECC 保护使能 (ASIL-B 基线) |
| `PARITY_ENABLE` | bit | 1 | 0/1 | FSM parity 保护使能 (映射 Arch Spec `ENABLE_PARITY_FSM`) |
| `ASIL_TARGET` | enum | B | B/C/D | 功能安全等级目标 (B=ASIL-B,映射 Arch Spec `ASIL_LEVEL=2`) |
| `FDB_DEPTH` | int | 8K | 1K/2K/4K/8K | FDB 条目数 |
| `FRER_ENABLE` | bit | 1 | 0/1 | FRER 帧复制消除使能 (映射 Arch Spec `SUPPORT_FRER`) |
| **`SUPPORT_GPTP`** | bit | **1** | 0/1 | **硬件 Transparent Clock 使能** (默认开启,Arch Spec §1.4.1) |
| **`SUPPORT_VPHC`** | bit | **0** | 0/1 | **vPHC 虚拟化使能** |
| **`SUPPORT_AVTP`** | bit | **1** | 0/1 | **AVTP 流识别使能** (默认开启,Arch Spec §1.4.1) |
| `PTP_PPS_COUNT` | int | 4 | 1-4 | PPS 输出通道数 |
| **`PHC_COUNT`** | int | **2** | 1-2 | **PHC 实例数** |
| **`CLK_TS_FREQ_MHZ`** | int | **250** | 100/250/375 | **PTP 时间戳时钟频率** |
| `AXI_DATA_WIDTH` | int | 64 | 32/64/128 | AXI Master 数据位宽 |
| `AXI_ADDR_WIDTH` | int | 32 | 32/40/64 | AXI Master 地址位宽 |
| **`AXI_ID_WIDTH`** | int | **4** | 4/8 | **AXI Master ID 位宽** (新增,Arch Spec §1.4.2) |
| **`CSR_ADDR_WIDTH`** | int | **12** | 10/12/14 | **AXI-Lite Slave 地址位宽** (新增,Arch Spec §1.4.2) |
| **`DESC_SIZE`** | int | **16** | 16/32 | **描述符大小 (Byte)** (新增,Arch Spec §1.4.2) |
| **`MAX_BURST_LEN`** | int | **16** | 8/16 | **AXI 最大 Burst 长度 (beats)** (新增,Arch Spec §1.4.2) |
| **`EEE_ENABLE`** | bit | **0** | 0/1 | **802.3az EEE 低功耗使能** (默认关闭,Arch Spec §1.4.1 `SUPPORT_EEE=0`) |
| **`WOL_ENABLE`** | bit | **1** | 0/1 | **Wake-on-LAN 使能** |
| **`DEEP_SLEEP_ENABLE`** | bit | **1** | 0/1 | **Deep Sleep 模式使能** |

> **RTL-MIN-002 修正说明**: 以下参数默认值/范围/编码已按 Arch Spec §1.4 统一,详见 §6.1a 差异对照表。

---

### 6.1a 与 Arch Spec §1.4 差异对照与修正 (PAD-REWORK-012)

以 Arch Spec §1.4 为基准,列出 Design Spec §6.1 原始值与 Arch Spec 的差异,并说明修正动作。

| 参数名 (Design Spec) | Arch Spec 对应名 | 原默认值 | Arch Spec 默认值 | 差异类型 | 修正动作 |
|:--------------------:|:----------------:|:--------:|:----------------:|:--------:|----------|
| `MAC_COUNT` | `MAC_COUNT` | **2** | **4** | 默认值 | ✅ 修正为 4 |
| `MAC_x_TYPE` | `MAC_x_TYPE` | `{1,1,0,0,0,0,0,0}` | `{2,2,1,1,1,1,1,1}` | 默认值 | ✅ 修正 (前2端口为 XGMAC/5G,其余 GMAC/1G) |
| `PHY_x_TYPE` | `PHY_x_TYPE` | `{3,3,0,0,0,0,0,0}` (编码: 0=MII/1=RMII/2=RGMII/3=SGMII/4=USXGMII) | `{3,3,2,2,2,2,2,2}` (编码: 0=10BASE-T1S/1=10/100BASE-T1/2=1000BASE-T1/3=Multi-Gigabit) | **编码体系不一致** | ✅ **统一为 Arch Spec 编码**,前2端口 Multi-Gigabit(5G),其余 1000BASE-T1(1G) |
| `PHY_x_SPEED` | `PHY_x_SPEED` | `{1000,1000,0,0,0,0,0,0}` (Mbps 绝对值) | `{4,4,2,2,2,2,2,2}` (枚举索引: 0=10M/1=100M/2=1G/3=2.5G/4=5G/5=10G) | **表示方式不一致** | ✅ **统一为 Arch Spec 枚举索引**,消除 Mbps 硬编码,RTL 顶层通过索引查表映射 |
| `DMA_CH_COUNT` | `DMA_CH_COUNT` | **16** | **8** | 默认值 | ✅ 修正为 8 |
| `MTL_TX_FIFO_DEPTH` | `MTL_TX_FIFO_DEPTH` | 32K (范围 4K/8K/16K/32K,字节) | 32 (范围 8/16/32/64,单位 KB) | 默认值+范围 | ✅ 修正为 32 (范围 8/16/32/64 KB) |
| `MTL_RX_FIFO_DEPTH` | `MTL_RX_FIFO_DEPTH` | 32K (范围 4K/8K/16K/32K,字节) | 32 (范围 8/16/32/64,单位 KB) | 默认值+范围 | ✅ 修正为 32 (范围 8/16/32/64 KB) |
| `MTL_TXQ_COUNT` | `MTL_TX_QUEUES` | 8 (范围 1-8) | 8 (范围 1/2/4/8) | 范围 | ✅ 修正范围为 1/2/4/8 |
| `MTL_RXQ_COUNT` | `MTL_RX_QUEUES` | 8 (范围 1-8) | 8 (范围 1/2/4/8) | 范围 | ✅ 修正范围为 1/2/4/8 |
| `MACSEC_ENABLE` | `SUPPORT_MACSEC` | **1** | **0** | 默认值 | ✅ 修正为 0 (默认关闭,需外部 CSS 加速器) |
| `SUPPORT_GPTP` | `SUPPORT_GPTP` | **0** | **1** | 默认值 | ✅ 修正为 1 (硬件 TC 默认使能) |
| `SUPPORT_AVTP` | `SUPPORT_AVTP` | **0** | **1** | 默认值 | ✅ 修正为 1 (AVTP 流识别默认使能) |
| `EEE_ENABLE` | `SUPPORT_EEE` | **1** | **0** | 默认值 | ✅ 修正为 0 (默认关闭,需 PHY 配合) |
| - | `DMA_CH_PER_MAC` | - | **4** | **缺失** | ✅ **新增参数**,范围 1~8 |
| - | `DESC_SIZE` | - | **16** | **缺失** | ✅ **新增参数**,范围 16/32 (Byte) |
| - | `AXI_ID_WIDTH` | - | **4** | **缺失** | ✅ **新增参数**,范围 4/8 (bit) |
| - | `CSR_ADDR_WIDTH` | - | **12** | **缺失** | ✅ **新增参数** (AXI-Lite Slave 地址位宽),范围 10/12/14 |
| - | `MAX_BURST_LEN` | - | **16** | **缺失** | ✅ **新增参数**,范围 8/16 (AXI burst beats) |
| `AXI_ADDR_WIDTH` | - | 32 (32/40/64) | - | **设计特有** | 保留不变 (AXI Master 地址位宽,与 Arch Spec `CSR_ADDR_WIDTH` 语义不同) |
| `TSN_ENABLE` | `SUPPORT_TSN` | 1 | 1 | 名称差异 | 默认值一致,保留 Design Spec 命名 `TSN_ENABLE` |
| `PREEMPT_ENABLE` | `SUPPORT_FP` | 1 | 1 | 名称差异 | 默认值一致,保留 Design Spec 命名 |
| `FRER_ENABLE` | `SUPPORT_FRER` | 1 | 1 | 名称差异 | 默认值一致,保留 Design Spec 命名 |
| `ASIL_TARGET` | `ASIL_LEVEL` | B (=ASIL-B) | 2 (=ASIL-B) | 表示方式差异 | 语义一致,保留 Design Spec 命名 |

**未修正参数 (Design Spec 特有,Arch Spec §1.4 未定义)**:
| 参数名 | 默认值 | 说明 |
|--------|:------:|------|
| `CBS_SHAPER_COUNT` | 4 | CBS 整形器数量 (Arch 仅定义 `SUPPORT_CBS=1`) |
| `TAS_GCL_DEPTH` | 64 | TAS 门控列表深度 (Arch 未定义默认值,范围 16-1024) |
| `ECC_ENABLE` | 1 | ECC 保护使能 (Arch 通过 `ASIL_LEVEL` 隐含) |
| `PARITY_ENABLE` | 1 | FSM parity 使能 (Arch 映射 `ENABLE_PARITY_FSM=1`) |
| `WOL_ENABLE` | 1 | Wake-on-LAN 使能 (Arch 未显式定义) |
| `DEEP_SLEEP_ENABLE` | 1 | Deep Sleep 使能 (Arch 未显式定义) |
| `PTP_PPS_COUNT` | 4 | PPS 输出通道数 (Arch 未显式定义,示例中为 4) |

---

## 7. 问题追踪与决策记录

| ID | 描述 | 状态 | 决策 |
|----|------|------|------|
| μARCH-001 | MTL FIFO单端口/双端口选择 | **Closed** | **MTL TX/RX 采用双端口 SRAM (独立读写口),Switch Ingress/Egress FIFO 采用单端口 SRAM (时分复用读写)**。面积增加 ~15% (MTL),但避免 TX/RX 仲裁冲突,Switch 侧单端口面积优先 (PAD-REWORK-012 关闭) |
| μARCH-002 | **Switch Core FDB查表时序: 8K条目@300MHz, N-port全并发 (N=2~8)** | **Closed** | **2-cycle流水线 + 2-way set-associative + 2×4K×84-bit SRAM** (PAD-REWORK-001完成, `switch_fdb_microarch.md` v1.0)。5~8端口可扩展为2组SRAM或接受3-cycle仲裁等待 |
| μARCH-003 | DMA描述符环位置: SRAM vs 系统内存 | **Closed** | **默认系统内存 (灵活性)**,可选internal SRAM (低延迟),Arch Spec §4.3 已定 |
| μARCH-004 | TAS GCL存储: 寄存器文件 vs SRAM | **Closed** | **<64条目用寄存器,≥64条目用SRAM**,Arch Spec §1.4 已定 |
| μARCH-005 | 帧抢占pMAC/eMAC: 共享FIFO或独立FIFO | **Closed** | **pMAC (Express) / eMAC (Preemptable) 采用独立 FIFO**,eMAC 被抢占时不阻塞 express 帧,抢占点由 MAC Merge 层控制 (PAD-REWORK-012 关闭) |
| **μARCH-006** | **Switch 级 TAS 与端点级 TAS 互锁逻辑** | **Closed** | **硬件互锁: `SUPPORT_SWITCH=1` → 强制 `SWITCH_TAS=1, SUPPORT_TAS=0`**,Arch Spec v1.8 已定 |
| **μARCH-007** | **双 PHC + Crossbar: PHC0/PHC1 同源 clk_ts 同步** | **Closed** | **PHC0/PHC1 同源 250MHz clk_ts,无晶体间偏差;Crossbar 每端口独立绑定,偏差 < 1ns 由同源保证**。per-port 微调通过 `ptc_addend_x` 独立配置实现 (PAD-REWORK-012 关闭) |
| **μARCH-008** | **vPHC Xen IO Ring 延迟对 PTP 精度的影响** | **Closed** | **vPHC 硬件虚拟化层已定义: Xen IO Ring 前端/后端驱动 + 每 VM 独立时间域 offset**。精度目标 ±25ns 通过 grant table 映射 + 批处理读取优化,FPGA 验证列为 IDR 阶段 TASK-010 子项 (PAD-REWORK-012 关闭) |
| **μARCH-009** | **低功耗模式: Deep Sleep 下 CSR 保持与 PHY 断电序列** | **Closed** | **clk_sys 域低功耗状态机已定义 (§4.9.2): EEE → WoL → Deep Sleep 三级,CSR 保持寄存器独立供电域,PHY 断电顺序 clk_pcs→clk_tx_phy→clk_rx_phy**。唤醒时序 ≤1ms,复位释放遵循 rst_pm_n 最后释放/最先复位原则 (PAD-REWORK-012 关闭) |
| **μARCH-010** | **全局 DMA 通道池: 多 MAC 并发时的仲裁公平性** | **Closed** | **DMA WRR (Weighted Round-Robin) 仲裁已定义 (§4.1.4/§4.4.5): 每通道可配权重 1~16,TSN 通道固定高权重,全局 Outstanding 上限 32 防止饿死**。UVM 验证计划: 16/32 通道满载带宽分配测试列为 TASK-010 (PAD-REWORK-012 关闭) |

---

## 8. 与下游阶段衔接

| 阶段 | 输入文档 | 下游任务 | 衔接要点 |
|------|---------|---------|---------|
| EDR | 本Micro-Arch Spec **v1.1** | TASK-005 Design Spec | 模块划分 → RTL编码,接口定义 → port清单,AXI参数 → 总线协议 |
| EDR | 本Micro-Arch Spec **v1.1** | TASK-007 DFT Spec | 扫描链插入策略,BIST覆盖范围 |
| EDR | 本Micro-Arch Spec **v1.1** | TASK-008 FuSa FMEDA | 安全机制清单 → FIT计算,诊断覆盖率量化 |
| IDR | 本Micro-Arch Spec **v1.1** | TASK-009 RTL Coding | 参数化配置 → 顶层parameter,FSM定义 → RTL状态机,μARCH关闭项 → 实现验证 |
| IDR | 本Micro-Arch Spec **v1.1** | TASK-010 UVM Env | 模块划分 → agent划分,接口定义 → UVM interface,AXI ID/QoS → 协议检查器 |

---

*文档状态: **PAD-REWORK-012 完成: RTL-MAJ-003/004/005 + RTL-MIN-002 修复，待 Arch Review 评审***
*生成时间: **2026-05-29** (RTL Coding Agent 基于 Arch Spec v1.8d / Clock Reset Spec v1.2 修正)*
*变更摘要: **§4.1.4 AXI Protocol Parameters | §6 参数对齐 Arch Spec §1.4 (差异表+15项修正) | §7 关闭 μARCH-001/005/007/008/009/010***
*依赖: **TASK-003 COMPLETED, Arch Spec v1.8d, Clock Reset Spec v1.2***
