# Ethernet IP SystemC Modeling Plan

> **项目**: Ethernet IP (IP_20260502_001)
> **模块/系统**: Gigabit Ethernet MAC + Switch Subsystem 系统级模型
> **版本**: v1.0
> **日期**: 2026-07-28
> **作者**: Arch Agent
> **评审状态**: Draft → 待评审
> **关联文档**: `ethernet_arch_spec.md` v1.9, `protocol_analysis.md` v2.2, `ethernet_interface_spec.md`
> *说明: 本文档定义 PAD 阶段 SystemC/TLM 系统级建模的目标、范围、精度等级、协议映射、验证场景与度量指标，用于架构探索、性能评估与 RTL 开发前的参考模型 (Golden Reference) 建立。*

---

## 1. 建模目标

SystemC 模型服务于以下四类目标，按优先级排序：

| 优先级 | 目标 | 说明 | 主要使用方 |
|--------|------|------|-----------|
| **P0** | **架构性能评估** | 在 RTL 冻结前验证 Switch/DMA/MTL 架构能否满足 5Gbps 线速、TSN 确定性与多端口并发指标（对应 Arch Spec §4 性能评估的量化闭环） | Arch Agent / 实体 Yang |
| **P0** | **Golden Reference** | 作为 UVM 验证环境的参考模型（帧级转发行为、描述符处理、时间戳语义），与 RTL 做 transaction-level 比对 | Verification Agent |
| **P1** | **架构探索 (Design Space Exploration)** | 扫描 `DMA_CH_COUNT`、`MTL_TX/RX_FIFO_DEPTH`、`SWITCH_PORT_COUNT` 等参数对带宽/丢帧/面积-缓冲权衡的影响 | Arch Agent |
| **P1** | **软件开发早期平台** | 提供寄存器级可编程视图 (CSR + 描述符 + Xen IO Rings)，供 Firmware/Hypervisor 驱动先行开发 | Firmware 团队 |

**非目标**：
- 不替代 RTL 仿真做功能正确性 sign-off
- 不建模 PCS/PMA 模拟层行为（10BASE-T1S PLCA 除外，仅做抽象时序）
- 不做时钟周期精确的时序收敛分析（属 FDR 阶段 STA 范畴）

---

## 2. 建模范围

### 2.1 覆盖模块

模型覆盖 Arch Spec §2.2 子系统划分中的以下 6 个核心组件：

| 组件 | 建模内容 | 关键参数（来自 Arch Spec §1.4） |
|------|---------|-------------------------------|
| **Switch Core** | 4~8 端口 L2 转发：MAC 自学习 (FDB 老化)、VLAN 转发、多播/广播过滤、入口共享队列 (MTL 前端)、Switch 级 TAS (802.1Qbv)、CBS (802.1Qav)、FRER (802.1CB 抽象)、L3 路由（`SWITCH_L3=1` 时，简化最长前缀匹配） | `SWITCH_PORT_COUNT`, `SWITCH_TAS`, `MTL_TX/RX_QUEUES` |
| **MAC (XGMAC-CORE)** | 帧组装/拆解 (Preamble/SFD/FCS/Pad)、TX/RX FSM 行为级抽象、帧抢占 (802.1Qbu pMAC/eMAC)、每 MAC 弹性 FIFO、Checksum Offload 语义 | `MAC_COUNT`, `MAC_x_TYPE`, `MAC_x_SPEED`, `SUPPORT_FP` |
| **DMA Engine** | 全局通道池仲裁 (8/16/32 通道共享复用)、32-byte 描述符 fetch/write-back、AXI Master burst 行为、每 MAC 动态通道分配、AVTP 流 RX 分离 | `DMA_CH_COUNT`, `DMA_CH_PER_MAC`, `DESC_SIZE=32`, `AXI_DATA_WIDTH` |
| **PHC (×2)** | 64-bit 纳秒计数器、Addend 精调机制、SFD 级硬件时间戳捕获点、P2P 路径延迟测量抽象（对应 Arch Spec §3.3） | `PHC_COUNT=2`, 时间戳分辨率 1ns |
| **vPHC** | Xen IO Rings 虚拟化模型：多 VM 时间域映射 (offset/scale)、IO Ring 生产者/消费者语义、VM 切换事件注入 | `SUPPORT_VPHC` |
| **Host** | 软件侧激励/响应模型：驱动发包线程、描述符环管理、CSR 读写序列、中断处理延迟抽象 | Host 中断延迟参数化 |

