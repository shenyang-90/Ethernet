# Clause 104: Power over Data Lines (PoDL) of Single-Pair Ethernet

**Focus**: PoDL PSE/PD operation, power classification, serial communication classification protocols

**Pages extracted**: 4371 – 4409

**Excluded from**: Page 4410 (electrical/PICS section)

104. Power over Data Lines (PoDL) of Single-Pair Ethernet
104.1 Overview
This clause defines the functional and electrical characteristics of two optional power entities, a PoDL 
Powered Device (PD) and PoDL Power Sourcing Equipment (PSE), for use with supported single balanced 
twisted-pair Ethernet Physical Layers. When used in this clause, the term PSE always means PoDL PSE, 
and the term PD always means PoDL PD. These entities allow devices to supply/draw power using the same 
cabling that may be used for data transmission. PoDL is intended to provide a single balanced twisted-pair 
Ethernet Physical Layer device with a single interface to both the data it requires and the power to process 
this data. This clause specifies the following:
a)
The characteristics of a power source to add power to the 100  single balanced twisted-pair cabling 
system.
b)
The characteristics of a PD’s load on the power source and the cabling.
c)
Certain electrical parameters of each MDI/PI that may be different from that specified in the PHY 
clause when power is simultaneously transmitted with data.
d)
Physical Layer protocols allowing the detection of a device that requests power from a PSE and 
classification of the device based on its power needs.
e)
A method for Powered Devices and Power Sourcing Equipment to negotiate and allocate power.
f)
A method for scaling supplied voltage back to the sleep level when full operating voltage is no lon-
ger requested or required.
This clause differentiates between the two ends of the link, defining the PSE and the PD as separate but 
related devices within a PoDL system.
104.1.1 Compatibility considerations
Compliant implementations of PD and PSE systems are defined as compatible at their respective Power 
Interfaces (PIs) when used in accordance with the restrictions of this clause. Designers are free to implement 
circuitry within the PD and PSE in an application-dependent manner provided that the respective PI 
specifications are satisfied. MDIs that incorporate compliant PoDL PIs are compatible with their respective 
Physical Layer standards. Such compatibility may require additional specifications found within this clause 
(see 104.6).
104.1.2 Relationship of PoDL to the IEEE 802.3 architecture
PoDL is an optional power entity to be used in conjunction with supported single-pair Ethernet Physical 
Layers. Data that is out of band to normal Ethernet traffic may be transmitted and received between the PSE 
and PD prior to the application of power and subsequent to the removal of full operating voltage via the MDI 
using the Serial Communication Classification Protocol (SCCP) which is described in 104.7.
Figure 104–1 depicts the positioning of PoDL for the PSE. Figure 104–2 depicts the positioning of PoDL in 
the case of the PD.

The Power Interface (PI) is the generic term that refers to the mechanical and electrical interface between the 
PSE or PD and the transmission medium. The PI is encompassed within the MDI.
104.1.3 PoDL system types
A PoDL system consists of a PSE, a link segment, and a PD. PoDL systems are not specified for mixing 
segments.
A Type A or Type C PSE and Type A or Type C PD are compatible with 10BASE-T1S and 100BASE-T1 
PHYs. A Type B or Type C PSE and Type B or Type C PD are compatible with 1000BASE-T1 PHYs. 
A Type C PSE and Type C PD are compatible with 10BASE-T1S, 100BASE-T1, and 1000BASE-T1 PHYs. 
Type D PSEs and Type D PDs may be incompatible with IEEE 802.3 PHYs and may lack a data entity. 
A Type E PSE and Type E PD are compatible with 10BASE-T1L PHYs. A Type F PSE and Type F PD are 
compatible with 2.5GBASE-T1, 5GBASE-T1, and 10GBASE-T1 PHYs.
Figure 104–1—PoDL Power Sourcing Equipment (PSE) relationship to the physical 
interface circuitry and the IEEE 802.3 Ethernet model
MDI/PI
MDI = Medium Dependent Interface
PHY = Physical Layer Device
PHY
PSE
Physical Interface Circuitry
PSE = Power Sourcing Equipment
PI = Power Interface
Medium
Figure 104–2—PoDL Powered Device (PD) relationship to the physical interface circuitry 
(PHY) and the IEEE 802.3 Ethernet model
MDI/PI
Medium
MDI = Medium Dependent Interface
PHY = Physical Layer Device
PHY
PD
Physical Interface Circuitry
PD = Powered Device
PI = Power Interface

Figure 104–3 illustrates the block diagram for a PoDL system.
104.2 Link segment
The dc loop resistance of the link segment shall be less than 6  for classes 0 and 1. The dc loop resistance 
shall be less than 6.5  for classes 2 through 9. The link segment dc loop resistance shall be less than 65 
for classes 10 and 13. The link segment dc loop resistance shall be less than 25  for classes 11 and 14. The 
link segment dc loop resistance shall be less than 9.5  for classes 12 and 15.
104.3 Class power requirements
PSEs and PDs are further categorized by their class. These classes and the relevant electrical specifications 
are shown in Table 104–1 and Table 104–2.
Table 104–1—Class power requirements matrix for PSE, PI, and PD
for classes 0 through 9 
12 V
unregulated 
PSE
12 V
regulated 
PSE
24 V
unregulated
PSE
24 V 
regulated 
PSE
48 V 
regulated 
PSE
Class
VPSE(max) (V)a
VPSE_OC(min) (V)b
14.4
14.4
VPSE(min) (V)
5.6
5.77
14.4
14.4
11.7
11.7
IPI(max) (mA)c
1 360
PClass(min) (W)d
0.566
1.31
3.59
6.79
1.14
3.97
5.59
35.3
65.3
NOTE—PI elements that prevent loading of the data signal by the PSE and PD are not shown. 
PHY elements that block dc are not shown.
Figure 104–3—PoDL system block diagram
PSE
PI+
PI-
PHY
BI_DA+
BI_DA-
PI+
PI-
BI_DA+
BI_DA-
PD
PHY
Link Segment
MDI/PI
MDI/PI

104.4 Power Sourcing Equipment (PSE)
The PSE provides power to the PD. The PSE’s main functions are as follows:
a)
To search the link segment for a PD
b)
To supply power to a detected PD through the link segment
c)
To monitor the power applied to a link segment
d)
To remove the full operating voltage when no longer required, when transitioning to the SLEEP 
state, or when a short-circuit or other fault is detected
Voltage and power classification mechanisms exist via the Serial Communication Classification Protocol 
(SCCP) to provide the PSE with detailed information regarding the requirements of the PD and vice versa.
A PSE is specified by its electrical and logical behavior as seen at the PI.
VPD(min) (V)
4.94
4.41
10.6
10.3
8.86
23.3
21.7
40.8
36.7
PPD(max) (W)e
0.5
aVPSE(max) is the maximum allowed voltage at the PSE PI over the full range of operating conditions.
bVPSE_OC(min) is the minimum allowed open circuit voltage measured at the PSE PI.
cIPI(max) is the maximum current flowing at the PSE and PD PIs except during inrush or an overload condition. IPI(max)
may be exceeded during inrush or an overload (see 104.4.7.2). Users are cautioned to be aware of the ampacity of 
cabling, as installed, and local codes and regulations (see 104.8.1).
dPClass(min) is the minimum average available output power at the PSE PI.
ePPD(max) is the maximum average available power at the PD PI.
Table 104–2—Class power requirements matrix for PSE, PI, and PD
for classes 10 through 15 
Class
VPSE(max) (V)
VPSE_OC(min) (V)
VPSE(min) (V)
IPI(max) (mA)
Pclass(min) (W)
1.85
4.8
12.63
11.54
VPD(min) (V)
PPD(max) (W)
1.23
3.2
8.4
7.7
Table 104–1—Class power requirements matrix for PSE, PI, and PD
for classes 0 through 9 (continued)
12 V
unregulated 
PSE
12 V
regulated 
PSE
24 V
unregulated
PSE
24 V 
regulated 
PSE
48 V 
regulated 
PSE
Class

104.4.1 PSE types
For PoDL systems there are multiple types of PSEs—Type A, Type B, Type C, Type D, Type E, and Type F 
consistent with 104.1.3.
104.4.2 PI pin assignments
A PSE provides power via a single two-wire connection. Table 104–3 in conjunction with Figure 104–3 
illustrates the PSE pinout.
A PSE shall implement the PSE pinout in Table 104–3.
104.4.3 PSE classes
A PSE shall comply with the voltage and power requirements listed in Table 104–1 for the relevant class. 
104.4.4  PSE state diagram
The PSE shall implement the behavior of the state diagrams shown in Figure 104–4, Figure 104–5, and 
Figure 104–6.
104.4.4.1 Overview
Prior to application of full operating voltage at the PI, the PSE performs detection in order to verify that a 
valid PD is present. A PSE may apply full operating voltage if it is able to successfully classify the PD using 
SCCP.
After full operating voltage has been applied, the PSE monitors the PI for a valid Maintain Full Voltage 
Signature (MFVS) from the PD. In the event a valid MFVS is not present, the PSE reduces the voltage at the 
PI to the range of VSleep. If an external wakeup request is received or if a valid wakeup current signature is 
detected at the PI, the PSE confirms that a valid PD is present by re-performing detection and, if enabled, 
classification before reapplying full operating voltage to the PI.
Additionally, while voltage is applied, the PSE monitors the current drawn and removes power if it detects 
an overload, short-circuit, or other fault.
104.4.4.2 Conventions
The notation used in the state diagrams follows the conventions of state diagrams as described in 21.5.
104.4.4.3 Variables
The PSE state diagrams use the following variables:
Table 104–3—PSE pinout
Contact
PI
PI+
PI–

