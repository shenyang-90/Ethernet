# vPHC 硬件接口定义

> **文档**: Ethernet IP vPHC Hardware Interface Specification  
> **版本**: v1.0  
> **日期**: 2026-05-22  
> **作者**: Arch Agent / PAD Orchestrator  
> **依赖**: Arch Spec v1.8c §3.3, ISSUE-007  
> **状态**: Draft — PAD 补完交付物

---

## 1. 范围与定义

### 1.1 范围

本文档定义 Ethernet IP 中 **vPHC（Virtual PTP Hardware Clock）** 模块的硬件接口信号、CSR 寄存器映射、VM 解码逻辑与时序要求。

vPHC 使能条件：`PHC_COUNT=2` 且 `SUPPORT_VPHC=1`。

### 1.2 术语

| 术语 | 定义 |
|------|------|
| **PHC** | PTP Hardware Clock，物理硬件时钟，64-bit 纳秒计数器 |
| **vPHC** | Virtual PHC，通过硬件虚拟化机制向多个 VM 提供隔离的时间域视图 |
| **VM** | Virtual Machine，虚拟机，通过 VM_ID 标识 |
| **Xen IO Ring** | 共享内存环形缓冲区，用于 Hypervisor（dom0）与 Guest（domU）间批量通信 |
| **Region ID** | 内存访问权限区域标识，用于隔离不同 VM 的 CSR 访问空间 |
| **Crossbar** | PHC 到端口的绑定选择器，每端口独立选择 PHC0 或 PHC1 |

---

## 2. 架构概述

### 2.1 虚拟化模型

本 IP 的 vPHC 方案**不依赖软件 Xen 堆栈**，而是通过**硬件虚拟化层**直接实现：

- **物理层**: PHC0 / PHC1 两个独立 64-bit 计数器，同源 `clk_ts`（250MHz）
- **虚拟化层**: 每 VM 分配一个 **虚拟时间偏移寄存器**（`VM_x_TIME_OFFSET`），硬件自动完成 `T_virtual = T_physical + offset`
- **隔离层**: VM 通过 `VM_ID` 解码访问各自的时间域，非法访问触发 `vphc_access_violation_irq`
- **中断层**: 时间更新中断按 VM 分发，支持中断聚合（per-VM 或全局）

### 2.2 与 R-Car S4 的差异

| 特性 | R-Car S4 | 本 IP |
|------|---------|-------|
| 虚拟化机制 | Xen IO Ring（软件中介） | 硬件虚拟化层（直接寄存器映射） |
| VM 时间获取 | domU 通过 IO Ring 只读请求 | VM 直接 CSR 读取（无软件开销） |
| 延迟 | ~μs 级（Hypervisor 调度） | **~10ns 级**（纯硬件路径） |
| 漂移风险 | Xen 调度延迟引入抖动 | 偏移寄存器原子更新，无调度依赖 |
| 安全认证 | 未明确 ASIL 声明 | 与 PHC 模块共享 ASIL-B 基线 |

> **设计决策**: 车规场景下，Xen IO Ring 的软件中介层引入不可预测的调度延迟（~10μs~1ms），破坏 gPTP 的 ±25ns 精度目标。本 IP 采用硬件虚拟化层替代，VM 直接通过 AXI-Lite CSR 读取虚拟时间，消除 Hypervisor 依赖。

### 2.3 数据通路框图

