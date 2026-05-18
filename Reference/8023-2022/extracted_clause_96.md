# Clause 96: 100BASE-T1

**Focus**: PCS 4B/5B + PAM3, PMA scrambler, state machines  
**Pages extracted**: 3883 – 3916  
**Excluded from**: Page 3917 (electrical/PICS section)

96. Physical Coding Sublayer (PCS), Physical Medium Attachment (PMA) 
sublayer and baseband medium, type 100BASE-T1
96.1 Overview
The 100BASE-T1 Physical Layer supports standard media access controller (MAC) interfaces via the MII 
defined in Clause 22 with the exception of the MII Management interface defined in 22.2.4. The 100BASE-
T1 management functions are optionally accessible through the management interface defined in Clause 45. 
Each copper port supports a single balanced twisted-pair link segment connection up to 15 m in length. 
100BASE-T1 provides data rate of 100 Mb/s at the MAC interface over a single balanced twisted-pair 
cable as defined in 96.7. The architectural positioning of the 100BASE-T1 Physical Layer is depicted in 
Figure 96–1. 
This clause defines the PCS and PMA sublayers of the 100BASE-T1 PHY. A functional block diagram of 
the 100BASE-T1 PHY is provided in Figure 96–3.
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
LLC (LOGICAL LINK CONTROL)
MAC (MEDIA ACCESS CONTROL)
HIGHER LAYERS
MDI = MEDIUM DEPENDENT INTERFACE
MII = MEDIA INDEPENDENT INTERFACE
PCS = PHYSICAL CODING SUBLAYER
* Physical instantiation of MII is optional.
PMA = PHYSICAL MEDIUM ATTACHMENT
PHY = PHYSICAL LAYER DEVICE
*MII
MDI
PMD = PHYSICAL MEDIUM DEPENDENT
RECONCILIATION
100 Mb/s link segment
MEDIUM
Figure 96–1—Architectural positioning of 100BASE-T1
OR OTHER MAC CLIENT
PMA
PCS
AN**
PHY
** Auto-Negotiation is optional


96.1.1 100BASE-T1 architecture
The 100BASE-T1 PHY operates using full-duplex communications (using echo cancellation) over a single 
balanced twisted-pair. This PHY uses ternary signaling and interfaces to the Clause 22 MII.
The 100BASE-T1 PHY interfaces to a Clause 22 MII. The PMA is similar to Clause 40. The PCS (specified 
in 96.3) is different from the PCS defined in Clause 40.
PMA functionality is defined in 96.4 with reference to Clause 40. The PMA functions are illustrated in 
Figure 96–3.
The 100BASE-T1 PHY leverages 1000BASE-T and 100BASE-TX PHY technologies in operation at 
100 Mb/s, and introduces new PCS, PMA, and other modifications in support of the 100BASE-T1 PHY.
The specification features that enable operation over a single balanced twisted-pair are as follows:
a)
Full-duplex communication with Ethernet MAC compatibility.
Figure 96–2—100BASE-T1 PHY interfaces
BI_DA +
BI_DA -
 
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
PMA_TXMODE.indication
PMA_UNITDATA.indication
PMA_RXSTATUS.indication
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
(MII)
MEDIA
PHY
PMA_RESET.indication
MANAGEMENT
PMA
PCS
PMA_TXEN.request
PMA_LINK.indication


b)
Adopt Pulse Amplitude Modulation 3 (PAM3) to provide trade-off between bandwidth and EMI 
performance.
Auto-Negotiation (Clause 98) may optionally be used by 100BASE-T1 devices to detect the abilities (modes 
of operation) supported by the device at the other end of a link segment, determine common abilities, and 
configure for normal operation. Auto-Negotiation is performed upon link startup through the use of half-
duplex differential Manchester encoding. The implementation of the Auto-Negotiation function is optional. 
If Auto-Negotiation is implemented, it shall meet the requirements of Clause 98.
96.1.1.1 Physical Coding Sublayer (PCS)
The 100BASE-T1 PCS transmits/receives signals to/from a Media Independent Interface (MII) as described 
in Clause 22, to/from signals on a 100BASE-T1 PMA, which supports a single balanced twisted-pair 
medium.
96.1.1.2 Physical Medium Attachment (PMA) sublayer
The 100BASE-T1 PMA transmits/receives signals to/from the PCS onto the single balanced twisted-pair
cable medium and supports the link management and the 100BASE-T1 PHY Control function. The PMA 
provides full duplex communications at 66.666 MBd over a single balanced twisted-pair cable up to 15 m in 
length.
96.1.1.3 Signaling
100BASE-T1 signaling is performed by the PCS generating continuous code-group sequences that the PMA 
transmits over the single balanced twisted-pair. The signaling scheme achieves a number of objectives 
including the following:
a)
Algorithm mapping and inverse mapping from nibble data to ternary symbols and back.
b)
Uncorrelated symbols in the transmitted symbol stream.
c)
No correlation between symbol streams traveling both directions.
d)
Ability to rapidly or immediately determine if a symbol stream represents data or idle.
e)
Robust delimiters for Start-of-Stream delimiter (SSD), End-of-Stream delimiter (ESD), and other 
control signals.
f)
Ability to signal the status of the local receiver to the remote PHY to indicate that the local receiver 
is not operating reliably and requires retraining.
96.1.2 Conventions in this clause
The body of this clause contains state diagrams, including definitions of variables, constants, and functions. 
Should there be a discrepancy between a state diagram and a descriptive text, the state diagram prevails.
96.1.2.1 State diagram notation
The notation used in the state diagrams follows the conventions of 21.5.
96.1.2.2 State diagram timer specifications
All timers operate in the manner described in 40.4.5.2.
96.1.2.3 Service specifications
The method and notation used in the service specification follows the conventions of 1.2.2.


96.2 100BASE-T1 service primitives and interfaces
The 100BASE-T1 PHY shall use the service primitives and interfaces in 40.2, with exception of the 
following clarifications and differences noted in this section, in support of 100 Mb/s operations over a single 
balanced twisted-pair channel. Figure 96–2 shows the relationship of the service primitives and interfaces 
used by the 100BASE-T1 PHY.
Differences from the 40.2 service interface are as follows:
a)
The 100BASE-T1 PHY uses the Media Independent Interface (MII) as specified in Clause 22.
b)
The 100BASE-T1 PHY does not use 40.2 support of LPI (Low Power Idle) related functions.
c)
The 100BASE-T1 PHY MASTER-SLAVE relationship is established by management (see 96.4.4).
NOTE—Annex K defines optional alternative terminology for “master” and “slave”.
96.2.1 PMA service interface
As shown in Figure 96–2, 100BASE-T1 uses the following service primitives to exchange symbol vectors, 
status indications, and control signals across the PMA service interface:
PMA_LINK.indications (link_status)
PMA_TXMODE.indication (tx_mode)
PMA_UNITDATA.request (tx_symb_vector)
PMA_UNITDATA.indication (rx_symb_vector)
PMA_SCRSTATUS.request (scr_status)
PMA_RXSTATUS.indication (loc_rcvr_status)
PMA_REMRXSTATUS.request (rem_rcvr_status)
PMA_TXEN.request (TX_EN)