detection_done
TRUE: the detection sequence has terminated since the last entry to the IDLE state either as a result of 
a valid or invalid signature being detected.
FALSE: the detection sequence has not terminated since the last entry to the IDLE state either as a 
result of a valid or invalid signature being detected.
do_classification_done
TRUE: following a detection sequence, the PSE has concluded serial communication after performing 
a read of the PD information and any additional implementation dependent read or write commands.
FALSE: following a detection sequence, the PSE has not concluded serial communication after 
performing a read of the PD information and any additional implementation dependent read or write 
commands.
external_wakeup
TRUE: while in the SLEEP state, the PSE has received an external wakeup request.
FALSE: while in the SLEEP state, the PSE has not received an external wakeup request.
iprebias_valid
TRUE: the PSE pre-bias output current is valid (see 104.4.7.2.3).
FALSE: the PSE pre-bias output current is invalid (see 104.4.7.2.3).
mfvs_timeout
TRUE: the MFVS dropout timer has timed out.
FALSE: the MFVS dropout timer has not timed out.
mfvs_valid
TRUE: MFVS is present (see 104.4.8.1).
FALSE: MFVS is absent (see 104.4.8.1).
mr_pse_enable
TRUE: enable operation of the PSE.
FALSE: disable operation of the PSE.
mr_sccp_enabled
TRUE: SCCP is enabled (see 104.7).
FALSE: SCCP is not enabled (see 104.7).
mr_invalid_signature
TRUE: an invalid signature has been detected during the detection cycle subsequent to the last idle 
sequence.
FALSE: an invalid signature has not been detected.
mr_valid_signature
TRUE: a valid PD signature has been detected during the detection cycle subsequent to the last idle 
sequence.
FALSE: a valid PD signature has not been detected.
overload_detected
TRUE: the PSE has detected an overload condition (see 104.4.7.2.1).
FALSE: the PSE has not detected an overload condition.
overload_held
TRUE: overload_detected has been TRUE since last entry to the IDLE state.
FALSE: overload_detected has been FALSE since last entry to the IDLE state.

pd_wakeup
TRUE: while in the SLEEP state, the PSE has detected a valid wakeup current signature.
FALSE: while in the SLEEP state, the PSE has not detected a valid wakeup current signature.
pi_classifying
TRUE: the PSE is performing classification at the PI (see 104.7).
FALSE: the PSE is not performing classification at the PI.
pi_detecting
TRUE: the circuitry that forces a voltage limited detection current and senses the voltage at the PI is 
enabled (see 104.4.5).
FALSE: the circuitry that forces a voltage limited detection current and senses the voltage at the PI is 
disabled.
pi_discharge_en
TRUE: the circuitry that discharges the PI to VSleep is enabled.
FALSE: the circuitry that discharges the PI to VSleep is disabled.
pi_powered
TRUE: the circuitry that applies full operating voltage to the PI is enabled.
FALSE: the circuitry that applies full operating voltage to the PI is disabled.
pi_prebiased
TRUE: the circuitry that applies VSleep at the PI during the RESTART, RESTART_DELAY, and 
IDLE states is enabled (see 104.4.7.1).
FALSE: the circuitry that applies VSleep at the PI is disabled.
pi_sleeping
TRUE: the circuitry that applies VSleep at the PI during the SETTLE_SLEEP and SLEEP states is 
enabled (see 104.4.7.1).
FALSE: the circuitry that applies VSleep at the PI is disabled.
power_stable
TRUE: following inrush, the PSE has begun steady-state operation.
FALSE: the PSE is either not applying full operating voltage or has begun applying full operating 
voltage but is still in the POWER_UP state.
power_available
TRUE: a compatible PSE class to PD class pairing exists as defined in Table 104–4 and Table 104–5, 
and the PSE is able to source the required voltage and power.
FALSE: a valid PSE class to PD class pairing does not exist as defined in Table 104–4 and 
Table 104–5, or the PSE is not able to source the required voltage and power.
pse_ready
TRUE: the PSE is ready to probe the link segment.
FALSE: the PSE is not ready to probe the link segment.
pse_reset
Controls the resetting of the PSE state diagram. Condition that is TRUE until such time as the power 
supply for the device that implements the PSE overall state diagrams has reached the operating region. 
It is also TRUE when implementation-specific reasons require reset of PSE functionality.
valid_class
TRUE: valid class information was received from the PD during SCCP.

FALSE: valid class information was not received from the PD during SCCP.
vsleep_valid
TRUE: VPSE is in the range of VSleep.
FALSE: VPSE is outside the range of VSleep.
vsig_valid
TRUE: a valid PD signature has been detected as defined in 104.4.5.2 and 104.4.5.3.
FALSE: an invalid PD signature has been detected as defined in 104.4.5.2 and 104.4.5.3. 
Table 104–4—PSE power_available matrix for PSE and PD
for classes 0 through 9 
PSE Classa
aAn ‘x’ denotes a valid PSE to PD Class pairing.
12V unreg
12V reg
24V unreg
24V reg
48V reg
PD Classa
12V 
unreg
x
x
x
x
—
—
—
—
—
—
—
x
x
x
—
—
—
—
—
—
12V 
reg
—
—
x
x
—
—
—
—
—
—
—
—
—
x
—
—
—
—
—
—
24V 
unreg
—
—
—
—
x
x
x
x
—
—
—
—
—
—
—
x
x
x
—
—
24V 
reg
—
—
—
—
—
—
x
x
—
—
—
—
—
—
—
—
—
x
—
—
48V 
reg
—
—
—
—
—
—
—
—
x
x
—
—
—
—
—
—
—
—
—
x
Table 104–5—PSE power_available matrix for PSE and PD
for classes 10 through 15 
PSE Classa
aAn ‘x’ denotes a valid PSE to PD Class pairing.
Classes 0 to 9
30V reg
58V reg
PD Classa
Classes 0 to 9
See Table 104–4
—
—
—
—
—
—
30V 
reg
—
x
x
x
—
—
—
—
—
x
x
—
—
—
—
—
—
x
—
—
—
58V 
reg
—
—
—
—
x
x
x
—
—
—
—
—
x
x
—
—
—
—
—
—
x

104.4.4.4 Timers
All timers operate in the manner described in 14.2.3.2 with the following addition: a timer is reset and stops 
counting upon entering a state where “stop x_timer” is asserted.
tclass_timer
A timer used to limit the time allowed for classifying a PD (see TClass in Table 104–7).
tdet_timer
A timer used to limit the time allowed for attempting to detect a PD (see Tdet in Table 104–6).
tod_timer
A timer used to regulate a subsequent attempt to power a PD after an overload condition that causes a 
fault (see Tod in Table 104–7).
tinrush_timer
A timer used to limit the duration of the inrush event (see TInrush in Table 104–7).
tmfvdo_timer
A timer used to monitor the dropout of MFVS (see TMFVDO in Table 104–7).
toff_timer
A timer used to limit the time the PSE attempts to discharge the PI to the range of VSleep (see TOFF in 
Table 104–7). If toff_timer expires during the SETTLE_SLEEP state, an overload condition exists, 
and the port state diagram enters the OVERLOAD state.
trestart_timer
A timer used to regulate a subsequent attempt to power a PD after an error condition that does not 
result in a fault (see TRestart in Table 104–7).
vsig_hold_timer
A timer used to de-glitch the PD signature voltage valid output in the detection state diagram (see 
Tsig_hold in Table 104–6).
104.4.4.5 Functions
do_classification
This function returns the following variables:
CLASS_TYPE_INFO register:
Refer to Table 104–13 for a description of the contents.
VOLT_INFO register:
PSEs that support cable resistance measurement also return the VOLT_INFO register. 
Refer to Table 104–14 for a description of the contents.
POWER_INFO register:
PSEs that support cable resistance measurement also return the POWER_INFO register. 
Refer to Table 104–15 for a description of the contents.
POWER_ASSIGN register:
PSEs that support cable resistance measurement also return the POWER_ASSIGN 
register. Refer to Table 104–16 for a description of the contents.

104.4.4.6 State diagram
Figure 104–4—PSE state diagram
DISABLED
pse_reset + !mr_pse_enable
pi_sleeping  FALSE
pi_prebiased  FALSE
pi_detecting  FALSE
pi_classifying FALSE
pi_powered  FALSE
pi_discharge_en  FALSE
overload_held  FALSE
DETECTION
pi_prebiased  FALSE
pi_sleeping  FALSE
pi_detecting  TRUE
IDLE
detection_done  FALSE
mr_valid_signature  FALSE
mr_invalid_signature  FALSE
pi_prebiased  TRUE
overload_held  FALSE
DETECTION_EVAL
CLASSIFICATION
start tclass_timer
pi_detecting  FALSE
pi_classifying  TRUE
do_classification
CLASSIFICATION_EVAL
stop tclass_timer
POWER_UP
pi_detecting  FALSE
pi_classifying  FALSE
pi_powered  TRUE
start tinrush_timer
RESTART
pi_prebiased  TRUE
pi_detecting  FALSE
pi_classifying  FALSE
pi_powered  FALSE
RESTART_DELAY
start trestart_timer
POWER_ON
SETTLE_SLEEP
pi_sleeping  TRUE
pi_powered  FALSE
pi_discharge_en  TRUE
start toff_timer
SLEEP
pi_discharge_en  FALSE
mr_valid_signature  FALSE
mr_invalid_signature  FALSE
OVERLOAD
pi_sleeping  FALSE
pi_prebiased  FALSE
pi_powered  FALSE
pi_discharge_en  FALSE
overload_held  TRUE
OVERLOAD_DELAY
start tod_timer
mr_pse_enable
pd_wakeup + external_wakeup
vsleep_valid * 
!toff_timer_done
tod_timer_done
pse_ready * 
iprebias_valid
detection_done
mr_valid_signature * 
!mr_sccp_enabled *
power_available
power_available *
valid_class
mr_sccp_enabled
(mr_invalid_signature +
!power_available) *
!mr_sccp_enabled
tclass_timer_done
!valid_class +
!power_available
tinrush_timer_done
UCT
 power_stable * 
