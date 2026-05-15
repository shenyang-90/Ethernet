# Annex D  (normative) Transport of PTP over User Datagram Protocol over Internet Protocol Version 6

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
385 
Annex D   
 
(normative)  
 
Transport of PTP over User Datagram Protocol over Internet Protocol 
Version 6 
D.1 General 
This annex specifies those portions of the PTP standard that are specific to implementations that transport 
messages over the User Datagram Protocol (UDP), as defined in IETF RFC 768 (1980), and Internet 
Protocol version 6 (IPv6), as defined in IETF RFC 8200 (2017). The specifications in this annex shall apply 
to all PTP implementations using UDP/IPv6 as a communication service.  
The first octet of the PTP message shall immediately follow the final octet of the UDP header.  
A transmitting PTP Instance shall extend the UDP payload of all PTP messages by two octets beyond the 
end of the PTP message. The contents of the UDP checksum field or the final two octets of the UDP 
payload may be modified by the initiator or an intermediate PTP Instance to ensure that the UDP checksum 
remains uncompromised after any modification of PTP fields. This modification to update the UDP 
checksum may be implemented using the mechanism defined in IETF RFC 1624 (1994). Other than for 
purposes of calculating the UDP checksum, the contents of the UDP field beyond the end of the PTP fields 
shall be ignored by the receiver. 
D.2 UDP port numbers 
The UDP destination port value of an PTP event message shall be 31926.  
The UDP destination port value of a multicast PTP general message shall be 320. 
The UDP destination port value of a unicast PTP general message that is addressed to a PTP Instance shall 
be 320.  
The UDP destination port value of a unicast PTP general message that is addressed to a manager shall be 
the UDP source port value of the PTP message to which this is a response.  
                                                 
26 The Internet Assigned Numbers Authority (IANA) assigned the dedicated port numbers shown to PTP (see 
http://www.iana.org/assignments/port-numbers/). 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
386 
D.3 IPv6 multicast addresses  
PTP messages shall use the multicast addresses in Table D.1. 
Table D.1 —IPv6 multicast addresses 
IANA assigned name 
PTP Message types 
Address (hex) 
PTP-primary 
All except peer-to-peer delay 
mechanism messages 
FF0X:0:0:0:0:0:0:181; see NOTE 
PTP-pdelay 
Peer-to-peer 
delay 
mechanism 
messages 
FF02:0:0:0:0:0:0:6B 
NOTE—The hexadecimal values for “X” in the PTP-primary address are defined in IETF RFC 4291 (2006) [B15]. 
These are as follows: 
         0  reserved 
         1  Interface-Local scope 
         2  Link-Local scope 
         3  reserved 
         4  Admin-Local scope 
         5  Site-Local scope 
         6  (unassigned) 
         7  (unassigned) 
         8  Organization-Local scope 
         9  (unassigned) 
         A  (unassigned) 
         B  (unassigned) 
         C  (unassigned) 
         D  (unassigned) 
         E  Global scope 
         F  reserved 
For PTP messages sent to the PTP-pdelay address, the Hop Limit (HL) field shall be set to 1.  
D.4 Optional values 
For PTP event messages, the value of the Differentiated Service (DS) field in the Traffic Class (TC) field 
should be set to the highest traffic class selector codepoint available. 
NOTE 1— When the layer 2 transport mechanism allows for multiple priorities, the highest priority preferably is used 
for PTP event messages. 
NOTE 2— The use of IPv6 Extension Headers is outside the scope of this standard. 
D.5 Protocol addresses 
For any quantity of data type PortAddress (see 5.3.6), when the networkProtocol member value is 
UDP/IPv6 (see 7.4.1): 
 
The addressLength member value shall be 16. 
 
The addressField member value shall be the IPv6 address of the port represented as 16  
groups 
of 
two 
hexadecimal 
digits. 
For 
example, 
the 
IPv6 
address 
2001:0DB8:85A3:08D3:1332:8A2E:0270:7225 expressed in the usual text notation per  
IETF RFC 4291 (2006) [B15] appear as the octet array 20010DB885A308D313328A2E02707225. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
