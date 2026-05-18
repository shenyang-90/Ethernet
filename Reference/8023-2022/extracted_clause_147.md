# Clause 147: 10BASE-T1S

**Focus**: PLCA beacon, burst mode, state machine, timers, PCS/PMA digital  
**Pages extracted**: 5885 – 5911  
**Excluded from**: Page 5912 (electrical/PICS section)

147. Physical Coding Sublayer (PCS), Physical Medium Attachment (PMA) 
sublayer and baseband medium, type 10BASE-T1S
147.1 Overview
This clause defines the type 10BASE-T1S Physical Coding Sublayer (PCS) and type 10BASE-T1S Physical 
Medium Attachment (PMA) sublayer. Together, the PCS and PMA sublayers comprise a 10BASE-T1S 
Physical Layer device (PHY). Provided in this clause are full functional and electrical specifications for the 
type 10BASE-T1S PCS, PMA, and MDI.
The 10BASE-T1S PHY is specified to be capable of operating at 10 Mb/s in several modes. All 
10BASE-T1S PHYs can operate as a half-duplex PHY with a single link partner over a point-to-point link 
segment defined in 147.7, and, additionally, there are two mutually exclusive optional operating modes: a 
full-duplex point-to-point mode over the link segment, defined in 147.7, and a half-duplex shared-medium 
mode, referred to as multidrop mode, capable of operating with multiple stations connected to a mixing 
segment, defined in 147.8. The medium supporting the operation of the 10BASE-T1S PHY is defined in 
terms of performance requirements between the attachment points (Medium Dependent Interface (MDI)), 
allowing implementers to specify their own media to operate the 10BASE-T1S PHY as long as the 
normative requirements included in this clause are met.
10BASE-T1S PHYs optionally support PHY Level Collision Avoidance (PLCA), described in Clause 148.
10BASE-T1S follows an integrated PCS and PMA architecture and therefore does not support an AUI 
(see Figure 1–1).
147.1.1 Relationship of 10BASE-T1S to other standards
The relationship between the 10BASE-T1S, the ISO Open Systems Interconnection (OSI) Reference Model, 
and the IEEE 802.3 Ethernet model are shown in Figure 147–1. The PHY sublayers (shown shaded) 
in Figure 147–1 connect one Clause 4 Media Access Control (MAC) layer to the medium. Auto-Negotiation 
for 10BASE-T1S is defined in Clause 98 and is not available in multidrop mode. Selection between 
multidrop and point-to-point mode is made via the appropriate configuration bit. A Management Entity is 
required using MDIO or equivalent functionality. Optional MDIO is defined in Clause 45.
147.1.2 Operation of 10BASE-T1S
All 10BASE-T1S PHYs can operate using half-duplex point-to-point communications on a link segment 
using a single balanced pair of conductors, supporting up to four in-line connectors and up to at least 
15 meters in reach, with an effective data rate of 10 Mb/s shared between the two directions of transmission. 
10BASE-T1S PHYs supporting the option of full-duplex point-to-point operation may operate with an 
effective data rate of 10 Mb/s in each direction simultaneously, supporting up to four in-line connectors and 
up to at least 15 meters in reach.
Additionally, the 10BASE-T1S PHY may operate using half-duplex communications on a mixing segment 
using a single balanced pair of conductors, interconnecting up to at least 8 PHYs to a trunk up to at least 
25 m. PHYs may be attached in-line with the trunk or at the end of stubs with a length of up to 10 cm. An 
overall effective data rate of 10 Mb/s is shared among the nodes. Larger PHY count and reach may be 
achieved provided the mixing segment specifications in 147.8 are met.


The 10BASE-T1S PHY utilizes two level Differential Manchester Encoding (DME). A 17-bit self-
synchronizing scrambler is used to improve the EMC performance. Following scrambling of the data, 4B/5B 
encoding is performed (see 147.3.2.4). DME is a self-clocked and intrinsically balanced line coding that 
guarantees very low DC baseline wander and allows for robust clock and data recovery in noisy 
environments. The 4B/5B mapping and the scrambler are contained within the PCS (see 147.3) while the 
DME encoder/decoder is contained in the PMA (see 147.4).
147.1.3 Conventions in this clause
The body of this clause contains state diagrams, including definitions of variables, constants, and functions. 
Should there be a discrepancy between a state diagram and descriptive text, the state diagram prevails.
147.1.3.1 State diagram notation
The conventions of 21.5 are adopted with the extension that some states in the state diagrams use an IF-
THEN-ELSE-END construct to condition which actions are taken within the state. If the logical expression 
associated with the IF evaluates TRUE, all the actions listed between THEN and ELSE will be executed. In 
the case where ELSE is omitted, the actions listed between THEN and END will be executed. If the logical 
expression associated with the IF evaluates FALSE, the actions listed between ELSE and END will be 
executed. After executing the actions listed between THEN and ELSE, between THEN and END, or 
between ELSE and END, the actions following the END, if any, will be executed.
147.1.3.2 State diagram timer specifications
All timers operate in the manner described in 40.4.5.2.
Figure 147–1—Relationship of 10BASE-T1S PHY
to the ISO/IEC OSI reference model and the IEEE 802.3 Ethernet model
PRESENTATION
APPLICATION
SESSION
TRANSPORT
NETWORK
DATA LINK
 PHYSICAL
OSI
 REFERENCE
MODEL
LAYERS
ETHERNET
LAYERS
MAC - MEDIA ACCESS CONTROL
RECONCILIATION
HIGHER LAYERS
MDI = MEDIUM DEPENDENT INTERFACE
MII = MEDIA INDEPENDENT INTERFACE
PCS = PHYSICAL CODING SUBLAYER
PMA = PHYSICAL MEDIUM ATTACHMENT
PHY = PHYSICAL LAYER DEVICE
MII1
MDI
10BASE-T1S
PMA
PCS
AN2
MEDIUM
LLC - LOGICAL LINK CONTROL
OR OTHER MAC CLIENT
MAC CONTROL (OPTIONAL)
PHY
NOTE 1—MII is optional
NOTE 2—Auto-Negotiation is optional
AN = AUTO-NEGOTIATION


