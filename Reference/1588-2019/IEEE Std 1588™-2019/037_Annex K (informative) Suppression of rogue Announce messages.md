# Annex K (informative) Suppression of rogue Announce messages

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
419 
Annex K  
(informative)  
Suppression of rogue Announce messages 
It is known both from simulation and practice that rogue Announce messages can occur  
(Broman et al. [B4]; Wang et al. [B55]). The standard provides several mechanisms for suppressing rogue 
Announce messages. Rogue Announce messages are PTP Announce messages that can circulate out-of-
date information endlessly in a loop. These messages typically contain information used by the BMCA but 
characterize a Grandmaster PTP Instance that no longer exists in the network, either due to removal of the 
Grandmaster PTP Instance or the degradation of its attributes. Rogue Announce messages are indicated by 
an ever increasing value of the stepsRemoved field within the messages. The value of stepsRemoved 
observed at a PTP Instance in such a loop will increase, on each pass, by the number of Boundary Clocks in 
the loop. Such a situation is unstable in the sense that until the rogue frame is eliminated, the BMCA does 
not converge to a unique selection of the Grandmaster PTP Instance. Rather, the BMCA of a Boundary 
Clock in the loop, upon receiving a rogue Announce message, will determine that the attributes of the rogue 
frame are such that the ingress PTP Port enters the SLAVE state, and additional rogue Announce messages 
are regenerated on PTP Ports in the MASTER state but with the stepsRemoved field incremented. The 
reason for the ingress PTP Port entering the SLAVE state is that the attributes of the rogue frame 
characterize the now nonexistent Grandmaster PTP Instance, which by definition was better than any of the 
other PTP Instances in the domain. 
This annex elaborates on the mechanisms in the standard designed to eliminate rogue Announce messages. 
Subclause 9.2.6.11 specifies the behavior of the PRE_MASTER state. This feature will eliminate rogue 
Announce messages in some circumstances. There are two disadvantages to this scheme: Namely, it helps 
but does not guarantee elimination of rogue Announce messages, and it introduces considerable delay in 
reconfiguring systems in the event of a change in the Grandmaster Clock or topology. 
The path trace mechanism specified in 16.2 is an optional method that can be used to eliminate rogue 
Announce messages. This mechanism is based on appended TLVs containing a list of the clockIdentities of 
the Boundary Clocks traversed by a PTP frame. If a PTP Instance receives a TLV that contains the PTP 
Instance’s own clockIdentity as a member of the list, then the frame is discarded. This technique is the most 
efficient in eliminating rogue Announce messages because it becomes operative on the first pass around a 
loop. In addition, it does not disrupt long chains of Boundary Clocks. However, all PTP Instances in a path 
need to accept, modify, and pass on the TLV for the method to work, thereby ruling out the presence of 
PTP Instances that do not implement the option. In addition, the clockIdentity of a PTP Instance is not 
appended to the TLV if that would cause the frame containing the transmitted Announce message to exceed 
the maximum frame size. This results in rogue frames not being detected and eliminated by this feature, in 
loops larger than a certain size.  
Subclause 9.3.2.5 specifies that Announce messages where the stepsRemoved field value of the Announce 
message is greater than or equal to the lesser of 255 or the value of an optional configurable variable 
defaultDS.maxStepsRemoved are to be discarded and not considered as part of the BMCA operation. The 
fixed value of 255 provides a last resort limit that will always work. The ability to configure a lesser value 
allows system designers to reduce the time required to eliminate the rogue Announce messages. The 
features specified in 9.3.2.5 have the advantage that they work in any topology. 
The selection of appropriate values for defaultDS.maxStepsRemoved is critical. The following two 
principal considerations assist in selecting the appropriate values: 
a) 
Ensuring that rogue Announce messages circulating in a loop are eliminated with minimal delay, 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
420 
b) 
Ensuring that the selected value does not prevent legitimate Announce messages from reaching 
other PTP Instances in the PTP Network 
The following examples illustrate these considerations for several common situations. These examples are 
not an exhaustive list of all the possible topological situations but are intended to illustrate some of the 
more subtle details to consider. 
K.1 Example—Star topology 
In Figure K.1, Assume BC-A is the Grandmaster PTP Instance. Announce messages from BC-A propagate 
down each of the three legs eventually reaching PTP Instances BC-D, BC-I, and BC-M, respectively. The 
values of stepsRemoved in the Announce messages reaching these PTP Instances are 2, 4, and 3, 
respectively. While rogue Announce messages are not expected in this topology, any PTP Network uniform 
value of defaultDS.maxStepsRemoved needs to clearly be at least 5.  
However, suppose that instead of the Grandmaster PTP Instance being PTP Instance BC-A the 
Grandmaster PTP Instance is PTP Instance BC-I. In this case, Announce messages from BC-I would arrive 
at PTP Instances BC-D and BC-M with stepsRemoved values of 7 and 8, respectively. Therefore, the 
minimum PTP Network uniform value selected for defaultDS.maxStepsRemoved needs to be at least 9. 
Rogue Announce messages in star topologies are not expected, and therefore configuration of the attribute 
defaultDS.maxStepsRemoved is not required. However, the considerations discussed in this example need 
to be examined in topologies containing loops to ensure that the ability of Announce messages to reach all 
PTP Instances in the PTP Network is not compromised as discussed in subsequent examples. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
421 
BC-A
BC-E
BC-B
BC-C
BC-D
BC-F
BC-J
BC-G
BC-H
BC-K
BC-L
BC-I
BC-M
 
