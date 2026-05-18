# Clause 126: 2.5GBASE-T and 5GBASE-T

**Focus**: LDPC, PAM16 mapping, PMA digital interface, state machines  
**Pages extracted**: 5016 – 5092  
**Excluded from**: Page 5093 (electrical/PICS section)

126. Physical Coding Sublayer (PCS), Physical Medium Attachment (PMA) 
sublayer, and baseband medium, types 2.5GBASE-T and 5GBASE-T
126.1 Overview
The 2.5GBASE-T and 5GBASE-T PHYs are members of the 2.5 Gb/s and 5 Gb/s Ethernet family of high-
speed network specifications respectively. The 2.5GBASE-T PCS, PMA, and baseband medium 
specifications are intended for operation over balanced twisted-pair structured cabling systems. The 
5GBASE-T PCS, PMA, and baseband medium specifications are intended for operation over balanced 
twisted-pair structured cabling systems. 2.5GBASE-T and 5GBASE-T signaling both require four pairs of 
balanced cabling as specified in ISO/IEC 11801:2002 and ANSI/TIA-568-C.2.
This clause defines the types 2.5GBASE-T and 5GBASE-T PCS, PMA sublayers, and Medium Dependent 
Interfaces (MDI). Together, the PCS and PMA sublayers define a Physical Layer device (PHY). Functional, 
electrical, and mechanical specifications for the type 2.5GBASE-T PMA, 5GBASE-T PMA, and MDI are 
provided in this clause. This clause also specifies the baseband media used with 2.5GBASE-T and 
5GBASE-T. Management functions are optionally accessible through the management interface defined in 
Clause 45, or equivalent. Please refer to Table 125–2 for associated sublayers and options for assembling a 
2.5 Gb/s or 5 Gb/s system with the 2.5GBASE-T or 5GBASE-T PHY, respectively.
This clause also specifies 2.5GBASE-T and 5GBASE-T Low Power Idle (LPI) as part of Energy-Efficient 
Ethernet (EEE). This allows the PHY to enter a low power mode of operation during periods of low link 
utilization as described in Clause 78.
2.5GBASE-T and 5GBASE-T PHYs may optionally support a fast retrain mechanism. Implementation of 
the fast retrain option is recommended. Configurations wishing to disable fast retrain on the link may do so 
by advertising lack of support during link startup, thus preventing the link partner from attempting fast 
retrain and potentially dropping the link, see 45.2.7.10.
126.1.1 Nomenclature
The 2.5GBASE-T and 5GBASE-T PHYs described in this clause represent two distinct PHY types that
share the same PCS, PMA, and MDI specifications subject to frequency scaling. In order to efficiently 
describe the two PHYs, the nomenclature 2.5G/5GBASE-T is used to describe specifications that apply to 
both the 2.5GBASE-T and 5GBASE-T PHYs. Additionally, for parameters that scale with the PHYs data 
rate, the parameter S is used for scaling. For 2.5GBASE-T, S = 0.5 and for 5GBASE-T, S = 1.
126.1.2 Relationship of 2.5GBASE-T and 5GBASE-T to other standards
The relationships between the 2.5GBASE-T and 5GBASE-T PHYs, the ISO Open Systems Interconnection 
(OSI) reference model, and the IEEE 802.3 Ethernet model are shown in Figure 126–1. The PHY sublayers 
(shown shaded) in Figure 126–1 connect the IEEE 802.3 Ethernet MAC to the medium. The 2.5GBASE-T 
and 5GBASE-T PHY service interface is the XGMII, which is defined in Clause 46.


.
126.1.3 Operation of 2.5GBASE-T and 5GBASE-T
The 2.5GBASE-T PHY and 5GBASE-T PHY each employ full duplex baseband transmission over four 
pairs of balanced twisted-pair structured cabling. The aggregate data rates of 2.5 Gb/s or 5 Gb/s are achieved 
by transmitting one-quarter of the aggregate data rate in each direction simultaneously on each wire pair, as 
follows in Figure 126–2. Baseband 16-level PAM signaling with a modulation rate of 200 MBd for 
2.5GBASE-T and 400 MBd for 5GBASE-T is used on each of the wire pairs. Ethernet data and control 
characters are encoded at a rate of 3.125 information bits per PAM16 symbol, along with auxiliary bits. Each 
transmitted PAM16 symbol is considered as a single one-dimensional (1D) symbol. After link startup, PHY 
frames consisting of 512 PAM16 symbols are continuously transmitted. The PAM16 symbols are 
determined by 4-bit labels, each comprising 4 LDPC-encoded bits. The 512 PAM16 symbols of one PHY 
frame are transmitted as 4  128 PAM16 symbols over the four wire pairs. Data and Control symbols are 
embedded in a framing scheme that runs continuously after startup of the link. For 2.5GBASE-T, the 
modulation symbol rate of 200 MBd results in a symbol period of 5 ns, and for 5GBASE-T, the modulation 
symbol rate of 400 MBd results in a symbol period of 2.5 ns.
A 2.5GBASE-T or 5GBASE-T PHY can be configured either as a MASTER PHY or as a SLAVE PHY. The 
MASTER-SLAVE relationship between two stations sharing a link segment is established during Auto-
Negotiation (see Clause 28, 126.6, Annex 28B, Annex 28C, and Annex 28D). The MASTER PHY uses a 
local clock to determine the timing of transmitter operations. The MASTER-SLAVE relationship includes 
loop timing. The SLAVE PHY recovers the clock from the received signal and uses it to determine the 
timing of transmitter operations, i.e., it performs loop timing, as illustrated in Figure 126–3.
NOTE—Annex K defines optional alternative terminology for “master” and “slave”.
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
MAC
RECONCILIATION
HIGHER LAYERS
XGMII*
MDI
2.5GBASE-T
PMA
PCS
AN
MEDIUM
Figure 126–1—Types 2.5GBASE-T and 5GBASE-T PHYs relationship to the ISO Open 
Systems Interconnection (OSI) reference model and the IEEE 802.3 Ethernet model
LLC - LOGICAL LINK CONTROL
OR OTHER MAC CLIENT
MAC CONTROL (OPTIONAL)
PHY
2.5GBASE-T PCS
AN = AUTO-NEGOTIATION
PHY = PHYSICAL LAYER DEVICE
MAC = MEDIA ACCESS CONTROL
MDI = MEDIUM DEPENDENT INTERFACE
PCS = PHYSICAL CODING SUBLAYER
PMA = PHYSICAL MEDIUM ATTACHMENT
XGMII = 10 GIGABIT MEDIA INDEPENDENT INTERFACE
RECONCILIATION
XGMII*
MDI
5GBASE-T
PMA
PCS
AN
MEDIUM
PHY
5GBASE-T PCS
*XGMII IS OPTIONAL


2.5GBASE-T and 5GBASE-T PHYs optionally provide support for LPI as part of EEE (see Clause 78). This 
extension allows PHYs to enter an LPI mode when either the local or link partner system requests low power 
operation. The transmit and receive functions may enter and leave the LPI mode independently so that both 
symmetric and asymmetric operation is supported. While the PHY is in the LPI mode, the PHY periodically 
transmits a refresh signal to allow the remote PHY to refresh its receiver state (e.g., timing recovery, adap-
tive filter coefficients) and thereby track long-term variation in the timing of the link or the underlying chan-
nel characteristics. An easily detectable alert signal is transmitted to signal an end to the LPI mode. The alert 
signal is followed by a wake signal to enable a rapid transition back to the normal operational mode.
2.5GBASE-T and 5GBASE-T PHYs may optionally support a fast retrain mechanism. This function allows 
PHYs to quickly recover from link degradation without a normal two-second retrain.
The PCS and PMA are summarized in 126.1.3.1 and 126.1.3.2. The EEE capability is summarized in 
126.1.3.3. Figure 126–3 shows the functional block diagram.


Tx
Rx
Tx
Rx
1250 S Mb/s
Figure 126–2—2.5GBASE-T and 5GBASE-T topology
MDI
MDI
Hybrid
Hybrid
Tx
Rx
Tx
Rx
1250 S Mb/s
Hybrid
Hybrid
Tx
Rx
Tx
Rx
1250 S Mb/s
Hybrid
Hybrid
Tx
Rx
Tx
Rx
1250 S Mb/s
Hybrid
Hybrid


PCS
PMA
received_
clock
PMA SERVICE
INTERFACE
recovered_
clock
rx_lpi_active
tx_mode
pcs_status
pcs_data_mode
alert_detect
(tx_symb_vector)
loc_rcvr_status
rem_rcvr_status
RXD<31:0>
Figure 126–3—Functional block diagram
NOTE 1—The recovered_clock arc is shown to indicate delivery of the received clock signal back to PMA TRANSMIT for loop timing.
NOTE 2—pcs_data_mode is required only for the EEE or fast retrain capabilities; alert_detect and rx_lpi_active are only required for 
the EEE capability; fr_active is only required for the fast retrain capability. Figures and capabilities only required for EEE are noted by 
dashed boxes.
PMA_LINK.request
BI_DD +
BI_DD –
BI_DA +
BI_DB +
BI_DA –
BI_DB –
BI_DC +
BI_DC –
(link_control)
PMA_LINK.indication
(link_status)
MEDIUM
INTERFACE
DEPENDENT
(MDI)
INDEPENDENT
INTERFACE
(XGMII)
10 GIGABIT MEDIA
RX_CLK
RXC<3:0>
PMA_UNITDATA.request
TX_CLK
TXC<3:0>
config
PMA_UNITDATA.indication
TXD<31:0>
(rx_symb_vector)
fr_active
Technology Dependent Interface (Clause 28)
PCS
TRANSMIT & 
TRANSMIT CONTROL
PCS 
RECEIVE
PMA 
RECEIVE
LINK 
MONITOR
PMA 
TRANSMIT
PHY 
CONTROL
CLOCK 
RECOVERY
link_status
scr_status


126.1.3.1 Summary of Physical Coding Sublayer (PCS)
The 2.5GBASE-T or 5GBASE-T PCS couples a 10 Gigabit Media Independent Interface (XGMII), as 
described in Clause 46, to the 2.5GBASE-T or 5GBASE-T Physical Medium Attachment (PMA) sublayer.
In addition to the normal mode of operation, the PCS supports a training mode. Furthermore, the PCS 
contains a management interface.
In the transmit direction (see Figure 126–6), in normal mode, the PCS receives eight XGMII data octets 
provided by two consecutive transfers on the XGMII service interface on TXD<31:0> and groups them into 
64-bit blocks with the 64-bit block boundaries aligned with the boundary of the two XGMII transfers. Each 
group of eight octets along with the data/control indications is transcoded into a 65-bit block. The resulting 
65-bit blocks are scrambled and assembled in a group of 25 blocks, yielding an Ethernet payload of 
25  65 = 1625 bits. Additionally, 97 zero-bits are appended, and a leading auxiliary bit is added to obtain a 
block of 1723 bits.
The 1723 bits are encoded by a systematic LDPC(1723,2048) encoder, which adds 325 LDPC check bits to 
form an LDPC codeword of 2048 coded bits. The 97 zero-bits are then replaced with vendor-defined random 
data. Implementers are cautioned that insufficient randomization can impact meeting PMA PSD mask 
requirements (see 126.5.3.4 for transmit PSD mask definition). The resulting 2048 bit LDPC frame is then 
divided into 512 4-bit labels, which are mapped into PAM16 modulation symbols.
The obtained PHY frame of 512 PAM16 symbols is passed on to the PMA as PMA_UNITDATA.request. 
The PMA transmits the PAM16 symbols over the four wire pairs in the form of 128 constituent PAM16 
symbols per pair.
In the receive direction (see Figure 126–7), in normal mode, the PCS processes code-groups received from 
the remote PHY via the PMA in 128 four-dimensional (4D) symbol blocks and maps them to the XGMII 
service interface in the receive path. In this receive processing scheme, symbol clock synchronization is 
done by the PMA Receive function. 
The signals provided by the PCS at the XGMII conform to the interface requirements of Clause 46. 
Details of the PCS functions and state diagrams are covered in 126.3. The interface to the PMA is an abstract 
message-passing interface specified in 126.2.
126.1.3.2 Summary of Physical Medium Attachment (PMA) sublayer
The PMA couples messages from the PCS service interface onto the balanced cabling physical medium via 
the Medium Dependent Interface (MDI) and provides the link management and PHY Control functions. The 
PMA provides full duplex communications at 400  S MBd over four pairs of balanced cabling up to 100 m 
in length.
The PMA Transmit function comprises four transmitters to generate continuous time analog signals on each 
of the four pairs BI_DA, BI_DB, BI_DC, and BI_DD, as described in 126.4.3.1. In normal mode, each 4D 
symbol received from the PCS Transmit function undergoes multiple stages of processing. First the symbol 
goes through a Tomlinson-Harashima precoder (THP), which maps the PAM16 input (as described in 
126.3.2.2.18) in each dimension of the 4D symbol into a quasi-continuous discrete-time value in the range 
. This THP-processed 4D symbol stream may be further processed by a digital transmit filter 
and is then passed on to four digital-to-analog converters (DACs). The DAC outputs may be further 
processed with continuous time filters to roll off the high-frequency spectral response to limit high-
frequency emissions and are then applied to each of the four balanced pairs via the MDI port.
–
x




The PMA Receive function comprises four independent receivers for pulse-amplitude modulated signals on 
each of the four pairs BI_DA, BI_DB, BI_DC, and BI_DD, as described in 126.4.3.2. The receivers are 
responsible for acquiring symbol timing and, when operating in normal mode, for canceling echo, near-end 
crosstalk, far-end crosstalk, and equalizing the signal. The 4D symbols are provided to the PCS Receive 
function via the PMA_UNITDATA.indication message. The PMA also contains functions for Link Monitor.
The PMA PHY Control function generates signals that control the PCS and PMA sublayer operations. PHY 
Control begins following the completion of Auto-Negotiation and provides the startup functions required for 
successful 2.5GBASE-T and 5GBASE-T operation. PHY Control determines whether the PHY operates in a 
normal mode, enabling data transmission over the link segment, or whether the PHY sends special PAM2 
code-groups that are used in the training mode.
PMA functions and state diagrams are specified in 126.4. PMA electrical specifications are given in 126.5.
The PMA sublayer may also support a fast retrain function. The fast retrain function is specified in 
126.4.2.5.16.
126.1.3.3 Summary of EEE capability
A 2.5GBASE-T or 5GBASE-T PHY may optionally support the EEE capability, as described in 78.1.4. The 
EEE capability is a mechanism by which 2.5GBASE-T and 5GBASE-T PHYs are able to reduce power 
consumption during periods of low link utilization. PHYs can enter this mode of operation after reaching 
PCS data mode. Each direction of the full duplex link is able to enter and exit the LPI mode independently, 
supporting symmetric and asymmetric LPI operation. This allows power savings when only one side of the 
full duplex link is in a period of low utilization. No data frames are lost or corrupted during the transition to 
or from the LPI mode.
In the transmit direction, the transition to the LPI transmit mode begins when the PCS transmit function 
detects an LPI control character in all four lanes of two consecutive transfers of TXD[31:0] that is then 
mapped into a single 64B/65B block, according to the position in the 2.5GBASE-T or 5GBASE-T LDPC 
frame. Following this event a sleep signal is transmitted by the PMA. The sleep signal is composed of LDPC 
frames that contain only LP_IDLE 64B/65B blocks. The sleep signal indicates to the link partner that the 
transmit function of the PHY is entering the LPI transmit mode. Immediately after the transmission of the 
sleep frames, the transmit function of the local PHY enters the LPI transmit mode. While the transmit 
function is in the LPI mode the PHY may disable data path and control logic to save additional power. 
Periodically the transmit function of the local PHY transmits refresh frames that are used by the link partner 
to update adaptive filters and timing circuits in order to maintain link integrity. The LPI mode begins with 
quiet signaling or with a full refresh period. Partial refreshes (defined as a refresh signal shorter than eight
LDPC frames) that immediately follow the transition to the LPI mode are replaced with quiet signaling. The 
quiet-refresh cycle continues until the PCS function detects IDLE characters on the XGMII. These 
characters signal to the PHY that the LPI transmit mode should end. The PMA Transmit function in the PHY 
then sends an alert message to the link partner. The alert signal begins on a LDPC 2-frame 256 4D-symbol 
boundary aligned to the inversion on pair A during PMA training, but has no fixed relationship to the quiet-
refresh cycle. The alert signal wakes the link partner from sleep. The alert signal is followed by a wake 
signal, composed of LDPC frames containing only IDLE 64B/65B blocks. After a short recovery time the 
normal operational mode is resumed.
In the receive direction the transition to the LPI mode is triggered when the PCS Receive function detects 
LPI control characters within received LDPC frames. This indicates that the link partner is about to enter the 
LPI transmit mode. Following these frames the link partner ceases transmission and begins quiet-refresh 
signaling. During the quiet time it is highly recommended that the local receiver power off circuits to reduce 
power consumption. Periodically the link partner transmits refresh frames that are used by the receiver to 
update adaptive coefficients and timing circuits. This quiet-refresh cycle continues until the link partner 
transmits the alert signal, initiating a transition back to the normal operational mode. The alert signal is 


detected in the PMA and signals that normal data frames will follow. The alert signal is followed by a wake 
signal that allows the local receiver time to prepare for the normal operational mode. The wake signal is 
composed of repeated IDLE 64B/65B blocks. After a short recovery time the normal operational mode is 
resumed.
Support for the EEE capability is advertised in the Infofield (Octet 12 bit 7) during link startup. Transitions 
to and from the LPI transmit mode are controlled via XGMII signaling. Transitions to and from the LPI 
receive mode are controlled by the link partner using sleep, alert, and wake signaling.
The PCS 64B/65B Transmit state diagram in Figure 126–14 and Figure 126–15 includes additional states for 
EEE. The PCS 64B/65B Receive state diagram in Figure 126–16 and Figure 126–17 includes additional 
states for EEE. The EEE Transmit state diagram is contained in the PCS Transmit function and is specified 
in Figure 126–18. 
126.1.4 Signaling
2.5GBASE-T and 5GBASE-T signaling is performed by the PCS generating continuous code-group 
sequences that the PMA transmits over each wire pair. The signaling scheme achieves a number of 
objectives including:
a)
Forward error correction (FEC) coded symbol mapping for data.
b)
Algorithmic mapping from TXD<31:0> and TXC<3:0> to 4D symbols in the transmit path.
c)
Algorithmic mapping from the received 4D signals on the MDI port to RXD<31:0> and RXC<3:0> 
on the XGMII interface.
d)
Uncorrelated symbols in the transmitted symbol stream.
e)
No correlation between symbol streams traveling both directions on any pair combination.
f)
No correlation between symbol streams on pairs BI_DA, BI_DB, BI_DC, and BI_DD.
g)
Block framing and other control signals.
h)
Ability to signal the status of the local receiver to the remote PHY to indicate that the local receiver 
is not operating reliably and requires retraining.
i)
Ability to automatically detect and correct for pair swapping and crossover connections.
j)
Ability to automatically detect and correct for incorrect polarity in the connections.
k)
Ability to automatically correct for differential delay variations across the wire-pairs.
l)
Ability to support refresh, quiet and alert signaling during LPI operation.
The PHY operates in two modes—normal mode or training mode. In normal mode, PCS generates a 
continuous stream of 4D symbols that are transmitted via the PMA at one of eight power levels. In training 
mode, the PCS is directed to generate only PAM2 symbols for transmission by the PMA, which enable the 
receiver at the other end to train until it is ready to operate in normal mode. (See 126.3.2.2 for description of 
PCS transmit modes.) 
PHYs may also support the EEE capability as described in 126.1.3.3. Transitions to the LPI mode are 
supported after reaching normal mode.
126.1.5 Interfaces
All 2.5GBASE-T and 5GBASE-T PHY implementations are compatible at the MDI and at the XGMII, if 
implemented. Implementation of the XGMII is optional. Designers are free to implement circuitry within the 
PCS and PMA in an application-dependent manner provided that the MDI and XGMII (if the XGMII is 
implemented) specifications are met. System operation from the perspective of signals at the MDI and 
management objects are identical whether the XGMII is implemented or not.


126.1.6 Conventions in this clause
The body of this clause contains state diagrams, including definitions of variables, constants, and functions. 
Should there be a discrepancy between a state diagram and descriptive text, the state diagram prevails. 
The notation used in the state diagrams follows the conventions of 21.5.
Default initializations, unless specified, are left to the implementer.
126.2 2.5GBASE-T and 5GBASE-T service primitives and interfaces
2.5GBASE-T and 5GBASE-T transfer data and control information across the following four service 
interfaces: 
a)
10 Gigabit Media Independent Interface (XGMII)
b)
Technology Dependent Interface
c)
PMA service interface
d)
Medium dependent interface (MDI)
The XGMII is specified in Clause 46; the Technology Dependent Interface is specified in Clause 28. The 
PMA service interface is defined in 126.2.2 and the MDI is defined in 126.8.
126.2.1 Technology Dependent Interface
2.5GBASE-T and 5GBASE-T use the following service primitives to exchange status indications and 
control signals across the Technology Dependent Interface as specified in Clause 28:
PMA_LINK.request (link_control)
PMA_LINK.indication (link_status)
126.2.1.1 PMA_LINK.request
This primitive allows the Auto-Negotiation algorithm to enable and disable operation of the PMA as 
specified in 28.2.6.2.
126.2.1.1.1 Semantics of the primitive
PMA_LINK.request (link_control)
The link_control parameter can take on one of three values: SCAN_FOR_CARRIER, DISABLE, or 
ENABLE. 
SCAN_FOR_CARRIER Used by the Auto-Negotiation algorithm prior to receiving any fast link
pulses. During this mode the PMA reports link_status=FAIL. PHY 
processes are disabled.
DISABLE
Set by the Auto-Negotiation algorithm in the event fast link pulses are
detected. PHY processes are disabled. This allows the Auto-Negotiation 
algorithm to determine how to configure the link.
ENABLE
Used by Auto-Negotiation to turn control over to the PHY for data 
processing functions.