147.1.3.3 Service specifications
The method and notation used in the service specification follows the conventions of 1.2.2.
147.2 Service primitives and interfaces
The 10BASE-T1S PHY uses the service primitives and interfaces in 40.2, with exception of the following 
clarifications and differences noted in this subclause. Figure 147–2 shows the relationship of the service 
primitives and interfaces used by the 10BASE-T1S PHY.
The 10BASE-T1S PHY uses the Media Independent Interface (MII) as specified in Clause 22.
As shown in Figure 147–2, 10BASE-T1S uses the following service primitives to exchange symbol vectors, 
status indications, and control signals across the PMA service interface:
PMA_UNITDATA.indication (rx_sym)
PMA_UNITDATA.request (tx_sym)
PMA_CARRIER.indication (pma_crs)
PMA_LINK.indication (link_status)
PMA_UNITDATA.indication
PMA_UNITDATA.request
Figure 147–2—10BASE-T1S PHY interfaces
 
TXD<3:0>
TX_CLK
TX_EN
TX_ER
RX_CLK
RXD<3:0>
RX_DV
RX_ER
MDIO
MDC
MEDIUM
INTERFACE
DEPENDENT
(MDI)
PMA SERVICE
INTERFACE
INDEPENDENT
INTERFACE
(MII)
MEDIA
PHY
MANAGEMENT
PMA
PCS
CRS
COL
BI_DA+
BI_DA–
PMA_CARRIER.indication
Technology Dependent Interface (optional)
PCS_STATUS.indication
PMA_LINK.request
PMA_LINK.indication


PMA_LINK.request (link_control)
PCS_STATUS.indication (pcs_status)
147.2.1 PMA_UNITDATA.indication
This primitive defines the transfer of one 5B symbol in the form of the rx_sym parameter from the PMA to 
the PCS.
147.2.1.1 Semantics of the primitive
PMA_UNITDATA.indication (rx_sym)
During reception, the PMA_UNITDATA.indication conveys to the PCS, via the parameter rx_sym, the 
value of the 5B symbol detected on the MDI during each cycle of the recovered clock.
147.2.1.2 When generated
The PMA generates PMA_UNITDATA.indication (rx_sym) messages synchronously for every 5B symbol 
received at the MDI. The nominal rate of the PMA_UNITDATA.indication primitive is 2.5 MHz, as 
governed by the recovered clock.
147.2.1.3 Effect of receipt
The effect of receipt of this primitive is unspecified.
147.2.2 PMA_UNITDATA.request
This primitive defines the transfer of one symbol in the form of the tx_sym parameter from the PCS to the 
PMA.
The symbol is obtained in the PCS Transmit function using the encoding rules defined in 147.3.2 to 
represent 4B/5B encoded MII data or special out of band signaling.
147.2.2.1 Semantics of the primitive
PMA_UNITDATA.request (tx_sym)
During transmission, the PMA_UNITDATA.request conveys the value of the symbol to be sent over the 
MDI, via the parameter tx_sym.
The tx_sym parameter is one of the allowed 5B codes specified in Table 147–1.
147.2.2.2 When generated
The PCS generates PMA_UNITDATA.request (tx_sym) synchronously with every symb_timer expiration. 
The symb_timer is defined in 147.3.2.6.
147.2.2.3 Effect of receipt
Upon receipt of this primitive the PMA transmits on the MDI the signals corresponding to the indicated 5B 
symbol after processing it with DME following the rules in 147.4.


147.2.3 Mapping of PMA_CARRIER.indication
Reports whether a signal compatible with DME encoding rules specified in 147.4.2 is detected on the 
medium.
147.2.3.1 Function
Maps the primitive PMA_CARRIER.indication to the MII CRS signal.
147.2.3.2 Semantic of the service primitive
PMA_CARRIER.indication (pma_crs)
The pma_crs parameter can take one of two values: CARRIER_ON or CARRIER_OFF.
The pma_crs parameter is set to CARRIER_ON if a signal compatible with DME encoding rules specified 
in 147.4.2 is present on the medium. Otherwise, the pma_crs parameter is set to CARRIER_OFF.
147.2.3.3 When generated
The PMA_CARRIER.indication primitive is generated continuously by the PMA sublayer.
147.2.4 PMA_LINK.request
This primitive allows Auto-Negotiation to enable and disable operation of the PMA, as specified in 98.4.2.
147.2.4.1 Semantics of the primitive
PMA_LINK.request (link_control)
The link_control parameter can take on one of the following two values:
DISABLE
Used by Auto-Negotiation function to disable the PHY.
ENABLE
Used by Auto-Negotiation function to enable the PHY.
147.2.4.2 When generated
Auto-Negotiation generates this primitive to indicate a change in link_control as described in 98.4.
147.2.5 PMA_LINK.indication
This primitive is generated by the PMA to indicate the status of the underlying medium as specified 
in 98.4.1. This primitive informs Auto-Negotiation functions about the status of the underlying link.
147.2.5.1 Semantics of the primitive
PMA_LINK.indication (link_status)
The link_status parameter can take on the following two values:
FAIL
No valid link established.
OK
The Link Monitor function indicates that a valid 10BASE-T1S link is established. 
Reliable reception of signals transmitted from the remote PHY is possible.


