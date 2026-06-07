```json
{
  "task_id": "TASK-PAD-REWORK-011",
  "owner": "**Arch_Agent** (已分配)",
  "status": "COMPLETED",
  "priority": "P1",
  "phase": "PAD 补完 / EDR 入口",
  "dependencies": [],
  "blockers": [],
  "progress": 100,
  "acceptance_criteria": [
    {
      "item": "§10.2 语义三级定义清晰，MACsec/AVTP 已修正",
      "completed": true
    },
    {
      "item": "§8.1 P0 升级项有需求追溯或已降级",
      "completed": true
    },
    {
      "item": "§6.1 含 GETH_AI.028/030 独立条目，总数 15",
      "completed": true
    },
    {
      "item": "§2.1 DMA 通道标注泛化",
      "completed": true
    },
    {
      "item": "§6.2.6 BC 模式消除固定成对误解",
      "completed": true
    },
    {
      "item": "§1.4.4 门数估算有 §4.3 引用",
      "completed": true
    },
    {
      "item": "§1.4.1 含 SUPPORT_SRP/SUPPORT_PFC",
      "completed": true
    },
    {
      "item": "802.1Qbu RTL Complexity 有评估结论",
      "completed": true
    }
  ],
  "deliverables": [],
  "created_at": ""
}
```

---

## 背景

实体 Yang 选定 27 个 Major/Minor issue 需要修改。Arch Agent 负责其中 8 个（3 Major + 5 Minor）。

## 交付物

### Major 修复

#### Arch-M-1: 并集决策语义统一
**位置**: `ethernet_arch_spec.md` §10.2
**问题**: MACsec 标 "Yes" 但 `SUPPORT_MACSEC=0`；AVTP 标 "Yes" 但默认 1；"Yes" vs "Configurable" 语义混乱
**修复**:
- 统一 §10.2 列语义: **Yes**=默认开启, **Configurable**=默认关闭需显式使能, **No**=不支持
- MACsec: "Yes" → **"Configurable"**
- AVTP: "Yes" → **"Configurable (默认1，TC4x/R-Car 推荐开启)"**
- 同步 §1.4.1 参数默认值与 §10.2 一致

#### Arch-M-2: P0 升级需求追溯
**位置**: `protocol_analysis.md` §8.1
**问题**: 802.1Qbu/Qci/Qcb 从 Optional → P0 无 SoC 需求文档支撑
**修复**:
- 每项升级后追加追溯引用: `→ 追溯: SoC_Requirements.md §X.X` 或 `Safety_Requirements.md §Y.Y`
- 若需求文档无对应条目，**降级回 P1** 并标注 "待需求确认"

#### Arch-M-3: Erratum 表补充 GETH_AI.028/030
**位置**: `ethernet_arch_spec.md` §6.1 / §6.2.10
**问题**: §6.2.7 提到 GETH_AI.028/030 但 §6.1 表无独立条目；§6.2.10 无 errata ID
**修复**:
- §6.1 补充 **GETH_AI.028** 和 **GETH_AI.030** 独立条目（root cause + 规避方案）
- §6.2.10 明确标注 "新增约束 (PHY 选型 check item，非 erratum 规避)" 或对应 errata ID
- 更新 erratum 总数 13 → **15**

### Minor 修复

#### Arch-m-1: DMA 通道框图泛化
**位置**: `ethernet_arch_spec.md` §2.1
**修复**: "CH[0:7]" → **"CH[0:N-1] (N = DMA_CH_COUNT)"** 或增加注释 "图示为 8 通道示例"

#### Arch-m-2: BC 模式描述消除固定成对误解
**位置**: `ethernet_arch_spec.md` §6.2.6
**修复**: "Port 0,1 → PHC0" → **"Port 0,1 可绑定 PHC0（支持任意 per-port 组合）"**

#### Arch-m-3: 门数估算列增加 §4.3 引用
**位置**: `ethernet_arch_spec.md` §1.4.4
**修复**: 表格脚注增加 **"估算依据见 §4.3 资源估算"**

#### Arch-m-4: SRP/PFC 显式参数声明
**位置**: `ethernet_arch_spec.md` §1.4.1 / §10.3
**修复**: 全局参数表追加:
- `SUPPORT_SRP`: bit, 0, 0/1, "802.1Q SRP (默认关闭，车载使用静态 TAS)"
- `SUPPORT_PFC`: bit, 0, 0/1, "802.3bd PFC (默认关闭，CBS+TAS 替代)"

#### Arch-m-5: 802.1Qbu RTL Complexity 评估
**位置**: `protocol_analysis.md` §1.1
**修复**: 若确认 802.1Qbu 实际复杂度低于 TAS → **High → Medium**；附评估依据

## 验收标准

- [ ] §10.2 语义三级定义清晰，MACsec/AVTP 已修正
- [ ] §8.1 P0 升级项有需求追溯或已降级
- [ ] §6.1 含 GETH_AI.028/030 独立条目，总数 15
- [ ] §2.1 DMA 通道标注泛化
- [ ] §6.2.6 BC 模式消除固定成对误解
- [ ] §1.4.4 门数估算有 §4.3 引用
- [ ] §1.4.1 含 SUPPORT_SRP/SUPPORT_PFC
- [ ] 802.1Qbu RTL Complexity 有评估结论

完成后执行 `git add -A && git commit -m "Arch: M-1,2,3 + m-1~5 修复 (PAD-REWORK-011)"`
