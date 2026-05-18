# Clause 97: 1000BASE-T1

**Focus**: PCS scrambling, PAM3 mapping, PMA echo canceller, state machines  
**Pages extracted**: 3944 – 4012  
**Excluded from**: Page 4013 (electrical/PICS section)

97. Physical Coding Sublayer (PCS), Physical Medium Attachment (PMA) 
sublayer, and baseband medium, type 1000BASE-T1
97.1 Overview
This clause defines the type 1000BASE-T1 Physical Coding Sublayer (PCS) and type 1000BASE-T1 
Physical Medium Attachment (PMA) sublayer. Together, the PCS and PMA sublayers comprise a 
1000BASE-T1 Physical Layer device (PHY). Provided in this clause are fully functional and electrical 
specifications for the type 1000BASE-T1 PCS and PMA.
The 1000BASE-T1 PHY is one of the Gigabit Ethernet family of high-speed full-duplex PHY 
specifications, capable of operating at 1000 Mb/s. The 1000BASE-T1 PHY is intended to be operated over a 
single twisted-pair copper cable, referred to as an automotive link segment (Type A) or optional link segment
(Type B), defined in 97.6. The automotive link segment specifications defined in 97.6 may also be used for 
other applications that have similar link segment requirements. The cabling supporting the operation of the 
1000BASE-T1 PHY is defined in terms of performance requirements between the attachment points 
[Medium Dependent Interface (MDI)], allowing implementers to provide their own cabling to operate the 
1000BASE-T1 PHY as long as the normative requirements included in this clause are met. 
This clause also specifies an optional Energy-Efficient Ethernet (EEE) capability. A 1000BASE-T1 PHY 
that supports this capability may enter a Low Power Idle (LPI) mode of operation during periods of low link 
utilization as described in Clause 78.
97.1.1 Relationship of 1000BASE-T1 to other standards
The relationship between the 1000BASE-T1 PHY, the ISO Open Systems Interconnection (OSI) Reference 
Model, and the IEEE 802.3 Ethernet Model are shown in Figure 97–1. The PHY sublayers (shown shaded) 
in Figure 97–1 connect one Clause 4 Media Access Control (MAC) layer to the medium. Auto-Negotiation 
for 1000BASE-T1 is defined in Clause 98. GMII is defined in Clause 35. 
97.1.2 Operation of 1000BASE-T1
The 1000BASE-T1 PHY operates using full-duplex communications over a single twisted-pair copper cable 
with an effective rate of 1 Gb/s in each direction simultaneously while meeting the requirements (EMC, 
temperature, etc.) of automotive and industrial environments. The PHY supports operation on two types of 
link segments:
a)
An automotive link segment supporting up to four in-line connectors using a single twisted-pair 
copper cable for up to at least 15 m (referred to as link segment type A)
b)
An optional link segment supporting up to four in-line connectors using a single twisted-pair copper 
cable for up to at least 40 m to support applications requiring extended physical reach, such as indus-
trial and automation controls and transportation (aircraft, railway, bus and heavy trucks). This link 
segment is referred to as link segment type B.
The 1000BASE-T1 PHY utilizes 3 level Pulse Amplitude Modulation (PAM3) transmitted at a 750 MBd 
rate. A 15-bit scrambler is used to improve the EMC performance. GMII TX_D, TX_EN, and TX_ER are 
encoded together using 80B/81B encoding, where 10 cycles of GMII data and control are encoded together 
in 81 bits to reduce the overhead. To maintain a bit error ratio (BER) of less than or equal to 10–10, the 
1000BASE-T1 PHY adds 396 bits of Reed-Solomon forward error correction (RS-FEC) parity to each 


group of 45 80B/81B blocks (containing 450 octets of GMII data). The PAM3 mapping, scrambler, 
RS-FEC, and 80B/81B encoder/decoder are all contained in the PCS (see 97.3).
Auto-Negotiation (Clause 98) may optionally be used by 1000BASE-T1 devices to detect the abilities 
(modes of operation) supported by the device at the other end of a link segment, determine common 
abilities, and configure for normal operation. Auto-Negotiation is performed upon link startup through the 
use of half-duplex differential Manchester encoding. The implementation of the Auto-Negotiation function 
is optional. If Auto-Negotiation is implemented, it shall meet the requirements of Clause 98.
A 1000BASE-T1 PHY shall be capable of operating as MASTER or SLAVE, per runtime configuration. A 
MASTER PHY uses a local clock to determine the timing of transmitter operations. A SLAVE PHY 
recovers the clock from the received signal and uses it to determine the timing of transmitter operations. 
When Auto-Negotiation is used, the MASTER-SLAVE relationship between two devices sharing a link 
segment is established during Auto-Negotiation (see Clause 98). If Auto-Negotiation is not used, a 
MASTER-SLAVE relationship shall be established by management or hardware configuration of the PHYs. 
The MASTER and SLAVE are synchronized by a PHY Link Synchronization function in the PHY (see 
97.4.2.6).
NOTE—Annex K defines optional alternative terminology for “master” and “slave”.
A 1000BASE-T1 PHY may optionally support Energy-Efficient Ethernet (see Clause 78) and advertise the 
EEE capability as described in 97.4.2.4.5. The EEE capability is a mechanism by which 1000BASE-T1 
PHYs are able to reduce power consumption during periods of low link utilization.
The 1000BASE-T1 PHY may optionally support the 1000BASE-T1 PCS-based Operations, Administration, 
and Maintenance (OAM). The 1000BASE-T1 OAM is useful for monitoring link operation by exchanging 
PHY link health status and messages. The 1000BASE-T1 OAM information is exchanged between two 
Figure 97–1—Relationship of 1000BASE-T1 PHY to the ISO/IEC OSI reference model 
and the IEEE 802.3 Ethernet Model
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
GMII = TEN GIGABIT MEDIA INDEPENDENT INTERFACE
PCS = PHYSICAL CODING SUBLAYER
PMA = PHYSICAL MEDIUM ATTACHMENT
PHY = PHYSICAL LAYER DEVICE
GMII1
MDI
1000BASE-T1
PMA
PCS
AN2
MEDIUM
LLC - LOGICAL LINK CONTROL
OR OTHER MAC CLIENT
MAC CONTROL (OPTIONAL)
PHY
NOTE 1—GMII is optional
NOTE 2—Auto-Negotiation is optional
AN = AUTO-NEGOTIATION


1000BASE-T1 PHYs out of band. The 1000BASE-T1 OAM is specified in 97.3.8, and the 1000BASE-T1 
PHY advertises its 1000BASE-T1 OAM capability as described in 97.4.2.4.5.
The 1000BASE-T1 PMA couples messages from the PCS to the MDI and provides clock recovery, link 
management, and PHY Control functions. The PMA provides full duplex communications at 750 MBd over 
the single twisted-pair copper cable. PMA functionality is described in 97.4. The MDI is specified in 97.7.
97.1.2.1 Physical Coding Sublayer (PCS)
The 1000BASE-T1 PCS couples a Gigabit Media Independent Interface (GMII), as described in Clause 35, 
to a Physical Medium Attachment (PMA) sublayer, described in 97.4, which supports communication over a 
single twisted-pair copper cable.
The PCS comprises the PCS Reset function, PCS Transmit, and PCS Receive. After completion of the Reset 
function, the Transmit and Receive functions start immediately and run simultaneously.
The PCS operates in two modes: the data mode and the training mode. In the data mode, the PCS Transmit 
function data path starts with the GMII interface, where TXD, TX_EN, and TX_ER input data to the PCS 
every 8 ns (as clocked by GTX_CLK). Data and control from ten GTX_CLK cycles are 80B/81B encoded 
into an 81-bit “81B block” that encodes every possible combination of data and control (control signals 
include transmit error propagation, receive error, assert low power idle, and inter-frame signaling, as defined 
in 35.2.1.6). Each set of 45 80B/81B blocks along with 9 bits of 1000BASE-T1 OAM data (see 97.3.8) is 
processed by an RS-FEC encoder. The RS-FEC encoder adds 396 RS-FEC parity bits and the resulting 
4050 bits (45 80B/81B blocks = 3645 bits, 9 bits of 1000BASE-T1 OAM, and 396 bits of FEC parity bits) 
are scrambled using a 15-bit side-stream scrambler. The 4050 bits are referred to interchangeably as a PHY 
frame or as a Reed-Solomon frame. Each group of 3 bits of the scrambled data is converted to 2 PAM3 
symbols by the 3B2T mapper (the 4050 bits in the PHY frame become 2700 PAM3 symbols) and passed to 
the PMA. PCS transmit functions are described in 97.3.2.2.
In the data mode, the PCS Receive function data path operates in the opposite order as the transmit path. The 
incoming PAM3 symbols are synchronized to PHY frame boundaries. Within each PHY frame, each two 
PAM3 symbols are demapped to 3 bits by the 3B2T demapper (the 2700 PAM3 symbols are converted to 
4050 bits). The data is then descrambled and passed to the RS-FEC decoder for data validation and 
correction. Finally, each of the 45 80B/81B blocks is 80B/81B decoded into GMII data or control. The PCS 
data mode receive is described in 97.3.2.3.
In the training mode (see 97.4.2.4), the PCS transmits and receives PAM2 training sequences to synchronize 
to the PHY frame, learns the data mode scrambler seed, and exchanges EEE and 1000BASE-T1 OAM
 
capabilities. The training mode uses PAM2 encoding.
97.1.2.2 Physical Medium Attachment (PMA) sublayer
The 1000BASE-T1 PMA transmits/receives symbol streams to/from the PCS onto the single balanced 
twisted-pair and provides the clock recovery, link monitor, and the 1000BASE-T1 PHY Control function. 
The PMA provides full duplex communications at 750 MBd.
The PMA PHY Control function generates signals that control the PCS and PMA sublayer operations. PHY 
Control is enabled following the completion of Auto-Negotiation or PHY Link Synchronization and 
provides the startup functions required for successful 1000BASE-T1 operation. It determines whether the 
PHY operates in a disabled state, a training state, or a data state where MAC frames can be exchanged 
between the link partners.


The Link Monitor determines the status of the underlying link channel and communicates this status to other 
functional blocks. A failure of the receive channel causes the data mode operation to stop and Auto-
Negotiation or Link Synchronization to restart.
The minimum link segment characteristics, EMC requirements, and test modes are specified in 97.5.
97.1.2.3 EEE capability
A 1000BASE-T1 PHY may optionally support the EEE capability, as described in 78.3. The EEE capability 
is a mechanism by which 1000BASE-T1 PHYs are able to reduce power consumption during periods of low 
link utilization. PHYs can enter the LPI mode of operation after completing training. Each direction of the 
full duplex link is able to enter and exit the LPI mode independently, supporting symmetric and asymmetric 
LPI operation. This allows power savings when only one side of the full duplex link is in a period of low 
utilization. The transition to or from LPI mode shall not cause any MAC frames to be lost or corrupted.
In the transmit direction the transition to the LPI transmit mode begins when the PCS transmit function 
detects an “Assert Low Power Idle” condition on the GMII in the last 80B/81B block of a PHY frame. At the 
next PHY frame aligned to the wake window the PCS transmits a sleep signal composed of an entire PHY 
frame containing only LP_IDLE. The sleep signal indicates to the link partner that the transmit function of 
the PHY is entering the LPI transmit mode. Immediately after the transmission of the sleep frame, the 
transmit function of the local PHY enters the LPI transmit mode. While the transmit function is in the LPI 
mode the PHY may disable data path and control logic to save additional power. Periodically the transmit 
function of the local PHY transmits refresh frames that may be used by the link partner to update adaptive 
filters and timing circuits. LPI mode may begin with quiet signaling, a full refresh period, or a wake frame. 
The quiet-refresh cycle continues until the PCS function detects a condition that is not Assert Low Power 
Idle on the GMII. This condition signals to the PHY that the LPI transmit mode should end. At the next PHY 
frame the PCS transmits a wake frame composed of an entire PHY frame containing only Idle. On the next 
PHY frame normal power mode shall resume.
Support for EEE capability is advertised during Training. See 97.4.2.4.5 for details. Transitions to and from 
the LPI transmit mode are controlled via GMII signaling. Transitions to and from the LPI receive mode are 
controlled by the link partner using sleep and wake signaling.
When the 1000BASE-T1 OAM SNR settings indicate that LPI is insufficient to maintain PHY SNR, the 
PHY may temporarily be forced to exit LPI mode and send idles.
The PCS 80B/81B Transmit state diagram in Figure 97–14 includes additional states for EEE. The PCS 
80B/81B Receive state diagram in Figure 97–12 includes additional states for EEE.
97.1.2.4 Link Synchronization
The Link Synchronization function is used when Auto-Negotiation is disabled to synchronize between the 
MASTER PHY and SLAVE PHY before training starts. Link Synchronization provides a fast and reliable 
mechanism for the link partner to detect the presence of the other, validate link, and start the timers used by 
the link monitor. Link Synchronization operates in a half-duplex fashion. Based on timers, the MASTER 
PHY sends a synchronization sequence for 1 µs. If there is no response from the SLAVE, the MASTER 
repeats by sending a synchronization sequence every 5 µs. If the slave detects the sequence, it responds with 
a synchronization sequence for 1 µs (after the MASTER has stopped transmitting). If no other detection 
happens after the SLAVE response for 4 µs then Link Synchronization is successfully complete, link 
monitor timers are started, and the PHY Control state machine starts Training. Link synchronization is 
defined in 97.4.2.6. 


PMA
link_status
Figure 97–2—Functional block diagram
PCS
RECEIVE
RX_CLK
RXD<7:0>
RX_DV
RX_ER
PMA_UNITDATA.request
PMA
RECEIVE
PMA_Link.request
GTX_CLK
TX_EN
TX_ER
loc_rcvr_status
PHY
CONTROL
recovered_clock
tx_mode
config
PMA_UNITDATA.indication
received_clock
TXD<7:0>
TRANSMIT
PCS
LINK
MONITOR
pcs_status / scr_status
(link_control)
PMA_Link.indication
(link_status)
(rx_symb)
(tx_symb)
CLOCK
RECOVERY
PMA
TRANSMIT
INDEPENDENT
INTERFACE
(GMII)
GIGABIT MEDIA
PMA SERVICE
INTERFACE
MEDIUM
INTERFACE
DEPENDENT
(MDI)
PCS
PHY
(INCLUDES PCS AND PMA)
Technology Dependent Interface (optional)
NOTE 1—The recovered_clock arc is shown to indicate delivery of the received clock signal back the PMA TRANSMIT for loop 
timing.
NOTE 2—Signals and functions shown with dashed lines are optional.
rx_lpi_active
MDI +
MDI -
tx_lpi_active
rem_rcvr_status / rem_phy_ready
PCS
OAM
tx_boundary
tx_oam_field<8:0>
rx_oam_field<8:0>
rx_boundary
LINK
SYNCHRO
NIZATION
sync_link_control
loc_phy_ready
sync_tx_symb


97.1.3 Signaling
1000BASE-T1 signaling is performed by the PCS generating continuous symbol sequences that the PMA 
transmits over the single twisted-pair copper cable. The signaling scheme achieves a number of objectives 
including the following:
a)
Algorithmic mapping from TXD<7:0> to PAM3 symbols in the transmit path
b)
Algorithmic mapping from PAM3 symbols to RXD<7:0> in the receive path
c)
Adding FEC coded data to transmit and validating data using FEC on receive
d)
Uncorrelated symbols in the transmitted symbol stream
e)
No correlation between symbol streams traveling both directions
f)
Ability to signal the status of the local receiver to the remote PHY to indicate that the local receiver 
is not operating reliably and requires retraining
g)
Optionally, ability to signal to the remote PHY that the transmitting PHY is entering the LPI mode 
or exiting the LPI mode and returning to normal power operation
The PHY may operate in three basic modes: the normal data mode, the training mode, or an optional LPI 
mode. 
In the normal data mode, PCS generates symbols that represent data, control, or idles for transmission by the 
PMA.
In the training mode, the PCS generates only a PAM2 pattern with periodic embedded data that enables the 
receiver at the other end to train and synchronize timing, scrambler seeds, and capabilities. The LPI mode is 
enabled separately in each direction (see LPI signaling in 97.3.5). When transmitting in LPI mode, the PCS 
generates zero symbols and periodically send a REFRESH pattern to keep the two PHYs synchronized (see 
97.3.2.2.15).
97.1.4 Interfaces
All 1000BASE-T1 PHY implementations are compatible at the MDI and at a physically exposed GMII, if 
made available. Physical implementation of the GMII is optional. Designers are free to implement circuitry 
within the PCS and PMA in an application-dependent manner provided that the MDI and GMII (if the GMII 
is implemented) specifications are met. System operation from the perspective of signals at the MDI and 
management objects are identical whether the GMII is implemented or not.
97.1.5 Conventions in this clause
The body of this clause contains state diagrams, including definitions of variables, constants, and functions. 
Should there be a discrepancy between a state diagram and descriptive text, the state diagram prevails.
The notation used in the state diagrams follows the conventions of 21.5.
The values of all components in test circuits shall be accurate to within ± 1% unless otherwise stated.
Default initializations, unless specified, are left to the implementer.
97.2 1000BASE-T1 Service Primitives and Interfaces
1000BASE-T1 transfers data and control information across the following four service interfaces: 
a)
Gigabit Media Independent Interface (GMII)
b)
Technology Dependent Interface


c)
PMA service interface
d)
Medium dependent interface (MDI)
The GMII is specified in Clause 35; the Technology Dependent Interface is specified in 98.4. The PMA 
service interface is defined in 97.2.2, and the MDI is defined in 97.7.3.
97.2.1 Technology Dependent Interface
1000BASE-T1 uses the following service primitives to exchange status indications and control signals 
across the Technology Dependent Interface as specified in 98.4:
PMA_LINK.request(link_control)
PMA_LINK.indication(link_status)
97.2.1.1 PMA_LINK.request
This primitive allows the Auto-Negotiation or the PHY Link Synchronization algorithm to enable and 
disable operation of the PMA, as specified in 98.4.2, respectively.
97.2.1.1.1 Semantics of the primitive
PMA_LINK.request(link_control)
The link_control parameter can take on one of the following two values: DISABLE, or ENABLE. 
DISABLE
Used by the Auto-Negotiation function to disable the PHY
ENABLE
Used by the Auto-Negotiation to enable the PHY
97.2.1.1.2 When generated
Auto-Negotiation generates this primitive to indicate a change in link_control as described in 98.4.
97.2.1.1.3 Effect of receipt
This primitive affects the operation of the PMA Link Monitor function as defined in 97.4.2.5, the PMA PHY 
Control function as defined in 97.4.2.4, and the PMA Receive function defined in 97.4.2.3.
97.2.1.2 PMA_LINK.indication
This primitive is generated by the PMA to indicate the status of the underlying medium as specified in 
98.4.1. This primitive informs the PCS, PMA PHY Control function, and the Auto-Negotiation functions 
about the status of the underlying link.
97.2.1.2.1 Semantics of the primitive
PMA_LINK.indication(link_status)
The link_status parameter can take on one of the following two values: FAIL or OK.
FAIL
No valid link established.
OK
The Link Monitor function indicates that a valid 1000BASE-T1 link is established.
Reliable reception of signals transmitted from the remote PHY is possible.