PMA
link_status
Figure 96–3—Functional block diagram
PCS
RECEIVE
RX_CLK
RXD<3:0>
RX_DV
RX_ER
PMA_UNITDATA.request
PMA
RECEIVE
tx_error_mii
TX_EN
TX_ER
TX_CLK
BI_DA +
BI_DA -
loc_rcvr_status
PHY
CONTROL
recovered_clock
tx_mode
config
rem_rcvr_status
PMA_UNITDATA.indication
receiving
received_clock
TXD<3:0>
TRANSMIT
PCS
LINK
MONITOR
scr_status
link_control
link_status
tx_enable_mii
(rx_symb_vector)
(tx_symb_vector)
CLOCK
RECOVERY
PMA
TRANSMIT
INDEPENDENT
INTERFACE
(MII)
MEDIA
PMA SERVICE
INTERFACE
MEDIUM
INTERFACE
DEPENDENT
(MDI)
PCS
PHY
(INCLUDES PCS AND PMA)
NOTE—The recovered_clock arc is shown to indicate delivery of the received clock signal back to the PMA TRANSMIT for loop timing
MANAGEMENT
MDC
MDIO
PCS
DATA
TRANSMISSION
ENABLE
config


96.2.2 PMA_LINK.indication
This primitive is generated by the PMA to indicate the status of the underlying medium as specified in 
96.4.5. This primitive informs the PCS about the status of the underlying link.
96.2.2.1 Semantics of the primitive
PMA_LINK.indication (link_status)
The link_status parameter can take on one of the following two values: FAIL or OK
FAIL
No valid link established
OK
The Link Monitor function indicates that a valid 100BASE-T1 link is estab-
lished. Reliable reception of signals transmitted from the remote PHY is possible.
96.2.2.2 When generated
The PMA generates this primitive continuously to indicate the value of the link_status in compliance with 
the state diagram given in 96.4.5.
96.2.2.3 Effect of receipt
The effect of receipt of this primitive is specified in 96.4.5.
96.2.3 PMA_TXMODE.indication
The 100BASE-T1 transmitter sends code-groups that represent an MII data stream, control information, 
idles, or zeros.
96.2.3.1 Semantics of the primitive
PMA_TXMODE.indication (tx_mode)
PMA_TXMODE.indication specifies to PCS Transmit via the parameter tx_mode what sequence of code-
groups the PCS should be transmitting. The parameter tx_mode can take on one of the following three 
values:
SEND_N
This value is continuously asserted when transmission of sequences of code-
groups representing a MII data stream (data mode), control mode or idle mode is 
to take place.
SEND_I
This value is continuously asserted in case transmission of sequences of code-
groups representing the idle mode is to take place.
SEND_Z
This value is continuously asserted in case transmission of zeros is required.
96.2.3.2 When generated
The PMA PHY Control function generates PMA_TXMODE.indication messages continuously.
96.2.3.3 Effect of receipt
Upon receipt of this primitive, the PCS performs its Transmit function as described in 96.3.3.


96.2.4 PMA_UNITDATA.request
This primitive defines the transfer of code-groups in the form of the tx_symb_vector parameter from the 
PCS to the PMA. The code-groups are obtained in the PCS Transmit function using the encoding rules 
defined in 96.3.3 to represent MII data streams, an idle mode, or other sequences.
96.2.4.1 Semantics of the primitive
PMA_UNITDATA.request (tx_symb_vector)
During transmission, the PMA_UNITDATA.request simultaneously conveys to the PMA via the parameter 
tx_symb_vector the value of the symbols to be sent over the transmit pair BI_DA. The tx_symb_vector 
parameter takes on the following form:
SYMB_1D: 
A vector of one ternary symbol for a single transmit pair BI_DA. Each ternary 
symbol may take on one of the values {–1, 0, or +1}.
The ternary symbols that are elements of tx_symb_vector are called tx_symb_vector[BI_DA].
96.2.4.2 When generated
The PCS continuously generates PMA_UNITDATA.request (SYMB_1D) synchronously with every 
TX_TCLK cycle. 
96.2.4.3 Effect of receipt
Upon receipt of this primitive the PMA transmits on the MDI the signals corresponding to the indicated ter-
nary symbols. The parameter tx_symb_vector is also used by the PMA Receive function to process the sig-
nals received on pair BI_DA.
96.2.5 PMA_UNITDATA.indication
This primitive defines the transfer of code-groups in the form of the rx_symb_vector parameter from the 
PMA to the PCS.
96.2.5.1 Semantics of the primitive
PMA_UNITDATA.indication (rx_symb_vector)
During reception, the PMA_UNITDATA.indication simultaneously conveys to the PCS via the parameter 
rx_symb_vector the values of the symbols detected on the receive pair BI_DA. The rx_symb_vector param-
eter takes on the following form:
SYMB_1D
A vector of ternary symbols for the receive pair BI_DA. Each ternary symbol 
may take on one of the values {–1, 0, or +1}.
The ternary symbols that are elements of rx_symb_vector are called rx_symb_vector[BI_DA]. 
96.2.5.2 When generated
The PMA generates PMA_UNITDATA.indication (SYMB_1D) messages synchronously with signals 
received at the MDI. The nominal rate of the PMA_UNITDATA.indication primitive is 66.666 MHz, as 
governed by the recovered clock.


96.2.5.3 Effect of receipt
The effect of receipt of this primitive is unspecified.
96.2.6 PMA_SCRSTATUS.request
This primitive is generated by PCS Receive to communicate the status of the descrambler for the local PHY. 
The parameter scr_status conveys to the PMA Receive function the information that the descrambler has 
achieved synchronization.
96.2.6.1 Semantics of the primitive
PMA_SCRSTATUS.request (scr_status)
The scr_status parameter can take on one of the following two values:
OK
The descrambler has achieved synchronization.
NOT_OK
The descrambler is not synchronized.
96.2.6.2 When generated
PCS Receive generates PMA_SCRSTATUS.request messages continuously.
96.2.6.3 Effect of receipt
The effect of receipt of this primitive is specified in 96.4.3 and 96.4.4.
96.2.7 PMA_RXSTATUS.indication
This primitive is generated by PMA Receive to indicate the status of the receive link at the local PHY. The 
parameter loc_rcvr_status conveys to the PCS Transmit, PCS Receive, PMA PHY Control function, and 
Link Monitor the information on whether the status of the overall receive link is satisfactory or not. Note 
that loc_rcvr_status is used by the PCS Receive decoding functions. The criterion for setting the parameter 
loc_rcvr_status is left to the implementor. It can be based, for example, on observing the mean-square error 
at the decision point of the receiver and detecting errors during reception of symbol streams that represent 
the idle mode.
96.2.7.1 Semantics of the primitive
PMA_RXSTATUS.indication (loc_rcvr_status)
The loc_rcvr_status parameter can take on one of the following two values:
OK
This value is asserted and remains true during reliable operation of the receive 
link for the local PHY.
NOT_OK
This value is asserted whenever operation of the link for the local PHY is unreli-
able.
96.2.7.2 When generated
PMA Receive generates PMA_RXSTATUS.indication messages continuously on the basis of signals 
received at the MDI. 
96.2.7.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 96–18, 96.4.4, and 96.4.5.


