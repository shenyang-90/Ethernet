# Annex A (normative) PICS proforma

121
Copyright © 2016 IEEE. All rights reserved.
IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
Annex A
(normative) 
PICS proforma13 
A.1 Introduction
The supplier of a protocol implementation that is claimed to conform to this standard shall complete the 
following Protocol Implementation Conformance Statement (PICS) proforma.
A completed PICS proforma is the PICS for the implementation in question. The PICS is a statement of 
which capabilities and options of the protocol have been implemented. The PICS can have a number of uses, 
including use
a)
By the protocol implementers, as a checklist to reduce the risk of failure to conform to the standard 
through oversight.
b)
By the supplier and acquirer—or potential acquirer—of the implementation, as a detailed indication 
of the capabilities of the implementation, stated relative to the common basis for understanding 
provided by the standard PICS proforma.
c)
By the user—or potential user—of the implementation, as a basis for initially checking the 
possibility of interworking with another implementation (note that although interworking can never 
be guaranteed, failure to interwork can often be predicted from incompatible PICS).
d)
By a protocol tester, as the basis for selecting appropriate tests against which to assess the claim for 
conformance of the implementation.
A.2 Abbreviations and special symbols
A.2.1 Status symbols
M
Mandatory
O
Optional
O.n
Optional, but support of at least one of the group of options labeled by the same numeral n is 
required
X
Prohibited
pred: Conditional-item symbol, including predicate identification: See B.3.4
¬
Logical negation, applied to a conditional item’s predicate 
A.2.2 General abbreviations
N/A
Not applicable
PICS Protocol Implementation Conformance Statement
13Copyright release for PICS proformas: Users of this standard may freely reproduce the PICS proforma in this annex so that it can be 
used for its intended purpose and may further publish the completed PICS.
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
122
Copyright © 2016 IEEE. All rights reserved.
A.3 Instructions for completing the PICS proforma
A.3.1 General structure of the PICS proforma
The first part of the PICS proforma, implementation identification and protocol summary, is to be completed 
as indicated with the information necessary to identify fully both the supplier and the implementation.
The main part of the PICS proforma is a fixed-format questionnaire, divided into several subclauses, each 
containing a number of individual items. Answers to the questionnaire items are to be provided in the right-
most column, either by simply marking an answer to indicate a restricted choice (usually Yes or No), or by 
entering a value or a set or range of values. (Note that there are some items in which two or more choices 
from a set of possible answers can apply; all relevant choices are to be marked.)
Each item is identified by an item reference in the first column. The second column contains the question to 
be answered; the third column records the status of the item—whether support is mandatory, optional, or 
conditional; see also B.3.4. The fourth column contains the reference or references to the material that 
specifies the item in the main body of this standard, and the fifth column provides the space for the answers.
A supplier may also provide (or be required to provide) further information, categorized as either Additional 
Information or Exception Information. When present, each kind of further information is to be provided in a 
further subclause of items labeled Ai or Xi, respectively, for cross-referencing purposes, where i is any 
unambiguous identification for the item (e.g., simply a numeral). There are no other restrictions on its format 
and presentation.
A completed PICS proforma, including any Additional Information and Exception Information, is the 
Protocol Implementation Conformation Statement for the implementation in question.
NOTE—Where an implementation is capable of being configured in more than one way, a single PICS may be able to 
describe all such configurations. However, the supplier has the choice of providing more than one PICS, each covering 
some subset of the implementation's configuration capabilities, in case that makes for easier and clearer presentation of 
the information.
A.3.2 Additional information
Items of Additional Information allow a supplier to provide further information intended to assist the 
interpretation of the PICS. It is not intended or expected that a large quantity will be supplied, and a PICS 
can be considered complete without any such information. Examples might be an outline of the ways in 
which a (single) implementation can be set up to operate in a variety of environments and configurations, or 
information about aspects of the implementation that are outside the scope of this standard but that have a 
bearing on the answers to some items.
References to items of Additional Information may be entered next to any answer in the questionnaire and 
may be included in items of Exception Information.
A.3.3 Exception information
It may occasionally happen that a supplier will wish to answer an item with mandatory status (after any 
conditions have been applied) in a way that conflicts with the indicated requirement. No preprinted answer 
will be found in the Support column for this: instead, the supplier shall write the missing answer into the 
Support column, together with an Xi reference to an item of Exception Information, and shall provide the 
appropriate rationale in the Exception item.
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 


