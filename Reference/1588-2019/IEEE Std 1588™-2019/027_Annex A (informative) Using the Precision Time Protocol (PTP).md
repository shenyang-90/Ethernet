# Annex A (informative) Using the Precision Time Protocol (PTP)

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
365 
Annex A  
(informative)  
Using the Precision Time Protocol (PTP) 
A.1 Overview 
PTP provides a simple methodology for accurately synchronizing PTP Instances in a network. When 
designing such a network, the following questions need to be answered: 
Physical layout issues: 
 
How physically dispersed are the PTP Instances? 
 
What network technology is to be used? 
Logical issues: 
 
Is the system a single collection of PTP Instances, or are the PTP Instances divided into logical 
groupings each with their own sense of time? 
Component issues: 
 
How accurately do the PTP Instances need to be synchronized? 
 
What is the source of time for the system? Does it need to be traceable to UTC or TAI? 
Local implementation issues: 
 
How are timing requirements to be met? 
 
How do other applications sharing the communication network affect PTP? 
 
How do accuracy requirements affect the implementation? 
 
What are the design issues for local oscillators? 
System implementation issues: 
 
How is the system partitioned? 
 
Which options are used? 
 
Which profiles are used? 
Performance issues: 
 
How do network delays and fluctuations affect PTP Instance Time accuracy? 
 
How does clock oscillator stability affect PTP Instance Time accuracy? 
Conformance testing issues: 
 
What features aid in conformance and performance testing? 
 
What features aid in calibrating PTP Instance timing? 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
366 
Subclause A.2 through subclause A.9 address each of these topics. 
A.2 Physical layout 
PTP Instances communicate with each other over a PTP Network. Typically, the selection of the network 
technology is based on the primary application. PTP works on any message-based network. PTP is 
designed to work in a multicast environment, although it is possible to design unicast PTP components and 
networks. Ethernet is a well-suited network for implementing PTP, and the rest of this annex uses Ethernet 
as an example. 
All networks have limitations on distance, number of allowed PTP Instances, and traffic. If the PTP 
Instances to be synchronized are dispersed beyond the range of the network technology, then the networks 
are preferably designed as separate “islands of time” with provision outside of PTP for synchronizing these 
islands. 
For example, if the network consists of two compact sites separated by several miles, PTP can be used 
within each site, with site-to-site synchronization provided by another technology such as GPS.  
Within a site, distance, traffic, and number of PTP Instance issues are usually addressed by special network 
components. For Ethernet, localized devices typically communicate via bridges. For larger and more 
complex networks, routers are used to separate the network into regions using only bridges. In general, 
each level of separation using these devices introduces additional statistical delay and delay fluctuation in 
the PTP message transmission times between devices. 
PTP is designed to minimize the effects of delay and delay fluctuation. To get the best PTP performance, 
the PTP Network topology preferably minimizes the number of such separating devices between PTP 
Instances with the most critical synchronization requirements. 
Bridges and routers not implementing PTP can introduce considerable timing jitter and path asymmetry. 
Although such devices can be included in a PTP Network, use of these devices is not advisable unless 
timing errors introduced by their jitter and path asymmetry are tolerable for the application, or can be 
reduced by an appropriate filtering algorithm. These effects can be mitigated by implementing PTP in 
bridges and routers (i.e., Boundary Clocks and/or Transparent Clocks). 
A.3 Logical layout 
Most applications consist of a single set of PTP Instances to be synchronized. For this case, all the PTP 
Instances can be placed in a single domain. If the default values specified in this standard and the 
applicable conformant PTP Profile are used, then generally no configuration of the PTP Instances is 
necessary. 
If the application requires several groups of PTP Instances, with each group maintaining a different self-
consistent timescale, then one of the following two solutions can be used: 
 
If the rest of the application is segmented into the same groups, it might be possible to use separate 
noncommunicating PTP Networks; in which case, each group can use the default domain. Network 
routers are often used for this purpose. 
 
