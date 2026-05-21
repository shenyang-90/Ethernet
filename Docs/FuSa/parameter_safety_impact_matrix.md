# Ethernet IP 新增可配置参数安全影响矩阵

> **项目**: Ethernet IP (IP_20260502_001)  
> **文档类型**: Safety Impact Matrix (ISO 26262-3:2018 支持文档)  
> **版本**: v1.0  
> **日期**: 2026-05-21  
> **作者**: FuSa Agent  
> **变更号**: PAD-REWORK-005  
> **关联文档**: `Docs/FuSa/safety_concept.md` v1.0+ (§1.3 新增参数安全影响)

---

## 1. 参数安全影响总览

本矩阵基于 `Docs/Arch/ethernet_arch_spec.md` v1.8c §1.4.3 / §1.4.2 / §10.4 提取的 **9 项新增/变更可配置参数**，逐项执行安全影响分析。参数分为三类：

| 类别 | 参数 | 默认值 | 说明 |
|------|------|:------:|------|
| **节能/PHY 模式** | `SUPPORT_EEE` | 0 | 802.3az EEE 低功耗 PHY 模式 |
| **网络安全卸载** | `SUPPORT_IPSEC` | 0 | IPsec ESP/AH 硬件卸载接口 |
| | `SUPPORT_SECOC` | 0 | SecOC PDU 级安全认证接口 |
| | `SUPPORT_DTLS` | 0 | D/TLS Chacha20-Poly1305 接口 |
| **PHY 双工模式** | `PHY_x_DUPLEX` | 1 (全双工) | 每 PHY 双工模式 (10M/100M 有效) |
| **AVB/AVTP 流** | `SUPPORT_AVTP` | 1 | IEEE 1722 AVTP/ACF 流识别与封装 |
| | `SUPPORT_AVTP_CTL` | 0 | IEEE 1722.1 AVTP 控制/路由表 |
| **PTP 虚拟化** | `PHC_COUNT` | 2 | PTP Hardware Clock 数量 |
| | `SUPPORT_VPHC` | 0 | vPHC 虚拟化 (依赖 PHC_COUNT=2) |

> **注**: 验收标准中的 "7 项" 按任务书原始分组计数（EEE/PHY/AVTP/AVTP_CTL/Security 三合一/PHC+VPHC 二合一）。本矩阵按实际 9 个独立参数展开，确保每个参数均有独立安全目标映射。

---

## 2. 安全影响矩阵 (参数级)

### 2.1 节能与 PHY 模式参数

| 参数名 | 默认值 | 故障模式 | 受影响安全目标 | 安全机制 | DC 目标 | FHTI | 备注 |
|--------|:------:|----------|:------------:|----------|:-------:|:----:|------|
| `SUPPORT_EEE` | 0 (关闭) | **STUCK-AT 1**: EEE 意外启用，LPI 状态非法进入 | SG-ETH-02 (TSN 确定性) | ① CSR Write-Once Lock ② EEE 使能位 Parity ③ LPI 状态机独立 Parity | 95% | < 10 μs | 默认关闭且无 PHY 配合时无功能影响；**启用后** LPI 唤醒延迟可能破坏 TAS 门控周期 |
| `SUPPORT_EEE` | 0 (关闭) | **SEU**: 配置位翻转导致 EEE 意外使能 | SG-ETH-02 | 同上 + ECC Scrub (配置 SRAM 若适用) | 90% | < 10 μs | 需与 PHY 握手确认 LPI 进入，PHY 侧需配合安全时钟 |
| `SUPPORT_EEE` | 0 (关闭) | **LPI 唤醒超时**: PHY 未能按时退出 LPI，TX 帧挂起 | SG-ETH-04 (DMA 超时) | ① LPI 唤醒 Timeout (硬件计数器) ② DMA CHx_TIMEOUT 兜底 | 95% | < 100 μs | 唤醒延迟预算: ≤ 10 μs (满足 TAS 125μs cycle 的 8% 裕量) |
| `SUPPORT_EEE` | 0 (关闭) | **配置错误**: 软件在 TSN 使能时启用 EEE | SG-ETH-02, SG-ETH-03 | ① 互斥配置检测硬件 (TSN=1 ∧ EEE=1 → 报警) ② Write-Once Lock | 95% | < 1 ms | **新增 SG-ETH-07**: 防止 EEE LPI 意外启用导致 TSN 确定性 violation |

