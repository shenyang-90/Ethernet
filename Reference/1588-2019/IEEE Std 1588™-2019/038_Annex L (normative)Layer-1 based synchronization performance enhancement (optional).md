# Annex L (normative)Layer-1 based synchronization performance enhancement (optional)

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
425 
Annex L  
(normative) 
Layer-1 based synchronization performance enhancement (optional) 
L.1 General 
When this option is implemented (see 6.1), by being specified in the applicable PTP Profile or by the 
manufacturer, then the option shall operate as specified in this annex. 
This annex defines the optional feature Layer 1 based synchronization performance enhancement (L1Sync) 
that can be used to support cooperation between PTP based synchronization and the physical layer (L1) 
based syntonization (e.g., Synchronous Ethernet, ITU-T Recommendations G.8261 [B33] and G.8262 
[B34]). The annex explains how to use such cooperation to enhance synchronization performance; 
however, several other possible applications exist. 
This annex provides the means to retrieve the current relationship and to configure a required relationship 
between the PTP synchronization and the L1 syntonization. The relationship between the PTP 
synchronization and the L1 syntonization is described in L.2 and L.3 as the relationship between the Local 
PTP Clock, L1 tx clock signal, and L1 rx clock signal, all defined in Clause 3. In an implementation 
consistent with this annex, the required relationship can be configured via configurable members of the 
data set defined in L.5.2. This required relationship is requested to be applied by an implementation-
specific mechanism when specified by the operation of the L1Sync state machine defined in L.7. The 
information about the relationship currently in place can be retrieved through dynamic members of the data 
set defined in L.5.3. The value of these dynamic data set members is TRUE if the operation of the 
implementation-specific mechanism and of the protocol is such that the description of the respective 
relationship in L.2 is true. The values of configurable and dynamic data set members are exchanged 
between the local and peer PTP Ports via the L1_SYNC TLV defined in L.6 (with optional extension in 
L.8.5). An implementation-specific mechanism consistent with this annex that enhances synchronization 
performance can operate on a Direct PTP Link if and only if the L1Sync configuration of both of its PTP 
Ports is compatible and the relationship currently in place meets the relationship required by the L1Sync 
configuration. 
NOTE 1— The relationship required through configuration can take time to be applied by the relevant implementation-
specific mechanism, for example, supporting hardware. Moreover, for reasons outside the scope of this standard, it 
might not be possible for the required relationship to be applied by this mechanism or the current relationship might 
change due to external conditions. For example, a relationship might require a Phase Locked Loop (PLL) to acquire a 
lock, which can take time and fail. Thus, the operation of this optional feature depends on the values provided in the 
configurable and the dynamic data set members. The former indicate what is the required situation (e.g., a PLL is 
required to lock), and the latter reflect the current situation (e.g., a PLL is locked). 
When the required relationship is in place, it is possible to enhance timestamps using the information about 
the phase offset between the clock signals, as explained using the Link Reference Model discussed in L.3. 
Such enhancement can be performed by implementation-specific mechanisms if the two peer PTP Ports are 
connected over a Direct PTP Link (see 3.1.8). Annex M explains how the mechanisms provided in this 
annex can be used to ensure frequency loopback, and how such frequency loopback is then used for precise 
correction of timestamps through phase offset measurement. 
Correction of egress timestamps by the transmitting PTP Port according to the Link Reference Model might 
be impossible or suboptimal in some implementations, for example in one-step PTP Ports. In cases such as 
this, information sent by a PTP Port using the optional parameters defined in L.8 can be used by its peer 
PTP Port to enhance performance. The optional parameters are defined as an option within this optional 
feature.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
426 
The applicable PTP Profile must define default and allowed values of attributes (see L.4) that characterize 
the operation of L1Sync. 
NOTE 2— While this annex is based on the White Rabbit implementation [B53], this annex provides greater flexibility 
than the original White Rabbit. This flexibility is restricted by the High Accuracy Delay Request-Response Default 
PTP Profile (see I.5), which corresponds to the original White Rabbit. The High Accuracy Default PTP Profile requires 
all the types of relationships to be in place and disallows the optional parameters of L.8. This profile is meant to 
provide sub-nanosecond accuracy of synchronization if the example implementation described in Annex M is followed. 
A dedicated implementation-specific mechanism (e.g., hardware support) is essential to the operation of 
this optional feature. The required mechanisms might differ depending on whether a PTP Port operates in a 
Master or a Slave state. This optional feature does not contribute to restricting/limiting the BMCA’s 
decisions to the PTP states supported by the implementation-specific mechanism. If an implementation 
does not support enhancements for all PTP states on a PTP Port, this implies that to successfully use this 
optional feature the result of the alternate BMCA and/or external port configuration (see 17.6) must be such 
that PTP Ports are not placed into PTP states not supported by the implementation. 
NOTE 3— This annex provides protocol support that allows enhanced synchronization performance provided that 
appropriate hardware is implemented, and appropriate calibration procedures are followed. The enhanced performance 
depends on the hardware characteristics. Characteristics are provided in Annex M for an example implementation that 
achieves sub-nanosecond accuracy of synchronization. Annex M includes characteristics such as the bandwidth, 
maximum gain peaking, Maximum Time Interval Error (MTIE) and Time deviation (TDEV), see M.6. It also describes 
a technique to achieve timestamping precision of ±4 ps (see M.3), taking advantage of frequency loopback (see M.2). 
L.2 Basic terms 
L.2.1 General 
This subclause provides terms used for the purpose of this annex.  
L.2.2 Coherent clocks, coherent clock signals, coherent clock signal and clock: Clocks A 
and B, or clock signals A and B, or clock signal A and clock B are coherent if the variation of the 
phase offset between A and B is bounded within performance limits. 
NOTE 1— For the purposes of the Link Reference Model in Figure L.1 the phase offset is considered constant when 
clocks are coherent. 
NOTE 2— This implies that the average frequency offset between A and B is bounded within performance limits 
L.2.3 Transmit coherent port: A PTP Port “A” is transmit coherent if the L1 tx clock signal 
transmitted at PTP Port “A” of a PTP Instance and the Local PTP Clock of the PTP Instance are 
coherent. For example: 
 
The L1 tx clock signal is appropriately derived from the Local PTP Clock; 
 
The L1 tx clock signal is traceable to the same source as the Local PTP Clock. 
NOTE—This implies that the transmitted L1 tx clock signal can be used to generate a physical clock that is coherent 
with the Local PTP Clock. 
L.2.4 Receive coherent port: A PTP Port “A” is receive coherent if the L1 rx clock signal 
received at PTP Port “A” of a PTP Instance and the Local PTP Clock of the PTP Instance are 
coherent. For example: 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
427 
 