!tinrush_timer_done
mfvs_timeout
toff_timer_done
UCT
trestart_timer_done
overload_detected * mr_pse_enable
!tclass_timer_done * 
do_classification_done
!power_available

Figure 104–5—Detection state diagram
!pi_detecting
pi_detecting
IDLE_DETECT
stop vsig_hold_timer
UCT
ENABLE_TDETECT
start tdet_timer
MONITOR
stop vsig_hold_timer
vsig_valid
DEGLITCH
start vsig_hold_timer
!vsig_valid
VALID_SIGNATURE
mr_valid_signature  TRUE
UCT
tdet_timer_done
tdet_timer_done
vsig_valid *
vsig_hold_timer_done *
!tdet_timer_done
INVALID_SIGNATURE
mr_invalid_signature  TRUE
UCT
DONE
detection_done  TRUE
Figure 104–6—MFVS state diagram
!pi_powered
pi_powered
IDLE_MFVS
!mfvs_valid 
MONITOR_MFVS
mfvs_valid 
DETECT_MFVS
stop tmfvdo_timer
mfvs_timeout FALSE
TIMEOUT_MFVS
mfvs_timeout TRUE
start tmfvdo_timer
!mfvs_valid *
tmfvdo_timer_done 

104.4.5 PSE detection of a PD
When in the DETECTION state, the PSE shall complete detection of a valid PD signature within Tdet as 
specified in Table 104–6. If a valid signature is not detected and classification is not performed, the PSE 
shall wait at least TRestart before reattempting detection. If a valid signature is detected and classification is 
not performed, the PSE may proceed to the POWER_UP state. A PSE may successfully detect a PD but then 
opt not to power the detected PD.
104.4.5.1 Detection probe requirements
All detection currents at the PI shall be within the Ivalid current range, as specified in Table 104–6, when 
connected to a valid PD detection signature as specified in Table 104–9. The detection probe shall conform 
to VOC, ISC, Islew, and Cout as specified in Table 104–6.
104.4.5.2 Detection criteria
A PSE shall accept as a valid PD signature a link segment with a voltage in the range of Vgood_PSE for at 
least Tsig_hold in response to a probing current in the range Ivalid as specified in Table 104–6.
104.4.5.3 Rejection criteria
The PSE shall reject link segments as having an invalid PD signature when those link segments exhibit any 
of the following characteristics with a probe current, as specified in Table 104–6:
a)
Voltage less than or equal to Vbad_lo_PSE max
b)
Voltage greater than or equal to Vbad_hi_PSE min
Table 104–6—PSE PI detection state electrical output requirements 
Item
Parameter
Symbol
Unit
Min
Max
Type
Additional 
information
Open circuit voltage
VOC
V
4.75
5.5
All
Short-circuit current
ISC
mA
—
All
Valid test probe current
Ivalid
mA
All
Slew rate
Islew
A/ms
—
All
Output capacitance during detection
Cout
µF
—
2.64
A, B, 
C, D
0.4
E
Maximum detection time
Tdet
ms
—
3.11
All
See 104.4.5
Valid PD detection signature range 
measured at PSE PI
Vgood_PSE
V
4.05
4.7
All
See 104.4.5.2
Invalid PD detection signature high 
range measured at PSE PI
Vbad_hi_PSE
V
Voc–0.05
—
All
See 104.4.5.3
Invalid PD detection signature low 
range measured at PSE PI
Vbad_lo_PSE
V
—
3.7
All
Signature hold timer for validity
Tsig_hold
ms
—
All
See 104.4.5.2

A PSE may accept or reject a voltage in the band between Vbad_lo_PSE max and Vgood_PSE min and in the 
band between Vgood_PSE max and Vbad_hi_PSE min. The values of these voltages are specified in 
Table 104–6.
104.4.6 PSE classification of a PD
The ability for the PSE to query the PD in order to determine the PD type and power class requirements of 
that PD is called classification. 
Classification is optional, and is performed using SCCP. See 104.7.
A PSE with SCCP enabled shall complete classification after detection and prior to application of full 
operating voltage at the PI in a time less than TClass as specified in Table 104–7. If classification is not 
completed before the TClass timer expires, a new detection cycle shall be completed before any subsequent 
application of full operating voltage, the PSE shall transition to the RESTART state.
Valid class information is one that returns one of the defined bit patterns in Table 104–13 with a valid CRC8 
result.
104.4.7 PSE output requirements
When the PSE provides power to the PSE PI, it shall conform to the electrical limits in Table 104–7.
Under all conditions, a PSE shall present an invalid PD signature with one of the attributes as specified in 
Table 104–10.
Table 104–7—PSE output requirements 
Item
Parameter
Symbol
Unit
Min
Max
Class
Type
Additional 
information
DC output voltage 
during 
POWER_ON state
VPSE(PON)
V
Class 
VPSE(min)
Class 
VPSE(m
ax)
All
All
See 
104.4.7.1 
and 
Table 104–1
Continuous output 
current capability in 
POWER_ON state
mA
PClass/ 
VPSE
—
All
All
See 
Table 104–1
Output slew rate 
dV/dt
V/ms
—
All
A, C
See 
104.4.7.3
—
All
E
See 
104.4.7.3
—
All
A, C, 
E
During 
inrush only
—
All
B, F
See 
104.4.7.3

Power feeding ripple and noise:
4a
1 kHz < f < 10 MHz
Vp-p
—
0.1
All
A, B, 
C, D, 
E
See 
104.4.7.3
0.066
F
4b
1 kHz < f < 10 MHz
—
0.01
All
A, B, 
C, D, 
E
0.0066
F
Output current —at 
short-circuit 
condition
ILIM
mA
IPI(max)
1.41 
IPI(max)
All
All
See 
104.4.7.2.1
Short-circuit time 
limit
TLIM
ms
Classes 
0 to 9
All
Classes 
10 to 15
Inrush time
TInrush
ms
3.17
3.87
Classes 
0 to 9
All
See 
104.4.7.4
Classes 
10 to 15
Classification time
TClass
ms
—
Classes 
0 to 9
All
See 104.4.6
Classes 
10 to 15
Turn off time
TOFF
ms
—
All
All
See 
104.4.7.5
DC output voltage 
during SLEEP state
VSleep
V
3.15
3.575
All
All
See 
104.4.7.1 
and 
104.4.7.5
Overload delay 
timing
Tod
ms
—
All
All
Restart timer delay
TRestart
ms
—
PD MFVS dropout 
time limit
TMFVDO
ms
See 
104.4.8.1
MFVS window time 
limit
TMFVS
ms
—
MFVS current 
threshold
IHold
mA
2.5
Table 104–7—PSE output requirements (continued)
Item
Parameter
Symbol
Unit
Min
Max
Class
Type
Additional 
information

104.4.7.1 Output voltage
A PSE operating in the POWER_ON state shall apply a voltage in the range of VPSE(PON) at the PI. A PSE 
shall apply a voltage at the PI in the range of VDisable when in the OVERLOAD, OVERLOAD_DELAY, 
and DISABLED states (see 104.4.7.5).
The PSE shall apply a voltage at the PI in the range of VSleep while operating in the SLEEP, RESTART, 
RESTART_DELAY, and IDLE states (see Table 104–7).
A PSE operating in the SETTLE_SLEEP state shall discharge the PSE PI to the range of VSleep within a 
time less than TOFF max.
104.4.7.2 Output current
A PSE operating in the POWER_ON state shall enter the SETTLE_SLEEP state if a valid MFVS is not 
present at the PI.
A PSE operating in the SETTLE_SLEEP state shall discharge the PI to the range of VSleep with a current in 
the range of Idischarge.
During the POWER_UP state, PSE output shall not exceed ILIM max.
Valid wakeup 
current signature 
range
IWakeup
mA
1.25
1.85
All
All
See 
104.4.7.2.2 
Wakeup current 
hold time required 
for validity
TWakeup
ms
0.1
—
Invalid wakeup 
current signature 
high range
IWakeup_bad
_hi
mA
2.5
—
Invalid wakeup 
current signature 
low range
IWakeup_bad
_lo
mA
—
0.5
Output discharge 
current during 
SETTLE_SLEEP 
state
Idischarge
mA
1.2
All
All
See 
104.4.7.2
DC output voltage 
during the 
DISABLED, 
OVERLOAD, and 
OVERLOAD_DEL
AY states
VDisable
V
—
All
All
See 
104.4.7.1
Disable time
TDisable
ms
—
All
All
See 
104.4.7.6
Table 104–7—PSE output requirements (continued)
Item
Parameter
Symbol
Unit
Min
Max
Class
Type
Additional 
information

