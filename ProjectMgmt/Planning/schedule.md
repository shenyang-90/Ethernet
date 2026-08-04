# 项目排期: ethernet

## WBS (工作分解结构)

ethernet
- PAD Phase (2026-05-11 ~ 2026-05-25)
  - 协议分析文档      [Arch Agent]    05/11-05/13
  - Arch Spec        [Arch Agent]    05/13-05/18
  - Interface Spec   [Arch Agent]    05/16-05/20
  - Clock/Reset Spec [Arch Agent]    05/18-05/20
  - SystemC/TLM 建模计划 [Arch Agent] 05/18-05/19
  - TLM 平台代码开发  [Design Agent]  05/19-05/22
  - SystemC 建模报告  [Arch/Design]   05/22-05/24
  - 微架构设计        [Design Agent]  05/20-05/25
  - PAD Review       [AI Yang]       05/25
- EDR Phase (2026-05-26 ~ 2026-06-15)
  - Design Spec      [Design Agent]
  - Verification Plan [Verification Agent]
  - DFT Spec         [DFT Agent]
  - FuSa Concept     [FuSa Agent]
- IDR Phase (2026-06-16 ~ 2026-08-15)
  - RTL Coding       [Design_Coding_Agent]
  - UVM Env          [Verification_Coding_Agent]
  - Testcases        [Verification_Coding_Agent]
  - Coverage         [Verification_Coding_Agent]
- FDR Phase (2026-08-16 ~ 2026-09-30)
  - Synthesis        [Flow Agent]
  - DFT Insertion    [Flow Agent]
  - PR               [Flow Agent]
  - STA Sign-off     [Flow Agent]

## 甘特图

| 任务 | W1 (5/11-17) | W2 (5/18-24) | W3 (5/25-31) | W4 | W5 | W6 | W7 | W8 |
|------|-------------|-------------|-------------|-----|-----|-----|-----|-----|
| PAD  | ████████░░░ | ░░░░░░░░░░░ | ░░░░░░░░░░░ |     |     |     |     |     |
| 协议分析 | ███░░░░░░░░ |             |             |     |     |     |     |     |
| Arch Spec | ░░░████░░░░ | █░░░░░░░░░░ |             |     |     |     |     |     |
| 微架构    |             |             | █████░░░░░░ |     |     |     |     |     |
| EDR  |             |             |             | ███ | ███ |     |     |     |
| IDR  |             |             |             |     |     | ███ | ███ | ███ |
| FDR  |             |             |             |     |     |     |     |     | ███

图例: █ = 任务执行期  ░ = 等待/缓冲期

## 关键路径

```
协议分析 (TASK-015)
    ↓
Arch Spec (TASK-003) — 含 Interface Spec + Clock/Reset Spec
    ↓
SystemC/TLM 建模 (TASK-PAD-SC-001~003) — 建模计划/平台/报告
    ↓
微架构设计 (TASK-004)
    ↓
PAD Review (TASK-PAD-REV)
```

---

*更新: 2026-05-11*  
*更新: 2026-07-30 — SystemC/TLM 建模完成：单元测试 77/77，集成测试 10/10，系统测试 5/5 全部通过*
