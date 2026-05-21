# 决策记录: DEC-001 — SWITCH_PORT_COUNT 参数一致性

> **决策 ID**: DEC-001  
> **主题**: `SWITCH_PORT_COUNT` 范围与 Design Spec 参数化策略  
> **日期**: 2026-05-21  
> **作者**: Arch_Agent (PAD-REWORK-004)  
> **状态**: **Closed** (已实施)  
> **关联缺陷**: RTL-CRIT-004 (Critical)  
> **关联任务**: PAD-REWORK-001 (FDB 微架构), PAD-REWORK-002 (仲裁器设计), PAD-REWORK-004 (本任务)  

---

## 1. 问题陈述

**RTL-CRIT-004 (Critical)**: Arch Spec v1.8c §1.4.1 定义 `SWITCH_PORT_COUNT` 可配置范围为 **2~8**，默认值为 **4**。但 Design Spec v1.0 §4.4 中 Switch Core 子模块实例数固定为 4 (`sw_ingress` ×4, `sw_egress_port` ×4, `sw_ingress_fifo` ×4 等)，导致架构定义与微架构实现不一致。此为**阻塞性缺陷** — 若按 Design Spec 实现 RTL，8-port Central Gateway (Config-D) 需求无法满足。

---

## 2. 决策选项对比

| 维度 | **选项 A: 保守 (2~4)** | **选项 B: 完整 (2~8)** | **选项 C: 混合 (默认4, 可扩展8) ✅** |
|------|:----------------------:|:----------------------:|:------------------------------------:|
| **Arch Spec 范围** | 缩减为 2~4 | 保持 2~8 | **保持 2~8，明确分级** |
| **Design Spec 改动量** | 小 (仅改文档范围) | 大 (全参数化 generate) | **中等 (参数化 generate + 分级说明)** |
| **验证空间** | 小 (4-port 为主) | 大 (2~8 全验证) | **可控 (2~4 为主验证, 5~8 扩展验证)** |
| **FDB 面积** | ~84KB SRAM (N=4) | ~84~168KB (N=4~8) | **~84KB 默认, ~168KB 扩展** |
| **仲裁器面积** | ~14kGE (N=4) | ~14~52kGE (N=4~8) | **~14kGE 默认, ~52kGE 扩展** |
| **Config-D 支持** | ❌ 不支持 8-port | ✅ 完全支持 | **✅ 支持 (编译时选配)** |
| **RTL 复杂度** | 低 | 高 (generate 块 + 宽度参数) | **中等 (标准 generate 块)** |
| **与已完成微架构对齐** | ❌ 需回退 FDB/仲裁器 | ✅ 完全对齐 | **✅ 完全对齐** |

---

## 3. 已有参考交付物分析

| 交付物 | 端口支持 | 面积数据 (关键) | 状态 |
|--------|----------|----------------|------|
| `switch_fdb_microarch.md` v1.0 (PAD-REWORK-001) | **2~8** | N=4: ~84KB SRAM + ~12kGE; N=8: ~168KB SRAM + ~20kGE (2组SRAM) 或 3-cycle等待 (1组SRAM) | ✅ 已完成 |
| `switch_arbiter_design.md` v1.0 (PAD-REWORK-002) | **2~8** | N=4: ~14kGE; N=8: ~52kGE; Crossbar N×N | ✅ 已完成 |

**关键发现**: FDB 和仲裁器微架构设计已**提前完成** 2~8 参数化支持。Design Spec 是唯一滞后文档。若选择选项 A (缩减至 2~4)，将导致已完成微架构工作部分失效，且无法支持 Config-D。

---

## 4. 最终决策: 选项 C (混合策略)

### 4.1 决策理由

1. **下游微架构已完成 2~8 支持**: FDB (PAD-REWORK-001) 和仲裁器 (PAD-REWORK-002) 均已按 2~8 参数化设计完成。回退到 2~4 会浪费已完成工作。
2. **Config-D 是真实需求**: 中央网关 8-port 场景在车载以太网中常见 (如 Zone Controller 骨干网汇聚)。Arch Spec 当初定义 2~8 即为此目的。
3. **验证风险可控**: 采用 "Primary Path (2~4) + Extended Path (5~8)" 分级策略，确保 2~4 作为主验证路径达到高成熟度，5~8 作为编译时扩展选项在需要时验证。
4. **面积可接受**: N=8 时 Switch Core ~90kGE + ~250KB SRAM，在 22nm 工艺下仍属合理范围 (参考 R-Car S4 RSwitch2 规模)。
5. **RTL 实现标准化**: `generate for` 块是 SystemVerilog 标准参数化方法，无技术风险。

