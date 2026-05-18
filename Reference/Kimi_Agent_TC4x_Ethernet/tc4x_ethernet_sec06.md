## 6. CSS安全加速器

汽车E/E架构向zonal拓扑演进的过程中，车载网络面临的安全威胁呈现指数级增长。区域控制器（Zonal Controller）作为连接传感器、执行器与中央计算单元的关键枢纽，必须同时满足高吞吐通信、功能安全（ISO 26262 ASIL-D）与网络安全（ISO/SAE 21434）三重约束。AURIX TC4x系列集成的Cyber Security Satellite（CSS）模块正是为解决这一矛盾而设计的分布式硬件安全加速引擎。CSS直接挂载于SRI（Shared Resource Interconnect）交叉总线，提供20+1条独立加密通道、3组AES引擎及完整的哈希加速阵列，可在不占用应用CPU算力的前提下，为MACsec、IPsec、DTLS/TLS 1.3和SecOC等车载网络安全协议提供硬件级加速[^21^]。

### 6.1 CSS模块架构

#### 6.1.1 SRI总线上的分布式安全引擎：20+1独立通道

CSS是TC4x中全新设计的硬件模块，其最显著的架构特征是直接部署于SRI交叉总线，与应用CPU（TriCore LS）、DMA控制器及非易失性存储共享同一互连平面[^21^]。这一位置选择具有关键意义：相比传统外设通过次级总线（如SPB）连接到CPU的架构，SRI挂载使CSS能够以最低延迟与所有总线主设备交换数据，避免了多级桥接引入的额外时延。

![TC4x CSS安全加速器架构图](fig_css_architecture.png)

CSS提供**20+1条独立通道**，每条通道均可独立执行对称加密或哈希运算[^21^]。其中20条通道供应用CPU、DMA及其他总线主设备使用，剩余1条由CSRM（Cyber Security Real-time Module）独占[^5^]。每条通道在硬件级别实现隔离，拥有独立的密钥存储区、中断路径和报警阈值，满足mixed-criticality系统对"干扰自由"（Freedom of Interference）的严格要求[^21^]。CSRM通过配置接口为每条通道独立设定访问权限，包括数据读写许可、配置修改权限以及通道优先级级别[^21^]。这种通道级隔离机制意味着，即使某一通道因攻击流量过载或密钥泄露而触发安全事件，其余20条通道仍可继续正常运行，不会被波及。

#### 6.1.2 与CSRM的信任链：CSRM配置、CSS执行的安全模型

CSS的安全模型遵循"CSRM配置、CSS执行"的分层原则。系统复位后，CSRM对CSS拥有独占访问权，负责完成所有通道的初始化配置[^21^]。CSRM自身是一个完整的安全子系统，集成了TriCore 1.8 CPU（CPUcs，最高500 MHz）、公钥加密引擎（PKC）、真随机数生成器（TRNG）、私有Flash（NVMcs）以及CSBCU总线控制单元。CSS与CSRM之间通过桥接器在同一SRI交叉总线上通信，CSRM可远程配置CSS的通道分配、密钥写入、失败认证阈值及密钥锁定策略[^21^]。

CSS支持三种运行模式，覆盖从最高安全性到最高性能的不同需求场景[^21^]：

**模式一（向后兼容模式）**：CSRM负责密钥更新并执行所有加密操作，应用CPU通过CSRM间接访问CSS。此模式与TC3x HSM的使用模式最为接近，安全性最高但延迟较大。

**模式二（安全与性能平衡模式）**：CSRM仅负责密钥更新，应用CPU直接通过SRI总线访问CSS执行加密运算。该模式显著降低了短帧处理的关键路径延迟，尤其适合CAN和Ethernet控制帧的实时加解密[^21^]。

**模式三（纯硬件加速器模式）**：应用CPU同时拥有密钥更新和加密运算的完全访问权限，CSRM仅在初始化阶段介入。此模式实现最大吞吐量和最低延迟，适用于高带宽数据面处理。

### 6.2 硬件加密引擎

CSS集成了6类专用硬件加速引擎，覆盖现代密码学的核心算法族。各引擎可在不同通道上并行运行，实现真正的多流并发处理。