147.2.5.2 When generated
The PMA generates this primitive to indicate a change in link_status in compliance with the state diagram 
given in Figure 147–14.
147.2.5.3 Effect of receipt
The effect of receipt of this primitive is specified in 98.4.1.
147.2.6 PCS_STATUS.indication
This primitive is generated by the PCS to indicate PCS status to the PMA.
147.2.6.1 Semantics of the primitive
PCS_STATUS.indication (pcs_status)
The pcs_status parameter can take on the following two values:
NOT_OK
PCS is not receiving valid packets or heartbeat signals from the remote PHY.
OK
PCS is actively receiving valid packets and/or heartbeat signals from the remote PHY.
147.2.6.2 When generated
The PCS generates this primitive continuously. The pcs_status parameter is set according to the state 
diagram in Figure 147–11.
147.2.6.3 Effect of receipt
The effect of receipt of this primitive is specified in 147.4.4.
147.3 Physical Coding Sublayer (PCS) functions
The Physical Coding Sublayer (PCS) consists of PCS Reset, PCS Transmit, and PCS Receive functions as 
shown in Figure 147–3. The PCS Reset function is explained in 147.3.1, the PCS Transmit function is 
explained in 147.3.2, the PCS Receive function is explained in 147.3.3, and the PCS Loopback function is 
explained in 147.3.4.
147.3.1 PCS Reset function
PCS Reset initializes all PCS functions. The PCS Reset function shall be executed whenever any of the 
following conditions occur:
a)
Power on causes power_on = TRUE (see 36.2.5.1.3) while pcs_reset = FALSE.
b)
The receipt of a request for reset from the management entity (bit 3.2291.15 defined in 45.2.3.72.1), 
independently from the current state of pcs_reset.
All state diagrams take the open-ended pcs_reset branch upon execution of PCS Reset. PCS Reset shall keep 
pcs_reset = TRUE until the complete execution of the PCS Reset function, after which it is set to 
pcs_reset = FALSE. The reference diagrams do not explicitly show the PCS Reset function.


147.3.2 PCS Transmit
147.3.2.1 PCS Transmit overview
The PCS Transmit function shall conform to the PCS Transmit state diagram in Figure 147–4 and 
Figure 147–5, and the associated state variables, functions, timers, and messages.
At each symbol period, PCS Transmit generates a symbol tx_sym conveyed to the PMA through the 
PMA_UNITDATA.request service primitive, where tx_sym is a 5B symbol. The PMA encodes tx_sym, 
LSB first, into a DME stream over the wire pair BI_DA as specified in Table 147–2.
duplex_mode
 
Figure 147–3—PCS reference diagram
PCS
RECEIVE
RX_CLK
RXD<3:0>
RX_DV
RX_ER
COLLISION
TX_EN
TX_ER
TX_CLK
pcs_reset
PMA_UNITDATA.indication (rx_sym)
DETECTION
TXD<3:0>
TRANSMIT
PCS
PMA_UNITDATA.request
(tx_sym)
MANAGEMENT
MDC
MDIO
 
link_control
CRS
COL
transmitting
PMA_CARRIER.indication
(pma_crs)
PCS_STATUS.indication (pcs_status)
Technology Dependent Interface (optional)


Upon assertion of TX_EN, the PCS Transmit function passes two SYNC symbols to the PMA, followed by 
two SSD symbols that replace the first 16 bits of the packet preamble. Following the second SSD, 
TXD<3:0> is encoded into 5B symbols using the encoding rules specified in Table 147–1, until TX_EN is 
deasserted.
Following the deassertion of TX_EN, the PCS Transmit generates a special code ESD. When there is no 
transmit error, ESD is followed by ESDOK. When there is a transmit error, ESD is followed by ESDERR. 
When a jabber condition is detected, ESD is followed by ESDJAB.
The 10BASE-T1S PHY has one special 5B symbol 'I' (see Table 147–1) which represents SILENCE. 
SILENCE represents an indication for the PMA to change the output according to 147.4.2.
147.3.2.2 Variables
err
This variable is set in the PCS Transmit state, as described in Figure 147–4 and 
Figure 147–5.
This variable is used to detect and latch a TX_ER = TRUE condition during data 
transmission; if such error is detected, an ESDERR symbol is sent at the end of 
transmission.
Values: TRUE or FALSE
hb_cmd
See 147.3.7.1.1.
link_control
This variable is generated by the Auto-Negotiation function. When Auto-Negotiation is 
not present or Auto-Negotiation is disabled, link_control has a default value of 
ENABLE, and may be provided by implementation-dependent functionality. When set 
to DISABLE, all PCS functions are switched off and no data can be sent or received.
Values: ENABLE or DISABLE
pcs_reset
The pcs_reset parameter set by the PCS Reset function.
Values: TRUE or FALSE
TX_EN
The TX_EN signal of the MII as specified in 22.2.2.3.
When set to FALSE transmission is disabled.
When set to TRUE transmission is enabled.
Values: TRUE or FALSE
TX_ER
The TX_ER signal of the MII as specified in 22.2.2.5.
When set to FALSE it indicates a non-errored transmission.
When set to TRUE it indicates an errored transmission.
Values: TRUE or FALSE
TXD
The TXD signal of the MII as specified in 22.2.2.4.
This signal represents a 4B data nibble to be transmitted.


tx_cmd
Encoding present on TXD<3:0>, TX_ER, and TX_EN as defined in Table 22–1.
Values:
BEACON: PLCA BEACON indication encoding present on TXD<3:0>, TX_ER, and 
TX_EN.
COMMIT: PLCA COMMIT indication encoding present on TXD<3:0>, TX_ER, and 
TX_EN.
SILENCE: TXD<3:0> does not encode any of the above requests, or TX_ER = FALSE, 
or TX_EN = TRUE.
tx_sym
5B symbol to be conveyed to the PMA Transmit function by the means of the 
PMA_UNITDATA.request primitive specified in 147.2.2.
transmitting
This variable is set in the PCS Transmit state, as described in Figure 147–4.
When this variable is set to TRUE, it indicates a transmission is ongoing.
Values: TRUE or FALSE
147.3.2.3 Constants
SYNC / COMMIT
5B symbol defined as 'J' in 4B/5B encoding.
SSD
5B symbol defined as 'H' in 4B/5B encoding.
ESD
5B symbol defined as 'T' in 4B/5B encoding.
ESDERR
5B symbol defined as 'K' in 4B/5B encoding.
ESDOK / ESDBRS
5B symbol defined as 'R' in 4B/5B encoding.
SILENCE
5B symbol defined as 'I' in 4B/5B encoding.
ESDJAB
5B symbol defined as 'S' in 4B/5B encoding.


