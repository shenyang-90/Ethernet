# Annex O (informative) Example inter-domain interactions

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
466 
Annex O  
(informative)  
Example inter-domain interactions 
O.1 General 
This annex discusses examples of how the various interfaces specified in Clause 18 can be used to relate 
the timing in two or more domains to meet application requirements. These examples are suggestions and 
are not to be construed as the only way to meet a particular requirement. 
O.2 Sourcing timing to multiple domains 
Timing can be provided to each of several independent domains by means of independent external sources 
known to be consistent within the required accuracy and precision, for example from separate GPS 
receivers. Such transfers are via the Source Dependent block on the Grandmaster Clock of each domain 
(see 7.6.6). This is illustrated in Figure O.1. 
 
Figure O.1 Independent domains with independent timing sources 
NOTE 1— From 7.6.6, the Source Dependent block is the only permitted entry point for timing from a source external 
to the domain. 
Timing can also be provided to each of several independent domains as in Figure O.2. In this case since 
there is only a single external source of timing, consistency is assured. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
467 
 
Figure O.2 Independent domains fed from a single timing source 
 
In Figure O.2, each Ordinary Clock is in a different domain. The network facing PTP Ports are either in the 
MASTER or PASSIVE states based on the outcome of the best master clock algorithm in each or by the 
explicit setting of PTP Port states. Each of the Ordinary Clocks are configured such that the domain 
distinguishing attributes, for example, domainNumber, sdoId, etc., match those of the connected domain. 
NOTE 2— Ordinary Clocks operating in different domains can be on different physical network ports or they can share 
a physical port.  
O.3 Providing timing to users (sinks) from multiple independent domains 
Timing transferred from multiple independent domains to a common external Clock Sink, for example, a 
sensor, can be done as illustrated in Figure O.3. 
NOTE 1— This is the model used in ITU-T G.8265.1 [B35], a PTP telecom profile for frequency synchronization. 
In this example timing is transferred independently from an Ordinary Clock in each of the multiple 
domains to the common external Clock Sink. In each case the transfer is made via the Sink Dependent 
block of the PTP Instances (see 7.6.7). The external common sink can select or combine the timing 
according to specifications outside of PTP.  
NOTE 2— From 7.6.7, the Sink Dependent block is the only permitted exit point for timing from within a PTP Instance 
to a sink external to the domain. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
468 
 
Figure O.3 External Clock Sink receiving timing from independent domains 
The techniques of this example and/or the examples or O.2 can be used to implement common application 
requirements such as triple modular redundancy or to improve security among others.  
NOTE 3— Ordinary Clocks operating in different domains might be on different physical network ports or they might 
share a physical port.  
O.4 Transferring time from PTP domain A to PTP domain B  
O.4.1 General description 
Time, phase, frequency, and metadata describing these, referred to in these examples as “timing,” are 
passed between independent domains A and B via the Source Dependent and Sink Dependent blocks in the 
Media Independent portion of the general architecture model (see 7.6.6 and 7.6.7).  
Consider the transfer of timing from domain A to domain B. Timing from domain A is sent via a Sink 
Dependent block on a PTP Instance in domain A and received by a Source Dependent block on the PTP 
Instance in domain B as specified in clauses 7.6.6 and 7.6.7, respectively.  
The Sink Adapter block on the PTP Instance in domain A needs to be compatible with the Source Adapter 
block on the PTP Instance in domain B and the physical media connecting the two PTP Instances.  
NOTE—When transferring timing between domains, be sure that timing loops are not created. 
O.4.2 Transfer of timing from domain A to domain B via non-PTP mechanisms 
The Source Adapter block of the receiving PTP Instance in domain B and the Sink Adapter block of the 
PTP Instance in domain A can implement any appropriate time transfer protocol, for example, IRIG-B. 
This is illustrated in Figure O.4. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
469 
 