### 2.2 范围边界（不建模内容）

| 不建模项 | 理由 |
|---------|------|
| HSPHY (PCS/PMA/SerDes 内部) | 以外部线速流量源/汇 (Traffic Generator/Monitor) 抽象替代，PHY 侧仅保留速率/双工约束 |
| MACsec / IPsec / SecOC / DTLS | `SUPPORT_MACSEC=0` 等默认关闭，安全通道仅预留接口 stub |
| DRE (ETH↔CAN) | 独立组件，本期仅保留 Switch Port 连接点占位 |
| 时钟门控 / 低功耗状态机 | 功耗评估不属于 SystemC 模型精度范围 |
| ECC/Parity 具体编码电路 | 错误注入场景中以抽象 fault flag 表示，不建模纠错电路本身 |

---

## 3. 精度等级 (Accuracy Level)

### 3.1 分级策略

采用 **LT (Loosely Timed) 为主、AT (Approximately Timed) 为辅** 的混合精度策略：

| 精度等级 | 适用组件 | 时间粒度 | 用途 |
|---------|---------|---------|------|
| **LT + 时间标注** | Host、DMA 描述符处理、CSR 访问、vPHC IO Rings | `sc_time` 估计延迟（基于 burst 长度 × 总线周期估算） | 快速功能验证、软件平台、长时场景仿真 |
| **AT (近似周期级)** | Switch Core 交换、MTL 队列调度 (TAS/CBS)、MAC TX/RX 数据通路、PHC 时间戳 | 拍级 (beat-level)：按 `AXI_DATA_WIDTH`/port 线速换算的 flit 传输时间，非真正时钟周期 | 性能评估、线速验证、TSN 门控时序分析 |

### 3.2 AT 精度定义

- **不建模真实时钟周期**：以 `sc_time` 延迟累加表达 beat 传输，例如 64-bit AXI @ 500MHz → 每 beat 2ns；5G MAC 线速 → 每 byte 1.6ns
- **仲裁点精确**：Switch Crossbar 仲裁、DMA 通道池仲裁、TAS 门控边沿为事件驱动精确点（对应帧调度决策时刻）
- **队列占用精确**：MTL FIFO 深度、Switch 共享缓存按 byte 级精确计数（丢帧/背压行为必须与 RTL 一致）
- **时间戳点精确**：PHC 时间戳在模型中的捕获点对应 RTL 的 SFD 检测点（Arch Spec §3.3.4），误差预算 ≤ ±1 个 beat 时间

### 3.3 精度校准

AT 延迟参数（每模块固定延迟、每 beat 传输时间）在 IDR 阶段用 RTL 仿真结果回归校准，目标：关键路径端到端延迟模型值 vs RTL 值偏差 **< 10%**。

---

## 4. 协议映射 (Protocol / Interface Mapping)

