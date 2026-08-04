# Ethernet IP SystemC/TLM 单元测试计划

> **项目**: ethernet (IP_20260502_001)
> **版本**: v1.0
> **日期**: 2026-07-30
> **作者**: Arch Agent / Verification Agent
> **状态**: Draft
> **关联文档**: `Docs/Arch/systemc_modeling_plan.md`, `Docs/Verification/verification_plan_v1.0.md`

---

## 1. 目标与范围

### 1.1 目标

在系统级场景测试（SC-01~SC-05）之前，通过单元测试验证各 TLM 模块的功能正确性，确保：

1. 每个模块独立功能正确
2. 模块接口语义与 Arch Spec / Interface Spec 一致
3. 提前发现集成问题，降低系统级调试复杂度

### 1.2 范围

覆盖 `Design/SystemC/models/` 下所有 TLM 模块：

| 模块 | 文件 | 优先级 | 负责 Agent |
|------|------|--------|-----------|
| Switch Core | `tlm_switch_core.h` | P0 | Design Agent |
| MAC | `tlm_mac.h` | P0 | Design Agent |
| PHC | `tlm_phc.h` | P0 | Design Agent |
| vPHC | `tlm_vphc.h` | P1 | Design Agent |
| DMA | `tlm_dma.h` | P1 | Design Agent |
| Traffic Generator | `tlm_traffic_gen.h` | P1 | Design Agent |
| Host | `tlm_host.h` | P2 | Design Agent |

---

## 2. 测试层次结构

```
Level 1: 单元测试（模块级，独立运行）
  ├── test_switch_core.cc    — FDB/VLAN/TAS/CBS/转发决策
  ├── test_mac.cc            — FCS/帧长/时间戳/帧抢占
  ├── test_phc.cc            — 时间戳/Addend/偏移/多实例
  ├── test_vphc.cc           — VM 切换/IO Ring/时间域映射
  ├── test_dma.cc            — 描述符环/通道仲裁/AXI 延迟
  ├── test_traffic_gen.cc    — 帧生成/错误注入/速率控制
  └── test_host.cc           — 发包线程/中断/CSR

Level 2: 集成测试（模块间，2~3 个模块组合）
  ├── test_mac_to_switch.cc  — MAC ↔ Switch 帧传输
  ├── test_dma_to_switch.cc  — DMA ↔ Switch 帧传输
  └── test_phc_to_mac.cc     — PHC 时间戳捕获链路

Level 3: 系统测试（场景级，完整系统）
  ├── SC-01 线速转发
  ├── SC-02 TSN 门控
  ├── SC-03 多端口并发
  ├── SC-04 vPHC VM 切换
  └── SC-05 错误注入
```

**准入条件**: Level 1 全部通过 → Level 2 → Level 3

---

## 3. 单元测试详细设计

### 3.1 test_switch_core.cc

**被测模块**: `tlm_switch_core`

**测试用例**:

| 用例 ID | 名称 | 测试内容 | 激励 | 通过判据 |
|---------|------|---------|------|---------|
| SC-U01 | FDB 自学习 | 发送源 MAC 帧，检查 FDB 是否学习 | 单播帧，src_mac=A, src_port=0 | FDB 包含 A→port0 |
| SC-U02 | FDB 查表命中 | 学习后发送目的 MAC 帧 | dst_mac=A | 转发到 port0，不泛洪 |
| SC-U03 | FDB 未命中泛洪 | 发送未学习的目的 MAC | dst_mac=B（未学习） | 泛洪到所有端口（除源端口） |
| SC-U04 | FDB 老化 | 学习后等待老化时间 | aging_time=300ms | FDB 条目被清除 |
| SC-U05 | 静态 FDB | 添加静态条目 | fdb_add_static(A, 1) | 静态条目不老化 |
| SC-U06 | VLAN 转发 | VLAN 帧查表 | vlan_id=10, dst_mac=A | 按 VLAN+FDB 转发 |
| SC-U07 | 广播帧 | 广播 MAC | dst_mac=FF:FF:FF:FF:FF:FF | 泛洪到所有端口（除源端口） |
| SC-U08 | 多播帧 | 多播 MAC | dst_mac=01:00:5E:xx:xx:xx | 泛洪处理 |
| SC-U09 | 环回丢弃 | 目的端口=源端口 | dst_mac 学习在 port0，从 port0 发送 | 帧丢弃 |
| SC-U10 | TAS 门控开 | 门控列表打开队列 | gate_mask=0xFF, queue=0 | 队列可发送 |
| SC-U11 | TAS 门控关 | 门控列表关闭队列 | gate_mask=0x00, queue=0 | 队列不可发送 |
| SC-U12 | CBS credit 累积 | 负 credit 随时间恢复 | credit=-1000, idle_slope=2Mbps | credit 逐渐恢复到 0 |
| SC-U13 | CBS credit 消耗 | 发送帧消耗 credit | credit=1000, frame=1000bits | credit 减少 1000 |
| SC-U14 | 队列优先级 | 高优先级队列优先发送 | queue7 和 queue0 同时有帧 | queue7 先发送 |
| SC-U15 | FIFO 溢出 | 队列满时入队 | queue 深度=1024，继续入队 | fifo_overflow 计数+1 |

