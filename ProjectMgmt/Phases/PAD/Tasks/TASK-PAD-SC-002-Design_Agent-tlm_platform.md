# TASK-PAD-SC-002: TLM 2.0 平台搭建与模块封装

```json
{
  "task_id": "TASK-PAD-SC-002",
  "project_id": "IP_20260502_001",
  "phase": "PAD",
  "task_type": "rtl_implementation",
  "priority": "P1",
  "status": "PENDING",
  "assigned_to": "Design_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "2026-05-22",
  "title": "TLM 2.0 平台搭建与模块封装",
  "requirements": "基于 TASK-PAD-SC-001 的建模计划，在 Design/SystemC/ 目录下搭建 SystemC 2.3.3 + TLM 2.0 建模平台，完成各子模块的 sc_module 封装、socket 连接、memory manager 与 payload pool 实现，并提供可编译的 Makefile。",
  "acceptance_criteria": [
    "Design/SystemC/ 目录结构完整（models/tests/utils）",
    "tlm_ethernet_top.h 顶层模块可编译",
    "Switch Core / MAC / PHC / vPHC 骨架头文件齐全",
    "base_test.h / throughput_test.cc / latency_test.cc 测试平台骨架完成",
    "utils/statistics.h / trace_helper.h 工具组件完成",
    "Makefile 支持 SystemC 2.3.3 + TLM 2.0，零错误编译",
    "README.md 说明目录结构与构建方法"
  ],
  "deliverables": {
    "files": [
      "Design/SystemC/models/tlm_ethernet_top.h",
      "Design/SystemC/models/tlm_switch_core.h",
      "Design/SystemC/models/tlm_mac.h",
      "Design/SystemC/models/tlm_phc.h",
      "Design/SystemC/models/tlm_vphc.h",
      "Design/SystemC/tests/base_test.h",
      "Design/SystemC/tests/throughput_test.cc",
      "Design/SystemC/tests/latency_test.cc",
      "Design/SystemC/utils/statistics.h",
      "Design/SystemC/utils/trace_helper.h",
      "Design/SystemC/Makefile",
      "Design/SystemC/README.md"
    ],
    "reports": []
  },
  "dependencies": {
    "pre_tasks": ["TASK-PAD-SC-001"],
    "blocks": ["TASK-PAD-SC-003"]
  },
  "working_directory": "sandbox/ethernet/Design/SystemC/",
  "ai_assist": true,
  "human_review_required": true
}
```

## 执行指令

### Design Agent 任务分配

**目标**: 建立可编译、可扩展的 TLM 2.0 平台骨架，为后续场景仿真（TASK-PAD-SC-003）提供基础设施。

**需要完成的工作**:

1. 创建 `Design/SystemC/` 目录结构（`models/`、`tests/`、`utils/`）
2. 封装顶层模块 `tlm_ethernet_top.h`，包含 `sc_module` 与 TLM socket 绑定
3. 创建子模块骨架头文件：
   - `tlm_switch_core.h` — Switch Core 事务级模型
   - `tlm_mac.h` — MAC 层模型
   - `tlm_phc.h` — PHC 时钟模型
   - `tlm_vphc.h` — vPHC 虚拟化模型
4. 创建测试平台骨架：
   - `base_test.h` — 测试基类
   - `throughput_test.cc` — 吞吐场景
   - `latency_test.cc` — 延迟场景
5. 创建工具组件：
   - `statistics.h` — 指标统计
   - `trace_helper.h` — 波形/日志辅助
6. 编写 Makefile（SystemC 2.3.3 + TLM 2.0，g++ -std=c++17）
7. 编写 README.md 说明目录结构与构建方法

### 交付要求

- 本阶段只要求骨架/模板，不要求完整实现
- 代码必须可编译（`make -C Design/SystemC` 零错误）
- 遵循 SystemC 2.3.3 + TLM 2.0 标准 API

---

*创建: 2026-05-18 | 状态: PENDING → Design Agent*