**`SUPPORT_EEE` 默认关闭安全声明**:  
当 `SUPPORT_EEE=0` 且 CSR Write-Once Lock 生效时，EEE 模块处于逻辑删除状态，不产生时钟/功耗/延迟影响。**安全结论**: 默认关闭时无新增安全目标，但配置锁机制必须存在以防止运行时非法启用。

---

### 2.2 PHY 双工模式参数

| 参数名 | 默认值 | 故障模式 | 受影响安全目标 | 安全机制 | DC 目标 | FHTI | 备注 |
|--------|:------:|----------|:------------:|----------|:-------:|:----:|------|
| `PHY_x_DUPLEX` | 1 (全双工) | **STUCK-AT 0**: 半双工模式意外启用 | SG-ETH-02 (TSN 确定性) | ① Duplex 模式寄存器 Parity ② 速率>100M 时硬件强制全双工 (不受配置影响) ③ TSN 使能时半双工配置拒绝 | 95% | < 1 μs | **关键冲突**: 半双工引入 CSMA/CD，完全破坏 TAS/CBS 确定性 |
| `PHY_x_DUPLEX` | 1 (全双工) | **SEU**: 双工配置位翻转 | SG-ETH-02 | 同上 + 每 PHY 独立 Parity | 90% | < 1 μs | 每 PHY 独立配置，一 PHY 故障不影响其他 PHY |
| `PHY_x_DUPLEX` | 1 (全双工) | **配置错误**: 软件为 TSN MAC 配置半双工 | SG-ETH-02, SG-ETH-03 | ① 配置一致性检查 (TSN=1 ∧ DUPLEX=0 → 报警/拒绝) ② Write-Once Lock | 95% | < 1 ms | Arch Spec 已约束: `PHY_x_TYPE=0` (10BASE-T1S) 自动关闭 TAS/FP |
| `PHY_x_DUPLEX` | 1 (全双工) | **接口超时**: PHY-MII 协商失败导致双工模式不确定 | SG-ETH-02 | ① PHY 链路状态 Timeout ② 默认回退全双工 (安全态优先) | 90% | < 10 μs | 协商超时后硬件自动选择全双工 (确定性优先于兼容性) |

**`PHY_x_DUPLEX` 特别关注 — 与 SG-ETH-02 的潜在冲突**:  
当 `PHY_x_DUPLEX=0` (半双工) 且 `SUPPORT_TAS=1` 或 `SUPPORT_CBS=1` 时，CSMA/CD 的随机回退机制与 TSN 门控调度/信用整形在物理层不兼容。此冲突必须在配置阶段通过硬件互锁检测拒绝，而非运行时检测。

> **设计决策**: 对于 10BASE-T1S (PLCA 多点总线)，Arch Spec 已明确自动关闭 `SUPPORT_FP` 和 `SUPPORT_TAS`，因此半双工在此场景下不引入新的 TSN 冲突。但 PLCA 的确定性由 PLCA 协调器保证，不在本 IP 安全范围内。

---

### 2.3 AVTP / AVB 流参数

| 参数名 | 默认值 | 故障模式 | 受影响安全目标 | 安全机制 | DC 目标 | FHTI | 备注 |
|--------|:------:|----------|:------------:|----------|:-------:|:----:|------|
| `SUPPORT_AVTP` | 1 (开启) | **STUCK-AT 0**: AVTP 流识别意外关闭 | SG-ETH-01 (帧丢失), SG-ETH-09 | ① AVTP 使能位 Parity ② RX Filter ECC ③ AVTP 流计数器 Timeout | 95% | < 10 μs | **默认开启**: 必须有主动安全机制保护，不能依赖 "默认关闭无影响" |
| `SUPPORT_AVTP` | 1 (开启) | **SEU**: AVTP 识别表/流 ID 损坏 | SG-ETH-09 | ① AVTP 流匹配表 ECC ② 流 ID 范围检查 (非法 ID 拒绝) ③ DMA 队列隔离校验 | 99% | < 1 μs | AVTP 表项较小 (通常 ≤ 16 流)，适合全 ECC 保护 |
| `SUPPORT_AVTP` | 1 (开启) | **DMA 误路由**: AVTP 帧被错发至非 AVTP 队列 | SG-ETH-01, SG-ETH-09 | ① DMA 队列绑定 Parity ② 描述符通道 ID 校验 ③ 独立的 AVTP DMA 通道隔离 | 95% | < 10 μs | 关键: 摄像头/激光雷达 AVTP 帧与标准帧必须 DMA 通道隔离 |
| `SUPPORT_AVTP` | 1 (开启) | **时钟漂移**: AVTP 演示时间戳 (AVTP 时间戳) 与 PTP 时间基准偏差 | SG-ETH-02, SG-ETH-09 | ① AVTP 时间戳与 PHC 交叉校验 ② 演示时间窗口合法性检查 | 90% | < 10 μs | 演示时间 (Presentation Time) 超前/滞后超窗则丢弃 |
| `SUPPORT_AVTP_CTL` | 0 (关闭) | **STUCK-AT 1**: AVTP 控制表意外启用 | SG-ETH-09 | ① Write-Once Lock ② CTL 表 ECC ③ 控制/数据路径隔离 | 95% | < 10 μs | 默认关闭，启用后增加路由表故障面 |
| `SUPPORT_AVTP_CTL` | 0 (关闭) | **SEU**: 路由表项损坏导致 AVTP 流错发 | SG-ETH-09 | ① 路由表 ECC (SECDED) ② 源/目的 MAC 一致性检查 ③ 静态路由表校验和 | 99% | < 1 μs | 建议静态路由表 + Checksum，运行时只读 |