96.2.8 PMA_REMRXSTATUS.request
This primitive is generated by PCS Receive to indicate the status of the receive link at the remote PHY as 
communicated by the remote PHY via its encoding of its loc_rcvr_status parameter. The parameter 
rem_rcvr_status conveys to the PMA PHY Control function the information on whether reliable operation of 
the remote PHY is detected or not. The criterion for setting the parameter rem_rcvr_status is left to the 
implementor. It can be based, for example, on asserting rem_rcvr_status is NOT_OK until loc_rcvr_status is 
OK and then asserting the detected value of rem_rcvr_status after proper PCS receive decoding is achieved.
96.2.8.1 Semantics of the primitive
PMA_REMRXSTATUS.request (rem_rcvr_status)
The rem_rcvr_status parameter can take on one of the following two values:
OK
The receive link for the remote PHY is operating reliably.
NOT_OK
Reliable operation of the receive link for the remote PHY is not detected.
96.2.8.2 When generated
The PCS generates PMA_REMRXSTATUS.request messages continuously on the basis of signals received 
at the MDI.
96.2.8.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 96–18.
96.2.9 PMA_RESET.indication
This primitive is used to pass the PMA Reset function to the PCS (pcs_reset=ON) when reset is enabled.
The PMA_RESET.indication primitive can take on one of the following two values:
TRUE
Reset is enabled.
FALSE
Reset is not enabled.
96.2.9.1 When generated
This primitive is generated under the conditions described in 40.4.2.1.
96.2.9.2 Effect of receipt
The effect of receipt of this primitive is specified in 40.4.2.1.
96.2.10 PMA_TXEN.request
This primitive indicates the presence of data on MII for transmission.
96.2.10.1 Semantic of the primitive
PMA_TXEN.request
The TX_EN parameter can take on one of the following two values:
TRUE
The data transmission on MII is enabled.
FALSE
The data transmission on MII is not enabled.


96.2.10.2 When generated
PCS generates the PMA_TXEN.request messages continuously based on TX_EN signal received from MII.
96.2.10.3 Effect of receipt
The effect of receipt of this primitive is specified in Figure 96–18.
96.3 100BASE-T1 Physical Coding Sublayer (PCS) functions
The Physical Coding Sublayer (PCS) consists of PCS Reset, the PCS Data Transmission Enable, PCS Trans-
mit, and PCS Receive functions as shown in Figure 96–4. The PCS Transmit function is explained in 96.3.3, 
and the PCS Receive function is explained in 96.3.4.


96.3.1 PCS Reset function
PCS Reset initializes all PCS functions. The PCS Reset function shall be executed whenever one of the 
following conditions occur:
a)
Power on (see 36.2.5.1.3).
b)
The receipt of a request for reset from the management entity. 
 
Figure 96–4—PCS reference diagram
PCS
MEDIA
INDEPENDENT
INTERFACE
PMA SERVICE
INTERFACE
link_status
PCS
RECEIVE
RX_CLK
RXD<3:0>
RX_DV
RX_ER
PCS DATA
ENABLE
tx_error_mii
TX_EN
TX_ER
TX_CLK
loc_rcvr_status
tx_mode
config
rem_rcvr_status
PMA_UNITDATA.indication
receiving
TRANSMISSION
TXD<3:0>
TRANSMIT
PCS
scr_status
tx_enable_mii
(rx_symb_vector)
PMA_UNITDATA.request
(tx_symb_vector)
MANAGEMENT
MDC
MDIO
 


PCS Reset sets pcs_reset=ON while any of the above reset conditions hold true. All state diagrams take the 
open-ended pcs_reset branch upon execution of PCS Reset. The reference diagrams do not explicitly show 
the PCS Reset function.
96.3.2 PCS data transmission enabling
The PCS data transmission enabling function shall conform to the PCS data transmission enabling state 
diagram in Figure 96–5.  When tx_mode is equal to SEND_N, the signals tx_enable_mii and tx_error_mii 
are equal to the value of the MII signals TX_EN and TX_ER respectively, otherwise tx_enable_mii and 
tx_error_mii are set to the value FALSE.
 
96.3.2.1 Variables
link_status
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive.
Values: OK or FAIL
pcs_reset
The pcs_reset parameter set by the PCS Reset function.
Values: ON or OFF
tx_enable_mii
The tx_enable_mii variable is generated in the PCS data transmission enabling state diagram as 
specified in Figure 96–5. When set to FALSE transmission is disabled, when set to TRUE 
transmission is enabled.
Values: TRUE or FALSE
Figure 96–5—PCS data transmission enabling state diagram
pcs_reset = ON +
link_status = FAIL
tx_mode = SEND_N 
TX_EN = FALSE 
TX_ER = FALSE
DISABLE DATA TRANSMISSION
tx_enable_mii  FALSE
tx_error_mii  FALSE
ENABLE DATA TRANSMISSION
tx_enable_mii  TX_EN
tx_error_mii  TX_ER
tx_mode  SEND_N
tx_mode = SEND_N


tx_error_mii
The tx_error_mii variable is generated in the PCS data transmission enabling state diagram as spec-
ified in Figure 96–5.When this variable is set to FALSE it indicates a non-errored transmission, 
when set to TRUE it indicates an errored transmission.
Values: TRUE or FALSE
TX_EN
The TX_EN signal of the MII as specified in 22.2.2.3.
TX_ER
The TX_ER signal of the MII as specified in 22.2.2.5.
tx_mode
The tx_mode parameter set by the PMA PHY Control function and passed to the PCS via the 
PMA_TXMODE.indication primitive. 
Values: SEND_Z, SEND_N, or SEND_I
96.3.3 PCS Transmit
96.3.3.1 4B/3B conversion
The PCS performs a 4B/3B conversion of the nibbles received at the MII, creates the ternary symbols, and 
then sends the symbols to the PMA for further processing. It receives 4 bits at the MII using TX_CLK, and 
converts the stream of 4-bit words at 25 MBd to a stream of 3-bit words at 33.333 MBd. The bits are then 
scrambled and converted through PCS encoding to a stream of code-groups (pairs of ternary symbols). 
These ternary symbol pairs are then multiplexed to a serialized stream of ternary symbols at 66.666 MBd
96.3.3.1.1 Control signals in 4B/3B conversion
Signals tx_enable_mii, tx_error_mii and TXD<3:0>, synchronized to MII TX_CLK are the input of 4B/3B 
conversion. After 4B/3B conversion, the transmit signals tx_data<2:0>, tx_enable and tx_error shall be syn-
chronized with PCS transmit clock pcs_txclk. The frequencies of MII TX_CLK and pcs_txclk are 25 MHz 
and 33.333 MHz respectively to keep the same bitwise throughput with 4B/3B conversion. TX_TCLK shall 
be derived from a local source in MASTER mode. TX_TCLK shall be derived from the recovered clock in 
SLAVE mode. The pcs_txclk is derived from the same clock source as TX_TCLK, with the proper clock 
division factor to get to the required frequency.
96.3.3.1.2 4B/3B conversion for MII data
The transmit data (TXD<3:0>) at the MII shall first be converted into 3 bits as a group (tx_data<2:0>). As 
shown in Figure 96–6b and Figure 96–6c, when the number of bits of a packet is not a multiple of three, the 
4B/3B conversion shall append stuff bits to the end of a packet (1 or 2 bits), and correspondingly, the tx_en-
able signal remains TRUE until all the bits in a packet (appended with stuff bits if applicable) are rate con-
verted. Note, a packet includes preamble, SFD, and a MAC Frame as specified in 1.4.447. Those stuff bits 
may be padded randomly, which is left to implementer, and will be discarded at the receiver upon the bound-
ary of the last nibble at the MII RX domain. The minimum 12 byte IPG period between packets enables 
flushing the extra stuff bits to prevent FIFO overflow.