147.3.2.4 Functions
ENCODE
This function takes a 4 bit input parameter Scn<3:0> and returns a 5B symbol according 
to the following procedure:
1. Convert Scn<3:0> into Sdn<3:0> as specified in 147.3.2.8.
2. Convert Sdn<3:0> (4B symbol) into the corresponding 5B symbol defined 
in Table 147–1.
Table 147–1—4B/5B Encoding 
Name
4B
5B
Special function
—
—
—
—
—
—
—
—
—
—
A
—
B
—
C
—
D
—
E
—
F
—
I
N/A
SILENCE
J
N/A
SYNC / COMMIT
K
N/A
ESDERR
T
N/A
ESD / HB
R
N/A
ESDOK / ESDBRS
H
N/A
SSD
N
N/A
BEACON
S
N/A
ESDJAB


TXCMD_ENCODE
In the PCS transmit process, this function takes as its arguments the values of tx_cmd 
and hb_cmd variables and returns a 5B symbol based on the following mapping:
'N' when the tx_cmd variable is set to BEACON,
'J' when the tx_cmd variable is set to COMMIT,
'T' when the hb_cmd variable is set to HEARTBEAT and the tx_cmd variable is not set 
to BEACON or COMMIT,
'I' otherwise.
147.3.2.5 Abbreviations
STD
Alias for symb_timer_done.
147.3.2.6 Timers
symb_timer
A continuous free-running timer. PMA_UNITDATA.request messages are issued by the 
PCS concurrently with symb_timer_done (see 147.2.2). TX_CLK (see 22.2.2.1) shall be 
generated from symb_timer with the rising edge of TX_CLK generated synchronously 
with symb_timer_done.
Continuous timer: The condition symb_timer_done becomes true upon timer expiration.
Restart time: Immediately after expiration.
Duration: 400 ns ± 100 ppm (see 22.2.2.1)
unjab_timer
Optionally times the minimum duration the PHY suppresses any transmission before 
reverting to normal operations.
Duration: 16 ms ± 100 s
xmit_max_timer
Defines the maximum time the PCS Transmit state diagram can stay in DATA state.
The xmit_max_timer shall be implemented in such a way that, upon expiration, an even 
number of nibbles has been sent to prevent the MAC from counting false alignment 
errors.
Duration: 2 ms ± 100 s
NOTE—This is approximately 25% greater than maxEnvelopeFrameSize specified in 4.2.7.1.


147.3.2.7 State diagram
STD *
(!TX_EN) *
(tx_cmd = COMMIT)
Figure 147–4—PCS Transmit state diagram, part a
pcs_reset +
(link_control = DISABLE)
STD *
TX_EN
SILENT
transmitting  FALSE
err FALSE
tx_sym TXCMD_ENCODE(tx_cmd, hb_cmd)
STD 
SYNC1
transmitting  TRUE
tx_sym  SYNC
err  err + TX_ER
SYNC2
err  err + TX_ER
SSD1
tx_sym  SSD
err  err + TX_ER
STD 
SSD2
err  err + TX_ER
start xmit_max_timer
STD 
STD 
COMMIT
tx_sym COMMIT
STD *
TX_EN
B
A
C
STD *
(!TX_EN) *
(tx_cmd = SILENCE)
STD *
(!TX_EN) *
(tx_cmd  COMMIT)


147.3.2.8 Self-synchronizing scrambler
The PCS Transmit function shall implement multiplicative scrambling using the following generator 
polynomial 
.
An implementation of a self-synchronizing scrambler by a linear-feedback shift register is shown 
in Figure 147–6. The bits stored in the shift register delay line at time n are denoted by Scrn<16:0>. 
The '+' symbol denotes the exclusive-OR logical operation. When Scn<3:0> is presented at the input of the 
scrambler, Sdn<3:0> is produced by shifting in each bit of Scn<3:0> as Scn<i>, with i ranging from 0 to 3 
(i.e., LSB first). The scrambler is reset upon execution of the PCS Reset function. If the PCS Reset is 
executed, all bits of the 17-bit vector representing the self-synchronizing scrambler state are arbitrarily set. 
The initialization of the scrambler state is left to the implementer. In no case shall the scrambler state be 
initialized to all zeros. At every STD, if no data is presented at the scrambler input via Scn<3:0>, the 
scrambler may be fed with arbitrary inputs.
STD * (!err) *
xmit_max_timer_done
STD *
TX_EN *
xmit_max_timer_not_done
Figure 147–5—PCS Transmit state diagram, part b
STD *
((!TX_EN) +
xmit_max_timer_done)
DATA
tx_sym  ENCODE(TXD)
err err + TX_ER
STD *
(!err) *
xmit_max_timer_not_done
ESD
IF tx_cmd COMMIT THEN
tx_sym ESD
ELSE
tx_sym  ESDBRS
END
BAD_ESD
IF err THEN
tx_sym ESDERR
ELSE
tx_sym  ESDJAB
END
GOOD_ESD
tx_sym  ESDOK
STD
STD *
(err +
xmit_max_timer_done)
UNJAB_WAIT
tx_sym  SILENCE
start unjab_timer
STD * err
STD *
(!TX_EN) *
unjab_timer_done
A
B
C
Optional Implementation
g x

x17
x14
+
+
=


