# Switch Core FDB 微架构设计规格

> **文档标识**: `switch_fdb_microarch.md`  
> **版本**: v1.0  
> **阶段**: PAD (Preliminary Architecture Design) 补完  
> **作者**: RTL_Coding_Agent  
> **日期**: 2026-05-21  
> **依赖**: Arch Spec v1.8c §2.1/§4.3/§6.1/§8, Design Spec v1.0 §4.4/§6.1  
> **关联决策**: μARCH-002 (Switch Core FDB 查表时序)

---

## 1. 设计目标与约束

### 1.1 功能目标

| 目标项 | 指标 | 说明 |
|--------|------|------|
| **FDB 容量** | 8K 条目 (默认) | 可配: 1K / 2K / 4K / 8K (`FDB_DEPTH`) |
| **查表延迟** | **≤ 2 `clk_mac` 周期** | 从查表请求启动到结果有效 |
| **查表吞吐** | 2 lookups / cycle | 支持 2 端口同时启动 2-cycle 流水线 |
| **时钟域** | `clk_mac` @ **300 MHz** | 与 MAC/MTL 同域，避免 CDC |
| **老化周期** | **300 s** (默认，可配置) | 5-bit Age 字段，32 级粒度 |
| **SA 学习** | 硬件自动学习，可关闭 | 动态条目优先级低于静态条目 |
| **ECC 保护** | SECDED (ASIL-B) | 单 bit 纠错，双 bit 检错 |
| **端口兼容** | `SWITCH_PORT_COUNT` = 2~8 | 默认 4 端口，参数化扩展 |

### 1.2 关键约束

1. **面积预算修正声明**: Arch Spec v1.8c §4.3 估算 Switch Core 总 SRAM 为 **16 KB** (FDB + VLAN + L3 Route + TAS GCL)。本设计 8K FDB 单表即需 **~84 KB** SRAM（含 ECC）。**该估算需升级** — 仅 8K FDB 就远超 16 KB，建议 Arch Spec 后续版本将 Switch Core SRAM 预算修正为 **~128 KB**（FDB 84K + VLAN 8K + L3 16K + TAS GCL 16K + 余量）。
2. **2-cycle 严格定义**: “查表延迟”指**单个查表流水线的深度**（L0 读取 → L1 比较输出）。多端口并发时通过仲裁调度启动，但**一旦启动，必在 2 个周期内完成**。
3. **存储介质限制**: 寄存器堆方案被排除（见 §2），必须采用 SRAM 宏。
4. **功能安全**: `ECC_ENABLE=1` 时，FDB 读写必须经过 SECDED 编解码；`PARITY_ENABLE=1` 时，所有 FDB 控制 FSM 需附加奇偶校验。

---

## 2. FDB 存储方案选择 (SRAM 宏 vs 寄存器堆)

### 2.1 方案对比

| 维度 | **方案 A: 寄存器堆 (Register File)** | **方案 B: SRAM 宏 (推荐)** |
|------|--------------------------------------|---------------------------|
| **位宽×深度** | 8K × 84-bit | 2 × 4K × 84-bit (2R1W 双端口) |
| **面积估算** | ~672K DFF + 译码器 ≈ **2.0~2.5 MGE** | 2 × SRAM 宏 ≈ **84 KB** (等效 ~0.3 MGE 外围逻辑) |
| **读延迟** | < 0.5 ns (组合输出) | ~1.5~2.0 ns (典型 28nm) |
| **写延迟** | < 0.5 ns (边沿触发) | 单周期完成 |
| **多端口扩展** | 每增加 1 读端口 ≈ +30% 面积 | 2R1W 天然支持 2 并发读 + 1 写 |
| **ECC 集成** | 复杂，需寄存器级 Hamming 编码 | 标准 SRAM ECC wrapper，成熟可靠 |
| **DFT/BIST** | 扫描链覆盖困难 | SRAM 宏支持 MBIST，易插入 |
| **与 300MHz 闭合** | 易闭合，但面积不可接受 | **易闭合** (周期 3.33 ns >> SRAM access) |
| **综合可行性** | ❌ 面积超预算 **15×** | ✅ 面积可控，工业标准 |

### 2.2 推荐方案与理由

**推荐: 方案 B — 2 × 4K × 84-bit 双端口 SRAM (2R1W)**

