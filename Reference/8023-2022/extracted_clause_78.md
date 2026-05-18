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





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



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