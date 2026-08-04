# TASK-PAD-SC-001: SystemC/TLM 建模计划与精度定义

```json
{
  "task_id": "TASK-PAD-SC-001",
  "project_id": "IP_20260502_001",
  "phase": "PAD",
  "task_type": "doc_writing",
  "priority": "P1",
  "status": "PENDING",
  "assigned_to": "Arch_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "2026-05-19",
  "title": "SystemC/TLM 2.0 建模计划与精度定义",
  "requirements": "制定 Ethernet IP 在 PAD 阶段的 SystemC + TLM 2.0 建模计划，明确建模范围、精度等级、协议映射、关键场景与指标定义，为架构冻结提供系统级性能与功能评估依据。",
  "acceptance_criteria": [
    "建模计划文档覆盖 Switch Core / MAC / DMA / PHC / vPHC / Host 全组件",
    "明确 LT/AT 精度等级划分及适用模块",
    "定义 AXI4-Stream / AXI4-MM / TLM generic payload 的映射策略",
    "列出不少于 5 个关键场景（线速转发、TSN 门控、多端口并发、vPHC VM 切换、错误注入）",
    "定义可量化指标（带宽、端到端延迟、缓存占用、仲裁公平性）",
    "明确模型与 RTL 的边界和假设",
    "通过 Arch Agent 内部评审"
  ],
  "deliverables": {
    "files": [
      "Docs/Arch/systemc_modeling_plan.md"
    ],
    "reports": []
  },
  "dependencies": {
    "pre_tasks": ["TASK-003"],
    "blocks": ["TASK-PAD-SC-002"]
  },
  "working_directory": "sandbox/ethernet/Docs/Arch/",
  "ai_assist": true,
  "human_review_required": true
}
```

## 执行指令

### Arch Agent 任务分配

**目标**: 在 Arch Spec 冻结前，建立 SystemC/TLM 2.0 建模的顶层计划，避免后续建模工作方向性返工。

**需要完成的工作**:

1. 阅读 `Docs/Arch/ethernet_arch_spec.md`、`ethernet_interface_spec.md`、`ethernet_clock_reset_spec.md`
2. 确定建模范围：哪些模块必须建模（Switch Core / MAC / DMA / PHC / vPHC / Host），哪些不建模（HSPHY、MACsec、DRE、功耗等）
3. 确定精度等级：哪些模块用 Loosely-Timed (LT)，哪些用 Approximately-Timed (AT)，并给出与 RTL 的精度目标（如偏差 <10%）
4. 确定协议映射：xMII/`swi_port_if` 到 AXI4-Stream，DMA/CSR 到 TLM generic payload，PHC 时间域建模方式
5. 定义关键场景与通过判据
6. 定义指标定义与输出格式（CSV/JSON）
7. 列出模型假设、限制与风险缓解措施

### 交付要求

- 文档必须达到可评审状态，包含可执行的建模范围、精度、场景和指标
- 与现有 Arch Spec 交叉引用，参数保持一致（如 `SWITCH_PORT_COUNT`、`DMA_CH_COUNT`、`PHC_COUNT`）

---

*创建: 2026-05-18 | 状态: PENDING → Arch Agent*
