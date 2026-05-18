# Annex F  (normative) Transport of PTP over DeviceNET

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
389 
Annex F   
(normative)  
Transport of PTP over DeviceNET 
F.1 Protocol  
This annex specifies those portions of the PTP standard that are specific to DeviceNet implementations. 
The specifications in this annex shall apply to all PTP implementations using DeviceNet as a 
communication network. For additional information on DeviceNet, consult the DeviceNet specification 
provided by ODVA.28 
NOTE—DeviceNet is also covered by IEC 62026-3:2008. 
F.2 message timestamp point 
The message timestamp point (see 7.3.4.1) shall correspond to the trailing edge of the sixth bit of the end of 
frame field of the first fragmented packet of a PTP event message as shown in Figure F.1. 
Clk
Ack
End of Frame
Interframe
Bus
CAN  frame field
CAN Bit Sync
Timestamp Point
End of Frame
End of Frame
0x01
0x00
0x00
CAN frame bit
0x06
0x05
0x06
End of Frame
 
Figure F.1 message timestamp point 
F.3 clockIdentity  
The clockIdentity for a DeviceNet PTP Node shall be as specified in 7.5.2.2.2. 
F.4 PTP message formats 
PTP messages are transmitted with the most significant byte of a data type transmitted first followed 
sequentially by bytes in order of decreasing significance. The first octet of the PTP message shall 
immediately follow the final octet of the DeviceNet header. 
 
                                                 
28 Open DeviceNet Vendors Association (http://www.odva.org/). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
390 
These data are sent using multiple DeviceNet packets (frames) following the standard DeviceNet Explicit 
Message fragmentation logic. All PTP messages are fragmented on DeviceNet. The DeviceNet header is 
present in all packets. 
DeviceNet headers for all PTP message packets are specified in Table F.1. This header is present in each 
DeviceNet frame of the PTP message. 
Table F.1 DeviceNet headers for all PTP message packets 
Octet 
0 
Octet 
1 
Octet 
2 
Type 
(informative) 
Field name 
h0h1 
j0j1 
k0k1 
octet | 
octet | 
octet 
Fragment = 1, XID = 0, Source MACID | 
Fragment Type, Fragment Count | 
R/R = 1, Service Code = UCMM Service Code 
F.5 DeviceNet addressing for PTP 
All PTP messages shall be transmitted by an UnConnect Message Manager (UCMM) capable device as an 
Unconnected Response Message (Message Group 3, Message ID 5) and by a Group 2 Only server as an 
Unconnected Response Message (Message Group 2, Message ID 3). Thus, each PTP Instance on the subnet 
has its own unique multicast address [Controller Area Network (CAN) identifier]. The same multicast 
address is used for all Domains. 
All PTP messages shall have the Request/Response bit in the DeviceNet header set to TRUE. 
The PTP multicast addresses are shared with other DeviceNet functions, some of which are point-to-point 
messages. To distinguish a PTP message, the transmitting PTP Instance shall place its own PTP Instance 
address in the Destination Node field of the DeviceNet message header. The message is then further 
identified as a PTP message by the UCMM service code.  
The UCMM service code field shall be 88 (5816) for the event class of messages and 89 (5916) for the 
General class of messages. 
For any quantity of data type PortAddress (see 5.3.6), when the networkProtocol member value is 
DeviceNet (see 7.4.1): 
 The addressLength member value shall be 2. 
 The addressField member value shall be the DeviceNet mac ID. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
