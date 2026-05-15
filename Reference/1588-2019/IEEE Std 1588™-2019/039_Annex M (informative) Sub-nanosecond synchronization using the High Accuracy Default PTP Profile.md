# Annex M (informative) Sub-nanosecond synchronization using the High Accuracy Default PTP Profile

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
445 
Annex M  
 
(informative)  
 
Sub-nanosecond synchronization using the High Accuracy Default PTP 
Profile 
M.1 General 
The High Accuracy Delay Request-Response Default PTP Profile requires the High Accuracy optional 
features per I.5.3. The features provide generic protocol mechanisms to support specialized hardware that 
enhances the accuracy of synchronization, outlined in Ronen and Lipinski [B51]. The accuracy 
enhancement depends on the hardware implementation. This annex describes an example implementation 
of the High Accuracy Delay Request-Response Default PTP Profile and its optional features that (at the 
output of the synchronization chain) can provide sub-nanosecond accuracy over a properly designed 
network. Note that performance during network rearrangements or network element failures are not 
addressed. This implementation originates from the White Rabbit open source implementation [B53] 
described in Wlostowski [B57] and Lipinski et al. [B38], and is provided by the European Organization for 
Nuclear Research (CERN). 
The example implementation of the High Accuracy Default PTP Profile: 
 
Uses the L1Sync (see Annex L) optional feature with the default values of the profile’s attributes 
and implements the High Accuracy Clock Model (see I.5.5) to provide a frequency loopback  
(see M.2), 
 
Enhances the precision of timestamps by correcting for the dynamic latencies according to the Link 
Reference Model in L.3 using the Digital Dual Mixer Time Difference (DDMTD) phase offset 
detector described in Moreira et al. [B41] (see M.3), 
 
Enhances the accuracy of timestamps by correcting for the semi-static and the static latencies 
described in Annex N per 7.3.4.2 and 16.7 (see M.4), 
 
Uses a single strand of single-mode fiber (1000BASE-BX10, defined in IEEE Std 802.3) for 
bidirectional communication and calculates its medium asymmetry with the medium relative delay 
coefficient per 16.8 (see M.5), 
 
Provides clock characteristics described in Rizzi et al [B50] (see M.6). 
The PTP Instances with the described example implementation are calibrated using the procedures in 
Annex N to provide sub-nanosecond accuracy of synchronization.  
M.2 Frequency loopback 
A PTP Instance based on the example shown in this annex implements the High Accuracy Clock Model 
(see I.5.5) and uses the L1Sync optional feature (see Annex L) with the default values of the High 
Accuracy Default PTP Profile (see I.5.3). This configuration of the L1Sync optional feature requires the 
PTP Ports of a PTP Instance to be transmit coherent, receive coherent, and congruent. When two such PTP 
Instances, A and B, are connected, that is, when all the following are true:  
 
the L1 tx clock signal transmitted by PTP Instance A at its PTP Port, in the MASTER state, is 
syntonized to, and coherent with, the Local PTP Clock of that PTP Instance 
 
the Local PTP Clock of the PTP Instance B is syntonized to, and coherent with, the L1 rx clock 
signal received at its PTP Port in the SLAVE state, except for the transients when the Local PTP 
Clock is adjusted to compensate the offset from Master, the L1 rx clock signal received by the PTP 
Instance B is the L1 tx clock signal transmitted by the PTP Instance A 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
446 
 
the L1 tx clock signal transmitted by the PTP Instance B at its PTP Port, in the SLAVE state, is 
syntonized to, and coherent with, the Local PTP Clock of that PTP Instance 
 
the L1 rx clock signal received by the PTP Instance A at its PTP Port in the MASTER state is 
traceable to Local PTP Clock of that PTP Instance 
then a frequency loopback between the two PTP Instances exists, as depicted in Figure M.1 (see also 
section 2 of Rizzi et al. [B50]). The traceability of the clock signals of the two PTP Instances to the same 
frequency source means that, except in transients, their phase offsets are nearly constant, and therefore can 
be precisely measured. The example implementation described in this annex uses a DDMTD-based phase 
offset detector. 
In addition to phase offset detection, the frequency loopback is important when implementing the L1Sync 
optional feature. The frequency loopback exists when all of the following are true: 
 
The PTP Port in the MASTER state is a transmit coherent port (i.e., isTxCoherent is TRUE;  
see L.5.3.2) 
 