**测试环境**:
- 实例化 `tlm_switch_core`（`SWITCH_PORT_COUNT=5`）
- 使用 `tlm_dummy_initiator` / `tlm_dummy_target` 替代外部模块
- 直接调用 `b_transport` 注入帧，检查 `tx_socket` 输出

---

### 3.2 test_mac.cc

**被测模块**: `tlm_mac`

**测试用例**:

| 用例 ID | 名称 | 测试内容 | 激励 | 通过判据 |
|---------|------|---------|------|---------|
| MAC-U01 | FCS 错误检测 | 注入 FCS 错误帧 | fcs_error=true | fcs_errors+1，帧丢弃 |
| MAC-U02 | 正常帧通过 | 无错误帧 | fcs_error=false | 帧正常转发到 Switch |
| MAC-U03 | Runt 帧检测 | <64B 帧 | length=32 | runt_frames+1，帧丢弃 |
| MAC-U04 | Giant 帧检测 | >9018B 帧 | length=10000 | giant_frames+1，帧丢弃 |
| MAC-U05 | 时间戳捕获 | PHC 时间戳写入 | phc 存在 | sfd_timestamp ≈ PHC 当前时间 |
| MAC-U06 | Express 队列 | 高优先级帧 | traffic_class=7 | 进入 express 队列 |
| MAC-U07 | Preemptable 队列 | 低优先级帧 | traffic_class=0 | 进入 preemptable 队列 |
| MAC-U08 | 帧组装 | TX 方向添加帧头/帧尾 | length=100 | 长度增加 Preamble+SFD+FCS |
| MAC-U09 | 帧拆解 | RX 方向移除帧头/帧尾 | length=118 | 长度减少 Preamble+SFD+FCS |

**测试环境**:
- 实例化 `tlm_mac` + `tlm_phc`
- 使用 `tlm_dummy_initiator` / `tlm_dummy_target` 替代 Switch 和 PHY

---

### 3.3 test_phc.cc

**被测模块**: `tlm_phc`

**测试用例**:

| 用例 ID | 名称 | 测试内容 | 激励 | 通过判据 |
|---------|------|---------|------|---------|
| PHC-U01 | 时间戳单调性 | 连续读取时间戳 | 两次 get_timestamp() | t2 > t1 |
| PHC-U02 | Addend 调整 | 修改 Addend 值 | addend=0x40000000 (半速) | 时间戳增长速率减半 |
| PHC-U03 | 偏移调整 | 设置时间偏移 | offset=1us | 时间戳增加 1us |
| PHC-U04 | 设置时间 | 设置绝对时间 | set_time(100ns) | 后续时间戳从 100ns 开始 |
| PHC-U05 | 多实例独立 | 两个 PHC 独立运行 | phc0, phc1 | 时间戳互不影响 |
| PHC-U06 | P2P 延迟计算 | 记录 4 个时间戳 | t1,t2,t3,t4 | delay = (t4-t1)-(t3-t2))/2 |

**测试环境**:
- 实例化 `tlm_phc`
- 直接调用 API，无需 socket

---

### 3.4 test_vphc.cc

**被测模块**: `tlm_vphc`

**测试用例**:

| 用例 ID | 名称 | 测试内容 | 激励 | 通过判据 |
|---------|------|---------|------|---------|
| VPHC-U01 | VM 时间映射 | VM 时间 = PHC 时间 × scale + offset | offset=1ms, scale=10ppm | vm_time ≈ phc_time + 1ms |
| VPHC-U02 | VM 切换 | 切换活动 VM | switch_vm(1) | current_vm=1，switch_count+1 |
| VPHC-U03 | 切换单调性 | 切换前后时间不回退 | 多次切换 | vm_time 单调递增 |
| VPHC-U04 | IO Ring 提交 | 提交请求到 Ring | submit_request(vm, id) | req_prod 增加 |
| VPHC-U05 | IO Ring 读取 | 读取响应 | read_response() | 返回正确的时间戳 |
| VPHC-U06 | Ring 溢出 | Ring 满时提交 | 提交 33 个请求 | overflow_count+1 |
| VPHC-U07 | 多 VM 请求 | 不同 VM 独立请求 | vm0, vm1 交替提交 | 每 VM 计数正确 |

**测试环境**:
- 实例化 `tlm_vphc` + `tlm_phc`
- 直接调用 API

---

### 3.5 test_dma.cc

**被测模块**: `tlm_dma`

**测试用例**:

| 用例 ID | 名称 | 测试内容 | 激励 | 通过判据 |
|---------|------|---------|------|---------|
| DMA-U01 | 描述符提交 | Host 提交 TX 描述符 | submit_tx_frame() | tx_queue 增加 |
| DMA-U02 | 通道轮询 | 多通道公平调度 | 4 通道同时有数据 | 每通道轮流获得 grant |
| DMA-U03 | AXI 延迟计算 | burst 传输延迟 | length=64B, AXI=64bit | delay = 8 beats × beat_time |
| DMA-U04 | 描述符错误 | OWN bit 冲突 | own=true 时提交 | error 标志，中断触发 |
| DMA-U05 | 帧写入内存 | RX 帧写入缓冲区 | 接收 Switch 帧 | memory 包含帧数据 |
| DMA-U06 | 描述符写回 | RX 完成后写回描述符 | 接收完成 | desc.own=false，timestamp 更新 |