The L1 rx clock signal is used to appropriately generate the Local PTP Clock; 
 
The L1 rx clock signal and the Local PTP Clock are traceable to the same source. 
NOTE 1— This implies that the received L1 rx clock signal can be used to generate a physical clock and that the Local 
PTP Clock is coherent with this physical clock. 
NOTE 2— A receive coherent port is not necessarily in PTP Slave state. This can be the case in a PTP Network that 
uses Synchronous Ethernet [B34] for frequency distribution (see also Ronen and Lipinski [B51]). 
L.2.5 Congruent port: A PTP Port at which the timing flow of L1 syntonization and PTP 
synchronization is the same. For example: 
 
congruent slave port: A PTP Port at which the Local PTP Clock is syntonized to the L1 rx clock 
signal of the PTP Port, the recommended PTP Port state is PTP Slave, and the Local PTP Clock is 
or will be synchronized via this PTP Port. 
 
congruent master port: A PTP Port at which the L1 tx clock signal of the PTP Port is syntonized 
to the Local PTP Clock, the recommended PTP Port state is PTP Master, and the time of the Local 
PTP Clock is or will be transmitted via this PTP Port. 
L.2.6 L1Sync port: An L1Sync port is a PTP Port on which the Layer-1 based synchronization 
performance enhancement option is implemented and enabled.  
L.3 Link Reference Model 
This annex provides support for enhancements of hardware-assisted timestamps. The enhancements require 
knowledge of the relationship between L1 tx clock signal (clktxL1), L1 rx clock signal (clkrxL1), and Local 
PTP Clock signal (clklocalPTP). This relationship is quantified in phase offset (see 3.1.45), as depicted in 
Figure L.1. The reception phase offset, xrx, is the phase offset of the L1 rx clock signal with respect to the 
Local PTP Clock signal; the transmission phase offset, xtx, is the phase offset of the Local PTP Clock signal 
with respect to the L1 tx clock signal. The phase offsets are expressed in the timescale in use. 
NOTE 1— The model is defined using rising edge as an example. This is not a requirement. Any distinguishing feature 
of the clock signal, for example, a falling edge, can be used. 
The Link Reference Model enables enhancement of PTP synchronization precision under the following 
conditions: 
 
Direct PTP Link between peer PTP Ports implementing this annex, that is, L1Sync ports 
(intermediate network elements that do not support this annex are not allowed) 
 
Support from implementation (e.g., hardware) that provides meaningful information about the 
phase offsets (xrx, xtx) between the clkL1tx, clkL1rx, and clkLocalPTP; the phase offsets can be known by 
design, measurement or other mechanisms 
 
The Timestamping Clock is the Local PTP Clock. 
NOTE 2— Obtaining meaningful information about the phase offset can depend on various aspects. Specifically, it 
might depend on the frequency offsets among clkL1tx, clkL1rx, and clkLocalPTP. How these aspects are addressed can be 
specified in the applicable PTP Profile. For example, the High Accuracy Delay Request-Response Default PTP Profile 
(see I.5) requires configuration in which such a frequency offset does not exist. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
428 
clkL1tx_A
clkLocalPTP_A
clkL1rx_A
Tx
n           n+1       n+2       n+3
+xtx_A
+xrx_A
Rx
clkL1rx_B
clkLocalPTP_B
clkL1tx_B
Rx
n           n+1       n+2       n+3
+xtx_B
Tx
+xrx_B
clkL1rx_A = clkL1tx_B
time
clkL1tx       - L1 tx clock signal used for encoding data
clkL1rx          - L1 rx clock signal recovered from the incoming data
clkLocalPTP   - Local PTP Clock signal used by PTP time counter
xrx             - phase offset of clkL1rx  with respect to clkLocalPTP   
xtx             - phase offset of clkLocalPTP  with respect to clkL1tx 
 
Figure L.1 Link Reference Model 
The phase offsets (xrx, xtx) are modeled as part (sub-period resolution of the Local PTP Clock signal) of the 
ingress and egress latencies and their values can be used by the implementation to correct the captured 
timestamps before they are provided to the PTP stack, as defined in 7.3.4.2. This is illustrated for ingress 
latency in Figure L.2. The message timestamp point crosses the reference plane at the rising edge of the L1 
rx clock signal (clkL1rx). The <ingressCapturedTimestamp> (as defined in 7.3.4.2) is captured at the rising 
edge of the Local PTP Clock signal (clkLocalPTP). A correct timestamp value should represent the instant at 
which the message timestamp point crosses the reference plane and, assuming (for simplicity) that no other 
sources of ingress latency exist, it can be obtained by correcting <ingressCapturedTimestamp> with the 
phase offset (xrx) between the clkLocalPTP and clkL1rx. The phase offset (xrx) contributes to the error of the 
<ingressCapturedTimestamp> in the same way in which any ingress latency would contribute. The phase 
offset can be considered to be a portion of the <implementation-specific correction of the ingressLatency 
and messageTimestampPointLatency> (see 7.3.4.2). where: 
<ingressProvidedTimestamp> = <ingressCapturedTimestamp> – <implementation-specific 
correction of ingressLatency and messageTimestampPointLatency> 
Similarly, the phase offset (xtx) between the clkLocalPTP and clkL1tx contributes to the egress latency.  
Figure L.2 is an example of ingress timestamp generation. In this figure, no other latency contributors are 
assumed; thus, <implementation-specific correction of ingressLatency and messageTimestamp 
PointLatency> is equal to the phase offset (xrx) and <ingressProvidedTimestamp> is equal to 
<ingressTimestamp>. In general, phase offsets are minor and dynamic contributors to the value of the 
ingress and egress latencies, and in practice provide improvement of precision but not accuracy.  
NOTE 3— The Link Reference Model illustrates the case in which the nominal period of the Local PTP Clock signal is 
the same as the nominal period of the L1 rx clock signal and L1 tx clock signal. Generalizations are possible where the 
nominal periods of these clock signals are different but inter-related. In such cases, the Link Reference Model might 
require frequency conversion of the Local PTP Clock signal to that of the L1 rx/tx clock signal (as the latter is the one 
visible on the wire). The method of the frequency conversion and obtaining the phase offset in accordance with the 
Link Reference Model is implementation specific. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
429 
<ingressTimestamp> 
ideal timestamp point at reference plane
(rising edge of L1 rx clock)
clkLocalPTP
communication medium
PTP Port 
event interface
PTP code
<implementation-specific correction of ingressLatency and 
messageTimestampPointLatency>
the phase offset (xrx) between the clkLocalPTP and clkL1rx
 
x
 
z
 
x  
x
 x
 x  Y 
