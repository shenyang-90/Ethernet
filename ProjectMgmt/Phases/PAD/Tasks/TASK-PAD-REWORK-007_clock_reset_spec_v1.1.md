```json
{
  "task_id": "TASK-PAD-REWORK-007",
  "owner": "Arch_Agent",
  "status": "COMPLETED",
  "priority": "P1",
  "phase": "PAD (补完)",
  "dependencies": [],
  "blockers": [
    "TASK-004 (EDR)"
  ],
  "progress": 100,
  "acceptance_criteria": [
    {
      "item": "6 个时钟域均有典型频率值 (非仅范围)",
      "completed": true
    },
    {
      "item": "半双工 CRS/CD 时钟域独立定义",
      "completed": true
    },
    {
      "item": "EEE 时钟门控策略完整",
      "completed": true
    },
    {
      "item": "复位释放序列有参数化计数器方案",
      "completed": true
    }
  ],
  "deliverables": [],
  "created_at": "2026-05-21"
}
```

---

## 背景

PM-001: Clock-Reset Spec v1.0 滞后，新增 PHY_x_DUPLEX (CRS 时钟域)、EEE 时钟门控、5G USXGMII 625MHz 时钟树等未反映。
RTL-MAJ-001: 所有时钟域均为频率范围，无典型目标频率。

## 交付物

1. **更新 `Docs/Arch/ethernet_clock_reset_spec.md` → v1.1**:
   - 定义典型目标频率: `clk_sys=200MHz`, `clk_mac=250MHz`, `clk_ts=250MHz`
   - `clk_tx_phy` / `clk_rx_phy` 按速率分档 (10M/100M/1G/2.5G/5G/10G)
   - 新增 CRS/CD 信号时钟域 (半双工模式，由 PHY 提供)
   - EEE LPI 时钟门控策略 (MAC 侧时钟关闭/恢复序列)
   - PLCA 参考时钟定义 (80ns 周期 = 12.5MHz? 确认)
   - 复位释放计数器实现 (100μs 延时 → 计数器位宽按 `clk_sys` 频率参数化)

## 验收标准

- [x] 6 个时钟域均有典型频率值 (非仅范围)
- [x] 半双工 CRS/CD 时钟域独立定义
- [x] EEE 时钟门控策略完整
- [x] 复位释放序列有参数化计数器方案

---

*创建时间: 2026-05-21 | 创建人: AI Yang*
