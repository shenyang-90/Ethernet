# Ethernet IP Interface Specification

> **文档名称**: Ethernet IP Interface Specification  
> **版本**: v1.1  
> **日期**: 2026-05-22  
> **作者**: Arch Agent  
> **评审状态**: Draft  
> **变更**: 新增 Security IF、EEE LPI、半双工控制、vPHC 硬件接口；更新 AXI4 QoS/ID/outstanding

---

## 1. 接口概述

### 1.1 接口列表

| 接口名称 | 类型 | 位宽 | 方向 | 所属模块 | 说明 |
|----------|------|------|------|----------|------|
| `AXI4_MASTER` | AXI4 | 64-bit | Master | DMA Engine | 系统内存访问 |
| `AXI4_LITE_SLAVE` | AXI4-Lite | 32-bit | Slave | CSR 寄存器 | 配置接口 |
| `RGMII` | 并行 | 12-pin | In/Out | HSPHY | 10/100/1000M 并行接口 |
| `SGMII` | 串行 | 2-pin (差分) | In/Out | HSPHY | 100M/1G/2.5G/5G 串行接口 |
| `USXGMII` | 串行 | 2-pin (差分) | In/Out | HSPHY | 2.5G/5G/10G 扩展串行接口 |
| `MII` | 并行 | 18-pin | In/Out | HSPHY | 10/100M 标准接口 |
| `RMII` | 并行 | 10-pin | In/Out | HSPHY | 10/100M 简化接口 |
| `PPS` | 脉冲 | 1-bit | Out | PTP/Timestamp | 秒脉冲输出 |
| `INTERRUPT` | 电平 | 1-bit | Out | DMA Engine | 中断输出 |
| `SMU_ALERT` | 电平 | 4-bit | Out | Safety Monitor | 安全报警 |
| `MDIO` | 串行 | 2-pin | Master | HSPHY | PHY 寄存器管理 |
| **SECURITY_ACCEL** | **并行** | **128-bit** | **In/Out** | **Security Wrapper** | **IPsec/SecOC/D-TLS/MACsec 封装卸载** |
| **EEE_LPI** | **控制** | **6-pin** | **In/Out** | **HSPHY** | **802.3az 低功耗握手** |
| **vPHC** | **CSR** | **32-bit** | **Slave** | **vPHC** | **虚拟 PHC VM 时间域接口** |

### 1.2 接口分类

```
+==================================================================+
|                        接口分类图                                 |
+==================================================================+
|                                                                    |
|  系统接口 (AXI)                                                   |
|  +-- AXI4_MASTER (64-bit) -- 数据面                              |
|  +-- AXI4_LITE_SLAVE (32-bit) -- 控制面                          |
|                                                                    |
|  PHY 接口                                                         |
|  +-- RGMII (10/100/1000M)                                         |
|  +-- SGMII (100M~5G)                                              |
|  +-- USXGMII (2.5G~10G)                                           |
|  +-- MII/RMII (10/100M)                                           |
|  +-- MDIO (PHY 管理)                                              |
|  +-- EEE_LPI (低功耗握手)                                         |
|  +-- Half-Duplex CRS/COL (10/100M)                               |
|                                                                    |
|  时钟/复位接口                                                     |
|  +-- clk_sys, clk_mac, clk_tx_phy, clk_rx_phy, clk_ts, clk_pcs    |
|  +-- clk_crs_cd (半双工载波/冲突域)                               |
|  +-- rst_n, rst_dma, rst_mac, rst_phy, rst_ts                     |
|                                                                    |
|  外部同步/中断接口                                                 |
|  +-- PPS (4 路输出)                                               |
|  +-- vPHC (虚拟时间域，per-VM CSR)                                |
|  +-- INTERRUPT (每通道 + 汇总)                                    |
|  +-- SMU_ALERT (安全报警)                                         |
|                                                                    |
|  安全加速器接口                                                    |
|  +-- SECURITY_ACCEL (MAC ↔ CSS/HSE)                               |
|                                                                    |
+==================================================================+
```

---

## 2. AXI4 Master 接口 (数据面)