**测试环境**:
- 实例化 `tlm_dma`
- 使用 `tlm_dummy_initiator` / `tlm_dummy_target` 替代 Switch 和内存

---

### 3.6 test_traffic_gen.cc

**被测模块**: `tlm_traffic_gen`

**测试用例**:

| 用例 ID | 名称 | 测试内容 | 激励 | 通过判据 |
|---------|------|---------|------|---------|
| TG-U01 | 帧长分布 | 生成指定分布的帧长 | lengths={64,1518}, weights={1,1} | 两种帧长比例 ≈ 50%/50% |
| TG-U02 | 速率控制 | 按指定速率生成 | rate=1000Mbps | 帧间隔 ≈ 计算值 |
| TG-U03 | FCS 错误注入 | 注入 FCS 错误 | inject_fcs_error() | fcs_errors_injected+1 |
| TG-U04 | Runt 帧注入 | 注入 runt 帧 | inject_runt_frame() | runt_frames_injected+1 |
| TG-U05 | Giant 帧注入 | 注入 giant 帧 | inject_giant_frame() | giant_frames_injected+1 |
| TG-U06 | 连续错误率 | 10% 错误率 | set_error_rate(0.1) | 约 10% 帧带错误 |

**测试环境**:
- 实例化 `tlm_traffic_gen`
- 使用 `tlm_dummy_target` 接收帧

---

## 4. 测试基础设施

### 4.1 测试基类 (`unit_test_base.h`)

```cpp
class unit_test_base {
public:
    void run();
    virtual void test_body() = 0;

    // 断言
    void assert_true(bool cond, const std::string& msg);
    void assert_false(bool cond, const std::string& msg);
    void assert_eq(uint64_t actual, uint64_t expected, const std::string& msg);
    void assert_near(double actual, double expected, double tolerance,
                     const std::string& msg);

    // 结果
    void print_result();
    int get_pass_count() const;
    int get_fail_count() const;

private:
    int m_pass = 0;
    int m_fail = 0;
    std::vector<std::string> m_failures;
};
```

### 4.2 编译目标

```makefile
# 单元测试
UNIT_TESTS := test_switch_core test_mac test_phc test_vphc test_dma test_traffic_gen

# 集成测试
INTEG_TESTS := test_mac_to_switch test_dma_to_switch test_phc_to_mac

# 系统测试
SYS_TESTS := sc01_linerate sc02_tsn sc03_concurrent sc04_vphc sc05_error
```

---

## 5. 执行计划

| 阶段 | 任务 | 交付物 | 时间 |
|------|------|--------|------|
| 1 | 实现 `unit_test_base.h` 测试框架 | `Design/SystemC/tests/unit_test_base.h` | 0.5 天 |
| 2 | 实现 `test_switch_core.cc` | 15 个用例全部通过 | 1 天 |
| 3 | 实现 `test_phc.cc` + `test_mac.cc` | 15 个用例全部通过 | 1 天 |
| 4 | 实现 `test_dma.cc` + `test_vphc.cc` | 13 个用例全部通过 | 1 天 |
| 5 | 实现 `test_traffic_gen.cc` + `test_host.cc` | 6+ 个用例全部通过 | 0.5 天 |
| 6 | 集成测试（3 项） | 模块间接口正确 | 1 天 |
| 7 | 系统测试（SC-01~SC-05） | 场景指标达标 | 2 天 |

**总计**: 约 6 天

---

## 6. 通过标准

### 6.1 单元测试通过标准

- 所有用例 100% 通过（无 FAIL）
- 代码覆盖率 ≥ 80%（行覆盖）
- 无内存泄漏（Valgrind 检查）

### 6.2 集成测试通过标准

- 模块间帧传输无丢失
- 接口语义与 Interface Spec 一致
- 延迟在理论值 ±10% 范围内

### 6.3 系统测试通过标准

- 满足 `systemc_modeling_plan.md` §5 中各场景的通过判据

---

## 7. 风险与缓解

| 风险 | 影响 | 缓解 |
|------|------|------|
| 单元测试发现架构缺陷 | 需要修改 Arch Spec | 提前评审，单元测试作为架构验证手段 |
| 线程/资源问题导致测试不稳定 | 测试结果不可重复 | 使用 pthreads 版本 SystemC，限制并发线程数 |
| 测试用例覆盖不足 | 系统级测试仍有问题 | 单元测试评审（Coding Yang），覆盖率检查 |

---

*文件: Docs/Verification/systemc_unit_test_plan.md*
*版本: v1.0*
*说明: Ethernet IP SystemC/TLM 单元测试计划 — 模块级验证策略与用例设计*