| 架构接口 (Arch Spec §5) | SystemC/TLM 映射 | 说明 |
|------------------------|------------------|------|
| **MAC ↔ PHY (xMII/USXGMII)** | AXI4-Stream 抽象通道 (`tdata/tvalid/tready/tlast/tuser`) | beat 级流控；`tuser` 携带时间戳、帧错误标志、时间敏感元数据；PHY 侧接 Traffic Generator |
| **Switch 端口接口 `swi_port_tx_if` / `swi_port_rx_if`** | AXI4-Stream 双向 channel pair | 与 Arch Spec §5.4 信号一一对应：frame data + SOP/EOP + TC/queue 编号 + cut-through 标志 |
| **DMA ↔ 系统内存 (AXI4 Master)** | TLM-2.0 generic payload + `tlm_initiator_socket` | burst 语义保留：`MAX_BURST_LEN`、outstanding 数、ID 并发；内存侧用 `tlm_target_socket` + 稀疏数组建模，附加 AXI 带宽/延迟仲裁器模型 |
| **DMA ↔ MAC/Switch 帧数据** | AXI4-Stream | 描述符控制通路 (TLM-GP) 与帧数据通路 (AXI4-Stream) 分离 |
| **CSR (AXI4-Lite Slave)** | TLM-2.0 generic payload (32-bit, 无 burst) | 寄存器块用回调式寄存器模型 (read/write side-effect 与 RTL CSR 语义对齐) |
| **PHC / vPHC 时间域** | 全局 `sc_time` + 时间域转换服务 (offset/scale 查表) | PHC 计数器 = `sc_time_stamp()` 经 Addend 换算；vPHC = per-VM 仿射变换 |
| **Xen IO Rings (vPHC)** | TLM-GP + 共享内存环形缓冲 + event 通知 | 生产者/消费者索引语义与 Xen ring 协议一致，事件用 `sc_event` 建模 |
| **中断** | `sc_event` / 电平信号抽象 | Host 模型注册中断延迟分布 (固定/随机) |

**Generic Payload 扩展**：DMA 事务使用 `tlm_extension` 携带：通道号、目标 MAC 号、AVTP 流 ID、描述符物理地址——保证流量统计可按通道/MAC 维度分解。

---

## 5. 关键验证场景

### 5.1 场景总览

| 场景 ID | 名称 | 目的 | 通过判据 |
|---------|------|------|---------|
| SC-01 | **线速转发** | 验证 Switch 全端口 5G 线速无丢帧（对应 Arch Spec §4.1/§4.2.1） | 64B 最小帧满负载下丢帧率 = 0（无背压配置）；吞吐 ≥ 99.9% 线速 |
| SC-02 | **TSN 门控调度** | 验证 TAS (802.1Qbv) 门控列表执行精度与 CBS 整形曲线 | 高优先级队列端到端抖动 ≤ 门控周期配置的理论界；CBS 输出符合 credit 曲线 ±5% |
| SC-03 | **多端口并发** | 4 MAC + Host DMA 同时满负荷，验证 DMA 通道池仲裁与共享 MTL 缓存行为 | 无死锁/饿死；聚合吞吐达到 AXI 带宽预算的 ≥ 90%（Arch Spec §4.4 计算器校核） |
| SC-04 | **vPHC VM 切换** | Hypervisor 场景下 VM 时间域热切换 | 切换前后 vPHC 读数单调、无回退；时间戳跨域映射误差 ≤ 1μs（对应 §3.3.6 同步精度目标） |
| SC-05 | **错误注入** | 验证错误检测/传播路径（FCS 错误、runt/giant 帧、描述符错误、FIFO 溢出、CSR timeout） | 错误帧被正确丢弃/标记，错误计数器递增，无错误帧流入 Host 内存 |

### 5.2 SC-01 线速转发 (细节)

- **拓扑**: 4 端口 Switch，每端口 5G (XGMAC)，双向对称流量，全网状 (full-mesh) 转发
- **帧长扫描**: 64B / 128B / 256B / 512B / 1024B / 1518B / jumbo 9018B
- **负载**: 100% 线速 (IFG 最小 12B)，持续仿真 ≥ 10ms 物理时间
- **变体**: (a) store-and-forward vs cut-through; (b) 单播 vs 20% 多播混合; (c) `SWITCH_PORT_COUNT=8` 扩展配置

