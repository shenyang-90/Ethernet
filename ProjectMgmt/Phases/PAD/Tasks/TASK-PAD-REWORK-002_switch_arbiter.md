# TASK-PAD-REWORK-002: Switch Core Egress 仲裁算法补完

**任务ID**: TASK-PAD-REWORK-002
**负责人**: RTL_Coding_Agent + Arch_Agent
**状态**: PENDING
**优先级**: P0
**所属阶段**: PAD (补完)
**前置依赖**: TASK-PAD-REWORK-001 (FDB 存储方案确定后仲裁输入确定)
**下游阻塞**: TASK-004 (EDR)

---

## 背景

RTL-CRIT-002: Switch Core Egress 仲裁算法缺失 — "Crossbar 全并发" 是概念描述，无仲裁伪代码/状态机。

实体 Yang 决策: **PAD 阶段补完**。

## 交付物

1. **`Docs/Design/ethernet/switch_arbiter_design.md`** — Egress 仲裁器设计文档
   - 输出端口冲突时的仲裁算法 (轮询 / 严格优先级 / 加权?)
   - 仲裁状态机图 (FSM)
   - 4-port/8-port 场景下的仲裁延迟分析
   - 与 FRER 冗余流的仲裁优先级处理
   - 与 TAS Gate Control List 的时序协同

## 验收标准

- [ ] 仲裁算法明确且可综合
- [ ] 仲裁状态机图完整
- [ ] 最坏情况仲裁延迟定量分析
- [ ] 与 TAS/FRER/AVTP 流量的优先级策略定义

---

*创建时间: 2026-05-21 | 创建人: AI Yang*
