# Annex I  (normative) Default PTP Profiles

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
398 
Annex I   
(normative)  
Default PTP Profiles 
I.1 General 
Each default PTP Profile specifies a selection of options and attributes. Each selection specifies a PTP 
Network that works without requiring user configuration. 
I.2 General requirements 
PTP Instance shall implement all requirements in the respective PTP Profile that specify default values or 
choices such that these default values or choices apply without requiring user configuration, that is, as 
delivered from the manufacturer. 
I.3 Delay Request-Response Default PTP Profile  
I.3.1 Identification 
The identification values for this PTP Profile (see 20.3.3) are as follows: 
 
PTP Profile 
 
Default PTP Profile for use with the delay request-response mechanism 
 
profileName: Default delay request-response profile 
 
profileNumber: 1 
 
primaryVersion: 1 
 
revisionNumber: 0 
 
profileIdentifier: 00-1B-19-01-01-00 
This profile is specified by the IEEE Precise Networked Clock Synchronization Working Group of the 
IM/ST Committee. 
A copy can be obtained by ordering IEEE Std 1588-2019 from the IEEE Standards Organization 
https://standards.ieee.org. 
I.3.2 PTP attribute values 
All PTP Instances shall support the ranges and shall have the default initialization values for attributes as 
follows: 
 
defaultDS.domainNumber: The default initialization value shall be 0. 
 
portDS.logAnnounceInterval: The default initialization value shall be 1. The configurable range 
shall be 0 to 4. 
 
portDS.logSyncInterval: The default initialization value shall be 0. The configurable range shall 
be −1 to +1. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
399 
 
portDS.logMinDelayReqInterval: The default initialization value shall be 0. The configurable 
range shall be 0 to 5. 
 
portDS.announceReceiptTimeout: The default initialization value shall be 3. The configurable 
range shall be 2 to 10. 
 
defaultDS.priority1: The default initialization value shall be 128. 
 
defaultDS.priority2: The default initialization value shall be 128.  
 
defaultDS.slaveOnly: If this parameter is configurable, the default initialization value shall be 
FALSE.  
 
τ (see 7.6.3.2): The value shall be 1.0 s. 
 
defaultDS.sdoId:  The default initialization value shall be 00016.  
For each defined range, manufacturers may support wider ranges within the constraints specified in this 
standard, for example, restrictions on domainNumber values in Table 2. 
I.3.3 PTP Options 
All options of Clause 16 and Clause 17 are permitted. By default, these options shall be inactive (disabled) 
unless specifically activated (enabled) by a management mechanism. 
The optional provision of item e) in 9.3.2.5 is permitted. By default, this optional provision shall be 
inactive (disabled) unless specifically specified-by-design or activated (enabled) by a management 
mechanism. 
See 8.1.4.3 for permitted management mechanism options. 
The best master clock algorithm shall be the algorithm specified in 9.3.2. 
The delay request-response mechanism shall be the default path delay measurement mechanism. The peer-
to-peer delay mechanism may also be implemented.  
NOTE—Only a single mechanism is allowed per path, that is, PTP Communication Path or PTP Link. Boundary 
Clocks are typically used between links that use different path delay mechanisms. 
I.3.4 Clock physical requirements  
I.3.4.1 Frequency accuracy 
Every Grandmaster Clock shall maintain a frequency such that the value of the second as measured by the 
Grandmaster Clock deviates no more than 0.01% from the second defined by the grandmaster’s timescale 
(see 7.2.1). 
I.3.4.2 Frequency adjustment range 
Any PTP Instance with a port in the in the SLAVE state shall be able to correct the frequency of its Local 
PTP Clock to match the frequency of any Master Clock meeting the requirements of I.3.4.1. 
NOTE—The frequency adjustment range are typically at least ±0.025%. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
400 
I.4 Peer-to-Peer Default PTP Profile  
I.4.1 Identification 
The identification values for this PTP Profile (see 20.3.3) are as follows: 
 
PTP Profile 
 
Default PTP Profile for use with the peer-to-peer delay mechanism 
 