```
┌─────────────────────────────────────────────────────────────┐
│                      vPHC Virtualization Layer               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐    │
│  │ VM0     │   │ VM1     │   │ VM2     │   │ VM3     │    │
│  │Offset[0]│   │Offset[1]│   │Offset[2]│   │Offset[3]│    │
│  └────┬────┘   └────┬────┘   └────┬────┘   └────┬────┘    │
│       │             │             │             │           │
│       └─────────────┴─────────────┴─────────────┘           │
│                         │                                   │
│                    ┌────┴────┐                              │
│                    │ VM MUX  │ ← VM_ID 解码                 │
│                    │(选择   │                              │
│                    │ Offset) │                              │
│                    └────┬────┘                              │
│                         │                                   │
│       ┌─────────────────┼─────────────────┐                 │
│       │                 │                 │                 │
│  ┌────┴────┐       ┌────┴────┐       ┌────┴────┐           │
│  │  Adder  │       │  Adder  │       │  Adder  │           │
│  │T0+Off[0]│       │T1+Off[1]│       │T0+Off[2]│           │
│  └────┬────┘       └────┬────┘       └────┬────┘           │
│       │                 │                 │                 │
│  ┌────┴────┐       ┌────┴────┐       ┌────┴────┐           │
│  │ VM0_T   │       │ VM1_T   │       │ VM2_T   │           │
│  │(CSR)    │       │(CSR)    │       │(CSR)    │           │
│  └─────────┘       └─────────┘       └─────────┘           │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
               ┌────┴────┐       ┌────┴────┐
               │  PHC0   │       │  PHC1   │
               │64b计数器 │       │64b计数器 │
               │clk_ts域 │       │clk_ts域 │
               └─────────┘       └─────────┘
```

---

## 3. 硬件信号定义

### 3.1 顶层接口信号

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `clk_ts` | Input | 1 | — | PHC 参考时钟（250MHz） |
| `rst_n_ts` | Input | 1 | clk_ts | PHC 域异步复位，低有效 |
| `vm_id[3:0]` | Input | 4 | clk_sys | 当前访问 VM 标识（来自 SoC Hypervisor 或 AXI ID） |
| `vm_valid` | Input | 1 | clk_sys | VM_ID 有效指示（高有效） |
| `phc_sel` | Input | 1 | clk_sys | PHC 选择：0=PHC0, 1=PHC1（per-VM 可配） |
| `vphc_csr_addr[11:0]` | Input | 12 | clk_sys | AXI-Lite CSR 地址 |
| `vphc_csr_wdata[31:0]` | Input | 32 | clk_sys | CSR 写数据 |
| `vphc_csr_wr` | Input | 1 | clk_sys | CSR 写使能 |
| `vphc_csr_rd` | Input | 1 | clk_sys | CSR 读使能 |
| `vphc_csr_rdata[31:0]` | Output | 32 | clk_sys | CSR 读数据 |
| `vphc_csr_rvalid` | Output | 1 | clk_sys | CSR 读数据有效 |
| `vphc_csr_ready` | Output | 1 | clk_sys | CSR 接口就绪 |
| `vphc_update_irq` | Output | 1 | clk_sys | 全局 vPHC 时间更新中断（脉冲，可配周期） |
| `vphc_vm_irq[15:0]` | Output | 16 | clk_sys | Per-VM 虚拟时间更新中断（每个 VM 独立） |
| `vphc_access_violation_irq` | Output | 1 | clk_sys | VM 访问越权中断（非法 Region 或 VM_ID） |
| `vphc_pps_out[15:0]` | Output | 16 | clk_ts | Per-VM PPS 输出（可选，`SUPPORT_VPHC_PPS=1`） |

> **VM_ID 来源**: 本 IP 不强制要求 AXI 用户信号携带 VM_ID。SoC 集成方可选择：
> - **方案 A**: AXI AWID/ARID 高 4bit 编码 VM_ID（推荐，零额外信号）
> - **方案 B**: 独立 `vm_id` 端口，由 SoC 总线矩阵根据地址范围译码
> - **方案 C**: CSR 基地址按 VM 分区域（`BASE + VM_ID × 0x100`），硬件自动提取 VM_ID

### 3.2 PHC → vPHC 数据通路内部信号

