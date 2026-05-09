## 8. PHY接口与HSPHY模块

TC4x以太网子系统的物理层实现围绕HSPHY（High Speed Physical Layer，高速物理层）模块展开。HSPHY基于MP8G PHY（Multi-Protocol 8 Gigabit PHY，多协议8G物理层）通用架构，可配置支持0.125 Gbit/s至8 Gbit/s的串行线速率[^115^]，同时通过并行接口支持MII、RMII、RGMII等传统以太网物理层规范[^75^][^35^]。本章解析TC4x支持的全部PHY接口类型、HSPHY内部架构及其初始化流程，并针对汽车以太网特有的10BASE-T1S物理层与PLCA（Physical Layer Collision Avoidance，物理层冲突避免）机制进行阐述。

### 8.1 支持的PHY接口

#### 8.1.1 MII/RMII：100M传统接口

MII（Media Independent Interface，媒体独立接口）是IEEE 802.3定义的基础性MAC-to-PHY接口，采用4位半字节并行传输。100 Mbps模式下，PHY提供25 MHz的TX_CLK与RX_CLK，有效吞吐率为 $25\,\text{MHz} \times 4\,\text{bit} = 100\,\text{Mbps}$[^422^]。接口信号包含TXD[3:0]、TX_EN、TX_ER、RXD[3:0]、RX_DV、RX_ER及时钟信号，半双工模式下还需CRS与COL信号，总引脚数超过16个[^470^]。

RMII（Reduced MII，精简MII）将引脚数缩减约50%[^422^]：数据宽度从4位压缩至2位，以50 MHz REF_CLK同步收发，满足 $50\,\text{MHz} \times 2\,\text{bit} = 100\,\text{Mbps}$[^465^]；同时取消独立收发时钟，将CRS与RX_DV复用为CRS_DV信号。**关键约束**：所有RMII引脚必须映射至同一Port组，可选Port 11、Port 16或Port 20与Port 21的组合[^115^][^117^]。该约束源于HSPHY内部时钟路由的物理限制，跨Port组布线将导致建立/保持时间违例。

#### 8.1.2 RGMII：1Gbps与DLL偏斜控制

RGMII（Reduced Gigabit MII，精简千兆MII）通过DDR（Double Data Rate，双倍数据速率）机制在4位数据线上实现1 Gbps： $125\,\text{MHz} \times 4\,\text{bit} \times 2 = 1000\,\text{Mbps}$[^422^][^389^]。TX_CTL与RX_CTL信号采用边沿复用设计——上升沿分别携带TX_EN与RX_DV，下降沿分别携带TX_ER与RX_ER。

RGMII接收端需在时钟路径上引入偏斜（skew）以确保数据采样时序。TC4x HSPHY集成DLL（Delay Lock Loop，延迟锁定环）模块，通过DLL_CFG寄存器实现精确偏斜注入，控制精度达138.88 ps（200 MHz发送时钟下），相位调节步进10度[^115^][^389^]。该片上能力消除了对PCB走线长度匹配的依赖，DLL使用CCU提供的Fxspi时钟作为参考源[^389^]。RGMII支持10/100/1000 Mbps三速自适应，对应时钟频率分别为2.5 MHz、25 MHz和125 MHz，均以DDR方式传输[^389^]。

#### 8.1.3 SGMII/USXGMII：SerDes接口

SGMII（Serial Gigabit MII，串行千兆MII）采用LVDS差分对通信，仅需2对差分信号（4引脚），时钟通过8B/10B编码嵌入数据流[^422^]。TC4x支持SGMII 100M（125 Mbps线速率）、1G（1.25 Gbps）和2.5G（3.125 Gbps）三档速率[^389^][^41^]。

USXGMII（Universal Serial 10GE MII，通用串行10G MII）在单接口内实现100M/1G/2.5G/5G无缝切换[^389^][^467^]。TC4x的5G模式采用5.15625 Gbps线速率，配合64B/66B PCS编码（IEEE 802.3 Clause 49），速率选择通过USXGMII_SPEED字段配置：3'b010对应1G、3'b100对应2.5G、3'b101对应5G[^468^]。

