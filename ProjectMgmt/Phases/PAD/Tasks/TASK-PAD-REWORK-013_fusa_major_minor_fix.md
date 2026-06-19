```json
{
  "task_id": "TASK-PAD-REWORK-013",
  "owner": "**FuSa_Agent** (已分配)",
  "status": "COMPLETED",
  "priority": "P1",
  "phase": "PAD 补完 / EDR 入口",
  "dependencies": [],
  "blockers": [
    "EDR 启动"
  ],
  "progress": 100,
  "acceptance_criteria": [
    {
      "item": "SG-ETH-07 定义，PHC 有 ECC/Parity 保护方案",
      "completed": true
    },
    {
      "item": "DC 计算方法文档化，每种机制有验证策略",
      "completed": true
    },
    {
      "item": "ASIL 分解有独立性分析和 CCF 评估",
      "completed": true
    },
    {
      "item": "FHTI 有 WCA 支撑，Switch/PTP FHTI 已定义",
      "completed": true
    },
    {
      "item": "降级模式位宽明确，Switch 有端口级降级策略",
      "completed": true
    },
    {
      "item": "Safety/ECC 面积参数化",
      "completed": true
    },
    {
      "item": "Lockstep 声明一致",
      "completed": true
    },
    {
      "item": "安全 CSR 在 Arch Spec 地址映射中",
      "completed": true
    },
    {
      "item": "半双工安全冲突有分析结论",
      "completed": true
    }
  ],
  "deliverables": [],
  "created_at": ""
}
```

---

## 背景

实体 Yang 选定 27 个 Major/Minor issue 需要修改。FuSa Agent 负责其中 9 个（8 Major + 1 Minor）。

## 交付物

### FUSA-PAD-002: PHC 故障模式 + ECC 保护
**修复**:
- 在 `safety_concept.md` 新增 **SG-ETH-07**: "防止 PHC 计数器故障导致 gPTP 同步精度退化"
- 定义 PHC 计数器 **ECC/Parity 保护**: 64-bit PHC → **8-bit SECDED ECC** 或 **偶校验 + 溢出检测**
- 定义 Crossbar 错误绑定的故障检测机制

### FUSA-PAD-003: DC 量化计算方法
**修复**:
- 在 `safety_concept.md` §3.2 补充每种安全机制的 **DC 计算方法**:
  - ECC: 故障注入仿真覆盖率 → ≥99%
  - FSM Parity: 形式验证非法状态可达性分析 → ≥90%
  - Clock Monitor: 频率跳变/毛刺 UVM 测试 → ≥99%/≥90%
  - Timeout: 总线屏蔽/仲裁饥饿 UVM 测试 → ≥95%
  - CSR Write-Once: 寄存器写入序列 UVM 测试 → ≥95%
- 新建 `Docs/FuSa/dc_quantification_method.md` 详细说明

### FUSA-PAD-004: ASIL 分解独立性分析
**修复**:
- 在 `safety_concept.md` §5.4 新增 **"ASIL 分解依据"**:
  - 分解策略: ASIL-D → ASIL-B(D) + ASIL-D(D)
  - **独立性要求**: 分解元素间满足独立性等级 D（无共因失效路径）
  - **共存分析**: IP 内 ECC/Parity/Timeout 与 SoC Lockstep/SMU 的共存关系
  - **CCF 分析**: SMU_ALERT[3:0] 接口作为分解边界的 CCF 评估

### FUSA-PAD-005: FHTI WCA + Switch/PTP FHTI
**修复**:
- 补充 **最坏情况分析 (WCA)** 说明 SG-ETH-02/03 典型/最坏差距来源
- 新增 **Switch Core 转发超时 FHTI**: FDB 查表阻塞 + Crossbar 仲裁饥饿场景
- 新增 **PTP 时间同步错误 FHTI**: PHC 计数器跳变 → gPTP 偏移容限

### FUSA-PAD-006: 降级模式粒度
**修复**:
- 明确 `SAFETY_DEGRADED_MASK` 位宽: **32-bit** (覆盖 DMA 通道) + **8-bit** (MAC/PHY) → 或分开两个寄存器
- 定义 **Switch 级降级策略**: 端口级降级（仅关闭故障端口）vs 模块级降级（整个 Switch SAFE_STATE）
- 定义 **DEGRADED→NORMAL 软件确认**: EcuM 确认流程或软件写清除机制

### FUSA-PAD-007: Safety/ECC 面积公式修正
**修复**:
- 将 Safety/ECC "固定 15kGE" 改为 **参数化公式**: `15kGE + 2kGE × (MAC_COUNT - 1)` 或等效
- 明确不同 `MAC_COUNT` 配置下的绝对门数

### FUSA-PAD-008: Lockstep 声明统一
**修复**:
- Arch Spec §8.1 "Lockstep (可选)" → 统一为 **"IP 内部不内嵌 Lockstep，SoC 级可选提供"**
- Safety Concept §5.3 同步更新，消除矛盾

### FUSA-PAD-009: 安全 CSR 地址纳入 Arch Spec
**修复**:
- 将 `SAFETY_STATE` (0x700) ~ `SAFETY_BIST_CTRL` (0x718) 纳入 Arch Spec §1.4.5 **"安全 CSR 地址空间"**
- 定义每个寄存器的访问权限 (RO/RW/Write-Once)

### FUSA-PAD-011: 半双工与 TSN 确定性冲突
**修复**:
- 分析 `PHY_x_DUPLEX=0` (半双工) 时 CSMA/CD 碰撞退避对 SG-ETH-02 (TSN 确定性) 的影响
- 结论: 半双工模式下 **TSN 确定性降级**，建议在安全关键应用中禁用半双工或降低 ASIL 声明
- 在 `safety_concept.md` §1.1 增加半双工安全策略说明

## 验收标准

- [x] SG-ETH-07 定义，PHC 有 ECC/Parity 保护方案
- [x] DC 计算方法文档化，每种机制有验证策略
- [x] ASIL 分解有独立性分析和 CCF 评估
- [x] FHTI 有 WCA 支撑，Switch/PTP FHTI 已定义
- [x] 降级模式位宽明确，Switch 有端口级降级策略
- [x] Safety/ECC 面积参数化
- [x] Lockstep 声明一致
- [x] 安全 CSR 在 Arch Spec 地址映射中
- [x] 半双工安全冲突有分析结论

完成后执行 `git add -A && git commit -m "FuSa: PAD-002~009 + PAD-011 修复 (PAD-REWORK-013)"`
