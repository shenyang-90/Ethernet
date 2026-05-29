# Ethernet IP Clock and Reset Specification

> **文档名称**: Ethernet IP Clock and Reset Specification  
> **版本**: v1.2  
> **日期**: 2026-05-29  
> **作者**: RTL Coding Agent  
> **评审状态**: Draft  
> **变更**: (PAD-REWORK-012) RTL-MAJ-003: §1.5 PLCA 参考时钟补充 CDC 策略 (时钟域归属、clk_sys↔plca_ref_clk/plca_ref_clk→clk_mac 跨域同步方案)

---

## 1. 时钟架构

### 1.1 时钟源

| 时钟源 | 频率范围 | **典型值** | 来源 | 用途 | 抖动要求 |
|--------|----------|:----------:|------|------|----------|
| `SYS_CLK` | 100–300 MHz | **200 MHz** | SoC PLL | AXI 总线、CSR 逻辑 | < 50 ps RMS |
| `MAC_CLK` | 150–300 MHz | **250 MHz** | SoC PLL / 独立 PLL | MAC Core、MTL 控制 | < 30 ps RMS |
| `TX_PHY_CLK` | 2.5–625 MHz | *按速率分档* | PHY / DLL | TX 并行数据 | < 100 ps |
| `RX_PHY_CLK` | 2.5–625 MHz | *按速率分档* | PHY CDR | RX 并行数据 | < 100 ps |
| `TS_CLK` | 100–300 MHz | **250 MHz** | 独立低抖动 PLL | PTP 时间戳、Addend | < 10 ps RMS |
| `PCS_CLK` | 62.5–625 MHz | *按速率分档* | SERDES PLL | PCS 串行编码 | < 5 ps RMS |
| `CRS_CD_CLK` | 2.5–25 MHz | *按速率分档* | PHY | 半双工 CRS/CD | < 200 ps |
| `PLCA_REF_CLK` | — | **12.5 MHz** | 内部分频 | 10BASE-T1S PLCA 参考 | < 50 ppm |
| `REF_CLK_25M` | 25 MHz | 25 MHz | 晶振 | SGMII/USXGMII 参考 | < 50 ppm |
| `REF_CLK_50M` | 50 MHz | 50 MHz | 晶振 | RMII 参考 | < 50 ppm |

### 1.2 时钟域划分

```
+==================================================================+
|                        时钟域架构图                               |
+==================================================================+
|                                                                    |
|  +---------------------+                                            |
|  |    clk_sys          |  (200 MHz 典型)                            |
|  |  +---------------+  |                                            |
|  |  | AXI Master    |  |                                            |
|  |  | AXI-Lite Slave|  |                                            |
|  |  | CSR Registers |  |                                            |
|  |  +---------------+  |                                            |
|  +----------|----------+                                            |
|             |                                                      |
|             | CDC (Async FIFO / Handshake)                          |
|             v                                                      |
|  +---------------------+                                            |
|  |    clk_mac          |  (250 MHz 典型)                             |
|  |  +---------------+  |                                            |
|  |  | MAC Core      |  |                                            |
|  |  | MTL Control   |  |                                            |
|  |  | DMA Control   |  |                                            |
|  |  +---------------+  |                                            |
|  +----------|----------+                                            |
|             |                                                      |
|             | CDC                                                  |
|             v                                                      |
|  +---------------------+         +---------------------+            |
|  |    clk_tx_phy       |         |    clk_rx_phy       |            |
|  |  (2.5~312.5 MHz)   |         |  (2.5~312.5 MHz)   |            |
|  |  +---------------+  |         |  +---------------+  |            |
|  |  | PHY TX IF     |  |         |  | PHY RX IF     |  |            |
|  |  | MII/RGMII/SGM |  |         |  | MII/RGMII/SGM |  |            |
|  |  +---------------+  |         |  +---------------+  |            |
|  +---------------------+         +---------------------+            |
|                                                                    |
|  +---------------------+                                            |
|  |    clk_ts           |  (250 MHz)                                  |
|  |  +---------------+  |                                            |
|  |  | PTP Timestamp |  |                                            |
|  |  | Time Counter  |  |                                            |
|  |  | Addend Logic  |  |                                            |
|  |  +---------------+  |                                            |
|  +---------------------+                                            |
|                                                                    |
|  +---------------------+                                            |
|  |    clk_pcs          |  (62.5~625 MHz)                            |
|  |  +---------------+  |                                            |
|  |  | PCS Encoder   |  |                                            |
|  |  | SERDES IF     |  |                                            |
|  |  +---------------+  |                                            |
|  +---------------------+                                            |
|                                                                    |
|  +---------------------+                                            |
|  |    clk_crs_cd       |  (2.5/25 MHz, 半双工)                       |
|  |  +---------------+  |                                            |
|  |  | CRS/CD Sync   |  |                                            |
|  |  | CSMA/CD Logic |  |                                            |
|  |  +---------------+  |                                            |
|  +---------------------+                                            |
|                                                                    |
|  +---------------------+                                            |
|  |    plca_ref_clk     |  (12.5 MHz)                                 |
|  |  +---------------+  |                                            |
|  |  | PLCA 协调器   |  |                                            |
|  |  +---------------+  |                                            |
|  +---------------------+                                            |
|                                                                    |
+==================================================================+
```