126.2.1.1.2 When generated
Auto-Negotiation generates this primitive to indicate a change in link_control as described in Clause 28.
126.2.1.1.3 Effect of receipt
This primitive affects operation of the PMA Link Monitor function as defined in 126.4.2.6.
126.2.1.2 PMA_LINK.indication
This primitive is generated by the PMA to indicate the status of the underlying medium as specified in 
28.2.6.1. This primitive informs the Auto-Negotiation algorithm about the status of the underlying link.
126.2.1.2.1 Semantics of the primitive
PMA_LINK.indication (link_status)
The link_status parameter can take on one of two values: FAIL or OK.
FAIL
No valid link established.
OK
The Link Monitor function indicates that a valid 2.5GBASE-T
or 5GBASE-T link is established. Reliable reception of signals
transmitted from the remote PHY is possible.
126.2.1.2.2 When generated
The PMA generates this primitive to indicate a change in link_status in compliance with the state diagram 
given in Figure 126–29.
126.2.1.2.3 Effect of receipt
Auto-Negotiation uses this primitive to detect a change in link_status as described in Clause 28.
126.2.2 PMA service interface
2.5GBASE-T and 5GBASE-T use the following service primitives to exchange symbol vectors, status 
indications, and control signals across the service interfaces: 
PMA_TXMODE.indication (tx_mode)
PMA_CONFIG.indication (config)
PMA_UNITDATA.request (tx_symb_vector)
PMA_UNITDATA.indication (rx_symb_vector)
PMA_SCRSTATUS.request (scr_status)
PMA_PCSSTATUS.request (pcs_status)
PMA_RXSTATUS.indication (loc_rcvr_status)
PMA_REMRXSTATUS.request (rem_rcvr_status)
EEE-capable PHYs additionally support the following service primitives:
PMA_ALERTDETECT.indication (alert_detect)


PCS_RX_LPI_STATUS.request (rx_lpi_active)
PMA_PCSDATAMODE.indication (PCS_data_mode)
Fast retrain capable PHYs additionally support the following service primitive:
PMA_FR_ACTIVE.indication (fr_active)
The use of these primitives is illustrated in Figure 126–4. Connections from the management interface 
(signals MDC and MDIO) to the sublayers are pervasive and are not shown in Figure 126–4.
Figure 126–4—2.5GBASE-T and 5GBASE-T service interfaces
BI_DD +
BI_DD –
BI_DA +
BI_DB +
BI_DA –
BI_DB –
BI_DC +
BI_DC –
 
TXD<31:0>
TX_CLK
TXC<3:0>
RX_CLK
RXD<31:0>
RXC<3:0>
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
(XGMII)
10 GIGABIT MEDIA
PHY
PMA
PCS
Technology Dependent Interface (Clause 28)
PMA_PCSSTATUS.request
PMA_ALERTDETECT.indication
PCS_RX_LPI_STATUS.request
NOTE 1—PMA_PCSDATAMODE.indication is required only for the EEE or fast retrain capabilities. 
NOTE 2—PMA_ALERTDETECT.indication and PCS_RX_LPI_STATUS.request are only required for the EEE 
capability.
NOTE 3—PMA_FR_ACTIVE.indication is only required for the fast retrain capability.
PMA_PCSDATAMODE.indication
PMA_FR_ACTIVE.indication


126.2.2.1 PMA_TXMODE.indication
The transmitter in a 2.5GBASE-T or 5GBASE-T link normally sends over the four pairs, 4D symbols that 
represent an XGMII data stream with framing, scrambling and encoding of data, control information, or 
idles.
126.2.2.1.1 Semantics of the primitive
PMA_TXMODE.indication (tx_mode)
PMA_TXMODE.indication specifies to PCS Transmit via the parameter tx_mode what sequence of code-
groups the PCS should be transmitting. The parameter tx_mode can take on one of the following three 
values of the form:
SEND_N
This value is continuously asserted when transmission of sequences of 
4D symbols representing an XGMII data stream in
normal mode.
SEND_T
This value is continuously asserted in case transmission of sequences of 
code-groups representing the training mode is to take place.
SEND_Z
This value is continuously asserted in case transmission of zeros is required.
126.2.2.1.2 When generated
The PMA PHY Control function generates PMA_TXMODE.indication messages to indicate a change in 
tx_mode.
126.2.2.1.3 Effect of receipt
Upon receipt of this primitive, the PCS performs its transmit function as described in 126.3.2.2.
126.2.2.2 PMA_CONFIG.indication
Each PHY in a 2.5GBASE-T or 5GBASE-T link is capable of operating as a MASTER PHY and as a 
SLAVE PHY. MASTER-SLAVE configuration is determined during Auto-Negotiation (126.6.1). The result 
of this negotiation is provided to the PMA. 
126.2.2.2.1 Semantics of the primitive
PMA_CONFIG.indication (config)
PMA_CONFIG.indication specifies to PCS and PMA Transmit via the parameter config whether the PHY 
operates as a MASTER PHY or as a SLAVE PHY. The parameter config can take on one of the following 
two values of the form:
MASTER
This value is continuously asserted when the PHY operates as a MASTER PHY.
SLAVE
This value is continuously asserted when the PHY operates as a SLAVE PHY.
126.2.2.2.2 When generated
PMA generates PMA_CONFIG.indication messages to indicate a change in config.


126.2.2.2.3 Effect of receipt
PCS and PMA Clock Recovery perform their functions in MASTER or SLAVE configuration according to 
the value assumed by the parameter config.
126.2.2.3 PMA_UNITDATA.request
This primitive defines the transfer of code-groups in the form of the tx_symb_vector parameter from the 
PCS to the PMA. The code-groups are obtained in the PCS Transmit function using the encoding rules 
defined in 126.3.2.2 to represent XGMII data and control streams or other sequences.
126.2.2.3.1 Semantics of the primitive
PMA_UNITDATA.request (tx_symb_vector)
During transmission, the PMA_UNITDATA.request simultaneously conveys to the PMA via the parameter 
tx_symb_vector the value of the symbols to be sent over each of the four transmit pairs BI_DA, BI_DB, 
BI_DC, and BI_DD. For EEE-capable PHYs, the vector also requests the PMA to send the ALERT signal 
during LPI. The tx_symb_vector parameter takes on the following form:
SYMB_4D
A vector of four multi-level symbols, one for each of the four transmit pairs 
BI_DA, BI_DB, BI_DC, and BI_DD. In normal operation, each symbol 
may take on one of the values in the set {–15, –13, –11, –9, –7, –5, –3, –1, 1, 3, 5, 7, 
9, 11, 13, 15}. The symbols may additionally take the value 0 when zeros are to be 
transmitted in the following two cases: 1) when PMA_TXMODE.indication is 
SEND_Z during PMA training, and 2) after data mode is reached, the transmit 
function is in the LPI transmit mode and lpi_tx_mode is QUIET
ALERT
A vector used to indicate that the PMA should transmit the alert sequence.
ALERT is asserted for a time equal to 8 LDPC frames.
The symbols that are elements of tx_symb_vector are called, according to the pair on which each is 
transmitted, 
tx_symb_vector[BI_DA], 
tx_symb_vector[BI_DB], 
tx_symb_vector[BI_DC], 
and 
tx_symb_vector[BI_DD].
126.2.2.3.2 When generated
The PCS generates PMA_UNITDATA.request synchronously with every transmit clock cycle. 
126.2.2.3.3 Effect of receipt
Upon receipt of this primitive the PMA transmits on the MDI the signals corresponding to the indicated 
symbols after processing with the THP, the transmit filter and other specified PMA Transmit processing. 
The parameter tx_symb_vector is also used by the PMA Receive function to process the signals received on 
pairs BI_DA, BI_DB, BI_DC, and BI_DD for canceling the echo and near-end crosstalk (NEXT).
126.2.2.4 PMA_UNITDATA.indication
This primitive defines the transfer of code-groups in the form of the rx_symb_vector parameter from the 
PMA to the PCS.


126.2.2.4.1 Semantics of the primitive
PMA_UNITDATA.indication (rx_symb_vector)
During reception the PMA_UNITDATA.indication simultaneously conveys to the PCS via the parameter 
rx_symb_vector the values of the symbols detected on each of the four receive pairs BI_DA, BI_DB, 
BI_DC, and BI_DD. The rx_symb_vector parameter takes on the following form:
SYMB_4D
A vector of the four 1D symbols that is the receiver’s best estimate of the symbols that 
were sent by the remote transmitter across the four pairs with reliability measures.
126.2.2.4.2 When generated
The PMA generates PMA_UNITDATA.indication (SYMB_4D) messages synchronously every four 
symbols received at the MDI. The nominal rate of the PMA_UNITDATA.indication primitive is 
S 400 MHz, as governed by the recovered clock.
126.2.2.4.3 Effect of receipt
The effect of receipt of this primitive is unspecified.
126.2.2.5 PMA_SCRSTATUS.request
This primitive is generated by PCS Receive to communicate the status of the descrambler for the local PHY. 
The parameter scr_status conveys to the PMA Receive function the information that the training mode 
descrambler has achieved synchronization.
126.2.2.5.1 Semantics of the primitive
PMA_SCRSTATUS.request (scr_status)
The scr_status parameter can take on one of the following two values of the form:
OK
The training mode descrambler has achieved synchronization.
NOT_OK
The training mode descrambler is not synchronized.
126.2.2.5.2 When generated
PCS Receive generates PMA_SCRSTATUS.request messages to indicate a change in scr_status.
126.2.2.5.3 Effect of receipt
The effect of receipt of this primitive is specified in 126.4.2.4, 126.4.2.5, and 126.4.6.1.
126.2.2.6 PMA_PCSSTATUS.request
This primitive is generated by PCS Receive to indicate the fully operational state of the PCS for the local 
PHY. The parameter pcs_status conveys to the PMA Receive function the information that the PCS is 
operating reliably in data mode.
126.2.2.6.1 Semantics of the primitive
PMA_PCSSTATUS.request (pcs_status)


The pcs_status parameter can take on one of the following two values of the form:
OK
The PCS is operating reliably in data mode.
NOT_OK
The PCS is not operating reliably in data mode.
126.2.2.6.2 When generated
PCS Receive generates PMA_PCSSTATUS.request messages to indicate a change in pcs_status. 
126.2.2.6.3 Effect of receipt
The effect of receipt of this primitive is specified in 126.4.6.
126.2.2.7 PMA_RXSTATUS.indication
This primitive is generated by PMA Receive to indicate the status of the receive link at the local PHY. The 
parameter loc_rcvr_status conveys to the PCS Transmit, PCS Receive, PMA PHY Control function, and 
Link Monitor the information on whether the status of the overall receive link is satisfactory or not. Note 
that loc_rcvr_status is used by the PCS Receive decoding functions. The criterion for setting the parameter 
loc_rcvr_status is left to the implementer. It can be based, for example, on observing the mean-square error 
at the decision point of the receiver and detecting errors during reception of symbol streams.
126.2.2.7.1 Semantics of the primitive
PMA_RXSTATUS.indication (loc_rcvr_status) 
The loc_rcvr_status parameter can take on one of the following two values of the form: 
OK
This value is asserted and remains true during reliable operation of the receive
link for the local PHY.
NOT_OK
This value is asserted whenever operation of the link for the local PHY is unreliable.
126.2.2.7.2 When generated
PMA Receive generates PMA_RXSTATUS.indication messages to indicate a change in loc_rcvr_status on 
the basis of signals received at the MDI.
126.2.2.7.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 126–26 and in 126.2 and 126.4.6.3.
126.2.2.8 PMA_REMRXSTATUS.request
This primitive is generated by PCS Receive to indicate the status of the receive link at the remote PHY as 
communicated by the remote PHY via its encoding of its loc_rcvr_status parameter. The parameter 
rem_rcvr_status conveys to the PMA PHY Control function the information on whether reliable operation of 
the remote PHY is detected or not. The criterion for setting the parameter rem_rcvr_status is left to the 
implementer. It can be based, for example, on asserting rem_rcvr_status is NOT_OK until loc_rcvr_status is 
OK and then asserting the detected value of rem_rcvr_status after proper PCS Receive decoding is achieved.
126.2.2.8.1 Semantics of the primitive
PMA_REMRXSTATUS.request (rem_rcvr_status)


The rem_rcvr_status parameter can take on one of the following two values of the form:
OK
The receive link for the remote PHY is operating reliably.
NOT_OK
Reliable operation of the receive link for the remote PHY is not detected.
126.2.2.8.2 When generated
The PCS generates PMA_REMRXSTATUS.request messages to indicate a change in rem_rcvr_status on the 
basis of signals received at the MDI.
126.2.2.8.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 126–26.
126.2.2.9 PMA_ALERTDETECT.indication
This primitive is generated by PMA Receive to indicate the status of the receive link at the local PHY when 
rx_lpi_active is TRUE. The parameter alert_detect conveys to the PCS receive function information 
regarding the detection of the LPI alert signal by the PMA receive function. The criterion for setting the 
parameter alert_detect is left to the implementer. 
126.2.2.9.1 Semantics of the primitive
PMA_ALERTDETECT.indication (alert_detect)
The alert_detect parameter can take on one of the following two values of the form:
TRUE
The alert signal has been reliably detected at the local receiver.
FALSE
The alert signal at the local receiver has not been detected.
126.2.2.9.2 When generated
The PMA generates PMA_ALERTDETECT.indication messages to indicate a change in the alert_detect 
status.
126.2.2.9.3 Effect of receipt
The effect of receipt of this primitive is specified in 126.3.2.3, Figure 126–16, and Figure 126–17.
126.2.2.10 PCS_RX_LPI_STATUS.request
When the PHY supports the EEE capability this primitive is generated by the PCS receive function to 
indicate the status of the receive link at the local PHY. The parameter PCS_RX_LPI_STATUS.request 
conveys to the PCS transmit and PMA receive functions information regarding whether the receive function 
is in the LPI receive mode. The parameter is generated by the Receive 64B/65B state diagram in 
Figure 126–16.
126.2.2.10.1 Semantics of the primitive
PCS_RX_LPI_STATUS.request (rx_lpi_active)
The rx_lpi_active parameter can take on one of the following two values of the form:


TRUE
The receive function is in the LPI receive mode.
FALSE
The receive function is not in the LPI receive mode.
126.2.2.10.2 When generated
The PCS generates PCS_RX_LPI_STATUS.request messages to indicate a change in the rx_lpi_active 
variable as determined by the receive state diagram in Figure 126–16.
126.2.2.10.3 Effect of receipt
The effect of receipt of this primitive is specified in 126.3.2.3 and Figure 126–30.
126.2.2.11 PMA_PCSDATAMODE.indication
This primitive indicates whether or not the PCS state diagrams are able to transition from their initialization 
states. The pcs_data_mode variable is generated by the PMA PHY Control function. It is passed to the PCS 
Control function via the PMA_PCSDATAMODE.indication primitive.
126.2.2.11.1 Semantics of the primitive
PMA_PCSDATAMODE.indication (pcs_data_mode)
The pcs_data_mode parameter can take on one of the following two values of the form:
TRUE
PHY is in state PCS_Data (see Figure 126–26).
FALSE
PHY is not in state PCS_Data (see Figure 126–26).
126.2.2.11.2 When generated
The PMA PHY Control function generates PMA_PCSDATAMODE.indication messages continuously.
126.2.2.11.3 Effect of receipt
Upon receipt of this primitive, the PCS performs its transmit function as described in 126.3.2.2.
126.2.2.12 PMA_FR_ACTIVE.indication
This primitive indicates whether or not the PMA is currently performing a fast retrain. The fr_active variable 
is generated by the PMA PHY Control function. It is passed to the PCS Receive Control function via the 
PMA_FR_ACTIVE.indication primitive. This primitive is only supported by PHYs with the fast retrain 
capability.
126.2.2.12.1 Semantics of the primitive
PMA_FR_ACTIVE.indication (fr_active)
The fr_active parameter can take on one of the following two values of the form:
TRUE
PHY is currently performing a fast retrain.
FALSE
PHY is not currently performing a fast retrain.


126.2.2.12.2 When generated
The PMA PHY Control function generates PMA_FR_ACTIVE.indication messages continuously.
126.2.2.12.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 126–16.
126.3 Physical Coding Sublayer (PCS)
126.3.1 PCS service interface (XGMII)
The PCS service interface allows the 2.5GBASE-T or 5GBASE-T PCS to transfer information to and from a 
PCS client. The PCS Interface is precisely defined as the 10 Gigabit Media Independent Interface (XGMII) 
in Clause 46.
126.3.2 PCS functions
The PCS comprises one PCS Reset function and two simultaneous and asynchronous operating functions. 
The PCS operating functions are: PCS Transmit and PCS Receive. All operating functions start immediately 
after the successful completion of the PCS Reset function. 
The PCS reference diagram, Figure 126–5, shows how the two operating functions relate to the messages of 
the PCS-PMA interface. Connections from the management interface (signals MDC and MDIO) to other 
layers are pervasive and are not shown in Figure 126–5.


126.3.2.1 PCS Reset function
PCS Reset initializes all PCS functions. The PCS Reset function shall be executed whenever one of the 
following conditions occur:
a)
Power on (see 126.3.6.2.2).
b)
The receipt of a request for reset from the management entity. 
PCS Reset sets pcs_reset = true while any of the above reset conditions hold true. All state diagrams take the 
open-ended pcs_reset branch upon execution of PCS Reset. The reference diagrams do not explicitly show 
the PCS Reset function.
PMA SERVICE
INTERFACE
PCS
PCS
RECEIVE
RX_CLK
RXD<31:0>
RXC<3:0>
rem_rcvr_status
10 GIGABIT MEDIA
PCS
TRANSMIT
TX_CLK
TXD<31:0>
tx_mode
PMA_UNITDATA.indication (rx_symb_vector)
TXC<3:0>
PMA_UNITDATA.request (tx_symb_vector)
config
Figure 126–5—PCS reference diagram
scr_status
MEDIA INDEPENDENT
INTERFACE (XGMII)
loc_rcvr_status
alert_detect
rx_lpi_active
NOTE 1—pcs_data_mode is required only for the EEE or fast retrain capabilities.
NOTE 2—alert_detect and rx_lpi_active are only required for the EEE capability.
NOTE 3—fr_active is only required for the fast retrain capability.
pcs_data_mode
fr_active
pcs_status


126.3.2.2 PCS Transmit function
The PCS Transmit function shall conform to the PCS 64B/65B Transmit state diagram in Figure 126–14 and 
the PCS Transmit bit ordering in Figure 126–6.
Dashed rectangles in Figure 126–14 and Figure 126–15 are used to indicate states and state transitions in the 
PCS 64B/65B Transmit state diagram that shall be supported by PHYs with the EEE capability. PHYs 
without the EEE capability do not support these transitions.
When communicating with the XGMII, the PCS uses a 4-octet-wide, synchronous data path, with packet 
delimiting being provided by transmit control signals and receive control signals. Alignment to 64B/65B is 
performed in the PCS. The PMA sublayer operates independently of block and packet boundaries. The PCS 
provides the functions necessary to map packets between the XGMII format and the PMA service interface 
format.
When the transmit channel is in normal mode, the PCS Transmit process continuously generates 65B blocks 
based upon the TXD <31:0> and TXC <3:0> signals on the XGMII. The subsequent functions of the PCS 
Transmit process then scramble the bits of the 65B blocks, pack the resulting scrambled blocks, append 97 
zeros, and attach a leading aux channel bit, all of which are then processed by a low density parity check 
(LDPC) encoder. The appended zeros are then replaced by vendor discretionary randomized bits. The 
resulting 2048-bit LDPC frame is then mapped into PAM16 symbols. Transmit data-units are sent to the 
PMA service interface via the PMA_UNITDATA.request primitive.
In each symbol period, when communicating with the PMA, the PCS Transmit generates a code-group (An, 
Bn, Cn, Dn) that is transferred to the PMA via the PMA_UNITDATA.request primitive. The PMA transmits 
symbols An, Bn, Cn, Dn over wire-pairs BI_DA, BI_DB, BI_DC, and BI_DD respectively. The integer, n, is 
a time index that is introduced to establish a temporal relationship between different symbol periods. A 
symbol period, T, is 2.5S ns.
If a PMA_TXMODE.indication message has the value SEND_Z, PCS Transmit passes a vector of zeros at 
each symbol period to the PMA via the PMA_UNITDATA.request primitive.
If a PMA_TXMODE.indication message has the value SEND_T, PCS Transmit generates sequences of 
code-groups (TAn, TBn, TCn, TDn) defined in 126.3.4.2 to the PMA via the PMA_UNITDATA.request 
primitive. These code-groups are used for training mode and only transmit the values {–9, 9} to keep the 
transmit power in the training mode the same as the transmit power in normal mode. 
During training mode an Infofield is transmitted at regular intervals containing messages for startup 
operation. By this mechanism, a PHY indicates the status of its own receiver to the link partner and makes 
requests for remote transmitter settings. (See 126.4.2.5.)
In the normal mode of operation, the PMA_TXMODE.indication message has the value SEND_N, and the 
PCS Transmit function uses a 65B-LDPC coding to generate at each symbol period code-groups that 
represent data or control. During transmission, the 65B encoded bits are scrambled by the PCS using a PCS 
scrambler, 97 zero bits and an auxiliary bit are added, then frames are encoded into a code-group of 4D
symbols and transferred to the PMA. During data encoding, PCS Transmit utilizes an LDPC frame encoder.
After reaching the normal mode of operation, EEE-capable PHYs may enter the LPI transmit mode under 
the control of the MAC via the XGMII. The EEE Transmit state diagram is contained within the PCS 
Transmit function. The EEE capability is described in 126.3.2.2.19.