147.3.2.9 Jabber functional requirements
The PCS Transmit function contains the capability to interrupt a transmission that exceeds a time duration 
determined by xmit_max_timer. If the packet being transmitted continues longer than the specified time 
duration, the PCS Transmit sends an ESD, ESDJAB symbol sequence to notify the receivers, then it inhibits 
further transmissions for at least the duration of unjab_timer. The PCS Transmit may return to normal 
operation automatically after unjab_timer elapsed and the error condition has been cleared, or it may keep 
silent until reset.
147.3.3 PCS Receive
147.3.3.1 PCS Receive overview
The PCS Receive function shall conform to the PCS Receive state diagram in Figure 147–7 and 
Figure 147–8, and associated state variables.
The state diagram defined in Figure 147–7 is triggered by the reception of a SYNC symbol from the PMA 
Receive function and waits for two SSD symbols to start regenerating the packet preamble whose start has 
been replaced with the SYNC, SYNC, SSD, SSD sequence by the PCS Transmit function as described 
in Figure 147–4. After the second SSD is received, the PCS Receive function discards the next nine 
symbols. These symbols can be used to achieve lock of the self-synchronizing descrambler.
During the descrambler locking time, the special value 5 is conveyed to the MII via the RXD variable in 
order to rebuild the original preamble transmitted by the MAC.
The DATA state, in which 5B symbols are decoded into MII data, is left when ESD or ESDBRS followed by 
either ESDOK, ESDERR, or ESDJAB symbol is encountered, or when the PMA detects SILENCE on the 
media (e.g., the transmitter prematurely stops data transmission).
During the WAIT_SYNC state, the PCS notifies the RS of a received BEACON indication by the means of 
the MII as specified in 22.2.2.8. When a sequence of at least two consecutive 'N' symbols is received, the 
MII signals RX_DV, RX_ER, and RXD<3:0> are set to the BEACON indication as shown in Table 22–2. 
Additionally, the PCS notifies the RS of a received COMMIT indication by the means of the MII as 
specified in 22.2.2.8. When a sequence of at least two consecutive SYNC is received, the MII signals 
RX_DV, RX_ER, and RXD<3:0> are set to the COMMIT indication as shown in Table 22–2.
Figure 147–6—Self-synchronizing scrambler
Scn<i>
Scrn<0>
T
Scrn<1>
T
Scrn<13>
T
Scrn<14>
T
Scrn<15>
T
Scrn<16>
T
+
+
Sdn<i>


147.3.3.2 Variables
duplex_mode
This variable indicates whether the PHY is configured for full-duplex operation 
(DUPLEX_FULL) or half-duplex operation (DUPLEX_HALF). If Multidrop mode 
MDIO register bit 1.2297.10 is set to one and multidrop mode is supported according to 
bit 1.2298.10 then duplex_mode is set to DUPLEX_HALF. Else, if Auto-Negotiation is 
enabled then duplex_mode is set by the priority resolution defined in 98B.4. Otherwise, 
this variable is set by MDIO register bit 3.2291.8. If MDIO is not implemented, 
duplex_mode is set by equivalent means.
Values: DUPLEX_FULL or DUPLEX_HALF
link_control
See 147.3.2.2.
multidrop
See 147.3.7.1.1.
precnt
Counter for preamble regeneration.
rx_cmd
See 147.3.7.1.1.
RX_DV
The RX_DV signal of the MII as specified in 22.2.2.7.
RX_ER
The RX_ER signal of the MII as specified in 22.2.2.10.
RXD
PCS decoded data synchronous to RX_CLK as specified in 22.2.2.8.
pcs_reset
See 147.3.2.2.
RXn
The rx_sym parameter of the PMA_UNITADATA.indication primitive defined 
in 147.2.1.
The 
'n' 
subscript 
denotes 
the 
rx_sym 
conveyed 
in 
the 
most 
recent 
recv_symb_conv_timer cycle.
The 'n-x' subscript indicates the rx_sym conveyed 'x' cycles before the most recent one. 
transmitting
See 147.3.2.2.
147.3.3.3 Constants
fc_supported
Indicates whether the optional False Carrier detection is supported.
Values: TRUE or FALSE
BEACON
5B symbol defined as 'N' in 4B/5B encoding.
HB
5B symbol defined as 'T' in 4B/5B encoding.
See also 147.3.2.3.


147.3.3.4 Functions
DECODE
This function takes a 5B symbol input parameter and returns a 4 bit value Dcn<3:0> 
value according to the following procedure:
1. Convert the 5B input symbol into Drn<3:0> by performing a reverse lookup 
in Table 147–1. If no 4B value is associated to the given 5B symbol, the PCS Receive 
function shall assert RX_ER for at least one symbol period and Drn<3:0> may be set 
arbitrarily.
2. Convert Drn<3:0> to Dcn<3:0> as specified in 147.3.3.8.
147.3.3.5 Abbreviations
RSCD
Alias for recv_symb_conv_timer_done.
147.3.3.6 Timers
recv_symb_conv_timer
A continuous timer which expires when the PMA_UNITDATA.indication message is 
generated (see 147.2.1).
Continuous timer: The condition recv_symb_conv_timer_done becomes true upon timer 
expiration.
Restart time: Immediately after expiration.
Duration: timed by the PMA_UNITDATA.indication message generation.


