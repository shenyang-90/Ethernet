# TASK-003: Architecture Specification

```json
{
  "task_id": "TASK-003",
  "project_id": "IP_20260502_001",
  "phase": "PAD",
  "task_type": "doc_writing",
  "priority": "P0",
  "status": "COMPLETED",
  "status_detail": "FINAL_APPROVAL_GRANTED_TASK_CLOSED",
  "deliverables_status": {
    "protocol_analysis.md": "COMPLETE (v1.2, 800+ lines, 23 errata full coverage)",
    "ethernet_arch_spec.md": "COMPLETE (v1.8d, PTP §3.3 + Switch loss + low power + ASIL-D clarification)",
    "ethernet_interface_spec.md": "COMPLETE (v1.0, per-instance params + SWITCH_CONNECTED_MAC_x arrays)",
    "ethernet_clock_reset_spec.md": "COMPLETE (v1.0, clk_ts=250MHz + PTP clock domain)"
  },
  "assigned_to": "Arch_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "2026-05-18",
  "title": "编写Architecture Specification并细化协议分析",
  "requirements": "基于TASK-015的protocol_analysis.md初稿，完成：1) 细化protocol_analysis.md（整合Kimi Agent的dim研究材料）；2) 编写完整的Architecture Spec；3) 编写Interface Spec；4) 编写Clock/Reset Spec。protocol_analysis.md作为Arch Spec的参考章节输入。",
  "acceptance_criteria": [
    "protocol_analysis.md已细化（协议依赖关系精确、实现优先级可执行）",
    "Arch Spec所有章节完成（含协议分析参考章节）",
    "Interface Spec接口定义完整（AXI/PHY/CSR/时钟）",
    "Clock/Reset Spec时钟域划分明确、复位策略完整",
    "通过Arch Review"
  ],
  "deliverables": {
    "files": [
      "Docs/Arch/protocol_analysis.md (细化版)",
      "Docs/Arch/ethernet_arch_spec.md",
      "Docs/Arch/ethernet_interface_spec.md",
      "Docs/Arch/ethernet_clock_reset_spec.md"
    ],
    "reports": [
      "ProjectMgmt/Phases/PAD/Reviews/checklist.md"
    ]
  },
  "dependencies": {
    "pre_tasks": ["TASK-015"],
    "blocks": ["TASK-004", "TASK-016", "TASK-017"]
  },
  "working_directory": "sandbox/ethernet/Docs/Arch/",
  "ai_assist": true,
  "human_review_required": true
}
```

## 执行指令

### Arch Agent 任务分配

**当前状态**: TASK-015 协议分析初稿已完成（555行），但有大量新输入材料待整合：
- `Reference/Kimi_Agent_TC4x_Ethernet/` 下38个文件（含12个dim研究 + 完整agent分析）

**需要你完成的工作**:

1. **细化 protocol_analysis.md**:
   - 阅读 `Kimi_Agent_TC4x_Ethernet/` 下的研究材料
   - 补充协议细节（特别是TSN协议间交互机制）
   - 修正竞品对比数据（用dim研究中的交叉验证结果）
   - 使协议依赖关系精确到"哪个模块实现哪个协议的哪个子集"

2. **填充 Arch Spec (`ethernet_arch_spec.md`)**:
   - 替换模板占位符（`__PROJECT_NAME__` → `ethernet`）
   - 包含协议分析章节（引用/整合 protocol_analysis.md）
   - 定义模块架构（MAC Core / MTL / DMA / PHY / Security）
   - 定义数据通路和控制通路
   - ASIL-B 安全架构（ECC/Parity/Timeout）

3. **填充 Interface Spec (`ethernet_interface_spec.md`)**:
   - 系统接口（AXI Master/Slave）
   - PHY接口（RGMII/SGMII/MII/RMII）
   - CSR寄存器接口定义
   - 时钟/复位接口（与Clock/Reset Spec交叉引用）
   - PPS/时间同步接口

4. **填充 Clock/Reset Spec (`ethernet_clock_reset_spec.md`)**:
   - 时钟域划分（clk_sys / clk_mac / clk_tx_phy / clk_rx_phy / clk_ts）
   - CDC策略（异步FIFO/握手/同步器）
   - 复位策略（全局复位/模块级复位/软复位）
   - 时钟门控（EEE模式）

### 优先级顺序

```
protocol_analysis.md 细化
    ↓
ethernet_arch_spec.md
    ↓
ethernet_interface_spec.md
    ↓
ethernet_clock_reset_spec.md
```

### 交付要求

- 所有文档必须是**可评审状态**，不是骨架
- protocol_analysis.md 作为 Arch Spec 的**参考附录**（不要求冻结，持续更新）
- 三个 Spec 文档必须**互相关联**，接口定义在 Interface Spec 中细化，时钟域在 Clock/Reset Spec 中细化

---

*更新: 2026-05-11 | 状态: ASSIGNED → Arch Agent*