### 2.1 接口信号

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `m_axi_awid` | Output | 4-bit | 写地址 ID (按通道分配，见 §2.3) |
| `m_axi_awaddr` | Output | 64-bit | 写地址 |
| `m_axi_awlen` | Output | 8-bit | 突发长度 (AXI: len+1) |
| `m_axi_awsize` | Output | 3-bit | 突发大小 (0=1B, 3=8B for 64-bit) |
| `m_axi_awburst` | Output | 2-bit | 突发类型 (INCR/WRAP/FIXED) |
| `m_axi_awqos` | Output | 4-bit | 写 QoS (优先级: CH0=0xF, CH7=0x8, PTP=0x4) |
| `m_axi_awvalid` | Output | 1-bit | 写地址有效 |
| `m_axi_awready` | Input | 1-bit | 写地址就绪 |
| `m_axi_wdata` | Output | 64-bit | 写数据 |
| `m_axi_wstrb` | Output | 8-bit | 写字节选通 |
| `m_axi_wlast` | Output | 1-bit | 写数据最后拍 |
| `m_axi_wvalid` | Output | 1-bit | 写数据有效 |
| `m_axi_wready` | Input | 1-bit | 写数据就绪 |
| `m_axi_bid` | Input | 4-bit | 写响应 ID |
| `m_axi_bresp` | Input | 2-bit | 写响应 (OKAY/EXOKAY/SLVERR/DECERR) |
| `m_axi_bvalid` | Input | 1-bit | 写响应有效 |
| `m_axi_bready` | Output | 1-bit | 写响应就绪 |
| `m_axi_arid` | Output | 4-bit | 读地址 ID (按通道分配，见 §2.3) |
| `m_axi_araddr` | Output | 64-bit | 读地址 |
| `m_axi_arlen` | Output | 8-bit | 突发长度 |
| `m_axi_arsize` | Output | 3-bit | 突发大小 |
| `m_axi_arburst` | Output | 2-bit | 突发类型 |
| `m_axi_arqos` | Output | 4-bit | 读 QoS (优先级: CH0=0xF, CH7=0x8, PTP=0x4) |
| `m_axi_arvalid` | Output | 1-bit | 读地址有效 |
| `m_axi_arready` | Input | 1-bit | 读地址就绪 |
| `m_axi_rid` | Input | 4-bit | 读数据 ID |
| `m_axi_rdata` | Input | 64-bit | 读数据 |
| `m_axi_rresp` | Input | 2-bit | 读响应 |
| `m_axi_rlast` | Input | 1-bit | 读数据最后拍 |
| `m_axi_rvalid` | Input | 1-bit | 读数据有效 |
| `m_axi_rready` | Output | 1-bit | 读数据就绪 |

### 2.2 时序要求

| 参数 | 最小值 | 典型值 | 最大值 | 单位 |
|------|--------|--------|--------|------|
| `T_awvalid_to_awready` | — | 1 | 4 | clk_sys cycles |
| `T_arvalid_to_arready` | — | 1 | 4 | clk_sys cycles |
| `T_wvalid_to_wready` | — | 1 | 2 | clk_sys cycles |
| `Burst length (PBL)` | 4 | 32 | 256 | beats |
| `Outstanding transactions (WR)` | 2 | 4 | 8 | 每通道 |
| `Outstanding transactions (RD)` | 2 | 4 | 8 | 每通道 |
| `QoS 传播延迟` | — | 0 | 1 | clk_sys cycle |

### 2.3 ID 分配策略

每 DMA 通道独立 AXI ID，RX 与 TX 分离，支持乱序完成识别：

| AXI ID | 通道/用途 | 优先级 (QoS) | 说明 |
|--------|----------|:------------:|------|
| `0x0` | CH0 TX | 0xF (最高) | 队列 0 发送 |
| `0x1` | CH0 RX | 0xF | 队列 0 接收 |
| `0x2` | CH1 TX | 0xE | 队列 1 发送 |
| `0x3` | CH1 RX | 0xE | 队列 1 接收 |
| `0x4` | CH2 TX | 0xD | 队列 2 发送 |
| `0x5` | CH2 RX | 0xD | 队列 2 接收 |
| `0x6` | CH3 TX | 0xC | 队列 3 发送 |
| `0x7` | CH3 RX | 0xC | 队列 3 接收 |
| `0x8` | CH4 TX | 0xB | 队列 4 发送 |
| `0x9` | CH4 RX | 0xB | 队列 4 接收 |
| `0xA` | CH5 TX | 0xA | 队列 5 发送 |
| `0xB` | CH5 RX | 0xA | 队列 5 接收 |
| `0xC` | CH6 TX | 0x9 | 队列 6 发送 |
| `0xD` | CH6 RX | 0x9 | 队列 6 接收 |
| `0xE` | CH7 TX | 0x8 | 队列 7 发送 |
| `0xF` | CH7 RX / PTP | 0x8 | 队列 7 接收 / PTP 描述符 |

> **Out-of-Order 支持**: AXI ID 独立使能每通道 TX/RX 乱序完成。同一 ID 内事务按顺序完成。  
> **ID 扩展**: 若 `DMA_CH_POOL=16` 或 `32`，高位扩展至 `m_axi_awid[5:0]` / `m_axi_arid[5:0]`。

### 2.4 地址映射

| 区域 | 地址范围 | 用途 | 访问属性 |
|------|----------|------|----------|
| `TX_BUFFER` | 0x7000_0000 ~ 0x700F_FFFF | TX 帧数据缓冲区 | RW, Cacheable |
| `RX_BUFFER` | 0x7010_0000 ~ 0x701F_FFFF | RX 帧数据缓冲区 | RW, Cacheable |
| `TX_DESC` | 0x7020_0000 ~ 0x7020_7FFF | TX 描述符环 | RW, Non-cacheable |
| `RX_DESC` | 0x7020_8000 ~ 0x7020_FFFF | RX 描述符环 | RW, Non-cacheable |
| `PTP_DESC` | 0x7021_0000 ~ 0x7021_3FFF | PTP 上下文描述符 | RW, Non-cacheable |

