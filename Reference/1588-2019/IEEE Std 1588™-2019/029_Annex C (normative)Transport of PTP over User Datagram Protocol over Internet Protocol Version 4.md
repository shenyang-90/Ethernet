# Annex C (normative)Transport of PTP over User Datagram Protocol over Internet Protocol Version 4

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
382 
Annex C  
 
(normative) 
 
Transport of PTP over User Datagram Protocol over Internet Protocol 
Version 4 
C.1 General 
This annex specifies those portions of the PTP standard that are specific to implementations that transport 
messages over the User Datagram Protocol (UDP), as defined in IETF RFC 768 (1980), and Internet 
Protocol version 4 (IPv4), as defined in IETF RFC 791 (1981). The specifications in this annex shall apply 
to all PTP implementations using UDP/IPv4 as a communication service.  
The first octet of the PTP message shall immediately follow the final octet of the UDP header. 
The transmitting or intermediate PTP Instance may set the UDP checksum to 0. 
When using this transport with unicast transmission, modifications to PTP event packets by Transparent 
Clocks might corrupt applications that incorrectly use the UDP destination port.  
NOTE—The UDP destination ports in this annex are values assigned to PTP, and no interference is expected to occur. 
However, it is known that some applications in use disregard these assignments. It is these applications that are 
vulnerable to the action of Transparent Clocks. 
C.2 UDP port numbers 
The UDP destination port of a PTP event message shall be 31924.  
The UDP destination port of a multicast PTP general message shall be 320.  
The UDP destination port of a unicast PTP general message that is addressed to a PTP Instance shall be 
320.  
The UDP destination port of a unicast PTP general message that is addressed to a manager shall be the 
UDP source port value of the PTP message to which this is a response.  
C.3 IPv4 multicast addresses 
PTP messages shall use the multicast message specified in Table C.1. 
 
 
 
                                                 
24 
The 
Internet 
Assigned 
Numbers 
Authority 
(IANA) 
assigned 
the 
dedicated 
port 
numbers 
shown 
to 
PTP  
(see http://www.iana.org/assignments/port-numbers/). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
383 
Table C.1 IPv4 multicast addresses 
IANA assigned name25 
PTP Message types 
Address 
PTP-primary 
All except peer-to-peer delay mechanism messages 
224.0.1.129 
PTP-pdelay 
Peer-to-peer delay mechanism messages 
224.0.0.107 
For PTP messages sent to the PTP-pdelay address, the Time to Live (TTL) field shall be set to 1.  
C.4 sdoId field values 
C.4.1 General 
Some Version 2.0 implementations are based on hardware designed for Version 1, “V.1 hardware”. This 
hardware-assisted timestamping, checked the length of the incoming packet before qualifying the 
timestamp, and required the UDP payload of the PTP event messages to be at least 124 octets in length. In 
version 1 hardware the PTP event messages were specified by the controlField (see 13.3.2.13). 
This edition of the standard deprecates implementations based on the V.1 hardware. V.1 hardware 
implementations shall be limited to version 2.0 PTP Nodes. Subclause C.4.2 defines an option, the “version 
1 hardware option”, that may be used by implementations that must be backward compatible with PTP 
Networks containing PTP Nodes or PTP Instances based on V.1 hardware. 
The version 1 hardware option shall not be used with any transport except IPv4, that is, Annex C of this 
standard. 
The support for this option should be included in product specifications.  
C.4.2 Version 1 hardware option 
Operation of this option depends on whether the device is a requestor (see C.4.2.1) or a responder  
(see C.4.2.2) of version 1 hardware support. 
C.4.2.1 Version 1 hardware option—Requestor 
Requestors are version 2.0 PTP Instances only. PTP Instances using V.1 hardware request other PTP 
Instances to transmit padded event messages to the requesting PTP Instance by setting the value of sdoId to 
10016 in all Announce and PTP event messages transmitted from the requesting PTP Instance. Requestors 
support the controlField (see 13.3.2.13).  
NOTE—Implementations based on Annex D of IEEE Std 1588-2008 will interpret the majorSdoId portion of the sdoId 
as the transportSpecific field of that edition; that is, a majorSdoId value of 00016 and 10016 will be interpreted as a 
transportSpecific field value with bit 0 set to 0 or 1, respectively. 
C.4.2.2 Version 1 hardware option—Responder 
Responders are PTP instances conformant to this standard and support the version 1 hardware option. 
                                                 
25 The IANA assigned the dedicated multicast addresses along with the IANA names to PTP. These names appear in the IANA listings 
identifying multicast addresses and names. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
384 
If the responder receives a version 2.0 PTP Announce or event message with the value of sdoId = 10016, it 
shall extend the UDP payload of all PTP event messages transmitted to the requesting PTP Instance by 
adding padding to the end of the PTP event message such that the UDP payload length is equal to or greater 
than 124 octets. The padding octets shall have all bits zero. Such responders shall also support the 
controlField (see 13.3.2.13). 
Padding and controlField support once active shall continue until such time as the transmitting PTP Port 
enters the INITIALIZING state. 
Responders shall transmit all PTP messages as specified in 7.1.4. 
Responders shall disregard the padding octets of a received PTP message. 
C.5 Optional values 
For PTP event messages, the value of the differentiated service field in the type of service field should be 
set to the highest traffic class selector codepoint available. 
NOTE—When the layer 2 transport mechanism allows for multiple priorities, it is recommended that the highest 
priority be used for PTP event messages. 
C.6 IPv4 Options 
IPv4 options shall not be used. 
C.7 Protocol addresses 
For any quantity of data type PortAddress (see 5.3.6), when the networkProtocol member value is 
UDP/IPv4 (see 7.4.1), the addressLength member value shall be 4. 
The addressField member value shall be the IPv4 address of the port represented as four groups of two 
hexadecimal digits. For example, the IPv4 address 203.0.113.235 expressed in the usual text notation 
appears as the octet array CB0071EB16. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
