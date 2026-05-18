# Annex H  (normative) Transport of PTP over IEC 61158 Type 10

IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
392 
Annex H   
(normative)  
Transport of PTP over IEC 61158 Type 10 
H.1 Background 
PROFINET (IEC 61158 Type 10) specifies a fieldbus communication system. More specific information 
on how this fieldbus communication system is used to interoperate in a system is given in the 
communication profiles IEC 61784-1:2007 and IEC 61784-2:2007. 
IEC 61784-1:2007 and IEC 61784-2:2007 specify Communication Profile Families (CPFs) and, within a 
CPF, one or more Communication Profiles (CPs). A CP refers to IEC 61158 Types. IEC 61784-1:2007 
specifies various fieldbuses. IEC 61784-2:2007 specifies various real-time Ethernet fieldbuses. 
PROFIBUSTM30 and PROFINET are specified in CPF 3. CP 3/4, CP 3/5, and CP 3/6 specify PROFINET in 
IEC 61784-2:2007. 
The IEC 61158 Type 10 protocol is specified in IEC 61158-6-10:2007. IEC 61158 Type 10 services are 
specified in IEC 61158-5-10:2007.  
This annex specifies the protocol used for the transport of PTP over Layer 2 for the CP 3/4, CP 3/5, and  
CP 3/6 of IEC 61784-2:2007, also known as PROFINET. These CPs refer to IEC 61158-5-10:2007,  
IEC 61158-6-10:2007, and other standards. 
Figure H.1 illustrates a PTP region and an IEC 61158 Type 10 region. A Boundary Clock is used to 
translate between the protocol in the two regions. 
The protocol of this annex is functionally equivalent to Transparent Clock and Ordinary Clock 
functionality of PTP over Layer 2 in the main subclauses and annexes of this standard. However, the 
protocol of this annex has a different encoding of the PTP messages to meet the encoding specifications for 
CP 3/4, CP 3/5, and CP 3/6 of IEC 61784-2:2007 within IEC 61158. This annex is not applicable to CP 3/1, 
CP 3/2, and CP 3/3 of IEC 61784-1:2007. 
NOTE—Existing ASICs support the PTP over Layer 2 of CP 3/4, CP 3/5, and CP 3/6 of IEC 61784-2:2007. 
The encoding of this annex shall be used for implementations required to meet the encoding specifications 
for CP 3/4, CP 3/5, and CP 3/6 of IEC 61784-2:2007 within IEC 61158. 
                                                 
30PROFIBUS™ is the trade name of the nonprofit organization PROFIBUS Nutzerorganisation e.V. (PNO). This information is given 
for the convenience of users of this standard and does not constitute an endorsement by the IEEE of these products. Equivalent 
products are acceptable if they can be shown to lead to the same results. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
393 
IEEE 1588 Region
OC
TC
OC
TC
OC
TC
OC
TC
BC
TC
OC
TC
OC
TC
OC
OC
OC
PROFINET Region
 
Figure H.1 PROFINET region combined with domains 
H.2 Message specification 
The mappings of the different message names are provided in Table H.1. 
Table H.1 Mapping of messages 
Names for PROFINET 
Names for PTP 
SyncPDU 
Sync 
FollowUpPDU 
Follow_Up 
AnnouncePDU 
Announce 
Not used 
Delay_Req 
Not used 
Delay_Resp 
DelayReqPDU 
Pdelay_Req 
DelayResPDU 
Pdelay_Resp 
DelayFuResPDU 
Pdelay_Resp_Follow_Up 
Not used 
Signaling 
Not used 
PTP management 
The coding of the PROFINET messages and the used acronyms, abbreviations, and conventions shall be 
used according IEC 61158-5-10:2007 and IEC 61158-6-10:2007. 
For any quantity of data type PortAddress (see 5.3.6), when the networkProtocol member value is 
PROFINET (see 7.4.1): 
 
The addressLength member value shall be 6. 
 
The addressField member value shall be the 6 octet source address of the Ethernet header. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
394 
H.3 DLPDU of the IEC 61158 TYPE10 
H.3.1 Abstract syntax of the DLPDU 
Table H.2 gives an outline of the abstract syntax of the DLPDU according to IEEE Std 802.3. 
The encoding and decoding of the fields in Table H.2 shall be according to IEEE Std 802.3 for the DLPDU. 
Table H.2 IEEE 802.3 DLPDU syntax 
DLPDU 
name 
DLPDU structure 
DLPDU 
Preamble,a StartFrameDelimiter, DestinationAddress, SourceAddress, DLSDU,b DLPDU_Padding,c 
FrameCheckSequence 
DLSDU 
LT, FIDAPDU 
FIDAPDU FrameID, SyncPDU ^ AnnouncePDU ^ FollowUpPDU ^ DelayReqPDU ^ DelayResPDU ^ 
DelayFuResPDU 
NOTE—According to IEEE Std 802.3, the DLPDUs have a minimum length of 64 octets (excluded Preamble, Start 
Frame Delimiter). 
a The field contains at least 7 octets. 
b The minimum DLSDU size is 2 octets. 
c The number of padding octets shall be in the range of 0 to 46 depending on the DLSDU size. The value shall be set to zero. 
H.3.2 Coding of the DLPDU field DestinationAddress 
The DLPDU field shall be coded as data type Octet[6]. The value of the field DestinationAddress shall be 
an IEEE 802 MAC address. 
For PTP over PROFINET-PDUs, the value shall be set according to the coding of the DLPDU 
DestinationAddress as specified in IEC 61158-6-10, 4.2.2.3.3; Ed3. 
H.3.3 Coding of the field LT 
The LT field shall be coded with the values according to IEEE Std 802.3 (Unsigned16). This specification 
uses the values according to Table H.3.  
Table H.3 LT (Length/Type) 
Value (hex) 
Meaning 
8892 
PROFINET 
H.3.4 Coding of the field FrameID 
The FrameID field shall be coded as data type Unsigned16 with the values according to Table H.4. This 
field identifies the structure and the type of the APDU. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
395 
Table H.4 FrameID 
Value (hex) 
Meaning 
Use 
0000–001F 
Reserved 
— 
0020 
SyncPDU 
SyncPDU with follow up used for PTP Instance synchronization 
(isochronous application) 
0021 
SyncPDU 
SyncPDU with follow up used for time synchronization 
0022–007F 
Reserved 
 
