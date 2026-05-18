# Annex P (informative)Security 

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
474 
Annex P  
(informative) 
Security  
P.1 Overview, assumptions, and approach 
The IEEE 1588 security approach addresses the risks, threats, and vulnerabilities associated with this 
standard. A detailed analysis of security threats and the resulting security requirements for clock 
synchronization protocols was developed in RFC 7384 [B39]. The IEEE 1588 security approach leverages 
this analysis and provides a multipronged approach that addresses those requirements. This approach 
allows for flexible implementation, configuration, and deployment options. Characteristics of the approach 
include the following: 
 
The security approach and mechanisms utilized by this standard vary by both industry (profile) and 
specific application. This approach is based on analysis of the threats and deployment paradigms 
for the particular application.  
 
The security approach includes a set of mechanisms that can be used individually or in concert to 
achieve the security objectives of the particular deployment.  
 
An individual mechanism might not be applicable for all applications.  
 
The security approach includes protocol-inherent means as well as protocol-agnostic means. This 
approach is described via different security prongs for the different security mechanisms available. 
 
A security key management scheme providing the necessary key material for the security services 
is necessary. Two examples of automated key management schemes are discussed in the context of 
this specification, one for immediate security verification (GDOI) and one for delayed security 
verification (TESLA). However, the detailed specification of these key management schemes is 
outside the scope of this document.  
 
Architectural and management options specified in this standard can also be used to address certain 
security requirements, and those options will be identified in this annex.  
P.2 Multipronged approach—detailed definition 
The IEEE 1588 security model is a multipronged approach, resulting in a set of security mechanisms and 
configuration options that meet various security objectives. This subclause discusses the individual prongs.  
P.2.1 PTP integrated security mechanism (prong A) 
P.2.1.1 General 
Subclause 16.14 describes an IEEE 1588 integrated security mechanism based on an AUTHENTICATION 
TLV in conjunction with either an immediate or delayed security processing. As outlined in 16.14, the 
following are specified: 
 
Immediate security processing enables the processing of the AUTHENTICATION TLV before the 
content of the PTP message is further processed. This requires that the involved PTP Instances 
share the security parameters needed for the calculation of the ICV. The ICV is a field in the 
AUTHENTICATION TLV. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
475 
 
Delayed security processing enables delayed distribution of all security parameters or a subset of 
them (at least the secret key). In this case only the originating PTP Instances possess all the security 
parameters needed for creating the ICV as a sender. With the exception of mutable fields, other 
PTP Instances cannot change the PTP messages. The correctionField is handled as mutable field, 
and therefore is treated as having a value of 0 during the ICV calculation. 
P.2.1.2 Key management options 
The content of the AUTHENTICATION TLV, defined in 16.14, is provided by the originating PTP 
Instance. The content depends on the chosen key management approach in terms of specific fields 
provided. Also, in case of immediate security processing, the ICV will be recalculated by PTP Instances 
that retransmit the PTP message that contains the TLV.  
The following assumptions were made in relation to the definition of the AUTHENTICATION TLV in 
16.14: 
 
The initial key management uses a separate mechanism outside the context of PTP to distribute a 
group key (for immediate security processing) or a trust anchor (for delayed security processing) 
from an authoritative entity (the issuer of the key) to the participating entity (the recipient of the 
key). This mechanism can be a manual key management or an automated key management. In case 
of an automated key management the authoritative entity can be centralized or collocated with one 
of the group members.  
 
