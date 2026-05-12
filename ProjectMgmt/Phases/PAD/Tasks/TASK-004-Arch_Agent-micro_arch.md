# TASK-004: 微架构设计

```json
{
  "task_id": "TASK-004",
  "project_id": "IP_20260502_001",
  "phase": "PAD",
  "task_type": "doc_writing",
  "priority": "P1",
  "status": "COMPLETED",
  "status_detail": "FINAL_APPROVAL_GRANTED_TASK_CLOSED",
  "deliverables_status": {
    "ethernet_design_spec.md": "COMPLETE (v1.0, 基于 Arch Spec v1.8d: Switch混合架构 + 双PHC+Crossbar + vPHC + 全局DMA池 + 低功耗模式 + ASIL-B基线)"
  },
  "assigned_to": "Arch_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "TBD",
  "title": "微架构设计与模块划分",
  "requirements": "完成模块划分、数据通路设计、子模块接口定义。依赖TASK-003 Arch Spec完成。",
  "acceptance_criteria": [
    "模块划分图完成",
    "数据通路与控制通路明确",
    "子模块接口定义"
  ],
  "deliverables": {
    "files": [
      "Docs/Design/ethernet/ethernet_design_spec.md(架构部分)"
    ]
  },
  "dependencies": {
    "pre_tasks": ["TASK-003"],
    "blocks": []
  },
  "working_directory": "sandbox/ethernet/Docs/Design/",
  "ai_assist": true,
  "human_review_required": true
}
```

## 执行状态

- **2026-05-12**: 依赖TASK-003已关闭（COMPLETED），本任务由PAD Orchestrator自动解阻塞并标记为IN_PROGRESS
- **2026-05-12 20:45**: 微架构设计Spec **v1.0 完成**，基于 Arch Spec v1.8d 全面升级:
  - Switch Core (4-port L2/L3) + 混合架构 (`SWITCH_CONNECTED_MAC_x`)
  - 双 PHC + Crossbar + vPHC 虚拟化
  - 全局 DMA 通道池 (8/16/32)
  - 低功耗模式 (EEE/WoL/Deep Sleep)
  - ASIL-B 基线安全架构
- **交付物**: `Docs/Design/ethernet/ethernet_design_spec.md` v1.0