104.4.7.2.1 Output current—at overload condition
During operation in the POWER_UP and POWER_ON states, the PSE shall limit the current to ILIM for a 
duration of up to TLIM in order to account for PSE dV/dt transients at the PI as specified in Table 104–7.
If IPSE exceeds ILIM min during the POWER_ON state, the PSE output voltage may drop below VPSE(PON)
min.
During operation in any state other than POWER_UP or POWER_ON when the PSE is enabled, the PSE 
shall limit IPSE to less than ISC as specified in Table 104–6 for a duration of up to TLIM.
If the PSE is limiting current in any state when pi_powered, pi_sleeping or pi_prebias are true, within TLIM
of the initiation of current limiting, overload_detected is set TRUE and power removal from the PI shall 
begin.
Measurements of IPSE during a short-circuit condition shall be made 1 ms after the initial transient to allow 
for settling.
104.4.7.2.2 Wakeup current signature detection
A PSE shall transition from the SLEEP state to the DETECTION state when IPSE is in the valid range of 
IWakeup for a minimum of TWakeup (see Table 104–7).
A PSE operating in the SLEEP state shall remain in the SLEEP state if IPSE is greater than IWakeup_bad_hi or 
less than IWakeup_bad_lo. A PSE may consider a PD wakeup request valid or invalid if IPSE is in the band 
between IWakeup_bad_hi and IWakeup max or the band between IWakeup min and IWakeup_bad_lo.
104.4.7.2.3 Output current requirement during idle
The PSE output current during the IDLE state shall be defined as valid if it less than IWakeup max for at least 
TWakeup min (see Table 104–7). A PSE may define its output current during the IDLE state as valid if the 
current is in the range between IWakeup max and IWakeup_bad_hi for at least TWakeup min.
A PSE may define its output current during the IDLE state as invalid if the current is in the range between 
IWakeup max and IWakeup_bad_hi. A PSE shall consider its output current during the IDLE state to be invalid if 
the current is greater than IWakeup_bad_hi.
104.4.7.3 Power feeding ripple and transients
The ripple and transient limits specified in Table 104–7, items (4) and (3) respectively, are meant to preserve 
data integrity.
A digital oscilloscope or data acquisition module with a differential probe is used to observe the voltage at 
the MDI/PI of the PSE device under test (DUT) as shown in Figure 104–7. The input impedance, Zin(f), and 
transfer function, H1(f), of the differential probe are specified by Equation (104–1) and Equation (104–2), 
respectively. When measuring the ripple voltage for a Type A or Type C PSE as specified by Table 104–7 
item (4a), f1 = 31.8 kHz ± 1%. When measuring the ripple voltage for a Type B or Type F PSE as specified 
in Table 104–7 item (4a), f1 = 318 kHz ± 1%. When measuring the ripple voltage for a Type E PSE as 
specified in Table 104–7 item (4a), f1 = 3.18 kHz ± 1%.
 
(104–1)
Zin f
0.1%
f2
f1
+
f
--------------------








=

(104–2)
When measuring the ripple voltages for a Type A or Type C PSE as specified by Table 104–7 item (4b), the 
voltage observed at the MDI/PI with the differential probe where f1 = 31.8 kHz ± 1% is post-processed with 
transfer function H2(f) specified in Equation (104–3) where f2 = 1 MHz ± 1%.
When measuring the ripple voltages for a Type B or Type F PSE as specified by Table 104–7 item (4b), the 
voltage observed at the MDI/PI with the differential probe where f1 = 318 kHz ± 1% is post-processed with 
transfer function H2(f) specified in Equation (104–3) where f2 = 10 MHz ± 1%.
When measuring the ripple voltages for a Type E PSE as specified by Table 104–7 item (4b), the voltage 
observed at the MDI/PI with the differential probe where f1 = 3.18 kHz ± 1% is post-processed with transfer 
function H2(f) specified in Equation (104–3) where f2 = 0.1 MHz ± 1%.
(104–3)
104.4.7.4 Inrush time
The specification for TInrush in Table 104–7 applies to the PSE power-up time allowed for a PD after 
completion of detection and optional classification. If full operating voltage is applied within TInrush min, 
the PSE shall enter the POWER_ON state. If full operating voltage is not applied within TInrush max, a new 
detection cycle shall be initiated after a delay of TRestart before any subsequent application of full operating 
voltage. If full operating voltage is applied within the range of TInrush, the PSE may enter the POWER_ON 
state or begin a new detection cycle after a delay of TRestart.
104.4.7.5 Turn off time
The specification for TOFF in Table 104–7 applies to the discharge time from VPSE in the POWER_ON state 
to VSleep. In addition, it is recommended that the PI be discharged when the PSE is not enabled. TOFF starts 
when VPSE drops 1 V below the steady-state full operating voltage value after the pi_powered variable is set 
to FALSE. TOFF ends when VPSE  VSleep max.
H1 f
f
f2
f1
+
--------------------
=
Figure 104–7—PSE ripple voltage test fixture
Iload
MDI/PI
Digital
Differential probe
Oscilloscope
and
Post
Processing
PSE
PHY
H2 f
f
f2
f2
+
--------------------
=

104.4.7.6 Disable time
The specification for TDisable in Table 104–7 shall apply to the discharge time from VPSE to VDisable with a 
test resistor of 320 k attached to the PI. TDisable starts when VPSE drops 1 V below the steady-state value 
after the pi_powered, pi_classifying, pi_detecting, pi_prebiased, and pi_sleeping variables are set to FALSE 
(see Figure 104–4). TDisable ends when VPSE is less than or equal to VDisable max.
104.4.7.7 Continuous output power in POWER_ON state
PClass is the minimum continuous class power that the PSE shall be capable of supplying, as defined in 
Table 104–1.
Measurement of PClass shall be averaged using a uniform sliding window with a width of 1 s.
A PSE may remove power from the PI when more than PClass is sourced.
104.4.8 PSE power removal
While the PSE is operating in the POWER_ON state, full operating voltage shall be removed from the PSE 
PI in the absence of the PD MFVS or if overload_detected is TRUE.
104.4.8.1 PSE MFVS requirements
MFVS shall be defined as being present in the POWER_ON state when IPSE is greater than or equal to IHold
max for a minimum of TMFVS.
MFVS may be defined as present or absent in the POWER_ON state if IPSE is in the range of IHold.
MFVS shall be defined as absent in the POWER_ON state if IPSE is less than or equal to IHold min. The 
PSE-PI Voltage shall be reduced to the range of VSleep when MFVS has been absent for a duration greater 
than TMFVDO. 
104.5 Powered Device (PD)
A PD is the portion of a device that is either drawing power or requesting power by participating in the PD 
detection or classification algorithms. A device that is capable of becoming a PD may have the ability to 
draw power from an alternate power source. A PD requiring power from the PI may simultaneously draw 
power from an alternate power source.
A PD is specified at the point of the physical connection to the PI. Limits defined for a PD are specified at 
the PI, not at any point internal to the PD, unless specifically stated.
104.5.1 PD types
For PoDL systems there are six types of PDs—Type A, Type B, Type C, Type D, Type E, and Type F 
consistent with 104.1.3.
104.5.2 PD PI
A PD may receive power in two modes, Mode A and Mode B. Table 104–8 in conjunction with 
Figure 104–3 illustrates the PD pinout.

Class 0 to class 9 PDs shall be able to operate per the Mode A column in Table 104–8. Class 10 to class 15 
PDs shall be implemented to be insensitive to the polarity of the power supply and shall be able to operate 
per the Mode A column and the Mode B column in Table 104–8.
104.5.3 PD classes
A PD shall comply with the voltage and power requirements listed in Table 104–1 for the relevant class.
104.5.4 PD state diagram
The PD state diagram specifies the externally observable behavior of a PD. The PD shall provide the 
behavior of the state diagram shown in Figure 104–8.
104.5.4.1 Overview
A falling edge of the PD input voltage through Vsig_enable enables a voltage signature, as defined in 104.5.5. 
When the input voltage rises through the Vsig_disable the PD disables its voltage signature.
A PD requests detection and wakeup while the voltage signature is enabled by presenting a valid wakeup 
current signature. SCCP may also be used for communication with the PD by the PSE when the voltage 
signature is enabled.
A rising edge through the VOn threshold causes the PD to enable MDI power to the load after a delay of 
Tpower_dly. A falling edge through the VOff threshold causes the PD to disable MDI power.
104.5.4.2 Conventions
The notation used in the state diagram follows the conventions of state diagrams as described in 21.5.
104.5.4.3 Variables
The PD state diagram uses the following variables:
disconnect_pd
TRUE: the PD no longer requires full operating voltage from the PI and has reduced its port current 
below the MFVS threshold current.
FALSE: the PD still requires full operating voltage from the PI.
enable_mdi_pwr
TRUE: the PD is enabled and ready to consume full power from the PI.
FALSE: the PD is disabled or not ready to consume full power from the PI.
fault_detected
TRUE: the PD no longer requires power as the result of an implementation-specific error condition.
FALSE: no fault has been detected.
Table 104–8—PD pinout
Contact
Mode A
Mode B
PI+
PI–
PI–
PI+

