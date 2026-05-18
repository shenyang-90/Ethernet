# IEEE 802.3-2022 RTL-Relevant Clause Extractions

> **Source**: `sandbox/ethernet/Reference/8023-2022/8023-2022.pdf`  
> **Method**: PyMuPDF text extraction, headers/footers stripped.  
> **Scope**: Digital/hardware-relevant content only. Electrical, optical, cable, MDI, and PICS sections excluded.  
> **Date**: 2026-05-11  

## Table of Contents

- [Clause 78: Energy-Efficient Ethernet (EEE)](#clause-78)
- [Clause 96: 100BASE-T1](#clause-96)
- [Clause 97: 1000BASE-T1](#clause-97)
- [Clause 98: Auto-Negotiation for single differential-pair media](#clause-98)
- [Clause 147: 10BASE-T1S](#clause-147)
- [Clause 126: 2.5GBASE-T and 5GBASE-T](#clause-126)

---

<a id='clause-78'></a>
# Clause 78: Energy-Efficient Ethernet (EEE)

**Focus**: LPI signaling, TX/RX state machines, wake/sleep timing, timers  
**Pages extracted**: 3314 – 3342  
**Excluded from**: Page 3343 (electrical/PICS section)

78. Energy-Efficient Ethernet (EEE)
78.1 Overview
The optional EEE capability combines the IEEE 802.3 Media Access Control (MAC) Sublayer with a 
family of Physical Layers defined to support operation in the Low Power Idle (LPI) mode. When the LPI 
mode is enabled, systems on both sides of the link can save power during periods of low link utilization.
EEE also provides a protocol to coordinate transitions to or from a lower level of power consumption and 
does this without changing the link status and without dropping or corrupting frames. The transition time 
into and out of the lower level of power consumption is kept small enough to be transparent to upper layer 
protocols and applications.
EEE supports operation over twisted-pair cabling systems, twinaxial cable, electrical backplanes, optical 
fiber, the XGXS for 10 Gb/s PHYs, the 25GAUI for 25 Gb/s PHYs, the XLAUI for 40 Gb/s PHYs, the 
LAUI-2 or 50GAUI-n for 50 Gb/s PHYs, the CAUI-n or 100GAUI-n for 100 Gb/s PHYs, the 200GAUI-n 
and 200GXS for 200 Gb/s PHYs, and the 400GAUI-n and 400GXS for 400 Gb/s PHYs. Table 78–1 lists the 
supported PHYs and interfaces and their associated clauses.
In addition to the above, EEE defines a 10 Mb/s MAU (10BASE-Te) with reduced transmit amplitude 
requirements. The 10BASE-Te MAU is fully interoperable with 10BASE-T MAUs over 100 m of class D 
(Category 5) or better cabling as specified in ISO/IEC 11801:1995. These requirements can also be met by 
Category 5 cable and components as specified in ANSI/TIA/EIA-568-B-1995. The definition of 
10BASE-Te allows a reduction in power consumption.
EEE also specifies means to exchange capabilities between link partners to determine whether EEE is 
supported and to select the best set of parameters common to both devices. Clause 78 provides an overview 
of EEE operation. PICS for the optional EEE capability for each specific PHY type are specified in the 
respective PHY clauses. Normative requirements for Data Link Layer capabilities are contained in 78.4.
78.1.1 LPI Signaling
LPI signaling allows the LPI Client to indicate to the PHY, and to the link partner, that a break in the data 
stream is expected, and the LPI Client can use this information to enter power-saving modes that require 
additional time to resume normal operation. LPI signaling also informs the LPI Client when the link partner 
has sent such an indication.
The definition of LPI signaling assumes the use of the MAC defined in Annex 4A for simplified full duplex 
operation (with carrier sense deferral). This provides full duplex operation but uses the carrier sense signal 
to defer transmission when the PHY is in the LPI mode.
The LPI Client connects to the RS service interface. LPI signaling between the RS and PCS is performed by 
LPI encoding on the Media Independent Interface. The transmit PCS encodes LPI symbols, which are 
decoded by the link partner receive PCS. The receive and transmit PCS also generate service interface 
signals, which are passed down to the lower PHY sublayers and indicate when receive and transmit PHY 
functions may be powered down.
The EEE request signals from the PCS control transitions between quiescent and normal operation. The 
Clause 49 PCS, Clause 107 PCS, Clause 82 PCS, and Clause 129 PCS also request transmit alert operation 
to assist the partner device PMD to detect the end of the quiescent state. Additionally the Clause 49 PCS, 
Clause 107 PCS, and Clause 82 PCS generate the RX_LPI_ACTIVE signal, which indicates to the 
Clause 74 BASE-R FEC that it can use rapid block lock because the link partner PCS has bypassed 
scrambling.


Coding defined in 83.5.11 also allows LPI transmit quiet and alert requests from the PCS to be signaled over 
the 25GAUI, XLAUI, and CAUI-n interfaces. The 25GAUI, XLAUI, and CAUI-n receive interfaces infer 
the quiet and alert requests from the data received over the interface and use that to recreate the transmit or 
receive direction signaling.
The receive PCS checks that the link cycles out of the quiescent state at the correct time and that the received 
signals return to their expected state within the required time. The ENERGY_DETECT indicate signal is 
passed up from the PMA to the PCS to allow the PCS to monitor the waking process.
78.1.1.1 Reconciliation sublayer service interfaces
Figure 78–1 depicts the LPI Client and the RS interlayer service interfaces.
78.1.1.2 Responsibilities of LPI Client
The decision on when to signal LPI to the link partner is made by the LPI Client and communicated to the 
PHY through the RS. The LPI Client is also informed when the link partner is signaling LPI by the RS.
The conditions under which the LPI Client decides to send LPI, and what action are taken by the LPI Client 
when it receives LPI from the link partner, are implementation specific and beyond the scope of this 
standard.
78.1.2 LPI Client service interface
The following specifies the service interface provided by the RS to the LPI Client. These services are 
described in an abstract manner and do not imply any particular implementation.
Low Power
Media Access Control (MAC)
PLS_DATA.request
PLS_SIGNAL.indication
PLS_DATA_VALID.indication
PLS_DATA.indication
PLS_CARRIER.indication
Physical Layer
Signaling (PLS)
service
interface
Low Power
Idle (LPI) Client
service
interface
Idle (LPI) Client
LP_IDLE.request
LP_IDLE.indication
Reconciliation Sublayer (RS)
xMII
PHY
Figure 78–1—LPI Client and RS interlayer service interfaces


The following primitives are defined:
LP_IDLE.request
LP_IDLE.indication
78.1.2.1 LP_IDLE.request
78.1.2.1.1 Function
A primitive used by the LPI Client to start or stop the signaling of LPI to the link partner.
78.1.2.1.2 Semantics of the service primitive
The semantics of the service primitive are as follows:
LP_IDLE.request (LPI_REQUEST)
The LPI_REQUEST parameter can take one of two values: ASSERT or DEASSERT. ASSERT initiates the 
signaling of LPI to the link partner. DEASSERT stops the signaling of LPI to the link partner. The effect of 
receipt of this primitive is undefined in any of the following cases:
a)
link_status is not OK (see 28.2.6.1.1)
b)
LPI_REQUEST=ASSERT within 1 s of the change of link_status to OK
c)
The PHY is indicating LOCAL FAULT
d)
The PHY is indicating REMOTE FAULT
78.1.2.1.3 When generated
Specification of the time when this primitive is generated by the LPI client is out of the scope of this 
standard.
78.1.2.1.4 Effect of receipt
The receipt of this primitive will cause the RS to start or stop signaling LPI to the link partner.
78.1.2.2 LP_IDLE.indication
78.1.2.2.1 Function
A primitive that is used to indicate to the LPI Client that the link partner has started or stopped signaling 
LPI.
78.1.2.2.2 Semantics of the service primitive
The semantics of the service primitive are as follows:
LP_IDLE.indication (LPI_INDICATION)
The LPI_INDICATION parameter can take one of two values: ASSERT or DEASSERT. ASSERT indicates 
that the link partner has started signaling LPI. DEASSERT indicates that the link partner has stopped 
signaling LPI.


78.1.2.2.3 When generated
This primitive is generated by the RS when it starts or stops receiving Assert LPI encoded on the receive 
xMII according to the rules defined in 78.1.3.2.
78.1.2.2.4 Effect of receipt
The effect of receipt of this primitive by the LPI client is unspecified.
78.1.3 Reconciliation sublayer operation
LPI assert and detect functions are contained in the Reconciliation Sublayer as shown in Figure 78–2. The 
xMII in this diagram represents any of the family of medium independent interfaces supported by EEE.
The following provides an overview of RS LPI operation. The actual specification of RS LPI operation can 
be found in the respective RS clauses.
78.1.3.1 RS LPI assert function
In the absence of an LPI request, indicated by the LPI_REQUEST parameter set to DEASSERT in the 
LP_IDLE.request primitive of the LPI Client interface, the LPI assert function maps the PLS service 
interface to the transmit xMII signals as under normal conditions.
When an LPI request is asserted, indicated by the LPI_REQUEST parameter set to ASSERT in the 
LP_IDLE.request primitive of the LPI Client interface, the LPI assert function starts to transmit the 
“Assert LPI” encoding on the xMII. The LPI assert function also sets the CARRIER_STATUS parameter to 
CARRIER_ON in the PLS_CARRIER.indication primitive of the PLS service interface. This will prevent 
the MAC from transmitting.
xMII
receive signals
xMII
transmit signals
PLS_DATA.request
PLS_SIGNAL.indication
PLS_DATA_VALID.indication
PLS_DATA.indication
PLS_CARRIER.indication
Physical Layer Signaling 
(PLS)
LPI Client
service interface
LP_IDLE.request
LP_IDLE.indication
LPI
assert function
LPI
detect function
Figure 78–2—RS LPI assert and detect functions
Reconciliation Sublayer


When the LPI request is deasserted, indicated by the LPI_REQUEST parameter set to DEASSERT in the 
LP_IDLE.request primitive of the LPI Client interface, the LPI assert function starts to transmit the 
normal interframe encoding on the xMII. After a delay, the LPI assert function sets the CARRIER_STATUS 
parameter to CARRIER_OFF in the PLS_CARRIER.indication primitive of the PLS service interface, 
allowing the MAC to start transmitting again. This delay is provided to allow the link partner to prepare for 
normal operation. This delay has a PHY dependent default value but this value can be adjusted using the 
Data Link Layer capabilities defined in 78.4.
78.1.3.2 LPI detect function
In the absence of LPI, indicated by an encoding other than “Assert LPI” on the receive xMII, the LPI detect 
function maps the receive xMII signals to the PLS service interface as under normal conditions.
At the start of LPI, indicated by the transition from normal interframe encoding to the “Assert LPI” 
encoding on the receive xMII, the LPI detect function continues to indicate idle on the PLS service interface, 
but sets LP_IDLE.indication(LPI_INDICATION) to ASSERT.
At the end of LPI, indicated by the transition from the “Assert LPI” encoding to any other encoding on the 
receive xMII, LP_IDLE.indication(LPI_INDICATION) is set to DEASSERT and the RS receive function 
resumes normal decode operation.
78.1.3.3 PHY LPI operation
The following provides an overview of PHY LPI operation. The specification of PHY LPI operation can be 
found in the respective PHY clauses (see Table 78–1).
78.1.3.3.1 PHY LPI transmit operation
When the start of “Assert LPI” encoding on the xMII is detected, the PHY signals sleep to its link partner to 
indicate that the local transmitter is entering LPI mode.
The EEE capability in most PHYs requires the local PHY transmitter to go quiet after sleep is signaled.
In the 1000BASE-T LPI mode, the local PHY transmitter goes quiet only after the local PHY signals sleep 
and receives a sleep signal from the remote PHY. If the remote PHY chooses not to signal LPI, then neither 
PHY can go into a low power mode; however, LPI requests are passed from one end of the link to the other 
regardless and system energy savings can be achieved even if the PHY link does not go into a low power 
mode.
The transmit function of the local PHY is enabled periodically to transmit refresh signals that are used by the 
link partner to update adaptive filters and timing circuits in order to maintain link integrity.
This quiet-refresh cycle continues until the reception of the normal interframe encoding on the xMII. The 
transmit function in the PHY communicates this to the link partner by sending a wake signal for a predefined 
period of time. The PHY then enters the normal operating state.


Figure 78–3 illustrates general principles of the EEE-capable transmitter operation.
No data frames are lost or corrupted during the transition to or from the LPI mode.
Except for BASE-T, for PHYs with an operating speed of 25 Gb/s or greater that implement the optional 
EEE capability, two modes of LPI operation may be supported: deep sleep and fast wake. Deep sleep refers 
to the mode for which the transmitter ceases transmission during Low Power Idle (as shown in Figure 78–3) 
and is equivalent to the only mechanism defined for PHYs with an operating speed of 10 Gb/s or below. 
Deep sleep support is optional for PHYs with an operating speed of 25 Gb/s or greater that implement EEE 
with the exception of the PHYs noted in Table 78–1 that do not support deep sleep. Fast wake refers to the 
mode for which the transmitter continues to transmit signals during Low Power Idle so that the receiver can 
resume operation with a shorter wake time (as shown in Figure 78–4). For transmit, other than the PCS 
encoding LPI, there is no difference between fast wake and normal operation. Except for BASE-T PHYs, 
fast wake support is mandatory for PHYs with an operating speed of 25 Gb/s or greater that implement EEE.
78.1.3.3.2 PHY LPI receive operation
In the receive direction, entering the LPI mode is triggered by the reception of a sleep signal from the link 
partner, which indicates that the link partner is about to enter the LPI mode. After sending the sleep signal, 
the link partner ceases transmission if not in fast wake mode. When the receiver detects the sleep signal, the 
local PHY indicates “Assert LPI” on the xMII and the local receiver can disable some functionality to 
reduce power consumption.
If not in fast wake mode the link partner periodically transmits refresh signals that are used by the local PHY 
to update adaptive coefficients and timing circuits. This quiet-refresh cycle continues until the link partner 
Figure 78–3—Overview of EEE LPI operation
Active
Sleep
Refresh
Refresh
Active
Wake
Active
Active
Low-Power Idle
Quiet
Quiet
Quiet
Ts
Tq
Tr
Figure 78–4—Overview of fast wake operation
Active
Fast wake
signaling
Idle
(or wake)
Physical Layer signaling continues with higher layer functions suspended during fast wake signaling
Active
NOTE—Fast wake signaling continually indicates LPI in a normally constituted data stream.
WARNING
The signaling in deep sleep operation precludes transparent mapping of the link over 
Optical Transport Networks. Only fast wake operation should be enabled for any link 
that is intended for transparent OTN mapping.


initiates transition back to normal mode by transmitting the wake signal for a predetermined period of time 
controlled by the LPI assert function in the RS. This allows the local receiver to prepare for normal 
operation and transition from the “Assert LPI” encoding to the normal interframe encoding on the xMII. 
After a system specified recovery time, the link supports the nominal operational data rate.
78.1.4 PHY types optionally supporting EEE
EEE defines a low power mode of operation for the IEEE 802.3 PHYs and interfaces listed in Table 78–1. 
The table also lists the clauses associated with each PHY or sublayer. Normative requirements for the EEE 
capability for each PHY type and interface are in the associated clauses.
Table 78–1—Clauses associated with each PHY or interface type 
PHY or interface type
Clause
10BASE-Te
10BASE-T1L
100BASE-TX
24, 25
1000BASE-KX
70, 36
1000BASE-T1
1000BASE-RHC
1000BASE-RHA
1000BASE-RHB
1000BASE-T
2.5GBASE-KX
127, 128
2.5GBASE-T1
2.5GBASE-T
5GBASE-KR
129, 130
5GBASE-T1
5GBASE-T
XGXS (XAUI)
47, 48
10GBASE-KX4
71, 48
10GBASE-KR
72, 51, 49, 74
10GBASE-T1
10GBASE-T
25GAUIa
109A
25GBASE-KR-S
74, 107, 109, 111
25GBASE-KR
74, 107, 108, 109, 111
25GBASE-CR-S
74, 107, 109, 110
25GBASE-CR
74, 107, 108, 109, 110
25GBASE-T
25GBASE-SRb
107, 108, 109, 112


25GBASE-BR10b
25GBASE-LRb
107, 108, 109, 114
25GBASE-BR20b
25GBASE-BR40b
25GBASE-ERb
107, 108, 109, 114
XLAUIa
83A
40GBASE-KR4
82, 83, 84, 74
40GBASE-CR4
82, 83, 85, 74
40GBASE-T
40GBASE-SR4b
82, 83, 86
40GBASE-FRb
82, 83, 89
40GBASE-LR4b
82, 83, 87
40GBASE-ER4b
82, 83, 87
50GBASE-KRb
133, 134, 137
50GBASE-CRb
133, 134, 136
50GBASE-SRb
133, 134, 138
50GBASE-FRb
133, 134, 139
50GBASE-BR10b
50GBASE-LRb
133, 134, 139
50GBASE-BR20b
50GBASE-BR40b
50GBASE-ERb
133, 134, 139
CAUI-10a
83A
CAUI-4a
83D
100GBASE-KR4
82, 83, 91, 93
100GBASE-KP4
82, 91, 94
100GBASE-KR2b
82, 135, 137
100GBASE-CR2b
82, 135, 136
100GBASE-CR4
82, 83, 91, 92
100GBASE-CR10
82, 83, 85, 74
100GBASE-SR4b
82, 83, 91, 95
100GBASE-SR2b
82, 135, 138
100GBASE-SR10b
82, 83, 86
100GBASE-DRb
82, 135, 140
Table 78–1—Clauses associated with each PHY or interface type (continued)
PHY or interface type
Clause


78.2 LPI mode timing parameters description
Ts
The period of time that the PHY transmits the sleep signal before turning all transmitters 
off
Tq
The period of time that the PHY remains quiet before sending the refresh signal
Tr
Duration of the refresh signal
Tphy_prop_tx
The propagation delay of a given unit of data from the xMII to the MDI
Tphy_prop_rx
The propagation delay of a given unit of data from the MDI to the xMII
100GBASE-FR1b
82, 135, 140
100GBASE-LR4b
82, 83, 88
100GBASE-LR1b
82, 135, 140
100GBASE-ER4b
82, 83, 88
100GBASE-ZRb
82, 83, 91, 135, 152, 153, 154
200GBASE-KR4b
119, 120, 137
200GBASE-CR4b
119, 120, 136
200GBASE-SR4b
119, 120, 138
200GBASE-DR4b
119, 120, 121
200GBASE-FR4b
119, 120, 122
200GBASE-LR4b
119, 120, 122
200GBASE-ER4b
119, 120, 122
400GBASE-SR16b
119, 120, 123
400GBASE-SR8b
119, 120, 138
400GBASE-SR4.2b
119, 120, 150
400GBASE-DR4b
119, 120, 124
400GBASE-FR8b
119, 120, 122
400GBASE-FR4b
119, 120, 151
400GBASE-LR4-6b
119, 120, 151
400GBASE-LR8b
119, 120, 122
400GBASE-ER8b
119, 120, 122
a25GAUI/XLAUI/CAUI-n shutdown is supported only when deep 
sleep is enabled for the associated PHY.
bThe deep sleep mode of EEE is not supported for this PHY.
Table 78–1—Clauses associated with each PHY or interface type (continued)
PHY or interface type
Clause


Tphy_shrink_tx
Transmitter shrinkage time, defined as the absolute time difference between the follow-
ing two timing parameters: 
—Delay between a transition from the “Assert LPI” to “Normal Idle” at the xMII and 
the corresponding start of the wake signal at the MDI
—Tphy_prop_tx
Tphy_shrink_rx
Receiver shrinkage time, defined as the absolute time difference between the following 
two timing parameters:
—Delay between start of the wake signal at the MDI and the corresponding transition 
from “Assert LPI” to “Normal Idle” at the xMII
—Tphy_prop_rx
Tw_phy
Parameter employed by the system that corresponds to the behavior of the PHY. It is the 
period of time between reception of an IDLE signal on the xMII and when the first data 
codewords are permitted on the xMII. The wake time of a compliant PHY does not 
exceed Tw_phy (min).
Tw_sys_tx
Parameter employed by the system that corresponds to its requirements. It is the longest 
period of time the system has to wait between a request to transmit and its readiness to 
transmit.
Tw_sys_rx
Parameter employed by the system that corresponds to its requirements. It is the mini-
mum time required by the system between a request to wake and its readiness to receive 
data.
Table 78–2 summarizes three key EEE parameters (Ts, Tq, and Tr) for supported PHYs. 
Table 78–2—Summary of the key EEE parameters for supported PHYs
or interfaces 
PHY or interface 
type
Ts 
s)
Tq
s)
Tr 
s)
Min
Max
Min
Max
Min
Max
10BASE-T1L 
6 000
6 000
100BASE-TX 
20 000
22 000
1000BASE-KX
19.9
20.1
2 500
2 600
19.9
20.1
1000BASE-T1
3.6
3.6
84.95
84.97
1.44
1.44
1000BASE-RHC
1000BASE-RHA
1000BASE-RHB
23.52
23.52
1.3
1.3
1000BASE-T
20 000
24 000
218.2
2.5GBASE-KX
19.9
20.1
2 500
2 600
19.9
20.1
2.5GBASE-T1
10.24
10.24
121.6
121.6
1.28
1.28
2.5GBASE-T
11.52
12.8
76.8
76.8
5.12
5.12
5GBASE-KR
4.9
5.1
1 700
1 800
16.9
17.5
5GBASE-T1
5.12
5.12
60.8
60.8
0.64
0.64
5GBASE-T
5.76
6.4
38.4
38.4
2.56
2.56