TX_CLK
tx_enable_mii
d0<3:0> d1<3:0>
d2<3:0>
d3<3:0>
d4<3:0>
d5<3:0>
TXD<3:0>
tx_error_mii
tx_enable
d0<2:0> d1<1:0>,
d0<3>
d2<0>,
d1<3:2>
d2<3:1>
d3<2:0> d4<1:0>,
d3<3>
d5<0>,
d4<3:2>
d5<3:1>
pcs_txclk
tx_data<2:0>
tx_error
4B/3B
Figure 96–6a—4B/3B MII signal conversion (3n-bit data, no stuff bit appended)
TX_CLK
tx_enable_mii
d0<3:0> d1<3:0>
d2<3:0>
d3<3:0>
TXD<3:0>
tx_error_mii
tx_enable
d0<2:0> d1<1:0>,
d0<3>
d2<0>,
d1<3:2>
d2<3:1>
d3<2:0>
<xx>,
d3<3>
pcs_txclk
tx_data<2:0>
tx_error
4B/3B
Figure 96–6b—4B/3B MII signal conversion ((3n+1)-bit data, 2 stuff bits appended)


96.3.3.2 PCS Transmit state diagram
The PCS Transmit function shall conform to the PCS Transmit state diagram in Figure 96–7, and the 
associated state variables, functions, timers and messages.
In each symbol period, PCS Transmit generates a sequence of symbols An to the PMA, operating in one of 
three different modes (tx_mode), where symbol An is a ternary code that can take values of {–1, 0, or +1}. 
The PMA transmits symbol An over the wire pair BI_DA. The integer, n, is a time index, introduced to 
establish a temporal relationship between different symbol periods. A symbol period, T, is nominally equal 
to 15 ns. In the normal mode of operation, the PCS Transmit generates sequences of vectors using the 
encoding rules defined for SEND_N in 96.3.3.3.7 and 96.3.3.3.8, according to the value of tx_enable. Upon 
the assertion of tx_enable, the PCS Transmit function passes an SSD of 6 consecutive symbols to the PMA, 
which replaces the first 9 bits of preamble. Following SSD, tx_data<2:0> is encoded into ternary symbols as 
specified in 96.3.3.3, until tx_enable is de-asserted. Following the de-assertion of tx_enable, a special code 
ESD (or ERR_ESD when transmit error is encountered) of 6 consecutive symbols is generated, after which 
the transmission of idle mode is resumed. As shown in Figure 96–6a and Figure 96–6b, if tx_error_mii is 
ever asserted (due to MII TX_ER assertion) during the data frame period, tx_error is set as TRUE and stays 
TRUE till the end of frame to record such an occurrence. 100BASE-T1 only has one special symbol pair (0, 
0) that is not used by Idle or Data symbols. Therefore, at the end of a frame, tx_error is examined to 
determine whether ESD3 or ERR_ESD3 are to be transmitted following ESD1 and ESD2, as shown in 
Figure 96–7.
The 100BASE-T1 PHY supports normal operation and link training operation. In training operation, the 
PCS ignores signals from MII and sends only the idle signals to the PMA until training process is complete 
(signaled by the link partner). The training process usually includes descrambler lock, timing acquisition, 
echo cancellation and equalizer convergence, etc.
If tx_mode has the value SEND_Z, PCS Transmit passes a vector of zeros at each symbol period to the 
PMA.
If tx_mode has the value SEND_I, PCS Transmit generates sequences of symbols according to the encoding 
rule in training mode as described in 96.3.3.3.6.
TX_CLK
tx_enable_mii
d0<3:0> d1<3:0>
d2<3:0>
d3<3:0>
d4<3:0>
d5<3:0>
d6<3:0>
d7<3:0>
TXD<3:0>
tx_error_mii
tx_enable
d0<2:0> d1<1:0>,
d0<3>
d2<0>,
d1<3:2>
d2<3:1>
d3<2:0> d4<1:0>,
d3<3>
d5<0>,
d4<3:2>
d5<3:1>
d6<2:0> d7<1:0>,
d6<3>
<x>,
d7<3:2>
pcs_txclk
tx_data<2:0>
tx_error
4B/3B
Figure 96–6c—4B/3B MII signal conversion ((3n+2)-bit data, 1 stuff bit appended)


If tx_mode has the value SEND_N, PCS Transmit generates symbols An at each symbol period representing 
data, special control symbols like SSD/ESD or IDLE symbols as defined in 96.3.3.3.5. The transition from 
idle to data is signaled by an SSD, and the end of transmission of data is signaled by an ESD.
During training operation (when tx_mode is SEND_I), knowledge of the transmitted symbols may be used 
at receiver side to perform any signal conditioning neccesary for meeting the required performance during 
normal operation. When the link is up, the PHY enters SEND_N mode and the transmitted PAM3 symbols 
are used at receiver PHY for continued clock frequency/phase tracking.
96.3.3.2.1 Variables
DATA
A vector of two ternary symbols corresponding to the code-group indicating valid data, as specified 
in 96.3.
ERR_ESD3
A vector of two ternary symbols in the third code-group of ESD in case of tx_error (–1, –1) as 
specified in 96.3.3.3.5.
ESD1
A vector of two ternary symbols in the first code-group of ESD (0, 0) as specified in 96.3.3.3.5.
ESD2
A vector of two ternary symbols in the second code-group of ESD (0, 0) as specified in 96.3.3.3.5.
ESD3
A vector of two ternary symbols in the third code-group of ESD (1, 1) as specified in 96.3.3.3.5.
IDLE
A sequence of vectors of ternary symbols representing the special code-group generated in Idle 
mode, as specified in 96.3.3.3.6 and 96.3.3.3.8.
link_status
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive.
Values: OK or FAIL
loc_rcvr_status
The loc_rcvr_status parameter set by the PMA Receive function and passed to the PCS via the 
PMA_RXSTATUS.indication primitive.
Values: OK or NOT_OK
pcs_reset
The pcs_reset parameter set by the PCS Reset function.
Values: ON or OFF
SSD1
A vector of two ternary symbols in the first code-group of SSD (0, 0) as specified in 96.3.3.3.5.
SSD2
A vector of two ternary symbols in the second code-group of SSD (0, 0) as specified in 96.3.3.3.5.
SSD3
A vector of two ternary symbols in the third code-group of SSD (0, 0) as specified in 96.3.3.3.5.


TXD<3:0>
The TXD<3:0> signal of the MII as specified in 22.2.2.4.
tx_enable
The tx_enable parameter generated by PCS Transmit as specified in Figure 96–7.
Values: TRUE or FALSE
tx_data<2:0>
Generated by PCS Transmit, transmit data is synchronous to pcs_txclk (33.333 MHz clock). 
tx_error
The tx_error parameter generated by PCS Transmit as specified in Figure 96–7.
Values: TRUE or FALSE
TX_EN
The TX_EN signal of the MII as specified in 22.2.2.3.
TX_ER
The TX_ER signal of the MII as specified in 22.2.2.5.
tx_mode
The tx_mode parameter set by the PMA PHY Control function and passed to the PCS via the 
PMA_TXMODE.indication primitive.
Values: SEND_Z, SEND_N, or SEND_I
Txn
Alias for tx_symb_vector at time n.
tx_symb_pair
A pair of ternary symbols generated by the PCS Transmit function after ternary pair encoding.
Value:
A pair of ternary transmit symbols. Each of the ternary symbols may take on one of the 
values {–1, 0, or +1}
96.3.3.2.2 Functions
ENCODE
In the PCS Transmit process, this function takes as its argument tx_data<2:0> 
and returns the corresponding tx_symb_pair. ENCODE follows the rules defined 
in 96.3.3.3.
96.3.3.2.3 Timers
symb_timer
The symb_timer shall be generated synchronously with TX_TCLK. In the PCS 
Transmit state diagram, the message PMA_UNITDATA.request is issued con-
currently with symb_timer_done.
Continuous timer:
The condition symb_timer_done becomes true upon 
timer expiration.
Restart time:
Immediately after expiration; timer restart resets the
condition symb_timer_done.
Duration: 
15 ns nominal. (See clock tolerance in 96.5.4.5.)
symb_pair_timer
The symb_pair_timer shall be generated synchronously with PCS transmit clock 
pcs_txclk.
Continuous timer:
The condition symb_pair_timer_done becomes true
upon timer expiration.


