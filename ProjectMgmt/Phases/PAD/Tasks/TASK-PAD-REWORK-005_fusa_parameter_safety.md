# TASK-PAD-REWORK-005: 新增参数安全影响评估 (FuSa 补完)

**任务ID**: TASK-PAD-REWORK-005
**负责人**: FuSa_Agent
**状态**: ✅ **COMPLETED**
**优先级**: P0
**所属阶段**: PAD (补完)
**前置依赖**: 无
**下游阻塞**: TASK-008 (EDR Safety Analysis)

---

## 背景

FUSA-PAD-001 (Critical): Arch Spec v1.8c 新增 7 项参数的安全影响完全未在 Safety Concept 中评估:
- `SUPPORT_EEE` — EEE LPI 唤醒延迟 vs FHTI
- `SUPPORT_IPSEC` — 外部 CSS 加速器接口故障导致 PDU 解密失败
- `SUPPORT_SECOC` — SecOC PDU 认证失败安全响应
- `SUPPORT_DTLS` — D/TLS 管理通道故障 (Minor 影响)
- `PHY_x_DUPLEX` — 半双工 CSMA/CD 碰撞退避破坏 TSN 确定性
- `SUPPORT_AVTP` / `SUPPORT_AVTP_CTL` — AVTP 流识别 (Minor 影响)
- `PHC_COUNT=2` + `SUPPORT_VPHC` — 双 PHC 漂移 + vPHC 虚拟化隔离失效

实体 Yang 决策: **立即启动**。

## 交付物

1. **更新 `Docs/FuSa/safety_concept.md`**:
   - 新增安全目标 SG-ETH-07 (EEE LPI 唤醒安全策略)
   - 新增安全目标 SG-ETH-08 (安全加速器接口故障)
   - 新增安全目标 SG-ETH-09 (半双工模式 TSN 确定性冲突)
   - 新增安全目标 SG-ETH-10 (PHC 漂移/vPHC 隔离)
   - 或: 证明上述参数在默认关闭状态下不引入新安全目标，仅需配置使能时的警告
   - 为每个新增参数定义: 故障模式 → 安全机制 → DC → FHTI

2. **`Docs/FuSa/parameter_safety_impact_matrix.md`** — 参数安全影响矩阵

## 验收标准

- [x] 7 项新增参数每项都有安全目标映射或 "默认关闭/无影响" 声明
- [x] 故障模式定义完整 (STUCK-AT, SEU, 时钟漂移, 接口超时等)
- [x] 安全机制与 Arch Spec 参数可配置性一致 (如 `ASIL_LEVEL=0` 时关闭)
- [x] DC 和 FHTI 数值有计算依据引用

**交付物确认**: `Docs/FuSa/parameter_safety_impact_matrix.md` v1.0 已提交 (19KB)

---

*创建时间: 2026-05-21 | 创建人: AI Yang | 完成时间: 2026-05-21 | 状态: COMPLETED*