The PTP Port in the SLAVE state is a transmit coherent, that is, isTxCoherent is TRUE  
(see L.5.3.2) and a receive coherent port, that is, isRxCoherent is TRUE (see L.5.3.3) 
As a consequence of the High Accuracy Clock Model implementation, when the frequency loopback exists, 
the PTP Port in the MASTER state is a receive coherent port by design. Therefore, the example 
implementation of the L1Sync optional feature sets the value of the dynamic data set member 
L1SyncBasicPortDS.isRxCoherent to TRUE as soon as the following dynamic data set members are all 
TRUE: isTxCoherent, peerIsTxCoherent, and peerIsRxCoherent. 
 
n           n+1
n           n+1
+xrx_A
time
+xrx_B
Phase detector
n           n+1
Local 
PTP Clock
L1 tx
Clock signal
L1 rx
Clock signal
L1 tx
Clock signal
L1 rx
Clock signal
Phase shifting PLL
n            n+1
Local 
PTP Clock
PTP node A
PTP node B
 
Figure M.1 Clock signal loopback between PTP Ports in the MASTER and SLAVE state of 
two PTP Instances 
Note that the Local PTP Clocks of the two interconnected PTP Instances in the example implementation 
are physically syntonized and synchronized. The syntonization is performed using the L1 clock signal 
while the synchronization is achieved exchanging the PTP timing messages. The PTP Instance B 
synchronizes to the PTP Instance A by adjusting its time counter, as well as the frequency and phase offset 
of its Local PTP Clock signal with respect to the L1 rx clock signal. Consequently, the frequency, phase, 
and time counter of PTP Instance B agree with that of PTP Instance A. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
447 
NOTE—In the example implementation, if the value of the offsetFromMaster is larger than the Local PTP Clock signal 
period, the time counter value is changed accordingly (with resolution of the period value) while the Local PTP Clock 
signal frequency is not changed, and thus the L1 tx clock signal frequency also is not changed. If the value of the 
offsetFromMaster is smaller than the Local PTP Clock signal period, the phase of the Local PTP Clock signal is 
adjusted by temporarily changing its frequency, and thus the L1 tx clock signal frequency also is temporarily changed. 
M.3 Timestamping precision 
M.3.1 General 
The timestamping precision of the example implementation described in this annex is ±4 ps. It is achieved 
by correcting timestamps according to the Link Reference Model (see L.3) with the phase offset 
measurement performed using the DDMTD. The measured phase offset is considered a dynamic latency 
(see N.2) and a contributor to the <implementation-specific correction of ingressLatency and 
messageTimestampPointLatency> per 7.3.4.2. 
M.3.2 Digital Dual Mixer Time Difference (DDMTD) phase offset detector 
The DDMTD is described in Moreira et el [B41]. It uses digital mixing to produce output clock signals of 
lower frequency than that of the input clock signals. The phase offset, expressed in radians, between the 
input clock signals is equal to that between the output clock signals. Therefore, the time-difference (phase 
offset expressed in units of time) between the phases of the input clock signals is proportional to that of the 
output clock signals. The output phase offset can be measured with much greater precision. 
In the example implementation of the DDMTD, the input clock signals clkAin and clkBin are traceable to the 
same source and therefore have the same nominal frequency fin. These clock signals are sampled with  
D-type flip-flops, as presented in Figure M.2. 
 
n-1        n           n+1
xin
n           n+1       n+2
D   Q
D   Q
clkPLL
PLL
fPLL=         fAin
N
N+1
clkAin
clkBin
clkAout
clkBout
xout
m
m                                                                   m+1
 
