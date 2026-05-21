# TASK-PAD-REWORK-009: Verification 黄金配置 + 覆盖率目标定义

**任务ID**: TASK-PAD-REWORK-009
**负责人**: Verification_Agent
**状态**: PENDING
**优先级**: P0
**所属阶段**: PAD (补完)
**前置依赖**: TASK-PAD-REWORK-004 (SWITCH_PORT_COUNT 范围确定)
**下游阻塞**: TASK-006 (EDR Verification Plan)

---

## 背景

VERIF-CRIT-001: 35+ 参数组合爆炸，未定义 "黄金配置" 验证子集。
VERIF-CRIT-002: 覆盖率目标完全未定义 (line/branch/FSM/assertion/functional/cross)。
实体 Yang 决策: **不投入 Formal 验证** → VERIF-CRIT-003 降级为不适用。

## 交付物

1. **`Docs/Verification/verification_plan_v1.0.md`** — 或更新到现有文档:
   - 定义 5 个 "黄金配置" (nightly regression 基线):
     - Config-A: 最小配置 (1 MAC, 1 PHY, 无 Switch, QM)
     - Config-B: 标准车载 (2 MAC, 2 PHY, Switch 4-port, ASIL-B)
     - Config-C: 全功能 (4 MAC, 4 PHY, Switch 4-port, TSN + MACsec + AVTP, ASIL-B)
     - Config-D: 最大性能 (8 MAC, 8 PHY, Switch 8-port, 5G + TSN + FRER, ASIL-B)
     - Config-E: 安全升级 (2 MAC, 2 PHY, ASIL-D 等级安全机制全开)
   - 覆盖率目标:
     - Line coverage ≥ 95%
     - Branch coverage ≥ 90%
     - FSM coverage ≥ 98%
     - Assertion coverage ≥ 95%
     - Cross coverage: 参数组合 × 协议场景
   - TC4x erratum 回归套件: 13 项 erratum 各建立 testcase ID + SVA 断言防退化
   - PICS Yes/No/Configurable 映射到具体 test case ID

## 验收标准

- [ ] 5 个黄金配置参数值明确，覆盖出货主要场景
- [ ] 覆盖率目标数值有依据 (对标行业/竞品/ISO 26262 要求)
- [ ] 每个 TC4x erratum 有对应 testcase ID
- [ ] PICS 每个 Yes/No 项映射到 ≥1 个 test case

---

*创建时间: 2026-05-21 | 创建人: AI Yang*
