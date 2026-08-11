# NXP S32G PFE (Packet Forwarding Engine) 深度调研

> **项目**: ethernet (IP_20260502_001)
> **文档**: S32G PFE 模块技术调研
> **版本**: v1.0
> **日期**: 2026-08-05
> **作者**: Arch Agent
> **状态**: Draft
> **关联文档**: `Docs/Arch/ethernet_arch_spec.md`, `Docs/Arch/ethernet_interface_spec.md`
> **参考来源**: `Reference/Kimi_Agent_MCU_Ethernet/`, NXP S32G2/G3 Product Brief, Linux PFEng Driver

---

## 1. 概述

### 1.1 PFE 定位

PFE（Packet Forwarding Engine）是 NXP S32G2/G3 处理器 Ethernet 子系统中区别于传统 MCU MAC 的**最大差异化模块**。它是一个**固件驱动的混合硬件-软件包处理器**，核心功能是在无主机 CPU 干预的情况下完成 L2/L3/L4 层的高速分类、路由与桥接。

### 1.2 与 GMAC_0 的分工

S32G 采用**双引擎架构**，GMAC_0 与 PFE 在架构上相互独立：

| 维度 | GMAC_0 | PFE |
|------|--------|-----|
| **定位** | 专用 TSN 端点 | 可编程包转发引擎 |
| **核心 IP** | Synopsys DWMAC 5.10/5.20 | NXP 自研（固件驱动） |
| **速率** | 10/100/1000/2500 Mbps | 2 Gbps（G2）/ 3 Gbps（G3）聚合 |
| **TSN 能力** | 完整（Qbv/Qbu/Qav/AS-Rev） | 无硬件 TSN，固件实现 |
| **时钟域** | 独立 PTP 硬件时间戳 | 固件调度 |
| **中断体系** | 独立 | 独立 |
| **AXI 接口** | 独立 AXI4 Master | 独立 AXI 主接口 |
| **驱动** | Linux `stmmac` + `dwmac-s32.c` | Linux PFEng（闭源固件） |

**设计意图**：GMAC_0 负责与时间严格绑定的控制流量（亚微秒级确定性），PFE 负责大吞吐量的数据平面转发（L2/L3/L4 分类、NAT、IPsec、状态防火墙）。

---

## 2. 内部架构

### 2.1 五大功能块

PFE 内部包含五大功能块，构成"专用硬件块 + 可编程固件"的混合范式：