123
Copyright © 2016 IEEE. All rights reserved.
IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
An implementation for which an Exception item is required in this way does not conform to this standard.
NOTE—A possible reason for the situation described above is that a defect in this standard has been reported, a 
correction for which is expected to change the requirement not met by the implementation.
A.3.4 Conditional status
A.3.4.1 Conditional items
The PICS proforma contains a number of conditional items. These are items for which both the applicability 
of the item itself, and its status if it does apply—mandatory or optional—are dependent upon whether or not 
certain other items are supported.
Where a group of items is subject to the same condition for applicability, a separate preliminary question 
about the condition appears at the head of the group, with an instruction to skip to a later point in the 
questionnaire if the “Not Applicable” answer is selected. Otherwise, individual conditional items are 
indicated by a conditional symbol in the Status column.
A conditional symbol is of the form “pred: S,” where pred is a predicate as described in A.3.4.2, and S is a 
status symbol, M or O.
If the value of the predicate is TRUE (see A.3.4.2), the conditional item is applicable, and its status is 
indicated by the status symbol following the predicate: the answer column is to be marked in the usual way. 
If the value of the predicate is FALSE, the “Not Applicable” (N/A)14 answer is to be marked.
A.3.4.2 Predicates
A predicate is one of the following:
a)
An item-reference for an item in the PICS proforma: The value of the predicate is TRUE if the item 
is marked as supported, and is FALSE otherwise.
b)
A predicate-name, for a predicate defined as a Boolean expression constructed by combining￿ﾠ
item-references using the Boolean operator OR: The value of the predicate is TRUE if one or more 
of the items is marked as supported.
c)
A predicate-name, for a predicate defined as a Boolean expression constructed by combining￿ﾠ
item-references using the Boolean operator AND: The value of the predicate is TRUE if all of the 
items are marked as supported.
d)
The logical negation symbol “¬” prefixed to an item-reference or predicate-name: The value of the 
predicate is TRUE if the value of the predicate formed by omitting the “¬” symbol is FALSE, and 
vice versa.
Each item whose reference is used in a predicate or predicate definition, or in a preliminary question for 
grouped conditional items, is indicated by an asterisk15 in the Item column.
14(N/A) is currently not used in this PICS.
15Asterisks are currently not used in this PICS. 
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
124
Copyright © 2016 IEEE. All rights reserved.
PICS proforma for IEEE Std 802.1AB-2016
A.3.5 Implementation identification
Supplier
Contact point for queries about the PICS
Implementation Name(s) and Version(s)
Other information necessary for full iden-
tification—e.g., name(s) and version(s) of 
machines and/or operating system names
NOTE 1—Only the first three items are required for all implementations; other information may be completed as 
appropriate in meeting the requirement for full identification. 
NOTE 2—The terms Name and Version should be interpreted appropriately to correspond with a supplier’s termi-
nology (e.g., Type, Series, Model).
A.3.6 Protocol summary, IEEE Std 802.1AB-2016
Identification of protocol 
specification
IEEE Std 802.1AB-2016, IEEE Standard for Local and metropolitan area 
networks—Station and Media Access Control Connectivity Discovery 
Identification of amendments and cor-
rigenda to the PICS proforma that 
have been completed as part of the 
PICS
Amd.                       :                    Corr.                    :
Amd.                       :                    Corr.                    :
Have any Exception items been 
required? (See B.3.3: The answer Yes 
means that the implementation does 
not conform to IEEE Std 802.1AB-
2016)
                         No   [ ]                                      Yes  [ ]
Date of Statement
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 