**`SUPPORT_AVTP` 默认开启安全声明**:  
与大多数新增参数不同，`SUPPORT_AVTP` 默认值为 **1** (开启)。这意味着 AVTP RX Filter + DMA 隔离机制在基线 ASIL-B 配置中即存在，其安全机制 (RX Filter ECC, DMA 通道隔离) 必须纳入基线安全架构，不能作为可选扩展。

> **新增 SG-ETH-09**: 防止因 AVTP 流识别/路由错误导致的 ADAS 安全数据丢失或延迟。

---

### 2.4 网络安全卸载参数 (IPsec / SecOC / D-TLS)

| 参数名 | 默认值 | 故障模式 | 受影响安全目标 | 安全机制 | DC 目标 | FHTI | 备注 |
|--------|:------:|----------|:------------:|----------|:-------:|:----:|------|
| `SUPPORT_IPSEC` | 0 (关闭) | **STUCK-AT 1**: IPsec 卸载意外启用，安全通道初始化失败 | SG-ETH-08 | ① Write-Once Lock ② CSS/HSE 握手 Timeout ③ 安全通道状态 Parity | 90% | < 10 μs | 默认关闭；意外启用会导致所有帧被 IPsec 处理但加速器未就绪 → 全帧丢弃 |
| `SUPPORT_IPSEC` | 0 (关闭) | **CSS/HSE 接口超时**: 安全加速器无响应，安全 PDU 挂起 | SG-ETH-04, SG-ETH-08 | ① 加速器接口 Timeout (≤ 10μs) ② 回退明文传输 (可配置安全策略) ③ DMA 通道独立复位 | 95% | < 100 μs | **关键决策**: 超时后回退明文还是安全停机？→ 推荐可配置策略，默认安全停机 (SAFE_STATE) |
| `SUPPORT_IPSEC` | 0 (关闭) | **SEU**: 安全描述符/SA (Security Association) 损坏 | SG-ETH-08 | ① SA 表 ECC ② SPI (Security Parameter Index) 范围检查 ③ 序列号窗口校验 | 99% | < 1 μs | SA 表条目关键，需全 ECC + 序列号防重放 |
| `SUPPORT_SECOC` | 0 (关闭) | **HSE 接口超时**: SecOC Freshness Value 获取失败 | SG-ETH-08 | ① HSE 接口 Timeout ② Freshness Value 本地备份计数器 ③ PDU 认证失败回退 | 90% | < 100 μs | SecOC 依赖 AUTOSAR SecOC 栈 + HSE，超时后 PDU 认证失败 |
| `SUPPORT_SECOC` | 0 (关闭) | **SEU**: SecOC 认证数据 (Authenticator) 损坏 | SG-ETH-01, SG-ETH-08 | ① 认证数据存储 ECC ② MAC/I-Tag 范围检查 ③ 失败后丢弃帧 (安全侧优先) | 95% | < 10 μs | 认证失败 → 丢弃帧 (不传播不可信数据) |
| `SUPPORT_DTLS` | 0 (关闭) | **CSS 接口超时**: Chacha20-Poly1305 加速器无响应 | SG-ETH-08 | ① CSS 接口 Timeout ② DTLS 会话状态机 Parity ③ 重传计数器限制 | 90% | < 100 μs | DTLS 有状态，会话状态机需 Parity 保护 |
| `SUPPORT_DTLS` | 0 (关闭) | **配置错误**: 软件为未初始化的 CSS 配置 DTLS | SG-ETH-03, SG-ETH-08 | ① CSS 就绪状态握手 ② Write-Once Lock ③ 配置一致性检查 (CSS_READY ∧ DTLS=1) | 95% | < 1 ms | 必须检测 CSS 硬件存在性再使能 DTLS |