profileName: Default delay peer-to-peer delay profile 
 
profileNumber: 2 
 
primaryVersion: 1 
 
revisionNumber: 0 
 
profileIdentifier: 00-1B-19-02-01-00 
This profile is specified by the IEEE Precise Networked Clock Synchronization Working Group of the 
IM/ST Committee. 
A copy can be obtained by ordering IEEE Std 1588-2019 from the IEEE Standards Organization 
https://standards.ieee.org. 
I.4.2 PTP attribute values 
All PTP Instances shall support the ranges and shall have the default initialization values for attributes as 
follows: 
 
defaultDS.domainNumber: The default initialization value shall be 0. 
 
portDS.logAnnounceInterval: The default initialization value shall be 1. The configurable range 
shall be 0 to 4. 
 
portDS.logSyncInterval: The default initialization value shall be 0. The configurable range shall 
be −1 to +1. 
 
portDS.logMinPdelayReqInterval: The default initialization value shall be 0. The configurable 
range shall be 0 to 5. 
 
portDS.announceReceiptTimeout: The default initialization value shall be 3. The configurable 
range shall be 2 to 10. 
 
defaultDS.priority1: The default initialization value shall be 128. 
 
defaultDS.priority2: The default initialization value shall be 128.  
 
defaultDS.slaveOnly: If this parameter is configurable the default initialization value shall be 
FALSE.  
 
τ (see 7.6.3.2): The value shall be 1.0 s. 
 
defaultDS.sdoId:  The default initialization value shall be 00016.  
 
transparentClockdefaultDS.primaryDomain: If implemented, its default initialization value 
shall be 0. 
For each defined range, manufacturers may support wider ranges within the constraints specified in this 
standard, for example, restrictions on domainNumber values in Table 2. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
401 
I.4.3 PTP options 
All options of Clause 16 and Clause 17 are permitted. By default, these options shall be inactive (disabled) 
unless specifically activated (enabled) by a management procedure. 
The optional provision of item e) in 9.3.2.5 is permitted. By default, this optional provision shall be 
inactive (disabled) unless specifically specified-by-design or activated (enabled) by a management 
mechanism. 
See 8.1.4.3 for permitted management mechanism options. 
The best master clock algorithm shall be the algorithm specified in 9.3.2. 
The peer-to-peer delay mechanism shall be the default path delay measurement mechanism. The delay 
request-response mechanism may also be implemented.  
NOTE—Only a single mechanism is allowed per path, that is, PTP Communication Path or PTP Link. Boundary 
Clocks are typically used between links that use different path delay mechanisms. 
I.4.4 Clock physical requirements  
I.4.4.1 Frequency accuracy 
Every Grandmaster Clock shall maintain a frequency such that the value of the second as measured by the 
Grandmaster Clock deviates no more than 0.01% from the second defined by the grandmaster’s timescale 
(see 7.2.1).  
I.4.4.2 Frequency adjustment range 
Any PTP Instance with a PTP Port in the SLAVE state shall be able to correct the frequency of its Local 
PTP Clock to match the frequency of any Master Clock meeting the requirements of I.4.4.1. 
NOTE—The frequency adjustment range are typically at least ±0.025%. 
I.5 High-Accuracy Delay Request-Response Default PTP Profile 
I.5.1 Identification  
The identification values for this PTP Profile (see 20.3.3) are as follows: 
 
PTP Profile: Default PTP Profile for use with the hardware that provides High Accuracy support 
 
profileName:  High Accuracy Delay Request-Response Default PTP Profile 
 
profileNumber: 3 
 
primaryVersion: 1 
 
revisionNumber: 0 
 
ProfileIdentifier: 00-1B-19-03-01-00 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
402 
This profile is specified by the IEEE Precise Networked Clock Synchronization Working Group of the 
IM/ST Committee. 
A copy can be obtained by ordering IEEE Std 1588-2019 from the IEEE Standards Organization 
https://standards.ieee.org. 
I.5.2 PTP attribute values 
All PTP Instances shall support the ranges and shall have the default initialization values for attributes and 
configurable data set members specified as follows: 
 
