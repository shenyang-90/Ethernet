# Annex N (informative) Calibration procedures

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
452 
Annex N  
(informative)  
Calibration procedures 
N.1 General 
N.1.1 Overview 
Inaccuracy in the synchronization of two PTP Instances can result from an asymmetry of the PTP 
Communication Path or PTP Link. In a Direct PTP Link (see 3.1.8) between two PTP Instances there exists 
two sources of asymmetry: timestamp generation latencies (see 7.3.4.2), and medium delays (see 7.4.2).  
Figure N.1 depicts the sources of asymmetry that are modeled in this standard and considered in this annex 
(<messageTimestampPointLatency> is not shown in the figure). 
The annex describes procedures32 that can be used to perform calibration of the sources of asymmetry and 
consequently minimize the effect of the asymmetries on the calculation of <meanDelay> and 
<offsetFromMaster> (see 11.2, 11.3, and 11.4) under assumptions and requirements stated in N.3. 
NOTE—The currentDS.meanDelay stores the current value of <meanDelay> calculated on the PTP Port in the SLAVE 
or UNCALIBRATED state for both delay mechanisms, that is, delay request-response mechanism and the peer-to-peer 
delay mechanism. The <meanDelay> is equal to <meanPathDelay> when the delay request-response mechanism is 
used, and it is equal to <meanLinkDelay> when the peer-to-peer delay mechanism is used. The standard also permits 
implementations where the value of <meanLinkDelay> is stored in transparentClockPortDS.peerMeanPathDelay. This 
member of the transparentClockPortDS is deprecated, thus not considered in this annex. 
 
                                                 
32 The procedures described in this annex are based on the White Rabbit calibration procedure [B5], a document that applies 
calibration to White Rabbit devices communicating over a single-mode fibre that is used for two-way communication (i.e., 
1000BASE-BX10 defined in IEEE Std 802.3). The “White Rabbit calibration procedure” [B5] document provides mathematical 
proofs of the described procedures and estimations of measurement uncertainties. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
453 
PTP code
egress  
stack
ingress 
stack
<egressCapturedTimestamp> 
captured at this point by implementation  
<ingressCapturedTimestamp>
captured at this point by the implementation
xxx.....xxYzzzzzzz
Event message     
Event message     
zzzzzzzYxx.....xxx
 message 
timestamp point
<ingressProvidedTimestamp>
provided to PTP stack
<egressProvidedTimestamp> 
Provided to PTP stack
PTP code
ingress  
stack
egress  
stack
δsm= 
<meanDelay> 
– <delayAsymmetry> 
reference plane for 
<egressTimestamp> and 
<ingressTimestamp> 
δms= 
<meanDelay> 
+ <delayAsymmetry> 
Communication
medium
PTP Port B
in SLAVE state 
or requester
PTP Port A
in MASTER state 
or responder
<implSpecEgressLatencyA>
<egressProvidedTimestamp> 
Provided to PTP Stack  
<impSpecIngressLatencyA>
<egressCapturedTimestamp> 
captured at this point in the implementation
<implSpecEgressLatencyB>
<ingressCapturedTimestamp>
captured at this point by the implementation
<ingressProvidedTimestamp>
provided to PTP stack
 
