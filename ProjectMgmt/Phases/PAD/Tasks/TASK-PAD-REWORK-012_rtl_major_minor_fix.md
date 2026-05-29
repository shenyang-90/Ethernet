# TASK-PAD-REWORK-012: RTL Major/Minor 修复 (MAJ-003,4,5 + MIN-002)

**任务ID**: TASK-PAD-REWORK-012
**负责人**: **RTL_Coding_Agent** (已分配)
**状态**: **ASSIGNED**
**优先级**: P1
**所属阶段**: PAD 补完 / EDR 入口
**前置依赖**: 无
**下游阻塞**: EDR 启动

---

## 背景

实体 Yang 选定 27 个 Major/Minor issue 需要修改。RTL Agent 负责其中 4 个（3 Major + 1 Minor）。

## 交付物

### RTL-MAJ-003: 10BASE-T1S PLCA 时钟域定义
**位置**: `ethernet_clock_reset_spec.md` / `ethernet_arch_spec.md` §6.2.9
**问题**: PLCA timer 参考时钟未明确（80ns 周期暗示 12.5MHz？未确认）
**修复**:
- 明确 PLCA timer 参考时钟: **`clk_plca = clk_sys / 16 = 12.5MHz` (200MHz ÷ 16)**
- 在 Clock-Reset Spec 新增 §1.5 **PLCA Reference Clock**
- 定义 PLCA timer 的时钟域归属和 CDC 策略（若与 `clk_mac` 不同域）

### RTL-MAJ-004: DMA AXI outstanding / QoS / ID 分配
**位置**: `ethernet_design_spec.md` §4.1 / `ethernet_arch_spec.md` §5.2
**问题**: 32 通道共享 AXI Master，outstanding/QoS/ID 未定义，死锁风险
**修复**:
- 定义 **AXI ID 分配表**: 每通道 TX/RX ID 范围，避免冲突
- 定义 **outstanding 上限**: 每通道 4~8 outstanding，全局上限 32
- 定义 **QoS 映射**: DMA 通道优先级 → AXI AWQOS/ARQOS
- 在 Design Spec §4.1.4 新增 "AXI Protocol Parameters" 小节

### RTL-MAJ-005: 关闭 μARCH-001/005/007/008/009/010
**位置**: `ethernet_design_spec.md` §7
**问题**: 6 个 Open 问题未定稿，RTL 设计不确定
**修复**:
逐一给出默认决策并关闭:
- **μARCH-001**: FIFO 单/双端口 → 默认 **双端口** (MTL_TX/RX_FIFO)，Switch ingress/egress FIFO 用 **单端口 SRAM 宏**
- **μARCH-005**: 帧抢占 FIFO 独立/共享 → 默认 **独立** (express/preempt 各一)
- **μARCH-007**: PHC 偏差补偿 → 默认 **Crossbar + per-port 微调寄存器**
- **μARCH-008**: vPHC 延迟 → 已由 `vphc_hw_interface.md` 定义硬件虚拟化层，标记 **Closed**
- **μARCH-009**: 低功耗序列 → 默认 **clk_sys 域状态机控制，clk_mac 可门控**
- **μARCH-010**: DMA 仲裁公平性 → 默认 **加权轮询 (WRR)**，权重可配置

### RTL-MIN-002: 参数默认值统一
**位置**: `ethernet_design_spec.md` §6 / `ethernet_arch_spec.md` §1.4
**问题**: `MAC_COUNT` Design Spec=4 vs Arch Spec=2；`DMA_CH_COUNT` Design Spec=8 vs Arch Spec=16 等
**修复**:
- 统一所有参数默认值，**以 Arch Spec §1.4 为基准**
- 列出差异表，逐一修正 Design Spec

## 验收标准

- [ ] PLCA 时钟域在 Clock-Reset Spec 中定义（12.5MHz，clk_sys÷16）
- [ ] AXI outstanding/QoS/ID 在 Design Spec §4.1.4 中定义
- [ ] μARCH-001/005/007/008/009/010 全部关闭，有默认决策
- [ ] Design Spec 参数默认值与 Arch Spec 一致

完成后执行 `git add -A && git commit -m "RTL: MAJ-003,4,5 + MIN-002 修复 (PAD-REWORK-012)"`