---

## 3. AXI4-Lite Slave 接口 (控制面 / CSR)

### 3.1 接口信号

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `s_axi_aclk` | Input | 1-bit | CSR 时钟 (clk_sys) |
| `s_axi_aresetn` | Input | 1-bit | CSR 复位 (低有效) |
| `s_axi_awaddr` | Input | 32-bit | 写地址 |
| `s_axi_awprot` | Input | 3-bit | 写保护 |
| `s_axi_awvalid` | Input | 1-bit | 写地址有效 |
| `s_axi_awready` | Output | 1-bit | 写地址就绪 |
| `s_axi_wdata` | Input | 32-bit | 写数据 |
| `s_axi_wstrb` | Input | 4-bit | 写字节选通 |
| `s_axi_wvalid` | Input | 1-bit | 写数据有效 |
| `s_axi_wready` | Output | 1-bit | 写数据就绪 |
| `s_axi_bresp` | Output | 2-bit | 写响应 |
| `s_axi_bvalid` | Output | 1-bit | 写响应有效 |
| `s_axi_bready` | Input | 1-bit | 写响应就绪 |
| `s_axi_araddr` | Input | 32-bit | 读地址 |
| `s_axi_arprot` | Input | 3-bit | 读保护 |
| `s_axi_arvalid` | Input | 1-bit | 读地址有效 |
| `s_axi_arready` | Output | 1-bit | 读地址就绪 |
| `s_axi_rdata` | Output | 32-bit | 读数据 |
| `s_axi_rresp` | Output | 2-bit | 读响应 |
| `s_axi_rvalid` | Output | 1-bit | 读数据有效 |
| `s_axi_rready` | Input | 1-bit | 读数据就绪 |

### 3.2 并发访问与 Outstanding

| 参数 | 最小值 | 典型值 | 最大值 | 说明 |
|------|--------|--------|--------|------|
| `Outstanding write` | 1 | 1 | 2 | AXI-Lite 写事务缓冲 |
| `Outstanding read` | 1 | 1 | 2 | AXI-Lite 读事务缓冲 |
| `Write-to-read switch` | — | 2 | 4 | clk_sys cycles |
| `Read latency` | — | 3 | 8 | clk_sys cycles |

> **地址解码**: `s_axi_awaddr[31:16]` 高 16-bit 区分模块区域 (MAC/MTL/DMA/Switch/Security/vPHC)。  
> **VM 隔离**: vPHC 区域通过 `AWID/ARID` 高 4-bit 提取 `VM_ID`，非法访问触发 `vphc_access_violation_irq`。

### 3.3 寄存器地址映射