Figure O.4 Timing transfer from domain A to B via non-PTP links 
O.4.3 Transfer of timing from domain A to domain B via a PTP Communication Path in 
domain A 
When timing is transferred from domain A to domain B via PTP messages on a Direct PTP Link  
(see 3.1.8), the external interface of the Source Adapter block of the receiving PTP Instance in domain B 
functions as though it is a slaveOnly Ordinary Clock in domain A. This is illustrated in Figure O.5. 
Network 
domain B
Source Adapter 
Block Acting as a 
slaveOnly Clock in 
domain A
Ordinary Clock 
domain B
Network 
domain A
PTP Port 
domain A
PTP Port 
domain A
Direct PTP Link domain A
domain A
domain B
Boundary Clock 
domain A
 
Figure O.5 Timing transfer from domain A to B via a Direct PTP Link 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
470 
NOTE—The Source Adapter block in the receiving PTP Device Instance of domain B is modeled as an Ordinary Clock 
and serves as a Clock Source in the Source Dependent Block of the Ordinary Clock in domain B (see Figure O.1 and 
Figure O.2).  
O.4.4 Transferring timing information between two instances residing in the same  
PTP Node  
This section will introduce a few examples where it is useful to transfer timing information between two 
PTP Instances that reside in the same PTP Node, as for example shown in Figure O.6. 
  
PTP Port
domain B 
Master State
PTP Port
domain A
Slave State
Source
Adapter B
Sink
Adapter A
Network 
domain A
Network 
domain B
Ordinary Clock Instance 
Acting as Grandmaster
In secondary domain B
Ordinary Clock Instance
Acting as Slave
In primary domain A
Sync 
domain A
Sync domain B
Legend:
PTP Node
 
Figure O.6 Timing transfer from domain A to B, internal to a PTP Node 
O.4.4.1 Transfer of timing from profile X to profile Y using a PTP Profile Gateway 
There are cases in which two profiles are incompatible, but there is still a desire to be able to convey timing 
information between domains running these profiles, as shown in Figure O.7. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
471 
PTP Port
domain B 
Master State
PTP Port
domain A
Slave State
Source
Adapter B
Sink
Adapter A
Network 
domain A
Network 
domain B
Ordinary Clock Instance 
Acting as Grandmaster
In secondary domain B
Ordinary Clock Instance
Acting as Slave
In primary domain A
Sync 
domain A
Sync domain B
PTP Node
Profile/domain 
Adapter Block
Timing and timing 
metadata Adapter
 
Figure O.7 Timing transfer from profile X to profile Y using a PTP Profile Gateway 
Using the into and out of domain interfaces (see 18.2), an implementer can design a PTP Node that has 
different PTP Ports running on these different incompatible PTP Profiles. Timing will be transferred from 
one PTP Instance running one profile within one domain, to second PTP Instance running the second PTP 
Port in a different domain. Such a Node might have an adapter block for the timing information that can 
take into account profile specific timing metadata, such as cumulative rate ratio, when transferring timing 
information between the Source and the Sink. 
NOTE—This example does not specify how the Source and Sink are selected. Such selection is outside the scope of 
PTP. Depending on the specific profiles between which the conversion is done, this could be set statically, or the 
BMCAs of the two profiles could be reconciled, if possible, to allow for dynamic selection of the best clock from 
within the two domains. Such a dynamic approach in selecting the clock, which would be outside of PTP, might not be 
possible for some profiles’ BMCA decision trees or for more complex use-cases where the two domains share more 
than one such gateway. Also, note that if such a dynamic approach is desirable, it needs to be done with an Adapter 
(not shown in figure above) that can provide the functionality only through reading/writing the datasets through the 
management interfaces of the Instances, and does not rely on access to any internal states or variables of the Instances. 
The time quality advertised in domain B needs to appropriately reflect the possible degradation of quality in the timing 
received in domain A along the timing path from domain A’s Grandmaster Clock. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
472 
O.4.4.2 Hot-standby Grandmaster transferring time through a secondary domain 
There are specific situations where the single point of failure represented by the Grandmaster Clock needs 
to be eliminated, and the settling times of switching to a holdover-upgradeable PTP Instance (see 16.4) do 
not satisfy the requirements of the use-case. In such a case, a PTP Node with good holdover characteristics 
which recovers the Grandmaster Clock on a primary domain, can be used to distribute this recovered clock 
through a secondary domain, as shown in Figure O.8. Such a PTP Instance can be termed a hot-standby 
Grandmaster, because timing backup information on the secondary domain is always available, even if the 
primary Grandmaster is active. 
 
