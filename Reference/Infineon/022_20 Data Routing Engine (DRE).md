# 20 Data Routing Engine (DRE)

20
Data Routing Engine (DRE)
The DRE is a hardware accelerator used to route Controller Area Network (CAN) frames and Ethernet frames.
The DRE routes CAN frames between Ethernet interfaces. Additionally, it can assist in routing CAN frames from
one CAN interface to another CAN interface or to a user-configured memory location, and in forwarding
Ethernet frames between Ethernet interfaces.
The DRE is aligned to the AVTP Control frame format defined by IEEE 1722-2016.
In this chapter the following notations from IEEE 1722-2016 are used:
•
AVTP frame refers to an Ethernet frame containing Audio Video Transport Protocol
•
ACF (AVTP Control Format) frame refers to an AVTP frame containing control frames
•
ACF_CAN_BRIEF message refers to CAN frames contained within an ACF frame
The following chapters describe the core elements of the DRE, their role in routing/forwarding and the
configuration possibilities
20.1
Feature list
•
Routes Controller Area Network (CAN) frames to or from Ethernet interfaces using IEEE 1722 ACF frames
-
Supports different Ethernet transmit trigger modes
-
User-configured Ethernet MAC Header (Layer 2) for ACF transmit frames
-
Automatic Ethernet DMA transmit and receive descriptor handling
-
Configurable AVTP stream-ID
-
CAN-ID based CAN interface destination search
-
Filtering of CAN frames tunneled over Ethernet
-
User-configured CAN Routing Table to identify the destination CAN interface for a CAN frame tunneled
over Ethernet
•
Assists CAN Routing Engine (CRE) to perform inter-MCMCAN transfer of CAN frames from a CAN interface to
another CAN interface
•
Assists CRE to perform routing of received CAN frame(s) or CAN I-PDU(s) from a CAN interface to a
configurable internal memory address location
-
Automatic memory address increment and wrap around
-
User-configured watermark interrupt generation for CPU notification
•
Supports 1:1 uni-cast routing and 1:4 multi-cast Ethernet to CAN routing
•
Provides non-starving arbitration between routing transfer requests
•
Supports 1:1 uni-cast or 1:6 multi-cast forwarding of Ethernet frames between interfaces
•
Provides non-starving arbitration between routing and forwarding requests
•
Provides error monitoring mechanisms for accelerated detection of faults
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3721
v1.1
2025-06-26


20.2
Functional overview
The DRE block diagram is shown in the following figure:
IEEE 1722a AVTP ACF CAN - Ethernet
Format Engine
Ethernet Descriptor Handler
Routing 
Control 
Unit
CAN Transmit 
Routing Engine
DRE
CRE service 
request
Configuration 
registers
Interrupt 
request
TRIGTYPE [1:0]
TRIGNODE [1:0]
SRI Slave
fSRI
16
FPI Master
fSPB
SRI Master
fSRI
Message RAM
RAM Access Arbiter
Forwarding 
Engine
DREw
IR
Ethernet 
Input 
Buffers
Ethernet 
Output 
Buffers
CAN 
Output 
Buffer 
List
Ethernet
Tx & Rx 
Descriptor
List
CAN 
Transmit 
Routing 
Table
CAN 
Address 
Database
Ethernet 
Forwarding 
Table
CAN 
Input 
Buffer 
List
Ethernet 
Address 
Database
DMEM 
Parameter 
Table
S
M
U
2
Alarms
MCMCANx
Message Controller
Figure 329
DRE block diagram
For the alarm description please refer to the alarm mapping tables in the SMU functional block and the Safety
Manual.
•
The DRE contains a central message storage RAM which buffers the CAN frames and the Ethernet frames
•
The Routing Control Unit assists in the transfer of received CAN frames from the MCMCAN module to the
internal message RAM. The Routing Control Unit also transfers the CAN frame to the identified CAN
interface for transmission
•
The ACF CAN - Ethernet Format Engine performs the translation of CAN frames to ACF frame format and
vice versa
•
The CAN Transmit Routing Engine, along with a user-configured Routing Table, decides the destination CAN
interface from which a CAN frame has to be transmitted. The Routing Control Unit also transfers the CAN
frame to the identified CAN interface for transmission
•
The Ethernet Descriptor Handler maintains the Ethernet Transmit (Tx) and Receive (Rx) descriptors which
will then be used by Ethernet DMA or the software to transmit or receive Ethernet frames
•
The Forwarding Engine, along with a user-configured Forwarding Table, decides the destination Ethernet
interface(s) to which the Ethernet frame has to be forwarded
20.3
Functional description
The following sections describe in detail the functions of the DRE.
20.4
Message controller
The Message Controller manages the CAN and Ethernet frame buffers in the Message RAM and arbitrates the
RAM accesses.
The image in the chapter Functional overview below shows the Message Controller relative to the DRE Message
RAM.
The Message RAM stores control information and CAN and Ethernet data. The SRI Slave accesses are always
given the highest priority followed by the MCMCAN module accesses. All the RAM accesses by other control logic
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3722
v1.1
2025-06-26


of the DRE are arbitrated with equal priority. Read and write accesses to the Message RAM are of up to 64-bit
data width.
20.4.1
Feature list
•
Message RAM is of size 32 Kbytes (4 kwords x 64 bits) for buffering frame data and control information as
follows:
-
CAN frames received from CAN interface - CAN Input Buffer List to buffer maximum of 20 CAN frames
(as there are a total of 20 CAN interfaces)
-
CAN Address Database for address and control configuration of CAN Receive Host Buffers and CAN
Transmit Host Buffers
-
Ethernet Address Database for address configuration of LETH and GETH DMA channels
-
Ethernet Input Buffers having 192 double words each can be used to store Ethernet frames received
from Ethernet interfaces
-
CAN frames to be transmitted to CAN interface in CAN Output Buffer List; stores a maximum of 64 CAN
frames
-
Ethernet Output Buffers having 192 double words each can be used to store Ethernet frames received
from Ethernet interfaces
-
CAN Transmit Routing Tables (1 to 4); each routing table can accommodate a maximum of 128 routing
rules
-
Ethernet Transmit (Tx) and Receive (Rx) Descriptor List
-
Ethernet Forwarding Table with a maximum of 128 forwarding rules
-
DMEM Parameter Table that consists of configuration of 28 memory destinations
•
Management of message buffers and routing control information
•
Allows direct access of Message RAM for application software through SRI Slave interface for monitoring
•
Arbitration of RAM accesses
20.4.2
Functional overview
This chapter describes the contents of the DRE Message RAM.
Message RAM
The contents of the Message RAM and its interfaces are shown in the figure below.
CAN Input 
Buffer List
1
2
Max. 20
CAN Output  
Buffer List  
1
2
Max. 64
Message RAM
Routing Control 
Unit
ACF CAN - ETH
Format Engine
S_SRI 
(Written by ETH 
DMA or SW)
ACF CAN - ETH
Format Engine
S_SRI 
(SW Configuration)
ETH Descriptor Handler
ACF CAN - ETH
Format Engine
Routing 
Control Unit
ACF CAN - ETH
Format Engine
S_SRI 
(Read by ETH 
DMA or SW)
CAN Transmit 
Routing Engine
S_SRI 
(Read & Write-back by 
ETH DMA or SW)
Message Controller
64
64
64
64
64
64
RCU_RIF
ACF_RIF
Host_RIF
ACF_RIF
Host_RIF
DESC_RIF
64
64
64
64
64
64
ACF_RIF
ACF_RIF
RCU_RIF
Host_RIF
CTRE_RIF
Host_RIF
CAN Address 
Database 
(CAD_)
CAN0_CRESA
CAN1_CRESA
CAN19_CRESA
S_SRI 
(SW Configuration)
64
Routing 
Control Unit
64
RCU_RIF
Ethernet
Forwarding Table
1
2
Max. 128
S_SRI 
(SW Configuration)
64
Host_RIF
Forwarding Engine
64
FE_RIF
64
Host_RIF
S_SRI 
(Read by ETH 
DMA or SW)
Ethernet
Address Database 
(EAD_)
LETH0_TXDMA
LETH0_RXDMA
GETHx_RXDMA
12 Addresses
S_SRI 
(SW Configuration)
64
ETH Descriptor 
Handler
64
DESC_RIF
DMEM 
Parameter Table
DMEM0
DMEM1
DMEM27
S_SRI 
(SW Configuration)
64
Routing 
Control Unit
64
RCU_RIF
Ethernet
Rx Descriptor List
1
2
Max. 24
Ethernet
Tx Descriptor List
1
2
Max. 24
CAN Transmit 
Routing Table
1 to 4
1
2
Max. 128
Ethernet
Output Buffer
1
Max. 6
Ethernet
Input Buffer
1
Max. 6
Figure 330
Message RAM block diagram
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3723
v1.1
2025-06-26


The Message RAM contains the following buffers and control information:
•
CAN Address Database (CAD)
•
CAN Input Buffer List (CIBL)
•
CAN Output Buffer List (COBL)
•
Ethernet Input Buffers (EIBUF)
•
Ethernet Output Buffers (EOBUF)
•
CAN Transmit Routing Tables (1 to 4)
•
Ethernet Descriptor Lists (Tx and Rx)
•
Ethernet Forwarding Table
•
Ethernet Address Database (EAD)
•
DMEM Parameter Table
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3724
v1.1
2025-06-26


20.4.3
Functional description
The following section describes the configuration and contents of DRE Message RAM.
Fixed setup of Message RAM layout
CAN Address Database
(20 elements)
DRE Message RAM layout
DRE RAM start address + 0x00
CAN Input Buffer List
(20 elements)
Fixed
20 double words
0
63
Fixed
200 double words
+ 0xA0
+ 0x6E0
CAN Output Buffer List
(64 elements)
Fixed
640 double words
+ 0x1AE0
CAN Transmit Routing Tables
(Up to 4 tables with maximum 128 routing elements)
Fixed
512 double words
+ 0x2AE0
Ethernet Address Database
(6 elements)
Fixed
6 double words
+ 0x2B40
EOBUF 0
(192 double words)
Tx Descriptor List 0
(8 double words)
Rx Descriptor List 0
(8 double words)
EIBUF 0
(192 double words)
+ 0x3140
+ 0x3180
+ 0x31C0
+ 0x37C0
Fixed
400 double words
Ethernet buffers and descriptors 1
Ethernet buffers and descriptors j 
(j = Number of Ethernet MACs - 1)
Ethernet buffers and 
descriptors 0
+ 0x4440
Fixed
400 * j double words
Max. 2000 double words
+ 0x7640
Ethernet Forwarding Table
(maximum 128 forwarding elements)
Configurable up to
128 double words
+ 0x7A40
DMEM Parameter Table
(28 elements)
Fixed
56 double words
+ 0x69C0
Reserved
+ 0x2B10
+ 0x1EE0
Figure 331
Setup of Message RAM layout
Note:
The Message RAM is not accessible during Kernel reset
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3725
v1.1
2025-06-26


20.4.3.1
CAN address database
The CAN Address Database (CAD) contains the control and address configuration of the CRE Receive host
buffers and the Transmit Host Buffers.
The CRE of the CAN peripherals (refer to CAN chapter for detailed information) contains host buffers for Receive
and Transmit CAN frames. The CAD needs to be configured by the user in order for the DRE to perform routing
operations to or from CAN peripherals. The database is stored in the Message RAM of the DRE and always starts
at the offset 0H. The structure of the database is given in the figure below.
DRE Message RAM
CAN Address Database (CAD)
CAD_CAN0_CRESA
DRE RAM start address
+  0x0
+  0x8
+  0x98
GAP
0
63
31
32
CAD_CAN1_CRESA
GAP
CAD_CAN19_CRESA
GAP
1 element = 8 bytes
Total 
20 elements = 160 bytes
Figure 332
CAN address database RAM structure
Each CAD element contains the following configurations for the corresponding CAN peripheral:
•
The absolute start address of the CRE address space (CAD_CANi_CRESA.ADR)
Related information
CAN input buffer list on page 3726
CAN output buffer list on page 3728
Routing control unit on page 3760
20.4.3.2
CAN input buffer list
The CAN Input Buffer List stores the CAN frames received by CAN interfaces which are to be transmitted through
ACF Ethernet frames. The Routing Control Unit transfers the received CAN frames with destination ID = 18H to
ID = 1DH from MCMCAN to the CAN Input Buffer List.
The start address of the CAN Input Buffer List is DRE RAM start address + 0xA0. There are a total of 20 CAN input
buffers. Each buffer stores 16 bytes of header data and 64 CAN data bytes. The structure of the buffers is shown
in the figure below.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3726
v1.1
2025-06-26


CAN Input Buffer List 
(CIBL)
CIBL start address (absolute) = 
DRE RAM start address + 0xA0
+  0x0  
+  0x50
0
63
31
32
CIBUF0
1 Buffer size  = 16 bytes header + 
64 bytes CAN payload
Number of CIBUF = 20
CIBL max. size = 1600 bytes
CIBUF1
CIBUF19
CIBUF0_RHEAD
CIBUF0_CRC
CIBUF0_R0
CIBUF0_R1
CIBUF0_DB3 – DB0
CIBUF0_DB7 – DB4
CIBUF0_DB59 – DB56
CIBUF0_DB63 – DB60
Figure 333
RAM structure of CAN input buffer list
The buffers are organized in the form of a circular list. The list contains a Put Index (CIBL_STATUS.PIDX).
The Put Index is controlled by the Message Controller. A new CAN frame is stored in the buffer indexed by the
Put Index. The Put Index is incremented to the next free buffer after storing the CAN frame. The Put Index wraps
around to the next free buffer starting from index 0 after it has reached the maximum number of assigned
buffers in the list. The buffer pending request (BPR) in CIBL_BPR is set by hardware to indicate that the CAN
buffer contains a frame yet to be processed by the ACF CAN-Ethernet Format Engine.
The pending requests are scanned by the ACF CAN-Ethernet Format Engine to identify the CAN frame to be
processed. After processing the identified CAN frame, the pending request is cleared by the ACF CAN-Ethernet
Format Engine.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3727
v1.1
2025-06-26


M1
M2
M3
M4
M5
M6
M7
Buffer Index
0
1
2
3
4
5
6
7
Put Index
1
0
1
1
0
1
1
0
Arrival of new CAN message – M8
Initial Buffer State
M1
M2
M3
M4
M5
M6
M7
M8
Buffer Index
0
1
2
3
4
5
6
7
Old Put Index
1
0
1
1
0
1
1
1
New Put Index
Pending request
Figure 334
Example of CAN input buffer list handling with 8 CAN input buffers
In the example figure:
•
The Put Index is currently at buffer 7
•
When a new CAN frame (M8) is fetched by the data Move Engine, it stores it in buffer 7 as indicated by the
Put Index
•
The Put Index is then circularly incremented to the next free buffer location, which is buffer index 1
The Buffer Full flag (CIBL_STATUS.BF) is set by the Message Controller when the EOBUF is not available to store
the incoming CAN frame and an interrupt is triggered. It is cleared by hardware after the frame is fetched from
the EOBUF.
The Buffer Empty flag (CIBL_STATUS.BE) is set by the Message Controller when no pending requests are set. It is
cleared by hardware when at least 1 buffer has a pending request set.
Related information
CAN-to-Ethernet ACF assembler on page 3746
Routing control unit on page 3760
CAN address database on page 3726
Ethernet output buffer on page 3730
20.4.3.3
CAN output buffer list
The CAN Output Buffer List stores the CAN frames which are to be transmitted through CAN interfaces.
After the CAN Transmit Routing Engine decides the routing destination of a CAN frame to be transmitted, the
ACF CAN-Ethernet Format Engine writes the CAN frame into the CAN Output Buffer List. The Routing Control
Unit transfers the CAN frame from the output buffers to their corresponding destinations.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3728
v1.1
2025-06-26


The start address of the CAN Output Buffer List is DRE RAM start address + 0x6E0. There are a total of 64 CAN
output buffers. Each buffer stores 16 bytes of header data and 64 CAN data bytes. The structure of the buffers is
shown in figure below.
CAN Output Buffer List 
(COBL)
COBL start address (absolute) = 
DRE RAM start address + 0x6E0
+  0x0  
+  0x50
0
63
31
32
COBUF0
1 Buffer size  = 16 bytes header + 
64 bytes CAN payload
Number of COBUF = 64
COBL max. Size = 5120 bytes
COBUF0_UCRH or
COBUF0_MCRH
COBUF0_CRC
COBUF0_R0
COBUF0_R1
COBUF0_DB3 – DB0
COBUF0_DB7 – DB4
COBUF0_DB59 – DB56
COBUF0_DB63 – DB60
COBUF1
COBUF63
Figure 335
RAM structure of CAN output buffer list
The CAN output buffers are organized in the form of a circular list. The list contains a Put Index
(COBL_STATUS.PIDX).
The Put Index is controlled by the Message Controller. A new transmit CAN frame is stored in the buffer indexed
by the Put Index. The Put Index is incremented to the next free buffer after storing the CAN frame. The Put Index
wraps around to the next free buffer starting from index 0 after the configured maximum number of buffers.
A pending request (COBL_BPR0.PRj (j=0-31) and COBL_BPR1.PRj (j=32-63)) is set by the ACF CAN-Ethernet
Format Engine to indicate that the CAN buffer contains a frame yet to be transferred to its corresponding
destination. The pending requests are scanned by the Routing Control Unit to identify the CAN frames to be
transferred. After transfer of the fetched CAN frame to its corresponding destination, the pending request is
cleared by the Routing Control Unit.
The Buffer Full flag (COBL_STATUS.BF) is set by the Message Controller when there are no free buffers to store
the incoming CAN frame and an interrupt is triggered. It is cleared by hardware when there are free buffers
available. The Buffer Empty flag (COBL_STATUS.BE) is set by the Message Controller when no pending requests
are set. It is cleared by hardware when at least one buffer has a pending request set.
Related information
ACF_CAN_BRIEF message format decoder on page 3754
Routing control unit on page 3760
Ethernet ACF-to-CAN disassembler on page 3753
CAN address database on page 3726
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3729
v1.1
2025-06-26


20.4.3.4
CAN transmit routing tables (1 to 4)
The CAN Transmit Routing Tables store the routing elements which identify the CAN interface to which a CAN
frame is to be transmitted. The routing tables are used by the CAN Transmit Routing Engine to identify the
transmit CAN interface.
Up to 4 routing tables with a maximum of 128 routing elements per routing table can be configured. The start
address of the first routing table is DRE RAM start address + 0x1AE0. The start address of the consecutive
routing tables are at fixed offsets of 0x400 from the previous table. The number of routing elements in each
routing table is configured using RTi_CONFIG.NRULES.
Each routing element contains:
1.
CAN ID filter (RT_REj_CIDFC ( j = 0-127)) and
2.
Routing rule with CAN destinations (RT_REj_UCR or MCR ( j = 0-127))
The CAN ID filter conditions are used by the CAN Transmit Routing Engine to identify the routing rule
corresponding to a CAN frame based on the configured CAN ID filters.
The routing rule configuration is used by the CAN Transmit Routing Engine to identify the destination CAN
interface.
Related information
CAN acceptance filters on page 3759
20.4.3.5
Ethernet output buffer
The Ethernet Output Buffer stores the transmit ACF frames containing one or more ACF_CAN_BRIEF messages.
There are six EOBUFs available but usability depends on the number of Ethernet interfaces available in the
device.
The start address of Ethernet Output Buffer j (j = 0 - 5) is configured at DRE RAM start address + 0x2B40 +
j*0xC80. The buffers have the following three sections:
1.
IEEE 802.3 MAC header
2.
NTSCF header
3.
ACF payload
The structure of the Ethernet Output Buffer is shown in the figure below.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3730
v1.1
2025-06-26


IEEE 802.3 Ethernet MAC header + 
IEEE 802.1Q Tag field
(20 Bytes)
NTSCF header
(12 Bytes)
ACF_CAN_BRIEF 
message #1
(Minimum - 8 Bytes, 
Maximum - 72 Bytes)
ACF_CAN_BRIEF 
message #2
ACF_CAN_BRIEF 
message #n
EOBUFj start address (absolute) = 
DRE RAM start address + 0x2B40+ 
j*0xC80
EOBUFj_CONFIG.PL
Minimum - 8 bytes
Maximum - 1484 
bytes
ACF payload size
Fixed header size
32 Bytes
ACF Frame
+ 0x20
Ethernet Output Buffer for 
IEEE 1722 Ethernet frames 
(EOBUF)
ACF Payload
Fixed size 192 words (64-bit)
Reserved
(20 bytes)
+ 0x14
Figure 336
Ethernet output buffer structure
IEEE 802.3 MAC header
This section contains the user-configured Ethernet MAC header with optional IEEE 802.1Q tag field. The header
always starts at the offset of 2H from the start address of the buffer. The MAC header is configured in
EOBUFj_MAC_H0, EOBUFj_MAC_H1, EOBUFj_MAC_H2, EOBUFj_MAC_H3 and EOBUFj_MAC_H4. The header is
assembled by the ACF CAN-Ethernet Format Engine when an Ethernet frame transmit trigger condition occurs.
The structure of the IEEE 802.3 MAC header is shown in the figure below.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3731
v1.1
2025-06-26


DRE RAM start address 
+ EOBUFi_SA.ADR
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
Reserved
DA[47:0] (Destination MAC address)
SA[47:0] (Source MAC address)
TPID[15:0] (0x8100)
PCP[2:0]
D
EI
VID[11:0] (VLAN Identifier)
AVTP EtherType[15:0] (0x22F0)
Byte 0
Byte 1
Byte 2
Byte 3
Byte order
Bit order
Figure 337
IEEE 802.3 MAC header
NTSCF header
This section contains the NTSCF header of the transmit Ethernet frame. The header always starts at the offset of
14H from the start address of the buffer. The header information is shown in EOBUFj_NTSCF_H0. The header is
assembled by the ACF CAN-Ethernet Format Engine when an Ethernet frame transmit trigger condition occurs.
The structure of the NTSCF header is shown in the figure below.
Subtype [7:0]
(0x82)
Stream_id [63:0]
DRE RAM start address +
EOBUFi_SA.ADR + 0x14
s
v
Version[2:
0] (000b)
r
Ntscf_data_length[10:0]
Sequence_num[7:0]
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
Byte 0
Byte 1
Byte 2
Byte 3
Byte order
Bit order
Figure 338
NTSCF header
ACF payload
This section contains one or more ACF_CAN_BRIEF messages. The ACF payload section always starts at the
offset of 20H from the start address of the buffer. The length of the ACF payload section is configured by the user
at EOBUFj_CONFIG.PL. The structure of the ACF_CAN_BRIEF message is shown in the figure below.
acf_msg_type [6:0]
acf_msg_length [8:0]
Pad
[1:0]
m
tv
rt
r
ef
f
br
s
fd
f
e
si
rsv [2:0]
can_bus_id [4:0]
rsv [2:0]
can_identifier [28:0]
can_msg_payload (0 – 16 32-bit words)
CAN header
CAN payload
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
Byte 0
Byte 1
Byte 2
Byte 3
Byte order
Bit order
Data Byte 0
Data Byte 1
Data Byte 2
Data Byte 3
Figure 339
ACF_CAN_BRIEF message
Related information
References on page 3907
CAN-to-Ethernet ACF assembler on page 3746
Tx descriptor handler on page 3781
CAN input buffer list on page 3726
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3732
v1.1
2025-06-26


20.4.3.6
Ethernet input buffer
The Ethernet Input Buffer stores the received Ethernet frames from the Ethernet module. The ACF CAN-Ethernet
Format Engine disassembles CAN frames from the ACF frames. Alternatively, the Ethernet Descriptor Handler
forwards the Ethernet frame if the destination is an Ethernet interface.
The Ethernet Input Buffer stores the Ethernet frames received from Ethernet interfaces which are to be
transmitted to CAN interfaces or forwarded to a different Ethernet interface. There are six EIBUFs available but
usability depends on the number of Ethernet interfaces available in the device. The start address of Ethernet
Input Buffer j (j = 0 - 5) is configured at DRE RAM start address + 0x31C0 + j*0xC80 . The size of the buffer is 192
double words which include the complete Ethernet frame (including MAC header, NTSCF header and ACF
payload) plus some additional padding bytes to achieve 64-byte alignment. The state machine gets the size of
the frame from the Rx descriptor in the case of Ethernet to Ethernet forwarding or the NTSCF header in the case
of Ethernet to CAN routing. The structure of the header and the payload is the same as that of the Ethernet
Output Buffer.
Related information
Ethernet ACF-to-CAN disassembler on page 3753
Rx descriptor handler on page 3784
Interrupt grouping on page 3789
Tx descriptor handler on page 3781
20.4.3.7
Ethernet descriptor lists
The Ethernet descriptor lists consist of a set of Rx or Tx descriptors to receive and transmit Ethernet frames.
The Ethernet descriptors are updated by the Ethernet Descriptor Handler (Read format) and the Ethernet DMA
channels (Write-back format). The ETH Descriptor Handler consists of 6 Transmit Descriptor Lists (0-5) and 6
Receive Descriptor Lists (0-5) but usability depends on the number of Ethernet interfaces available in the
device. There is one Tx list and one Rx list per Tx/Rx DMA channel respectively. The Message RAM consists of 4
Rx descriptors and 4 Tx descriptors per Ethernet interface. Each descriptor list contains 4 descriptors, and each
descriptor is made up of 4 32-bit words.
The descriptors are used to exchange packet data and packet control or status information between the DRE
and Ethernet DMA channel.
The start address of Ethernet Tx descriptor list j (j = 0 - 5) is configured at DRE RAM start address + 0x3140 +
j*0xC80.
The start address of Ethernet Rx descriptor list j (j = 0 - 5) is configured at DRE RAM start address + 0x3180 +
j*0xC80.
Related information
Tx descriptor handler on page 3781
Rx descriptor handler on page 3784
Forwarding table on page 3739
20.4.3.7.1
Descriptor structure configuration
This section describes the configuration of descriptors for use in the DRE.
In the ring structure, each descriptor is made of 4 32-bit words. The descriptor structure is configured by the
user by configuring the following registers:
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3733
v1.1
2025-06-26


•
The Rx and Tx descriptor lists can be assigned to an Ethernet interface by setting RETHDLi_CTRL.EIF and
RETHDLi_CTRL.EIFID. For example, if EIBUF0 is used for receiving Ethernet frames from GETH0 Rx DMA
channel 1:
-
RETHDL0_CTRL.EIF = 0
-
RETHDL0_CTRL.EIFID = 0
-
RETHDL0_CTRL.DMACH = 1
Note:
Bit-fields RETHDLi_CTRL.DMACH and TETHDLi_CTRL.DMACH should be the same.
Irrespective of the value configured in this bit-field, the DRE receives/transmits frames only
from/to the Ethernet DMA channel whose Tail Pointer address is configured in the Ethernet
Address Database (EAD) at the corresponding index RETHDLi_CTRL.EIF and
RETHDLi_CTRL.EIFID. Bit-field RETHDLi_CTRL.DMACH is used in generating the FWDID while
forwarding and bit-field TETHDLi_CTRL.DMACH is only for status information
•
RETHDLi_CTRL.TRIG and TETHDLi_CTRL.TRIG set the type of trigger from the Descriptor Handler. When a
TRIG is set, Ethernet frames are sent to and received from software by triggering an interrupt. In this case,
the descriptors are not prepared by the DRE
The user must pre-configure the descriptor structure of the DRE within the Ethernet DMA channel by updating
the registers with the start addresses of the Tx and Rx descriptor list within the Message RAM:
•
For GETH, DMA_CHj_TxDesc_List_LAddress and DMA_CHj_RxDesc_List_LAddress
•
For LETH, DMA_CHy_TxDesc_List_Address and DMA_CHy_RxDesc_List_Address
The user must also update the registers with the total number Tx and Rx descriptors per respective DMA
channel:
•
For GETH, DMA_CHj_Tx_Control2.TDRL and DMA_CHj_Rx_Control2.RDRL
•
For LETH, DMA_CHy_TxDesc_Ring_Length.TDRL and DMA_CHy_Rx_Control2.RDRL
Related information
Ethernet address database (EAD) on page 3740
Tx descriptor handler on page 3781
Rx descriptor handler on page 3784
Descriptor error handling on page 3789
20.4.3.7.2
Tx descriptors
This chapter describes the use of Tx descriptors in the DRE.
Whenever a new Ethernet frame is to be transmitted to a Tx DMA channel of an Ethernet interface, transmit
descriptors (TDESC_RD0-3) are prepared by the DRE in Read format in the Message RAM. The Tx DMA reads the
descriptor prepared by the DRE and then overwrites it with the Write-back format (TDESC_WR0-3) after reading
the frame from the Ethernet Output Buffer. The following figures give an overview of the Read and Write-back
formats. A detailed description can be found in the chapter Registers of this manual.
Read format
The following image shows an example of the structure of a Tx descriptor. Each Read format descriptor
contains 4 TDESCi_RD descriptor words (i=0-3). Each Tx descriptor list in Read format contains 4 descriptors,
giving 16 words for each list in total.
Words marked reserved contain no valid input.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3734
v1.1
2025-06-26


EOBUF or EIBUF address [31:0]
0
31
0
IOC
0
Buffer 1 length [13:0]
OWN
Control [30:15]
Frame length [14:0]
TDESC_RD0
TDESC_RD1
TDESC_RD2
TDESC_RD3
Tx descriptor Read format (i = 0-3)
Figure 340
Tx descriptor - read format
The 4 descriptor words prepared by the DRE are: TDESCi_RD0, TDESCi_RD1, TDESCi_RD2 and TDESCi_RD3
Write-back format
The following image shows an example of the structure of a Tx descriptor. Each Write-back format descriptor
contains 4 TDESCi_WR descriptor words (i=0-3). Each Tx descriptor list in Write-back format contains 4
descriptors, giving 16 words for each list in total.
Words marked reserved contain no valid input.
Reserved
Reserved
31
0
OWN
Descriptor Status [30:27]
Reserved
TDESC_WR0
Tx descriptor Write-back format (i=0-3)
Reserved
OWN
Descriptor Status [30:0]
Reserved
LETH descriptor view
GETH descriptor view
TDESC_WR1
TDESC_WR2
TDESC_WR3
Figure 341
Tx descriptor - write-back format
•
The GETH Tx DMA channel prepares the 4 descriptor words: TDESCi_WR0, TDESCi_WR1, TDESCi_WR2 and
TDESCi_WR3G
•
The LETH Tx DMA channel prepares the 4 descriptor words: TDESCi_WR0L, TDESCi_WR1L, TDESCi_WR2 and
TDESCi_WR3L
Related information
Tx descriptor handler on page 3781
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3735
v1.1
2025-06-26


20.4.3.7.3
Rx descriptors
This chapter describes the use of Rx descriptors in the DRE.
Whenever a free EIBUF is available to receive an Ethernet frame from an Ethernet interface, receive descriptors
(RDESC_RD0-3) are prepared by the DRE in Read format in the Message RAM. The Rx DMA reads the descriptor
and then overwrites it with the Write-back format (RDESC_RD0-3) after writing the frame to the Ethernet Input
buffer. The following figures give an overview of the Read and Write-back formats. A detailed description can be
found in the chapter Registers in this manual.
Read format
The following image shows an example of the structure of an Rx descriptor. Each Read format descriptor
contains 4 TDESCi_RD descriptor words (i=0-3). Each Rx descriptor list in Read format contains 4 descriptors,
giving 16 words for each list in total.
Words marked reserved contain no valid input.
EIBUF address [31:0]
Reserved
31
0
OWN
IOC
Reserved
RDESC_RD0
Rx descriptor Read format (i=0-3)
Reserved
RDESC_RD1
RDESC_RD2
RDESC_RD3
Reserved
BUF1V
Reserved
Reserved
OWN
IOC
LETH descriptor view
EIBUF address [31:0]
GETH descriptor view
Reserved
Figure 342
Rx descriptor - read format
The 4 descriptor words prepared by the DRE are: RDESCi_RD0, RDESCi_RD1, RDESCi_RD2, and RDESCi_RD3G
for GETH or RDESCi_RD3L for LETH.
Write-back format
The following image shows an example of the structure of an Rx descriptor. Each Write-back format descriptor
contains 4 TDESCi_WR descriptor words (i=0-3). Each Rx descriptor list in Write-back format contains 4
descriptors, giving 16 words for each list in total.
Words marked reserved contain no valid input.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3736
v1.1
2025-06-26


VNID/VSID [31:8]
RSS HASH / Flexible Receive Parser Last Instruction
31
0
OWN
Descriptor Status 
[30:27]
Packet Length [13:0]
DRE_RDESC_WR0NT
when TNP=0
Rx descriptor Write-back format (i=0-3)
MAC Filter Status [31:16]
OL2L3 [2:0]
RSVD
IVT[15:0]/ELRD [15:0]
OVT [15:0]/ELRD [15:0]
VF
RPNG
IOS
ELD
TNP
FRP
SM
Header Length [9:0]
FR
PSL
Packet Status [26:16]
ES
OAM code or MAC control Opcode [31:16]
Extended Status
Inner VLAN Tag [31:16]
Outer VLAN TAG [15:0]
MAC Filter Status/Flexible Rx Parser Status [31:16]
VF
Rsvd 
[14:12]
Header Length [9:0]
ARP Status 
[11:10]
Packet Length [14:0]
ES
Packet Status [27:16]
OWN
Descriptor 
Status [30:28]
Reserved
LETH descriptor view
GETH descriptor view
DRE_RDESC_WR1
DRE_RDESC_WR2
DRE_RDESC_WR3
DRE_RDESC_WR0T
when TNP=1
Figure 343
Rx descriptor - write-back format
The image above shows the differences for tunneled and non-tunneled frames for RDESCi_WR0. When TNP=1,
RDESCi_WROT applies to both GETH and LETH interfaces. When TNP=0, RDESCi_WR0NT applies for LETH and
GETH as shown by the colors in the image.
•
The GETH Rx DMA channel prepares the 4 descriptor words: RDESCi_WR0T (for tunneled frames) or
RDESCi_WR0NT (for non-tunneled frames), RDESCi_WR1G, RDESCi_WR2G and RDESCi_WR3G
•
The LETH Rx DMA channel prepares the 4 descriptor words: RDESCi_WR0NT, RDESCi_WR1L, RDESCi_WR2L
and RDESCi_WR3L
Related information
Rx descriptor handler on page 3784
Descriptor structure configuration on page 3733
Descriptor error handling on page 3789
20.4.3.8
Message RAM access protection
The Ethernet section is organized such that each EOBUF, it's corresponding EIBUF and the corresponding Tx
and RX descriptor lists are located together in a consecutive RAM address range, as shown in the diagram
below. Each address range has it's own Access Protection Unit (APU) associated to it, so each address range can
be individually protected. Each APU corresponds to a Ethernet interface (SRI master) as shown in the image
below. The start address of the APU is the same as the EOBUF start address. The owner of the APU is
determined based on which master requires write access to the EIBUF and the descriptors (RETHDLi_CTRL.EIF,
EIFID). While the owner of the APU must have read and write access, the other masters must have only read
access.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3737
v1.1
2025-06-26


EOBUF 0
Tx Descriptor list 0
(4 descriptors)
Rx Descriptor list 0
(4 descriptors)
EIBUF 0
APU-PETH0
DRE RAM SA 
+ 0x2B40
DRE Message RAM layout (Ethernet section)
400 
double 
words
63
0
EOBUF 1 + Tx Desc list 1 + Rx Desc list 1 
+ EIBUF 1
APU-PETH1
+ 0x37C0
400 
double 
words
APU-PETHj
(j = Max. Ethernet MACs - 1)
EOBUF j + Tx Desc list j + Rx Desc list j + 
EIBUF j
+ 0x69C0
400 
double 
words
Figure 344
DRE message RAM layout for Ethernet
Example access matrices for GETH and LETH are given in Table 1 and Table 2 below. The APUs can be
configured using the APU-PETHj (ETHj_ACCEN) registers (refer to the Registers chapters for details).
Table 933
Example access matrix (APU owned by GETH0)
Read access
Write access
•
GETH0
•
LETH interfaces
GETH0
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3738
v1.1
2025-06-26


Table 934
Example access matrix (APU owned by LETH0)
Read access
Write access
•
LETH0
•
GETH interfaces
LETH0
20.4.3.9
Forwarding table
The forwarding table is used by the Forwarding Engine to identify the transmit Ethernet interface.
The forwarding table stores the forwarding rules which identify the Ethernet interface to which an Ethernet
frame is to be forwarded.
Up to a maximum of 128 forwarding elements can be configured. The start address of the forwarding table is
DRE RAM start address + 0x7640. The number of forwarding elements can be configured through
FTCFG.NRULES as shown in the figure below.
Forwarding element 1
Forwarding element 2
Max. forwarding element 127
FMODE
FID1
Reserved
DSEL
FID2
Reserved
2 words
Filter IDs
Filter mode
Forward rule
Forwarding element 0
Forwarding element
Forwarding table
FTCFG.NRULES
DRE RAM start address + 
0x7640
Figure 345
Forwarding table
Each forwarding element contains:
1.
Uni-cast or multi-cast Forward ID filters Filter ID1 in bit-field FT_FEj_FRULE.FID1 and Filter ID2 in bit-field
FT_FEj_FID2.FID2
2.
Forwarding rule FT_FEj_FRULE.DSEL. The forwarding rule is bit-encoded. Single bit is set in the case of
uni-cast and multiple bits are set in the case of multi-cast forwarding
3.
Filter mode FT_FEj_FRULE.FMODE
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3739
v1.1
2025-06-26


The FWD ID filter conditions are used by the Forwarding Engine to identify the forwarding rule corresponding to
an Ethernet frame based on the configured FWD ID based filters.
The forwarding rule configuration is used by the Forwarding Engine to identify the destination Ethernet
interface of the corresponding Ethernet frame.
Related information
Ethernet descriptor lists on page 3733
20.4.3.10
Ethernet address database (EAD)
The Ethernet Descriptor Handler receives Ethernet frames from or transmits them to Ethernet DMA channels.
The Ethernet Address Database (EAD) needs to be configured by the user in order for the DRE to perform routing
and forwarding operations to or from Ethernet DMA channels. The database is stored in the Message RAM of the
DRE and always starts at address DRE RAM start address + 0x2AE0. The EAD is indexed based on
RETHDLi_CTRL.EIF and EIFID configured. The Ethernet address database stores the addresses of the following
Rx and Tx Tail Pointer registers of each Ethernet DMA channel, as shown in the figure below:
•
DMA_CHy_RxDesc_Tail_Pointer (y=0-7) and DMA_CHy_TxDesc_Tail_Pointer (y=0-7) for LETH
•
DMA_CHj_RxDesc_Tail_LPointer (j=0-7) and DMA_CHj_TxDesc_Tail_LPointer (j=0-7) for GETH
Note:
One Tx and one Rx DMA channel per Ethernet MAC is configured to receive and/or transmit Ethernet
frames from/to the DRE
DRE Message RAM
ETH Address Database (EAD) for 
Descriptor Tail Pointers
LETH0_TXDMA
+  0x0
+  0x8
+  0x28
LETH0_RXDMA
0
63
31
32
LETH1_TXDMA
LETH1_RXDMA
GETH1_TXDMA
GETH1_RXDMA
Total 
12 elements = 48 bytes
LETH2_TXDMA
LETH2_RXDMA
LETH3_TXDMA
LETH3_RXDMA
GETH0_TXDMA
GETH0_RXDMA
EAD start address (absolute) = 
DRE RAM start address + 0x2AE0
Figure 346
Ethernet address database structure
The Ethernet Descriptor Handler reads the Ethernet DMA Status register DMA_CH_Status during error or polls it
to determine the status of the DMA. The bits highlighted in the figure below are checked by the Descriptor
Handler to determine the status.
1.
GETH DMA_CHj_Status (j=0-7) register address = DMA_CHj_RxDesc_Tail_LPointer (j=0-7) + EADCFG.GOV
2.
LETH DMA_CHy_Status (y=0-7) register address = DMA_CHy_RxDesc_Tail_Pointer (y=0-7) + EADCFG.LOV
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3740
v1.1
2025-06-26


Reserved
Bits 21-16
Bits 15-13
Bit 12
Rsvd
Bits 11-9
Bit 8
Bit 7
Bit 2
Bit 1
DMA_CHj_status or DMA_CHy_status 
register outline
Bit 0
Checked by DRE
Bit 6
RPS
FBE
RBU
TBU
TPS
FBE  Fatal Bus Error
RPS  Receive Process Stopped
RBU Receive Buffer Unavailable
TBU Transmit Buffer Unavailable
TPS  Transmit Process Stopped
Figure 347
DMA status register outline
Related information
Descriptor structure configuration on page 3733
Descriptor error handling on page 3789
Tx descriptor handler on page 3781
Rx descriptor handler on page 3784
20.4.3.11
DMEM parameter table
The DMEM parameter table contains the control and address configuration of the destination memories used
for CAN to system memory routing.
The start address of the DMEM parameter table is DRE RAM start address + 0x7A40. The DMEM parameter table
consists of 28 elements. Each element corresponds to an individual destination memory (DMEMi) configuration.
This way 28 independent destination memories can be configured. The DMEM parameter table layout is shown
in the following figure.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3741
v1.1
2025-06-26


DRE Message RAM
DMEM parameter table
DMEM0_SA
+  0x10
+  0x180
DMEM0_FDBI
0
63
31
32
DMEM0_WM
DMEM0_WA
DMEM27
DMEM0
1 element = 16 bytes
Total 
28 elements = 448 bytes
DMEM1
DMEM2
+  0x20
+  0x30
DMEM parameter table start address (absolute) = 
DRE RAM start address + 0x7A40
Figure 348
DMEM parameter table layout
The DMEM table is configured by the user with the following parameters:
1.
DMEMi_SA defines the start address of DMEMi (i= 0 to 27)
2.
DMEMi_WM defines the watermark level of DMEMi (i= 0 to 27). The watermark level is configured as
number of CAN messages or number of words depending on the trigger mode.
3.
DMEMi_WA defines the wraparound level of DMEMi (i= 0 to 27). The wraparound level is configured as
number of CAN messages or number of words depending on the trigger mode.
The DMEM table also consists of DMEMi_FDBI, which is updated by the DRE after each CAN message is
transferred to the destination memory.
Related information
System memory as destination (ID = 20 to 3B) on page 3768
20.5
ACF CAN-Ethernet format engine
This section describes the CAN-to-ACF and ACF-to-CAN frame formatting.
20.5.1
Feature list
•
Concurrent assembly and disassembly of CAN (FD) frames into and from ACF frames according to IEEE
1722-2016
-
Supports Non-Time-Synchronous Control Format header (NTSCF)
-
Supports Abbreviated CAN/CAN FD message type (ACF_CAN_BRIEF)
•
Support of different ACF frame transmission modes
-
Frame Count transmit mode
-
Buffer Fill Level transmit mode
-
Time-Triggered transmit mode
-
Software-Triggered transmit mode
•
User-configurable stream ID for the ACF transmit frames
•
Optional user configuration for Ethernet 802.3 MAC header and 802.1Q tag field corresponding to ACF
frames contained in Layer 2 Ethernet frame
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3742
v1.1
2025-06-26


•
Automatic stream ID-based sequence number generation and validation for ACF transmit and receive
frames respectively
•
Flexible identification of AVTP EtherType field start offset address in received ACF frames
•
Stream ID-based acceptance filters for received ACF frames
•
Support of the following error detections
-
Invalid NTSCF sub-type received
-
Invalid CAN/CAN FD message type received
-
ACF received frame length error
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3743
v1.1
2025-06-26


20.5.2
Functional overview
The block diagram of the ACF CAN-to-Ethernet Format Engine is shown in the following figure. It contains four
blocks:
•
Transmit Trigger Unit
•
CAN-to-Ethernet ACF Assembler
•
Ethernet ACF-to-CAN Disassembler
•
Stream ID Filter
CAN to Ethernet ACF 
Assembler
Transmit 
Trigger 
Unit
Ethernet ACF to CAN 
Disassembler
Stream ID 
Filters
CAN Transmit 
Routing 
Engine
ACF CAN-Ethernet Format 
Engine
Transmit 
Trigger
Input CAN Frames
ACF formatted CAN frames
Input Ethernet ACF frame
containing CAN Frames
Extracted CAN Frames
Routing request
(Message RAM)
(Message RAM)
(Message RAM)
(Message RAM)
CAN Input 
Buffer List
1
2
20
Ethernet 
Input Buffer
1
2
6
Ethernet 
Output Buffer
1
2
6
CAN Output 
Buffer List
1
2
64
Figure 349
IEEE 1722a ACF format engine block diagram
Transmit Trigger Unit
The Transmit Trigger Unit controls the completion criteria of assembling the CAN-over-Ethernet frame which is
performed by the CAN-to-Ethernet ACF Assembler. Based on the configuration of the Transmit Trigger Unit, a
transmit trigger is sent to the CAN-to-Ethernet ACF Assembler, which marks that the corresponding Ethernet
Output Buffer is ready for transmission to an Ethernet interface. The Transmit Trigger Unit supports 4 modes of
operation:
•
Frame Count transmit mode
•
Buffer Fill Level transmit mode
•
Time-Triggered transmit mode
•
Software-Triggered transmit mode
CAN-to-Ethernet ACF Assembler
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3744
v1.1
2025-06-26


The CAN-to-Ethernet ACF Assembler performs the formatting of the CAN frame to Abbreviated CAN/CAN FD
message type (ACF_CAN_BRIEF) format as specified by the IEEE 1722-2016 standard. The CAN frames are
fetched from the CAN Input Buffer List and the formatted CAN frames are written to the Ethernet Output Buffer
corresponding to the destination ID contained in the routing header of the input CAN frame. In addition to the
ACF payload, it also prepares the NTSCF header.
Ethernet ACF-to-CAN Disassembler
The Ethernet ACF-to-CAN Disassembler performs the extraction of Abbreviated CAN/CAN FD messages
(ACF_CAN_BRIEF) from an ACF frame in the Ethernet Input Buffer and formats it to the CAN frame transmit
format. The extracted and formatted transmit CAN frames are handed to the CAN Transmit Routing Engine to
determine the destination CAN interface.
Stream ID Filter
The Stream ID Filters contain the configuration for accepted Stream IDs of the input ACF frames. They also
contain routing table indexes for each Stream ID filter. The routing table index is used by the CAN Transmit
Routing Engine to select a corresponding CAN Transmit Routing Table which is compared to extracted CAN
frames to identify the destination CAN interface.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3745
v1.1
2025-06-26


20.5.3
Functional description
In this section, the packing and un-packing of CAN frames to or from ACF frames are described in detail.
20.5.3.1
Transmit trigger unit
The Transmit Trigger Unit enables the user to configure the transmit condition of the ACF frame. The following
transmit modes are supported and can be configured with EOBUFj_CONFIG.TTM:
•
Frame Count
•
Buffer Fill Level
•
Time-Triggered
•
Software-Triggered
20.5.3.1.1
Frame count transmit mode
The transmission of the ACF frame is triggered when the number of ACF_CAN_BRIEF messages in an Ethernet
Output Buffer has reached the user-configured frame count value in the EOBUFj_TTC.TFL bit-field.
The Frame Count transmit mode is enabled when EOBUFj_CONFIG.TTM = 01B. The current number of CAN
frames packed in an Ethernet Output Buffer is seen at EOBUFj_STATUS.ACFL. When it reaches the
EOBUFj_TTC.TFL of an Ethernet Output Buffer, the EOBUFj_STATUS.TXRDY flag is set.
20.5.3.1.2
Buffer fill level transmit mode
The transmission of the ACF frame is triggered when the ACF payload size is greater than or equal to the
configured Buffer Fill level in EOBUFj_TTC.BUFT.
The Buffer Fill Level transmit mode is enabled when EOBUFj_CONFIG.TTM = 10B. The current ACF payload size
of an Ethernet Output Buffer is shown in EOBUFj_NTSCF_H0.NTSCFDL. When the ACF payload size is greater
than or equal to the configured Buffer Fill level (EOBUFj_TTC.BUFT), the Transmit Ready flag
(EOBUFj_STATUS.TXRDY) is set.
20.5.3.1.3
Time-triggered transmit mode
The transmission of the ACF frame is triggered after a configured time interval.
The Time-Triggered transmit mode is enabled when EOBUFj_CONFIG.TTM = 11B. The clock source of the timer is
fSRI. The pre-scaler value for the timer is configured in EOBUFj_TTC.TP. Writing a non-zero value to the Timer
Reload Value (EOBUFj_TTS.TRV) starts the timer. At the start of the timer, the TRV value is loaded to the Current
Timer Value (EOBUFj_TTC.CTV) and it is decremented at the frequency of the clock source fSRI (pre-scaled by
EOBUFj_TTC.TP). When EOBUFj_TTC.CTV reaches 00H, the Transmit Ready flag (EOBUFj_STATUS.TXRDY) is set.
Upon a trigger condition, when the corresponding Ethernet Output Buffer is empty, the Transmit Ready flag is
not set and the Transmit Trigger Lost flag (EOBUFj_STATUS.TTL) is set.
20.5.3.1.4
Software-triggered transmit mode
The transmission of the ACF Ethernet frame is triggered from the application software.
When EOBUFj_CONFIG.TTM = 0B, the application software can trigger the transmission of the ACF frame by
setting EOBUFj_STATUS.TXRDY. When the TXRDY flag is set and the corresponding EOBUF is empty, the Transmit
Trigger Lost flag (EOBUFj_STATUS.TTL) is set.
20.5.3.2
CAN-to-Ethernet ACF assembler
The CAN-to-Ethernet ACF Assembler:
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3746
v1.1
2025-06-26


1.
Formats the CAN frames in CIBUF from CAN Input Buffer format to ACF_CAN_BRIEF format
2.
Writes the ACF_CAN_BRIEF messages to the Ethernet Output Buffer
3.
Writes the Ethernet header and NTSCF header to the Ethernet Output Buffer
The state machine of the CAN-to-Ethernet ACF Assembler is shown in the figure below.
Idle
Scan
Halt
Busy
New Input CAN 
frame fetched
ACF_CAN_BRIEF
Write Complete
EOBUF 
Unavailable
CIBUF 
Empty
EOBUF Available
CIBUF Pending 
Request
Module Reset
Figure 350
CAN-to-Ethernet state machine diagram
The transition conditions are described in the following table.
Table 935
CAN-to-Ethernet state transition condition
Current state
Next state
Transition condition
Any
Idle
Module Reset triggered
Idle
Scan
Pending Request of CAN Input Buffer
Scan
Idle
CAN Input Buffer List is empty
Scan
Busy
New CAN frame from CAN Input Buffer is ready to be processed
Busy
Scan
Assembling CAN frame in Ethernet Output Buffer is completed
Scan
Halt
No relevant Ethernet Output Buffer is available
Halt
Scan
An Ethernet Output Buffer becomes available
Related information
CAN input buffer list on page 3726
Ethernet output buffer on page 3730
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3747
v1.1
2025-06-26


20.5.3.2.1
Fetch input CAN frame
The Pending Request bit (CIBL_BPR) is used to identify the CAN frames to be processed from the CAN Input
Buffer List. Upon a new CAN Input Buffer pending request, the state machine transits from Idle to Scan state. In
this state, the pending requests of the CAN Input Buffers are scanned from CAN Input Buffer Index 0 up to Index
19. A CAN frame from a CAN Input Buffer is processed when the following conditions are satisfied:
1.
The CAN Input Buffer has a pending request set, and
2.
All destination Ethernet Output Buffer(s) are enabled and there is a free Ethernet Output Buffer
(EOBUFj_STATUS.TXRDY = 0 and EOBUFj_STATUS.TXREQ = 0)
The destination Ethernet Output Buffer(s) is determined by the Routing header of the input CAN frame
(CIBUFj_RHEAD). When an Ethernet destination(s) is enabled in CIBUFj_RHEAD, the corresponding Ethernet
Destination IDs are compared with configured matching Destination IDs of the Ethernet Output Buffers 0 to 5
(EOBUFj_CONFIG.DID). The EOBUF with the matching Destination ID is used as the destination Ethernet Output
Buffer. When no match is found, the Invalid Routing Destination Error flag (ME_ERR.IRDE) is set.
The CAN frame satisfying the above-mentioned conditions is then formatted with the ACF_CAN_BRIEF frame
structure. The CAN Input Buffer Index which matches the conditions is reflected in the CIBL_STATUS.CBI bit-
field and the state is set to Busy. In case the above conditions are not met by a CAN Input Buffer and the
corresponding CAN frame, the next CAN Input Buffer is scanned, until the configured maximum number of
buffers is reached. A transition from Scan to Idle state is performed when the Buffer Empty flag
(CIBL_STATUS.BE) is set. A transition from Scan to Halt state is performed when no CAN frame with pending
request has destination Ethernet Output Buffer(s) free.
Note:
The order of the ACF_CAN_BRIEF messages assembled in the EOBUF is not maintained as per the
order of incoming CAN requests
20.5.3.2.2
ACF_CAN_BRIEF message format encoder
ACF_CAN_BRIEF message format encoder
The input CAN frame is converted to the ACF_CAN_BRIEF format as defined by IEEE 1722-2016. The format of
the ACF_CAN_BRIEF message type is shown in figure below.
can_msg_payload (0 –16 32-bit words)
acf_msg_type [6:0]
acf_msg_length [8:0]
Pad[1:0]
m
tv
rt
r
ef
f
br
s
fd
f
es
i
rsv [2:0]
can_bus_id [4:0]
rsv [2:0]
can_identifier [28:0]
CAN header
CAN payload
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
Byte 0
Byte 1
Byte 2
Byte 3
Byte order
Bit order
Data Byte 0
Data Byte 1
Data Byte 2
Data Byte 3
Figure 351
ACF_CAN_BRIEF frame format
The ACF_CAN_BRIEF message has the following fields:
•
acf_msg_type: 7 bits
•
acf_msg_length: 9 bits
•
pad (padding length): 2 bits
•
mtv (message_timestamp valid): 1 bit
•
rtr (remote transmission request): 1 bit
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3748
v1.1
2025-06-26


•
eff (extended frame format): 1 bit
•
brs (bit rate switch): 1 bit
•
fdf (CAN Flexible Data-rate Format): 1 bit
•
esi (error state indicator): 1 bit
•
rsv (reserved): 3 bits
•
can_bus_id: 5 bits
•
can_identifier: 29 bits
•
rsv: 3 bits
•
can_msg_payload: 0 to 16 (32-bit) words
acf_msg_type field
The acf_msg_type field describes the type of message contained in the ACF message payload. The
ACF_CAN_BRIEF frames have a fixed acf_msg_type value of 0x02.
acf_msg_length field
The acf_ msg_length field indicates the number of words contained in the ACF_CAN_BRIEF frame. It includes
the number of words in the CAN header and in the CAN payload. The length of the input CAN frame payload is
indicated in the DLC field of the CAN Input Buffer. The acf_msg_length field always represents the number of
32-bit words in the frame. The minimum length is always 2, that is, when a CAN message contains no payload,
then the acf_msg_length contains a value of 2 representing only the words occupied by the CAN header. When a
CAN frame has a payload length which is not an integral multiple of 32-bit words, then the remaining bytes of
the can_msg_payload are padded with zero (0) to reach an integral multiple of 32-bit words. This is described in
detail below in the pad field description.
pad (padding length) field
The pad field indicates the length of padding at the end of the CAN message payload in bytes. Padding is added
to the payload of the input CAN frame so that the can_msg_payload ends on a word boundary. A value of zero
(0) is used in case there is no padding required for the CAN message payload. The table below shows the
encoding of the acf_msg_length and pad fields values for corresponding input CAN message length (DLC)
values.
Table 936
CAN message payload length transformation
Input CAN message
data length code
(DLC)
Input CAN message
data length (in
bytes)
can_message_payl
oad length (in
words)
Pad value (in bytes) acf_msg_length
value (in words)
0H
0D
0D
0D
2D
1H
1D
1D
3D
3D
2H
2D
1D
2D
3D
3H
3D
1D
1D
3D
4H
4D
1D
0D
3D
5H
5D
2D
3D
4D
6H
6D
2D
2D
4D
7H
7D
2D
1D
4D
8H
8D
2D
0D
4D
9H
12D
3D
0D
5D
AH
16D
4D
0D
6D
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3749
v1.1
2025-06-26


Table 936
(continued) CAN message payload length transformation
Input CAN message
data length code
(DLC)
Input CAN message
data length (in
bytes)
can_message_payl
oad length (in
words)
Pad value (in bytes) acf_msg_length
value (in words)
BH
20D
5D
0D
7D
CH
24D
6D
0D
8D
DH
32D
8D
0D
10D
EH
48D
12D
0D
14D
FH
64D
16D
0D
18D
mtv (message_timestamp_valid) field
The mtv field is always set to zero (0) for the ACF_CAN_BRIEF message format.
rtr (remote_transmission_request) field
The rtr field contains the CAN message Remote Transmission Request bit. The value of this bit-field corresponds
to CIBUFj_R0.RTR bit-field of the CAN Input Buffer. In case of Remote frames, there is no payload data copied
and the frame ends at R1.
eff (extended_frame_format) field
The eff field contains the CAN message Extended Frame Format bit. The value of this bit-field corresponds to
the CIBUFj_R0.XTD bit-field of the CAN Input Buffer.
Input CAN frames with standard 11-bit CAN identifier have their eff bit set to zero (0).
Input CAN frames with extended 29-bit CAN identifier have their eff bit set to one (1).
brs (bit_rate_switch) field
The brs field contains the CAN message Bit Rate Switch bit. The value of this bit-field corresponds to the
CIBUFj_R1.BRS bit-field of the CAN Input Buffer.
fdf (CAN Flexible Data-rate [FD] Format) field
The fdf field contains the CAN message Flexible Data-rate Format bit. The value of this bit-field corresponds to
the CIBUFj_R1.FDF bit-field of the CAN Input Buffer.
If the fdf bit is set to zero (0), then it is a classical CAN message and the valid lengths for data in the
can_msg_payload field are 0 through 8 bytes.
If the fdf bit is set to one (1), then it is a CAN FD message and the valid lengths for data in the can_msg_payload
field are 0 through 8, 12, 16, 20, 24, 32, 48 and 64 bytes.
esi (error_state_indicator) field
The esi field contains the CAN message Error State Indicator bit. The value of this bit-field corresponds to the
CIBUFj_R0.ESI bit-field of the CAN Input Buffer.
can_bus_id field
The can_bus_id field contains an identifier for the CAN bus on which this frame is received. The value of this bit-
field corresponds to the bits CIBUFj_RHEAD.SCBID[4:0] of the CAN Input Buffer.
can_identifier field
The can_identifier field contains the CAN frame identifier. The CAN frame identifier is either 11 or 29 bits in
length. The length of the can_identifier is indicated by the eff field. 11-bit CAN message identifiers
CIBUFj_R0.ID[28:18] are stored in byte 2, bits 2 through 0 and byte 3, bits 7 through 0. The remaining bits of the
field are set to zero (0). 29-bit CAN frame identifiers CIBUFj_R0.ID[28:0] occupy the entire 29-bit-field length of
the can_identifier field. The mapping of the CAN ID from the CAN Input Buffer to the ACF can_identifier field is
shown in the figure below. Valid CAN ID bits are marked as 'v' in the figure.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3750
v1.1
2025-06-26


1
0
9
8
7
6
5
4
3
2
1
0
v
v
v
v
v
v
v
v
v
v
v
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CAN Input Buffer
„R0"
Bit position
R
T
R
X
T
D
E
SI
Standard 11 bits CAN ID (R0.XTD = 0)
rsv
ACF_CAN_BRIEF
CAN-ID Field
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
Extended 29 bits CAN ID (R0.XTD = 1)
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
Byte 0
Byte 1
Byte 2
Byte 3
rsv
ACF_CAN_BRIEF
CAN-ID Field
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
v
v
v
v
v
v
v
v
v
v
v
2
0
9
8
7
6
5
4
3
2
1
3
0
9
8
7
6
5
4
3
2
1
1
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
7
6
5
4
3
2
1
0
Byte 0
Byte 1
Byte 2
Byte 3
1
0
9
8
7
6
5
4
3
2
1
0
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
v
CAN Input Buffer
„R0"
Bit position
R
T
R
X
T
D
E
SI
2
0
9
8
7
6
5
4
3
2
1
3
0
9
8
7
6
5
4
3
2
1
1
Figure 352
CAN ID mapping
can_msg_payload field
The can_msg_payload field contains the CAN frame payload data. The size of this field can be from 0 to 16
words, depending on the DLC (Data Length Code) of the input CAN frame. Only the data bytes of length
corresponding to CIBUFj_R1.DLC from the CAN Input Buffer are written to the can_msg_payload field. The
overall size of the can_msg_payload field is always an integral multiple of words (one word is of 4-bytes). If the
data length is not word aligned, padding is always added at the end of the CAN frame payload to satisfy the
length condition as shown in the previous table.
20.5.3.2.3
Assembling the CAN frame
This section describes the steps performed by the CAN-to-Ethernet ACF Assembler to assemble CAN frames.
Identification of the destination Ethernet Output Buffer
The destination of the input CAN frame is identified through the Destination ID in the Routing header of the CAN
frame (CIBUFj_RHEAD.ETHDID). Valid Destination ID values for Ethernet are from 18H until 1DH. The Ethernet
Output Buffer corresponding to the Destination ID values are configured in EOBUFj_CONFIG.DID. The Ethernet
Output Buffer that matches the Destination ID of the input CAN frame is chosen to store the corresponding
ACF_CAN_BRIEF message. In case the Ethernet Output buffer configurations contain the same Destination ID
values, Ethernet Output Buffer 0 is given the highest priority followed by the other buffers, provided that the
Buffer 0 is free to accept a new CAN frame.
Write operation to the ACF payload section
The input CAN frames which are encoded in the ACF_CAN_BRIEF message format are written to the ACF
Payload section of the Ethernet Output Buffer. The ACF Payload section starts at an offset address of 0x20 from
the Ethernet Output Buffer start address. The offset address at which the current ACF_CAN_BRIEF message is to
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3751
v1.1
2025-06-26


be written is indicated in EOBUFj_STATUS.ACF_CAN_ADDR. The ACF_CAN_BRIEF message is written to the
indicated payload address. Then following occurs after completion of the write operation:
1.
The EOBUFj_STATUS.ACF_CAN_ADDR is incremented by can_msg_payload × 4 (multiple of 4 is done to
convert the size from 32-bit words to bytes)
2.
The ntscf_data_length (EOBUFj_NTSCF_H0.NTSCFDL) of the NTSCF header is incremented by
can_msg_payload × 4
The Assembler verifies the 16-bit CRC (CIBUFj_CRC) which is calculated by the CRE over R0, R1 (except ESI,
ANMF, RXTS, FIDX and BRS which are considered as zero), safety critical CAN payload and the DID (which is
padded with zeros to make it 32-bits) which is part of the input CAN frame in the CIBUF before it writes the final
block of data into the EOBUF. The CRC is calculated over 16 bits of data at a time starting with the MSB. It uses
the CCITT CRC16 polynomial: 0x1021 x16 + x12 + x5 + 1 . If there is a mismatch in the CRC, the CRC Error flag
(CIBL_STATUS.CRCE) is set and an error interrupt is triggered but the CAN frame is still processed by the DRE.
Note:
In case of CAN to CAN routing, the DRE does not calculate the CRC. It only copies the CRC from the
source CAN node to the destination CAN node.
Acknowledgement of the CAN Input Buffer
After finishing the write operation of the completed ACF_CAN_BRIEF message to the Ethernet Output Buffer, the
pending request of the corresponding CAN Input Buffer is cleared by the hardware. EOBUFj_STATUS.ACFL is
incremented after the ACF_CAN_BRIEF message is assembled inside the EOBUF. The CAN-to-Ethernet ACF
Assembler then proceeds to fetch the next available input CAN frame.
The DRE monitors for delayed processing of the CAN frame in CIBUF by the engine. The watchdog timer counter
starts incrementing when the Timeout Enable (CWDCFG.EN) is set. The CAN watchdog timer triggers periodic
events E1, E2,…,En after a user-configured timeout prescaler CWDCFG.CTO. If the start condition is true and the
end condition is not true within two events Ei and Ei+1, the CAN watchdog Timeout Error flag
CIBL_STATUS.WDTE is set and the error interrupt INT_8 is triggered if CWDCFG.WTOE is enabled. The buffer with
the Timeout error is indicated by the CITO register. Whenever there is a timeout, the corresponding CIBUF is
taken out of the arbitration. The software shall clear the Timeout status within the CITO register and also clear
the pending request if needed after reading the frame. In case the same CIBUF is to be reused (included again in
the next arbitration), the software shall clear only the Timeout status.
The Timeout period between the events Ei is calculated as follows:
•
Default Timeout period: Tdef = 16
fSRl
•
User-configured Timeout period: Tout = Tdef * CWDCFG.CTO + 1
The table below shows the conditions which trigger a Timeout interrupt.
Table 937
Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within a single event Ei
No Timeout error. No Timeout interrupt triggered
End condition is true within two consecutive events Ei
and Ei+1
If the presence of start condition is detected at Ei,
then the end condition is expected to happen before
Ei+1. If not, the Timeout interrupt is triggered
End condition is true after two consecutive events Ei
and Ei+1
Timeout interrupt is triggered
The table below shows the start and end conditions for the CIBUF.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3752
v1.1
2025-06-26


Table 938
CIBUF : Start and end condition list
Start condition
End condition
Pending request is set for the CAN frame in an
individual buffer CIBUF. The CIBL_BPR.PRj indicates
the pending requests
Pending request is cleared for the CIBUF
Checking the Ethernet Output Buffer full condition
The maximum size of the ACF Payload section is configured at EOBUFj_CONFIG.PL. Before storing a new
ACF_CAN_BRIEF frame into an Ethernet Output Buffer, if the EOBUFj_NTSCF_H0.NTSCFDL will exceed the
configured EOBUF payload size (EOBUFj_CONFIG.PL), the Buffer Full flag (EOBUFj_STATUS.BF) is set by the
hardware and an interrupt is triggered. There is no transmit ready from the DRE in case of Buffer Full scenario.
The software shall use the Buffer Full interrupt to set the TXRDY.
The hardware then checks for the next available Ethernet Output Buffer with a matching Destination ID. If
available, the ACF_CAN_BRIEF message is stored in that buffer, otherwise the ACF_CAN_BRIEF message
processing is aborted and the pending request flag (CIBL_BPR.PRj) of the corresponding CAN Input Buffer is not
cleared.
Write operation to the Ethernet header section
The Transmit Trigger Unit controls the Transmit Ready (EOBUFj_STATUS.TXRDY) condition of each Ethernet
Output Buffer. The CAN-to-Ethernet ACF Assembler continues to stack ACF_CAN_BRIEF messages to the
Ethernet Output Buffer until EOBUFj_STATUS.TXRDY is set by the Transmit Trigger Unit. When
EOBUFj_STATUS.TXRDY is set, the CAN-to-Ethernet ACF Assembler prepares the Ethernet header section of the
Ethernet Output Buffer as follows:
1.
When EOBUFj_CONFIG.HE is set, the contents of the Ethernet header (EOBUFj_MAC_H0,
EOBUFj_MAC_H1, EOBUFj_MAC_H2, EOBUFj_MAC_H3 and EOBUFj_MAC_H4) are written to the header
section of the Ethernet Output Buffer, starting at offset address of 0H from the EOBUF start address
2.
The NTSCF header (EOBUFj_NTSCF_H0, EOBUFj_NTSCF_STREAM0_ID and EOBUFj_NTSCF_STREAM1_ID)
is written to the NTSCF header section of the Ethernet Output Buffer, starting at an offset address of 14H
from the EOBUF start address
3.
The Sequence Number (EOBUFj_NTSCF_H0.SN) is incremented by 1. Upon overflow, the Sequence
Number is wrapped around to 0
4.
The Ethernet Transmit Request bit for the corresponding EOBUF is set in EREQ.TXi_REQ
5.
The assembled Ethernet frame is handed over to the Ethernet Descriptor Handler which triggers an
interrupt to the Interrupt Router module or prepares the Tx descriptors depending on the
TETHDLi_CTRL.TRIG
20.5.3.3
Ethernet ACF-to-CAN disassembler
This section describes the extraction of CAN frames from the input ACF frame.
Related information
Ethernet input buffer on page 3733
20.5.3.3.1
Ethernet input frame
The received Ethernet frames are stored in the Ethernet Input Buffer by the ETH DMA channel or the software. A
new received Ethernet frame in the Ethernet Input Buffer is indicated by the pending request set by the ETH
Descriptor Handler. The Ethernet Input Buffer with a pending request set is processed by the ACF-to-CAN
Disassembler. The Buffer 0 has the highest priority while the Buffer 5 has the lowest priority.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3753
v1.1
2025-06-26


Validation of the Ethernet input frame
The Ethernet input frame is checked for a valid subtype and stream_id in the NTSCF header.
Header type validation
The subtype field starts at offset 0 of the NTSCF header field and is 8 bits long. The value of the subtype field
should be 82H, which corresponds to the Non-Time-Synchronous Control format.
In case of a mismatch to the subtype field, it is checked if the Ethernet frame needs to be forwarded to an
Ethernet destination by performing the Forward ID filtering within the forwarding table (refer to the Forwarding
Engine chapter). When there is no match, the NTSCF Header Format Error flag is set. It is considered an Ethernet
Frame error (EIBUFi_STATUS.FE=1), as the Ethernet input frame cannot be processed further. In this case, the FE
flag is set and the pending request is cleared by the hardware.
Stream ID validation
The stream_id field starts at offset 04H from the start of the NTSCF header and is 64 bits long. The stream_id
value is checked against the Stream-ID filter configuration for acceptance of the Ethernet frame and to
determine the CAN Transmit Routing Table to be used for the routing operation of the CAN frames contained
within the Ethernet input ACF frame. The CAN Transmit Routing Table is identified by the SIDFi_FC.RTI
configuration.
The Stream ID filters support up to 8 filter configurations. The filter mode can be configured as Range filter or
Mask filter using SIDFi_FC.MODE. In Range filter mode, the Stream ID of the Ethernet input frame must fall
within the values between Filter 1 (SIDFi_FIL1_L, SIDFi_FIL1_H) and Filter 2 (SIDFi_FIL2_L, SIDFi_FIL2_H) in
order to pass. In Mask filter mode, the Stream ID of the Ethernet input frame is checked for a match with the
Filter 1 configuration and the Filter 2 value is used as mask for the compare operation. The filtering operation is
terminated with the first matching filter element. When no configured filter is matched, the Ethernet input
frame is checked if it needs to be forwarded to an Ethernet destination by performing the Forward ID filtering
within the Forwarding Table (refer to the Forwarding Engine chapter). When there is still no match, the Invalid
Destination ID flag (EIBUFi_STATUS.IDID) is set and an interrupt INT_10 is triggered. The software fetches the
Ethernet frame from the buffer and clears the pending request.
Note:
In case RETHDLi_CTRL.TRIG is set to 1, the Forward ID filtering is not performed when the Stream ID
filtering returns no match. The Invalid Destination ID flag (EIBUFi_STATUS.IDID) is set and an interrupt
INT_10 is triggered.
Related information
Forwarding engine on page 3787
20.5.3.3.2
ACF_CAN_BRIEF message format decoder
The ACF_CAN_BRIEF messages contained in the Ethernet input frame ACF payload are extracted and formatted
to the CAN frame format of the CAN Output Buffer. In addition, the routing destination of each extracted CAN
frame is requested from the CAN Transmit Routing Engine.
Fetch ACF_CAN_BRIEF
ACF_CAN_BRIEF messages start at offset CH from the NTSCF start address. Initially, the offset address of the
ACF_CAN_BRIEF message to be fetched is indicated in EIBUFi_STATUS.ACF_CAN_ADR. After the fetched
ACF_CAN_BRIEF message is processed, the offset address of the next ACF_CAN_BRIEF message is determined
by the acf_msg_length value of the last fetched message.
New ACF_CAN_ADDR = ACF_CAN_ADDR + acf_msg_length < < 2H
For each fetched ACF_CAN_BRIEF message, the length of the ACF payload is incremented as follows:
ACF_Payload_Length = ACF_Payload_Length + acf_msg_length < < 2H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3754
v1.1
2025-06-26


ACF_CAN_BRIEF messages are fetched from the Ethernet Input Buffer until the calculated ACF_Payload_Length
is equal to the Ntscf_data_length value of the NTSCF header. If it is greater, then the fetched ACF_CAN_BRIEF
message is discarded, the AVTP Length Mismatch Error flag (EIBUFi_STATUS.LME) is set, the Ethernet input
frame is discarded and the EIBUF pending request is cleared.
Validation of ACF_CAN_BRIEF
Each fetched ACF_CAN_BRIEF message is validated for Frame Format and Remote Frame errors before it is
decoded.
Frame format error
The acf_msg_type value of the ACF_CAN_BRIEF message shall be 02H. In case of a mismatch, the CAN Frame
Format Error flag is triggered, the corresponding Ethernet input frame is dropped and the Pending Request flag
is reset.
Remote frame error
When Reject Remote Frame is configured as 1B and the RTR field of the ACF_CAN_BRIEF frame is 1B and FDF is
set to 0B, the EIBUFi_STATUS.RFE flag is set and the next ACF_CAN_BRIEF message is fetched (if available).
When Reject Remote Frame is configured as 0B , the frame is copied without any data bytes.
As there are no remote frames in case of CAN FD format, the DRE_COBUFj_R0.RTR bit is ignored if the FDF bit is
set to 1B.
Routing request
The CAN Identifier field of the validated ACF_CAN_BRIEF message and the Routing Table Index is used to
request the CAN Transmit Routing Engine in order to identify the destination of the CAN frames.
A new routing request is performed when RREQ_CONFIG.REQ bit is cleared. The CAN Identifier and eff values of
the ACF_CAN_BRIEF frame are written to RREQ_CID. The SIDFi_FC.RTI of the matched Stream ID filter is written
to the RREQ_CONFIG.RTI. A routing request is initiated by setting the RREQ_CONFIG.REQ bit by hardware.
The CAN Transmit Routing Engine, after identifying a matching routing rule for the requested CAN frame, writes
the corresponding routing rule in the Routing header (UCRH or MCRH SFR). The index of the Routing Element
used by the CAN Transmit Routing Engine is written to RS.RE. The CAN Transmit Routing Engine acknowledges
back the completion of the routing request by clearing the RREQ_CONFIG.REQ bit.
Frame decoder
The ACF_CAN_BRIEF frame is decoded and written to the CAN Output Buffer.
The ACF_CAN_BRIEF message is formatted and written to the available CAN Output Buffer indicated by the Put
Index of CAN Output Buffer List.
The ACF_CAN_BRIEF message is formatted as follows:
•
Routing header
The Routing header as given by the CAN Transmit Routing Engine is copied to COBUFj_UCRH,
COBUFj_MCRH
•
CAN identifier
The value of the CAN_ID field of the ACF_CAN_BRIEF message is copied to COBUFj_R0.ID
•
Remote transmit request
The value of the RTR field of the ACF_CAN_BRIEF message is copied to COBUFj_R0.RTR
•
Extended CAN identifier
The value of the EFF field of the ACF_CAN_BRIEF message is copied to COBUFj_R0.XTD
•
Error state indicator
The value of the EDI field of the ACF_CAN_BRIEF message is copied to COBUFj_R0.ESI
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3755
v1.1
2025-06-26


•
Data length code
The acf_msg_length and pad bit values are translated to a CAN Data Length Code as specified in the
ACF_CAN_BRIEF message format encoder section. The translated Data Length Code is written to
COBUFj_R1.DLC. In case of an invalid Data Length Code, the CAN Frame Length Error is set and the CAN
frame is dropped
•
Bit-rate switch
The value of the BRS field of the ACF_CAN_BRIEF message is copied to COBUFj_R1.BRS
•
Frame format
The value of the FDF field of the ACF_CAN BRIEF message is copied to COBUFj_R1.FDF
•
CAN payload data
The can_msg_payload data bytes as determined by the calculated DLC of the ACF_CAN_BRIEF message are
copied to the COBUFj_DB fields. The padded bytes are not written to the CAN Output Buffer
Related information
ACF_CAN_BRIEF message format encoder on page 3748
CAN frame completion
The ACF_CAN_BRIEF message decoder also computes a 16-bit CRC (COBUFj_CRC) over the R0, R1 (except ESI,
ANMF, RXTS, FIDX and BRS which are considered as zero), safety critical CAN payload and the DID (which is
padded with zeros to make it 32-bits) of the CAN frame stored in the CAN Output Buffer. It uses the CCITT CRC16
polynomial: 0x1021 x16 + x12 + x5 + 1. The CRC is calculated over 16 bits of data at a time starting with the
MSB.
After successful completion of the write operation of the CRC and the CAN frame to the CAN Output Buffer, the
corresponding Transmit Request bit is set by hardware. The next ACF_CAN_BRIEF message is fetched and
decoded.
The DRE monitors for delayed processing of the CAN frame in COBUF by the Routing Control Unit. The
watchdog timer counter starts incrementing when the Timeout Enable (CWDCFG.EN) is set. The CAN watchdog
timer triggers periodic events E1, E2,…, En after a user-configured timeout prescaler CWDCFG.CTO. If the start
condition is true and the end condition is not true within two events Ei and Ei + 1 , the CAN watchdog Timeout
Error flag COBL_STATUS.WDTE is set and error interrupt INT_9 is triggered if CWDCFG.WTOE is enabled. The
buffer with the Timeout error is indicated by the COTO0 and COTO1 registers. Whenever there is a timeout, the
corresponding COBUF is taken out of the arbitration. The software shall clear the Timeout status within the
COTO0 and COTO1 registers and also clear the pending request if needed after reading the frame. In case the
same COBUF is to be reused (included again in the next arbitration), the software shall clear only the Timeout
status.
The Timeout period between the events Ei is calculated as follows:
•
Default Timeout period: Tdef = 16
fSRI
•
User-configured Timeout period: Tout = Tdef * CWDCFG.CTO + 1
The table below shows the conditions which trigger a Timeout interrupt.
Table 939
Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within a single event Ei
No Timeout error. No Timeout interrupt triggered
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3756
v1.1
2025-06-26


Table 939
(continued) Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within two consecutive events Ei
and Ei + 1
If the presence of start condition is detected at Ei,
then the end condition is expected to happen before
Ei+1. If not, the Timeout interrupt is triggered
End condition is true after two consecutive events Ei
and Ei + 1
Timeout interrupt is triggered
The table below shows the start and end conditions for the COBUF.
Table 940
COBUF : Start and end condition list
Start condition
End condition
Pending request is set for the CAN frame in an
individual buffer COBUF. The COBL_BPR0 and
COBL_BPR1 indicate the pending requests
Pending request is cleared for the COBUF
Related information
Fetch ACF_CAN_BRIEF on page 3754
20.5.3.3.3
Completion of the Ethernet frame
All CAN frames contained within the input ACF frame are considered to be processed when the calculated ACF
payload length matches with the NTSCF_data_length value of the NTSCF header. Upon successful completion,
the pending request of the Ethernet Input Buffer (EIBUFi_STATUS.BPR) is cleared by hardware.
20.6
CAN transmit routing engine and routing control unit
The CAN Transmit Routing Engine and the Routing Control Unit are responsible for the routing of CAN frames to
CAN peripherals.
20.6.1
Feature list
•
Up to 4 user-configurable CAN Transmit Routing Tables
•
Up to 128 user-configurable routing rules per CAN Transmit Routing Table
•
The following routing modes are supported:
-
Uni-cast
-
Multi-cast (up to 4 configurable destination CAN interfaces)
•
Up to 128 user-configurable CAN ID-based acceptance or rejection filters per CAN Transmit Routing Table
•
Processing of multiple routing requests:
-
Requests from source CAN nodes
-
Requests from the CAN Output Buffer List
•
Non-starving arbitration of routing requests
•
CAN routing transfer to the following destinations:
-
CAN nodes
-
ACF Ethernet frames
-
System memory
•
FPI and SRI transactions by the Move Engine
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3757
v1.1
2025-06-26


20.6.2
Functional overview
The figure below shows the block diagram of the CAN Transmit Routing Engine and the Routing Control Unit.
Ethernet 
Descriptor  
Handler
Ethernet ACF to CAN 
Disassembler
ACF CAN-Ethernet Format 
Engine
Routing request
CAN Transmit Routing Engine
1
2
1
2
1
2
CAN Transmit 
Routing Table
1 to 4
1
2
Max. 128
Routing Control Unit
Move Engine
CRE service 
request
(Message RAM)
Extracted CAN frames
CAN Output 
Buffer List
1
2
64
(Message RAM)
COBUF 
request
FPI Master
SRI Master
CAN Address 
Database
Ethernet 
Address 
Database
(Message RAM)
Figure 353
CAN Transmit Routing Engine and Routing Control Unit block diagram
The CAN Transmit Routing Engine is responsible for identifying the transmit destination of a CAN frame in the
CAN Output Buffer List (Ethernet to CAN routing use case), whereas the Routing Control Unit assists, together
with the Move Engine, in the transfer of CAN frames and Ethernet frames.
20.6.3
Functional description
In this section, the routing of transmit CAN frames and the functions of the CAN Transmit Routing Engine and
the Routing Control Unit are described in detail.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3758
v1.1
2025-06-26


20.6.3.1
CAN transmit routing engine
The CAN Transmit Routing Engine is responsible for identifying the transmit destination CAN interface of a CAN
frame.
20.6.3.1.1
Initiating routing operation
The routing function of the CAN Transmit Routing Engine is initiated when a CAN Routing Request is set. When
the CAN Routing Request is set, the CAN Transmit Routing Engine uses the following registers to identify the
destination of the CAN frame:
•
RREQ_CONFIG.RTI to identify the CAN Transmit Routing Table (1 to 4)
•
RREQ_CID.ID and XTD for acceptance filter scanning
20.6.3.1.2
CAN acceptance filters
Each routing element in a CAN Transmit Routing Table contains the following:
•
CAN ID filter (RT_REj_CIDFC ( j = 0-127))
•
Routing rule (RT_REj_UCR or RT_REj_MCR ( j = 0-127))
The CAN ID filter contains the acceptance condition for a given CAN ID. The CAN ID (RREQ_CID.ID) and the
Extended Identifier (RREQ_CID.XTD) of the CAN Routing Request are scanned through the CAN ID filters of each
routing element. When a match occurs, the corresponding routing rule is used to identify the destination of the
requested CAN frame. Disabled routing rules are not used for the filter operation. The scanning operation is
performed starting from routing element 0 and ends with the routing element with the first matching CAN ID
filter.
The CAN ID filter supports 3 modes of operation (RT_REj_CIDFC.MODE):
•
Classical ID filter (MODE = 00B):
-
RT_REj_CIDFC.CANID1 is used as the CAN ID filter and RT_REj_CIDFC.CANID2 is used as the mask. A
mask value with bit positions having "0b" causes the corresponding bits of CAN ID1 to be ignored for
matching with the requested CAN ID (RREQ_CID.ID). A mask value of all 1 causes a successful match
only if the requested CAN ID is exactly same as the RT_REj_CIDFC.CANID1 value. Similarly, a mask value
of all 0 causes any CAN ID value to match
•
Dual ID filter (MODE = 01B):
-
RT_REj_CIDFC.CANID1 or RT_REj_CIDFC.CANID2 is used as the CAN ID filter. The requested CAN ID must
exactly match to either RT_REj_CIDFC.CANID1 or RT_REj_CIDFC.CANID2. No masking bits are used
•
Range ID filter (MODE = 10B):
-
The range of IDs between RT_REj_CIDFC.CANID1 and RT_REj_CIDFC.CANID2, inclusive, are used as CAN
ID filters. The requested CAN ID must be between RT_REj_CIDFC.CANID1 (inclusive) and
RT_REj_CIDFC.CANID2 (inclusive) for a match
On successful identification of the routing element with a matching CAN ID filter, the corresponding routing rule
(RT_REj_UCR or RT_REj_MCR) is written to the routing header (UCRH or MCRH) of the CAN frame and the
Routing Request flag (RREQ_CONFIG.REQ) is reset to 0. The corresponding routing element index is written to
the RS.RE bit-field.
Related information
CAN transmit routing tables (1 to 4) on page 3730
20.6.3.1.3
Error scenarios
Invalid routing table error
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3759
v1.1
2025-06-26


When the CAN Transmit Routing Table indexed by the routing request (RREQ_CONFIG.REQ) is disabled or
reserved, then the Invalid Routing Table flag (RS.IRT) is set.
Non-matched filter element error
When no matching CAN ID filter is found in the indexed CAN Transmit Routing Table, the Non-Matching Filter
Element Error flag (RS.NMFE) is set.
20.6.3.2
Routing control unit
This section describes the handing of the CAN routing operation.
Related information
CAN address database on page 3726
20.6.3.2.1
CAN trigger request
The MCMCAN module generates Receive and Transmit Host Buffer triggers for the DRE.
The trigger request from a CAN node consists of the following signals:
•
TRIGTYPE(0:1): Indicates the host buffer (Receive Host Buffer 0/1 or Transmit Host Buffer 0) related to the
trigger request
•
TRIGNODE(0:1): Indicates the CAN node within the MCMCAN module related to the trigger request
The table below shows the encoding of the TRIGTYPE trigger.
Table 941
TRIGTYPE description
TRIGTYPE(1)
TRIGTYPE(0)
Description
0B
0B
No trigger or idle
0B
1B
Transmit Host Buffer 0 free
1B
0B
New Receive Host Buffer 0
1B
1B
New Receive Host Buffer 1
Although the MCMCAN module provides two Transmit Host Buffers, only the Transmit Host Buffer 0 can be
configured to trigger the DRE. CAN Receive Host Buffer 0 or 1 requests from the MCMCAN module indicates to
the DRE that a new Receive CAN frame from the corresponding CAN node is pending to be fetched. The DRE in
this case sets a pending Receive Request flag for the corresponding CAN node (CANRXR0, CANRXR1). A CAN
Transmit Host Buffer 0 request from MCMCAN module indicates to the DRE that the corresponding CAN node
has a free Transmit Host Buffer. The DRE in this case sets a pending Transmit Request flag for the corresponding
CAN node (CANTXR).
The table below shows the encoding of the TRIGNODE trigger.
Table 942
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
20  Data Routing Engine (DRE)
Reference manual
3760
v1.1
2025-06-26


20.6.3.2.2
Routing requests
The Routing Control Unit receives routing requests from CAN nodes (through CAN trigger request inputs) and
from CAN Output Buffers.
Routing requests from CAN nodes
CAN Receive Host Buffers pending requests (CANRXR0, CANRXR1) are processed by the Routing Control Unit in a
round-robin (non-starving) priority scheme, starting with the MCMCAN0 Node 0 request until the maximum
number of available CAN node requests is reached. Within a CAN node request, the Receive Host Buffer 0
(CANRXR0.Ci_RH0R, CANRXR1.Ci_RH0R) gets a higher priority than the Receive Host Buffer 1
(CANRXR0.Ci_RH1R, CANRXR1.Ci_RH1R).
CAN node address decoding
The CAN Address Database in the DRE RAM always starts at the DRE RAM base address. The CAN Address
Database is configured by the user with the CRE start address (CAD_CANi_CRESA.ADR). An overview of the
Receive and Transmit Host Buffers structure and address decoding is given in the figure below. Refer to the CAN
chapter for detailed description.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3761
v1.1
2025-06-26


THBUF1_T0
THBUF1_T1
THBUF1_DBm
THBUF1_CRC
THBUF0_CRC
RHBUF1_CRC
RHBUF0_CRC
RHBUF0_UCRH
RHBUF0_THEAD_INTRD, 
RHBUF0_THEAD_RXTS
RHBUF0_R0
RHBUF0_R1
RHBUF0_DBm
CAD_CANi_CRESA.ADR
+ 0x24
+ 0x30
+ 0x38
1 word
2 words
1 word
1 word
16 words
RHBUF1_UCRH
RHBUF1_THEAD_INTRD, 
RHBUF1_THEAD_RXTS
RHBUF1_R0
RHBUF1_R1
RHBUF1_DBm
CAD_CANi_CRESA.ADR+ 0x80
+ 0x84
+ 0x90
+ 0x98
1 word
2 words
1 word
1 word
16 words
THBUF0_T0
THBUF0_T1
THBUF0_DBm
1 word
1 word
16 words
CAD_CANi_CRESA.ADR+ 0xE0
CAN CRE Host Buffers structure in 
MCMCAN module internal RAM
CRE_CONFIG
+ 0x20
Start of Receive Host Buffer 0 
(RHBUF0)
Start of Transmit Host Buffer 0
(THBUF0)
Start of Receive Host Buffer 1 
(RHBUF1)
1 word
1 word
+ 0x2C
+ 0x8C
1 word
1 word
1 word
16 words
1 word
Start of Transmit Host Buffer 1
(THBUF1)
+ 0xEC
CAD_CANi_CRESA.ADR+ 0x130
+ 0xE4
+ 0x134
+ 0x13C
Reserved
Reserved
2 words
1 word
Reserved
2 words
Reserved
1 word
Reserved
CRE_ABORT_SEQ
+ 0x18
Figure 354
CAN CRE host buffer structure
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3762
v1.1
2025-06-26


When a new request from a CAN node is received, the DRE Move Engine transfers the CAN frame from the
respective CAN Receive Host Buffer to the corresponding destination(s) as indicated in the routing header
(RHBUFk_UCRH).
Requests from RHBUF0
The DRE performs the following after receiving a request from RHBUF0 of a CAN node CANi:
•
The Routing header is read from the user-configured CAD_CANi_CRESA.ADR + 20H address
•
The Timing header (2 words) is read from the CAD_CANi_CRESA.ADR +24H address
•
The CRC header (1 word) is read from the CAD_CANi_CRESA.ADR +2CH address
•
The CAN header or PDU header (2 words) RHBUF0_R0 and R1 are read from the CAD_CANi_CRESA.ADR
+30H address
•
The CAN data bytes RHBUF0_DBm are read from the CAD_CANi_CRESA.ADR +38H address. The number of
data bytes to be read is defined by the Data Length Code (DLC) of the CAN frame (RHBUF0_R1.DLC)
Requests from RHBUF1
The DRE performs the following after receiving a request from RHBUF1 of CAN Node CANi:
•
The Routing header is read from the user-configured CAD_CANi_CRESA.ADR +80H address
•
The Timing header (2 words) is read from the CAD_CANi_CRESA.ADR +84H address
•
The CRC header (1 word) is read from the CAD_CANi_CRESA.ADR +8CH address
•
The CAN header or PDU header (2 words) RHBUF1_R0 and R1 are read from the CAD_CANi_CRESA.ADR
+90H address
•
The CAN data bytes RHBUF1_DBm are read from the CAD_CANi_CRESA.ADR +98H address. The number of
data bytes to be read is defined by the Data Length Code (DLC) of the CAN frame (RHBUF1_R1.DLC)
The fetched CAN frame is routed to the assigned destination(s) as described in the chapter Routing transfer.
After a successful routing transfer, the CAN Receive Host Buffer pending requests (CANRXR0.Ci_RH0R, Ci_RH1R,
CANRXR1.Ci_RH0R, Ci_RH1R) are cleared by hardware.
Related information
Routing transfer on page 3765
Routing requests from CAN output buffers
CAN Output Buffers store CAN frames to be transmitted to CAN nodes. Pending CAN frames in the CAN Output
Buffer are indicated by COBL_BPR0 or COBL_BPR1. Among pending CAN frames, the highest priority CAN frame
which has all its destinations available is selected for routing transfer. The priority of the CAN frame is defined
by the corresponding CAN ID. CAN frames with the lowest CAN ID value have the highest priority as defined by
ISO 11898-1. When multiple buffers have CAN frames of equal priority with the same CAN ID, the CAN frame in
the buffer with the lowest index is selected for routing transfer.
The Routing Control Unit determines the availability of a destination according to the following:
•
A CAN node as a destination is said to be available when the corresponding Transmit Host Buffer
request bit (CANTXR.Ci_THR) is set. The DRE always writes only into the Transmit Host Buffer 0
(CAD_CANi_CRESA.ADR +E0H)
Note:
In the MCMCAN module, the CRE Tx Host Buffer 0 has to be configured to trigger the DRE by
setting Ni_CRE_HBUF_TX0_CONFIG.INTEN to 0B
•
An Ethernet frame as a destination is said to be available when the CAN Input Buffer List has free buffers
(CIBL_STATUS.BF = 0)
•
A memory destination is said to be available when enabled in DMEMi_CONFIG.EN = 1
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3763
v1.1
2025-06-26


After successful routing transfer, the pending request of the CAN Output Buffer (COBL_BPR0.PRj,
COBL_BPR1.PRj) is cleared by hardware.
Related information
CAN output buffer pending request 0 on page 3816
CAN output buffer list on page 3728
Priority between requests from CAN nodes and CAN output buffers
When CAN Receive Host Buffers and CAN Output Buffers have pending requests at the same time, the routing
requests are serviced alternately between them, giving them equal priority. The following figure shows an
example with 4 CAN nodes (C0 to C3) with 2 pending receive requests and 4 CAN Output Buffers with 3 pending
requests.
0
1
1
0
1
CANRXR0
C2_RH0R
1
0
0
C2_RH1R
C3_RH0R
C3_RH1R
1
C0_RH0R
0
0
0
C0_RH1R
C1_RH0R
C1_RH1R
COBL_BPR0
PR0
PR1
PR2
PR3
CAN FRAME ID
0x8
0x1
0x3
0x5
CAN FRAME ID
0
1
1
0
1
C2_RH0R
1
0
0
C2_RH1R
C3_RH0R
C3_RH1R
1
C0_RH0R
0
0
0
C0_RH1R
C1_RH0R
C1_RH1R
PR0
PR1
PR2
PR3
0x8
0x1
0x3
0x5
0
1
1
0
1
C2_RH0R
0
0
0
C2_RH1R
C3_RH0R
C3_RH1R
1
C0_RH0R
0
0
0
C0_RH1R
C1_RH0R
C1_RH1R
PR0
PR1
PR2
PR3
0x8
0x1
0x3
0
0
1
0
1
C2_RH0R
0
0
0
C2_RH1R
C3_RH0R
C3_RH1R
1
C0_RH0R
0
0
0
C0_RH1R
C1_RH0R
C1_RH1R
PR0
PR1
PR2
PR3
0x8
0x3
0
0
1
0
1
C2_RH0R
0
0
0
C2_RH1R
C3_RH0R
C3_RH1R
0
C0_RH0R
0
0
0
C0_RH1R
C1_RH0R
C1_RH1R
PR0
PR1
PR2
PR3
0x8
0x9
0x9
0x9
0x9
0x9
0
0
1
0
0
C2_RH0R
0
0
0
C2_RH1R
C3_RH0R
0
C0_RH0R
0
0
0
C0_RH1R
C1_RH0R
C1_RH1R
PR0
PR1
PR2
PR3
0x9
time
Pending Routing 
requests
Last serviced CAN node 
request
Granted routing 
request
t0
t1
t2
t3
t4
t5
Figure 355
An example of priority handling between CAN receive requests and CAN output buffer
requests
In the previous figure, it can be assumed that before time 't0', the pending request PR1 in the CAN Output Buffer
List is serviced, then at 't1', the CAN Receive Host Buffer pending requests are granted an opportunity to
perform routing transfer. Since the last serviced CANRXR0 is C1_RH1R, the next pending request in the round-
robin scan is C2_RH1R. Therefore, the C2_RH1R routing request is serviced at 't1'. After successful routing
operation, the CAN Output Buffer List pending requests are handled. At time 't2', the PR3 request is granted
since the corresponding CAN frame has the highest priority CAN ID (ID=0x1) among the pending requests in the
CAN Output Buffer List (PR0 & PR2). Similarly, at 't3' and 't4' CAN receive requests and CAN Output Buffer
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3764
v1.1
2025-06-26


pending requests are serviced alternately. At 't5', since there are no more pending CAN receive requests, the
CAN Output Buffer List pending request PR2 is chosen again for routing transfer.
In case of any error (such as bus error, IRDE or DBOE), where the ongoing transaction has to be canceled by the
DRE, the DRE writes into the CRE_ABORT_SEQ at the CAD_CANi_CRESA.ADR + 18H address. The abort
sequence is triggered by the DRE only after it starts reading the CAN payload and before the last read or write
operation is launched.
Related information
Routing requests from CAN nodes on page 3761
Routing requests from CAN output buffers on page 3763
20.6.3.2.3
Routing transfer
The routing transfer function moves CAN frames from a source to their corresponding destination(s).
CAN routing header
The destination of a CAN frame is indicated by the routing header of the corresponding CAN frame. When a
routing transfer request for a pending CAN frame is received, the routing header is read by the Routing Control
Unit to identify the destination of the CAN frame.
The following CAN routing header types are supported:
•
Uni-cast routing: In the case of CAN to CAN routing, CAN to Ethernet routing and vice versa
•
Multi-cast routing: In the case of Ethernet to CAN routing (by the DRE). The multi-cast routing of CAN
frames is performed as a sequence of uni-cast routing operations by the CRE
•
PDU routing: In the case of CAN to memory routing
Uni-cast routing
In uni-cast routing, the CAN frame is routed to only a single destination. It is indicated in the routing header
with MODE = 00B.
Multi-cast routing
In multi-cast routing, the CAN frame is routed to up to 4 destinations. It is indicated in the routing header with
MODE = 01B.
Multi-cast routing is supported by the DRE for Ethernet to CAN routing. Multi-cast routing for CAN frames is
handled by the CRE.
The multi-cast rule must follow the below configuration rules:
•
Unused DIDs are set to zero
•
At least DID0 and DID1 should have valid destination IDs (1H to 14H)
-
Invalid configuration: DID0 or/and DID1 are set to zero
•
All valid DIDs are different. If the DIDs are the same, the CAN frame is routed only once
•
No gaps are allowed between valid DIDs. For example:
-
Valid configuration: DID0, DID1 and DID2 are valid
-
Invalid configuration: DID0, DID1 and DID3 are valid. DID2 is set to zero
The routing transfer is performed in order from destination 1 to destination 4. The CAN frame is routed only
when all relevant destinations are available. Destinations with DID=0 are ignored. The IRDE bit-field is set when
there are no valid DIDs for a CAN frame and the routing operation is aborted. The DRE writes into the
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3765
v1.1
2025-06-26


CRE_ABORT_SEQ at the CAD_CANi_CRESA.ADR + 18H address. The abort sequence is triggered by the DRE only
after it starts reading the CAN frame and before the last read or write operation is launched. The DRE cancels
the ongoing read sequence by writing 1B to CRE_ABORT_SEQ.CRHBUF0 or CRHBUF1 if it has already started
reading the CAN frame (R0, R1, DBm) after the error has occurred. The DRE cancels the ongoing write sequence
to Tx Host Buffer 0 by writing 1B to CRE_ABORT_SEQ.CTHBUF0 if it has already started writing the CAN frame
(T0, T1, DBm) after the error has occurred.
In multi-cast routing, the Ethernet ACF-to-CAN Disassembler computes a 16-bit CRC over the R0, R1 (except ESI,
ANMF, RXTS, FIDX and BRS which are considered as zero) and the safety critical CAN payload (without DID). This
intermediate CRC is stored in the COBUF. While writing the frame from the COBUF to the Tx Host Buffer 0, at the
moment of writing the CRC, the CRC is re-computed by the DRE including the DID0. The same is done for all 4
DIDs (DID0 to DID3) before the corresponding write operations.
PDU routing
In PDU routing, the CAN I-PDU is routed to a single destination. It is indicated in the uni-cast routing header
with MODE = 10B. The CAN I-PDU is routed to the system memory location indicated by the DID bit in the routing
header.
Routing destinations
This section describes the possible routing destinations for a CAN frame.
A CAN frame can have the following routing destinations:
•
CAN node
•
ACF Ethernet frame
•
User-configured memory location
Each destination is allocated with a 6-bit unique ID. The table below shows the IDs relevant for each destination
type and the respective routing transfer destinations.
Table 943
Routing destinations ID
Destination
ID (6 bits)
Transfer destination
Destination disabled
0H
-
MCMCAN0_Ni (i=0:3)
1H to 4H
CAN Transmit Host Buffer 0
(MCMCAN0_Ni_THBUF0)
MCMCAN1_Ni (i=0:3)
5H to 8H
CAN Transmit Host Buffer 0
(MCMCAN1_Ni_THBUF0)
MCMCAN2_Ni (i=0:3)
9H to CH
CAN Transmit Host Buffer 0
(MCMCAN2_Ni_THBUF0)
MCMCAN3_Ni (i=0:3)
DH to 10H
CAN Transmit Host Buffer 0
(MCMCAN3_Ni_THBUF0)
MCMCAN4_Ni (i=0:3)
11H to 14H
CAN Transmit Host Buffer 0
(MCMCAN4_Ni_THBUF0)
ACF Ethernet frames
18H to 1DH
DRE CAN Input Buffer List
System memory locations (1 to 28)
20H to 3BH
User-configured by DMEM (0-27)
Reserved for future extension
Others
-
When the DID in the routing header from the CRE does not belong to any valid destination, the IRDE bit is set by
the DRE and an interrupt is triggered.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3766
v1.1
2025-06-26


CAN node as destination (ID = 1H to 14H)
When the destination of the CAN frame is a CAN node (Destination ID = 1H to 14H), then the CAN frame is
transferred to the CAN Transmit Host Buffer 0 of the destination CAN node that is configured for the DRE.
The following requests can have a CAN node as destination:
•
Requests from a source CAN node
•
Requests from the CAN Output Buffer List
Requests from a source CAN node
The following occurs if the source request is from a CAN node (CANRXR0, CANRXR1):
1.
The pending request of the Transmit Host Buffer 0 (CANTXR) of the destination CAN node is checked
2.
If a pending request for the destination CAN node is set (CANTXR), the CAN frame starting from
RHBUFk_R0 until the data bytes defined by DLC is read from the source and written to the destination
CAN frame Transmit Host Buffer 0 (the length of data bytes to be written is defined by DLC). The source
CAN node request (CANRXR0, CANRXR1) is cleared when the DRE starts reading the RHBUFk_R0
3.
After a successful transfer to the destination CAN Transmit Host Buffer 0, the destination Transmit Host
Buffer 0 request (CANTXR.Ci_THR) is cleared
4.
If the destination CAN node has its Transmit Host Buffer 0 pending request cleared, and if a CAN Output
Buffer is free (COBL_STATUS.BF = 0), then the CAN frame along with the routing header is transferred
to the CAN Output Buffer and the corresponding COBL_BPR1 and COBL_BPR0 pending request is set. In
this case, the source request (CANRXR0, CANRXR1) is cleared after the CAN frame is written successfully
to the CAN Output Buffer. Otherwise, the source CAN frame is aborted from the routing transfer, without
clearing the source request
5.
During a routing transfer, if the length of the source CAN frame is bigger than the destination buffer
(Transmit Host Buffer 0 size or CAN Output Buffer size), the source CAN frame is dropped with the
Destination Buffer Overflow Error flag set (ME_ERR.DBOE ). In this case, the corresponding source
request is cleared
Requests from the CAN output buffer list
The following occurs if the source request is from the CAN Output Buffer List (COBL_BPR1 and COBL_BPR0):
1.
The pending request of the Transmit Host Buffer 0 (CANTXR) of the destination CAN node is checked
2.
If a pending request for a destination CAN node is set (CANTXR), the CAN frame starting from COBUFj_R0
until the data bytes defined by COBUFj_R1.DLC are read from the source and written to the destination
CAN node Transmit Host Buffer 0
3.
After a successful transfer to the destination CAN Transmit Host Buffer 0, the source request (CAN Output
Buffer request) and the destination Transmit Host Buffer 0 request (CANTXR.Ci_THR) are cleared
4.
If the destination CAN node has the Transmit Host Buffer 0 pending request cleared, the source CAN
frame is aborted from routing transfer without clearing the source request
ACF Ethernet frame as destination (ID = 18H to 1DH)
When the destination of the CAN frame is an ACF Ethernet frame (Destination ID = 18H to 1DH), then the CAN
frame is transferred to an available CAN Input Buffer indexed by CIBL_STATUS.PIDX. The CAN frame starting
from the RHBUFk_CRC, RHBUFk_R0 until the data bytes defined by RHBUFk_R1.DLC is read from the source
and written to the CAN Input Buffer. After a successful transfer, the source request (CANRXR0 and CANRXR1) is
cleared and the pending request in the corresponding CAN Input Buffer (CIBL_BPR) is set.
If the CAN Input Buffer List is full (CIBL_STATUS.BF=1), then the source CAN frame is aborted from routing
transfer without clearing the source request.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3767
v1.1
2025-06-26


System memory as destination (ID = 20H to 3BH)
When the destination of the CAN message is a system memory location (Destination ID = 20H to 3BH) and the
corresponding destination memory (DMEMi) is enabled (DMEMi_CONFIG.EN1=1B), then the CAN message is
transferred to the system memory location with the starting address (DMEMi_SA.ADR) configured by the user in
the DMEM parameter table. The index i of DMEMi is derived from the destination ID (i = destination ID - 20H).
The user should configure the following levels for each DMEM in the DMEM parameter table:
•
Watermark (DMEMi_WM) if required
•
Wraparound (DMEMi_WA)
The user should also configure the CAN message type being received by a DMEM (DMEMi_CONFIG.CTYP). The
following CAN message types are supported:
•
CAN frames (DMEMi_CONFIG.CTYP = 0B)
•
CAN I-PDUs (DMEMi_CONFIG.CTYP = 1B)
Related information
DMEM parameter table on page 3741
CAN message buffer layout
The user can create a circular list of CAN Message Buffers to store CAN messages in the DMEM. The following
figure shows the CAN Message Buffer layout for CAN frames (DMEMi_CONFIG.CTYP = 0) within the DMEMi.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3768
v1.1
2025-06-26


System memory 
destination
DMEMi start address (absolute) = 
DMEMi_SA.ADR
+  0x0  
+  DMEMi_CONFIG.OA
( 64 bit address aligned)
0
63
31
32
CAN Message Buffer 0
Buffer size defined by 
DMEMi_CONFIG.OA (64 bit address 
aligned)
Number of Buffers =
DMEMi_STATUS.WAL+1 
(max 128)
DMEMi_STATUS 
(if DMEM_CONFIG.AST=1)
RHBUFk_THEAD_INTRD
(if DMEM_CONFIG.ATH=1)
RHBUFk_THEAD_RXTS
(if DMEM_CONFIG.ATH=1)
RHBUFk_R0
RHBUFk_R1
RHBUFk_DB3 – DB0
RHBUFk_DB63 – DB60
GAP
CAN Message Buffer 1
CAN Message Buffer 127
Figure 356
CAN Message Buffer layout for CAN frames
The CAN Message Buffer layout must have the following characteristics:
•
The size of the CAN Message Buffers is defined by DMEMi_CONFIG.OA
•
The total number of CAN Message Buffers in the circular list is defined by the configured Wraparound level
(DMEMi_WA.WAL+1)
•
The CAN Message Buffer Index at which the next CAN message is to be stored is shown in
DMEMi_STATUS.BC
•
The start address of each CAN Message Buffer can be identified as DMEMi_SA.ADR + (DMEMi_STATUS.BC *
DMEMi_CONFIG.OA)
Note:
The Watermark level (DMEMi_WM) must always be smaller than the Wraparound level.
CAN message buffer layout mode
The user can configure DMEMi_MODE.BUF to set the layout mode of the CAN Message Buffer. The following
layout modes are supported:
•
Single (DMEMi_MODE.BUF = 0B)
•
Continuous (DMEMi_MODE.BUF = 1B)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3769
v1.1
2025-06-26


These layout modes apply for DMEMs configured for both CAN message types, CAN frames
(DMEMi_CONFIG.CTYP = 0B) and CAN I-PDUs (DMEMi_CONFIG.CTYP = 1B).
Single mode
In Single mode (SINGLE, DMEMi_MODE.BUF = 0B), the CAN Message Buffer is split into the following two buffers:
•
Frame Data Buffer 1 (based on the Watermark level DMEMi_WM)
•
Frame Data Buffer 2 (based on the Wraparound level DMEMi_WA)
Both Frame Data Buffers always start at the 64-bit aligned address. The DRE triggers a Watermark and a
Wraparound interrupt when the set DMEMi_WM and DMEMi_WA levels are reached.
Single mode supports the following trigger modes:
•
Index-based trigger (INDEX, DMEMi_MODE.TRIG = 0B): This mode is valid only for CAN I-PDUs. For CAN
frames this bit is ignored and the Count-based trigger mode is used. In the Index-based trigger mode, the
Watermark and Wraparound interrupts are triggered based on the DMEMi_FDBI value. The DMEMi_WM and
DMEMi_WA levels are configured as words in this case
•
Count-based trigger (COUNT, DMEMi_MODE.TRIG = 1B): In this mode, the Watermark and Wraparound
interrupts are triggered based on the DMEMi_STATUS.BC value. The DMEMi_WM and DMEMi_WA levels are
configured as number of CAN frames or CAN I-PDUs. The size of Frame Data Buffer 1 and Frame Data Buffer
2 are allocated based on DMEMi_WM, DMEMi_WA and DMEMi_CONFIG.OA
Continuous mode
In Continuous mode (CONT, DMEMi_MODE.BUF = 1B), the CAN Message Buffer is considered as a whole buffer
and the CAN messages are assembled continuously until the Wraparound level (DMEMi_WA) is reached.
Continuous mode supports the following trigger modes:
•
Index-based trigger (INDEX, DMEMi_MODE.TRIG = 0B): This mode is valid only for CAN I-PDUs. For CAN
frames this bit is ignored and the Count-based trigger mode is used. In the Index-based trigger mode, the
Wraparound interrupt is triggered based on the DMEMi_FDBI value. The DMEMi_WA level is configured as
words in this case
•
Count-based trigger (COUNT, DMEMi_MODE.TRIG = 1B): In this mode, the Wraparound interrupt is triggered
based on the DMEMi_STATUS.BC value. The DMEMi_WA level is configured as number of CAN frames or CAN
I-PDUs. The size of Frame Data Buffer 1 is allocated based on DMEMi_WA and DMEMi_CONFIG.OA
CAN message buffer packing
DMEMi_MODE.TYP enables the user to configure the CAN Message Buffer packing type. The following packing
types can be configured:
•
Multiplexing disabled (MUXDIS, DMEMi_MODE.TYP = 0B): The CAN messages (CAN frames or CAN I-PDUs) are
packed in the same way as shown in the figure CAN Message Buffer layout for CAN frames (see above). The
size of the CAN Message Buffer is defined by DMEMi_CONFIG.OA. In this case, there will be padding bits
between the CAN messages as each CAN message starts at a 32-bit aligned address and no FDBI is present
to indicate the exact length
•
Multiplexing enabled (MUXEN, DMEMi_MODE.TYP = 1B): This mode is valid only for CAN I-PDUs. The CAN I-
PDUs are packed without any padding bits in between them. This mode can be used when the CAN I-PDUs
are to be multiplexed into a frame, for example, an Ethernet frame. The size of the assembled frame is
defined by DMEMi_FDBI which is incremented by the size of the CAN I-PDU after each CAN I-PDU is
transferred to the DMEM
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3770
v1.1
2025-06-26


Related information
CAN message buffer layout on page 3768
Destination memory transfer mode configurations
The following table shows a summary with the possible applicable DMEMi transfer mode configurations
(DMEMi_MODE) depending on the CAN message type being received by the DMEMi (DMEMi_CONFIG.CTYP).
Table 944
Applicable DMEMi transfer mode configurations
DMEMi_MODE
DMEMi_CONFIG.CTYP Description
TYP
TRIG
BUF
CAN
frame1)
CAN I-
PDU1)
MUXDIS COUNT
CONT
✔
✔
•
Space between CAN frames/CAN I-PDUs depending on
the DLC
•
Interrupt trigger based on the number of CAN
frames/CAN I-PDUs
•
CAN frames/CAN I-PDUs are assembled continuously
with no DMEMi division
MUXDIS COUNT SINGLE
✔
✔
•
Space between CAN frames/CAN I-PDUs depending on
the DLC
•
Interrupt trigger based on the number of CAN
frames/CAN I-PDUs
•
DMEMi divided into FDB1 and FDB2. CAN frames/CAN
I-PDUs are assembled first in FDB1 followed by FDB2
MUXDIS
INDEX
CONT
✔
✔
•
Space between CAN frames/CAN I-PDUs depending on
the DLC
•
Interrupt trigger based on the index (FDBI)
•
CAN frames/CAN I-PDUs are assembled continuously
with no DMEMi division
MUXDIS
INDEX
SINGLE
✔
✔
•
Space between CAN frames/CAN I-PDUs depending on
the DLC
•
Interrupt trigger based on the index (FDBI)
•
DMEMi divided into FDB1 and FDB2. CAN frames/CAN
I-PDUs are assembled first in FDB1 followed by FDB2
MUXEN
COUNT
CONT
✘
✔
•
No space between CAN I-PDUs
•
Interrupt trigger based on the number of CAN I-PDUs
•
CAN I-PDUs are assembled continuously with no
DMEMi division
MUXEN
COUNT SINGLE
✘
✔
•
No space between CAN I-PDUs
•
Interrupt trigger based on the number of CAN I-PDUs
•
DMEMi divided into FDB1 and FDB2. CAN I-PDUs are
assembled first in FDB1 followed by FDB2
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3771
v1.1
2025-06-26


Table 944
(continued) Applicable DMEMi transfer mode configurations
DMEMi_MODE
DMEMi_CONFIG.CTYP Description
TYP
TRIG
BUF
CAN
frame1)
CAN I-
PDU1)
MUXEN
INDEX
CONT
✘
✔
•
No padding bytes between CAN I-PDUs
•
Interrupt trigger based on the index (FDBI)
•
CAN I-PDUs are assembled continuously with no
DMEMi division
MUXEN
INDEX
SINGLE
✘
✔
•
No space between CAN I-PDUs
•
The interrupt trigger is based on the index (FDBI)
•
DMEMi divided into FDB1 and FDB2. CAN I-PDUs are
assembled first in FDB1 followed by FDB2
1)
✔ = applicable, ✘= not applicable
CAN frames to system memory
For every CAN frame routing where DMEMi_CONFIG.CTYP is set to 0B (CAN frame) by the user, the following
tasks are performed:
1.
If DMEMi_CONFIG.ATH = 1, the CAN frame Timing headers (RHBUFk_THEAD_INTRD and
RHBUFk_THEAD_RXTS) are copied as the first two words of the current CAN Message Buffer
2.
If both DMEMi_CONFIG.AST=1 and DMEMi_CONFIG.ATH = 1 are set, DMEMi_STATUS and the Timing
headers are copied
3.
The CAN frame is then transferred to destination memory starting from RHBUFk_R0 until the end of the
CAN data bytes defined by RHBUFk_R1.DLC and aligned to 32-bit words
4.
The following occurs after a successful transfer:
a.
If DMEMi_WM.WML = DMEMi_STATUS.BC (except when WML=0), the Watermark flag is set
(DMEMi_STATUS.WMF = 1) and an interrupt is triggered
b.
If DMEMi_WA = DMEMi_STATUS.BC, the Wraparound flag is set (DMEMi_STATUS.WAF = 1) and an
interrupt is triggered. After the wraparound event, the next CAN frame is stored again at the start
address DMEMi_SA.ADR, making the destination a circular list
c.
The buffer counter (DMEMi_STATUS.BC) is increased by 1. When a Wraparound event occurs, the
buffer counter is reset to 0. The BC value is still zero within the DMEMi after the first message is
transferred. The register DMEMi_STATUS indicates the correct count value
d.
The message counter (DMEMi_STATUS.MC) is increased by 1. After overflow of the counter, the
counter is reset to 0
5.
DMEMi_STATUS.SID is updated with the source ID of the CAN frame and the New Message bit
(DMEMi_STATUS.NM) is set to 1
6.
If only DMEMi_CONFIG.AST = 1 is set, DMEMi_STATUS is copied as the first word of the current virtual CAN
buffer after the frame is copied
Consider the following when transferring CAN frames to the system memory:
•
The message counter (DMEMi_STATUS.MC) resets to 0 either after a counter overflow or after a software
write with a non-zero value
•
If the CAN frame (including Status and Timing headers, if enabled) does not fit the destination buffer size
defined by DMEMi_CONFIG.OA, the Destination Buffer Overflow Error flag (ME_ERR.DBOE) is set and the
source CAN request is cleared. The ongoing transaction has to be canceled by the DRE by writing into the
CRE_ABORT_SEQ at the CAD_CANi_CRESA.ADR + 18H address.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3772
v1.1
2025-06-26


•
If a CAN I-PDU is received instead of a CAN frame where DMEMi_CONFIG.CTYP is set to 0B, the CAN I-PDU
is discarded, the Invalid Routing Destination Error flag (ME_ERR.IRDE) is set and the source CAN request
is cleared. The ongoing transaction has to be canceled by the DRE by writing into the CRE_ABORT_SEQ
at the CAD_CANi_CRESA.ADR + 18H address. The abort sequence is triggered by the DRE only after it
starts reading the CAN frame and before the last read or write operation is launched. The DRE cancels the
ongoing read sequence by writing 1B to CRE_ABORT_SEQ.CRHBUF0 or CRHBUF1 if it has already started
reading the CAN frame (R0, R1, DBm) after the error has occurred.
•
The DRE locks the buffer by setting DMEMi_CONFIG.EN1 or EN2 to 0B after a Wraparound or Watermark
event. It is up to the software to unlock the buffer again by setting the DMEMi_CONFIG.EN1 or EN2 to 1B
CAN I-PDUs to system memory with multiplexing enabled
If DMEMi_MODE.TYP is set to 1B (MUXEN), the CAN I-PDUs in the data buffers are assembled with no padding
between them. The SRI transactions are broken down based on the payload length which is part of the PDU
header in order to avoid padding, as shown in the alignment of CAN message 1 - 3 in the figure below.
DMEMi_STATUS + FDBI
(DMEMi_WM+1)*DMEMi_CONFIG.OA + 8 bytes
Padding bytes for 64-bit 
alignment
CAN message 2
When DRE_DMEMi_MODE.TYP is set to 1 in Single mode
with Count-based trigger
CAN message 1
CAN message 3
CAN message 
DMEMi_WM
Frame Data Buffer 1
DMEMi_STATUS + FDBI
FDBI
CAN messages
Padding bytes for 64-bit 
alignment
CAN message 
DMEMi_WA
FDBI
Frame Data Buffer 2
(DMEMi_WA-DMEMi_WM 
+ 1)*DMEMi_CONFIG.OA + 
8 bytes
DMEMi_STATUS + FDBI
DMEMi_WM – DMEMi_SA
Padding bytes for 64-bit 
alignment
CAN message 2
When DRE_DMEMi_MODE.TYP is set to 1 in Single mode
with Index-based trigger
CAN message 1
CAN message 3
CAN message i
Frame Data Buffer 1
DMEMi_STATUS + FDBI
FDBI
CAN messages
Padding bytes for 64-bit 
alignment
CAN message j
FDBI
Frame Data Buffer 2
DMEMi_WA – 
DMEMi_WM
DMEMi_SA
DMEMi_SA
Figure 357
Trigger modes comparison
The DMEMi_FDBI denotes where the next CAN I-PDU is to be stored in the Frame Data Buffer.
When the first CAN I-PDU is received, it is copied at the index DMEMi_SA as long as the WML is large enough to
accommodate a whole CAN I-PDU including the status and header information. The FDBI is then updated as
follows:
FDBI bytes
= 4 bytes DMEMi_STATUS optional + 4 bytes DMEMi_FDBI + 8 bytes THEAD optional
+ Sℎort or Long PDU ℎeader 4 or 8 bytes + Data bytes
The second CAN I-PDU is then copied starting from the index FDBI as shown in the figure below.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3773
v1.1
2025-06-26


Frame Data Buffer 1 Status (optional)
CAN I-PDU 1 Timing header (optional)
CAN I-PDU 1 short or long PDU header
CAN I-PDU 1 Payload (DB3-DB0)
CAN I-PDU 1 Payload (DB7-DB4)
...
Example 1: Index-based Single Mode
CAN I-PDU 1 : Payload length = 18 bytes
CAN I-PDU 2 : Payload length = 10 bytes
CAN I-PDU 3 : Payload length = 18 bytes
CAN I-PDU 4 : Payload length = 10 bytes
DMEMi_WM = 64 bytes (8 words)
DMEMi_WA = 128 bytes (16 words)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 Short or Long PDU header
CAN I-PDU 2 short or long PDU header
CAN I-PDU 2 Payload (DB1-DB0)
CAN I-PDU 2 Payload (DB5-DB2)
CAN I-PDU 2 Payload (DB9-DB6)
...
FDBI = 38 bytes
DRE_DMEMi_SA
64-bit aligned
CAN I-PDU 1 Payload (DB17-DB16)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 short or long PDU header
HW checks EN1 = 1
0
31
FDBI
CAN I-PDU 1 Payload (DB17-DB16)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 Short or Long PDU Header
WM = FDBI
Watermark interrupt
Frame Data Buffer 2 status (optional)
CAN I-PDU 3 Timing header (optional)
CAN I-PDU 3 short or long PDU header
CAN I-PDU 3 Payload (DB3-DB0)
CAN I-PDU 3 Payload (DB7-DB4)
CAN I-PDU 3 Payload (DB17-DB16)
...
CAN I-PDU 4 Timing header (optional)
CAN I-PDU 4 Timing header (optional)
CAN I-PDU 4 Timing header (optional)
CAN I-PDU 4 short or long PDU header
CAN I-PDU 4 short or long PDU header
CAN I-PDU 4 short or long PDU header
CAN I-PDU 4 Payload (DB1-DB0)
CAN I-PDU 4 Payload (DB5-DB2)
...
CAN I-PDU 4 Payload (DB9-DB6)
WA = FDBI
Wraparound interrupt
FDBI = 102 bytes
HW checks 
EN2 = 1
64-bit aligned
+ DMEMi_WM
FDBI
Figure 358
Example 1: Index-based trigger in Single mode
The following occurs if the new CAN I-PDU (including Timing header, if enabled) does not fit to the destination
buffer size or if the buffer becomes unavailable:
•
If DMEMi_MODE.FOM is set to 0B, the CAN I-PDU is stored in the next available Frame Data Buffer 1, or
Frame Data Buffer 2 when the corresponding EN bit is set to 1B. When the EN bit is set to 0B, this means
that the Frame Data Buffer is disabled or that the software has not read the data yet. The CAN I-PDU is
discarded, the Destination Buffer Overflow Error flag (ME_ERR.DBOE) is set and the source CAN request is
cleared
•
If DMEMi_MODE.FOM is set to 1B, the CAN I-PDU is discarded, the Destination Buffer Overflow Error flag
(ME_ERR.DBOE) is set and the source CAN request is cleared
The ongoing transaction has to be canceled by the DRE in the case of error by writing into CRE_ABORT_SEQ
at the CAD_CANi_CRESA.ADR + 18H address. The abort sequence is triggered by the DRE only after it starts
reading the CAN frame and before the last read or write operation is launched. The DRE cancels the
ongoing read sequence by writing 1B to CRE_ABORT_SEQ.CRHBUF0 or CRHBUF1 if it has already started
reading the CAN frame (R0, R1, DBm) after the error has occurred
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3774
v1.1
2025-06-26


For each CAN request, the DRE reads the Routing header RHBUFk_UCRH from the Rx Host Buffer to determine
the destination DMEMi and performs the following tasks:
1.
Checks if the bit DMEMi_CONFIG.EN1 is 1B
2.
If DMEMi_CONFIG.ATH = 1 is set, then the Timing header (THEAD of two 32-bit words in size) of the CAN
I-PDU is copied after DMEMi_FDBI
3.
The CAN I-PDU is transferred to the destination memory starting from the PDU header (always two 32-bit
words in size) until end of CAN data bytes defined by DLC in the PDU header
4.
DMEMi_FDBI is updated with the index where the next CAN I-PDU is to be stored. DMEMi_STATUS.BC is
incremented by 1. The BC value is still zero within the DMEMi after the first message is transferred. The
register DMEMi_STATUS indicates the correct count value
5.
The next CAN I-PDU is fetched. The following occurs depending on the configured layout mode:
a.
Single mode: Steps 4 to 6 are repeated until the Watermark level is reached. The DRE proceeds
with Step 9 for the Frame Data Buffer 1. The DRE repeats Steps 1 to 6 (if DMEMi_CONFIG.EN2 is
1B) until the Wraparound level is reached for the Frame Data Buffer 2. See the previous figure
Example 1: Index-based trigger in Single mode
b.
Continuous mode: Steps 5 to 7 are repeated until the Wraparound level is reached, as shown in
the figure below:
Frame Data Buffer 1 Status (optional)
CAN I-PDU 1 Timing header (optional)
CAN I-PDU 1 short or long PDU header
CAN I-PDU 1 Payload (DB3-DB0)
CAN I-PDU 1 Payload (DB7-DB4)
CAN I-PDU 1 Payload (DB17-DB16)
...
Example 2: Index-based Continuous mode
CAN I-PDU 1 : Payload length = 18 bytes
CAN I-PDU 2 : Payload length = 10 bytes
DMEMi_WA = 64 bytes (8 words)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 Timing header (optional)
CAN I-PDU 2 short or long PDU header
CAN I-PDU 2 short or long PDU header
CAN I-PDU 2 short or long PDU header
CAN I-PDU 2 Payload (DB1-DB0)
CAN I-PDU 2 Payload (DB5-DB2)
CAN I-PDU 2 Payload (DB9-DB6)
...
FDBI = 38 bytes
WA = FDBI
Wraparound interrupt
DRE_DMEMi_SA
64-bit aligned
HW checks EN1 = 1
FDBI
31
0
Figure 359
Example 2: Index-based trigger in Continuous mode
6.
The DRE then locks the buffer by setting DMEMi_CONFIG.EN1 or EN2 to 0B. DMEMi_STATUS.WMF or
DMEMi_STATUS.WAF is set and interrupt is triggered. The message counter (DMEMi_STATUS .MC) is
increased by 1 to indicate a message transfer to the DMEM. Upon overflow of the counter, the counter is
reset to 0
7.
If DMEMi_CONFIG.AST = 1, then DMEMi_STATUS is copied as the first word of the destination memory
just before the Watermark or Wraparound interrupt is triggered
8.
DMEMi_FDBI is copied as the 2nd word (or first word) just before the Watermark or Wraparound interrupt
is triggered
9.
The software initiates the frame processing in the DMEMi until the configured Watermark or Wraparound
level is reached. FDBI indicates the exact length of the frame in the buffer. It is up to the software to
unlock the buffer again by setting the DMEMi_CONFIG.EN1 or EN2 to 1B
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3775
v1.1
2025-06-26


Note:
The start addresses of Frame Data Buffer 1 and Frame Data Buffer 2 are always 64-bit aligned.
If the configured DMEMi_WM is not 64-bit aligned, there are padding bits added to the end of
Frame Data Buffer 1. Even in Count-based trigger mode, when FDBI is not 64-bit aligned at the
watermark, there are padding bits added to the end of Frame Data Buffer 1. Nevertheless, the
exact length of the frame is indicated by the FDBI
Handling buffer overflow and unavailability for CAN I-PDUs
In Continuous mode (DMEMi_MODE.BUF = 1B), the CAN I-PDU is discarded when DMEMi_CONFIG.EN1 is not set,
the CAN request is cleared and the DBOE interrupt is triggered. In Single mode (DMEMi_MODE.BUF = 0B), the
DRE handles CAN I-PDUs depending on the buffer availability DMEMi_CONFIG.EN1 and DMEMi_CONFIG.EN2,
and the set buffer overflow mode (DMEMi_MODE).
The following table shows how the DRE handles CAN requests in Single mode when the EN bits are not set or
when a buffer overflow scenario occurs where the size of the incoming CAN I-PDU exceeds the configured
Watermark (DMEMi_WM) or Wraparound (DMEMi_WA) level.
Table 945
Buffer overflow or buffer unavailability (Single mode)
Scenario
Condition
EN1
EN2
FOM
Result
Buffer
available
PDU for Frame Data Buffer
1
1
-
-
Copy PDU to Frame Data Buffer 1
PDU for Frame Data Buffer
2
-
1
-
Copy PDU to Frame Data Buffer 2
Buffer
unavailable
PDU for Frame Data Buffer
1 or 2
0
0
1
PDU is discarded, CAN request
cleared and DBOE interrupt
triggered
PDU for Frame Data Buffer
1
0 (buffer
full)
1
0
Copy PDU to Frame Data Buffer 2
PDU for Frame Data Buffer
2
1
0 (buffer
full)
0
Copy PDU to Frame Data Buffer 1
Buffer
overflow
Size of PDU for Frame
Data Buffer 1 exceeds
DMEMi_WM
1
1
0
Copy PDU to Frame Data Buffer 2
and trigger Watermark interrupt
1
0
0
PDU is discarded, CAN request
cleared and DBOE interrupt
triggered
1
-
1
Size of PDU for Frame Data
Buffer 2 exceeds DMEMi_WA
1
1
0
Copy PDU to Frame Data
Buffer 1 and trigger Wraparound
interrupt
0
1
0
PDU is discarded, CAN request
cleared and DBOE interrupt
triggered
-
1
1
Note:
The DMEMi_STATUS that is copied to the DMEMi (if DMEMi_CONFIG.AST = 1) is only updated in the
buffer that receives a message. In case the FOM bit is set in order to copy the message to the spare
Frame data buffer, the DMEMi_STATUS is not updated for the buffer which is full but is updated for the
Frame data buffer to which the CAN message is copied to. In case of buffer overflow, the software shall
read the error information from the DMEMi_STATUS register and not from the DMEMi
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3776
v1.1
2025-06-26


Summary of allowed scenarios during CAN message transfer to system memory
Scenarios that lead to a message being stored in the configured DMEM. The following table shows a summary of
allowed scenarios for CAN frame or CAN I-PDU transfer to the system memory.
Table 946
Summary of allowed CAN node to memory cases
Configured mode
in DMEMi_MODE
(TYP_TRIG_BUF)1)
Operating mode
Condition2)
EN
1
EN
2
Result
-
-
CTYP matches
-
-
Message stored, WMF and
WAF flags set accordingly,
FDBI updated, EN1 cleared
if WML reached
MUXEN_COUNT_SINGLE
MUXEN_COUNT_SINGLE
Message
destined for
FDB1
1
x
Message stored, WMF and
WAF flags set accordingly,
FDBI updated, EN1 cleared
if WML reached
Message
destined for
FDB2
x
1
Same handling as FDB1
MUXEN_COUNT_CONT
MUXEN_COUNT_SINGLE
with WM>=WA
MUXEN_COUNT_CONT
Message
destined for
DMEM
1
x
Message stored, WMF and
WAF flags set accordingly,
FDBI updated, EN1 cleared
if WAL reached3)
MUXEN_INDEX_SINGLE
MUXEN_INDEX_SINGLE
Message
destined for
FDB1
1
x
Message accepted in FDB1,
WMF flag set if WML
reached, FDBI set to end
of messaged(+1) delivered
in FDB1, EN1 cleared if at
WML
Message
destined for
FDB2
x
1
Same handling as FDB1
MUXEN_INDEX_CONT
MUXEN_INDEX_SINGLE
with WM>=WA
MUXEN_INDEX_CONT
Message
destined for
DMEM
1
x
Message stored and flags
set accordingly, FDBI
updated
MUXDIS_*
MUXDIS_COUNT_CONT
Message
destined for
DMEM
1
x
Message stored4) , WMF and
WAF flags set accordingly,
EN1 cleared if wrap around
reached, EN2 untouched
1)
Configuration should be static
2)
The requirement is that the WML/WAL set to at least one maximum frame size plus some bytes
3)
WMF always set according to the programmed levels, independent of the mode, but no WM interrupt triggered
4)
General rule is that a message coming to a buffer whose EN is 0 is dropped, BO is triggered, and status is unchanged
Note:
Other scenarios not included in this table are illegal or cause the message to be dropped and trigger
the corresponding interrupt or error.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3777
v1.1
2025-06-26


20.6.3.2.4
Move engine
The Move Engine performs the FPI and SRI transactions as required by the routing transfer operation. The Move
Engine also has direct read and write access to the DRE internal RAM. The read/write operation is directed to
the corresponding interface based on the address map.
The current status of the routing transfer operation and the bus access is shown in ME_STATE SFR. The read and
write address of a ME transaction is shown in ME_SRCA and ME_DESTA. In case of an FPI or SRI transaction
error, the corresponding error flags are set in ME_ERR. After an error, the first error status is shown in
ME_ERR.FESID, FEDID, ME_FESRCA and ME_FEDESTA. In case of an error, the current routing transfer is aborted
and the Move Engine continues to perform the next routing transfer request from the Routing Control Unit. The
DRE writes into the CRE_ABORT_SEQ at the CAD_CANi_CRESA.ADR + 18H address to indicate the CRE about the
abort of the routing transfer.
Resource partition configuration
CAN nodes and system memory destinations can be assigned to one of the Resource Partitions (RP) using the
registers CANi_RP, DMEMi_RP and DMAi_RP. These registers point to the RP configuration MODEr that defines
the DRE Move Engine access condition to the on-chip buses when performing a routing transfer. The Move
Engine inherits the RP configuration of CAN nodes during read/write access to CAN nodes. Similarly, it inherits
the RP configuration of system memory destinations, during write access to the same.
While accessing the Ethernet DMA channels, the DRE inherits the RP configuration pointed to by the DMAi_RP
register. DMA0_RP and DMA1_RP indicates the index of RP configuration of GETH0 and GETH1 respectively.
DMA2_RP to DMA5_RP indicates the index of RP configuration of LETH0 to LETH3 respectively.
The RP has a master tag identifier driven onto the on-chip bus during the Move Engine access to the
corresponding resource. The master tag identifier for a RP is derived from the DRE base master tag ID and
corresponding MODEr.TAG_OFF bit-field.
Each RP may further be assigned to a virtual machine number and protection set (PRS). The virtual machine
number and the PRS programmed in the RP MODEr SFR will be driven on the bus during read or write access to
the corresponding resource.
MODEr.MODE determines if the DRE performs the corresponding bus accesses in supervisor mode or user
mode.
20.7
Ethernet descriptor handler
The ETH Descriptor Handler prepares the normal Transmit and Receive ETH descriptors within the Message
RAM to exchange ETH frames and descriptors that contain control or status information between the DRE and
ETH MAC.
20.7.1
Feature list
•
Offloads CPU by preparing the Rx and Tx descriptors
•
A maximum of 24 Rx descriptors can be configured (4 per Ethernet Rx DMA channel) to receive an Ethernet
frame in the EIBUF. One Rx descriptor is used to receive one Ethernet frame in EIBUF
•
A total of 24 Tx descriptors can be configured (4 per Ethernet Tx DMA channel) and used to transmit or
forward an Ethernet frame:
-
Transmit an IEEE 1722 ACF Ethernet frame from EOBUF or
-
Forward an Ethernet frame received in EIBUF
•
Consists of a Forwarding Engine to forward Ethernet frames between Ethernet interfaces
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3778
v1.1
2025-06-26


20.7.2
Functional overview
The block diagram of the Ethernet Descriptor Handler is shown in the following figure. It contains three blocks:
•
Tx Descriptor Handler
•
Rx Descriptor Handler
•
Forwarding Engine
(Message RAM)
(4 Tx descriptor per Tx DMA CH)
ACF CAN-Ethernet 
Format Engine
CAN to ETH frame
ETH Descriptor Handler
ACF CAN-Ethernet 
Format Engine
Prepare Read 
format
Output Ethernet ACF 
frames to Tx DMA
Overwrite with 
Write-back format
Read CAN to ETH 
frame
Free Input buffer 
element
(Message RAM)
(4 Rx descriptor per Rx DMA CH)
Prepare Read 
format
Write ETH frame
(Message RAM)
Check forwarding 
rule
ETH to CAN frame
ETH to ETH 
Forward frame
Update Tx DMA 
Tail ptr
Read ETH to ETH 
Forward frame
Overwrite with 
Write-back format
Update Rx DMA 
Tail ptr
Forwarding table
1
2
Max. 128
(Message RAM)
(Message RAM)
CAN to Ethernet (IEEE 1722) data-path
Ethernet to Ethernet data-path
(IEEE 1722) Ethernet to CAN data-path
New Ethernet 
frame
Tx Descriptor 
Handler
Forwarding Engine
Rx Descriptor 
Handler
ETH Tx 
DMA 
channel(s)
ETH Rx 
DMA 
channel(s)
ETH Output Buffer 
List
1
2
6
Transmit 
Descriptor List
1
2
24
Receive Descriptor 
List
1
2
24
ETH Input Buffer 
List
1
2
6
Figure 360
Ethernet descriptor handler block diagram
Tx Descriptor Handler
The Tx Descriptor Handler prepares the Tx descriptor(s) in Read format within the Message RAM for each
Ethernet frame that is to be routed or forwarded to an Ethernet interface through an Ethernet Tx DMA channel.
•
CAN to Ethernet frame: IEEE 1722 ACF Ethernet frame in EOBUF
•
Ethernet to Ethernet frame: Ethernet forward frame in EIBUF
It also updates the DMA Tail Pointer registers of LETH (DMA_CHy_TxDesc_Tail_Pointer (y=0-7)) and GETH
(DMA_CHj_TxDesc_Tail_LPointer (j=0-7)) Tx DMA channels. For the LETH Tx address register, see RAM LETH Tx
DMA channel address. For the GETH Tx address register, see RAM GETH Tx DMA channel address . The DMA
channel overwrites the descriptor with the Write-back format after reading the Ethernet frame from the buffer.
The Tx Descriptor Handler also checks the status within the Write-back format of the Tx descriptor and triggers
an interrupt in the event of any errors.
Rx Descriptor Handler
The Rx Descriptor Handler prepares the Rx descriptor(s) in Read format within the Message RAM whenever
there is a free EIBUF element to receive an Ethernet frame from an Ethernet Rx DMA channel.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3779
v1.1
2025-06-26


It also updates the DMA Tail Pointer registers of the LETH (DMA_CHy_RxDesc_Tail_Pointer (y=0-7)) and GETH
(DMA_CHj_RxDesc_Tail_LPointer (j=0-7)) Rx DMA channels. For the LETH Rx address register, see RAM LETH Rx
DMA channel address. For the GETH Rx address register, see RAM GETH Rx DMA channel address. The DMA
channel overwrites the descriptor with the Write-back format after writing the Ethernet frame to the buffer. The
Rx Descriptor Handler also checks the status within the Write-back format of the Rx descriptor and triggers an
interrupt in the event of any errors.
The Rx Descriptor Handler also separates the Ethernet to CAN traffic and the Ethernet to Ethernet forward
traffic.
Forwarding Engine
The Forwarding Engine generates the FTCFG.FID from the Write-back format of the Rx descriptor. It performs
the Forward ID filtering to determine the forwarding destination of the Ethernet frame.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3780
v1.1
2025-06-26


20.7.3
Functional description
In this section, the transmit, receive and forward functions of the Ethernet frames are described in detail.
20.7.3.1
Tx descriptor handler
The Tx Descriptor Handler transmits ACF Ethernet frames from the EOBUF and also forwards an Ethernet frame
from the EIBUF to an Ethernet Tx DMA channel.
Whenever there is an Ethernet frame to be transmitted or forwarded, the corresponding EREQ.TXi_REQ or
EREQ.FWDi_REQ request bit is set.
When TETHDLi_CTRL.TRIG is set to 1, it sets EOBUFj_STATUS.TXREQ and triggers an Ethernet output frame
transmit request interrupt to the IR indicating that the software can read the Ethernet frame from the buffer.
When TETHDLi_CTRL.TRIG is set to 0, the following happens:
1.
The Tx Descriptor Handler prepares the 4 words of all Tx descriptors in Read format:
a.
For the ACF Ethernet frame in the EOBUF
b.
For the Ethernet frame in the EIBUF in the case of Ethernet frame forwarding
2.
The Tx Descriptor Handler sets the following bits:
a.
TDESCi_RD3.FD bit is set to indicate to the DMA that this is the first Tx descriptor of the Ethernet
frame
b.
TDESCi_RD3.LD bit is set to indicate to the DMA that this is the last Tx descriptor of the Ethernet
frame
The Tx Descriptor Handler prepares the remaining unused Tx descriptors as well with buffer pointers to
EOBUF. If a forwarding request arrives, then the Tx descriptors are used for the frame in EIBUF by
changing the buffer pointers. The OWN bit is not set for these descriptors as unused Tx descriptors are
still owned by the DRE.
3.
After preparing the Tx descriptor, the Tx Descriptor Handler sets the TDESCi_RD3.OWN bit in the
descriptor, indicating that the DMA channel TETHDLi_CTRL.DMACH owns the descriptor. The OWN bit of
the second Tx descriptor is set for the second frame, the OWN bit of the third descriptor is set for the
third frame, and so on. After the fourth frame, the first descriptor is used again
4.
The Tx Descriptor Handler then reads the address of the DMA Tail Pointer from the Ethernet address
database and updates the Tail Pointer DMA_CHj_TxDesc_Tail_LPointer or
DMA_CHy_TxDesc_Tail_Pointer of the Ethernet DMA channel TETHDLi_CTRL.DMACH, indicating the total
number of Tx descriptors. The Tx Descriptor Tail LPointer register has the 32-bit end address of the
Transmit descriptor list. This is the Transmit Poll Demand from the DRE.
a.
DMA_CHj_TxDesc_Tail_LPointer = Start address ofTETHDLi + 10H for GETH if the first
descriptor has OWN bit set
b.
DMA_CHy_TxDesc_Tail_Pointer = Start address ofTETHDLi + 10H for LETH if the first
descriptor has OWN bit set
The Tail Pointer is updated until the descriptor which has the OWN bit set
5.
While in Run state, the Ethernet DMA selects the next Tx DMA channel from which the packets requiring
transmission should be processed. The Ethernet DMA channel fetches each Tx descriptor (DRE_TDESC)
and performs the following actions:
a.
Reads the buffer address and payload length from the Tx descriptor and fetches the ACF Ethernet
frame from the EOBUF. In case of forwarding it fetches the Ethernet frame from the EIBUF
b.
Clears OWN bit and overwrites the Tx descriptors with the Write-back format. The
TDESCi_WR3G.LD bit or TDESCi_WR3L.LD must be set by DMA once the last descriptor is
processed instructing the Tx Descriptor Handler to release the DRE_TDESC to be used by another
frame
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3781
v1.1
2025-06-26


c.
It then fetches the next descriptor and if the OWN bit is not set, it goes into Suspend state
d.
The DMA comes out of Suspend state and goes into Run state with the next Transmit Poll Demand
from the DRE
Note:
The DRE issues only one Transmit poll demand at a time. Any new request for the same
Tx DMA channel would be considered only after the write-back format is written by the
DMA channel for the previous request
6.
If there is no error in the Write-back format, the Tx Descriptor Handler clears the following bits,
indicating buffer free:
•
EREQ.TXi_REQ, after the entire frame is read from the EOBUF
•
EREQ.FWDi_REQ, after the entire frame is read from the EIBUF
7.
When there is a new frame to be transmitted or forwarded, the Tx Descriptor Handler then issues
another Transmit Poll Demand after setting the OWN bit of the next Tx descriptor pointed to by the
TETHDLi_CTRL.PTR. The PTR is always pointing to the next descriptor following the last word write-back
format write operation from the Tx DMA channel. This Transmit Poll Demand brings the DMA out of
Suspend state. If the DMA does not read the descriptor pointed to by TETHDLi_CTRL.PTR, error flag
EOBUFj_ERROR.TDESE is set and Transmit descriptor error interrupt INT_14 is triggered
8.
After the successful routing and forwarding of each Ethernet frame, EDLSTAT.TXCNT is incremented
9.
The transmit of an Ethernet frame is complete upon the detection of the write of the last word of the
descriptor Write-back format TDESCi_WR3 (RAM TDESC word 3 Write-back format for GETH or RAM
TDESC word 3 Write-back format for LETH). The Tx DMA updates the Write-back descriptor error status
TDESCi_WR3G.DERR in most error scenarios. In the case of LETH, TDESCi_WR3L.DE and ES bits indicate
error. But when an AXI bus error occurs (refer GETH or LETH chapters) while writing the Write-back
format, the transaction is aborted immediately by the Tx DMA channel and the last word TDESCi_WR3
might not be updated. When Ethernet Transmit Timeout Monitoring is enabled and the last word is not
written before the timer expires, a timeout interrupt is triggered. When Ethernet Transmit Timeout
Monitoring is disabled, the Tx Descriptor Handler polls the GETH DMA_CHj_Status (j=0-7) and LETH
DMA_CHy_Status (y=0-7) registers every 200 clock cycles in order to monitor the status of the DMA
channel. The polling starts at the first word read of the descriptor Read format and is done in a round-
robin fashion for each DMA channel. If the DMA detects one of the following conditions, the transmission
from that channel is suspended or stopped and the Tx DMA proceeds to go into Suspend state or Stop
state.
Tip:
As Suspend state is considered an abnormal event by Ethernet, it triggers AIS interrupt. It is
recommended that this interrupt is disabled when the DMA channel is configured to route or
forward frames using DRE
Bit TBU (bit 2) of the Status register of the corresponding DMA channel is set in the event that
transmission is suspended:
a.
The descriptor is flagged as owned by the DRE (OWN bit is cleared): In this case the DRE Tx
Descriptor Handler gives the ownership to the DMA by setting the OWN bit and then issues a Poll
Demand command by writing to the Tail Pointer register
b.
The descriptor Tail Pointer is equal to the current descriptor pointer in Ring Descriptor list mode:
In this case the DRE Tx Descriptor Handler modifies the Tail Pointer such that the following
condition is true:
Current Descriptor Pointer < Descriptor Tail Pointer
c.
An error condition occurs because of transmit underflow: The packet transmission is aborted and
TDESCi_WR3.DERR (in the case of GETH) or TDESCi_WR3.DE (in the case of LETH) is set
accordingly by the DMA channel. DRE Tx Descriptor Handler triggers a Transmit descriptor error
interrupt INT_14
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3782
v1.1
2025-06-26


d.
In the event of a bus error, the DMA proceeds to Stop state, bit FBE is set and the bit-field TPS of
the Status register is set accordingly. In this case, the packet transmission is aborted, TDESE is set
and Transmit descriptor error interrupt INT_14 is triggered
e.
The software can reset the TETHDLi_CTRL.PTR if required by setting the TETHDLi_CTRL.STOP bit.
The software must wait for the DRE to set the TETHDLi_CTRL.STOPACK before resetting the PTR.
The software must then clear the STOP bit. Clearing of this STOP bit will trigger DRE to clear
STOPACK and set OWN bit of the TDESCi pointed to by the new updated TETHDLi_CTRL.PTR and
trigger a Transmit Poll Demand to the Tx DMA channel
Note:
The software can ensure that the Ethernet DMA current pointer in this case is also
pointing to the same descriptor by resetting the Ethernet DMA current pointer or by
restarting the DMA
Requests arbitration
All the requests to forward or transmit Ethernet frames are processed in a round-robin fashion. A requests
arbitration example is shown in the image below. The priority is as follows:
1.
Write-back format processing
2.
If the previous processed request was TXi_REQ, then FWDi_REQ is processed
3.
If the previous processed request was FWDi_REQ, then TXi_REQ is processed
This ensures a non-starving arbitration of TXi_REQ and FWDi_REQ
time
t1
0
0
0
0
0
0
1
0
0
0
0
0
TX0_REQ
TX1_REQ
TX2_REQ
TX3_REQ
TX4_REQ
TX5_REQ
FWD0_REQ
FWD1_REQ
FWD2_REQ
FWD3_REQ
FWD4_REQ
FWD5_REQ
0
0
1
0
0
0
1
0
1
0
0
0
TX0_REQ
TX1_REQ
TX2_REQ
TX3_REQ
TX4_REQ
TX5_REQ
FWD0_REQ
FWD1_REQ
FWD2_REQ
FWD3_REQ
FWD4_REQ
FWD5_REQ
t2
t3
0
0
1
0
0
0
0
0
1
0
0
0
TX0_REQ
TX1_REQ
TX2_REQ
TX3_REQ
TX4_REQ
TX5_REQ
FWD0_REQ
FWD1_REQ
FWD2_REQ
FWD3_REQ
FWD4_REQ
FWD5_REQ
t4
Pending 
requests
Last serviced 
request
Granted 
request
...
...
0
0
0
0
0
0
0
0
1
0
0
0
TX0_REQ
TX1_REQ
TX2_REQ
TX3_REQ
TX4_REQ
TX5_REQ
FWD0_REQ
FWD1_REQ
FWD2_REQ
FWD3_REQ
FWD4_REQ
FWD5_REQ
0
1
1
1
1
1
0
0
0
1
0
1
TX0_REQ
TX1_REQ
TX2_REQ
TX3_REQ
TX4_REQ
TX5_REQ
FWD0_REQ
FWD1_REQ
FWD2_REQ
FWD3_REQ
FWD4_REQ
FWD5_REQ
Multi-cast forward requests
0
1
1
1
1
1
0
0
0
1
0
1
TX0_REQ
TX1_REQ
TX2_REQ
TX3_REQ
TX4_REQ
TX5_REQ
FWD0_REQ
FWD1_REQ
FWD2_REQ
FWD3_REQ
FWD4_REQ
FWD5_REQ
tn
tn-1
Figure 361
Requests arbitration example
Ethernet transmit timeout monitoring
The DRE monitors for delayed Ethernet frame availability to transmit within the EOBUF and also monitors for
delayed read of Ethernet frames from EOBUF by the Ethernet DMA channel. The Ethernet watchdog counter
starts incrementing when the Ethernet watchdog timeout is enabled in EWDCFG.EN. The watchdog timer
triggers periodic events E1, E2, …, En after a user-configured Ethernet timeout period EWDCFG.ETO. The
Ethernet timeout period is configured by the user based on the use-case. If the start condition is true and the
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3783
v1.1
2025-06-26


end condition is not true within two events Ei and Ei + 1 , the Ethernet watchdog timeout error flag
EOBUFj_ERROR.WDTE is set and error interrupt INT_14 is triggered if EWDCFG.WTOE is enabled. The software
can read the frame in the event of such a timeout and must clear the error flag. Once the error flag is cleared,
the EOBUF is used for the next frame.
The timeout period between the events Ei is calculated as follows:
•
Default timeout period: Tdef = 16
fSRI
•
User-configured timeout period: Tout = Tdef * EWDCFG.ETO + 1
Table 947
Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within a single event Ei
No Timeout error. No timeout interrupt triggered
End condition is true within two consecutive events Ei
and Ei + 1
If the presence of start condition is detected at Ei,
then the end condition is expected to happen before
Ei+1. If not, timeout interrupt is triggered
End condition is true after two consecutive events Ei
and Ei + 1
Timeout interrupt is triggered
Table 948
EOBUF : Start and end condition list
Start condition
End condition
EOBUF full (ready for transmit). EREQ.TXi_REQ is set to
indicate this
EOBUF empty (read complete by Ethernet DMA
channel or software). EREQ.TXi_REQ is cleared
EOBUF not empty (partially full)
EOBUF full (ready for transmit). EREQ.TXi_REQ is set
Related information
Ethernet output buffer on page 3730
Ethernet input buffer on page 3733
Ethernet descriptor lists on page 3733
Descriptor structure configuration on page 3733
Descriptor error handling on page 3789
Tx descriptors on page 3734
Forwarding engine on page 3787
Ethernet address database (EAD) on page 3740
20.7.3.2
Rx descriptor handler
The Rx Descriptor Handler receives an Ethernet frame in the EIBUF from an ETH Rx DMA channel.
Whenever there is a free EIBUF available to receive an ETH frame, the EIBUFi_STATUS.BPR is 0 indicating buffer
empty.
When RETHDLi_CTRL.TRIG is set to 1, the Descriptor Handler sets EIBUFi_STATUS.RXREQ and triggers an
Ethernet Frame Receive Request Interrupt INT_11 to the IR indicating that the software can write an Ethernet
frame to the free buffer. The software writes the Ethernet frame to the EIBUF and clears the RXREQ. The handler
sets the Buffer Pending Request (BPR) bit after the Ethernet frame is received in the EIBUF. When
RETHDLi_CTRL.TRIG is set to 0, the following actions are performed:
1.
The Rx Descriptor Handler prepares the 4 words of all Rx descriptors in Read format for the ETH frame to
be stored in EIBUF but only sets the OWN bit of the first Rx descriptor. The OWN bit of the second Rx
descriptor is set for the second frame, the OWN bit of the third descriptor is set for the third frame, and
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3784
v1.1
2025-06-26


so on. After the fourth frame, the first descriptor is used again. RDESC_RD0.BUF1AP points to the EIBUF
start address
2.
After preparing the Rx descriptors, the Rx Descriptor Handler sets the RDESCi_RD3.OWN bit (GETH) or
RDESCi_RD3.OWN bit (LETH) in the first descriptor, indicating that the DMA channel
RETHDLi_CTRL.DMACH owns the descriptor
3.
The Rx Descriptor Handler reads the address of the DMA Tail Pointer from the Ethernet address database
and updates the Tail Pointer DMA_CHj_RxDesc_Tail_LPointer (GETH) or DMA_CHy_RxDesc_Tail_Pointer
(LETH) of the Ethernet DMA channel RETHDLi_CTRL.DMACH indicating the total number of Rx
descriptors. The Rx Descriptor Tail LPointer register has the 32-bit end address of the Receive descriptor
list. This is the Receive Poll Demand from the DRE:
a.
DMA_CHj_RxDesc_Tail_LPointer = Start address ofRETHDLi + 10H for GETH if the first
descriptor has OWN bit set
b.
DMA_CHy_RxDesc_Tail_Pointer = Start address ofRETHDLi + 10H for LETH if the first
descriptor has OWN bit set
The Tail Pointer is updated up to the descriptor which has the OWN bit set
4.
While in Run state, the Ethernet DMA channel fetches each Rx descriptor (DRE_RDESC) and performs the
following actions:
a.
Reads the buffer address from the Rx descriptor and writes the Ethernet frame to this address in
the EIBUF
b.
Clears OWN bit and overwrites the Rx descriptor with the Write-back format which includes the
packet length RDESCi_WR3G.PL (GETH) or RDESCi_WR3L.PL (LETH). The RDESCi_WR3G.LD bit
(GETH) or RDESCi_WR3L.LD (LETH) must be set by the DMA once the last descriptor is processed,
indicating to the DRE to release the DRE_RDESCi to be used by another frame. If the LD bit is not
set, the error flag EIBUFi_ERROR.RDESE is set and error interrupt INT_10 is triggered
c.
The Ethernet DMA starts to process the next Rx descriptor but goes into Suspend state as the
second descriptor is still owned by the DRE
d.
The DMA comes out of Suspend state and goes into Run state with the next Receive Poll Demand
from the DRE
5.
If there is no error in the Write-back format, after the last word write to the Write-back format Rx
descriptor DRE_RDESCi_WR3 (RDESCi_WR3G for GETH or RDESCi_WR3L for LETH), the OWN bit is
checked if cleared and BPR bit is set to 1 by the Rx Descriptor Handler indicating buffer full
6.
The DRE then begins processing the new frame in EIBUF. After the frame in EIBUF is successfully
processed and once the buffer is empty, the Rx Descriptor Handler sets the OWN bit of the next Rx
descriptor pointed to by the RETHDLi_CTRL.PTR and issues a Receive Poll Demand . The PTR is always
pointing to the next descriptor following the last word Write-back format write operation from the Rx
DMA channel. This Receive Poll Demand brings the DMA out of Suspend state to start processing the next
descriptor. If the DMA does not read the descriptor pointed to by RETHDLi_CTRL.PTR, error flag
EIBUFi_ERROR.RDESE is set and Receive descriptor error interrupt INT_10 is triggered
7.
After successful forwarding of each Ethernet frame, EDLSTAT.RXCNT is incremented
8.
The reception of an Ethernet frame is complete upon the detection of the write of the last word of the
descriptor Write-back format RDESCi_WR3 (RAM RDESC word 3 Write-back format GETH or RAM RDESC
word 3 Write-back format LETH). The Rx DMA updates the Write-back descriptor error summary
RDESCi_WR3G.ES bit or RDESCi_WR3L.ES bit in most error scenarios. But when an AXI bus error (refer
LETH or GETH chapters) occurs while writing the Write-back format, the transaction is aborted
immediately by the Rx DMA channel and the last word RDESCi_WR3 might not be updated. When
Ethernet Receive Timeout Monitoring is enabled and the last word is not written before the timer
expires, a timeout interrupt will be triggered. When Ethernet Receive Timeout Monitoring is disabled, the
Rx Descriptor Handler polls the GETH DMA_CHj_Status (j=0-7) and LETH DMA_CHy_Status (y=0-7)
registers every 200 clock cycles in order to monitor the status of the DMA channel. The polling starts at
the first word read of descriptor Read format and is done in a round-robin fashion for each DMA channel.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3785
v1.1
2025-06-26


If the DMA detects one of the following conditions, the transmission from that channel is suspended or
stopped and the Rx DMA proceeds to go into Suspend state or Stop state
a.
The Ethernet DMA enters Suspend state when there are no free descriptors (based on Rx current
descriptor and descriptor Tail Pointer register values). Bit RBU (bit 7) of the Status register of the
corresponding DMA channel is set in the event that transmission is suspended. It exits the
suspend state on a Receive Poll Demand from the DRE after it advances the Tail Pointer of the
channel.
Tip:
As Suspend state is considered an abnormal event by Ethernet, it triggers AIS interrupt.
It is recommended that this interrupt is disabled when the DMA channel is configured to
route or forward frames using DRE
b.
If there is an error indication by RDESCi_WR3G.ES or RDESCi_WR3L.ES bit, the Rx Descriptor
Handler stores the frame in the EIBUF, sets the error flag EIBUFi_ERROR.RDESE and triggers a
Receive descriptor error interrupt INT_10
c.
In the event of a bus error, the DMA proceeds to Stop state, bit FBE is set and the bit-field RPS of
the Status register is set accordingly. In this case, the transaction is aborted, RDESE is set and
Receive descriptor error interrupt INT_10 is triggered
d.
The software can reset the RETHDLi_CTRL.PTR if required by setting the RETHDLi_CTRL.STOP bit.
The software must wait for the DRE to set the RETHDLi_CTRL.STOPACK before resetting the PTR.
The software must then clear the STOP bit. Clearing of this STOP bit will trigger DRE to clear
STOPACK and set OWN bit of the RDESCi pointed to by the new updated RETHDLi_CTRL.PTR and
trigger a Receive Poll Demand to the Rx DMA channel
Note:
The software can ensure that the Ethernet DMA current pointer in this case is also
pointing to the same descriptor by resetting the Ethernet DMA current pointer or by
restarting the DMA
Ethernet receive timeout monitoring
The DRE monitors for a delayed write of an Ethernet frame by the Ethernet DMA channel or software to the
EIBUF and also monitors for delayed processing of the Ethernet frame by the ACF Format Engine or by the Tx
Descriptor Handler in the case of Ethernet forwarding. The Ethernet watchdog counter starts incrementing
when the Ethernet watchdog timeout is enabled in EWDCFG.EN is set. The watchdog timer triggers periodic
events E1, E2, …, En after a user-configured Ethernet timeout period EWDCFG.ETO. The Ethernet timeout
period is configured by the user based on the use-case. If the start condition is true and the end condition is not
true within two events Ei and Ei + 1 , the Ethernet watchdog timeout error flag EIBUFi_ERROR.WDTE is set and
error interrupt INT_10 is triggered if EWDCFG.WTOE is enabled. The software can read the frame in the event of
such a timeout and must clear the error flag. Once the error flag is cleared, the EIBUF is used for the next frame.
The timeout period between the events Ei is calculated as follows:
•
Default timeout period: Tdef = 16
fSRI
•
User-configured timeout period: Tout = Tdef * EWDCFG.ETO + 1
Table 949
Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true within a single event Ei
No timeout error. No timeout interrupt triggered
End condition is true within two consecutive events Ei
and Ei + 1
If the presence of start condition is detected at Ei,
then the end condition is expected to happen before
Ei+1. If not, timeout interrupt is triggered
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3786
v1.1
2025-06-26


Table 949
(continued) Timeout interrupt trigger
Timeout check
Timeout interrupt trigger
End condition is true after two consecutive events Ei
and Ei + 1
Timeout interrupt is triggered
Table 950
EIBUF : Start and end condition list
Start condition
End condition
EIBUF empty (EIBUFi_STATUS.BPR is 0)
EIBUF full (EIBUFi_STATUS.BPR is 1). In the event of an
error scenario such as overflow, the EIBUFi_STATUS
bit BPR, Buffer Pending Request, is not set by the DRE,
which triggers a timeout. In this case, two error
interrupts (Buffer full and timeout) are triggered. If the
end condition and the timeout occur at the same
time, INT_10 is triggered even if the Ethernet frame is
processed successfully
EIBUF full
EIBUF empty (processed by the Ethernet to CAN
Disassembler or by the Tx Descriptor Handler in the
case of forwarding)
Related information
Ethernet input buffer on page 3733
Ethernet descriptor lists on page 3733
Descriptor structure configuration on page 3733
Descriptor error handling on page 3789
Rx descriptors on page 3736
Forwarding engine on page 3787
Ethernet address database (EAD) on page 3740
20.7.3.3
Forwarding engine
The Forwarding Engine assists in forwarding Ethernet frames between Ethernet interfaces.
The Rx Descriptor Handler decides the path of the Ethernet frame in the EIBUF. The Rx Descriptor Handler can
give control of the Ethernet frame to the ACF CAN-Ethernet Format Engine (to the Ethernet ACF to CAN
Disassembler) in the case of ETH to CAN routing or to the Forwarding Engine in the case of Ethernet forwarding.
It gives control to the ACF CAN-Ethernet Format Engine under the following scenarios:
1.
In the case of an IEEE 1722 Ethernet frame containing AV tagged data,
a.
For GETH, RDESCi_WR2G bit AVTDP or AVTCP is set
Note:
The DRE does not support split header feature. The DRE identifies the frame to be AV
tagged when AVTDP or AVTCP is set irrespective of L34T value. If the frame is not AV
tagged but AVTDP or AVTCP is still set, the subtype check or failed StreamID filtering
described below would give control to the Forwarding Engine
b.
For LETH, RDESCi_WR1L bits 2:0 (Payload Type) are 110B or 111B
2.
If the frame is identified to be an IEEE 1722 Ethernet frame (refer to the section Validation of the Ethernet
input frame):
a.
Subtype = 0x82
b.
StreamID filtering passed
In all other scenarios, the Rx Descriptor Handler gives control of the Ethernet frame to the Forwarding Engine.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3787
v1.1
2025-06-26


The Forwarding Engine assists in forwarding Ethernet frames between Ethernet interfaces. The Ethernet MAC
consists of a built-in Ethernet packet filtering which consists of L2, L3, L4 filters and a Flexible Receive Parser
(FRP). Acceptance and rejection of packets is based on the configuration of these filters:
•
For LETH, the L3L4FM (3 bits) is not included in filtering
•
For GETH, the L3L4FM (3 bits) is not included in filtering when both L34M and L4M are zero
The DRE_RDESCi Write-back format consists of the packet filtering and FRP status information. This is used by
the Forwarding Engine to create a FTCFG.FID as shown in the following figure.
Source 
EIF
FRPLI
L3L4FM
MADRM
4 bits
8 bits
3 bits
8 bits
23 bits FID
RETHDLi_CTRL.EIF
From RDESCi_WR
Source 
DMACH
RETHDLi_CTRL.EIFID
Rx descriptor Write-back format
Figure 362
Forwarding ID
The Forwarding Engine determines the destination of the Ethernet frame using this FID within the Forwarding
table. The Forwarding table consists of a set of user-configurable forward filter IDs FT_FEj_FRULE.FID1,
FT_FEj_FID2.FID2 and a bit-encoded forward rule FT_FEj_FRULE.DSEL consisting of 6 bits. The forward rule is
used to select the Tx descriptor list of the corresponding destination DMA channel. The Forwarding Engine
performs the following operations:
1.
Forward ID filtering: Each filter element is executed until the first matching element is found. Forward
ID filtering stops at the first matching element. The remaining filter elements are not evaluated for this
frame. The following types of filtering mode can be configured by setting FT_FEj_FRULE.FMODE
accordingly:
a.
Classic ID filter: FID1 used as the filter ID and FID2 used as mask
b.
Dual ID filter: FID1 or FID2 used as filter ID and FTCFG.FID should be an exact match
c.
Range ID filter: Range of IDs between FID1 and FID2 are used as filter IDs. The FTCFG.FID should be
between FID1 and FID2
2.
Frame forwarding: When there is a matching filter element, the Forwarding Engine sets the
EREQ.FWDi_REQ of the corresponding Tx descriptor list FT_FEj_FRULE.DSEL. It gives control of the
Ethernet frame in the EIBUF to the Tx Descriptor Handler. The Tx Ethernet Descriptor Handler then
prepares the Tx descriptors for the frame in EIBUF depending on the configured forward rule
FT_FEj_FRULE.DSEL
Related information
Tx descriptor handler on page 3781
Rx descriptor handler on page 3784
Ethernet input buffer on page 3733
Ethernet address database (EAD) on page 3740
Forwarding table on page 3739
Validation of the Ethernet input frame on page 3754
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3788
v1.1
2025-06-26


20.7.3.4
Descriptor error handling
The Ethernet DMA channel signals an error through the status information within the Write-back format of the
descriptors.
During any SRI bus error while sending the Transmit or Receive Poll demand, the EOBUFj_ERROR.TDESE or
EIBUFi_ERROR.RDESE is set for transmit and receive respectively. ME_ERR.SRIBE is set and FEDID and FESID
bits are set accordingly.
Error in Tx descriptors
•
In the case of GETH, error in Tx descriptors is indicated by bit TDESCi_WR3G.DERR
•
In the case of LETH, error in Tx descriptors is indicated by bit TDESCi_WR3L.DE and bit TDESCi_WR3L.ES
indicates the type of error
In the event of a Tx descriptor error, the Tx Descriptor Handler retains the Tx descriptors and the frame in
EOBUF or EIBUF. It sets the error flag EOBUFj_ERROR.TDESE and EIBUFi_STATUS.FE (in the case of FWDi_REQ
from EIBUF) and triggers an interrupt. The software then fixes the root cause of the error, it fetches the Ethernet
frame from the buffer, clears the request TXi_REQ or FWDi_REQ and then clears the TDESE or RDESE.
Meanwhile, the Tx Descriptor Handler processes the remaining requests in round-robin fashion, as described in
the chapter Tx Descriptor Handler. During any Tx descriptor error caused by a FWDi_REQ, the TXi_REQ is
blocked until the TDESE belonging to the EOBUFi is cleared by the software as the Tx descriptors are mapped to
the same Tx DMA channel.
Error in Rx descriptors
•
In the case of GETH, error in Rx descriptors or in the received packet is indicated by bit RDESCi_WR3G.ES
•
In the case of LETH, error in Rx descriptors or in the received packet is indicated by RDESCi_WR3L.ES
In the event of an Rx descriptor error, the Rx Descriptor Handler retains the Rx descriptor Write-back format and
the frame in the EIBUF. It sets the error flag EIBUFi_ERROR.RDESE, EIBUFi_STATUS.FE and triggers an interrupt.
The software then fetches the Ethernet frame from the buffer and clears the error flag. Once the error flag is
cleared, the EIBUF is used for the next frame.
Meanwhile, the Rx Descriptor Handler processes the next free EIBUF as described in the chapter Rx Descriptor
Handler.
Related information
Tx descriptor handler on page 3781
Rx descriptor handler on page 3784
20.7.3.5
Interrupt grouping
DRE generates status and error events on 16 interrupt lines (INT_0 until INT_15) to the Interrupt Router.
The corresponding interrupt lines are enabled by configuring the IE register. A trigger event on an interrupt line
is shown in the INTSIG register even if the interrupt is disabled. INT_i (i= 0 to 15) output will be a pulse when a
trigger event for interrupt i happens even if INTSIG[i] is already set at that point in time. The 16 interrupt lines
are mapped to the following status and error events:
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3789
v1.1
2025-06-26


Table 951
Interrupt grouping table
Interrupt line
Interrupt type
Status and error events mapped
INT_0 to INT_7
Watermark and Wraparound
Interrupts
Groups watermark and
wraparound events of destination
memory routing operations.
DMEMi_STATUS.WAF and WMF
status events are mapped to one of
INT[0:7] as selected by
DMEMi_CONFIG.INP
INT_8
CAN Input Buffer List Interrupts
Groups the following CIBL error
interrupts:
•
CIBL_STATUS.BF
•
CIBL_STATUS.CRCE
•
CIBL_STATUS.WDTE
INT_9
CAN Output Buffer List Interrupts
Groups the following COBL error
interrupts:
•
COBL_STATUS.BF
•
COBL_STATUS.WDTE
INT_10
EIBUF Frame Error Interrupts
Groups the following EIBUF error
interrupts:
•
EIBUFi_STATUS.FE
•
EIBUFi_STATUS.IFT
•
EIBUFi_STATUS.LME
•
EIBUFi_STATUS.RFE
•
EIBUFi_STATUS.IDID
•
EIBUFi_STATUS.CFE
•
EIBUFi_ERROR.WDTE
•
EIBUFi_ERROR.RDESE
•
EIBUFi_ERROR.BF
INT_11
Ethernet Frame Receive Request
Interrupt
EIBUFi_STATUS.RXREQ
INT_12
Routing Table Error Interrupts
Groups RS.IRT and NMFE
INT_13
ME Routing Transaction Lost
Interrupts
Groups the following ME error
interrupts:
•
ME_ERR.DBOE
•
ME_ERR.SRIBE
•
ME_ERR.SPBBE
•
ME_ERR.IRDE
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3790
v1.1
2025-06-26


Table 951
(continued) Interrupt grouping table
Interrupt line
Interrupt type
Status and error events mapped
INT_14
EOBUF Frame Error Interrupts
Groups the following EOBUF error
interrupts:
•
EOBUFj_STATUS.BF
•
EOBUFj_ERROR.WDTE
•
EOBUFj_ERROR.TDESE
INT_15
Ethernet Frame Transmit Request
Interrupt
EOBUFj_STATUS.TXREQ
When multiple events are mapped to the same interrupt lines, the corresponding interrupt line is triggered
when at least one of the relevant status or error events has occurred (logical OR operation on status or error
event).
Related information
Ethernet input buffer on page 3733
20.8
Registers
20.8.1
Register overview - access mode glossary
Table 952
Register overview - access mode glossary
Keyword
Description
E
Access protection using PROT register PROTE.
SE
Access protection using PROT register PROTSE.
APU-PETHj
(j=0-5)
Protection group consisting of registers ETHj_ACCEN_WRA, ETHj_ACCEN_WRB,
ETHj_ACCEN_RDA, ETHj_ACCEN_RDB, ETHj_ACCEN_VM, ETHj_ACCEN_PRS.
PETHj
Access protection using APU-PETHj registers.
APU-PG
Protection group consisting of registers ACCEN_WRA, ACCEN_WRB, ACCEN_RDA, ACCEN_RDB,
ACCEN_VM, ACCEN_PRS.
PG
Access protection using APU-PG registers.
32
Access only when using 32-bit width.
SV
Access only when supervisor mode is active on the interconnect.
BE
Always returns a Bus Error.
U
No access restrictions.
PROT
Access restrictions as defined in the PROT register access rules.
P
Description can be found in global access mode definition.
nBE
Indicates that no Bus Error is generated when accessing this address range, even though it is
either an access to an undefined address or the access does not follow the given rules.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3791
v1.1
2025-06-26


20.8.2
Register overview - DRE (ascending offset address)
Table 953
Register overview - DRE (ascending offset address)
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
PG, 32
PG, SV, E,
32
Application
Reset
3798
OCS
OCDS Control and Status
Register
00004H
PG, 32
SV, PG, 32
Debug Reset
3799
ID
Module Identification
Register
00008H
PG, 32
BE
PowerOn Reset
3800
RST_CTRLA
Reset Control Register A
0000CH
PG, 32
PG, SV, E,
32
Application
Reset
3801
RST_CTRLB
Reset Control Register B
00010H
PG, 32
PG, SV, E,
32
Application
Reset
3801
RST_STAT
Reset Status Register
00014H
PG, 32
BE
Application
Reset
3802
PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3803
PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3804
ACCEN_WRA
Write access enable register
A
00020H
32
SE, SV, 32
Application
Reset
3806
ACCEN_WRB
Write access enable register
B
00024H
32
SE, SV, 32
Application
Reset
3807
ACCEN_RDA
Read access enable register
A
00028H
32
SE, SV, 32
Application
Reset
3807
ACCEN_RDB
Read access enable register
B
0002CH
32
SE, SV, 32
Application
Reset
3808
ACCEN_VM
VM access enable register
00030H
32
SE, SV, 32
Application
Reset
3808
ACCEN_PRS
PRS access enable register
00034H
32
SE, SV, 32
Application
Reset
3809
ETHj_ACCEN_WR
A
Write access enable register
A j
00040H+j
*20H
32
SE, SV, 32
Application
Reset
3810
ETHj_ACCEN_WR
B
Write access enable register
B j
00044H+j
*20H
32
SE, SV, 32
Application
Reset
3810
ETHj_ACCEN_RD
A
Read access enable register
A j
00048H+j
*20H
32
SE, SV, 32
Application
Reset
3811
ETHj_ACCEN_RD
B
Read access enable register
B j
0004CH+
j*20H
32
SE, SV, 32
Application
Reset
3811
ETHj_ACCEN_VM
VM access enable register j
00050H+j
*20H
32
SE, SV, 32
Application
Reset
3812
ETHj_ACCEN_PR
S
PRS access enable register j 00054H+j
*20H
32
SE, SV, 32
Application
Reset
3812
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3792
v1.1
2025-06-26


Table 953
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
MODEr
RP r mode register
01040H+
r*4
PG, 32
E, SV, PG,
32
Application
Reset
3813
CANi_RP
CAN i resource partition
01060H+i
*4
PG, 32
E, SV, PG,
32
Kernel Reset
3814
CIBL_BPR
CAN input buffer pending
request
010B8H
PG, 32
PG, 32
Kernel Reset
3814
CIBL_STATUS
CAN input buffer list status
010BCH
PG, 32
PG, 32
Kernel Reset
3815
COBL_BPR0
CAN output buffer pending
request 0
010C8H
PG, 32
PG, 32
Kernel Reset
3816
COBL_BPR1
CAN output buffer pending
request 1
010CCH
PG, 32
PG, 32
Kernel Reset
3817
COBL_STATUS
CAN output buffer list
status
010D0H
PG, 32
PG, 32
Kernel Reset
3818
EIBUFi_CONFIG
Ethernet input buffer i
configuration
010D8H+
i*14H
PG, 32
E, SV, PG,
32
Kernel Reset
3818
EIBUFi_ERROR
Ethernet input buffer i error 010E0H+i
*14H
PG, 32
PG, 32
Kernel Reset
3819
EIBUFi_STATUS
Ethernet input buffer i
status
010E4H+i
*14H
PG, 32
PG, 32
Kernel Reset
3821
EOBUFj_CONFIG
Ethernet output buffer j
configuration
01150H+j
*38H
PG, 32
E, SV, PG,
32
Kernel Reset
3823
EOBUFj_MAC_H0 Ethernet output buffer j
MAC header 0
01154H+j
*38H
PG, 32
PG, 32
Kernel Reset
3825
EOBUFj_MAC_H1 Ethernet output buffer j
MAC header 1
01158H+j
*38H
PG, 32
PG, 32
Kernel Reset
3826
EOBUFj_MAC_H2 Ethernet output buffer j
MAC header 2
0115CH+
j*38H
PG, 32
PG, 32
Kernel Reset
3826
EOBUFj_MAC_H3 Ethernet output buffer j
MAC header 3
01160H+j
*38H
PG, 32
PG, 32
Kernel Reset
3827
EOBUFj_MAC_H4 Ethernet output buffer j
MAC header 4
01164H+j
*38H
PG, 32
PG, 32
Kernel Reset
3827
EOBUFj_NTSCF_
H0
Ethernet output buffer j
NTSCF header
01168H+j
*38H
PG, 32
PG, 32
Kernel Reset
3828
EOBUFj_NTSCF_
STREAM0_ID
Ethernet output buffer j
Stream ID configuration 0
0116CH+
j*38H
PG, 32
PG, 32
Kernel Reset
3829
EOBUFj_NTSCF_
STREAM1_ID
Ethernet output buffer j
Stream ID configuration 1
01170H+j
*38H
PG, 32
PG, 32
Kernel Reset
3830
EOBUFj_STATUS
Ethernet output buffer j
status
01174H+j
*38H
PG, 32
PG, 32
Kernel Reset
3830
EOBUFj_TTC
Ethernet output buffer
j Transmit trigger
configuration
01178H+j
*38H
PG, 32
PG, 32
Kernel Reset
3832
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3793
v1.1
2025-06-26


Table 953
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
EOBUFj_TTS
Ethernet output buffer j
Timer threshold and status
0117CH+
j*38H
PG, 32
PG, 32
Kernel Reset
3832
EOBUFj_ERROR
Ethernet output buffer j
error
01180H+j
*38H
PG, 32
PG, 32
Kernel Reset
3833
SIDFi_FC
Stream ID filter i
configuration
0129CH+
i*14H
PG, 32
PG, 32
Kernel Reset
3834
SIDFi_FIL1_L
Stream ID filter i
configuration Stream ID
filter 1 lower
012A0H+
i*14H
PG, 32
PG, 32
Kernel Reset
3835
SIDFi_FIL1_H
Stream ID filter i
configuration Stream ID
filter 1 higher
012A4H+
i*14H
PG, 32
PG, 32
Kernel Reset
3835
SIDFi_FIL2_L
Stream ID filter i
configuration Stream ID
filter 2 lower
012A8H+
i*14H
PG, 32
PG, 32
Kernel Reset
3836
SIDFi_FIL2_H
Stream ID filter i
configuration Stream ID
filter 2 higher
012ACH+
i*14H
PG, 32
PG, 32
Kernel Reset
3836
RTi_CONFIG
CAN transmit routing table i
configuration
01340H+i
*8
PG, 32
E, SV, PG,
32
Kernel Reset
3837
RREQ_CONFIG
Routing request
configuration
0135CH
PG, 32
BE
Kernel Reset
3837
RREQ_CID
CAN ID request
01360H
PG, 32
BE
Kernel Reset
3838
UCRH
Uni-cast routing header
01364H
PG, 32
BE
Kernel Reset
3838
MCRH
Multi-cast routing header
01364H
PG, 32
BE
Kernel Reset
3839
RS
Routing status
01368H
PG, 32
PG, 32
Kernel Reset
3840
CANRXR0
CAN receive request 0
0136CH
PG, 32
BE
Kernel Reset
3840
CANRXR1
CAN receive request 1
01370H
PG, 32
BE
Kernel Reset
3841
CANTXR
CAN transmit buffer
available request
01374H
PG, 32
BE
Kernel Reset
3842
DMEMi_CONFIG
Destination memory i
configuration
0137CH+
i*20H
PG, 32
E, SV, PG,
32
Kernel Reset
3842
DMEMi_MODE
Destination memory
i transfer mode
configuration
01380H+i
*20H
PG, 32
E, SV, PG,
32
Kernel Reset
3844
DMEMi_STATUS
Destination memory i
status
01390H+i
*20H
PG, 32
PG, 32
Kernel Reset
3845
DMEMi_RP
Destination memory i
resource partition
01394H+i
*20H
PG, 32
E, SV, PG,
32
Kernel Reset
3846
ME_SRCA
Move engine source
address
016F8H
PG, 32
BE
Kernel Reset
3847
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3794
v1.1
2025-06-26


Table 953
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
ME_DESTA
Move engine destination
address
016FCH
PG, 32
BE
Kernel Reset
3847
ME_STATE
Move engine state
01700H
PG, 32
BE
Kernel Reset
3847
ME_FESRCA
Move engine first error
source address
01704H
PG, 32
BE
Kernel Reset
3848
ME_FEDESTA
Move engine first error
destination address
01708H
PG, 32
BE
Kernel Reset
3849
ME_ERR
Move engine error register
0170CH
PG, 32
PG, 32
Kernel Reset
3849
INTSIG
Interrupt signal
01710H
PG, 32
BE
Kernel Reset
3851
IE
Interrupt line enable
01714H
PG, 32
PG, 32
Kernel Reset
3853
RETHDLi_CTRL
Rx Ethernet descriptor list i
configuration and control
0171CH+
i*8
PG, 32
E, SV, PG,
32
Kernel Reset
3854
TETHDLi_CTRL
Tx Ethernet descriptor list i
configuration and control
0174CH+
i*10H
PG, 32
E, SV, PG,
32
Kernel Reset
3856
EDLSTAT
Ethernet descriptor list
status
017D8H
PG, 32
PG, 32
Kernel Reset
3858
EREQ
Ethernet requests summary 017DCH
PG, 32
PG, 32
Kernel Reset
3859
FTCFG
Forwarding table
configuration
017E4H
PG, 32
E, SV, PG,
32
Kernel Reset
3860
CWDCFG
DRE CAN watchdog
configuration
017ECH
PG, 32
E, SV, PG,
32
Kernel Reset
3861
EWDCFG
DRE Ethernet watchdog
configuration
017F4H
PG, 32
E, SV, PG,
32
Kernel Reset
3862
EADCFG
Ethernet address database
configuration
017F8H
PG, 32
E, SV, PG,
32
Kernel Reset
3862
DMAi_RP
DMA i resource partition
017FCH+
i*4
PG, 32
E, SV, PG,
32
Kernel Reset
3863
CITO
CAN Input buffer timeout
status
01818H
PG, 32
PG, 32
Kernel Reset
3863
COTO0
CAN Output buffer timeout
status 0
0181CH
PG, 32
PG, 32
Kernel Reset
3864
COTO1
CAN Output buffer timeout
status 1
01820H
PG, 32
PG, 32
Kernel Reset
3864
20.8.3
Register overview - DRE CAN Address Database RAM interface
(ascending offset address)
Table 954
Register overview - DRE CAN Address Database RAM interface (ascending offset
address)
Short name
Long name
Offset
address
See
CAD_CANi_CRESA
RAM CAN address database CRE start address
00000H+i*8
3865
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3795
v1.1
2025-06-26


20.8.4
Register overview - DRE CAN Input Buffer List RAM interface
(ascending offset address)
Table 955
Register overview - DRE CAN Input Buffer List RAM interface (ascending offset address)
Short name
Long name
Offset
address
See
CIBUFj_RHEAD
RAM CIBUF routing header
000A0H+j*50H
3865
CIBUFj_CRC
RAM CIBUF CRC computed by CRE
000A4H+j*50H
3866
CIBUFj_R0
RAM CIBUF register 0
000A8H+j*50H
3866
CIBUFj_R1
RAM CIBUF register 1
000ACH+j*50H
3867
CIBUFj_DBm
RAM CIBUF data byte m
000B0H+j*50H
+m
3868
20.8.5
Register overview - DRE CAN Output Buffer List RAM interface
(ascending offset address)
Table 956
Register overview - DRE CAN Output Buffer List RAM interface (ascending offset
address)
Short name
Long name
Offset
address
See
COBUFj_UCRH
RAM uni-cast routing header
006E0H+j*50H
3868
COBUFj_MCRH
RAM multi-cast routing header
006E0H+j*50H
3869
COBUFj_CRC
RAM COBUF CRC computed by DRE
006E4H+j*50H
3870
COBUFj_R0
RAM COBUF register 0
006E8H+j*50H
3871
COBUFj_R1
RAM COBUF register 1
006ECH+j*50H
3872
COBUFj_DB
RAM COBUF data byte m
006F0H+j*50H
+m
3873
20.8.6
Register overview - DRE Ethernet descriptors RAM interface
(ascending offset address)
Table 957
Register overview - DRE Ethernet descriptors RAM interface (ascending offset address)
Short name
Long name
Offset
address
See
TDESCi_RD0
RAM TDESC word 0 read format
03140H+i*10H
3877
TDESCi_WR0
RAM TDESC word 0 Write-back format
03140H+i*10H
3878
TDESCi_RD1
RAM TDESC word 1 read format
03144H+i*10H
3878
TDESCi_WR1
RAM TDESC word 1 Write-back format
03144H+i*10H
3879
TDESCi_RD2
RAM TDESC word 2 read format
03148H+i*10H
3879
TDESCi_WR2
RAM TDESC word 2 Write-back format
03148H+i*10H
3880
TDESCi_RD3
RAM TDESC word 3 read format
0314CH+i*10H
3880
TDESCi_WR3G
RAM TDESC word 3 Write-back format for GETH
0314CH+i*10H
3882
TDESCi_WR3L
RAM TDESC word 3 Write-back format for LETH
0314CH+i*10H
3883
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3796
v1.1
2025-06-26


Table 957
(continued) Register overview - DRE Ethernet descriptors RAM interface (ascending
offset address)
Short name
Long name
Offset
address
See
RDESCi_RD0
RAM RDESC word 0 read format
03180H+i*10H
3886
RDESCi_WR0NT
RAM RDESC word 0 Write-back format Non Tunneled frames
(also LETH)
03180H+i*10H
3886
RDESCi_WR0T
RAM RDESC word 0 Write-back format Tunneled frames
03180H+i*10H
3887
RDESCi_RD1
RAM RDESC word 1 read format
03184H+i*10H
3887
RDESCi_WR1G
RAM RDESC word 1 Write-back format GETH
03184H+i*10H
3888
RDESCi_WR1L
RAM RDESC word 1 Write-back format LETH
03184H+i*10H
3888
RDESCi_RD2
RAM RDESC word 2 read format
03188H+i*10H
3891
RDESCi_WR2G
RAM RDESC word 2 Write-back format GETH
03188H+i*10H
3891
RDESCi_WR2L
RAM RDESC word 2 Write-back format LETH
03188H+i*10H
3894
RDESCi_RD3G
RAM RDESC word 3 read format GETH
0318CH+i*10H
3896
RDESCi_RD3L
RAM RDESC word 3 read format LETH
0318CH+i*10H
3897
RDESCi_WR3G
RAM RDESC word 3 Write-back format GETH
0318CH+i*10H
3898
RDESCi_WR3L
RAM RDESC word 3 Write-back format LETH
0318CH+i*10H
3900
20.8.7
Register overview - DRE DMEM parameter table RAM interface
(ascending offset address)
Table 958
Register overview - DRE DMEM parameter table RAM interface (ascending offset
address)
Short name
Long name
Offset
address
See
DMEMi_SA
RAM Destination memory start address
07A40H+i*10H
3904
DMEMi_FDBI
RAM Destination memory frame data buffer index
07A44H+i*10H
3905
DMEMi_WM
RAM Destination memory watermark level
07A48H+i*10H
3905
DMEMi_WA
RAM Destination memory wraparound level
07A4CH+i*10H
3906
20.8.8
Register overview - DRE Ethernet Address Database RAM interface
(ascending offset address)
Table 959
Register overview - DRE Ethernet Address Database RAM interface (ascending offset
address)
Short name
Long name
Offset
address
See
EAD_LETHj_TXDMA
RAM LETH Tx DMA channel address
02AE0H+j*8
3876
EAD_LETHj_RXDMA
RAM LETH Rx DMA channel address
02AE4H+j*8
3876
EAD_GETHj_TXDMA
RAM GETH Tx DMA channel address
02B00H+j*8
3876
EAD_GETHj_RXDMA
RAM GETH Rx DMA channel address
02B04H+j*8
3877
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3797
v1.1
2025-06-26


20.8.9
Register overview - DRE Forwarding table RAM interface (ascending
offset address)
Table 960
Register overview - DRE Forwarding table RAM interface (ascending offset address)
Short name
Long name
Offset
address
See
FT_FEj_FRULE
RAM Forwarding rule and FID1
07640H+j*8
3902
FT_FEj_FID2
RAM Forward filter ID2
07644H+j*8
3904
20.8.10
Register overview - DRE CAN Transmit Routing Table RAM interface
(ascending offset address)
Table 961
Register overview - DRE CAN Transmit Routing Table RAM interface (ascending offset
address)
Short name
Long name
Offset
address
See
RT_REj_CIDFC
RAM routing table CAN ID filter configuration
01AE0H+j*8
3873
RT_REj_UCR
RAM routing table uni-cast routing
01AE4H+j*8
3874
RT_REj_MCR
RAM routing table multi-cast routing
01AE4H+j*8
3875
20.8.11
Clock Control Register
The Clock Control Register CLC allows the programmer to adapt the functionality and power consumption of
the module to the requirements of the application.
Register CLC controls the module clock signal and the reactivity to the sleep signal.
CLC
Offset address:
00000H
Clock Control Register
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
Used for enable/disable control of the module.
0B On request: enable the module clock
1B Off request: stop the module clock
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3798
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DISS
1
rh
Module Disable Status Bit
When CLC.DISS=1B, registers CLC, OCS, ID, RST_CTRLA, RST_CTRLB,
PROTE, PROTSE, ACCEN* and ETH_ACCEN* are still accessible. Accesses
to other DRE registers are not executed and will result in a bus error.
0B Module clock is enabled
1B Off: module is not clocked
EDIS
3
rw
Sleep Mode Enable Control
Used to control the module’s reaction to sleep mode.
Note: Sleep mode should not be enabled when there are ongoing or
pending transactions between the DRE and Ethernet
0B Sleep mode request is enabled and functional
1B Module disregards the sleep mode control signal
0
2,
31:4
r
Reserved
Read as 0; should be written with 0.
20.8.12
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
r
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3799
v1.1
2025-06-26


Field
Bits
Type
Description
SUS
27:24
rw
OCDS Suspend Control
Controls the sensitivity to the suspend signal coming from the OCDS
Trigger Switch (OTGS)
Not listed combinations are reserved.
0H Will not suspend
1H Reserved, Do not use
2H Soft suspend mode
Clocks will be disabled after kernel acknowledge. The DRE waits
for the onging transactions on the SRI and FPI Master interfaces to
finish. SRI access remains operational. Read accesses are allowed
on the SRI slave interface for the entire SFR space and the RAM
memory. Write access are allowed on the SRI slave interface for the
RAM memory and the registers on the application domain
(common registers). Write access to Kernel domain registers will
have no effect. The DRE resumes operation from the point where it
was stopped upon a suspend request. Note: Suspend mode
should not be enabled when there are ongoing or pending
transactions. Rapid sequence of suspend requests should be
avoided in order to avoid false acknowledge.
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
23:0,
31:30
r
Reserved
Read as 0; should be written with 0.
Table 962
Access mode restrictions of OCS sorted by descending priority
Mode name
Access mode
Description
write 1 to .SUS_P
rw
SUS
Set SUS_P during write access
(default)
r
SUS
 
20.8.13
Module Identification Register
ID
Offset address:
00008H
Module Identification Register
PowerOn Reset value:
0102 C002H
31
30
29
28
27
26
25
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
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3800
v1.1
2025-06-26


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
The bit-field is set to C0H which defines the module as a 32-bit module.
MOD_NUM
31:16
r
Module Number Value
This bit-field defines a module identification number.
20.8.14
Reset Control Register A
RST_CTRLA
Offset address:
0000CH
Reset Control Register A
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
0B Global module reset group x does not have any effect
1B Global module reset group x results in a kernel reset
0
7:1,
31:12
r
Reserved
Read as 0; should be written with 0.
20.8.15
Reset Control Register B
RST_CTRLB
Offset address:
00010H
Reset Control Register B
Application Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3801
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
20.8.16
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
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3802
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
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
20.8.17
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
31
30
29
28
27
26
25
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
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3803
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
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
Table 963
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
20.8.18
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
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3804
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
20  Data Routing Engine (DRE)
Reference manual
3805
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
Table 964
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
20.8.19
Write access enable register A
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
ACCEN_WRA
Offset address:
00020H
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
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3806
v1.1
2025-06-26


20.8.20
Write access enable register B
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
ACCEN_WRB
Offset address:
00024H
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
EN63 EN62 EN61 EN60 EN59 EN58 EN57 EN56 EN55 EN54 EN53 EN52 EN51 EN50 EN49 EN48
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
EN47 EN46 EN45 EN44 EN43 EN42 EN41 EN40 EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
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
ENq (q=32-63)
q-32
rw
Write access enable for TAG-ID q
This bit enables write access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for write access
1B Enabled for write access
20.8.21
Read access enable register A
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
ACCEN_RDA
Offset address:
00028H
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
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3807
v1.1
2025-06-26


20.8.22
Read access enable register B
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
ACCEN_RDB
Offset address:
0002CH
Read access enable register B
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
EN63 EN62 EN61 EN60 EN59 EN58 EN57 EN56 EN55 EN54 EN53 EN52 EN51 EN50 EN49 EN48
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
EN47 EN46 EN45 EN44 EN43 EN42 EN41 EN40 EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
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
ENq (q=32-63)
q-32
rw
Read access enable for TAG-ID q
This bit enables read access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for read access
1B Enabled for read access
20.8.23
VM access enable register
ACCEN register set
This register defines which virtual machine encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each VMx.
ACCEN_VM
Offset address:
00030H
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
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3808
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
20.8.24
PRS access enable register
ACCEN register set
This register defines which protection register set encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each PRSx.
ACCEN_PRS
Offset address:
00034H
PRS access enable register
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
20  Data Routing Engine (DRE)
Reference manual
3809
v1.1
2025-06-26


20.8.25
Write access enable register A j
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
ETHj_ACCEN_WRA (j=0-5)
Offset address:
00040H+j*20H
Write access enable register A j
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
20.8.26
Write access enable register B j
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
write accesses to the access protected region.
ETHj_ACCEN_WRB (j=0-5)
Offset address:
00044H+j*20H
Write access enable register B j
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
EN63 EN62 EN61 EN60 EN59 EN58 EN57 EN56 EN55 EN54 EN53 EN52 EN51 EN50 EN49 EN48
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
EN47 EN46 EN45 EN44 EN43 EN42 EN41 EN40 EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
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
ENq (q=32-63)
q-32
rw
Write access enable for TAG-ID q
This bit enables write access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for write access
1B Enabled for write access
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3810
v1.1
2025-06-26


20.8.27
Read access enable register A j
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
ETHj_ACCEN_RDA (j=0-5)
Offset address:
00048H+j*20H
Read access enable register A j
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
20.8.28
Read access enable register B j
ACCEN register set
This register defines which master agent function TAG identifier (TAG-ID) encodings are enabled or disabled for
read accesses to the access protected region.
ETHj_ACCEN_RDB (j=0-5)
Offset address:
0004CH+j*20H
Read access enable register B j
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
EN63 EN62 EN61 EN60 EN59 EN58 EN57 EN56 EN55 EN54 EN53 EN52 EN51 EN50 EN49 EN48
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
EN47 EN46 EN45 EN44 EN43 EN42 EN41 EN40 EN39 EN38 EN37 EN36 EN35 EN34 EN33 EN32
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
ENq (q=32-63)
q-32
rw
Read access enable for TAG-ID q
This bit enables read access to the access protected region for
transactions with the TAG-ID q.
0B Disabled for read access
1B Enabled for read access
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3811
v1.1
2025-06-26


20.8.29
VM access enable register j
ACCEN register set
This register defines which virtual machine encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each VMx.
ETHj_ACCEN_VM (j=0-5)
Offset address:
00050H+j*20H
VM access enable register j
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
20.8.30
PRS access enable register j
ACCEN register set
This register defines which protection register set encodings are enabled or disabled for accesses to the access
protected region. There is one RDx and WRx bit for each PRSx.
ETHj_ACCEN_PRS (j=0-5)
Offset address:
00054H+j*20H
PRS access enable register j
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
20  Data Routing Engine (DRE)
Reference manual
3812
v1.1
2025-06-26


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
20.8.31
RP r mode register
The Mode Register defines the attributes used by the DRE bus master interfaces when a routing operation
related to a Resource Partition (RP) accesses the on chip buses.
MODEr (r=0-7)
Offset address:
01040H+r*4
RP r mode register
Application Reset value:
0000 0001H
31
30
29
28
27
26
25
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
TAG
OFF
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
MOD
E
r
rw
Field
Bits
Type
Description
MODE
0
rw
Resource Partition Supervisor Mode
0B Bus master interface accesses on chip bus in user mode.
1B Bus master interface accesses on chip bus in supervisor mode.
VM
18:16
rw
Virtual Machine
Bus master interface accesses fabric with extended VM tag ID
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
Bus master interface accesses fabric with extended PRS tag ID
configured in this bit-field
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3813
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
PRSEN
23
rw
Protection Set Enable
0B Disable: PRS disabled
1B Enable: PRS enabled
TAGOFF
24
rw
Tag Offset
Bus master interface accesses fabric with extended tag ID.
TAG# = DRE_BASE_TAG (011110b) + TAG_OFF
0
15:1,
31:25
r
Reserved
Read as 0; should be written with 0.
20.8.32
CAN i resource partition
This SFR configures the resource allocation for access made to the CAN Interfaces
CANi_RP (i=0-19)
Offset address:
01060H+i*4
CAN i resource partition
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
RPI
r
rw
Field
Bits
Type
Description
RPI
2:0
rw
CAN Resource Partition Index
This bit-field indicates the resource partition allocated to CAN
interfaces.
0
31:3
r
Reserved
Read as 0; should be written with 0.
20.8.33
CAN input buffer pending request
The pending requests for CAN input buffers are set by hardware in this SFR.
CIBL_BPR
Offset address:
010B8H
CAN input buffer pending request
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
PR19 PR18 PR17 PR16
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
PR15 PR14 PR13 PR12 PR11 PR10
PR9
PR8
PR7
PR6
PR5
PR4
PR3
PR2
PR1
PR0
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
20  Data Routing Engine (DRE)
Reference manual
3814
v1.1
2025-06-26


Field
Bits
Type
Description
PRj (j=0-19)
j
rwh
Buffer Pending Request
Indicates a pending CAN frame to be proceessed in corresponding
buffer. A pending request is set by hardware when a new CAN frame is
stored in a buffer. It is cleared by hardware when the CAN frame is
processed by ACF CAN-Ethernet Format Engine.
Whenever there is a timeout, the corresponding CIBUF is taken out of
the arbitration. The software shall clear the timeout status within the
CITO register and also clear this bit if needed after reading the frame. In
case the same CIBUF is to be reused (included again in the next
arbitration), the software shall clear only the timeout status. Software
write with 1b also clears the pending request.
0B No pending Request
No request for the corresponding buffer
1B New pending request
A new pending request for the corresponding buffer
0
31:20
r
Reserved
Read as 0; should be written with 0
20.8.34
CAN input buffer list status
CIBL_STATUS
Offset address:
010BCH
CAN input buffer list status
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
WDT
E
CRC
E
BE
BF
r
rwh
rwh
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
CBI
0
PIDX
r
rh
r
rh
Field
Bits
Type
Description
PIDX
5:0
rh
Put Index
This bit-field shows the index corresponding to the buffer at which a
new CAN frame will be stored. When Buffer Full flag (BF) is set, value of
this bit-field is ignored.
CBI
13:8
rh
Current CAN Input Buffer Index
This bit-field indicates that CAN input buffer index currently processed
by the ACF CAN-Ethernet Format Engine. Valid values are 1 to 20.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3815
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
BF
16
rh
Buffer Full
This bit-field shows the buffer full status. This flag is set by hardware
when all the buffers have pending requests set. The flag is cleared by
hardware when there is a free buffer available
Note: When all the EOBUFs corresponding to the DIDs of the CAN
frames in the CIBL are disabled, it leads to a buffer full condition. The
software shall enable the EOBUF based on the buffer full interrupt
0B Free buffers available
1B CAN Input Buffer List is full
BE
17
rh
Buffer Empty
This flag shows the buffer empty condition. The flag is set by hardware
when there are no buffers with a pending request. The flag is cleared by
hardware when atleast one buffer has a pending request set.
0B Buffer not empty
Buffers have pending requests set.
1B Buffer empty
Buffers have no pending requests set
CRCE
18
rwh
CRC error flag
This bit is set by the hardware to indicate an CRC mismatch while
verifying the 16-bit CRC part of the CAN frame in the CIBUF before
writing the final block of data into the EOBUF. The software write with 1
clears this bit.
WDTE
19
rwh
Watchdog timeout error flag
This bit is set by the hardware to indicate an CAN Watchdog timeout
error in case of delayed processing of the CAN frame in CIBUF by the
ACF CAN-ETH assembler. Software write with 1 clears this bit
0
7:6,
15:14,
31:20
r
Reserved
Read as 0; should be written with 0.
20.8.35
CAN output buffer pending request 0
The pending requests for CAN output buffers from index 0 to 31 are set by hardware in this register.
COBL_BPR0
Offset address:
010C8H
CAN output buffer pending request 0
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
PR31 PR30 PR29 PR28 PR27 PR26 PR25 PR24 PR23 PR22 PR21 PR20 PR19 PR18 PR17 PR16
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
PR15 PR14 PR13 PR12 PR11 PR10
PR9
PR8
PR7
PR6
PR5
PR4
PR3
PR2
PR1
PR0
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
20  Data Routing Engine (DRE)
Reference manual
3816
v1.1
2025-06-26


Field
Bits
Type
Description
PRj (j=0-31)
j
rwh
Buffer Pending Request
Indicates a pending CAN frame to be proceessed in corresponding
buffer. A pending request is set by CAN Transmit Routing Engine when a
new CAN frame is stored in a buffer. It is cleared by Routing Control Unit
when the CAN frame is transferred to corresponding destination(s).
Whenever there is a timeout, the corresponding COBUF is taken out of
the arbitration. The software shall clear the timeout status within the
COTO0 and COTO1 registers and also clear this bit if needed after
reading the frame. In case the same COBUF is to be reused (included
again in the next arbitration), the software shall clear only the timeout
status. Software write with 1 clears this bit
0B No pending Request
No request for the corresponding buffer
1B New pending request
A new pending request for the corresponding buffer
20.8.36
CAN output buffer pending request 1
The pending requests for CAN output buffers from index 32 to 63 are set by hardware in this register.
COBL_BPR1
Offset address:
010CCH
CAN output buffer pending request 1
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
PR63 PR62 PR61 PR60 PR59 PR58 PR57 PR56 PR55 PR54 PR53 PR52 PR51 PR50 PR49 PR48
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
PR47 PR46 PR45 PR44 PR43 PR42 PR41 PR40 PR39 PR38 PR37 PR36 PR35 PR34 PR33 PR32
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
PRj (j=32-63)
j-32
rwh
Buffer Pending Request
Indicates a pending CAN frame to be proceessed in corresponding
buffer. A pending request is set by CAN Transmit Routing Engine when a
new CAN frame is stored in a buffer. It is cleared by Routing Control Unit
when the CAN frame is transferred to corresponding destination(s).
Whenever there is a timeout, the corresponding COBUF is taken out of
the arbitration. The software shall clear the timeout status within the
COTO0 and COTO1 registers and also clear this bit if needed after
reading the frame. In case the same COBUF is to be reused (included
again in the next arbitration), the software shall clear only the timeout
status. Software write with 1 clears this bit
0B No pending Request
No request for the corresponding buffer
1B New pending request
A new pending request for the corresponding buffer
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3817
v1.1
2025-06-26


20.8.37
CAN output buffer list status
COBL_STATUS
Offset address:
010D0H
CAN output buffer list status
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
WDT
E
0
BE
BF
r
rwh
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
PIDX
r
rh
Field
Bits
Type
Description
PIDX
6:0
rh
Put Index
This bit-field shows the index corresponding to the buffer at which a
new CAN frame is stored. When Buffer Full (BF) flag is set, value of this
bit-field is ignored.
BF
16
rh
Buffer Full
This bit-field shows the buffer full status. This flag is set by hardware
when all the buffers have pending requests set. The flag is cleared by
hardware when there is a free buffer available.
0B Free buffers available
1B CAN Output Buffer List is full
BE
17
rh
Buffer Empty
This flag shows the buffer empty condition. The flag is set by hardware
when there are no buffers with a pending request. The flag is cleared by
hardware when atleast one buffer has a pending request set.
0B Buffers have pending requests set
1B Buffers have no pending requests set
WDTE
19
rwh
Watchdog timeout error flag
This bit is set by the hardware to indicate an CAN Watchdog timeout
error in case of delayed processing of the CAN frame in COBUF by the
Routing control unit. Software write with 1 clears this bit
0
15:7,
18,
31:20
r
Reserved
Read as 0; should be written with 0.
20.8.38
Ethernet input buffer i configuration
EIBUFi_CONFIG (i=0-5)
Offset address:
010D8H+i*14H
Ethernet input buffer i configuration
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3818
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
RRF
0
0
r
rw
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
NTSCF_SA
0
r
rw
r
Field
Bits
Type
Description
NTSCF_SA
7:2
rw
Start Address of the NTSCF Header
This bit-field defines the bits [7:2] of the offset address from EIBUF start
address which the NTSCF header starts. Note: The start address offset is
always 32 bit aligned.
RRF
28
rw
Reject Remote Frame
When this bit-field is set, ACF_CAN_BRIEF messages with RTR = 1 are
not processed. When this bit is not set, there is no CAN payload data
copied by the DRE. The frame is copied until R1
0
1:0,
26:8,
27,
31:29
r
Reserved
20.8.39
Ethernet input buffer i error
EIBUFi_ERROR (i=0-5)
Offset address:
010E0H+i*14H
Ethernet input buffer i error
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
DERRTYP
BF
RDE
SE
WDT
E
r
rh
rwh
rwh
rwh
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3819
v1.1
2025-06-26


Field
Bits
Type
Description
WDTE
0
rwh
Ethernet watchdog timeout error
This bit is set by the hardware to indicate an Ethernet Watchdog
timeout error in case of delayed processing of the Ethernet frame in
EIBUF by the ACF engine or by the Tx Descriptor Handler. The software
shall read the frame directly from the EIBUF and clear this flag.
Software write with 1 clears this bit.
In case a WDTE event occurs during a forwarding request, the software
identifies the EIBUF by checking the EREQ.CBIi and EREQ.FWDi_REQ
bits. Clearing the EREQ.FWDi_REQ would automatically clear the
EIBUF_STATUS.BPR bit.
EIBUF_STATUS.BPR bit could already be cleared by DRE in some cases
even after the WDTE error occurs as the forwarding request could be
already processed within the time the WDTE error is triggered
When there is a watchdog timeout error, the software has to restart the
Tx Descriptor Handler by setting the TETHDLi_CTRL.STOP request in
order to avoid the Tx Descriptor Handler waiting indefinitely for the
Write-back format
RDESE
1
rwh
Rx descriptor error
This bit is also set by hardware under following scenarios:
Error in Rx descriptor is indicated by bits RDESCi_WR3L.ES,
RDESCi_WR3G.ES, and RDESCi_WR3G.ETLT. The software shall read the
frame directly from the EIBUF and clear this flag. Software write with 1
clears this bit. This bit shall be cleared by the software only after
clearing the corresponding TXi_REQ or FWDi_REQ
BF
2
rwh
Buffer full
This bit is set by the hardware to indicate that the EIBUF is full. It is set
by the DRE when the calculated size of the Ethernet frame from the
NTSCF header or the packet length from the receive descriptor Write-
back format RDESCi_WR3.PL exceeds the maxumum size of the EIBUF.
The software shall read the frame directly from the EIBUF and clear this
flag. Software write with 1 clears the bit.
0B Free buffer
1B EIBUF full
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3820
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DERRTYP
5:3
rh
Descriptor error type
This bit-field indicates the reason for RDESE error. This is set by the
hardware when RDESE error occurs and cleared by hardware when the
software clears RDESE
000B No error
001B Rx Poll Demand error
Bus error while Rx Tail Pointer register update
010B Rx DMA state error
The Rx DMA channel is in STOP state
011B Incorrect OWN bit
In case the OWN bit is not set while the Rx DMA channel is
reading the Rx descriptor read format
100B PTR mismatch read
Mismatch between the Read format Rx descriptor pointed to by
RETHDLi_CTRL.PTR and the descriptor being read by Rx DMA
channel
101B PTR mismatch Write-back
Mismatch between the Rx descriptor pointed to by
RETHDLi_CTRL.PTR and the descriptor being written back by Rx
DMA channel
110B Write-back error
Write-back error in GETH Rx descriptor is indicated by bits
RDESCi_WR3G.ES and LETH Rx descriptor is indicated by
RDESCi_WR3L.ES. Write-back error also occurs when the Write-
back format has the OWN bit set and LD bit not set
111B Reserved
0
31:6
r
Reserved
Read as 0; should be written with 0.
20.8.40
Ethernet input buffer i status
EIBUFi_STATUS (i=0-5)
Offset address:
010E4H+i*14H
Ethernet input buffer i status
Kernel Reset value:
2003 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
BPR
BPR
C
RXR
EQ
0
MSFE
ACF_CAN_ADDR
rh
rwh
rwh
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
FC
RFE
CFE
LME
IDID
IFT
FE
LE_ACF_CAN_ADDR
rwh
rwh
rwh
rwh
rwh
rwh
rwh
rh
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3821
v1.1
2025-06-26


Field
Bits
Type
Description
LE_ACF_CAN_
ADDR
8:0
rh
Last Error ACF CAN Address Pointer
This bit-field indicates the latest ACF_CAN_ADDR (bits 10 to 2 of the 32-
bit aligned address) of the ACF_CAN_BRIEF message which had either a
Remote Frame Error (RFE) or a CAN Format Error (CFE). The value of this
bit-field is valid only when either RFE or CFE error status bits are set.
This bit-field is reset by the hardware once the BPR is set again for the
next request
FE
9
rwh
Input Ethernet Frame Error
This flag is set in case of Ethernet frame error and the frame cannot be
processed by the ACF CAN-Ethernet Format Engine or the Forwarding
engine. This bit-field is set when any of the IFT, IDID, CFE,LME, WDTE,
RDESE or BF flags are set. Hardware sets the flag and software write
with 1 clears the flag.
IFT
10
rwh
Invalid Frame Type
This flag is set when the "Subtype" field of NTSCF header has a value
other than 0x82. Hardware sets the flag and a software write with 1b
clears the flag. In case the descriptor mode is used, this bit is set only
when IDID is set to indicate the software the type of frame that caused
the error
IDID
11
rwh
Invalid destination ID
This bit-field is set when there is no matching Stream ID Filter element
corresponding to the "Stream ID" of the input frame and there is also
no matching FWDID Filter element. Hardware sets the flag and a
software write with 1b clears the flag. Once set, the IDID status bit is
sticky until SW clears it. The next incoming forwarding frame shall be
forwarded irrespective of this bit being set unless there is again an IDID
error for this frame.
LME
12
rwh
AVTP Length Mismatch Error
This bit-field indicates if the calculated ACF_PAYLOAD_LENGTH is
greater than the "Ntscf_data_length" value of the NTSCF header of
input Ethernet frame. Hardware sets the flag and a software write with
1b clears the flag.
CFE
13
rwh
CAN Format Error
This bit-field is set when the "ACF_MSG_TYPE" of the CAN frame
contained in the input Ethernet frame has a value other than 0x2.
Hardware sets the flag and a software write with 1b clears the flag.
RFE
14
rwh
Remote Frame Error
This bit-field is set when EIBUF_CONFIG.RRF = 1 and a CAN frame has
RTR = 1. Hardware sets the flag and a software write with 1b clears the
flag.
FC
15
rwh
Ethernet Frame Complete
This flag is set when the input Ethernet frame is processed by ACF CAN-
Ethernet Format Engine that is when EIBUFi_STATUS.BPR bit-field is
cleared by hardware. Software write with 1 clears the bit-field.
Note: The SW should clear this bit when the RETHDLi_CTRL.TRIG mode
is changed from interrupt to Rx descriptor mode
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3822
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ACF_CAN_ADD
R
24:16
rh
ACF CAN Address Pointer
This bit-field indicates the bits 10 to 2 of offset address from the NTSCF
header start address of the Ethernet Input Buffer from which a new
ACF_CAN_BRIEF message is to be read from. The bits 1 and 0 of the
physical address to be considered as 0, as the address is always 32-bit
aligned. The first ACF_CAN_BRIEF message is always read from offset of
0xC. The address is modified to the start of next ACF_CAN_BRIEF
message after processing the fetch ACF_CAN_BRIEF message by the
ACF CAN-Ethernet Format Engine. The bit-field is reset to 0x3 (32-bit
aligned address representation of the offset address 0xC) when
EIBUFi_STATUS.BPR is set again for the next request. BPR is cleared by
hardware (when frame processing is completed) or by software setting
BPRC = 1 (software abort).
MSFE
27:25
rh
Matched Stream ID Filter Element
This bit-field indicates the index of the matched Stream-ID filter
element. Valid match indicated only when IDID = 0. In case there is no
Stream-ID match found, this bit-field is set to 7 and IDID is set to 1 if
there is no forwarding filter match
RXREQ
29
rwh
Ethernet receive request
This bit-field indicates a free Ethernet Input Buffer available to receive a
Ethernet frame.
1B - The bit-field is set by hardware and cleared by software with write
of 1B after a frame is written to the EIBUF. The software to clear the bit
after reset or after writing the Ethernet frame into the EIBUF.
0B - A software write of 0B has no effect
BPRC
30
rwh
Buffer Pending Request Clear
This bit-field allows software to clear the BPR of EIBUF. Software write
with 1b clears the BPR bit-field of EIBUF. This bit-field is cleared at once
the BPR bit-field is cleared by hardware. A software write with 0b has no
effect.
BPR
31
rh
Buffer Pending Request
This bit-field indicates a pending request for the EIBUF. The Ethernet
Descriptor Handler writes 1b to indicate a new input Ethernet frame in
EIBUF. The ACF CAN-Ethernet Format Engine clears the bit-field by
hardware after completing extraction all CAN Frames from the input
Ethernet frame. Software can also clear the flag (example: Software
abort) by setting the BPRC bit-field to 1b.
0
28
r
Reserved
Read as 0; Written as 0
20.8.41
Ethernet output buffer j configuration
EOBUFj_CONFIG (j=0-5)
Offset address:
01150H+j*38H
Ethernet output buffer j configuration
Kernel Reset value:
0032 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3823
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
TTM
HE
DID
r
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
PL
r
rw
Field
Bits
Type
Description
PL
10:0
rw
ACF Payload Length
This bit-field configures the size in bytes of the ACF payload of Ethernet
Output Buffer. Only the value of bits PL[10:2] is considered and PL[1:0]
is always considered by hardware as 00b, so that the payload size is
always an integral multiple of 32-bits. The minimum value is 8 bytes
and maximum value can be 1484 bytes.
0 - Ethernet Output Buffer is disabled
4 - Considered as 8 bytes
8 to 1484 - Specifies the configured number of bytes (always a multiple
of 4)
>1484 - Considered as 1484
Note: When PL is not configured according to the Transmit trigger mode
TTM and configuration TTC, the Buffer full flag BF is set when the
EOBUF cannot accomodate the incoming CAN frame. The PL shall be
configured such that there is at least a single ACF_CAN_BRIEF message
within the EOBUF. There is no TXREQ triggered if the EOBUF is empty
DID
21:16
rw
Destination ID of the Buffer
This bit-field assigns a routing destination ID for the Ethernet Output
Buffer. The input CAN frames with a matching destination ID with this
bit-field value are assembled to the Ethernet Output Buffer. Valid values
are from 0x18 till 0x1D. Other values are reserved.
Only consecutive EOBUFs can be configured with similar DIDs. For e.g.:
EOBUF0, EOBUF1 can have DID=18H. But if the configurations of DIDs is
EOBUF0=18H, EOBUF1=19H and EOBUF2=18H, then it is incorrect.
HE
22
rw
Header Enable
This bit-field enables the Ethernet header content of the buffer.
0B Ethernet header insertion is disabled
1B Ethernet header insertion is enabled
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3824
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TTM
24:23
rw
Transmit Trigger Mode
This bit-field configures the AVTP frame transmit trigger modes.
Note : When Buffer full flag BF is set, the DRE forces a SW transmit
trigger mode for that EOBUF irrespective of the trigger mode
configured. The software shall set the TXRDY flag based on the Buffer
full interrupt. When Buffer full flag BF is set in descriptor mode, the Tx
descriptors are prepared and there is no transmit trigger generated
In case of SW trigger mode, the TXRDY bit should not be set when the
TXREQ bit or TXi_REQ bit is already set
00B SWTM: Software Triggered Transmit Mode
Transmit trigger is initiated when software sets
EOBUFj_STATUS.TXRDY.
01B FCTM: Frame Count Transmit Mode
The transmit trigger is based on configured number of CAN
frames (EOBUFj_TTC.TFL) in a transmit Ethernet frame.
10B BFTM: Buffer Fill Level Transmit Mode
The transmit trigger condition is based on the fill size of the
Ethernet Output Buffer as configured in EOBUFj_TTC.BUFT.
11B TTTM: Time Triggered Transmit Mode
The transmit trigger condition is based on a timer as configured
in EOBUFj_TTC and EOBUFj_TTS.
0
15:11,
31:25
r
Reserved
Read as 0; should be written with 0.
20.8.42
Ethernet output buffer j MAC header 0
EOBUFj_MAC_H0 (j=0-5)
Offset address:
01154H+j*38H
Ethernet output buffer j MAC header 0
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
DA1
DA0
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
DA0
23:16
rw
MAC Destination Address 0
This bit-field corresponds to bits 47 to 40 of the MAC destination
address of the transmit Ethernet frame.
DA1
31:24
rw
MAC Destination Address 1
This bit-field corresponds to bits 39 to 32 of the MAC destination
address of the transmit Ethernet frame.
0
15:0
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3825
v1.1
2025-06-26


20.8.43
Ethernet output buffer j MAC header 1
EOBUFj_MAC_H1 (j=0-5)
Offset address:
01158H+j*38H
Ethernet output buffer j MAC header 1
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
DA5
DA4
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
DA3
DA2
rw
rw
Field
Bits
Type
Description
DA2
7:0
rw
MAC Destination Address 2
This bit-field corresponds to bits 31 to 24 of the MAC destination
address of the transmit Ethernet frame.
DA3
15:8
rw
MAC Destination Address 3
This bit-field corresponds to bits 23 to 16 of the MAC destination
address of the transmit Ethernet frame.
DA4
23:16
rw
MAC Destination Address 4
This bit-field corresponds to bits 15 to 8 of the MAC destination address
of the transmit Ethernet frame.
DA5
31:24
rw
MAC Destination Address 5
This bit-field corresponds to bits 7 to 0 of the MAC destination address
of the transmit Ethernet frame.
20.8.44
Ethernet output buffer j MAC header 2
EOBUFj_MAC_H2 (j=0-5)
Offset address:
0115CH+j*38H
Ethernet output buffer j MAC header 2
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
SA3
SA2
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
SA1
SA0
rw
rw
Field
Bits
Type
Description
SA0
7:0
rw
MAC Source Address
This bit-field corresponds to bits 47 to 40 of the MAC source address of
the transmit Ethernet frame.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3826
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
SA1
15:8
rw
MAC Source Address
This bit-field corresponds to bits 39 to 32 of the MAC source address of
the transmit Ethernet frame.
SA2
23:16
rw
MAC Source Address
This bit-field corresponds to bits 31 to 24 of the MAC source address of
the transmit Ethernet frame.
SA3
31:24
rw
MAC Source Address
This bit-field corresponds to bits 23 to 16 of the MAC source address of
the transmit Ethernet frame.
20.8.45
Ethernet output buffer j MAC header 3
EOBUFj_MAC_H3 (j=0-5)
Offset address:
01160H+j*38H
Ethernet output buffer j MAC header 3
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
TPID_L
TPID_H
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
SA5
SA4
rw
rw
Field
Bits
Type
Description
SA4
7:0
rw
MAC Source Address
This bit-field corresponds to bits 15 to 8 of the MAC source address of
the transmit Ethernet frame.
SA5
15:8
rw
MAC Source Address
This bit-field corresponds to bits 7 to 0 of the MAC source address of the
transmit Ethernet frame.
TPID_H
23:16
rw
Tagged Protocol Identifier High
This bit-field represents the MSB of TPID field. The TPID field is
configured to a value of 8100h for tagged Ethernet frames, as required
by IEEE Std. 802.1Q
TPID_L
31:24
rw
Tagged Protocol Identifier Low
This bit-field represents the LSB of TPID field. The TPID field is
configured to a value of 8100h for tagged Ethernet frames, as required
by IEEE Std. 802.1Q
20.8.46
Ethernet output buffer j MAC header 4
EOBUFj_MAC_H4 (j=0-5)
Offset address:
01164H+j*38H
Ethernet output buffer j MAC header 4
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3827
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
AVTPET_L
AVTPET_H
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
VTAG_L
VTAG_H
rw
rw
Field
Bits
Type
Description
VTAG_H
7:0
rw
VLAN Tag High
This bit-field is configured by user with MSB of VLAN tag for the transmit
Ethernet frame as specified by IEEE Std 802.1Q. The VLAN tag contains
PCP (3 bits), DEI (1 bit) & VID (12 bits).
VTAG_L
15:8
rw
VLAN Tag Low
This bit-field is configured by user with LSB of VLAN tag for the transmit
Ethernet frame as specified by IEEE Std 802.1Q. The VLAN tag contains
PCP (3 bits), DEI (1 bit) & VID (12 bits).
AVTPET_H
23:16
rw
AVTP Ethertype High
This bit-field contains the MSB of AVTPET field. This AVTPET field is
used to identify the transmit Ethernet frame as AVTP frames. The
corresponding Ethertype for AVTP frame is 0x22F0
AVTPET_L
31:24
rw
AVTP Ethertype Low
This bit-field contains the LSB of AVTPET field. This AVTPET field is used
to identify the transmit Ethernet frame as AVTP frames. The
corresponding Ethertype for AVTP frame is 0x22F0
20.8.47
Ethernet output buffer j NTSCF header
EOBUFj_NTSCF_H0 (j=0-5)
Offset address:
01168H+j*38H
Ethernet output buffer j NTSCF header
Kernel Reset value:
0000 0082H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
SN
NTSCFDL_L
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
SV
0
NTSCFDL_H
SUBTYP
rw
r
rh
r
Field
Bits
Type
Description
SUBTYP
7:0
r
Subtype of AVTP Frame
This bit-field is used to identify the format being carried by AVTP frame.
Non-Time Synchronous Control frames (NTSCF) has subtype value of
0x82.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3828
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
NTSCFDL_H
10:8
rh
NTSCF Data Length High
This bit-field contains bits 10 to 8 of NTSCF data length field of the ACF
payload data in bytes. The ACF CAN-Ethernet Format Engine updates
the length on every ACF_CAN_BRIEF message written to the ACF
payload section of Ethernet Output Buffer. It is reset to 0 when
EOBUFj_STATUS.TXREQ is cleared to 0.
SV
15
rw
Stream ID Valid
This bit-field indicates whether the STREAM_ID field contains an ID for a
stream with a valid stream reservation.
NTSCFDL_L
23:16
rh
NTSCF Data Length Low
This bit-field contains bits 7 to 0 of NTSCF data length field of the ACF
payload data in bytes. The ACF CAN-Ethernet Format Engine updates
the length on every ACF_CAN_BRIEF message written to the ACF
payload section of Ethernet Output Buffer.
SN
31:24
rwh
Sequence Number
This bit-field indicates the sequence of AVTP frames in a stream.
Software can configure an initial value for a stream and the sequence
number if incremented by the ACF CAN-Ethernet Format engine for
every new transmit AVTP frame. Upon overflow, the value is wrapped
around to 0x00 by hardware.
0
14:11
r
Reserved
Read as 0; should be written with 0.
20.8.48
Ethernet output buffer j Stream ID configuration 0
EOBUFj_NTSCF_STREAM0_ID (j=0-5)
Offset address:
0116CH+j*38H
Ethernet output buffer j Stream ID configuration 0
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
ID3
ID2
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
ID1
ID0
rw
rw
Field
Bits
Type
Description
ID0
7:0
rw
Stream ID
This bit-field defines bits 63 to 56 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
ID1
15:8
rw
Stream ID
This bit-field defines bits 55 to 48 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3829
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ID2
23:16
rw
Stream ID
This bit-field defines bits 47 to 40 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
ID3
31:24
rw
Stream ID
This bit-field defines bits 39 to 32 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
20.8.49
Ethernet output buffer j Stream ID configuration 1
EOBUFj_NTSCF_STREAM1_ID (j=0-5)
Offset address:
01170H+j*38H
Ethernet output buffer j Stream ID configuration 1
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
ID7
ID6
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
ID5
ID4
rw
rw
Field
Bits
Type
Description
ID4
7:0
rw
Stream ID
This bit-field defines bits 31 to 24 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
ID5
15:8
rw
Stream ID
This bit-field defines bits 23 to 16 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
ID6
23:16
rw
Stream ID
This bit-field defines bits 15 to 8 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
ID7
31:24
rw
Stream ID
This bit-field defines bits 7 to 0 of the identifier for stream
identification. User must configure a valid Stream ID as defined in
subclause 35.2.2.8.2 of IEEE Std 802.1Q - 2014.
20.8.50
Ethernet output buffer j status
EOBUFj_STATUS (j=0-5)
Offset address:
01174H+j*38H
Ethernet output buffer j status
Kernel Reset value:
0008 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3830
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
ACF_CAN_ADDR
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
TXR
DY
TXRE
Q
TTL
0
BF
ACFL
r
rwh
rwh
rwh
r
rh
rh
Field
Bits
Type
Description
ACFL
7:0
rh
ACF CAN Fill Level
This bit-field indicates the number of CAN frames assembled in the
Ethernet Output Buffer. The field is reset to 0x0 when
EOBUFj_STATUS.TXREQ is cleared to 0.
BF
8
rh
Buffer Full
This flag is set the EOBUF cannot accommodate the currently
processed CAN frame. This bit shall only be cleared by hardware after
TXREQ (in case of interrupt trigger) is cleared by software. In case the
descriptor mode is used, this bit shall be cleared by hardware
simultaneously while clearing EREQ.TXi_REQ.
Note : The EOBUFj_CONFIG.PL needs to be configured according the
Transmit trigger mode TTM and configuration TTC
0B Free buffer
1B EOBUF full
TTL
10
rwh
Transmit Trigger Lost
This status bit is set by hardware when a transmit trigger condition is
skipped as the corresponding Ethernet Output Buffer is empty (ACFL =
0). A software write with 1b clears the bit-field. A write with 0b has no
effect.
TXREQ
11
rwh
Ethernet Output Buffer Transmit Request
This bit-field indicates a valid transmit Ethernet frame in the Ethernet
Output Buffer. The bit-field is set by hardware and cleared by software
with write of 1b. A software write of 0b has no effect.
TXRDY
12
rwh
Ethernet Output Buffer Transmit Ready
This bit-field is set by hardware when an Ethernet Output Buffer has a
transmit trigger as configured in EOBUFj_CONFIG.TTM. When TTM = 0,
the software write of 1b to this bit-field marks the transmit trgger
condition. The flag is cleared by hardware, when the transmit Ethernet
frame is prepared. A software write of 0b has no effect.
ACF_CAN_ADD
R
24:16
rh
ACF CAN Address Offset
This bit-field indicates the bits 10 to 2 of offset address from the start
address of the Ethernet Output Buffer at which a new ACF_CAN_BRIEF
message is to be stored. The bits 1 and 0 of the physical address to be
considered as 0, as the address is always 32-bit aligned. The first
ACF_CAN_BRIEF message is always stored at the offset address of 0x20.
This field is reset to 0x8 (32-bit aligned representation of the offset
address 0x20) when EOBUFj_STATUS.TXREQ is cleared to 0.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3831
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
9,
15:13,
31:25
r
Reserved
Read as 0. should be written with 0.
20.8.51
Ethernet output buffer j Transmit trigger configuration
EOBUFj_TTC (j=0-5)
Offset address:
01178H+j*38H
Ethernet output buffer j Transmit trigger configuration
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
TP
TFL
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
BUFT
r
rw
Field
Bits
Type
Description
BUFT
10:0
rw
Buffer Threshold
When EOBUFj_CONFIG.TTM = 0x2, this bit-field configures the threshold
size of the Ethernet Output Buffer ACF payload for transmit trigger. A
valid value of this bit-field is between 0x1 till the maximum size of the
Ethernet Output Buffer ACF payload as configured in
EOBUFj_CONFIG.PL
TFL
23:16
rw
Trigger Fill Level
When EOBUFj_CONFIG.TTM = 0x1, this bit-field defines the threshold for
number of CAN frames in an Ethernet Output Buffer for transmit trigger
condition. This bit-field cannot be zero.
Note: This value has to be set based on the size of the incoming CAN
frames and the size of the EOBUF. If this value is set too high, there
might not be a transmit trigger
TP
31:24
rw
Pre-scale for Timer
This bit-field defines the divider factor of the clock frequency used for
transmit trigger. The prescaler used is (TP+1).
0
15:11
r
Reserved
Read as 0; should be written with 0.
20.8.52
Ethernet output buffer j Timer threshold and status
EOBUFj_TTS (j=0-5)
Offset address:
0117CH+j*38H
Ethernet output buffer j Timer threshold and status
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3832
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
TRV
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
CTV
rh
Field
Bits
Type
Description
CTV
15:0
rh
Current Timer Value
This bit-field shows the current timer value. It is reloaded with the value
of TRV upon a non-zero write to TRV bit-field and is decremented at the
timer frequency. Transmit trigger condition occurs when it reaches 0.
The timer is halted when TRV is written with 0.
TRV
31:16
rw
Timer Reload Value
This bit-field defines the reload value of the transmit timers. It is
configured by the software. A non-zero TRV value indicates that the
timer is running.
When TRV transitions from zero to non-zero value, the timer is started.
The first transmit trigger is generated immediately. All subsequent
transmit triggers would be at the intervals of the value configured.
When the timer is already running and the SW changes the TRV to a
different non-zero value, the timer automatically adjusts the time
period without generating any surplus transmit trigger
20.8.53
Ethernet output buffer j error
EOBUFj_ERROR (j=0-5)
Offset address:
01180H+j*38H
Ethernet output buffer j error
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
DERRTYP
0
TDES
E
WDT
E
r
rh
r
rwh
rwh
Field
Bits
Type
Description
WDTE
0
rwh
Ethernet watchdog timeout error
This bit is set by the hardware to indicate an Ethernet Watchdog
timeout error in case of delayed availability of Ethernet frame to
transmit within the EOBUF and delayed read of the Ethernet frame from
EOBUF. Software write with 1 clears this bit
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3833
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TDESE
1
rwh
Tx descriptor error
This bit is also set by hardware under following scenarios:
Error in Tx descriptor is indicated by bit TDESCi_WR3G.DERR or
TDESCi_WR3L.DE. Software write with 1 clears this bit. This bit shall be
cleared by software only after clearing the corresponding TXi_REQ or
FWDi_REQ
DERRTYP
5:3
rh
Descriptor error type
This bit-field indicates the reason for TDESE error. This is set by the
hardware when TDESE error occurs and cleared by hardware when the
software clears TDESE
000B No error
001B Tx Poll Demand error
Bus error during the Tx Tail Pointer register update
010B Tx DMA state error
The Tx DMA channel is in STOP state
011B Incorrect OWN bit
In case the OWN bit is not set while the Tx DMA channel is
reading the Tx descriptor read format
100B PTR mismatch read
Mismatch between the Read format Tx descriptor pointed to by
TETHDLi_CTRL.PTR and the descriptor being read by Tx DMA
channel
101B PTR mismatch Write-back
Mismatch between the Tx descriptor pointed to by
TETHDLi_CTRL.PTR and the descriptor being written back by Tx
DMA channel
110B Write-back error
Write-back error in GETH Tx descriptor is indicated by bits
TDESCi_WR3G.DERR and LETH Tx descriptor is indicated by
TDESCi_WR3L.DE. Write-back error also occurs when the Write-
back format has the OWN bit set and LD bit not set
111B Reserved
0
2,
31:6
r
Reserved
Read as 0; should be written with 0.
20.8.54
Stream ID filter i configuration
SIDFi_FC (i=0-7)
Offset address:
0129CH+i*14H
Stream ID filter i configuration
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
RTI
0
MODE
FE
r
rw
r
rw
rw
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3834
v1.1
2025-06-26


Field
Bits
Type
Description
FE
0
rw
Filter Enable
This bit-field indicates whether the filter element is enabled (FE=1) or
disabled (FE=0).
MODE
2:1
rw
Filter Mode
This bit-field defines the mode of Stream ID filters
00B Classical Filter
Stream Filter 1 is used as Filter element and Stream Filter 2 is
used as mask.
01B Range Filter
The range of values between Stream Filter 1 and Stream Filter 2
are used for filtering.
10B Reserved
Reserved; not to be used
11B Reserved
Reserved; not to be used
RTI
6:4
rw
Routing Table Index
This bit filed indicates the Routing Table index which will be used by
the CAN Transmit Routing Engine for the CAN frames within the
Ethernet frame. Valid values are 0 to 3.
0
3,
31:7
r
Reserved
Read as 0; should be written with 0.
20.8.55
Stream ID filter i configuration Stream ID filter 1 lower
SIDFi_FIL1_L (i=0-7)
Offset address:
012A0H+i*14H
Stream ID filter i configuration Stream ID filter 1 lower
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
F1L
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
F1L
rw
Field
Bits
Type
Description
F1L
31:0
rw
Lower Filter 1 Stream ID
This bit-field defines the Filter 1 for Stream IDs
20.8.56
Stream ID filter i configuration Stream ID filter 1 higher
SIDFi_FIL1_H (i=0-7)
Offset address:
012A4H+i*14H
Stream ID filter i configuration Stream ID filter 1 higher
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3835
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
F1H
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
F1H
rw
Field
Bits
Type
Description
F1H
31:0
rw
Higher Filter 1 Stream ID
This bit-field defines the Filter 1 for Stream IDs
20.8.57
Stream ID filter i configuration Stream ID filter 2 lower
SIDFi_FIL2_L (i=0-7)
Offset address:
012A8H+i*14H
Stream ID filter i configuration Stream ID filter 2 lower
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
F2L
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
F2L
rw
Field
Bits
Type
Description
F2L
31:0
rw
Lower Filter 2 Stream ID
This bit-field defines the Filter 2 for Stream IDs
20.8.58
Stream ID filter i configuration Stream ID filter 2 higher
SIDFi_FIL2_H (i=0-7)
Offset address:
012ACH+i*14H
Stream ID filter i configuration Stream ID filter 2 higher
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
F2H
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
F2H
rw
Field
Bits
Type
Description
F2H
31:0
rw
Higher Filter 2 Stream ID
This bit-field defines the Filter 2 for Stream IDs
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3836
v1.1
2025-06-26


20.8.59
CAN transmit routing table i configuration
RTi_CONFIG (i=0-3)
Offset address:
01340H+i*8
CAN transmit routing table i configuration
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
NRULES
r
rw
Field
Bits
Type
Description
NRULES
7:0
rw
Number of routing rules
This bit-field configures the number of routing rules contained in the
CAN Transmit Routing Table (RTi). Valid values are from 0 to 128.
0 - CAN Transmit Routing Table is disabled
1 to 128 - Number of routing rules in the CAN Transmit Routing Table
>128 - Invalid configuration
0
31:8
r
Reserved
Read as 0; should be written with 0.
20.8.60
Routing request configuration
RREQ_CONFIG
Offset address:
0135CH
Routing request configuration
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
RTI
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
REQ
r
rh
Field
Bits
Type
Description
REQ
0
rh
New Routing Request
This bit-field indicates a new routing request for CAN Transmit Routing
Engine.
RTI
18:16
rh
Routing Table Index
This bit-field indicates the CAN Transmit Routing Table to be used for
the routing search done by the CAN Transmit Routing Engine. Valid
values are 0 to 3.
0
15:1,
31:19
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3837
v1.1
2025-06-26


20.8.61
CAN ID request
RREQ_CID
Offset address:
01360H
CAN ID request
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
XTD
0
ID
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
ID
rh
Field
Bits
Type
Description
ID
28:0
rh
CAN Identifier
This bit-field indicates the CAN ID for which the routing request is
initiated.
XTD
31
rh
Extended Identifier
This bit-field indicates the ID format of the CAN ID.
0B Standard 11-bit ID
1B Extended 29-bit CAN ID
0
30:29
r
Reserved
Read as 0; should be written with 0.
20.8.62
Uni-cast routing header
UCRH
Offset address:
01364H
Uni-cast routing header
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
DID
0
MODE
r
rh
r
rh
Field
Bits
Type
Description
MODE
1:0
rh
Routing Rule Mode
It defines the type of the routing rule
0 - Uni-cast rule
1 - Multi-cast rule
other - Reserved, considered as Uni-cast rule
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3838
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DID
13:8
rh
Destination ID
This bit-field indicates the destination CAN node to which the received
CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
0
7:2,
31:14
r
Reserved
Read as 0; should be written with 0.
20.8.63
Multi-cast routing header
MCRH
Offset address:
01364H
Multi-cast routing header
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
DID3
DID2
DID1
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
DID1
DID0
0
MODE
rh
rh
r
rh
Field
Bits
Type
Description
MODE
1:0
rh
Routing Rule Mode
It defines the type of the routing rule
0 - Uni-cast rule
1 - Multi-cast rule
other - Reserved, considered as Uni-cast rule
DID0
13:8
rh
Destination ID 1
This bit-field indicates the 1st destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID1
19:14
rh
Destination ID 2
This bit-field indicates the 2nd destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID2
25:20
rh
Destination ID 3
This bit-field indicates the 3rd destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3839
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
DID3
31:26
rh
Destination ID 4
This bit-field indicates the 4th destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
0
7:2
r
Reserved
Read as 0; should be written with 0.
20.8.64
Routing status
RS
Offset address:
01368H
Routing status
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
NMF
E
IRT
r
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
RE
r
rh
Field
Bits
Type
Description
RE
8:0
rh
Routing Element
This bit-field indicates Routing Element index which matches the CAN
ID of the routing request. This bit-field is reset by the hardware once the
BPR bit is cleared. This bit-field is not valid in case of IRT or NMFE error
IRT
16
rwh
Invalid Routing Table
This bit-field is set when the CAN Transmit Routing Table indexed in the
routing request is either disabled or invalid. Hardware sets the flag and
a software write with 1b clears the flag.
NMFE
17
rwh
Non-Matching Filter Element Error
This bit-field is set when there are no matching filter elements found for
the corresponding routing request. Hardware sets the flag and a
software write with 1b clears the flag.
0
15:9,
31:18
r
Reserved
Read as 0; should be written with 0.
20.8.65
CAN receive request 0
This register indicates Receive request from CAN interfaces
CANRXR0
Offset address:
0136CH
CAN receive request 0
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3840
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
C15_
RH1R
C15_
RH0
R
C14_
RH1
R
C14_
RH0
R
C13_
RH1
R
C13_
RH0
R
C12_
RH1
R
C12_
RH0
R
C11_
RH1
R
C11_
RH0
R
C10_
RH1
R
C10_
RH0
R
C9_R
H1R
C9_R
H0R
C8_R
H1R
C8_R
H0R
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
C7_R
H1R
C7_R
H0R
C6_R
H1R
C6_R
H0R
C5_R
H1R
C5_R
H0R
C4_R
H1R
C4_R
H0R
C3_R
H1R
C3_R
H0R
C2_R
H1R
C2_R
H0R
C1_R
H1R
C1_R
H0R
C0_R
H1R
C0_R
H0R
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
Ci_RH0R
(i=0-15)
2*i
rh
CANi Receive Host Buffer 0 Pending Request
This bit-field indicates a pending receive request from CANi interface
Receive Host Buffer 0
Ci_RH1R
(i=0-15)
2*i+1
rh
CANi Receive Host Buffer 1 Pending Request
This bit-field indicates a pending receive request from CANi interface
Receive Host Buffer 1
20.8.66
CAN receive request 1
This register indicates Receive request from CAN interfaces
CANRXR1
Offset address:
01370H
CAN receive request 1
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
C19_
RH1
R
C19_
RH0
R
C18_
RH1
R
C18_
RH0
R
C17_
RH1
R
C17_
RH0
R
C16_
RH1
R
C16_
RH0
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
Field
Bits
Type
Description
Ci_RH0R
(i=16-19)
2*i-32
rh
CANi Receive Host Buffer 0 Pending Request
This bit-field indicates a pending receive request from CANi interface
Receive Host Buffer 0
Ci_RH1R
(i=16-19)
2*i-31
rh
CANi Receive Host Buffer 1 Pending Request
This bit-field indicates a pending receive request from CANi interface
Receive Host Buffer 1
0
31:8
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3841
v1.1
2025-06-26


20.8.67
CAN transmit buffer available request
This register indicates Transmit Host Buffer 0 available request from CAN interfaces
CANTXR
Offset address:
01374H
CAN transmit buffer available request
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
C19_
THR
C18_
THR
C17_
THR
C16_
THR
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
C15_
THR
C14_
THR
C13_
THR
C12_
THR
C11_
THR
C10_
THR
C9_T
HR
C8_T
HR
C7_T
HR
C6_T
HR
C5_T
HR
C4_T
HR
C3_T
HR
C2_T
HR
C1_T
HR
C0_T
HR
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
Ci_THR
(i=0-19)
i
rh
CANi Transmit Host Buffer 0 Request
This bit-field indicates a free transmit buffer available in CANi interface
0
31:20
r
Reserved
Read as 0; should be written with 0.
20.8.68
Destination memory i configuration
DMEMi_CONFIG (i=0-27)
Offset address:
0137CH+i*20H
Destination memory i configuration
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
CTYP
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
OA
INP
ATH
AST
EN2
EN1
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
EN1
0
rwh
Enable Memory Destination 1
This bit-field is used to enable or disable the corresponding memory
destination by the software. The software sets this bit by writing 1 to
indicate that the buffer is ready for the CAN frame or CAN I-PDU to be
stored. Software write with 0 has no effect. The hardware clears this bit
after the CAN frames or CAN I-PDUs are assembled till the waternark
level.
0B DMEM not available
1B DMEM available
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3842
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
EN2
1
rwh
Enable Memory Destination 2
This bit-field is used to enable or disable the corresponding memory
destination by the software. The software sets this bit by writing 1 to
indicate that the buffer is ready for the CAN frame or CAN I-PDU to be
stored. Software write with 0 has no effect. The hardware clears this bit
after the CAN frames or CAN I-PDUs are assembled till the wraparound
level.
0B DMEM not available
1B DMEM available
AST
2
rw
Append Status Information
When set to 1, the DMEMi_STATUS register content is appended along
with the CAN message in the memory destination
0B DIS: DMEMi_STATUS not appended
1B EN: DMEMi_STATUS appended
ATH
3
rw
Append Timing Header
When set to 1, the CAN timing header is appended to the CAN message
at the memory destination
0B DIS: THEAD not appended
1B EN: THEAD appended
INP
7:4
rw
Interrupt Node Pointer
This bit-field configures the interrupt line to be triggered in case of a
watermark or address wraparound event. Valid values are 0 till 7. Other
values are reserved and will be considered as 0.
OA
15:8
rw
Offset Address
The offset address by which the destination address is incremented
after every routing operation to the destination memory. It defines the
size of each buffer at the destination memory. OA[0:2] is considered
always as 000b so that the calculated absolute destination address is
always 64-bit aligned.
In case of CAN I-PDU routing, the OA is considered for the count based
trigger mode to calculate the size of the frame data buffers 1 and 2. The
OA should be configured by the user based upon the number of I-PDUs
(DMEMi_WM and DMEMi_WA levels) and the size of the I-PDUs that are
to be assembled within the DMEMi. The OA value should also include
the Timing header (optional) and I-PDU header. It is illegal to configure
the OA smaller than the combined sizes of the incoming CAN messages
Note: Configuring the OA for Classical CAN I-PDU (Timing header
(optional) + PDU header + Payload), but incoming CAN FD I-PDUs into
the DMEMi would lead to buffer overflow as the size would be too small
Note: Avoid setting OA as 0x20 for CAN frames with larger payload of
more than 8 bytes. Such frames are rejected and an error is triggered
but the status flags WAF, WMF and BC are updated even though the
frame is rejected
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3843
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
CTYP
16
rw
Type of CAN message
This bit indicates the type of CAN message that is stored in the DMEM.
When the incoming CAN frame has the DID which is configured to
accept CAN I-PDU or vice-versa, the CAN message is discarded and
Invalid destination ID error is triggered
0B CAN Frame
1B CAN I-PDU
0
31:17
r
Reserved
20.8.69
Destination memory i transfer mode configuration
DMEMi_MODE (i=0-27)
Offset address:
01380H+i*20H
Destination memory i transfer mode configuration
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
FOM
BUF
TRIG
TYP
r
rw
rw
rw
rw
Field
Bits
Type
Description
TYP
0
rw
PDU Mode enabled
The bit-field configures the destination memory in the case of a CAN
frame or CAN I-PDU
0B MUXDIS: Padding
Padding bits are present between CAN messages
1B MUXEN: No padding
No padding bits present between CAN messages
TRIG
1
rw
Trigger Mode
This bit-field selects between two interrupt trigger modes
0B INDEX: Index-based interrupt trigger
This index based trigger is valid only for CAN I-PDUs. The
watermark and wraparound interrupts are triggered based on the
DMEMi_FDBI
1B COUNT: Count-based interrupt trigger
The watermark and wraparound interrupts are triggered based on
the buffer count DMEMi_STATUS.BC
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3844
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
BUF
2
rw
Buffer Mode
This bit configures the buffer split of the DMEM
0B SINGLE: Single buffer mode
The DMEM is divided into two parts Frame data buffer 1 and Frame
data buffer 2 based on the Watermark level and Wraparound levels
respectively. Note: Both the Frame data buffers always starts at a
64-bit aligned address.
1B CONT: Continuous buffer mode
The DMEM is treated as a continuous buffer. Only wraparound level
is considered
FOM
3
rw
FDBI overflow mode
This bit controls the data path of the new CAN frame or CAN I-PDU in
case of no space in the Frame data buffer
0B Continue
If frame or I-PDU is received that does not fit in the current part of
the DMEM Frame data buffer, it is placed into the other buffer when
the EN bit is set. Otherwise there is a buffer overflow error
triggered.
1B Overflow
The frame or I-PDU is discarded and an overflow error is triggered
0
31:4
r
Reserved
Read as 0; should be written as 0
20.8.70
Destination memory i status
DMEMi_STATUS (i=0-27)
Offset address:
01390H+i*20H
Destination memory i status
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
MC
0
BO
WAF
WMF
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
BC
0
SID
NM
rh
r
rh
rwh
Field
Bits
Type
Description
NM
0
rwh
New Message
This bit indicates a new message is transferred to destination memory.
Hardware sets this bit and software write with 1 clears the bit. Software
write with 0 has no effect.
SID
6:1
rh
Source ID
This bit-field indicates the source from which the message is fetched.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3845
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
BC
15:8
rh
Buffer Counter
This bit-field is incremented on every transfer of message to the
destination memory. The counter is reset to 0 when a wraparound
event has occurred.
Note: In index mode, if CAN messages with zero payload or less payload
are received, the count could exceed 255 depending on the
configuration. In this case, the counter wraps around to 0
WMF
16
rwh
Watermark Flag
This bit-field indicates watermark event. Hardware sets the flag and a
software write with 1b clears the flag.
WAF
17
rwh
Wraparound Flag
This bit-field is set when address wraparound has occurred. Hardware
sets the flag and a software write with 1b clears the flag.
BO
18
rwh
Buffer Overflow
This bit indicates a buffer overflow. This bit is set by hardware in case of
an buffer overflow error (DBOE) and cleared by software by writing 1.
Writing 0 has no effect.
MC
31:20
rwh
Message Counter
This bit-field is incremented on every message transfer to the
destination. A software write with a non zero value resets the counter
value to 0. The counter wraps around to 0 upon overflow.
0
7,
19
r
Reserved
Read as 0; should be written as 0
20.8.71
Destination memory i resource partition
DMEMi_RP (i=0-27)
Offset address:
01394H+i*20H
Destination memory i resource partition
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
RPI
r
rw
Field
Bits
Type
Description
RPI
2:0
rw
Resource Partition Index
This bit-field indicates the Resource Partition allocated to the
destination memory i.
0
31:3
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3846
v1.1
2025-06-26


20.8.72
Move engine source address
This SFR indicates the first address the Move Engine is reading from.
ME_SRCA
Offset address:
016F8H
Move engine source address
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
ADR
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
ADR
rh
Field
Bits
Type
Description
ADR
31:0
rh
Source Address
This bit-field indicates the current address the Move Engine is reading
from.
20.8.73
Move engine destination address
This SFR indicates the first address which the Move Engine is writing to.
ME_DESTA
Offset address:
016FCH
Move engine destination address
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
ADR
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
ADR
rh
Field
Bits
Type
Description
ADR
31:0
rh
Destination Address
This bit-field indicates the current address which the Move Engine is
writing to.
20.8.74
Move engine state
ME_STATE
Offset address:
01700H
Move engine state
Kernel Reset value:
0000 0000H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3847
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
DID
SID
SRIW SRIR
SPB
W
SPB
R
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
SPBR
0
rh
SPB Read
This bit-field is set when an FPI/SPB read operation is currently
performed by the Move Engine
SPBW
1
rh
SPB Write
This bit-field is set when an FPI/SPB write operation is performed by
the Move Engine
SRIR
2
rh
SRI Read
This bit-field is set when a SRI read operation is currently performed by
the Move Engine
SRIW
3
rh
SRI Write
This bit-field is set when a SRI write operation is performed by the Move
Engine
SID
9:4
rh
Source ID
This bit-field indicates the source ID of the current routing operation
DID
15:10
rh
Destination ID
This bit-field indicates the destination ID of the current routing
operation.
0
31:16
r
Reserved
Read as 0; Write with 0
20.8.75
Move engine first error source address
This SFR indicates the first read address at which the Move Engine has an error.
ME_FESRCA
Offset address:
01704H
Move engine first error source address
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
ADR
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
ADR
rh
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3848
v1.1
2025-06-26


Field
Bits
Type
Description
ADR
31:0
rh
First Error Source Address
This bit-field indicates the source address (that is start address of CAN
Receive Host Buffer or CAN Output Buffer) for the routing request which
has at least one of the IRDE, DBOE, SPBBE, SRIBE errors. The value of
this bit-field is frozen once any of the aforementioned error flags are
set. The value of this bit-field is ignored when there is no error (all Move
Engine error status flags IRDE, DBOE, SPBBE, SRIBE are 0).
20.8.76
Move engine first error destination address
This SFR indicates the first write address at which the Move Engine has an error.
ME_FEDESTA
Offset address:
01708H
Move engine first error destination address
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
ADR
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
ADR
rh
Field
Bits
Type
Description
ADR
31:0
rh
First Error Destination Address
This bit-field indicates the destination address (that is start address of
virtual CAN buffer at memory destination or CAN Input Buffer or CAN
Output Buffer) for the routing request which has at least one of the
DBOE, SPBBE, SRIBE errors. The value of this bit-field is frozen once any
of the aforementioned error flags are set. The value of this bit-field is
ignored when there is no error (Move Engine error status flags DBOE,
SPBBE, SRIBE are 0) or when FEDID has reserved destination ID values.
20.8.77
Move engine error register
ME_ERR
Offset address:
0170CH
Move engine error register
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
FEDID
FESID
FEDI
R
FEC
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
IRDE
DBO
E
SRIB
E
SPB
BE
0
r
rwh
rwh
rwh
rwh
r
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3849
v1.1
2025-06-26


Field
Bits
Type
Description
SPBBE
1
rwh
SPB Bus Transaction error
This bit-field indicates an error occurred during an FPI/SPB transaction
performed by Move Engine. Hardware sets the flag and a software write
with 1b clears the flag.
SRIBE
2
rwh
SRI Transaction Error
This bit-field indicates an error occurred during an SRI transaction
performed by the Move Engine. Hardware sets the flag and a software
write with 1b clears the flag.
Note: The hardware sets this bit and triggers interrupt INT_13 also in
the event of read data error detection and correction (EDC) error and
read data transaction ID error on SRI master interface (MIF)
DBOE
3
rwh
Destination Buffer Overflow Error
This bit-field indicates the destination buffer overflow condition that is,
the CAN frame size is larger than the buffer size of the corresponding
destination (shown in FEDID). Hardware sets the flag and a software
write with 1b clears the flag.
IRDE
4
rwh
Invalid Routing Destination Error
This bit-field indicates in case of routing requests with a destination ID
value corresponding to a reserved value or when the corresponding
destination is disabled. Hardware sets the flag and a software write
with 1b clears the flag.
FEC
18:16
rh
First error code
This bit-field is bit encoded to indicate which error first occurred. This
denotes that the FEDIR, FESID and FEDID corresponds to the error
indicated by this bit-field
000B No error
001B IRDE
010B DBOE
011B SRIBE
100B SPBBE
others, Reserved
FEDIR
19
rh
First Error Direction
This bit indicates whether access error was for read or write access
0B Read
1B Write
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3850
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FESID
25:20
rh
First Error Source ID
This bit-field indicates the source ID of the first routing operation which
has at least one of IRDE, DBOE, SPBBE or SRIBE errors. The value of this
bit-field is ignored when there is no error (all Move Engine error status
flags IRDE, DBOE, SPBBE or SRIBE are 0). The value of this bit-field is
frozen once any of the aforementioned error flags are set. When the
source ID of the routing or forwarding request is known for the
corresponding transaction, this bit-field is updated with the SID.
Otherwise in the case of the following scenarios where the source ID is
unknown, this bit-field is set to:
b111100 when a bus transaction error occurs during the write
operation of the Rx descriptor Tail Pointer. RDESE is set and interrupt
INT_10 triggered
b111101 when a bus transaction error occurs during the write
operation of the Tx descriptor Tail Pointer. TDESE is set and interrupt
INT_14 triggered
b111110 when a bus transaction error occurs during the read operation
of the DMA status register.
FEDID
31:26
rh
First Error Destination ID
This bit-field indicates the destination ID of the first routing operation
which has at least one of IRDE, DBOE, SPBBE or SRIBE errors. The value
of this bit-field is ignored when there is no error (all Move Engine error
status flags IRDE, DBOE, SPBBE or SRIBE are 0). The value of this bit-
field is frozen once any of the aforementioned error flags are set. When
the destination ID of the routing or forwarding request is known for the
corresponding transaction, this bit-field is updated with the DID.
Otherwise in the case of the following scenarios when the destination
ID is unknown, this bit-field is set to:
b111111 when a bus transaction error occurs during the read operation
of the routing header (RHEAD).
b111100 when a bus transaction error occurs during the write
operation of the Rx descriptor Tail Pointer. RDESE is set and interrupt
INT_10 triggered
b111101 when a bus transaction error occurs during the write
operation of the Tx descriptor Tail Pointer. TDESE is set and interrupt
INT_14 triggered
b111110 when a bus transaction error occurs during the read operation
of the DMA status register.
0
0,
15:5
r
Reserved
Read as 0; should be written as 0
20.8.78
Interrupt signal
DRE signals events to the Interrupt Router module through 16 interrupt lines INT[15:0]. This register shows the
status of interrupt signalled for the events grouped to an interrupt line. It means at least one status event has
occurred within an interrupt line. The bit-fields value is purely OR-ing of the status bits corresponding to the
interrupt line.
INTSIG
Offset address:
01710H
Interrupt signal
Kernel Reset value:
0000 0800H
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3851
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
INT15 INT1
4
INT1
3
INT1
2
INT1
1
INT1
0
INT9
INT8
INT7
INT6
INT5
INT4
INT3
INT2
INT1
INT0
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
INTi (i=0-7)
i
rh
Interrupt Line i
The interrupt line INT0 to INT7 corresponds to DMEMi_STATUS.WAF,
WMF events. Each destination memory can assign its events to one of
the INT0 till INT7 lines by configuring DMEMi_CONFIG.INP.
0B DIS: No WM or WA event
1B EN: WM or WA event
INT8
8
rh
CAN input buffer status interrupt
This interrupt line corresponds to
•
CAN Input Buffer List full event (CIBL_STATUS.BF).
•
CAN CRC error (CIBL_STATUS.CRCE)
•
CAN WDT error (CIBL_STATUS.WDTE)
0B OK: CIBUF status OK
1B NOK: CIBUF status Not OK
INT9
9
rh
CAN output buffer status interrupt
This interrupt line corresponds to
•
CAN Output Buffer List full event (COBL_STATUS.BF).
•
CAN WDT error (COBL_STATUS.WDTE)
0B OK: COBUF status OK
1B NOK: COBUF status not OK
INT10
10
rh
Ethernet input buffer frame error and status interrupts
This interrupt line corresponds to
•
Input Ethernet frame error events (EIBUFi_STATUS.FE)
•
Invalid frame type (EIBUFi_STATUS.IFT)
•
AVTP Length Mismatch Error (EIBUFi_STATUS.LME)
•
Remote frame error (EIBUFi_STATUS.RFE)
•
Invalid destination ID (EIBUFi_STATUS.IDID)
•
CAN Format Error (EIBUFi_STATUS.CFE)
•
Ethernet watchdog timeout error (EIBUFi_ERROR.WDTE)
•
Rx descriptor error (EIBUFi_ERROR.RDESE)
•
Ethernet Input buffer full (EIBUFi_ERROR.BF)
0B OK: EIBUF status OK
1B NOK: EIBUF status not OK
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3852
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
INT11
11
rh
Ethernet Frame Receive Request
This interrupt line corresponds to input EIBUFi_STATUS.RXREQ
0B DIS: Request disabled
1B EN: Request enabled
INT12
12
rh
Routing Table Error Interrupt
This interrupt line corresponds to CAN Transmit Routing Table error
events (RS.IRT, NMFE).
0B OK: No error
1B NOK: Routing table error
INT13
13
rh
ME Routing Transaction Lost
This interrupt line corresponds to Move Engine error events
(ME_ERR.DBOE, IRDE, SRIBE, SPBBE).
0B OK: No error
1B NOK: Move engine error
INT14
14
rh
Ethernet output buffer error and status interrupts
This interrupt line corresponds to
•
Output Ethernet frame WDT error (EOBUFj_ERROR.WDTE)
•
Output Ethernet frame Tx descriptor error (EOBUFj_ERROR.TDESE)
•
Ethernet output buffer full (EOBUFi_STATUS.BF)
0B OK: EOBUF status OK
1B NOK: EOBUF status not OK
INT15
15
rh
Ethernet Frame Transmit Request
This interrupt line corresponds to
•
Ethernet output frame transmit request events
(EOBUFj_STATUS.TXREQ)
0B DIS: Request disabled
1B EN: Request enabled
0
31:16
r
Reserved
Read as 0; should be written with 0.
20.8.79
Interrupt line enable
The interrupt lines INT[15:0] are enabled through this SFR.
IE
Offset address:
01714H
Interrupt line enable
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
IE15
IE14
IE13
IE12
IE11
IE10
IE9
IE8
IE7
IE6
IE5
IE4
IE3
IE2
IE1
IE0
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
20  Data Routing Engine (DRE)
Reference manual
3853
v1.1
2025-06-26


Field
Bits
Type
Description
IEi (i=0-15)
i
rw
Interrupt Line i Enabled
This bit-field enables the corresponding interrupt. Upon relevant status
events, the corresponding interrupt lines are triggered only when they
are enabled by setting this bit-field to 1.
0B Interrupt line is disabled
1B Interrupt line is enabled
0
31:16
r
Reserved
Read as 0; should be written with 0.
20.8.80
Rx Ethernet descriptor list i configuration and control
RETHDLi_CTRL (i=0-5)
Offset address:
0171CH+i*8
Rx Ethernet descriptor list i configuration and control
Kernel Reset value:
0000 0180H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
PTR
STO
P
STO
PACK
IOC
0
rwh
rw
rh
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
FCS
TRIG
0
EIFID
DMACH
EIF
r
rw
rw
r
rw
rw
rw
Field
Bits
Type
Description
EIF
0
rw
Ethernet Interface
This bit-field selects between the LETH and GETH interface to which the
Rx and Tx descriptor list is mapped. One descriptor list consists of 4
descriptors
0B GETH
1B LETH
DMACH
3:1
rw
DMA channel number
This bit-field configures the Ethernet DMA CH to which the Rx descriptor
list belongs. Two Rx descriptor lists cannot be mapped to the same Rx
DMA channel. This bit-field is used by the hardware only to generate the
FWD ID and not in identifying the DMA channel mapped. Note:
Irrespective of the value configured in this bit-field, the DRE only
receives/transmits frames from/to the Ethernet DMA channel whose
Tail Pointer address is configured in the Ethernet Address Database
(EAD) at the corresponding index RETHDLi_CTRL.EIF and EIFID
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3854
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
EIFID
5:4
rw
Ethernet interface ID
This bit-field indicates the source or destination Ethernet Interface ID. x
is determined by bit EIF
Note: When EIFID > 1, EIF will be LETH by default
00B xETH0: xETH0 interface
01B xETH1: xETH1 interface
10B xETH2: xETH2 interface
EIF shall be LETH
11B xETH3: xETH3 interface
EIF shall be LETH
TRIG
7
rw
Trigger type
This bit-field configures the type of trigger from the Ethernet Descriptor
Handler. This bit-field is cleared by software only at the end, after the
configuration of the Rx DMA channel, in order for the DRE to start
preparing the Rx descriptors
0B DMA: Rx from Ethernet DMA
This is the descriptor mode where Rx descriptors are prepared by
the DRE. Ethernet frame is received from Ethernet DMA. The
Ethernet Descriptor Handler gives a Receive Poll Demand by
updating the Ethernet Rx DMA channel Tail Pointer.
1B IR: Trigger interrupt
An interrupt is triggerd to the IR. The SW shall write an Ethernet
frame into the EIBUF based on the interrupt. The software shall
clear the TRIG bit only at the end, after the configuration of the Rx
descriptor list, in order to trigger the DRE to start preparing the Rx
descriptors.
FCS
8
rw
Receive Ethernet packet has FCS field
This bit-field indicates if the Ethernet frame received by the
corresponding Rx descriptor has FCS field included or not. This bit-field
must be configured by SW during the initialization phase of DRE and
shall not be changed during run-time. This bit-field value is used by
DRE only for Ethernet-to-Ethernet forwarding use-case, to configure the
TDESCi_RD3.CPC bit-field of the corresponding Transmit descriptor. If
FCS = 0, then the corresponding TDESCi_RD3.CPC bit-field is set to b00
(Enable CRC and PAD insertion) or else TDESCi_RD3.CPC bit-field is set
to b10 (Disable CRC insertion).
IOC
26
rw
Interrupt on completion
This bit is the static configuration for Rx descriptors RDESCi_RD3G.IOC
for GETH and RDESCi_RD3L.IOC for LETH
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3855
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
STOPACK
27
rh
STOP acknowledge
This bit is set by the hardware in case the STOP bit is set by the
software. The Rx Descriptor Handler sets this bit after it finishes the
ongoing processes and goes into IDLE state. The software must then
update the RETHDLi_CTRL.PTR after STOPACK is set. The
RETHDLi_CTRL.STOP bit must be cleared by software after updating the
RETHDLi_CTRL.PTR. Clearing of STOP bit will trigger DRE to clear
STOPACK and set OWN bit of the RDESCi pointed to by the new updated
RETHDLi_CTRL.PTR and trigger a Receive Poll Demand to the Rx DMA
channel.
Note: All writes to RETHDLi_CTRL.PTR bit while the STOPACK bit is 0 are
ignored and have no effect
STOP
28
rw
STOP bit
This bit is set by the software in the event that the descriptor pointer
RETHDLi_CTRL.PTR needs to be reset. The Rx Descriptor Handler sets
the RETHDLi_CTRL.STOPACK after it finishes the ongoing processes and
goes into IDLE state. The software must then update the
RETHDLi_CTRL.PTR after STOPACK is set. The STOP bit must be cleared
by software after updating the RETHDLi_CTRL.PTR. Clearing of STOP bit
will trigger DRE to clear STOPACK and set OWN bit of the RDESCi
pointed to by the newly updated RETHDLi_CTRL.PTR and trigger a
Receive Poll Demand to the Rx DMA channel.
PTR
31:29
rwh
Descriptor pointer
This bit-field points to the index of the next Rx descriptor to be
prepared and whose OWN bit should be set by the Ethernet Descriptor
Handler.
Valid values are 0 to 3. This bit-field wraps around after 3
Note: For descriptors owned by the DRE, the OWN bit of RDESCi_WR3G
for GETH or RDESCi_WR3L for LETH is reset to 0. For descriptors owned
by the DMA, the OWN bit is set to 1
All writes to this bit-field are ignored when RETHDLi_CTRL.STOPACK is
not set to 1
0
6,
25:9
r
Reserved
Read as 0; should be written with 0.
20.8.81
Tx Ethernet descriptor list i configuration and control
TETHDLi_CTRL (i=0-5)
Offset address:
0174CH+i*10H
Tx Ethernet descriptor list i configuration and control
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
PTR
STO
P
STO
PACK
IOC
SAIC
SLOTNUM
0
rwh
rw
rh
rw
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
TRIG
0
DMACH
0
r
rw
r
rw
r
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3856
v1.1
2025-06-26


Field
Bits
Type
Description
DMACH
3:1
rw
DMA channel number
This bit-field is redundant to RETHDLi_CTRL.DMACH and indicates the
Ethernet DMA CH to which the Tx descriptor list belongs. Two Tx
descriptor lists cannot be mapped to the same Tx DMA channel. This
bit-field acts as status information only. The hardware considers that Rx
and Tx DMA channels have the same ID. For example, LETH0 has Rx
DMA channel 0 and Tx DMA channel 0 mapped to DRE. Note:
Irrespective of the value configured in this bit-field, the DRE only
receives/transmits frames from/to the Ethernet DMA channel whose
Tail Pointer address is configured in the Ethernet Address Database
(EAD) at the corresponding index RETHDLi_CTRL.EIF and EIFID
TRIG
6
rw
Trigger type
This bit-field configures the type of trigger from the Ethernet Descriptor
Handler
0B DMA: Tx to Ethernet DMA
This is the descriptor mode where Tx descriptors are prepared by
DRE. Ethernet frame is transmitted to Ethernet DMA. The Ethernet
Descriptor Handler gives a Transmit Poll Demand by updating the
Ethernet Tx DMA channel Tail Pointer.
1B IR: Trigger interrupt
An interrupt is triggerd to the IR. The SW shall read the Ethernet
frame from the EOBUF/EIBUF based on the interrupt
SLOTNUM
22:19
rw
Slot Number configuration
This bit is the static configuration for all Tx descriptors
TDESCi_RD3.SLOTNUM.
SAIC
25:23
rw
SA insertion control configuration
This bit is the static configuration for all Tx descriptors
TDESCi_RD3.SAIC.
•
2'b00: Do not include the source address
•
2'b01: Reserved
•
2'b10: Replace the source address. For reliable transmission, the
application must provide frames with source addresses
•
2'b11: Reserved
IOC
26
rw
Interrupt on completion
This bit is the static configuration for all Tx descriptors TDESCi_RD2.IOC
STOPACK
27
rh
STOP acknowledge
This bit is set by the hardware in case the STOP bit is set by the
software. The Tx Descriptor Handler sets this bit after it finishes the
ongoing processes and goes into IDLE state. The software must then
update the TETHDLi_CTRL.PTR after STOPACK is set. The
TETHDLi_CTRL.STOP bit must be cleared by software after updating the
TETHDLi_CTRL.PTR. Clearing of STOP bit will trigger DRE to clear
STOPACK and set OWN bit of the TDESCi pointed to by the new updated
TETHDLi_CTRL.PTR and trigger a Transmit Poll Demand to the Tx DMA
channel.
Note: All writes to TETHDLi_CTRL.PTR bit while the STOPACK bit is 0 are
ignored and have no effect
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3857
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
STOP
28
rw
STOP bit
This bit is set by the software in case the descriotor pointer
TETHDLi_CTRL.PTR needs to be reset. The Tx Descriptor Handler sets
the TETHDLi_CTRL.STOPACK after it finishes the ongoing processes and
goes into IDLE state. The software must then update the
TETHDLi_CTRL.PTR after STOPACK is set. The STOP bit must be cleared
by software after updating the TETHDLi_CTRL.PTR. Clearing of STOP bit
will trigger DRE to clear STOPACK and set OWN bit of the TDESCi
pointed to by the new updated TETHDLi_CTRL.PTR and trigger a
Transmit Poll Demand to the Tx DMA channel.
PTR
31:29
rwh
Descriptor pointer
This bit-field points to the index of index of the next Tx descriptor to be
prepared and whose OWN bit should be set by the Ethernet Descriptor
Handler
Valid values are 0 to 3. This bit-field wraps around after 3
Note : For descriptors owned by the DRE, the OWN bit of TDES3 is reset
to 0. For descriptors owned by the DMA, the OWN bit is set to 1
All writes to this bit-field is ignored when TETHDLi_CTRL.STOPACK is
not set to 1
0
0,
5:4,
18:7
r
Reserved
Read as 0; should be written with 0
20.8.82
Ethernet descriptor list status
EDLSTAT
Offset address:
017D8H
Ethernet descriptor list status
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
TXCNT
RXCNT
r
rwh
rwh
Field
Bits
Type
Description
RXCNT
5:0
rwh
Receive count
This bit-field is incremented by 1 after every succesful receive of
Ethernet frame. The counter wraps around to 0 by hardware upon
overflow. A write operation of any non zero value resets the counter
value to 0.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3858
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TXCNT
13:6
rwh
Transmit and forward count
This bit-field is incremented by 1 after every succesful trasmit or
forward of Ethernet frame. The counter wraps around to 0 by hardware
upon overflow. SW write has no effect
0
31:14
r
Reserved
Read as 0; Written as 0
20.8.83
Ethernet requests summary
EREQ
Offset address:
017DCH
Ethernet requests summary
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
CBI5
CBI4
CBI3
CBI2
CBI1
0
rh
rh
rh
rh
rh
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
CBI0
0
FWD
5_RE
Q
FWD
4_RE
Q
FWD
3_RE
Q
FWD
2_RE
Q
FWD
1_RE
Q
FWD
0_RE
Q
TX5_
REQ
TX4_
REQ
TX3_
REQ
TX2_
REQ
TX1_
REQ
TX0_
REQ
rh
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
rwh
rwh
Field
Bits
Type
Description
TXi_REQ
(i=0-5)
i
rwh
Tx request
This bit-field is set by hardware whenever there is an ACF Ethernet
frame to be transmitted in the EOBUF. It is cleared by hardware after
the Ethernet frame is sucessfully transmitted and there is no error
Write-back format of the descriptor. In the case of an interrupt (INT_15),
this bit is cleared by the hardware after the frame is read from EOBUF
by the software. In the case of error, this bit is cleared by software after
reading the frame from the buffer. If there is a buffer full condition, this
would be cleared by hardware together with the EOBUFj_STATUS.BF
flag. Software write with 1 clears this flag. Software write with 0 has no
effect
FWDi_REQ
(i=0-5)
i+6
rwh
Forward request
This bit-field is set by the Forwarding engine whenever there is an
Ethernet frame to be forwarded in the EIBUF. When there is a matching
filter element, the Forwarding engine sets the EREQ.FWDi_REQ of the
corresponding Tx descriptor list FT_FEj_FRULE.DSEL. It is cleared by
the Descriptor Handler after the Ethernet frame is sucessfully
forwarded and there is no error Write-back format of the descriptor. In
case of error, this bit is cleared by software after reading the frame from
the buffer. Software write with 1 clears this flag. Software write with 0
has no effect
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3859
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
CBI0
15:13
rh
Current buffer index 0
Indicates the buffer index of EIBUF for which the Tx descriptors of Tx
descriptor list 0 are being prepared in case of forwarding
CBI1
19:17
rh
Current buffer index 1
Indicates the buffer index of EIBUF for which the Tx descriptors of Tx
descriptor list 1 are being prepared in case of forwarding
CBI2
22:20
rh
Current buffer index 2
Indicates the buffer index of EIBUF for which the Tx descriptors of Tx
descriptor list 2 are being prepared in case of forwarding
CBI3
25:23
rh
Current buffer index 3
Indicates the buffer index of EIBUF for which the Tx descriptors of Tx
descriptor list 3 are being prepared in case of forwarding
CBI4
28:26
rh
Current buffer index 4
Indicates the buffer index of EIBUF for which the Tx descriptors of Tx
descriptor list 4 are being prepared in case of forwarding
CBI5
31:29
rh
Current buffer index 5
Indicates the buffer index of EIBUF for which the Tx descriptors of Tx
descriptor list 5 are being prepared in case of forwarding
0
12,
16
r
Reserved
Read as 0; Written as 0
20.8.84
Forwarding table configuration
FTCFG
Offset address:
017E4H
Forwarding table configuration
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
FID
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
FID
NRULES
rh
rw
Field
Bits
Type
Description
NRULES
7:0
rw
Number of forwarding rules
This bit-field configures the number of forwarding rules contained in
the Forwarding Table. Valid values are from 0 to 128
0 - Forwarding Table is disabled
1 to 128 - Number of forwarding rules in the Forwarding Table
>128 - Invalid configuration
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3860
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FID
30:8
rh
Forwarding ID
Forwarding ID generated by the forwarding engine
1.
GETH FID : EIF | DMACH | FRPLI | L3L4FM | MADRM
•
FRPLI : Bits [7:0] of RDESCi_WR1G[31:0]
•
L3L4FM : RDESCi_WR2G[31:29]
•
MADRM : RDESCi_WR2G[26:19]
2.
LETH FID : EIF | DMACH | FRPLI | xxxx| MADRM
•
FRPLI : Bits [31:24] of RDESCi_WR2L[31:16]
•
MADRM : RDESCi_WR2L[26:19]
0
31
r
Reserved
Read as 0; Write with 0
20.8.85
DRE CAN watchdog configuration
The DRE Watchdog timer register to monitor CAN timeout.
CWDCFG
Offset address:
017ECH
DRE CAN watchdog configuration
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
CTO
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
WTO
E
EN
r
rw
rw
Field
Bits
Type
Description
EN
0
rw
Enable CAN watchdog
This bit-field enables the CAN watchdog timer
0B DIS: CAN watchdog disabled
1B EN: CAN watchdog enabled
WTOE
1
rw
CAN watchdog timeout error
This bit field enables / disables the generation of interrupt when there
is a timeout.
0B DIS: Timeout interrupt disabled
1B EN: Timeout interrupt enabled
CTO
31:16
rw
CAN timeout value
This bit-field configures the timeout prescaler of the fSRI clock. This bit-
field can only be written when the watchdog timer is disabled
0
15:2
r
Reserved
Read as 0; should be written as 0
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3861
v1.1
2025-06-26


20.8.86
DRE Ethernet watchdog configuration
The DRE Watchdog timer register to monitor Ethernet timeout.
EWDCFG
Offset address:
017F4H
DRE Ethernet watchdog configuration
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
ETO
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
WTO
E
EN
r
rw
rw
Field
Bits
Type
Description
EN
0
rw
Enable Ethernet watchdog
This bit-field enables the Ethernet watchdog timer
0B DIS: Ethernet watchdog disabled
1B EN: Ethernet watchdog enabled
WTOE
1
rw
Ethernet watchdog timeout error
This bit field enables / disables the generation of interrupt when there
is a timeout.
0B DIS: Timeout interrupt disabled
1B EN: Timeout interrupt enabled
ETO
31:16
rw
Ethernet timeout value
This bit-field configures the timeout prescaler of the fSRI clock. This bit-
field can only be written when the watchdog timer is disabled.
0
15:2
r
Reserved
Read as 0; should be written as 0
20.8.87
Ethernet address database configuration
EADCFG
Offset address:
017F8H
Ethernet address database configuration
Kernel Reset value:
3834 0000H
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
LOV
GOV
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
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3862
v1.1
2025-06-26


Field
Bits
Type
Description
GOV
23:16
rw
GETH offset value
This bit-field configures the offset of the GETH DMA_CHj_Status (j=0-7)
from the GETH DMA_CHj_RxDesc_Tail_LPointer (i=0-7) register
LOV
31:24
rw
LETH offset value
This bit-field configures the offset of the LETH DMA_CHy_Status (y=0-7)
from the LETH DMA_CHy_RxDesc_Tail_Pointer (y=0-7) register
0
15:0
r
Reserved
Read as 0; Written as 0
20.8.88
DMA i resource partition
DMAi_RP (i=0-5)
Offset address:
017FCH+i*4
DMA i resource partition
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
RPI
r
rw
Field
Bits
Type
Description
RPI
2:0
rw
Resource partition index
This bit-field indicates the Resource Partition allocated to the Rx and Tx
DMA of Ethernet MAC.
0
31:3
r
Reserved
Read as 0; should be written as 0
20.8.89
CAN Input buffer timeout status
CITO
Offset address:
01818H
CAN Input buffer timeout status
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
TOU
T19
TOU
T18
TOU
T17
TOU
T16
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
TOUT
15
TOU
T14
TOU
T13
TOU
T12
TOU
T11
TOU
T10
TOU
T9
TOU
T8
TOU
T7
TOU
T6
TOU
T5
TOU
T4
TOU
T3
TOU
T2
TOU
T1
TOU
T0
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
20  Data Routing Engine (DRE)
Reference manual
3863
v1.1
2025-06-26


Field
Bits
Type
Description
TOUTj (j=0-19) j
rwh
Timeout error
When set, the corresponding CIBUF has a timeout error. The software
shall clear this bit by writing 1. Writing zero has no effect. The software
can also clear the BPR if required. But if the software does not clear the
BPR bit, the CAN frame in the CIBUF is processed again by the ACF
engine after this timeout bit is cleared by software
0
31:20
r
Reserved
Read 0; write 0
20.8.90
CAN Output buffer timeout status 0
COTO0
Offset address:
0181CH
CAN Output buffer timeout status 0
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
TOUT
31
TOU
T30
TOU
T29
TOU
T28
TOU
T27
TOU
T26
TOU
T25
TOU
T24
TOU
T23
TOU
T22
TOU
T21
TOU
T20
TOU
T19
TOU
T18
TOU
T17
TOU
T16
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
TOUT
15
TOU
T14
TOU
T13
TOU
T12
TOU
T11
TOU
T10
TOU
T9
TOU
T8
TOU
T7
TOU
T6
TOU
T5
TOU
T4
TOU
T3
TOU
T2
TOU
T1
TOU
T0
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
TOUTj (j=0-31) j
rwh
Timeout error
When set, the corresponding COBUF has a timeout error. The software
shall clear this bit by writing 1. Writing zero has no effect. The software
can also clear the BPR if required. But if the software does not clear the
BPR bit, the CAN frame in the CIBUF is processed again by the ACF
engine after this timeout bit is cleared by software
20.8.91
CAN Output buffer timeout status 1
COTO1
Offset address:
01820H
CAN Output buffer timeout status 1
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
TOUT
63
TOU
T62
TOU
T61
TOU
T60
TOU
T59
TOU
T58
TOU
T57
TOU
T56
TOU
T55
TOU
T54
TOU
T53
TOU
T52
TOU
T51
TOU
T50
TOU
T49
TOU
T48
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
TOUT
47
TOU
T46
TOU
T45
TOU
T44
TOU
T43
TOU
T42
TOU
T41
TOU
T40
TOU
T39
TOU
T38
TOU
T37
TOU
T36
TOU
T35
TOU
T34
TOU
T33
TOU
T32
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
20  Data Routing Engine (DRE)
Reference manual
3864
v1.1
2025-06-26


Field
Bits
Type
Description
TOUTj
(j=32-63)
j-32
rwh
Timeout error
When set, the corresponding COBUF has a timeout error. The software
shall clear this bit by writing 1. Writing zero has no effect. The software
can also clear the BPR if required. But if the software does not clear the
BPR bit, the CAN frame in the CIBUF is processed again by the ACF
engine after this timeout bit is cleared by software
20.8.92
CAN Address Database RAM interface
20.8.92.1
RAM CAN address database CRE start address
The CAN address database elements are stored in DRE RAM starting from DRE RAM base address.
The CAN Address Database is stored in DRE RAM starting from DRE RAM base address. This RAM location
configured by user with start address of the CAN CRE RAM allocation.
CAD_CANi_CRESA (i=0-19)
Offset address:
00000H + i*8
RAM CAN address database CRE start address
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
ADR
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
ADR
rw
Field
Bits
Type
Description
ADR
31:0
rw
Address
This bit-field is configured by user with start address of the CANi
interface CRE RAM allocation.
20.8.93
CAN Input Buffer List RAM interface
20.8.93.1
RAM CIBUF routing header
The CAN Input Buffer List is stored in DRE RAM starting from DRE RAM base address + 0xA0. The number of
buffers in the list is 20.
CIBUFj_RHEAD (j=0-19)
Offset address:
000A0H+j*50H
RAM CIBUF routing header
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
ETHDID
SCBID
0
r
rh
rh
r
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3865
v1.1
2025-06-26


Field
Bits
Type
Description
SCBID
7:2
rh
Source CAN Bus ID
This bit-field indicates the source CAN interface ID from which the CAN
frame is received. Refer to Routing destination ID table
ETHDID
13:8
rh
Ethernet Destination ID
This bit-field indicates the destination ID of Ethernet frame. Valid IDs
are from 0x18 till 0x1D. The destination is disabled when ID value is 0x0.
Refer to the Routing destination ID table
0
1:0,
31:14
r
Reserved
Read as 0; should be written with 0
20.8.93.2
RAM CIBUF CRC computed by CRE
The CAN Input Buffer List is stored in DRE RAM starting from DRE RAM base address + 0xA0. The number of
buffers in the list is 20.
CIBUFj_CRC (j=0-19)
Offset address:
000A4H+j*50H
RAM CIBUF CRC computed by CRE
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
20.8.93.3
RAM CIBUF register 0
The CAN Input Buffer List is stored in DRE RAM starting from DRE RAM base address + 0xA0. The number of
buffers in the list is 20.
CIBUFj_R0 (j=0-19)
Offset address:
000A8H+j*50H
RAM CIBUF register 0
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
ID
rh
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3866
v1.1
2025-06-26


Field
Bits
Type
Description
ID
28:0
rh
CAN Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier is stored into ID[28:18].
RTR
29
rh
Remote Transmission Request
This bit-field indicates that the CAN frame is a remote frame. There are
no remote frames in CAN FD format. In case of CAN FD frame (FDF = 1),
this bit-field is ignored.
0B Received frame is a data frame
1B Received frame is a remote frame
XTD
30
rh
Extended Identifier
Indicates whether the CAN frame has a standard or extended identifier.
0B 11-bit standard identifier
1B 29-bit extended identifier
ESI
31
rh
Error State Indicator
0B Transmitting node is error active
1B Transmitting node is error passive
20.8.93.4
RAM CIBUF register 1
The CAN Input Buffer List is stored in DRE RAM starting from DRE RAM base address + 0xA0. The number of
buffers in the list is 20.
CIBUFj_R1 (j=0-19)
Offset address:
000ACH+j*50H
RAM CIBUF register 1
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
FDF
BRS
DLC
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
r
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3867
v1.1
2025-06-26


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
0
15:0,
31:22
r
Reserved
Read as 0; should be written with 0.
20.8.93.5
RAM CIBUF data byte m
This register indicates value of CAN payload data byte m.
CIBUFj_DBm (j=0-19;m=0-63)
Offset address:
000B0H+j*50H+m
RAM CIBUF data byte m
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
20.8.94
CAN Output Buffer List RAM interface
20.8.94.1
RAM uni-cast routing header
The CAN Output Buffer List is stored in DRE RAM starting from DRE RAM base address + 0x6E0. The number of
buffers in the list is 64.
COBUFj_UCRH (j=0-63)
Offset address:
006E0H+j*50H
RAM uni-cast routing header
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3868
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
DID
SID
MODE
r
rh
rh
rh
Field
Bits
Type
Description
MODE
1:0
rh
Routing Rule Mode
It defines the type of the routing rule
0 - Uni-cast rule
1 - Multi-cast rule
other - Reserved, considered as Uni-cast rule
SID
7:2
rh
Source ID
This bit-field indicates the source from which the CAN frame is received.
The source module are referenced using a unique ID as given in the
Routing destination ID table.
•
EIBUF0 : 0x18
•
EIBUF1 : 0x19
•
EIBUF2 : 0x1A
•
EIBUF3 : 0x1B
•
EIBUF4 : 0x1C
•
EIBUF5 : 0x1D
DID
13:8
rh
Destination ID
This bit-field indicates the destination CAN node to which the received
CAN frame has to be transferred. The destination CAN node are
referenced using a unique ID as given in the Routing destination ID
table.
0
31:14
r
Reserved
Read as 0; should be written with 0.
20.8.94.2
RAM multi-cast routing header
The CAN Output Buffer List is stored in DRE RAM starting from DRE RAM base address + 0x6E0. The number of
buffers in the list is 64.
COBUFj_MCRH (j=0-63)
Offset address:
006E0H+j*50H
RAM multi-cast routing header
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
DID1
DID0
SID
MODE
rh
rh
rh
rh
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3869
v1.1
2025-06-26


Field
Bits
Type
Description
MODE
1:0
rh
Routing Rule Mode
It defines the type of the routing rule
0 - Uni-cast rule
1 - Multi-cast rule
other - Reserved, considered as Uni-cast rule
SID
7:2
rh
Source ID
This bit-field indicates the source from which the CAN frame is received.
The source module are referenced using a unique ID as given in the
Routing destination ID table.
•
EIBUF0 : 0x18
•
EIBUF1 : 0x19
•
EIBUF2 : 0x1A
•
EIBUF3 : 0x1B
•
EIBUF4 : 0x1C
•
EIBUF5 : 0x1D
DID0
13:8
rh
Destination ID 1
This bit-field indicates the 1st destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID1
19:14
rh
Destination ID 2
This bit-field indicates the 2nd destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID2
25:20
rh
Destination ID 3
This bit-field indicates the 3rd destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID3
31:26
rh
Destination ID 4
This bit-field indicates the 4th destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
20.8.94.3
RAM COBUF CRC computed by DRE
The CAN Output Buffer List is stored in DRE RAM starting from DRE RAM base address + 0x6E0. The number of
buffers in the list is 64.
COBUFj_CRC (j=0-63)
Offset address:
006E4H+j*50H
RAM COBUF CRC computed by DRE
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3870
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
CRC computed by DRE
Note: In case of Multi-cast, an intermediate CRC calculated over R0, R1
(except ANMF, RXTS, FIDX and BRS which are considered as zero), safety
critical CAN payload (without DID) is stored
0
31:16
r
Reserved
20.8.94.4
RAM COBUF register 0
The CAN Output Buffer List is stored in DRE RAM starting from DRE RAM base address + 0x6E0. The number of
buffers in the list is 64.
COBUFj_R0 (j=0-63)
Offset address:
006E8H+j*50H
RAM COBUF register 0
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
ID
rh
Field
Bits
Type
Description
ID
28:0
rh
CAN Identifier
Standard or extended identifier depending on bit XTD. A standard
identifier is stored into ID[28:18].
RTR
29
rh
Remote Transmission Request
This bit-field indicates that the CAN frame is a remote frame. There are
no remote frames in CAN FD format. In case of CAN FD frame (FDF = 1),
this bit-field is ignored.
0B Received frame is a data frame
1B Received frame is a remote frame
XTD
30
rh
Extended Identifier
Indicates whether the CAN frame has a standard or extended identifier.
0B 11-bit standard identifier
1B 29-bit extended identifier
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3871
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ESI
31
rh
Error State Indicator
0B Transmitting node is error active
1B Transmitting node is error passive
20.8.94.5
RAM COBUF register 1
The CAN Output Buffer List is stored in DRE RAM starting from DRE RAM base address + 0x6E0. The number of
buffers in the list is 64.
COBUFj_R1 (j=0-63)
Offset address:
006ECH+j*50H
RAM COBUF register 1
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
FDF
BRS
DLC
r
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
r
Field
Bits
Type
Description
DLC
19:16
rh
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
rh
Bit Rate Switch
0B Frame received without bit rate switching
1B Frame received with bit rate switching
FDF
21
rh
Frame Data Format
0B Standard frame format
1B CAN FD frame format (new DLC-coding and CRC)
0
15:0,
31:22
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3872
v1.1
2025-06-26


20.8.94.6
RAM COBUF data byte m
This register indicates value of CAN payload data byte m.
COBUFj_DB (j=0-63;m=0-63)
Offset address:
006F0H+j*50H+m
RAM COBUF data byte m
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
rh
Field
Bits
Type
Description
DB
7:0
rh
Data Byte m
20.8.95
CAN Transmit Routing Table RAM interface
20.8.95.1
RAM routing table CAN ID filter configuration
The CAN Transmit Routing Table i elements are stored in DRE RAM starting from DRE RAM base address +
0x1AE0 + i*RTi_CONFIG.NRULES. The number of routing elements within each routing table is configured in
RTi_CONFIG.NRULES.
RT_REj_CIDFC (j=0-127)
Offset address:
01AE0H+j*8
RAM routing table CAN ID filter configuration
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
MODE
CANID2
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
IDS
CANID1
rw
rw
Field
Bits
Type
Description
CANID1
12:0
rw
CAN ID 1
The first CAN identifier used for filter operation. The function of CAN ID
1 depends on the configured "MODE" bit-field. For standard CAN IDs
(RREQ_CID.XTD = 0b) only bits 10 to 0 are considered. For extended CAN
IDs (RREQ_CID.XTD = 1b) all 13 bits are considered.
IDS
15:13
rw
ID Shift
This bit-field is used only when RREQ_CID.XTD = 1b. The extended ID is
shifted left by this bit-field value and the most significant 13 bits of the
shifted CAN ID are used for filtering operation.
CANID2
28:16
rw
CAN ID 2
The second CAN identifier used for filter operation. The function of CAN
ID 2 depends on the configured "MODE" bit-field. For standard CAN IDs
(RREQ_CID.XTD = 0b) only bits 10 to 0 are considered. For extended CAN
IDs (RREQ_CID.XTD = 1b) all 13 bits are considered.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3873
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MODE
30:29
rw
Filter Mode
This bit-field configures the filter mode.
00B Classical ID Filter
"CAN ID 1" is used as the filter ID and "CAN ID 2" is used as mask
01B Dual ID Filter
"CANID1" or "CANID2" is used as the filter ID. No masking is done.
10B Range ID Filter
The range of IDs from "CANID1" till "CANID2" are used as filter
IDs. It has to be ensured by the user that "CANID1" < "CANID2"
11B Reserved
Reserved; not to be used
0
31
r
Reserved
Read as 0; should be written with 0.
20.8.95.2
RAM routing table uni-cast routing
RT_REj_UCR (j=0-127)
Offset address:
01AE4H+j*8
RAM routing table uni-cast routing
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
0
MODE
r
rw
r
rw
Field
Bits
Type
Description
MODE
1:0
rw
Routing Rule Mode
It defines the type of the routing rule
0 - Uni-cast rule
1 - Multi-cast rule
other - Reserved, considered as Uni-cast rule
DID
13:8
rw
Destination ID
This bit-field indicates the destination CAN node to which the received
CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
0
7:2,
31:14
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3874
v1.1
2025-06-26


20.8.95.3
RAM routing table multi-cast routing
RT_REj_MCR (j=0-127)
Offset address:
01AE4H+j*8
RAM routing table multi-cast routing
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
0
MODE
rw
rw
r
rw
Field
Bits
Type
Description
MODE
1:0
rw
Routing Rule Mode
It defines the type of the routing rule
0 - Uni-cast rule
1 - Multi-cast rule
other - Reserved, considered as Uni-cast rule
DID0
13:8
rw
Destination ID 1
This bit-field indicates the 1st destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID1
19:14
rw
Destination ID 2
This bit-field indicates the 2nd destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID2
25:20
rw
Destination ID 3
This bit-field indicates the 3rd destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
DID3
31:26
rw
Destination ID 4
This bit-field indicates the 4th destination CAN node to which the
received CAN frame has to be transferred. The destination CAN node is
referenced using a unique ID as given in the Routing destination ID
table.
0
7:2
r
Reserved
Read as 0; should be written with 0.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3875
v1.1
2025-06-26


20.8.96
Ethernet Address Database RAM interface
20.8.96.1
RAM LETH Tx DMA channel address
The Ethernet address database elements are stored in DRE RAM starting from DRE RAM base address + 0x2AE0.
EAD_LETHj_TXDMA (j=0-3)
Offset address:
02AE0H+j*8
RAM LETH Tx DMA channel address
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
ADR
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
ADR
rw
Field
Bits
Type
Description
ADR
31:0
rw
Address
This bit-field is configured by user with address of the LETH DMA
channel Tail Pointer.
20.8.96.2
RAM LETH Rx DMA channel address
The Ethernet address database elements are stored in DRE RAM starting from DRE RAM base address + 0x2AE0.
EAD_LETHj_RXDMA (j=0-3)
Offset address:
02AE4H+j*8
RAM LETH Rx DMA channel address
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
ADR
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
ADR
rw
Field
Bits
Type
Description
ADR
31:0
rw
Address
This bit-field is configured by user with address of the LETH DMA
channel Tail Pointer.
20.8.96.3
RAM GETH Tx DMA channel address
The Ethernet address database elements are stored in DRE RAM starting from DRE RAM base address + 0x2AE0
EAD_GETHj_TXDMA (j=0-1)
Offset address:
02B00H+j*8
RAM GETH Tx DMA channel address
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3876
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
ADR
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
ADR
rw
Field
Bits
Type
Description
ADR
31:0
rw
Address
This bit-field is configured by user with address of the GETH DMA
channel Tail Pointer.
20.8.96.4
RAM GETH Rx DMA channel address
The Ethernet address database elements are stored in DRE RAM starting from DRE RAM base address + 0x2AE0
EAD_GETHj_RXDMA (j=0-1)
Offset address:
02B04H+j*8
RAM GETH Rx DMA channel address
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
ADR
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
ADR
rw
Field
Bits
Type
Description
ADR
31:0
rw
Address
This bit-field is configured by user with address of the GETH DMA
channel Tail Pointer.
20.8.97
Ethernet descriptors RAM interface
20.8.97.1
RAM TDESC word 0 read format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_RD0 (i=0-3)
Offset address:
03140H+i*10H
RAM TDESC word 0 read format
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3877
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
BUF1AP
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
BUF1AP
rwh
Field
Bits
Type
Description
BUF1AP
31:0
rwh
Ethernet Buffer Address Pointer 1
These bits indicate the physical address of the frame in EOBUF or
EIBUF. Bit FD shall be set.
20.8.97.2
RAM TDESC word 0 Write-back format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_WR0 (i=0-3)
Offset address:
03140H+i*10H
RAM TDESC word 0 Write-back format
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
r
Field
Bits
Type
Description
0
31:0
r
Reserved
Read as 0; should be written as 0
20.8.97.3
RAM TDESC word 1 read format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_RD1 (i=0-3)
Offset address:
03144H+i*10H
RAM TDESC word 1 read format
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
BUF2AP
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
BUF2AP
rwh
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3878
v1.1
2025-06-26


Field
Bits
Type
Description
BUF2AP
31:0
rwh
Ethernet Buffer Address Pointer 2
Shall be 0 as there is no segmentation of frame
20.8.97.4
RAM TDESC word 1 Write-back format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_WR1 (i=0-3)
Offset address:
03144H+i*10H
RAM TDESC word 1 Write-back format
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
r
Field
Bits
Type
Description
0
31:0
r
Reserved
Read as 0; should be written as 0
20.8.97.5
RAM TDESC word 2 read format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_RD2 (i=0-3)
Offset address:
03148H+i*10H
RAM TDESC word 2 read format
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
IOC
0
S2L
rwh
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
S1L
r
rwh
Field
Bits
Type
Description
S1L
13:0
rwh
Size of buffer 1
Indicates the size of the frame EOBUF/EIBUF (in bytes)
S2L
29:16
rwh
Size of buffer 2
Shall be 0 as there is no second buffer in DRE
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3879
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
IOC
31
rwh
Interrupt on Completion
This bit sets the TI bit in the DMA_CH(#i)_Status register after the
present packet has been transmitted.
0
15:14,
30
r
Reserved
Read as 0; should be written as 0
20.8.97.6
RAM TDESC word 2 Write-back format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_WR2 (i=0-3)
Offset address:
03148H+i*10H
RAM TDESC word 2 Write-back format
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
r
Field
Bits
Type
Description
0
31:0
r
Reserved
Read as 0; should be written as 0
20.8.97.7
RAM TDESC word 3 read format
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_RD3 (i=0-3)
Offset address:
0314CH+i*10H
RAM TDESC word 3 read format
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
OWN
CTXT
FD
LD
CPC
SAIC
SLOTNUM
0
CIC
rwh
rwh
rwh
rwh
rwh
rwh
rwh
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
FL
r
rwh
Field
Bits
Type
Description
FL
14:0
rwh
Packet Length
Length of the packet to be transmitted in bytes. This equals the total
length of the packet to be transmitted: Header length + Payload length
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3880
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
CIC
17:16
rwh
Checksum Insertion control
Checksum insertion is disabled. Shall be set to 0
SLOTNUM
22:19
rwh
Slot Number
Holds the static value configured in TETHDLi_CTRL.SLOTNUM. These
bits indicate the slot interval in which the data should be fetched from
the corresponding buffers addressed by D0 or D1. When the Transmit
descriptor is fetched, the DMA compares the slot number value in this
field with the slot interval maintained in the RSN field
DMA_CH(#i)_Slot_Function_Control_Status. It fetches the data from
the buffers only if a value matches. These bits are valid only for the AV
channels.
SAIC
25:23
rwh
SA insertion control
Holds the static value configured in TETHDLi_CTRL.SAIC
These bits request the MAC to add or replace the Source Address field in
the Ethernet packet with the value given in the MAC Address 0 register.
If the Source Address field is modified in a packet, the MAC
automatically recalculates and replaces the CRC bytes. Bit 25 specifies
the MAC Address Register (1 or 0) value that is used for Source Address
insertion or replacement.
The following list describes the values of bits [24:23]:
•
2'b00: Do not include the source address
•
2'b01: Reserved
•
2'b10: Replace the source address. For reliable transmission, the
application must provide frames with source addresses
•
2'b11: Reserved
CPC
27:26
rwh
CRC Pad Control
This field controls the CRC and Pad Insertion for TX packet. This field is
valid only when the first descriptor bit (TDESCi_RD3[29]) is set
•
2'b10 Disable CRC Insertion: The MAC does not append the CRC at
the end of the transmitted packet. The application should ensure
that the padding and CRC bytes are present in the packet being
transferred from the Transmit Buffer
•
2'b00 CRC and Pad Insertion: The MAC appends the cyclic
redundancy check (CRC) at the end of the transmitted packet of
length greater than or equal to 60 bytes. The MAC automatically
adds padding and CRC to a frame shorter than 60 bytes
In case of Ethernet frames to be forwarded from EIBUF, this bit is
configured based on the RETHDLi_CTRL.FCS bit. If FCS = 0, then the
corresponding TDESCi_RD3.CPC bit-field is set to b00 (Enable CRC and
PAD insertion) or else TDESCi_RD3.CPC bit-field is set to b10 (Disable
CRC insertion)
This field shall be set to 0 in case the Ethernet frame is in EOBUF
LD
28
rwh
Last Descriptor
When this bit is set, it indicates that the buffer contains last segment of
the packet
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3881
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
FD
29
rwh
First Descriptor
When this bit is set, it indicates that the buffer contains first segment of
the packet.
CTXT
30
rwh
Context Type
Shall be set to 0 for Normal descriptor
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
0
15,
18
r
Reserved
Read as 0; should be written as 0
20.8.97.8
RAM TDESC word 3 Write-back format for GETH
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_WR3G (i=0-3)
Offset address:
0314CH+i*10H
RAM TDESC word 3 Write-back format for GETH
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
OWN
CTXT
FD
LD
DER
R
0
rwh
rwh
rwh
rwh
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
r
Field
Bits
Type
Description
DERR
27
rwh
Descriptor Error
When this bit is set, it indicates that the descriptor content is incorrect.
LD
28
rwh
Last Descriptor
When this bit is set, it indicates that the buffer contains last segment of
the packet
FD
29
rwh
First Descriptor
When this bit is set, it indicates that the buffer contains first segment of
the packet.
CTXT
30
rwh
Context Type
Shall be set to 0 for Normal descriptor
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3882
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
0
26:0
r
Reserved
Read as 0; should be written as 0
20.8.97.9
RAM TDESC word 3 Write-back format for LETH
The Ethernet Transmit descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3140 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
TDESCi_WR3L (i=0-3)
Offset address:
0314CH+i*10H
RAM TDESC word 3 Write-back format for LETH
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
OWN
CTXT
FD
LD
0
DE
0
TTSS
EUE
rwh
rwh
rwh
rwh
r
rwh
r
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
ES
JT
FF
PCE
LOC
NC
LC
EC
CC
ED
UF
DB
IHE
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
IHE
0
rwh
IP Header Error
When IP Header Error is set, this bit indicates that the Checksum
Offload engine detected an IP header error. This bit is valid only when
Tx Checksum Offload is enabled. Otherwise, it is reserved. If COE
detects an IP header error, it still inserts an IPv4 header checksum if the
Ethernet Type field indicates an IPv4 payload. In full duplex mode,
when EST/Qbv is enabled and this bit is set, it indicates the frame drop
status due to Frame Size error or Schedule Error.
DB
1
rwh
Deferred Bit
This bit indicates that the MAC deferred before transmitting because of
presence of carrier. This bit is valid only in the half-duplex mode.
UF
2
rwh
Underflow Error
This bit indicates that the MAC aborted the packet because the data
arrived late from the system memory. The underflow error can occur
because of either of the following conditions:
•
The DMA encountered an empty Transmit Buffer while transmitting
the packet
•
The application filled the MTL Tx FIFO slower than the MAC
transmit rate
The transmission process enters the suspended state and sets the
underflow bit corresponding to a queue in the MTL_Interrupt_Status
register.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3883
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
ED
3
rwh
Excessive Deferral
This bit indicates that the transmission ended because of excessive
deferral of over 24,288 bit times (155,680 bits times in 1000 Mbps mode
or Jumbo Packet enabled mode) if DC bit is set in the
MAC_Configuration register. When TBS is enabled in full duplex mode
and this bit is set, it indicates that the frame has been dropped after the
expiry time has reached.
CC
7:4
rwh
Collision Count
This 4-bit counter value indicates the number of collisions occurred
before the packet was transmitted. The count is not valid when the EC
bit is set.
EC
8
rwh
Excessive Collision
This bit indicates that the transmission was aborted after 16 successive
collisions while attempting to transmit the current packet. If the DR bit
is set in the MAC_Configuration register, this bit is set after first collision
and the transmission of the packet is aborted.
LC
9
rwh
Late Collision
This bit indicates that packet transmission was aborted because a
collision occurred after the collision window (64 byte times including
Preamble in MII mode and 512 byte times including Preamble and
Carrier Extension in GMII mode). This bit is not valid if Underflow Error
is set.
NC
10
rwh
No Carrier
This bit indicates that the carrier sense signal form the PHY was not
asserted during transmission.
LOC
11
rwh
Loss of Carrier
This bit indicates that Loss of Carrier occurred during packet
transmission (that is, the gmii_crs_i signal was inactive for one or more
transmit clock periods during packet transmission). This is valid only
for the packets transmitted without collision and when the MAC
operates in the half-duplex mode.
PCE
12
rwh
Payload Checksum Error
This bit indicates that the Checksum Offload engine had a failure and
did not insert any checksum into the encapsulated TCP, UDP, or ICMP
payload. This failure can be either because of insufficient bytes, as
indicated by the Payload Length field of the IP Header or the MTL
starting to forward the packet to the MAC transmitter in Store-and-
Forward mode without the checksum having been calculated yet. This
second error condition only occurs when the Transmit FIFO depth is
less than the length of the Ethernet packet being transmitted to avoid
deadlock, the MTL starts forwarding the packet when the FIFO is full,
even in the store-and-forward mode. This error can also occur when
Bus Error is detected during packet transfer. When the Full Checksum
Offload engine is not enabled, this bit is reserved.
FF
13
rwh
Packet Flushed
This bit indicates that the DMA or MTL flushed the packet because of a
software flush command given by the CPU.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3884
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
JT
14
rwh
Jabber Timeout
This bit indicates that the MAC transmitter has experienced a jabber
time-out. This bit is set only when the JD bit of the MAC_Configuration
register is not set.
ES
15
rwh
Error Summary
This bit indicates the logical OR of the following bits:
•
TDES3[0]: IP Header Error
•
TDES3[14]: Jabber Timeout
•
TDES3[13]: Packet Flush
•
TDES3[12]: Payload Checksum Error
•
TDES3[11]: Loss of Carrier
•
TDES3[10]: No Carrier
•
TDES3[9]: Late Collision
•
TDES3[8]: Excessive Collision
•
TDES3[3]: Excessive Deferral
•
TDES3[2]: Underflow Error
This bit is also set when EUE (bit 16) is set.
EUE
16
rwh
ECC Uncorrectable Error Status
Indicates the ECC uncorrectable error in the TSO memory.
Uncorrectable error in Transmit FIFO memory is reported with (Bit 13)
FF = 1. This is because, all such packets are flushed by LETH.
TTSS
17
rwh
Tx Timestamp Status
This status bit indicates that a timestamp has been captured for the
corresponding transmit packet. When this bit is set, TDES0 and TDES1
have timestamp values that were captured for the Transmit packet.
This field is valid only when the Last Segment control bit (TDES3 [28]) in
a descriptor is set. This bit is valid only when IEEE 1588 timestamping
feature is enabled; otherwise, it is reserved.
DE
23
rwh
Descriptor Error
When this bit is set, it indicates that the descriptor content is incorrect.
The DMA sets this bit during Write-back while closing the descriptor.
LD
28
rwh
Last Descriptor
When this bit is set, it indicates that the buffer contains last segment of
the packet
FD
29
rwh
First Descriptor
When this bit is set, it indicates that the buffer contains first segment of
the packet.
CTXT
30
rwh
Context Type
Shall be set to 0 for Normal descriptor
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3885
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
22:18,
27:24
r
Reserved
Read as 0; should be written as 0
20.8.97.10
RAM RDESC word 0 read format
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_RD0 (i=0-3)
Offset address:
03180H+i*10H
RAM RDESC word 0 read format
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
BUF1AP
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
BUF1AP
rwh
Field
Bits
Type
Description
BUF1AP
31:0
rwh
Ethernet input buffer address pointer
These bits indicate the physical address EIBUF to which the input
Ethernet frame is stored.
20.8.97.11
RAM RDESC word 0 Write-back format Non Tunneled frames (also
LETH)
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR0NT (i=0-3)
Offset address:
03180H+i*10H
RAM RDESC word 0 Write-back format Non Tunneled
frames [also LETH)
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
IVT
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
OVT
rwh
Field
Bits
Type
Description
OVT
15:0
rwh
Outer VLAN Tag or External Lookup Result Data
This bit-field is not used by the DRE
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3886
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
IVT
31:16
rwh
Inner VLAN Tag or External Lookup Result Data
This bit-field is not used by the DRE
20.8.97.12
RAM RDESC word 0 Write-back format Tunneled frames
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR0T (i=0-3)
Offset address:
03180H+i*10H
RAM RDESC word 0 Write-back format Tunneled frames
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
VID
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
VID
0
OL2L3
rwh
r
rwh
Field
Bits
Type
Description
OL2L3
2:0
rwh
Outer L2 L3 Type
This bit-field is not used by the DRE
VID
31:8
rwh
VNID or VSID
This bit-field is not used by the DRE
0
7:3
r
Reserved
Read as 0; should be written as 0
20.8.97.13
RAM RDESC word 1 read format
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_RD1 (i=0-3)
Offset address:
03184H+i*10H
RAM RDESC word 1 read format
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
r
Field
Bits
Type
Description
0
31:0
r
Reserved
Read as 0; should be written as 0
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3887
v1.1
2025-06-26


20.8.97.14
RAM RDESC word 1 Write-back format GETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR1G (i=0-3)
Offset address:
03184H+i*10H
RAM RDESC word 1 Write-back format GETH
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
FRPLI
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
FRPLI
rwh
Field
Bits
Type
Description
FRPLI
31:0
rwh
RSS HASH/Flexible Recieve Parser Last Instruction
This field contains the FRP Last Instruction number where FRP result is
generated. This bit-field is used by the Forwarding engine to generate
the GETH Forward ID
20.8.97.15
RAM RDESC word 1 Write-back format LETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR1L (i=0-3)
Offset address:
03184H+i*10H
RAM RDESC word 1 Write-back format LETH
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
OPC
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
TD
TSA
PV
PFT
PMT
IPCE
IPCB
IPV6
IPV4
IPHE
PT
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
20  Data Routing Engine (DRE)
Reference manual
3888
v1.1
2025-06-26


Field
Bits
Type
Description
PT
2:0
rwh
Payload type
These bits indicate the type of payload encapsulated in the IP
datagram processed by the Receive Checksum Offload Engine (COE):
•
3'b000: Unknown type or IP/AV payload not processed
•
3'b001: UDP
•
3'b010: TCP
•
3'b011: ICMP
•
3'b110: AV Tagged Data Packet
•
3'b111: AV Tagged Control Packet
•
3'b101: AV Untagged Control Packet
•
3'b100: IGMP if IPV4 Header Present bit is set else DCB (LLDP)
Control Packet
If the COE does not process the payload of an IP datagram because
there is an IP header error or fragmented IP, it sets these bits to 3'b000.
IPHE
3
rwh
IP Header Error
When this bit is set, it indicates either of the following:
•
The 16-bit IPv4 header checksum calculated by the MAC does not
match the received checksum bytes.
•
The IP datagram version is not consistent with the Ethernet Type
value.
•
Ethernet packet does not have the expected number of IP header
bytes.
This bit is valid when either bit 5 or bit 4 is set. This bit is available when
you select the Enable Receive TCP/IP Checksum Check feature.
IPV4
4
rwh
IPV4 Header Present
This bit indicates that an IPV4 header is detected. When the SPH bit of
RDESCi_WR3 is set, the IPV4 header is available in the header buffer
area to which RDESCi_WR0 is pointing.
IPV6
5
rwh
IPV6 Header Present
This bit indicates that an IPV6 header is detected. When the Enable
Split Header Feature option is selected and the SPH bit of Control
Register of a channel is set, the IPV6 header is available in the header
buffer area to which RDES0 is pointing.
IPCB
6
rwh
IP Checksum Bypassed
This bit indicates that the checksum offload engine is bypassed. This bit
is available when you select the Enable Receive TCP/IP Checksum
Check feature.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3889
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
IPCE
7
rwh
IP Payload Error
When this bit is set, it indicates either of the following:
•
The 16-bit IP payload checksum (that is, the TCP, UDP, or
ICMP checksum) calculated by the MAC does not match the
corresponding checksum field in the received segment.
•
The TCP, UDP, or ICMP segment length does not match the payload
length value in the IP Header field.
•
The TCP, UDP, or ICMP segment length is less than minimum
allowed segment length for TCP, UDP, or ICMP.
Bit 15 (ES) of RDESCi_WR3 is not set when this bit is set.
PMT
11:8
rwh
PTP Message Type
These bits are encoded to give the type of the message received:
•
0000: No PTP message received
•
0001: SYNC (all clock types)
•
0010: Follow_Up (all clock types)
•
0011: Delay_Req (all clock types)
•
0100: Delay_Resp (all clock types)
•
0101: Pdelay_Req (in peer-to-peer transparent clock)
•
0110: Pdelay_Resp (in peer-to-peer transparent clock)
•
0111: Pdelay_Resp_Follow_Up (in peer-to-peer transparent clock)
•
1000: Announce
•
1001: Management
•
1010: Signaling
•
1011 to 1110: Reserved
•
1111: PTP packet with Reserved message type
These bits are available only when you select the Timestamp feature.
PFT
12
rwh
PTP Packet Type
This bit indicates that the PTP message is sent directly over Ethernet.
This bit is available only when you select the Timestamp feature.
Otherwise, this bit is reserved.
PV
13
rwh
PTP Version
This bit indicates that the received PTP message has the IEEE 1588
version 2 format. When this bit is reset, it indicates the IEEE 1588
version 1 format. This bit is available only when you select the
Timestamp feature. Otherwise, this bit is reserved.
TSA
14
rwh
Timestamp Available
When Timestamp is present, this bit indicates that the timestamp value
is available in a context descriptor word 2 (RDESCi_WR2) and word 1
(RDESCi_WR1). This is valid only when the Last Descriptor bit
(RDESCi_WR3 [28]) is set. The context descriptor is written in the next
descriptor just after the last normal descriptor for a packet.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3890
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
TD
15
rwh
Timestamp Dropped
This bit indicates that the timestamp was captured for this packet but it
got dropped in the MTL Rx FIFO because of overflow. This bit is
available only when you select the Timestamp feature. Otherwise, this
bit is reserved.
OPC
31:16
rwh
OAM Sub-Type Code, or MAC Control Packet opcode
•
OAM Sub-Type Code
If bits[18:16] of RDESCi_WR3 are set to 3'b111, this field contains
the OAM sub-type and code fields.
•
MAC Control Packet opcode
If bits[18:16] of RDESCi_WR3 are set to 3'b110, this field contains
the MAC Control packet opcode field.
20.8.97.16
RAM RDESC word 2 read format
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_RD2 (i=0-3)
Offset address:
03188H+i*10H
RAM RDESC word 2 read format
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
r
Field
Bits
Type
Description
0
31:0
r
Reserved
Read as 0; should be written as 0
20.8.97.17
RAM RDESC word 2 Write-back format GETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR2G (i=0-3)
Offset address:
03188H+i*10H
RAM RDESC word 2 Write-back format GETH
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3891
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
L3L4FM
L4F
M
L3F
M
MADRM
0
DAF
SAF
rwh
rwh
rwh
rwh
r
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
VF
0
0
FPS2
0
FPS1
HL
AVTD
P
AVTC
P
rwh
r
r
rwh
r
rwh
rwh
rwh
rwh
Field
Bits
Type
Description
AVTCP
0
rwh
AV Tagged Control Packet
When L34T=0b0000, this bit is set to 1 when AV Tagged Control packet is
received. When L34T is non-zero, this bit is HL[0] for packet split by the
MAC at L3 or L4 header.
Note: The DRE does not support split header feature. The DRE identifies
the frame to be AV tagged when AVTDP or AVTCP is set irrespective of
L34T value.
AVTDP
1
rwh
AV Tagged Data Packet
When L34T=0b0000, this bit is set to 1 when AV Tagged Data packet is
received. When L34T is non-zero, this bit is HL[1] for packet split by the
MAC at L3 or L4 header
Note: The DRE does not support split header feature. The DRE identifies
the frame to be AV tagged when AVTDP or AVTCP is set irrespective of
L34T value.
HL
9:2
rwh
L3/L4 Header Length
This field contains the length of the header of the packet split by the
MAC at L3 or L4 header boundary as identified by the MAC receiver. This
field is valid only when the first descriptor bit is set (FD = 1).
The header data is written to the Buffer 1 address of corresponding
descriptor. If header length is zero, it implies that the MAC did not
identify and split the header and both Buffer 1 and Buffer 2 are used for
storing the packet.
FPS1
10
rwh
Flexible Receive Parser bit 1
FPS2
12
rwh
Flexible Receive Parser bit 2
VF
15
rwh
VLAN Filter Status
When this bit is set, it indicates that the VLAN Tag of received packet
passed the VLAN filter. For a tunneled packet, only the outer Ethernet
header fields are used for filtering
SAF
16
rwh
SA Address Filter Fail
When this bit is set, it indicates that the packet failed the SA Filter in the
MAC. For a tunneled packet, only the outer Ethernet header fields are
used for filtering
DAF
17
rwh
Destination Address Filter Fail
When this bit is set, it indicates that the packet failed the DA Filter in the
MAC. For a tunneled packet, only the outer Ethernet header fields are
used for filtering.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3892
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
MADRM
26:19
rwh
MAC Address Match or Hash Value
This field contains the MAC address register number that matched the
Destination address of the received packet. This field is valid only if the
DAF bit is reset. This bit-field is used by the DRE to generate the forward
ID.
L3FM
27
rwh
Layer 3 Filter Match
When this bit is set, it indicates that the received packet matches one of
the enabled Layer 3 IP Address fields. This status is given only when one
of the following conditions is true:
•
All enabled Layer 3 fields match and all enabled Layer 4 fields are
bypassed
•
All enabled filter fields match
When more than one filter matches, this bit gives the layer 3 filter status
of filter indicated by bits[31:29].
For a tunneled packet, only the outer L3-L4 header fields are used for
filter comparison
L4FM
28
rwh
Layer 4 Filter Match
When this bit is set, it indicates that the received packet matches one of
the enabled Layer 4 Port Number fields. This status is given only when
one of the following conditions is true:
•
Layer 3 fields are not enabled and all enabled Layer 4 fields match
•
All enabled Layer 3 and Layer 4 filter fields match
When more than one filter matches, this bit gives the layer 4 filter status
of filter indicated by bits[31:29]
For a tunneled packet, only the outer L3-L4 header fields are used for
filter comparison.
L3L4FM
31:29
rwh
Layer 3 and Layer 4 Filter Number Matched
This bit-field is used by the DRE to generate the forward ID. These bits
indicate the number of the Layer 3 and Layer 4 Filter that matched the
received packet:
•
000: Filter 0
•
001: Filter 1
•
010: Filter 2
•
011: Filter 3
•
100: Filter 4
•
101: Filter 5
•
110: Filter 6
•
111: Filter 7
This field is valid only when bit 28 or bit 27 is set high. When more than
one filter matches, these bits give the number of lowest filter.
For a tunneled packet, only the outer L3-L4 header fields are used for
comparison
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3893
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
0
11,
13,
14,
18
r
Reserved
20.8.97.18
RAM RDESC word 2 Write-back format LETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
The LSB 8 bits of this RAM word also holds the FRPLI used to generate Forward ID
RDESCi_WR2L (i=0-3)
Offset address:
03188H+i*10H
RAM RDESC word 2 Write-back format LETH
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
L3L4FM
L4F
M
L3F
M
MADRM
HF
DAF
SAF
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
OTS
ITS
0
ARP
NR
HL
rwh
rwh
r
rwh
rwh
Field
Bits
Type
Description
HL
9:0
rwh
L3/L4 Header Length
This field contains the length of the header of the packet split by the
MAC at L3 or L4 header boundary as identified by the MAC receiver. This
field is valid only when the first descriptor bit is set (FD = 1).
The header data is written to the Buffer 1 address of corresponding
descriptor. If header length is zero, this field is not valid. It implies that
the MAC did not identify and split the header. This field is valid when
the Enable Split Header Feature option is selected.
ARPNR
10
rwh
ARP Reply Not Generated
When this bit is set, it indicates that the MAC did not generate the ARP
Reply for received ARP Request packet. This bit is set when the MAC is
busy transmitting ARP reply to earlier ARP request (only one ARP
request is processed at a time). This bit is reserved when the Enable
IPv4 ARP Offload option is not selected.
ITS
14
rwh
Inner VLAN Tag Filter Status
This bit is valid only when DWC_EQOS_ERVFE is enabled. This bit is
valid only for Double VLAN Tagged frames, when Double VLAN
Processing is enabled. For more information, see the Filter Status topic
of LETH.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3894
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
OTS
15
rwh
VLAN Filter Status
When set, this bit indicates that the VLAN Tag of the received packed
passed the VLAN filter. This bit is valid only when DWC_EQOS_ERVFE is
not enabled. If DWC_EQOS_ERVFE is enabled, the bit is redefined as
Outer VLAN Tag Filter Status (OTS). This bit is valid for both Single and
Double VLAN Tagged frames
SAF
16
rwh
SA Filter Fail or Packet dropped
SA Address Filter Fail
When Flexible RX Parser is disabled, and this bit is set, it indicates that
the packet failed the SA Filter in the MAC.
When Flexible RX Parser is enabled, this bit is set to indicate that the
packet is dropped (RXPD) by the parser. Note: When this bit is set, ES bit
of RDESCi_WR3 is also set.
DAF
17
rwh
DA Filter Fail or Packet parsing incomplete
Destination Address Filter Fail
When Flexible RX Parser is disabled, and this bit is set, it indicates that
the packet failed the DA Filter in the MAC.
When Flexible RX Parser is enabled, this bit is set to indicate that the
packet parsing is incomplete (RXPI) due to ECC error. Note: When this
bit is set, ES bit of RDESCi_WR3 is also set.
HF
18
rwh
Hash Filter Status
When this bit is set, it indicates that the packet passed the MAC address
hash filter. Bits[26:19] indicate the hash value. Note: This status is not
available when Flexible RX Parser is enabled.
MADRM
26:19
rwh
MAC Address Match or Hash Value
When the HF bit is reset, this field contains the MAC address register
number that matched the Destination address of the received packet.
This field is valid only if the DAF bit is reset.
When the HF bit is set, this field contains the hash value computed by
the MAC. A packet passes the hash filter when the bit corresponding to
the hash value is set in the hash filter register. Note: This status is not
available when Flexible RX Parser is enabled.
L3FM
27
rwh
Layer 3 Filter Match
When this bit is set, it indicates that the received packet matches one of
the enabled Layer 3 IP Address fields. This status is given only when one
of the following conditions is true:
•
All enabled Layer 3 fields match and all enabled Layer 4 fields are
bypassed
•
All enabled filter fields match
When more than one filter matches, this bit gives the layer 3 filter status
of filter indicated by bits[31:29]. Note: This status is not available when
Flexible RX Parser is enabled.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3895
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
L4FM
28
rwh
Layer 4 Filter Match
When this bit is set, it indicates that the received packet matches one of
the enabled Layer 4 Port Number fields. This status is given only when
one of the following conditions is true:
•
Layer 3 fields are not enabled and all enabled Layer 4 fields match
•
All enabled Layer 3 and Layer 4 filter fields match
When more than one filter matches, this bit gives the layer 4 filter status
of filter indicated by bits[31:29]. Note: This status is not available when
Flexible RX Parser is enabled.
L3L4FM
31:29
rwh
Layer 3 and Layer 4 Filter Number Matched
These bits indicate the number of the Layer 3 and Layer 4 Filter that
matched the received packet:
•
000: Filter 0
•
001: Filter 1
•
010: Filter 2
•
011: Filter 3
•
100: Filter 4
•
101: Filter 5
•
110: Filter 6
•
111: Filter 7
This field is valid only when bit 28 or bit 27 is set high. When more than
one filter matches, these bits give the number of lowest filter. Note: This
status is not available when Flexible RX Parser is enabled.
0
13:11
r
Reserved
Read as 0; should be written as 0
20.8.97.19
RAM RDESC word 3 read format GETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_RD3G (i=0-3)
Offset address:
0318CH+i*10H
RAM RDESC word 3 read format GETH
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
OWN
IOC
0
rwh
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
r
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3896
v1.1
2025-06-26


Field
Bits
Type
Description
IOC
30
rwh
Interrupt on Completion
This bit sets the TI bit in the DMA_CH(#i)_Status register after the
present packet has been transmitted.
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
0
29:0
r
Reserved
Read as 0; should be written as 0
20.8.97.20
RAM RDESC word 3 read format LETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_RD3L (i=0-3)
Offset address:
0318CH+i*10H
RAM RDESC word 3 read format LETH
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
OWN
IOC
0
BUF1
V
0
rwh
rwh
r
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
r
Field
Bits
Type
Description
BUF1V
24
rwh
Buffer 1 address valid
When this bit is set, it indicates the DMA that the EIBUF address
specified in the RDESCi_RD0.BUF1AP is valid.
IOC
30
rwh
Interrupt on Completion
This bit sets the TI bit in the DMA_CH(#i)_Status register after the
present packet has been transmitted.
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
0
23:0,
29:25
r
Reserved
Read as 0; should be written as 0
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3897
v1.1
2025-06-26


20.8.97.21
RAM RDESC word 3 Write-back format GETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR3G (i=0-3)
Offset address:
0318CH+i*10H
RAM RDESC word 3 Write-back format GETH
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
OWN
CTXT
FD
LD
CDA
0
ETM
NCP
L34T
ETLT
rwh
rwh
rwh
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
ES
FRPS
L
PL
rwh
rwh
rwh
Field
Bits
Type
Description
PL
13:0
rwh
Packet length
These bits indicate the byte length of the received packet that was
transferred to system memory. This does not include the
VLAN/Pad/CRC bytes if VLAN/Pad/CRC stripping is enabled. This field is
valid when the LD (bit[28]) is set and ES (bit[15]) is reset.
Note: Only this bit-field is checked by the DRE for the packet length. So
this value should include the complete length including the headers
FRPSL
14
rwh
Flexible Receive Parser Status LSB bit
Indicates the status of the Flexible receive parser. For details see, GETH/
LETH specification
ES
15
rwh
Error Summary
This bit indicates that the received packet has an error. The type of
error is indicated by bits [19:16].
This field is valid only when the LD bit of RDESCi_WR3 is set. When this
bit is set, INT_10 is triggered
•
Bit[0]: IP Header Error
•
Bit[14]: Jabber Timeout
•
Bit[13]: Packet Flush
•
Bit[12]: Payload Checksum Error
•
Bit[11]: Remote Fault
•
Bit[10]: Local Fault
•
Bit[2]: Underflow Error
ETLT
19:16
rwh
Error Type or L2 Type
When the 15th bit of this descriptor (ES) is set to 1, this field indicates
the Error Type. When the 15th bit of this descriptor (ES) is set to 0, this
field indicates the L2 Packet Type. Refer GETH/LETH UM for the
encoding
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3898
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
L34T
23:20
rwh
Layer3/ Layer4 packet Type
These bits indicate the type of payload encapsulated in the IP
datagram and processed by the Receive Checksum Offload Engine
ETMNCP
24
rwh
Ether Type Match or No Coagulation Packet
When L34T=0b0000, this bit is set to 1 (ETM Status) when the Type field
of the received packet matches the value programmed in the
MAC_Rx_Eth_Type_Match register. When L34T has any value other than
zero and this bit is set to 1 (NCP Status), it indicates that the DMA has
received a packet that must not be kept holding for TCP packet
coagulation. It must be forwarded to the TCP/IP stack immediately
even though it may be in sequence with respect to the previous packet.
NCP Status is valid only when the OoS function is enabled in the
MAC_RSS_Control register. For a tunneled packet, ETM refers to the
Type Match of the Inner Ethernet Header. NCP is not supported for a
tunneled packet.
CDA
27
rwh
Context Descriptor Available
The DRE does not support context descriptors
LD
28
rwh
Last Descriptor
When this bit is set, it indicates that the buffers to which this descriptor
is pointing are the last buffers of the packet.
FD
29
rwh
First Descriptor
When this bit is set, it indicates that this descriptor contains the first
buffer of the packet. If the size of the first buffer is 0, the second buffer
contains the beginning of the packet. If the size of the second buffer is
also 0, the next descriptor contains the beginning of the packet. CTXT,
FD, and LD bits together indicate Descriptor Definition Error. During
Write-back, all three bits are set to 1 {CTXT, FD, LD} = 3'b111 to indicate
Descriptor Definition Error in the Rx Descriptor. Descriptor Definition
Error for Rx Descriptor is indicated when both Buffer-1 and Buffer-2 are
all 1s.
CTXT
30
rwh
Receive Context Descriptor
When this bit is set, it indicates that the current descriptor is a context
type descriptor. The DMA writes 1'b0 to this bit for normal receive
descriptor.
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
0
26:25
r
Reserved
Read as 0; should be written as 0
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3899
v1.1
2025-06-26


20.8.97.22
RAM RDESC word 3 Write-back format LETH
The Ethernet Receive descriptor list j is stored in DRE RAM at DRE RAM base address + 0x3180 + j*0xC80
There are 4 descriptors (each of which is made up of four 32-bit words) within each descriptor list.
RDESCi_WR3L (i=0-3)
Offset address:
0318CH+i*10H
RAM RDESC word 3 Write-back format LETH
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
OWN
CTXT
FD
LD
RS2V RS1V RS0V
CE
GP
RWT
OE
RE
DE
LT
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
ES
PL
rwh
rwh
Field
Bits
Type
Description
PL
14:0
rwh
Packet length
These bits indicate the byte length of the received packet that was
transferred to system memory (including CRC). This field is valid when
the LD bit of RDESCi_WR3 is set and ES bits are reset. The packet length
also includes the two bytes appended to the Ethernet packet when IP
checksum calculation is enabled and the received packet is not a MAC
control packet. This field is valid when the LD bit of RDESCi_WR3 is set.
When the Last Descriptor and Error Summary bits are not set, this field
indicates the accumulated number of bytes that have been transferred
for the current packet.
Note: Only this bit-field is checked by the DRE for the packet length. So
this value should include the complete length including the headers
ES
15
rwh
Error Summary
When this bit is set, it indicates the logical OR of the following bits:
•
RDESCi_WR3[24]: CRC Error
•
RDESCi_WR3[19]: Dribble Error
•
RDESCi_WR3[20]: Receive Error
•
RDESCi_WR3[22]: Watchdog Timeout
•
RDESCi_WR3[21]: Overflow Error
•
RDESCi_WR3[23]: Giant Packet
•
RDESCi_WR2[17]: Destination Address Filter Fail, when Flexible RX
Parser is enabled
•
RDESCi_WR2[16]: SA Address Filter Fail, when Flexible RX Parser is
enabled
This field is valid only when the LD bit of RDESCi_WR3 is set.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3900
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
LT
18:16
rwh
Length/Type Field
This field indicates if the packet received is a length packet or a type
packet. The encoding of the 3 bits is as follows:
•
3'b000: The packet is a length packet
•
3'b001: The packet is a type packet.
•
3'b011: The packet is a ARP Request packet type
•
3'b100: The packet is a type packet with VLAN Tag
•
3'b101: The packet is a type packet with Double VLAN Tag
•
3'b110: The packet is a MAC Control packet type
•
3'b111: The packet is a OAM packet type
•
3'b010: Reserved
DE
19
rwh
Dribble Bit Error
When this bit is set, it indicates that the received packet has a non-
integer multiple of bytes (odd nibbles). This bit is valid only in the MII
Mode.
RE
20
rwh
Receive Error
When this bit is set, it indicates that the gmii_rxer_i signal is asserted
while the gmii_rxdv_i signal is asserted during packet reception. This
error also includes carrier extension error in the GMII and half-duplex
mode. Error can be of less or no extension, or error (rxd!= 0f) during
extension.
OE
21
rwh
Overflow Error
When this bit is set, it indicates that the received packet is damaged
because of buffer overflow in Rx FIFO. Note: This bit is set only when the
DMA transfers a partial packet to the application. This happens only
when the Rx FIFO is operating in the threshold mode. In the store-and-
forward mode, all partial packets are dropped completely in Rx FIFO.
NCP Status is valid only when the OoS function is enabled in the
MAC_RSS_Control register. For a tunneled packet, ETM refers to the
Type Match of the Inner Ethernet Header. NCP is not supported for a
tunneled packet.
RWT
22
rwh
Receive Watchdog Timeout
When this bit is set, it indicates that the Receive Watchdog Timer has
expired while receiving the current packet. The current packet is
truncated after watchdog timeout.
GP
23
rwh
Giant Packet
When this bit is set, it indicates that the packet length exceeds the
specified maximum Ethernet size of 1518, 1522, or 2000 bytes (9018 or
9022 bytes if jumbo packet enable is set). Note: Giant packet indicates
only the packet length. It does not cause any packet truncation.
CE
24
rwh
CRC Error
When this bit is set, it indicates that a Cyclic Redundancy Check (CRC)
Error occurred on the received packet. This field is valid only when the
LD bit of RDESCi_WR3 is set.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3901
v1.1
2025-06-26


(continued)
Field
Bits
Type
Description
RS0V
25
rwh
Receive Status RDESCi_WR0 Valid
When this bit is set, it indicates that the status in RDESCi_WR0 is valid
and it is written by the DMA. This bit is valid only when the LD bit of
RDESCi_WR3 is set.
RS1V
26
rwh
Receive Status RDESCi_WR1 Valid
When this bit is set, it indicates that the status in RDESCi_WR1 is valid
and it is written by the DMA. This bit is valid only when the LD bit of
RDESCi_WR3 is set.
RS2V
27
rwh
Receive Status RDESCi_WR2 Valid
When this bit is set, it indicates that the status in RDESCi_WR2 is valid
and it is written by the DMA. This bit is valid only when the LD bit of
RDESCi_WR3 is set.
LD
28
rwh
Last Descriptor
When this bit is set, it indicates that the buffers to which this descriptor
is pointing are the last buffers of the packet.
FD
29
rwh
First Descriptor
When this bit is set, it indicates that this descriptor contains the first
buffer of the packet. If the size of the first buffer is 0, the second buffer
contains the beginning of the packet. If the size of the second buffer is
also 0, the next descriptor contains the beginning of the packet. See the
CTXT bit description for details of using the CTXT bit and FD bit
together.
CTXT
30
rwh
Receive Context Descriptor
When this bit is set, it indicates that the current descriptor is a context
type descriptor. The DMA writes 1'b0 to this bit for normal receive
descriptor. When CTXT and FD bits are used together, {CTXT, FD}
•
00: Intermediate Descriptor
•
01: First Descriptor
•
10: Reserved
•
11: Descriptor Error (due to all 1s)
OWN
31
rwh
OWN bit
When this bit is set, it indicates that the DMA owns the descriptor. When
this bit is reset, it indicates that the DRE owns the descriptor. The DMA
clears this bit after it completes the transfer of data given in the
associated buffers.
20.8.98
Forwarding table RAM interface
20.8.98.1
RAM Forwarding rule and FID1
Consists of the forwarding rule and Filter ID.
FT_FEj_FRULE (j=0-127)
Offset address:
07640H+j*8
RAM Forwarding rule and FID1
RAMInit value:
XXXX XXXXH
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3902
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
FID1
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
FID1
DSEL
0
FMODE
rwh
rwh
r
rwh
Field
Bits
Type
Description
FMODE
1:0
rwh
Filter mode
Forwarding filter modes
00B CLASSIC: Classic filter
Filter ID 1 used as the filter and ID 2 used as Mask
01B DUAL: Dual ID filter
Filter ID1 or Filter ID2 used as filter and FWD ID should be exact
match with one of the Filter ID
10B RANGE: Range ID filter
Range of IDs between Filter ID1 and Filter ID2 are used as Filter
IDs. The FWD ID must match the values between Filter ID1 and
Filter ID2.
11B OTHER: Other
Treated as Classsic Filter
DSEL
8:3
rwh
Destination select
Bit encoded destination Tx descriptor list select. The Ethernet desriptor
handler prepares the corresponding Tx descriptors for the frame in
EIBUF
•
Bit[0] : Tx desc list 0
•
Bit[1] : Tx desc list 1
•
Bit[2] : Tx desc list 2
•
Bit[3] : Tx desc list 3
•
Bit[4] : Tx desc list 4
•
Bit[5] : Tx desc list 5
In case of uni-cast forward only one bit is set. In case of multi-cast
forward, multiple bits can be set.
If the Tx descriptor list selected has TETHDLi_CTRL.TRIG bit set, the
frame is not forwarded to that particular destination and this particular
DSEL bit is treated as cleared
When no bit is set, the frame is not forwarded and a IDID bit is set and
INT_10 is triggered
FID1
31:9
rwh
Forward filter ID1
Forward filter ID 1
0
2
r
Reserved
Read as 0; should be written as 0
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3903
v1.1
2025-06-26


20.8.98.2
RAM Forward filter ID2
Forward filter ID2
FT_FEj_FID2 (j=0-127)
Offset address:
07644H+j*8
RAM Forward filter ID2
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
FID2
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
FID2
0
rwh
r
Field
Bits
Type
Description
FID2
31:9
rwh
Forward filter ID2
Forward filter ID 2
0
8:0
r
Reserved
Read as 0; should be written as 0
20.8.99
DMEM parameter table RAM interface
20.8.99.1
RAM Destination memory start address
The DMEM parameter table elements are stored in DRE RAM starting from DRE RAM base address + 0x7A40.
This register configures the start address of the destination memory region
DMEMi_SA (i=0-27)
Offset address:
07A40H+i*10H
RAM Destination memory start address
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
ADR
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
ADR
rw
Field
Bits
Type
Description
ADR
31:0
rw
Absolute Start Address
The start address of the destination memory. Only ADR[31:3] are
considered for address decoding, ADR[2:0] are by default 000b. Note:
The start address offset is always 64 bit aligned.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3904
v1.1
2025-06-26


20.8.99.2
RAM Destination memory frame data buffer index
The DMEM parameter table elements are stored in DRE RAM starting from DRE RAM base address + 0x7A40.
DMEMi_FDBI (i=0-27)
Offset address:
07A44H+i*10H
RAM Destination memory frame data buffer index
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
INDEX
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
INDEX
rwh
Field
Bits
Type
Description
INDEX
31:0
rwh
Data buffer index
This bit-field is calculated by the hardware on every transfer of message
to the destination memory. It denotes where the next CAN message is
to be stored in the Frame data buffer. The counter is reset to 0 when a
wraparound event has occurred.
20.8.99.3
RAM Destination memory watermark level
The DMEM parameter table elements are stored in DRE RAM starting from DRE RAM base address + 0x7A40.
This bit-field configures the Watermark level in case of Single Mode
When WML= WAL, the behaviour is as observed in Continuos mode.
DMEMi_WM (i=0-27)
Offset address:
07A48H+i*10H
RAM Destination memory watermark level
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
WML
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
WML
rw
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3905
v1.1
2025-06-26


Field
Bits
Type
Description
WML
31:0
rw
Watermark level
•
Index-based trigger mode : This is only valid for CAN I-PDU.
The watermark level is configured as absolute address from the
DMEMi_SA. The watermark flag DMEMi_STATUS.WMF is set (after
successful transfer of CAN I-PDU to destination memory) when this
address value is reached. This bit-field has to be configured to a
value higher than the size of a single CAN message (plus headers)
•
Count-based trigger mode : The watermark level is configured
in terms of number of frames or I-PDUs. The watermark flag
DMEMi_STATUS.WMF is set (after successful transfer of CAN frame
or CAN I-PDU to destination memory) when the DMEMi_STATUS.BC
value of current CAN frame equals to the configured WML bit-field
value.
When WML is configured 0, the Watermark interrupt would be triggered
after 1 CAN message is copied to DMEMi.
When WML>=WAL, the behaviour is as observed in Continuos mode. In
order to disable watermark, the user shall set WML>=WAL
20.8.99.4
RAM Destination memory wraparound level
The DMEM parameter table elements are stored in DRE RAM starting from DRE RAM base address + 0x7A40.
Wraparound level for both Single and Continuos mode
DMEMi_WA (i=0-27)
Offset address:
07A4CH+i*10H
RAM Destination memory wraparound level
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
WAL
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
WAL
rw
Field
Bits
Type
Description
WAL
31:0
rw
Wraparound level
•
Index-based trigger mode : This is only valid for CAN I-PDU. The
wraparound level is configured as absolute address from the
DMEMi_WM. The wraparound flag DMEMi_STATUS.WAF is set (after
successful transfer of CAN I-PDU to destination memory) when this
address value is reached. This bit-field has to be configured to a
value higher than the size of a single CAN message (plus headers)
•
Count-based trigger mode : The wraparound level is configured
in terms of number of frames or I-PDUs. The watermark flag
DMEMi_STATUS.WAF is set (after successful transfer of CAN frame
or CAN I-PDU to destination memory) when the DMEMi_STATUS.BC
value of current CAN frame equals to the configure WAL bit-field
value.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3906
v1.1
2025-06-26


20.9
Debug information
This section is not applicable for the module being described.
20.10
References
1.
IEEE 1722-2016, IEEE Standard for a Transport Protocol for Time-Sensitive Applications in Bridged Local
Area Networks
2.
IEEE 802.1Q-2018 - IEEE Standard for Local and Metropolitan Area Networks—Bridges and Bridged
Networks
3.
IEEE 802.3-2018 - IEEE Standard for Ethernet
4.
ISO 11898-1:2015 - Road vehicles — Controller area network (CAN) — Part 1: Data link layer and physical
signalling
20.11
DRE revision history
Reference
Description of change(s)
Date range: 2024-08-17 to 2024-10-25
Registers
•
Changed representation of register base addresses and offsets (no change of
physical register addresses)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3907
v1.1
2025-06-26


20.12
TC4Dx DRE information
20.12.1
TC4Dx DRE configuration
There is no device specific DRE configuration
20.12.2
TC4Dx DRE features
Forwarding between Ethernet interfaces include:
1.
GETH to LETH forwarding
2.
LETH to GETH forwarding
20.12.3
TC4Dx DRE functional description
1.
DRE acts as a Master on the ComPB bus and uses the system clock frequency fSPB. In TC4Dx, the ComPB
also uses this clock
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3908
v1.1
2025-06-26


20.12.4
TC4Dx DRE registers
There are no deviations from the generic specification.
20.12.4.1
Memory overview tables of DRE domain SFR
Table 965
Memory overview - DRE domain SFR (ascending address)
Short name
Long name
Address
DRE_RAM
Embedded SRAM for DRE
(08000H Byte)
F9038000H
20.12.4.2
Register address space - DRE
Table 966
Registers address space - DRE
Module
Base address
End address
Note
DRE
F9030000H
F903FFFFH
SRI Slave Interface
20.12.4.3
Register address space - DRE domain Floating
Table 967
Registers address space - DRE domain Floating
Module
Domain
Base address
End address
Note
DRE
Floating
F9038000H
F903809FH
CAN Address Database RAM interface
Floating
F90380A0H
F90386DFH
CAN Input Buffer List RAM interface
Floating
F90386E0H
F9039ADFH
CAN Output Buffer List RAM interface
Floating
F903AAE0H
F903AEDFH
CAN Transmit Routing Table RAM
interface
Floating
F903AAE0H
F903AB0FH
Ethernet Address Database RAM
interface
Floating
F903AB40H
F903B7BFH
Ethernet descriptors RAM interface
Floating
F903F640H
F903FA3FH
Forwarding table RAM interface
Floating
F903FA40H
F903FBFFH
DMEM parameter table RAM interface
20.12.4.4
Register overview - access mode glossary
Table 968
Register overview - access mode glossary
Keyword
Description
E
Access protection using PROT register DRE_PROTE .
SE
Access protection using PROT register DRE_PROTSE .
APU-PETHj
(j=0-5)
Protection group consisting of registers DRE_ETHj_ACCEN_WRA , DRE_ETHj_ACCEN_WRB ,
DRE_ETHj_ACCEN_RDA , DRE_ETHj_ACCEN_RDB , DRE_ETHj_ACCEN_VM ,
DRE_ETHj_ACCEN_PRS .
PETHj
Access protection using APU-PETHj registers.
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3909
v1.1
2025-06-26


Table 968
(continued) Register overview - access mode glossary
Keyword
Description
APU-PG
Protection group consisting of registers DRE_ACCEN_WRA , DRE_ACCEN_WRB ,
DRE_ACCEN_RDA , DRE_ACCEN_RDB , DRE_ACCEN_VM , DRE_ACCEN_PRS .
PG
Access protection using APU-PG registers.
32
Access only when using 32-bit width.
SV
Access only when supervisor mode is active on the interconnect.
BE
Always returns a Bus Error.
U
No access restrictions.
PROT
Access restrictions as defined in the PROT register access rules.
P
Description can be found in global access mode definition.
nBE
Indicates that no Bus Error is generated when accessing this address range, even though it is
either an access to an undefined address or the access does not follow the given rules.
20.12.4.5
Register overview - DRE (ascending offset address)
Table 969
Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
DRE_CLC
Clock Control Register
00000H
PG, 32
PG, SV, E,
32
Application
Reset
3798
DRE_OCS
OCDS Control and Status
Register
00004H
PG, 32
SV, PG, 32
Debug Reset
3799
DRE_ID
Module Identification
Register
00008H
PG, 32
BE
PowerOn Reset
3800
DRE_RST_CTRLA
Reset Control Register A
0000CH
PG, 32
PG, SV, E,
32
Application
Reset
3801
DRE_RST_CTRLB Reset Control Register B
00010H
PG, 32
PG, SV, E,
32
Application
Reset
3801
DRE_RST_STAT
Reset Status Register
00014H
PG, 32
BE
Application
Reset
3802
DRE_PROTE
PROT Register Endinit
00018H
U
SV, PROT
Application
Reset
3803
DRE_PROTSE
PROT Register Safe Endinit
0001CH
U
SV, PROT
Application
Reset
3804
DRE_ACCEN_WR
A
Write access enable register
A
00020H
32
SE, SV, 32
Application
Reset
3806
DRE_ACCEN_WR
B
Write access enable register
B
00024H
32
SE, SV, 32
Application
Reset
3807
DRE_ACCEN_RDA Read access enable register
A
00028H
32
SE, SV, 32
Application
Reset
3807
DRE_ACCEN_RD
B
Read access enable register
B
0002CH
32
SE, SV, 32
Application
Reset
3808
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3910
v1.1
2025-06-26


Table 969
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
DRE_ACCEN_VM
VM access enable register
00030H
32
SE, SV, 32
Application
Reset
3808
DRE_ACCEN_PRS PRS access enable register
00034H
32
SE, SV, 32
Application
Reset
3809
DRE_ETHj_ACCE
N_WRA
(j=0-5)
Write access enable register
A j
00040H+j
*20H
32
SE, SV, 32
Application
Reset
3810
DRE_ETHj_ACCE
N_WRB
(j=0-5)
Write access enable register
B j
00044H+j
*20H
32
SE, SV, 32
Application
Reset
3810
DRE_ETHj_ACCE
N_RDA
(j=0-5)
Read access enable register
A j
00048H+j
*20H
32
SE, SV, 32
Application
Reset
3811
DRE_ETHj_ACCE
N_RDB
(j=0-5)
Read access enable register
B j
0004CH+
j*20H
32
SE, SV, 32
Application
Reset
3811
DRE_ETHj_ACCE
N_VM
(j=0-5)
VM access enable register j
00050H+j
*20H
32
SE, SV, 32
Application
Reset
3812
DRE_ETHj_ACCE
N_PRS
(j=0-5)
PRS access enable register j 00054H+j
*20H
32
SE, SV, 32
Application
Reset
3812
DRE_MODEr
(r=0-7)
RP r mode register
01040H+
r*4
PG, 32
E, SV, PG,
32
Application
Reset
3813
DRE_CANi_RP
(i=0-19)
CAN i resource partition
01060H+i
*4
PG, 32
E, SV, PG,
32
Kernel Reset
3814
DRE_CIBL_BPR
CAN input buffer pending
request
010B8H
PG, 32
PG, 32
Kernel Reset
3814
DRE_CIBL_STAT
US
CAN input buffer list status
010BCH
PG, 32
PG, 32
Kernel Reset
3815
DRE_COBL_BPR0 CAN output buffer pending
request 0
010C8H
PG, 32
PG, 32
Kernel Reset
3816
DRE_COBL_BPR1 CAN output buffer pending
request 1
010CCH
PG, 32
PG, 32
Kernel Reset
3817
DRE_COBL_STAT
US
CAN output buffer list
status
010D0H
PG, 32
PG, 32
Kernel Reset
3818
DRE_EIBUFi_CO
NFIG
(i=0-5)
Ethernet input buffer i
configuration
010D8H+
i*14H
PG, 32
E, SV, PG,
32
Kernel Reset
3818
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3911
v1.1
2025-06-26


Table 969
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
DRE_EIBUFi_ERR
OR
(i=0-5)
Ethernet input buffer i error 010E0H+i
*14H
PG, 32
PG, 32
Kernel Reset
3819
DRE_EIBUFi_STA
TUS
(i=0-5)
Ethernet input buffer i
status
010E4H+i
*14H
PG, 32
PG, 32
Kernel Reset
3821
DRE_EOBUFj_CO
NFIG
(j=0-5)
Ethernet output buffer j
configuration
01150H+j
*38H
PG, 32
E, SV, PG,
32
Kernel Reset
3823
DRE_EOBUFj_MA
C_H0
(j=0-5)
Ethernet output buffer j
MAC header 0
01154H+j
*38H
PG, 32
PG, 32
Kernel Reset
3825
DRE_EOBUFj_MA
C_H1
(j=0-5)
Ethernet output buffer j
MAC header 1
01158H+j
*38H
PG, 32
PG, 32
Kernel Reset
3826
DRE_EOBUFj_MA
C_H2
(j=0-5)
Ethernet output buffer j
MAC header 2
0115CH+
j*38H
PG, 32
PG, 32
Kernel Reset
3826
DRE_EOBUFj_MA
C_H3
(j=0-5)
Ethernet output buffer j
MAC header 3
01160H+j
*38H
PG, 32
PG, 32
Kernel Reset
3827
DRE_EOBUFj_MA
C_H4
(j=0-5)
Ethernet output buffer j
MAC header 4
01164H+j
*38H
PG, 32
PG, 32
Kernel Reset
3827
DRE_EOBUFj_NT
SCF_H0
(j=0-5)
Ethernet output buffer j
NTSCF header
01168H+j
*38H
PG, 32
PG, 32
Kernel Reset
3828
DRE_EOBUFj_NT
SCF_STREAM0_I
D
(j=0-5)
Ethernet output buffer j
Stream ID configuration 0
0116CH+
j*38H
PG, 32
PG, 32
Kernel Reset
3829
DRE_EOBUFj_NT
SCF_STREAM1_I
D
(j=0-5)
Ethernet output buffer j
Stream ID configuration 1
01170H+j
*38H
PG, 32
PG, 32
Kernel Reset
3830
DRE_EOBUFj_ST
ATUS
(j=0-5)
Ethernet output buffer j
status
01174H+j
*38H
PG, 32
PG, 32
Kernel Reset
3830
DRE_EOBUFj_TT
C
(j=0-5)
Ethernet output buffer
j Transmit trigger
configuration
01178H+j
*38H
PG, 32
PG, 32
Kernel Reset
3832
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3912
v1.1
2025-06-26


Table 969
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
DRE_EOBUFj_TT
S
(j=0-5)
Ethernet output buffer j
Timer threshold and status
0117CH+
j*38H
PG, 32
PG, 32
Kernel Reset
3832
DRE_EOBUFj_ER
ROR
(j=0-5)
Ethernet output buffer j
error
01180H+j
*38H
PG, 32
PG, 32
Kernel Reset
3833
DRE_SIDFi_FC
(i=0-7)
Stream ID filter i
configuration
0129CH+
i*14H
PG, 32
PG, 32
Kernel Reset
3834
DRE_SIDFi_FIL1_
L
(i=0-7)
Stream ID filter i
configuration Stream ID
filter 1 lower
012A0H+
i*14H
PG, 32
PG, 32
Kernel Reset
3835
DRE_SIDFi_FIL1_
H
(i=0-7)
Stream ID filter i
configuration Stream ID
filter 1 higher
012A4H+
i*14H
PG, 32
PG, 32
Kernel Reset
3835
DRE_SIDFi_FIL2_
L
(i=0-7)
Stream ID filter i
configuration Stream ID
filter 2 lower
012A8H+
i*14H
PG, 32
PG, 32
Kernel Reset
3836
DRE_SIDFi_FIL2_
H
(i=0-7)
Stream ID filter i
configuration Stream ID
filter 2 higher
012ACH+
i*14H
PG, 32
PG, 32
Kernel Reset
3836
DRE_RTi_CONFI
G
(i=0-3)
CAN transmit routing table i
configuration
01340H+i
*8
PG, 32
E, SV, PG,
32
Kernel Reset
3837
DRE_RREQ_CON
FIG
Routing request
configuration
0135CH
PG, 32
BE
Kernel Reset
3837
DRE_RREQ_CID
CAN ID request
01360H
PG, 32
BE
Kernel Reset
3838
DRE_UCRH
Uni-cast routing header
01364H
PG, 32
BE
Kernel Reset
3838
DRE_MCRH
Multi-cast routing header
01364H
PG, 32
BE
Kernel Reset
3839
DRE_RS
Routing status
01368H
PG, 32
PG, 32
Kernel Reset
3840
DRE_CANRXR0
CAN receive request 0
0136CH
PG, 32
BE
Kernel Reset
3840
DRE_CANRXR1
CAN receive request 1
01370H
PG, 32
BE
Kernel Reset
3841
DRE_CANTXR
CAN transmit buffer
available request
01374H
PG, 32
BE
Kernel Reset
3842
DRE_DMEMi_CO
NFIG
(i=0-27)
Destination memory i
configuration
0137CH+
i*20H
PG, 32
E, SV, PG,
32
Kernel Reset
3842
DRE_DMEMi_MO
DE
(i=0-27)
Destination memory
i transfer mode
configuration
01380H+i
*20H
PG, 32
E, SV, PG,
32
Kernel Reset
3844
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3913
v1.1
2025-06-26


Table 969
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
DRE_DMEMi_STA
TUS
(i=0-27)
Destination memory i
status
01390H+i
*20H
PG, 32
PG, 32
Kernel Reset
3845
DRE_DMEMi_RP
(i=0-27)
Destination memory i
resource partition
01394H+i
*20H
PG, 32
E, SV, PG,
32
Kernel Reset
3846
DRE_ME_SRCA
Move engine source
address
016F8H
PG, 32
BE
Kernel Reset
3847
DRE_ME_DESTA
Move engine destination
address
016FCH
PG, 32
BE
Kernel Reset
3847
DRE_ME_STATE
Move engine state
01700H
PG, 32
BE
Kernel Reset
3847
DRE_ME_FESRCA Move engine first error
source address
01704H
PG, 32
BE
Kernel Reset
3848
DRE_ME_FEDEST
A
Move engine first error
destination address
01708H
PG, 32
BE
Kernel Reset
3849
DRE_ME_ERR
Move engine error register
0170CH
PG, 32
PG, 32
Kernel Reset
3849
DRE_INTSIG
Interrupt signal
01710H
PG, 32
BE
Kernel Reset
3851
DRE_IE
Interrupt line enable
01714H
PG, 32
PG, 32
Kernel Reset
3853
DRE_RETHDLi_C
TRL
(i=0-5)
Rx Ethernet descriptor list i
configuration and control
0171CH+
i*8
PG, 32
E, SV, PG,
32
Kernel Reset
3854
DRE_TETHDLi_C
TRL
(i=0-5)
Tx Ethernet descriptor list i
configuration and control
0174CH+
i*10H
PG, 32
E, SV, PG,
32
Kernel Reset
3856
DRE_EDLSTAT
Ethernet descriptor list
status
017D8H
PG, 32
PG, 32
Kernel Reset
3858
DRE_EREQ
Ethernet requests summary 017DCH
PG, 32
PG, 32
Kernel Reset
3859
DRE_FTCFG
Forwarding table
configuration
017E4H
PG, 32
E, SV, PG,
32
Kernel Reset
3860
DRE_CWDCFG
DRE CAN watchdog
configuration
017ECH
PG, 32
E, SV, PG,
32
Kernel Reset
3861
DRE_EWDCFG
DRE Ethernet watchdog
configuration
017F4H
PG, 32
E, SV, PG,
32
Kernel Reset
3862
DRE_EADCFG
Ethernet address database
configuration
017F8H
PG, 32
E, SV, PG,
32
Kernel Reset
3862
DRE_DMAi_RP
(i=0-5)
DMA i resource partition
017FCH+
i*4
PG, 32
E, SV, PG,
32
Kernel Reset
3863
DRE_CITO
CAN Input buffer timeout
status
01818H
PG, 32
PG, 32
Kernel Reset
3863
DRE_COTO0
CAN Output buffer timeout
status 0
0181CH
PG, 32
PG, 32
Kernel Reset
3864
(table continues...)
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3914
v1.1
2025-06-26


Table 969
(continued) Register overview - DRE (ascending offset address)
Short name
Long name
Offset
address
Access mode
Reset
See
Read
Write
DRE_COTO1
CAN Output buffer timeout
status 1
01820H
PG, 32
PG, 32
Kernel Reset
3864
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3915
v1.1
2025-06-26


20.12.4.6
Device specific registers
There are no device specific register changes.
20.12.5
TC4Dx DRE connectivity
The table below lists interfaces to and from this functional block to other blocks in the device.
Table 970
List of DRE interface signals
Interface signals
I/O
Description
CLOCK_DRE_fSPB
In
SPB clock input
CLOCK_DRE_fSRI
In
SRI clock input
CAN0_DRE_TRIGTYPE[1:0]
In
Trigger input per MCMCAN
CAN1_DRE_TRIGTYPE[1:0]
In
Trigger input per MCMCAN
CAN2_DRE_TRIGTYPE[1:0]
In
Trigger input per MCMCAN
CAN3_DRE_TRIGTYPE[1:0]
In
Trigger input per MCMCAN
CAN4_DRE_TRIGTYPE[1:0]
In
Trigger input per MCMCAN
CAN0_DRE_TRIGNODE[1:0]
In
Trigger input per MCMCAN
CAN1_DRE_TRIGNODE[1:0]
In
Trigger input per MCMCAN
CAN2_DRE_TRIGNODE[1:0]
In
Trigger input per MCMCAN
CAN3_DRE_TRIGNODE[1:0]
In
Trigger input per MCMCAN
CAN4_DRE_TRIGNODE[1:0]
In
Trigger input per MCMCAN
DRE_IR_DREw[15:0]
Out
Interrupt request
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3916
v1.1
2025-06-26


20.12.6
TC4Dx DRE revision history
Initial release of the chapter.
 
 
AURIX™ TC4Dx user manual 
20  Data Routing Engine (DRE)
Reference manual
3917
v1.1
2025-06-26