| 地址偏移 | 寄存器名称 | 访问 | 说明 |
|----------|-----------|------|------|
| `0x0000` | `MAC_Configuration` | RW | MAC 全局配置 |
| `0x0004` | `MAC_Extended_Configuration` | RW | MAC 扩展配置 |
| `0x0008` | `MAC_Packet_Filter` | RW | 帧过滤控制 |
| `0x0010` | `MAC_Watchdog_Timeout` | RW | 看门狗超时 |
| `0x0040` | `MAC_VLAN_Tag` | RW | VLAN 标签控制 |
| `0x0044` | `MAC_VLAN_Tag_Data` | RW | VLAN 标签数据 |
| `0x00D0` | `MAC_Timestamp_Control` | RW | 时间戳控制 |
| `0x00D8` | `MAC_Sub_Second_Increment` | RW | 子秒增量 |
| `0x00DC` | `MAC_System_Time_Seconds` | RO | 系统时间秒 |
| `0x00E0` | `MAC_System_Time_Nanoseconds` | RO | 系统时间纳秒 |
| `0x00E4` | `MAC_Timestamp_Addend` | RW | Addend 精调值 |
| `0x0100` | `MAC_PPS_Control` | RW | PPS 控制 |
| `0x0200` | `MTL_Operation_Mode` | RW | MTL 操作模式 |
| `0x0300` | `MTL_TxQ0_Operation_Mode` | RW | TX 队列0 模式 |
| `0x0304` | `MTL_TxQ0_Underflow` | RO | TX 队列0 下溢 |
| `0x0310` | `MTL_RxQ0_Operation_Mode` | RW | RX 队列0 模式 |
| `0x0400` | `MTL_EST_Control` | RW | TAS/EST 控制 |
| `0x0404` | `MTL_EST_Status` | RO | TAS/EST 状态 |
| `0x0500` | `MTL_TC0_CBS_Control` | RW | CBS 控制 |
| `0x0504` | `MTL_TC0_CBS_IdleSlope` | RW | CBS idleSlope |
| `0x0508` | `MTL_TC0_CBS_SendSlope` | RW | CBS sendSlope |
| `0x050C` | `MTL_TC0_CBS_HiCredit` | RW | CBS hiCredit |
| `0x0510` | `MTL_TC0_CBS_LoCredit` | RW | CBS loCredit |
| `0x1000` | `DMA_Mode` | RW | DMA 全局模式 |
| `0x1004` | `DMA_SysBus_Mode` | RW | 系统总线模式 |
| `0x1100` | `DMA_CH0_Control` | RW | 通道0 控制 |
| `0x1104` | `DMA_CH0_TxDesc_List_Addr` | RW | 通道0 TX 描述符基址 |
| `0x1108` | `DMA_CH0_RxDesc_List_Addr` | RW | 通道0 RX 描述符基址 |
| `0x110C` | `DMA_CH0_TxDesc_Tail_Ptr` | RW | 通道0 TX 尾指针 |
| `0x1110` | `DMA_CH0_RxDesc_Tail_Ptr` | RW | 通道0 RX 尾指针 |
| `0x1114` | `DMA_CH0_TxDesc_Ring_Len` | RW | 通道0 TX 环长度 |
| `0x1118` | `DMA_CH0_RxDesc_Ring_Len` | RW | 通道0 RX 环长度 |
| `0x111C` | `DMA_CH0_Interrupt_Enable` | RW | 通道0 中断使能 |
| `0x1120` | `DMA_CH0_Rx_Interrupt_Watchdog` | RW | 通道0 RX 看门狗 |
| `0x1124` | `DMA_CH0_Status` | RW1C | 通道0 状态 |
| `0x1300` | `DMA_CH1_Control` | RW | 通道1 控制 (同上结构) |
| ... | ... | ... | 通道 2~7 寄存器组 |
| `0x3000` | `Switch_Control` | RW | Switch 控制 |
| `0x3004` | `Switch_FDB_Table` | RW | 交换转发表 |
| `0x3800` | `Security_Control` | RW | 安全加速器全局控制 |
| `0x3900` | `EEE_Control` | RW | EEE LPI 控制 |
| `0xF000` | `Safety_ECC_Status` | RO | ECC 状态 |
| `0xF004` | `Safety_FSM_Parity` | RO | FSM 奇偶校验状态 |
| `0xF008` | `Safety_Timeout_Status` | RO | 超时状态 |
| `0xF010` | `Safety_Interrupt_Mask` | RW | 安全中断掩码 |

> **注**: 寄存器完整列表详见 `Docs/Design/Module_Specs/` 下的各模块详细规格。vPHC 寄存器块位于 `0x1_1000` 紧邻 PHC 寄存器块之后，详见 `Docs/Design/ethernet/vphc_hw_interface.md` §5。

---

## 4. PHY 接口

### 4.1 RGMII 接口 (10/100/1000M)

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `rgmii_tx_clk` | Output | 1-bit | TX 时钟 (2.5/25/125 MHz) |
| `rgmii_txd[3:0]` | Output | 4-bit | TX 数据 |
| `rgmii_tx_ctl` | Output | 1-bit | TX 控制 (含 DDR 有效指示) |
| `rgmii_rx_clk` | Input | 1-bit | RX 时钟 |
| `rgmii_rxd[3:0]` | Input | 4-bit | RX 数据 |
| `rgmii_rx_ctl` | Input | 1-bit | RX 控制 |

**时序要求**: 遵循 RGMII v2.0 规范，TX 时钟-数据偏斜由 HSPHY 内部 DLL 控制，典型精度 138.88 ps。

### 4.2 SGMII 接口 (100M/1G/2.5G/5G)

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `sgmii_tx_p` | Output | 1-bit | TX 差分正 |
| `sgmii_tx_n` | Output | 1-bit | TX 差分负 |
| `sgmii_rx_p` | Input | 1-bit | RX 差分正 |
| `sgmii_rx_n` | Input | 1-bit | RX 差分负 |
| `sgmii_refclk_p` | Input | 1-bit | 参考时钟差分正 (25 MHz) |
| `sgmii_refclk_n` | Input | 1-bit | 参考时钟差分负 |

**速率映射**:
- 100M: 625 Mbps line rate (8b/10b)
- 1G: 1.25 Gbps line rate
- 2.5G: 3.125 Gbps line rate
- 5G: 6.25 Gbps line rate (USXGMII 模式)

**时序要求**: 眼图 ≥ 0.3 UI，抖动 < 0.15 UI (典型 @ 1G)。

