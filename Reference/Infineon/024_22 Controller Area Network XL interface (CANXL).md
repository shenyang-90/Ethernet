# 22 Controller Area Network XL interface (CANXL)

22
Controller Area Network XL interface (CANXL)
The CANXL module provides a communication interface according to the ISO 11898-1:2024 standard,
supporting Classical CAN, CAN FD and CAN XL communication. It supports CAN XL data baudrates of up to
20 Mbits/s.
22.1
Feature list
•
Classical CAN, CAN FD and CAN XL communication according to ISO 11898-1:2024
•
CAN XL payload size of up to 2048 data bytes
•
CAN XL communication baud rate up to 20 Mbits/s
•
Hardware-based 64-bit time stamping
•
Integrated DMA for message transfers without CPU load
•
1 transmit priority queue with maximum of 32 slots for ID-based priority transmission of CAN frames
•
Maximum of 8 TX FIFO queues
•
Maximum of 8 RX FIFO queues
•
TX message filtering with up to 16 filter elements
•
RX message filtering with up to 255 filter elements (with 32-bit word compare)
22.2
Functional overview
The figure below shows the block diagram overview of the CANXL module.
CANXL
PORT 
Control
IR
fCANXL
Slave 
IF 
Bridge
Master 
IF 
Bridge    
FPI slave
SRI master
SMU
Alarms
X_CAN Node 0    
Configuration & Status 
SFRs
Message 
Handler & 
DMA
Protocol
Controller 
&
PWME
Interrupts
X_CAN Node i    
Configuration & Status 
SFRs
Message 
Handler & 
DMA
Protocol
Controller 
&
PWME
Interrupts
DMA_AXI
HOST_AXI
Shared 
Configuration 
RAM
MEM_AXI
MEM_AXI
HOST_MEM_
AXI
Node 0 
TXD
Node 0 
RXD[7:0]
Node i
 TXD
Node i
 RXD[7:0]
ERR_INT [i:0]
i
MTI_TRIG [i:0]
i
FUNC_INT [i:0]
i
fCANXLH
SAFETY_INT [i:0]
i
GTM, 
EGTM, 
GST1)
GTM, 
EGTM1)
TRIG_IN [i:0]
i
1) Note: Refer to device specific connectivity chapter for existence of connection
STM
STM_TRIG
Pin x.y
.
.
.
.
.
.
.
.
.
Figure 390
CANXL block diagram
For the alarm description please refer to the alarm mapping tables in the SMU functional block and the Safety
Manual.
The Node I are instances of X_CAN IP from Bosch. The Slave Interface Bridge contains the following functions
•
Clock control
•
Reset functions
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4165
v1.1
2025-06-26


•
Access protection and
•
Slave bus protocol conversion bridges for accessing SFRs and local memory RAM through the 32-bit FPI
interface
The Master Interface Bridge contains the following function
•
VM and PRS configuration
•
Master bus protocol conversion bridges for data and control transfer through 64-bit SRI interface
Related information
TC4Dx SMU alarm mapping tables on page 7233
22.3
Functional description
CANXL Glossary
The following table introduces some acronyms related to the CANXL functional block that are used in the rest of
the chapter.
Table 1035
CANXL acronyms
Acronym
Description
CAN
Generic term for any controller area network protocol variant.
CCAN
Classical CAN protocol as per ISO 11898-1:2024.
CAN FD
CAN with flexible datarate protocol as per ISO 11898-1:2024.
CAN XL
CAN XL protocol as per ISO 11898-1:2024.
X_CAN
Bosch IP core that supports CCAN/CAN FD/CAN XL protocols and message
handling on a single interface node.
CANXL
Functional block encapsulating multiple X_CAN.
MH
Message Handler module inside X_CAN responsible for DMA of CAN message data
and message descriptor data to and from system memory.
PRT
Protocol Controller module inside X_CAN responsible for CAN protocol operation
and interface to MH module.
L_MEM
Local Memory. It is also referred in the chapter as "Shared Configuration RAM"
S_MEM
System Memory. It refers to System RAM.
XCAND_MH_DESC
DESCRIPTOR MESSAGE HANDLER
XCAND_MH_DMA
DMA MESSAGE HANDLER
Clock control
The CANXL module has one global clock control special function register (SFR) and each X_CAN node has an
independent clock control SFR. The clock control SFR (MODULE_CLC) controls the clock enable or disable of
the entire CANXL module. The CLKEN SFR controls the clock enable or disable only for the corresponding
X_CAN nodes. The node i clock control is a subset of module clock control, that is switching off the clocks using
module clock control switches off all nodes clock domains as well.
Note:
The clocks must be switched off by hardware only after the respective X_CAN node's Protocol
Controller is stopped.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4166
v1.1
2025-06-26


fCANXL
fCANXLH
MODULE_CLC.DISR
CLKEN.N0_CC
CLKEN.N1_CC
CLKEN.Ni_CC
fCANXL0
fCANXLH0
fCANXL1
fCANXLH1
fCANXLi
fCANXLHi
fCANXLH  
(to shared resources like 
RAM, AXI interconnect etc.,)
(to CANXL Node0)
(to CANXL Node1)
(to CANXL Nodei)
Figure 391
CANXL clock control
Reset control
The CANXL module has one global Reset Control Register set (MODULE_RST_CTRLA and MODULE_RST_CTRLB)
and each X_CAN node has an independent Reset Control Register set (NODEi_RST_CTRLA and
NODEi_RST_CTRLB). The module reset control SFRs controls the reset of entire CANXL module. The node i reset
control SFRs control only for the corresponding X_CAN nodes reset. The node i reset control is a subset of
module reset control, that is triggering reset using module reset control resets all nodes also.
Note:
The kernel reset must be initiated by software only after the corresponding X_CAN node's Message
Handler and Protocol Controller are stopped. In case of individual node i kernel reset, it is up to the
software to ensure that X_CAN node i's Message Handler and Protocol Controller are stopped, before
requesting the reset via node i KRST.
Access protection
The CANXL module contains global access protection (MODULE_ACCEN SFRs) for access protection
configuration to all SFRs which are shared by the X_CAN nodes. Each X_CAN node specific SFRs access
protection is configured through the corresponding node specific access protection registers
(NODEi_ACCENNODE). The access protection for node specific configuration RAM regions are configured
through NODEi_ACCENNODE_RGNLA and NODEi_ACCENNODE_RGNUA registers. Refer to Register Overview
table for access protection allocation to SFRs.
Master VM and PRS allocation
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4167
v1.1
2025-06-26


All X_CAN nodes within the module share a single SRI master interface and has a single Master TAG-ID assigned.
In order to distinguish the SRI transactions initiated by each X_CAN node, NODEi_VMPRSCONFIG SFRs are used.
Each X_CAN node DMA transactions can be assigned to a virtual machine number (VM) and protection set (PRS).
The VM number and the PRS programmed in the NODEi_VMPRSCONFIG register will be driven on the SRI
interconnect during read or write accesses to the corresponding resource (memory), if they are enabled
respectively through configuration.
Shared Local Memory (L_MEM)
The shared L_MEM is a 32-bit RAM with allocation of 4kB per X_CAN node. The L_MEM is accessed both by
software through HOST_MEM interface and MEM_AXI interface. Arbitration is done in round-robin basis when
parallel access is requested through HOST_MEM and by hardware through MEM_AXI. The L_MEM stores the
following data for each X_CAN node
•
RX filter elements. The base address of the RX filter elements are configured through
Ni_RX_FILTER_MEM_ADD register. The amount of RAM space allocated for the RX filter elements is strictly
dependent on Ni_RX_FILTER_CTRL.NB_FE bit-field configuration and individual RX filter element
configuration.
•
Tx FIFO Queue Header and Next descriptors. The base address for TX FIFO Queue descriptors are configured
through Ni_TX_DESC_MEM_ADD.FQ_BASE_ADDR bit-field. The amount of RAM space allocated for the Tx
FIFO Queue descriptors is strictly dependent on number of active TX FIFO Queues.
•
Tx Priority Queue Header descriptors. The base address for TX Priority Queue descriptors are configured
through Ni_TX_DESC_MEM_ADD.PQ_BASE_ADDR bit-field. The amount of RAM space allocated for the Tx
Priority Queue descriptors is strictly dependent on number of active TX Priority Queue elements.
Interrupt Control
The CANXL module reports status and error events through interrupts to the Interrupt Router module. Each
X_CAN node generates following three interrupts
•
SRC_CANXLiFUNC interrupt. Each X_CAN node's functional events as described in Ni_FUNC_RAW register
can trigger this interrupt, if the corresponding events are enabled through Ni_FUNC_ENA register. The
corresponding event flags can be cleared by software through Ni_FUNC_CLR register.
•
SRC_CANXLiERR interrupt. Each X_CAN node's error events as described in Ni_ERR_RAW register can
trigger this interrupt, if the corresponding events are enabled through Ni_ERR_ENA register. The
corresponding event flags can be cleared by software through Ni_ERR_CLR register.
•
SRC_CANXLiSAFETY interrupt. Each X_CAN node's error events as described in Ni_SAFETY_RAW register can
trigger this interrupt, if the corresponding events are enabled through Ni_SAFETY_ENA register. The
corresponding event flags can be cleared by software through Ni_SAFETY_CLR register.
Message transfer trigger to GTM, eGTM and GST
CANXL module provides MTI_TRIG[N_NODES-1:0] trigger output from each CAN XL node to GTM, eGTM and GST.
Refer to device specific connectivity chapter for the availability of the trigger to GTM, eGTM and GST.
Each CAN XL node's message transfer relevant events as described in NODEi_MTI_RAW register can trigger this
interrupt, if the corresponding events are enabled through NODEi_MTI_ENA register. The corresponding event
flags can be cleared by software through NODEi_MTI_CLR register.
Timebase generation for hardware time stamping
Each X_CAN node can capture a 64-bit timestamp for every receive and transmit frames. The source for the
timebase can be selected by configuring Ni_TS_CLOCK_CTL.SRC_SEL. One of the four following sources can be
selected
1.
fCANXLH clock
2.
STM trigger
3.
GTM trigger and
4.
eGTM trigger
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4168
v1.1
2025-06-26


The selected source can be be prescaled by a 4-bit prescaler (Ni_TS_CLOCK_CTL.PRESCALER). The prescaled
source is used as basis of tick to increment the 64-bit counter which is represented in Ni_TS_CNT_HI and
Ni_TS_CNT_LO SFRs. The 64-bit counter is enabled through Ni_TS_CTL.ENABLED. The counter is cleared when
Ni_TS_CMD.TS_CLEAR bit-field is written with 1B.
The X_CAN node instances i with i>0 have an additional feature to synchronizes their time bases with Node 0
64-bit timebase. This can be enabled with Ni_TS_CLOCK_CTL.SYNC_SEL = 1B. In this scenario, the synchronized
nodes timebase is controlled by N0 timebase. The figure below shows the timebase generation and control for
each instance of X_CAN node.
STM_TRIG
fCANXLH
GTM_TRIG_IN[0]
eGTM_TRIG_IN[0]
N0_TS_CLOCK_CTL.
SRC_SEL
Node 0
XCAN
TS0
64-bit counter
(N0_TS_CNT_HI and 
N0_TS_CNT_LO)  
4-bit prescaler
(N0_TS_CLOCK_CTL.
PRESCALER)
N0_TS_CTL.
ENABLED
N0_TS_CMD
.TS_CLEAR
STM_TRIG
fCANXLH
GTM_TRIG_IN[1]
eGTM_TRIG_IN[1]
N1_TS_CLOCK_CTL.
SRC_SEL
Node 1
XCAN
TS1
64-bit counter
(N1_TS_CNT_HI and 
N1_TS_CNT_LO)  
4-bit prescaler
(N1_TS_CLOCK_CTL.
PRESCALER)
N1_TS_CTL.
ENABLED
N1_TS_CMD
.TS_CLEAR
N1_TS_CLOCK_CTL.
SYNC_SEL
STM_TRIG
fCANXLH
GTM_TRIG_IN[i]
eGTM_TRIG_IN[i]
Ni_TS_CLOCK_CTL.
SRC_SEL
Node i
XCAN
TSi
64-bit counter
(Ni_TS_CNT_HI and 
Ni_TS_CNT_LO)  
4-bit prescaler
(Ni_TS_CLOCK_CTL
.PRESCALER)
Ni_TS_CTL.E
NABLED
Ni_TS_CMD.
TS_CLEAR
Ni_TS_CLOCK_CTL.
SYNC_SEL
Figure 392
Timebase generation overview
Note:
Check availability of signals (specially GTM triggers) in connectivity chapter
Receive Port Selection
Each X_CAN node can select 1 out of 8 possible RX port interfaces. The RX port can be selected using
NODEi_PORTCTRL.RXSEL.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4169
v1.1
2025-06-26


22.4
X_CAN
The X_CAN is the new CAN Communication Controller IP supporting CAN XL protocol. The X_CAN performs
communication according to ISO 11898-1:2024.
22.4.1
Feature list
•
Conform with ISO 11898-1:2024
•
Classical CAN with up to 8 data bytes
•
CAN FD with up to 64 data bytes
•
CAN XL with up to 2048 data bytes
•
CAN Error Logging
•
Fault Injection Module
•
Programmable loop-back test mode
•
1 Priority Queue, up to 32 slots, priority based on the arbitration field of the CAN frame
•
8 TX FIFO queues
•
8 RX FIFO queues
•
TX message filtering with up to 16 filter elements
•
RX message filtering with up to 255 filter elements, while each can compare one 32-bit word (the actual
usable number of filter elements depends on CAN clock frequency, CAN bit rate, and Local Memory
performance)
•
Maskable module interrupts with three categories: Functional, Functional Error and Safety
•
Three clock domains (HOST, CAN, TIMEBASE clock domains)
22.4.2
Functional overview
The X_CAN is the new CAN Communication Controller IP from Bosch supporting CAN XL protocol. The X_CAN
performs communication according to ISO 11898-1:2024. The following block diagram shows the internal
structure of the X_CAN IP.
X_CAN
XCAND_TOP
Protocol Controller
XCAN_PRT
Message Handler
XCAND_MH
AXI Bus
Message Bus
Discrete wire
Interrupt Controller
XCAND_TOP_IRC
PWM
Encoder
XCAN_PWME
RX_MSG
TX_MSG
ENABLE
EVENTS
CAN_RX
RX_MSG
TX_MSG
D_TX
D_RX
PWME_CFG[18]
CAN_TX
CAPTURE
TIMESTAMP[64]
TIMEBASE_TIME
CDC
CDC_TIMEBASE
ENABLE
XLT
TXD
ONLY_CC (static)
ONLY_CC_FD (static)
STAT_ACT
SAMPLE_POINT
EVENTS
AXI Multiplexer
XCAND_TOP_MUX
HOST_AXI
HOST_AXI
PRT_EVENTS
MH_EVENTS
REG_AXI
PRT_REG_AXI
MH_HOST_AXI
IRC_HOST_AXI
MEM_AXI
SAFETY_INT
ERR_INT
FUNC_INT
CLOCK_ACTIVE
MEM_SFTY_CE
MEM_SFTY_UE
CDC
CDC_EVENTS
CLOCK_ACTIVE
System
Interrupt
Controller
Peripheral
Interconnect
Main 
Interconnect
L_MEM
(Local Memory)
S_MEM
(System Memory)
Debug
CAN 
Transceiver
Time
Base
OTP
Bond-out
HDP
HDP
XCAND_TOP_HDP
DMA_AXI
Clock Check
C2C_CHECK
CDC
CDC_AXI32
CDC
CDC_SIGNAL
CDC
CDC_TX_MSG
CDC
CDC_RX_MSG
Clock Check
C2C_CHECK
Figure 393
X_CAN block diagram
22.4.3
Functional description
The top level of the X_CAN IP embeds all digital blocks required for communication on one CAN bus.
To start up the X_CAN IP, the Message Handler and the Protocol Controller have to be configured beforehand.
The Message Handler must be started first (writing a '1' to the Ni_MH_CTRL.START bit) and afterwards, the
Protocol Controller has to be started by writing a ‘1’ to the Ni_CTRL.STRT bit.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4170
v1.1
2025-06-26


22.4.3.1
AXI multiplexer
The X_CAN embeds three register banks, containing configuration, control, status and event information. They
are located in the modules Message handler, Protocol controller and Interrupt controller and are accessible
through the peripheral interconnect using the HOST_AXI interface and IP internal AXI multiplexer.
•
When an access is performed to a non-mapped register in the address range, an access error response is
provided
•
When a read access to write-only registers or a write access to read-only registers is performed, an access
error response is provided
22.4.3.2
Message handler
All functions concerning the storage and scheduling of CAN messages are implemented in the Message handler
(MH). The TX path supports the storage of CAN messages in 8 TX FIFO Queues and one TX Priority Queue. The RX
path provides 8 RX FIFO Queues.
FIFO data is physically stored in System Memory (S_MEM) and managed by descriptors. TX and RX Filters
provide methods to accept or deny CAN Messages and (for RX only) to determine the target RX FIFO for data
storage.
The MH will be configured and controlled by HOST CPU through HOST_AXI interface. CAN messages and
descriptors are transported between System Memory and local memory autonomously by an internal DMA,
which is connected to DMA_AXI. For fast access, the MH needs a Local Memory (L_MEM) which is connected via
MEM_AXI interface.
22.4.3.3
Protocol controller
The Protocol Controller (PRT) performs CAN communication as specified in ISO 11898-1:2024. The bitrate
can be configured to values up to 20 MBit/s at a clock speed of 160 MHz, depending on the semiconductor
technology used. For the connection to the physical layer, additional transceiver hardware is required.
The PRT does not provide internal buffering of frames, so that data has to be transferred by IP internal Message
Busses in 32-bit slices in real-time while (de)-serializing them on the CAN Bus. Thus, single data transfers at the
internal Message Busses are closely time-synchronised to the schedule at the CAN bus.
22.4.3.4
PWME
The module PWME implements the PWM encoding as specified in ISO 11898-1:2024. When transceiver mode
switching is enabled, the PWME encodes the CAN_TX input signal during a CAN XL frame’s data phase and
during ADH CAN XL bit-field, to generate the PWM encoded output signal TXD.
22.4.3.5
Hardware Debug Port
The X_CAN provides a 16-bit Hardware Debug Port (HDP) to enable debugging using the internal signals of the
X_CAN.
The internal signals are organized in pre-defined sets which are selected by Ni_HDP.HDP_SEL. The following
tables describe the signal sets.
Table 1036
Hardware Debug Port signal sets
HDP [15:0]
HDP_SEL = 0 (MH debug port)
HDP_SEL = 1 (PRT interface signals)
15
MH_HDP[15]
TX_DU
14
MH_HDP[14]
RX_DO
13
MH_HDP[13]
BUS_OFF
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4171
v1.1
2025-06-26


Table 1036
(continued) Hardware Debug Port signal sets
HDP [15:0]
HDP_SEL = 0 (MH debug port)
HDP_SEL = 1 (PRT interface signals)
12
MH_HDP[12]
E_PASSIVE
11
MH_HDP[11]
E_ACTIVE
10
MH_HDP[10]
BUS_ERR
9
MH_HDP[9]
TX_EVT
8
MH_HDP[8]
RX_EVT
7
MH_HDP[7]
STAT_ACT[1]
6
MH_HDP[6]
STAT_ACT[0]
5
MH_HDP[5]
XLT
4
MH_HDP[4]
D_RX
3
MH_HDP[3]
D_TX
2
MH_HDP[2]
SAMPLE_POINT
1
MH_HDP[1]
CAN_TX
0
MH_HDP[0]
CAN_CLK
22.4.3.6
Interrupt controller
The X_CAN IP is equipped with a central interrupt controller (IRC). It captures all events of the MH and PRT and
can be configured for each event individually to interrupt the HOST CPU.
22.5
Message handler (MH)
The Message Handler (MH) is located between the main interconnect and the Protocol Controller (PRT). It is
used in transmit direction, to read TX CAN message data from System memory (S_MEM) and to send them to
the PRT and in receive direction, to provides S_MEM with the RX CAN message data from PRT.
22.5.1
Feature list
•
Functional and Error interrupts
•
Safety interrupts
•
Safety measures built-in:
-
Data path parity protection
-
Parity protection on address pointers
-
Linked list descriptor protected by CRC
-
Register bank protected by CRC
-
Interface timeout protection (PRT and AXI master interfaces)
•
TX message priority based on ID and IDE and SRR and RTR
•
Up to 8 TX FIFO queues can be defined
•
Up to 8 RX FIFO queues can be defined
•
1 Priority Queue with a programmable number of slot, limited to 32
•
TX message filtering with up to 16 filter definition
•
RX message filtering with up to 255 filter definition
•
Classic CAN and CAN FD supported
•
CAN XL supported
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4172
v1.1
2025-06-26


22.5.2
Functional overview
The Message Handler (MH) is located between the main interconnect and the Protocol Controller (PRT). It is
designed to read TX CAN message data from System memory (S_MEM) and to send them to the PRT.
In the other direction, it provides S_MEM with the RX CAN message data, when received by the PRT. A status
feedback is given to the software for every CAN RX and TX messages directly in the S_MEM, avoiding register
accesses.
All functions concerning the storage and scheduling of CAN messages are implemented in the Message Handler
(MH). The TX path supports the storage of CAN messages in 8 TX FIFO queues and one TX priority queue. The RX
path provides 8 RX FIFO queues. FIFO data is physically stored in system memory and managed by descriptors.
TX and RX filters provide methods to accept or deny CAN messages and (for RX only) to determine the target RX
FIFO for data storage.
The MH will be configured and controlled by software through HOST_AXI interface. CAN messages and
descriptors are transported between system memory and local memory (L_MEM) autonomously by an internal
DMA, which is connected to DMA_AXI interface. The MH needs a local memory which is connected through
MEM_AXI interface.
XCAND_MH
(MESSAGE HANDLER)
XCAND_MH_RX
(RX MESSAGE HANDLER)
TX_MSG
RX_MSG
DMA_AXI
XCAND_MH_MEM_CTRL
(LOCAL MEMORY 
CONTROLLER)  
HOST_AXI
XCAND_MH_REG
XCAND_MH_DESC
(DESCRIPTOR MESSAGE 
HANDLER)
XCAND_MH_TX
(TX MESSAGE HANDLER)
RESET_N
CLK
INTERRUPTS
CLK_AXI
MEM_AXI
ENABLE
XCAND_MH_DMA
(DMA MESSAGE HANDLER)
Read Channel 2
(TX DMA Channel )
AXI Master interface
DMA Write 
Arbitration
DMA Read 
Arbitration
Read Channel 0
(RX DESC DMA Channel)
Read Channel 1
(TX DESC DMA Channel)
Write Channel 1
(ACK DESC DMA Channel)
Write Channel 0
(RX DMA Channel)
MH_SM_00_REG_REG
_CRC_CHECK
MH_SM_13_MEMCTRL
_TO_CHECK
Parity added on read data
L_MEM
MH_SM_16_DMA_AXI_
TO_CHECK
Figure 394
MH block diagram
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4173
v1.1
2025-06-26


22.5.3
Functional description
The MH can manage concurrently up to 8 TX FIFO Queues, up to 8 RX FIFO Queues and up to 32 slots defined in
a TX Priority Queue. The message handler uses the principle of linked list to define RX and TX FIFO queues, as
well as the TX priority queue.
The TX message is made of TX descriptors (see TX descriptor chapter for more information) which define the TX
message header information and the address of its payload. The payload buffer can be defined in any location
in memory.
An RX message is written to memory based on the information defined in RX descriptors (see RX descriptor
chapter for more details) and/or configuration registers. All RX message data can be defined in any location in
memory.
The RX FIFO queue can support classic CAN, CAN FD and CAN XL frame format.
The TX FIFO queues and TX priority queue slots can support classic CAN, CAN FD and CAN XL frame format.
The TX MESSAGE HANDLER is managing the TX messages while the RX MESSAGE HANDLER is taking care of RX
messages. Both share the Descriptor Message Handler to get their TX and RX descriptors respectively. This
module also updates the status at the TX/RX FIFO Queues and TX Priority Queue when a transfer is completed.
A dedicated sub-module in the Descriptor Message Handler is assigned to the TX path and one for the RX path,
that can run concurrently.
The selection of the highest priority TX message and the RX message filtering is done locally using the L_MEM.
Therefore, the highest priority message to be sent is defined in a shorter time. Regarding the RX filtering, the RX
filter elements are fetched from the L_MEM to reduce the processing time to accept or reject an RX message
before a new one comes in.
The MH can drive only one protocol controller using the TX_MSG and RX_MSG interfaces.
Related information
TX descriptor on page 4187
RX descriptor on page 4194
22.5.3.1
TX MESSAGE HANDLER
The TX MESSAGE HANDLER is in charge of TX FIFO queues and TX priority queue management. Therefore, the TX
message handler is requesting the TX descriptor whenever required, arbitrates the TX descriptors according to
their IDs and selects the high priority TX message to be sent to the PRT.
Once a TX descriptor is selected and the PRT is winning the arbitration on CAN bus, it fetches the payload data
assigned to that descriptor from the system memory.
The internal arbitration on TX descriptors is called TX-SCAN in order to avoid a conflict with the arbitration done
on the CAN bus.
A TX filter is put in place to ensure only the relevant TX messages will be sent through the CAN bus.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4174
v1.1
2025-06-26


XCAND_MH_TX
(TX MESSAGE HANDLER)
TX_DMA_CHANNEL
TX_MESSAGE_CONTROLLER
SEQUENCER
TX DMA FIFO
CAN TD0
CAN TD1
CAN TD15
TX PRT BUFFER
CAN TDn
TX_MSG  
INTERFACE
TX_MSG
TX CHANNEL 
INTERFACE
TX_QUEUE_CONTROLLER
CONTROLLER
TX QUEUE 
CONTROLLER 
MEMORY INTERFACE
ARBITER
TX DESC ARBITER BUFFER A
CAN T0
CAN T1
CAN T2 / CAN TD0
TX Payload Addr / TD1  
DMA Info Ctrl 1
TX CANDIDATE BUFFER B
ID | FIFO/SLOT NUMBER
DMA Info Ctrl 2
TX CANDIDATE BUFFER A
ID | FIFO/SLOT NUMBER
TX ACK DESC BUFFER
DMA Info Ctrl 1
DMA Info Ctrl 2
CAN TS0
CAN TS1
FROM 
XCAND_MH_MEM_CTRL
MEM CTRL 
INTERFACE
TO 
XCAND_DESC_MH
TX DESC REQ 
INTERFACE
TX ACK 
INTERFACE
FROM 
XCAND_MH_DMA
TX MESSAGE 
CONTROLLER 
INTERFACE
TX DMA PRT BUFFER
TX DMA PTR
TX DESC FQ PTR BUFFER
TX DESC FQ PTR 1
TX DESC FQ PTR N-1
TX DESC FQ PTR 0
TX DESC PTR BUFFER
TX DESC PTR
TX DMA 
INTERFACE
MH_SM_07_TX_TXDES
C_SRC_CHECK
TX DESC VALID BUFFER
TX DESC VALID
TX DESC ARBITER BUFFER B
CAN T0
CAN T1
CAN T2 / CAN TD0
TX Payload Addr / TD1  
DMA Info Ctrl 1
DMA Info Ctrl 2
MUX
TX ACK DESC PTR BUFFER
TX ACK DESC PTR
TX PAYLOAD BUFFER
TX Payload Addr
TX Payload Size
ENABLE
MH_SM_11_TX_DP_
PARITY_CHECK
MH_SM_14_TX_TXM
SG_TO_CHECK
CLK
RESET_N
XCAND_MH_REG
INTERRUPTS
MH_SM_09_TX_AP_
PARITY_CHECK
TX MESSAGE FILTER
Buffer with parity
Address Pointers
FROM 
XCAND_MH_DESC
Figure 395
TX MESSAGE HANDLER block diagram
22.5.3.1.1
Block description
Several blocks are used to manage the TX message, TX FIFO Queues and the TX Priority Queue.
TX DMA channel interface
This block is interfacing the DMA MESSAGE HANDLER to send read commands to the system memory. It will also
hold the payload data in a local TX DMA FIFO before sending the data to the TX MESSAGE CONTROLLER when
available and complete.
The size of the payload data can be different from time to time, as low as 8 bytes for the Classic CAN up to
2048 bytes for the CAN XL.
Every TX descriptor defines the size of the data transfer to be executed. So, only one DMA transfer request is
performed per TX descriptor. Every information related to the data transfer is set by the TX MESSAGE
CONTROLLER. The TX DMA FIFO size is set to two maximum burst length to allow continuous execution of the
data transfer. As soon as the TX DMA FIFO is having enough space to load a new burst the DMA MESSAGE
HANDLER will initiate a new fetch from the system memory. Only one data transfer can be defined at a time. As
a matter of fact, when the first defined data transfer is finished, meaning the data to be read are inside the TX
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4175
v1.1
2025-06-26


DMA FIFO, a second data transfer can be started. The remaining data from the first transfer are used to wait for
the second DMA transfer data to be stored in the TX DMA FIFO.
Only the address pointer ADDR_PTR[31:0] to fetch the payload data and the SIZE[10:0] of the transfer are
required. This fields can be found on the related TX descriptor.
The other data transfer parameter are static and defined using control registers.
The TX DMA CHANNEL can accept only one data transfer definition at a time in the TX DMA PTR BUFFER, so one
data transfer can be performed at a time.
TX message controller
This block is in charge of sequencing the TX message data to the TX_MSG interface. Two sources of data are
used to build the TX message. The first data comes from the TX descriptor, which contains the header and the
first payload words of the CAN frame.
This TX descriptor comes from the TX QUEUE CONTROLLER and is provided by the ARBITER.
Once the TX descriptor is executed, the address pointer defined in the descriptor is used to fetch further
payload data from the S_MEM using the TX DMA CHANNEL.
The TX MESSAGE CONTROLLER is in charge of managing new TX descriptor when several descriptors are used
for one TX message. Any new TX message to be sent is provided only by the ARBITER, in all scenarios.
As all TX messages are managed by the TX MESSAGE CONTROLLER, once a message is sent (or not sent)
successfully to the PRT, an acknowledge descriptor is provided to the DESC MESSAGE HANDLER to be written
back to the source descriptor. If some issues are detected, the current message is canceled and all the traffic
from the system memory is aborted. Once done, a new TX message can be considered and should be already
provided by the ARBITER.
The PRT signalizes via ENABLE signal whether it requires message handling or not. When this signal goes low,
the MH must stop its current activities. This means the TX FIFO Queues and TX Priority Queue are put on hold as
well as all the relevant traffic from and to the S_MEM must be aborted.
TX queue controller
This block manages the TX FIFO Queues and the TX Priority Queue as well as the TX-SCAN. As soon as a TX
FIFO Queue is started, and/or a TX Priority Queue slot is valid, the TX QUEUE CONTROLLER is fetching the
appropriate TX descriptor from the system memory.
Those descriptors are stored in the L_MEM for further processing. The TX descriptors (only part of it) are fetched
from the L_MEM and analyzed to find out the TX message having the highest priority.
The one selected is stored locally for the TX MESSAGE CONTROLLER to be read. This block is also computing the
address to read the next TX descriptor for every TX FIFO Queues running once used and to manage the active
slot from the TX Priority Queue for new one being declared.
All the relevant information to the TX MESSAGE CONTROLLER is provided by this block.
The TX filter uses configuration registers to select between TX messages to be sent to the CAN bus and TX
messages to be discarded.
When the TX-SCAN (selection of the TX message with the highest priority) is done, the selected TX descriptor is
read from the L_MEM. To ensure that it is the one already selected, some TX descriptor bit fields are checked
against the expected value stored locally by the TX-Scan. In case one of the bit fields, listed below, does not
match, a TX_DESC_REQ_ERR signal is triggered to the system and Ni_SFTY_INT_STS.TX_DESC_REQ_ERR is set
to 1:
•
The IN (instance number)
•
The FQN (TX FIFO queue number) if PQ = 0
•
The PQSN (TX Priority Queue slot number) if PQ = 1
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4176
v1.1
2025-06-26


•
The PQ (Priority Queue flag)
•
The Priority Value assigned to the TX message
22.5.3.2
RX MESSAGE HANDLER
The RX MESSAGE HANDLER is in charge of the RX FIFO queues. Every RX FIFO queue uses a linked list of RX
descriptors to identify the exact location in S_MEM to store the message.
The RX MESSAGE HANDLER requests the RX descriptor as required, when for example the RX filter result of an
accepted incoming RX Message becomes available.
The RX filter identifies any incoming RX messages and determines whether it has to be rejected (not stored) or
accepted (stored into one of the RX FIFO queues, defined by the RX filter).
XCAND_MH_RX
(RX MESSAGE HANDLER)
RX_DMA_CHANNEL
RX_MESSAGE_CONTROLLER
RX_MSG 
INTERFACE
FILTER
RX FILTER BUFFER
CAN R0
CAN R1
FILTER ELEMENT BUFFER
FEn
SEQUENCER
RX PRT BUFFER
CAN Rn
RX_MSG
REFi
MSKj
RX_QUEUE_CONTROLLER
RX CHANNEL 
INTERFACE
RX DMA FIFO
CAN RD0
CAN RD1
CAN RD2
CAN RD31
RX MESSAGE 
INTERFACE
RX ACK DESC BUFFER
DMA Info Ctrl1
RX buffer Addr
CONTROLLER
RX DESC FQ PTR BUFFER
RX QUEUE 
CONTROLLER 
MEMORY INTERFACE
CAN TS0
CAN TS1
RX DESC BUFFER
DMA Info Ctrl1
RX buffer Addr
TO 
XCAND_MH_DMA
TO 
XCAND_MH_DESC
FROM 
XCAND_MH_MEM_CTRL
MEM CTRL 
INTERFACE
TO 
XCAND_MH_DESC
RX DESC REQ 
INTERFACE
RX DESC 
INTERFACE
RX ACK 
INTERFACE
CAN R2
RX DESC FQ PTR 0
RX DESC FQ PTR M-1
RX DESC PTR BUFFER
RX DESC PTR
RX DMA 
INTERFACE
FROM 
XCAND_MH_DESC
RX ACK DESC PTR BUFFER
RX ACK DESC PTR
MH_SM_08_RX_AP_
PARITY_CHECK
ENABLE
MH_SM_15_RX_RXMSG_
TO_CHECK
MUX
FIDX and BLK 
BUFFER
FDIX_BLK
CLK
RESET_N
XCAND_MH_REG
INTERRUPTS
RX DC FQ PTR BUFFER
RX DESC FQ PTR 0
RX DESC FQ PTR M-1
RX DC PTR BUFFER
RX DC PTR
Buffer with parity
Address Pointers
Parity added on data
RX DMA PTR BUFFER
RX DMA PTR
FROM 
XCAND_MH_DESC
Figure 396
RX MESSAGE HANDLER block diagram
22.5.3.2.1
Block description
Several blocks are used to manage the RX FIFO Queues.
RX DMA channel
This block interfaces the DMA MESSAGE HANDLER to send write commands to the S_MEM. It will also buffer the
RX message data in a local RX DMA FIFO before sending the data to the S_MEM.
The size of the payload data for a CAN frame can be the size of 8 bytes for Classical CAN and up to 2048 bytes for
CAN XL.
Every RX descriptor of the same RX FIFO Queue has a fixed buffer size to hold data. The size of the overall
transfers is stored locally to identify how many descriptors are required for the RX message and what the size of
each DMA data transfer is.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4177
v1.1
2025-06-26


As a matter of fact, when the RX message exceeds the maximum buffer pointed by the current descriptor, one
or several DMA data transfers are executed. In other words, there are as many DMA data transfer as RX
descriptors per RX message.
Only the address pointer ADDR_PTR[31:0] and the SIZE[10:0] (size of the transfer) are required to fetch the
payload data. This fields can be found on the RX descriptor. The other data transfer parameters are static and
are defined in control registers.
The RX DMA CHANNEL can accept only one data transfer definition in the RX DMA PTR BUFFER, so one data
transfer can be performed at a time.
RX message controller
This block is in charge of sequencing the RX message data from the RX_MSG interface to the RX_DMA_CHANNEL
and to filter the incoming messages.
The RX message is managed by the RX MESSAGE CONTROLLER. Once a message is received successfully, an
acknowledge descriptor is provided to the DESCRIPTOR MESSAGE HANDLER to be written back to the first
descriptor of the RX message. This first descriptor is used along the process of receiving a message and is the
only one which is acknowledged and holds the header data.
If an error was detected, the current message will be canceled and the storage to the S_MEM will be aborted.
Once done, a new RX message can be processed and the RX descriptors of the previously aborted message are
reused.
To avoid duplication of buffers, the data from the PRT is stored directly into the RX DMA FIFO without waiting
for the result of the filter. Once the result of the filter is known (RX message accepted or not accepted), the CAN
data being received is stored in the S_MEM or discarded.
The PRT signals through ENABLE signal whether it is active and requires message handling or not. When this
signal is going low, the MH stops current activities. This means that the RX FIFO queues are put on hold as well
as the traffic from and to the S_MEM will be aborted.
Related information
RX filter on page 4243
RX queue controller
This block manages the RX FIFO queues and keeps track of the write pointers to use for each of them. As soon
as an RX FIFO queue is started, the RX queue controller is allowed to request descriptors from the descriptor
message handler.
The descriptor to be used is stored into the local RX desc buffer and is the result of a request to the descriptor
message handler when the RX FIFO queue is identified by the FILTER. This block also computes the address to
read the next RX descriptor for every RX FIFO queues running, once used. All the relevant information to write
data to the S_MEM or to generate an interrupt when receiving a message is provided to the RX message
controller.
In case that several descriptors are required for one message, the RX queue controller can request the next
descriptor from the descriptor message handler as soon as RX message controller has taken over the current
descriptor.
22.5.3.3
Descriptor message handler
This block is in charge of getting, from the S_MEM, the RX descriptors used by the RX MESSAGE HANDLER. For
the TX path, it is also fetching all the descriptors for the TX path which will be used later on by the TX message
handler.
On top of providing the appropriate descriptor to those sub-modules, as soon as an RX or TX message is
received or sent, it will provide the acknowledge data relative to that message to the header descriptor.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4178
v1.1
2025-06-26


This sub-module is only managing the RX or TX descriptors fetched and acknowledged on request from the two
control sub-modules; TX MESSAGE HANDLER and RX MESSAGE HANDLER.
As the RX and TX and acknowledge paths are fully concurrent, it is up to the DMA_CONTROLLER managing
traffic from or to the S_MEM to decide which request to serve first.
As the CAN bus is unidirectional there should be a low collision rate on the AXI bus interface of the same
channel.
The parallel processing of TX/RX descriptors will decouple functions between the two paths. Such approach
relaxes the constraints on those two concurrent data flows, considering use cases where both are active at the
same time. Furthermore, while receiving a CAN Frame, TX descriptors can be fetched from the S_MEM on
request or while executing RX FIFOs. This approach lowers the complexity of use case management.
Regarding the acknowledge of descriptors, the same strategy is used, the acknowledge path does not interfere
with the RX and TX data path.
Any configuration register is defined into the main register bank of the message handler.
XCAND_MH_DESC
(DESCRIPTOR MESSAGE HANDLER)
ACK_DESC_DMA_CHANNEL
ACK DESC DMA FIFO
CAN TX/RX ACK0
CAN TX/RX ACK1
ACK DESCRIPTOR 
CONTROLLER 
INTERFACE
ACK CHANNEL 
INTERFACE
CAN TX/RX ACK3
TX_DESC_DMA_CHANNEL
TX DESC 
CHANNEL 
INTERFACE
TX DESCRIPTOR
CONTROLLER
INTERFACE
TX_DESC_CONTROLLER
TX DESC MEMORY 
INTERFACE
TX 
DESCRIPTOR  
CONTROLLER
RX_DESC_CONTROLLER
RX 
DESCRIPTOR 
CONTROLLER
ACK_DESC_CONTROLLER
ACK 
DESCRIPTOR 
CONTROLLER
TX DESC BUFFER
TX DESC0
TX DESC7
MH_SM_01_DESC_TXDESC
_CRC_CHECK
MH_SM_03_DESC_RXD
ESC_CRC_CHECK
RX DESC BUFFER
CAN RX DESC0
CAN RX DESC1
TX DESC DMA FIFO
TX DESC0
TX DESC7
RX_DESC_DMA_CHANNEL
RX DESC DMA FIFO
RX DESC 
CHANNEL 
INTERFACE
RX DESCRIPTOR
CONTROLLER
INTERFACE
CAN RX DESC0
CAN RX DESC1
XCAND_MH_REG
TO XCAND_MH_RX
FROM 
XCAND_MH_TX
TO 
XCAND_MH_DMA
FROM 
XCAND_MH_DMA
FROM 
XCAND_MH_DMA
TO 
XCAND_MH_MEM_CTRL
FROM XCAND_MH_RX
RX DESC REQ 
INTERFACE
RX DESC 
INTERFACE
RX ACK 
INTERFACE
TX DESC REQ 
INTERFACE
TX ACK 
INTERFACE
MEM CTRL 
INTERFACE
ACK DESC BUFFER
CAN TX/RX ACK0
CAN TX/RX ACK1
CAN TX/RX ACK3
ACK DESC PTR BUFFER
ACK DESC PTR
RX DESC PTR BUFFER
IN & FQN & RC
TX DESC PTR BUFFER
IN & (FQN/PQSN) & RC & PQ
ACK DESC DMA 
INTERFACE
RX DESC DMA 
INTERFACE
TX DESC DMA 
INTERFACE
MH_SM_04_DESC_RXDESC_
SRC_CHECK
MH_SM_02_DESC_TXDESC_
SRC_CHECK
CLK
RESET_N
INTERRUPTS
Buffer with parity
Address Pointers
RX DESC PTR
TX DESC PTR
XCAND_MH_RX
(RX MESSAGE HANDLER)
MH_SM_08_RX_AP_
PARITY_CHECK
XCAND_MH_TX
(TX MESSAGE HANDLER)
MH_SM_09_TX_AP_
PARITY_CHECK
MH_SM_05_DESC_RX
ACK_PARITY_CHECK
MH_SM_06_DESC_TX
ACK_PARITY_CHECK
Figure 397
Descriptor message handler block diagram
22.5.3.3.1
Block description
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4179
v1.1
2025-06-26


TX_DESC_CONTROLLER
This block stores read descriptor requests from the TX MESSAGE HANDLER and sends them to the
TX_DESC_DMA_CHANNEL. It is able to accept up to two requests when there is a need to pre-fetch TX
descriptors.
In order to provide the request to the TX_DESC_DMA_CHANNEL, the block sends only the address of the TX
descriptor ADDR_PTR[31:0] (the size of the TX descriptor is always identical). Other control signals manage the
handshaking. On top of those information, an abort signal is provided to stop the current data transfer on the
DMA channel, when requested by the TX MESSAGE HANDLER.
Once a TX descriptor is provided by the TX_DESC_DMA_CHANNEL, several checks are performed to ensure the
correctness of the descriptor and its validity. These checks are (in the order):
1.
The VALID bit in the TX descriptor is checked to ensure descriptor is valid. The following check is
performed only if the VALID bit equals 1
2.
A CRC check is done on the TX descriptor. In case a CRC error is detected, a CRC error is triggered to the
system using the TX_DESC_REQ_ERR signal and Ni_SFTY_INT_STS.TX_DESC_CRC_ERR flag is set. The
following check is performed only if there is no CRC issue
3.
The instance number IN[2:0], either the TX FIFO Queue number FQN[3:0] or the TX FIFO Queue slot
number PQSN[4:0], the rolling counter RC[4:0] bit fields of the TX descriptor and the Priority Queue bit
PQ are checked against the expected values from the request (see TX descriptor definition chapter for
more detail on those bit fields). In case that one of the bit fields does not match, a TX_DESC_REQ_ERR
signal is triggered to the system and flag Ni_SFTY_INT_STS.TX_DESC_REQ_ERR set.
Whatever the result of the checks done on the TX descriptor, it is always written to the L_MEM. Doing so, the
wrong TX descriptor can be read from the L_MEM, if required for debug purpose.
To store the TX descriptor, a write access is performed to the L_MEM through the memory controller interface.
As the size of the TX descriptor to write does not change, the number of words to be written is identical for all
descriptors. As soon as a TX descriptor is checked and no issue is identified, it is written to the L_MEM and a
notification is sent to the TX MESSAGE HANDLER.
The TX descriptor from the S_MEM is stored locally for filtering. Once stored and accepted, it is written to the
L_MEM. In case a Header Descriptor is rejected, the TX_FILTER_IRQ interrupt is triggered to the system. The TX
MESSAGE CONTROLLER is notified that the requested TX descriptor is rejected and will not be provided. Refer
to the TX Filter chapter for a detailed description.
Related information
TX descriptor on page 4187
TX_DESC_DMA_CHANNEL
This block is interfacing the DMA_CONTROLLER to send read commands to the S_MEM. It will also hold the TX
descriptors in a local DMA FIFO before sending the data to the TX_DESC_CONTROLLER when available and
complete. As the TX descriptor has a fixed size (8 words of 32 bits), the data transfer to be executed by the DMA
channel will always be the same. Only the address pointer ADDR_PTR[31:0] to fetch the TX descriptor is
required. The other data transfer parameter are static and defined using control registers. As the transmit FIFO
can accept only one TX descriptor, only one data transfer can be performed at a time. There is no check
performed by this block as everything is done by the TX_DESC_CONTROLLER holding the read request
definition. For more details on the DMA_CONTROLLER interface see the relevant chapter.
Related information
DMA message handler on page 4182
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4180
v1.1
2025-06-26


RX_DESC_CONTROLLER
This block is in charge of storing read descriptor requests from the RX MESSAGE HANDLER and to send them to
the RX_DESC_DMA_CHANNEL. It is possible to accept up to two requests when there is a need to pre-fetch RX
descriptors for large payload data defined in RX messages.
In order to provide the request to the RX_DESC_DMA_CHANNEL the block is sending only the address of the RX
descriptor ADDR_PTR[31:0] and a PRIORITY signal, other control signals are managing the handshaking. On top
of those information an abort signal is provided to stop the current data transfer on the DMA channel when
requested by the RX MESSAGE HANDLER.
Once an RX descriptor is providing by the RX_DESC_DMA_CHANNEL several checks are performed to ensure the
correctness of the descriptor. These checks are:
1.
The VALID bit in the RX descriptor is checked to ensure descriptor is valid. The following check is
performed only if the VALID bit equals 1
2.
A CRC check is done on the RX descriptor. When the CRC is valid, the RX descriptor is sent to the RX
MESSAGE HANDLER, otherwise a CRC error is triggered to the system using the RX_DESC_REQ_ERR
signal and flag Ni_SFTY_INT_STS.RX_DESC_REQ_ERR set. The following check is performed only if there
is no CRC issue
3.
The instance number IN[2:0], the RX FIFO Queue number FQN[3:0] and the rolling counter RC[4:0] bit
fields of the RX descriptor are checked against the expected value mentioned in the request (see RX
descriptor definition chapter for more detail on those bit fields). In case one of the bit field does not
match, an RX_DESC_REQ_ERR signal is triggered to the system and flag
Ni_SFTY_INT_STS.RX_DESC_REQ_ERR set.
Related information
RX descriptor on page 4194
RX_DESC_DMA_CHANNEL
This block interfaces the DMA_CONTROLLER to send read commands to the S_MEM. It will also hold the RX
descriptors in a local DMA FIFO before sending the data to the RX_DESC_CONTROLLER when available and
complete. As the RX descriptors have the same size (2 words of 32 bits), the data transfer to be executed by the
DMA channel will always be the same. Only the address pointer ADDR_PTR[31:0], to fetch the RX descriptor, is
required. The other data transfer parameters are static and defined using control registers. As the RX FIFO can
accept only one RX descriptor, only one data transfer can be performed at a time. There is no check performed
by this block as everything is done by the RX_DESC_CONTROLLER holding the read request definition. For more
details on the DMA_CONTROLLER interface, see the relevant chapter.
Related information
DMA message handler on page 4182
ACK_DESC_CONTROLLER
This block manages the RX MESSAGE HANDLER and TX MESSAGE HANDLER request when an RX or TX descriptor
being executed needs to be acknowledged. As soon as the RX MESSAGE HANDLER has completed its execution
using one RX descriptor, the relevant information (transfer status and errors mainly) of that transfer must be
sent back to the first descriptor. To do so, the RX MESSAGE HANDLER and TX MESSAGE HANDLER will send a
request to the ACK_DESC_CONTROLLER to write acknowledge data into the respective Header Descriptor.
The ACK_DESC_CONTROLLER can only accept data when the ACK DESC DMA FIFO has enough data to store it.
As long as this DMA FIFO cannot accept the data, it will hold any request from either RX MESSAGE HANDLER
and/or TX MESSAGE HANDLER. Acknowledge data are build and stored in the RX MESSAGE HANDLER and TX
MESSAGE HANDLER. This way, any updates along the reception or transmission of a TX message will
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4181
v1.1
2025-06-26


automatically be done locally on the sub-module. As the CAN bus is unidirectional, there should be no conflict
regarding RX and TX descriptors being acknowledged at the same time. The only exception is when PRT is set in
loopback mode. As soon as the ACK DESC DMA FIFO in ACK_DESC_DMA_CHANNEL provides the right FIFO level
to receive one burst of data, the ACK_DESC_CONTROLLER will write those data and will push the address
pointer of those data. Despite that RX and TX acknowledge requests may not occur at the same time, the higher
priority is always given to the RX path. The ACK_DESC_CONTROLLER will always start writing the acknowledge
data (always 4 × 32 bit ) to the DMA FIFO in ACK_DESC_DMA_CHANNEL whatever the request source is, either
TX MESSAGE HANDLER or RX MESSAGE HANDLER. At last it will write the address pointer of that descriptor
triggering at the same time a new DMA data transfer. The option, to provide a priority signal to define the
urgency of the writing, exists.
ACK_DESC_DMA_CHANNEL
This block is interfacing the DMA_CONTROLLER to send write commands to the S_MEM. It also holds bursts to
be sent over the interconnect into a local DMA FIFO before asking the DMA_CONTROLLER to send it to the
S_MEM.
As the acknowledge data for RX and TX descriptors is having a fix size (4 words of 32 bits), the data transfer to be
executed by the DMA channel will always be the same. Only the address pointer to write the burst is required
and a PRIORITY signal to manage the urgency of the request. The other data transfer parameter are static and
defined using control registers. As the transmit DMA FIFO can accept only one burst, one transfer can be
performed at a time. For more details on the DMA_CONTROLLER interface see the relevant chapter.
22.5.3.4
DMA message handler
The DMA_CONTROLLER reads and writes bursts of data from and to the S_MEM through its AXI4 master
interface DMA_AXI (compliant to AMBA 4 ARM™ protocol). The DMA_CONTROLLER manages request commands
from the sub-module that is in charge of sending or receiving TX or RX messages, as well as fetching RX or TX
descriptors.
It is in charge of providing data to the sub-module responsible to send CAN frames (TX MESSAGE HANDLER) as
well as to the sub-module managing the RX and TX descriptors (DESC MESSAGE HANDLER). It is managing all
data from a received CAN frames (RX MESSAGE HANDLER) as well as to write back information into RX/TX
descriptors when required (DESC MESSAGE HANDLER).
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4182
v1.1
2025-06-26


XCAND_MH_DMA
(DMA MESSAGE HANDLER)
XCAND_MH_TX
(TX MESSAGE 
HANDLER)
XCAND_MH_RX
(RX MESSAGE 
HANDLER)
RX_MSG
DMA_AXI
XCAND_MH_REG
XCAND_MH_DESC
(DESC MESSAGE 
HANDLER)
TX_MSG
INTERRUPTS
CLK
RESET_N
DMA write channel 0
DMA write channel 1
DMA read channel 0
DMA read channel 1
DMA read channel 2
DMA_WRITE_CH_CORE
DMA_READ_CH_CORE
CLK_AXI
MH_SM_12_DMA_CH_
IF_CHECK
MH_SM_10_RX_DP_
PARITY_CHECK
Parity added on data
Figure 398
DMA message handler block diagram
22.5.3.4.1
Block description
The DMA build in the DMA MESSAGE HANDLER block has a static configuration, once the software has written
the registers. They must not be changed except if all the DMA channels are stopped.
An arbitration process will take place to define which request command is to be served first.
As several concurrent read and write accesses can be foreseen, refer to Ni_AXI_PARAMS.AR_MAX_PEND[1:0] and
Ni_AXI_PARAMS.AR_MAX_PEND[1:0] bit field registers.
To maximize the AXI throughput, whatever the number of data transfer to be done, the DMA_CONTROLLER
ensures the usage of the maximum burst length whenever possible. To do so, the DMA_CONTROLLER is always
trying to generate a burst length for the first transfer to get an aligned address burst size for the next data to be
transferred (maximize the usage of maximum burst size for transfers).
The RESP_ERR[1:0] interrupts are used to trigger the system for any bus error, when reading or writing the
S_MEM and L_MEM. Some status flags provide the interrupt source, see the Ni_SFTY_INT_STS register.
Before starting any transfer a DMA read/write channel must be enabled. The Ni_TX_FQ_CTRL2.ENABLE[n] and
Ni_RX_FQ_CTRL2.ENABLE[n] and Ni_TX_PQ_CTRL2.ENABLE[n] bit-field registers are used to identify when the
DMA channels are required. If none of those enable bit are set to 1, no data transfer can occur.
The DMA is intended to:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4183
v1.1
2025-06-26


•
Write all the received RX CAN frame data coming from the PRT to the system memory at a defined address
location (specified into RX descriptors). This traffic does concern only the RX MESSAGE HANDLER
•
Write the acknowledge of TX CAN frame message back to the relative TX descriptor. This traffic is owned by
the DESC MESSAGE HANDLER
•
Write the acknowledge of RX CAN frame message back to the appropriate RX descriptor. This traffic is
owned by the DESC MESSAGE HANDLER
•
Read TX descriptors where the TX CAN frame header is defined with some other relevant information like
the address pointer of the payload data. This traffic is owned by the DESC MESSAGE HANDLER
•
Read RX descriptors according to the RX CAN frame messages being filtered to identify which location to
write the received data. This traffic is owned by the DESC MESSAGE HANDLER
•
Read TX message payload data from the system memory when the corresponding message header is
winning the CAN bus arbitration. This traffic does concern only the TX MESSAGE HANDLER
DMA_WRITE_CH_CORE
This block is in charge of the following:
•
Writing data to the system memory and to have those transfers compliant to the AXI4 AMBA protocol
•
Providing the appropriate write burst length for a maximum system bus efficiency according to the number
of data to be sent
•
Reading the relevant number of data from a defined DMA write channel through the read FIFO interface
•
Arbitrating among the different DMA write command of those channels
•
Stopping any AXI data transfer any time without locking the AXI write system bus interface
The DMA_WRITE_CH_CORE is storing and sending all the write commands to the system memory. As soon as a
write command is granted, the required data is fetch from the read FIFO interface of the corresponding channel
and written to the AXI write system bus interface.
A classic read FIFO interface is provided at the block interface to avoid embedded data FIFOs. This kind of
implementation does allow to scale the data FIFO assigned to any DMA write channel without having to modify
the DMA_CONTROLLER. Only the level of the FIFO to be read must be provide to ensure a proper handshaking.
The read FIFO interface is defined as, a 32-bit data bus with a read enable and a FIFO level to ensure enough
data are present into the FIFO to perform a new burst.
Once a command is received from a DMA write channel, the arbitration process is taking care of the right
command to execute.
Any write command selected by the ARBITER must only be issue by a sub-module if all the relevant data of the
burst are present into the local FIFO of the sub-module.
As long as the DMA FIFO level is not empty, AXI write commands will be issued according to the write
outstanding value set in the Ni_AXI_PARAMS.AW_MAX_PEND[1:0] bit register.
It is not allowed to insert wait state in between data read from the FIFO interface.
DMA_READ_CH_CORE
This block is in charge of:
•
Reading data from the system memory and to have those transfers compliant to the AXI4 AMBA protocol
•
Providing the appropriate read burst length for a maximum system bus efficiency according to the number
of data to be fetched
•
Writing the relevant number of data to a defined DMA read channel through the write FIFO interface
•
Arbitrating among the different DMA read command of those channels
•
Stopping any AXI data transfer any time without locking the AXI read system bus interface
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4184
v1.1
2025-06-26


The DMA_READ_CH_CORE is storing and sending all the read commands to the system memory. As soon as a
read command is granted, the required data is fetched from the AXI write system bus interface and written to
the read FIFO interface of the corresponding channel.
A classic write FIFO interface is provided at the block interface to avoid embedded data FIFOs. This kind of
implementation does allow to scale the data FIFO assigned to any DMA read channel without having to modify
the DMA_CONTROLLER. Only the level of the FIFO to be written must be provide to ensure a proper
handshaking. The write FIFO interface is defined as a 32-bit data bus with a write enable and a FIFO level to
ensure enough place are present into the FIFO to receive a new burst.
A read command from the DMA read channel would need to define all the relevant information to describe the
read data transfer to be executed, see the common list of signal defined previously.
Once a command is received from a DMA read channel, the arbitration process is taking care of the right
command to be executed.
As long as the DMA FIFO level is not full, AXI read commands will be issued according to the read outstanding
value set in the Ni_AXI_PARAMS.AR_MAX_PEND[1:0] bit register.
It is not allowed to insert wait state in between data written to the FIFO interface.
22.5.3.4.2
Data transfer mode
Several data transfer type can be defined:
No Transfer: When the register Ni_AXI_PARAMS.AW_MAX_PEND[1:0] is set to 0, no AXI write transfer is executed.
Doing so, there is the option to have the MH fully active and running without the need of an external memory to
receive RX messages. Acknowledges will not be written, so this mode is considered for debug purpose only.
When the Ni_AXI_PARAMS.AR_MAX_PEND[1:0] is set to 0, no read access is performed and without TX/RX
descriptor read, the MH will be waiting forever.
The Ni_AXI_PARAMS.AW_MAX_PEND[1:0] and Ni_AXI_PARAMS.AR_MAX_PEND[1:0] can set the maximum
number of read/write outstanding commands on the DMA_AXI interface.
22.5.3.4.3
Data transfer description
Address bus
The DMA is able to address up to 4GB memory space (DMA_AXI_AWADDR[31:0] and DMA_AXI_ARADDR[31:0]).
Burst size
The maximum number of bytes to transfer in each data transfer is fixed and set to 4. Any read or write transfer is
always using 32 bits.
When considering TX CAN frame for instance, the payload data being define as bytes must be 4 byte aligned
when read from the system memory.
For the RX CAN frame, if data to be written to system memory is not properly aligned some padding needs to be
added to complete a 4-byte word. The padding bytes are set to 00H.
As a consequence, the write strobe signals are not managed by the DMA_CONTROLLER as all 4 bytes are always
written.
Burst length
The DMA_CONTROLLER for the AXI read and write transfers supports INCR burst lengths from 1 to 8, considering
an AXI 32 bits data bus width. The DMA_AXI_AWLEN[3:0] and DMA_AXI_ARLEN[3:0] are sized to support a
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4185
v1.1
2025-06-26


maximum burst length of 16 despite only 8 is possible. To be fully compliant with the AXI4 AMBA protocol [3] the
DMA_AXI_AWLEN[7:4] and DMA_AXI_ARLEN[7:4] are considered as 0000B.
The DMA_CONTROLLER will always try to align its burst address to make full benefit of the maximum allowed
burst length. The address burst value must be always 32 byte aligned to ensure the maximum burst length
( 8 × 32 bit ). Whatever the data transfer mode, the DMA engine will reduce (if needed) the size of the first burst
to align the address to the maximum burst length. Depending on the amount of data to be transferred the last
burst can be shorter.
It is important to optimize the access to the system memory, especially if a low number of data transfer is
performed. As an example, if a data transfer of 12 × 32 bit needs to be executed and the start address is 32 byte
aligned, it will result in two burst 8 × 32 bit and 4 × 32 bit . In case the start address is not aligned and we are in
the worst scenario it could lead to 3 bursts 3 × 32 bit and 8 × 32 bit and 1 × 32 bit or 2 × 32 bit and 8 × 32 bit
and 2 × 32 bit or 1 × 32 bit and 8 × 32 bit and 3 × 32 bit .
In case high latency is expected, it is essential to limit the number of burst and make sure whenever possible to
align the start address to the maximum burst size.
The DMA_CONTROLLER provides variable burst length of data according to the sub-module command
requests.
The burst lengths from/to sub-modules connected to the DMA_CONTROLLER are defined based on the data
type of information to be used.
Here below are the expected burst length from/to the sub-modules:
•
TX MESSAGE HANDLER: This sub-module does read the TX payload data from the system memory through
the DMA read channel 2. The maximum burst length is limited to 8 × 32 bit . There is no write access from
this sub-module
•
RX MESSAGE HANDLER: This sub-module writes the RX CAN frame data to the system memory through the
DMA write channel 1. The maximum burst length is limited to 8 × 32 bit . There is no read access from this
sub-module
•
DESCRIPTOR MESSAGE HANDLER: This sub-module performs a fixed burst read of 8 × 32 bit to read TX
descriptors from the system memory through the DMA read channel 2. A fixed burst length of 2 × 32 bit is
used instead to read RX descriptors through the DMA read channel 0. To acknowledge any transfer from
and to the CAN bus, a fixed burst length of 4 × 32 bit is performed to either the RX descriptor for received
frame or to the TX descriptor for TX message through the DMA write channel 1
Outstanding transactions
In order to support read and write outstanding commands and to limit the FIFO size, the maximum burst length
is limited to 8 × 32 bit . The maximum number of outstanding command/transactions expected at the DMA_AXI
interface is programmable, see Ni_AXI_PARAMS.AR_MAX_PEND[1:0] and Ni_AXI_PARAMS.AR_MAX_PEND[1:0]
bit field register. Up to 3 read and write outstanding transactions can be specified. Even if set to the maximum
value, the maximum number of outstanding transactions performed by the MH will depend on many
parameters like the system latency, the CAN Bus bit rate, the MH and PRT clock ratio.
Burst type
The only burst type supported is the burst incrementing INCR. Check [3] for more information
The WRAP/FIXED burst type is not supported.
Memory attributes
The memory attributes for the read or write accesses to memory are Normal, Non-modifiable (Non-cacheable
in AXI3) and Non-Bufferable. No read-allocate nor Write-allocate are expected on this interface and would be
set to 0B.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4186
v1.1
2025-06-26


As a reminder, Non-bufferable means:
•
The write response must be obtained from the final destination
•
Read data must be obtained from the destination
•
Transactions are Non-Modifiable
•
Read and write transactions from the same ID to addresses that overlap must remain ordered
Non-modifiable means:
•
A Non-modifiable transaction must not be split into multiple transactions or merged with other
transactions
•
In a Non-modifiable transaction, the parameters AxADDR, AxSIZE, AxLEN, AxBURST and AxPROT must not
be changed
Transaction ID
The DMA_CONTROLLER is building the ID of every burst access based on the number of channels defined. It
provides a way to track on the system bus which DMA channel is doing the access at any time.
For the AXI read interface, the DMA_AXI_ARID[1:0] defines the channel number as follow:
00B => RX descriptor fetch from S_MEM
01B => TX descriptor fetch from S_MEM
10B => TX data payload read from S_MEM
For the AXI write interface, the DMA_AXI_AWID[0] defines the channel number as follow:
0B => TX/RX descriptor acknowledge to S_MEM
1B => RX message data write (payload and header) to S_MEM
22.5.3.5
TX descriptor
TX descriptors are used for the TX FIFO Queues and the TX Priority Queue. They can be fetched with one AXI
burst, as the overall size is only 8 × 32 bit .
Many bit fields are common but some are different between TX FIFO Queue and TX Priority Queue. Details are
provided in the following table.
Further information is provided by the chapter TX Message Header Definition.
Table 1037
TX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
0
[31]
VALID
SW/MH
Valid: The SW must set this bit to 1 to define a TX
descriptor is valid for the MH. When the descriptor
has been fully used, the MH will clear this bit when
writing the acknowledge data information back to
this descriptor. This update occurs only when the HD
bit is set to 1.
In case the descriptor is fetched when this bit is set to
0, an interrupt TX_FQ_IRQ is triggered to the system
for the TX FIFO queue n having this descriptor
[30]
HD
SW only
Must be set to 1
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4187
v1.1
2025-06-26


Table 1037
(continued) TX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
[29]
WRAP
SW only
Wrap: When set to 1 the next message descriptor is
the one declared at the initial start address of the TX
FIFO Queue (First Descriptor). This bit provides a way
to the SW to keep the next TX message continuous in
a memory buffer if less space is available at the end
of a data container
[28]
NEXT
SW only
Must be set to 0
[27]
IRQ
SW only
Interrupt: when set to 1 an interrupt is triggered to
the system when the descriptor execution is
complete, meaning when the TX message has been
sent to the CAN bus
[26]
PQ
SW only
TX Priority Queue: when set to 1, the TX descriptor
belongs to the TX Priority Queue
TX FIFO Queue: must be set to 0
[25]
END
SW only
For the TX FIFO Queue: when set to 1 the TX FIFO
Queue defined its ending, it means, it is set as
inactive. Once done, the TX FIFO Queue can be
reprogrammed and started
For the TX Priority Queue: must be set to 0
[24:16]
CRC[8:0]
SW only
CRC: this CRC is computed by the SW for the current
TX descriptor. It must consider all elements assuming
this bit-field as set to 0. Any CRC error is triggering an
interrupt to the system. The CRC is not evaluated if
the Ni_MH_SFTY_CTRL.TX_DESC_CRC_EN bit is set to
0.
[15:12]
FQN[3:0]
SW only
TX FIFO Queue: define the TX FIFO Queue number
allocated to this TX descriptor. Despite being set to 4
bits, only the FQN[2:0] bit range is used
PQSN[4:1]
SW only
TX Priority Queue: define the TX FIFO Queue slot
number allocate to this descriptor
[11]
Reserved
SW only
TX FIFO Queue: must be set to 0
PQSN[0]
SW only
TX Priority Queue: Define the TX FIFO Queue slot
number allocated to this descriptor
[10:9]
Not used
SW only
Must be set to 0
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4188
v1.1
2025-06-26


Table 1037
(continued) TX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
[8:4]
RC[4:0]
SW only
Rolling Counter: use to track the order of TX
descriptor fetched when a TX FIFO Queue or a TX
Priority Queue slot is running.
TX FIFO Queue: When a TX FIFO Queue is started for
the first time, its first TX descriptor must have the
RC[4:0] set to 00000B. This value must be
incremented for every new TX descriptor up to
11111B and then back to 00000B even in case of wrap.
TX Priority Queue: This bit field must be set to 00000B
as the initial value for all TX Header descriptor
defined in the different slots.
[3:0]
STS[3:0]
MH only
Status: gives the status of the TX message
transmitted. The MH writes back only the Header
Descriptor (HD bit set to 1) for status report. The SW
must always set it to 0.
0000B: none
0001B: message sent successfully
0010B: message not sent after a number of trials
0011B: message skipped due to HFI
0100B: message rejected by TX filter
0101B to 1110B: reserved
1111B: message acknowledge data with parity error
1
[31:27]
Not Used
SW only
Must be set to 0
[26]
PLSRC
SW only
Payload Source: This bit provides to the MH the
information about the need to fetch payload data in
the data container when executing only a TX Header
Descriptor.
When set to 1: the TX descriptor is attached to a data
container which would need to be accessed and the
bit field SIZE[9:0] defines the number of TX data to
send for this descriptor. For CAN XL, as no payload
data can be defined in TX descriptor, this bit is
always set to 1 for CAN XL. For CAN FD, this bit is set
to 1 when the payload data is greater than 4 bytes.
When set to 0: the payload data defined in the data
container are not required. Therefore, the TX
descriptor includes all data payload. For the Classical
CAN, all payload data are always included, this bit
must always be set to 0. In case of CAN FD it would be
set to 0 only when the payload data is less or equal to
4 bytes. Nevertheless, the bit field SIZE[9:0] still
defines the number of payload data to send per TX
descriptor
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4189
v1.1
2025-06-26


Table 1037
(continued) TX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
[25:16]
SIZE[9:0]
SW only
Define the buffer size in words (32-bit) for the given
TX descriptor to transmit to the PRT. As an example, a
payload from 1 to 4 bytes requires SIZE to be set to 1.
As only 32-bit read accesses are performed the buffer
size containing the payload must be 32 bit aligned.
When set to 0, there is no payload data attached to
the TX descriptor (only valid for Classical CAN/CAN
FD without payload or a Classical CAN remote frame)
For CAN XL no data is defined in TX descriptor. The
MH replies only on the address pointer defined in
element 7 to fetch payload data from S_MEM.
For CAN FD:
SIZE > 1: The copy of the first data payload (aligned
on 32 bits) is required in element 6. The address
pointer in element 7 is used to fetch the payload data
from S_MEM.
SIZE = 1: The copy of the first data payload is
required in element 6. The address pointer in
element 7 is not used. Nevertheless, it is required to
have it set to the address of the payload data in
S_MEM
SIZE = 0: Element 7 and 6 are not used
[15:13]
IN[2:0]
SW only
Instance Number: define the X_CAN instance number
using that descriptor. This bit field is relevant if
several X_CAN are running concurrently. It provides
a way to detect descriptor fetch issue between
instances. The value defined must be equal to the
one defined in the Ni_MH_CFG.INST_NUM bit field
register.
[12]
Not Used
SW only
Must be set to 0
[11:2]
TDO[9:0]
SW only
For the TX Priority Queue: This bit field must be set to
0.
NHDO[9:0]
SW only
For the TX FIFO Queue: This bit field must be set to 1.
[2:0]
Not used
SW only
Must be set to 0
2
[31:0]
TS0[31:0]
MH only
Timestamp 0: LSB of the 64-bit timestamp of the
successfully sent TX message (only valid when HD bit
is set to 1)
3
[31:0]
TS1[31:0]
MH only
Timestamp 1: MSB of the 64-bit timestamp of the
successfully sent TX message (only valid when HD bit
is set to 1)
4
[31:0]
T0[31:0]
SW only
Define the TX message header information, see TX
message header definition chapter
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4190
v1.1
2025-06-26


Table 1037
(continued) TX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
5
[31:0]
T1[31:0]
SW only
Define the TX message header information, see TX
message header definition chapter
6
[31:0]
TD0[31:0]
SW only
Classic CAN and CAN FD: define the first payload of
the TX message
T2[31:0]
SW only
CAN XL: Defined the TX message header information,
see TX message header definition chapter
7
[31:0]
TD1[31:0]
SW only
Classical CAN with payload greater equal to 4 byte:
define the last payload data of the TX message for
the Classical CAN (in case payload data is greater
than 4 bytes).
TX_AP[31:0
]
SW only
CAN XL and CAN FD with payload greater than 4
bytes: Address pointer to fetch the TX message
payload data. This bit-field is mandatory for the CAN
XL as no payload data can be defined into the
descriptor. As the Classic CAN has only 8 bytes
payload, the whole message can be defined using
only one TX descriptor, see TD0 and TD1. As the
address pointer must be 32 bit aligned the two LSB
will not be considered and so must be set to 0 all
time. In case the TX_AP is not used it must be set to
0.
Table 1038
TX Descriptor Element managed by SW
 
SW to write information to MH
SW to read information from MH
Element number
Header descriptor
Header descriptor
0
Mandatory
Mandatory
1
Mandatory
Mandatory
2
NA
Mandatory
3
NA
Mandatory
4
Mandatory
NA
5
Mandatory
NA
6
Mandatory
NA
7
Optional
NA
Table 1039
TX Descriptor Element managed by MH
 
MH to write information to SW
MH to read information from SW
Element number
Header descriptor
Header descriptor
0
Mandatory
Mandatory
1
Mandatory
Mandatory
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4191
v1.1
2025-06-26


Table 1039
(continued) TX Descriptor Element managed by MH
 
MH to write information to SW
MH to read information from SW
Element number
Header descriptor
Header descriptor
2
Mandatory
NA
3
Mandatory
NA
4
NA
Mandatory
5
NA
Mandatory
6
NA
Mandatory
7
NA
Optional
22.5.3.5.1
TX descriptor CRC computation
A dedicated CRC is computed for every TX descriptor. When a CRC error is detected the DESC_ERR interrupt
signal is triggered. This way the data transfer setting and description up to the DMA engine are fully protected.
The CRC covers all the relevant data, meaning the 247-bit data in the TX descriptor considering the CRC bit-field
in the descriptor as equal to 9'b0. The CRC is part of the Element Number 0.
The CRC ( CRC −9_167 ) is computed assuming the following elements in sequence:
Element Number 0[31:25] & 9'b0 & Element Number 0[15:0].
Element Number 1[31:0]
Element Number 2[31:0] set to 32’b0
Element Number 3[31:0] set to 32’b0
Element Number 4[31:0]
Element Number 5[31:0]
Element Number 6[31:0]
Element Number 7[31:0]
Note:
The Koopman representation of the polynomial CRC-9_167is used to protect TX descriptors:
CRC −9_167 = x9 + x7 + x6 + x3 + x2 + x + 1  (CRC polynomial in implicit "+1" hex format,
meaning the trailing "+1" is omitted from the polynomial number)
Using the Ni_MH_SFTY_CTRL.TX_DESC_CRC_EN bit register, the SW can decide to disable this check for all the
TX descriptors fetched from S_MEM or L_MEM.
22.5.3.5.2
TX descriptors errors
When a TX descriptor error is detected, the relevant information are logged in the Ni_DESC_ERR_INFO1 register.
Furthermore, the source address of the faulty TX descriptor is logged in the Ni_DESC_ERR_INFO0 register. This
would help the SW to identify potential root causes when such error occurs. The Ni_DESC_ERR_INFO1.RX_TX
bit is set to 0 when a TX descriptor gets an error.
22.5.3.6
TX message header definition
The TX descriptor contains the TX message header. The header data structure depends on the CAN Frame
Format (Classical CAN, CAN FD, CAN XL) to be used for this message on the CAN Bus. It can be controlled by the
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4192
v1.1
2025-06-26


header bits T0.FDF, T0.XLF and T0.XTD. The following tables describe the three data structures used for the
headers.
Table 1040
Classical CAN TX header definition
Tn
Bits
Name
Description/Constraints
T0
[31]
FDF
FD Format
[30]
XLF
XL Format
[29]
XTD
Extended Identifier
[28:18]
BaseID [28:18]
Base ID
[17:0]
ExtID [17:0]
Extended ID
T1
[31]
Reserved
Not Applicable
[30]
FIR
Fault Injection Request
[29:27]
Reserved
Not Applicable
[26]
RTR
Remote Transmission Request
[25:20]
Reserved
Not Applicable
[19:16]
DLC[3:0]
Data Length Code
[15:0]
Reserved
Not Applicable
Note:
Classical CAN frames (CBDF, CEDF, CBRF, CERF) require T0.FDF = T0.XLF = 0. The header consist of T0
and T1.
Table 1041
CAN FD TX header definition
Tn
Bits
Name
Description/Constraints
T0
[31]
FDF
FD Format
[30]
XLF
XL Format
[29]
XTD
Extended Identifier
[28:18]
BaseID [28:18]
Base ID
[17:0]
ExtID [17:0]
Extended ID
T1
[31]
Reserved
Not Applicable
[30]
FIR
Fault Injection Request
[29:27]
Reserved
Not Applicable
[26]
Must be set to 0 Not Applicable
[25]
BRS
Bit Rate Switch
[24:21]
Reserved
Not Applicable
[20]
ESI
Error State Indicator
[19:16]
DLC[3:0]
Data Length Code
[15:0]
Reserved
Not Applicable
Note:
CAN FD frames (FBDF, FEDF) require T0.FDF = 1 and T0.XLF = 0. The header consist of T0 and T1.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4193
v1.1
2025-06-26


Table 1042
CAN XL TX header definition
Tn
Bits
Name
Description/Constraints
T0
[31]
FDF
FD Format
[30]
XLF
XL Format
[29]
XTD
Extended Identifier
[28:18]
Priority ID
[28:18]
Priority Identifier
[17]
RRS
Remote Request Substitution
[16]
SEC
Simple Extended Content
[15:8]
VCID[7:0]
Virtual CAN Network ID
[7:0]
SDT[7:0]
SDU Type
T1
[31]
Reserved
Not Applicable
[30]
FIR
Fault Injection Request
[29:27]
Reserved
Not Applicable
[26:16]
DLC-XL [10:0]
Data Length Code with CAN XL encoding
[15:0]
Reserved
Not Applicable
T2
[31:0]
AF[31:0]
Acceptance Field
Note:
CAN XL frames (XLFF) require T0.FDF = T0.XLF = 1 and T0.XTD = 0. The header consist of T0, T1 and T2.
22.5.3.7
RX descriptor
The RX descriptor definition for the RX FIFO is defined in table below. Only 4x32 bit are required to define an RX
descriptor. Hence the overall RX descriptor can be fetched with one burst. Some bit field elements are defined
in a separate table for the sake of simplicity.
Table 1043
RX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
0
[31]
VALID
SW/MH
Valid: The SW must set this bit to 0 to define an RX
descriptor is pointing to a valid data container. As
soon as the RX descriptor is executed the MH will set
this bit to 1 to indicate to the SW valid data written to
the S_MEM. In case the RX descriptor is fetched with
this bit set to 1 and interrupt RX_FQ_IRQ is triggered
to the system for the RX FIFO Queue having this non
valid descriptor.
The SW must clear this bit only when all the RX
message data attached have been read
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4194
v1.1
2025-06-26


Table 1043
(continued) RX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
[30]
HD
MH only
Message header: when set to 1 the RX descriptor is
defined as containing the header of the RX message.
Any other RX descriptor, if several descriptors are
used for the same RX message, will contain only
payload data. In Continuous Mode HD is always set
to 1 as only one RX descriptor is used per RX message
[29]
reserved
SW only
Must be set to 0
[28]
NEXT
MH only
Next: Set to 1 by the MH to indicate in the RX Header
descriptor that more than one descriptor is used for
the RX message. This information is only mentioned
in the Header Descriptor, the RX Trailing Descriptors
are not modified. This allows the SW to acknowledge
only the RX Header Descriptor for any RX messages.
In Continuous Mode NEXT is always set to 0 as only
one RX descriptor is used per RX message
[27]
IRQ
SW only
Interrupt: when set to 1, an interrupt is triggered
to the system when the descriptor execution is
complete and a correctly received RX message was
written to it. This interrupt can provide point to the
SW a synchronization point to monitor the RX FIFO
Queue execution
[26:25]
Not Used
SW only
Must be set to 0
[24:16]
CRC[8:0]
SW only
CRC: this CRC is computed by the SW for the
current RX descriptor. It must consider all elements
assuming this bit-field as set to 0. Any CRC error is
triggering an interrupt to the system. The CRC is not
evaluated if the Ni_MH_STS.RX_DESC_CRC_EN bit is
set to 0
[15:12]
FQN[3:0]
SW only
RX FIFO Queue number: define the RX FIFO Queue
number allocated to this RX descriptor
[11:9]
IN[2:0]
SW only
Instance Number: define the XCAN instance number
using that descriptor. This bit-field is relevant if
several XCAN are running concurrently. It provides
a way to detect descriptor fetch issue between
instances. The value defined must be equal to the
one defined in the Ni_MH_CFG.INST_NUM bit-field
register.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4195
v1.1
2025-06-26


Table 1043
(continued) RX descriptor description
Element
number
Bit-field
Name
Managed by
Description/Constraints
[8:4]
RC[4:0]
SW only
Rolling Counter: use to track the order of RX
descriptor fetched when an RX FIFO Queue is
running. When an RX FIFO Queue is started for the
first time, its first RX descriptor must have the RC[4:0]
set to 5’b00000. This value must be incremented for
every new RX descriptor up to 5’b11111 and then
back to 5’b00000. Even if a wrap occurs at to the
end of the RX FIFO Queue, there must be continuous.
Therefore, the First RX descriptor may have a RC[4:0]
different from 5’b00000.To have always RC[4:0] =
5’b00000 for the First RX descriptor, the RX FIFO
Queue size must be a multiple of 32 RX descriptor
size
[3:0]
STS[3:0]
MH only
Status: gives the status of the RX message received.
This bit-field is written back by the MH when the
descriptor has been completed. This bit-field must
be set to 0 by SW.
0000B: none
0001B: message received successfully
0010B: message received but not filtered
0011B to 1110B: reserved
1111B: message acknowledged with parity error
1
[31:0]
RX_AP
SW/MH
Normal Mode: the SW defines the address of the RX
data container to write RX data
Continuous Mode:
The SW must set this bit field to 0 as default value.
The MH writes this field with the address pointer to
find the RX message attached to the RX descriptor.
Only the RX Header Descriptor is having this bit field
updated, with the RX message address in the data
container.
This address must be 32 bit aligned, the two LSB bits
are assumed to be always 0
2
[31:0]
TS0[31:0]
MH only
Timestamp 0: LSB of the 64-bit timestamp of the
successfully received RX message (only valid when
HD bit is set to 1)
3
[31:0]
TS1[31:0]
MH only
Timestamp 1: MSB of the 64-bit timestamp of the
successfully received RX message (only valid when
HD bit is set to 1)
Here is the list of required elements for the various RX descriptor definition to be managed by the SW or the MH:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4196
v1.1
2025-06-26


Table 1044
Element managed by SW
 
SW to write information to MH
SW to read information from MH
Element
number
RX Descriptor
Header descriptor
Trailing descriptor
0
Mandatory
Mandatory
Mandatory in Normal
mode
1
Mandatory in Normal mode
NA in Continuous mode (must be set to 0)
Mandatory
Mandatory in Normal
mode
2
NA (must be set to 0)
Mandatory
NA (must be equal to
0)
3
NA (must be set to 0)
Mandatory
NA (must be equal to
0)
Table 1045
Element managed by MH
 
MH to write information to SW
MH to read information from SW
Element
number
Header descriptor
Trailing
descriptor
RX descriptor
0
Mandatory
Not updated
Mandatory
1
Not updated in Normal
mode
Mandatory in
Continuous mode
Not updated
Mandatory in Normal mode
NA in Continuous mode
2
Mandatory
Not updated
NA
3
Mandatory
Not updated
NA
When the Element´s content is mentioned as NA, the assumed default value must be 0.
22.5.3.7.1
CRC computation
A dedicated CRC is computed for every RX descriptor. When a CRC issue is detected, the DESC_ERR interrupt
signal is triggered (see safety measures section). This way the data transfer setting and description up to the
DMA engine are fully protected.
The CRC covers all the relevant data, meaning the 55 bits of data in the RX descriptor considering the CRC bit
field in the descriptor as equal to 9'b0. The CRC is part of the Element Number 0.
The CRC (CRC-9_167) is computed assuming the following elements in sequence:
Element Number 0[31:25] & 9'b0 & Element Number 0[15:0]
Element Number 1[31:0]
Note:
The Koopman representation of the polynomial CRC-9_167is used to protect RX descriptors:
CRC-9_167 = (x9+x7+x6+x3+x2+x+1) (CRC polynomial in implicit "+1" hex format, meaning the trailing
"+1" is omitted from the polynomial number)
Using the Ni_MH_SFTY_CTRL.RX_DESC_CRC_EN bit register, the SW can decide to disable this check for all the
RX descriptors fetched from S_MEM or L_MEM.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4197
v1.1
2025-06-26


22.5.3.7.2
RX Descriptor Errors
When an RX descriptor error is detected, the relevant information are logged in the Ni_DESC_ERR_INFO1
register. Furthermore, the source address of the faulty RX descriptor is logged in the Ni_DESC_ERR_INFO0
register. This would help the SW to identify potential root causes when such error occurs. The
Ni_DESC_ERR_INFO1.RX_TX bit register is set to 1 when an RX descriptor gets an error.
22.5.3.8
RX message header definition
Messages received from the CAN Bus are stored in the S_MEM, each consisting of a header followed by the
payload. The header data structure depends on the CAN Frame Format (Classical CAN, CAN FD, CAN XL) used for
this message on the CAN Bus. It can be identified by the header bits FDF and XLF. The following tables describe
the three data structures used for the headers, consisting of the words R0, R1 and R2.
Table 1046
Classical CAN RX header definition
Rn
Bits
Name
Source
Description/Constraints
R0
[31]
FDF
CAN
FD Format
[30]
XLF
CAN
XL Format
[29]
XTD
CAN
Extended Identifier
[28:18]
BaseID
[28:18]
CAN
Base ID
[17:0]
ExtID [17:0]
CAN
Extended ID
R1
[31:27]
Reserved
Not
applicable
Not Applicable
[26]
RTR
CAN
Remote Transmission Request
[25:20]
Reserved
Not
applicable
Not Applicable
[19:16]
DLC[3:0]
CAN
Data Length Code
[15:11]
Reserved
Not
Applicable
Not Applicable
[10]
FAB
MH
Filter Aborted: when set to 1, the RX filtering
process was ending before completing with no
match
[9]
BLK
MH
Black List: When set to 1, the RX message filtered
belongs to a black listed
[8]
FM
MH
Filter Match: When set to 1 one of the filter
element (defined by FIDX[7:0]) has detected a
match
[7:0]
FIDX[7:0]
MH
Filter index: provide the information of the filter
index which has been triggered
R2
[31:0]
Reserved
Not
Applicable
Not Applicable
Note:
Classical CAN frames (CBDF, CEDF, CBRF, CERF) can be identified by R0.FDF = R0.XLF = 0.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4198
v1.1
2025-06-26


Table 1047
CAN FD RX header definition
Rn
Bits
Name
Source
Description/Constraints
R0
[31]
FDF
CAN
FD Format
[30]
XLF
CAN
XL Format
[29]
XTD
CAN
Extended Identifier
[28:18]
BaseID
[28:18]
CAN
Base ID
[17:0]
ExtID [17:0]
CAN
Extended ID
R1
[31:26]
Reserved
Not
applicable
Not Applicable
[25]
BRS
CAN
Bit Rate Switch
[24:21]
Reserved
Not
applicable
Not Applicable
[20]
ESI
CAN
Error State Indicator
[19:16]
DLC[3:0]
CAN
Data Length Code
[15:11]
Reserved
Not
Applicable
Not Applicable
[10]
FAB
MH
Filter Aborted: when set to 1, the RX filtering
process was ending before completing with no
match
[9]
BLK
MH
Black List: When set to 1, the RX message filtered
belongs to a black listed
[8]
FM
MH
Filter Match: When set to 1 one of the filter
element (defined by FIDX[7:0]) has detected a
match
[7:0]
FIDX[7:0]
MH
Filter index: provide the information of the filter
index which has been triggered
R2
[31:0]
Reserved
Not
Applicable
Not Applicable
Note:
CAN FD frames (FBDF, FEDF) can be identified by R0.FDF = 1 and R0.XLF = 0.
Table 1048
CAN XL RX header definition
Rn
Bits
Name
Source
Description/Constraints
R0
[31]
FDF
CAN
FD Format
[30]
XLF
CAN
XL Format
[29]
Reserved
Not
Applicable
Not Applicable
[28:18]
Priority
ID[28:18]
CAN
Priority Identifier
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4199
v1.1
2025-06-26


Table 1048
(continued) CAN XL RX header definition
Rn
Bits
Name
Source
Description/Constraints
[17]
RRS
CAN
Remote Request Substitution
[16]
SEC
CAN
Simple Extended Content
[15:8]
VCID[7:0]
CAN
Virtual CAN Network ID
[7:0]
SDT[7:0]
CAN
SDU Type
R1
[31:27]
Reserved
Not
applicable
Not Applicable
[26:16]
DLC-XL[10:0]
CAN
Data Length Code with CAN XL encoding
[15:11]
Reserved
Not
Applicable
Not Applicable
[10]
FAB
MH
Filter Aborted: when set to 1, the RX filtering
process was ending before completing with no
match
[9]
BLK
MH
Black List: When set to 1, the RX message filtered
belongs to a black listed
[8]
FM
MH
Filter Match: When set to 1 one of the filter
element (defined by FIDX[7:0]) has detected a
match
[7:0]
FIDX[7:0]
MH
Filter index: provide the information of the filter
index which has been triggered
R2
[31:0]
AF[31:0]
MH
Acceptance Field
Note:
CAN XL frames (XLFF) could be identified by R0.FDF = R0.XLF = 1.
22.5.3.9
TX message
For a better understanding while reading this chapter, read the TX descriptor chapter first.
A TX message is defined using one TX descriptor and a TX data container where the payload data buffer is
defined.
The Header Descriptor (or the only one, in case of one descriptor per message) holds the header data
information and for some CAN protocols, the data payload of the message. Such descriptor also provides some
additional information to the MH: the interrupt to be triggered, where to write acknowledge data, where to
fetch TX message data, etc.
A TX data container is a general term to name the memory space allocated by the SW. This data container is
used to hold the payload data buffer. In most of the cases, this TX data container would be identical to the data
buffer size to transmit, avoiding the loss of memory space.
A specific TX descriptor is used for the TX FIFO Queue and for the TX Priority Queue due to the structure of the
two different implementations.
In order to optimize the fetch of the TX descriptor as well as data payload, a maximum burst length of 8x32 bit is
used.
The buffer size which can be defined in a TX descriptor can go up to 2048 byte. This way, a TX message can be
defined using a single TX descriptor and one data buffer.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4200
v1.1
2025-06-26


As the maximum efficiency is reached when using the maximum burst length, it is highly recommended to
define a data buffer size aligned on the maximum burst length.
If the TX payload data is not a multiple of the burst length, the remaining data in the data container won’t be
read. Nevertheless, the embedded DMA_CONTROLLER will use the maximum burst length to read the payload
whenever possible and will adapt the latest burst length to complete its transfer. Only the relevant data are
read from S_MEM when smaller than the maximum burst length.
The address pointer used to fetch the payload data is always 32 bit, despite that payload data is byte aligned.
Every TX descriptor holding the header of the TX message, once a TX message is transmitted, is acknowledged
for status, error reporting and timestamping.
Here below are the different types of messages according to CAN protocols.
Related information
TX descriptor on page 4187
22.5.3.9.1
Single TX descriptor usage
A TX message can be defined using one single TX descriptor. This kind of choice requires to have the complete
payload data defined in one data container in the S_MEM. In case of Classical CAN, the complete Classical CAN
message is embedded in the TX descriptor. This means no payload buffer is required for Classical CAN
messages. The NEXT bit in TX descriptor must be set to 0. In case of a TX Priority Queue, the TX descriptor TDO
bit field must be set to 0. For the TX FIFO Queues, the NHDO is set to a value equal to 1 in order to define the
next TX header descriptor.
For the TX Priority Queue and TX FIFO Queue the same description below applies.
Classical CAN with up to 8 bytes payload
As the Classical CAN payload data is only 8 bytes, it can be defined completely in the TX descriptor (see TD0 and
TD1 in chapter TX descriptor). There is no need to define an address pointer to a payload buffer in that case.
Despite a data container is mentioned, it is not used. This is to align with the other description in the next
sections.
This approach provides a single and simple way to send any Classical CAN TX message in a straight forward
manner. Using the T0, T1, TD0 and TD1 in the TX descriptor, the overall Classical CAN message can be defined,
refer to the TX descriptor chapter for more details.
TX Data Container
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TD1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
TX Descriptor
TD0
TD1
Buffer
Figure 399
Classical CAN TX message with 8 bytes payload (single descriptor)
CAN FD
As the CAN FD protocol can provide up to 64 bytes, it is mandatory to define an address pointer to read the
payload data from the S_MEM when the size is greater than 4 bytes. The first payload data defined in the
payload data buffer also needs to be defined in the TX descriptor. For high latency system, the time to fetch the
payload data, once the arbitration process is complete, can lead to a potential under-run. To solve this issue,
TD0 is declared in the TX descriptor. By the time TD0 is sent through the CAN bus, the payload data will be read
from the S_MEM. This approach avoids pre-fetching the payload data before having the arbitration result and to
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4201
v1.1
2025-06-26


throw away the complete burst when arbitration is not successful. The TD0 from the first read burst access will
then be skipped.
The address pointer points to the buffer holding the overall payload data as depicted in figure below. In case
only 4-byte payload data is required, there would be no need to define the address pointer (must be set to 0).
For payload data above 4 bytes an address pointer is required. The minimum data container size is either 32
bytes (data payload lower or equal to 32 bytes) or 64 bytes (data payload greater than 32 bytes).
The size of the buffer to be fetched is always 32 bit aligned. When the data payload is lower than a multiple of
32 bits, padding is expected and will be discarded by the PRT.
Using the T0, T1, TD0 and the TX_AP fields, the overall CAN FD TX message can be defined, refer to the TX
descriptor chapter for more details
TX Data Container
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP  
Element 2: TS0
Element 3: TS1
Element 0
Element 1
TD2
TD3
TD15
TDm-1
Buffer
TX Descriptor
TD0
TD1
Figure 400
CAN FD TX message with more than 4 byte payload (single descriptor)
CAN XL
As the CAN XL header information requires 3 words of 32 bits, there is no payload data defined in the TX
descriptor. T2 is required only when the arbitration on the CAN bus is successful, giving time for the MH to read
the payload data from the S_MEM and to avoid the need of prefetching data.
Using the T0, T1, T2 and the TX_AP fields, the overall CAN XL TX message can be defined, refer to the TX
descriptor chapter for more details.
The size of the buffer to be fetched is always 32 bit aligned. When the data payload is lower than a multiple of
32 bits, padding is expected and will be discarded by the PRT.
TX Data Container
Element 4: T0
Element 5: T1
Element 6: T2
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TX_AP  
TD0
TD1
TD2
TD3
TDn-1
TX Descriptor
Buffer
Figure 401
CAN XL TX message (single descriptor)
Related information
TX descriptor on page 4187
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4202
v1.1
2025-06-26


22.5.3.10
RX message in normal mode
In order to receive RX messages, an RX descriptor is required to define how the MH must behave and where to
write the RX data in Normal mode.
Those RX descriptors are attached to RX FIFO Queues which are selected according to the RX filtering rules. It
means, RX descriptors are concatenated and read in sequence.
An RX data container is a general term to name the memory space allocated by the SW. This data container is
used to hold the RX message data. In most of the cases, this RX data container would not be fully filled with
data, maximum data payload being different for CAN protocols.
Every RX descriptor is assigned to a data container to write incoming data to the S_MEM. The RX data container
size is a multiple of the maximum burst length supported, 8x32 bit with a maximum of 4064 bytes (127*32
bytes) and a minimum of 32 bytes. This granularity does provide some flexibility to address several RX message
size with only one data container. As defined previously, if an RX data container is smaller than an RX message,
several RX descriptors will be assigned to that message.
Compared to the TX message, the header and the payload of the RX message are written together to the
S_MEM. This approach gives the flexibility to pass address pointers of the overall message to the application
and to avoid copies.
If the payload data does not cover a multiple of the burst length, some data won’t be written to the data buffer
in the container. The embedded DMA_CONTROLLER will use the maximum burst length whenever possible to
write header and payload and will adapt the latest burst length to complete its transfer.
The address pointer used to write the RX message is always 32 bit aligned despite payload data is byte aligned.
The size of the data container defined into the RX descriptor is fixed for a given RX FIFO Queue and for all the RX
descriptors of that queue. The smaller the size of data buffer the less RX descriptors a message would require.
As the data container is defined anywhere into the S_MEM, the SW can decide to allocate all the data containers
into a continuous way in the S_MEM to ensure, the RX message is not split over several location. It will ease the
reading of RX messages and simplify the management of data buffers, see RX FIFO Queue chapter for more
details.
The NEXT bit defined into the RX Header Descriptor provides the information to the SW that one or several RX
descriptors are used. On top of it, the RX Header Descriptor of an RX message will have the HD bit set to 1 to
indicate that the data container got the header of the message.
Only the RX Header Descriptor holding the header data is acknowledged when an RX message is received. This
way, despite receiving the timestamp at the end of the data received, it will be written with the header and
status reporting.
Here below are the different types of RX messages according to the CAN protocol and some different structures
when using one or several RX descriptors.
Related information
RX FIFO queue in normal mode on page 4217
22.5.3.10.1
Single RX descriptor
With such structure the size of the data container defined by the RX descriptor must be large enough to hold the
maximum payload size of the expected RX message to receive.
Classical CAN
As depicted in the following figure, the Classical CAN header and payload data can be directly written into a 32
bytes data container ( N = 1 ). If such data buffer size is defined then several RX descriptors would be required
to support CAN FD (3 RX descriptors) or CAN XL (65 RX descriptors) frame size. It is important to note that
according to the RX message type received, the whole message may be written into a bigger data container as
every RX FIFO Queue is defining its own data container size.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4203
v1.1
2025-06-26


RX Data Container
(N * 32byte)
R0
R1
RD0
RD1
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor
Buffer
Figure 402
Classical CAN RX message (single descriptor)
CAN FD
Compared to Classical CAN, a larger data buffer is required to hold up to 64 bytes of payload data and the
header message data. In this case a data container of 96 bytes ( N = 3 ) is allocated to support CAN FD frame
format. There will be no issue regarding Classical CAN message as it would fit entirely into the same data
container. Doing so, the CAN XL message can be supported but would require up to 22 RX descriptors.
RX Data Container
(N * 32byte)
R0
Buffer
R1
RD0
RD1
RDn-1
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor
Figure 403
CAN FD RX message (single descriptor)
CAN XL
To ensure only one RX descriptor is pointing to one RX message a data container size of more than 2048 bytes is
required ( N = 65 ). With this setting, all the different CAN protocols are covered with a single data container
per RX descriptor. However, quite some memory space is lost in the data container (when configure to support
CAN XL payload size) when receiving Classical CAN or CAN FD messages. To solve this issue, multiple RX
descriptors can be used, see next chapter.
RX Data Container
(N * 32byte)
Buffer
RD0
R2
R1
R0
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor
RD1
RDn-1
Figure 404
CAN XL RX message (single descriptor)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4204
v1.1
2025-06-26


22.5.3.10.2
Multiple RX descriptors
To optimize the memory usage, regardless of the payload size of the RX message received, several RX
descriptors can be assigned to one RX message. Doing so, the RX message is written in several data containers.
When one is full, the RX message data is going to the next one. As depicted in the figure below, for a given size of
data container (constant per RX FIFO Queue), the RX message can be written anywhere into the S_MEM. The MH
takes care of filling the right data container with the RX message data whenever required. As a fixed memory
allocation is defined per RX descriptor, the RX message data may be spread over several data containers and RX
descriptors (depends on RX message payload data).
The figure below shows three RX descriptors and their assigned data container to hold the entire RX message. If
a data container has a size of 96 bytes (N=3) and a CAN XL message payload of 270 bytes is received, then the RX
message is depicted in figure below. Although the CAN XL message, in this example, is split over several RX
descriptors, this configuration allows to support Classical CAN and CAN FD with only one RX descriptor.
RX Data Container
(N * 32byte)
RX Data Container
(N * 32byte)
RX Data Container
(N * 32byte)
R0
R1
R2
RD0
RD1
RD31
RD30
RD29
RD28
RD32
RDm
Buffer
buffer
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor 
0
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX Descriptor 
1
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX Descriptor 
2
CAN RDn-1
RDm+3
RDm+2
RDm+1
Buffer
Figure 405
RX message (multiple descriptors)
22.5.3.11
RX message in continuous mode
For a better understanding of this section please read the RX Message in Normal mode chapter.
In the Continuous mode, the RX messages, instead of being split over several data container (see RX Message in
Normal mode chapter), are merged in the same big data container one after the other. As depicted below only a
single data container is defined per RX FIFO Queue and one RX descriptor is used per RX message.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4205
v1.1
2025-06-26


RX Data Container
(N * 32byte)
R0
R1
R2
RD0
RD1
RD31
RD30
RD29
RD28
RD32
RDm
Buffer
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor 
0
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor 
1
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor 
2
CAN RDn-1
RDm+3
RDm+2
RDm+1
R0
Buffer
R1
RD0
RD1
RDn-1
R0
R1
RD0
RD1
Buffer
Figure 406
RX message (continuous mode)
The Continuous mode makes use of the already defined RX descriptor list to support the SW management of RX
messages, see RX message Normal mode for more details.
It is important to note that the Continuous mode applies to all RX FIFO Queues when set. There is no option to
make it available only to some queues.
The RX descriptors are attached to a defined RX FIFO Queue. The RX FIFO Queue, to write the RX message, is
defined according to the RX filtering rules, see RX Filter chapter for more details. Once the RX FIFO Queue is
identified, the latest RX descriptor (meaning the current one) is fetched from S_MEM. As the RX descriptors in a
given FIFO Queue are concatenated, they will be read in sequence up to the end of the RX message.
Every RX descriptor is assigned to only one RX message in this large data container. This data container size is a
multiple of the maximum burst lengths supported, 8x32 bit with a maximum of 131040 bytes (4095*32 byte)
and a minimum of 32 bytes. Every RX FIFO Queue has its own data container (defined by a start address and a
size).
The header and the payload of the RX message are written one after the other to the S_MEM. This approach
gives the advantage to have the complete RX message data available in one place in the S_MEM. A copy of the
RX message in the S_MEM can then be easily defined by a start address and a size.
Whenever it is possible, the embedded DMA_CONTROLLER uses the maximum burst length to write header and
payload data and will adapt the latest burst length to complete its transfer.
The address pointer, used to write the RX message, is always 32 bit aligned despite payload data is byte aligned.
The data container is defined anywhere in the S_MEM. Being defined as a 32 bit address pointer, it can be
defined in a 4 Gbyte memory area.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4206
v1.1
2025-06-26


The NEXT bit defined in the RX Descriptor will never be set, as only one RX Descriptor is used per RX message.
The RX Descriptor pointing to the RX message has the HD bit set to 1 as it is a Header Descriptor. No Trailing
Descriptors are used for such mode, only one RX descriptor is required and it is a Header Descriptor.
Only the RX Header Descriptor holding the header data is acknowledged when an RX message is received,
considering the Normal mode. The same applies for the Continuous mode, see RX message in Normal mode
chapter for more details.
Compared to the Normal mode, there is no tradeoff to consider regarding the different CAN protocol payload
data size. As the RX messages are written in a row, no loss of memory is expected in the data container assigned
to an RX FIFO Queue.
This mode will also ensure that RX data are always linearly and continuously written in the S_MEM. At the
beginning of the reception of an RX message header, a check is performed to ensure the RX data to be received
can fit entirely in the data container. As the RX message cannot be written at the bottom and at the top of the
data container, the MH will go to the start address of the data container before writing the first data. This would
provide to the SW an easy way to perform memory copy, as one start address and a size can define the overall
RX message.
22.5.3.12
Descriptor acknowledgement
For the TX and RX paths, the MH is providing data information back to the RX and TX Header Descriptor.
To do so, some place holders are defined in the RX and TX descriptors for the MH to write RX and TX message
status, timestamping and error reporting.
As the CAN bus is not a full duplex interface, there should not be any collision on the acknowledge of RX and TX
descriptors, with the exception of the PRT when in loopback mode. In such mode, all TX messages transmitted
by the MH are send back by the PRT to the MH, refer to the PRT chapter for detailed description of the loopback.
The process of acknowledgment is completely separated from the reception or transmission of a CAN frame, a
dedicated DMA channel is reserved for such purpose.
22.5.3.12.1
RX descriptor
For the RX path, one or several RX descriptors can be used to hold the complete RX message. Once an RX
message is received successfully, an acknowledgement is written back to the Header Descriptor when the
message is completed. If several descriptors are used per message (Trailing Descriptors), they are not changed
by the MH. If the data container assigned to the RX descriptor is sized in such a way that any RX message can fit
in entirely, then every RX descriptor (in fact Header descriptors in that case) will be acknowledged.
If several RX descriptors are used to store the RX message and an issue occurs while processing the message, all
RX descriptors already used are then released for the next RX message.
Here below is the list of bit fields used by the MH to provide the acknowledgement information to the RX
Header descriptor, see RX Descriptor chapter for details:
•
VALID: The MH expects this bit to be set to 0 by the SW to ensure the data container is ready to be written
again. This bit is written by the MH to 1, when an RX message is received successfully and the data are
available in S_MEM. It is true only for the RX descriptor holding the RX message header data
•
TS0[31:0] and TS1[31:0]: The MH writes the 64-bit timestamp (TS0 and TS1) in the RX descriptor when the
RX message data is received successfully. Only the RX descriptor holding the data will have this bit-field
updated
•
NEXT: As soon as more than one RX descriptor is required for an RX message, the MH is setting this bit to 1
to indicate to the SW, more descriptors are used for this RX message. Only the RX Header descriptor will
have this bit-field updated. The trailing descriptors are not updated. When in Continuous mode this bit will
always be 0
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4207
v1.1
2025-06-26


•
HD: In case several RX descriptors are used to define an RX message, the MH is setting this bit to 1 to
identify which descriptor has the message header embedded into its data buffer
•
STS[3:0]: This bit-field gets updated by the MH for any usage of RX descriptor. It provides information on the
status of the RX message and on any related issue while RX FIFO Queues are running
22.5.3.12.2
TX descriptor
For the TX path, once a TX message is processed, the TX Header Descriptor is written back with the relevant
information. The list of conditions to trigger an acknowledge is defined below:
•
Message sent successfully
•
Message rejected by the TX filter (see TX Filter chapter)
•
Message discarded after several retransmission
•
Message rejected by the PRT (see HFI codeword in PRT chapter)
Here below are the list of bit-field used by the MH to provide the acknowledgment information to the TX
descriptor, see TX Descriptor chapter for details:
•
VALID: The MH expects this bit to be set to 1 by SW to ensure the data buffer is ready to be sent, only the TX
descriptors having this bit set to 1 are accepted and executed. This rule applies for every TX descriptor with
or without the header data (when TX message is split over several descriptors). When the last data defined
by this TX descriptor has been sent over the CAN bus, it will be set back to 0 by the MH only to the TX
descriptor holding the header data
•
TS0[31:0] and TS1[31:0]: When the TX message data is sent successfully a 64-bit timestamp is written back
into to the TX descriptor holding the header data
•
STS[3:0]: This bit-field gets updated by the MH for any usage of TX descriptor. It provides information on the
status of the TX message and on any related issue while TX FIFO Queues are running
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4208
v1.1
2025-06-26


22.5.3.13
TX FIFO queue
TX FIFO QUEUE
TX Data Container
TX Data Container
TX Data Container
Descriptors Link List
PROCESSED IN ORDER
TX Data Container
Element 4: T0
Element 5: T1
Element 6: T2
Element 4: Not used
Element 5: Not used
Element 6: Not used
Element 7: TX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 2: Not used
Element 3: Not used
Element 0
Element 1
Element 7: TX_AP
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Tx link list start 
address register
TD2
TD3
TD6
TD15
TDi-1
TD2
TD3
TD4
TD5
Buffer
TX Descriptor 0
TX Descriptor 1
TX Descriptor n-1
TD2
TD3
TDj-1
TD0
TD1
TD
TD1
TD0
TD1
TD16
Container: 
Linear memory 
space assigned 
to one descriptor
Buffer: 
Linear memory space 
used by a descriptor
Head Descriptor: 
Descriptor holding the header of the TX 
message
First Descriptor: 
Descriptor defined by the TX FIFO Queue 
start address
Current Descriptor: 
Descriptor executed by the MH
Next Descriptor: 
Descriptor to be used as next in 
the current TX FIFO Queue
Last Descriptor: 
The last descriptor defined into 
the TX FIFO Queue
Buffer
Buffer
Element 4: T0
Element 5: T1
Element 6: TD0
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TD1
TX Descriptor n
TD0
TD1
Buffer
Element 4: T0
Element 5: T1
Element 6: TD0
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TD1
TX Descriptor n+1
Not Defined
CAN-FD TX Message
Classic CAN TX Message
CAN-XL TX Message
CAN-FD TX Message
Figure 407
TX FIFO queue description
Up to 8 TX FIFO Queues can be defined and managed by the MH.
When the SW wants to configure N TX FIFO Queues, only the queue number from 0 to N-1 can be used.
A TX FIFO Queue is a list of TX messages to be sent in order to the PRT.
Each one being fully independent from the others, the SW can declare and add new messages to any of the
FIFO Queue without stopping the execution of the others or the current one. In this sense, the TX FIFO Queues
can be enabled or disabled individually. An abort mechanism is provided to stop and flush each TX FIFO Queue
individually.
Prior to launch any TX FIFO Queue, the MH must be started (Ni_MH_CTRL.START written to 1 will drive the
Ni_MH_STS.BUSY bit status to 1). To start the TX FIFO Queue n, write 1 to the Ni_TX_FQ_CTRL0.START[n]. Before
launching a TX FIFO Queue n, it must be enabled by setting the Ni_TX_FQ_CTRL2.ENABLE[n] bit to 1. Once
enabled and started, there is no way to disable it while it is running without a defined procedure. Instead, the
abort bit Ni_TX_FQ_CTRL1.ABORT[n] provides a way to stop a TX FIFO Queue n running and to ensure a safe
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4209
v1.1
2025-06-26


stop and flush of ongoing data. For more detail on starting and stopping TX FIFO Queues, refer to the
Application Information chapter.
To ensure no dead lock can occur at start, the ENABLE signal from the PRT must be set to high to allow any TX
FIFO Queue to start. This signal status can be monitored in the Ni_MH_STS.ENABLE bit field.
There is also nothing preventing the SW to declare and run a TX FIFO Queue with a defined list of TX messages,
assuming an interrupt at the end of the TX FIFO Queue execution.
However, the TX FIFO Queue can be used as a circular buffer when the Last Descriptor defines a wrap to the
First Descriptor (WRAP bit set to 1 in TX descriptor). Doing so, the SW can add new messages in an endless
manner over time.
The mechanism, used to manage TX FIFO Queues, is based on the concept of linked list. Any TX FIFO Queue is
defined using a linked list of TX descriptors and data buffers to read TX message payload from the S_MEM.
A linked list is made of descriptors, where a descriptor is defined by several data elements of the same size, the
element is a 32-bit word. Each element provides some information or would define some actions to perform. A
descriptor is built by the SW but will be read and executed by the MH.
Every TX descriptor is of the same size, pointing to a data buffer and also to the next descriptor, as depicted in
the figure above. The TX descriptors are continuous in memory (to ease and simplify implementation).
Therefore, it is not required to declare or use a bit field to mention the position of the next descriptor as it is
implicit.
The linked list is started by fetching the First Descriptor in the list, once it is fully read, it is executed and the
data buffer assigned to it, is read. Other actions can be defined into the element data like triggering an
interrupt or setting a flag. The linked list is processed one descriptor at a time, once a descriptor is completed,
the next one is fetched into the list and the process repeats itself. The process keeps going up to the Last
Descriptor of the link list and from this point in, may end or may wrap to the first descriptor in a circular buffer
mode.
Every TX FIFO Queue defines its own order of TX messages to be send to the CAN bus, but as several queues are
running concurrently, an arbitration process is performed between queues to select the highest priority
message. Every TX message is filtered to ensure only the required ones can be sent. The SW builds those queues
with messages and the MH takes care of sending them whenever appropriate.
For the TX FIFO Queues, data buffers hold the payload data of the TX message while the descriptor defines
header information. In some cases, the first payload data may also be part of the Head Descriptor.
To give a status report and some information like timestamping, the MH is also able to write back some
elements in the TX descriptors. Not all of them are written back but only the one having the Header Descriptor
data are updated.
It is possible to wrap at the top of the TX FIFO Queue any time but with the following constraints:
•
The WRAP bit must be set in the Header Descriptor to identify where is the next TX message
The descriptors are mainly defined on SRAM as they drive the actions to be taken. Nothing prevents the SW to
declare and use the E_MEM instead but it can slow down the execution and may create real time issues.
However, the data buffers can be either in E_MEM, which is usually the case, or in SRAM. As a matter of fact, if
the next descriptor cannot be fetched before the relevant data are fully read or written, the link list execution
speed would depend on the data access time. To solve this issue, read prefetchings are performed to hide the
system latency whenever possible.
TX Data Containers can be defined at any location in S_MEM. But for performance reason and to optimize the
burst access, it is highly recommended to have the TX buffer 32 byte aligned. Those containers are considered
as memory space that is allocated by the Memory Management Unit to store buffer. Once a message is sent, the
container can be de-allocated, so the memory space is released for further usage.
As soon as the TX FIFO Queue is started, the MH will fetch the First Descriptor and store it to L_MEM. When the
TX descriptor is available in L_MEM, it will be part of the arbitration process. As long as the TX message defined
by this TX descriptor is not sent to the CAN bus, it will remain for all the arbitration runs. When it is sent
successfully, the next TX descriptor of that TX FIFO Queue is fetched automatically.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4210
v1.1
2025-06-26


The MH will proceed with all TX FIFO Queues in the same way. As the TX message to be sent is based on its
priority, the TX FIFO Queues will run at a different rate up to the point that all TX messages are sent successfully.
If the Last Descriptor of a TX FIFO Queue sets the END bit, the MH will end the FIFO execution as soon as the TX
message defined is transmitted successfully on the CAN bus and the TX descriptor acknowledge is written to
the S_MEM.
Up to 1023 TX descriptors can be defined for a TX FIFO Queue. When the maximum number of TX descriptor
defined for a TX FIFO Queue is reached, the MH wraps automatically to its initial start address to fetch the next
TX descriptor. Despite this default behavior, it is still possible at any time for the SW to mention a wrap using
the WRAP bit in the Header Descriptor.
When the END bit is not set for the last TX descriptor, the TX FIFO Queue is considered as endless and any new
TX descriptor can be appended to the already defined last descriptor. To allow such way of working, the last
descriptor must always be not valid (VALID bit set to 0). This is very important as the detection of the non-valid
TX descriptor triggers an interrupt to the system to declare that the TX FIFO Queue is stopped. It would then be
up to the SW to append a new TX descriptor and restart the TX FIFO Queue.
If for some reasons a TX FIFO Queue has an error, it is still possible to abort the execution of that TX FIFO Queue.
When such action is performed, the TX FIFO Queue will be considered as active as long as the current data
transfer assigned to a TX descriptor is not finished. This means, the TX descriptor is not considered for the
arbitration anymore, so no more fetches are done and the TX FIFO Queue is set inactive.
Any safety issue related to a TX descriptor executed by a TX FIFO Queue will stop it right away. The TX FIFO
Queue is declared as no more valid and is stopped. To identify such issue, some interrupts are triggered to the
system, TX_CRC_ERR and TX_SFTY_STS. Despite that the faulty TX FIFO queue is stopped, the others will keep
going.
If a message has reached maximum number of retransmission or has declared an invalid header format, the
message is skipped and the next one in the TX FIFO Queue is considered instead. The error mentioning such
skip is written back to the report status bit field in the TX Header Descriptor.
In a context where a TX descriptor provides the definition of one TX message, the next TX message is the next TX
descriptor, an offset of 1 (1x32byte) is required.
A TX FIFO Queue is controlled and monitored using several registers and bit registers:
•
The Ni_TX_FQ_START_ADD{n} (where n is 0-7) register to define the start address of the TX FIFO Queue n
•
The Ni_TX_FQ_CTRL0.START[n] (where n is 0-7) register to launch the TX FIFO Queue n
•
The Ni_TX_FQ_SIZE{n} (where n is 0-7) register to define the maximum number of TX descriptor for the TX
FIFO Queue n before looping back to the initial start address
•
The Ni_TX_FQ_ADD_PT{n} (where n is 0-7) register to monitor the current address pointer of the TX FIFO
Queue n
•
The Ni_TX_DESC_ADD_PT register to monitor the current address pointer
•
The Ni_TX_FQ_CTRL1.ABORT[n] (where n is 0-7) bit register to abort the execution of the TX FIFO Queue n
•
The Ni_TX_FQ_CTRL2.ENABLE[n] (where n is 0-7) bit register to enable the TX FIFO Queue n prior to use it
•
The Ni_TX_FQ_INT_STS.SENT[n] and Ni_TX_FQ_INT_STS.UNVALID[n] (where n is 0-7) bit registers to
identify respectively, a message is transmitted and an invalid TX descriptor is detected
•
The Ni_TX_FQ_STS0.BUSY[n] and Ni_TX_FQ_STS.STOP[n] (where n is 0-7}) bit registers to know
respectively, the status of the TX FIFO Queue n, busy (TX FIFO Queue is active) and stopped or running
•
The Ni_TX_FQ_STS1.ERROR[n] and Ni_TX_FQ_STS.UNVALID[n] (where n is 0-7) bit registers to identify the
root cause of the TX FIFO Queue being stopped, an error is detected or an invalid TX descriptor is detected
A TX FIFO Queue is being controlled for any issue using common bit registers when receiving interrupts:
•
The Ni_SFTY_INT_STS.TX_DESC_CRC_ERR and Ni_SFTY_INT_STS.TX_DESC_REQ_ERR bit registers to
identify respectively, any CRC issue on TX descriptor running in the TX FIFO Queue n and non-expected TX
descriptor
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4211
v1.1
2025-06-26


•
The Ni_ERR_INT_STS.DP_TX_ACK_DO_ERR bit register to identify overflow on TX ACK data path for the TX
FIFO Queues
•
The Ni_ERR_INT_STS.DP_TX_SEQ_ERR bit register to identify if an issue occurs on the TX_MSG interface
22.5.3.13.1
Basic mode
The SW defines one TX descriptor per TX message payload data. Thus, a TX message would be:
•
One TX descriptor to provide the complete header information
•
One TX data container to hold the complete TX message payload data (only required for CAN FD and CAN
XL when payload data is over 8 bytes)
Data containers holding the TX payload buffer can be declared anywhere in the S_MEM despite being attached
to only one TX descriptor, as depicted in the following figure.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4212
v1.1
2025-06-26


TX FIFO QUEUE
TX Data Container
TX Data Container
Descriptors Link List
PROCESSED IN ORDER
TX Data Container
Element 4: T0
Element 5: T1
Element 6: T2
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TX_AP
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Tx link list start 
address register
TD2
TD3
TD6
TD15
TDi-1
TD2
TD3
TD4
TD5
Buffer
TX Descriptor 0
TX Descriptor 1
TX Descriptor n-1
TD0
TD1
TD0
TD1
TD16
Element 4: T0
Element 5: T1
Element 6: TD0
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TD1
TX Descriptor n
TD0
TD1
Buffer
TDi+2
TDi+3
TDi+m-1
TDi
TDi+1
Buffer
Element 4: T0
Element 5: T1
Element 6: TD0
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TD1
TX Descriptor n+1
CAN-FD TX Message
Classic CAN TX Message
CAN-XL TX Message
Figure 408
TX FIFO Queue (Basic Mode)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4213
v1.1
2025-06-26


This approach does provide less constraints on system as only one TX descriptor needs to be fetched per TX
message. It would be much more efficient in term of performances and memory allocation regarding linked list
descriptors.
The only constraint for such configuration would be the memory space allocated to the payload data. As the
CAN XL can support up to 2048 bytes, the size of the data container to hold the complete payload could be quite
large.
22.5.3.14
TX priority queue
TX PRIORITY QUEUE
TX Data Container
(multiple of 32byte)
TX Data Container
(multiple of 32byte)
TX Data Container
(multiple of 32byte)
Descriptor Slots
(Up to 32)
TD0
TD1
TD2
TD3
TDm-1
TD2
TD3
TD15
TDm-1
Buffer
TD0
TD1
TD0
TD1
Buffer
PROCESSED IN ANY ORDER
Element 4: T0
Element 5: T1
Element 6: T2
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TD1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TX_AP
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1
TX Descriptor
SLOT 0
TX Descriptor
SLOT 1
TX Descriptor
SLOT 31
TX Priority Queue 
start address register
Container: 
Linear memory 
space assigned to 
one descriptor
Buffer: 
Linear memory space 
used by a descriptor
Head Descriptor: 
Descriptor holding the header of the TX 
message
Current Descriptor: 
Descriptor executed by the MH
Buffer
CAN-FD TX Message
Classic CAN TX Message
CAN-XL TX Message
Figure 409
TX priority queue description
This kind of queue does not behave as the TX FIFO Queue but the way messages are defined and how the MH is
reading the descriptor are identical.
A TX Priority Queue can be configured with a maximum of 32 slots.
When the SW wants to configure N TX Priority Queue slots, only the slot number from 0 to N-1 can be used.
Every slot is assigned one TX message from a SW point of view. Every slot can be enabled/disabled individually
leaving the option to define any number of active slot or none in the SW. Compared to the TX FIFO Queue, there
is no order of execution. Any message defined in the TX Priority queue can be selected and executed in any
order, only the highest priority message is selected first. Those messages are evaluated against the one
currently in use in all TX FIFO Queues.
The same principle is used to define a TX message, meaning some TX descriptors and TX data buffers to define a
message. Like the TX FIFO Queues, data buffers hold the payload data of the TX message while descriptor
defines header information. In some cases, the first payload data may also be part of the descriptor.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4214
v1.1
2025-06-26


To give a status report and some information like timestamping, the MH writes back some bit field in the TX
Header Descriptor. This way the SW is able to track back TX messages sent and identify those with issues.
The TX Priority Queue is using the same data path as the one defined and implemented for the TX FIFO Queue.
The main difference between the two queues is:
•
The Priority Queue is managed in any order. As soon as a slot over the 32 is available, a new message can
be defined
•
The SW needs to trigger the MH to consider a new message in a slot
•
The SW needs to read status register to identify which message has been sent
Prior to launch any TX Priority Queue slot, the MH must be started (Ni_MH_CTRL.START written to 1 will drive
the Ni_MH_STS.BUSY bit status to 1). To start the TX Priority Queue slot n, write 1 to the
Ni_TX_PQ_CTRL0.START[n]. Before launching a TX Priority Queue slot n, it must be enabled by setting the
Ni_TX_PQ_CTRL2.ENABLE[n] bit to 1. Once enabled and started, there is no way to disable it while running
without a defined procedure. Instead, the abort bit Ni_TX_PQ_CTRL1.ABORT[n] provides a way to stop a TX
Priority Queue slot n running and to ensure a safe stop and flush of ongoing data. For more detail on starting
and stopping TX Priority Queue slots, refer to the Application Information chapter.
To ensure that no dead lock can occur at start, the ENABLE signal from the PRT must be high to allow any TX
Priority Queue to start. This signal status can be monitored in the Ni_MH_STS.ENABLE bit field.
As soon as one or several slots of the TX Priority Queue are started, the MH will fetch the relevant TX descriptors
defined at those locations and stores them in L_MEM. When the TX descriptors are available in the L_MEM, they
will be part of the arbitration process. As long as the TX messages defined by those TX descriptors are not sent
to the CAN bus, they will remain for all the arbitration runs. It is important to note the TX FIFO Queue's
messages are also part of this arbitration process.
When the TX message is sent successfully, the TX Priority Queue slot is released and set inactive. A TX_PQ_IRQ
interrupt can be triggered to the SW when the last data of the TX message is sent. The other option would be to
poll the corresponding status bit register, to identify when the transfer has completed. This last approach
requires much more CPU time compare to the interrupt one.
As the TX message to select is based on an arbitration process, the TX Priority Queue execution will run at a
different rate compared to the TX FIFO Queues. If TX messages are defined into the TX Priority and have highest
priority they will go before TX FIFO Queues. The SW can add new messages at any time when a slot is available.
If for some reason a TX Priority Queue slot n needs to be stopped, it is still possible to abort the execution of
that slot. When such action is performed, the TX Priority Queue slot n will be considered as no more active. If
the TX message assigned to this slot is already in progress to the CAN bus or has been selected as the next
message to be sent, it will not be canceled. By using a register status, it is possible to identify if the slot aborted
has been done before or after the sending of the TX message.
Any safety issue related to a TX descriptor executed by a TX Priority Queue slot is declared as no more valid.
This means, it will not be part of the arbitration process with the other slots but will not prevent the others to
be executed. To identify such issue a TX_DESC_CRC_ERR is sent to the system. Despite this TX Priority Queue
slot is stopped, the others will keep going with their own TX descriptors.
If some message does not go through for the two following reasons, maximum number of restart reached or
invalid header format, the message is discarded. The error status being detected is written back to the TX
descriptor holding the header data.
There is a way to keep track of the TX descriptors used for a given TX FIFO Queue, refer to the Trace and Debug
chapter.
A TX Priority Queue is controlled and monitored using several registers and bit registers:
•
The Ni_TX_PQ_START_ADD register to define the start address of the TX Priority Queue
•
The Ni_TX_PQ_CTRL0.START[n] (where n is 0-31) bit register to launch the TX Priority Queue slot n
•
The Ni_TX_PQ_CTRL1.ABORT[n] (where n is 0-31) bit register to abort the execution of the TX Priority
Queue slot n
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4215
v1.1
2025-06-26


•
The Ni_TX_PQ_CTRL2.ENABLE[n] (where n is 0-31) bit register to enable the TX Priority Queue slot n prior to
use it
•
The Ni_TX_DESC_ADD_PT register to monitor the current address pointer
•
The Ni_TX_PQ_STS0.BUSY[n] (where n is 0-31) bit register to know the status of the TX Priority Queue slot
n, either busy (TX Priority Queue Slot is having a TX message to send) or not busy (Slot is no more active for
reasons like message sent, safety issue, ...)
•
The Ni_TX_PQ_STS1.SENT[n] (where n is 0-31) bit register to know the status of the TX message assigned to
the TX Priority Queue slot n, either sent (TX message assigned to slot n is sent) or not sent (could be for
different reasons like safety issue, max retransmission counter reached, ...)
•
The Ni_TX_PQ_INT_STS0.SENT[n]/ Ni_TX_PQ_INT_STS1.SENT[n] and Ni_TX_PQ_INT_STS0.UNVALID[n]/
Ni_TX_PQ_INT_STS1.UNVALID[n] (where n is 0-31) bit register to identify respectively, a message is
transmitted or an invalid TX descriptor is detected
A TX Priority Queue is being controlled for any issue using common bit registers:
•
The Ni_SFTY_INT_STS.TX_DESC_CRC_ERR and Ni_SFTY_INT_STS.TX_DESC_REQ_ERR bit registers to
identify respectively, any CRC issue on TX descriptor running in the TX FIFO Queue n and non-expected TX
descriptor
•
The Ni_ERR_INT_STS.DP_TX_ACK_DO_ERR bit register to identify overflow on TX ACK data path for the TX
FIFO Queues
•
The Ni_ERR_INT_STS.DP_TX_SEQ_ERR bit register to identify if an issue occurs on the TX_MSG interface
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4216
v1.1
2025-06-26


22.5.3.15
RX FIFO queue in normal mode
RX FIFO QUEUE (Normal mode)
Descriptor Set: 
Group of one or more descriptors combined 
to provide storage for one RX message
The leading descriptor of the set is called the 
Head Descriptor and the other descriptors 
are called the Trailing Descriptors
Head Descriptor: 
Descriptor pointing to the RX data 
container holding the header data
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
R0
R1
RD0
RD2
RD1
RD2
Buffer
R0
R1
RD0
RD1
RDn-1
RD1
RD0
R2
R1
R0
Descriptors Link List
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 0
RX 
Descriptor 1
RX 
Descriptor n
PROCESSED IN ORDER
RDi
Buffer
Current Descriptor: 
Descriptor executed by the MH
Trailing Descriptor: 
Descriptor holding only payload buffer 
pointer  
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 2
Next Descriptor: 
Descriptor to be used as next in 
the current RX FIFO Queue
Last Descriptor: 
The last descriptor defined into 
the RX FIFO Queue
Data Container: 
Linear memory space 
assigned to one RX 
descriptor
The size defined is 
identical for all the RX 
data container of one 
RX FIFO Queue
First Descriptor: 
Descriptor defined by the RX FIFO Queue 
start address
RX Data Container
(N*32bytes)
RDi+3
RDi+2
RDi+1
RDm+i-1
Buffer: 
Linear memory 
space used by a RX 
descriptor in the 
data container
Buffer
Buffer
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 3
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 4
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 
n-1
RX data container size 
defined in register for the 
entire RX FIFO Queue
Descriptor link list start 
address defined in register
Descriptor link list size 
defined in register
RX Data Container
(N*32bytes)
R0
R1
RD0
RD1
Buffer
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 5
Figure 410
RX FIFO queue description
Up to 8 RX FIFO Queue can be defined and managed by the MH. An RX FIFO Queue is a list of RX descriptors
pointing to RX data container to store the RX messages received by the PRT.
The RX filtering rules, programmed by the SW, define if a message is rejected or accepted and in case it is which
RX FIFO Queue is receiving the message. If a message is rejected it will not appear in any of the FIFOs. Each one
being fully independent from the others, the MH appends new RX message as they arrive on the CAN Bus.
The mechanism to manage RX FIFO Queues is based on the concept of link list. Any RX FIFO Queue is defined
using a link list of RX descriptors and RX data container. Those containers are used to write the RX message data
to the S_MEM and have fix size over the entire RX FIFO Queue. A different size could be defined per RX FIFO
Queue but must always be a multiple of 32 byte.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4217
v1.1
2025-06-26


The size of the data container is programmable to store small or large RX message payload data, if required. Up
to Ni_RX_FQ_SIZE{n}.DC_SIZE[6:0] * 32byte data container size can be defined per RX descriptor in an RX FIFO
Queue n. As the size is programmable per RX FIFO Queue, it is then possible to limit the memory footprint
according to the expected message to be received.
A link list is made of descriptors, where a descriptor is defined by several data elements of the same size, the
element is 32 bit word. Each element provides some information or would define some actions to perform. A
descriptor is built by the SW but will be read and executed by the MH. Every descriptor is of the same size,
pointing to a data container and also to the next descriptor. The link between descriptor is just a fix offset, as
they are continuous in memory (to ease and simplify implementation). Therefore, it is not required to declare
or use a bit field to mention the position of the next descriptor as it is implicit (dashed lines). As data containers
have a fix size and the RX message received may change in size, several descriptors could be required.
As messages are received in a continuous way, the RX FIFO Queue are used in a circular buffer mode. This
means when the Last Descriptor is reach the MH will consider the First Descriptor as the next descriptor. The
Last Descriptor is defined by the size of the RX FIFO Queue and the start address of the RX FIFO Queue.
An RX filter in MH is used to accept or reject RX messages. If a message is accepted, it is then sent to a defined
RX FIFO Queue. The RX filter builds over time those queues with messages based on the filtering result. It is up
to the SW to read them in time.
The RX filter observes all the incoming RX messages to identify the right RX FIFO Queue. Once defined, the first
RX descriptor attached to the selected RX FIFO Queue is fetched and used to write the incoming data to the
S_MEM. As soon as the incoming RX data is increasing above the limit of the data buffer pointed by the current
RX descriptor a new one is fetched to keep going. This process repeats up to last RX data received.
The MH will proceed with all the RX FIFO Queues the same way. As the RX FIFO Queue selected depends on the
RX filtering result, the RX FIFO Queues will be fill up at a different rate.
Prior to launching any RX FIFO Queue, the MH must be started (Ni_MH_CTRL.START written to 1 will drive the
Ni_MH_STS.BUSY bit status to 1). To start the RX FIFO Queue n, write 1 to the Ni_RX_FQ_CTRL0.START[n].
Before launching an RX FIFO Queue n, it must be enabled by setting the Ni_RX_FQ_CTRL2.ENABLE[n] bit to 1.
Once enabled and started, there is no way to disable it while running without a defined procedure. Instead, the
abort bit Ni_RX_FQ_CTRL1.ABORT[n] provides a way to stop an RX FIFO Queue n running and to ensure a safe
stop and flush of on going data. For more detail on starting and stopping RX FIFO Queues, refer to the
Application Information chapter. It is essential to configure and start the relevant RX FIFO Queues before
starting the PRT. When the MH is not started and so no RX FIFO Queues are started, the MH will not accept any
RX data, leading to a PRT data overflow.
Each RX FIFO Queue can be managed individually, SW can decide to enable or disable any queue according to
the way RX messages must be managed. Once the RX filter is defined and the PRT is receiving messages any
change on the RX FIFO Queue setting is not possible. There is still a mechanism to abort an flush an RX FIFO
Queue while others are running.
Once a link list is started and an RX message needs to be written inside, the first descriptor in the list is read. It is
executed and the data buffer assigned to it, written. Other actions could be defined into the element data like
triggering an interrupt or setting flags. The link list is processed one descriptor at a time, if more RX descriptor is
required for a given message, the next one into the list is fetched (or could have been fetched earlier) and the
process repeats itself. The process keeps going up to the last descriptor of the link list, a wrap will occur
automatically at this time.
If the size of the container is small, the RX message with few payload data may fit in but larger one would
require several descriptors and containers. This approach optimizes the memory usage as the number of
containers used is very close to the effective size of the RX message received. But on the other way, such
strategy requires more descriptors and Data Container.
If we consider the other way round, large data container avoids splitting data buffers and limits the number of
descriptors. The main disadvantage would be the usage of more memory per descriptor.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4218
v1.1
2025-06-26


This is up to the SW to find the best tradeoff according to the CAN protocol and to the application required.
There is also the option to size differently the data container for every RX FIFO Queue, leaving some flexibility of
optimization.
Before receiving any RX message the RX FIFO Queues must be started. In case some messages are received and
the RX FIFO Queue to write data is not active the RX message is rejected and an RX_ABORT_IRQ interrupt is
triggered to the system.
To give a status report and some information like timestamping, the MH is also able to write back some
elements in the RX or TX descriptors. Not all of them are written back but only the one having the header data
defined.
The same remark regarding TX descriptors and TX data buffer location into memory applies for the RX
descriptors and data buffers.
The SW must always ensure that some RX descriptors in the RX FIFO Queue are always valid (VALID bit set to 0).
In case an RX descriptor is not valid the RX FIFO Queue n is stopped and an interrupt RX_FQ_IRQ is sent to the
system. If the system provides a valid RX descriptor and restarts the RX FIFO Queue n in time the RX message
could may be written into memory, otherwise the message is rejected and the interrupt RX_FQ_IRQ is triggered
to the system.
Up to 1023 RX descriptors can be defined for an RX FIFO Queue. The size of the RX FIFO Queue is defined such a
way when the Last Descriptor is reached, the MH wraps automatically to its initial start address to get the First
Descriptor.
If for some reasons an RX FIFO Queue has an error, it is still possible to abort the execution of that FIFO Queue.
When such action is performed, the RX FIFO Queue will be considered as active as long as the current data
transfer assigned to an RX descriptor is not finished. This means no more fetches are done and the RX FIFO
Queue is set inactive.
Any issue related to an RX descriptor executed by an RX FIFO Queue will stop it right away. To identify such
issue some interrupts are triggered to the system, RX_DESC_CRC_ERR or RX_DESC_REQ_ERR. Despite this RX
FIFO Queue is stopped, the others will keep going through their own RX descriptors.
An RX FIFO Queue is controlled and monitored using several registers and bit registers:
•
The Ni_RX_FQ_START_ADD{n} (where n is 0-7}) bit register to define the start address of the RX FIFO Queue
n
•
The Ni_RX_FQ_CTRL0.START[n] (n € {0, 1, 2, …, 7}) bit register to launch the RX FIFO Queue n
•
The Ni_RX_FQ_CTRL1.ABORT[n] (where n is 0-7}) bit register to abort the execution of the RX FIFO Queue n
•
The Ni_RX_FQ_CTRL2.ENABLE[n] (where n is 0-7}) bit register to enable the RX FIFO Queue n prior to use it
•
The Ni_RX_FQ_SIZE{n}.MAX_DESC and Ni_RX_FQ_SIZE{n}.DC_SIZE (where n is 0-7}) bit register to define
respectively, the maximum number of RX descriptor before looping back to the initial start address and the
Data Container size for the RX FIFO Queue n
•
The Ni_RX_FQ_ADD_PT{n} (where n is 0-7}) register to monitor the current address pointer of the RX FIFO
Queue n
•
The Ni_RX_FQ_STS0.BUSY[n] and Ni_RX_FQ_STS0.STOP[n] (where n is 0-7}) bit registers to know
respectively, the status of the RX FIFO Queue n, busy (RX FIFO Queue is active) and stopped or running or
not started
•
The Ni_RX_FQ_STS1.ERROR[n] and Ni_RX_FQ_STS1.UNVALID[n] (where n is 0-7}) bit registers to identify the
root cause of the RX FIFO Queue being stopped, an error is detected or a RX descriptor is invalid
•
The Ni_RX_FQ_INT_STS.RECEIVED[n] and Ni_RX_FQ_INT_STS.UNVALID[n] (where n is 0-7}) bit registers to
identify respectively, a message is received and an invalid RX descriptor is detected
An RX FIFO Queue is being controlled for any issue using common bit registers:
•
The Ni_SFTY_INT_STS.RX_DESC_CRC_ERR and Ni_SFTY_INT_STS.RX_DESC_REQ_ERR bit registers to
identify respectively, any CRC issue on RX descriptor running in the RX FIFO Queue n and non-expected RX
descriptor
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4219
v1.1
2025-06-26


•
The Ni_ERR_INT_STS.DP_RX_ACK_DO_ERR bit register to identify overflow on RX ACK data path for the TX
FIFO Queues
•
The Ni_ERR_INT_STS.DP_RX_FIFO_DO_ERR bit register to identify overflow on RX DMA FIFO for the RX FIFO
Queues
•
The Ni_ERR_INT_STS.DP_RX_SEQ_ERR bit register to identify if an issue occurs on the RX_MSG interface
22.5.3.15.1
Fragmented data container
The RX Data Container can be defined into any location and so an RX message is split across several area in the
S_MEM. With such approach, an address pointer is given to the application for any RX message data, no copy is
performed. A new Data Container is then allocated to replace the one being sent to the application. It is
important to note that in case of RX message received into several Data Container, several address pointers will
need to be provided. It is assumed that Data Containers that belongs to the same message can only be released
once all RX buffer data have been read.
When the MH has executed the Last Descriptor (the descriptor defined at the latest position in the Descriptor
Link List), it wraps automatically to the First descriptor.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4220
v1.1
2025-06-26


RX FIFO QUEUE
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
R0
R1
RD0
RD1
RDm-1
Buffer
RDi+j+5
RDi+j+4
RDi+j+3
RDi+j+2
RDi+j+1
Descriptors Link List
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Rx link list start 
address register
RX 
Descriptor 3
RX 
Descriptor 4
RX 
Descriptor 6
PROCESSED IN ORDER
Buffer
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 5
RX Data Container
(N*32bytes)
RD1
RD0
R1
R0
RDn-1
Buffer
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 7
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 1
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 2
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 0
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 8
RDi+6
Buffer
RDi+5
RDi+4
RDi+3
RDi+2
RDi+1
RDi+j
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RD2
Buffer
RD1
RD0
R2
R1
R0
RDi
Figure 411
RX FIFO Queue in Normal mode (Fragmented data containers)
In some cases the RX message can then be split across RX descriptor being at the top and at the bottom of an
RX FIFO Queue. This mode does make use of all the RX descriptors defined in a given RX FIFO Queue. It may
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4221
v1.1
2025-06-26


happen that SW would prefer to rely on linear RX message, having in mind a linear organization of data
containers in S_MEM, see Continuous data container chapter.
22.5.3.15.2
Continuous data container
As the RX data containers of the same message are spread to different location in L_MEM, it will not be easy for
the SW to read the entire message. To get around this issue, the SW can decide to declare the RX Data Container
in a linear memory area and to have them continuous to each other as depicted below.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4222
v1.1
2025-06-26


RX FIFO QUEUE
Descriptors Link List
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Rx link list start 
address register
RX 
Descriptor 4
RX 
Descriptor 8
RX 
Descriptor 6
PROCESSED IN ORDER
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 5
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 7
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 2
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 3
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 0
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 1
RX Data 
Container
(N*32bytes)
RX Data 
Container
(N*32bytes)
RX Data 
Container
(N*32bytes)
RX Data 
Container
(N*32bytes)
RD2
Buffer
RD1
RD0
R2
R1
R0
RDi
RDi+j+1
RDi+j+2
RDi+j+3
RDi+j+4
RDi+j+5
Buffer
RD1
RD0
R1
R0
RDm-1
Buffer
R0
R1
RD0
RD1
RDn-1
Buffer
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data Container
(N*32bytes)
RX Data 
Container
(N*32bytes)
RDi+6
Buffer
RDi+5
RDi+4
RDi+3
RDi+2
RDi+1
RDi+j
Figure 412
RX FIFO Queue in Normal Mode (Continuous Data Container)
This way of managing the RX message will have the main advantage to provide an RX message written in a
linear memory area, despite being split in several data containers.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4223
v1.1
2025-06-26


The only exception would be when the Last Descriptor is used and the message size exceed the Data Container.
The MH wraps and uses the First Descriptor to keep going with the current RX message data. In this particular
scenario the RX message data is split over the top and the bottom of the data container and the same applies
for the link list holding the RX descriptor. This is normal behavior and it must not be an issue for the SW to read
the RX message following the RX descriptor list from bottom to top.
This configuration provides a pseudo linearity for the RX messages in S_MEM, excepted at the borders. Doing
so, the SW would need to perform a copy of the RX message data to free the memory area for the new incoming
messages. Such configuration does not require any update on address pointer in the RX descriptors. Only the
VALID bit needs to be written by the SW to acknowledge the reading of the RX message and the update of the
read address pointer register.
22.5.3.16
RX FIFO queue in continuous mode
RX FIFO QUEUE (Continuous mode)
RX Data Container
(N*32bytes)
Descriptors Link List
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Rx link list start 
address register
RX 
Descriptor 4
RX 
Descriptor 6
PROCESSED IN ORDER
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 5
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 7
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 2
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 3
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 0
Element 2: Not used
Element 3: Not used
Element 0
Element 1: RX_AP
RX 
Descriptor 1
RD2
Buffer
RD1
RD0
R2
R1
R0
RDi
RD1
RD0
R1
R0
RDm-1
Buffer
R0
R1
RD0
RD1
RDn-1
Buffer
RDi+6
RDi+5
RDi+4
RDi+3
RDi+2
RDi+1
RDi+j
RDi+j+1
RDi+j+2
RDi+j+3
RDi+j+4
RDi+j+5
Head Descriptor: 
Descriptor pointing to the RX data 
container holding the header data
Current Descriptor: 
Descriptor executed by the MH
Next Descriptor: 
Descriptor to be used as next in 
the current RX FIFO Queue
Last Descriptor: 
The last descriptor defined into 
the RX FIFO Queue
First Descriptor: 
Descriptor defined by the RX FIFO Queue 
start address
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 4
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX 
Descriptor 4
Container: 
Linear memory 
space assigned to 
all RX message 
received by a RX 
FIFO Queue
Buffer: 
Linear memory 
space used by a RX 
descriptor to write 
RX data
Figure 413
RX FIFO queue continuous mode
The same principle as defined in the RX FIFO Queue in Normal mode applies for the RX descriptors in this
Continuous mode. The way they are used, managed and defined remain, see RX FIFO Queue in Normal mode
chapter.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4224
v1.1
2025-06-26


The main difference is coming from the structure of the RX message data being stored in the S_MEM. An RX FIFO
Queue when in Continuous mode is a list of RX descriptors pointing to a large and single data container to store
all the RX messages received by the PRT.
The RX filtering rules, programmed by the SW, define if a message is rejected or accepted, and in case it is which
RX FIFO Queue is receiving the message. If a message is rejected it will not appear in any of the FIFOs. Each one
being fully independent from the others, the MH appends to RX FIFO Queues new RX message as they arrive on
the CAN Bus. The RX filter builds over time those queues with messages based on the filtering result. It is up to
the SW to read them in time.
The mechanism to manage RX FIFO Queues is based on the concept of link list. Any RX FIFO Queue when in
Continuous mode is defined using a link list of RX descriptors and a large data container.
As messages are received in a continuous way, the RX FIFO Queue are used in a circular buffer mode. This
means when the Last Descriptor is reach the MH will consider the First Descriptor as the next descriptor. The
Last Descriptor is defined by the size of the RX FIFO Queue and the start address of the RX FIFO Queue.
The RX filter observes all the incoming RX messages to identify the right RX FIFO Queue. Once defined, the
current RX descriptor attached to the selected RX FIFO Queue is fetched and used to define the new incoming
RX message data.
The MH will proceed with all the RX FIFO Queues the same way. As the RX FIFO Queue selected depends on the
RX filtering result, the RX FIFO Queues will be fill up at a different rate.
Every RX FIFO Queue can be managed individually, SW can decide to enable or disable any queue according to
the way RX messages must be managed. Once the RX filter is defined and the PRT is receiving messages any
change on the RX FIFO Queue setting is not possible. There is still a mechanism to abort and flush an RX FIFO
Queue while others are running.
Once an RX FIFO Queue is started and an RX message needs to be written in its corresponding data container,
the First descriptor in the descriptor list is read. It is executed and the initial start address of the data container
assigned to it. The link list is processed one descriptor at a time every time a new RX message is received by the
same RX FIFO Queue. The process keeps going up to the Last descriptor of the link list before making a wrap.
Other actions could be defined in the RX descriptor like triggering an interrupt or setting flags.
The MH writes messages as they arrive, to avoid overwritting. The SW needs to write the address value of the
current message being read to a MH register. Therefore, the MH can compute the exact memory left to be used
by the new RX message.
The size of the data container is programmable to store many CAN XL frames if required. Up to
Ni_RX_FQ_SIZE{n}.DC_SIZE[11:0] * 32byte data container size can be defined for a data container assigned to
an RX FIFO Queue. As the size is programmable per RX FIFO Queue, it is then possible to limit the memory
footprint according to the expected message to be received.
Before receiving any RX message the RX FIFO Queues must be started. In case some messages are received and
the RX FIFO Queue to write data is not active the RX message is rejected and an RX_ABORT_IRQ interrupt is
triggered to the system.
To give a status report and some information like timestamping, the MH is also able to write back some
elements in the RX or TX descriptors. Not all of them are written back but only the one having the header data
defined.
The same remark regarding TX descriptors and TX data buffer location into memory applies for the RX
descriptors and data buffers.
The SW must always ensure that some RX descriptors in the RX FIFO Queue are always valid (VALID bit set to 0).
In case an RX descriptor is not valid the RX FIFO Queue n is stopped and an interrupt RX_FQ_IRQ is sent to the
system. If the system provides a valid RX descriptor and restarts the RX FIFO Queue n in time the RX message
could may be written into memory, otherwise the message is rejected and the interrupt RX_FQ_IRQ is triggered
to the system.
In the Continuous mode, one RX descriptor is assigned to one message, thus, once the SW has read the
message, the VALID bit can be set to 0 right away. The SW is in charge, once the message is read, to set the read
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4225
v1.1
2025-06-26


address pointer in the MH register. The MH uses this information to estimate if the incoming message data can
be written safely in the data container.
Up to 1023 RX descriptors can be defined for an RX FIFO Queue. The size of the RX FIFO Queue is defined such
that when the Last Descriptor is reached, the MH wraps to its initial start address to fetch the First Descriptor. As
the RX FIFO Queue size for the RX descriptors is defined at first time and cannot be changed once the RX FIFO
Queue is started, the MH wraps automatically to keep going.
If, for some reasons, an RX FIFO Queue has an error, it is still possible to abort the execution of that FIFO Queue.
When such action is performed, the RX FIFO Queue will be considered as active, as long as the current data
transfers, assigned to an RX descriptor, are not finished. This means, there is no pending transaction attached
to the RX FIFO Queue, this includes the RX descriptor acknowledge when an RX message is received. The
RX_FQ_IRQ interrupt is triggered to the system, if enable, once the last RX message is received by the aborted
RX FIFO Queue n.
Any issue related to an RX descriptor that is executed by an RX FIFO Queue will stop it right away. To identify
such issue, some interrupts are triggered to the system, RX_DESC_CRC_ERR or RX_DESC_REQ_ERR. Despite of
having this RX FIFO Queue stopped, the other ones will keep going through their own RX descriptors.
An RX FIFO Queue is controlled and monitored using several registers and bit registers:
•
See the all registers already defined for the Normal mode
•
The Ni_RX_FQ_DC_START_ADDn (where n is 0-7) register to be written by the software to indicate to the MH
the read address pointer in the data container for the RX FIFO Queue n
•
The Ni_RX_FQ_STS2.DC_FULL[n] (where n is 0-7) bit register to identify the root cause of the RX FIFO Queue
being stopped, there is no space left on the system memory to write new RX data. This issue may occur only
if the MH is set to Continuous Mode
•
In case of Continuous mode, the Ni_RX_FQ_RD_ADD_PTn (n € {0, 1, ..., 7}) register must be initialized to
{Ni_RX_FQ_RD_ADD_PTn.VAL | 0b11} otherwise left to its default value
An RX FIFO Queue is being controlled for any issue using common bit registers:
•
See the all registers already defined for the Normal mode
22.5.3.17
TX FIFO queue data flow
The SW defines the TX descriptors for every TX FIFO Queues to be used and declare the TX data buffers assigned
to those TX descriptors.
As soon as the TX FIFO Queues are started the TX MH will process and fetch all the relevant TX descriptors and
will store them into the L_MEM for arbitration.
Only the TX message having the highest priority ID is sent first. Those messages will compete against the one
defined into the TX Priority Queue. Only the TX descriptor holding the header data is written back with status
information of the data transfer and timestamp. As soon as one TX descriptor is used from a TX FIFO Queue it
will be replaced by the next one of that queue. The TX MESSAGE HANDLER is managing on its own the request
for a new descriptor whenever required.
The following data flow describes how the TX FIFO Queues are running in parallel. Here are the different steps
when a TX message is selected and/or used:
1.
After having sent a TX message from the TX FIFO queue n, the TX MESSAGE HANDLER is sending a request
to the DESCRIPTOR MESSAGE HANDLER for the next TX descriptor from that queue
2.
The relevant TX descriptor of the TX FIFO Queue is fetched by the DESCRIPTOR MESSAGE HANDLER and
written to the L_MEM
3.
As soon as the new TX descriptor is completely written into the L_MEM an arbitration run is performed.
This arbitration will identify which TX descriptor is having the highest priority, looping through the
current TX descriptor for every TX FIFO Queues and through all the slot of the TX Priority Queue declared
as active. Once the two first candidates position (Priority Queue slot number or TX FIFO queue number)
are defined, they are loaded in the TX MESSAGE HANDLER
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4226
v1.1
2025-06-26


4.
The TX MESSAGE HANDLER is then trying to upload the TX message with the highest priority locally. If a
TX message is in progress, the TX MESSAGE HANDLER will wait for the end of the current transmission to
read from the L_MEM the complete TX descriptor. If nothing is preventing the upload of the next
descriptor, it will be done right away. As soon as the TX descriptor is locally stored the first TX message
data are sent to the PRT. The TX MESSAGE HANDLER will wait for the PRT to know if it has won the
arbitration process. As long as no new TX descriptor is changing the arbitration result, the selected TX
descriptor remains in the TX MESSAGE HANDLER for further arbitration trials. As soon as the TX message
is winning the arbitration, all the data contained in the TX descriptor is sent to the PRT
5.
The payload data assigned to the TX descriptor is fetched from the S_MEM.
6.
If the TX message is sent successfully, an acknowledge request is sent to the DESCRIPTOR MESSAGE
HANDLER with the status and information of the transfer. The DESCRIPTOR MESSAGE HANDLER writes
back the acknowledge of that descriptor in the S_MEM. When the DESCRIPTOR MESSAGE HANDLER has
finished writing the TX descriptor an interrupt TX_FQ_IRQ for the TX FIFO Queue n may be triggered to
the system
As all TX FIFO Queue are processed the same way, the data flow of only one TX FIFO Queue is depicted in the
following figure with the reference number for each step.
S_MEM
T0
T1
TD4 / TD5
TDn-2 / TDn-1
MESSAGE HANDLER
DMA MESSAGE 
HANDLER
TX MESSAGE 
HANDLER
HOST 
CPU
LOCAL 
MEMORY 
CONTROLLER
TD0
TD1
TD2
TD3
TDn-1
Element 4: T0
Element 5: T1
Element 6: T2 / TD0
Element 2: set to 0
Element 3: set to 0
Element 0
Element 1
Element 7: TX_AP / TD1
TX Descriptor
DMA READ 
CHANNEL 1
DMA READ 
CHANNEL 2
N x Burst
1 Burst
TX Payload
TX Data Container
TX Data Container
TX Data Container
FIFO Queue TX Element 
Descriptors
FIFO Queue TX 
Element Payload
Element 4: T0
Element 5: T1
Element 6: T2
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TD1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TX_AP  
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP  
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Tx link list start 
address register
TD0
TD1
TD2
TD3
TDn-1
TD2
Multiple of 32Bytes
TX Element Descriptor 0
TX Element Descriptor 1
TX Element Descriptor n
PROCESSED IN ORDER
TD0
TD1
DESCRIPTOR 
MESSAGE 
HANDLER
Element 2: TS0
Element 3: TS1
Element 0
Element 1
TX Acknowledge
DMA WRITE 
CHANNEL 0
TX Acknowledge
TD0
TD1
TD1 / TD2
TD2 / TD3
TD3 / TD4
T2 / TD0
TD0 / TD1
Multiple of 32Bytes
L_MEM
FIFO Queue TX Element 
Descriptors
Element 4: T0
Element 5: T1
Element 6: T2
Element 7: TX_AP  
FIFO Queue 0
TX Descriptor
Element 0
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TD1
TX Descriptor
Element 0
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP  
TX Descriptor
Element 0
CAN TDn-1 /        
32Bytes
Element 1
Element 1
Element 1
Element 4: T0
Element 5: T1
Element 6: T2 / TD0
Element 7: TX_AP / TD1
TX Element Descriptor n
Element 0
Element 1
FIFO Queue 1
FIFO Queue N-1
TX FIFO Queue
1
5
2
3
Current TX 
Descriptor
4
MEM_AXI
6
SLOT 0
SLOT 31
Element 4: T0
Element 5: T1
Element 6: T2
Element 7: TX_AP  
Element 0
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP  
Element 0
Element 1
Element 1
TX Descriptor
TX Descriptor
PROTOCOL 
CONTROLLER
TXD
CPU read and write data path
TX descriptor acknowledge write data path
TX descriptor read and write data path
TX message read payload data path
TX-Scan read data path
TX Header descriptor read data path
TX_MSG
DMA_AXI
Figure 414
TX FIFO queue data flow
22.5.3.18
TX priority queue data flow
The SW defines the TX descriptors to be sent into the TX Priority Queue slot to be used and declare the TX data
buffers assigned to those TX descriptors. Once done the SW triggers the TX MESSAGE HANDLER to have those
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4227
v1.1
2025-06-26


messages sent as soon as possible. Those messages will compete against the one defined into the TX FIFO
Queues. Only the ID is relevant for the selection of TX messages.
As soon as the TX Priority Queue slots are started the TX MESSAGE HANDLER will process and fetch all the
relevant TX descriptors and will store them into the L_MEM for arbitration.
When a TX message is sent, an acknowledge (status information and timestamp) is written back to the TX
descriptor holding the header data. As soon as a TX descriptor slot is used from a TX Priority Queue slot, it will
be considered as inactive and won’t be considered afterwards.
There is a way to keep track of the TX descriptors used for the TX Priority Queue, refer to the Trace and Debug
chapter.
The following data flow is relevant for all TX Priority Queue slots.
Here below are the different steps when a TX message is selected and or used:
1.
To trigger the TX message defined into the TX Priority Queue, the SW must write the start bit of the
corresponding slot. There is nothing preventing the SW to declared several TX message at the same time
and to launch them at once. The TX MESSAGE HANDLER is sending requests to the DESCRIPTOR
MESSAGE HANDLER for the TX descriptors to be fetched. If several TX descriptors need to be uploaded at
once, they would be fetched in the order of their slot number, starting with 0
2.
The relevant TX descriptors of the TX FIFO Queue is fetched by the DESCRIPTOR MESSAGE HANDLER and
written to the L_MEM
3.
As soon as the new TX descriptor is completely written into the L_MEM an arbitration run is performed
and only the TX descriptor uploaded for the slot will be considered. This arbitration will identify which TX
descriptor is having the highest priority, looping through the current TX descriptor for every TX FIFO
Queue and through all slots of the TX Priority Queue declared as active. This selection is performed
doing a single read on all defined TX descriptor in the L_MEM. Once the two first candidates are
identified, either the TX Priority Queue Slot number and/or the TX FIFO queue number, they are stored
locally in the TX MESSAGE HANDLER
4.
The TX MESSAGE HANDLER is then trying to upload the TX descriptor with the highest priority locally. If a
TX message is in progress, the TX MESSAGE HANDLER will wait for the end of the current transmission to
read from the L_MEM the complete TX descriptor. If nothing is preventing the upload of the next
descriptor, it will be done right away. As soon as the TX descriptor is stored locally the first TX message
data are sent to the PRT. The TX MESSAGE HANDLER will wait for the PRT to know if it has won the
arbitration process. As long as no new TX descriptor is changing the arbitration result, the selected TX
descriptor remains into the TX MESSAGE HANDLER for further arbitration trials. As soon as the TX
message is winning the arbitration, all the data contained into the TX descriptor is sent to the PRT
5.
The payload data assigned to the TX descriptor is fetched from the S_MEM.
6.
If the TX message is sent successfully, an acknowledge request is sent to the DESCRIPTOR MESSAGE
HANDLER with the status and information of the transfer. The DESCRIPTOR MESSAGE HANDLER writes
back the acknowledge of that descriptor in the S_MEM. When the DESCRIPTOR MESSAGE HANDLER has
finished writing the TX descriptor an interrupt TX_PQ_IRQ for any of the TX Priority Queue slot may be
triggered to the system. Once the acknowledge is written, the slot is considered as invalid and will not be
used for the next arbitration run, up to the time the SW set it back to active
As all the TX Priority Queue slots are processed the same way, the data flow of one slot is depicted in the
following figure with the reference number for each step.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4228
v1.1
2025-06-26


S_MEM
L_MEM
MESSAGE HANDLER
TX MESSAGE 
HANDLER
HOST 
CPU
LOCAL MEMORY 
CONTROLLER
Priority Queue TX Element 
Descriptors
DMA MESSAGE 
HANDLER
DMA READ 
CHANNEL 1
DMA READ 
CHANNEL 0
DMA WRITE 
CHANNEL 0
DESCRIPTOR 
MESSAGE 
HANDLER
REGISTER 
BANK
Element 2: TS0
Element 3: TS1
Element 0
Element 1
TX Acknowledge
TX Acknowledge
Element 4: T0
Element 5: T1
Element 6: T2 / TD0
Element 7: TX_AP / TD1
TX Descriptor
Element 0
Element 1
Element 4: T0
Element 5: T1
Element 6: T2 / TD0
Element 2: set to 0
Element 3: set to 0
Element 0
Element 1
Element 7: TX_AP / TD1
TX Descriptor
1 Burst
T0
T1
TD4 / TD5
TDn-2 / TDn-1
TD1 / TD2
TD2 / TD3
TD3 / TD4
T2 / TD0
TD0 / TD1
CAN TDn-1 /        
TX Priority Queue slots of 
descriptor  
TX Data Buffer
TD0
TD1
TD2
TD3
TDn-1
TD2
TD3
TD15
TDm-1
Buffer multiple of 32bytes
TD0
TD1
TD0
TD1
Buffer multiple of 32bytes
32Bytes
PROCESSED IN ANY ORDER
Up to 32 slots
Element 4: T0
Element 5: T1
Element 6: T2
Element 4: T0
Element 5: T1
CAN TD0
CAN TD1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 2: TS0
Element 3: TS1
Element 0
Element 1
Element 7: TX_AP
Element 4: T0
Element 5: T1
CAN TD0
Element 7: TX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1
TX Descriptor
SLOT 0
TX Descriptor
SLOT 1
TX Descriptor
SLOT 31
TX Priority Queue 
start address register
TD0
TD1
TD2
TD3
TDn-1
N x Burst
TX Payload
TX_MSG
HOST_AXI
3
MEM_AXI
4
5
2
1
DMA_AXI
6
Element 4: T0
Element 5: T1
Element 6: T2
Element 7: TX_AP  
FIFO Queue 0
Element 0
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TD1
Element 0
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP  
Element 0
Element 1
Element 1
Element 1
FIFO Queue 1
FIFO Queue N-1
SLOT 0
SLOT 31
Element 4: T0
Element 5: T1
Element 6: T2
Element 7: TX_AP  
Element 0
Element 4: T0
Element 5: T1
Element 6: TD0
Element 7: TX_AP  
Element 0
Element 1
Element 1
TX Descriptor
TX Descriptor
TX Descriptor
TX Descriptor
TX Descriptor
PROTOCOL 
CONTROLLER
TXD
CPU read and write data path
TX descriptor acknowledge write data path
TX descriptor read and write data path
TX message read payload data path
TX-Scan read data path
TX Header descriptor read data path
TX Priority Queue
Figure 415
TX Priority queue data flow
22.5.3.19
RX FIFO queue data flow in Normal Mode
The SW needs to prepare into the S_MEM the RX filter elements. Once done the SW writes those elements to the
L_MEM. The SW cannot access this memory directly in write mode through the HOST bus interface. As a
consequence the L_MEM should provide a way to protect the memory space allocated to the RX filtering
elements from being read by any other masters.
The SW defines the RX descriptors for every RX FIFO Queue to be used and allocated the RX data buffers
assigned to those RX descriptors. As soon as the RX FIFO Queues are started any RX messages will be filtered,
meaning rejected or accepted, and stored into the S_MEM when required.
Here below are the different steps when receiving an RX message:
1.
As soon as the RX message data R0, R1 and R2 are received the RX filtering is started. All the incoming
data are stored locally into the RX MESSAGE HANDLER waiting for the result of RX filtering. The RX
MESSAGE HANDLER identifies RX FIFO Queue to be used
2.
The RX MESSAGE HANDLER sends an RX descriptor request to the DESCRIPTOR MESSAGE HANDLER
3.
The relevant RX descriptor of the queue identified and fetched by the DESCRIPTOR MESSAGE HANDLER is
given to the RX MESSAGE HANDLER
4.
The RX MESSAGE HANDLER is using the address pointer of the RX descriptor to write the message data to
the S_MEM as soon as a complete burst is available. As long as the data buffer can accept message data,
the process of writing can continue. In case the last data can be written into the data buffer pointed by
the current RX descriptor, go to 6 otherwise the next RX descriptor of the same queue is requested to the
DESCRIPTOR MESSAGE HANDLER
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4229
v1.1
2025-06-26


5.
When the current RX descriptor is about to be complete, the new RX descriptor should be available for
the next DMA data transfer and go to 3
6.
The RX MESSAGE HANDLER gets the status of the last part of the RX message and the information of the
latest data transfers. Those data are sent to the DESCRIPTOR MESSAGE HANDLER to be written back as
acknowledge to RX descriptor into the S_MEM holding the header. The timestamp and report status of
the RX message is written at the same time. When the DESCRIPTOR MESSAGE HANDLER has finished
writing the RX descriptor an interrupt RX_FQ_IRQ for the RX FIFO Queue n may be triggered to the
system
As all the RX FIFO Queues are processed the same way, the data flow of only one RX FIFO Queue is depicted in
the following figure with the reference number for each step.
S_MEM
L_MEM
MESSAGE HANDLER
RX MESSAGE 
HANDLER
HOST CPU
LOCAL MEMORY 
CONTROLLER
DMA MESSAGE 
HANDLER
DMA WRITE 
CHANNEL 1
Filter Element 0
Filter Element 1
Filter Element 2
Filter Element P-2
Reference Value 0
Reference Mask 0
Reference Value 1
Reference Mask 1
Reference Value Q-1
Reference Mask Q-1
Filter Element P-1
R0
R1
R2 / RD0
RD0 / RD1
RDi-2 / RDi-1
RX Payload
N x Burst
Protected Area
Filter Elements and 
References
Filter Element 0
Filter Element 1
Filter Element 2
Filter Element P-2
Reference Value 0
Reference Mask 0
Reference Value 1
Reference Mask 1
Reference Value Q-1
Reference Mask Q-1
Filter Element P-1
References
DMA READ 
CHANNEL 0
DESCRIPTOR 
MESSAGE 
HANDLER
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Acknowledge
RX Acknowledge
DMA WRITE 
CHANNEL 0
Element 0
Element 1: RX_AP
RX Descriptor
RX Descriptor
Filter Elements
References
Filter Elements
R0
R1
RD4 / RD5
RDn-2 / RDn-1
RD1 / RD2
RD2 / RD3
RD3 / RD4
R2 / RD0
RD0 / RD1
RDn-1 /        
RX Data Container
RX Data Container
RX Data Container
RX Data Container
RX Buffer
R0
R1
RD0
RX Buffer
RD(Kx16)+5
RD1
RD2
RD25
RD(Kx16)+4
RD(Kx16)+3
RD(Kx16)+2
RD(Kx16)+1
RD(Kx16)
RX FIFO Queue Link List 
Descriptors
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Rx link list start 
address register
RX Descriptor 0
RX Descriptor 1
RX Descriptor 2
PROCESSED IN ORDER
RD(Kx16-1)
RX Buffer
R0
R1
R2
RD0
RD1
64Bytes
64Bytes
64Bytes
2
3
1
4
RX_MSG
MEM_AXI
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor n
Current RX 
Descriptor
5
DMA_AXI
6
PROTOCOL 
CONTROLLER
CAN_RX
5
CPU read and write data path
RX descriptor acknowledge write data path
RX descriptor read data path
RX message write data path
RX Filter read data path
RX FIFO Queue
RX Buffer
R0
R1
RD0
RD1
64Bytes
Figure 416
RX FIFO queue data flow in Normal Mode
22.5.3.19.1
RX FIFO Queue data flow in Continuous Mode
The SW needs to prepare the RX filter elements required to accept or reject RX messages. Once done, the SW
writes those elements to the L_MEM. The SW cannot access this memory directly in write mode through the
HOST bus interface. As a consequence the L_MEM must provide a way to protect the memory space allocated to
the RX filtering elements from being read by any other masters.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4230
v1.1
2025-06-26


The SW defines the RX descriptors for every RX FIFO Queue to be used and allocates the single data container
for each of them.
As soon as the RX FIFO Queues are started, any RX messages will be filtered, meaning rejected or accepted, and
stored into the S_MEM when required.
Here below are the different steps when receiving an RX message:
1.
As soon as the RX message data R0, R1 and R2 are received, the RX filtering is started. All the incoming
data are stored locally in the RX MESSAGE HANDLER waiting for the result of RX filtering. The RX
MESSAGE HANDLER identifies RX FIFO Queue to be used
2.
The RX MESSAGE HANDLER sends an RX descriptor request to the DESCRIPTOR MESSAGE HANDLER
3.
The relevant RX descriptor of the queue identified and fetched by the DESCRIPTOR MESSAGE HANDLER is
given to the RX MESSAGE HANDLER
4.
The RX MESSAGE HANDLER holds the RX descriptor of that RX FIFO queue for futher purpose. In case the
current RX message cannot fit in the remaining space of the data container, the message is automatically
written at the top (if possible). The message data are written to the S_MEM starting after the last RX
message stored in the data container. As soon as a complete burst is available, it is written and this
process continues up to the last RX message data.
5.
The RX MESSAGE HANDLER gets the status of the last part of the RX message and the information of the
latest data transfers. Those data are sent to the DESCRIPTOR MESSAGE HANDLER to be written back as
an acknowledge to the RX descriptor fetched earlier from the S_MEM. The timestamp, the address of the
RX message inside the data container and a report status of the RX message are written at the same
time. When the DESCRIPTOR MESSAGE HANDLER has finished writing the RX descriptor, an interrupt
RX_FQ_IRQ for the RX FIFO Queue n may be triggered to the system.
As all the RX FIFO Queues are processed the same way, the data flow of only one RX FIFO Queue is depicted in
the figure below with the reference number for each step.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4231
v1.1
2025-06-26


S_MEM
L_MEM
MESSAGE HANDLER
RX MESSAGE 
HANDLER
HOST CPU
LOCAL MEMORY 
CONTROLLER
DMA MESSAGE 
HANDLER
DMA WRITE 
CHANNEL 1
Filter Element 0
Filter Element 1
Filter Element 2
Filter Element P-2
Reference Value 0
Reference Mask 0
Reference Value 1
Reference Mask 1
Reference Value Q-1
Reference Mask Q-1
Filter Element P-1
R0
R1
R2 / RD0
RD0 / RD1
RDi-2 / RDi-1
RX Payload
N x Burst
Protected Area
Filter Elements and 
References
Filter Element 0
Filter Element 1
Filter Element 2
Filter Element P-2
Reference Value 0
Reference Mask 0
Reference Value 1
Reference Mask 1
Reference Value Q-1
Reference Mask Q-1
Filter Element P-1
References
DMA READ 
CHANNEL 0
DESCRIPTOR 
MESSAGE 
HANDLER
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Acknowledge
RX Acknowledge
DMA WRITE 
CHANNEL 0
Element 0
Element 1: RX_AP
RX Descriptor
RX Descriptor
Filter Elements
References
Filter Elements
R0
R1
RD4 / RD5
RDn-2 / RDn-1
RD1 / RD2
RD2 / RD3
RD3 / RD4
R2 / RD0
RD0 / RD1
RDn-1 /        
RX Data Container
(Nx64Byte)
R0
R1
RD0
RD1
RD2
RD25
RX FIFO Queue Link List 
Descriptors
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
Rx link list start 
address register
RX Descriptor 0
RX Descriptor 1
RX Descriptor 2
PROCESSED IN ORDER
RD2
R0
R1
R2
RD0
RD1
RD240
2
3
1
4
RX_MSG
MEM_AXI
Element 2: TS0
Element 3: TS1
Element 0
Element 1: RX_AP
RX Descriptor n
Current RX 
Descriptor
DMA_AXI
5
PROTOCOL 
CONTROLLER
CAN_RX
RD2
R0
R1
R2
RD0
RD1
R0
R1
R2
RD0
RD1
RD2
RD40
RD2
RD129
RX FIFO Queue
CPU read and write data path
RX descriptor acknowledge write data path
RX descriptor read data path
RX message write data path
RX Filter read data path
Figure 417
RX FIFO Queue data flow in Continuous Mode
22.5.3.20
TX-SCAN
To avoid any misunderstanding when talking about the selection of the next TX message to be sent to the PRT,
the term TX-SCAN is used to define this process.
To arbitrate TX FIFO queues and cope with high latency in S_MEM, the TX Header Descriptor of every active TX
FIFO Queues are stored into the L_MEM. The same applies for the TX Priority Queue slots when they are
declared as active. It means up to 8 TX FIFO Queues Header Descriptor can be declared in L_MEM and up to 32
for the TX Priority Queue. Doing so, it becomes much easier to parse all the active TX Header Descriptors locally
to identify which TX message has the highest priority. The TX-SCAN process would be very fast and the expected
TX message order at CAN bus as close as possible to the one expected by the SW.
The TX-SCAN uses the list of TX descriptors available in L_MEM. When a new TX descriptor is added, a flag is set
to indicate the availability of a new potential candidate. As long as the TX descriptor is not executed or
discarded, it will remain as a valid candidate, see Ni_TX_FQ_DESC_VALID and Ni_TX_PQ_DESC_VALID registers.
Events to trigger a TX-SCAN run are:
•
A new TX message written in a TX Priority Queue slot
•
A TX message sent successfully
•
A TX message discarded after N retransmissions
•
A SW abort of a TX Priority Queue slot
•
A SW abort of a TX FIFO Queue
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4232
v1.1
2025-06-26


•
A TX message rejected by the TX Filter
•
A TX message starting to be sent (in case of TX FIFO Queue, triggers the fetch of the next descriptor)
Any new TX message appended to a TX FIFO Queue does not trig a new TX-SCAN. The MH is only processing TX
descriptor one after the other in every TX FIFO Queue, it does not know if a new message is added to one of
them.
A re-transmission counter defines the number of re-transmissions allowed to the same TX message when this
one is unsuccessful. For every trial of the same TX message, the re-transmission counter is incremented and
compared to a maximum value defined in the Ni_MH_CFG.MAX_RETRANS[2:0]. If the counter exceeds the limit,
the current TX message will no longer be considered and is skipped, the next TX message is taken instead. The
re-transmission counter is set back to 0 when a new TX message is selected. There is the option to define an
unlimited number of trials for TX messages.
The maximum number of re-transmission is defined by the register Ni_MH_CFG.MAX_RETRANS[2:0] and covers
the maximum value defined in ISO 11898-1:2024.
Several options are defined:
•
0: No re-transmission
•
1 to 6: 1 to 6 re-transmission
•
7: Unlimited re-transmission (default value)
Here below is the definition of the 32bit priority value when considering Classical CAN, CAN FD and CAN XL. The
fields XLF, FDF, XTD, RTR, SRR and ID (defined in CAN protocol [1]) are used to determine the priority value of a
given TX message. The priority value is computed for every TX message and then compared with each other to
identify the highest priority message (the lowest value gives the highest priority message to transmit).
Only the T0 of the TX Header Descriptor is used for the selection of the highest priority message. As the relevant
bits are defined in T0 element, only a single read access from the L_MEM is required. In Classical frame format,
a data frame and a remote frame with the same identifier have the same priority in the TX-Scan.
Table 1049
Definition of priority value
CAN
Protocol
Protocol Selection
Priority Value
XLF
FDF
XTD
31
down to
19
20
19
18
17
16
downto
1
0
Classic
CAN
0
0
0
T0[28:18
] (Base
ID[10:0])
0 (RTR)
0
(XTD)
0
(FDF)
0
16'b0
0
Classic
CAN
(extende
d ID)
0
0
1
T0[28:18
] (Base
ID[10:0])
1 (SRR)
1
(XTD)
T0[17:0]
(Identifier Extension[17:0])
0 (RTR)
CAN FD
0
1
0
T0[28:18
] (Base
ID[10:0])
0 (RRS)
0
(XTD)
1
(FDF)
0
16'b0
0
CAN FD
(extende
d ID)
0
1
1
T0[28:18
] (Base
ID[10:0])
1 (SRR)
1
(XTD)
T0[17:0]
(Identifier Extension[17:0])
0 (RSS)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4233
v1.1
2025-06-26


Table 1049
(continued) Definition of priority value
CAN
Protocol
Protocol Selection
Priority Value
XLF
FDF
XTD
31
down to
19
20
19
18
17
16
downto
1
0
CAN XL
1
X
X
T0[28:18
]
(Priority
ID[10:0])
T0[17]
(RRS)
0
(XTD)
1
(FDF)
1
(XLF)
16'b0
0
The selection of the TX message is done by looking at the queues in the following order, TX Priority Queue slots
from 0 to 31, then the TX FIFO Queues are scanned from 0 to 7. The process of TX message selection will keep
the two highest priority messages over the full scan.
When two or more TX messages have the same priority value, the first one will always be kept as the one to be
sent first.
Note:
At initial time, when several TX FIFO Queues are started at the same time, the first TX messages may
not be in the right order. Due to the scanning order (TX FIFO Queue slots 0 to 31 and then TX FIFO
Queue 0 to 7) and if the system memory latency is high, by the time the last TX descriptor is uploaded
to the L_MEM, some TX messages may have been already scanned for the highest priority and sent to
the PRT. This is normal behavior and will last only for the first TX messages.
As soon as a new Header Descriptor is available in the L_MEM, it will be arbitrated automatically if the TX-Scan
process is not running. In case that a new TX Header Descriptor is stored in the L_MEM while the TX-Scan is
running, the TX-Scan goes up to the end and will restarted to take this new descriptor into account.
Before starting the TX-Scan, the list of all potential candidates (valid) on the L_MEM is stored locally. This
process will ensure a proper definition of the best candidates after a complete scan at the time it is done.
The duration of the TX-Scan mainly depends on the access time to the L_MEM and the number of TX FIFO
Queues and TX Priority Queue Slots. Here is the list of parameters that will drive the overall time:
•
The number of TX FIFO Queues being active at the same time
•
The number of TX Priority Queue slots active at the same time
•
The L_MEM read latency to fetch one single word
The processing time for one TX -Scan run can be defined as:
TX Scan processin g time µs
= Lr * Nbfq + Nbpqs *
1
CLK Mℎz  where Nbfq = Number of TX FIFO Queues
active, Nbpqs = Number of TX Priority Queue slots active and Lr = read latency from L_MEM defined in number
of CLK clock cycles.
In any cases, when a new TX message is scheduled for transmission and it has the highest priority, the
maximum delay to have this message selected by the TX-SCAN depends on, the maximum number of TX FIFO
Queue and TX priority Queue running concurrently at that time. Considering a maximum of 8 TX FIFO Queues
and 32 TX Priority Queue slots running at the same time this leads to (considering the previous formula):
MaximumTX SCAN duration
µs
= Lr *
1
CLK MHz
* 40
To ensure the continuity of a TX message, it is important to note that regarding TX FIFO Queues, the current and
the next TX Header Descriptor for a given FIFO are loaded in the L_MEM. This assumption is valid only if the two
TX descriptors are valid. Thus, if several TX messages in the same FIFO have the highest priority over the others,
they will be sent back to back. For the TX priority Queue, things are different as one TX message is stored per
slot. Only the TX message defined as active in a slot is taken into account at any time.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4234
v1.1
2025-06-26


Two internal buffers are used to hold the TX descriptors in order to send TX messages in a row. One is holding
the current TX descriptor to be sent right away to the PRT while the other stores the TX descriptor for the next
message. It is important to note that the TX descriptors selected are the result of one TX-Scan. If any new events
like, a message sent or a new message to be sent occurs, the two candidates may not be right ones. In this case
the TX descriptors already buffered may need to be changed by some new ones. The change is performed step
by step, to always have the highest priority message of one TX-Scan run available in one of the two local
buffers. The previous TX descriptor with the highest priority is kept in one of the two local buffer while the new
highest one is replacing the other. This procedure is repeated, if required, to change the second highest priority
message.
The event of any new TX descriptor being loaded and available in the L_MEM triggers a TX-SCAN run. The TX
descriptors describing TX messages can only be taken into account by the TX-SCAN if they are available in
L_MEM, see Ni_TX_FQ_DESC_VALID and Ni_TX_PQ_DESC_VALID registers.
To prepare the next TX descriptor and to react properly according to some result of the data being sent, there
will be several actions to perform:
•
The TX-SCAN is computing the two next potential candidates, without considering the TX descriptor set as
current in one of the two local buffers (the one with the highest priority). As soon as there are identified,
the information related to the source of the two next highest priority messages is stored locally
•
The first candidate is compared to the one already in local buffer and having the lowest priority. If the first
candidate computed is already in one of the two local buffers, nothing needs to be done. If this is not the
case, it is uploaded to provide the next highest priority TX message and will replace the one having the
lowest priority in the local buffers. This is mandatory to ensure there is always a valid TX descriptor with
high priority to provide to PRT, at any time. This is valid, even if the highest priority TX descriptor in local
buffer may, at this time, not be the one with the highest priority. As soon as the first candidate is loaded in
the local buffer, it may become the current one if it is having the highest priority or the next one otherwise.
It may happen that while loading the first candidate, the current one is used as the next TX message.
Nothing can prevent such scenario and either the one with the highest priority is sent first or at the second
place
•
The second candidate is compared with the one previously defined as current. If the second candidate
computed is already in one of the two local buffers, nothing needs to be done. If this is not the case, it is
uploaded to provide the second highest TX message. In this particular case the second candidate
overwrites the other local buffer
Here below is the flow chart of the TX-SCAN process.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4235
v1.1
2025-06-26


Set the TX descriptor fetched  as the new 
first or second potential candidate  
Start
Is there a new valid 
TX descriptor?
N
Y
Compare the TX descriptor to be fetched 
with the one selected in local buffer
New TX descriptor 
in L_MEM?
N
Y
Y
Y
N
Return
Is TX descriptor 
already in local 
buffer?
N
Y
Is TX descriptor having 
higher priority?
Fetch T0 from L_MEM for the TX 
descriptor selected
Get the first TX descriptor from the list of 
valid descriptors
Compare T0 against the first and second 
potential candidates
Upload full TX descriptor buffer from 
L_MEM and replace the TX descriptor in 
local buffer having the  lowest priority
Get the next TX descriptor from the list 
of valid descriptors
N
Is first potential 
candidate in local 
buffer?
N
Set the T0 of the lowest priority TX 
descriptor from the two local buffers as 
the first and second potential candidates 
(initialization)
Is second potential 
candidate in local 
buffer?
N
Upload full TX descriptor buffer from 
L_MEM and replace the TX descriptor in 
local buffer used as the  
Y
Figure 418
Flow chart of the TX-SCAN process
According to the status of the message sent, there will be two different actions:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4236
v1.1
2025-06-26


•
The TX message is sent successfully: the next candidate is considered as the current message. If no new TX
descriptor is available in L_MEM, the next candidate to be fetched is already known, otherwise a new TX-
SCAN run is launched
•
The TX message is not sent successfully: The first next candidate is compare with the current one being not
successful. If the current candidate is having a higher priority it will be considered as the one to select
otherwise the other candidate is used instead. On top of it, the re-transmission counter defined in the
Ni_MH_CFG register will limit the number of possible trials for the same message. If the counter exceeds
the limit, the current candidate will no longer be considered, even it has the highest priority. The TX
message is skipped and the next candidate is taken instead. If the counter does not reach the maximum
value defined and a new message is taken instead, the counter is reset to 0
Some TX-SCAN scenarios are described here below with the following assumptions:
•
Three TX FIFO Queues and 3 TX Priority Queue slots are defined
•
The TX messages are sent without any pause (no RX message received)
•
For the sake of simplicity, only the ID in T0 is used as the main criteria to select the TX message to be sent
•
A TX message is defined per TX descriptor (only Header Descriptor are defined)
The first scenario describes the TX-SCAN based only on TX FIFO Queues running and considering every message
as sent successfully.
0
1
2
ID
ID
ID
-
-
-
-
N
-
18
-
N+1
-
5
-
N+2
-
40
-
N+3
-
30
10
N+4
1
1
38
N+5
0
110
80
N+6
4
24
20
N+7
7
6
6
N+8
11
4
8
N+9
20
29
15
N+10
100
50
39
-
-
-
-
Descriptor number
used by TX FIFO
QUEUE
TX FIFO QUEUES
Figure 419
Scenario 1: TX message requests pending in TX FIFO Queues
ID: TX Header Descriptor ID (one TX message per RX descriptor)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4237
v1.1
2025-06-26


0
1
2
CID
NID
CID
NID
CID
NID
CID
CID
CID
IDIP
MSG 
Result
NIDMNS
NIDMS
0
-
1
18
-
10
-
-
-
-
-
ok
-
1
1
1
0
18
10
-
-
-
1
ok
1
0
2
0
4
18
10
-
-
-
0
ok
0
4
3
4
7
18
10
-
-
-
4
ok
4
7
4
7
11
18
10
-
-
-
7
ok
7
10
5
11
18
10
38
-
-
-
10
ok
10
11
6
11
20
18
38
-
-
-
11
ok
11
18
7
20
18
5
38
-
-
-
18
ok
18
5
8
20
5
40
38
-
-
-
5
ok
5
20
9
20
100
40
38
-
-
-
20
ok
20
38
10
100
40
38
80
-
-
-
38
ok
38
40
11
100
40
30
80
-
-
-
40
ok
40
30
12
100
30
1
80
30
ok
30
1
13
-
-
-
-
-
-
-
-
-
-
-
-
TX Header Descriptor in L_MEM
TX PRIORITY
TX FIFO QUEUES
CAN BUS
TX-SCAN results
TX-SCAN run
Queue slots
0
1
2
Figure 420
Scenario 1: TX-SCAN process
CID: Current TX Header Descriptor ID to consider for TX-SCAN
NID: Next TX Header Descriptor ID to consider for TX-SCAN
NIDMS: Next TX Header Descriptor ID if Message Successful
NIDMNS: Next TX Header Descriptor ID if Message Not Successful
IDIP: TX Header Descriptor ID In Progress
The second scenario describes the TX-SCAN based on TX FIFO Queues and TX Priority Queue slots running and
considering every message as sent successfully.
0
1
2
ID
ID
ID
-
-
-
-
N
-
18
-
N+1
-
5
-
N+2
-
40
-
N+3
-
30
10
N+4
1
1
38
N+5
0
110
80
N+6
4
24
20
N+7
7
6
6
N+8
11
4
8
N+9
20
29
15
N+10
100
50
39
-
-
-
-
Descriptor number
used by TX FIFO
QUEUE
TX FIFO QUEUES
Figure 421
Scenario 2: TX message requests pending in TX FIFO Queues and TX priority queue
slots
ID: TX Header Descriptor ID (one TX message per RX descriptor)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4238
v1.1
2025-06-26


0
1
2
CID
NID
CID
NID
CID
NID
CID
CID
CID
IDIP
MSG
Result
NIDMNS
NIDMS
0
-
1
18
-
10
-
-
-
-
-
ok
-
1
1
1
0
18
10
-
-
-
1
ok
1
0
2
0
4
18
10
-
-
-
0
ok
0
4
3
4
7
18
10
-
1
-
4
ok
1
1
4
7
18
10
-
1
-
1
ok
1
7
5
7
11
18
10
-
-
12
7
ok
7
10
6
11
18
10
38
5
-
12
10
ok
5
5
7
11
18
38
5
-
12
5
ok
5
11
8
11
20
18
38
-
-
12
11
ok
11
12
9
20
18
38
-
-
12
12
ok
12
18
10
20
18
5
38
-
-
-
18
ok
18
5
11
20
5
40
38
-
-
-
5
ok
5
20
12
20
100
40
38
20
ok
20
38
13
-
-
-
-
-
-
-
-
-
-
-
-
-
TX-SCAN run
TX Header Descriptor in L_MEM
CAN BUS
TX-SCAN results
TX FIFO QUEUE
PRIORITY QUEUE
SLOTS
0
1
2
Figure 422
Scenario 2: TX-SCAN process
CID: Current TX Header Descriptor ID to consider for TX-SCAN
NID: Next TX Header Descriptor ID to consider for TX-SCAN
NIDMS: Next TX Header Descriptor ID if Message Successful
NIDMNS: Next TX Header Descriptor ID if Message Not Successful
IDIP: TX Header Descriptor ID In Progress The third scenario describes the TX-SCAN based on TX FIFO Queues
and TX Priority Queue slots running and considering successful and not successful messages with re-
transmission counter set to 1.
0
1
2
ID
ID
ID
-
-
-
-
N
-
18
-
N+1
-
5
-
N+2
-
40
-
N+3
-
30
10
N+4
1
1
38
N+5
0
110
80
N+6
4
24
20
N+7
7
6
6
N+8
11
4
8
N+9
20
29
15
N+10
100
50
39
-
-
-
-
TX FIFO QUEUES
Descriptor number 
used by TX FIFO 
QUEUE
Figure 423
Scenario 3: TX message requests pending in TX FIFO Queues and TX priority queue
slots with retransmission
ID: TX Header Descriptor ID (one TX message per RX descriptor)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4239
v1.1
2025-06-26


0
1
2
CID
NID
CID
NID
CID
NID
CID
CID
CID
IDIP
MSG 
Result
NIDMNS
NIDMS
0
-
1
18
-
10
-
-
-
-
-
ok
-
1
1
1
0
18
10
-
-
-
1
ok
1
0
2
0
4
18
10
-
-
-
0
ok
0
4
3
4
7
18
10
-
1
-
4
nok
1
1
4
4
7
1
-
1
ok
1
4
5
4
7
18
10
-
-
-
4
nok
4
7
6
4
7
18
10
-
-
12
4
ok
7
7
7
7
11
18
10
5
-
12
7
ok
5
5
8
11
18
10
5
-
12
5
ok
5
10
9
11
18
10
38
-
-
12
10
ok
10
11
10
11
20
18
38
-
-
12
11
nok
11
12
11
11
20
18
38
-
-
12
11
nok
12
12
12
20
18
38
-
-
12
12
ok
12
18
13
-
-
-
-
-
-
-
-
-
-
-
-
-
TX-SCAN run
TX Header Descriptor in L_MEM
CAN BUS
TX-SCAN results
TX FIFO QUEUE
PRIORITY QUEUE
SLOTS
0
1
2
Figure 424
Scenario 3: TX_SCAN process
CID: Current TX Header Descriptor ID to consider for TX-SCAN
NID: Next TX Header Descriptor ID to consider for TX-SCAN
NIDMS: Next TX Header Descriptor ID if Message Successful
NIDMNS: Next TX Header Descriptor ID if Message Not Successful
IDIP: TX Header Descriptor ID In Progress
Some debug registers are used to monitor the activity of the TX-Scan:
•
The Ni_TX_SCAN_FC register provides the 2 best candidates selected from the previous TX-Scan run as well
as the 2 best candidates for the current run
•
The Ni_TX_SCAN_BC register gives all the relevant information (The TX FIFO Queue number and TX
descriptor offset in that Queue or the TX Priority Queue slot number) regarding the two best candidates
uploaded in the local buffer and ready to be sent to the PRT
•
The Ni_TX_FQ_DESC_VALID register identifies which TX descriptor is valid, uploaded in the L_MEM and
belonging to the list of potential candidate for the TX-Scan. The information displayed in that register
covers for a given TX FIFO Queue, the current and the next TX descriptors of a queue that may be loaded in
the L_MEM and valid
•
The Ni_TX_PQ_DESC_VALID register provides the information of the slots of the TX Priority Queue loaded in
the L_MEM and valid (ready for the TX-Scan)
22.5.3.21
TX filter
To ensure only declared TX messages can go through, the MH provides to the SW a way to define TX acceptance
filters. Only the TX messages being filtered are considered for the arbitration process. There is the option to
enable or disable this TX filtering process (see Ni_TX_FILTER_CTRL0.EN bit register) and so to leave all TX
messages to go through or not. Several TX filter elements are defined and processed to determine if the TX
message is accepted or rejected. The Ni_TX_FILTER_CTRL0 control register defines how the TX filter element are
used, either standalone or combined.
A TX filter element uses reference values to compare with the TX message header data. The selection of the bit
field to do the comparison can be configured for every TX filter element. Up to 16 TX filter elements can be
defined and are applied to every TX messages when fetched from the L_MEM. There is no way to define those
filters only for some specific queues. They apply to all TX messages whatever the TX FIFO Queues and TX
Priority Queue slots.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4240
v1.1
2025-06-26


When a TX filter error occurs, the faulty TX message is acknowledged with the status report "message rejected
by TX filter". Thus, the SW is able to identify which one has been rejected, while scanning the TX descriptors
from the TX FIFO Queues or TX Priority Queue slots. In order to determine the one being faulty and to avoid
waiting for the TX descriptor, the Ni_TX_FILTER_ERR_INFO register provides the relevant information. The
Ni_TX_FILTER_ERR_INFO.FQ when set to 1 defines a faulty TX message from a TX FIFO Queue otherwise from
the TX Priority Queue. The FIFO Queue number is defined with the Ni_TX_FILTER_ERR_INFO.FQNS_PQS[3:0] bit
field and the slot number with the Ni_TX_FILTER_ERR_INFO.FQNS_PQS[4:0] bit field.
22.5.3.21.1
Global configuration
To protect the setting of those TX filter elements, registers assigned to the configuration are protected, they can
only be accessed while in privileged mode. Only the required application can modify the TX filter setting.
A global TX filter configuration register can be used to define, if the TX messages are accepted or rejected on
match using the Ni_TX_FILTER_CTRL0.MODE bit register.
To notify the system that a TX message is rejected, a TX_FILTER_IRQ interrupt is generated. It is possible to
enable and disable the TX filter interrupt using the Ni_TX_FILTER_CTRL0.IRQ_EN bit register. On top of it, the
faulty TX descriptor is acknowledged immediately with the status rejected by TX filter.
The TX filter elements can be enabled or disabled independently from each other thanks to the
Ni_TX_FILTER_CTRL1.VALID[15:0] bit registers.
In order to define the type of data to be compared with, either the VCID or SDT, the
Ni_TX_FILTER_CTRL1.FIELD[15:0] is used. This register bit field is relevant for the CAN XL protocol only.
The definition of those TX filter elements is done through the setting of registers. Compared to the RX filter, the
TX filter does not require to have access to the L_MEM, settings are done only in registers, see
Ni_TX_FILTER_CTRL0, Ni_TX_FILTER_CTRL1, Ni_TX_FILTER_REFVAL{n} (n € {0, 1, 2, 3}). It is assumed that the TX
filter elements once defined are statics and won’t change over time while the MH is running.
Refer to the TX filter registers for a more detailed description of the TX filter elements.
As the MH can support several CAN protocols, different options are possible on the TX filter, see the next
sections for more details.
22.5.3.21.2
Classical CAN
All Classical CAN TX messages are either accepted or rejected, see Ni_TX_FILTER_CTRL0.CC_CAN bit register.
There is no other option for such Classic CAN protocol. The TX filter elements are only used for the CAN XL
protocol.
22.5.3.21.3
CAN FD
All CAN FD messages are either accepted or rejected, see Ni_TX_FILTER_CTRL0.CAN_FD bit register. There is no
other option for such CAN FD protocol. The TX filter elements are only used for the CAN XL protocol.
22.5.3.21.4
CAN XL
Several options are possible to define the TX filter elements. Two global modes are defined for the overall TX
filter elements, either Allow or Reject on match, see Ni_TX_FILTER_CTRL0.MODE bit-field register. When the
Mode is configured to "Allow" (White List Approach), set by default, a frame is only transmitted, if there is a
match on one of the TX filter elements. When the Mode is configured to "Reject" (Black List Approach) a frame is
only transmitted, if there is no match at all.
Every TX filter elements is provided with a reference value to be compared with and which bit-field in the
message header to be used, either VCID or SDT.
There is three different options on how to define a TX filter elements with the previous definition:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4241
v1.1
2025-06-26


•
Option 1:
In normal mode, the reference value defined in Ni_TX_FILTER_REFVAL{n}.REF_VAL3,
Ni_TX_FILTER_REFVAL{n}.REF_VAL2, Ni_TX_FILTER_REFVAL{n}.REF_VAL1 and
Ni_TX_FILTER_REFVAL{n}.REF_VAL0 (n € {0, 1, 2, 3}) registers, is compared with either SDT or VCID. If e.g.
Ni_TX_FILTER_REFVAL{n}.REF_VAL0 is defined to be compared to VCID and
Ni_TX_FILTER_REFVAL{n}.REF_VAL1 to be compared to SDT than a CAN message will get a match if one of
the two values matches.
Any of the 16 TX filter elements can be used to compare the VCID or the SDT value, refer to the control bit
register Ni_TX_FILTER_CTRL1.FIELD[n] (n € {0, 1, 2, 3, …, 15}) (when the bit n is set to 1, the SDT bit field is
selected for the TX filter element n otherwise VCID).
The Tx filter n is defined as valid or not valid using the Ni_TX_FILTER_CTRL1.VALID[n] (n € {0, 1, 2, 3, …, 15})
bit register. If the TX filter 1 is not considered, just set the Ni_TX_FILTER_CTRL1.VALID[1] to 0. An example of
the option 1 is given in the table below.
For such configuration, the Ni_TX_FILTER_CTRL0.MASK[n] (n € {0, 1, 2, …, 7}) bit register must be set to 0 for
the given TX filter element pair (n and n+1 assuming n is even)
To allow single compare value, meaning one reference value for one match, the
Ni_TX_FILTER_CTRL0.COMB[n] must set to 0 for TX filter element n and n+1 (n being even). In this mode,
there will be always TX filter element n and n+1 available.
•
Option 2:
Based on the normal mode and to increase the possible filtering options, two TX filter elements can be
combined to allow VCID and SDT to be checked as only one filter. However, both values must be identical.
As only a pair of TX filter elements reference values can be combined, Ni_TX_FILTER_REFVAL{n}.REF_VAL0
and Ni_TX_FILTER_REFVAL{n}.REF_VAL1 or Ni_TX_FILTER_REFVAL{n}.REF_VAL2 and
Ni_TX_FILTER_REFVAL{n}.REF_VAL3 (n € {0, 1, 2, 3}) can be used.
The selection of the bit field value to be compared with is defined by the Ni_TX_FILTER_CTRL1.FIELD[n] (n €
{0, 1, 2, 3, …, 15}) bit register. The setting of this register is identical to the option 1.
Only two adjacent TX filter elements can be configured as combined, using the
Ni_TX_FILTER_CTRL0.COMB[n] (n € {0, 1, 2, …, 7}) bit register. When set to 1, TX filter n and n+1 (n being
even) are combined. A an example, for the REF_VAL0/REF_VAL1 in the Ni_TX_FILTER_REFVAL0 register, the
Ni_TX_FILTER_CTRL0.COMB[0] bit must be set to 1.
For such configuration, the Ni_TX_FILTER_CTRL0.MASK[n] (n € {0, 1, 2, …, 7}) bit register must be set to 0 for
the given TX filter element pair (n and n+1 assuming n is even).
The TX filter element n and n+1 which are combined (n being even) need to be set as valid (set to 1) using
the Ni_TX_FILTER_CTRL1.VALID[n] and Ni_TX_FILTER_CTRL1.VALID[n+1] (n € {0, 1, 2, 3, …, 15}) bit register.
This means that combined TX filter elements require two bits to be set in the Ni_TX_FILTER_CTRL1 register.
•
Option 3: In order to compare a range of values, a reference value and a mask are required. To provide such
option, two TX filter elements TX filter n and n+ 1 (n is even) can be paired in a way that one is the value to
be compared with while the other is the mask. As only a pair of TX filter elements reference values can be
combined, Ni_TX_FILTER_REFVAL{n}.REF_VAL0 and Ni_TX_FILTER_REFVAL{n}.REF_VAL1 or
Ni_TX_FILTER_REFVAL{n}.REF_VAL2 and Ni_TX_FILTER_REFVAL{n}.REF_VAL3 (n € {0, 1, 2, 3}) can be used.
In order to set one of the two reference value as a mask, the appropriate bit in the
Ni_TX_FILTER_CTRL0.MASK[n] (n € {0, 1, 2, …, 7}) bit register must be set to 1. As an eaxmple, the
Ni_TX_FILTER_CTRL0.MASK[0] set to 1 is referring to the pair Ni_TX_FILTER_REFVAL0.REF_VAL0 and
Ni_TX_FILTER_REFVAL0.REF_VAL1. In such configuration, the second reference value is the mask, hence the
REF_VAL1 when considering the REF_VAL0/REF_VAL1 pair.
The bit field to be compared with is defined by the Ni_TX_FILTER_CTRL0.FIELD bit field register. For the
above example the Ni_TX_FILTER_CTRL0.FIELD[0] must be set either to 1 for SDT or 0 for VCID. When
Ni_TX_FILTER_CTRL0.MASK[0]=1 then Ni_TX_FILTER_CTRL0.FIELD[1] is ignored by the MH, REF_VAL1 is
interpreted as a mask only.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4242
v1.1
2025-06-26


Only two adjacent TX filter elements can be configured as combined, using the
Ni_TX_FILTER_CTRL0.COMB[n] (n € {0, 1, 2, …, 7}) bit register. When set to 1, TX filter n and n+1 (n being
even) are combined. A an example, for the Ni_TX_FILTER_REFVAL0.REF_VAL0 and
Ni_TX_FILTER_REFVAL0.REF_VAL1 bit field, the Ni_TX_FILTER_CTRL0.COMB[0] bit must be set to 1.
It is essential to enable this pair of TX filter element by setting the appropriate bits in the
Ni_TX_FILTER_CTRL1 register. As an example the Ni_TX_FILTER_CTRL1.VALID[1:0] set to 2’b11 will enable
the Ni_TX_FILTER_REFVAL0.REF_VAL0 (used as reference value) and Ni_TX_FILTER_REFVAL0.REF_VAL1
(used as a mask).
The following example shows 4 reference values defined in the Ni_TX_FILTER_REFVAL0 register, others behave
the same.
Option 1 (single): A TX filter element uses only one reference value and one bit field (VCID or SDT)
Option 2 (Combined with matches): REF_VAL0 and REF_VAL1 are combined to provide a TX filter element that is
able to compare VCID and SDT in the same filter. The same holds for REF_VAL2 and REF_VAL3.
Option 3 (Combined with mask and value): same as Option 2 with the difference that, REF_VAL0 is still the
reference value to compare with (either VCID or SDT) but the REF_VAL1 is the mask to apply.
Table 1050
TX Filter Element options
Reference value
Option 1
(single)
Option 2
(Combined with
matches)
Option 3
(Combined with mask
and value)
REF_VAL0
REF_VAL0 = (VCID or SDT)
REF_VAL0 = VCID or SDT
AND
REF_VAL1 = VCID or SDT
REF_VAL0 (value) =
REF_VAL1 (mask) AND
(VCID or SDT)
REF_VAL1
REF_VAL1 =
(VCID or SDT)
REF_VAL2
REF_VAL2 = (VCID or SDT)
REF_VAL2 = VCID or SDT
AND
REF_VAL3 = VCID or SDT
REF_VAL2 (value)=
REF_VAL3 (mask) AND
(VCID or SDT)
REF_VAL3
REF_VAL3 =
(VCID or SDT)
22.5.3.22
RX filter
The RX filtering provides a way to reject or accept RX messages to the SW as well as to write those messages to
a defined RX FIFO Queue.
Up to 255 RX filters can be defined. The RX filter is defined using an RX filter element (word of 32bit) associated
with up to 2 pairs of reference(32bit)/mask(32bit) values. Those RX filter elements are continuous in the L_MEM
and will be parsed one after the other. Regarding the reference/mask pairs they are defined after the RX filter
element list in the L_MEM, up to 256 pairs can be declared.
To be flexible, an RX filter is made of up to 2 comparisons, each one using a reference value (32bit) and mask
value (32bit) to apply on one of the incoming header message data word (R0, R1 or R3) from the PRT. A
reference/mask pair can apply to any of the RX filter elements.
It is a SW task to define and write the RX filter elements and reference/mask pairs in the L_MEM. There is no
direct access to it through the MH. The SW would need to access the L_MEM directly to program the relevant RX
filter elements and reference/mask pairs.
The process of RX filtering is started as soon as the first 32bit word from the PRT is received, meaning R0. If the
RX filter is fetching a filter element which requires R1, the process is on hold waiting for the 32bit word to be
available. The same applies with R2 if only R0 and R1 are available.
The minimum time dedicated to the RX filtering is defined by the reception of an RX message when it is sent
back to back. The timing window in this case is defined by the reception of two first 32bit word from the PRT
(R0/R1) for the current RX message to the next two 32bit words (R0/R1) of the next message.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4243
v1.1
2025-06-26


22.5.3.22.1
Global configuration
The register Ni_RX_FILTER_CTRL is used to set the general configuration for all RX Filters, a write access in
Privileged mode is required. Once the MH is started (Ni_MH_CTRL.START = 1), the register is write protected.
Here below are the list RX filter configuration setting:
•
The number of RX filter elements is defined in the Ni_RX_FILTER_CTRL.NB_FE[7:0] bit field register
•
Non-matching CAN frames can be accepted or rejected by configuring the Ni_RX_FILTER_CTRL.ANMF bit
register to 1. If non-matching frames are accepted, they are stored in the default RX FIFO Queue defined by
the Ni_RX_FILTER_CTRL.ANMF_FQ[2:0] bit field register
•
If the RX filtering is not done in time, the data stored in the RX DMA FIFO may lead to an overflow. There is
the option to allow the reception of such frames to the default RX FIFO Queue (defined by the
Ni_RX_FILTER_CTRL.ANMF_FQ[2:0] bit field register). This feature is only enabled when setting the
Ni_RX_FILTER_CTRL.ANFF bit field register to 1. The Ni_RX_FILTER_CTRL.THRESHOLD[4:0] defines the level
in the RX DMA FIFO to reach before sending the non-filtered frames to the default RX FIFO Queue
•
The default RX FIFO Queue number, to write RX message data when non-matching frames OR non-filtered
frames are accepted, is defined in the Ni_RX_FILTER_CTRL.ANMF_FQ[2:0] bit field register. This default RX
FIFO Queue value is considered if either the Ni_RX_FILTER_CTRL.ANMF bit or the Ni_RX_FILTER_CTRL.ANFF
bit is set to 1. It is essential to enable and start this default RX FIFO Queue prior starting the PRT
22.5.3.22.2
Reference and Mask pair
Two comparisons in the RX Filter Element can be defined. Each comparison require a reference value (REFm)
and a mask (MSKm) (m € {0, 1, 2, …, 255}). The reference and mask value are 32bit raw data. The 32bit reference
value is compared with the first (R0), the second (R1) or the third (R3) word (32bit) of the RX message header
(coming from the PRT) after applying the 32bit mask value.
The reference value and the mask are defined as a pair of two consecutive words of 32bit in L_MEM, starting
with the REFm. Up to 256 pairs can be defined for the overall RX filter elements. All the pairs of reference value
and mask are appended after the RX filter elements section in L_MEM, see MH Software Interface chapter. Any
of the 256 reference/mask pairs can be selected for a given RX filter element.
The RX filter element will use an index to identify the position of the pairs to be used. The first pair is having the
index 0, the second the index 1 and so on. The RX Filter Element is then referring to this index in the bit field
CREFI0 and CREFI1 (see RX Filter Element Definition chapter), to identify the right pair to use.
22.5.3.22.3
RX Filter Element definition
For every filter element it is possible to:
•
Define which RX FIFO Queue to use if RX message is accepted or rejected on match
•
Generate an interrupt when a filter matches, triggering the signal RX_FILTER_IRQ to the system
•
Define if the RX message expected is being defined into the black list (BLK bit-field)
•
Define up to 2 comparisons with the option to:
-
Select the word index in the header message to look at (limited to R0, R1 and R2), see WI0 or WI1. It is
important to note that R2 is a header data for the CAN XL while a payload data in case of Classic CAN
and CAN FD. In case a remote frame is detected, any filter looking at R2 will be discarded
-
Define the reference value and mask index to perform the comparison, see CREFI0 or CREFI1 bit-field
-
Reject or accept on match, see AR0 and AR1
-
Perform two comparison for a match. When WI0 and WI1 are both different from 0, both comparisons
are performed to know if there is a match. In such configuration, the AR0 and AR1 must be identical. In
case they are not, only the comparison 0 is performed to check for a match
RX filter element is described in the following table:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4244
v1.1
2025-06-26


Table 1051
RX filter element
Filter Element
Section
Bit-field
Name
Description
FEn
Control
FEn[31:28]
FIFO[3:0]
RX FIFO Queue
number to store the
receive CAN data
FEn[27]
IRQ
Interrupt: When set
to 1 an interrupt
is triggered to the
system when a
match is detected
FEn[26]
BLK
BlackList: When set
to 1 the BLK bit
defined in the RX
message header is
set to 1
FEn[25:24]
Reserved
 
Comparison 1 (only
considered with
comparison 0)
FEn[23]
Reserved
 
FEn[22]
AR1
See AR0 bit-field
description. Must
always be equal to
AR0.
FEn[21:20]
WI1[1:0]
See WI0 bit-field
description
FEn[19:12]
CREFI1[7:0]
See CREFI0 bit-field
description
Comparison 0
FEn[11]
Reserved
 
FEn[10]
AR0
Accept or Reject on
match: when set to
1 the RX message
is rejected on match
otherwise accepted
on match
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4245
v1.1
2025-06-26


Table 1051
(continued) RX filter element
Filter Element
Section
Bit-field
Name
Description
FEn[9:8]
WI0[1:0]
Word Index: provide
the index of the
RX message header
word to compare, 1
for R0, 2 for R1 and 3
for R2. R2 will not be
considered as a valid
index for remote
frame or Classical
CAN frame with
no payload data
or CAN FD frame
without payload, the
comparison is then
canceled. When set
to 0, no comparison
is performed
FEn[7:0]
CREFI0[7:0]
Comparison
Reference Index:
provide the index of
the reference pair
(value and mask)
to be used for
comparison
The RX filter element can be used in two different modes:
•
Comparison 0 only ( WI0 > 0 and WI0 = 0 )
•
Comparison 0 and comparison 1 ( WI0 > 0 and WI1 > 0 )
It is essential to understand that if the Comparison 1 is defined, this RX Filter element will not be considered if
the Comparison 0 is not defined. In such case, the filter element is skipped.
Each time an RX message is received, the RX filtering is triggered and start the following sequence:
•
Fetch the first filter element from L_MEM. The start address of this first filter element is defined in
Ni_RX_FILTER_MEM_ADD.BASE_ADDR[15:0] register
•
If the conditions listed below are met, the RX filter element will be discarded and the next filter element be
fetched (if there is one available). In all other cases, go to next step:
-
WI0 = 0
-
WI0 = 3 and the frame is either a Classic CAN/CAN FD without payload or a Classic CAN remote frame
-
WI1 = 3 and the frame is either a Classic CAN/CAN FD without payload or a Classic CAN remote frame
-
WI0 > 3 and WI1 > 3 and AR0/AR1 not equal
•
For the comparison 0, using the index CREFI0, the two words for the reference value and mask are fetched
from L_MEM
•
The comparison 0 is done between the word defined by the index WI0 and the reference value/mask
fetched earlier. According to the WI1 bit several actions are taken:
-
WI1 set to 0 (Comparison 0 only): if there is a match, the RX filter will look at the AR0 bit to identify
what to do with the RX message. It would then be accepted or rejected and the RX filter stops. If there
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4246
v1.1
2025-06-26


is no match, the RX filter keeps going with the next filter element, if there is one available, otherwise
stops
-
WI1 > 0 (Comparison 0 and Comparison 1 expected): if there is a match on the comparison 0, the RX
filter will wait for the result of the comparison 1 to decide what to do with the RX message. If there is
no match on comparison 0, the RX filter keeps going with the next filter element, if there is one
available, otherwise stops
•
The comparison 1 is done between the word defined by the index WI1 and the reference value/mask
fetched earlier. If there is a match, the RX filter will look at the AR0 bit to identify what to do with the RX
message. It would then be accepted or rejected and the RX filter stops. If there is no match, the RX filter
keeps going with the next filter element, if there is one available, otherwise stops
22.5.3.22.4
RX Header Descriptor updates
When an RX message is accepted, the index of the RX filter element which has accepted the message on match
is logged inside the RX Header Descriptor. In case the RX message is rejected, no information is provided to the
SW.
The filtering process writes filtering information to three bit-fields of the header data (see RX Message header
definition chapter):
•
The BLK bit in the header data of the RX message can be set by an RX filter element to indicate to the SW a
non expected messages. When the SW is parsing the RX message Header Descriptor it can easily identify
them once available in S_MEM
•
The FIDX[7:0] bit-field is used to provide the information of the filter element index which has been
triggered for that message
•
The FAB bit field when set to 1, indicates to the SW that there was not enough time to complete the RX
filtering process. This bit will be set when such issue occurs and only if the Ni_RX_FILTER_CTRL.ANFF bit
register is set to 1 and Ni_RX_FILTER_CTRL.THRESHOLD[4:0] bit field greater than 0 (threshold mechanism
active)
•
The FM bit-field when set to 1, notifies the SW that there was a match on the RX filtering. When the FAB and
FM bit-fields are set to 0, the RX filtering process ending with no match
22.5.3.22.5
MH behavior according to RX Filter setting
The RX filter elements are sequentially read from the L_MEM. This process continues up to the point, where the
RX filter result is known and the message can either be accepted or rejected.
In case the RX filter selects an RX FIFO Queue that is not enabled, the incoming frame is considered as a non-
matching frame and is discarded, the RX_ABORT_IRQ is set to the system.
In a normal situation, when the RX filter result arrives in time, the RX message data are sent to the appropriate
RX FIFO Queue or are rejected.
A default RX FIFO Queue can be defined for some configuration when Ni_RX_FILTER_CTRL.ANMF_FQ[2:0] is
defined and Ni_RX_FILTER_CTRL.ANMF set to 1.
A threshold can be defined on the RX DMA FIFO to manage not filtered frames. The Ni_RX_FILTER_CTRL.ANFF
must be set to 1 to activate the function and the Ni_RX_FILTER_CTRL.THRESHOLD[4:0] bit field defining the
threshold value must be greater than 0. Once activated, those frames are sent to a default RX FIFO Queue, see
Ni_RX_FILTER_CTRL.ANMF_FQ[2:0] bit field register.
Here below is the summary of the RX filter behavior when considering Ni_RX_FILTER_CTRL.NB_FE[7:0],
Ni_RX_FILTER_CTRL.ANMF and Ni_RX_FILTER_CTRL.ANFF bit fields:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4247
v1.1
2025-06-26


Table 1052
RX Filter behavior
ANMF
NBFE[7:0]
ANFF
RX Filter status
0
0
X
All RX frames are rejected
1
0
X
All RX messages are
accepted and are going to
the default RX FIFO Queue
defined by
Ni_RX_FILTER_CTRL.ANM
F_FQ[2:0]
0
>0
0
Frames with match are
going to RX FIFO Queues
Frames with no match are
rejected
No threshold monitoring
is performed during RX
filtering
1
Frames with match are
going to RX FIFO Queues
Frames with no match are
rejected
Frames reaching the RX
DMA FIFO level set in the
Ni_RX_FILTER_CTRL.THRE
SHOLD[4:0] register and
not filtered, are going to
the default RX FIFO Queue
defined in
Ni_RX_FILTER_CTRL.ANM
F_FQ[2:0] register
1
>0
0
Frames with match are
going to RX FIFO Queues
Frames with no match are
going to the default RX
FIFO Queue defined by
Ni_RX_FILTER_CTRL.ANM
F_FQ[2:0]
No threshold monitoring
is performed during RX
filtering
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4248
v1.1
2025-06-26


Table 1052
(continued) RX Filter behavior
ANMF
NBFE[7:0]
ANFF
RX Filter status
1
Frames with match are
going to RX FIFO Queues
Frames with no match are
going to the default RX
FIFO Queue defined by
Ni_RX_FILTER_CTRL.ANM
F_FQ[2:0]
Frames reaching the RX
DMA FIFO level set in the
Ni_RX_FILTER_CTRL.THRE
SHOLD[4:0] register and
not filtered, are going to
the default RX FIFO Queue
defined in
Ni_RX_FILTER_CTRL.ANM
F_FQ[2:0] register
The MH will manage the RX message differently if a default RX FIFO Queue is defined or not with or without a
threshold defined. The configurations being able to use the two last options are described below:
Scenario 1:
Threshold mechanism is not active (Ni_RX_FILTER_CTRL.ANFF bit set to 0 and Ni_RX_FILTER_CTRL.NBFE[7:0] >
0).
Two scenarios can occur:
•
The RX filtering result is not known before receiving the first word of the next RX message and the amount
of the CAN frame data is lower than the RX DMA FIFO. The RX message is discarded with the RX_ABORT_IRQ
interrupt and the RX_FILTER_ERR is also triggered to the system.
•
In case the amount of data received, while waiting the RX filtering result, does exceed the maximum RX
DMA FIFO size, the RX message is discarded with the RX_ABORT_IRQ interrupt. The DP_DO_ERR interrupt is
triggered to notify an RX DMA FIFO overflow.
Scenario 2: Threshold mechanism is active (Ni_RX_FILTER_CTRL.ANNF bit set to 1 and
Ni_RX_FILTER_CTRL.NBFE[7:0] > 0 and Ni_RX_FILTER_CTRL.THRESHOLD[4:0] value is greater than 0). This
backup solution to avoid losing the RX message is possible due to the monitoring of the RX DMA FIFO level and
a threshold configured in the Ni_RX_FILTER_CTRL.THRESHOLD[4:0] bit field register (see next section for more
details).
Two scenarios can occur:
•
The RX filtering result takes a very long time and the frame size is large. Once the threshold is reached, the
RX descriptor from the default RX FIFO Queue is fetched from the S_MEM. Then, the RX buffer address
pointer defined in the RX descriptor is used to write the first burst of data to the default RX FIFO Queue.
•
The RX filtering result takes a very long time and the frame size does not reach the threshold value. As long
as no new message is received, the RX filtering keeps going and a result could be expected in time. In case a
new RX message is received, the current RX message is discarded with the RX_ABORT_IRQ interrupt. The
RX_FILTER_ERR is also triggered to the system to identified a potential issue with the RX filter.
Here below is a table to summarize the different scenarios:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4249
v1.1
2025-06-26


Table 1053
RX Filter scenarios
Frame length
Filter result when
threshold is
reached
Filter result when
next RX message
arrives
Action of MH
Comments
Short
Not possible
Available
Store frame in RX
FIFO Queue defined
by RX filter result
Normal behavior
Short
Not possible
Not available
Discard frame
The overall
processing time is
too long due to a
high number of
filters and/or a low
core clock
frequency,
Long
Available and ANFF =
X
Not considered
Store frame in RX
FIFO Queue defined
by RX filter result
Normal behavior
Long
Not available and
ANFF = 0
Not considered
Keeps waiting for
the RX filter result
Within this case, the
message is written
in time to the right
RX FIFO Queue or
discarded due to
data overflow on the
RX DMA FIFO
Long
Not available and
ANFF = 1
Not considered
Store frame in
default RX FIFO
Queue
Threshold must be
set such a way there
is enough time to
fetch RX descriptor
and to write burst
data to S_MEM,
22.5.3.22.6
Threshold computation
The MH uses the Ni_RX_FILTER_CTRL.THRESHOLD[4:0] only when the Ni_RX_FILTER_CTRL.ANFF bit is set to 1
and the threshold value is greater than 0. The threshold value to be configured by the user depends on the
S_MEM latency, the CAN protocols supported and the CAN XL data bit rate. The RX DMA FIFO has a size of 32
words (128 byte).
Case 1: Only Classical CAN and/or CAN FD messages are received: The RX DMA FIFO is capable of storing a
complete Classical CAN or CAN FD message. The feature Ni_RX_FILTER_CTRL.ANFF should not be used.
Note: When Ni_RX_FILTER_CTRL.ANFF=1 and Ni_RX_FILTER_CTRL.THRESHOLD[4:0] is set to 19 or larger, then
the threshold will never be reached. This implicitly disables the threshold, because it will be never be reached
by a Classical CAN or CAN FD message.
Case 2: Also CAN XL messages are received: CAN XL messages can be much longer than the RX DMA FIFO size.
When the fill level of the RX DMA FIFO reaches the threshold, the MH will fetch the RX descriptor from the
default RX FIFO Queue and will write the first burst of data stored in the RX DMA FIFO. For the case, that no RX
filter result is available at the point in time the threshold is reached, this mechanism prevents a data overflow
that would occur on the RX DMA FIFO and allows the reception of the message. The threshold divides the time
budget provided by the RX DMA FIFO into two parts: (1) time to do the RX Filtering, (2) Time to fetch the RX
Descriptor from S_MEM and to write the first burst of data to S_MEM. The user should configure the threshold
as large as possible, to give the RX Filtering enough time, but as low as necessary to be able to receive the
message, in case RX Filtering is not finished yet.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4250
v1.1
2025-06-26


22.5.3.22.7
RX Filter processing time
The number of accesses to evaluate an RX filter element is defined as follow:
Classical CAN and CAN FD:
One single word access (definition of the filter element) and 2 words for the mask and value to compare with
CAN XL:
same as Classical CAN / CAN FD or one single word and 2 reads of 2 words for the 2 mask and value to compare
with
The RX filter element access time depends on the read latency Lr (defined in number of CLK clock cycles):
Classical CAN and CAN FD:
RXFilter element processin g time µs
=
Lr + 2 + Lr + 1 + 2
*
1
CLK MHz
CAN XL:
RXFilter element processin g time µs
=
Lr + 2 + Lr + 1 + 2
*
1
CLK MHz
witℎone comparision
RXFilter element processin g time µs
=
Lr + 2 + 2 * Lr + 1 + 2
*
1
CLK MHz
witℎ
two comparisions
The overall RX filter time is computed as follow:
RX Filter processin g time µs
=
Nbfe1c *
Lr + 2 + Lr + 1 + 2
+ Nbfe2c *
Lr + 2 + 2 * Lr + 1
+ 2
*
1
CLK MHz
where Nbfe1c = Number of filter element with 1 comparison, Nbfe2c = Number of filter element with 2
comparisons and the read latency Lr (defined in number of CLK clock cycles).
22.5.3.23
Local Memory Controller
The XCAND_MH_MEM_CTRL block is in charge of reading and writing the L_MEM. The Local Memory Controller
is managing all requests and data transfer for the different blocks running concurrently:
•
The writes of TX descriptors from the XCAND_DESC block
•
The read of RX filter elements from the XCAND_RX_PATH
•
The read of TX descriptor from XCAND_TX_PATH when a message has to be sent
•
The read of TX descriptor from XCAND_TX_PATH for TX SCAN (selection of the highest priority TX message)
22.5.3.23.1
Local Memory side band signals
It is assumes that the L_MEM provides safety measure to protect data. The safety protection implemented in
the L_MEM could either report error when reading a data (Single Error Detection) or be able to correct it in some
cases (Single Error Correction and Double Error Detection for example). To address those two options, two
input side band signals denominated MEM_SFTY_CE and MEM_SFTY_UE, are provided with the MEM_AXI
interface.
Here below are the expected behavior of those signals and the expected response on the MEM_AXI interface:
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4251
v1.1
2025-06-26


•
Error Detection Only: When a corrupted data is read from the L_MEM, a pulse of one CLK clock cycle must
be generated on the MEM_SFTY_UE input signal. The MEM_AXI interface must report a SLVERR response on
the MEM_AXI bus. The MEM_SFTY_UE input signal can be fully asynchronous to the MEM_AXI interface.
•
Error Detection and Correction: When a corrupted data is read from the L_MEM but is corrected, a pulse of
one CLK clock cycle must be generated on the MEM_SFTY_CE input signal. The MEM_AXI interface must
report an OKAY response on the MEM_AXI bus. The MEM_SFTY_UE input signal can be fully asynchronous to
the MEM_AXI interface.
22.5.3.23.2
Address bus
The XCAND_MH_MEM_CTRL block is able to address up to 64 Kbytes memory space (MEM_AXI_AWADDR[15:0]
and MEM_AXI_ARADDR[15:0]).
The address burst value is always 32 bit aligned.
22.5.3.23.3
Burst size
The maximum number of bytes to transfer in each data transfer is fixed and set to 4. Any read or write transfer is
always using 32 bit.
As a consequence, the write strobe signals are not managed by the XCAND_MH_MEM_CTRL as all 4 bytes are
always written.
22.5.3.23.4
Burst length
The Local Memory Controller for the AXI read and write transfers supports INCR burst length 1, 2 and 8
considering an AXI 32 bit data bus width.
The burst lengths from/to the L_MEM are defined based on the data type of information to be used. Here below
are the expected burst length from/to the different sub-blocks:
•
XCAND_MH_DESC: This sub-block writes the TX descriptor allocated to TX FIFO Queues and TX Priority
Queue slots. The burst length is fixed and set to 8 × 32 bit . There is no read access from this sub-module
•
XCAND_MH_RX: This sub-block reads the RX filter elements and reference/mask values to perform the RX
message filtering. The burst length is set to 1 × 32 bit for the RX filter element and 2 × 32bit for the
reference/mask value. There is no write access from this sub module
•
XCAND_MH_TX: This sub-block reads two type of information, the TX descriptor to be sent as the next
candidate to the TX_MSG interface and part of the TX descriptors assigned to TX FIFO Queues and TX
Priority Queue slots. A fixed burst length of 1 × 32 bit is used for the TX SCAN and 8 × 32 bit is for the TX
descriptor
22.5.3.23.5
Outstanding
As the L_MEM can be shared across several X_CAN instances and many accesses are required for RX filtering and
TX SCAN, 2 outstanding read transactions can supported. As only a few writes are required from the MH point of
view, only 1 outstanding write transaction is supported.
22.5.3.23.6
Burst type
The only burst type supported is the burst incrementing INCR.
The WRAP/FIXED burst type is not supported.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4252
v1.1
2025-06-26


22.5.3.23.7
Multi-region
The Local Memory Controller does not support multiple region interfaces.
22.5.3.23.8
Memory attributes
The memory attributes for the read or write accesses to the L_MEM are Normal, Non-modifiable (Non-
cacheable in AXI3) and Non-bufferable. No read-allocate nor No Write-allocate are expected on this interface
and would be set to 1'b0.
As a reminder, Non-bufferable means (See [3] for mode details):
•
The write response must be obtained from the destination
•
Read data must be obtained from the destination
•
Transactions are Non-modifiable
•
Read and write transactions from the same ID to addresses that overlap must remain ordered
As a reminder, Non-modifiable means:
•
A Non-modifiable transaction must not be split into multiple transactions or merged with other
transactions
•
In a Non-modifiable transaction, the parameters AxADDR, AxSIZE, AxLEN, AxBURST and AxPROT must not
be changed
22.5.3.23.9
Access permissions
It is considered that any access is always defined as a Data, Secure and the operating mode is Unprivileged, see
[3] for more details. Those setting cannot be changed by SW.
Therefore, any access from the MH which needs to be non-secure, must be managed with an external and
dedicated logic attached to the MEM_AXI interface.
As an example, the RX filter elements and reference/mask can be stored in a secure area in the L_MEM, as a
consequence the MEM_AXI_ARPROT[1] and MEM_AXI_AWPROT[1] are set to 0B. Doing so, the MH is able to read
secure and non-secure data in the L_MEM, with the assumption that non-secure area is always accessible by a
secure access. This means MEM_AXI_A(W/R)PROT[2:0] is set to 000B.
22.5.3.23.10
Transaction ID
The L_MEM Controller builds the ID of every burst access based on the source of request. It provides a way to
track which sub-block is doing the access at any time on the system bus.
For the AXI read interface, the MEM_AXI_ARID[1:0] defines the channel number as follow:
00B => XCAND_MH_TX reads TX descriptor from L_MEM
2’b01 => XCAND_MH_TX read part of TX descriptor from L_MEM for TX SCAN
10B => XCAND_MH_RX reads RX filter elements and reference/mask values from L_MEM
11B => Reserved
For the AXI write interface, the MEM_AXI_AWID[0] defines the channel number as follow:
0B => XCAND_MH_DESC writes TX descriptor to L_MEM
1B => Reserved
22.5.3.24
Trace and debug
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4253
v1.1
2025-06-26


22.5.3.24.1
Interrupts
For integration verification it is possible to trig functional and safety interrupts by SW. Here is the procedure:
1.
Unlock the Ni_DEBUG_TEST_CTRL register, see section Lock Mechanism Protection in Register
Protection chapter
2.
Write the Ni_DEBUG_TEST_CTRL.TEST_IRQ_EN bit to 1 in privileged mode
3.
Once the access to the Ni_INT_TEST0 and Ni_INT_TEST1 registers are allowed (always accessible once
opened), write 1 to the relevant bit to set the appropriate interrupt line.
Re-lock the access to the Ni_INT_TEST0 and Ni_INT_TEST1 registers. Step 1) and 2) needs to be done with
Ni_DEBUG_TEST_CTRL.TEST_IRQ_EN bit set to 0 instead.
22.5.3.24.2
Hardware debug port
The 16bit HDP bus provides some visibility to internal signals to debug the MH. By default, there is no activity
on the HDP bus.
To enable the toggling of the HW signal on the HDP bus, set the Ni_DEBUG_TEST_CTRL.HDP_EN bit to 1.
1) Unlock the Ni_DEBUG_TEST_CTRL register, see section Lock Mechanism Protection in Register Protection
chapter
2) Write the Ni_DEBUG_TEST_CTRL.HDP_EN bit to 1 and the selected set to be monitored on the HDP using the
Ni_DEBUG_TEST_CTRL.HDP_SEL[2:0]. This access must be done in privileged mode.
To disable the Hardware Debug Port monitoring, do the previous set with Ni_DEBUG_TEST_CTRL.HDP_EN bit to
0.
Up to 8 sets can be defined using the Ni_DEBUG_TEST_CTRL.HDP_SEL[2:0] bit field. When the value is set to n
the set n is selected on the HDP bus.
INTERRUPTS:
The interrupt line assigned to the RX or TX FIFO Queue can be monitored individually. Therefore, it is possible to
track the activity of the FIFO Queues while they are running. To allow the visibility of all MH interrupts, on the
same HDP set, the TX FIFO Queues interrupt lines are gathered to only one single HW internal signal called
TX_FQ_IRQ_ORED (the interrupts are 'ored'). The same is done on the RX FIFO Queues and so the interrupts are
'ored' to provide the HW internal signal RX_FQ_IRQ_ORED.
Note:
There are two possible sources to trig an interrupt (valid for TX_FQ_IRQ[7:0], RX_FQ_IRQ[7:0] and
TX_PQ_IRQ interrupt lines): one is related to functional and the other one is from the Ni_INT_TEST0
and Ni_INT_TEST1 registers (for integration test only). Only the functional interrupt source is
displayed on the HDP set. Therefore, when an interrupt is triggered, by a write access to either
Ni_INT_TEST0 or Ni_INT_TEST1 register, it will not be visible on the HDP. Nevertheless, the interrupt
line is properly set at the MH interface.
INTERFACES:
To ensure the traceability of the traffic going from and to the MH, the following interfaces can be monitored
through one of the HDP sets:
•
DMA_AXI interface (control signals) used to manage RX/TX descriptors and RX/TX message data
•
MEM_AXI interface (control signals) used to manage TX descriptors for TX-Scan and RX filtering
•
TX_MSG interface (control signals) used to transmit TX message from MH to PRT
•
RX_MSG interface (control signals) used to receive RX message from PRT to MH
The table below shows the description of sets available on the MH HDP bus.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4254
v1.1
2025-06-26


Table 1054
Signals available on the HDP bus
MH_HDP[1
5:0]
Set 0
(interrupt
s)
Set 1 (RX
and TX
path)
Set 2 (TX
Scan)
Set 3
(MH_PRT
Interface)
Set 4
(Write AXI
DMA
interface)
Set 5
(Read AXI
DMA
interface)
Set 6
(Write AXI
MEM
interface)
Set 7
(Read AXI
MEM
interface)
15
TX_FQ_IR
Q[7]
CLK
FH_OFFSE
T[9]
CLK
CLK
CLK
CLK
CLK
14
TX_FQ_IR
Q[6]
TX_FQ_IR
Q_ORED
FH_OFFSE
T[8]
TX_MSG_
WVALID
DMA_AXI_
BID[0]
DMA_AXI_
RID[1]
MEM_AXI_
BID[0]
MEM_AXI_
RID[1]
13
TX_FQ_IR
Q[5]
RX_FQ_IR
Q_ORED
FH_OFFSE
T[7]
TX_MSG_
WUSER[1]
DMA_AXI_
BVALID
DMA_AXI_
RID[0]
MEM_AXI_
BVALID
MEM_AXI_
RID[0]
12
TX_FQ_IR
Q[4]
TX_PQ_IR
Q
FH_OFFSE
T[6]
TX_MSG_
WUSER[0]
DMA_AXI_
BREADY
NA
MEM_AXI_
BREADY
NA
11
TX_FQ_IR
Q[3]
RX_FILTER
_ERR
FH_OFFSE
T[5]
TX_MSG_
WREADY
DMA_AXI_
BRESP[1]
DMA_AXI_
RRESP[1]
MEM_AXI_
BRESP[1]
MEM_AXI_
RRESP[1]
10
TX_FQ_IR
Q[2]
RX_FILTER
_IRQ
FH_OFFSE
T[4]
TX_MSG_B
VALID
DMA_AXI_
BRESP[0]
DMA_AXI_
RRESP[0]
MEM_AXI_
BRESP[0]
MEM_AXI_
RRESP[0]
9
TX_FQ_IR
Q[1]
TX_FILTER
_IRQ
FH_OFFSE
T[3]
TX_MSG_B
USER_STA
TUS[2]
DMA_AXI_
WREADY
DMA_AXI_
RREADY
MEM_AXI_
WREADY
MEM_AXI_
RREADY
8
TX_FQ_IR
Q[0]
STAT_IRQ
FH_OFFSE
T[2]
TX_MSG_B
USER_STA
TUS[1]
DMA_AXI_
WVALID
DMA_AXI_
RVALID
MEM_AXI_
WVALID
MEM_AXI_
RVALID
7
RX_FQ_IR
Q[7]
TX_ABORT
_IRQ
FH_OFFSE
T[1]
TX_MSG_B
USER_STA
TUS[0]
DMA_AXI_
WLAST
DMA_AXI_
RLAST
MEM_AXI_
WLAST
MEM_AXI_
RLAST
6
RX_FQ_IR
Q[6]
RX_ABORT
_IRQ
FH_OFFSE
T[0]
TX_MSG_B
READY
NA
DMA_AXI_
ARID[1]
NA
MEM_AXI_
ARID[1]
5
RX_FQ_IR
Q[5]
DP_SEQ_E
RR
FH_FQN_P
QN[4]
RX_MSG_
WVALID
DMA_AXI_
AWID[0]
DMA_AXI_
ARID[0]
MEM_AXI_
AWID[0]
MEM_AXI_
ARID[0]
4
RX_FQ_IR
Q[4]
DP_DO_ER
R
FH_FQN_P
QN[3]
RX_MSG_
WUSER[2]
DMA_AXI_
AWVALID
DMA_AXI_
ARVALID
MEM_AXI_
AWVALID
MEM_AXI_
ARVALID
3
RX_FQ_IR
Q[3]
STOP_IRQ
FH_FQN_P
QN[2]
RX_MSG_
WUSER[1]
DMA_AXI_
AWREADY
DMA_AXI_
ARREADY
MEM_AXI_
AWREADY
MEM_AXI_
ARREADY
2
RX_FQ_IR
Q[2]
RESP_ER
R[1]
FH_FQN_P
QN[1]
RX_MSG_
WUSER[0]
DMA_AXI_
AWLEN[2]
DMA_AXI_
ARLEN[2]
MEM_AXI_
AWLEN[2]
MEM_AXI_
ARLEN[2]
1
RX_FQ_IR
Q[1]
RESP_ER
R[0]
FH_FQN_P
QN[0]
RX_MSG_
WREADY
DMA_AXI_
AWLEN[1]
DMA_AXI_
ARLEN[1]
MEM_AXI_
AWLEN[1]
MEM_AXI_
ARLEN[1]
0
RX_FQ_IR
Q[0]
ENABLE
FH_PQ
ENABLE
DMA_AXI_
AWLEN[0]
DMA_AXI_
ARLEN[0]
MEM_AXI_
AWLEN[0]
MEM_AXI_
ARLEN[0]
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4255
v1.1
2025-06-26


22.5.3.24.3
TX-scan
In order to keep track of the TX-Scan process, some registers provide the relevant information to observe the
selection of the next TX message, meaning, which TX FIFO Queue number and which message within this FIFO
Queue is selected, or which TX Priority Queue slot number. The Ni_TX_SCAN_FC and Ni_TX_SCAN_BC registers
are monitoring the TX-Scan activity, see Software Interface chapter for more details. The duration of a CAN
frame is large enough to make it possible, to read those registers in time and get some valuable information.
The Ni_TX_SCAN_FC register provides the information of the source of the four first candidates selected by the
TX-Scan., meaning the TX FIFO Queue number or the TX Priority Queue slot number. The source of the two first
candidates are defined by:
•
The Ni_TX_SCAN_FC.FQ_PQ{n} (n € {0, 1}) bit register: when set to 0, the first or second candidate is a TX
FIFO Queue. In fact, Ni_TX_SCAN_FC.FQ_PQ0 = Ni_TX_SCAN_BC.FH_PQ and Ni_TX_SCAN_FC.FQ_PQ1 =
Ni_TX_SCAN_BC.SH_PQ, see Ni_TX_SCAN_BC register description below
•
The Ni_TX_SCAN_FC.FQN_PQSN{n} (n € {0, 1}) bit register: define either a TX FIFO Queue number or a TX
Priority Queue slot number according to the Ni_TX_SCAN_FC.FQ_PQ{n} (n € {0, 1}) bit register. In fact,
Ni_TX_SCAN_FC.FQN_PQSN0 = Ni_TX_SCAN_BC.FH_FQN_PQSN and Ni_TX_SCAN_FC.FQN_PQSN1 =
Ni_TX_SCAN_BC.SH_FQN_PQSN, see Ni_TX_SCAN_BC register description below
•
The two sources of the last two candidates are monitoring the selection of a TX-Scan. It is essential to note
that the value in those registers is not stable, compare to the source of the two first candidate, and will
change during a TX-Scan run. When the Ni_TX_SCAN_FC.FQ_PQ{n} (n € {0, 1, …, 3}) is set to 0, the candidate
n is a TX FIFO Queue, looking at the Ni_TX_SCAN_FC.FQN_PQSN{n} (n € {0, 1, …, 3} bit field, provides the
number. If the Ni_TX_SCAN_FC.FQ_PQ{n} (n € {0, 1, …, 3}) is set to 1, the candidate n is a TX Priority Queue
and the slot number is defined by the Ni_TX_SCAN_FC.FQN_PQSN{n} (n € {0, 1, …, 3} bit field.
The value of the Ni_TX_SCAN_FC register is updated when a new TX Scan result is available, see TX-SCAN
chapter.
The Ni_TX_SCAN_BC register gives the full reference of the first and second highest priority messages, defined
and uploaded at the end of a TX-Scan run (see Buffer A and B in TX MESSAGE HANDLER chapter). The first
highest candidate is the one selected and sent to the CAN bus. The second highest priority candidate is the TX
message to be sent, once the transmission of the first highest candidate is completed. The register values
provide full visibility of the two message candidates stored locally in Buffer A and B, see TX MESSAGE HANDLER
chapter for more details. As such, those registers are stable over time and do change only after at the end of a
TX-Scan.
The first best candidate is defined by:
•
The Ni_TX_SCAN_BC.FH_PQ bit register: when set to 0, the candidate is a TX FIFO Queue
•
The Ni_TX_SCAN_BC.FH_FQN_PQSN bit register: define either a TX FIFO Queue number or a TX Priority
Queue slot number according to the Ni_TX_SCAN_BC.FH_PQ bit register
•
The Ni_TX_SCAN_BC.FH_OFFSET bit register: define the offset (in 32byte) of the TX descriptor selected,
starting from the initial start address of the TX FIFO Queue (defined in the Ni_TX_SCAN_BC.FH_FQN_PQS
bit register) with TX descriptor address = TX FIFO Queue start address + offset * 32byte. When the candidate
is a TX Priority Queue slot, the Ni_TX_SCAN_BC.FH_OFFSET register has no meaning and is set to 0.
The second best candidate is defined by:
•
The Ni_TX_SCAN_BC.SH_PQ bit register: when set to 0, the candidate is a TX FIFO Queue
•
The Ni_TX_SCAN_BC.SH_FQN_PQSN bit register: define either the TX FIFO Queue number or the TX Priority
Queue slot number according to the Ni_TX_SCAN_BC.FH_PQ bit register
•
The Ni_TX_SCAN_BC.SH_OFFSET bit register: define the offset (in 32byte) of the TX descriptor selected,
starting from the initial start address of the TX FIFO Queue (defined in the Ni_TX_SCAN_BC.SH_FQN_PQSN
bit register) with TX descriptor address = TX FIFO Queue start address + offset * 32byte. It is important to
note that, when the TX FIFO queue selected for the first best candidate is identical to the one for the
second, the offset would be also identical. In such scenario, the second best candidate is always the next
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4256
v1.1
2025-06-26


TX descriptor of that TX FIFO Queue. When the candidate is a TX Priority Queue slot, the
Ni_TX_SCAN_BC.SH_OFFSET register has no meaning and is set to 0
22.5.3.24.4
TX Descriptor tracking in a TX FIFO Queue
The current and next TX descriptors for a given TX FIFO Queue n are stored in the L_MEM and can be identified
in the Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] and Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] bit registers.
Here are the status for those bit register when progressing with the TX FIFO Queue n:
Initial start:
1.
The current TX descriptor (first one in case this is an initial start) fetched from S_MEM and written to
L_MEM is leading to Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] = 1 and
Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] = 0.
2.
If the current TX descriptor is about to be sent go to 3), otherwise stay in 2) and no updates are done on
bit registers.
3.
The next descriptor is fetched from S_MEM and written in L_MEM.
a.
If the next TX descriptor is not valid then the TX FIFO Queue n is put on hold. The
Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] set to 1, goes to 0 once the TX message is sent
(Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] =0).
b.
If the descriptor is valid, Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] = 1 and
Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] =1, go to 4)
4.
When the current TX message is fully sent, Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] = 0 and
Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] =1.
5.
If the current TX descriptor is about to be sent go to 6), otherwise stay in 5) and no updates are done on
bit registers.
6.
The next descriptor is fetched from S_MEM and written in L_MEM.
a.
If the next TX descriptor is not valid then the TX FIFO Queue n is put on hold. The
Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] set to 1, goes to 0 once the TX message is sent
(Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] =0).
b.
If the descriptor is valid, Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] = 1 and
Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] =1, go to 7)
7.
When the current TX message is fully sent, Ni_TX_FQ_DESC_VALID.DESC_NC_VALID[n] = 0 and
Ni_TX_FQ_DESC_VALID.DESC_CN_VALID[n] =1, go to 2)
22.5.3.24.5
TX Descriptor tracking in TX Priority Queue
As soon as a TX Priority Queue slot n is started, the corresponding TX descriptor is fetched from the S_MEM and
written to the L_MEM. When the TX descriptor assigned to the slot n is fully written in the L_MEM, the
Ni_TX_PQ_DESC_VALID.DESC_VALID[n] is set to 1.
If the TX descriptor fetched is not valid or has any safety issue, the Ni_TX_PQ_DESC_VALID.DESC_VALID[n] is not
set. In case the TX message of the slot n is discarded, the Ni_TX_PQ_DESC_VALID.DESC_VALID[n] is set back to
0.
22.5.3.25
RX and TX Statistics
22.5.3.25.1
RX statistic counters
Two 12bit counters are provided to keep track of how many messages have been received successfully/
unsuccessfully, see Ni_RX_STATISTICS register. When a counter has reached the maximum value, it will wrap to
zero with the next increment. The counters can be cleared (set to 0) by writing 0 to the dedicated register bit
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4257
v1.1
2025-06-26


field. To identify when counters are wrapping, the STATS_IRQ interrupt line is triggered to the system. To
identify the counter which has wrapped, a read to the Ni_STATS_INT_STS register is required. Writing a 1 to the
corresponding bit will clear the bit.
Here are the list of root cause to increment Ni_RX_STATISTICS.SUCC[11:0] counter:
•
When an RX message is stored in S_MEM and its RX Header descriptor is acknowledged
Here are the list of root cause to increment Ni_RX_STATISTICS.UNSUCC[11:0] counter.
Safety or Errors:
•
When an RX data parity error is detected
•
When an RX address pointer parity error is detected
•
When an RX descriptor error (request, CRC or invalid) is detected and used for the current RX message
Functional:
•
When an ABORT code word is received from the PRT
•
When a DO code word is received from the PRT
•
When the RX message cannot be written to the RX FIFO Queue (queue not enable and/or started)
•
When the RX filtering has not finished in time before a new one
•
When a data overflow occurs on the RX DMA FIFO
•
When a new RX message is received while one is already in progress (filtered and RX descriptor already
fetched from system memory)
•
When the PRT ENABLE signal is going from High to Low when receiving an RX frame
22.5.3.25.2
TX statistic counters
Two 12bit counters are provided to keep track of how many messages have been transmitted successfully/
unsuccessfully, see Ni_TX_STATISTICS register. When a counter has reached the maximum value, it will wrap to
zero with the next increment. The counters can be cleared (set to 0) by writing 0 to the dedicated register bit
field. To identify when counters are wrapping, the STATS_IRQ interrupt line is triggered to the system. To
identify the counter which has wrapped, a read to the Ni_STATS_INT_STS register is required. Writing a 1 to the
corresponding bit will clear the bit.
Here are the list of root cause to increment Ni_TX_STATISTICS.SUCC[11:0] counter:
•
When a TX message is fully sent to the PRT, and its TX Header descriptor is acknowledged
Here are the list of root cause to increment Ni_TX_STATISTICS.UNSUCC[11:0] counter.
Safety or Errors:
•
Not applicable
Functional:
•
When a HFI code word is received from the PRT
•
When the maximum number of transmission allowed for a given TX message is reached
•
When the TX filtering has rejected a TX message
22.5.3.26
Register access
The MH registers are accessible in read/write mode through its AXI4-Lite slave interface HOST_AXI (compliant to
AMBA 4 ARM Ltd protocol, see [3]).
Any access to registers, either read or write, must use a 32bit aligned address, otherwise a SLVERR is provided
as a response.
When an access is performed to a non-mapped register in the address range, a SLVERR is provided as a
response.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4258
v1.1
2025-06-26


When a read access to write-only registers or a write access to read-only registers is performed, a SLVERR is
provided as a response.
When an access is performed to a write-only Privileged register in the address range, a SLVERR is provided as a
response.
The phrase ‘SLVERR is provided as a response’ means that the HOST_AXI responds with RRESP = ‘SLVERR’
respective BRESP = ‘SLVERR’.
The error is only reported on the AXI4-Lite protocol, no interrupt is triggered for such issue. The register
interface does not provide any access to the L_MEM. It would in charge of the integrator to provide a direct
access to the L_MEM to write the relevant data for the MH.
22.5.3.27
Register protection
22.5.3.27.1
Lock mechanism protection
To secure the access to some of the critical registers, an unlock key sequence is required prior to any write-
modified access. This procedure must be done before any write to the locked registers. As soon as the write is
completed, the register is automatically set back to lock mode.
When an access is performed to a locked register, a SLVERR is provided as a response. The error is only reported
on the AXI4-Lite protocol, no interrupt is triggered for such issue.
Two locks are provided for two different purposes:
•
A lock is protecting the register in charge of stopping RX and TX FIFO Queues as well as TX Priority Queue
slots
•
A lock is protecting the MH to be set in debug mode
Functional lock
This sequence is based on three step as defined below:
1.
Write 0x1234 to the Ni_LOCK.ULK[15:0] bit-field register
2.
Write 0x4321 to the Ni_LOCK.ULK[15:0] bit-field register
3.
Write to the unlocked register the expected value
Once the write is performed to the register, it will be automatically back to lock.
The following list of registers are using this protection:
•
Ni_TX_FQ_CTRL1
•
Ni_TX_PQ_CTRL1
•
Ni_RX_FQ_CTRL1
Test mode lock
An unlock key sequence is required to access in write mode the registers assigned to debug and test purpose.
This procedure must be done before any write to the locked registers.
This sequence is based on three step as defined below:
1.
Write 0x6789 to the Ni_LOCK.TMK[15:0] bit-field register
2.
Write 0x9876 to the Ni_LOCK.TMK[15:0] bit-field register
3.
Write to the unlocked register the expected value
Once the write is performed to the register, it will be automatically back to a lock state. The only register using
this specific key sequence is the Ni_DEBUG_TEST_CTRL register as it does control the debug mode.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4259
v1.1
2025-06-26


22.5.3.27.2
Conditional access protection
Some registers can be written if a bit defined in another register allows the access. As long as this conditional
bit is having the right value, any single or consecutive writes can be performed. Configuration registers are
protected by such mechanism to avoid any changes while the logic is running.
When an access is performed to a write protected register, a SLVERR is provided as a response. The error is only
reported on the AXI4-Lite protocol, no interrupt is triggered for such issue.
The registers with conditional accesses are defined in the following table.
Table 1055
Conditional access register list
Register Name
Condition to write access
Description/Constraints
Ni_MH_CFG
Ni_MH_STS.BUSY = 0
The register can be written if the
MH is not running
Ni_MH_SFTY_CFG
Ni_MH_SFTY_CTRL
Ni_RX_FILTER_MEM_ADD
Ni_TX_DESC_MEM_ADD
Ni_AXI_ADD_EXT
Ni_AXI_PARAMS
Ni_TX_FILTER_CTRL0
Ni_TX_FILTER_CTRL1
Ni_TX_FILTER_REFVAL0
Ni_TX_FILTER_REFVAL1
Ni_TX_FILTER_REFVAL2
Ni_TX_FILTER_REFVAL3
Ni_RX_FILTER_CTRL
Ni_TX_FQ_START_ADD{n}
Ni_TX_FQ_STS0.BUSY[n] = 0
The register can be written if the TX
FIFO Queue n is not running (where
n is 0-7)
Ni_TX_FQ_SIZE0{n}
Ni_TX_PQ_START_ADD
Ni_TX_PQ_STS0 = 00000000H
The register can be written if no TX
Priority Queue slots are running
Ni_RX_FQ_START_ADD{n}
Ni_RX_FQ_STS0.BUSY[n] = 00H
The register can be written if the RX
FIFO Queue n is not running (where
n is 0-7)
Ni_RX_FQ_SIZE{n}
Ni_RX_FQ_DC_START_ADD{n}
Ni_INT_TEST0
Ni_DEBUG_TEST_CTRL.TEST_IRQ_
EN = 1
The interrupt lines can be trigger by
SW if the interrupt test mode is
enable
Ni_INT_TEST1
22.5.3.27.3
Register CRC computation
To protect the MH configuration, control and configuration registers are protected using CRC. A reference CRC,
computed by the SW, is set to a register, and compare with an internal CRC value computed by the MH. It is
important to note that some of the registers won't be accessible once the MH is started, Ni_MH_STS.BUSY set to
1, refer to Conditional Access Protection and Lock Mechanism Protection sections for more details.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4260
v1.1
2025-06-26


Once the overall MH setting is done and only when there are no more changes on the control and configuration
register, do the following:
•
The SW must provide the expected CRC for list of protected registers. The CRC reference value must be
computed, only for the registers defined as CRC protected, starting from the lowest address offset. The
order of the register to be considered for the CRC computation is defined below (all register values will be
checked). The CRC is computed using the 32bit value of the register defined in the list
•
Once the 32bit CRC value is computed by SW, it must be written to the Ni_CRC_REG register. The write
access to this register does not trig a CRC check
•
To check the CRC for the registers, set the Ni_CRC_CTRL.START bit to 1. The MH goes through the list of CRC
protected registers and compute the global CRC. After a few cycles, the CRC reference value in the
Ni_CRC_REG register is compared with the one already computed. If a CRC error is detected, the
REG_CRC_ERR interrupt signal is triggered. As the check is only done and control by SW, there is no enable
defined
SW can start a CRC check at regular time interval by setting the Ni_CRC_CTRL.START bit to 1. It is recommended
to perform a register CRC check, for any new configuration, to ensure a proper setting before starting the MH.
Here below is the list of registers protected by CRC, in the order they need to be considered (refer to sections in
Register Protection chapter for register accessibility):
•
Ni_VERSION
•
Ni_MH_CFG
•
Ni_MH_SFTY_CFG
•
Ni_MH_SFTY_CTRL
•
Ni_RX_FILTER_MEM_ADD
•
Ni_TX_DESC_MEM_ADD
•
Ni_AXI_ADD_EXT
•
Ni_AXI_PARAMS
•
LOOP n from 0 to 7
-
Ni_TX_FQ_START_ADD{n}
-
Ni_TX_FQ_SIZE{n}
•
END LOOP
•
Ni_TX_PQ_START_ADD
•
LOOP n from 0 to 7
-
Ni_RX_FQ_START_ADD{n}
-
Ni_RX_FQ_SIZE{n}
-
Ni_RX_FQ_DC_START_ADD{n}
•
END LOOP
•
Ni_TX_FILTER_CTRL0 (Privileged)
•
Ni_TX_FILTER_CTRL1 (Privileged)
•
LOOP n from 0 to 3
-
Ni_TX_FILTER_REFVAL{n} (Privileged)
•
END LOOP
•
Ni_RX_FILTER_CTRL (Privileged)
•
Ni_DEBUG_TEST_CTRL (Privileged)
•
Ni_INT_TEST0
•
Ni_INT_TEST1
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4261
v1.1
2025-06-26


Here below is the normal polynomial representation and implementation of the CRC-32 used to protect the
registers:
CRC −32 =
x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x + 1
Here below is the pseudo code to compute the CRC for the MH register bank:
The reg_table[] is the array of 32bit registers defined previously (in the order they are 
listed):
static logic[31:0] rem32 = 32'hffffffff;
static logic[31:0] rem32_old = 32'hffffffff;
static logic[31:0] poly = 32'h4c11db7;
static logic[31:0] crc32;
// initialize CRC shift register
// This algorithm is indirect
rem32 = 32'hffffffff;
foreach (reg_table[i]) begin
for (int j = 31; j >= 0; j--) begin
// to decide whether reduction with polynomial will be required based on MSB before shift
rem32_old = rem32;
// shift out MSB of CRC
rem32 = rem32 << 1;
rem32[0] = reg_table[i].get()[j];
// perform reduction if required
if (rem32_old[31]) rem32 = rem32 ^ poly;
end
end
// processing 32 0s more
repeat(32) begin
// to decide whether reduction with polynomial will be required based on MSB before shift
rem32_old = rem32;
// shift out MSB of CRC
rem32 = rem32 << 1;
rem32[0] = 0;
// perform reduction if required
if (rem32_old[31]) rem32 = rem32 ^ poly;
end
crc32 = rem32;
22.5.3.28
Error and exception handling
Here is the list of potential issues the MH may have to handle and how it should react:
Table 1056
Potential issues of the MH
Error
Source
Interrupt
MH behavior
MH
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4262
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
RX acknowledge path
overflow
Acknowledge data not
sent in time before new
one needs to be stored
DP_DO_ERR
The current RX message is discarded
and an RX_ABORT_IRQ is triggered
to the system. The interrupt
DP_DO_ERR is triggered to the
system and the
Ni_ERR_INT_STS.DP_RX_ACK_DO_E
RR bit status register is set to 1. The
MH finishes its current transactions
and stops with Ni_MH_CTRL.BUSY =
0. The SW needs to restart it and the
MH will keep going with its current
task.
TX acknowledge path
overflow
Acknowledge data not
sent in time before the
new one being stored
DP_DO_ERR
As soon as an acknowledge data
locally stored and ready to be send
cannot be done (due to some
overflow) no new messages will be
sent to the PRT. The DP_DO_ERR
interrupt is triggered to the system
and the
Ni_ERR_INT_STS.DP_TX_ACK_DO_E
RR bit status register is set to 1. The
MH finishes its current transaction
and stops with Ni_MH_CTRL.BUSY =
0. The SW needs to restart it and the
MH will keep going with its current
task.
RX DMA FIFO overflow
The FIFO overflow on the
RX path
DP_DO_ERR
The current RX message is discarded
and an RX_ABORT_IRQ is sent to the
system. The already RX descriptors
used are allocated for the next
message. No status is sent back to
the Header Descriptor. The MH
keeps receiving RX message despite
this temporary issue. The
Ni_ERR_INT_STS.DP_RX_FIFO_DO_E
RR bit status register is set to 1.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4263
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
RX DMA FIFO above
threshold while RX filtering
in progress
The RX filter has not
completed in time to
avoid a potential overflow
NONE
The current RX message is sent to
the default RX FIFO Queue as backup
solution if enable, see the
Ni_RX_FILTER_CTRL register.
The threshold is defined to provide
enough time for the MH to write the
message in S_MEM. The RX Header
descriptor of that RX message will
have its status report bit field set to
“message received but not filtered”.
The MH keeps receiving RX message.
RX descriptor CRC error
when fetched from S_MEM
A CRC error is detected on
RX descriptor
DESC_ERR
As the RX descriptor has a CRC error,
the related RX FIFO Queue is
stopped and the interrupt
DESC_ERR is triggered to the
system, see Ni_RX_FQ_STS1,
Ni_RX_FQ_STS0 registers. The
Ni_SFTY_INT_STS.RX_DESC_CRC_ER
R bit status register is set to 1. Other
RX FIFO Queues would still be
running.
Wrong RX descriptor
fetched from S_MEM
The expected descriptor is
not the one coming back
from S_MEM. Several
issue on the address
could lead to such result
DESC_ERR
As the RX descriptor is not the one
expected, the related RX FIFO Queue
is stopped and the interrupt
DESC_ERR is triggered to the
system, see Ni_RX_FQ_STS1,
Ni_RX_FQ_STS0 registers. The
Ni_SFTY_INT_STS.RX_DESC_REQ_E
RR bit status register is set to 1.
Other RX FIFO Queues would still be
running.
TX descriptor CRC error
when fetched from S_MEM
A CRC error is detected on
TX descriptor when
fetched from S_MEM
DESC_ERR
As the TX descriptor has a CRC error,
the related TX FIFO Queue is
stopped and the interrupt
DESC_ERR is triggered to the
system. The
Ni_SFTY_INT_STS.TX_DESC_CRC_ER
R bit status register is set to 1. Other
TX FIFO Queues would still be
running. TX priority Queue are
managed differently. If an issue
occurs on the TX descriptor the slot
will have its busy and sent flags set
to 0, see Ni_TX_PQ_STS0 and
Ni_TX_PQ_STS1 registers.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4264
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
Wrong TX descriptor
fetched from S_MEM
The expected descriptor is
not the one coming back
from S_MEM. Several
issue on the address
could lead to such result
DESC_ERR
As the TX descriptor is not the one
expected, the related TX FIFO Queue
is stopped and the interrupt
DESC_ERR is triggered to the
system. The
Ni_SFTY_INT_STS.TX_DESC_REQ_ER
R bit status register is set to 1. Other
TX FIFO Queues would still be
running. TX priority Queue are
managed differently. If an issue
occurs on the TX descriptor the slot
will have its busy and sent flags set
to 0, see Ni_TX_PQ_STS0 and
Ni_TX_PQ_STS1 registers.
Wrong TX descriptor
fetched from L_MEM
The expected descriptor is
not the one coming back
from L_MEM. Several
issue on the address
could lead to such result
DESC_ERR
The TX descriptor selected to be the
next message candidate is
corrupted. Either the related TX FIFO
Queue is stopped (see
Ni_TX_FQ_STS0 and
Ni_SFTY_INT_STS registers) or the
TX Priority Queue slot is set disable
(busy flag set to 0), see
Ni_TX_PQ_STS0 and
Ni_SFTY_INT_STS registers). The
interrupt DESC_ERR is triggered to
the system. The
Ni_SFTY_INT_STS.TX_DESC_REQ_ER
R bit status register is set to 1. Other
TX FIFO Queues would still be
running as well as TX Priority Queue
slots.
Parity error detected on TX
address pointers
One of the address
pointers managing the TX
FIFO Queues or the TX
Priority Queue is
corrupted
AP_PARITY_ERR As the source of parity issue, could
lead to wrong memory accesses, the
MH stops. The MH finishes all
pending data transfers and then
stops with Ni_MH_STS.BUSY = 0. The
SW is notified through the
AP_PARITY_ERR interrupt and the
Ni_SFTY_INT_STS.AP_TX_PARITY_ER
R status bit register is set to 1.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4265
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
Parity error detected on RX
address pointers
One of the address
pointers managing the RX
FIFO Queues is corrupted
AP_PARITY_ERR As the source of parity issue, could
lead to wrong memory accesses, the
MH stops. The MH finishes all
pending data transfers and then
stops with Ni_MH_STS.BUSY = 0. The
SW is notified through the
AP_PARITY_ERR interrupt and the
Ni_SFTY_INT_STS.AP_RX_PARITY_E
RR status bit register is set to 1.
Register CRC error
One of the configuration
register protected by CRC
is corrupted
REG_CRC_ERR
There is no way to define which
register is corrupted and to evaluate
which part of the logic would be
impacted. The MH is stopped. When
receiving an RX message, the current
message is discarded and all RX FIFO
Queues are stopped. When
transmitting a message, it is
aborted. All TX FIFO Queues are
stopped and all TX Priority Queue
slot are disabled. The interrupt
REG_CRC_ERR is sent to system
TX data path sequence
error
Any error sequence
detected on the TX_MSG
interface
DP_SEQ_ERR
If any code word reported by the
PRT does not match the expected
sequence the PRT and MH are no
more synchronized. The MH finishes
all pending data transfers and then
stops with Ni_MH_STS.BUSY = 0. the
DP_SEQ_ERR interrupt is triggered
with the
Ni_ERR_INT_STS.DP_TX_SEQ_ERR
bit status register set to 1.
RX data path sequence
error
Any error sequence
detected on the RX_MSG
interface
DP_SEQ_ERR
If any code word reported by the
PRT does not match the expected
sequence the PRT and MH are no
more synchronized. The MH finishes
all pending data transfers and then
stops with Ni_MH_STS.BUSY = 0. the
DP_SEQ_ERR interrupt is triggered
with the
Ni_ERR_INT_STS.DP_RX_SEQ_ERR
bit status register set to 1.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4266
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
RX frame reception in
progress when receiving a
new RX message
Due to a high number of
filter elements and a high
latency on the memory,
the RX filtering process
may cover almost the
shortest CAN frame,
leading to an overlap on
the current and new RX
messages
RX_ABORT_IRQ
As the current RX message has not
complete prior receiving the next
frame, the new frame is discarded to
provide the remaining time to
complete the process on the current
one. Therefore, any new RX message
is aborted with an RX_ABORT_IRQ
interrupt.
RX filter not done in time
before a new RX frame
The RX filter does not
complete in time its
process to identify the RX
FIFO Queue
RX_FILTER_ERR
When the RX filter is taking too much
time and a new RX message is
coming, the RX_FILTER_ERR
interrupt is triggered. The new RX
message is discarded, see
Ni_RX_FILTER_CTRL register. The MH
keeps running on its current frame.
Such interrupt is a good indicator for
SW to identify large RX filtering time
on some frames.
RX FIFO Queue not enable
for reception
The RX FIFO Queue
selected to receive the RX
message is not running,
either not set or wrongly
set
RX_ABORT_IRQ
The selected RX FIFO Queue defined
after the RX filtering process is
disable. The MH discards the RX
message with the RX_ABORT_IRQ
interrupt. Every RX message going to
this disabled RX FIFO Queue will
trigger this interrupt. The SW must
ensure RX FIFO Queues are enable at
first time.
The RX Filter cannot send
message to the RX FIFO
Queue as it is disable
RX_FILTER_ERR
In case the RX Filter identifies an RX
FIFO Queue to receive an RX
message but this queue is disable,
the RX_FILTER_ERR interrupt is
triggered and the message is
rejected
TX message rejected by TX
filter
The Header Descriptor is
filtered to ensure only
well-defined TX message
can go through
TX_FILTER_IRQ
When a TX message is rejected it will
be skipped by the MH. When the
Header descriptor is in a TX FIFO
Queue, the next message in the FIFO
is used instead. An acknowledge is
sent to the TX descriptor with the
status rejected. Regarding TX
Priority Queue, the corresponding
slot is disabled. The MH keeps
running all other TX FIFO Queues or
slots defined as valid
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4267
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
DMA channel interface
mixed up
Wrong data sent or
received to DMA channel
interface detected by the
DMA
DMA_CH_ERR
As such issue would mean data are
mixed up, there is no way to recover.
The MH finishes all pending data
transfers and then stops with
Ni_MH_STS.BUSY = 0. The system is
notified through the DMA_CH_ERR
interrupt line. There is no status flag
assigned to such interrupt as the
DMA channel being faulty cannot be
identified
Parity error on RX message
data
A bit flip is detected on
data from the RX_MSG to
the AXI system bus
interface
DP_PARITY_ER
R
If such issue occurs while receiving
data, the RX message would be
discarded. No acknowledge data is
sent. An interrupt DP_PARITY_ERR is
triggered. The
Ni_SFTY_INT_STS.DP_RX_PARITY_E
RR bit status register is set to 1. As
the RX message would be aborted,
the RX_ABORT_IRQ interrupt would
also be set. The MH keeps going with
new messages.
Parity error on TX message
data
A bit flip is detected on
data from the AXI system
bus interface to the
TX_MSG
DP_PARITY_ER
R
If such issue occurs while
transmitting data, the TX message
would be aborted. An interrupt
DP_PARITY_ERR would be triggered.
The
Ni_SFTY_INT_STS.DP_TX_PARITY_E
RR bit status register is set to 1. The
TX_ABORT_IRQ interrupt is set.
Parity error on RX message
acknowledge data
A bit flip is detected on
data from the RX_MSG to
the AXI system bus
interface
DP_PARITY_ER
R
If such issue occurs on the
acknowledge data, the RX message
would be discarded. No
acknowledge data is sent. An
interrupt DP_PARITY_ERR is
triggered. The
Ni_SFTY_INT_STS.ACK_RX_PARITY_
ERR bit status register is set to 1. The
MH keeps going with new messages.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4268
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
Parity error on TX message
acknowledge data
A bit flip is detected on
payload data from the AXI
system bus interface to
the TX_MSG
DP_PARITY_ER
R
If such issue occurs while
acknowledging the TX message. An
interrupt DP_PARITY_ERR is
triggered. The
Ni_SFTY_INT_STS.ACK_TX_PARITY_E
RR bit status register is set to 1. The
SW can identify such issue reading
the report status of that TX
descriptor.
RX message received while
MH not started
Ni_MH_CTRL.START bit
wrongly set to 1
NONE
The MH does not accept RX message
data from the PRT. As the PRT
cannot sent data to the MH, a data
overflow on the PRT will occur
leading to an interrupt.
PRT
RX data path overflow
DO code word received
from PRT. . Several issues
could lead to such issue
for example, peak latency
preventing write accesses
in time or RX path being
stopped and so on.
NA
The RX message is discarded. The
already used RX descriptor are
reused for the next message. Then,
no status is sent back to the Header
Descriptor in S_MEM.
RX message on CAN bus
not successful
ABORT code word
received from PRT. Invalid
CAN message detected on
CAN bus
NA
This is normal behavior. The RX
message is discarded. The already
used RX descriptors are allocated for
the next message. No acknowledge
data is sent back to the S_MEM
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4269
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
TX data path underrun
DU code word received
from PRT. TX message
data not provided in time
NA
The current TX message, selected
and started on the MH side, is
aborted but the PRT keeps going
with its current frame and will
generated a wrong CRC to invalidate
the frame at the receiver side. All
data transfers from S_MEM is
aborted. The issue may be the result
of a peak latency. The TX message is
still valid and will be part of the next
TXScan. The MH can restart to
transmit the same message
according to the restart counter
setting. The PRT is triggered an
interrupt to the system when such
code word is transmitted to the MH.
It is essential to understand that the
MH will still be active and fully
functional. There is no message loss
when such issue occurs
TX message on CAN bus
not successful
RESTART code word
received from PRT
NA
The current TX message, selected
and started on the MH side, is
aborted. All data transfers from
S_MEM is aborted. The current TX
message is still valid and will be part
of the next TX-Scan. The MH can
restart to transmit the same
message according to the restart
counter setting or use another one
with highest priority.
TX message header invalid
HFI code word received
from PRT
NA
The current TX message is
discarded, and a data acknowledge
is sent back to the Header Descriptor
in S_MEM. The report status of the
TX descriptor is updated with the
issue. If the TX message was in a TX
FIFO Queue, the MH keeps running
and skips this TX message to fetch
the next one. In case of a TX Priority
Queue slot, the slot is set as done
but not sent (see report status in TX
descriptor)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4270
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
Unexpected Start Of
Sequence (USOS) at the
TX_MSG interface
When PRT detects USOS,
it stops CAN protocol
operation and sets
ENABLE=0
STOP_IRQ
In case such code word is received,
the MH or the PRT are no more
synchronized. The MH finishes its
current transfers and stops. The
STOP_IRQ interrupt is set to notify
MH is no more active. In such
scenario the only action would be to
reset the MH and PRT to recover
PRT entered CAN
protocol’s Bus-Off state
PRT stops CAN protocol
operation and sets
ENABLE=0
STOP_IRQ
MH finishes all pending data
transfers and then stops (put on
hold). All FSM in the MH go to idle.
The STOP_IRQ interrupt is set to
notify MH is no more active. A write
to the Ni_MH_CTRL.START bit
register allows the SW to restart
everything at the point it was
stopped, if required.
PRT stopped by SW
PRT stops CAN protocol
operation and sets
ENABLE=0
STOP_IRQ
PRT TX_MSG interface not
responding
PRT is having a deadlock
and cannot answer to MH
request or receive data
DP_TO_ERR
When the timeout assigned to the
TX_MSG interface fires, the MH
finishes all pending data transfers
and then stops with
Ni_MH_STS.BUSY = 0. The
DP_TO_ERR interrupt is triggered to
the system.with the
Ni_ERR_INT_STS.DP_TX_TO_ERR bit
status set to 1
PRT RX_MSG interface not
responding
PRT is having a deadlock
and cannot send data to
MH
DP_TO_ERR
When the timeout assigned to the
RX_MSG interface fires, the MH
finishes all pending data transfers
and then stops with
Ni_MH_STS.BUSY = 0. The
DP_TO_ERR interrupt is triggered to
the system with the
Ni_ERR_INT_STS.DP_RX_TO_ERR bit
status set to 1
LOCAL MEMORY (L_MEM)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4271
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
Local memory safety error
while reading RX filter
element. Corrupted data
has been corrected
The L_MEM is providing a
safety error on
MEM_SFTY_CE input
signal while reading a
data
MEM_SFTY_ERR As the corrupted data word is
corrected, the RX filtering can be
done on the current RX message.
The MH keeps running and will be
able to receive new messages. The
interrupt MEM_SFTY_ERR is
triggered to the system with the
Ni_SFTY_INT_STS.MEM_SFTY_CE bit
status register set to 1. It is essential
for such issue that there is no error
response on the memory interface
while reading the corrected data.
Local memory safety error
while reading TX
descriptor. Corrupted data
has been corrected
The L_MEM is providing a
safety error on
MEM_SFTY_CE input
signal while reading a
data
MEM_SFTY_ERR As the TX descriptor selected to be
the next message candidate is
corrupted but corrected, the related
TX FIFO Queue or the TX Priority
Queue slot will run as normal. When
the TX-Scan is reading a corrected TX
descriptor, the all process will
complete. The interrupt
MEM_SFTY_ERR is triggered to the
system with the
Ni_SFTY_INT_STS.MEM_SFTY_CE bit
status register set to 1. It is essential
for such issue that there is no error
response on the memory interface
while reading the corrected data.
Local memory safety error
while reading RX filter
element. Corrupted data is
not corrected
The L_MEM is providing a
safety error on
MEM_SFTY_UE input
signal while reading a
data with SLVERR
response
MEM_SFTY_ERR As no more filtering can be done on
the current RX message, it is
discarded. As it is not possible to
keep going with a corrupted RX filter
element, the MH stops The interrupt
MEM_SFTY_ERR is triggered to the
system with the
Ni_SFTY_INT_STS.MEM_SFTY_UE bit
status register set to 1. The MH
finishes all pending data transfers
and then stops with
Ni_MH_STS.BUSY = 0. It is essential
for such issue, to have the memory
interface reporting a SLVERR when
reading the corrupted data.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4272
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
Local memory safety error
while reading TX
descriptor. Corrupted data
is not corrected
The L_MEM is providing a
safety error on
MEM_SFTY_UE input
signal while reading a
data with a SLVERR
response
MEM_SFTY_ERR As it is not possible to keep going
with a corrupted TX descriptor, the
MH stops The interrupt
MEM_SFTY_ERR is triggered to the
system if such issue occurs with the
Ni_SFTY_INT_STS.MEM_SFTY_UE bit
status register set to 1. The MH
finishes all pending data transfers
and then stops with
Ni_MH_STS.BUSY = 0. It is essential
for such issue, to have the memory
interface reporting a SLVERR when
reading the corrupted data.
Error response received on
local memory write access.
A safety issue is not
considered here
The L_MEM is providing a
DECERR/SLVERR error
response on BRESP[1:0]
for a write access
RESP_ERR[0]
The TX descriptor written to the
L_MEM is not valid. In such cases as
the L_MEM cannot be trusted
anymore, the MH stops. The MH
finishes all pending data transfers
and then stops with the
Ni_MH_STS.BUSY = 0. The
RESP_ERR[0] interrupt is triggered
to the system. To identify the issue
the BRESP[1:0] and the ID of the
transaction are logged in the
Ni_AXI_ERR_INFO.MEM_ID[1:0] and
Ni_AXI_ERR_INFO.MEM_RESP[1:0]
bit status register.
Error response received on
local memory read access.
A safety issue is not
considered here
The L_MEM is providing a
DECERR/SLVERR error
response on RRESP[1:0]
for a read access
RESP_ERR[1]
The TX descriptor or RX Filter
element read from the L_MEM is not
valid. In such cases as the L_MEM
cannot be trusted anymore, the MH
stops. The MH finishes all pending
data transfers and stops with the
Ni_MH_STS.BUSY = 0. The
RESP_ERR[0] interrupt is triggered
to the system. To identify the issue
the RRESP[1:0] and the ID of the
transaction are logged in the
Ni_AXI_ERR_INFO.MEM_ID[1:0] and
Ni_AXI_ERR_INFO.MEM_RESP[1:0]
bit status register.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4273
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
A read from the L_MEM
cannot complete
The MH does not
complete a read within a
defined time frame
MEM_TO_ERR
When the timeout assigned to the
L_MEM AXI read channel fires, the
MH finishes all pending data
transfers and then stops with
Ni_MH_STS.BUSY = 0. The
MEM_TO_ERR interrupt is triggered
to the system and the
Ni_SFTY_INT_STS.MEM_AXI_RD_TO_
ERR bit status is set to 1
A write to the L_MEM
cannot complete
The MH does not
complete a write within a
defined time frame
MEM_TO_ERR
When the timeout assigned to the
L_MEM AXI write channel fires, the
MH finishes all pending data
transfers and then stops with
Ni_MH_STS.BUSY = 0. The
MEM_TO_ERR interrupt is triggered
to the system and the
Ni_SFTY_INT_STS.MEM_AXI_WR_TO
_ERR bit status is set to 1
System
Address decoding error on
DMA write channels
Error response from AXI
system bus interface,
DECERR received on
BRESP[1:0] for write
access
RESP_ERR[0]
When the error is detected on the RX
message data or acknowledge data
being written, the interrupt
RESP_ERR[0] interrupt is sent to the
system. As the S_MEM is not reliable,
the MH stops. The MH finishes all
pending data transfers and stops
with the Ni_MH_STS.BUSY = 0. To
identify the issue the BRESP[1:0]
and the ID of the transaction are
logged in the
Ni_AXI_ERR_INFO.DMA_ID[1:0] and
Ni_AXI_ERR_INFO.DMA_RESP[1:0]
bit status register.
Address decoding error on
DMA read channels
Error response from AXI
system bus interface,
DECERR received on
RRESP[1:] for read access
RESP_ERR[1]
When the error is detected on the TX
message data, RX or TX descriptors,
the interrupt RESP_ERR[1] is sent to
the system. As the S_MEM is not
reliable, the MH stops. The MH
finishes all pending data transfers
and stops with the Ni_MH_STS.BUSY
= 0. To identify the issue the
RRESP[1:0] and the ID of the
transaction are logged in the
Ni_AXI_ERR_INFO.DMA_ID[1:0] and
Ni_AXI_ERR_INFO.DMA_RESP[1:0]
bit status register.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4274
v1.1
2025-06-26


Table 1056
(continued) Potential issues of the MH
Error
Source
Interrupt
MH behavior
System memory CRC error
or Access to wrong slave
on DMA write channel
Error response from AXI
system bus interface,
SLVERR received on
BRESP[1:0] for write
access
RESP_ERR[0]
There is no way to identify the exact
error source, either a CRC error or a
wrong slave access. See “Address
decoding error on DMA write
channels” description in this table
System memory CRC error
or Access to wrong slave
on DMA read channel
Error response from AXI
system bus interface,
SLVERR received on
RRESP[1:0] for read
access
RESP_ERR[1]
There is no way to identify the exact
source, either a CRC error or a wrong
slave access. See “Address decoding
error on DMA read channels”
description in this table
A read from the S_MEM
cannot complete
The MH does not
complete a read within a
defined time frame
DMA_TO_ERR
When the timeout assigned to the
S_MEM AXI read channel fires, the
MH finishes all pending data
transfers and then stops with
Ni_MH_STS.BUSY = 0. The
DMA_TO_ERR interrupt is triggered
to the system with the
Ni_SFTY_INT_STS.DMA_AXI_RD_TO_
ERR bit status set to 1
A write to the S_MEM
cannot complete
The MH does not
complete a write within a
defined time frame
DMA_TO_ERR
When the timeout assigned to the
S_MEM AXI write channel fires, the
MH finishes all pending data
transfers and then stops with
Ni_MH_STS.BUSY = 0. The
DMA_TO_ERR interrupt is triggered
to the system with the
Ni_SFTY_INT_STS.DMA_AXI_WR_TO
_ERR bit status set to 1
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4275
v1.1
2025-06-26


22.5.3.29
Interrupts
Table 1057
Interrupts
Interrupt
Description
TX_FQ_IRQ[7:0]
When considering TX FIFO Queues there is a mean, thanks to the IRQ bit-field in TX
descriptor, to trigger an interrupt to the system when a TX message is sent
successfully or skipped. This interrupt can only be declared in a TX Header
Descriptor (HD=1). When a TX descriptor has HD=0 and IRQ=1, no interrupt is
generated
A dedicated interrupt signal TX_FQ_IRQ[N] is provided per TX FIFO queue n (0 <= n
<= 7). When a TX Header Descriptor is mentioning an interrupt (IRQ bit set to 1) and
the message is successfully sent or skipped, the DESC_MESSAGE_HANDLER
identifies the TX FIFO queue source number of that descriptor and triggers the
relative line of the interrupt bus signal. When one or several TX descriptors are used
for one TX message, the SW needs to define the interrupt (IRQ bit-field set to 1) only
to the Header Descriptor. The interrupt will be effective only when the
acknowledge data of that descriptor is fully written in S_MEM.
It is then possible to define for a TX FIFO Queue n, having a fix number of messages
to be sent, the interrupt TX_FQ_IRQ[N] only to the last Header Descriptor. Doing so,
this approach will limit the number of interrupts to the system.
The main purpose of the TX FIFO Queue is to append on the fly new messages. A
race condition may occur between the SW and the Message Handler regarding the
definition of valid TX message in that queue. In case a TX FIFO Queue n does not
provide a valid TX descriptor, the MH notifies the SW with the TX_FQ_IRQ[n] that
the TX FIFO Queue n is on hold, despite being active.
The Ni_TX_FQ_INT_STS register provides the relevant information to detect the
root cause.
As a summary two different source of events can trig those interrupts:
•
This interrupt is triggered when the IRQ bit field in TX Header Descriptor is set
to 1 and the TX message is sent successfully. The Ni_TX_FQ_INT_STS.SENT[n]
bit register is set to 1 for the TX FIFO Queue n and the bit field STS[3:0] in the TX
descriptor is set to 0’b0001
•
This interrupt trigs when the TX message is skipped. The
Ni_TX_FQ_INT_STS.SENT[n] bit register is set to 1 for the TX FIFO Queue n and
the bit field STS[3:0] in the TX descriptor is set to 0’b0010 or 0’b0011
•
The TX FIFO Queue n execution is stopped due to the fetch of an invalid TX
descriptor in this queue (no more TX message defined, and no END bit set to 1
for the last TX message). The Ni_TX_FQ_INT_STS.UNVALID[n] bit register is set
to 1 for the TX FIFO Queue n
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4276
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
RX_FQ_IRQ[7:0]
When considering RX FIFO Queues there is the option, thanks to the IRQ bit field in
RX descriptor, to trigger an interrupt to the system when an RX message is received
successfully. The interrupt bus signal RX_FQ_IRQ[n] provides an interrupt line for
the RX FIFO queue n (0 <= n <=7). When the DESC_MESSAGE_HANDLER fetches
an RX descriptor for a given RX message and identifies an IRQ bit set to 1 in one
of them, it stores this information. Once the RX message is received successfully
and a IRQ bit set has been detected in one RX descriptor, an interrupt is triggered.
This interrupt is triggered only when the acknowledge data (written in the Header
Descriptor) is fully written in the S_MEM.
As a summary there are two options to define this interrupt bit in RX descriptors:
•
In case the SW requires an interrupt per RX message, the IRQ bit in all RX
descriptors must be set to 1. This setting is valid for Normal and Continuous
mode with the same effect.
•
The SW can set the IRQ bit in a regular interval along an RX FIFO Queue,
avoiding interrupts at every RX message. Only the RX message covering the RX
descriptor having this IRQ bit set will trigger an interrupt. In Continuous mode,
it is then possible to set an interrupt every two, three or N messages. In Normal
mode, the interrupt could be defined every two, three or N RX descriptors
According to the RX message size, several RX descriptors will be used and so
could trig the interrupt. It is important to note that RX messages are received
with various bit rate, thus the interrupt time interval will not be identical.
A race condition may occur between the SW and the Message Handler regarding the
definition of valid RX descriptor in a queue. In case an RX FIFO Queue n does not
provide a valid RX descriptor in time, the interrupt notifies the SW with the
RX_FQ_IRQ[n] interrupt that the RX FIFO Queue n is on hold despite being active.
The Ni_RX_FQ_INT_STS register provides the related information to identify the
root cause.
As a summary two different source of events can trig those interrupts:
•
This interrupt is triggered when the IRQ bit field in an RX Descriptor is set to 1
and the RX message is received successfully. The
Ni_RX_FQ_INT_STS.RECEIVED[n] bit register is set to 1 for the RX FIFO Queue n
and the bit field STS[3:0] in the RX descriptor is set to 0’b0001
•
The RX FIFO Queue n execution is stopped due to the fetch of an invalid RX
descriptor in this queue. The Ni_RX_FQ_INT_STS.UNVALID[n] bit register is set
to 1 for the TX FIFO Queue n
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4277
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
TX_PQ_IRQ
A single TX_PQ_IRQ interrupt is assigned to all TX Priority Queue slots. Any TX
Priority Queue slot can trigger an interrupt (IRQ = 1) when the relative TX message
is successfully sent or skipped. Any TX Header Descriptor having the IRQ bit set and
used by the TX Priority Queue trigs this interrupt line. As for the TX FIFO Queue,
when a TX message is defined in a TX Priority Queue slot, all the TX descriptors
used to define this message must be valid.
When the message is sent, the slot is set to inactive and nothing else can occur.
Whereas the TX FIFO Queue, which is processing up to the point a TX descriptor is
invalid, the TX Priority Queue slot must not fetch any invalid descriptor. To protect
the execution of TX message and to have a common TX Queue management, the TX
priority Queue can also report invalid descriptor.
The SW need to look at the interrupt status register Ni_TX_PQ_INT_STS0 and
Ni_TX_PQ_INT_STS1 to identify which slot has generated the interrupt and for
which reason.
As a summary three different source of events can trig this interrupt:
•
This interrupt is triggered when the IRQ bit field in TX Header Descriptor is set
to 1 and the TX message is sent successfully. The Ni_TX_PQ_INT_STS0.SENT[n]
bit register is set to 1 for the TX Priority Queue slot n and the bit field STS[3:0]
in the TX descriptor is set to 0’b0001
•
This interrupt is triggered when the TX message is skipped. The
Ni_TX_PQ_INT_STS0.SENT[n] bit register is set to 1 for the TX Priority Queue
slot n and the bit field STS[3:0] in the TX descriptor is set to 0’b0010 or 0’b0011
•
The TX Priority Queue slot n execution is stopped due to the fetch of an invalid
TX descriptor in this queue (TX descriptor is not valid). The
Ni_TX_PQ_INT_STS1.UNVALID[n] bit register is set to 1 for the TX Priority
Queue slot n
STATS_IRQ
Four Statistic counters are used to monitor successful and unsuccessful RX and TX
messages. As soon as one of those counters overflows the STATS_IRQ is triggers to
the system, refer to the RX and TX Statistics chapter for more details. When looking
at the Ni_STATS_INT_STS register, the SW can identify which counter has reached
its maximum value:
•
When the number of unsuccessful RX message received has reached the
maximum counter value, the Ni_STATS_INT_STS.RX_UNSUCC is set to 1
•
When the number of successful RX message received has reached the
maximum counter value, the Ni_STATS_INT_STS.RX_SUCC is set to 1
•
When the number of unsuccessful TX message received has reached the
maximum counter value, the Ni_STATS_INT_STS.TX_UNSUCC is set to 1
•
When the number of successful TX message received has reached the
maximum counter value, the Ni_STATS_INT_STS.TX_SUCC is set to 1
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4278
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
STOP_IRQ
When the PRT is stop (ENABLE signal goes from high to low), the MH finishes its
current tasks. It puts all active RX/TX FIFO Queues on hold and discard all active TX
Priority Queue slots. Once done, the MH notifies such state by triggering the
STOP_IRQ interrupt.
The interrupt STOP_IRQ is raised under the following conditions:
•
Ni_TX_FQ_STS0 = 0x0000 and Ni_RX_FQ_STS0 = 0x0000 and Ni_TX_PQ_STS0 =
0x00000000
•
Ni_TX_FQ_STS0 = 0xXYXY and Ni_RX_FQ_STS0 = 0xWVWV and Ni_TX_PQ_STS0
= 0x00000000, where XY defined the active and on hold TX FIFO Queues and WV
the active and on hold RX FIFO Queues
RX_FILTER_IRQ
In order to track RX filtering results, an interrupt can be defined when a match
is detected on any defined RX filter element. The RX_FILTER_IRQ can only be
triggered if the IRQ bit in the RX filter element is set to 1 AND there is a match. When
a match is detected, the FM bit (set in RX message header) is set to 1 and the filter
element index is defined in the FIDX[7:0] bit field (set in the RX message header).
Note:
The BLK bit field in the RX Filter element is a side band information and is
not considered for the interrupt generation
TX_FILTER_IRQ
The interrupt is triggered when the TX filter is enabled, and a TX message
is rejected. Despite being rejected, the TX descriptor used to define the TX
message is acknowledged. To identify the TX descriptor allocated to the TX
message rejected, the STS[3:0] bit field in the TX descriptor is set to 0’b0100.
The Ni_TX_FILTER_ERR_INFO register provides the relevant information to identify
which TX FIFO Queue or TX Priority Queue slot is impacted.
TX_ABORT_IRQ
This interrupt line is only triggered when the MH needs to abort a TX message being
sent to the PRT. This interrupt does not have any status flags, as it will always be
linked to functional or safety errors. Thus, another interrupt will provide the require
information related to the issue.
Several source of events can lead to this interrupt:
•
TX address pointer parity error (refer to AP_PARITY_ERR interrupt)
•
Timeout on S_MEM, L_MEM or PRT interface (refer to MEM_TO_ERR,
DMA_TO_ERR or DP_TO_ERR interrupt)
•
DMA channel routing error (refer to DMA_CH_ERR interrupt)
•
A TX_MSG sequence error (refer to DP_SEQ_ERR interrupt)
•
A DMA AXI or MEM AXI error response (refer to RESP_ERR interrupt)
•
An uncorrectable error detected on the L_MEM (refer to MEM_SFTY_ERR
interrupt)
•
A TX data parity error (refer to DP_PARITY_ERR interrupt)
Aborting a TX FIFO Queue or a TX Priority Queue slot does not set this interrupt as
no TX message abort is expected to occur (the MH will complete the current TX
message before aborting the TX FIFO Queue).
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4279
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
RX_ABORT_IRQ
This interrupt line is triggered when the MH needs to abort an RX message is
received from PRT. This interrupt does not have any status flags, as it will always be
linked to functional or safety errors. Thus, another interrupt will provide the require
information related to the issue.
As a summary two different source of events can trig this interrupt:
•
An RX message is about to be sent to a disabled RX FIFO Queue.
•
An RX message is in progress and the MH receives a new RX message at the
same time. If the RX filter has already completed or if the threshold in the RX
DMA FIFO is reached, the new one is aborted to leave more time for the current
one to complete.
•
RX address pointer parity error (refer to AP_PARITY_ERR interrupt)
•
Timeout on S_MEM, L_MEM or PRT interface (refer to MEM_TO_ERR,
DMA_TO_ERR or DP_TO_ERR interrupt)
•
DMA channel routing error (refer to DMA_CH_ERR interrupt)
•
An RX_MSG sequence error (refer to DP_SEQ_ERR interrupt)
•
A DMA AXI or MEM AXI error response (refer to RESP_ERR interrupt)
•
An uncorrectable error detected on the L_MEM (refer to MEM_SFTY_ERR
interrupt)
•
An RX data parity error (refer to DP_PARITY_ERR interrupt)
•
An RX descriptor error (refer to DESC_ERR interrupt)
•
An overflow on RX DMA FIFO or on the RX descriptor acknowledge path (refer to
the DP_DO_ERR interrupt)
Aborting an RX FIFO Queue will never set this interrupt, as the MH will complete its
current reception before this action.
RX_FILTER_ERR
This interrupt line is triggered when the RX filter has not finished in time, to define
the RX FIFO Queue number, before the reception of a new RX message. It provides
information to the SW about large RX filtering time. Refer to the RX Filter chapter
for detailed description. There is no status flag related to this interrupt, as the
second source of event, defined below, is a programming issue and should never
occur. Two different sources of events can trig this interrupt:
•
RX filtering not finished before a new RX frame
•
RX FIFO Queue to receive RX frame not running
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4280
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
MEM_SFTY_ERR
Safety error detected at the L_MEM interface. In fact, this interrupt is triggered
when either the MEM_SFTY_CE or MEM_SFTY_UE input signal is active. To identify
the root cause of such interrupt, refer to the Ni_SFTY_INT_STS register Two
different sources of events can trigger this interrupt:
•
The MEM_SFTY_UE input signal, when set, to indicate an uncorrectable error
from the L_MEM when reading (this signal must be generated by the L_MEM
memory controller). The Ni_SFTY_INT_STS. MEM_SFTY_UE bit register is set to
1 in this case
•
The MEM_SFTY_CE input signal, when set, to indicate a correctable error from
the L_MEM when reading (this signal must be generated by the L_MEM
memory controller). The Ni_SFTY_INT_STS. MEM_SFTY_CE bit register is set to
1 in this case
REG_CRC_ERR
CRC error detected on the register bank. This interrupt is triggered after a few
cycles if the CRC written in the Ni_CRC_REG.VAL[31:0], prior writing 1 to the
Ni_CRC_CTRL.START bit, is not matching the one computed in hardware. Such
interrupt event does not trig any actions in the MH. Therefore, it is a SW task to do
the appropriate actions to stop the MH.
DESC_ERR
CRC error detected on RX/TX descriptor or unexpected RX/TX descriptor received.
Status flags allow SW to identify the root cause of such interrupt, see
Ni_SFTY_INT_STS register. Several source issues could lead to this interrupt:
•
When the Ni_SFTY_INT_STS.RX_DESC_CRC_ERR is set to 1, an RX descriptor is
received and is having a CRC error
•
When the Ni_SFTY_INT_STS.RX_DESC_REQ_ERR is set to 1, an RX descriptor is
received and is not compliant to the one requested (wrong RX FIFO Queue,
wrong instance number, wrong position in the queue, …)
•
When the Ni_SFTY_INT_STS.TX_DESC_CRC_ERR is set to 1, a TX descriptor is
received and is having a CRC error
•
When the Ni_SFTY_INT_STS.TX_DESC_REQ_ERR is set to 1, a TX descriptor is
received and is not compliant to the one requested (wrong TX FIFO Queue,
wrong instance number, wrong position in the queue, wrong TX Priority Queue
slot…)
The Ni_DESC_ERR_INFO0 and Ni_DESC_ERR_INFO1 registers provide a detailed
description of the faulty RX/TX descriptor. Only the first RX/TX descriptor error will
lead to an update of those registers, in case several ones occur. To capture the next
descriptor error information, the SW must clear the interrupt source.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4281
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
AP_PARITY_ERR
Address pointers used to manage TX FIFO Queues, RX FIFO Queues and TX Priority
Queue are protected using parity bit (1bit per byte). Any issue detected trigs
this interrupt. The parity bits are checked only when the address pointer is
used for S_MEM accesses. Status flags allow SW to identify the root cause, see
Ni_SFTY_INT_STS register.
Several source issues could lead to this interrupt:
•
When the Ni_SFTY_INT_STS.AP_RX_PARITY_ERR is set to 1, an address pointer
used to manage the RX path is having a parity error
•
When the Ni_SFTY_INT_STS.AP_TX_PARITY_ERR is set to 1, an address pointer
used to manage the TX path is having a parity error
DP_PARITY_ERR
Parity error detected on RX message data received from PRT to AXI system
bus or TX payload data transmitted from AXI system bus to PRT. Any issue
detected trigs this interrupt. Status flags allow SW to identify the root cause, see
Ni_SFTY_INT_STS register.
Several source issues could lead to this interrupt:
•
When the Ni_SFTY_INT_STS.DP_RX_PARITY_ERR is set to 1, an RX message
data is having a parity error
•
When the Ni_SFTY_INT_STS.DP_TX_PARITY_ERR is set to 1, a TX message data
is having a parity error
DP_SEQ_ERR
The RX_MSG or TX_MSG interface used to synchronize the MH and PRT data
exchange is not functional. A wrong PRT or MH behavior could lead to this issue. A
problem on the logic managing the clock domain crossing on RX_MSG or TX_MSG
interface may be one of the source issues. Status flags are available to identify the
faulty interface, see Ni_ERR_INT_STS register. Several source issues could lead to
this interrupt:
•
When the Ni_ERR_INT_STS.DP_RX_SEQ_ERR is set to 1, an issue is detected on
the RX_MSG interface
•
When the Ni_ERR_INT_STS.DP_TX_SEQ_ERR is set to 1, an issue is detected on
the TX_MSG interface
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4282
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
DP_DO_ERR
An overflow is detected on the RX data path or while acknowledging an RX/TX
descriptor. Some status flags are provided to identify the interrupt source, see
Ni_ERR_INT_STS register
Several source issue could trigger this interrupt:
•
When the Ni_ERR_INT_STS.DP_RX_FIFO_DO_ERR is set to 1, an RX DMA FIFO
overflow is detected. Several reasons could explain such issue: a very high
system latency (over the expected limit considered for the MH), a system
memory no more accessible and a wrong MH behavior.
•
When the Ni_ERR_INT_STS.DP_RX_ACK_DO_ERR is set to 1, an ACK DMA FIFO
overflow is detected. Such issue occurs when the acknowledgment of an RX
descriptor is not possible due to some pending ones. A system memory not
accessible or a wrong MH behavior (DMA_CONTROLLER not functional,
deadlock on RX/TX acknowledge path) could explain such issue.
•
When the Ni_ERR_INT_STS.DP_TX_ACK_DO_ERR is set to 1, an ACK DMA FIFO
overflow is detected. Such issue occurs when the acknowledgment of a TX
descriptor is not possible due to some pending ones. A system memory not
accessible or a wrong MH behavior (DMA_CONTROLLER not functional,
deadlock on RX/TX acknowledge path) could explain such issue
DP_TO_ERR
When the PRT is not responding after a certain amount of time, either on RX or on
TX path, the DP_TO_ERR interrupt is triggered. The counter on RX_MSG or TX_MSG
interface starts with the Start Of Frame and stop when receiving the timestamp.
The timeout value is programmable by SW. Some status flags provide the interrupt
source, see Ni_SFTY_INT_STS register.
Several source issue could trigger this interrupt:
•
When the Ni_SFTY_INT_STS.DP_PRT_RX_TO_ERR is set to 1, the timeout value
defined on the RX_MSG interface is over. The PRT or MH may be locked,
preventing data reception
•
When the Ni_SFTY_INT_STS.DP_PRT_TX_TO_ERR is set to 1, the timeout value
defined on the TX_MSG interface is over. The PRT or MH may be locked,
preventing data transmission
DMA_TO_ERR
When the S_MEM is not responding after a defined time interval, the DMA_TO_ERR
is triggered. The timeout value is programmable by SW. Some status flags provide
the interrupt source, see Ni_SFTY_INT_STS register. Several source issue could
trigger this interrupt:
•
When the Ni_SFTY_INT_STS.DMA_AXI_RD_TO_ERR is set to 1, the timeout
value defined on the DMA AXI read channel interface is over. A system memory
no more accessible or a DMA_CONTROLLER in deadlock could explain such
issue.
•
When the Ni_SFTY_INT_STS.DMA_AXI_WR_TO_ERR is set to 1, the timeout
value defined on the DMA AXI write channel interface is over. A system memory
no more accessible or a DMA_CONTROLLER in deadlock could explain such
issue.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4283
v1.1
2025-06-26


Table 1057
(continued) Interrupts
Interrupt
Description
MEM_TO_ERR
When the L_MEM is not responding after a defined time interval the MEM_TO_ERR
is triggered. The timeout value is programmable by SW. Some status flags are
provided to identify the interrupt source, see Ni_SFTY_INT_STS register. Several
source issue could trigger this interrupt:
•
When the Ni_SFTY_INT_STS.MEM_AXI_RD_TO_ERR is set to 1, the timeout
value defined on the MEM AXI read channel interface is over. A local memory no
more accessible or a memory controller in deadlock could explain such issue.
•
When the Ni_SFTY_INT_STS.MEM_AXI_WR_TO_ERR is set to 1, the timeout
value defined on the MEM AXI write channel interface is over. A local memory
no more accessible or a memory controller in deadlock could explain such
issue.
DMA_CH_ERR
Data received or sent are not routed to or from the right DMA channels. Such issue
will lead to data corruption and wrong MH behavior. There are no status flags to
identify the source channel being faulty.
RESP_ERR[1:0]
Any error response from the DMA AXI and MEM AXI interfaces can lead to a
RESP_ERR[1:0] interrupts. Some status flags provide the interrupt source, see
Ni_SFTY_INT_STS register. Several source issue could trigger those interrupts:
•
When the RESP_ERR[0] interrupt is set, a write access error is detected on
either the DMA_AXI or MEM_AXI write channel.
•
When the RESP_ERR[1] interrupt is set, a read access error is detected on
either the DMA_AXI or MEM_AXI read channel.
The Ni_AXI_ERR_INFO register provides a detailed description of the faulty AXI
interface, refer to the Ni_AXI_ERR_INFO.MEM_RESP[1:0] or
Ni_AXI_ERR_INFO.DMA_RESP[1:0] bit field to determine which one (must be
different from 0’b00).
The traffic getting the error response is defined when looking at the
Ni_AXI_ERR_INFO.MEM_ID[1:0] (if Ni_AXI_ERR_INFO.MEM_RESP[1:0] is different
from 0’b00) or Ni_AXI_ERR_INFO.DMA_ID[1:0] bit field (if
Ni_AXI_ERR_INFO.DMA_RESP[1:0] is different from 0’b00).
In case several response errors occur on the same interface, only the AXI ID of the
last one is captured.
22.5.3.30
Local memory map
In order to perform the RX filtering and the TX-SCAN, the MH requires a local memory. This local memory called
L_MEM is addressable through the MEM_AXI interface. The MEM_AXI interface is able to address up to 64 KBytes
with a 32 bit data bus width.
The L_MEM is storing all the RX filter elements, Header Descriptor for TX FIFO and Priority Queues, as well as a
single Trailing Descriptor when considering TX message defined with several descriptors.
22.5.3.30.1
TX descriptors
The TX FIFO Queue descriptors are organized into the L_MEM starting at the base address defined in
Ni_TX_DESC_MEM_ADD.fq_base_add[15:0]. Up to 8 memory location, of size 8 × 32 bit , is required to hold the
TX Header Descriptor of every TX FIFO Queues.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4284
v1.1
2025-06-26


Every TX FIFO Queue, when active, has its current and next descriptor defined into the L_MEM for the TX-SCAN
process. This means, for a given TX FIFO Queue, memory space must be double. The current and the next TX
Header Descriptor are used for the TX-SCAN.
The TX Priority Queue descriptors are organized into the L_MEM starting at the base address defined in
Ni_TX_DESC_MEM_ADD.PQ_BASE_ADDR[15:0]. Up to 32 memory location, of size 8 × 32 bit , is required to hold
the TX Header Descriptors of every slot. As there is only one TX message per slot, there is no need to allocate
more space.
When a TX message is split over several descriptors, a temporary memory location is used to hold the Trailing
Descriptor to retrieve payload data (see Temporary Descriptor below).
The TX descriptor element are organized in 32 bit word and so any offset would be a multiple of 8. Here below is
the memory organization of the TX descriptors considering N TX FIFO Queues and M TX Priority Queue Slots:
Table 1058
Memory organization of the TX descriptors
Memory base
address
Offset
Name
Bit field
Description
FQ_BASE_ADD[15:0]
0x0+0x40*n
0x0 + 0x40 × n
TX FIFO Queue n
(current/next TX
Header Descriptor)
(0 <= n < N)
Element 0
TX Header
Descriptor, see TX
descriptor, TX
Message and TX FIFO
Queue chapters
0x4+0x40*n
0x4 + 40 × n
Element 1
0x8 + 0x40 × n
Element 2: TS0
0xC + 0x40 × n
Element 3: TS1
0x10 + 0x40 × n
Element 4: T0
0x14 + 0x40 × n
Element 5: T1
0x18 + 0x40 × n
Element 6: T2/TD0
0x1C + 0x40 × n
Element 7:
TX_AP/TD1
0x20 + 0x40 × n
TX FIFO Queue n
(next/current TX
Header Descriptor)
(0<= n < N)
Element 0
TX Header
Descriptor, see TX
descriptor, TX
Message and TX FIFO
Queue chapters
0x24 + 0x40 × n
Element 1
0x28 + 0x40 × n
Element 2: TS0
0x2C + 0x40 × n
Element 3: TS1
0x30 + 0x40 × n
Element 4: T0
0x34 + 0x40 × n
Element 5: T1
0x38 + 0x40 × n
Element 6: T2/TD0
0x3C + 0x40 × n
Element 7:
TX_AP/TD1
 
 
 
 
0x0 + 0x40 × N
Temporary TX
Trailing Descriptor
Element 0
TX Trailing
Descriptor, see TX
descriptor, TX
Message and TX FIFO
Queue chapters
0x4 + 0x40 × N
Element 1
0x8 + 0x40 × N
Element 2: TS0
0xC + 0x40 × N
Element 3: TS1
0x10 + 0x40 × N
Element 4: T0
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4285
v1.1
2025-06-26


Table 1058
(continued) Memory organization of the TX descriptors
Memory base
address
Offset
Name
Bit field
Description
0x14 + 0x40 × N
Element 5: T1
0x18 + 0x40 × N
Element 6: T2/TD0
0x1C + 0x40 × N
Element 7:
TX_AP/TD1
PQ_BASE_ADD[15:0]
0x0 + 0x20 × m
TX Priority Queue
slot n (0<= m < M)
Element 0
TX Header
Descriptor, see TX
descriptor, TX
Message and TX
Priority Queue
chapters
0x4 + 0x20 × m
Element 1
0x8 + 0x20 × m
Element 2: TS0
0xC + 0x20 × m
Element 3: TS1
0x10 + 0x20 × m
Element 4: T0
0x14 + 0x20 × m
Element 5: T1
0x18 + 0x20 × m
Element 6: T2/TD0
0x1C + 0x20 × m
Element 7:
TX_AP/TD1
As the L_MEM can be shared across several MH, the SW is having some flexibility to allocate TX FIFO/Priority
Queue descriptors anywhere and also according to the usage of the application. As an example, if only 4 TX
FIFO Queues is required with a TX Priority Queue with 16 slots the expected memory size would be half
compare to the maximum configuration possible. It is obvious that this kind of configuration would assume TX
FIFO Queues are continuous, meaning 0, 1, 2 and 3 AND TX Priority Queue slots 0, 1, ... and 15.
One must be careful if more TX FIFO Queue and TX Priority Queue slots are required as more memory space
would then need to be allocated. As a matter of fact, if the SW is able to enable any TX FIFO Queue and/or TX
Priority Queue slots, the worst configuration would be a memory space configured with 8 TX FIFO Queues and
32 TX Priority Queues.
22.5.3.30.2
RX filter elements
The filter elements to be parsed are stored into the local memory on 32 bit word. The global setting of the RX
Filter is defined by the Ni_RX_FILTER_CTRL register and will apply to all filter elements. Up to n filter elements
can be defined (where n is from 0 to 255) with up to m reference/mask pair (where m is from 0 to 255). The
number of elements is defined in the Ni_RX_FILTER_CTRL.NB_FE[7:0] bit-field register.
Table 1059
Memory Base Address
Offset
( 0 ≤n ≤254 )
( 0 < n < 255 )
Name
( 0 ≤n ≤254 )
( 0 < n < 255 )
Description
RX_FILTER_ADD[15:0]
0x0
FE0
Define the RX filter
element 0
 
 
 
0x4 × n
FEn
Define the RX filter
element n −1
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4286
v1.1
2025-06-26


Table 1059
(continued)
Memory Base Address
Offset
( 0 ≤n ≤254 )
( 0 < n < 255 )
Name
( 0 ≤n ≤254 )
( 0 < n < 255 )
Description
RX_FILTER_ADD[15:0]
+0x4 × n
0x0
REF0
RX Filter Reference value 0
0x4 0x4
MSK0
RX Filter Reference mask 0
 
 
 
0x0 + 0x4 × m
REFm
RX Filter Reference value
m
0x4 + 0x4 × m
MSKm
RX Filter Reference mask
m
As the local memory can be shared across several Message Handler, the SW is having some flexibility to allocate
RX filter elements and references anywhere and also according to the usage of the application. As a memory
space of 64 Kbytes is addressable, the start address of those elements is defined in the
Ni_RX_FILTER_MEM_ADD.BASE_ADDR[15:0] bit-field register.
22.5.3.31
Application information
General information related to performances, starting and stopping RX/TX FIFO Queues as well as TX Priority
Queue.
22.5.3.31.1
Queue status flags
The TX FIFO Queue status is defined according to the bit status in the Ni_TX_FQ_STS0 register, as shown in the
table below:
Table 1060
TX FIFO Queue status
Ni_TX_FQ_STS0.BUSY[n]
Ni_TX_FQ_STS0.STOP[n]
Status for TX FIFO QUEUE n (n = 0
to 31)
0
0
Inactive: The TX FIFO Queue can be
programmed and started if enabled
0
1
na
1
0
Active and running: The TX FIFO
Queue is enabled and has been
started. TX messages are sent
whenever possible to the PRT
1
1
Active and on hold: When
considering no functional or safety
errors, this status is reached when
an invalid TX descriptor is fetched
from S_MEM.
The TX Priority Queue slot n status is defined according to the bit status in the Ni_TX_PQ_STS0 register, as
shown in the table below
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4287
v1.1
2025-06-26


Table 1061
TX Priority Queue status
Ni_TX_PQ_STS0.BUSY[n]
Status for TX PRIORITY QUEUE slot n (n=0 to 31)
0
Inactive: The TX Priority Queue can be programmed
and started if enabled
1
Active and running: The TX Priority Queue is enabled
and has been started. TX message in the slot n can be
transmitted whenever possible
Compared to the TX FIFO Queues, there is no STOP bits. Any errors related to a TX Priority Queue slot execution
sets the slot as inactive.
Table 1062
RX FIFO Queue status
Ni_RX_FQ_STS0.BUSY[n]
Ni_RX_FQ_STS0.STOP[n]
Status for RX FIFO QUEUE n (n = 0
to 31)
0
0
Inactive: The RX FIFO Queue can be
programmed and started if enabled
0
1
na
1
0
Active and running: The RX FIFO
Queue is enabled and has been
started. RX messages can be
received from the PRT
1
1
Active and on hold: When
considering no functional or safety
errors, this status is reached when
an invalid RX descriptor is fetched
from S_MEM.
22.5.3.31.2
Cluster
The same L_MEM can be shared accross several Message Handler but several points need to be highlighted. A
tradeoff needs to be found to ensure every MH will get enough time to complete their RX filter process as well as
their TX-Scan for a given L_MEM bandwidth.
•
The worst scenario on RX path is defined when all MH in a cluster are receiving an RX message at the same
time. Therefore, it is essential to ensure the available bandwidth on the L_MEM is able to support the RX
filter process from all concurrent MH. Several measures can be taken to lower the bandwidth for a given
value: limit the number of RX filter elements and the number of comparison (1 or 2) per filter element.
•
The worst scenario on TX path is defined by all TX FIFO queues active for every MH as well as new TX
messages being added to all TX Priority Queue slots. As one message is added or sent at a time for every
MH, the impact of the TX-Scan may be limited but may play an important role by generating more
arbitration occurences
•
The read latency to access the L_MEM is a common factor for all MH and should be as low as possible. This
access time is driven the overall performances when in cluster mode
22.5.3.31.3
Performances
Several processing time have a direct impact on the overall MH performances, see sections below.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4288
v1.1
2025-06-26


Core clock frequency
The minimum MH core clock frequency is driven by several parameters:
•
The maximum number of RX filter elements to support
•
The Classical CAN, CAN FD and CAN XL bit rates (Arbitration and Data Phase)
•
The L_MEM read latency
•
The maximum number of TX FIFO Queues
To estimate the minimum core clock frequency to set, please refer to excel file [6]. One must keep in mind that
the computated value is a minimum. Other clock frequency constraints may require an higher clock speed on
the MH.
TX-Scan
The TX-Scan does compute the highest priority message over the TX FIFO queues and the TX Priority Queue
slots. The processing time is mainly link to the number of TX FIFO Queues active at the same time as well as the
number of TX Priority Queue slots being set active. The higher the number of slots and TX FIFO queues active,
the higher the bandwitdh from the L_MEM. The sooner the result is known the better the expected transmission
order is. For more detail on TX-Scan refer to the TX-Scan chapter.
RX Filter
As the RX filter elements are defined and read from the L_MEM, any RX message received will generate many
accesses. The number of RX filter elements and the number of comparisons per element drive the bandwidth
from the L_MEM and so the processing time. The higher the number of filter elements the higher it takes to
define if an RX message is accepted or rejected. Despite some measures are in place to avoid to discard the
current RX message, the SW would need to sort the non dispatched messages later on. For more detail on RX
Filter refer to the RX Filter chapter.
The process of filtering is started as soon as the first RX message header data is received. When an RX filter
element expects an RX data word that is not already stored, the process stops and waits for the RX data word.
As the RX filter element are fetched linearly from the L_MEM, it is required to have them organized in a specific
way to optimize the filtering time. This means, the RX filter elements, having to be compared to the first header
data word, must be stored at the beginning, the ones using the second header data word at the last position.
The Classical CAN with a low bit rate does provide more margin to complete the RX filtering in time. The critical
path is defined when receiving CAN FD frame with no payload data.
As a general rule, it is recommended to define RX filter elements in this order:
1.
CAN FD, assuming that only one comparison with the first message header word is required
2.
CAN XL, assuming either one or two comparisons could be defined
3.
Classical CAN , assuming that only one comparison with the first message header word is required
Such RX filter elements organization will optimize the overall processing time.
RX or TX Descriptors memory organization
RX/TX descriptors are fetched from the S_MEM. The DMA_CONTROLLER is reading and writing data to the
S_MEM using burst length of various sizes. As soon as the address to read or write data is aligned on burst
length of 8, all the following burst transfer are using maximum burst length of 8. If the address to fetch the
RX/TX descriptor does cross a burst of 8 boundary, two read accesses are required.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4289
v1.1
2025-06-26


TX path
As the TX header descriptor is store locally in the MH there is no constraint regarding the access time from the
S_MEM. Nevertheless, several recommendation will help to increase access performances and to limit power
consumption:
•
Align TX FIFO Queue start address on maximum burst length (8 word of 32 bit)
•
Align TX Priority Queue start address on maximum burst length (8 word of 32 bit)
•
Define TX FIFO and or Priority Queues (link list of TX descriptors) in SRAM to leave more time for payload
data fetching. This is best pratice to declare TX descriptor in SRAM whenever possible
RX path
RX descriptors fetches are driving the RX messages write to S_MEM. On top of it, if the RX filtering is taking too
much time, an RX DMA FIFO overflow may occur. Several recommendation will help to increase access
performances and to limit power consumption:
•
Align RX FIFO Queue start address on maximum burst length (8 word of 32 bit)
•
Define RX FIFO Queues (link list of RX descriptors) in SRAM to leave more time for RX filtering. This is best
practice to declare RX descriptor in SRAM whenever possible
Data payload buffer memory organization
Any accesses done from or to the S_MEM by the DMA will be fully optimized as the address is aligned on the
maximum burst length (8x32bit).
TX path
•
Align data container start address on maximum burst length (8 word of 32 bit)
•
Use data container size multiple of maximum burst length (8 word of 32 bit)
RX path
•
Align data container start address on maximum burst length (8 word of 32 bit), whatever the mode (Normal
or Continuous)
•
Use data container size multiple of maximum burst length (8 word of 32 bit)
High system memory latency
If the latency time to get the first payload data burst is greater than the computed value, an underrun will occur
when starting to transmit a TX message to the PRT. As many DMA requests may occur to the system bus at the
same time, some critical scenarios could lead to delay the fetch of the first payload data, providing underrun. If
one of the TX descriptor DMA requests is preempting the access to the first payload data for the current TX
message, the delay would be larger than the one expected. As an example, starting all TX FIFO Queues and TX
Priority Queue slots at the same time may increase the probability to have an underrun.
Very high system latency may lead to underrun due to the high constraints on burst accesses. The data
underrun is a warning and won't affect the MH behavior and the order of the TX messages. No TX message with
underrun is dropped and it will still be considered in the next TX-Scan run.
Nevertheless, here below are a list of recommendations to avoid and limit issues in a system with high latency:
TX path
Every TX descriptor and its payload data are fetched from the S_MEM. The payload data is only read from the
S_MEM when the TX message (defined by its TX descriptor) started to be transmitted on the CAN bus (meaning
the message has won the CAN bus arbitration). Thus, in case of very high latency system, a data underrun may
occur on the PRT. As a matter of fact, the critical path is defined by the first bunch of payload data to be fetched.
Several actions can be done to cope with high system latency:
•
Align data container start address on maximum burst length (8 word of 32bit)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4290
v1.1
2025-06-26


•
Align TX FIFO Queue start address on maximum burst length (8 word of 32bit)
•
Align TX Priority Queue start address on maximum burst length (8 word of 32bit)
•
Use data container size multiple of maximum burst length (8 word of 32bit)
•
The usage of write outstanding transaction may not provide a significant improvement as the write
accesses are somehow sequential. Nevertheless, it is recommended to set it to the maximum value, see
Ni_AXI_PARAMS.AW_MAX_PEND[1:0] bit register
•
Make use of read outstanding transaction (this is mandatory to avoid cases where DMA channel are
competing against each other to read the S_MEM). The maximum value is recommended, see
Ni_AXI_PARAMS.AR_MAX_PEND[1:0] bit register
•
Define TX FIFO/Priority Queues (linked list of TX descriptors) in SRAM to leave more time for payload data
fetching. This is best practice to declare descriptor in SRAM whenever possible
RX path
Every RX descriptor is fetched from the S_MEM. As for the TX path, the critical path is defined by the first RX
descriptor to be fetched, once the RX FIFO Queue number is defined by the RX filter. As soon as the RX FIFO
Queue is known, there is still some time required to read the corresponding RX descriptor and to write the data
payload to the S_MEM. To avoid any RX DMA FIFO overflow and to limit the constraints at system level, the
faster the RX descriptor is read from the S_MEM the faster the payload data can be written to the S_MEM.
Nevertheless, several actions can be done to cope with high system latency:
•
Align data container start address on maximum burst length (8 word of 32bit)
•
Align RX FIFO Queue start address on maximum burst length (8 word of 32bit)
•
Use data container size multiple of maximum burst length (8 word of 32bit)
•
The usage of write outstanding transaction may not provide a significant improvement as the write
accesses are somehow sequential and the RX DMA FIFO sized to support high latency. Nevertheless, it is
recommended to set it to the maximum value, see Ni_AXI_PARAMS.AW_MAX_PEND[1:0] bit register
•
Make use of read outstanding transaction (this is mandatory to avoid cases where DMA channel are
competing against each other to read the S_MEM). The maximum value is recommended, see
Ni_AXI_PARAMS.AR_MAX_PEND[1:0] bit register
•
Define RX FIFO Queues (linked list of RX descriptors) in SRAM to shorter the reaction time when receiving an
RX message. This is best practice to declare descriptor in SRAM whenever possible
22.5.3.32
PRT and ENABLE signal
The PRT signalizes via ENABLE whether it is active and requires message handling or not. It means a message
can be received or transmitted only if the ENABLE signal is set high by the PRT.
As soon as this ENABLE signal goes low, the MH must stop its activity and goes in idle state. The MH is stopped,
therefore the active TX FIFO Queue n and RX FIFO Queue m are put on hold, it means: Ni_TX_FQ_STS0.BUSY[n] =
1, Ni_RX_FQ_STS0.BUSY[m] = 1, Ni_TX_FQ_STS0.STOP[n] = 1 and Ni_RX_FQ_STS0.STOP[m] = 1. Any active TX
Priority Queue slot k is discarded, Ni_TX_PQ_STS0.BUSY[k] = 0. Any RX message received or TX message
transmitted at that time is discarded. Therefore, it is up to the SW to decide what to do next:
•
Keep going: As soon as the ENABLE signal is back to high, the SW would need to write the
Ni_MH_CTRL.START bit to 1 to set the MH in active mode. Then, the already started TX FIFO Queues would
need to be started again, using the Ni_TX_FQ_CTRL0.START[7:0] bit field register, to continue their
execution from where they were. Once the Ni_RX_FQ_CTRL0.START[7:0] bit field register would be set to re-
started the RX FIFO Queues, they would be back to where they were before being stopped. Within such
option, all the registers and internal buffers will remain the same, only start bits are used to continue MH
execution at the point of time it was stopped
•
Reinitialize MH partly or completely: The SW can decide to cancel the execution of an RX/TX FIFO Queue or
TX Priority Queue slot. To do so, use the Ni_TX_FQ_CTRL1.ABORT[7:0], Ni_RX_FQ_CTRL1.ABORT[7:0] or
Ni_TX_PQ_CTRL1.ABORT[31:0] bit field register. Only active RX/TX FIFO Queues and TX Priority Queue slots
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4291
v1.1
2025-06-26


can be aborted (see Ni_TX_FQ_STS0.BUSY[7:0], Ni_RX_FQ_STS0.BUSY[7:0] and Ni_TX_PQ_STS0.BUSY[31:0]
bit field registers). Once the selected RX/TX FIFO Queue and TX Priority Queue slot are aborted, the relevant
ones can be started to keep going from where they were. Nothing is preventing the SW to abort all active
RX/TX FIFO Queues and TX Priority Queue slots to reinitialize completely the MH.
22.6
Protocol controller (PRT)
This document describes the PRT, the CAN XL protocol controller, and its interfaces with the host controller, a
message handler frontend, and the CAN transceiver.
22.6.1
Feature list
•
Classical CAN, CAN FD and CAN XL as specified in ISO 11898-1:2024
•
Classical CAN bit rate up to 1 Mbps
•
Arbitration phase bit rate up to 1 Mbps for CAN FD and for CAN XL
•
CAN FD data phase bit rate up to 8 Mbps at a clock speed of 80 MHz or 160 MHz
•
CAN XL data phase bit rate up to 20 Mbps at a clock speed of 160 MHz
•
Dedicated timebase interfaces
22.6.2
Functional overview
The PRT is a CAN XL Protocol Controller that can be integrated into different CAN modules. The PRT performs
CAN communication as specified in ISO 11898-1:2024. The bit-rate can be configured to values up to 20 MBit/s
at a clock speed of 160 MHz, depending on the used semiconductor technology. For the connection to the
physical layer, additional transceiver hardware is required, which is connected through GPIO ports or may be
integrated into the CAN module (see chapter “Transceiver interface”).
The PRT does not provide internal buffering of frames, so that data has to be transferred by IP internal Message
Busses in 32-bit slices in real-time while (de)-serialization on the CAN Bus. Thus single data transfers at the
internal Message Busses are closely time-synchronized to the schedule at the CAN bus.
XCAN_PRT -  CAN XL Protocol Controller
RX-Buffers
RX_MSG
TX_MSG
CAN_TX
REG AXI
ENABLE
CAN_RX
XLT
D_RX
CAPTURE
TIMESTAMP
Rx
Tx
TX-Buffers
Shift Register
64
Protocol
FSM
AXI Bus
Multibit  Signal
Discrete Signal
Config / Control / Status Registers
PWME_CFG
D_TX
ONLY_CC_FD (static)
ONLY_CC (static)
EVENTS
18
Figure 425
PRT block diagram
The figure above shows principle of the PRT’s functions. When the PRT and the message handler operate in
different clock domains, they are connected through CDC modules. The time base is captured inside a CDC
module, triggered by the PRT’s output signal CAPTURE.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4292
v1.1
2025-06-26


The PRT consists of the CAN Protocol FSM, an Rx/Tx shift register, a set of interface registers for configuration,
control, and status information as well as interfaces to the message handler for received messages and for
messages to be transmitted. The PRT is not designed to store complete messages, there is only transient
caching for two memory words for each direction during reception or transmission. A separate message
handler is needed for the storage of whole messages as well as for functions like acceptance filtering, sorting of
received messages into specific message buffers, and ordering the sequence of messages that are requested for
transmission. Messages are streamed between message handler and PRT as sequences or 32-bit data words.
The host accesses the PRT’s registers through REG_AXI, an AMBA AXI4-Lite interface, for configuration, control,
and status information.
22.6.3
Functional description
The PRT does provide several interrupt outputs that signal, with a high-pulse of one CLK period length, the
occurrence of specific internal events. For test purposes, the Ni_TEST register has a generate interrupt pulse
function GIP so that in hardware test mode HWT an interrupt output pulse can also be triggered by writing a
0b1 to the corresponding Ni_TEST register bit.
Table 1063
Interrupts
Interrupt
TEST bit
Activated when
BUS_OFF
27
Entering Bus_Off state
BUS_ON
26
Starting CAN communication, after starting or end of Bus_Off
E_PASSIVE
25
Switching from error-active to error-passive
E_ACTIVE
24
Switching from error-passive to error-active
BUS_ERR
23
Error detected on CAN bus or protocol exception event detected
RX_EVT
22
Received a valid message
TX_EVT
21
Successfully transmitted a message
IFF_RQ
20
MH requests a message with invalid frame format in header
RX_DO
19
Data overflow condition in RX_MSG sequence detected
TX_DU
18
Data underrun condition in TX_MSG sequence detected
USOS
17
Unexpected start of sequence during TX_MSG sequence detected
ABORTED
16
TX_MSG sequence stopped by TX_MSG_WUSER code ABORT
The PRT outputs internal status information, optionally to be connected to a hardware debug port
•
SAMPLE_POINT: This is the CAN sample point
•
STAT_ACT: This is the actual 2-bit-value of register Ni_STAT.ACT (see register description)
22.6.3.1
Software reset
The software reset is triggered by writing 0b1 to Ni_CTRL.SRES when the CAN protocol operation is stopped.
This does not require an unlocking sequence. The software reset must not be executed when Ni_CTRL.SRES is
written while the CAN protocol operation is started. The software reset resets all state machines of the PRT
(excluding the error-counters and the error-states) and clears the following readable registers: Ni_STAT.TDCV,
Ni_STAT.FIMA, Ni_FIMC.FIP, Ni_TEST.HWT, Ni_TEST.TXC, Ni_TEST.LBCK and all flags of Ni_EVNT. The
configuration registers are not changed by a software reset.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4293
v1.1
2025-06-26


22.6.3.2
Operating mode
The operating mode is defined using the Ni_MODE register and only when the CAN communication is stopped,
otherwise the register is read only. The register Ni_MODE defines separate operating mode options.
The four configuration bits FDOE, XLOE, EFDI, and XLTR, and are interrelated according the table below.
Table 1064
Frame formats
FDOE
XLOE
XLTR EFDI
Description
0
0
X
0
When FDOE is not set, the PRT shall be  to the Classical CAN frame 
format. In this case, when PXHD is set, the PRT shall accept both recessive and
dominant bits as received reserved bits. When PXHD is not set, the PRT shall 
treat a recessive received first reserved bit as a Protocol Exception condition and
shall enter the Protocol Exception State as defined in [1] and it shall set the flag
Ni_EVNT.PXE. FDOE shall be static at 0b0 while the input signal ONLY_CC is 0b1 
0
1
X
X
Invalid configuration
0
X
X
1
Invalid configuration
X
0
X
1
Invalid configuration
1
0
X
0
Operating in Classical CAN and CAN FD frame format. When FDOE is set, the PRT
shall be able to transmit and to receive Classical CAN frames and CAN FD frames
as defined in [1]. When XLOE is not set, the PRT shall not be able to transmit or
to receive CAN XL frames as defined in [1]. When FDOE is set but not XLOE, PXHD
defines the PRT’s reaction on a recessive reserved bit following the recessive
FDF bit in a CAN FD frame. In this case, when PXHD is set, the PRT shall treat this
condition as a Form Error. When PXHD is not set, the PRT shall treat this
condition as a Protocol Exception condition and shall enter the Protocol
Exception State as defined in [1] and it shall set the flag Ni_EVNT.PXE. XLOE shall
be static at 0b0 while the input signals ONLY_CC_FD or ONLY_CC are at 0b1
1
1
0
0
Operating in all frame formats, without XL transceiver. When FDOE and XLOE are
both set and >EFDI is not set, the PRT shall be able to transmit and to receive
Classical CAN frames, CAN FD frames and CAN XL frames as defined in [1]. When
both FDOE and XLOE are set, PXHD defines the PRT’s reaction on a recessive
reserved bit following the recessive XLF bit in a CAN XL frame. In this case, when
PXHD is set, the PRT shall treat this condition as a Form Error. When PXHD is not
set, the PRT shall treat this condition as a Protocol Exception condition and shall
enter the Protocol Exception State as defined in [1] and it shall set the flag
Ni_EVNT.PXE. When EFDI is not set, the PRT shall send error flags as defined in
[1]
1
1
0
1
Operating in XL frame format only, without XL transceiver, error frames are
disabled for all communication. It shall be an invalid configuration to set EFDI
without setting both FDOE and XLOE. When XLTR is not set, the PRT shall not
control the operating mode of the transceiver
1
1
1
0
Invalid configuration
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4294
v1.1
2025-06-26


Table 1064
(continued) Frame formats
FDOE
XLOE
XLTR EFDI
Description
1
1
1
1
Operating in XL frame format only, enabling XL transceiver, error frames are
disabled for all communication. When XLTR is set together with FDOE and XLOE,
the PRT shall control the PWME to the transceiver in order to switch the
operating mode of the transceiver at the beginning and at the end of the CAN XL
data phase, as defined in [1]. When XLTR is set together with FDOE and XLOE, the
PRT shall control the PWME to the transceiver in order to switch the operating
mode of the transceiver at the beginning and at the end of the CAN XL data
phase, as defined in [1]. When EFDI is set together with FDOE and XLOE, the PRT
shall not send error flags and it shall not change its transmit error counter or its
receive error counter. When an error condition occurs, the PRT shall, instead of
sending an error flag, enter Protocol Exception State, like in Restricted Mode, as
defined in [1]
22.6.3.3
Starting and stopping the module
The PRT is started by writing 0b1 to Ni_CTRL.STRT. This does not require an unlocking sequence. After the start
command, the PRT waits for the occurrence of a sequence of 11 consecutive recessive bits (the idle condition of
ISO 11898-1:1995) to finish its integration into the CAN communication on the CAN bus line. When the PRT has
detected the idle condition, it switches into idle state. When it sees a recessive bit on entering idle state, the
PRT is able to start a pending transmission in the following bit. When the PRT sees a dominant bit on entering
idle state, it immediately becomes receiver of that frame.
There are two options to stop the CAN protocol operation under software control, one that waits for the
completion of an ongoing message transfer and one that stops the operation immediately.
The two options use different variants of the Ni_CTRL.STOP command. In the first variant, only the STOP bit is
written to 0b1. In the second variant, both the Ni_CTRL.STOP bit and the Ni_CTRL.IMMD bit are written to 0b1 at
the same time. Both variants require the application of the unlock key sequence, followed by a write access to
the Ni_CTRL register. The three consecutive write accesses may not be interrupted by other accesses through
REG_AXI.
The first variant of the STOP command is asserted this way:
1.
Write 0x1234 to Ni_LOCK.ULK 0x40
2.
Write 0x4321 to Ni_LOCK.ULK 0x40
3.
Write 0b1 to Ni_CTRL.STOP 0x44
The PRT’s reaction to the first variant of the STOP command depends on its current activity (Ni_STAT.ACT).
When the current activity of this node is Idle, it switches its activity to its inactive state immediately and stop all
CAN operation. When the current activity is either Receiver or Transmitter, it continues that activity and it sets
the status flag Ni_STAT.STP to show that it is waiting for end of the actual message after a Ni_CTRL.STOP
command. If no TX_MSG sequence is already started, the PRT clears TX_MSG_WREADY and keep it cleared until
all CAN operation is stopped. As soon as the current reception or transmission is finished (either successfully or
in failure) the PRT reports the result of that transfer to the MH, clears the status flag Ni_STAT.STP, clears
ENABLE, switches its activity to its inactive state, and stops all CAN operation. The PRT does not start another
reception or transmission until it is started again.
The second variant of the STOP command is asserted this way:
1.
Write 0x1234 to Ni_LOCK.ULK 0x40
2.
Write 0x4321 to Ni_LOCK.ULK 0x44
3.
Write 0b1 to Ni_CTRL.IMMD and 0b1 to Ni_CTRL.STOP 0x44
4.
Write 0b1 to Ni_CTRL.SRES 0x44
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4295
v1.1
2025-06-26


The PRT’s reaction to the second variant of the STOP command is to switch its activity to its inactive state
immediately, to stop all CAN operation, and to set its CAN_TX output to 0b1 and to clear ENABLE. When the
current activity was Transmitter, the PRT aborts that transmission. When the current activity was Receiver, it
abort that reception. Both interfaces with the MH are reset, outstanding transactions are discontinued. If this
happens while an RX_MSG sequence was ongoing, this sequence is discontinued with the ABORT code. The PRT
does not start another reception or transmission until it is started again.
The CAN protocol operation stops automatically on the following conditions:
•
When the node enters the CAN protocol’s Bus-Off state
•
Unexpected start of sequence during TX_MSG sequence detected
Note:
Detecting an Unexpected Start of Sequence (USOS) indicates a mis-synchronization between PRT and
MH that requires a restart.
When the CAN protocol operation is stopped, it is started by writing 0b1 to Ni_CTRL.STRT. This does not require
an unlocking sequence.
When the CAN protocol operation was stopped because the PRT entered the CAN Bus_Off state, the start
command (writing 0b1 to Ni_CTRL.STRT) causes the PRT to perform the CAN Bus_Off Recovery Sequence
before it is again able to participate in CAN communication.
The CAN Bus_Off Recovery Sequence (see ISO 11898-1:2024) cannot be shortened by starting or stopping the
PRT. If the PRT goes Bus_Off, it will set Ni_STAT.BO bit and it will, of its own accord, stop all bus activities. Once
the PRT has been started again, the PRT clears Ni_STAT.TEC, Ni_STAT.RP, Ni_STAT.REC, and Ni_STAT.EP but it
will keep Ni_STAT.BO.
The PRT will then wait for 129 occurrences of Bus Idle (129 * 11 consecutive recessive bits) before resuming
normal operation. The PRT uses the Receive Error Counter (Ni_STAT.REC) to count the occurrences of Bus Idle.
Additionally, each time a sequence of 11 recessive bits has been monitored, a Bit0 Error (Ni_EVNT.B0E) is
reported, enabling the host to readily check up whether the CAN bus is stuck at dominant or continuously
disturbed and to monitor the progress of the Bus_Off recovery sequence. When the last-but-one sequence of 11
recessive bits has been monitored, Ni_STAT.RP, and Ni_STAT.EP are set and Ni_STAT.REC is at 0x7F. When the
last sequence of 11 recessive bits has been monitored, the end of the Bus_Off recovery sequence is reached and
Ni_STAT.TEC, Ni_STAT.RP, Ni_STAT.REC, Ni_STAT.EP and Ni_STAT.BO will all be reset. The PRT switches into idle
state.
22.6.3.4
Reaction on exceptions at the TX_MSG and RX_MSG interfaces
22.6.3.4.1
MH requests a message with invalid frame format in header
This is detected when the requested transmit frame format is disabled in the configuration register (see
Ni_MODE.FDOE, Ni_MODE.EFDI, or Ni_MODE.XLOE) or there is an internal contradiction in the header content of
that frame. On the detection of this condition, the PRT ends the TX_MSG sequence with the response code HFI,
generate a pulse on the IFF_RQ interrupt output and it does not transmit that message.
22.6.3.4.2
MH intentionally aborts TX_MSG sequence
If the ABORT command is given with the second transaction of the TX_MSG sequence, the PRT does not start
the transmission. If the ABORT command is given after the second transaction of the TX_MSG sequence, the
PRT sets an internal flag that causes the FCRC bits of that transmission to be transmitted inverted. This internal
flag is cleared at the end of the transmission. In both cases, the PRT generates a pulse on the ABORTED
interrupt output and the ongoing TX_MSG sequence is finished.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4296
v1.1
2025-06-26


22.6.3.4.3
Data underrun condition in TX_MSG sequence detected
This is detected when the ongoing transmission on the CAN bus needed another TX_MSG data word but that
word was not provided in time. On the detection of this condition, the PRT continues the transmission (to avoid
disturbing the message schedule on the CAN bus), but the PRT generates a pulse on the TX_DU interrupt output
and the PRT sets an internal flag that causes the FCRC bits of that transmission to be transmitted inverted (to
avoid the acceptance of a message containing invalid data). This internal flag is cleared at the end of the
transmission. In case of a Data Underrun, the ongoing TX_MSG sequence finishes with the code DU when the
MH transfers the missing data word. After the end of the transmission, TX_MSG_WREADY is asserted again to
accept the following TX_MSG Sequence (starting again with W0).
22.6.3.4.4
Unexpected start of sequence detected
This is detected when the PRT receives a TX_MSG transaction marked as start of sequence before a previously
started TX_MSG sequence has ended. This indicates that MH and PRT operate out-of-phase. On the detection of
this condition, the PRT generates a pulse on the USOS interrupt output and the PRT stops CAN protocol
operation. Afterward, the PRT needs to be restarted under software control by writing 0b1 to Ni_CTRL.STRT.
22.6.3.4.5
Data overflow condition in RX_MSG sequence detected
This is detected when, during an ongoing reception, the MH has not acknowledged an RX_MSG data word in
time. On the detection of this condition, the PRT generates a pulse on the RX_DO interrupt output and the PRT
ends such an RX_MSG sequence through a subsequent transfer with code DO. This transfer with code DO must
be acknowledged by the MH before the PRT can start a new RX_MSG sequence.
22.6.3.5
Controlling the module’s clock input
The PRT has two clock inputs, CLK and CLK_AXI. CLK is the clock input of the PRT excluding its REG_AXI
interface, while CLK_AXI is the clock input of the PRT’s REG_AXI module. Both clocks are synchronous to each
other, driven from the same source. The difference between the two clocks is that CLK_AXI must be always
active (to keep the REG_AXI interface operational), but CLK may be switched off (gated) while the PRT is
stopped, for example when no CAN communication is needed.
•
The recommended clock frequency for CAN XL operation is 160 MHz
•
The recommended clock frequency for CAN FD operation only is 80 MHz
The function of the PRT does not depend on a particular duty-cycle of the clock, that means it reacts only on
rising clock edges. The duration of the clock high pulse may vary between 10% and 90% of the clock period
during operation.
The PRT’s input signal CLOCK_ACTIVE shows whether the clock input CLK of the PRT is active. The actual value
of the CLOCK_ACTIVE input signal is always readable from the status bit Ni_STAT.CLKA, even when CLK is not
active. The signal CLOCK_ACTIVE does not control the PRT’s function, it provides only status information,
coming from a clock multiplexer outside of the PRT.
While CLK is not active, the PRT has no function and cannot be started. CLK must be reactivated before the PRT
needs to be started again.
22.6.3.6
Transceiver interface
The CAN bus is usually implemented as a twisted-pair bus line, its bus wires called CAN_H and CAN_L. An
analog CAN transceiver device is connected to the CAN bus, interfacing between the bidirectional CAN bus wires
and the CAN protocol controller’s unidirectional, digital serial input and output signals. The future CAN XL
transceivers will need to switch between two operating modes during the transmission of a CAN XL message.
The switching control is coded into signals between protocol controller and transceiver. The coding is
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4297
v1.1
2025-06-26


implemented inside a separate, dedicated PWME module that is placed between protocol controller and
transceiver, see block diagram.
The transceiver’s RxD output is connected to the PRT’s CAN_RX input. This asynchronous input signal is
synchronized to the CAN clock by routing it through two synchronizer-FFs. This delay of two clock cycles is part
of the input delay for the calculation of the propagation segment length of the CAN bit time. The CAN bit time
configuration is only functional if the following conditions are fulfilled:
•
NTSEG1 + 1 × BRP × CLK_period  is larger than the transmitter loop delay
•
DTSEG1 + 1 × BRP × CLK_period  and XTSEG1 + 1 × BRP × CLK_period  are larger than the
transmitter loop delay or transmitter delay compensation is enabled
The connection from the PRT to the transceiver is routed through the PWME module (Pulse Width Modulation
Encoder, specified in [1]). In CAN XL communication using a transceiver with switchable operating modes, the
PWME controls the operating mode of the transceiver, to switch it into the CAN XL data phase modes for
transmissions as well as receptions and back. The PWME_CFG configuration data consists of Ni_PCFG.PWMO,
Ni_PCFG.PWML, and Ni_PCFG.PWMS, it is an 18-bit vector concatenating the three 6-bit vectors from
Ni_PCFG.PWMO[5] downto Ni_PCFG.PWMS[0]. The appropriate switching times are signaled by the PRT via its
outputs XLT, D_TX and D_RX (see [1]).
The PWME function is controlled by the following outputs of the PRT: PWME_CFG, XLT, D_TX, D_RX, and CAN_TX.
22.6.3.7
Hardware timestamping
22.6.3.7.1
Timestamping function
Timestamps are captured for each transmitted or received message, captured at either the sample point of the
start of frame bit of the message or at the sample point of the bit when the message becomes valid at the end
of the frame. The capture position is defined by the configuration bit Ni_MODE.SFS.
22.6.3.7.2
Time stamping offset
Due to internal propagation delays for the timestamping in the Protocol Controller (1 CAN clock cycle) and the
clock domain crossing for the time capturing (n clock cycles, depending on the clock frequency ratio between
the CAN and the TIMBASE domain) a certain offset has to be considered to derive the correct time.
These are the formulas for the offset:
TS_offset_max = 2 CAN_CLK period + 3 TIMEBASE_CLK period
TS_offset_min = 2 CAN_CLK period + 2 TIMEBASE_CLK period
This is the formula for the corrected timestamp:
Corrected Timestamp = Timestamp in TX/RX descriptor - TS_offset
22.6.3.8
Trace and debug
The hardware test mode functions are disabled by the software reset of the PRT. The status flag Ni_TEST.HWT
shows whether the hardware test mode functions are enabled.
When the hardware test mode functions are disabled, all bits of Ni_TEST are cleared with the exception of RXD.
Enabling the hardware test mode functions (see chapter “Hardware Test Functions”) requires the application of
the test mode key sequence. The test mode key sequence consists of three consecutive write accesses, not
interrupted by other accesses through REG_AXI:
1.
Write 0x6789 to Ni_LOCK.TMK 0x40
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4298
v1.1
2025-06-26


2.
Write 0x9876 to Ni_LOCK.TMK 0x40
3.
Write 0b1to Ni_CTRL.TEST 0x44
The hardware test mode functions enable the host to directly control the values driven at the transceiver
interface pins, to read the actual transceiver RxD output, and to transmit messages in a loop-back mode where
all transmitted messages are also reported through the RX_MSG interface as received messages.
The CAN_RX input (output signal of the transceiver) is always readable at RXD.
The CAN_TX output control TXC offers four options:
•
0b00: Normal function of CAN_TX
•
0b01: Normal function of CAN_TX, CAN_RX is ignored (for message loop-back mode)
•
0b10: CAN_TX output set to 0b0 and XLT output set to 0
•
0b11: CAN_TX output set to 0b1 and XLT output set to 0
When LBCK is set, the PRT operates in the message loop-back mode. In message loop-back mode, the PRT
reports transmit messages (requested through the TX_MSG interface) through RX_MSG as received messages.
The transmit messages are encoded and decoded bitwise inside the PRT, but a transmitted message is treated
as successfully transmitted even if it does not get ACK. When the host sets LBCK to 0b1, it also sets TXC to either
0b01 or to 0b11 to control whether messages transmitted in the message loop-back mode are visible at the
transceiver pins. In the message loop-back mode with TXC set to a value > 0b00, the actual CAN_RX input
(output signal of the transceiver) is ignored by the PRT.
When the host sets TXC = 0b11 in the message loop-back mode, the PRT keeps the CAN_TX output at 0b1 and
loops back its internal serial output signal to its internal serial input signal.
When the host sets TXC = 0b01 in the message loop-back mode, the PRT drives the frame bits at its CAN_TX
output. In this case, the PRT loops back its internal serial output signal to its internal serial input signal, so it is
not able to perform an arbitration or to react on bit errors on the CAN bus.
If TXC is set as zero b00, the loop-back test may be disturbed by errors on the CAN_RX input.
If TXC is set as 0b01, the loop-back test operates independently from the CAN_RX input, the loop-back
transmission can be monitored at the CAN_TX output.
If TXC is set as 0b11, the loop-back test operates independently from the CAN_RX input, the LoopBack
transmision cannot be monitored at the Tx-pin. This is intended for a self-test in the field, not disturbing the
CAN bus.
22.7
Pulse width modulation encoder (PWME)
This document describes the PWME, the Pulse Width Modulation Encoder, and its interfaces with the CAN XL
protocol controller and the CAN transceiver.
22.7.1
Feature list
•
PWM encoding as specified in [1]
22.7.2
Functional overview
The following figure shows the PWME and its interfaces with the CAN XL protocol controller and the CAN
transceiver.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4299
v1.1
2025-06-26


XCAN_PRT -  CAN XL Protocol Controller
CAN_TX
REG AXI
CAN_RX
XLT
D_RX
Protocol
FSM
CDC
TxD
Pulse
Width
Modulation
Encoder
Config / Control / Status Registers
PWME_CFG
D_TX
PWME
Host
To Transceiver
GPIO 
Ports
Multibit  Signal
Discrete Signal
Figure 426
PWME overview
22.7.3
Functional description
PWME implements the PWM encoding as specified in [1]. When transceiver mode switching is enabled, the
PWME encodes the CAN_TX input signal during a CAN XL frame’s data phase and during ADH bit, to generate the
PWM encoded output signal TXD.
The output of the PWM logic is registered by the Flip Flop TXD_PWME. An active reset sets this Flip Flop
TXD_PWME to one. All Flip Flops in the PWME change their value with the rising edge of CLK.
PWM Logic
CAN_TX
SYMB_CNT [7..0]
TXD
PWME_CFG
XLT,D_TX,D_RX
PWM0_CNT [1..0]
TXD_ 
PWME
Figure 427
PWME block diagram
22.7.3.1
Transparent mode
While XLT is passive or both D_RX and D_TX are passive, the PWME interface behaves transparent between
CAN_TX input and TXD output.
This mode is independent of reset.
22.7.3.2
PWM encoded mode
While XLT is active, the TXD output is PWM encoded for a transmitting node while D_TX is active and for the
receiving node while D_RX active. The PWM encoded TXD output has one CLK cycle delay (internal processing
delay) relative to the bit boundaries on CAN_TX input.
22.7.3.2.1
Transmitting node
When the PWME detects an edge from passive to active on D_TX and if XLT is active, then the PWME drives a
LOW level on TXD for one PWM offset time.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4300
v1.1
2025-06-26


With expiration of the PWM offset time the TXD output drives 2 consecutive PWM_0 symbols. From there
onwards all following PWM symbols follow the CAN_TX input.
When D_TX is passive or XLT is passive the PWME switches back to transparent behavior regardless of the actual
PWM phase.
22.7.3.2.2
Receiving node
When the PWME detects an edge from passive to active on D_RX and if XLT is active, then the PWME drives
consecutive PWM_1 symbols without a leading offset time.
When D_RX is passive or XLT is passive the PWME switches back to transparent behavior regardless of the actual
PWM phase.
22.7.3.3
Application information
Not applicable.
22.7.3.3.1
PWME configuration
The PWME_CFG contains the parameters needed for the PWM encoding (as defined in [1]) in the PWME module.
The PWME_CFG signal may not change its value while the PRT is started, i.e. while CAN frames can be received
and transmitted.
Valid values for the PWM phase Short PWMS are 00H to 3FH. The actual interpretation of this value is that the
PWM short phase length is (PWMS + 1) clock cycles long.
Valid values for the PWM phase Long PWML are 00H to 3FH. The actual interpretation of this value is that the
PWM long phase length is (PWML + 1) clock cycles long.
The PWM symbol length is the sum of PWM short phase length and PWM long phase length (PWMS + PWML + 2)
clock cycles.
Valid values for the PWM Offset PWMO are 00H to 3FH. PWMO shall always be smaller than the PWM symbol
length (PWMO < PWMS + PWML + 2).
22.8
Interrupt Controller (IRC)
22.8.1
Feature list
•
Interrupt generation for Functional events
•
Interrupt generation for Error event
•
Interrupt generation for Safety critical events
•
Masking of individual events
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4301
v1.1
2025-06-26


22.8.2
Functional overview
The X_CAN IP is equipped with a central interrupt controller (IRC). It captures all events of the MH and PRT and
can be configured for each event individually to interrupt the HOST CPU.
The events are organized in two categories, i.e. Functional Events and Error Events. Functional Events can
trigger the IRC output FUNC_INT. Error Events can trigger the IRC outputs ERR_INT and SAFETY_INT.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4302
v1.1
2025-06-26


22.8.3
Functional description
The following table lists the categories and shows the related IRC registers together with the dedicated IRC
outputs:
Table 1065
Interrupt categories
Category
IRC Registers
IRC output
Functional Event
Ni_FUNC_RAW, Ni_FUNC_CLR,
Ni_FUNC_ENA
FUNC_INT
Error Event
Ni_ERR_RAW, Ni_ERR_CLR,
Ni_ERR_ENA
ERR_INT
Ni_SAFETY_RAW, Ni_SAFETY_CLR,
Ni_SAFETY_ENA
SAFETY_INT
For each category, three registers are implemented: xxx_RAW, xxx_CLR, and xxx_ENA. To capture the events, the
xxx_RAW registers are used. These registers provide information about the occurrence of events inside the MH
and the PRT. A flag is set when the related event occurred, independent of xxx_ENA. The flags remain set until
the HOST CPU clears them by writing a 1 to the corresponding bit position at register xxx_CLR.
The xxx_ENA registers control on bit level, whether a certain bit in the xxx_RAW register can activate the
interrupt line xxx_INT. The interrupt line xxx_INT gets active high, when at least one RAW/ENA pair is 1, e.g.
ERR_INT gets active high, when Ni_ERR_RAW.MH_RX_FILTER_ERR = Ni_ERR_ENA.MH_RX_FILTER_ERR = 1.
22.9
Registers
22.9.1
Register overview - access mode glossary
Table 1066
Register overview - access mode glossary
Keyword
Description
E
Access protection using PROT register PROTE.
SE
Access protection using PROT register PROTSE.
APU-PM
Protection group consisting of registers MODULE_ACCEN_WRA, MODULE_ACCEN_WRB,
MODULE_ACCEN_RDA, MODULE_ACCEN_RDB, MODULE_ACCEN_VM, MODULE_ACCEN_PRS.
PM
Access protection using APU-PM registers.
APU-PNi (i=0-3)
Protection group consisting of registers NODEi_ACCENNODE_WRA,
NODEi_ACCENNODE_WRB, NODEi_ACCENNODE_RDA, NODEi_ACCENNODE_RDB,
NODEi_ACCENNODE_VM, NODEi_ACCENNODE_PRS.
PNi
Access protection using APU-PNi registers.
U
No access restrictions.
BE
Always returns a Bus Error.
PROT
Access restrictions as defined in the PROT register access rules.
32
Access only when using 32-bit width.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4303
v1.1
2025-06-26


22.9.2
Registers overview - CANXL (ascending offset address)
Table 1067
Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
ID
Module Identification
Register
00000H
U
BE
PowerOn Reset
4310
OCS
OCDS Control and Status
Register
00004H
PM
SV, PM
Debug Reset
4310
MODULE_CLC
Module Clock Control
Register
00008H
PM
PM, SV, E
Application
Reset
4312
MODULE_RST_C
TRLA
Module reset control
register A
0000CH
PM
PM, SV, E
Application
Reset
4312
MODULE_RST_C
TRLB
Module reset control
register B
00010H
PM
PM, SV, E
Application
Reset
4313
MODULE_RST_S
TAT
Module reset status register 00014H
PM
BE
Application
Reset
4314
MODULE_ACCEN
_WRA
Module Write access enable
register A
00018H
U
SE, SV
Application
Reset
4314
MODULE_ACCEN
_WRB
Module Write access enable
register B
0001CH
U
SE, SV
Application
Reset
4315
MODULE_ACCEN
_RDA
Module Read access enable
register A
00020H
U
SE, SV
Application
Reset
4315
MODULE_ACCEN
_RDB
Module Read access enable
register B
00024H
U
SE, SV
Application
Reset
4316
MODULE_ACCEN
_VM
Module VM access enable
register
00028H
U
SE, SV
Application
Reset
4316
MODULE_ACCEN
_PRS
Module PRS access enable
register
0002CH
U
SE, SV
Application
Reset
4317
PROTE
PROT Register Endinit
00038H
U
SV, PROT
Application
Reset
4318
PROTSE
PROT Register Safe Endinit
0003CH
U
SV, PROT
Application
Reset
4319
CLKEN
Clock enable
00040H
clk, PM
clk, PM, SV,
E
Application
Reset
4321
NODEi_RST_CTR
LA
Node i reset control register
A
00100H+i
*100H
PNi
PNi, SV, E
Application
Reset
4322
NODEi_RST_CTR
LB
Node i reset control register
B
00104H+i
*100H
PNi
PNi, SV, E
Application
Reset
4322
NODEi_RST_STA
T
Node i reset status register
00108H+i
*100H
PNi
BE
Application
Reset
4323
NODEi_ACCENN
ODE_WRA
Node i write access enable
register A
0010CH+
i*100H
U
SE, SV
Application
Reset
4324
NODEi_ACCENN
ODE_WRB
Node i write access enable
register B
00110H+i
*100H
U
SE, SV
Application
Reset
4324
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4304
v1.1
2025-06-26


Table 1067
(continued) Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
NODEi_ACCENN
ODE_RDA
Node i read access enable
register A
00114H+i
*100H
U
SE, SV
Application
Reset
4325
NODEi_ACCENN
ODE_RDB
Node i read access enable
register B
00118H+i
*100H
U
SE, SV
Application
Reset
4326
NODEi_ACCENN
ODE_VM
Node i VM access enable
register
0011CH+
i*100H
U
SE, SV
Application
Reset
4326
NODEi_ACCENN
ODE_PRS
Node i PRS access enable
register
00120H+i
*100H
U
SE, SV
Application
Reset
4327
NODEi_ACCENN
ODE_RGNLA
Node i region lower address
register
00124H+i
*100H
U
SE, SV
Application
Reset
4328
NODEi_ACCENN
ODE_RGNUA
Node i region upper
address register
00128H+i
*100H
U
SE, SV
Application
Reset
4328
NODEi_VMPRSC
ONFIG
Node i VM and PRS
configuration Register
0012CH+
i*100H
U
SE, SV
Application
Reset
4328
NODEi_PORTCTR
L
Node i Port Control Register 00130H+i
*100H
PNi
PNi
Kernel Reset
4329
NODEi_MTI_RAW Node i message transfer
interrupt event register
00134H+i
*100H
PNi
BE
Kernel Reset
4330
NODEi_MTI_CLR
Node i message transfer
interrupt clear register
00138H+i
*100H
PNi
PNi
Kernel Reset
4330
NODEi_MTI_ENA
Node i message transfer
interrupt enable register
0013CH+
i*100H
PNi
PNi
Kernel Reset
4331
DEBUG_CTL
Debug control register
10004H
PM
PM
Kernel Reset
4332
Ni_TS_CTL
Node i timestamp control
20010H+i
*2000H
PNi
PNi
Kernel Reset
4332
Ni_TS_CLOCK_C
TL
Node i timestamp clock
control
20014H+i
*2000H
PNi
PNi
Kernel Reset
4333
Ni_TS_CMD
Node i timestamp
command
20020H+i
*2000H
PNi
PNi
Kernel Reset
4334
Ni_TS_CNT_LO
Node i timestamp counter
LSBs
20030H+i
*2000H
PNi
BE
Kernel Reset
4334
Ni_TS_CNT_HI
Node i timestamp counter
MSBs
20034H+i
*2000H
PNi
BE
Kernel Reset
4335
Ni_VERSION
Node i release
identification register
21000H+i
*2000H
PNi, 32
BE
Kernel Reset
4335
Ni_MH_CTRL
Node i message handler
control register
21004H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4336
Ni_MH_CFG
Node i message handler
configuration register
21008H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4337
Ni_MH_STS
Node i message handler
status register
2100CH+
i*2000H
PNi, 32
BE
Kernel Reset
4338
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4305
v1.1
2025-06-26


Table 1067
(continued) Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_MH_SFTY_CF
G
Node i message handler
safety configuration
register
21010H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4339
Ni_MH_SFTY_CT
RL
Node i message handler
safety control register
21014H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4340
Ni_RX_FILTER_M
EM_ADD
Node i RX filter base
address register
21018H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4341
Ni_TX_DESC_ME
M_ADD
Node i TX descriptor base
address register
2101CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4342
Ni_AXI_ADD_EXT
Node i AXI address
extension register
21020H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4342
Ni_AXI_PARAMS
Node i AXI parameter
register
21024H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4343
Ni_MH_LOCK
Node i message handler
lock register
21028H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4343
Ni_TX_DESC_AD
D_PT
Node i TX descriptor
current address pointer
register
21100H+i
*2000H
PNi, 32
BE
Kernel Reset
4344
Ni_TX_STATISTIC
S
Node i TX message counter
register
21104H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4344
Ni_TX_FQ_STS0
Node i TX FIFO queue status
register
21108H+i
*2000H
PNi, 32
BE
Kernel Reset
4345
Ni_TX_FQ_STS1
Node i TX FIFO queue status
register
2110CH+
i*2000H
PNi, 32
BE
Kernel Reset
4346
Ni_TX_FQ_CTRL0 Node i TX FIFO queue
control register 0
21110H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4346
Ni_TX_FQ_CTRL1 Node i TX FIFO queue
control register 1
21114H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4347
Ni_TX_FQ_CTRL2 Node i TX FIFO queue
control register 2
21118H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4348
Ni_TX_FQ_ADD_
PTr
Node i TX FIFO queue
r current address pointer
register
21120H+i
*2000H+r
*10H
PNi, 32
BE
Kernel Reset
4348
Ni_TX_FQ_START
_ADDr
Node i TX FIFO queue r start
address register
21124H+i
*2000H+r
*10H
PNi, 32
PNi, 32
Kernel Reset
4349
Ni_TX_FQ_SIZEr
Node i TX FIFO queue r size
register
21128H+i
*2000H+r
*10H
PNi, 32
PNi, 32
Kernel Reset
4349
Ni_TX_PQ_STS0
Node i TX priority queue
status register
21300H+i
*2000H
PNi, 32
BE
Kernel Reset
4350
Ni_TX_PQ_STS1
Node i TX priority queue
status register
21304H+i
*2000H
PNi, 32
BE
Kernel Reset
4350
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4306
v1.1
2025-06-26


Table 1067
(continued) Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_TX_PQ_CTRL
0
Node i TX priority queue
control register 0
2130CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4351
Ni_TX_PQ_CTRL
1
Node i TX priority queue
control register 1
21310H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4351
Ni_TX_PQ_CTRL
2
Node i TX priority queue
control register 2
21314H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4352
Ni_TX_PQ_STAR
T_ADD
Node i TX priority queue
start address
21318H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4352
Ni_RX_DESC_AD
D_PT
Node i RX descriptor
current address pointer
21400H+i
*2000H
PNi, 32
BE
Kernel Reset
4353
Ni_RX_STATISTIC
S
Node i RX message counter
register
21404H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4353
Ni_RX_FQ_STS0
Node i RX FIFO queue status
register 0
21408H+i
*2000H
PNi, 32
BE
Kernel Reset
4354
Ni_RX_FQ_STS1
Node i RX FIFO queue status
register 1
2140CH+
i*2000H
PNi, 32
BE
Kernel Reset
4355
Ni_RX_FQ_STS2
Node i RX FIFO queue status
register 2
21410H+i
*2000H
PNi, 32
BE
Kernel Reset
4355
Ni_RX_FQ_CTRL0 Node i RX FIFO queue
control register 0
21414H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4356
Ni_RX_FQ_CTRL1 Node i RX FIFO queue
control register 1
21418H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4356
Ni_RX_FQ_CTRL2 Node i RX FIFO queue
control register 2
2141CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4357
Ni_RX_FQ_ADD_
PTs
Node i RX FIFO queue s
current address pointer
21420H+i
*2000H+
s*18H
PNi, 32
BE
Kernel Reset
4357
Ni_RX_FQ_START
_ADDs
Node i RX FIFO queue s link
list start address
21424H+i
*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4358
Ni_RX_FQ_SIZEs
Node i RX FIFO queue s link
list and data container size
21428H+i
*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4358
Ni_RX_FQ_DC_S
TART_ADDs
Node i RX FIFO queue s data
container start address
2142CH+
i*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4359
Ni_RX_FQ_RD_A
DD_PTs
Node i RX FIFO queue s read
address pointer
21430H+i
*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4360
Ni_TX_FILTER_CT
RL0
Node i TX filter control
register 0
21600H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4360
Ni_TX_FILTER_CT
RL1
Node i TX filter control
register 1
21604H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4361
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4307
v1.1
2025-06-26


Table 1067
(continued) Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_TX_FILTER_R
EFVALt
Node i TX filter reference
value register t
21608H+i
*2000H+t
*4
PNi, 32
SV, PNi, 32
Kernel Reset
4362
Ni_RX_FILTER_C
TRL
Node i RX filter control
register
21680H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4363
Ni_TX_FQ_INT_S
TS
Node i TX FIFO queue
interrupt status register
21700H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4364
Ni_RX_FQ_INT_S
TS
Node i RX FIFO queue
interrupt status register
21704H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4365
Ni_TX_PQ_INT_S
TS0
Node i TX priority queue
interrupt status register 0
21708H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4365
Ni_TX_PQ_INT_S
TS1
Node i TX priority queue
interrupt status register 1
2170CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4366
Ni_STATS_INT_S
TS
Node i statistics interrupt
status register
21710H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4366
Ni_ERR_INT_STS Node i error interrupt status
register
21714H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4367
Ni_SFTY_INT_ST
S
Node i safety interrupt
status register
21718H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4368
Ni_AXI_ERR_INF
O
Node i DMA error
information
2171CH+
i*2000H
PNi, 32
BE
Kernel Reset
4369
Ni_DESC_ERR_IN
FO0
Node i descriptor error
information 0
21720H+i
*2000H
PNi, 32
BE
Kernel Reset
4370
Ni_DESC_ERR_IN
FO1
Node i descriptor error
information 1
21724H+i
*2000H
PNi, 32
BE
Kernel Reset
4371
Ni_TX_FILTER_E
RR_INFO
Node i TX filter error
information
21728H+i
*2000H
PNi, 32
BE
Kernel Reset
4371
Ni_DEBUG_TEST
_CTRL
Node i debug control
register
21800H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4372
Ni_INT_TEST0
Node i interrupt test
register 0
21804H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4373
Ni_INT_TEST1
Node i interrupt test
register 1
21808H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4373
Ni_TX_SCAN_FC
Node i TX-SCAN first
candidates register
21810H+i
*2000H
PNi, 32
BE
Kernel Reset
4376
Ni_TX_SCAN_BC
Node i TX-SCAN best
candidates register
21814H+i
*2000H
PNi, 32
BE
Kernel Reset
4377
Ni_TX_FQ_DESC
_VALID
Node i valid TX FIFO queue
descriptors in local memory
21818H+i
*2000H
PNi, 32
BE
Kernel Reset
4378
Ni_TX_PQ_DESC
_VALID
Node i valid TX priority
queue descriptors in local
memory
2181CH+
i*2000H
PNi, 32
BE
Kernel Reset
4379
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4308
v1.1
2025-06-26


Table 1067
(continued) Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_CRC_CTRL
Node i CRC control register
21880H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4379
Ni_CRC_REG
Node i CRC register
21884H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4380
Ni_ENDN
Node i endianness test
register
21900H+i
*2000H
PNi, 32
BE
Kernel Reset
4380
Ni_PREL
Node i PRT release
identification register
21904H+i
*2000H
PNi, 32
BE
Kernel Reset
4380
Ni_STAT
Node i PRT status register
21908H+i
*2000H
PNi, 32
BE
Kernel Reset
4381
Ni_EVNT
Node i event status flags
register
21920H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4383
Ni_LOCK
Node i unlock sequence
register
21940H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4384
Ni_CTRL
Node i control register
21944H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4385
Ni_FIMC
Node i fault injection
module control register
21948H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4386
Ni_TEST
Node i hardware test
functions register
2194CH+
i*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4386
Ni_MODE
Node i operating mode
register
21960H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4388
Ni_NBTP
Node i arbitration phase
nominal bit timing register
21964H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4389
Ni_DBTP
Node i CAN FD data phase
bit timing register
21968H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4390
Ni_XBTP
Node i CAN XL data phase
bit timing register
2196CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4391
Ni_PCFG
Node i PWME configuration
register
21970H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4392
Ni_FUNC_RAW
Node i functional raw event
status register
21A00H+
i*2000H
PNi, 32
BE
Kernel Reset
4393
Ni_ERR_RAW
Node i error raw event
status register
21A04H+
i*2000H
PNi, 32
BE
Kernel Reset
4395
Ni_SAFETY_RAW
Node i safety raw event
status register
21A08H+
i*2000H
PNi, 32
BE
Kernel Reset
4397
Ni_FUNC_CLR
Node i functional raw event
clear register
21A10H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4400
Ni_ERR_CLR
Node i error raw event clear
register
21A14H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4402
Ni_SAFETY_CLR
Node i safety raw event
clear register
21A18H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4403
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4309
v1.1
2025-06-26


Table 1067
(continued) Registers overview - CANXL (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_FUNC_ENA
Node i functional raw event
enable register
21A20H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4405
Ni_ERR_ENA
Node i error raw event
enable register
21A24H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4407
Ni_SAFETY_ENA
Node i safety raw event
enable register
21A28H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4409
Ni_CAPTURING_
MODE
Node i IRC configuration
register
21A30H+
i*2000H
PNi, 32
BE
Kernel Reset
4411
Ni_HDP
Node i hardware debug
port control register
21A40H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4411
22.9.3
Module Identification Register
ID
Offset address:
00000H
Module Identification Register
PowerOn Reset value:
00B6 C001H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
MOD_NUM
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MOD_TYPE
MOD_REV
r
r
Field
Bits
Type
Description
MOD_REV
7:0
r
Module Revision
Indicates the revision number of the implementation.
MOD_TYPE
15:8
r
Module Type
This internal marker is fixed to C0H.
MOD_NUM
31:16
r
Module Number
Indicates the module identification number.
22.9.4
OCDS Control and Status Register
The OCDS Control and Status register OCS controls the debug and trace behavior by selecting suspend modes
and OTGB trigger sets. When OCDS is disabled the suspend control is ineffective.
OCS
Offset address:
00004H
OCDS Control and Status Register
Debug Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4310
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
SUSS
TA
SUS_
P
SUS
0
r
rh
w
rw
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TG_P
TGB
TGS
r
w
rw
rw
Field
Bits
Type
Description
TGS
1:0
rw
Trigger Set for OTGB0/1
00B No Trigger Set output
01B CANXL_HDP16
The HW signals defined by Ni_DEBUG_TEST_CTRL.HDP_SEL[1:0]
are selected as OTGB triggers.
10B Reserved
11B Reserved
TGB
2
rw
OTGB0/1 Bus Select
0B Trigger Set is output on OTGB0
1B Trigger Set is output on OTGB1
TG_P
3
w
TGS, TGB Write Protection
TGS and TGB are only written when TG_P is 1, otherwise unchanged.
Read as 0.
SUS
27:24
rw
OCDS Suspend Control
Controls the sensitivity to the suspend signal coming from the OCDS
Trigger Switch (OTGS)
Not listed combinations are reserved.
0H Will not suspend
1H Hard suspend.
Clock is off immediately. Do not use this mode in normal CAN or
CAN XL applications, this mode is meant for debugging the
peripheral IP.
2H Soft suspend mode
Soft suspend of CAN-XL nodes. The clock is switched off after
completion of the ongoing transmission and reception events.
others, Reserved, do not use
SUS_P
28
w
SUS Write Protection
SUS is only written when SUS_P is 1, otherwise unchanged. Read as 0.
SUSSTA
29
rh
Suspend State
0B Module is not (yet) suspended
1B Module is suspended
0
23:4,
31:30
r
Reserved
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4311
v1.1
2025-06-26


Table 1068
Access mode restrictions of OCS sorted by descending priority
Mode name
Access mode
Description
write 1 to .TG_P
rw
TGB, TGS
Set TG_P during write access
write 1 to .SUS_P
rw
SUS
Set SUS_P during write access
otherwise
r
SUS, TGB, TGS
 
22.9.5
Module Clock Control Register
The Clock Control Register CLC allows the programmer to adapt the functionality and power consumption of
the module to the requirements of the application.
Register CLC controls the module clock signal and the reactivity to the sleep signal.
MODULE_CLC
Offset address:
00008H
Module Clock Control Register
Application Reset value:
0000 0003H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
EDIS
0
DISS
DISR
r
rw
r
rh
rw
Field
Bits
Type
Description
DISR
0
rw
Module Disable Request Bit
Used for enable/disable control of the module. This also includes the
Slave Interface Bridge and Master Interface Bridge
0B On request: enable the module clock
1B Off request: stop the module clock
DISS
1
rh
Module Disable Status Bit
0B Module clock is enabled
1B Off: module is not clocked
EDIS
3
rw
Sleep mode enable control
Used to control the module’s reaction to sleep mode.
0B Sleep mode request is enabled and functional
1B Module disregards the sleep mode control signal
0
2,
31:4
r
Reserved
Read as 0; should be written with 0.
22.9.6
Module reset control register A
MODULE_RST_CTRLA
Offset address:
0000CH
Module reset control register A
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4312
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
GRS
TEN3
GRS
TEN2
GRS
TEN1
GRS
TEN0
0
KRST
r
rw
rw
rw
rw
r
rw1sh
Field
Bits
Type
Description
KRST
0
rw1sh
Kernel reset
Request a kernel reset. The requested reset is executed if
MODULE_RST_CTRLA.KRST=1 and MODULE_RST_CTRLB.KRST=1.
KRST is cleared after the kernel reset was executed.
0B No action
1B A kernel reset was requested
GRSTENx
(x=0-3)
x+8
rw
Enable for global module reset group x
0B Global module reset group x does not have any effect
1B Global module reset group x results in a kernel reset
0
7:1,
31:12
r
Reserved
Read as 0; should be written with 0.
22.9.7
Module reset control register B
MODULE_RST_CTRLB
Offset address:
00010H
Module reset control register B
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
STAT
CLR
0
w
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
KRST
r
rw1sh
Field
Bits
Type
Description
KRST
0
rw1sh
Kernel reset
Request a kernel reset. The requested reset is executed if
MODULE_RST_CTRLA.KRST=1 and MODULE_RST_CTRLB.KRST=1.
KRST is cleared after the kernel reset was executed.
0B No action
1B A kernel reset was requested
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4313
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
STATCLR
31
w
Kernel reset status clear
Clears all status bits in MODULE_RST_STAT when 1 is written. Read will
return 0.
0B No action
1B Write with ´1´ clears bits MODULE_RST_STAT.GRSTx and bit
MODULE_RST_STAT.KRST .
0
30:1
r
Reserved
Read as 0; should be written with 0.
22.9.8
Module reset status register
The reset status register contains the status bits for kernel reset (KRST) and the global module reset groups
(GRSTx).
MODULE_RST_STAT
Offset address:
00014H
Module reset status register
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
GRS
T3
GRS
T2
GRS
T1
GRS
T0
0
KRST
r
rh
rh
rh
rh
r
rh
Field
Bits
Type
Description
KRST
0
rh
Kernel reset status
Indicates an executed kernel reset. MODULE_RST_STAT.KRST is set after
the execution of a kernel reset in the same clock cycle in which the
reset bits are cleared.
Clear KRST by setting bit STATCLR in register MODULE_RST_CTRLB.
GRSTx (x=0-3)
x+8
rh
Status for global module reset group x
0B Reset was not triggered by global reset group x
1B Reset was triggered by global reset group x
0
7:1,
31:12
r
Reserved
Read as 0.
22.9.9
Module Write access enable register A
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
MODULE_ACCEN_WRA
Offset address:
00018H
Module Write access enable register A
Application Reset value:
1000 0003H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4314
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
EN31 EN30 EN29 EN28 EN27 EN26 EN25 EN24 EN23 EN22 EN21 EN20 EN19 EN18 EN17 EN16
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
EN15 EN14 EN13 EN12 EN11 EN10 EN09 EN08 EN07 EN06 EN05 EN04 EN03 EN02 EN01 EN00
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=00-31)
q
rw
Write access enable for TAG-ID q
This bit enables write access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for write access
1B Enabled for write access
22.9.10
Module Write access enable register B
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
MODULE_ACCEN_WRB
Offset address:
0001CH
Module Write access enable register B
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=32-39)
q-32
rw
Write access enable for TAG-ID q
This bit enables write access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for write access
1B Enabled for write access
0
31:8
r
Reserved
Read as 0; should be written with 0.
22.9.11
Module Read access enable register A
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
MODULE_ACCEN_RDA
Offset address:
00020H
Module Read access enable register A
Application Reset value:
FFFF FFFFH
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4315
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
EN31 EN30 EN29 EN28 EN27 EN26 EN25 EN24 EN23 EN22 EN21 EN20 EN19 EN18 EN17 EN16
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
EN15 EN14 EN13 EN12 EN11 EN10 EN09 EN08 EN07 EN06 EN05 EN04 EN03 EN02 EN01 EN00
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=00-31)
q
rw
Read access enable for TAG-ID q
This bit enables read access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for read access
1B Enabled for read access
22.9.12
Module Read access enable register B
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
MODULE_ACCEN_RDB
Offset address:
00024H
Module Read access enable register B
Application Reset value:
0000 00FFH
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=32-39)
q-32
rw
Read access enable for TAG-ID q
This bit enables read access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for read access
1B Enabled for read access
0
31:8
r
Reserved
Read as 0; should be written with 0.
22.9.13
Module VM access enable register
This register defines which virtual machine encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each VMx.
MODULE_ACCEN_VM
Offset address:
00028H
Module VM access enable register
Application Reset value:
00FF 00FFH
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4316
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
WR0
7
WR0
6
WR0
5
WR0
4
WR0
3
WR0
2
WR0
1
WR0
0
r
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RD07 RD06 RD05 RD04 RD03 RD02 RD01 RD00
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
RDq (q=00-07)
q
rw
Read access enable for VM ID q
This bit enables read access to the access protected region for
transactions with the VM ID q.
0B Disabled for read access
1B Enabled for read access
WRq (q=00-07) q+16
rw
Write access enable for VM ID q
This bit enables write access to the access protected region for
transactions with the VM ID q.
0B Disabled for write access
1B Enabled for write access
0
15:8,
31:24
r
Reserved
Read as 0; should be written with 0.
22.9.14
Module PRS access enable register
This register defines which protection register set encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each PRSx.
MODULE_ACCEN_PRS
Offset address:
0002CH
Module PRS access enable register
Application Reset value:
00FF 00FFH
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
WR0
7
WR0
6
WR0
5
WR0
4
WR0
3
WR0
2
WR0
1
WR0
0
r
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RD07 RD06 RD05 RD04 RD03 RD02 RD01 RD00
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
RDq (q=00-07)
q
rw
Read access enable for PRS q
This bit enables read access to the access protected region for
transactions with the PRS q.
0B Disabled for read access
1B Enabled for read access
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4317
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
WRq (q=00-07) q+16
rw
Write access enable for PRS q
This bit enables write access to the access protected region for
transactions with the PRS q.
0B Disabled for write access
1B Enabled for write access
0
15:8,
31:24
r
Reserved
Read as 0; should be written with 0.
22.9.15
PROT Register Endinit
The resource protection register allows the definition of a specific PROT owner, and allows the PROT owner and
in some PROT states, the secure master to update the PROT state as described in the PROT mechanism.
The PROTE register controls lock / unlock of the local Endinit (E) protected control registers.
PROTE
Offset address:
00038H
PROT Register Endinit
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
OWE
N
ODE
F
TAGID
PRSE
N
PRS
VME
N
VM
w
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
SWE
N
STATE
r
w
rwh
Field
Bits
Type
Description
STATE
2:0
rwh
Resource protection state
Returns the current PROT state when read. Can be written by the PROT
owner or CS master to modify the current PROT state if the state
transition is valid in the PROT state diagram.
000B Init (unlocked state)
001B Config (unlocked state)
010B ConfigSec (unlocked state)
011B CheckSec (locked state)
100B Run (locked state)
101B RunSec (locked state)
110B RunLock (locked state)
111B RunLock (locked state)
SWEN
3
w
State write enable
Write-enable for the STATE field. Reads always return 0.
0B Disable: STATE field is not updated
1B Enable: STATE field is updated by the write
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4318
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
VM
18:16
rw
Virtual machine definition for PROT owner
Defines the VM of the PROT owner. This field is ignored if VMEN=0B or
ODEF=0B.
VMEN
19
rw
Virtual machine definition enable for PROT owner
0B Disable: VM is not part of PROT owner definition
1B Enable: VM is part of PROT owner definition
PRS
22:20
rw
Protection set definition for PROT owner
Defines the PRS of the PROT owner. This field is ignored if PRSEN=0B or
ODEF=0B.
PRSEN
23
rw
Protection set definition enable for PROT owner
0B Disable: PRS is not part of PROT owner definition
1B Enable: PRS is part of PROT owner definition
TAGID
29:24
rw
TAG-ID definition for PROT owner
Defines the TAGID of the PROT owner. This field is ignored if ODEF=0B.
ODEF
30
rw
Enable for PROT owner definition
0B Undefined: Any master can act as PROT owner (TAGID, VMEN, VM,
PRSEN, PRS are ignored)
1B Defined: TAGID, VMEN, VM, PRSEN, PRS define the PROT owner
OWEN
31
w
Owner write enable
Write-enable for the owner fields. Reads always return 0.
0B Disable: PROT owner fields (ODEF, TAGID, VMEN, VM, PRSEN, PRS)
are not updated
1B Enable: PROT owner fields (ODEF, TAGID, VMEN, VM, PRSEN, PRS)
are updated by the write
0
15:4
r
Reserved
Read as 0; should be written with 0.
Table 1069
Access mode restrictions of PROTE sorted by descending priority
Mode name
Access mode
Description
write 1 to .SWEN
rwh
STATE
 
write 1 to .OWEN
rw
ODEF, PRS, PRSEN, TAGID, VM,
VMEN
 
otherwise
r
ODEF, PRS, PRSEN, TAGID, VM,
VMEN
 
rh
STATE
22.9.16
PROT Register Safe Endinit
The resource protection register allows the definition of a specific PROT owner, and allows the PROT owner and
in some PROT states, the secure master to update the PROT state as described in the PROT mechanism.
The PROTSE register controls lock / unlock of the local Safe Endinit (SE) protected control registers.
PROTSE
Offset address:
0003CH
PROT Register Safe Endinit
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4319
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
OWE
N
ODE
F
TAGID
PRSE
N
PRS
VME
N
VM
w
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
SWE
N
STATE
r
w
rwh
Field
Bits
Type
Description
STATE
2:0
rwh
Resource protection state
Returns the current PROT state when read. Can be written by the PROT
owner or CS master to modify the current PROT state if the state
transition is valid in the PROT state diagram.
000B Init (unlocked state)
001B Config (unlocked state)
010B ConfigSec (unlocked state)
011B CheckSec (locked state)
100B Run (locked state)
101B RunSec (locked state)
110B RunLock (locked state)
111B RunLock (locked state)
SWEN
3
w
State write enable
Write-enable for the STATE field. Reads always return 0.
0B Disable: STATE field is not updated
1B Enable: STATE field is updated by the write
VM
18:16
rw
Virtual machine definition for PROT owner
Defines the VM of the PROT owner. This field is ignored if VMEN=0B or
ODEF=0B.
VMEN
19
rw
Virtual machine definition enable for PROT owner
0B Disable: VM is not part of PROT owner definition
1B Enable: VM is part of PROT owner definition
PRS
22:20
rw
Protection set definition for PROT owner
Defines the PRS of the PROT owner. This field is ignored if PRSEN=0B or
ODEF=0B.
PRSEN
23
rw
Protection set definition enable for PROT owner
0B Disable: PRS is not part of PROT owner definition
1B Enable: PRS is part of PROT owner definition
TAGID
29:24
rw
TAG-ID definition for PROT owner
Defines the TAGID of the PROT owner. This field is ignored if ODEF=0B.
ODEF
30
rw
Enable for PROT owner definition
0B Undefined: Any master can act as PROT owner (TAGID, VMEN, VM,
PRSEN, PRS are ignored)
1B Defined: TAGID, VMEN, VM, PRSEN, PRS define the PROT owner
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4320
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
OWEN
31
w
Owner write enable
Write-enable for the owner fields. Reads always return 0.
0B Disable: PROT owner fields (ODEF, TAGID, VMEN, VM, PRSEN, PRS)
are not updated
1B Enable: PROT owner fields (ODEF, TAGID, VMEN, VM, PRSEN, PRS)
are updated by the write
0
15:4
r
Reserved
Read as 0; should be written with 0.
Table 1070
Access mode restrictions of PROTSE sorted by descending priority
Mode name
Access mode
Description
write 1 to .SWEN
rwh
STATE
 
write 1 to .OWEN
rw
ODEF, PRS, PRSEN, TAGID, VM,
VMEN
 
otherwise
r
ODEF, PRS, PRSEN, TAGID, VM,
VMEN
 
rh
STATE
22.9.17
Clock enable
This register controls enable or disable of individual CAN XL node clocks.
CLKEN
Offset address:
00040H
Clock enable
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
N3_C
CS
N2_C
CS
N1_C
CS
N0_C
CS
r
rh
rh
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
N3_C
C
N2_C
C
N1_C
C
N0_C
C
r
rw
rw
rw
rw
Field
Bits
Type
Description
Ni_CC (i=0-3)
i
rw
Node i clock control
This bit-field is used to enable or disable fCANXL and fCANXLH clock of
CAN XL Node i.
0B Disable Node i clocks
1B Enable Node i clocks
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4321
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
Ni_CCS (i=0-3)
i+16
rh
Node i clock control status
This bit-field shows enable or disable status of CAN XL Node i fCANXL
and fCANXLH clock.
0B Node i clocks are disabled
1B Node i clocks are enabled
0
15:4,
31:20
r
Reserved, write 0, read as 0
22.9.18
Node i reset control register A
NODEi_RST_CTRLA (i=0-3)
Offset address:
00100H+i*100H
Node i reset control register A
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
GRS
TEN3
GRS
TEN2
GRS
TEN1
GRS
TEN0
0
KRST
r
rw
rw
rw
rw
r
rw1sh
Field
Bits
Type
Description
KRST
0
rw1sh
Kernel reset
Request a kernel reset. The requested reset is executed if
NODEi_RST_CTRLA.KRST=1 and NODEi_RST_CTRLB.KRST=1.
KRST is cleared after the kernel reset was executed.
0B No action
1B A kernel reset was requested
GRSTENx
(x=0-3)
x+8
rw
Enable for Node reset group x
Node group reset is not supported by CANXL. Software must set this bit-
field as 0.
0B Node reset group x does not have any effect
1B Node reset group x results in a kernel reset - Reserved
0
7:1,
31:12
r
Reserved
Read as 0; should be written with 0.
22.9.19
Node i reset control register B
NODEi_RST_CTRLB (i=0-3)
Offset address:
00104H+i*100H
Node i reset control register B
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4322
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
STAT
CLR
0
w
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
KRST
r
rw1sh
Field
Bits
Type
Description
KRST
0
rw1sh
Kernel reset
Request a kernel reset. The requested reset is executed if
NODEi_RST_CTRLA.KRST=1 and NODEi_RST_CTRLB.KRST=1.
KRST is cleared after the kernel reset was executed.
0B No action
1B A kernel reset was requested
STATCLR
31
w
Kernel reset status clear
Clears all status bits in NODEi_RST_STAT when 1 is written. Read will
return 0.
0B No action
1B Write with ´1´ clears bits NODEi_RST_STAT.GRSTx and bit
NODEi_RST_STAT.KRST .
0
30:1
r
Reserved
Read as 0; should be written with 0.
22.9.20
Node i reset status register
The reset status register contains the status bits for kernel reset (KRST) and the global module reset groups
(GRSTx).
NODEi_RST_STAT (i=0-3)
Offset address:
00108H+i*100H
Node i reset status register
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
GRS
T3
GRS
T2
GRS
T1
GRS
T0
0
KRST
r
rh
rh
rh
rh
r
rh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4323
v1.1
2025-06-26


Field
Bits
Type
Description
KRST
0
rh
Kernel reset status
Indicates an executed kernel reset. NODEi_RST_STAT.KRST is set after
the execution of a kernel reset in the same clock cycle in which the
reset bits are cleared.
Clear KRST by setting bit STATCLR in register NODEi_RST_CTRLB.
GRSTx (x=0-3)
x+8
rh
Status for global module reset group x
0B Reset was not triggered by global reset group x
1B Reset was triggered by global reset group x
0
7:1,
31:12
r
Reserved
Read as 0.
22.9.21
Node i write access enable register A
Per CAN XL node SFR protection.
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
NODEi_ACCENNODE_WRA (i=0-3)
Offset address:
0010CH+i*100H
Node i write access enable register A
Application Reset value:
1000 0003H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
EN31 EN30 EN29 EN28 EN27 EN26 EN25 EN24 EN23 EN22 EN21 EN20 EN19 EN18 EN17 EN16
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
EN15 EN14 EN13 EN12 EN11 EN10 EN09 EN08 EN07 EN06 EN05 EN04 EN03 EN02 EN01 EN00
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=00-31)
q
rw
Write access enable for TAG-ID q
This bit enables write access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for write access
1B Enabled for write access
22.9.22
Node i write access enable register B
Per CAN XL node SFR protection.
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
NODEi_ACCENNODE_WRB (i=0-3)
Offset address:
00110H+i*100H
Node i write access enable register B
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4324
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=32-39)
q-32
rw
Write access enable for TAG-ID q
This bit enables write access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for write access
1B Enabled for write access
0
31:8
r
Reserved
Read as 0; should be written with 0.
22.9.23
Node i read access enable register A
Per CAN XL node SFR protection.
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
NODEi_ACCENNODE_RDA (i=0-3)
Offset address:
00114H+i*100H
Node i read access enable register A
Application Reset value:
FFFF FFFFH
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
EN31 EN30 EN29 EN28 EN27 EN26 EN25 EN24 EN23 EN22 EN21 EN20 EN19 EN18 EN17 EN16
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
EN15 EN14 EN13 EN12 EN11 EN10 EN09 EN08 EN07 EN06 EN05 EN04 EN03 EN02 EN01 EN00
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=00-31)
q
rw
Read access enable for TAG-ID q
This bit enables read access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for read access
1B Enabled for read access
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4325
v1.1
2025-06-26


22.9.24
Node i read access enable register B
Per CAN XL node SFR protection.
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
NODEi_ACCENNODE_RDB (i=0-3)
Offset address:
00118H+i*100H
Node i read access enable register B
Application Reset value:
0000 00FFH
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
ENq (q=32-39)
q-32
rw
Read access enable for TAG-ID q
This bit enables read access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for read access
1B Enabled for read access
0
31:8
r
Reserved
Read as 0; should be written with 0.
22.9.25
Node i VM access enable register
Per CAN XL node SFR protection.
This register defines which virtual machine encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each VMx.
NODEi_ACCENNODE_VM (i=0-3)
Offset address:
0011CH+i*100H
Node i VM access enable register
Application Reset value:
00FF 00FFH
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
WR0
7
WR0
6
WR0
5
WR0
4
WR0
3
WR0
2
WR0
1
WR0
0
r
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RD07 RD06 RD05 RD04 RD03 RD02 RD01 RD00
r
rw
rw
rw
rw
rw
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4326
v1.1
2025-06-26


Field
Bits
Type
Description
RDq (q=00-07)
q
rw
Read access enable for VM ID q
This bit enables read access to the access protected region for
transactions with the VM ID q.
0B Disabled for read access
1B Enabled for read access
WRq (q=00-07) q+16
rw
Write access enable for VM ID q
This bit enables write access to the access protected region for
transactions with the VM ID q.
0B Disabled for write access
1B Enabled for write access
0
15:8,
31:24
r
Reserved
Read as 0; should be written with 0.
22.9.26
Node i PRS access enable register
Per CAN XL node SFR protection.
This register defines which protection register set encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each PRSx.
NODEi_ACCENNODE_PRS (i=0-3)
Offset address:
00120H+i*100H
Node i PRS access enable register
Application Reset value:
00FF 00FFH
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
WR0
7
WR0
6
WR0
5
WR0
4
WR0
3
WR0
2
WR0
1
WR0
0
r
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RD07 RD06 RD05 RD04 RD03 RD02 RD01 RD00
r
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
RDq (q=00-07)
q
rw
Read access enable for PRS q
This bit enables read access to the access protected region for
transactions with the PRS q.
0B Disabled for read access
1B Enabled for read access
WRq (q=00-07) q+16
rw
Write access enable for PRS q
This bit enables write access to the access protected region for
transactions with the PRS q.
0B Disabled for write access
1B Enabled for write access
0
15:8,
31:24
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4327
v1.1
2025-06-26


22.9.27
Node i region lower address register
Per CAN XL node SFR protection.
This register sets the lower bound of the access protected region. Addresses greater than or equal to the lower
bound are considered part of the access protected region.
NODEi_ACCENNODE_RGNLA (i=0-3)
Offset address:
00124H+i*100H
Node i region lower address register
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ADDR
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ADDR
0
rw
r
Field
Bits
Type
Description
ADDR
31:6
rw
Bits 31:6 of the lower bound of the access protected region
0
5:0
r
Reserved
Read as 0; should be written with 0.
22.9.28
Node i region upper address register
Per CAN XL node SFR protection.
This register sets the upper bound of the access protected region. Addresses stricly less than the upper bound
are considered part of the access protected region.
NODEi_ACCENNODE_RGNUA (i=0-3)
Offset address:
00128H+i*100H
Node i region upper address register
Application Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ADDR
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ADDR
0
rw
r
Field
Bits
Type
Description
ADDR
31:6
rw
Bits 31:6 of the upper bound of the access protected region
0
5:0
r
Reserved
Read as 0; should be written with 0.
22.9.29
Node i VM and PRS configuration Register
NODEi_VMPRSCONFIG (i=0-3)
Offset address:
0012CH+i*100H
Node i VM and PRS configuration Register
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4328
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
PRSE
N
PRS
VME
N
VM
r
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
r
Field
Bits
Type
Description
VM
18:16
rw
Virtual Machine
CAN-XL Node i's master interface accesses has extended VM tag ID
configured in this bit-field
VMEN
19
rw
Virtual Machine Enable
0B Disable: VM disabled
1B Enable: VM enabled
PRS
22:20
rw
Protection Set
CAN XL node i's master interface accesses with extended PRS tag ID
configured in this bit-field
PRSEN
23
rw
Protection Set Enable
0B Disable: PRS disabled
1B Enable: PRS enabled
0
15:0,
31:24
r
Reserved
Read as 0; should be written with 0.
22.9.30
Node i Port Control Register
The Node Port Control Register NODEi_PORTCTRL configures the CAN XL bus transmit/receive ports.
NODEi_PORTCTRL (i=0-3)
Offset address:
00130H+i*100H
Node i Port Control Register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RXSEL
r
rw
Field
Bits
Type
Description
RXSEL
2:0
rw
Receive Select
RXSEL selects one out of 8 possible receive inputs. The CAN XL receive
signal is performed by the selected input. (see the device related
chapter for RXSEL)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4329
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
31:3
r
Reserved
Read as 0; should be written with 0.
22.9.31
Node i message transfer interrupt event register
A flag is set when the related event is detected, independent of NODEi_MTI_ENA. The flags remain set until the
Host CPU clears them by writing a 1 to the corresponding bit position at register NODEi_MTI_CLR.
NODEi_MTI_RAW (i=0-3)
Offset address:
00134H+i*100H
Node i message transfer interrupt event register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TS_C
APT
URE
MH_
RX_F
ILTE
R_IR
Q
PRT_
RX_E
VT
PRT_
TX_E
VT
r
rh
rh
rh
rh
Field
Bits
Type
Description
PRT_TX_EVT
0
rh
PRT transmitted a valid CAN message
PRT_RX_EVT
1
rh
PRT received a valid CAN message
MH_RX_FILTER
_IRQ
2
rh
Receive filter event
In order to track RX filtering results an interrupt can be triggered when
a match is detected on any defined RX filter element
TS_CAPTURE
3
rh
Timestamp capture event
0
31:4
r
Reserved
Read as 0; should be written with 0.
22.9.32
Node i message transfer interrupt clear register
Writing a '1' to a certain bit position clears the correponding bit of register NODEi_MTI_RAW
NODEi_MTI_CLR (i=0-3)
Offset address:
00138H+i*100H
Node i message transfer interrupt clear register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4330
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TS_C
APT
URE
MH_
RX_F
ILTE
R_IR
Q
PRT_
RX_E
VT
PRT_
TX_E
VT
r
w
w
w
w
Field
Bits
Type
Description
PRT_TX_EVT
0
w
Clear PRT transmit event
Clears NODEi_MTI_RAW.PRT_TX_EVT upon writing this bit-field with 1
PRT_RX_EVT
1
w
Clear PRT receive event
Clears NODEi_MTI_RAW.PRT_RX_EVT upon writing this bit-field with 1
MH_RX_FILTER
_IRQ
2
w
Clear Receive filter event
Clears NODEi_MTI_RAW.MH_RX_FILTER_IRQ upon writing this bit-field
with 1
TS_CAPTURE
3
w
Timestamp capture event
Clears NODEi_MTI_RAW.TS_CAPTURE upon writing this bit-field with 1
0
31:4
r
Reserved
Read as 0; should be written with 0.
22.9.33
Node i message transfer interrupt enable register
Writing a '1' to a certain bit position enables the correponding bit of register NODEi_MTI_RAW
NODEi_MTI_ENA (i=0-3)
Offset address:
0013CH+i*100H
Node i message transfer interrupt enable register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TS_C
APT
URE
MH_
RX_F
ILTE
R_IR
Q
PRT_
RX_E
VT
PRT_
TX_E
VT
r
rw
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4331
v1.1
2025-06-26


Field
Bits
Type
Description
PRT_TX_EVT
0
rw
Enable PRT transmit event
Writing this bit-field with 1 enables MTI interrupt trigger on occurrence
of corresponding event in MTI SFR. Write with 0 disables the MTI
interrupt for the corresponding event.
PRT_RX_EVT
1
rw
Enable PRT receive event
Writing this bit-field with 1 enables MTI interrupt trigger on occurrence
of corresponding event in MTI SFR. Write with 0 disables the MTI
interrupt for the corresponding event.
MH_RX_FILTER
_IRQ
2
rw
Enable receive filter event
Writing this bit-field with 1 enables MTI interrupt trigger on occurrence
of corresponding event in MTI SFR. Write with 0 disables the MTI
interrupt for the corresponding event.
TS_CAPTURE
3
rw
Enable timestamp capture event
Writing this bit-field with 1 enables MTI interrupt trigger on occurrence
of corresponding event in MTI SFR. Write with 0 disables the MTI
interrupt for the corresponding event.
0
31:4
r
Reserved
Read as 0; should be written with 0.
22.9.34
Debug control register
DEBUG_CTL
Offset address:
10004H
Debug control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
NODE_SEL
r
rw
Field
Bits
Type
Description
NODE_SEL
2:0
rw
Node select
Selection for which X_CAN debug ports are connected to the single top
level ports at canxl_base for HDP[15:0], SAMPLE_POINT and
STAT_ACT[1:0].
0
31:3
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.35
Node i timestamp control
This register is used to enable timstamp counters.
Ni_TS_CTL (i=0-3)
Offset address:
20010H+i*2000H
Node i timestamp control
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4332
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ENAB
LED
0
rw
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
r
Field
Bits
Type
Description
ENABLED
31
rw
Timestamp control
When ENABLED is 0 for instance i, TS_CNT* do not increment. Setting
the bit to 1 enables incrementing. If disabling a timestamp counter, any
X_CAN instance using this counter should be idle and not actively
capturing from that timer.
0
30:0
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.36
Node i timestamp clock control
This register should be adjusted by software when Ni_TS_CTL register ENABLED bit = 0.
Ni_TS_CLOCK_CTL (i=0-3)
Offset address:
20014H+i*2000H
Node i timestamp clock control
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
PRESCALER
0
SYNC
_SEL
0
SRC_SEL
r
rw
r
rw
r
rw
Field
Bits
Type
Description
SRC_SEL
2:0
rw
Clock source select for clk_timebase generation.
000B HOST: Host clock (fCANXLH)
001B EXT_0: External 0 (STM Trigger)
010B EXT_1: External 1 (GTM Trigger)
011B EXT_2: External 2 (eGTM Trigger)
others, External 3 (Reserved)
SYNC_SEL
4
rw
Selection of external or local timebase
0B INTERNAL: Select internal timestamp counter and clock
1B EXTERNAL: Select external timestamp counter and clock
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4333
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
PRESCALER
11:8
rw
Local pre-scaler for clk_timebase generation.
0H DIV_BY_0: Divide option 0
…
FH DIV_BY_15: Divide option 15
0
3,
7:5,
31:12
r
Reserved
Read as 0; should be written with 0.
22.9.37
Node i timestamp command
Ni_TS_CMD (i=0-3)
Offset address:
20020H+i*2000H
Node i timestamp command
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TS_C
LEAR
r
w1c
Field
Bits
Type
Description
TS_CLEAR
0
w1c
Timestamp counter clear request (resets to 0).
Should be used only if Ni_TS_CTL register ENABLED bit is 0.
0
31:1
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.38
Node i timestamp counter LSBs
Ni_TS_CNT_LO (i=0-3)
Offset address:
20030H+i*2000H
Node i timestamp counter LSBs
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VALUE
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VALUE
rh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4334
v1.1
2025-06-26


Field
Bits
Type
Description
VALUE
31:0
rh
Bits [31:0] of 64 bit timestamp counter
Note that in the case of TS_PRESENT = 1:
If SYNC_SEL = INTERNAL, Ni_TS_CNT_LO is the clk_host synchronised
version of the node local timestamp counter (bits [31:0]).
If SYNC_SEL = EXTERNAL, Ni_TS_CNT_LO is the clk_host synchronised
version of the ext_ts_in external reference timestamp counter (bits
[31:0]).
22.9.39
Node i timestamp counter MSBs
Ni_TS_CNT_HI (i=0-3)
Offset address:
20034H+i*2000H
Node i timestamp counter MSBs
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VALUE
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VALUE
rh
Field
Bits
Type
Description
VALUE
31:0
rh
Bits [63:32] of timestamp counter.
Note that in the case of TS_PRESENT = 1:
If SYNC_SEL = INTERNAL, Ni_TS_CNT_HI is the clk_host synchronised
version of the node local timestamp counter (bits [63:32]).
If SYNC_SEL = EXTERNAL, Ni_TS_CNT_HI is the clk_host synchronised
version of the ext_ts_in external reference timestamp counter (bits
[63:32]).
22.9.40
Node i release identification register
This register is protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_VERSION (i=0-3)
Offset address:
21000H+i*2000H
Node i release identification register
Kernel Reset value:
0560 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
REL
STEP
SUBSTEP
YEAR
r
r
r
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MON
DAY
r
r
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4335
v1.1
2025-06-26


Field
Bits
Type
Description
DAY
7:0
r
DAY
Define the day of the release using a binary coded decimal
representation (1 being the first day of the month and so forth). This
reset value is defined by the generic parameter
DESIGN_TIME_STAMP_G[7:0]. If the generic parameter
DESIGN_TIME_STAMP_G is not set, the default value is the one defined
here
MON
15:8
r
MON
Define the month of the release using a binary coded decimal
representation (1 being January and so forth). This reset value is
defined by the generic parameter DESIGN_TIME_STAMP_G[15:8]. If the
generic parameter DESIGN_TIME_STAMP_G is not set, the default value
is the one defined here
YEAR
19:16
r
YEAR
Define the year of the release using a binary coded decimal
representation (0 being 2020 and so forth&#8230;). This reset value is
defined by the generic parameter DESIGN_TIME_STAMP_G[19:16]. If the
generic parameter DESIGN_TIME_STAMP_G is not set, the default value
is the one defined here
SUBSTEP
23:20
r
SUBSTEP
Sub-Step value according to Step.
STEP
27:24
r
STEP
Step value according to Release.
REL
31:28
r
REL
Release value, used to identify the main release of the X_CAN.
22.9.41
Node i message handler control register
Ni_MH_CTRL (i=0-3)
Offset address:
21004H+i*2000H
Node i message handler control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
STAR
T
r
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4336
v1.1
2025-06-26


Field
Bits
Type
Description
START
0
rw
START
Before starting any RX/TX FIFO Queues or TX FIFO Queue slots the MH
must write 1 to this bit prior launching the PRT. At initial start, as long
as the PRT is not started, this bit can be set back to 0. When set to 1, the
global configuration registers are write-protected. As soon as the PRT is
started, this bit cannot be set to 0. This bit can only be set to back to 0 if
Ni_MH_STS.ENABLE = 0 and Ni_MH_STS.BUSY =0. For more details on
starting/stopping or restarting the MH, refer to the Programming
Guidelines chapter.
0
31:1
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.42
Node i message handler configuration register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_MH_CFG (i=0-3)
Offset address:
21008H+i*2000H
Node i message handler configuration register
Kernel Reset value:
0000 0700H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
INST_NUM
r
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MAX_RETRANS
0
RX_C
ONT
_DC
r
rw
r
rw
Field
Bits
Type
Description
RX_CONT_DC
0
rw
RX CONT DC
When set to 1, the Continuous mode is active. This mode provides the
option to have a linear and continuous memory organization of the RX
message data. Only one RX descriptor is used by RX message data and
one single data container is required. This bit field register is only
accessible in write mode if the MH is not started, see
Ni_MH_CTRL.START = 0.
MAX_RETRANS 10:8
rw
MAX RETRANS
Maximum number of TX message re-transmissions. Different
configurations are possible: 0 -> no re-transmission; 1 to 6 -> 1 to 6 re-
transmissions; 7-> unlimited re-transmissions; This bit field register is
only accessible in write mode if the MH is not started, see
Ni_MH_CTRL.START = 0.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4337
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
INST_NUM
18:16
rw
INST NUM
In case that a cluster of X_CAN is defined, this bit field is used as a
unique identifier per instance. This identifier is used by the MH to
determine if the TX/RX descriptors are fetched by the right instance, see
RX/TX description. This bit field register is only accessible in write mode
if the MH is not started, see Ni_MH_CTRL.START = 0.
0
7:1,
15:11,
31:19
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.43
Node i message handler status register
Ni_MH_STS (i=0-3)
Offset address:
2100CH+i*2000H
Node i message handler status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
CLO
CK_A
CTIV
E
0
ENA
BLE
0
BUSY
r
rh
r
rh
r
rh
Field
Bits
Type
Description
BUSY
0
rh
BUSY
This bit is the general busy flag, it is an ORED( RX/TX FIFO Queues and
TX Priority Queue slots busy flags).
ENABLE
4
rh
ENABLE
Value of the ENABLE signal driven by the PRT. The PRT signalizes via
ENABLE whether it is active (ENABLE = 1) and requires message
handling or not (ENABLE = 0).
CLOCK_ACTIV
E
8
rh
CLOCK ACTIVE
Status of MH core clock: 0 = clock off, 1 = clock on.
0
3:1,
7:5,
31:9
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4338
v1.1
2025-06-26


22.9.44
Node i message handler safety configuration register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_MH_SFTY_CFG (i=0-3)
Offset address:
21010H+i*2000H
Node i message handler safety configuration register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
PRESCALER
PRT_TO_VAL
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MEM_TO_VAL
DMA_TO_VAL
rw
rw
Field
Bits
Type
Description
DMA_TO_VAL
7:0
rw
DMA TO VAL
This value is used by the watchdog timer for the DMA_AXI interface and
defines the maximum number of timer ticks until a read or write access
has to be completed. This value must be configured according to the
maximum system latency, expected on the DMA_AXI interface. If this
value is set to 0 and Ni_MH_SFTY_CTRL.DMA_TO_EN = 1 then the
DMA_TO_ERR interrupt is triggered right away when accessing the
S_MEM. This bit field register is only accessible in write mode if the MH
is not started, see Ni_MH_CTRL.START = 0.
MEM_TO_VAL
15:8
rw
MEM TO VAL
This value is used by the watchdog timer for the MEM_AXI interface and
defines the maximum number of timer ticks until a read or write access
has to be completed. This value must be configured to the expected
maximum latency on the MEM_AXI interface. If this value is set to 0 and
Ni_MH_SFTY_CTRL.MEM_TO_EN = 1 then the MEM_TO_ERR interrupt is
triggered right away when accessing the L_MEM. This bit field register is
only accessible in write mode if the MH is not started, see
Ni_MH_CTRL.START = 0.
PRT_TO_VAL
29:16
rw
PRT TO VAL
This value is used by the watchdog timers for the internal RX_MSG and
TX_MSG interfaces. It defines the maximum number of timer ticks until
a message has to be transferred from PRT to MH respective MH to PRT.
The value must be configured according to the CAN frame which
requires the longest time to be transported on the CAN bus. If this value
is set to 0 and Ni_MH_SFTY_CTRL.PRT_TO_EN = 1 then the DP_TO_ERR
interrupt is triggered right away at the beginning of an RX message or
when starting a TX message. This bit field register is only accessible in
write mode if the MH is not started, see Ni_MH_CTRL.START = 0.
PRESCALER
31:30
rw
PRESCALER
Prescaler used to generate the timer ticks for the watchdogs. This bit
field register is only accessible in write mode if the MH is not started,
see Ni_MH_CTRL.START = 0. According to the value a different clock
ratio can be selected: 0: clk divided by 32 1: clk divided by 64 2: clk
divided by 128 3: clk divided by 512
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4339
v1.1
2025-06-26


22.9.45
Node i message handler safety control register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_MH_SFTY_CTRL (i=0-3)
Offset address:
21014H+i*2000H
Node i message handler safety control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
PRT_
TO_E
N
MEM
_TO_
EN
DMA
_TO_
EN
DMA
_CH_
CHK
_EN
RX_A
P_PA
RITY
_EN
TX_A
P_PA
RITY
_EN
TX_D
P_PA
RITY
_EN
RX_D
P_PA
RITY
_EN
MEM
_PR
OT_E
N
RX_D
ESC_
CRC_
EN
TX_D
ESC_
CRC_
EN
r
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
TX_DESC_CRC
_EN
0
rw
TX DESC CRC EN
When set to 1, the CRC check for the TX descriptors is enabled. This bit
field register is only accessible in write mode if the MH is not started,
see Ni_MH_CTRL.START = 0.
RX_DESC_CRC
_EN
1
rw
RX DESC CRC EN
When set to 1, the CRC check for the RX descriptors is enabled. This bit
field register is only accessible in write mode if the MH is not started,
see Ni_MH_CTRL.START = 0.
MEM_PROT_E
N
2
rw
MEM PROT EN
When set to 1, the sfty_err signal from the local memory interface is
checked. This bit field register is only accessible in write mode if the MH
is not started, see Ni_MH_CTRL.START = 0.
RX_DP_PARITY
_EN
3
rw
RX DP PARITY EN
When set to 1, the data path parity check performed on the RX path is
enabled. This bit field register is only accessible in write mode if the MH
is not started, see Ni_MH_CTRL.START = 0.
TX_DP_PARITY
_EN
4
rw
TX DP PARITY EN
When set to 1, the data path parity check performed on the TX path is
enabled. This bit field register is only accessible in write mode if the MH
is not started, see Ni_MH_CTRL.START = 0.
TX_AP_PARITY
_EN
5
rw
TX AP PARITY EN
When set to 1, the address pointer parity check on the TX path is
enabled. This bit field register is only accessible in write mode if the MH
is not started, see Ni_MH_CTRL.START = 0.
RX_AP_PARITY
_EN
6
rw
RX AP PARITY EN
When set to 1, the address pointer parity check on the RX path is
enabled. This bit field register is only accessible in write mode if the MH
is not started, see Ni_MH_CTRL.START = 0.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4340
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DMA_CH_CHK
_EN
7
rw
DMA CH CHK EN
When set to 1, the read/write DMA channels routing is checked. This bit
field register is only accessible in write mode if the MH is not started,
see Ni_MH_CTRL.START = 0.
DMA_TO_EN
8
rw
DMA TO EN
When set to 1, the watchdog for the DMA_AXI interface is enabled,
otherwise disabled. This bit field register is only accessible in write
mode if the MH is not started, see Ni_MH_CTRL.START = 0.
MEM_TO_EN
9
rw
MEM TO EN
When set to 1, the watchdog for the MEM_AXI interface is enabled,
otherwise disabled. This bit field register is only accessible in write
mode if the MH is not started, see Ni_MH_CTRL.START = 0.
PRT_TO_EN
10
rw
PRT TO EN
When set to 1, the watchdogs for the internal RX_MSG and TX_MSG
interfaces are enabled, otherwise disabled. This bit field register is only
accessible in write mode if the MH is not started, see
Ni_MH_CTRL.START = 0.
0
31:11
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.46
Node i RX filter base address register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_RX_FILTER_MEM_ADD (i=0-3)
Offset address:
21018H+i*2000H
Node i RX filter base address register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
BASE_ADDR
rw
Field
Bits
Type
Description
BASE_ADDR
15:0
rw
BASE ADDR
Define the base address where the RX filter elements are defined in
L_MEM (up to 64Kbytes can be addressed). The BASE_ADDR[1:0] bits
are always assumed to be 0b00 whatever the value written. This
address value must always be word aligned (32bit). This bit field
register is only accessible in write mode if the MH is not started, see
Ni_MH_CTRL.START = 0.
0
31:16
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4341
v1.1
2025-06-26


22.9.47
Node i TX descriptor base address register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_TX_DESC_MEM_ADD (i=0-3)
Offset address:
2101CH+i*2000H
Node i TX descriptor base address register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
PQ_BASE_ADDR
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
FQ_BASE_ADDR
rw
Field
Bits
Type
Description
FQ_BASE_ADD
R
15:0
rw
FQ BASE ADDR
Define the base address where the TX FIFO Queue descriptors are
stored in L_MEM (up to 64Kbytes can be addressed). The
FQ_BASE_ADDR[1:0] bits are always assumed to be 0b00 whatever the
value written. This address value must always be word aligned (32bit).
This bit field register is only accessible in write mode if the MH is not
started, see Ni_MH_CTRL.START = 0.
PQ_BASE_ADD
R
31:16
rw
PQ BASE ADDR
Define the base address where the TX Priority Queue descriptors are
stored in L_MEM (up to 64Kbytes can be addressed). The
PQ_BASE_ADDR[1:0] bits are always assumed to be 0b00 whatever the
value written. This address value must always be word aligned (32bit).
This bit field register is only accessible in write mode if the MH is not
started, see Ni_MH_CTRL.START = 0.
22.9.48
Node i AXI address extension register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_AXI_ADD_EXT (i=0-3)
Offset address:
21020H+i*2000H
Node i AXI address extension register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4342
v1.1
2025-06-26


Field
Bits
Type
Description
VAL
31:0
rw
VAL
Define the MSB of the read/write AXI address bus used on the DMA_AXI
interface. If not required, leave the default value and do not connect
the upper part of the DMA_AXI read/write address bus. This bit field
register is only accessible in write mode if the MH is not started, see
Ni_MH_CTRL.START = 0.
22.9.49
Node i AXI parameter register
This register is only accessible in write mode if the MH is not started, see Ni_MH_CTRL.START = 0. This register is
protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_AXI_PARAMS (i=0-3)
Offset address:
21024H+i*2000H
Node i AXI parameter register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
AW_MAX_P
END
0
AR_MAX_P
END
r
rw
r
rw
Field
Bits
Type
Description
AR_MAX_PEN
D
1:0
rw
AR MAX PEND
AR_MAX_PEND[1:0] defines the maximum read pending transactions
on DMA_AXI interface: 0 -> no read transfer; 1 -> 1 outstanding read
transaction; 2 -> 2 outstanding read transactions, 3 -> 3 outstanding
read transactions. This bit field register is only accessible in write mode
if the MH is not started, see Ni_MH_CTRL.START = 0.
AW_MAX_PEN
D
5:4
rw
AW MAX PEND
AW_MAX_PEND[1:0] defines the maximum write pending transactions
on DMA_AXI interface: 0 -> no write transfer; 1 -> 1 outstanding write
transaction allowed; 2 -> 2 outstanding write transactions, 3 -> 3
outstanding write transactions. This bit field register is only accessible
in write mode if the MH is not started, see Ni_MH_CTRL.START = 0.
0
3:2,
31:6
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.50
Node i message handler lock register
Ni_MH_LOCK (i=0-3)
Offset address:
21028H+i*2000H
Node i message handler lock register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4343
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
TMK
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ULK
rw
Field
Bits
Type
Description
ULK
15:0
rw
ULK
Unlock key register. Two consecutive writes to this bit field, starting
with 0x1234 and 0x04321, must be done before writing to a register
being locked.
TMK
31:16
rw
TMK
Test mode key register. Two consecutive writes to this bit field, starting
with 0x6789 and 0x9876, must be done before writing to the
Ni_DEBUG_TEST_CTRL register.
22.9.51
Node i TX descriptor current address pointer register
Ni_TX_DESC_ADD_PT (i=0-3)
Offset address:
21100H+i*2000H
Node i TX descriptor current address pointer register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rh
Field
Bits
Type
Description
VAL
31:0
rh
VAL
Address used to fetch a TX descriptor for the TX FIFO Queues or TX
Priority Queue slots. It could be for several reasons: a new message
needs to be fetched from a TX FIFO Queue or a new message is defined
in a TX Priority Queue slot. This address value is always word aligned
(32bit).
22.9.52
Node i TX message counter register
Ni_TX_STATISTICS (i=0-3)
Offset address:
21104H+i*2000H
Node i TX message counter register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4344
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
UNSUCC
r
rwh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
SUCC
r
rwh
Field
Bits
Type
Description
SUCC
11:0
rwh
SUCC
Counter incremented with every successful transmission of a CAN
message to the CAN bus. The counter wraps automatically to 0 and can
be cleared when writing 0 to the bit field. A STATS_IRQ interrupt is
generated when the counter wraps.
UNSUCC
27:16
rwh
UNSUCC
Counter incremented with every unsuccessful transmission of a CAN
message to the CAN bus. The counter wraps automatically to 0 and can
be cleared when writing 0 to the bit field. A STATS_IRQ interrupt is
generated when the counter wraps.
0
15:12,
31:28
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.53
Node i TX FIFO queue status register (i=0-3)
Ni_TX_FQ_STS0 (i=0-3)
Offset address:
21108H+i*2000H
Node i TX FIFO queue status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
STOP
r
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
BUSY
r
rh
Field
Bits
Type
Description
BUSY
7:0
rh
BUSY
When BUSY[n] = 1 the TX FIFO Queue n is active, this means the FIFO
Queue is started and running (TX message defined in the TX FIFO Queue
n can be processed). When the BUSY[n] = 0, the TX FIFO Queue n is
stopped and would require a write to the Ni_TX_FQ_CTRL0.START[n] to
make it active again. A TX FIFO Queue can go inactive if the END bit in
the last TX descriptor of a TX message is set. In this case the, the
BUSY[n] = 0 can occur only if the TX header descriptor of this last
message has been acknowledged for the TX FIFO Queue n. When the TX
FIFO Queue n is aborted, the BUSY[n] flag is set to 0 only when no
acknowledge is pending.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4345
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
STOP
23:16
rh
STOP
When STOP[n] = 1 the TX FIFO Queue n is on hold, this means the FIFO
Queue is started and running but waits for the SW to keep going. The
STOP[n] can be set only if the BUSY[n] = 1. Several root causes may lead
to this state: an error is detected, or a TX descriptor is not valid. To
identify the potential issues, refer to the Ni_TX_FQ_STS1 register. In
order to keep going with the TX FIFO Queue n, a write to the
Ni_TX_FQ_CTRL0.START[n] is required. When BUSY[n] = 0, this bit is
automatically set to 0
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.54
Node i TX FIFO queue status register (i=0-3)
Ni_TX_FQ_STS1 (i=0-3)
Offset address:
2110CH+i*2000H
Node i TX FIFO queue status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
ERROR
r
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
UNVALID
r
rh
Field
Bits
Type
Description
UNVALID
7:0
rh
UNVALID
When UNVALID[n] = 1 the TX FIFO Queue n is on hold due to an TX
descriptor with VALID=0 was loaded.
ERROR
23:16
rh
ERROR
When ERROR[n] = 1 the TX FIFO Queue n is on hold due to an
inconsistent TX descriptor was loaded, see chapter Descriptor
Protection.
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.55
Node i TX FIFO queue control register 0
Ni_TX_FQ_CTRL0 (i=0-3)
Offset address:
21110H+i*2000H
Node i TX FIFO queue control register 0
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4346
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
START
r
rw
Field
Bits
Type
Description
START
7:0
rw
START
When writing a 1 to the START[n], the TX FIFO Queue n is started. This
bit is autocleared. Once started, the Ni_TX_FQ_STS0.BUSY[n] is set to 1.
The MH must be started prior to any TX FIFO Queue start
(Ni_MH_STS.BUSY set to 1). A TX FIFO Queue n can only be started if
Ni_TX_FQ_CTRL2.ENABLE[n] is set to 1 and in order to avoid a dead
lock situation with the PRT, the ENABLE signal from the PRT is high.
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.56
Node i TX FIFO queue control register 1
This register is only accessible in write mode if the unlock key sequence has been performed prior to write.
Ni_TX_FQ_CTRL1 (i=0-3)
Offset address:
21114H+i*2000H
Node i TX FIFO queue control register 1
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
ABORT
r
rwh
Field
Bits
Type
Description
ABORT
7:0
rwh
ABORT
When ABORT[n] is set to 1, the TX FIFO Queue n is aborted. Once set to
1, the MH will abort all pending transaction related to the TX FIFO
Queue n whenever required. This bit must be set back to 0 only when
the TX FIFO Queue n is inactive, Ni_TX_FQ_STS0.BUSY[n] = 0. This bit
field register is only accessible in write mode if the unlock key sequence
has been performed prior to write.
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4347
v1.1
2025-06-26


22.9.57
Node i TX FIFO queue control register 2
Ni_TX_FQ_CTRL2 (i=0-3)
Offset address:
21118H+i*2000H
Node i TX FIFO queue control register 2
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
ENABLE
r
rw
Field
Bits
Type
Description
ENABLE
7:0
rw
ENABLE
When ENABLE[n] is set to 1, the TX FIFO Queue n is enabled. A TX FIFO
Queue cannot be started if it is not enabled. Aborting a not started TX
FIFO Queue has no effect.
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.58
Node i TX FIFO queue r current address pointer register
Ni_TX_FQ_ADD_PTr (i=0-3;r=0-7)
Offset address:
21120H+i*2000H+r*1
0H
Node i TX FIFO queue r current address pointer register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rh
Field
Bits
Type
Description
VAL
31:0
rh
VAL
Provide the header descriptor address of the TX message being in used
by the arbiter for the TX FIFO Queue. To follow TX descriptors over time
while running TX FIFO Queues, refer to the Ni_TX_DESC_ADD_PT
register. This address value is always word aligned (32bit).
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4348
v1.1
2025-06-26


22.9.59
Node i TX FIFO queue r start address register
This register is only accessible in write mode if the TX FIFO Queue r is not busy, see BUSY flag in Ni_TX_FQ_STS0
register. This register is protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_TX_FQ_START_ADDr (i=0-3;r=0-7)
Offset address:
21124H+i*2000H+r*1
0H
Node i TX FIFO queue r start address register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
Field
Bits
Type
Description
VAL
31:0
rw
VAL
Define the start address of the TX FIFO Queue link list descriptor in the
system memory. The VAL[1:0] bits are always assumed to be 0b00
whatever the value written. This address value must always be word
aligned (32bit). This bit field register is only accessible in write mode if
the TX FIFO Queue 0 is not busy, see BUSY flag in Ni_TX_FQ_STS0
register.
22.9.60
Node i TX FIFO queue r size register
This register is only accessible in write mode if the TX FIFO Queue r is not busy, see BUSY flag in Ni_TX_FQ_STS0
register. This register is protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_TX_FQ_SIZEr (i=0-3;r=0-7)
Offset address:
21128H+i*2000H+r*1
0H
Node i TX FIFO queue r size register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MAX_DESC
r
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4349
v1.1
2025-06-26


Field
Bits
Type
Description
MAX_DESC
9:0
rw
MAX DESC
Define the maximum number of TX descriptors in the TX FIFO Queue
link list descriptors. It is important to note that MAX_DESC = 0 does not
prevent the TX FIFO Queue to be enabled and started. An active and
running TX FIFO Queue with MAX_DESC = 0 is not allowed and will
result in a DESC_ERR interrupt if no TX descriptor is defined. The
memory size to allocate is MAX_DESC * 32bytes for MAX_DESC > = 1.
This bit field register is only accessible in write mode if the TX FIFO
Queue 0 is not busy, see BUSY flag in Ni_TX_FQ_STS0 register.
0
31:10
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.61
Node i TX priority queue status register (i=0-3)
Ni_TX_PQ_STS0 (i=0-3)
Offset address:
21300H+i*2000H
Node i TX priority queue status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
BUSY
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
BUSY
rh
Field
Bits
Type
Description
BUSY
31:0
rh
BUSY
When BUSY[n] = 1, the TX Priority Queue slot n is busy, which means
that the TX descriptor in the slot n is being loaded in L_MEM and
considered by the TX-Scan. As long as this bit remains high, the
message attached to the slot n has not been sent yet. The BUSY[n] = 0
can occur only if the TX header descriptor of the slot n has been
acknowledged.
22.9.62
Node i TX priority queue status register (i=0-3)
Ni_TX_PQ_STS1 (i=0-3)
Offset address:
21304H+i*2000H
Node i TX priority queue status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
SENT
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
SENT
rh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4350
v1.1
2025-06-26


Field
Bits
Type
Description
SENT
31:0
rh
SENT
When SENT[n] = 1 the TX message assigned to the TX Priority Queue
slot n has been transmitted and the TX descriptor attached to the slot n
is acknowledged. This bit will be cleared once a new start on this slot
will occur.
22.9.63
Node i TX priority queue control register 0
Ni_TX_PQ_CTRL0 (i=0-3)
Offset address:
2130CH+i*2000H
Node i TX priority queue control register 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
START
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
START
rw
Field
Bits
Type
Description
START
31:0
rw
START
When writing a 1 to the START[n], the TX Priority Queue slot n is started
and running. This bit is autocleared and once started, the
Ni_TX_PQ_STS0.BUSY[n] is set to 1. The MH must be started prior to any
TX Priority Queue slot start (Ni_MH_STS.BUSY set to 1). A TX Priority
Queue slot n can only be started if Ni_TX_PQ_CTRL2.ENABLE[n] is set to
1 and in order to avoid a dead lock situation with the PRT, the ENABLE
signal from the PRT is high.
22.9.64
Node i TX priority queue control register 1
This register is only accessible in write mode if the unlock key sequence has been performed prior to write.
Ni_TX_PQ_CTRL1 (i=0-3)
Offset address:
21310H+i*2000H
Node i TX priority queue control register 1
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ABORT
rwh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ABORT
rwh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4351
v1.1
2025-06-26


Field
Bits
Type
Description
ABORT
31:0
rwh
ABORT
When ABORT[n] is set to 1, the TX Priority Queue slot n is aborted. This
bit must be set back to 0 only when the TX Priority Queue slot n is
inactive, Ni_TX_PQ_STS0.BUSY[n] = 0. A TX message attached to a slot
can only be aborted if it is not stored in the two internal buffers holding
the two best candidates for the next TX message. Despite a TX message
is aborted, it may have been sent, check the Ni_TX_PQ_STS1.SENT[n]
bit register for the slot n. This bit field register is only accessible in write
mode if the unlock key sequence has been performed prior to write.
22.9.65
Node i TX priority queue control register 2
Ni_TX_PQ_CTRL2 (i=0-3)
Offset address:
21314H+i*2000H
Node i TX priority queue control register 2
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ENABLE
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ENABLE
rw
Field
Bits
Type
Description
ENABLE
31:0
rw
ENABLE
When ENABLE[n] is set to 1, the slot n in the TX Priority Queue is
enabled. A TX Priority Queue slot cannot be started if not enabled.
Aborting a not started slot n has no effect
22.9.66
Node i TX priority queue start address
This register is only accessible in write mode if the TX Priority Queue is not busy, see BUSY flag in TX_PQ_STS
register. It means TX_PQ_STS register is equal to 0x0. This register is protected by a register bank CRC defined in
Ni_CRC_REG register.
Ni_TX_PQ_START_ADD (i=0-3)
Offset address:
21318H+i*2000H
Node i TX priority queue start address
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4352
v1.1
2025-06-26


Field
Bits
Type
Description
VAL
31:0
rw
VAL
Define the start address of the TX Priority Queue in the system memory.
All TX header descriptors in the TX Priority Queue are continuously
defined from this start address. The VAL[1:0] bits are always assumed to
be 0b00 whatever the value written. This address value must always be
word aligned (32bit). This bit field register is only accessible in write
mode if the TX Priority Queue is not busy, see BUSY flag in TX_PQ_STS
register
22.9.67
Node i RX descriptor current address pointer
Ni_RX_DESC_ADD_PT (i=0-3)
Offset address:
21400H+i*2000H
Node i RX descriptor current address pointer
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rh
Field
Bits
Type
Description
VAL
31:0
rh
VAL
Provide the address used to fetch the current RX descriptor. This
address value is always word aligned (32bit).
22.9.68
Node i RX message counter register
Ni_RX_STATISTICS (i=0-3)
Offset address:
21404H+i*2000H
Node i RX message counter register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
UNSUCC
r
rwh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
SUCC
r
rwh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4353
v1.1
2025-06-26


Field
Bits
Type
Description
SUCC
11:0
rwh
SUCC
Counter incremented with every successful reception of a CAN message
from the CAN bus. The counter wraps automatically to 0 and can be
cleared when writing 0x00 to the bit field. An interrupt is generated
when the counter wraps.
UNSUCC
27:16
rwh
UNSUCC
Counter incremented with every unsuccessful reception of a CAN
message from the CAN bus. The counter wraps automatically to 0 and
can be cleared when writing 0x00 to the bit field. An interrupt is
generated when the counter wraps.
0
15:12,
31:28
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.69
Node i RX FIFO queue status register 0
Ni_RX_FQ_STS0 (i=0-3)
Offset address:
21408H+i*2000H
Node i RX FIFO queue status register 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
STOP
r
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
BUSY
r
rh
Field
Bits
Type
Description
BUSY
7:0
rh
BUSY
When BUSY[n] = 1 the RX FIFO Queue n is busy, this means the FIFO
Queue is started and running (RX message to be written to the RX FIFO
Queue can be processed). When the BUSY[n] = 0, the RX FIFO Queue n is
stopped and would require a write to the Ni_RX_FQ_CTRL0.START[n] to
make it active again. When the RX FIFO Queue n is aborted, the BUSY[n]
flag is set to 0 only when no acknowledge is pending.
STOP
23:16
rh
STOP
When STOP[n] = 1 the RX FIFO Queue n is on hold, it means started but
waiting for the SW to react. The STOP[n] can be set only if the BUSY[n] =
1. Several root causes may lead to the RX FIFO Queue n to stop: an error
is detected, or an RX descriptor is not valid, or the FIFO is full. To
identify the potential issues, refer to the Ni_RX_FQ_STS1 and
Ni_RX_FQ_STS2 registers. In order to keep going with the RX FIFO
Queue n, a write to the Ni_RX_FQ_CTRL0.START[n] is required. When
BUSY[n] = 0, this bit is automatically set to 0
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4354
v1.1
2025-06-26


22.9.70
Node i RX FIFO queue status register 1
Ni_RX_FQ_STS1 (i=0-3)
Offset address:
2140CH+i*2000H
Node i RX FIFO queue status register 1
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
ERROR
r
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
UNVALID
r
rh
Field
Bits
Type
Description
UNVALID
7:0
rh
UNVALID
When UNVALID[n] = 1 the RX FIFO Queue n is on hold due to an RX
descriptor detected with VALID=0.
ERROR
23:16
rh
ERROR
When ERROR[n] = 1 the RX FIFO Queue n is on hold due to an
inconsistent RX descriptor being loaded, see chapter Descriptor
Protection.
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.71
Node i RX FIFO queue status register 2
Ni_RX_FQ_STS2 (i=0-3)
Offset address:
21410H+i*2000H
Node i RX FIFO queue status register 2
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
DC_FULL
r
rh
Field
Bits
Type
Description
DC_FULL
7:0
rh
DC FULL
When DC_FULL[n] = 1 the RX FIFO Queue n is stopped due to the RX
FIFO Queue n being full. This register is relevant only for the Continuous
Mode as in Normal mode, there is no need to provide such information
to the MH
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4355
v1.1
2025-06-26


22.9.72
Node i RX FIFO queue control register 0
Ni_RX_FQ_CTRL0 (i=0-3)
Offset address:
21414H+i*2000H
Node i RX FIFO queue control register 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
START
r
rw
Field
Bits
Type
Description
START
7:0
rw
START
When writing a 1 to the START[n], the RX FIFO Queue n is started. This
bit is autocleared and once started, the Ni_RX_FQ_STS0.BUSY[n] is set
to 1. The MH must be started prior to any RX FIFO Queue start
(Ni_MH_STS.BUSY set to 1). An RX FIFO Queue n can only be started if
Ni_RX_FQ_CTRL2.ENABLE[n] is set to 1.
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.73
Node i RX FIFO queue control register 1
This register is only accessible in write mode if the unlock key sequence has been performed prior to write.
Ni_RX_FQ_CTRL1 (i=0-3)
Offset address:
21418H+i*2000H
Node i RX FIFO queue control register 1
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
ABORT
r
rwh
Field
Bits
Type
Description
ABORT
7:0
rwh
ABORT
When ABORT[n] is set to 1, the RX FIFO Queue n is aborted. Once set to
1, the MH will abort all pending transactions related to the RX FIFO
Queue n whenever required. The abort can be effective only if the RX
FIFO Queue n is enabled. This bit must be set back to 0 only when the
RX FIFO Queue n is inactive, Ni_RX_FQ_STS0.BUSY[n] = 0. This bit field
register is only accessible in write mode if the unlock key sequence has
been performed prior to write.
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4356
v1.1
2025-06-26


22.9.74
Node i RX FIFO queue control register 2
Ni_RX_FQ_CTRL2 (i=0-3)
Offset address:
2141CH+i*2000H
Node i RX FIFO queue control register 2
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
ENABLE
r
rw
Field
Bits
Type
Description
ENABLE
7:0
rw
ENABLE
When ENABLE[n] is set to 1, the RX FIFO Queue n is enabled. The RX
FIFO Queue n cannot be started if not enabled. The abort of an RX FIFO
Queue n not started would have no effect.
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.75
Node i RX FIFO queue s current address pointer
Ni_RX_FQ_ADD_PTs (i=0-3;s=0-7)
Offset address:
21420H+i*2000H+s*1
8H
Node i RX FIFO queue s current address pointer
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rh
Field
Bits
Type
Description
VAL
31:0
rh
VAL
Provide the current RX Header Descriptor address pointer for the RX
FIFO Queue 0 in the system memory. To follow RX descriptor over time,
refer to the Ni_RX_DESC_ADD_PT register. This address value is always
word aligned (32bit).
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4357
v1.1
2025-06-26


22.9.76
Node i RX FIFO queue s link list start address
This register is only accessible in write mode if the RX FIFO Queue is not busy, see BUSY flag in Ni_RX_FQ_STS0
register. This register is protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_RX_FQ_START_ADDs (i=0-3;s=0-7)
Offset address:
21424H+i*2000H+s*1
8H
Node i RX FIFO queue s link list start address
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
Field
Bits
Type
Description
VAL
31:0
rw
VAL
Define the start address of the RX FIFO Queue link list descriptor in
system memory. The VAL[1:0] bits are always assumed to be 0b00
whatever the value written. This address value must always be word
aligned (32bit). This register is only accessible in write mode if the RX
FIFO Queue 0 is not busy, see BUSY flag in Ni_RX_FQ_STS0 register
22.9.77
Node i RX FIFO queue s link list and data container size
This register is only accessible in write mode if the RX FIFO Queue is not busy, see BUSY flag in Ni_RX_FQ_STS0
register. This register is protected by a register bank CRC defined in Ni_CRC_REG register.
Ni_RX_FQ_SIZEs (i=0-3;s=0-7)
Offset address:
21428H+i*2000H+s*1
8H
Node i RX FIFO queue s link list and data container size
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
DC_SIZE
r
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MAX_DESC
r
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4358
v1.1
2025-06-26


Field
Bits
Type
Description
MAX_DESC
9:0
rw
MAX DESC
Define the maximum number of descriptors in the RX FIFO Queue link
list. It is important to note that MAX_DESC = 0 does not prevent the RX
FIFO Queue to be enabled and started. An active and running RX FIFO
Queue with MAX_DESC = 0 is not allowed and will result in a DESC_ERR
interrupt if no RX descriptor is defined. The size to be allocated to the
link list must be equal to MAX_DESC * 16bytes for MAX_DESC >= 1. This
register is only accessible in write mode if the RX FIFO Queue 0 is not
busy, see BUSY flag in Ni_RX_FQ_STS0 register
DC_SIZE
27:16
rw
DC SIZE
In Normal mode only the DC_SIZE[6:0] is used to define the maximum
size of an RX data container for the RX FIFO Queue. The data container
size is DC_SIZE[6:0] * 32bytes and one is attached to every RX
descriptor. In continuous mode, it defines the size of the single data
container used to write all RX messages. The overall data container size
is DC_SIZE[11:0] * 32bytes for MAX_DESC > = 1. When set to 0, the RX
FIFO Queue can be enabled but not started. This register is only
accessible in write mode if the RX FIFO Queue 0 is not busy, see BUSY
flag in Ni_RX_FQ_STS0 register
0
15:10,
31:28
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.78
Node i RX FIFO queue s data container start address
This register is accessible in write mode if the RX FIFO Queue is not busy, see BUSY flag in Ni_RX_FQ_STS0
register. This register is protected by a register bank CRC defined in Ni_CRC_REG register. This register is used
only in Continuous Mode
Ni_RX_FQ_DC_START_ADDs (i=0-3;s=0-7)
Offset address:
2142CH+i*2000H+s*1
8H
Node i RX FIFO queue s data container start address
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
Field
Bits
Type
Description
VAL
31:0
rw
VAL
Define the Data Container Start Address in system memory. This bit
field is relevant only when the MH is configured in Continuous Mode.
The VAL[1:0] bits are always assumed to be 0b00 whatever the value
written. This address value must always be word aligned (32bit). This
register is only accessible in write mode if the RX FIFO Queue 0 is not
busy, see BUSY flag in Ni_RX_FQ_STS0 register
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4359
v1.1
2025-06-26


22.9.79
Node i RX FIFO queue s read address pointer
This register is used only in Continuous Mode.
Ni_RX_FQ_RD_ADD_PTs (i=0-3;s=0-7)
Offset address:
21430H+i*2000H+s*1
8H
Node i RX FIFO queue s read address pointer
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
Field
Bits
Type
Description
VAL
31:0
rw
VAL
The SW uses this register to indicate the Data Read Address of the RX
message being read to the MH. This address must point to the last word
of the RX message considered in the data container. This bit field is
relevant only when the MH is configured in Continuous mode. The MH
uses this information to ensure that enough memory space is available
to write the next message. For an initial start, it is mandatory to set
VAL[1:0] to 0b11, to avoid Ni_RX_FQ_RD_ADD_PT0 register to be equal
to the Ni_RX_FQ_START_ADDR0 registers. Excepted for the initial value,
the address value must always be word aligned (32bit), VAL[1:0] must
be set to 0b00.
22.9.80
Node i TX filter control register 0
This register is only accessible in write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register. The
register is accessible in write access in privileged mode only. This register is protected by a register bank CRC
defined in Ni_CRC_REG register.
Ni_TX_FILTER_CTRL0 (i=0-3)
Offset address:
21600H+i*2000H
Node i TX filter control register 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
IRQ_
EN
EN
CC_C
AN
CAN_
FD
MOD
E
r
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MASK
COMB
rw
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4360
v1.1
2025-06-26


Field
Bits
Type
Description
COMB
7:0
rw
COMB
When COMB[n] =1 the comparison attached to the reference values
(REF_VAL0 and REF_VAL1) or (REF_VAL2 and REF_VAL3) are required to
accept a TX message. This bit field register is only accessible in write
mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
MASK
15:8
rw
MASK
When MASK[n] =1 the reference values REF_VAL0/1 or REF_VAL2/3 are
combined to define a value (REF_VAL0 or REF_VAL2) and a mask
(REF_VAL1 or REF_VAL3). Otherwise, the comparison uses the
REF_VAL0/1/2/3 bit field as reference value only. This bit field register is
only accessible in write mode if the MH is not busy, see BUSY flag in
Ni_MH_STS register
MODE
16
rw
MODE
When set to 1 accept on match, otherwise reject on match. This bit field
register is only accessible in write mode if the MH is not busy, see BUSY
flag in Ni_MH_STS register
CAN_FD
17
rw
CAN FD
When set to 1 reject CAN-FD messages, otherwise accept them. This bit
field register is only accessible in write mode if the MH is not busy, see
BUSY flag in Ni_MH_STS register
CC_CAN
18
rw
CC CAN
When set to 1 reject Classic CAN messages, otherwise accept them. This
bit field register is only accessible in write mode if the MH is not busy,
see BUSY flag in Ni_MH_STS register
EN
19
rw
EN
When set to 1, enable the TX filter for all TX message to be sent. This bit
field register is only accessible in write mode if the MH is not busy, see
BUSY flag in Ni_MH_STS register
IRQ_EN
20
rw
IRQ EN
When set to 1, enable the interrupt tx_filter_irq to be triggered. The
interrupt is triggered when a message is rejected. This bit field register
is only accessible in write mode if the MH is not busy, see BUSY flag in
Ni_MH_STS register
0
31:21
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.81
Node i TX filter control register 1
This register is only accessible in write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register. The
register is accessible in write access in privileged mode only. This register is protected by a register bank CRC
defined in Ni_CRC_REG register.
Ni_TX_FILTER_CTRL1 (i=0-3)
Offset address:
21604H+i*2000H
Node i TX filter control register 1
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4361
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
FIELD
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VALID
rw
Field
Bits
Type
Description
VALID
15:0
rw
VALID
When VALID[n] = 1 the reference value defined for the TX filter n is valid.
This bit field register is only accessible in write mode if the MH is not
busy, see BUSY flag in Ni_MH_STS register. The valid reference value
used is defined as follow: VALID[n] is assigned to
Ni_TX_FILTER_REFVAL0.REF_VAL{n} (n &#8364; {0, 1, 2, 3}) VALID[n+4] is
assigned to Ni_TX_FILTER_REFVAL1.REF_VAL{n} (n &#8364; {0, 1, 2, 3})
VALID[n+8] is assigned to Ni_TX_FILTER_REFVAL2.REF_VAL{n} (n
&#8364; {0, 1, 2, 3}) VALID[n+12] is assigned to
Ni_TX_FILTER_REFVAL3.REF_VAL{n} (n &#8364; {0, 1, 2, 3})
FIELD
31:16
rw
FIELD
When FIELD[n] = 1 the TX filter element n is considering SDT, otherwise
VCID, to compare with the reference value defined in
Ni_TX_FILTER_REFVAL0/1/2/3. This bit field register is only accessible in
write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register.
The reference value to be set is defined as follow: FIELD[n] is assigned
to Ni_TX_FILTER_REFVAL0.REF_VAL{n} (n &#8364; {0, 1, 2, 3}) FIELD[n+4]
is assigned to Ni_TX_FILTER_REFVAL1.REF_VAL{n} (n &#8364; {0, 1, 2, 3})
FIELD[n+8] is assigned to Ni_TX_FILTER_REFVAL2.REF_VAL{n} (n
&#8364; {0, 1, 2, 3}) FIELD[n+12] is assigned to
Ni_TX_FILTER_REFVAL3.REF_VAL{n} (n &#8364; {0, 1, 2, 3})
22.9.82
Node i TX filter reference value register t
This register is only accessible in write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register. The
register is accessible in write access in privileged mode only. This register is protected by a register bank CRC
defined in Ni_CRC_REG register.
Ni_TX_FILTER_REFVALt (i=0-3;t=0-3)
Offset address:
21608H+i*2000H+t*4
Node i TX filter reference value register t
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
REF_VAL3
REF_VAL2
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
REF_VAL1
REF_VAL0
rw
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4362
v1.1
2025-06-26


Field
Bits
Type
Description
REF_VAL0
7:0
rw
REF VAL0
Define the reference value 0. This bit field register is only accessible in
write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
REF_VAL1
15:8
rw
REF VAL1
Define the reference value 1. This bit field register is only accessible in
write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
REF_VAL2
23:16
rw
REF VAL2
Define the reference value 2. This bit field register is only accessible in
write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
REF_VAL3
31:24
rw
REF VAL3
Define the reference value 3. This bit field register is only accessible in
write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
22.9.83
Node i RX filter control register
This register is only accessible in write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register. The
register is accessible in write access in privileged mode only. This register is protected by a register bank CRC
defined in Ni_CRC_REG register.
Ni_RX_FILTER_CTRL (i=0-3)
Offset address:
21680H+i*2000H
Node i RX filter control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
ANFF ANM
F
0
ANMF_FQ
r
rw
rw
r
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
THRESHOLD
NB_FE
r
rw
rw
Field
Bits
Type
Description
NB_FE
7:0
rw
NB FE
Define the number of RX filter elements that are defined in the local
memory. When set to 0, all RX messages are accepted and stored in the
RX FIFO Queue number defined by ANMF_FQ[3:0]. This bit field register
is only accessible in write mode if the MH is not busy, see BUSY flag in
Ni_MH_STS register
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4363
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
THRESHOLD
12:8
rw
THRESHOLD
THRESHOLD defines the latest point in time to wait for the result of the
RX filtering process., Once this limit is reached, the MH starts fetching
an RX descriptor from S_MEM. THRESHOLD value is only used when
greater than 0 and ANFF bit set to 1. See chapter "RX Filter" for an
explanation how to configure THRESHOLD. When the RX filtering is not
providing the result before the threshold of the RX DMA FIFO is reached,
the RX message is sent to the default RX FIFO Queue mentioned in the
ANMF_FQ[2:0] (only enabled when ANFF set to 1). When the level is over
the threshold and the RX filtering result is already known, no action is
taken. Threshold is given in number of word of 32bit. This bit field
register is only accessible in write mode if the MH is not busy, see BUSY
flag in Ni_MH_STS register
ANMF_FQ
18:16
rw
ANMF FQ
Define the default RX FIFO Queue number (from 0 to 7) when non
matching frames are accepted (ANMF = 1) AND/OR when the threshold
mechanism is active (ANFF = 1). This bit field register is only accessible
in write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
ANMF
20
rw
ANMF
When set to 1, non matching frames are accepted, otherwise rejected. It
is mandatory to have the default RX FIFO Queue defined in the
ANMF_FQ[2:0] bit field, enabled and started (see Ni_RX_FQ_CTRL2 and
Ni_RX_FQ_CTRL0 registers). This bit field register is only accessible in
write mode if the MH is not busy, see BUSY flag in Ni_MH_STS register
ANFF
21
rw
ANFF
When set to 1, frames not filtered in time and over the DMA RX FIFO
level defined in THRESHOLD[4:0], are routed to the default RX FIFO
Queue (defined by the ANMF_FQ[2:0] bit field). It is mandatory to have
the default RX FIFO Queue defined in the ANMF_FQ[2:0] bit field,
enabled and started (see Ni_RX_FQ_CTRL2 and Ni_RX_FQ_CTRL0
registers). This bit field register is only accessible in write mode if the
MH is not busy, see BUSY flag in Ni_MH_STS register
0
15:13,
19,
31:22
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.84
Node i TX FIFO queue interrupt status register
Ni_TX_FQ_INT_STS (i=0-3)
Offset address:
21700H+i*2000H
Node i TX FIFO queue interrupt status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
UNVALID
r
rw1ch
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
SENT
r
rw1ch
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4364
v1.1
2025-06-26


Field
Bits
Type
Description
SENT
7:0
rw1ch
SENT
When SENT[n] = 1, a TX message was sent from the TX FIFO Queue n
and writing a 1 clears the bit.
UNVALID
23:16
rw1ch
UNVALID
When TX FIFO Queue n loads a TX descriptor with VALID = 0, the bit
UNVALID[n] will be set. Writing 1 to UNVALID[n] clears the bit.
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.85
Node i RX FIFO queue interrupt status register
Ni_RX_FQ_INT_STS (i=0-3)
Offset address:
21704H+i*2000H
Node i RX FIFO queue interrupt status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
UNVALID
r
rwh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RECEIVED
r
rw1ch
Field
Bits
Type
Description
RECEIVED
7:0
rw1ch
RECEIVED
When RECEIVED[n] = 1, an RX message was received in the RX FIFO
Queue n, writing a 1 clears the bit.
UNVALID
23:16
rwh
UNVALID
When RX FIFO Queue n loads an RX descriptor with VALID=0, the bit
UNVALID[n] will be set. Writing 1 to UNVALID[n] clears the bit.
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.86
Node i TX priority queue interrupt status register 0
Ni_TX_PQ_INT_STS0 (i=0-3)
Offset address:
21708H+i*2000H
Node i TX priority queue interrupt status register 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
SENT
rw1ch
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
SENT
rw1ch
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4365
v1.1
2025-06-26


Field
Bits
Type
Description
SENT
31:0
rw1ch
SENT
When SENT[n] = 1 TX message was sent from the TX Priority Queue slot
n, writing a 1 clears the bit.
22.9.87
Node i TX priority queue interrupt status register 1
Ni_TX_PQ_INT_STS1 (i=0-3)
Offset address:
2170CH+i*2000H
Node i TX priority queue interrupt status register 1
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
UNVALID
rw1ch
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
UNVALID
rw1ch
Field
Bits
Type
Description
UNVALID
31:0
rw1ch
UNVALID
When UNVALID[n] = 1, an invalid RX descriptor is detected while
running the TX Priority Queue slot n. Writing a 1 clears the bit. When set
to 1, the TX Priority Queue slot n is on hold, waiting for the SW to react.
As the TX message is fully defined in system memory before starting the
relevant slot, there should not be any invalid TX descriptor interrupts
22.9.88
Node i statistics interrupt status register
Ni_STATS_INT_STS (i=0-3)
Offset address:
21710H+i*2000H
Node i statistics interrupt status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
RX_
UNS
UCC
RX_S
UCC
TX_U
NSU
CC
TX_S
UCC
r
rw1ch
rw1ch
rw1ch
rw1ch
Field
Bits
Type
Description
TX_SUCC
0
rw1ch
TX SUCC
Counter of TX message transmitted successfully has wrapped, writing a
1 clears the bit.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4366
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TX_UNSUCC
1
rw1ch
TX UNSUCC
Counter of TX message transmitted unsuccessfully has wrapped,
writing a 1 clears the bit.
RX_SUCC
2
rw1ch
RX SUCC
Counter of RX message received successfully has wrapped, writing a 1
clears the bit.
RX_UNSUCC
3
rw1ch
RX UNSUCC
Counter of RX message received unsuccessfully has wrapped, writing a
1 clears the bit.
0
31:4
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.89
Node i error interrupt status register
Ni_ERR_INT_STS (i=0-3)
Offset address:
21714H+i*2000H
Node i error interrupt status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
DP_
RX_S
EQ_E
RR
DP_T
X_SE
Q_E
RR
DP_
RX_A
CK_
DO_
ERR
DP_
RX_F
IFO_
DO_
ERR
DP_T
X_AC
K_D
O_E
RR
r
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
Field
Bits
Type
Description
DP_TX_ACK_D
O_ERR
0
rw1ch
DP TX ACK DO ERR
When set to 1, a TX acknowledge data overflow is detected, writing a 1
clears the bit.
DP_RX_FIFO_
DO_ERR
1
rw1ch
DP RX FIFO DO ERR
When set to 1, an RX DMA FIFO overflow issue is detected, writing a 1
clears the bit.
DP_RX_ACK_D
O_ERR
2
rw1ch
DP RX ACK DO ERR
When set to 1, an RX acknowledge data overflow is detected, writing a 1
clears the bit.
DP_TX_SEQ_E
RR
3
rw1ch
DP TX SEQ ERR
When set to 1, a TX sequence issue is detected, writing a 1 clears the bit.
DP_RX_SEQ_E
RR
4
rw1ch
DP RX SEQ ERR
When set to 1, an RX sequence issue is detected, writing a 1 clears the
bit.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4367
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
31:5
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.90
Node i safety interrupt status register
Ni_SFTY_INT_STS (i=0-3)
Offset address:
21718H+i*2000H
Node i safety interrupt status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
ACK_
RX_P
ARIT
Y_ER
R
ACK_
TX_P
ARIT
Y_ER
R
r
rw1ch
rw1ch
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MEM_
SFTY
_CE
MEM
_SFT
Y_UE
RX_D
ESC_
CRC_
ERR
RX_D
ESC_
REQ
_ERR
TX_D
ESC_
CRC_
ERR
TX_D
ESC_
REQ
_ERR
AP_R
X_PA
RITY
_ERR
AP_T
X_PA
RITY
_ERR
DP_
RX_P
ARIT
Y_ER
R
DP_T
X_PA
RITY
_ERR
MEM
_AXI
_RD_
TO_E
RR
MEM
_AXI
_WR
_TO_
ERR
DP_
PRT_
RX_T
O_E
RR
DP_
PRT_
TX_T
O_E
RR
DMA
_AXI
_RD_
TO_E
RR
DMA
_AXI
_WR
_TO_
ERR
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
Field
Bits
Type
Description
DMA_AXI_WR_
TO_ERR
0
rw1ch
DMA AXI WR TO ERR
When set to 1, an AXI write access timeout issue is detected on DMA
interface, writing a 1 clears the bit.
DMA_AXI_RD_
TO_ERR
1
rw1ch
DMA AXI RD TO ERR
When set to 1, an AXI read access timeout issue is detected on DMA
interface, writing a 1 clears the bit.
DP_PRT_TX_T
O_ERR
2
rw1ch
DP PRT TX TO ERR
When set to 1, a TX_MSG timeout issue is detected, writing a 1 clears
the bit.
DP_PRT_RX_T
O_ERR
3
rw1ch
DP PRT RX TO ERR
When set to 1, an RX_MSG timeout issue is detected, writing a 1 clears
the bit.
MEM_AXI_WR_
TO_ERR
4
rw1ch
MEM AXI WR TO ERR
When set to 1, an AXI write access timeout issue is detected on local
memory interface, writing a 1 clears the bit.
MEM_AXI_RD_
TO_ERR
5
rw1ch
MEM AXI RD TO ERR
When set to 1, an AXI read access timeout issue is detected on local
memory interface, writing a 1 clears the bit.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4368
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DP_TX_PARITY
_ERR
6
rw1ch
DP TX PARITY ERR
When set to 1, a TX data parity error is detected on datapath, writing a 1
clears the bit.
DP_RX_PARITY
_ERR
7
rw1ch
DP RX PARITY ERR
When set to 1, an RX data parity error is detected on datapath, writing a
1 clears the bit.
AP_TX_PARITY
_ERR
8
rw1ch
AP TX PARITY ERR
When set to 1, a TX address pointer parity issue is detected, writing a 1
clears the bit.
AP_RX_PARITY
_ERR
9
rw1ch
AP RX PARITY ERR
When set to 1, an RX address pointer parity issue is detected, writing a 1
clears the bit.
TX_DESC_REQ
_ERR
10
rw1ch
TX DESC REQ ERR
When set to 1, a TX descriptor fetched does not match the one
expected, writing a 1 clears the bit.
TX_DESC_CRC
_ERR
11
rw1ch
TX DESC CRC ERR
When set to 1, a TX descriptor has a wrong CRC, writing a 1 clears the
bit.
RX_DESC_REQ
_ERR
12
rw1ch
RX DESC REQ ERR
When set to 1, an RX descriptor fetched does not match the one
expected, writing a 1 clears the bit.
RX_DESC_CRC
_ERR
13
rw1ch
RX DESC CRC ERR
When set to 1, an RX descriptor has a wrong CRC, writing a 1 clears the
bit.
MEM_SFTY_UE 14
rw1ch
MEM SFTY UE
When set to 1, an uncorrectable error is detected on the local memory
interface, writing a 1 clears the bit.
MEM_SFTY_CE 15
rw1ch
MEM SFTY CE
When set to 1, a correctable error is detected on the local memory
interface, writing a 1 clears the bit.
ACK_TX_PARIT
Y_ERR
16
rw1ch
ACK TX PARITY ERR
When set to 1, an acknowledge data parity issue is detected on the TX
path, writing a 1 clears the bit.
ACK_RX_PARIT
Y_ERR
17
rw1ch
ACK RX PARITY ERR
When set to 1, an acknowledge data parity issue is detected on the RX
path, writing a 1 clears the bit.
0
31:18
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.91
Node i DMA error information
Ni_AXI_ERR_INFO (i=0-3)
Offset address:
2171CH+i*2000H
Node i DMA error information
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4369
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MEM_RESP
MEM_ID
DMA_RESP
DMA_ID
r
rh
rh
rh
rh
Field
Bits
Type
Description
DMA_ID
1:0
rh
DMA ID
On DMA_AXI interface. Define the AXI ID used when a write or read error
response is detected. According to the value, the DMA channel can be
identified and so it is possible to define what's the effect of such issue.
DMA_RESP
3:2
rh
DMA RESP
On DMA_AXI interface. When set to 0b10, the AXI response is SLVERR.
When set to 0b11, the response is DECERR. By default, set to 0b00
(OKAY)
MEM_ID
5:4
rh
MEM ID
On MEM_AXI interface. Define the AXI ID used when a write or read error
response is detected. According to the value, the DMA channel can be
identified and so it is possible to define what's the effect of such issue.
MEM_RESP
7:6
rh
MEM RESP
On MEM_AXI interface. When set to 0b10, the AXI response is SLVERR.
When set to 0b11, the response is DECERR. By default, set to 0b00
(OKAY)
0
31:8
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.92
Node i descriptor error information 0
If the Ni_DESC_ERR_INFO0.ADD[31:16] = 0 and Ni_DESC_ERR_INFO1.CRC[8:0], Ni_DESC_ERR_INFO1.RX_TX and
Ni_DESC_ERR_INFO1.RC[4:0] are all equal to 0, the faulty descriptor is a TX descriptor fetched from L_MEM.
Ni_DESC_ERR_INFO0 (i=0-3)
Offset address:
21720H+i*2000H
Node i descriptor error information 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ADD
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ADD
rh
Field
Bits
Type
Description
ADD
31:0
rh
ADD
Descriptor address being used when the error is detected.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4370
v1.1
2025-06-26


22.9.93
Node i descriptor error information 1
When the Ni_DESC_ERR_INFO1.CRC[8:0], Ni_DESC_ERR_INFO1.RX_TX and Ni_DESC_ERR_INFO1.RC[4:0] are all
equal to 0, the faulty descriptor is a TX descriptor fetched from L_MEM only if the
Ni_DESC_ERR_INFO0.ADD[31:16] = 0.
Ni_DESC_ERR_INFO1 (i=0-3)
Offset address:
21724H+i*2000H
Node i descriptor error information 1
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
CRC
r
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
RX_T
X
0
RC
PQ
IN
FQN_PQSN
rh
r
rh
rh
rh
rh
Field
Bits
Type
Description
FQN_PQSN
4:0
rh
FQN PQSN
Provide the information regarding the RX/TX FIFO Queue number or the
TX Priority Queue slot having an issue.
IN
7:5
rh
IN
Provide the instance number defined in RX or TX descriptor logged in.
PQ
8
rh
PQ
Identify which TX queue is impacted, either the TX Priority Queue (PQ
set to 1) or the TX FIFO Queues.
RC
13:9
rh
RC
Provide the information regarding the Rolling Counter defined in RX or
TX descriptor impacted.
RX_TX
15
rh
RX TX
RX descriptor has an issue (RX_TX set to 1), otherwise the same for a TX
descriptor.
CRC
24:16
rh
CRC
CRC value defined in the RX or TX descriptor logged in.
0
14,
31:25
r
Reserved
Read as 0; should be written with 0.
22.9.94
Node i TX filter error information
Ni_TX_FILTER_ERR_INFO (i=0-3)
Offset address:
21728H+i*2000H
Node i TX filter error information
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4371
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
FQN_PQS
FQ
r
rh
rh
Field
Bits
Type
Description
FQ
0
rh
FQ
When set to 1, one of the TX FIFO Queues has triggered the
TX_FILTER_ERR interrupt, otherwise it is a TX Priority Queue slot.
FQN_PQS
5:1
rh
FQN PQS
Provide the information of the TX FIFO Queue number or TX Priority
Queue slot number which has triggered the TX_FILTER_ERR interrupt.
0
31:6
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.95
Node i debug control register
This register is only accessible in write mode if the Test Mode Key sequence has been performed prior to write.
The register is accessible in write access in privileged mode only. This register is protected by a register bank
CRC defined in Ni_CRC_REG register.
Ni_DEBUG_TEST_CTRL (i=0-3)
Offset address:
21800H+i*2000H
Node i debug control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
HDP_SEL
0
HDP
_EN
TEST
_IRQ
_EN
r
rw
r
rw
rw
Field
Bits
Type
Description
TEST_IRQ_EN
0
rw
TEST IRQ EN
When writing 1, enable the control of the interrupt lines using the
Ni_INT_TEST0 and Ni_INT_TEST1 registers. This bit field register is only
accessible in write mode if the Test Mode Key sequence has been
performed prior to write.
HDP_EN
1
rw
HDP EN
When writing 1, enable the hardware debug port to monitor MH
internal signals. This bit field register is only accessible in write mode if
the Test Mode Key sequence has been performed prior to write.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4372
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
HDP_SEL
10:8
rw
HDP SEL
Define the set of signals to be monitored on the HDP[15:0] bus signal
interface. This bit field register is only accessible in write mode if the
Test Mode Key sequence has been performed prior to write.
0
7:2,
31:11
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.96
Node i interrupt test register 0
This register is only accessible in write mode if the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set.
Ni_INT_TEST0 (i=0-3)
Offset address:
21804H+i*2000H
Node i interrupt test register 0
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
RX_FQ_IRQ
r
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TX_FQ_IRQ
r
rw
Field
Bits
Type
Description
TX_FQ_IRQ
7:0
rw
TX FQ IRQ
When writing 1 to TX_FQ_IRQ[n], triggers the interrupt line tx_fq_irq[n],
those bits are auto-cleared. This bit field register is only accessible in
write mode if the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
RX_FQ_IRQ
23:16
rw
RX FQ IRQ
When writing 1 to RX_FQ_IRQ[n], triggers the interrupt line rx_fq_irq[n],
those bits are auto-cleared. This bit field register is only accessible in
write mode if the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.97
Node i interrupt test register 1
This register is only accessible in write mode if the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set.
Ni_INT_TEST1 (i=0-3)
Offset address:
21808H+i*2000H
Node i interrupt test register 1
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4373
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TX_P
Q_IR
Q
STAT
S_IR
Q
STO
P_IR
Q
RX_F
ILTE
R_IR
Q
TX_F
ILTE
R_IR
Q
r
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
TX_A
BORT
_IRQ
RX_A
BOR
T_IR
Q
RX_F
ILTE
R_ER
R
MEM
_TO_
ERR
MEM
_SFT
Y_ER
R
REG_
CRC_
ERR
DESC
_ERR
AP_P
ARIT
Y_ER
R
DP_
PARI
TY_E
RR
DP_S
EQ_E
RR
DP_
DO_
ERR
DP_T
O_E
RR
DMA
_CH_
ERR
DMA
_TO_
ERR
RESP_ERR
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
RESP_ERR
1:0
rw
RESP ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
DMA_TO_ERR
2
rw
DMA TO ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
DMA_CH_ERR
3
rw
DMA CH ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
DP_TO_ERR
4
rw
DP TO ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
DP_DO_ERR
5
rw
DP DO ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
DP_SEQ_ERR
6
rw
DP SEQ ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
DP_PARITY_ER
R
7
rw
DP PARITY ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
AP_PARITY_ER
R
8
rw
AP PARITY ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4374
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DESC_ERR
9
rw
DESC ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
REG_CRC_ERR 10
rw
REG CRC ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
MEM_SFTY_ER
R
11
rw
MEM SFTY ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
MEM_TO_ERR
12
rw
MEM TO ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
RX_FILTER_ER
R
13
rw
RX FILTER ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
RX_ABORT_IR
Q
14
rw
RX ABORT IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
TX_ABORT_IR
Q
15
rw
TX ABORT IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
TX_FILTER_IR
Q
16
rw
TX FILTER IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
RX_FILTER_IR
Q
17
rw
RX FILTER IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
STOP_IRQ
18
rw
STOP IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
STATS_IRQ
19
rw
STATS IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4375
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TX_PQ_IRQ
20
rw
TX PQ IRQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared. This bit field register is only accessible in write mode if
the TEST_IRQ_EN bit in Ni_DEBUG_TEST_CTRL is set
0
31:21
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.98
Node i TX-SCAN first candidates register
This register gives the 4 best candidates evaluated by the TX-Scan. This register gives the first and second
highest priority TX descriptor after a TX-Scan. It provides also the third and fourth candidates during a TX-Scan,
considering the first and second candidates as already defined by a previous TX-Scan run.
Ni_TX_SCAN_FC (i=0-3)
Offset address:
21810H+i*2000H
Node i TX-SCAN first candidates register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
FQN_PQSN3
FQ_P
Q3
0
FQN_PQSN2
FQ_P
Q2
r
rh
rh
r
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
FQN_PQSN1
FQ_P
Q1
0
FQN_PQSN0
FQ_P
Q0
r
rh
rh
r
rh
rh
Field
Bits
Type
Description
FQ_PQ0
0
rh
FQ PQ0
The first candidate evaluated by TX-Scan is either a TX Priority Queue
(when set to 1) or a TX FIFO Queue (when set to 0). This bit field is
identical to Ni_TX_SCAN_BC.FH_PQ bit register
FQN_PQSN0
5:1
rh
FQN PQSN0
The first candidate is coming from either the TX FIFO Queue number N
(defined by FQN in TX descriptor) or the TX Priority Queue Slot number
M (defined by the PQSN in TX descriptor). The meaning of this bit field
depends on the PQ0. This bit field is identical to
Ni_TX_SCAN_BC.FH_FQN_PQSN bit register
FQ_PQ1
8
rh
FQ PQ1
The second candidate evaluated by TX-Scan is either a TX Priority
Queue (when set to 1) or a TX FIFO Queue (when set to 0). This bit field
is identical to Ni_TX_SCAN_BC.SH_PQ bit register
FQN_PQSN1
13:9
rh
FQN PQSN1
The second candidate is coming from either the TX FIFO Queue number
N (defined by FQN in TX descriptor) or the TX Priority Queue Slot
number M (defined by the PQSN in TX descriptor). The meaning of this
bit field depends on the PQ0. This bit field is identical to the
Ni_TX_SCAN_BC.SH_FQN_PQSN bit register
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4376
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FQ_PQ2
16
rh
FQ PQ2
The third candidate evaluated by TX-Scan is either a TX Priority Queue
(when set to 1) or a TX FIFO Queue (when set to 0).
FQN_PQSN2
21:17
rh
FQN PQSN2
The third candidate is coming from either the TX FIFO Queue number N
(defined by FQN in TX descriptor) or the TX Priority Queue Slot number
M (defined by the PQSN in TX descriptor). The meaning of this bit field
depends on the PQ2.
FQ_PQ3
24
rh
FQ PQ3
The fourth candidate evaluated by TX-Scan is either a TX Priority Queue
(when set to 1) or a TX FIFO Queue (when set to 0).
FQN_PQSN3
29:25
rh
FQN PQSN3
The fourth candidate is coming from either the TX FIFO Queue number
N (defined by FQN in TX descriptor) or the TX Priority Queue Slot
number M (defined by the PQSN in TX descriptor). The meaning of this
bit field depends on the PQ3.
0
7:6,
15:14,
23:22,
31:30
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.99
Node i TX-SCAN best candidates register
This register gives the first and second highest priority TX descriptor after a TX-Scan.
Ni_TX_SCAN_BC (i=0-3)
Offset address:
21814H+i*2000H
Node i TX-SCAN best candidates register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
SH_OFFSET
SH_FQN_PQSN
SH_
PQ
rh
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
FH_OFFSET
FH_FQN_PQSN
FH_P
Q
rh
rh
rh
Field
Bits
Type
Description
FH_PQ
0
rh
FH PQ
First highest priority candidate evaluated by TX-Scan. It is either a TX
Priority Queue (when set to 1) or a TX FIFO Queue (when set to 0).
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4377
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FH_FQN_PQS
N
5:1
rh
FH FQN PQSN
First highest priority candidate coming from either the TX FIFO Queue
number N (defined by FQN in TX descriptor) or the TX Priority Queue
Slot number M (defined by the PQSN in TX descriptor). The meaning of
this bit field depends on the FH_PQ.
FH_OFFSET
15:6
rh
FH OFFSET
First highest priority candidate offset in multiple of 32bytes (TX
descriptor size). This register is relevant only for the TX FIFO Queue. It
provides the index of the TX descriptor in the TX FIFO Queue which is in
use on the CAN bus. When FH_PQ = 1 it is set to 0.
SH_PQ
16
rh
SH PQ
Second highest priority candidate evaluated by TX-Scan. It is either a TX
Priority Queue (when set to 1) or a TX FIFO Queue (when set to 0).
SH_FQN_PQS
N
21:17
rh
SH FQN PQSN
Second highest priority candidate coming from either the TX FIFO
Queue number N (defined by FQN in TX descriptor) or the TX Priority
Queue Slot number M (defined by the PQSN in TX descriptor). The
meaning of this bit field depends on the SH_PQ.
SH_OFFSET
31:22
rh
SH OFFSET
Second highest priority candidate offset in multiple of 32bytes (TX
descriptor size). This register is relevant only for the TX FIFO Queue. It
provides the index of the TX descriptor in the TX FIFO Queue which is
about to be sent on the CAN bus. When SH_PQ = 1 it is set to 0.
22.9.100
Node i valid TX FIFO queue descriptors in local memory
Ni_TX_FQ_DESC_VALID (i=0-3)
Offset address:
21818H+i*2000H
Node i valid TX FIFO queue descriptors in local memory
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
DESC_NC_VALID
r
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
DESC_CN_VALID
r
rh
Field
Bits
Type
Description
DESC_CN_VAL
ID
7:0
rh
DESC CN VALID
When DESC_CN_VALID[n] = 1, the current/next TX descriptor for the TX
FIFO Queue n is available in L_MEM.
DESC_NC_VAL
ID
23:16
rh
DESC NC VALID
When DESC_NC_VALID[n] = 1, the next/current TX descriptor for the TX
FIFO Queue is available in L_MEM.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4378
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
15:8,
31:24
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.101
Node i valid TX priority queue descriptors in local memory
Ni_TX_PQ_DESC_VALID (i=0-3)
Offset address:
2181CH+i*2000H
Node i valid TX priority queue descriptors in local
memory
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
DESC_VALID
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
DESC_VALID
rh
Field
Bits
Type
Description
DESC_VALID
31:0
rh
DESC VALID
When DESC_VALID[n] = 1, the TX descriptor assigned to the slot n in
local memory is valid.
22.9.102
Node i CRC control register
Ni_CRC_CTRL (i=0-3)
Offset address:
21880H+i*2000H
Node i CRC control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
STAR
T
r
w
Field
Bits
Type
Description
START
0
w
START
Writing a 1 to this bit triggers the HW CRC check of registers. This action
can be done any time for a sanity check
0
31:1
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4379
v1.1
2025-06-26


22.9.103
Node i CRC register
Ni_CRC_REG (i=0-3)
Offset address:
21884H+i*2000H
Node i CRC register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
VAL
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
VAL
rw
Field
Bits
Type
Description
VAL
31:0
rw
VAL
CRC value of all the registers protected by CRC. Once done, a write to
the START bit in the Ni_CRC_CTRL register must be done
22.9.104
Node i endianness test register
Ni_ENDN (i=0-3)
Offset address:
21900H+i*2000H
Node i endianness test register
Kernel Reset value:
8765 4321H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
ETV
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ETV
r
Field
Bits
Type
Description
ETV
31:0
r
ETV
The purpose of this register is to identify the beginning of the PRT
address map in a memory dump and to check the proper endianness
data byte mapping when the data word is routed through different
busses.
22.9.105
Node i PRT release identification register
Ni_PREL (i=0-3)
Offset address:
21904H+i*2000H
Node i PRT release identification register
Kernel Reset value:
0540 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4380
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
REL
STEP
SUBSTEP
YEAR
r
r
r
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MON
DAY
r
r
Field
Bits
Type
Description
DAY
7:0
r
DAY
Define the day of the release using a binary coded decimal
representation (1 being the first day of the month and so forth). This
reset value is defined by the generic parameter
DESIGN_TIME_STAMP_G[7:0]. If the generic parameter
DESIGN_TIME_STAMP_G is not set, the default value is the one defined
here
MON
15:8
r
MON
Define the month of the release using a binary coded decimal
representation (1 being January and so forth). This reset value is
defined by the generic parameter DESIGN_TIME_STAMP_G[15:8]. If the
generic parameter DESIGN_TIME_STAMP_G is not set, the default value
is the one defined here
YEAR
19:16
r
YEAR
Define the year of the release using a binary coded decimal
representation (0 being 2020 and so forth&#8230;). This reset value is
defined by the generic parameter DESIGN_TIME_STAMP_G[19:16]. If the
generic parameter DESIGN_TIME_STAMP_G is not set, the default value
is the one defined here
SUBSTEP
23:20
r
SUBSTEP
Sub-Step value according to Step.
STEP
27:24
r
STEP
Step value according to Release.
REL
31:28
r
REL
Release value, used to identify the main release of the XCAN_PRT.
22.9.106
Node i PRT status register
Ni_STAT (i=0-3)
Offset address:
21908H+i*2000H
Node i PRT status register
Kernel Reset value:
0000 0010H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
TEC
RP
REC
rh
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
TDCV
BO
EP
FIMA CLKA
STP
INT
ACT
rh
rh
rh
rh
rh
rh
rh
rh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4381
v1.1
2025-06-26


Field
Bits
Type
Description
ACT
1:0
rh
ACT
The current activity of this node: 0b00: inactive state 0b01: Idle 0b10:
Receiver 0b11: Transmitter When the CAN protocol operation is
stopped, ACT changes to 0b00 and INT changes to 0. When the CAN
protocol operation is started, INT is set to 1, but ACT remains at 0b00
until the CAN protocol&#8217;s bus idle detection condition is met,
then it changes to 0b01 and INT changes to 0. When the CAN protocol
operation is started while BO is set, the PRT remains in integrating state
(INT=1 and ACT=0b00) until the Bus-Off recovery sequence is finished,
then it changes to 0b01 and INT changes to 0. When PRT detects a
protocol exception event (see [1], chapter 10.9.5), ACT changes to 0b00
and INT changes to 1 until the CAN protocol&#8217;s bus idle detection
condition is met, then ACT changes to 0b01 and INT changes to 0. ACT
changes from 0b01 to 0b10 when the PRT has received a Start-of-Frame
from the CAN bus. ACT changes from 0b01 to 0b11 when the PRT has
sent a Start-of-Frame to the CAN bus. ACT changes from 0b11 to 0b10
when the PRT loses arbitration during a transmission. ACT changes
from 0b10 to 0b01 or from 0b11 to 0b01when the PRT detects the
second bit of intermission (see [1], chapter 10.4.6.2) to be recessive.
INT
2
rh
INT
This node is integrating into CAN bus traffic.
STP
3
rh
STP
Waiting for end of actual message after STOP command, see Starting
and Stopping The Module chapter.
CLKA
4
rh
CLKA
The actual value of the CLOCK_ACTIVE input signal, see Starting and
Stopping the Module chapter. As the clock must be active when a reset
is performed, the default value should be 1.
FIMA
5
rh
FIMA
Fault Injection Module Activated, see Safety Measures chapter.
EP
6
rh
EP
This node is in Error-Passive state. When both error counters drop
below 127, or when the Bus-Off recovery sequence is finished, the EP
bit is cleared.
BO
7
rh
BO
This node is in Bus-Off state. This flag is set on an error condition that
would have caused an increment of the Transmit Error Counter to a
value beyond its 8 bit range. When the PRT enters Bus-Off state, BO is
set to 1 and CAN protocol operation is stopped. When the Bus-Off
recovery sequence is finished, BO is cleared.
TDCV
15:8
rh
TDCV
Transmitter Delay Compensation&#8217;s delay value. A software reset
clears the TDV bit field to 0x00. This register shows the sum of the
measured delay plus the configured offset, giving the position of the
secondary sample point. It is updated for each frame transmission that
includes a data phase.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4382
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
REC
22:16
rh
REC
The CAN protocol&#8217;s Receive Error Counter. A software reset does
not change the value in this register. When the Bus-Off recovery
sequence is finished, the error counter REC is cleared. The REC is a 7-
bit-counter, together with the Error-Passive flag EP. When the increment
REC+1 or REC+8 would result in a value > 127 (carry-flag), the REC is
kept unchanged, but EP is set. When EP is set but REC is below 127 and
further errors are detected with an REC+1 condition, the REC will be
incremented until it reaches 127. At the reception of a valid message,
the REC-1 decrements the actual value of the REC by one AND clears the
Error-Passive flag EP.
RP
23
rh
RP
The Passive flag of the CAN protocol&#8217;s Receive Error Counter.
This flag is set on an error condition that would have caused an
increment of the Receive Error Counter to a value beyond its 7 bit
range.
TEC
31:24
rh
TEC
The CAN protocol&#8217;s Transmit Error Counter. A software reset
does not change the value in this register. When the Bus-Off recovery
sequence is finished, the error counter TEC is cleared. When the
increment TEC+8 would result in a value > 255 (carry-flag), the TEC is
kept unchanged, but BO is set. The Transmit Error Counter is
decremented by one each time a CAN message has been successfully
transmitted, but it is not decremented below the value 0.
22.9.107
Node i event status flags register
The Ni_EVNT Register contains event status flags. The flags are set by the PRT when specific events occur. A
software reset clears all flags. A host write access to this register, writing a 1 to a specific flag, clears that flag.
When a host write access occurs concurrently with a set condition for a flag, the flag is set.
Ni_EVNT (i=0-3)
Offset address:
21920H+i*2000H
Node i event status flags register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
ABO
IFR
USO
DU
PXE
TXF
RXF
DO
STE
FRE
AKE
B1E
B0E
CRE
r
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
rw1ch
Field
Bits
Type
Description
CRE
0
rw1ch
CRE
CRC Error.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4383
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
B0E
1
rw1ch
B0E
Bit0 Error: The PRT wanted to send a dominant bit (logical value 0), but
the monitored CAN bus value was recessive. During Bus-Off recovery,
B0E is also set each time a sequence of 11 recessive bits has been
monitored, enabling the CPU to readily check whether the CAN bus is
stuck at dominant or continuously disturbed, and to monitor the
proceeding of the Bus-Off recovery sequence.
B1E
2
rw1ch
B1E
Bit1Error: During the transmission of a message (with the exception of
the arbitration field), the PRT wanted to send a recessive bit (logical
value 1), but the monitored CAN bus value was dominant.
AKE
3
rw1ch
AKE
Acknowledge Error.
FRE
4
rw1ch
FRE
Form Error or the condition of CAN error counting rule f).
STE
5
rw1ch
STE
Stuff Error.
DO
6
rw1ch
DO
Overflow condition in RX_MSG sequence detected.
RXF
7
rw1ch
RXF
Frame received.
TXF
8
rw1ch
TXF
Frame transmitted.
PXE
9
rw1ch
PXE
Protocol Exception Event occurred.
DU
10
rw1ch
DU
Underrun condition in TX_MSG sequence detected.
USO
11
rw1ch
USO
Unexpected Start of Sequence during TX_MSG sequence detected.
IFR
12
rw1ch
IFR
Invalid Frame Format requested in TX_MSG.
ABO
13
rw1ch
ABO
TX_MSG sequence stopped by TX_MSG_WUSER code ABORT.
0
31:14
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.108
Node i unlock sequence register
Writing a sequence of specific data words enables the activation of control commands in the registers Ni_CTRL
and Ni_FIMC.
Ni_LOCK (i=0-3)
Offset address:
21940H+i*2000H
Node i unlock sequence register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4384
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
TMK
w
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
ULK
w
Field
Bits
Type
Description
ULK
15:0
w
ULK
Unlock Key.
TMK
31:16
w
TMK
Test Mode Key.
22.9.109
Node i control register
Writing to this register controls the CAN protocol operation. Reading this register gives the value 0x00000000.
When writing to this register, only one of the four bits TEST, SRES , STRT, or STOP may be written to 1, otherwise
the write access takes no effect. The bit IMMD may be written to 1 together with the bit STOP, but not together
with one of the other bits.
Ni_CTRL (i=0-3)
Offset address:
21944H+i*2000H
Node i control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
TEST
0
SRES
0
STRT
0
IMM
D
STO
P
r
w
r
w
r
w
r
w
w
Field
Bits
Type
Description
STOP
0
w
STOP
Stop CAN protocol operation. The Unlock Key must be used prior to
write to this bit field. When not set together with bit IMMD the PRT waits
for an ongoing CAN message to finish before stopping CAN protocol
operation.
IMMD
1
w
IMMD
Stop CAN protocol operation immediately. The Unlock Key must be
used prior to write to this bit . This bit is only effective when being set
together with the bit STOP.
STRT
4
w
STRT
Start CAN protocol operation.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4385
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
SRES
8
w
SRES
Software Reset. When the CAN protocol operation is stopped, the
software reset of all state machines of the PRT (excluding the error-
counters and the error-states) is triggered by writing 1 to
Ni_CTRL.SRES. No unlocking sequence is required. A software reset will
not be executed while the CAN protocol operation is started.
TEST
12
w
TEST
Enable Test Mode. The Test Mode Key must be used prior to write to
this bit field.
0
3:2,
7:5,
11:9,
31:13
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.110
Node i fault injection module control register
Writing the fault injection position number requires the application of the test mode key sequence before
writing to Ni_FIMC. This register must be accessed in privileged mode when supported.
Ni_FIMC (i=0-3)
Offset address:
21948H+i*2000H
Node i fault injection module control register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
FIP
r
rw
Field
Bits
Type
Description
FIP
14:0
rw
FIP
Fault Injection Position. Writing to Ni_FIMC while Ni_MODE.FIME is set
activates the Fault Injection Module FIM (see Safety Measures chapter).
While the FIM is activated, the value of Ni_FIMC.FIP is protected from
further write accesses until the FIM is de-activated again.
0
31:15
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.111
Node i hardware test functions register
This register is writable after the hardware test mode functions are enabled by writing the test mode key
sequence to Ni_LOCK and Ni_CTRL registers. While the hardware test mode functions are not enabled, this
register is read-only. This register must be accessed in privileged mode when supported. The hardware test
mode functions are disabled and cleared by the software reset of the PRT.
Ni_TEST (i=0-3)
Offset address:
2194CH+i*2000H
Node i hardware test functions register
Kernel Reset value:
0000 0008H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4386
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
BUS_
OFF
BUS_
ON
E_PA
SSIV
E
E_AC
TIVE
BUS_
ERR
RX_E
VT
TX_E
VT
IFF_
RQ
RX_D
O
TX_D
U
USO
S
ABO
RTE
D
r
w
w
w
w
w
w
w
w
w
w
w
w
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
HWT
0
TXC
RXD
0
LBCK
r
r
rw
r
r
rw
Field
Bits
Type
Description
LBCK
0
rw
LBCK
Enable the Message Loop-Back mode, see chapter Trace and Debug.
RXD
3
r
RXD
Bit value seen at CAN_RX. The CAN_RX input (output signal of the
transceiver) is always readable through this bit.
TXC
5:4
rw
TXC
Control the bit value driven at CAN_TX 0b00: Normal function of CAN TX
0b01: Normal function of CAN TX. CAN RX is ignored (for message look
back mode) 0b10: CAN TX output set to 0 0b11: CAN TX output set to 1
HWT
15
r
HWT
This status flag HWT shows whether the hardware test mode functions
are enabled, set to 1 means enable.
ABORTED
16
w
ABORTED
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
USOS
17
w
USOS
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
TX_DU
18
w
TX DU
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
RX_DO
19
w
RX DO
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
IFF_RQ
20
w
IFF RQ
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
TX_EVT
21
w
TX EVT
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
RX_EVT
22
w
RX EVT
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4387
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
BUS_ERR
23
w
BUS ERR
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
E_ACTIVE
24
w
E ACTIVE
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
E_PASSIVE
25
w
E PASSIVE
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
BUS_ON
26
w
BUS ON
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
BUS_OFF
27
w
BUS OFF
Writing a 1 to the bit field triggers the related interrupt line, this bit is
auto-cleared.
0
2:1,
14:6,
31:28
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.112
Node i operating mode register
Configuration register that is writable while the CAN communication is stopped and that is read-only after the
CAN communication is started. This register defines separate operating mode options. The four configuration
bits FDOE, XLOE, EFDI, and XLTR, are interrelated according to table Frame Formats defined in Operating Mode
chapter.
Ni_MODE (i=0-3)
Offset address:
21960H+i*2000H
Node i operating mode register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
FIME
EFDI
XLTR
SFS
RSTR MON
TXP
EFBI
PXH
D
TDCE XLOE
FDO
E
r
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rwh
rwh
Field
Bits
Type
Description
FDOE
0
rwh
FDOE
FD Frame Format enabled. When set to 1, node is FD enabled according
to ISO11898-1:2024. When set to 0, node is FD tolerant according to
ISO11898-1:2024 (only Classical CAN frames used). This bit cannot be
set to 1 when the static input ONLY_CC is set.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4388
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
XLOE
1
rwh
XLOE
XL Frame Format enabled. When set to 0, node behaves according to
ISO11898-1:2024, no arbitration during FDF bit. When set to 1, node
behaves according to ISO11898-1:2024, arbitration during FDF bit and
XLF bit. This bit cannot be set to 1 when one of the static inputs
ONLY_CC or ONLY_CC_FD is set. Setting XLOE without setting FDOE is
an invalid configuration.
TDCE
2
rw
TDCE
Transmitter Delay Compensation Enabled as defined in [1].
PXHD
3
rw
PXHD
Protocol Exception Handling Disabled.
EFBI
4
rw
EFBI
Edge Filtering during Bus Integration. If this bit is set, the PRT requires
two consecutive dominant to to detect an edge causing the reset of the
bit counter for the detection of the idle condition.
TXP
5
rw
TXP
Transmit Pause. If this bit is set, the PRT pauses for two CAN bit times
before starting the next transmission after itself has successfully
transmitted a frame
MON
6
rw
MON
Monitoring Mode Enabled as defined in [1].
RSTR
7
rw
RSTR
Restricted Mode Enabled as defined in [1].
SFS
8
rw
SFS
Time stamp position: Start of Frame Stamping 1: Timestamps captured
at the start of a frame 0: Timestamps captured at the end of a frame.
XLTR
9
rw
XLTR
XL Transceiver Connected.
EFDI
10
rw
EFDI
Error Flag Disable, 1 means Error Signalling is disabled as defined in [1]
and the error counters REC and TEC are not incremented. When this bit
is set, only CAN XL frames are transmitted and received dominant FDF
or XLF bits are treated as form errors.
FIME
11
rw
FIME
Fault Injection Module Enable, see Safety Measures chapter.
0
31:12
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.113
Node i arbitration phase nominal bit timing register
Configuration register that is writable while the CAN communication is stopped and that is read-only after the
CAN communication is started. This register defines the Nominal Bit Timing as defined in [1].
Ni_NBTP (i=0-3)
Offset address:
21964H+i*2000H
Node i arbitration phase nominal bit timing register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4389
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
BRP
NTSEG1
r
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
NTSEG2
0
NSJW
r
rw
r
rw
Field
Bits
Type
Description
NSJW
6:0
rw
NSJW
Nominal SJW. Valid values for the Nominal Synchronization Jump
Width NSJW are 0x00-0x7F. The actual interpretation of this value is
that the Nominal Synchronization Jump Width is (NSJW + 1) TQ long.
NTSEG2
14:8
rw
NTSEG2
Nominal Phase_Seg2. Valid values for NTSEG2 are 0x01-0x7F. This value
defines the length of Phase_Seg2(N). The actual interpretation of this
value is that the phase buffer segment 2 is (NTSEG2 + 1) TQ long.
NTSEG1
24:16
rw
NTSEG1
Nominal Prop_Seg and Phase_Seg1. Valid values for NTSEG1 are
0x01-0x1FF. This value defines the sum of Prop_Seg(N) and
Phase_Seg1(N). The actual interpretation of this value is that these
segments together are (NTSEG1 + 1) TQ long.
BRP
29:25
rw
BRP
Bit Rate Prescaler. Valid values for the Bit Rate Prescaler BRP are
0x00-0x1F. This value defines the length of the Time Quantum TQ for all
three bit time configurations. The actual interpretation of this value is
that the TQ is (BRP + 1) CLK periods long
0
7,
15,
31:30
r
Reserved
Read as 0; should be written with 0.
22.9.114
Node i CAN FD data phase bit timing register
Configuration register that is writable while the CAN communication is stopped and that is read-only after the
CAN communication is started. This register defines the FD Data Phase Bit Timing as defined in [1].
Ni_DBTP (i=0-3)
Offset address:
21968H+i*2000H
Node i CAN FD data phase bit timing register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
DTDCO
DTSEG1
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
DTSEG2
0
DSJW
r
rw
r
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4390
v1.1
2025-06-26


Field
Bits
Type
Description
DSJW
6:0
rw
DSJW
FD data phase SJW. Valid values for the FD data phase Synchronization
Jump Width DSJW are 0x00-0x7F. The actual interpretation of this value
is that the FD data phase Synchronization Jump Width is (DSJW + 1) TQ
long.
DTSEG2
14:8
rw
DTSEG2
FD data phase Phase_Seg2. Valid values for DTSEG2 are 0x01-0x7F. This
value defines the length of Phase_Seg2(D). The actual interpretation of
this value is that the phase buffer segment 2 is (DTSEG2 + 1) TQ long.
DTSEG1
23:16
rw
DTSEG1
FD data phase Prop_Seg and Phase_Seg1. Valid values for DTSEG1 are
0x00-0xFF. This value defines the sum of Prop_Seg(D) and
Phase_Seg1(D). The actual interpretation of this value is that these
segments together are (DTSEG1 + 1) TQ long
DTDCO
31:24
rw
DTDCO
Transmitter Delay Compensation Offset for FD frames. Valid values for
the FD Transmitter Delay Compensation Offset DTDCO is 0x00-0xFF.
This configuration defines the distance between the measured delay
from CAN_TX to CAN_RX and the secondary sample point SSP,
measured in CLK periods. This value is used when transmitting a CAN
FD frame
0
7,
15
r
Reserved
Read as 0; should be written with 0.
22.9.115
Node i CAN XL data phase bit timing register
Configuration register that is writable while the CAN communication is stopped and is read-only after the CAN
communication is started. This register defines the XL Data Phase Bit Timing as defined in [1].
Ni_XBTP (i=0-3)
Offset address:
2196CH+i*2000H
Node i CAN XL data phase bit timing register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
XTDCO
XTSEG1
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
XTSEG2
0
XSJW
r
rw
r
rw
Field
Bits
Type
Description
XSJW
6:0
rw
XSJW
XL data phase SJW. Valid values for the XL data phase Synchronization
Jump Width XSJW are 0x00-0x7F. The actual interpretation of this value
is that the XL data phase Synchronization Jump Width is (XSJW + 1) TQ
long
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4391
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
XTSEG2
14:8
rw
XTSEG2
XL data phase Phase_Seg2. Valid values for XTSEG2 are 0x01-0x7F. This
value defines the length of Phase_Seg2(X). The actual interpretation of
this value is that the phase buffer segment 2 is (XTSEG2 + 1) TQ long
XTSEG1
23:16
rw
XTSEG1
XL data phase Prop_Seg and Phase_Seg1. Valid values for XTSEG1 are
0x00-0xFF. This value defines the sum of Prop_Seg(X) and
Phase_Seg1(X). The actual interpretation of this value is that these
segments together are (XTSEG1 + 1) TQ long
XTDCO
31:24
rw
XTDCO
Transmitter Delay Compensation Offset for XL frames. Valid values for
the XL Transmitter Delay Compensation Offset XTDCO is 0x00-0xFF. This
configuration defines the distance between the measured delay from
CAN_TX to CAN_RX and the secondary sample point SSP, measured in
CLK periods. This value is used when transmitting a CAN XL frame.
0
7,
15
r
Reserved
Read as 0; should be written with 0.
22.9.116
Node i PWME configuration register
Configuration register that is writable while the CAN communication is stopped and is read-only after the CAN
communication is started. This register defines the parameters needed for the PWM coding (as described in [1])
in the PWME module for CAN XL transceivers with switchable operating modes
Ni_PCFG (i=0-3)
Offset address:
21970H+i*2000H
Node i PWME configuration register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
PWMO
r
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
PWML
0
PWMS
r
rw
r
rw
Field
Bits
Type
Description
PWMS
5:0
rw
PWMS
PWM phase Short.
PWML
13:8
rw
PWML
PWM phase Long.
PWMO
21:16
rw
PWMO
PWM Offset.
0
7:6,
15:14,
31:22
r
Reserved
Read as all 0's; should be written with all 0's.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4392
v1.1
2025-06-26


22.9.117
Node i functional raw event status register
This register provides information about the occurrence of functional relevant events inside the MH and the
PRT. A flag is set when the related event is detected, independent of Ni_FUNC_ENA. The flags remain set until
the Host CPU clears them by writing a 1 to the corresponding bit position at register FUNC_CLR.
Ni_FUNC_RAW (i=0-3)
Offset address:
21A00H+i*2000H
Node i functional raw event status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
PRT_
RX_E
VT
PRT_
TX_E
VT
PRT_
BUS_
ON
PRT_
E_AC
TIVE
0
MH_
STAT
S_IR
Q
MH_
RX_A
BOR
T_IR
Q
MH_
TX_A
BOR
T_IR
Q
MH_
TX_F
ILTE
R_IR
Q
MH_
RX_F
ILTE
R_IR
Q
MH_
STO
P_IR
Q
MH_
TX_P
Q_IR
Q
r
rh
rh
rh
rh
r
rh
rh
rh
rh
rh
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MH_R
X_FQ
7_IR
Q
MH_
RX_F
Q6_I
RQ
MH_
RX_F
Q5_I
RQ
MH_
RX_F
Q4_I
RQ
MH_
RX_F
Q3_I
RQ
MH_
RX_F
Q2_I
RQ
MH_
RX_F
Q1_I
RQ
MH_
RX_F
Q0_I
RQ
MH_
TX_F
Q7_I
RQ
MH_
TX_F
Q6_I
RQ
MH_
TX_F
Q5_I
RQ
MH_
TX_F
Q4_I
RQ
MH_
TX_F
Q3_I
RQ
MH_
TX_F
Q2_I
RQ
MH_
TX_F
Q1_I
RQ
MH_
TX_F
Q0_I
RQ
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
Field
Bits
Type
Description
MH_TX_FQ0_I
RQ
0
rh
MH TX FQ0 IRQ
MH interrupt of the TX FIFO Queue 0. This interrupt is triggered when an
invalid TX descriptor is fetched from this TX FIFO Queue, a TX message
from that FIFO Queue is sent (if set in TX descriptor), or a TX message of
that TX FIFO Queue is skipped, see description of TX_FQ_IRQ[7:0] in MH
section.
MH_TX_FQ1_I
RQ
1
rh
MH TX FQ1 IRQ
MH interrupt of the TX FIFO Queue 1. Refer to the description of the
MH_TX_FQ0_IRQ
MH_TX_FQ2_I
RQ
2
rh
MH TX FQ2 IRQ
MH interrupt of the TX FIFO Queue 2. Refer to the description of the
MH_TX_FQ0_IRQ
MH_TX_FQ3_I
RQ
3
rh
MH TX FQ3 IRQ
MH interrupt of the TX FIFO Queue 3. Refer to the description of the
MH_TX_FQ0_IRQ
MH_TX_FQ4_I
RQ
4
rh
MH TX FQ4 IRQ
MH interrupt of the TX FIFO Queue 4. Refer to the description of the
MH_TX_FQ0_IRQ
MH_TX_FQ5_I
RQ
5
rh
MH TX FQ5 IRQ
MH interrupt of the TX FIFO Queue 5. Refer to the description of the
MH_TX_FQ0_IRQ
MH_TX_FQ6_I
RQ
6
rh
MH TX FQ6 IRQ
MH interrupt of the TX FIFO Queue 6. Refer to the description of the
MH_TX_FQ0_IRQ
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4393
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_TX_FQ7_I
RQ
7
rh
MH TX FQ7 IRQ
MH interrupt of the TX FIFO Queue 7. Refer to the description of the
MH_TX_FQ0_IRQ
MH_RX_FQ0_I
RQ
8
rh
MH RX FQ0 IRQ
MH interrupt of the RX FIFO Queue 0. This interrupt is triggered when an
invalid RX descriptor is fetched from this RX FIFO Queue, or an RX
message is received (if set in RX descriptor) in this RX FIFO Queue, see
description of RX_FQ_IRQ[7:0] in MH section.
MH_RX_FQ1_I
RQ
9
rh
MH RX FQ1 IRQ
MH interrupt of the RX FIFO Queue 1. Refer to the description of the
MH_RX_FQ0_IRQ
MH_RX_FQ2_I
RQ
10
rh
MH RX FQ2 IRQ
MH interrupt of the RX FIFO Queue 2. Refer to the description of the
MH_RX_FQ0_IRQ
MH_RX_FQ3_I
RQ
11
rh
MH RX FQ3 IRQ
MH interrupt of the RX FIFO Queue 3. Refer to the description of the
MH_RX_FQ0_IRQ
MH_RX_FQ4_I
RQ
12
rh
MH RX FQ4 IRQ
MH interrupt of the RX FIFO Queue 4. Refer to the description of the
MH_RX_FQ0_IRQ
MH_RX_FQ5_I
RQ
13
rh
MH RX FQ5 IRQ
MH interrupt of the RX FIFO Queue 5. Refer to the description of the
MH_RX_FQ0_IRQ
MH_RX_FQ6_I
RQ
14
rh
MH RX FQ6 IRQ
MH interrupt of the RX FIFO Queue 6. Refer to the description of the
MH_RX_FQ0_IRQ
MH_RX_FQ7_I
RQ
15
rh
MH RX FQ7 IRQ
MH interrupt of the RX FIFO Queue 7. Refer to the description of the
MH_RX_FQ0_IRQ
MH_TX_PQ_IR
Q
16
rh
MH TX PQ IRQ
Interrupt of TX Priority Queue. Any TX message sent from the TX Priority
Queue can be configured to trigger this interrupt. The SW would then
need to look at the MH register Ni_TX_PQ_INT_STS to identify which
slot has generated the interrupt and for which reason.
MH_STOP_IRQ 17
rh
MH STOP IRQ
The interrupt is triggered when the PRT is stopped. The MH finishes its
task and switches to idle mode.
MH_RX_FILTER
_IRQ
18
rh
MH RX FILTER IRQ
In order to track RX filtering results, an interrupt can be triggered when
the comparison between an RX message header and a defined filter is
successful.
MH_TX_FILTER
_IRQ
19
rh
MH TX FILTER IRQ
The interrupt is triggered when the TX filter is enabled, and a TX
message is rejected.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4394
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_TX_ABOR
T_IRQ
20
rh
MH TX ABORT IRQ
This interrupt line is triggered when the MH needs to abort a TX
message being sent to the PRT.
MH_RX_ABOR
T_IRQ
21
rh
MH RX ABORT IRQ
This interrupt line is triggered when the MH needs to abort an RX
message being received from PRT.
MH_STATS_IR
Q
22
rh
MH STATS IRQ
One of the RX/TX counters have reached the threshold.
PRT_E_ACTIVE 24
rh
PRT E ACTIVE
PRT switched from Error-Passive to Error-Active state.
PRT_BUS_ON
25
rh
PRT BUS ON
PRT started CAN communication, after start or end of BusOff.
PRT_TX_EVT
26
rh
PRT TX EVT
PRT transmitted a valid CAN message.
PRT_RX_EVT
27
rh
PRT RX EVT
PRT received a valid CAN message.
0
23,
31:28
r
Reserved
Read as 0; should be written with 0.
22.9.118
Node i error raw event status register
This register provides information about the occurrence of functional error relevant events inside the MH and
the PRT. A flag is set when the related event is detected, independent of Ni_ERR_ENA. The flags remain set until
the Host CPU clears them by writing a 1 to the corresponding bit position at register ERR_CLR.
Ni_ERR_RAW (i=0-3)
Offset address:
21A04H+i*2000H
Node i error raw event status register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TOP_
MUX
_TO_
ERR
0
PRT_
BUS_
OFF
PRT_
E_PA
SSIV
E
PRT_
BUS_
ERR
PRT_
IFF_
RQ
PRT_
RX_D
O
PRT_
TX_D
U
PRT_
USO
S
PRT_
ABO
RTE
D
r
rh
r
rh
rh
rh
rh
rh
rh
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MH_
MEM
_TO_
ERR
MH_
WR_
RESP
_ERR
MH_
RD_
RESP
_ERR
MH_
DMA
_CH_
ERR
MH_
DMA
_TO_
ERR
MH_
DP_T
O_E
RR
MH_
DP_
DO_
ERR
MH_
DP_S
EQ_E
RR
MH_
DP_
PARI
TY_E
RR
MH_
AP_P
ARIT
Y_ER
R
MH_
DESC
_ERR
MH_
REG_
CRC_
ERR
MH_
MEM
_SFT
Y_ER
R
MH_
RX_F
ILTE
R_ER
R
r
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4395
v1.1
2025-06-26


Field
Bits
Type
Description
MH_RX_FILTER
_ERR
0
rh
MH RX FILTER ERR
MH RX filtering has not finished in time, i.e. current RX filtering has not
been completed before next incoming RX message requires RX filtering.
MH_MEM_SFT
Y_ERR
1
rh
MH MEM SFTY ERR
MH detected error in L_MEM. This interrupt is triggered when either the
MEM_SFTY_CE or MEM_SFTY_UE input signal is active. The Message
Handler provides the information, which signal was active, see flags
MH:SFTY_INT_STS.MEM_SFTY_CE and
MH:SFTY_INT_STS.MEM_SFTY_UE.
MH_REG_CRC
_ERR
2
rh
MH REG CRC ERR
MH detected CRC error at the register bank. See also description of
REG_CRC_ERR in MH section.
MH_DESC_ER
R
3
rh
MH DESC ERR
CRC error detected on RX/TX descriptor or RX/TX descriptor not
expected detected. A status flag can define if it is on TX or RX path, see
Ni_SFTY_INT_STS register.
MH_AP_PARIT
Y_ERR
4
rh
MH AP PARITY ERR
MH detected parity error at address pointers, used to manage the MH
Queues (RX/TX FIFO Queues and TX Priority Queues). See also
description of AP_PARITY_ERR in MH section.
MH_DP_PARIT
Y_ERR
5
rh
MH DP PARITY ERR
MH detected parity error at RX message data (received from PRT and
written to AXI system bus) respective parity error detected at TX
message data (read from AXI system bus and transferred to PRT).
Associated information provided by MH register Ni_ERR_INT_STS, e.g. if
RX message or TX message was affected.
MH_DP_SEQ_
ERR
6
rh
MH DP SEQ ERR
MH detected an incorrect sequence at RX_MSG respective TX_MSG
interfaces located between MH and PRT. Associated information
provided by MH register Ni_ERR_INT_STS, e.g. if RX or TX interface was
affected.
MH_DP_DO_E
RR
7
rh
MH DP DO ERR
MH detected a data overflow at RX buffer, see description of
DP_DO_ERR in MH section.
MH_DP_TO_E
RR
8
rh
MH DP TO ERR
MH detected timeout at TX_MSG interface located between MH and
PRT, see description of DP_TO_ERR in MH section.
MH_DMA_TO_
ERR
9
rh
MH DMA TO ERR
MH detected timeout at DMA_AXI interface, see description of
DMA_TO_ERR in MH section.
MH_DMA_CH_
ERR
10
rh
MH DMA CH ERR
MH detected routing error, i.e. data received or sent are not properly
routed to or from DMA channel interfaces, see description of
DMA_CH_ERR in MH section.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4396
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_RD_RESP
_ERR
11
rh
MH RD RESP ERR
MH detected a bus error caused by a read access to S_MEM respective
L_MEM, see description of RESP_ERR in MH section.
MH_WR_RESP
_ERR
12
rh
MH WR RESP ERR
MH detected a bus error caused by a write access to S_MEM respective
L_MEM, see description of RESP_ERR in MH section.
MH_MEM_TO_
ERR
13
rh
MH MEM TO ERR
MH detected timeout at local memory interface MEM_AXI, see
description of MEM_TO_ERR in MH section.
PRT_ABORTED 16
rh
PRT ABORTED
PRT detected stop of TX_MSG sequence by TX_MSG_WUSER code
ABORT.
PRT_USOS
17
rh
PRT USOS
PRT detected unexpected Start of Sequence during TX_MSG sequence.
PRT_TX_DU
18
rh
PRT TX DU
PRT detected underrun condition at TX_MSG sequence.
PRT_RX_DO
19
rh
PRT RX DO
PRT detected overflow condition at RX_MSG sequence.
PRT_IFF_RQ
20
rh
PRT IFF RQ
PRT detected invalid Frame Format at TX_MSG.
PRT_BUS_ERR 21
rh
PRT BUS ERR
PRT detected error on the CAN Bus.
PRT_E_PASSIV
E
22
rh
PRT E PASSIVE
PRT switched from Error-Active to Error-Passive state.
PRT_BUS_OFF 23
rh
PRT BUS OFF
PRT entered Bus_Off state.
TOP_MUX_TO
_ERR
28
rh
TOP MUX TO ERR
Timeout at top-level multiplexer for HOST_AXI detected.
0
15:14,
27:24,
31:29
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.119
Node i safety raw event status register
This register provides information about the occurrence of safety relevant events inside the MH and the PRT. A
flag is set when the related event is detected, independent of Ni_SAFETY_ENA. The flags remain set until the
Host CPU clears them by writing a 1 to the corresponding bit position at register Ni_SAFETY_CLR.
Ni_SAFETY_RAW (i=0-3)
Offset address:
21A08H+i*2000H
Node i safety raw event status register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4397
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TOP_
MUX
_TO_
ERR
0
PRT_
BUS_
OFF
PRT_
E_PA
SSIV
E
PRT_
BUS_
ERR
PRT_
IFF_
RQ
PRT_
RX_D
O
PRT_
TX_D
U
PRT_
USO
S
PRT_
ABO
RTE
D
r
rh
r
rh
rh
rh
rh
rh
rh
rh
rh
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MH_
MEM
_TO_
ERR
MH_
WR_
RESP
_ERR
MH_
RD_
RESP
_ERR
MH_
DMA
_CH_
ERR
MH_
DMA
_TO_
ERR
MH_
DP_T
O_E
RR
MH_
DP_
DO_
ERR
MH_
DP_S
EQ_E
RR
MH_
DP_
PARI
TY_E
RR
MH_
AP_P
ARIT
Y_ER
R
MH_
DESC
_ERR
MH_
REG_
CRC_
ERR
MH_
MEM
_SFT
Y_ER
R
MH_
RX_F
ILTE
R_ER
R
r
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
rh
Field
Bits
Type
Description
MH_RX_FILTER
_ERR
0
rh
MH RX FILTER ERR
MH RX filtering has not finished in time, i.e. current RX filtering has not
been completed before next incoming RX message requires RX filtering.
MH_MEM_SFT
Y_ERR
1
rh
MH MEM SFTY ERR
MH detected error in L_MEM. This interrupt is triggered when either the
MEM_SFTY_CE or MEM_SFTY_UE input signal is active. The Message
Handler provides the information, which signal was active, see flags
MH:SFTY_INT_STS.MEM_SFTY_CE and
MH:SFTY_INT_STS.MEM_SFTY_UE.
MH_REG_CRC
_ERR
2
rh
MH REG CRC ERR
MH detected CRC error at the register bank. See also description of
REG_CRC_ERR in MH section.
MH_DESC_ER
R
3
rh
MH DESC ERR
CRC error detected on RX/TX descriptor or RX/TX descriptor not
expected detected. A status flag can define if it is on TX or RX path, see
Ni_SFTY_INT_STS register.
MH_AP_PARIT
Y_ERR
4
rh
MH AP PARITY ERR
MH detected parity error at address pointers, used to manage the MH
Queues (RX/TX FIFO Queues and TX Priority Queues). See also
description of AP_PARITY_ERR in MH section.
MH_DP_PARIT
Y_ERR
5
rh
MH DP PARITY ERR
MH detected parity error at RX message data (received from PRT and
written to AXI system bus) respective parity error detected at TX
message data (read from AXI system bus and transferred to PRT).
Associated information provided by MH register Ni_ERR_INT_STS, e.g. if
RX message or TX message was affected.
MH_DP_SEQ_
ERR
6
rh
MH DP SEQ ERR
MH detected an incorrect sequence at RX_MSG respective TX_MSG
interfaces located between MH and PRT. Associated information
provided by MH register Ni_ERR_INT_STS, e.g. if RX or TX interface was
affected.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4398
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_DP_DO_E
RR
7
rh
MH DP DO ERR
MH detected a data overflow at RX buffer, see description of
DP_DO_ERR in MH section.
MH_DP_TO_E
RR
8
rh
MH DP TO ERR
MH detected timeout at TX_MSG interface located between MH and
PRT, see description of DP_TO_ERR in MH section.
MH_DMA_TO_
ERR
9
rh
MH DMA TO ERR
MH detected timeout at DMA_AXI interface, see description of
DMA_TO_ERR in MH section.
MH_DMA_CH_
ERR
10
rh
MH DMA CH ERR
MH detected routing error, i.e. data received or sent are not properly
routed to or from DMA channel interfaces, see description of
DMA_CH_ERR in MH section.
MH_RD_RESP
_ERR
11
rh
MH RD RESP ERR
MH detected a bus error caused by a read access to S_MEM respective
L_MEM, see description of RESP_ERR in MH section.
MH_WR_RESP
_ERR
12
rh
MH WR RESP ERR
MH detected a bus error caused by a write access to S_MEM respective
L_MEM, see description of RESP_ERR in MH section.
MH_MEM_TO_
ERR
13
rh
MH MEM TO ERR
MH detected timeout at local memory interface MEM_AXI, see
description of MEM_TO_ERR in MH section.
PRT_ABORTED 16
rh
PRT ABORTED
PRT detected stop of TX_MSG sequence by TX_MSG_WUSER code
ABORT.
PRT_USOS
17
rh
PRT USOS
PRT detected unexpected Start of Sequence during TX_MSG sequence.
PRT_TX_DU
18
rh
PRT TX DU
PRT detected underrun condition at TX_MSG sequence.
PRT_RX_DO
19
rh
PRT RX DO
PRT detected overflow condition at RX_MSG sequence.
PRT_IFF_RQ
20
rh
PRT IFF RQ
PRT detected invalid Frame Format at TX_MSG.
PRT_BUS_ERR 21
rh
PRT BUS ERR
PRT detected error on the CAN Bus.
PRT_E_PASSIV
E
22
rh
PRT E PASSIVE
PRT switched from Error-Active to Error-Passive state.
PRT_BUS_OFF 23
rh
PRT BUS OFF
PRT entered Bus_Off state.
TOP_MUX_TO
_ERR
28
rh
TOP MUX TO ERR
Timeout at top-level multiplexer for HOST_AXI detected.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4399
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
15:14,
27:24,
31:29
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.120
Node i functional raw event clear register
Writing a 1 to a certain bit position clears the corresponding bit of register Ni_FUNC_RAW. Writing a ’0’ has no
effect.
Ni_FUNC_CLR (i=0-3)
Offset address:
21A10H+i*2000H
Node i functional raw event clear register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
PRT_
RX_E
VT
PRT_
TX_E
VT
PRT_
BUS_
ON
PRT_
E_AC
TIVE
0
MH_
STAT
S_IR
Q
MH_
RX_A
BOR
T_IR
Q
MH_
TX_A
BOR
T_IR
Q
MH_
TX_F
ILTE
R_IR
Q
MH_
RX_F
ILTE
R_IR
Q
MH_
STO
P_IR
Q
MH_
TX_P
Q_IR
Q
r
w
w
w
w
r
w
w
w
w
w
w
w
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MH_R
X_FQ
7_IR
Q
MH_
RX_F
Q6_I
RQ
MH_
RX_F
Q5_I
RQ
MH_
RX_F
Q4_I
RQ
MH_
RX_F
Q3_I
RQ
MH_
RX_F
Q2_I
RQ
MH_
RX_F
Q1_I
RQ
MH_
RX_F
Q0_I
RQ
MH_
TX_F
Q7_I
RQ
MH_
TX_F
Q6_I
RQ
MH_
TX_F
Q5_I
RQ
MH_
TX_F
Q4_I
RQ
MH_
TX_F
Q3_I
RQ
MH_
TX_F
Q2_I
RQ
MH_
TX_F
Q1_I
RQ
MH_
TX_F
Q0_I
RQ
w
w
w
w
w
w
w
w
w
w
w
w
w
w
w
w
Field
Bits
Type
Description
MH_TX_FQ0_I
RQ
0
w
MH TX FQ0 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ0_IRQ by writing 1.
MH_TX_FQ1_I
RQ
1
w
MH TX FQ1 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ1_IRQ by writing 1.
MH_TX_FQ2_I
RQ
2
w
MH TX FQ2 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ2_IRQ by writing 1.
MH_TX_FQ3_I
RQ
3
w
MH TX FQ3 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ3_IRQ by writing 1.
MH_TX_FQ4_I
RQ
4
w
MH TX FQ4 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ4_IRQ by writing 1.
MH_TX_FQ5_I
RQ
5
w
MH TX FQ5 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ5_IRQ by writing 1.
MH_TX_FQ6_I
RQ
6
w
MH TX FQ6 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ6_IRQ by writing 1.
MH_TX_FQ7_I
RQ
7
w
MH TX FQ7 IRQ
Clear bit of Ni_FUNC_RAW.MH_TX_FQ7_IRQ by writing 1.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4400
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_RX_FQ0_I
RQ
8
w
MH RX FQ0 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ0_IRQ by writing 1.
MH_RX_FQ1_I
RQ
9
w
MH RX FQ1 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ1_IRQ by writing 1.
MH_RX_FQ2_I
RQ
10
w
MH RX FQ2 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ2_IRQ by writing 1.
MH_RX_FQ3_I
RQ
11
w
MH RX FQ3 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ3_IRQ by writing 1.
MH_RX_FQ4_I
RQ
12
w
MH RX FQ4 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ4_IRQ by writing 1.
MH_RX_FQ5_I
RQ
13
w
MH RX FQ5 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ5_IRQ by writing 1.
MH_RX_FQ6_I
RQ
14
w
MH RX FQ6 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ6_IRQ by writing 1.
MH_RX_FQ7_I
RQ
15
w
MH RX FQ7 IRQ
Clear bit of Ni_FUNC_RAW.MH_RX_FQ7_IRQ by writing 1.
MH_TX_PQ_IR
Q
16
w
MH TX PQ IRQ
Clear bit Ni_FUNC_RAW.MH_TX_PQ_IRQ by writing 1.
MH_STOP_IRQ 17
w
MH STOP IRQ
Clear bit Ni_FUNC_RAW.MH_STOP_IRQ by writing 1.
MH_RX_FILTER
_IRQ
18
w
MH RX FILTER IRQ
Clear bit Ni_FUNC_RAW.MH_RX_FILTER_IRQ by writing 1.
MH_TX_FILTER
_IRQ
19
w
MH TX FILTER IRQ
Clear bit Ni_FUNC_RAW.MH_TX_FILTER_IRQ by writing 1.
MH_TX_ABOR
T_IRQ
20
w
MH TX ABORT IRQ
Clear bit Ni_FUNC_RAW.MH_TX_ABORT_IRQ by writing 1.
MH_RX_ABOR
T_IRQ
21
w
MH RX ABORT IRQ
Clear bit Ni_FUNC_RAW.MH_RX_ABORT_IRQ by writing 1.
MH_STATS_IR
Q
22
w
MH STATS IRQ
Clear bit Ni_FUNC_RAW.MH_STATS_IRQ by writing 1.
PRT_E_ACTIVE 24
w
PRT E ACTIVE
Clear bit Ni_FUNC_RAW.PRT_E_ACTIVE by writing 1.
PRT_BUS_ON
25
w
PRT BUS ON
Clear bit Ni_FUNC_RAW.PRT_BUS_ON by writing 1.
PRT_TX_EVT
26
w
PRT TX EVT
Clear bit Ni_FUNC_RAW.PRT_TX_EVT by writing 1.
PRT_RX_EVT
27
w
PRT RX EVT
Clear bit Ni_FUNC_RAW.PRT_RX_EVT by writing 1.
0
23,
31:28
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4401
v1.1
2025-06-26


22.9.121
Node i error raw event clear register
Writing a 1 to a certain bit position clears the corresponding bit of register Ni_ERR_RAW. Writing a ’0’ has no
effect.
Ni_ERR_CLR (i=0-3)
Offset address:
21A14H+i*2000H
Node i error raw event clear register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TOP_
MUX
_TO_
ERR
0
PRT_
BUS_
OFF
PRT_
E_PA
SSIV
E
PRT_
BUS_
ERR
PRT_
IFF_
RQ
PRT_
RX_D
O
PRT_
TX_D
U
PRT_
USO
S
PRT_
ABO
RTE
D
r
w
r
w
w
w
w
w
w
w
w
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MH_
MEM
_TO_
ERR
MH_
WR_
RESP
_ERR
MH_
RD_
RESP
_ERR
MH_
DMA
_CH_
ERR
MH_
DMA
_TO_
ERR
MH_
DP_T
O_E
RR
MH_
DP_
DO_
ERR
MH_
DP_S
EQ_E
RR
MH_
DP_
PARI
TY_E
RR
MH_
AP_P
ARIT
Y_ER
R
MH_
DESC
_ERR
MH_
REG_
CRC_
ERR
MH_
MEM
_SFT
Y_ER
R
MH_
RX_F
ILTE
R_ER
R
r
w
w
w
w
w
w
w
w
w
w
w
w
w
w
Field
Bits
Type
Description
MH_RX_FILTER
_ERR
0
w
MH RX FILTER ERR
Clear bit Ni_ERR_RAW.MH_RX_FILTER_ERR by writing 1.
MH_MEM_SFT
Y_ERR
1
w
MH MEM SFTY ERR
Clear bit Ni_ERR_RAW.MH_MEM_SFTY_ERR by writing 1.
MH_REG_CRC
_ERR
2
w
MH REG CRC ERR
Clear bit Ni_ERR_RAW.MH_REG_CRC_ERR by writing 1.
MH_DESC_ER
R
3
w
MH DESC ERR
Clear bit Ni_ERR_RAW.MH_DESC_ERR by writing 1.
MH_AP_PARIT
Y_ERR
4
w
MH AP PARITY ERR
Clear bit Ni_ERR_RAW.MH_AP_PARITY_ERR by writing 1.
MH_DP_PARIT
Y_ERR
5
w
MH DP PARITY ERR
Clear bit Ni_ERR_RAW.MH_DP_PARITY_ERR by writing 1.
MH_DP_SEQ_
ERR
6
w
MH DP SEQ ERR
Clear bit Ni_ERR_RAW.MH_DP_SEQ_ERR by writing 1.
MH_DP_DO_E
RR
7
w
MH DP DO ERR
Clear bit Ni_ERR_RAW.MH_DP_DO_ERR by writing 1.
MH_DP_TO_E
RR
8
w
MH DP TO ERR
Clear bit Ni_ERR_RAW.MH_DP_TO_ERR by writing 1.
MH_DMA_TO_
ERR
9
w
MH DMA TO ERR
Clear bit Ni_ERR_RAW.MH_DMA_TO_ERR by writing 1.
MH_DMA_CH_
ERR
10
w
MH DMA CH ERR
Clear bit Ni_ERR_RAW.MH_DMA_CH_ERR by writing 1.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4402
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_RD_RESP
_ERR
11
w
MH RD RESP ERR
Clear bit Ni_ERR_RAW.MH_RD_RESP_ERR by writing 1.
MH_WR_RESP
_ERR
12
w
MH WR RESP ERR
Clear bit Ni_ERR_RAW.MH_WR_RESP_ERR by writing 1.
MH_MEM_TO_
ERR
13
w
MH MEM TO ERR
Clear bit Ni_ERR_RAW.MH_MEM_TO_ERR by writing 1.
PRT_ABORTED 16
w
PRT ABORTED
Clear bit Ni_ERR_RAW.PRT_ABORTED by writing 1.
PRT_USOS
17
w
PRT USOS
Clear bit Ni_ERR_RAW.PRT_USOS by writing 1.
PRT_TX_DU
18
w
PRT TX DU
Clear bit Ni_ERR_RAW.PRT_TX_DU by writing 1.
PRT_RX_DO
19
w
PRT RX DO
Clear bit Ni_ERR_RAW.PRT_RX_DO by writing 1.
PRT_IFF_RQ
20
w
PRT IFF RQ
Clear bit Ni_ERR_RAW.PRT_IFF_RQ by writing 1.
PRT_BUS_ERR 21
w
PRT BUS ERR
Clear bit Ni_ERR_RAW.PRT_BUS_ERR by writing 1.
PRT_E_PASSIV
E
22
w
PRT E PASSIVE
Clear bit Ni_ERR_RAW.PRT_E_PASSIVE by writing 1.
PRT_BUS_OFF 23
w
PRT BUS OFF
Clear bit Ni_ERR_RAW.PRT_BUS_OFF by writing 1.
TOP_MUX_TO
_ERR
28
w
TOP MUX TO ERR
Clear bit Ni_ERR_RAW.TOP_MUX_TO_ERR by writing 1.
0
15:14,
27:24,
31:29
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.122
Node i safety raw event clear register
Writing a 1 to a certain bit position clears the corresponding bit of register Ni_SAFETY_RAW. Writing a ’0’ has no
effect.
Ni_SAFETY_CLR (i=0-3)
Offset address:
21A18H+i*2000H
Node i safety raw event clear register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4403
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TOP_
MUX
_TO_
ERR
0
PRT_
BUS_
OFF
PRT_
E_PA
SSIV
E
PRT_
BUS_
ERR
PRT_
IFF_
RQ
PRT_
RX_D
O
PRT_
TX_D
U
PRT_
USO
S
PRT_
ABO
RTE
D
r
w
r
w
w
w
w
w
w
w
w
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MH_
MEM
_TO_
ERR
MH_
WR_
RESP
_ERR
MH_
RD_
RESP
_ERR
MH_
DMA
_CH_
ERR
MH_
DMA
_TO_
ERR
MH_
DP_T
O_E
RR
MH_
DP_
DO_
ERR
MH_
DP_S
EQ_E
RR
MH_
DP_
PARI
TY_E
RR
MH_
AP_P
ARIT
Y_ER
R
MH_
DESC
_ERR
MH_
REG_
CRC_
ERR
MH_
MEM
_SFT
Y_ER
R
MH_
RX_F
ILTE
R_ER
R
r
w
w
w
w
w
w
w
w
w
w
w
w
w
w
Field
Bits
Type
Description
MH_RX_FILTER
_ERR
0
w
MH RX FILTER ERR
Clear bit Ni_SAFETY_RAW.MH_RX_FILTER_ERR by writing 1.
MH_MEM_SFT
Y_ERR
1
w
MH MEM SFTY ERR
Clear bit Ni_SAFETY_RAW.MH_MEM_SFTY_ERR by writing 1.
MH_REG_CRC
_ERR
2
w
MH REG CRC ERR
Clear bit Ni_SAFETY_RAW.MH_REG_CRC_ERR by writing 1.
MH_DESC_ER
R
3
w
MH DESC ERR
Clear bit Ni_SAFETY_RAW.MH_DESC_ERR by writing 1.
MH_AP_PARIT
Y_ERR
4
w
MH AP PARITY ERR
Clear bit Ni_SAFETY_RAW.MH_AP_PARITY_ERR by writing 1.
MH_DP_PARIT
Y_ERR
5
w
MH DP PARITY ERR
Clear bit Ni_SAFETY_RAW.MH_DP_PARITY_ERR by writing 1.
MH_DP_SEQ_
ERR
6
w
MH DP SEQ ERR
Clear bit Ni_SAFETY_RAW.MH_DP_SEQ_ERR by writing 1.
MH_DP_DO_E
RR
7
w
MH DP DO ERR
Clear bit Ni_SAFETY_RAW.MH_DP_DO_ERR by writing 1.
MH_DP_TO_E
RR
8
w
MH DP TO ERR
Clear bit Ni_SAFETY_RAW.MH_DP_TO_ERR by writing 1.
MH_DMA_TO_
ERR
9
w
MH DMA TO ERR
Clear bit Ni_SAFETY_RAW.MH_DMA_TO_ERR by writing 1.
MH_DMA_CH_
ERR
10
w
MH DMA CH ERR
Clear bit Ni_SAFETY_RAW.MH_DMA_CH_ERR by writing 1.
MH_RD_RESP
_ERR
11
w
MH RD RESP ERR
Clear bit Ni_SAFETY_RAW.MH_RD_RESP_ERR by writing 1.
MH_WR_RESP
_ERR
12
w
MH WR RESP ERR
Clear bit Ni_SAFETY_RAW.MH_WR_RESP_ERR by writing 1.
MH_MEM_TO_
ERR
13
w
MH MEM TO ERR
Clear bit Ni_SAFETY_RAW.MH_MEM_TO_ERR by writing 1.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4404
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
PRT_ABORTED 16
w
PRT ABORTED
Clear bit Ni_SAFETY_RAW.PRT_ABORTED by writing 1.
PRT_USOS
17
w
PRT USOS
Clear bit Ni_SAFETY_RAW.PRT_USOS by writing 1.
PRT_TX_DU
18
w
PRT TX DU
Clear bit Ni_SAFETY_RAW.PRT_TX_DU by writing 1.
PRT_RX_DO
19
w
PRT RX DO
Clear bit Ni_SAFETY_RAW.PRT_RX_DO by writing 1.
PRT_IFF_RQ
20
w
PRT IFF RQ
Clear bit Ni_SAFETY_RAW.PRT_IFF_RQ by writing 1.
PRT_BUS_ERR 21
w
PRT BUS ERR
Clear bit Ni_SAFETY_RAW.PRT_BUS_ERR by writing 1.
PRT_E_PASSIV
E
22
w
PRT E PASSIVE
Clear bit Ni_SAFETY_RAW.PRT_E_PASSIVE by writing 1.
PRT_BUS_OFF 23
w
PRT BUS OFF
Clear bit Ni_SAFETY_RAW.PRT_BUS_OFF by writing 1.
TOP_MUX_TO
_ERR
28
w
TOP MUX TO ERR
Clear bit Ni_SAFETY_RAW.TOP_MUX_TO_ERR by writing 1.
0
15:14,
27:24,
31:29
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.123
Node i functional raw event enable register
Any bit in the Ni_FUNC_ENA register enables the corresponding bit in the Ni_FUNC_RAW to trigger the interrupt
line FUNC_INT. The interrupt line gets active high, when at least one RAW/ENA pair is 1, e.g.
Ni_FUNC_RAW.MH_TX_FQ_IRQ = Ni_FUNC_ENA.MH_TX_FQ_IRQ = 1
Ni_FUNC_ENA (i=0-3)
Offset address:
21A20H+i*2000H
Node i functional raw event enable register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
PRT_
RX_E
VT
PRT_
TX_E
VT
PRT_
BUS_
ON
PRT_
E_AC
TIVE
0
MH_
STAT
S_IR
Q
MH_
RX_A
BOR
T_IR
Q
MH_
TX_A
BOR
T_IR
Q
MH_
TX_F
ILTE
R_IR
Q
MH_
RX_F
ILTE
R_IR
Q
MH_
STO
P_IR
Q
MH_
TX_P
Q_IR
Q
r
rw
rw
rw
rw
r
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
MH_R
X_FQ
7_IR
Q
MH_
RX_F
Q6_I
RQ
MH_
RX_F
Q5_I
RQ
MH_
RX_F
Q4_I
RQ
MH_
RX_F
Q3_I
RQ
MH_
RX_F
Q2_I
RQ
MH_
RX_F
Q1_I
RQ
MH_
RX_F
Q0_I
RQ
MH_
TX_F
Q7_I
RQ
MH_
TX_F
Q6_I
RQ
MH_
TX_F
Q5_I
RQ
MH_
TX_F
Q4_I
RQ
MH_
TX_F
Q3_I
RQ
MH_
TX_F
Q2_I
RQ
MH_
TX_F
Q1_I
RQ
MH_
TX_F
Q0_I
RQ
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4405
v1.1
2025-06-26


Field
Bits
Type
Description
MH_TX_FQ0_I
RQ
0
rw
MH TX FQ0 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ0_IRQ to activate FUNC_INT.
MH_TX_FQ1_I
RQ
1
rw
MH TX FQ1 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ1_IRQ to activate FUNC_INT.
MH_TX_FQ2_I
RQ
2
rw
MH TX FQ2 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ2_IRQ to activate FUNC_INT.
MH_TX_FQ3_I
RQ
3
rw
MH TX FQ3 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ3_IRQ to activate FUNC_INT.
MH_TX_FQ4_I
RQ
4
rw
MH TX FQ4 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ4_IRQ to activate FUNC_INT.
MH_TX_FQ5_I
RQ
5
rw
MH TX FQ5 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ5_IRQ to activate FUNC_INT.
MH_TX_FQ6_I
RQ
6
rw
MH TX FQ6 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ6_IRQ to activate FUNC_INT.
MH_TX_FQ7_I
RQ
7
rw
MH TX FQ7 IRQ
Enable Ni_FUNC_RAW.MH_TX_FQ7_IRQ to activate FUNC_INT.
MH_RX_FQ0_I
RQ
8
rw
MH RX FQ0 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ0_IRQ to activate FUNC_INT.
MH_RX_FQ1_I
RQ
9
rw
MH RX FQ1 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ1_IRQ to activate FUNC_INT.
MH_RX_FQ2_I
RQ
10
rw
MH RX FQ2 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ2_IRQ to activate FUNC_INT.
MH_RX_FQ3_I
RQ
11
rw
MH RX FQ3 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ3_IRQ to activate FUNC_INT.
MH_RX_FQ4_I
RQ
12
rw
MH RX FQ4 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ4_IRQ to activate FUNC_INT.
MH_RX_FQ5_I
RQ
13
rw
MH RX FQ5 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ5_IRQ to activate FUNC_INT.
MH_RX_FQ6_I
RQ
14
rw
MH RX FQ6 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ6_IRQ to activate FUNC_INT.
MH_RX_FQ7_I
RQ
15
rw
MH RX FQ7 IRQ
Enable Ni_FUNC_RAW.MH_RX_FQ7_IRQ to activate FUNC_INT.
MH_TX_PQ_IR
Q
16
rw
MH TX PQ IRQ
Enable Ni_FUNC_RAW.MH_TX_PQ_IRQ to activate FUNC_INT.
MH_STOP_IRQ 17
rw
MH STOP IRQ
Enable Ni_FUNC_RAW.MH_STOP_IRQ to activate FUNC_INT.
MH_RX_FILTER
_IRQ
18
rw
MH RX FILTER IRQ
Enable Ni_FUNC_RAW.MH_RX_FILTER_IRQ to activate FUNC_INT.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4406
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_TX_FILTER
_IRQ
19
rw
MH TX FILTER IRQ
Enable Ni_FUNC_RAW.MH_TX_FILTER_IRQ to activate FUNC_INT.
MH_TX_ABOR
T_IRQ
20
rw
MH TX ABORT IRQ
Enable Ni_FUNC_RAW.MH_TX_ABORT_IRQ to activate FUNC_INT.
MH_RX_ABOR
T_IRQ
21
rw
MH RX ABORT IRQ
Enable Ni_FUNC_RAW.MH_RX_ABORT_IRQ to activate FUNC_INT.
MH_STATS_IR
Q
22
rw
MH STATS IRQ
Enable Ni_FUNC_RAW.MH_STATS_IRQ to activate FUNC_INT.
PRT_E_ACTIVE 24
rw
PRT E ACTIVE
Enable Ni_FUNC_RAW.PRT_E_ACTIVE to activate FUNC_INT.
PRT_BUS_ON
25
rw
PRT BUS ON
Enable Ni_FUNC_RAW.PRT_BUS_ON to activate FUNC_INT.
PRT_TX_EVT
26
rw
PRT TX EVT
Enable Ni_FUNC_RAW.PRT_TX_EVT to activate FUNC_INT.
PRT_RX_EVT
27
rw
PRT RX EVT
Enable Ni_FUNC_RAW.PRT_RX_EVT to activate FUNC_INT.
0
23,
31:28
r
Reserved
Read as 0; should be written with 0.
22.9.124
Node i error raw event enable register
Any bit in the Ni_ERR_ENA register enables the corresponding bit in the Ni_ERR_RAW to trigger the interrupt
line ERR_INT. The interrupt line gets active high, when at least one RAW/ENA pair is 1, e.g.
Ni_ERR_RAW.MH_TX_FQ_IRQ = Ni_ERR_ENA.MH_TX_FQ_IRQ = 1
Ni_ERR_ENA (i=0-3)
Offset address:
21A24H+i*2000H
Node i error raw event enable register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TOP_
MUX
_TO_
ERR
0
PRT_
BUS_
OFF
PRT_
E_PA
SSIV
E
PRT_
BUS_
ERR
PRT_
IFF_
RQ
PRT_
RX_D
O
PRT_
TX_D
U
PRT_
USO
S
PRT_
ABO
RTE
D
r
rw
r
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MH_
MEM
_TO_
ERR
MH_
WR_
RESP
_ERR
MH_
RD_
RESP
_ERR
MH_
DMA
_CH_
ERR
MH_
DMA
_TO_
ERR
MH_
DP_T
O_E
RR
MH_
DP_
DO_
ERR
MH_
DP_S
EQ_E
RR
MH_
DP_
PARI
TY_E
RR
MH_
AP_P
ARIT
Y_ER
R
MH_
DESC
_ERR
MH_
REG_
CRC_
ERR
MH_
MEM
_SFT
Y_ER
R
MH_
RX_F
ILTE
R_ER
R
r
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4407
v1.1
2025-06-26


Field
Bits
Type
Description
MH_RX_FILTER
_ERR
0
rw
MH RX FILTER ERR
Enable Ni_ERR_RAW.MH_RX_FILTER_ERR to activate ERR_INT.
MH_MEM_SFT
Y_ERR
1
rw
MH MEM SFTY ERR
Enable Ni_ERR_RAW.MH_MEM_SFTY_ERR to activate ERR_INT.
MH_REG_CRC
_ERR
2
rw
MH REG CRC ERR
Enable Ni_ERR_RAW.MH_REG_CRC_ERR to activate ERR_INT.
MH_DESC_ER
R
3
rw
MH DESC ERR
Enable Ni_ERR_RAW.MH_DESC_ERR to activate ERR_INT.
MH_AP_PARIT
Y_ERR
4
rw
MH AP PARITY ERR
Enable Ni_ERR_RAW.MH_AP_PARITY_ERR to activate ERR_INT.
MH_DP_PARIT
Y_ERR
5
rw
MH DP PARITY ERR
Enable Ni_ERR_RAW.MH_DP_PARITY_ERR to activate ERR_INT.
MH_DP_SEQ_
ERR
6
rw
MH DP SEQ ERR
Enable Ni_ERR_RAW.MH_DP_SEQ_ERR to activate ERR_INT.
MH_DP_DO_E
RR
7
rw
MH DP DO ERR
Enable Ni_ERR_RAW.MH_DP_DO_ERR to activate ERR_INT.
MH_DP_TO_E
RR
8
rw
MH DP TO ERR
Enable Ni_ERR_RAW.MH_DP_TO_ERR to activate ERR_INT.
MH_DMA_TO_
ERR
9
rw
MH DMA TO ERR
Enable Ni_ERR_RAW.MH_DMA_TO_ERR to activate ERR_INT.
MH_DMA_CH_
ERR
10
rw
MH DMA CH ERR
Enable Ni_ERR_RAW.MH_DMA_CH_ERR to activate ERR_INT.
MH_RD_RESP
_ERR
11
rw
MH RD RESP ERR
Enable Ni_ERR_RAW.MH_RD_RESP_ERR to activate ERR_INT.
MH_WR_RESP
_ERR
12
rw
MH WR RESP ERR
Enable Ni_ERR_RAW.MH_WR_RESP_ERR to activate ERR_INT.
MH_MEM_TO_
ERR
13
rw
MH MEM TO ERR
Enable Ni_ERR_RAW.MH_MEM_TO_ERR to activate ERR_INT.
PRT_ABORTED 16
rw
PRT ABORTED
Enable Ni_ERR_RAW.PRT_ABORTED to activate ERR_INT.
PRT_USOS
17
rw
PRT USOS
Enable Ni_ERR_RAW.PRT_USOS to activate ERR_INT.
PRT_TX_DU
18
rw
PRT TX DU
Enable Ni_ERR_RAW.PRT_TX_DU to activate ERR_INT.
PRT_RX_DO
19
rw
PRT RX DO
Enable Ni_ERR_RAW.PRT_RX_DO to activate ERR_INT.
PRT_IFF_RQ
20
rw
PRT IFF RQ
Enable Ni_ERR_RAW.PRT_IFF_RQ to activate ERR_INT.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4408
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
PRT_BUS_ERR 21
rw
PRT BUS ERR
Enable Ni_ERR_RAW.PRT_BUS_ERR to activate ERR_INT.
PRT_E_PASSIV
E
22
rw
PRT E PASSIVE
Enable Ni_ERR_RAW.PRT_E_PASSIVE to activate ERR_INT.
PRT_BUS_OFF 23
rw
PRT BUS OFF
Enable Ni_ERR_RAW.PRT_BUS_OFF to activate ERR_INT.
TOP_MUX_TO
_ERR
28
rw
TOP MUX TO ERR
Enable Ni_ERR_RAW.TOP_MUX_TO_ERR to activate ERR_INT.
0
15:14,
27:24,
31:29
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.125
Node i safety raw event enable register
Any bit in the Ni_SAFETY_ENA register enables the corresponding bit in the Ni_SAFETY_RAW to trigger the
interrupt line SAFETY_INT. The interrupt line gets active high, when at least one RAW/ENA pair is 1, e.g.
Ni_SAFETY_RAW.MH_TX_FQ_IRQ = Ni_SAFETY_ENA.MH_TX_FQ_IRQ = 1
Ni_SAFETY_ENA (i=0-3)
Offset address:
21A28H+i*2000H
Node i safety raw event enable register
Kernel Reset value:
0000 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
TOP_
MUX
_TO_
ERR
0
PRT_
BUS_
OFF
PRT_
E_PA
SSIV
E
PRT_
BUS_
ERR
PRT_
IFF_
RQ
PRT_
RX_D
O
PRT_
TX_D
U
PRT_
USO
S
PRT_
ABO
RTE
D
r
rw
r
rw
rw
rw
rw
rw
rw
rw
rw
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
MH_
MEM
_TO_
ERR
MH_
WR_
RESP
_ERR
MH_
RD_
RESP
_ERR
MH_
DMA
_CH_
ERR
MH_
DMA
_TO_
ERR
MH_
DP_T
O_E
RR
MH_
DP_
DO_
ERR
MH_
DP_S
EQ_E
RR
MH_
DP_
PARI
TY_E
RR
MH_
AP_P
ARIT
Y_ER
R
MH_
DESC
_ERR
MH_
REG_
CRC_
ERR
MH_
MEM
_SFT
Y_ER
R
MH_
RX_F
ILTE
R_ER
R
r
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
rw
Field
Bits
Type
Description
MH_RX_FILTER
_ERR
0
rw
MH RX FILTER ERR
Enable Ni_SAFETY_RAW.MH_RX_FILTER_ERR to activate SAFETY_INT.
MH_MEM_SFT
Y_ERR
1
rw
MH MEM SFTY ERR
Enable Ni_SAFETY_RAW.MH_MEM_SFTY_ERR to activate SAFETY_INT.
MH_REG_CRC
_ERR
2
rw
MH REG CRC ERR
Enable Ni_SAFETY_RAW.MH_REG_CRC_ERR to activate SAFETY_INT.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4409
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MH_DESC_ER
R
3
rw
MH DESC ERR
Enable Ni_SAFETY_RAW.MH_DESC_ERR to activate SAFETY_INT.
MH_AP_PARIT
Y_ERR
4
rw
MH AP PARITY ERR
Enable Ni_SAFETY_RAW.MH_AP_PARITY_ERR to activate SAFETY_INT.
MH_DP_PARIT
Y_ERR
5
rw
MH DP PARITY ERR
Enable Ni_SAFETY_RAW.MH_DP_PARITY_ERR to activate SAFETY_INT.
MH_DP_SEQ_
ERR
6
rw
MH DP SEQ ERR
Enable Ni_SAFETY_RAW.MH_DP_SEQ_ERR to activate SAFETY_INT.
MH_DP_DO_E
RR
7
rw
MH DP DO ERR
Enable Ni_SAFETY_RAW.MH_DP_DO_ERR to activate SAFETY_INT.
MH_DP_TO_E
RR
8
rw
MH DP TO ERR
Enable Ni_SAFETY_RAW.MH_DP_TO_ERR to activate SAFETY_INT.
MH_DMA_TO_
ERR
9
rw
MH DMA TO ERR
Enable Ni_SAFETY_RAW.MH_DMA_TO_ERR to activate SAFETY_INT.
MH_DMA_CH_
ERR
10
rw
MH DMA CH ERR
Enable Ni_SAFETY_RAW.MH_DMA_CH_ERR to activate SAFETY_INT.
MH_RD_RESP
_ERR
11
rw
MH RD RESP ERR
Enable Ni_SAFETY_RAW.MH_RD_RESP_ERR to activate SAFETY_INT.
MH_WR_RESP
_ERR
12
rw
MH WR RESP ERR
Enable Ni_SAFETY_RAW.MH_WR_RESP_ERR to activate SAFETY_INT.
MH_MEM_TO_
ERR
13
rw
MH MEM TO ERR
Enable Ni_SAFETY_RAW.MH_MEM_TO_ERR to activate SAFETY_INT.
PRT_ABORTED 16
rw
PRT ABORTED
Enable Ni_SAFETY_RAW.PRT_ABORTED to activate SAFETY_INT.
PRT_USOS
17
rw
PRT USOS
Enable Ni_SAFETY_RAW.PRT_USOS to activate SAFETY_INT.
PRT_TX_DU
18
rw
PRT TX DU
Enable Ni_SAFETY_RAW.PRT_TX_DU to activate SAFETY_INT.
PRT_RX_DO
19
rw
PRT RX DO
Enable Ni_SAFETY_RAW.PRT_RX_DO to activate SAFETY_INT.
PRT_IFF_RQ
20
rw
PRT IFF RQ
Enable Ni_SAFETY_RAW.PRT_IFF_RQ to activate SAFETY_INT.
PRT_BUS_ERR 21
rw
PRT BUS ERR
Enable Ni_SAFETY_RAW.PRT_BUS_ERR to activate SAFETY_INT.
PRT_E_PASSIV
E
22
rw
PRT E PASSIVE
Enable Ni_SAFETY_RAW.PRT_E_PASSIVE to activate SAFETY_INT.
PRT_BUS_OFF 23
rw
PRT BUS OFF
Enable Ni_SAFETY_RAW.PRT_BUS_OFF to activate SAFETY_INT.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4410
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TOP_MUX_TO
_ERR
28
rw
TOP MUX TO ERR
Enable Ni_SAFETY_RAW.TOP_MUX_TO_ERR to activate SAFETY_INT.
0
15:14,
27:24,
31:29
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.126
Node i IRC configuration register
This register shows the hardware configuration of the IRC concerning the capturing mode of the event inputs.
The IP internal events signals coming from the MH and the PRT require an 'edge sensitive' capturing. That is
why the value of this register is 0x7 and cannot be changed.
Ni_CAPTURING_MODE (i=0-3)
Offset address:
21A30H+i*2000H
Node i IRC configuration register
Kernel Reset value:
0000 0007H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
SAFE
TY
ERR
FUN
C
r
r
r
r
Field
Bits
Type
Description
FUNC
0
r
FUNC
Capturing mode of Ni_FUNC_RAW register. 0 = Level sensitive 1 = Edge
sensitive
ERR
1
r
ERR
Capturing mode of ERR RAW register. 0 = Level sensitive 1 = Edge
sensitive
SAFETY
2
r
SAFETY
Capturing mode of SAFETY RAW register. 0 = Level sensitive 1 = Edge
sensitive
0
31:3
r
Reserved
Read as all 0's; should be written with all 0's.
22.9.127
Node i hardware debug port control register
Ni_HDP (i=0-3)
Offset address:
21A40H+i*2000H
Node i hardware debug port control register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4411
v1.1
2025-06-26


31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
0
r
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
0
HDP
_SEL
r
rw
Field
Bits
Type
Description
HDP_SEL
0
rw
HDP SEL
Select the driver of the Hardware Debug Port. See also chapter HDP. 0 =
Message Handler 1 = Protocol Controller
0
31:1
r
Reserved
Read as all 0's; should be written with all 0's.
22.10
Debug information
Hard suspend
Hard suspend is enabled when OCS.SUS is set to 1B. Upon OCDS suspend trigger, both fCANXL and fCANXLH
clocks are switched off immediately. The status of the suspend state can be monitored through OCS.SUSTA
status bit-field. It is not recommended to use this mode in normal CAN or CAN XL applications, as they are
meant only for debugging of the module.
Soft suspend
Soft suspend in enabled when OCS.SUS is set to 2H. User must ensure that the X_CAN node's protocol controller
and message handler are stopped, before entering the soft suspend mode. Upon OCDS suspend trigger, both
fCANXL and fCANXLH clocks are switched off. The status of the suspend state can be monitored through
OCS.SUSTA status bit-field.
OTGB trigger sets
Each X_CAN proved a set of 16 signals which can be traced using OTGB0/1 bus. X_CAN's HDP is selectable
through Ni_HDP.HDP_SEL bit-field. The X_CAN node which needs to be traced is selectable through
DEBUG_CTL.NODE_SEL bit-field. The OTGB bus 0 or 1 is selected through OCS.TGB bit-field.
Note:
Limitation: "CLK" signals which are part of HDP[15] cannot be traced by user.
22.11
References
1.
ISO 11898-1:2024 CAN Data link layer and physical coding sublayer
2.
AXI4 ARM IHI 0022E (ID022613)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4412
v1.1
2025-06-26


22.12
CANXL revision history
Reference
Description of change(s)
Date range: 2024-08-17 to 2024-11-18
RX FIFO queue in
continuous mode
•
Adding the configuration of register Ni_RX_FQ_RD_ADD_PTn to the
programming instructions for continuous mode
Controller Area Network
XL interface (CANXL),
Feature list, Functional
description, PWME,
References, Feature list,
X_CAN, Feature list,
Functional overview,
Protocol controller,
Functional overview,
Starting and stopping the
module, Node i operating
mode register, Transceiver
interface , TX-SCAN
•
Replacing references to CiA 610-1 and ISO 11898-1:2015 by ISO 11898-1:2024
Controller Area Network XL
interface (CANXL), Feature
list, Protocol controller,
Feature list and Functional
overview
•
Updating the maximum supported CAN XL baudrate from 15 MBit/s to 20
MBit/s
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4413
v1.1
2025-06-26


22.13
TC4Dx CAN-XL information
22.13.1
TC4Dx CANXL configuration
Table 1071
TC4Dx CANXL configuration
Parameter
CANXL0
Number of CANXL nodes (N_NODES)
4
RAM size (in Kbytes)
16
22.13.2
TC4Dx CANXL features
•
Supports 4 CAN XL nodes
•
16 Kbytes of shared configuration RAM
22.13.3
TC4Dx CANXL functional description
In TC4Dx device, the CANXL modules are connected to ComPB bus interface. The CANXL chapter refers to it as
FPI bus.
The following restriction applies for CANXL implementation in TC4Dx
•
Software must ensure that X_CAN node's Message Handler and Protocol Controller are stopped, before
Kernel reset request via KRST or via module group reset trigger (when enabled through
MODULE_RST_CTRLA.GRSTEN bit-field).
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4414
v1.1
2025-06-26


22.13.4
TC4Dx CANXL registers
22.13.4.1
Memory overview tables of CANXL
Table 1072
Memory overview - CANXL (ascending address)
Short name
Long name
Address
CANXL0_RAM
Embedded SRAM for CAN XL nodes configuration
(04000H Byte)
F47C0000H
22.13.4.2
Register address space - CANXL
Table 1073
Registers address space - CANXL
Key: The module name in brackets () indicates a memory section name. Without brackets the reference is to a
functional block.
Module
Base address
End address
Note
CANXL0
F47D0000H
F4FFFFFFH
FPI slave interface for SFR registers
(CANXL0_RAM)
F47C0000H
F47C3FFFH
FPI slave interface for L_MEM
22.13.4.3
Register overview - access mode glossary
Table 1074
Register overview - access mode glossary
Keyword
Description
E
Access protection using PROT register CANXL0_PROTE .
SE
Access protection using PROT register CANXL0_PROTSE .
APU-PM
Protection group consisting of registers CANXL0_MODULE_ACCEN_WRA ,
CANXL0_MODULE_ACCEN_WRB , CANXL0_MODULE_ACCEN_RDA ,
CANXL0_MODULE_ACCEN_RDB , CANXL0_MODULE_ACCEN_VM ,
CANXL0_MODULE_ACCEN_PRS .
PM
Access protection using APU-PM registers.
APU-PNi (i=0-3)
Protection group consisting of registers CANXL0_NODEi_ACCENNODE_WRA ,
CANXL0_NODEi_ACCENNODE_WRB , CANXL0_NODEi_ACCENNODE_RDA ,
CANXL0_NODEi_ACCENNODE_RDB , CANXL0_NODEi_ACCENNODE_VM ,
CANXL0_NODEi_ACCENNODE_PRS .
PNi
Access protection using APU-PNi registers.
U
No access restrictions.
BE
Always returns a Bus Error.
PROT
Access restrictions as defined in the PROT register access rules.
32
Access only when using 32-bit width.
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4415
v1.1
2025-06-26


22.13.4.4
Registers overview - CANXL0 (ascending offset address)
Table 1075
Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_ID
Module Identification
Register
00000H
U
BE
PowerOn Reset
4310
CANXL0_OCS
OCDS Control and Status
Register
00004H
PM
SV, PM
Debug Reset
4310
CANXL0_MODUL
E_CLC
Module Clock Control
Register
00008H
PM
PM, SV, E
Application
Reset
4312
CANXL0_MODUL
E_RST_CTRLA
Module reset control
register A
0000CH
PM
PM, SV, E
Application
Reset
4312
CANXL0_MODUL
E_RST_CTRLB
Module reset control
register B
00010H
PM
PM, SV, E
Application
Reset
4313
CANXL0_MODUL
E_RST_STAT
Module reset status register 00014H
PM
BE
Application
Reset
4314
CANXL0_MODUL
E_ACCEN_WRA
Module Write access enable
register A
00018H
U
SE, SV
Application
Reset
4314
CANXL0_MODUL
E_ACCEN_WRB
Module Write access enable
register B
0001CH
U
SE, SV
Application
Reset
4315
CANXL0_MODUL
E_ACCEN_RDA
Module Read access enable
register A
00020H
U
SE, SV
Application
Reset
4315
CANXL0_MODUL
E_ACCEN_RDB
Module Read access enable
register B
00024H
U
SE, SV
Application
Reset
4316
CANXL0_MODUL
E_ACCEN_VM
Module VM access enable
register
00028H
U
SE, SV
Application
Reset
4316
CANXL0_MODUL
E_ACCEN_PRS
Module PRS access enable
register
0002CH
U
SE, SV
Application
Reset
4317
CANXL0_PROTE
PROT Register Endinit
00038H
U
SV, PROT
Application
Reset
4318
CANXL0_PROTSE PROT Register Safe Endinit
0003CH
U
SV, PROT
Application
Reset
4319
CANXL0_CLKEN
Clock enable
00040H
clk, PM
clk, PM, SV,
E
Application
Reset
4321
CANXL0_NODEi_
RST_CTRLA
(i=0-3)
Node i reset control register
A
00100H+i
*100H
PNi
PNi, SV, E
Application
Reset
4322
CANXL0_NODEi_
RST_CTRLB
(i=0-3)
Node i reset control register
B
00104H+i
*100H
PNi
PNi, SV, E
Application
Reset
4322
CANXL0_NODEi_
RST_STAT
(i=0-3)
Node i reset status register
00108H+i
*100H
PNi
BE
Application
Reset
4323
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4416
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_NODEi_
ACCENNODE_WR
A
(i=0-3)
Node i write access enable
register A
0010CH+
i*100H
U
SE, SV
Application
Reset
4324
CANXL0_NODEi_
ACCENNODE_WR
B
(i=0-3)
Node i write access enable
register B
00110H+i
*100H
U
SE, SV
Application
Reset
4324
CANXL0_NODEi_
ACCENNODE_RD
A
(i=0-3)
Node i read access enable
register A
00114H+i
*100H
U
SE, SV
Application
Reset
4325
CANXL0_NODEi_
ACCENNODE_RD
B
(i=0-3)
Node i read access enable
register B
00118H+i
*100H
U
SE, SV
Application
Reset
4326
CANXL0_NODEi_
ACCENNODE_VM
(i=0-3)
Node i VM access enable
register
0011CH+
i*100H
U
SE, SV
Application
Reset
4326
CANXL0_NODEi_
ACCENNODE_PR
S
(i=0-3)
Node i PRS access enable
register
00120H+i
*100H
U
SE, SV
Application
Reset
4327
CANXL0_NODEi_
ACCENNODE_RG
NLA
(i=0-3)
Node i region lower address
register
00124H+i
*100H
U
SE, SV
Application
Reset
4328
CANXL0_NODEi_
ACCENNODE_RG
NUA
(i=0-3)
Node i region upper
address register
00128H+i
*100H
U
SE, SV
Application
Reset
4328
CANXL0_NODEi_
VMPRSCONFIG
(i=0-3)
Node i VM and PRS
configuration Register
0012CH+
i*100H
U
SE, SV
Application
Reset
4328
CANXL0_NODEi_
PORTCTRL
(i=0-3)
Node i Port Control Register 00130H+i
*100H
PNi
PNi
Kernel Reset
4329
CANXL0_NODEi_
MTI_RAW
(i=0-3)
Node i message transfer
interrupt event register
00134H+i
*100H
PNi
BE
Kernel Reset
4330
CANXL0_NODEi_
MTI_CLR
(i=0-3)
Node i message transfer
interrupt clear register
00138H+i
*100H
PNi
PNi
Kernel Reset
4330
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4417
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_NODEi_
MTI_ENA
(i=0-3)
Node i message transfer
interrupt enable register
0013CH+
i*100H
PNi
PNi
Kernel Reset
4331
CANXL0_DEBUG_
CTL
Debug control register
10004H
PM
PM
Kernel Reset
4332
CANXL0_Ni_TS_C
TL
(i=0-3)
Node i timestamp control
20010H+i
*2000H
PNi
PNi
Kernel Reset
4332
CANXL0_Ni_TS_C
LOCK_CTL
(i=0-3)
Node i timestamp clock
control
20014H+i
*2000H
PNi
PNi
Kernel Reset
4333
CANXL0_Ni_TS_C
MD
(i=0-3)
Node i timestamp
command
20020H+i
*2000H
PNi
PNi
Kernel Reset
4334
CANXL0_Ni_TS_C
NT_LO
(i=0-3)
Node i timestamp counter
LSBs
20030H+i
*2000H
PNi
BE
Kernel Reset
4334
CANXL0_Ni_TS_C
NT_HI
(i=0-3)
Node i timestamp counter
MSBs
20034H+i
*2000H
PNi
BE
Kernel Reset
4335
CANXL0_Ni_VER
SION
(i=0-3)
Node i release
identification register
21000H+i
*2000H
PNi, 32
BE
Kernel Reset
4335
CANXL0_Ni_MH_
CTRL
(i=0-3)
Node i message handler
control register
21004H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4336
CANXL0_Ni_MH_
CFG
(i=0-3)
Node i message handler
configuration register
21008H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4337
CANXL0_Ni_MH_
STS
(i=0-3)
Node i message handler
status register
2100CH+
i*2000H
PNi, 32
BE
Kernel Reset
4338
CANXL0_Ni_MH_
SFTY_CFG
(i=0-3)
Node i message handler
safety configuration
register
21010H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4339
CANXL0_Ni_MH_
SFTY_CTRL
(i=0-3)
Node i message handler
safety control register
21014H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4340
CANXL0_Ni_RX_F
ILTER_MEM_ADD
(i=0-3)
Node i RX filter base
address register
21018H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4341
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4418
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_Ni_TX_
DESC_MEM_ADD
(i=0-3)
Node i TX descriptor base
address register
2101CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4342
CANXL0_Ni_AXI_
ADD_EXT
(i=0-3)
Node i AXI address
extension register
21020H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4342
CANXL0_Ni_AXI_
PARAMS
(i=0-3)
Node i AXI parameter
register
21024H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4343
CANXL0_Ni_MH_
LOCK
(i=0-3)
Node i message handler
lock register
21028H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4343
CANXL0_Ni_TX_
DESC_ADD_PT
(i=0-3)
Node i TX descriptor
current address pointer
register
21100H+i
*2000H
PNi, 32
BE
Kernel Reset
4344
CANXL0_Ni_TX_S
TATISTICS
(i=0-3)
Node i TX message counter
register
21104H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4344
CANXL0_Ni_TX_F
Q_STS0
(i=0-3)
Node i TX FIFO queue status
register
21108H+i
*2000H
PNi, 32
BE
Kernel Reset
4345
CANXL0_Ni_TX_F
Q_STS1
(i=0-3)
Node i TX FIFO queue status
register
2110CH+
i*2000H
PNi, 32
BE
Kernel Reset
4346
CANXL0_Ni_TX_F
Q_CTRL0
(i=0-3)
Node i TX FIFO queue
control register 0
21110H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4346
CANXL0_Ni_TX_F
Q_CTRL1
(i=0-3)
Node i TX FIFO queue
control register 1
21114H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4347
CANXL0_Ni_TX_F
Q_CTRL2
(i=0-3)
Node i TX FIFO queue
control register 2
21118H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4348
CANXL0_Ni_TX_F
Q_ADD_PTr
(i=0-3;r=0-7)
Node i TX FIFO queue
r current address pointer
register
21120H+i
*2000H+r
*10H
PNi, 32
BE
Kernel Reset
4348
CANXL0_Ni_TX_F
Q_START_ADDr
(i=0-3;r=0-7)
Node i TX FIFO queue r start
address register
21124H+i
*2000H+r
*10H
PNi, 32
PNi, 32
Kernel Reset
4349
CANXL0_Ni_TX_F
Q_SIZEr
(i=0-3;r=0-7)
Node i TX FIFO queue r size
register
21128H+i
*2000H+r
*10H
PNi, 32
PNi, 32
Kernel Reset
4349
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4419
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_Ni_TX_P
Q_STS0
(i=0-3)
Node i TX priority queue
status register
21300H+i
*2000H
PNi, 32
BE
Kernel Reset
4350
CANXL0_Ni_TX_P
Q_STS1
(i=0-3)
Node i TX priority queue
status register
21304H+i
*2000H
PNi, 32
BE
Kernel Reset
4350
CANXL0_Ni_TX_P
Q_CTRL0
(i=0-3)
Node i TX priority queue
control register 0
2130CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4351
CANXL0_Ni_TX_P
Q_CTRL1
(i=0-3)
Node i TX priority queue
control register 1
21310H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4351
CANXL0_Ni_TX_P
Q_CTRL2
(i=0-3)
Node i TX priority queue
control register 2
21314H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4352
CANXL0_Ni_TX_P
Q_START_ADD
(i=0-3)
Node i TX priority queue
start address
21318H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4352
CANXL0_Ni_RX_
DESC_ADD_PT
(i=0-3)
Node i RX descriptor
current address pointer
21400H+i
*2000H
PNi, 32
BE
Kernel Reset
4353
CANXL0_Ni_RX_S
TATISTICS
(i=0-3)
Node i RX message counter
register
21404H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4353
CANXL0_Ni_RX_F
Q_STS0
(i=0-3)
Node i RX FIFO queue status
register 0
21408H+i
*2000H
PNi, 32
BE
Kernel Reset
4354
CANXL0_Ni_RX_F
Q_STS1
(i=0-3)
Node i RX FIFO queue status
register 1
2140CH+
i*2000H
PNi, 32
BE
Kernel Reset
4355
CANXL0_Ni_RX_F
Q_STS2
(i=0-3)
Node i RX FIFO queue status
register 2
21410H+i
*2000H
PNi, 32
BE
Kernel Reset
4355
CANXL0_Ni_RX_F
Q_CTRL0
(i=0-3)
Node i RX FIFO queue
control register 0
21414H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4356
CANXL0_Ni_RX_F
Q_CTRL1
(i=0-3)
Node i RX FIFO queue
control register 1
21418H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4356
CANXL0_Ni_RX_F
Q_CTRL2
(i=0-3)
Node i RX FIFO queue
control register 2
2141CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4357
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4420
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_Ni_RX_F
Q_ADD_PTs
(i=0-3;s=0-7)
Node i RX FIFO queue s
current address pointer
21420H+i
*2000H+
s*18H
PNi, 32
BE
Kernel Reset
4357
CANXL0_Ni_RX_F
Q_START_ADDs
(i=0-3;s=0-7)
Node i RX FIFO queue s link
list start address
21424H+i
*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4358
CANXL0_Ni_RX_F
Q_SIZEs
(i=0-3;s=0-7)
Node i RX FIFO queue s link
list and data container size
21428H+i
*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4358
CANXL0_Ni_RX_F
Q_DC_START_AD
Ds
(i=0-3;s=0-7)
Node i RX FIFO queue s data
container start address
2142CH+
i*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4359
CANXL0_Ni_RX_F
Q_RD_ADD_PTs
(i=0-3;s=0-7)
Node i RX FIFO queue s read
address pointer
21430H+i
*2000H+
s*18H
PNi, 32
PNi, 32
Kernel Reset
4360
CANXL0_Ni_TX_F
ILTER_CTRL0
(i=0-3)
Node i TX filter control
register 0
21600H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4360
CANXL0_Ni_TX_F
ILTER_CTRL1
(i=0-3)
Node i TX filter control
register 1
21604H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4361
CANXL0_Ni_TX_F
ILTER_REFVALt
(i=0-3;t=0-3)
Node i TX filter reference
value register t
21608H+i
*2000H+t
*4
PNi, 32
SV, PNi, 32
Kernel Reset
4362
CANXL0_Ni_RX_F
ILTER_CTRL
(i=0-3)
Node i RX filter control
register
21680H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4363
CANXL0_Ni_TX_F
Q_INT_STS
(i=0-3)
Node i TX FIFO queue
interrupt status register
21700H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4364
CANXL0_Ni_RX_F
Q_INT_STS
(i=0-3)
Node i RX FIFO queue
interrupt status register
21704H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4365
CANXL0_Ni_TX_P
Q_INT_STS0
(i=0-3)
Node i TX priority queue
interrupt status register 0
21708H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4365
CANXL0_Ni_TX_P
Q_INT_STS1
(i=0-3)
Node i TX priority queue
interrupt status register 1
2170CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4366
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4421
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_Ni_STAT
S_INT_STS
(i=0-3)
Node i statistics interrupt
status register
21710H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4366
CANXL0_Ni_ERR
_INT_STS
(i=0-3)
Node i error interrupt status
register
21714H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4367
CANXL0_Ni_SFTY
_INT_STS
(i=0-3)
Node i safety interrupt
status register
21718H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4368
CANXL0_Ni_AXI_
ERR_INFO
(i=0-3)
Node i DMA error
information
2171CH+
i*2000H
PNi, 32
BE
Kernel Reset
4369
CANXL0_Ni_DES
C_ERR_INFO0
(i=0-3)
Node i descriptor error
information 0
21720H+i
*2000H
PNi, 32
BE
Kernel Reset
4370
CANXL0_Ni_DES
C_ERR_INFO1
(i=0-3)
Node i descriptor error
information 1
21724H+i
*2000H
PNi, 32
BE
Kernel Reset
4371
CANXL0_Ni_TX_F
ILTER_ERR_INFO
(i=0-3)
Node i TX filter error
information
21728H+i
*2000H
PNi, 32
BE
Kernel Reset
4371
CANXL0_Ni_DEB
UG_TEST_CTRL
(i=0-3)
Node i debug control
register
21800H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4372
CANXL0_Ni_INT_
TEST0
(i=0-3)
Node i interrupt test
register 0
21804H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4373
CANXL0_Ni_INT_
TEST1
(i=0-3)
Node i interrupt test
register 1
21808H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4373
CANXL0_Ni_TX_S
CAN_FC
(i=0-3)
Node i TX-SCAN first
candidates register
21810H+i
*2000H
PNi, 32
BE
Kernel Reset
4376
CANXL0_Ni_TX_S
CAN_BC
(i=0-3)
Node i TX-SCAN best
candidates register
21814H+i
*2000H
PNi, 32
BE
Kernel Reset
4377
CANXL0_Ni_TX_F
Q_DESC_VALID
(i=0-3)
Node i valid TX FIFO queue
descriptors in local memory
21818H+i
*2000H
PNi, 32
BE
Kernel Reset
4378
CANXL0_Ni_TX_P
Q_DESC_VALID
(i=0-3)
Node i valid TX priority
queue descriptors in local
memory
2181CH+
i*2000H
PNi, 32
BE
Kernel Reset
4379
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4422
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_Ni_CRC
_CTRL
(i=0-3)
Node i CRC control register
21880H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4379
CANXL0_Ni_CRC
_REG
(i=0-3)
Node i CRC register
21884H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4380
CANXL0_Ni_END
N
(i=0-3)
Node i endianness test
register
21900H+i
*2000H
PNi, 32
BE
Kernel Reset
4380
CANXL0_Ni_PRE
L
(i=0-3)
Node i PRT release
identification register
21904H+i
*2000H
PNi, 32
BE
Kernel Reset
4380
CANXL0_Ni_STAT
(i=0-3)
Node i PRT status register
21908H+i
*2000H
PNi, 32
BE
Kernel Reset
4381
CANXL0_Ni_EVN
T
(i=0-3)
Node i event status flags
register
21920H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4383
CANXL0_Ni_LOC
K
(i=0-3)
Node i unlock sequence
register
21940H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4384
CANXL0_Ni_CTR
L
(i=0-3)
Node i control register
21944H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4385
CANXL0_Ni_FIMC
(i=0-3)
Node i fault injection
module control register
21948H+i
*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4386
CANXL0_Ni_TEST
(i=0-3)
Node i hardware test
functions register
2194CH+
i*2000H
PNi, 32
SV, PNi, 32
Kernel Reset
4386
CANXL0_Ni_MOD
E
(i=0-3)
Node i operating mode
register
21960H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4388
CANXL0_Ni_NBT
P
(i=0-3)
Node i arbitration phase
nominal bit timing register
21964H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4389
CANXL0_Ni_DBT
P
(i=0-3)
Node i CAN FD data phase
bit timing register
21968H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4390
CANXL0_Ni_XBT
P
(i=0-3)
Node i CAN XL data phase
bit timing register
2196CH+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4391
(table continues...)
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4423
v1.1
2025-06-26


Table 1075
(continued) Registers overview - CANXL0 (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CANXL0_Ni_PCF
G
(i=0-3)
Node i PWME configuration
register
21970H+i
*2000H
PNi, 32
PNi, 32
Kernel Reset
4392
CANXL0_Ni_FUN
C_RAW
(i=0-3)
Node i functional raw event
status register
21A00H+
i*2000H
PNi, 32
BE
Kernel Reset
4393
CANXL0_Ni_ERR
_RAW
(i=0-3)
Node i error raw event
status register
21A04H+
i*2000H
PNi, 32
BE
Kernel Reset
4395
CANXL0_Ni_SAFE
TY_RAW
(i=0-3)
Node i safety raw event
status register
21A08H+
i*2000H
PNi, 32
BE
Kernel Reset
4397
CANXL0_Ni_FUN
C_CLR
(i=0-3)
Node i functional raw event
clear register
21A10H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4400
CANXL0_Ni_ERR
_CLR
(i=0-3)
Node i error raw event clear
register
21A14H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4402
CANXL0_Ni_SAFE
TY_CLR
(i=0-3)
Node i safety raw event
clear register
21A18H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4403
CANXL0_Ni_FUN
C_ENA
(i=0-3)
Node i functional raw event
enable register
21A20H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4405
CANXL0_Ni_ERR
_ENA
(i=0-3)
Node i error raw event
enable register
21A24H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4407
CANXL0_Ni_SAFE
TY_ENA
(i=0-3)
Node i safety raw event
enable register
21A28H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4409
CANXL0_Ni_CAP
TURING_MODE
(i=0-3)
Node i IRC configuration
register
21A30H+
i*2000H
PNi, 32
BE
Kernel Reset
4411
CANXL0_Ni_HDP
(i=0-3)
Node i hardware debug
port control register
21A40H+
i*2000H
PNi, 32
PNi, 32
Kernel Reset
4411
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4424
v1.1
2025-06-26


22.13.4.5
Device specific registers
There are no device specific register changes.
22.13.5
TC4Dx CANXL connectivity
The table below lists interfaces to and from this functional block to other blocks in the device.
Table 1076
List of CANXL interface signals
Interface signals
I/O
Description
CLOCK_CANXL_fCANXL
In
CANXL asynchronous clock input
CLOCK_CANXL_fCANXLH
In
CANXL synchronous clock input
CPU0_CANXL_STM_TRIG
In
CPU0 VM1 STM Service Request 0 trigger input
EGTM_CANXL_TRIG_IN[3:0]
In
eGTM trigger input
PORTS_CANXL_node[3:0]_RXD[7:0]
In
CANXL node i receive inputs
CANXL_PORTS_node[3:0]_TXD
Out
CANXL node i transmit output
CANXL_IR_FUNC_INT[3:0]
Out
CANXL Functional events Service Request
CANXL_IR_ERR_INT[3:0]
Out
CANXL Error events Service Request
CANXL_IR_SAFETY_INT[3:0]
Out
CANXL Safety events Service Request
CANXL_EGTM_MTI_TRIG[3:0]
Out
CANXL Miscellaneous events Service Request to eGTM
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4425
v1.1
2025-06-26


22.13.6
TC4Dx CANXL revision history
 
 
AURIX™ TC4Dx user manual 
22  Controller Area Network XL interface (CANXL)
Reference manual
4426
v1.1
2025-06-26
