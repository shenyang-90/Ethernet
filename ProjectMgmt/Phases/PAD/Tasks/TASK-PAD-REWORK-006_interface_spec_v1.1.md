# TASK-PAD-REWORK-006: Interface Spec v1.1 升级

**任务ID**: TASK-PAD-REWORK-006
**负责人**: Arch_Agent
**状态**: PENDING
**优先级**: P1
**所属阶段**: PAD (补完)
**前置依赖**: 无
**下游阻塞**: TASK-004 (EDR)

---

## 背景

PM-001/Arch-m1: Interface Spec v1.0 自 5-11 后未更新，Arch Spec 已迭代 8 次重大修订。
新增参数未反映: `PHY_x_DUPLEX`, `SUPPORT_EEE`, `SUPPORT_IPSEC/SECOC/DTLS`, Security IF 信号。

## 交付物

1. **更新 `Docs/Arch/ethernet_interface_spec.md` → v1.1**:
   - 新增 Security IF 信号定义 (IPsec/SecOC/D-TLS 封装/卸载接口)
   - 新增 EEE LPI 控制信号 (MAC ↔ PHY 低功耗握手)
   - 新增半双工信号 (CRS, COL for 10M/100M)
   - 更新 AXI4/AXI4-Lite 接口定义 (outstanding, QoS, ID 分配)
   - 补充 vPHC 硬件接口信号 (若 TASK-PAD-REWORK-003 先完成则引用)

## 验收标准

- [ ] 所有 Arch Spec v1.8c 中的接口信号在 Interface Spec 中有定义
- [ ] 时序约束 (setup/hold, valid-ready 握手) 至少定义典型值
- [ ] 版本历史更新，列出 v1.0→v1.1 的所有变更

---

*创建时间: 2026-05-21 | 创建人: AI Yang*