Figure 78–5 illustrates the relationship between the LPI mode timing parameters and the minimum system 
wake time.
78.3 Capabilities Negotiation
The EEE capability shall be advertised during the Auto-Negotiation stage, except for PHYs that only 
support fast wake operation or PHYs that exchange EEE capability during link training. Auto-Negotiation 
provides a linked device with the capability to detect the abilities (modes of operation) supported by the 
device at the other end of the link, determine common abilities, and configure for joint operation. Auto-
Negotiation is performed at power up, on command from management, due to link failure, or due to user 
intervention. Fast wake capability shall be advertised using L2 protocol frames as described in 78.4. The 
EEE capability for 2.5GBASE-T and 5GBASE-T shall be advertised during link training according to 
126.4.2.5.10. The EEE capability for 2.5GBASE-T1, 5GBASE-T1, and 10GBASE-T1 shall be advertised 
during link training according to 149.4.2.4.10. The EEE capability for 25GBASE-T and 40GBASE-T shall 
be advertised during link training according to 113.4.2.5.10.
During Auto-Negotiation, both link partners indicate their EEE capabilities. EEE is supported only if during 
Auto-Negotiation both the local device and link partner advertise the EEE capability for the resolved PHY 
type. If EEE is not supported, all EEE functionality is disabled and the LPI client does not assert LPI. EEE 
deep sleep operation shall not be enabled unless both the local device and link partner advertise deep sleep 
capability during Auto-Negotiation for the resolved PHY type. If EEE is supported by both link partners for 
the negotiated PHY type, then the EEE function can be used independently in either direction. The same 
applies to 2.5GBASE-T, 2.5GBASE-T1, 5GBASE-T, 5GBASE-T1, 10GBASE-T1, 25GBASE-T, and 
XGXS (XAUI)
19.9
20.1
2 500
2 600
19.9
20.1
10GBASE-KX4
19.9
20.1
2 500
2 600
19.9
20.1
10GBASE-KR
4.9
5.1
1 700
1 800
16.9
17.5
10GBASE-T1
2.56
2.56
30.4
30.4
0.32
0.32
10GBASE-T
2.88
3.2
39.68
39.68
1.28
1.28
25GBASE-KR-S
25GBASE-KR
25GBASE-CR-S
25GBASE-CR
4.9
5.1
1 700
1 800
16.9
17.5
25GBASE-T
0.768
0.896
15.616
15.616
0.768
0.768
40GBASE-KR4
40GBASE-CR4
0.9
1.1
1 700
1 800
5.9
6.5
40GBASE-T
0.48
0.56
9.76
9.76
0.48
0.48
100GBASE-KR4
100GBASE-KP4
100GBASE-CR4
100GBASE-CR10
0.9
1.1
1 700
1 800
5.9
6.5
Table 78–2—Summary of the key EEE parameters for supported PHYs
or interfaces (continued)
PHY or interface 
type
Ts 
s)
Tq
s)
Tr 
s)
Min
Max
Min
Max
Min
Max


40GBASE-T except the EEE capabilities are exchanged and resolved during link training instead of during 
Auto-Negotiation.
Additional capabilities and settings using L2 protocol frames, including the adjustment of the Tw_sys_tx
parameter, are described in 78.4.
78.4 Data Link Layer capabilities
Additional capabilities and settings are supported using frames based on the IEEE 802.3 Organizationally 
Specific TLVs are defined in Annex F of IEEE Std 802.1AB-2009. Devices that require longer wake-up 
times prior to being able to accept data on their receive paths may use the Data Link Layer capabilities 
defined in this subclause to negotiate for extended system wake-up times from the transmitting link partner. 
This mechanism may allow for more or less aggressive energy saving modes.
The Data Link Layer capabilities shall be implemented for devices with an operating speed equal to or 
greater than 10 Gb/s and may be implemented for all other devices. The use of the EEE Fast Wake TLV shall 
be interpreted as an indication that the device supports EEE fast wake operation, regardless of the capability 
advertised during the Auto-Negotiation stage. A device shall not indicate deep sleep capability using the 
EEE Fast Wake TLV unless both the local device and link partner advertise deep sleep capability during 
Auto-Negotiation for the resolved PHY type.
	
	



 	







	
	


















	

Figure 78–5—LPI mode timing parameters and their relationship to 
minimum system wake time
Tw_sys_tx (min)
= Tw_sys_rx (min) + Tphy_shrink_tx (max)  + Tphy_shrink_rx (max)
Tw_phy (min)
= Tphy_wake (min) + Tphy_shrink_tx
Tw_sys_res (min) is greater of Tw_sys_tx (min) and Tw_phy (min)
Tphy_shrink_tx (max)
=  (Tphy_wake_tx (max) – Tphy_prop_tx (min))
Tphy_shrink_rx (max)
=  (Tphy_wake_rx(max) – Tphy_prop_rx (min))

where
Tphy_wake_tx
= xMII start of wake to MDI start of wake delay
Tphy_prop_tx
= xMII to MDI data propagation delay
Tphy_wake_rx
= MDI start of wake to xMII start of wake delay
Tphy_prop_rx
= MDI to xMII data propagation delay
Tphy_wake
= Minimum wake duration required by PHY


Implementations that use the Data Link Layer capabilities shall comply with all mandatory parts of 
IEEE Std 802.1AB-2009; shall support the EEE Type, Length, Value (TLV) defined in 79.3.5; timing 
requirement in 78.4.1; and shall support the control state diagrams defined in 78.4.2. Devices with an 
operating speed equal to or greater than 40 Gb/s shall support EEE Fast Wake TLV as defined in 79.3.6.
The Data Link Layer capabilities are described from a unidirectional perspective on the link between 
transmitting and receiving link partners. For duplex EEE links that implement the Data Link Layer 
capabilities, each link partner shall implement the TLV, control and state diagrams for a transmitter as well 
as a receiver.
For purposes of Data Link Layer capabilities, all values that are negotiated and/or exchanged that have a 
fractional value shall be rounded up to the nearest integer number in microseconds.
78.4.1 Data Link Layer capabilities timing requirements
An EEE link partner shall send an LLDPDU containing an EEE TLV within 10 s of the Link Layer 
capability exchange being enabled when both the variables dll_enabled and dll_ready are asserted.
An LLDPDU containing an EEE TLV with an updated value for the “Echo Transmit Tw_sys_tx” field shall be 
sent within 10 s of receipt of an LLDPDU containing an EEE TLV where the value of “Transmit Tw_sys_tx” 
field is different from the previously communicated value.
An LLDPDU containing an EEE TLV with an updated value for the “Echo Receive Tw_sys_tx” field shall be 
sent within 10 s of receipt of an LLDPDU containing an EEE TLV where the value of “Receive Tw_sys_tx” 
field is different from the previously communicated value.
78.4.2 Control state diagrams
The control state diagrams for an EEE transmitting link partner and an EEE receiving link partner specify 
the externally observable behavior of an EEE transmitting link partner and an EEE receiving link partner 
implementing Data Link Layer capabilities respectively. EEE transmitting link partners implementing Data 
Link Layer capabilities shall provide the behavior of the state diagram as shown in Figure 78–6. EEE 
receiving link partners implementing Data Link Layer capabilities shall provide the behavior of the state 
diagram as shown in Figure 78–7.
78.4.2.1 Conventions
The body of this subclause is composed of state diagrams, including the associated definitions of variables, 
constants, and functions. Should there be a discrepancy between a state diagram and descriptive text, the 
state diagram prevails.
The notation used in the state diagrams follows the conventions of state diagrams as described in 21.5.
78.4.2.2 Constants
PHY WAKE VALUE
Integer (2 octets wide) representing the Tw_sys_tx (min) defined for the PHY that is in use for the 
link. This parameter should be rounded up to the nearest integer number when it is calculated and 
examined according to 78.2 and Table 78–4.


78.4.2.3 Variables
Unless otherwise specified, all integers are assumed to be 2 octets wide.
LocTxSystemValue
Integer that indicates the value of Tw_sys_tx that the local system can support. This value is updated 
by the EEE DLL Transmitter state diagram. This variable maps into the aLldpXdot3LocTxTwSys 
attribute.
RemTxSystemValueEcho
Integer that indicates the value Transmit Tw_sys_tx echoed back by the remote system. This value 
maps from the aLldpXdot3RemTxTwSysEcho attribute.
LocRxSystemValue
Integer that indicates the value of Tw_sys_tx that the local system requests from the remote system. 
This value is updated by the EEE Receiver L2 state diagram. This variable maps into the 
aLldpXdot3LocRxTwSys attribute.
RemRxSystemValueEcho
Integer that indicates the value of Receive Tw_sys_tx echoed back by the remote system. This value 
maps from the aLldpXdot3RemRxTwSysEcho attribute.
LocFbSystemValue
Integer that indicates the value of fallback Tw_sys_tx that the local system requests from the remote 
system. This value is updated by the local system software.
RemTxSystemValue
Integer that indicates the value of Tw_sys_tx that the remote system can support. This value maps 
from the aLldpXdot3RemTxTwSys attribute.
LocTxSystemValueEcho
Integer that indicates the remote system’s Transmit Tw_sys_tx that was used by the local system to 
compute the Tw_sys_tx that it wants to request from the remote system. This value maps into the 
aLldpXdot3LocTxTwSysEcho attribute.
RemRxSystemValue
Integer that indicates the value of Tw_sys_tx that the remote system requests from the local system. 
This value maps from the aLldpXdot3RemRxTwSys attribute.
LocRxSystemValueEcho
Integer that indicates the remote systems Receive Tw_sys_tx that was used by the local system to 
compute the Tw_sys_tx that it can support. This value maps into the aLldpXdot3LocRxTwSysEcho 
attribute.
LocResolvedTxSystemValue
Integer that indicates the current Tw_sys_tx supported by the local system.
LocResolvedRxSystemValue
Integer that indicates the current Tw_sys_tx supported by the remote system.


LPI_FW
Boolean variable controlling the wake mode for the LPI transmit and receive functions as defined 
in 82.2.19.2.2.
LocTxSystemFW
Boolean variable that indicates the state of LPI_FW that the local transmit system can support. 
This value is updated by the EEE DLL Transmit fast wake state diagram. This variable maps into 
the aLldpXdot3LocTxFw attribute.
RemTxSystemFWEcho
Boolean variable that indicates the state of transmit LPI_FW echoed back by the remote system. 
This value maps from the aLldpXdot3RemTxFwEcho attribute.
LocRxSystemFW
Boolean variable that indicates the state of LPI_FW that the local receive system requests from the 
remote system. This value is updated by the EEE DLL Receive fast wake state diagram. This vari-
able maps into the aLldpXdot3LocRxFw attribute.
RemRxSystemFWEcho
Boolean variable that indicates the state of receive LPI_FW echoed back by the remote system. 
This value maps from the aLldpXdot3RemRxFwEcho attribute.
RemTxSystemFW
Boolean variable that indicates the LPI_FW that the remote transmit system requests from the 
local system. This value maps from the aLldpXdot3RemTxFw attribute.
LocTxSystemFWEcho
Boolean variable that indicates the remote system’s transmit LPI_FW that was used by the local 
system to decide the LPI_FW that it wants to request from the remote system. This value maps into 
the aLldpXdot3LocTxFwEcho attribute.
RemRxSystemFW
Boolean variable that indicates the LPI_FW that the remote receive system requests from the local 
system. This value maps from the aLldpXdot3RemRxFw attribute.
LocRxSystemFWEcho
Boolean variable that indicates the remote system’s receive LPI_FW that was used by the local 
system to decide the LPI_FW that it can support. This value maps into the aLldpXdot3LocRxF-
wEcho attribute.
LocResolvedTxSystemFW
Boolean that indicates the current LPI_FW supported by the local system.
LocResolvedRxSystemFW
Boolean variable that indicates the current LPI_FW supported by the remote system.
TempTxFW
 Boolean variable used to store the value of LPI_FW.