z 
clkL1rx
xrx
x
Communication medium
PTP Event message
 
Figure L.2 Timestamp correction with phase offset modeled as <implementation-specific 
correction of ingressLatency and messageTimestampPointLatency> 
L.4 L1Sync port characteristics 
L.4.1 L1SyncEnabled 
The Boolean attribute L1SyncEnabled specifies whether the L1Sync option is enabled on the PTP Port. If 
L1SyncEnabled is TRUE, then the L1Sync message exchange (see L.6) is implemented and enabled. The 
default initialization value and allowed values of the L1SyncEnabled shall be specified in the applicable 
PTP Profile. 
NOTE—The PTP Port on which the L1Sync option is implemented and enabled is called L1Sync port (see L.2.6). 
L.4.2 txCoherentIsRequired 
The Boolean attribute txCoherentIsRequired specifies the configuration of the L1Sync port and the 
expected configuration of its peer L1Sync port. This configuration indicates whether the L1Sync port is 
required to be a transmit coherent port, as specified in L.2.3. L1Sync can successfully operate: 
 
When txCoherentIsRequired is TRUE, if and only if the L1Sync port is a transmit coherent port 
and its peer is a transmit coherent port, or 
 
When txCoherentIsRequired is FALSE, regardless of whether the L1Sync port and its peer are 
transmit coherent ports.  
NOTE—The L1SyncBasicPortDS.isTxCoherent (see L.5.3.2) and L1SyncBasicPortDS.peerIsTxCoherent (see L.5.3.9) 
indicate whether the L1Sync port and its peer, respectively, are transmit coherent ports, as specified in L.2.3. 
The default initialization value and allowed values of txCoherentIsRequired shall be specified in the 
applicable PTP Profile.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
430 
L.4.3 rxCoherentIsRequired 
The Boolean attribute rxCoherentIsRequired specifies the configuration of the L1Sync port and the 
expected configuration of its peer L1Sync port. This configuration indicates whether the L1Sync port is 
required to be a receive coherent port, as specified in L.2.4. L1Sync can successfully operate: 
 
When rxCoherentIsRequired is TRUE, if and only if the L1Sync is a receive coherent port and its 
peer is a receive coherent port, or 
 
When rxCoherentIsRequired is FALSE, regardless of whether the L1Sync port and its peer are 
receive coherent ports. 
NOTE—The 
L1SyncBasicPortDS.isRxCoherent 
(see 
L.5.3.3) 
and 
L1SyncBasicPortDS.peerIsRxCoherent  
(see L.5.3.10) indicate whether the L1Sync port and its peer, respectively, are receive coherent ports, as specified in 
L.2.4. 
The default initialization value and allowed values of the rxCoherentIsRequired shall be specified in the 
applicable PTP Profile. 
L.4.4 congruentIsRequired 
The Boolean attribute congruentIsRequired specifies configuration of the L1Sync port and the expected 
configuration of its peer L1Sync port. This configuration indicates whether the L1Sync port is required to 
be a congruent port, as specified in L.2.5. L1Sync can successfully operate: 
 
When congruentIsRequired is TRUE, if and only if the L1Sync port is a congruent port and its peer 
is a congruent port, or 
 