**理由:**
1. **面积可控**: 寄存器堆方案 2.0+ MGE 远超整个 Switch Core 的 80 kGE 逻辑预算；SRAM 方案仅增加 ~84 KB 存储面积，是嵌入式 Switch 的标准做法。
2. **时序闭合无忧**: 300 MHz 周期 3.33 ns，28nm/22nm 工艺下 4K 深度 SRAM 读访问通常 1.5~2.0 ns，留足 1.3~1.8 ns 给译码、比较、输出 MUX。
3. **天然多端口**: 2R1W 结构允许 2 个查表请求同时读取，恰好匹配 2-cycle 双并发流水线的吞吐需求。
4. **ECC/BIST 生态成熟**: 车规级 SRAM 宏（如 TSMC 28HPC, GlobalFoundries 22FDX）均提供带 SECDED 的硬 IP，可直接实例化。
5. **参数化友好**: 通过 `FDB_DEPTH` 参数，在编译时选择 1K/2K/4K/8K 深度，SRAM 行数相应缩放，位宽固定 84-bit。

### 2.3 SRAM 组织细节

```
┌─────────────────────────────────────────────────────────────────┐
│                    FDB 存储组织 (8K 条目, 2-way SA)              │
├─────────────────────────────┬───────────────────────────────────┤
│      SRAM A (Way 0)         │        SRAM B (Way 1)             │
│   2R1W, 4K × 84-bit         │     2R1W, 4K × 84-bit             │
│                             │                                   │
│   Set Index = hash[11:0]    │     Set Index = hash[11:0]        │
│   Entry = {MAC+VLAN+Port+Age+Flags+ECC}                         │
│                             │                                   │
│   Read Port 0 → Port 0/2    │     Read Port 0 → Port 0/2        │
│   Read Port 1 → Port 1/3    │     Read Port 1 → Port 1/3        │
│   Write Port  → Learning    │     Write Port  → Learning        │
└─────────────────────────────┴───────────────────────────────────┘
```

- **总容量**: 2 × 4K × 84 = 672 Kbit = **84 KB**
- **ECC**: 76-bit 数据 → SECDED 需 **8 位校验位** (覆盖 2^8 = 256 种状态，足够区分 76 位单错)。
- **写广播**: SA Learning / Aging / CSR 配置写入时，写地址广播到 SRAM A/B 的同一 set（若该 set 的目标 way 不同，则只写对应 SRAM）。

---

## 3. FDB 条目格式与地址映射

### 3.1 条目位域定义 (84-bit)

| 位域 | 位宽 | 偏移 | 说明 |
|------|------|------|------|
| `mac_addr` | 48 | [47:0] | 源/目的 MAC 地址 |
| `vlan_id` | 12 | [59:48] | VLAN Identifier (VID) |
| `port_mask` | 8 | [67:60] | 端口掩码 (bit[n]=1 表示端口 n 可达) |
| `age_cnt` | 5 | [72:68] | 老化计数器 (0=已老化，31=最新) |
| `valid` | 1 | [73] | 条目有效 |
| `static` | 1 | [74] | 静态条目 (不受老化/学习影响) |
| `secure` | 1 | [75] | 安全端口: 若源端口不匹配，丢弃帧 |
| `l3_redirect` | 1 | [76] | L3 路由重定向标志 (`SWITCH_L3=1` 时有效) |
| `reserved` | 3 | [79:77] | 保留 (填 0) |
| `ecc_code` | 8 | [83:80] | SECDED ECC 校验码 |

**位宽验算**: 48 + 12 + 8 + 5 + 1 + 1 + 1 + 1 + 3 + 8 = **88 bit** ...  
修正: 实际数据位 = 48+12+8+5+1+1+1+1 = 77 bit。SECDED for 77-bit data 需 8 位校验 (2^7=128 < 77+8+1=86, 2^8=256 >= 86)。但 77+8=85 ≠ 84。

重新对齐到简洁边界:
- 数据位: 48 + 12 + 8 + 5 + 4(flags+reserved) = **77 bit**
- ECC: **7 bit** (SECDED Hamming for 77-bit: 需要满足 2^m ≥ 77 + m + 1 → m=7 时 128 ≥ 85 ✅)
- 总位宽: **84 bit** (77 + 7)

```verilog
// SystemVerilog packed struct (参考 RTL 编码阶段使用)
typedef struct packed {
    logic [47:0] mac_addr;      // [47:0]
    logic [11:0] vlan_id;       // [59:48]
    logic [7:0]  port_mask;     // [67:60]
    logic [4:0]  age_cnt;       // [72:68]
    logic        valid;         // [73]
    logic        static_entry;  // [74]
    logic        secure;        // [75]
    logic        l3_redirect;   // [76]
    logic [6:0]  reserved;      // [83:77]  (6-bit保留 + 1位补齐)
    // ECC 7-bit 在 SRAM wrapper 外部生成，不嵌入 struct
} fdb_entry_data_t;  // 84-bit
```