| 信号名 | 方向 | 位宽 | 时钟域 | 说明 |
|--------|------|------|--------|------|
| `phc0_sec[31:0]` | Input | 32 | clk_ts | PHC0 当前秒 |
| `phc0_ns[31:0]` | Input | 32 | clk_ts | PHC0 当前纳秒 |
| `phc1_sec[31:0]` | Input | 32 | clk_ts | PHC1 当前秒 |
| `phc1_ns[31:0]` | Input | 32 | clk_ts | PHC1 当前纳秒 |
| `vm_offset_sec[15:0][31:0]` | Internal | 32×16 | clk_ts | 每 VM 秒偏移（16 VM max） |
| `vm_offset_ns[15:0][31:0]` | Internal | 32×16 | clk_ts | 每 VM 纳秒偏移 |
| `vm_phc_sel[15:0]` | Internal | 1×16 | clk_sys | 每 VM 的 PHC 选择 |
| `vm_region_id[15:0][3:0]` | Internal | 4×16 | clk_sys | 每 VM 的 Region ID |

---

## 4. VM 解码与权限控制逻辑

### 4.1 VM_ID 解码

```verilog
// VM_ID 有效性检查
wire vm_id_valid = (vm_id < VM_MAX_COUNT) && vm_valid;

// Region ID 检查（CSR 访问时）
wire [3:0] access_region = vphc_csr_addr[11:8];  // 地址高 4bit 编码 Region
wire [3:0] vm_region     = vm_region_id[vm_id];
wire region_match        = (access_region == vm_region) || (vm_id == 0);  // VM0=dom0，全权限

// 访问权限判定
wire access_allowed = vm_id_valid && region_match;
wire access_denied  = vm_id_valid && !region_match;
```

### 4.2 Region ID 分级策略

| Region ID | 访问权限 | 说明 |
|:---------:|:---------|------|
| `0x0` | **Full Access** | dom0 / Hypervisor：读写所有 VM 偏移寄存器，配置 VM 映射表 |
| `0x1~0xE` | **Self Only** | domU：仅读写本 VM 的 `VM_x_TIME_OFFSET`，只读物理 PHC |
| `0xF` | **Read-Only** | 诊断/监控：只读所有虚拟时间，不可修改偏移 |

> **默认映射**: VM0 → Region 0x0（dom0），VM1~VM15 → Region 0x1~0xF（domU）。
> **动态重配**: dom0 可通过 `VM_REGION_ID[vm_id]` 寄存器修改映射，需 `rst_n` 或软件同步后生效。

### 4.3 PHC 选择 MUX

每 VM 独立选择绑定 PHC0 或 PHC1：

```verilog
// VM 虚拟时间 = 物理 PHC + VM 偏移
wire [31:0] sel_sec = vm_phc_sel[vm_id] ? phc1_sec : phc0_sec;
wire [31:0] sel_ns  = vm_phc_sel[vm_id] ? phc1_ns  : phc0_ns;

wire [31:0] vm_virt_sec = sel_sec + vm_offset_sec[vm_id];
wire [31:0] vm_virt_ns  = sel_ns  + vm_offset_ns[vm_id];

// 纳秒进位处理（ns ≥ 1e9 时秒+1）
wire ns_carry = (vm_virt_ns >= 32'd1_000_000_000);
assign vm_time_sec = vm_virt_sec + {31'b0, ns_carry};
assign vm_time_ns  = ns_carry ? (vm_virt_ns - 32'd1_000_000_000) : vm_virt_ns;
```

**时序约束**: 加法器 + MUX 路径需在 `clk_sys` 单周期内完成（建议 `clk_sys ≥ 100MHz`，即 ≤10ns 组合逻辑延迟）。

---

## 5. CSR 寄存器映射

### 5.1 寄存器总览

基地址：`0x1_1000`（紧邻 PHC 寄存器块 `0x1_0800` 之后，见 Arch Spec §3.3.7）