TempRxFW
Boolean variable used to store the value of LPI_FW.


local_system_FW_change
An implementation-specific control variable that indicates that the local system wants to change 
either the Transmit LPI_FW or the Receive LPI_FW.
NEW_TX_FW
Boolean variable that indicates the value of transmit LPI_FW that the local system can support.
NEW_RX_FW
Boolean variable that indicates the value of receive LPI_FW that the local system wants the remote 
system to support. 
TempTxVar
 Integer used to store the value of Tw_sys_tx.
TempRxVar
Integer used to store the value of Tw_sys_tx.
local_system_change
An implementation specific control variable that indicates that the local system wants to change 
either the Transmit Tw_sys_tx or the Receive Tw_sys_tx.
tx_dll_ready
Data Link Layer ready: This variable indicates that the tx system initialization is complete and is 
ready to update/receive LLDPDU containing EEE TLV. This variable is updated by the local 
system software.
rx_dll_ready
Data Link Layer ready: This variable indicates that the rx system initialization is complete and is 
ready to update/receive LLDPDU containing EEE TLV. This variable is updated by the local 
system software.
NEW_TX_VALUE
Integer that indicates the value of Tw_sys_tx that the local system can support.
NEW_RX_VALUE
Integer that indicates the value of Tw_sys_tx that the local system wants the remote system to 
support. 


A summary of cross-references between the EEE object class attributes and the transmit and receive control 
state diagrams, including the direction of the mapping, is provided in Table 78–3.
78.4.2.4 Functions
examine_Tx_change
This function computes the new value of Tw_sys_tx that the local system can support when there is 
as updated request from the remote system or if local system conditions require a change in the 
value of the presently supported Tw_sys_tx. 
examine_Rx_change
This function computes the new value of Tw_sys_tx that the local system wants the remote system to 
support. This function is called when the remote system wants to change its presently allocated 
Table 78–3—Attribute to state diagram variable cross-reference 
Entity
Object class
Attribute
Mapping
State diagram variable
TX
oLldpXdot3Loc-
SystemsGroup
aLldpXdot3LocTxTwSys

LocTxSystemValue
aLldpXdot3LocRxTwSysEcho

LocRxSystemValueEcho
aLldpXdot3LocDllEnabled

tx_dll_enabled
aLldpXdot3LocTxDllReady

tx_dll_ready
aLldpXdot3LocTxFw

LocTxSystemFW
aLldpXdot3LocRxFwEcho

LocRxSystemFWEcho
oLldpXdot3Rem-
SystemsGroup
aLldpXdot3RemRxTwSys

RemRxSystemValue
aLldpXdot3RemTxTwSysEcho

RemTxSystemValueEcho
aLldpXdot3RemRxFw

RemRxSystemFW
aLldpXdot3RemTxFwEcho

RemTxSystemFWEcho
RX
oLldpXdot3Loc-
SystemsGroup
aLldpXdot3LocRxTwSys

LocRxSystemValue
aLldpXdot3LocTxTwSysEcho

LocTxSystemValueEcho
aLldpXdot3LocFbTwSys

LocFbSystemValue
aLldpXdot3LocDllEnabled

rx_dll_enabled
aLldpXdot3LocRxDllReady

rx_dll_ready
aLldpXdot3LocRxFw

LocRxSystemFW
aLldpXdot3LocTxFwEcho

LocTxSystemFWEcho
oLldpXdot3Rem-
SystemsGroup
aLldpXdot3RemTxTwSys

RemTxSystemValue
aLldpXdot3RemRxTwSysEcho

RemRxSystemValueEcho
aLldpXdot3RemTxFw

RemTxSystemFW
aLldpXdot3RemRxFwEcho

RemRxSystemFWEcho


Tw_sys_tx or if local system conditions require a change in the value of Tw_sys_tx presently 
supported by the remote system.
examine_TxFW_change
This function decides if the new value of LPI_FW is acceptable by the local transmit system when 
there is an updated request from the remote system or if local system conditions require a change 
in the value of the presently supported LPI_FW.
examine_RxFW_change
This function decides if the new value of LPI_FW is acceptable by the local receive system when 
there is an updated request from the remote system or if local system conditions require a change 
in the value of the presently supported LPI_FW.
78.4.2.5 State diagrams
Control for placing data on the medium rests with the transmitting side, hence Tw_sys_tx is enforced by the 
transmitter. For a given path between link partners (i.e., a transmitter and its associated receiver), the 
transmitting link partner shall wait for the time indicated by the Transmit Tw_sys_tx after deasserting LPI (at 
the xMII) before sending data frames. The receiving link partner shall be ready to accept data based on its 
echoed value of Transmit link partner's Tw_sys_tx. This ensures that the link partners transition out of LPI 
mode and receive frames without loss or corruption.
The general state change procedure for transmitter is shown in Figure 78–6.


SYSTEM REALLOCATION
!local_system_change * 
(RemRxSystemValue  TempRxVar) * 
(LocTxSystemValue = RemTxSystemValueEcho)
local_system_change
RUNNING
REMOTE CHANGE
 
LOCAL CHANGE
LocTxSystemValue  PHY WAKE VALUE
RemTxSystemValueEcho  PHY WAKE VALUE
RemRxSystemValue  PHY WAKE VALUE
LocRxSystemValueEcho  PHY WAKE VALUE
LocResolvedTxSystemValue  PHY WAKE VALUE
TempRxVar  PHY WAKE VALUE
INITIALIZE
!tx_dll_enabled + 
!tx_dll_ready
Figure 78–6—EEE DLL Transmitter state diagram
tx_dll_ready
TempRxVar  RemRxSystemValue
examine_Tx_change
TempRxVar  RemRxSystemValue
examine_Tx_change
UCT 
TX UPDATE
LocTxSystemValue  NEW_TX_VALUE
(LocTxSystemValue = 
RemTxSystemValueEcho) + 
(NEW_TX_VALUE < LocTxSystemValue)
(NEW_TX_VALUE LocTxSystemValue) * 
(LocTxSystemValue  RemTxSystemValueEcho) 
UCT
MIRROR UPDATE
LocRxSystemValueEcho  TempRxVar
UCT
(NEW_TX_VALUE 
LocResolvedTxSystemValue) +
(NEW_TX_VALUE  TempRxVar)
(NEW_TX_VALUE < LocResolvedTxSystemValue)
* (NEW_TX_VALUE < TempRxVar)
LocResolvedTxSystemValue  NEW_TX_VALUE


The general state change procedure for receiver is shown in Figure 78–7.
Figure 78–7—EEE DLL Receiver state diagram
UPDATE MIRROR
LocTxSystemValueEcho  TempTxVar
local_system_change +
RemTxSystemValue  TempTxVar
RUNNING
RX UPDATE
 
CHANGE
!rx_dll_enabled + 
!rx_dll_ready
rx_dll_ready
LocRxSystemValue  NEW_RX_VALUE
TempTxVar  RemTxSystemValue
examine_Rx_change
SYSTEM REALLOCATION
LocResolvedRxSystemValue  NEW_RX_VALUE
(NEW_RX_VALUE  
LocResolvedRxSystemValue) +
(NEW_RX_VALUE  TempTxVar)
LocRxSystemValue  PHY WAKE VALUE
RemRxSystemValueEcho  PHY WAKE VALUE
RemTxSystemValue  PHY WAKE VALUE
LocTxSystemValueEcho  PHY WAKE VALUE
LocResolvedRxSystemValue  PHY WAKE VALUE
LocFbSystemValue  PHY WAKE VALUE
TempTxVar  PHY WAKE VALUE
INITIALIZE
(NEW_RX_VALUE >
LocResolvedRxSystemValue) *
(NEW_RX_VALUE > TempTxVar)
UCT
UCT
UCT


The general state change procedure for transmitter fast wake is shown in Figure 78–8.
SYSTEM REALLOCATION
!local_system_FW_change * 
(RemRxSystemFW  TempRxFW) * 
(LocTxSystemFW = RemTxSystemFWEcho)
local_system_FW_change
RUNNING
REMOTE CHANGE
 
LOCAL CHANGE
LocTxSystemFW  TRUE
RemTxSystemFWEcho  TRUE
RemRxSystemFW  TRUE
LocRxSystemFWEcho  TRUE
LocResolvedTxSystemFW  TRUE
TempRxFW  TRUE
INITIALIZE
 !tx_dll_ready
Figure 78–8—EEE DLL Transmitter fast wake state diagram
tx_dll_ready
TempRxFW  RemRxSystemFW
examine_TxFW_change
TempRxFW  RemRxSystemFW
examine_TxFW_change
UCT 
TX UPDATE
LocTxSystemFW  NEW_TX_FW
(LocTxSystemFW = 
RemTxSystemFWEcho)
(NEW_TX_FW LocTxSystemFW) * 
(LocTxSystemFW  RemTxSystemFWEcho) 
UCT
MIRROR UPDATE
LocRxSystemFWEcho  TempRxFW
UCT
(NEW_TX_FW 
LocResolvedTxSystemFW) +
(NEW_TX_FW  TempRxFW)
(NEW_TX_FW = LocResolvedTxSystemFW)
* (NEW_TX_FW = TempRxFW) 
LocResolvedTxSystemFW  NEW_TX_FW


The general state change procedure for receiver fast wake is shown in Figure 78–9.
78.4.3 State change procedure across a link
The transmitting and receiving link partners utilize the LLDP mechanism to advertise their various attributes 
to the other entity.
The initial Tw_sys_tx defaults governing the EEE operation of the link default to the wake values required by 
the PHYs. This provides for EEE operation and functionality on initialization and prior to the exchange and 
processing of the TLVs.
Figure 78–9—EEE DLL Receiver fast wake state diagram
UPDATE MIRROR
LocTxSystemFWEcho  TempTxFW
local_system_FW_change +
RemTxSystemFW  TempTxFW
RUNNING
RX UPDATE
 
CHANGE
 !rx_dll_ready
rx_dll_ready
LocRxSystemFW  NEW_RX_FW
TempTxFW  RemTxSystemFW
examine_RxFW_change
SYSTEM REALLOCATION
LocResolvedRxSystemFW  NEW_RX_FW
(NEW_RX_FW  LocResolvedRxSystemFW) +
(NEW_RX_FW  TempTxFW)
LocRxSystemFW  PHY WAKE VALUE
RemRxSystemFWEcho  PHY WAKE VALUE
RemTxSystemFW  PHY WAKE VALUE
LocTxSystemFWEcho  PHY WAKE VALUE
LocResolvedRxSystemFW  PHY WAKE VALUE
TempTxFW  PHY WAKE VALUE
INITIALIZE
(NEW_RX_FW = 
LocResolvedRxSystemFW) *
(NEW_RX_FW = TempTxFW)
UCT
UCT
UCT


The receiving link partner may request a new Tw_sys_tx value through the aLldpXdot3LocRxTwSys 
(30.12.2.1.64) attribute in the LldpXdot3LocSystemsGroup managed object class (30.12.2). The request 
appears to the transmitting link partner as a change to the aLldpXdot3RemRxTwSys (30.12.3.1.62) attribute 
in the LldpXdot3RemSystemsGroup managed (30.12.3) object class. The transmitting link partner responds 
to its receiving partner’s request through the aLldpXdot3LocTxTwSys (30.12.2.1.62) attribute in the 
LldpXdot3LocSystemsGroup managed object class (30.12.2). The transmitting link partner also copies the 
value of the aLldpXdot3RemRxTwSys (30.12.3.1.62) attribute in the LldpXdot3RemSystemsGroup 
managed (30.12.3) object class to the aLldpXdot3LocRxTwSysEcho (30.12.2.1.65) attribute in the 
LldpXdot3LocSystemsGroup managed object class (30.12.2).
The transmitting link partner may advertise new value of Tw_sys_tx through the aLldpXdot3LocTxTwSys 
(30.12.2.1.62) attribute in the LldpXdot3LocSystemsGroup managed object class (30.12.2). This appears to 
the receiving link partner as a change to the aLldpXdot3RemTxTwSys (30.12.3.1.60) attribute in the 
LldpXdot3RemSystemsGroup managed (30.12.3) object class. The receiving link partner responds to a 
transmitter’s 
request 
through 
the 
aLldpXdot3LocRxTwSys 
(30.12.2.1.64) 
attribute 
in 
the 
LldpXdot3LocSystemsGroup managed object class (30.12.2). The receiving link partner also copies the 
value of the aLldpXdot3RemTxTwSys (30.12.3.1.60) attribute in the LldpXdot3RemSystemsGroup 
managed (30.12.3) object class to the aLldpXdot3LocTxTwSysEcho (30.12.2.1.63) attribute in the 
LldpXdot3LocSystemsGroup managed object class (30.12.2). This appears to the transmitting link partner 
as 
a 
change 
to 
the 
aLldpXdot3RemTxTwSysEcho 
(30.12.3.1.61) 
attribute 
in 
the 
LldpXdot3RemSystemsGroup managed (30.12.3).
The state diagrams in Figure 78–6 and Figure 78–7 describe the preceding behavior.
The default state of Fast_Wake_Enable is TRUE for all PHYs that support the function. This provides for 
EEE operation and functionality on initialization and prior to the exchange and processing of the TLVs.
The receiving link partner may request a change of Fast_Wake_Enable through the aLldpXdot3LocRxFw 
(30.12.2.1.72) attribute in the LldpXdot3LocSystemsGroup managed object class (30.12.2). The request 
appears to the transmitting link partner as a change to the aLldpXdot3RemRxFw (30.12.3.1.26) attribute in 
the LldpXdot3RemSystemsGroup managed (30.12.3) object class. The transmitting link partner responds to 
its receiving partner's request through the aLldpXdot3LocTxFw (30.12.2.1.70) attribute in the 
LldpXdot3LocSystemsGroup managed object class (30.12.2). The transmitting link partner also copies the 
value of the aLldpXdot3RemRxFw (30.12.3.1.26) attribute in the LldpXdot3RemSystemsGroup managed 
(30.12.3) 
object 
class 
to 
the 
aLldpXdot3LocRxFwEcho 
(30.12.2.1.73) 
attribute 
in 
the 
LldpXdot3LocSystemsGroup managed object class (30.12.2).
The transmitting link partner may advertise a change of Fast_Wake_Enable through the 
aLldpXdot3LocTxFw (30.12.2.1.70) attribute in the LldpXdot3LocSystemsGroup managed object class 
(30.12.2). This appears to the receiving link partner as a change to the aLldpXdot3RemTxFw (30.12.3.1.24) 
attribute in the LldpXdot3RemSystemsGroup managed (30.12.3) object class. The receiving link partner 
responds to a transmitter's request through the aLldpXdot3LocRxFw (30.12.2.1.72) attribute in the 
LldpXdot3LocSystemsGroup managed object class (30.12.2). The receiving link partner also copies the 
value of the aLldpXdot3RemTxFw (30.12.3.1.24) attribute in the LldpXdot3RemSystemsGroup managed 
(30.12.3) 
object 
class 
to 
the 
aLldpXdot3LocTxFwEcho 
(30.12.2.1.71) 
attribute 
in 
the 
LldpXdot3LocSystemsGroup managed object class (30.12.2). This appears to the transmitting link partner 
as a change to the aLldpXdot3RemTxFwEcho (30.12.3.1.25) attribute in the LldpXdot3RemSystemsGroup 
managed (30.12.3).
The state diagrams in Figure 78–8 and Figure 78–9 describe the preceding behavior.