126.3.2.2.1 Use of blocks
The PCS translates between XGMII signals and 65-bit blocks inserted within an LDPC frame using a 
65B-LDPC coding scheme. The PAM2 PMA training frame synchronization allow establishment of LDPC 
frame and 65B boundaries by the PCS Synchronization process. Blocks and frames are unobservable and 
have no meaning outside the PCS. During the LPI mode, LDPC frame boundaries delimit sleep, wake, 
refresh, quiet, and alert cycles. The PCS functions ENCODE and DECODE generate, manipulate, and 
interpret blocks and frames as provided by the rules in 126.3.2.2.2.
126.3.2.2.2 65B-LDPC transmission code
The PCS uses a transmission code to improve the transmission characteristics of information to be 
transferred across the link and to support transmission of control and data characters. In addition, the code 
enables the receiver to achieve PCS synchronization alignment on the incoming PHY bit stream.
The relationship of block bit positions to XGMII, PMA, and other PCS constructs is illustrated in 
Figure 126–6 for transmit and Figure 126–7 for receive. These figures illustrate the processing of a 
multiplicity of blocks containing 8 data octets. See 126.3.2.2.5 for information on how blocks containing 
control characters are mapped. 
126.3.2.2.3 Notation conventions
For values shown as binary, the leftmost bit is the first transmitted bit.
64B/65B encodes 8 data octets or control characters into a block. Blocks containing control characters also 
contain a block type field. Data octets are labeled D0 to D7. Control characters other than /O/, /S/, and /T/ are 
labeled C0 to C7. The control character for ordered set is labeled as O0 or O4 since it is only valid on the first 
octet of the XGMII. The control character for start is labeled as S0 or S4 for the same reason. The control 
character for terminate is labeled as T0 to T7.
Two consecutive XGMII transfers provides eight characters that are encoded into one 65-bit transmission 
block. The subscript in the above labels indicates the position of the character in the eight characters from 
the XGMII transfers.
Contents of block type fields, data octets and control characters are shown in hexadecimal notation. The 
LSB of the equivalent binary value represents the first transmitted bit. For instance, the block type field 
0x1E is sent from left to right as 01111000. The bits of a transmitted or received block are labeled 
TxB<64:0> and RxB<64:0> respectively where TxB<0> and RxB<0> represent the first transmitted bit. 
The value of the data/ctrl header is shown as a binary value. Binary values are shown with the first 
transmitted bit (the LSB) on the left.
126.3.2.2.4 Transmission order
The PCS Transmit bit ordering shall conform to Figure 126–6. Note that this figure shows the mapping from 
XGMII to 64B/65B block for a block containing eight data characters.
126.3.2.2.5 Block structure
Blocks consist of 65 bits. The first bit of a block is the data/ctrl header. Blocks are either data blocks or 
control blocks. The data/ctrl header is 0 for data blocks and 1 for control blocks. The remainder of the block 
contains the payload.
Data blocks contain eight data characters. Control blocks begin with an 8-bit block type field that indicates 
the format of the remainder of the block. For control blocks containing a Start or Terminate character, that 


Figure 126–6—PCS Transmit bit ordering
XGMII
TXD<0>
TXD<31>
TXD<0>
TXD<31>
D0
D1
D2
D3
D4
D5
D6
D7
LDPC frame
Scrambler
PMA service
Data/Ctrl header
Bit mapper: 4 bit Gray-coded symbols to PAM16
4D-PAM16<0>
4D-PAM16<127>
tx_coded<0>
512x4 LDPC-coded bits
PAM16<0>
PAM16<4>
PAM16<12>
PAM16<508>
...
PAM16<8>
PAM16<504>
PAM16<1>
PAM16<5>
PAM16<13>
PAM16<509>
...
PAM16<9>
PAM16<505>
PAM16<2>
PAM16<6>
PAM16<14>
PAM16<510>
...
PAM16<10>
PAM16<506>
PAM16<3>
PAM16<7>
PAM16<15>
PAM16<511>
PAM16<11>
PAM16<507>
interface
Pair A
Pair B
Pair C
Pair D
...
S0
S1
S2
S3
S4
S5
S6
S7
LDPC(1723,2048) encoder
TxB<0>
TxB<64>
Output of scrambled
65B block
Aggregate 25 65B blocks, append 97 zeros
65B block 1
65B block 2
auxiliary bit
65B block 25
97 zeros
Random fill bits
Replace 97 zeros
First transfer
Second transfer
tx_coded<64>
Output of encoder 
function 65B block
(see Figure 126–14
and Figure 126–15)
NOTE—This figure shows the mapping from the XGMII to a 64B/65B block for a block con-
taining eight data characters.


Figure 126–7—PCS Receive bit ordering
XGMII
RXD<0>
RXD<31>
First transfer
RXD<0>
RXD<31>
Frame sync
PMA service interface
rx_symb_vector<0> (PMA)
rx_symb_vector<127> (PMA)
LDPC decoded frame
rx 4D-PAM16<0>
rx 4D-PAM16<127>
LDPC frame
LDPC received frame
LDPC decode
1723 decoded bits
Second transfer
D0
D1
D2
D3
D4
D5
D6
D7
Input to descrambler 
S0
S1
S2
S3
S4
S5
S6
S7
Descrambler
function
RxB<64>
RxB<0>
Blocks in LDPC 
Separate 25 65B blocks,
decoded frame
65B block 1
65B block 2
65B block 25
97 zeros
Discard auxiliary bit and
97 trailing zeros
NOTE 1—This figure shows the mapping from a 64B/65B block for a block containing eight 
data characters to the XGMII.
Input to decoder 
function 65B block
(see Figure 126–16
and Figure 126–17)
Data/Ctrl header
rx_coded<0>
rx_coded<64>
NOTE 2—Conversion from 4DPAM-16 symbols to bits occurs in the LDPC decoder.


character is implied by the block type field. Other control characters are encoded in a 7-bit control code or a 
4-bit O Code. Each control block contains eight characters.
The format of the blocks is as follows in Figure 126–8. In the figure, the column labeled Input Data shows, 
in abbreviated form, the eight characters used to create the 65-bit block. These characters are either data 
characters or control characters and, when transferred across the XGMII interface, the corresponding TXC 
or RXC bit is set accordingly. Within the Input Data column, D0 through D7 are data octets and are 
transferred with the corresponding TXC or RXC bit set to zero. All other characters are control octets and 
are transferred with the corresponding TXC or RXC bit set to one. The single bit fields (thin rectangles with 
no label in the figure) are sent as zero and ignored upon receipt. 
Bits and field positions are shown with the least significant bit on the left. Hexadecimal numbers are shown 
prepended with ‘0x’, and with the least significant digit on the right. For example the block type field 0x1E 
is sent as 01111000 representing bits 1 through 8 of the 65-bit block. The least significant bit for each field is 
placed in the lowest numbered position of the field.
All unused values of block type field are reserved.216
126.3.2.2.6 Control codes
The same set of control characters are supported by the XGMII, 2.5GBASE-T and 5GBASE-T PCS. The 
representations of the control characters are the control codes. The XGMII encodes a control character into 
an octet (an 8-bit value). The 2.5GBASE-T and 5GBASE-T PCS encode the start and terminate control 
characters implicitly by the block type field. The 2.5GBASE-T and 5GBASE-T PCS encode the ordered set 
control codes using a combination of the block type field and a 4-bit O code for each ordered set. The 
2.5GBASE-T and 5GBASE-T PCS encode each of the other control characters into a 7-bit C code. 
The control characters and their mappings to 2.5GBASE-T and 5GBASE-T control codes and XGMII 
control codes are specified in Table 126–1. All XGMII, 2.5GBASE-T, and 5GBASE-T control code values 
that do not appear in the table shall not be transmitted and shall be treated as an error if received. 
126.3.2.2.7 Ordered sets
Ordered sets are used to extend the ability to send control and status information over the link such as remote 
fault and local fault status. Ordered sets consist of a control character followed by three data characters. 
Ordered sets always begin on the first octet of the XGMII. One kind of ordered set is used for 2.5 and 
5 Gigabit Ethernet—the sequence ordered set (see 46.3.4). The sequence ordered set control character is 
denoted /Q/. An additional ordered set, the signal ordered set, has been reserved and it begins with another 
control code. The 4-bit O field encodes the control code. See Table 126–1 for the mappings.
126.3.2.2.8 Idle (/I/)
Idle control characters (/I/) are transmitted when idle control characters are received from the XGMII. Idle 
characters may be added or deleted by the PCS to adapt between clock rates. /I/ insertion and deletion shall 
occur in groups of 4. /I/s may be added following idle or ordered sets. They shall not be added while data is 
being received. When deleting /I/s, the first four characters after a /T/ shall not be deleted.
216The block type field values have been chosen to have a 4-bit Hamming distance between them. The only unused value that maintains 
the Hamming distance is 0x00.


Table 126–1—Control codes 
Control character
Notation
XGMII 
control code
2.5G/5GBASE-T 
control code
2.5G/5GBASE-T
O code
idle
/I/
0x07
0x00
LPI
/LI/
0x06
0x06
start
/S/
0xFB
Encoded by block type 
field
terminate
/T/
0xFD
Encoded by block type 
field
error
/E/
0xFE
0x1E
Sequence ordered set
/Q/
0x9C
Encoded by block type 
field plus O code
0x0
Figure 126–8—64B/65B block formats
C0 C1 C2 C3/C4 C5 C6 C7
0x1E
D2
D3
D4
D5
D6
D7
Control Block Formats:
Block
0xFF
0xE1
0xB4
0xAA
0x99
0x87
0x78
0x33
0xCC
0xD2
D0 D1 D2 D3/D4 D5 D6 T7
D0 D1 D2 D3/D4 D5 T6 C7
D0 D1 D2 D3/D4 T5 C6 C7
D0 D1 D2 D3/T4 C5 C6 C7
D0 D1 D2 T3/C4 C5 C6 C7
D0 D1 T2 C3/C4 C5 C6 C7
D0 T1 C2 C3/C4 C5 C6 C7
T0 C1 C2 C3/C4 C5 C6 C7
S0 D1 D2 D3/D4 D5 D6 D7
C0 C1 C2 C3/S4 D5 D6 D7
D1
D0
D0
D0
D0
D0
D0
D0
C0
C0
D1
D1
D1
D1
D1
D1
C1
C1
C1
D2
C2
D2
D2
D2
D2
C2
C2
C2
D3
D3
D3
D3
C3
C3
C3
C3
C3
D4
D4
D4
C4
C4
C4
C4
C4
D5
D5
D5
C5
C5
C5
C5
C5
C5
D6
D6
C6
C6
C6
C6
C6
C6
C6
D7
C7
C7
C7
C7
C7
C7
C7
C7
D2
C0 C1 C2 C3/O4 D5 D6 D7
0x2D
C0
C1
C2
C3
D5
D6
D7
O4
O0 D1 D2 D3/S4 D5 D6 D7
0x66
D1
D2
D3
D5
D6
D7
O0
O0 D1 D2 D3/O4 D5 D6 D7
0x55
D1
D2
D3
D5
D6
D7
O0
O4
D2
D3
0x4B
O0 D1 D2 D3/C4 C5 C6 C7
D1
C4
C5
C6
C7
O0
Input Data
data
D0 D1 D2 D3/D4 D5 D6 D7
D0
D1
D2
D3
D4
D5
D6
D7
Data Block Format:
Block Payload
ctrl
header
Bit Position:


126.3.2.2.9 LPI (/LI/)
Low power idle (LPI) control characters (/LI/) on the XGMII indicate that the LPI client is requesting 
operation in the LPI transmit mode. A continuous stream of LPI control characters (/LI/) is used to maintain 
a link in the LPI transmit mode. Idle control characters (/I/) are used to transition from the LPI transmit 
mode to the normal mode. PHYs that support EEE respond to the LPI XGMII control characters using the 
procedure outlined in 126.1.3.3. LPI characters may be added or deleted by the PCS to adapt between clock 
rates. /LI/ insertion and deletion shall occur in groups of four. /LI/s may be added following low power idle 
characters. They shall not be added while data is being received. 
If EEE is not supported, then /LI/ is not a valid control character.
126.3.2.2.10 Start (/S/)
The start control character (/S/) indicates the start of a packet. This delimiter is only valid on the first octet of 
the XGMII (TXD<7:0> and RXD<7:0>). Receipt of an /S/ on any other octet of TXD indicates an error. 
Block type field values implicitly encode an /S/ as the fifth or first character of the block. These are the only 
characters of a block on which a start can occur.
126.3.2.2.11 Terminate (/T/)
The terminate control character (/T/) indicates the end of a packet. Since packets may be any length, the /T/ 
can occur on any octet of the XGMII interface and within any character of the block. The location of the /T/ 
in the block is implicitly encoded in the block type field. A valid end of packet occurs when a block 
containing a /T/ is followed by a control block that does not contain a /T/.
126.3.2.2.12 ordered set (/O/)
The ordered set control characters (/O/) indicate the start of an ordered set. There are two kinds of ordered 
sets: the sequence ordered set and the signal ordered set (which is reserved). When it is necessary to 
designate the control character for the sequence ordered set specifically, /Q/ is used. /O/ is only valid on the 
first octet of the XGMII. Receipt of an /O/ on any other octet of TXD indicates an error. Block type field 
reserved0
0x1C
0x2D
reserved1
0x3C
0x33
reserved2
0x7C
0x4B
reserved3
0xBC
0x55
reserved4
0xDC
0x66
reserved5
0xF7
0x78
Signal ordered seta
/Fsig/
0x5C
Encoded by block type 
field plus O code
0xF
aUsed by INCITS T11 Fibre Channel.
Table 126–1—Control codes (continued)
Control character
Notation
XGMII 
control code
2.5G/5GBASE-T 
control code
2.5G/5GBASE-T
O code


values implicitly encode an /O/ as the first or fifth character of the block. The 4-bit O code encodes the 
specific /O/ character for the ordered set. 
Sequence ordered sets may be deleted by the PCS to adapt between clock rates. Such deletion shall only 
occur when two consecutive sequence ordered sets have been received and shall delete only one of the two. 
Only Idles may be inserted for clock compensation. Signal ordered sets are not deleted for clock 
compensation.
126.3.2.2.13 Error (/E/)
The /E/ is sent whenever an /E/ is received. The /E/ allows physical sublayers such as the PCS to propagate 
received errors. See R_BLOCK_TYPE and T_BLOCK_TYPE function definitions in 126.3.6.2.4 for further 
information.
126.3.2.2.14 Transmit process
The transmit process generates blocks based upon the TXD<31:0> and TXC<3:0> signals received from the 
XGMII. Two XGMII data transfers are encoded into each block. 50 XGMII data transfers are encoded into 
an LDPC frame. It takes 128 PMA_UNITDATA transfers to send an LDPC frame of data. Therefore, if the 
PCS is connected to an XGMII and PMA sublayer where the ratio of their transfer rates is exactly 25:64, 
then the transmit process does not need to perform rate adaptation. Where the XGMII and PMA sublayer 
data rates are not synchronized to that ratio, the transmit process needs to insert idles, delete idles, or delete 
sequence ordered sets to adapt between the rates.
The transmit process generates blocks as specified in the PCS 64B/65B Transmit state diagram (see 
Figure 126–16 and Figure 126–17). The contents of each block are contained in a vector tx_coded<64:0>, 
which is passed to the scrambler. tx_coded<0> contains the data/ctrl header and the remainder of the bits 
contain the block payload.
126.3.2.2.15 PCS Scrambler
The payload of the PCS PHY frame is scrambled with a self-synchronizing scrambler. The scrambler for the 
MASTER shall produce the same result as the implementation shown in Figure 126–9. This implements the 
scrambler polynomial:217 
(126–1)
The scrambler for the SLAVE shall produce the same result as the implementation shown in Figure 126–9. 
This implements the scrambler polynomial:
(126–2)
The initial seed values for the MASTER and SLAVE are left to the implementer. The scrambler is run 
continuously on all payload bits.
126.3.2.2.16 LDPC framing and LDPC encoder
The resulting payload of scrambled 25 65B blocks, followed by the 97 zero bits and preceded by 1 auxiliary 
bit results in a total payload of 25 65 + 97 +1 = 1723 bits. The use of the auxiliary bit is for vendor-specific 
217The convention here, which considers the most recent bit into the scrambler to be the lowest order term, is consistent with most ref-
erences and with other scramblers shown in this standard. Some references consider the most recent bit into the scrambler to be the 
highest order term and would therefore identify this as the inverse of the polynomial in Equation (126–1). In case of doubt, note that the 
conformance requirement is based on the representation of the scrambler in the figure rather than the polynomial equation.
G x

x39
x58
+
+
=
G x

x19
x58
+
+
=


communication is outside the scope of this document. For the purposes of this standard it is ignored by the 
link partner. The 1723 bits shall be encoded by the LDPC(1723, 2048) generator matrix G. G is described in 
Annex 55A.
The LDPC encoding takes the 1723 bit input code vector x = [x0 x1 x2 ... x1722], and shall generate the 2048 
bit codeword c represented by the matrix multiplication c = x  G. For both x and c the leftmost element of 
the vector is the first bit into the LDPC encoder and the first transmitted bit.
126.3.2.2.17 Substitution for zero-bit fill
The 2048 LDPC-coded bits output from the LDPC encoder in Figure 126–6 are then divided into three
groups: the first 1626 bits, representing the auxiliary bit and the 25 scrambled 65B blocks of Ethernet pay-
load; the subsequent 97 bits, representing the zero-fill added prior to encoding, and the subsequent 325 
LDPC check bits. The group of 97 zero-fill bits are then replaced by vendor discretionary, randomized bits. 
The randomized fill bits should approximate the autocorrelation properties of the PCS scrambler described 
in 126.3.2.2.15, so as not to generate tones violating the transmit spectral PSD masks in 126.5.3.4.
126.3.2.2.18 PAM16 bit mapping
The LDPC frame shall be mapped four bits at a time in bit order of transmission into Gray-coded PAM-16 as 
follows in Table 126–2.
Figure 126–9—MASTER and SLAVE PCS scramblers
S0
S56
S39
S38
S2
S1
S57
Serial data input
Scrambled data output
S0
S56
S19
S18
S2
S1
S57
Serial data input
Scrambled data output
PCS scrambler employed by the SLAVE
PCS scrambler employed by the MASTER


126.3.2.2.19 EEE capability
The optional 2.5GBASE-T or 5GBASE-T EEE capability allows compliant PHYs to transition to an LPI 
mode of operation when link utilization is low. 
PHYs that support EEE shall conform to the EEE transmit state diagram, shown in Figure 126–18, within 
the PCS.
When PCS_Reset is asserted or pcs_data_mode is not asserted, the state diagram enters the TX_NORMAL 
state. 
When a complete 64B/65B block of LPI characters is generated by the PCS transmit function, the PHY 
transmits the sleep signal to indicate to the link partner that it is transitioning to the LPI transmit mode. If the 
sleep signal begins on an even LDPC frame boundary aligned to the inversion on pair A during PMA 
training, then it contains 18 full LDPC frames each composed entirely of LDPC encoded LP_IDLE blocks. 
If the sleep signal does not begin on an even LDPC frame boundary, then it contains one to two LDPC 
frames partially composed of LP_IDLE blocks followed by 18 LDPC frames fully composed of LP_IDLE 
blocks. 
Following the transmission of the sleep signal, quiet-refresh signaling begins, as described in 126.3.5. 
After the sleep signal is transmitted LPI control characters shall be input to the PCS scrambler continuously 
until the PCS Transmit Function exits the LPI transmit mode. 
Table 126–2—PAM16 to Gray coded PAM16 mapping
Bits (b0b1b2b3)
Hex
Level
0x4
+15
0x5
+13
0x7
+11
0x6
+9
0x2
+7
0x3
+5
0x1
+3
0x0
+1
0x8
–1
0x9
–3
0xB
–5
0xA
–7
0xE
–9
0xF
–11
0xD
–13
0xC
–15