97.2.1.2.2 When generated
The PMA generates this primitive to indicate a change in link_status in compliance with the state diagram 
given in Figure 97–27.
97.2.1.2.3 Effect of receipt
The effect of receipt of this primitive is specified in 98.4.1.
97.2.2 PMA service interface
1000BASE-T1 uses the following service primitives to exchange symbol vectors, status indications, and 
control signals across the service interfaces: 
PMA_TXMODE.indication(tx_mode)
PMA_CONFIG.indication(config)
PMA_UNITDATA.request(tx_symb)
PMA_UNITDATA.indication(rx_symb)
PMA_SCRSTATUS.request(scr_status)
PMA_PCSSTATUS.request(pcs_status)
PMA_RXSTATUS.indication(loc_rcvr_status)
PMA_PHYREADY.indication(loc_phy_ready)
PMA_REMRXSTATUS.request(rem_rcvr_status)
PMA_REMPHYREADY.request(rem_phy_ready)
The use of these primitives is illustrated in Figure 97–3. Connections from the management interface 
(signals MDC and MDIO) to the sublayers are pervasive and are not shown in Figure 97–3.
EEE-capable PHYs additionally support the following service primitives:
PMA_PCS_RX_LPI_STATUS.request(rx_lpi_active)
PMA_PCS_TX_LPI_STATUS.request(tx_lpi_active)
97.2.2.1 PMA_TXMODE.indication
The transmitter in a 1000BASE-T1 link normally sends over the MDI symbols that represent a GMII data 
stream with framing, scrambling and encoding of data, control information, or idles. 
97.2.2.1.1 Semantics of the primitive
PMA_TXMODE.indication(tx_mode)
PMA_TXMODE.indication specifies to PCS Transmit via the parameter tx_mode what sequence of 
symbols the PCS should be transmitting. The parameter tx_mode can take on one of the following four 
values of the form:
SEND_NThis value is continuously asserted during transmission of sequences of 
symbols representing a GMII data stream in the data mode
SEND_IThis value is continuously asserted when transmission of sequences of 
idle symbols is to take place
SEND_TThis value is continuously asserted in case transmission of sequences of 
symbols representing the training mode is to take place
SEND_ZThis value is continuously asserted in case transmission of zeros is required


97.2.2.1.2 When generated
The PMA PHY Control function generates PMA_TXMODE.indication messages to indicate a change in 
tx_mode.
97.2.2.1.3 Effect of receipt
Upon receipt of this primitive, the PCS performs its transmit function as described in 97.3.2.2.
Figure 97–3—1000BASE-T1 service interfaces
MDI +
MDI -
 
TXD<7:0>
GTX_CLK
TX_EN
TX_ER
RX_CLK
RXD<7:0>
RX_DV
RX_ER
MDIO
MDC
PMA_TXMODE.indication
PMA_CONFIG.indication
PMA_UNITDATA.indication
PMA_LINK.request 
PMA_RXSTATUS.indication
PMA_LINK.indication 
MEDIUM
INTERFACE
DEPENDENT
(MDI)
PMA_UNITDATA.request
PMA_REMRXSTATUS.request
PMA_SCRSTATUS.request
PMA SERVICE
INTERFACE
INDEPENDENT
INTERFACE
(GMII)
GIGABIT MEDIA
PHY
MANAGEMENT
PMA
PCS
Technology Dependent Interface (optional)
NOTE—Service interface primitives shown with dashed lines are optional.
PMA_PCS_RX_LPI_STATUS.request
PMA_PCSSTATUS.request
PMA_PCS_TX_LPI_STATUS.request
PMA_REMPHYREADY.request
PMA_PHYREADY.indication


97.2.2.2 PMA_CONFIG.indication
Each PHY in a 1000BASE-T1 link is capable of operating as a MASTER PHY and as a SLAVE PHY. If the 
Auto-Negotiation process is enabled, PMA_CONFIG MASTER-SLAVE configuration is determined 
during Auto-Negotiation (Clause 98) and the result is provided to the PMA. If the Auto-Negotiation process 
is not implemented or not enabled, PMA_CONFIG MASTER-SLAVE configuration is predetermined to be 
MASTER or SLAVE via management control during initialization or via default hardware setup. 
97.2.2.2.1 Semantics of the primitive
PMA_CONFIG.indication(config)
PMA_CONFIG.indication specifies to PCS and PMA Transmit via the parameter config whether the PHY 
operates as a MASTER PHY or as a SLAVE PHY. The parameter config can take on one of the following 
two values of the form:
MASTER
This value is continuously asserted when the PHY operates as a MASTER PHY
SLAVE
This value is continuously asserted when the PHY operates as a SLAVE PHY
97.2.2.2.2 When generated
PMA generates PMA_CONFIG.indication messages to indicate a change in configuration.
97.2.2.2.3 Effect of receipt
PCS and PMA Clock Recovery perform their functions in MASTER or SLAVE configuration according to 
the value assumed by the parameter configuration.
97.2.2.3 PMA_UNITDATA.request
This primitive defines the transfer of symbols in the form of the tx_symb parameter from the PCS to the 
PMA. The symbols are obtained in the PCS Transmit function using the encoding rules defined in 97.3.2.2 
to represent GMII data and control streams or other sequences.
97.2.2.3.1 Semantics of the primitive
PMA_UNITDATA.request(tx_symb)
During transmission, the PMA_UNITDATA.request simultaneously conveys to the PMA via the parameter 
tx_symb the value of the symbols to be sent over the MDI. The tx_symb may take on one of the values in the 
set { –1, 0, 1 }
97.2.2.3.2 When generated
The PCS generates PMA_UNITDATA.request(tx_symb) synchronously with every transmit clock cycle. 
97.2.2.3.3 Effect of receipt
Upon receipt of this primitive the PMA transmits on the MDI the signals corresponding to the indicated 
symbols after processing with optional transmit filtering and other specified PMA Transmit processing.


97.2.2.4 PMA_UNITDATA.indication
This primitive defines the transfer of symbols in the form of the rx_symb parameter from the PMA to the 
PCS.
97.2.2.4.1 Semantics of the primitive
PMA_UNITDATA.indication(rx_symb)
During reception the PMA_UNITDATA.indication conveys to the PCS via the parameter rx_symb the value 
of symbols detected on the MDI during each cycle of the recovered clock.
97.2.2.4.2 When generated
The PMA generates PMA_UNITDATA.indication(rx_symb) messages synchronously for every symbol 
received at the MDI. The nominal rate of the PMA_UNITDATA.indication primitive is 750 MHz, as 
governed by the recovered clock.
97.2.2.4.3 Effect of receipt
The effect of receipt of this primitive is unspecified.
97.2.2.5 PMA_SCRSTATUS.request
This primitive is generated by PCS Receive to communicate the status of the descrambler for the local PHY. 
The parameter scr_status conveys to the PMA Receive function the information that the training mode 
descrambler has achieved synchronization.
97.2.2.5.1 Semantics of the primitive
PMA_SCRSTATUS.request(scr_status)
The scr_status parameter can take on one of the following two values of the form:
OK
The training mode descrambler has achieved synchronization
NOT_OK
The training mode descrambler is not synchronized
97.2.2.5.2 When generated
PCS Receive generates PMA_SCRSTATUS.request messages to indicate a change in scr_status.
97.2.2.5.3 Effect of receipt
The effect of receipt of this primitive is specified in 97.4.2.3 and 97.4.2.4.
97.2.2.6 PMA_PCSSTATUS.request
This primitive is generated by PCS Receive to indicate the fully operational state of the PCS for the local 
PHY. The parameter pcs_status conveys to the PMA Receive function the information that the PCS is 
operating reliably in the data mode.
97.2.2.6.1 Semantics of the primitive
PMA_PCSSTATUS.request(pcs_status)


The pcs_status parameter can take on one of the following two values of the form:
OK
The PCS is operating reliably in the data mode
NOT_OK
The PCS is not operating reliably in the data mode
97.2.2.6.2 When generated
PCS Receive generates PMA_PCSSTATUS.request messages to indicate a change in pcs_status. 
97.2.2.6.3 Effect of receipt
The effect of receipt of this primitive is specified in 97.4.4.1.
97.2.2.7 PMA_RXSTATUS.indication
This primitive is generated by PMA Receive to indicate the status of the receive link at the local PHY. The 
parameter loc_rcvr_status conveys to the PCS Transmit, PCS Receive, PMA PHY Control function, and 
Link Monitor the information on whether the status of the overall receive link is satisfactory or not. Note 
that loc_rcvr_status is used by the PCS Receive decoding functions. The criterion for setting the parameter 
loc_rcvr_status is left to the implementer. It can be based, for example, on observing the mean-square error 
at the decision point of the receiver and detecting errors during reception of symbol stream.
97.2.2.7.1 Semantics of the primitive
PMA_RXSTATUS.indication(loc_rcvr_status) 
The loc_rcvr_status parameter can take on one of the following two values of the form: 
OK
This value is asserted and remains true during reliable operation of the receive
link for the local PHY
NOT_OK
This value is asserted whenever operation of the link for the local PHY is unreliable
97.2.2.7.2 When generated
PMA Receive generates PMA_RXSTATUS.indication messages to indicate a change in loc_rcvr_status on 
the basis of signals received at the MDI.
97.2.2.7.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 97–26, 97.3.2.3, 97.4.2.4, and 97.4.5.
97.2.2.8 PMA_PHYREADY.indication
This primitive is generated by PMA Receive to indicate the local PHY is ready or not ready to receive data. 
The parameter loc_phy_ready is conveyed to the link partner by the PCS as defined in Table 97–1.
97.2.2.8.1 Semantics of the primitive
PMA_PHYREADY.indication(loc_phy_ready)
The loc_phy_ready parameter can take on one of the following two values of the form:
OK
The local PHY is ready to receive data
NOT_OK
The local PHY is not ready to receive data


97.2.2.8.2 When generated
PMA Receive generates PMA_PHYREADY.indication messages to indicate a change in loc_phy_ready 
based on loc_rcvr_status and pcs_status values.
97.2.2.8.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 97–26 and Figure 97–27.
97.2.2.9 PMA_REMRXSTATUS.request
This primitive is generated by PCS Receive to indicate the status of the receive link at the remote PHY as 
communicated by the remote PHY via its encoding of its loc_rcvr_status parameter. The parameter 
rem_rcvr_status conveys to the PMA PHY Control function the information on whether reliable operation of 
the remote PHY is detected or not. The parameter rem_rcvr_status is set to the value received in the 
loc_rcvr_status bit in the InfoField from the remote PHY. The rem_rcvr_status is set to NOT_OK if the PCS 
has not decoded a valid InfoField from the remote PHY.
97.2.2.9.1 Semantics of the primitive
PMA_REMRXSTATUS.request(rem_rcvr_status)
The rem_rcvr_status parameter can take on one of the following two values of the form:
OK
The receive link for the remote PHY is operating reliably
NOT_OK
Reliable operation of the receive link for the remote PHY is not detected
97.2.2.9.2 When generated
The PCS generates PMA_REMRXSTATUS.request messages to indicate a change in rem_rcvr_status based 
on the PCS decoding the loc_rcvr_status bit in InfoField messages received from the remote PHY during 
training.
97.2.2.9.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 97–26.
97.2.2.10 PMA_REMPHYREADY.request
This primitive is generated by PCS Receive to indicate whether the remote PHY is ready or not ready to 
receive data. Its value is received from the link partner by the PCS as defined in Table 97–1.
97.2.2.10.1 Semantics of the primitive
PMA_REMPHYREADY.request(rem_phy_ready)
The rem_phy_ready parameter can take on one of the following two values of the form:
OK
The remote PHY is ready to receive data
NOT_OK
The remote PHY is not ready to receive data


97.2.2.10.2 When generated
The PCS generates PMA_REMPHYREADY.request messages to indicate a change in rem_phy_ready 
based on the PCS decoding the control words in Table 97–1 received from the remote PHY.
97.2.2.10.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 97–26.
97.2.2.11 PMA_PCS_RX_LPI_STATUS.request
When the PHY supports the EEE capability this primitive is generated by the PCS receive function to 
indicate 
the 
status 
of 
the 
receive 
link 
at 
the 
local 
PHY. 
The 
parameter 
PMA_PCS_RX_LPI_STATUS.request conveys to the PCS transmit and PMA receive functions 
information regarding whether the receive function is in the LPI receive mode.
97.2.2.11.1 Semantics of the primitive
PMA_PCS_RX_LPI_STATUS.request(rx_lpi_active)
The rx_lpi_active parameter can take on one of the following two values of the form:
true 
The receive function is in the LPI receive mode
false 
The receive function is not in the LPI receive mode
97.2.2.11.2 When generated
The PCS generates PMA_PCS_RX_LPI_STATUS.request messages to indicate a change in the 
rx_lpi_active variable as described in 97.3.2.3 and 97.3.6.2.2.
97.2.2.11.3 Effect of receipt
The effect of receipt of this primitive is specified in 97.3.6.4.
97.2.2.12 PMA_PCS_TX_LPI_STATUS.request
When the PHY supports the EEE capability this primitive is generated by the PCS transmit function to 
indicate 
the 
status 
of 
the 
transmit 
link 
at 
the 
local 
PHY. 
The 
parameter 
PMA_PCS_TX_LPI_STATUS.request conveys to the PCS transmit and PMA receive functions information 
regarding whether the transmit function is in the LPI transmit mode.
97.2.2.12.1 Semantics of the primitive
PMA_PCS_TX_LPI_STATUS.request(tx_lpi_active)
The tx_lpi_active parameter can take on one of the following two values of the form:
true 
The transmit function is in the LPI transmit mode
false 
The transmit function is not in the LPI transmit mode
97.2.2.12.2 When generated
The PCS generates PMA_PCS_TX_LPI_STATUS.request messages to indicate a change in the 
tx_lpi_active variable as described in 97.3.5 and 97.3.6.2.2. 


97.2.2.12.3 Effect of receipt
The effect of receipt of this primitive is specified in 97.3.6.4.
97.3 Physical Coding Sublayer (PCS)
97.3.1 PCS service interface (GMII)
The PCS service interface allows the 1000BASE-T1 PCS to transfer information to and from a PCS client. 
The PCS Interface is defined as the Gigabit Media Independent Interface (GMII) in Clause 35.
97.3.2 PCS functions
The PCS comprises one PCS Reset function and two simultaneous and asynchronous operating functions. 
The PCS operating functions are: PCS Transmit and PCS Receive. All operating functions start immediately 
after the successful completion of the PCS Reset function. 
The PCS reference diagram, Figure 97–4, shows how the two operating functions relate to the messages of 
the PCS-PMA interface. Connections from the management interface (signals MDC and MDIO) to other 
layers are pervasive and are not shown in Figure 97–4.
97.3.2.1 PCS Reset function
PCS Reset initializes all PCS functions. The PCS Reset function shall be executed whenever one of the 
following conditions occur:
a)
Power for the device containing the PMA has not reached the operating state
b)
The receipt of a request for reset from the management entity
PCS Reset sets pcs_reset = ON while any of the above reset conditions hold true. All state diagrams take the 
open-ended pcs_reset branch upon execution of PCS Reset. The reference diagrams do not explicitly show 
the PCS Reset function.
The control and management interface shall be restored to operation within 10 ms from the setting of 
bit 3.2304.15.
97.3.2.2 PCS Transmit function
The PCS Transmit function shall conform to the PCS 80B/81B Transmit state diagram in Figure 97–14 and 
the PCS Transmit bit ordering in Figure 97–5 and Figure 97–7.
When communicating with the GMII, the PCS uses an octet-wide, synchronous data path, with packet 
delimiting being provided by transmit control signals and receive control signals. Alignment to 80B/81B 
blocks is performed in the PCS. The PMA sublayer operates independently of block and packet boundaries. 
The PCS provides the functions necessary to map packets between the GMII format and the PMA service 
interface format.
When the transmit channel is in the data mode, the PCS Transmit process continuously generates 80B/81B 
blocks based upon the TXD <7:0>, TX_EN and TX_ER signals on the GMII. The subsequent functions of 
the PCS Transmit process then pack the resulting blocks plus one 1000BASE-T1 OAM symbol, both of 
which are then processed by a Reed-Solomon (RS-FEC) encoder and subsequently 3B2T mapped into a 
transmit PHY frame of PAM3 symbols. Transmit data-units are sent to the PMA service interface via the 
PMA_UNITDATA.request primitive. A symbol period, T, is 4/3 ns.


If a PMA_TXMODE.indication message has the value SEND_T, PCS Transmit generates sequences of 
codes defined in 97.3.4.2 to the PMA via the PMA_UNITDATA.request primitive. These codes are used for 
training mode and only transmit the values {–1, +1}.
During training mode an InfoField is transmitted at regular intervals containing messages for startup 
operation. By this mechanism, a PHY indicates the status of its own receiver to the link partner. (See 
97.4.2.4.)
In the data mode of operation, the PMA_TXMODE.indication message has the value SEND_N, and the 
PCS Transmit function uses an 81B-RS coding technique to generate at each symbol period symbols that 
represent data or control. During transmission, 45 80B/81B blocks shall be aggregated, encoded by a PHY 
frame encoder, and then scrambled by a PCS scrambler. During data encoding PCS Transmit frames shall be 
encoded into a sequence of PAM3 symbols and transferred to the PMA.
Dashed rectangles in Figure 97–14 indicate states and state transitions in the transmit process state diagram 
that are supported by PHYs with the EEE capability. PHYs without the EEE capability do not support these 
transitions.
Figure 97–4—PCS reference diagram
loc_phy_ready
RECEIVE
PCS
GIGABIT MEDIA INDEPENDENT
INTERFACE (GMII)
TRANSMIT
PCS
tx_mode
tx_symb
tx_lpi_active
TX_ER
GTX_CLK
TX_EN
TXD<7:0>
scr_status / pcs_status
rx_symb
config
rem_rcvr_status / rem_phy_ready
loc_rcvr_status
link_status
rx_lpi_active
RX_ER
RX_CLK
RX_DV
RXD<7:0>
PMA SERVICE
INTERFACE
PCS
OAM
PCS
rx_boundary
rx_oam_field<8:0>
tx_boundary
tx_oam_field<8:0>


