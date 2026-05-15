# Annex B (informative) Timescales and epochs in PTP

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
375 
Annex B  
(informative)  
Timescales and epochs in PTP 
B.1 General considerations 
A more detailed discussion of many of the topics in this annex can be found in Allan et al. [B1], Allan et al. 
[B2], IETF RFC 5905 (2010) [B19], ISO 8601:2004 [B29], the USNO Time Service Department website,23 
and Sullivan et al. [B52]. 
Within a domain, the characteristics of the time are determined by the Grandmaster PTP Instance of the 
domain. The Grandmaster Clock determines: 
a) 
The rate at which time advances. The frequency accuracy of the Grandmaster Clock is measured by 
how well a time interval determined between any two events, as measured using the Grandmaster 
Clock, corresponds to the same interval measured using a PTP Instance, consistent with the 
internationally defined second or the time unit in use for the ARB timescale. The internationally 
defined SI second is the measure of time defining the TAI timescale maintained by the Bureau 
International des Poids et Mesures near Paris. 
b) 
The origin, or epoch, of the timescale. 
The possible timescales and epochs available for use by the Grandmaster PTP Instance are as follows: 
 
timescale PTP: Indicated by a timePropertiesDS.ptpTimescale value of TRUE. The epoch is the 
PTP epoch.  
 
timescale ARB: Indicated by a timePropertiesDS.ptpTimescale value of FALSE. The epoch is 
specific to the implementation. 
B.2 UTC, TAI and the PTP epoch and timescale updates 
B.2.1 General properties of UTC, TAI, and the PTP epoch 
See NIST SP 330:2008 [B42], with the further amplification of Proceedings of the 21st General Assembly 
of the IAU [B48], for the definition of TAI, and Petit and Luzum [B47] for more information on TAI. 
TAI and UTC are international standards for time based on the SI second (see NIST SP 330:2008 [B42], 
Proceedings of the 21st General Assembly of the IAU [B48], and Petit and Luzum [B47]). The SI second is 
the duration of 9 192 631 770 periods of the radiation corresponding to the transition between the two 
hyperfine levels of the ground state of the cesium 133 atom (see NIST SP 330:2008 [B42], Proceedings of 
the 21st General Assembly of the IAU [B48], and Petit and Luzum [B47] for more details on UTC, TAI, and 
the SI second). TAI stability is established from a weighted average of clocks in timing laboratories 
throughout the world. The rate is steered to laboratory frequency standards that best realize this definition, 
adjusted to the rate on Earth's geoid. UTC = TAI − <dLS> (see 7.2.4). The difference between TAI and 
UTC is defined in IERS Bulletin C. The history of this difference is maintained by the United States Naval 
Observatory [B54]. 
                                                 