| 加速引擎 | 数量 | 支持算法/模式 | 关键参数 | 车载安全协议映射 |
|:---------|:----:|:-------------|:---------|:----------------|
| AES Engine | 3 | CMAC, GMAC, GCM, GHASH | 128/192/256-bit密钥 | MACsec (GCM), IPsec (ESP), SecOC (CMAC) |
| Chacha20 | 1 | Stream cipher, 256-bit key, 96-bit nonce | 30 cycles/64B, 856 MB/s | DTLS 1.3 / TLS 1.3 (V2X通信) |
| SipHash | 1 | 2-4 variant, 4-8 variant | 20/40 cycles/64B, 1280/640 MB/s | SecOC PDU认证 (CAN/Ethernet) |
| Poly1305 | 1 | MAC algorithm | 55 cycles/64B, 468 MB/s | ChaCha20-Poly1305 AEAD |
| SHA Engine | 1 | SHA-1/224/256/384/512, HMAC, SHA3-224/256/384/512 | 27-88 cycles/块 | 证书链验证、密钥派生 |
| SHAKE | 1 | SHAKE128/256 | 27 cycles/块, 2492/2016 MB/s | XOF扩展输出、密钥派生 |

上表呈现了CSS加密引擎矩阵的完整视图。三组AES引擎是CSS设计的核心创新——相比TC3x HSM仅有单一AES实例，3x AES并行架构使CSS能够同时处理多个独立的数据流。在车载网络场景中，这一能力直接映射为多端口MACsec并发处理：TC4x的2个5 Gbps GETH端口与4个10/100 Mbps LETH端口可能同时接收加密流量，3组AES引擎可动态分配给不同端口对应的CSS通道，避免加密处理成为网络吞吐的瓶颈[^21^]。

#### 6.2.1 对称加密：3x AES引擎、Chacha20

CSS的三组AES引擎完整支持CMAC、GMAC、GCM和GHASH四种操作模式，密钥长度覆盖128位、192位和256位[^21^]。CMAC模式主要用于SecOC和消息认证场景，GMAC/GCM模式服务于MACsec和IPsec的AEAD（Authenticated Encryption with Associated Data）需求，GHASH作为GCM模式的认证组件可独立调用。Chacha20流密码引擎采用256位密钥和96位nonce，在400 MHz时钟下每64字节数据仅需30个时钟周期，等效吞吐率达到856 MB/s[^21^]。Chacha20与Poly1305组合形成的ChaCha20-Poly1305 AEAD方案是TLS 1.3标准 cipher suite 之一，在V2X（Vehicle-to-Everything）通信中具有重要应用价值。

#### 6.2.2 Hash引擎：SHA-1/SHA-2/SHA-3、HMAC、SHAKE128/256

CSS的哈希引擎实现了对三代SHA标准的完整覆盖。SHA-1和SHA-2系列（SHA-224/256/384/512）以88或72个时钟周期处理64字节或128字节输入块[^21^]。SHA-3系列基于Keccak算法，以固定的27个时钟周期处理不同大小的输入块——由于SHA-3的内部状态更大（1600位），其每周期有效吞吐显著优于SHA-2：SHAKE128在400 MHz下达到2492 MB/s，是CSS所有算法中吞吐率最高的[^21^]。HMAC模式在基础哈希运算基础上仅增加少量周期用于密钥处理，吞吐率与底层哈希算法基本持平。SHAKE128/256作为可扩展输出函数（XOF），可生成任意长度的输出，适用于密钥派生和掩码生成等需要变长输出的密码学场景。

#### 6.2.3 专用引擎：SipHash、Poly1305

SipHash和Poly1305是CSS针对轻量级认证需求而引入的两款专用引擎。SipHash引擎支持SipHash-2-4和SipHash-4-8两种参数变体：2-4变体以20个周期/64字节达到1280 MB/s的峰值吞吐，适合对延迟极度敏感的PDU认证场景；4-8变体以40个周期/64字节提供640 MB/s吞吐，在安全性与性能之间取得更高平衡[^21^]。SipHash在AUTOSAR SecOC规范中被推荐用于CAN/CAN-FD帧的Freshness Value和Authenticator计算，其短输入高性能的特性与车载控制帧（通常8-64字节）的长度分布高度匹配。Poly1305引擎作为ChaCha20-Poly1305 AEAD方案的认证组件，以55个周期/64字节提供468 MB/s吞吐[^21^]，与Chacha20引擎配合实现完整的AEAD处理流程。

### 6.3 密钥管理

#### 6.3.1 8KB安全RAM：密钥存储、IV与属性

CSS内部集成8KB专用RAM用于安全密钥存储，支持128位、192位和256位三种密钥长度，同时容纳初始化向量（IV）和密钥属性元数据[^21^]。该RAM在架构上具有一个关键安全特征：**不存在任何软件可访问的读取接口**，密钥一旦写入便无法被任何总线主设备（包括应用CPU和调试器）回读[^21^]。这种"只写不读"的设计从根本上消除了密钥泄露的软件攻击面。

8KB RAM按通道进行分区，每个通道被分配独立的基地址和存储大小[^21^]。同一密钥可在多个通道间共享，减少了重复存储的内存开销。密钥属性（Attribute）机制为每把密钥附加访问控制元数据，包括写保护标志——被标记为写保护的密钥将永久不可修改，适用于根密钥和长期会话密钥的存储。

