# Annex B (normative) PTOPO MIB update

127
Copyright © 2016 IEEE. All rights reserved.
IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
Annex B
(normative) 
PTOPO MIB update
The PTOPO MIB should be updated according to the following rules: 
a)
If any objects in the LLDP remote systems MIB age out, the equivalent objects in the PTOPO MIB 
should be deleted. 
b)
If the TTL value in the Time To Live TLV is zero, then the port is being shutdown and the PTOPO 
MIB objects associated with the MSAP identifier should be deleted.
c)
If the TTL field is non-zero, then the appropriate ptopoRemEntry is found or created, based on the 
data elements included in the LLDP frame. If the indicated entry is dynamic (i.e., ptopoConnIsStatic 
is FALSE), then the current sysUpTime value is stored in the ptopoConnLastVerifyTime field for the 
entry.
d)
If a ptopoRemEntry was added then the ptopoConnTabInserts counter is incremented.
e)
If any ptopoRemEntry was added or deleted, or if information other than the 
ptopoRemLastVerifyTime changed for any entry due to the processing of this LLDP frame, the 
ptopoLastChangeTime object is set with the current sysUpTime, and a ptopoConfigChange trap 
event is generated. (See the PTOPO MIB for information on ptopoConfigChange trap generation.)
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 