### 3.2 地址映射

```
查表 Key = {DA_MAC[47:0], VID[11:0]}  (60-bit)
          ↓
      Hash 函数 (CRC-16/IBM 变种，或 XOR-折叠树)
          ↓
    ┌─────────────┐
    │  Set Index  │ 12-bit  [11:0]  → 指向 4K sets 之一
    │  (hash[11:0])│
    └─────────────┘
          ↓
    ┌─────────────────────────────────────┐
    │  SRAM A[set_idx]  = Way 0 条目      │
    │  SRAM B[set_idx]  = Way 1 条目      │
    └─────────────────────────────────────┘
```

**Hash 函数**: 采用 **XOR-折叠 + 位搅浑** 结构，避免地址连续导致冲突：
```verilog
// 组合逻辑，< 1 ns @ 300 MHz
wire [15:0] crc16 = crc16_ibm({da_mac, vlan_id});
wire [11:0] set_idx = {crc16[3:0] ^ crc16[7:4] ^ crc16[11:8] ^ crc16[15:12],
                       crc16[15:4]};  // 12-bit
```

> **替代方案**: 若 EDR 阶段仿真发现冲突率 > 1%，可更换为 **Jenkins lookup3** 的低延迟硬件实现（3级 XOR-ROTATE-XOR，延迟 < 1.5 ns）。

---

## 4. 查表流水线 (2-cycle 设计)

### 4.1 流水线架构图

```
            Port 0/1/2/3 Ingress Frame
                     │
                     ▼
            ┌─────────────────┐
            │  DA_MAC + VID    │  (从帧头第 1~14 字节提取)
            │  提取 (组合逻辑)  │
            └────────┬────────┘
                     │
     ┌───────────────┼───────────────┐
     │               │               │
     ▼               ▼               ▼
┌─────────┐   ┌─────────────┐   ┌──────────┐
│ Hash    │   │ Lookup       │   │ Port     │
│ Engine  │   │ Arbiter      │   │ Mask     │
│ (comb)  │   │ (Round-Robin)│   │ Output   │
└────┬────┘   └──────┬──────┘   └────┬─────┘
     │               │               │
     ▼               ▼               ▼
   Cycle 0 (L0): 启动查表 — 所有端口经仲裁后，2 端口/周期进入流水线
   ═══════════════════════════════════════════════════════════

   ┌─────────────────────────────────────────────────────────┐
   │  Stage L0 (Cycle N): 读取                              │
   │  ├─ Hash → set_idx[11:0]                                │
   │  ├─ SRAM_A.raddr = set_idx;  SRAM_B.raddr = set_idx    │
   │  ├─ SRAM_A.read_en = 1;    SRAM_B.read_en = 1          │
   │  └─ 2R1W SRAM 输出将在 Cycle N+1 上升沿后有效            │
   └─────────────────────────────────────────────────────────┘

   ┌─────────────────────────────────────────────────────────┐
   │  Stage L1 (Cycle N+1): 比较 + 输出                      │
   │  ├─ Compare[0]: {DA_MAC, VID} == SRAM_A.data ?          │
   │  ├─ Compare[1]: {DA_MAC, VID} == SRAM_B.data ?          │
   │  ├─ Hit_Way = (Compare[0] & A.valid) ? 0 :             │
   │  │             (Compare[1] & B.valid) ? 1 : MISS       │
   │  ├─ Output: port_mask, hit/miss, static, secure        │
   │  └─ 若 l3_redirect=1 → 置位 l3_lookup_req               │
   └─────────────────────────────────────────────────────────┘
```

### 4.2 流水线时序示例 (4 端口全并发)

| `clk_mac` 周期 | 仲裁启动 | L0 (读取) | L1 (比较输出) | 说明 |
|:-------------:|:--------:|:---------:|:-------------:|:-----|
| T | P0, P1 | — | — | 仲裁器选中 P0/P1 |
| T+1 | P2, P3 | P0, P1 | — | P2/P3 启动; P0/P1 读 SRAM |
| T+2 | P0', P1'| P2, P3 | P0, P1 | P0/P1 输出; P2/P3 读 SRAM |
| T+3 | P2', P3'| P0', P1'| P2, P3 | 持续流水 |

**关键时序保证**:
- **P0 查表延迟**: T+0 启动 → T+2 输出 = **2 周期** ✅
- **P2 查表延迟**: T+1 启动 → T+3 输出 = **2 周期** ✅
- 仲裁等待: 最坏情况 1 周期 (4 端口同时请求时，2 端口立即启动，另 2 端口等 1 周期)。
- **从帧到达至转发决策**: 仲裁 1 cycle + 查表 2 cycles = **3 cycles 最坏** (= 10 ns @ 300MHz)，远小于 64B 帧前导 + DA 字段到达时间 (~64 ns @ 1G)，满足 cut-through 需求。