Key management typically has an associated security policy describing key management related 
information such as key validity period or the key update interval, etc. The security policy is 
communicated as part of the key management and not as part of the AUTHENTICATION TLV.  
Note that in the case of manual key management, all values contained in a security association need to be 
provided out of band. This manual key management approach might not scale for larger groups and also 
might limit key update options. 
As specified in 16.14.2, the key management provides the information to enable the calculation of the ICV, 
and this constitutes the security association for the session. 
Immediate and delayed security processing can be used in a complementary manner by attaching two 
AUTHENTICATION TLVs. One AUTHENTICATION TLV would be used for authenticating the PTP 
message sent by the originator, and a second AUTHENTICATION TLV would be used for protecting the 
mutable fields. An example is a Transparent Clock updating the correctionField. In this case, the immutable 
parts of the PTP message from the PTP Port in the MASTER state are authenticated using delayed security 
processing, while the whole message, including possible updates of the correctionField, or other mutable 
fields by Transparent Clocks, are authenticated using immediate security processing. 
P.2.1.2.1 Key management for immediate security processing  
Immediate security processing can be supported in general by utilizing a group-based key management. As 
the security parameter and the group key typically will be distributed upfront (pre-PTP message-processing 
key sharing) from an authoritative entity, it can directly be applied to protect or validate a PTP message 
(on-the-fly processing). Note that utilizing a shared group key hinders the identification of a single 
misbehaving group member. The trust between the group members is transitive; hence all group members 
are equally trusted. 
An example for such a group based key management protocol is the Group Domain Of Interpretation 
(GDOI) method defined in IETF RFC 6407 [B56]. It supports the distribution of a symmetric group key 
(i.e., a Traffic Encryption Key—TEK) to all preconfigured or otherwise enrolled PTP Instances. This 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
476 
method requires a Key Distribution Center (KDC), which is the authoritative entity responsible for 
distributing symmetric session keys and security policy parameters to the involved PTP Instances. GDOI 
uses point-to-point communications between the KDC and each member of the group to distribute the 
symmetric group keys. The group key is distributed after successful authentication of the group members. 
The group key itself is then applied in ICV calculation of PTP messages within the specific group. A KDC 
failure will disrupt key updates, which might influence the group communication, so KDC redundancy is 
imperative.  
Note that the GDOI specification (RFC 6407) defines the distribution of group keys for application in IPsec 
with either AH or ESP mode as the target security protocol. Nevertheless, GDOI can also be applied to 
other target protocols, but in this case, requires the definition of the security association payload.  
An example is provided by the application of GDOI in the power systems environment  
(see IETF RFC 8052 [B24]), which has been specified in IEC TC57 WG15 to protect GOOSE (Generic 
Object Oriented Substation Events) and SV (Sampled Values) communication over wide area networks in  
IEC 61850-90-5 [B7]. For substation internal communication the approach is currently specified in  
IEC 62351-6 [B8] (key application) and IEC 62351-9 [B9] (key distribution). Within the IETF there are 
currently efforts to define specific security association payloads for the new target protocol. 
For PTP, a similar effort is needed to define the security association payload providing the necessary 
parameter and security policy to be applied in the AUTHENTICATION TLV processing.  
The general approach of GDOI and the interaction between the entities and the KDC is depicted in  
Figure P.1 and requires the definition of the IEEE 1588 specific security association payload. 
PTP Instance A
Key Distribution Center (KDC)
•Pre-configured PTP Instance access 
list sharing the same security policy, 
(belonging to a security domain) 
identified by a group ID
•Generates (group) keys
•May be realized as component in a 
network node which includes a PTP 
Instance 
SUBSCRIBE – A authenticates and 
applies for membership in specific group
PTP Instance B
Group
SUBSCRIBE – B authenticates and applies 
for membership in specific group
PUBLISH -After successful authentication of A, the KDC 
sends the specific group parameters for the SA to A
PUBLISH – After successful authentication of B, 
the KDC sends the specific group parameters for 
the SA to B
KDC
PTP Data exchange 
secured using Key 
with keyID for 
calculating the ICV 
in the 
AUTHENTICATION 
TLV
 
Figure P.1 —GDOI based key management—general approach 
Figure P.1 shows the general application of GDOI for group key distribution to support immediate security 
processing in PTP security prong A. As stated earlier, to be directly used, the associated payload for 
distribution of the PTP specific keys has to be defined. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
477 
The set of security parameters listed in 16.14.2 is expected to be provided by the security policy payload of 
the group key management protocol. As stated above, the definition of the security payload for GDOI for 
supporting this standard is expected to be done in the IETF. 
P.2.1.2.2 Key management for delayed security processing 
The TESLA method defined in IETF RFC 4082 [B46] is applied as a scheme using delayed security 
processing. The general approach for TESLA is illustrated in Figure P.2, and the general setup is shown in 
Figure P.3. It enables a receiver of a message to validate its integrity and to authenticate its source. The 
TESLA scheme results in the distribution of a source authentication key. The key is distributed to enable 
delayed verification of PTP message integrity between a PTP Instance and the members of its associated 
group. The trust relationship here is different from immediate security processing as TESLA aims to 
provide authentication of a Master PTP Instance without the need to share the key that is actively being 
used to generate AUTHENTICATION TLVs. As a consequence, another PTP Instance cannot impersonate 
a PTP Instance actively using that specific key. For example, a slave instance cannot impersonate a GM. 
Usage of TESLA precludes protection of mutable fields like the correctionField because only the PTP 
Instance originating the PTP messages knows the current valid key. After disclosure, a key is no longer 
used to generate ICVs. As the key is shared in a delayed fashion and is not used after disclosure, the sender 
of PTP messages can be clearly identified.  
TESLA aims to enable PTP Instances to authenticate the source of PTP messages originating from Master 
PTP Instances. PTP messages originating from a PTP Port in the SLAVE state (Delay_Req, Pdelay_Req, 
Pdelay_Resp) are preferably protected by applying the immediate security scheme described in P.2.1.2.1 
for those PTP messages.  
Note that in general TESLA could also be applied to provide strong source authentication for PTP 
messages originating from any PTP Instances. This would require every PTP Instance to act not only as a 
receiver of TESLA secured messages but also as a sender of TESLA secured messages, thus increasing the 
resulting complexity compared to the combined approach of delayed and immediate security processing. 
TESLA uses a one-way chain of keys, where each key is the output of a one-way function applied to the 
previous key in the chain. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
478 
PTP Instance
Master PTP
PTP Message (X{363} used for ICV)
Secret Start Value: X{0}
Hash-Chain-Anchor: X{364}
X{0}
X{1}
X{2}
…
X{361}
X{362}
X{363}
X{364}
Start 
Day 363
Day 362
Day 3
Day 2
Day 1
Hash-
Value        
Chain-Anchor
Timeline (Days)
X{0} is the Secret Start Value
X{1} = Hash(X{0})
X{2} = Hash(X{1})
…
X{364} = Hash(X{363})   
X{364} is the Hash-Chain-Anchor signed by the Master Clock
Release X{363}
Distribute X{364}
Verify signature of X{364}, 
Store X{364} for later 
verifications disclosed keys
...
Verifies if X{363} = h(X{364})
If yes: Store X{363}
Verify stored packets
Store packet
PTP Message (X{362} used for ICV)
Release X{362}
...
...
Verifies if X{362} = h(X{363})
If yes: Store X{362}
Verify stored packets
Store packet
 
