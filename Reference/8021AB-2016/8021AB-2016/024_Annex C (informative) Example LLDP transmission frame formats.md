# Annex C (informative) Example LLDP transmission frame formats

IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
128
Copyright © 2016 IEEE. All rights reserved.
Annex C
(informative) 
Example LLDP transmission frame formats
The LLDP MAC frame format is based on the particular transmission protocol. The following example 
formats illustrate the indicated LLDP EtherType encoding method. 
C.1 Direct-encoded LLDP frame format 
The IEEE 802.3 LLDP frame format is illustrated in Figure C.1. 
NOTE—The illustration shows the simplest form of an LLDP frame on an IEEE 802.3 medium; i.e., where the frame 
has had no IEEE 802.1Q tag header, or IEEE 802.1AE™ security tag, or any other form of encapsulation applied to it.
C.2 SNAP-encoded LLDP frame format 
The IEEE 802.11™ frame format is illustrated in Figure C.2, for the case where the value of To DS and 
From DS in the Frame Control field are both zero. 
NOTE—The illustration shows the simplest form of an LLDP frame on an IEEE 802.11 medium; i.e., where the frame 
has had no IEEE 802.1Q tag header, or IEEE 802.1AE security tag, or any other form of encapsulation applied to it.
Figure C.1—IEEE 802.3 LLDP frame format
Figure C.2—IEEE 802.11 LLDP frame format
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 