defaultDS.domainNumber: The default initialization value shall be 0. 
 
portDS.logAnnounceInterval: The default initialization value shall be 1. The configurable range 
shall be 0 to 4. 
 
portDS.logSyncInterval: The default initialization value shall be 0. The configurable range shall 
be –1 to +1. 
 
portDS.logMinDelayReqInterval: The default initialization value shall be 0. The configurable 
range shall be 0 to 5. 
 
portDS.announceReceiptTimeout: The default initialization value shall be 3. The configurable 
range shall be 2 to 10. 
 
defaultDS.priority1: The default initialization value shall be 128. 
 
defaultDS.priority2: The default initialization value shall be 128.  
 
defaultDS.slaveOnly: If this parameter is configurable, the default initialization value shall be 
FALSE.  
 
τ (see 7.6.3.2): The value shall be 1.0 s. 
 
defaultDS.sdoId:  The default initialization value shall be 00016.  
 
transparentClockdefaultDS.primaryDomain: If implemented, the default initialization value 
shall be 0. 
 
portDS.logMinPdelayReqInterval: If implemented, the default initialization value shall be 0. The 
configurable range shall be 0 to 5. 
For each defined range, manufacturers may support wider ranges within the constraints specified in this 
standard, for example, restrictions on domainNumber values in Table 2. 
I.5.3 PTP options 
The options required, permitted, or prohibited by this profile are specified as follows: 
a) 
Layer-1 based synchronization performance enhancement, specified in Annex L, shall be 
implemented. This option shall be active (enabled). The data set members required by this option 
shall be implemented. Their default initialization values and allowed values are specified in  
Table I.1. L1SYNC_RESET event (L.7.4.3), specified by this option, shall be instantiated 
whenever a disconnection of the physical port interface is detected.  
b) 
Mechanisms for external configuration of the PTP Instance’s PTP Port states, specified in 17.6, 
shall be implemented. By default, this option shall be inactive (disabled). The default initialization 
value and allowed value of the defaultDS.externalPortConfigurationEnabled required by this option 
are specified in Table I.1. 
c) 
Requirement a) through requirement f) in N.3 shall be fulfilled for Boundary Clocks and Ordinary 
Clocks to enable calibration procedures (see Annex N). As a consequence of requirement b) in N.3:  
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
403 
1) 
Configurable correction of timestamps, specified in 16.7, must be implemented. The data set 
members required by this option must be implemented. 
2) 
Calculation of the <delayAsymmetry> for certain media, specified in 16.8, must be 
implemented and active (enabled). The data set members required by this option must be 
implemented. 
Table I.1 specifies the default initialization values and allowed values of the data set members 
required by the options of 16.7 and 16.8. 
d) 
Isolation option, specified in 16.5, shall not be used. 
e) 
masterOnly mode, specified in 9.2.2.2 and 8.2.15.5.2, shall be implemented. The default 
initialization value and allowed value of the portDS.masterOnly required by this option are 
specified in Table I.1. 
f) 
All remaining options of Clause 16 and Clause 17 are permitted. By default, these options shall be 
inactive (disabled) unless specifically activated (enabled) by a management mechanism. If an 
option from Clause 16 or Clause 17 is implemented, the data set members required by the option 
shall be implemented. 
g) 
The optional provision of item e) of 9.3.2.5 is permitted. By default, this optional provision shall be 
inactive (disabled) unless specifically specified-by-design or activated (enabled) by a management 
mechanism. 
All PTP Instances shall support the ranges and shall have the default initialization values for the attributes 
and configurable data set members of the specified options as specified in Table I.1. Except for the 
defaultDS.sdoId, the members of the data sets specified in Table I.1 shall be implemented. The 
defaultDS.sdoId can be specified-by-design. 
Table I.1 PTP attribute values for options 
Attribute and configurable data set members of the specified optional 
features 
Default 
initialization 
value 
Limits of 
value range 
Layer-1 based synchronization performance enhancement option 
L1SyncBasicPortDS.L1SyncEnabled 
TRUE 
TRUE  
L1SyncBasicPortDS.txCoherencyIsRequired 
TRUE 
TRUE  
L1SyncBasicPortDS.rxCoherencyIsRequired 
TRUE 
 TRUE  
