# TASK-010: Verification Environment

```json
{
  "task_id": "TASK-010",
  "project_id": "IP_20260502_001",
  "phase": "IDR",
  "task_type": "verification",
  "priority": "P0",
  "status": "PENDING",
  "assigned_to": "Verification_Coding_Agent",
  "assigned_by": "PM_Agent",
  "deadline": "TBD",
  "title": "搭建验证环境",
  "requirements": "搭建UVM和非UVM环境，编写testcase",
  "acceptance_criteria": [
    "UVM环境可编译",
    "非UVM环境可运行",
    "所有testcase可执行",
    "代码覆盖率>90%"
  ],
  "deliverables": {
    "files": [
      "Verification/Env/tb_top.sv",
      "Verification/Env/uvm/ethernet_uvm_pkg.sv",
      "Verification/Testcases/directed/*.sv",
      "Verification/Testcases/random/*.sv"
    ]
  },
  "working_directory": "sandbox/ethernet/Verification/",
  "commands": [
    "make sim",
    "make coverage"
  ],
  "ai_assist": true,
  "human_review_required": true
}
```