### 4.3 MII 接口 (10/100M)

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `mii_tx_clk` | Input | 1-bit | TX 时钟 (2.5/25 MHz) |
| `mii_txd[3:0]` | Output | 4-bit | TX 数据 |
| `mii_tx_en` | Output | 1-bit | TX 使能 |
| `mii_tx_err` | Output | 1-bit | TX 错误 |
| `mii_rx_clk` | Input | 1-bit | RX 时钟 |
| `mii_rxd[3:0]` | Input | 4-bit | RX 数据 |
| `mii_rx_dv` | Input | 1-bit | RX 数据有效 |
| `mii_rx_err` | Input | 1-bit | RX 错误 |
| `mii_col` | Input | 1-bit | 冲突检测 (半双工) |
| `mii_crs` | Input | 1-bit | 载波侦听 (半双工) |

**时序要求**: 遵循 IEEE 802.3 Clause 22，时钟-数据建立时间 ≥ 5 ns (典型 10 ns)，保持时间 ≥ 0 ns。

### 4.4 RMII 接口 (10/100M)

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `rmii_ref_clk` | Input | 1-bit | 参考时钟 (50 MHz) |
| `rmii_txd[1:0]` | Output | 2-bit | TX 数据 |
| `rmii_tx_en` | Output | 1-bit | TX 使能 |
| `rmii_rxd[1:0]` | Input | 2-bit | RX 数据 |
| `rmii_crs_dv` | Input | 1-bit | 载波侦听/数据有效 |
| `rmii_rx_err` | Input | 1-bit | RX 错误 |

### 4.5 MDIO 管理接口

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `mdc` | Output | 1-bit | 管理时钟 (≤2.5 MHz) |
| `mdio` | In/Out | 1-bit | 管理数据 (开漏) |

**协议**: IEEE 802.3 Clause 22/45，支持 32 个 PHY 地址，16-bit 寄存器数据。

### 4.6 半双工控制信号 (CRS/COL, 10M/100M)

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `phy_crs` | Input | 1-bit | clk_crs_cd | 载波侦听 (Carrier Sense)，PHY 在半双工模式下驱动 |
| `phy_col` | Input | 1-bit | clk_crs_cd | 冲突检测 (Collision Detect)，PHY 在半双工模式下驱动 |
| `phy_duplex` | Output | 1-bit | clk_mac | 双工模式配置: 0=半双工, 1=全双工 (默认) |

**接口映射**:

| 目标接口 | `phy_crs` 映射 | `phy_col` 映射 | 有效速率 |
|----------|---------------|---------------|----------|
| MII | `mii_crs` | `mii_col` | 10M/100M |
| RMII | `rmii_crs_dv` (CRS 分量) | 无 (RMII 无 COL) | 10M/100M |
| RGMII | `rgmii_rx_ctl` (10/100M 时 CRS 编码) | 无 (RGMII 半双工不支持 COL) | 10M/100M |
| SGMII/USXGMII | 串行编码内嵌 | 串行编码内嵌 | 10M/100M (不常用) |

**时序要求**:

| 参数 | 典型值 | 最大值 | 单位 |
|------|--------|--------|------|
| `T_crs_setup` | 10 | 20 | ns |
| `T_crs_hold` | 0 | 5 | ns |
| `T_col_to_tx_abort` | — | 96 | bit-times |
| `CRS/CD 时钟域频率` | 2.5 / 25 | — | MHz |

> **设计约束**: `PHY_x_DUPLEX=0` 时，MAC TX 状态机使能 CSMA/CD 退避逻辑；`PHY_x_DUPLEX=1` 时，`phy_crs`/`phy_col` 被忽略。

### 4.7 EEE LPI 控制信号 (MAC ↔ PHY, 802.3az)

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `tx_lpi_req` | Output | 1-bit | clk_mac | MAC 请求 TX 方向进入 LPI |
| `tx_lpi_ack` | Input | 1-bit | clk_tx_phy | PHY 确认 TX 已进入 LPI |
| `rx_lpi_ind` | Input | 1-bit | clk_rx_phy | PHY 指示 RX 处于 LPI |
| `lpi_wake_req` | Output | 1-bit | clk_mac | MAC 请求退出 LPI (TX/RX) |
| `lpi_wake_ack` | Input | 1-bit | clk_tx_phy | PHY 确认唤醒完成 |
| `lpi_active` | Input | 1-bit | clk_mac | PHY 汇总 LPI 状态 (经 2-flop 同步) |
| `lpi_timer[15:0]` | Output | 16-bit | clk_mac | LPI 请求维持计时器 (μs 单位, 典型 20μs) |

**LPI 状态转换**:

```
ACTIVE (正常传输)
  |
  | 链路空闲 ≥ lpi_timer
  v
LPI_REQUEST (tx_lpi_req=1)
  |
  | tx_lpi_ack=1
  v
LPI (门控 clk_tx_phy / clk_rx_phy / clk_pcs)
  |
  | lpi_wake_req=1 (新帧到达 / 外部唤醒)
  v
WAKE (恢复时钟, lpi_wake_ack=1)
  |
  | 就绪
  v
ACTIVE
```

**时序要求**:

| 参数 | 典型值 | 最大值 | 单位 | 说明 |
|------|--------|--------|------|------|
| `T_lpi_req_to_ack` | 1 | 10 | μs | PHY 进入 LPI 响应 |
| `T_wake_req_to_ack` | 2 | 10 | μs | PHY 唤醒响应 (典型 4.288 μs @ 1G) |
| `lpi_timer` | 20 | — | μs | LPI 请求阈值 (可配) |
| `T_lpi_quiet` | — | — | — | PHY 决定，MAC 不控制 |

> **使能条件**: `SUPPORT_EEE=1` 且 PHY 支持 802.3az 时启用。默认 `SUPPORT_EEE=0`。

---

## 5. PPS / 时间同步接口

### 5.1 PPS 输出

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `pps[3:0]` | Output | 4-bit | 4 路可编程 PPS 输出 |
| `pps_trig_in` | Input | 1-bit | 外部触发输入 |

**PPS 配置**:
- 频率: 1 Hz (默认), 可编程至 32768 Hz
- 占空比: 可编程 (默认 50%)
- 对齐: 与 gPTP 系统时间秒边界对齐
- 输出模式: 脉冲 / 方波 / 单次触发

### 5.2 时间戳触发

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `ext_ts_trig[1:0]` | Input | 2-bit | 外部时间戳捕获触发 |
| `ext_ts_val[63:0]` | Output | 64-bit | 捕获时间戳值 (可选输出) |

### 5.3 vPHC 硬件接口 (Virtual PHC)

> **使能条件**: `PHC_COUNT=2` 且 `SUPPORT_VPHC=1`。  
> **详细定义**: 见 `Docs/Design/ethernet/vphc_hw_interface.md` §3。

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `vm_id[3:0]` | Input | 4 | clk_sys | 当前访问 VM 标识 |
| `vm_valid` | Input | 1 | clk_sys | VM_ID 有效指示 |
| `phc_sel` | Input | 1 | clk_sys | PHC 选择: 0=PHC0, 1=PHC1 (per-VM 可配) |
| `vphc_csr_addr[11:0]` | Input | 12 | clk_sys | AXI-Lite CSR 地址 |
| `vphc_csr_wdata[31:0]` | Input | 32 | clk_sys | CSR 写数据 |
| `vphc_csr_wr` | Input | 1 | clk_sys | CSR 写使能 |
| `vphc_csr_rd` | Input | 1 | clk_sys | CSR 读使能 |
| `vphc_csr_rdata[31:0]` | Output | 32 | clk_sys | CSR 读数据 |
| `vphc_csr_rvalid` | Output | 1 | clk_sys | CSR 读数据有效 |
| `vphc_csr_ready` | Output | 1 | clk_sys | CSR 接口就绪 |
| `vphc_update_irq` | Output | 1 | clk_sys | 全局 vPHC 时间更新中断 (脉冲) |
| `vphc_vm_irq[15:0]` | Output | 16 | clk_sys | Per-VM 虚拟时间更新中断 |
| `vphc_access_violation_irq` | Output | 1 | clk_sys | VM 访问越权中断 |
| `vphc_pps_out[15:0]` | Output | 16 | clk_ts | Per-VM PPS 输出 (可选) |

**PHC → vPHC 数据通路内部信号**:

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `phc0_sec[31:0]` | Input | 32 | clk_ts | PHC0 当前秒 |
| `phc0_ns[31:0]` | Input | 32 | clk_ts | PHC0 当前纳秒 |
| `phc1_sec[31:0]` | Input | 32 | clk_ts | PHC1 当前秒 |
| `phc1_ns[31:0]` | Input | 32 | clk_ts | PHC1 当前纳秒 |

**时序要求**:

| 参数 | 典型值 | 最大值 | 单位 |
|------|--------|--------|------|
| `T_csr_access` | 3 | 8 | clk_sys cycles |
| `T_vm_virt_time_latency` | 1 | 1 | clk_sys cycle |
| `T_pps_output_jitter` | ±4 | ±8 | ns |
| `vPHC 中断周期` | 1 | — | ms (可配) |

---

## 6. 中断接口

### 6.1 中断信号

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `irq_n` | Output | 1-bit | 低有效中断 (汇总) |
| `irq_vector[15:0]` | Output | 16-bit | 中断向量 (具体见下表) |

### 6.2 中断向量映射

| 位 | 中断源 | 触发条件 |
|----|--------|----------|
| `[0]` | CH0_TX | DMA 通道0 发送完成 |
| `[1]` | CH0_RX | DMA 通道0 接收完成 |
| `[2]` | CH1_TX | DMA 通道1 发送完成 |
| `[3]` | CH1_RX | DMA 通道1 接收完成 |
| `[4]` | CH2_TX | DMA 通道2 发送完成 |
| `[5]` | CH2_RX | DMA 通道2 接收完成 |
| `[6]` | CH3_TX | DMA 通道3 发送完成 |
| `[7]` | CH3_RX | DMA 通道3 接收完成 |
| `[8]` | CH4_TX | DMA 通道4 发送完成 |
| `[9]` | CH4_RX | DMA 通道4 接收完成 |
| `[10]` | CH5_TX | DMA 通道5 发送完成 |
| `[11]` | CH5_RX | DMA 通道5 接收完成 |
| `[12]` | CH6_TX | DMA 通道6 发送完成 |
| `[13]` | CH6_RX | DMA 通道6 接收完成 |
| `[14]` | CH7_TX | DMA 通道7 发送完成 |
| `[15]` | CH7_RX | DMA 通道7 接收完成 |