### 5.3 SC-02 TSN 门控 (细节)

- **配置**: 8 队列 (TC0~TC7)，TAS 门控周期 125μs（典型车载周期），TC7 保护窗口 + 多窗口调度
- **流量**: TC7 周期性强实时流 (2ms 周期, 固定 256B) + TC5 AVB 流 (CBS, idleSlope=2Mbps) + TC0 best-effort 背景流打满
- **观测**: TC7 帧的到达-发送抖动、门控边沿处的帧抢占行为 (`SUPPORT_FP=1` 时 pMAC/eMAC 切换)、CBS credit 时间序列

### 5.4 SC-03 多端口并发 (细节)

- **配置**: `MAC_COUNT=4`, `DMA_CH_COUNT=8`, `DMA_CH_PER_MAC=4`, AXI 128-bit @ 500MHz
- **流量**: 4 MAC 同时 RX 满线速 + Host 同时 TX 4 端口满线速
- **观测**: AXI 总线利用率分布、DMA 描述符 fetch 延迟、通道饥饿检测（单通道等待时间上限）、MTL FIFO 峰值占用

### 5.5 SC-04 vPHC VM 切换 (细节)

- **配置**: `PHC_COUNT=2`, `SUPPORT_VPHC=1`，4 个 VM 时间域（不同 offset/scale）
- **序列**: VM0 运行 → Hypervisor 通过 Xen IO Ring 下发切换 → VM1 接管时间戳请求 → 验证期间 gPTP Sync 持续到达
- **观测**: 切换瞬间时间戳连续性、in-flight 请求的正确归属、IO Ring 溢出/丢失处理

### 5.6 SC-05 错误注入 (细节)

| 注入类型 | 注入点 | 预期行为 |
|---------|-------|---------|
| FCS 错误 (随机 bit flip) | PHY Traffic Generator | RX MAC 标记 `frame_error`，帧丢弃或透传标记（按 CSR 配置），错误计数 +1 |
| Runt (< 64B) / Giant (> 配置上限) | Traffic Generator | 丢弃 + 对应计数器递增 |
| 描述符非法 (OWN bit 冲突 / 地址越界) | Host 模型 | DMA 挂起该通道 + 错误中断，不影响其他通道 |
| MTL RX FIFO 溢出 | 关闭 DMA 排水 | 背压或丢帧（按配置），溢出计数递增 |
| CSR 访问超时 | 模型内挂起 CSR 响应 | CSR Timeout 安全机制触发 (Arch Spec §1.4.3 安全参数) |

---

## 6. 指标定义 (Metrics)

### 6.1 性能指标

| 指标 | 定义 | 测量方法 | 目标值 |
|------|------|---------|--------|
| **端口带宽** | 单位时间成功转发的有效载荷字节数 / 线速 | 每端口 Monitor 计数 SOP~EOP 间字节，滑窗平均 | ≥ 99.9% 线速 (64B 帧, SC-01) |
| **聚合带宽** | 全端口 + Host 方向总和 | 全局 Monitor | 达到 Arch Spec §4.4 带宽计算器理论值的 ≥ 90% |
| **端到端延迟** | 帧 SOP 进入端口 → 同帧 EOP 离开目标端口（含 DMA 路径时到描述符 write-back 完成） | `tuser` 携带注入时间戳，Monitor 采样 | 报告 avg / p99 / max；store-and-forward 下须满足 Arch Spec §4.2 延迟预算 |
| **TSN 抖动** | 周期性流相邻帧到达间隔偏差 | SC-02 中 TC7 流的到达时间序列 | ≤ TAS 门控粒度理论界 |
| **缓存占用** | MTL FIFO / Switch 共享缓存的 byte 级占用时间序列 | 每事件采样，输出峰值/均值/直方图 | 峰值 ≤ 配置深度的 85%（SC-01 满负载）；为 FIFO 深度选型提供依据 |
| **仲裁公平性** | DMA 通道池 / Switch 端口仲裁下，单个请求方最长等待时间与平均等待时间之比 | 记录每请求 grant 等待，计算 Jain's Fairness Index 与 max/avg 比 | Jain's Index ≥ 0.95 (SC-03)；无请求方等待 > 2× 理论最坏界 |