pd_fault
TRUE: following the application of full operating voltage at the PI, the PD has gone offline as the 
result of an error condition.
FALSE: following the application of full operating voltage at the PI, no fault has been detected.
pd_sccp_enabled
TRUE: during detection, a PSE reset pulse has been detected by the PD and a SCCP serial transaction 
is pending.
FALSE: during detection, no PSE reset pulse has been detected by the PD.
pd_reset
An implementation-specific control variable that unconditionally resets the PD state diagram to the 
RESET state.
TRUE: the device is in reset.
FALSE: the device is not in reset (default).
present_det_sig
A variable that controls the PD detection signature as specified in 104.5.5.
TRUE: the detection signature is to be applied to the PD PI.
FALSE: the detection signature is not to be applied to the PD PI.
present_iwakeup
TRUE: the wakeup signature (IWakeup_PD) is to be applied to the PD PI.
FALSE: the wakeup signature (IWakeup_PD) is not to be applied to the PD PI.
present_mfvs
TRUE: the MFVS is to be applied to the PD PI.
FALSE: the MFVS is not to be applied to the PD PI.
sccp_reset_pulse
TRUE: during detection, a SCCP reset pulse per Figure 104–10 as described in 104.7.1.1 has been 
received by the PD.
FALSE: during detection, a SCCP reset pulse has not been received by the PD.
VOff
PD turn off threshold voltage (see Table 104–11).
VOn
PD turn on threshold voltage (see Table 104–11).
VPD
The voltage measured at the PI of the PD.
Vsig_disable
PD signature disable threshold voltage (see Table 104–9).
Vsig_enable
PD signature enable threshold voltage (see Table 104–9).
wakeup
TRUE: the PD requires the full operating voltage at the PI.
FALSE: the PD is ready to go to sleep.

104.5.4.4 Timers
All timers operate in the manner described in 14.2.3.2 with the following addition. A timer is reset and stops 
counting upon entering a state where “stop x_timer” is asserted.
tpower_dly_timer
A timer used to prevent a PD from drawing more than inrush current during the PSE’s POWER_UP 
state (see Tpower_dly in Table 104–11).
sccp_watchdog_timer
A timer used to limit the time in the DO_CLASSIFICATION state in the event serial communication 
between the PSE and PD is idle or stalled (see TSCCP_watchdog in Table 104–11).
104.5.4.5 Functions
do_sccp
This function returns the following variable to the PSE:
CLASS_TYPE_INFO register:
Refer to Table 104–13 for a description of the contents.
VOLT_INFO register:
PDs that support cable resistance measurement also return the VOLT_INFO register. 
Refer to Table 104–14 for a description of the contents.
POWER_INFO register:
PDs that support cable resistance measurement also return the POWER_INFO register. 
Refer to Table 104–15 for a description of the contents.
POWER_ASSIGN register:
PDs that support cable resistance measurement also return the POWER_ASSIGN register. 
Refer to Table 104–16 for a description of the contents.

104.5.4.6 State diagram
104.5.5 PD signature
Class 0 and Class 1 PDs, or PDs that do not implement classification shall enable a valid detection signature 
when VPD is less than Vsig_enable min and may enable a valid detection signature when VPD is less than 
Vsig_enable max. A PD that presents an invalid detection signature greater than Vbad_hi max as specified in 
Table 104–10 shall implement classification as specified in 104.7.
When VPD is greater than Vsig_disable a PD shall remove the current draw of the detection signature.
The detection signature shall consist of a current limited voltage Vgood per Table 104–9 when measured by 
the PSE.
A valid PD detection signature shall have all of the characteristics of Table 104–9.
A non-valid PD detection signature shall have one of the characteristics in Table 104–10.
Figure 104–8—PD state diagram
RESET
present_det_sig  TRUE
present_iwakeup  TRUE
present_mfvs  FALSE
enable_mdi_pwr  FALSE
pd_sccp_enabled  FALSE
pd_fault  FALSE
pd_reset
DO_DETECTION
present_det_sig  TRUE
present_iwakeup  TRUE
pd_sccp_enabled  FALSE
DO_CLASSIFICATION
pd_sccp_enabled  TRUE
start sccp_watchdog_timer
do_sccp
MDI_POWER1
present_det_sig  FALSE
present_iwakeup  FALSE
pd_sccp_enabled  FALSE
pd_fault  FALSE
MDI_POWER2
enable_mdi_pwr  TRUE
present_mfvs  TRUE
DISCONNECT
present_mfvs  FALSE
enable_mdi_pwr  FALSE
PD_SLEEP
present_det_sig  TRUE
FAULT
pd_fault  TRUE
MDI_POWER_DELAY
start Tpower_dly_timer
!pd_reset
!sccp_reset_pulse *
VPD > Vsig_disable
VPD > Vsig_disable
sccp_watchdog_timer_done
VPD < Vsig_enable
VPD > VOn
VPD < VOff
Tpower_dly_timer_done *
VPD > VOn
fault_detected
sccp_reset_pulse
UCT
disconnect_pd + 
VPD < VOff
VPD < Vsig_enable
wakeup * VPD > VOn
wakeup * VPD Vsig_disable
VPD > Vsig_disable

A PD that presents a signature within the limits set out in Table 104–9 is assured to pass detection, while a 
PD that presents one of the signature characteristics of Table 104–10 is assured to fail detection.
104.5.6 PD classification and mutual identification between the PSE and PD
A PD may be classified by the PSE based on SCCP information provided by the PD. The intent of PD 
classification is to provide information about the voltage and power required by the PD during operation. 
SCCP classification may also be used to establish mutual identification between a PSE and a PD. See 104.7 
for more information about SCCP.
104.5.7 PD power
The PD shall operate within the characteristics in Table 104–11.
Table 104–9—Valid PD detection signature characteristics, measured at PD PI
Parameter
Conditions
Min
Max
Unit
Vgood
7 mA < IPD < 17 mA, PD exiting RESET state
4.05
4.55
V
Isignature_limit
VPD < Vsig_disable max
—
mA
Vsig_disable
VPD rising
4.6
5.75
V
Vsig_enable
VPD falling
3.6
4.3
V
Table 104–10—Non-valid PD detection signature characteristics, measured at PD PI
Parameter
Conditions
Min
Max
Unit
Vbad_hi
7 mA < IPD < 17 mA, PD exiting RESET state
5.15
—
V
Vbad_lo
7 mA < IPD < 17 mA, PD exiting RESET state
—
3.7
V
Table 104–11—PD power supply limits 
Item
Parameter
Symbol
Unit
Min
Max
PD 
Type
Additional 
information
Input current dI/dt
A/ms
—
A, C
See 104.5.7.4
—
B
—
0.1
E
Input voltage dV/dt
V/ms
—
A, C
—
B
—
E

Ripple voltage
3a
1 kHz < f < 10 MHz
Vp-p
—
0.1
A, B, 
C, D, 
E
See 104.5.7.4
0.066
F
3b
1 kHz < f < 10 MHz
—
0.01
A, B, 
C, D, 
E
0.0066
F
4a
Power supply turn on voltage 
(unregulated 12 V classes)
VOn
V
—
5.75
All
See 104.5.7.2
4b
Power supply turn on voltage 
(regulated 12 V classes)
—
13.6
4c
Power supply turn on voltage 
(unregulated 24 V classes)
—
11.4
4d
Power supply turn on voltage 
(regulated 24 V classes)
—
24.7
4e
Power supply turn on voltage 
(regulated 48 V classes)
—
45.6
4f
Power supply turn on voltage 
(Classes 10, 11, and 12)
—
19.2
4g
Power supply turn on voltage 
(Classes 13, 14, and 15)
—
5a
Power supply turn off voltage 
(unregulated 12 V classes)
VOff
V
3.6
—
5b
Power supply turn off voltage 
(regulated 12 V classes)
9.56
—
5c
Power supply turn off voltage 
(unregulated 24 V classes)
7.97
—
5d
Power supply turn off voltage 
(regulated 24 V classes)
19.5
—
5e
Power supply turn off voltage 
(regulated 48 V classes)
—
5f
Power supply turn off voltage
(Classes 10, 11, and 12)
11.2
—
5g
Power supply turn off voltage
(Classes 13, 14, and 15)
—
Table 104–11—PD power supply limits (continued)
Item
Parameter
Symbol
Unit
Min
Max
PD 
Type
Additional 
information

104.5.7.1 PD discharge
At a delay of TOFF max (see Table 104–7) after disconnection from the PSE, a PD shall not source greater 
than 410 J out of its PI until VPD drops below VSleep_PD max.
104.5.7.2 PD input voltage
The PD shall turn on at a voltage less than or equal to VOn max and with a delay greater than Tpower_dly min. 
After the PD turns on, the PD shall stay on over the range from VPD min to VPSE max. The PD shall turn off 
at a voltage in the range of VPD min to VOff min. Table 104–1 defines the values for VPD min and VPSE
max. Table 104–11 defines the values for VOn, Tpower_dly, and VOff.
The PD shall turn on or off without startup oscillation and within the first trial when a voltage in the range of 
VPSE (as defined in Table 104–1) is applied with a series resistance within the range of valid dc loop 
resistance (see 104.2).
6a
Input Capacitance during 
DO_DETECTION, 
MDI_POWER1, and 
MDI_POWER_DELAY 
states
CIN
F
—
All
Classes 1 to 3 
and 5 to 9
—
Class 4
6b
Input capacitance during 
DO_CLASSIFICATION state
CIN_Class
—
0.2
A, B, 
C, D
All classes
—
0.4
E
Inrush enable delay time 
(Classes 0 to 9)
Tpower_dly
ms
1.46
—
All
See 104.5.7.2
Inrush enable delay time 
(Classes 10 to 15)
—
PD MFVS duration
TMFVS_PD
ms
—
All
See 104.5.8
MFVS current threshold limit
Ihold_PD
mA
—
Power supply voltage during 
PD_SLEEP state
VSleep_PD
V
3.1
3.575
See 104.5.7.2
Sleep current
ISleep_PD
mA
—
0.1
See 104.5.7.3
Wakeup current
IWakeup_PD
mA
1.3
1.8
See 104.5.7.3
Input current not related to 
inrush
 IPD_pwr1