78.4.3.1 Transmitting link partner’s state change procedure across a link
A transmitting link partner is said to be in sync with the receiving link partner if the presently advertised 
value of Transmit Tw_sys_tx and the corresponding echoed value are equal. 
During normal operation, the transmitting link partner is in the RUNNING state. If the transmitting link 
partner wants to initiate a change to the presently resolved value of Tw_sys_tx, the local_system_change is 
asserted and the transmitting link partner enters the LOCAL CHANGE state where NEW_TX_VALUE is 
computed. If the new value is smaller than the presently advertised value of Tw_sys_tx or if the transmitting 
link partner is in sync with the receiving link partner, then it enters TX UPDATE state. Otherwise, it returns 
to the RUNNING state. 
If the transmitting link partner sees a change in the Tw_sys_tx requested by the receiving link partner, it 
recognizes the request only if it is in sync with the transmitting link partner. The transmitting link partner 
examines the request by entering the REMOTE CHANGE state where a NEW TX VALUE is computed and 
it then enters the TX UPDATE state.
Upon entering the TX UPDATE state, the transmitter updates the advertised value of Transmit Tw_sys_tx with 
NEW_TX_VALUE. If the NEW_TX_VALUE is equal to or greater than either the resolved Tw_sys_tx value 
or the value requested by the receiving link partner then it enters the SYSTEM REALLOCATION state 
where it updates the value of resolved Tw_sys_tx with NEW_TX_VALUE. The transmitting link partner 
enters the MIRROR UPDATE state either from the SYSTEM REALLOCATION state or directly from the 
TX UPDATE state. The UPDATE MIRROR state then updates the echo for the Receive Tw_sys_tx and 
returns to the RUNNING state.
A transmitting link partner is said to be in sync with the receiving link partner if the presently advertised 
value of Transmit Fast_Wake_Enable and the corresponding echoed value are equal. 
During normal operation, the transmitting link partner is in the RUNNING state. If the transmitting link 
partner wants to initiate a change to the presently resolved value of Fast_Wake_Enable, the 
local_system_change is asserted and the transmitting link partner enters the LOCAL CHANGE state where 
NEW_TX_FW is computed. If the transmitting link partner is in sync with the receiving link partner, then it 
enters TX UPDATE state. Otherwise, it returns to the RUNNING state. 
If the transmitting link partner sees a change in the Fast_Wake_Enable requested by the receiving link 
partner, it recognizes the request only if it is in sync with the transmitting link partner. The transmitting link 
partner examines the request by entering the REMOTE CHANGE state where a NEW_TX_FW is computed 
and it then enters the TX UPDATE state.
Upon entering the TX UPDATE state, the transmitter updates the advertised value of Transmit 
Fast_Wake_Enable with NEW_TX_FW. If the NEW_TX_FW is different to either the resolved 
Fast_Wake_Enable value or the value requested by the receiving link partner then it enters the SYSTEM
 
REALLOCATION state where it updates the value of resolved Fast_Wake_Enable with NEW_TX_FW. The 
transmitting link partner enters the MIRROR UPDATE state either from the SYSTEM REALLOCATION 
state or directly from the TX UPDATE state. The UPDATE MIRROR state then updates the echo for the 
Receive Fast_Wake_Enable and returns to the RUNNING state.
78.4.3.2 Receiving link partner’s state change procedure across a link
A receiving link partner is said to be in sync with the transmitting link partner if the presently requested 
value of Receive Tw_sys_tx and the corresponding echoed value are equal.
During normal operation, the receiving link partner is in the RUNNING state. If the receiving link partner 
wants to request a change to the presently resolved value of Tw_sys_tx, the local_system_change is asserted. 


When local_system_change is asserted or when the receiving link partner sees a change in the Tw_sys_tx
advertised by the transmitting link partner, it enters the CHANGE state where NEW_RX_VALUE is 
computed. If NEW_RX_VALUE is less than either the presently resolved value of Tw_sys_tx or the presently 
advertised value by the transmitting link partner, it enters the SYSTEM REALLOCATION state where it 
updates the resolved value of Tw_sys_tx to NEW_RX_VALUE. The receiving link partner ultimately enters 
the RX UPDATE state, either from the SYSTEM REALLOCATION state or directly from the CHANGE 
state.
In the RX UPDATE state, it updates the presently requested value to NEW_RX_VALUE, then it updates the 
echo for the Transmit Tw_sys_tx in the UPDATE MIRROR state and finally goes back to the RUNNING 
state.
A receiving link partner is said to be in sync with the transmitting link partner if the presently requested 
value of Receive Fast_Wake_Enable and the corresponding echoed value are equal.
During normal operation, the receiving link partner is in the RUNNING state. If the receiving link partner 
wants to request a change to the presently resolved value of Fast_Wake_Enable, the local_system_change is 
asserted. When local_system_change is asserted or when the receiving link partner sees a change in the 
Fast_Wake_Enable advertised by the transmitting link partner, it enters the CHANGE state where 
NEW_RX_FW is computed. If NEW_RX_FW is different from either the presently resolved value of 
Fast_Wake_Enable or the presently advertised value by the transmitting link partner, it enters the SYSTEM
 
REALLOCATION state where it updates the resolved value of Fast_Wake_Enable to NEW_RX_FW. The 
receiving link partner ultimately enters the RX UPDATE state, either from the SYSTEM REALLOCATION 
state or directly from the CHANGE state.
In the RX UPDATE state, it updates the presently requested value to NEW_RX_FW, then it updates the 
echo for the Transmit Fast_Wake_Enable in the UPDATE MIRROR state and finally goes back to the 
RUNNING state.
78.5 Communication link access latency
In the full duplex mode, predictable operation of the MAC Control PAUSE operation (Clause 31, 
Annex 31B) demands that there be an upper bound on the propagation delay through the network. This 
implies that MAC, MAC Control sublayer, and PHY implementers conform to certain delay maxima, and 
that network planners and administrators conform to constraints regarding the cable topology and the 
concatenation of devices.
The EEE capability adds latency that has to be considered by the network designer. When in the LPI mode, 
the PHY link is not available immediately for transmission of data. The system has to wake it up by sending 
the normal IDLE code on the MAC interface. Following the reception of an IDLE code on the MAC interface, 
the PHY starts the wake-up process. The maximal PHY recovery time, Tw_phy is defined for each PHY.
Transmit and/or Receive wait time shrinkage can happen when Tphy_shrink_rx or Tphy_shrink_tx (as defined in 
78.1.3) are not zero. This has to be taken into consideration in designing or configuring the network.
Table 78–4 summarizes critical timing parameters for supported PHYs. These are listed here to assist the 
system designer in assessing the impact of EEE on the operation of the link.
Case-1 of the 1000BASE-T PHY applies to PHYs in Master mode. Case-2 of the 1000BASE-T PHY applies 
to PHYs in Slave mode.
NOTE—Annex K defines optional alternative terminology for “master” and “slave”.


Case-1 of the 10GBASE-KR PHY applies to PHYs without FEC. Case-2 of the 10GBASE-KR PHY applies 
to PHYs with FEC.
Case-1 of the PHY in the MultiGBASE-T set applies when the PHY is requested to transmit the Wake signal 
before transmission of the Sleep signal to the Link Partner is complete. Case-2 of the PHY in the 
MultiGBASE-T set applies when the PHY is requested to transmit the Wake signal after transmission of the 
Sleep signal to the Link Partner is complete and if the PHY has not indicated LOCAL FAULT at any time 
during the previous 10 ms.
Case-1 of the 25GBASE-CR, 25GBASE-CR-S, 25GBASE-KR, and 25GBASE-KR-S PHYs applies to 
PHYs in deep sleep without FEC enabled. Case-2 applies to 25GBASE-R PHYs with the BASE-R FEC in 
deep sleep. Case-3 applies to 25GBASE-R PHYs with the RS-FEC in deep sleep.
Case-1 of the 40GBASE-CR4, 40GBASE-KR4, and 100GBASE-CR10 PHYs applies to PHYs without FEC 
in deep sleep. Case-2 of these PHYs applies to PHYs with FEC in deep sleep.
Case-1 of the PHY in the MultiGBASE-T1 set applies when the PHY is requested to transmit the alert signal 
before transmission of the sleep signal to the link partner is complete. Case-2 of the PHY in the 
MultiGBASE-T1 set applies when the PHY is requested to transmit the wake signal after transmission of the 
sleep signal to the link partner is complete and if the PHY has not indicated LOCAL FAULT at any time 
during the previous 10 ms. Case-3 of the PHY in the MultiGBASE-T1 set is the same as Case-1 when Slow 
Wake is active. Case-4 of the PHY in the MultiGBASE-T1 set is the same as Case-2 when Slow Wake is 
active.
Table 78–4—Summary of the LPI timing parameters for supported PHYs 
or interfaces 
PHY or interface 
type
Case
Tw_sys_tx
(min) 
(s)
Tw_phy
(min) 
(s)
Tphy_shrink_tx
(max) 
(s)
Tphy_shrink_rx 
(max) 
(s)
Tw_sys_rx
(min) 
(s)
10BASE-T1L
250.5
100BASE-TX
20.5
1000BASE-KX
13.26
11.25
6.5
1.76
1000BASE-T1
10.8
10.8
10.8
0a
0a
1000BASE-RHC
1000BASE-RHA
1000BASE-RHB
1000BASE-T
Case-1
16.5
16.5
2.5
1.76
Case-2
16.5
16.5
12.24
9.74
1.76
2.5GBASE-KX
13.26
11.25
5.0
6.5
1.76
2.5GBASE-T1
Case-1
35.84
35.84
25.6
10.24
Case-2
25.6
25.6
15.36
10.24
Case-3
148.48
148.48
138.24
10.24
Case-4
138.24
138.24
10.24


2.5GBASE-T
Case-1
29.44
29.44
17.92
11.52
Case-2
17.92
17.92
6.4
11.52
5GBASE-KR
15.38
12.25
7.5
2.88
5GBASE-T1
Case-1
17.92
17.92
12.8
5.12
Case-2
12.8
12.8
7.68
5.12
Case-3
74.24
74.24
69.12
5.12
Case-4
69.12
69.12
5.12
5GBASE-T
Case-1
14.72
14.72
8.96
5.76
Case-2
8.96
8.96
3.2
5.76
XGXS (XAUI)
12.38
9.25
4.5
2.88
10GBASE-KX4
12.38
9.25
4.5
2.88
10GBASE-KR
Case-1
15.38
12.25
7.5
2.88
Case-2
17.38
14.25
9.5
2.88
10GBASE-T1
Case-1
8.96
8.96
6.4
2.56
Case-2
6.4
6.4
3.84
2.56
Case-3
37.12
37.12
34.56
2.56
Case-4
34.56
34.56
2.56
10GBASE-T
Case-1
7.36
7.36
4.48
2.88
Case-2
4.48
4.48
1.6
2.88
25GBASE-R fast 
wake
0.34
0.3
0.25
25GAUIb
25GBASE-KR-S
25GBASE-KR
25GBASE-CR-S
25GBASE-CR
Case-1
15.38
12.25
7.5
2.88
Case-2
17.38
14.25
9.5
2.88
Case-3
15.38
12.25
7.5
2.88
25GBASE-T
Case-1
2.56
2.56
1.792
0.768
Case-2
1.792
1.792
0.64
0.768
40GBASE-R fast 
wake
0.34
0.3
0.25
XLAUIb
40GBASE-KR4
40GBASE-CR4
Case-1
5.5
5.5
1.2
Case-2
6.5
6.5
1.2
Table 78–4—Summary of the LPI timing parameters for supported PHYs 
or interfaces (continued)
PHY or interface 
type
Case
Tw_sys_tx
(min) 
(s)
Tw_phy
(min) 
(s)
Tphy_shrink_tx
(max) 
(s)
Tphy_shrink_rx 
(max) 
(s)
Tw_sys_rx
(min) 
(s)


78.5.1 PHY extension using extender sublayers
The XGXS can be inserted between the RS and a 10 Gb/s PHY to transparently extend the physical reach of 
the XGMII. The LPI signaling can operate through the XGXS with the LPI timing parameters modified as 
described below.
If the DTE XS XAUI stop enable bit (5.0.9) is asserted, the DTE XS may stop signaling on the XAUI in the 
transmit direction to conserve energy. If the DTE XS XAUI stop enable bit is asserted, the RS defers 
sending data following deassertion of LPI by an additional time equal to Tw_sys_tx – Tw_sys_rx for the XGXS 
as shown in Table 78–4 (see 46.4.2.1).
If the PHY XS XAUI stop enable bit (4.0.9) is asserted, the PHY XS may stop signaling on the XAUI in the 
receive direction to conserve energy. The receiver negotiates an additional time for the remote Tw_sys equal 
40GBASE-T
Case-1
1.6
1.6
1.12
0.48
Case-2
1.12
1.12
0.4
0.48
50GBASE-R fast 
wake
0.34
0.3
0.25
100GBASE-R fast 
wake
0.34
0.3
0.25
CAUI-nb
100GBASE-KR4
100GBASE-KP4
100GBASE-CR4
5.5
5.5
100GBASE-CR10
Case-1
5.5
5.5
Case-2
7.5
7.5
200GBASE-R fast 
wake
0.34
0.3
0.25
200GXSc
0.34
400GBASE-R fast 
wake
0.34
0.3
0.25
400GXSc
0.34
aAll data transmission in 1000BASE-T1 PHY is synchronized to the PHY frame boundary. As such, the EEE function 
in the 1000BASE-T1 PHY is expected to assert the wake signal only at specific moments of time, aligned to PHY 
frame boundaries, and no shrinkage or delay at the RX side is expected.
b Tw_sys_tx is increased by 1 s for each instance of 25GAUI/XLAUI/CAUI with shutdown enabled on the transmit 
path.The receiver should negotiate an increase for remote Tw_sys for the link partner of 1 s for each instance of 
25GAUI/XLAUI/CAUI with shutdown enabled on the receive path.
cThe minimum Tw_sys_tx of a PHY is increased by the indicated period if there is a 200GXS/400GXS in the transmit 
path. A PHY that includes a 200GXS/400GXS in the receive path may require an increase of Tw_sys_tx on the link 
partner; this may be negotiated using LLDP (see 79.3.5).
Table 78–4—Summary of the LPI timing parameters for supported PHYs 
or interfaces (continued)
PHY or interface 
type
Case
Tw_sys_tx
(min) 
(s)
Tw_phy
(min) 
(s)
Tphy_shrink_tx
(max) 
(s)
Tphy_shrink_rx 
(max) 
(s)
Tw_sys_rx
(min) 
(s)


to Tw_sys_tx – Tw_sys_rx for the XGXS as shown in Table 78–4 before setting the PHY XS XAUI stop enable 
bit.
The 200GXS or 400GXS (see Clause 118) can be inserted between the RS and a 200 Gb/s or 400 Gb/s PHY, 
respectively, to transparently extend the physical reach of the 200GMII or 400GMII. The LPI signaling can 
operate through the 200GXS or 400GXS with the PHY timing parameters modified as described in 
Table 78–4.
78.5.2 25 Gb/s 40 Gb/s, and 100 Gb/s PHY extension using 25GAUI, XLAUI, or CAUI-n
25GAUI, XLAUI, CAUI-10, and CAUI-4 may be used as physical instantiations of the inter-sublayer 
service interface to separate functions between devices. The LPI signaling can operate through these 
interfaces with the LPI timing parameters modified as described below.
If PMA Egress AUI Stop Enable (PEASE, see 83.3; MDIO register bit 1.7.8) is asserted for any of the PMA 
sublayers, the PMA may stop signaling on the AUI in the transmit direction to conserve energy. If PEASE is 
asserted, the RS defers sending data following deassertion of LPI by an additional time equal to Tw_sys_tx for 
the AUI as shown in Table 78–4 for each PMA with PEASE asserted (see 81.4.2).
If PMA Ingress AUI Stop Enable (PIASE, see 83.3; MDIO register bit 1.7.9) is asserted for any of the PMA 
sublayers, the PMA may stop signaling on the AUI in the receive direction to conserve energy. The receiver 
should negotiate an additional time for the remote Tw_sys equal to Tw_sys_tx for the AUI as shown in 
Table 78–4 for each PMA with PIASE to be asserted before setting the PIASE bits.


---

<a id='clause-96'></a>
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
# Clause 98: Auto-Negotiation for single differential-pair media

**Focus**: Auto-Negotiation state machine, page format, DME encoding  
**Pages extracted**: 4050 – 4079  
**Excluded from**: Page 4080 (electrical/PICS section)