When congruentIsRequired is FALSE, regardless of whether the L1Sync port and its peer are 
congruent ports  
NOTE—The L1SyncBasicPortDS.isCongruent (see L.5.3.4) and L1SyncBasicPortDS.peerIsCongruent (see L.5.3.11) 
indicates whether the L1Sync port and its peer, respectively, are congruent ports, as specified in L.2.5. 
The default initialization value and allowed values of the congruentIsRequired shall be specified in the 
applicable PTP Profile.  
L.4.5 optParamsEnabled 
The Boolean attribute optParamsEnabled specifies whether the L1Sync port transmitting the L1_SYNC 
TLV extends this TLV per L.8.5 with the information about the optional parameters defined in L.8. 
The specification initialization value (8.1.3.4) of optParamsEnabled shall be FALSE. The allowed values of 
optParamsEnabled shall be FALSE, unless otherwise specified in the applicable PTP Profile. 
NOTE—An applicable PTP Profile that specifies the default initialization and/or allowed value of this attribute to be 
TRUE mandates implementation of the optional parameters defined in section L.8.  
L.4.6 L1SyncInterval 
The attribute L1SyncInterval shall specify the mean time interval between successive periodic messages 
sent by the L1Sync port and carrying the L1_SYNC TLV (see L.6). The default initialization value and 
allowed values of the L1SyncInterval shall be specified in the applicable PTP Profile. 
NOTE—This attribute is specified indirectly by configuring logL1SyncInterval.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
431 
L.4.7 L1SyncReceiptTimeout 
The value of L1SyncReceiptTimeout specifies the number of elapsed L1SyncIntervals that must pass 
without reception of the L1_SYNC TLV before the L1_SYNC TLV reception timeout occurs (see L.6.3). 
The default initialization value and allowed values of the L1SyncReceiptTimeout shall be specified in the 
applicable PTP Profile. 
L.5 L1Sync data sets 
L.5.1 General specification for data set members 
This annex defines the L1SyncBasicPortDS data set that shall be maintained for each PTP Port as a basis 
for the L1Sync operation and providing values for the fields of L1_SYNC TLV. Optionally, if it is  
supported by the implementation, the L1SyncOptParamsPortDS, defined in L.8.4, can be maintained. 
In addition to the specification of 8.1.3, all dynamic members of the L1SyncBasicPortDS data set shall be 
set to initialization values when the state machine of L.7.3 is in DISABLED state. Moreover, the dynamic 
members in Table L.2 shall be set to initialization values when the state machine of L.7.3 enters the IDLE 
state.  
L.5.2 Configurable members of the L1SyncBasicPortDS data set 
L.5.2.1 L1SyncBasicPortDS.L1SyncEnabled 
The value of L1SyncBasicPortDS.L1SyncEnabled is the value of the L1SyncEnabled attribute (see L.4.1) 
of the L1Sync port. The data type shall be Boolean. 
L.5.2.2 L1SyncBasicPortDS.txCoherentIsRequired 
The value of L1SyncBasicPortDS.txCoherentIsRequired is the value of the txCoherentIsRequired attribute 
(see L.4.2) of the L1Sync port. The data type shall be Boolean. 
L.5.2.3 L1SyncBasicPortDS.rxCoherentIsRequired 
The value of L1SyncBasicPortDS.rxCoherentIsRequired is the value of the rxCoherentIsRequired attribute 
(see L.4.3) of L1Sync port. The data type shall be Boolean. 
L.5.2.4 L1SyncBasicPortDS.congruentIsRequired 
The value of L1SyncBasicPortDS.congruentIsRequired is the value of the congruentIsRequired attribute 
(see L.4.4) of the L1Sync port. The data type shall be Boolean. 
L.5.2.5 L1SyncBasicPortDS.optParamsEnabled 
The value of L1SyncBasicPortDS.optParamsEnabled is the value of the optParamsEnabled attribute  
(see L.4.5) of the L1Sync port. The data type shall be Boolean. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
432 
L.5.2.6 L1SyncBasicPortDS.logL1SyncInterval 
The value of L1SyncBasicPortDS.logL1SyncInterval shall be the logarithm to the base 2 of the 
L1SyncInterval in seconds (see L.4.6). The data type shall be Integer8. 
L.5.2.7 L1SyncBasicPortDS.L1SyncReceiptTimeout 
The value of L1SyncBasicPortDS.L1SyncReceiptTimeout is the value of the L1SyncReceiptTimeout 
attribute (see L.4.7). The data type shall be UInteger8. 
L.5.3 Dynamic members of the L1SyncBasicPortDS data set 
L.5.3.1 L1SyncBasicPortDS.L1SyncLinkAlive 
The value of L1SyncBasicPortDS.L1SyncLinkAlive shall be initialized to FALSE. The data type shall be 
Boolean. L1SyncBasicPortDS.L1SyncLinkAlive shall be set to TRUE when a L1_SYNC TLV is received 
at the PTP Port and the PTP Port is configured with L1SyncBasicPortDS.L1SyncEnabled TRUE (i.e., it is 
an L1Sync port). L1SyncBasicPortDS.L1SyncLinkAlive shall be set to FALSE when  the L1_SYNC TLV 
reception timeout occurs (see L.6.3). 
NOTE—The value of L1SyncBasicPortDS.L1SyncLinkAlive is set to the initialization value (FALSE) when the state 
machine of L.7.3 is in the DISABLED state (see L.5.1). This happens when the PTP Port is configured with 
L1SyncBasicPortDS.L1SyncEnabled set to FALSE. This also happens as a result of the L1SYNC_RESET event. This 
event is implementation specific and can be defined by a PTP Profile. The High Accuracy Delay Request-Response 
Default PTP Profile specifies it to be instantiated whenever a disconnection of the physical port interface is detected, 
(see I.5.3a)). 
L.5.3.2 L1SyncBasicPortDS.isTxCoherent 
The value of L1SyncBasicPortDS.isTxCoherent shall be set to TRUE when the L1Sync Port is a transmit 
coherent port, as specified in L.2.3. Otherwise, it shall be set to FALSE. The data type shall be Boolean. 
NOTE—The TRUE value of this dynamic data set member indicates that the current state of the relevant 
implementation-specific mechanism is such that the relationship described in L.2.3 is in place and so this L1Sync port 
is a transmit coherent port. 
L.5.3.3 L1SyncBasicPortDS.isRxCoherent 
The value of L1SyncBasicPortDS.isRxCoherent shall be set to TRUE when the L1Sync Port is a receive 
coherent port, as specified in L.2.4. Otherwise, it shall be set to FALSE. The data type shall be Boolean. 
NOTE 1— The TRUE value of this dynamic data set member indicates that the current state of the relevant 
implementation-specific mechanism is such that the relationship described in L.2.4 is in place and so this L1Sync port 
is a receive coherent port. 
NOTE 2— Per L.2.4, L1Sync port is a receive coherent port in two cases: 
a) 
The L1 rx clock signal is used to appropriately generate the Local PTP Clock; 
b) 
The L1 rx clock signal and the Local PTP Clock are traceable to the same source. 
As an example, L1Sync port is a receive coherent port, per case b), if the following are true: 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
433 
 
The relationship required at this L1Sync port and its peer, provided in the configurable members of 
the 
L1SyncBasicPortDS, 
is 
as 
follows: 
txCoherentIsRequired = TRUE, 
rxCoherentIs 
Required = TRUE, peerTxCoherentIsRequired = TRUE, peerRxCoherentIsRequired = TRUE , and 
 
The current relationship at this L1Sync port and its peer, provided in the dynamic members of the 
L1SyncBasicPortDS, 
is 
as 
follows: 
isTxCoherent = TRUE, 
peerIsTxCoherent = TRUE, 
peerIsRxCoherent = TRUE . 
In this case, the L1Sync port is a receive coherent port and the L1SyncBasicPortDS.isRxCoherent is set to TRUE. 
L.5.3.4 L1SyncBasicPortDS.isCongruent 
The value of L1SyncBasicPortDS.isCongruent shall be set to TRUE when the PTP Port is a congruent port, 
as specified in L.2.5. Otherwise, it shall be set to FALSE. The data type shall be Boolean. 
NOTE 1— The TRUE value of this dynamic data set member indicates that the current state of the relevant 
implementation-specific mechanism and the operation of this protocol are such that the relationship described in L.2.5 
is in place and so this L1Sync port is a congruent port. 
NOTE 2— A PTP Port in the MASTER state that is a transmit coherent port is also a congruent port. A PTP Port in the 
UNCALIBRATED or SLAVE state becomes a congruent port as soon as it becomes a receive coherent port. 
L.5.3.5 L1SyncBasicPortDS.L1SyncState 
The value of L1SyncBasicPortDS.L1SyncState shall be the value of the current state of the L1Sync state 
machine associated with this L1Sync port (see L.7) and shall be enumerated according to Table L.1. The 
data type shall be Enumeration8. 
Table L.1 L1Sync state enumeration 
L1Sync state Enumeration8 
Value (hex) 
DISABLED 
01 
IDLE 
02 
LINK_ALIVE 
03 
CONFIG_MATCH 
04 
L1_SYNC_UP 
05 
--- 
All other values reserved 
The initialization value of L1SyncState shall be DISABLED.  
L.5.3.6 L1SyncBasicPortDS.peerTxCoherentIsRequired 
The value of L1SyncBasicPortDS.peerTxCoherentIsRequired shall be set as defined in Table L.2. The data 
type shall be Boolean. 
L.5.3.7 L1SyncBasicPortDS.peerRxCoherentIsRequired 
The value of L1SyncBasicPortDS.peerRxCoherentIsRequired shall be set as defined in Table L.2. The data 
type shall be Boolean. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
434 
L.5.3.8 L1SyncBasicPortDS.peerCongruentIsRequired 
The value of L1SyncBasicPortDS.peerCongruentIsRequired shall be set as defined in Table L.2. The data 
type shall be Boolean. 
L.5.3.9 L1SyncBasicPortDS.peerIsTxCoherent 
The value of L1SyncBasicPortDS.peerIsTxCoherent shall be set as defined in Table L.2. The data type 
shall be Boolean. 
L.5.3.10 L1SyncBasicPortDS.peerIsRxCoherent 
The value of L1SyncBasicPortDS.peerIsRxCoherent shall be set as defined in Table L.2. The data type 
shall be Boolean. 
L.5.3.11 L1SyncBasicPortDS.peerIsCongruent 
The value of L1SyncBasicPortDS.peerIsCongruent shall be set as defined in Table L.2. The data type shall 
be Boolean.  
Table L.2 Storing fields of the L1_SYNC TLV in the local L1SyncBasicPortDS 
DS member 
Initialization 
value 
Field of the most recently received 
L1_SYNC TLV 
L1SyncBasicPortDS.peerTxCoherentIsRequired 
FALSE 
TCR 
L1SyncBasicPortDS.peerRxCoherentIsRequired 
FALSE 
RCR 
L1SyncBasicPortDS.peerCongruentIsRequired 
FALSE 
CR 
L1SyncBasicPortDS.peerIsTxCoherent 
FALSE 
ITC 
L1SyncBasicPortDS.peerIsRxCoherent 
FALSE 
IRC 
L1SyncBasicPortDS.peerIsCongruent 
FALSE 
IC 
NOTE—As specified in L.5.1, the initialization values are set when the state machine of L.7.3. is in the DISABLED state or 
enters the IDLE state. 
L.6 L1Sync message exchange 
L.6.1 General 
A PTP Port that supports this annex and has its L1SyncBasicPortDS.L1SyncEnabled set to TRUE 
communicates by sending and receiving a L1_SYNC TLV. The L1_SYNC TLV is nonpropagating. The 
L1_SYNC TLV shall be carried in a message that is addressed to the nonforwardable transport address31, if 
such an address is supported by the mapping defined in use. The transmission and reception of the 
L1_SYNC TLV is specified in L.6.2 and L.6.3 respectively. The format of the L1_SYNC TLV is specified 
in L.6.4. The L1_SYNC TLV shall be transmitted in PTP Signaling messages, unless otherwise specified in 
an applicable PTP Profile. The L1Sync message exchange is depicted in Figure L.3. 
                                                 