Figure N.1 Direct PTP Link  
N.1.2 Calibration of ingress and egress latencies 
Ingress and egress latencies per 7.3.4.2 exist because the timestamps are captured at a point removed from 
the reference plane, as depicted in Figure N.1.  
Correction of the latencies is modeled in 7.3.4.2. The measurement of actual values of the latencies is 
referred to as an absolute calibration (for example, see Peek and Jansweijer [B44]). In absolute calibration, 
the measurement of the latencies is not biased by the calibration device (calibrator) and thus it can be 
repeated with the same result using different calibrators, subject to their stated measurement uncertainty. In 
practice, precise absolute calibration of the latencies modeled in 7.3.4.2 is difficult, and depends upon the 
implementation of the PTP Node and the calibrator.  
If the absolute calibration is not used or not sufficient, the accuracy of synchronization can be enhanced by 
a relative calibration. In relative calibration, the measurement of the latencies is biased by the calibrator. 
This bias, however, cancels out if PTP Nodes calibrated with the same calibrator are interconnected. The 
calibration is relative to a given calibrator, and all PTP Nodes must be calibrated using this calibrator to 
achieve enhanced accuracy of synchronization. 
NOTE—Absolute calibration can be used to calibrate a calibrator that is later used to calibrate PTP Nodes using 
relative calibration. 
This annex provides procedures for the relative calibration of ingress and egress latencies. The procedures 
include the following: 
a) 
Measurement of the two-way delay introduced by the medium (N.4.1) 
b) 
Precalibration of a PTP Instance to become a calibrator (N.4.2) 
c) 
Calibration of a PTP Instance using the calibrator (N.4.3) 
d) 
Recovery of a calibrator that is no longer available (N.4.4) 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
454 
N.1.3 Calibration of medium relative delay coefficient (medium asymmetry) 
Medium asymmetry results from a difference between the transmission times of PTP event messages in the 
medium in two directions: master-to-slave and slave-to-master or responder-to-requester and requester-to-
responder.  
If synchronization is performed over a Direct PTP Link without intervening Transparent Clocks, and 
latencies per 7.3.4.2 are accounted for, medium asymmetry is the dominant component of the 
<delayAsymmetry> (see 7.4.2). In certain media, the transmission times in the two directions have a nearly 
constant relationship that can be described by the medium relative delay coefficient defined in 7.4.3 as 
<delayCoefficient> (α). 
This annex provides procedures for the determination of the <delayCoefficient>. The procedures include 
the following: 
a) 
Measurement of the two-way delay introduced by the medium (see N.4.1) 
b) 
Calibration of the relative delay coefficient for media with interrelated one-way delays (see N.4.5) 
NOTE—The parameter referred to as the “medium relative delay coefficient” is obtained using the type of calibration 
referred to as the “absolute calibration.” See the discussion of absolute and relative calibration in N.1.2. 
N.1.4 Applicability of the calibration procedures 
The calibration procedures described in this annex are applicable in PTP Networks in which each network 
element supports PTP. Typically, the applicable networks are relatively small Local Area Networks in 
which the required high level of accuracy (in sub-ns range) justifies the effort needed to perform the 
calibration procedures described in this annex.  
The procedures for calibration of ingress and egress latencies are typically used in PTP Networks where the 
required accuracy of synchronization cannot be achieved through absolute calibration due to technological 
or practical limitations. The latency values obtained through these procedures improve accuracy of 
synchronization on a PTP Communication Path and a PTP Link between two PTP Instances, provided both 
have been calibrated. These calibration procedures can be used for network-level or global calibration. In 
the first case, an operator calibrates its PTP Network using a calibration PTP Instance (calibrator) dedicated 
to the particular network. In the latter case, a certification body provides calibration services using its 
golden calibrator; users of heterogeneous PTP Networks with PTP Instances calibrated and certified by 
such a body expect a certain level of synchronization performance.  
Ingress and egress latencies need to be calibrated for each PTP Port of a PTP Instance.  
Since auxiliary components, such as small form-factor pluggable (SFP), contribute to the calibrated 
latencies, the best accuracy is achieved if calibration is done with the specific components to be utilized in 
the network deployment. Depending on the tolerances of the components of a given type from a specific 
manufacturer, such components can be substituted for each other, without calibration, while maintaining 
sufficient accuracy. 
The procedures for calibration of the medium relative delay coefficient are applicable if the interconnected 
PTP Instances connect using media for which the relative delay coefficient can be defined per 7.4.3. The 
relative delay coefficient needs to be calibrated for each type of medium that is used in the PTP Network. 
For the given type, the value of the relative delay coefficient depends on the direction of this medium 
asymmetry and needs to be configured accordingly (see 7.4.3). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
455 
N.2 Theoretical background 
A Direct PTP Link (see 3.1.8) between two PTP Instances, depicted in Figure N.1, is characterized by: 
 
<ingressLatencyA> and <ingressLatencyB>:  <ingressLatency> per 7.3.4.2 at PTP Ports in 
MASTER and SLAVE state, or responder and requester, respectively. Their values are provided in 
timestampCorrectionPortDS.ingressLatency (see 8.2.16.3) in each respective PTP Instance. 
 
<egressLatencyA> and <egressLatencyB>:  <egressLatency> per 7.3.4.2 at PTP Ports in the 
MASTER and SLAVE state, or responder and requester, respectively. Their values are provided in 
timestampCorrectionPortDS.egressLatency (see 8.2.16.2) in each respective PTP Instance. 
 
<implSpecIngressLatencyA> and <implSpecIngressLatencyB>:  <implementation-specific 
correction of ingressLatency and messageTimestampPointLatency> per 7.3.4.2 at PTP Ports in 
MASTER and SLAVE state, or responder and requester, respectively. 
 
<implSpecEgressLatencyA> 
and 
<implSpecEgressLatencyB>: 
 
<implementation-specific 
correction of egressLatency and messageTimestampPointLatency> per 7.3.4.2 at PTP Ports in 
MASTER and SLAVE state, or responder and requester, respectively. 
 
δms: medium delay in the master-to-slave, or responder-to-requester, direction.  
 
δsm: medium delay in the slave-to-master, or requester-to-responder, direction.  
In the following discussion, tms is used to mean both tms and tresp-to-req; tsm is used to mean both  
tsm and treq-to-resp.  
NOTE 1— The <messageTimestampPointLatency>, defined in 7.3.4.2, is not considered in this annex, thus it is not 
depicted in Figure N.1. If it is known, its value is assumed to be corrected appropriately. If it is not known, its value is 
assumed to be zero. If any uncompensated <messageTimestampPointLatency> exists, its contribution is included the 
values of <ingressLatency> and <egressLatency> that are obtained during calibration. 
In practice, the following three types of latencies can be distinguished: 
a) 
 Dynamic: Their values change during operation. They are referred to as <dynamicIngressLatency> 