After reaching the data mode of operation, EEE-capable PHYs may enter the LPI transmit mode under the 
control of the MAC via the GMII. The EEE Transmit state diagram is contained within the PCS Transmit 
function. The EEE capability is described in 97.3.2.2.15.
97.3.2.2.1 Use of blocks
The PCS maps GMII signals into 81-bit blocks inserted into a PHY frame, and vice versa, using an 81B-RS 
coding scheme. The PAM2 PMA training frame synchronization allows establishment of PHY frame and 
81B boundaries by the PCS Synchronization process. Blocks and PHY frames are unobservable and have no 
meaning outside the PCS. The PCS functions ENCODE and DECODE generate, manipulate, and interpret 
blocks and PHY frames as provided by the rules in 97.3.2.2.2.
97.3.2.2.2 81B-RS transmission code
The PCS uses a transmission code to improve the transmission characteristics of information to be 
transferred across the link and to support transmission of control and data characters. The encoding defined 
by the transmission code ensures that sufficient information is present in the PHY bit stream to make clock 
recovery possible at the receiver. The encoding also preserves the likelihood of detecting any PHY frame 
errors that may occur during transmission and reception of information. In addition, the code enables the 
receiver to achieve PCS synchronization alignment on the incoming PHY bit stream.
The relationship of block bit positions to GMII, PMA, and other PCS constructs is illustrated in Figure 97–5 
for transmit and Figure 97–6 for receive. These figures illustrate the processing of a multiplicity of blocks 
containing 10 data octets. See 97.3.2.2.5 for information on how blocks containing control characters are 
mapped. 
97.3.2.2.3 Notation conventions
For values shown as binary, the leftmost bit is the first transmitted bit.
97.3.2.2.4 Transmission order
The PCS Transmit bit ordering shall conform to Figure 97–5 and Figure 97–7. Note that these figures show 
the mapping from GMII to 80B/81B block for a block containing ten data characters. The LSB of the 
1000BASE-T1 OAM symbol is transmitted first. 
97.3.2.2.5 Block structure
Blocks consist of 81 bits. The first bit of a block is the data/ctrl header. Blocks are either data blocks or 
control blocks. The data/ctrl header is 0 for data blocks and 1 for control blocks. The remainder of the block 
contains the payload.
Data blocks contain 10 data octets. Control blocks begin with a 5-bit pointer field that indicates the location 
of the first control code within the block. Bits 0 to 3 of the pointer field points to the next octet that is a 
control symbol. Bit 4 of the pointer field indicates whether the next control symbol is the final control 
symbol of the block: 0 = final, 1 = more control symbols. If the first octet in the block is a control character, 
the pointer field is followed by a 3-bit control code. Otherwise the pointer field is followed by one or more 
data octets until the position of the first control code. Then the 3-bit control code indicates type of control 
character. The control code is followed by a 5-bit pointer field to the next control character if the prior 
pointer field value was greater than 15 (i.e., bit 4 = 1). The pointer field may be followed by a data octet or 
control code depending on the value of the pointer field. In this way any combination of ten data octets and 
control characters may be encapsulated within an 80B/81B block.


Figure 97–5—PCS Transmit bit ordering
GMII
TXD<0>
1st transfer
Output of encoder
D0
D1
D2
D9
PMA service
function 
Data/Ctrl
header
RS-FEC frame
interface
TXD<7>
2nd transfer
3rd transfer
10th transfer
TXB<0>
TXB<80>
LSB
Reed-Solomon FEC Encode
OAM
RSC<43>
RSC<0>
RSD<405>
RSD<404>
RSD<0>
Data mode Tx scrambler
3B2T mapper
PAM3
<2699>
PAM3
<1000>
PAM3
<0>
PAM3
<1>
PAM3
<2>
Aggregate 45 x 80B/81B blocks, plus OAM
80B/81B block
 80B/81B 
block 2
 80B/81B 
block 1
 80B/81B 
block 45


 
Figure 97–6—PCS Receive bit ordering
GMII
RXD<0>
1st transfer
Input to decoder
D0
D1
D2
D9
PMA service
function 80B/81B block
Data/Ctrl
header
RS-FEC decoded
interface
RXD<7>
2nd transfer
3rd transfer
10th transfer
RXB<0>
RXB<80>
Reed-Solomon FEC Decode
Data mode Rx scrambler
3B2T demapper
rx PAM3
<1000>
rx PAM3
<0>
rx PAM3
<1>
rx PAM3
<2>
Aggregate 45 x 80B/81B blocks, extract OAM
frame
rx RSC
rx RSC
rx RSD
rx RSD
rx RSD
RS-FEC received
frame
Frame Sync
rx_data-group<0:2699>
rx PAM3
<2699>
<0>
<40>
<40>
<0>
<43
OAM
 80B/81B 
block 2
 80B/81B 
block 1
 80B/81B 
block 45


The 80B/81B block encoding is defined by the following pseudo-code, where N = 10.
N = number of GMII octets encoded into block. Octets numbered n = 0,1,2,…,N–1. 
octet 0 is the first one presented on GMII.
TC[n] = 0 if octet n is data octet on GMII, 1 if octet n is control octet on GMII
TC[–1] = 1 by definition
TD[n][0:7] = GMII octet n TXD[0:7] if TC[n] = 0
TD[n][5:7] = 010 – IPG (loc_phy_ready = OK), 101 – LPI, 001 – TX Error, 000 – IPG 
(loc_phy_ready = NOT_OK) if TC[n] = 1. TD[n][0:4] is undefined.
B[0:8N] is the 8N+1 block. Bit 0 transmitted first.
OR(n) = Bitwise OR of TC[n:N–1]
NEXT(n)[0:3] = bit position of lowest bit in TC[n:N–1] that is a 1. Bit 3 is MSB. 
NEXT(n)[4] = 0 if Bitwise SUM of TC[n:N–1] = 1, else 1
B[0] = 
OR(0)
B[8n+1:8n+4] = 
TD[n][0:3] – if OR(n) = 0
NEXT(n)[0:3] – if OR(n) = 1 AND TC[n–1] = 1
TD[n–1][3:6] – if OR(n) = 1 AND TC[n–1] = 0
B[8n+5] =
TD[n][4] – if OR(n) = 0
NEXT(n)[4] – if OR(n) = 1 AND TC[n–1] = 1
TD[n–1][7] – if OR(n) = 1 AND TC[n–1] = 0
B[8n+6:8n+8] = 
TD[n][5:7] – if OR(n) = 0
TD[n][5:7] – if OR(n) = 1 AND TC[n] = 1
TD[n][0:2] – if OR(n) = 1 AND TC[n] = 0
97.3.2.2.6 Control codes
A subset of control characters defined at the GMII are supported by the 1000BASE-T1 PCS. When TX_ER 
and TX_EN are both asserted, the 1000BASE-T1 PCS conveys an Error symbol in the 80B/81B block code. 
When TX_EN is not asserted and no other supported control code is present at the GMII, the 1000BASE-T1 
PCS conveys a Normal Inter-Frame control code in the 80B/81B block code.
Figure 97–7—PCS detailed transmit bit ordering
XOR
81B block 1
81B block 2
81B block 45
RS-FEC symbol
RS-FEC symbol
RS-FEC symbol
RS-FEC symbol
OAM
3645:3653
PCS 
RS ENC 
output
output
symb #
bit #
scrambler
scr [0:4049]
Binary
Binary
Binary
Binary
Binary
3645:3653
scrambler
output
bit #
Ternary
Ternary
Ternary
Ternary
Ternary
2430:2435


The control characters and their mappings to 1000BASE-T1 control code and GMII control code are 
specified in Table 97–1. All GMII and 1000BASE-T1 control code values that do not appear in the table 
shall not be transmitted and shall be treated as an error if received. 
The Carrier Extend and Carrier Extend Error, and Reserved transactions, if any occurred, are assigned to 
Normal inter-frame in the PCS 80B/81B Encoder. 
97.3.2.2.7 Idle
Idle (Normal Inter-frame) control characters are transmitted when TX_EN is not asserted and no other 
supported control code is present at the GMII. Idle characters may be added or deleted by the PCS to adapt 
between clock rates. Idle characters shall not be added within a MAC frame.
97.3.2.2.8 LP_IDLE
The low power idle control characters (LP_IDLEs) are transmitted when TX_EN is not asserted, TX_ER is 
asserted, and TXD<7:0> = 0x1. A continuous stream of LPI control characters is used to maintain a link in 
the LPI transmit mode. Idle control characters are used to transition from the LPI transmit mode to the 
normal power mode. EEE compliant PHYs respond to the Assert Low Power Idle condition on the GMII 
using the procedure outlined in 97.1.2.3. LP_IDLE characters may be added or deleted by the PCS to adapt 
between clock rates. LP_IDLE characters shall not be added within a MAC frame.
Where the GMII and PMA sublayer data rates are not synchronized, the transmit process needs to insert 
LPI_IDLEs, or delete LPI_IDLEs to adapt between the rates.
If EEE is not supported, then LP_IDLE shall be converted to IDLE.
97.3.2.2.9 Error
The Error control code is sent when TX_ER and TX_EN are both asserted. Error allows physical sublayers 
such as the PCS to propagate received errors. 
97.3.2.2.10 Transmit process
The transmit process generates blocks based upon the TXD<7:0>, TX_EN, and TX_ER signals received 
from the GMII. Ten GMII data transfers are encoded into each block. It takes 2700 PMA_UNITDATA 
transfers to send a PHY frame of data. Where the GMII and PMA sublayer data rates are not synchronized to 
that ratio, the transmit process needs to insert idles, or delete idles to adapt between the rates.
Table 97–1—GMII control code mapping
Control Code[0:2]
GMII Transmit
GMII Receive
Normal Inter-Frame with 
loc_phy_ready = NOT_OK
Normal Inter-Frame with 
rem_phy_ready = NOT_OK
Transmit Error 
Propagation
Data Reception Error
Normal Inter-Frame with 
loc_phy_ready = OK
Normal Inter-Frame with 
rem_phy_ready = OK
Assert Low Power Idle
Assert Low Power Idle


The transmit process generates blocks as specified in the transmit process state diagram. The contents of 
each block are contained in a vector tx_coded<80:0>, which is aggregated with 45 80B/81B blocks and 
1000BASE-T1 OAM, then passed to the RS-FEC Encoder and then finally passed to the scrambler. 
tx_coded<0> contains the data/ctrl header and the remainder of the bits contain the block payload.
97.3.2.2.11 RS-FEC encoder
The 1000BASE-T1 PCS shall encode the transmitted data stream using Reed-Solomon code (450,406). The 
RS-FEC encoder shall follow the bit order described in 97.3.2.2.3 where the LSB is the first bit into the RS-
FEC encoder and the first transmitted bit.
The FEC code used for 1000BASE-T1 links is a shortened Reed-Solomon (450,406) code over the Galois 
Field of GF(29)—a code operating on 9-bit symbols, as shown in Figure 97–8. The code encodes 
406 information symbols and adds 44 parity symbols, enabling correction of up to 22 symbol errors. The 
code is systematic, meaning that the information symbols are not disturbed in any way in the encoder and 
the parity symbols are added separately to each block. 
The code is based on the generating polynomial shown in Equation (97–1).
(97–1)
where
 is a root of the binary primitive polynomial x9 + x4 + 1 and is represented as 0x002
A is a series representing the resulting polynomial coefficients of G(Z), (A44 is equal to 0x001)
Z corresponds to an 9-bit GF(29) symbol
x corresponds to a bit position in a GF(29) symbol
The parity calculation shall produce the same result as the shift register implementation shown in Figure 97–8. 
Before calculation begins, the shift register shall be initialized to zero. The contents of the shift register are 
transmitted without inversion.
An FEC parity vector is represented by Equation (97–2).
(97–2)
where
 is the data vector 
.  
is the first 9-bit data symbol and 
 is the last
 is the parity vector 
.
 is the first 9-bit parity symbol and 
 is 
the last
A data symbol (d8, d7, ...., d1, d0) is identified with the element: d88 + d77 + .... + d11 + d0 in GF(29), the 
finite field with 29 elements. 
The d0 is identified as the LSB and d8 is identified as the MSB for all symbols.
The resulting payload of scrambled 45 80B/81B blocks, followed by the 1000BASE-T1 OAM symbol 
results in a total payload of 3654 bits. The resulting PHY frame size is 450 9-bit symbols, a total of 
4050 bits. Figure 97–7 shows the bit mapping between PCS and FEC.
G Z

Z
i
–


A44Z44
A43Z43

A0Z0
+
+
+
=
i
=

=
P Z

D Z
 mod G Z

=
D Z

D Z

D405Z449
D404Z448

D0Z44
+
+
+
=
D405
D0
P Z

P Z

P43Z43
P42Z42
P0Z0
+
+
=
P43
P0


97.3.2.2.12 PCS scrambler
The PCS Transmit function employs side-stream scrambling. The scrambler for the MASTER shall produce 
the same result as the implementation shown in Figure 97–9. This implements the scrambler polynomial as 
shown in Equation (97–3):169
(97–3)
The scrambler for the SLAVE shall produce the same result as the implementation shown in Figure 97–9. 
This implements the scrambler polynomial as shown in Equation (97–4):
(97–4)
The initial seed values for the MASTER and SLAVE scramblers are left to the implementer. The seed values 
shall be non-zero and transmitted during the InfoField exchange. (See 97.4.2.4.5). The scrambler is run 
continuously on all PHY frame output bits. 
97.3.2.2.13 3B2T to PAM3
The 3B2T mapper generates 2700 PAM3 symbols per PHY frame that are sent to the PMA via 
PMA_UNITDATA.request. Every 9-bit symbol is divided into three 3-bit groups with the LSB bits as the 
first group. Each 3-bit group is then mapped by the 3B2T into 2 PAM3 symbols. The mapping of 3B2T to 
PAM3 is illustrated in Table 97–2. B[0] is the LSB and T[0] is the first PAM3 symbol transmitted..
169The convention here, which considers the most recent bit into the scrambler to be the lowest order term, is consistent with most 
references and with other scramblers shown in this standard. Some references consider the most recent bit into the scrambler to be the 
highest order term and would therefore identify this as the inverse of the polynomial in Equation (97–3). In case of doubt, note that the 
conformance requirement is based on the representation of the scrambler in the figure rather than the polynomial equation.
Figure 97–8—Circuit for generating FEC parity vector
*A0
*A1
GF
Multiply
+
GF
Add
P0
*A2
+
P1
*A43
+
P42
*A44
+
P43
GF(29)
SR
D405,D404, ... D1,D0
G x

x4
x15
+
+
=
G x

x11
x15
+
+
=
Figure 97–9—MASTER and SLAVE PCS scramblers
PCS scrambler employed by the SLAVE
PCS scrambler employed by the MASTER
S0
S1
S2
S3
S4
S5
S6
S7
S8
S9
S10
S11
S12
S13
S14
+
S0
S1
S2
S3
S4
S5
S6
S7
S8
S9
S10
S11
S12
S13
S14
+


97.3.2.2.14 81B-RS framer
The 81B-RS framer adapts between the 81-bit width of the 80B/81B blocks and the PAM3 input to the 
PMA. When the transmit channel is operating in the data mode, the 81B-RS sends one PAM3 symbol of 
transmit data at a time via PMA_UNITDATA.request primitives. The PMA_UNITDATA.request primitives 
are fully packed with bits. 
97.3.2.2.15 EEE capability
The optional 1000BASE-T1 EEE capability allows compliant PHYs to transition to an LPI mode of 
operation when link utilization is low. EEE compliant PHYs shall implement the transmit state diagram 
including the EEE portion, noted by dotted lines in Figure 97–14, within the PCS.
When there is an Assert Low Power Idle while in the SEND_DATA state the PHY transmits the sleep signal 
to indicate to the link partner that it is transitioning to the SEND_LPI state. The sleep signal is one PHY 
frame composed entirely of LP_IDLE characters. If the LP_IDLE character fills the entire last 80B/81B 
block then the sleep signal is the next PHY frame. The PHY shall transmit no PHY frames partially filled 
with LP_IDLES.
Following the transmission of the sleep signal, quiet-refresh signaling begins, as described in 97.3.5. 
While the PMA asserts SEND_N, the lpi_tx_mode variable shall control the transmit signal through the 
PMA_UNITDATA.request primitive described as follows: 
—
When the PMA_TXMODE.indication message does not have the value of SEND_N, the 
lpi_tx_mode variable is ignored
—
When the lpi_tx_mode variable takes the value NORMAL the PCS passes coded data to the PMA 
via the PMA_UNITDATA.request primitive
—
When the lpi_tx_mode variable takes the value QUIET the PCS passes zeros to the PMA through the 
PMA_UNITDATA.request primitive
—
When the lpi_tx_mode variable takes the value REFRESH, the PCS passes zero data encoded 
through PCS data path to the PMA via the PMA_UNITDATA.request primitive
The quiet-refresh cycle is repeated until Assert Low Power Idle is not detected at the GMII (indicating that 
the local system is requesting a transition back to the normal power mode) or until an 1000BASE-T1 OAM
 
Table 97–2—3B2T Mapping to PAM3
B[2], B[1], B[0]
T[1], T[0]
–1,–1
0,–1
–1,0
–1,+1
+1,0
+1,–1
+1,+1
0,+1


message with SNR<1:0> set to 01 is transmitted to or received from the link partner (indicating that the LPI 
refresh is insufficient to maintain the SNR). At the next wake frame window the PCS transmits a wake 
frame composed of an entire PHY frame containing only Idle. The wake frame shall be sent only during 
alternating PHY frame counts.
The wake signal occurs at the beginning of every second PHY frame boundary, and the maximum duration 
of the PHY wake time is 10.8 s (lpi_wake_timer = Tw_phy as defined by Clause 78).
97.3.2.3 PCS Receive function
The PCS Receive function shall conform to the PCS 80B/81B receive state diagram in Figure 97–12 and the 
PCS Receive bit ordering in Figure 97–6 including compliance with the associated state variables as 
specified in 97.3.6.
The PCS Receive function accepts received symbols provided by the PMA Receive function via the 
parameter rx_symb. The PCS receiver uses knowledge of the PMA training alignment to correctly align the 
81B-RS frames. The received 81B-RS frames are decoded with error correction; the framing is checked; and 
the 80B/81B blocks are converted to 10 data octets to obtain the signals RXD<7:0>, RX_DV, and RX_ER 
for transmission to the GMII. 
During PMA training mode, PCS Receive checks the received PAM2 framing and signals the reliable 
acquisition of the descrambler state by setting the parameter scr_status to OK.
When the PCS Synchronization process has obtained synchronization, the PHY frame error rate (RFER) 
monitor process monitors the signal quality asserting hi_rfer if excessive PHY frame errors are detected (RS 
parity error). If 40 consecutive PHY frame errors are detected, the block_lock flag is de-asserted. When 
block_lock is asserted and hi_rfer is de-asserted, the PCS Receive process continuously accepts blocks. The 
PCS Receive process monitors these blocks and generates RXD<7:0>, RX_DV and RX_ER for 
transmission to the GMII.
When the receive channel is in training mode, the PCS Synchronization process continuously monitors 
PMA_RXSTATUS.indication(loc_rcvr_status). When loc_rcvr_status indicates OK, then the PCS 
Synchronization process accepts data-units via the PMA_UNITDATA.request primitive. It attains PHY 
frame and block synchronization based on the PMA training frames and conveys received blocks to the PCS 
Receive process. The PCS Synchronization process sets the block_lock flag to indicate whether the PCS has 
obtained synchronization. The PMA training sequence includes 1 bit pattern every 180 PAM2 symbols, 
which is aligned with the PCS partial PHY frame boundary, as well as an InfoField, which is inserted in the 
15th PCS partial PHY frame. When the PCS Synchronization process is synchronized to the PHY frame 
boundary using this pattern, block_lock is asserted. One partial PHY frame codeword is defined to be 1/15 
of a PHY frame. Fifteen partial PHY frames concatenated back to back form one PHY frame. The start of 
the first partial PHY frame coincides with the start of the PHY frame.
PHYs with the EEE capability support transition to the LPI mode when the PHY has successfully completed 
training. Transitions to and from the LPI mode are allowed to occur independently in the transmit and 
receive functions. The PCS receive function is responsible for detecting transitions to and from the LPI 
receive mode and indicating these transitions using signals defined in 97.3.6. 
The link partner signals a transition to the LPI mode of operation by transmitting one PHY frame composed 
entirely of 80B/81B blocks of LP_IDLES. When blocks of LP_IDLES are detected at the output of the 
80B/81B decoder, rx_lpi_active is asserted by the PCS receive function and the LPI character is 
continuously asserted at the receive GMII. After the sleep frame the link partner begins transmitting zeros, 
and it is recommended that the receiver power down receive circuits to reduce power consumption. The 
receive function uses PHY frame counters to maintain synchronization with the remote PHY and receives 
periodic refresh signals that are used to update coefficients, so that the integrity of adaptive filters and timing 