mA
—
See 104.5.7.3
Wakeup current hold time 
required for validity
TWakeup_PD
ms
0.2
—
See 104.5.7.3
SCCP watchdog timeout
TSCCP_watchdog
ms
A, B, 
C, D
See 104.5.6
E
Table 104–11—PD power supply limits (continued)
Item
Parameter
Symbol
Unit
Min
Max
PD 
Type
Additional 
information

The PD shall operate in the PD_SLEEP state with an input voltage greater than VSleep_PD min as specified in 
Table 104–11.
When the input voltage is greater than Vsig_disable, then the signature is disabled.
104.5.7.3 Input current
During operation in the DISCONNECT and PD_SLEEP states, the PD shall not draw current in excess of 
ISleep_PD as specified in Table 104–11.
A PD that requires detection and application of power shall draw current in the range of IWakeup_PD for at 
least TWakeup_PD when VPD is within the range of VSleep_PD as specified in Table 104–11.
A PD shall draw less than IPD_pwr1 max of current for a constant PD input voltage between Vsig_disable max 
and VOn min.
104.5.7.4 PD ripple and transients
The specifications for ripple and transients in Table 104–11 apply to the voltage or current at the PD PI 
generated by the PD circuitry. Ripple and transient limits are provided to preserve data integrity.
The PD DUT is connected to a power supply through a dc bias coupling network as shown in Figure 104–9. 
The ripple and transient specifications for a Type A or Type C PD shall be met for all operating voltages in 
the range of VPD sourced through a dc bias coupling network with MDI return loss as specified by 
Equation (96–12), and over the range of PPD. The ripple and transient specifications for a Type B PD shall 
be met for all operating voltages in the range of VPD sourced through a dc bias coupling network with MDI 
return loss as specified by Clause 97, and over the range of PPD. The ripple and transient specifications for a 
Type E PD shall be met for all operating voltages in the range of VPD sourced through a dc bias coupling 
network with MDI return loss as specified by Clause 146 and over the range of PPD. The ripple and transient 
specifications for a Type F PD shall be met for all operating voltages in the range of VPD sourced through a 
dc bias coupling network with MDI return loss as specified by Clause 149, and over the range of PPD.
Figure 104–9—PD ripple voltage test fixture
MDI/PI
Digital
Differential probe
Oscilloscope
and
Post
Processing
PD
PHY
DC Bias
Coupling
Network
Vbias
+-

A digital oscilloscope or data acquisition module with a differential probe is used to observe the voltage at 
the MDI/PI. The input impedance, Zin(f), and transfer function, H1(f), of the differential probe are specified 
by Equation (104–1) and Equation (104–2), respectively. When measuring the ripple voltage for a Type A 
or Type C PD as specified by Table 104–11 item (3a), f1 = 31.8 kHz ± 1%. When measuring the ripple 
voltage for a Type B or Type F PD as specified by Table 104–11 item (3a), f1 = 318 kHz ± 1%. When 
measuring the ripple voltage for a Type E PD as specified by Table 104–11 item (3a), f1 = 3.18 kHz ± 1%.
When measuring the ripple voltages for a Type A or Type C PD as specified by Table 104–11 item (3b), the 
voltage observed at the MDI/PI with the differential probe where f1 = 31.8 kHz ± 1% shall be 
post-processed with transfer function H2(f) specified in Equation (104–3) where f2 = 1 MHz ± 1%. When 
measuring the ripple voltages for a Type B or Type F PD as specified by Table 104–11 item (3b), the 
voltage observed at the MDI/PI with the differential probe where f1 = 318 kHz ± 1% shall be post-processed 
with transfer function H2(f) specified in Equation (104–3) where f2 = 10 MHz ± 1%. When measuring the 
ripple voltages for a Type E PD as specified by Table 104–11 item (3b), the voltage observed at the MDI/PI 
with the differential probe where f1 = 3.18 kHz ± 1% shall be post-processed with transfer function H2(f) 
specified in Equation (104–3) where f2 = 0.1 MHz ± 1%.
104.5.7.5 Input average power
The maximum average power, PPD(max) in Table 104–1, shall be calculated using a uniform sliding window 
with a width of 1 s.
104.5.7.6 PD stability
When any voltage between VPSE min and VPSE max (with RLoop_max in series) is applied to the PI of the 
PD, PPD is defined as shown in Equation (104–4).
(104–4)
where
 PPD
is the input power at the PD PI
VPD
is the input voltage at the PD PI
IPD
is the input current to the PD
NOTE—When connected together as a system, the PSE and PD might exhibit instability at the PSE side, the PD side, or 
both due to the presence of negative impedance at the PD input.
104.5.8 PD Maintain full voltage
In order to signal the PSE to maintain full operating voltage, the PD shall provide a valid MFVS at the PI. 
The MFVS shall consist of current draw equal to or greater than Ihold_PD for a minimum duration of 
TMFVS_PD measured at the PD PI followed by an allowed MFVS dropout for no longer than TMFVDO min. 
PDs that do not require full operating voltage at the PI shall remove the current draw of the MFVS from the 
PI.
104.6 Additional electrical specifications
104.6.1 Isolation
In order to prevent the formation of a ground loop, a PD shall provide at least 1 M dc isolation between all 
accessible external conductors, including frame ground (if any), and all MDI leads, when measured using a 
5 V ± 20% source voltage. Any equipment that can be connected to a PD through a non-MDI connector that 
is not isolated from the MDI leads needs to provide isolation between all accessible external conductors, 
PPD
VPD
IPD


 (Watts)
=

including frame ground (if any), and the non-MDI connector, so as not to negate the dc isolation provided by 
the PD.
104.6.2 Fault tolerance
The PI for Type A, Type B, Type C, and Type F PSEs and PDs shall meet the fault tolerance requirements 
as specified in 96.8.3. The PI for Type E PSEs and PDs shall meet the fault tolerance requirements as 
specified in 146.8.6.
A PD shall not be damaged when connected to any PSE as defined in 104.4.
The PSE PI shall withstand without damage the application of short circuits between the wires within the 
cable for an indefinite period of time.
104.7 Serial communication classification protocol (SCCP)
Implementation of SCCP by PSEs and PDs that present a valid detection signature is optional. PDs that 
present an invalid detection signature as specified in Table 104–10 shall implement SCCP. The PSE acts as 
a master during the SCCP exchange, controlling the PD that acts as the slave device. SCCP is a 
current-sinking, wired-OR (e.g., open-drain or open-collector), half-duplex bidirectional serial data bus. The 
PSE sources the required pull-up current. PDs can derive power from the PSE’s pull-up current during 
classification via the PD PI.
Measurement of initial cable resistance, RCable_initial, by PSEs and PDs that implement SCCP is optional. 
PSEs and PDs that implement cable resistance measurement support the VOLT_INFO, POWER_INFO, and 
POWER_ASSIGN registers (see Table 104–14, Table 104–15, and Table 104–16). PSEs that implement 
cable resistance measurement shall report assigned power through PoDL PSE Status 2 Register 
(see 45.2.9.3).
104.7.1 SCCP signaling
SCCP uses the following signal types in order to ensure data integrity: reset pulse, presence pulse, Write 0, 
Write 1, Read 0, and Read 1. The PSE initiates all of these signals.
104.7.1.1 Initialization procedure—reset and presence pulses
All SCCP communication with a PD shall begin with an initialization sequence that consists of a reset pulse 
from the PSE followed by a presence pulse from the PD. This is illustrated in Figure 104–10. See 
Table 104–12 for requirements on the timing relationships.
During the initialization sequence the PSE shall transmit the reset pulse by first driving VPSE low and then 
releasing to the pull up at tRSTL. The PSE shall then go into receive mode (RX). When the PD detects the 
rising edge at the PD PI, it shall wait tPDH and then transmit a presence pulse by pulling VPD low for tPDL. 
Presence data from the PD shall be valid for the entire time window defined by tMSP following the rising 
edge that terminated the reset pulse. Therefore, the PSE should sample the subsequent voltage within tMSP
from the completion of the preceding rising edge at its PI.

104.7.1.2 Write time slots
There are two types of write time slots: Write 1 and Write 0 time slots. Figure 104–11 illustrates Write 0/1 
timing diagrams. The PSE shall use a Write 1 time slot to transmit a logic 1 to the PD and a Write 0 time slot 
to transmit a logic 0 to the PD. All write time slots shall be tWRITESLOT in duration. The PSE shall initiate 
both types of write time slots by pulling VPSE low.
To generate a Write 1 time slot, after pulling VPSE low, the PSE shall pull up VPSE within the range of tW1L. 
To generate a Write 0 time slot, after pulling the VPSE low, the PSE shall pull up VPSE within the range of 
tW0L. The PD shall sample the VPD within the range of tssw after the falling edge during a Write 1 or Write 0 
operation.
Figure 104–10—Reset command timing diagram
Reset Pulse
tF
VTL
0V
VTH
VPUP
tRSTL
PD pulls down
PSE
PD
PULL UP
tR
tF
tPDL
tR
tREC
tPDH
tMSP
VCHRG
tCHRG
Figure 104–11—Write 0/1 slot timing diagram
tF
VTL
0V
VTH
VPUP
tW1L
PSE
PD
PULL UP
tR
tWRITESLOT
tR
tREC
tF
Write 1
Write 0
(PD Capture Window)
tW0L
tSSW
VCHRG
tCHRG