### 6.2 功能正确性指标

| 指标 | 定义 | 通过判据 |
|------|------|---------|
| 转发正确率 | 目的端口、VLAN 处理、FDB 学习结果 vs 期望 | 100% (所有场景) |
| 错误检出率 | 注入错误被检测/计数比例 | 100% (SC-05) |
| 时间戳精度 | 模型时间戳 vs 理论 SFD 时刻偏差 | ≤ 1 beat 时间 (SC-04) |
| 模型-RTL 偏差 | 同一激励下端到端延迟模型值 vs RTL 仿真值 | < 10% (IDR 校准后) |

### 6.3 指标输出形式

所有指标由统一的 Metric Collector 输出为 CSV + JSON 摘要，命名规则 `metrics_<SC-xx>_<config>_<timestamp>.csv`，供 `auto_dashboard.py` 与评审报告引用。

---

## 7. 模型假设与限制

### 7.1 假设

1. **时钟理想化**：各时钟域 (AXI / MAC / PTP) 以标称频率无抖动工作；CDC (异步时钟域穿越) 仅建模为固定延迟 + 弹性 FIFO 吸收，不建模亚稳态
2. **存储器理想化**：系统内存无限大、无 ECC 错误；AXI 从端延迟为参数化固定值 + 带宽竞争仲裁，不建模 DRAM 刷新/bank 冲突
3. **PHY 理想化**：链路始终 up、无自动协商过程、无链路抖动；速率切换通过参数重配置而非动态建模
4. **软件行为简化**：Host 驱动响应中断的延迟为参数化分布，不建模 OS 调度、cache、MMU 页表遍历
5. **TAS 门控列表静态**：门控列表在仿真开始时装载，运行中不重构（符合车载静态配置用法，`SUPPORT_SRP=0`）
6. **帧内容无关**：除 FCS/长度/地址/VLAN/AVTP 头外，payload 内容不影响行为，模型中可用模式填充

### 7.2 限制

| 限制 | 影响 | 应对 |
|------|------|------|
| 非周期精确 | 不能发现 RTL 级流水线气泡、多周期路径问题 | AT 校准 + RTL 回归比对（§3.3） |
| CDC 简化 | 无法暴露异步 FIFO 深度不足导致的亚稳态/丢数据 | 弹性 FIFO 深度单独做 RTL 级验证 |
| 无功耗建模 | 无法评估时钟门控/EEE 收益 | FDR 阶段用门级功耗工具 |
| Host 延迟分布为假设值 | 端到端软件延迟结论仅供趋势参考 | 标注为假设，硅后用实测回填 |
| FRER (802.1CB) 抽象 | 序列号窗口/复制消除逻辑仅行为级 | FRER 功能正确性由 UVM 定向测试保证 |

---

## 8. 与 RTL 的边界

| 维度 | SystemC 模型 | RTL (Design/RTL/ip/ethernet) |
|------|-------------|------------------------------|
| **抽象层** | Transaction-level (LT/AT 混合) | Cycle-accurate, 可综合 |
| **时间基准** | `sc_time` 浮点/整数累加，无真实时钟树 | 真实时钟/复位/CDC 结构 (ethernet_clock_reset_spec.md) |
| **接口** | AXI4-Stream channel / TLM socket | `swi_port_if` 信号级、AXI4 pin 级 |
| **寄存器** | 回调式行为模型，语义对齐 | 实际 CSR 译码逻辑；地址映射以 Arch Spec §1.4.5 为唯一来源 |
| **验证关系** | Golden Reference：帧级 transaction 比对；性能瓶颈先期发现 | 功能正确性 sign-off；覆盖率收集在 RTL/UVM 环境 |
| **比对点** | Switch 出端口帧序列、DMA 描述符 write-back 序列、PHC 时间戳值、错误计数器 | 同左（UVM scoreboard 中逐 transaction 比对） |
| **不承诺** | 模型时序不作为时序收敛依据；模型资源占用不作为面积依据 | — |