98. Auto-Negotiation for single differential-pair media
98.1 Overview
98.1.1 Scope
Clause 98 describes the single twisted-pair Auto-Negotiation function that allows a device to advertise 
enhanced modes of operation it possesses to a device at the remote end of a link segment and to detect 
corresponding enhanced operational modes that the other device may be advertising. Annex 98A describes 
the Selector Field that is used by Auto-Negotiation to identify the type of message being sent.
The objective of the single twisted-pair Auto-Negotiation function is to provide the means to exchange 
information between two devices that share a link segment and to automatically configure both devices to 
take maximum advantage of their abilities. It has the additional objective of providing a common 
synchronization time between two devices prior to link training.
Single twisted-pair Auto-Negotiation is performed using differential Manchester encoding (DME) pages. 
DME provides a DC balanced signal. DME does not add packet or upper layer overhead to the network 
devices. DME is transferred in a half-duplex manner over the single twisted-pair copper cable.
Single twisted-pair Auto-Negotiation does not test the link segment characteristics.
The function allows the devices at both ends of a link segment to advertise abilities, acknowledge receipt 
and understanding of the common mode(s) of operation that both devices share, and to reject the use of 
operational modes that are not shared by both devices. Where more than one common mode exists between 
the two devices, a mechanism is provided to allow the devices to resolve to a single mode of operation using 
a predetermined priority resolution function. The single twisted-pair Auto-Negotiation function allows the 
identification of the operational mode of the link partner. Should multiple modes be present, management 
may select between the various offered modes. How such selection is done is beyond the scope of this 
standard.
98.1.2 Relationship to the ISO/IEC Open Systems Interconnection (OSI) reference model
The single twisted-pair Auto-Negotiation function is provided at the Physical Layer of the ISO/IEC OSI 
reference model as shown in Figure 98–2. A device that supports multiple modes of operation may advertise 
its capabilities using the single twisted-pair Auto-Negotiation function. The actual transfer of information is 
observed only at the MDI. 
98.2 Functional specifications
The single twisted-pair Auto-Negotiation function provides a mechanism to control connection of a single 
MDI to a single PHY type, where more than one PHY type may exist. A management interface provides 
control and status of single twisted-pair Auto-Negotiation, but the presence of a management agent is not 
required.
Auto-Negotiation shall provide the following functions (as shown in Figure 98–1):
a)
Transmit
b)
Receive
c)
Half duplex
d)
Arbitration


These functions shall comply with the state diagrams from Figure 98–7 through Figure 98–10. The single 
twisted-pair Auto-Negotiation functions shall interact with the technology-dependent PHYs through the 
Technology Dependent Interface (see 98.4).
98.2.1 Transmit function requirements
The Transmit function provides the ability to transmit pages. The first pages exchanged by the local device 
and its link partner after Power-On, link restart, or renegotiation contain the base link codeword defined in 
Table 98–2. The local device may modify the link codeword to disable an ability it possesses, but will not 
transmit an ability it does not possess. This makes possible the distinction between local abilities and 
advertised abilities so that multi-ability devices may Auto-Negotiate to a mode lower in priority than the 
highest common ability.
Two different Auto-Negotiation speeds are defined in this subclause. A PHY shall support at least one of 
these Auto-Negotiation speeds. The two speeds are referred to as high-speed mode, or HSM, and low-speed 
mode, or LSM. If Auto-Negotiation is implemented, 1000BASE-T1, 100BASE-T1, and 10BASE-T1S 
PHYs shall support HSM and may optionally support LSM. For link segments with high insertion loss and 
those requiring 10BASE-T1L, LSM is provided to enable the full reach capability. If Auto-Negotiation is 
implemented, 10BASE-T1L PHYs shall support LSM and may optionally support HSM. When performing 
Auto-Negotiation in high-speed mode, DME pages are transmitted at a nominal rate of 16.667 Mb/s. In 
low-speed mode, DME pages are transmitted at a nominal rate of 625 kb/s. Subclause 98.5.6 describes the 
behavior to automatically choose between the different Auto-Negotiation speeds when a PHY supports both.
98.2.1.1 DME transmission
Auto-Negotiation’s method of communication builds upon the encoding mechanism known as differential 
Manchester encoding (DME). The DME page encodes the data that is used to control the Auto-Negotiation 
function. DME pages shall not be transmitted when Auto-Negotiation is complete and the highest common 
denominator PHY has been enabled.
Figure 98–1—High-level model
Technology
Specific
PMA = 1000BASE-T1
Technology
Specific
PMA = #2
Technology
Specific
PMA = #N
Transmission
Arbitration
Receive
AN Half-Duplex
Auto-Negotiation Functions
MDI


98.2.1.1.1 DME page encoding
A DME page carries a 48-bit Auto-Negotiation page. It consists of 157 evenly spaced transition positions 
starting from the initial transition from silent to active in the preamble. The page contains a Start Delimiter, 
the 48-bit page, 16-bit CRC, and an end delimiter (see Figure 98–6). The odd-numbered transition positions 
represent clock information. The even numbered transition positions represent data information. DME pages 
are alternately transmitted between the two devices with quiet period separating the DME pages. When the 
DME page is active, the PHY shall transmit either +1 or –1 level with the voltage levels as specified in 
98.2.1.1.4.
The first 26 transition positions contain the Start Delimiter, which marks the beginning of the page. The 
Start Delimiter contains a transition from quiet to active at position 1. For HSM Auto-Negotiation, this 
transition is followed by transitions at positions 2, 3, 5, 7, 8, 12, 13, 14, 15, 19, 21, 24, 25, 26 and no 
transitions at the remaining positions. For LSM Auto-Negotiation, this transition is followed by transitions 
at positions 2, 3, 4, 5, 6, 7, 8, 9, 11, 13, 15, 16, 18, 19, 20, 22, 23, 24, 26 and no transitions at the remaining 
positions.
The final 2 transition positions contain the ending delimiter, which marks the end of the page. The ending 
delimiter contains a transition at position 155 and no transitions at the remaining positions. Position 157 
contains a transition from active to quiet.
Each of the remaining 64 odd-numbered transition positions between the starting and ending delimiters shall 
contain a transition. The remaining 64 even-numbered transition positions shall represent data information 
as follows:
Figure 98–2—Location of Auto-Negotiation function within the 
ISO/IEC OSI reference model
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
MDI
1000BASE-T1
PMA
PCS
MEDIUM
LLC - LOGICAL LINK CONTROL
OR OTHER MAC CLIENT
MAC CONTROL (OPTIONAL)
PHY
NOTE 2—Auto-Negotiation is optional. Auto-Negotiation communicates
AN2
with the PMA sublayer through the PMA service interface 
messages PMA_LINK.request and PMA_LINK.indication.
GMII1
NOTE 1—GMII is optional.
AN = AUTO-NEGOTIATION


—
A transition present in an even-numbered transition position represents a logical one.
—
A transition absent from an even-numbered transition position represents a logical zero.
The first 48 of these positions shall carry the data of the Auto-Negotiation page. The final 16 positions carry 
the 16-bit CRC. 
The CRC16 polynomial is x16 + x15 + x2 + 1. The CRC16 shall produce the same result as the 
implementation shown in Figure 98–3. The 16 delay elements S0,..., S15, shall be initialized to zero. 
Afterwards the 48 data bits are used to compute the CRC16 with the switch connected (setting CRCgen). 
After all the 48 bits have been processed, the switch is disconnected (setting CRCout) and the 16 values 
stored in the delay elements are transmitted in the order illustrated, first S15, followed by S14, and so on, 
until the final value S0.
The polarity at position 0 is randomly determined in an implementation specific manner.
The purpose of randomizing the starting polarity is to remove the spectral peaks that would otherwise occur 
when sending the same DME page repeatedly. Randomly choosing the starting polarity results in randomly 
inverting or not inverting the encoded page so that repetitions of the same page no longer produce a periodic 
signal.
Clock transition positions are differentiated from data transition positions by the spacing between them, as 
shown in Figure 98–4 and enumerated in Table 98–1.
The encoding of data using DME bits in a DME page is illustrated in Figure 98–4.
Figure 98–3—CRC16
S0
+
S1
S2
S14
+
S15
+
CRC16 output
D0 through D47
Logic 0
CRCgen
CRCout


98.2.1.1.2 DME page timing
The timing parameters for DME pages shall be followed as in Table 98–1. The transition positions within a 
DME page are spaced with a period of T1. T2 is the separation between clock transitions. T3 is the time 
from a clock transition to a data transition representing a one. When operating in high-speed mode, 
transitions shall occur within ± 0.8 ns of their ideal positions. When operating in low-speed mode, 
transitions shall occur within ± 10 ns of their ideal positions.
T5 specifies the duration of a DME page. The minimum number of transitions and maximum number of 
transitions in a page is represented by T4a. T4b indicates that the start of a DME page begins with a 
transition from 0 to ±1 and the end of the DME page is a transition from ±1 to 0.
Table 98–1 summarizes the timing parameters. The transition timing parameters are illustrated in Figure 98–5 
and Figure 98–6.
Figure 98–4—Data bit encoding within DME pages
Clock transitions
First bit on wire
Data
Encoding
Transition positions
D0
D1
D2
Figure 98–5—DME page transition timing
Clock
transition
Clock
transition
Data
transition
T2
T3


98.2.1.1.3 DME page Delimiters
The page is preceded by a unique Start Delimiter consisting of a 26 × T1 sequence that includes multiple 
DME transition violations. For a Start Delimiter starting with a 0 to +1 transition, the bit sequence for 
high-speed Auto-Negotiation mode is:
+1 –1 +1 +1 –1 –1 +1 –1 –1 –1 –1 +1 –1 +1 –1 –1 –1 –1 +1 +1 –1 –1 –1 +1 –1 +1.
For a Start Delimiter starting with a 0 to +1 transition, the bit sequence for low-speed Auto-Negotiation 
mode is:
+1 –1 +1 –1 +1 –1 +1 –1 +1 +1 –1 –1 +1 +1 –1 +1 +1 –1 +1 –1 –1 +1 –1 +1 +1 –1.
The DME page ends with an end delimiter that consists of an electrical 0. An example of the delimiters is 
shown in Figure 98–6.
Table 98–1—DME page timing summary 
Parameters
Mode
Min
Typ
Max
Units
T1
Transmit position spacing (period)
high-speed
29.997
30.003
ns
low-speed
799.96
800.04
T2
Clock transition to clock transition
high-speed
59.8
60.2
ns
low-speed
T3
Clock transition to data transition (data = 1)
high-speed
29.9
30.1
ns
low-speed
T4a
+1 to –1 or –1 to +1 transitions in a DME page
high-speed
—
—
low-speed
—
T4b
0 to ±1 or ±1 to 0 transitions in a DME page
high-speed
—
low-speed
T5
DME page width
high-speed
ns
low-speed
124 793
124 800
124 807


NOTE—The Start Delimiter may begin with a 0 to +1 or 0 to –1 transition depending upon the DME page starting 
polarity randomizer.
98.2.1.1.4 Transmitter peak differential output
When measured with 100 termination, transmit differential signal at MDI shall be within range of 
1 V ± 30% peak-to-peak. 
98.2.1.2 Link codeword encoding
The base link codeword (Base Page) transmitted within a DME page shall convey the encoding shown in 
Table 98–2. The Auto-Negotiation function supports additional pages using the Next Page function.
Encoding for the link codeword(s) used in the Next Page exchange are defined in 98.2.4.3. In a DME page, 
D0 shall be the first bit transmitted. 
D[4:0] contains the Selector Field. D[9:5] contains the Echoed Nonce field. D[11:10] contains capability 
bits to advertise capabilities not related to the PHY. C[1:0] is used to advertise pause capability. D[12] is the 
force MASTER-SLAVE bit (see 98.2.1.2.5). D[15:13] contains the RF, Ack, and NP bits. The RF, Ack, and 
NP bits shall function as specified in 98.2.1.2.7, 98.2.1.2.8, and 98.2.1.2.9, respectively. D[20:16] contains 
the Transmitted Nonce field. D[47:21] contains the Technology Ability Field. 
NOTE—Annex K defines optional alternative terminology for “master” and “slave”.
98.2.1.2.1 Selector Field
Selector Field (S[4:0]) is a 5-bit wide field, encoding 32 possible messages. Selector Field encoding 
definitions are shown in Annex 98A. Combinations not specified are reserved. Reserved combinations of 
the Selector Field shall not be transmitted.
The Selector Field for IEEE Std 802.3 is shown in Table 98–3. 
Table 98–2—Link codeword Base Page
D0
D1
D2
D3
D4
D5
D6
D7
D8
D9
D10
D11
D12
D13
D14
D15
S0
S1
S2
S3
S4
E0
E1
E2
E3
E4
C0
C1
M/S
RF
Ack
NP
D16
D17
D18
D19
D20
D21
D22
D23
D24
D25
D26
D27
D28
D29
D30
D31
T0
T1
T2
T3
T4
A0
A1
A2
A3
A4
A5
A6
A7
A8
A9
A10
D32
D33
D34
D35
D36
D37
D38
D39
D40
D41
D42
D43
D44
D45
D46
D47
A11
A12
A13
A14
A15
A16
A17
A18
A19
A20
A21
A22
A23
A24
A25
A26
D
D
D
D
S
S
Start Delimiter
Payload
CRC16
End Delimiter
T5
Figure 98–6—DME Page


98.2.1.2.2 Echoed Nonce Field
Echoed Nonce Field (E[4:0]) is a 5-bit wide field containing the nonce received from the link partner. If the 
device has not received a DME page with good CRC16, the bits in this field shall contain logical zeros. If the 
device has received a DME page with good CRC16, the bits in this field shall contain the value received in 
the Transmitted Nonce Field from the link partner at the same time as the Acknowledge bit is set.
98.2.1.2.3 Transmitted Nonce Field
Transmitted Nonce Field (T[4:0]) is a 5-bit wide field whose lower 4 bits contains a random or 
pseudo-random number. A new value shall be generated for each entry to the Ability Detect state. The 
method of generating the nonce is left to the implementer. The lower 4 bits of the transmitted nonce should 
have a uniform distribution in the range from 0 to 24 – 1. The method used to generate the value should be 
designed to minimize correlation to the values generated by other devices. 
Bit T[4] should be set to 1 if the device prefers or is forced to be MASTER and 0 if the device prefers or is 
forced to be SLAVE.
If the device has received a DME page with good CRC16 and the link partner has a Transmitted Nonce Field 
(T[4:0]) that matches the devices generated T[4:0], the device shall invert its T[0] bit and regenerate a new 
random value for T[3:1] and use that as its new T[4:0] value. Since the DME pages are exchanged in a 
half-duplex manner, it is possible to swap to a new T[4:0] value prior to transmitting the DME page. One 
device will always see a DME page with good CRC16 before the other device hence this swapping will 
guarantee that nonce_match will never be true.
98.2.1.2.4 Technology Ability Field
Technology Ability Field (A[26:0]) is a 27-bit wide field containing information indicating supported 
technologies specific to the selector field value when used with the single twisted-pair Auto-Negotiation 
Ethernet. These bits are mapped to individual technologies such that abilities are advertised in parallel for a 
single selector field value. The Technology Ability Field encoding for the IEEE 802.3 selector with single 
twisted-pair Auto-Negotiation Ethernet is described in 98B.3.
Multiple technologies may be advertised in the link codeword. A device shall support the data service ability 
for a technology it advertises. It is the responsibility of the Arbitration function to determine the common 
mode of operation shared by a link partner and to resolve multiple common modes.
98.2.1.2.5 Force MASTER-SLAVE
The force MASTER-SLAVE bit, D12, allows a device to force its MASTER-SLAVE configuration. If this 
bit is set to 0 then the device is in preferred mode, otherwise it is in the forced mode. The MASTER-SLAVE 
resolution is shown in Table 98–4. 
98.2.1.2.6 Pause Ability
Pause (C0:C1) is encoded in bits D11:D10 of the base link codeword. The 2-bit Pause is encoded as follows:
Table 98–3—Selector Field Encoding
S4
S3
S2
S1
S0
Selector description
IEEE Std 802.3