PTP Port
domain B 
Master State
PTP Port
domain A
Slave State
Source
Adapter B
Sink
Adapter A
Ordinary Clock Instance 
Acting as Grandmaster
In secondary domain B
Ordinary Clock Instance
Acting as Slave
In primary domain A
PTP Hot-Standby Grandmaster Node
Transparent Clock 
active in both 
domain A and B
Transparent Clock 
active in both 
domain A and B
Slave in both 
domain A and 
domain B
Slave in both 
domain A and 
domain B
Grandmaster in 
domain A
domain B timing
 
Figure O.8 Timing transfer of recovered clock through a secondary domain 
Taking as example Figure O.8, after the Slave Clock Instance in domain A locks to domains A’s 
Grandmaster, the timing information is redistributed by the Node’s secondary Grandmaster Clock Instance 
in domain B. This allows Slaves to synchronize to a primary domain and use the secondary domain as a 
hot-standby backup synchronization source, in case the primary one fails or degrades. 
NOTE—This approach requires that Transparent Clocks or Boundary Clocks transport both domains, but it also 
enables more advanced topologies where the two domains can be used to achieve synchronization path redundancy. 
O.4.4.3  Testing the quality of the recovered clock of a Slave or Boundary Clock Instance 
There are cases in which there is a need for better visibility and sampling capabilities for measuring the 
recovered clock of PTP Instance. In such cases, a second PTP Instance, with completely independent 
timing and rate of egress messages can be used to output the recovered clock, as shown in Figure O.9. 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
473 
PTP Port
domain B 
Master State
PTP Port
domain A
Slave State
Source
Adapter B
Sink
Adapter A
PTP Node in test mode
Ordinary Clock Instance 
Acting as Grandmaster
In secondary domain B
Ordinary Clock Instance
Acting as Slave
In primary domain A
PTP Tester
Send timing information on domain A as Grandmaster and compare with received information on domain B
 
Figure O.9 Output of recovered clock via a second PTP Instance 
If the Ordinary Clock or Boundary Clock being measured is connected to a tester device that can compare 
the known timing information on primary domain A to the timing information received back on the 
secondary domain B, the tester can calculate the time error of the recovered clock of the PTP Instance in 
the SLAVE state in domain A.  
NOTE—The Grandmaster PTP Instance in domain B (used for transmitting the recovered clock) can be configured in 
such a way such that it is less resource intensive for the device being tested, for example by setting the PTP Port state 
static, or by changing other settings that do not affect the actual sampling of the recovered clock. If the Grandmaster 
PTP Instance of domain B always outputs the PTP Clock of the domain A, even when domain A is not locked, start-up 
and holdover behavior can be tested. The timing and rate of Sync messages of the Grandmaster PTP Instance can be 
adjusted to improve the sampling as per application dependent needs.  
The domain B Grandmaster PTP Instance can be disabled when not used in a test bench environment. 
O.5 Example use for external configuration of port state 
In some cases, physically disjoint networks are impractical and there is topological overlap of the domains. 
In such cases the option of 17.6 for configuring PTP Port states from outside the domain can be used to 
create maximally disjoint topologies within the constraints presented by the physical connections. In this 
case an external application would learn the connection patterns, for example, via management 
mechanisms, and would first compute the desired topologies for each domain and then set the state of the 
PTP Ports of each domains PTP Instances appropriately. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