While the PMA asserts SEND_N, the lpi_tx_mode variable shall control the transmit signal through the 
PMA_UNITDATA.request primitive described as follows: 
When the PHY is not in the PCS_Data state, the lpi_tx_mode variable is ignored.
When the lpi_tx_mode variable takes the value NORMAL and the PMA asserts SEND_N, the PCS 
passes coded data to the PMA via the PMA_UNITDATA.request primitive as described in 
126.3.2.2.
When the lpi_tx_mode variable takes the value QUIET and the PMA asserts SEND_N, the PCS 
passes zeros to the PMA through the PMA_UNITDATA.request primitive.
When the lpi_tx_mode variable takes the value REFRESH_A and the PMA asserts SEND_N, the 
PCS passes the PMA training signal to the PMA on pair A, to allow both the local and remote PHY 
to refresh adaptive filters and timing loops. The PCS passes zeros to all other pairs in this condition. 
REFRESH_B, REFRESH_C and REFRESH_D operate in an analogous manner for the other pairs.

When the lpi_tx_mode variable takes the value ALERT and the PMA asserts SEND_N, the PCS 
passes the ALERT vector to the PMA.
The quiet-refresh cycle is repeated until codewords other than LP_IDLE are detected at the XGMII. These 
codewords indicate that the local system is requesting a transition back to the normal operational mode. 
Following this event, the PMA_UNITDATA.request parameter tx_symb_vector is set to the value ALERT. 
The alert signal is not synchronized with respect to the quiet-refresh cycle but shall be synchronized so that 
the alert signal from the PMA begins on a LDPC 2-frame 256 4D-symbol boundary aligned to the inversion 
on pair A during PMA training.
The PHY also transitions back to the normal operation mode if an error condition occurs. This error 
condition is defined as the detection of any characters other than LPI or IDLE at the XGMII.
After the alert signal the PCS completes the transition from LPI mode to normal mode by sending a wake 
signal containing lpi_wake_time LDPC frames composed of IDLE 64B/65B blocks.
lpi_wake_time is a fixed parameter that is defined as 18 LDPC frames as follows in Table 126–3. The 
maximum PHY wake time when wake is requested before sleep has been completely transmitted is 
14.72/S s (lpi_wake_timer=Tw_phy as defined by Clause 78). The maximum PHY wake time when wake is 
requested after sleep has been completely transmitted is 8.96/S s.
126.3.2.3 PCS Receive function
The PCS Receive function shall conform to the PCS 64B/65B receive state diagram in Figure 126–16 and 
Figure 126–17 and the PCS Receive bit ordering in Figure 126–7 including compliance with the associated 
state variables as specified in 126.3.6.
Table 126–3—LPI wake time
lpi_wake_time
lpi_wake_timer when wake starts 
before sleep signal is complete
lpi_wake_timer when wake starts 
after sleep signal is complete
(frames)
(frames)
(s)
(frames)
(s)
14.72/S
8.96/S


The PCS Receive function accepts received code-groups provided by the PMA Receive function via the 
parameter rx_symb_vector. The PCS receiver uses knowledge of the encoding rules to correctly align the 
65B-LDPC frames. The randomized bits are replaced with known zeros. The received 65B-LDPC frames 
are decoded with error correction; the auxiliary bit and the trailing zero-fill bits are then stripped; 
descrambling is then performed. This process generates the 64B/65B block vector rx_coded<64:0>, which is 
then decoded to form the XGMII signals RXD<31:0> and RXC<3:0> as specified in the PCS 64B/65B 
Receive state diagram (see Figure 126–16 and Figure 126–17). Two XGMII data transfers are decoded from 
each block. Where the XGMII and PMA sublayer data rates are not synchronized to a 25:64 ratio, the 
receive process inserts idles, deletes idles, or deletes sequence ordered sets to adapt between rates.
During PMA training mode, PCS Receive checks the received PAM2 framing and signals the reliable 
acquisition of the descrambler state by setting the scr_status parameter of the PMA_SCRSTATUS.request 
primitive to OK.
When the PCS Synchronization process has obtained synchronization, the LDPC frame error ratio (LFER) 
monitor process monitors the signal quality asserting hi_lfer if excessive LDPC frame errors are detected 
(LDPC parity error). If 40 consecutive LDPC frame errors are detected, the block_lock flag is de-asserted. 
When block_lock is asserted and hi_lfer is de-asserted, the PCS Receive process continuously accepts 
blocks. The PCS Receive process monitors these blocks and generates RXD <31:0> and RXC <3:0> on the 
XGMII.
When the receive channel is in training mode, the PCS Synchronization process continuously monitors 
PMA_RXSTATUS.indication (loc_rcvr_status). When loc_rcvr_status indicates OK, then the PCS 
Synchronization process accepts data-units via the PMA_UNITDATA.indication primitive. It attains frame 
and block synchronization based on the PMA training frames and conveys received blocks to the PCS 
Receive process. The PCS Synchronization process sets the block_lock flag to indicate whether the PCS has 
obtained synchronization. The PMA training sequence includes 1 bit pattern on pair A every 256 PAM2 
symbols, which is aligned with the PCS boundary of two LDPC frames. When the PCS Synchronization 
process is synchronized to this pattern, block_lock is asserted.
PHYs with the EEE capability support transition to the LPI mode when the PHY has successfully completed 
training and pcs_data_mode is TRUE. Transitions to and from the LPI mode are allowed to occur 
independently in the transmit and receive functions. The PCS receive function is responsible for detecting 
transitions to and from the LPI receive mode and indicating these transitions using signals defined in 
126.2.2. 
The link partner signals a transition to the LPI mode of operation by transmitting 18 LDPC frames 
composed entirely of 64B/65B blocks of /LI/. When blocks of /LI/ are detected at the output of the 64B/65B 
decoder, rx_lpi_active is asserted by the PCS receive function and the /LI/ character is continuously asserted 
at the receive XGMII. These frames may be preceded by a frame composed partially of /LI/ characters. After 
these frames the link partner begins transmitting zeros, and it is recommended that the receiver power down 
receive circuits to reduce power consumption. The receive function uses LDPC frame counters to maintain 
synchronization with the remote PHY and receives periodic refresh signals that are used to update 
coefficients, so that the integrity of adaptive filters and timing loops in the PMA is maintained. LPI signaling 
is defined in 126.3.5. The quiet-refresh cycle continues until the PMA asserts alert_detect to indicate that the 
alert signal has been reliably detected. After the alert signal the link partner transmits repeated /I/ characters, 
representing a wake signal. The PHY receive function sends /I/ to the XGMII for 18 LDPC frame periods 
and then resumes normal operation. 
126.3.2.3.1 Frame and block synchronization
When the receive channel is operating in normal mode, the frame and block synchronization function 
receives data via 4D-PAM16 PMA_UNITDATA.indication primitives. It shall form a 4D-PAM16 stream 
from the primitives by concatenating requests with the PAM16s of each primitive in order from 


rx_symb_vector<0> to rx_symb_vector<127> (see Figure 126–7). It obtains block_lock to the LDPC 
frames during the PAM2 training pattern using synchronization bits provided on pair A. The 65-bit blocks 
are extracted based on their location in the LDPC frame.
126.3.2.3.2 PCS descrambler
The descrambler processes the payload to reverse the effect of the scrambler using the same polynomial. It 
shall produce the same result as the implementations shown in Figure 126–10 for the MASTER and the 
SLAVE.
126.3.2.3.3 Invalid blocks
A block is invalid if any of the following conditions exists:
a)
The block type field contains a reserved value.
b)
Any control character contains a value not in Table 126–1.
c)
Any O code contains a value not in Table 126–1.
d)
The block contains information from the payload of an invalid received PHY frame or the first 
64B/65B block following an invalid received PHY frame.
The PCS Receive function shall check the integrity of the LDPC parity bits defined in 126.3.2.2.16. If the 
check fails the PHY frame is invalid.
R_BLOCK_TYPE of an invalid block is set to E.
Figure 126–10—MASTER and SLAVE PCS descramblers
S0
S56
S39
S38
S2
S1
S57
Scrambled data input
Serial data output
S0
S56
S19
S18
S2
S1
S57
Scrambled data input
Serial data output
PCS descrambler employed by the MASTER
PCS descrambler employed by the SLAVE


126.3.3 Test-pattern generators
The test-pattern generator mode is provided for enabling joint testing of the local transmitter, the channel 
and remote receiver. When the transmit PCS is operating in test-pattern mode it shall transmit continuously 
as illustrated in Figure 126–6, with the input to the scrambler set to zero and the initial condition of the 
scrambler set to any non-zero value. When the receiver PCS is operating in test-pattern mode it shall receive 
continuously as illustrated in Figure 126–7. After acquiring the self-synchronizing scrambler state, the 
output of the received scrambled values should ideally be zero. Any nonzero values correspond to receiver 
bit errors. This mode is further described as test mode 7 in 126.5.2.
126.3.4 PMA training side-stream scrambler polynomials
The PCS Transmit function employs side-stream scrambling for generating 2-level PAM PMA training 
sequences as follows in Figure 126–11. An implementation of MASTER and SLAVE PHY side-stream 
scramblers is shown in the “Main PN sequence” box. The bits stored in the shift register delay line at time n
are denoted by Scrn[32:0]. At each symbol period, the shift register is advanced by one bit, and one new bit 
represented by Scrn[0] is generated. The transmitter side-stream scrambler is reset upon execution of the 
PCS Reset function. If PCS Reset is executed, all bits of the 33-bit vector representing the side-stream 
scrambler state are arbitrarily set. The initialization of the scrambler state is left to the implementer. In no 
case shall the scrambler state be initialized to all zeros.


126.3.4.1 Generation of bits San, Sbn, Scn, Sdn
PMA training signal encoding rules are based on the generation, at time n, of the four bits San, Sbn, Scn, Sdn. 
These four bits are generated in a systematic fashion using the bits in Scrn[32:0], and an auxiliary generating 
polynomial. For both MASTER and SLAVE PHYs, they are obtained by the same linear combinations of 
bits stored in the transmit scrambler shift register delay line. These four bits are derived from elements of the 
same maximum-length shift register sequence of length 233– 1 as Scrn[0], but shifted in time. The associated 
delays are all large and different so that there is no short-term correlation among the bits San, Sbn, Scn, Sdn. 
The four bits are generated using the bit Scrn[0] and the equations in Figure 126–11 in the “Derived 
sequences” box.
126.3.4.2 Generation of 4D symbols TAn, TBn, TCn, TDn
The four bits San, Sbn, Scn, Sdn are mapped to a 4D symbol (TAn, TBn, TCn, TDn) as follows in 
Figure 126–11.
Figure 126–11—A realization of PMA training PAM2 sequences
Modulation 
symbol 
counter
Infofield (128 bits) added when
16384–128<(n mod 16384)<16384
Generation of 
main PN 
sequence and 
derived 
sequences
0: +9
1: –9
+
0: +9
1: –9
0: +9
1: –9
0: +9
1: –9
n
San
Sbn
Scn
Sdn
TAn
TBn
TCn
TDn
Derived sequences:
Main PN sequence:
San
Scrn 0


if n mod 256 = 0
Scrn 0

otherwise



=
Sbn
Scrn 3

Scrn 8


=
Scn
Scrn 6

Scrn 16



=
Sdn
Scrn 9

Scrn 14



Scrn 19


Scrn 24




=
Scrn 32:1


Scrn
–
31:0


=
Scrn 0

Scrn
–


Scrn
–


+
if PMA_CONFIG=MASTER
Scrn
–


Scrn
–


+
if PMA_CONFIG=SLAVE



=


The inversion on pair A at 256 intervals (
) defines the LDPC boundary during 
data mode.
Notice 
that 
over 
the 
repeating 
time 
intervals 
of 
and 
of 
length 
128, 
, the PMA training pattern in pair A is XOR’ed with the 
Infofield. Thus, pair A transmits the Infofield, which communicates to the remote transceiver settings of 
THP and power backoff and other control information.
126.3.4.3 PMA training mode descrambler polynomials
The PHY shall acquire descrambler state synchronization to the PAM2 training sequence and report success 
through scr_status. For side-stream descrambling, the MASTER PHY shall employ the receiver descrambler 
generator polynomial 
 and the SLAVE PHY shall employ the receiver descrambler 
generator polynomial 
.
126.3.5 LPI signaling
PHYs with EEE capability have transmit and receive functions that can enter and leave the LPI mode 
independently. The PHY can transition to the LPI mode when the PHY has successfully completed training 
and pcs_data_mode is TRUE. The transmit function of the PHY initiates a transition to the LPI transmit 
mode when it generates 64B/65B blocks composed entirely of LPI control characters, as described in 
126.3.2.2.19. The transmit function of the link partner signals the transition using the sleep signal. When the 
transmitter begins to send the sleep signal, it asserts tx_lpi_active and the transmit function enters the LPI 
transmit mode.
Within the LPI mode PHYs use a repeating quiet-refresh cycle (see Figure 126–12). The first part of this 
cycle is known as the quiet period and lasts for a time lpi_quiet_time equal to 120 LDPC frame periods. The 
quiet period is defined in 126.3.5.2. The second part of this cycle is known as the refresh period and lasts for 
a time lpi_refresh_time equal to 8 LDPC frame periods. The refresh period is defined in 126.3.5.3. A cycle 
composed of one quiet period and one refresh period is known as a single pair LPI cycle and lasts for a time 
lpi_qr_time equal to 128 LDPC frame periods. The time taken to complete a quiet-refresh cycle for all four 
pairs is known as a complete LPI cycle. 
lpi_offset, lpi_quiet_time, lpi_refresh_time, lpi_qr_time, and lpi_allpairs_qr_time are timing parameters 
that are integer multiples of the LDPC frame period. lpi_offset is a fixed value equal to lpi_qr_time/2 that is 
used to ensure refresh signals are appropriately offset by the link partners.
 
n
k
256 k


0 1 2 

=
=
m
–

n
m
16384 m




1 2 3 

=
g'M x

x20
x33
+
+
=
g'S x

x13
x
+
+
=
lpi_quiet_time
lpi_refresh_time
lpi_qr_time
lpi_allpairs_qr_time
Figure 126–12—Timing periods for LPI signals
Pair A
R
Pair C
R
Pair D
R
Pair B
active_pair
A
B
C
D
quiet
quiet
A
R
refresh (R)


PHYs begin the transition from the LPI receive mode when the alert signal is detected by the PMA as 
defined in 126.4.2.4. 
126.3.5.1 LPI Synchronization
To maximize power savings, maintain link integrity, and ensure interoperability, EEE-capable PHYs 
synchronize refresh intervals during the LPI mode. The transition to PCS_Test is used as a fixed timing 
reference for the link partners. Refresh signaling is derived by counting LDPC frames from the transition to 
PCS_Test.
In initial training, normal retraining, and fast retraining, with or without the EEE capability being supported, 
the master and slave signal when they transition to PCS_Test using the transition counter following the 
procedure described in 126.4.2.5.15.
A EEE-capable PHY in slave mode is responsible for synchronizing its PMA training frame to the master’s 
PMA training frame during the transition to PMA_Training_Init_S. The slave shall ensure that its PMA 
training frames are synchronized to the master’s PMA training frames within two LDPC frames, measured 
at the slave MDI on pair A. In addition, the slave shall initialize its transition counter so that it transitions to 
PCS_Test within two LDPC frames of the master PHY’s transition to PCS_Test, measured at the slave 
PHY’s MDI on pair A. This mechanism ensures that the refresh offset is bounded to a small value at both 
MDI interfaces, thus ensuring there is no overlap of master and slave signals when both transmit and receive 
are in the LPI mode. 
Following the transition to PCS_Test, the PCS counts transmitted and received LDPC frames, and uses these 
counters to generate refresh and pair control signals for the transmit and receive functions. The transmitted 
LDPC frame count is named tx_ldpc_frame_cnt. The received LDPC frame count is named 
rx_ldpc_frame_cnt.
The master and slave shall derive the active pair and refresh_active signals from the LDPC frame counters 
as follows in Table 126–4 and Table 126–5.
Table 126–4—Synchronization logic derived from slave signal LDPC frame count 
Slave-side variable
Master-side variable
for master u=rx_ldpc_frame_cnt
for slave u=tx_ldpc_frame_cnt
tx_refresh_active=true
rx_refresh_active=true
lpi_offset – lpi_refresh_time  
mod(u,lpi_qr_time) < lpi_offset 
tx_lpi_full_refresh=true
N/A
lpi_offset – lpi_refresh_time = 
mod(u,lpi_qr_time)
tx_active_pair=PAIR_A
rx_active_pair=PAIR_A
lpi_offset + lpi_qr_time  u < lpi_offset 
+ 2  lpi_qr_time
tx_active_pair=PAIR_B
rx_active_pair=PAIR_B
lpi_offset + 2  lpi_qr_time  u < 
lpi_offset + 3  lpi_qr_time
tx_active_pair=PAIR_C
rx_active_pair=PAIR_C
lpi_offset + 3  lpi_qr_time  u < 4  
lpi_qr_time OR
0  u < lpi_offset
tx_active_pair=PAIR_D
rx_active_pair=PAIR_D
lpi_offset  u < lpi_offset + lpi_qr_time


126.3.5.2 Quiet period signaling
During the quiet period the transmitters on all four pairs should be turned off. Average launch power (as 
measured from 56 LDPC frames after a refresh period to 56 LDPC frames before the next refresh period on 
the same lane) for each Transmitter shall be less than –41 dBm. This requirement does not apply to the 
periods when the alert signal is transmitted as defined in 126.4.2.2.1.
126.3.5.3 Refresh period signaling
During the LPI mode 2.5GBASE-T and 5GBASE-T PHYs use staggered, out-of-phase refresh signaling to 
maximize power savings. Two-level PAM refresh symbols are generated using the PMA side-stream 
scrambler polynomials described in 126.3.4 and exactly as is shown in Figure 126–11 with the exception 
that the Infofield consists of a sequence of 128 zeros. The training sequence described in 126.3.4 shall be 
used during the LPI mode, with the scramblers free-running from PCS Reset.
Refresh signals shall be sent using the THP filter as described in 126.4.3.1. At the start of each refresh signal 
the THP feedback delay line shall be initialized with zeros.
While a transmit function is in the LPI transmit mode only one of the transmit pairs is active during a refresh 
period. tx_symb_vector for all transmit pairs that are not active shall be set to zero. 
When tx_symb_vector has the value ALERT and the PHY is master, the transmitter on pair A shall be active 
and all other pairs shall be quiet. When tx_symb_vector has the value ALERT and the PHY is slave, the 
transmitter on pair C shall be active and all other pairs shall be quiet. If lpi_tx_mode=REFRESH_A on a 
MASTER PHY or lpi_tx_mode=REFRESH_C on a SLAVE PHY, and tx_symb_vector has the value 
ALERT, then the alert signaling shall be transmitted in place of the refresh signaling where the signals 
overlap. 
126.3.6 Detailed functions and state diagrams
126.3.6.1 State diagram conventions
The body of this subclause is composed of state diagrams, including the associated definitions of variables, 
constants, and functions. Should there be a discrepancy between a state diagram and descriptive text, the 
state diagram prevails.
Table 126–5—Synchronization logic derived from master signal LDPC frame count
Slave-side variable
Master-side variable
for master v=tx_ldpc_frame_cnt
for slave v=rx_ldpc_frame_cnt
rx_refresh_active=true
tx_refresh_active=true
lpi_quiet_time mod(v,lpi_qr_time)
N/A
tx_lpi_full_refresh=true
lpi_quiet_time = mod(v,lpi_qr_time)
rx_active_pair=PAIR_A
tx_active_pair=PAIR_A
0  v < lpi_qr_time
rx_active_pair=PAIR_B
tx_active_pair=PAIR_B
lpi_qr_time  v < 2  lpi_qr_time
rx_active_pair=PAIR_C
tx_active_pair=PAIR_C
2  lpi_qr_time  v < 3  lpi_qr_time
rx_active_pair=PAIR_D
tx_active_pair=PAIR_D
3  lpi_qr_time  v < 4  lpi_qr_time


