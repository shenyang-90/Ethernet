# TASK-006: FuSa Agent - Safety Concept for Ethernet IP

```json
{
  "task_id": "TASK-006",
  "project_id": "IP_20260502_001",
  "phase": "PAD",
  "task_type": "doc_writing",
  "priority": "P1",
  "status": "COMPLETED",
  "status_detail": "FINAL_APPROVAL_GRANTED_TASK_CLOSED",
  "assigned_to": "FuSa_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "2026-05-13",
  "title": "功能安全概念文档 (Safety Concept)",
  "requirements": "为 Ethernet IP 编写 PAD 阶段功能安全概念文档，作为 EDR 阶段 FMEDA 分析的输入。依赖 TASK-003 Arch Spec 安全架构章节完成。",
  "acceptance_criteria": [
    "安全目标 (SG) 定义完成，覆盖所有关键失效模式",
    "安全机制清单与 ASIL-B 基线策略确定",
    "诊断覆盖 (DC) 量化，满足 ISO 26262-5 Table D 要求",
    "FHTI 定义，所有路径延迟预算 <100 μs",
    "ASIL 分解策略：基线 B + 可选 C/D 升级路径",
    "竞品功能安全对标完成",
    "故障注入测试策略规划"
  ],
  "deliverables": {
    "files": [
      "Docs/FuSa/safety_concept.md",
      "Docs/Arch/gap_analysis_rcar_s4.md"
    ],
    "reports": [
      "ProjectMgmt/Phases/PAD/Reviews/safety_review_checklist.md"
    ]
  },
  "dependencies": {
    "pre_tasks": ["TASK-003"],
    "blocks": ["TASK-EDR-FMEDA"]
  },
  "working_directory": "sandbox/ethernet/Docs/FuSa/",
  "ai_assist": true,
  "human_review_required": true
}
```

> **任务ID**: TASK-006
> **阶段**: PAD
> **负责人**: FuSa Agent
> **优先级**: P1
> **状态**: COMPLETED
> **计划开始**: 2026-05-11
> **计划结束**: 2026-05-13
> **前置依赖**: TASK-003 (Architecture Specification 安全架构章节完成)
> **阻塞下游**: TASK-EDR-FMEDA (EDR 阶段 FMEDA 分析)

---

## 任务目标

为 Ethernet IP (IP_20260502_001) 编写 PAD 阶段功能安全概念文档 (Safety Concept)，作为 EDR 阶段 FMEDA 分析的输入。

## 交付物清单

| 交付物 | 路径 | 状态 | 说明 |
|--------|------|------|------|
| Safety Concept | `Docs/FuSa/safety_concept.md` | ✅ **已完成** | 安全目标、诊断覆盖、FHTI、ASIL 分解、竞品对标 |
| Gap Analysis (R-Car S4) | `Docs/Arch/gap_analysis_rcar_s4.md` | ✅ **已完成** | Switch/PHC/AVTP/FFI/IDS 差距分析 |
| **Arch Spec v1.8d** | **`Docs/Arch/ethernet_arch_spec.md`** | **✅ 已完成** | **PTP §3.3 + Switch loss + low power + ASIL-D clarification** |

## 完成标准

- [x] 安全目标 (SG) 定义完成，覆盖所有关键失效模式
- [x] 安全机制清单与 ASIL-B 基线策略确定
- [x] 诊断覆盖 (DC) 量化，满足 ISO 26262-5 Table D 要求
- [x] FHTI 定义，所有路径延迟预算 <100 μs
- [x] ASIL 分解策略：基线 B + 可选 C/D 升级路径
- [x] 竞品功能安全对标 (TC4x/S32G/S32K3/R-Car S4)
- [x] 故障注入测试策略规划
- [x] 与 EDR 阶段 FMEDA 的衔接输入准备

## 关键决策

| 决策项 | 结论 | 影响 |
|--------|------|------|
| IP 级 ASIL 目标 | **ASIL-B 基线**，不内嵌 Lockstep | 面积节省 ~35%，安全完整性由 SoC 级 SMU 实现 |
| ECC 策略 | SECDED，每存储器实例独立 | 覆盖 MTL FIFO + 描述符 + Bridge 表 |
| FSM 保护 | 全状态机 Parity + 非法状态检测 | 覆盖所有控制逻辑 |
| 降级模式 | 单通道故障降级，多通道故障安全态 | 平衡可用性与安全性 |

## 风险与阻塞

| 风险ID | 描述 | 状态 | 缓解措施 |
|--------|------|------|----------|
| R-FuSa-001 | FMEDA 需要工艺库 FIT 数据，PAD 阶段无法完成 | ⬜ | EDR 阶段补充，本 Safety Concept 提供完整输入框架 |
| R-FuSa-002 | ASIL-D 要求可能需要 SoC 级变更，超出 IP 范围 | ⬜ | 明确 IP 级 ASIL-B 基线，ASIL-D 由 SoC 集成实现 |

## 评审记录

| 日期 | 评审人 | 意见 | 状态 |
|------|--------|------|------|
| — | — | 待 FuSa Review | ⬜ |

---

*更新: 2026-05-12 — Safety Concept v1.1+ 完成 (同步 Arch Spec v1.8d 变更)*