and <dynamicEgressLatency>. An example of such latency is the phase offset described in L.3. 
b) 
Semi-static: Their values might change each time the link is established but are otherwise nearly 
constant, subject to temperature changes. They are referred to as <semiStaticIngressLatency> and 
<semiStaticEgressLatency>. An example of <semiStaticIngressLatency> is bitslide; see M.4.2. 
c) 
Static: Their values are nearly constant throughout the lifetime of a PTP Instance, subject to 
temperature changes and aging. They are referred to as <ingressLatency> and <egressLatency>. 
The correction for dynamic and semi-static latencies is implementation specific and is modeled as 
implementation-specific corrections of the captured timestamps specified in 7.3.4.2, that is, 
<implementation-specific correction of egressLatency and messageTimestampPointLatency> and 
<implementation-specific correction of ingressLatency and messageTimestampPointLatency>. The 
timestamps provided to the PTP stack, <egressProvidedTimestamp> and <ingressProvidedTimestamp> 
depicted in Figure N.1, are already corrected for the dynamic and semi-static latencies as follows in 
Equation (N.1) and Equation (N.2).  
egressProvidedTimestamp
egressCapturedTimestamp
dynamicEgressLatency
semistaticEgressLatency
<
> = <
 + <
> + <
>
 
(N.1) 
 
ingressProvidedTimestamp
ingressCapturedTimestamp
dynamicIngressLatency
semistaticIngressLatency
<
> = <
 −<
> −<
>
(N.2) 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
456 
Before they are used for timing computations, the timestamps provided to the PTP stack are corrected for 
static latencies, according to 7.3.4.2: 
 
Egress timestamps, that is, t1 and t3, according to Equation (N.3).  
egressTimestamp
egress Pr ovidedTimestamp
egressLatency
<
> = <
> + <
>  
(N.3) 
 
 
Ingress timestamps, that is, t2 and t4, according to Equation (N.4).  
ingressTimestamp
ingress Pr ovidedTimestamp
ingressLatency
<
> = <
 −<
>  
(N.4) 
 
The corrected timestamps are used to calculate the two-way delay of the Direct PTP Link (see 3.1.8), 
<delayMM>, as follows in Equation (N.5). 
(
) (
) (
) (
)
delay
t
t
t
t
t
t
t
t
2
meanDelay
MM
2
1
4
3
2
3
4
1
<
> =
−
+
−
=
−
+
−
=
<
>  
(N.5) 
where <meanDelay> is the mean value of tms and tsm, that is, <meanDelay> = (tms+tsm)/2. 
Before performing relative calibration, described in this annex, the ingress and egress latencies are not yet 
properly compensated. The <ingressLatency> and <egressLatency> are configured as follows: 
<ingressLatency> = <ingressCoarseLatency> 
<egressLatency > = <egressCoarseLatency> 
where <ingressCoarseLatency> and <egressCoarseLatency> are either of the following: 
 
Coarse values of the ingress and egress latencies 
 
Zero 
Since the timestamps are not properly corrected for the latencies, the <delayMM> includes unknown static 
ingress and egress latencies, that is, Δingress, Δegress, and the two-way delay of the Direct PTP Link (see 3.1.8) 
can be expressed as in Equation (N.6). 
delay
ms
sm
egress,B
egress,A
ingress,A
ingress,B
MM
<
> = ∆
+ ∆
+ ∆
+ ∆
+ δ
+ δ
 
(N.6) 
where 
Δingress,A 
is the unknown static ingress latency, Δingress, at the PTP Port in the MASTER state or 
at the responder  
Δingress,B 
is the unknown static ingress latency, Δingress,  at the PTP Port in the SLAVE state or 
at the requester  
Δegress,A 
is the unknown static egress latency, Δegress,  at the PTP Port in the MASTER state or 
at the responder  
Δegress,B 
is the unknown static egress latency, Δegress,  at the PTP Port in the SLAVE state or at 
the requester  
The goal of the calibration procedure is to obtain the values of these unknown static latencies, which are 
then used to update the values of <ingressLatency> and <egressLatency> as follows: 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
457 
<ingressLatency> = <ingressCoarseLatency> + Δingress 
<egressLatency >  = <egressCoarseLatency> + Δegress 
Once the latencies are obtained and the timestamps are properly corrected for, it is assumed that the 
transmission times, that is, tms and tsm defined in 7.4.2, are nearly equal to the medium delays, that is, tms ≈ 
δms  and tsm ≈ δsm. Consequently, the main contributor to the inaccuracy of synchronization is the medium 
asymmetry, that is, δms ≠ δsm.  
In some media33, the relationship between master-to-slave and slave-to-master, or responder-to-requester 
and requester-to-responder, delays can be described through a <delayCoefficient> (α) defined in 7.4.3 as 
follows in Equation (N.7). 
(
)
ms
sm
t
1
t
=
+ α  
 
(N.7) 
Knowing the <delayCoefficient> (α), the <delayAsymmetry> (see 7.4.2) can be calculated according to 
16.8, as in Equation (N.8). 
[
]
delayAsymmetry
meanDelay
/ (
2)
<
> =
<
>
α
α +
 