```
┌─────────────────────────────────────────────────────────────────┐
│                        S32G PFE 架构                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐       │
│   │  HIF    │   │  BMU    │   │  TMU    │   │  EMAC   │       │
│   │ (Host   │   │ (Buffer │   │ (Traffic│   │ (×3)    │       │
│   │Interface│   │  Mgmt)  │   │  Mgmt)  │   │         │       │
│   │ ×4通道  │   │ SRAM+DDR│   │ 8队列   │   │10/100/  │       │
│   │hif0~3   │   │ 双池    │   │ 2调度器 │   │1000/2500│       │
│   └────┬────┘   └────┬────┘   │ 4整形器 │   │ Mbps    │       │
│        │             │        └────┬────┘   └────┬────┘       │
│        │             │             │             │             │
│        └─────────────┴─────────────┴─────────────┘             │
│                          │                                      │
│                   ┌──────┴──────┐                               │
│                   │   CLASS PE   │  ← 8核，L2/L3/L4 分类        │
│                   │  (Classification)│                            │
│                   └──────┬──────┘                               │
│                          │                                      │
│                   ┌──────┴──────┐                               │
│                   │   UTIL PE    │  ← 2+核，复杂状态操作          │
│                   │  (Utility)   │     IPsec代理/NAT/HSE交互     │
│                   └─────────────┘                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 各组件详细规格

| 组件 | 数量/规格 | 功能描述 | 关键特性 |
|------|----------|---------|---------|
| **CLASS PE** | 8 核 | 包解析与 L2/L3/L4 分类，线速 Header Inspection | 有状态分类（Stateful Classification），首包建流表，后续包 Fast Path |
| **UTIL PE** | 2+ 核 | 复杂状态操作、IPsec 代理、NAT 会话管理、HSE 交互 | 处理 Slow Path 流量，调用外部加速器 |
| **TMU** | 8 队列 / 2 调度器 / 4 整形器 | 出向 QoS 调度 | WRR、DWRR、Strict Priority，字节级精度带宽分配 |
| **BMU** | 双池（SRAM + DDR） | 包缓冲区分配/回收 | 内部 SRAM（低延迟）与外部 DDR（大容量）分层 |
| **HIF** | 多通道（hif0/hif1/hif2/hif3） | 与主机 CPU 的数据/控制通路 | 支持多核并行，零拷贝 DMA |
| **EMAC** | 3 × PFE_MAC（内置） | 支持 10/100/1000/2500 Mbps | 各 EMAC 独立 PHY 时钟域 |
| **聚合吞吐** | 2 Gbps（S32G2）/ 3 Gbps（S32G3） | 64 字节小包线速路由/桥接 | G3 相对 G2 提升 50% |

### 2.3 内存映射

| 区域 | 地址范围 | 大小 | 说明 |
|------|---------|------|------|
| PFE 专用内存 | `0x46000000–0x46ffffff` | 16 MB | 设备树分配，包含固件代码、流表、缓冲区 |
| BMU SRAM 池 | 内部 SRAM | 可变 | 低延迟缓冲区，高优先级流量 |
| BMU DDR 池 | 外部 DDR | 可变 | 大容量缓冲区，普通流量 |

---

## 3. 关键接口信号

### 3.1 HIF（Host Interface）信号

HIF 是 PFE 与主机 CPU 的数据/控制通路，支持多核并行访问：

| 信号组 | 信号名 | 宽度 | 方向 | 说明 |
|--------|--------|------|------|------|
| **数据通道** | `hif_tx_data` | 64-bit | CPU → PFE | TX 帧数据 |
| | `hif_tx_valid` | 1 | CPU → PFE | 数据有效 |
| | `hif_tx_ready` | 1 | PFE → CPU | PFE 可接收 |
| | `hif_tx_sop` | 1 | CPU → PFE | 帧起始 |
| | `hif_tx_eop` | 1 | CPU → PFE | 帧结束 |
| | `hif_tx_chid` | 4 | CPU → PFE | HIF 通道 ID（0~3） |
| **RX 数据** | `hif_rx_data` | 64-bit | PFE → CPU | RX 帧数据 |
| | `hif_rx_valid` | 1 | PFE → CPU | 数据有效 |
| | `hif_rx_ready` | 1 | CPU → PFE | CPU 可接收 |
| | `hif_rx_sop` | 1 | PFE → CPU | 帧起始 |
| | `hif_rx_eop` | 1 | PFE → CPU | 帧结束 |
| | `hif_rx_chid` | 4 | PFE → CPU | HIF 通道 ID |
| **描述符** | `hif_bd_addr` | 32 | CPU → PFE | Buffer Descriptor 地址 |
| | `hif_bd_len` | 16 | CPU → PFE | 缓冲区长度 |
| | `hif_bd_own` | 1 | CPU ↔ PFE | 所有权位（类似 TC4x OWN） |
| | `hif_bd_int` | 1 | PFE → CPU | 完成中断 |

### 3.2 EMAC 接口信号（PFE_MAC ↔ 外部 PHY）

PFE 内置 3 个 EMAC，每个 EMAC 支持独立 PHY 时钟域：

| 信号组 | 信号名 | 宽度 | 方向 | 说明 |
|--------|--------|------|------|------|
| **TX** | `emac_tx_data` | 8/4/1 | PFE → PHY | TX 数据（RGMII 4-bit/RMII 2-bit/MII 4-bit） |
| | `emac_tx_en` | 1 | PFE → PHY | TX 使能 |
| | `emac_tx_clk` | 1 | PHY → PFE | TX 时钟 |
| | `emac_tx_er` | 1 | PFE → PHY | TX 错误 |
| **RX** | `emac_rx_data` | 8/4/1 | PHY → PFE | RX 数据 |
| | `emac_rx_dv` | 1 | PHY → PFE | RX 数据有效 |
| | `emac_rx_clk` | 1 | PHY → PFE | RX 时钟 |
| | `emac_rx_er` | 1 | PHY → PFE | RX 错误 |
| **控制** | `emac_mdc` | 1 | PFE → PHY | MDIO 时钟 |
| | `emac_mdio` | 1 | 双向 | MDIO 数据 |
| | `emac_int` | 1 | PHY → PFE | PHY 中断 |

### 3.3 AXI 系统接口

| 信号 | 宽度 | 方向 | 说明 |
|------|------|------|------|
| `axi_awaddr` | 32 | PFE → 系统 | AXI 写地址 |
| `axi_awvalid` | 1 | PFE → 系统 | 写地址有效 |
| `axi_awready` | 1 | 系统 → PFE | 写地址就绪 |
| `axi_wdata` | 64 | PFE → 系统 | 写数据 |
| `axi_wvalid` | 1 | PFE → 系统 | 写数据有效 |
| `axi_wready` | 1 | 系统 → PFE | 写数据就绪 |
| `axi_araddr` | 32 | PFE → 系统 | AXI 读地址 |
| `axi_arvalid` | 1 | PFE → 系统 | 读地址有效 |
| `axi_arready` | 1 | 系统 → PFE | 读地址就绪 |
| `axi_rdata` | 64 | 系统 → PFE | 读数据 |
| `axi_rvalid` | 1 | 系统 → PFE | 读数据有效 |
| `axi_rready` | 1 | PFE → 系统 | 读数据就绪 |
| `axi_awqos` | 4 | PFE → 系统 | AXI QoS 标识（高优先级流量保障） |
| `axi_arqos` | 4 | PFE → 系统 | AXI QoS 标识 |

### 3.4 FCI（Flexible Communication Interface）控制接口

FCI 是 PFE 固件暴露给主机软件的配置 API，通过共享内存 + 中断实现：

| 信号 | 说明 |
|------|------|
| `fci_cmd_buf` | 命令缓冲区地址（共享内存） |
| `fci_rsp_buf` | 响应缓冲区地址 |
| `fci_int` | FCI 中断（PFE → CPU） |
| `fci_sem` | 信号量（互斥访问） |

**FCI 命令类型**：
- 路由表配置（L2/L3/L4 规则）
- NAT 表配置
- VLAN 配置
- QoS 策略配置
- 端口镜像配置
- 统计查询

---

## 4. 数据流

### 4.1 RX 方向（EMAC → Host）

```
┌─────────┐   ┌─────────┐   ┌──────────┐   ┌─────────┐   ┌─────────┐
│  PHY    │──►│  EMAC   │──►│ CLASS PE │──►│   BMU   │──►│   HIF   │──► Host
│(1000BASE│   │(PFE_MAC)│   │(L2/L3/L4 │   │(Buffer  │   │(Channel │
│  -T1)   │   │         │   │Classification)│  Mgmt) │   │  0~3)   │
└─────────┘   └─────────┘   └──────────┘   └─────────┘   └─────────┘
                                │
                                ▼
                         ┌──────────┐
                         │  UTIL PE │  ← Slow Path（IPsec/NAT/防火墙）
                         │(Utility) │
                         └──────────┘