147.3.3.7 State diagrams
Figure 147–7—PCS Receive state diagram, part a
RSCD *
((RXn = ESD) +
((RXn  SSD) *
(RXn  SYNC) *
(!fc_supported)))
RSCD *
(RXn  SSD)*
fc_supported
RSCD *
(precnt  9)
RSCD 
precnt = 9
PRE
RX_DV TRUE
RXD 0101
IF precnt > 3 THEN
precnt precnt + 1
DECODE(RXn-3)
ELSE
precnt precnt + 1
END
RSCD *
(RXn = SSD)
RSCD *
(RXn = SSD)
RSCD *
(RXn = SYNC)
RSCD *
(RXn = SSD)
RSCD *
(RXn = SYNC)
pcs_reset +
(transmitting *
(duplex_mode = DUPLEX_HALF)) +
(link_control = DISABLE)
B
A
RSCD *
(precnt = 9)
RSCD *
(RXn  SSD) *
(!fc_supported)
RSCD *
(RXn = SILENCE +
(RXn = ESD)
BAD_SSD
RX_ER TRUE
RXD 1110
rx_cmd NONE
COMMIT
RX_ER TRUE
RXD 0011
rx_cmd COMMIT
WAIT_SSD
RXD 0000
precnt 0
RX_ER FALSE
rx_cmd NONE
D
RSCD *
(RXn = HB) *
(!multidrop)
RSCD *
(RXn = BEACON)
C
RSCD *
(RXn  SYNC) *
(RXn  SSD) *
(RXn  ESD) *
fc_supported
RSCD *
(RXn = SSD)
RSCD *
(RXn  SYNC) *
(RXn  SSD) *
(RXn  ESD) *
fc_supported
RSCD *
((RXn = ESD) +
((RXn  SSD) *
(RXn  SYNC) *
(!fc_supported)))
RSCD *
((RXn = SILENCE) +
(RXn = ESD))
SYNCING
WAIT_SYNC
RX_DV FALSE
RX_ER FALSE
RXD 0000
rx_cmd NONE


Figure 147–8—PCS Receive state diagram, part b
A
DATA
RXD  DECODE(RXn–3)
BAD_ESD
RX_ER  TRUE
RXD 0000
GOOD_ESD
RX_DV  FALSE
RXD 0000
RSCD
RSCD *
((((RXn–2 = ESD) +
(RXn–2 = ESDBRS)) *
(RXn–1 ESDOK) *
(RXn–3  ESD) *
(RXn–3  ESDBRS)) +
(RXn–3  SILENCE))
RSCD *
((RXn–3 = ESD) +
(RXn–3 = ESDBRS)) *
(RXn–2 = ESDOK)
RSCD
B
RSCD *
(!((((RXn–2 = ESD) +
(RXn–2 = ESDBRS)) *
(RXn–1 ESDOK) *
(RXn–3  ESD)*
(RXn–3  ESDBRS)) +
(RXn–3  SILENCE))) *
(!(((RXn–3 = ESD) +
(RXn–3 = ESDBRS)) *
(RXn–2 = ESDOK)))
HEARTBEAT1
C
B
HEARTBEAT2
rx_cmd HEARTBEAT
RSCD *
(RXn = HB)
RSCD *
(RXn  HB)
B
RSCD *
(RXn  HB)
BEACON1
D
B
BEACON2
RX_ER TRUE
RXD 0010
rx_cmd BEACON
RSCD *
(RXn  BEACON)
B
RSCD *
(RXn = BEACON)
RSCD *
(RXn  BEACON)


147.3.3.8 Self-synchronizing descrambler
The PCS Receive function descrambles the 5B/4B decoded data stream and returns the value of RXD<3:0> 
to the MII. The descrambler shall employ the polynomial 
 defined in 147.3.2.8. The implementation of 
the self-synchronizing descrambler by linear-feedback shift register is shown in Figure 147–9. The bits 
stored in the shift register delay line at time n are denoted by Dcrn<16:0>. The '+' symbol denotes the 
exclusive-OR logical operation.
When Drn<3:0> is presented at the input of the descrambler, Dcn<3:0> is produced by shifting in each bit of 
Drn<3:0> as Drn<i>, with i ranging from 0 to 3 (i.e., LSB first). The descrambler is reset upon execution of 
the PCS Reset function. If PCS Reset is executed, all the bits of the 17-bit vector representing the self-
synchronizing descrambler state are arbitrarily set. The initialization of the descrambler state is left to the 
implementer. At every RSCD, if no data is presented at the descrambler input via Drn<3:0>, the descrambler 
may be fed with arbitrary inputs.
147.3.3.9 Jabber diagnostics
The ESDJAB symbol informs the PCS Receiver that a frame was terminated by the jabber function. The 
number of received ESDJAB events can be reported to the management entity be the means of MDIO 
register 3.2293 or similar functionality if MDIO is not implemented.
147.3.4 PCS loopback
The PCS shall be placed in loopback mode when the loopback bit in MDIO register 3.0.14, defined 
in 45.2.3.1.2, is set to one (or PCS loopback mode is enabled by a similar functionality if MDIO is not 
implemented). In this mode, the PCS shall accept data on the transmit path from the MII and return it on the 
receive path to the MII. Additionally, the PHY receive circuitry shall be isolated from the network medium, 
and the assertion of TX_EN at the MII shall not result in the transmission of data on the network medium.
147.3.5 Collision detection
When operating in half-duplex mode, the 10BASE-T1S PHY shall detect when a transmission initiated 
locally results in a corrupted signal at the MDI as a collision. When collisions are detected, the PHY shall 
assert the signal COL on the MII for the duration of the collision or until TX_EN signal is FALSE.
The method for detecting a collision is implementation dependent but the following requirements have to be 
fulfilled:
a)
The PHY shall assert COL when it is transmitting, and one or more other stations are also 
transmitting at the same time.
b)
The PHY shall assert CRS in the presence of a signal resulting from a collision between two or more 
other stations.
g x

Figure 147–9—Self-synchronizing descrambler
Drn<i>
Dcrn<0>
T
Dcrn<1>
T
Dcrn<13>
T
Dcrn<14>
T
Dcrn<15>
T
Dcrn<16>
T
+
+
Dcn<i>


147.3.6 Carrier sense
When operating in half-duplex mode, the 10BASE-T1S PHY senses when the media is busy and conveys 
this information to the MAC by asserting the signal CRS on the MII as specified in 22.2.2.11.
CRS is generated by mapping the PMA_CARRIER.indication (pma_crs) primitive to the MII signal CRS:
a)
CRS shall be asserted when the pma_crs parameter is CARRIER_ON.
b)
CRS shall be deasserted when the pma_crs parameter is CARRIER_OFF.
147.3.7 Support for PCS status generation
If Clause 98 Auto-Negotiation functions are implemented and enabled, the PCS shall conform to the 
Heartbeat (HB) transmit and receive state diagrams in Figure 147–10, Figure 147–11, and the associated 
state variables, functions, timers, messages, and constants.
If Clause 98 Auto-Negotiation functions are not implemented or disabled, the PCS_STATUS.indication 
primitive conveys NOT_OK.
The pcs_status parameter of PCS_STATUS.indication primitive is set to OK after the reception of HB 
signals or valid data reception (RX_DV) according to the logic described in the HB receive state diagram.
The HB generation is disabled when the PHY is configured for operation over a mixing segment or a 
BEACON is detected.
147.3.7.1 Heartbeat transmit overview
HB signals are sent unsolicited by the PHY that negotiated the master role during auto-negotiation, while the 
slave PHY replies back to received HB signals.
NOTE—Annex K defines optional alternative terminology for “master” and “slave”.
A heartbeat is sent only when the PHY is not in the multidrop mode and Auto-Negotiation has completed. 
The state diagram in Figure 147–10 is held in the INIT state when in the multidrop mode, Auto-Negotiation 
is not enabled, or Auto-Negotiation signals link_control = DISABLE.
When the PHY is not in multidrop mode and a BEACON request is received from the MII (see Table 22–2) 
or a BEACON signal is received from the line (see Table 147–1), the state diagram in Figure 147–10 enters 
the DISABLE_HB state. It remains in the DISABLE_HB state until at least one of the following occurs: 
PCS Reset is asserted, multidrop mode is enabled, the disable_hb_timer expires, Auto-Negotiation is 
disabled, or Auto-Negotiation stops reporting that it is complete.
NOTE—Any BEACON received either from the MII or the PMA restarts the disable_hb_timer.
147.3.7.1.1 Variables
pcs_reset
See 147.3.2.2.
mr_autoneg_enable
See 98.5.1.
link_control
See 147.3.2.2.