Figure K.1 Star topology 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
422 
K.2 Example—PTP Network with a single loop with an odd number of PTP 
Instances in the loop 
In Figure K.2, when the Grandmaster PTP Instance is BC-A, the BMCA will break the loop at one of the 
PTP Ports of BC-F, for example, between PTP Instances BC-E and BC-F as indicated by the dashed line. If 
BC-A is disconnected from the PTP Network, or if its attributes such as clockClass are degraded, it is 
known that rogue Announce messages can be generated, which circulate endlessly around the loop with the 
value of stepsRemoved increasing by 7 with each traversal of the loop. In this topology, a value for 
defaultDS.maxStepsRemoved of at least 7 ensures that, irrespective of link failure or the PTP Instance 
selected as the Grandmaster PTP Instance, Announce messages can reach all other connected PTP 
Instances that require receipt in order to correctly execute the BMCA, and that rogue frames will be deleted 
as soon as possible.  
For further illustration, note that the value 7 is minimal in the case where we want to accommodate a 
possible link failure between BC-B and either BC-H or BC-C. If we exclude the possibility of link failures, 
then a value of 5 can be used since then the maximum number of Boundary Clocks between any PTP 
Instances and a potential Grandmaster PTP Instance is 4 due to the loop breaking mechanism of the 
BMCA.  
GM
BC-A
BC-B
BC-H
BC-E
BC-C
BC-G
BC-D
BC-F
 
Figure K.2 Single loop topology 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
423 
K.3 Example—More complex single loop PTP Network 
The PTP Network example shown in Figure K.3 is similar to the PTP Network of example K.2 but with 
additional Boundary Clocks. The considerations are similar to the previous case but the addition of BC-I 
and BC-J means that the selected values of defaultDS.maxStepsRemoved need to be incremented by 2 to 
account for the additional Boundary Clocks in the PTP Network. 
GM
BC-A
BC-B
BC-H
BC-E
BC-C
BC-G
BC-D
BC-F
BC-I
BC-J
 
Figure K.3 More complex single loop PTP Network 
K.4 Example—Linear chain 
The upper diagram in Figure K.4 illustrates a chain of Boundary Clocks. Boundary Clocks BC-C and BC-F 
are linked to GPS receivers and therefore have clockClass 6. Assuming the other BMCA relevant attributes 
are identical the chain will be broken as shown by the dashed line by virtue of BC-C having a greater 
clockIdentity than BC-F. The chain is broken into two segregated domains, one with the Grandmaster PTP 
Instance being BC-F and the other with BC-C. This configuration will be achieved provided a PTP 
Network uniform value of defaultDS.maxStepsRemoved is at least 3 thereby permitting Announce message 
from BC-C and BC-F to reach each other during the reconfiguration or startup transient. 
In the lower figure, Boundary Clock BC-C has lost contact with the GPS receiver, is out of any holdover 
specification, and has degraded its clockClass to 187. The BMCA results in the topology shown with BC-F 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
424 
the Grandmaster Clock for the entire chain. However, this only can occur if the value of 
defaultDS.maxStepsRemoved used in BC-A is at least 5 and with similarly appropriate values for the other 
PTP Instances in the chain. 
A comparison of these two cases illustrates that great care needs to be exercised in determining the 
appropriate value for defaultDS.maxStepsRemoved. 
BC-A
BC-B
BC-C
BC-D
BC-E
BC-F
clockClass 6
identity 2
clockClass 6
identity 1
BC-A
BC-B
BC-C
BC-D
BC-E
BC-F
clockClass 187
identity 2
clockClass 6
identity 1
 
Figure K.4 Linear chain of Boundary Clocks 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