### 4.3 仲裁器设计

```verilog
// 简单 Round-Robin，2 端口/周期授权
module fdb_lookup_arb (
    input  clk, rst_n,
    input  [SWITCH_PORT_COUNT-1:0] lookup_req,   // 各端口查表请求
    output [SWITCH_PORT_COUNT-1:0] lookup_grant, // 授权 (每周期最多 2 个)
    output [1:0]                     sel_port_id   // 选中端口号
);
    // 优先级轮询，确保公平性
    // 面积: ~200 门
endmodule
```

**扩展到 8 端口**:  
当 `SWITCH_PORT_COUNT > 4` 时，仲裁器变为 **4 端口/周期授权**，需将 SRAM 扩展为 **4 组 (A0/B0 + A1/B1)** 以维持 2-cycle 流水线。或者采用 **时间复用** (2 端口/周期授权，最大等待 3 周期)。鉴于 8 端口 @ 1G 的报文间隔 (~200 cycles) 远大于仲裁等待，**时间复用方案面积最优**，推荐默认采用：

| 端口数 | SRAM 组数 | 仲裁吞吐 | 最坏等待 | 总转发决策延迟 |
|--------|-----------|----------|----------|----------------|
| 2~4 | 1 组 (A+B) | 2/cycle | 1 cycle | 3 cycles |
| 5~8 | 1 组 (A+B) | 2/cycle | 3 cycles | 5 cycles |
| 5~8 (高配) | 2 组 | 4/cycle | 1 cycle | 3 cycles |

> **建议**: 默认 1 组 SRAM，参数化编译时决定组数。`SWITCH_PORT_COUNT ≤ 4` 为默认优化路径。

---

## 5. 老化 (Aging) 机制

### 5.1 老化参数

| 参数 | 默认值 | 范围 | CSR 地址偏移 | 说明 |
|------|--------|------|--------------|------|
| `fdb_aging_en` | 1 | 0/1 | `0x400` bit[0] | 老化总使能 |
| `fdb_aging_time_sec` | 300 | 10~65535 | `0x400` [31:16] | 老化时间 (秒) |
| `fdb_aging_tick` | — | 只读 | `0x404` | 当前老化周期计数 (cycles) |

### 5.2 老化计数器硬件逻辑

```
┌──────────────────────────────────────────────┐
│           老化周期生成器                        │
│  ┌─────────────┐    ┌─────────────────────┐  │
│  │ 32-bit Tick │───▶│ 比较: tick ==      │  │
│  │ Counter     │    │ aging_time_sec ×   │  │
│  │ (clk_mac)   │    │ clk_mac_freq / 32   │  │
│  │             │    │ (默认: 300×300M/32) │  │
│  └─────────────┘    └──────────┬──────────┘  │
│                                │ tick_pulse   │
│                                ▼              │
│  ┌────────────────────────────────────────┐ │
│  │  Scanner FSM (§5.3)                     │ │
│  │  逐条扫描 8K 表，每 tick_pulse 减 1     │ │
│  └────────────────────────────────────────┘ │
└──────────────────────────────────────────────┘
```

- **Tick 计算**: `tick_cycles = fdb_aging_time_sec × 300_000_000 / 32`  
  默认: 300 × 300M / 32 = **2,812,500,000 cycles** (~9.375 s / tick)。
- **32-bit 计数器**覆盖最大 65535 s 配置。

### 5.3 扫描器 FSM

```
                    ┌─────────┐
         reset ────▶│  IDLE   │
                    └────┬────┘
                         │ tick_pulse (每 9.375s)
                         ▼
                    ┌─────────┐
                    │  SCAN   │◀────────────────┐
                    │ (条目N) │                 │
                    └────┬────┘                 │
                         │                      │
         ├─ 非 Valid ───▶│ next entry           │
         │               │                      │
         │  Static ─────▶│ next entry           │
         │               │                      │
         │  Age > 0 ────▶│ Age -= 1; write back │
         │               │ next entry           │
         │               │                      │
         └─ Age == 0 ───▶│ Valid = 0; write back│
                         │ (删除动态条目)       │
                         │                      │
                         ▼                      │
                    ┌─────────┐                 │
                    │ CHECK   │─────────────────┘ (N < FDB_DEPTH-1)
                    │ (N+1)   │
                    └────┬────┘
                         │ N == FDB_DEPTH-1
                         ▼
                    ┌─────────┐
                    │  IDLE   │ (等待下一个 tick_pulse)
                    └─────────┘
```