23 USNO Time Service Department.(http://tycho.usno.navy.mil/). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
376 
UTC is the basis for civil time. The UTC printed representation is specified by ISO 8601:2004 [B29] as 
YYYY-MM-DD for the date and hh:mm:ss for the time in each day. The rate at which UTC time advances 
is identical to the rate at which TAI time advances. The UTC time differs from the TAI time by a constant 
offset. This offset is modified on occasion by adding or subtracting leap seconds. 
Starting on 0 h on 1 January 1972 UTC [Modified Julian Day (MJD) 41 317.0], the world’s standard time 
systems began the implementation of leap seconds to allow only integral second correction between UTC 
and TAI, both of which are expressed in years, months, days, hours, minutes, and seconds. On this date,  
TAI − UTC was 10 s. Prior to 1 January 1972, corrections to the offset between UTC and TAI were made 
in fractions of a second; in addition, the duration of the UTC second was not exactly equal to the duration 
of the TAI second and was different during different periods (see IERS [B49]). 
Leap-second corrections, which are applied to UTC but not to TAI, are made preferably following second 
23:59:59 of the last day of June or December. The first such correction, a single, positive leap-second 
correction, was made following 23:59:59 on 30 June 1972 UTC, and UTC was 11 s behind TAI following 
that instant. 
NOTE—As of 0 h on 1 January 2017 UTC, TAI − UTC = +37 s. 
In computer networks, the common Portable Operating System Interface (POSIX)-based time conversion 
algorithms are typically used to produce the correct ISO 8601:2004 [B29] printed representations for both 
TAI and UTC.  
The PTP epoch is set such that a direct application of the POSIX algorithm to a timestamp in the timescale 
PTP converts this PTP timestamp to the ISO 8601:2004 [B29] printed representation of TAI. PTP also 
distributes the current offset between TAI and UTC, that is, <dLS>, in the currentUtcOffset field of 
Announce messages. Except during leap seconds, subtracting <dLS> from a PTP timestamp and then 
applying the POSIX algorithm results in the ISO 8601:2004 printed representation of UTC. Conversely, 
except during leap seconds, applying the inverse POSIX algorithm and adding <dLS> converts from the 
ISO 8601:2004 printed form of UTC to the form required to generate a PTP timestamp. 
For example, at 0 h 2 January 1972 TAI, the value of PTP Instance Time was 63 158 400. At this time, 
<dLS> was 10. The POSIX algorithm applied to the value (63,158,400 − 10) gives a value of 23:59:50 
1972-01-01 (10 s before 0 h 2 January 1972 UTC). The value of PTP Instance Time on 0 h 2 January 1972 
TAI is computed by observing that PTP Instance Time = 0 on 0 h 1 January 1970 TAI, that is, MJD 40 587. 
On 0 h 2 January 1972 TAI, MJD = 41 318. Thus, PTP Instance Time on 0 h 2 January 1972 TAI is  
0 + 86 400 × (41 318 − 40 587). Note that if this calculation were done for a day in which a leap second 
occurred, a more complex algorithm would be required to ensure that, for the duration of the leap second, 
the ISO 8601:2004 [B29] print form seconds value would be 60 for a positive leap second. 
International standards specify that if a correction to UTC relative to TAI is required, the leap second 
occurs at the last second of the UTC day, preferably at the end of June 30 or December 31. For a negative 
leap second, the last minute of the designated day has only 59 seconds. Negative leap seconds have never 
occurred and are unlikely to occur in the future. For a positive leap second, the last minute of the 
designated day has 61 seconds. 
Although a negative leap second is unlikely to occur, if such a correction becomes necessary the  
ISO 8601:2004 [B29] printed representation would appear as follows for a hypothetical negative leap 
second on 30 June 1972 UTC:  
1972-06-30 23:59:57, 1972-06-30 23:59:58, 1972-07-01 00:00:00 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
377 
For the positive leap second that actually occurred on 30 June 1972 UTC, the ISO 8601:2004 [B29] printed 
representation appeared as follows: 
1972-06-30 23:59:59, 1972-06-30 23:59:60, 1972-07-01 00:00:00 
Note the 23:59:60 notation to indicate the added second. 
The update semantics for leap-second updates in PTP are discussed in B.2.2. 
B.2.2 Update semantics for UTC and alternate timescales 
B.2.2.1 General Semantics of timePropertiesDS.currentUtcOffset, 
timePropertiesDS.leap59, and timePropertiesDS.leap61  
When the timescale is PTP, the members of the timePropertiesDS enable PTP Instances of a PTP Network 
to compute the current UTC time from the PTP Instance Time. PTP distributes the current time on the 
timescale via the timestamps in the PTP timing messages. PTP does not distribute UTC but distributes the 
information needed to compute UTC from PTP Instance Time via the timePropertiesDS information 
contained in Announce messages. 
In all cases, per the specifications of 9.4, the PTP Grandmaster Instance is responsible for inserting the 
correct values of leap-second information into the PTP messages. The PTP Grandmaster Instance is also 
responsible for receiving this information from an external source.  
PTP Instances other than the Grandmaster PTP Instance propagate this information based on the 
specifications of 9.3.5. Such PTP Instances are able to compute the precise PTP Instance Time for update 
and the updated value of <dLS> based on the information in their timePropertiesDS without waiting for 
receipt of the updated <dLS> information from the Grandmaster PTP Instance. Specifically, a PTP Instance 
can use the values of timePropertiesDS.leap59 and timePropertiesDS.leap61 to compute the PTP Instance 
Time when the update is to occur. The updated value of <dLS> can be computed from 
timePropertiesDS.currentUtcOffset and knowing, for example, that for a TRUE value of 
timePropertiesDS.leap61 that the updated <dLS> will be timePropertiesDS.currentUtcOffset + 1. After a 
leap-second event, the fields related to leap seconds in the received Announce message will not be updated 
immediately due to the delay in the propagation of Announce messages. As a result, PTP Instances need to 
avoid further leap-second processing until updated timePropertiesDS information is received from the 
Grandmaster PTP. 
It is also possible for a receiving PTP Instance to ignore the leap-second flags and simply update the 
computed values of UTC whenever an updated value of timePropertiesDS.currentUtcOffset is received. 
However, this option ensures that the updates will not occur at the same instant in all PTP Instances and in 
all cases will differ from the Grandmaster PTP Instance during the time it takes for the information to 
propagate according to the specifications of 9.3.5.  
B.2.2.2 Semantics for the use of option 16.3 to compute Pacific Standard Time during a 
positive leap second 
Consider the operation of a Grandmaster PTP Instance, and another PTP Instance, C, during the time period 
from 1990-Dec-31 23:59:59 to 1991-Jan-1 00:00:00 UTC. This time interval includes a positive leap 
second as the last second of 1990-Dec-31 UTC, which results in the value of <dLS> changing from 25 s to 
26 s at midnight of that day. In this example, the Grandmaster PTP Instance is using the 
ALTERNATE_TIME_OFFSET_INDICATOR TLV to distribute Pacific Standard Time, PST. Note that 
PST is 8 h (28 800 s) behind UTC, which in turn is <dLS> behind PTP. The total offset of PST from PTP; 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
378 
that is, currentOffset (see 16.3.3.5), is therefore –<dLS> –28 800 s. Note that the receiving PTP Instance 
does not itself correct for the leap second in the received value of timeOfNextJump. It is the responsibility 
of the Grandmaster PTP Instance to correct for <dLS> in computing values of jumpSeconds and 
timeOfNextJump. 
B.3 Standard time sources 
There are two standard time sources of particular interest in implementing PTP systems for which UTC 
traceable time is required by the application. 
The first time source is the set of systems implementing the Network Time Protocol (NTP) protocol [B19], 
widely used in synchronizing computer systems within a campus and around the world. A set of NTP 
servers, to which NTP clients synchronize, is maintained. These servers themselves are synchronized to 
timeservers traceable to international standards. UTC time accuracy from NTP systems is usually in the 
millisecond range. NTP provides the current time and warning flags marking the introduction of a leap-
second correction, which is inserted at the end of the current UTC day. NTP does not correct the number of 
NTP seconds since the NTP epoch whenever a leap-second correction is made. (In other words, the NTP 
clock effectively stops during a leap second, and the time interval occupied by a leap second is effectively 
“forgotten” once it has been inserted.) The NTP epoch is 0 h on 1 January 1900. NTP was set at 0 h on 1 
January 1972 to 2 272 060 800.0, to agree with UTC. Currently, NTP represents seconds as a 32-bit 
unsigned integer. NTP therefore rolls over every 232 s ≈ 136 years, with the first such rollover occurring in 
approximately the year 2036. 
The second system of interest is Global Navigation Satellite System (GNSS). For example, the GNSS 
maintained by the U.S. Department of Defense is the GPS. UTC time accuracy from the GPS system is 
usually in the 10 ns to 100 ns range. GPS system transmissions represent the time as {GPS Weeks, GPS 
SecondsInLastWeek}, that is, the number of weeks since the GPS epoch and the number of seconds since 
the beginning of the current week. From this, GPS Seconds, that is, the number of seconds since the GPS 
epoch, can be computed. GPS provides the current time, a leap-seconds offset, and warning flags marking 
the introduction of a leap-second correction. From GPS time, UTC and TAI times can be computed using 
the information contained in the GPS transmissions. The GPS epoch began at 0 h on 6 January 1980 UTC 
(MJD 44 244). GPS weeks are represented in the satellite transmissions modulo 1024 weeks ≅ 19.7 years. 
The first such rollover occurred between the weeks of 15 August and 22 August 1999. Many, but not all, 
commercial systems are believed to have correctly managed this rollover. 
Either of these systems is appropriate for use in providing time to a clockClass 6 clock. Relationships 
between the timescales discussed and examples of times in each system for interesting instants are given in 
Table B.1. In Table B.1, PTP Seconds refers to the seconds portion of the time distributed by the timescale 
PTP and, as noted, is referenced to 1 January 1970 TAI. 
Table B.1 Relationships between timescales 
From 
To 
Formula 
NTP Seconds 
PTP Seconds 
PTP Seconds = NTP Seconds ─ 2 208 988 800  
+ currentUtcOffset 
PTP Seconds 
NTP Seconds 
NTP Seconds = PTP Seconds + 2 208 988 800  
─ currentUtcOffset 
GPS Seconds = (GPS Weeks × 7 × 86 400) 
+ GPSSecondsInLastWeek 
(GPS week number needs to include 
1024 × number of rollovers) 
PTP Seconds 
PTP Seconds = GPS Seconds + 315 964 819 
PTP Seconds 
GPS Seconds 
GPS Seconds = PTP Seconds ─ 315 964 819 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
379 
B.4 Meaning and uses of the attributes of the timePropertiesDS data set 
The Grandmaster PTP Instance determines the time and frequency that are distributed within a PTP 
domain. The Grandmaster PTP Instance also sets the values of attributes in the timePropertiesDS data set 
that describe properties of the time and frequency. These attributes are also distributed within a domain. 
The attribute timePropertiesDS.timeSource (see 8.2.4.9) indicates the nature of the source of time and 
frequency distributed by the Grandmaster PTP Instance. As noted in 8.2.4.9 and 7.6.2.8, the source can be 
internal or external to the Grandmaster PTP Instance.  
The attribute timePropertiesDS.ptpTimescale (see 8.2.4.8) indicates whether the timescale of the domain as 
established by the Grandmaster PTP Instance is the timescale PTP or the timescale ARB,(see 7.2). If the 
value is PTP, then the epoch or origin of the timescale is the PTP epoch (see 7.2.3). 
The attribute timePropertiesDS.frequencyTraceable (see 8.2.4.7) indicates whether the frequency is 
traceable to international standards. A clock consists of an oscillator and a counter. This attribute refers to 
the frequency of the oscillator. This effectively defines the realization of the second in the domain. For 
example, the GPS system distributes a signal traceable to international standards. If the Grandmaster PTP 
Instance has access to this signal from a GPS receiver and uses this to syntonize the Grandmaster PTP 
Instance within the accuracy defined in the applicable profile for traceability, then this attribute is TRUE. 
On the other hand, if the Grandmaster PTP Instance either does not have access to the GPS signal or does 
not make use of it in syntonizing its Local PTP Clock, then whether or not this attribute is TRUE depends 
on whether the accuracy of the second realized by the free running local clock agrees with the second 
defined by international standards to within the traceability accuracy specification of the applicable profile.  
It is also possible that the Grandmaster PTP Instance implicitly sets the frequency based on periodic 
updates of the time. If in this case it can be demonstrated that the frequency derived from the Grandmaster 
Clock is within the traceability accuracy requirement for frequency established by the applicable profile, 
then the frequency can be considered traceable. Note that if the ptpTimescale is ARB, indicating that the 
epoch is arbitrary or not known to be traceable to international standards, that is, the time is not traceable, it 
is still possible that the frequency defined by the Grandmaster Clock is traceable. Indeed, this is precisely 
the situation dealt with in ITU-T Recommendation G.8265.1 (July 2014) [B35], which specifies how this 
standard is used to distribute frequency but not time in a telecommunications application. 
The attribute timePropertiesDS.timeTraceable (see 8.2.4.6) indicates whether the time indicated by the 
Grandmaster Clock is traceable to international standards. For example, the GPS system distributes a signal 
and data from which the time, traceable to international standards, can be derived. If the Grandmaster PTP 
Instance has access to this signal and data from a GPS receiver and uses this to periodically update the time 
of Grandmaster Clock within the accuracy defined in the applicable profile for traceability, then this 
attribute would be TRUE. On the other hand, if the Grandmaster PTP Instance either does not have access 
to the GPS signal or does not make use of it, this attribute would normally be FALSE unless it could be 
otherwise demonstrated that the time was indeed traceable. Similar arguments would apply to other 
potential sources of time traceable to international standards. 
The value of the attribute timePropertiesDS.currentUtcOffset (see 8.2.4.2) indicates the difference between 
the TAI and UTC timescales (see 7.2.4). This difference is defined by international agreement and is 
independent of the operation of the PTP protocol. Whether the actual value of the attribute 
timePropertiesDS.currentUtcOffset 
is 
valid 
is 
indicated 
by 
the 
value 
of 
the 
attribute 
timePropertiesDS.currentUtcOffsetValid (see 8.2.4.3). If currentUtcOffset is valid and if the timescale of 
the domain is PTP, then UTC can be computed from the timescale PTP as outlined in 7.2.4. Even if the 
value of the currentUtcOffset is valid, if the timescale of the domain is ARB, in general UTC cannot be 
computed 
from 
the 
timescale 
of 
the 
domain. 
In 
this 
case, 
the 
ALTERNATE_TIME_OFFSET_INDICATOR TLV of 16.3 can be used to compute UTC. Most 
Grandmaster PTP Instances will obtain values for UTC offset from their external primary reference. For 
example, the GPS system distributes this information. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
380 
The attribute timePropertiesDS.leap59 (see 8.2.4.4) or timePropertiesDS.leap61 (see 8.2.4.5), when TRUE, 
indicates that a leap-second correction is to occur at the end of the UTC day. This notification information 
is included in GPS transmissions and from other sources. 
The timePropertiesDS attributes timeSource, ptpTimescale, frequencyTraceable, and timeTraceable are 
established by the Grandmaster PTP Instance and distributed to other PTP Instances within the domain. 
None are used in the operation of the BMCA (see 9.3.2). The Grandmaster PTP Instance can make use of 
the properties described by these attributes in the determination of clockClass (see 7.6.2.5). Applications 
served by PTP Instances can make use of these attributes in determining how to interpret the time or 
frequency distributed within the domain; for example, whether the timescale is PTP or ARB is usually 
critical for applications. 
Many applications require determining UTC time from time distributed by PTP. This determination is the 
responsibility of the application or, if specified in the applicable profile, of PTP Instances delivering time 
directly to an application. The PTP protocol does not distribute UTC directly but, when possible, does 
distribute the information needed to compute UTC. 
It is possible to compute UTC from time distributed by PTP if all the following conditions hold: 
a) 
The timescale is PTP as indicated by the ptpTimescale attribute. 
b) 
The currentUtcOffsetValid attribute is TRUE, indicating that the currentUtcOffset value is valid 
and can be used in the computations. 
c) 
The timeTraceable attribute is TRUE, indicating that the timescale PTP is traceable to international 
standards to the accuracy specified in the applicable profile.  
NOTE—It is possible but not verifiable based on PTP attributes to compute UTC with lower accuracy than specified by 
the timeTraceable attribute.  
If these conditions are met, there are two ways provided in the standard for the computation of UTC from 
time distributed by PTP within the domain. 
The first is a direct computation where UTC = TAI – currentUtcOffset (see 7.2.4). In effect, subtracting the 
currentUtcOffset value from the time of the Local PTP Clock and then applying the result to the POSIX 
algorithm yields the correct print form of UTC, except during a positive leap second, when the algorithm 
needs to be modified to create a seconds value of 60.  
The second method is the use of the ALTERNATE_TIME_OFFSET_INDICATOR TLV of 16.3. This 
method requires the Grandmaster PTP Instance to distribute the information needed to compute UTC using 
this TLV. The computation itself is done in PTP Instances distributing time directly to the application. In 
this case, the values of currentUtcOffset, leap59, and leap61 of the common header are not used by PTP 
Instances in the computation as in the first method, although they might be useful as part of the 
computations 
done 
by 
the 
Grandmaster 
PTP 
Instance 
in 
populating 
the 
fields 
of 
the 
ALTERNATE_TIME_OFFSET_INDICATOR TLV.  
Note that while the ALTERNATE_TIME_OFFSET_INDICATOR TLV of 16.3 can be used to distribute 
information needed to compute UTC from the timescale PTP, its primary purpose is to compute other 
timescales. When used for its primary purpose, the Grandmaster PTP Instance uses the TLV to distribute 
the information to compute the desired alternate timescale based on offsets from the timescale distributed 
by the PTP Grandmaster Instance, that is, PTP or ARB. For example, the TLV can be used for computing 
time since some external event known to the Grandmaster PTP Instance, for example, the launch of a 
rocket, from the timescale in use within the domain. 
When the timescale is PTP, time is continuous in the domain. However, if the timescale is ARB, time can 
be piecewise continuous. There are two ways PTP Instances can manage steps in the UTC offset or similar 
discontinuities in timescale offsets distributed via the ALTERNATE_TIME_OFFSET_INDICATOR TLV. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
381 
In the case of UTC and a timescale PTP, a PTP Instance receives time and the currentUtcOffset values 
from the Grandmaster PTP Instance. The PTP Instance synchronizes its Local PTP Clock to that of the 
Grandmaster Clock by accounting for the propagation delays using either the peer-to-peer or end-to-end 
methods. Thus, PTP time at PTP Instances always matches the time of the Grandmaster Clock to within the 
synchronization accuracy. At a leap-second event, the value of currentUtcOffset changes by a second. The 
notification of this change takes time to propagate to downstream PTP Instances. Hence, while the 
downstream PTP Instances could simply compute UTC by subtracting its current known value of 
currentUtcOffset, the result would be in error during the time taken for the updated value of 
currentUtcOffset to propagate to the PTP Instances.  
Alternatively, the leap59 and leap61 flags of the common header can be used by PTP Instances to ensure 
that leap-second events occur simultaneously throughout the domain to within the accuracy of 
synchronization. These flags, when TRUE, indicate that a leap second is to be added or subtracted at the 
end of the current UTC day. These flags are set sufficiently in advance of the event to permit PTP Instances 
to make the leap-second correction at the correct UTC time based on the time of the PTP Instance’s Local 
PTP Clock. 
In the case where the ALTERNATE_TIME_OFFSET_INDICATOR TLV is used, jumps in the timescale 
are indicated by the jumpSeconds and timeOfNextJump fields. The values of these fields can be used by a 
PTP Instance to make offset corrections at the appropriate time on the timescale in use based on the time of 
the PTP Instance’s clock. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
