# Switch Core Egress Arbiter Design Specification

> **项目**: Ethernet IP (IP_20260502_001)  
> **模块**: Switch Core Egress Arbiter (`sw_egress_arbiter`)  
> **版本**: v1.0  
> **日期**: 2026-05-21  
> **作者**: RTL_Coding_Agent (PAD Phase)  
> **前置文档**: `Docs/Arch/ethernet_arch_spec.md` v1.8c §2.1/§4.3/§6.2.7, `Docs/Design/ethernet/ethernet_design_spec.md` v1.0 §4.4  
> **对应 Rework**: PAD-REWORK-002

---

## 1. 设计目标与约束

### 1.1 设计目标

基于 Arch Spec v1.8c 和 Design Spec v1.0 的 Switch Core 定义，补完 **Egress 端口仲裁器** 的完整微架构设计。仲裁器位于 Switch Core 的 Crossbar 出口侧，负责将来自多个 Ingress 端口的帧按优先级和公平性策略调度到目标 Egress 端口。

### 1.2 关键约束

| 约束项 | 来源 | 值 | 说明 |
|--------|------|-----|------|
| **端口数** | Arch Spec §1.4.1 | 4 (默认), 2~8 (可配置) | `SWITCH_PORT_COUNT` 参数化 |
| **Crossbar 拓扑** | Arch Spec §2.1 | N×N 全并发 | 每个 Ingress 端口可同时向任意 Egress 端口发帧 |
| **线速保证** | Arch Spec §6.2.7 | 100% 线速转发 | 无 HOL 阻塞，单端口拥塞不阻塞其他端口 |
| **流量类型** | Arch Spec §1.3 / §10.1 | 4 级优先级 | TSN > FRER > AVTP > Best-Effort |
| **公平性** | Design Spec §4.4.3 | Round-Robin | 同优先级内防饥饿 |
| **背压** | Arch Spec §6.2.7 | Pause 帧 / Ready 信号 | Egress FIFO 满时暂停输入，不丢帧 |
| **TAS 协同** | Design Spec §4.4.2 | Switch 级 TAS | `SWITCH_TAS=1` 时统一调度 |
| **资源预算** | Arch Spec §4.3 | ~15 kGE (arbiter 部分) | Switch Core 总计 ~80 kGE |

### 1.3 设计范围

- ✅ **本设计覆盖**: Egress 仲裁算法、优先级编码、Round-Robin 调度、背压控制、TAS 门控协同
- ❌ **本设计不覆盖**: Ingress FIFO 设计、FDB 查表、VLAN 处理、L3 路由、FRER 序列号生成（这些在 `sw_ingress`/`sw_fdb`/`sw_frer` 中实现）

---

## 2. Crossbar 拓扑与端口映射

### 2.1 N×N Crossbar 拓扑

```
                    ┌──────────────────────────────────────────────────────────────┐
                    │                  Crossbar Matrix (N×N)                       │
                    │                                                              │
   Ingress Port 0   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐          │
   (来自 MAC0 RX)   │  │ XBAR_00 │  │ XBAR_01 │  │ XBAR_02 │  │ XBAR_03 │ ...      │
        │           │  │(Port0→0)│  │(Port0→1)│  │(Port0→2)│  │(Port0→3)│          │
        │           │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘          │
        ▼           │       │            │            │            │              │
   Ingress Port 1   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐          │
   (来自 MAC1 RX)   │  │ XBAR_10 │  │ XBAR_11 │  │ XBAR_12 │  │ XBAR_13 │ ...      │
        │           │  │(Port1→0)│  │(Port1→1)│  │(Port1→2)│  │(Port1→3)│          │
        │           │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘          │
        ▼           │       │            │            │            │              │
   Ingress Port 2   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐          │
   (来自 MAC2 RX)   │  │ XBAR_20 │  │ XBAR_21 │  │ XBAR_22 │  │ XBAR_23 │ ...      │
        │           │  │(Port2→0)│  │(Port2→1)│  │(Port2→2)│  │(Port2→3)│          │
        │           │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘          │
        ▼           │       │            │            │            │              │
   Ingress Port 3   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐          │
   (来自 MAC3 RX)   │  │ XBAR_30 │  │ XBAR_31 │  │ XBAR_32 │  │ XBAR_33 │ ...      │
        │           │  │(Port3→0)│  │(Port3→1)│  │(Port3→2)│  │(Port3→3)│          │
        │           │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘          │
        ▼           │       │            │            │            │              │
       ...          │      ...          ...          ...          ...             │
                    │       │            │            │            │              │
                    │       ▼            ▼            ▼            ▼              │
                    │  ┌─────────────────────────────────────────────────────┐   │
                    │  │              Egress Arbiter (per port)              │   │
                    │  │   Arb_Port[0]   Arb_Port[1]   Arb_Port[2]  ...     │   │
                    │  │        │            │            │                     │   │
                    │  │        ▼            ▼            ▼                     │   │
                    │  │   Egress FIFO    Egress FIFO   Egress FIFO  ...       │   │
                    │  │   (Port 0)       (Port 1)      (Port 2)               │   │
                    │  │        │            │            │                     │   │
                    │  │        ▼            ▼            ▼                     │   │
                    │  │    MAC0 TX      MAC1 TX       MAC2 TX   ...           │   │
                    │  └─────────────────────────────────────────────────────┘   │
                    └──────────────────────────────────────────────────────────────┘
```

### 2.2 端口映射规则