### 1.3 时钟频率与速率对应关系

| 工作模式 | MII_TX_CLK | MII_RX_CLK | RGMII_CLK | SGMII_Line_Rate | USXGMII_Line_Rate | **clk_tx_phy** | **clk_rx_phy** | **clk_pcs** |
|----------|------------|------------|-----------|-----------------|-------------------|:--------------:|:--------------:|:-----------:|
| 10M MII  | 2.5 MHz    | 2.5 MHz    | —         | —               | —                 | **2.5 MHz**    | **2.5 MHz**    | —           |
| 100M MII | 25 MHz     | 25 MHz     | —         | —               | —                 | **25 MHz**     | **25 MHz**     | —           |
| 100M RMII| —          | —          | —         | —               | —                 | **50 MHz**     | **50 MHz**     | —           |
| 1G RGMII | —          | —          | 125 MHz   | —               | —                 | **125 MHz**    | **125 MHz**    | —           |
| 1G SGMII | —          | —          | —         | 1.25 Gbps       | —                 | **125 MHz**    | **125 MHz**    | 625 MHz     |
| 2.5G SGMII| —         | —          | —         | 3.125 Gbps      | —                 | **312.5 MHz**  | **312.5 MHz**  | 625 MHz     |
| 5G USXGMII| —         | —          | —         | —               | 6.25 Gbps         | **312.5 MHz**  | **312.5 MHz**  | 625 MHz     |
| 10G USXGMII| —        | —          | —         | —               | 10.3125 Gbps      | **312.5 MHz**  | **312.5 MHz**  | 625 MHz     |

### 1.4 CRS/CD 时钟域 (半双工模式)

| 参数 | 10M 半双工 | 100M 半双工 | 来源 | 说明 |
|------|:----------:|:-----------:|------|------|
| `clk_crs_cd` | 2.5 MHz | 25 MHz | PHY | 与 MII_TX_CLK/MII_RX_CLK 同源 |
| 占空比 | 50% | 50% | — | 标准 50% 方波 |
| 建立时间 | 10 ns | 10 ns | — | CRS/COL 相对 clk_mac |
| 保持时间 | 0 ns | 0 ns | — | — |

> **独立定义**: `clk_crs_cd` 由 PHY 在半双工模式 (`PHY_x_DUPLEX=0`) 下提供，与 `clk_tx_phy`/`clk_rx_phy` 同源但逻辑上独立作为 **CSMA/CD 控制域**。`PHY_x_DUPLEX=1` 时此时钟域关闭或忽略。

### 1.5 PLCA 参考时钟

| 参数 | 值 | 说明 |
|------|-----|------|
| `plca_ref_clk` | **12.5 MHz** | 10BASE-T1S PLCA 协调器参考时钟 |
| 周期 | **80 ns** | 1 / 12.5 MHz = 80 ns，对应 PLCA 时隙粒度 |
| 来源 | `clk_sys` ÷ 16 (200 MHz → 12.5 MHz) | 整数分频，无抖动累积 |
| 精度 | ±50 ppm | 由 `clk_sys` 精度继承 |
| **时钟域归属** | **`plca_ref_clk` 域** (独立划分，见 §1.2 架构图) | 与 `clk_mac`/`clk_sys` 异步，但同源 |
| **CDC 策略** | **→ CSR 配置**: `clk_sys` → `plca_ref_clk` 握手同步 (§3.2)，配置影子寄存器原子加载<br>**→ MAC 状态**: `plca_ref_clk` → `clk_mac` 2-flop 同步器 (§3.1)，TO 超时/BEACON 接收事件<br>**→ 系统中断**: `plca_ref_clk` → `clk_sys` 2-flop 同步器 (§3.1)，PLCA 错误/状态变化 | 见 §3 CDC 详细方案 |
| 用途 | PLCA 状态机、TO 计时器、BEACON 发送对齐 | 802.3cg §148.4.3 |