### 4.2 实施内容

#### Arch Spec 更新 (`Docs/Arch/ethernet_arch_spec.md` v1.8c → v1.8d)
- §1.4.1: `SWITCH_PORT_COUNT` 说明增加 "默认 4，可扩展至 8"
- §2.1: 系统框图 Switch Core 标注改为 "N=2~8 ports, 默认N=4"
- §4.3: 资源估算从固定 ~80kGE/16KB 改为参数化:
  - Switch Core: ~14~52kGE (仲裁器) + ~84~128KB SRAM (FDB+VLAN+L3+GCL)
  - 新增 N=2/4/8 分解表，引用 FDB/仲裁器交付物数据
  - 典型场景增加 8-port 扩展估算 (~280kGE, ~210KB SRAM)

#### Design Spec 更新 (`Docs/Design/ethernet/ethernet_design_spec.md` v1.0 → v1.1)
- §1.1 / §1.2 / §2.3: 所有 "4-port" 改为 "N-port (N=SWITCH_PORT_COUNT)"
- §4.4.1: 实例数表 `sw_ingress`/`sw_ingress_fifo`/`sw_egress_port` 从 "4" 改为 "**N**"
- **新增 §4.4.1a**: 参数化 `generate` 块实例化策略 — 含完整 Verilog 代码模板、per-port / single-instance 模块分类、与 Arch Spec 对齐检查表
- §4.4.3: Crossbar 描述 "4 端口同时线速" 改为 "N 端口同时线速"
- §4.6.1: `ptc_timestamp`/`ptc_pps_gen` 从 "×4" 改为 "**×N**"; `ptc_crossbar` 绑定从硬编码 `[0..3]` 改为 `generate` 循环
- §4.6.2: Crossbar 绑定代码改为 `generate for` 循环
- §4.6.4: TC 验证目标从 "4-port" 改为 "N-port (验证基准 N=4,8)"
- μARCH-002 状态更新: Open → **Closed**，引用 `switch_fdb_microarch.md`

#### 新建决策记录
- 本文档 (`DEC-001_switch_port_count.md`) 记录完整决策过程

---

## 5. 风险与缓解

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|:------:|:----:|----------|
| 8-port 验证覆盖不足 | 中 | Major | EDR 阶段优先验证 N=4; N=8 在 FDR 阶段通过配置矩阵覆盖 |
| FDB 5~8 端口仲裁等待增加 (3-cycle) | 低 | Minor | 1G 线速下 3-cycle ≈ 30ns，远小于 64B 帧前导时间 (~64ns)，cut-through 不受影响 |
| 仲裁器 N=8 面积 ~52kGE 超出早期预算 | 低 | Minor | Arch Spec §4.3 已更新为参数化估算; 实际面积需 RTL 综合后校准 |
| generate 块综合工具兼容性 | 低 | Minor | 使用标准 SystemVerilog-2005 `generate for` + `genvar`，主流工具 (DC/Genus/Primetime) 全支持 |

---

## 6. 验收标准检查

| 检查项 | 标准 | 状态 |
|--------|------|:----:|
| Arch Spec 与 Design Spec 的 `SWITCH_PORT_COUNT` 范围完全一致 | 均为 2~8, 默认 4 | ✅ |
| 子模块实例化策略明确 (generate / 固定 / 混合) | §4.4.1a 明确 `generate for` + 单实例核心模块分类 | ✅ |
| 门数/SRAM 估算按最终端口数范围更新 | §4.3 引用 FDB ~84KB, 仲裁器 ~52kGE @ N=8 | ✅ |
| 与 5 个黄金配置兼容 | Config-A~E (含 Config-D 8-port) 均可通过参数化实现 | ✅ |

---

## 7. 关联文档

- `Docs/Arch/ethernet_arch_spec.md` v1.8d (已更新)
- `Docs/Design/ethernet/ethernet_design_spec.md` v1.1 (已更新)
- `Docs/Design/ethernet/switch_fdb_microarch.md` v1.0 (PAD-REWORK-001)
- `Docs/Design/ethernet/switch_arbiter_design.md` v1.0 (PAD-REWORK-002)

---

*记录完成。决策已实施，等待 PM Agent / AI Yang 批判性检查。*