| 寄存器名 | 偏移 | 访问 | 位宽 | 说明 |
|---------|------|:----:|:----:|------|
| `VPHC_CTRL` | 0x000 | RW | 32 | 全局控制：使能、VM 数量、PPS 使能 |
| `VPHC_STATUS` | 0x004 | RO | 32 | 状态：更新忙、错误标志、VM 在线位图 |
| `VPHC_IRQ_MASK` | 0x008 | RW | 32 | 中断掩码：per-VM + 全局 + violation |
| `VPHC_IRQ_STAT` | 0x00C | W1C | 32 | 中断状态：写 1 清除 |
| `VPHC_UPDATE_PERIOD` | 0x010 | RW | 32 | 自动更新周期（μs，0=禁用） |
| `VM_MAX_COUNT` | 0x014 | RW | 4 | 有效 VM 数量（1~16，默认 4） |
| `VM_PHC_SEL[0]` | 0x020 | RW | 1 | VM0 PHC 选择（0=PHC0, 1=PHC1） |
| `VM_PHC_SEL[1]` | 0x024 | RW | 1 | VM1 PHC 选择 |
| ... | ... | ... | ... | ... |
| `VM_PHC_SEL[15]` | 0x05C | RW | 1 | VM15 PHC 选择 |
| `VM_REGION_ID[0]` | 0x060 | RW | 4 | VM0 Region ID（默认 0x0） |
| `VM_REGION_ID[1]` | 0x064 | RW | 4 | VM1 Region ID（默认 0x1） |
| ... | ... | ... | ... | ... |
| `VM_REGION_ID[15]` | 0x09C | RW | 4 | VM15 Region ID |
| `VM0_TIME_OFFSET_SEC` | 0x100 | RW | 32 | VM0 秒偏移 |
| `VM0_TIME_OFFSET_NS` | 0x104 | RW | 32 | VM0 纳秒偏移 |
| `VM0_VIRT_TIME_SEC` | 0x108 | RO | 32 | VM0 虚拟时间秒（硬件实时计算） |
| `VM0_VIRT_TIME_NS` | 0x10C | RO | 32 | VM0 虚拟时间纳秒 |
| ... | ... | ... | ... | 每 VM 0x20 字节间距 |
| `VM15_TIME_OFFSET_SEC` | 0x300 | RW | 32 | VM15 秒偏移 |
| `VM15_TIME_OFFSET_NS` | 0x304 | RW | 32 | VM15 纳秒偏移 |
| `VM15_VIRT_TIME_SEC` | 0x308 | RO | 32 | VM15 虚拟时间秒 |
| `VM15_VIRT_TIME_NS` | 0x30C | RO | 32 | VM15 虚拟时间纳秒 |

### 5.2 寄存器位定义

#### VPHC_CTRL (0x000)

| 位 | 字段 | 说明 |
|:--:|------|------|
| 0 | `VPHC_EN` | vPHC 全局使能（1=使能，0=直通物理 PHC） |
| 1 | `PPS_EN` | Per-VM PPS 输出使能 |
| 2 | `IRQ_MODE` | 中断模式：0=全局聚合，1=per-VM 独立 |
| 3 | `UPDATE_AUTO` | 自动更新模式：1=周期性 `vphc_update_irq`，0=仅软件触发 |
| 7:4 | `Reserved` | — |
| 15:8 | `VM_COUNT` | 有效 VM 数量 - 1（0=1 VM，15=16 VM） |
| 31:16 | `Reserved` | — |

#### VPHC_STATUS (0x004)

| 位 | 字段 | 说明 |
|:--:|------|------|
| 15:0 | `VM_ONLINE` | 每 VM 在线状态位图（1=该 VM 已初始化偏移） |
| 16 | `UPDATE_BUSY` | 时间更新正在进行（多 VM 同时访问时原子锁） |
| 17 | `VIOLATION_FLAG` | 访问越权事件挂起 |
| 18 | `PHC0_LOSS` | PHC0 丢失锁指示（来自时钟监控） |
| 19 | `PHC1_LOSS` | PHC1 丢失锁指示 |
| 31:20 | `Reserved` | — |