Figure P.2 —TESLA key application—general approach 
 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
479 
Role: 
Master
KDC
Role: 
Slave
PTP messages 
secured with 
Tesla
Transmits TESLA data
Request (authentication and 
authorization are checked)
Contains ID of desired master
Response: TESLA data as 
appropriate for a TESLA 
slave
Request (authentication and 
authorization are checked)
 
Figure P.3 —TESLA—general setup 
All PTP Instances relying on the source authentication of TESLA securely obtain the last element of the 
key chain from the authoritative entity. Time is split into intervals of uniform duration and each key is 
assigned to an interval in reverse order. Figure P.2 is an example that illustrates the chain of messages and 
does not illustrate the calculation of the ICV. It shows a key validity time of 1 day and a key chain that 
provides the values for one year. In the example shown, the authoritative entity is co-located with the 
Master PTP Instance to provide the anchor value of the key chain. The authoritative entity generates the 
key chain starting from the initial value X0 (a random number). X0 is hashed to X1, which in turn is hashed 
again. This process is continued until X364, which constitutes the trust anchor for the key chain. This value 
is provided by the Master PTP Instance in a digitally signed form. Through the digital signature, a 
verification of the authenticity of the anchor value is possible. At each time interval, multicast packets send 
by a Master PTP Instance include an ICV, which is calculated using the key corresponding to the current 
time interval, and the key of the previous disclosure interval as necessary. The receiving PTP Instance 
verifies the ICV by buffering the packet until disclosure of the key in its associated disclosure interval 
occurs. In the example in Figure P.2, each period is connected with one specific key, day 1 for instance 
with the key X363. When the validity period of this key has ended, and the value of the disclosure interval 
equals 1, the key will be disclosed by the Master PTP in the AUTHENTICATION TLV. All PTP Instances 
receiving the disclosed key can verify its authenticity by hashing it once, which results in the value X364, 
which was distributed in a signed form. If the result is different an error occurred and an alert message 
preferably is generated.  
TESLA requires a bootstrapping phase for the necessary security parameter for the sender (Master PTP 
Instance) and the receivers (other PTP Instances). This parameter distribution can be achieved as follows:  
 
By manual configuration  
 
By utilizing Multimedia Internet Keying (MIKEY) as specified in IETF RFC 4442 [B17].  
 
By utilizing the GDOI, IETF RFC 6407 [B56], with the same assumptions regarding the definition 
of the security association data payloads for TESLA as in GDOI. As for the immediate security 
processing, it is expected that this definition will be created in the IETF. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
480 
In the automated case, it is assumed that each PTP Instance is authenticated to a central instance, for 
example, the Key Distribution Center (KDC) for immediate security processing and will receive the values 
necessary to bootstrap TESLA as displayed in Figure P.2. 
P.2.1.2.2.1 KDC setup 
The KDC divides time into uniform time intervals T_Int as displayed in Figure P.2. It determines the 
number n+1 of keys in the one-way key chain X{0}, …, X{n}. This results in n keys that are usable to 
authenticate multicast packets. The key chain is calculated as follows: 
 
The KDC entity chooses a random value for X0. 
 
It recursively constructs the key chain X{i+1} = F(X{i}), where F is a pseudo random function 
(typically a hash function). 
 
The last key X{n} serves as the trust anchor. 
 
From each key in the key chain, it derives an associated key X'{i} by X'{i} = F'(X{i}), where F' is 
also a pseudo random function. The associated key X'{i} is used for the calculation of the ICV. 
This approach ensures that the verification of the affiliation of a disclosed key to the key chain and 
the computation of the ICV is not done with the same key (see IETF RFC 4082 [B46], Sec. 3.4). 
 
The sender determines the value of the key disclosure delay (disclosureDelay). 
The sender (Master PTP Instance) receives the following values from the KDC: 
 
The duration of the time interval T_Int  
 
The number of time intervals n 
 
The starting time of the first time interval 
 
The disclosure delay 
 
The identifier for the pseudo random functions F and Fˊ 
 
The value of the trust anchor X{n} 
Receiver (Ordinary PTP Instance) setup: 
 
The receiver needs an upper bound D_t of the network delay between its own clock and the 
sender’s clock. A receiver can determine the network delay by means of PTP.  
 
The receiver obtains the trust anchor X{n} from the KDC. 
 