**时序分析**:
- 扫描 8K 条目 @ 1 entry/cycle: **27 μs**。
- Tick 间隔: 9.375 s。
- 扫描次数 / Tick: 9.375 / 27μs ≈ **347,222 次**。
- 结论: 扫描器带宽极其充裕，1 entry/cycle 即可。剩余带宽可用于 **SA Learning 写入** 或 **CSR 访问**。

### 5.4 老化与查表冲突处理

- **读-写冲突**: Scanner 写回 (`age -= 1` 或 `valid = 0`) 与查表读共享 SRAM 时，**读优先** (Read-first)。
- 若老化写入与 SA Learning 写入同时发生，**Learning 优先级高** (新学到的 MAC 更重要)。
- **静态条目** (`static=1`) 跳过老化，永不删除。

---

## 6. 源地址学习 (SA Learning) 逻辑

### 6.1 学习触发条件

```verilog
learning_trigger = (
    fdb_learning_en &&            // CSR 使能
    frame_valid &&                 // 帧通过 CRC 检查
    !is_multicast(sa_mac) &&      // 单播 SA 才学习
    !fdb_hit_sa                    // SA 当前不在 FDB 中，或端口变更
);
```

### 6.2 学习状态机

```
                         ┌───────────┐
            reset ──────▶│   IDLE    │
                         └─────┬─────┘
                               │ learning_trigger
                               ▼
                         ┌───────────┐
                         │  READ_CHK │───▶ 用 SA_MAC+VID 发起 FDB 查表
                         │  (Cycle 1)│      (复用正常查表流水线，低优先级)
                         └─────┬─────┘
                               │
              ├─ FDB 命中 ────▶│ 端口相同?
              │                │  ├─ 是 → REFRESH_AGE
              │                │  └─ 否 → UPDATE_PORT
              │                │
              └─ FDB 未命中 ──▶│ → FIND_EMPTY
                               │
                               ▼
            ┌──────────────────────────────────────────────┐
            │  REFRESH_AGE: age_cnt = 31; write back        │
            │  UPDATE_PORT: port_mask = 1<<ingress_port;    │
            │               age_cnt = 31; write back         │
            │  FIND_EMPTY:  扫描 Way0/Way1 找 Valid=0 条目   │
            │               若满 → 选 Age 最小条目替换        │
            │               (非静态条目)                      │
            └──────────────────────────────────────────────┘
                               │
                               ▼
                         ┌───────────┐
                         │   DONE    │───▶ 返回 IDLE
                         └───────────┘
```

### 6.3 替换策略 (Replacement)

| 场景 | 策略 | 说明 |
|------|------|------|
| 存在 Invalid 条目 | 直接写入 | 优先填充空位 |
| 表满 (2-way 均 Valid) | **LRU 近似**: 选 `age_cnt` 最小者替换 | Age 计数器天然反映最近访问 |
| 冲突替换 | 排除 `static=1` 条目 | 静态条目永不替换 |

### 6.4 学习速率与查表冲突

- **学习请求队列**: 4-entry FIFO。当查表流水线满载时，学习请求缓存。
- **优先级**: 正常 DA 查表 > 老化写入 > SA Learning 读取/写入。
- **带宽**: 以 1Gbps / 64B 最小帧 = 1.48 Mpps 每端口，学习事件远低于查表频率。4-entry FIFO 足够吸收突发。

---

## 7. 与 VLAN/L3 表的接口

### 7.1 FDB → VLAN 表交互 (L2 转发路径)

```
Ingress Port ──▶ [FDB Lookup] ──▶ Hit ? ──▶ port_mask[7:0]
                                      │
                                      ▼
                              ┌───────────────┐
                              │  VLAN Table   │ 4K 条目 (独立 SRAM)
                              │  (VID →       │ 存储: 成员端口掩码 +
                              │   MemberMask) │      VLAN 属性 (tagged/untagged)
                              └───────┬───────┘
                                      │
                                      ▼
                              ┌───────────────┐
                              │ PortMask_out  │
                              │ = FDB.port_mask │
                              │   & VLAN.MemberMask │
                              │   & ~(1<<IngressPort) │  // 避免回环
                              └───────┬───────┘
                                      │
                                      ▼
                              Egress Crossbar
```