31 As an example, nonforwardable transport address for the following:  
 
Transport of PTP over User Datagram Protocol over Internet Protocol is 224.0.0.107 
 
Transport of PTP over IEEE 802.3/Ethernet is 01-80-C2-00-00-0E 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
435 
 
L1Sync port 1 time
L1Sync port 2 time
L1SyncInterval
L1SyncInterval
 
Figure L.3 L1Sync message exchange 
L.6.2 Transmission of the L1_SYNC TLV 
A PTP Port with L1SyncBasicPortDS.L1SyncEnabled set to TRUE shall periodically send a PTP message 
with an L1_SYNC TLV attached. The mean time interval between successive periodic L1_SYNC TLV 
transmissions shall be specified by the L1SyncBasicPortDS.logL1SyncInterval (see L.5.2.6). The time 
intervals between successive L1_SYNC TLV transmissions shall meet the requirements for the time 
interval between successive Announce message transmissions, see 9.5.8. A PTP Port with 
L1SyncBasicPortDS.L1SyncEnabled set to TRUE may send a PTP message with an L1_SYNC TLV 
attached upon change of the information transmitted in the L1_SYNC TLV. The format of the L1_SYNC 
TLV shall be the basic format specified in L.6.4, unless the optional parameters of subclause L.8 are 
enabled, that is, optParamsEnabled=TRUE. When optParamsEnabled=TRUE, the format of the L1_SYNC 
TLV shall be the extended format specified in L.8.5. 
L.6.3 Reception of the L1_SYNC TLV and the L1_SYNC TLV reception timeout 
A PTP Port with L1SyncBasicPortDS.L1SyncEnabled set to TRUE shall evaluate the basic format of the 
L1_SYNC TLV carried by any PTP message received on that PTP Port (see L.6.4). The content of the 
basic format of the L1_SYNC TLV shall be stored in the L1SyncBasicPortDS as defined in Table L.2 until 
the next L1_SYNC TLV is received, or the initialization values are set per L.5.1. Any fields of the 
L1_SYNC TLV that are not part of the basic format shall be ignored, unless the optional parameters are 
allowed by the implementation. The format of the received L1_SYNC TLV is extended if the value of the 
OPE bit (see L.6.4.6) in the received frame is TRUE (see Table L.3). 
NOTE—OPE bit is used by L1Sync ports that support the optional parameters of subclause L.8 to recognize the format 
of the received L1_SYNC TLV. L1Sync ports that do not support the optional parameters can ignore the OPE bit and 
can parse only the basic format of the L1_SYNC TLV. 
On a PTP Port with L1SyncBasicPortDS.L1SyncEnabled set to TRUE, the L1_SYNC TLV reception 
timeout shall occur when an L1_SYNC TLV has not been received over L1SyncReceiptTimeout (see 
L.4.7) number of L1SyncIntervals (see L.4.6). When the L1_SYNC TLV reception timeout occurs, the 
L1SyncLinkAlive is set to FALSE, see L.5.3.1. 
L.6.4 Basic format of the L1_SYNC TLV 
The basic format of the L1_SYNC TLV is specified in Table L.3. An L1Sync port implementing this annex 
shall support the basic format of the L1_SYNC TLV. The length of the L1_SYNC TLV with basic format 
shall be 2 octets. The basic format of the L1_SYNC TLV can be extended as specified in L.8.5. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
436 
Table L.3 Content and layout of the basic format of the L1_SYNC TLV 
Bits 
Octets 
TLV 
offset 
7 
6 
5 
4 
3 
2 
1 
0 
tlvType 
2 
0 
lengthField 
2 
2 
Reserved 
OPE 
CR 
RCR 
TCR 
1 
4 
Reserved 
Reserved 
IC 
IRC 
ITC 
1 
5 
L.6.4.1 tlvType 
The value of tlvType shall be L1_SYNC (see Table 52). 
L.6.4.2 lengthField 
The value of lengthField with the basic format shall be 2. 
L.6.4.3 TCR (Boolean) 
The value of TCR shall be the value of L1SyncBasicPortDS.txCoherentIsRequired. 
L.6.4.4 RCR (Boolean) 
The value of RCR shall be the value of  L1SyncBasicPortDS.rxCoherentIsRequired. 
L.6.4.5 CR (Boolean) 
The value of CR shall be the value of  L1SyncBasicPortDS.congruentIsRequired. 
L.6.4.6 OPE (Boolean) 
The value of OPE shall be the value of  L1SyncBasicPortDS.optParamsEnabled. 
L.6.4.7 ITC (Boolean) 
The value of ITC shall be the value of  L1SyncBasicPortDS.isTxCoherent. 
L.6.4.8 IRC (Boolean) 
The value of IRC shall be the value of  L1SyncBasicPortDS.isRxCoherent. 
L.6.4.9 IC (Boolean) 
The value of IC shall be the value of  L1SyncBasicPortDS.isCongruent. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
437 
L.7 L1Sync port operation specification 
L.7.1 General 
The operation of L1Sync shall be defined per PTP Port. It shall be governed by the state machine defined in 
L.7.3 with state definitions in L.7.2 and state transitions in L.7.4.  
L.7.2 State definitions 
The behavior of the states of an L1Sync port associated with the state machine of Figure L.4 shall be as 
defined in Table L.4. 
Table L.4 Description of L1 Sync States 
Name 
Description 
DISABLED 
L1Sync is not enabled on this PTP Port (see L.5.2.1) or the event L1SYNC_RESET   
(see L.7.4.3) has occurred. All dynamic members of L1SyncBasicPortDS and L1SyncOptPortDS data 
sets are set to initialization values in this state. 
IDLE 
L1Sync is enabled on this PTP Port (see L.5.2.1). The PTP Port sends messages with the L1_SYNC 
TLV. The dynamic members listed in Table L.2 are set to initialization values when entering this 
state. 
LINK_ALIVE 
The PTP Port sends messages with the L1_SYNC TLV. The PTP Port is receiving valid L1_SYNC 
TLV from a peer PTP Port.  
CONFIG_MATCH 
The PTP Port sends messages with the L1_SYNC TLV. The PTP Port has a compatible configuration 
profile when compared with its peer PTP Port configuration profile received in the L1_SYNC TLV. 
The 
required 
relationship 
that 
is 
configured 
via 
the 
L1SyncBasicPortDS  
(see L.5.2.) shall be requested to be applied by the implementation-specific mechanisms. The L1Sync 
port remains in this state until the required relationship is successfully applied, which is indicated by 
the dynamic members of the L1SyncBasicPortDS (see L.5.3). 
L1_SYNC_UP 
The PTP Port sends messages with the L1_SYNC TLV. The required relationship specified in 
L1SyncBasicPortDS (see L.5.2) is applied by the implementation-specific mechanisms. This is 
indicated by the values of L1SyncBasicPortDS dynamic members (see L.5.3). The implementation-
specific mechanisms shall perform synchronization enhancements (see L.3). 
 