```

**详细流程**：

1. **EMAC 接收**：PHY 侧帧到达，EMAC 执行 CRC 检查、帧长检查、时间戳捕获
2. **CLASS PE 分类**：
   - **Fast Path**：首包解析 L2/L3/L4 头部，建立流表项；后续同流包直接匹配流表，零 CPU 干预转发
   - **Slow Path**：需要复杂状态操作（IPsec/NAT/防火墙）的包移交 UTIL PE
3. **UTIL PE 处理**（可选）：IPsec 包代理至 HSE，NAT 会话管理，状态防火墙跟踪
4. **BMU 缓冲**：帧数据写入 BMU 管理的缓冲区（SRAM 或 DDR）
5. **HIF 传输**：通过 HIF 通道将帧描述符+数据指针传递给主机 CPU

### 4.2 TX 方向（Host → EMAC）

```
┌─────────┐   ┌─────────┐   ┌──────────┐   ┌─────────┐   ┌─────────┐
│  Host   │──►│   HIF   │──►│   BMU    │──►│   TMU   │──►│  EMAC   │──► PHY
│         │   │(Channel │   │(Buffer   │   │(Traffic │   │(PFE_MAC)│
│         │   │  0~3)   │   │  Mgmt)   │   │  Mgmt)  │   │         │
└─────────┘   └─────────┘   └──────────┘   └─────────┘   └─────────┘
                                                 │
                                          ┌──────┴──────┐
                                          │  8 队列      │
                                          │  2 调度器    │
                                          │  4 整形器    │
                                          └─────────────┘