The notation used in the state diagrams follows the conventions of 21.5. State diagram timers follow the 
conventions of 14.2.3.2. The notation ++ after a counter or integer variable indicates that its value is to be 
incremented.
126.3.6.2 State diagram parameters
126.3.6.2.1 Constants
EBLOCK_R<71:0> 
72 bit vector to be sent to the XGMII interface containing /E/ in all the eight character locations.
EBLOCK_T<64:0>
65 bit vector to be sent to the LDPC encoder containing /E/ in all the eight character locations.
LBLOCK_R<71:0>
72 bit vector to be sent to the XGMII interface containing two Local Fault ordered sets. The Local 
Fault ordered set is defined in 46.3.4.
LBLOCK_T<64:0>
65 bit vector to be sent to the LDPC encoder containing two Local Fault ordered sets.
LPBLOCK_R<71:0>
72 bit vector to be sent to the XGMII containing /LI/ in all the eight character locations.
LPBLOCK_T<64:0>
65 bit vector to be sent to the LDPC encoder containing /LI/ in all the eight character locations.
IBLOCK_R<71:0>
72 bit vector to be sent to the XGMII containing /I/ in all the eight character locations.
IBLOCK_T<64:0>
65 bit vector to be sent to the LDPC encoder containing /I/ in all the eight character locations.
UBLOCK_R<71:0>
72 bit vector to be sent to the XGMII containing two Link Interruption ordered sets. The Link 
Interruption ordered set is defined in 46.3.4.
126.3.6.2.2 Variables
lfer_test_lf
Boolean variable that is set true when a new LDPC frame is available for testing and false when 
LFER_TEST_LF state is entered. A new LDPC frame is available for testing when the Block Sync 
process has accumulated enough symbols from the PMA to evaluate the next LDPC frame.
block_lock
Boolean variable that is set true when receiver acquires block delineation.
hi_lfer
Boolean variable that is asserted true when the lfer_cnt reaches 16 errors in one lfer_timer interval.
pcs_reset
Boolean variable that controls the resetting of the PCS. It is true whenever a reset is necessary 
including when reset is initiated from the MDIO, during power on, and when the MDIO has put the 
PCS into low-power mode.
rx_coded<64:0>
Vector containing the input to the 64B/65B decoder. The format for this vector is shown in 
Figure 126–8. The leftmost bit in the figure is rx_coded<0> and the rightmost bit is rx_coded<64>.
rx_raw<71:0> 
Vector containing two successive XGMII output transfers. RXC<3:0> for the first transfer are 
taken from rx_raw<3:0>. RXC<3:0> for the second transfer are taken from rx_raw<7:4>. 
RXD<31:0> for the first transfer are taken from rx_raw<39:8>. RXD<31:0> for the second 
transfer are taken from rx_raw<71:40>.


lf_valid 
Boolean indication that is set true if received LDPC frame is valid. LDPC frame is valid if and only 
if all parity checks of the LDPC code are satisfied.
tx_coded<64:0>
Vector containing the output from the 64B/65B encoder. The format for this vector is shown in 
Figure 126–8. The leftmost bit in the figure is tx_coded<0> and the rightmost bit is tx_coded<64>.
tx_raw<71:0> 
Vector containing two successive XGMII transfers. TXC<3:0> for the first transfer are placed in 
tx_raw<3:0>. TXC<3:0> for the second transfer are placed in tx_raw<7:4>. TXD<31:0> for the 
first transfer are placed in tx_raw<39:8>. TXD<31:0> for the second transfer are placed in 
tx_raw<71:40>.
The following variables are required for PHYs that support the EEE capability:
tx_lpi_active
A Boolean variable that is set true when the PHY transmit function is operating in the LPI transmit 
mode and during transitions to and from the LPI transmit mode (i.e., at any time when the PHY is 
transmitting sleep, alert, wake, or quiet-refresh signaling). It is set false otherwise. 
tx_lpi_qr_active
A Boolean variable that is set true during the LPI transmit mode, when the PHY is transmitting 
quiet-refresh signaling. Set false otherwise.
rx_lpi_active
A Boolean variable that is set true when the PHY receive function is operating in the LPI receive 
mode and set false otherwise. The LPI receive mode begins when the sleep signal is detected and 
lasts until the alert signal is detected. When the EEE capability is not supported, rx_lpi_active is 
set false.
tx_lpi_req
A Boolean variable that is set true when the LPI client indicates that it is requesting operation in 
the LPI transmit mode via the XGMII and set false otherwise.
alert_detect
Indicates that an alert signal from the link partner has been received at the MDI as indicated by 
PMA_ALERTDETECT.indication(alert_detect).
tx_lpi_alert_active
A Boolean variable that is set true when the PHY is transmitting ALERT signaling. Set false 
otherwise.
rx_lpi_wake
A Boolean variable that is set true when the PHY receiver is in the WAKE state and sending IDLE 
to the XGMII. Set false otherwise. When the EEE capability is not supported, rx_lpi_wake is set 
false.
tx_active_pair
A variable indicating the transmit active pair during the LPI transmit mode. The variable may take 
the values PAIR_A, PAIR_B, PAIR_C, PAIR_D. This variable is defined in 126.3.5.1.
lpi_tx_mode
A variable indicating the signaling to be used from the PCS to the PMA across the 
PMA_UNITDATA.request (tx_symb_vector) interface. 
lpi_tx_mode controls tx_symb_vector only when tx_mode is set to SEND_N.
The variable is set to NORMAL when (!tx_lpi_qr_active * !tx_lpi_alert_active), indicating that the 
PCS is in the normal mode of operation and encodes code-groups as described in Figure 126–14 
and Figure 126–15.
The variable is set to REFRESH_A when (tx_lpi_qr_active * (tx_active_pair=PAIR_A) * 
tx_refresh active). 
The variable is set to REFRESH_B when (tx_lpi_qr_active * (tx_active_pair=PAIR_B) * 
tx_refresh active). 
The variable is set to REFRESH_C when (tx_lpi_qr_active * (tx_active_pair=PAIR_C) * 


tx_refresh active). 
The variable is set to REFRESH_D when (tx_lpi_qr_active * (tx_active_pair=PAIR_D) * 
tx_refresh active). 
The variable is set to QUIET when (tx_lpi_qr_active * (!tx_refresh_active + tx_lpi_initial_quiet)).
The variable is set to ALERT when (tx_lpi_alert_active).
tx_refresh_active
A Boolean value. This variable is set true following the logic described in 126.3.5.1.
tx_lpi_full_refresh 
A Boolean value. This variable is set true following the logic described in 126.3.5.1.
tx_lpi_initial_quiet
A Boolean value. This variable is set true when the transmit function enters the LPI transmit mode 
and a partial refresh is replaced by quiet signaling.
ldpc_two_frame_done
A Boolean value. This variable is set true when the final symbol of each even LDPC frame aligned 
to the inversion on pair A during PMA training is transmitted and is set false otherwise.
The following variable is only required for PHYs that support the fast retrain capability:
fr_sigtype
If fast retrain is supported, this variable controls the block type the PMA sends on the receive path 
during fast retrain. If MDIO is supported, this variable is set based on the value in 1.147.2:1 as 
follows:
00 IBLOCK_R
01 LBLOCK_R
10 UBLOCK_R
11 Reserved
If MDIO is not supported, an equivalent method of controlling fast retrain functionality should be 
provided.
126.3.6.2.3 Timers
State diagram timers follow the conventions described in 14.2.3.2.
lfer_timer
Timer that is triggered every 125S µs +1%, –25%. When the timer reaches its terminal count it 
sets lfer_timer_done = TRUE.
The following timers are required for PHYs that support the EEE capability:
lpi_tx_sleep_timer
This timer defines the time the local transmitter sends the sleep signal to the link partner.
Values: The condition lpi_tx_sleep_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to 18 LDPC frame periods.
lpi_tx_alert_timer
This timer defines the time the local transmitter transmits the alert signal.
Values: The condition lpi_tx_alert_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to 8 LDPC frame periods.
lpi_tx_wake_timer
This timer defines the time the local transmitter transmits the wake signal.
Values: The condition lpi_tx_wake_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to lpi_wake_time LDPC frame periods.
lpi_rx_wake_timer
This timer defines the time the receiver sends IDLE blocks to the XGMII after the alert signal is 
detected.


Values: The condition lpi_rx_wake_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to lpi_wake_time LDPC frame periods. 
126.3.6.2.4 Functions
DECODE(rx_symb_vector<64:0>) 
In the PCS Receive process, this function takes as its argument 65-bit rx_coded<64:0> from the 
LDPC decoder and decodes the 65B-LDPC bit vector returning a vector rx_raw<71:0>, which is 
sent to the XGMII. The DECODE function shall decode the block based on code specified in 
126.3.2.2.2.
ENCODE(tx_raw<71:0>) 
Encodes the 72-bit vector received from the XGMII, returning 65-bit vector tx_coded. The 
ENCODE function shall encode the block as specified in 126.3.2.2.2.
R_BLOCK_TYPE = {C, S, T, D, E, I, LI, LII}
When the EEE capability is not supported, this function classifies each 65-bit rx_coded vector as 
belonging to one of the five types {C, S, T, D, E} depending on its contents.
When the EEE capability is supported, this function classifies each 65-bit rx_coded vector as 
belonging to the eight types depending on its contents. A vector may simultaneously belong to the 
C and I types when it contains eight valid control characters that are all /I/, but in every other case 
the vector belongs to only one type.
Values:
C; The vector contains a data/ctrl header of 1 and one of the following:
a) A block type field of 0x1E and eight valid control characters other than /E/ and 
/LI/;
b) A block type field of 0x2D or 0x4B, a valid O code, and four valid control 
characters;
c) A block type field of 0x55 and two valid O codes.
S; The vector contains a data/ctrl header of 1 and one of the following:
a) A block type field of 0x33 and four valid control characters;
b) A block type field of 0x66 and a valid O code;
c) A block type field of 0x78.
T; The vector contains a data/ctrl header of 1, a block type field of 0x87, 0x99, 0xAA, 
0xB4, 0xCC, 0xD2, 0xE1, or 0xFF and all control characters are valid.
D; The vector contains a data/ctrl header of 0.
I; If the optional EEE capability is supported, then the I type is a special case of the C 
type where the vector contains a data/ctrl header of 1, a block type field of 0x1E,
and eight control characters of /I/.
LI: If the optional EEE capability is supported, then the LI type occurs when the vector 
contains a data/ctrl header of 1, a block type field of 0x1E, and eight control 
characters of /LI/.
LII: If the optional EEE capability is supported, then the LII type occurs when the vector 
contains a data/ctrl header of 1, a block type field of 0x1E, and one of the following:
a) Four control characters of /LI/ followed by four control characters of /I/;
b) Four control characters of /I/ followed by four control characters of /LI/.
E; The vector does not meet the criteria for any other value.
A valid control character is one containing a 2.5G/5GBASE-T control code specified in 
Table 126–1. A valid O code is one containing an O code specified in Table 126–1.
R_TYPE(rx_coded<64:0>) 
Returns the R_BLOCK_TYPE of the rx_coded<64:0> bit vector.
R_TYPE_NEXT
Prescient end of packet check function. It returns the R_BLOCK_TYPE of the rx_coded vector 
immediately following the current rx_coded vector.


T_BLOCK_TYPE = {C, S, T, D, E, I, LI, LII}
When the EEE capability is not supported, this function classifies each 72-bit tx_raw vector as 
belonging to one of the five types {C, S, T, D, E} depending on its contents. 
When the EEE capability is supported, this function classifies each 72-bit tx_raw vector as 
belonging to the eight types depending on its contents. A vector may simultaneously belong to the 
C and I types when it contains eight valid control characters that are all /I/, but in every other case 
the vector belongs to only one type. 
Values:
C; The vector contains one of the following:
a) Eight valid control characters other than /O/, /S/, /T/, /E/, and /LI/; 
b) One valid ordered set and four valid control characters other than /O/, /S/, and /T/;
c) Two valid ordered sets.
S; The vector contains an /S/ in its first or fifth character, any characters before the S 
character are valid control characters other than /O/, /S/, and /T/ or form a valid 
ordered set, and all characters following the /S/ are data characters.
T; The vector contains a /T/ in one of its characters, all characters before the /T/ are data 
characters, and all characters following the /T/ are valid control characters other 
than /O/, /S/ and /T/.
D; The vector contains eight data characters.
I; If the optional EEE capability is supported, then the I type is a special case of the C 
type where the vector contains eight control characters of /I/.
LI: If the optional EEE capability is supported, then the LI type occurs when the vector 
contains eight control characters of /LI/.
LII: If the optional EEE capability is supported, then the LII type occurs when the vector 
contains one of the following:
a) Four control characters of /LI/ followed by four control characters of /I/;
b) Four control characters of /I/ followed by four control characters of /LI/.
E; The vector does not meet the criteria for any other value.
A tx_raw character is a control character if its associated TXC bit is asserted. A valid control 
character is one containing an XGMII control code specified in Table 126–1. A valid ordered set 
consists of a valid /O/ character in the first or fifth characters and data characters in the three 
characters following the /O/. A valid /O/ is any character with a value for O code in Table 126–1.
T_TYPE(tx_raw<71:0>)
Returns the T_BLOCK_TYPE of the tx_raw<71:0> bit vector.
T_TYPE_NEXT
Prescient end of packet check function. It returns the FRAME_TYPE of the tx_raw vector 
immediately following the current tx_raw vector.
126.3.6.2.5 Counters
lfer_cnt 
Count up to a maximum of 16 of the number of invalid LDPC frames within the current lfer_timer 
period.
The following counters are required for PHYs that support the EEE capability:
tx_ldpc_frame_cnt
An integer value that counts transmit LDPC frame periods. The counter is reset when the first 
symbol of the first LDPC frame crosses the MDI on pair A in the transmit direction after normal 
training or fast retraining. It is incremented after the last symbol of each transmitted LDPC frame. 
tx_ldpc_frame_cnt is reset to 0 when tx_ldpc_frame_cnt = lpi_qr_time  4.
rx_ldpc_frame_cnt
An integer value that counts receive LDPC frame periods. The counter is reset when the first 
symbol of the first LDPC frame crosses the MDI on pair A in the receive direction after normal 


training or fast retraining. It is incremented after the last symbol of each received LDPC frame. 
rx_ldpc_frame_cnt is reset to 0 when rx_ldpc_frame_cnt = lpi_qr_time  4.
lpi_rxw_err_cnt
An integer value that counts the number of receive wake on error conditions. lpi_rxw_err_cnt is 
reset to zero during PCS_Test. The counter is reflected in register 3.22 (see 45.2.3.12).
126.3.6.3 State diagrams
The LFER Monitor state diagram shown in Figure 126–13 monitors the received signal for high LDPC 
frame error ratio.
The 64B/65B Transmit state diagram shown in Figure 126–14 controls the encoding of 65B transmitted 
blocks. It makes exactly one transition for each 65B transmit block processed. Though the Transmit state 
diagram sends Local Fault ordered sets when reset is asserted, the scrambler and 65B-LDPC may not be 
operational during reset. Thus, the Local Fault ordered sets may not appear on the PMA service interface.
The 64B/65B Receive state diagram shown in Figure 126–16 controls the decoding of 65B received blocks. 
It makes exactly one transition for each receive block processed except for the transition from RX_WE to 
RX_E, which occurs immediately after the RX_WE processes are complete.
The PCS shall perform the functions of LFER Monitor, Transmit, and Receive as specified in these state 
diagrams. The PCS shall not perform the LFER Monitor function during LPI receive operation from the 
time that the PCS 64B/65B Receiver enters the state RX_L, until the state RX_W is exited. 
Transitions surrounded by dashed rectangles indicate requirements for 2.5GBASE-T and 5GBASE-T EEE-
capable implementations.
126.3.7 PCS management
The following objects apply to PCS management. If an MDIO Interface is provided (see Clause 45), they are 
accessed via that interface. If not, it is recommended that an equivalent access be provided.
126.3.7.1 Status 
pcs_status 
Indicates whether the PCS is in a fully operational state. It is only true if block_lock is true and 
hi_lfer is false. This status is reflected in MDIO register 3.32.12. A latch low view of this status is 
reflected in MDIO register 3.1.2 and a latch high of the inverse of this status, Receive fault, is 
reflected in MDIO register 3.8.10.
block_lock 
Indicates the state of the block_lock variable. This status is reflected in MDIO register 3.32.0. A 
latch low view of this status is reflected in MDIO register 3.33.15.
hi_lfer 
Indicates the state of the hi_lfer variable. This status is reflected in MDIO register 3.32.1. A latch 
high view of this status is reflected in MDIO register 3.33.14.
Rx LPI indication 
For EEE capability, this variable indicates the current state of the receive LPI function. This flag is 
set to TRUE (register bit set to one) when the PCS 64B/65B Receive state diagram 
(Figure 126–17) is in the RX_L or RX_W states. This status is reflected in MDIO register 3.1.8. A 
latch high view of this status is reflected in MDIO register 3.1.10 (Rx LPI received).
Tx LPI indication
For EEE capability, this variable indicates the current state of the transmit LPI function. This flag 
is set to TRUE (register bit set to one) when the PCS 64B/65B Transmit state diagram 


(Figure 126–15) is in the TX_L or TX_W states. This status is reflected in MDIO register 3.1.9. A 
latch high view of this status is reflected in MDIO register 3.1.11 (Tx LPI received).
126.3.7.2 Counters
The following counters are reset to zero upon read and upon reset of the PCS. When they reach all ones, they 
stop counting. Their purpose is to help monitor the quality of the link.
lfer_count
6-bit counter that counts each time LFER_BAD_LF state is entered. This counter is reflected in 
MDIO register bits 3.33.13:8. The counter is reset when register 3.33 is read by management. Note 
that this counter counts a maximum of 16 counts per lfer_timer period since the LFER_BAD_LF 
can be entered a maximum of 16 times per lfer_timer window.
errored_block_count
8-bit counter. When the receiver is in normal mode, errored_block_count counts once for each time 
RX_E state is entered. This counter is reflected in MDIO register bits 3.33.7:0.


Figure 126–13—LFER monitor state diagram
LFER_MT_INIT
LFER_TEST_LF
hi_lfer  false
lfer_test_lf  false
UCT
pcs_reset + !block_lock + rx_lpi_active 
+ rx_lpi_wake
lf_valid 
lfer_timer_done
LFER_BAD_LF
!lf_valid 
lfer_cnt ++
HI_LFER
hi_lfer  true
lfer_test_lf 
lfer_cnt < 16 
!lfer_timer_done
lfer_cnt =16 
START_TIMER
lfer_cnt  0
start lfer_timer
lfer_cnt < 16 
lfer_timer_done
lfer_timer_done
GOOD_LFER
hi_lfer  false
UCT
lfer_test_lf
lfer_test_lf  false


Figure 126–14—PCS 64B/65B Transmit state diagram, part a
TX_INIT
pcs_reset+!pcs_data_mode
T_TYPE(tx_raw) = (C + LII)
tx_coded  LBLOCK_T
TX_C
tx_coded ENCODE(tx_raw)
T_TYPE(tx_raw) = (E + D + LI +T)
T_TYPE(tx_raw) = S
D
D
TX_E
tx_coded EBLOCK_T
T_TYPE(tx_raw) = (C+LII)
T_TYPE(tx_raw) = S
T_TYPE(tx_raw) = (E + D +T)
TX_D
tx_coded ENCODE(tx_raw)
D
T_TYPE(tx_raw) = D
TX_T
tx_coded ENCODE(tx_raw)
T_TYPE(tx_raw) = T
C
 T_TYPE(tx_raw) = (E + C + LI + LII + S)
T_TYPE(tx_raw) = D
T_TYPE(tx_raw) = T
 T_TYPE(tx_raw) = (E + S)
T_TYPE(tx_raw) = S
D
T_TYPE(tx_raw) = (C + LII) 
C
T_TYPE(tx_raw) = (E + D + T)
L
T_TYPE(tx_raw) = LI 
T_TYPE(tx_raw) = (C+LII)
T_TYPE(tx_raw) = LI 
C
L
L
T_TYPE(tx_raw) = LI
NOTE—Transitions inside dashed boxes are only required for the EEE capability.


TX_L
tx_lpi_req  true
tx_coded  LPBLOCK_T
T_TYPE(tx_raw) = (LI+LII)
TX_WN
tx_lpi_req  false
tx_coded  IBLOCK_T
tx_lpi_active
L
!tx_lpi_active
NOTE—This figure is mandatory for PHYs with the EEE capability.
C
T_TYPE(tx_raw) = (C + D + E + S + T )
Figure 126–15—PCS 64B/65B Transmit state diagram, part b


Figure 126–16—PCS 64B/65B Receive state diagram, part a
RX_INIT
pcs_reset+ hi_lfer + !block_lock + 
!pcs_data_mode
R_TYPE(rx_coded) = C + LII
if !fr_active
   rx_raw  LBLOCK_R
else
   rx_raw  fr_sigtype
end
rx_lpi_wake  false
rx_lpi_active  false
RX_C
rx_raw DECODE(rx_coded)
rx_lpi_wake  false
R_TYPE(rx_coded) = (E + D + LI + T)
R_TYPE(rx_coded) = S
D
D
RX_E
rx_raw EBLOCK_R
R_TYPE(rx_coded) = C + LII
R_TYPE(rx_coded) = S
R_TYPE(rx_coded) = (E + D + T)
RX_D
rx_raw DECODE(rx_coded)
D
R_TYPE(rx_coded) = D
RX_T
rx_raw DECODE(rx_coded)
R_TYPE(rx_coded) = T 
R_TYPE_NEXT = (S + C + LI 
+ LII)
R_TYPE(rx_coded) = (C + LII)
C
C
(R_TYPE(rx_coded) = T
R_TYPE_NEXT  (E + D + T)) + 
R_TYPE(rx_coded) = (E + C + LI + LII + S)
R_TYPE(rx_coded) = D
R_TYPE(rx_coded) = T 
R_TYPE_NEXT = (S + C + LI + LII )
(R_TYPE(rx_coded) = T 
R_TYPE_NEXT  (E + D + T)) + 
R_TYPE(rx_coded) = (E + S)
R_TYPE(rx_coded)= S
D
R_TYPE(rx_coded) = C + LII
C
L
R_TYPE(rx_coded) = LI
E
L
R_TYPE(rx_coded) = LI
L
R_TYPE(rx_coded) = LI
NOTE—Signals and functions shown with dashed lines are only required for the EEE capability.