loops in the PMA is maintained. LPI signaling is defined in 97.3.5. The quiet-refresh cycle continues until 
the PHY detects the wake frame. The PHY receive function sends Idles to the GMII for the remainder of the 
wake frame and then resumes normal power mode operation.
97.3.2.3.1 Frame and block synchronization
When operating in the data mode, the receiving PCS shall form a PAM3 stream from the 
PMA_UNITDATA.indication primitive by concatenating requests in order from rx_data<0> to 
rx_data<2699> (see Figure 97–6). It obtains block lock to the PHY frames during the PAM2 training pattern 
using synchronization bits provided in the training sequence.
97.3.2.3.2 PCS descrambler
The descrambler processes the payload to reverse the effect of the scrambler using the same polynomial. 
The PCS descrambles the data stream and returns the proper sequence of symbols to the decoding process 
for generation of RXD<7:0> to the GMII. For side-stream descrambling, the MASTER PHY shall employ 
the receiver descrambler generator polynomial per Equation (97–4) and the SLAVE PHY shall employ the 
receiver descrambler generator polynomial per Equation (97–3).
97.3.2.3.3 Valid and invalid blocks
An 80B/81B block is invalid if any of the following conditions exists:
a)
The block contains an invalid pointer
b)
Any control character contains a value not in Table 97–1
c)
The PHY frame containing this 80B/81B block is uncorrectable
Invalid blocks are replaced with Error.
97.3.3 Test-pattern generators
The test-pattern generator mode is provided for enabling joint testing of the local transmitter, the channel 
and remote receiver. When the transmit PCS is operating in test-pattern mode it shall transmit continuously 
as illustrated in Figure 97–5, with the input to the RS-FEC encoder set to zero and the initial condition of the 
scrambler set to any non-zero value. This has the same effect as setting the input to the scrambler to zero. 
When the receiver PCS is operating in test-pattern mode it shall receive continuously as illustrated in 
Figure 97–6. The output of the received descrambled values should be zero. Any nonzero values correspond 
to receiver bit errors. The output of the RS-FEC decoder should also be zero, however there is the possibility 
that the RS-FEC decoder may have corrected some errors. This mode is further described as test mode 7 in 
97.5.2.
97.3.4 PMA training side-stream scrambler polynomials
The PCS Transmit function employs side-stream scrambling. If the parameter config provided to the PCS by 
the PMA PHY Control function via the PMA_CONFIG.indication message assumes the value MASTER, 
PCS Transmit shall employ Equation (97–5)
(97–5)
as transmitter side-stream scrambler generator polynomial. If the PMA_CONFIG.indication message 
assumes the value of SLAVE, PCS Transmit shall employ Equation (97–6)
(97–6)
gM x

x13
x
+
+
=
gS x

x20
x33
+
+
=


as transmitter side-stream scrambler generator polynomial. An implementation of MASTER and SLAVE 
PHY side-stream scramblers by linear-feedback shift registers is shown in Figure 97–9. The bits stored in 
the shift register delay line at time n are denoted by Scrn[32:0]. At each symbol period, the shift register is 
advanced by one bit, and one new bit represented by Scrn[0] is generated. The transmitter side-stream 
scrambler is reset upon execution of the PCS Reset function. If PCS Reset is executed, all bits of the 33-bit 
vector representing the side-stream scrambler state are arbitrarily set. The initialization of the scrambler state 
is left to the implementer. In no case shall the scrambler state be initialized to all zeros. 
97.3.4.1 Generation of Sn 
During PMA training, the training pattern is embedded with indicators to establish alignment to the RS-FEC 
block and the 15 partial PHY frames that comprise the block. The last partial PHY frame is embedded with 
an information field used to exchange messages between link partners. PMA training signal encoding is 
based on the generation, at time n, of the bit Sn. The first bit is inverted in the first 14 partial PHY frames of 
each RS-FEC block. The first 96 bits of the 15th partial PHY frame is XORed with the contents of the 
InfoField. Each partial PHY frame is 180 bits long, beginning at Sn where (n mod 180) = 0. See Equation (97–7).
(97–7)
97.3.4.2 Generation of symbol Tn 
The bit Sn is mapped to the transmit symbol Tn as follows: if Sn = 0 then Tn = +1, if Sn = 1 then Tn = –1.
97.3.4.3 PMA training mode descrambler polynomials
The PHY shall acquire descrambler state synchronization to the PAM2 training sequence and report success 
through scr_status. For side-stream descrambling, the MASTER PHY employs the receiver descrambler 
generator polynomial per Equation (97–6) and the SLAVE PHY employs the receiver descrambler generator 
polynomial per Equation (97–5).
Figure 97–10—Realization of side-stream scramblers by linear feedback shift registers
T
+
Side-stream scrambler employed by the MASTER PHY Transmit
T
Scrn[0]
Scrn[1]
T
Scrn[12]
T
Scrn[13]
T
Scrn[31]
T
Scrn[32]
Side-stream scrambler employed by the SLAVE PHY Transmit
T
+
T
Scrn[0]
Scrn[1]
T
Scrn[19]
T
Scrn[20]
T
Scrn[31]
T
Scrn[32]
Sn
Scrn 0

InfoField n mod 180



n mod 2700




Scrn 0


else if n mod 180


=
Scrn 0

otherwise







=


97.3.5 LPI signaling
PHYs with EEE capability have transmit and receive functions that can enter and leave the LPI mode 
independently. The PHY can transition to the LPI mode when the PHY has successfully completed training. 
The transmit function of the PHY initiates a transition to the LPI transmit mode when it generates a sleep 
signal composed of 80B/81B blocks containing only LPI control characters, as described in 97.3.2.2.15. 
When the transmitter begins to send the sleep signal, it asserts tx_lpi_active and the transmit function enters 
the LPI transmit mode.
Within the LPI mode PHYs use a repeating quiet-refresh cycle (see Figure 97–11). The first part of this 
cycle is known as the quiet period and lasts for a time lpi_quiet_time equal to 354 partial PHY frame 
periods. The quiet period is defined in 97.3.5.2. The second part of this cycle is known as the refresh period
and lasts for a time lpi_refresh_time equal to 6 partial PHY frame periods. The refresh period is defined in 
97.3.5.3. A cycle composed of one quiet period and one refresh period is known as an LPI cycle and lasts for 
an lpi_qr_time equal to 24 × 15 = 360 partial PHY frame periods.
lpi_offset, lpi_quiet_time, lpi_refresh_time, and lpi_qr_time are timing parameters that are integer multiples 
of the partial PHY frame period. lpi_offset is a fixed value equal to lpi_qr_time/2 + 15. It is used to ensure 
refresh signals and wake start times are appropriately offset by the link partners.
PHYs begin the transition from the LPI receive mode when they detect the wake frame. 
97.3.5.1 LPI Synchronization
To maximize power savings, maintain link integrity, and ensure interoperability, EEE-capable PHYs shall 
synchronize refresh intervals during the LPI mode. The quiet-refresh cycle is established from the Master 
partial PHY frame Count (PFC24) during PMA Training. At the MASTER, partial PHY frame zero and all 
multiples of 360 partial PHY frames thereafter denote the start of the cycle.
An EEE-capable PHY in SLAVE mode is responsible for synchronizing its partial PHY frame count to the 
MASTER’s partial PHY frame count during link up. The SLAVE shall ensure that its partial PHY frame 
count is synchronized to the MASTER’s partial PHY frames within 1 partial PHY frame. The start of the 
SLAVE quiet-refresh cycle is delayed from the MASTER by 13 PHY frames (195 partial PHY frames). 
This offset ensures that the MASTER and SLAVE wake/sense windows are offset from each other and that 
the refresh periods are nearly a half cycle offset.
Following the transition to PAM3, the PCS continues to count transmitted partial PHY frames (tx_pfc), and 
uses the counter to generate refresh and wake control signals for the transmit functions.
Figure 97–11—LPI signal timing
90 120 150 180
240 270 300 330 360
75 105 135 165 195 225 255 285 315 345
Master
Valid
Wake
Starts
Slave
Refresh
lpi_refresh_time
Valid
Wake
Starts
PHY frame boundaries occur where module (tx_pfc, 15) == 0
lpi_quiet_time
lpi_qr_time
lpi_offset


Wake frames may be sent at the beginning of every second PHY frame boundary starting at the beginning of 
the refresh PHY frame. This sets wake_period to 30 partial PHY frames. The MASTER and SLAVE 
allowable wake positions do not overlap. The wake frame may start in the same PHY frame as a planned 
refresh and obviate this refresh.
The MASTER and SLAVE shall derive the tx_refresh_active and tx_wake_start signals from the 
transmitted partial PHY frames (tx_pfc) as shown in Table 97–3 and Table 97–4.
97.3.5.2 Quiet period signaling
During the quiet period the transmitter shall put PAM3 symbol zero on to the MDI. During the quiet period 
the transmitter may be turned off to save power.
97.3.5.3 Refresh period signaling
During the LPI mode 1000BASE-T1 PHYs use staggered, out-of-phase refresh signaling to maximize 
power savings. PAM3 refresh symbols are generated from the output of the data mode PCS side-stream 
scrambler polynomials described in 97.3.2.2.12 with PCS transmit data masked to zero. The scramblers run 
continuously regardless of the transmit mode. The refresh occupies the last 6 partial PHY frames of where 
the PHY frame would occur if it were transmitted.
The 1000BASE-T1 OAM symbols and the RS parity symbols are XORed with the scrambler stream at the 
same relative position to the RS boundaries as they occupy during normal mode. The parity is generated 
using Equation (97–2) with D405 ... D1 = 0 and D0 = OAM.
97.3.6 Detailed functions and state diagrams
97.3.6.1 State diagram conventions
The body of this subclause is composed of state diagrams, including the associated definitions of constants, 
variables, functions, counters, and messages. Should there be a discrepancy between a state diagram and 
descriptive text, the state diagram prevails.
The notation used in the state diagrams follows the conventions of 21.5. The notation ++ after a counter or 
integer variable indicates that its value is to be incremented.
Table 97–3—Synchronization logic derived from SLAVE signal partial PHY frame count
Slave-side Variable
u = tx_pfc
tx_refresh_active=true
lpi_offset – lpi_refresh_time  mod(u, lpi_qr_time) < lpi_offset 
tx_wake_start=true
mod(u, wake_period) = 0
Table 97–4—Synchronization logic derived from MASTER signal partial PHY frame count
Master-side variable
v = tx_pfc
tx_refresh_active=true
mod(v, lpi_qr_time) lpi_quiet_time
tx_wake_start=true
mod(v, wake_period) = wake_period/2


97.3.6.2 State diagram parameters
97.3.6.2.1 Constants
EBLOCK_R<99:0>
TYPE: bit vector
100-bit vector to be sent to the GMII containing symbol errors in all 10 character locations.
IBLOCK_R<99:0>
TYPE: bit vector
100-bit vector to be sent to the GMII containing idles in all 10 character locations.
IBLOCK_T<99:0>
TYPE: bit vector
100-bit vector to be sent to the encoder containing idles in all 10 character locations.
LPBLOCK_R<99:0>
TYPE: bit vector
100-bit vector to be sent to the GMII containing LP_IDLEs in all 10 character locations.
LPBLOCK_T<99:0>
TYPE: bit vector
100-bit vector to be sent to the encoder containing LP_IDLEs in all 10 character locations.
RFER_CNT_LIMIT
TYPE: Integer
VALUE: 16
Number of Reed-Solomon frames with uncorrectable errors.
RFRX_CNT_LIMIT
TYPE: Integer
VALUE: 88
Number of Reed-Solomon frames received over bit error rate interval.
ZBLOCK_T<80:0>
TYPE: bit vector
81-bit vector containing all zero bits.
97.3.6.2.2 Variables
block_lock
Boolean variable that is set true when receiver acquires block delineation.
hi_rfer
Boolean variable that is asserted true when the rfer_cnt reaches RFER_CNT_LIMIT indicating a 
bit error ratio > 4  10–4.
pcs_reset
When this variable is set to ON, all PCS functions are reset. Otherwise, this variable holds the 
value of OFF. This variable is set by the PCS Reset function.
rx_coded<81:0>
Vector containing the input to the 80B/81B decoder including a block valid flag. The format for 


rx_coded<80:0> is shown in Figure 97–6. The leftmost bit in the figure is rx_coded<0> and the 
rightmost bit is rx_coded<80>. rx_coded<81> (not shown in the figure) is set to 1 if all parity 
checks of the Reed-Solomon frame are satisfied, otherwise it is set to 0.
rf_valid 
Boolean indication that is set true if received Reed-Solomon frame is valid. The frame is valid if all 
parity checks of the coded bits are satisfied.
rx_lpi_active
This variable is set true upon detection of LP_IDLE. Set false upon detection of a wake frame.
rx_raw<99:0> 
Vector containing 10 successive GMII output transfers. Each transfer is numbered from 0 to 9 with 
the first transfer numbered as the 0th transfer. The nth GMII transfer is labeled as RX_DV[n], 
RX_ER[n], RXD[n]<7:0>. 
For n = 0 to 9, RX_DV[n] = rx_raw<10n>, RX_ER[n] = rx_raw<10n+1>, 
RXD[n]<7:0> = rx_raw<10n+9:10n+2>
rx_wake_frame_complete
This variable is set true at end of WAKE PHY frame, otherwise false.
tx_coded<80:0>
Vector containing the output from the 80B/81B encoder. The format for this vector is shown in 
Figure 97–5. The leftmost bit in the figure is tx_coded<0> and the rightmost bit is tx_coded<80>.
tx_data_mode 
Set true when tx_mode = SEND_N, otherwise false.
tx_lpi_active
This variable is set false at the next wake frame window if any of the following conditions is true:
— a non-LP_IDLE is detected on GMII in any block
— the PHY receives SNR<1:0> set to 01 by its link partner 
— the PHY transmits SNR<1:0> set to 01 to its link partner as defined in 97.3.8.2.14
This variable is set true on next PHY frame if all of the following conditions are true:
— an LP_IDLE detected on GMII during the entire last 80B/81B block
— the PHY does not receive SNR<1:0> set to 01 by its link partner 
— the PHY does not transmit SNR<1:0> set to 01 to its link partner as defined in 97.3.8.2.14
tx_raw<99:0> 
Vector containing 10 successive GMII transfers. Each transfer is numbered from 0 to 9 with the 
first transfer numbered as the 0th transfer. The nth GMII transfer is labeled as TX_EN[n], 
TX_ER[n], TXD[n]<7:0>.
For n = 0 to 9, tx_raw<10n> = TX_EN[n], tx_raw<10n+1> = TX_ER[n], tx_raw<10n+9:10n+2
> = TXD[n]<7:0>
tx_sleep_frame_complete
This variable is set to true when PHY is transitioning to the LPI mode and the sleep signal trans-
mission is completed. This variable is set to false when the PHY is transitioning out of the LPI 
mode.


tx_wake_frame_complete 
This variable is set to true at the end of a complete wake frame. This variable is set to false 
otherwise.
lpi_tx_mode 
A variable indicating the signaling to be used from the PCS to the PMA across the PMA_UNIT-
DATA.request(tx_symb) interface. 
lpi_tx_mode controls tx_symb only when tx_mode is set to SEND_N.
The variable is set to NORMAL when !tx_lpi_active, indicating that the PCS is in the normal 
power mode of operation.
The variable is set to REFRESH when (tx_lpi_active * tx_refresh active).
The variable is set to QUIET when (tx_lpi_active * !tx_refresh active).
rx_aggregate 
This variable is set to true when nine aligned 9-bit Reed-Solomon symbols are aggregated in 
rx_coded. This variable is asserted even when the receiver is in low power idle mode at the time 
when the nine 9-bit RS-FEC symbols would be aggregated in rx_coded if the receiver was 
operating in non-lpi mode. This variable is set to false otherwise.
rx_frame
This variable is set to true when a full Reed-Solomon frame has been decoded and the variable 
rf_valid is updated. This variable is set to false otherwise.
tx_aggregate
This variable is set to true when 10 GMII transfers are aggregated in tx_raw<99:0>. This variable 
is set to false otherwise.
97.3.6.2.3 Functions
DECODE(rx_coded<81:0>) 
In the PCS Receive process, this function takes as its argument 82-bit rx_coded<81:0> from the 
Reed-Solomon decoder and descrambler. If rx_coded<81> = 1 then the decoder decodes the 81B-
Reed-Solomon bit vector rx_coded<80:0> returning a vector rx_raw<99:0>, which is sent to the 
GMII. The DECODE function shall decode the block based on code specified in 97.3.2.2.2. If 
rx_coded<81> = 0 then the decoder returns EBLOCK_R.
ENCODE(tx_raw<99:0>) 
Encodes the 100-bit vector received from the GMII, returning 81-bit vector tx_coded. The 
ENCODE function shall encode the block as specified in 97.3.2.2.2. The ENCODE function shall 
only encode LPI_IDLE while in the SEND_LPI state. Otherwise LPI_IDLE is converted to Idle in 
the ENCODE function.
97.3.6.2.4 Counters
rfer_cnt 
Count up to a maximum of RFER_CNT_LIMIT of the number of invalid Reed-Solomon frames 
within the current RFRX_CNT_LIMIT Reed-Solomon frame period.
rfrx_cnt 
Count number Reed-Solomon frames received during current period.


97.3.6.3 Messages
PCS_status 
Indicates whether the PCS is in a fully operational state. (See 97.3.7.1.)
PMA_UNITDATA.indication(rx_symb)
A signal sent by PMA Receive indicating that a PAM3 symbol is available in rx_symb.
PMA_UNITDATA.request(tx_symb)
A signal sent to PMA Transmit indicating that a PAM3 symbol is available in tx_symb.
97.3.6.4 State diagrams
The RFER Monitor state diagram shown in Figure 97–13 monitors the received signal for high PHY frame 
error ratio. The 80B/81B Transmit state diagram shown in Figure 97–14 controls the encoding of 81B 
transmitted blocks. It makes exactly one transition for each 81B transmit block processed. The 80B/81B 
Receive state diagram shown in Figure 97–12 controls the decoding of 81B received blocks. It makes 
exactly one transition for each receive block processed. The PCS shall perform the functions of PCS 
Receive, RFER monitor, and PCS Transmit, as specified in Figure 97–12, Figure 97–13, and Figure 97–14, 
respectively.