Figure M.2 Digital Dual Mixer Time Difference (DDMTD) phase offset detector 
The flip-flops are clocked with an offset clock signal, clkPLL, that is generated from one of the input clocks 
signals with a Phase Locked Loop (PLL). Its frequency, fPLL, is very close to fin. Their relationship is 
specified as follows in Equation (M.1). 
in
PLL
f
N
N
f
1
+
=
 
 
(M.1) 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
448 
where N is an implementation-specific value that is 214 in the example implementation. The sampling 
operation performed by the flip-flops is similar to analog mixing and low-pass filtering. The output clock 
signals, clkAout and clkBout, are of a frequency that is proportional to the frequency of the input clock signals, 
as in Equation (M.2). 
in
out
f
N
f
1
1
+
=
 
 
(M.2) 
When the phase offset is expressed in units of time, the phase offset between the output clock signals, xout, 
is proportional to the phase offset between the input clock signals, xin, as in Equation (M.3). 
[
]
[
]
1
ns
ns
1
in
out
x
x
N
=
+
 
 
(M.3) 
In the example implementation, a counter that is clocked with the input clock signals, fin, is used to measure 
the phase offset, xout, between the output clock signals. This value is then used to calculate xin. The 
measurement resolution for xin is proportionally higher than that for xout, for example, for an input clock of 
125 MHz and N = 214, the output phase offset is measured with a resolution of 8 ns, which gives a 
resolution of 0.488251 ps for the measurement of xin. 
M.3.3 Enhancement of timestamping precision using phase detection 
The phase offset measurement obtained by the DDMTD is used to enhance the coarse value of the 
timestamps from nanoseconds to picoseconds following the Link Reference Model described in L.3. In the 
example implementation, only the reception timestamps need enhancing; the transmission timestamps are 
precise by design as the L1 tx clock signal is directly derived from the Local PTP Clock. 
A coarse reception timestamp is captured by latching the value of a time counter when the message 
timestamp point (e.g., Start of Frame delimiter) is detected. In the example implementation, the time 
counter is incremented by the Local PTP Clock signal, the message timestamp point is aligned with the L1 
rx clock signal; thus, the coarse timestamp has a resolution of the Local PTP Clock signal period, for 
example, 8 ns for 125 MHz. The coarse timestamp is enhanced by measuring the phase offset between the 
Local PTP Clock signal and the L1 rx clock signal. This phase offset is nearly constant thanks to the 
existing frequency loopback and can be precisely measured using the DDMTD phase offset detector. The 
measured phase offset constitutes portion of the <implementation-specific correction of ingressLatency and 
messageTimestampPointLatency> and is used to correct the <capturedIngressTimestamp> as specified in 
7.3.4.2. The other portion of this correction is the semi-static latency described further in M.4.2. 
The resolution of the enhanced timestamps in the example implementation, that is, N = 214, fin = 125 MHz, 
is approximately 0.5 ps. The measured precision is ±4 ps. 
M.4 Timestamping accuracy 
M.4.1 General 
The timestamping accuracy is enhanced in the example implementation by automatic correction of semi-
static latencies and user calibration of the static latencies.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
449 
The timestamps are typically captured at a point removed from the reference plane. The time interval 
between the actual time of detection and the time the message timestamp point passes the reference plane is 
defined in 7.3.4.2 as ingress latency for the received PTP messages and as egress latency for the transmitted 
PTP messages. The asymmetry between these latencies contributes to the inaccuracy of synchronization. 
Apart from the dynamic latency mentioned in M.3, two components of these latencies are identified in 
Annex N: static and semi-static. The static latencies need to be calibrated by the user or manufacturer, for 
example, through the procedures described in Annex N. Other mechanisms, including automated options, 
are possible. To obtain the most optimal calibration and accurate synchronization, the semi-static latencies 
need to be measured and corrected for by the implementation.  
M.4.2 Semi-static latency 
A semi-static latency is described in N.2 as the type of latency that can change each time the link is 
established but is nearly constant while the link is active, subject to temperature changes. This latency 
results from any bit-level misalignment between the L1 rx clock signal recovered from the serial bit stream 
and the serial word border (see Figure M.3). While the parallel word (upon which the timestamp is 
generated) is aligned with the L1 rx clock signal, the actual timestamping point that crossed the reference 
plane is aligned with the serial word border, resulting in a semi-static latency (bitslide). Changes to the 
semi-static latency that occur when the link is established depend mainly on the design of the physical layer 
function (PHY), in particular, the Phase-Locked Loop and the Clock Data Recovery (PLL/CRD). An 
implementation of the High Accuracy Delay Request-Response Default PTP Profile, according to the 
example provided in this annex, requires that the recovered L1 rx clock is either automatically aligned with 
the border of the serial symbol, or the misalignment is evaluated and remains constant as long as the link is 
active. 
In the example implementation, which uses Gigabit Ethernet, the semi-static latency is the phase offset 
between the ”edge” of the 8b/10b symbol and the edge of the L1 rx clock signal with which the 8 bit 
parallel word is aligned (see Figure M.3). It is measured through a process called “bit-slip, 
 described in Jansweijer and Peek [B37], and remains nearly constant while the link is active.  
111010110000010101101110101100000101
Semi-static latency (bitslide)
8b/10b encoding
Serial bit stream
L1 rx clock signal
 