The receiver obtains the values T_Int, the number of time intervals n, the starting time of the first 
time interval and the disclosure delay from the KDC. 
The exchanged data are locally stored in the SAD. If the key chain is depleted the sender has to re-initiate 
the TESLA parameters and has to update the KDC accordingly. The receivers have to request a new set of 
TESLA parameters.  
P.2.1.2.2.2 Initial time synchronization 
TESLA requires loose time synchronization between sender and receiver to enable the receiver of messages 
to verify the timeliness of received messages. For details, see IETF RFC 4082 [B46]. The initial time 
synchronization can be established by various means, for example, by running PTP secured via GDOI. 
A detailed description of the requirements during the bootstrapping phase can be read in  
IETF RFC 4082 [B46]. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
481 
P.2.1.2.2.3 Values of the SecurityTLV specific to TESLA 
Table P.1 describes how TESLA employs the fields of the AUTHENTICATION TLV that are specific to 
delayed security processing. 
Table P.1 TESLA security fields 
Field 
Length in Octets 
KeyID: indicates the current time interval I_K 
4 
disclosedKey: If not empty the key of the time interval, which results from the value 
of the current time interval minus the value of the disclosure delay 
D  
(see Table 131) 
The following values are exchanged during key management protocol specific to TESLA: 
 
Key: the last key X{n} of the key chain. This key serves as TESLA trust anchor 
 
Pseudo random function identifier for F and Fˊ 
 
keyLength: length of the output of the pseudo random function Fˊ 
 
disclosureDelay: Indicates the number of time interval after which a key is disclosed 
 
chainLength: indicates the length of the key chain and the number of time intervals 
 
Starting time of the first time interval 
 
intervalDuration: indicates the length of a time interval in milliseconds 
P.2.2 PTP external transport security mechanisms (prong B)  
Prong B addresses security mechanisms that are external to PTP but that can be utilized to address some of 
the security requirements for PTP. This section describes two such mechanisms: MACsec at Layer 2 and 
IPsec at Layer 3.  
The MACsec-based solution provides link layer based security enabling authentication of PTP messages 
modified in a Transparent Clock.  
The IPsec-based solution provides security for PTP communications between two PTP Ports across an IP 
based transport. This is particularly useful for profiles such as ITU-T G.8265.1 [B35] that do not rely on 
Boundary Clocks or Transparent Clocks as intermediate nodes between the Grandmaster PTP Instance and 
the final PTP Instance, however, as described in P.2.2.2, it can also be applied in networks which include 
Boundary Clocks and Transparent Clocks. PTP messages can use a dedicated IPsec tunnel or be sent in a 
tunnel used for other traffic types (the accuracy might be lower in the latter case).  
The following two assumptions are made regarding the environments that these types of solutions will be 
deployed in:  
 
MACsec or IPsec is already supported as a general security mechanism in the PTP Node and will 
be used for all messages including PTP messages.  
 
The security key handling required for these mechanisms is part of the general security 
infrastructure and is outside the scope of PTP.  
P.2.2.1 MACsec 
This subclause describes how MACsec (IEEE Std 802.1AE [B10]) can be used as a security mechanism for 
PTP.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
482 
PTP can be run over MACsec in a Layer 2 Local Area Network (LAN). Potential use cases include power 
substation networks and IEEE 802.1 AVB/TSN networks. The following assumptions apply to the MACsec 
guidance:  
 
The MACsec standard is a port-based model in which all traffic is secured. Thus, it is assumed that 
PTP is secured, alongside with all the rest of the traffic. 
 
PTP Instances will be receiving PTP messages in plaintext.  
 
MACsec requires manual configuration of keys or, for ease of operation and increased protection, a 
key agreement protocol such as that defined by IEEE Std 802.1X-2010 [B11]. Operation of the key 
management protocol is out of scope for this document, but it is assumed that the MACsec Key 
Agreement (MKA) [IEEE802.1X-2010] is used as mandated by IEEE Std 802.1AE-2006 [B10]. 
 
MACsec can be used on point-to-point LANs, such as copper cable and optical fibers, and on 
shared media LANs, such as IEEE 802.11 Wireless LAN and IEEE 802.3 Ethernet Passive Optical 
Network (EPON). This subclause focuses on point-to-point LANs only.  
P.2.2.1.1 MACsec operation in bridged and routed networks 
MACsec can be applied to Layer-2 bridged networks as well as Layer-3 routed networks. Figure P.4 
illustrates both. Figure P.5 illustrates the same networks with MACsec applied. 
Higher layer functions
MAC
PHY
Bridge
Higher layer functions
MAC
PHY
Bridge
Higher layer functions
L3 
interface
PHY
Route
Higher layer functions
MAC
PHY
Route
MAC
L3 
interface
 
Figure P.4 —Point-to-point LAN in a Layer-2 bridged and Layer-3 routed network 
Higher layer functions
MAC
PHY
Bridge
Higher layer functions
MAC
PHY
Bridge
Higher layer functions
L3 
interface
PHY
Route
Higher layer functions
MAC
PHY
Route
MAC
L3 
interface
MACsec
MACsec
MACsec
MACsec
Secure 
Association
Secure 
Association
 