104.7.1.3 Read time slots
Figure 104–12 illustrates Read 0/1 timing diagrams. The PD can only transmit data to the PSE when the PSE 
issues read time slots. Therefore, the PSE shall generate read time slots immediately after issuing a function 
command, which requires data from the PD so that the PD can provide the requested data. In addition, the 
PSE can generate read time slots after issuing a manufacturer specific function command in order to 
determine the status of a commanded operation.
All read time slots shall be tREADSLOT in duration. The PSE shall initiate a read time slot by pulling VPSE
low and then pulling-up VPSE within tW1L. After the PSE initiates the read time slot, the PD shall begin 
transmitting a 1 or 0 at its PI. The PD shall transmit a 1 by leaving VPD high and transmit a 0 by pulling VPD
low. When transmitting a 0, the PD shall hold VPD low and then release VPD within tR0L. VPSE and VPD will 
be pulled back to the high idle state by the PSE’s pull-up current. Output data from the PD is valid for tMSR
after the falling edge that initiated the read time slot. Therefore, the PSE shall release VPSE and then sample 
the subsequent voltage within tMSR from the start of the read time slot SCCP electrical requirements.
A PSE or PD implementing SCCP shall comply with the electrical and timing requirements in 
Table 104–12. All voltages are referenced to the PI, as shown in Figure 104–3. See Figure 104–10, 
Figure 104–11, and Figure 104–12 for timing definitions.
Table 104–12—SCCP electrical requirements 
Item
Parameter
Symbol
Unit
Min
Max
PSE/PD 
Type
Additional 
information
PSE Pull-up Voltage 
(Classes 0 to 9)
VPUP
V
Vgood_PSE max
All
See Table 104–6
PSE Pull-up Voltage 
(Classes 10 to 15)
5.5
PSE Pull-up Current
IPUP
mA
All
Figure 104–12—Read 0/1 slot timing diagram
tF
VTL
0V
VTH
VPUP
tW1L
PSE
PD
PULL UP
tR
tREADSLOT
tR
tREC
tF
Read 1
Read 0
tR0L,min
tMSR
tR0L,max
(PD Release Window for Read 0)
PD pulls down
VCHRG
tCHRG

Input Logic High 
Voltage
VTH
V
—
All
Input Logic Low 
Voltage
VTL
V
—
A, B, C, D, 
PSE/PD; 
E PD
E PSE
Sink Current
IL
mA
—
All
VPort 0.8 V
6a
Write Time Slot
tWRITESLOT
ms
2.7
3.3
A, B, C, D
—
2.78
E
6b
Read Time Slot
tREADSLOT
ms
2.7
3.3
A, B, C, D
—
3.83
E
Recovery Time
tREC
ms
0.27
0.33
All
Write 0 Low Time
tW0L
ms
1.8
2.2
All
Write 1 Low Time
tW1L
ms
0.08
0.25
A, B, C, D
0.09
0.61
E
PD Sample Write Time
tSSW
ms
0.5
1.5
A, B, C, D
0.77
1.43
E
PSE Sample Read 
Time
tMSR
ms
0.27
0.33
A, B, C, D
0.9
1.1
E
Read 0 Low Time
tR0L
ms
0.5
1.5
A, B, C, D
1.75
3.25
E
Reset Time Low Time
tRSTL
ms
A, B, C, D
10.5
E
Presence-Detect High 
Time
tPDH
ms
0.5
1.5
A, B, C, D
0.7
1.3
E
Presence-Detect Low 
Time
tPDLOW
ms
2.5
7.5
A, B, C, D
2.8
5.2
E
E
PDs that support 
link segment 
resistance 
measurement
PSE Sample Presence 
Time
tMSP
ms
1.8
2.2
All
Rise-Time
tR
ms
0.025
0.105
A, B, C, D
0.025
0.5
E
Table 104–12—SCCP electrical requirements (continued)
Item
Parameter
Symbol
Unit
Min
Max
PSE/PD 
Type
Additional 
information

104.7.1.4 Calculations for cable resistance
A PSE that implements cable resistance measurement may calculate cable resistance (dc loop resistance of 
the link segment) using the voltage and current at the PSE PI during the presence pulse and the voltage at the 
PD PI as shown in Equation (104–5). The measurement tolerances in the voltage and current values should 
be included in the cable resistance measurement calculation. The initial calculated link segment cable 
resistance, RCable_initial, is defined in Equation (104–5).
 
(104–5)
where 
VReport_PD
is the voltage at PD’s PI during the presence pulse as reported in b[7:0] of VOLT_INFO in 
Table 104–14
VPSE 
is the voltage at PSE’s PI during the presence pulse
IPSE
is the current at PSE’s PI during the presence pulse
The initial cable resistance value calculated in Equation (104–5) is then margined by the Resistance Margin 
Factor, KRMF, as shown in Equation (104–6). The margined link segment cable resistance, RCable, should 
not exceed the maximum allowable link segment dc loop resistance for the class as shown in 
Equation (104–6).
 
(104–6)
where 
RCable_initial
is the initial calculated link segment cable resistance
KRMF
is the Resistance Margin Factor per Table 104–12
RLoop(max)
is the maximum allowable link segment dc loop resistance for the class per 104.2
Fall-Time
tF
ms
0.025
0.1
A, B, C, D
0.025
0.25
E
Bus Capacitance
CBUS
nF
—
A, B, C, D
—
E
PD reservoir capacitor 
recharge voltage
VCHRG
V
0.9×VPUPmin
—
E
PD reservoir capacitor 
recharge time
tCHRG
ms
0.2
—
E
Resistance margin 
factor
KRMF
—
1.06
—
E
PSEs that 
support cable 
resistance 
measurement
Table 104–12—SCCP electrical requirements (continued)
Item
Parameter
Symbol
Unit
Min
Max
PSE/PD 
Type
Additional 
information
RCable_initial
VPSE
VReport_PD
–
IPSE
---------------------------------------




=
RCable
min RCable_initial
KRMF 

RLoop(max)



=

104.7.1.5 Calculations for power allocation
A PD that supports cable resistance measurement may request a power allocation between 0.1 W and 
PClass(max) via the PD Requested Power, PPD_req, field of the POWER_INFO register b[11:0]. The PD 
Requested Power may exceed PPD(max). A PSE that supports cable resistance measurement shall set 
PD Assigned Power (PPD_assign) based on PD Requested Power, PPD_req, and measured cable resistance as 
shown in Equation (104–7):
 W
(104–7)
where 
PPD_req
is the PD Requested Power as reported in b[11:0] of POWER_INFO in Table 104–15
PPD_assign
is the PD Assigned Power by PSE as assigned in b[11:0] of POWER_ASSIGN 
in Table 104–16
PClass(min)
see Table 104–1 for description
IPI(max)
see Table 104–1 for description
PPD(max)
see Table 104–1 for description
For systems that implement cable resistance measurement, the PSE determines PPD_assign, as assigned in 
b[11:0] of POWER_ASSIGN in Table 104–16. Maximum average available power at the PD PI is 
PPD_assign. PPD_assign may be greater or less than PPD(max).
PPD_assign
min PPD_req  PClass(min)
IPI(max)
–
RCable

,

for PPD_req
P

PD(max)
PPD_req
for PPD_req
P

PD(max) 









=

104.7.2 Serial communication classification protocols
All data and commands shall be transmitted least significant bit first using SCCP. The PSE initiates all 
transactions.
104.7.2.1 SCCP transaction sequence
The transaction sequence for accessing a PD on SCCP is as follows:
a)
Initialization
b)
Address Command (followed by any required data exchange)
c)
Function Command
104.7.2.2 Initialization
All communication with a PD shall begin with the initialization sequence that consists of a reset pulse from 
the PSE followed by a presence pulse from the PD.
Figure 104–13—Address and Read_Scratchpad function command flowchart
CRC-8
PSE Tx ADDRESS
COMMAND
PD Tx
PRESENCE
PULSE
RESET PULSE
Initialization
Sequence
N
N
PSE Tx
PSE Rx
0xBB
VOLT_INFO
READ?
0x81
POWER_ASSIGN
READ?
N
N
POWER_ASSIGN
CRC-8
PSE Tx
PSE Tx
POWER_ASSIGN
PSE Rx
0xAA
SCRATCHPAD
READ?
PSE Computation
and Decision Logic
Y
Y
Y
CRC-8
PSE Rx
N
Y
0xCC
BRDCAST ADDR
COMMAND
CLASS_TYPE_INFO
CRC-8
PSE Rx
PSE Rx
Y
0x99
POWER_ASSIGN
WRITE?
VOLT_INFO
PSE Rx
CRC-8
PSE Rx
0x77
POWER_INFO
READ?
Y
POWER_INFO
PSE Rx
N