125
Copyright © 2016 IEEE. All rights reserved.
IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
A.4 Major capabilities and options 
Item
Feature
Status
References
Support
cntrlport
Are LLDP exchanges supported through a con-
trolled port if port access is controlled by IEEE 
Std 802.1X?
M 
5.3, 6 
Yes [ ] N/A [ ]
uncntrlport
Are LLDP exchanges supported through the 
uncontrolled port if port access is controlled by 
IEEE Std 802.1X?
O 
5.4, 6 
Yes [ ] No [ ] N/A [ ]
addr
Are LLDP addressing and LLDP EtherType 
encoding in conformance with the defined 
requirements? 
All systems:
DA = Any group MAC address
DA = Any individual MAC address
SA = station MAC address 
LLDP EtherType encoding
C-VLAN Bridge:
DA = Nearest bridge address 
DA = Nearest non-TPMR bridge address
DA = Nearest customer bridge address
S-VLAN Bridge:
DA = Nearest bridge address 
DA = Nearest non-TPMR bridge address
DA = Nearest customer bridge address
TPMR Bridge:
DA = Nearest bridge address 
DA = Nearest non-TPMR bridge address
DA = Nearest customer bridge address
End station:
DA = Nearest bridge address 
DA = Nearest non-TPMR bridge address
DA = Nearest customer bridge address
O
O
M 
M 
M 
M
M
M 
M
X
M 
X
X
M 
O
O
7.1
7.1
7.2 
7.3 
7.1
7.1
7.1
7.1
7.1
7.1
7.1
7.1
7.1
7.1
7.1
7.1
Yes [ ] No [ ]
Yes [ ] No [ ]
Yes [ ] 
Yes [ ] 
Yes [ ] N/A [ ]
Yes [ ] N/A [ ]
Yes [ ] N/A [ ]
Yes [ ] N/A [ ]
Yes [ ] N/A [ ]
No [ ] N/A [ ]
Yes [ ] N/A [ ]
No [ ] N/A [ ]
No [ ] N/A [ ]
Yes [ ] N/A [ ]
Yes [ ] No [ ] N/A [ ]
Yes [ ] No [ ] N/A [ ]
lldpdu
Is the LLDPDU encapsulation in conformance 
with the TLV order specified by the LLDPDU 
format?
M 
7.3 
Yes [ ] 
tlvfmt
Is the basic TLV capability implemented?
M 
8.4 
Yes [ ] 
basictlv
Is each TLV in the basic management set imple-
mented? 
End Of LLDPDU TLV 
Chassis ID TLV 
Port ID TLV 
Time To Live TLV 
Port Description TLV 
System Name TLV 
System Description TLV 
System Capabilities TLV 
Management Address TLV 
O 
M 
M 
M 
M 
M 
M 
M 
M 
8.5.1 
8.5.2 
8.5.3 
8.5.4 
8.5.5 
8.5.6 
8.5.7 
8.5.8 
8.5.9 
Yes [ ] No [ ]
Yes [ ] 
Yes [ ] 
Yes [ ] 
Yes [ ] 
Yes [ ] 
Yes [ ] 
Yes [ ] 
Yes [ ] 
xtlvfmt
Is the Organizationally Specific TLV capability 
implemented?
M 
8.6 
Yes [ ] 
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 


IEEE Std 802.1AB-2016
IEEE Standard for Local and metropolitan area networks—Station and Media Access Control Connectivity Discovery
126
Copyright © 2016 IEEE. All rights reserved.
optxrx
optx
oprx
Which of the following operational modes are 
implemented? 
Transmit and receive 
Transmit only 
Receive only 
O.1 
O.1 
O.1 
6.1 
6.1 
6.1 
Yes [ ] No [ ]
Yes [ ] No [ ]
Yes [ ] No [ ]
txmode
Is the transmit mode in conformance with all 
operational specifications indicated for the Tx 
mode in Table 9-1? 
optxrx 
OR optx: 
M 
Clause 9
Yes [ ] N/A [ ]
rxmode
Is the receive module in conformance with all 
operational specifications indicated for the Tx 
mode in Table 9-1?
optxrx 
OR oprx: 
M 
Clause 9
Yes [ ] N/A [ ]
mib
nomib
Which type of data store/retrieval is imple-
mented?
SNMP MIB is supported
SNMP MIB is not supported
O.2
O.2
11.5, 5.3
10.1, 5.3
Yes [ ] No [ ]
Yes [ ] No [ ]
snmpmib
Is the MIB module in conformance with the 
MIB sections indicated in Table 11-1 for the 
operating mode being implemented?
mib:M
11.5, 5.3
Yes [ ] N/A [ ]
snmpsupport
Which of the transport mappings defined by 
IETF RFC 3417 or IETF RFC 4789 is used to 
support SNMP? 
IETF RFC 3417
IETF RFC 4789
mib:O.3
mib:O.3
5.3, 5.4
5.3, 5.4
Yes [ ] No [ ] N/A [ ]
Yes [ ] No [ ] N/A [ ]
equivstor
If the SNMP is not supported, is functionally 
equivalent storage and retrieval capability spec-
ified in Clause 8, Clause 9, Clause10 provided 
for the operating mode being implemented?
nomib:M
10.1
Yes [ ] N/A [ ]
A.4 Major capabilities and options 
Item
Feature
Status
References
Support
Authorized licensed use limited to: Tsinghua University. Downloaded on March 18,2026 at 10:36:06 UTC from IEEE Xplore.  Restrictions apply. 