If the groups have to share a common PTP Network, then each group can be assigned to a different 
domain. This logically divides the PTP Instances as desired. Depending on the mapping to the 
underlying physical addressing of the network, the processing load on each PTP Instance might or 
might not be affected.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
367 
With the exception of the assignment of PTP Instances to a domain, PTP defines an administration-free 
network in the default case. Within a domain, PTP Instances can be added or removed without any 
requirement for modification of address tables, etc., provided components use the recommended multicast 
communication model. Addition or removal of PTP Instances might cause a different PTP Instance to 
become the Grandmaster PTP Instance in the network. This might cause a transient in the timescale as the 
network automatically recalibrates for the new delay patterns to the new Grandmaster PTP Instance. 
This standard provides several configuration options for users that require more control over the selection 
of Master PTP Instances, or over different timing and other attributes that govern network performance. For 
example, the use of the priority1 attribute allows network designers to designate up to 254 devices in a 
priority order for Grandmaster PTP Instance selection. 
A.4 Component issues 
The primary issue in the selection of PTP Network components is the required synchronization accuracy. 
 
PTP Instances that support protocol features protocol required to achieve the desired accuracy need 
to be selected.  
 
Network components and physical design decisions also affect the accuracy as outlined in the 
previous clauses. 
Properly designed Ethernet PTP Networks can readily achieve sub-microsecond accuracy. 
A second issue is the technique for establishing the PTP Network epoch. In every domain, the epoch is 
defined by the Grandmaster PTP Instance that is selected according to the best master clock algorithm. 
If TAI or UTC traceable time is a requirement, then the Grandmaster Clock maintains the timescale PTP. 
If the value of clockClass is 6, 7, 52, or 187 for the Grandmaster PTP Instance in a domain, the timescale is 
PTP. From the timescale PTP, UTC can be computed using the value of currentUtcOffset distributed by 
PTP. Such networks might or might not maintain the epoch after a power outage (see 7.6.2.5). 
If the value of clockClass is 13, 14, 58, 193, or 216 or greater for the Grandmaster PTP Instance in a 
domain, the timescale is ARB (see 7.6.2.5). Such networks might or might not maintain the epoch after a 
power outage. 
A Master PTP Instance can fail in such a way that its time or frequency become incorrect. Detection of this 
problem and recovery from it, within a single domain, are outside the scope of this standard. Some 
information such as the Parent PTP Instance statistics maintained in the parentDS data set is available to aid 
in detecting a “false-ticking” master. Implementers are advised to consider information from as many PTP 
Instances as possible, and to weigh the information from each PTP Instance according to the inherent 
stability of the Local PTP Clock of the PTP Instance. A PTP Network containing three or more domains 
using the same time reference can identify false ticking masters by using a voting algorithm (see O.3). 
Disabling a PTP Port with management (i.e., write portDS.portEnable to FALSE) can aid in recovering 
from a false-ticking master. Note that disabling or demoting a Master PTP Instance has side effects 
(especially if it is a Boundary Clock), so the decision to do that might depend on factors besides its 
timekeeping quality. That decision is outside the scope of this standard. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
368 
A.5 Local implementation issues 
A.5.1 General 
This subclause provides some guidelines for implementers of PTP Ordinary Clocks, Boundary Clocks, and 
Transparent Clocks. Although not within the scope of this standard, note that services built on top of PTP 
Instances synchronized via PTP (or any other protocol) might degrade the accuracy beyond acceptable 
limits. 
A.5.2 Timing issues 
Implementations need to meet the PTP message processing and timing requirements and also need to meet 
whatever timing requirements are needed to operate any servomechanism that synchronizes the Local PTP 
Clock based on information in PTP messages. 
Implementations need to ensure that adequate computing and memory resources are available to meet these 
requirements. Implementations also need to ensure that the resources needed by the PTP implementation 
have adequate priority over other applications sharing these resources to meet the PTP and 
servomechanism timing requirements. PTP tasks are preferably assigned the highest priority in an 
implementation, similar to priorities assigned to the protocol stack and other operating network resources. 
PTP implementations normally require resources for a short time in every syncInterval. The selection of the 
syncInterval for a network needs to be consistent with the available resources in all network components. 
The use of PTP Network resources by other applications can affect PTP accuracy as discussed in A.5.3. 
A.5.3 Accuracy issues 
A.5.3.1 General 
The achievable accuracy of a PTP Network is limited by the following: 
 
Delay fluctuation in the protocol stacks of PTP Instances 
 
Delay asymmetry 
 
Delay fluctuation in network components 
 
Timestamping accuracy 
 