Figure P.5 —Point-to-point MACsec secured LAN in a Layer-2 bridged and Layer-3  
routed network 
MACsec creates a secure association between ports of connected equipment after agreement on which keys 
to use. The key agreement protocol runs between the two elements in clear text; all data frames on the link 
are either integrity protected or encrypted when operated in Strict mode (i.e., frames are received in order). 
Data frames not integrity protected or encrypted are discarded. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
483 
The frame format is illustrated in Figure P.6. ICV, the Integrity Check Value, provides integrity protection. 
Confidentiality is provided by data encryption (optional). The SecTAG field in MACsec carries 
information about the established secure channel, such as Ethertype, TAG control information, secure 
association number, packet number, and secure channel identifier. 
 
Figure P.6 —MACsec frame format (Figure 8-1 of IEEE Std 802.1AE-2006 [B10])  
P.2.2.1.2 MACsec in PTP Networks 
Figure P.7 illustrates a network that uses PTP for synchronization distribution. The network elements are 
all switches or routers (S/R). The top element includes a Grandmaster PTP Instance in the form of the PTP 
Port in the MASTER state of an Ordinary Clock, (OC-M) or a PTP Port in the MASTER STATE of a 
Boundary Clock, (BC). The bottom most elements includes a PTP Port in the SLAVE state of an Ordinary 
Clock, (OC-S) or of a Boundary Clock (BC). PTP Ports in the MASTER and SLAVE states are connected 
by Transparent Clocks over point-to-point links. Figure P.8 illustrates the same network where the point-to-
point links are MACsec protected. 
 
 
Figure P.7 —Synchronization distribution network using PTP 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
484 
 
Figure P.8 —Synchronization distribution network using PTP showing MACsec  
secured links 
Figure P.9 illustrates the path between a Master PTP Instance and a single Slave PTP Instance in the routed 
case (top) and the bridged case (bottom). 
 
PTP TC
L3 
interface
PHY
Route
PTP OS-S/BC
MAC
PHY
Route
MAC
L3 
interface
MACsec
MACsec
Secure 
Association
PTP OC-M/BC
L3 
interface
PHY
Route
PTP TC
MAC
PHY
Route
MAC
L3 
interface
MACsec
MACsec
Secure 
Association
L3 
interface
PHY
MAC
MACsec
Timestamping point
L3 
interface
PHY
MAC
MACsec
L3 
interface
PHY
MAC
MACsec
L3 
interface
PHY
MAC
MACsec
Secure 
Association
PTP TC
PHY
Bridge
PTP OS-S/BC
MAC
PHY
Bridge
MAC
MACsec
MACsec
Secure 
Association
PTP OC-M/BC
PHY
Bridge
PTP TC
MAC
PHY
Bridge
MAC
MACsec
MACsec
Secure 
Association
PHY
MAC
MACsec
Timestamping point
PHY
MAC
MACsec
PHY
MAC
MACsec
PHY
MAC
MACsec
Secure 
Association
 
Figure P.9 —MACsec protected synchronization path in routed and bridged network 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
485 
P.2.2.1.3 Timing aspects of MACsec in PTP-aware Networks 
Figure P.10 illustrates the ingress and egress functional blocks of an Ethernet port. Ideally timestamping is 
done in the physical layer. On the ingress path, the timestamp measurement can be performed before 
decryption. However, on the egress path, the timestamp or updated correctionField needs to be inserted 
before encryption, for one-step operation.  
Encryption/decryption can introduce high PTP message delays. As illustrated in Figure P.10, high 
timestamping accuracy can be achieved in one of the following two ways:  
 
If the encryption/decryption module is implemented with a low delay variation, timestamping can 
be performed accurately at the PTP layer (1588) labeled “1588”.  
 
In two-step mode, timestamping can be performed at the physical layer since the transmitted PTP 
messages do not require in-flight modification. 
1588
Host
Tx
Rx
MACsec
MAC
Physical
PMD
1588
MACsec
MAC
Physical
PMD
 
Figure P.10 —Time stamping before and after MACsec functions 
P.2.2.2 IPsec 
When PTP is run over UDP/IP, as described in Annex C and Annex D, IPsec can be used to secure the IP 
layer.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
486 
IPsec is defined by a suite of IETF RFCs that specify the following:  
 
The architecture as defined in IETF RFC 7619 [B21] 
 
Protocols for node authentication and key exchange, for example, (IKEv2) IETF RFC 8247 [B25] 
 
A protocol to provide confidentiality, normally in conjunction with integrity (Encapsulating 
Security Payload (ESP) tunnel mode, as defined in IETF RFC 4303 [B16])  
 
Several alternative algorithms to be used by these protocols  
PTP in combination with IPsec can be divided into two scenarios. One scenario is PTP Networks consisting 
only of a Grand Master PTP Instance and Slave PTP Instances, that is, no Boundary Clocks or Transparent 
Clocks. ITU-T G.8265.1 [B35] is one example of a profile with this architecture. The other scenario is PTP 
Networks that include Boundary Clocks and/or Transparent Clocks. These two scenarios are discussed. 
This subclause focuses on IPsec in its unicast variant. Therefore, it is assumed for purposes of this 
discussion that all PTP messages are sent as unicast.  
P.2.2.2.1 IPsec scenario 1—PTP tunneled over a non-PTP aware network 
As shown in Figure P.11, the Grand Master PTP Instance is located in a trusted network; the Ordinary 
Clock is connected via a Public Network. Communication with the Ordinary Clock over the Public 
Network is protected using IPsec (PTP messages might or might not be encrypted; however, if they are 
carried over the same tunnel used for other traffic, encryption is generally expected). Typically, the PTP 
Node implementing the Ordinary Clock contains a lot of functions related to the applications and hence the 
PTP traffic is only a small fraction of all communication with the PTP Node. Communication with the PTP 
Node containing the Ordinary Clock from the trusted network over the public network can be over an IPsec 
Tunnel, using the following: 
 
