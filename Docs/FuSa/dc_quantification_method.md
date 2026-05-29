# DC 量化计算方法

> **文档类型**: Diagnostic Coverage Quantification Methodology
> **版本**: v1.0
> **日期**: 2026-05-29
> **作者**: FuSa Agent
> **对应**: `Docs/FuSa/safety_concept.md` §3.2a

---

## 1. 概述

本文档定义 `Docs/FuSa/safety_concept.md` 中每种安全机制的 **诊断覆盖等级 (Diagnostic Coverage, DC)** 量化计算方法，遵循 ISO 26262-5:2018 Table D 要求。

**适用范围**: 所有 ASIL-B/C/D 安全目标 (SG-ETH-01~14) 对应的安全机制 DC 计算与验证。

---

## 2. DC 通用计算公式

### 2.1 故障注入法 (Fault Injection)

```
DC_fault_injection = (检测到的故障数 / 注入的故障总数) × 100%
```

**采样要求**:
- 每种故障模式 ≥1000 次独立注入
- 覆盖所有寄存器/存储器 bit 位置
- 覆盖所有时钟域和工作温度 corner

### 2.2 形式验证法 (Formal Verification)

```
DC_formal = (已验证属性数 / 总属性数) × 100%
```

**覆盖要求**:
- 所有状态空间可达性已证明
- 所有非法状态/转换已排除
- 100% 状态空间覆盖视为 DC = 100%

---

## 3. 安全机制 DC 计算方法详述

### 3.1 ECC (SECDED)

| 项目 | 内容 |
|------|------|
| **DC 目标** | 99% (单 bit 纠正: 100%, 双 bit 检测: 100%) |
| **计算方法** | 故障注入 |
| **注入方法** | 强制单/双 bit 翻转 → 统计纠正/检测率 |
| **验证环境** | UVM + VCS/Xcelium |
| **覆盖率指标** | 单 bit 100% 纠正 / 双 bit 100% 检测 |
| **最小注入次数** | ≥1000 次/存储器实例 |
| **corner 覆盖** | SS/TT/FF, -40°C~125°C, 1.08V~1.32V |

**故障注入流程**:
1. 正常工作时注入单 bit 错误到 FIFO/描述符/Bridge 表
2. 监测 ECC 纠正信号和错误计数器
3. 注入双 bit 错误，监测 SMU 报警和状态切换
4. 统计: `DC = 纠正或检测次数 / 总注入次数`

### 3.2 FSM Parity

| 项目 | 内容 |
|------|------|
| **DC 目标** | 90% |
| **计算方法** | 形式验证 + 故障注入 |
| **验证环境** | JasperGold/VC Formal + UVM |
| **覆盖率指标** | 所有非法状态编码 100% 检测 |

**形式验证属性**:
```systemverilog
assert property (@(posedge clk) disable iff (!rst_n)
    (fsm_state != LEGAL_STATE[0]) && (fsm_state != LEGAL_STATE[1]) && ...
    |-> ##1 parity_error);
```

**故障注入**: 强制篡改状态编码，统计 Parity 检测率。

### 3.3 Timeout (DMA/CSR/Bus)

| 项目 | 内容 |
|------|------|
| **DC 目标** | 95% |
| **计算方法** | 故障注入 |
| **注入方法** | 屏蔽响应信号/挂起总线 → 统计超时触发率 |
| **验证环境** | UVM + 断言检查 |
| **覆盖率指标** | 100% 超时场景触发 |

**测试场景**:
- AXI 无响应 (AR/AW/R/B 通道挂起)
- DMA 描述符读取超时
- CSR 访问超时
- 各 corner 下超时阈值漂移验证

### 3.4 Clock Monitor

| 项目 | 内容 |
|------|------|
| **DC 目标** | 99% |
| **计算方法** | 故障注入 |
| **注入方法** | 修改分频比/注入毛刺 → 统计频率偏移检测率 |
| **验证环境** | UVM + 频率计数器模型 |
| **覆盖率指标** | 100% 超阈值漂移检测 |