下表对五种PHY接口进行系统对比：

| 接口 | 最高速率 | 数据宽度 | 时钟机制 | 引脚数 | 典型应用场景 |
|:---|:---|:---|:---|:---|:---|
| MII | 100 Mbps | 4位并行 | 25 MHz（PHY提供） | 16+ | 传统10/100M设备兼容[^422^] |
| RMII | 100 Mbps | 2位并行 | 50 MHz REF_CLK | 8+ | 低成本车载边缘节点[^422^] |
| RGMII | 1 Gbps | 4位 DDR | 125 MHz | 12+ | 主流千兆以太网主链路[^422^] |
| SGMII | 2.5 Gbps | 1对LVDS差分 | 嵌入数据流 | 4 | 紧凑型板级PHY互联[^422^] |
| USXGMII | 5 Gbps | 4对LVDS差分 | 嵌入数据流 | 16 | 高速骨干网与区域控制器[^389^] |

上表揭示了接口设计从并行走向串行的演进逻辑。MII以16引脚实现100 Mbps，单位引脚带宽约6.25 Mbps/引脚；RGMII借助DDR技术将效率提升至83.3 Mbps/引脚；USXGMII以16引脚承载5 Gbps，效率达312.5 Mbps/引脚。对于引脚资源受限的汽车MCU，SGMII的4引脚设计在板级空间受限场景中具有不可替代的优势。HSPHY通过统一的MP8G PHY架构同时支持并行与串行接口，使开发人员可在同一硬件平台上根据外围PHY器件的可用性灵活选型[^115^]。

### 8.2 HSPHY模块

#### 8.2.1 MP8G PHY架构：3x PHY实例，2x XPCS，8Gbps线速率

HSPHY模块内部包含三个MP8G PHY实例、两个XPCS（Gigabit Physical Coding Sublayer，千兆物理编码子层）模块、DLL与偏斜控制单元[^115^][^117^]。每个MP8G PHY实例包含完整的PCS与PMA（Physical Medium Attachment，物理介质附加）子层：PCS负责8B/10B或64B/66B编解码、扰码/解扰及时钟速率补偿；PMA执行SerDes、CDR（Clock Data Recovery，时钟数据恢复）和发送均衡[^115^]。

两个XPCS模块专用于以太网协议适配。发送路径包含GMII速率适配逻辑（RAL）、TX字编码器和8B/10B编码器；5G USXGMII模式下通过64/66B编码器与扰码器处理。接收路径对称地包含解码器、解扰器和时钟速率补偿单元，消除时钟抖动与频漂[^115^]。XPCS使用25 MHz参考时钟。

MP8G PHY的线速率覆盖0.125 Gbit/s至8 Gbit/s[^115^]。每个实例配备自适应CTLE（Continuous Time Linear Equalizer，连续时间线性均衡器）、DFE（Decision Feedback Equalizer，判决反馈均衡器）及可编程发送均衡，支持独立TX/RX功耗控制和PRBS生成与校验[^115^]。

#### 8.2.2 初始化序列：时钟→复位→线速率→XPCS→DLL→MAC

HSPHY初始化遵循严格的时序依赖，标准流程如下：