**IPsec/SecOC/D-TLS 统一安全目标**:  
三者共享 **新增 SG-ETH-08**: 防止因外部安全加速器 (CSS/HSE) 接口故障或配置错误导致的安全 PDU 处理失败或不可信数据传播。

> **关键分析**: IPsec/SecOC/D-TLS 的安全机制不在 Ethernet IP 内部完成 (由外部 CSS/HSE 处理)，但 Ethernet IP 提供的 **封装/卸载接口** 本身是故障点。故障模式包括：
> 1. 接口 Timeout: 加速器无响应导致帧挂起
> 2. 握手失败: 安全通道未建立即开始卸载
> 3. 描述符损坏: DMA 安全描述符 SEU 导致错误的安全策略应用
> 4. 回退策略错误: 安全机制失败后错误地回退明文传输 (违反安全策略)
>
> **安全原则**: 任何安全加速器故障必须导致 **安全侧停机** (丢弃帧/进入 DEGRADED)，绝不能自动回退明文传输。回退策略如需支持，必须经显式软件配置并受 Write-Once Lock 保护。

---

### 2.5 PTP 虚拟化参数 (PHC / vPHC)

| 参数名 | 默认值 | 故障模式 | 受影响安全目标 | 安全机制 | DC 目标 | FHTI | 备注 |
|--------|:------:|----------|:------------:|----------|:-------:|:----:|------|
| `PHC_COUNT` | 2 | **双 PHC 漂移**: PHC0 与 PHC1 频率/相位偏差超过阈值 | SG-ETH-02 | ① PHC 交叉比较 (PHC0 vs PHC1, 阈值 ± 4ns) ② 漂移趋势计数器 ③ 自动同步校准 (Addend 补偿) | 95% | < 10 μs | 两 PHC 同源 `clk_ts`，漂移主要源于 Addend 差异 |
| `PHC_COUNT` | 2 | **Crossbar 绑定错误**: 端口绑定至错误 PHC | SG-ETH-02 | ① PHC 选择寄存器 Parity ② 绑定配置 Shadow 回读 ③ 非法绑定检测 (vPHC 未使能时禁止绑定至 vPHC) | 95% | < 1 μs | 每端口独立 PHC 选择，配置错误影响该端口时间同步 |
| `PHC_COUNT` | 2 | **SEU**: PHC 计数器/Addend 寄存器翻转 | SG-ETH-02 | ① PHC 计数器 ECC (64-bit 宽数据) ② Addend 寄存器 Parity ③ 纳秒字段范围检查 (0~999,999,999) | 99% | < 1 μs | PHC 为安全关键计数器，必须 ECC 保护 |
| `SUPPORT_VPHC` | 0 (关闭) | **虚拟化隔离失效**: VM A 的时间错误污染 VM B | SG-ETH-10 | ① VM ID 标签 Parity ② Xen IO Ring 边界检查 ③ vPHC 上下文切换完整性校验 | 90% | < 10 μs | **新增 SG-ETH-10**: 防止 vPHC 虚拟化隔离失效 |
| `SUPPORT_VPHC` | 0 (关闭) | **vPHC 上下文损坏**: VM 切换时 vPHC 状态未正确保存/恢复 | SG-ETH-10 | ① vPHC 上下文 RAM ECC ② 上下文切换原子性保证 (硬件序列) ③ VM ID 与 vPHC 绑定校验 | 95% | < 10 μs | 上下文切换需硬件原子序列，不能被中断 |
| `SUPPORT_VPHC` | 0 (关闭) | **SEU**: vPHC 偏移量 (offset from physical PHC) 翻转 | SG-ETH-10 | ① vPHC offset ECC ② 偏移量合理性检查 (超范围 → 使用物理 PHC) ③ 虚拟机时间漂移监控 | 90% | < 10 μs | 偏移量异常时安全回退至物理 PHC |
| `SUPPORT_VPHC` | 0 (关闭) | **配置错误**: 为单 PHC 系统配置 vPHC (PHC_COUNT=1 ∧ VPHC=1) | SG-ETH-03 | ① 配置一致性检查 (PHC_COUNT&lt;2 ∧ VPHC=1 → 报警/拒绝) ② Write-Once Lock | 95% | < 1 ms | Arch Spec 已定义依赖约束 |