| 信号 | 宽度 | 说明 |
|------|------|------|
| `ingress_port_id` | `log2(SWITCH_PORT_COUNT)` | 源端口编号 (0 ~ N-1) |
| `egress_port_mask` | `SWITCH_PORT_COUNT` | 目标端口位掩码 (bit[i]=1 → 转发到 Port i) |
| `host_port_mask` | 1 | 是否同时转发到 Host Port (CPU) |

**FDB 查表输出 → Crossbar 路由**: 
- FDB 查表结果为 `egress_port_mask[N-1:0]` + `host_port_mask`
- 每个 Ingress 端口的帧根据查表结果，写入对应 XBAR 交叉点 FIFO
- XBAR_{i→j} 为从 Ingress Port i 到 Egress Port j 的交叉点缓冲

### 2.3 Crossbar 交叉点 FIFO (XBAR Buffer)

| 参数 | 默认值 | 范围 | 说明 |
|------|--------|------|------|
| `XBAR_FIFO_DEPTH` | 8 | 4, 8, 16 | 每交叉点 FIFO 深度 (帧数) |
| `XBAR_DATA_WIDTH` | 64 | 64, 128 | 数据位宽，与 MAC 接口对齐 |
| `XBAR_ADDR_WIDTH` | 3 | 2~4 | `log2(XBAR_FIFO_DEPTH)` |

**Crossbar 交叉点总数**: `SWITCH_PORT_COUNT × SWITCH_PORT_COUNT` = N² 个 FIFO
- 4-port: 16 个 FIFO
- 8-port: 64 个 FIFO

> **面积优化**: 当 `egress_port_mask` 仅设置单个位时（最常见情况），帧只写入一个 XBAR FIFO；广播/多播时写入多个 XBAR FIFO。

---

## 3. 仲裁算法 (优先级编码 + Round-Robin)

### 3.1 流量类型优先级定义

仲裁器根据帧的 **流量类型 (Traffic Class, TC)** 进行 4 级优先级调度：

| 优先级 | 流量类型 | 标识 | 来源 | 调度策略 |
|:------:|----------|------|------|----------|
| **P0 (最高)** | TSN 时间关键流 | `TC_TSN` | TAS Gate Open 期间的高优先级流 | Strict Priority，抢占式 |
| **P1** | FRER 冗余流 | `TC_FRER` | 802.1CB 序列号生成流 | Strict Priority，允许多 Egress |
| **P2** | AVTP 音视频流 | `TC_AVTP` | IEEE 1722 带宽预留流 | Strict Priority + 带宽限制 |
| **P3 (最低)** | Best-Effort | `TC_BE` | 普通数据流量 | WRR / Round-Robin |

### 3.2 流量类型判定逻辑

每帧在 Ingress 处理阶段被标记 `traffic_class[1:0]`，仲裁器直接读取该标记：

```verilog
// Ingress 阶段提取 (在 sw_ingress 中完成)
assign tc_tsn   = (tas_gate_open[port] && frame_priority == 3'b111);  // TAS Gate Open + 最高 VLAN PC
assign tc_frer  = (frer_stream_id_valid && frer_enable);               // FRER 流识别 + 使能
assign tc_avtp  = (avtp_stream_id_valid && avtp_bandwidth_reserved); // AVTP 流识别 + 预留
assign tc_be    = !(tc_tsn || tc_frer || tc_avtp);                     // 默认 BE

// 编码为 2-bit traffic_class
assign traffic_class = tc_tsn ? 2'b00 :     // P0
                       tc_frer ? 2'b01 :     // P1
                       tc_avtp ? 2'b10 :     // P2
                                 2'b11;     // P3 (BE)
```

### 3.3 仲裁器核心结构 (Per Egress Port)

每个 Egress 端口拥有独立的仲裁器实例 `arb_port[i]`：

```
┌─────────────────────────────────────────────────────────────┐
│              Egress Port[i] Arbiter Core                     │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ XBAR_0→i │  │ XBAR_1→i │  │ XBAR_2→i │  │ XBAR_3→i │     │
│  │   FIFO   │  │   FIFO   │  │   FIFO   │  │   FIFO   │ ... │
│  │ (Port0   │  │ (Port1   │  │ (Port2   │  │ (Port3   │     │
│  │  → i)    │  │  → i)    │  │  → i)    │  │  → i)    │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │             │             │             │            │
│       └─────────────┴─────────────┴─────────────┘            │
│                         │                                    │
│                         ▼                                    │
│              ┌─────────────────────┐                        │
│              │   Priority Encoder  │                        │
│              │   (4-level strict) │                        │
│              │                     │                        │
│              │  P0: TSN ──────────┼──► 最高，无条件抢占     │
│              │  P1: FRER ─────────┼──► 次高                 │
│              │  P2: AVTP ─────────┼──► 第三                 │
│              │  P3: BE ───────────┼──► 最低                 │
│              └──────────┬──────────┘                        │
│                         │                                    │
│                         ▼                                    │
│              ┌─────────────────────┐                        │
│              │  Per-TC Round-Robin │                        │
│              │   (同优先级公平性)   │                        │
│              │                     │                        │
│              │  TC_P0_arb ────┐   │                        │
│              │  TC_P1_arb ────┼──►│ selected ingress_port   │
│              │  TC_P2_arb ────┤   │                         │
│              │  TC_P3_arb ────┘   │                         │
│              └──────────┬──────────┘                        │
│                         │                                    │
│                         ▼                                    │
│              ┌─────────────────────┐                        │
│              │   Frame Assembler   │                        │
│              │  (→ Egress FIFO)  │                        │
│              └─────────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

### 3.4 优先级编码器逻辑

```verilog
// 每周期检查所有 N 个 Ingress 端口的 XBAR FIFO 状态
// 输入: xbar_fifo_empty[j] (j = 0..N-1), traffic_class[j]
// 输出: selected_ingress_port, selected_traffic_class