Stability issues 
A.5.3.2 Protocol stack delay fluctuation 
The simplest implementations of PTP operate as ordinary applications at the top of the network protocol 
stack. Timestamps are generated at the application level. Protocol stack delay fluctuation causes errors in 
these timestamps. These errors are typically in the hundred microseconds to milliseconds range, depending 
on the operating system. 
Implementations might generate timestamps at the interrupt level rather than at the application level. In this 
case, delay fluctuation typically can be reduced to tens of microseconds depending on other use of 
interrupts by other applications, and on the traffic patterns on the network. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
369 
A.5.3.3 Network component delay fluctuation 
Network components introduce fluctuation in the propagation time of PTP messages. This directly affects 
the accuracy of the currentDS.offsetFromMaster, currentDS.meanDelay, and portDS.meanLinkDelay 
values. 
Network bridges and routers are subject to store-and-forward delay fluctuation. Typical Ethernet bridges 
have input and output buffers communicating over a very high-speed back plane or switch fabric. Each PTP 
Port typically connects directly to an end device or another Ethernet bridge. The dominant contribution to 
delay fluctuation arises from the output buffering and queuing. If the output subnet is always available, this 
delay fluctuation is typically in the nanoseconds range and reducible by averaging techniques. Intensive 
traffic in a network might cause increased delay fluctuation due to this output buffering. This increased 
delay fluctuation is much more difficult to reduce. The proper design of PTP Networks need to recognize 
this effect and take measures to reduce the impact.  
Most bridges and routers support traffic prioritization. High-priority traffic suffers less fluctuation in 
propagation time. PTP event messages preferably are sent with high priority compared with other data 
whenever possible. See Annex D through Annex I for specific priority recommendations for each transport 
protocol. 
A.5.4 Timestamp accuracy 
The resolution of the clock generating the timestamps required by PTP needs to be consistent with the 
desired accuracy. Note that this resolution contributes to the PTP variance (see 7.6.3). 
A.5.5 Stability issues 
As noted earlier in this annex, the delay fluctuation introduced into the computation of the 
currentDS.offsetFromMaster and currentDS.meanDelay members can be reduced by suitable design of any 
synchronization servo algorithms of the PTP Instance. Engineering trade-offs need to be made between the 
averaging times (number of samples) and the responsiveness to effects other than delay fluctuation, such as 
oscillator stability.  
The fundamental time stability of the Local PTP Clock needs to be consistent with the required 
syncInterval and accuracy specifications. The algorithms used to reduce delay fluctuation do not correct for 
drifts of the local clocks during time intervals that are small compared with the averaging intervals of the 
algorithms. Servos cannot correct for random drifts occurring within a syncInterval. 
At high accuracy, the specifications on the stability of the local oscillators driving the Local PTP Clock can 
be quite difficult to meet. The trade-off is between cost and stability. Local oscillators typically are quartz 
crystals. The frequency of quartz crystals typically drifts due to thermal, mechanical, and aging effects. Of 
these effects, thermal ones are the most difficult to deal with in most applications. 
For example, a typical thermal specification for uncompensated crystals is 1  ppm per degree Celsius. A 1° 
temperature rise over a syncInterval of 2 s produces an error on the order of 2 µs. Accuracies in the tens of 
nanosecond range, therefore, imply that some combination of better thermal specifications on the crystal, 
reduced syncInterval, and better thermal management be used to reduce the thermal drift by two orders of 
magnitude. 
PTP allows syncInterval to be reduced to a fraction of a second depending on the PTP Profile selected, with 
the corresponding increase in computation and network bandwidth requirements. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
370 
Thermal specifications on crystals become increasingly expensive below 1 ppm/degree. Control of the 
thermal environment needs to be carefully managed, particularly in high accuracy implementations. Very 
long averaging times typically require oven-controlled crystals or the use of more stable oscillators. 
Thermal drift during the short intervals and averaging times typical of PTP Networks can often be managed 
by attention to heat dissipation in surrounding devices, cooling patterns within the device, increasing the 
thermal mass of the oscillator, and similar techniques. See Sullivan et al. [B52] for a thorough discussion of 
clock characterization. 
A.6 System implementation issues 
A PTP Network is the collection of PTP components that operate together to meet the requirements of an 
application. An interoperable PTP Network is one where the protocol operates as specified in this standard, 
the selection and configuration of PTP Instances is such that the protocol is successful in constructing a 
master−slave timing hierarchy, and the PTP Instances with a PTP Port in the SLAVE state are able to 
synchronize to Master PTP Instances. An optimal PTP Network is one that is interoperable, manageable, 
and meets the synchronization requirements of the application. Ensuring that a network built with 
conformant PTP Instances is optimal is an issue for the network integrator. The following 
recommendations facilitate the construction of interoperable networks: 
 