#### VPHC_IRQ_MASK / VPHC_IRQ_STAT (0x008 / 0x00C)

| 位 | 字段 | 说明 |
|:--:|------|------|
| 15:0 | `VM_UPDATE` | Per-VM 时间更新中断 |
| 16 | `GLOBAL_UPDATE` | 全局时间更新中断 |
| 17 | `VIOLATION` | 访问越权中断 |
| 18 | `PHC0_LOSS` | PHC0 时钟丢失 |
| 19 | `PHC1_LOSS` | PHC1 时钟丢失 |
| 31:20 | `Reserved` | — |

### 5.3 虚拟时间读取时序

```
Cycle:  1       2       3       4       5
        │       │       │       │       │
ADDR ──┼─0x108─┼───────┼───────┼───────┼──→ VM0_VIRT_TIME_SEC
        │       │       │       │       │
RD  ───┼──1────┼───────┼───────┼───────┼──→
        │       │       │       │       │
RVALID─┼───────┼───────┼──1────┼───────┼──→ 数据有效
        │       │       │       │       │
RDATA──┼───────┼───────┼─sec───┼───────┼──→ 虚拟时间秒[31:0]
```

**读取延迟**: 2 个 `clk_sys` 周期（地址译码 + 加法器路径）。
**注意**: `VMx_VIRT_TIME_SEC/NS` 为**组合输出**，无时钟采样，读取值反映当前物理 PHC + 偏移的实时值。

---

## 6. 时序与性能

### 6.1 虚拟时间精度

| 参数 | 值 | 说明 |
|------|-----|------|
| 物理 PHC 分辨率 | 4 ns | 250MHz `clk_ts` |
| 虚拟时间分辨率 | 4 ns | 与物理 PHC 相同（偏移寄存器 32-bit 纳秒） |
| VM→虚拟时间延迟 | ≤10 ns | `clk_sys` 单周期加法器 + MUX（@100MHz） |
| 偏移更新原子性 | 64-bit | 秒 + 纳秒同步更新，无撕裂 |
| 多 VM 并发读取 | 全并发 | 每 VM 独立组合逻辑，无仲裁延迟 |

### 6.2 中断时序

| 中断源 | 触发条件 | 脉冲宽度 | 清除方式 |
|--------|---------|---------|---------|
| `vphc_update_irq` | `VPHC_UPDATE_PERIOD` 到期 | 1 `clk_sys` | W1C `VPHC_IRQ_STAT[16]` |
| `vphc_vm_irq[x]` | 同全局，per-VM 模式 | 1 `clk_sys` | W1C `VPHC_IRQ_STAT[x]` |
| `vphc_access_violation_irq` | 非法 Region 访问 | 1 `clk_sys` | W1C `VPHC_IRQ_STAT[17]` |

**中断聚合**: 当 `IRQ_MODE=0`（全局），所有 VM 更新合并为单个 `vphc_update_irq`，软件通过读取 `VPHC_STATUS[15:0]` 位图判断哪个 VM 触发。

### 6.3 PPS 输出（可选）

| 参数 | 值 |
|------|-----|
| 输出数量 | `VM_COUNT`（每 VM 一个） |
| 输出域 | `clk_ts`（与 PHC 同步） |
| 精度 | ±4 ns（单 `clk_ts` 周期） |
| 周期 | 1 秒（固定） |
| 脉宽 | 4~100 ms 可配（`VPHC_PPS_WIDTH` 寄存器） |
| 使能 | `VPHC_CTRL[1]` |

---

## 7. 安全机制（ASIL-B）

### 7.1 ECC 保护

| 存储单元 | ECC 策略 | 说明 |
|---------|---------|------|
| `vm_offset_sec/ns` 寄存器组 | SECDED | 16 VM × 2 × 32bit，单 bit 纠错 / 双 bit 检测 |
| `vm_phc_sel` / `vm_region_id` | Parity | 配置寄存器偶校验 |