**测试场景**:
- PLL 失锁 (+/- 20% 频率偏移)
- 时钟毛刺 (宽度 < 1ns)
- 备用 PLL 切换延迟

### 3.5 CSR Write-Once Lock

| 项目 | 内容 |
|------|------|
| **DC 目标** | 95% |
| **计算方法** | 形式验证 |
| **验证环境** | JasperGold/VC Formal |
| **覆盖率指标** | 100% 锁存后写入拒绝 |

**形式验证属性**:
```systemverilog
assert property (@(posedge clk)
    (lock_bit == 1'b1) && (write_en == 1'b1)
    |-> (write_rejected));
```

### 3.6 配置互锁检测

| 项目 | 内容 |
|------|------|
| **DC 目标** | 95% |
| **计算方法** | 形式验证 |
| **验证环境** | JasperGold/VC Formal |
| **覆盖率指标** | 100% 非法组合拒绝 |

**验证方法**: 遍历所有参数组合 (EEE×TSN, TSN×半双工, PHC_COUNT<2×VPHC)，确认非法组合均被硬件拒绝。

### 3.7 PHC 计数器 ECC/Parity

| 项目 | 内容 |
|------|------|
| **DC 目标** | 95% (单 bit: 100%, 溢出: 100%) |
| **计算方法** | 故障注入 |
| **注入方法** | 强制 PHC 计数器 bit 翻转/Addend 溢出 → 统计检测/纠正率 |
| **验证环境** | UVM + PTP 时间戳模型 |
| **覆盖率指标** | 单 bit 100% 纠正 / 溢出 100% 检测 |

**测试场景**:
- PHC 64-bit 计数器各 byte 单 bit 翻转
- Addend 寄存器溢出 (0xFFFFFFFF → 0x00000000)
- Crossbar 映射一致性校验失败

### 3.8 Crossbar 错误绑定检测

| 项目 | 内容 |
|------|------|
| **DC 目标** | 90% |
| **计算方法** | 形式验证 |
| **验证环境** | JasperGold/VC Formal |
| **覆盖率指标** | 100% 非法绑定检测 |

**形式验证属性**:
```systemverilog
assert property (@(posedge clk)
    (port_mac_mapping != VALID_MAP[port])
    |-> ##1 binding_error);
```

### 3.9 RX Filter ECC + DMA 隔离

| 项目 | 内容 |
|------|------|
| **DC 目标** | 99% |
| **计算方法** | 故障注入 |
| **注入方法** | 强制 Filter 表/DMA 映射 bit 翻转 → 统计检测率 |
| **验证环境** | UVM + 流识别模型 |
| **覆盖率指标** | 100% 非法流/映射检测 |

### 3.10 PHC 交叉漂移监控

| 项目 | 内容 |
|------|------|
| **DC 目标** | 95% |
| **计算方法** | 故障注入 |
| **注入方法** | 注入相位/频率偏移 → 统计漂移检测率 |
| **验证环境** | UVM + 时间基准模型 |
| **覆盖率指标** | 100% 超阈值漂移检测 |

### 3.11 VM ID Parity + IO Ring 边界

| 项目 | 内容 |
|------|------|
| **DC 目标** | 90% |
| **计算方法** | 故障注入 |
| **注入方法** | 篡改 VM ID / 越界访问 → 统计检测率 |
| **验证环境** | UVM + Xen IO Ring 模型 |
| **覆盖率指标** | 100% 非法 VM ID / 越界检测 |

---

## 4. DC 汇总表