Use a single transport media (e.g., Annex C to Annex H) throughout the domain, or divide the 
domain into regions, each of which uses a single transport. Regions are connected using Boundary 
Clocks.  
 
Use a single management approach throughout the network. Either the PTP management message 
mechanism of this standard or an alternate management mechanism specified in a PTP Profile are 
acceptable.  
 
Use the same choice of best master clock algorithm throughout the domain. There is no assurance 
that regions of a domain implementing different choices of best master clock algorithm can be 
made to interoperate, even when connected by a Boundary Clock. Use either the best master clock 
algorithm defined in this standard or an alternate specified in a PTP Profile. 
 
Use the same selection of state configuration options (Clause 17) throughout the domain. If state 
configuration options are used, it is the responsibility of the network integrator to ensure that the 
selected configuration produces an interoperable network. There is no assurance that regions of a 
domain implementing different choices of configuration options and configuration can be made to 
interoperate, even when connected by a Boundary Clock.  
 
Use a single path delay mechanism (see 11.3 and 11.4) throughout the domain, or divide the 
domain into regions with each using a single path delay mechanism. Regions are connected using 
one or more Boundary Clocks.  
 
Use an interoperable set of attribute and configurable data set values throughout the domain, or 
divide the domain into regions with each using a single such interoperable set. Regions are 
connected using one or more Boundary Clocks.  
 
Use the same default value for each attribute and configurable data set member on all PTP 
Instances in the network.  
 
Use the same required maximum and required minimum range values for each attribute on all PTP 
Instances in the network.  
 
Some options only work as designed, without interoperability problems, if they are implemented 
and active on every PTP Instance in a network. An example is the security option (see 16.14). 
Other options are effective on the subset of PTP Instances implementing them, even if other PTP 
Instances in the network do not support the option. Furthermore, the presence of such PTP 
Instances does not interfere with PTP Instances not implementing the option. An example is the 
unicast option. 
 
Use only PTP Instances implementing the same PTP Profile throughout the domain, or divide the 
domain into regions, with each using a single PTP Profile. Regions are connected using a Boundary 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
371 
Clock capable of resolving the PTP Profile differences. There is no assurance that the specifications 
of two PTP Profiles allow the design of a Boundary Clock that resolves their differences. For 
example, it is not possible to ensure that regions using self-configuration with the best master clock 
algorithm of this standard can interoperate with regions that use configuration of the master−slave 
hierarchy. 
 