!alert_detect
lpi_rx_wake_timer_done* 
R_TYPE(rx_coded)=I 
C
RX_L
rx_raw  LP_BLOCK_R
rx_lpi_active true
RX_W
rx_raw  I_BLOCK_R
start lpi_rx_wake_timer
rx_lpi_active false
rx_lpi_wake  true
E
L
Figure 126–17—PCS 64B/65B Receive state diagram, part b
alert_detect
RX_WE
lpi_rxw_err_cnt++
rx_lpi_wake  false
lpi_rx_wake_timer_done* 
!(R_TYPE(rx_coded)=I) 
UCT
NOTE—This figure is mandatory for PHYs with the EEE capability.


 
pcs_reset+!pcs_data_mode
TX_NORMAL
tx_lpi_active  false
tx_lpi_qr_active  false
tx_lpi_alert_active  false
PARTIAL_SLEEP
tx_lpi_active  true 
SEND_QR
tx_lpi_qr_active  true 
tx_lpi_initial_quiet  false
tx_lpi_req *
!ldpc_two_frame_done
lpi_tx_sleep_timer_done*
!tx_lpi_req
!tx_lpi_req * 
ldpc_two_frame_done
lpi_tx_alert_timer_done
lpi_tx_sleep_timer_done*
tx_lpi_req*
(tx_lpi_full_refresh + 
!tx_refresh_active )
SEND_ALERT
start lpi_tx_alert_timer
tx_lpi_qr_active  false
tx_lpi_alert_active  true
lpi_tx_wake_timer_done
SEND_WAKE
start lpi_tx_wake_timer
tx_lpi_alert_active  false
SEND_INITIAL_QUIET
tx_lpi_qr_active  true 
tx_lpi_initial_quiet  true
lpi_tx_sleep_timer_done*
tx_lpi_req*
!tx_lpi_full_refresh*
tx_refresh_active
!tx_lpi_req* 
ldpc_two_frame_done
tx_lpi_req*
!tx_refresh_active
SEND_SLEEP
start lpi_tx_sleep_timer
tx_lpi_active  true 
tx_lpi_req *
ldpc_two_frame_done
ldpc_two_frame_done
NOTE—This figure is mandatory for PHYs with the EEE capability.
Figure 126–18—EEE transmit state diagram


126.3.7.3 Loopback
The PCS shall be placed in loopback mode when the loopback bit in MDIO register 3.0.14 is set to a one. In 
this mode, the PCS shall accept data on the transmit path from the XGMII and return it on the receive path to 
the XGMII. In addition, the PCS shall transmit a continuous stream of 65B-LDPC encoded 4D-PAM16 
symbols to the PMA sublayer, and shall ignore all data presented to it by the PMA sublayer.
126.4 Physical Medium Attachment (PMA) sublayer
126.4.1 PMA functional specifications
The PMA couples messages from a PMA service interface specified in 126.2.2 to the 2.5GBASE-T and 
5GBASE-T baseband media, specified in 126.7. 
The interface between PMA and the baseband medium is the Medium Dependent Interface (MDI), which is 
specified in 126.8.
LINK
MONITOR
PMA_LINK.request 
config
tx_mode
loc_rcvr_status
rem_rcvr_status
recovered_clock
PMA_UNITDATA.request
PMA_UNITDATA.indication
link_status
(link_control)
NOTE 1—The recovered_clock arc is shown to indicate delivery of the recovered clock signal back to PMA TRANSMIT for loop timing.
scr_status
 (tx_symb_vector)
 (rx_symb_vector)
PMA_LINK.indication 
(link_status)
BI_DD +
BI_DD –
BI_DA +
BI_DB +
BI_DA –
BI_DB –
BI_DC +
BI_DC –
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
Figure 126–19— PMA reference diagram
clock
Technology Dependent Interface (Clause 28)
 alert_detect
 rx_lpi_active
NOTE 2—pcs_data_mode is required only for the EEE or fast retrain capabilities alert_detect and rx_lpi_active are only required for 
the EEE capability fr_active is only required for the fast retrain capability.
pcs_data_mode
fr_active
pcs_status


126.4.2 PMA functions
The PMA sublayer comprises one PMA Reset function and five simultaneous and asynchronous operating 
functions. The PMA operating functions are PHY Control, PMA Transmit, PMA Receive, Link Monitor, 
and Clock Recovery. All operating functions are started immediately after the successful completion of the 
PMA Reset function. 
The PMA reference diagram, Figure 126–19, shows how the operating functions relate to the messages of 
the PMA Service interface and the signals of the MDI. Connections from the management interface, 
comprising the signals MDC and MDIO, to other layers are pervasive and are not shown in Figure 126–19.
126.4.2.1 PMA Reset function
The PMA Reset function shall be executed whenever one of the two following conditions occur:
a)
Power on (see 126.3.6.2.2)
b)
The receipt of a request for reset from the management entity
All state diagrams take the open-ended pma_reset branch upon execution of PMA Reset. The reference 
diagrams do not explicitly show the PMA Reset function.
126.4.2.2 PMA Transmit function
The PMA Transmit function comprises four synchronous transmitters to generate four pulse-amplitude 
modulated signals on each of the four pairs BI_DA, BI_DB, BI_DC, and BI_DD. While send_fail is FALSE 
and ALERT is not indicated by tx_symb_vector, PMA Transmit shall continuously transmit onto the MDI 
pulses modulated by the symbols given by tx_symb_vector[BI_DA], tx_symb_vector[BI_DB], 
tx_symb_vector[BI_DC], and tx_symb_vector[BI_DD], respectively after processing with the THP, 
optional transmit filtering, digital to analog conversion (DAC) and subsequent analog filtering. When 
ALERT is indicated by tx_symb_vector, the alert signal is transmitted as specified in 126.4.2.2.1. When 
send_fail is TRUE, the link failure signal is transmitted as specified in 126.4.2.2.2. The four transmitters 
shall be driven by the same transmit clock, TX_TCLK. The signals generated by PMA Transmit shall follow 
the mathematical description given in 126.4.3.1, and shall comply with the electrical specifications given in 
126.5. 
When the PMA_CONFIG.indication parameter config is MASTER, for both normal and LPI operation, the 
PMA Transmit function shall source TX_TCLK from a local clock source while meeting the transmit jitter 
requirements of 126.5.3.3. The MASTER/SLAVE relationship includes loop timing. If the 
PMA_CONFIG.indication parameter config is SLAVE, the PMA Transmit function shall source TX_TCLK 
from the recovered clock of 126.4.2.8 while meeting the jitter requirements of 126.5.3.3.
The PMA Transmit fault function is optional. The faults detected by this function are implementation 
specific. If the MDIO interface is implemented, then this function shall be mapped to the transmit fault bit as 
specified in 45.2.1.7.4.
EEE-capable PHYs shall generate the alert signal as defined in 126.4.2.2.1. PHYs that support the fast 
retrain capability shall generate the link failure signal as defined in 126.4.2.2.2. If ALERT is indicated by 
tx_symb_vector at the same time as send_fail is TRUE, then link failure signaling is transmitted.
126.4.2.2.1 Alert signal
PHYs that support the optional EEE capability transmit the following PAM2 sequence when the 
PMA_UNITDATA.request parameter is set to ALERT. The alert signal is sent for a total of 8 LDPC frame 
periods and begins on a LDPC 2-frame 256 4D-symbol boundary aligned to the inversion on pair A during 


PMA training. The alert signal is transmitted without THP filtering. The alert signal is transmitted on pair A 
when the PHY operates as a MASTER. The alert signal is transmitted on pair C when the PHY operates as a 
SLAVE. All other pairs transmit quiet as described in 126.3.5.
When the PMA_CONFIG.indication(config) is MASTER the alert signal is composed of 7 repetitions of the 
following 128 symbol PAM2 sequence, followed by 128 zero symbols.
xpr_master =
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
When the PMA_CONFIG.indication(config) is SLAVE the alert signal is composed of 7 repetitions of the 
following 128 symbol PAM2 sequence, followed by 128 zero symbols. 
xpr_slave =
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9  –9  –9  –9    9    9    9    9    9    9    9    9    9    9  –9  –9
–9  –9    9    9  –9  –9    9    9  –9  –9  –9  –9  –9  –9  –9  –9
9    9  –9  –9  –9  –9  –9  –9    9    9  –9  –9  –9  –9  –9  –9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
–9
The alert signal is followed by a wake signal composed of repeated IDLE characters encoded using the 
64B/65B encoding technique. At the start of the wake signal all THP feedback delay lines are initialized 
with zeros.


126.4.2.2.2 Link failure signal
PHYs that support the fast retrain capability transmit the link failure signal under the control of the Fast 
Retrain state diagram. The link failure signal indicates to the link partner that a link failure has been detected 
and that the link partners should begin the fast retrain procedure. 
The link failure signal is sent for 8 LDPC frames and begins on an even LDPC frame boundary aligned to 
the inversion on pair A during PMA training. The link failure signal is transmitted without THP filtering. 
The link failure signal is transmitted on pair A when the PHY operates as a MASTER. The link failure 
signal is transmitted on pair C when the PHY operates as a SLAVE. All other pairs transmit quiet as 
described in 126.3.5.
When the PMA_CONFIG.indication(config) is MASTER, the link failure signal is composed of 7 
repetitions of the following 128 symbol PAM2 sequence, followed by 128 zero symbols.
xfr_master = xpr_master  (–1)
When the PMA_CONFIG.indication(config) is SLAVE the link failure signal is composed of 7 repetitions of 
the following 128 symbol PAM2 sequence, followed by 128 zero symbols.
xfr_slave = xpr_slave  (–1)
126.4.2.3 PMA transmit disable function
126.4.2.3.1 Global PMA transmit disable function
The Global_PMA_transmit_disable function allows all of the transmitters to be disabled. It is used in either 
of the following cases:
a)
When a Global_PMA_transmit_disable variable is set to TRUE, this function shall turn off all of the 
transmitters so that the each transmitter Average Launch Power of the OFF Transmitter is less than 
–53 dBm.
b)
If a PMA_transmit_fault is detected, then the PMA may set the Global_PMA_transmit_disable to 
TRUE, turning off the transmitter on each pair.
126.4.2.3.2 PMA pair by pair transmit disable function
The PMA_transmit_disable function allows the transmitters on each pair to be selectively disabled.
When a PMA_transmit_disable_N variable is set to TRUE, this function shall turn off the transmitter 
associated with that variable so that the transmitter Average Launch Power of the OFF Transmitter is less 
than –53 dBm.
126.4.2.3.3 PMA MDIO function mapping
The MDIO capability described in Clause 45 defines several variables that provide control and status 
information for and about the PMA. Mapping of MDIO control variables to PMA control variables is shown 
in Table 126–6. Mapping of MDIO status variables to PMA status variables is shown in Table 126–7.


126.4.2.4 PMA Receive function
The PMA Receive function comprises four independent receivers for pulse-amplitude modulated signals on 
each of the four pairs BI_DA, BI_DB, BI_DC, and BI_DD. The PMA Receive contains the circuits 
necessary to both detect symbol sequences from the signals received at the MDI over receive pairs BI_DA, 
BI_DB, BI_DC, and BI_DD and to present these sequences to the PCS Receive function. The signals 
received at the MDI are described mathematically in 126.4.3.2. The PMA translates the signals received on 
pairs BI_DA, BI_DB, BI_DC, and BI_DD into the PMA_UNITDATA.indication parameter 
rx_symb_vector. The quality of these symbols shall allow an LFER of less than 3.2  10–9 after LDPC 
decoding, over a channel meeting the requirements of 126.7. The receiver shall correct for differential delay 
variations of up to 50 ns across the wire-pairs. The delay skew is removed by computing the relative 
received delay of the four known transmit patterns described in 126.3.4.
To achieve the indicated performance, it is highly recommended that PMA Receive include the functions of 
signal equalization, echo and crosstalk cancellation. The sequence of code-groups assigned to 
tx_symb_vector is needed to perform echo and self near-end crosstalk cancellation.
The PMA Receive function uses the scr_status parameter and the state of the equalization, cancellation, 
estimation, and LPI functions to determine the quality of the receiver performance, and generates the 
loc_rcvr_status variable accordingly. The precise algorithm for generation of loc_rcvr_status is 
implementation dependent.
Table 126–6—MDIO/PMA control variable mapping
MDIO control variable
PMA register name
Register/bit 
number
PMA control variable
Reset
Control register 1
1.0.15
PMA_reset
Global PMD transmit 
disable
Transmit disable register
1.9.0
Global_PMA_transmit_disable
Transmit disable pair D
Transmit disable register
1.9.4
PMA_transmit_disable_D
Transmit disable pair C
Transmit disable register
1.9.3
PMA_transmit_disable_C
Transmit disable pair B
Transmit disable register
1.9.2
PMA_transmit_disable_B
Transmit disable pair A
Transmit disable register
1.9.1
PMA_transmit_disable_A
Table 126–7—MDIO/PMA status variable mapping
MDIO status variable
PMA register name
Register/bit 
number
PMA status variable
Fault
Status register 1
1.1.7
PMA_fault
Transmit fault
Status register 2
1.8.11
PMA_transmit_fault
Receive fault
Status register 2
1.8.10
PMA_receive_fault


The receiver uses the sequence of symbols during the training sequence to detect and correct for pair swaps 
and crossovers. The receiver pairs BI_DA, BI_DB, BI_DC, and BI_DD may be connected in any manner 
described in 126.4.4 to the corresponding transmit pairs. The receiver also detects and corrects for polarity 
mismatches on any pairs and corrects for differential delay variations across the wire-pairs.
The PMA Receive fault function is optional. The PMA Receive fault function is the logical OR of the 
link_status = FAIL and any implementation specific fault. If the MDIO interface is implemented, then this 
function shall contribute to the receive fault bit specified in 45.2.1.7.5.
PMA receive functions that support the optional EEE capability shall generate alert_detect when the alert 
signal is detected at the receiver. The PMA receive function asserts alert_detect after the entire alert signal 
(7 LDPC frame periods of the xpr_master or xpr_slave sequence and 1 frame of silence) has been detected. 
The alert signal is specified in 126.4.2.2.1. The criterion used to generate alert_detect is left to the 
implementer. 
PHYs that support the fast retrain capability shall set link_fail_detect to TRUE when the link failure signal is 
reliably detected at the receiver. The PMA receive function asserts link_fail_detect after the entire link 
failure signal (7 LDPC frame periods of the xfr_master or xfr_slave sequence and 1 frame of silence) has 
been detected. The link failure signal is specified in 126.4.2.2.2. The criterion used to generate 
link_fail_detect is left to the implementer. It is highly recommended that the generation of link_fail_detect is 
qualified with repeated errored frames at the LDPC decoder output.
126.4.2.5 PHY Control function
PHY Control generates the control actions that are needed to bring the PHY into a mode of operation during 
which frames can be exchanged with the link partner. PHY Control shall comply with the state diagram 
description given in Figure 126–26.
During PMA training (includes PMA_Training_Init_M, PMA_Training_Init_S, PMA_PBO_Exch, 
PMA_Coeff_Exch, and PMA_Fine_Adjust states in Figure 126–26), PHY Control information is exchanged 
between link partners with a 16 octet Infofield, which is XOR’ed with the last 128 bits of the PMA 16384 
PAM2 frame on pair A (see Figure 126–11). The link partner is not required to decode every Infofield 
transmitted but is required to decode Infofields at a rate that enables the correct actions to timer expiration 
times, transition counter values, etc. described in Figure 126–26, Figure 126–27, and Figure 126–28. 
The 16 octet Infofield shall include the fields in 126.4.2.5.2 through 126.4.2.5.14, also shown in the 
overview Figure 126–20, and the more detailed Figure 126–21, Figure 126–22, and Figure 126–23.
Figure 126–20—Infofield format
Start of Frame Delimiter 
0xBBA70000
3 Transmitter 
Settings
Message 
Field
SNR 
Margin
Message Field 
Dependent
Message Field 
Dependent
CRC16
4 octets
3 octets
1 octet
4 bits
1.5 octets
4 octets
2 octets


126.4.2.5.1 Infofield notation
For all the Infofield notation below, Reserved<bit location> represents any unused values and shall be set to 
zero and ignored by the link partner. For all PBO Infofield values below, the PBO<6:4> are unsigned 3-bit 
values 000, 001, 010, 011, 100, 101, 110, and 111 shall indicate power backoffs of 0 dB, 2 dB, 4 dB, 6 dB, 
8 dB, 10 dB, 12 dB, and 14 dB respectively. The Infofield is transmitted following the notation described in 
126.3.2.2.3 where the LSB of each octet is sent first and the octets are sent in increasing number order (that 
is, the LSB of Octet 1 is sent first).
126.4.2.5.2 Start of Frame Delimiter
The start of Frame Delimiter consist of 4 octets [Octet 1<7:0>, Octet 2<7:0>, Octet 3<7:0>, Octet 4<7:0>] 
and shall use the hexadecimal value 0xBBA70000. 0xBB corresponds to Octet 1<7:0> and so forth.
126.4.2.5.3 Current transmitter settings
Current transmitter setting (1 octet). Represented by Octet 5{Valid<7>, PBO<6:4>, Reserved<3:0>} and 
shown in Figure 126–24. Used to announce the current fixed PBO setting during PMA_Training_Init_M, 
PMA_Training_Init_S and PMA_PBO_Exch, and the current programmable PBO setting during 
PMA_Coeff_Exch. For every other state this octet is set to zero and ignored by the link partner. The bit Valid 
shall be set to one if the corresponding octet information is valid and shall be set to zero if it the octet 
information is not valid. If Valid is set to zero, the octet is ignored by the link partner.
Figure 126–21—Infofield transition counter format
Start of Frame Delimiter 
0xBBA70000
3 Transmitter 
Settings
Message 
Field
SNR 
Margin
Reser-
ved
Transition 
Counter
Reser-
ved/
Ability
Vendor 
Specific
CRC16
4 octets
3 octets
1 octet
4 bits
2 bits
10 bits
2 octets
2 octets
2 octets
Figure 126–22—Infofield coefficient exchange format
Start of Frame Delimiter 
0xBBA70000
3 Transmitter 
Settings
Message 
Field
SNR 
Margin
Coefficient 
Exchange
Coefficient 
Field
CRC16
4 octets
3 octets
1 octet
4 bits
1.5 octets
4 octets
2 octets
Figure 126–23—Infofield not transition counter and not coefficient exchange format
Start of Frame Delimiter 
0xBBA70000
3 Transmitter 
Settings
Message 
Field
SNR 
Margin
Reserved
Reserved
/Ability
Vendor 
Specific
CRC16
4 octets
3 octets
1 octet
4 bits
1.5 octets
2 octets
2 octets
2 octets


126.4.2.5.4 Next transmitter settings
Next transmitter setting (1 octet). Represented by Octet 6{Valid<7>, PBO<6:4>, Reserved<3:0>} and 
shown in Figure 126–24. Used to announce the next programmable PBO setting during PMA_PBO_Exch 
that takes effect upon entering PMA_Coeff_Exch state. For every other state, this octet is set to zero and 
ignored by the link partner. The bit Valid shall be set to one if the corresponding octet information is valid 
and shall be set to zero if it the octet information is not valid. If Valid is set to zero, the octet is ignored by the 
link partner.
126.4.2.5.5 Requested transmitter settings
Requested remote transmitter setting (1 octet). Represented by Octet 7{Valid<7>, PBO<6:4>, 
Reserved<3:0>} and shown in Figure 126–24. Used to request the remote transmitter programmable PBO 
setting during PMA_PBO_Exch that takes effect upon entering PMA_Coeff_Exch state. For every other 
state, this octet is set to zero and ignored by the link partner. The bit Valid shall be set to one if the 
corresponding octet information is valid and shall be set to zero if it the octet information is not valid. If 
Valid is set to zero, the octet is ignored by the link partner.
126.4.2.5.6 Message field
Message field (1 octet). For the MASTER, this field is represented by Octet 8{PMA_state<7:6>, 
loc_rcvr_status<5>, en_slave_tx<4>, trans_to_Coeff_Exch<3>, Coeff_exchange<2>, trans_to_Fine_Adjust<1>, 
trans_to_PCS_Test<0>}. 
For 
the 
SLAVE, 
this 
field 
is 
represented 
by 
Octet 8{PMA_state<7:6>, 
loc_rcvr_status<5>, timing_lock_OK<4>, trans_to_Coeff_Exch<3>, Coeff_exchange<2>, trans_to_Fine_Adjust
<1>, trans_to_PCS_Test<0>}.
The two state-indicator bits PMA_state<7:6> shall indicate the state of the transmitting transceiver to the 
link partner as follows: PMA_state<7:6>=00 indicates PMA_Training_Init_M or PMA_Training_Init_S, 
PMA_state<7:6>=01 indicates PMA_PBO_Exch, PMA_state<7:6>=10 indicates PMA_Coeff_Exch, and 
PMA_state<7:6>=11 indicates PMA_Fine_Adjust.
All possible Message field settings are listed in Table 126–8 for the MASTER and Table 126–9 for the 
SLAVE. No other value shall be transmitted, and all other values shall be ignored at the receiver. The 
Message field setting for the first transmitted PMA frame shall be the first row of Table 126–8 for the 
MASTER and the first row of Table 126–9 for the SLAVE. Moreover, for a given Message field setting, the 
following Message field setting shall be the same Message field setting or the Message field setting 
corresponding to a row below the current setting. When loc_rcvr_status=OK the Infofield variable is set to 
loc_rcvr_status<5>=1 and set to 0 otherwise.
Figure 126–24—Infofield transmitter setting format
Single transmitter setting detail (one for current, next, or requested)
Valid
Reserved
PBO
bit 7
bit 6
bit 5
bit 4
bit 3
bit 2 bit 1 bit 0