---

## 2. 复位架构

### 2.1 复位源

| 复位源 | 类型 | 触发条件 | 作用范围 |
|--------|------|----------|----------|
| `POR_n` | 异步 | 上电 | 全芯片 |
| `rst_n` | 同步 | 软件/看门狗 | Ethernet IP 全模块 |
| `rst_dma_n` | 同步 | CSR 控制 | DMA 子系统 |
| `rst_mac_n` | 同步 | CSR 控制 | MAC + MTL 子系统 |
| `rst_phy_n` | 同步 | CSR 控制 | PHY 接口子系统 |
| `rst_ts_n` | 同步 | CSR 控制 | PTP/时间戳子系统 |
| `rst_switch_n` | 同步 | CSR 控制 | Switch 子系统 |
| `rst_sec_n` | 同步 | CSR 控制 | Security Wrapper 子系统 |
| `smu_rst_n` | 异步 | SMU 报警 | 全模块/部分通道 |

### 2.2 复位域

```
+==================================================================+
|                        复位域架构图                               |
+==================================================================+
|                                                                    |
|  +------------------------+                                         |
|  |      POR_n             |  (全局上电复位)                         |
|  +-----------|------------+                                         |
|              v                                                     |
|  +------------------------+                                         |
|  |      rst_n             |  (全局软复位)                            |
|  +-----------|------------+                                         |
|              |                                                     |
|    +---------+---------+                                           |
|    |         |         |                                           |
|    v         v         v                                           |
|  +----+   +----+   +------+   +------+   +--------+   +------+  |
|  |DMA |   |MAC |   |PHY   |   |TS    |   |Switch  |   |Sec   |  |
|  |    |   |MTL |   |      |   |      |   |        |   |Accel |  |
|  +----+   +----+   +------+   +------+   +--------+   +------+  |
|    ^         ^         ^         ^         ^           ^       |
|    |         |         |         |         |           |       |
|  rst_dma  rst_mac   rst_phy   rst_ts   rst_switch   rst_sec   |
|    |         |         |         |         |           |       |
|  +---------+---------+---------+---------+---------+          |
|  |         CSR 控制   (独立模块复位)                              |
|  +------------------------+                                         |
|              |                                                     |
|              v                                                     |
|  +------------------------+                                         |
|  |      smu_rst_n         |  (SMU 安全复位)                         |
|  +------------------------+                                         |
|                                                                    |
+==================================================================+
```

### 2.3 复位时序

| 参数 | 最小值 | 典型值 | 最大值 | 单位 |
|------|--------|--------|--------|------|
| `POR_n` 低电平宽度 | 1 | 10 | — | μs |
| `rst_n` 低电平宽度 | 16 | 32 | — | clk_sys cycles |
| **复位释放到首个 CSR 访问** | **—** | **100** | **—** | **μs** |
| 复位释放到首个 DMA 传输 | 500 | — | — | μs |
| 模块级复位脉冲宽度 | 16 | — | — | 目标时钟域 cycles |
| SMU 复位响应延迟 | — | — | 10 | μs |

### 2.4 复位释放计数器 (参数化)

全局复位释放后，硬件自动插入 **100 μs 延时**，确保 PLL 锁定、PHY 稳定、CDC FIFO 初始化完成。

**参数化公式**:

```
RESET_CNT_W = ceil(log2(CLK_SYS_FREQ_MHZ * 100_000))
RESET_CNT_MAX = CLK_SYS_FREQ_MHZ * 100_000 - 1
```

| clk_sys 频率 | 计数器位宽 | 计数器最大值 | 实际延时 |
|:------------:|:----------:|:------------:|:--------:|
| 100 MHz | 14-bit | 9_999 | 100 μs |
| **200 MHz** | **15-bit** | **19_999** | **100 μs** |
| 250 MHz | 15-bit | 24_999 | 100 μs |
| 300 MHz | 15-bit | 29_999 | 100 μs |