multidrop
If MDIO is implemented, this variable is set according to bit 1.2297.10.
If MDIO is not implemented, multidrop should be set by equivalent means.
Values: TRUE or FALSE
master
Result of the role negotiated using method in 98.2.1.2.5 and Table 98–4.
Values: TRUE (negotiated role is master) or FALSE (negotiated role is slave)
hb_cmd
Enumerated variable that conveys the command to send an HB message to the PCS 
transmit function. This command is ignored or interrupted by the PCS transmit function 
when normal data is being sent or a higher priority request is in effect, as specified 
in 147.3.2.4.
Values: HEARTBEAT or NONE
rx_cmd
PLCA or HEARTBEAT signaling decoded by the PCS.
tx_cmd
See 147.3.2.2.
COL
The MII signal COL.
Values: TRUE or FALSE
CRS
The MII signal CRS.
Values: TRUE or FALSE
RX_DV
The MII signal RX_DV.
Values: TRUE or FALSE
147.3.7.1.2 Timers
disable_hb_timer
Time the heartbeat state diagram dwells in the DISABLE_HB state without receiving or 
transmitting a BEACON.
Duration: 1 s
Tolerance: ± 100 ms
hb_send_timer
Times the duration of the HB signal on the line.
Duration: 20 bit times
Tolerance: ± 0.5 bit times
hb_timer
Period between the transmission of two consecutive HB signals.
Duration: 50 ms
Tolerance: ± 100 s


147.3.7.1.3 State diagram
Figure 147–10—Heartbeat transmit state diagram
pcs_reset +
(!mr_autoneg_enable) +
(link_control = DISABLE) +
multidrop
hb_send_timer_done
INIT
!master
master
WAIT_TMR
start hb_timer
hb_cmd  NONE
hb_timer_done*
(!CRS)
TX_HB
start hb_send_timer
hb_cmd  HEARTBEAT
COL
COLLIDE
hb_cmd  NONE
COOLDOWN
start hb_send_timer
!CRS
DISABLE_HB
(!pcs_reset) *
mr_autoneg_enable *
link_control = ENABLE*
(!multidrop) *
((rx_cmd = BEACON) +
(tx_cmd = BEACON))
start disable_hb_timer
hb_send_timer_done*
(!COL)
WAIT_HB
hb_cmd  NONE
WAIT_RX
(rx_cmd = HEARTBEAT) +
RX_DV
WAIT_TX
start hb_send_timer
(rx_cmd = NONE) *
(!RX_DV)
REPLY_HB
start hb_send_timer
hb_cmd  HEARTBEAT
hb_send_timer_done
hb_send_timer_done
disable_hb_timer_done


147.3.7.2 Heartbeat receive overview
The HB receive state diagram in Figure 147–11 generates the pcs_status parameter of the 
PCS_STATUS.indication primitive based on the reception of valid data packets and HB signals from the 
remote PHY.
The pcs_status is reported as OK when at least ACTIVE_CNT valid packets or HB messages, separated at 
max by link_hold_timer ms, are received.
The pcs_status is reported as NOT_OK when PCS is reset or when no valid packets nor HB messages are 
received within link_hold_timer for INACTIVE_CNT times in a row.
147.3.7.2.1 Variables
pcs_reset
See 147.3.2.2.
pcs_status
Parameter of the PCS_STATUS.indication primitive.
Values: OK or NOT_OK
mr_autoneg_enable
See 98.5.1.
link_control
See 147.3.2.2.
multidrop
See 147.3.7.1.1.
rx_cmd
See 147.3.7.1.1.
cnt_l
Count of link_hold_timer expiration periods without HBs or receive packet when 
pcs_status is OK.
Values: integer number between 0 and INACTIVE_CNT
cnt_h
Counter of HBs and receive packets when pcs_status is NOT_OK.
Values: integer number between 0 and ACTIVE_CNT
COL
The MII signal COL.
Values: TRUE or FALSE
CRS
The MII signal CRS.
Values: TRUE or FALSE
RX_DV
The MII signal RX_DV.
Values: TRUE or FALSE


147.3.7.2.2 Constants
ACTIVE_CNT
Number of combined HBs and receive packets required to signal pcs_status = OK.
Value: integer number between 0 and 7
Default value: 2
INACTIVE_CNT
Number of link_hold_timer expirations without HBs or receive packets required to 
signal pcs_status = NOT_OK.
Value: integer number between 0 and 7
Default value: 5
147.3.7.2.3 Timers
link_hold_timer
Timer used to check inactivity.
Duration: 75 ms
Tolerance: ± 100 s
147.3.7.2.4 State diagram
Figure 147–11—Heartbeat receive state diagram
(rx_cmd = HEARTBEAT) +
RX_DV
link_hold_timer_done *
(rx_cmd = NONE) *
(!RX_DV)
(rx_cmd = HEARTBEAT) +
RX_DV
COUNT_UP
start link_hold_timer
cnt_h  cnt_h + 1
B
A
INACTIVE
pcs_status  NOT_OK
cnt_h 0
cnt_l 0
pcs_reset +
(!mr_autoneg_enable) +
(link_control = DISABLE) +
multidrop
COUNT_DOWN
cnt_l  cnt_l + 1
ACTIVE
start link_hold_timer
pcs_status  OK
(rx_cmd = HEARTBEAT) +
RX_DV
cnt_l = INACTIVE_CNT
(rx_cmd = NONE) *
(!RX_DV) *
(!CRS) *
(cnt_h < ACTIVE_CNT)
cnt_h = ACTIVE_CNT
(rx_cmd = NONE) *
(!RX_DV)
link_hold_timer_done *
(rx_cmd  HEARTBEAT) *
(!RX_DV)
HOLD_OFF
HOLD_ON
cnt_l  0
B
A
ELSE