126.4.2.5.7 SNR_margin
SNR_margin (4 bits). Represented by Octet 9<7:4>, which reports received decision point SNR margin in 
1/2 dB steps. SNR_margin is relative to the SNR required for reception of LDPC-coded PAM16 at an LDPC 
frame error ratio of less than 3.2  10–9. The SNR_margin<7:4> 4-bit values, 0010, 0011, 0100, 0101, 0110, 
0111, 1000, 1001, 1010, 1011, 1100, 1101, 1110 shall indicate the decision point SNR margin values of –1.5, 
Table 126–8—Infofield message field valid MASTER settings
PMA_state<7:6>
loc_rcvr_
status
en_slave_tx
trans_to_
Coeff_Exch
Coeff_
exchange
trans_to_
Fine_Adjust
trans_to_
PCS_Test
0/1
Table 126–9—Infofield message field valid SLAVE settings
PMA_state<7:6>
loc_rcvr_
status
timing_lock
_OK
trans_to_
Coeff_Exch
Coeff_
exchange
trans_to_
Fine_Adjust
trans_to_
PCS_Test
0/1
0/1
0/1
0/1


–1, –0.5, 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5 dB respectively. The value 0001 shall indicate a margin of –2 dB 
or less, and the value 1111 shall indicate 5 dB or more. Finally, the value 0000 shall indicate that the SNR 
margin value is unknown.
126.4.2.5.8 Transition counter
Transition counter (10 bits). Represented by the 1.25 octets [Octet 9<1:0>, Octet 10<7:0>]. When 
configured as Transition counter (Coeff_exchange<2>=0 and a transition is announced to 
PMA_Coeff_Exch, PMA_Fine_Adjust or PCS_Test) this field is used as a 10-bit counter that counts the 
number of remaining frames until the next transition (PMA_Coeff_Exch, PMA_Fine_Adjust, PCS_Test).
126.4.2.5.9 Coefficient exchange handshake
Coefficient exchange handshake (12 bits). Represented by the 1.5 octets [Octet 9<3:0>, Octet 10<7:0>]. If 
Coeff_exchange<2>=1, this field is configured as a Coefficient exchange handshake and is used as a 
handshake control channel during programmable THP coefficient exchange. The details of the coefficient 
exchange are described in 126.4.2.5.15.
126.4.2.5.10 Ability fields
Ability field (1 octet). Represented by Octet 12{EEE Ability<7>, THP Bypass Request<6>,Fast 
Retrain<5>, Reserved<4:0>}. Used to advertise the abilities of the PHY during the PMA_PBO_Exch state 
when Message<7:6> = 01.
For every other state, this octet is set to zero and ignored by the link partner. The Ability bits are defined as 
follows:
Octet 12<4:0> = Reserved
Octet 12<5> = Fast Retrain
0 = Fast Retrain not supported
1 = Fast Retrain supported
Octet 12<6> = THP Bypass Request in PMA_Coeff_Exch state
0 = Local device requests link partner not to bypass THP during fast retrain
1 = Local device requests link partner to bypass THP during fast retrain
Octet 12<7> = EEE Ability
0 = EEE not supported
1 = EEE supported.
126.4.2.5.11 Reserved fields
All Infofield fields denoted Reserved in Figure 126–21, Figure 126–22, and Figure 126–23 are reserved for 
future use. This includes Octet 11 and Octet 12 when Coeff_exchange<2>=0 and Message<7:6> is not equal 
to 01; Octet 9<3:2> when transition counter is announced; and [Octet 9<3:0>, Octet 10<7:0>] when no 
transition is announced and no coefficients are exchanged.
126.4.2.5.12 Vendor-specific field
If Coeff_exchange<2>=0, Octet 13 and Octet 14 are vendor-specific fields. If during Auto-Negotiation both 
transceivers agree on the use of the two vendor-specific octets, they may be used as a PHY communication 


channel; otherwise they are set to zero and ignored by the link partner. They are represented by Octet 
13<7:0> and Octet 14<7:0>.
126.4.2.5.13 Coefficient field
The Coefficient field (4 octets) is represented by Octet 11<7:0>, Octet 12<7:0>, Octet 13<7:0>, and 
Octet 14<7:0>. When Coeff_exchange<2>=1, this field is used to exchange programmable THP 
coefficients. It transmits four 8-bit THP coefficients out of the total of 64 (16 coefficients over each of the 4 
pairs). The order is pair A, coefficients 0:3, followed by coefficients 4:7, followed by 8:11 and 12:15. For all 
cases the first coefficient (indices 0, 4, 8, and 12) is mapped to Octet 11, the second coefficient (indices 1, 5, 
9, 13) is mapped to Octet 12 and so on. The same coefficient order is followed to transmit the coefficients 
for pair B, followed by pair C, and finally pair D. The details of the coefficient exchange are described in 
126.4.2.5.15.
126.4.2.5.14 CRC16
CRC16 (2 octets). This field shall contain the CRC16 value calculated using the polynomial (x+1)(x15+x+1) 
of the previous 10 octets, Octet 5<7:0>, Octet 6<7:0>, Octet 7<7:0>, Octet 8<7:0>, Octet 9<7:0>, 
Octet 10<7:0>, Octet 11<7:0>, Octet 12<7:0>, Octet 13<7:0>, and Octet 14<7:0>. The CRC16 shall 
produce the same result as the implementation shown in Figure 126–25. In Figure 126–25 the 16 delay 
elements S0,..., S15, shall be initialized to zero. Afterwards Octet 5 through Octet 14 are used to compute 
the CRC16 with the switch set to CRCgen in Figure 126–25. After all the 10 octets have been processed, the 
switch is set to CRCout and the 16 values stored in the delay elements are transmitted in the order illustrated, 
first S15, followed by S14, and so on, until the final value S0.
126.4.2.5.15 Startup sequence
The startup sequence shall comply with the state diagram description given in Figure 126–26 and the 
transition counter state diagrams Figure 126–27 and Figure 126–28.
During Auto-Negotiation, PHY Control is in the DISABLE_2.5G/5GBASE-T_TRANSMITTER state and 
the transmitters are disabled. During normal training, prior to enabling the transmitter, the THP coefficients 
are set to zero.
When the Auto-Negotiation process asserts link_control=ENABLE, PHY Control enters the 
INIT_MAXWAIT_TIMER state. Upon entering this state, the maxwait_timer is started and PHY Control 
enters the SILENT state, which starts the minwait_timer and forces transmission of zeros by setting 
tx_mode=SEND_Z.
Figure 126–25—CRC16
S0
Octet 5 through Octet 14
CRC16 output
S2
S15
S1
S14
CRCgen
CRCout
...
Logic 0


In MASTER mode, after expiration of the minwait_timer, PHY Control transitions to the 
PMA_Training_Init_M state. 
Upon entering the PMA_Training_Init_M and PMA_Training_Init_S states, the PHY Control forces 
transmission into the training mode by asserting tx_mode=SEND_T, which includes the transmission of 
Infofields.
Upon entering state PMA_Training_Init_M, the MASTER starts transmission with a fixed transmit power 
level, PBO=4 (corresponding to a power backoff of 8 dB). The PBO variable is communicated to the link 
partner via the current transmitter octet of the Infofield.
Initially the MASTER is not ready for the SLAVE to respond and sets en_slave_tx=0, which is 
communicated to the link partner via the Infofield. After the MASTER has sufficiently converged the 
necessary circuitry, the MASTER sets en_slave_tx=1 to allow the SLAVE to transition to 
PMA_Training_Init_S.
In SLAVE mode, PHY Control transitions to the PMA_Training_Init_S state only after the SLAVE PHY 
acquires timing, converges its equalizers, acquires its descrambler state and sets loc_SNR_margin=OK. The 
SLAVE shall respond using the fixed PBO transmit power level, PBO=4 (corresponding to a power backoff 
of 8 dB). For PHYs with the EEE capability, further requirements for this transition are described in 
126.3.5.1.
While in states PMA_Training_Init_S, PMA_PBO_Exch, or PMA_Coeff_Exch, whenever a SLAVE 
operating in loop timing mode loses the MASTER timing reference (for example, after transmit power level 
transitions) it sets timing_lock_OK=0, which is communicated to the link partner via the Infofield. 
Otherwise, timing_lock_OK is set to one.
In MASTER mode, PHY Control enters the PMA_PBO_Exch state after loc_SNR_margin=OK and in 
SLAVE mode PHY Control enters the PMA_PBO_Exch state after the loc_SNR_margin=OK and 
minwait_timer expires. In the PMA_PBO_Exch state while Infofield Message<7:6> = 01, the PHY 
advertises EEE and Fast Retrain capability in octet 12 of the Infofield. When both the local device and 
remote device advertise EEE capability then EEE is supported. When both the local device and remote 
device advertise Fast Retrain capability then Fast Retrain is supported. In the PMA_PBO_Exch state, after 
the MASTER has computed the final desired programmable PBO level, it shall request a PBO change using 
the requested transmitter setting in the Infofield (octet 7). In SLAVE mode, after the MASTER has requested 
the desired PBO level, the SLAVE shall request a desired PBO level that is within two levels (within 4 dB) 
of the requested MASTER PBO level. 
Following PBO exchange for both transceivers, each PHY shall announce the next PBO setting using the 
next transmitter setting (octet 6). Afterwards, each PHY announces a transition to the PMA_Coeff_Exch 
state using the trans_to_Coeff_Exch=1 and transition_count as described in 126.4.5.1. MASTER initiates 
the transition to PMA_Coeff_Exch count with the trans_to_Coeff_Exch=1 flag and a transition counter 
value of S  28. The SLAVE responds prior to the MASTER transition counter reaching S  25 by setting 
trans_to_Coeff_Exch=1 flag and a transition counter value matching the MASTER. The PMA frame after 
each transceiver transition_count reaches zero, the PHYs shall enter the PMA_Coeff_Exch state and enable 
the requested PBO. Therefore, both PHYs enter the PMA_Coeff_Exch state within one PMA frame.
While both MASTER and SLAVE are in state PMA_Coeff_Exch, when either end has computed the 
programmable THP settings, the programmable THP coefficient exchange process can begin, using the 1.5-
octet Coefficient exchange handshake and the 4-octet Coefficient field as follows:
a)
During PMA_Coeff_Exch each PHY begins a coefficient exchange by setting the Coeff_Exchange 
flag to 1 in the Message field.


b)
During coefficient exchange, the transition counter bits are used as the Coefficient Exchange 
Handshake
1)
Octet 9{Reserved<3:0>}: unused
2)
Coefficient Pair Received, Octet 10<7:6>: 01 for local transmitter pair A, 10 for B, 11 for C 
and 00 for D (default). This is the handshake to tell the remote unit the last coefficients 
received.
3)
Coefficient Group Received, Octet 10<5:4>: 01 for coefficients 0:3, 10 for 4:7, 11 for 8:11 and 
00 for 12:15 (default). This is the handshake to tell the remote unit the last coefficients 
received.
4)
Coefficient Pair Sent, Octet 10<3:2>: 01 for remote transmitter pair A, 10 for B, 11 for C and 
00 for D (default). This is the handshake to tell the remote unit the current coefficients being 
sent.
5)
Coefficient Group Sent, Octet 10<1:0>: 01 for 0:3, 10 for 4:7, 11 for 8:11 and 00 for 12:15 
(default). This is the handshake to tell the remote unit the current coefficients being sent.
c)
The Coefficient field is used to send four 8-bit coefficients in each frame designated by the 
Coefficient Pair Sent and Coefficient Group Sent bits. The coefficient format is as follows:
1)
8 bits per coefficient. Use one octet per coefficient in twos complement notation
2)
Coefficient range is –2.0 to 1.984375 in steps of 0.015625
3)
The sign of the coefficients shall be consistent with Equation (126–3)
d)
Each PHY begins the exchange by sending pair A coefficients 0:3 with Coefficient Pair Sent=01 and 
Coefficient Group Sent=01.
e)
The remote unit acknowledges by setting Coefficient Pair Received=01 and Coefficient Group 
Received=01.
f)
Following each acknowledgment, the PHY increments through the Coefficient Group and then 
Coefficient Pair settings until Coefficient Pair Sent=00 and Coefficient Group Sent=00 and 
Coefficient Pair Received=00 and Coefficient Group Received=00. At this time, coefficient 
exchange is done and both PHYs set Coeff_Exchange=0.
Following coefficient exchange for both transceivers, each PHY announces a transition to the 
PMA_Fine_Adjust state (trans_to_Fine_Adjust=1) and starts the transition_count as described in 126.4.5.1. 
During the first PMA frame after the transition_count reaches zero, the PHYs enter the PMA_Fine_Adjust 
state and enable the THP precoders with the requested coefficients. At the closure of the THP feedback loop, 
the initial state of the THP feedback filters shall be the last 16 symbols from the state PMA_Coeff_Exch.
The THP coefficients and PBO setting may not be changed during PMA_Fine_Adjust. The final 
convergence of the adaptive filter parameters is completed in the PMA_Fine_Adjust state.
After the PHY completes successful training and establishes proper receiver operations, PCS Transmit 
conveys this information to the link partner via transmission of the parameter Infofield value 
loc_rcvr_status. The link partner’s value for loc_rcvr_status is stored in the local device parameter 
rem_rcvr_status. When the condition loc_rcvr_status=OK and rem_rcvr_status=OK is satisfied, each PHY 
announces a transition to the PCS_Test state (trans_to_PCS_Test=1) and start the transition counter as 
described in 126.4.5.1. For PHYs with the EEE capability, further requirements for this transition are 
described in 126.3.5.1.
The normal mode of operation corresponds to the PCS_Data state, where PHY Control asserts 
tx_mode=SEND_N and transmission of data over the link can take place.
PHY Control may force the transmit scrambler state to be initialized to an arbitrary value by requesting the 
execution of the PCS Reset function defined in 126.3.2.1.
The operation of the maxwait_timer requires that the PHY complete the startup sequence from state 
SILENT to PMA_Fine_Adjust in the PHY Control state diagram (Figure 126–26) in less than 2000 ms to 


avoid link_status being changed to FAIL by the Link Monitor state diagram (Figure 126–29). To ensure 
interoperability the timing in Table 126–10 should be observed.
After reaching the PCS_Data state, PHYs with the EEE capability can transition to the LPI receive mode 
under the control of the link partner and to the LPI transmit mode under control of the local LPI client.
126.4.2.5.16 Fast retrain function
PHYs that support the fast retrain capability shall conform to the fast retrain state diagram shown in 
Figure 126–31. PHYs may request a fast retrain by setting the variable loc_fr_req to TRUE. This causes the 
transmission of an easily-detected link failure signal specified in 126.4.2.2.2. After completing the link 
failure signal the PHY shall transition to the PMA_INIT_FR state followed immediately by the 
PMA_Coeff_Exch state. If the link partner requested THP bypass for fast retrain the PHY bypasses the THP 
(or set THP coefficients to zero). Otherwise the PHY shall keep its THP turned on with its previously 
exchanged coefficients, and send PAM2 signaling within a time period equivalent to 18 LDPC frame 
periods.
After the detection of the link failure signal, a PHY shall transition to the PMA_Coeff_Exch state and 
respond with PAM2 signaling within a time period equivalent to 18 LDPC frame periods after receiving the 
link failure signal. 
The PAM2 symbols are generated using the PMA sidestream scrambler polynomials shown in 
Figure 126–11. The training sequence described in 126.3.4 shall be used during fast retraining, with the 
scramblers free-running from PCS Reset.
Note that reliable traffic on the transmitter may be interrupted when the local receiver requests a fast retrain.
Following the link failure signal, the two link partners transition back to the PMA_Coeff_Exch state and 
follow the training procedure described in 126.4.2.5.15, with the exception that the initial Infofield 
countdown values are reduced as indicated in Figure 126–27 and Figure 126–28. 
To ensure interoperability the training times in Table 126–11 should be observed during the fast retrain.
Table 126–10—Recommended startup sequence timing
Master
Recommended
maximum
time (ms)
Recommended
average
time (ms)
Slave
SILENT plus 
(PMA_Training_Init_M state
AND en_slave_tx = 0)
SILENT
(PMA_Training_Init_M state
AND en_slave_tx = 1) plus
PMA_PBO_Exch state
PMA_Training_Init_S state 
plus PMA_PBO_Exch state
PMA_Coeff_Exch state
PMA_Coeff_Exch state with 
timing_lock_OK=0
Total for PMA Coeff Exch state
PMA_Fine_Adjust state
PMA_Fine_Adjust state
Total


126.4.2.6 Link Monitor function
Link Monitor determines the status of the underlying receive channel and communicates it via the variable 
link_status. Failure of the underlying receive channel typically causes the PMA’s clients to suspend normal 
operation. 
The Link Monitor function shall comply with the state diagram of Figure 126–29.
Upon power on, reset, or release from power down, the Auto-Negotiation algorithm sets 
link_control=SCAN_FOR_CARRIER and, during this period, sends fast link pulses to signal its presence to 
a remote station. If the presence of a remote station is sensed through reception of fast link pulses, the Auto-
Negotiation algorithm sets link_control=DISABLE and exchanges Auto-Negotiation information with the 
remote station. During this period, link_status=FAIL is asserted. If the presence of a remote 2.5GBASE-T or 
5GBASE-T station is established, the Auto-Negotiation algorithm permits full operation by setting 
link_control=ENABLE. As soon as reliable transmission is achieved, the variable link_status=OK is 
asserted, upon which further PHY operations can take place.
126.4.2.7 Refresh Monitor function
The Refresh monitor is required for PHYs that support the EEE capability. The Refresh monitor operates 
when the PHY is in the LPI receive mode. The Refresh monitor shall comply with the state diagram of 
Figure 126–17. The function forces a link retrain if a refresh signal is not reliably detected within a moving 
time window equivalent to 50 complete quiet-refresh cycles (nominally equal to 16.384/S ms), when the 
PHY is in the lower power receive mode.
126.4.2.8 Clock Recovery function
The Clock Recovery function couples to all four receive pairs. It may provide independent clock phases for 
sampling the signals on each of the four pairs.
The Clock Recovery function shall provide clocks suitable for signal sampling on each line so that the 
LDPC FER indicated in 126.4.2.4 is achieved. The received clock signal should be stable and ready for use 
when training has been completed (loc_rcvr_status=OK). The received clock signal is supplied to the PMA 
Transmit function by received_clock.
126.4.3 MDI
Communication through the MDI is summarized in 126.4.3.1 and 126.4.3.2.
126.4.3.1 MDI signals transmitted by the PHY
The symbols to be transmitted by the PMA on the four pairs BI_DA, BI_DB, BI_DC, and BI_DD are 
denoted 
by 
tx_symb_vector[BI_DA], 
tx_symb_vector[BI_DB], 
tx_symb_vector[BI_DC], 
and 
Table 126–11—Recommended fast retrain sequence timing
State
Recommended 
maximum time (ms)
PMA_Coeff_Exch state
PMA_Fine_Adjust state


tx_symb_vector[BI_DD], respectively. The modulation scheme used over each pair is PAM16. PMA 
Transmit generates a pulse-amplitude modulated signal on each pair in the following form:
(126–3)
(126–4)
In Equation (126–3), an is the PAM16 modulation symbol from the set {–15, –13, –11, –9, –7, –5, –3, –1, 1, 
3, 5, 7, 9, 11, 13, 15} to be transmitted at time 
. Each of the 16 THP coefficients c1, c2,..., c16 per wire 
pair is represented in two’s complement form by 8 bits described in 126.4.2.5. The nonlinear THP operation 
given by 
 corresponds to changing the modulation symbol an to an 
augmented modulation symbol 
 with the integer mn chosen such that the THP output lies in 
the interval 
. Equation (126–4) describes the convolution of the THP output signals with the 
transmitter symbol response 
 to obtain the transmit signal 
 at the MDI. The values of the 
