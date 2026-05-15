# Annex J (normative) Performance monitoring options (optional)

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
407 
Annex J  
(normative)  
Performance monitoring options (optional) 
J.1 General 
When this option is implemented (see 6.1), by being specified in the applicable PTP Profile or by the 
manufacturer, then the option shall operate as specified in this annex. 
For some applications, it is important to monitor the performance of the network and of the network 
elements. 
This annex specifies data for performing performance monitoring in a PTP Network. The collection of this 
data might be based on a timescale other than the timescale in use in the PTP domain. The option can be 
enabled in a PTP Instance by setting the PTP Instance’s value of performanceMonitoringDS.enable to 
TRUE and disabled by setting the value to FALSE. 
Accurate performance monitoring would, in general, require the support of an external reference (e.g., 
GPS); however, PTP Instances may provide some useful information. In particular, in addition to the 
default parameters used by PTP (<meanPathDelay>, <offsetFromMaster>, etc.) the monitoring of the four 
PTP Timestamps (t1, t2, t3, and t4) might also be useful, for example, for the following use cases: 
 
Indication of network performance. This is applicable mainly in case PTP messages are carried 
over network elements that are not able to process the PTP packets, for example, legacy routers to 
deliver frequency synchronization (see ITU-T G.8265 [B35]). As an example, in this case, 
monitoring how t1, t2, t3, and t4 change over time, as a relative difference, can provide information 
on the noise and packet delay variation present in the network. 
 
Indication of Local PTP Clock operation. As an example, by monitoring how t1, t2, t3 and t4 
change over time, can provide information on abnormal Local PTP Clock/network conditions or 
clock stabilization time. 
Specific PTP Profiles may define additional parameters more suitable to their specific application.  
J.2 Timestamp monitoring 
For the purpose of monitoring how the PTP timestamps change over time, Table J.1 provides a list of 
statistics counters and objects related to the PTP Port in the SLAVE state. The related definitions are 
provided after Table J.1. 
The parameters are members of the data records in the performanceMonitoringDS (a per PTP Instance data 
set). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
408 
Table J.1 PTP Instance Performance Monitoring parameters  
Parameter Name 
Definition 
Data type 
Applicability 
averageMasterSlaveDelay 
Average of the MasterSlaveDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
minMasterSlaveDelay 
Minimum of the MasterSlaveDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
maxMasterSlaveDelay 
Maximum of the MasterSlaveDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
stdDevMasterSlaveDelay 
StdDev of the MasterSlaveDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
averageSlaveMasterDelay 
Average  of the SlaveMasterDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
minSlaveMasterDelay 
Minimum of the SlaveMasterDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
maxSlaveMasterDelay 
Maximum of the SlaveMasterDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
stdDevSlaveMasterDelay 
StdDev of the SlaveMasterDelay for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
averageMeanPathDelay 
Average of the <meanPathDelay> for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
minMeanPathDelay 
Minimum of the <meanPathDelay> for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
maxMeanPathDelay 
Maximum of the <meanPathDelay> for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
stdDevMeanPathDelay  
StdDev of the <meanPathDelay> for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end delay 
mechanism 
averageOffsetFromMaster 
(See Note 1) 
Average of the <offsetFromMaster> for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
minOffsetFromMaster 
(See Note 1) 
Minimum of the <offsetFromMaster> for each 15 
min and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
maxOffsetFromMaster 
(See Note 1) 
Maximum of the <offsetFromMaster> for each 15 
min and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
stdDevOffsetFromMaster 
(See Note 1) 
StdDev of the <offsetFromMaster> for each 15 min 
and 24 h interval. 
TimeInterval 
End-to-end 
and 
peer-to-peer delay 
mechanism 
NOTE 1— When the main usage of the statistics is to be compared against a threshold level crossing alarm, it might be 
more convenient to display an absolute value, for example, the observed abs(average Offset From Master), instead of 
the related signed value. This is implementation specific. 
The statistics shall be performed as follows: 
The <offsetFromMaster> values shall be computed as described in 11.2. The <meanPathDelay> values shall 
be computed as described in 11.3.1. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
409 
The value of MasterSlaveDelay is calculated as follows: 
a) 
Upon receipt of a Sync message, the Slave PTP Instance generates a timestamp 
<syncEventIngressTimestamp> corrected for latency per 7.3.4. The corrections shall be made per 
11.3 for the delay request-response mechanism and per 11.4 for the peer-to-peer mechanism. 
b) 
If the twoStepFlag bit of the flagField of the Sync message, is FALSE, indicating that a Follow_Up 
message will not be received, then  
MasterSlaveDelay = <syncEventIngressTimestamp> ─ <originTimestamp>  
─ correctionField of Sync message. 
c) 
If the twoStepFlag bit of the flagField of the of the Sync message is TRUE, indicating that a 
Follow_Up message will be received, then  
MasterSlaveDelay = <syncEventIngressTimestamp> ─ <preciseOriginTimestamp>  
─ correctionField of Sync message ─ correctionField of Follow_Up message. 
where 
1) 
The <originTimestamp> is the value of the originTimestamp field in the received Sync 
message. 
2) 
The <preciseOriginTimestamp> is the value of the preciseOriginTimestamp field in the 
received Follow_Up message. 
The value of SlaveMasterDelay is calculated as follows: 
d) 
Generate 
and 
save 
timestamp 
t3 
as 
related 
to 
the 
Delay_Req 
message 
(<delayReqEventEgressTimestamp>). 
e) 
 Upon receipt of the Delay_Resp message by the Slave PTP Instance, SlaveMasterDelay shall be 