```

**详细流程**：

1. **HIF 接收**：主机 CPU 通过 HIF 通道提交帧描述符+数据指针
2. **BMU 读取**：PFE 从系统内存读取帧数据到 BMU 缓冲区
3. **TMU 调度**：根据 QoS 策略（WRR/DWRR/Strict Priority）调度到 8 个出向队列
4. **EMAC 发送**：帧经 EMAC 发送到 PHY，支持帧抢占（若启用）

### 4.3 Fast Path vs Slow Path

| 维度 | Fast Path | Slow Path |
|------|----------|----------|
| **处理引擎** | CLASS PE | UTIL PE |
| **处理内容** | L2/L3/L4 分类、流表匹配、直接转发 | IPsec、NAT、状态防火墙、复杂协议处理 |
| **CPU 干预** | 零干预 | 固件处理（PFE 内部 PE，非主机 CPU） |
| **延迟** | 线速（纳秒级） | 微秒级 |
| **吞吐** | 2/3 Gbps 聚合 | 受 UTIL PE 核数限制 |

---

## 5. 配置流程

### 5.1 固件加载

PFE 固件以二进制 blob 形式提供，系统启动时加载：

```c
// Linux 驱动加载流程
1. request_firmware("s32g_pfe_class.fw")  → CLASS PE 固件
2. request_firmware("s32g_pfe_util.fw")   → UTIL PE 固件
3. 写入 PFE 内部存储器（0x46000000 区域）
4. 复位释放，PFE 开始执行固件
```

### 5.2 HIF 通道初始化

```c
// HIF 通道配置（Linux PFEng 驱动）
1. 分配 HIF 通道描述符环（TX/RX 各 128 项）
2. 配置 BMU 缓冲池（SRAM 池 + DDR 池）
3. 注册中断处理函数（hif0_int, hif1_int, ...）
4. 使能 HIF 通道
```

### 5.3 FCI 配置流程

通过 FCI（Flexible Communication Interface）配置 PFE 功能：

```c
// 1. 分配 FCI 命令/响应缓冲区（共享内存）
fci_cmd_buf = dma_alloc_coherent(dev, FCI_CMD_SIZE, &dma_addr, GFP_KERNEL);

// 2. 构造 FCI 命令
fci_cmd->cmd_id = FCI_CMD_ADD_ROUTE;
fci_cmd->route.dst_ip = 0xC0A80101;  // 192.168.1.1
fci_cmd->route.mask = 0xFFFFFF00;    // /24
fci_cmd->route.next_hop = 0xC0A801FE;
fci_cmd->route.out_port = 1;

// 3. 发送命令（写入共享内存 + 触发中断）
writel(FCI_CMD_READY, fci_reg_base + FCI_CTRL);

// 4. 等待响应（中断或轮询）
wait_for_completion(&fci_done);