104.7.2.3 Address commands
All SCCP-capable PDs shall support the Broadcast Address command. The PSE shall issue an appropriate 
address command before issuing a function command.
104.7.2.3.1 Broadcast address [0xCC]
The PSE uses this command to address a PD on the bus without sending out unique address code 
information.
104.7.2.4 Read_Scratchpad function command [0xAA]
All SCCP-capable PDs shall support the 8-bit Read_Scratchpad command. After receiving a 
Read_Scratchpad function command the PD shall respond with a 16-bit CLASS_TYPE_INFO read payload 
followed by an 8-bit CRC8 field as specified in 104.7.2.5. A flowchart for operation of the address and the 
Read_Scratchpad function command is shown in Figure 104–13. Table 104–13 illustrates the contents of the 
CLASS_TYPE_INFO register.
Table 104–13—CLASS_TYPE_INFO register table 
Bit(s)
Name
Description
R/W
b[15:12]
Type
= Type A
= Type B
= Type C
= Type D
= Type E
= Type F
RO
b[11]
pd_faulted
1—error condition has occurred that prevented the PD from receiving power at 
the PI. Set to 1 when the pd_fault variable transitions from FALSE to TRUE
0—no error condition detected
RO/
LH
b[10]
Cable 
resistance 
measurement
1 — Cable resistance measurement enabled
0 — Cable resistance measurement disabled
RO
b[9:0]
Class
= Class 0
= Class 1
= Class 2
= Class 3
= Class 4
= Class 5
= Class 6
= Class 7
= Class 8
= Class 9
=Class 10
=Class 11
=Class 12
=Class 13
=Class 14
=Class 15
RO

104.7.2.5 CRC8 field
The CRC8 field is an 8-bit cyclic redundancy check value. This value is computed as a function of the 
contents of the preceding Read/Write payload.
The encoding is defined by the generating polynomial shown in Equation (104–8):
(104–8)
This CRC8 calculation shall produce the same result as the serial implementation shown in Figure 104–14. 
Before calculation begins, the shift register shall be initialized to the value 0x00. The content of the shift 
register is transmitted without inversions.
104.7.2.6 Read_VOLT_INFO command [0xBB]
All PSEs and PDs that support cable resistance measurement shall support the 8-bit Read_VOLT_INFO 
command. After receiving a Read_VOLT_INFO command, the PD shall respond with a 16-bit 
VOLT_INFO read payload followed by an 8-bit CRC8 field as specified in 104.7.2.5. A flowchart for 
operation of the address and the Read_VOLT_INFO command is shown in Figure 104–13. Table 104–14 
illustrates the contents of the VOLT_INFO register.
Table 104–14—VOLT_INFO register table
Bit(s)
Name
Description
R/Wa
aRO = Read only
b[15:8]
Reserved
Value always 0
RO
b[7:0]
Voltage at PD PI during 
Presence Pulse
 ± 20 mV tolerance, 10 mV per LSB
RO
G x

x8
x5
x4
+
+
+
=
Figure 104–14—CRC8 field generation
X0
X1
X2
X3
X4
X5
X6
X7
CONTROL INPUT OUTPUT
CONTROL = 1 when shifting the contents of the register and calculating the CRC field
CONTROL = 0 when transmitting the CRC field
= AND
= XOR

104.7.2.7 Read_POWER_INFO command [0x77]
All PSEs and PDs that support cable resistance measurement shall support the 8-bit Read_POWER_INFO 
command. After receiving a Read_POWER_INFO command, the PD shall respond with a 16-bit 
POWER_INFO read payload followed by an 8-bit CRC8 field as specified in 104.7.2.5. A flowchart for 
operation of the address and the Read_POWER_INFO command is shown in Figure 104–13. Table 104–15 
illustrates the contents of the POWER_INFO register.
104.7.2.8 Write_POWER_ASSIGN command [0x99]
All 
PSEs 
and 
PDs 
that 
support 
cable 
resistance 
measurement 
shall 
support 
the 
8-bit 
Write_POWER_ASSIGN command. After transmitting a Write_POWER_ASSIGN command, the PSE 
shall transmit a 16-bit POWER_ASSIGN write payload followed by an 8-bit CRC8 field as specified 
in 104.7.2.5. A flowchart for operation of the address and the Write_POWER_ASSIGN command is shown 
in Figure 104–13. Table 104–16 illustrates the contents of the POWER_ASSIGN register.
104.7.2.9 Read_POWER_ASSIGN command [0x81]
All 
PSEs 
and 
PDs 
that 
support 
cable 
resistance 
measurement 
shall 
support 
the 
8-bit 
Read_POWER_ASSIGN command. After receiving a Read_POWER_ASSIGN command, the PD shall 
respond with a 16-bit POWER_ASSIGN read payload followed by an 8-bit CRC8 field as specified in 
104.7.2.5. A flowchart for operation of the address and the Read_POWER_ASSIGN command is shown in 
Figure 104–13. Table 104–16 illustrates the contents of the POWER_ASSIGN register.
Table 104–15—POWER_INFO register table
Bit(s)
Name
Description
R/Wa
aRO = Read only
b[15:12]
Reserved
Value always 0
RO
b[11:0]
PPD_req 
PD Requested Power
Power requested by PD, 0.025 W per LSB
RO
Table 104–16—POWER_ASSIGN register table
Bit(s)
Name
Description
R/Wa
aRO = Read only, R/W = Read/Write
b[15:12]
Reserved
Value always 0
RO
b[11:0]
PPD_assign
PD Assigned Power
PD assigned power, 0.025 W per LSB 
R/W

104.8 Environmental
104.8.1 General safety
Equipment subject to this clause shall conform to the general safety requirements in J.2. In particular, the 
PSE shall be classified as a Limited Power Source in accordance with Annex Q of IEC 62368-1:2018, as 
applicable. For automotive applications, systems described in this clause may be subject to additional 
requirements; refer to ISO 26262.
All equipment subject to this clause may be additionally required to conform to any applicable local, state, 
or national standards, including national motor vehicle standards related to safety or as agreed to between 
the customer and supplier.
104.8.2 Network safety
This subclause sets forth a number of recommendations and guidelines related to safety concerns. The list is 
neither complete nor does it address all possible safety issues. The designer is urged to consult the relevant 
local, national, and international safety regulations to verify compliance with the appropriate requirements. 
LAN cabling systems described in this clause are subject to at least four direct electrical safety hazards 
during their installation and use. These hazards are as follows:
a)
Direct contact between LAN components and power, lighting, or communications circuits.
b)
Static charge buildup on LAN cabling and components.
c)
High-energy transients coupled onto the LAN cabling system.
d)
Voltage potential differences between safety grounds to which various LAN components are 
connected.
Such electrical safety hazards should be avoided or appropriately protected against for proper network 
installation and performance. In addition to provisions for proper handling of these conditions in an 
operational system, special measures should be taken to verify that the intended safety features are not 
negated during installation of a new network or during modification of an existing network.
104.8.3 Installation and maintenance guidelines
It is a mandatory requirement that sound installation practice, as defined by applicable local codes and 
regulations, be followed in every instance in which such practice is applicable.
In particular, users are cautioned to be aware of the ampacity of cabling, as installed, and local codes and 
regulations, e.g., ANSI/NFPA 70—National Electric Code® (NEC®), relevant to the maximum class 
supported.
It is a mandatory requirement that, during installation of the cabling plant, care be taken to verify that 
non-insulated network cabling conductors do not make electrical contact with unintended conductors or 
ground.
All cabling and equipment subject to this clause is expected to be mechanically and electrically secure in a 
professional manner.
In automotive applications, all PoDL cabling should be routed in way to provide maximum protection by the 
motor vehicle sheet metal and structural components, following SAE J1292, ISO 14229, and ISO 15764.

Automotive environmental conditions are generally more severe than those found in many commercial and 
industrial environments. The target automotive, industrial, or commercial environment(s) require careful 
analysis prior to implementation.
104.8.4 Patch panel considerations 
It is possible that the current carrying capability of a cabling cross-connect may be exceeded by a PSE. The 
designer should consult the manufacturers’ specifications to verify compliance with the appropriate 
requirements.
104.8.5 Telephony voltages
The use of building wiring brings with it the possibility of wiring errors that may connect telephony voltages 
to a PSE or PD. Other than voice signals, the primary voltages that may be encountered are the “battery” and 
ringing voltages. Although there is no universal standard, the following maximums generally apply:
Battery voltage to a telephone line is generally 56 Vdc, applied to the line through a balanced 400 Ω source 
impedance. Ringing voltage is a composite signal consisting of an ac component and a dc component. The 
ac component is up to 175 Vp at 20 Hz to 60 Hz with a 100  source resistance. The dc component is 
56 Vdc with 300 Ω to 600 Ω source resistance. Large reactive transients can occur at the start and end of 
each ring interval.
Application of any of the above voltages to the PI of a PSE or a PD in non-automotive applications shall not 
preclude conformance with 104.8.1 and 104.8.2.
104.8.6 Electromagnetic emissions
The PD and PSE powered cabling link shall comply with applicable local and national codes for the 
limitation of electromagnetic interference.
In addition, the system may need to comply with more stringent requirements as agreed upon between 
customer and supplier, for the limitation of electromagnetic interference. In automotive applications, a 
PoDL system shall be tested according to CISPR 25 test methods, and shall meet the following motor 
vehicle EMC requirements:
a)
Radiated/Conducted Emissions: CISPR 25, IEC 61967-1/4, and IEC 61000-4-21
b)
Radiated/Conducted Immunity: ISO 11452, IEC 62132-1/4, and IEC 61000-4-21
c)
Electrostatic Discharge: ISO 10605 and IEC 61000-4-2/3
d)
Electrical Disturbances: IEC 62215-3 and ISO 7637-2/3
Exact test setup and test limit values may be adapted to each specific application, subject to agreement 
between the customer and the supplier.
104.8.7 Temperature and humidity
The PD and PSE powered cabling link segment is expected to operate over a reasonable range of 
environmental conditions related to temperature, humidity, and physical handling. Specific requirements 
and values for these parameters are beyond the scope of this standard.