L1SyncBasicPortDS.congruencyIsRequired 
TRUE 
TRUE  
L1SyncBasicPortDS.optParamsEnabled 
FALSE 
 FALSE 
L1SyncBasicPortDS.logL1SyncInterval 
0 
−4 to 4 
L1SyncBasicPortDS.L1SyncReceiptTimeout 
3 
2 to 10 
Mechanism for external configuration of the PTP Instance’s port states 
defaultDS.externalPortConfigurationEnabled 
FALSE 
FALSE, 
TRUE 
Calibration Procedures 
timestampCorrectionPortDS.egressLatency 
Default is zero 
unless specified 
otherwise 
by 
implementation. 
–263 to 263–1 
timestampCorrectionPortDS.ingressLatency 
–263 to 263–1 
asymmetryCorrectionPortDS.constantAsymmetry 
–263 to 263–1 
asymmetryCorrectionPortDS.scaledDelayCoefficient 
–262 to 262 
asymmetryCorrectionPortDS.enable 
TRUE 
TRUE 
(see NOTE) 
 
masterOnly mode 
portDS.masterOnly  
FALSE  
TRUE, 
FALSE  
NOTE—The TRUE value of the asymmetryCorrectionPortDS.enable is required because uncorrected asymmetry can 
substantially degrade synchronization accuracy. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
404 
The master–slave hierarchy shall be determined using the default best master clock algorithm, specified in 
9.3.2, unless the Mechanism for external configuration of the PTP Instance’s PTP Port states as specified in 
17.6 is enabled. 
The delay request-response mechanism shall be the default path delay measurement mechanism. The peer-
to-peer delay mechanism may also be implemented. 
NOTE 1— Only a single mechanism is allowed per path, that is, PTP Communication Path or PTP Link. Boundary 
Clocks are typically used between links that use different path delay mechanisms. 
See 8.1.4.3 for permitted management mechanism options. 
NOTE 2— The accuracy of synchronization achieved by a PTP Instance supporting this High Accuracy Default PTP 
Profile depends on the PTP Instance’s implementation. The PTP options and attribute values specified by this PTP 
Profile provide protocol support that allows for an implementation to achieve enhanced synchronization characteristics. 
An example implementation of the High Accuracy Default PTP Profile that, over a properly designed network, can 
achieve sub-nanosecond accuracy of synchronization, is described in Annex M. 
I.5.4 Interoperation with other Default PTP Profiles 
By specifying defaultDS.sdoId to be 00016, and consequently the values of majorSdoId and minorSdoId to 
be zero, the High Accuracy Delay Request-Response Default PTP Profile does not use Profile Isolation 
(see 16.5). The High Accuracy Delay Request-Response Default PTP Profile is intended to interoperate 
with the Delay Request-Response Default PTP Profile (see I.3). If the optionally permitted peer-to-peer 
delay mechanism is implemented, the High Accuracy Delay Request-Response Default PTP Profile can 
inter-operate with Peer-to-Peer Default PTP Profile (see I.4). Transparent Clocks without support for High 
Accuracy optional features should not be placed between PTP Instances implementing the High Accuracy 
Delay Request Response Default PTP Profile. 
NOTE 1— In this context, interoperation between a PTP Instance A implementing the High Accuracy Delay Request-
Response Default PTP Profile and a PTP Instance B implementing the Delay Request-Response Default PTP Profile 
(or the Peer-to-Peer Default PTP Profile) means that: 
 
The PTP Instance B can synchronize with the PTP Instance A as if the PTP Instance B were synchronizing 
with another PTP Instance C implementing the Delay Request-Response Default PTP Profile (or the Peer-to-
Peer Default PTP Profile). 
 