| 步骤 | 操作内容 | 关键寄存器 | 注意事项 |
|:---|:---|:---|:---|
| 1 | 使能HSPHY时钟 | CLC.DISR = 0 | 轮询CLC.DISS确认时钟稳定 |
| 2 | 释放模块复位 | CTRL1.RSTx = 0 | 复位前须确保时钟已使能[^41^] |
| 3 | 配置MP8G PHY线速率 | 线速率配置寄存器 | 按模式选择125M/1.25G/3.125G/5.156G |
| 4 | 配置RX自适应参数 | AFE_DFE_EN_CTRL | SGMII模式须将AFE_EN_0与DFE_EN_0清0[^41^] |
| 5 | 配置XPCS以太网模式 | XPCS控制寄存器 | **跳过**SGMII模式下RX_RST_0断言步骤[^41^] |
| 6 | 配置RX_MISC温度补偿 | RX_MISC_CTRL0 | 100M→177, 1G→161, 2.5G→96, 5G→163（十进制）[^41^] |
| 7 | 配置DLL偏斜（RGMII/xSPI） | DLL_CFG | 精度138.88 ps，参考源为Fxspi时钟[^389^] |
| 8 | 配置引脚模式与驱动能力 | Port寄存器 | RMII引脚须位于同一Port组[^115^] |
| 9 | 初始化GETH/LETH MAC | MAC配置寄存器 | 必须在HSPHY就绪后执行 |

上表步骤4至6包含针对已知芯片勘误的纠正措施。勘误[HSPHY_TC.H007]要求SGMII模式禁用AFE与DFE自适应，USXGMII 5G模式保留默认值[^41^]。勘误[HSPHY_TC.H008]明确禁止在SGMII初始化中操作RX_RST_0位，否则将导致接收状态机异常[^41^]。勘误[HSPHY_TC.005]按线速率给出RX_MISC修正值以补偿温度漂移[^41^]。这些纠正反映了8 Gbps级SerDes链路在自适应均衡、时钟恢复与温度敏感性方面的工程挑战。系统复位前，软件须先将CTRL1.RSTx置1复位所有业务PHY实例，方可执行应用复位[^41^]。

### 8.3 10BASE-T1S物理层

#### 8.3.1 外部收发器接口

10BASE-T1S是IEEE 802.3cg定义的汽车专用10 Mbps以太网标准，采用半双工多分支总线拓扑，单段支持至少8个节点[^458^][^460^]。TC4x通过LETH（Lite Ethernet）模块的MII接口连接外部收发器[^40^][^41^]，物理连接仅需TXD、RXD和TX_EN三个信号。10BASE-T1S采用差分曼彻斯特编码在单一对双绞线上传输，节点共享介质访问。与CSMA/CD不同，10BASE-T1S引入PLCA机制实现确定性介质访问[^458^]。

#### 8.3.2 PLCA配置

PLCA的工作机制如下：协调器节点（节点ID = 0）周期性发送BEACON信号同步所有跟随者（节点ID = 1–254），各节点在BEACON后的特定时刻获得发送机会（TO）[^460^]。若某节点在其TO窗口内无数据待发，则立即将发送权传递给下一节点，从而消除碰撞与退避延迟。

PLCA参数通过MDIO访问Open Alliance TC14规范寄存器配置[^41^][^460^]：PLCA_NODE_ID（0为协调器，255禁用PLCA）、PLCA_NODE_COUNT（2–255，默认8）、PLCA_TO_TIMER（1–255 BT，默认32 BT）、PLCA_BURST_COUNT（0–255，默认0禁用突发）和PLCA_BURST_TIMER（0–255 BT，默认128 BT）。所有节点必须保持相同的TO_TIMER和BURST_TIMER值，节点ID必须在总线范围内唯一[^391^][^460^]。

TC4x LETH在10BASE-T1S操作中存在若干功能性偏差：跟随者发送延迟约1.24 µs超出规范、COMMIT定时器30 µs长于规定的28.8 µs、PLCA周期时间约32 µs超出预期的29 µs上限[^41^]。这些偏差在多节点网络设计时需纳入时序预算。从架构角度看，10BASE-T1S与LETH的组合使TC4x能够将以太网连接性延伸至传统CAN总线所在的传感器/执行器层面。PLCA的确定性访问特性保证了每个节点在固定周期内必然获得发送机会，相较CSMA/CD的随机退避，这一特性对需要周期性数据上报的传感器节点具有重要价值。