L.7.3 State machine 
The state machine of Figure L.4 shall determine the allowed transitions for L1Sync ports. The state 
machine shall be executed on each L1Sync port. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
438 
DISABLED
IDLE
LINK_ALIVE
CONFIG_MATCH
L1_SYNC_UP
ANY STATE
L1_SYNC_ENABLED
LINK_OK
CONFIG_OK
! CONFIG_OK
STATE_OK
! STATE_OK
! L1_SYNC_ENABLED OR L1_SYNC_RESET
POWERUP
! LINK_OK
! CONFIG_OK
 
Figure L.4 L1Sync State Machine 
L.7.4 State transition descriptions 
L.7.4.1 POWERUP 
The POWERUP event is defined in 9.2.6.2. 
L.7.4.2 Local variables 
The following Boolean local variables are defined:  
a) 
L1_SYNC_ENABLED indicates whether the PTP Port is configured for L1Sync operation. 
b) 
LINK_OK indicates whether the link between the L1Sync port and its peer has been verified to be 
direct and active. 
c) 
CONFIG_OK indicates whether the configuration of the communicating L1Sync ports is 
compatible.  
d) 
STATE_OK indicates whether the relationship required by configuration is currently in place. 
These variables shall be evaluated by the state machine each time a relevant member of 
L1SyncBasicPortDS changes. The values of these variables are defined in Table L.5, unless otherwise 
specified in the applicable PTP Profile. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
439 
Table L.5 Logic expressions defining values of the local variables 
Name 
Logic expression 
(all variables are members of L1SyncBasicPortDS) 
L1_SYNC_ 
ENABLED 
L1SyncEnabled == TRUE 
LINK_OK 
L1SyncLinkAlive == TRUE 
CONFIG_O
K 
 (txCoherentIsRequired == peerTxCoherentIsRequired) 
AND 
(rxCoherentIsRequired == peerRxCoherentIsRequired) 
 AND 
 (congruentIsRequired == peerCongruentIsRequired) 
STATE_OK 
 
{ ( txCoherentIsRequired == FALSE ) OR [ ( isTxCoherent == TRUE ) AND  
(peerIsTxCoherent == TRUE ) ] } 
AND 
{ ( rxCoherentIsRequired==FALSE) OR [ ( isRxCoherent == TRUE ) AND  
(peerIsRxCoherent== TRUE ) ] } 
AND 
{ ( congruentIsRequired == FALSE) OR [ ( isCongruent == TRUE ) AND  
(peerIsCongruent == TRUE ) ] } 
L.7.4.3 L1SYNC_RESET 
The L1SYNC_RESET event is implementation specific and can be defined by the applicable PTP Profile. 
NOTE—The Default High Accuracy Profile specifies this event to be instantiated whenever a disconnection of the 
physical port interface is detected (see I.5.3a)). 
L.8 Optional parameters (option within this option) 
L.8.1 General 
Subclause L.8 defines optional support for the exchange of the transmission phase offset and frequency 
offset parameters for L1Sync ports, that is, xtx and ytx, respectively, within an extended format of the 
L1_SYNC TLV. These parameters supply to the peer L1Sync port quantitative information about the 
interrelation between the L1 tx clock signal used for data transmission on an L1Sync port and the Local 
PTP Clock signal. 
The method of acquiring values of the phase offset and frequency offset parameters is outside the scope of 
this standard. Similarly, a detailed specification of how these parameters are used is outside the scope of 
this standard. A profile may specify the usage of these parameters and, if so, should specify attributes 
and/or characteristics related to these parameters (e.g., rate of transmission and/or rate of generation, 
respectively).  
NOTE 1— The optional feature of L.8 is not supported in the High Accuracy Delay Request-Response Default PTP 
Profile (see I.5). 
If L.8 is supported by an L1Sync port and the information conveyed by the parameters is valid, this 
information can be used by the peer L1Sync port to enhance the timestamps that this PTP Port receives, 
unless these timestamps are already enhanced by the sending L1Sync port. The sending L1Sync port 
indicates 
whether 
it 
enhances 
its 
timestamps 
through 
the 
value 
of 
the 
L1SyncOpt 
ParamsPortDS.timestampsCorrectedTx (see L.8.4.2.1) that is sent in the extended L1_SYNC TLV as a 
TCT bit (see L.8.5.4). If this bit is set to TRUE, it means that the transmitted timestamps are already 
enhanced using the information provided in the parameters, and any further correction using this 
information is unlikely to provide further enhancements. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
440 
The optional parameters specified in this subclause are based on a modeling of the transmission phase 
offset xtx, presented in Figure L.1, as a linear function of the Local PTP Clock time. Provided that the two 
clocks’ (i.e., clkLocalPTP and clkL1tx) interrelation is sufficiently stable over the modeled time-interval (t1–t0), 
the phase offset at a nearby time t1 (i.e., xtx(t1)) can be modeled as show in Equation (L.1).  
( )
(
) (
)
(
)
tx
1
tx
0
1
0
tx
0
x
t
y
t
t
t
x
t
=
×
−
+
 