a)
C0 is the same as PAUSE as defined in Annex 28B
b)
C1 is the same as ASM_DIR as defined in Annex 28B
The Pause encoding is defined in 28B.2, Table 28B–2. The PAUSE bit indicates that the device is capable of 
providing the symmetric PAUSE functions as defined in Annex 31B. The ASM_DIR bit indicates that 
asymmetric PAUSE is supported. The value of the PAUSE bit when the ASM_DIR bit is set indicates the 
direction the PAUSE frames are supported for flow across the link. Asymmetric PAUSE configuration 
results in independent enabling of the PAUSE receive and PAUSE transmit functions as defined by 
Annex 31B. See 28B.3 regarding PAUSE configuration resolution.
98.2.1.2.7 Remote Fault
Remote Fault (RF) is encoded in bit D13 of the base link codeword. The default value is logical zero. The 
Remote Fault bit provides a standard transport mechanism for the transmission of simple fault information. 
When the RF bit in the BASE-T1 AN advertisement register (register 7.514.13) is set to logical one, the RF 
bit in the transmitted base link codeword is set to logical one. When the RF bit in the received base link 
codeword is set to logical one, the Remote Fault bit in the BASE-T1 AN LP Base Page ability register 
(register 7.517.13) will be set to logical one, if the management function is present.
98.2.1.2.8 Acknowledge
Acknowledge (Ack) is used by the Auto-Negotiation function to indicate that a device has successfully 
received its link partner’s link codeword. The Acknowledge Bit is encoded in bit D14 of link codeword. If 
no Next Page information is to be sent, this bit shall be set to logical one in the link codeword after the 
reception of at least one DME page with a correct CRC. If Next Page information is to be sent, this bit shall 
be set to logical one after the device has successfully received at least one DME page with correct CRC, and 
will remain set until the Next Page information has been loaded into the BASE-T1 AN NEXT PAGE 
transmit register (Registers 7.520, 7.521, 7.522). In order to save the current received link codeword, it shall 
be read from the BASE-T1 AN LP NEXT PAGE ability register (register 7.523, 7.524, 7.525) before the 
Next Page of transmit information is loaded into the BASE-T1 AN NEXT PAGE transmit register. After the 
Table 98–4—MASTER-SLAVE Configuration 
Local Device
Remote 
Device
Local Device Resolution
Remote Device Resolution
M/S
T[4]
M/S
T[4]
X
X
Device with higher T[4:0] is 
MASTER, otherwise SLAVE
Device with higher T[4:0] is 
MASTER, otherwise SLAVE
X
MASTER
SLAVE
X
SLAVE
MASTER
X
SLAVE
MASTER
X
MASTER
SLAVE
Configuration Fault
Configuration Fault
SLAVE
MASTER
MASTER
SLAVE
Configuration Fault
Configuration Fault


COMPLETE ACKNOWLEDGE state has been entered, the link codeword will be transmitted at least three 
times.
98.2.1.2.9 Next Page
Next Page (NP) is encoded in bit D15 of link codeword. Support of Next Pages is mandatory. If the device 
does not have any Next Pages to send, the NP bit shall be set to logical zero. If a device wishes to engage in 
Next Page exchange, it shall set the NP bit to logical one. If a device has no Next Pages to send and its link 
partner has set the NP bit to logical one, it shall transmit Next Pages with Null message codes and the NP bit 
set to logical zero while its link partner transmits valid Next Pages. Next page exchanges will occur if either 
the device or its link partner sets the Next Page bit to logical one. The Next Page function is defined in 
98.2.4.3.
98.2.1.3 Transmit Switch function
The Transmit Switch function shall enable the transmit path from a single technology-dependent PHY to the 
MDI once a highest common denominator choice has been made and Auto-Negotiation has completed. 
During Auto-Negotiation, the Transmit Switch function shall connect only the DME page generator 
controlled by the Transmit state diagram to the MDI. When a PHY is connected to the MDI through the 
Transmit Switch function, the signals at the MDI shall conform to all of the PHY’s specifications.
98.2.2 Receive function requirements
The Receive function detects the DME page sequence, decodes the information contained within, and stores 
the data in rx_link_code_word[64:1]. The receive function incorporates a receive switch to control 
connection to the various PMAs.
98.2.2.1 DME page reception
To be able to detect the DME bits, the receiver should have the capability to receive DME signals sent with 
the electrical specifications of the PHY. The DME transmit signal level is specified in 98.2.1.1.4.
98.2.2.2 Receive Switch function
The Receive Switch function shall enable the receive path from the MDI to a single technology-dependent 
PHY once a highest common denominator choice has been made and Auto-Negotiation has completed.
During Auto-Negotiation, the Receive Switch function shall connect the DME page receiver controlled by 
the Receive state diagram to the MDI and the Receive Switch function shall also connect the appropriate 
receivers to the MDI.
98.2.2.3 Link codeword matching
The Receive function shall generate ability_match, acknowledge_match, and consistency_match variables 
as defined in Arbitration state diagram Figure 98–7.
98.2.3 AN half-duplex function requirements
The AN half-duplex function is defined by Figure 98–10 and ensures that only one of the link partners is 
transmitting a DME page at each step during the DME page exchange process. The AN half-duplex function 
uses a blind timer to ensure that the receiver ignores signals reflected from the channel following the end of 
the device's transmitted DME page. A silent timer is used to ensure that the device does not begin 
transmitting the DME page until after the link partner has exited from the blind timer. The half-duplex 


backoff timer resolves concurrent transmissions by using a random wait time to listen for a DME page to 
arrive from the link partner before the local device transmits a DME page.
98.2.4 Arbitration function requirements
The Arbitration function is defined by Figure 98–7 and ensures proper sequencing of the Auto-Negotiation 
function using the Transmit function, Receive function, and AN half-duplex function. The Arbitration 
function enables the Transmit function to advertise and acknowledge abilities. Upon indication of 
acknowledgment, the Arbitration function determines the highest common denominator using the priority 
resolution function and enables the appropriate technology-dependent PHY via the Technology Dependent 
Interface (see 98.4).
98.2.4.1 Renegotiation function
A Renegotiation request from any entity, such as a management agent, shall cause the Arbitration function 
to disable all technology-dependent PHYs and halt any transmit data and link transition activity until the 
break_link_timer expires. Consequently, the link partner will go into link fail and normal Auto-Negotiation 
resumes. The local device shall resume Auto-Negotiation after the break_link_timer has expired by issuing 
DME pages with the Base Page valid in tx_link_code_word[64:1]. Once Auto-Negotiation has completed, 
renegotiation will take place if the Highest Common Denominator technology that receives 
link_control = ENABLE returns link_status = FAIL. To allow the PHY an opportunity to determine link 
integrity using its own link integrity test function, the link_fail_inhibit_timer qualifies the 
link_status = FAIL indication such that renegotiation takes place if the link_fail_inhibit_timer has expired 
and the PHY still indicates link_status = FAIL.
98.2.4.2 Priority Resolution function
Since a local device and a link partner may have multiple common abilities, a mechanism to resolve which 
mode to configure is required. The mechanism used by Auto-Negotiation is a Priority Resolution function 
that predefines the hierarchy of supported technologies. The single PHY enabled to connect to the MDI by 
Auto-Negotiation shall be the technology corresponding to the bit in the Technology Ability Field common 
to the local device and link partner that has the highest priority as defined in 98B.4 (listed from highest 
priority to lowest priority).
The common technology is referred to as the highest common denominator, or HCD, technology. If the local 
device receives a Technology Ability Field with a bit set that is reserved, the local device shall ignore that 
bit for priority resolution. Determination of the HCD technology occurs on entrance to the AN GOOD 
CHECK state. In the event that there is no common technology, HCD shall have a value of “NULL,” 
indicating that no PHY receives link_control = ENABLE and link_status[HCD] = FAIL.
98.2.4.3 Next Page function
The Next Page function uses the Auto-Negotiation arbitration mechanisms to allow exchange of Next Pages 
of information, which may follow the transmission and acknowledgment procedures used for the base link 
codeword. The Next Page has both Message Code Field and Unformatted Code Fields.
A dual acknowledgment system is used. Acknowledge (Ack) is used to acknowledge receipt of the 
information; Acknowledge 2 (Ack2) is used to indicate that the receiver is able to act on the information (or 
perform the task) defined in the message. 
The Toggle (T) bit is used to ensure proper synchronization between the local device and the link partner. 


Next page exchange occurs after the base link codewords have been exchanged if either end of the link 
segment set the Next Page bit to logical one indicating that it had at least one Next Page to send. Next page 
exchange consists of using the normal Auto-Negotiation arbitration process to send Next Page messages. 
The Next Page contains two message encodings. The message encodings are defined as follows: message 
code, which contains predefined 11-bit codes, and unformatted code, which contains 32-bit codes. Multiple 
Next Pages with appropriate message codes and unformatted codes can be transmitted to send extended 
messages. Each series of Next Pages shall have a Message code that defines how the Unformatted codes will 
be interpreted. Any number of Next Pages may be sent in any order; however, it is recommended that the 
total number of Next Pages sent be kept small to minimize the link startup time. 
Next Page transmission ends when both ends of a link segment set their Next Page bits to logical zero, 
indicating that neither has anything additional to transmit. It is possible for one device to have more pages to 
transmit than the other device. Once a device has completed transmission of its Next Page information, it 
shall transmit Next Pages with Null message codes and the NP bit set to logical zero while its link partner 
continues to transmit valid Next Pages. An Auto-Negotiation able device shall recognize reception of 
Message Pages with Null message codes as the end of its link partner’s Next Page information.
98.2.4.3.1 Next page encodings
The Next Page shall use the encoding shown in Table 98–5 and Table 98–6 for the NP, Ack, MP, Ack2, and 
T bits. These bits shall function as specified in 98.2.1.2.9, 98.2.1.2.8, 28.2.3.4.5, 28.2.3.4.6, and 28.2.3.4.7 
respectively. There are two types of Next Page encodings: message and unformatted. For message Next 
Pages, the MP bit shall be set to logical one, the 11-bit field D[10:0] shall be encoded as a Message Code 
Field and D[47:16] shall be encoded as Unformatted Code Field. For Unformatted Next Pages, the MP bit 
shall be set to logical ZERO: D[10:0] and D[47:16] shall be encoded as the Unformatted Code Field.  
98.2.4.3.2 Use of Next Pages
Next page exchange shall commence after the Base Page exchange if either device requests it by setting the 
NP bit to logical one.
Table 98–5—Message Next Page
D0
D1
D2
D3
D4
D5
D6
D7
D8
D9
D10
D11
D12
D13
D14
D15
M0
M1
M2
M3
M4
M5
M6
M7
M8
M9
M10
T
Ack2
MP
Ack
NP
D16
D17
D18
D19
D20
D21
D22
D23
D24
D25
D26
D27
D28
D29
D30
D31
U0
U1
U2
U3
U4
U5
U6
U7
U8
U9
U10
U11
U12
U13
U14
U15
D32
D33
D34
D35
D36
D37
D38
D39
D40
D41
D42
D43
D44
D45
D46
D47
U16
U17
U18
U19
U20
U21
U22
U23
U24
U25
U26
U27
U28
U29
U30
U31
Table 98–6—Unformatted Next Page
D0
D1
D2
D3
D4
D5
D6
D7
D8
D9
D10
D11
D12
D13
D14
D15
U0
U1
U2
U3
U4
U5
U6
U7
U8
U9
U10
T
Ack2
MP
Ack
NP
D16
D17
D18
D19
D20
D21
D22
D23
D24
D25
D26
D27
D28
D29
D30
D31
U11
U12
U13
U14
U15
U16
U17
U18
U19
U20
U21
U22
U23
U24
U25
U26
D32
D33
D34
D35
D36
D37
D38
D39
D40
D41
D42
D43
D44
D45
D46
D47
U27
U28
U29
U30
U31
U32
U33
U34
U35
U36
U37
U38
U39
U40
U41
U42


Next page exchange shall continue until neither device on a link has more pages to transmit as indicated by 
the NP bit. A Next Page with a Null Message Code Field value shall be sent if the device has no other 
information to transmit.
A message code can carry either a specific message or information that defines how the corresponding 
unformatted codes should be interpreted.
98.3 State diagram variable to Auto-Negotiation register mapping
The state diagrams of Figure 98–7 to Figure 98–10 generate and accept variables of the form “mr_x,” where 
x is an individual signal name. These variables comprise a management interface to communicate 
Auto-Negotiation information to and from the management entity. Clause 45 MDIO registers are defined in 
MMD7 to support Auto-Negotiation. The Clause 45 MDIO electrical interface is optional. Where no 
physical embodiment of the MDIO exists, provision of an equivalent mechanism to access the information is 
recommended. 
Table 98–7 describes the MDIO register to the state diagrams variable mapping.
98.4 Technology-Dependent Interface
The Technology-Dependent Interface is the communication mechanism between each technology’s PMA 
and the Auto-Negotiation function. Auto-Negotiation can support multiple technologies, all of which need 
not be implemented in a given device. Each of these technologies may utilize its own technology-dependent 
link integrity test function.
Table 98–7—State diagram variable to Single twisted-pair Auto-Negotiation 
MDIO register mapping
State diagram variable
Description / MDIO register mapping
mr_adv_ability[48:1] 
{7.516.15:0, 7.515.15:0, 7.514.15:0} BASE-T1 AN advertisement registers
mr_autoneg_complete 
7.513.5 Auto-Negotiation complete
mr_autoneg_enable 
7.512.12 Auto-Negotiation enable
mr_lp_adv_ability[48:1]
For Base Page:
{7.519.15:0, 7.518.15:0, 7.517.15:0} BASE-T1 AN LP Base Page ability registers
For Next Page(s):
{7.525.15:0, 7.524.15:0, 7.523.15:0} BASE-T1 AN LP NEXT PAGE ability register
mr_main_reset
7.512.15 AN reset
mr_next_page_loaded
Set on write to BASE-T1 AN NEXT PAGE transmit register;
cleared by Arbitration state diagram
mr_np_tx[48:1]
{7.522.15:0, 7.521.15:0, 7.520.15:0} BASE-T1 AN NEXT PAGE transmit register 
mr_page_rx
7.513.6 Page received
mr_restart_negotiation
7.512.9 Restart Auto-Negotiation
set to 1
7.513.3 Auto-Negotiation ability


98.4.1 PMA_LINK.indication
This primitive is generated by the PMA to indicate the status of the underlying medium. The purpose of this 
primitive is to give the Auto-Negotiation function a means of determining the validity of received code 
elements.
98.4.1.1 Semantics of the service primitive
PMA_LINK.indication(link_status)
The link_status parameter shall assume one of two values: OK or FAIL, indicating whether the underlying 
receive channel is intact and enabled (OK) or not intact (FAIL).
98.4.1.2 When generated 
A technology-dependent PMA generates this primitive to indicate a change in the value of link_status.
98.4.1.3 Effect of receipt
The effect of receipt of this primitive shall be governed by the state diagram of Figure 98–7.
98.4.2 PMA_LINK.request
This primitive is generated by Auto-Negotiation to allow it to enable and disable operation of the PMA.
98.4.2.1 Semantics of the service primitive
PMA_LINK.request(link_control)
The link_control parameter shall assume one of two values: DISABLE or ENABLE.
The link_control=DISABLE mode shall be used by the Auto-Negotiation function to disable PMA 
processing.
The link_control=ENABLE mode shall be used by Auto-Negotiation to turn control over to a single PMA 
for all normal processing functions.
98.4.2.2 When generated
The Auto-Negotiation function shall generate this primitive to indicate to the PHY how to respond, in 
accordance with the state diagram of Figure 98–7. Upon power-on or reset, if the Auto-Negotiation function 
is enabled (mr_autoneg_enable=true) the PMA_LINK.request(DISABLE) message shall be issued to all 
technology-dependent PMAs.
98.4.2.3 Effect of receipt
This primitive affects operation of the underlying PMA.
98.5 Detailed functions and state diagrams
The notation used in state diagrams follows the conventions in Clause 28. Variables in a state diagram with 
default values evaluate to the variable default in each state where the variable value is not explicitly set. 