RECEIVE_DATA
rx_raw  
DECODE(rx_coded<81:0>)
RECEIVE_INIT
rx_raw  IBLOCK_R
pcs_reset = ON
+ hi_rfer
+ !block_lock
RECEIVE_LPI
rx_raw  LPBLOCK_R
RECEIVE_WAKE
rx_raw IBLOCK_R
rx_aggregate
* !rx_lpi_active
rx_aggregate
* rx_lpi_active
rx_aggregate
* !rx_lpi_active
rx_aggregate * rx_lpi_active
rx_aggregate *
rx_wake_frame_complete
rx_aggregate
Note—Transitions inside dashed boxes are only required for the 
EEE capability.
Figure 97–12—PCS Receive state diagram


 
 
Figure 97–13—RFER monitor state diagram
INIT_CNT
rfer_cnt  0
rfrx_cnt  0
UCT
RFER_MT_INIT
hi_rfer  false
pcs_reset = ON
+ !block_lock
+ rx_lpi_active
WAIT
UCT
INC_CNT
rfrx_cnt++
rx_frame
RFER_BAD_RF
rfer_cnt++
!rf_valid
rfer_cnt =
RFER_CNT_LIMIT
rfer_cnt < RFER_CNT_LIMIT *
rfrx_cnt < RFRX_CNT_LIMIT
rf_valid *
rfrx_cnt < RFRX_CNT_LIMIT
HI_RFER
hi_rfer  true
INC_CNT2
rfrx_cnt++
rx_frame *
rfrx_cnt < RFRX_CNT_LIMIT
GOOD_RFER
hi_rfer  false
rf_valid *
rfrx_cnt = RFRX_CNT_LIMIT
UCT
rfrx_cnt = RFRX_CNT_LIMIT
rfer_cnt < RFER_CNT_LIMIT *
rfrx_cnt = RFRX_CNT_LIMIT


Figure 97–14—PCS Transmit state diagram
SEND_IDLES
tx_coded  
ENCODE(IBLOCK_T)
DISABLE_TRANSMITTER
pcs_reset = ON
SEND_DATA
tx_coded  
ENCODE(tx_raw<99:0>)
SEND_ENTER_LPI
tx_coded  
ENCODE(LPBLOCK_T)
SEND_LPI
tx_coded  ZBLOCK_T
SEND_WAKE
tx_coded  
ENCODE(IBLOCK_T)
tx_aggregate *
tx_data_mode
tx_aggregate *
tx_data_mode *
tx_lpi_active
tx_aggregate *
tx_data_mode *
tx_lpi_active * tx_sleep_frame_complete
tx_aggregate *
tx_data_mode *
!tx_lpi_active
tx_aggregate *
!tx_data_mode
tx_aggregate *
!tx_data_mode
tx_aggregate *
tx_data_mode *
!txlpi_active
tx_aggregate *
tx_data_mode * tx_lpi_active
tx_aggregate *
tx_data_mode * !tx_lpi_active
tx_aggregate *
tx_data_mode * tx_wake_frame_complete
tx_aggregate *
tx_aggregate
!tx_data_mode
tx_aggregate *
!tx_data_mode
tx_aggregate *
!tx_data_mode
Note—Transitions inside dashed boxes are only required for the EEE capability.


97.3.7 PCS management
The following objects apply to PCS management. If an MDIO Interface is provided (see Clause 45), they are 
accessed via that interface. If not, it is recommended that an equivalent access be provided.
97.3.7.1 Status 
PCS_status: 
Indicates whether the PCS is in a fully operational state. It is only true if block_lock is true and 
hi_rfer is false. This status is reflected in MDIO register 3.2306.10. A latch low view of this status 
is reflected in MDIO register 3.2305.2 and the inverse of this status is reflected in MDIO register 
3.2305.7.
block_lock: 
Indicates the state of the block_lock variable. This status is reflected in MDIO register 3.2306.8. A 
latch low view of this status is reflected in MDIO register 3.2306.6.
hi_rfer: 
Indicates the state of the hi_rfer variable. This status is reflected in MDIO register 3.2306.9. A 
latch high view of this status is reflected in MDIO register 3.2306.7.
Rx LPI indication: 
For EEE capability, this variable indicates the current state of the receive LPI function. This flag is 
set to true (register bit set to one) when the PCS Receive state diagram (Figure 97–12) is in the 
RECEIVE_LPI or RECEIVE_WAKE states. This status is reflected in MDIO register 3.2305.8. A 
latch high view of this status is reflected in MDIO register 3.2305.10 (Rx LPI received).
Tx LPI indication:
For EEE capability, this variable indicates the current state of the transmit LPI function. This flag 
is set to true (register bit set to one) when the PCS Transmit state diagram (Figure 97–14) is in the 
SEND_LPI or SEND_WAKE states. This status is reflected in MDIO register 3.2305.9. A latch 
high view of this status is reflected in MDIO register 3.2305.11 (Tx LPI received).
97.3.7.2 Counter
The following counter is reset to zero upon read and upon reset of the PCS. When it reaches all ones, it stops 
counting. Its purpose is to help monitor the quality of the link.
RFER_count:
6-bit counter that counts each time RFER_BAD_RF of the RFER monitor state diagram (see 
Figure 97–13) is entered. This counter is reflected in MDIO register bits 3.2306.5:0. The counter is 
reset when register 3.2306 is read by management. Note that this counter counts a maximum of 
RFER_CNT_LIMIT counts per RFRX_CNT_LIMIT period since the RFER_BAD_RF state can 
be entered a maximum of RFER_CNT_LIMIT times per RFRX_CNT_LIMIT window.
97.3.7.3 Loopback
The PCS shall be placed in loopback mode when the loopback bit in MDIO register 3.2304.14 is set to a one. 
In this mode, the PCS shall accept data on the transmit path from the GMII and return it on the receive path 
to the GMII. In addition, the PCS shall transmit a continuous stream of GMII data to the 81B encoder and on 
further to the PMA sublayer and shall ignore all data presented to it by the PMA sublayer. 


97.3.8 BASE-T1 Operations, Administration, and Maintenance (OAM)
The 1000BASE-T1 PCS level Operations, Administration, and Maintenance (OAM) provides an optional 
mechanism useful for monitoring link operation such as exchanging PHY link health status and message 
exchange. When OAM is implemented, behavior shall conform to the state diagrams in Figure 97–17 and 
Figure 97–18. The 1000BASE-T1 OAM information is exchanged out of band between two PHYs using 
excess bandwidth available on the link. The 1000BASE-T1 OAM is strictly between two 1000BASE-T1 
PHYs on the physical layer and their associated management entities if present. Passing 1000BASE-T1 
OAM information to other layers is outside the scope of this standard.
1000BASE-T1 OAM is operational as long as both PHYs implement this mechanism and link is up. It 
continues to be operational during low power idle albeit the information is transferred at a slower rate during 
the refresh cycle.
The 1000BASE-T1 OAM frame data is carried in the OAM9 field described in 97.3.2.2.4 for the normal 
power data mode and 97.3.5.3 for low power mode. This 9-bit field is used to exchange 1000BASE-T1 
OAM frames. The implementation of 1000BASE-T1 OAM frame exchange function is optional. However, 
if 1000BASE-T1 EEE is implemented, then the 1000BASE-T1 OAM frame exchange function is 
implemented to exchange, at a minimum, the link partner health status.
For the remainder of this subclause, the term 1000BASE-T1 OAM is specific to the 1000BASE-T1 PCS 
level OAM.
97.3.8.1 Definitions 
1000BASE-T1 OAM frame: A frame consisting of 12 octets of data with 12 parity bits.
1000BASE-T1 OAM symbol: A 9-bit symbol consisting of one data octet plus a parity bit. Twelve 
1000BASE-T1 OAM symbols make up an 1000BASE-T1 OAM frame.
1000BASE-T1 OAM field: The OAM9 field in each PHY frame as described in 97.3.2.2.11 or in each 
refresh cycle as described in 97.3.5.3.
1000BASE-T1 OAM message: A message contains a 4-bit message number plus 8 octets of message data 
embedded in an 1000BASE-T1 OAM frame. The same 1000BASE-T1 OAM message can be repeated on 
multiple 1000BASE-T1 OAM frames. 
97.3.8.2 Functional specifications
97.3.8.2.1 1000BASE-T1 OAM Frame Structure
Each 1000BASE-T1 OAM frame is made up of 12 octets of data and 12 parity bits. Each symbol consists of 
8 bits of data and one parity bit. The parity bit value for symbol 0 should be such that the sum of the number 
of 1s in the nine bits is even. The parity bit value for symbols 1 to 11 should be such that the sum of the 
number of 1s in the nine bits is odd.


One 1000BASE-T1 OAM symbol is placed in the 9-bit 1000BASE-T1 OAM field in each PHY frame 
during normal power operation in the data mode. One 1000BASE-T1 OAM symbol is placed in the 9-bit 
1000BASE-T1 OAM field in each refresh cycle during low power idle. The 12 1000BASE-T1 OAM
 
symbols are consecutively inserted into 12 consecutive PHY frames and/or refresh cycles. Once the 12 
symbols of the current 1000BASE-T1 OAM frame are inserted, the 12 symbols of the next 1000BASE-T1 
OAM frame are inserted. This process is continuous without any break in the insertion of 1000BASE-T1 
OAM symbols.
Bit 0 of each 1000BASE-T1 OAM symbol is the first bit transmitted in the 9-bit 1000BASE-T1 OAM field. 
Symbol 0 is the first symbol transmitted in each 1000BASE-T1 OAM frame.
The 1000BASE-T1 OAM frame boundary can be found at the receiver by determining the symbol parity. 
Symbol 0 has even parity while all other symbols have odd parity.
If 1000BASE-T1 OAM is not implemented then the 9-bit 1000BASE-T1 OAM field shall be set to all 0s. If 
the link partner does not implement 1000BASE-T1 OAM, the 9-bit 1000BASE-T1 OAM field will remain 
static and the symbol parity will not change. 
97.3.8.2.2 1000BASE-T1 OAM Frame Data
The 1000BASE-T1 OAM frame data is shown in Figure 97–15. OAM<x><y> refers to symbol x, bit y of 
the 1000BASE-T1 OAM frame. Reserved fields shall be set to 0. 
97.3.8.2.3 Ping RX
The Ping RX is indicated in OAM<0><3>.
This bit is set by the PHY to the same value as the Ping TX bit received from the link partner. 
97.3.8.2.4 Ping TX
The Ping TX is indicated in OAM<0><2>.
Figure 97–15—OAM Frame
Even
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Odd
Parity
Reserved Reserved Reserved Reserved
Toggle
Valid
Ack
TogAck
Message_Number<3:0>
PingRx
PingTx
SNR<1>
SNR<0>
Message<0><7:0>
Message<1><7:0>
Message<2><7:0>
Message<3><7:0>
Message<4><7:0>
Message<5><7:0>
Message<6><7:0>
Message<7><7:0>
CRC16
CRC16
Symbol 0
Symbol 1
Symbol 2
Symbol 3
Symbol 4
Symbol 5
Symbol 6
Symbol 7
Symbol 8
Symbol 9
Symbol 10
Symbol 11
D8
D7
D6
D5
D4
D3
D2
D1
D0
first bit
final bit


This bit is set by the PHY to for the link partner to echo on Ping RX. 
97.3.8.2.5 PHY Health
The PHY Health (SNR<1:0>) is indicated in OAM<0><1:0>.
This status is set by the PHY to indicate the status of the receiver. The definitions of good, marginal, when to 
request idles, and when to request retrain are implementation dependent.
—
00: PHY link is failing and will drop link and relink within 2 ms to 4 ms after the end of the current 
1000BASE-T1 OAM frame
—
01: LPI refresh is insufficient to maintain PHY SNR. Request link partner to exit LPI and send idles 
(used only when EEE is enabled)
—
10: PHY SNR is marginal
—
11: PHY SNR is good
97.3.8.2.6 1000BASE-T1 OAM Message Valid
The 1000BASE-T1 OAM message valid (Valid) is indicated in OAM<1><7>. 
—
0: Current 1000BASE-T1 OAM frame does not contain a valid 1000BASE-T1 OAM message
—
1: Current 1000BASE-T1 OAM frame contains a valid 1000BASE-T1 OAM message
97.3.8.2.7 1000BASE-T1 OAM Message Toggle
The 1000BASE-T1 OAM message toggle (Toggle) is indicated in OAM<1><6>. 
The toggle bit is used to ensure proper 1000BASE-T1 OAM message synchronization between the PHY and 
the link partner. The toggle bit in the current 1000BASE-T1 OAM message is set to the opposite value of the 
toggle bit in the previous 1000BASE-T1 OAM message only if link partner acknowledge the 1000BASE-T1 
OAM message is received. This allows one 1000BASE-T1 OAM message to be delineated from a second 
1000BASE-T1 OAM message since the same 1000BASE-T1 OAM message may be repeated over multiple 
1000BASE-T1 OAM frames. This bit is valid only if Valid is set to 1.
97.3.8.2.8 1000BASE-T1 OAM Message Acknowledge
The 1000BASE-T1 OAM message Acknowledge (Ack) is indicated in OAM<1><5>. 
Ack is set by the PHY to let the link partner know that the 1000BASE-T1 OAM message sent by the link 
partner was successfully received as defined in 97.3.8.2.13 and the PHY is ready to accept a new 
1000BASE-T1 OAM message. An 1000BASE-T1 OAM message is defined to be Message_Number<3:0> 
and Message<7:0><7:0>. 
—
0: No Acknowledge
—
1: Acknowledge
97.3.8.2.9 1000BASE-T1 OAM Message Toggle Acknowledge
The 1000BASE-T1 OAM message Toggle Acknowledge (TogAck) is indicated in OAM<1><4>. 
TogAck is set by the PHY to let the link partner know which the 1000BASE-T1 OAM message is being 
acknowledged. TogAck takes the value of Toggle bit of the 1000BASE-T1 OAM message being 
acknowledged. This bit is valid only if Ack is set to 1. 


97.3.8.2.10 1000BASE-T1 OAM Message Number
The 1000BASE-T1 OAM message number is indicated in OAM<1><3:0>. 
This field is user-defined but is recommended that it be used to indicate the meaning of the 8-octet message 
that follows. If used this way, up to 16 different 8-octet messages can be exchanged.
The message number is user-defined and its definition is outside the scope of this standard.
97.3.8.2.11 1000BASE-T1 OAM Message Data
The 1000BASE-T1 OAM message data is indicated in OAM<9:2><7:0>. 
The 8-octet message data is user-defined and its definition is outside the scope of this standard. 
Ack is set by the PHY to let the link partner know that the 1000BASE-T1 OAM frame sent by the link 
partner is successfully received as defined The 1000BASE-T1 OAM frame octet is the lower 8 bits of the 
9-bit 1000BASE-T1 OAM symbol. Twelve octets form the 1000BASE-T1 OAM data. 
97.3.8.2.12 CRC16
The CRC16 is indicated in OAM<11:10><7:0>. 
The CRC16 implements the polynomial (x+1)(x15+x+1) of the previous 10 octets. The CRC16 shall produce 
the same result as the implementation shown in Figure 97–16. The 16 delay elements S0,..., S15, shall be 
initialized to zero. Afterwards OEM<9:0><7:0> presented in their transmitted order as described in 
97.3.8.2.1 are used to compute the CRC16 with the switch connected, which is setting CRC gen in Figure 97–16. 
Note that the parity bit is not used in the CRC16 calculation. After all the 10 octets have been processed, the 
switch is disconnected (setting CRC out) and the 16 values stored in the delay elements are transmitted in 
the order illustrated, first S15, followed by S14, and so on, until the final value S0. S15 is indicated in 
OAM<10><0> and S0 is indicated in OAM<11><7>. 
97.3.8.2.13 1000BASE-T1 OAM Frame Acceptance Criteria
All fields of the 1000BASE-T1 OAM frame shall be accepted and updated, unless any of the following 
occurs:
a)
Incorrect parity on any of the 12 symbols
b)
Incorrect CRC16
c)
Uncorrectable PHY frame on any of the 12 symbols
Figure 97–16—1000BASE-T1 OAM CRC16
+
S0
S1
S2
S14
+
S15
CRC16 output
+
Data In
CRC gen
CRC out


97.3.8.2.14 PHY Health Indicator
The PHY current health is sent to the link partner on a per 1000BASE-T1 OAM frame basis using the 
SNR<1:0> bits as described in 97.3.8.2.5. It lets the link partner have an early indication of potential 
problems that may cause the PHY to drop link or have high error rates. 
If EEE is implemented, there may be a case where a PHY’s receiver can no longer maintain good SNR 
based on quiet/refresh cycles. Instead of dropping the link, the PHY can attempt to recover the link by 
forcing the link partner to exit LPI in its egress direction so that the PHY can use normal power mode to 
recover. This is done by transmitting SNR<1:0> with a value of 01.
If a PHY receives SNR<1:0> set to 01 by its link partner, then it cannot enter into LPI in the egress 
direction. If the PHY is already in LPI then the PHY shall immediately exit LPI.
97.3.8.2.15 Ping
The PingTx bit is set based on the value in mr_tx_ping. The PingRx bit is set based on the latest PingTx 
received from the link partner. The value in mr_rx_ping is set based on the received PingRx from the link 
partner. The user can determine that the link partner 1000BASE-T1 OAM is operating properly by togging 
mr_tx_ping and observing mr_rx_ping matches after a short delay. 
The Ping bits are updated on a per 1000BASE-T1 OAM frame basis. 
97.3.8.2.16 1000BASE-T1 OAM Message Exchange
Unlike the PHY health indicator and the ping function that operate on a per 1000BASE-T1 OAM frame 
basis, the 1000BASE-T1 OAM message exchange operates on a per 1000BASE-T1 OAM message basis 
that will occur over many 1000BASE-T1 OAM frames. The 1000BASE-T1 OAM message exchange 
mechanism allows a management entity attached to a PHY and its peer attached to the link partner to 
asynchronously pass 1000BASE-T1 OAM messages and verify their delivery. 
The 1000BASE-T1 OAM message is first written into the 1000BASE-T1 OAM transmit registers in the 
PHY. The 1000BASE-T1 OAM message is then read out of the 1000BASE-T1 OAM transmit registers and 
transmitted to the link partner. After the link partner receives the 1000BASE-T1 OAM message it transfers 
it into the link partner’s 1000BASE-T1 OAM receive registers and also sends an acknowledge back to the 
PHY indicating that the next 1000BASE-T1 OAM message can be transmitted. One 1000BASE-T1 OAM
 
message can be loaded into the 1000BASE-T1 OAM transmit registers while another 1000BASE-T1 OAM
 