Figure 96–7—PCS Transmit state diagram
pcs_reset = ON
STD 
tx_enable = TRUE
SEND IDLE
tx_symb_pair  IDLE
STD 
SSD1 VECTOR
tx_symb_pair  SSD1
STD 
SSD2 VECTOR
tx_symb_pair  SSD2
SSD3 VECTOR
tx_symb_pair  SSD3
TRANSMIT DATA
tx_symb_pair  ENCODE(tx_data<2:0>)
ESD1 VECTOR
tx_symb_pair  ESD1
ERR ESD1 VECTOR
tx_symb_pair  ESD1
STD 
STD 
ERR ESD2 VECTOR
tx_symb_pair  ESD2
STD 
ESD2 VECTOR
tx_symb_pair  ESD2
STD 
ERR ESD3 VECTOR
tx_symb_pair  ERR_ESD3
ESD3 VECTOR
tx_symb_pair  ESD3
STD 
STD 
ELSE 
STD 
 tx_enable = FALSE
tx_error = TRUE
STD tx_enable = TRUE
STD 
tx_enable = FALSE 
tx_error = FALSE
STD 
tx_enable = TRUE
STD 
tx_enable = FALSE 
tx_error = FALSE
STD 
 tx_enable = FALSE 
tx_error = TRUE


Restart time: 
Immediately after expiration; timer restart resets the
condition symb_pair_timer_done.
Duration: 
30 ns nominal.
96.3.3.2.4 Messages
STD
Alias for symb_pair_timer_done.
96.3.3.3 PCS transmit symbol generation
The reference diagram of PCS transmit symbol generation is indicated in Figure 96–8. The tx_symb_pair is 
the ternary pair (TAn, TBn).
96.3.3.3.1 Side-stream scrambler polynomial
The scrambler function shall conform to 40.3.1.3.1 and associated Figure 40–6 without any exceptions.
96.3.3.3.2 Generation of Syn[2:0]
Generation of Syn[2:0] and Scn[2:0] shall conform to and be generated in accordance with the encoding 
rules in 40.3.1.3.2 and 40.3.1.3.3. Syn[2:0] vector in this specification is three bits, while the 40.3.1.3.2 
vector is four bits.The PCS Transmit encoding of Syn[2:0] and then Scn[2:0] are performed, at time n, and 
used to eliminate the correlation of transmit data tx_data<2:0> and to generate idle and training symbols. 
Syn[3] is not used by definition.
96.3.3.3.3 Generation of Scn[2:0]
Bits Scn[2:0] shall be generated as follows:
4B/3B
CONVERSION
4B/3B DATA
CONVERSION
SYMBOL
MAPPING
DATA
SCRAMBLER
SIDE STREAM
SCRAMBLER
2D 
to
1D
TXD<3:0>
tx_enable_mii
tx_enable
tx_error
tx_error_mii
 tx_data<2:0>
 Sdn[2:0]
 Scn[2:0]
PMA_UNITDATA.request
(tx_symb_vector)
PCS
Figure 96–8—PCS transmit symbol generation 
TAn
TBn
tx_mode
loc_rcvr_status
Scn 2 :0


0  0  0

                if  ( tx_mode = SEND_Z )
Syn 2 :0

                                                else



=


96.3.3.3.4 Generation of scrambled bits Sdn[2:0]
The tx_datan<2:0> is a three bit vector after 4B/3B conversion.
From scrambler bits Scn[2:0] and tx_datan<2:0>, bits Sdn[2:0] shall be generated as follows:
where ^ denotes the XOR logic operator.
96.3.3.3.5 Generation of ternary pair (TAn, TBn)
The bits Sdn[2:0] are used to generate ternary pair (TAn, TBn). The ternary symbol pair (0, 0) is used in the 
special codes of SSD, ESD, and ESD with tx_error. Sequences of (0, 0), (0, 0), (0, 0) represent SSD, (0, 0), 
(0, 0), (1, 1) represent ESD and (0, 0), (0, 0), (–1, –1) represent ESD with tx_error.
96.3.3.3.6 Generation of (TAn, TBn) when tx_mode = SEND_I
Among the nine possible values for the ternary pair (TAn, TBn) only six values are used in the training 
sequence as indicated in Table 96–1. The ternary pairs used to encode SSD and ESD are not used during 
training.
96.3.3.3.7 Generation of (TAn, TBn) when tx_mode = SEND_N, tx_enable = 1
The mapping from Sdn[2:0] to ternary pairs in data mode is indicated in Table 96–2.
Table 96–1—Idle symbol mapping in training 
Sdn[2:0]
TAn
TBn
–1
–1
–1
–1
–1
Sdn 2

Scn 2

tx_datan< 2 >                    if  ( tx_enablen
–  = 1)

Scn 2

1                             else if  ( loc_rcvr_status = OK)

Scn 2

                                                         else





=
Sdn 1 :0


Scn 1:0


tx_datan< 1:0 >
                     if ( tx_enablen
–  = 1)

Scn 1:0


                                                         else



=


96.3.3.3.8 Generation of (TAn, TBn) for idle sequence when tx_mode=SEND_N
The extra scrambling bit Sxn is introduced to balance the power density for ternary pair (TAn, TBn). Sxn shall 
be generated as follows:
where ^ denotes the XOR logic operator. The ternary pair (TAn, TBn) is generated according to Table 96–3.
Table 96–2—Data symbols when tx_mode=SEND_N 
Sdn[2:0]
TAn
TBn
–1
–1
–1
–1
–1
Used for SSD/ESD
–1
Table 96–3—Idle symbols when tx_mode=SEND_N 
tx_mode = SEND_N
Sxn = 0
Sxn = 1
Sdn[2:0]
TAn
TBn
TAn
TBn
–1
–1
–1
–1
–1
–1
–1
–1
–1
–1
–1
–1
Sxn
Scrn 7

Scrn 9

Scrn 12


Scrn 14





=


96.3.3.3.9 Generation of (TAn, TBn) when tx_mode=SEND_Z
The ternary pair (TAn, TBn) simply shows as zero vector (0, 0) when tx_mode=SEND_Z.
96.3.3.3.10 Generation of symbol sequence
The generation of one-dimensional symbol sequence from ternary pair (TAn, TBn) is illustrated in 
Figure 96–9.
The symbol is sent to one sequence in the form of interleave in the order from right to left. AB_SEL sig-
nal defines the interleave selection for code-groups. The serial stream is created by interleaving either 
(TAn, TBn) with TAn followed by TBn  or  (TBn, TAn) with TBn followed by TAn. The ESD (after a 
packet) is followed by IDLE symbols, then SSD, and then by DATA. The symbol rate is twice as fast as 
pcs_txclk.
96.3.4 PCS Receive
96.3.4.1 PCS Receive overview
The PCS Receive function shall conform to the PCS Receive state diagram in Figure 96–10a and 
Figure 96–10b, and associated state variables. 
... TA2 TA1
... TB2 TB1
... TB2 TA2 TB1 TA1
DDDDDD
DDDDDD
|||||| ... ||||||
DDD
DDD
||| ... |||
||| ... |||
MUX
AB_SEL
Figure 96–9—2-D symbol to 1-D symbol conversion
DDD
DDD


