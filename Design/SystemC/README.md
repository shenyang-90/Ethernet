# Ethernet IP SystemC/TLM 2.0 Modeling

> **项目**: ethernet (IP_20260502_001)
> **阶段**: PAD
> **目标**: 在架构冻结前提供系统级性能与功能评估

---

## 目录结构

```
Design/SystemC/
├── models/              # TLM 2.0 模块模型
│   ├── tlm_ethernet_top.h
│   ├── tlm_switch_core.h
│   ├── tlm_mac.h
│   ├── tlm_phc.h
│   └── tlm_vphc.h
├── tests/               # 测试平台
│   ├── base_test.h
│   ├── throughput_test.cc
│   └── latency_test.cc
├── utils/               # 工具组件
│   ├── statistics.h
│   └── trace_helper.h
├── Makefile
└── README.md
```

---

## 环境要求

- SystemC 2.3.3
- TLM 2.0 (随 SystemC 发布)
- g++ 支持 C++17

设置环境变量：

```bash
export SYSTEMC_HOME=/path/to/systemc-2.3.3
export LD_LIBRARY_PATH=$SYSTEMC_HOME/lib-linux64:$LD_LIBRARY_PATH
```

---

## 构建

```bash
cd Design/SystemC
make          # 编译所有测试
make run      # 运行默认测试
make clean    # 清理
```

---

## 说明

当前为 PAD 阶段骨架代码，仅包含模块封装与接口定义，完整实现见 TASK-PAD-SC-002/003。

---

*创建: 2026-05-18 | 维护: Arch Agent / Design Agent*