message is being transmitted by the PHY to the link partner while yet another 1000BASE-T1 OAM message 
is being read out at the link partner's 1000BASE-T1 OAM receive registers. The exchange of 1000BASE-T1 
OAM messages are occurring concurrently and bi-directionally.The transfers between the management 
entities can be done asynchronously. On the transmit side mr_tx_valid = 0 indicates that the next 
1000BASE-T1 OAM message can be written into the 1000BASE-T1 OAM transmit registers. Once the 
registers are written the management entity sets mr_tx_valid to 1 to indicate that the 1000BASE-T1 OAM
 
transmit registers contains a valid 1000BASE-T1 OAM message. Once the message is read out atomically, 
the state machine clears the mr_tx_valid to 0 to indicate that the registers are ready to accept the next 
1000BASE-T1 OAM message.
On the receive side mr_rx_lp_valid indicates that valid 1000BASE-T1 OAM message can be read from the 
1000BASE-T1 OAM receive registers. Once these registers are read, the mr_rx_lp_valid should be cleared 
to 0 to indicate that the registers are ready to receive the next 1000BASE-T1 OAM message. If 
mr_rx_lp_valid is not cleared then the 1000BASE-T1 OAM message transfer will eventually stall since the 
sender cannot send new 1000BASE-T1 OAM messages if the receiver does not acknowledge that an 
1000BASE-T1 OAM message has been transferred into the 1000BASE-T1 OAM receive registers.


The management entities can asynchronously read mr_tx_valid and mr_rx_lp_valid to know when 
1000BASE-T1 OAM messages can be transferred in and out of the 1000BASE-T1 OAM registers. 
The toggle bit alternates between 0 and 1, which lets the management entity determine which 1000BASE-
T1 OAM message is being referred to. The toggle bit transitioning rules between one 1000BASE-T1 OAM
 
frame to the next 1000BASE-T1 OAM frame are shown in Table 97–5.
97.3.8.3 State diagram variable to BASE-T1 OAM register mapping
The state diagrams of Figure 97–18 and Figure 97–17 generate and accept variables of the form “mr_x,” 
where x is an individual signal name. These variables comprise a management interface to communicate the 
1000BASE-T1 OAM information to and from the management entity. Clause 45 MDIO registers are 
defined in MMD3 to support the 1000BASE-T1 OAM. The Clause 45 MDIO electrical interface is optional. 
Where no physical embodiment of the MDIO exists, provision of an equivalent mechanism to access the 
information is recommended. Table 97–6 describes the MDIO register to the state diagrams variable 
mapping.
Table 97–5—Toggle bit transition rules
Previous 
Valid 
Previous 
Toggle
Current 
Valid
Current 
Toggle
Description
No valid 1000BASE-T1 OAM message
Illegal transition (Error)
New 1000BASE-T1 OAM message starting
Illegal transition (Error)
Illegal transition (Error)
No valid 1000BASE-T1 OAM message
Illegal transition (Error)
New 1000BASE-T1 OAM message starting
Illegal transition (Error)
Received acknowledge, no new 1000BASE-T1 OAM 
message to send
Repeating current 1000BASE-T1 OAM message, waiting 
for link partner’s acknowledge
Previous 1000BASE-T1 OAM message ending, new 
1000BASE-T1 OAM message starting
Received acknowledge, no new 1000BASE-T1 OAM 
message to send
Illegal transition (Error)
Previous 1000BASE-T1 OAM message ending, new 
1000BASE-T1 OAM message starting
Repeating current 1000BASE-T1 OAM message, waiting 
for link partner’s acknowledge


 
Table 97–6—State Variables to BASE-T1 OAM Register Mapping 
MDIO control/status variable 
PCS register name
Register/bit 
number
PCS control/status 
variable
BASE-T1 OAM Message Valid
BASE-T1 OAM transmit 
register
3.2308.15
mr_tx_valid
Toggle Value
BASE-T1 OAM transmit 
register
3.2308.14
mr_tx_toggle
BASE-T1 OAM Message 
Received
BASE-T1 OAM transmit 
register
3.2308.13
mr_tx_received
Received Message Toggle Value
BASE-T1 OAM transmit 
register
3.2308.12
mr_tx_received_toggle
Message Number
BASE-T1 OAM transmit 
register
3.2308.11:8
mr_tx_message_num[3:0]
Ping Received
BASE-T1 OAM transmit 
register
3.2308.3
mr_rx_ping
Ping Transmit
BASE-T1 OAM transmit 
register
3.2308.2
mr_tx_ping
Local SNR
BASE-T1 OAM transmit 
register
3.2308.1:0
mr_tx_SNR[1:0]
BASE-T1 OAM Message 0
BASE-T1 OAM message 
register
3.2309.7:0
mr_tx_message[7:0]
BASE-T1 OAM Message 1
BASE-T1 OAM message 
register
3.2309.15:8
mr_tx_message[15:8]
BASE-T1 OAM Message 2
BASE-T1 OAM message 
register
3.2310.7:0
mr_tx_message[23:16]
BASE-T1 OAM Message 3
BASE-T1 OAM message 
register
3.2310.15:8
mr_tx_message[31:24]
BASE-T1 OAM Message 4
BASE-T1 OAM message 
register
3.2311.7:0
mr_tx_message[39:32]
BASE-T1 OAM Message 5
BASE-T1 OAM message 
register
3.2311.15:8
mr_tx_message[47:40]
BASE-T1 OAM Message 6
BASE-T1 OAM message 
register
3.2312.7:0
mr_tx_message[55:48]
BASE-T1 OAM Message 7
BASE-T1 OAM message 
register
3.2312.15:8
mr_tx_message[63:56]
Link Partner BASE-T1 OAM 
Message Valid
BASE-T1 OAM receive register
3.2313.15
mr_rx_lp_valid
Link Partner Toggle Value
BASE-T1 OAM receive register
3.2313.14
mr_rx_lp_toggle


97.3.8.4 Detailed functions and state diagrams
97.3.8.4.1 State diagram conventions
The body of this subclause is composed of state diagrams, including the associated definitions of variables, 
counters, and functions. Should there be a discrepancy between a state diagram and descriptive text, the state 
diagram prevails. 
The notation used in the state diagrams follows the conventions of 21.5.
97.3.8.4.2 State diagram parameters
97.3.8.4.3 Variables
link_status
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive. This variable takes the values of OK or FAIL.
mr_rx_lp_message[63:0]
Eight octet 1000BASE-T1 OAM message from the link partner. The value in this variable is valid 
only when mr_rx_lp_valid is 1.
mr_rx_lp_message_num[3:0]
Four bit message number from the link partner. The value in this variable is valid only when 
mr_rx_lp_valid is 1.
Link Partner Message Number
BASE-T1 OAM receive register
3.2313.11:8
mr_rx_lp_message_num[
3:0]
Link Partner SNR
BASE-T1 OAM receive register
3.2313.1:0
mr_rx_lp_SNR[1:0]
Link Partner BASE-T1 OAM 
Message 0
Link partner BASE-T1 OAM 
message register
3.2314.7:0
mr_rx_lp_message[7:0]
Link Partner BASE-T1 OAM 
Message 1
Link partner BASE-T1 OAM 
message register
3.2314.15:8
mr_rx_lp_message[15:8]
Link Partner BASE-T1 OAM 
Message 2
Link partner BASE-T1 OAM 
message register
3.2315.7:0
mr_rx_lp_message[23:16]
Link Partner BASE-T1 OAM 
Message 3
Link partner BASE-T1 OAM 
message register
3.2315.15:8
mr_rx_lp_message[31:24]
Link Partner BASE-T1 OAM 
Message 4
Link partner BASE-T1 OAM 
message register
3.2316.7:0
mr_rx_lp_message[39:32]
Link Partner BASE-T1 OAM 
Message 5
Link partner BASE-T1 OAM 
message register
3.2316.15:8
mr_rx_lp_message[47:40]
Link Partner BASE-T1 OAM 
Message 6
Link partner BASE-T1 OAM 
message register
3.2317.7:0
mr_rx_lp_message[55:48]
Link Partner BASE-T1 OAM 
Message 7
Link partner BASE-T1 OAM 
message register
3.2317.15:8
mr_rx_lp_message[63:56]
Table 97–6—State Variables to BASE-T1 OAM Register Mapping (continued)
MDIO control/status variable 
PCS register name
Register/bit 
number
PCS control/status 
variable


mr_rx_lp_SNR[1:0]
Link partner health status.
Values:
00:
PHY link is failing and will drop link and relink within 2 ms to 4 ms after the end of 
the current 1000BASE-T1 OAM frame
01:
LPI refresh is insufficient to maintain PHY SNR. Request link partner to exit LPI
and send idles (used only when EEE is enabled).
10:
PHY SNR is marginal
11:
PHY SNR is good
The threshold for the status is implementation dependent.
mr_rx_lp_toggle
The toggle bit value associated with the eight octet 1000BASE-T1 OAM message from the link 
partner.
Values:
The toggle bit alternates between 0 and 1.
mr_rx_lp_valid
Indicates 
whether 
1000BASE-T1 
OAM 
message 
in 
mr_rx_lp_message[63:0], 
mr_rx_lp_message_num[3:0] and the toggle bit in mr_rx_lp_toggle is valid or not. This variable 
should be cleared when mr_rx_lp_message[63:48] is read and is not explicitly shown in the state 
machine. The clearing of this variable indicates to the state machine that the 1000BASE-T1 OAM
 
message is read by the user and the state machine can proceed to load in the next 1000BASE-T1 
OAM message. 
Values:
0:
invalid
1:
valid
mr_rx_ping
Echoed ping value from the link partner.
Values:
The value can be 0 or 1.
mr_tx_message[63:0]
Eight octet 1000BASE-T1 OAM message transmitted by the local PHY. The value in this variable 
is valid only when mr_tx_valid is 1.
mr_tx_message_num[3:0]
Four bit message number transmitted by the local PHY. The value in this variable is valid only 
when mr_tx_valid is 1.
mr_tx_ping
Ping value transmitted by the local PHY.
Values:
The value can be 0 or 1.
mr_tx_received
Indicates whether the most recently transmitted 1000BASE-T1 OAM message with a toggle bit 
value of mr_tx_received_toggle was received, read, and acknowledged by the link partner. This 
variable shall clear on read.
Values:
0:
1000BASE-T1 OAM message not received and read by the link partner
1:
1000BASE-T1 OAM message received by the link partner


mr_tx_received_toggle
Toggle bit value of the 1000BASE-T1 OAM message that was received, read, and most recently 
acknowledged by the link partner. This bit is valid only if mr_tx_received is 1.
Values:
The value can be 0 or 1.
mr_tx_SNR[1:0]
Status register indicating PHY health status.
Values:
00:
PHY link is failing and will drop link and relink within 2 to 4 ms after the end of
the current 1000BASE-T1 OAM frame
01:
LPI refresh is insufficient to maintain PHY SNR. Request link partner to exit LPI
and send idles (used only when EEE is enabled)
10:
PHY SNR is marginal
11:
PHY SNR is good
The threshold for the status is implementation dependent.
mr_tx_toggle
The toggle bit value associated with the eight octet 1000BASE-T1 OAM message transmitted by 
the PHY. The value is automatically set by the state machine and cannot be set by the user. This bit 
should be read and recorded prior to setting mr_tx_valid to 1.
Values:
The toggle bit alternates between 0 and 1.
mr_tx_valid
Indicates 
whether 
1000BASE-T1 
OAM 
message 
in 
mr_tx_message[63:0] 
and 
mr_rx_lp_message_num[3:0] is valid or not. This register will be cleared by the state machine to 
indicate whether the next 1000BASE-T1 OAM message can be written into the registers. 
Values:
0: 
invalid
1:
valid
reset
Reset
Values:
false:
1000BASE-T1 OAM circuit not in reset
true:
1000BASE-T1 OAM circuit is in reset
rx_ack
Acknowledge from link partner in response to PHY’s 1000BASE-T1 OAM message. 
Values:
0:
no acknowledge
1:
acknowledge 
rx_ack_toggle
The toggle value corresponding to the PHY’s 1000BASE-T1 OAM message that the link partner is 
acknowledging. This value is valid only if the rx_ack is set to 1.
Values:
The toggle bit can take on values of 0 or 1.
rx_boundary
This variable is set to true whenever the receive data stream reaches the end of a Reed-Solomon 
frames during normal power operation in the data mode, or at the end of a received refresh cycle 


during low power idle operation. This variable is set to false at other times.
Values:
false:
receive stream not at a boundary end
true:
receive stream at a boundary end 
rx_exp_toggle
This variable holds the expected toggle value of the next 1000BASE-T1 OAM message. This is 
normally the opposite value of the current toggle value, but is reset on error conditions where two 
back to back 1000BASE-T1 OAM messages separated by 1000BASE-T1 OAM frames without a 
valid message have the same toggle value.
Values:
The toggle bit can take on values of 0 or 1.
rx_lp_ack
Acknowledge from PHY in response to link partner’s 1000BASE-T1 OAM message. Indicates 
whether valid 1000BASE-T1 OAM message from the link partner has been sampled into the 
PHY’s registers.
Values:
0:
no acknowledge / not sampled
1:
acknowledge / sampled
rx_lp_ping
Ping value received from the link partner that should be looped back.
Values: 
The value can be 0 or 1.
rx_lp_toggle
The toggle bit value in the previous 1000BASE-T1 OAM frame received from the link partner.
Values:
The toggle bit alternates between 0 and 1.
rx_lp_valid
Indicates whether 1000BASE-T1 OAM message in previous 1000BASE-T1 OAM frame received 
from the link partner is valid or not.
Values:
0:
invalid
1: 
valid
rx_oam_field<8:0>
Nine bit 1000BASE-T1 OAM symbol extracted from a received Reed-Solomon frame during nor-
mal power operation in the data mode, or from a received refresh cycle during low power idle 
operation. 
rx_oam<11 to 0><8:0>
Raw 12 symbol 1000BASE-T1 OAM frame received from the link partner.


SNR[1:0]
PHY health status.
Values:
00:
PHY link is failing and will drop link and relink within 2 ms to 4 ms after the end 
of the current 1000BASE-T1 OAM frame
01:
LPI refresh is insufficient to maintain PHY SNR. Request link partner to exit LPI
and send idles (used only when EEE is enabled)
10:
PHY SNR is marginal
11:
PHY SNR is good
Both the status threshold and condition for generating this status are implementation dependent.
tx_boundary
This variable is set to true whenever the transmit data stream reaches the start of a PHY frame 
during normal power operation in the data mode, or at the start of a transmit refresh cycle during 
low power idle operation. This variable is set to false at other times.
Values:
false:
transmit stream not at a boundary end
true:
transmit stream at a boundary end
tx_oam_field<8:0>
Nine bit 1000BASE-T1 OAM symbol inserted into a transmitted Reed-Solomon frame during nor-
mal power operation in the data mode, or into a transmitted refresh cycle during low power idle 
operation.
tx_oam<11 to 0><8:0>
Raw 12 symbol 1000BASE-T1 OAM frame transmitted from the PHY.
tx_lp_ready
Indicates whether the link partner is ready to receive the next 1000BASE-T1 OAM message from 
the PHY. If ready, then the PHY will load the next 1000BASE-T1 OAM message from the regis-
ters and begin transmitting them.
Values:
0:
not ready
1:
ready
tx_toggle
The toggle bit value being send in the current 1000BASE-T1 OAM frame transmitted by the PHY.
Values:
The value can be 0 or 1.
97.3.8.4.4 Counters
rx_cnt
A count of received 1000BASE-T1 OAM frames.
Values:
The value can be any integer from 0 to 12, inclusive.
tx_cnt
1000BASE-T1 OAM frame transmit symbol count.
Values:
The value can be any integer from 0 to 12, inclusive.


97.3.8.4.5 Functions
CRC16(10 octets)
This function outputs a 16-bit CRC value using 10-octet input as defined in 97.3.8.2.12.
CRC16_Check(12 octets)
This function checks whether the 12-octet frame has the correct CRC16 as defined in 97.3.8.2.12.
Values:
BAD:
CRC16 check is bad
GOOD:
CRC16 check is good 
Parity(12 octets)
This function outputs 12 parity bits, one for each of the 12 input octets. An even parity bit is output 
for the first octet, and odd parity bits are output for each of the remaining 11 octets. 
Parity_Check(9-bit symbol)
This function calculates the bit parity of the 9-bit symbol.
Values:
Even:
symbol has even parity
Odd:
symbol has odd parity


97.3.8.4.6 State diagrams
Figure 97–17—Receive state diagram
RECEIVE INIT
rx_lp_valid  0
rx_lp_toggle 0
rx_lp_ping 0
rx_lp_ack 0
rx_ack 0
rx_ack_toggle 0
rx_exp_toggle 0
rx_cnt 0
mr_rx_lp_valid 0
mr_rx_lp_toggle 0
mr_rx_ping  0
mr_rx_lp_SNR[1:0]  00
mr_rx_lp_message_num[3:0]  0
mr_rx_lp_message[63:0]  0
reset + (link_status = FAIL)
CHECK READ
if ((rx_lp_valid = 0) + (rx_lp_ack = 0))
then
rx_exp_toggle  rx_lp_toggle
rx_lp_ack  0
LOAD RECEIVE PAYLOAD
mr_rx_lp_SNR[1:0]  rx_oam<0><1:0>
rx_lp_ping  rx_oam<0><2>
mr_rx_ping  rx_oam<0><3>
rx_lp_valid  rx_oam<1><7>
rx_lp_toggle  rx_oam<1><6>
rx_ack  rx_oam<1><5>
rx_ack_toggle  rx_oam<1><4>
if ((mr_rx_lp_valid = 0) * (rx_oam<1><7> = 1) *
(rx_oam<1><6> = rx_exp_toggle)) then
mr_rx_lp_message_num[3:0]  rx_oam<1><3:0>
mr_rx_lp_message[8n+7:8n]  rx_oam<n+2><7:0>
where n = 0 to 7
mr_rx_lp_toggle  rx_oam<1><6>
mr_rx_lp_valid  1
rx_exp_toggle  ~rx_oam<1><6>
rx_lp_ack  1
LOAD EVEN PARITY
rx_oam<rx_cnt><7:0>  rx_oam_field<7:0>
rx_cnt  1
LOAD ODD PARITY
rx_oam<rx_cnt><7:0>  rx_oam_field<7:0>
rx_cnt  rx_cnt + 1
BAD CRC16
rx_cnt  0
(rx_cnt = 12) *
(CRC16_Check(rx_oam<11 to 0><7:0>) = GOOD)
Parity_Check(rx_oam_field<8:0>) = Even
Parity_Check(rx_oam_field<8:0>) = Odd
(rx_cnt = 12) *
(CRC16_Check(rx_oam<11 to 0><7:0>) = BAD)
rx_boundary
rx_boundary
rx_boundary
rx_boundary


 
Figure 97–18—Transmit state diagram
TRANSMIT INIT
tx_toggle  0
tx_lp_ready 1
tx_oam<9 to 0><7:0> 0
tx_oam_field<8:0> 0
mr_tx_valid 0
mr_tx_toggle 0
mr_tx_received 0
mr_tx_received_toggle 0
mr_tx_ping 0
mr_tx_SNR[1:0] 00
LOAD TRANSMIT PAYLOAD
mr_tx_SNR[1:0]  SNR[1:0]
tx_oam<0><1:0>  SNR[1:0]
tx_oam<0><2>  mr_tx_ping
tx_oam<0><3>  rx_lp_ping
tx_oam<1><5>  rx_lp_ack
tx_oam<1><4>  mr_rx_lp_toggle
tx_oam<1><6>  tx_toggle
if ((mr_tx_valid = 1) * (tx_lp_ready = 1)) then
tx_oam<1><7> 1
tx_oam<1><3:0> mr_tx_message_num[3:0]
tx_oam<n+2><7:0> mr_tx_message[8n+7:8n]
where n = 0 to 7
mr_tx_valid 0
mr_tx_toggle ~mr_tx_toggle
tx_lp_ready  0
CHECK ACK
if ((rx_ack = 1) * (rx_ack_toggle = tx_toggle)) then
tx_toggle mr_tx_toggle
tx_lp_ready 1
tx_oam<1><7> 0
mr_tx_received 1
mr_tx_received_toggle rx_ack_toggle
CALC CRC16
(tx_oam<11><7:0>, tx_oam<10><7:0>)  CRC16(tx_oam<9 to 0><7:0>)
CALC PARITY
tx_oam<11 to 0><8>  Parity(tx_oam<11 to 0><7:0>)
tx_cnt  0
TRANSMIT SYMBOL
tx_oam_field<8:0>  tx_oam<tx_cnt><8:0>
tx_cnt  tx_cnt + 1
reset + link_status = FAIL
tx_boundary
UCT
UCT
UCT
UCT
(tx_cnt < 12) * tx_boundary
(tx_cnt = 12) * tx_boundary