A
Figure 96–10a—PCS Receive state diagram
RSPCD
 IDLE
pcs_rx_er FALSE
pcs_rx_dv FALSE
rx_data<2:0> ”000"
receiving FALSE
mii_fc_err FALSE
 LINK FAILED
pcs_rx_er TRUE
pcs_rx_dv TRUE
receiving FALSE
((loc_rcvr_status = NOT_OK receiving = TRUE)
+ (link_status = FAIL receiving = TRUE))
RSPCD
(pcs_reset = ON
+ (loc_rcvr_status = NOT_OK  receiving = FALSE)
+ (link_status = FAIL  receiving = FALSE)
+ rcv_jab_detected = TRUE)
RSPCD 
Rxn  SSD1 
Rxn  IDLE
SSD
pcs_rx_er FALSE
pcs_rx_dv FALSE
rx_data<2:0> ”000"
receiving TRUE
FIRST SSD
pcs_rx_er FALSE
pcs_rx_dv TRUE
rx_data<2:0> ”101"
receiving TRUE
RSPCD
DATA
pcs_rx_er  FALSE
pcs_rx_dv TRUE
rx_data<2:0>  DECODE(Rxn-4)
receivingTRUE
RSPCD 
Rxn = ESD1
RSPCD 
Rxn  ESD1
RSPCD
THIRD SSD
pcs_rx_er FALSE
pcs_rx_dv TRUE
rx_data<2:0> ”101"
receiving TRUE
RSPCD 
Rxn = ESD1
RSPCD 
Rxn  ESD1
SECOND SSD
pcs_rx_er FALSE
pcs_rx_dv TRUE
rx_data<2:0> ”010"
receiving TRUE
RSPCD
CHECK SSD3
pcs_rx_er FALSE
pcs_rx_dv FALSE
rx_data<2:0> ”000"
receiving TRUE
RSPCD 
Rxn = SSD3
RSPCD 
Rxn  SSD3
CHECK SSD2
pcs_rx_er FALSE
pcs_rx_dv FALSE
rx_data<2:0> ”000"
receiving TRUE
RSPCD 
Rxn = SSD2
RSPCD 
Rxn  SSD2
BAD SSD
pcs_rx_er TRUE
pcs_rx_dv FALSE
rx_data<2:0> “000”
receiving TRUE
mii_fc_errTRUE
check_idle=TRUE
ELSE
RSPCD 
Rxn = SSD1
B


 
A JAB state machine as shown in Figure 96–11, is implemented to prevent any mis-detection of ESD1 and 
ESD2 that would make the PCS Receive state machine lock up in the DATA state. The maximum dwelling 
time in DATA state shall be less than the period specified for rcv_max_timer. When rcv_max_timer expires, 
the PCS Receive state machine is reset and transition to IDLE state is forced.
Figure 96–10b—PCS Receive state diagram (continued)
CHECK ESD2
pcs_rx_er FALSE
pcs_rx_dv TRUE
rx_data<2:0> DECODE(Rxn-4)
receiving TRUE
RSPCD 
Rxn  ESD2
A
RSPCD 
Rxn ESD2
BAD ESD2
pcs_rx_er TRUE
pcs_rx_dv TRUE
rx_data<2:0> DECODE(Rxn-4)
receiving TRUE
RSPCD
CHECK ESD3
pcs_rx_er FALSE
pcs_rx_dv TRUE
rx_data<2:0> DECODE(Rxn-4)
receiving TRUE
RSPCD 
Rxn  ESD3 
 Rxn  ERR_ESD3
RSPCD 
Rxn = ESD3
BAD END
pcs_rx_er TRUE
pcs_rx_dv TRUE
rx_data<2:0> DECODE(Rxn-4)
receiving TRUE
RX ERROR
pcs_rx_er TRUE
pcs_rx_dv TRUE
rx_data<2:0> DECODE(Rxn-4)
receiving TRUE
ESD
pcs_rx_er FALSE
pcs_rx_dv TRUE
rx_data<2:0> DECODE(Rxn-4)
receiving TRUE
RSPCD
RSPCD 
Rxn = ERR_ESD3
RSPCD
RSPCD
B


In Figure 96–10a, there are a total of four states after SSD3 detection before the DATA state; meanwhile, 
there are also four states before the IDLE state (including the DATA state) that perform DATA decoding. 
As a result, the depth of data flush-in delay line is the same as the flush-out delay line ensuring correct 
packet reception at the MII.
The variables, functions, and timers used in Figure 96–10a, Figure 96–10b, and Figure 96–11 are defined as 
below. For the definition of IDLE, SSD1, SSD2, SSD3, ESD1, ESD2, ESD3 and ERR_ESD3, see 
96.3.3.2.1.
96.3.4.1.1 Variables
link_status
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive.
Values: OK or FAIL
loc_rcvr_status
The loc_rcvr_status parameter set by the PMA Receive function and passed to the PCS via the 
PMA_RXSTATUS.indication primitive.
Values: OK or NOT_OK
mii_fc_err
Indicates that a false carrier error has occurred.
Values: TRUE or FALSE
pcs_reset
The pcs_reset parameter set by the PCS Reset function.
Values: ON or OFF
Figure 96–11—JAB state diagram
JABIDLE
rcv_jab_detected  FALSE
JAB
rcv_jab_detected TRUE
receiving = FALSE +
link_status = FAIL
MONJAB
start rcv_max_timer
receiving = TRUE  
rcv_max_timer_done = TRUE
receiving = FALSE
receiving = TRUE 
link_status = OK
pcs_reset = ON


pcs_rx_er
PCS receive error indication signal synchronous to pcs_rxclk.
Values: TRUE or FALSE
pcs_rx_dv
PCS receive data link indication signal synchronous to pcs_rxclk.
Values: TRUE or FALSE
receiving
Generated by the PCS Receive function; if set as TRUE, it indicates that the PCS is in Data mode.
Values: TRUE or FALSE
rcv_jab_detected
Variable set as TRUE when in JAB state as shown in JAB state diagram in Figure 96–11 else
it is set FALSE.
Values: TRUE or FALSE
Rxn
Received symbol pair generated by PCS Receive at time n.
rx_data<2:0>
PCS decoded data synchronous to pcs_rxclk.
rx_symb_pair
A pair of ternary symbols generated by the PCS Receive function before ternary pair decoding.
Value:
A pair of ternary receive symbols. Each of the ternary symbols may take
on one of the values {–1, 0, or +1}.
rx_symb_vector
A vector of ternary symbols received by the PMA and passed to the PCS via the PMA_UNIT-
DATA.indication primitive.
Value: SYMB_1D
96.3.4.1.2 Functions
check_idle
A function used by the PCS Receive process to detect the reception of valid idle 
code-groups after an error condition during the process. The check_idle function 
operates on six consecutive code-groups after de-interleaving rx_symb_vectors. 
The check_idle function then returns a Boolean value indicating whether or not 
all six consecutive code-groups after de-interleaving rx_symb_vectors are valid 
in idle mode encoding, as specified in 96.3.3.3.5.
DECODE
In the PCS Receive process, this function takes as its argument the value of 
rx_symb_pair and returns the corresponding rx_data<2:0>. DECODE follows 
the rules outlined in 96.3.4.2.
96.3.4.1.3 Timer
RSPCD
Receive Symbol Pair Converted Done, synchronized with PCS receive clock 
pcs_rxclk of frequency 33.333 MHz.
rcv_max_timer
A timer used to determine the maximum amount of time the PHY Receive state 
machine stays in DATA state. The timer shall expire 1.08 ms ± 54 s after being 
started. The condition rcv_max_timer_done becomes true upon timer expiration.