**RTL 实现**:

```verilog
// 参数化复位计数器
localparam RESET_CNT_W = $clog2(CLK_SYS_FREQ_MHZ * 100_000);
localparam RESET_CNT_MAX = CLK_SYS_FREQ_MHZ * 100_000 - 1;

reg [RESET_CNT_W-1:0] rst_release_cnt;
reg rst_release_done;

always @(posedge clk_sys or negedge POR_n) begin
    if (!POR_n) begin
        rst_release_cnt <= '0;
        rst_release_done <= 1'b0;
    end else if (!rst_release_done) begin
        if (rst_release_cnt >= RESET_CNT_MAX)
            rst_release_done <= 1'b1;
        else
            rst_release_cnt <= rst_release_cnt + 1'b1;
    end
end

// rst_n 仅在 rst_release_done 后释放
assign rst_n_out = rst_release_done ? rst_n_in : 1'b0;
```

> **注意**: 100 μs 为最小延时。若 SoC PLL 锁定时间更长，软件可通过 `RST_EXTEND` CSR 位追加延时。

### 2.5 复位策略详细说明

#### 2.5.1 全局复位 (`rst_n`)

- **触发**: 上电完成后软件释放，或 CSR `Software_Reset` 位置位
- **作用**: 全模块寄存器复位至默认值，FIFO 清零，状态机归零
- **时序**: 同步释放，需跨时钟域同步到各子模块
- **注意事项**: 复位期间所有 AXI 事务必须完成或异常终止

#### 2.5.2 模块级软复位

- **触发**: 通过 CSR 各模块控制寄存器的 Reset 位
- **作用**: 仅复位目标子系统，不影响其他模块运行
- **典型场景**:
  - `rst_dma_n`: 描述符环错误后重新初始化 DMA
  - `rst_mac_n`: MAC 配置变更后重新加载
  - `rst_ts_n`: PTP 配置切换后重新同步
  - `rst_switch_n`: 转发表更新后重新初始化
  - `rst_sec_n`: 安全加速器错误后重新初始化

#### 2.5.3 SMU 安全复位

- **触发**: ECC 双 bit 错误、FSM Parity 错误、Timeout 严重报警
- **作用**: 根据安全策略执行全复位或部分通道关闭
- **响应等级**:
  - Level 1 (Warning): 仅中断 + 计数
  - Level 2 (Critical): 关闭故障通道，其他通道继续
  - Level 3 (Fatal): 全模块复位，上报 SMU

---

## 3. CDC 方案

### 3.1 单 bit 同步

| 应用场景 | 源时钟域 | 目标时钟域 | 方案 | 延迟 |
|----------|----------|------------|------|------|
| 中断标志 | clk_mac | clk_sys | 2-flop 同步器 | 2-3 cycles |
| 安全报警 | clk_mac | clk_sys | 2-flop 同步器 | 2-3 cycles |
| PPS 输出 | clk_ts | clk_sys | 2-flop 同步器 | 2-3 cycles |
| 链路状态 | clk_rx_phy | clk_mac | 2-flop 同步器 | 2-3 cycles |
| LPI 状态 | clk_tx_phy | clk_mac | 2-flop 同步器 | 2-3 cycles |
| CRS/CD | clk_crs_cd | clk_mac | 2-flop 同步器 | 2-3 cycles |
| **PLCA 状态事件** | **plca_ref_clk** | **clk_mac** | **2-flop 同步器** | **2-3 cycles** |
| **PLCA 配置加载完成** | **plca_ref_clk** | **clk_sys** | **2-flop 同步器** | **2-3 cycles** |

**要求**: MTBF > 1000 年 (基于目标工艺和切换频率计算)

### 3.2 多 bit 同步 (握手)

| 应用场景 | 源时钟域 | 目标时钟域 | 方案 | 延迟 |
|----------|----------|------------|------|------|
| CSR 配置值 | clk_sys | clk_mac | 握手同步 (req/ack) | 4-6 cycles |
| 时间戳加载 | clk_sys | clk_ts | 握手同步 | 4-6 cycles |
| GCL 切换 | clk_sys | clk_mac | 握手同步 + 双银行 | 1 cycle (原子) |
| VM 偏移更新 | clk_sys | clk_ts | 握手同步 | 4-6 cycles |
| **PLCA 参数配置 (TO/Burst/NodeID)** | **clk_sys** | **plca_ref_clk** | **握手同步 + 影子寄存器** | **4-6 cycles** |
| **PLCA 周期状态 (cycle_time/偏差)** | **plca_ref_clk** | **clk_sys** | **握手同步** | **4-6 cycles** |