Figure M.3 Bitslide 
M.4.3 Static ingress and egress latency  
The static latency is described in N.2 as the type of latency that is nearly constant throughout the lifetime of 
a PTP Instance, subject to temperature changes and aging. 
Except for the source of the semi-static latency (see M.4.2) and the dynamic latency (see M.3), the 
networking components used in the example implementation are deterministic and guarantee negligible 
variation of the latencies they introduce.  
The value of the static latency is obtained through the calibration procedures described in Annex N. 
M.5 Medium and its asymmetry 
The medium used by the example implementation on a Direct PTP Link is a single strand of single-mode 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
450 
fiber, that is, 1000BASE-BX10 defined in IEEE Std 802.3. It is used for bidirectional communication by 
transmitting and receiving at different wavelengths. The consequence of using different wavelengths and a 
common medium for the two-way communication is a nearly constant relationship between the delays in 
the two directions. This relationship is defined in 7.4.3 as a medium relative delay coefficient.  
The medium relative delay coefficient is used by the example implementation to calculate and 
automatically compensate the medium asymmetry. This is achieved by calculating the value of the 
<delayAsymmetry> using <delayCoefficient> and <meanDelay> per 16.8, and then using the calculated 
value to correct the <meanDelay> per 7.4.2 in the calculation of the <offsetFromMaster> (see 11.2). 
According to the example implementation, the user calibrates the medium relative delay coefficient using 
the procedures in Annex N for each medium used.  
NOTE—To achieve high synchronization accuracy, it is important that the value of <delayAsymmetry> does not 
change during execution of delay mechanisms of 11.3 and 11.4, which are used to obtain the value of the 
<meanDelay>, that is, <meanPathDelay> and <meanLinkDelay>, respectively. When the delay request-response 
mechanism of 11.3 is used, the value of <delayAsymmetry> is added to the received correctionField of Sync message 
[see item a) of 11.2] and subtracted from the correctionField of Delay_Req before its transmission [see item c)3) of 
11.3.2]. When the peer-to-peer delay mechanism of 11.4 is used, the value of <delayAsymmetry> is added to the 
received correctionField of Pdelay_Resp message [see item d)2) of 11.4.2] and subtracted from the correctionField of 
Pdelay_Req before its transmission [see item a)3) of 11.4.2]. In the case of a Direct PTP Link, proper operation of the 
protocol requires that the added and subtracted value of the <delayAsymmetry> cancels out in the calculation of 
<meanPathDelay> and <meanLinkDelay> in 11.3.2 and 11.4.2, respectively, while the correction for 
<delayAsymmetry> is included in the calculation of the <offsetFromMaster> in 11.2. Any change of the value of 
<delayAsymmetry> during the execution of these mechanisms will introduce an error in the calculation of the 
<meanPathDelay> and <meanLinkDelay>, and so incorrect synchronization per 11.2. Additionally, this error will 
affect calculation of <delayAsymmetry> per 16.8. 
M.6 Timing characteristics  
NOTE 1— The timing characteristics of the example implementation were measured considering the list of the 
characteristics that have been used to specify a synchronous Ethernet Equipment Clock (EEC) defined in  
ITU-T G.8262/Y1362 [B34]. The measurement was not intended to verify compliance with the G.8262 clock. 
Measurements have been done on the L1 clock signal. These measurements provide an indication of the Local PTP 
clock signal performance. 
The measurement results of wander in locked mode with constant temperature are presented in Figure M.4. 
The figure shows Maximum Time Interval Error (MTIE) and Time deviation (TDEV), as defined in  
ITU-T G.810 [B31], measured for the example implementation and the masks defined in  
ITU-T G.8262/Y1362 [B34] for EEC Option 1 (EEC1) and EEC Option 2 (EEC2).  
The L1 syntonization in the example implementation has bandwidth of 30Hz and a maximum phase gain of 
3.3 dB, at 16 Hz. The bandwidth is greater than the requirements of  ITU-T G.8262/Y1362 [B34] for the 
EEC in order to transfer the wander performance of the grandmaster to the Local PTP Clock, which would 
otherwise be influenced by the wander of the local oscillator. The bandwidth is not greater than 30 Hz, to 
take advantage of the local oscillator’s short-term phase stability.  
Other measurements, characteristics, and their detailed descriptions are available in Rizzi et al. [B50].  
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
451 
 
Figure M.4 Wander generation (MTIE and TDEV) for EEC-Option 1 and EEC-Option 2  
with constant temperature 
NOTE 2— The measurement presented in Figure M.4 provides an example of performance (in terms of time error 
stability at constant temperature) that could be met with an implementation based on this Annex. Comparison with the 
G.8262 masks is only for information. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
