# Ethernet IP Interface Specification

> **文档名称**: Ethernet IP Interface Specification  
> **版本**: v1.0  
> **日期**: 2026-05-11  
> **作者**: Arch Agent  
> **评审状态**: Draft  

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
|                                                                    |
|  时钟/复位接口                                                     |
|  +-- clk_sys, clk_mac, clk_tx_phy, clk_rx_phy, clk_ts, clk_pcs    |
|  +-- rst_n, rst_dma, rst_mac, rst_phy, rst_ts                     |
|                                                                    |
|  外部同步/中断接口                                                 |
|  +-- PPS (4 路输出)                                               |
|  +-- INTERRUPT (每通道 + 汇总)                                    |
|  +-- SMU_ALERT (安全报警)                                         |
|                                                                    |
+==================================================================+
```

---

## 2. AXI4 Master 接口 (数据面)

### 2.1 接口信号

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `m_axi_awid` | Output | 4-bit | 写地址 ID |
| `m_axi_awaddr` | Output | 64-bit | 写地址 |
| `m_axi_awlen` | Output | 8-bit | 突发长度 (AXI: len+1) |
| `m_axi_awsize` | Output | 3-bit | 突发大小 (0=1B, 3=8B for 64-bit) |
| `m_axi_awburst` | Output | 2-bit | 突发类型 (INCR/WRAP/FIXED) |
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
| `m_axi_arid` | Output | 4-bit | 读地址 ID |
| `m_axi_araddr` | Output | 64-bit | 读地址 |
| `m_axi_arlen` | Output | 8-bit | 突发长度 |
| `m_axi_arsize` | Output | 3-bit | 突发大小 |
| `m_axi_arburst` | Output | 2-bit | 突发类型 |
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
| `Outstanding transactions` | 2 | 2 | 4 | — |

### 2.3 地址映射

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

### 3.2 寄存器地址映射

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
| `0x3000` | `Bridge_Control` | RW | Bridge 控制 |
| `0x3004` | `Bridge_Forward_Table` | RW | 桥接转发表 |
| `0xF000` | `Safety_ECC_Status` | RO | ECC 状态 |
| `0xF004` | `Safety_FSM_Parity` | RO | FSM 奇偶校验状态 |
| `0xF008` | `Safety_Timeout_Status` | RO | 超时状态 |
| `0xF010` | `Safety_Interrupt_Mask` | RW | 安全中断掩码 |

> **注**: 寄存器完整列表详见 `Docs/Design/Module_Specs/` 下的各模块详细规格。

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

**时序要求**: 遵循 RGMII v2.0 规范，TX 时钟-数据偏斜由 HSPHY 内部 DLL 控制，精度 138.88 ps。

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
| `clk_sys` | Input | 100-300 MHz | 系统总线时钟 |
| `clk_mac` | Input | 150-300 MHz | MAC 核心时钟 |
| `clk_tx_phy` | Input | 25-312.5 MHz | TX PHY 接口时钟 |
| `clk_rx_phy` | Input | 25-312.5 MHz | RX PHY 接口时钟 |
| `clk_ts` | Input | 100 MHz | PTP 时间戳时钟 |
| `clk_pcs` | Input | 62.5-625 MHz | PCS 串行时钟 |

### 8.2 复位接口

| 信号名 | 方向 | 极性 | 说明 |
|--------|------|------|------|
| `rst_n` | Input | 低有效 | 全局异步复位 |
| `rst_dma_n` | Input | 低有效 | DMA 模块复位 |
| `rst_mac_n` | Input | 低有效 | MAC 模块复位 |
| `rst_phy_n` | Input | 低有效 | PHY 接口复位 |
| `rst_ts_n` | Input | 低有效 | 时间戳模块复位 |
| `rst_bridge_n` | Input | 低有效 | Bridge 模块复位 |

---

## 9. 附录

### 9.1 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v0.1 | 2026-05-02 | Arch Agent | 初始模板创建 |
| v1.0 | 2026-05-11 | Arch Agent | 填充完整接口定义 |

### 9.2 待解决问题

| ID | 问题描述 | 优先级 | 负责人 | 状态 |
|----|----------|--------|--------|------|
| ISSUE-006 | USXGMII 模式下 5G 速率的信号完整性要求 | P1 | Design Agent | 待分析 |
| ISSUE-007 | AXI Master ID 分配策略 (8 通道仲裁) | P1 | Arch Agent | 待定义 |
| ISSUE-008 | CSS 加速器 AXI Slave 接口定义 | P1 | Arch Agent | 待定义 |

---

*文档生成: 2026-05-11 | 状态: Draft | 下一步: Arch Review*