(L.1) 
where 
xtx(t0) is the phase offset 
ytx(t0) is the frequency offset 
at time t0. 
NOTE 2— The data types of both parameters used in the model, xtx(t) and ytx(t), need to be consistent. These data types 
are defined by the data set members that store values of these parameters. 
NOTE 3— The above linear model assumes that no rollover (see NOTE 1 in L.8.2) occurs in the value of xtx(t) during 
the time-interval (t1–t0). The values of phase offset and frequency offset are specified in L.8.2 and L.8.3. 
L.8.2 Transmission phase offset 
The transmission phase offset, xtx, indicates the time-difference between  
 
the significant instant with which the passage of the message timestamp point through the reference 
plane is aligned, for example the rising edge of the L1 tx clock signal, and  
 
the time represented by the captured timestamp of this passage of the message (this timestamp will 
typically be aligned with the preceding rising edge of the Local PTP Clock signal). 
where both these times are with respect to the timescale maintained by the Local PTP Clock. In the Link 
Reference Model in Figure L.1, the transmission phase offsets xtx_A and xtx_B, are depicted as the time-
difference between the instant when the message timestamp point passes the reference plane and a 
timestamp captured using the preceding edge of the Local PTP Clock signal. However, as implementations 
might vary in how the Local PTP Clock is maintained and this timestamping is performed, the actual 
transmission phase offset relevant within the implementation is used.   
NOTE 1— In the case when the captured timestamp is aligned with the preceding rising edge of the Local PTP Clock 
signal, and the period of the Local PTP Clock signal is equal to the period of the L1 tx clock signal, the absolute value 
of the transmission phase offset will generally be limited to this period. A transmission frequency offset, for example, 
might cause the phase offset to increase up to a point where it rolls over to another value. The handling of such a 
rollover event in the sender and/or receiver is implementation specific. 
NOTE 2— A specific example of a departure from the Link Reference Model is as follows. The depicted Link 
Reference Model assumes that the period of the Local PTP Clock signal is equal to the L1 tx/rx clock signal. However, 
in general, an implementation can use different clock periods for these clock signals. If the period of the Local PTP 
Clock signal is larger than that of the L1 tx/rx clock signal, the value of the phase offset xtx might be greater than one 
period of the L1 tx/rx clock signal, and vice versa. In any case, it is the responsibility of the implementer to ensure that 
the value of the transmission phase offset enhances the precision of the timestamp provided by the implementation. 
In general, this phase offset is time varying. A phase offset value xtx is associated with time tx. This may be 
represented as an ordered pair (xtx, tx). The time tx is expressed in the timescale in use. A value of tx = 0 
means that the time is not provided by the sender, and the value xtx is the most recent known phase offset 
for the L1Sync port.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
441 
L.8.3 Transmission frequency offset 
The transmission frequency offset, ytx, is the known rate of change of the transmission phase offset xtx(t).  
In general, this frequency offset ytx is time varying. A frequency offset value ytx is associated with time ty. 
This may be represented as an ordered pair (ytx, ty). The time ty is expressed in the timescale in use. A value 
of ty = 0 means that the time is not provided by the sender, and the value ytx is the most recent known 
frequency offset for the L1Sync port.  
NOTE 1— The times tx and ty are not necessarily the same. 
NOTE 2— A PTP Instance receiving the values ytx corresponding to the time ty can use this value and the received L1 
rx clock signal (clkL1rx) to generate a Local PTP Clock signal (clkLocalPTP) approximately syntonized to the Local PTP 
Clock signal of the transmitting PTP Instance. The level of approximation depends on the stability of ytx within the 
specific system.  
NOTE 3— The transmission phase and frequency offset parameters can be significant when addressing generalizations 
of L1Sync behavior, wherein the L1 tx clock signal (clkL1tx) of a PTP Instance is not coherent with its Local PTP Clock 
signal. 
L.8.4 L1SyncOptParamsPortDS data set 
L.8.4.1 General specification 
If L.8 is implemented, the L1SyncOptParamsPortDS shall be maintained for each PTP Port. 
In addition to the specification of 8.1.3, the dynamic members of the L1SyncOptParamsPortDS data set 
shall be initialized when the state machine of L.7.3 is in the DISABLED state. 
L.8.4.2 Configurable members of the L1SyncOptParamsPortDS data set 
L.8.4.2.1 L1SyncOptParamsPortDS.timestampsCorrectedTx 
The value of L1SyncOptParamsPortDS.timestampsCorrectedTx specifies configuration of the L1Sync port 
on which L1Sync optional parameters are enabled, that is, the value of the L1SyncBasicPortDS. 
optParamsEnabled is TRUE (see L.5.2.5). When L1SyncOptParamsPortDS.timestampsCorrectedTx is 
TRUE, the L1Sync port shall correct the transmitted egress timestamps with the known value of the phase 
offset (xtx), as indicated in the Link Reference Model defined in L.3. Otherwise, when 
L1SyncOptParamsPortDS.timestampsCorrectedTx is FALSE, the L1Sync port shall not correct transmitted 
egress timestamps with the information that is provided in the parameters sent in the L1_SYNC TLV. In 
such a case (i.e., L1SyncOptParamsPortDS.timestampsCorrectedTx=FALSE), the parameters, if valid, may 
be used by the receiving L1Sync port to enhance the received timestamps. The data type shall be Boolean. 
NOTE—When the value of the L1SyncOptParamsPortDS.timestampsCorrectedTx is TRUE, the timestamps on the 
L1Sync port are corrected as if the Optional Parameters of L.8 were not implemented/enabled while the values of the 
optional parameters can be sent in the extended L1_SYNC TLV. 
L.8.4.3 Dynamic members of the L1SyncOptParamsPortDS data set 
L.8.4.3.1 L1SyncOptParamsPortDS.phaseOffsetTxValid 
The value of L1SyncOptParamsPortDS.phaseOffsetTxValid shall be TRUE if and only if the values of the 
transmission phase offset parameters (provided by L1SyncOptParamsPortDS members phaseOffsetTx and 
phaseOffsetTxTimestamp) are valid. Otherwise, it shall be FALSE. The data type shall be Boolean. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
442 
L.8.4.3.2 L1SyncOptParamsPortDS.frequencyOffsetTxValid 
The value of L1SyncOptParamsPortDS.frequencyOffsetTxValid shall be TRUE if and only if the values of 
the transmission frequency offset parameters (provided by L1SyncOptParamsPortDS members 
frequencyOffsetTx and frequencyOffsetTxTimestamp) are valid. Otherwise, it shall be FALSE. The data 
type shall be Boolean. 
L.8.4.3.3 L1SyncOptParamsPortDS.phaseOffsetTx 
The value of L1SyncOptParamsPortDS.phaseOffsetTx shall be the transmission phase offset xtx defined in 
L.8.2. The data type shall be TimeInterval. 
NOTE—The data type of L1SyncOptParamsPortDS.phaseOffsetTx is TimeInterval (see 5.3.2), thus it is divided by 
2+16 to obtain its value in nanoseconds. 
L.8.4.3.4 L1SyncOptParamsPortDS.phaseOffsetTxTimestamp 
The value of L1SyncOptParamsPortDS.phaseOffsetTxTimestamp shall be the transmission phase offset 
timestamp tx defined in L.8.2 and expressed in the timescale in use. The data type shall be Timestamp. 
L.8.4.3.5 L1SyncOptParamsPortDS.frequencyOffsetTx 
The value of L1SyncOptParamsPortDS.frequencyOffsetTx shall be the transmission frequency offset ytx 
defined in L.8.3, multiplied by 1 second. The data type shall be TimeInterval. 
NOTE—The data type of L1SyncOptParamsPortDS.frequencyOffsetTx is TimeInterval (see 5.3.2), thus it is divided 
by 2+16 to obtain the transmission frequency offset in nanoseconds per second. The transmission frequency offset 
provides resolution of 2–16ns/s. As an example, the value 216 represents a frequency offset of 1 ns/s. 
L.8.4.3.6 L1SyncOptParamsPortDS.frequencyOffsetTxTimestamp 
The value of L1SyncOptParamsPortDS.frequencyOffsetTxTimestamp shall be the transmission frequency 
offset sample time ty defined in L.8.3 and expressed in the timescale in use. The data type shall be 
Timestamp. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
443 
L.8.5 Extended format of L1_SYNC TLV 
The extended format of the L1_SYNC TLV is specified in Table L.6. An L1Sync port shall send the 
L1_SYNC TLV with the extended format if and only if the value of  L1SyncBasicPortDS. 
optParamsEnabled is TRUE (see L.5.2.5). 
Table L.6 L1_SYNC TLV extended format 
Bits 
Octets 
TLV 
offset 
7 
6 
5 
4 
3 
2 
1 
0 
tlvType 
2 
0 
lengthField 
2 
2 
Reserved 
OPE 
CR 
RCR 
TCR 
1 
4 
Reserved 
IC 
IRC 
ITC 
1 
5 
Reserved 
FOV 
POV 
TCT 
1 
6 
phaseOffsetTx 
8 
7 
phaseOffsetTxTimestamp 
10 
15 
freqOffsetTx 
8 
25 
freqOffsetTxTimestamp 
10 
33 
Reserved 
1 
43 
L.8.5.1 tlvType 
The value of tlvType shall be L1_SYNC (see Table 52). 
L.8.5.2 lengthField 
The value of lengthField with the extended format shall be 40. 
L.8.5.3 TCR, RCR, CR, OPE, ITC, IRC, IC (Boolean) 
The values of TCR, RCR, CR, OPE, ITC, IRC, and IC are specified in L.6.4. 
L.8.5.4 TCT (Boolean) 
The value of TCT shall be the value of L1SyncOptParamsPortDS.timestampsCorrectedTx (see L.8.4.2.1). 
L.8.5.5 POV (Boolean) 
The value of POV shall be the value of L1SyncOptParamsPortDS.phaseOffsetTxValid (see L.8.4.3.1). 
L.8.5.6 FOV (Boolean) 
The value of FOV shall be the value of L1SyncOptParamsPortDS.frequencyOffsetTxValid (see L.8.4.3.2). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
444 
L.8.5.7 phaseOffsetTx  (TimeInterval) 
The value of phaseOffsetTx shall be the value of L1SyncOptParamsPortDS.phaseOffsetTx (see L.8.4.3.3). 
L.8.5.8 phaseOffsetTxTimestamp (Timestamp) 
The value of phaseOffsetTxTimestamp shall be the value of  L1SyncOptParamsPortDS.phaseOffset 
TxTimestamp (see L.8.4.3.4). 
L.8.5.9 freqOffsetTx  (TimeInterval) 
The value of freqOffsetTx shall be the value of L1SyncOptParamsPortDS.frequencyOffsetTx  
(see L.8.4.3.5). 
L.8.5.10 freqOffsetTxTimestamp (Timestamp) 
The value of freqOffsetTxTimestamp shall be the value of  L1SyncOptParamsPortDS.frequencyOffset 
TxTimestamp (see L.8.4.3.6). 
L.9 Link verification using Signaling messages (informative)   
Signaling messages carrying the L1_SYNC TLV are meant to verify whether a PTP Communication Path 
or a PTP Link between two L1Sync ports is a Direct PTP Link, that is, no network elements exist between 
these PTP Ports. This is achieved by using nonforwardable transport address for encapsulation of Signaling 
messages (see L.6.1) to prevent their forwarding by network elements that do not support IEEE1588.  
Signaling messages carrying the L1_SYNC TLV are meant to detect PTP Instances without support for the 
L1Sync optional feature, if these PTP Instances are placed between two L1Sync ports. This is achieved by 
using the nonpropagating property of the L1_SYNC_TLV attached to a Signaling message, per 14.2.1; a 
Boundary Clock that does not support L1Sync ignores the unrecognized L1_SYNC TLV and does not 
propagate it. 
NOTE—These Signaling messages containing the L1_SYNC TLV might be retransmitted by a Transparent Clock that 
does not support L1Sync optional feature, preventing detection of such a Transparent Clock. 
If a network element or a Boundary Clock without support for L1Sync occurs between two L1Sync ports, 
the L1_SYNC TLVs are not received by any of these L1Sync ports. Failure to receive the L1_SYNC TLV 
results in the occurrence of the L1_SYNC TLV reception timeout (see L.6.3), and setting 
L1SyncBasicPortDS.L1SyncLinkAlive to FALSE.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