147.4 Physical Medium Attachment (PMA) sublayer
PMA functions are illustrated in Figure 147–12.
The reference diagrams do not explicitly show the PMA Reset function.
The PMA couples messages from the PMA service interface specified in 147.3.1 onto the 10BASE-T1S 
physical medium. The PMA provides half duplex communications to and from the medium. Optionally, the 
PMA may also provide full duplex communications to and from the medium. The interface between PMA 
and the baseband medium is the Medium Dependent Interface (MDI), which is specified in 147.9.
147.4.1 PMA Reset function
The PMA Reset function shall be executed whenever one of the two following conditions occur:
—
Power on (see 36.2.5.1.3).
—
The receipt of a request for reset from the management entity.
The PMA Reset function carries out the following tasks:
—
PMA Transmit output is set to high-impedance state.
—
PMA_UNITDATA.indication is cleared.
147.4.2 PMA Transmit function
During transmission, PMA_UNITDATA.request conveys the tx_sym variable to the PMA. The value of the 
tx_sym variable is sent over the single balanced pair of conductors, BI_DA.
PCS_STATUS.indication (pcs_status)
Figure 147–12—PMA functional block diagram
PMA_UNITDATA.request (tx_sym)
PMA_UNITDATA.indication (rx_sym)
BI_DA+
PMA
PMA
CLOCK
TRANSMIT
RECEIVE
RECOVERY
BI_DA–
received_clock
PMA
SERVICE
MEDIUM
DEPENDENT
(MDI)
INTERFACE
LINK
MONITOR
INTERFACE
PMA_LINK.request (link_control)
Technology Dependent Interface (optional)
PMA_LINK.indication (link_status)
PMA_CARRIER.indication (pma_crs)


The tx_sym variable is a 5B symbol, to be encoded LSB first, using DME rules defined below:
If the tx_sym parameter value is the special 5B symbol 'I', the PMA shall, in the following order:
a)
Transmit an additional DME encoded 0 if the previous value of the tx_sym parameter was anything 
but the 5B symbol 'I'.
b)
When operating in multidrop mode, present the minimum impedance described in 147.9.2 at the 
MDI. This shall happen within 40 ns after the additional DME encoded 0 has been transmitted.
c)
When operating in point-to-point mode, drive BI_DA+ and BI_DA– to the same voltage with 100 
nominal impedance, so that their difference is 0 V.
If tx_sym value is anything other than 'I', the following rules apply:
—
A “clock transition” shall always be generated at the start of each bit.
—
A “data transition” in the middle of a nominal bit period shall be generated if the bit to be 
transmitted is a logical '1'. Otherwise, no transition shall be generated until the next bit.
See Figure 147–13 and Table 147–2.
147.4.3 PMA Receive function
The 10BASE-T1S PMA Receive function comprises a single receiver (PMA Receive) for DME modulated 
signals on a single balanced pair of conductors, BI_DA. PMA Receive has the ability to translate the 
received signals on the single balanced pair of conductors into the PMA_UNITDATA.indication parameter 
rx_sym. It detects 5B symbols from the signals received at the MDI and presents these sequences to the PCS 
Receive function.
Table 147–2—DME timings
Parameter 
name
Description
Minimum 
value
Nominal 
value
Maximum 
value
Unit of 
measure
T1
Delay between transmissions
—
—
ns
T2
Clock transition to clock transition
–100 ppm
+100 ppm
ns
T3
Clock transition to data transition (data = 1)
ns
first transmission
Figure 147–13—DME encoding scheme
T2
T3
clock
transition
next transmission
high-Z or
T1
diff. 0V
clock
transition
data
transition


The PMA Receive function recovers encoded clock and data information from the DME encoded stream 
received at the MDI. The clock recovery provides a synchronous clock for sampling the signal on the pair. 
While it may not drive the MII directly, the clock recovery function is the underlying source of RX_CLK. In 
order to meet the specifications of 147.5.5.1, the PMA Receive function has to achieve proper 
synchronization on both the DME stream and the 5B boundary within 800 ns.
The PMA Receive function interprets the signals at the MDI using the inverse mapping described in 147.4.2 
for the PMA Transmit function and transfers the 5B code groups by the means of the 
PMA_UNITDATA.indication. When the PMA Receive function does not detect activity on the line, it shall 
convey the symbol 'I' (meaning SILENCE).
147.4.4 Link Monitor function
The PMA shall conform to the Link Monitor state diagram in Figure 147–14 and associated variables.
147.4.4.1 Link Monitor overview
The link monitor function generates the link_status parameter of the PMA_LINK.indication primitive for 
the Clause 98 Auto-Negotiation function.
The link_status parameter is set after the result of the PCS_STATUS.indication primitive and the 
implementation defined variable loc_rcv_status.
147.4.4.2 Variables
pma_reset
Allows reset of all PMA functions.
Values: TRUE or FALSE
Set by: PMA Reset function.
link_control
See 147.3.2.2.
loc_rcv_status
Implementation defined variable set to TRUE when the PMA is ready to decode valid 
data from the line, FALSE otherwise.
Values: TRUE or FALSE
(pcs_status = OK)*
loc_rcv_status
Figure 147–14—Link Monitor state diagram
LINK_DOWN
link_status  FAIL
pma_reset +
(link_control = DISABLE)
LINK_UP
link_status  OK
(pcs_status = NOT_OK) +
(!loc_rcv_status)


---

<a id='clause-126'></a>