(N.8) 
where <meanDelay> is the mean value of tms and tsm, that is, <meanDelay> = (tms+tsm)/2, assuming tms = δms  
and tsm = δsm. 
The goal of the calibration procedure described in this annex is to obtain the value of the 
<delayCoefficient> (α) for the medium in use and a particular direction of its asymmetry (see 7.4.3). The 
procedure can be repeated for each direction of its asymmetry, or the value of the <delayCoefficient> (α') 
for the opposite direction can be calculated as follows: α' = – α/(1+ α). 
Once the value of <delayCoefficient> (α) for a given medium and its asymmetry direction is known, the 
<delayAsymmetry> can be calculated and used to correct the <meanDelay> for medium asymmetry, per 
16.8. 
NOTE 2— In 16.8, <delayAsymmetry> = asymmetryCorrectionPortDS.constantAsymmetry + [α /( α +2)] 
(<meanDelay>). 
During 
calibration 
procedures 
described 
in 
this 
annex, 
the 
value 
of 
asymmetry 
CorrectionPortDS.constantAsymmetry is set to zero; thus, it is not included in Equation (N.8). When using 16.8, the 
value of asymmetryCorrectionPortDS.constantAsymmetry can be used to fine-tune the <delayAsymmetry> computed 
using <delayCoefficient> (α). This <delayCoefficient> (α) can be obtained using the calibration procedure described in 
this annex. The method to obtain the value of asymmetryCorrectionPortDS.constantAsymmetry, when using it 
according to 16.8, is outside the scope of this annex. 
N.3 Assumptions and requirements 
The following assumptions and requirements concern the PTP Instance used in the calibration procedures: 
a) 
For the purpose of performing the calibration, the PTP Instance provides an output signal outside of 
PTP, for example, a PPS signal, that can be compared with a signal outside of PTP of another PTP 
Instance. The PTP Instance Time (see 3.1.54) is represented by the significant instants of this 
output signal, and the calibration ensures that this representation of the PTP Instance Time on all 
the calibrated PTP Instances is synchronized regardless of internal delays of these output signals, 
provided these internal delays are constant within required uncertainty for each PTP Instance. 
Correction for such internal delays is outside the scope of this standard. 
                                                 
33 One known example: single-mode fiber used for two-way communication, 1000BASE-BX10 defined in IEEE Std 802.3.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
458 
NOTE 1— The delay between the internal implementation of the Local PTP Clock and the significant instant 
of the output signal outside of PTP (e.g., rising edge of the PPS signal) is, in general, non-negligible for high 
accuracy applications. The assumption that the PTP Instance Time is represented by the output signal makes 
the internal delay irrelevant for the calibration described in this annex. This is explained with a mathematical 
proof for the PPS output signal in A.6 of Daniluk [B5]. 
b) 
The PTP Instance supports and has enabled the following optional features of this standard: 
1) 
“16.7 Configurable correction of timestamps” which means that the PTP Instance supports the 
following optional members of timestampCorrectionPortDS: egressLatency (see 8.2.16.2) and 
ingressLatency (see 8.2.16.3).  
2) 
“16.8 Calculation of the <delayAsymmetry> for certain media” which means that the PTP 
Instance 
supports 
the 
following 
optional 
members: 
asymmetryCorrectionPortDS. 
constantAsymmetry (see 8.2.17.2), asymmetryCorrectionPortDS.scaledDelayCoefficient  
(see 8.2.17.3), and asymmetryCorrectionPortDS.enable (see 8.2.17.4), and this option is 
enabled. 
c) 
The precision of the calibration is limited by the precision of the timestamps. The PTP Instance 
provides timestamps with precision sufficient for the intended accuracy of synchronization. 
d) 
The PTP Instance is provided with <egressProvidedTimestamp> and <ingressProvidedTimestamp> 
that are already corrected by the implementation for dynamic and semi-static latencies according to 
Equation (N.1) and Equation (N.2) with a precision sufficient for the intended synchronization 
performance. 
e) 
The PTP Instance provides to the user, through management or implementation-specific 
mechanism, the current value of <meanDelay> which is used to calculate the two-way delay, 
<delayMM>, that is, <delayMM> [ns] = 2 × currentDS.meanDelay. 
NOTE 2— The data set member currentDS.meanDelay provides the value of <meanPathDelay> per 11.3 
when the delay request-response mechanism is in use, and the value of <meanLinkDelay> per 11.4 when 
peer-to-peer delay mechanism is in use. The data type of currentDS.meanDelay is TimeInterval. It is assumed 
that appropriate conversion to nanoseconds is performed. 
NOTE 3— For procedures described in N.4.1, N.4.2, N.4.3, and N.4.4, if peer-to-peer delay mechanism is 
used, the two-way delay can be also calculated using the value of the <meanLinkDelay>, that is,  
<delayMM> [ns] = 2 ×  portDS.meanLinkDelay. 
f) 
The PTP Instance under Calibration is a Boundary Clock or an Ordinary Clock and its 
Timestamping Clock is the Local PTP Clock. 
The auxiliary equipment required for the calibration includes the following: 
g) 
Medium of the same type that is used in the deployed PTP Network, either: 
1) 
A short piece of medium of which the two-way delay is known with a precision and accuracy 
sufficient for the intended synchronization performance, or 
2) 
Two pieces, short and long, of medium of the same type and substantially different length34 
that can be directly connected with negligible, for the intended synchronization accuracy, 
delay and asymmetry introduced by the interconnection. The two-way delay of these two 
pieces can be measured following the procedure in N.4.1. 
h) 
Calibrator: 
1) 
An existing calibrator obtained either using the relative calibration described in N.4.2 or an 
absolute calibration (see Peek and Jansweijer [B44]); or 
2) 
Two identical PTP Instances (contained in identical PTP Nodes) that can be used to create a 
calibrator following the procedure in N.4.2. 
                                                 