Use only PTP Instances implementing the same version of this standard throughout the domain, or 
divide the domain into regions with each using a single version (version 1, version 2, or a future 
version). Connect these regions using a Boundary Clock.  
A.7 Guidelines to achieve optimal performance 
The following requirements will aid in achieving optimal clock synchronization performance: 
a) 
The delay of a PTP message exchanged the Master PTP Instance and a Slave PTP Instance need to 
be symmetric. 
b) 
A PTP Instance might contain asymmetric delays in its timestamping mechanism or protocol path. 
If these asymmetries are not negligible, they need to be correctly accounted for (see 7.4.2). 
c) 
The delay of a PTP message exchanged between a Master PTP Instance and a Slave PTP Instance 
need to be constant over the time interval between PTP event messages. 
d) 
Delay fluctuation due to network components and due to the protocol stack within PTP Instances 
are preferably reduced by two techniques: 
1) 
The timestamps used in PTP need to be generated as close to the physical layer as practical 
for a given PTP Instance implementation. In cases where the most accurate timestamps can be 
generated only after a message has been transmitted, the actual value is communicated in a 
Follow_Up message or a Pdelay_Resp_Follow_Up message.  
NOTE—See Eidson et al. [B6], IETF RFC 1589 [B13], and IETF RFC 2783 [B14] for mechanisms to 
aid in generating these timestamps. 
2) 
Remaining delay fluctuation introduced by the protocol stack and by network components not 
isolated by a Boundary Clock or Transparent Clock can be reduced by averaging. The 
averaging algorithms are outside the scope of this standard. 
e) 
The computing power of PTP Instances implementing the protocol needs to be great enough and 
the number of PTP Instances needs to be small enough to meet the timing constraints. 
Implementers of Boundary Clocks and Ordinary Clocks, for example, need to consider the 
resources required to process Delay_Req messages from Slave PTP Instances communicating with 
the PTP Instance. The inability to process these messages due to resource limitations can lead to 
deterioration in the synchronization performance due to missed measurements of the path delays. 
Users need to be aware of this limitation when selecting PTP Nodes and designing their network. 
f) 
The inherent stability and precision of a PTP Instance’s oscillator need to be adequate; see A.5.4 
and A.5.5. 
A.8 Recommendations to aid in conformance testing 
To aid in 1) testing the performance of a PTP Network, 2) calibrating PTP Instances, and 3) verifying 
conformance, all PTP Ordinary Clocks and Boundary Clocks preferably provide a 1 pulse per second (PPS) 
signal with the rising edge of the pulse coincident with each increment in the seconds field of the PTP 
Instance. If implemented and not coincident, then the PTP Instance specifications preferably include the 
time offset of the 1 PPS signal from the seconds increment event time. This signal can be an accessible 
internal test point and need not be visible as an external output of the PTP Node in which the PTP Instance 
is embedded, for example, a sensor.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
372 
A.9 Recommendation for implementations in unicast networks or networks with 
non-PTP bridges and routers 
A.9.1 General 
Master PTP Instances and Slave PTP Instances will be introduced into networks where bridges and routers 
do not support the PTP standard. Furthermore, many networks do not support multicast. 
The unicast communication model can be used to overcome many of these problems. Subclause 7.3.1 
allows the use of a unicast model provided that the behavior of the protocol is preserved. 
This subclause describes issues that need to be resolved in an alternate PTP Profile when using a unicast 
communication model in order  to produce an implementation that is likely to work in such networks, while 
satisfying a wide range of timing requirements. Some wide-area network requirements, such as security and 
resilience, are outside of the scope of this discussion. 
A.9.2 Boundary Clocks and Transparent Clocks in a unicast model 
In the multicast model, Ordinary Clocks and Boundary Clocks create a synchronization hierarchy without 
prior knowledge of PTP Network topology. Except for PTP management messages, Boundary Clocks 
terminate all PTP messages. Furthermore, if only PTP bridges, routers, Transparent Clocks, and Boundary 
Clocks are present, the messages used by the peer-to-peer delay mechanism terminate in the neighbor peer-
to-peer PTP Instance. In the unicast model, however, the above conditions do not hold. 
To preserve the protocol behavior, the following functions need to be preserved when using the unicast 
model: 
 
The correct creation of the synchronization hierarchy.  
 
The correct exchange of PTP event messages and associated PTP general messages needed for 
synchronization. 
 
The correct operation of the peer-to-peer delay or delay request-response mechanisms for 
determining path latency. 
 