96.3.4.2 PCS Receive symbol decoding
When PMA Receive indicates normal operation and sets loc_rcvr_status = OK, the PCS Receive function 
checks the symbol sequences and searches for SSD or receive error indicator. The receiver de-interleaves the 
sequences of rx_symb_vector to rx_symb_pair accordingly.
The received symbols, rx_symb_vector, are de-interleaved to generate rx_symb_pair (RAn, RBn). To achieve 
correct operation, PCS Receive uses the knowledge of the encoding rules that are employed in the idle 
mode. PCS Receive generates the sequence of symbols and indicates the reliable acquisition of the descram-
bler state by setting the parameter scr_status to OK. The received ternary pairs (RAn, RBn) are decoded to 
generate signals rx_data<2:0>, pcs_rx_dv, and pcs_rx_error. These signals are processed through 3B/4B 
conversion to generate signals RXD<3:0>, RX_DV and RX_ER at the MII. 
PCS Receive sets pcs_rx_dv=TRUE when it receives SSD, and sets pcs_rx_dv=FALSE when it receives 
ESD or ESD with error. The number of bits received in a packet is always a multiple of 3 that shall go 
through the process of 3B/4B conversion, discarding the residual 1 bit or 2 bits of data. 
PCS Receive shall set pcs_rx_er = TRUE when it receives bad ESDs, ERR_ESD, or bad SSDs. When the 
state machine reaches the IDLE state, pcs_rx_er gets reset to FALSE.
96.3.4.3 PCS Receive descrambler polynomial
This function shall conform to 40.3.1.4.2, with the exception that it applies to rx_data<2:0>.
96.3.4.4 PCS Receive automatic polarity detection (Optional)
During training, automatic polarity detection may be done in PCS Receive with proper decoding procedures. 
In the IDLE mode, Sdn[2:0] are generated by side-stream scrambler with Sdn[0]=Scrn[0]. According to 
Table 96–1, when Sdn[0] is 0, TAn is either +1 or –1; otherwise, TAn is 0. Based on this rule, Scrn[0] should 
be decoded solely depending on the value of RAn, then fed back to the shift registers of side-stream descram-
bler to achieve reliable state acquisition. After that, in every symbol cycle, Scrn[0] should be compared with 
the processed RAn value. Continuous consistency within a certain period means the scrambler has been suc-
cessfully locked. Polarity can also be automatically detected with similar techniques in a recursive process: 
one assumption of polarity is made first and the descrambler synchronization is monitored within a certain 
period to determine whether such an assumption is correct; if not, the same procedure is repeated with a dif-
ferent polarity assumption.
Figure 96–12—PCS Data receive symbol decoding
 1D
to
2D
 RAn
 RBn
3B/4B
CONVERSION
 RXD<3:0>
 RX_DV
 RX_ER
 rx_data<2:0>
 pcs_rx_dv
 pcs_rx_er
rx_symb_vector
DECODE


Polarity detection and correction can be done simultaneously at the earliest link up stages. Link up starts 
with the MASTER PHY sending symbols to the SLAVE PHY. During this initial stage, all hand-shaking 
signal status, such as rem_rcvr_status, are known as FALSE. With this a priori knowledge, polarity should 
be accurately detected by the SLAVE side. If a polarity flip is detected, the SLAVE changes the sign of its 
received signals (RAn, RBn) to correct the polarity. Furthermore, it shall invert its transmitted signals (TAn, 
TBn). Since polarity correction has been taken care of by the SLAVE PHY, the polarity would always be 
observed as correct by the MASTER PHY.
96.3.4.5 PCS Receive MII signal 3B/4B conversion
The MII receive signals RXD<3:0>, RX_DV and RX_ER are synchronized with clock RX_CLK ; while 
PCS Receive generated signals rx_data<2:0>, rx_dv, and rx_error shall be synchronized with pcs_rxclk to 
keep the same bitwise throughput after 3B/4B conversion. Generation of pcs_rxclk is implementation 
dependent. RX_CLK may be derived from the same clock source as TX_CLK if the PHY is in MASTER 
mode or from the recovered clock if the PHY is in SLAVE mode. The pcs_rxclk is derived from the same 
clock source as RX_CLK, with the proper clock division factor to get to the required frequency. 
The conversion from pcs_rxclk domain signals to MII signals is shown in Figure 96–13. If the number of 
bits from the received data packet in pcs_rxclk domain is not a multiple of four, the residual bits are actually 
the stuff bits appended during 4B/3B conversion at the transmitter side. With 3B/4B conversion, those bits 
shall be discarded. RX_DV shall be deasserted right after the last nibble is converted. 
If the BAD SSD state occurred in Figure 96–10a PCS Receive state diagram, the false carrier error shall be 
indicated on the MII after conversion.
96.3.5 PCS Loopback
The PCS shall be placed in loopback mode when the loopback bit in MDIO register 3.0.14, defined in 
45.2.3.1.2, is set to a one. In this mode, the PCS shall accept data on the transmit path from the MII and 
return it on the receive path to the MII. Additionally, the PHY receive circuitry shall be isolated from the 
network medium, and the assertion of TX_EN at the MII shall not result in the transmission of data on the 
network medium. The PCS loopback data flow is illustrated in Figure 96–14.
pcs_rxclk
pcs_rx_dv
d<2:0>
d<5:3>
d<8:6>
rx_data<2:0>
pcs_rx_er
RX_DV
RX_CLK
RXD<3:0>
RX_ER
3B/4B
d<3:0>
d<7:4>
<xxx>
<xxx>
Figure 96–13—PCS Receive 3B/4B conversion reference diagram


.
The MAC compares the packets sent through the MII Transmit function to the packets received from the 
MII Receive function to validate the functionality of 100BASE-T1 PCS functions.
96.4 Physical Medium Attachment (PMA) Sublayer
The PMA couples messages from the PMA service interface specified in 96.2.1 onto the 100BASE-T1 phys-
ical medium, and provides the link management and PHY Control functions. The PMA provides full duplex 
communications to and from medium employing 3-level Pulse Amplitude Modulation (PAM3). The inter-
face between PMA and the baseband medium is the Medium Dependent Interface (MDI), which is specified 
in 96.8.
PMA functions are illustrated in Figure 96–15.
96.4.1 PMA Reset function
This function shall conform to 40.4.2.1 The optional low power mode referenced in 36.2.5.1.3 is not 
supported.
Figure 96–14—PCS loopback data flow
PMA Receive
PMA Transmit
PCS Receive
PCS Transmit
PCS loopback enable
MDI
MII