97.4 Physical Medium Attachment (PMA) sublayer
97.4.1 PMA functional specifications
The PMA couples messages from a PMA service interface specified in 97.2.2 to the 1000BASE-T1 
baseband medium, specified in 97.5. 
The interface between PMA and the baseband medium is the Medium Dependent Interface (MDI), which is 
specified in 97.7.
97.4.2 PMA functions
The PMA sublayer comprises one PMA Reset function and five simultaneous and asynchronous operating 
functions. The PMA operating functions are PHY Control, PMA Transmit, PMA Receive, Link Monitor, 
and Clock Recovery. All operating functions are started immediately after the successful completion of the 
PMA Reset function. 
LINK
MONITOR
PMA_LINK.request 
config
tx_mode
loc_rcvr_status
rem_rcvr_status / rem_phy_ready
recovered_clock
PMA_UNITDATA.request
PMA_UNITDATA.indication
link_status
(link_control)
NOTE—The recovered_clock arc is shown to indicate delivery of the recovered clock signal back to PMA TRANSMIT for loop timing.
scr_status / pcs_status
 (tx_symb)
 (rx_symb)
PMA_LINK.indication 
(link_status)
MDI+
MDI-
PMA
RECEIVE
PMA
TRANSMIT
received_
CLOCK
RECOVERY
PHY
CONTROL
MEDIUM
INTERFACE
DEPENDENT
(MDI)
PMA SERVICE
INTERFACE
Figure 97–19—PMA reference diagram
clock
Technology Dependent Interface (optional)
rx_lpi_active
tx_lpi_active
 loc_phy_ready
LINK
SYNCHRO
NIZATION
sync_link_control
sync_tx_symb


The PMA reference diagram, Figure 97–19, shows how the operating functions relate to the messages of the 
PMA Service interface and the signals of the MDI. Connections from the management interface, comprising 
the signals MDC and MDIO, to other layers are pervasive and are not shown in Figure 97–19.
97.4.2.1 PMA Reset function
The PMA Reset function shall be executed whenever one of the two following conditions occur:
a)
Power for the device containing the PMA has not reached the operating state
b)
The receipt of a request for reset from the management entity
PMA Reset sets pma_reset = ON while any of the above reset conditions hold true. All state diagrams take 
the open-ended pma_reset branch upon execution of PMA Reset. The reference diagrams do not explicitly 
show the PMA Reset function.
The 1000BASE-T1 PMA takes no longer than 100 ms to enter the PCS_DATA state after exiting from reset 
or low power mode (see Figure 97–26).
97.4.2.2 PMA Transmit function
The PMA Transmit function comprises a transmitter to generate a three level modulated signal on the single 
twisted-pair copper cable. PMA Transmit shall continuously transmit onto the MDI pulses modulated by the 
symbols given by tx_symb when sync_link_control = ENABLE, or the sync_tx_symb output by the PHY 
Link Synchronization function when sync_link_control = DISABLE, after processing with optional transmit 
filtering, digital-to-analog conversion (DAC) and subsequent analog filtering. The signals generated by 
PMA Transmit shall comply with the electrical specifications given in 97.5. 
When the PMA_CONFIG.indication parameter config is MASTER, the PMA Transmit function shall 
source TX_TCLK from a local clock source while meeting the transmit jitter requirements of 97.5.3.3. The 
MASTER-SLAVE relationship shall include loop timing. If the PMA_CONFIG.indication parameter config 
is SLAVE, the PMA Transmit function shall source TX_TCLK from the recovered clock of 97.4.2.8 while 
meeting the jitter requirements of 97.5.3.3.
97.4.2.2.1 Global PMA transmit disable
When the PMA_transmit_disable variable is set to true, this function shall turn off the transmitter so that the 
transmitter Average Launch Power of the Transmitter is less than –53 dBm.
97.4.2.3 PMA Receive function
The PMA Receive function comprises a receiver for PAM3 signals on the twisted-pair. PMA Receive 
contains the circuits necessary to both detect symbol sequences from the signals received at the MDI over 
receive pair and to present these sequences to the PCS Receive function. The PMA translates the signals 
received on the twisted-pair into the PMA_UNITDATA.indication parameter rx_symb. The quality of these 
symbols shall allow RFER of less than 3.6  10–7 after RS-FEC decoding, over a channel meeting the 
requirements of 97.6. 
To achieve the indicated performance, it is highly recommended that PMA Receive include the functions of 
signal equalization and echo cancellation. The sequence of symbols assigned to tx_symb is needed to 
perform echo cancellation.
The PMA Receive function uses the scr_status parameter and the state of the equalization, cancellation, and 
estimation functions to determine the quality of the receiver performance, and generates the loc_rcvr_status 
variable accordingly. The loc_rcvr_status variable is expected to become NOT_OK when the link partner’s 


tx_mode changes to SEND_Z from any other values (see PHY Control state diagram in Figure 97–26). The 
precise algorithm for generation of loc_rcvr_status is implementation dependent.
The receiver uses the sequence of symbols during the training sequence to detect and correct for pair polarity 
swaps. 
The PMA Receive fault function is optional. The PMA Receive fault function is the logical OR of the 
link_status = FAIL and any implementation specific fault. If the MDIO interface is implemented, then this 
function shall contribute to the receive fault bit specified in 45.2.1.238.6.
97.4.2.4 PHY Control function
PHY Control generates the control actions that are needed to bring the PHY into a mode of operation during 
which frames can be exchanged with the link partner. PHY Control shall comply with the state diagram 
description given in Figure 97–26.
During PMA training (TRAINING and COUNTDOWN states in Figure 97–26), PHY Control information 
is exchanged between link partners with a 12-octet InfoField, which is XORed with the first 96 bits of the 
15th partial PHY frame (bits 2520 to 2615) of the PHY frame. The InfoField is also denoted IF. The link 
partner is not required to decode every IF transmitted but is required to decode IFs at a rate that enables the 
correct actions prior to the PAM2 to PAM3 transition. 
The 12-octet InfoField shall include the fields in 97.4.2.4.2 through 97.4.2.4.8, also shown in the overview 
Figure 97–20, and the more detailed Figure 97–21 and Figure 97–22. Each InfoField shall be transmitted at 
least 256 times to ensure detection at link partner.
  
Figure 97–20—InfoField format
0xBB
0xA7
0x00
PFC24
Message MSG24 MSG24 MSG24
CRC16
octet 1
octet 2
octet 3
octets 4/5/6
octet 7
octets 8/9/10
octets 11/12
Figure 97–21—InfoField TRAINING format
0xBB
0xA7
0x00
PFC24
Message
SeedUsrCfgCap
CRC16
octet 1
octet 2
octet 3
octets 4/5/6
octet 7
octets 8/9/10
octets 11/12
PMA_state = 00
Figure 97–22—InfoField COUNTDOWN format
0xBB
0xA7
0x00
PFC24
Message
DataSwPFC24
CRC16
octet 1
octet 2
octet 3
octets 4/5/6
octet 7
octets 8/9/10
octets 11/12
PMA_state = 01


97.4.2.4.1 InfoField notation
For all the InfoField notations in the following subclauses, Reserved<bit location> represents any unused 
values and shall be set to zero on transmit and ignored when received by the link partner. The InfoField is 
transmitted following the notation described in 97.3.2.2.3 where the LSB of each octet is sent first and the 
octets are sent in increasing number order (that is, the LSB of Oct1 is sent first).
97.4.2.4.2 Start of Frame Delimiter
The start of Frame Delimiter consists of 3 octets [Oct1<7:0>, Oct2<7:0>, Oct3<7:0>] and shall use the 
hexadecimal value 0xBBA700. 0xBB corresponds to Oct1<7:0> and so forth.
97.4.2.4.3 Partial PHY frame Count (PFC24)
The start of partial PHY frame Count consists of 3 octets [Oct4<7:0>, Oct5<7:0>, Oct6<7:0>] and indicates 
the running count of partial PHY frames sent LSB first. There are 15 partial PHY frames per PHY frame and 
the InfoField is embedded within the 15th partial PHY frame. The first partial PHY frame is zero, thus the 
first partial PHY frame count field after a reset is 14.
97.4.2.4.4 Message Field
Message Field (1 octet). For the MASTER, this field is represented by Oct7{PMA_state<7:6>, 
loc_rcvr_status<5>, en_slave_tx<4>, reserved<3:0>}. For the SLAVE, this field is represented by 
Oct7{PMA_state<7:6>, loc_rcvr_status<5>,  timing_lock_OK<4>, reserved<3:0>}.
The two state-indicator bits PMA_state<7:6> shall communicate the state of the transmitting transceiver to 
the link partner. PMA_state<7:6> = 00 indicates TRAINING, and PMA_state<7:6> = 01 indicates 
COUNTDOWN.
All possible Message Field settings are listed in Table 97–7 for the MASTER and Table 97–8 for the 
SLAVE. Any other value shall not be transmitted and shall be ignored at the receiver. The Message Field 
setting for the first transmitted PMA frame shall be the first row of Table 97–7 for the MASTER and the 
first or second row of Table 97–8 for the SLAVE. Moreover, for a given Message Field setting, the next 
Message Field setting shall be the same Message Field setting or the Message Field setting corresponding to 
a row below the current setting. When loc_rcvr_status = OK the InfoField variable is set to 
loc_rcvr_status<5> = 1 and set to 0 otherwise.
Table 97–7—InfoField message field valid MASTER settings
PMA_state<7:6>
loc_rcvr_status
en_slave_tx
reserved
reserved
reserved
reserved


97.4.2.4.5 PHY Capability Bits, User Configurable Register, and Data Mode Scrambler Seed
When PMA_state<7:6> = 00, then [0ct8<7:0>, 0ct9<7:0>, 0ct10<7:0>] contains the two PHY capability 
bits, the user configurable register bits, and the 15-bit data mode scrambler seed (Seed). Each octet is sent 
LSB first.
The format of PHY capability bits is Oct9<7> = EEEen and Oct10<0> = OAMen, indicating EEE and 
1000BASE-T1 OAM capability enable, respectively. The PHY shall indicate the support of optional 
capabilities by setting the corresponding capability bits.
The data mode scrambler seed contains bits S14 (sent first) to S0 (sent last) to indicate the initial state of the 
data mode transmit scrambler of the local device upon reaching the data switch partial PHY frame count. 
The state of the scrambler in Figure 97–9 shall be S14:S0 at the first bit of the first PHY frame when the 
partial PHY frame counter equals to the DataSwPFC24 value, see 97.4.2.4.6. The format of Seed is 
Oct8<7:0> = S<7:14> and Oct9<6:0> = S<0:6>. Seed S<14:0> shall not be all zeros. 
The remaining 7-bit Oct10<7:1> form a user-configurable register. See 97.4.2.4.11 for details.
97.4.2.4.6 Data Switch partial PHY frame Count
When PMA_state<7:6> = 01, then [Oct8<7:0>, Oct9<7:0>, Oct10<7:0>] contains the data switch partial 
PHY frame count (DataSwPFC24) sent LSB first. DataSwPFC24 indicates the partial PHY frame count 
when the transmitter switches from PAM2 to PAM3, which occurs at the start of an RS-FEC block. The last 
value of PFC24 prior to the transition is DataSwPFC24 - 1. DataSwPFC24 shall be set to an integer multiple 
of 15. This value of DataSwPFC24 guarantees that the switch from PAM2 to PAM3 occurs on a PHY frame 
boundary.
97.4.2.4.7 Reserved Fields
When PMA_state<7:6> is greater than 01, then [Oct8<1:0>, Oct9<1:0>, Oct10<7:0>] contains a reserved 
field. All InfoField fields denoted Reserved are reserved for future use.
97.4.2.4.8 CRC16
CRC16 (2 octets) shall implement the CRC16 polynomial (x+1)(x15+x+1) of the previous 7 octets, 
Oct4<7:0>, Oct5<7:0>, Oct6<7:0>, Oct7<7:0>, Oct8<7:0>, Oct9<7:0>, and Oct10<7:0>. The CRC16 shall 
produce the same result as the implementation shown in Figure 97–23. In Figure 97–23 the 16 delay 
elements S0,..., S15, shall be initialized to zero. Afterwards Oct4 through Oct10 are used to compute the 
CRC16 with the switch connected, which is setting CRCgen in Figure 97–23. After all the 7 octets have 
Table 97–8—InfoField message field valid SLAVE settings
PMA_state<7:6>
loc_rcvr_status
timing_lock_OK
reserved
reserved
reserved
reserved


been processed, the switch is disconnected (setting CRCout) and the 16 values stored in the delay elements 
are transmitted in the order illustrated, first S15, followed by S14, and so on, until the final value S0.
97.4.2.4.9 PMA MDIO function mapping
The MDIO capability described in Clause 45 defines several variables that provide control and status 
information for and about the PMA. Mapping of MDIO control variables to PMA control variables is shown 
in Table 97–9. Mapping of MDIO status variables to PMA status variables is shown in Table 97–10. 
97.4.2.4.10 Startup sequence
The startup sequence shall comply with the state diagram description given in Figure 97–26. If the Auto-
Negotiation function is not implemented, or mr_autoneg_en = false, PMA_CONFIG is predetermined to be 
MASTER or SLAVE via management control during initialization or via default hardware setup.
The Auto-Negotiation function is optional for 1000BASE-T1 PHYs. If the Auto-Negotiation function is 
used, during the Auto-Negotiation process PHY Control is in the DISABLE_TRANSMITTER state and the 
transmitter is disabled. If the Auto-Negotiation function is not used, during the PHY Link Synchronization 
stage the PHY Control remains in the DISABLE_TRANSMITTER state and the Link Synchronization 
function (see 97.4.2.6) is the data source for the PMA Transmit function.
Table 97–9—MDIO/PMA control variable mapping
MDIO control variable
PMA register name
Register/bit 
number
PMA control variable
Reset
Control register 1 /
1000BASE-T1 PMA control register
1.0.15 /
1.2304.15 
pma_reset
Transmit disable
1000BASE-T1 PMA control register
1.2304.14
PMA_transmit_disable
Table 97–10—MDIO/PMA status variable mapping
MDIO status variable
PMA register name
Register/bit 
number
PMA status variable
Receive fault
1000BASE-T1 PMA status register
1.2305.1
PMA_receive_fault
Figure 97–23—CRC16
S0
+
S1
S2
S14
+
S15
+
CRC16 output
Oct4 through Oct10
Logic 0
CRCgen
CRCout


When the Auto-Negotiation asserts link_control = ENABLE, or PHY Link Synchronization process asserts 
sync_link_control = ENABLE, PHY Control enters the INIT_MAXWAIT_TIMER state. Upon entering the 
INIT_MAXWAIT_TIMER state, the maxwait_timer is started. PHY Control then transitions to the SILENT 
state where the minwait_timer is started and the PHY transmits zeros (tx_mode = SEND_Z).
In MASTER mode PHY Control transitions to the TRAINING state once the minwait_timer expires. 
Upon entering the TRAINING state, the minwait_timer is started and the PHY Control asserts 
tx_mode = SEND_T sending PAM2 together with InfoFields. The PHY Control also sets PMA_state = 00 
and sends the PHY capability bits, the user configurable register bits, and the Seed value used by the local 
device for the data mode scrambler initialization, see 97.4.2.4.5.
The optional EEE capability shall be enabled only if both PHYs set the capability bit EEEen = 1. The 
optional 1000BASE-T1 OAM capability shall be enabled only if both PHYs set the capability bit 
OAMen = 1.
Initially the MASTER is not ready for the SLAVE to respond and sets en_slave_tx = 0, which is 
communicated to the link partner via the InfoField. After the MASTER has sufficiently converged the 
necessary circuitry, the MASTER shall set en_slave_tx = 1 to allow the SLAVE to transition to TRAINING.
In SLAVE mode PHY Control transitions to the TRAINING state only after the SLAVE PHY acquires 
timing, converges its equalizers, acquires its descrambler state and sets loc_SNR_margin = OK. The 
SLAVE shall align its transmit 81B-RS frame to within +0/–1 partial PHY frames of the MASTER as seen 
at the SLAVE MDI. The SLAVE InfoField partial PHY frame Count shall match the MASTER InfoField 
partial PHY frame Count for the aligned frame.
Upon entering TRAINING state the SLAVE initially sets timing_lock_OK = 0 until it has acquired timing 
lock at which point the SLAVE sets timing_lock_OK = 1.
After the PHY completes successful training and establishes proper receiver operations, PCS Transmit 
conveys this information to the link partner via transmission of the parameter InfoField value 
loc_rcvr_status. The link partner’s value for loc_rcvr_status is stored in the local device parameter 
rem_rcvr_status. Upon expiration of the minwait_timer and when the condition loc_rcvr_status = OK and 
rem_rcvr_status = OK is satisfied, PHY control transitions to the COUNTDOWN state.
Upon entering the COUNTDOWN state, PHY Control sets PMA_state = 01 and DataSwPFC24 to the value 
of the partial PHY frame count when the transmitter switches from PAM2 to PAM3.
Upon reaching DataSwPFC24 partial PHY frame count PHY Control transitions to the SEND_IDLE1 state 
and forces transmission into the idle mode by asserting tx_mode = SEND_I.
Once the link partner has transitioned from PAM2 to PAM3, PHY Control transitions to the SEND_IDLE2 
state and starts the minwait_timer.
Upon 
expiration 
of 
the 
minwait_timer 
and 
when 
the 
condition 
loc_phy_ready = OK 
and 
rem_phy_ready = OK is satisfied, PHY control transitions to the SEND_DATA state.
Upon entering the SEND_DATA state, PHY Control starts the minwait_timer and enables frame 
transmission to the link partner by asserting tx_mode = SEND_N.
The operation of the maxwait_timer requires that the PHY complete the startup sequence from state 
INIT_MAXWAIT_TIMER to SEND_DATA in the PHY Control state diagram state diagram (Figure 97–26) 
in less than 97.5 ms to avoid link_status being changed to FAIL by the Link Monitor state diagram 
(Figure 97–27).


