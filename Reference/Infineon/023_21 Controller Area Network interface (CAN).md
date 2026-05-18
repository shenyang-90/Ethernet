# 21 Controller Area Network interface (CAN)

21
Controller Area Network interface (CAN)
The CAN module provides a communication interface according to the ISO 11898-1 standard, supporting both
classical CAN and CAN FD communication. It provides the CAN Routing Engine as an extension which is used
to route data within different CAN nodes based on the CAN-ID, and it also provides a virtual host interface to
the RxFIFOs and TxQueues/TxFIFO of CAN nodes. The CAN module in this document is referred as MCMCAN. The
CAN nodes in this document is referred as M_CAN.
21.1
Feature list
•
Compatibility to ISO 11898-1
•
CAN Error Logging
•
AUTOSAR optimized
•
SAE J1939 optimized
•
Direct Message RAM access for Host CPU
•
Multiple M_CANs share the same Message RAM
•
Maskable module interrupts
•
Power-down support
•
Debug on CAN support
•
CAN Routing Engine (CRE)
-
Abstraction of RxFIFO, TxFIFO/TxQueue operation with virtual buffers
-
Hardware accelerated CAN to CAN routing within the same MCMCAN module
-
Assists Data Routing Engine (DRE) to perform hardware accelerated
-
CAN to CAN routing between different MCMCAN Modules
-
CAN to Ethernet (in IEEE 1722 ACF frame) routing
-
CAN to a user-configurable System RAM location transfer
-
CAN PDU to a user configurable system RAM location transfer
-
Consists of a measurement unit for Intrusion Detection (IDMU)
21.2
Functional overview
This figure gives an overview of the MCMCAN block.
IR
fMCAN
Port
Control
.   
.   
.
Pin x.y
node0_RXD 
[7:0]
MCMCAN
Message
RAM
User Interface
CRE
MRAM 
Access Arbiter
FPI
SRC_CANINTx
(x=0-15)
.   
.   
.
fMCANH  
GTM/
eGTM
GTM / 
eGTM_Ni_TRIG 
(i=0-3)
.   
.
M_CAN 
node n
.   
.   
.
32
TSU
32
32
32
M_CAN 
node 1
TSU
M_CAN 
node 0
TSU
32
32
32
16
DRE
2
4
4
SRC_CANINTx
(x=12-15)
STM
STM_Ni_TRIG 
(i=0-3)
TRIGNODE [1:0]
2
node0_TXD
node n_TXD
node n_RXD 
[7:0]
TRIGTYPE [1:0]
4
8
8
Figure 363
MCMCAN block diagram
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3918
v1.1
2025-06-26


The MCMCAN contains of the following sub blocks: User Interface, M_CAN nodes, the CAN routing engine and
the Message RAM.
Related information
TC4Dx SMU alarm mapping tables on page 7233
21.3
Functional description
Please refer to each of the CAN functional sub-blocks for the functional description.
21.4
User interface (UI)
The user interface is the wrapper which provides the interface for control of the M_CAN, CRE and MRAM to
the user and to the CPU. It contains configuration for clocks, trigger signal, interrupts, timers and the modules
connection to the outside world.
21.4.1
Feature list
•
Clock selection and generation through Clock Control Block
-
Up to 160 MHz input clock for CAN baud rate generation
•
Flexible interrupt structure generation available
-
Interrupt groups
•
Timer based transmission of CAN frame and timeouts for reception of CAN frames
•
Read and write access protection for Message RAM
21.4.2
Functional overview
The overview of the User Interface is shown in the following figure. The clock generation is handled in Clock
Control Block, where the required frequencies are derived from the fMCAN and fMCANH inputs.
The Timing functions module is used for calculating the delays and generating triggers when automatic
transmission of messages is needed.
The Interrupt Generation module consists of the interrupt grouping logic for interrupt triggers and the node
specific transmit trigger.
For test purposes, the user can connect the nodes to an CAN internal bus, this mode is also referred as loop
back mode. Additionally, the user can select the node in the loop back mode out, where a connection between
the internal CAN bus and an external CAN bus is possible. This is provided from the Test functions module.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3919
v1.1
2025-06-26


Clock Control 
Block
Interrupt 
Generation
Configuration Registers (SFRs)
Timers
Timing functions
fMCANH
fMCAN
Timer Interrupts 
(Node specific)
16
Interrupt 
Trigger  
User 
Interface
FPI
fASYN
fSYN
Triggers for automatic 
transmission
Test 
functions
Figure 364
UI block diagram
21.4.3
Functional description
The MCMCAN User Interface describes about the clock generation, grouping of interrupts, external connections
to the module and IO configurations.
21.4.3.1
MCMCAN clockpaths
A general overview of clocks within the MCMCAN module.
fMCAN
MCMCAN
MRAM
User Interface
CAN
Routing 
Engine
MRAM
Access Arbiter
fMCANH 
M_CAN
node n
.
.   
.
TSU
M_CAN
node 1
TSU
M_CAN
node 0
TSU
fSYN0
fASYN0
fSYN1
fASYN1
fSYNn
fASYNn
fSYN
fASYN
MCR.CLKSELi
MCR, RAM, BPI and
global registers
&
&
fSYNi(i=0-n)
fASYNi(i=0-n)
&
&
OFF
OFF
00
10
11
01
CLC
Node Clock Control Block
Figure 365
MCMCAN clock interconnects and clock control unit
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3920
v1.1
2025-06-26


The MCMCAN module clock inputs are connected to the clock control unit (CCU). The CLC setting supplies the
global module registers with its clocks. To supply the M_CAN nodes with the corresponding clocks, the
MCR.CLKSELi registers have to be set.
In the figure above the clock switch through CLC and clock control for single nodes is shown. The asynchronous
clock (fASYN ) as well as the synchronous clock (fSYN)of each single M_CAN node can be switched on and off
through MCR.CLKSELi register bit-fields.
The fSYN is supplied from fMCANH and fASYN is supplied from fMCAN from CCU. The fSYN is used as the clock source
for registers and RAM interface, fASYN is used to generate the nominal and fast CAN FD baudrates. It is
recommended to use fASYN as 20 MHz, 40 MHz, 80 MHz, or 160 MHz from the Peripheral clock or also from fOSC, in
order to achieve commonly used nominal and fast CAN FD baudrates. The condition that fSYN >= fASYN is
essential for proper functioning of MCMCAN.
Table 971
MCMCAN clock interconnects
CAN clock inputs
Connected to
Description
fMCAN
CCU
fMCAN of the MCMCAN module is one of the clock inputs of the Clock
Control Block, providing the MCMCAN with the clock for the asynchronous
clock path fASYN
fMCANH
CCU
fMCANH of the MCMCAN module is the clock input of the Clock Control
Block, providing the main kernel clock fSYN
fSYN
CLC
fMCANH becomes fSYN within the module
fASYN
CLC
fMCAN becomes fASYN within the module
fSYNi
MCR.CLKSELi
fSYN becomes fSYNi clocking the synchronous part of M_CAN node i (Nodes
can be switched on or off individually)
fASYNi
MCR.CLKSELi
fASYN becomes fASYNi clocking the asynchronous part of M_CAN node i
(Nodes can be switched on or off individually)
Clock selection
The asynchronous clock part of the M_CAN and the rest of the MCMCAN module are separate frequency
domains and can be driven by separate independent frequencies. The clocks for the module are chosen within
the clock control unit. The asynchronous clock can be chosen in the CCU among the Peripheral clock fPLL or
with direct drive from the oscillator fOSC.
The purpose of supplying the asynchronous clock part with a direct oscillator clock is to avoid the clock jitter
added by the PLL, necessary when the chip is driven by a low cost ceramic resonator instead of by a high
precision quartz crystal.
As shown in the figure above the clock signals for the MCMCAN module are generated and controlled by a clock
control unit. This clock control unit is responsible for the enable or disable control, the clock frequency
adjustment.
Clock control register
The Module clock is enabled using the CLC register. The module control clock fSYN is used inside the MCMCAN
module for control purposes such as clocking of control logic and register operations. The frequency of fSYN is
sourced by fMCANH from CCU module. This clock is independent to fSPB and allows M_CAN to continue operation
when fSPB is reduced in frequency, therefore enabling pretended networking. The clock control register CLC
makes it possible to enable or disable fSYN and fASYN under certain conditions.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3921
v1.1
2025-06-26


21.4.3.2
Interrupt groups
Interrupt grouping is fixed, as shown in the following figures. For the complete module, 16 interrupt nodes are
existing. The interrupt groups can be freely assigned to the interrupt line by using Ni_G0INTR (i=0-3), Ni_G1INTR
(i=0-3) and Ni_G2INTR (i=0-3) .
21.4.3.2.1
Mapping of interrupts
The mapping of interrupt from the interrupt registers into groups, out of which only enabled interrupt sources
are forwarded, is as following:
•
REINT - Receive Interrupt
•
RxF0F - Rx FIFO 0 Full
•
RxF1F - Rx FIFO 1 Full
•
RxF0N - Rx FIFO 0 New Message
•
RxF1N - Rx FIFO 1 New Message
•
RXTI - Receive Timeout
•
TRAQ - Transmission Queue
•
TRACO - Transmission Control
•
TEFIFO - Tx Event FIFO incident
•
HPE - High Priority Event
•
WATI - Watermark Interrupt
•
ALRT - Alert
•
MOER - Module Error
•
SAFE - Safety
•
BOFF - Bus Off
•
LOI - Last Error Interrupt
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3922
v1.1
2025-06-26


LOI
PEA
LEC
 PED
DLEC
MOER
WDI
MRAF
RXTI
TOO
REINT
DRX
BOFF
BO
ALRT
EW
EP
TSW
RF0L
RF1L
TEFL
SAFE
ELO
TRACO
TCF
TC
TFE
TRAQ
HPE
HPM
TEFIFO
TEFF
TEFN
WATI
TEFW
RF1W
RF0W
RxF0N
RF0N
RxF1F
RF1F
RxF0F
RF0F
RxF1N
RF1N
19
2
6
4
0
11
9
10
≥1
≥1
30
29
28
27
31
25
≥1
17
20
21
26
≥1
3
7
16
23
24
22
8
≥1
13
5
1
15
≥1
14
12
18
MCAN_IR_grouping.vsd_Int
TEFL
TEFF
TEF
W
TEFN
TC
HPM
TFE
TCF
RF1L
RF1F
RF1
W
RF1N
RF0
W
RF0N
RF0L
RF0F
31
30
29
28
27
26
25
20
21
24
22
23
17
19
18
16
15
14
13
12
11
10
9
4
5
8
6
7
1
3
2
0
Bits
Bits
0x50
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
res
PED
BO
EW
PEA
WDI
EP
ELO
res
MRA
F
TSW
DRX
TOO
RW-0
RW-0
R
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
RW-0
R
RW-0
RW-0
RW-0
RW-0
Bit definition in Ni_PSR register
Bit definition in Ni_IR register
Bit definition in Ni_INTRSIG register
Figure 366
Mapping of interrupts into groups
0
RXHBUF0
RBUF0I
1
RXHBUF1
RBUF1I
2
TXHBUF0
TBUF0I
4
5
IDMU
SFRMLI
XFRMLI
0
Bits
Bits
31
16
15
Node i CRE Interrupt Register
RBUF0I
RBUF1I
TBUFI0
SFRMLI
XFRMLI
IRSI0
IRSI1
IWSI0
IWSI1
CRCI0
CEI
IRSI0
IRSI1
IWSI0
IWSI1
CRCI0
CRCI1
RWDTI0
RWDTI1
TWDTI0
TWDTI1
6
7
8
9
10
Bit definition in Ni_CRE_IR  register
TBUFI1
3
TXHBUF1
TBUF1I
CRCI1
RWDTI0
11
12
RWDTI1
TWDTI0
TWDTI1
14
13
Figure 367
Mapping of CRE interrupts into groups
21.4.3.2.2
Signalling interrupts of groups
The groups defined in the previous paragraph are also shown in Ni_INTRSIG (i=0-3). For each group, 0 in the
corresponding bit-field means that no interrupt is pending and 1 means pending interrupt.
21.4.3.2.3
Interrupt control
The general interrupt structure is shown in the following figure:
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3923
v1.1
2025-06-26


Interrupt
Enable 
&
Interrupt Event 
Other Interrupt
Sources on the
same line
Ni_G0INTR
Ni_G1INTR
Ni_G2INTR
³1
To SRC_CANINT0
.....
To SRC_CANINT1
To 
SRC_CANINT15
Figure 368
General interrupt structure
The interrupt event can trigger the interrupt generation. The interrupt pulse is generated based on the interrupt
flag and the interrupt enable bit. The interrupt flag registers are: Ni_IR (i=0-3) and Ni_CRE_IR (i=0-3). The
interrupts are enabled at Ni_IE (i=0-3) and CRE configuration registers. The pulse generation is purely based on
AND logic between the interrupt flags and interrupt enable bit-fields. The interrupt flag can be reset by software
by writing a ‘1’ to the Ni_IR and Ni_CRE_IR respective bit-field.
If enabled by the related interrupt enable bit in the corresponding interrupt enable register (Ni_IE (i=0-3),
Ni_TIMER_RXTOUT (i=0-3).TEIE and CRE configuration registers), an interrupt pulse can be generated at one of
the 16 interrupt output lines SRC_CANINTn of the module using Ni_G0INTR (i=0-3), Ni_G1INTR (i=0-3) and
Ni_G2INTR (i=0-3). If more than one interrupt source is connected to the same interrupt line the requests are
combined to one common line.
The interrupt groups are only OR - ing the interrupts of the corresponding CAN nodes. The interrupt request has
to be reset in the node.
Note:
Enabling an interrupt in Interrupt Enable register when the corresponding flag is already set in
Interrupt Register will also generate an interrupt pulse. Hence it is recommended to clear the
interrupt flags before enabling the corresponding interrupts.
Interrupt 
Compressor Unit
Assign the 
interrupt line:  
Ni_G0INTR
Ni_G1INTR
Ni_G2INTR
M_CAN 
node 0
M_CAN 
node 3
Flags in: 
N0_IR
N0_CRE_IR
....
Flags in: 
N0_INTRSIG
Flags in: 
N3_INTRSIG
Flags in: 
N3_IR
N3_CRE_IR
16 interrupt lines:
SRC_CANINT0 ... 
SRC_CANINT15
Interrupt 
Router
Figure 369
Interrupt compression Unit
21.4.3.3
Connecting the module to the outside world
Each node in the MCMCAN module can be connected to an internal or external CAN bus via configuring the
Ni_PORTCTRL (i=0-3).LBM.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3924
v1.1
2025-06-26


M_CAN node 0
N0_PORTCTRL.
LBM
CAN Bus 0
M_CAN node i
Ni_PORTCTRL.
LBM
CAN Bus i
0
1
N0_PORTCTRL.
LOUT
0
1
...
0
1
0
1
Internal CAN bus
Ni_PORTCTRL.
LOUT
Figure 370
Module internal loop-back mode and loop-back mode out
21.4.3.3.1
Module internal loop-back mode
The MCMCAN module provides a module internal loop-back mode to enable an in-system test of the MCMCAN
module as well as the development of CAN driver software without access to an external CAN bus.
The loop-back feature consists of an internal CAN bus (inside the MCMCAN module) and a bus select switch for
each CAN node. With the switch, each CAN node can be connected either to the internal CAN bus (internal loop-
back mode activated) or the external CAN bus, respectively to transmit and receive pins (normal operation).
The CAN bus that is not currently selected is driven recessive; this means the transmit pin is held at 1, and the
receive pin is ignored by the CAN nodes that are in Loop-Back Mode.
The internal loop-back mode is selected for CAN node x by setting the Node x Port Control Register bit
Ni_PORTCTRL (i=0-3).LBM. All CAN nodes that are in loop-back mode may communicate together through the
internal CAN bus without affecting the normal operation of the other CAN nodes that are not in Loop-Back
Mode.
21.4.3.3.2
Module loop back mode out
Setting Ni_PORTCTRL (i=0-3).LOUT bit will send the signals from the internal loop back bus to the
corresponding pins of the CAN node and vice versa. Therefore a receive and transmit between internal loop
back bus and a bus system outside is possible. When Ni_PORTCTRL (i=0-3).LOUT is set to one, the internal loop
back bus and the external bus will be communicating with each other. The table below explains the behavior of
the CAN module for different combinations Ni_PORTCTRL (i=0-3).LOUT and Ni_PORTCTRL (i=0-3).LBM.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3925
v1.1
2025-06-26


Table 972
Combinations of internal loop back mode and loop back mode out
Ni_PORTCTRL.LOUT
Ni_PORTCTRL.LBM
Description
0
0
Normal CAN operation. Internal and loop back out mode
deactivated
0
1
Internal Loop Back mode
1
0
Loop Back Mode Out
1
1
Reserved
21.4.3.4
Setting the address protection for the CAN nodes
Inside the Register User Interface, the address protection is defined. Here the nodes become protectable, as
well as the control area. More information regarding the protection scheme is found in the PROT chapter.
MCMCAN has 5 APU set of registers to protect read/write access condition of separate parts of the module. APU
with ID 0-3, shown in Register overview chapter as PNi(i=0-3) controls CAN node i(i=0-3) read/write access
protection. APU with ID 4 is used for other registers read/write protection (shared by all CAN nodes). Therefore
each node has isolated read and write access protection configuration for its configuration registers. Individual
masters could be configured for each and every CAN node.
The Node Start Address (Ni_STARTADR (i=0-3)) and Node End Address (Ni_ENDADR (i=0-3)) registers, give the
possibility to define a range within CAN and CRE RAM, belonging to a node, which can only be written and read
by masters configured in CAN node APU register. The specified RAM area is write and read protected. An overlap
of the protected areas, is not found by the hardware.
21.4.3.5
Node timing functions
A CAN node offers the following timing functions:
•
A receive timeout mode that can detect the reception within message buffers. The timeout expires, when
no message has been received
•
Without CPU involvement, a selectable message buffer can be transmitted periodically, triggered by a
timer, the System Timer (STM), the General Timer Module (GTM) or the Enhanced General Timer Module
(eGTM)
The clocking options for the node timer is controlled by Node Timer Clock Control Register, Ni_TIMER_CCR
(i=0-3), the node timing functions for Receive Timeout Mode is controlled by Ni_TIMER_RXTOUT (i=0-3) and for
Transmit Trigger Mode is controlled by Node i Timer 0/1/2 Transmit Trigger Registers (Ni_TIMER_TXTRIG0
(i=0-3), Ni_TIMER_TXTRIG1 (i=0-3), Ni_TIMER_TXTRIG2 (i=0-3)). The timers will start running after setting the
STRT bit and setting the RELOAD value, to a value different than 0.
Modes with timer usage
A CAN node timer is driven by the synchronous clock or by the corresponding clock sources, divided by a
prescaler selected through bit-field Ni_TIMER_CCR (i=0-3).TPSC in the corresponding timer control register. The
timers are enabled by writing to the RELOAD bits in the relevant node timer registers. Then it decrements from
its initial value. The further behavior depends on the selected timer mode:
•
Receive Timeout Mode: The receive timeout function is valid for the receive buffers. A receive time-out
check is enabled, which may be a received frame or remote data frame. If any of the message buffers
receives before the timer is 0, the timer will be reloaded. When the timer reaches 0, it will stop. Bit TE in
Ni_TIMER_RXTOUT (i=0-3) register will be set. With bit Ni_TIMER_RXTOUT (i=0-3).TEIE = 1, an interrupt will
be generated.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3926
v1.1
2025-06-26


Note:
To avoid unintended receive timeout interrupts, the corresponding receive interrupts shall be
enabled via bits Ni_IE.RF0NE, Ni_IE.RF1NE or Ni_IE.DRXE depending on the usage of RxFIFO0/1 or
dedicated Rx buffers for proper function of the receive timeout interrupt
•
Transmit Trigger Mode: When the timer reaches 0, the TXRQ of the corresponding message buffer is
selected
Transmit trigger by system timer or general timer module
For Node i Timer the trigger for transmission of a message can also be set by a System Timer (STM) trigger
event, the General Timer Module (GTM), or the Enhanced General Timer Module (eGTM) trigger event, see the
following figure. The bit-field Ni_TIMER_CCR (i=0-3).TRIGSRC in the timer clock control register enables this
feature and the timer is started once values are written to the RELOAD bits of the relevant Ni_TIMER_TXTRIG0
(i=0-3), Ni_TIMER_TXTRIG1 (i=0-3) or Ni_TIMER_TXTRIG2 (i=0-3) registers. In transmit trigger mode, when a
trigger event occurs (STM, GTM or eGTM), the node timer will be decremented per trigger event timing
prescaled by (TPSC+1). The transmit request is set for the corresponding transmit message buffer one trigger
event after the RELOAD value reaches zero.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3927
v1.1
2025-06-26


Node 0
Ni_TIMER_CCR.
TRIGSRC
000
010
011
001
eGTM_Ni_TRIG
GTM_Ni_TRIG
STM_Ni_TRIG
Prescaler
Node i
1XX
Reserved, 
Do not Use
Ni_TIMER_CCR.
TPSC
TIMER
Comp.
= 0 ?
Ni_TIMER_RXTOUT.
TE = 1
Set  transmit request bit for 
Ni_TIMER_TXTRIG0  
Transmit buffer 1
Receive buffers, 
none FIFO
Message receive in 
buffer
Receive Timeout  Mode
Node i Timer 0
Transmit Trigger Mode
TIMER
Comp.
= 0 ?
Set  transmit request bit for 
Ni_TIMER_TXTRIG1  
Transmit buffer 2
Node i Timer 1
TIMER
Comp.
= 0 ?
Set  transmit request bit for 
Ni_TIMER_TXTRIG2  
Transmit buffer 3
Node i Timer 2
TIMER
Comp.
= 0 ?
Ni_TIMER_TXTRIG0. 
RELOAD
Ni_TIMER_RXTOUT.
RELOAD
Ni_TIMER_TXTRIG1. 
RELOAD
Ni_TIMER_TXTRIG2. 
RELOAD
fSYNi
Figure 371
CAN node timing modes
21.4.3.5.1
Automatic transferring of messages
Ni_TIMER_TXTRIG0 (i=0-3), Ni_TIMER_TXTRIG1 (i=0-3), Ni_TIMER_TXTRIG2 (i=0-3) registers enable the M_CAN to
trigger messages on timer events. The timer per module have one clock source. The counting events can take
place on an STM interrupt, a GTM, an eGTM interrupt or by fSYNi. These timers can be used to enable Pretended
Networking, or to have hardware support for a gateway functionality. This functionality needs a receive
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3928
v1.1
2025-06-26


interrupt or a watermark interrupt within a FIFO, triggering a DMA transfer. The transmit objects will be
automatically triggered to transfer the message buffer, through timer underflow. As the transmit triggers are
fixed to message RAM buffers 1-3, this feature only works if these buffers are available.
21.4.3.6
Message RAM
The Message RAM is shared by all the CAN nodes within the module. The elements of the message RAM are
configured per CAN node. When operated in CAN FD mode the required Message RAM size strongly depends on
the element size configured for Rx FIFO0, Rx FIFO1, Rx Buffers, and Tx Buffers through Ni_RXESC.F0DS,
Ni_RXESC.F1DS, Ni_RXESC.RBDS, and Ni_TXESC.TBDS.
SIDFC.FLSSA
XIDFC.FLESA
RXF0C.F0SA
RXF1C.F1SA
RXBC.RBSA
TXFC.EFSA
TXBC.TBSA
CRE_CONFIGADR.SA
0-128 elements / 0-128 words
0-64 elements / 0-128 words
0-64 elements / 0-1152 words
0-64 elements / 0-1152 words
0-64 elements / 0-1152 words
0-32 elements / 0-64 words
0-32 elements / 0-576 words
0-570 words
32 bits
11-bit Filter
29-bit Filter
Rx FIFO 0
Rx FIFO 1
Rx Buffer
Tx Event FIFO
Tx Buffer
CRE Configuration
Start Address
Figure 372
Message RAM configuration
When the M_CAN addresses the Message RAM it addresses 32-bit words, not single bytes. The configurable start
addresses are 32-bit word addresses this means only bits 15 to 2 are evaluated, the two least significant bits are
ignored.
The CRE part of RAM structure is shown in the figure above.
Note:
The M_CAN does not check for erroneous configuration of the Message RAM. Especially the
configuration of the start addresses of the different sections and the number of elements of each
section has to be done carefully to avoid falsification or loss of data.
21.4.3.6.1
Rx buffer and FIFO element
Up to 64 Rx buffers and two Rx FIFOs can be configured in the Message RAM. Each Rx FIFO section can be
configured to store up to 64 received messages. The structure of a Rx buffer/FIFO element is shown in the table
below. The element size can be configured for storage of CAN FD messages with up to 64 bytes data field
through register Ni_RXESC (i=0-3).
RXMSGk_R1A(k=0-63): When no TSU is used (Ni_CCCR (i=0-3).UTSU = '0'), R1A.RXTS[15:0] holds the 16-bit
timestamp generated by the M_CAN's internal timestamp logic.
RXMSGk_R1B (k=0-63): When a TSU is used (Ni_CCCR (i=0-3).UTSU = '1') and when bit SSYNC/ESYNC of the
matching filter element is set, R1B .TSC = '1' and R1B .RXTSP [3:0] holds the number of the TSU's Timestamp
registers which holds the 32-bit timestamp captured by the TSU. Else RXMSGk_R1B(k=0-63).TSC= '0' and
RXMSGk_R1B (k=0-63).RXTSP[3:0] is not valid.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3929
v1.1
2025-06-26


Table 973
Message layout - Rx buffer and FIFO element
 
3
1
 
 
 
 
 
 
2
4
2
3
 
 
 
 
 
 
1
6
1
5
 
 
 
 
 
 
8
7
 
 
 
 
 
 
0
R0
E
SI
X
T
D
R
T
R
ID[28:0]
R1A A
N
M
F
FIDX[6:0]
0
F
D
F
B
R
S
DLC[3:0]
RXTS[15:0]
R1B A
N
M
F
FIDX[6:0]
0
F
D
F
B
R
S
DLC[3:0]
0
T
S
C
RXTSP[3:0]
DB
m(0
-3)
DB3[7:0]
DB2[7:0]
DB1[7:0]
DB0[7:0]
DB
m(4
-7)
DB7[7:0]
DB6[7:0]
DB5[7:0]
DB4[7:0]
…
…
…
…
…
DB
m(
m-3
- m)
DBm[7:0]
DBm-1[7:0]
DBm-2[7:0]
DBm-3[7:0]
Note:
Depending on the configuration of the element size (RXESC), between two and sixteen 32-bit words
are used for storage of a CAN message’s data field.
21.4.3.6.2
Tx buffer element
The Tx buffers section can be configured to hold dedicated Tx buffers as well as a Tx FIFO/Tx Queue. If the Tx
buffers section is shared by dedicated Tx buffers and a Tx FIFO/Tx Queue, the dedicated Tx buffers start at the
beginning of the Tx buffers section followed by the buffers assigned to the Tx FIFO or Tx Queue. The Tx Handler
distinguishes between dedicated Tx buffers and Tx FIFO/Tx Queue by evaluating the Tx buffer configuration
Ni_TXBC.TFQS and Ni_TXBC.NDTB. The element size can be configured for storage of CAN FD messages with up
to 64 bytes data field through register Ni_TXESC.
Table 974
Message layout - Tx buffer element
 
3
1
 
 
 
 
 
 
2
4
2
3
 
 
 
 
 
 
1
6
1
5
 
 
 
 
 
 
8
7
 
 
 
 
 
 
0
T0 E
SI
X
T
D
R
T
R
ID[28:0]
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3930
v1.1
2025-06-26


Table 974
(continued) Message layout - Tx buffer element
T1 MM0[7:0]
E
F
C
T
S
C
E
F
D
F
B
R
S
DLC[3:0]
MM1[15:8]
0
D
B
m(
0-
3)
DB3[7:0]
DB2[7:0]
DB1[7:0]
DB0[7:0]
D
B
m(
4-
7)
DB7[7:0]
DB6[7:0]
DB5[7:0]
DB4[7:0]
… …
…
…
…
D
B
m(
m
-3
-
m
)
DBm[7:0]
DBm-1[7:0]
DBm-2[7:0]
DBm-3[7:0]
Note:
Depending on the configuration of the element size (TXESC), between two and sixteen 32-bit words
are used for storage of a CAN message’s data field.
21.4.3.6.3
Tx event FIFO element
Each element stores information about transmitted messages. By reading the Tx event FIFO the Host CPU gets
this information in the order the messages were transmitted. Status information about the Tx event FIFO can be
obtained from register Ni_TXEFS.
E1A: When Ni_CCCR.WMM ='0' and no TSU is used (Ni_CCCR.UTSU = '0'). E1A.TXTS[15:0] holds the 16-bit
timestamp generated by the M_CAN's internal timestamping logic.
E1B: When 16-bit Message Marker are enabled (Ni_CCCR.WMM = '1') or when Ni_CCCR.UTSU = '1', E1B.MM1[15:8]
holds the upper 8 bit of the Wide Message Marker. When a TSU is used (Ni_CCCR.UTSU = '1') and when bit TSCE
of the related Tx_Buffer element is set, E1B.TSC = '1' and E1B .TXTSP[3:0] holds the number of the TSU's
Timestamp register which holds the 32-bit timestamp captured by the TSU. Else E1B.TSC = '0' and
E1B.TXTSP[3:0] is not valid.
Table 975
Message layout - Tx event FIFO element
 
3
1
 
 
 
 
 
 
2
4
2
3
 
 
 
 
 
 
1
6
1
5
 
 
 
 
 
 
8
7
 
 
 
 
 
 
0
E0 E
SI
X
T
D
R
T
R
ID[28:0]
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3931
v1.1
2025-06-26


Table 975
(continued) Message layout - Tx event FIFO element
E1
A
MM[7:0]
ET
[1:0]
F
D
F
B
R
S
DLC[3:0]
TXTS[15:0]
E1
B
MM0[7:0]
ET
[1:0]
F
D
F
B
R
S
DLC[3:0]
MM1[15:8]
0
T
S
C
TXTSP[3:0]
21.4.3.6.4
Standard message ID filter element
Up to 128 filter elements can be configured for 11-bit standard IDs. When accessing a standard message ID Filter
element, its address is the filter list standard start address SIDFCi.FLSSA plus the index of the filter element (0…
127).
Table 976
Message layout - standard message ID Filter element
 
3
1
 
 
 
 
 
 
2
4
2
3
 
 
 
 
 
 
1
6
1
5
 
 
 
 
 
 
8
7
 
 
 
 
 
 
0
S0 SFT[
1:0]
SFEC[2:
0]
SFID1[10:0]
S
S
Y
N
C
0
SFID2[10:0]
21.4.3.6.5
Extended message ID filter element
Up to 64 filter elements can be configured for 29-bit extended IDs. When accessing an extended message ID
filter element, its address is the filter list extended start address XIDFCi.FLESA plus two times the index of the
filter element (0…63).
Table 977
Message layout - extended message ID filter element
 
3
1
 
 
 
 
 
 
2
4
2
3
 
 
 
 
 
 
1
6
1
5
 
 
 
 
 
 
8
7
 
 
 
 
 
 
0
F0 EFEC[2:
0]
EFID1[28:0]
F1 EFT[
1:0]
E
S
Y
N
C
EFID2[28:0]
21.4.3.7
Debug over CAN (DXCM feature)
The MCMCAN controller supports debugging using standard CAN tool access in parallel to regular CAN bus
traffic. This is achieved by transmitting DAP telegrams and replies as regular CAN messages (DXCM DAP over
CAN Messages). DXCM uses the lowest message buffers and it is strongly recommended to use also the same
CAN pins as for DXCPL (DAP over CAN Physical Layer). DXCM is enabled with the MCR.DXCM bit. Please refer to
the Debug and Trace chapter for more information about DAP, DXCM and DXCPL.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3932
v1.1
2025-06-26


Debug over CAN shall be only available on CAN0. TX Buffer 0 will be the sending transmit object. For receive at
least one message buffer has to be configured. Meaning that RX Buffer 0 will be used for receiving DAP
telegrams. The starting address of the message buffer and the receiving address of the message buffer have to
be configured within BUFADR register.
21.5
Modular CAN (M_CAN)
This section describes the Modular CAN nodes.
21.5.1
Feature list
•
Transmit and receive CAN frames with compatibility to ISO 11898-1
-
CAN FD with up to 64 data bytes supported
•
Improved acceptance filtering
•
Separate event signaling on reception of high priority messages
•
Flexible functional configuration for software
-
Configurable transmit FIFO
-
Configurable transmit queue
-
Configurable transmit event FIFO
-
Programmable loopback test mode
-
Two configurable receive FIFOs
•
Data storage:
-
Up to 64 dedicated receive buffers
-
Up to 32 dedicated transmit buffers
-
Up to sixteen 32-bit timestamps supported
•
Timestamping:
-
Hardware timestamping according to CiA 603
-
AUTOSAR synchronization method supported
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3933
v1.1
2025-06-26


21.5.2
Functional overview
This part gives a overview of the M_CAN module.
Extension IF
Host 
Interface
Memory 
Interface
32
MCAN
CAN Core
Tx Handler        
Cfg & Ctrl
Tx Priorization
Rx Handler        
Cfg & Ctrl
Rx Priorization
Generic Slave IF
Interrupt & 
Timestamp
Cfg & Ctrl
Sync
Generic Master IF
Tx_State
Tx_Req
Rx_State
RX
TX
CAN Clock Domain 
(fMCAN) 
Host Clock Domain
(fMCANH)  
Clk
Figure 373
M_CAN block diagram
CAN core
CAN Protocol Controller and Rx or Tx Shift register. Handles all ISO 11898-1 protocol functions. Supports 11-bit
and 29-bit identifiers.
Sync
Synchronizes signals from the Host clock domain to the CAN clock domain and vice versa.
Clk
Synchronizes reset signal to the Host clock domain and to the CAN clock domain.
Cfg and Ctrl
CAN core related configuration and control bits.
Interrupt and timestamp
Interrupt control and 16-bit CAN bit time counter for receive and transmit timestamp generation. An externally
generated 16-bit vector may substitute the integrated 16-bit CAN bit time counter for receive and transmit
timestamp generation.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3934
v1.1
2025-06-26


Tx handler
Controls the message transfer from the external message RAM to the CAN core. A maximum of 32 Tx buffers can
be configured for transmission. Tx buffers can be used as dedicated Tx buffers, as Tx FIFO, part of a Tx queue, or
as a combination of them. A Tx event FIFO stores Tx timestamps together with the corresponding message ID.
Transmit cancellation is also supported.
The Tx Handler also implements the Frame Synchronization Entity (FSE) which controls time-triggered
communication according to ISO11898-4. It synchronizes itself to the reference messages on the CAN bus,
controls cycle time and global time, and handles transmissions according to the predefined message schedule,
the system matrix. It also handles the time marks of the system matrix that are linked to the messages in the
Message RAM. Stop Watch Trigger, Event Trigger, and Time Mark Interrupt are synchronization interfaces.
Rx handler
Controls the transfer of received messages from the CAN core to the external message RAM. The Rx Handler
supports two receive FIFOs, each of configurable size, and up to 64 dedicated Rx buffers for storage of all
messages that have passed acceptance filtering. A dedicated Rx buffer, in contrast to a receive FIFO, is used to
store only messages with a specific identifier. An Rx timestamp is stored together with each message. Up to 128
filters can be defined for 11-bit IDs and up to 64 filters for 29-bit IDs.
Generic slave interface
Connects the M_CAN to a customer specific Host CPU.
Generic master interface
Connects the M_CAN access to an external 32-bit message RAM.
Extension interface
All flags from the interrupt register (Ni_IR SFR) and selected internal status and control signals are routed to
this interface.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3935
v1.1
2025-06-26


21.5.3
Functional description
The CAN module consists of four M_CAN nodes. Each M_CAN node represents a CAN channel interface, which is
configured individually. The functional description of a M_CAN node is given in this chapter.
21.5.3.1
Operating modes
This chapter provides the details of configuration options for a M_CAN operation, which includes: software
initialization, CAN and CAN FD operation, sleep mode and test modes.
21.5.3.1.1
Software initialization
Software initialization is started by setting bit Ni_CCCR (i=0-3).INIT, either by software or by a hardware reset, or
by going Bus_Off. While Ni_CCCR (i=0-3).INIT is set, message transfer from and to the CAN bus is stopped, the
status of the CAN bus output TXD is recessive (HIGH). The counters of the Error Management Logic EML are
unchanged. Setting Ni_CCCR (i=0-3).INIT does not change any configuration register. Resetting Ni_CCCR
(i=0-3).INIT finishes the software initialization. Afterwards the Bit Stream Processor BSP synchronizes itself to
the data transfer on the CAN bus by waiting for the occurrence of a sequence of 11 consecutive recessive bits
(Bus_Idle) before it can take part in bus activities and start the message transfer.
Access to the M_CAN configuration registers is only enabled when both bits Ni_CCCR (i=0-3).INIT and Ni_CCCR
(i=0-3).CCE are set (protected write).
Ni_CCCR (i=0-3).CCE can only be set/reset while Ni_CCCR (i=0-3).INIT = 1. Ni_CCCR (i=0-3).CCE is automatically
reset, when Ni_CCCR (i=0-3).INIT is cleared.
The following registers are reset when Ni_CCCR (i=0-3).CCE is set
•
Ni_HPMS (i=0-3) - High Priority Message Status
•
Ni_RXF0S (i=0-3) - Rx FIFO 0 Status
•
Ni_RXF1S (i=0-3) - Rx FIFO 1 Status
•
Ni_TXFQS (i=0-3) - Tx FIFO/Queue Status
•
Ni_TXBRP (i=0-3) - Tx Buffer Request Pending
•
Ni_TXBTO (i=0-3) - Tx Buffer Transmission Occurred
•
Ni_TXBCF (i=0-3) - Tx Buffer Cancellation Finished
•
Ni_TXEFS (i=0-3) - Tx Event FIFO Status
The Timeout Counter value Ni_TOCV (i=0-3).TOC is preset to the value configured by Ni_TOCC (i=0-3).TOP when
Ni_CCCR (i=0-3).CCE is set.
In addition the state machines of the Tx Handler and Rx Handler are held in idle state while Ni_CCCR (i=0-3).CCE
= 1.
The following registers are only writeable while Ni_CCCR (i=0-3).CCE = ‘0’
•
Ni_TXBAR (i=0-3) - Tx Buffer Add Request
•
Ni_TXBCR (i=0-3) - Tx Buffer Cancellation Request
Ni_CCCR (i=0-3).TEST and Ni_CCCR (i=0-3).MON can only be set by the Host while Ni_CCCR (i=0-3).INIT = 1 and
Ni_CCCR (i=0-3).CCE = 1. Both bits may be reset at any time. Ni_CCCR (i=0-3).DAR can only be set/reset while
Ni_CCCR (i=0-3).INIT = 1 and Ni_CCCR (i=0-3).CCE = 1.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3936
v1.1
2025-06-26


21.5.3.1.2
Normal operation
The M_CAN’s default operating mode after hardware reset is event-driven CAN communication.
Once the M_CAN is initialized and Ni_CCCR (i=0-3).INIT is reset to zero, the M_CAN synchronizes itself to the CAN
bus and is ready for communication.
After passing the acceptance filtering, received messages including Message ID and DLC are stored into a
dedicated Rx Buffer or into Rx FIFO 0 or Rx FIFO 1.
For messages to be transmitted dedicated Tx Buffers and/or a Tx FIFO or a Tx Queue can be initialized or
updated. Automated transmission on reception of remote frames is not implemented.
21.5.3.1.3
CAN FD operation
There are two variants in the CAN FD frame transmission:
•
The CAN FD frame without bit-rate switching
•
The CAN FD frame where control field, data field, and CRC field are transmitted with a higher bit rate than
the beginning and the end of the frame
The previously reserved bit in CAN frames with 11-bit identifiers and the first previously reserved bit in CAN
frames with 29-bit identifiers will now be decoded as FDF bit. If FDF is equal to:
•
Recessive: It signifies a CAN FD frame
•
Dominant It signifies a Classical CAN frame
In a CAN FD frame, the two bits following FDF, res and BRS, decide whether the bit rate inside of this CAN FD
frame is switched. A CAN FD bit rate switch is signified by res = dominant and BRS = recessive. The coding of res
= recessive is reserved for future expansion of the protocol.
In case the M_CAN receives a frame with FDF = recessive and res = recessive, it will signal a Protocol Exception
Event by setting bit Ni_PSR (i=0-3).PXE. When Protocol Exception Handling is:
•
Enabled (Ni_CCCR (i=0-3).PXHD = 0): This causes the operation state to change from Receiver (Ni_PSR
(i=0-3).ACT = “10”) to Synchronizing (Ni_PSR (i=0-3).ACT = “00”) at the next sample point
•
Disabled (Ni_CCCR (i=0-3).PXHD = 1): The M_CAN will treat a recessive res bit as an form error and will
respond with an error frame
CAN FD operation is enabled by programming Ni_CCCR (i=0-3).FDOE. In case Ni_CCCR (i=0-3).FDOE = 1,
transmission and reception of CAN FD frames is enabled. Transmission and reception of classical CAN frames is
always possible. Whether a CAN FD frame or a classical CAN frame is transmitted can be configured through bit
FDF in the respective Tx Buffer element. With Ni_CCCR (i=0-3).FDOE = 0, received frames are interpreted as
classical CAN frames, which leads to the transmission of an error frame when receiving a CAN FD frame. When
CAN FD operation is disabled, no CAN FD frames are transmitted even if bit FDF of a Tx Buffer element is set.
Ni_CCCR (i=0-3).FDOE and Ni_CCCR (i=0-3).BRSE can only be changed while Ni_CCCR (i=0-3).INIT and Ni_CCCR
(i=0-3).CCE are both set. With Ni_CCCR (i=0-3).FDOE = 0, the setting of bits FDF and BRS is ignored and frames
are transmitted in Classical CAN format. With Ni_CCCR (i=0-3).FDOE = 1 and Ni_CCCR (i=0-3).BRSE = 0, only bit
FDF of a Tx Buffer element is evaluated. With Ni_CCCR (i=0-3).FDOE = 1 and Ni_CCCR (i=0-3).BRSE = 1,
transmission of CAN FD frames with bit rate switching is enabled. All Tx Buffer elements with bits FDF and BRS
set are transmitted in CAN FD format with bit rate switching.
A mode change during CAN operation is only recommended under the following conditions:
•
The failure rate in the CAN FD data phase is significantly higher than in the CAN FD arbitration phase. In this
case, disable the CAN FD bit rate switching option for transmissions
•
During system start-up all nodes are transmitting Classical CAN messages until it is verified that they are
able to communicate in CAN FD format. If this is true, all nodes switch to CAN FD operation
•
Wake-up messages in CAN partial networking have to be transmitted in classical CAN format
•
End-of-line programming in case not all nodes are CAN FD capable. Non-CAN FD nodes are held in silent
mode until programming has completed. Then all nodes switch back to classical CAN communication
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3937
v1.1
2025-06-26


In the CAN FD format, the coding of the DLC differs from the standard CAN format. The DLC codes 0 to 8 have
the same coding as in standard CAN. The DLC codes 9 to 15, which in standard CAN all code a data field of
8 bytes, are coded according to the table below.
Table 978
Coding of DLC in CAN FD
DLC
9
10
11
12
13
14
15
Number of data bytes
12
16
20
24
32
48
64
In CAN FD frames, the bit timing will be switched inside the frame, after the BRS (Bit Rate Switch) bit, if this bit is
recessive. Before the BRS bit, in the CAN FD arbitration phase, the standard CAN bit timing is used as defined by
the Nominal Bit Timing and Prescaler Register Ni_DBTP (i=0-3). In the following CAN FD data phase, the data
phase bit timing is used as defined by the Data Bit Timing and Prescaler Register Ni_DBTP (i=0-3). The bit timing
is switched back from the fast timing at the CRC delimiter or when an error is detected, whichever occurs first.
The maximum configurable bit rate in the CAN FD data phase depends on the CAN clock frequency
(asynchronous clock). Example: with a CAN clock frequency of 20 MHz and the shortest configurable bit time of
4 tq, the bit rate in the data phase is 5 Mbit/s.
Note:
MCMCAN supports up to 5 Mbit/s considering the physical medium CAN-FD timing requirements from
ISO 11898-2:2016. At fM_CAN = 80 MHz, CAN-FD data phase bit rate can be extended to 8 Mbit/s, while
the bit asymmetry effect from CAN-FD transceiver, physical layer network topology and any other
dependencies, has to be considered by the user.
In both data frame formats, CAN FD long and CAN FD fast, the value of the bit ESI (Error Status Indicator) is
determined by the transmitter’s error state at the start of the transmission. If the transmitter is error passive,
ESI is transmitted recessive, else it is transmitted dominant.
21.5.3.1.4
Bus off recovery
The M_CAN enters Bus off state according to CAN protocol conditions specified in ISO 11898-1. The Bus off state
is reported by setting Ni_PSR.BO. Additionally, the M_CAN sets Ni_CCCR.INIT to stop all CAN operation.
To restart CAN operation, the application software needs to clear Ni_CCCR.INIT. After Ni_CCCR.INIT is cleared,
the M_CAN’s CAN state machine waits for the completion of the Bus off recovery Sequence according to CAN
protocol (at least 128 occurrences of Bus Idle Condition, which is the detection of 11 consecutive recessive bits).
The M_CAN uses its Receive Error Counter to count the occurrences of the Bus Idle Condition. If need be, that
can be monitored at Ni_ECR.REC. Additionally, each occurrence of the Bus Idle condition is flagged by
Ni_PSR.LEC = 5 = Bit0Error, which triggers an interrupt (Ni_IR.PEA) when Ni_IE.PEAE is enabled.
While the Bus off recovery proceeds, the CAN activity is reported as “Synchronizing”, Ni_PSR.ACT = 0 and
Ni_PSR.BO remains set. The time from resetting Ni_CCCR.INIT to the clearing of Ni_PSR.BO will be (in the
absence of dominant bits on the CAN bus) 1420 (11 * 129 + 1) CAN bit times plus synchronization delay between
clock domains.
During Bus off recovery, the M_CAN does not receive or start transmission of messages. When a transmission is
requested while the Bus off recovery proceeds, it will be started after the recovery has completed and CAN
activity entered Idle state, Ni_PSR.ACT = 1.
When the Bus off recovery has completed, Ni_PSR.BO, Ni_ECR.TEC, and Ni_ECR.REC are cleared, and one CAN
bit time later Ni_PSR.ACT is set to Idle.
After Ni_PSR.ACT reaches Idle, it will remain in Idle for at least one CAN bit time. The M_CAN’s CAN state
machine will become receiver (Ni_PSR.ACT = 2) when it samples a dominant bit during Idle state or it will
become transmitter (Ni_PSR.ACT = 3) when it detects a pending transmission request during Idle state.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3938
v1.1
2025-06-26


21.5.3.1.5
Transmitter delay compensation
During the data phase of a CAN FD transmission only one node is transmitting, all others are receivers. The
length of the bus line has no impact. When transmitting through pin TXD the protocol controller receives the
transmitted data from its local CAN transceiver through pin RXD. The received data is delayed by the CAN
transmitter delay. In case this delay is greater than TSEG1 (time segment before sample point), a bit error is
detected. In order to enable a data phase bit time that is even shorter than the transmitter delay, the delay
compensation is introduced. Without transmitter delay compensation, the bit rate in the data phase of a CAN
FD frame is limited by the transmitter delay.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3939
v1.1
2025-06-26


Configuration
The CAN FD protocol unit has implemented a delay compensation mechanism to compensate the CAN
transceiver’s loop delay, the transmitter delay, thereby enabling transmission with higher bit rates during the
CAN FD data phase independent of the delay of a specific CAN transceiver and port delay.
For the transmitter delay compensation the following boundary conditions have to be considered:
To check for bit errors during the data phase of transmitting nodes, the delayed transmit data is compared
against the received data at the Secondary Sample Point (SSP). If a bit error is detected, the transmitter will
react on this bit error at the next following regular sample point. During arbitration phase the delay
compensation is always disabled.
The transmitter delay compensation enables configurations where the data bit time is shorter than the
transmitter delay, it is described in detail in the ISO11898-1. It is enabled by setting bit Ni_DBTP (i=0-3).TDC. The
received bit is compared against the transmitted bit at the Secondary Sample Point. The Secondary Sample
Point position is defined as the sum of the measured delay from the M_CAN’s transmit output TX through the
transceiver to the receive input RX plus the transmitter delay compensation offset as configured by Ni_TDCR
(i=0-3).TDCO. The transmitter delay compensation offset is used to adjust the position of the SSP inside the
received bit (for example half of the bit time in the data phase). The position of the secondary sample point is
rounded down to the next integer number of minimum time quanta "mtq". Ni_PSR.TDCV shows the actual
transmitter delay compensation value. Ni_PSR (i=0-3).TDCV is cleared when Ni_CCCR.INIT is set and is updated
at each transmission of an FD frame while Ni_DBTP (i=0-3).TDC is set.
The following boundary conditions have to be considered for the transmitter delay compensation implemented
in the M_CAN:
•
The sum of the measured delay from TX to RX and the configured transmitter delay compensation offset
Ni_TDCR (i=0-3).TDCO has to be less than 6-bit times in the data phase. The sum of the measured delay
from RX to RX and the configured transmitter delay compensation offset Ni_TDCR (i=0-3).TDCO has to be
less than or equal to 127 mtq. In case this sum exceeds 127 mtq, the maximum value of 127 mtq is used for
transmitter delay compensation. The data phase ends at the sample point of the CRC delimiter, that stops
checking of receive bits at the secondary sample points
Measurement
If transmitter delay compensation is enabled by programming Ni_DBTP (i=0-3).TDC = ‘1’, the measurement is
started within each transmitted CAN FD frame at the falling edge of bit FDF to bit res. The measurement is
stopped when this edge is seen at the receive input RX of the transmitter. The resolution of this measurement is
one mtq.
The figure below describes how the transmitter loop delay is measured.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3940
v1.1
2025-06-26


Figure 374
Transmitter delay measurement
To avoid that a dominant glitch inside the received FDF bit ends the delay compensation measurement before
the falling edge of the received “res” bit, resulting in a to early Secondary Sample Point position, the use of a
transmitter delay compensation filter window can be enabled by programming Ni_TDCR (i=0-3).TDCF. This
defines a minimum value for the Secondary Sample Point position. Dominant edges on RX, that would result in
an earlier Secondary Sample Point position are ignored for transmitter delay measurement. The measurement
is stopped when the Secondary Sample Point position is at least Ni_TDCR (i=0-3).TDCF AND TX is low.
21.5.3.1.6
Restricted operation mode
In case of an error condition or overload condition, it does not send dominant bits, instead it waits for the
occurrence of bus idle to resynchronize itself to the CAN communication. The error counters (Ni_ECR
(i=0-3).REC and Ni_ECR (i=0-3).TEC) are frozen while Error Logging (Ni_ECR (i=0-3).CEL) is active. The Host can
set the M_CAN into Restricted Operation mode by setting bit Ni_CCCR (i=0-3).ASM. The bit can only be set by the
Host when both Ni_CCCR (i=0-3).CCE and Ni_CCCR (i=0-3).INIT are set to ‘1’. The bit can be reset by the Host at
any time.
Restricted Operation Mode is automatically entered when the Tx Handler was not able to read data from the
Message RAM in time. To leave Restricted Operation Mode, the Host CPU has to reset Ni_CCCR (i=0-3).ASM.
In  operation mode the node is able to:• 
Rece
ive data 
• 
Receive remote frames, and 
• 
Give acknowledge to valid frames 
The node does not send: 
• 
Data frames 
• 
Remote frames 
• 
Active error frames, or 
• 
Overload frames 
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3941
v1.1
2025-06-26


The Restricted Operation Mode can be used in applications that adapt themselves to different CAN bit rates. In
this case the application tests different bit rates and leaves the Restricted Operation Mode after it has received
a valid frame.
21.5.3.1.7
Bus monitoring mode
The M_CAN is set in bus monitoring mode by programming Ni_CCCR (i=0-3).MON to one. In bus monitoring
mode (see ISO11898-1, 10.12 Bus monitoring), the M_CAN is able to receive valid data frames and valid remote
frames, but cannot start a transmission. In this mode, it sends only recessive bits on the CAN bus, if the M_CAN
is required to send a dominant bit (ACK bit, overload flag, active error flag), the bit is rerouted internally so that
the M_CAN monitors this dominant bit, although the CAN bus may remain in recessive state. In bus monitoring
mode register TXBRP is held in reset state.
The bus monitoring mode can be used to analyze the traffic on a CAN bus without affecting it by the
transmission of dominant bits. The following figure shows the connection of signals TXD and RXD to the M_CAN
in bus monitoring mode.
Figure 375
Pin control in bus monitoring mode
21.5.3.1.8
Disabled automatic retransmission
According to the CAN Specification (see ISO11898-1, 6.3.3 Recovery Management), the M_CAN provides means
for automatic retransmission of frames that have lost arbitration or that have been disturbed by errors during
transmission. By default automatic retransmission is enabled. To support time-triggered communication as
described in ISO 11898-1 in Chapter 9.2, the automatic retransmission may be disabled through Ni_CCCR
(i=0-3).DAR.
Frame transmission in DAR mode
In DAR mode all transmissions are automatically canceled after they started on the CAN bus. A Tx Buffer’s Tx
Request Pending bit Ni_TXBRP (i=0-3).TRPx is reset after successful transmission, when a transmission has not
yet been started at the point of cancellation, has been aborted due to lost arbitration, or when an error
occurred during frame transmission.
•
Successful transmission:
-
Corresponding Tx Buffer Transmission Occurred bit Ni_TXBTO (i=0-3).TOx set
-
Corresponding Tx Buffer Cancellation Finished bit Ni_TXBCF (i=0-3).CFx not set
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3942
v1.1
2025-06-26


•
Successful transmission in spite of cancellation:
-
Corresponding Tx Buffer Transmission Occurred bit Ni_TXBTO (i=0-3.TOx set
-
Corresponding Tx Buffer Cancellation Finished bit Ni_TXBCF (i=0-3).CFx set
•
Arbitration lost or frame transmission disturbed:
-
Corresponding Tx Buffer Transmission Occurred bit Ni_TXBTO (i=0-3.TOx not set
-
Corresponding Tx Buffer Cancellation Finished bit Ni_TXBCF (i=0-3).CFx set
In case of a successful frame transmission, and if storage of Tx events is enabled, a Tx Event FIFO element is
written with Event Type ET = “10” (transmission in spite of cancellation).
21.5.3.1.9
Power down (sleep mode)
The M_CAN can be set into power down mode controlled by input signal clock stop request or by CC Control
Register Ni_CCCR (i=0-3).CSR. As long as the clock stop request signal is active, bit Ni_CCCR (i=0-3).CSR is read
as one.
When all pending transmission requests have completed, the M_CAN waits until bus idle state is detected. Then
the M_CAN sets then Ni_CCCR (i=0-3).INIT to one to prevent any further CAN transfers. Now the M_CAN
acknowledges that it is ready for power down by setting Ni_CCCR (i=0-3).CSA to one. In this state, before the
clocks are switched off, further register accesses can be made. A write access to Ni_CCCR (i=0-3).INIT will have
no effect. Now the module clocks may be switched off.
To leave power down mode, the application has to turn on the module clocks before resetting CC Control
Register flag Ni_CCCR (i=0-3).CSR. The M_CAN will acknowledge this by resetting Ni_CCCR (i=0-3).CSA.
Afterwards, the application can restart CAN communication by resetting bit Ni_CCCR (i=0-3).INIT.
21.5.3.1.10
Test modes
To enable write access to register TEST (see Ni_TEST (i=0-3)), bit Ni_CCCR (i=0-3).TEST has to be set to one. This
allows the configuration of the test modes and test functions.
Four output functions are available for the CAN transmit pin TXD by programming Ni_TEST (i=0-3).TX.
Additionally to its default function – the serial data output – it can drive the CAN Sample Point signal to monitor
the M_CAN’s bit timing and it can drive constant dominant or recessive values. The actual value at pin RXD can
be read from Ni_TEST (i=0-3).RX. Both functions can be used to check the CAN bus’ physical layer.
Due to the synchronization mechanism between CAN clock and Host clock domain, there may be a delay of
several Host clock periods between writing to Ni_TEST (i=0-3).TX until the new configuration is visible at output
pin TXD. This applies also when reading input pin RXD through Ni_TEST (i=0-3).RX.
Note:
Test modes should be used for production tests or self test only. The software control for pin TXD
interferes with all CAN protocol functions. It is not recommended to use test modes for application.
Node external loop back mode
The M_CAN can be set in external loop back Mode by programming Ni_TEST (i=0-3).LBCK to one. In loop back
mode, the M_CAN treats its own transmitted messages as received messages and stores them (if they pass
acceptance filtering) into an Rx Buffer or an Rx FIFO0/1. The following figure shows the connection of TXD and
RXD to the M_CAN in external loop back mode.
This mode is provided for hardware self-test. To be independent from external stimulation, the M_CAN ignores
acknowledge errors (recessive bit sampled in the acknowledge slot of a data or remote frame) in loop back
mode. In this mode the M_CAN performs an internal feedback from its Tx output to its Rx input. The actual
value of the RXD input pin is disregarded by the M_CAN. The transmitted messages can be monitored at the TXD
pin.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3943
v1.1
2025-06-26


Node internal loop back mode
Internal loop back mode is entered by programming bits Ni_TEST (i=0-3).LBCK and Ni_CCCR (i=0-3).MON to
one. This mode can be used for a “Hot Selftest”, meaning the M_CAN can be tested without affecting a running
CAN system connected to the pins TXD and RXD. In this mode pin RXD is disconnected from the M_CAN and pin
TXD is held recessive. The following figure shows the connection of TXD and RXD to the M_CAN in case of
internal loop back mode.
Figure 376
Pin control in loop back modes
21.5.3.2
Timestamp generation
M_CAN supports two methods for frame timestamping:
1.
Internal M_CAN timestamping feature 16-bit wide timestamps, using a selectable clock source,
compatible with previous versions of MCMCAN module
2.
Hardware timestamping 32-bit wide timestamps using TSU module, according to CiA 603
21.5.3.2.1
Internal timestamp generation
For timestamp generation the M_CAN supplies a 16-bit wrap-around counter. A prescaler Ni_TSCC (i=0-3).TCP
can be configured to clock the counter in multiples of CAN bit times (1…16). The counter is readable through
Ni_TSCV (i=0-3).TSC. A write access to register TSCV resets the counter to zero. When the timestamp counter
wraps around interrupt flag Ni_IR (i=0-3).TSW is set.
On start of frame reception/transmission the counter value is captured and stored into the timestamp section
of an Rx Buffer/Rx FIFO (RXTS[15:0]) or Tx Event FIFO (TXTS[15:0]) element.
By programming bit Ni_TSCC (i=0-3).TSS an external 16-bit timestamp can be used. The external timer can be
controlled using the Ni_TIMER_CCR (i=0-3) register. The external source for the timer is selected by
programming the Ni_TIMER_CCR (i=0-3).TRGIGSRC. The external timer can be started by setting Ni_TIMER_CCR
(i=0-3).STSTART. It can be reset to zero by setting Ni_TIMER_CCR (i=0-3).STRESET. A write of ‘1b’ to
Ni_TIMER_CCR (i=0-3).STSTART is effective only when Ni_TIMER_CCR (i=0-3).STRESET is ‘0b’ that is, the external
timer cannot be started when Ni_TIMER_CCR (i=0-3).STRESET is ‘1b’.
21.5.3.2.2
Timestamping unit (TSU)
This section gives a description of configuring and using the timestamping unit for hardware captured
timestamps of received or transmitted frames.
To enable hardware timestamping together with the TSU, M_CAN’s configuration bit Ni_CCCR (i=0-3).UTSU has
to be configured to 1. In case Ni_CCCR (i=0-3).UTSU = ‘0’ (default value), the M_CAN’s internal 16-bit timestamp
counter is used, if enabled.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3944
v1.1
2025-06-26


TSU Configuration
The TSU is configured by Ni_TSU_TSCFG. This register is only writable while Ni_CCCR (i=0-3).CCE = ‘1’. With
Ni_TSU_TSCFG.TSUE the TSU is enabled. Both Ni_CCCR (i=0-3).UTSU and Ni_TSU_TSCFG.TSUE shall be set to '1',
for proper functioning of timestamping using TSU. By default the TSU is disabled. The Timebase Prescaler
Ni_TSU_TSCFG.TBPRE[7:0] is used to adapt the count rate of the TSU’s internal counter, if enabled, to the
requirements of the application.
The TSU provides the user the possibility of using an internal timebase or an external timebase input for
timestamping, selected through Ni_TSU_TSCFG (i=1-3).TBCS. When this bit is set to ‘0’, the internal free running
timebase counter is used, and if this bit is set to ‘1’, the timestamp value is taken from the external timebase
input. CAN node 0 has no external timebase input. CAN node 1-3 external timebase input is the output of the
CAN node 0 internal timebase. This gives the possibility of synchronized timestamping accross the nodes. The
following figure shows the connection and its configuration.
Ni_TSU_TSCFG.SCP configures the point in time when a timestamp is captured for Sync messages (0: at EOF, 1:
at SOF of the received or transmitted Sync message).
When Ni_TSU_TSCFG.SCP = '0', the timestamp is captured directly from the Actual Timebase Ni_TSU_ATB
(i=0-3) to the timestamp register Ni_TSU_TSm (i=0-3;m=0-15) when the message gets valid at EOF. This
configuration is intended for AUTOSAR conformant applications.
When Ni_TSU_TSCFG.SCP = '1', the Actual Timebase Ni_TSU_ATB (i=0-3) is captured into a temporary buffer at
each SOF. When the message gets valid at EOF the timestamp is copied from the temporary buffer to the
timestamp register Ni_TSU_TSm (i=0-3;m=0-15).
The Timestamp Pointer is incremented after capturing the timestamp.
fMCANH
fMCANH
fMCANH
TSU0
32 bit counter
TSU1
32 bit 
counter
Internal timebase   0
fMCANH
N0_Timebase
N1_TSCFG.TBCS
N0_Timebase 1
TSU2
32 bit 
counter
Internal timebase   0
N2_TSCFG.TBCS
N0_Timebase 1
TSU3
32 bit 
counter
Internal timebase   0
N3_TSCFG.TBCS
N0_Timebase 1
Figure 377
TSU connectivity across the nodes
Reception of timestamped messages
To configure the M_CAN for reception of timestamped messages, a Standard/Extended Message ID Filter
Element has to be set up by configuration of STDMSGk_S0.SSYNC = ‘1’ respectively EXTMSGk_F1.ESYNC = ‘1’. In
case the filter element matches the received frame and the received frame is valid, M_CAN output at the EOF
triggers the storage of the value of the TSU’s Actual Timebase ATB to the TSU's timestamp register selected by
the Timestamp Pointer Ni_TSU_TSS2 (i=0-3).TSP[3:0]. At the same pulse, the M_CAN captures the Timestamp
Pointer value and this value is written to the M_CAN’s RXMSGk_R1B.RXTSP[3:0] of the related Rx Buffer or Rx
FIFO element. R1B.TSC is set to ‘1’ when a timestamp has been captured by the TSU and
RXMSGk_R1B.RXTSP[3:0] holds a valid timestamp pointer.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3945
v1.1
2025-06-26


Transmission of timestamped messages
In case bits TXMSGk_T1.TSCE and TXMSGk_T1.EFC of a Tx Buffer element are set, a successful transmission of
that Tx Buffer generates a pulse that triggers the storage of the value of the TSU’s Actual Timebase ATB to the
TSU's timestamp register selected by the Timestamp Pointer Ni_TSU_TSS2 (i=0-3).TSP[3:0]. At the same pulse,
the M_CAN captures the Timestamp Pointer value and this value is written to the M_CAN’s
TXEVENTk_E1B.TXTSP[3:0] of the related Tx Event FIFO. TXEVENTk_E1B.TSC is set to ‘1’ when a timestamp has
been captured by the TSU and TXEVENTk_E1B.TXTSP[3:0] holds a valid timestamp pointer element.
Handling of timestamps
The TSU stores sixteen 32-bit timestamps. They are written to TS0 to TS15 in a cyclic manner.
Each timestamp register has assigned two status bits:
•
Ni_TSU_TSS1 (i=0-3).TSNn is set whenever a timestamp was stored to the related timestamp register
Ni_TSU_TSm (i=0-3;m=0-15)
•
Ni_TSU_TSS1 (i=0-3).TSLn is set when a new timestamp was stored to the related timestamp register TSn
before the previously store timestamp has been read out
Reading a Timestamp register resets the related TSS1 bits, if Ni_PORTCTRL(i=0-3).DELE is set.
21.5.3.3
Timeout counter
To signal timeout conditions for Rx FIFO 0, Rx FIFO 1, and the Tx Event FIFO the M_CAN supplies a 16-bit
Timeout Counter. It operates as down-counter and uses the same prescaler controlled by Ni_TSCC (i=0-3).TCP
as the Timestamp Counter. The Timeout Counter is configured by register Ni_TOCC (i=0-3). The actual counter
value can be read from Ni_TOCV (i=0-3).TOC.
The Timeout Counter can only be started while Ni_CCCR (i=0-3).INIT = ‘0’. It is stopped when Ni_CCCR
(i=0-3).INIT = ‘1’, for example when the M_CAN enters Bus_Off state.
The operation mode is selected by Ni_TOCC (i=0-3).TOS. When operating in Continuous Mode, the counter starts
when Ni_CCCR.INIT is reset. A write to Ni_TOCV (i=0-3) presets the counter to the value configured by Ni_TOCC
(i=0-3).TOP and continues down-counting.
When the Timeout Counter is controlled by one of the FIFOs, an empty FIFO presets the counter to the value
configured by Ni_TOCC (i=0-3).TOP. Down-counting is started when the first FIFO element is stored. Writing to
Ni_TOCV (i=0-3) has no effect.
When the counter reaches zero, interrupt flag Ni_IR (i=0-3).TOO is set. In Continuous Mode, the counter is
immediately restarted at Ni_TOCC (i=0-3).TOP.
Note:
The clock signal for the Timeout Counter is derived from the CAN Core’s sample point signal. Therefore
the point in time where the Timeout Counter is decremented may vary due to the synchronization/
re-synchronization mechanism of the CAN Core. If the baud rate switch feature in CAN FD is used, the
timeout counter is clocked differently in arbitration and data field.
21.5.3.4
Rx handling
The Rx Handler controls the acceptance filtering, the transfer of received messages to the Rx Buffers or to one of
the two Rx FIFOs, as well as the Rx FIFO’s Put and Get Indices.
21.5.3.4.1
Acceptance filtering
The M_CAN offers the possibility to configure two sets of acceptance filters, one for standard identifiers and one
for extended identifiers. These filters can be assigned to an Rx Buffer or to Rx FIFO 0,1. For acceptance filtering
each list of filters is executed from element #0 until the first matching element. Acceptance filtering stops at the
first matching element. The following filter elements are not evaluated for this message.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3946
v1.1
2025-06-26


The main features are:
•
Each filter element can be configured as:
-
Range filter (from - to)
-
Filter for one or two dedicated IDs, or
-
Classic bit mask filter
•
Each filter element is configurable for acceptance or rejection filtering
•
Each filter element can be enabled and disabled individually
•
Filters are checked sequentially, execution stops with the first matching filter element
Related configuration registers are:
•
Global Filter Configuration Ni_GFC (i=0-3)
•
Standard ID Filter Configuration Ni_SIDFC (i=0-3)
•
Extended ID Filter Configuration Ni_XIDFC (i=0-3)
•
Extended ID AND Mask Ni_XIDAM (i=0-3)
Depending on the configuration of the filter element (STDMSGk_S0.SFEC or EXTMSGk_F0.EFEC) a match
triggers one of the following actions:
•
Store received frame in FIFO 0 or FIFO 1
•
Store received frame in Rx Buffer
•
Store received frame in Rx Buffer
•
Reject received frame
•
Set High Priority Message interrupt flag Ni_IR (i=0-3).HPM
•
Set High Priority Message interrupt flag Ni_IR (i=0-3).HPM and store received frame in FIFO 0 or FIFO 1
Acceptance filtering is started after the complete identifier has been received. After acceptance filtering has
completed, and if a matching Rx Buffer or Rx FIFO has been found, the Message Handler starts writing the
received message data in portions of 32 bits to the matching Rx Buffer or Rx FIFO. If the CAN protocol controller
has detected an error condition (for example CRC error), this message is discarded with the following impact on
the affected Rx Buffer or Rx FIFO:
Rx Buffer New Data flag of matching Rx Buffer is not set, but Rx Buffer (partly) overwritten with received data.
Rx FIFO Put index of matching Rx FIFO is not updated, but related Rx FIFO element (partly) overwritten with
received data. In case the matching Rx FIFO is operated in overwrite mode, the boundary conditions described
in Rx FIFO Overwrite Mode (see related information) have to be considered.
For error type see Ni_PSR (i=0-3).LEC respectively Ni_PSR (i=0-3).FLEC.
Note:
When an accepted message is written to one of the two Rx FIFOs, or into an Rx Buffer, the unmodified
received identifier is stored independent of the filter(s) used. The result of the acceptance filter process
is strongly depending on the sequence of configured filter elements.
Related information
Rx FIFO overwrite mode on page 3952
Range filter
The filter matches for all received frames with Message IDs in the range defined by STDMSGk_S0.SFID1/SFID2
respectively EXTMSGk_F0.EFID1/EFID2.
There are two possibilities when range filtering is used together with extended frames:
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3947
v1.1
2025-06-26


•
EXTMSGk_F1.EFT = 00: The Message ID of received frames is ANDed with the Extended ID AND Mask
(Ni_XIDAM) before the range filter is applied
•
EXTMSGk_F1.EFT = 11: The Extended ID AND Mask (Ni_XIDAM) is not used for range filtering
Filter for specific IDs
A filter element can be configured to filter for one or two specific Message IDs. To filter for one specific
Message ID, the filter element has to be configured with STDMSGk_S0.SFID1 = STDMSGk_S0.SFID2 respectively
EXTMSGk_F0.EFID1 = EXTMSGk_F1.EFID2.
Classic bit mask filter
Classic bit mask filtering is intended to filter groups of Message IDs by masking single bits of a received Message
ID. With classic bit mask filtering STDMSGk_S0.SFID1/EXTMSGk_F0.EFID1 is used as Message ID filter, while
STDMSGk_S0.SFID2/EXTMSGk_F1.EFID2 is used as filter mask.
A zero bit at the filter mask will mask out the corresponding bit position of the configured ID filter, for example
the value of the received Message ID at that bit position is not relevant for acceptance filtering. Only those bits
of the received Message ID where the corresponding mask bits are one are relevant for acceptance filtering.
In case all mask bits are one, a match occurs only when the received Message ID and the Message ID filter are
identical. If all mask bits are zero, all Message IDs match.
Standard message ID filtering
The following figure shows the flow for standard message ID (11-bit identifier) filtering. The standard message
ID Filter element is described in related information.
Controlled by the global filter configuration Ni_GFC (i=0-3) and the standard ID filter configuration Ni_SIDFC
message ID, remote transmission request bit (RTR), and the identifier extension bit (IDE) of received frames are
compared against the list of configured filter elements.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3948
v1.1
2025-06-26


Figure 378
Standard message ID filter path
Related information
Standard message ID filter element on page 3932
Extended message ID filtering
The following figure shows the flow for extended message ID (29-bit identifier) filtering. The extended message
ID filter element is described in related information.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3949
v1.1
2025-06-26


Controlled by the Global Filter Configuration Ni_GFC and the Extended ID Filter Configuration Ni_XIDFC
Message ID, Remote Transmission Request bit (RTR), and the Identifier Extension bit (IDE) of received frames
are compared against the list of configured filter elements.
The Extended ID AND Mask Ni_XIDAM is ANDed with the received identifier before the filter list is executed.
Figure 379
Extended message ID filter path
Related information
Standard message ID filter element on page 3932
21.5.3.4.2
Rx FIFOs
Rx FIFO 0 and Rx FIFO 1 can be configured to hold up to 64 elements each. Configuration of the two Rx FIFOs is
done by registers Ni_RXF0C (i=0-3) and Ni_RXF1C (i=0-3).
Received messages that passed acceptance filtering are transferred to the Rx FIFO as configured by the
matching filter element. For a description of the filter mechanisms available for Rx FIFO 0 and Rx FIFO 1 see
Acceptance Filtering in related information. The Rx FIFO element is described in Rx Buffer and FIFO Element in
related information.
To avoid an Rx FIFO overflow, the Rx FIFO watermark can be used. When the Rx FIFO fill level reaches the Rx
FIFO watermark configured by RXFnC.FnWM, interrupt flag Ni_IR.RFnW is set. When the Rx FIFO Put Index
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3950
v1.1
2025-06-26


reaches the Rx FIFO Get Index an Rx FIFO Full condition is signalled by Ni_RXFnS.FnF. In addition interrupt flag
Ni_IR (i=0-3).RFnF is set.
Figure 380
Rx FIFO status
When reading from an Rx FIFO, Rx FIFO Get Index Ni_RXFnS.FnGI • FIFO Element Size has to be added to the
corresponding Rx FIFO start address Ni_RXFnC.FnSA.
Table 979
Rx buffer/FIFO element size
Ni_RXESC.RBDS[2:0]
Ni_RXESC.FnDS[2:0]
Data field
[bytes]
FIFO element size
[RAM words]
000
8
4
001
12
5
010
16
6
011
20
7
100
24
8
101
32
10
110
48
14
111
64
18
Related information
Acceptance filtering on page 3946
Rx buffer and FIFO element on page 3929
Rx FIFO blocking mode
The Rx FIFO blocking mode is configured by Ni_RXFnC.FnOM = ‘0’. This is the default operation mode for the Rx
FIFOs.
When an Rx FIFO full condition is reached (Ni_RXFnS.FnPI = Ni_RXFnS.FnGI), no further messages are written to
the corresponding Rx FIFO until at least one message has been read out and the Rx FIFO Get Index has been
incremented. An Rx FIFO full condition is signalled by Ni_RXFnS.FnF = ‘1’. In addition interrupt flag Ni_IR
(i=0-3).RFnF is set.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3951
v1.1
2025-06-26


In case a message is received while the corresponding Rx FIFO is full, this message is discarded and the
message lost condition is signalled by Ni_RXFnS.RFnL = ‘1’. In addition interrupt flag Ni_IR (i=0-3).RFnL is set.
Rx FIFO overwrite mode
The Rx FIFO overwrite mode is configured by Ni_RXFnC.FnOM = ‘1’.
When an Rx FIFO full condition (Ni_RXFnS.FnPI = RXFnS.FnGI) is signalled by Ni_RXFnS.FnF = ‘1’, the next
message accepted for the FIFO will overwrite the oldest FIFO message. Put and get index are both incremented
by one.
When an Rx FIFO is operated in overwrite mode and an Rx FIFO full condition is signalled, reading of the Rx FIFO
elements should start at least at get index + 1. The reason for that is, that it might happen, that a received
message is written to the Message RAM (put index) while the CPU is reading from the Message RAM (get index).
In this case inconsistent data may be read from the respective Rx FIFO element. Adding an offset to the get
index when reading from the Rx FIFO avoids this problem. The offset depends on how fast the CPU accesses the
Rx FIFO. The following figure shows an offset of two with respect to the get index when reading the Rx FIFO. In
this case the two messages stored in element 1 and 2 are lost.
Figure 381
Rx FIFO overflow handling
After reading from the Rx FIFO, the number of the last element read has to be written to the Rx FIFO
Acknowledge Index Ni_RXFnA.FnA. This increments the get index to that element number. In case the put index
has not been incremented to this Rx FIFO element, the Rx FIFO full condition is reset (Ni_RXFnS.FnF = ‘0’).
21.5.3.4.3
Dedicated Rx buffers
The M_CAN supports up to 64 dedicated Rx Buffers. The start address of the dedicated Rx Buffer section is
configured by Ni_RXBC (i=0-3).RBSA.
For each Rx Buffer a Standard or Extended Message ID Filter Element with STDMSGk_S0.SFEC/
EXTMSGk_F0.EFEC = “111” and STDMSGk_S0.SFID2/EXTMSGk_F1.EFID2[10:9] = “00” has to be configured (see
related information).
After a received message has been accepted by a filter element, the message is stored into the Rx Buffer in the
Message RAM referenced by the filter element. The format is the same as for an Rx FIFO element. In addition the
flag Ni_IR.DRX (Message stored in dedicated Rx Buffer) in the interrupt register is set.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3952
v1.1
2025-06-26


Table 980
Example filter configuration for Rx buffers
Filter
element
SFID1[10:0]
EFID1[28:0]
SFID2[10:9]
EFID2[10:9]
SFID2[5:0]
EFID2[5:0]
0
ID message 1
00
00 0000
1
ID message 2
00
00 0001
2
ID message 3
00
00 0010
After the last word of a matching received message has been written to the Message RAM, the respective New
Data flag in register Ni_NDAT1 (i=0-3),Ni_NDAT2 (i=0-3) is set. As long as the New Data flag is set, the respective
Rx Buffer is locked against updates from received matching frames. The New Data flags have to be reset by the
Host by writing a ‘1’ to the respective bit position.
While an Rx Buffer’s New Data flag is set, a Message ID Filter Element referencing this specific Rx Buffer will not
match, causing the acceptance filtering to continue. Following Message ID Filter Elements may cause the
received message to be stored into another Rx Buffer, or into an Rx FIFO, or the message may be rejected,
depending on filter configuration.
Related information
Standard message ID filter element on page 3932
Extended message ID filter element on page 3932
Rx buffer handling
•
Reset interrupt flag Ni_IR (i=0-3).DRX
•
Read new data registers
•
Read messages from Message RAM
•
Reset new data flags of processed messages
21.5.3.5
Tx handling
The Tx Handler handles transmission requests for the dedicated Tx Buffers, the Tx FIFO, and the Tx Queue. It
controls the transfer of transmit messages to the CAN Core, the Put and Get Indices, and the Tx Event FIFO. Up
to 32 Tx Buffers can be set up for message transmission. The CAN mode for transmission (Classic CAN or CAN
FD) can be configured separately for each Tx Buffer element. The Tx Buffer element is described in related
information. The following table describes the possible configurations for frame transmission.
Table 981
Possible configuration for frame transmission
CCCR
Tx buffer element
Frame transmission
BRSE
FDOE
FDF
BRS
Ignored
0
Ignored
Ignored
Classical CAN
0
1
0
Ignored
Classical CAN
0
1
1
Ignored
FD without bit rate switching
1
1
0
Ignored
Classical CAN
1
1
1
0
FD without bit rate switching
1
1
1
1
FD with bit rate switching
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3953
v1.1
2025-06-26


Note:
AUTOSAR requires at least three Tx Queue Buffers and support of transmit cancellation
The Tx Handler starts a Tx scan to check for the highest priority pending Tx request (Tx Buffer with lowest
Message ID) when the Tx Buffer Request Pending register Ni_TXBRP (i=0-3) is updated, or when a transmission
has been started.
Related information
Tx buffer element on page 3930
21.5.3.5.1
Transmit pause
The transmit pause feature is intended for use in CAN systems where the CAN message identifiers are
(permanently) specified to specific values and cannot easily be changed. These message identifiers may have a
higher CAN arbitration priority than other defined messages, while in a specific application their relative
arbitration priority should be inverse. This may lead to a case where one ECU sends a burst of CAN messages
that cause another ECU’s CAN messages to be delayed because that other messages have a lower CAN
arbitration priority.
If for example CAN ECU-1 has the transmit pause feature enabled and is requested by its application software to
transmit four messages, it will, after the first successful message transmission, wait for two CAN bit times of bus
idle before it is allowed to start the next requested message. If there are other ECUs with pending messages,
those messages are started in the idle time, they would not need to arbitrate with the next message of ECU-1.
After having received a message, ECU-1 is allowed to start its next transmission as soon as the received
message releases the CAN bus.
The transmit pause feature is controlled by bit Ni_CCCR (i=0-3).TXP. If the bit is set, the M_CAN will, each time it
has successfully transmitted a message, pause for two CAN bit times before starting the next transmission. This
enables other CAN nodes in the network to transmit messages even if their messages have lower prior
identifiers. Default is transmit pause disabled (Ni_CCCR (i=0-3).TXP = ‘0’).
This feature loosens up burst transmissions coming from a single node and it protects against “babbling idiot”
scenarios where the application program erroneously requests too many transmissions.
21.5.3.5.2
Dedicated Tx buffers
Dedicated Tx Buffers are intended for message transmission under complete control of the Host CPU. Each
dedicated Tx Buffer is configured with a specific Message ID. In case that multiple dedicated Tx Buffers are
configured with the same Message ID, the Tx Buffer with the lowest buffer number is transmitted first. These Tx
buffers shall be requested in ascending order with lowest buffer number first. Alternatively all Tx buffers
configured with the same Message ID can be requested simultaneously by a single write access to Ni_TXBAR
(i=0-3).
If the data section has been updated, a transmission is requested by an "Add Request" through Ni_TXBAR
(i=0-3).ARn. The requested messages arbitrate internally with messages from an optional Tx FIFO or Tx Queue
and externally with messages on the CAN bus, and are sent out according to their Message ID.
A dedicated Tx Buffer allocates Element Size 32-bit words in the Message RAM (see related information).
Therefore the start address of a dedicated Tx Buffer in the Message RAM is calculated by adding transmit buffer
index (0…31) • Element Size to the Tx Buffer Start Address Ni_TXBC (i=0-3).TBSA.
Table 982
Tx buffer/FIFO/queue element size
Ni_TXESC.TBDS[2:0]
Data field [bytes]
Element size [RAM words]
000
8
4
001
12
5
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3954
v1.1
2025-06-26


Table 982
(continued) Tx buffer/FIFO/queue element size
Ni_TXESC.TBDS[2:0]
Data field [bytes]
Element size [RAM words]
010
16
6
011
20
7
100
24
8
101
32
10
110
48
14
111
64
18
Related information
Tx FIFO on page 3956
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3955
v1.1
2025-06-26


21.5.3.5.3
Tx FIFO
Tx FIFO operation is configured by programming Ni_TXBC (i=0-3).TFQM to ‘0’. Messages stored in the Tx FIFO are
transmitted starting with the message referenced by the Get Index Ni_TXFQS (i=0-3).TFGI. After each
transmission the Get Index is incremented cyclically until the Tx FIFO is empty. The Tx FIFO enables
transmission of messages with the same Message ID from different Tx Buffers in the order these messages have
been written to the Tx FIFO. The M_CAN calculates the Tx FIFO Free Level Ni_TXFQS (i=0-3).TFFL as difference
between Get and Put Index. It indicates the number of available (free) Tx FIFO elements.
New transmit messages have to be written to the Tx FIFO starting with the Tx Buffer referenced by the Put Index
Ni_TXFQS (i=0-3).TFQPI. An “Add Request” increments the Put Index to the next free Tx FIFO element. When the
Put Index reaches the Get Index, Tx FIFO Full (Ni_TXFQS (i=0-3).TFQF = ‘1’) is signalled. In this case no further
messages should be written to the Tx FIFO until the next message has been transmitted and the Get Index has
been incremented.
When a single message is added to the Tx FIFO, the transmission is requested by writing a ‘1’ to the TXBAR bit
related to the Tx Buffer referenced by the Tx FIFO’s Put Index.
When multiple (n) messages are added to the Tx FIFO, they are written to n consecutive Tx Buffers starting with
the Put Index. The transmissions are then requested by Ni_TXBAR (i=0-3). The Put Index is then cyclically
incremented by n. The number of requested Tx buffers should not exceed the number of free Tx Buffers as
indicated by the Tx FIFO Free Level.
When a transmission request for the Tx Buffer referenced by the Get Index is cancelled, the Get Index is
incremented to the next Tx Buffer with pending transmission request and the Tx FIFO Free Level is recalculated.
When transmission cancellation is applied to any other Tx Buffer, the Get Index and the FIFO Free Level remain
unchanged.
A Tx FIFO element allocates Element Size 32-bit words in the Message RAM (see table in related information).
Therefore the start address of the next available (free) Tx FIFO Buffer is calculated by adding Tx FIFO/Queue Put
Index Ni_TXFQS (i=0-3).TFQPI (0…31) • Element Size to the Tx Buffer Start Address Ni_TXBC (i=0-3).TBSA.
Related information
Dedicated Tx buffers on page 3954
21.5.3.5.4
Tx queue
Tx Queue operation is configured by programming Ni_TXBC (i=0-3).TFQM to ‘1’. Messages stored in the Tx Queue
are transmitted starting with the message with the lowest Message ID (highest priority). In case that multiple Tx
Queue buffers are configured with the same Message ID, the transmission order depends on numbers of the
buffers where the messages were stored for transmission. As these buffer numbers depend on the then current
states of the Put Index, a prediction of the transmission order is not possible.
New messages have to be written to the Tx Buffer referenced by the Put Index Ni_TXFQS (i=0-3).TFQPI. The Put
Index always points to that free buffer of the Tx Queue with the lowest buffer number. In case that the Tx Queue
is full (Ni_TXFQS (i=0-3).TFQF = “1”), the Put Index is not valid and no further message should be written to the
Tx Queue until at least one of the requested messages has been sent out or a pending transmission request has
been cancelled.
The application may use register TXBRP instead of the Put Index and may place messages to any Tx Buffer
without pending transmission request.
A Tx Queue Buffer allocates Element Size 32-bit words in the Message RAM (see table in related information).
Therefore the start address of the next available (free) Tx Queue Buffer is calculated by adding Tx FIFO/Queue
Put Index Ni_TXFQS (i=0-3).TFQPI (0…31) • Element Size to the Tx Buffer Start Address Ni_TXBC (i=0-3).TBSA.
Related information
Dedicated Tx buffers on page 3954
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3956
v1.1
2025-06-26


21.5.3.5.5
Mixed dedicated Tx buffers/Tx FIFO
In this case the Tx Buffers section in the Message RAM is subdivided into a set of dedicated Tx Buffers and a Tx
FIFO. The number of dedicated Tx Buffers is configured by Ni_TXBC (i=0-3).NDTB. The number of Tx Buffers
assigned to the Tx FIFO is configured by Ni_TXBC (i=0-3).TFQSi. In case Ni_TXBC (i=0-3).TFQS is programmed to
0x0, only dedicated Tx Buffers are used.
Figure 382
Example of mixed configuration dedicated Tx buffers/Tx FIFO
Tx prioritization:
•
Scan dedicated Tx Buffers and oldest pending Tx FIFO Buffer (referenced by Ni_TXFQS (i=0-3).TFGI)
•
Buffer with lowest Message ID gets highest priority and is transmitted next
21.5.3.5.6
Mixed dedicated Tx buffers/Tx queue
In this case the Tx Buffers section in the Message RAM is subdivided into a set of dedicated Tx Buffers and a Tx
Queue. The number of dedicated Tx Buffers is configured by Ni_TXBC (i=0-3).NDTB. The number of Tx Queue
Buffers is configured by Ni_TXBC (i=0-3).TFQSi. In case Ni_TXBC (i=0-3).TFQS is programmed to zero, only
dedicated Tx Buffers are used.
Figure 383
Example of mixed configuration dedicated Tx buffers/Tx queue
Tx prioritization:
•
Scan all Tx Buffers with activated transmission request
•
Tx Buffer with lowest Message ID gets highest priority and is transmitted next
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3957
v1.1
2025-06-26


21.5.3.5.7
Transmit cancellation
This feature is especially intended for gateway applications and AUTOSAR based applications. To cancel a
requested transmission from a dedicated Tx Buffer or a Tx Queue buffer the Host has to write a ‘1’ to the
corresponding bit position (=number of Tx Buffer) of register Ni_TXBCR (i=0-3). Transmit cancellation is not
intended for Tx FIFO operation.
Successful cancellation is signalled by setting the corresponding bit of register TXBCF to ‘1’.
In case a transmit cancellation is requested while a transmission from a Tx Buffer is already ongoing, the
corresponding TXBRP bit remains set as long as the transmission is in progress. If the transmission was
successful, the corresponding TXBTO and TXBCF bits are set. If the transmission was not successful, it is not
repeated and only the corresponding TXBCF bit is set.
Note:
In case a pending transmission is cancelled immediately before this transmission could have been
started, there follows a short time window where no transmission is started even if another message
is also pending in this node. This may enable another node to transmit a message which may have a
lower priority than the second message in this node.
21.5.3.5.8
Tx event handling
To support Tx event handling the M_CAN has implemented a Tx Event FIFO. After the M_CAN has transmitted a
message on the CAN bus, Message ID and timestamp are stored in a Tx Event FIFO element. To link a Tx event to
a Tx Event FIFO element, the Message Marker from the transmitted Tx Buffer is copied into the Tx Event FIFO
element.
The Tx Event FIFO can be configured to a maximum of 32 elements. The Tx Event FIFO element is described in
related information.
The purpose of the Tx Event FIFO is to decouple handling transmit status information from transmit message
handling that is a Tx Buffer holds only the message to be transmitted, while the transmit status is stored
separately in the Tx Event FIFO. This has the advantage, especially when operating a dynamically managed
transmit queue, that a Tx Buffer can be used for a new message immediately after successful transmission.
There is no need to save transmit status information from a Tx Buffer before overwriting that Tx Buffer.
When a Tx Event FIFO full condition is signalled by Ni_IR (i=0-3).TEFF, no further elements are written to the Tx
Event FIFO until at least one element has been read out and the Tx Event FIFO Get Index has been incremented.
In case a Tx event occurs while the Tx Event FIFO is full, this event is discarded and interrupt flag Ni_IR
(i=0-3).TEFL is set.
To avoid a Tx Event FIFO overflow, the Tx Event FIFO watermark can be used. When the Tx Event FIFO fill level
reaches the Tx Event FIFO watermark configured by Ni_TXEFC (i=0-3).EFWM, interrupt flag Ni_IR.TEFW is set.
When reading from the Tx Event FIFO, two times the Tx Event FIFO Get Index Ni_TXEFS (i=0-3).EFGI has to be
added to the Tx Event FIFO start address Ni_TXEFC (i=0-3).EFSA.
Related information
Tx event FIFO element on page 3931
21.5.3.6
FIFO acknowledge handling
The Get Indices of Rx FIFO 0, Rx FIFO 1, and the Tx Event FIFO are controlled by writing to the corresponding
FIFO Acknowledge Index (see Ni_RXF0A, Ni_RXF1A and Ni_TXEFA). Writing to the FIFO Acknowledge Index will
set the FIFO Get Index to the FIFO Acknowledge Index plus one and thereby updates the FIFO Fill Level. There
are two use cases:
When only a single element has been read from the FIFO (the one being pointed to by the Get Index), this Get
Index value is written to the FIFO Acknowledge Index.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3958
v1.1
2025-06-26


When a sequence of elements has been read from the FIFO, it is sufficient to write the FIFO Acknowledge Index
only once at the end of that read sequence (value: Index of the last element read), to update the FIFO’s Get
Index.
Due to the fact that the CPU has free access to the M_CAN’s Message RAM, special care has to be taken when
reading FIFO elements in an arbitrary order (Get Index not considered). This might be useful when reading a
High Priority Message from one of the two Rx FIFOs. In this case the FIFO’s Acknowledge Index should not be
written because this would set the Get Index to a wrong position and also alters the FIFO’s Fill Level. In this case
some of the older FIFO elements would be lost.
Note:
The application has to ensure that a valid value is written to the FIFO Acknowledge Index. The M_CAN
does not check for erroneous values.
21.6
CAN Routing Engine (CRE)
The CAN Routing Engine (CRE) is an extension of MCMCAN which is used to route CAN frames by determining
the destination(s) of a received CAN frame based on the received CAN-ID.
The destination of the CAN frame can be another CAN interface or Ethernet interface or a System RAM location.
The CRE standalone routes the CAN frames with destination within the MCMCAN it belongs to. For CAN frames
with destination outside the MCMCAN, CRE writes the frame to respective Host Buffer and triggers the Data
Routing Engine (DRE) or an interrupt to the Interrupt Router based on the configuration. The CRE provides a
virtual host interface to the RxFIFOs and TxQueues/TxFIFO of M_CAN, for ease of reading the received CAN
frame and writing the transmit CAN frame without any additional processing by host to perform address
calculation/acknowledge for CAN RxFIFO and TxQueue/TxFIFO. The CRE also consists of a Intrusion Detection
Measurement Unit (IDMU) which provides parameters that can be used by intrusion detection software.
The CRE is enabled by setting Ni_CRE_CONFIG.EN to 1. When CRE is enabled, the virtual host interfaces RX and
TX Host Buffers are also enabled. In this case, the received frames are read from the receive Host Buffer RHBUF
by the FPI master instead of the RxFIFO. Frames are written to the Transmit Host Buffer THBUF by the FPI
master instead of TxQueue/TxFIFO. The CRE must be enabled before enabling routing or IDMU.
Note:
When CRE is disabled, both routing and IDMU are disabled. The host buffers are disabled and the
frames are written to or read from TxQueue/TxFIFO and RxFIFO.
The routing operation is enabled by setting both Ni_CRE_CONFIG.EN and Ni_CRE_CONFIG.REN to 1. This CRE
should be enabled both at the source and the destination nodes for a successful routing operation.
The IDMU is enabled by setting both Ni_CRE_CONFIG.EN and Ni_CRE_CONFIG.IDMUEN to 1.
21.6.1
Feature list
The following are the features of CRE:
•
Offloads CPU by hardware accelerated routing of received CAN frames to a user configured destination(s)
•
Hardware accelerated CAN to CAN routing within the same MCMCAN module
•
Assists Data Routing Engine (DRE) to perform hardware accelerated
-
CAN to CAN routing between different MCMCAN module
-
CAN to Ethernet (in IEEE 1722 ACF Frame) routing
-
CAN frame to a user configurable system RAM location transfer
-
CAN PDU to a user configurable system RAM location transfer
•
Supports DRE in multi-cast routing, that is routing of a received CAN frame to a maximum of up to four
destinations
•
Provides a configurable routing table to define the rules of the routing operation
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3959
v1.1
2025-06-26


•
Abstracts the M_CAN RxFIFOs and TxFIFO/TxQueues operation to the host interface by providing virtual
buffers
-
Enables system DMA, CPU software or DRE to write transmitted CAN frames and to read received CAN
frames with ease
•
Consists of a measurement unit for Intrusion Detection (IDMU)
21.6.2
Functional overview
The CAN Routing Engine is shared by all four CAN interfaces in a MCMCAN module as shown in the figure below.
CAN Node 3 (N3)
N1 Tx Host 
Buffer 1
N2 Tx Host 
Buffer 1
N3 Tx Host 
Buffer 1
CAN Routing Engine
MCMCAN 
RAM
Interrupt (to IR)
Trigger (to DRE)
MCMCAN
SPB
CAN Node 1 (N1)
CAN Node 0 (N0)
N0 Rx
FIFO 0
N0
IDMU
Database
N0
Routing 
Table
N0 Tx Host 
Buffer 1
CAN Node 2 (N2)
N0 Tx
Queue
N1 Tx
Queue
N2 Tx
Queue
N3 Tx
Queue
N0 Rx Host 
Buffer 0
N1
IDMU
Database
N1
Routing 
Table
N2
IDMU
Database
N2
Routing 
Table
N3
IDMU
Database
N3
Routing 
Table
N0 Rx
FIFO 1
N1 Rx
FIFO 0
N1 Rx
FIFO 1
N2 Rx
FIFO 0
N2 Rx
FIFO 1
N3 Rx
FIFO 0
N3 Rx
FIFO 1
N0 Rx Host 
Buffer 1
N1 Rx Host 
Buffer 0
N1 Rx Host 
Buffer 1
N2 Rx Host 
Buffer 0
N2 Rx Host 
Buffer 1
N3 Rx Host 
Buffer 0
N3 Rx Host 
Buffer 1
N0 Tx Host 
Buffer 0
N1 Tx Host 
Buffer 0
N2 Tx Host 
Buffer 0
N3 Tx Host 
Buffer 0
Figure 384
CRE interfaces to CAN nodes
Routing table
The Routing Table contains the rules which decide the routing path of the received CAN frame. It also has other
configuration parameters related to its destination. The CAN Routing Engine uses the Routing Table to perform
all the routing operations.
IDMU
The Intrusion Detection Measurement Unit (IDMU) contains a Timestamp database and a Frame Rate Measure
table, which provide measures that can be used for intrusion detection. The CAN Routing Engine uses the
Timestamp database to calculate the Inter Arrival Measure (IAM) of frames. The Frame Rate Measure table
consists of counters that increment with reception of each frame.
Receive host buffer
The Receive Host Buffer 0/1 contains the pending received CAN frame from RxFIFO0/RxFIFO1. The CRE identifies
the routing destination of the newly received CAN frame from RxFIFO0 or RxFIFO1. If the Routing Destination is
not one of the CAN Nodes belonging to the CRE (within the same MCMCAN the CRE belongs to), then CRE writes
the CAN frame to the respective Receive Host Buffer. If the destination of the CAN frame is within the same
MCMCAN the CRE belongs to, the frame is not written to respective Receive Host Buffer. The CRE transmit
interface writes the CAN frame directly to the destination CAN node TxQueue or TxFIFO.
Event Notification: Each new frame on the Rx Host Buffer triggers either an interrupt to IR or a trigger to DRE,
as configured by the user.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3960
v1.1
2025-06-26


Transmit host buffer
The Tx Host Buffer0/1 contains the CAN frame to be transmitted. Upon detecting a valid CAN frame, the CRE
copies the frame to TxQueue or to TxFIFO and initiates transmission by setting Transmit request (Ni_TXBAR).
Event Notification: When a free element in TxQueue/TxFIFO is available, triggers either an interrupt to IR or a
trigger to DRE, indicating the possibility to initiate transmission of a new CAN frame through the Tx Host Buffer.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3961
v1.1
2025-06-26


21.6.3
Functional description
The block diagram of CRE is shown in Figure below
CRE
Nx 
RxFIFO 0/1
Receive 
Interface
Routing 
Control
Transmit 
Interface
Nx 
Rx Host 
Buffer 0/1
Nx 
Tx Host 
Buffer 0/1
Nx 
TxFIFO or 
Queue
Nx
Routing 
Table
Internal Routing
External Routing
CRE 
Configuration
SFRs
CRE Status
SFRs
TRIGTYPE[1:0]
INT[5:0]
TRIGNODE[1:0]
Intrusion Detection 
Measurement Unit
Nx
Timestamp 
Database
Nx
Frame Rate 
Measure
TSU
To DRE
To IR
Figure 385
CRE block diagram
The CRE consists of four major blocks:
•
Receive Interface
•
Routing Control
•
Intrusion Detection Measurement Unit (IDMU)
•
Transmit Interface
In addition to it, the CRE Host Buffers, Routing Tables, IDMU Tables and databases are stored in the MCMCAN
RAM. Total RAM size of 36KBytes or 20KBytes (Refer to Device specific CAN configuration chapter for the total
RAM size for the CAN module) is shared between CRE and CAN. Based on the use case, user shall do the RAM
configuration for CRE and CAN. For example, 4KB for CRE and 32 KB of RAM can be configured for MCMCAN0.
Ni_CRE_CONFIGADR.SA defines the start address of the CRE configurations in the RAM. The start addresses and
size of the tables are part of the CRE tables specific configuration parameters as shown in the following figure.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3962
v1.1
2025-06-26


CAN  Node Specific CRE Configuration
Routing Table Standard ID 
 (max 128 Elements - 1 element per word)
Routing Table Extended  ID 
 (max 64 Elements - 1 element per word)
0 - 127 elements
128 Words
STD_RT_PARAM.SIZE
0 - 63 elements
64 Words
XTD_RT_PARAM.SIZE
Tx Host Buffer 0 CAN frame/CAN I-PDU(1 element - 18 words)
XTD_RT_PARAM.SA
CRE_CONFIGADR.SA
96 Words
Fixed Size when CRE is 
enabled
Frame Rate Measure Standard  ID 
 (max 128 Elements - 1 element per word)
Frame Rate Measure Extended  ID 
 (max 64 Elements - 1 element per word)
Timestamp Database Standard  ID 
 (max 128 Elements - 1 element per word)
Timestamp Database Extended  ID 
 (max 64 Elements - 1 element per word)
0 - 63 elements
32 Words
XTD_FRT_PARAM.SIZE
0 - 127 elements
128 Words
STD_TSD_PARAM.SIZE
0 - 63 elements
64 Words
XTD_TSD_PARAM.SIZE
XTD_TSD_PARAM.SA
Rx Host Buffer 1 Routing Header (1 element - 1 word)
Rx Host Buffer 1 Timing Header (1 element - 2 words)
Rx Host Buffer 1 CRC  (1 element - 1 word)
Rx Host Buffer 1 CAN frame/CAN I-PDU (1 element - 18 words)
CRE Tables Specific Configuration Parameters ( 6 words)
STD_TSD_PARAM.SA
XTD_FRT_PARAM.SA
0 - 127 elements
64 Words
STD_FRT_PARAM.SIZE
STD_FRT_PARAM.SA
STD_RT_PARAM.SA
Reserved (1 word)
Rx Host Buffer 0 Routing Header (1 element - 1 word)
Rx Host Buffer 0 Timing Header (1 element - 2 words)
Rx Host Buffer 0 CRC  (1 element - 1 word)
Rx Host Buffer 0 CAN frame/CAN I-PDU (1 element - 18 words)
Tx Host Buffer 0 CRC  (1 element - 1 word)
Tx Host Buffer 1 CAN frame/CAN I-PDU (1 element - 18 words)
Tx Host Buffer 1 CRC  (1 element - 1 word)
Rx Host Buffer 0
Rx Host Buffer 1
Tx Host Buffer 0
Tx Host Buffer 1
Reserved (2 words)
Reserved (2 words)
Reserved (1 word)
Reserved (1 word)
CRE_ABORT_SEQ (1 word)
Figure 386
Message RAM layout for CRE
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3963
v1.1
2025-06-26


Note:
Offset addresses for the CRE Standard Routing Table, CRE Extended Routing Table, CRE Standard
Frame Rate Table, CRE Extended Frame Rate Table, CRE Standard Timestamp Database and CRE
Extended Timestamp Database are relative to the configured start address by the user in the
appropriate CRE configuration table. These configured start addresses are absolute in the CAN
message RAM and not relative to the start of the CRE RAM section.
In following sections, detailed functionality of CRE with respect to transmit and receive CAN frames are
described.
21.6.3.1
Receive interface
The Receive Interface abstracts the following operations relating to RxFIFO for the user:
•
Address calculation to identify the pending RxFIFO0/1 element
•
Acknowledge the RxFIFO 0/1 after the read operation
•
Fetching the external 32-bit timestamp from the TSU
•
Fetching the internally generated 16-bit timestamp from RXMSGk_R1A (k=0-63).RXTS[15:0]
When Ni_CRE_CONFIG (i=0-3).EN = 1, a master of FPI can always read a pending received CAN frame only from
the Rx Host Buffer 0/1 instead of accessing from the RxFIFO0/1. The CRE assists the read operation by providing
a interrupt/trigger for each newly available CAN frame stored in Rx Host Buffer 0/1. The Receive Interface
interacts with the Routing Control to identify the destination of a corresponding received CAN frame. It fetches
the receive timestamp from the Timestamping Unit (TSU) (external timestamp) or from RXMSGk_R1A
(k=0-63).RXTS[15:0] (internal timestamp). It interacts with the IDMU to calculate the intrusion detection
measures. The Receive Interface also updates the timing header with the received timestamp.
Identify a new received frame from RxFIFO
The Receive Interface monitors the RxFIFO fill level Ni_RXF0S (i=0-3).F0FL (or) Ni_RXF1S (i=0-3).F1FL. When the
F0FL or F1FL is not 0, then CRE reads the newly received CAN frame as indicated by RxFIFO Get index
Ni_RXF0S.F0GI or Ni_RXF1S.F1GI. The corresponding Get index of the RxFIFO is also indicated in
Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1).INDEX.
Fetching the receive timestamp
Every frame consists of a 16-bit internal (Internal Timestamp Generation, see related information) or 32-bit
external timestamp (Timestamping Unit (TSU), see related information). Receive Interface first checks if the TSU
is enabled (CCCR.UTSU = 1 and TSUE = 1) and then if RXMSGk_R1B (k=0-63).TSC is set. R1B.TSC is set when a
timestamp has been captured by the TSU and RXMSGk_R1B (k=0-63).RXTSP holds a valid timestamp pointer. If
R1B.TSC is set and the TSU is enabled, the Receive Interface fetches the 32-bit timestamp captured by the TSU
using the RXMSGk_R1B (k=0-63).RXTSP which holds the pointer of the TSU's timestamp register.
The Timing Header (THEAD) is composed of two words (32-bit each) as shown in the figure above.
RHBUFk_THEAD_RXTS (k=0-1) holds the timestamp and RHBUFk_THEAD_INTRD (k=0-1) consists of status flags
(TSCLEN, TSC and TSL) associated with the THEAD_RXTS. The Receive Interface updates the THEAD with the
timestamp received in the following manner:
•
Case 1: When a 16-bit internal timestamp is used, Timing Header (THEAD) RHBUFk_THEAD_RXTS (k=0-1) is
updated with RXMSGk_R1A (k=0-63).RXTS[15:0]. TSCLEN and TSC are set to 0 by the hardware
•
Case 2: When a 32-bit external timestamp is used, Timing Header (THEAD) RHBUFk_THEAD_RXTS (k=0-1) is
updated with the timestamp from TSU pointed to by RXMSGk_R1B (k=0-63).RXTSP[3:0]. TSCLEN and TSC
are set to 1 by the hardware. The TSC bit is set to 1 by the hardware to indicate that the 32-bit timestamp
RHBUFk_THEAD_RXTS (k=0-1) is valid. The timestamp is only valid when bits Ni_CCCR.UTSU, TSUE, SSYNC/
ESYNC, RXMSGk_R1B.TSC and Ni_TSU_TSS1.TSN are set. TSL bit is set in the THEAD when there is a loss of
timestamp in the TSU (Ni_TSU_TSS1.TSLn = 1)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3964
v1.1
2025-06-26


Note:
The Intrusion Detection Measurement Unit (IDMU) (see related information) updates the THEAD
further with the intrusion detection measure IAM and IAMSTAT
Relevance for routing operation
When the routing operation is enabled for a CAN node (Ni_CRE_CONFIG (i=0-3).REN), then the Receive Interface
decides if the received CAN frame is relevant for routing operation or not, based on the Acceptance Filter from
which the CAN frame has been received. REN should be enabled at the source CAN node. Enabling REN makes
the CAN node a routing source. The frame is routed to the destination DID irrespective of the REN bit at the
destination node.
The CRE Receive Interface checks the Acceptance Filter ID (RXMSGk_R1A (k=0-63).FIDX) and Accept Non-
Matching Frame (RXMSGk_R1A (k=0-63).ANMF) in the Rx FIFO element of the received CAN frame.
•
Case 1: When R1.ANMF = 1, then the Rx frame is not relevant for routing
•
Case 2: When R1.ANMF = 0, and R1.FIDX < CRE_STD_RT_PARAM.SIZE (when R0.XTD = 0) or
CRE_XTD_RT_PARAM.SIZE (when R0.XTD = 1), the Rx frame is relevant for routing. Otherwise, the Rx frame
is not relevant for routing
In case routing is disabled (REN is 0), all the frames are considered as routing non-relevant. REN bit is checked
only at the source CAN node of the Routing operation.
Case 1: Routing non-relevant Rx CAN frame
The Received CAN frame is processed according to Table 984 without performing a Routing operation.
Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1).VRH is set to 0, to indicate the corresponding CAN frame stored in Rx
Host Buffer does not have a Routing Header (Routing non-relevant).
Case 2: Routing relevant Rx CAN frame
The CRE Receive Interface passes the CAN frame over to the Routing Control. Routing Control consists of
Routing Tables for both standard ID and extended ID CAN frames. The Routing Tables should be configured by
the user with routing rules (standard ID: SRTk_UCR or SRTk_MCR and extended ID: XRTk_UCR or XRTk_MCR)
that give the destination ID (DID) of CAN frames. The routing destination ID (DID) map is shown in the following
table. After Routing Control has identified the destination of the CAN frame, the Receive Interface performs an
internal CAN routing or external CAN routing depending on the DID.
1.
Internal routing of CAN frames: If the DID belongs to the IDs of the CAN node belonging to the same
MCMCAN as that of the CRE, the CRE Receive Interface provides the CAN frame along to the Transmit
Interface. For example, if the Ni_CRE_CONFIG (i=0-3).ID = 1H and corresponding routing rule configured
in the Routing Table SRTk_UCR (k=0-127).DID = 2H, the frame is routed internally within MCMCAN0 from
CAN node with ID 1H to CAN node with ID 2H
Note:
No Routing header is generated and CAN frame is not written to the respective RHBUF (Rx Host
Buffer) in case of internal routing.
2.
External routing of CAN frames: If the DID does not belong to the IDs of the CAN node belonging to the
same MCMCAN as that of the CRE (Ni_CRE_CONFIG (i=0-3).ID), then CRE Receive Interface generates a
Routing Header (RHBUFk_UCRH (k=0-1) or RHBUFk_MCRH (k=0-1)), writes the Routing Header and the
modified CAN frame to the corresponding Rx Host Buffer. Table 985 explains the processing of external
routing relevant frames. VRH is set to 1, to indicate the corresponding CAN frame stored in Rx Host Buffer
has a valid Routing Header (Routing relevant). When the DID does not belong to any valid destination,
the VRH is not set. The format of the Routing Header is described in RHBUFk_UCRH (k=0-1) or
RHBUFk_MCRH (k=0-1)
The CRE Receive Interface also computes an 16-bit CRC over the CAN headers R0 and R1 (except ESI, ANMF,
RXTS and FIDX which are considered zero for CRC calculation), the safety critical CAN payload and the DID of
CAN frame stored in the Rx Host Buffer. The CRC is calculated over 16-bit data at a time starting with the MSB.
The 32-bit RAM word is divided into two 16-bit words and the highest 16 bits (31:16) is taken first for the CRC
calculation followed by the lower 16 bits (15:0). The CRC calculation and verification is always enabled when
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3965
v1.1
2025-06-26


Ni_CRE_HBUF_RXz_CONFIG (i=0-3;z=0-1).TRIGEN is enabled. The CRC calculation and verification can be
enabled or disabled using Ni_CRE_HBUF_RXz_CONFIG (i=0-3;z=0-1).CRCEN. In case of DIDs belonging to system
memory locations (20H till 3BH), the CRC calculation is not valid and it is ignored by the DRE. The CRC should be
read exactly once as the first element from the Rx Host Buffer by the DRE or by the application. The Receive
Interface stores the computed CRC along with the CAN frame in the Rx Host Buffer. The CRE uses CCITT CRC16
polynomial: 0x1021 x16 + x12 + x5 + 1.
Table 983
Routing destination IDs
Destination
ID (6 bits)
Transfer destination
Destination disabled
0H
-
MCMCAN0_Ni (i=0:3)
1H till 4H
CAN0 Transmit Host Buffer 0
(MCMCAN0_Ni_THBUF0)
MCMCAN1_Ni (i=0:3)
5H till 8H
CAN1 Transmit Host Buffer 0
(MCMCAN1_Ni_THBUF0)
MCMCAN2_Ni (i=0:3)
9H till CH
CAN2 Transmit Host Buffer 0
(MCMCAN2_Ni_THBUF0)
MCMCAN3_Ni (i=0:3)
DH till 10H
CAN3 Transmit Host Buffer 0
(MCMCAN3_Ni_THBUF0)
MCMCAN4_Ni (i=0:3)
11H till 14H
CAN4 Transmit Host Buffer 0
(MCMCAN4_Ni_THBUF0)
ACF Ethernet frames
18H till 1DH
DRE CAN Input Buffer List
System memory locations (1 to 28)
20H till 3BH
User configured by DMEMi (i=0:27)
Reserved for future extension
Others
-
In case of a routing non-relevant frames as shown in Case 1 above or for CAN frames with invalid destination ID,
for example, in case of PDU routing with DID outside the range of System memory locations 20H till 3BH, the
behavior would be as follows:
Table 984
Behavior in case of routing non-relevant frames and invalid DID
Ni_CRE_HBUF_RXz_CONFIG.TRIGE
N
Ni_CRE_HBUF_RXz_CONFIG.INTE
N
Behavior
0
0
Invalid configuration. The frame
just remains in the Receive Host
Buffer.
1
0
The frame is discarded from the
routing operation and there is no
trigger to the DRE
0
1
The frame is written to the Receive
Host Buffer and interrupt is
triggered
1
1
The frame is written to the Receive
Host Buffer and interrupt is
triggered. There is no trigger to the
DRE
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3966
v1.1
2025-06-26


Table 985
Behavior in case of external routing relevant frames
Ni_CRE_HBUF_RXz_CONFIG.TRIGE
N
Ni_CRE_HBUF_RXz_CONFIG.INTE
N
Behavior
0
0
Invalid configuration. The frame
just remains in the Rx Host Buffer.
1
0
The frame is written to Rx Host
Buffer and there is a trigger to the
DRE
0
1
The frame is written to the Rx Host
Buffer and interrupt is triggered
1
1
The frame is written to Rx Host
Buffer and there is a trigger to the
DRE. There is an interrupt trigger as
well. The application needs to
ensure it does not read any
message content that is covered by
the sequence checker in order not
to disrupt the reading of message
by the DRE
Event generation
After the Receive Interface writes the complete frame to the Receive Host Buffer (RHBUF), it generates the new
event by triggering either the DRE or an interrupt to the IR.
•
Trigger to DRE is done through TRIGTYPE[1:0] and TRIGNODE[1:0] interfaces when
Ni_CRE_HBUF_RXz_CONFIG (i=0-3;z=0-1).TRIGEN is set
•
Interrupt to IR Ni_CRE_IR (i=0-3).RBUFzI is triggered when Ni_CRE_HBUF_RXz_CONFIG (i=0-3;z=0-1).INTEN
is set
After the trigger, the Rx Host Buffer New Event (Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1).RHREQ) flag is set to 1 by
hardware indicating a frame is ready to be read from the RHBUF. The software can also trigger the DRE by
setting Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1).SWTRIG to 1 after writing a frame into the RHBUF. The hardware
clears the SWTRIG flag after trigger to DRE.
Multi-cast routing
In case of 1 up to 4 multi-cast routing, the Receive Interface hands over the frame to the Transmit interface in
case of an internal routing. In case of destinations outside the same MCMCAN, the Receive Interface writes the
complete frame to the respective Receive Host Buffer and triggers the DRE. The multi-cast routing with up to 4
DIDs outside the same MCMCAN is broken down into 4 individual uni-cast routing by the CRE. In this case, the
CRE overwrites the Routing header with a new DID and triggers the DRE. The CRE clears the Receive Host Buffer
(RHBUF) contents only after the DRE forwards the frames to the corresponding DID specified in the Routing
Headers. The multi-cast routing rule SRTk_MCR or XRTk_MCR should follow the below configuration rules:
•
At least DID0 and DID1 should have valid destination IDs (1H till 14H or 20H till 3BH)
•
All valid DIDs are different
•
Unused DIDs are set to zero
•
No gaps allowed between valid DIDs. For example,
-
Valid configuration: DID0, DID1 and DID2 are valid
-
Invalid configuration: DID0, DID1 and DID3 are valid. DID2 is set to zero
PDU routing
PDU routing is handled together by CRE and DRE. In case of PDU routing, the CRE Receive Interface:
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3967
v1.1
2025-06-26


•
Converts the CAN frame into an CAN I-PDU (Interaction layer Protocol Data Unit) by generating a PDU
Header along with the Routing and Timing Headers. The PDU Header is of two 32-bit RAM words and
consists of the PDU ID and Payload length.
Note:
PDU Header has the same size of 2 32-bit RAM words as that of R0 and R1 of the CAN frame so that
data location remains the same
•
Writes the CAN I-PDU to the Rx Host Buffer
•
Triggers the DRE
L-32B
FD
ID-20
Data
R0 and R1
Rx CAN frame
Data
Short PDU Header (or) 
Long PDU Header
Timing Header
Routing Header
DID = 20H till 3BH
Data
Timing Header
Routing Header
R0
R1
PDU Routing mode enabled 
(Mode = 2)
PDU Routing mode disabled
PDU Header consists of  
PDU ID and Payload 
length
CAN I-PDU stored in 
RHBUF
CAN frame stored in 
RHBUF
Figure 387
CAN frame to CAN I-PDU conversion
Read completion event
The Receive Host Buffer interrupt or trigger can be used by a master of FPI to read the CAN frame (R0, R1 and
data) from the Receive Host Buffer. The Receive Interface also monitors the address of the Last Word of data to
be read from FPI interface. The 'Last Word' can be configured either as Dynamic Data Length (based on DLC) or
Fixed Data Length through Ni_CRE_HBUF_RXz_CONFIG (i=0-3;z=0-1).LEN. The DRE always reads the Rx Host
Buffer in Dynamic Data Length mode. Fixed Data Length mode is only for software. One data word (DW)
corresponds to 4 bytes.
For example, If the CAN Message has DLC = 4, and the Rx Host Buffer LEN = 2, then:
•
-
Dynamic Data Length
-
The last read operation is DW0 (RHBUFk_RHBUF_DBm (k=0-1;m=0-63))
-
Fixed Data Length
-
The last read operation is DW1 (RHBUFk_RHBUF_DBm (k=0-1;m=0-63))
Note:
When the RTR bit is set, the frame ends at R1 because it has no data. Remote frames configured for
PDU routing are rejected.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3968
v1.1
2025-06-26


On the 'Last Word' read completion event (the entire CAN frame is read from the Rx Host Buffer), the Receive
Interface performs the following actions:
1.
The Rx Host Buffer New Event (Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1).RHREQ) flag is cleared by
hardware
2.
Acknowledge the corresponding RxFIFO by updating the Ni_RXF0A or Ni_RXF1A.FA with the index of the
FIFO element currently processed
3.
On each successful read completion of a frame from the Receive Host Buffer, the Receive Host Buffer
counter (Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1).COUNT) is incremented by 1 (resets to 0 on overflow)
4.
The Receive Interface starts processing the next received CAN frame
In case the DRE Move Engine has an error, it cancels the ongoing read sequence by writing 1 to
CRE_ABORT_SEQ(i=0-3).CRHBUF0 or CRHBUF1 as long as the last read has not been started. A read
sequence error is triggered in this case. Ni_CRE_IR(i=0-3).IRSI0 or IRSI1 error flag (depending on Rx Host
Buffer) is set and interrupt is triggered when Ni_ERRCTRL.IRSIE is enabled. There is no re-trigger to the
DRE. The SW clears the error flags and could read the frame from the respective Rx Host Buffer, or set the
Ni_CRE_HBUF_RXz_STAT.SWTRIG in order to re-trigger the DRE, or write ‘1’ into
Ni_CRE_HBUF_RXz_STAT.RHREQ to free Rx Host Buffer for new frame and discard existing one from Rx
Host Buffer.
Error monitoring
1.
Sequence check: The CRE Receive Interface monitors the incorrect read access to the Rx Host buffer by
an FPI master by checking the sequence in which the message is being read from the Rx Host Buffer (R0,
R1 and DBm). The Routing header, Timing header and CRC are not part of the sequence check. The
sequence checking starts once the FPI master starts reading the first word of the CAN frame or CAN I-
PDU from the Rx Host buffer.
If the message is read in an incorrect sequence, the Ni_CRE_IR(i=0-3).IRSI0 or IRSI1 (depending on Rx
Host Buffer) error flag is set and interrupt is triggered when Ni_ERRCTRL.IRSIE is enabled. DRE is not re-
triggered in this scenario. The SW clears the error flags and could read the frame from the respective Rx
Host Buffer, or set the Ni_CRE_HBUF_RXz_STAT.SWTRIG in order to re-trigger the DRE, or write ‘1’ into
Ni_CRE_HBUF_RXz_STAT.RHREQ to free Rx Host Buffer for new frame and discard existing one from Rx
Host Buffer.
2.
Timeout monitoring:
The CRE Receive Interface also monitors for a delayed read operation by master of FPI. The watchdog
timer counter starts incrementing when timeout enable WDT.EN is set. The watchdog timer triggers
periodic events E1, E2, …, En after a user configured timeout prescaler WDT.FWDP and SWDP. The FWDP
pre-scaler is configured by user for monitoring fast events as shown in Table below. The SWDP prescaler
is configured by user for monitoring slow events as shown in Table below. If FWDP or SWDP are set to
zero, then a default value of 16 is used for the corresponding prescaler. The fast timeout prescaler and
slow timeout prescaler is configured by the user based on the usage of both the RHBUF and THBUF. If
the presence of start condition is detected at Ei, then the end condition is expected to happen before
Ei+1. If not, the corresponding watchdog timeout error flag Ni_CRE_IR(i=0-3).RWDTI0 or RWDTI1 is set
and interrupt is triggered whenNi_ERRCTRL(i=0-3).RWD0IE or RWD1IE is enabled. DRE is not re-triggered
in this scenario. The SW clears the error flags and could read the frame from the respective Rx Host
Buffer, or set the Ni_CRE_HBUF_RXz_STAT.SWTRIG in order to re-trigger the DRE, or write ‘1’ into
Ni_CRE_HBUF_RXz_STAT.RHREQ to free Rx Host Buffer for new frame and discard existing one from Rx
Host Buffer.
The watchdog counter is running at the host clock frequency fMCANH . The timeout period between the
events Ei is calculated as follows:
•
Default timeout period : Tdef =
16
fMCANH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3969
v1.1
2025-06-26


•
Fast timeout period : Tfast = Tdef * FWDP + 1
•
Slow timeout period : Tslow = Tdef * SWDP + 1
Table 986
Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within a single event Ei
No timeout error. No timeout interrupt triggered
End condition is true within two consecutive events
Ei
If the presence of start condition is detected at Ei,
then the end condition is expected to happen
before Ei+1. If not, timeout interrupt is triggered
End condition is true after two consecutive events
Ei
Timeout interrupt is triggered
Table 987
RHBUF : Start and end condition list
Start condition
(SC)
End condition (EC) Direction
Event type
Enable
RxFIFO not empty
RxFIFO processing
done
Source
Fast event
When
Ni_ERRCTRL.WDG1
is enabled
RHBUF empty
RHBUF full
Source
Slow event
When
Ni_ERRCTRL.WDG2
is enabled
RHBUF full
RHBUF empty
Source
Slow event
When
Ni_ERRCTRL.WDG3
is enabled
Note:
Timeout monitoring does not apply to routing non-relevant frames
Related information
Timestamping unit (TSU) on page 3944
Internal timestamp generation on page 3944
Intrusion detection measurement unit (IDMU) on page 3978
Transmit Interface on page 3973
21.6.3.2
Routing control
The Routing Control along with the Routing Table decides the destination location of the received CAN frame
and formats the CAN frame as defined by the Routing rule.
Routing table
The Routing Table contains a number of user configured Routing rules. The Routing rules define the destination
of the CAN frame. The destination can be another CAN interface or Ethernet interface or a system memory
location. It also provides the possibility to change the CAN Frame Format Classical/CAN FD Frame, Data Length
and ID of the CAN frame.
Each CAN node can have two Routing Tables
•
Standard ID Routing Table - Containing the routing rules for Rx CAN frames with standard 11-bit CAN ID
•
Extended ID Routing Table - Containing the routing rules for Rx CAN frames with extended 29-bit CAN ID
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3970
v1.1
2025-06-26


The start address of the Routing Table is configured in CRE_STD_RT_PARAM.SA and number of Routing rules for
standard CAN IDs is configured using CRE_STD_RT_PARAM.SIZE. Similarly for extended CAN IDs at
CRE_XTD_RT_PARAM.SA and CRE_XTD_RT_PARAM.SIZE.
Each Routing rule, supports three modes of routing:
•
Uni-cast Routing rule (Mode = 0)
-
Only one configurable destination
-
CAN frame modification is possible
•
Multi-cast Routing rule (Mode = 1)
-
Up to 4 configurable destinations
-
CAN frame modification not possible
•
PDU Routing rule (Mode = 2)
-
Only one configurable destination
-
PDU header generation and automatic PDU ID creation is based on the PDU header type configuration
-
Optional software configurable "Metadata"
The format of the standard ID Uni-cast and Multi-cast Routing rules are given in SRT_UCR and SRT_MCR
respectively.
The format of the extended ID Uni-cast and Multi-cast Routing rules are given in XRT_UCR and XRT_MCR
respectively.
CAN frame modifiers
When Uni-cast Routing mode is used (Mode = 0), then the CRE can modify the following properties of the
received CAN frame based on the following configuration parameters of the Uni-cast Routing rule.
1.
FDF (CAN FD Format)
a.
If SRT_UCR.FDFM = 0, the FDF bit is ignored and the CAN frame format is not changed. The frame
format is kept same as that of the received CAN frame
b.
If SRT_UCR.FDFM = 1, the CAN frame format is changed to either Classical CAN frame (FDF = 0) or
CAN FD frame format (FDF = 1)
Note:
When a CAN-FD frame of more than 8 bytes is configured to be changed to classic CAN
format, only the first 8 bytes will be transmitted and remaining data is truncated
2.
DLC (Data Length Code)
a.
If SRT_UCR or XRT_UCR.DLC = 0, the Destination CAN frame length is same as the source CAN
frame
b.
If SRT_UCR or XRT_UCR.DLC != 0, the Destination CAN frame length is as defined by ISO 11898-1.
The DLC configured in the routing rule must be smaller than the actual frame DLC. When DLC
configured in the Routing rule is larger than the frame DLC, the additional bytes will contain
undefined values in the Rx Host Buffer
3.
IDXOR (CAN ID Modifier)
a.
For Standard ID, the Destination CAN Frame ID = SRT_UCR.IDXOR (XORed) Rx_CANID
b.
For Extended ID, the Destination CAN frame ID = [XRT_UCR.IDXOR << XRT_UCR.IDSHIFT] (XORed)
Rx_CANID
Note:
Both the source and destination nodes in the system should be aware of the frame modifications so
that any potential truncation or modification of the safety critical payload can be avoided or properly
handled by the system integrator.
Routing table index
The indexing of the Routing Table is done based upon the receive acceptance filter ID. The Acceptance Filter ID
is stored along with the CAN frame in the Receive Buffer, RXMSGk_R1A or RXMSGk_R1B.FIDX. The Rx CAN frames
which are accepted by Acceptance Filter ID0 has the corresponding Routing rule stored at address (in words)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3971
v1.1
2025-06-26


Offset ’0’ from the start of the Routing Table, similarly Acceptance Filter ID1 corresponds to address (in words)
Offset '1' of Routing Table and so on.
Desired Routing Index:
Standard ID Routing rule Address = CRE_STD_RT_PARAM.SA + R1.FIDX × 4
Extended ID Routing rule Address = CRE_XTD_RT_PARAM.SA + R1.FIDX × 4
Hence it is essential to consider during the Acceptance Filter (AF) configuration, that AF configuration
corresponding to the CAN Frames which are to be routed should start with the first AF element 0. A total of up to
128 standard ID Routing rules and 64 extended ID Routing rules can be configured.
PDU routing rule
The PDU routing mode is enabled, when SRTk_PR.Mode is configured as 0x2. The user shall configure the
Routing rule "DID" to one of the System memory locations (20H till 3BH). The Routing rule also consists of the
"PDU header type", which is used to configure the PDU header contents. Short PDU Header is of 1 RAM word
and Long PDU Header is of 2 RAM words.
•
Type 1: 11-bit Standard CAN ID with no Metadata
•
Type 2: 11-bit Standard CAN ID with Metadata
•
Type 3: 11-bit Standard CAN ID with optional Metadata
•
Type 4: 29-bit Extended CAN ID with no Metadata
•
Type 5: 29-bit Extended CAN ID with no Metadata and no Source ID
Note:
Type 5: If the CAN ID is unique per CAN node, the system can identify the CAN node without the
Source ID. Last 3 bits are reserved
Type 4: Only first 27 bits of the 29-bit ID are used
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3972
v1.1
2025-06-26


CAN ID(11 bits)
Source ID(5 bits)
Reserved
DLC(4 bits)
Type 1 Short PDU Header(1 word)
Metadata(bits [7:0])
Type 3 Long PDU Header(2 words)
PDU ID
TYPE
SPDUH
SPDUH
LPDUH1
LPDUH0
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
Type 2 Short PDU Header(1 word)
CAN ID(11 bits)
Source ID(5 bits)
R
DLC(4 bits)
TYPE
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
Reserved
DLC(4 bits)
TYPE
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
Metadata(16 bits)
CAN ID(11 bits)
Source ID(5 bits)
Type 4 Long PDU Header(2 words)
LPDUH1
LPDUH0
Reserved
DLC(4 bits)
TYPE
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
CAN ID(bits [28:2])
Source ID(5 bits)
Type 5 Long PDU Header(2 words)
LPDUH1
LPDUH0
Reserved
DLC(4 bits)
TYPE
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  9  8  7  6  5  4  3  2  1  0  
CAN ID(29 bits)
Reserved
Figure 388
PDU Header types
21.6.3.3
Transmit Interface
The Transmit Interface abstracts the following operation related to TxFIFO or TxQueue for the user
•
Address calculation to identify the available TxFIFO (or Tx Queue) element
•
Setting a new transmit request for the corresponding TxFIFO (or Tx Queue) element
The Transmit Interface can get two types of transmit requests
•
External transmit requests - a master of FPI initiates transmission of a new CAN frame.
A master of FPI can write a CAN frame to be transmitted to the CAN Tx Host Buffer (THBUF) instead of the
TxFIFO(Queue). The CRE assists the writing by providing a interrupt/trigger for each free TxFIFO(Queue)
element
•
Internal transmit requests - the CRE Receive Interface initiates transmission of a CAN frame due to internal
CAN routing operation.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3973
v1.1
2025-06-26


Transmit Interface can also get a new CAN frame from the CRE Receive Interface, if the destination of the
CAN frame is configured by the Routing Table as another CAN Node belonging to the same MCMCAN
module. The Transmit Interface identifies the destination CAN Node, with the help of DID in Routing Header
External transmit request
The CRE Transmit Interface first identifies a free element in the TxFIFO or Tx Queue based on the Put Index.
Identify free Tx buffer element in TxFIFO or Tx Queue
If the TxFIFO/TxQueue is not full, that is, Ni_TXFQS (i=0-3).TFQF = 0, then Tx FIFO Put Index Ni_TXFQS
(i=0-3).TFQPI, points to the next Free Transmit Buffer in the Tx FIFO/TxQueue. The Ni_CRE_HBUF_TXz_STAT
(i=0-3;z=0-1).INDEX points to the identified Put Index of TxFIFO/Tx Queue. Upon identifying a free transmit
buffer element,
•
Checks for a pending frame in the Tx Host Buffer (Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).THREQ is set to 1B)
•
In case of a pending frame in the Tx Host Buffer, the Transmit Interface
-
Copies the CAN frame from the Tx Host Buffer to the identified Tx Buffer element in TxFIFO or Tx Queue
-
Set transmit request (Ni_TXBAR (i=0-3).AR) of the corresponding Tx buffer element
-
On each successful write completion of a new transmit frame to the TxFIFO or Tx Queue, the
Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).COUNT is incremented by 1B(resets to 0 upon overflow)
-
Sets Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).THREQ to 0B. Then it starts identifying the next available Tx
Buffer element in the TxFIFO or TxQueue
•
In case a Tx Host Buffer is empty, the Transmit Interface triggers either
-
Trigger to DRE: TRIGTYPE[1:0], TRIGNODE[1:0] or
-
Interrupt to IR: Ni_CRE_IR.TBUF0I or TBUF1I
correspondingly based on the configuration of Ni_CRE_HBUF_TXz_CONFIG (i=0-3;z=0-1).INTEN.
Note:
Only Tx Host Buffer 0 shall be configured to trigger to DRE.
At the destination CAN node, Ni_CRE_CONFIG (i=0-3).DEN is checked by the CRE before the CAN frame is written
to the TxFIFO.
Table 988
Routing behavior based on DEN configuration
Use-case
Ni_CRE_CONFIG.EN
Ni_CRE_CONFIG.DEN
Behavior
Internal
0
0
No routing enabled.
Frame is discarded
Internal
0
1
Frame is routed to the
destination TxFIFO
Internal
1
0
Frame is discarded
Internal
1
1
Frame is routed to the
destination TxFIFO
External
0
0
No routing enabled. No
triggers
External
0
1
No routing enabled. No
triggers
External
1
0
Frame remains in the Tx
Host buffer. No re-trigger
is performed.
External
1
1
Frame is routed to the
destination TxFIFO
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3974
v1.1
2025-06-26


Note:
DEN=0 is used to isolate a CAN node in case of any bus error where the CAN frame is not expected to be
written to the TxFIFO by the CRE
The CRE should be enabled and the Host Buffers need to be configured after the DRE is enabled. A free Tx Host
Buffer is indicated by Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).THREQ = 0B. The trigger or the interrupt is used by
master of FPI to write a new Transmit CAN frame to the Tx Host Buffer.
Tx Host Buffer 1 shall be configured to trigger interrupt to IR. Based on the interrupt, Tx Host Buffer 1 can be
dedicated for System DMA. One System DMA channel is configured per CAN node. The interrupt
Ni_CRE_IR(i=0-3).TBUF0/1I indicates the System DMA that the THBUF is ready to receive a new CAN frame. The
software then writes the CAN frame to the system memory in dedicated buffers per CAN node. The System DMA
reads each CAN frame from the system memory location and writes the CAN frame to the corresponding
THBUF. The number of CAN frames transmitted is indicated in the Ni_CRE_HBUF_TXz_STAT
(i=0-3;z=0-1).COUNT bit-field.
The Transmit Interface identifies the start of Transmit frame (T0, T1 and DBm) write by a FPI master by
monitoring the write to the First Word of the Tx Host Buffer. The format of the Transmit Host Buffer is given in
THBUFk_T0, THBUFk_T1 and THBUFk_DBm (m=0-63).
Write completion event
The Transmit Interface monitors the address of the "Last Word" of the Tx Host Buffer to be written by master of
FPI interface. The "Last Word” can be configured either as Dynamic Data Length (based on DLC) or Fixed Data
Length (Ni_CRE_HBUF_TXz_CONFIG.LEN). The configuration of last word can be done by programming
Ni_CRE_HBUF_TXz_CONFIG (i=0-3;z=0-1).LWM. The DRE always writes into the Tx Host Buffer 0 in Dynamic Data
Length mode. Fixed Data Length mode is only for the software. One data word (DW) corresponds to 4 bytes.
For example: If the Tx CAN frame has DLC = 4 and the Tx Host Buffer LEN = 2, then
•
Dynamic Data Length: The last write operation is "DW0" (THBUFk_DBm (m=0-63))
•
Fixed Data Length (8 bytes): The last write operation is "DW1" (THBUFk_DBm (m=0-63))
Upon the “the Last Word” write completion event (the entire CAN frame is written to the Tx Host Buffer), the
Transmit Interface performs the following actions
1.
Sets Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).THREQ to 1B indicating Tx Host Buffer full
2.
Copies the CAN frame from the Tx Host Buffer to the identified Tx Buffer element in TxFIFO or Tx Queue
3.
Set transmit request (Ni_TXBAR (i=0-3).AR) of the corresponding Tx buffer element
4.
On each successful write completion of a new transmit frame to the TxFIFO or Tx Queue, the
Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).COUNT is incremented by 1B(resets to 0 upon overflow)
5.
The Transmit Interface sets Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1).THREQ to 0B. Then it starts identifying
the next available Tx Buffer element in the TxFIFO or TxQueue
In case the DRE Move Engine has an error, it cancels the ongoing write sequence by writing 1 to
CRE_ABORT_SEQ(i=0-3).CTHBUF as long as the last write has not been launched. A write sequence error
is launched in this case. Ni_CRE_IR.IWSI0 error flag is set and interrupt is triggered when
Ni_ERRCTRL.IWSIE is enabled. There is no re-trigger to the DRE. The SW clears the error flags and could
read the frame from the respective Tx Host Buffer, or set the Ni_CRE_HBUF_TXz_STAT.SWTRIG in order to
re-trigger the DRE, or write ‘1’ into Ni_CRE_HBUF_TXz_STAT.THREQ to free Tx Host Buffer for new frame
and discard existing one from Tx Host Buffer.
Internal transmit request
The Transmit Interface gets the CAN frame along with a Routing Header from the Receive Interface in case of
internal MCMCAN routing. The Transmit Interface identifies the destination CAN Node from the DID in the
Routing Header. The Transmit Interface identifies a free Tx FIFO/Queue Element from the corresponding CAN
node. It writes the CAN frame to the identified Tx FIFO/Queue element and sets the corresponding Transmit
Request (Ni_TXBAR.AR). The Transmit Interface then acknowledges back the Receive Interface to indicate that
the internal routing is performed. After the acknowledge, the Receive Interface performs the following
operation
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3975
v1.1
2025-06-26


1.
Acknowledge the corresponding RxFIFO by updating the Ni_RXF0A or Ni_RXF1A.FA with the index of the
FIFO element currently processed
2.
Clear RxFIFO New Message Flag Ni_IR (i=0-3).RF0N or RF1N
The Transmit Interface after setting the Transmit Request (Ni_TXBAR.AR), it starts identifying the next available
Tx Buffer element in the TxFIFO or TxQueue.
Error monitoring
1.
Sequence check: The CRE Transmit Interface monitors the incorrect write access to the Tx Host Buffer by
an FPI master by checking the sequence in which the message is being written to the Tx Host Buffer(T0,
T1 and DBm). The sequence checking starts once the FPI master starts writing the first word of the CAN
frame to the Tx Host buffer.
If the message is later written in an incorrect sequence, the Ni_CRE_IR.IWSI0 or IWSI1 (depending on the
Tx Host Buffer) error flag is set and interrupt is triggered when Ni_ERRCTRL.IWSIE is enabled. There is no
re-trigger of the DRE. The SW clears the error flags and could read the frame from the respective Tx Host
Buffer, or set the Ni_CRE_HBUF_TXz_STAT.SWTRIG in order to re-trigger the DRE, or write ‘1’ into
Ni_CRE_HBUF_TXz_STAT.THREQ to free Tx Host Buffer for new frame and discard existing one from Tx
Host Buffer.
2.
CRC verification: The DRE or application generates an 16-bit CRC over the CAN headers R0 and R1
(except ESI, ANMF, RXTS and FIDX), the safety critical CAN payload and the DID using CCITT CRC16
polynomial: 0x1021 x16 + x12 + x5 + 1 . The CRC is calculated over 16 bits of data at a time starting
with the MSB. The DRE or the application should write the CRC along with the CAN frame into the Tx
Host Buffer. After the CAN frame is written to the Tx Host Buffer, CRE Transmit Interface verifies the CRC
and the DID before writing the CAN frame to the Tx FIFO/Tx Queue. If there is a mismatch between the
calculated CRC and the received CRC, the Ni_CRE_IR.CRCI0 or CRCI1 (depending on the Tx Host Buffer)
interrupt is triggered when the CRC error interrupt is enabled in Ni_ERRCTRL.CRCIE. The processing of
the frame is based on the Ni_CRE_HBUF_TXz_CONFIG.CRCG. In case the CRCG is set to 0, the CAN frame
is processed further and written to the TxFIFO. In case the CRCG is set to 1, the CAN frame is discarded in
the Host buffer. There is no re-trigger of the DRE. The SW clears the error flags and could read the frame
from the respective Tx Host Buffer, or set the Ni_CRE_HBUF_TXz_STAT.SWTRIG in order to re-trigger the
DRE. The user must ensure that the size of the TxFIFO or TxQueue is large enough to store the data from
the Tx Host Buffer in order to avoid unwanted CRC error.
3.
Timeout monitoring: The CRE Transmit Interface monitors for a delayed write operation by master of
FPI. The watchdog timer counter starts incrementing when timeout enable WDT.EN is set. The watchdog
timer triggers periodic events E1, E2, …, En after a user configured timeout prescaler WDT.FWDP or
SWDP. The FWDP pre-scaler is configured by user for monitoring fast events as shown in Table below.
The SWDP pre-scaler is configured by user for monitoring slow events as shown in Table below. If FWDP
or SWDP are set to zero, then a default value of 16 is used for the corresponding prescaler. The fast
timeout prescaler and slow timeout prescaler is configured by the user based on the usage of both the
RHBUF and THBUF. If the presence of start condition is detected at Ei, then the end condition is expected
to happen before Ei+1. If not, the corresponding watchdog timeout error flag Ni_CRE_IR.TWDTI0 or
TWDT1 is set and interrupt triggered when Ni_ERRCTRL.TWD0IE or TWD1IE is enabled. There is no
re-trigger of the DRE. The SW clears the error flags and could read the frame from the respective Tx
Host Buffer, or set the Ni_CRE_HBUF_TXz_STAT.SWTRIG in order to re-trigger the DRE, or write ‘1’ into
Ni_CRE_HBUF_TXz_STAT.THREQ to free Tx Host Buffer for new frame and discard existing one from Tx
Host Buffer.
The watchdog counter is running at the host clock frequency fMCANH . The timeout period between the events
Ei is calculated as follows:
•
Default timeout period : Tdef =
16
fMCANH
•
Fast timeout period : Tfast = Tdef * FWDP + 1
•
Slow timeout period : Tslow = Tdef * SWDP + 1
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3976
v1.1
2025-06-26


Table 989
Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within a single event Ei
No timeout error. No timeout interrupt triggered
End condition is true within two consecutive events Ei
If the presence of start condition is detected at Ei,
then the end condition is expected to happen before
Ei+1. If not, timeout interrupt is triggered
End condition is true after two consecutive events Ei
Timeout interrupt is triggered
Table 990
THBUF : Start and end condition list
Start condition
End condition
Direction
Event type
Enable
THBUF empty
THBUF full
Destination
Slow event
When
Ni_ERRCTRL.WDG2
is enabled
THBUF full
THBUF empty
Destination
Fast event
When
Ni_ERRCTRL.WDG1
is enabled
21.6.3.4
Trigger function
The CRE can generate triggers to DRE for Rx Host Buffers and Tx Host Buffers. The trigger events are encoded as
given in the following tables.
The signal TRIGTYPE[1:0] indicates a new trigger event corresponding to a Host Buffer. The signal
TRIGNODE[1:0] indicates the CAN Node which the Host Buffer belongs to. Initially, the TRIGTYPE[1:0] and
TRIGNODE[1:0] are 00b. The CRE, upon detecting the trigger event of a Host Buffer, sets the TRIGTYPE[1:0] and
TRIGNODE[1:0] to corresponding level.
Table 991
TRIGTYPE description
TRIGTYPE(1)
TRIGTYPE(0)
Description
0B
0B
No Trigger or Idle
0B
1B
Transmit Host Buffer 0 free
1B
0B
New Receive Host Buffer 0
1B
1B
New Receive Host Buffer 1
Table 992
TRIGNODE description
TRIGNODE(1)
TRIGNODE(0)
Description
0B
0B
CANx_N0
0B
1B
CANx_N1
1B
0B
CANx_N2
1B
1B
CANx_N3
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3977
v1.1
2025-06-26


21.6.3.5
Intrusion detection measurement unit (IDMU)
The IDMU assists with intrusion detection by measuring the following timing parameters and updating the
Timing Header (THEAD) for each received frame that has the routing destination outside the MCMCAN.
•
Inter Arrival Measure (RHBUFk_THEAD_INTRD (k = 0-1).IAM)
•
Frame Rate Measure (SFRk_FR (k = 0-63) or XFRk_FR (k = 0-31))
•
Rx Throughput Measure (Ni_IDMU_RXTPCFG (i = 0-3).TP)
The IDMU consists of a Timestamp Database and Frame Rate Measure Table as shown in the following figure. All
the IDMU Tables are part of the CRE RAM as shown in table CRE RAM Structure, see related information. The
Timestamp Database stores the previous received timestamp (Reference Timestamp) of CAN frame(s)
corresponding to a Acceptance Filter ID. The Frame Rate Measure Table consists of frame counters for each
Acceptance Filter ID, that increment with reception of each frame accepted by the filter.
Rx Acceptance 
Filters
CANx RxFIFO 0/1
CANx
STD CAN Acceptance 
Filter ID 0 & 1
...
IDMU
CRE
FR 0
FR 1
FR 3
FR 2
FR 127
FR 126
RTS 0
RTS 1
RTS 127
...
...
...
Standard Frame Rate Measure table
Standard Timestamp Database
FR 0
FR 1
FR 3
FR 2
FR 63
FR 62
...
...
Extended Frame Rate Measure table
RTS 0
RTS 1
RTS 63
...
Extended Timestamp Database
...
STD CAN Acceptance 
Filter ID 7E & 7F
XTD CAN Acceptance 
Filter ID 0 & 1
XTD CAN Acceptance 
Filter ID 3E & 3F
Figure 389
IDMU
Inter arrival measure
When there is valid timestamp available, the IAM is calculated for each frame by calculating the difference
between the current received timestamp RHBUFk_THEAD_RXTS (k=0-1) and the Reference Timestamp
STSDk_RTS (k=0-127) or XTSDk_RTS (k=0-63) which is fetched from the Reference Timestamp Database for the
corresponding Acceptance Filter ID. The Reference Timestamp Database is updated with the last timestamp to
compute the IAM of the next frame. Similar to the routing table, the indexing of the Reference Timestamp
Database and Frame Rate Measure Table are done based upon the receive Acceptance Filter ID as shown in the
figure above.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3978
v1.1
2025-06-26


The IAM of each frame is part of the Timing Header THEAD.
For Standard ID CAN frame(s) :
RHBUFk_THEAD_INTRD.IAM = RHBUFk_THEAD_RXTS.RXTS −STSDk_RTS.TS
For Extended ID CAN frame(s) :
RHBUFk_THEAD_INTRD.IAM = RHBUFk_ THEAD_RXTS.RXTS −XTSDk_RTS.TS
When there is an overflow of the timebase counter and the current timestamp is smaller than the Reference
Timestamp,
RHBUFk_THEAD_INTRD.IAM =
MaxValue Of Timestamp −STSDk_RTS.TS +
RHBUFk_THEAD_RXTS.RXTS + 1
The value of "MaxValueOfTimestamp" is computed based on the maximum value of TSCLEN.
The calculated IAM is written to the Timing Header RHBUFk_THEAD_INTRD (k=0-1).IAM and
RHBUFk_THEAD_INTRD (k=0-1).IAMSTAT is set to 1.
If there was a loss of timestamp the RHBUFk_THEAD_INTRD (k=0-1).TSL is set. But the IAM is calculated with the
latest available valid timestamp.
The Receive Interface fetches only valid timestamps. In case of no valid timestamp available or in case of the
first frame received which will not have a Reference Timestamp to calculate the IAM, there is no IAM calculated
and RHBUFk_THEAD_INTRD (k=0-1).IAMSTAT = 0.
Frame rate measure
The Frame Rate Measures SFRk_FR (k=0-63) are counters associated with each Acceptance Filter ID, which
increment with reception of each frame. The start address of the Frame Rate Measure table and the size can be
configured in CRE_STD_FRT_PARAM. Similarly for extended CAN IDs at CRE_XTD_FRT_PARAM.
Each entry of the Frame Rate Measure Table consists of two Frame Rate Measure counters FR1 and FR2,
corresponding to two Acceptance Filter IDs (FID). The indexing of the Frame Rate Measures are based on the
LSB of the FID. Each Frame Rate Measure counter is of 16 bits. The Frame Rate Measure counters are controlled
by Ni_IDMU_FRTCONFIG (i=0-3).STDLOCK or XTDLOCK. Reading of the frame rate is recommended to be done in
a timer-based interrupt service routine which sets the STDLOCK or XTDLOCK is '1' correspondingly . The Frame
Rate Measures freeze whenever the STDLOCK/XTDLOCK is set to 1. The Frame Rate Measure counters and the
STDLOCK/XTDLOCK bit must be reset to 0 by software after reading. The Frame Rate Measure counters start
incrementing again with the reception of the next frame.
If frames are received while the STDLOCK/XTDLOCK bit is set, there is a loss of Frame Rate Measure count and
an interrupt SFRMLI or XFRMLI is triggered when Ni_IDMU_FRTCONFIG.INTEN0 or Ni_IDMU_FRTCONFIG.INTEN1
is enabled.
Rx throughput measure
The Rx Throughput Measure Ni_IDMU_RXTPCFG (i=0-3).TP is a counter per CAN node. The Receive Interface
identifies newly received CAN frames based on the RxFIFO fill level Ni_RXF0S (i=0-3).F0FL (or) Ni_RXF1S
(i=0-3).F1FL. The Rx Throughput Measure counter TP increments whenever there is a new message. Reading of
the Rx Throughput Measure counter is recommended to be done in a timer-based interrupt service routine. TP
can be reset to 0 by software after reading.
Related information
Functional description on page 3962
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3979
v1.1
2025-06-26


21.7
Registers
21.7.1
Register overview - access mode glossary
Table 993
Register overview - access mode glossary
Keyword
Description
E
Access protection using PROT register PROTE.
SE
Access protection using PROT register PROTSE.
APU-PNi (i=0-3)
Protection group consisting of registers Ni_ACCEN_WRA, Ni_ACCEN_WRB, Ni_ACCEN_RDA,
Ni_ACCEN_RDB, Ni_ACCEN_VM, Ni_ACCEN_PRS.
PNi
Access protection using APU-PNi registers.
APU-P4
Protection group consisting of registers ACCEN_WRA, ACCEN_WRB, ACCEN_RDA, ACCEN_RDB,
ACCEN_VM, ACCEN_PRS.
P4
Access protection using APU-P4 registers.
BE
Always returns a Bus Error.
U
No access restrictions.
PROT
Access restrictions as defined in the PROT register access rules.
nBE
Indicates that no Bus Error is generated when accessing this address range, even though it is
either an access to an undefined address or the access does not follow the given rules.
M
Indicates a module specific access condition. Refer to the register description for details of
the specific access condition.
21.7.2
Register overview - CAN domain SFR (ascending offset address)
Table 994
Register overview - CAN domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CLC
Clock Control Register
00000H
P4
P4, SV, E
See 3989
3989
OCS
OCDS Control and Status
Register
00004H
P4
SV, P4
Debug Reset
3990
ID
Module Identification
Register
00008H
P4
BE
PowerOn Reset
3991
RST_CTRLA
Reset Control Register A
0000CH
P4
P4, SV, E
Application
Reset
3991
RST_CTRLB
Reset Control Register B
00010H
P4
P4, SV, E
Application
Reset
3992
RST_STAT
Reset Status Register
00014H
P4
BE
Application
Reset
3993
PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3993
PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3995
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3980
v1.1
2025-06-26


Table 994
(continued) Register overview - CAN domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
ACCEN_WRA
Write access enable register
A
00030H
U
SE, SV
Application
Reset
3997
ACCEN_WRB
Write access enable register
B
00034H
U
SE, SV
Application
Reset
3997
ACCEN_RDA
Read access enable register
A
00038H
U
SE, SV
Application
Reset
3998
ACCEN_RDB
Read access enable register
B
0003CH
U
SE, SV
Application
Reset
3998
ACCEN_VM
VM access enable register
00040H
U
SE, SV
Application
Reset
3999
ACCEN_PRS
PRS access enable register
00044H
U
SE, SV
Application
Reset
3999
MCR
Module Control Register
00070H
P4
P4
See 4001
4001
BUFADR
Buffer receive address and
transmit address
00074H
P4
P4
Kernel Reset
4003
MECR
Measure Control Register
00080H
P4
P4
Kernel Reset
4004
MESTAT
Measure Status Register
00084H
P4
P4
Kernel Reset
4005
WDT
CRE Watchdog timer
register
00088H
P4
SV, E, P4
Kernel Reset
4006
Ni_ACCEN_WRA
Node i Write access enable
register A
00100H+i
*400H
U
SE, SV
Application
Reset
4007
Ni_ACCEN_WRB
Node i Write access enable
register B
00104H+i
*400H
U
SE, SV
Application
Reset
4008
Ni_ACCEN_RDA
Node i Read access enable
register A
00108H+i
*400H
U
SE, SV
Application
Reset
4008
Ni_ACCEN_RDB
Node i Read access enable
register B
0010CH+
i*400H
U
SE, SV
Application
Reset
4009
Ni_ACCEN_VM
Node i VM access enable
register
00110H+i
*400H
U
SE, SV
Application
Reset
4009
Ni_ACCEN_PRS
Node i PRS access enable
register
00114H+i
*400H
U
SE, SV
Application
Reset
4010
Ni_STARTADR
Node i Start Address
00120H+i
*400H
PNi
SV, E, PNi
Application
Reset
4010
Ni_ENDADR
Node i End Address
00124H+i
*400H
PNi
SV, E, PNi
Application
Reset
4011
Ni_INTRSIG
Node i Interrupt Signalling
Register
00128H+i
*400H
PNi
nBE
Kernel Reset
4011
Ni_G0INTR
Node i Interrupt routing for
Group 0
0012CH+
i*400H
PNi
PNi
Kernel Reset
4013
Ni_G1INTR
Node i Interrupt routing for
Group 1
00130H+i
*400H
PNi
PNi
Kernel Reset
4014
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3981
v1.1
2025-06-26


Table 994
(continued) Register overview - CAN domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_G2INTR
Node i Interrupt routing for
Group 2
00134H+i
*400H
PNi
PNi
Kernel Reset
4015
Ni_TIMER_CCR
Node i Timer Clock Control
Register
00138H+i
*400H
PNi
PNi
Kernel Reset
4015
Ni_TIMER_TXTRI
G0
Node i Timer Transmit
Trigger 0 Register
0013CH+
i*400H
PNi
PNi
Kernel Reset
4016
Ni_TIMER_TXTRI
G1
Node i Timer Transmit
Trigger 1 Register
00140H+i
*400H
PNi
PNi
Kernel Reset
4017
Ni_TIMER_TXTRI
G2
Node i Timer Transmit
Trigger 2 Register
00144H+i
*400H
PNi
PNi
Kernel Reset
4018
Ni_TIMER_RXTO
UT
Node i Timer Receive
Timeout Register
00148H+i
*400H
PNi
PNi
Kernel Reset
4018
Ni_PORTCTRL
Node i Port Control Register 0014CH+
i*400H
PNi
PNi
Kernel Reset
4019
Ni_CRE_CONFIG
Node i CRE Configuration
Register
00150H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4020
Ni_CRE_CONFIG
ADR
Node i CRE Configuration
Start Address
00154H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4022
Ni_CRE_HBUF_R
Xz_CONFIG
Node i Receive Host Buffer z
Configuration
00158H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4022
Ni_CRE_HBUF_R
Xz_STAT
Node i Receive Host Buffer z
Status
0015CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4024
Ni_CRE_HBUF_T
Xz_CONFIG
Node i Transmit Host Buffer
z Configuration
00168H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4025
Ni_CRE_HBUF_T
Xz_STAT
Node i Transmit Host Buffer
z Status
0016CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4026
Ni_CRE_IR
Node i CRE Interrupt
Register
0018CH+
i*400H
PNi
PNi
Kernel Reset
4028
Ni_IDMU_FRTCO
NFIG
Node i Frame Rate Measure
Table Configuration
00190H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4029
Ni_IDMU_RXTPC
FG
Node i Rx Throughput
Measure configuration
00194H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4030
Ni_ERRCTRL
Node i CRE Error control
register
00198H+i
*400H
P4
SV, E, P4
Kernel Reset
4031
Ni_CREL
Node i Core Release
Register
00200H+i
*400H
PNi
nBE
Kernel Reset
4032
Ni_ENDN
Node i Endian Register
00204H+i
*400H
PNi
nBE
Kernel Reset
4033
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3982
v1.1
2025-06-26


Table 994
(continued) Register overview - CAN domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_DBTP
Node i Data Bit Timing &
Prescaler Register
0020CH+
i*400H
PNi
PNi
See 4034
4034
Ni_TEST
Node i Test Register
00210H+i
*400H
PNi
PNi
See 4035
4035
Ni_RWD
Node i RAM Watchdog
00214H+i
*400H
PNi
PNi
Kernel Reset
4036
Ni_CCCR
Node i CC Control Register
00218H+i
*400H
PNi
PNi
See 4037
4037
Ni_NBTP
Node i Nominal Bit Timing
& Prescaler Register
0021CH+
i*400H
PNi
PNi
See 4040
4040
Ni_TSCC
Node i Timestamp Counter
Configuration
00220H+i
*400H
PNi
PNi
Kernel Reset
4041
Ni_TSCV
Node i Timestamp Counter
Value
00224H+i
*400H
PNi
PNi
Kernel Reset
4042
Ni_TOCC
Node i Timeout Counter
Configuration
00228H+i
*400H
PNi
PNi
Kernel Reset
4043
Ni_TOCV
Node i Timeout Counter
Value
0022CH+
i*400H
PNi
PNi
Kernel Reset
4044
Ni_ECR
Node i Error Counter
Register
00240H+i
*400H
PNi
nBE
Kernel Reset
4045
Ni_PSR
Node i Protocol Status
Register
00244H+i
*400H
PNi
nBE
Kernel Reset
4045
Ni_TDCR
Node i Transmitter Delay
Compensation Register
00248H+i
*400H
PNi
PNi
Kernel Reset
4049
Ni_IR
Node i Interrupt Register
00250H+i
*400H
PNi
PNi
Kernel Reset
4050
Ni_IE
Node i Interrupt Enable
00254H+i
*400H
PNi
PNi
Kernel Reset
4053
Ni_GFC
Node i Global Filter
Configuration
00280H+i
*400H
PNi
PNi
Kernel Reset
4056
Ni_SIDFC
Node i Standard ID Filter
Configuration
00284H+i
*400H
PNi
PNi
See 4057
4057
Ni_XIDFC
Node i Extended ID Filter
Configuration
00288H+i
*400H
PNi
PNi
Kernel Reset
4058
Ni_XIDAM
Node i Extended ID AND
Mask
00290H+i
*400H
PNi
PNi
Kernel Reset
4058
Ni_HPMS
Node i High Priority
Message Status
00294H+i
*400H
PNi
nBE
Kernel Reset
4059
Ni_NDAT1
Node i New Data 1
00298H+i
*400H
PNi
PNi
Kernel Reset
4060
Ni_NDAT2
Node i New Data 2
0029CH+
i*400H
PNi
PNi
Kernel Reset
4060
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3983
v1.1
2025-06-26


Table 994
(continued) Register overview - CAN domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_RXF0C
Node i Rx FIFO 0
Configuration
002A0H+
i*400H
PNi
PNi
Kernel Reset
4061
Ni_RXF0S
Node i Rx FIFO 0 Status
002A4H+
i*400H
PNi
nBE
Kernel Reset
4062
Ni_RXF0A
Node i Rx FIFO 0
Acknowledge
002A8H+
i*400H
PNi
PNi
Kernel Reset
4063
Ni_RXBC
Node i Rx Buffer
Configuration
002ACH+
i*400H
PNi
PNi
See 4063
4063
Ni_RXF1C
Node i Rx FIFO 1
Configuration
002B0H+
i*400H
PNi
PNi
Kernel Reset
4064
Ni_RXF1S
Node i Rx FIFO 1 Status
002B4H+
i*400H
PNi
nBE
Kernel Reset
4065
Ni_RXF1A
Node i Rx FIFO 1
Acknowledge
002B8H+
i*400H
PNi
PNi
Kernel Reset
4066
Ni_RXESC
Node i Rx Buffer/FIFO
Element Size Configuration
002BCH+
i*400H
PNi
PNi
Kernel Reset
4067
Ni_TXBC
Node i Tx Buffer
Configuration
002C0H+
i*400H
PNi
PNi
See 4068
4068
Ni_TXFQS
Node i Tx FIFO/Queue
Status
002C4H+
i*400H
PNi
nBE
Kernel Reset
4069
Ni_TXESC
Node i Tx Buffer Element
Size Configuration
002C8H+
i*400H
PNi
PNi
See 4070
4070
Ni_TXBRP
Node i Tx Buffer Request
Pending
002CCH+
i*400H
PNi
PNi
Kernel Reset
4072
Ni_TXBAR
Node i Tx Buffer Add
Request
002D0H+
i*400H
PNi
PNi
Kernel Reset
4073
Ni_TXBCR
Node i Tx Buffer
Cancellation Request
002D4H+
i*400H
PNi
PNi
Kernel Reset
4073
Ni_TXBTO
Node i Tx Buffer
Transmission Occurred
002D8H+
i*400H
PNi
nBE
Kernel Reset
4074
Ni_TXBCF
Node i Tx Buffer
Cancellation Finished
002DCH+
i*400H
PNi
nBE
Kernel Reset
4074
Ni_TXBTIE
Node i Tx Buffer
Transmission Interrupt
Enable
002E0H+i
*400H
PNi
PNi
Kernel Reset
4075
Ni_TXBCIE
Node i Tx Buffer
Cancellation Finished
Interrupt Enable
002E4H+i
*400H
PNi
PNi
Kernel Reset
4075
Ni_TXEFC
Node i Tx Event FIFO
Configuration
002F0H+i
*400H
PNi
PNi
Kernel Reset
4076
Ni_TXEFS
Node i Tx Event FIFO Status
002F4H+i
*400H
PNi
nBE
Kernel Reset
4077
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3984
v1.1
2025-06-26


Table 994
(continued) Register overview - CAN domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
Ni_TXEFA
Node i Tx Event FIFO
Acknowledge
002F8H+i
*400H
PNi
PNi
Kernel Reset
4077
Ni_TSU_CREL
Node i TSU Core Release
Register
00360H+i
*400H
PNi
nBE
Kernel Reset
4078
Ni_TSU_TSCFG
Node i Timestamp
Configuration
00364H+i
*400H
PNi
PNi
Kernel Reset
4078
Ni_TSU_TSS1
Node i Timestamp Status 1
00368H+i
*400H
PNi
nBE
Kernel Reset
4080
Ni_TSU_TSS2
Node i Timestamp Status 2
0036CH+
i*400H
PNi
nBE
Kernel Reset
4081
Ni_TSU_TSm
Node i Timestamp m
00370H+i
*400H+m
*4
PNi
nBE
Kernel Reset
4082
Ni_TSU_ATB
Node i Actual Timebase
003B0H+
i*400H
PNi
U
Kernel Reset
4082
21.7.3
Register overview - CAN CRE Receive Host Buffers (ascending offset
address)
Table 995
Register overview - CAN CRE Receive Host Buffers (ascending offset address)
Short name
Long name
Offset
address
See
RHBUFk_UCRH
Uni-cast Routing Header k
00020H+k*60H 4101
RHBUFk_MCRH
Multi-cast Routing Header k
00020H+k*60H 4102
RHBUFk_THEAD_INT
RD
Timing Header k Intrusion Detection Information
00024H+k*60H 4103
RHBUFk_THEAD_RXT
S
Timing Header k Rx Timestamp
00028H+k*60H 4104
RHBUFk_CRC
CRE computed CRC
0002CH+k*60H 4104
RHBUFk_R0
RHBUF k Register 0
00030H+k*60H 4105
RHBUFk_LPDUH1
Long PDU header 1
00030H+k*60H 4105
RHBUFk_R1
RHBUF k Register 1
00034H+k*60H 4106
RHBUFk_LPDUH0
Long PDU header 0
00034H+k*60H 4107
RHBUFk_SPDUH
Short PDU header
00034H+k*60H 4108
RHBUFk_RHBUF_DB
m
RHBUF k Data Byte m
00038H+k*60H
+m
4109
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3985
v1.1
2025-06-26


21.7.4
Register overview - CAN CRE Standard Frame Rate Table (ascending
offset address)
Table 996
Register overview - CAN CRE Standard Frame Rate Table (ascending offset address)
Short name
Long name
Offset
address
See
SFRk_FR
Standard ID Frame Rate Measure
00468H+k*4
4119
21.7.5
Register overview - CAN CRE Standard Routing Table (ascending
offset address)
Table 997
Register overview - CAN CRE Standard Routing Table (ascending offset address)
Short name
Long name
Offset
address
See
SRTk_UCR
Standard routing table Uni-cast Rule
00168H+k*4
4113
SRTk_MCR
Standard routing table Multi-cast Rule
00168H+k*4
4114
SRTk_PR
Standard routing table PDU Routing Rule
00168H+k*4
4115
21.7.6
Register overview - CAN CRE Standard Timestamp Database
(ascending offset address)
Table 998
Register overview - CAN CRE Standard Timestamp Database (ascending offset address)
Short name
Long name
Offset
address
See
STSDk_RTS
Standard ID Reference Timestamp
005E8H+k*4
4120
21.7.7
Register overview - CAN CRE configuration table (ascending offset
address)
Table 999
Register overview - CAN CRE configuration table (ascending offset address)
Short name
Long name
Offset
address
See
CRE_STD_RT_PARAM STD ID Routing table parameters
00000H
4097
CRE_XTD_RT_PARAM XTD ID Routing table parameters
00004H
4098
CRE_STD_FRT_PARA
M
STD ID Frame rate measure table parameters
00008H
4098
CRE_XTD_FRT_PARA
M
XTD ID Frame rate measure table parameters
0000CH
4099
CRE_STD_TSD_PARA
M
STD ID Timestamp database parameters
00010H
4099
CRE_XTD_TSD_PARA
M
XTD ID Timestamp database parameters
00014H
4100
CRE_ABORT_SEQ
CRE abort sequence register
00018H
4100
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3986
v1.1
2025-06-26


21.7.8
Register overview - CAN CRE Transmit Host Buffers (ascending
offset address)
Table 1000
Register overview - CAN CRE Transmit Host Buffers (ascending offset address)
Short name
Long name
Offset
address
See
THBUFk_CRC
Tx Host Buffer CRC
000E0H+k*50H 4109
THBUFk_T0
Transmit Host Buffer Word 0
000E4H+k*50H 4110
THBUFk_T1
Transmit Host Buffer Word 1
000E8H+k*50H 4111
THBUFk_DBm
Transmit Host Buffer Data Byte m
000ECH+k*50H
+m
4113
21.7.9
Register overview - CAN CRE Extended Frame Rate Table (ascending
offset address)
Table 1001
Register overview - CAN CRE Extended Frame Rate Table (ascending offset address)
Short name
Long name
Offset
address
See
XFRk_FR
Extended ID Frame Rate Measure
00568H+k*4
4120
21.7.10
Register overview - CAN CRE Extended Routing Table (ascending
offset address)
Table 1002
Register overview - CAN CRE Extended Routing Table (ascending offset address)
Short name
Long name
Offset
address
See
XRTk_UCR
Extended routing table Uni-cast Rule
00368H+k*4
4116
XRTk_MCR
Extended routing table Multi-cast Rule
00368H+k*4
4117
XRTk_PR
Extended ID routing table PDU Routing Rule
00368H+k*4
4118
21.7.11
Register overview - CAN CRE Extended Timestamp Database
(ascending offset address)
Table 1003
Register overview - CAN CRE Extended Timestamp Database (ascending offset
address)
Short name
Long name
Offset
address
See
XTSDk_RTS
Extended ID Reference Timestamp
007E8H+k*4
4121
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3987
v1.1
2025-06-26


21.7.12
Register overview - CAN Rx Buffer and FIFO Element (ascending
offset address)
Table 1004
Register overview - CAN Rx Buffer and FIFO Element (ascending offset address)
Short name
Long name
Offset
address
See
RXMSGk_R0
Register 0
00000H+k*48H 4087
RXMSGk_R1A
Register 1 A
00004H+k*48H 4088
RXMSGk_R1B
Register 1 B
00004H+k*48H 4089
RXMSGk_DBm
Data Byte m
00008H+k*48H
+m
4090
21.7.13
Register overview - CAN Standard Message ID Filter Element
(ascending offset address)
Table 1005
Register overview - CAN Standard Message ID Filter Element (ascending offset
address)
Short name
Long name
Offset
address
See
STDMSGk_S0
Standard Message 0
00000H+k*4
4082
21.7.14
Register overview - CAN Tx Buffer Element (ascending offset
address)
Table 1006
Register overview - CAN Tx Buffer Element (ascending offset address)
Short name
Long name
Offset
address
See
TXMSGk_T0
Transmit Buffer 0
00000H+k*48H 4094
TXMSGk_T1
Transmit Buffer 1
00004H+k*48H 4095
TXMSGk_DBm
Data Byte m
00008H+k*48H
+m
4097
21.7.15
Register overview - CAN Tx Event FIFO Element (ascending offset
address)
Table 1007
Register overview - CAN Tx Event FIFO Element (ascending offset address)
Short name
Long name
Offset
address
See
TXEVENTk_E0
Event 0
00000H+k*8
4091
TXEVENTk_E1A
Event 1A
00004H+k*8
4091
TXEVENTk_E1B
Event 1B
00004H+k*8
4093
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3988
v1.1
2025-06-26


21.7.16
Register overview - CAN Extended Message ID Filter Element
(ascending offset address)
Table 1008
Register overview - CAN Extended Message ID Filter Element (ascending offset
address)
Short name
Long name
Offset
address
See
EXTMSGk_F0
Filter Element 0
00000H+k*8
4084
EXTMSGk_F1
Filter Element 1
00004H+k*8
4085
21.7.17
Clock Control Register
The Clock Control Register CLC allows the programmer to adapt the functionality and power consumption of
the module to the requirements of the application.
Register CLC controls the module clock signal and the reactivity to the sleep signal.
CLC
Offset address:
00000H
Clock Control Register
Reset values see:
Table 1009
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
Used for enable/disable control of the module. The synchronous and
asynchronous clock is switched on/off. Note that no register access is
possible to any register while module is disabled. A disable request is
granted, if the M_CAN clock is disabled, or all M_CAN nodes
acknowledge the disable request.
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
Sleep Mode Enable Control
Used to control the module’s reaction to sleep mode.
0B Sleep mode request is enabled and functional
1B Module disregards the sleep mode control signal
0
2,
31:4
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3989
v1.1
2025-06-26


Table 1009
Reset values of CLC
Reset type
Reset value
Note
Application Reset
0000 0003H
 
After Boot-FW
Value
0000 0000H
After CAN BSL execution
21.7.18
OCDS Control and Status Register
The OCDS Control and Status register OCS controls the debug and trace behavior by selecting suspend modes
and OTGB trigger sets. When OCDS is disabled the suspend control is ineffective.
OCS
Offset address:
00004H
OCDS Control and Status Register
Debug Reset value:
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
01B TS16_CAN
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
Clock is off immediately. Do not use this mode in normal CAN
applications, this mode is meant for debugging the peripheral IP.
2H Soft suspend mode
Soft suspend of CAN nodes.
others, Reserved, do not use
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3990
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
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
Read as 0; should be written with 0.
Table 1010
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
(default)
r
SUS, TGB, TGS
 
21.7.19
Module Identification Register
ID
Offset address:
00008H
Module Identification Register
PowerOn Reset value:
00B8 C004H
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
This internal marker is fixed to C0.
MOD_NUM
31:16
r
Module Number
Indicates the module identification number (00B8 = CAN).
21.7.20
Reset Control Register A
RST_CTRLA
Offset address:
0000CH
Reset Control Register A
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3991
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
rwh
Field
Bits
Type
Description
KRST
0
rwh
Kernel Reset
Request a kernel reset. The reset is executed if the reset bits of both
kernel reset registers are set.
KRST is cleared after the kernel reset was executed.
0B No action
1B A kernel reset was requested
GRSTENx
(x=0-3)
x+8
rw
Enable for Global Module Reset Group x
0B global module reset group x does not have any effect
1B global module reset group x results in a kernel reset
0
7:1,
31:12
r
Reserved
Read as 0; should be written with 0.
21.7.21
Reset Control Register B
RST_CTRLB
Offset address:
00010H
Reset Control Register B
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
rwh
Field
Bits
Type
Description
KRST
0
rwh
Kernel Reset
Request a kernel reset. The reset is executed if the reset bits of both
kernel reset registers are set.
KRST is cleared after the kernel reset was executed.
0B No action
1B A kernel reset was requested
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3992
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
Kernel Reset Status Clear
Clears all status bits in RST_STAT when 1 is written. Read will return 0.
0B No action
1B Write with ´1´ clears bits STAT.GRSTx and bit STAT.KRST .
0
30:1
r
Reserved
Read as 0; should be written with 0.
21.7.22
Reset Status Register
The reset status register contains the status bits for kernel reset (KRST) and the global module reset groups
(GRSTx).
RST_STAT
Offset address:
00014H
Reset Status Register
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
Kernel Reset Status
Indicates an executed kernel reset. RST_STAT.KRST is set after the
execution of a kernel reset in the same clock cycle in which the reset
bits are cleared.
Clear KRST by setting bit STATCLR in register RST_CTRLB.
GRSTx (x=0-3)
x+8
rh
Status for Global Module Reset Group x
0B Reset was not triggered by global reset group x
1B Reset was triggered by global reset group x
0
7:1,
31:12
r
Reserved
Read as 0; should be written with 0.
21.7.23
PROT Register Endinit
The resource protection register allows the definition of a specific PROT owner, and allows the PROT owner and
in some PROT states, the secure master to update the PROT state as described in the PROT mechanism.
The PROTE register controls lock / unlock of the local Endinit (E) protected control registers.
PROTE
Offset address:
00018H
PROT Register Endinit
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3993
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
21  Controller Area Network interface (CAN)
Reference manual
3994
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
Table 1011
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
 
(default)
r
ODEF, PRS, PRSEN, TAGID, VM,
VMEN
 
rh
STATE
21.7.24
PROT Register Safe Endinit
The resource protection register allows the definition of a specific PROT owner, and allows the PROT owner and
in some PROT states, the secure master to update the PROT state as described in the PROT mechanism.
The PROTSE register controls lock / unlock of the local Safe Endinit (SE) protected control registers.
PROTSE
Offset address:
0001CH
PROT Register Safe Endinit
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3995
v1.1
2025-06-26


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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3996
v1.1
2025-06-26


Table 1012
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
 
(default)
r
ODEF, PRS, PRSEN, TAGID, VM,
VMEN
 
rh
STATE
21.7.25
Write access enable register A
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
ACCEN_WRA
Offset address:
00030H
Write access enable register A
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
21.7.26
Write access enable register B
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
ACCEN_WRB
Offset address:
00034H
Write access enable register B
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3997
v1.1
2025-06-26


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
21.7.27
Read access enable register A
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
ACCEN_RDA
Offset address:
00038H
Read access enable register A
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
21.7.28
Read access enable register B
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
ACCEN_RDB
Offset address:
0003CH
Read access enable register B
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3998
v1.1
2025-06-26


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
21.7.29
VM access enable register
This register defines which virtual machine encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each VMx.
ACCEN_VM
Offset address:
00040H
VM access enable register
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
21.7.30
PRS access enable register
This register defines which protection register set encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each PRSx.
ACCEN_PRS
Offset address:
00044H
PRS access enable register
Application Reset value:
00FF 00FFH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
3999
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
21  Controller Area Network interface (CAN)
Reference manual
4000
v1.1
2025-06-26


21.7.31
Module Control Register
The Module Control Register MCR contains basic settings that determine the operation of the MCMCAN module.
The write access to the lowest byte of the MCR register becomes only valid, if and only if, MCR.CCCE and MCR.CI
are already set during write access. To switch the clocks on or off, the bits of MCR.CCCE and MCR.CI have to be
reset afterwards. Before this sequence hasn’t taken place, no write access to the corresponding nodes, can be
done.
Note:
If the baud rate logic is supplied from an unstable clock source, or no clock at all, the CAN
functionality is not guaranteed.
To be able to change the clock settings the following programming sequence needs to be met:
uwTemp = CANn_MCR.U;
uwTemp |= (0xC0000000 | CLKSELx);
CANn_MCR.U = uwTemp;
uwTemp &= ~0xC0000000;
CANn_MCR.U = uwTemp;
The clock settings for CAN nodes becomes active.
To be able to start the RAM initialization, the following programming sequence need to be met:
CANn_MCR |= 0xC0000000;
Wait until CANn_MCR.RBUSY is 0b
Set CANn_MCR.RINIT to 0b
Set CANn_MCR.RINIT to 1b
Dummy read CANn_MCR
Wait until CANn_MCR.RBUSY is 0b
Set CANn_MCR.RINIT to 0b
CANn_MCR &= ~0xC0000000;
RAM initialization is finished
MCR
Offset address:
00070H
Module Control Register
Reset values see:
Table 1013
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
CCCE
CI
RINI
T
RBU
SY
DXC
M
NODE
0
rw
rw
rw
rh
rw
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
CLKSEL3
CLKSEL2
CLKSEL1
CLKSEL0
r
rw
rw
rw
rw
Field
Bits
Type
Description
CLKSEL0
1:0
rw
Clock Select 0
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4001
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
CLKSEL1
3:2
rw
Clock Select 1
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
CLKSEL2
5:4
rw
Clock Select 2
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
CLKSEL3
7:6
rw
Clock Select 3
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
NODE
26:24
rw
Node
This bit-field determines the M_CAN node i which is used for debug over
M_CAN. This bit-field only exists on CAN module 0.
000B M_CAN0
…
011B M_CAN3
DXCM
27
rw
Debug Over CAN Messages Enable
This bit enables the debug over serial connections between DAP and
CAN module 0.
If enabled the lowest receive/transmit message buffer is reserved for
debugger communication. DXCM is described in detail in the OCDS
chapter. This bit only exists on CAN module 0.
0B DXCM disabled
1B DXCM enabled
RBUSY
28
rh
RAM BUSY
This bit shows that the RAM Initialization is running. This bit is set back
to 0b by hardware when the RAM intialization is completed.
RINIT
29
rw
RAM Init
This bit is MCR.CI and MCR.CCCE protected.
This bit starts the initialization of the RAM block to all 0x0.
The RAM initialization is started only when this bit is changed from 0b
to 1b and also RBUSY is 0b.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4002
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
CI
30
rw
Change Init
Needs to be set to enable and disable clocks.
0B Change Init disabled
1B Change Init enabled (takes effect with CCCE:=1)
CCCE
31
rw
Clock and RAM Change Enable
Needs to be set to enable and disable the clocks.
0B Clock and RAM Change disabled
1B Clock and RAM Change enabled (takes effect with CI:=1)
0
23:8
r
Reserved
Shall read 0; shall be written with 0.
Table 1013
Reset values of MCR
Reset type
Reset value
Note
Kernel Reset
0000 0000H
 
After Boot-FW
Value
0000 000CH
After CAN BSL execution
21.7.32
Buffer receive address and transmit address
This register is used only when Debug over CAN Messages feature is used. This register assigns the start address
to all features needing the message buffers inside the corresponding M_CAN, which are for receive and transmit
BUFADR
Offset address:
00074H
Buffer receive address and transmit address
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
RXBUF
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
TXBUF
r
rw
Field
Bits
Type
Description
TXBUF
13:0
rw
Transmit Buffer start address
This is the start address of the first dedicated transmit buffer.
RXBUF
29:16
rw
Receive Buffer start address
This is the start address of the first dedicated receive buffer.
0
15:14,
31:30
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4003
v1.1
2025-06-26


21.7.33
Measure Control Register
The Measure Control Register MECR controls the CAN edge timing measurement function for calibration
purposes. This feature only exists on CAN module 0.
Oscillator calibration
This register supports the oscillator calibration on which the decision is taken to increase or decrease the
frequency.
MECR
Offset address:
00080H
Measure Control Register
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
SOF
DEPTH
0
CAPE
IE
ANYE
D
0
NODE
INP
r
rw
rw
r
rw
rw
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
TH
rw
Field
Bits
Type
Description
TH
15:0
rw
Threshold
This bit-field contains the threshold value for the measurement timer. If
TH = 0000, the timer is stopped and the capture function is disabled.
INP
19:16
rw
Interrupt Node Pointer
INP selects the interrupt output line SRC_CANINTx (x = 0-15) for a
capture event interrupt.
0H Interrupt output line SRC_CANINT0 is selected
…
FH Interrupt output line SRC_CANINT15 is selected
NODE
22:20
rw
Node
This bit-field determines the CAN node i whose input line RXDCANi is
used for start and capture of the measurement timer.
000B Node 0
…
011B Node 3
ANYED
24
rw
Any Edge
This bit enables capture on any edge of CAN input line specified by
NODE.
0B Capture on falling (dominant) edge only
1B Capture on rising (recessive) or falling (dominant) edge
CAPEIE
25
rw
Capture Event Interrupt Enable
This bit enables the capture event interrupt.
Bit-field INP selects the interrupt output line which becomes activated
at this type of interrupt.
0B Capture event interrupt is disabled
1B Capture event interrupt is enabled
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4004
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DEPTH
29:27
rw
Digital Glitch Filter Depth
DEPTH determines the number of input samples clocked with fSYNi that
are taken into account for the calculation of the floating average. The
higher DEPTH is chosen to be, the longer the glitches that are
suppressed and the longer the delay of the input signal introduced by
this filter.
000B off, default
001B Filter depth of 8 cycles
010B Filter depth of 16 cycles
011B Filter depth of 32 cycles
100B Filter depth of 64 cycles
101B Filter depth of 128 cycles
110B Filter depth of 255 cycles
111B not allowed, reserved
SOF
30
rw
Start Of Frame
This bit selects falling edge or any edge as measurement for start of
frame detection.
0B Measurement starts with any falling edge
1B Measurement starts with falling Start of Frame edge. i.e any falling
edge that occurs while the CAN node is in idle state
0
23,
26,
31
r
Reserved
Read as 0; should be written with 0.
21.7.34
Measure Status Register
The Measure Status Register MESTAT contains the status information of the CAN edge timing measurement.
This feature only exists on CAN module 0.
MESTAT
Offset address:
00084H
Measure Status Register
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
CAPE
CAP
RED
r
rwh
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
CAPT
rh
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4005
v1.1
2025-06-26


Field
Bits
Type
Description
CAPT
15:0
rh
Captured Timer
This bit-field contains the captured measurement timer content.
The timer itself is cleared and started by the first falling (dominant)
edge of a CAN frame on the input line of the CAN node specified by
MECR.NODE. The timer is incremented by the module control clock fSYNi
and will be stopped when FFFFH is reached. If MECR.TH = 0000, the
timer is always stopped.
A capture will take place if all the following conditions are met:
1.
MECR.TH > 0000
2.
Timer is cleared and started by new frame
3.
Timer reaches MECR.TH
4.
This node is not sending and first edge (as specified by
MECR.ANYED) after 3. occurs on input line
Capture will be repeated for the following CAN frames until MECR.TH is
cleared.
CAPRED
16
rh
Captured Rising Edge
This bit indicates the type of edge that caused the last capture event.
0B Capture occurred on falling (dominant) edge
1B Capture occurred on rising (recessive) edge
CAPE
17
rwh
Capture Event
This flag is set on a capture event. It must be reset by software.
An interrupt request is generated if MECR.CAPEIE = 1. If CAPE=1, then
no further measurement results are posted to MESTAT.CAPT and
MESTAT.CAPRED. CAPE bit has to be cleared to re-enable update of
MESTAT.CAPT and MESTAT.CAPRED.
0B No capture event has occurred since last flag reset
1B Capture event has occurred since last flag reset
0
31:18
r
Reserved
Read as 0; should be written with 0.
21.7.35
CRE Watchdog timer register
The CRE Watchdog timer register to monitor timeout.
WDT
Offset address:
00088H
CRE Watchdog timer register
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
SWDP
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
FWDP
EN
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4006
v1.1
2025-06-26


Field
Bits
Type
Description
EN
0
rw
Enable watchdog
This bit enables/disables the watchdog timer
FWDP
15:1
rw
Fast Watchdog prescaler
This bit-field is a configurable pre-scalar. This pre-scaler is configured
by user for monitoring fast events that are part of WDG1 and WDG2. By
default the pre-scaler is fixed to 16 when this bit-field is not set
1.
•
Start condition : RxFIFO not empty
•
End condition : RxFIFO processing done
2.
•
Start condition : THBUF full
•
End condition : THBUF empty
SWDP
31:16
rwh
Slow Watchdog prescaler
This bit-field is a configurable pre-scalar. This pre-scaler is configured
by user for monitoring slow events that are part of WDG2 and WDG3. By
default the pre-scaler is fixed to 16 when this bit-field is not set
1.
•
Start condition : THBUF empty
•
End condition : THBUF full
2.
•
Start condition : RHBUF full
•
End condition : RHBUF empty
3.
•
Start condition : RHBUF empty
•
End condition : RHBUF full
21.7.36
Node i Write access enable register A
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
Ni_ACCEN_WRA (i=0-3)
Offset address:
00100H+i*400H
Node i Write access enable register A
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4007
v1.1
2025-06-26


21.7.37
Node i Write access enable register B
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
Ni_ACCEN_WRB (i=0-3)
Offset address:
00104H+i*400H
Node i Write access enable register B
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
21.7.38
Node i Read access enable register A
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
Ni_ACCEN_RDA (i=0-3)
Offset address:
00108H+i*400H
Node i Read access enable register A
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
21  Controller Area Network interface (CAN)
Reference manual
4008
v1.1
2025-06-26


21.7.39
Node i Read access enable register B
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
Ni_ACCEN_RDB (i=0-3)
Offset address:
0010CH+i*400H
Node i Read access enable register B
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
21.7.40
Node i VM access enable register
This register defines which virtual machine encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each VMx.
Ni_ACCEN_VM (i=0-3)
Offset address:
00110H+i*400H
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
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4009
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
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
21.7.41
Node i PRS access enable register
This register defines which protection register set encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each PRSx.
Ni_ACCEN_PRS (i=0-3)
Offset address:
00114H+i*400H
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
21.7.42
Node i Start Address
In case the RAM shall not be protected, the STARTADR has to be higher than the corresponding ENDADR of the
node.
Ni_STARTADR (i=0-3)
Offset address:
00120H+i*400H
Node i Start Address
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4010
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
PROT_RANGE_START
0
rw
r
Field
Bits
Type
Description
PROT_RANGE_
START
15:2
rw
Message RAM start - START
The address within the RAM area of the MCMCAN, of node i, where the
message RAM to be protected starts
0
1:0,
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.43
Node i End Address
Ni_ENDADR (i=0-3)
Offset address:
00124H+i*400H
Node i End Address
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
PROT_RANGE_END
0
rw
r
Field
Bits
Type
Description
PROT_RANGE_
END
15:2
rw
Message RAM end - END
The address within the RAM area of the MCMCAN, of node i, where the
message RAM to be protected ends
0
1:0,
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.44
Node i Interrupt Signalling Register
The groups by the Ni_G0INTR, Ni_G1INTR and G2INTR registers are also shown inside the INTRSIG (interrupt
signalling register) register. Inside the interrupt signalling register a 1 means, that one of the corresponding bits
inside the interrupt (status) register of the corresponding M_CAN node, at least one group member is showing
an interrupt. Ni_INTRSIG is purely OR-ing the interrupt status bits of the group to enable SW to have proper
handling of the bits. Writing to Ni_INTRSIG has no effect.
If Ni_INTRSIG is written, this shall have no effect on the interrupt status inside the M_CAN nodes. The bits have
to be reset inside the corresponding M_CAN nodes, see register Ni_IR.
Ni_INTRSIG (i=0-3)
Offset address:
00128H+i*400H
Node i Interrupt Signalling Register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4011
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
CEI
IDM
U
TXH
BUF1
TXH
BUF0
RXH
BUF1
RXH
BUF0
r
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
LOI
BOF
F
SAFE
MOE
R
ALRT WATI
HPE
TEFI
FO
TRAC
O
TRA
Q
RETI
RxF0
N
RxF1
N
RxF0
F
RxF1
F
REIN
T
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
REINT
0
rh
A message stored in a receive buffer interrupt
RxF1F
1
rh
Receive FIFO1 is full interrupt
RxF0F
2
rh
Receive FIFO0 is full interrupt
RxF1N
3
rh
Receive FIFO1 got a new message interrupt
RxF0N
4
rh
Receive FIFO0 got a new message interrupt
RETI
5
rh
A receive timeout event interrupt
TRAQ
6
rh
A transmission queue event interrupt
TRACO
7
rh
A transmission control event interrupt
TEFIFO
8
rh
A Transmit Event FIFO Incident interrupt
HPE
9
rh
A high priority event interrupt
WATI
10
rh
A watermark interrupt has been reached
ALRT
11
rh
An alert interrupt
MOER
12
rh
Module error interrupt
SAFE
13
rh
The safety counter interrupt ELO
BOFF
14
rh
Bus Off Interrupt
LOI
15
rh
Last Error Interrupt
RXHBUF0
16
rh
CRE Rx Host Buffer 0 interrupt
RXHBUF1
17
rh
CRE Rx Host Buffer 1 interrupt
TXHBUF0
18
rh
CRE Tx Host Buffer 0 interrupt
TXHBUF1
19
rh
CRE Tx Host Buffer 1 interrupt
IDMU
20
rh
IDMU interrupts
Ni_CRE_IR.SFRMLI and XFRMLI events are mapped here.
CEI
21
rh
CRE error interrupts
Ni_CRE_IR.IRSI, IWSI, CRCI, RWDTI and TWDTI events are mapped here
0
31:22
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4012
v1.1
2025-06-26


21.7.45
Node i Interrupt routing for Group 0
Ni_G0INTR is the first of three grouping registers. In this register, the interrupt line within the module is fixed.
Please be reminded, that the interrupt sources need to be enabled to be mapped. The total module has 16
interrupts and the interrupt node can be chosen within Ni_G0INTR, Ni_G1INTR and Ni_G2INTR.
Meaning:
0000B Interrupt output line SRC_CANINT0 is selected.
0001B Interrupt output line SRC_CANINT1 is selected.
…B…
1110B Interrupt output line SRC_CANINT14 is selected.
1111B Interrupt output line SRC_CANINT15 is selected.
Note: MCMCAN has 22 interrupt groups and 16 interrupt lines, and the user can decide how the interrupt lines
are shared within the groups.
Ni_G0INTR (i=0-3)
Offset address:
0012CH+i*400H
Node i Interrupt routing for Group 0
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
LOI
BOFF
SAFE
MOER
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
ALRT
WATI
HPE
TEFIFO
rw
rw
rw
rw
Field
Bits
Type
Description
TEFIFO
3:0
rw
Transmit Event FIFO Incidents
are mapped here. Ni_IR.TEFF (Transmit Event FIFO Full) and Ni_IR.TEFN
(Transmit Event FIFO New Entry)
HPE
7:4
rw
High Priority Events
are mapped here, giving Ni_IR.HPM an interrupt level
WATI
11:8
rw
Watermark interrupts
are mapped here: Ni_IR.TEFW (Transmit FIFO warning interrupt
reached), Ni_IR.RF1W (Receive FIFO 1 warning interrupt reached).
Ni_IR.RF0W (Receive FIFO 0 warning interrupt reached)
ALRT
15:12
rw
ALERTS
All kind of alerts are mapped here. Ni_IR.EW (warning status), Ni_IR.EP
(error passive), Ni_IR.TSW (timestamp wrap around), Ni_IR.TEFL
(Transmit Event FIFO Element Lost), Ni_IR.RF0L (Receive FIFO 0
Message Lost), Ni_IR.RF1L (Receive FIFO 1 Message Lost).
MOER
19:16
rw
Module errors
Ni_IR.WDI (watchdog interrupt) and Ni_IR.MRAF (message RAM access
failure) are mapped here.
SAFE
23:20
rw
Safety counter overflow
The interrupt node for Ni_IR.ELO showing a safety counter overflow
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4013
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
BOFF
27:24
rw
Bus Off has been reached
Mapped to Ni_IR.BO flag indication the change in Bus_Off status. To get
out of bus off, the Ni_CCCR.INIT bit has to be reset.
LOI
31:28
rw
Last Error Interrupts
The interrupt sources Ni_IR.PED (Protocol Error in Data Phase) and
Ni_IR.PEA (Protocol Error in Arbitration Phase) are signalled here.
21.7.46
Node i Interrupt routing for Group 1
Ni_ G1INTR has the same functionality as Ni_ G0INTR, but for other interrupt sources. The interrupt sources
need to be enabled to be mapped.
Ni_G1INTR (i=0-3)
Offset address:
00130H+i*400H
Node i Interrupt routing for Group 1
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
TRACO
TRAQ
RETI
RxF0N
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
RxF1N
RxF0F
RxF1F
REINT
rw
rw
rw
rw
Field
Bits
Type
Description
REINT
3:0
rw
Message stored in dedicated receive buffer interrupt (Ni_IR.DRX)
is assigned to interrupt node.
RxF1F
7:4
rw
IR.RF1F
Receive FIFO1 full interrupt assigned to an interrupt node
RxF0F
11:8
rw
IR.RF0F
Receive FIFO0 full interrupt assigned to an interrupt node
RxF1N
15:12
rw
IR.RF1N
Receive FIFO1 new message assigned to an interrupt node
RxF0N
19:16
rw
IR.RF0N
Receive FIFO0 new message assigned to an interrupt node
RETI
23:20
rw
Receive Timeouts
can be assigned here. Ni_IR.TOO (time-out event) and TE (Timer Event)
TRAQ
27:24
rw
Transmission Queue Events
can be assigned here. Ni_IR.TFE Transmission FIFO Empty
TRACO
31:28
rw
Interrupts of the transmission control
can be assigned here. Ni_IR.TCF (Transmission Cancellation Finished)
and Ni_IR.TF (Transmission Completed).
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4014
v1.1
2025-06-26


21.7.47
Node i Interrupt routing for Group 2
Ni_ G2INTR has the same functionality as Ni_ G0INTR, but for other interrupt sources. The interrupt sources
need to be enabled to be mapped.
Ni_G2INTR (i=0-3)
Offset address:
00134H+i*400H
Node i Interrupt routing for Group 2
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
CEI
IDMU
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
TXHBUF1
TXHBUF0
RXHBUF1
RXHBUF0
rw
rw
rw
rw
Field
Bits
Type
Description
RXHBUF0
3:0
rw
CRE Rx host buffer 0 interrupt
are mapped here: Ni_CRE_IR.RBUF0I (Receive Host Buffer 0 interrupt)
RXHBUF1
7:4
rw
CRE Rx host buffer 1 interrupt
are mapped here: Ni_CRE_IR.RBUF0I (Receive Host Buffer 1 interrupt)
TXHBUF0
11:8
rw
CRE Tx host buffer interrupt
are mapped here: Ni_CRE_IR.TBUFI 0 (Transmit Host Buffer 0 interrupt )
TXHBUF1
15:12
rw
CRE Tx host buffer interrupt
are mapped here: Ni_CRE_IR.TBUFI 1 (Transmit Host Buffer 1 interrupt)
IDMU
19:16
rw
IDMU relevant interrupts
are mapped here: Ni_CRE_IR.SFRMLI, Ni_CRE_IR.XFRMLI (Frame rate
measure lost interrupts)
CEI
23:20
rw
CRE error interrupts
are mapped here: Ni_CRE_IR.IRSI, Ni_CRE_IR.IWSI, Ni_CRE_IR.CRCI,
Ni_CRE_IR.RWDTI, Ni_CRE_IR.TWDTI (Error interrupts)
0
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.48
Node i Timer Clock Control Register
The Node i Timer Clock Control Register Ni_TIMER_CCR controls the functions of the node timer.
Ni_TIMER_CCR (i=0-3)
Offset address:
00138H+i*400H
Node i Timer Clock Control Register
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
TRIGSRC
0
r
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
STST
ART
STRE
SET
0
TPSC
0
rw
rw
r
rw
r
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4015
v1.1
2025-06-26


Field
Bits
Type
Description
TPSC
11:8
rw
Timer Prescaler
The duration of one timer clock is given by Ni_TIMER_CCR.TRIGSRC
frequency divided by (TPSC + 1).
STRESET
14
rw
Stamping Reset
This bit gives the possibility to reset the time stamp for CAN FD
messages.
STSTART
15
rw
Stamping Start
This bit starts the external timer used for CAN FD messages. The source
and the prescaler are identical to the Ni_TIMER_CCR(i=0-3).
TRIGSRC
20:18
rw
Trigger Source
This bit selects the trigger source for the different modes in the node
timer.
000B Node i Timer is decremented per fSYNi prescaled by (TPSC + 1)
timing to 0.
001B System Timer (STM) trigger event enabled
Node i Timer is decremented per STM trigger event prescaled by
(TPSC + 1).
010B General Timer (GTM) trigger event enabled
Node i Timer is decremented per GTM trigger event prescaled by
(TPSC + 1).
011B Enhanced General Timer (eGTM) trigger event enabled
Node i Timer is decremented per eGTM trigger event prescaled
by (TPSC + 1).
others, Reserved, do not use
0
7:0,
13:12,
17:16,
31:21
r
Reserved
Read as 0; should be written with 0.
21.7.49
Node i Timer Transmit Trigger 0 Register
The Node i Timer Transmit Trigger 0 Register Ni_TIMER_TXTRIG0 controls the node timing functions for
Transmit Trigger Mode.
Pretended Networking
The timer registers are intended to support Pretended Networking. As an application example, the SPB bus is
clocked at 40MHz. The asynchronous module part is clocked either with 40MHz as well or even more power
saving with direct drive from the oscillator. The cores are in idle mode. Messages can be received and a receive
interrupt can be generated. It is possible to trigger messages with or without changing the content by the
timers provided. For example the network management message and two related messages can be triggered
without any CPU interaction. As mostly the operating system is still running, messages can be changed without
any problem during the time, where the operating system is active.
Ni_TIMER_TXTRIG0 (i=0-3)
Offset address:
0013CH+i*400H
Node i Timer Transmit Trigger 0 Register
Kernel Reset value:
0001 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4016
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
STRT
TXMO
r
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
RELOAD
rw
Field
Bits
Type
Description
RELOAD
15:0
rw
Reload Value
This bit-field contains the reload value for the timer. The timer will
restart when RELOAD is written.
TXMO
23:16
r
Transmit Message Object
This transmit trigger is fixed to transmit buffer 1
STRT
24
rw
Timer Start
This bit-field controls the operation of the timer.
0B Timer is stopped.
1B Timer is started.
0
31:25
r
Reserved
Read as 0; should be written with 0.
21.7.50
Node i Timer Transmit Trigger 1 Register
The Node i Timer Transmit Trigger 1 Register Ni_TIMER_TXTRIG1 controls the node timing functions for
Transmit Trigger Mode.
Ni_TIMER_TXTRIG1 (i=0-3)
Offset address:
00140H+i*400H
Node i Timer Transmit Trigger 1 Register
Kernel Reset value:
0002 0000H
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
STRT
TXMO
r
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
RELOAD
rw
Field
Bits
Type
Description
RELOAD
15:0
rw
Reload Value
This bit-field contains the reload value for the timer. The timer will
restart when RELOAD is written.
TXMO
23:16
r
Transmit Message Object
This transmit object is fixed to transmit buffer 2
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4017
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
STRT
24
rw
Timer Start
This bit-field controls the operation of the timer.
0B Timer is stopped.
1B Timer is started.
0
31:25
r
Reserved
Read as 0; should be written with 0.
21.7.51
Node i Timer Transmit Trigger 2 Register
The Node i Timer Transmit Trigger 2 Register Ni_TIMER_TXTRIG2 controls the node timing functions for
Transmit Trigger Mode.
Ni_TIMER_TXTRIG2 (i=0-3)
Offset address:
00144H+i*400H
Node i Timer Transmit Trigger 2 Register
Kernel Reset value:
0003 0000H
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
STRT
TXMO
r
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
RELOAD
rw
Field
Bits
Type
Description
RELOAD
15:0
rw
Reload Value
This bit-field contains the reload value for the timer. The timer will
restart when RELOAD is written.
TXMO
23:16
r
Transmit Message Object
This transmit trigger is fixed to transmit buffer 3
STRT
24
rw
Timer Start
This bit-field controls the operation of the timer.
0B Timer is stopped.
1B Timer is started.
0
31:25
r
Reserved
Read as 0; should be written with 0.
21.7.52
Node i Timer Receive Timeout Register
The Node i Timer Receive Timeout Register Ni_TIMER_RXTOUT controls the node timing functions for Receive
Timeout Mode. This feature is independent of Classical CAN and CAN FD.
This mode exists, to have for example network management supervision.
Ni_TIMER_RXTOUT (i=0-3)
Offset address:
00148H+i*400H
Node i Timer Receive Timeout Register
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4018
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
TE
TEIE
0
r
rwh
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
RELOAD
rw
Field
Bits
Type
Description
RELOAD
15:0
rw
Reload Value
This bit-field contains the reload value for the timer. The timer will start
when RELOAD ≠ 0 is written. After half the time of the RELOAD value, the
interrupt flags of the receive buffers will be cleared automatically, to
ensure, that no message receive will be missed.
TEIE
22
rw
Timer Event Interrupt Enable
This bit enables the node timer event interrupt of CAN node i.
Bit-field Ni_G1INTR.RETI selects the interrupt output line which
becomes activated at this type of interrupt.
0B Timer event interrupt is disabled
1B Timer event interrupt is enabled
TE
23
rwh
Timer Event
This flag is set on a node timer transition from 1 to 0 in Receive Timeout
Mode. This bit must be reset (i.e Write to ‘0’) by software, writing a ‘1’
has no effect.
An interrupt request is generated if TEIE = 1.
0B No timer event has occurred since last flag reset
1B Timer event has occurred since last flag reset
0
21:16,
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.53
Node i Port Control Register
The Node Port Control Register Ni_PORTCTRL configures the CAN bus transmit/receive ports.
Ni_PORTCTRL (i=0-3)
Offset address:
0014CH+i*400H
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
DELE
LOU
T
LBM
0
RXSEL
r
rw
rw
rw
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4019
v1.1
2025-06-26


Field
Bits
Type
Description
RXSEL
2:0
rw
Receive Select
RXSEL selects one out of 8 possible receive inputs. The CAN receive
signal is performed by the selected input.
LBM
8
rw
Loop-Back Mode
0B Loop-Back Mode is disabled.
1B Loop-Back Mode is enabled. This node is connected to an internal
(virtual) loop-back CAN bus. All CAN nodes which are in Loop-Back
Mode are connected to this virtual CAN bus so that they can
communicate with each other internally. The external transmit line
is forced recessive in Loop-Back Mode.
LOUT
9
rw
Loop Back Mode Out
The loop back bus is switched to the external CAN bus of the node.
DELE
10
rw
Enable destructive read on Ni_ECR.CEL
If this bit is set, the destructive read on Ni_ECR.CEL and on the PSR
register takes place. Meaning, that with read access on Ni_ECR, the CEL
is reset. The same is true for the Ni_PSR register, for the bits PXE, RFDF,
RBRS, RESI, LEC and DLEC. When this bitfield is set, reading the
timestamp value from Ni_TSU_TSn register resets the related
Ni_TSU_TSS1 bits. After the destructive read it is advised to reset the bit
again.
0
7:3,
31:11
r
Reserved
Read as 0; should be written with 0.
21.7.54
Node i CRE Configuration Register
The Node i CRE Configuration Register Ni_CRE_CONFIG configures the Routing Engine functionality.
Ni_CRE_CONFIG (i=0)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0100H
Ni_CRE_CONFIG (i=1)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0200H
Ni_CRE_CONFIG (i=2)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0300H
Ni_CRE_CONFIG (i=3)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0400H
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
ID
0
DEN
IDM
UEN
REN
EN
r
r
r
rw
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4020
v1.1
2025-06-26


Field
Bits
Type
Description
EN
0
rw
Enable
Note: When the EN is set, the respective host buffers are enabled. The
RxFIFO0/1 and Tx FIFO/Queues shall not be used in this case. The
frames are read/written from/to CRE host buffers instead.
0B DIS: CRE function is disabled
1B EN: CRE function is enabled. When CRE is enabled, then RxFIFO0/1
and TxFIFO/Queue host interface handling is also enabled when
corresponding FIFO/Queue are enabled by CAN node
REN
1
rw
Routing Enable
This bit indicates that the Routing is enabled for the Source node. This
bit is checked only at the Source node. This bit-field can be written only
when Ni_CRE_CONFIG.EN = 1.
Note: This bit should be enabled at the source node for correct routing
0B DIS: Routing Disable
The Routing function of CRE is disabled. Note: If Ni_CRE_CFG.EN is
set, the corresponding host buffers are still enabled.
1B EN: Routing Enable
The Routing function of CRE is enabled for the Source CAN node
IDMUEN
2
rw
IDMU Enable
This bit-field can be written only when Ni_CRE_CFG.EN = 1
0B DIS: IDMU Disable
The Intrusion detection measurement unit (IDMU) of CRE is
disabled
1B EN: IDMU Enable
The Intrusion detection measurement unit (IDMU) of CRE is
enabled
DEN
3
rw
Destination Enable
This bit is checked only at the Destination node. This bit controls the
CRE write of the CAN frame to TxFIFO
Note: In case of external routing, the CAN frame remains in the Tx Host
Buffer and there will be no re-trigger to the DRE if DEN is set to 0 after
there has already been a trigger to the DRE. In case of internal routing,
the CAN frame would be discarded if DEN is set to 0
0B DIS: Destination Disable
The CAN frame is discarded
1B EN: Destination Enable
The CRE will write the CAN frame to the TxFIFO
ID
13:8
r
Unique ID
A Unique ID of the CAN Node i
1H till 4H - MCMCAN 0 CAN Node 0-Node 3 respectively
5H till 8H - MCMCAN 1 CAN Node 0-Node 3 respectively
9H till CH - MCMCAN 2 CAN Node 0-Node 3 respectively
DH till 10H - MCMCAN 3 CAN Node 0-Node 3 respectively
11H till 14H - MCMCAN 4 CAN Node 0-Node 3 respectively
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4021
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
7:4,
31:14
r
Reserved
Read as 0; shall be written with 0.
21.7.55
Node i CRE Configuration Start Address
This register defines the CRE RAM start address of CRE Configurations
Ni_CRE_CONFIGADR (i=0-3)
Offset address:
00154H+i*400H
Node i CRE Configuration Start Address
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
SA
0
rw
r
Field
Bits
Type
Description
SA
15:2
rw
Start Address
The start address from which the CRE Configuration section starts (32
bit word address and 16-byte aligned). The Routing Headers and Host
buffers are allocated from this address.
0
1:0,
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.56
Node i Receive Host Buffer z Configuration
This register configures the Host Buffer for RxFIFO
Ni_CRE_HBUF_RXz_CONFIG (i=0-3;z=0-1)
Offset address:
00158H+i*400H+z*8
Node i Receive Host Buffer z Configuration
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
CRC
EN
INTE
N
TRIG
EN
0
LEN
LRM
r
rw
rw
rw
r
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4022
v1.1
2025-06-26


Field
Bits
Type
Description
LRM
0
rw
Last Read Mode
This bit-field defines the last word of the CAN payload data expected to
be read by the host from Rx Host Buffer
0B Dynamic Data Length: The last word to be read by the host is
defined by the DLC of the received CAN frame
1B Fixed Data Length
The last word to be read by the host is defined by LEN bit-field of
this register
LEN
6:1
rw
Fixed Data Length
This bit-field contains the length of CAN Data field in words (4 bytes)
which is stored in the Receive Host Buffer. It defines the last word to be
read by the host when LRM=1. This bit-field is ignored when LRM=0.
0 - No payload data
1 - Data length of 4 bytes or 1 word
2 - Data length of 8 bytes or 2 words
.
.
16 - Data length of 64 bytes or 16 words
others - Incorrect (shall not be more than 16)
TRIGEN
8
rw
Enable Trigger
This bit-field enables / disables the generation of Trigger signal when a
new CAN frame is stored in Receive Host Buffer.
0B Disable
The Receive Host Buffer z trigger signal is disabled
1B Enabled
The Receive Host Buffer z trigger signal is enabled
INTEN
9
rw
Interrupt Enable
This bit-field enables / disables the generation of interrupt when a new
CAN frame is stored in Receive Host Buffer.
0B Disable
The Receive Host Buffer z interrupt is disabled
1B Enabled
The Receive Host Buffer z interrupt is enabled
CRCEN
10
rw
CRC calculation enable
This bit controls inclusion of CRC in the sequence check
0B CRC not included
1B CRC included
0
7,
31:11
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4023
v1.1
2025-06-26


21.7.57
Node i Receive Host Buffer z Status
This register provides the status information of the Receive Host buffer.
Ni_CRE_HBUF_RXz_STAT (i=0-3;z=0-1)
Offset address:
0015CH+i*400H+z*8
Node i Receive Host Buffer z Status
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
COUNT
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
WEG
INDEX
0
SWT
RIG
VTH
RHR
EQ
VRH
0
rwh
rh
r
rwh
rh
rwh
rh
r
Field
Bits
Type
Description
VRH
2
rh
Valid Routing Header
This bit-field indicates if there is a valid routing header stored in
Routing Header for the current CAN frame.
0 - No routing header (routing non-relevant)
1 - Valid routing header
RHREQ
3
rwh
New Receive Host Buffer z Transfer Request
This bit-field indicates a pending transfer request of Receive Host
buffer. It is set to 1 by hardware, when there is a new CAN frame stored
in the Receive Host Buffer. After successful read operation of the host
from the RX Host Buffer, this bit is reset to 0 by hardware. SW write to 1
also clears the bit. A SW write by 0 has no effect. A transition of 0 to 1
triggers RHBUF_INT when enabled in
Ni_CRE_HBUF_RXz_CONFIG.INTEN=1.
VTH
4
rh
Valid Timing Header
This bit-field indicates if there is a valid timing header stored in Timing
Header for the current CAN frame.
0 - No Timing header (Intrusion parameters not available)
1 - Valid Timing header
SWTRIG
5
rwh
Software DRE Tigger
SW trigger to the DRE. SW writes 1 to request trigger to DRE. HW clears
it after trigger to DRE. SW write with 0 has no effect
INDEX
13:8
rh
RxFIFOz Index
This bit-field indicates the Get Index of RxFIFOz, from which the current
CAN frame is fetched form.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4024
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
WEG
15:14
rwh
Watchdog Event Group
Set by hardware when there is a watchdog timeout error. This bit-field
indicates which event group has watchdog timeout error. Write
operation of any non-zero value resets the value to 0. Writing 0 does not
change the value of the bit-field
00B No Error
01B WDG1 Error
10B WDG2 Error
11B WDG3 Error
COUNT
23:16
rwh
Counter
The count field increments by 1 for every successful read of a CAN
frame by host from the Receive Host Buffer. The Counter wraps around
to 0 by hardware upon overflow. A write operation of any non zero
value resets the counters value to 0. Writing of 0 does not change the
value
0
1:0,
7:6,
31:24
r
Reserved
Reserved. Read as 0; should be written with 0
21.7.58
Node i Transmit Host Buffer z Configuration
This register configures the Host Buffer for TxFIFO / TxQueue
Ni_CRE_HBUF_TXz_CONFIG (i=0-3;z=0-1)
Offset address:
00168H+i*400H+z*8
Node i Transmit Host Buffer z Configuration
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
CRC
G
CRC
EN
INTE
N
0
LEN
LWM
r
rw
rw
rw
r
rw
rw
Field
Bits
Type
Description
LWM
0
rw
Last Write Mode
This bit-field defines the last word of the CAN payload data expected to
be written by the host to Tx Host Buffer
0B Dynamic Data Length: The last word to be read by the host is
defined by the DLC of the transmit CAN frame
1B Fixed Data Length
The last word to be written by the host is defined by
Ni_CRE_HBUF_TXz_CONFIG.LEN. Ni_CRE_HBUF_TXz_CONFIG.LEN
shall be configured greater than 0
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4025
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
LEN
6:1
rw
Fixed Data Length
This bit-field contains the length of CAN Data field in words (4 bytes)
which is stored in the Transmit Host Buffer. It defines the last word to
be written by the host when LWM=1. This bit-field is ignored when
LWM=0.
0 - No payload data
1 - Data length of 4 bytes or 1 word
2 - Data length of 8 bytes or 2 words
.
.
16 - Data length of 64 bytes or 16 words
others - Incorrect (shall not be more than 16)
INTEN
9
rw
Interrupt or Trigger Enable
This bit-field enables the generation of trigger signal to DRE/interrupt
to IR when the Transmit Host Buffer is available to transmit a new CAN
frame. Only Tx Host Buffer 0 shall be used to trigger DRE. In case the Tx
Host Buffer 1 INTEN is set to 0, there is no trigger to DRE nor an
interrupt
Note: The interrupt is triggered only when the Tx Host Buffer is emptied
after being filled.
0B TRIG Enabled
The Transmit Host Buffer trigger signal is enabled
1B Interrupt Enabled
The Transmit Host Buffer interrupt is enabled
CRCEN
10
rw
CRC calculation enable
This bit controls enable and disable of CRC calculation when INTEN is 1
CRC calculation is always enabled when INTEN is 0
0B CRC calculation disabled
1B CRC calculation enabled
CRCG
11
rw
CRC gate
This bit controls whether the CAN frame with CRC error is processed
further or discarded by the CRE
0B CAN frame is not discarded
1B CAN frame discarded
0
8:7,
31:12
r
Reserved
Read as 0; should be written with 0.
21.7.59
Node i Transmit Host Buffer z Status
This register provides the status information of the Transmit Host buffer.
Ni_CRE_HBUF_TXz_STAT (i=0-3;z=0-1)
Offset address:
0016CH+i*400H+z*8
Node i Transmit Host Buffer z Status
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4026
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
COUNT
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
WEG
INDEX
0
SWT
RIG
0
THR
EQ
0
0
rwh
rh
r
rwh
r
rwh
r
r
Field
Bits
Type
Description
THREQ
3
rwh
Free Transmit Host Buffer z
This bit-field indicates a pending transfer request of Transmit Host
Buffer. It is set to 0 by hardware, when the Transmit Host Buffer is free
to accept a new transmit CAN frame. Upon "last word" write
completion event to the Tx Host Buffer the HW sets this bit to 1
indicating buffer full. SW write to 1 also clears the bit. A SW write by 0
has no effect. An interrupt TXHBUF_INT is triggered when enabled in
Ni_CRE_HBUF_TXz_CONFIG.INTEN=1 to indicate free buffer element..
SWTRIG
5
rwh
Software DRE Tigger
SW trigger to the DRE. SW writes 1 to request trigger to DRE. HW clears
it after trigger to DRE. SW write with 0 has no effect.
Note: Write to this bit is valid only for Tx Host buffer 0. SW write has no
effect for Tx Host buffer 1
INDEX
13:8
rh
TxFIFO/Queue Index
This bit-field indicates the Put Index of TxFIFO / Queue, to which the
current CAN frame will be written to.
WEG
15:14
rwh
Watchdog Event Group
Set by hardware when there is a watchdog timeout error. This bit-field
indicates which event group has watchdog timeout error. Write
operation of any non-zero value resets the value to 0. Writing 0 does not
change the value of the bit-field
00B No Error
01B WDG1 Error
10B WDG2 Error
11B WDG3 Error
COUNT
23:16
rwh
Counter
The count field increments by 1 for every successful write of a CAN
frame by host to the Transmit Host Buffer. The Counter wraps around to
0 by hardware upon overflow. A write operation of any non zero value
resets the counters value to 0. Writing of 0 does not change the value
0
1:0,
2,
4,
7:6,
31:24
r
Reserved
Reserved. Read as 0; should be written with 0
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4027
v1.1
2025-06-26


21.7.60
Node i CRE Interrupt Register
The flags are set when one of the listed conditions is detected (edge-sensitive). The flags remain set until the
Host clears them. A flag is cleared by writing a 1 to the corresponding bit position. Writing a 0 has no effect.
Ni_CRE_IR (i=0-3)
Offset address:
0018CH+i*400H
Node i CRE Interrupt Register
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
TWDT
I1
TWD
TI0
RWD
TI1
RWD
TI0
CRCI
1
CRCI
0
IWSI
1
IWSI
0
IRSI1 IRSI0
XFR
MLI
SFR
MLI
TBU
F1I
TBU
F0I
RBU
F1I
RBU
F0I
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
RBUF0I
0
rwh
Node i Rx Host Buffer 0 interrupt flag
This flag is set after the Receive Interface writes the complete frame to
the Receive Host Buffer 0. The Receive Host Buffer interrupt or trigger
can be used by a master of FPI to read the CAN frame from the Receive
Host Buffer 0.
RBUF1I
1
rwh
Node i Rx Host Buffer 1 interrupt flag
This flag is set after the Receive Interface writes the complete frame to
the Receive Host Buffer 1. The Receive Host Buffer interrupt or trigger
can be used by a master of FPI to read the CAN frame from the Receive
Host Buffer 1.
TBUF0I
2
rwh
Node i Tx Host Buffer 0 interrupt flag
This flag is set after the Transmit Interface identifies a free Transmit
Host Buffer 0 element. The Transmit Host Buffer interrupt or trigger can
be used by a master of FPI to write the CAN frame to the Transmit Host
Buffer 0.
TBUF1I
3
rwh
Node i Tx Host Buffer 1 interrupt flag
This flag is set after the Transmit Interface identifies a free Transmit
Host Buffer 1 element. The Transmit Host Buffer interrupt or trigger can
be used by a master of FPI to write the CAN frame to the Transmit Host
Buffer 1.
SFRMLI
4
rwh
Node i STD ID Frame measure lost interrupt flag
This flag is set when there is loss of standard ID frame measure count
while the STDLOCK is set by the user in the Ni_IDMU_FRTCONFIG SFR
XFRMLI
5
rwh
Node i XTD ID Frame measure lost interrupt flag
This flag is set when there is loss of extended ID frame measure count
while the XTDLOCK is set by the user in the Ni_IDMU_FRTCONFIG SFR
IRSI0
6
rwh
Node i Incorrect read sequence error interrupt 0
This flag is set when there is an incorrect read sequence error interrupt
triggered for Rx Host Buffer 0
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4028
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
IRSI1
7
rwh
Node i Incorrect read sequence error interrupt 1
This flag is set when there is an incorrect read sequence error interrupt
triggered for Rx Host Buffer 1
IWSI0
8
rwh
Node i Incorrect write sequence error interrupt 0
This flag is set when an incorrect write sequence error interrupt is
triggered for Tx Host Buffer 0
IWSI1
9
rwh
Node i Incorrect write sequence error interrupt 1
This flag is set when an incorrect write sequence error interrupt is
triggered for Tx Host Buffer 1
CRCI0
10
rwh
Node i CRC error interrupt 0
This flag is set when CRC error interrupt is triggered for Tx Host buffer 0
CRCI1
11
rwh
Node i CRC error interrupt 1
This flag is set when CRC error interrupt is triggered for Tx Host buffer 1
RWDTI0
12
rwh
Node i RHBUF0 watchdog timeout error interrupt 0
This flag is set when RHBUF0 watchdog timeout error interrupt is
triggered
RWDTI1
13
rwh
Node i RHBUF1 watchdog timeout error interrupt 1
This flag is set when RHBUF1 watchdog timeout error interrupt is
triggered
TWDTI0
14
rwh
Node i THBUF0 watchdog timeout error interrupt 0
This flag is set when THBUF0 watchdog timeout error interrupt is
triggered
TWDTI1
15
rwh
Node i THBUF1 watchdog timeout error interrupt 1
This flag is set when THBUF1 watchdog timeout error interrupt is
triggered
0
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.61
Node i Frame Rate Measure Table Configuration
Configuration registers for IDMU
This register controls the Frame Rate Measure Tables
Ni_IDMU_FRTCONFIG (i=0-3)
Offset address:
00190H+i*400H
Node i Frame Rate Measure Table Configuration
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
INTE
N1
0
XTDL
OCK
0
INTE
N0
0
STDL
OCK
r
rw
r
rwh
r
rw
r
rwh
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4029
v1.1
2025-06-26


Field
Bits
Type
Description
STDLOCK
0
rwh
Lock STD ID Frame Rate Measures
Lock bit to freeze the Standard ID Frame Rate Measures. This bit is set
by the user (eg. in a timer-based interrupt service routine) to read the
STD ID frame rate measure counters
INTEN0
2
rw
STD ID Frame rate measure Interrupt Enable
This bit-field enables / disables the generation of interrupt when a
frame is received while the Frame Rate Measure counters (FRMs) are
frozen i.e when the STDLOCK is set and there is a loss of frame count.
0B Disable
The STD ID Frame rate measure interrupt is disabled
1B Enabled
The STD ID Frame rate measure interrupt is enabled
XTDLOCK
8
rwh
Lock XTD ID Frame Rate Measures
Lock bit to freeze the Extended ID Frame Rate Measures. This bit is set
by the user (eg. in a timer-based interrupt service routine) to read the
XTD ID frame rate measure counters
INTEN1
10
rw
XTD ID Frame rate measure Interrupt Enable
This bit-field enables / disables the generation of interrupt when a
frame is received while the Frame Rate Measure counters (FRMs) are
frozen i.e when the XTDLOCK is set and there is a loss of frame count.
0B Disable
The XTD ID Frame rate measure interrupt is disabled
1B Enabled
The XTD ID Frame rate measure interrupt is enabled
0
1,
7:3,
9,
31:11
r
Reserved
Read as 0; should be written with 0
21.7.62
Node i Rx Throughput Measure configuration
Configuration registers for IDMU
This register provides the Rx Throughput Measured over a set of frames of the MCAN and its corresponding
control bits
Ni_IDMU_RXTPCFG (i=0-3)
Offset address:
00194H+i*400H
Node i Rx Throughput Measure configuration
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
TP
rwh
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4030
v1.1
2025-06-26


Field
Bits
Type
Description
TP
15:0
rwh
Rx Throughput Measure
Rx Throughput Measure is relevant for Intrusion detection. It indicates
the total number of frames received by the MCMCAN.
0
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.63
Node i CRE Error control register
The CRE error control register is used to enable particular monitoring group of start and end conditions and
control the interrupt enable.
Ni_ERRCTRL (i=0-3)
Offset address:
00198H+i*400H
Node i CRE Error control register
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
TWD
1IE
TWD
0IE
IWSI
E
IRSIE CRCI
E
RWD
1IE
RWD
0IE
WDG
3
WDG
2
WDG
1
r
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
WDG1
0
rwh
Enable bit for watchdog timeout monitoring event group 1
When this bit is set, the following start and end conditions are
monitored. These events are compelety under the control of CRE
1.
•
Start condition : RxFIFO not empty
•
End condition : RxFIFO processing done
2.
•
Start condition : THBUF full
•
End condition : THBUF empty
WDG2
1
rwh
Enable bit for watchdog timeout monitoring event group 2
When this bit is set, the following start and end conditions are
monitored. These events are dependent on the System, DRE and
message frequency
1.
•
Start condition : RHBUF empty
•
End condition : RHBUF full
2.
•
Start condition : THBUF empty
•
End condition : THBUF full
WDG3
2
rwh
Enable bit for watchdog timeout monitoring event group 3
When this bit is set, the following start and end conditions are
monitored. This is dependent on DRE or System
1.
•
Start condition : RHBUF full
•
End condition : RHBUF empty
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4031
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
RWD0IE
3
rwh
Receive watchdog timeout 0 interrupt enable
0B DIS: Disable RHBUF watchdog timeout error interrupt
1B EN: Enable RHBUF watchdog timeout error interrupt
RWD1IE
4
rwh
Receive watchdog timeout 1 interrupt enable
0B DIS: Disable RHBUF watchdog timeout error interrupt
1B EN: Enable RHBUF watchdog timeout error interrupt
CRCIE
5
rwh
CRC error interrupt enable
0B DIS: Disable CRC error interrupt
1B EN: Enable CRC error interrupt
IRSIE
6
rwh
Incorrect read sequence error interrupt enable
0B DIS: Disable invalid read sequence error interrupt
1B EN: Enable invalid read sequence error interrupt
IWSIE
7
rwh
Incorrect write sequence error interrupt enable
0B DIS: Disable invalid write sequence error interrupt
1B EN: Enable invalid write sequence error interrupt
TWD0IE
8
rwh
Transmit watchdog timeout 0 interrupt enable
0B DIS: Disable THBUF watchdog timeout error interrupt
1B EN: Enable THBUF watchdog timeout error interrupt
TWD1IE
9
rwh
Transmit watchdog timeout 1 interrupt enable
0B DIS: Disable THBUF watchdog timeout error interrupt
1B EN: Enable THBUF watchdog timeout error interrupt
0
31:10
r
Reserved
21.7.64
Node i Core Release Register
Ni_CREL (i=0-3)
Offset address:
00200H+i*400H
Node i Core Release Register
Kernel Reset value:
3308 1114H
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
Time Stamp Day
MON
15:8
r
Time Stamp Month
YEAR
19:16
r
Time Stamp Year
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4032
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
SUBSTEP
23:20
r
Sub-step of Core Release
One digit, BCD-coded.
STEP
27:24
r
Step of Core Release
One digit, BCD-coded.
REL
31:28
r
Core Release
One digit, BCD-coded.
Table 1014
Example for Coding of Revisions
Release
Step
SubStep
Year
Month
Day
Name
0
1
0
0
03
10
Revision 0.1.0, Date 2010/03/10
21.7.65
Node i Endian Register
Ni_ENDN (i=0-3)
Offset address:
00204H+i*400H
Node i Endian Register
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
Endianness Test Value
The endianness test value is 0x87654321.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4033
v1.1
2025-06-26


21.7.66
Node i Data Bit Timing & Prescaler Register
This register is only writable if bits Ni_CCCR.CCE and Ni_CCCR.INIT are set. The CAN bit time may be
programmed in the range of 4 to 49 time quanta. The CAN time quantum may be programmed in the range of 1
to 32 clock cycles. tq = (DBRP + 1) clock cycles.
DTSEG1 is the sum of Prop_Seg and Phase_Seg1. DTSEG2 is Phase_Seg2.
Therefore the length of the bit time is (programmed values) [DTSEG1 + DTSEG2 + 3] tq or (functional values)
[Sync_Seg + Prop_Seg + Phase_Seg1 + Phase_Seg2] tq.
The Information Processing Time (IPT) is zero, meaning the data for the next bit is available at the first clock
edge after the sample point.
Note:
With a CAN clock of 8 MHz, the reset value of 0x00000A33 configures the M_CAN for a fast bit rate of
500 kbit/s.
The bit rate configured for the CAN FD data phase via DBTP must be higher or equal to the bit rate
configured for the arbitration phase via NBTP.
Ni_DBTP (i=0-3)
Offset address:
0020CH+i*400H
Node i Data Bit Timing & Prescaler Register
Reset values see:
Table 1015
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
TDC
0
DBRP
r
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
DTSEG1
DTSEG2
DSJW
r
rw
rw
rw
Field
Bits
Type
Description
DSJW
3:0
rw
Data (Re) Synchronization Jump Width
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Valid values are 0 to 15. The actual interpretation by the hardware of
this value is such that one more than the value programmed here is
used.
DTSEG2
7:4
rw
Data time segment after sample point
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Valid values are 0 to 15. The actual interpretation by the hardware of
this value is such that one more than the programmed value is used.
DTSEG1
12:8
rw
Data time segment before sample point
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Valid values are 0 to 31. The actual interpretation by the hardware of
this value is such that one more than the programmed value is used.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4034
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DBRP
20:16
rw
Data Baud Rate Prescaler
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
The value by which the oscillator frequency is divided for generating
the bit time quanta. The bit time is built up from a multiple of this
quanta. Valid values for the Baud Rate Prescaler are  0 to 31. The actual
interpretation by the hardware of this value is such that one more than
the value programmed here is used.
TDC
23
rw
Transmitter Delay Compensation
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Transmitter Delay Compensation disabled
1B Transmitter Delay Compensation enabled
0
15:13,
22:21,
31:24
r
Reserved
Read as 0; should be written with 0.
Table 1015
Reset values of Ni_DBTP (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0A33H
 
After Boot-FW
Value
0000 0000 –XX– ––––
XXX– –––– –––– ––––B
After CAN BSL execution (applicable only for CAN0 and Node 1)
21.7.67
Node i Test Register
Write access to the Test Register has to be enabled by setting bit Ni_CCCR.TEST to ‘1’. All Test Register functions
are set to their reset values when bit Ni_CCCR.TEST is reset.
Loop Back Mode and software control of transmit pin are hardware test modes. Programming of Ni_TEST.TX ≠
“00” may disturb the message transfer on the CAN bus.
Ni_TEST (i=0-3)
Offset address:
00210H+i*400H
Node i Test Register
Reset values see:
Table 1016
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
RX
TX
LBCK
0
0
0
0
r
rh
rw
rw
r
r
r
r
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4035
v1.1
2025-06-26


Field
Bits
Type
Description
LBCK
4
rw
Loop Back Mode
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
This is the external loop back mode, visible on the outside.
0B Reset value, Loop Back Mode is disabled
1B Loop Back Mode is enabled
TX
6:5
rw
Control of Transmit Pin
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
00B Reset value, TX pin controlled by the CAN Core, updated at the
end of the CAN bit time
01B Sample Point can be monitored at the TX pin
10B Dominant (‘0’) level at TX pin.
11B Recessive (‘1’) at TX pin.
RX
7
rh
Receive Pin
Monitors the actual value of RX pin.
0B The CAN bus is dominant (RXD = ‘0’)
1B The CAN bus is recessive (RXD = ‘1’)
0
0,
1,
2,
3,
31:8
r
Reserved
Read as 0; should be written with 0.
Table 1016
Reset values of Ni_TEST (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0000H
Value of RX depends on RX signal value.
21.7.68
Node i RAM Watchdog
The RAM Watchdog monitors the READY output of the Message RAM. A Message RAM access via the M_CAN’s
Generic Master Interface starts the Message RAM Watchdog Counter with the value configured by Ni_RWD.WDC.
The counter is reloaded with RWD.WDC when the Message RAM signals successful completion. In case there is
no response from the Message RAM until the counter has counted down to zero, the counter stops and interrupt
flag Ni_IR.WDI is set. The RAM Watchdog Counter is clocked by the Host clock.
Ni_RWD (i=0-3)
Offset address:
00214H+i*400H
Node i RAM Watchdog
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
WDV
WDC
rh
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4036
v1.1
2025-06-26


Field
Bits
Type
Description
WDC
7:0
rw
Watchdog Configuration
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start value of the Message RAM Watchdog Counter. With the reset value
of “00” the counter is disabled.
00H Watchdog disabled
others, Start value of the Message RAM Watchdog Counter
WDV
15:8
rh
Watchdog Value
Actual Message RAM Watchdog Counter Value.
0
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.69
Node i CC Control Register
The Ni_CCCR register enables and disables CAN bus participation and basic protocol functions. Due to
synchronization mechanisms between the clock domains, after a write operation to Ni_CCCR, the register shall
be read back, until the set values are written to the register. Please keep in mind, that the register also includes
hardware influenced bits.
Note:
After enabling the CAN clocks in MCR register, the application software has to wait for 10 host clock
cycles before accessing the kernel registers.
Note:
LDMST or SWAPMSK.W instructions should be used only with bit mask enabled for rwh bits in this
register.
Ni_CCCR (i=0-3)
Offset address:
00218H+i*400H
Node i CC Control Register
Reset values see:
Table 1017
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
NISO
TXP
EFBI
PXH
D
WM
M
UTS
U
BRSE
FDO
E
TEST
DAR
MON
CSR
CSA
ASM
CCE
INIT
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
rh
rwh
rw
rwh
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4037
v1.1
2025-06-26


Field
Bits
Type
Description
INIT
0
rwh
Initialization
Note:
Due to the synchronization mechanism between the two
clock domains, there may be a delay until the value written
to INIT can be read back. Therefore the programmer has
to assure that the previous value written to INIT has been
accepted by reading INIT before setting INIT to a new value.
0B Normal Operation
1B Initialization is started
CCE
1
rw
Configuration Change Enable
0B The CPU has no write access to the protected configuration
registers
1B The CPU has write access to the protected configuration registers
(while CCCR.INIT = ‘1’)
ASM
2
rwh
Restricted Operation Mode
Bit ASM can only be set by the Host when both CCE and INIT are set to
‘1’. In can also be set by the M_CAN. The bit can be reset by the Host at
any time. For a description of the Restricted Operation Mode see
paragraph Restricted Operation Mode.
0B Normal CAN operation
1B Restricted Operation Mode active
CSA
3
rh
Clock Stop Acknowledge
0B No clock stop acknowledged
1B M_CAN may be set in power down by stopping the synchronous
and the asynchronous clock source
CSR
4
rw
Clock Stop Request
0B No clock stop is requested
1B Clock stop requested. When clock stop is requested, first INIT and
then CSA will be set after all pending transfer requests have been
completed and the CAN bus reached idle.
MON
5
rw
Bus Monitoring Mode
Bit MON can only be set by the Host when both CCE and INIT are set to
‘1’. The bit can be reset by the Host at any time.
0B Bus Monitoring Mode is disabled
1B Bus Monitoring Mode is enabled
DAR
6
rw
Disable Automatic Retransmission
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Automatic retransmission of messages not transmitted
successfully enabled
1B Automatic retransmission disabled
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4038
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TEST
7
rw
Test Mode Enable
The TEST register can only be set, if CCE, INIT and TEST are set. Writes
to test will only have effect, if all three bits are set.
0B Normal operation, register TEST holds reset values
1B Test Mode, write access to register TEST enabled
FDOE
8
rw
FD Operation Enable
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B CAN FD frame format disabled.
1B CAN FD frame format enabled.
BRSE
9
rw
Bit Rate Switch Enable
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Bit rate switching for transmission disabled.
1B Bit rate switching for transmission enabled.
UTSU
10
rw
Use Timestamping register
When UTSU is set, 16-bit Wide Message Markers are also enabled
regardless of the value of WMM.
0B Internal time stamping
1B External time stamping by TSU
WMM
11
rw
Wide Message Marker
Enables the use of 16-bit Wide Message Markers. When 16-bit Wide
Message Markers are used (WMM = '1'), 16-bit internal timestamping is
disabled for the Tx Event FIFO.
0B 8-bit Message Marker used
1B 16-bit Message Marker used, replacing 16-bit timestamps in Tx
Event FIFO
PXHD
12
rw
Protocol Exception Handling Disable
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Protocol exception handling enabled.
1B Protocol exception handling disabled. (When protocol exception
handling is disabled, the M_CAN will transmit an error frame when
it detects a protocol exception condition.
EFBI
13
rw
Edge Filtering during Bus Integration
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Edge filter disabled
1B Two consecutive dominant tq required to detect an edge for hard
synchronization.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4039
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TXP
14
rw
Transmit Pause
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
If this bit is set, the M_CAN pauses for two CAN bit times before starting
the next transmission after itself has successfully transmitted a frame.
0B Transmit pause disabled
1B Transmit pause enabled
NISO
15
rw
Non ISO Operation
If this bit is set, the M_CAN uses the CAN FD frame format as specified
by the Bosch CAN FD Specification V1.0.
0B CAN FD frame format according to ISO11898-1
1B CAN FD frame format according to Bosch CAN FD Specification V1.0
0
31:16
r
Reserved
Read as 0; should be written with 0.
Table 1017
Reset values of Ni_CCCR (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0001H
 
After Boot-FW
Value
0000 0000 0000 0000
0000 00–– 0000 0000B
After CAN BSL execution (applicable only for CAN0 and Node 1)
21.7.70
Node i Nominal Bit Timing & Prescaler Register
This register is only writable if bits Ni_CCCR.CCE and Ni_CCCR.INIT are set.
The CAN bit time may be programmed in the range of 4 to 385 time quanta. The CAN time quantum may be
programmed in the range of 1 to 512 clock periods. tq = (NBRP + 1) clock periods.
NTSEG1 is the sum of Prop_Seg and Phase_Seg1. NTSEG2 is Phase_Seg2.
Therefore the length of the bit time is (programmed values) [NTSEG1 + NTSEG2 + 3] tq or (functional values)
[Sync_Seg + Prop_Seg + Phase_Seg1 + Phase_Seg2] tq.
The Information Processing Time (IPT) is zero, meaning the data for the next bit is available at the first clock
edge after the sample point.
Note:
With a CAN clock of 8 MHz, the reset value of 0600H0A03 configures the M_CAN for a bit rate of 500
kbit/s.
Ni_NBTP (i=0-3)
Offset address:
0021CH+i*400H
Node i Nominal Bit Timing & Prescaler Register
Reset values see:
Table 1018
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
NSJW
NBRP
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
NTSEG1
0
NTSEG2
rw
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4040
v1.1
2025-06-26


Field
Bits
Type
Description
NTSEG2
6:0
rw
Nominal Time segment after sample point
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Valid values are 1 to 127. The actual interpretation by the hardware of
this value is such that one more than the programmed value is used.
NTSEG1
15:8
rw
Nominal Time segment before sample point
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Valid values are 1 to 255. The actual interpretation by the hardware of
this value is such that one more than the programmed value is used.
NBRP
24:16
rw
Baud Rate Prescaler
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
The value by which the oscillator frequency is divided for generating
the bit time quanta. The bit time is built up from a multiple of this
quanta. Valid values for the Baud Rate Prescaler are 0 to 511. The actual
interpretation by the hardware of this value is such that one more than
the value programmed here is used.
NSJW
31:25
rw
(Re) Synchronization Jump Width
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Valid values are 0 to 127. The actual interpretation by the hardware of
this value is such that one more than the value programmed here is
used.
0
7
r
Reserved
Read as 0; should be written with 0.
Table 1018
Reset values of Ni_NBTP (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0600 0A03H
 
After Boot-FW
Value
–––– –––– –––– ––––
–––– –––– X––– ––––B
After CAN BSL execution (applicable only for CAN0 Node 1)
21.7.71
Node i Timestamp Counter Configuration
For a description of the Timestamp Counter see chapter Timestamp Generation
Ni_TSCC (i=0-3)
Offset address:
00220H+i*400H
Node i Timestamp Counter Configuration
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
TCP
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
TSS
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4041
v1.1
2025-06-26


Field
Bits
Type
Description
TSS
1:0
rw
Time segment before sample point
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
01B Timestamp counter value incremented according to TCP
10B External timestamp counter value used, timer to be started in
Ni_TIMER_CCR, the clock source as well as the chosen prescaler
has to be configured before using this feature.
others, Timestamp counter value always 0x0000
TCP
19:16
rw
Timestamp Counter Prescaler
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Configures the timestamp and timeout counters time unit in multiples
of CAN bit times [ 1…16 ]. The actual interpretation by the hardware of
this value is such that one more than the value programmed here is
used.
Note:
With CAN FD an external counter is required for timestamp
generation (TSS = “10”)
0
15:2,
31:20
r
Reserved
Read as 0; should be written with 0.
21.7.72
Node i Timestamp Counter Value
Ni_TSCV (i=0-3)
Offset address:
00224H+i*400H
Node i Timestamp Counter Value
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
TSC
rwh
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4042
v1.1
2025-06-26


Field
Bits
Type
Description
TSC
15:0
rwh
Timestamp Counter
The internal/external Timestamp Counter value is captured on start of
frame (both Rx and Tx). When Ni_TSCC.TSS = “01”, the Timestamp
Counter is incremented in multiples of CAN bit times [ 1…16 ]
depending on the configuration of Ni_TSCC.TCP. A wrap around sets
interrupt flag Ni_IR.TSW.
Write access resets the counter to zero.
When Ni_TSCC.TSS = “10”, TSC reflects the external Timestamp Counter
value. A write access has no impact.
Note:
A “wrap around” is a change of the Timestamp Counter
value from non-zero to zero not caused by write access to
Ni_TSCV.
0
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.73
Node i Timeout Counter Configuration
The Timeout Counter register is used to configure signaling timeout conditions for Rx FIFO 0, Rx FIFO 1, and the
Tx Event FIFO.
Ni_TOCC (i=0-3)
Offset address:
00228H+i*400H
Node i Timeout Counter Configuration
Kernel Reset value:
FFFF 0000H
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
TOP
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
TOS
ETO
C
r
rw
rw
Field
Bits
Type
Description
ETOC
0
rw
Enable Timeout Counter
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Note:
For use of timeout function with CAN FD see chapter Timeout
Counter.
0B Timeout Counter disabled
1B Timeout Counter enabled
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4043
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TOS
2:1
rw
Timeout Select
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
When operating in Continuous mode, a write to Ni_TOCV presets the
counter to the value configured by TOCC.TOP and continues down-
counting. When the Timeout Counter is controlled by one of the FIFOs,
an empty FIFO presets the counter to the value configured by
Ni_TOCC.TOP. Down-counting is started when the first FIFO element is
stored.
00B Continuous operation
01B Timeout controlled by Tx Event FIFO
10B Timeout controlled by Rx FIFO 0
11B Timeout controlled by Rx FIFO 1
TOP
31:16
rw
Timeout Period
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start value of the Timeout Counter (down-counter). Configures the
Timeout Period.
0
15:3
r
Reserved
Read as 0; should be written with 0.
21.7.74
Node i Timeout Counter Value
Ni_TOCV (i=0-3)
Offset address:
0022CH+i*400H
Node i Timeout Counter Value
Kernel Reset value:
0000 FFFFH
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
TOC
rwh
Field
Bits
Type
Description
TOC
15:0
rwh
Timeout Counter
The Timeout Counter is decremented in multiples of CAN bit times [1…
16] depending on the configuration of Ni_TSCC.TCP. When decremented
to zero, interrupt flag Ni_IR.TOO is set and the Timeout Counter is
stopped. Start and reset/restart conditions are configured via
Ni_TOCC.TOS.
Any write access will lead to clearing of the counter.
0
31:16
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4044
v1.1
2025-06-26


21.7.75
Node i Error Counter Register
Ni_ECR (i=0-3)
Offset address:
00240H+i*400H
Node i Error Counter Register
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
CEL
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
RP
REC
TEC
rh
rh
rh
Field
Bits
Type
Description
TEC
7:0
rh
Transmit Error Counter
Actual state of the Transmit Error Counter, values between 0 and 255
Note:
When CCCR.ASM is set, the CAN protocol controller does
not increment TEC and REC when a CAN protocol error is
detected, but CEL is still incremented.
REC
14:8
rh
Receive Error Counter
Actual state of the Receive Error Counter, values between 0 and 127
Note:
When CCCR.ASM is set, the CAN protocol controller does
not increment TEC and REC when a CAN protocol error is
detected, but CEL is still incremented.
RP
15
rh
Receive Error Passive
0B The Receive Error Counter is below the error passive level of 128
1B The Receive Error Counter has reached the error passive level of
128
CEL
23:16
rh
CAN Error Logging
The counter is incremented each time when a CAN protocol error
causes the Transmit Error Counter or the Receive Error Counter to be
incremented. It is reset by read access to CEL. The counter stops at
0xFF; the next increment of TEC or REC sets interrupt flag Ni_IR.ELO.
The counter is reset on read, if the bit Ni_PORTCTRL.DELE is set for the
node.
0
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.76
Node i Protocol Status Register
Ni_PSR (i=0-3)
Offset address:
00244H+i*400H
Node i Protocol Status Register
Kernel Reset value:
0000 0707H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4045
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
TDCV
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
PXE
RFDF
RBR
S
RESI
DLEC
BO
EW
EP
ACT
LEC
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4046
v1.1
2025-06-26


Field
Bits
Type
Description
LEC
2:0
rh
Last Error Code
The LEC indicates the type of the last error to occur on the CAN bus.
This field will be cleared to ‘0’ when a message has been transferred
(reception or transmission) without error. This bit-field is set to 0x7 on
read, if Ni_PORTCTRL.DELE is set.
Note:
The Bus_Off recovery sequence (see ISO11898-1) cannot
be shortened by setting or resetting Ni_CCCR.INIT. If the
device goes Bus_Off, it will set Ni_CCCR.INIT of its own
accord, stopping all bus activities. Once Ni_CCCR.INIT has
been cleared by the CPU, the device will then wait for
129 occurrences of Bus Idle (129 * 11 consecutive recessive
bits) before resuming normal operation. At the end of the
Bus_Off recovery sequence, the Error Management Counters
will be reset. During the waiting time after the resetting of
Ni_CCCR.INIT, each time a sequence of 11 recessive bits has
been monitored, a Bit0 Error code is written to Ni_PSR.LEC,
enabling the CPU to readily check up whether the CAN bus is
stuck at dominant or continuously disturbed and to monitor
the Bus_Off recovery sequence. Ni_ECR.REC is used to count
these sequences.
000B No Error: No error occurred since LEC has been reset by
successful reception or transmission.
001B Stuff Error: More than 5 equal bits in a sequence have occurred
in a part of a received message where this is not allowed.
010B Form Error: A fixed format part of a received frame has the
wrong format.
011B Ack Error: The message transmitted by the M_CAN was not
acknowledged by another node.
100B Bit1 Error: During the transmission of a message (with the
exception of the arbitration field), the device wanted to send a
recessive level (bit of logical value ‘1’), but the monitored bus
value was dominant.
101B Bit0 Error: During the transmission of a message (or
acknowledge bit, or active error flag, or overload flag), the
device wanted to send a dominant level (data or identifier bit
logical value ‘0’), but the monitored bus value was recessive.
During Bus_Off recovery this status is set each time a sequence
of 11 recessive bits has been monitored. This enables the CPU to
monitor the proceeding of the Bus_Off recovery sequence
(indicating the bus is not stuck at dominant or continuously
disturbed).
110B CRC Error: The CRC check sum of a received message was
incorrect. The CRC of an incoming message does not match with
the CRC calculated from the received data.
111B No Change: Any read access to the Protocol Status Register re-
initializes the LEC to ‘7’. When the LEC shows the value ‘7’, no
CAN bus event was detected since the last CPU read access to
the Protocol Status Register.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4047
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ACT
4:3
rh
Activity
Monitors the module’s CAN communication state.
Note:
ACT is set to “00” by a Protocol Exception Event.
00B Synchronizing - node is synchronizing on CAN communication
01B Idle - node is neither receiver nor transmitter
10B Receiver - node is operating as receiver
11B Transmitter - node is operating as transmitter
EP
5
rh
Error Passive
0B The M_CAN is in the Error_Active state. It normally takes part in
bus communication and sends an active error flag when an error
has been detected
1B The M_CAN is in the Error_Passive state
EW
6
rh
Warning Status
0B Both error counters are below the Error_Warning limit of 96
1B At least one of error counter has reached the Error_Warning limit
of 96
BO
7
rh
Bus_Off Status
0B The M_CAN is not in Bus_Off1)
1B The M_CAN is in Bus_Off state
DLEC
10:8
rh
Data Phase Last Error Code
Type of last error that occurred in the data phase of a CAN FD format
frame with its BRS flag set. Coding is the same as for LEC. This field will
be cleared to zero when a CAN FD format frame with its BRS flag set has
been transferred (reception or transmission) without error. This bit-field
is set to 0x7 on read, if Ni_PORTCTRL.DELE is set.
Note:
When a frame in CAN FD format has reached the data phase
with BRS flag set, the next CAN event (error or valid frame)
will be shown in DLEC instead of LEC. An error in a fixed stuff
bit of a CAN FD CRC sequence will be shown as a Form Error,
not Stuff Error.
RESI
11
rh
ESI flag of last received CAN FD Message
This bit is set together with REDF, independent of acceptance filtering.
This bit is reset after read access, if Ni_PORTCTRL.DELE is set.
0B Last received CAN FD message did not have its ESI flag set
1B Last received CAN FD message had its ESI flag set
RBRS
12
rh
BRS flag of last received CAN FD Message
This bit is set together with REDF, independent of acceptance filtering.
This bit is reset after read access, if Ni_PORTCTRL.DELE is set.
0B Last received CAN FD message did not have its BRS flag set
1B Last received CAN FD message had its BRS flag set
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4048
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
RFDF
13
rh
Received a CAN FD Message
This bit is set independent of acceptance filtering.
This bit is reset after read access, if Ni_PORTCTRL.DELE is set.
0B Since this bit was reset by the CPU, no CAN FD message has been
received
1B Message in CAN FD format with FDF flag set, has been received
PXE
14
rh
Protocol Exception Event
This bit is reset after read access, if Ni_PORTCTRL.DELE is set.
0B No protocol exception event occurred since last read access
1B Protocol exception event occurred
TDCV
22:16
rh
Transmitter Delay Compensation Value
Position of the secondary sample point, defined by the sum of the
measured delay from TX to RX and Ni_TDCR.TDCO. The SSP position is,
in the data phase, the number of mtq between the start of the
transmitted bit and the secondary sample point. Valid values are 0 to
127 mtq.
0
15,
31:23
r
Reserved
Read as 0; should be written with 0.
1)
The Bus_Off recovery sequence (see ISO11898-1) cannot be shortened by setting or resetting CCCR.INIT. If the device goes
Bus_Off, it will set CCCR.INIT of its own accord, stopping all bus activities. Once CCCR.INIT has been cleared by the CPU, the device
will then wait for 129 occurrences of Bus Idle (129 * 11 consecutive recessive bits) before resuming normal operation. At the end
of the Bus_Off recovery sequence, the Error Management Counters will be reset. During the waiting time after the resetting of
CCCR.INIT, each time a sequence of 11 recessive bits has been monitored, a Bit0Error code is written to PSR.LEC, enabling the
CPU to readily check up whether the CAN bus is stuck at dominant or continuously disturbed and to monitor the Bus_Off recovery
sequence. ECR.REC is used to count these sequences.
21.7.77
Node i Transmitter Delay Compensation Register
Ni_TDCR (i=0-3)
Offset address:
00248H+i*400H
Node i Transmitter Delay Compensation Register
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
TDCO
0
TDCF
r
rw
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4049
v1.1
2025-06-26


Field
Bits
Type
Description
TDCF
6:0
rw
Transmitter Delay Compensation Filter Window Length
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set. Defines the minimum value for the Secondary Sample
Point position, dominant edges on RX that would result in an earlier
Secondary Sample Point position are ignored for transmitter delay
measurement. This feature is enabled when TDCF is configured to a
value greater than TDCO. Valid values are from 0 to 127 mtq.
TDCO
14:8
rw
Transmitter Delay Compensation Offset
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set. Offset value defining the distance between the
measured delay from TX to RX and the secondary sample point. Valid
values are 0 to 127 mtq. The duration of one mtq is equal to the fASYNi
clock period.
0
7,
31:15
r
Reserved
Read as 0; should be written with 0.
21.7.78
Node i Interrupt Register
The flags are set when one of the listed conditions is detected (edge-sensitive). The flags remain set until the
Host clears them. A flag is cleared by writing a “1” to the corresponding bit position. Writing a “0” has no effect.
The configuration of Ni_IE controls whether an interrupt is generated.
Note:
LDMST or SWAPMSK.W instructions should be used only with bit mask enabled for all rwh bits in this
register.
Ni_IR (i=0-3)
Offset address:
00250H+i*400H
Node i Interrupt Register
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
0
PED
PEA
WDI
BO
EW
EP
ELO
0
0
DRX
TOO
MRA
F
TSW
r
r
rwh
rwh
rwh
rwh
rwh
rwh
rwh
r
r
rwh
rwh
rwh
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
TEFL
TEFF
TEF
W
TEFN
TFE
TCF
TC
HPM RF1L RF1F
RF1
W
RF1
N
RF0L RF0F
RF0
W
RF0
N
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
RF0N
0
rwh
Rx FIFO 0 New Message
0B No new message written to Rx FIFO 0
1B New message written to Rx FIFO 0
RF0W
1
rwh
Rx FIFO 0 Watermark Reached
0B Rx FIFO 0 fill level below watermark
1B Rx FIFO 0 fill level reached watermark
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4050
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
RF0F
2
rwh
Rx FIFO 0 Full
0B Rx FIFO 0 not full
1B Rx FIFO 0 full
RF0L
3
rwh
Rx FIFO 0 Message Lost
0B No Rx FIFO 0 message lost
1B Rx FIFO 0 message lost, also set after write attempt to Rx FIFO 0 of
size zero
RF1N
4
rwh
Rx FIFO 1 New Message
0B No new message written to Rx FIFO 1
1B New message written to Rx FIFO 1
RF1W
5
rwh
Rx FIFO 1 Watermark Reached
0B Rx FIFO 1 fill level below watermark
1B Rx FIFO 1 fill level reached watermark
RF1F
6
rwh
Rx FIFO 1 Full
0B Rx FIFO 1 not full
1B Rx FIFO 1 full
RF1L
7
rwh
Rx FIFO 1 Message Lost
0B No Rx FIFO 1 message lost
1B Rx FIFO 1 message lost, also set after write attempt to Rx FIFO 1 of
size zero
HPM
8
rwh
High Priority Message
0B No high priority message received
1B High priority message received
TC
9
rwh
Transmission Completed
0B No transmission completed
1B Transmission completed
TCF
10
rwh
Transmission Cancellation Finished
0B No transmission cancellation finished
1B Transmission cancellation finished
TFE
11
rwh
Tx FIFO Empty
0B Tx FIFO non-empty
1B Tx FIFO empty
TEFN
12
rwh
Tx Event FIFO New Entry
0B Tx Event FIFO unchanged
1B Tx Handler wrote Tx Event FIFO element
TEFW
13
rwh
Tx Event FIFO Watermark Reached
0B Tx Event FIFO fill level below watermark
1B Tx Event FIFO fill level reached watermark
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4051
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TEFF
14
rwh
Tx Event FIFO Full
0B Tx Event FIFO not full
1B Tx Event FIFO full
TEFL
15
rwh
Tx Event FIFO Element Lost
0B No Tx Event FIFO element lost
1B Tx Event FIFO element lost, also set after write attempt to Tx Event
FIFO of size zero
TSW
16
rwh
Timestamp Wraparound
0B No timestamp counter wrap-around
1B Timestamp counter wrapped around
MRAF
17
rwh
Message RAM Access Failure
The flag is set, when the Rx Handler
•
has not completed acceptance filtering or storage of an accepted
message until the arbitration field of the following message has
been received. In this case acceptance filtering or message storage
is aborted and the Rx Handler starts processing of the following
message.
•
was not able to write a message to the Message RAM. In this case
message storage is aborted.
In both cases the FIFO put index is not updated resp. the New Data flag
for a dedicated Rx Buffer is not set, a partly stored message is
overwritten when the next message is stored to this location.
The flag is also set when the Tx Handler was not able to read a message
from the Message RAM in time. In this case message transmission is
aborted. In case of a Tx Handler access failure the M_CAN is switched
into Restricted Operation Mode. To leave Restricted Operation Mode,
the Host CPU has to reset Ni_CCCR.ASM.
0B No Message RAM access failure occurred
1B Message RAM access failure occurred
TOO
18
rwh
Timeout Occurred
0B No timeout
1B Timeout reached
DRX
19
rwh
Message stored to Dedicated Rx Buffer
The flag is set whenever a received message has been stored into a
dedicated Rx Buffer.
0B No Rx Buffer updated
1B At least one received message stored into an Rx Buffer
ELO
22
rwh
Error Logging Overflow
0B CAN Error Logging Counter did not overflow
1B Overflow of CAN Error Logging Counter occurred
EP
23
rwh
Error Passive
0B Error_Passive status unchanged
1B Error_Passive status changed
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4052
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
EW
24
rwh
Warning Status
0B Error_Warning status unchanged
1B Error_Warning status changed
BO
25
rwh
Bus_Off Status
0B Bus_Off status unchanged
1B Bus_Off status changed
WDI
26
rwh
Watchdog Interrupt
0B No Message RAM Watchdog event occurred
1B Message RAM Watchdog event due to missing READY
PEA
27
rwh
Protocol Error in Arbitration Phase
(Nominal Bit Time is used)
0B No protocol error in arbitration phase
1B Protocol error in arbitration phase detected (Ni_PSR.LEC ≠ 0,7)
PED
28
rwh
Protocol Error in Data Phase
(Data Bit Time is used)
0B No protocol error in data phase detected
1B Protocol error in data phase detected (Ni_PSR.DLEC ≠ 0,7)
0
20,
21,
29,
31:30
r
Reserved
Read as 0; shall be written with 0.
21.7.79
Node i Interrupt Enable
The settings in the Interrupt Enable register determine which status changes in the Interrupt Register will be
signalled on an interrupt line.
Ni_IE (i=0-3)
Offset address:
00254H+i*400H
Node i Interrupt Enable
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
0
PED
E
PEAE WDIE
BOE
EWE
EPE
ELOE
0
0
DRX
E
TOO
E
MRA
FE
TSW
E
r
r
rw
rw
rw
rw
rw
rw
rw
r
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
TEFL
E
TEFF
E
TEF
WE
TEFN
E
TFEE TCFE
TCE
HPM
E
RF1L
E
RF1F
E
RF1
WE
RF1
NE
RF0L
E
RF0F
E
RF0
WE
RF0
NE
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
21  Controller Area Network interface (CAN)
Reference manual
4053
v1.1
2025-06-26


Field
Bits
Type
Description
RF0NE
0
rw
Rx FIFO 0 New Message Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF0WE
1
rw
Rx FIFO 0 Watermark Reached Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF0FE
2
rw
Rx FIFO 0 Full Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF0LE
3
rw
Rx FIFO 0 Message Lost Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF1NE
4
rw
Rx FIFO 1 New Message Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF1WE
5
rw
Rx FIFO 1 Watermark Reached Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF1FE
6
rw
Rx FIFO 1 Full Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
RF1LE
7
rw
Rx FIFO 1 Message Lost Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
HPME
8
rw
High Priority Message Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TCE
9
rw
Transmission Completed Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TCFE
10
rw
Transmission Cancellation Finished Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TFEE
11
rw
Tx FIFO Empty Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TEFNE
12
rw
Tx Event FIFO New Entry Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4054
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TEFWE
13
rw
Tx Event FIFO Watermark Reached Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TEFFE
14
rw
Tx Event FIFO Full Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TEFLE
15
rw
Tx Event FIFO Element Lost Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TSWE
16
rw
Timestamp Wraparound Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
MRAFE
17
rw
Message RAM Access Failure Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
TOOE
18
rw
Timeout Occurred Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
DRXE
19
rw
Message stored to Dedicated Rx Buffer Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
ELOE
22
rw
Error Logging Overflow Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
EPE
23
rw
Error Passive Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
EWE
24
rw
Warning Status Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
BOE
25
rw
Bus_Off Status Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
WDIE
26
rw
Watchdog Interrupt Enable
0B Interrupt disabled
1B Interrupt enabled
PEAE
27
rw
Protocol Error in Arbitration Phase Enable
0B Interrupt disabled
1B Interrupt enabled
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4055
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
PEDE
28
rw
Protocol Error in Data Phase Enable
0B Interrupt disabled
1B Interrupt enabled
0
20,
21,
29,
31:30
r
Reserved
Read as 0; shall be written with 0.
21.7.80
Node i Global Filter Configuration
Global settings for Message ID filtering. The Global Filter Configuration controls the filter path for standard and
extended messages as described in Acceptance Filtering Chapter.
Ni_GFC (i=0-3)
Offset address:
00280H+i*400H
Node i Global Filter Configuration
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
ANFS
ANFE
RRFS RRFE
r
rw
rw
rw
rw
Field
Bits
Type
Description
RRFE
0
rw
Reject Remote Frames Extended
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Filter remote frames with 29-bit extended IDs
1B Reject all remote frames with 29-bit extended IDs
RRFS
1
rw
Reject Remote Frames Standard
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Filter remote frames with 11-bit standard IDs
1B Reject all remote frames with 11-bit standard IDs
ANFE
3:2
rw
Accept Non-matching Frames Extended
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Defines how received messages with 29-bit IDs that do not match any
element of the filter list are treated.
00B Accept in Rx FIFO 0
01B Accept in Rx FIFO 1
10B Reject
11B Reject
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4056
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ANFS
5:4
rw
Accept Non-matching Frames Standard
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Defines how received messages with 11-bit IDs that do not match any
element of the filter list are treated.
00B Accept in Rx FIFO 0
01B Accept in Rx FIFO 1
10B Reject
11B Reject
0
31:6
r
Reserved
Read as 0; should be written with 0.
21.7.81
Node i Standard ID Filter Configuration
Settings for 11-bit standard Message ID filtering. The Standard ID Filter Configuration controls the filter path for
standard messages.
Ni_SIDFC (i=0-3)
Offset address:
00284H+i*400H
Node i Standard ID Filter Configuration
Reset values see:
Table 1019
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
LSS
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
FLSSA
0
rw
r
Field
Bits
Type
Description
FLSSA
15:2
rw
Filter List Standard Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start address of standard Message ID filter list (32-bit word address).
LSS
23:16
rw
List Size Standard
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
00H No standard Message ID filter
01H 1 Message ID filter elements
…
80H 128 Message ID filter elements
others, 128 Message ID filter elements
0
1:0,
31:24
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4057
v1.1
2025-06-26


Table 1019
Reset values of Ni_SIDFC (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0000H
 
After Boot-FW
Value
0001 0000H
After CAN BSL execution (applicable only for CAN0 and Node 1)
21.7.82
Node i Extended ID Filter Configuration
Settings for 29-bit extended Message ID filtering. The Extended ID Filter Configuration controls the filter path for
standard messages as described in Acceptance Filtering Chapter.
Ni_XIDFC (i=0-3)
Offset address:
00288H+i*400H
Node i Extended ID Filter Configuration
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
LSE
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
FLESA
0
rw
r
Field
Bits
Type
Description
FLESA
15:2
rw
Filter List Extended Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start address of extended Message ID filter list (32-bit word addess).
LSE
22:16
rw
List Size Extended
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
00H No standard Message ID filter
01H 1 extended Message ID filter element
…
40H 64 extended Message ID filter element
others, 64 extended Message ID filter elements
0
1:0,
31:23
r
Reserved
Read as 0; should be written with 0.
21.7.83
Node i Extended ID AND Mask
Ni_XIDAM (i=0-3)
Offset address:
00290H+i*400H
Node i Extended ID AND Mask
Kernel Reset value:
1FFF FFFFH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4058
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
EIDM
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
EIDM
rw
Field
Bits
Type
Description
EIDM
28:0
rw
Extended ID Mask
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
For acceptance filtering of extended frames the Extended ID AND Mask
is ANDed with the Message ID of a received frame. Intended for masking
of 29-bit IDs in SAE J1939. With the reset value of all bits set to one the
mask is not active.
0
31:29
r
Reserved
Read as 0; should be written with 0.
21.7.84
Node i High Priority Message Status
This register is updated every time a Message ID filter element configured to generate a priority event matches.
This can be used to monitor the status of incoming high priority messages and to enable fast access to these
messages.
Ni_HPMS (i=0-3)
Offset address:
00294H+i*400H
Node i High Priority Message Status
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
FLST
FIDX
MSI
BIDX
rh
rh
rh
rh
Field
Bits
Type
Description
BIDX
5:0
rh
Buffer Index
Index of Rx FIFO element to which the message was stored. Only valid
when MSI[1] = ‘1’.
MSI
7:6
rh
Message Storage Indicator
00B No FIFO selected
01B FIFO message lost
10B Message stored in FIFO 0
11B Message stored in FIFO 1
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4059
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FIDX
14:8
rh
Filter Index
Index of matching filter element. Range is 0 to Ni_SIDFC.LSS - 1 resp.
Ni_XIDFC.LSE - 1.
FLST
15
rh
Filter List
Indicates the filter list of the matching filter element.
0B Standard Filter List
1B Extended Filter List
0
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.85
Node i New Data 1
The register holds the New Data flags of Rx Buffers 0 to 31.
Note:
LDMST or SWAPMSK.W instructions should be used only with bit mask enabled for all rwh bits in this
register.
Ni_NDAT1 (i=0-3)
Offset address:
00298H+i*400H
Node i New Data 1
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
ND31
ND3
0
ND2
9
ND2
8
ND2
7
ND2
6
ND2
5
ND2
4
ND2
3
ND2
2
ND2
1
ND2
0
ND1
9
ND1
8
ND1
7
ND1
6
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
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
ND15
ND1
4
ND1
3
ND1
2
ND1
1
ND1
0
ND9
ND8
ND7
ND6
ND5
ND4
ND3
ND2
ND1
ND0
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
NDy (y=0-31)
y
rwh
New Data in Rx Buffer y - ND
The flag is set when the respective Rx Buffer has been updated from a
received frame. The flags remain set until the Host clears them. A flag is
cleared by writing a “1” to the corresponding bit position. Writing a “0”
has no effect.
0B Rx Buffer not updated
1B Rx Buffer updated from new message
21.7.86
Node i New Data 2
The register holds the New Data flags of Rx Buffers 32 to 63.
Note:
LDMST or SWAPMSK.W instructions should be used only with bit mask enabled for all rwh bits in this
register.
Ni_NDAT2 (i=0-3)
Offset address:
0029CH+i*400H
Node i New Data 2
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4060
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
ND63
ND6
2
ND6
1
ND6
0
ND5
9
ND5
8
ND5
7
ND5
6
ND5
5
ND5
4
ND5
3
ND5
2
ND5
1
ND5
0
ND4
9
ND4
8
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
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
ND47
ND4
6
ND4
5
ND4
4
ND4
3
ND4
2
ND4
1
ND4
0
ND3
9
ND3
8
ND3
7
ND3
6
ND3
5
ND3
4
ND3
3
ND3
2
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
NDy (y=32-63)
y-32
rwh
New Data in Rx Buffer y - ND
The flag is set when the respective Rx Buffer has been updated from a
received frame. The flags remain set until the Host clears them. A flag is
cleared by writing a “1” to the corresponding bit position. Writing a “0”
has no effect.
0B Rx Buffer not updated
1B Rx Buffer updated from new message
21.7.87
Node i Rx FIFO 0 Configuration
Ni_RXF0C (i=0-3)
Offset address:
002A0H+i*400H
Node i Rx FIFO 0 Configuration
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
F0OM
F0WM
0
F0S
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
F0SA
0
rw
r
Field
Bits
Type
Description
F0SA
15:2
rw
Rx FIFO 0 Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start address of Rx FIFO 0 in Message RAM (32-bit word address, see
Message RAM Configuration Chapter).
F0S
22:16
rw
Rx FIFO 0 Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
00H No Rx FIFO 0
01H 1 Rx FIFO 0 elements
…
40H 64 Rx FIFO 0 elements
others, 64 Rx FIFO 0 elements
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4061
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
F0WM
30:24
rw
Rx FIFO 0 Watermark
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
01H Level 1 for Rx FIFO 0 watermark interrupt (IR.RF0W)
…
40H Level 64 for Rx FIFO 0 watermark interrupt (IR.RF0W)
others, Watermark interrupt disabled
F0OM
31
rw
FIFO 0 Operation Mode
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
FIFO 0 can be operated in blocking or in overwrite mode (see Rx FIFOs
Chapter).
0B FIFO 0 blocking mode
1B FIFO 0 overwrite mode
0
1:0,
23
r
Reserved
Read as 0; should be written with 0.
21.7.88
Node i Rx FIFO 0 Status
Ni_RXF0S (i=0-3)
Offset address:
002A4H+i*400H
Node i Rx FIFO 0 Status
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
RF0L
F0F
0
F0PI
r
rh
rh
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
F0GI
0
F0FL
r
rh
r
rh
Field
Bits
Type
Description
F0FL
6:0
rh
Rx FIFO 0 Fill Level
Number of elements stored in Rx FIFO 0, range 0 to 64.
F0GI
13:8
rh
Rx FIFO 0 Get Index
Rx FIFO 0 read index pointer, range 0 to 63.
F0PI
21:16
rh
Rx FIFO 0 Put Index
Rx FIFO 0 write index pointer, range 0 to 63.
F0F
24
rh
Rx FIFO 0 Full
0B Rx FIFO 0 not full
1B Rx FIFO 0 full
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4062
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
RF0L
25
rh
Rx FIFO 0 Message Lost
This bit is a copy of interrupt flag Ni_IR.RF0L. When Ni_IR.RF0L is reset,
this bit is also reset.
Note:
Overwriting the oldest message when Ni_RXF0C.F0OM = ‘1’
will not set this flag.
0B No Rx FIFO 0 message lost
1B Rx FIFO 0 message lost, also set after write attempt to Rx FIFO 0 of
size zero
0
7,
15:14,
23:22,
31:26
r
Reserved
Read as 0; should be written with 0.
21.7.89
Node i Rx FIFO 0 Acknowledge
Ni_RXF0A (i=0-3)
Offset address:
002A8H+i*400H
Node i Rx FIFO 0 Acknowledge
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
F0AI
r
rw
Field
Bits
Type
Description
F0AI
5:0
rw
Rx FIFO 0 Acknowledge Index
After the Host has read a message or a sequence of messages from Rx
FIFO 0 it has to write the buffer index of the last element read from Rx
FIFO 0 to F0AI. This will set the Rx FIFO 0 Get Index Ni_RXF0S.F0GI to
F0AI + 1 and update the FIFO 0 Fill Level Ni_RXF0S.F0FL.
0
31:6
r
Reserved
Read as 0; should be written with 0.
21.7.90
Node i Rx Buffer Configuration
Ni_RXBC (i=0-3)
Offset address:
002ACH+i*400H
Node i Rx Buffer Configuration
Reset values see:
Table 1020
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4063
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
RBSA
0
rw
r
Field
Bits
Type
Description
RBSA
15:2
rw
Rx Buffer Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Configures the start address of the Rx Buffers section in the Message
RAM (32-bit word address).
0
1:0,
31:16
r
Reserved
Read as 0; should be written with 0.
Table 1020
Reset values of Ni_RXBC (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0000H
 
After Boot-FW
Value
0000 0008H
After CAN BSL execution (applicable only for CAN0 and Node 1)
21.7.91
Node i Rx FIFO 1 Configuration
Ni_RXF1C (i=0-3)
Offset address:
002B0H+i*400H
Node i Rx FIFO 1 Configuration
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
F1OM
F1WM
0
F1S
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
F1SA
0
rw
r
Field
Bits
Type
Description
F1SA
15:2
rw
Rx FIFO 1 Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start address of Rx FIFO 1 in Message RAM (32-bit word address).
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4064
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
F1S
22:16
rw
Rx FIFO 1 Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
00H No Rx FIFO 1
01H 1 Rx FIFO 1 elements
…
40H 64 Rx FIFO 1 elements
others, 64 Rx FIFO 1 elements
F1WM
30:24
rw
Rx FIFO 1 Watermark
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
01H Level 1 for Rx FIFO 1 watermark interrupt (IR.RF1W)
…
40H Level 64 for Rx FIFO 1 watermark interrupt (IR.RF1W)
others, Watermark interrupt disabled
F1OM
31
rw
FIFO 1 Operation Mode
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
FIFO 1 can be operated in blocking or in overwrite mode.
0B FIFO 1 blocking mode
1B FIFO 1 overwrite mode
0
1:0,
23
r
Reserved
Read as 0; should be written with 0.
21.7.92
Node i Rx FIFO 1 Status
Ni_RXF1S (i=0-3)
Offset address:
002B4H+i*400H
Node i Rx FIFO 1 Status
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
0
RF1L
F1F
0
F1PI
r
r
rh
rh
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
F1GI
0
F1FL
r
rh
r
rh
Field
Bits
Type
Description
F1FL
6:0
rh
Rx FIFO 1 Fill Level
Number of elements stored in Rx FIFO 1, range 0 to 64.
F1GI
13:8
rh
Rx FIFO 1 Get Index
Rx FIFO 1 read index pointer, range 0 to 63.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4065
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
F1PI
21:16
rh
Rx FIFO 1 Put Index
Rx FIFO 1 write index pointer, range 0 to 63.
F1F
24
rh
Rx FIFO 1 Full
0B Rx FIFO 1 not full
1B Rx FIFO 1 full
RF1L
25
rh
Rx FIFO 1 Message Lost
This bit is a copy of interrupt flag Ni_IR.RF1L. When Ni_IR.RF1L is reset,
this bit is also reset.
Note:
Overwriting the oldest message when Ni_RXF1C.F1OM = ‘1’
will not set this flag.
0B No Rx FIFO 1 message lost
1B Rx FIFO 1 message lost, also set after write attempt to Rx FIFO 1 of
size zero
0
7,
15:14,
23:22,
29:26,
31:30
r
Reserved
Read as 0; should be written with 0.
21.7.93
Node i Rx FIFO 1 Acknowledge
Ni_RXF1A (i=0-3)
Offset address:
002B8H+i*400H
Node i Rx FIFO 1 Acknowledge
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
F1AI
r
rw
Field
Bits
Type
Description
F1AI
5:0
rw
Rx FIFO 1 Acknowledge Index
After the Host has read a message or a sequence of messages from Rx
FIFO 1 it has to write the buffer index of the last element read from Rx
FIFO 1 to F1AI. This will set the Rx FIFO 1 Get Index Ni_RXF1S.F1GI to
F1AI + 1 and update the FIFO 1 Fill Level Ni_RXF1S.F1FL
0
31:6
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4066
v1.1
2025-06-26


21.7.94
Node i Rx Buffer/FIFO Element Size Configuration
Configures the number of data bytes belonging to an Rx Buffer / Rx FIFO element. Data field sizes > 8 bytes are
intended for CAN FD operation only.
Ni_RXESC (i=0-3)
Offset address:
002BCH+i*400H
Node i Rx Buffer/FIFO Element Size Configuration
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
RBDS
0
F1DS
0
F0DS
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
F0DS
2:0
rw
Rx FIFO 0 Data Field Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Note:
In case the data field size of an accepted CAN frame exceeds
the data field size configured for the matching Rx Buffer
or Rx FIFO, only the number of bytes as configured by this
bit-field are stored to the Rx Buffer resp. Rx FIFO element.
The rest of the frame’s data field is ignored.
000B 8-byte data field
001B 12-byte data field
010B 16-byte data field
011B 20-byte data field
100B 24-byte data field
101B 32-byte data field
110B 48-byte data field
111B 64-byte data field
F1DS
6:4
rw
Rx FIFO 1 Data Field Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
000B 8-byte data field
001B 12-byte data field
010B 16-byte data field
011B 20-byte data field
100B 24-byte data field
101B 32-byte data field
110B 48-byte data field
111B 64-byte data field
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4067
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
RBDS
10:8
rw
Rx Buffer Data Field Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
000B 8-byte data field
001B 12-byte data field
010B 16-byte data field
011B 20-byte data field
100B 24-byte data field
101B 32-byte data field
110B 48-byte data field
111B 64-byte data field
0
3,
7,
31:11
r
Reserved
Read as 0; should be written with 0.
21.7.95
Node i Tx Buffer Configuration
Ni_TXBC (i=0-3)
Offset address:
002C0H+i*400H
Node i Tx Buffer Configuration
Reset values see:
Table 1021
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
TFQ
M
TFQS
0
NDTB
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
TBSA
0
rw
r
Field
Bits
Type
Description
TBSA
15:2
rw
Tx Buffers Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start address of Tx Buffers section in Message RAM (32-bit word
address).
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4068
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
NDTB
21:16
rw
Number of Dedicated Transmit Buffers
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Note:
Be aware that the sum of TFQS and NDTB may be
not greater than 32. There is no check for erroneous
configurations. The Tx Buffers section in the Message RAM
starts with the dedicated Tx Buffers.
00H No Dedicated Tx Buffers
01H 1 Dedicated Tx Buffers
…
20H 32 Dedicated Tx Buffers
others, 32 Dedicated Tx Buffers
TFQS
29:24
rw
Transmit FIFO/Queue Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
00H No Tx FIFO/Queue
01H 1 Tx Buffers used for Tx FIFO/Queue
…
20H 32 Tx Buffers used for Tx FIFO/Queue
others, 32 Tx Buffers used for Tx FIFO/Queue
TFQM
30
rw
Tx FIFO/Queue Mode
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
0B Tx FIFO operation
1B Tx Queue operation
0
1:0,
23:22,
31
r
Reserved
Read as 0; should be written with 0.
Table 1021
Reset values of Ni_TXBC (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0000H
 
After Boot-FW
Value
0000 1208H
After CAN BSL execution (applicable only for CAN0 and Node 1)
21.7.96
Node i Tx FIFO/Queue Status
The Tx FIFO/Queue status is related to the pending Tx requests listed in register Ni_TXBRP. Therefore the effect
of Add/Cancellation requests may be delayed due to a running Tx scan (Ni_TXBRP not yet updated).
Ni_TXFQS (i=0-3)
Offset address:
002C4H+i*400H
Node i Tx FIFO/Queue Status
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4069
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
TFQF
TFQPI
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
TFGI
0
TFFL
r
rh
r
rh
Field
Bits
Type
Description
TFFL
5:0
rh
Tx FIFO Free Level
Number of consecutive free Tx FIFO elements starting from TFGI, range
0 to 32. Read as zero when Tx Queue operation is configured
(Ni_TXBC.TFQM = ‘1’)
Note:
In case of mixed configurations where dedicated Tx Buffers
are combined with a Tx FIFO or a Tx Queue, the Put and Get
Indices indicate the number of the Tx Buffer starting with the
first dedicated Tx Buffers. Example: For a configuration of 12
dedicated Tx Buffers and a Tx FIFO of 20 Buffers a Put Index
of 15 points to the fourth buffer of the Tx FIFO.
TFGI
12:8
rh
Tx FIFO Get Index
Tx FIFO read index pointer, range 0 to 31. Read as zero when Tx Queue
operation is configured (Ni_TXBC.TFQM = ‘1’).
TFQPI
20:16
rh
Tx FIFO/Queue Put Index
Tx FIFO/Queue write index pointer, range 0 to 31.
TFQF
21
rh
Tx FIFO/Queue Full
0B Tx FIFO/Queue not full
1B Tx FIFO/Queue full
0
7:6,
15:13,
31:22
r
Reserved
Read as 0; should be written with 0.
21.7.97
Node i Tx Buffer Element Size Configuration
Configures the number of data bytes belonging to a Tx Buffer element. Data field sizes > 8 bytes are intended for
CAN FD operation only.
Ni_TXESC (i=0-3)
Offset address:
002C8H+i*400H
Node i Tx Buffer Element Size Configuration
Reset values see:
Table 1022
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
TBDS
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4070
v1.1
2025-06-26


Field
Bits
Type
Description
TBDS
2:0
rw
Tx Buffer Data Field Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Note:
In case the data length code DLC of a Tx Buffer element is
configured to a value higher than the Tx Buffer data field size
Ni_TXESC.TBDS, the bytes not defined by the Tx Buffer are
transmitted as “0xCC” (padding bytes).
000B 8-byte data field
001B 12-byte data field
010B 16-byte data field
011B 20-byte data field
100B 24-byte data field
101B 32-byte data field
110B 48-byte data field
111B 64-byte data field
0
31:3
r
Reserved
Read as 0; should be written with 0.
Table 1022
Reset values of Ni_TXESC (i=0-3)
Reset type
Reset value
Note
Kernel Reset
0000 0000H
 
After Boot-FW
Value
0000 0007H
After CAN BSL execution (applicable only for CAN0 and Node 1)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4071
v1.1
2025-06-26


21.7.98
Node i Tx Buffer Request Pending
Each Tx Buffer has its own Transmission Request Pending bit. The bits are set via register Ni_TXBAR. The bits
are reset after a requested transmission has completed or has been cancelled via register Ni_TXBCR.
Ni_TXBRP bits are set only for those Tx Buffers configured via Ni_TXBC. After a TXBRP bit has been set, a Tx scan
(Tx Handling) is started to check for the pending Tx request with the highest priority (Tx Buffer with lowest
Message ID).
A cancellation request resets the corresponding transmission request pending bit of register Ni_TXBRP. In case
a transmission has already been started when a cancellation is requested, this is done at the end of the
transmission, regardless whether the transmission was successful or not. The cancellation request bits are reset
directly after the corresponding TXBRP bit has been reset.
After a cancellation has been requested, a finished cancellation is signalled via Ni_TXBCF
•
after successful transmission together with the corresponding Ni_TXBTO bit
•
when the transmission has not yet been started at the point of cancellation
•
when the transmission has been aborted due to lost arbitration
•
when an error occurred during frame transmission
In "Disable Automatic Retransmission" mode all transmissions are automatically cancelled if they are not
successful. The corresponding Ni_TXBCF bit is set for all unsuccessful transmissions.
Note:
TXBRP bits which are set while a Tx scan is in progress are not considered during this particular
Tx scan. In case a cancellation is requested for such a Tx Buffer, this "Add Request" is cancelled
immediately, the corresponding Ni_TXBRP bit is reset.
Ni_TXBRP (i=0-3)
Offset address:
002CCH+i*400H
Node i Tx Buffer Request Pending
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
TRP3
1
TRP3
0
TRP2
9
TRP2
8
TRP2
7
TRP2
6
TRP2
5
TRP2
4
TRP2
3
TRP2
2
TRP2
1
TRP2
0
TRP1
9
TRP1
8
TRP1
7
TRP1
6
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
TRP1
5
TRP1
4
TRP1
3
TRP1
2
TRP1
1
TRP1
0
TRP9 TRP8 TRP7 TRP6 TRP5 TRP4 TRP3 TRP2 TRP1 TRP0
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
TRPz (z=0-31)
z
rh
Transmission Request Pending Tx Buffer z - TRP
0B No transmission request pending
1B Transmission request pending
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4072
v1.1
2025-06-26


21.7.99
Node i Tx Buffer Add Request
Each Tx Buffer has its own "Add Request" bit. Writing a ‘1’ will set the corresponding "Add Request" bit; writing
a ‘0’ has no impact. This enables the Host to set transmission requests for multiple Tx Buffers with one write to
Ni_TXBAR. Ni_TXBAR bits are set only for those Tx Buffers configured via Ni_TXBC. When no Tx scan is running,
the bits are reset immediately, else the bits remain set until the Tx scan process has completed.
Note:
If an add request is applied for a Tx Buffer with pending transmission request (corresponding
Ni_TXBRP bit already set), this add request is ignored. LDMST or SWAPMSK.W instructions should
be used only with bit mask enabled for all rwh bits in this register.
Ni_TXBAR (i=0-3)
Offset address:
002D0H+i*400H
Node i Tx Buffer Add Request
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
AR31 AR30 AR29 AR28 AR27 AR26 AR25 AR24 AR23 AR22 AR21 AR20 AR19 AR18 AR17 AR16
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
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
AR15 AR14 AR13 AR12 AR11 AR10
AR9
AR8
AR7
AR6
AR5
AR4
AR3
AR2
AR1
AR0
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
ARz (z=0-31)
z
rwh
Add Request Tx Buffer z - AR
0B No transmission request added
1B Transmission requested added
21.7.100
Node i Tx Buffer Cancellation Request
Each Tx Buffer has its own Cancellation Request bit. Writing a ‘1’ will set the corresponding Cancellation
Request bit; writing a ‘0’ has no impact. This enables the Host to set cancellation requests for multiple Tx
Buffers with one write to Ni_TXBCR. Ni_TXBCR bits are set only for those Tx Buffers configured via Ni_TXBC. The
bits remain set until the corresponding bit of Ni_TXBRP is reset.
Note:
LDMST or SWAPMSK.W instructions should be used only with bit mask enabled for all rwh bits in this
register.
Ni_TXBCR (i=0-3)
Offset address:
002D4H+i*400H
Node i Tx Buffer Cancellation Request
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
CR31 CR30 CR29 CR28 CR27 CR26 CR25 CR24 CR23 CR22 CR21 CR20 CR19 CR18 CR17 CR16
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
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
CR15 CR14 CR13 CR12 CR11 CR10
CR9
CR8
CR7
CR6
CR5
CR4
CR3
CR2
CR1
CR0
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rwh
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4073
v1.1
2025-06-26


Field
Bits
Type
Description
CRz (z=0-31)
z
rwh
Cancellation Request Tx Buffer z - CR
0B No cancellation pending
1B Cancellation pending
21.7.101
Node i Tx Buffer Transmission Occurred
Each Tx Buffer has its own Transmission Occurred bit. The bits are set when the corresponding Ni_TXBRP bit is
cleared after a successful transmission. The bits are reset when a new transmission is requested by writing a ‘1’
to the corresponding bit of register Ni_TXBAR.
Ni_TXBTO (i=0-3)
Offset address:
002D8H+i*400H
Node i Tx Buffer Transmission Occurred
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
TO31 TO30 TO29 TO28 TO27 TO26 TO25 TO24 TO23 TO22 TO21 TO20 TO19 TO18 TO17 TO16
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
TO15 TO14 TO13 TO12 TO11 TO10
TO9
TO8
TO7
TO6
TO5
TO4
TO3
TO2
TO1
TO0
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
TOz (z=0-31)
z
rh
Transmission Occurred Tx Buffer z - TO
0B No transmission occurred
1B Transmission occurred
21.7.102
Node i Tx Buffer Cancellation Finished
Each Tx Buffer has its own Cancellation Finished bit. The bits are set when the corresponding Ni_TXBRP bit is
cleared after a cancellation was requested via Ni_TXBCR. In case the corresponding Ni_TXBRP bit was not set at
the point of cancellation, CF is set immediately. The bits are reset when a new transmission is requested by
writing a ‘1’ to the corresponding bit of register Ni_TXBAR.
Ni_TXBCF (i=0-3)
Offset address:
002DCH+i*400H
Node i Tx Buffer Cancellation Finished
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
CF31
CF30 CF29 CF28 CF27 CF26 CF25 CF24 CF23 CF22 CF21 CF20 CF19 CF18 CF17 CF16
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
CF15
CF14 CF13 CF12 CF11 CF10
CF9
CF8
CF7
CF6
CF5
CF4
CF3
CF2
CF1
CF0
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4074
v1.1
2025-06-26


Field
Bits
Type
Description
CFz (z=0-31)
z
rh
Cancellation Finished Tx Buffer z - CF
0B No transmit buffer cancellation
1B Transmit buffer cancellation finished
21.7.103
Node i Tx Buffer Transmission Interrupt Enable
Each Tx Buffer has its own Transmission Interrupt Enable bit.
Ni_TXBTIE (i=0-3)
Offset address:
002E0H+i*400H
Node i Tx Buffer Transmission Interrupt Enable
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
TIE31
TIE3
0
TIE2
9
TIE2
8
TIE2
7
TIE2
6
TIE2
5
TIE2
4
TIE2
3
TIE2
2
TIE2
1
TIE2
0
TIE1
9
TIE1
8
TIE1
7
TIE1
6
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
TIE15
TIE1
4
TIE1
3
TIE1
2
TIE1
1
TIE1
0
TIE9
TIE8
TIE7
TIE6
TIE5
TIE4
TIE3
TIE2
TIE1
TIE0
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
TIEz (z=0-31)
z
rw
Transmission Interrupt Enable Tx Buffer z - TIE
0B Transmission interrupt disabled
1B Transmission interrupt enable
21.7.104
Node i Tx Buffer Cancellation Finished Interrupt Enable
Each Tx Buffer has its own Cancellation Finished Interrupt Enable bit.
Ni_TXBCIE (i=0-3)
Offset address:
002E4H+i*400H
Node i Tx Buffer Cancellation Finished Interrupt Enable
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
CFIE3
1
CFIE
30
CFIE
29
CFIE
28
CFIE
27
CFIE
26
CFIE
25
CFIE
24
CFIE
23
CFIE
22
CFIE
21
CFIE
20
CFIE
19
CFIE
18
CFIE
17
CFIE
16
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
CFIE1
5
CFIE
14
CFIE
13
CFIE
12
CFIE
11
CFIE
10
CFIE
9
CFIE
8
CFIE
7
CFIE
6
CFIE
5
CFIE
4
CFIE
3
CFIE
2
CFIE
1
CFIE
0
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
21  Controller Area Network interface (CAN)
Reference manual
4075
v1.1
2025-06-26


Field
Bits
Type
Description
CFIEz (z=0-31)
z
rw
Cancellation Finished Interrupt Enable Tx Buffer z - CFIE
0B Cancellation finished interrupt disabled
1B Cancellation finished interrupt enabled
21.7.105
Node i Tx Event FIFO Configuration
Ni_TXEFC (i=0-3)
Offset address:
002F0H+i*400H
Node i Tx Event FIFO Configuration
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
EFWM
0
EFS
r
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
EFSA
0
rw
r
Field
Bits
Type
Description
EFSA
15:2
rw
Event FIFO Start Address
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
Start address of Tx Event FIFO in Message RAM (32-bit word address).
EFS
21:16
rw
Event FIFO Size
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
The Tx Event FIFO elements are indexed from 0 to EFS - 1
00H Tx Event FIFO disabled
01H 1 Tx Event FIFO elements
…
20H 32 Tx Event FIFO elements
others, 32 Tx Event FIFO elements
EFWM
29:24
rw
Event FIFO Watermark
This bit-field is CCE and INIT protected. Writes will only have effect, if
both bits are set.
01H Level 1 for Tx Event FIFO watermark interrupt (Ni_IR.TEFW)
…
20H Level 32 for Tx Event FIFO watermark interrupt (Ni_IR.TEFW)
others, Watermark interrupt disabled
0
1:0,
23:22,
31:30
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4076
v1.1
2025-06-26


21.7.106
Node i Tx Event FIFO Status
Ni_TXEFS (i=0-3)
Offset address:
002F4H+i*400H
Node i Tx Event FIFO Status
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
TEFL
EFF
0
EFPI
r
rh
rh
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
EFGI
0
EFFL
r
rh
r
rh
Field
Bits
Type
Description
EFFL
5:0
rh
Event FIFO Fill Level
Number of elements stored in Tx Event FIFO, range 0 to 32.
EFGI
12:8
rh
Event FIFO Get Index
Tx Event FIFO read index pointer, range 0 to 31.
EFPI
20:16
rh
Event FIFO Put Index
Tx Event FIFO write index pointer, range 0 to 31.
EFF
24
rh
Event FIFO Full
0B Tx Event FIFO not full
1B Tx Event FIFO full
TEFL
25
rh
Tx Event FIFO Element Lost
This bit is a copy of interrupt flag Ni_IR.TEFL. When Ni_IR.TEFL is reset,
this bit is also reset.
0B No Tx Event FIFO element lost
1B Tx Event FIFO element lost, also set after write attempt to Tx Event
FIFO of size zero.
0
7:6,
15:13,
23:21,
31:26
r
Reserved
Read as 0; should be written with 0.
21.7.107
Node i Tx Event FIFO Acknowledge
Ni_TXEFA (i=0-3)
Offset address:
002F8H+i*400H
Node i Tx Event FIFO Acknowledge
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
EFAI
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4077
v1.1
2025-06-26


Field
Bits
Type
Description
EFAI
4:0
rw
Event FIFO Acknowledge Index
After the Host has read an element or a sequence of elements from the
Tx Event FIFO it has to write the index of the last element read from Tx
Event FIFO to EFAI. This will set the Tx Event FIFO Get Index
Ni_TXEFS.EFGI to EFAI + 1 and update the FIFO 0 Fill Level
Ni_TXEFS.EFFL.
0
31:5
r
Reserved
Read as 0; should be written with 0.
21.7.108
Node i TSU Core Release Register
Ni_TSU_CREL (i=0-3)
Offset address:
00360H+i*400H
Node i TSU Core Release Register
Kernel Reset value:
1008 1114H
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
Time Stamp Day
MON
15:8
r
Time Stamp Month
YEAR
19:16
r
Time Stamp Year
SUBSTEP
23:20
r
Sub-step of Core Release
One digit, BCD-coded.
STEP
27:24
r
Step of Core Release
One digit, BCD-coded.
REL
31:28
r
Core Release
One digit, BCD-coded.
Table 1023
Example for Coding of Revisions
Release
Step
SubStep
Year
Month
Day
Name
0
1
0
2010
03
10
Revision 0.1.0, Date 2010/03/10
21.7.109
Node i Timestamp Configuration (i=0)
Ni_TSU_TSCFG (i=0)
Offset address:
00364H+i*400H
Node i Timestamp Configuration
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4078
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
TBPRE
0
SCP
0
TSUE
rw
r
rw
r
rw
Field
Bits
Type
Description
TSUE
0
rw
Timestamp Unit Enable
Timestamp Unit Enable
0B TSU disabled
1B TSU enabled
SCP
2
rw
Select Capturing Position
Capture timestamp at EOF or SOF
0B Capture Timestamp at EOF
1B Capture Timestamp at SOF
TBPRE
15:8
rw
Timebase Prescaler
Timebase Prescaler
0x00 to 0xFF
The value by which the oscillator frequency is divided for generating
the timebase counter clock. Valid values for the Timebase Prescaler are
0 to 255. The actual interpretation by hardware of this value is such that
one more than the value programmed is used. Affects only TSU internal
timebase.
0
1,
7:3,
31:16
r
Reserved
Read as 0; shall be written with 0.
21.7.110
Node i Timestamp Configuration (i=1-3)
Ni_TSU_TSCFG (i=1-3)
Offset address:
00364H+i*400H
Node i Timestamp Configuration
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
TBPRE
0
SCP
TBCS TSUE
rw
r
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4079
v1.1
2025-06-26


Field
Bits
Type
Description
TSUE
0
rw
Timestamp Unit Enable
Timestamp Unit Enable
0B TSU disabled
1B TSU enabled
TBCS
1
rw
Timebase Counter Select
Timebase Counter Select
0B Timestamp value captured from internal timebase counter,
Ni_TSU_ATB.TB[31:0] is the internal timebase counter
1B Timestamp value captured from external input,
Ni_TSU_ATB.TB[31:0] is TSU0's output signal.Note: This only
applicable for Ni_TSU_TSCFG with Ni: 1-3,while N0 does not have
an external input
SCP
2
rw
Select Capturing Position
Capture timestamp at EOF or SOF
0B Capture Timestamp at EOF
1B Capture Timestamp at SOF
TBPRE
15:8
rw
Timebase Prescaler
Timebase Prescaler
0x00 to 0xFF
The value by which the oscillator frequency is divided for generating
the timebase counter clock. Valid values for the Timebase Prescaler are
0 to 255. The actual interpretation by hardware of this value is such that
one more than the value programmed is used. Affects only TSU internal
timebase.
0
7:3,
31:16
r
Reserved
Read as 0; should be written with 0.
21.7.111
Node i Timestamp Status 1
Ni_TSU_TSS1 (i=0-3)
Offset address:
00368H+i*400H
Node i Timestamp Status 1
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
TSL1
5
TSL1
4
TSL1
3
TSL1
2
TSL1
1
TSL1
0
TSL9 TSL8 TSL7 TSL6 TSL5 TSL4 TSL3 TSL2 TSL1 TSL0
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
TSN1
5
TSN1
4
TSN1
3
TSN1
2
TSN1
1
TSN1
0
TSN9 TSN8 TSN7 TSN6 TSN5 TSN4 TSN3 TSN2 TSN1 TSN0
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
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4080
v1.1
2025-06-26


Field
Bits
Type
Description
TSNz (z=0-15)
z
rh
Timestamp New z - TSN
Timestamp New
Each Timestamp register (TS0-TS15) is assigned one bit. The bits are set
when a timestamp was stored in the related Timestamp register.
Reading a Timestamp register resetes the related bit, if
Ni_PORTCTRL.DELE is set.
TSLz (z=0-15)
z+16
rh
Timestamp Lost z - TSL
Timestamp Lost
Each Timestamp register (TS0-TS15) is assigned one bit. The bits are set
when a timestamp was overwritten before it was read. Reading a
Timestamp register resetes the related bit, if Ni_PORTCTRL.DELE is set.
21.7.112
Node i Timestamp Status 2
Ni_TSU_TSS2 (i=0-3)
Offset address:
0036CH+i*400H
Node i Timestamp Status 2
Kernel Reset value:
0000 E000H
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
ITBG
NTSG
0
TSP
r
r
r
rh
Field
Bits
Type
Description
TSP
3:0
rh
Timestamp Counter TSP
Timestamp Pointer
The Timestamp Pointer is incremented by one each time a timestamp is
captured. From its maximum value (3, 7, or 15 depending on
configuration) it is incremented to 0.
NTSG
13:12
r
Number of Timestamps Generic NTSG
Number of Timestamps
Read as 0x10, meaning is 16 timestamp registers
ITBG
15:14
r
Internal Timebase and SOF select Generic ITBG
Constant value of generic parameter
00B no SOF option, no internal timebase
01B no SOF option, internal timebase (default)
10B SOF option, no internal timebase
11B SOF option, internal timebase
0
11:4,
31:16
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4081
v1.1
2025-06-26


21.7.113
Node i Timestamp m
Ni_TSU_TSm (i=0-3;m=0-15)
Offset address:
00370H+i*400H+m*4
Node i Timestamp m
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
TS
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
TS
rh
Field
Bits
Type
Description
TS
31:0
rh
Reference Timestamp generated by TSU
21.7.114
Node i Actual Timebase
Actual Timebase
Ni_TSU_ATB (i=0-3)
Offset address:
003B0H+i*400H
Node i Actual Timebase
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
TB
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
TB
rwh
Field
Bits
Type
Description
TB
31:0
rwh
Timebase for timestamp generation
Timebase for timestamp generation.
21.7.115
Standard Message ID Filter Element
21.7.115.1
Standard Message 0
STDMSGk_S0 (k=0-127)
Offset address:
00000H + k*4
Standard Message 0
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4082
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
SFT
SFEC
SFID1
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
SSYN
C
0
SFID2
rwh
r
rw
Field
Bits
Type
Description
SFID2
10:0
rw
Standard Filter ID 2
This bit-field has a different meaning depending on the configuration of
SFEC:
1) SFEC = “001”…”110”  Second ID of standard ID filter element
2) SFEC = “111” Filter for Rx Buffers or for debug messages
SFID2[5:0]
defines the offset to the Rx Buffer Start Address Ni_RXBC.RBSA for
storage of a matching message.
SFID2[8:6]
is used to control the filter event pins. A one at the respective bit
position enables generation of a pulse at the related filter event pin
with the duration of one host clock period in case the filter matches.
SFID2[10:9]
decides whether the received message is stored into an Rx Buffer or
treated as message A, B, or C of the debug message sequence.
000H Store message into an Rx Buffer
…
1FFH Store message into an Rx Buffer
200H Debug Message A
…
3FFH Debug Message A
400H Debug Message B
…
5FFH Debug Message B
600H Debug Message C
…
7FFH Debug Message C
SSYNC
15
rwh
Standard Sync Message
Only evaluated when Ni_CCCR.UTSU = '1'.
0B Timestamping for the matching Sync message disabled.
1B Timestamping for the matching Sync message enabled.
SFID1
26:16
rw
Standard Filter ID 1
First ID of standard ID filter element.
When filtering for Rx Buffers or for debug messages this field defines the
ID of a standard message to be stored. The received identifiers must
match exactly, no masking mechanism is used.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4083
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
SFEC
29:27
rw
Standard Filter Element Configuration
All enabled filter elements are used for acceptance filtering of standard
frames. Acceptance filtering stops at the first matching enabled filter
element or when the end of the filter list is reached. If SFEC = “100”,
“101” or “110”, a match sets interrupt flag Ni_IR.HPM and, if enabled,
an interrupt is generated. In this case register Ni_HPMS is updated with
the status of the priority match.
000B Disable filter element
001B Store in Rx FIFO 0 if filter matches
010B Store in Rx FIFO 1 if filter matches
011B Reject ID if filter matches
100B Set priority if filter matches
101B Set priority and store in FIFO 0 if filter matches
110B Set priority and store in FIFO 1 if filter matches
111B Store into Rx Buffer or as debug message, configuration of
SFT[1:0] ignored
SFT
31:30
rw
Standard Filter Type
Note:
With SFT = “11” the filter element is disabled and the
acceptance filtering continues (same behavior as with SFEC
= “000”)
00B Range filter from SF1ID to SF2ID (SF2ID ≥ SF1ID)
01B Dual ID filter for SF1ID or SF2ID
10B Classic filter: SF1ID = filter, SF2ID = mask
11B Filter element disabled
0
14:11
r
Reserved
Read as 0; should be written with 0.
21.7.116
Extended Message ID Filter Element
21.7.116.1
Filter Element 0
See Message layout.
EXTMSGk_F0 (k=0-63)
Offset address:
00000H + k*8
Filter Element 0
RAMInit value:
XXXX XXXXH
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
EFEC
EFID1
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
EFID1
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4084
v1.1
2025-06-26


Field
Bits
Type
Description
EFID1
28:0
rw
Extended Filter ID 1
First ID of extended ID filter element.
When filtering for Rx Buffers or for debug messages this field defines the
ID of an extended message to be stored. The received identifiers must
match exactly, only XIDAMi masking mechanism is used.
EFEC
31:29
rw
Extended Filter Element Configuration
All enabled filter elements are used for acceptance filtering of extended
frames. Acceptance filtering stops at the first matching enabled filter
element or when the end of the filter list is reached. If EFEC = “100”,
“101” or “110”, a match sets interrupt flag Ni_IR.HPM and, if enabled,
an interrupt is generated. In this case register Ni_HPMS is updated with
the status of the priority match.
000B Disable filter element
001B Store in Rx FIFO 0 if filter matches
010B Store in Rx FIFO 1 if filter matches
011B Reject ID if filter matches
100B Set priority if filter matches
101B Set priority and store in FIFO 0 if filter matches
110B Set priority and store in FIFO 1 if filter matches
111B Store into Rx Buffer or as debug message, configuration of
EFT[1:0] ignored
Related information
Message RAM on page 3929
21.7.116.2
Filter Element 1
See Message layout.
EXTMSGk_F1 (k=0-63)
Offset address:
00004H+k*8
Filter Element 1
RAMInit value:
XXXX XXXXH
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
EFT
ESYN
C
EFID2
rw
rwh
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
EFID2
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4085
v1.1
2025-06-26


Field
Bits
Type
Description
EFID2
28:0
rw
Extended Filter ID 2
This bit-field has a different meaning depending on the configuration of
EFEC:
1) EFEC = “001”…”110” Second ID of extended ID filter element
2) EFEC = “111” Filter for Rx Buffers or for debug messages
EFID2[5:0]
defines the offset to the Rx Buffer Start Address Ni_RXBC.RBSA for
storage of a matching message.
EFID2[8:6]
is used to control the filter event. A one at the respective bit position
enables generation of a pulse at the related filter event pin with the
duration of one host clock period in case the filter matches.
EFID2[10:9]
decides whether the received message is stored into an Rx Buffer or
treated as message A, B, or C of the debug message sequence.
00000000H Store message into an Rx Buffer
…
000001FFH Store message into an Rx Buffer
00000200H Debug Message A
…
000003FFH Debug Message A
00000400H Debug Message B
…
000005FFH Debug Message B
00000600H Debug Message C
…
000007FFH Debug Message C
ESYNC
29
rwh
Extended Sync Message
Only evaluated when Ni_CCCR.UTSU = '1'.
0B Timestamping for the matching Sync message disabled.
1B Timestamping for the matching Sync message enabled.
EFT
31:30
rw
Extended Filter Type
00B Range filter from EF1ID to EF2ID (EF2ID ≥ EF1ID)
01B Dual ID filter for EF1ID or EF2ID
10B Classic filter: EF1ID = filter, EF2ID = mask
11B Range filter from EF1ID to EF2ID (EF2ID ≥ EF1ID), XIDAM mask not
applied
Related information
Message RAM on page 3929
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4086
v1.1
2025-06-26


21.7.117
Rx Buffer and FIFO Element
21.7.117.1
Register 0
See Message layout.
RXMSGk_R0 (k=0-63)
Offset address:
00000H + k*48H
Register 0
RAMInit value:
XXXX XXXXH
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
ESI
XTD
RTR
ID
rwh
rwh
rwh
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
ID
rwh
Field
Bits
Type
Description
ID
28:0
rwh
Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier is stored into ID[28:18].
RTR
29
rwh
Remote Transmission Request
Signals to the Host whether the received frame is a data frame or a
remote frame.
Note:
There are no remote frames in CAN FD format. In case a
CAN FD frame was received (FDF = 1’), bit RTR reflects the
state of the reserved bit r1.
0B Received frame is a data frame
1B Received frame is a remote frame
XTD
30
rwh
Extended Identifier
Signals to the Host whether the received frame has a standard or
extended identifier.
0B 11-bit standard identifier
1B 29-bit extended identifier
ESI
31
rwh
Error State Indicator
0B Transmitting node is error active
1B Transmitting node is error passive
Related information
Message RAM on page 3929
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4087
v1.1
2025-06-26


21.7.117.2
Register 1 A
See Message layout.
When no TSU is used (Ni_CCCR.UTSU = 0), RXMSGk_R1A.RXTS[15:0] holds the 16-bit timestamp generated by
the M_CAN's internal timestamping logic
RXMSGk_R1A (k=0-63)
Offset address:
00004H+k*48H
Register 1 A
RAMInit value:
XXXX XXXXH
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
ANMF
FIDX
0
FDF
BRS
DLC
rwh
rwh
r
rwh
rwh
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
RXTS
rwh
Field
Bits
Type
Description
RXTS
15:0
rwh
Rx Timestamp
Timestamp Counter value captured on start of frame reception.
Resolution depending on configuration of the Timestamp Counter
Prescaler Ni_TSCC.TCP.
DLC
19:16
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rwh
Bit Rate Switch
0B Frame received without bit rate switching
1B Frame received with bit rate switching
FDF
21
rwh
Frame Data Format
0B Standard frame format
1B CAN FD frame format (new DLC-coding and CRC)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4088
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FIDX
30:24
rwh
Filter Index
00H Index of matching Rx acceptance filter element (invalid if ANMF =
‘1’).
Range is 0 to SIDFC.LSS - 1 resp. XIDFC.LSE - 1.
…
7FH Index of matching Rx acceptance filter element (invalid if ANMF =
‘1’).
Range is 0 to SIDFC.LSS - 1 resp. XIDFC.LSE - 1.
ANMF
31
rwh
Accepted Non-matching Frame
Acceptance of non-matching frames may be enabled via GFC.ANFS and
GFC.ANFE.
0B Received frame matching filter index FIDX
1B Received frame did not match any Rx filter element
0
23:22
r
Reserved
Read as 0; should be written with 0.
Related information
Message RAM on page 3929
21.7.117.3
Register 1 B
See Message layout.
When a TSU is used (CCCR.UTSU = 1) and when bit SSYNC/ESYNC of the matching filter element is set, R1B.TSC =
1 and R1B.RXTSP[3:0] holds the number of the TSU's Timestamp register which holds the 32-bit timestamp
captured by the TSU. Else R1B.TSC = 0 and R1B.RXTSP[3:0] is not valid
RXMSGk_R1B (k=0-63)
Offset address:
00004H+k*48H
Register 1 B
RAMInit value:
XXXX XXXXH
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
ANMF
FIDX
0
FDF
BRS
DLC
rwh
rwh
r
rwh
rwh
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
TSC
RXTSP
r
rwh
rwh
Field
Bits
Type
Description
RXTSP
3:0
rwh
Rx Timestamp Pointer
Number of TSU Time Stamp register (TS0..15) where the related
timestamp is stored.
TSC
4
rwh
Timestamp Captured
0B No timestamp captured
1B Timestamp captured and stored in TSU Timestamp register
referenced by R1B.RXTSP
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4089
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DLC
19:16
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rwh
Bit Rate Switch
0B Frame received without bit rate switching
1B Frame received with bit rate switching
FDF
21
rwh
Frame Data Format
0B Standard frame format
1B CAN FD frame format (new DLC-coding and CRC)
FIDX
30:24
rwh
Filter Index
00H Index of matching Rx acceptance filter element (invalid if ANMF =
‘1’).
Range is 0 to Ni_SIDFC.LSS - 1 resp. Ni_XIDFC.LSE - 1.
…
7FH Index of matching Rx acceptance filter element (invalid if ANMF =
‘1’).
Range is 0 to Ni_SIDFC.LSS - 1 resp. Ni_XIDFC.LSE - 1.
ANMF
31
rwh
Accepted Non-matching Frame
Acceptance of non-matching frames may be enabled via Ni_GFC.ANFS
and Ni_GFC.ANFE.
0B Received frame matching filter index FIDX
1B Received frame did not match any Rx filter element
0
15:5,
23:22
r
Reserved
Read as 0; should be written with 0.
Related information
Message RAM on page 3929
21.7.117.4
Data Byte m
RXMSGk_DBm (k=0-63;m=0-63)
Offset address:
00008H+k*48H+m
Data Byte m
RAMInit value:
XXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4090
v1.1
2025-06-26


7
6
5
4
3
2
1
0
DB
rwh
Field
Bits
Type
Description
DB
7:0
rwh
Data Byte m
21.7.118
Tx Event FIFO Element
21.7.118.1
Event 0
See Message layout.
TXEVENTk_E0 (k=0-31)
Offset address:
00000H + k*8
Event 0
RAMInit value:
XXXX XXXXH
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
ESI
XTD
RTR
ID
rwh
rwh
rwh
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
ID
rwh
Field
Bits
Type
Description
ID
28:0
rwh
Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier is stored into ID[28:18].
RTR
29
rwh
Remote Transmission Request
0B Data frame transmitted
1B Remote frame transmitted
XTD
30
rwh
Extended Identifier
0B 11-bit standard identifier
1B 29-bit extended identifier
ESI
31
rwh
Error State Indicator
0B Transmitting node is error active
1B Transmitting node is error passive
Related information
Message RAM on page 3929
21.7.118.2
Event 1A
See Message layout.
TXEVENTk_E1A (k=0-31)
Offset address:
00004H+k*8
Event 1A
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4091
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
MM
ET
FDF
BRS
DLC
rwh
rwh
rwh
rwh
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
TXTS
rwh
Field
Bits
Type
Description
TXTS
15:0
rwh
Tx Timestamp
Timestamp Counter value captured on start of frame transmission.
Resolution depending on configuration of the Timestamp Counter
Prescaler Ni_TSCC.TCP.
DLC
19:16
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rwh
Bit Rate Switch
0B Frame transmitted without bit rate switching
1B Frame transmitted with bit rate switching
FDF
21
rwh
FD Format
0B Standard frame format
1B CAN FD frame format (new DLC-coding and CRC)
ET
23:22
rwh
Event Type
00B Reserved
01B Tx event
10B Transmission in spite of cancellation (always set for
transmissions in DAR mode)
11B Reserved
MM
31:24
rwh
Message Marker
Copied from Tx Buffer into Tx Event FIFO element for identification of Tx
message status.
Related information
Message RAM on page 3929
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4092
v1.1
2025-06-26


21.7.118.3
Event 1B
See Message layout.
TXEVENTk_E1B (k=0-31)
Offset address:
00004H+k*8
Event 1B
RAMInit value:
XXXX XXXXH
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
MM0
ET
FDF
BRS
DLC
rwh
rwh
rwh
rwh
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
MM1
0
TSC
TXTSP
rw
r
rwh
rwh
Field
Bits
Type
Description
TXTSP
3:0
rwh
Tx Timestamp Pointer
Number of TSU Time Stamp register (TS0..15) where the related
timestamp is stored.
TSC
4
rwh
Timestamp Captured
0B 0 No timestamp captured
1B 1Timestamp captured and stored in TSU Timestamp register
referenced by TXTSP
MM1
15:8
rw
Message Marker
High byte of Wide Message Marker, written by CPU during Tx Buffer
configuration. Copied into Tx Event FIFO element for identification of Tx
message status.
DLC
19:16
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rwh
Bit Rate Switch
0B Frame transmitted without bit rate switching
1B Frame transmitted with bit rate switching
FDF
21
rwh
FD Format
0B Standard frame format
1B CAN FD frame format (new DLC-coding and CRC)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4093
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ET
23:22
rwh
Event Type
00B Reserved
01B Tx event
10B Transmission in spite of cancellation (always set for
transmissions in DAR mode)
11B Reserved
MM0
31:24
rwh
Message Marker
Copied from Tx Buffer into Tx Event FIFO element for identification of Tx
message status.
0
7:5
r
Reserved
Read as 0; should be written with 0.
Related information
Message RAM on page 3929
21.7.119
Tx Buffer Element
21.7.119.1
Transmit Buffer 0
See Message layout.
TXMSGk_T0 (k=0-31)
Offset address:
00000H + k*48H
Transmit Buffer 0
RAMInit value:
XXXX XXXXH
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
ESI
XTD
RTR
ID
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
ID
rw
Field
Bits
Type
Description
ID
28:0
rw
Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier has to be written to ID[28:18].
RTR
29
rw
Remote Transmission Request
Note:
When RTR = 1, the M_CAN transmits a remote frame
according to ISO11898-1, even if Ni_CCCR.FDOE enables the
transmission in CAN FD format.
0B Transmit data frame
1B Transmit remote frame
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4094
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
XTD
30
rw
Extended Identifier
0B 11-bit standard identifier
1B 29-bit extended identifier
ESI
31
rw
Error State Indicator
Note:
The ESI bit of the transmit buffer is OR’ed with the error
passive flag to decide the value of the ESI bit in the
transmitted FD frame. As required by the CAN FD protocol
specification, an error active node may optionally transmit
the ESI bit recessive, but an error passive node will always
transmit the ESI bit recessive.
0B ESI bit in CAN FD format depends only on error passive flag
1B ESI bit in CAN FD format transmitted recessive
Related information
Message RAM on page 3929
21.7.119.2
Transmit Buffer 1
See Message layout.
TXMSGk_T1 (k=0-31)
Offset address:
00004H+k*48H
Transmit Buffer 1
RAMInit value:
XXXX XXXXH
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
MM0
EFC
TSCE
FDF
BRS
DLC
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
MM1
0
rw
r
Field
Bits
Type
Description
MM1
15:8
rw
Message Marker
High byte of Wide Message Marker, written by CPU during Tx Buffer
configuration. Copied into Tx Event FIFO element for identification of Tx
message status. Available only when Ni_CCCR.WMM = '1' or when
Ni_CCCR.UTSU = '1'.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4095
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DLC
19:16
rw
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rw
Bit Rate Switching
Note:
Bits ESI, FDF, and BRS are only evaluated when CAN FD
operation is enabled Ni_CCCR.FDOE = 1’. Bit BRS is only
evaluated when in addition Ni_CCCR.BRSE = ‘1’.
0B CAN FD frames transmitted without bit rate switching
1B CAN FD frames transmitted with bit rate switching
FDF
21
rw
FD Format
0B Frame transmitted in Classical CAN format
1B Frame transmitted in CAN FD format
TSCE
22
rw
Time Stamp Captuer Enable for TSU
Only available when Ni_CCCR.UTSU = '1'. When this bit is set and the
message is transmitted, the transmission of a Sync message is signaled
to the Timestamping Unit (TSU) connected to the M_CAN which
captures the timestamp.
0B Time Stamp Capture disabled
1B Time Stamp Capture enabled
EFC
23
rw
Event FIFO Control
0B Do not store Tx events
1B Store Tx events
MM0
31:24
rw
Message Marker
Written by CPU during Tx Buffer configuration. Copied into Tx Event
FIFO element for identification of Tx message status.
0
7:0
r
Reserved
Read as 0; should be written with 0.
Related information
Message RAM on page 3929
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4096
v1.1
2025-06-26


21.7.119.3
Data Byte m
TXMSGk_DBm (k=0-31;m=0-63)
Offset address:
00008H+k*48H+m
Data Byte m
RAMInit value:
XXH
7
6
5
4
3
2
1
0
DB
rw
Field
Bits
Type
Description
DB
7:0
rw
Data Byte m
21.7.120
CRE configuration table
21.7.120.1
STD ID Routing table parameters
This register defines the Start Address and size of the Standard ID Routing Table
SA defines the start address of the Standard ID Routing Table (32 bit Word Address).
SIZE defines the number of Routing Rules contained in the Standard ID Routing Table.
0 - The Routing Table is disabled
1 till 128 - Number of Routing Rules
others - Reserved
Note: Ensure the SA does not overlap with the Host Buffer contents. Refer CRE RAM structure
CRE_STD_RT_PARAM
Offset address:
00000H
STD ID Routing table parameters
RAMInit value:
XXXX XXXXH
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
SIZE
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
SA
r
rw
Field
Bits
Type
Description
SA
13:0
rw
Start address of the table
SIZE
23:16
rw
Size of the table
0
15:14,
31:24
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4097
v1.1
2025-06-26


21.7.120.2
XTD ID Routing table parameters
This register defines the Start Address and size of the Extended ID Routing Table
SA defines the start address of the Extended ID Routing Table (32 bit Word Address).
SIZE defines the number of Routing Rules contained in the Extended ID Routing Table.
0 - The Routing Table is disabled
1 till 64 - Number of Routing Rules
others - Reserved
Note: Ensure the SA does not overlap with the Host Buffer contents. Refer CRE RAM structure
CRE_XTD_RT_PARAM
Offset address:
00004H
XTD ID Routing table parameters
RAMInit value:
XXXX XXXXH
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
SIZE
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
SA
r
rw
Field
Bits
Type
Description
SA
13:0
rw
Start address of the table
SIZE
23:16
rw
Size of the table
0
15:14,
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.120.3
STD ID Frame rate measure table parameters
This register defines the Start Address and size of the Standard ID Frame rate measure Table
SA defines the start address of the Standard ID Frame rate measure Table (32 bit Word Address).
SIZE defines the number of Frame rate measures contained in the Standard ID Frame rate measure Table.
0 - The Frame rate measure Table is disabled
1 till 128 - Number of Frame rate measures
others - Reserved
CRE_STD_FRT_PARAM
Offset address:
00008H
STD ID Frame rate measure table parameters
RAMInit value:
XXXX XXXXH
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
SIZE
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
SA
r
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4098
v1.1
2025-06-26


Field
Bits
Type
Description
SA
13:0
rw
Start address of the table
SIZE
23:16
rw
Size of the table
0
15:14,
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.120.4
XTD ID Frame rate measure table parameters
This register defines the Start Address and size of the Extended ID Frame rate measure Table
SA defines the start address of the Extended ID Frame rate measure Table (32 bit Word Address).
SIZE defines the number of Frame rate measures contained in the Extended ID Frame rate measure Table.
0 - The Frame rate measure Table is disabled
1 till 64 - Number of Frame rate measures
others - Reserved
CRE_XTD_FRT_PARAM
Offset address:
0000CH
XTD ID Frame rate measure table parameters
RAMInit value:
XXXX XXXXH
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
SIZE
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
SA
r
rw
Field
Bits
Type
Description
SA
13:0
rw
Start address of the table
SIZE
23:16
rw
Size of the table
0
15:14,
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.120.5
STD ID Timestamp database parameters
This register defines the Start Address and size of the Standard ID Timestamp database
SA defines the start address of the Standard ID Timestamp database (32 bit Word Address).
SIZE defines the number of timestamps contained in the Standard ID Timestamp database.
0 - The Timestamp database is disabled
1 till 128 - Number of timestamps
others - Reserved
CRE_STD_TSD_PARAM
Offset address:
00010H
STD ID Timestamp database parameters
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4099
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
SIZE
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
SA
r
rw
Field
Bits
Type
Description
SA
13:0
rw
Start address of the table
SIZE
23:16
rw
Size of the table
0
15:14,
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.120.6
XTD ID Timestamp database parameters
This register defines the Start Address and size of the Extended ID Timestamp database
SA defines the start address of the Extended ID Timestamp database (32 bit Word Address).
SIZE defines the number of timestamps contained in the Extended ID Timestamp database.
0 - The Timestamp database is disabled
1 till 64 - Number of timestamps
others - Reserved
CRE_XTD_TSD_PARAM
Offset address:
00014H
XTD ID Timestamp database parameters
RAMInit value:
XXXX XXXXH
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
SIZE
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
SA
r
rw
Field
Bits
Type
Description
SA
13:0
rw
Start address of the table
SIZE
23:16
rw
Size of the table
0
15:14,
31:24
r
Reserved
Read as 0; should be written with 0.
21.7.120.7
CRE abort sequence register
CRE_ABORT_SEQ
Offset address:
00018H
CRE abort sequence register
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4100
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
CTH
BUF0
CRH
BUF1
CRH
BUF0
r
rwh
rwh
rwh
Field
Bits
Type
Description
CRHBUF0
0
rwh
Cancel Rx Host Buffer 0 sequence
Writing 1 to this bit cancels the ongoing Rx Host Buffer 0 sequence.
Writing 0 has no effect. The software shall not write to this register
CRHBUF1
1
rwh
Cancel Rx Host Buffer 1 sequence
Writing 1 to this bit cancels the ongoing Rx Host Buffer 1 sequence.
Writing 0 has no effect
CTHBUF0
2
rwh
Cancel Tx Host Buffer 0 sequence
Writing 1 to this bit cancels the ongoing Tx Host Buffer 0 sequence.
Writing 0 has no effect
0
31:3
r
Reserved
21.7.121
CRE Receive Host Buffers
21.7.121.1
Uni-cast Routing Header k
RHBUFk_UCRH (k=0-1)
Offset address:
00020H+k*60H
Uni-cast Routing Header k
RAMInit value:
XXXX XXXXH
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
DID
SID
Mode
r
rw
rw
rw
Field
Bits
Type
Description
Mode
1:0
rw
Defines type of routing
It defines the type of the routing rule
other - Reserved, considered as Uni-cast Rule
00B Uni-cast Rule
01B Multi-cast Rule
10B PDU Routing Rule
11B Reserved
Considered as uni-cast Rule
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4101
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
SID
7:2
rw
ID of Source node receiving CAN Frame
This bit-field indicates the Source node at which the CAN frame is
received. The Source nodes are referenced using a unique ID as given in
the Routing ID overview table.
DID
13:8
rw
Destination of Received CAN Frame
This bit-field indicates the Destination to which the received CAN frame
has to be transferred to. The Destinations are referenced using a unique
ID as given in the Routing ID overview table.
0
31:14
r
Reserved
Read as 0; should be written with 0
21.7.121.2
Multi-cast Routing Header k
RHBUFk_MCRH (k=0-1)
Offset address:
00020H+k*60H
Multi-cast Routing Header k
RAMInit value:
XXXX XXXXH
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
DID3
DID2
DID1
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
DID1
DID0
SID
Mode
rw
rw
rw
rw
Field
Bits
Type
Description
Mode
1:0
rw
Defines type of routing
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
other - Reserved, considered as Uni-cast Rule
SID
7:2
rw
ID of Source node receiving CAN Frame
This bit-field indicates the Source node at which the CAN frame is
received. The Source node are referenced using a unique ID as given in
the Routing ID overview table.
DID0
13:8
rw
1st Destination of Recieved CAN Frame
This bit-field indicates the 1st Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID1
19:14
rw
2nd Destination of Recieved CAN Frame
This bit-field indicates the 2nd Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4102
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DID2
25:20
rw
3rd Destination of Recieved CAN Frame
This bit-field indicates the 3rd Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID3
31:26
rw
4th Destination of Recieved CAN Frame
This bit-field indicates the 4th Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
21.7.121.3
Timing Header k Intrusion Detection Information
RHBUFk_THEAD_INTRD (k=0-1)
Offset address:
00024H+k*60H
Timing Header k Intrusion Detection Information
RAMInit value:
XXXX XXXXH
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
TSL
IAMS
TAT
TSCL
EN
TSC
IAM
rwh
rwh
rwh
rwh
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
IAM
rwh
Field
Bits
Type
Description
IAM
27:0
rwh
Inter Arrival Measure
Inter arrival mesaure is the difference between the latest timestamp
RXTS of the received frame and the previous timestamp obtained from
the timestamp database STSDk_RTS.TS or XTSDk_RTS.TS. The IAM is
valid only when it is non-zero. IAM is zero in case of unavailabilty of
reference timestamp RTS
TSC
28
rwh
Timestamp Captured
External timestamp from TSU.
0 : No timestamp captured or timestamp invalid
1: Valid timestamp captured and stored in RHBUFk_THEAD_RXTS
TSCLEN
29
rwh
Timestamp Captured Length
Length of the timestamp stored in RHBUFk_THEAD_RXTS
0 : 16-bit timestamp
1 : 32-bit timestamp (from TSU)
IAMSTAT
30
rwh
Inter Arrival Measure Status
Availablity of Inter Arrival Measure for Intrusion detection
0 : No reference timestamp (RTS) avaialble to calculate IAM (in case of
first frame received, overrun, no entry in the RTS DB).
1 : RTS available to calculate IAM
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4103
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TSL
31
rwh
Timestamp lost
Timestamp register in the TSU was overwritten before it was read. The
IAM is calculated using the latest timestamp fetched.
0 : No timestamp lost
1: Timestamp lost
21.7.121.4
Timing Header k Rx Timestamp
16-bit Internal or 32-bit External Timestamp.
RHBUFk_THEAD_RXTS (k=0-1)
Offset address:
00028H+k*60H
Timing Header k Rx Timestamp
RAMInit value:
XXXX XXXXH
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
RXTS
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
RXTS
rwh
Field
Bits
Type
Description
RXTS
31:0
rwh
External Timestamp
16-bit internal or 32 bit external timestamp. Ni_INTRD.TSCLEN specifies
the length of the timestamp
21.7.121.5
CRE computed CRC
CRC computed by the CRE over the safety critical CAN payload of the CAN frame stored in the RHBUF. The CRC
is computed by the CRE over the CAN frame (R0, R1 and DBm) and the DID of the frame
RHBUFk_CRC (k=0-1)
Offset address:
0002CH+k*60H
CRE computed CRC
RAMInit value:
XXXX XXXXH
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
CRC
rwh
Field
Bits
Type
Description
CRC
15:0
rwh
CRC
CRC computed by CRE
0
31:16
r
Reserved
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4104
v1.1
2025-06-26


21.7.121.6
RHBUF k Register 0
See Message layout.
RHBUFk_R0 (k=0-1)
Offset address:
00030H+k*60H
RHBUF k Register 0
RAMInit value:
XXXX XXXXH
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
ESI
XTD
RTR
ID
rwh
rwh
rwh
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
ID
rwh
Field
Bits
Type
Description
ID
28:0
rwh
Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier is stored into ID[28:18].
RTR
29
rwh
Remote Transmission Request
Signals to the Host whether the received frame is a data frame or a
remote frame.
Note:
There are no remote frames in CAN FD format. In case a
CAN FD frame was received (FDF = 1’), bit RTR reflects the
state of the reserved bit r1.
0B Received frame is a data frame
1B Received frame is a remote frame
XTD
30
rwh
Extended Identifier
Signals to the Host whether the received frame has a standard or
extended identifier.
0B 11-bit standard identifier
1B 29-bit extended identifier
ESI
31
rwh
Error State Indicator
0B Transmitting node is error active
1B Transmitting node is error passive
Related information
Functional description on page 3962
21.7.121.7
Long PDU header 1
RHBUFk_LPDUH1 (k=0-1)
Offset address:
00030H+k*60H
Long PDU header 1
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4105
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
ID
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
ID
rwh
Field
Bits
Type
Description
ID
31:0
rwh
PDU ID
•
Type 3 PDU ID = Source ID + CAN ID (11 bits) + Metadata (16 bits)
•
Type 4 PDU ID = Source ID + CAN ID (27 bits)
•
Type 5 PDU ID = CAN ID (29 bits)
21.7.121.8
RHBUF k Register 1
See Message layout.
RHBUFk_R1 (k=0-1)
Offset address:
00034H+k*60H
RHBUF k Register 1
RAMInit value:
XXXX XXXXH
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
ANMF
FIDX
0
FDF
BRS
DLC
rwh
rwh
r
rwh
rwh
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
RXTS
rwh
Field
Bits
Type
Description
RXTS
15:0
rwh
Rx Timestamp
Timestamp Counter value captured on start of frame reception.
Resolution depends on configuration of the Timestamp Counter
Prescaler Ni_TSCC.TCP.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4106
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DLC
19:16
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rwh
Bit Rate Switch
0B Frame received without bit rate switching
1B Frame received with bit rate switching
FDF
21
rwh
Frame Data Format
0B Standard frame format
1B CAN FD frame format (new DLC-coding and CRC)
FIDX
30:24
rwh
Filter Index
00H Index of matching Rx acceptance filter element (invalid if ANMF =
‘1’).
Range is 0 to Ni_SIDFC.LSS - 1 resp. Ni_XIDFC.LSE - 1.
…
7FH Index of matching Rx acceptance filter element (invalid if ANMF =
‘1’).
Range is 0 to Ni_SIDFC.LSS - 1 resp. Ni_XIDFC.LSE - 1.
ANMF
31
rwh
Accepted Non-matching Frame
Acceptance of non-matching frames may be enabled via Ni_GFC.ANFS
and Ni_GFC.ANFE.
0B Received frame matching filter index FIDX
1B Received frame did not match any Rx filter element
0
23:22
r
Reserved
Read as 0; should be written with 0.
Related information
Functional description on page 3962
21.7.121.9
Long PDU header 0
Type 3, Type 4 and Type 5 long PDU header PDU ID
RHBUFk_LPDUH0 (k=0-1)
Offset address:
00034H+k*60H
Long PDU header 0
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4107
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
DLC
0
rwh
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
TYP
r
rw
Field
Bits
Type
Description
TYP
2:0
rw
PDU Header type
Indicates the Long PDU header type
DLC
31:28
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
0
27:3
r
Reserved
21.7.121.10
Short PDU header
Type 1 and Type 2 short PDU header. All PDU headers consist of a unique PDU ID and the DLC
RHBUFk_SPDUH (k=0-1)
Offset address:
00034H+k*60H
Short PDU header
RAMInit value:
XXXX XXXXH
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
DLC
ID
rwh
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
ID
0
TYP
rwh
r
rw
Field
Bits
Type
Description
TYP
2:0
rw
PDU Header type
Indicates the Short PDU header type
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4108
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ID
27:4
rwh
PDU ID
•
Type 1 PDU ID = Source ID + CAN ID (11 bits)
•
Type 2 PDU ID = Source ID + CAN ID (11 bits) + Metadata (8 bits)
DLC
31:28
rwh
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
0
3
r
Reserved
21.7.121.11
RHBUF k Data Byte m
RHBUFk_RHBUF_DBm (k=0-1;m=0-63)
Offset address:
00038H+k*60H+m
RHBUF k Data Byte m
RAMInit value:
XXH
7
6
5
4
3
2
1
0
DB
rwh
Field
Bits
Type
Description
DB
7:0
rwh
Data Byte m
21.7.122
CRE Transmit Host Buffers
21.7.122.1
Tx Host Buffer CRC
CRC computed over the safety critical CAN payload of the CAN frame stored in the THBUF. This CRC is verified
by the CRE before writing the CAN frame to the Tx FIFO/Queue
THBUFk_CRC (k=0-1)
Offset address:
000E0H+k*50H
Tx Host Buffer CRC
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4109
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
CRC
rwh
Field
Bits
Type
Description
CRC
15:0
rwh
CRC
CRC to be verified by CRE
0
31:16
r
Reserved
21.7.122.2
Transmit Host Buffer Word 0
See Message layout.
THBUFk_T0 (k=0-1)
Offset address:
000E4H+k*50H
Transmit Host Buffer Word 0
RAMInit value:
XXXX XXXXH
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
ESI
XTD
RTR
ID
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
ID
rw
Field
Bits
Type
Description
ID
28:0
rw
Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier has to be written to ID[28:18].
RTR
29
rw
Remote Transmission Request
Note:
When RTR = 1, the M_CAN transmits a remote frame
according to ISO11898-1, even if Ni_CCCR.FDOE enables the
transmission in CAN FD format.
0B Transmit data frame
1B Transmit remote frame
XTD
30
rw
Extended Identifier
0B 11-bit standard identifier
1B 29-bit extended identifier
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4110
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ESI
31
rw
Error State Indicator
Note:
The ESI bit of the transmit buffer is OR’ed with the error
passive flag to decide the value of the ESI bit in the
transmitted FD frame. As required by the CAN FD protocol
specification, an error active node may optionally transmit
the ESI bit recessive, but an error passive node will always
transmit the ESI bit recessive.
0B ESI bit in CAN FD format depends only on error passive flag
1B ESI bit in CAN FD format transmitted recessive
Related information
Functional description on page 3962
21.7.122.3
Transmit Host Buffer Word 1
See Message layout.
THBUFk_T1 (k=0-1)
Offset address:
000E8H+k*50H
Transmit Host Buffer Word 1
RAMInit value:
XXXX XXXXH
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
MM
EFC
TSCE
FDF
BRS
DLC
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
MM1
0
rw
r
Field
Bits
Type
Description
MM1
15:8
rw
Message Marker
High byte of Wide Message Marker, written by CPU during Tx Buffer
configuration. Copied into Tx Event FIFO element for identification of Tx
message status. Available only when Ni_CCCR.WMM = '1' or when
Ni_CCCR.UTSU = '1'.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4111
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DLC
19:16
rw
Data Length Code
0H CAN + CAN FD: received frame has 0 data bytes
…
8H CAN + CAN FD: received frame has 8 data bytes
9H CAN FD: received frame has 12 (9*4-24) data bytes
CAN: received frame has 8 data bytes
…
CH CAN FD: received frame has 24 (12*4-24) data bytes
CAN: received frame has 8 data bytes
DH CAN FD: received frame has 32 (13*16-176) data bytes
CAN: received frame has 8 data bytes
…
FH CAN FD: received frame has 64 (15*16-176) data bytes
CAN: received frame has 8 data bytes
BRS
20
rw
Bit Rate Switching
Note:
Bits ESI, FDF, and BRS are only evaluated when CAN FD
operation is enabled Ni_CCCR.FDOE = 1’. Bit BRS is only
evaluated when in addition Ni_CCCR.BRSE = ‘1’.
0B CAN FD frames transmitted without bit rate switching
1B CAN FD frames transmitted with bit rate switching
FDF
21
rw
FD Format
0B Frame transmitted in Classical CAN format
1B Frame transmitted in CAN FD format
TSCE
22
rw
Timestamp Capture Enable for TSU
Only available when Ni_CCCR.UTSU = '1'. When this bit is set and the
message is transmitted, the transmission of a Sync message is signaled
to the Timestamping Unit (TSU) connected to the M_CAN which
captures the timestamp.
0= Timestamp Capture disabled
1= Timestamp Capture enabled
EFC
23
rw
Event FIFO Control
0B Do not store Tx events
1B Store Tx events
MM
31:24
rw
Message Marker
Written by CPU during Tx Buffer configuration. Copied into Tx Event
FIFO element for identification of Tx message status.
0
7:0
r
Reserved
Read as 0; should be written with 0.
Related information
Functional description on page 3962
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4112
v1.1
2025-06-26


21.7.122.4
Transmit Host Buffer Data Byte m
THBUFk_DBm (k=0-1;m=0-63)
Offset address:
000ECH+k*50H+m
Transmit Host Buffer Data Byte m
RAMInit value:
XXH
7
6
5
4
3
2
1
0
DB
rw
Field
Bits
Type
Description
DB
7:0
rw
Data Byte m
21.7.123
CRE Standard Routing Table
21.7.123.1
Standard routing table Uni-cast Rule
SRTk_UCR (k=0-127)
Offset address:
00168H+k*4
Standard routing table Uni-cast Rule
RAMInit value:
XXXX XXXXH
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
IDXOR
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
DLC
FDF
FDF
M
0
DID
Mode
rw
rw
w
r
rw
rw
Field
Bits
Type
Description
Mode
1:0
rw
Defines the type of the routing
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
2 - PDU Routing Rule
other - Reserved, considered as Uni-cast Rule
DID
7:2
rw
Destination of Received CAN Frame
This bit-field indicates the Destination to which the received CAN frame
has to be transferred to. The Destinations are referenced using a unique
ID as given in the Routing ID overview table.
FDFM
10
w
CAN Frame Format Modifier enable bit
CAN Frame Format Modifier enable bit
0 - the FDF bit is ignored and the received CAN frame format is not
changed
1 - the received CAN frame format is changed either to Classical CAN
frame (FDF=0) or to CAN FD frame format (FDF=1)
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4113
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FDF
11
rw
Indicates if Received Frames is Classical or CAN-FD Frame
This bit-field indicates the Frame Format to which the received CAN
frame has to be modified to. It is valid only when FDFM = 1.
0 - Classical CAN frame format
1 - CAN FD frame format
DLC
15:12
rw
Indicates modification of Data Length Code of received frame
Indicates the modification to the Data Length Code of the received CAN
frame before transferring the frame to its corresponding destination.
DLC = 0, the Destination CAN frame length is same as the received CAN
frame
DLC != 0, Destination CAN frame length as defined by ISO 11898-1
IDXOR
26:16
rw
CAN Frame ID modifier
Modification to the ID of the received CAN frame.
The Destination CAN Frame ID = IDXOR (Xored) RX_CANID
0
9:8,
31:27
r
Reserved
Read as 0; should be written with 0
21.7.123.2
Standard routing table Multi-cast Rule
SRTk_MCR (k=0-127)
Offset address:
00168H+k*4
Standard routing table Multi-cast Rule
RAMInit value:
XXXX XXXXH
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
DID3
0
DID2
0
rw
r
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
DID1
0
DID0
Mode
rw
r
rw
rw
Field
Bits
Type
Description
Mode
1:0
rw
Defines the type of the routing
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
2 - PDU Routing Rule
other - Reserved, considered as Uni-cast Rule
DID0
7:2
rw
1st Destination of Received CAN Frame
This bit-field indicates the 1st Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4114
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DID1
15:10
rw
2nd Destination of Received CAN Frame
This bit-field indicates the 2nd Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID2
23:18
rw
3rd Destination of Recieved CAN Frame
This bit-field indicates the 3rd Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID3
31:26
rw
4th Destination of Recieved CAN Frame
This bit-field indicates the 4th Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
0
9:8,
17:16,
25:24
r
Reserved
Read as 0; should be written with 0
21.7.123.3
Standard routing table PDU Routing Rule
SRTk_PR (k=0-127)
Offset address:
00168H+k*4
Standard routing table PDU Routing Rule
RAMInit value:
XXXX XXXXH
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
MD
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
TYP
0
DID
Mode
rw
r
rw
rw
Field
Bits
Type
Description
Mode
1:0
rw
Defines the type of the routing
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
2 - PDU Routing Rule
other - Reserved, considered as Uni-cast Rule
DID
7:2
rw
Destination ID of system memory
This bit-field indicates the system memory destination to which the
received CAN frame has to be transferred to. The Destinations are
referenced using a unique ID as given in the Routing ID overview table.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4115
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TYP
15:13
rw
PDU Header type
Selects the PDU header type. All other values are by default considered
as Type 1
001B TYPE1: 11- bit Standard CAN ID with no Metadata
010B TYPE2: 11- bit Standard CAN ID with Metadata
011B TYPE3: 11- bit Standard CAN ID with optional Metadata
MD
31:16
rw
Metadata
SW configured Metadata used in the PDU ID generation
0
12:8
r
Reserved
Read as 0; should be written with 0
21.7.124
CRE Extended Routing Table
21.7.124.1
Extended routing table Uni-cast Rule
XRTk_UCR (k=0-63)
Offset address:
00368H+k*4
Extended routing table Uni-cast Rule
RAMInit value:
XXXX XXXXH
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
IDSHIFT
0
IDXOR
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
DLC
FDF
FDF
M
0
DID
Mode
rw
rw
w
r
rw
rw
Field
Bits
Type
Description
Mode
1:0
rw
Defines the type of routing table
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
2 - PDU Routing Rule
other - Reserved, considered as Uni-cast Rule
DID
7:2
rw
Destination of Recieved CAN Frame
This bit-field indicates the Destination to which the received CAN frame
has to be transferred to. The Destinations are referenced using a unique
ID as given in the Routing ID overview table.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4116
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FDFM
10
w
CAN Frame Format Modifier enable bit
CAN Frame Format Modifier enable bit
0 - the FDF bit is ignored and the received CAN frame format is not
changed
1 - the received CAN frame format is changed either to Classical CAN
frame (FDF=0) or to CAN FD frame format (FDF=1)
FDF
11
rw
Indicates if recieved Frame is Classical or FD Format
This bit-field indicates the Frame Format to which the received CAN
frame has to be modified to. It is valid only when FDFM = 1.
0 - Classical CAN frame format
1 - CAN FD frame format
DLC
15:12
rw
Data Length Code
Indicates the modification to the Data Length Code of the received CAN
frame before transferring the frame to its corresponding destination.
DLC = 0, the Destination CAN frame length is same as the received CAN
frame
DLC != 0, Destination CAN frame length as defined by ISO 11898-1
IDXOR
26:16
rw
CAN Frame ID modifier
Modification to the ID of the Received CAN frame.
The Destination CAN Frame ID = [IDXOR<<IDSHIFT] (Xored) RX_CANID
IDSHIFT
31:29
rw
CAN Frame ID Modifier
Modification to the ID of the Received CAN frame.
The Destination CAN Frame ID = [IDXOR<<IDSHIFT] (Xored) RX_CANID
0
9:8,
28:27
r
Reserved
Read as 0; should be written with 0
21.7.124.2
Extended routing table Multi-cast Rule
XRTk_MCR (k=0-63)
Offset address:
00368H+k*4
Extended routing table Multi-cast Rule
RAMInit value:
XXXX XXXXH
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
DID3
0
DID2
0
rw
r
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
DID1
0
DID0
Mode
rw
r
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4117
v1.1
2025-06-26


Field
Bits
Type
Description
Mode
1:0
rw
Definition of type of routing table
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
2 - PDU Routing Rule
other - Reserved, considered as Uni-cast Rule
DID0
7:2
rw
1st Destination of Received CAN Frame
This bit-field indicates the 1st Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID1
15:10
rw
2nd Destination of Received CAN Frame
This bit-field indicates the 2nd Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID2
23:18
rw
3rd Destination of Received CAN Frame
This bit-field indicates the 3rd Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
DID3
31:26
rw
4th Destination of Received CAN Frame
This bit-field indicates the 4th Destination to which the received CAN
frame has to be transferred to. The Destinations are referenced using a
unique ID as given in the Routing ID overview table.
0
9:8,
17:16,
25:24
r
Reserved
Read as 0; should be written with 0
21.7.124.3
Extended ID routing table PDU Routing Rule
XRTk_PR (k=0-63)
Offset address:
00368H+k*4
Extended ID routing table PDU Routing Rule
RAMInit value:
XXXX XXXXH
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
TYP
0
DID
Mode
rw
r
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4118
v1.1
2025-06-26


Field
Bits
Type
Description
Mode
1:0
rw
Defines the type of the routing
It defines the type of the routing rule
0 - Uni-cast Rule
1 - Multi-cast Rule
2 - PDU Routing Rule
other - Reserved, considered as Uni-cast Rule
DID
7:2
rw
Destination ID of system memory
This bit-field indicates the system memory destination to which the
received CAN frame has to be transferred to. The Destinations are
referenced using a unique ID as given in the Routing ID overview table.
TYP
15:13
rw
PDU Header type
Selects the PDU header type. All other values are considered by default
as Type 4
100B TYPE4: 29- bit Extended CAN ID with no Metadata
101B TYPE5: 29- bit Extended CAN ID with no Metadata and no Source
ID
0
12:8,
31:16
r
Reserved
Read as 0; should be written with 0
21.7.125
CRE Standard Frame Rate Table
21.7.125.1
Standard ID Frame Rate Measure
Standard CAN ID Frame rate measure table
Consists of two Standard ID Frame rate measures
SFRk_FR (k=0-63)
Offset address:
00468H+k*4
Standard ID Frame Rate Measure
RAMinit value:
XXXX XXXXH
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
FR2
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
FR1
rwh
Field
Bits
Type
Description
FR1
15:0
rwh
Frame Rate Measure 1
Frame Rate Measure is relevant for Intrusion detection. It indicates the
number of frames received
FR2
31:16
rwh
Frame Rate Measure 2
Frame Rate Measure is relevant for Intrusion detection. It indicates the
number of frames received
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4119
v1.1
2025-06-26


21.7.126
CRE Extended Frame Rate Table
21.7.126.1
Extended ID Frame Rate Measure
Extended CAN ID Frame Rate Mesaure table
Consists of two Extended ID Frame rate measures
XFRk_FR (k=0-31)
Offset address:
00568H+k*4
Extended ID Frame Rate Measure
RAMInit value:
XXXX XXXXH
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
FR2
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
FR1
rwh
Field
Bits
Type
Description
FR1
15:0
rwh
Frame Rate Measure 1
Frame Rate Measure is relevant for Intrusion detection. It indicates the
number of frames received
FR2
31:16
rwh
Frame Rate Measure 2
Frame Rate Measure is relevant for Intrusion detection. It indicates the
number of frames received
21.7.127
CRE Standard Timestamp Database
21.7.127.1
Standard ID Reference Timestamp
Standard ID Reference Timestamp which is used to calculate the RHBUFk_THEAD_INTRD. IAM
Note: The database needs to be initialized to 0
STSDk_RTS (k=0-127)
Offset address:
005E8H+k*4
Standard ID Reference Timestamp
RAMInit value:
XXXX XXXXH
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
TS
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
TS
rwh
Field
Bits
Type
Description
TS
31:0
rwh
Reference Timestamp
This Reference Timestamp is the previous received Timestamp used for
calculating the Inter Arrival Measure.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4120
v1.1
2025-06-26


21.7.128
CRE Extended Timestamp Database
21.7.128.1
Extended ID Reference Timestamp
Extended ID Reference Timestamp which is used to calculate the RHBUFk_THEAD_INTRD. IAM
Note: The database needs to be initialized to 0
XTSDk_RTS (k=0-63)
Offset address:
007E8H+k*4
Extended ID Reference Timestamp
RAMInit value:
XXXX XXXXH
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
TS
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
TS
rwh
Field
Bits
Type
Description
TS
31:0
rwh
Reference Timestamp
This Reference Timestamp is the previous received Timestamp used for
calculating the Inter Arrival Measure.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4121
v1.1
2025-06-26


21.8
Debug information
OCDS suspend behavior support
•
Hard suspend
-
The clock is switched off to the MCMCAN module, and any ongoing transmission or reception event will
be suspended immediately
•
Soft suspend
-
The clock is switched off to the MCMCAN module after completion of the ongoing transmission and
reception events. The Ni_CCCR.INIT bit will be set during the soft suspend. So, when leaving the soft
suspend, the debugger has to ensure that the Ni_CCCR.INIT bit is cleared in order to continue normal
CAN operation
Destructive debug
On destructive debug entry ie., when GP_CSRM_DBCFG.DESTDBG = 11b and GP_CSRM_DBGMODE.EDDM = 11b,
the CAN transmit data output (TXD) is tied to “Recessive state” (logic ‘1b’). This blocks any further CAN
transmission when the device has entered the Destructive Debug state.
OCDS trigger bus interface
The CAN trigger set is shown in table. Its output is on OTBG0 or OTGB1 controlled by the OCS register.
Table 1024
TS16_CAN trigger set
Values
Name
Description
i
AF
Acceptance filtering done for Node i
i + 4
MR
Message successfully received on Node i
i + 8
FDR
Fast Data Phase reception on Node i
i + 12
FDT
Fast Data Phase transmission on Node i
21.9
References
1.
ISO 11898-1, Road vehicles — Controller area network (CAN) — Part 1: Data link layer and physical
signalling, 2015
2.
Society of Automotive Engineer, J1939 Recommended Practice for a Serial Control and Communications
Vehicle Network
3.
CAN in Automation, CiA 603: CAN Frame time-stamping – Requirements for network time management,
version 1.0.0, 2017
21.10
CAN revision history
Reference
Description of change(s)
Date range: 2024-08-17 to 2024-11-27
Node i Test Register, Node
i Protocol Status Register
and Node i CC Control
Register
•
Correcting wrong access condition type of bit-fields
Module Control Register,
Node i Timer Transmit
Trigger 0 Register and
Measure Control Register
•
Moving misplaced paragraphs from MCR register description to the
appropriate register descriptions
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4122
v1.1
2025-06-26


21.11
TC4Dx CAN information
21.11.1
TC4Dx CAN configuration
Table 1025
Device specific parameters
Parameters
CAN0
CAN1
CAN2
CAN3
CAN4
Number of CAN
nodes
4
4
4
4
4
RAM size (in
Kbytes)
36
20
20
20
20
Debug over CAN
support
Yes (only in Node
0)
No
No
No
No
21.11.2
TC4Dx CAN features
There are no deviations from the generic specification.
21.11.3
TC4Dx CAN functional description
•
In TC4Dx device, the CAN modules are connected to ComPB bus interface. The CAN chapter refers to it as
FPI bus
•
In TC4Dx, the reset domain for the Node Start Address (Ni_STARTADR (i=0-3)) and Node End Address
(Ni_ENDADR (i=0-3)) registers is Kernel Reset and the reset value remains the same as specified in the
family specification 4010
21.11.4
TC4Dx CAN registers
21.11.4.1
Memory overview tables of CAN domain SFR
Table 1026
Memory overview - CAN domain SFR (ascending address)
Short name
Long name
Address
CAN0_RAM
Embedded SRAM for messages
(09000H Byte)
F4700000H
CAN1_RAM
Embedded SRAM for messages
(05000H Byte)
F4720000H
CAN2_RAM
Embedded SRAM for messages
(05000H Byte)
F4740000H
CAN3_RAM
Embedded SRAM for messages
(05000H Byte)
F4760000H
CAN4_RAM
Embedded SRAM for messages
(05000H Byte)
F4780000H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4123
v1.1
2025-06-26


21.11.4.2
Register address space - CAN
Table 1027
Registers address space - CAN
Key: The module name in brackets () indicates a memory section name. Without brackets the reference is to a
functional block.
Module
Base address
End address
Note
CAN0
F4710000H
F471FFFFH
Slave interface for SFR registers
CAN1
F4730000H
F473FFFFH
Slave interface for SFR registers
CAN2
F4750000H
F475FFFFH
Slave interface for SFR registers
CAN3
F4770000H
F477FFFFH
Slave interface for SFR registers
CAN4
F4790000H
F479FFFFH
Slave interface for SFR registers
(CAN0_RAM)
F4700000H
F4708FFFH
Slave interface for Message RAM
(CAN1_RAM)
F4720000H
F4724FFFH
Slave interface for Message RAM
(CAN2_RAM)
F4740000H
F4744FFFH
Slave interface for Message RAM
(CAN3_RAM)
F4760000H
F4764FFFH
Slave interface for Message RAM
(CAN4_RAM)
F4780000H
F4784FFFH
Slave interface for Message RAM
21.11.4.3
Register overview - access mode glossary
Table 1028
Register overview - access mode glossary
Keyword
Description
E
Access protection using PROT register CAN0_PROTE or CAN1_PROTE or CAN2_PROTE or
CAN3_PROTE or CAN4_PROTE .
SE
Access protection using PROT register CAN0_PROTSE or CAN1_PROTSE or CAN2_PROTSE or
CAN3_PROTSE or CAN4_PROTSE .
APU-PNi (i=0-3)
Protection group consisting of registers CAN0_Ni_ACCEN_WRA , CAN0_Ni_ACCEN_WRB ,
CAN0_Ni_ACCEN_RDA , CAN0_Ni_ACCEN_RDB , CAN0_Ni_ACCEN_VM , CAN0_Ni_ACCEN_PRS
or CAN1_Ni_ACCEN_WRA , CAN1_Ni_ACCEN_WRB , CAN1_Ni_ACCEN_RDA ,
CAN1_Ni_ACCEN_RDB , CAN1_Ni_ACCEN_VM , CAN1_Ni_ACCEN_PRS
or CAN2_Ni_ACCEN_WRA , CAN2_Ni_ACCEN_WRB , CAN2_Ni_ACCEN_RDA ,
CAN2_Ni_ACCEN_RDB , CAN2_Ni_ACCEN_VM , CAN2_Ni_ACCEN_PRS
or CAN3_Ni_ACCEN_WRA , CAN3_Ni_ACCEN_WRB , CAN3_Ni_ACCEN_RDA ,
CAN3_Ni_ACCEN_RDB , CAN3_Ni_ACCEN_VM , CAN3_Ni_ACCEN_PRS
or CAN4_Ni_ACCEN_WRA , CAN4_Ni_ACCEN_WRB , CAN4_Ni_ACCEN_RDA ,
CAN4_Ni_ACCEN_RDB , CAN4_Ni_ACCEN_VM , CAN4_Ni_ACCEN_PRS .
PNi
Access protection using APU-PNi registers.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4124
v1.1
2025-06-26


Table 1028
(continued) Register overview - access mode glossary
Keyword
Description
APU-P4
Protection group consisting of registers CAN0_ACCEN_WRA , CAN0_ACCEN_WRB ,
CAN0_ACCEN_RDA , CAN0_ACCEN_RDB , CAN0_ACCEN_VM , CAN0_ACCEN_PRS
or CAN1_ACCEN_WRA , CAN1_ACCEN_WRB , CAN1_ACCEN_RDA , CAN1_ACCEN_RDB ,
CAN1_ACCEN_VM , CAN1_ACCEN_PRS
or CAN2_ACCEN_WRA , CAN2_ACCEN_WRB , CAN2_ACCEN_RDA , CAN2_ACCEN_RDB ,
CAN2_ACCEN_VM , CAN2_ACCEN_PRS
or CAN3_ACCEN_WRA , CAN3_ACCEN_WRB , CAN3_ACCEN_RDA , CAN3_ACCEN_RDB ,
CAN3_ACCEN_VM , CAN3_ACCEN_PRS
or CAN4_ACCEN_WRA , CAN4_ACCEN_WRB , CAN4_ACCEN_RDA , CAN4_ACCEN_RDB ,
CAN4_ACCEN_VM , CAN4_ACCEN_PRS .
P4
Access protection using APU-P4 registers.
BE
Always returns a Bus Error.
U
No access restrictions.
PROT
Access restrictions as defined in the PROT register access rules.
nBE
Indicates that no Bus Error is generated when accessing this address range, even though it is
either an access to an undefined address or the access does not follow the given rules.
M
Indicates a module specific access condition. Refer to the register description for details of
the specific access condition.
21.11.4.4
Register overview - CAN0 domain SFR (ascending offset address)
Table 1029
Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_CLC
Clock Control Register
00000H
P4
P4, SV, E
3989
3989
CAN0_OCS
OCDS Control and Status
Register
00004H
P4
SV, P4
Debug Reset
3990
CAN0_ID
Module Identification
Register
00008H
P4
BE
PowerOn Reset
3991
CAN0_RST_CTRL
A
Reset Control Register A
0000CH
P4
P4, SV, E
Application
Reset
3991
CAN0_RST_CTRL
B
Reset Control Register B
00010H
P4
P4, SV, E
Application
Reset
3992
CAN0_RST_STAT
Reset Status Register
00014H
P4
BE
Application
Reset
3993
CAN0_PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3993
CAN0_PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3995
CAN0_ACCEN_W
RA
Write access enable register
A
00030H
U
SE, SV
Application
Reset
3997
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4125
v1.1
2025-06-26


Table 1029
(continued) Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_ACCEN_W
RB
Write access enable register
B
00034H
U
SE, SV
Application
Reset
3997
CAN0_ACCEN_RD
A
Read access enable register
A
00038H
U
SE, SV
Application
Reset
3998
CAN0_ACCEN_RD
B
Read access enable register
B
0003CH
U
SE, SV
Application
Reset
3998
CAN0_ACCEN_V
M
VM access enable register
00040H
U
SE, SV
Application
Reset
3999
CAN0_ACCEN_PR
S
PRS access enable register
00044H
U
SE, SV
Application
Reset
3999
CAN0_MCR
Module Control Register
00070H
P4
P4
4001
4001
CAN0_BUFADR
Buffer receive address and
transmit address
00074H
P4
P4
Kernel Reset
4003
CAN0_MECR
Measure Control Register
00080H
P4
P4
Kernel Reset
4004
CAN0_MESTAT
Measure Status Register
00084H
P4
P4
Kernel Reset
4005
CAN0_WDT
CRE Watchdog timer
register
00088H
P4
SV, E, P4
Kernel Reset
4006
CAN0_Ni_ACCEN
_WRA
(i=0-3)
Node i Write access enable
register A
00100H+i
*400H
U
SE, SV
Application
Reset
4007
CAN0_Ni_ACCEN
_WRB
(i=0-3)
Node i Write access enable
register B
00104H+i
*400H
U
SE, SV
Application
Reset
4008
CAN0_Ni_ACCEN
_RDA
(i=0-3)
Node i Read access enable
register A
00108H+i
*400H
U
SE, SV
Application
Reset
4008
CAN0_Ni_ACCEN
_RDB
(i=0-3)
Node i Read access enable
register B
0010CH+
i*400H
U
SE, SV
Application
Reset
4009
CAN0_Ni_ACCEN
_VM
(i=0-3)
Node i VM access enable
register
00110H+i
*400H
U
SE, SV
Application
Reset
4009
CAN0_Ni_ACCEN
_PRS
(i=0-3)
Node i PRS access enable
register
00114H+i
*400H
U
SE, SV
Application
Reset
4010
CAN0_Ni_START
ADR
(i=0-3)
Node i Start Address
00120H+i
*400H
PNi
SV, E, PNi
Application
Reset
4010
CAN0_Ni_ENDAD
R
(i=0-3)
Node i End Address
00124H+i
*400H
PNi
SV, E, PNi
Application
Reset
4011
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4126
v1.1
2025-06-26


Table 1029
(continued) Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_Ni_INTRSI
G
(i=0-3)
Node i Interrupt Signalling
Register
00128H+i
*400H
PNi
nBE
Kernel Reset
4011
CAN0_Ni_G0INT
R
(i=0-3)
Node i Interrupt routing for
Group 0
0012CH+
i*400H
PNi
PNi
Kernel Reset
4013
CAN0_Ni_G1INT
R
(i=0-3)
Node i Interrupt routing for
Group 1
00130H+i
*400H
PNi
PNi
Kernel Reset
4014
CAN0_Ni_G2INT
R
(i=0-3)
Node i Interrupt routing for
Group 2
00134H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN0_Ni_TIMER_
CCR
(i=0-3)
Node i Timer Clock Control
Register
00138H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN0_Ni_TIMER_
TXTRIG0
(i=0-3)
Node i Timer Transmit
Trigger 0 Register
0013CH+
i*400H
PNi
PNi
Kernel Reset
4016
CAN0_Ni_TIMER_
TXTRIG1
(i=0-3)
Node i Timer Transmit
Trigger 1 Register
00140H+i
*400H
PNi
PNi
Kernel Reset
4017
CAN0_Ni_TIMER_
TXTRIG2
(i=0-3)
Node i Timer Transmit
Trigger 2 Register
00144H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN0_Ni_TIMER_
RXTOUT
(i=0-3)
Node i Timer Receive
Timeout Register
00148H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN0_Ni_PORTC
TRL
(i=0-3)
Node i Port Control Register 0014CH+
i*400H
PNi
PNi
Kernel Reset
4019
CAN0_Ni_CRE_C
ONFIG
(i=0-3)
Node i CRE Configuration
Register
00150H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4020
CAN0_Ni_CRE_C
ONFIGADR
(i=0-3)
Node i CRE Configuration
Start Address
00154H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4022
CAN0_Ni_CRE_H
BUF_RXz_CONFI
G
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Configuration
00158H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4022
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4127
v1.1
2025-06-26


Table 1029
(continued) Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_Ni_CRE_H
BUF_RXz_STAT
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Status
0015CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4024
CAN0_Ni_CRE_H
BUF_TXz_CONFI
G
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Configuration
00168H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4025
CAN0_Ni_CRE_H
BUF_TXz_STAT
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Status
0016CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4026
CAN0_Ni_CRE_IR
(i=0-3)
Node i CRE Interrupt
Register
0018CH+
i*400H
PNi
PNi
Kernel Reset
4028
CAN0_Ni_IDMU_
FRTCONFIG
(i=0-3)
Node i Frame Rate Measure
Table Configuration
00190H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4029
CAN0_Ni_IDMU_
RXTPCFG
(i=0-3)
Node i Rx Throughput
Measure configuration
00194H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4030
CAN0_Ni_ERRCT
RL
(i=0-3)
Node i CRE Error control
register
00198H+i
*400H
P4
SV, E, P4
Kernel Reset
4031
CAN0_Ni_CREL
(i=0-3)
Node i Core Release
Register
00200H+i
*400H
PNi
nBE
Kernel Reset
4032
CAN0_Ni_ENDN
(i=0-3)
Node i Endian Register
00204H+i
*400H
PNi
nBE
Kernel Reset
4033
CAN0_Ni_DBTP
(i=0-3)
Node i Data Bit Timing &
Prescaler Register
0020CH+
i*400H
PNi
PNi
4034
4034
CAN0_Ni_TEST
(i=0-3)
Node i Test Register
00210H+i
*400H
PNi
PNi
4035
4035
CAN0_Ni_RWD
(i=0-3)
Node i RAM Watchdog
00214H+i
*400H
PNi
PNi
Kernel Reset
4036
CAN0_Ni_CCCR
(i=0-3)
Node i CC Control Register
00218H+i
*400H
PNi
PNi
4037
4037
CAN0_Ni_NBTP
(i=0-3)
Node i Nominal Bit Timing
& Prescaler Register
0021CH+
i*400H
PNi
PNi
4040
4040
CAN0_Ni_TSCC
(i=0-3)
Node i Timestamp Counter
Configuration
00220H+i
*400H
PNi
PNi
Kernel Reset
4041
CAN0_Ni_TSCV
(i=0-3)
Node i Timestamp Counter
Value
00224H+i
*400H
PNi
PNi
Kernel Reset
4042
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4128
v1.1
2025-06-26


Table 1029
(continued) Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_Ni_TOCC
(i=0-3)
Node i Timeout Counter
Configuration
00228H+i
*400H
PNi
PNi
Kernel Reset
4043
CAN0_Ni_TOCV
(i=0-3)
Node i Timeout Counter
Value
0022CH+
i*400H
PNi
PNi
Kernel Reset
4044
CAN0_Ni_ECR
(i=0-3)
Node i Error Counter
Register
00240H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN0_Ni_PSR
(i=0-3)
Node i Protocol Status
Register
00244H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN0_Ni_TDCR
(i=0-3)
Node i Transmitter Delay
Compensation Register
00248H+i
*400H
PNi
PNi
Kernel Reset
4049
CAN0_Ni_IR
(i=0-3)
Node i Interrupt Register
00250H+i
*400H
PNi
PNi
Kernel Reset
4050
CAN0_Ni_IE
(i=0-3)
Node i Interrupt Enable
00254H+i
*400H
PNi
PNi
Kernel Reset
4053
CAN0_Ni_GFC
(i=0-3)
Node i Global Filter
Configuration
00280H+i
*400H
PNi
PNi
Kernel Reset
4056
CAN0_Ni_SIDFC
(i=0-3)
Node i Standard ID Filter
Configuration
00284H+i
*400H
PNi
PNi
4057
4057
CAN0_Ni_XIDFC
(i=0-3)
Node i Extended ID Filter
Configuration
00288H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN0_Ni_XIDAM
(i=0-3)
Node i Extended ID AND
Mask
00290H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN0_Ni_HPMS
(i=0-3)
Node i High Priority
Message Status
00294H+i
*400H
PNi
nBE
Kernel Reset
4059
CAN0_Ni_NDAT1
(i=0-3)
Node i New Data 1
00298H+i
*400H
PNi
PNi
Kernel Reset
4060
CAN0_Ni_NDAT2
(i=0-3)
Node i New Data 2
0029CH+
i*400H
PNi
PNi
Kernel Reset
4060
CAN0_Ni_RXF0C
(i=0-3)
Node i Rx FIFO 0
Configuration
002A0H+
i*400H
PNi
PNi
Kernel Reset
4061
CAN0_Ni_RXF0S
(i=0-3)
Node i Rx FIFO 0 Status
002A4H+
i*400H
PNi
nBE
Kernel Reset
4062
CAN0_Ni_RXF0A
(i=0-3)
Node i Rx FIFO 0
Acknowledge
002A8H+
i*400H
PNi
PNi
Kernel Reset
4063
CAN0_Ni_RXBC
(i=0-3)
Node i Rx Buffer
Configuration
002ACH+
i*400H
PNi
PNi
4063
4063
CAN0_Ni_RXF1C
(i=0-3)
Node i Rx FIFO 1
Configuration
002B0H+
i*400H
PNi
PNi
Kernel Reset
4064
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4129
v1.1
2025-06-26


Table 1029
(continued) Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_Ni_RXF1S
(i=0-3)
Node i Rx FIFO 1 Status
002B4H+
i*400H
PNi
nBE
Kernel Reset
4065
CAN0_Ni_RXF1A
(i=0-3)
Node i Rx FIFO 1
Acknowledge
002B8H+
i*400H
PNi
PNi
Kernel Reset
4066
CAN0_Ni_RXESC
(i=0-3)
Node i Rx Buffer/FIFO
Element Size Configuration
002BCH+
i*400H
PNi
PNi
Kernel Reset
4067
CAN0_Ni_TXBC
(i=0-3)
Node i Tx Buffer
Configuration
002C0H+
i*400H
PNi
PNi
4068
4068
CAN0_Ni_TXFQS
(i=0-3)
Node i Tx FIFO/Queue
Status
002C4H+
i*400H
PNi
nBE
Kernel Reset
4069
CAN0_Ni_TXESC
(i=0-3)
Node i Tx Buffer Element
Size Configuration
002C8H+
i*400H
PNi
PNi
4070
4070
CAN0_Ni_TXBRP
(i=0-3)
Node i Tx Buffer Request
Pending
002CCH+
i*400H
PNi
PNi
Kernel Reset
4072
CAN0_Ni_TXBAR
(i=0-3)
Node i Tx Buffer Add
Request
002D0H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN0_Ni_TXBCR
(i=0-3)
Node i Tx Buffer
Cancellation Request
002D4H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN0_Ni_TXBTO
(i=0-3)
Node i Tx Buffer
Transmission Occurred
002D8H+
i*400H
PNi
nBE
Kernel Reset
4074
CAN0_Ni_TXBCF
(i=0-3)
Node i Tx Buffer
Cancellation Finished
002DCH+
i*400H
PNi
nBE
Kernel Reset
4074
CAN0_Ni_TXBTIE
(i=0-3)
Node i Tx Buffer
Transmission Interrupt
Enable
002E0H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN0_Ni_TXBCIE
(i=0-3)
Node i Tx Buffer
Cancellation Finished
Interrupt Enable
002E4H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN0_Ni_TXEFC
(i=0-3)
Node i Tx Event FIFO
Configuration
002F0H+i
*400H
PNi
PNi
Kernel Reset
4076
CAN0_Ni_TXEFS
(i=0-3)
Node i Tx Event FIFO Status
002F4H+i
*400H
PNi
nBE
Kernel Reset
4077
CAN0_Ni_TXEFA
(i=0-3)
Node i Tx Event FIFO
Acknowledge
002F8H+i
*400H
PNi
PNi
Kernel Reset
4077
CAN0_Ni_TSU_C
REL
(i=0-3)
Node i TSU Core Release
Register
00360H+i
*400H
PNi
nBE
Kernel Reset
4078
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4130
v1.1
2025-06-26


Table 1029
(continued) Register overview - CAN0 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN0_Ni_TSU_T
SCFG
(i=0)
(i=1-3)
Node i Timestamp
Configuration
00364H+i
*400H
PNi
PNi
Kernel Reset
4078
CAN0_Ni_TSU_T
SS1
(i=0-3)
Node i Timestamp Status 1
00368H+i
*400H
PNi
nBE
Kernel Reset
4080
CAN0_Ni_TSU_T
SS2
(i=0-3)
Node i Timestamp Status 2
0036CH+
i*400H
PNi
nBE
Kernel Reset
4081
CAN0_Ni_TSU_T
Sm
(i=0-3;m=0-15)
Node i Timestamp m
00370H+i
*400H+m
*4
PNi
nBE
Kernel Reset
4082
CAN0_Ni_TSU_A
TB
(i=0-3)
Node i Actual Timebase
003B0H+
i*400H
PNi
U
Kernel Reset
4082
21.11.4.5
Register overview - CAN1 domain SFR (ascending offset address)
Table 1030
Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_CLC
Clock Control Register
00000H
P4
P4, SV, E
Application
Reset
4154
CAN1_OCS
OCDS Control and Status
Register
00004H
P4
SV, P4
Debug Reset
3990
CAN1_ID
Module Identification
Register
00008H
P4
BE
PowerOn Reset
3991
CAN1_RST_CTRL
A
Reset Control Register A
0000CH
P4
P4, SV, E
Application
Reset
3991
CAN1_RST_CTRL
B
Reset Control Register B
00010H
P4
P4, SV, E
Application
Reset
3992
CAN1_RST_STAT
Reset Status Register
00014H
P4
BE
Application
Reset
3993
CAN1_PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3993
CAN1_PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3995
CAN1_ACCEN_W
RA
Write access enable register
A
00030H
U
SE, SV
Application
Reset
3997
CAN1_ACCEN_W
RB
Write access enable register
B
00034H
U
SE, SV
Application
Reset
3997
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4131
v1.1
2025-06-26


Table 1030
(continued) Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_ACCEN_RD
A
Read access enable register
A
00038H
U
SE, SV
Application
Reset
3998
CAN1_ACCEN_RD
B
Read access enable register
B
0003CH
U
SE, SV
Application
Reset
3998
CAN1_ACCEN_V
M
VM access enable register
00040H
U
SE, SV
Application
Reset
3999
CAN1_ACCEN_PR
S
PRS access enable register
00044H
U
SE, SV
Application
Reset
3999
CAN1_MCR
Module Control Register
00070H
P4
P4
Kernel Reset
4156
CAN1_WDT
CRE Watchdog timer
register
00088H
P4
SV, E, P4
Kernel Reset
4006
CAN1_Ni_ACCEN
_WRA
(i=0-3)
Node i Write access enable
register A
00100H+i
*400H
U
SE, SV
Application
Reset
4007
CAN1_Ni_ACCEN
_WRB
(i=0-3)
Node i Write access enable
register B
00104H+i
*400H
U
SE, SV
Application
Reset
4008
CAN1_Ni_ACCEN
_RDA
(i=0-3)
Node i Read access enable
register A
00108H+i
*400H
U
SE, SV
Application
Reset
4008
CAN1_Ni_ACCEN
_RDB
(i=0-3)
Node i Read access enable
register B
0010CH+
i*400H
U
SE, SV
Application
Reset
4009
CAN1_Ni_ACCEN
_VM
(i=0-3)
Node i VM access enable
register
00110H+i
*400H
U
SE, SV
Application
Reset
4009
CAN1_Ni_ACCEN
_PRS
(i=0-3)
Node i PRS access enable
register
00114H+i
*400H
U
SE, SV
Application
Reset
4010
CAN1_Ni_START
ADR
(i=0-3)
Node i Start Address
00120H+i
*400H
PNi
SV, E, PNi
Application
Reset
4010
CAN1_Ni_ENDAD
R
(i=0-3)
Node i End Address
00124H+i
*400H
PNi
SV, E, PNi
Application
Reset
4011
CAN1_Ni_INTRSI
G
(i=0-3)
Node i Interrupt Signalling
Register
00128H+i
*400H
PNi
nBE
Kernel Reset
4011
CAN1_Ni_G0INT
R
(i=0-3)
Node i Interrupt routing for
Group 0
0012CH+
i*400H
PNi
PNi
Kernel Reset
4013
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4132
v1.1
2025-06-26


Table 1030
(continued) Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_Ni_G1INT
R
(i=0-3)
Node i Interrupt routing for
Group 1
00130H+i
*400H
PNi
PNi
Kernel Reset
4014
CAN1_Ni_G2INT
R
(i=0-3)
Node i Interrupt routing for
Group 2
00134H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN1_Ni_TIMER_
CCR
(i=0-3)
Node i Timer Clock Control
Register
00138H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN1_Ni_TIMER_
TXTRIG0
(i=0-3)
Node i Timer Transmit
Trigger 0 Register
0013CH+
i*400H
PNi
PNi
Kernel Reset
4016
CAN1_Ni_TIMER_
TXTRIG1
(i=0-3)
Node i Timer Transmit
Trigger 1 Register
00140H+i
*400H
PNi
PNi
Kernel Reset
4017
CAN1_Ni_TIMER_
TXTRIG2
(i=0-3)
Node i Timer Transmit
Trigger 2 Register
00144H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN1_Ni_TIMER_
RXTOUT
(i=0-3)
Node i Timer Receive
Timeout Register
00148H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN1_Ni_PORTC
TRL
(i=0-3)
Node i Port Control Register 0014CH+
i*400H
PNi
PNi
Kernel Reset
4019
CAN1_Ni_CRE_C
ONFIG
(i=0-3)
Node i CRE Configuration
Register
00150H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4158
CAN1_Ni_CRE_C
ONFIGADR
(i=0-3)
Node i CRE Configuration
Start Address
00154H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4022
CAN1_Ni_CRE_H
BUF_RXz_CONFI
G
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Configuration
00158H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4022
CAN1_Ni_CRE_H
BUF_RXz_STAT
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Status
0015CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4024
CAN1_Ni_CRE_H
BUF_TXz_CONFI
G
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Configuration
00168H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4025
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4133
v1.1
2025-06-26


Table 1030
(continued) Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_Ni_CRE_H
BUF_TXz_STAT
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Status
0016CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4026
CAN1_Ni_CRE_IR
(i=0-3)
Node i CRE Interrupt
Register
0018CH+
i*400H
PNi
PNi
Kernel Reset
4028
CAN1_Ni_IDMU_
FRTCONFIG
(i=0-3)
Node i Frame Rate Measure
Table Configuration
00190H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4029
CAN1_Ni_IDMU_
RXTPCFG
(i=0-3)
Node i Rx Throughput
Measure configuration
00194H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4030
CAN1_Ni_ERRCT
RL
(i=0-3)
Node i CRE Error control
register
00198H+i
*400H
P4
SV, E, P4
Kernel Reset
4031
CAN1_Ni_CREL
(i=0-3)
Node i Core Release
Register
00200H+i
*400H
PNi
nBE
Kernel Reset
4032
CAN1_Ni_ENDN
(i=0-3)
Node i Endian Register
00204H+i
*400H
PNi
nBE
Kernel Reset
4033
CAN1_Ni_DBTP
(i=0-3)
Node i Data Bit Timing &
Prescaler Register
0020CH+
i*400H
PNi
PNi
4034
4034
CAN1_Ni_TEST
(i=0-3)
Node i Test Register
00210H+i
*400H
PNi
PNi
4035
4035
CAN1_Ni_RWD
(i=0-3)
Node i RAM Watchdog
00214H+i
*400H
PNi
PNi
Kernel Reset
4036
CAN1_Ni_CCCR
(i=0-3)
Node i CC Control Register
00218H+i
*400H
PNi
PNi
4037
4037
CAN1_Ni_NBTP
(i=0-3)
Node i Nominal Bit Timing
& Prescaler Register
0021CH+
i*400H
PNi
PNi
4040
4040
CAN1_Ni_TSCC
(i=0-3)
Node i Timestamp Counter
Configuration
00220H+i
*400H
PNi
PNi
Kernel Reset
4041
CAN1_Ni_TSCV
(i=0-3)
Node i Timestamp Counter
Value
00224H+i
*400H
PNi
PNi
Kernel Reset
4042
CAN1_Ni_TOCC
(i=0-3)
Node i Timeout Counter
Configuration
00228H+i
*400H
PNi
PNi
Kernel Reset
4043
CAN1_Ni_TOCV
(i=0-3)
Node i Timeout Counter
Value
0022CH+
i*400H
PNi
PNi
Kernel Reset
4044
CAN1_Ni_ECR
(i=0-3)
Node i Error Counter
Register
00240H+i
*400H
PNi
nBE
Kernel Reset
4045
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4134
v1.1
2025-06-26


Table 1030
(continued) Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_Ni_PSR
(i=0-3)
Node i Protocol Status
Register
00244H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN1_Ni_TDCR
(i=0-3)
Node i Transmitter Delay
Compensation Register
00248H+i
*400H
PNi
PNi
Kernel Reset
4049
CAN1_Ni_IR
(i=0-3)
Node i Interrupt Register
00250H+i
*400H
PNi
PNi
Kernel Reset
4050
CAN1_Ni_IE
(i=0-3)
Node i Interrupt Enable
00254H+i
*400H
PNi
PNi
Kernel Reset
4053
CAN1_Ni_GFC
(i=0-3)
Node i Global Filter
Configuration
00280H+i
*400H
PNi
PNi
Kernel Reset
4056
CAN1_Ni_SIDFC
(i=0-3)
Node i Standard ID Filter
Configuration
00284H+i
*400H
PNi
PNi
4057
4057
CAN1_Ni_XIDFC
(i=0-3)
Node i Extended ID Filter
Configuration
00288H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN1_Ni_XIDAM
(i=0-3)
Node i Extended ID AND
Mask
00290H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN1_Ni_HPMS
(i=0-3)
Node i High Priority
Message Status
00294H+i
*400H
PNi
nBE
Kernel Reset
4059
CAN1_Ni_NDAT1
(i=0-3)
Node i New Data 1
00298H+i
*400H
PNi
PNi
Kernel Reset
4060
CAN1_Ni_NDAT2
(i=0-3)
Node i New Data 2
0029CH+
i*400H
PNi
PNi
Kernel Reset
4060
CAN1_Ni_RXF0C
(i=0-3)
Node i Rx FIFO 0
Configuration
002A0H+
i*400H
PNi
PNi
Kernel Reset
4061
CAN1_Ni_RXF0S
(i=0-3)
Node i Rx FIFO 0 Status
002A4H+
i*400H
PNi
nBE
Kernel Reset
4062
CAN1_Ni_RXF0A
(i=0-3)
Node i Rx FIFO 0
Acknowledge
002A8H+
i*400H
PNi
PNi
Kernel Reset
4063
CAN1_Ni_RXBC
(i=0-3)
Node i Rx Buffer
Configuration
002ACH+
i*400H
PNi
PNi
4063
4063
CAN1_Ni_RXF1C
(i=0-3)
Node i Rx FIFO 1
Configuration
002B0H+
i*400H
PNi
PNi
Kernel Reset
4064
CAN1_Ni_RXF1S
(i=0-3)
Node i Rx FIFO 1 Status
002B4H+
i*400H
PNi
nBE
Kernel Reset
4065
CAN1_Ni_RXF1A
(i=0-3)
Node i Rx FIFO 1
Acknowledge
002B8H+
i*400H
PNi
PNi
Kernel Reset
4066
CAN1_Ni_RXESC
(i=0-3)
Node i Rx Buffer/FIFO
Element Size Configuration
002BCH+
i*400H
PNi
PNi
Kernel Reset
4067
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4135
v1.1
2025-06-26


Table 1030
(continued) Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_Ni_TXBC
(i=0-3)
Node i Tx Buffer
Configuration
002C0H+
i*400H
PNi
PNi
4068
4068
CAN1_Ni_TXFQS
(i=0-3)
Node i Tx FIFO/Queue
Status
002C4H+
i*400H
PNi
nBE
Kernel Reset
4069
CAN1_Ni_TXESC
(i=0-3)
Node i Tx Buffer Element
Size Configuration
002C8H+
i*400H
PNi
PNi
4070
4070
CAN1_Ni_TXBRP
(i=0-3)
Node i Tx Buffer Request
Pending
002CCH+
i*400H
PNi
PNi
Kernel Reset
4072
CAN1_Ni_TXBAR
(i=0-3)
Node i Tx Buffer Add
Request
002D0H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN1_Ni_TXBCR
(i=0-3)
Node i Tx Buffer
Cancellation Request
002D4H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN1_Ni_TXBTO
(i=0-3)
Node i Tx Buffer
Transmission Occurred
002D8H+
i*400H
PNi
nBE
Kernel Reset
4074
CAN1_Ni_TXBCF
(i=0-3)
Node i Tx Buffer
Cancellation Finished
002DCH+
i*400H
PNi
nBE
Kernel Reset
4074
CAN1_Ni_TXBTIE
(i=0-3)
Node i Tx Buffer
Transmission Interrupt
Enable
002E0H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN1_Ni_TXBCIE
(i=0-3)
Node i Tx Buffer
Cancellation Finished
Interrupt Enable
002E4H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN1_Ni_TXEFC
(i=0-3)
Node i Tx Event FIFO
Configuration
002F0H+i
*400H
PNi
PNi
Kernel Reset
4076
CAN1_Ni_TXEFS
(i=0-3)
Node i Tx Event FIFO Status
002F4H+i
*400H
PNi
nBE
Kernel Reset
4077
CAN1_Ni_TXEFA
(i=0-3)
Node i Tx Event FIFO
Acknowledge
002F8H+i
*400H
PNi
PNi
Kernel Reset
4077
CAN1_Ni_TSU_C
REL
(i=0-3)
Node i TSU Core Release
Register
00360H+i
*400H
PNi
nBE
Kernel Reset
4078
CAN1_Ni_TSU_T
SCFG
(i=0)
(i=1-3)
Node i Timestamp
Configuration
00364H+i
*400H
PNi
PNi
Kernel Reset
4078
CAN1_Ni_TSU_T
SS1
(i=0-3)
Node i Timestamp Status 1
00368H+i
*400H
PNi
nBE
Kernel Reset
4080
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4136
v1.1
2025-06-26


Table 1030
(continued) Register overview - CAN1 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN1_Ni_TSU_T
SS2
(i=0-3)
Node i Timestamp Status 2
0036CH+
i*400H
PNi
nBE
Kernel Reset
4081
CAN1_Ni_TSU_T
Sm
(i=0-3;m=0-15)
Node i Timestamp m
00370H+i
*400H+m
*4
PNi
nBE
Kernel Reset
4082
CAN1_Ni_TSU_A
TB
(i=0-3)
Node i Actual Timebase
003B0H+
i*400H
PNi
U
Kernel Reset
4082
21.11.4.6
Register overview - CAN2 domain SFR (ascending offset address)
Table 1031
Register overview - CAN2 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN2_CLC
Clock Control Register
00000H
P4
P4, SV, E
Application
Reset
4154
CAN2_OCS
OCDS Control and Status
Register
00004H
P4
SV, P4
Debug Reset
3990
CAN2_ID
Module Identification
Register
00008H
P4
BE
PowerOn Reset
3991
CAN2_RST_CTRL
A
Reset Control Register A
0000CH
P4
P4, SV, E
Application
Reset
3991
CAN2_RST_CTRL
B
Reset Control Register B
00010H
P4
P4, SV, E
Application
Reset
3992
CAN2_RST_STAT
Reset Status Register
00014H
P4
BE
Application
Reset
3993
CAN2_PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3993
CAN2_PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3995
CAN2_ACCEN_W
RA
Write access enable register
A
00030H
U
SE, SV
Application
Reset
3997
CAN2_ACCEN_W
RB
Write access enable register
B
00034H
U
SE, SV
Application
Reset
3997
CAN2_ACCEN_RD
A
Read access enable register
A
00038H
U
SE, SV
Application
Reset
3998
CAN2_ACCEN_RD
B
Read access enable register
B
0003CH
U
SE, SV
Application
Reset
3998
CAN2_ACCEN_V
M
VM access enable register
00040H
U
SE, SV
Application
Reset
3999
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4137
v1.1
2025-06-26


Table 1031
(continued) Register overview - CAN2 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN2_ACCEN_PR
S
PRS access enable register
00044H
U
SE, SV
Application
Reset
3999
CAN2_MCR
Module Control Register
00070H
P4
P4
Kernel Reset
4156
CAN2_WDT
CRE Watchdog timer
register
00088H
P4
SV, E, P4
Kernel Reset
4006
CAN2_Ni_ACCEN
_WRA
(i=0-3)
Node i Write access enable
register A
00100H+i
*400H
U
SE, SV
Application
Reset
4007
CAN2_Ni_ACCEN
_WRB
(i=0-3)
Node i Write access enable
register B
00104H+i
*400H
U
SE, SV
Application
Reset
4008
CAN2_Ni_ACCEN
_RDA
(i=0-3)
Node i Read access enable
register A
00108H+i
*400H
U
SE, SV
Application
Reset
4008
CAN2_Ni_ACCEN
_RDB
(i=0-3)
Node i Read access enable
register B
0010CH+
i*400H
U
SE, SV
Application
Reset
4009
CAN2_Ni_ACCEN
_VM
(i=0-3)
Node i VM access enable
register
00110H+i
*400H
U
SE, SV
Application
Reset
4009
CAN2_Ni_ACCEN
_PRS
(i=0-3)
Node i PRS access enable
register
00114H+i
*400H
U
SE, SV
Application
Reset
4010
CAN2_Ni_START
ADR
(i=0-3)
Node i Start Address
00120H+i
*400H
PNi
SV, E, PNi
Application
Reset
4010
CAN2_Ni_ENDAD
R
(i=0-3)
Node i End Address
00124H+i
*400H
PNi
SV, E, PNi
Application
Reset
4011
CAN2_Ni_INTRSI
G
(i=0-3)
Node i Interrupt Signalling
Register
00128H+i
*400H
PNi
nBE
Kernel Reset
4011
CAN2_Ni_G0INT
R
(i=0-3)
Node i Interrupt routing for
Group 0
0012CH+
i*400H
PNi
PNi
Kernel Reset
4013
CAN2_Ni_G1INT
R
(i=0-3)
Node i Interrupt routing for
Group 1
00130H+i
*400H
PNi
PNi
Kernel Reset
4014
CAN2_Ni_G2INT
R
(i=0-3)
Node i Interrupt routing for
Group 2
00134H+i
*400H
PNi
PNi
Kernel Reset
4015
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4138
v1.1
2025-06-26


Table 1031
(continued) Register overview - CAN2 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN2_Ni_TIMER_
CCR
(i=0-3)
Node i Timer Clock Control
Register
00138H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN2_Ni_TIMER_
TXTRIG0
(i=0-3)
Node i Timer Transmit
Trigger 0 Register
0013CH+
i*400H
PNi
PNi
Kernel Reset
4016
CAN2_Ni_TIMER_
TXTRIG1
(i=0-3)
Node i Timer Transmit
Trigger 1 Register
00140H+i
*400H
PNi
PNi
Kernel Reset
4017
CAN2_Ni_TIMER_
TXTRIG2
(i=0-3)
Node i Timer Transmit
Trigger 2 Register
00144H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN2_Ni_TIMER_
RXTOUT
(i=0-3)
Node i Timer Receive
Timeout Register
00148H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN2_Ni_PORTC
TRL
(i=0-3)
Node i Port Control Register 0014CH+
i*400H
PNi
PNi
Kernel Reset
4019
CAN2_Ni_CRE_C
ONFIG
(i=0-3)
Node i CRE Configuration
Register
00150H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4158
CAN2_Ni_CRE_C
ONFIGADR
(i=0-3)
Node i CRE Configuration
Start Address
00154H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4022
CAN2_Ni_CRE_H
BUF_RXz_CONFI
G
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Configuration
00158H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4022
CAN2_Ni_CRE_H
BUF_RXz_STAT
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Status
0015CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4024
CAN2_Ni_CRE_H
BUF_TXz_CONFI
G
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Configuration
00168H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4025
CAN2_Ni_CRE_H
BUF_TXz_STAT
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Status
0016CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4026
CAN2_Ni_CRE_IR
(i=0-3)
Node i CRE Interrupt
Register
0018CH+
i*400H
PNi
PNi
Kernel Reset
4028
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4139
v1.1
2025-06-26


Table 1031
(continued) Register overview - CAN2 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN2_Ni_IDMU_
FRTCONFIG
(i=0-3)
Node i Frame Rate Measure
Table Configuration
00190H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4029
CAN2_Ni_IDMU_
RXTPCFG
(i=0-3)
Node i Rx Throughput
Measure configuration
00194H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4030
CAN2_Ni_ERRCT
RL
(i=0-3)
Node i CRE Error control
register
00198H+i
*400H
P4
SV, E, P4
Kernel Reset
4031
CAN2_Ni_CREL
(i=0-3)
Node i Core Release
Register
00200H+i
*400H
PNi
nBE
Kernel Reset
4032
CAN2_Ni_ENDN
(i=0-3)
Node i Endian Register
00204H+i
*400H
PNi
nBE
Kernel Reset
4033
CAN2_Ni_DBTP
(i=0-3)
Node i Data Bit Timing &
Prescaler Register
0020CH+
i*400H
PNi
PNi
4034
4034
CAN2_Ni_TEST
(i=0-3)
Node i Test Register
00210H+i
*400H
PNi
PNi
4035
4035
CAN2_Ni_RWD
(i=0-3)
Node i RAM Watchdog
00214H+i
*400H
PNi
PNi
Kernel Reset
4036
CAN2_Ni_CCCR
(i=0-3)
Node i CC Control Register
00218H+i
*400H
PNi
PNi
4037
4037
CAN2_Ni_NBTP
(i=0-3)
Node i Nominal Bit Timing
& Prescaler Register
0021CH+
i*400H
PNi
PNi
4040
4040
CAN2_Ni_TSCC
(i=0-3)
Node i Timestamp Counter
Configuration
00220H+i
*400H
PNi
PNi
Kernel Reset
4041
CAN2_Ni_TSCV
(i=0-3)
Node i Timestamp Counter
Value
00224H+i
*400H
PNi
PNi
Kernel Reset
4042
CAN2_Ni_TOCC
(i=0-3)
Node i Timeout Counter
Configuration
00228H+i
*400H
PNi
PNi
Kernel Reset
4043
CAN2_Ni_TOCV
(i=0-3)
Node i Timeout Counter
Value
0022CH+
i*400H
PNi
PNi
Kernel Reset
4044
CAN2_Ni_ECR
(i=0-3)
Node i Error Counter
Register
00240H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN2_Ni_PSR
(i=0-3)
Node i Protocol Status
Register
00244H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN2_Ni_TDCR
(i=0-3)
Node i Transmitter Delay
Compensation Register
00248H+i
*400H
PNi
PNi
Kernel Reset
4049
CAN2_Ni_IR
(i=0-3)
Node i Interrupt Register
00250H+i
*400H
PNi
PNi
Kernel Reset
4050
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4140
v1.1
2025-06-26


Table 1031
(continued) Register overview - CAN2 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN2_Ni_IE
(i=0-3)
Node i Interrupt Enable
00254H+i
*400H
PNi
PNi
Kernel Reset
4053
CAN2_Ni_GFC
(i=0-3)
Node i Global Filter
Configuration
00280H+i
*400H
PNi
PNi
Kernel Reset
4056
CAN2_Ni_SIDFC
(i=0-3)
Node i Standard ID Filter
Configuration
00284H+i
*400H
PNi
PNi
4057
4057
CAN2_Ni_XIDFC
(i=0-3)
Node i Extended ID Filter
Configuration
00288H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN2_Ni_XIDAM
(i=0-3)
Node i Extended ID AND
Mask
00290H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN2_Ni_HPMS
(i=0-3)
Node i High Priority
Message Status
00294H+i
*400H
PNi
nBE
Kernel Reset
4059
CAN2_Ni_NDAT1
(i=0-3)
Node i New Data 1
00298H+i
*400H
PNi
PNi
Kernel Reset
4060
CAN2_Ni_NDAT2
(i=0-3)
Node i New Data 2
0029CH+
i*400H
PNi
PNi
Kernel Reset
4060
CAN2_Ni_RXF0C
(i=0-3)
Node i Rx FIFO 0
Configuration
002A0H+
i*400H
PNi
PNi
Kernel Reset
4061
CAN2_Ni_RXF0S
(i=0-3)
Node i Rx FIFO 0 Status
002A4H+
i*400H
PNi
nBE
Kernel Reset
4062
CAN2_Ni_RXF0A
(i=0-3)
Node i Rx FIFO 0
Acknowledge
002A8H+
i*400H
PNi
PNi
Kernel Reset
4063
CAN2_Ni_RXBC
(i=0-3)
Node i Rx Buffer
Configuration
002ACH+
i*400H
PNi
PNi
4063
4063
CAN2_Ni_RXF1C
(i=0-3)
Node i Rx FIFO 1
Configuration
002B0H+
i*400H
PNi
PNi
Kernel Reset
4064
CAN2_Ni_RXF1S
(i=0-3)
Node i Rx FIFO 1 Status
002B4H+
i*400H
PNi
nBE
Kernel Reset
4065
CAN2_Ni_RXF1A
(i=0-3)
Node i Rx FIFO 1
Acknowledge
002B8H+
i*400H
PNi
PNi
Kernel Reset
4066
CAN2_Ni_RXESC
(i=0-3)
Node i Rx Buffer/FIFO
Element Size Configuration
002BCH+
i*400H
PNi
PNi
Kernel Reset
4067
CAN2_Ni_TXBC
(i=0-3)
Node i Tx Buffer
Configuration
002C0H+
i*400H
PNi
PNi
4068
4068
CAN2_Ni_TXFQS
(i=0-3)
Node i Tx FIFO/Queue
Status
002C4H+
i*400H
PNi
nBE
Kernel Reset
4069
CAN2_Ni_TXESC
(i=0-3)
Node i Tx Buffer Element
Size Configuration
002C8H+
i*400H
PNi
PNi
4070
4070
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4141
v1.1
2025-06-26


Table 1031
(continued) Register overview - CAN2 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN2_Ni_TXBRP
(i=0-3)
Node i Tx Buffer Request
Pending
002CCH+
i*400H
PNi
PNi
Kernel Reset
4072
CAN2_Ni_TXBAR
(i=0-3)
Node i Tx Buffer Add
Request
002D0H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN2_Ni_TXBCR
(i=0-3)
Node i Tx Buffer
Cancellation Request
002D4H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN2_Ni_TXBTO
(i=0-3)
Node i Tx Buffer
Transmission Occurred
002D8H+
i*400H
PNi
nBE
Kernel Reset
4074
CAN2_Ni_TXBCF
(i=0-3)
Node i Tx Buffer
Cancellation Finished
002DCH+
i*400H
PNi
nBE
Kernel Reset
4074
CAN2_Ni_TXBTIE
(i=0-3)
Node i Tx Buffer
Transmission Interrupt
Enable
002E0H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN2_Ni_TXBCIE
(i=0-3)
Node i Tx Buffer
Cancellation Finished
Interrupt Enable
002E4H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN2_Ni_TXEFC
(i=0-3)
Node i Tx Event FIFO
Configuration
002F0H+i
*400H
PNi
PNi
Kernel Reset
4076
CAN2_Ni_TXEFS
(i=0-3)
Node i Tx Event FIFO Status
002F4H+i
*400H
PNi
nBE
Kernel Reset
4077
CAN2_Ni_TXEFA
(i=0-3)
Node i Tx Event FIFO
Acknowledge
002F8H+i
*400H
PNi
PNi
Kernel Reset
4077
CAN2_Ni_TSU_C
REL
(i=0-3)
Node i TSU Core Release
Register
00360H+i
*400H
PNi
nBE
Kernel Reset
4078
CAN2_Ni_TSU_T
SCFG
(i=0)
(i=1-3)
Node i Timestamp
Configuration
00364H+i
*400H
PNi
PNi
Kernel Reset
4078
CAN2_Ni_TSU_T
SS1
(i=0-3)
Node i Timestamp Status 1
00368H+i
*400H
PNi
nBE
Kernel Reset
4080
CAN2_Ni_TSU_T
SS2
(i=0-3)
Node i Timestamp Status 2
0036CH+
i*400H
PNi
nBE
Kernel Reset
4081
CAN2_Ni_TSU_T
Sm
(i=0-3;m=0-15)
Node i Timestamp m
00370H+i
*400H+m
*4
PNi
nBE
Kernel Reset
4082
CAN2_Ni_TSU_A
TB
(i=0-3)
Node i Actual Timebase
003B0H+
i*400H
PNi
U
Kernel Reset
4082
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4142
v1.1
2025-06-26


21.11.4.7
Register overview - CAN3 domain SFR (ascending offset address)
Table 1032
Register overview - CAN3 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN3_CLC
Clock Control Register
00000H
P4
P4, SV, E
Application
Reset
4154
CAN3_OCS
OCDS Control and Status
Register
00004H
P4
SV, P4
Debug Reset
3990
CAN3_ID
Module Identification
Register
00008H
P4
BE
PowerOn Reset
3991
CAN3_RST_CTRL
A
Reset Control Register A
0000CH
P4
P4, SV, E
Application
Reset
3991
CAN3_RST_CTRL
B
Reset Control Register B
00010H
P4
P4, SV, E
Application
Reset
3992
CAN3_RST_STAT
Reset Status Register
00014H
P4
BE
Application
Reset
3993
CAN3_PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3993
CAN3_PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3995
CAN3_ACCEN_W
RA
Write access enable register
A
00030H
U
SE, SV
Application
Reset
3997
CAN3_ACCEN_W
RB
Write access enable register
B
00034H
U
SE, SV
Application
Reset
3997
CAN3_ACCEN_RD
A
Read access enable register
A
00038H
U
SE, SV
Application
Reset
3998
CAN3_ACCEN_RD
B
Read access enable register
B
0003CH
U
SE, SV
Application
Reset
3998
CAN3_ACCEN_V
M
VM access enable register
00040H
U
SE, SV
Application
Reset
3999
CAN3_ACCEN_PR
S
PRS access enable register
00044H
U
SE, SV
Application
Reset
3999
CAN3_MCR
Module Control Register
00070H
P4
P4
Kernel Reset
4156
CAN3_WDT
CRE Watchdog timer
register
00088H
P4
SV, E, P4
Kernel Reset
4006
CAN3_Ni_ACCEN
_WRA
(i=0-3)
Node i Write access enable
register A
00100H+i
*400H
U
SE, SV
Application
Reset
4007
CAN3_Ni_ACCEN
_WRB
(i=0-3)
Node i Write access enable
register B
00104H+i
*400H
U
SE, SV
Application
Reset
4008
CAN3_Ni_ACCEN
_RDA
(i=0-3)
Node i Read access enable
register A
00108H+i
*400H
U
SE, SV
Application
Reset
4008
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4143
v1.1
2025-06-26


Table 1032
(continued) Register overview - CAN3 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN3_Ni_ACCEN
_RDB
(i=0-3)
Node i Read access enable
register B
0010CH+
i*400H
U
SE, SV
Application
Reset
4009
CAN3_Ni_ACCEN
_VM
(i=0-3)
Node i VM access enable
register
00110H+i
*400H
U
SE, SV
Application
Reset
4009
CAN3_Ni_ACCEN
_PRS
(i=0-3)
Node i PRS access enable
register
00114H+i
*400H
U
SE, SV
Application
Reset
4010
CAN3_Ni_START
ADR
(i=0-3)
Node i Start Address
00120H+i
*400H
PNi
SV, E, PNi
Application
Reset
4010
CAN3_Ni_ENDAD
R
(i=0-3)
Node i End Address
00124H+i
*400H
PNi
SV, E, PNi
Application
Reset
4011
CAN3_Ni_INTRSI
G
(i=0-3)
Node i Interrupt Signalling
Register
00128H+i
*400H
PNi
nBE
Kernel Reset
4011
CAN3_Ni_G0INT
R
(i=0-3)
Node i Interrupt routing for
Group 0
0012CH+
i*400H
PNi
PNi
Kernel Reset
4013
CAN3_Ni_G1INT
R
(i=0-3)
Node i Interrupt routing for
Group 1
00130H+i
*400H
PNi
PNi
Kernel Reset
4014
CAN3_Ni_G2INT
R
(i=0-3)
Node i Interrupt routing for
Group 2
00134H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN3_Ni_TIMER_
CCR
(i=0-3)
Node i Timer Clock Control
Register
00138H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN3_Ni_TIMER_
TXTRIG0
(i=0-3)
Node i Timer Transmit
Trigger 0 Register
0013CH+
i*400H
PNi
PNi
Kernel Reset
4016
CAN3_Ni_TIMER_
TXTRIG1
(i=0-3)
Node i Timer Transmit
Trigger 1 Register
00140H+i
*400H
PNi
PNi
Kernel Reset
4017
CAN3_Ni_TIMER_
TXTRIG2
(i=0-3)
Node i Timer Transmit
Trigger 2 Register
00144H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN3_Ni_TIMER_
RXTOUT
(i=0-3)
Node i Timer Receive
Timeout Register
00148H+i
*400H
PNi
PNi
Kernel Reset
4018
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4144
v1.1
2025-06-26


Table 1032
(continued) Register overview - CAN3 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN3_Ni_PORTC
TRL
(i=0-3)
Node i Port Control Register 0014CH+
i*400H
PNi
PNi
Kernel Reset
4019
CAN3_Ni_CRE_C
ONFIG
(i=0-3)
Node i CRE Configuration
Register
00150H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4158
CAN3_Ni_CRE_C
ONFIGADR
(i=0-3)
Node i CRE Configuration
Start Address
00154H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4022
CAN3_Ni_CRE_H
BUF_RXz_CONFI
G
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Configuration
00158H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4022
CAN3_Ni_CRE_H
BUF_RXz_STAT
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Status
0015CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4024
CAN3_Ni_CRE_H
BUF_TXz_CONFI
G
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Configuration
00168H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4025
CAN3_Ni_CRE_H
BUF_TXz_STAT
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Status
0016CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4026
CAN3_Ni_CRE_IR
(i=0-3)
Node i CRE Interrupt
Register
0018CH+
i*400H
PNi
PNi
Kernel Reset
4028
CAN3_Ni_IDMU_
FRTCONFIG
(i=0-3)
Node i Frame Rate Measure
Table Configuration
00190H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4029
CAN3_Ni_IDMU_
RXTPCFG
(i=0-3)
Node i Rx Throughput
Measure configuration
00194H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4030
CAN3_Ni_ERRCT
RL
(i=0-3)
Node i CRE Error control
register
00198H+i
*400H
P4
SV, E, P4
Kernel Reset
4031
CAN3_Ni_CREL
(i=0-3)
Node i Core Release
Register
00200H+i
*400H
PNi
nBE
Kernel Reset
4032
CAN3_Ni_ENDN
(i=0-3)
Node i Endian Register
00204H+i
*400H
PNi
nBE
Kernel Reset
4033
CAN3_Ni_DBTP
(i=0-3)
Node i Data Bit Timing &
Prescaler Register
0020CH+
i*400H
PNi
PNi
4034
4034
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4145
v1.1
2025-06-26


Table 1032
(continued) Register overview - CAN3 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN3_Ni_TEST
(i=0-3)
Node i Test Register
00210H+i
*400H
PNi
PNi
4035
4035
CAN3_Ni_RWD
(i=0-3)
Node i RAM Watchdog
00214H+i
*400H
PNi
PNi
Kernel Reset
4036
CAN3_Ni_CCCR
(i=0-3)
Node i CC Control Register
00218H+i
*400H
PNi
PNi
4037
4037
CAN3_Ni_NBTP
(i=0-3)
Node i Nominal Bit Timing
& Prescaler Register
0021CH+
i*400H
PNi
PNi
4040
4040
CAN3_Ni_TSCC
(i=0-3)
Node i Timestamp Counter
Configuration
00220H+i
*400H
PNi
PNi
Kernel Reset
4041
CAN3_Ni_TSCV
(i=0-3)
Node i Timestamp Counter
Value
00224H+i
*400H
PNi
PNi
Kernel Reset
4042
CAN3_Ni_TOCC
(i=0-3)
Node i Timeout Counter
Configuration
00228H+i
*400H
PNi
PNi
Kernel Reset
4043
CAN3_Ni_TOCV
(i=0-3)
Node i Timeout Counter
Value
0022CH+
i*400H
PNi
PNi
Kernel Reset
4044
CAN3_Ni_ECR
(i=0-3)
Node i Error Counter
Register
00240H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN3_Ni_PSR
(i=0-3)
Node i Protocol Status
Register
00244H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN3_Ni_TDCR
(i=0-3)
Node i Transmitter Delay
Compensation Register
00248H+i
*400H
PNi
PNi
Kernel Reset
4049
CAN3_Ni_IR
(i=0-3)
Node i Interrupt Register
00250H+i
*400H
PNi
PNi
Kernel Reset
4050
CAN3_Ni_IE
(i=0-3)
Node i Interrupt Enable
00254H+i
*400H
PNi
PNi
Kernel Reset
4053
CAN3_Ni_GFC
(i=0-3)
Node i Global Filter
Configuration
00280H+i
*400H
PNi
PNi
Kernel Reset
4056
CAN3_Ni_SIDFC
(i=0-3)
Node i Standard ID Filter
Configuration
00284H+i
*400H
PNi
PNi
4057
4057
CAN3_Ni_XIDFC
(i=0-3)
Node i Extended ID Filter
Configuration
00288H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN3_Ni_XIDAM
(i=0-3)
Node i Extended ID AND
Mask
00290H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN3_Ni_HPMS
(i=0-3)
Node i High Priority
Message Status
00294H+i
*400H
PNi
nBE
Kernel Reset
4059
CAN3_Ni_NDAT1
(i=0-3)
Node i New Data 1
00298H+i
*400H
PNi
PNi
Kernel Reset
4060
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4146
v1.1
2025-06-26


Table 1032
(continued) Register overview - CAN3 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN3_Ni_NDAT2
(i=0-3)
Node i New Data 2
0029CH+
i*400H
PNi
PNi
Kernel Reset
4060
CAN3_Ni_RXF0C
(i=0-3)
Node i Rx FIFO 0
Configuration
002A0H+
i*400H
PNi
PNi
Kernel Reset
4061
CAN3_Ni_RXF0S
(i=0-3)
Node i Rx FIFO 0 Status
002A4H+
i*400H
PNi
nBE
Kernel Reset
4062
CAN3_Ni_RXF0A
(i=0-3)
Node i Rx FIFO 0
Acknowledge
002A8H+
i*400H
PNi
PNi
Kernel Reset
4063
CAN3_Ni_RXBC
(i=0-3)
Node i Rx Buffer
Configuration
002ACH+
i*400H
PNi
PNi
4063
4063
CAN3_Ni_RXF1C
(i=0-3)
Node i Rx FIFO 1
Configuration
002B0H+
i*400H
PNi
PNi
Kernel Reset
4064
CAN3_Ni_RXF1S
(i=0-3)
Node i Rx FIFO 1 Status
002B4H+
i*400H
PNi
nBE
Kernel Reset
4065
CAN3_Ni_RXF1A
(i=0-3)
Node i Rx FIFO 1
Acknowledge
002B8H+
i*400H
PNi
PNi
Kernel Reset
4066
CAN3_Ni_RXESC
(i=0-3)
Node i Rx Buffer/FIFO
Element Size Configuration
002BCH+
i*400H
PNi
PNi
Kernel Reset
4067
CAN3_Ni_TXBC
(i=0-3)
Node i Tx Buffer
Configuration
002C0H+
i*400H
PNi
PNi
4068
4068
CAN3_Ni_TXFQS
(i=0-3)
Node i Tx FIFO/Queue
Status
002C4H+
i*400H
PNi
nBE
Kernel Reset
4069
CAN3_Ni_TXESC
(i=0-3)
Node i Tx Buffer Element
Size Configuration
002C8H+
i*400H
PNi
PNi
4070
4070
CAN3_Ni_TXBRP
(i=0-3)
Node i Tx Buffer Request
Pending
002CCH+
i*400H
PNi
PNi
Kernel Reset
4072
CAN3_Ni_TXBAR
(i=0-3)
Node i Tx Buffer Add
Request
002D0H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN3_Ni_TXBCR
(i=0-3)
Node i Tx Buffer
Cancellation Request
002D4H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN3_Ni_TXBTO
(i=0-3)
Node i Tx Buffer
Transmission Occurred
002D8H+
i*400H
PNi
nBE
Kernel Reset
4074
CAN3_Ni_TXBCF
(i=0-3)
Node i Tx Buffer
Cancellation Finished
002DCH+
i*400H
PNi
nBE
Kernel Reset
4074
CAN3_Ni_TXBTIE
(i=0-3)
Node i Tx Buffer
Transmission Interrupt
Enable
002E0H+i
*400H
PNi
PNi
Kernel Reset
4075
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4147
v1.1
2025-06-26


Table 1032
(continued) Register overview - CAN3 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN3_Ni_TXBCIE
(i=0-3)
Node i Tx Buffer
Cancellation Finished
Interrupt Enable
002E4H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN3_Ni_TXEFC
(i=0-3)
Node i Tx Event FIFO
Configuration
002F0H+i
*400H
PNi
PNi
Kernel Reset
4076
CAN3_Ni_TXEFS
(i=0-3)
Node i Tx Event FIFO Status
002F4H+i
*400H
PNi
nBE
Kernel Reset
4077
CAN3_Ni_TXEFA
(i=0-3)
Node i Tx Event FIFO
Acknowledge
002F8H+i
*400H
PNi
PNi
Kernel Reset
4077
CAN3_Ni_TSU_C
REL
(i=0-3)
Node i TSU Core Release
Register
00360H+i
*400H
PNi
nBE
Kernel Reset
4078
CAN3_Ni_TSU_T
SCFG
(i=0)
(i=1-3)
Node i Timestamp
Configuration
00364H+i
*400H
PNi
PNi
Kernel Reset
4078
CAN3_Ni_TSU_T
SS1
(i=0-3)
Node i Timestamp Status 1
00368H+i
*400H
PNi
nBE
Kernel Reset
4080
CAN3_Ni_TSU_T
SS2
(i=0-3)
Node i Timestamp Status 2
0036CH+
i*400H
PNi
nBE
Kernel Reset
4081
CAN3_Ni_TSU_T
Sm
(i=0-3;m=0-15)
Node i Timestamp m
00370H+i
*400H+m
*4
PNi
nBE
Kernel Reset
4082
CAN3_Ni_TSU_A
TB
(i=0-3)
Node i Actual Timebase
003B0H+
i*400H
PNi
U
Kernel Reset
4082
21.11.4.8
Register overview - CAN4 domain SFR (ascending offset address)
Table 1033
Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_CLC
Clock Control Register
00000H
P4
P4, SV, E
Application
Reset
4154
CAN4_OCS
OCDS Control and Status
Register
00004H
P4
SV, P4
Debug Reset
3990
CAN4_ID
Module Identification
Register
00008H
P4
BE
PowerOn Reset
3991
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4148
v1.1
2025-06-26


Table 1033
(continued) Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_RST_CTRL
A
Reset Control Register A
0000CH
P4
P4, SV, E
Application
Reset
3991
CAN4_RST_CTRL
B
Reset Control Register B
00010H
P4
P4, SV, E
Application
Reset
3992
CAN4_RST_STAT
Reset Status Register
00014H
P4
BE
Application
Reset
3993
CAN4_PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3993
CAN4_PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3995
CAN4_ACCEN_W
RA
Write access enable register
A
00030H
U
SE, SV
Application
Reset
3997
CAN4_ACCEN_W
RB
Write access enable register
B
00034H
U
SE, SV
Application
Reset
3997
CAN4_ACCEN_RD
A
Read access enable register
A
00038H
U
SE, SV
Application
Reset
3998
CAN4_ACCEN_RD
B
Read access enable register
B
0003CH
U
SE, SV
Application
Reset
3998
CAN4_ACCEN_V
M
VM access enable register
00040H
U
SE, SV
Application
Reset
3999
CAN4_ACCEN_PR
S
PRS access enable register
00044H
U
SE, SV
Application
Reset
3999
CAN4_MCR
Module Control Register
00070H
P4
P4
Kernel Reset
4156
CAN4_WDT
CRE Watchdog timer
register
00088H
P4
SV, E, P4
Kernel Reset
4006
CAN4_Ni_ACCEN
_WRA
(i=0-3)
Node i Write access enable
register A
00100H+i
*400H
U
SE, SV
Application
Reset
4007
CAN4_Ni_ACCEN
_WRB
(i=0-3)
Node i Write access enable
register B
00104H+i
*400H
U
SE, SV
Application
Reset
4008
CAN4_Ni_ACCEN
_RDA
(i=0-3)
Node i Read access enable
register A
00108H+i
*400H
U
SE, SV
Application
Reset
4008
CAN4_Ni_ACCEN
_RDB
(i=0-3)
Node i Read access enable
register B
0010CH+
i*400H
U
SE, SV
Application
Reset
4009
CAN4_Ni_ACCEN
_VM
(i=0-3)
Node i VM access enable
register
00110H+i
*400H
U
SE, SV
Application
Reset
4009
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4149
v1.1
2025-06-26


Table 1033
(continued) Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_Ni_ACCEN
_PRS
(i=0-3)
Node i PRS access enable
register
00114H+i
*400H
U
SE, SV
Application
Reset
4010
CAN4_Ni_START
ADR
(i=0-3)
Node i Start Address
00120H+i
*400H
PNi
SV, E, PNi
Application
Reset
4010
CAN4_Ni_ENDAD
R
(i=0-3)
Node i End Address
00124H+i
*400H
PNi
SV, E, PNi
Application
Reset
4011
CAN4_Ni_INTRSI
G
(i=0-3)
Node i Interrupt Signalling
Register
00128H+i
*400H
PNi
nBE
Kernel Reset
4011
CAN4_Ni_G0INT
R
(i=0-3)
Node i Interrupt routing for
Group 0
0012CH+
i*400H
PNi
PNi
Kernel Reset
4013
CAN4_Ni_G1INT
R
(i=0-3)
Node i Interrupt routing for
Group 1
00130H+i
*400H
PNi
PNi
Kernel Reset
4014
CAN4_Ni_G2INT
R
(i=0-3)
Node i Interrupt routing for
Group 2
00134H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN4_Ni_TIMER_
CCR
(i=0-3)
Node i Timer Clock Control
Register
00138H+i
*400H
PNi
PNi
Kernel Reset
4015
CAN4_Ni_TIMER_
TXTRIG0
(i=0-3)
Node i Timer Transmit
Trigger 0 Register
0013CH+
i*400H
PNi
PNi
Kernel Reset
4016
CAN4_Ni_TIMER_
TXTRIG1
(i=0-3)
Node i Timer Transmit
Trigger 1 Register
00140H+i
*400H
PNi
PNi
Kernel Reset
4017
CAN4_Ni_TIMER_
TXTRIG2
(i=0-3)
Node i Timer Transmit
Trigger 2 Register
00144H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN4_Ni_TIMER_
RXTOUT
(i=0-3)
Node i Timer Receive
Timeout Register
00148H+i
*400H
PNi
PNi
Kernel Reset
4018
CAN4_Ni_PORTC
TRL
(i=0-3)
Node i Port Control Register 0014CH+
i*400H
PNi
PNi
Kernel Reset
4019
CAN4_Ni_CRE_C
ONFIG
(i=0-3)
Node i CRE Configuration
Register
00150H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4158
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4150
v1.1
2025-06-26


Table 1033
(continued) Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_Ni_CRE_C
ONFIGADR
(i=0-3)
Node i CRE Configuration
Start Address
00154H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4022
CAN4_Ni_CRE_H
BUF_RXz_CONFI
G
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Configuration
00158H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4022
CAN4_Ni_CRE_H
BUF_RXz_STAT
(i=0-3;z=0-1)
Node i Receive Host Buffer z
Status
0015CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4024
CAN4_Ni_CRE_H
BUF_TXz_CONFI
G
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Configuration
00168H+i
*400H+z*
8
PNi
PNi
Kernel Reset
4025
CAN4_Ni_CRE_H
BUF_TXz_STAT
(i=0-3;z=0-1)
Node i Transmit Host Buffer
z Status
0016CH+
i*400H+z
*8
PNi
PNi
Kernel Reset
4026
CAN4_Ni_CRE_IR
(i=0-3)
Node i CRE Interrupt
Register
0018CH+
i*400H
PNi
PNi
Kernel Reset
4028
CAN4_Ni_IDMU_
FRTCONFIG
(i=0-3)
Node i Frame Rate Measure
Table Configuration
00190H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4029
CAN4_Ni_IDMU_
RXTPCFG
(i=0-3)
Node i Rx Throughput
Measure configuration
00194H+i
*400H
PNi
SV, E, PNi
Kernel Reset
4030
CAN4_Ni_ERRCT
RL
(i=0-3)
Node i CRE Error control
register
00198H+i
*400H
P4
SV, E, P4
Kernel Reset
4031
CAN4_Ni_CREL
(i=0-3)
Node i Core Release
Register
00200H+i
*400H
PNi
nBE
Kernel Reset
4032
CAN4_Ni_ENDN
(i=0-3)
Node i Endian Register
00204H+i
*400H
PNi
nBE
Kernel Reset
4033
CAN4_Ni_DBTP
(i=0-3)
Node i Data Bit Timing &
Prescaler Register
0020CH+
i*400H
PNi
PNi
4034
4034
CAN4_Ni_TEST
(i=0-3)
Node i Test Register
00210H+i
*400H
PNi
PNi
4035
4035
CAN4_Ni_RWD
(i=0-3)
Node i RAM Watchdog
00214H+i
*400H
PNi
PNi
Kernel Reset
4036
CAN4_Ni_CCCR
(i=0-3)
Node i CC Control Register
00218H+i
*400H
PNi
PNi
4037
4037
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4151
v1.1
2025-06-26


Table 1033
(continued) Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_Ni_NBTP
(i=0-3)
Node i Nominal Bit Timing
& Prescaler Register
0021CH+
i*400H
PNi
PNi
4040
4040
CAN4_Ni_TSCC
(i=0-3)
Node i Timestamp Counter
Configuration
00220H+i
*400H
PNi
PNi
Kernel Reset
4041
CAN4_Ni_TSCV
(i=0-3)
Node i Timestamp Counter
Value
00224H+i
*400H
PNi
PNi
Kernel Reset
4042
CAN4_Ni_TOCC
(i=0-3)
Node i Timeout Counter
Configuration
00228H+i
*400H
PNi
PNi
Kernel Reset
4043
CAN4_Ni_TOCV
(i=0-3)
Node i Timeout Counter
Value
0022CH+
i*400H
PNi
PNi
Kernel Reset
4044
CAN4_Ni_ECR
(i=0-3)
Node i Error Counter
Register
00240H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN4_Ni_PSR
(i=0-3)
Node i Protocol Status
Register
00244H+i
*400H
PNi
nBE
Kernel Reset
4045
CAN4_Ni_TDCR
(i=0-3)
Node i Transmitter Delay
Compensation Register
00248H+i
*400H
PNi
PNi
Kernel Reset
4049
CAN4_Ni_IR
(i=0-3)
Node i Interrupt Register
00250H+i
*400H
PNi
PNi
Kernel Reset
4050
CAN4_Ni_IE
(i=0-3)
Node i Interrupt Enable
00254H+i
*400H
PNi
PNi
Kernel Reset
4053
CAN4_Ni_GFC
(i=0-3)
Node i Global Filter
Configuration
00280H+i
*400H
PNi
PNi
Kernel Reset
4056
CAN4_Ni_SIDFC
(i=0-3)
Node i Standard ID Filter
Configuration
00284H+i
*400H
PNi
PNi
4057
4057
CAN4_Ni_XIDFC
(i=0-3)
Node i Extended ID Filter
Configuration
00288H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN4_Ni_XIDAM
(i=0-3)
Node i Extended ID AND
Mask
00290H+i
*400H
PNi
PNi
Kernel Reset
4058
CAN4_Ni_HPMS
(i=0-3)
Node i High Priority
Message Status
00294H+i
*400H
PNi
nBE
Kernel Reset
4059
CAN4_Ni_NDAT1
(i=0-3)
Node i New Data 1
00298H+i
*400H
PNi
PNi
Kernel Reset
4060
CAN4_Ni_NDAT2
(i=0-3)
Node i New Data 2
0029CH+
i*400H
PNi
PNi
Kernel Reset
4060
CAN4_Ni_RXF0C
(i=0-3)
Node i Rx FIFO 0
Configuration
002A0H+
i*400H
PNi
PNi
Kernel Reset
4061
CAN4_Ni_RXF0S
(i=0-3)
Node i Rx FIFO 0 Status
002A4H+
i*400H
PNi
nBE
Kernel Reset
4062
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4152
v1.1
2025-06-26


Table 1033
(continued) Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_Ni_RXF0A
(i=0-3)
Node i Rx FIFO 0
Acknowledge
002A8H+
i*400H
PNi
PNi
Kernel Reset
4063
CAN4_Ni_RXBC
(i=0-3)
Node i Rx Buffer
Configuration
002ACH+
i*400H
PNi
PNi
4063
4063
CAN4_Ni_RXF1C
(i=0-3)
Node i Rx FIFO 1
Configuration
002B0H+
i*400H
PNi
PNi
Kernel Reset
4064
CAN4_Ni_RXF1S
(i=0-3)
Node i Rx FIFO 1 Status
002B4H+
i*400H
PNi
nBE
Kernel Reset
4065
CAN4_Ni_RXF1A
(i=0-3)
Node i Rx FIFO 1
Acknowledge
002B8H+
i*400H
PNi
PNi
Kernel Reset
4066
CAN4_Ni_RXESC
(i=0-3)
Node i Rx Buffer/FIFO
Element Size Configuration
002BCH+
i*400H
PNi
PNi
Kernel Reset
4067
CAN4_Ni_TXBC
(i=0-3)
Node i Tx Buffer
Configuration
002C0H+
i*400H
PNi
PNi
4068
4068
CAN4_Ni_TXFQS
(i=0-3)
Node i Tx FIFO/Queue
Status
002C4H+
i*400H
PNi
nBE
Kernel Reset
4069
CAN4_Ni_TXESC
(i=0-3)
Node i Tx Buffer Element
Size Configuration
002C8H+
i*400H
PNi
PNi
4070
4070
CAN4_Ni_TXBRP
(i=0-3)
Node i Tx Buffer Request
Pending
002CCH+
i*400H
PNi
PNi
Kernel Reset
4072
CAN4_Ni_TXBAR
(i=0-3)
Node i Tx Buffer Add
Request
002D0H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN4_Ni_TXBCR
(i=0-3)
Node i Tx Buffer
Cancellation Request
002D4H+
i*400H
PNi
PNi
Kernel Reset
4073
CAN4_Ni_TXBTO
(i=0-3)
Node i Tx Buffer
Transmission Occurred
002D8H+
i*400H
PNi
nBE
Kernel Reset
4074
CAN4_Ni_TXBCF
(i=0-3)
Node i Tx Buffer
Cancellation Finished
002DCH+
i*400H
PNi
nBE
Kernel Reset
4074
CAN4_Ni_TXBTIE
(i=0-3)
Node i Tx Buffer
Transmission Interrupt
Enable
002E0H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN4_Ni_TXBCIE
(i=0-3)
Node i Tx Buffer
Cancellation Finished
Interrupt Enable
002E4H+i
*400H
PNi
PNi
Kernel Reset
4075
CAN4_Ni_TXEFC
(i=0-3)
Node i Tx Event FIFO
Configuration
002F0H+i
*400H
PNi
PNi
Kernel Reset
4076
CAN4_Ni_TXEFS
(i=0-3)
Node i Tx Event FIFO Status
002F4H+i
*400H
PNi
nBE
Kernel Reset
4077
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4153
v1.1
2025-06-26


Table 1033
(continued) Register overview - CAN4 domain SFR (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
CAN4_Ni_TXEFA
(i=0-3)
Node i Tx Event FIFO
Acknowledge
002F8H+i
*400H
PNi
PNi
Kernel Reset
4077
CAN4_Ni_TSU_C
REL
(i=0-3)
Node i TSU Core Release
Register
00360H+i
*400H
PNi
nBE
Kernel Reset
4078
CAN4_Ni_TSU_T
SCFG
(i=0)
(i=1-3)
Node i Timestamp
Configuration
00364H+i
*400H
PNi
PNi
Kernel Reset
4078
CAN4_Ni_TSU_T
SS1
(i=0-3)
Node i Timestamp Status 1
00368H+i
*400H
PNi
nBE
Kernel Reset
4080
CAN4_Ni_TSU_T
SS2
(i=0-3)
Node i Timestamp Status 2
0036CH+
i*400H
PNi
nBE
Kernel Reset
4081
CAN4_Ni_TSU_T
Sm
(i=0-3;m=0-15)
Node i Timestamp m
00370H+i
*400H+m
*4
PNi
nBE
Kernel Reset
4082
CAN4_Ni_TSU_A
TB
(i=0-3)
Node i Actual Timebase
003B0H+
i*400H
PNi
U
Kernel Reset
4082
21.11.4.9
Clock Control Register (CANn=1-4)
The Clock Control Register CLC allows the programmer to adapt the functionality and power consumption of
the module to the requirements of the application.
Register CLC controls the module clock signal and the reactivity to the sleep signal.
CAN1_CLC
Offset address:
00000H
Clock Control Register
Application Reset value:
0000 0003H
CAN2_CLC
Offset address:
00000H
Clock Control Register
Application Reset value:
0000 0003H
CAN3_CLC
Offset address:
00000H
Clock Control Register
Application Reset value:
0000 0003H
CAN4_CLC
Offset address:
00000H
Clock Control Register
Application Reset value:
0000 0003H
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4154
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
Used for enable/disable control of the module. The synchronous and
asynchronous clock is switched on/off. Note that no register access is
possible to any register while module is disabled. A disable request is
granted, if the M_CAN clock is disabled, or all M_CAN nodes
acknowledge the disable request.
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
Sleep Mode Enable Control
Used to control the module’s reaction to sleep mode.
0B Sleep mode request is enabled and functional
1B Module disregards the sleep mode control signal
0
2,
31:4
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4155
v1.1
2025-06-26


21.11.4.10
Module Control Register (CANn=1-4)
The Module Control Register MCR contains basic settings that determine the operation of the MCMCAN module.
The write access to the lowest byte of the MCR register becomes only valid, if and only if, MCR.CCCE and MCR.CI
are already set during write access. To switch the clocks on or off, the bits of MCR.CCCE and MCR.CI have to be
reset afterwards. Before this sequence hasn’t taken place, no write access to the corresponding nodes, can be
done.
Note:
If the baud rate logic is supplied from an unstable clock source, or no clock at all, the CAN
functionality is not guaranteed.
To be able to change the clock settings the following programming sequence needs to be met:
uwTemp = CANn_MCR.U;
uwTemp |= (0xC0000000 | CLKSELx);
CANn_MCR.U = uwTemp;
uwTemp &= ~0xC0000000;
CANn_MCR.U = uwTemp;
The clock settings for CAN nodes becomes active.
To be able to start the RAM initialization, the following programming sequence need to be met:
CANn_MCR |= 0xC0000000;
Wait until CANn_MCR.RBUSY is 0b
Set CANn_MCR.RINIT to 0b
Set CANn_MCR.RINIT to 1b
Dummy read CANn_MCR
Wait until CANn_MCR.RBUSY is 0b
Set CANn_MCR.RINIT to 0b
CANn_MCR &= ~0xC0000000;
RAM initialization is finished
CAN1_MCR
Offset address:
00070H
Module Control Register
Kernel Reset value:
0000 0000H
CAN2_MCR
Offset address:
00070H
Module Control Register
Kernel Reset value:
0000 0000H
CAN3_MCR
Offset address:
00070H
Module Control Register
Kernel Reset value:
0000 0000H
CAN4_MCR
Offset address:
00070H
Module Control Register
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
CCCE
CI
RINI
T
RBU
SY
0
0
rw
rw
rw
rh
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
0
CLKSEL3
CLKSEL2
CLKSEL1
CLKSEL0
r
rw
rw
rw
rw
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4156
v1.1
2025-06-26


Field
Bits
Type
Description
CLKSEL0
1:0
rw
Clock Select 0
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
CLKSEL1
3:2
rw
Clock Select 1
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
CLKSEL2
5:4
rw
Clock Select 2
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
CLKSEL3
7:6
rw
Clock Select 3
This bit-field is MCR.CI and MCR.CCCE protected.
00B No clock supplied
01B The asynchronous clock source is switched on
10B The synchronous clock source is switched on
11B Both clock sources are switched on
RBUSY
28
rh
RAM BUSY
This bit shows that the RAM Initialization is running. This bit is set back
to 0b by hardware when the RAM intialization is completed.
RINIT
29
rw
RAM Init
This bit is MCR.CI and MCR.CCCE protected.
This bit starts the initialization of the RAM block to all 0x0.
The RAM initialization is started only when this bit is changed from 0b
to 1b and also RBUSY is 0b.
CI
30
rw
Change Init
Needs to be set to enable and disable clocks.
0B Change Init disabled
1B Change Init enabled (takes effect with CCCE:=1)
CCCE
31
rw
Clock and RAM Change Enable
Needs to be set to enable and disable the clocks.
0B Clock and RAM Change disabled
1B Clock and RAM Change enabled (takes effect with CI:=1)
0
23:8,
27:24
r
Reserved
Shall read 0; shall be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4157
v1.1
2025-06-26


21.11.4.11
Node i CRE Configuration Register (CANn=1-4;i=0) (CANn=1-4;i=1)
(CANn=1-2;i=2)
The Node i CRE Configuration Register Ni_CRE_CONFIG configures the Routing Engine functionality.
CAN1_Ni_CRE_CONFIG (i=0)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0500H
CAN2_Ni_CRE_CONFIG (i=0)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0900H
CAN3_Ni_CRE_CONFIG (i=0)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0D00H
CAN4_Ni_CRE_CONFIG (i=0)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 1100H
CAN1_Ni_CRE_CONFIG (i=1)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0600H
CAN2_Ni_CRE_CONFIG (i=1)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0A00H
CAN3_Ni_CRE_CONFIG (i=1)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0E00H
CAN4_Ni_CRE_CONFIG (i=1)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 1200H
CAN1_Ni_CRE_CONFIG (i=2)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0700H
CAN2_Ni_CRE_CONFIG (i=2)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0B00H
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
ID
0
DEN
IDM
UEN
REN
EN
r
r
r
rw
rw
rw
rw
Field
Bits
Type
Description
EN
0
rw
Enable
Note: When the EN is set, the respective host buffers are enabled. The
RxFIFO0/1 and Tx FIFO/Queues shall not be used in this case. The
frames are read/written from/to CRE host buffers instead.
0B DIS: CRE function is disabled
1B EN: CRE function is enabled. When CRE is enabled, then RxFIFO0/1
and TxFIFO/Queue host interface handling is also enabled when
corresponding FIFO/Queue are enabled by CAN node
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4158
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
REN
1
rw
Routing Enable
This bit indicates that the Routing is enabled for the Source node. This
bit is checked only at the Source node. This bit-field can be written only
when Ni_CRE_CONFIG.EN = 1.
Note: This bit should be enabled at the source node for correct routing
0B DIS: Routing Disable
The Routing function of CRE is disabled. Note: If Ni_CRE_CFG.EN is
set, the corresponding host buffers are still enabled.
1B EN: Routing Enable
The Routing function of CRE is enabled for the Source CAN node
IDMUEN
2
rw
IDMU Enable
This bit-field can be written only when Ni_CRE_CFG.EN = 1
0B DIS: IDMU Disable
The Intrusion detection measurement unit (IDMU) of CRE is
disabled
1B EN: IDMU Enable
The Intrusion detection measurement unit (IDMU) of CRE is
enabled
DEN
3
rw
Destination Enable
This bit is checked only at the Destination node. This bit controls the
CRE write of the CAN frame to TxFIFO
Note: In case of external routing, the CAN frame remains in the Tx Host
Buffer and there will be no re-trigger to the DRE if DEN is set to 0 after
there has already been a trigger to the DRE. In case of internal routing,
the CAN frame would be discarded if DEN is set to 0
0B DIS: Destination Disable
The CAN frame is discarded
1B EN: Destination Enable
The CRE will write the CAN frame to the TxFIFO
ID
13:8
r
Unique ID
A Unique ID of the CAN Node i
1H till 4H - MCMCAN 0 CAN Node 0-Node 3 respectively
5H till 8H - MCMCAN 1 CAN Node 0-Node 3 respectively
9H till CH - MCMCAN 2 CAN Node 0-Node 3 respectively
DH till 10H - MCMCAN 3 CAN Node 0-Node 3 respectively
11H till 14H - MCMCAN 4 CAN Node 0-Node 3 respectively
0
7:4,
31:14
r
Reserved
Read as 0; shall be written with 0.
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4159
v1.1
2025-06-26


21.11.4.12
Node i CRE Configuration Register (CANn=1-4;i=3) (CANn=3-4;i=2)
CAN3_Ni_CRE_CONFIG (i=2)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0F00H
CAN4_Ni_CRE_CONFIG (i=2)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 1300H
CAN1_Ni_CRE_CONFIG (i=3)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0800H
CAN2_Ni_CRE_CONFIG (i=3)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 0C00H
CAN3_Ni_CRE_CONFIG (i=3)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 1000H
CAN4_Ni_CRE_CONFIG (i=3)
Offset address:
00150H+i*400H
Node i CRE Configuration Register
Kernel Reset value:
0000 1400H
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
ID
0
DEN
IDM
UEN
REN
EN
r
r
r
rw
rw
rw
rw
Field
Bits
Type
Description
EN
0
rw
Enable
Note: When the EN is set, the respective host buffers are enabled. The
RxFIFO0/1 and Tx FIFO/Queues shall not be used in this case. The
frames are read/written from/to CRE host buffers instead.
0B DIS: CRE function is disabled
1B EN: CRE function is enabled. When CRE is enabled, then RxFIFO0/1
and TxFIFO/Queue host interface handling is also enabled when
corresponding FIFO/Queue are enabled by CAN node
REN
1
rw
Routing Enable
This bit indicates that the Routing is enabled for the Source node. This
bit is checked only at the Source node. This bit-field can be written only
when Ni_CRE_CONFIG.EN = 1.
Note: This bit should be enabled at the source node for correct routing
0B DIS: Routing Disable
The Routing function of CRE is disabled. Note: If Ni_CRE_CFG.EN is
set, the corresponding host buffers are still enabled.
1B EN: Routing Enable
The Routing function of CRE is enabled for the Source CAN node
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4160
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
IDMUEN
2
rw
IDMU Enable
This bit-field can be written only when Ni_CRE_CFG.EN = 1
0B DIS: IDMU Disable
The Intrusion detection measurement unit (IDMU) of CRE is
disabled
1B EN: IDMU Enable
The Intrusion detection measurement unit (IDMU) of CRE is
enabled
DEN
3
rw
Destination Enable
This bit is checked only at the Destination node. This bit controls the
CRE write of the CAN frame to TxFIFO
Note: In case of external routing, the CAN frame remains in the Tx Host
Buffer and there will be no re-trigger to the DRE if DEN is set to 0 after
there has already been a trigger to the DRE. In case of internal routing,
the CAN frame would be discarded if DEN is set to 0
0B DIS: Destination Disable
The CAN frame is discarded
1B EN: Destination Enable
The CRE will write the CAN frame to the TxFIFO
ID
13:8
r
Unique ID
A Unique ID of the CAN Node i
1H till 4H - MCMCAN 0 CAN Node 0-Node 3 respectively
5H till 8H - MCMCAN 1 CAN Node 0-Node 3 respectively
9H till CH - MCMCAN 2 CAN Node 0-Node 3 respectively
DH till 10H - MCMCAN 3 CAN Node 0-Node 3 respectively
11H till 14H - MCMCAN 4 CAN Node 0-Node 3 respectively
0
7:4,
31:14
r
Reserved
Read as 0; shall be written with 0.
21.11.5
TC4Dx CAN connectivity
The table below lists interfaces to and from this functional block to other blocks in the device.
Table 1034
List of CAN interface signals
Interface signals
I/O
Description
CLOCK_CAN_fSPB
In
SPB clock input
CLOCK_CAN_fMCAN
In
MCAN asynchronous clock input
CLOCK_CAN_fMCANH
In
MCANH synchronous clock input
FPI_CAN_SIF
In
Slave interface
CPU0_CAN0_Nx_TRIG
In
STM Service Request 0 transmit trigger input for node x
CPU0_CAN1_Nx_TRIG
In
STM Service Request 0 transmit trigger input for node x
CPU0_CAN2_Nx_TRIG
In
STM Service Request 0 transmit trigger input for node x
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4161
v1.1
2025-06-26


Table 1034
(continued) List of CAN interface signals
Interface signals
I/O
Description
CPU0_CAN3_Nx_TRIG
In
STM Service Request 0 transmit trigger input for node x
CPU0_CAN4_Nx_TRIG
In
STM Service Request 0 transmit trigger input for node x
EGTM_CAN0_Nx_TRIG[3:0]
In
eGTM transmit trigger input for node x (x=0-3)
EGTM_CAN1_Nx_TRIG[3:0]
In
eGTM transmit trigger input for node x (x=0-3)
EGTM_CAN2_Nx_TRIG[3:0]
In
eGTM transmit trigger input for node x (x=0-3)
EGTM_CAN3_Nx_TRIG[3:0]
In
eGTM transmit trigger input for node x (x=0-3)
EGTM_CAN4_Nx_TRIG[3:0]
In
eGTM transmit trigger input for node x (x=0-3)
PORTS_CAN0_node[3:0]_RXD[7:0]
In
CAN0 node x receive inputs
PORTS_CAN1_node[3:0]_RXD[7:0]
In
CAN1 node x receive inputs
PORTS_CAN2_node[3:0]_RXD[7:0]
In
CAN2 node x receive inputs
PORTS_CAN3_node[3:0]_RXD[7:0]
In
CAN3 node x receive inputs
PORTS_CAN4_node[3:0]_RXD[7:0]
In
CAN4 node x receive inputs
CAN0_PORTS_node[3:0]_TXD
Out
CAN0 node x transmit outputs
CAN1_PORTS_node[3:0]_TXD
Out
CAN1 node x transmit outputs
CAN2_PORTS_node[3:0]_TXD
Out
CAN2 node x transmit outputs
CAN3_PORTS_node[3:0]_TXD
Out
CAN3 node x transmit outputs
CAN4_PORTS_node[3:0]_TXD
Out
CAN4 node x transmit outputs
CAN0_IR_SRC_CANINT[15:0]
Out
CAN0 Service Request
CAN1_IR_SRC_CANINT[15:0]
Out
CAN1 Service Request
CAN2_IR_SRC_CANINT[15:0]
Out
CAN2 Service Request
CAN3_IR_SRC_CANINT[15:0]
Out
CAN3 Service Request
CAN4_IR_SRC_CANINT[15:0]
Out
CAN4 Service Request
CAN0_EGTM_SRC_CANINT[15:12]
Out
CAN0 Service Request to eGTM
CAN1_EGTM_SRC_CANINT[15:12]
Out
CAN1 Service Request to eGTM
CAN2_EGTM_SRC_CANINT[15:12]
Out
CAN2 Service Request to eGTM
CAN3_EGTM_SRC_CANINT[15:12]
Out
CAN3 Service Request to eGTM
CAN4_EGTM_SRC_CANINT[15:12]
Out
CAN4 Service Request to eGTM
CAN0_DRE_TRIGTYPE[1:0]
Out
Trigger event corresponding to a host buffer
CAN1_DRE_TRIGTYPE[1:0]
Out
Trigger event corresponding to a host buffer
CAN2_DRE_TRIGTYPE[1:0]
Out
Trigger event corresponding to a host buffer
CAN3_DRE_TRIGTYPE[1:0]
Out
Trigger event corresponding to a host buffer
CAN4_DRE_TRIGTYPE[1:0]
Out
Trigger event corresponding to a host buffer
CAN0_DRE_TRIGNODE[1:0]
Out
CAN0 node to which host buffer belongs
(table continues...)
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4162
v1.1
2025-06-26


Table 1034
(continued) List of CAN interface signals
Interface signals
I/O
Description
CAN1_DRE_TRIGNODE[1:0]
Out
CAN1 node to which host buffer belongs
CAN2_DRE_TRIGNODE[1:0]
Out
CAN2 node to which host buffer belongs
CAN3_DRE_TRIGNODE[1:0]
Out
CAN3 node to which host buffer belongs
CAN4_DRE_TRIGNODE[1:0]
Out
CAN4 node to which host buffer belongs
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4163
v1.1
2025-06-26


21.11.6
TC4Dx CAN revision history
Reference
Description of change(s)
Date range: 2024-08-17 to 2024-11-27
Module Control Register
(CANn=1-4)
•
Removing misplaced paragraphs from MCR register description
 
 
AURIX™ TC4Dx user manual 
21  Controller Area Network interface (CAN)
Reference manual
4164
v1.1
2025-06-26