### 7.2 访问超时

- CSR 访问若 `vphc_csr_ready` 未在 256 个 `clk_sys` 周期内拉高 → 触发 `CSR_TIMEOUT` 报警
- 超时基线：`ENABLE_CSR_TIMEOUT=1` 时使能（见 Arch Spec §1.4.3）

### 7.3 非法配置拒绝

| 非法条件 | 硬件行为 |
|---------|---------|
| `VM_ID ≥ VM_MAX_COUNT` | 访问忽略，`VIOLATION_IRQ` 触发 |
| `Region 不匹配` | 写忽略 / 读返回 0，`VIOLATION_IRQ` 触发 |
| 偏移更新时纳秒 ≥ 1e9 | 自动秒进位，无溢出（硬件自动处理） |
| `PHC_COUNT=1` 时 `SUPPORT_VPHC=1` | 配置阶段报错（编译时检查），运行时 `VPHC_EN` 无效 |

---

## 8. 集成指南

### 8.1 SoC 集成要点

1. **VM_ID 来源**: 推荐复用 AXI AWID/ARID 高 4bit，总线矩阵在地址路由阶段提取
2. **Hypervisor 适配**: 本 IP 硬件虚拟化层**不绑定特定 Hypervisor**。Xen/KVM/QNX 仅需：
   -  dom0 驱动：配置 `VM_PHC_SEL` / `VM_REGION_ID` / `VM_TIME_OFFSET`
   -  domU 驱动：读取 `VMx_VIRT_TIME_SEC/NS` CSR
3. **时钟要求**: `clk_sys` ≥ 100MHz，确保虚拟时间加法器单周期完成
4. **复位顺序**: `rst_n_ts` → 释放 PHC 计数器 → 软件初始化 VM 偏移 → 置位 `VPHC_EN`

### 8.2 与 Arch Spec 的交叉引用

| Arch Spec 章节 | 本文档对应 |
|---------------|-----------|
| §3.3.1 双 PHC + Crossbar | §2.1, §4.3 PHC 选择 MUX |
| §3.3.7 PHC 寄存器映射 | §5.1 基地址 0x1_1000（紧邻 PHC 块） |
| §1.4.1 `PHC_COUNT`/`SUPPORT_VPHC` | §1.1, §7.3 使能条件 |
| §1.4.3 `ASIL_LEVEL`/`ENABLE_CSR_TIMEOUT` | §7.2 访问超时 |
| §6.2.6 PTP 精度目标 | §6.1 ±10ns 物理 / ±25ns 虚拟化 |

---

## 9. 版本历史

| 版本 | 日期 | 作者 | 变更说明 |
|------|------|------|---------|
| v1.0 | 2026-05-22 | PAD Orchestrator | 初始版本：基于 Arch Spec v1.8c ISSUE-007 决议，定义硬件虚拟化层替代 Xen IO Ring 方案 |

---

## 10. 待 EDR 阶段细化项

| # | 项目 | 负责人 | 说明 |
|---|------|--------|------|
| 1 | 加法器时序闭合 | Design Agent | 确认 `clk_sys=100/200MHz` 时 64-bit 加法 + MUX 路径延迟 |
| 2 | AXI-Lite CSR 接口集成 | Design Agent | 与现有 CSR 控制器的地址译码拼接 |
| 3 | PPS 输出 IO Buffer | Design Agent | 若使能 PPS，需专用 pad 或复用 GPIO |
| 4 | 虚拟时间原子读取验证 | Verification Agent | 确认 32-bit 分两次读取时 PHC 未跨越 1e9 边界 |
| 5 | VM 越权攻击测试 | Verification Agent | 非法 VM_ID / Region 访问的负面验证 |

---

*文档结束 | Ethernet IP vPHC Hardware Interface Specification v1.0*