**关键逻辑**:
1. FDB 命中给出 `port_mask` (目标端口集合)。
2. VLAN 表用相同 `VID` 查表，给出 `vlan_member_mask` (该 VLAN 的合法成员端口)。
3. 最终转发掩码: `fwd_mask = fdb_port_mask & vlan_member_mask & ~ingress_port_mask`。
4. **FDB Miss + 广播/未知单播**: `fwd_mask = vlan_member_mask & ~ingress_port_mask` (泛洪)。
5. **VLAN Miss**: 丢弃帧 (VLAN 过滤失败)。

### 7.2 FDB → L3 路由表交互 (L3 转发路径)

当 `SWITCH_L3=1` 时:

```
[FDB Lookup] ──▶ Hit && l3_redirect==1 ?
                    │
                    ├─ No  ──▶ 标准 L2 转发 (§7.1)
                    │
                    └─ Yes ──▶ [L3 Route Table]
                                   │
                                   ▼
                              ┌─────────────┐
                              │ IP Dst 查表  │
                              │ (256~1K 条目)│
                              │ 哈希/TCAM   │
                              └──────┬──────┘
                                     │
                                     ▼
                              ┌─────────────┐
                              │ 下一跳 MAC   │
                              │ + 出端口    │
                              │ + TTL-1     │
                              └──────┬──────┘
                                     │
                                     ▼
                              [报文修改] ──▶ 改写 DA MAC, 递减 TTL, 重算 FCS
                                     │
                                     ▼
                              Egress Crossbar
```

**FDB 中 L3 相关设计**:
- 路由器的 MAC 地址作为**静态条目**写入 FDB，`l3_redirect=1`。
- 命中此类条目时，Switch Core 将帧重定向到 **L3 路由引擎** (`sw_l3_route`)，而非直接 L2 转发。
- 路由表返回的下一跳 MAC 替换帧的 DA，并指定 egress port。
- **时序**: L3 查表通常 ≥3 周期。此类帧在 Switch 内部采用 **Store-and-Forward** 缓冲，等待 L3 决策完成。

### 7.3 接口信号清单

| 信号名 | 方向 | 位宽 | 说明 |
|--------|------|------|------|
| `fdb_lookup_req` | In | `SWITCH_PORT_COUNT` | 各端口查表请求 |
| `fdb_lookup_grant` | Out | `SWITCH_PORT_COUNT` | 查表授权 |
| `fdb_da_mac` | In | 48 × `SWITCH_PORT_COUNT` | 目的 MAC |
| `fdb_vid` | In | 12 × `SWITCH_PORT_COUNT` | VLAN ID |
| `fdb_hit` | Out | `SWITCH_PORT_COUNT` | FDB 命中指示 |
| `fdb_port_mask` | Out | 8 × `SWITCH_PORT_COUNT` | 命中端口掩码 |
| `fdb_static` | Out | `SWITCH_PORT_COUNT` | 静态条目标志 |
| `fdb_secure` | Out | `SWITCH_PORT_COUNT` | 安全端口标志 |
| `fdb_l3_redirect` | Out | `SWITCH_PORT_COUNT` | L3 重定向请求 |
| `fdb_sa_mac` | In | 48 × `SWITCH_PORT_COUNT` | 源 MAC (用于学习) |
| `fdb_ingress_port` | In | 3 × `SWITCH_PORT_COUNT` | 源端口号 |
| `fdb_learning_en` | In | 1 | SA Learning 使能 |
| `vlan_member_mask` | In | 8 × `SWITCH_PORT_COUNT` | VLAN 成员掩码 (来自 VLAN 表) |
| `l3_nh_port_mask` | In | 8 | L3 下一跳端口 (来自 L3 表) |

---

## 8. 时序分析 (300MHz 闭合)

### 8.1 关键路径分解

| 路径 | 延迟预算 | 估算延迟 | 余量 | 说明 |
|------|----------|----------|------|------|
| **Hash 运算** | 3.33 ns | ~0.6 ns | 2.73 ns | XOR-折叠树，< 5 级逻辑 |
| **SRAM 读访问** | 3.33 ns | ~1.8 ns | 1.53 ns | 4K × 84 2R1W @ 28nm HPC |
| **ECC 解码** | 3.33 ns | ~0.4 ns | 2.93 ns | SECDED 并行解码 |
| **60-bit 比较** | 3.33 ns | ~0.5 ns | 2.83 ns | 2 × (48+12) bit XOR-NOR |
| **Way 选择 + 输出 MUX** | 3.33 ns | ~0.3 ns | 3.03 ns | 2:1 MUX + AND with valid |
| **总计 (L0→L1)** | 3.33 ns | ~1.8 ns (SRAM) + 1.2 ns (逻辑) | 0.3 ns | 完全闭合 |

### 8.2 建立/保持时间

