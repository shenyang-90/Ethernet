```json
{
  "task_id": "TASK-PAD-REWORK-004",
  "owner": "Arch_Agent",
  "status": "COMPLETED",
  "priority": "P0",
  "phase": "PAD (补完)",
  "dependencies": [
    "无 (TASK-PAD-REWORK-001/002 已完成)"
  ],
  "blockers": [
    "TASK-004 (EDR)"
  ],
  "progress": 100,
  "acceptance_criteria": [
    {
      "item": "Arch Spec 与 Design Spec 的 `SWITCH_PORT_COUNT` 范围完全一致",
      "completed": true
    },
    {
      "item": "子模块实例化策略明确 (generate / 固定 / 混合)",
      "completed": true
    },
    {
      "item": "门数估算按最终端口数范围更新",
      "completed": true
    }
  ],
  "deliverables": [],
  "created_at": "2026-05-21"
}
```

---

## 背景

RTL-CRIT-004: Arch Spec 定义 `SWITCH_PORT_COUNT` 范围 2~8，但 Design Spec 子模块实例数固定为 4 (`sw_ingress` ×4, `sw_egress_port` ×4)。

## 交付物

1. **更新 `ethernet_arch_spec.md`** — 统一 `SWITCH_PORT_COUNT` 范围:
   - 选项 A: 锁定 2~4 (保守，降低验证空间)
   - 选项 B: 支持 2~8 (需 Design Spec 重写子模块为参数化实例化)
   - 推荐: 经与实体 Yang 确认后选择

2. **更新 `ethernet_design_spec.md`** — 子模块实例化策略与 Arch Spec 对齐

## 验收标准

- [x] Arch Spec 与 Design Spec 的 `SWITCH_PORT_COUNT` 范围完全一致
- [x] 子模块实例化策略明确 (generate / 固定 / 混合)
- [x] 门数估算按最终端口数范围更新

---

*创建时间: 2026-05-21 | 创建人: AI Yang*