Auto-Negotiation shall implement the Transmit state diagram, Receive state diagram, half-duplex state 
diagram, and Arbitration state diagram. Additional requirements to these state diagrams are made in the 
respective functional requirements sections. Options to these state diagrams clearly stated as such in the 
functional requirements sections or state diagrams shall be allowed. In the case of any ambiguity between 
stated requirements and the state diagrams, the state diagrams shall take precedence.
98.5.1 State diagram variables
A variable with “_[x]” appended to the end of the variable name indicates a variable or set of variables as 
defined by “x”. “x” may be as follows:
—
all; 
represents all specific technology-dependent PMAs supported in the local device.
—
HCD; 
represents the single technology-dependent PMA chosen by Auto-Negotiation as the 
highest common denominator technology through the Priority Resolution. 
—
notHCD; represents all technology-dependent PMAs not chosen by Auto-Negotiation as the highest 
common denominator technology through the Priority Resolution.
—
1GigT1;
represents that the 1000BASE-T1 PMA is the signal source.
—
2.5GigT1; represents that the 2.5GBASE-T1 PMA is the signal source.
—
5GigT1;
represents that the 5GBASE-T1 PMA is the signal source.
—
10GigT1; represents that the 10GBASE-T1 PMA is the signal source.
Variables with [48:1] appended to the end of the variable name indicate arrays that can be directly mapped 
to 48-bit registers. For these variables, “[x]” indexes an element or set of elements in the array, where “[x]” 
may be as follows:
a)
Any integer
b)
Any range of integers
c)
Any variable that takes on integer values
d)
NP; represents the index of the Next Page bit
e)
ACK; represents the index of the Acknowledge bit
f)
RF; represents the index of the Remote Fault bit
Variables of the form “mr_x”, where x is a label, comprise a management interface that is intended to be 
connected to the Management function. However, an implementation-specific management interface may 
provide the control and status function of these bits. The mapping between state diagram variables and 
Single twisted-pair Auto-Negotiation MDIO registers is shown in Table 98–7.
ability_match
Indicates that at least one link codeword with good CRC16 was received.
Values:
false: 
at least one link codeword with good CRC16 has not been received (default)
true: 
at least one link codeword with good CRC16 has been received
NOTE—This variable is set by this variable definition; it is not set explicitly in the state diagrams.
ability_match_word [48:1]
A 48-bit array that is loaded upon transition to Acknowledge Detect state with the value of the link 
codeword that caused ability_match = true for that transition. For each element in the array 
transmitted.
Values:
ZERO: 
data bit is logical zero
ONE: 
data bit is logical one
NOTE—This variable is set by this variable definition; it is not set explicitly in the state diagrams.


 ack_finished
Status indicating that the final remaining_ack_cnt link codewords with the Ack bit set have been 
transmitted.
Values:
false: 
more link codewords with the Ack bit set to logical one is transmitted
true: 
all remaining link codewords with the Ack bit set to logical one have been 
transmitted
ack_nonce_match
Indicates whether the echoed nonce received from the link partner matches the transmitted nonce 
field sent by the local device. The echoed nonce value from the DME page that caused 
acknowledge_match to be set is used for this test.
Values:
false: 
link partner echoed nonce does not equal local device transmitted nonce
true: 
link partner echoed nonce equals local device transmitted nonce
acknowledge_match
Indicates that at least one link codeword with the Acknowledge bit set and with good CRC16 was 
received. The link codeword that initially set the ability_match variable should not be used to set 
this variable.
Values:
false: 
at least one link codeword with the Acknowledge bit set and with good CRC16
has not been received (default)
true: 
at least one link codeword with the Acknowledge bit set and with good CRC16
has been received
NOTE—This variable is set by this variable definition; it is not set explicitly in the state diagrams.
an_link_good
Indicates that Auto-Negotiation has completed.
Values:
false: 
negotiation is in progress (default)
true: 
negotiation is complete, forcing the Transmit and Receive functions to IDLE
an_receive_idle
Indicates that the Receive state diagram is in the IDLE state.
Values:
false: 
the Receive state diagram is not in the IDLE state (default)
true: 
the Receive state diagram is in the IDLE state
ANSP
This variable contains the type of the selected Auto-Negotiation speed.
Values:
HSM:
high-speed mode
LSM:
low-speed mode
base_page
Status indicating that the page currently being transmitted by Auto-Negotiation is the initial link 
codeword encoding used to communicate the device’s abilities.
Values:
false: 
a page other than base link codeword is being transmitted
true: 
the base link codeword is being transmitted
code_sel
A random or pseudo-random value uniformly distributed. A new value is generated each time the 


variable code_sel is used.
Values:
ZERO: 
a zero has been assigned
ONE: 
a one has been assigned
complete_ack
Controls the counting of transmitted link codewords that have their Acknowledge bit set.
Values:
false: 
transmitted link codewords with the Acknowledge bit set are not counted
(default)
true: 
transmitted link codewords with the Acknowledge bit set are counted
 
consistency_match
Indicates that the ability_match_word is the same as the link codeword that caused 
acknowledge_match to be set.
Values:
false: 
the link codeword that caused ability_match to be set is not the same as the link
codeword that caused acknowledge_match to be set, ignoring the Acknowledge
bit value and the echoed nonce value
true: 
the link codeword that caused ability_match to be set is the same as the link
codeword that caused acknowledge_match to be set, ignoring the Acknowledge
bit value and the echoed nonce value
NOTE—This variable is set by this variable definition; it is not set explicitly in the state diagrams.
detect_mv_end
Status indicating that the receiver has detected the end delimiter.
Values:
false: 
set to false after any Receive State Diagram state transition (default)
true: 
end delimiter has been detected
detect_mv_start
Status indicating that the receiver has detected a Start Delimiter as defined in 98.2.1.1.1.
Values:
false:
set to false after any Receive State Diagram state transition (default)
true: 
Start Delimiter has been detected
detect_transition
Status indicating that the receiver has detected a transition.
Values:
false: 
set to false after any Receive State Diagram state transition (default)
true: 
set to true when a transition is received
incompatible_link
Parameter used following Priority Resolution to indicate the resolved link is incompatible with the 
local device settings. A device’s ability to set this variable to true is optional.
Values:
false: 
a compatible link exists between the local device and link partner (default)
true: 
optional indication that Priority Resolution has determined no highest common
denominator exists following the most recent negotiation
NOTE—This variable is set by this variable definition; it is not set explicitly in the state diagrams. 
link_control_[x]
Controls the connection of each PMD to the MDI. When all PMD transmitters are isolated from 
the MDI, the AN transmitter is connected to the MDI.


Values:
DISABLE: isolates the PMD from the MDI
ENABLE: 
connects the PMD (both transmit and receive) to the MDI
link_status_[x]
The link_status parameter set by PMA Link Monitor and passed to the PCS via the 
PMA_LINK.indication primitive. This variable takes the values of OK or FAIL.
mr_autoneg_complete
Status indicating whether Auto-Negotiation has completed or not.
Values: 
false: 
Auto-Negotiation has not completed
true: 
Auto-Negotiation has completed
 
mr_autoneg_enable
Controls the enabling and disabling of the Auto-Negotiation function.
Values:
false: 
Auto-Negotiation is disabled
true: 
Auto-Negotiation is enabled
mr_adv_ability[48:1]
A 48-bit array that contains the Advertised Abilities link codeword. For each element within the 
array:
Values:
ZERO: 
data bit is logical zero
ONE: 
data bit is logical one
mr_lp_adv_ability[48:1]
A 48-bit array that contains the link partner’s Advertised Abilities link codeword. For each 
element within the array: 
Values:
ZERO: 
data bit is logical zero
ONE: 
data bit is logical one
mr_main_reset
Controls the resetting of the Auto-Negotiation state diagrams.
Values:
false: 
do not reset the Auto-Negotiation state diagrams
true: 
reset the Auto-Negotiation state diagrams
mr_next_page_loaded
Status indicating whether a new page has been loaded into the BASE-T1 AN NEXT PAGE 
transmit register (see 45.2.7.24).
Values:
false: 
a New Page has not been loaded
true: 
a New Page has been loaded
mr_np_tx[48:1]
A 48-bit array that contains the new Next Page to transmit. For each element within the array:
Values:
ZERO: 
data bit is logical zero
ONE: 
data bit is logical one


mr_page_rx
Status indicating whether a New Page has been received. A New Page has been successfully 
received when acknowledge_match = true and consistency_match = true and the link codeword 
has been written to mr_lp_adv_ability[48:1].
Values:
false: 
a New Page has not been received
true: 
a New Page has been received
 
mr_restart_negotiation
Controls the entrance to the TRANSMIT DISABLE state to break the link before 
Auto-Negotiation is allowed to renegotiate via management control.
Values:
false: 
renegotiation is not taking place
true: 
renegotiation is started
multispeed_autoneg_reset
See 98.5.6.1.
nonce_match
Indicates whether the transmitted nonce received from the link partner matches the transmitted 
nonce field sent by the local device.
Values:
false: 
link partner transmitted nonce does not equal local device transmitted nonce
true: 
link partner transmitted nonce equals local device transmitted nonce
np_rx
Flag to hold the value of rx_link_code_word[NP] upon entry to the COMPLETE 
ACKNOWLEDGE state. This value is associated with the value of rx_link_code_word[NP] when 
acknowledge_match was last set.
Values:
ZERO: 
local device np_rx bit equals a logical zero
ONE: 
local device np_rx bit equals a logical one
page_polarity
Starting polarity of the page.
Values:
ZERO: 
starting polarity of page is negative
ONE: 
starting polarity of page is positive
power_on
Condition that is true until such time as the power supply for the device that contains the 
Auto-Negotiation state diagrams has reached the operating region or the device has low-power 
mode set via 1000BASE-T1 PMA control register bit 1.2304.11 or via 10BASE-T1L PMA control 
register bit 1.2294.11. 
Values:
false: 
the device is completely powered (default)
true: 
the device has not been completely powered
receive_blind
Controls whether the receiver should ignore activity on the line.
Values:
true: 
ignore received DME transitions
false: 
accept received DME transitions


receive_DME_active
Status indicating whether or not a DME page reception is in progress.
Values:
true: 
DME page reception in progress
false: 
DME page reception completed
rx_link_code_word[64:1]
A 64-bit array that contains the data bits to be received from a DME page. For each element within 
the array:
Values:
ZERO: 
data bit is a logical zero
ONE: 
data bit is a logical one
rx_nonce[4:0]
A 5-bit array that contains the transmitted nonce received from the DME page that caused 
ability_match = true. For each element within the array:
Values:
ZERO: 
data bit is a logical zero
ONE: 
data bit is a logical one
TD_AUTONEG
Controls the signal sent by Auto-Negotiation on the TD_AUTONEG circuit.
Values:
disable: 
transmission of Auto-Negotiation signals is disabled
idle: 
Auto-Negotiation maintains the current signal level on the MDI
mv_end_delimiter: 
Auto-Negotiation causes the transmission of the end delimiter on the
MDI
mv_start_delimiter: 
Auto-Negotiation causes the transmission of the Start Delimiter on
the MDI as defined in 98.2.1.1.1
transition: 
Auto-Negotiation causes a transition in the level on the MDI
toggle_rx
Flag to keep track of the state of the link partner’s Toggle bit.
Values:
ZERO: 
link partner’s Toggle bit equals logical zero
ONE: 
link partner’s Toggle bit equals logical one
toggle_tx
Flag to keep track of the state of the local device’s Toggle bit.
Values:
ZERO: 
local device’s Toggle bit equals logical zero
ONE: 
local device’s Toggle bit equals logical one
transmit_ability
Controls the transmission of the link codeword containing tx_link_code_word[64:1].
Values:
false: 
any transmission of tx_link_code_word[64:1] is halted (default)
true: 
the transmit state diagram begins sending tx_link_code_word[64:1]
transmit_ack
Controls the setting of the Acknowledge bit in the tx_link_code_word[64:1] to be transmitted.
Values:
false: 
sets the Acknowledge bit in the transmitted tx_link_code_word[64:1] to a logical
zero (default)


true: 
sets the Acknowledge bit in the transmitted tx_link_code_word[64:1] to a logical
one
transmit_disable
Controls the transmission of tx_link_code_word[64:1].
Values:
false: 
tx_link_code_word[64:1] transmission is allowed (default)
true: 
tx_link_code_word[64:1]transmission is halted
transmit_DME_done
Status indicating the DME page transmission completed.
Values:
true: 
DME page transmission completed
false: 
DME page transmission in progress
transmit_DME_wait
Control indication whether a DME page can be transmitted.
Values:
true: 
pause DME page transmission
false: 
continue DME page transmission
transmit_mv_end_done
Status indicating that the transmission of the end delimiter has completed.
Values:
false: 
transmission of the end delimiter is in progress
true: 
transmission of the end delimiter has completed
transmit_mv_start_done
Status indicating that the transmission of the Start Delimiter defined in 98.2.1.1.1 has been 
completed.
Values:
false: 
transmission of the Start Delimiter is in progress
true: 
transmission of the Start Delimiter has been completed
tx_link_code_word[64:1]
A 64-bit array that contains the data bits to be transmitted in an DME page. 
tx_link_code_word[48:1] 
contains 
the 
Auto-Negotiation 
page 
to 
be 
transmitted. 
tx_link_code_word[64:49] contains the CRC16. This array may be loaded from mr_adv_ability or 
mr_np_tx. For each element within the array:
Values:
ZERO: 
data bit is logical zero
ONE: 
data bit is logical one.
98.5.2 State diagram timers
All timers operate in the manner described in 40.4.5.2.
When operating in high-speed mode, the following timer value definitions shall apply:
backoff_timer_[HSM]
Timer for the random amount of time to wait for a page to arrive from the link partner before 
transmitting a page. The timer shall expire according to the formula below after being started.
If T[4] bit is 1, the timer duration is (6805 ns to 6925 ns) + (random integer from 
0 to 15) × (2120 ns to 2240 ns).


If T[4] bit is 0, the timer duration is (7895 ns to 8015 ns) + (random integer from 
0 to 15) × (2120 ns to 2240 ns).
A new random integer from 0 to 15 inclusive is generated every time the 
backoff_timer_[HSM] is started. The random value should be uniformly distributed.
blind_timer_[HSM]
Timer for the amount of time to blind the receiver after end of transmission to prevent the 
device from seeing its own echo. The timer shall expire 2000 ns to 2120 ns after being started.
break_link_timer_[HSM]
Timer for the amount of time to wait in TRANSMIT DISABLE to assure that the link partner 
will exit from either ACKNOWLEDGE DETECT or NEXT PAGE WAIT; effect on the link 
partner in other states is not defined. The timer shall expire 300 µs to 305 µs after being 
started.
clock_detect_max_timer_[HSM]
Timer for the maximum time between detection of differential Manchester clock transitions. 
The clock_detect_max_timer_[HSM] shall expire 63 ns to 75 ns after being started or 
restarted.
clock_detect_min_timer_[HSM]
Timer for the minimum time between detection of differential Manchester clock transitions. 
The clock_detect_min_timer_[HSM] shall expire 45 ns to 57 ns after being started or restarted.
data_detect_max_timer_[HSM]
Timer for the maximum time between a clock transition and the following data transition. This 
timer is used in conjunction with the data_detect_min_timer_[HSM] to detect whether the data 
bit between two clock transitions is a logical zero or a logical one. The 
data_detect_max_timer_[HSM] shall expire 33 ns to 45 ns from the last clock transition.
data_detect_min_timer_[HSM]
Timer for the minimum time between a clock transition and the following data transition. This 
timer is used in conjunction with the data_detect_max_timer_[HSM] to detect whether the data 
bit between two clock transitions is a logical zero or a logical one. The 
data_detect_min_timer_[HSM] shall expire 15 ns to 27 ns from the last clock transition.
interval_timer_[HSM]
Timer for the separation of a transmitted clock pulse from a data bit. The 
interval_timer_[HSM] shall expire 30 ns ± 0.01% from each clock pulse and data bit.
page_test_max_timer_[HSM]
Timer for the maximum time between detection of start and end delimiters. The 
page_test_max_timer_[HSM] shall expire 4800 ns to 4920 ns after being started or restarted.
receive_DME_timer_[HSM]
Timer for the maximum amount of time to receive a complete page before timeout. The timer 
shall expire 6805 ns to 6925 ns after being started.
rx_wait_timer_[HSM]
Timer for the maximum time between detection of DME pages. This timer is used to detect 
whether the link partner is transmitting DME pages. The rx_wait_timer_[HSM] shall expire 
15 µs to 17 µs after being started or restarted.