34 Ideally, the lengths of the two pieces of medium differ by several orders of magnitude and their combined length is as large as is 
practical. For example, the 1000BASE-BX10 medium defined in IEEE Std 802.3 used in White Rabbit [B53] is defined for up to 
10 km over single-mode fiber and the two pieces used for the calibration have typically lengths of 1 m and 9.6 km. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
459 
i) 
A device that can measure the time difference between two signals (for example, two PPS signals) 
[see item a) in N.3] with a precision and accuracy sufficient for the intended synchronization 
performance, for example an oscilloscope or Time Interval Counter. This device is connected to the 
output signals of the PTP Instances with cables of equal delay. 
These are the assumptions and requirements concerning the medium used during calibration: 
j) 
The asymmetry of the medium is nearly constant throughout its lifetime, subject to temperature 
changes and aging, unless the variation of asymmetry is known and accounted for by means outside 
the scope of this annex. 
k) 
The medium is wired; calibration over wireless is not covered. 
l) 
To perform procedures described in N.4.3 and N.4.4, the asymmetry of the medium needs to be 
either negligible or accounted for as described in 7.4.2. If applicable, the relative medium delay 
coefficient can be obtained using the procedure in N.4.5 and the asymmetry can be accounted for as 
described in 16.8. 
All the procedures described in N.4 need to be performed at constant temperature. The procedures 
described in N.4.1 and N.4.5 need to be performed at the same temperature. 
N.4 Calibration procedures 
N.4.1 Two-way medium delay calibration 
The measurement of the two-way medium delay, that is, δ = δms + δsm, is described in this subclause. It 
requires two pieces of medium that fulfill the requirements in N.3. These two pieces are henceforth referred 
to as cableshort and cablelong. The PTP Instances used in this procedure need not be calibrated. The results of 
the measurement described in this section are used in the following sections. 
The procedure to obtain the two-way medium delays of cableshort and cablelong is as follows: 
a) 
Synchronize the two PTP Instances via cableshort, see Figure N.2. When stable synchronization is 
achieved, note the two-way delay, for example, <delayMM>1 [ns] = 2·currentDS.meanDelay 
provided by the Slave PTP Instance.  
NOTE—When the peer-to-peer delay mechanism is used, the two-way delay is provided by both PTP 
Instances and can be also obtained as follows:  <delayMM>1 [ns]= 2·portDS.meanLinkDelay. This also applies 
to step b) and step c). 
b) 
Synchronize the two PTP Instances via cablelong and the same PTP Ports as in step a)  
(see Figure N.2). When stable synchronization is achieved, note the two-way delay, for example, 
<delayMM>2 [ns]= 2·currentDS.meanDelay provided by the Slave PTP Instance. 
c) 
Synchronize the two PTP Instances via interconnected cableshort and cablelong and the same PTP 
Ports as in step a) and step b) (see Figure N.2). When stable synchronization is achieved, note the 
two-way delay, for example, <delayMM>3 [ns] = 2·currentDS.meanDelay provided by the Slave 
PTP Instance. 
Calculate the two-way medium delay of cableshort (δshort) and cablelong (δlong) as follows in Equation (N.9). 
3
2
[ns]
<delay
>
<delay
>
short
MM
MM
δ
=
−
 
(N.9) 
δlong [ns] = <delayMM>3 – <delayMM>1 
 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
460 
Master PTP Instance:
PTP Port in MASTER 
state
Master PTP Instance:
PTP Port in MASTER 
state 
Master PTP Instance:
PTP Port in MASTER 
state
Slave PTP Instance:
PTP Port in SLAVE 
state
Slave PTP Instance:
PTP Port in SLAVE 
state
Slave PTP Instance:
PTP Port in SLAVE 
state
δshort
δlong
δlong
δshort
a ) cableshort
b ) cablelong
c ) cableshort + cablelong
 
Figure N.2 Two-way medium delay calibration 
N.4.2 Calibrator precalibration 
The steps necessary to create a calibrator from an arbitrary PTP Instance/Node are described in this section. 
Alternatively, a calibrator can be obtained using absolute calibration, see Peek and Jansweijer [B44]. 
Precalibration of the calibrator requires two identical instances of a PTP Instance/Node, one of which 
becomes the calibrator. 
NOTE 1— The two PTP Instances are required to be identical so that their latencies are equal. Therefore, ideally, they 
are contained in PTP Nodes of the same manufacturing series, with the same hardware, firmware, software and relevant 
configuration. 
The procedure to precalibrate a selected PTP Port of the calibrator is as follows: 
a) 
Set the value of timestampCorrectionPortDS.ingressLatency (see 8.2.16.3) and timestamp 
CorrectionPortDS.egressLatency (see 8.2.16.2) at the selected PTP Ports of the two PTP Instances 
to either: 
1) 
A coarse value, for example, provided by the manufacturer, or 
2) 
Zero 
b) 
Synchronize the two identical PTP Instances via the selected ports using the cableshort. When stable 
synchronization 
is 
achieved, 
note 
the 
two-way 
delay, 
for 
example, 
<delayMM>  
[ns] = 2 × currentDS.meanDelay provided by the Slave PTP Instance.  
NOTE 2— When the peer-to-peer delay mechanism is used, the two-way delay is provided by both PTP Instances and 
can be also obtained as follows:  <delayMM> [ns]= 2 × portDS.meanLinkDelay. 
c) 
Calculate the unknown static ingress and egress latencies, Δingress and Δegress, of the selected ports on 
both PTP Instances as follows in Equation (N.10). 
[ ]
[ ] (
)
ns
ns
delay
/ 4
egress
ingress
short
MM
∆
= ∆
= <
> −δ
 