**`PHC_COUNT=2` 默认开启说明**:  
`PHC_COUNT` 默认值为 2，意味着双 PHC 是基线配置。这与 `SUPPORT_VPHC` (默认 0) 不同：vPHC 是可选虚拟化扩展，但双 PHC 本身已是安全基线的一部分。

> **PHC 漂移监控具体实现**:  
> - 周期: 每 1 ms 比较一次 PHC0 vs PHC1  
> - 阈值: ± 4 ns (1 tick @ 250MHz)  
> - 响应: 累计 3 次超阈值 → DEGRADED，触发 Addend 重新同步  
> - 单 PHC 故障: 所有端口自动迁移至健康 PHC，故障 PHC 进入隔离态

---

## 3. 默认关闭参数的安全声明汇总

| 参数 | 默认值 | 默认关闭时是否影响安全 | 所需最低安全机制 | 说明 |
|------|:------:|:--------------------:|------------------|------|
| `SUPPORT_EEE` | 0 | **否** (若 Write-Once Lock 生效) | CSR Write-Once Lock + Parity | EEE 模块逻辑删除，无功耗/延迟影响 |
| `SUPPORT_IPSEC` | 0 | **否** (若 Write-Once Lock 生效) | CSR Write-Once Lock + Parity | 安全卸载接口未初始化，不引入外部故障 |
| `SUPPORT_SECOC` | 0 | **否** (若 Write-Once Lock 生效) | CSR Write-Once Lock + Parity | 同上 |
| `SUPPORT_DTLS` | 0 | **否** (若 Write-Once Lock 生效) | CSR Write-Once Lock + Parity | 同上 |
| `SUPPORT_AVTP_CTL` | 0 | **否** (若 Write-Once Lock 生效) | CSR Write-Once Lock + Parity | AVTP 控制表未初始化，不影响数据路径 |
| `SUPPORT_VPHC` | 0 | **否** (若 Write-Once Lock 生效) | CSR Write-Once Lock + Parity + 配置一致性检查 | vPHC 模块逻辑删除，PHC_COUNT=2 时两物理 PHC 独立运行 |
| `PHY_x_DUPLEX` | 1 | **不适用** (非关闭型参数) | Duplex 模式 Parity + 速率强制全双工 + TSN 互锁 | 默认全双工是安全态，半双工才是风险态 |

> **重要**: "默认关闭不影响安全" 的前提条件是 **配置寄存器受 Write-Once Lock 保护**。若锁机制失效，任何默认关闭的参数都可能在运行时被非法启用，从而引入未经验证的安全风险。因此 **Write-Once Lock 是前提安全机制，而非可选**。

---

## 4. DC 数值依据与待验证项

| DC 数值 | 计算依据 | 验证状态 |
|:-------:|----------|----------|
| 99% (SECDED ECC) | Infineon TC4x Safety Manual §4.2 — SECDED 覆盖率 100% 单 bit 纠正 + 100% 双 bit 检测 | ✅ 已对标验证 |
| 95% (Write-Once Lock + 互锁检测) | 配置错误检测 = 所有非法配置组合中可检测比例。TSN∩EEE、TSN∩Half-Duplex 等 4 类互锁覆盖主要风险 | ⚠️ 待 EDR 阶段通过故障注入验证 |
| 95% (Timeout) | 基于时钟周期计数器的超时检测。10μs @ 250MHz = 2500 cycles，足够区分正常延迟与故障 | ✅ 原理验证通过 |
| 90% (Parity/FSM) | 单 bit Parity 检测所有单 bit SEU，覆盖率 = (2^n - 1) / 2^n ≈ 50% 状态空间，但针对 SEU 模型达 90% | ✅ ISO 26262-5 Table D 合规 |
| 90% (PHC 漂移监控) | 双 PHC 交叉比较检测单 PHC 漂移。假设两 PHC 独立故障概率极低，双故障为多点故障 | ⚠️ 待 EDR 阶段通过时钟故障注入验证 |
| 90% (vPHC 隔离) | VM ID Parity + IO Ring 边界检查。隔离失效需多重故障同时发生 (VM ID 错误 ∧ 边界失效) | ⚠️ 待 EDR 阶段通过虚拟化故障注入验证 |
| 85% (安全描述符 ECC) | 安全加速器接口描述符较小 (32~64 byte)，SECDED ECC 覆盖数据 + 地址字段 | ⚠️ 待 EDR 阶段验证 |