// 5. 检查响应状态
if (fci_rsp->status == FCI_SUCCESS) { ... }
```

### 5.4 典型配置序列

| 步骤 | 配置内容 | FCI 命令 |
|------|---------|---------|
| 1 | L2 桥接配置 | `FCI_CMD_L2_BR_ADD` |
| 2 | VLAN 配置 | `FCI_CMD_VLAN_ADD` |
| 3 | L3 路由配置 | `FCI_CMD_ROUTE_ADD` |
| 4 | NAT 配置 | `FCI_CMD_NAT_ADD` |
| 5 | QoS 策略 | `FCI_CMD_QOS_SET` |
| 6 | 状态防火墙 | `FCI_CMD_FW_ADD_RULE` |
| 7 | IPsec SA | `FCI_CMD_IPSEC_SA_ADD` |

---

## 6. 协议支持情况

### 6.1 L2 协议

| 协议 | 支持方式 | 说明 |
|------|---------|------|
| **802.1Q VLAN** | 硬件 | VLAN 插入/删除/替换，QinQ |
| **802.1Qav CBS** | 无 | PFE 不支持，GMAC_0 支持 |
| **802.1Qbv TAS** | 无 | PFE 不支持，GMAC_0 支持 |
| **802.1Qbu/802.3br 帧抢占** | 无 | PFE 不支持，GMAC_0 支持 |
| **802.1CB FRER** | 固件 | 可通过固件实现 |
| **802.1Qci PSFP** | 固件 | 可通过固件实现 |
| **L2 桥接** | 硬件 | 线速 MAC 学习/转发 |

### 6.2 L3/L4 协议

| 协议 | 支持方式 | 说明 |
|------|---------|------|
| **IPv4/IPv6** | 硬件 | 线速路由、分片/重组 |
| **NAT/NAPT** | 固件 | UTIL PE 实现，支持 TCP/UDP/ICMP |
| **IPsec AH/ESP** | 固件 + HSE | UTIL PE 识别，HSE 加解密 |
| **TCP/UDP** | 硬件 | 校验和计算/验证 |
| **ICMP** | 硬件 | 校验和计算/验证 |
| **状态防火墙** | 固件 | TCP 三次握手跟踪、UDP 伪会话 |

### 6.3 TSN 协议

| 协议 | PFE 支持 | GMAC_0 支持 | 说明 |
|------|---------|------------|------|
| **802.1AS-2020 gPTP** | 固件 | 硬件 | PFE 固件实现，精度低于 GMAC_0 硬件 |
| **802.1Qbv TAS** | ❌ | ✅ 硬件 | PFE 无硬件 TAS |
| **802.1Qbu/802.3br** | ❌ | ✅ 硬件 | PFE 无硬件帧抢占 |
| **802.1Qav CBS** | ❌ | ✅ 硬件 | PFE 无硬件 CBS |

**关键限制**：S32G2 的 Qbv/Qbu 仅限 GMAC_0 且不能同时启用；S32G3 可同时启用。

### 6.4 安全协议

| 协议 | 支持方式 | 说明 |
|------|---------|------|
| **IPsec** | 固件 + HSE | UTIL PE + HSE 协同，AES-GCM/CCM |
| **MACsec** | ❌ | 片内无 MACsec 加速器，需外部 PHY（TJA1104/TJA1121） |
| **SecOC** | 固件 + HSE | AUTOSAR SecOC，AES-CMAC |
| **SSL/TLS** | 固件 + HSE | 组合密码/哈希加速 |

---

## 7. 关键功能实现方式

### 7.1 有状态分类（Stateful Classification）

**实现位置**：CLASS PE

**工作机制**：
1. **首包处理**：CLASS PE 解析 L2/L3/L4 头部（MAC 地址、VLAN、IP 地址、协议类型、端口号），建立流表项
2. **流表匹配**：后续同流包直接匹配硬件加速的流表，实现 Fast Path 零 CPU 干预转发
3. **流表老化**：超时未匹配的流表项自动清除

**流表项结构**：
```c
struct pfe_flow_entry {
    uint8_t  dst_mac[6];     // 目的 MAC
    uint8_t  src_mac[6];     // 源 MAC
    uint16_t vlan_id;        // VLAN ID
    uint32_t src_ip;         // 源 IP
    uint32_t dst_ip;         // 目的 IP
    uint8_t  protocol;       // 协议类型（TCP/UDP/ICMP）
    uint16_t src_port;       // 源端口
    uint16_t dst_port;       // 目的端口
    uint8_t  out_port;       // 出端口
    uint32_t age_timer;      // 老化定时器
};
```

### 7.2 状态防火墙（Stateful Firewall）

**实现位置**：UTIL PE

**工作机制**：
1. **TCP 会话跟踪**：跟踪 SYN/SYN-ACK/ACK 三次握手状态
2. **UDP 伪会话**：跟踪 UDP 流的生命周期（首包建会话，超时清除）
3. **入向连接控制**：仅允许已建立连接的回包通过，阻断未经请求的入向连接

**与无状态过滤对比**：
| 特性 | 无状态过滤 | 状态防火墙 |
|------|----------|----------|
| 规则匹配 | 静态 ACL | 动态会话状态 |
| TCP 支持 | 仅端口/标志位 | 完整握手状态 |
| UDP 支持 | 仅端口 | 伪会话跟踪 |
| DoS 防护 | 有限 | 强（阻断未请求入向连接） |

### 7.3 IPsec 卸载

**实现位置**：UTIL PE + HSE

**工作流程**：
1. PFE UTIL PE 识别属于 IPsec SA（Security Association）的数据包
2. 通过高速内部接口将包转发至 HSE
3. HSE 执行 AES-GCM/AES-CCM/SHA-256 等密码运算
4. 处理完的包返回 PFE 继续路由

**安全隔离**：明文数据与密钥不暴露于主 CPU 内存空间，实现 "Bump-in-the-Wire" 级别安全隔离。

### 7.4 QoS 调度

**实现位置**：TMU

**调度算法**：
- **WRR（Weighted Round Robin）**：按权重轮询
- **DWRR（Deficit Weighted Round Robin）**：按字节级精度分配带宽
- **Strict Priority**：严格优先级

**队列结构**：8 个出向队列，2 个调度器，4 个整形器

### 7.5 零拷贝 DMA

**实现位置**：HIF + BMU

**工作机制**：
1. PFE 提供 4 个独立 HIF 通道
2. Linux PFEng 驱动使用预留内存节点 "pfebufs" 作为 DMA 缓冲区池
3. BMU1/BMU2 管理 DDR 和内部 SRAM 中的缓冲池
4. PFE 固件自主完成缓冲区分配和回收
5. 网络栈接收的数据包直接存放在 PFE 缓冲区中，只需传递指针即可移交上层

**与 TC4x 对比**：
| 特性 | TC4x | S32G PFE |
|------|------|---------|
| 零拷贝机制 | 双缓冲区描述符（2 buffer/描述符） | BMU 池 + PFE HIF |
| Scatter-Gather | 双缓冲区 + 链式描述符 | BMU 缓冲池 |
| CPU 占用 | 低 | 最低（网关场景） |

---

## 8. S32G2 vs S32G3 差异

| 特性 | S32G2 | S32G3 | 影响 |
|------|-------|-------|------|
| **PFE 聚合吞吐** | 2 Gbps | 3 Gbps | G3 提升 50%，支持更复杂分类规则 |
| **PFE MAC 速率** | 仅 MAC0 2.5G | 全部 3 端口 2.5G | G3 支持对称多 2.5G 骨干网 |
| **GMAC_0 TSN** | Qbv/Qbu 互斥 | Qbv+Qbu 同时启用 | G3 支持 TAS + 帧抢占协同 |
| **CPU 核心** | 4 × Cortex-A53 | 8 × Cortex-A53 | G3 计算能力翻倍 |

---

## 9. 与本项目 Ethernet IP 的对比

| 维度 | S32G PFE | 本项目 Switch Core | 差异分析 |
|------|---------|-------------------|---------|
| **交换结构** | 固件可编程转发 | 硬件 Crossbar + FDB | PFE 灵活但延迟高，本项目确定性好 |
| **FDB** | 固件实现 | 硬件自学习 | 本项目零延迟查表 |
| **TAS/CBS** | 无 | 硬件支持 | 本项目 TSN 能力完整 |
| **帧抢占** | 无 | 硬件支持 | 本项目支持 802.1Qbu |
| **VLAN** | 硬件 | 硬件 | 相当 |
| **L3 路由** | 硬件 | 简化（SWITCH_L3=0/1） | PFE 更强 |
| **NAT** | 固件 | 无 | PFE 支持 |
| **IPsec** | 固件 + HSE | 无 | PFE 支持 |
| **状态防火墙** | 固件 | 无 | PFE 支持 |
| **接口** | HIF + EMAC | swi_port_if | 本项目统一接口更简洁 |
| **可编程性** | 固件更新 | 参数化配置 | PFE 更灵活 |

---

## 10. 参考来源

| 来源 | 内容 |
|------|------|
| `Reference/Kimi_Agent_MCU_Ethernet/ethernet_mcu.agent.final.converted.md` | S32G PFE 架构、GMAC_0 对比、TSN 分析 |
| `Reference/Kimi_Agent_MCU_Ethernet/pics_report_sec08.md` | PICS 支持度分析 |
| NXP S32G2/G3 Product Brief | PFE 功能列表 |
| Linux PFEng Driver | HIF/BMU/FCI 接口细节 |
| NXP S32G Reference Manual | 寄存器级描述 |

---

*文件: Reference/S32G_PFE/s32g_pfe_deep_dive.md*
*版本: v1.0*
*说明: NXP S32G PFE 模块深度调研 — 架构、接口、数据流、配置流程、协议支持、关键功能实现*