0080  
SyncPDU  
SyncPDU 
without 
follow 
up 
used 
for PTP Instance 
synchronization (isochronous application) 
0081 
SyncPDU 
SyncPDU without follow up used for time synchronization 
0082–FEFF 
Reserved 
— 
FF00 
AnnouncePDU (clock) 
AnnouncePDU 
is 
used 
for 
synchronization 
(isochronous 
application) 
FF01 
AnnouncePDU (time) 
AnnouncePDU is used for time synchronization 
FF02–FF1F 
Reserved 
 
FF20 
FollowUpPDU (clock) 
FollowUpPDU is used for clock synchronization 
FF21 
FollowUpPDU (time) 
FollowUpPDU is used for time synchronization 
FF22–FF3F 
Reserved 
— 
FF40 
DelayReqPDU 
DelayReqPDU is used for path delay measurement 
FF41 
DelayResPDU 
DelayResPDU is used for path delay measurement with follow up 
FF42 
DelayFuResPDU 
DelayFuResPDU is used for path delay measurement 
FF43 
DelayResPDU 
DelayResPDU is used for path delay measurement without follow 
up 
FF44–FFFF 
Reserved 
— 
H.4 Encoding specifications 
A bridge can convert the two formats at the edge. The mapping of the different formats and the different 
parameter and attribute names are provided in Table H.5. The translation of flagField (see 13.3.2.8) to 
PROFINET is provided in Table H.6. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
396 
Table H.5 Mapping of the parameter and attribute names 
Names for PROFINET 
Message type 
Names for PTP  
No counterpart 
— 
majorSdoId 
FrameID 
SyncPDU 
FollowUpPDU 
AnnouncePDU 
DelayReqPDU 
DelayResPDU 
DelayFuResPDU 
messageType 
No counterpart 
— 
versionPTP 
No counterpart 
— 
minorVersionPTP 
No counterpart 
— 
messageLength 
SubdomainUUID 
SyncPDU 
FollowUpPDU 
AnnouncePDU 
DelayReqPDU 
DelayResPDU 
DelayFuResPDU 
domainNumber 
According to Table 37 
SyncPDU 
flagField 
SequenceId 
SyncPDU 
FollowUpPDU 
AnnouncePDU 
DelayReqPDU 
DelayResPDU 
DelayFuResPDU 
sequenceId 
MasterSourceAddress 
SyncPDU 
FollowUpPDU 
AnnouncePDU 
clockIdentity 
Is specified in PROFINET 
— 
logMessageInterval 
Seconds 
SyncPDU 
seconds (Bit 0–31) 
NanoSeconds 
SyncPDU 
Nanoseconds 
EpochNumber 
SyncPDU 
seconds (Bit 32–47) 
CurrentUTCOffset 
SyncPDU 
currentUtcOffset 
ClockAccuracy 
SyncPDU 
AnnouncePDU 
clockAccuracy 
ClockClass 
SyncPDU 
AnnouncePDU 
clockClass 
MasterPriority1 
SyncPDU 
AnnouncePDU 
priority1 
MasterPriority2 
SyncPDU 
AnnouncePDU 
priority2 
ClockVariance 
SyncPDU 
AnnouncePDU 
offsetScaledLogVariance 
No counterpart 
— 
stepsRemoved 
No counterpart 
— 
grandmasterIdentity 
No counterpart 
— 
parentPortIdentity 
RequestSourceAddress 
DelayReqPDU 
DelayResPDU 
DelayFuResPDU 
clockIdentity 
RequestPortID 
DelayReqPDU 
DelayResPDU 
DelayFuResPDU 
portNumber 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 1588-2019 
IEEE Standard for a Precision Clock Synchronization Protocol for Networked Measurement and Control Systems 
 
Copyright © 2020 IEEE. All rights reserved. 
397 
 
Table H.6 Translation of flagField from PTP version 2 to PROFINET 
Names for PROFINET 
Names for PTP version 2.1 
Last minute has 61 s 
flagField.leap61  
Last minute has 59 s 
flagField.leap59 
Signaled by the AnnouncePDU 
flagField.alternateMasterFlag 
Coded in FrameID 
flagField.twoStepFlag 
TRUE for time synchronization and ClockStratum = 1 or 2 
flagField.timeTraceable 
TRUE for ClockStratum = 1 or 2 
flagField.frequencyTraceable 
FALSE for clock synchronization (ARP) 
TRUE for time synchronization if identifier is not INIT or 
DFLT. Otherwise FALSE 
flagField.ptpTimescale 
FALSE for clock synchronization (ARP) 
TRUE for time synchronization if identifier is not INIT or 
DFLT. Otherwise FALSE 
flagField.currentUtcOffsetValid 
FALSE 
flagField.unicastFlag 
Set to FALSE 
All other flagField 
The coding of the IEC 61158 Type 10 parameter, attributes, and the used acronyms, abbreviations, and 
conventions shall be used according IEC 61158-5-10:2007 and IEC 61158-6-10:2007. 
Authorized licensed use limited to: University of Exeter. Downloaded on June 19,2020 at 08:52:11 UTC from IEEE Xplore.  Restrictions apply. 