97.4.2.4.11 PHY Control Registers
The PHY control registers are shown in Table 97–11.
97.4.2.5 Link Monitor function
Link Monitor determines the status of the underlying receive channel and communicates it via the variable 
link_status. Failure of the underlying receive channel causes the PMA to set link_status to FAIL, which in 
turn causes the PMA’s clients to stop exchanging frames and restart the auto-negotiation (if enabled) or 
synchronization (if auto-negotiation is not enabled) process. 
The Link Monitor function shall comply with the state diagram of Figure 97–27.
Upon power on, reset, or release from power down, the Auto-Negotiation function set 
link_control = DISABLE, or PHY Link Synchronization algorithms set sync_link_control = DISABLE. 
During this period, link_status = FAIL is asserted. When the Auto-Negotiation function establishes the 
presence of a remote 1000BASE-T1 PHY, link_control is set to ENABLE, or when the PHY Link 
Synchronization finishes the synchronization function, sync_link_control is set to ENABLE, and the Link 
Monitor state machines begins monitoring the PCS and receiver lock status. As soon as reliable transmission 
is achieved, the variable link_status = OK is asserted, upon which further PHY operations can take place.
Table 97–11—PHY Control Registers
MDIO control/status 
variable 
PMA register name 
Register/bit number 
PMA control/status 
variable
MASTER-SLAVE
BASE-T1 PMA/PMD 
control register
1.2100.14
force_config 
(see 97.4.2.6.1)
Type selection
BASE-T1 PMA/PMD 
control register
1.2100.3:0
force_PHY_type 
(see 97.4.2.6.1)
1000BASE-T1 OAM 
Ability
1000BASE-T1 PMA 
status register
1.2305.11
EEE Ability
1000BASE-T1 PMA 
status register
1.2305.10
User Field
1000BASE-T1 training 
register
1.2306.10:4
PMA_state<7:6> 
= 00, Oct10<7:1>
1000BASE-T1 OAM 
Advertisement
1000BASE-T1 training 
register
1.2306.1
PMA_state<7:6> 
= 00, Oct10<0>
EEE Advertisement
1000BASE-T1 training 
register
1.2306.0
PMA_state<7:6> 
= 00, Oct9<7>
Link Partner User Field
1000BASE-T1 link 
partner training register
1.2307.10:4
LP PMA_state<7:6> 
= 00, Oct10<7:1>
Link Partner 1000BASE-
T1 OAM Advertisement
1000BASE-T1 link 
partner training register
1.2307.1
LP PMA_state<7:6> 
= 00, Oct10<0>
Link Partner EEE 
Advertisement
1000BASE-T1 link 
partner training register
1.2307.0
LP PMA_state<7:6> 
= 00, Oct9<7>


97.4.2.6 PHY Link Synchronization
If the optional Clause 98 Auto-Negotiation function is disabled or not implemented, then the Link 
Synchronization function is responsible for establishing the start of PHY PMA training as defined in 
97.4.2.4. 
When operating, the Link Synchronization function is the data source for the PMA Transmit function (see 
97.4.2.2) and generates a signal, SEND_S, used by the MASTER and SLAVE to discover the link partner 
and synchronize the start of PMA training. 
Link Synchronization employs the SEND_S signal to achieve synchronization prior to link training. If the 
PHY is configured as MASTER, Link Synchronization shall employ Equation (97–8) as the PN sequence 
generator.
 
(97–8)
If the PHY is configured as SLAVE, Link Synchronization shall employ Equation (97–9) as PN sequence 
generator.
 
(97–9)
The period of both PN sequences is 255.
An implementation of MASTER and SLAVE PHY SEND_S PN sequence generators by linear-feedback 
shift registers is shown in Figure 97–24. The bits stored in the shift register delay line at time n are denoted 
by Sn[7:0]. At each symbol period, the shift register is advanced by one bit, and one new bit represented by 
Sn[0] is generated. The PN sequence generator shift registers shall be reset to a non-zero value upon 
entering into the TRANSMIT_DISABLE state (see Figure 97–25). The receiver may not necessarily receive 
a continuous PN sequence between separate periods of SEND_S.
The bit Sn[0] is mapped to the transmit symbol Tn as follows: if Sn[0] = 0 then Tn = +1, if Sn[0] = 1 then 
Tn = –1.
pM x

x8
x4
x3
x2
+
+
+
+
=
pMS x

x8
x6
x5
x4
+
+
+
+
=
Figure 97–24—SEND_S PN sequence generator by linear feedback shift registers Sn
T
MASTER PHY SEND_S PN sequence generator
T
Sn[0]
Sn[1]
+
T
Sn[2]
+
T
Sn[3]
+
T
Sn[4]
T
Sn[5]
T
Sn[6]
T
Sn[7]
T
T
Sn[0]
Sn[1]
SLAVE PHY SEND_S PN sequence generator
T
Sn[2]
T
Sn[3]
+
T
Sn[4]
+
T
Sn[5]
+
T
Sn[6]
T
Sn[7]


The synchronization state diagram in Figure 97–25 shall be used to synchronize 1000BASE-T1 PHYs prior 
to the 1000BASE-T1 link training. If Clause 98 Auto-Negotiation function is enabled, then the Auto-
Negotiation function shall be used as the mechanism for PHY synchronization and the synchronization state 
diagram in Figure 97–25 remains in the SYNC_DISABLE state.
97.4.2.6.1 State diagram variables
force_config
This variable indicates whether the PHY operates as a MASTER or as a SLAVE. The variable 
takes on one of the following values:
MASTER:
this value is continuously asserted when the PHY operates as a MASTER
SLAVE:
this value is continuously asserted when the PHY operates as a SLAVE
force_phy_type
This variable indicates what speed the PHY is to operate when Auto-Negotiation is disabled or not 
implemented. The variable takes on one of the following values:
1000-T1:
 if Auto-Negotiation is disabled or not implemented and 1000BASE-T1 is 
selected
100-T1: 
if Auto-Negotiation is disabled or not implemented and 100BASE-T1 is selected
None: 
else
link_status
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive. This variable takes the values of OK or FAIL.
mr_autoneg_enable
See 98.5.1.
mr_main_reset
See 98.5.1.
power_on
See 98.5.1.
send_s_sigdet
This variable indicates whether the SEND_S pattern was detected. This variable shall be set false 
no later than 1 µs after the signal goes quiet on the MDI. 
Values:
true:
SEND_S pattern detected
false:
SEND_S pattern not detected
sync_link_control
This variable indicates the data source for the PMA Transmit function.
Values:
DISABLE:
The data source is the PHY Link Synchronization function (sync_tx_symb)
ENABLE:
The data source is PMA_UNITDATA.request (tx_symb)
sync_tx_mode
This variable indicates what symbols are sent by the PHY Link Synchronization process.
Values:
SEND_S:
this value is continuously asserted to enable transmission of the PN sequence
defined in 97.4.2.6
SEND_Z:
this value is asserted to disable transmission


97.4.2.6.2 State diagram timers
break_link_timer
See 98.5.2.
link_fail_inhibit_timer
See 98.5.2.
send_s_timer
This timer is used to control the duration SEND_S is transmitted. The timer shall expire 
1.0 µs ± 0.04 µs after being started. 
sigdet_wait_timer
This timer is used to control the wait time after transmitting or detecting the end of SEND_S. The 
timer shall expire 4 µs ± 0.1 µs after being started.
97.4.2.6.3 Messages
sync_tx_symb
A signal sent from Link Synchronization block to PMA Transmit indicating that a PAM2 
(SEND_S) or zero (SEND_Z) symbol is available. The Link Synchronization block generates 
sync_tx_symb synchronously with every transmit clock cycle.


97.4.2.6.4 State diagrams
Figure 97–25—PHY Link Synchronization state diagram
TRANSMIT_DISABLE
start break_link_timer
sync_tx_mode SEND_Z
sync_link_control DISABLE
SILENT WAIT
sync_tx_mode  SEND_Z
A
B
A
A
LINK_GOOD
B
TX_SEND_S
start send_s_timer
sync_tx_mode  SEND_S
A
SIGDET_WAIT
start sigdet_wait_timer
sync_tx_mode  SEND_Z
PAUSE
start sigdet_wait_timer
sync_tx_mode  SEND_Z
LINK_GOOD_CHECK
start link_fail_inhibit_timer
sync_link_control  ENABLE
sigdet_wait_timer_done *
force_config = MASTER
send_s_sigdet = false *
force_config = SLAVE
send_s_timer_done *
force_config = MASTER
send_s_timer_done *
force_config = SLAVE
SYNC_DISABLE
break_link_timer_done *
force_config = MASTER
break_link_timer_done *
force_config = SLAVE
send_s_sidget = true
send_s_sigdet = false *
force_config = MASTER
sigdet_wait_timer_done
link_status = OK
power_on = true +
mr_main_reset = true +
mr_autoneg_enable = true +
link_fail_inhibit_timer_done
link_status = FAIL
mr_autoneg_enable = false
force_phy_type  1000-T1


97.4.2.7 Refresh Monitor function
A 1000BASE-T1 PHY supporting the EEE capability shall implement the Refresh monitor function. The 
Refresh monitor operates when the PHY is in the LPI receive mode. If Refresh is not reliably detected 
within a moving window of 50 Q/R cycles (4.32 ms), the refresh monitor shall set PMA_refresh_status to 
FAIL, which sets link_status to FAIL. Subsequently the PHY restarts auto-negotiation (if auto-negotiation is 
enabled) or synchronization (if auto-negotiation is disabled). PMA_refresh_status shall be set to OK when 
the Link Monitor state diagram (Figure 97–27) enters the LINK_UP state.
97.4.2.8 Clock Recovery function
The Clock Recovery function shall provide a clock suitable for signal sampling so that the RS FER indicated 
in 97.4.2.3 is achieved. The received clock signal is expected to be stable and ready for use when training 
has been completed. The received clock signal is supplied to the PMA Transmit function by received_clock.
97.4.3 MDI
Communication through the MDI is summarized in 97.4.3.1 and 97.4.3.2.
97.4.3.1 MDI signals transmitted by the PHY
The symbols to be transmitted by the PMA are denoted by tx_symb. The modulation scheme used over each 
pair is PAM3. PMA Transmit generates a pulse-amplitude modulated signal on each pair in the following 
form:
(97–10)
In Equation (97–10), an is the PAM3 modulation symbol from the set {–1, 0, 1} to be transmitted at 
time 
, and 
 denotes the system symbol response at the MDI. This symbol response shall comply 
with the electrical specifications given in 97.5.
97.4.3.2 Signals received at the MDI 
Signals received at the MDI can be expressed for each pair as pulse-amplitude modulated signals that are 
corrupted by noise as follows:
(97–11)
In Equation (97–11) hR(t) denotes the symbol response of the overall channel impulse response between the 
transmit symbol source and the receive MDI and w(t) represents the contribution of various noise sources 
including uncancelled echo. The receive signal is processed within the PMA Receive function to yield the 
received symbols rx_symb.
97.4.4 State variables
97.4.4.1 State diagram variables
auto_neg_imp
This variable indicates if an optional Auto-Negotiation sublayer is associated with the PMA.
Values:
true:
An optional Auto-Negotiation sublayer is associated with the PMA
false:
An optional Auto-Negotiation sublayer is not associated with the PMA
s t
anhT t
nT
–


n
=


=
nT
hT t
r t
anhR t
nT
–


w t
+
n
=


=


config
The PMA generates this variable continuously and passes it to the PCS via the PMA_CON-
FIG.indication primitive. 
Values:
MASTER
SLAVE
en_slave_tx
The en_slave_tx variable in the InfoField received by the SLAVE. 
Values:
0: 
Master is not ready for the SLAVE to transmit
1: 
Master is ready for the SLAVE to transmit
infofield_complete
This variable indicates that a complete set of InfoField messages has been sent (see 97.4.2.4).
Values:
false: 
a complete set of InfoField messages has not been sent
true: 
a complete set of InfoField messages has been sent
link_control
This variable is defined in 97.2.1.1.1.
link_status
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive. This variable takes the values of OK or FAIL.
loc_phy_ready
This variable is set by the PMA Receive function to indicate the local PHY is ready or not ready to 
receive data. The value of loc_phy_ready is equal to OK only if loc_rcvr_status = OK and 
pcs_status = OK. Otherwise its value is NOT_OK. This variable is conveyed to the link partner by 
the PCS as defined in Table 97–1.
Values:
OK:
the local PHY is ready to receive data
NOT_OK: 
the local PHY is not ready to receive data
loc_countdown_done
This variable is set to false when the PHY Control state diagram is in the 
DISABLE_TRANSMITTER state and is set to true immediately after transmitting the last bit of 
the DataSwPFC24–1 partial PHY frame.
loc_rcvr_status
Variable set by the PMA Receive function to indicate correct or incorrect operation of the receive 
link for the local PHY. This variable is transmitted in the loc_rcvr_status bit of the InfoField by the 
local PHY. 
Values:
OK: 
the receive link for the local PHY is operating reliably
NOT_OK: 
operation of the receive link for the local PHY is unreliable
loc_SNR_margin
This variable reports whether the local device has sufficient SNR margin to continue to the next 
state. The criterion for setting the parameter loc_SNR_margin is left to the implementer.
Values:
OK: 
the local device has sufficient SNR margin
NOT_OK: 
the local device does not have sufficient SNR margin


PMA_refresh_status
This variable indicates the status of the Refresh Monitor as described in 97.4.3. 
Values:
OK: 
refresh is detected reliably
FAIL:
refresh is not detected reliably
pma_reset
Allows reset of all PMA functions. It is set by PMA Reset.
Values:
ON
OFF
PMA_state
Variable for the value transmitted in the PMA_state<7:6> of the InfoField by the local PHY.
Values:
00: 
TRAINING state
01: 
COUNTDOWN state
PMA_watchdog_status
Variable indicating the status of the PAM3 monitor. 
Values:
OK: 
the local device has received sufficient PAM3 transitions
NOT_OK: 
the local device has not received sufficient PAM3 transitions
During normal operation NOT_OK is assigned when:
— PAM3 symbol 0 consecutively seen on the line for longer than 2 µs ± 0.1 µs
— PAM3 symbol +1 consecutively seen on the line for longer than 3.9 µs ± 0.1 µs
— PAM3 symbol –1 consecutively seen on the line for longer than 3.9 µs ± 0.1 µs
During Low Power Idle operation NOT_OK is assigned when:
—  PAM3 symbol not toggling on the line during one full refresh window
rem_countdown_done
This variable is set to false when the PHY Control state diagram is in the DISABLE_TRANSMIT-
TER state or SILENT state and is set to true once the receiver has transitioned from PAM2 to 
PAM3 mode and has received a valid PHY frame containing all IDLEs.
rem_phy_ready
This variable is set by the PCS Receive function to indicate whether the remote PHY is ready or 
not ready to receive data. This variable is received from the link partner by the PCS as defined in 
Table 97–1. The variable retains its value until the next normal Inter-Frame idle is received.
Values:
OK:
the remote PHY is ready to receive data
NOT_OK:
the remote PHY is not ready to receive data
rem_rcvr_status
Variable set by the PCS Receive function to indicate whether correct operation of the receive link 
for the remote PHY is detected or not. This variable is received in the loc_rcvr_status bit in the 
InfoField from the remote PHY. This variable is set to NOT_OK if the PCS has not decoded a 
valid InfoField from the remote PHY.
Values:
OK: 
the receive link for the remote PHY is operating reliably
NOT_OK: 
reliable operation of the receive link for the remote PHY is not detected


sync_link_control
This variable is defined in 97.4.2.6.1.
tx_mode
The PMA generates this variable continuously and passes it to the PCS via the PMA_TX-
MODE.indication primitive. 
Values:
SEND_N: 
this value is continuously asserted when transmission of sequences of symbols
representing a GMII data stream take place
SEND_I: 
this value is continuously asserted when transmission of sequences of symbols 
representing an idle stream takes place
SEND_T: 
this value is continuously asserted when transmission of sequences of symbols 
representing the training sequences of symbols is to take place
SEND_Z: 
this value is asserted when transmission of zero symbols is to take place
97.4.4.2 Timers
All timers operate in the manner described in 14.2.3.2.
maxwait_timer 
A timer used to limit the amount of time during which a receiver dwells in the SILENT and 
TRAINING states. The timer shall expire 97.5 ms  0.5 ms after being started. 
This timer is used jointly in the PHY Control and Link Monitor state diagrams. The maxwait_timer 
is tested by the Link Monitor to force link_status to be set to FAIL if either of the following 
conditions is true:
—
the PMA_watchdog_status is NOT_OK
—
the timer expires and loc_phy_ready is NOT_OK
—
the PMA_refresh_status is FAIL
See Figure 97–26 and Figure 97–27.
minwait_timer 
A timer used to determine the minimum amount of time the PHY Control stays in the SILENT, 
TRAINING, SEND IDLE2, and SEND DATA states. The timer shall expire 975 µs 50 µs after 
being started.


97.4.5 State diagrams
 
INIT_MAXWAIT_TIMER
start maxwait_timer
SILENT
tx_mode  SEND_Z
start minwait_timer
COUNTDOWN
tx_mode  SEND_T
PMA_state 01
SEND IDLE1
tx_mode  SEND_I
SEND DATA
tx_mode  SEND_N
start minwait_timer
TRAINING
tx_mode SEND_T
start minwait_timer
PMA_state 00
SEND IDLE2
tx_mode  SEND_I
start minwait_timer
(link_control = DISABLE *
auto_neg_imp = true * mr_autoneg_enable = true) +
(sync_link_control = DISABLE *
(auto_neg_imp = false + mr_autoneg_enable = false)) +
pma_reset = ON
(link_control = ENABLE *
auto_neg_imp = true * mr_autoneg_enable = true) +
(sync_link_control = ENABLE *
(auto_neg_imp = false + mr_autoneg_enable = false))
UCT
((config = MASTER) +
(config = SLAVE * loc_SNR_margin = OK *
en_slave_tx = 1)) * minwait_timer_done
loc_rcvr_status = OK * rem_rcvr_status = OK *
minwait_timer_done * infofield_complete
DISABLE_TRANSMITTER
loc_countdown_done * infofield_complete
rem_countdown_done
loc_phy_ready = OK *
rem_phy_ready = OK *
minwait_timer_done
loc_rcvr_status = NOT_OK
loc_rcvr_status = NOT_OK
loc_rcvr_status = NOT_OK
Figure 97–26—PHY Control state diagram


---

<a id='clause-98'></a>