### 3.3 异步 FIFO

| 应用场景 | 宽度 | 深度 | 方案 | 说明 |
|----------|------|------|------|------|
| MTL TX FIFO | 68-bit (64+4) | 32KB/8B = 4K | 双端口 SRAM + Gray 码 | clk_sys → clk_mac |
| MTL RX FIFO | 68-bit (64+4) | 32KB/8B = 4K | 双端口 SRAM + Gray 码 | clk_mac → clk_sys |
| DMA Prefetch | 128-bit | 16 | 寄存器 FIFO | clk_sys → clk_mac |
| 时间戳 FIFO | 64-bit | 16 | 寄存器 FIFO | clk_ts → clk_sys |
| Security FIFO | 128-bit | 8 | 寄存器 FIFO | clk_mac → sec_accel_aclk |

**格雷码指针**: 读写指针各用 N+1 bit Gray 编码，确保跨时钟域采样一致性。

### 3.4 总线桥接 CDC

| 桥接路径 | 方案 | 说明 |
|----------|------|------|
| AXI Master (clk_sys) → DMA Engine (clk_mac) | 异步 FIFO + 跨时钟桥 | 数据缓冲 + 控制握手 |
| CSR (clk_sys) → MAC Core (clk_mac) | 影子寄存器 + 脉冲同步 | 配置原子加载 |
| DMA Engine (clk_mac) → AXI Master (clk_sys) | 异步 FIFO + 信用机制 | 回写数据缓冲 |
| vPHC (clk_sys) → PHC (clk_ts) | 握手同步 | VM 偏移更新 |

---

## 4. 时钟门控

### 4.1 EEE (Energy-Efficient Ethernet) 模式

| 状态 | 条件 | 门控策略 |
|------|------|----------|
| `ACTIVE` | 正常传输 | 所有时钟运行 |
| `LPI_REQUEST` | 链路空闲计时达到阈值 | 准备进入低功耗 |
| `LPI` | 链路空闲 | **门控 `clk_tx_phy`, `clk_rx_phy`, `clk_pcs`** |
| `WAKE` | 新帧到达 | 快速唤醒 (≤10 μs)，顺序释放门控 |
| `TX_ACTIVE` | 仅发送方向活动 | **门控 `clk_rx_phy`** |
| `RX_ACTIVE` | 仅接收方向活动 | **门控 `clk_tx_phy`** |

**EEE 门控详细策略**:

```
LPI 请求触发 (tx_lpi_req=1, rx_lpi_ind=1)
  |
  +-- clk_tx_phy 门控: ICG 关闭 (lpi_gate_tx = 1)
  |   +-- 维持 TX 侧寄存器状态
  |   +-- SERDES TX 发送 LPI 码型 (/P/)
  |
  +-- clk_rx_phy 门控: ICG 关闭 (lpi_gate_rx = 1)
  |   +-- 维持 RX 侧 CDR 低速运行 (非完全关闭)
  |   +-- 监听 WAKE 码型 (/W/)
  |
  +-- clk_pcs 门控: ICG 关闭 (lpi_gate_pcs = 1)
      +-- 编码器/解码器暂停
      +-- 8b/10b 或 64b/66b 状态机保持

唤醒触发 (lpi_wake_req=1)
  |
  +-- 顺序释放: clk_pcs → clk_tx_phy → clk_rx_phy
  +-- 每级延迟 1~2 周期，确保无毛刺
  +-- lpi_wake_ack 在 clk_tx_phy 稳定后拉高
```

**门控时序要求**:

| 参数 | 典型值 | 最大值 | 说明 |
|------|--------|--------|------|
| `T_lpi_gate_setup` | 2 | 4 | clk_mac cycles | 门控使能建立 |
| `T_lpi_gate_release` | 2 | 4 | cycles | 门控释放顺序间隔 |
| `T_wake_total` | 4 | 10 | μs | 从 wake_req 到 ACTIVE |
| `ICG 毛刺抑制` | 0 | 0 | — | 必须无毛刺 |

### 4.2 动态时钟门控