> **标注规范**: 本矩阵中所有 DC 数值均标注状态 — ✅ 已验证 / ⚠️ 待 EDR 阶段通过故障注入验证。未标注 "待验证" 的数值引用已有对标数据或 ISO 26262 标准表格。

---

## 5. 与 EDR FMEDA 的衔接

### 5.1 新增参数 FIT 贡献估算

| 参数模块 | 预估 FIT (基线) | 故障模式占比 | 说明 |
|----------|-----------------|--------------|------|
| EEE LPI 状态机 | +2 FIT | SEU 60%, 配置错误 40% | 小状态机，低复杂度 |
| AVTP RX Filter | +5 FIT | SEU 50%, 表项损坏 30%, DMA 误路由 20% | 16 流匹配表 + DMA 队列 |
| AVTP CTL 路由表 | +1 FIT (默认关闭) | SEU 100% | 静态表，只读运行时 |
| IPsec/SecOC/DTLS 接口 | +3 FIT (默认关闭) | Timeout 50%, 配置错误 30%, SEU 20% | 主要是接口逻辑，加速器 FIT 不计入 IP |
| PHY Duplex 配置 | +1 FIT | SEU 70%, 配置错误 30% | 每 PHY 1-bit，8 PHY 共 8 bit |
| PHC 双时钟 + Crossbar | +3 FIT | 漂移 40%, SEU 35%, 绑定错误 25% | 双计数器 + 选择 Crossbar |
| vPHC 虚拟化 | +4 FIT (默认关闭) | 隔离失效 40%, 上下文错误 35%, SEU 25% | IO Ring + 上下文 RAM |

> **总计**: 默认配置下 (EEE=0, IPsec=0, SecOC=0, DTLS=0, AVTP_CTL=0, VPHC=0) 仅 AVTP (默认 1) + PHC_COUNT=2 + PHY_DUPLEX 生效，基线 FIT 增量 ≈ **+9 FIT**。  
> 全部启用时 FIT 增量 ≈ **+19 FIT**。详见 EDR 阶段完整 FMEDA。

### 5.2 故障注入测试新增项

| 测试项 | 注入方法 | 预期检测 | 关联参数 |
|--------|----------|----------|----------|
| EEE 非法启用 + TSN 运行 | 强制 CSR `SUPPORT_EEE=1` 且绕过 Lock | TSN∩EEE 互锁报警 | `SUPPORT_EEE` |
| LPI 唤醒超时 | 强制 PHY LPI 响应信号拉低 | LPI 唤醒 Timeout → DEGRADED | `SUPPORT_EEE` |
| 半双工 + TAS 配置 | 强制 `PHY_x_DUPLEX=0` 且 `SUPPORT_TAS=1` | 配置拒绝 / 报警 | `PHY_x_DUPLEX` |
| AVTP 流表 SEU | 强制 AVTP 匹配表 bit 翻转 | ECC 纠正 / 双 bit 报警 | `SUPPORT_AVTP` |
| AVTP DMA 错队列 | 强制 DMA 通道映射错误 | 通道隔离校验报警 | `SUPPORT_AVTP` |
| CSS 接口 Timeout | 屏蔽 CSS 响应信号 | 接口 Timeout → DEGRADED/SAFE_STATE | `SUPPORT_IPSEC` |
| SecOC Freshness 失败 | 强制 HSE Freshness Value 错误 | PDU 认证失败 → 丢弃帧 | `SUPPORT_SECOC` |
| PHC 漂移注入 | 强制 PHC0 Addend 偏移 | PHC 交叉比较报警 → DEGRADED | `PHC_COUNT=2` |
| vPHC VM 隔离突破 | 强制 VM ID 篡改 | VM ID Parity 报警 | `SUPPORT_VPHC` |

---

## 6. 版本历史

| 版本 | 日期 | 作者 | 变更内容 |
|------|------|------|----------|
| v1.0 | 2026-05-21 | FuSa Agent | 初始版本: 9 项新增参数安全影响矩阵，含故障模式、安全目标、安全机制、DC、FHTI |

---

*文档生成: 2026-05-21 | 状态: Draft | 下一步: EDR 阶段故障注入验证 → FMEDA 更新*