(N.10) 
 
where δshort is the two-way medium delay of the cableshort obtained through the procedure in N.4.1. 
NOTE 3— The unknown static ingress and egress latencies on both PTP Instances are assumed to be equal, while an 
asymmetry between these latencies is likely to exist in reality. This assumption does not affect the calibration quality, 
since the asymmetry is taken into account during the calibration of PTP Instances using the calibrator (see N.4.3, in 
particular, NOTE 6—), see an explanation with a mathematical proof in A.3 of Daniluk [B5]. 
d) 
Choose one of the PTP Instances to be the calibrator and update the configuration of its 
timestampCorrectionPortDS.ingressLatency and timestampCorrectionPortDS.egressLatency for the 
selected port with the calculated latencies, Δingress and Δegress, in the following steps: 
1) 
Read the current values of the current data set members: 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
461 
<oldIngressLatency> = timestampCorrectionPortDS.ingressLatency 
<oldEgressLatency> = timestampCorrectionPortDS.egressLatency 
2) 
Set the new values of the data sets members, as follows: 
timestampCorrectionPortDS.ingressLatency = <oldIngressLatency> +  Δingress [ns] × 2+16 
timestampCorrectionPortDS.egressLatency  = <oldEgressLatency>  +  Δegress [ns] × 2+16 
NOTE 4— The timestampCorrectionPortDS.ingressLatency and timestampCorrectionPortDS.egressLatency are of type 
TimeInterval (see 5.3.2). 
e) 
Use the configured PTP Instance, and its selected PTP Port, as the calibrator. 
N.4.3 PTP Instance calibration 
The procedure to calibrate a single PTP Port of a PTP Instance Under Calibration (PIUC) using the 
calibrator specified in N.3 is as follows: 
a) 
Set 
the 
value 
of 
timestampCorrectionPortDS.ingressLatency 
(see 
8.2.16.3) 
and 
timestampCorrectionPortDS.egressLatency (see 8.2.16.2) at the PTP Port of the PIUC to either one 
of the following: 
1) 
A course value, for example provided by the manufacturer 
2) 
Zero 
b) 
Synchronize the PIUC over the PTP Port with the calibrator using cableshort. The PIUC is assumed 
to be a Slave PTP Instance and have its PTP Port in the SLAVE state. When stable synchronization 
is achieved, note the two-way delay, for example <delayMM> [ns] = 2 × currentDS.meanDelay 
provided by the Slave PTP Instance. 
NOTE 1— When the peer-to-peer delay mechanism is used, the two-way delay is provided by both PTP Instances and 
can be also obtained as follows:  <delayMM>  [ns]= 2 × portDS.meanLinkDelay. 
NOTE 2— In this procedure, a short cable (cableshort) is used to minimize the effect of the medium asymmetry on the 
measurement results. For short medium, the value of asymmetry tends to be negligible. This procedure provides the 
most accurate results if the medium asymmetry is compensated. If an applicable medium is used, this can be achieved 
by setting the value of asymmetryCorrectionPortDS.scaledDelayCoefficient obtained through calibration described in 
N.4.5 (with the asymmetryCorrectionPortDS.constantAsymmetry set to zero). It can be also achieved by setting the 
value of asymmetryCorrectionPortDS.constantAsymmetry obtained through a procedure outside the scope of this 
annex 
(with 
the 
asymmetryCorrectionPortDS.scaledDelayCoefficient 
set 
to 
zero). 
If 
not 
known, 
set 
asymmetryCorrectionPortDS.scaledDelayCoefficient and asymmetryCorrectionPortDS.constantAsymmetry to zero, 
and use cableshort that is as short as possible. 
NOTE 3— The <delayMM> is calculated using timestamps generated by the calibrator and the timestamps generated by 
the PIUC. The timestamps generated by the calibrator are corrected for ingress and egress latencies obtained either 
following the procedure in N.4.2 or an absolute calibration (for example, see Peek and Jansweijer [B44]) outside the 
scope of this annex. 
c) 
Calculate the average (coarse) value, Δcoarse, of the unknown ingress and egress latencies of the PTP 
Port of the PIUC, as follows in Equation (N.11). 
[ ] (
) 2
/
short
MM
delay
ns
coarse
δ
−
>
<
=
∆
 
