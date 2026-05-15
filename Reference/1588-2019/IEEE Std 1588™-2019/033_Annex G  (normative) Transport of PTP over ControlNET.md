# Annex G  (normative) Transport of PTP over ControlNET

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
391 
Annex G   
(normative)  
Transport of PTP over ControlNET 
G.1 Protocol 
This annex specifies those portions of the PTP standard that are specific to ControlNet implementations. 
The specifications in this annex shall apply to all PTP implementations using ControlNet as a 
communication network. For additional information on ControlNet, consult the ControlNet specification 
provided by ControlNet International.29 
NOTE—ControlNet is also covered by IEC 61158 type 2 elements. 
G.2 clockIdentity  
The clockIdentity for a ControlNet PTP Node shall be as specified in 7.5.2.2.2. 
G.3 PTP message formats 
PTP messages are transmitted with the most significant byte of a data type transmitted first followed 
sequentially by bytes in order of decreasing significance. The first octet of the PTP message shall 
immediately follow the final octet of the ControlNet LPacket header. 
G.4 ControlNet addressing for PTP 
The Destination address field for a PTP LPacket shall be 255(FF16) (Broadcast).  
The Fixed Tag field for a PTP LPacket shall be 141 (8D16) for event messages and 142(8E16) for general 
messages.  
For any quantity of data type PortAddress (see 5.3.6), when the networkProtocol member value is 
ControlNet (see 7.4.1): 
 
The addressLength member value shall be 2. 
 
The addressField member value shall be the ControlNet PTP Instance number of the device.  
                                                 
29 ControlNet (http://www.controlnet.org/). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