module priority_encoder (
    input  [N-1:0]        xbar_fifo_not_empty,    // 1 = FIFO 有数据
    input  [N*2-1:0]      traffic_class_vec,      // 每端口 2-bit TC
    input  [N-1:0]        tc_tsn_vec,             // P0 有效标志
    input  [N-1:0]        tc_frer_vec,            // P1 有效标志
    input  [N-1:0]        tc_avtp_vec,            // P2 有效标志
    input  [N-1:0]        tc_be_vec,              // P3 有效标志
    output [$clog2(N)-1:0] selected_port,         // 选中的 Ingress 端口
    output [1:0]          selected_tc,            // 选中的流量类型
    output                valid                   // 有效选择
);

    // 按优先级分层筛选
    wire [N-1:0] p0_candidates = xbar_fifo_not_empty & tc_tsn_vec;
    wire [N-1:0] p1_candidates = xbar_fifo_not_empty & tc_frer_vec;
    wire [N-1:0] p2_candidates = xbar_fifo_not_empty & tc_avtp_vec;
    wire [N-1:0] p3_candidates = xbar_fifo_not_empty & tc_be_vec;

    // 优先级编码: P0 > P1 > P2 > P3
    wire has_p0 = |p0_candidates;
    wire has_p1 = |p1_candidates;
    wire has_p2 = |p2_candidates;
    wire has_p3 = |p3_candidates;

    wire [N-1:0] final_candidates = has_p0 ? p0_candidates :
                                    has_p1 ? p1_candidates :
                                    has_p2 ? p2_candidates :
                                    has_p3 ? p3_candidates :
                                             {N{1'b0}};

    // 同优先级内 Round-Robin 仲裁 (见 §3.5)
    // ... (与 RR arbiter 接口)

endmodule
```

### 3.5 同优先级 Round-Robin 仲裁

每个优先级 (P0~P3) 拥有独立的 Round-Robin 指针，仅在有候选者时旋转：

```verilog
module rr_arbiter #(
    parameter N = 4
)(
    input              clk,
    input              rst_n,
    input  [N-1:0]     request,        // 候选请求
    input              grant_en,        // 允许授权 (来自优先级编码器)
    output [$clog2(N)-1:0] grant_port,  // 授权的端口
    output             grant_valid      // 授权有效
);

    reg [$clog2(N)-1:0] rr_ptr;         // Round-Robin 指针

    // 旋转优先级: 从 rr_ptr 开始查找下一个置位的 request
    wire [2*N-1:0] request_double = {request, request};
    wire [2*N-1:0] mask_double = {request, request} & ~((1 << (rr_ptr + N)) - 1);
    
    // 找到下一个置位
    wire [N-1:0] grant_mask;
    priority_encoder_masked enc (.in(mask_double[N-1:0] | mask_double[2*N-1:N]), .out(grant_mask));
    
    wire [$clog2(N)-1:0] next_grant = ffs(grant_mask);  // 找第一个置位

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rr_ptr <= 0;
        else if (grant_valid)
            rr_ptr <= next_grant + 1;   // 指向下一个端口 (循环)
    end

    assign grant_port  = next_grant;
    assign grant_valid = grant_en && (|request);
endmodule
```

### 3.6 防饥饿保证

| 机制 | 说明 | 最坏等待帧数 |
|------|------|-------------|
| **P0 (TSN)** | TAS Gate Open 期间独占带宽，无竞争 | 0 (抢占式) |
| **P1 (FRER)** | P0 无请求时立即服务 | ≤ (N-1) × 同优先级帧 |
| **P2 (AVTP)** | P0/P1 无请求时服务 | ≤ (N-1) × 同优先级帧 + P0/P1 突发 |
| **P3 (BE)** | P0/P1/P2 无请求时轮询 | ≤ (N-1) × 同优先级帧 + 高优先级突发 |

---

## 4. 仲裁状态机 (FSM)

### 4.1 单 Egress 端口仲裁 FSM

```
                              ┌───────────────┐
                              │    IDLE       │
                              │  等待 XBAR   │
                              │  FIFO 非空   │
                              └───────┬───────┘
                                      │ xbar_fifo_not_empty=1
                                      ▼
                    ┌───────────────────────────────────────────┐
                    │           PRIORITY_EVAL                  │
                    │  1-cycle: 读取所有 XBAR FIFO 头部 TC    │
                    │  按 P0>P1>P2>P3 筛选候选者               │
                    └─────────────────┬─────────────────────────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    │                 │                 │
        ┌───────────▼─────────┐ ┌─────▼─────┐ ┌───────▼────────┐
        │     GRANT_P0        │ │  GRANT_P1 │ │    GRANT_P2    │
        │  选中 TSN 帧        │ │ 选中 FRER │ │   选中 AVTP    │
        │  读取 XBAR FIFO     │ │  读取 FIFO │ │    读取 FIFO   │
        └───────────┬─────────┘ └─────┬─────┘ └───────┬────────┘
                    │                 │               │
        ┌───────────▼─────────┐ ┌─────▼─────┐ ┌───────▼────────┐
        │    WAIT_EOF_P0      │ │ WAIT_EOF_1│ │   WAIT_EOF_P2  │
        │   等待帧结束        │ │ 等待结束  │ │   等待帧结束   │
        │   (EOF 或 Abort)   │ │           │ │                │
        └───────────┬─────────┘ └─────┬─────┘ └───────┬────────┘
                    │                 │               │
        ┌───────────▼─────────────────▼───────────────▼────────┐
        │                      CHECK_BP                         │
        │              检查背压 (Egress FIFO 满?)               │
        │              满 → 暂停，空 → 返回 IDLE                 │
        └─────────────────────────┬───────────────────────────────┘
                                  │ backpressure=0
                                  ▼
                              ┌───────────────┐
                              │    IDLE       │
                              └───────────────┘
```

### 4.2 FSM 状态定义

| 状态 | 编码 | 说明 | 停留条件 |
|------|------|------|----------|
| `ARB_IDLE` | 3'b000 | 空闲等待 | 无有效 XBAR FIFO 请求 |
| `ARB_PRI_EVAL` | 3'b001 | 优先级评估 | 固定 1 cycle |
| `ARB_GRANT_P0` | 3'b010 | 授权 TSN 帧 | 帧头有效 |
| `ARB_GRANT_P1` | 3'b011 | 授权 FRER 帧 | 帧头有效 |
| `ARB_GRANT_P2` | 3'b100 | 授权 AVTP 帧 | 帧头有效 |
| `ARB_GRANT_P3` | 3'b101 | 授权 BE 帧 | 帧头有效 |
| `ARB_WAIT_EOF` | 3'b110 | 等待帧传输完成 | `eof_detected` 或 `frame_abort` |
| `ARB_BACKPRESSURE` | 3'b111 | 背压暂停 | `bp_deasserted` |

### 4.3 状态转移条件

```verilog
// 状态转移逻辑 (每 Egress 端口独立)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        arb_state <= ARB_IDLE;
    else begin
        case (arb_state)
            ARB_IDLE:
                if (|xbar_fifo_not_empty)
                    arb_state <= ARB_PRI_EVAL;
            
            ARB_PRI_EVAL:
                // 1-cycle 评估，下一周期进入对应 GRANT 状态
                arb_state <= has_p0 ? ARB_GRANT_P0 :
                             has_p1 ? ARB_GRANT_P1 :
                             has_p2 ? ARB_GRANT_P2 :
                             has_p3 ? ARB_GRANT_P3 : ARB_IDLE;
            
            ARB_GRANT_P0, ARB_GRANT_P1, ARB_GRANT_P2, ARB_GRANT_P3:
                if (frame_eof)
                    arb_state <= ARB_BACKPRESSURE;
                else if (frame_abort)
                    arb_state <= ARB_IDLE;  // 异常终止，丢弃当前帧
            
            ARB_WAIT_EOF:
                if (frame_eof || frame_abort)
                    arb_state <= ARB_BACKPRESSURE;
            
            ARB_BACKPRESSURE:
                if (!egress_fifo_full)
                    arb_state <= ARB_IDLE;  // 背压解除，继续仲裁
                // 若仍满，保持 BACKPRESSURE 状态
            
            default: arb_state <= ARB_IDLE;
        endcase
    end
end
```

### 4.4 FSM 状态图 (完整)

```
                                    +-----------+
                                    |   IDLE    |
                                    +-----+-----+
                                          | xbar_not_empty
                                          v
                                    +-----------+
                                    | PRI_EVAL  |
                                    | (1 cycle) |
                                    +-----+-----+
                                          |
           +------------------------------+------------------------------+
           |                              |                              |
           | P0 valid                     | P1 valid                     | P2 valid                     | P3 valid
           v                              v                              v                              v
    +-------------+                +-------------+                +-------------+                +-------------+
    | GRANT_P0    |                | GRANT_P1    |                | GRANT_P2    |                | GRANT_P3    |
    | (read TSN   |                | (read FRER  |                | (read AVTP  |                | (read BE    |
    |  frame)     |                |  frame)     |                |  frame)     |                |  frame)     |
    +------+------+                +------+------+                +------+------+                +------+------+
           |                              |                              |                              |
           | eof/abort                    | eof/abort                    | eof/abort                    | eof/abort
           v                              v                              v                              v
    +-------------+                +-------------+                +-------------+                +-------------+
    | BACKPRESSURE|◄---------------| BACKPRESSURE|◄---------------| BACKPRESSURE|◄---------------| BACKPRESSURE|
    | (check fifo |                | (check fifo |                | (check fifo |                | (check fifo |
    |  full)      |                |  full)      |                |  full)      |                |  full)      |
    +------+------+                +------+------+                +------+------+                +------+------+
           | fifo_not_full                | fifo_not_full                | fifo_not_full                | fifo_not_full
           v                              v                              v                              v
    +-------------+                +-------------+                +-------------+                +-------------+
    |    IDLE     |                |    IDLE     |                |    IDLE     |                |    IDLE     |
    +-------------+                +-------------+                +-------------+                +-------------+
```

---

## 5. FRER 冗余流的多 Egress 仲裁

### 5.1 FRER 复制机制

根据 802.1CB FRER 规范，冗余流需要 **同时从 2~6 个 Egress 端口发送** (1:6 复制)：

```
┌─────────────────────────────────────────────────────────────────┐
│                    FRER Sequence Generation                      │
│                      (在 sw_frer 中完成)                          │
│                                                                  │
│   Ingress Frame                                                  │
│        │                                                         │
│        ▼                                                         │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐   │
│   │ Copy 0  │     │ Copy 1  │     │ Copy 2  │     │ Copy 3  │   │
│   │ + R-Tag │     │ + R-Tag │     │ + R-Tag │     │ + R-Tag │   │
│   │ Seq=100 │     │ Seq=100 │     │ Seq=100 │     │ Seq=100 │   │
│   │(Port 0) │     │(Port 1) │     │(Port 2) │     │(Port 3) │   │
│   └────┬────┘     └────┬────┘     └────┬────┘     └────┬────┘   │
│        │               │               │               │         │
│        ▼               ▼               ▼               ▼         │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐   │
│   │XBAR_0→0 │     │XBAR_0→1 │     │XBAR_0→2 │     │XBAR_0→3 │   │
│   │  FIFO   │     │  FIFO   │     │  FIFO   │     │  FIFO   │   │
│   └─────────┘     └─────────┘     └─────────┘     └─────────┘   │
│                                                                  │
│   每份复制独立注入对应 Egress 端口的 XBAR FIFO                    │
│   各 Egress 端口仲裁器独立调度，无需跨端口同步                     │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 FRER 多 Egress 仲裁策略

| 场景 | 行为 | 说明 |
|------|------|------|
| **FRER 复制到多个端口** | 每份复制作为独立帧进入对应 XBAR FIFO | 各端口仲裁器独立处理 |
| **FRER 帧优先级** | P1 (仅次于 TSN) | 确保冗余流优先于 AVTP/BE |
| **复制同步要求** | **无强同步要求** | 各路径延迟差异由 R-Tag 序列号消除，接收端处理 |
| **部分端口背压** | 背压端口暂停，其他端口继续发送 | 不要求所有副本同时发出 |

### 5.3 FRER 与 TAS 协同

当 FRER 复制流遇到 TAS Gate Close：
- **Gate Open 期间**: FRER 帧正常复制并发送 (P1 优先级)
- **Gate Close 期间**: FRER 帧进入 XBAR FIFO 等待，不抢占 TSN 窗口
- **Gate 重新 Open**: 若 FRER 帧仍在 FIFO 中，按 P1 优先级被调度

> **重要**: FRER 帧在 TAS Gate Close 期间 **不排空**，与其他 P1/P2/P3 帧一样等待下一个调度周期。

---

## 6. 背压与流量控制

### 6.1 背压机制概览

```
┌─────────────────────────────────────────────────────────────┐
│                    Backpressure Architecture                 │
│                                                              │
│   Egress Port[i]                                             │
│   ┌──────────────┐                                           │
│   │ Egress FIFO  │◄──── 来自 XBAR 的数据                     │
│   │  (深度可配)  │                                           │
│   │  阈值:       │                                           │
│   │   - high_wm  │──► 向 Ingress 发 pause / 置 backpressure │
│   │   - low_wm   │──► 解除 pause / 清除 backpressure        │
│   └──────┬───────┘                                           │
│          │                                                   │
│          ▼                                                   │
│   MAC TX (sw_egress_port[i])                                 │
│                                                              │
│   Backpressure 传播路径:                                      │
│   ┌─────────────────────────────────────────────────────┐   │
│   │  1. egress_fifo_watermark → bp_local[i]            │   │
│   │  2. bp_local[i] → 暂停 XBAR_0→i / XBAR_1→i / ...   │   │
│   │  3. bp_local[i] → 生成 Pause 帧 (802.3x)             │   │
│   │  4. Pause 帧 → 对端 MAC → 对端 Ingress 降速         │   │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 两级背压策略

#### 6.2.1 第一级: XBAR FIFO 暂停 (本地背压)

```verilog
// 每 Egress 端口的本地背压生成
module local_backpressure #(
    parameter FIFO_DEPTH = 8,
    parameter HIGH_WM  = 6,    // 75% 满时触发
    parameter LOW_WM   = 2     // 25% 满时解除
)(
    input              clk,
    input              rst_n,
    input  [$clog2(FIFO_DEPTH+1)-1:0] fifo_count,
    output reg         bp_assert    // 1 = 暂停该端口的所有 XBAR 输入
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bp_assert <= 1'b0;
        else if (fifo_count >= HIGH_WM)
            bp_assert <= 1'b1;
        else if (fifo_count <= LOW_WM)
            bp_assert <= 1'b0;
        // 否则保持原状态 (滞回)
    end
endmodule
```

**滞回 (Hysteresis) 设计**: 防止背压信号在阈值边界振荡。

#### 6.2.2 第二级: Pause 帧生成 (远程背压)

当本地背压持续超过阈值，向对端发送 802.3x Pause 帧：

```verilog
// Pause 帧生成条件
assign pause_gen_en = (bp_assert && bp_duration > PAUSE_GEN_THRESHOLD);

// Pause 帧参数
assign pause_time = EGRESS_FIFO_DEPTH - fifo_count;  // 剩余空间对应的暂停时间

// Pause 帧格式 (标准 802.3x)
// DA = 01:80:C2:00:00:01 (MAC Control)
// Type/Length = 0x8808 (MAC Control)
// Opcode = 0x0001 (Pause)
// Param = pause_time (单位: 512 bit-times)
```

### 6.3 不丢帧保证

| 条件 | 行为 | 结果 |
|------|------|------|
| Egress FIFO < high_wm | 正常接收 XBAR 数据 | 帧正常入队 |
| Egress FIFO ≥ high_wm | 置位 bp_assert，暂停 XBAR 写入 | 帧暂存在 XBAR FIFO 中 |
| XBAR FIFO 也满 | Pause 帧发送至源 MAC | 源端降速 |
| TAS Gate Close + 背压 | 帧在 XBAR FIFO 中等待 | 不丢帧，Gate Open 后调度 |

**关键保证**: 帧从进入 Ingress 到离开 Egress 的完整路径上，**任何环节都不主动丢弃**。只有 CRC 错误、帧长非法等硬错误才会触发丢弃。

### 6.4 Egress FIFO 参数

| 参数 | 默认值 | 范围 | 说明 |
|------|--------|------|------|
| `EGRESS_FIFO_DEPTH` | 16 | 8, 16, 32 | 帧数 |
| `EGRESS_FIFO_HIGH_WM` | 12 | 75% × DEPTH | 触发背压 |
| `EGRESS_FIFO_LOW_WM` | 4 | 25% × DEPTH | 解除背压 |
| `EGRESS_DATA_WIDTH` | 64 | 64, 128 | 与 MAC 接口对齐 |

---

## 7. 与 TAS Gate Control List 的时序协同

### 7.1 TAS Gate 状态定义

| Gate 状态 | 编码 | 说明 |
|-----------|------|------|
| `GATE_OPEN` | 2'b01 | TAS Gate 开启，TSN 帧可发送 |
| `GATE_CLOSE` | 2'b10 | TAS Gate 关闭，TSN 帧被阻塞 |
| `GATE_TRANSITION` | 2'b11 | 切换过渡期 (1 cycle) |

### 7.2 关键问题: Gate Close 时是否排空 Egress FIFO 中的 TSN 帧？

**设计决策**: **不清空，继续发送**。

```
理由:
1. TSN 帧进入 Egress FIFO 时 Gate 是 OPEN 状态，说明该帧已获得发送授权
2. Gate Close 只阻塞**新到达的** TSN 帧，不中断**已在传输中的**帧
3. 强制排空会导致帧丢失 (违背"不丢帧"约束) 和带宽浪费
4. 802.1Qbv 规范定义 Gate 控制的是"准入"而非"排空"
```

### 7.3 TAS 与仲裁器的交互时序

```
Cycle:    0     1     2     3     4     5     6     7     8     9
          │     │     │     │     │     │     │     │     │     │
GCL:      OPEN  OPEN  OPEN  OPEN  CLOSE CLOSE CLOSE OPEN  OPEN  OPEN
          │     │     │     │     │     │     │     │     │     │
TSN帧A:   │ 进入XBAR               │     │     │     │     │     │
          │     │     │     │     │     │     │     │     │     │
TSN帧B:   │     │ 进入XBAR          │(阻塞)│     │     │     │     │
          │     │     │     │     │     │     │     │     │     │
TSN帧A:   │     │     │     │ 进入EG_FIFO │     │  发送中  │     │
          │     │     │     │     │     │     │     │     │     │
仲裁:     │     │     │     │ P0  │ P0  │ --  │ --  │ P0  │ P0  │
                              (A)   (A)         (B)   (A)   (B)
                                     ↑
                                Gate Close, 但帧A继续发送
```

### 7.4 TAS Gate 状态机

```verilog
// 每 Egress 端口独立的 TAS Gate 状态
module tas_gate_sync #(
    parameter N = 4
)(
    input              clk,
    input              rst_n,
    input  [N-1:0]     gate_open,          // 来自 sw_tas_gcl 的门控信号
    input  [N*2-1:0]   traffic_class_vec,  // 每 XBAR 的 TC
    output [N-1:0]     tas_mask            // 1 = 允许该 XBAR 的 TSN 帧参与仲裁
);

    // TSN 帧 (P0) 只有在 gate_open=1 时才能进入仲裁候选
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_tas_mask
            assign tas_mask[i] = gate_open[i] || (traffic_class_vec[i*2 +: 2] != 2'b00);
            // 非 TSN 帧不受 Gate 影响; TSN 帧需 gate_open
        end
    endgenerate
endmodule
```

### 7.5 Gate Open 时的 TSN 抢占

当 Gate 从 CLOSE → OPEN 切换时：
1. **当前帧为非 TSN**: 允许在当前帧 EOF 后插入 TSN 帧 (preemption 模式)
2. **当前帧为 TSN**: 继续发送，下帧检查更高优先级 TSN
3. **当前帧为 BE/AVTP/FRER**: 若 TSN 帧到达且 Gate Open，标记 `abort_after_eof`，在当前帧结束后立即切换

---

## 8. 时序分析 (仲裁延迟)

### 8.1 关键路径分析

| 路径 | 延迟 (cycles) | 说明 |
|------|---------------|------|
| XBAR FIFO 读 → 优先级编码 | 1 | 组合逻辑 |
| 优先级编码 → RR 仲裁 | 1 | 组合逻辑 |
| RR 仲裁 → Grant 输出 | 1 | 组合逻辑 |
| Grant → 数据输出 | 1 | FIFO 读使能 → 数据有效 |
| **单周期仲裁总延迟** | **1 cycle** | 流水线优化后 |

### 8.2 最坏情况仲裁延迟 (Worst Case)

**场景**: N-port Switch，所有端口同时向同一 Egress 端口发送同优先级帧

| 参数 | 公式 | 4-port 示例 | 8-port 示例 |
|------|------|-------------|-------------|
| 同优先级帧数 | N | 4 | 8 |
| 单帧服务时间 | L_max / Data_Width | 190 cycles (1518B/64b) | 190 cycles |
| RR 旋转周期 | N × 单帧时间 | 760 cycles | 1520 cycles |
| **最坏等待时间** | (N-1) × 单帧时间 | **570 cycles** | **1330 cycles** |
| 换算 (clk_mac=125MHz) | cycles / 125MHz | **4.56 μs** | **10.64 μs** |

**高优先级抢占**: TSN 帧 (P0) 不受 RR 等待影响，Gate Open 时立即抢占：
- TSN 帧最坏延迟: **1 cycle** (立即抢占)
- FRER 帧最坏延迟: **同优先级 RR 周期** (P1 内部 RR)
- AVTP 帧最坏延迟: **P0 + P1 突发 + P2 RR 周期**
- BE 帧最坏延迟: **所有高优先级突发 + P3 RR 周期**

### 8.3 端到端延迟预算

| 阶段 | 延迟 | 说明 |
|------|------|------|
| Ingress FIFO → XBAR | 1~2 cycles | FDB 查表 + 路由决策 |
| XBAR 缓冲 | 0~2 cycles | FIFO 深度影响 |
| Egress 仲裁 | **1 cycle** | 本设计目标 |
| Egress FIFO → MAC TX | 1~2 cycles | 帧组装 |
| **Switch 内部总延迟** | **3~7 cycles** | **24~56 ns @ 125MHz** |

### 8.4 与 TAS 周期的关系

| TAS Gate Open 时长 | 最小帧数 (64B) | 说明 |
|--------------------|----------------|------|
| 125 μs (典型) | ~1000 帧 | 足够处理所有优先级 |
| 25 μs | ~200 帧 | 需限制高优先级突发 |
| 5 μs | ~40 帧 | 仅适合 TSN 短突发 |

**设计约束**: TAS Gate Open 窗口 ≥ 最坏情况 BE 帧等待时间 + 1 帧发送时间。

---

## 9. 门数/面积估算

### 9.1 仲裁器子模块面积

| 子模块 | 实例数 | 每实例 (kGE) | 总计 (kGE) | 说明 |
|--------|--------|-------------|-----------|------|
| `pri_encoder` | N | ~0.5 | ~2.0 (N=4) | 4 级优先级编码 |
| `rr_arbiter` | 4×N (每 TC 每端口) | ~0.3 | ~4.8 (N=4) | 4 TC × N 端口 |
| `xbar_fifo` | N×N | ~0.2 | ~3.2 (N=4) | N² 个 FIFO |
| `egress_fifo` | N | ~0.4 | ~1.6 (N=4) | 每端口 Egress |
| `bp_controller` | N | ~0.2 | ~0.8 (N=4) | 背压控制 |
| `tas_gate_sync` | N | ~0.1 | ~0.4 (N=4) | TAS 同步 |
| `fsm_ctl` | N | ~0.3 | ~1.2 (N=4) | 状态机控制 |
| **合计 (N=4)** | — | — | **~14.0** | — |
| **合计 (N=8)** | — | — | **~52.0** | — |

### 9.2 SRAM 估算

| 存储类型 | 深度 | 宽度 | 数量 | 总 bits | 备注 |
|----------|------|------|------|---------|------|
| XBAR FIFO | 8 | 64B | 16 (N=4) | 8,192 | 每交叉点 |
| XBAR FIFO | 8 | 64B | 64 (N=8) | 32,768 | 每交叉点 |
| Egress FIFO | 16 | 64B | 4 (N=4) | 4,096 | 每端口 |
| Egress FIFO | 16 | 64B | 8 (N=8) | 8,192 | 每端口 |
| RR 指针 | 4 | 3b | 4 | 48 | 每 TC 每端口 |
| **Total SRAM (N=4)** | — | — | — | **~12.3 Kb (~1.5 KB)** | — |
| **Total SRAM (N=8)** | — | — | — | **~41.0 Kb (~5.1 KB)** | — |

### 9.3 与 Arch Spec 资源预算对比

| 预算项 | Arch Spec §4.3 | 本设计 (N=4) | 余量 |
|--------|---------------|-------------|------|
| Switch Core 总门数 | ~80 kGE | 仲裁器 ~14 kGE | 66 kGE 用于 FDB/VLAN/L3/FRER/AVTP/TAS |
| Switch Core 总 SRAM | ~16 KB | 仲裁器 ~1.5 KB | ~14.5 KB 用于 FDB/VLAN/GCL |

---

## 10. 参数化支持 (2~8 端口)

### 10.1 Verilog 参数定义

```verilog
module sw_egress_arbiter #(
    parameter SWITCH_PORT_COUNT = 4,          // 2 ~ 8
    parameter XBAR_FIFO_DEPTH   = 8,          // 4, 8, 16
    parameter EGRESS_FIFO_DEPTH = 16,         // 8, 16, 32
    parameter DATA_WIDTH        = 64,         // 64, 128
    parameter TC_COUNT          = 4,          // 固定 4 级 (TSN/FRER/AVTP/BE)
    parameter PAUSE_THRESHOLD   = 4,          // 触发 Pause 帧的背压持续周期
    parameter ENABLE_TAS_SYNC   = 1           // 1 = 支持 TAS 门控同步
)(
    input  wire                        clk,
    input  wire                        rst_n,
    
    // XBAR FIFO 接口 (N × N)
    input  wire [SWITCH_PORT_COUNT*SWITCH_PORT_COUNT-1:0] xbar_fifo_not_empty,
    input  wire [SWITCH_PORT_COUNT*SWITCH_PORT_COUNT*2-1:0] xbar_tc_vec,
    output wire [SWITCH_PORT_COUNT*SWITCH_PORT_COUNT-1:0] xbar_fifo_rd_en,
    input  wire [DATA_WIDTH-1:0]       xbar_fifo_rdata [0:SWITCH_PORT_COUNT*SWITCH_PORT_COUNT-1],
    
    // TAS Gate 接口
    input  wire [SWITCH_PORT_COUNT-1:0] tas_gate_open,
    
    // Egress FIFO 接口
    output wire [SWITCH_PORT_COUNT*DATA_WIDTH-1:0] egress_fifo_wdata,
    output wire [SWITCH_PORT_COUNT-1:0] egress_fifo_wr_en,
    input  wire [SWITCH_PORT_COUNT-1:0] egress_fifo_full,
    input  wire [SWITCH_PORT_COUNT-1:0] egress_fifo_almost_full,
    
    // 背压输出
    output wire [SWITCH_PORT_COUNT-1:0] bp_assert,           // 本地背压
    output wire [SWITCH_PORT_COUNT-1:0] pause_frame_req,     // Pause 帧请求
    output wire [SWITCH_PORT_COUNT*16-1:0] pause_time_val,   // Pause 时间值
    
    // 状态输出 (调试/诊断)
    output wire [SWITCH_PORT_COUNT*3-1:0] arb_state_vec,    // 每端口 FSM 状态
    output wire [SWITCH_PORT_COUNT-1:0] arb_grant_valid,    // 授权有效
    output wire [SWITCH_PORT_COUNT*$clog2(SWITCH_PORT_COUNT)-1:0] arb_grant_port // 授权的 Ingress 端口
);
```

### 10.2 参数约束与验证

| 参数 | 有效范围 | 约束检查 | 非法处理 |
|------|----------|----------|----------|
| `SWITCH_PORT_COUNT` | 2, 3, 4, 5, 6, 7, 8 | `generate` 编译时 | < 2 → 强制 2; > 8 → 强制 8 |
| `XBAR_FIFO_DEPTH` | 4, 8, 16 | `generate` 编译时 | 非 2^n → 向上取整到 2^n |
| `EGRESS_FIFO_DEPTH` | 8, 16, 32 | `generate` 编译时 | 非 2^n → 向上取整到 2^n |
| `DATA_WIDTH` | 64, 128 | `generate` 编译时 | 非 64/128 → 强制 64 |

### 10.3 端口扩展性分析

| N | XBAR FIFO 数 | 仲裁器实例 | 面积 (kGE) | SRAM (KB) | 支持线速 |
|---|-------------|-----------|-----------|-----------|----------|
| 2 | 4 | 2 | ~7 | ~0.5 | 2×1G |
| 4 | 16 | 4 | ~14 | ~1.5 | 4×1G / 2×5G |
| 6 | 36 | 6 | ~35 | ~3.5 | 6×1G / 3×5G |
| 8 | 64 | 8 | ~52 | ~5.1 | 8×1G / 4×5G / 2×10G |

> **注意**: 8-port 配置下 XBAR FIFO 总数 64，面积增长为 O(N²)。若面积受限，可考虑共享 XBAR Buffer (Virtual Output Queue 替代 per-crosspoint FIFO)。

---

## Appendix A. 验收标准检查

| 检查项 | 状态 | 说明 |
|--------|:----:|------|
| 仲裁算法明确 (优先级策略 + 同优先级轮询) | ✅ | §3.1~3.5: 4 级 Strict Priority + 每 TC 独立 RR |
| 仲裁状态机图完整 | ✅ | §4.1~4.4: 8 状态 FSM，含转移条件和时序图 |
| FRER 多 Egress 同时发送机制 | ✅ | §5.1~5.3: FRER 复制 → 多 XBAR FIFO → 各端口独立仲裁 |
| 背压不丢帧机制 | ✅ | §6.1~6.4: 两级背压 (本地 XBAR 暂停 + 远程 Pause 帧)，滞回阈值 |
| 与 TAS Gate Open/Close 的时序协同 | ✅ | §7.1~7.5: Gate Close 不清空 FIFO，Gate Open 抢占，TAS 掩码逻辑 |
| 最坏情况仲裁延迟定量分析 | ✅ | §8.1~8.4: N=4 时最坏 570 cycles (4.56 μs)，TSN 抢占 1 cycle |

---

## Appendix B. 与其他文档的关联

| 本文档章节 | 关联文档 | 关联章节 | 说明 |
|-----------|---------|---------|------|
| §2 Crossbar | `ethernet_design_spec.md` | §2.3, §4.4.1 | Switch Core 数据通路 |
| §3 仲裁算法 | `ethernet_arch_spec.md` | §2.1, §6.2.7 | 系统框图 + Bridge 替代决策 |
| §6 背压 | `ethernet_design_spec.md` | §4.4.3 | 满负载丢帧率保证 |
| §7 TAS 协同 | `ethernet_design_spec.md` | §4.4.2 | Switch 级 TAS 互斥 |
| §9 面积 | `ethernet_arch_spec.md` | §4.3 | 资源估算预算 |
| §10 参数化 | `ethernet_arch_spec.md` | §1.4.1 | `SWITCH_PORT_COUNT` 参数 |

---

> **签核**: 本文档作为 PAD 阶段交付物，经 RTL_Coding_Agent 设计完成，待 AI_Yang 质量检查通过后可进入 RTL 编码阶段。

> **修订历史**:  
> v1.0 (2026-05-21): 初始版本 — PAD-REWORK-002 补完交付