.
96.4.2 PMA Transmit function
Figure 96–16 illustrates the signal flow of the 100BASE-T1 PMA Transmit function. During transmission, 
PMA_UNITDATA.request conveys to the PMA using tx_symb_vector the value of the symbols to be sent 
over the single transmit pair.
config
tx_mode
loc_rcvr_status
rem_rcvr_status
recovered_clock
PMA_UNITDATA.request (tx_symb_vector)
PMA_UNITDATA.indication
link_status
link_control
scr_status
 (rx_symb_vector)
link_status
BI_DA +
BI_DA -
PMA
RECEIVE
PMA
TRANSMIT
received_clock
CLOCK
RECOVERY
LINK
MONITOR
PHY
CONTROL
MEDIUM
INTERFACE
DEPENDENT
(MDI)
PMA SERVICE
INTERFACE
Figure 96–15—PMA functional block diagram
NOTE: The recovered_clock arc shown indicates delivery of the recovered clock back to PMA TRANSMIT for loop 
timing.
TX_EN
MDC
MDIO
MANAGEMENT


A single transmitter is used to generate the PAM3 signal BI_DA on the wire, using the transmit clock, 
TX_TCLK of 66.666 MHz, that is the reference clock for the MASTER. When the config parameter is set to 
MASTER, the PMA Transmit Function derives the TX_TCLK from a local clock source. When the config 
parameter is set to SLAVE, the PMA Transmit Function derives the TX_TCLK from the recovered clock.
The PMA Transmit fault function is optional. The faults detected by this function are implementation spe-
cific. If the MDIO interface is implemented, then this function shall be mapped to the transmit fault bit as 
specified in 45.2.1.7.4.
96.4.3 PMA Receive function
Figure 96–17 illustrates the signal flow of the 100BASE-T1 PMA Receive function. There are three primary 
PMA Receive characteristics: Receivers, Abilities, and Sub-Functions. 
The 100BASE-T1 PMA Receive function comprises a single receiver (PMA Receive) for PAM3 modulated 
signals on a single balanced twisted-pair, BI_DA. PMA Receive has the ability to translate the received sig-
nals on the single pair into the PMA_UNITDATA.indication parameter rx_symb_vector. It detects ternary 
symbol sequences from the signals received at the MDI over one channel and presents these sequences to the 
PCS Receive function. PMA Receive has Signal Equalization and Echo Cancellation sub-functions. These 
sub-functions are used to determine the receiver performance and generate loc_rcvr_status. The parameter 
loc_rcvr_status is generated by PMA Receive to indicate the status of the receive link at the local PHY. This 
variable indicates to the PCS Transmitter, PCS Receiver, PMA PHY Control function and Link Monitor 
whether the status of the overall received link is ok or not. scr_status is generated by the PCS Receiver to 
indicate the status of the descrambler to the local PHY. It conveys the information on whether the scrambler 
has achieved synchronization or not  to the PMA receive function.
The PMA Receive fault function is optional. The PMA Receive fault function is the logical OR of the 
link_status = Fail and any implementation specific fault. If the MDIO interface is implemented, then this 
function shall contribute to the receive fault bit specified in 45.2.1.7.5.
recovered_clock
PMA_UNITDATA.request (tx_symb_vector)
BI_DA +
BI_DA -
PMA
TRANSMIT
Figure 96–16—PMA Transmit
config
tx_mode


96.4.4 PHY Control function
If the Auto-Negotiation process is not implemented or not enabled, PMA_CONFIG MASTER-SLAVE con-
figuration is predetermined to be MASTER or SLAVE via management control during initialization or via 
default hardware setup. It governs the control actions needed to bring the PHY into the 100BASE-T1 mode 
of operation so that frames can be exchanged with the link partner. PMA PHY Control also generates the 
signals that control PCS and PMA sublayer operations. It determines whether the PHY operates in the nor-
mal mode, enabling data transmission over the link segment, or whether the PHY sends special code-groups 
that represent the idle mode. PHY Control shall comply with the state diagram shown in Figure 96–18. PHY 
Control sets tx_mode to SEND_N (transmission of normal MII Data Stream, Control Information, or idle), 
SEND_I (transmission of IDLE code-groups), or SEND_Z (transmission of zero code-groups).
96.4.5 Link Monitor function
Link Monitor operation, as shown in state diagram of Figure 96–19, shall be provided to support PHY Con-
trol. The link_control variable is controlled by management during the PHY initialization. In all cases, the 
time from power_on = FALSE, transitioning to power_on = TRUE, to link_status=OK shall be less than 
100 ms.
96.4.6 PMA clock recovery
This PMA function recovers the clock from the received stream. It is coupled to the receiver in order to pro-
vide the clock for optimum sampling of the channel. PMA clock recovery outputs are also used as input 
variables for other PMA functions.
96.4.7 State variables
96.4.7.1 State diagram variables
config
The config parameter is set by management and passed to the PMA and PCS. 
Values: MASTER or SLAVE.
link_control
This variable is generated by management or set by default.
Values: ENABLE or DISABLE.
loc_rcvr_status
PMA_UNITDATA.request
PMA_UNITDATA.indication
scr_status
 (tx_symb_vector)
 (rx_symb_vector)
BI_DA +
BI_DA -
PMA
RECEIVE
received_clock
PHY CONTROL
Figure 96–17—PMA Receive


Figure 96–18—PHY Control state diagram
DISABLE TRANSMITTER
SLAVE SILENT
start maxwait_timer
tx_mode  SEND_Z
TRAINING
start minwait_timer
tx_mode  SEND_I
link_control = DISABLE +
pma_reset = ON
minwait_timer_done 
loc_rcvr_status = NOT_OK 
TX_EN = FALSE
SEND IDLE OR DATA
stop maxwait_timer
start minwait_timer
tx_mode  SEND_N
SEND IDLE
stop maxwait_timer
start minwait_timer
tx_mode  SEND_I
config = MASTER +
scr_status = OK
minwait_timer_done 
loc_rcvr_status = OK 
rem_rcvr_status = NOT_OK
minwait_timer_done 
loc_rcvr_status = OK 
rem_rcvr_status = OK
minwait_timer_done 
loc_rcvr_status = NOT_OK
minwait_timer_done 
loc_rcvr_status = OK 
rem_rcvr_status = NOT_OK
minwait_timer_done
loc_rcvr_status = OK
rem_rcvr_status = OK
link_control = ENABLE


link_status
This variable is generated by the PMA to indicate the status of the link. 
Values: OK or FAIL.
loc_rcvr_status
Variable set by the PMA Receive function to indicate correct or incorrect operation of the receive 
function for the local PHY.
Values: OK: The receive function for the local PHY is operating reliably.
NOT_OK: Operation of the receive function for the local PHY is unreliable.
pma_reset
Allows reset of all PMA functions.
Values: ON or OFF 
Set by:
PMA Reset 
rem_rcvr_status 
Variable set by the PCS Receive function to indicate whether correct operation of the receive func-
tion for the remote PHY is detected or not.
Values: OK: The receive function for the remote PHY is operating reliably.
NOT_OK: Reliable operation of the receive function for the remote PHY is not detected.
Figure 96–19—Link Monitor state diagram
LINK DOWN
link_status  FAIL
HYSTERESIS
start stabilize_timer
LINK UP
link_status  OK
pma_reset = ON +
link_control  ENABLE
stabilize_timer_done 
loc_rcvr_status = OK
loc_rcvr_status = OK
loc_rcvr_status = NOT_OK
loc_rcvr_status = NOT_OK 
maxwait_timer_done = TRUE


---

<a id='clause-97'></a>