---

## 7. 安全报警接口

### 7.1 SMU 报警信号

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `smu_alert[3:0]` | Output | 4-bit | 安全报警输出 |

### 7.2 报警映射

| 位 | 报警类型 | 严重程度 | 响应动作 |
|----|----------|----------|----------|
| `[0]` | ECC 可纠正错误 | Warning | 计数 + 中断 |
| `[1]` | ECC 不可纠正错误 | Critical | 通道关闭 + SMU 上报 |
| `[2]` | FSM Parity 错误 | Critical | 安全状态机 + SMU 上报 |
| `[3]` | Timeout / 安全机制失效 | Critical | 模块复位 + SMU 上报 |

---

## 8. 时钟与复位接口

> **详见**: [ethernet_clock_reset_spec.md](ethernet_clock_reset_spec.md)

### 8.1 时钟接口

| 信号名 | 方向 | 频率 | 说明 |
|--------|------|------|------|
| `clk_sys` | Input | **200 MHz** (典型) | 系统总线时钟 |
| `clk_mac` | Input | **250 MHz** (典型) | MAC 核心时钟 |
| `clk_tx_phy` | Input | 2.5/25/125/312.5 MHz | TX PHY 接口时钟 (按速率分档) |
| `clk_rx_phy` | Input | 2.5/25/125/312.5 MHz | RX PHY 接口时钟 (按速率分档) |
| `clk_ts` | Input | **250 MHz** (典型) | PTP 时间戳时钟 |
| `clk_pcs` | Input | 62.5/156.25/312.5/625 MHz | PCS 串行时钟 |
| `clk_crs_cd` | Input | 2.5/25 MHz | 半双工 CRS/CD 时钟域 (由 PHY 提供) |

### 8.2 复位接口

| 信号名 | 方向 | 极性 | 说明 |
|--------|------|------|------|
| `rst_n` | Input | 低有效 | 全局异步复位 |
| `rst_dma_n` | Input | 低有效 | DMA 模块复位 |
| `rst_mac_n` | Input | 低有效 | MAC 模块复位 |
| `rst_phy_n` | Input | 低有效 | PHY 接口复位 |
| `rst_ts_n` | Input | 低有效 | 时间戳模块复位 |
| `rst_switch_n` | Input | 低有效 | Switch 模块复位 |

---

## 9. Security Accelerator 接口 (IPsec/SecOC/D-TLS/MACsec)

> **使能条件**: `SUPPORT_IPSEC=1` / `SUPPORT_SECOC=1` / `SUPPORT_DTLS=1` / `SUPPORT_MACSEC=1`。  
> **实现方式**: 外部安全加速器 (CSS / HSE) 配合，Ethernet IP 提供封装/卸载接口。  
> **参考**: Arch Spec §10.4, ISSUE-004。

### 9.1 接口信号

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `sec_accel_aclk` | Input | 1 | clk_sys | 安全加速器时钟 (与 clk_sys 同源) |
| `sec_accel_aresetn` | Input | 1 | clk_sys | 安全加速器复位 (低有效) |
| `macsec_tx_data[127:0]` | Output | 128 | sec_accel_aclk | MACsec TX 明文数据 → CSS |
| `macsec_tx_valid` | Output | 1 | sec_accel_aclk | MACsec TX 数据有效 |
| `macsec_tx_ready` | Input | 1 | sec_accel_aclk | MACsec TX 就绪 |
| `macsec_rx_data[127:0]` | Input | 128 | sec_accel_aclk | MACsec RX 密文数据 ← CSS |
| `macsec_rx_valid` | Input | 1 | sec_accel_aclk | MACsec RX 数据有效 |
| `macsec_rx_ready` | Output | 1 | sec_accel_aclk | MACsec RX 就绪 |
| `macsec_sa_idx[5:0]` | Output | 6 | sec_accel_aclk | Security Association 索引 |
| `ipsec_offload_req` | Output | 1 | sec_accel_aclk | IPsec ESP/AH 封装/卸载请求 |
| `ipsec_offload_ack` | Input | 1 | sec_accel_aclk | IPsec 加速器就绪 |
| `ipsec_pkt_data[127:0]` | In/Out | 128 | sec_accel_aclk | IPsec 数据通道 (双向) |
| `ipsec_spi[31:0]` | Output | 32 | sec_accel_aclk | Security Parameters Index |
| `secoc_pdu_req` | Output | 1 | sec_accel_aclk | SecOC PDU 认证请求 |
| `secoc_pdu_ack` | Input | 1 | sec_accel_aclk | SecOC 加速器完成 |
| `secoc_pdu_id[15:0]` | Output | 16 | sec_accel_aclk | PDU 标识符 (AUTOSAR SecOC) |
| `secoc_freshness[31:0]` | In/Out | 32 | sec_accel_aclk | Freshness Value (同步/验证) |
| `dtls_crypto_req` | Output | 1 | sec_accel_aclk | D-TLS ChaCha20-Poly1305 请求 |
| `dtls_crypto_ack` | Input | 1 | sec_accel_aclk | D-TLS 加速器就绪 |
| `dtls_aad[127:0]` | Output | 128 | sec_accel_aclk | Additional Authenticated Data |
| `dtls_nonce[95:0]` | Output | 96 | sec_accel_aclk | D-TLS Nonce (IV) |

