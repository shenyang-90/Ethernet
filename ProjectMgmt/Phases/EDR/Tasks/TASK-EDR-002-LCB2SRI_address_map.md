# TASK-EDR-002 — LCB2SRI 通道分离配置地址映射

> **任务类型**: EDR 阶段设计任务 (由 PAD ISSUE-002 转移)
> **任务ID**: TASK-EDR-002
> **负责人**: Design Agent
> **前置依赖**: PAD 阶段 Arch Spec v1.4.2 (ISSUE-002 已转移至 EDR)
> **关联 ISSUE**: ISSUE-002
> **创建日期**: 2026-05-12
> **计划完成**: EDR 阶段内
> **状态**: ⏳ 待启动

---

## 1. 任务背景

PAD 阶段 ISSUE-002 提出：5G USXGMII 模式下 LCB2SRI 通道分离配置的具体地址映射未定义。

**PAD 结论**: LCB2SRI（Lane Control Block to SerDes/Ring Interface）是物理层 SerDes 适配模块，地址映射属于微架构实现细节，非 PAD 阶段决策范围。转移至 EDR 阶段由 Design Agent 完成。

---

## 2. 任务目标

定义 LCB2SRI 模块的完整寄存器地址映射，包括：

| 子任务 | 内容 | 输出物 |
|--------|------|--------|
| 2.1 | LCB2SRI 基地址定义 | 寄存器基地址分配表 |
| 2.2 | 通道偏移量计算 | 每通道寄存器偏移公式 |
| 2.3 | 配置位域定义 | 每个配置寄存器的位域说明 |
| 2.4 | 与 USXGMII 5G 模式适配 | 5G 速率下的通道分离策略 |

---

## 3. 参考输入

| 输入 | 路径 | 说明 |
|------|------|------|
| TC4x LCB2SRI 手册 | `Reference/Infineon/016_14 Gigabit Ethernet (GETH).md` §5.4 | 基线参考 |
| Arch Spec v1.4.2 | `Docs/Arch/ethernet_arch_spec.md` | PHY_SPEED=5 (10G) / PHY_TYPE=3 (USXGMII) 配置 |
| ISSUE-002 PAD 结论 | `Docs/Arch/ethernet_arch_spec.md` §8.2 | PAD 阶段结论摘要 |

---

## 4. 验收标准

- [ ] LCB2SRI 寄存器地址映射表纳入 `Docs/Design/ethernet/ethernet_design_spec.md`
- [ ] 地址映射通过 Verification Agent 的寄存器访问测试用例覆盖
- [ ] 5G USXGMII 模式下的通道分离策略与 PHY 接口时序兼容

---

*由 PAD 阶段 ISSUE-002 转移创建 | Arch Spec v1.4.2 零问题声明附件*
