# Annex E  (normative) Transport of PTP over IEEE 802.3 transports

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
387 
Annex E   
(normative)  
Transport of PTP over IEEE 802.3 transports 
E.1 General 
This annex specifies those portions of the PTP standard that are specific to implementations that transport 
messages directly over Ethernet frames as specified in IEEE 802 standards. 
The first octet of the PTP message shall occupy the first octet of the client data field.  
E.2 Ethertype 
Ethertype shall be 88F716.  
E.3 Multicast media access control (MAC) addresses 
By default, PTP messages shall use MAC addresses as specified in 0. 
Table E.1—Multicast MAC addresses 
PTP Message types 
Address (hex) 
All except peer-to-peer delay mechanism messages 
01-1B-19-00-00-00 
Peer-to-peer delay mechanism messages 
01-80-C2-00-00-0E 
The OUI value of 00-1B-19 represents the value assigned to this standard by the IEEE Registration 
Authority27. The MAC address value of 01-1B-19-00-00-00 represents a multicast address derived from the 
pool of multicast addresses within that space. 
The MAC address of 01-80-C2-00-00-0E represents a multicast address derived from the pool of multicast 
addresses administered by IEEE Std 802.1Q. It is permissible, however, to use address 01-1B-19-00-00-00 
or address 01-80-C2-00-00-0E for all PTP messages if such use is defined in the applicable PTP Profile. 
NOTE 1— According to the IEEE 802.1 model, it is always possible to use PTP peer-to-peer delay mechanism 
messages even on ports blocked by Spanning Tree Protocols. 
NOTE 2— Per 8.6.3 of IEEE Std 802.1Q-2014, frames containing 01-80-C2-00-00-0E in their destination address field 
are not relayed by the bridge. Therefore, this address is selected for the peer-to-peer delay mechanism messages 
because the scope of this address is limited to an individual LAN, and this is the normal case of the PTP peer-to-peer 
delay mechanism messages. This address is not assigned exclusively to PTP, but rather it is a shared address. 
Per port, peer-to-peer delay measurements shall use the egress PTP Port’s MAC Address as the source 
MAC Address in PTP peer-to-peer delay mechanism messages. 
                                                 
27 IEEE Registration Authority (https://standards.ieee.org/regauth/). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
388 
E.4 majorSdoId field values  
The majorSdoId field (see 13.3.2.1) shall be interpreted as a subtype of the Ethertype (see Table 2 in 7.1.4). 
If the device recognizes the subtype, then the PTP message is passed to the PTP Instance. If the device does 
not recognize the subtype, then the message is treated as any other message with an unrecognized 
Ethertype. 
E.5 Optional values 
When the Ethernet transport mechanism allows for multiple traffic classes, the highest priority traffic class 
should be used for PTP event messages. 
NOTE—For Ethernet, IEEE Std 802.1Q-2014 discusses the implementation of traffic classes.  
E.6 Protocol addresses 
For any quantity of data type PortAddress (see 5.3.6), when the networkProtocol member value is  
IEEE 802.3 (see 7.4.1): 
 
The addressLength member value shall be 6. 
 
The addressField member value shall be the six octet source address field of the Ethernet header. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