The PTP Instance A can synchronize with the PTP Instance B as if the PTP Instance A were implementing the 
Delay Request-Response Default PTP Profile (or the Peer-to-Peer Default PTP Profile), provided the timing 
characteristics of the PTP Instance B meet the requirements of I.5.6. 
In both cases, the PTP options specified by the High Accuracy Delay Request-Response Default PTP Profile do not 
enhance accuracy on the PTP Communication Path or on a PTP Link between the PTP Instances A and B; however, the 
protocol operates normally (that is, it is not a faulty situation). 
NOTE 2— As an example, such interoperation might be used to connect PTP Instances that do not require enhanced 
accuracy of synchronization and implement the Delay Request-Response Default PTP Profile (or the Peer-to-Peer 
Default PTP Profile) to an already existing PTP Network in which all the PTP Instances implement the High Accuracy 
Delay Request-Response Default PTP Profile. In this example scenario, the portion of the PTP Network implementing 
the High Accuracy Delay Request-Response Default PTP Profile contains the Grandmaster PTP Instance. This portion 
provides enhanced accuracy of synchronization to the connected end applications. If an application exists that does not 
need the enhanced accuracy of synchronization, such an application can be connected to this portion of the PTP 
Network using the Delay Request-Response Default PTP Profile. 
I.5.5 Adjusting the clocks in the clock block of the layered model 
This PTP Profile assumes that Boundary Clocks and Ordinary Clocks follow the model in Figure I.1, for 
the Local PTP Clock in the layered models depicted in Figure 5 and Figure 6 of 6.5.2.1.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
405 
Phase:time control
Master time
Local PTP time
Clock signal 
physically syntonized to Master Clock’s 
timescale (e.g. L1 rx clock signal)
Local PTP 
Clock
Local PTP Clock physically syntonized 
to the Master Clock and 
synchronized via PTP
 
Figure I.1 High Accuracy model of Local PTP Clock 
With the model in Figure I.1, the Local PTP Clock is physically syntonized and synchronized to the 
Grandmaster Clock in the domain, and the Local Clock is identical to the Local PTP Clock. The 
Timestamping Clock is the Local PTP Clock. The information about the phase of the syntonized physical 
clock signal can be used to enhance the accuracy and precision of synchronization, for example, through 
phase offset detection.  
Syntonization in this model is performed independent from the PTP timing message exchange. The Local 
PTP Clock is fed with a clock signal that is physically syntonized to the Grandmaster Clock’s timescale as 
permitted by 12.2.3 (e.g., L1 rx clock signal). 
NOTE 1— It is assumed that the physical clock signal provides more accurate syntonization than that based on 
observing PTP timing messages. 
Synchronization in this model is performed using PTP timing messages. The time of the Local PTP Clock 
is compared to that of the Master Clock and corrected for any path delay. The “Phase:time control” block 
adjusts the time and phase of Local PTP Clock appropriately, which introduces a phase offset between the 
Local PTP Clock signal and the clock signal that is physically syntonized to the Grandmaster Clock. 
NOTE 2— The time and phase adjustment can be done by adjusting the time counter and/or temporarily changing the 
frequency of the Local PTP Clock. 
The key aspect of the scheme illustrated by the high accuracy model is that the physical clock signal and 
the time of the PTP Instance are coherent. If physical clock signals of such peer PTP Instances are available 
to each of the PTP Instances, implementation-specific (e.g., phase offset detection) techniques can be used 
to enhance precision of timestamps and improve overall synchronization performance (see Annex M). 
NOTE 3— In the described model, the Local Clock and the Local PTP Clock are identical (see 3.1.26). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
406 
I.5.6 Clock physical requirements  
I.5.6.1 Frequency accuracy 
Every Grandmaster Clock shall maintain a frequency such that the value of the second as measured by the 
Grandmaster Clock deviates no more than 4.6 ppm from the second defined by the grandmaster’s timescale 
(see 7.2.1).  
I.5.6.2 Frequency adjustment range 
Any PTP Instance with a PTP Port in the SLAVE state shall be able to correct the frequency of its Local 
PTP Clock to match the frequency of any Master Clock meeting the requirements of I.5.6.1. 
NOTE—The frequency adjustment range needs to be  be at least ±4.6 ppm. 
 
 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