Encapsulating Security Payload (ESP) Tunnel mode (IETF RFC 4303 [B16]) 
 
Internet Key Exchange (IKE) v2 ([B21]) 
In this example, there is only one IPsec tunnel between the Security Gateway and the PTP Node. 
From a PTP perspective, any encryption algorithm can be used or the traffic can be without encryption. 
One aspect to consider is how to handle Quality of Service, ensuring that PTP messages get the highest 
possible priority. The trusted and public network can have different Quality of Service policies, and 
therefore, the mapping of a Differentiated Services Code Point (DSCP) value from the inner IP header to 
the outer IP header needs to be adapted properly. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
487 
Trusted network
GM
SEG
OC
PTP
UDP
IP
ESP
IP
PTP
UDP
IP
PTP
UDP
IP
PTP
UDP
IP
ESP
IP
Public network
GM
Grandmaster PTP Instance
OC
Ordinary Clock
SEG Secure Gateway
 
Figure P.11 —IPsec in a network with no intermediate PTP clocks 
P.2.2.2.2 IPsec scenario 2—PTP in a PTP aware network 
The second scenario is illustrated in Figure P.12. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
488 
GM
BC
BC
PTP
UDP
IP
ESP
IP
PTP
UDP
IP
ESP
IP
GM
Grandmaster PTP Instance
OC
Ordinary Clock
BC
Boundary Clock
OC
PTP
UDP
IP
ESP
IP
 
Figure P.12 —IPsec in a network with intermediate PTP clocks 
In this scenario, there is an IPsec tunnel on each Direct PTP Link. This tunnel is used for the PTP traffic 
and can be used to carry non-PTP traffic.  
The IPsec ESP can be used if the tunnel is carrying only PTP traffic since confidentiality (encryption) is not 
required for PTP. The IPsec Tunnels preferably then use the following IPsec modes: 
 
ESP Tunnel mode (IETF RFC 4303 [B16]) 
 
IKE v2 ([B21]) 
P.2.2.2.3 Timing Aspects of IPsec in PTP-aware Networks 
IPsec could bring some degradation of the timestamping accuracy due to the additional security processing 
if the attached PTP Node and PTP Instances are not designed properly.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
489 
IPsec introduces additional delay when encrypting and decrypting PTP messages and some consideration is 
needed with regards to timestamping. If the IPsec module is implemented in hardware, it introduces similar 
considerations as MACsec. If the IPsec module is implemented in software, then the following two possible 
approaches can be taken: 
 
Depending on the timing requirements, it might be sufficient to use software-based timestamping, 
potentially causing lower accuracy.  
 
Hardware-based timestamping in combination with IPsec encryption requires some further 
considerations, as PTP messages are sent over a software-based IPsec tunnel. On the ingress path, it 
is not possible to identify incoming PTP messages until after decryption. On the egress path, it is 
not possible to update the timestamp field in an outgoing PTP message after it has been encrypted. 
Therefore all incoming PTP messages have to be timestamped and stored until the corresponding 
PTP message is decrypted and identified as a PTP message. For outgoing PTP event messages it is 
recommended to use two-step mode, thus allowing transmission of encrypted PTP messages that 
contain accurate timestamps. The outgoing PTP event messages needs to be identified in the 
hardware by an implementation specific method, for example by an internal flag attached to the 
message. 
Figure P.13 shows the possible timestamping points in an implementation that uses software-based IPsec. 
The picture shows two alternatives for timestamping, either software-based (lower precision) or hardware 
based (higher precision). One-step PTP Ports add extra requirements on the hardware time stamping (not 
considered here) when compared with two-step PTP Ports. 
PTP Protocol
IPsec authentication 
data generation
UDP
Device Driver
MAC
PHY
IPsec authentication 
data generation
Tx Timestamping
Rx Timestamping
SW TS
HW TS
SW TS
HW TS
 
Figure P.13 —Possible timestamping planes in a software-based IPsec implementation 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
490 
P.2.3 Architecture mechanisms (Prong C) 
Prong C highlights several IEEE 1588 optional features and network topology choices that can be used to 
enhance security.  
Time transfer protocols benefit from the nature of timing information, as follows: 
 
PTP messages are generally used and discarded. At most, messages will be saved for a period of 
minutes in a dequeuing filter. Therefore, the authenticity of the message content is not required to 
be maintained for a long duration, allowing the utilization of a delay authentication scheme as 
discussed in P.2.1.2.2.  
 
The time being distributed is generally not a secret and therefore does not need to be hidden in the 
network; thus, confidentially protection is not generally required for PTP messages.  
 