**一致性责任**：接口语义 (SOP/EOP 位置、背压规则、描述符字段) 若模型与 RTL 出现分歧，以 Arch Spec / Interface Spec 为仲裁依据，双侧修正。模型版本与 RTL 版本通过 `Docs/Arch/` 与 `Design/RTL/` 的 git tag 关联追溯。

---

## 9. 风险与缓解

| 风险 ID | 风险 | 概率 | 影响 | 缓解措施 |
|---------|------|------|------|---------|
| R-01 | **AT 精度不足**：拍级近似掩盖真实流水线瓶颈，性能结论过于乐观 | 中 | 高 | 关键路径 (Switch 仲裁 + DMA burst) 预留 15% 性能裕量；IDR 阶段用 RTL 仿真回归校准延迟参数（§3.3），偏差 > 10% 时修正模型并重申结论 |
| R-02 | **模型与 RTL 语义漂移**：双侧独立演进导致 Golden Reference 失效 | 高 | 高 | 接口语义唯一来源为 Arch Spec §5；模型纳入 git 版本管理与 IDR checklist；每次 Arch Spec 变更触发模型同步任务 |
| R-03 | **Host/内存假设失真**：理想化 AXI 从端掩盖带宽竞争 | 中 | 中 | AXI 仲裁器模型支持可变从端延迟分布；与 SoC 集成方的 NoC 参数对齐；结论中明确标注假设 |
| R-04 | **场景覆盖不足**：TSN 门控与帧抢占/多队列交互的角落场景遗漏 | 中 | 中 | SC-02 增加门控边沿 + 抢占 + FIFO 近满的复合变体；场景清单评审 (Coding Yang review) 后冻结 |
| R-05 | **仿真性能不足**：10ms 物理时间满负载 LT/AT 仿真耗时过长 | 中 | 低 | LT 模式跑长时场景，AT 仅跑关键窗口；支持 checkpoint/restore；必要时 SC-01 降帧长扫描密度 |
| R-06 | **vPHC Xen 语义理解偏差**：IO Ring 协议细节与真实 Xen 行为不符 | 低 | 中 | 以 Xen ring buffer 公开规范为准建模；Firmware 团队评审 SC-04 序列；不承诺模拟完整 Hypervisor |
| R-07 | **SystemC/TLM 工具链缺失**：环境中无 SystemC 库或版本不兼容 | 低 | 高 | 开始前确认 Accellera SystemC ≥ 2.3.3 + TLM-2.0 可用；纳入 IDR 环境检查项 |

---

## 10. 交付物与里程碑

| 交付物 | 路径 | 阶段 | 依赖 |
|--------|------|------|------|
| 本建模计划 | `Docs/Arch/systemc_modeling_plan.md` | EDR | — |
| SystemC 模型源码 | `Design/SystemC/` (待建) | IDR | 本文档评审通过 |
| 场景激励与 Metric Collector | `Design/SystemC/scenarios/` | IDR | 模型骨架完成 |
| 性能评估报告 (SC-01~SC-05 结果) | `ProjectMgmt/Phases/IDR/Reviews/` | IDR Review | 场景全部执行 |
| 模型-RTL 校准报告 | `ProjectMgmt/Phases/IDR/Reviews/` | IDR 后期 | RTL 仿真可用 |

---

*文件: Docs/Arch/systemc_modeling_plan.md*
*版本: v1.0*
*说明: Ethernet IP SystemC/TLM 系统级建模计划 — 精度分级、协议映射、验证场景与指标定义*