(N.11) 
where δshort is the two-way medium delay of the cableshort obtained through the procedure in N.4.1. 
NOTE 4— In reality, the unknown ingress and egress latencies of the PIUC are not equal. The difference between their 
values and their asymmetry results in an offset between the two PTP Instances. This asymmetry is taken into account in 
the next steps. 
d) 
Update the configuration of timestampCorrectionPortDS.ingressLatency and timestampCorrection 
PortDS.egressLatency at the PTP Port of the PIUC with the calculated coarse latency value Δcoarse 
in the following steps: 
1) 
Read the values of the current data set members of the PIUC, as follows: 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
462 
<oldIngressLatency> = timestampCorrectionPortDS.ingressLatency 
<oldEgressLatency> = timestampCorrectionPortDS.egressLatency 
2) 
Set the new values of the data set members, as follows: 
timestampCorrectionPortDS.ingressLatency=<oldIngressLatency>+ Δcoarse [ns] × 2+16 
timestampCorrectionPortDS.egressLatency  =<oldEgressLatency> + Δcoarse  [ns] × 2+16 
e) 
Resynchronize the PIUC with the calibrator via cableshort using the same PTP Port and the newly 
configured static ingress and egress latencies. When stable synchronization is achieved, measure 
the time difference between the output signals [e.g., PPS; see item a) of N.3] of the Master PTP 
Instance and of the Slave PTP Instance defined as follows: 
[ ]
measuredOffsetFromMaster
ns
time of Slave Clock output signal
time of Master Clock output signal
<
>
= <
> −<
>
(N.12) 
where all times are measured at the same instant as observed by an appropriate measurement 
device, for example an oscilloscope connected to the output signals from the PIUC and the 
calibrator. The value of <measuredOffsetFromMaster> is positive if the transition at the Slave 
Clock output occurs later than the transition at the Master Clock output. The measurement of 
<measuredOffsetFromMaster> is depicted in Figure N.3.  
NOTE 5— It is assumed that the output signals of the Master PTP Instance and the Slave PTP Instance represent their 
Local PTP Clocks, the Master Clock and the Slave Clock, respectively. 
f) 
Calculate the precise values of the unknown ingress and egress latencies, Δingress, Δegress  as follows: 
Δingress [ns] = Δcoarse + <measuredOffsetFromMaster> 
Δegress  [ns] = Δcoarse – <measuredOffsetFromMaster>  
NOTE 6— The asymmetry measured in this stage of calibration, <measuredOffsetFromMaster> is, in fact, the sum of 
asymmetries introduced by the PIUC and the calibrator. However, the component of the calibrator’s asymmetry cancels 
out when connecting two PTP Ports calibrated to the same calibrator, see an explanation with a mathematical proof in 
A.3 of Daniluk [B5]. If the connected PTP Ports are calibrated using different calibrators, the component of the 
calibrator's asymmetry, in general, does not cancel out. 
g) 
Update 
the 
configuration 
of 
the 
timestampCorrectionPortDS.ingressLatency 
and 
timestampCorrectionPortDS.egressLatency at the PIUC with the following calculated precise 
values of the unknown ingress and egress latencies, Δingress and Δegress: 
timestampCorrectionPortDS.ingressLatency=<oldIngressLatency> + Δingress [ns] × 2+16 
timestampCorrectionPortDS.egressLatency  =<oldEgressLatency>  + Δegress   [ns] × 2+16 
h) 
Repeat this procedure for each PTP Port of the PIUC and each detectable configuration35 of each 
PTP Communication Path or PTP Link. 
 
                                                 
35 For example, in the case of communication over fibre-optic medium, the detectable configuration includes the type and 
manufacturer of the small form-factor pluggable (SFP) module. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
463 
Master PTP 
Instance
Slave PTP 
Instance
δshort
n                                     n+1
n                                     n+1
Physical representation 
of Local PTP Clock in 
the Master PTP Instance
Physical representation 
of Local PTP Clock in
the Slave PTP Instance
Time
<Time of Master
Clock output signal >
<Time of Slave
Clock output signal >
positive (+)  
<measuredOffsetFromMaster> [ns]
Physical
output signals
(e.g. PPS)
delayA
delayA
Measurement device
 
