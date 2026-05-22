# TASK-PAD-REWORK-003: vPHC 硬件接口定义补完

**任务ID**: TASK-PAD-REWORK-003
**负责人**: RTL_Coding_Agent + Arch_Agent
**状态**: ✅ **COMPLETED**
**优先级**: P0
**所属阶段**: PAD (补完)
**前置依赖**: 无
**下游阻塞**: TASK-004 (EDR)

---

## 背景

RTL-CRIT-003: vPHC Xen IO Ring 是软件/虚拟化概念，RTL 需要的是硬件接口信号清单。

实体 Yang 决策: **有 Hypervisor**，`SUPPORT_VPHC` 保持 P1，需补完硬件接口定义。

## 交付物

1. **`Docs/Design/ethernet/vphc_hw_interface.md`** — vPHC 硬件接口定义
   - VM ID 解码逻辑 (来自哪个总线/寄存器?)
   - PHC 选择 MUX (VM → PHC 映射表)
   - 虚拟时间偏移寄存器组 (per-VM offset register)
   - 中断分发逻辑 (VM 间的虚拟中断隔离)
   - CSR 寄存器映射 (vPHC 控制/状态/时间偏移)
   - 时序: VM 切换延迟、时间偏移更新时间

2. **更新 `ethernet_arch_spec.md` §3.3** — 补充 vPHC 硬件框图，替换 Xen IO Ring 软件概念

## 验收标准

- [x] 硬件信号清单完整 (输入/输出/宽度/时钟域)
- [x] VM → PHC 映射表可配置
- [x] 虚拟中断隔离机制明确
- [x] 与 Xen/KVM 等 Hypervisor 的对接方式说明 (若适用)

**交付物确认**: `Docs/Design/ethernet/vphc_hw_interface.md` v1.0 已创建 (13KB)，基于 Arch Spec v1.8c ISSUE-007 决议，采用硬件虚拟化层替代 Xen IO Ring 方案。

---

*创建时间: 2026-05-21 | 创建人: AI Yang | 完成时间: 2026-05-22 (PAD Orchestrator 自动补完) | 状态: COMPLETED*