| 门控目标 | 控制信号 | 条件 |
|----------|----------|------|
| `clk_mac` | `mac_cg_en` | DMA 通道全部关闭时 |
| `clk_ts` | `ts_cg_en` | PTP 功能禁用时 |
| `clk_switch` | `switch_cg_en` | Switch 功能禁用时 |
| `clk_pcs` | `pcs_cg_en` | 串行接口未使能时 |
| `clk_sec` | `sec_cg_en` | Security 功能全部禁用时 |
| `clk_crs_cd` | `crs_cd_cg_en` | 全双工模式或速率 ≥1G 时 |
| `plca_ref_clk` | `plca_cg_en` | 非 10BASE-T1S 模式时 |

### 4.3 门控时序要求

| 参数 | 要求 | 说明 |
|------|------|------|
| 时钟使能建立时间 | ≥2 cycles | 门控释放前预使能 |
| 时钟使能保持时间 | ≥2 cycles | 确保最后一笔事务完成 |
| 唤醒延迟 | ≤10 μs | LPI → ACTIVE 转换 |
| 时钟无毛刺 | 必需 | 使用 ICG (Integrated Clock Gating) |
| PLCA 参考时钟启动 | ≤2 μs | 从 `plca_cg_en` 到稳定 12.5 MHz |

---

## 5. 附录

### 5.1 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v0.1 | 2026-05-02 | Arch Agent | 初始模板创建 |
| v1.0 | 2026-05-11 | Arch Agent | 填充完整时钟/复位/CDC/门控内容 |
| **v1.2** | **2026-05-29** | **RTL Coding Agent** | **(PAD-REWORK-012) RTL-MAJ-003**  
| | | | 1. §1.5 PLCA 参考时钟补充 **时钟域归属** (`plca_ref_clk` 独立域，与 `clk_sys` 同源但异步处理)  
| | | | 2. §1.5/§3 补充 **CDC 策略**: CSR→PLCA 握手同步、PLCA→MAC 2-flop 同步器、PLCA→SYS 中断同步  
| | | | 3. §3.1/§3.2/§3.4 新增 PLCA 跨域同步条目 (单 bit/多 bit/总线桥接) |
| v1.1 | 2026-05-22 | Arch Agent | (PAD-REWORK-007)  
| | | | 1. 补充 6 个主时钟域 **典型频率值**: `clk_sys=200MHz`, `clk_mac=250MHz`, `clk_ts=250MHz` |
| | | | 2. `clk_tx_phy`/`clk_rx_phy` 按速率分档 (10M/100M/1G/2.5G/5G/10G) |
| | | | 3. 新增 §1.4 **CRS/CD 时钟域** (半双工模式，2.5/25 MHz，由 PHY 提供) |
| | | | 4. 新增 §1.5 **PLCA 参考时钟** (12.5 MHz，80 ns 周期，802.3cg) |
| | | | 5. 扩充 §4.1 **EEE LPI 时钟门控策略** (顺序释放、唤醒时序、ICG 毛刺抑制) |
| | | | 6. 新增 §2.4 **复位释放计数器参数化** (100 μs 延时按 `clk_sys` 计算，200 MHz → 15-bit) |
| | | | 7. 更新 §2.1/§2.2 复位源与复位域: 新增 `rst_switch_n`, `rst_sec_n`, `smu_rst_n` |
| | | | 8. 更新 §3 CDC 方案: 补充 LPI/CRS/vPHC/Security 跨域同步策略 |
| | | | 9. 更新 §4.2 动态门控: 补充 `clk_crs_cd`, `clk_sec`, `plca_ref_clk` 门控条件 |

### 5.2 待解决问题

| ID | 问题描述 | 优先级 | 负责人 | 状态 |
|----|----------|--------|--------|------|
| ISSUE-009 | 5G USXGMII 模式下 PCS_CLK 625 MHz 的时钟树优化 | P1 | Design Agent | 待分析 |
| ISSUE-010 | LPI 唤醒时序与 PHY 自动协商的交互 | P2 | Arch Agent | **已定义 (见 §4.1)** |
| ISSUE-011 | 多 XGMAC 实例间的时钟域一致性 (skew < 100 ps) | P1 | Design Agent | 待约束 |
| ISSUE-012 | SMU 复位与模块级软复位的优先级仲裁逻辑 | P1 | Arch Agent | **已定义 (见 §2.5.3)** |

---

*文档生成: 2026-05-22 | 状态: Draft | 下一步: Arch Review*