programmable THP coefficients are exchanged in the Infofield during PMA_Coeff_Exch. The THP filter 
coefficients shall be fixed after startup.
The nominal power (denoted Ptx) and the symbol response of the PMA transmitted signal 
, shall 
comply with the electrical specifications given in 126.5. When the link segment does not experience the 
maximum insertion loss (IL), each transceiver indicates to the link partner that the link partner PMA 
Transmit signal shall be reduced in increments of 2 dB. The minimum power backoff level requested shall 
comply with the power backoff schedule in Table 126–12. If a given receiver has sufficient decision point 
SNR margin, it may choose to request from the link partner larger power backoff (up to 14 dB) than shown 
in Table 126–12. Additionally, the Slave shall select a PBO level as described in the PMA_PBO_Exch state 
of 126.4.2.5.15. The PMA Transmit shall be capable of eight power backoff settings in approximately 2 dB 
steps. The difference between each consecutive power setting shall be 2  0.25 dB, and each step shall be 
centered at 2  n dB (n = 0 to 7) reduction from nominal, with a maximum error of  1 dB.
The received signal power at the MDI, P (dBm), in Table 126–12, should be the estimate of the average 
received power across all four pairs from the remote transmitter when the link partner PMA Transmit is at 
nominal power (after accounting for local transmitter power). If the remote transmitter is not at nominal 
power during the measurement, the estimate of the received power should be incremented by the amount of 
power backoff of the link partner transmitter during the measurement. Nominal power refers to the transmit 
power without any power backoff and is specified in 126.5.3.4. The estimate of the received signal power is 
stored in registers 1.141 to 1.144 as described in 45.2.1. The values in the length, L (m), column in 
Table 126–12 are for reference only (not required for power backoff evaluation).
xn
M an
xn
k
– ck
k
=

–




an
32mn
xn
k
– ck
k
=

–
+
=
=
s t
xnhT t
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
M 


+

mod32
–
=
a˜n
an
32mn
+
=
–
xn


hT t
s t
s t


126.4.3.2 Signals received at the MDI 
Signals received at the MDI can be expressed for each pair as pulse-amplitude modulated signals that are 
corrupted by noise as follows:
(126–5)
In Equation (126–5), 
 are the augmented PAM16 modulation symbols described in 126.4.3.1, hR(t)
denotes the symbol response of the overall channel from the THP precoder to the MDI at the receiver, and 
w(t) represents the contribution of various noise sources including uncancelled crosstalk. The four signals 
received on pairs BI_DA, BI_DB, BI_DC, and BI_DD are processed within the PMA Receive function to 
yield the received symbols rx_symb_vector.
126.4.4 Automatic MDI/MDI-X configuration
Automatic MDI/MDI-X configuration is intended to eliminate the need for crossover cables between similar 
devices. Automatic MDI/MDI-X configuration is required for 2.5GBASE-T and 5GBASE-T devices and 
shall comply with 40.4.4.1 and 40.4.4.2.
Having established MDI/MDI-X configuration, the receiver shall detect and correct for several 
configurations of pair swaps and crossovers and arbitrary polarity swaps. The receiver pairs BI_DA, BI_DB, 
BI_DC, and BI_DD might be connected to the corresponding transmit pairs in any of the following ways 
with arbitrary polarity:
a)
No crossover
b)
A/B crossover only
c)
C/D crossover only
d)
A/B crossover and C/D crossover
Table 126–12—Power backoff schedule
5GBASE-T
Received signal power at MDI, 
P (dBm)
Length L(m)
(reference)
Minimum power 
backoff (dB)
 
2.5GBASE-T
Received signal power at MDI, 
P (dBm)
Length L(m)
(reference)
Minimum power 
backoff (dB)
 
5.8
–
P

L


7.0
–
P

5.8
–

L


9.2
–
P

7.0
–

L


–
P

9.2
–

L


P
–

L

4.3
–
P

L


P
4.3
–

L

r t
a˜nhR t
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
a˜ n


For EEE-capable PHYs, the MDI/MDIX function configuration shall apply to refresh and alert signaling. 
For PHYs with the fast retrain capability, the MDI/MDIX function configuration shall apply to link failure 
signaling.
126.4.5 State variables
126.4.5.1 State diagram variables
coeff_exchange_done
This variable reports that both transceivers have received the corresponding coefficients from the 
link partner. 
Values:TRUE: The coefficient exchange has completed.
FALSE: The coefficient exchange has not completed.
config
The PMA shall generate this variable continuously and pass it to the PCS via the PMA_CON-
FIG.indication primitive. 
Values:MASTER or SLAVE.
link_control 
The link_control parameter generated by Auto-Negotiation and passed to the PMA via the 
PMA_LINK.request primitive (see 126.2.1.1).
link_status 
The link_status parameter set by PMA Link Monitor state diagram and communicated through the 
PMA_LINK.indication primitive. 
Values:OK or FAIL.
loc_rcvr_status 
Variable set by the PMA Receive function to indicate correct or incorrect operation of the receive 
link for the local PHY.
Values:OK: The receive link for the local PHY is operating reliably.
NOT_OK: Operation of the receive link for the local PHY is unreliable.
loc_SNR_margin 
This variable reports whether the local device has sufficient SNR margin to continue to the next 
state. The criterion for setting the parameter loc_SNR_margin is left to the implementer. 
Values:OK: The local device has sufficient SNR margin.
NOT_OK: The local device does not have sufficient SNR margin.
master_transition_counter
This variable reports the current value of the MASTER’s transition counter reported in the Infof-
ield defined in 126.4.2.5. 
Values: 0 to 29.
MessageField_IF
This variable reports that a receiver has successfully received and decoded the Infofield from the 
remote device. This variable takes on the value contained in the Message field. If the Message field 
cannot be decoded or no explicit action is outstanding the value Null is returned.
Values: trans_to_Coeff_Exch, trans_to_Fine_Adjust, trans_to_PCS_Test or Null.
PBO
PBO is a variable that can take any integer value from 0 to 7 and indicates the power backoff level.
Denoting Ptx as the maximum nominal power, the PBO values are as follows: 
Values:0, 1, 2, 3, 4, 5, 6, 7, which correspond to transmit power levels of 
Ptx, Ptx–2 dB, Ptx–4 dB, Ptx–6 dB, Ptx–8 dB, Ptx–10 dB, Ptx–12 dB, Ptx–14 dB
respectively.
PBO_next
PBO_next is a variable that can take any integer value from 0 to 7 and indicates the next power 
backoff level to be used at the local transmitter. The value is taken from the fixed set of values 
during PMA_Training_Init_M and PMA_Training_Init_S as described in 126.4.2.5. The value is 


taken from the decoded value of the link partner Infofield during PMA_PBO_Exch 
Values:0, 1, 2, 3, 4, 5, 6, 7, which correspond to transmit power levels of 
Ptx, Ptx–2 dB, Ptx–4 dB, Ptx–6 dB, Ptx–8 dB, Ptx–10 dB, Ptx–12 dB, Ptx–14 dB
respectively.
PBO_tx
PBO_tx is a variable that can take any integer value from 0 to 7 and indicates the power backoff 
level currently used at the local transmitter. 
Values:0, 1, 2, 3, 4, 5, 6, 7, which correspond to transmit power levels of 
Ptx, Ptx–2 dB, Ptx–4 dB, Ptx–6 dB, Ptx–8 dB, Ptx–10 dB, Ptx–12 dB, Ptx–14 dB
respectively.
PBO_exchange_done 
This variable reports that both transceivers have received the corresponding PBO levels from the 
link partner.
Values:TRUE: The PBO exchange has completed.
FALSE: The PBO exchange has not completed.
pcs_status 
The pcs_status parameter generated by the PCS and passed to the PMA via the PMA_PCSSTA-
TUS.request primitive (see 126.2.2.6).
pma_reset 
Allows reset of the PHY Control and Link Monitor state diagrams.
Values:ON or OFF.
rem_rcvr_status 
Variable set by the PCS Receive function to indicate whether correct operation of the receive link 
for the remote PHY is detected or not. 
Values:OK: The receive link for the remote PHY is operating reliably. 
NOT_OK: Reliable operation of the receive link for the remote PHY is not detected.
THP_next 
THP_next is a variable that contains sixteen 8-bit values and describes the next transmitter setting 
of the THP coefficients. It refers to the programmable THP coefficients selected during coefficient 
exchange described in 126.4.2.5. 
Values:16 coefficients of 8-bit values each. Range is –2.0 to 1.984375 in steps of 0.015625.
THP_tx 
THP_tx is a variable that contains sixteen 8-bit values and describes the current transmitter setting 
of the THP coefficients. It refers to the programmable THP coefficients selected during the coeffi-
cient exchange described in 126.4.2.5. 
Values:16 coefficients of 8-bit values each. Range is –2.0 to 1.984375 in steps of 0.015625.
trans_to_Coeff_Exch 
Message field variable defined in 126.4.2.5 that flags a transition by the local device to the 
PMA_Coeff_Exch state. 
Values:1: The local device transitions to the PMA_Coeff_Exch state on expiration of the transition 
counter.
0: The local device does not transition to the PMA_Coeff_Exch state.
trans_to_Fine_Adjust 
Message field variable defined in 126.4.2.5 that flags a transition by the local device to the 
PMA_Fine_Adjust state. 
Values:1: The local device transitions to the PMA_Fine_Adjust state on expiration of the transition 
counter.
0: The local device does not transition to the PMA_Fine_Adjust state.
trans_to_PCS_Test 
Message field variable defined in 126.4.2.5 that flags a transition by the local device to the 
PCS_Test state. 
Values:1: The local device transitions to the PCS_Test state on expiration of the transition counter.
0: The local device does not transition to the PCS_Test state.


transition_count
This variable reports the value of the transition counter contained in the Infofield sent to the remote 
device. Transition_count has to comply with the state diagram description given in 126.4.6.2. 
When the Message field contains a flag for a state transition, the transition counter denotes the 
remaining number of Infofield until the next state transition. MASTER initiates the transition to 
PMA_Coeff_Exch count with the trans_to_Coeff_Exch=1 flag and a counter value of S  28. The 
SLAVE responds prior to the counter reaching S  25 with the same flag and a count value match-
ing the MASTER. Then both PHY’s transition to PMA_Coeff_Exch within one PMA frame. The 
same sequence is performed in the transition to PMA_Fine_Adjust state and PCS_Test state using 
the trans_to_Fine_Adjust=1 and trans_to_PCS_Test=1 flags respectively. In EEE-capable PHYs, 
synchronization of the PMA frames is tightly controlled as described in 126.3.5.1. When the Mes-
sage field does not contain a flag for a state transition, the transition counter is set to zero and 
ignored by the receiver. 
Values:0 to 29.
tx_mode
PCS Transmit sends code-groups according to the value assumed by this variable. 
Values: SEND_N: This value is continuously asserted when transmission of sequences of code-
groups representing a XGMII data stream take place. 
SEND_T: This value is continuously asserted when transmission of sequences of code-
groups representing the sequences of code-groups (TAn, TBn, TCn, TDn) defined in 126.3.4.2 is to 
take place.
SEND_Z: This value is asserted when transmission of zero code-groups is to take place.
The following variables are required only for PHYs that support the EEE capability:
lpi_refresh_detect
Set TRUE when the receiver has reliably detected refresh signaling and FALSE otherwise. The 
exact criteria left to the implementer.
pcs_data_mode
Generated by the PMA PHY Control function and indicates whether or not the local PHY may 
transition its PCS state diagrams out of their initialization states. The current value of the 
pcs_data_mode is passed to the PCS via the PMA_PCSDATAMODE.indicate primitive. In the 
absence of the optional EEE and fast retrain capabilities, the PHY operates as if the value of this 
variable is TRUE.
mtc
mtc is the transition count for a MASTER PHY during normal training and fast retraining. mtc 
shall be equal to S  28 for normal training and S  25 for fast retrain.
stc
stc is the transition count for a SLAVE PHY during normal training and fast retraining. stc shall be 
equal to S  25 for normal training and S  24 for fast retrain.
The following six variables are required only for PHYs that support the fast retrain capability:
fr_enable
This variable is set to TRUE if fast retrain is supported. The variable is set to FALSE otherwise. If 
MDIO is supported, this variable is based on the value of 1.147.0 with the value of TRUE corre-
sponding to 1.147.0 set to 1. If MDIO is not supported, an equivalent method of controlling fast 
retrain functionality should be provided. 
loc_fr_req
Set TRUE when the receiver has detected a link failure condition and is requesting a fast retrain; 
set FALSE otherwise.


loc_fr_detect
Set TRUE when the receiver has reliably detected the link failure signal. It is highly recommended 
that loc_fr_detect is qualified with the reception of errored blocks at the LDPC decoder output. Set 
FALSE when the link failure signal is not detected.
send_link_fail
When TRUE indicates that the PMA should send the link failure signal. When FALSE the variable 
has no effect.
fr_active
Set TRUE when the PHY is performing a fast retrain and set FALSE otherwise.
fast_retrain_flag
Set TRUE after the PHY generates or detects a link failure signal and set FALSE otherwise.
126.4.5.2 Timers
All timers operate in the manner described in 14.2.3.2.
maxwait_timer 
A timer used to limit the amount of time during which a receiver dwells in the SILENT and 
TRAINING states. The timer shall expire 2000 ms  10 ms after being started. This timer is used 
jointly in the PHY Control and Link Monitor state diagrams. The maxwait_timer is tested by the 
Link Monitor to force link_status to be set to FAIL if the timer expires and loc_rcvr_status is 
NOT_OK. See Figure 126–26 and Figure 126–29.
minwait_timer 
A timer used to determine the minimum amount of time the PHY Control stays in the SILENT, 
PMA_Training_Init_S, PCS_Test and PCS_Data states. The timer shall expire 1 ms 0.1 ms after 
being started.
The following timer is required only for PHYs that support the EEE capability:
lpi_refresh_rx_timer
This timer is used to monitor link quality during the LPI receive mode. If the PHY does not reli-
ably detect reliable refresh signaling before this timer expires then a full retrain is performed.
Values: The condition lpi_refresh_rx_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to 50 complete quiet-refresh signal periods, equiva-
lent to 8.192/S ms.
The following two timers are required only for PHYs that support the fast retrain capability:
link_fail_sig_timer
Determines the period of time the PHY sends the link failure signal.
Values: The condition link_fail_sig_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to 8 LDPC frame periods.
fr_maxwait_timer
Determines the period of time the PHY has to transition its PCS Control State to PCS_Test follow-
ing a fast retrain before the fast retrain is aborted and a full retrain performed.
Values: The condition fr_maxwait_timer_done becomes true upon timer expiration.
Duration: This timer shall have a period equal to 30 ms.


126.4.5.3 Functions
Exchange_Final_PBO 
This function transmits and receives the final PBO settings using the Infofield as described in 
126.4.2.5.
Exchange_THP_Coefficients 
This function compiles and sends to the link partner and receives from the link partner the desired 
programmable THP coefficients using the Infofield as described in 126.4.2.5.
126.4.5.4 Counters
The following two counters are required only for PHYs that support the fast retrain capability:
fr_tx_counter
Counts the number of times the PHY initiates a fast link retrain by transmitting the link failure sig-
nal. This counter is reflected in MDIO register 1.147.10:6 specified in 45.2.1.94.2.
fr_rx_counter
Counts the number of times the PHY begins a fast link retrain in response to the detection of link 
failure signaling from the link partner. This counter is reflected in MDIO register 1.147.15:11 
specified in 45.2.1.94.1.


126.4.6 State diagrams
126.4.6.1 PHY Control state diagram
PCS_Data
tx_mode  SEND_N
stop maxwait_timer
start minwait_timer
TRANSMITTER
start maxwait_timer
tx_mode  SEND_Z
SILENT
PMA_Training_Init_M
config = SLAVE *
link_control  ENABLE + 
DISABLE_2.5G/5GBASE-T
tx_mode  SEND_T
PCS_Test
tx_mode  SEND_N
start minwait_timer
loc_rcvr_status = OK *
link_control = ENABLE
PBO_tx 4
PMA_Fine_Adjust
PMA_Training_Init_S
tx_mode  SEND_T
PBO_tx  4
minwait_timer_done *
loc_rcvr_status = NOT_OK
config = MASTER *
loc_SNR_margin = OK *
pcs_status = NOT_OK) )
(minwait_timer_done *
minwait_timer_done
start minwait_timer
PMA_Coeff_Exch
PBO_tx  PBO_next
THP_tx  THP_next
en_slave_tx = 1 *
INIT_MAXWAIT_TIMER
UCT
trans_to_Coeff_Exch = 1 *
transition_count = 0
trans_to_PCS_Test = 1 *
transition_count = 0
minwait_timer_done
loc_SNR_margin = OK *
minwait_timer_done
Exchange_THP_coefficients
pcs_status = OK
minwait_timer_done *
start minwait_timer
pma_reset = ON
PMA_PBO_Exch
Exchange_Final_PBO
trans_to_Fine_Adjust = 1 *
transition_count = 0
loc_SNR_margin = OK
minwait_timer_done *
stop fr_maxwait_timer
NOTE—For PHYs that do not support the fast retrain capability, the variable fast_retrain_flag is 
set to FALSE.
lpi_rxw_err_cnt  0
pcs_data_mode  true
fr_maxwait_timer_done *
fr_active 
fr_maxwait_timer_done *
fr_active 
I
PMA_INIT_FR
UCT
fast_retrain_flag  false
tx_mode  SEND_T
fr_active  true
fr_active  false
( loc_rcvr_status = NOT_OK +
!fr_active *
pcs_status = NOT_OK) )
(minwait_timer_done *
( loc_rcvr_status = NOT_OK +
fr_active *
fr_active  false
pcs_data_mode  false
pcs_data_mode  false
fast_retrain_flag
THP_tx  zeros
Figure 126–26—PHY Control state diagram
I
I
I


126.4.6.2 Transition counter state diagrams
Figure 126–27—MASTER transition counter state diagram
NOTE—For PHYs that do not support the fast retrain capability, the variable fast_retrain_flag is set to 
FALSE.
INIT
min_wait_timer_done
STOP_COUNTER_ PMA_Coeff_Exch
trans_to_Coeff_Exch  0
PBO_exchange_done = TRUE
fast_retrain_flag = TRUE
START_COUNTER_PMA_Fine_Adjust
transition_count  mtc
trans_to_Fine_Adjust  1
coeff_exchange_done = TRUE
STOP_COUNTER_ PMA_Fine_Adjust
trans_to_Fine_Adjust  0
transition_count = 0
loc_rcvr_status = OK *
rem_rcvr_status = OK
START_COUNTER_PCS_Test
transition_count  mtc
trans_to_PCS_Test  1
STOP_COUNTER_PCS_Test
trans_to_PCS_Test  0
transition_count = 0
transition_count = 0
START_COUNTER_PMA_Coef_Exch
transition_count  mtc
trans_to_Coef_Exch  1


Figure 126–28—SLAVE transition counter state diagram
NOTE—For PHYs that do not support the fast retrain capability, the variable fast_retrain_flag 
is set to FALSE.
START_COUNTER_PMA_Coeff_Exch
MessageField_IF = trans_to_Coeff_Exch *
master_transition_counter > S  25
trans_to_Coeff_Exch  1
transition_count  master_transition_counter
STOP_COUNTER_ PMA_Coeff_Exch
trans_to_Coeff_Exch  0
transition_count = 0
fast_retrain_flag = TRUE
START_COUNTER_PMA_Fine_Adjust
trans_to_Fine_Adjust  1
transition_count  master_transition_counter
MessageField_IF = trans_to_Fine_Adjust *
master_transition_counter > stc
STOP_COUNTER_ PMA_Fine_Adjust
trans_to_Fine_Adjust  0
transition_count = 0
loc_rcvr_status = OK *
rem_rcvr_status = OK *
MessageField_IF = trans_to_PCS_Test *
master_transition_counter > stc
START_COUNTER_PCS_Test
trans_to_PCS_Test  1
transition_count  master_transition_counter
STOP_COUNTER_PCS_Test
trans_to_PCS_Test  0
transition_count = 0


126.4.6.3 Link Monitor state diagram
Figure 126–29—Link Monitor state diagram
LINK_UP
link_status  OK 
LINK_DOWN
link_status  FAIL
minwait_timer_done *
pcs_status = OK
pma_reset = ON +
link_control  ENABLE
NOTE 1—maxwait_timer is started in PHY Control state diagram (see Figure 126–26).
NOTE 2—The variables link_control and link_status are designated as link_control_2p5GigT 
and link_status_2p5GigT, respectively for 2.5GBASE-T, and link_control_5GigT and 
link_status_5GigT, for 5GBASE-T (by the Auto-Negotiation Arbitration state diagram 
(Figure 28–18).
maxwait_timer_done *
(pcs_status = NOT_OK +
loc_rcvr_status = NOT_OK)


126.4.6.4 EEE Refresh monitor state diagram
LPI_OK
LPI_MON_REFRESH
start lpi_refresh_rx_timer
Figure 126–30—EEE Refresh monitor state diagram
rx_lpi_active
NOTE—This state diagram is only required when the PHY supports the EEE capability.
LPI_REFRESH_TIMEOUT
loc_rcvr_status  NOT_OK
!rx_lpi_active
lpi_refresh_rx_timer_done
!lpi_refresh_rx_timer_done *
lpi_refresh_detect


---