Figure N.3 Measurement of <measuredOffsetFromMaster> 
N.4.4 Calibrator recovery-calibration 
It can happen that the calibrator used to calibrate a PTP Network, or the golden calibrator, is no longer 
available. The lack of the calibrator makes it impossible to connect new PTP Instances without 
recalibrating the entire PTP Network. It is possible to obtain values of the static ingress and egress latencies 
for an arbitrary PTP Instance/Node so that it can be used as the new calibrator. PTP Instances calibrated 
using the new calibrator will correctly synchronize with the PTP Instances calibrated using the original 
calibrator.  
NOTE—The new calibrator can be used to calibrate any PTP Instance that is intended to be connected to the existing 
PTP Network, made of PTP Instances calibrated with the original calibrator. The new calibrator can be also used to 
calibrate PTP Instances that are intended to be connected with other PTP Instances calibrated with the new calibrator. 
Note that the measurement errors accumulate. It might become an issue if the new calibrator uses values recovered with 
a PTP Instance that had been already calibrated to a recovered calibrator. The longer this chain of calibrations is, the 
more inaccuracy is expected from the calibration procedure.  
To calibrate the new calibrator, the procedure described in N.4.3 can be used. In the procedure, a PTP 
Instance calibrated using the original calibrator takes the role of the calibrator, and the arbitrary PTP 
Instance/Node to become a new calibrator is the PTP Instance Under Calibration (PIUC). 
N.4.5 Calibration of relative delay coefficient for media with interrelated one-way delays 
The procedure to obtain the value of <delayCoefficient> (α), 7.4.3, for one direction of the Medium Under 
Calibration (MUC) and its asymmetry, is as follows: 
a) 
Set the value of asymmetryCorrectionPortDS.scaledDelayCoefficient (see 8.2.17.3) in the two PTP 
Ports to zero. 
b) 
Set the value of asymmetryCorrectionPortDS.constantAsymmetry (see 8.2.17.2) in the two PTP 
Ports to zero. 
c) 
Synchronize the two PTP Instances using MUC cableshort (see part 1 of Figure N.4). When stable 
synchronization is achieved, measure the time difference between the output signals of the Master 
PTP Instance and of the Slave PTP Instance, that is, <measuredOffsetFromMaster>1 [ns]; see point 
e) of N.4.3. 
d) 
Synchronize the two PTP Instances using MUC cablelong (see part 2 of Figure N.4). When stable 
synchronization is achieved, measure the time difference between the output signals of the Master 
PTP Instance and of the Slave PTP Instance, that is, <measuredOffsetFromMaster>2 [ns]; see  
point e) of N.4.3. 
e) 
Calculate the <delayCoefficient> (α) as follows in Equation (N.13). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
464 
[
]
[
]
1
ster
fsetFromMa
measuredOf
2
ster
fsetFromMa
measuredOf
2
long
1
ster
fsetFromMa
measuredOf
2
ster
fsetFromMa
measuredOf
2
>
<
−
>
<
−
>
<
−
>
<
⋅
=
δ
α
 
(N.13) 
 
where δlong [ns] is the two-way medium delay of MUC cablelong obtained through the procedure in 
N.4.1 under the same temperature as the measurements of the time difference. 
f) 
Set the value of asymmetryCorrectionPortDS.scaledDelayCoefficient in the Slave PTP Instance at 
the PTP Port in the SLAVE state as follows: 
 asymmetryCorrectionPortDS.scaledDelayCoefficient =   α × 262 
g) 
Repeat for the inverted direction of the MUC and its asymmetry, and for each type of 
communication medium. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
465 
NOTE 1— The value of the <delayCoefficient> (α) can be calibrated for each direction of a particular medium using 
the procedure above. However, if <delayCoefficient> (α) for one direction of medium asymmetry is known, the 
<delayCoefficient> (α') for the opposite direction of the medium and its asymmetry can be calculated as follows:  
α' = – α/(1+ α) (see NOTE 3— in 7.4.3). Therefore, the value of asymmetryCorrectionPortDS.scaledDelayCoefficient 
for the opposite direction of medium asymmetry is:  
asymmetryCorrectionPortDS.scaledDelayCoefficient = α' × 262 = – α/(1+ α) × 262. 
NOTE 2— As examples, the value of the <delayCoefficient> (α') for the opposite direction of the medium asymmetry 
can be set as follows:  
 
On the same PTP Port that was configured in the step f) of the calibration procedure above, if the medium is 
reconnected so that the direction of the medium asymmetry is opposite to the one during calibration. If single-
mode fiber is used for two-way communication (1000BASE-BX10 defined in IEEE802.3), this is the case 
when the SFPs are swapped between the two PTP Ports. 
 
On the Direct PTP Link’s other PTP Port connected using the MUC to the PTP Port that was configured in the 
step f) of the calibration procedure above. 
NOTE 3— For some media, it is possible to provide auto-detection of the type and/or direction of the medium that is 
connected to a PTP Port. The detection of the type and/or direction enables the determination of the value of the 
<delayCoefficient> (α) to be configured on the PTP Port (see NOTE 4— in 7.4.3). 
Master PTP 
Instance
Slave PTP 
Instance
δshort
n                                     n+1
n                                     n+1
Physical representation 
of Local PTP Clock in 
the Master PTP Instance
Physical representation 
of Local PTP Clock in
the Slave PTP Instance
Time
<Time of Master
Clock output signal >
<Time of Slave
Clock output signal >
positive (+)  
<measuredOffsetFromMaster> [ns]
Physical
output signals
(e.g. PPS)
delayA
delayA
Measurement device
1 ) Measurement <measuredOffsetFromMaster>1 with cableshort                                              
Master PTP 
Instance
Slave PTP 
Instance
δlong
n                                     n+1
n                                     n+1
Physical representation 
of Local PTP Clock in 
the Master PTP Instance
Physical representation 
of Local PTP Clock in
the Slave PTP Instance
Time
<Time of Master
Clock output signal >
<Time of Slave
Clock output signal >
positive (+)  
<measuredOffsetFromMaster> [ns]
Physical
output signals
(e.g. PPS)
delayA
delayA
Measurement device
 2 ) Measurement of <measuredOffsetFromMaster>2 with cablelong
 
Figure N.4 Calibration of medium delay coefficient for a medium with proportional  
one-way delays 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