Standardized time can usually be introduced into a network from multiple independent sources. 
Time from multiple sources does not need exactly agree to be useful for enabling robustness; it 
only needs to be similar enough to meet the timing error budget of the application. 
Packet based time transfer protocols, such as PTP, are vulnerable to delay attacks which cannot be thwarted 
by cryptographic protection supplied by prongs A and B. In applications where a delay attack is a threat 
that needs to be addressed, architectural solutions are essential to enable detecting and possibly mitigating 
this threat. 
Redundancy in timing sources and paths can also possibly help detect and protect against other security 
threats. If the threats hamper only part of the timing sources (PTP Instances) being utilized by the 
application within the PTP node, the redundant timing sources can help detect the corruption within the 
sources and possibly mitigate the attack if only a nonmajority of sources are corrupted. It might be feasible 
to achieve such protection without utilization of cryptographic mechanisms if the network architecture 
hinders a simultaneous attack in parallel on the different timing sources being utilized by the node (for 
example completely physically disjoint transport networks for each PTP domain can significantly hamper 
an attacker’s ability to access these networks for such a simultaneous attack). Such redundancy 
mechanisms are discussed in the following section. 
P.2.3.1 Redundancy 
The architectural contribution to security is based on redundancy. Specifically, the following three types of 
redundancy are discussed: 
 
Redundancy by complementary timing systems 
 
Redundant Grandmaster PTP Instances 
 
Redundant network paths between devices 
Redundancy by complimentary timing systems means that a device acquires time from a PTP Instance and 
also from a non-PTP time transfer mechanism. An example would be a PTP Instance which is part of a 
device that also has a GPS receiver. If the device has three or more sources of time, then a suspected 
compromised time source could be removed by a voting algorithm. Once the Local PTP Clock is 
synchronized then it could be used heuristically as a third clock in a limited voting scheme when there are 
only two sources. For example, if the time from an external PTP Instance displays an unexpected time jump 
compared to the both the Local PTP Clock and the GPS receiver as illustrated in Figure P.14, then the time 
from the external PTP Instance is suspect. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
491 
Timing Appliance
Attack
Grandmaster 
PTP Instance
Transparent 
Clock
Ordinary 
Clock
GPS 
Receiver
 
Figure P.14 —Timing appliance with PTP and GPS as redundant timing sources 
Multiple PTP domains can be used to implement a deployment with multiple simultaneous Grandmaster 
PTP Instances (see Annex O). This can be used to increase robustness against network induced errors, 
equipment failures and security breaches. The idea is that multiple Ordinary Clocks are configured to 
operate as Grandmaster PTP Instances, each in a different PTP domain. Devices that want robust time have 
multiple PTP Ports in the SLAVE state configured to operate in the different domains. If there are three or 
more domains, then a voting algorithm can be used. This is illustrated in Figure P.15. Ideally the 
Grandmaster PTP Instances are placed to maximize the diversity in network paths to the Ordinary Clocks. 
Many delay attacks or other man-in-the-middle attacks can be identified by comparing the responses from 
multiple Grandmaster PTP Instances. 
PTP  
Network
Timing 
Appliance
Attack
Grandmaster 
PTP Instance 
Domain 0
Ordinary 
Clock 
Domain 0
Grandmaster 
PTP Instance 
Domain 1
Ordinary 
Clock 
Domain 1
Grandmaster 
PTP Instance 
Domain 2
Ordinary 
Clock 
Domain 2
 
Figure P.15 —PTP network with redundant grandmasters 
Another use of domains is for multipath PTP. This is a special case of multi-master PTP where the 
redundant Grandmaster PTP Instances are implemented as different PTP Ports on the same time sourcing 
PTP Node (see Figure P.16). Note that different PTP Ports can share a physical interface, although having 
them on separate physical interfaces will help to increase the path diversity. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
492 
PTP  
Network
Source 
Timing 
Appliance
Sink 
Timing 
Appliance
Attack
Grandmaster 
PTP Instance 
Domain 0
Ordinary 
Clock 
Domain 0
Grandmaster 
PTP Instance 
Domain 1
Ordinary 
Clock 
Domain 1
Grandmaster 
PTP Instance 
Domain 2
Ordinary 
Clock 
Domain 2
 