### 9.2 数据通路

```
[MAC TX] → [Security Wrapper] → [sec_accel_aclk 域]
              |
              +-- MACsec: 直连 CSS (128-bit 数据通道)
              +-- IPsec: 封装请求 → CSS/HSE → 回写 ESP/AH 头
              +-- SecOC: PDU 级认证 → HSE → 回写 MAC (I-PDU)
              +-- D-TLS: Record 层加密 → CSS → 回写密文
              |
           [PHY] ← [加密后帧]

[PHY RX] → [Security Wrapper] → [sec_accel_aclk 域]
              |
              +-- MACsec: CSS 解密 → 明文 → MAC RX
              +-- IPsec: HSE 解封装 → 原始 IP 报文
              +-- SecOC: HSE 验证 Freshness + MAC
              +-- D-TLS: CSS 解密 Record
              |
           [MAC RX] ← [解密后帧]
```

### 9.3 时序要求

| 参数 | 典型值 | 最大值 | 单位 | 说明 |
|------|--------|--------|------|------|
| `T_sec_accel_req_to_ack` | 2 | 10 | clk_sys cycles | 加速器握手延迟 |
| `T_macsec_latency` | — | 500 | ns | MACsec 单帧加解密延迟 (CSS) |
| `T_ipsec_latency` | — | 2 | μs | IPsec 封装/卸载延迟 (HSE) |
| `T_secoc_latency` | — | 1 | μs | SecOC PDU 认证延迟 |
| `sec_accel_aclk` | — | 200 | MHz | 与 clk_sys 同源同频 |

> **带宽覆盖**: TC4x CSS 763 MB/s 覆盖 2×5Gbps MACsec。S32G HSE 512 MB/s 覆盖 1Gbps IPsec/SecOC。

---

## 10. 附录

### 10.1 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v0.1 | 2026-05-02 | Arch Agent | 初始模板创建 |
| v1.0 | 2026-05-11 | Arch Agent | 填充完整接口定义 (AXI/PHY/PPS/Interrupt/SMU/CLK-RST) |
| **v1.1** | **2026-05-22** | **Arch Agent** | **(PAD-REWORK-006)**  
| | | | 1. 新增 §9 Security Accelerator 接口 (IPsec/SecOC/D-TLS/MACsec 封装卸载) |
| | | | 2. 新增 §4.7 EEE LPI 控制信号 (802.3az MAC↔PHY 低功耗握手) |
| | | | 3. 新增 §4.6 半双工控制信号 (CRS/COL for 10M/100M, 映射至 MII/RMII/RGMII) |
| | | | 4. 更新 §2 AXI4 Master: 新增 QoS (`awqos`/`arqos`)、ID 分配策略表、Outstanding  per-channel |
| | | | 5. 更新 §3 AXI4-Lite: 补充 Outstanding 读写并发、VM 隔离地址解码说明 |
| | | | 6. 新增 §5.3 vPHC 硬件接口信号 (引用 `vphc_hw_interface.md` §3 信号清单) |
| | | | 7. 更新 §8.1 时钟接口: 补充典型频率 `clk_sys=200MHz`, `clk_mac=250MHz`, `clk_ts=250MHz` |
| | | | 8. 更新 §1.1/1.2 接口列表与分类图，纳入 Security/EEE/vPHC |

### 10.2 待解决问题

| ID | 问题描述 | 优先级 | 负责人 | 状态 |
|----|----------|--------|--------|------|
| ISSUE-006 | USXGMII 模式下 5G 速率的信号完整性要求 | P1 | Design Agent | 待分析 |
| ISSUE-007 | AXI Master ID 分配策略 (8 通道仲裁) | P1 | Arch Agent | **已定义 (见 §2.3)** |
| ISSUE-008 | CSS 加速器 AXI Slave 接口定义 | P1 | Arch Agent | **已定义 (见 §9)** |

---

*文档生成: 2026-05-22 | 状态: Draft | 下一步: Arch Review*