computed as: 
SlaveMasterDelay = (receiveTimestamp of Delay_Resp message–correctionField of 
Delay_Resp message – t3 
NOTE 2— The StdDev is defined in Papoulis [B43], in particular (see 7.6.3), which provides the variance (the StdDev 
is the square root of variance). 
The measurementValid flag (see J.4.1), shall indicate the data can be correctly interpreted. Validity is 
implementation specific and may be defined in a PTP Profile (e.g., the data have been collected when the 
Local PTP Clock is synchronized to a time source, either the PTP Local Clock of the Parent PTP Instance 
or an accurate external reference). 
If for some periods the data are not valid for part of the data collection interval (e.g., the clock is not 
locked), a specific implementation can report the statistics only for valid data and with measurementValid 
flag set to TRUE. This might be useful for the 24-hour statistics. Reporting of statistics based on data 
collected when the data are not valid (e.g., the clock is not locked) may be reported with the 
measurementValid flag set to FALSE. 
The periodComplete flag (see J.4.1), shall indicate that measurements were performed during the entire 
period (15 min or 24 h). For example, if the PTP Instance is disabled for  5 min of a 15 min period, 
periodComplete is FALSE. The periodComplete flag is not related to the validity of measurements that 
were performed. 
The measurementValid and periodComplete flags apply to all parameters for a given measurement period, 
including PTP Port related. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
410 
The full set of parameters specified in Table J.1 should be provided; however, specific applications or 
implementations may implement only a subset of these parameters. As an example, for some applications, 
the statistic based on <meanPathDelay> and <offsetFromMaster> can be sufficient. 
In the case of a peer-to-peer delay mechanism, an implementation may collect the <meanLinkDelay> 
related statistics for all PTP Ports where the related measurement is active (see Table J.2).  
These parameters are defined as members of the performanceMonitoringPortDS, that is, a per PTP Port 
data set (see J.5.2). 
Table J.2 PTP Port Monitoring parameters when using the peer-to-peer delay mechanism 
Parameter Name 
Definition 
Data type 
Applicability 
averageMeanLinkDelay 
Average of the <meanLinkDelay> for each 15 min and  
24 h interval. 
TimeInterval 
Per PTP Port 
if applicable  
minMeanLinkDelay 
Minimum of the <meanLinkDelay> for each 15 min and  
24 h interval. 
TimeInterval 
Per PTP Port 
if applicable  
maxMeanLinkDelay 
Maximum of the <meanLinkDelay> for each 15 min and 
24 h interval. 
TimeInterval 
Per PTP Port 
if applicable  
stdDevMeanLinkDelay 
StdDev of the <meanLinkDelay> for each 15 min and 24 h 
interval. 
TimeInterval 
Per PTP Port 
if applicable  
J.3 Additional parameters 
The additional parameters/events in Table J.3 may be provided as a complement to those listed in  
Table J.1. The additional parameters can be useful for monitoring the performance of the network and PTP 
Instances, as applicable to a PTP Port, depending on its state. 
These parameters are members of the performanceMonitoringPortDS (a per PTP Port data set). 
The list is applicable to multicast communication. The applicability of these counters to unicast 
communication is out of scope. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
411 
Table J.3 Additional parameters 
Parameter name 
Definition 
Data type 
Applicability 
 announceTx 
Counter indicating the number of Announce 
messages that have been transmitted for each  
15 min and 24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end and peer-
to-peer delay 
mechanism 
 announceRx 
Counter indicating the number of Announce 
messages from the current GM that have been 
received for each 15 min and 24 h interval. 
 
UInteger32 
Per PTP Port End-to-
end and peer-to-peer 
delay mechanism 
 
announceForeignMasterRx 
Counter 
indicating 
the 
total 
number 
of 
Announce messages from the foreign Masters 
that have been received for each 15 min and 24 
h interval. 
UInteger32 
Per PTP Port 
End-to-end and peer-
to-peer delay 
mechanism 
 syncTx 
Counter indicating the number of Sync messages 
that have been transmitted for each 15 min and  
24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end and peer-
to-peer delay 
mechanism 
 syncRx 
Counter indicating the number of Sync messages 
that have been received for each 15 min and 24 
h interval. 
 
UInteger32 
Per PTP Port 
End-to-end and peer-
to-peer delay 
mechanism 
 followUpTx 
Counter indicating the number of Follow_Up 
messages that have been transmitted for each  
15 min and 24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end and peer-
to-peer delay 
mechanism 
 followUpRx 
Counter indicating the number of Follow_Up 
messages that have been received for each 15 
min and 24 h intervall. 
 
UInteger32 
Per PTP Port 
End-to-end and peer-
to-peer delay 
mechanism 
 delayReqTx 
Counter indicating the number of Delay_Req 
messages that have been transmitted for each  
15 min and 24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end delay 
mechanism 
 delayReqRx 
Counter indicating the number of Delay_Req 
messages that have been received for each 15 
min and 24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end delay 
mechanism 
delayRespTx 
Counter indicating the number of Delay_Resp 
messages that have been transmitted for each  
15 min and 24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end delay 
mechanism 
 delayRespRx 
Counter indicating the number of Delay_Resp 
messages that have been received for each 15 
min and 24 h interval. 
 
UInteger32 
Per PTP Port 
End-to-end delay 
mechanism 
 pDelayReqTx 
Counter indicating the number of Pdelay_Req 
messages that have been transmitted for each  
15 min and 24 h interval. 
 
UInteger32 
Per PTP Port 
peer-to-peer delay 
mechanism 
 pDelayReqRx 
Counter indicating the number of Pdelay_Req 
messages that have been received for each 15 
min and 24 h interval. 
 
UInteger32 
Per PTP Port 
peer-to-peer delay 
mechanism 
 pDelayRespTx 
Counter indicating the number of  Pdelay_Resp 
messages that have been transmitted for each  
15 min and 24 h intervall. 
 
UInteger32 
Per PTP Port 
peer-to-peer delay 
mechanism 
 pDelayRespRx 
Counter indicating the number of Pdelay_Resp  
messages that have been received for each 15 
min and 24 h interval. 
 
UInteger32 
Per PTP Port 
peer-to-peer delay 
mechanism 
 pDelayRespFollowUpTx 
Counter indicating the number of  
Pdelay_Resp_Follow_Up messages that have 
been transmitted for each 15 min and 24 h 
interval. 
 
UInteger32 
Per PTP Port 
peer-to-peer delay 
mechanism 
 pDelayRespFollowUpRx 
Counter indicating the number of  
Pdelay_Resp_Follow_Up messages that have 
been received for each 15 min and 24 h interval. 
 
UInteger32 
Per PTP Port 
peer-to-peer delay 
mechanism 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
412 
NOTE 1— Where applicable, this information can be compared by the centralized management entity with the expected 
related message rate. 
NOTE 2— These values are counted from the PTP layer point of view. 
NOTE 3— A subset of these parameters might be relevant for a specific application or PTP Profile. 
J.4 Record data types 
The data are captured and stored as the history of Performance Monitoring data, as a list of records, each 
record using a data type defined in J.4.1. The data collection periodicity is a single record every 15 min and 
a single record every 24 h (see Figure J.1). 
1
0
PMTime
Data buffers
Start of current 24h
Start of current 15 minutes
<< 15m >> statistics over last 24h
98
97
96
15m
24h
24h
24h
t0
PMTime: 
start of the 15 minute/24 hour periods
Data used for the statistics stored in the buffer
Data used for the current 24 hour value
Data used for the current 15 minutes value
t0
Indication of current time when accessing the PM Data
...
...
...
 
Figure J.1 —Performance monitoring data collection 
NOTE—For further details on items such as the start and alignment of the measurement periods, applicable timescale, 
epoch, stability of the real-time clock  refer to the applicable performance measurement specification  
(e.g., ITU-T G.7710 [B32]). These items should be consistent over the network that is being managed. 
The data types defined in J.4.1 for the Performance Monitoring data sets include a member called 
“PMTime.” This member shall indicate the time of the beginning of the measurement bin stored in the data 
sets; that is, it must be aligned to the starting times of the measurement periods being utilized for 
monitoring. Each management mechanism (e.g., SNMP [B27] and NETCONF [B20]) specifies a data 
modeling language. Each data modeling language can utilize a different data type for storing the time of the 
monitoring information. To accommodate this, the data type for PMTime is simply referred to as 
“PMTimestamp.”  
The complete set of the measurement periods should be made available; however, specific applications or 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
413 
implementations may implement only a subset of the measurement periods. The following list provides 
examples of implementing a subset of measurement periods: 
 
For the 15 min measurements periods, provide the first two records only (i.e., current and most 
recent). 
 
Provide the two 24 h measurements (i.e., current and most recent), without any 15 min 
measurements. 
 
Provide a 15 min measurement once every hour, by returning only indices 0, 4, 8, 12, and so on. 
J.4.1 Data Types for Performance Monitoring  
The ClockPerformanceMonitoringDataRecord type is used for PTP Instance performance monitoring 
statistics (see Table J.1).  
Struct ClockPerformanceMonitoringDataRecord 
{ 
UInteger16 index; 
 Boolean measurementValid;   
Boolean periodComplete; 
 PMTimestamp PMTime; 
 TimeInterval <parameter 1>; 
 .. 
 TimeInterval <parameter 16>; 
}; 
The PortPerformanceMonitoringPeerDelayDataRecord type is used for the PTP Port related performance 
monitoring statistics for the peer-to-peer delay measurement mechanism (see Table J.2).  
Struct PortPerformanceMonitoringPeerDelayDataRecord 
{ 
UInteger16 index; 
 PMTimestamp PMTime; 
 TimeInterval <parameter 1>; 
 .. 
 TimeInterval <parameter 4>; 
}; 
The PortPerformanceMonitoringDataRecord is used for the PTP Port related performance monitoring 
statistics (see Table J.3).  
Struct PortPerformanceMonitoringDataRecord 
{ 
 UInteger16 index; 
PMTimestamp PMTime; 
 UInteger32 <parameter 1>; 
 .. 
 UInteger32 <parameter 17>  
}; 
where PMTimestamp is as defined in J.4.  
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
414 
J.5 Data sets for performance monitoring 
The following performance monitoring data sets are defined and may be maintained for Ordinary Clocks 
and Boundary Clocks: 
 
performanceMonitoringDS 
 
performanceMonitoringPortDS 
With respect to management, support for these data sets is conditional on the implementation of the 
optional performance monitoring option of this annex. 
 
Since the performance monitoring option is associated with use of management to read the records, and 
each parameter is optional, the operational conformance of each data set member is “management”  
(see 8.1.6). Support of performanceMonitoringDS.enable is required if any other member of the 
performance monitoring data sets is supported. 
J.5.1 performanceMonitoringDS data set member specifications 
The performanceMonitoringDS data set provides features for this annex as a whole, as well as records 
using the data type ClockPerformanceMonitoringDataRecord as specified in J.4.1 (see Table J.1).  
J.5.1.1 performanceMonitoringDS.enable 
The member performanceMonitoringDS.enable permits management control over the collection of 
performance monitoring data for a PTP Instance, including performanceMonitoringDS and 
performanceMonitoringPortDS. The data type shall be Boolean. The specification initialization value  
(see 8.1.3.4) shall be FALSE. 
J.5.1.2 performanceMonitoringDS.recordList 
The recordList provides the list of performance monitoring records for the PTP Instance, recorded at 15 
min and 24 h periods. 
The data type shall be a list (array) of 99 records, with each record using the data type 
ClockPerformanceMonitoringDataRecord as specified in J.4.1. 
The recordList member is organized as follows: 
 
Ninety-seven 15 min measurement records, the current record at index 0, followed by the most 
recent 96 records 
 
Two 24 h measurement records, the current record at index 97, and the previous record at index 98 
Each record contains an associated measurementValid flag, and the PMTime related to when data have 
been collected (i.e., start of the 15 min or 24 h period). 
Since the measurementValid flag applies to all parameters of a given measurement period (see J.2), 
measurementValid in a record of performanceMonitoringDS.recordList shall apply to the corresponding 
record 
in 
performanceMonitoringPortDS.recordList 
and 
performanceMonitoringPortDS.recordList 
PeerDelay. For example, if performanceMonitoring.recordList[5].measurementValid is FALSE, 
performanceMonitoringPortDS.recordList[5] and performanceMonitoringPortDS.recordListPeerDelay[5] 
are not valid records. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
415 
Since the periodComplete flag applies to all parameters of a given measurement period (see J.2), 
periodComplete in a record of performanceMonitoringDS.recordList shall apply to the corresponding 
record 
in 
performanceMonitoringPortDS.recordList 
and 
performanceMonitoringPortDS.record 
ListPeerDelay. 
NOTE 1— As mentioned in J.4, it is recommended that the measurement practices of a specific application be 
followed. This concerns aspects such as management timescale, alignment of the measurement intervals, and so on. 
NOTE 2— The current 15 min record and the current 24 h record contain statistics that are not based on a complete 
measurement of data for the respective period. Therefore, the periodComplete flag is FALSE for the current records. 
If a record is not implemented for a specific index, management does not return the record. For example, if 
only four 15-minute periods are implemented, a management request for performanceMonitoring. 
recordList[6] returns an error. If a specific parameter is not implemented, management does not return the 
parameter. For example, if maxMasterSlaveDelay is not implemented, a management request for 
performanceMonitoring.recordList[0].maxMasterSlaveDelay  returns an error. 
Parameters defined in Table J.1 that are invalid (not measured correctly) shall be indicated with one in all 
bits, except the most significant. This represents the largest positive value of the TimeInterval data type, 
indicating a value outside the maximum range. For example, if the value of averageMasterSlaveDelay is 
not valid, the value of <parameter 1> would be all ones. 
Data stored in recordList are shown with an example in Figure J.2. 
...
Index points at the specific instance of the clockPerformanceMonitoringDataRecord
15 min or 24 h; current or historical. Per port buffer.  
Current value
Historical values
0
96
97
98
15 min
24 h
Index
 
Figure J.2 —clockPerformanceMonitoringDataRecord buffers 
If only some of the data are reported, the same index values are used, As an example, if only the 24 h 
statistics are accessed, the indexes are still 97 and 98. 
NOTE 3— In the case of a chain of Boundary Clocks, although a PTP Instance at the end of the chain indicates a 
measurementValid= TRUE, the actual time recovered might take some time to be fully aligned with the time delivered 
by the Grandmaster Clock. This transitory period depends on the length of the chain and on the clock bandwidth of the 
Phase Locked Loop (PLL) implemented in the Boundary Clocks. 
The classification is dynamic. 
The following initialization values are specified for all records in the list: 
 
clockPerformanceMonitoringDataRecord. measurementValid: False. 
 
clockPerformanceMonitoringDataRecord. PMTime: zero. 
 
clockPerformanceMonitoringDataRecord.<parameter x>: one in all bits, except the most 
significant. Note that this represents the largest positive value of the data type indicating that it is a 
value outside the maximum range. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
416 
J.5.2 performanceMonitoringPortDS data set member specifications 
The 
performanceMonitoringPortDS 
data 
set 
provides 
records 
using 
the 
data 
type 
PortPerformanceMonitoringPeerDelayDataRecord as specified in J.4.1 and records using the data type 
PortPerformanceMonitoringDataRecord as specified in J.4.1. See Table J.2 and Table J.3 for the referenced 
records. 
J.5.2.1 performanceMonitoringPortDS.recordListPeerDelay 
The recordListPeerDelay provides the list of performance monitoring records for a PTP Port that is using 
the peer-to-peer (P2P) delay mechanism, recorded at 15-minute and 24-hour periods. 
The data type shall be a list (array) of 99 records, with each record using the data type 
PortPerformanceMonitoringPeerDelayDataRecord as specified in J.4.1. 
The recordListPeerDelay member is organized as follows: 
 
97 15-minute measurement records, the current record at index 0, followed by the most recent 96 
records 
 
2 24-hour measurement records, the current record at index 97, and the previous record at index 98 
Each record contains the PMTime related to when data has been collected (i.e., start of the 15 minute or 24 
hour period). 
The measurementValid flag of each record in performanceMonitoringDS.recordlist applies to the 
corresponding record of this list (see J.5.1.2). 
The periodComplete flag of each record in performanceMonitoringDS.recordlist applies to the 
corresponding record of this list (see J.5.1.2). 
NOTE—Information on PortIdentity is not directly included in the data structure as the information on which PTP Port 
the data relates to is implicitly defined in the data information model (i.e., the information is structured per PTP Port). 
If a record is not implemented for a specific index, management does not return the record. For example, if 
only four 15 min periods are implemented, a management request for performanceMonitoring 
PortDS.recordListPeerDelay[6] returns an error. If a specific parameter is not implemented, management 
does not return the parameter. For example, if averageMeanLinkDelay is not implemented, a management 
request for performanceMonitoringPortDS.recordListPeerDelay[0].averageMeanLinkDelay returns an 
error. 
Parameters defined in Table J.2 that are invalid (not measured correctly) shall be indicated with one in all 
bits, except the most significant. This represents the largest positive value of the TimeInterval data type, 
indicating a value outside the maximum range. For example, if the value of averageMeanLinkDelay is not 
valid, the value of <parameter 1> would be all ones. 
For each relevant PTP Port, data stored in recordListPeerDelay are shown with an example in Figure J.3. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
417 
...
Index points at the specific instance of the portPerformanceMonitoringPeerDelayDataRecord
15 min or 24 h; current or historical. Per port buffer.  
Current value
Historical values
0
96
97
98
15 min
24 h
Index
 
Figure J.3 —portPerformanceMonitoringPeerDelayDataRecord buffers 
The classification of this member is dynamic. 
The following initialization values are specified for all records in the list: 
 
PortPerformanceMonitoringPeerDelayDataRecord.PMTime: zero 
 
PortPerformanceMonitoringPeerDelayDataRecord.<parameter x>: one in all bits, except the most 
significant.  
J.5.2.2 performanceMonitoringPortDS.recordList 
The recordList provides the list of performance monitoring records for the PTP Port, recorded at 15 min 
and 24 h periods. 
The data type shall be a list (array) of 99 records, with each record using the data type 
PortPerformanceMonitoringDataRecord as specified in J.4.1. 
The recordList member is organized as follows: 
 
Ninety-seven 15 min measurement records, the current record at index 0, followed by the most 
recent 96 records 
 
Two 24 h measurement records, the current record at index 97, and the previous record at index 98 
Each record contains the PMTime related to when data has been collected (i.e., start of the 15 min or 24 h 
period). 
The measurementValid flag of each record in performanceMonitoringDS.recordlist applies to the 
corresponding record of this list (see J.5.1.2). 
The periodComplete flag of each record in performanceMonitoringDS.recordlist applies to the 
corresponding record of this list (see J.5.1.2). 
NOTE—Information on portIdentity is not directly included in the data structure as the information on which PTP Port 
the data relates to is implicitly defined in the data information model (i.e., the information is structured per PTP Port). 
If a record is not implemented for a specific index, management does not return the record. For example, if 
only four 15 min periods are implemented, a management request for performanceMonitoringPortDS. 
recordList[6] returns an error. If a specific parameter is not implemented, management does not return the 
parameter. For example, if announceTx is not implemented, a management request for performance 
MonitoringPortDS.recordList[0].announceTx returns an error. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
418 
Parameters defined in Table J.3 that are invalid (not measured correctly) shall be indicated with the value 
zero, indicating that nothing was counted. 
For each relevant PTP Port, data stored in recordList are shown with an example in Figure J.4. 
...
Index points at the specific instance of the portPerformanceMonitoringDataRecord
15 min or 24 h; current or historical. Per port buffer.  
Current value
Historical values
0
96
97
98
15 min
24 h
Index
 
Figure J.4 —portPerformanceMonitoringDataRecord buffers 
The classification of this member is dynamic (see 8.1.2.1.2). 
The following initialization values are specified for all records in the list: 
 
PortPerformanceMonitoringDataRecord.PMTime: zero 
 
PortPerformanceMonitoringDataRecord.<parameter x>: zero 
Rollover of the counters listed in Table J.3 is not typical due to the limited measurement period. 
The counter value shall be initialized to zero at the start of new 15 min and 24 h intervals. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