Figure P.16 —PTP Network with redundant PTP Communication Paths 
Architecture contributions to security have some limitations. First, an attack which can take control of more 
than one device on the network might be able to defeat an algorithm based on voting. A critical assumption 
in voting systems is that the healthy sources outnumber compromised sources. Second, the ability to deliver 
alternative independent time sources to a PTP Node or PTP Instance is often limited by the degree to which 
different paths for PTP messages can be assured. For example, if a device has only one network port, then 
the switch it connects to is a single point of failure. Lastly, without a complimentary cryptographic method, 
a malicious PTP Node might become the grandmaster in every domain.  
P.2.4 Monitoring and management mechanisms (prong D)  
Prong D highlights the role that monitoring and management plays in meeting the identified security 
requirements. 
Monitoring and management mechanisms can provide complementary tools in the security approach that 
can be combined with one of the other prongs. 
Various parameters and aspects could be monitored to enhance security in a PTP deployment. In particular, 
monitoring of the performance of the PTP Network can in some cases provide an indication on potential 
security attacks, for example delay attacks.  
Monitoring of the link delay is one example of the parameters that can provide useful information. 
In P2P mode, every PTP Clock computes the PTP Link delay between each of its PTP Ports and the peer 
PTP Instance. This allows highly granular measurement information that can be collected by a central 
management system, allowing detection and localization of potential problems or threats. 
In end-to-end (E2E) mode, the time distribution and the delay measurement are intertwined. The delay 
measurement uses Sync and Delay_Req messages. Thus, if a malicious attacker tampers with Sync 
messages, for example by delaying them, this attack is reflected in the delay computation. Hence, a 
suspiciously high path delay might indicate that an attacker is tampering with Sync or Delay_Req 
messages. In P2P mode, malicious delay of Sync messages cannot be detected by the peer-to-peer delay 
mechanism.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
493 
Other general heuristics can detect suspicious circumstances once a Slave Clock is locked to its Master 
Clock. These include the following: 
 
Unexpected offset jumps 
 
Offset corrections indicating a frequency drift which is larger than expected from the properties of 
the local oscillator 
 
Large changes in P2P measured PTP link delays 
A list of the parameters that can be monitored are described in Annex J. The basic principle is that by 
monitoring some of the parameters used by PTP (meanPathDelay, OffsetFromMaster, etc.) and the four 
PTP Timestamps (t1, t2, t3, and t4), it is possible to get an indication of network performance and PTP 
Instance operation. 
Details of the performance monitoring parameters for a PTP Port in SLAVE state are provided in Table J.1.  
Specific parameters for the performance monitoring of meanPathDelay in case of the peer-to-peer delay 
mechanism are described in Table J.2. 
Additional parameters such as counters that can check the PTP message rate, could also provide some 
indication on possible attacks, for example  DoS. These are described in Table J.3. 
It could also be important to monitor the network Grandmaster PTP Instance. When a PTP Instance claims 
to be the best master it might be important to verify if there is any inconsistency with the actual 
characteristics and location in the network of this PTP Instance. 
It could also be relevant to monitor the values and the consistency of PTP message fields that can change 
due to an attack, for example, currentUTCOffset field that changes without the occurrence of a leap second. 
An important aspect is to define where the monitoring takes place. Some functions might need to be 
implemented in every PTP Node or PTP Instance to enable a quicker response to a security violation. 
External tools to monitor the jitter, network changes, etc., could also be considered for these tasks.  
P.2.5 Additional security considerations 
This subclause identifies additional security practices and considerations that can be used to improve the 
security posture of the overall system.  
P.2.5.1 Disabling unused features 
To the extent possible, it is recommended to limit implementation or activation of optional features that are 
not required. An optional feature that is enabled can, in some cases, result in a security vulnerability. 
P.2.5.2 Whitelist and access control 
A whitelist is a list of PTP Instances with which the current PTP Instance is permitted to communicate. A 
whitelist can be configured manually or by remote management. Optionally, the whitelist can specify an 
access level for each PTP Instance on the whitelist, indicating whether the PTP Instance is permitted to be a 
Master PTP Instance. A whitelist is especially strong at resisting attacks when combined with a 
cryptographic technique for authenticating the sources of PTP messages.  
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
494 
P.2.5.3 Secure network management protocols  
The AUTHENTICATION TLV can be applied to protect PTP management messages. Many early network 
management protocols including early versions of SNMP [B27] and IEEE 1588 Clause 15 management did 
not include any security mechanisms for the management protocol and data. It is recommended that a 
secure network management protocol like SNMPv3 (IETF RFC 5590 [B18]) be utilized wherever possible.  
P.2.5.4 Two-step operation 
As discussed, two-step operation can simplify the implementation of accurate hardware-based 
timestamping in the presence of a cryptographic security mechanism.  
One-step transmission of PTP event messages requires the cryptographic functions to be performed after 
the timestamping of the PTP messages. High accuracy synchronization requires low latency variation in the 
cryptographic calculations. This will in turn require the cryptographic functionality to be hardware-based. 
In two-step operation, the timestamping functionality can be implemented in hardware, even when the 
cryptographic functionality is performed by a software layer. Therefore, two-step operation allows 
software-based cryptographic protocols. Security mechanisms implemented in software, rather than 
hardware might be easier to upgrade in the field. 
P.2.5.5 Compartmentalization 
When a cryptographic security mechanism is used in a PTP-enabled network, it is important to minimize 
the number of PTP Instances that are in possession of the security key, so as to minimize potential threats 
by attackers that gain access to the cryptographic key.  
It is recommended that PTP domains that do not require interaction be cryptographically partitioned using 
different keys.  
On-path support, using Boundary Clocks or Transparent Clocks, allows Slave Clocks to synchronize to the 
Grandmaster Clock with a high degree of accuracy. Some applications require an accuracy that can be 
satisfied without on-path support. In these cases, it is recommended that on-path support be disabled and 
the number of nodes that have access to the cryptographic keys be limited to reduce the threat posed by 
intermediate nodes. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
