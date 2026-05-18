# Verification Plan Template

> **项目**: __PROJECT_NAME__
> **模块/系统**: __MODULE_NAME__
> **版本**: v0.1
> **日期**: YYYY-MM-DD
> **作者**: __AUTHOR__

---

## 1. Verification Scope
### 1.1 验证范围
[描述验证覆盖的范围]

### 1.2 不在本计划内的
[明确排除的范围]

---

## 2. Verification Strategy
### 2.1 验证方法
| 方法 | 应用范围 | 工具 |
|------|---------|------|
| UVM仿真 | 主要功能 | VCS/Verilator |
| 形式验证 | 关键协议 | JasperGold |

### 2.2 测试层次
| 层次 | 目标 | 环境 |
|------|------|------|
| UT | 模块功能 | IP级UVM |
| IT | 子系统 | 子系统UVM |

---

## 3. Testbench Architecture
### 3.1 架构图
### 3.2 Agent列表
| Agent | 协议 | 功能 |
|-------|------|------|
| | | |

---

## 4. Coverage Plan
### 4.1 代码覆盖目标
| 类型 | 目标 | 说明 |
|------|------|------|
| Line | >90% | |
| Condition | >90% | |
| FSM | >95% | |
| Toggle | >90% | |

---

## 5. Testcase List
### 5.1 冒烟测试
### 5.2 功能测试
### 5.3 边界测试
### 5.4 随机测试

---

## 6. Regression Plan
### 6.1 回归策略
### 6.2 回归频率

---

## 7. Sign-off Criteria
### 7.1 覆盖率
### 7.2 Bug状态
### 7.3 回归稳定性

*模板: workflow/templates/docs/verification_plan.md*
