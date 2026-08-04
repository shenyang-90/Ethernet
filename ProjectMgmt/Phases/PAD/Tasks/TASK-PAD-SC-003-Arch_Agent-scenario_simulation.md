# TASK-PAD-SC-003: 关键场景仿真与架构指标提取

```json
{
  "task_id": "TASK-PAD-SC-003",
  "project_id": "IP_20260502_001",
  "phase": "PAD",
  "task_type": "doc_writing",
  "priority": "P1",
  "status": "PENDING",
  "assigned_to": "Arch_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "2026-05-24",
  "title": "关键场景仿真与架构指标提取",
  "requirements": "基于 TASK-PAD-SC-002 搭建的 TLM 2.0 平台，执行关键场景仿真，提取带宽、端到端延迟、缓存占用、仲裁公平性等指标，输出 SystemC 建模报告，反哺 Arch Spec 与微架构设计。",
  "acceptance_criteria": [
    "完成不少于 5 个关键场景仿真：线速转发、TSN 门控、多端口并发、vPHC VM 切换、错误注入",
    "每个场景给出配置、流量模型、观测点与通过判据",
    "输出带宽、端到端延迟、缓存占用、仲裁公平性等量化指标",
    "指标与 Arch Spec 目标进行对比分析",
    "输出假设一致性检查（模型参数与 Arch Spec 一致）",
    "输出资产移交说明（TLM-to-RTL 一致性验证策略）",
    "通过 Arch Agent 内部评审"
  ],
  "deliverables": {
    "files": [
      "Docs/Arch/systemc_modeling_report.md"
    ],
    "reports": [
      "ProjectMgmt/Phases/PAD/Reviews/checklist.md"
    ]
  },
  "dependencies": {
    "pre_tasks": ["TASK-PAD-SC-002"],
    "blocks": ["TASK-004"]
  },
  "working_directory": "sandbox/ethernet/Docs/Arch/",
  "ai_assist": true,
  "human_review_required": true
}
```

## 执行指令

### Arch Agent 任务分配

**目标**: 通过 TLM 2.0 仿真验证架构假设，确保 Arch Spec 中的性能指标在微架构冻结前得到系统级确认。

**需要完成的工作**:

1. 阅读 `Docs/Arch/systemc_modeling_plan.md` 和 `ethernet_arch_spec.md`
2. 基于 `Design/SystemC/` 平台实现并运行关键场景：
   - SC-01 线速转发（最大/最小帧）
   - SC-02 TSN 门控调度（802.1Qbv）
   - SC-03 多端口并发 + 仲裁
   - SC-04 vPHC VM 切换
   - SC-05 错误注入（CRC/FCS/长度错误）
3. 提取并分析指标：带宽、端到端延迟、缓存占用、仲裁公平性（Jain's Index）
4. 对比 Arch Spec 目标，输出差距分析
5. 若指标不达标，提出 Arch Spec 修改建议（如增大 FIFO、调整仲裁权重）
6. 输出 TLM-to-RTL 一致性验证策略，供 Verification Plan 引用
7. 输出 `systemc_modeling_report.md`

### 交付要求

- 报告必须包含可复现的仿真配置与量化结果
- 所有指标必须与 Arch Spec 目标对比，并给出是否达标的结论
- 假设一致性检查必须覆盖 `SWITCH_PORT_COUNT`、`DMA_CH_COUNT`、`PHC_COUNT` 等关键参数

---

*创建: 2026-05-18 | 状态: PENDING → Arch Agent*
