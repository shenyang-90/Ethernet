# TASK-PAD-REWORK-001: Switch Core FDB 存储与查表微架构补完

**任务ID**: TASK-PAD-REWORK-001
**负责人**: RTL_Coding_Agent + Arch_Agent
**状态**: ✅ **COMPLETED**
**优先级**: P0
**所属阶段**: PAD (补完)
**前置依赖**: 无
**下游阻塞**: TASK-PAD-REWORK-002 (仲裁算法), TASK-004 (EDR 微架构设计)

---

## 背景

RTL_Coding_Agent 在 PAD Gate Review 中发现 Critical 问题 RTL-CRIT-001:
> Switch Core FDB/L3 查表微架构完全缺失，无法 RTL 编码。8K FDB @ 300MHz 的查表方案未定义。

实体 Yang 决策: **PAD 阶段补完**，不推入 EDR。

## 交付物

1. **`Docs/Design/ethernet/switch_fdb_microarch.md`** — FDB 存储与查表微架构设计文档
   - 8K FDB 存储实现方案 (SRAM 宏 / 寄存器堆 / TCAM 接口)
   - 查表流水线级数与时序约束
   - FDB 条目格式 (MAC + VLAN + Port + Age + Flag)
   - 老化 (Aging) 机制硬件实现
   - 源地址学习 (SA Learning) 硬件逻辑框图

2. **更新 `ethernet_arch_spec.md` §2.1 / §6.1** — 补充 errata ID GETH_AI.028/030 的独立条目

## 验收标准

- [x] FDB 存储方案明确 (SRAM 型号/端口数/位宽，或寄存器堆方案)
- [x] 查表延迟约束定义 (如: "查表需在 N 个 clk_mac 周期内完成")
- [x] 8K 条目 @ 300MHz 的时序闭合方案可验证
- [x] 与 Arch Spec v1.8c 参数 `SWITCH_PORT_COUNT` 范围一致

**交付物确认**: `Docs/Design/ethernet/switch_fdb_microarch.md` v1.0 已提交 (33KB)

---

*创建时间: 2026-05-21 | 创建人: AI Yang (PAD Gate Review 决策驱动) | 完成时间: 2026-05-21 | 状态: COMPLETED*