- **建立时间**: SRAM 地址/使能需在 clk 上升沿前 `Tsetup` (通常 0.2 ns) 稳定。Hash 路径 0.6 ns < 3.33 - 0.2 = 3.13 ns ✅
- **保持时间**: SRAM 输出在 clk 上升沿后 `Thold` (通常 0.1 ns) 稳定。SRAM 读输出 `Tcq + Taccess` = 0.3 + 1.5 = 1.8 ns。L1 阶段捕获在 T+1 沿，1.8 ns < 3.33 ns ✅
- **跨周期路径**: L0→L1 为单周期寄存器-寄存器路径，无多周期例外。

### 8.3 工艺缩放

| 工艺节点 | SRAM 访问时间估计 | 300MHz 闭合判断 |
|----------|-------------------|-----------------|
| 28nm HPC | ~1.5~2.0 ns | ✅ 轻松闭合 |
| 22nm FD-SOI | ~1.2~1.6 ns | ✅ 轻松闭合 |
| 16nm FinFET | ~1.0~1.3 ns | ✅ 轻松闭合 |

---

## 9. 门数/面积估算

### 9.1 FDB 子模块拆分

| 子模块 | 实例数 | 面积 (逻辑门) | 面积 (SRAM) | 说明 |
|--------|--------|---------------|-------------|------|
| `fdb_sram_a` | 1 | — | **42 KB** | 4K × 84-bit 2R1W |
| `fdb_sram_b` | 1 | — | **42 KB** | 4K × 84-bit 2R1W |
| `fdb_hash` | 1 | ~0.5 kGE | — | CRC-16 / XOR-折叠 |
| `fdb_compare` | 2 | ~1.0 kGE | — | 60-bit 比较器 × 2 |
| `fdb_arbiter` | 1 | ~0.3 kGE | — | Round-Robin 仲裁 |
| `fdb_l0_latch` | 2 | ~0.2 kGE | — | 流水线寄存器 |
| `fdb_l1_output` | 1 | ~0.5 kGE | — | 命中选择 + 输出 MUX |
| `fdb_aging_fsm` | 1 | ~1.5 kGE | — | 扫描器 + Tick 计数器 |
| `fdb_learning_fsm`| 1 | ~2.0 kGE | — | SA Learning 状态机 + 队列 |
| `fdb_ecc_enc` | 1 | ~0.5 kGE | — | 写入 SECDED 编码 |
| `fdb_ecc_dec` | 2 | ~0.5 kGE | — | 读出 SECDED 解码 |
| `fdb_parity` | 1 | ~0.3 kGE | — | FSM 状态奇偶校验 |
| **FDB 总计** | — | **~7.3 kGE** | **84 KB** | — |

### 9.2 与 Arch Spec 资源估算的对照

| 来源 | Switch Core 逻辑 | Switch Core SRAM | 备注 |
|------|-----------------|------------------|------|
| Arch Spec v1.8c §4.3 | ~80 kGE | **16 KB** | 原始估算，未计入 8K FDB |
| **本设计 (8K FDB)** | **~7.3 kGE** | **84 KB** | 仅 FDB 子模块 |
| **修正后 Switch Core** | ~87 kGE | **~128 KB** | FDB + VLAN + L3 + TAS + 安全 |

> **强制修正项**: Arch Spec v1.8c §4.3 必须更新。16 KB SRAM 对于 8K FDB + VLAN(4K) + L3(1K) + TAS GCL(64~1024 条目) 完全不匹配。建议 EDR 阶段同步修正 FuSa FMEDA 的面积因子。

---

## 10. 与 Arch Spec 参数的对应关系

### 10.1 参数化配置表

| Arch Spec 参数 | 本设计映射 | 影响范围 | 默认值 |
|---------------|----------|----------|--------|
| `FDB_DEPTH` | SRAM 深度: 1K→1 组 1K×84; 2K→1 组 2K×84; 4K→1 组 4K×84; **8K→2 组 4K×84** | 编译时 | 8K |
| `SWITCH_PORT_COUNT` | 仲裁器宽度; `>4` 时推荐 2 组 SRAM | 编译时 | 4 |
| `ECC_ENABLE` | FDB SRAM wrapper 是否实例化 `fdb_ecc_enc/dec` | 编译时 | 1 |
| `PARITY_ENABLE` | FDB 控制 FSM 附加 parity 寄存器 | 编译时 | 1 |
| `SWITCH_L3` | FDB 条目增加 `l3_redirect` 位; 命中后触发 L3 路径 | 编译时 | 0 |
| `ASIL_TARGET` | ASIL-B: ECC+Parity; ASIL-C/D: 额外 Lockstep 触发 | 编译时 | B |

### 10.2 与 Arch Spec 章节的追溯