#### 6.3.2 密钥锁定机制：安全事件触发自动锁定

CSS实现了与SMU（Safety Management Unit）紧密集成的安全事件响应框架。每个通道独立维护一个失败认证计数器，当验证失败次数超过CSRM配置的阈值时，CSS自动触发以下响应链[^21^]：首先，该通道的密钥被立即锁定，禁止后续加密操作使用；其次，CSS向SMU发送安全报警信号；最终，SMU根据预设策略执行系统级响应（如复位、中断通知或故障记录）。

密钥锁定行为可针对每条通道独立配置，CSRM在初始化阶段设定各通道的响应策略[^21^]。这种细粒度的 per-channel 安全事件管理，与通道级隔离架构共同构成了CSS的纵深防御体系：攻击者即使通过某一网络端口注入恶意流量，其影响也被严格限制在该端口对应的CSS通道内，无法扩散至其他通道或访问其他通道的密钥材料。

### 6.4 Ethernet安全应用

#### 6.4.1 MACsec加速：CSS执行AES-GCM，SW驱动处理SecTAG/ICV

MACsec（IEEE 802.1AE）为Ethernet链路层提供逐跳加密和完整性保护，是车载骨干网络（5 Gbps GETH端口）安全通信的核心协议。TC4x的MACsec实现采用"硬件加速+软件编排"的协同模型[^19^]：CSS硬件负责AES-GCM加解密和GMAC认证运算，软件驱动负责SecTAG插入/解析、ICV（Integrity Check Value）验证以及MACsec密钥协商协议（MKA）的状态管理[^5^]。

具体处理流程如下：待发送的Ethernet帧首先由软件驱动添加SecTAG（包含EtherType 0x88E5、TCI、SL和PN字段），随后通过SRI总线将帧体和关联数据（AAD）提交至CSS通道。CSS内部的AES-GCM引擎使用预配置的SAK（Secure Association Key）计算密文和ICV，运算完成后将加密帧返回DMA描述符链。接收方向执行逆向流程：CSS验证ICV并解密封装数据，将完整性验证结果通过通道状态寄存器报告给软件驱动。得益于3组AES引擎的并行能力，CSS可同时为多个MACsec安全关联（SA）提供服务，每个SA绑定至独立的CSS通道[^21^]。

#### 6.4.2 IPsec/DTLS：ESP/AH加密套件、TLS 1.3现代密码套件

CSS对IPsec协议族的加速覆盖ESP（Encapsulating Security Payload）和AH（Authentication Header）两种模式[^5^]。ESP模式采用AES-GCM提供加密与认证双重保护，AH模式则使用AES-GMAC实现纯认证。对于需要前后向保密（Perfect Forward Secrecy）的场景，CSS支持ChaCha20-Poly1305作为AES-GCM的替代方案（RFC 7634），在侧信道攻击防护要求更高的环境中提供等价的安全保障。

在TLS 1.3协议栈中，CSS可加速的核心cipher suite包括TLS_AES_128_GCM_SHA256、TLS_AES_256_GCM_SHA384以及TLS_CHACHA20_POLY1305_SHA256。哈希引擎的SHA-2/SHA-3支持覆盖TLS握手阶段的消息哈希需求（CertificateVerify和Finished消息计算），HMAC加速服务于TLS记录层的完整性校验。

#### 6.4.3 SecOC：PDU级认证，CAN/Ethernet统一安全

SecOC（Secure Onboard Communication）是AUTOSAR定义的车载网络PDU级安全机制，为CAN、CAN-FD和Ethernet帧提供 freshness 和 authenticity 保障。CSS通过AES-CMAC和SipHash两种引擎加速SecOC运算[^5^]：AES-CMAC用于生成和验证Full Authenticator（完整认证码），SipHash用于计算Truncated Authenticator（截断认证码，通常32-64位），以适应CAN帧严格的负载长度限制（每帧最多8-64字节有效载荷）。

CSS的 per-channel 密钥分配机制天然适配SecOC的"每PDU独立密钥"需求——每个SecOC受保护的PDU可分配至独立CSS通道，其Freshness Value（FV）和密钥存储于该通道对应的8KB RAM分区中[^21^]。这种架构使得区域控制器可在单一CSS实例上并发处理数百个SecOC PDU的认证运算，而无需应用CPU介入逐帧计算。更重要的是，CSS的ASIL-D MAC Comparator（详见6.5.2节）为SecOC认证结果提供了功能安全级别的验证保障，满足制动、转向等安全关键信号链的ASIL-D要求。

### 6.5 性能数据

#### 6.5.1 吞吐量对比：从AES-CMAC到SHAKE的完整性能谱