A management mechanism for configuring the PTP Instances. 
One way to achieve these functions is by requiring that all Ordinary Clocks, Boundary Clocks, and peer-to-
peer Transparent Clocks be configured in advance with the unicast protocol addresses of the neighboring 
PTP Instances visible from each PTP Port. As one exception to the previous sentence, the addresses of 
slave-only PTP Instances using the delay request-response mechanism do not need to be preconfigured in 
other PTP Instances if unicast option 16.1 is used. If the peer-to-peer delay mechanism is to be used, the 
configuration needs to ensure that only a single peer-to-peer PTP Instance is visible from each PTP Port 
(see 11.4.3). 
PTP Ports might be neighbors even when there are bridges, routers, or Transparent Clocks between the PTP 
Ports. PTP Ports are not neighbors if there is a Boundary Clock between them. In the event of a PTP 
Network reconfiguration, the neighbor relationships can change; in which case, two PTP Ports might 
communicate in unicast across a Boundary Clock. If a mechanism for learning topology changes is 
available, PTP Instances can stop all unicast communications between non-neighbors, leading to an 
optimized synchronization hierarchy and better utilization of the network resources. If such a learning 
mechanism is not available, then depending on the PTP Network topology, it might be advisable to use 
end-to-end Transparent Clocks instead of Boundary Clocks or peer-to-peer Transparent Clocks. In all 
cases, the implementation has to provide a mechanism to break forwarding loops for achieving correct 
operation of the protocol.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
373 
A.9.3 Unicast options 
The configuration options of Clause 17 can be used to configure each PTP Port with the needed unicast 
protocol addresses. 
The unicast option of 16.1 can be used to establish unicast communications for Announce, Sync, 
Delay_Resp, and Pdelay_Resp messages, and any associated messages.  
Alternatively, unicast contracts between two PTP Instances can be created using a management 
mechanism. These contracts consist of the unicast address information and of respective specified packet 
rates for Sync, Announce, and Delay_Req messages.  
The path trace option of 16.2 can be used in defining a mechanism for breaking a loop formed by multiple 
PTP Communication Paths. 
Since the management mechanism of 15.2 depends on the use of the multicast model and on retransmission 
by Boundary Clocks, an alternative management mechanism for configuring the PTP Instances needs to be 
specified as permitted in 8.1.4.3. 
A.9.4 Unicast conformance 
A.9.4.1 General 
Subclause 20.2.3 specifies that to claim conformance, a PTP Instance needs to comply with a PTP Profile 
in addition to conforming to the PTP standard. This profile needs to specify any differences from the 
specifications of the default PTP Profiles of Annex I. Subclause A.9.4.2 contains examples of some of the 
specifications that are needed to implement a unicast model to meet the requirements discussed in A.9.1 
and A.9.2. Not discussed are possible alternate best master clock algorithms and an alternate unicast-based 
management mechanism. 
A.9.4.2 PTP options and attribute values 
The unicast options defined in 16.1 and 17.4 need to be supported and operational by default. All other 
options of Clause 16 and Clause 17 are permitted but need to be inactive by default.  
The unicast communication model is used by default as permitted by 7.3.1. If the multicast communication 
model, or mixed multicast/unicast is also implemented, it needs to be inactive by default. Multicast 
communication is a recommended option for exploiting future multicast support in these networks and for 
allowing interoperability with equipment supporting the PTP default profiles.  
The timing of unicast PTP messages is determined by the values of the logInterMessagePeriod field in the 
unicast negotiation REQUEST_UNICAST_TRANSMISSION TLV. 
Suggested values for the logInterMessagePeriod field of the REQUEST_UNICAST_TRANSMISSION 
TLV are as follows: 
 
For requesting unicast Announce messages: The suggested value of logInterMessagePeriod is 1 
(once every 2 s). The suggested configurable range is −3 (8 every 1 s) to 3 (once every 8 s). 
 
For requesting unicast Sync messages: The suggested value of logInterMessagePeriod is −4 (16 
every 1 s). The suggested configurable range is −7 (128 every 1 s) to 1 (once every 2 s). 
 
For requesting unicast Delay_Resp messages: The suggested value of logInterMessagePeriod is 
−4 (16 every 1 s). The suggested configurable range is −7 (128 every 1 s) to 6 (once every 64 s). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
374 
The suggested value of durationField in each REQUEST_UNICAST_TRANSMISSION TLV is 300  
(300 s) and the suggested configurable range is 10 to 1000. 
The maintenance and configuration of these default and configuration range values is implementation 
specific. 
In implementing the GRANT_UNICAST_TRANSMISSION TLV mechanism, the granted values 
preferably are the same as requested in the received REQUEST_UNICAST_TRANSMISSION TLV as 
long as the requests are in the configurable range.  
NOTE—Since the transport can be unreliable, it is recommended that the requesting PTP Port repeat the request after 
an implementation-specific timeout if no grant TLV has been received. For receiving continuous service, a requester 
can reissue a request in advance of the end of the grant period. The recommended advance includes sufficient margin 
for reissuing the request at least two more times if no grant is received. 
The 
values 
of 
defaultDS.announceReceiptTimeout, 
defaultDS.priority1, 
defaultDS.priority2, 
defaultDS.slaveOnly, and τ are identical to those specified in I.3 and I.4. 
The physical requirements are identical to those specified in I.3 and I.4. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