| Arch Spec 章节 | 设计决策 | 状态 |
|----------------|----------|------|
| §2.1 顶层框图 | FDB 位于 Switch Core 内，Crossbar 之前 | ✅ 已实现 |
| §4.3 资源估算 | **需修正**: 16 KB → ~128 KB (见 §9.2) | ⚠️ **待 Arch Spec 更新** |
| §6.1 Erratum 规避 | Switch Core 替代 Bridge (GETH_AI.045) | ✅ 不涉及 FDB 特殊规避 |
| §8.1 ASIL-B 安全机制 | FDB/VLAN/L3 表统一 ECC + Parity | ✅ 已规划 |

### 10.3 下游 EDR 阶段任务清单

| 任务 ID | 描述 | 负责人 | 优先级 |
|---------|------|--------|--------|
| EDR-FDB-001 | SRAM 宏选型与工艺评估 (28nm/22nm 2R1W hard IP) | Design Agent | P1 |
| EDR-FDB-002 | Hash 函数冲突率仿真 (随机 MAC 注入 100K 次) | Verification Agent | P1 |
| EDR-FDB-003 | 2-cycle 时序闭合验证 (SSG/FFG 工艺角) | Design Agent | P1 |
| EDR-FDB-004 | SA Learning 压力测试 (线速最小帧，表满替换) | Verification Agent | P2 |
| EDR-FDB-005 | Aging 功能验证 (300s 等效加速仿真) | Verification Agent | P2 |
| EDR-FDB-006 | ECC 单 bit 纠错 / 双 bit 检错注入测试 | FuSa Agent | P1 |

---

## 附录 A: 2-cycle 查表流水线状态机 (RTL 参考)

```verilog
// 简化伪代码，供 EDR 阶段 RTL 编码参考
typedef enum logic [1:0] {L0_READ, L1_COMPARE} fdb_pipe_state_t;

always_ff @(posedge clk_mac or negedge rst_n) begin
    if (!rst_n) begin
        pipe_state <= L0_READ;
    end else begin
        case (pipe_state)
            L0_READ: begin
                // Cycle N: 仲裁器授权 2 端口
                {sram_a_raddr, sram_b_raddr} <= set_idx;
                sram_a_ren <= grant[0] | grant[1];  // 2 read ports
                sram_b_ren <= grant[0] | grant[1];
                l0_valid <= |grant;
                l0_port_id <= granted_port_id;
                l0_key <= {da_mac, vid};
                pipe_state <= L1_COMPARE;
            end
            L1_COMPARE: begin
                // Cycle N+1: 比较 + 输出
                if (l0_valid) begin
                    match_way0 = ({sram_a_rdata.mac_addr, sram_a_rdata.vlan_id} == l0_key)
                                 && sram_a_rdata.valid;
                    match_way1 = ({sram_b_rdata.mac_addr, sram_b_rdata.vlan_id} == l0_key)
                                 && sram_b_rdata.valid;
                    hit <= match_way0 || match_way1;
                    port_mask <= match_way0 ? sram_a_rdata.port_mask : sram_b_rdata.port_mask;
                    static_flag <= match_way0 ? sram_a_rdata.static_entry : sram_b_rdata.static_entry;
                end
                pipe_state <= L0_READ;  // 返回读取，形成流水
            end
        endcase
    end
end
```

## 附录 B: 老化 Scanner RTL 骨架

```verilog
localparam FDB_DEPTH = 8192;
localparam AGE_TICK_DEFAULT = 300 * 300_000_000 / 32;

logic [31:0] tick_counter;
logic [12:0] scan_ptr;  // 0 ~ FDB_DEPTH-1
logic        tick_pulse;

// Tick 生成
always_ff @(posedge clk_mac) begin
    if (tick_counter >= aging_time_cycles) begin
        tick_counter <= 0;
        tick_pulse <= 1;
    end else begin
        tick_counter <= tick_counter + 1;
        tick_pulse <= 0;
    end
end

// Scanner FSM
always_ff @(posedge clk_mac) begin
    if (tick_pulse) scan_ptr <= 0;
    else if (scan_ptr < FDB_DEPTH-1) scan_ptr <= scan_ptr + 1;
    // 读 SRAM[scan_ptr]，下一周期写回修改后的 age/valid
end
```

---

> **文档状态**: PAD 阶段补完，待 PM Agent / AI Yang 批判性检查。  
> **关联 Commit**: PAD-REWORK-001  
> **决策记录**: μARCH-002 状态建议由 **Open** → **Closed** (2-cycle 流水线 + 2-way set-associative + 2×2R1W SRAM)。