下表汇总了CSS在400 MHz系统时钟下的主要算法吞吐量实测数据。所有数据来源于Infineon官方仿真平台，反映CSS硬件引擎的实际处理性能[^21^]。

| 算法 | 周期数/数据块 | 块大小 | 吞吐率 @400 MHz (MB/s) | 典型应用场景 |
|:-----|:------------:|:------:|:----------------------:|:-----------|
| AES-CMAC-128 | — | — | **555** | SecOC认证、HMAC替代 |
| AES-CMAC-256 | — | — | **407** | 高安全级消息认证 |
| AES-GMAC-128 | — | — | **763** | MACsec ICV计算 |
| AES-GMAC-256 | — | — | **763** | MACsec高安全模式 |
| Chacha20 | 30 cycles | 64 B | **856** | TLS 1.3流加密 |
| Poly1305 | 55 cycles | 64 B | **468** | AEAD消息认证 |
| SipHash-2-4 | 20 cycles | 64 B | **1280** | SecOC快速PDU认证 |
| SipHash-4-8 | 40 cycles | 64 B | **640** | 高安全级PDU认证 |
| SHA-1 | 88 cycles | 64 B | **292** | 遗留系统兼容 |
| SHA-256 | 72 cycles | 64 B | **356** | 证书验证、TLS握手 |
| SHA-512 | 88 cycles | 128 B | **584** | IPsec HMAC-SHA-512 |
| SHA3-256 | 27 cycles | 136 B | **2016** | 后量子迁移准备 |
| SHAKE128 | 27 cycles | 168 B | **2492** | 密钥派生、XOF输出 |
| SHAKE256 | 27 cycles | 136 B | **2016** | 高安全性密钥扩展 |

上表数据揭示了CSS性能设计中的几个关键工程决策。首先，GMAC-128与GMAC-256的吞吐率相同（763 MB/s），表明GCM模式的性能瓶颈在于GHASH认证组件而非AES加密本身——这是GCM模式的结构特性决定的，因为无论密钥长度如何，GHASH的128位乘法运算量保持不变。其次，SHAKE128以2492 MB/s位居所有算法之首，这得益于Keccak-f[1600]置换的高并行度和较大的168字节输入块处理效率[^21^]。与SHA-256的356 MB/s相比，SHAKE128的吞吐率高出约7倍，使CSS在执行密钥派生和掩码生成等需要长输出的密码学任务时具有显著优势。

从车载网络工程角度审视这些数据，GMAC的763 MB/s吞吐率意味着CSS可在单通道上满足5 Gbps Ethernet端口MACsec处理的带宽需求（5 Gbps = 625 MB/s有效载荷层吞吐），且仍留有约22%的性能裕量用于处理帧开销和协议元数据。对于双5 Gbps GETH端口的并发MACsec保护，两组AES-GCM引擎分别绑定至对应CSS通道即可实现无阻塞处理。SipHash-2-4的1280 MB/s吞吐使其成为SecOC场景的理想选择：即使在最坏情况下，数百个CAN-FD和Ethernet PDU的并发认证请求也不会形成CSS层面的性能瓶颈。

#### 6.5.2 ASIL-D安全MAC比较器：恒定时间比较，1-512位可配置

CSS集成的Safe MAC Comparator是其在功能安全维度上的核心差异化特性。该比较器通过ASIL-D认证，支持1至512位任意长度的MAC值比较[^21^]。其关键安全机制是**恒定时间比较（Constant-Time Comparison）**：无论两个MAC值在何处出现差异，比较操作的执行时间都严格保持一致，比较结果不会提前返回[^21^]。这一设计消除了定时侧信道攻击的可能性——攻击者无法通过测量比较时间来推断MAC值的不匹配位置或逐字节暴力破解认证码。

MAC比较器支持两种输入模式：硬件MAC模式由CSS内部AES/哈希引擎直接生成计算MAC值，适用于高吞吐的在线认证场景；软件MAC模式由CPUcs计算MAC值后写入CHx_MAC_VALUEi特殊功能寄存器（SFR），适用于需要算法灵活性的场景[^21^]。两种模式下的比较操作均在恒定时间内完成，比较结果通过通道状态寄存器报告，失败事件自动计入该通道的失败认证计数器并触发SMU报警链[^21^]。

在车载网络的实际部署中，MAC比较器的ASIL-D等级使其可直接服务于安全关键信号路径——例如制动踏板位置传感器通过Ethernet传输的SecOC认证PDU，其认证结果由CSS MAC Comparator验证后，可直接作为ASIL-D安全链路的输入信号，无需额外的软件验证层。这种硬件级的安全认证路径不仅降低了端到端延迟，还通过消除软件比较代码的潜在bug面，提升了整体系统的功能安全完整性。