silent_timer_[HSM]
Timer for the amount of time to wait after receiving a page before transmitting a page. The 
timer shall expire 2120 ns to 2240 ns after being started.#
When operating in low-speed mode, the following timer value definitions shall apply:
backoff_timer_[LSM]
Timer for the random amount of time to wait for a page to arrive from the link partner before 
transmitting a page. The timer shall expire according to the formula below after being started. 
If T[4] bit is 1, the timer duration is (156 300 ns to 159 500 ns) + (random integer from 
0 to 15) × (31 400 ns to 34 600 ns).
If T[4] bit is 0, the timer duration is (172 800 ns to 176 000 ns) + (random integer from 
0 to 15) × (31 400 ns to 34 600 ns).
A new random integer from 0 to 15 inclusive is generated every time the 
backoff_timer_[LSM] is started. The random value should be uniformly distributed.
blind_timer_[LSM]
Timer for the amount of time to blind the receiver after end of transmission to prevent the 
device from seeing its own echo. The timer shall expire 28 200 ns to 31 400 ns after being 
started.
break_link_timer_[LSM]
Timer for the amount of time to wait in TRANSMIT DISABLE to assure that the link partner 
will exit from either ACKNOWLEDGE DETECT or NEXT PAGE WAIT; effect on the link 
partner in other states is not defined. The timer shall expire 8000 µs to 8133 µs after being 
started.
clock_detect_max_timer_[LSM]
Timer for the maximum time between detection of differential Manchester clock transitions. 
The clock_detect_max_timer_[LSM] shall expire 1680 ns to 2000 ns after being started or 
restarted.
clock_detect_min_timer_[LSM]
Timer for the minimum time between detection of differential Manchester clock transitions. 
The clock_detect_min_timer_[LSM] shall expire 1200 ns to 1520 ns after being started or 
restarted.
data_detect_max_timer_[LSM]
Timer for the maximum time between a clock transition and the following data transition. This 
timer is used in conjunction with the data_detect_min_timer_[LSM] to detect whether the data 
bit between two clock transitions is a logical zero or a logical one. The 
data_detect_max_timer_[LSM] shall expire 880 ns to 1200 ns from the last clock transition.
data_detect_min_timer_[LSM]
Timer for the minimum time between a clock transition and the following data transition. This 
timer is used in conjunction with the data_detect_max_timer_[LSM] to detect whether the data 
bit between two clock transitions is a logical zero or a logical one. The 
data_detect_min_timer_[LSM] shall expire 400 ns to 720 ns from the last clock transition.
interval_timer_[LSM]
Timer for the separation of a transmitted clock pulse from a data bit. The 
interval_timer_[LSM] shall expire 800 ns ± 0.005% from each clock pulse and data bit.
page_test_max_timer_[LSM]
Timer for the maximum time between detection of start and end delimiters. The 
page_test_max_timer_[LSM] shall expire 128 000 ns to 131 200 ns after being started or 
restarted.


receive_DME_timer_[LSM]
Timer for the maximum amount of time to receive a complete page before timeout. The timer 
shall expire 156 300 ns to 159 500 ns after being started.
rx_wait_timer_[LSM]
Timer for the maximum time between detection of DME pages. This timer is used to detect 
whether the link partner is transmitting DME pages. The rx_wait_timer_[LSM] shall expire 
330 µs to 370 µs after being started or restarted.
silent_timer_[LSM]
Timer for the amount of time to wait after receiving a page before transmitting a page. The 
timer shall expire 31 400 ns to 34 600 ns after being started.
Depending on the selected PHY type, done by Auto-Negotiation, the following timer values shall be used:
link_fail_inhibit_timer_[HCD]
Timer for qualifying a link_status=FAIL indication or a link_status=OK indication when a 
specific technology link is first being established. A link will be considered “failed” only if the 
link_fail_inhibit_timer_[HCD] has expired and the link has still not gone into the 
link_status=OK state. The expiration time of the link_fail_inhibit_timer_[HCD] shall be 
dependent on the selected PHY type. For all PHY types, except 10BASE-T1L and 
10BASE-T1S, this timer shall expire 97 ms to 98 ms after entering the AN GOOD CHECK 
state. For a 10BASE-T1L PHY, this timer shall expire 3030 ms to 3090 ms after entering the 
AN GOOD CHECK state. For a 10BASE-T1S PHY, this timer shall expire 400 ms to 405 ms 
after entering the AN GOOD CHECK state.
NOTE—The link_fail_inhibit_timer_[HCD] expiration value is greater than the time required for the link partner to 
complete Auto-Negotiation after the local device has completed Auto-Negotiation plus the time required for the specific 
technology to enter the link_status=OK state.
98.5.3 State diagram counters
remaining_ack_cnt
A counter that may take on integer values from 0 to 3. The number of additional link codewords 
with the Acknowledge Bit set to logical one to be sent to ensure that the link partner receives the 
acknowledgment.
Values:
not_done: 
positive integers between 0 and 2 inclusive
done: 
positive integer 3
init:
counter is reset to zero
rx_bit_cnt
A counter that may take on integer values from 0 to 64. This counter is used to keep a count of data 
bits received from a DME page and to ensure that when erroneous extra transitions are received, 
the first 48 bits are kept while the next 16 bits are used for CRC16 check and any additional bits 
are ignored. When this counter reaches 64, enough data bits have been received. This counter does 
not increment beyond 64 and does not return to 0 until it is reinitialized. 
tx_bit_cnt
A counter that may take on integer values from 1 to 64. This counter is used to keep a count of 
data bits sent within a DME page. When this counter reaches 64, all data bits have been sent.


98.5.4 Function
CRC16(x[48:1])
Returns the output of the CRC16 generator described in 98.2.1.1.1 after processing 
the 48-bit input x.
98.5.5 State diagrams
Figure 98–7—Arbitration state diagram
ABILITY DETECT
transmit_ability  true
toggle_tx  mr_adv_ability[12]
ability_match  false
acknowledge_match  false
tx_link_code_word[48:1]  mr_adv_ability[48:1]
mr_page_rx  false
base_page  true
ack_finished  false
consistency_match  false
TRANSMIT DISABLE
ACKNOWLEDGE DETECT
if(base_page = true) then
tx_link_code_word[10:6]  rx_nonce[4:0]
transmit_ability  true
transmit_ack  true
link_control_[all]  DISABLE
COMPLETE ACKNOWLEDGE
complete_ack  true
transmit_ability  true
transmit_ack  true
toggle_rx  rx_link_code_word[12]
toggle_tx  !toggle_tx
mr_page_rx  true
np_rx  rx_link_code_word[NP]
mr_lp_adv_ability  rx_link_code_word[48:1]
NEXT PAGE WAIT
transmit_ability  true
mr_page_rx  false
base_page  false
tx_link_code_word[48:13]  mr_np_tx[48:13]
tx_link_code_word[12]  toggle_tx
tx_link_code_word[11:1]  mr_np_tx[11:1]
ack_finished  false
mr_next_page_loaded  false
AN GOOD CHECK
Auto-Negotiation ENABLE
mr_page_rx  false
mr_autoneg_complete  false
AN GOOD
an_link_good  true
mr_autoneg_complete  true
break_link_timer_[ANSP]_done
(acknowledge_match = true *
(consistency_match = false +
(ack_nonce_match = false *
base_page = true))) +
an_receive_idle = true
acknowledge_match = true *
(ack_nonce_match = true +
base_page = false) *
consistency_match = true
ability_match = true * nonce_match = false
ack_finished = true *
mr_next_page_loaded = true *
((tx_link_code_word[NP] = 1) +
(np_rx = 1))
ability_match = true *
nonce_match = true
ability_match = true *
((toggle_rx ^ ability_match_word[12]) = 1)
ack_finished = true *
tx_link_code_word[NP] = 0 *
np_rx = 0
multispeed_autoneg_reset = true + 
mr_main_reset = true +
mr_restart_negotiation = true +
mr_autoneg_enable = false
link_status_[HCD] = OK
link_status_[HCD] = FAIL
(link_status_[HCD] = FAIL *
link_fail_inhibit_timer_[HCD]_done) +
incompatible_link = true
an_receive_idle = true
link_control_[HCD]  ENABLE
an_link_good  true
start link_fail_inhibit_timer_[HCD]
power_on = true +
mr_autoneg_enable = true
start break_link_timer_[ANSP]
link_control_[all] DISABLE
transmit_disable true
mr_page_rx false
mr_autoneg_complete false
mr_next_page_loaded false


Figure 98–8—Transmit state diagram
WAIT 2
TD_AUTONEG  disable
transmit_DME_done  false
page_polarity  code_sel
remaining_ack_cnt  remaining_ack_cnt + 1
if (remaining_ack_cnt = done)
then ack_finished  true
TRANSMIT REMAINING
ACKNOWLEDGE
remaining_ack_cnt  init
TRANSMIT CLOCK BIT
TRANSMIT DELIMITER TAIL
TD_AUTONEG  mv_end_delimiter
transmit_DME_done  true
TRANSMIT DELIMITER HEAD
TD_AUTONEG  mv_start_delimiter
remaining_ack_cnt  done
WAIT 1
TD_AUTONEG  disable
transmit_DME_done  false
page_polarity  code_sel
IDLE
TD_AUTONEG  disable
TRANSMIT COUNT ACK
TD_AUTONEG  mv_start_delimiter
TRANSMIT ABILITY
tx_bit_cnt  1
tx_link_code_word[64:49]  
CRC16(tx_link_code_word[48:1])
TRANSMIT DATA BIT
start interval_timer_[ANSP]
if (tx_link_code_word[tx_bit_cnt] = 1)
then TD_AUTONEG  transition
else TD_AUTONEG  idle
tx_bit_cnt  tx_bit_cnt + 1
power_on = true +
mr_main_reset = true +
mr_autoneg_enable = false +
an_link_good = true +
transmit_disable = true
complete_ack = false *
transmit_ability = true *
transmit_mv_start_done
remaining_ack_cnt = done +
ack_finished = true +
complete_ack = false
transmit_DME_wait false
UCT
transmit_DME_wait = false
transmit_mv_end_done *
remaining_ack_cnt = done
complete_ack = true *
transmit_mv_start_done
UCT
UCT
interval_timer_[ANSP]_done
transmit_mv_end_done *
remaining_ack_cnt = not_done
transmit_mv_start_done
interval_timer_[ANSP]_done
tx_bit_cnt = 64
start interval_timer_[ANSP]
TD_AUTONEG  transition
multispeed_autoneg_reset = true +


Figure 98–9—Receive state diagram
detect_mv_start = true *
detect_mv_end = true *
UCT
an_link_good = true +
mr_autoneg_enable = false +
power_on = true +
mr_main_reset = true +
UCT
page_test_max_timer_[ANSP]_done
page_test_max_timer_[ANSP]_done
transmit_disable = true
IDLE
an_receive_idle  true
receive_DME_active false
DELIMITER WAIT
receive_DME_active  false
start rx_wait_timer_[ANSP]
DME_CAPTURE
rx_bit_cnt  0
start page_test_max_timer_[ANSP]
receive_DME_active  true
DME CLOCK
start data_detect_max_timer_[ANSP]
start data_detect_min_timer_[ANSP]
rx_bit_cnt  rx_bit_cnt + 1
start clock_detect_max_timer_[ANSP]
start clock_detect_min_timer_[ANSP]
detect_transition = true *
receive_blind = false *
clock_detect_min_timer_[ANSP]_done *
clock_detect_max_timer_[ANSP]_not_done
DME DATA_1
rx_link_code_word[rx_bit_cnt] 1
DME DATA_0
rx_link_code_word[rx_bit_cnt] 0
detect_transition = true *
receive_blind = false *
data_detect_min_timer_[ANSP]_done *
data_detect_max_timer_[ANSP]_not_done
A
detect_transition = true *
receive_blind = false *
clock_detect_min_timer_[ANSP]_done *
clock_detect_max_timer_[ANSP]_not_done
receive_blind = false
detect_mv_start = true *
receive_blind = false
rx_wait_timer_[ANSP]_done
A
detect_mv_end = true *
receive_blind = false
A
receive_blind = false
multispeed_autoneg_reset = true +


98.5.6 High-speed and low-speed Auto-Negotiation modes
A PHY supporting two different Auto-Negotiation speeds, as described in 98.2.1.1.2, shall implement the 
behavior shown in Figure 98–11. Figure 98–11 determines the mode used for the timers in Figure 98–7, 
Figure 98–8, Figure 98–9, Figure 98–10, and Figure 98–11 through the variable ANSP and synchronizes 
them through the variable multispeed_autoneg_reset.
Figure 98–10—Half-duplex state diagram
BLIND
transmit_DME_wait  true
receive_blind  true
start blind_timer_[ANSP]
RECEIVE WAIT
start backoff_timer_[ANSP]
receive_blind  false
RECEIVE ACTIVE
stop backoff_timer_[ANSP]
start receive_DME_timer_[ANSP]
SILENT
stop receive_DME_timer_[ANSP]
start silent_timer_[ANSP]
TRANSMIT ACTIVE
transmit_DME_wait  false
receive_blind  true
an_link_good = true +
mr_autoneg_enable = false +
power_on = true +
mr_main_reset = true +
transmit_disable = true
blind_timer_[ANSP]_done
receive_DME_active = true
receive_DME_active = false
silent_timer_[ANSP]_done
receive_DME_timer_[ANSP]_done
backoff_timer_[ANSP]_done
transmit_DME_done = true
multispeed_autoneg_reset = true +


A PHY supporting only one Auto-Negotiation speed shall implement the behavior as shown in Figure 98–7, 
Figure 98–8, Figure 98–9, and Figure 98–10, using the associated timer values for high-speed mode (HSM) 
or low-speed mode (LSM) Auto-Negotiation as described in 98.5.2.
98.5.6.1 Variables
an_link_good
See 98.5.1.
ANSP
See 98.5.1.
mr_autoneg_enable
See 98.5.1.
mr_main_reset
See 98.5.1.
mr_restart_negotiation
See 98.5.1.
multispeed_autoneg_reset
If two different Auto-Negotiation speeds are implemented and this variable is set to true by 
the state diagram in Figure 98–11, then the state diagrams in Figure 98–7, Figure 98–8, 
Figure 98–11—Auto-Negotiation—high-speed mode and low-speed mode selection
LOW-SPEED AN
start failure_timer
stop detection_timer
ANSP LSM
multispeed_autoneg_reset false
SPEED DETECTION
start detection_timer
stop failure_timer
multispeed_autoneg_reset true
power_on +
mr_main_reset +
mr_restart_negotiation +
!mr_autoneg_enable
HIGH-SPEED AN
start failure_timer
stop detection_timer
ANSP HSM
multispeed_autoneg_reset false
an_link_good
AN COMPLETE
stop failure_timer
failure_timer_done
failure_timer_done
low_speed_autoneg +
detection_timer_done
high_speed_autoneg
an_link_good
!an_link_good


Figure 98–9, and Figure 98–10 are restarted. If only single speed Auto-Negotiation is 
implemented, then this variable remains set to false.
Values: 
true: Auto-Negotiation state diagrams are restarted
false: Auto-Negotiation state diagrams are in normal operation
power_on
See 98.5.1.
98.5.6.2 Functions
high_speed_autoneg
This function returns true if at least the last 12 received DME pulses are within the allowed 
range for the high-speed Auto-Negotiation communication (15 ns to 135 ns pulse width) 
including the violations of the DME encoding within the start delimiter; otherwise, this 
function returns false.
Values: true or false
low_speed_autoneg
This function returns true if at least the last 12 received DME pulses are within the allowed 
range for the low-speed Auto-Negotiation communication (400 ns to 2000 ns pulse width) 
including the violations of the DME encoding within the start delimiter; otherwise, this 
function returns false.
Values: true or false
98.5.6.3 Timers
All timers operate in the manner described in 40.4.5.2.
detection_timer
This timer limits the maximum time for detection of Auto-Negotiation frames sent by the far 
end PHY, before starting to send its own Auto-Negotiation frames at low-speed. This timer is 
not automatically restarted after expiration. A new random integer from 0 to 15 inclusive is 
generated every time the detection_timer is started. The random value should be uniformly 
distributed.
Timer value: (10 ms ± 0.1 ms) + (random integer from 0 to 15) × (0.5 ms ± 0.05 ms)
failure_timer
This timer limits the maximum time for the underlying Auto-Negotiation state diagrams to 
complete the Auto-Negotiation process before restarting the Auto-Negotiation process. This 
timer is not automatically restarted after expiration.
Timer value: 250 ms ± 1 ms


---

<a id='clause-147'></a>
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