| 安全机制 | DC 目标 | 计算方法 | 验证手段 | 工具/环境 | 覆盖率指标 |
|----------|---------|----------|----------|-----------|------------|
| **ECC (SECDED)** | 99% | 故障注入 | 存储器故障注入仿真 | UVM + VCS/Xcelium | 单 bit 100% 纠正 / 双 bit 100% 检测 |
| **FSM Parity** | 90% | 形式验证 + 故障注入 | 形式属性检查 (SVA) | JasperGold/VC Formal | 所有非法状态编码 100% 检测 |
| **Timeout** | 95% | 故障注入 | 总线/DMA 故障注入 | UVM + 断言检查 | 100% 超时场景触发 |
| **Clock Monitor** | 99% | 故障注入 | 时钟故障注入 | UVM + 频率计数器模型 | 100% 超阈值漂移检测 |
| **CSR Write-Once Lock** | 95% | 形式验证 | 寄存器访问属性检查 | JasperGold/VC Formal | 100% 锁存后写入拒绝 |
| **配置互锁检测** | 95% | 形式验证 | 参数组合属性检查 | JasperGold/VC Formal | 100% 非法组合拒绝 |
| **PHC 计数器 ECC/Parity** | 95% | 故障注入 | PHC 寄存器故障注入 | UVM + PTP 时间戳模型 | 单 bit 100% 纠正 / 溢出 100% 检测 |
| **Crossbar 错误绑定检测** | 90% | 形式验证 | Crossbar 映射属性检查 | JasperGold/VC Formal | 100% 非法绑定检测 |
| **RX Filter ECC + DMA 隔离** | 99% | 故障注入 | AVTP 流故障注入 | UVM + 流识别模型 | 100% 非法流/映射检测 |
| **PHC 交叉漂移监控** | 95% | 故障注入 | 双 PHC 比较故障注入 | UVM + 时间基准模型 | 100% 超阈值漂移检测 |
| **VM ID Parity + IO Ring 边界** | 90% | 故障注入 | 虚拟化故障注入 | UVM + Xen IO Ring 模型 | 100% 非法 VM ID / 越界检测 |

---

## 5. 验证入口要求

### 5.1 故障注入最小样本量

| 安全机制 | 最小注入次数 | 故障模式覆盖 | Corner 覆盖 |
|----------|-------------|-------------|-------------|
| ECC | 1000 次/实例 | 单 bit, 双 bit, 多 bit | SS/TT/FF, 全温度 |
| FSM Parity | 1000 次/状态机 | 单 bit 翻转, 非法跳转 | 全状态编码 |
| Timeout | 500 次/通道 | 无响应, 延迟响应, 部分响应 | 全频率 corner |
| Clock Monitor | 500 次 | 失锁, 漂移, 毛刺 | 全电压 corner |
| Write-Once Lock | 形式验证 (全覆盖) | 锁存后写入, 非法解锁 | 不适用 |
| 配置互锁 | 形式验证 (全覆盖) | 所有非法组合 | 不适用 |
| PHC ECC | 500 次/PHC | 计数器翻转, Addend 溢出 | 全温度 corner |
| Crossbar | 形式验证 (全覆盖) | 所有非法绑定 | 不适用 |

### 5.2 形式验证属性完备性

- **状态空间覆盖**: ≥100% (所有可达状态已证明)
- **转换覆盖**: 所有状态转换已验证
- **边界条件**: 所有 corner case 已覆盖

---

## 6. 参考文献

1. ISO 26262-5:2018, Table D — Diagnostic coverage of each safety mechanism
2. Infineon AURIX TC4x Safety Manual, Section 4.2 — SECDED ECC coverage
3. Mentor Graphics Questa Formal / Synopsys VC Formal User Guide — Property checking methodology
4. UVM 1.2 Reference Manual — Fault injection testbench architecture

---

> **版本历史**
> | 版本 | 日期 | 作者 | 变更说明 |
> |------|------|------|----------|
> | v1.0 | 2026-05-29 | FuSa Agent | 初始版本：覆盖所有 SG-ETH-01~14 安全机制的 DC 量化计算方法 |
