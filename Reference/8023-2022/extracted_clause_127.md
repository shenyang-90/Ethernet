# Clause 127: Physical Coding Sublayer (PCS) and Physical Medium Attachment (PMA) sublayer for 2.5 Gb/s 8B/10B 2.5GBASE-X

**Focus**: 2.5GBASE-X PCS, PMA, 8B/10B coding, XGMII mapping, synchronization state machine, EEE LPI support

**Pages extracted**: 5135 – 5171

**Excluded from**: Page 5172 (electrical/PICS section)

127. Physical Coding Sublayer (PCS) and Physical Medium Attachment 
(PMA) sublayer for 2.5 Gb/s 8B/10B 2.5GBASE-X
127.1 Overview
127.1.1 Scope
This clause specifies the Physical Coding Sublayer (PCS) and the Physical Medium Attachment (PMA) 
sublayer that are common to a family of 2.5 Gb/s Physical Layer implementations known as 2.5GBASE-X. 
The 2.5GBASE-X PCS and 2.5GBASE-X PMA are sublayers of the 2.5 Gb/s BASE-X PHY listed in 
Table 125–1. The term 2.5GBASE-X is used when referring generally to Physical Layers using the PCS and 
PMA defined in this clause.
2.5GBASE-X PCS and PMA sublayers map the interface characteristics of the PMD sublayer (including
MDI) to the services expected by the Reconciliation sublayer. 2.5GBASE-X can be extended to support any 
other full duplex medium requiring only that the medium be compliant at the PMD level.
127.1.2 Relationship of 2.5GBASE-X to other standards
Figure 125–1 depicts the relationships among the 2.5GBASE-X sublayers, Ethernet MAC and reconciliation 
layers, and the higher layers. The 2.5GBASE-X service interface is the XGMII, which is defined in 
Clause 46.
127.1.3 Summary of 2.5GBASE-X sublayers
Figure 127–1 shows the relationship of the 2.5GBASE-X PCS sublayer with other sublayers to the ISO 
Open System Interconnection (OSI) reference model. 
127.1.3.1 Physical Coding Sublayer (PCS)
The PCS service interface is the XGMII that provides a uniform interface to the Reconciliation sublayer for 
all 2.5 Gb/s PHY implementations. The 2.5GBASE-X PCS provides all services required by the XGMII 
including encoding (decoding) of XGMII data octets to (from) ten-bit code-groups (8B/10B) for 
communication with the underlying PMA.
127.1.3.2 Physical Medium Attachment (PMA) sublayer
The PMA provides a medium-independent means for the PCS to support the use of serial-bit-oriented 
physical media. The 2.5GBASE-X PMA performs the following functions:
a)
Mapping of transmit and receive code-groups between the PCS and PMA via the PMA Service 
Interface.
b)
Serialization (deserialization) of code-groups for transmission (reception) on the underlying serial 
PMD.
c)
Recovery of clock from the 8B/10B-coded data supplied by the PMD.
d)
Mapping of transmit and receive bits between the PMA and PMD via the PMD Service Interface.
127.1.3.3 Physical Medium Attachment (PMA) service interface rates
2.5GBASE-X Physical Layer specification has nominal rate at the PMA service interface of 3.125 Gb/s, 
which provides MAC data rate of 2.5 Gb/s.

127.1.4 Inter-sublayer interfaces
There are a number of interfaces employed by 2.5GBASE-X. Some (such as the PMA Service Interface) use 
an abstract service model to define the operation of the interface. An optional physical instantiation of the 
PCS Interface is the XGMII. Figure 127–2 depicts the relationship and mapping of the services provided by 
all of the interfaces relevant to 2.5GBASE-X.
While this specification defines interfaces in terms of bits, octets, and code-groups, implementers may 
choose other data path widths for implementation convenience. The only exception is the XGMII, which, 
when implemented at an observable interconnection port, uses a 32-bit-wide data path as specified in 
Clause 46.
Figure 127–1—2.5GBASE-X PCS and PMA relationship to the ISO/IEC Open Systems 
Interconnection (OSI) reference model and IEEE 802.3 Ethernet model
PHY = PHYSICAL LAYER DEVICE
PMA = PHYSICAL MEDIUM ATTACHMENT
PMD = PHYSICAL MEDIUM DEPENDENT
XGMII = 10 GIGABIT MEDIA INDEPENDENT INTERFACE
* XGMII IS OPTIONAL
AN= AUTO-NEGOTIATION
LLC = LOGICAL LINK CONTROL
MAC = MEDIA ACCESS CONTROL
MDI = MEDIUM DEPENDENT INTERFACE
PCS = PHYSICAL CODING SUBLAYER
ETHERNET
LAYERS
LLC OR OTHER MAC CLIENT
MAC
HIGHER LAYERS
MAC CONTROL (OPTIONAL)
PRESENTATION
APPLICATION
SESSION
TRANSPORT
NETWORK
DATA LINK
PHYSICAL
OSI
REFERENCE
MODEL
LAYERS
PHY
RECONCILIATION
AN
PMA
2.5GBASE-X PCS
2.5GBASE-X
MEDIUM
MDI
XGMII*
PMD

127.1.5 Functional block diagram
Figure 127–2 provides a functional block diagram of the 2.5GBASE-X PHY.
127.2 Physical Coding Sublayer (PCS)
127.2.1 PCS Interface (XGMII)
The PCS Service Interface allows the 2.5GBASE-X PCS to transfer information to and from a PCS client. 
PCS clients include the MAC (via the Reconciliation sublayer). The PCS Interface is precisely defined as 
the 10 Gigabit Media Independent Interface (XGMII) in Clause 46.
M D I
Transmit
PMD 
Receive
PCS
PMA
TXD<31:0>
TXC<3:0>
TX_CLK
RXD<31:0>
RXC<3:0>
RX_CLK
XGMII
WORD ENCODE
TRANSMIT
Figure 127–2—Functional block diagram of 2.5GBASE-X PHY
SYNCHRONIZATION
TRANSMIT
RECEIVE
tx_bit
rx_bit
RECEIVE
WORD-TO-OCTETS
OCTETS-TO-WORD
we_tpd<31:0>
we_tp_en<3:0>
we_tp_er<3:0>
tpd<7:0>
tp_en
tp_er
WORD DECODE
wd_rpd<31:0>
wd_rp_dv<3:0>
wd_rp_er<3:0>
rpd<7:0>
rp_dv
rp_er
tx_code-group<9:0>
rx_code-group<9:0>
2.5GPII
tx_even
sync_status
tpd<7:0>
tp_en
tp_er
tx_even
tx_quiet
rx_quiet
signal_detect
LPI_TRANSMIT
signal_detect

127.2.2 Functions within the PCS
The PCS includes the Word Encode, Word-to-Octets, Transmit, Synchronization, Receive, Octets-to-Word, 
and Word Decode processes for 2.5GBASE-X. The PCS shields the RS (and MAC) from the specific nature 
of the underlying channel.
When communicating with the XGMII, the PCS uses, in each direction, 32 data signals (TXD <31:0> and 
RXD <31:0>), four control signals (TXC <3:0> and RXC <3:0>), and a clock (TX_CLK and RX_CLK).
When communicating with the PMA, the PCS uses a ten-bit-wide synchronous data path, tx_code-
group<9:0> and rx_code-group<9:0>, which conveys ten-bit code-groups. At the PMA Service Interface, 
code-group alignment and MAC packet delimiting are made possible by embedding special non-data code-
groups in the transmitted code-group stream. The PCS provides the functions necessary to map packets 
between the XGMII format and the PMA service interface format.
The Word Encode process continuously generates four 2.5GPII symbols (we_tpd<31:0>) and associated 
four bits of transmit enable (we_tp_en<3:0>) and four bits of transmit error (we_tp_er<3:0>) based upon the 
TXD <31:0> and TXC <3:0> signals on the XGMII, sending them to the Word-to-Octets process.
The Word-to-Octets process takes the four 2.5GPII symbols, and associated transmit enable and transmit 
error, and transmits one 2.5GPII symbol (tpd<7:0>) and its associated transmit enable (tp_en) and transmit 
error (tp_er) at a time to the PCS Transmit Process.
The Word-to-Octets process takes the output of the Word Encoder and presents one symbol at a time (tp_en, 
tp_er, tpd<7:0>) to the PCS transmit process. we_tpd<7:0> is presented first and we_tpd<31:24> is 
presented last.
The PCS Synchronization process continuously accepts code-groups via the PMA_UNITDATA.indication 
primitive 
and 
conveys 
received 
code-groups 
to 
the 
PCS 
Receive 
process 
via 
the 
SYNC_UNITDATA.indication primitive. The PCS Synchronization process sets the sync_status flag to 
indicate whether the PMA is functioning dependably.
The PCS Receive process continuously accepts code-groups via the SYNC_UNITDATA.indication 
primitive. The PCS Receive process monitors these code-groups and generates rpd<7:0>, rp_dv, and rp_er 
on the 2.5GPII.
The Octets-to-Word process queues the received 2.5GPII symbols and aligns them in groups of four 2.5GPII 
symbols. Symbols may be deleted or idle symbols added in order to do the alignment.
The Word Decode process continuously accepts the four 2.5GPII symbols from the Octets-to-Word process 
and generates RXD <31:0> and RXC <3:0> on the XGMII.
All PCS processes are described in detail in the state diagrams in 127.2.7.2.
127.2.3 PCS used with 2.5GBASE-KX PMD
The following requirements apply to a PCS used with a 2.5GBASE-KX PMD. Support for the Auto-
Negotiation process defined in Clause 73 is mandatory. The PCS shall support the primitive 
AN_LINK.indication(link_status) (see 73.9). The parameter link_status shall take the value FAIL when 
code_sync_status=FAIL and the value OK when code_sync_status =OK. The primitive shall be generated 
when the value of link_status changes.

127.2.4 Use of code-groups
The transmission code used by the PCS, referred to as 8B/10B, is identical to that specified in Clause 36. 
The PCS maps XGMII characters into an intermediate 2.5GPII which is then mapped to 10-bit code-groups, 
and vice versa, using the 8B/10B block coding scheme. Implicit in the definition of a code-group is an 
establishment of code-group boundaries by a PCS Synchronization process. The 8B/10B transmission code 
as well as the rules by which the PCS ENCODE and DECODE functions generate, manipulate, and interpret 
code-groups are specified in 127.2.6. The XGMII to 2.5GPII mapping and vice versa are specified in 
127.2.5. Code-groups and the 2.5GPII are unobservable and have no meaning outside the PCS.
127.2.5 XGMII to 2.5GPII mapping
The Word Encode, Word-to-Octets, Octets-to-Word, and Word Decode processes together define the XGMII 
to 2.5GPII mapping. This mapping function formats and serializes/deserializes the data between the four 
XGMII lanes and the single lane of the PCS transmit/receive process.
127.2.5.1 2.5 Gb/s PCS Internal Interface (2.5GPII)
The 2.5 Gb/s PCS Internal Interface (2.5GPII) is a logical interface that is internal to the 2.5GBASE-X PCS 
and exists solely for the purposes of defining the 2.5GBASE-X PCS functionality. Physical implementation 
of the 2.5GPII is optional and is not exposed outside of the PCS.
A 2.5GPII symbol is defined to be a set of tp_en, tp_er, tpd<7:0> variables on the transmit path, and rp_dv, 
rp_er, rpd<7:0> variables on the receive path. The permissible encodings are shown in Table 127–1 and 
Table 127–2. The Word Encode and Word Decode processes maps between the four XGMII lanes to four 
2.5GPII symbols. The 2.5GPII symbols are indexed as we_tp_en<3:0>, we_tp_er<3:0>, we_tpd<31:0>, 
wd_rp_dv<3:0>, wd_rp_er<3:0>, and wd_rpd<31:0>. The nominal rate of operation is 78.125 Msymbols/s 
± 100 ppm.
The Word-to-Octets and Octets-to-Word processes serializes/de-serializes four 2.5GPII symbols, and their 
associated enable and error bits, to/from four consecutive single 2.5GPII symbols. The nominal rate of 
operation of 2.5GPII symbols is 312.5 Msymbols/s ± 100 ppm.
Table 127–1—Permissible encodings of tpd<7:0>, tp_en, tp_er at 2.5GPII
tp_en
tp_er
tpd<7:0>
Description
Mnemonic
0x00 to 0xFF
Normal Inter-
frame
Idle
0x00
Reserved
0x01
Assert LPI
LPI
0x02 to 0x9B
Reserved
0x9C
Sequence
Seq
0x9D to 0xFF
Reserved
0x00 to 0xFF
Data
Data X
0x00 to 0xFF
Transmit Error
Err

127.2.5.2 Word Encode
The Word Encode process maps the four XGMII lanes (see Table 46–2) onto four 2.5GPII symbols, and 
their associated transmit enable and transmit error bits, as shown in Table 127–3. The XGMII encoding is 
specified in Table 46–3. The 2.5GPII encoding is specified in Table 127–1. The mapping of the sequence 
ordered set is dependent on the current state of the wencode_state variable as shown in column 5. The state 
of wencode_state is updated once the mapping occurs per the last column.
A sequence ordered set ||Q|| appears to the PMA as /K28.5/W/K28.5/W/K28.5/W/K28.5/W/. On the 2.5GPII 
this appears as Seq, Data S0, Seq, Data S1, Seq, Data S2, Seq, Data S3. The same sequence ordered set is 
assumed to be repeating over multiple XGMII cycles. Every alternating consecutive sequence ordered set on 
the XGMII is ignored. If a sequence ordered set occurs over odd number of cycles on the XGMII, then the 
final one will be truncated as Seq, Data S0, Seq, Data S1 and Seq, Data S2, Seq, Data S3 are not sent.
The 24-bit Data X, Data Y, and Data Z from the sequence ordered set is mapped to Data S0, Data S1, Data 
S2, Data S3 as shown in Equation (127-1).
S0<7> = S3<7> = 0, S1<7> = S2<7> = 1
S0<5:0> = Data X<5:0>
S1<5:0> = Data Y<3:0>, Data X<7:6>
S2<5:0> = Data Z<1:0>, Data Y<7:4>
S3<5:0> = Data Z<7:2>
Sn<6> = Sn<7> if Sn<2> = 0
Sn<6> = Sn<5> if Sn<2> = 1
(127-1)
The signal ordered set |Fsig| uses the same equation except S2<7> is set to 0.
Since sequence ordered set can be sent back to back it is necessary to determine the boundaries of the 
ordered set. {S0<7>, S1<7>, S2<7>, S3<7>} can be used to determine the boundary. {S0<7>, S1<7>} will 
always be 01, while the 01 combination will never occur over {S1<7>, S2<7>}, {S2<7>, S3<7>}, or 
{S3<7>, S0<7>}.
Only 128 combinations of Sn<7:0> are possible. When encoded to their 10-bit equivalent, these 128 code-
groups are defined to be in the set of /W/ (see 127.2.7.1.2).
Table 127–2—Permissible encodings of rpd<7:0>, rp_dv, rp_er at 2.5GPII
rp_dv
rp_er
rpd<7:0>
Description
Mnemonic
0x00 to 0xFF
Normal Inter-frame
Idle
0x00
Reserved
0x01
Assert LPI
LPI
0x02 to 0x0D
Reserved
0x0E
False carrier indication
FCI
0x0F
Carrier Extend (odd byte packets)
CE
0x10 to 0x9B
Reserved
0x9C
Sequence
Seq
0x9D to 0xFF
Reserved
0x00 to 0xFF
Data
Data X
0x00 to 0xFF
Receive Error
Err

Table 127–3—Word Encode mapping
XGMII
wencode
_state
(n)
2.5GPII
wencode
_state
(n+1)
Lane 0
Lane 1
Lane 2
Lane 3
wd_tpd<7:0>
we_tp_en<0>
we_tp_er<0>
wd_tpd<15:8>
we_tp_en<1>
we_tp_er<1>
wd_tpd<23:16>
we_tp_en<2>
we_tp_er<2>
wd_tpd<31:24>
we_tp_en<3>
we_tp_er<3>
Data A or 
Err
Data B or 
Err
Data C or 
Err
Data D or 
Err
Don’t care
=>
Data A or Err
Data B or Err
Data C or Err
Data D or Err
DATA
Idle
Idle
Idle
Idle
Don’t care
=>
Idle
Idle
Idle
Idle
IDLE
LPI
LPI
LPI
LPI
Don’t care
=>
LPI
LPI
LPI
LPI
DATA
Start
Data A or 
Err
Data B or 
Err
Data C or 
Err
Don’t care
=>
 Data 0x55
Data A or Err
Data B or Err
Data C or Err
DATA
Terminate
Idle
Idle
Idle
Don’t care
=>
Idle
Idle
Idle
Idle
IDLE
Data A or 
Err
Terminate
Idle
Idle
Don’t care
=>
Data A or Err
Idle
Idle
Idle
DATA
Data A or 
Err
Data B or 
Err
Terminate
Idle
Don’t care
=>
Data A or Err
Data B or Err
Idle
Idle
DATA
Data A or 
Err
Data B or 
Err
Data C or 
Err
Terminate
Don’t care
=>
Data A or Err
Data B or Err
Data C or Err
Idle
DATA
Sequence
Data X
Data Y
Data Z
IDLE
=>
Seq
Data S0
Seq
Data S1
SEQ
Sequence
Data X
Data Y
Data Z
SEQ
=>
Seq
Previous 
Data S2 a
Seq
Previous 
Data S3 a
IDLE
Sequence
Data X
Data Y
Data Z
DATA
=>
Idle
Idle
Idle
Idle
IDLE
else
Don’t care
=>
Err
Err
Err
Err
DATA
a Previous Data S2 and Previous Data S3 are the values of S2 and S3 respectively as calculated by Equation (127-1) during the previous mapping.

127.2.5.3 Word-to-Octets
The Word-to-Octets process takes the output of the Word Encoder and presents one symbol at a time (tp_en, 
tp_er, tpd<7:0>) to the PCS transmit process. we_tpd<7:0> is presented first and we_tpd<31:24> is 
presented last.
The Word-to-Octets process shall be synchronized to the PCS transmit process such that the 
we_tpd<7:0>and we_tpd<23:16> symbols are presented to the PCS transmit process which will result in the 
corresponding ordered set to be output to the PMA when the variable tx_even is TRUE and 
we_tpd<15:8>and we_tpd<31:24> variables when tx_even is FALSE.
127.2.5.4 Octets-to-Word
The Octets-to-Word process de-serializes the output of the PCS receive process to four symbols 
(wd_rp_dv<3:0>, wd_rp_er<3:0>, wd_rpd<31:0>). wd_rpd<7:0> is the earliest to arrive and 
wd_rpd<31:24> is the last.
The Octets-to-Word process inserts idle symbols or deletes symbols from the sequence of rpd<7:0> symbols 
received to achieve the following conditions:
a)
A transition of a 2.5GPII idle symbol to a data or error symbol shall place the data or error symbol 
on wd_rpd<7:0>.
b)
A transition of a 2.5GPII idle symbol to a LPI symbol shall place the LPI symbol on either 
wd_rpd<7:0> or wd_rpd<23:16>.
c)
A transition of a 2.5GPII LPI symbol to an idle symbol shall place the idle symbol on either 
wd_rpd<7:0> or wd_rpd<23:16>.
d)
The start of ||Q|| or ||Fsig|| set shall always occur on wd_rpd<7:0>. 127.2.5.2 describes how the start 
of |Q| and |Fsig| can be determined.
The Octets-to-Word process maintains a Deficit Idle Count (DIC) that represent the cumulative count of idle
symbols in rpd<7:0> added or deleted from the sequence of received symbols. The DIC is incremented by 
one for each idle symbol deleted and decremented by one for each idle symbol added. The DIC shall be 
bounded to a minimum of 0 and a maximum of 3.
Note that in a properly behaved system, deletion of idle symbols from rpd<7:0> onto wd_rpd<31:0> should 
only occur at most once at the beginning of link, and afterwards no further insertions or deletions are 
required. In order to interoperate with the application described in Annex 127A, additional symbol 
insertions and deletions may be required during normal operation.
The only symbol that may be inserted is a idle symbol. However any symbol may be deleted. Usually this 
will either be idle or LPI symbols, though in pathological error conditions (e.g., unterminated packet 
followed immediately with sequence ordered set) some other symbol may be deleted.

127.2.5.5 Word Decode
The Word Decode process maps the four 2.5GPII symbols onto the four XGMII lanes (see Table 46–2) as 
shown in Table 127–4. The XGMII encoding is specified in Table 46–4. The seq_s2_s3 variable indicates 
whether the next four 2.5GPII symbols are of the form Sequence, Data, Sequence, Data. The 2.5GPII 
encoding is specified in Table 127–2. The mapping is dependent on the current state of the wdecode_state 
and next_seq_s2_s3 variables as shown in columns 5 and 6. The state of wdecode_state is updated once the 
mapping occurs per the last column.
The 24-bit Data X, Data Y, and Data Z from the sequence ordered is reconstructed from Data S0, Data S1, 
Data S2, Data S3 according to Equation (127-2).
Data X<7:0> = S1<1:0>, S0<5:0>
Data Y<7:0> = S2<3:0>, S1<5:2>
Data Z<7:0> = S3<5:0>, S2<5:4>
(127-2)
127.2.6 8B/10B transmission code
The transmission code used by the PCS, referred to as 8B/10B, is identical to that specified in Clause 36. In 
addition to the requirements in this clause, a 2.5GBASE-X PCS shall also meet the 8B/10B transmission 
code requirements specified in 36.2.4.1 through 36.2.4.6, 36.2.4.8, and 36.2.4.9. The relationship of code-
group bit positions to PMA and other PCS constructs is illustrated in Figure 127–3.
127.2.6.1 Notation conventions
The 8B/10B transmission code uses letter notation for describing the bits of an unencoded information octet 
and a single control variable according to 36.2.4.1.
127.2.6.2 Transmission order
Code-group bit transmission order is illustrated in Figure 127–3 and defined in 36.2.4.2.
8B/10B 
Encoder
tpd<7:0>
(312.5 million octets/s)
PMA Service Interface
(312.5 million code-groups/s)
8B/10B 
Decoder
PMA Service Interface
(312.5 million code-groups/s)
0 1 2 3 4 5 6 7 8 9
Figure 127–3—PCS 8B/10B reference diagram
0 1 2 3 4 5 6 7 8 9
PCS DECODE function
PCS ENCODE function
7 6 5 4 3 2 1 0
Output of ENCODE function
Input to DECODE function
8  control
8  control
0 0 1 1 1 1 1 x x x
Properly aligned comma symbol
rx_code-group<9:0>
tx_code-group<9:0>
a b c d e i f g h j
a b c d e i f g h j
Input to ENCODE function
Output of DECODE function
H G F E D C B A
H G F E D C B A
7 6 5 4 3 2 1 0
PMD Service Interface
(3125 million rx_bits/s)
bit 0 is received first
PMD Service Interface
(3125 million tx_bits/s)
rpd<7:0>
2.5GPII
(312.5 million octets/s)
2.5GPII
bit 0 is transmitted first

Table 127–4—Word Decode mapping
2.5GPII
wdecode
_state
(n)
next_
seq_s2_s3 a
XGMII
wdecode
_state
(n+1)
wd_rpd<7:0>
we_rp_en<0>
we_rp_er<0>
wd_rpd<15:8>
we_rp_en<1>
we_rp_er<1>
wd_rpd<23:16>
we_rp_en<2>
we_rp_er<2>
wd_rpd<31:24>
we_rp_en<3>
we_rp_er<3>
Lane 0
Lane 1
Lane 2
Lane 3
Data A or Err
Data B or Err
Data C or Err
Data D or Err
≠IDLE
Don't care
=>
Data A or 
Err
Data B or 
Err
Data C or 
Err
Data D or 
Err
DATA
Data 
Data A or Err
Data B or Err
Data C or Err
IDLE
Don't care
=>
SOP
Data A or 
Err
Data B or 
Err
Data C or 
Err
DATA
Idle
Idle
Idle
Idle
≠ DATA
Don't care
=>
Idle
Idle
Idle
Idle
IDLE
Idle
Idle
Idle
Idle
DATA
Don't care
=>
Terminate
Idle
Idle
Idle
IDLE
Data A or Err
Idle or CE
Idle
Idle
DATA
Don't care
=>
Data A or 
Err
Terminate
Idle
Idle
IDLE
Data A or Err
Data B or Err
Idle
Idle
DATA
Don't care
=>
Data A or 
Err
Data B or 
Err
Terminate
Idle
IDLE
Data A or Err
Data B or Err
Data C or Err
Idle or CE
DATA
Don't care
=>
Data A or 
Err
Data B or 
Err
Data C or 
Err
Terminate
IDLE
LPI
LPI
LPI
LPI
≠ DATA
Don't care
=>
LPI
LPI
LPI
LPI
IDLE
Idle
Idle
LPI
LPI
Don't care
Don't care
=>
LPI
LPI
LPI
LPI
IDLE
LPI
LPI
Idle
Idle
≠ DATA
Don't care
=>
Idle
Idle
Idle
Idle
IDLE
Seq
Data S0
Seq
Data S1
≠ DATA
TRUE
=>
Sequence
Data X
Data Y
Data Z
SEQ
Seq
Data S0
Seq
Data S1
≠ DATA
FALSE
=>
Idle
Idle
Idle
Idle
IDLE
Seq
Data S2
Seq
Data S3
SEQ
Don't care
=>
Sequence
Data X
Data Y
Data Z
IDLE
else
Don’t care
=>
Err
Err
Err
Err
ERR
a next_seq_s2_s3 is TRUE when the next four GPII octets represent the S2 and S3 sequence ordered set and FALSE otherwise.

127.2.6.3 Generating code-groups and checking the validity of received code
Valid code-groups are defined in 36.2.4.3.
The running disparity rules are defined in 36.2.4.4.
The code-group generation is defined in 36.2.4.5.
The check on the validity of received code-groups is defined in 36.2.4.6.
127.2.6.4 Ordered sets
Table 127–5 lists the defined ordered sets, consisting of a single special code-group or combinations of 
special and data code-groups. Ordered sets which include /K28.5/ provide the ability to obtain bit and code-
group synchronization and establish ordered set alignment (see 36.2.4.9 and 127.3.2.4). Ordered sets provide 
for the delineation of a packet and synchronization between the transmitter and receiver circuits at opposite 
ends of a link. Certain PHYs include an option (see 78.3) to transmit or receive /LI/, /LI1/ and /LI2/ to 
support Energy-Efficient Ethernet (see Clause 78).
Ordered sets are specified according to the following rules:
a)
Ordered sets consist of either one, two, or eight code-groups.
b)
The first code-group of all ordered sets is always a special code-group.
c)
The second code-group of all multi-code-group ordered sets is always a data code-group. The 
second code-group is used to distinguish the ordered set from all other ordered sets. 
Table 127–5—Defined ordered sets
Code
Ordered Set
Number of
Code-Groups
Encoding
/I/
IDLE 
Correcting /I1/, Preserving /I2/
/I1/
     IDLE 1
/K28.5/D5.6/
/I2/
     IDLE 2
/K28.5/D16.2/
Encapsulation
/R/
     Carrier_Extend
/K23.7/
/S/
     Start_of_Packet 
/K27.7/
/T/
     End_of_Packet
/K29.7/
/V/
     Error_Propagation
/K30.7/
/LI/
LPI
Correcting /LI1/, Preserving /LI2/
/LI1/
     LPI 1
/K28.5/D6.5/
/LI2/
     LPI 2
/K28.5/D26.4/
Link Status
/Q/
     Sequence ordered set
/K28.5/W0/K28.5/W1/K28.5/W2/
K28.5/W3a
a /W0/, /W1/, /W2/, /W3/ are the 10-bit /Dx.y/ version of S0, S1, S2, S3 as defined per 
127.2.5.2 and will never have a value of /D5.6/, /D16.2/, /D6.5/, /D26.4/. 
Reserved
/Fsig/
     Signal ordered set
/K28.5/W0/K28.5/W1/K28.5/W2/
K28.5/W3a

127.2.6.5 Comma considerations
The comma considerations are described in 36.2.4.8 and 36.2.4.9.
127.2.6.6 Sequence (/Q/)
A sequence ordered set is used to convey various optional link status such as local fault or remote fault. The
24-bit data of the sequence ordered set on the XGMII,when implemented, are mapped to S0, S1, S2, S3 (see 
127.2.5.2), and /W0/, /W1/, /W2/, /W3/ are the 8B/10B mapped version.
S0, S1, S2, S3 are constructed such that each /Wn/ can be mapped to only 128 out of 256 possible /Dx.y/ 
code-groups. /W/ is defined to be the set of 128 /Dx.y/ code-groups that can appear in a sequence ordered 
set. /W/ does not contain /D5.6/, /D16.2/, /D6.5/, /D26.4/.
It is possible for the transmitter to send out a truncated sequence ordered set that appears as 
/K28.5/W0/K28.5/W1/. When a truncated sequence ordered set is received, the Word Decode process will 
convert it to idles.
127.2.6.7 Data (/D/)
A data code-group, when not used to distinguish or convey information for a defined ordered set, conveys 
one octet of arbitrary data supplied on the XGMII. The sequence of data code-groups is arbitrary, where any 
data code-group can be followed by any other data code-group. Data code-groups are coded and decoded but 
not interpreted by the PCS. Successful decoding of the data code-groups depends on proper receipt of the 
Start_of_Packet delimiter, as defined in 127.2.6.10 and the checking of validity, as defined in 36.2.4.6.
127.2.6.8 IDLE (/I/)
IDLE ordered sets (/I/) are transmitted continuously and repetitively whenever the XGMII is idle. /I/ 
provides a continuous fill pattern to establish and maintain clock synchronization. /I/ is emitted from, and 
interpreted by, the PCS. /I/ consists of one or more consecutively transmitted /I1/ or /I2/ ordered sets, as 
defined in Table 127–5.
The /I1/ ordered set is defined such that the running disparity at the end of the transmitted /I1/ is opposite 
that of the beginning running disparity. The /I2/ ordered set is defined such that the running disparity at the 
end of the transmitted /I2/ is the same as the beginning running disparity. The first /I/ following a packet or a 
sequence order set restores the current positive or negative running disparity to a negative value. All 
subsequent /I/s are /I2/ to ensure negative ending running disparity.
Distinct carrier events are separated by /I/s.
A received ordered set that consists of two code-groups, the first of which is /K28.5/ and the second of 
which is a data code-group other than any of the 128 possible /W/, /D21.5/, or /D2.2/ (or /D6.5/ or /D26.4/ to 
support EEE capability), is treated as an /I/ ordered set.
127.2.6.9 Low Power Idle (/LI/)
LPI is transmitted in the same manner as IDLE. LPI ordered sets (/LI/) are transmitted continuously and 
repetitively whenever the XGMII is indicating “Assert LPI”.
127.2.6.10 Start_of_Packet delimiter (SPD)
A Start_of_Packet delimiter (SPD) is used to delineate the starting boundary of a data transmission 
sequence. Upon  initiation of packet transmission, the PCS replaces the first octet of the MAC preamble with 

SPD. Upon initiation of packet reception, the PCS replaces the received SPD delimiter with the data octet 
value associated with the first preamble octet. A SPD delimiter consists of the code-group /S/, as defined in 
Table 127–5.
127.2.6.11 End_of_Packet delimiter (EPD)
An End_of_Packet delimiter (EPD) is used to delineate the ending boundary of a packet. The EPD is 
transmitted by the PCS following the last data octet comprising the FCS of the MAC packet. On reception, 
EPD is interpreted by the PCS as terminating a packet. A EPD consists of the code-groups /T/R/. If /R/ is 
transmitted in an even-numbered code-group position, the PCS appends a single additional /R/ to the code-
group stream to ensure that the subsequent /I/ is aligned on an even numbered code-group boundary. An /I/ 
always follows the conclusion of EPD. The /T/R/ or /T/R/R/ occupies part of the region considered by the 
MAC to be the IPG. The code-group /T/ and /R/ are defined in Table 127–5. 
127.2.6.12 Error_Propagation (/V/)
Error_Propagation (/V/) indicates that the PCS client wishes to indicate a transmission error to its peer 
entity. /V/ is emitted from the PCS when the XGMII indicates transmit error propagation, or when the 
XGMII presents a mapping that is undefined in Table 127–3 to the Word Encode process. The code group 
/V/ is defined in Table 127–5.
The presence of Error_Propagation or any invalid code-group on the medium denotes an error condition. 
Invalid code-groups are not intentionally transmitted onto the medium. 
127.2.7 Detailed functions and state diagrams
The body of this subclause comprises state diagrams, including the associated definitions of variables, 
constants, and functions. Should there be a discrepancy between a state diagram and descriptive text, the 
state diagram prevails. The notation used in the state diagrams follows the conventions of 21.5. State 
diagram timers follow the conventions of 14.2.3.2. 
127.2.7.1 State variables
127.2.7.1.1 Notation conventions
/x/
Denotes the constant code-group specified in 127.2.7.1.2 (valid code-groups have to follow the 
rules of running disparity as per 127.2.6.3).
[/x/]
Denotes the latched received value of the constant code-group (/x/) specified in 127.2.7.1.2 and 
conveyed by the SYNC_UNITDATA.indication message described in 127.2.7.1.6.
127.2.7.1.2 Constants
/COMMA/
The set of special code-groups which include a comma as specified in 36.2.4.9 and listed in 
Table 36–2.
/D/
The set of 256 code-groups corresponding to valid data, as specified in 127.2.6.7.
/Dx.y/
One of the set of 256 code-groups corresponding to valid data, as specified in 127.2.6.7.

/I/
The IDLE ordered set group, comprising either the /I1/ or /I2/ ordered sets, as specified in 
127.2.6.8.
/INVALID/
The set of invalid data or special code-groups, as specified in 36.2.4.6.
/Kx.y/
One of the set of 12 code-groups corresponding to valid special code-groups, as specified in 
Table 36–2.
/Q/
Sequence ordered set as specified in 127.2.6.6. A properly formed sequence order set appears as 
/K28.5/W/K28.5/W/K28.5/W/K28.5/W/. A truncated sequence order set appears as 
/K28.5/W/K28.5/W/.
/R/
The code-group used for the second and, if present, the third code-group in an End_of_Packet 
delimiter as specified in 127.2.6.11.
/S/
The code-group corresponding to the Start_of_Packet delimiter (SPD) as specified in 127.2.6.10.
/T/
The code-group used for the first code-group in the End_of_Packet delimiter  as specified in 
127.2.6.11.
/V/
The Error_Propagation code-group, as specified in 127.2.6.12.
/W/
The set of 128 code-groups that is generated by ENCODE(s<7:0>) where for all 128 possible 
values of x<6:0>
s<7> = x<6>, s<5:0> = x<5:0>, 
s<6> is set to x<5> when x<2> = 1; and s<6> is set to x<6> when x<2> = 0
NOTE— /W/ is a subset of /D/.
PL_LIMIT
The number of 2.5GPII symbols to preload in the Octets-to-Word process after release from the 
RESET state. The number of symbols to preload is implementation dependent and should be 
minimized to reduce latency. The minimum number has to be 3 to account for the deficit idle 
counting in 127.2.5.4.
The following constant is used only for the EEE capability:
/LI/
The LP_IDLE ordered set group, comprising either the /LI1/ or /LI2/ ordered sets, as specified in 
127.2.6.9.
127.2.7.1.3 Variables
assert_seq
Alias used for sequence ordered set, consisting of the following terms:
tp_en=0 * tp_er=1 * (tpd<7:0> = 0x9C)

cgbad
Alias for the following terms: ((rx_code-group/INVALID/) + (rx_code-
group=/COMMA/*rx_even=TRUE)) * PMA_UNITDATA.indication
cggood
Alias for the following terms: !((rx_code-group/INVALID/) + (rx_code-
group=/COMMA/*rx_even=TRUE)) * PMA_UNITDATA.indication
EVEN
The latched state of the rx_even variable, when rx_even=TRUE, as conveyed by the 
SYNC_UNITDATA.indication message described in 127.2.7.1.6.
mr_loopback
A Boolean that indicates the enabling and disabling of data being looped back through the PHY. 
Loopback of data through the PHY is enabled when Control register bit 3.0.14 is set to one.
Values:
FALSE; Loopback through the PHY is disabled.
TRUE; Loopback through the PHY is enabled.
mr_main_reset
Controls the resetting of the PCS via control register bit 3.0.15.
Values:
FALSE; Do not reset the PCS.
TRUE; Reset the PCS.
ODD
The latched state of the rx_even variable, when rx_even=FALSE, as conveyed by the 
SYNC_UNITDATA.indication message described in 127.2.7.1.6.
power_on
Condition that is true until such time as the power supply for the device that contains the PCS has 
reached the operating region. The condition is also true when the device has low power mode set 
via Control register bit 3.0.11.
Values:
FALSE; The device is completely powered (default).
TRUE; The device has not been completely powered.
NOTE—Power_on evaluates to its default value in each state where it is not explicitly set.
rpd<7:0>
Single lane 2.5GPII receive data from the PCS receive process.
wd_rpd<31:0>
Receive data from the Octets-to-Word process. x= 0, 1, 2, 3 for the four sets of 2.5GPII.
rp_dv
Single lane 2.5GPII receive data valid from the PCS receive process.
Values: 0 or 1.
wd_rp_dv<3:0>
Receive data valid from the Octets-to-Word process.
Values: 0 or 1.
rp_er
Single lane 2.5GPII receive error from the PCS receive process.
Values: 0 or 1.

wd_rp_er<3:0>
Receive error from the Octets-to-Word process.
Values: 0 or 1.
rx_bit
A binary parameter conveyed by the PMD_UNITDATA.indication service primitive, as specified 
in 128.2.2, to the PMA.
Values: ZERO; Data bit is a logical zero.
ONE; Data bit is a logical one.
rx_code-group<9:0>
A 10-bit vector represented by the most recently received code-group from the PMA. The element 
rx_code-group<0> is the least recently received (oldest) rx_bit; rx_code-group<9> is the most 
recently received rx_bit (newest). When code-group alignment has been achieved, this vector 
contains precisely one code-group.
rx_even
A Boolean set by the PCS Synchronization process to designate received code-groups as either 
even- or odd-numbered code-groups as specified in 127.2.6.2.
Values:
TRUE; Even-numbered code-group being received.
FALSE; Odd-numbered code-group being received.
RXC<3:0>
The RXC<3:0> signal of the XGMII as specified in Clause 46. Set by the Word Decode process.
RXD<31:0>
The RXD<31:0> signal of the XGMII as specified in Clause 46. Set by the Word Decode process.
signal_detect
A Boolean set by the PMD continuously via the PMD_SIGNAL.indication(SIGNAL_DETECT) 
message to indicate the status of the incoming link signal.
Values:
FAIL; A signal is not present on the link.
OK; A signal is present on the link.
sync_status
Alias used by the PCS receive state diagram, consisting of the following terms:
sync_status = code_sync_status + rx_lpi_active.
Values:
FAIL; A signal is not present on the link.
OK; A signal is present on the link.
NOTE—If EEE is not supported, the variable rx_lpi_active is always false, and this variable is identical to 
code_sync_status controlled by the synchronization state diagram.
tpd<7:0>
Single lane 2.5GPII transmit data to the PCS transmit process.
tpd_t1<7:0>
The value of tpd<7:0> latched by cg_timer_done = TRUE.
Values:
0 or 1.
we_tpd<31:0>
Transmit data output of the WORD ENCODE process.

tp_en
Single lane 2.5GPII transmit data enable to the PCS transmit process.
Values: 0 or 1.
we_tp_en<3:0>
Transmit data valid output of the WORD ENCODE process.
Values: 0 or 1.
tp_er
Single lane 2.5GPII transmit error to the PCS transmit process.
Values: 0 or 1.
we_tp_er<3:0>
Transmit error output of the WORD ENCODE process.
Values: 0 or 1.
tx_bit
A binary parameter used to convey data from the PMA to the PMD via the 
PMD_UNITDATA.request service primitive as specified in 128.2.1.
Values: ZERO; Data bit is a logical zero.
ONE; Data bit is a logical one.
tx_code-group<9:0>
A vector of bits representing one code-group, as specified in Table 36–1a through Table 36–1e, or 
Table 36–2, which has been prepared for transmission by the PCS Transmit process. This vector 
is conveyed to the PMA as the parameter of the PMD_UNITDATA.request(tx_bit) service 
primitive. The element tx_code-group<0> is the first tx_bit transmitted; tx_code-group<9> is the 
last tx_bit transmitted.
tx_disparity
A Boolean set by the PCS Transmit process to indicate the running disparity at the end of code-
group transmission as a binary value. Running disparity is described in 36.2.4.4.
Values:
POSITIVE
NEGATIVE
tx_even
A Boolean set by the PCS Transmit process to designate transmitted code-groups as either even or 
odd numbered code-groups as specified in 127.2.6.2.
Values:
TRUE; Even-numbered code-group being transmitted.
FALSE; Odd-numbered code-group being transmitted.
tx_o_set
One of the following defined ordered sets: /T/, /R/, /I/, /S/, /V/, /LI/, or one of the following code-
groups: /K28.5/ or /D/.
TXC<3:0>
The TXC<3:0> signal of the XGMII as specified in Clause 46.
TXD<31:0>
The TXD<31:0> signal of the XGMII as specified in Clause 46.

wdecode_state
Word Decoder State used by the Word Decode process to properly assemble the next XGMII value 
to output.
Values:
DATA;
IDLE;
SEQ;
wencode_state
Word Encoder State used by the Word Encode process to properly assemble the Sequence ordered 
set.
Values:
DATA;
IDLE;
SEQ;
xgmii_txc_lo<3:0>
The value of xgmii_txc_lo_neg<3:0> latched by the rising edge of TX_CLK.
xgmii_txc_lo_neg<3:0>
The value of TXC<3:0> latched by the falling edge of TX_CLK.
xgmii_txc_hi<3:0>
The value of TXC<3:0> latched by the rising edge of TX_CLK.
xgmii_txd_lo<31:0>
The value of xgmii_txd_lo_neg<31:0> latched by the rising edge of TX_CLK.
xgmii_txd_lo_neg<31:0>
The value of TXD<3:0> latched by the falling edge of TX_CLK.
xgmii_txd_hi<31:0>
The value of TXD<31:0> latched by the rising edge of TX_CLK.
The following variables are used only for the EEE capability:
assert_lpidle
Alias used for the optional LPI function, consisting of the following terms:

(tp_en=0 * tp_er=1 * (tpd<7:0> = 0x01))
code_sync_status
A parameter set by the PCS Synchronization process to reflect the status of the link as viewed by 
the receiver.
Values:
FAIL; The receiver is not synchronized to code-group boundaries.
OK; The receiver is synchronized to code-group boundaries.
idle_d
Alias for the following terms:
SUDI( ![/D21.5/] * ![/D2.2/]) when EEE is not supported, or 
SUDI(![/D21.5/] * ![/D2.2/] * ![/D6.5/] * ![/D26.4/] ) when EEE is supported.
rx_lpi_active
A Boolean variable that is set to TRUE when the receiver is in a low power state and set to FALSE 
when it is in an active state and capable of receiving data.

rx_quiet
A Boolean variable set to TRUE while in the RX_QUIET state and set to FALSE otherwise.
tx_quiet
A Boolean variable set to TRUE when the transmitter is in the TX_QUIET state and set to FALSE 
otherwise. When set to TRUE, the PMD will disable the transmitter as described in 128.6.5.
127.2.7.1.4 Functions
carrier_detect
In the PCS Receive process, this function uses for input the latched code-group ([/x/]) and latched 
rx_even (EVEN/ODD) parameters of the SYNC_UNITDATA.indication message from the PCS 
Synchronization process. When SYNC_UNITDATA.indication message indicates EVEN, the 
carrier_detect function detects carrier when either:
a)A two or more bit difference between [/x/] and both /K28.5/ encodings exists (see Table 36–2); 
or
b)A two to nine bit difference between [/x/] and the expected /K28.5/ (based on current running 
disparity) exists.
Values:
TRUE; Carrier is detected.
FALSE; Carrier is not detected.
check_end
Prescient End_of_Packet function used by the PCS Receive process. The check_end function 
returns the current and next two code-groups in rx_code-group<9:0>.
DECODE([/x]/)
In the PCS Receive process, this function takes as its argument the latched value of rx_code-
group<9:0> ([/x/]) and the current running disparity, and returns the corresponding 2.5GPII 
rpd<7:0>, as per Table 36–1a to Table 36–1e. DECODE also updates the current running disparity 
per the running disparity rules outlined in 36.2.4.4.
ENCODE(x)
In the PCS Transmit process, this function takes as its argument (x), where x is a 2.5GPII tpd<7:0> 
octet, and the current running disparity, and returns the corresponding ten-bit code-group as per 
Table 36–1a to Table 36–1e. ENCODE also updates the current running disparity variable 
tx_disparity per the running disparity rules outlined in 36.2.4.4.
NEXTSEQ
Prescient function used by the Word Decode process that returns whether the next four 2.5GPII 
symbols presented to the Word Decode process is of the form: Sequence, Data, Sequence, Data.
Values:
TRUE; Next four 2.5GPII symbols are Sequence, Data, Sequence, Data.
FALSE; Next four 2.5GPII symbols are not Sequence, Data, Sequence, Data.
signal_detectCHANGE
In the PCS Synchronization process, this function monitors the signal_detect variable for a state 
change. The function is set upon state change detection.
Values:
TRUE; A signal_detect variable state change has been detected.
FALSE; A signal_detect variable state change has not been detected (default).
NOTE—signal_detectCHANGE is set by this function definition; it is not set explicitly in the state 
diagrams. signal_detectCHANGE evaluates to its default value upon state entry.

SINSERT(x)
Add a single 2.5GPII symbol to the end of a queue that stores the 2.5GPII symbol presented by the 
receive process. The variable x is the 2.5GPII symbol (rp_dv, rp_er, rpd<7:0>). If x is a null set, 
then all content in the queue is emptied. The depth of the queue is implementation dependent.
VOID(x)
x  /D/, /T/, /R/, /K28.5/. Substitutes /V/ on a per code-group basis as requested by the 2.5GPII.
If [tp_en=0 * tp_er=1 * tpd<7:0>(0000 1111)],
then return /V/;
Else if [tp_en=1 * tp_er=1],
then return /V/;
Else return x.
WALIGN
In the PCS Octets-to-Word process, this function performs the alignment according to 127.2.5.4. 
Four 2.5GPII symbols (wd_rp_dv<3:0>, wd_rp_er<3:0>, wd_rpd<31:0>) are returned by this 
function. wd_rpd<7:0> is the earliest to arrive and wd_rpd<31:24> is last. The SINSERT(x) 
function adds 2.5GPII symbols to the queue. The WALIGN functions removes one to seven 
2.5GPII symbols from the front of the queue every time it is called.

When no 2.5GPII symbols are inserted or deleted, this function will return the first four 2.5GPII 
symbols in the queue and remove them from the queue.

When X 2.5GPII idles symbols are inserted, then X 2.5GPII idles symbols and the first 4 – X 
2.5GPII symbols are returned by the function, and the first 4 - X 2.5GPII symbols are removed 
from the queue.

When X 2.5GPII symbols are deleted, then the first X 2.5GPII symbols are removed from the 
queue, and the next four in the queue are returned by the function and then removed from the 
queue.
WDECODE(x, y, z)
In the PCS Word Decode process, this function performs the mapping according to 127.2.5.5. The 
variable x is four sets of 2.5GPII variables wd_rp_dv<3:0>, wd_rp_er<3:0>, wd_rpd<31:0>, the 
variable y is the current state of the wdecode_state variable, and the variable z indicates whether 
the next four 2.5GPII symbols are of the form: Sequence, Data, Sequence, Data.

The output is XGMII RXC<3:0>, RXD<31:0>, wdecode_state.
WENCODE(x, y)
In the PCS Word Encode process, this function performs the mapping according to  127.2.5.2. The 
variable x is xgmii_txc_lo<3:0> or xgmii_txc_hi<3:0>, xgmii_txd_lo<31:0> or 
xgmii_txd_hi<31:0>, and the variable y is the current state of the wencode_state variable.

The output is four sets of 2.5GPII variables and the updated state of the wencode_state variable 
and is ordered as follows: we_tp_en<3:0>, we_tp_er<3:0>, we_tpd<31:0>, wencode_state.
127.2.7.1.5 Counters
good_cgs
Count of consecutive valid code-groups received.

plcnt
Count of number the number of 2.5GPII symbols to preload in the Octets-to-Word process after 
release from the RESET state. The number of symbols to preload is implementation dependent and 
should be minimized to reduce latency.
The following counter is used only for the EEE capability:
wake_error_counter
A counter that is incremented each time that the LPI receive state diagram enters the RX_WTF 
state indicating that a wake time fault has been detected. The counter is reflected in register 3.22 
(see 45.2.3.12).
127.2.7.1.6 Messages
PMA_UNITDATA.indication(rx_code-group<9:0>)
A signal sent by the PMA Receive process conveying the next code-group received over the 
medium (see 127.3.1.2).
PMA_UNITDATA.request(tx_code-group<9:0>)
A signal sent to the PMA Transmit process conveying the next code-group ready for transmission 
over the medium (see 127.3.1.1).
PMD_SIGNAL.indication(SIGNAL_DETECT)
A signal sent by the PMD to indicate the status of the signal being received on the MDI.
PUDI
Alias for PMA_UNITDATA.indication(rx_code-group<9:0>).
PUDR
Alias for PMA_UNITDATA.request(tx_code-group<9:0>).
SUDI
Alias for SYNC_UNITDATA.indication(parameters).
SYNC_UNITDATA.indication(parameters)
A signal sent by the PCS Synchronization process to the PCS Receive process conveying the 
following parameters:
Parameters: [/x/]; the latched value of the indicated code-group (/x/);
EVEN/ODD; the latched state of the rx_even variable;
Value: EVEN; passed when the latched state of rx_even=TRUE.
ODD; passed when the latched state of rx_even=FALSE.
TX_OSET.indication
A signal sent to the PCS Transmit ordered set process from the PCS Transmit code-group process 
signifying the completion of transmission of one ordered set.
The following messages are used only for the EEE capability:
PMD_RXQUIET.request(rx_quiet)
A signal sent by the PCS/PMA LPI receive state diagram to the PMD. This message is ignored by 
devices that do not support EEE capability.
Values:
TRUE: The receiver is in a quiet state and is not expecting incoming data.
FALSE: The receiver is ready to receive data.

PMD_TXQUIET.request(tx_quiet)
A signal sent by the PCS/PMA LPI transmit state diagram to the PMD. This message is ignored 
by devices that do not support the optional LPI mechanism.
Values:
TRUE: The transmitter is in a quiet state and may cease to transmit a signal on the 
medium.
FALSE: The transmitter is ready to transmit data.
127.2.7.1.7 Timers
cg_timer
A continuous free-running timer. If XGMII is implemented, cg_timer shall expire synchronously 
with the rising edge of TX_CLK as well as every one-eighth of the TX_CLK cycle time (see 
tolerance required for TX_CLK in 46.3.1.1). In the absence of XGMII, cg_timer shall expire every 
3.2 ns ± 100 ppm.
Values: The condition cg_timer_done becomes true upon timer expiration.
Restart when: immediately after expiration; restarting the timer resets the condition 
cg_timer_done.
Duration:  3.2 ns nominal.
TX_CLK_timer
A continuous free-running timer. TX_CLK_timer shall expire synchronously with the rising edge 
of TX_CLK (see tolerance required for TX_CLK in 46.3.1.1).
Restart when: immediately after expiration.
Duration:  25.6 ns nominal.
The following timers are used only for the EEE capability:
rx_tq_timer
This timer is started when the PCS receiver enters the START_TQ_TIMER state. The timer 
terminal count is set to TQR. When the timer reaches terminal count, it will set the 
rx_tq_timer_done = TRUE.
rx_tw_timer
This timer is started when the PCS receiver enters the RX_WAKE state. The timer terminal count 
shall not exceed the maximum value of TWR in Table 127–7. When the timer reaches terminal 
count, it will set the rx_tw_timer_done = TRUE.
rx_wf_timer
This timer is started when the PCS receiver enters the RX_WTF state, indicating that the receiver 
has encountered a wake time fault. The rx_wf_timer allows the receiver an additional period in 
which to synchronize or return to the quiescent state before a link failure is indicated. The timer 
terminal count is set to TWTF. When the timer reaches terminal count, it will set the 
rx_wf_timer_done = TRUE.
tx_tq_timer
This timer is started when the PCS transmitter enters the TX_QUIET state. The timer terminal 
count is set to TQL. When the timer reaches terminal count, it will set the tx_tq_timer_done = 
TRUE.

tx_tr_timer
This timer is started when the PCS transmitter enters the TX_REFRESH state. The timer terminal 
count is set to TUL. When the timer reaches terminal count, it will set the tx_tr_timer_done = 
TRUE.
tx_ts_timer
This timer is started when the PCS transmitter enters the TX_SLEEP state. The timer terminal 
count is set to TSL. When the timer reaches terminal count, it will set the tx_ts_timer_done = 
TRUE.
127.2.7.2 State diagrams
127.2.7.2.1 Word Encode and Word-to-Octets
The Word Encode process (see 127.2.5.2) and Word-to-Octets process (see 127.2.5.3) are merged into one 
state diagram depicted in Figure 127–4, including compliance with the associated state variables as specified 
in 127.2.7.1. 
The Word Encode process continuously maps the four XGMII lanes to four 2.5GPII symbols via the 
WENCODE function in the TX_XGMII_LO and TX_XGMII_HI states. The four 2.5GPII symbols are then 
serialized and output one at a time by the Word-to-Octets process. The presentation of the 2.5GPII symbols 
are synchronized to the PCS transmit process such that the 2.5GPII index 0 and 2 symbols are presented to 
the PCS transmit process which will result in the corresponding ordered set to be output to the PMA when 
the variable tx_even is TRUE and index 1 and 3 variables when tx_even is FALSE.
127.2.7.2.2 Transmit
The PCS Transmit process is depicted in two state diagrams: PCS Transmit ordered set and PCS Transmit 
code-group. The PCS shall implement its Transmit process as depicted in Figure 127–5 and Figure 127–6, 
including compliance with the associated state variables as specified in 127.2.7.1.          
The Transmit ordered set process continuously sources ordered sets to the Transmit code-group process. 
Upon the assertion of tp_en by the 2.5GPII, the SPD ordered set is sourced. Following the SPD, /D/ code-
groups are sourced until tp_en is deasserted. Following the de-assertion of tp_en, EPD ordered sets are 
sourced. If tp_en and tp_er are both deasserted, the /R/ ordered set may be sourced, after which the sourcing 
of /I/ is resumed. If, while tp_en is asserted, the tp_er signal is asserted, the /V/ ordered set is sourced except 
when the SPD ordered set is selected for sourcing. If the 2.5GPII indicates sequence, then /Q/ ordered sets
are sourced. If the optional EEE is enabled and the 2.5GPII indicates low power idles, then /LI/ ordered sets
are sourced.
The Transmit code-group process continuously sources tx_code-group<9:0> to the PMA based on the 
ordered sets sourced to it by the Transmit ordered set process. The Transmit code-group process determines 
the proper code-group to source based on even/odd-numbered code-group alignment, running disparity 
requirements, and ordered set format.

Figure 127–4—PHY TX control state diagram
TX_CLK_rising_done *
RESET
tp_en  0
TX_XGMII_LO
power_on=TRUE + 
mr_main_reset=TRUE 
tx_even=FALSE *
tp_er  0
tpd<7:0>  0x00
wencode_state  IDLE
TX_2.5GPII_0
tp_en  we_tp_en<0>
tp_er   we_tp_er<0>
tpd<7:0>  we_tpd<7:0>
TX_2.5GPII_1
tp_en  we_tp_en<1>
tp_er   we_tp_er<1>
tpd<7:0>  we_tpd<15:8>
cg_timer_done
TX_2.5GPII_2
tp_en  we_tp_en<2>
tp_er   we_tp_er<2>
tpd<7:0>  we_tpd<23:16>
cg_timer_done
TX_2.5GPII_3
tp_en  we_tp_en<3>
tp_er   we_tp_er<3>
tpd<7:0>  we_tpd<31:24>
cg_timer_done
TX_2.5GPII_4
tp_en  we_tp_en<0>
tp_er   we_tp_er<0>
tpd<7:0>  we_tpd<7:0>
TX_2.5GPII_5
tp_en  we_tp_en<1>
tp_er   we_tp_er<1>
tpd<7:0>  we_tpd<15:8>
TX_2.5GPII_6
tp_en  we_tp_en<2>
tp_er   we_tp_er<2>
tpd<7:0>  we_tpd<23:16>
TX_2.5GPII_7
tp_en  we_tp_en<3>
tp_er   we_tp_er<3>
tpd<7:0>  we_tpd<31:24>
TX_XGMII_HI
{we_tp_en<3:0>,we_tp_er<3:0>,we_tpd<3:0><7:0>,wencode_state}  
WENCODE(xgmii_txc_hi<3:0>,xgmii_txd_hi<31:0>,wencode_state)
UCT
{we_tp_en<3:0>,we_tp_er<3:0>,we_tpd<31:0>,wencode_state}  
WENCODE(xgmii_txc_lo<3:0>,xgmii_txd_lo<31:0>,wencode_state)
cg_timer_done 
cg_timer_done
cg_timer_done
UCT
we_tpd_en<3:2>  0
we_tpd_er<3:2>  0
we_tpd<31:16>  0x0000
xgmii_txc_lo_neg<3:0> = 0xF
TX_CLK_rising_done *
tx_even=TRUE *
xgmii_txc_lo_neg<3:0> = 0xF
cg_timer_done
cg_timer_done

Figure 127–5—PCS transmit ordered set state diagram
START_ERROR 
tx_o_set /S/
TX_OSET.indication
ALIGN_ERR_START
tp_er=0 
XMIT_DATA
tx_o_set /I/
START_OF_PACKET
tp_en=1 
tp_er=1 
tx_o_set /S/
tp_en=0 
tp_er1
END_OF_PACKET_EXT
tx_o_set /T/
END_OF_PACKET_NOEXT
EPD2_NOEXT
tx_o_set /R/
tp_er1 
tp_en1 
tp_er0 
EPD3
tx_o_set /R/
tp_er=0 
CARRIER_EXTEND
tx_o_set VOID(/R/)
tp_en0 
tp_er1 
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
tp_en0 
tp_er0 
TX_OSET.indication
TX_DATA_ERROR
tx_o_set /V/
EXTEND_BY_1
tx_o_set /R/
TX_OSET.indication
tx_even=FALSE 
TX_OSET.indication
tx_even=TRUE 
TX_OSET.indication
TX_PACKET
TX_DATA 
tx_o_set VOID(/D/)
tp_en=1
tp_en=1 +
TX_TEST_XMIT
IDLE
tx_o_set /I/
power_on=TRUE + 
mr_main_reset=TRUE 
TX_OSET.indication
TX_OSET.indication
tx_o_set /T/
tp_en=0 
tp_er=0
tp_er=1
TX_OSET.indication 
tp_en=0tp_er=0
A
A
B
assert_lpidle *
C
XMIT_LPIDLE
tx_o_set /LI/
C
!assert_lpidle *
B
assert_lpidle *
TX_OSET.indication
TX_OSET.indication
TX_OSET.indication
NOTE—A transition inside a dashed box is only required for the EEE capability.
E
tp_en=0 
tp_er=0
D
assert_seq *
TX_OSET.indication
tp_en=1 
tp_er=1 
TX_OSET.indication
XMIT_SEQUENCE
tx_o_set /K28.5/
E
!assert_seq *
D
XMIT_SEQ_DATA
tx_o_set VOID(/D/)
TX_OSET.indication
assert_seq *
TX_OSET.indication
TX_OSET.indication
!assert_lpidle * 
!assert_seq * 
tp_en=0 * 
TX_OSET.indication
tp_en=1 

Figure 127–6—PCS transmit code-group state diagram
GENERATE_CODE_GROUPS
SPECIAL_GO
power_on=TRUE + mr_main_reset=TRUE
tx_o_set
tx_o_set/I/ + /LI/
IDLE_DISPARITY_TEST
IDLE_DISPARITY_WRONG
tx_code-group K28.5
tx_even TRUE
tx_disparity
tx_disparity
NEGATIVE
POSITIVE
IDLE_I1B
IF tx_o_set=/LI/
tx_even FALSE
TX_OSET.indication
IDLE_DISPARITY_OK
tx_code-group K28.5/
tx_even TRUE
cg_timer_done
cg_timer_done
cg_timer_done
cg_timer_done
cg_timer_done
DATA_GO
tx_code-group 
tx_o_set/D/
TX_OSET.indication
ENCODE(tpd_t1<7:0>)
/V/  /S/  /T/  /R/ + /K28.5/
tx_even tx_even
cg_timer_done
PUDR
PUDR
PUDR
PUDR
THEN (tx_code-group /D6.5/)
ELSE (tx_code-group /D5.6/)
IDLE_I2B
IF tx_o_set=/LI/
tx_even FALSE
TX_OSET.indication
PUDR
THEN (tx_code-group /D26.4/)
ELSE (tx_code-group /D16.2/)
IF tx_o_set= /R/ THEN
(tx_code-group /K23.7/)
ELSE IF tx_o_set= /S/ THEN
(tx_code-group  /K27.7/) 
ELSE IF tx_o_set= /T/ THEN
(tx_code-group  /K29.7/) 
ELSE IF tx_o_set= /V/ THEN
(tx_code-group /K30.7/) 
ELSE 
tx_code-group  /K28.5/
tx_even  ! tx_even
TX_OSET.indication
PUDR

127.2.7.2.3 Synchronization
The PCS shall implement the Synchronization process as depicted in Figure 127–7 including compliance 
with the associated state variables as specified in 127.2.7.1. The Synchronization process is responsible for 
determining whether the underlying receive channel is ready for operation. Failure of the underlying channel 
typically causes the PMA client to suspend normal actions.
A receiver that is in the LOSS_OF_SYNC state and that has acquired bit synchronization attempts to acquire 
code-group synchronization via the Synchronization process. Code-group synchronization is acquired by the 
detection of three ordered sets containing commas in their leftmost bit positions without intervening invalid 
code-group errors. Upon acquisition of code-group synchronization, the receiver enters the 
SYNC_ACQUIRED_1 state. Acquisition of synchronization ensures the alignment of multi-code-group 
ordered sets to even-numbered code-group boundaries.
Once synchronization is acquired, the Synchronization process tests received code-groups in sets of four 
code-groups and employs multiple sub-states, to move between the SYNC_ACQUIRED_1 and 
LOSS_OF_SYNC states.
For EEE capability the relationship between sync_status and code_sync_status is given by the definition of 
the sync_status variable in 127.2.7.1.3; otherwise sync_status is identical to code_sync_status.
127.2.7.2.4 Receive
The PCS shall implement its Receive process as depicted in Figure 127–8a and Figure 127–8b, including 
compliance with the associated state variables as specified in 127.2.7.1. The PCS shall implement 
Figure 127–8c if the optional EEE is present and enabled.
The PCS Receive process continuously passes rpd<7:0> and sets the rp_dv and rp_er signals to the 2.5GPII 
based on the received code-group from the PMA.          
127.2.7.2.5 Octets-to-Word and Decode
The Octets-to-Word process and Word decode process are merged into one state diagram depicted in 
Figure 127–9, including compliance with the associated state variables as specified in 127.2.7.1.
The Octets-to-Word process continuously queues the incoming 2.5GPII symbols from the PCS receive 
process and outputs four 2.5GPII symbols at a time using the WALIGN function. Symbols may be dropped 
or idles symbols added by the WALIGN function. The Word Decode process continuously maps the four 
2.5GPII symbols and presents them on the XGMII using the WDECODE function in the RX_XGMII state.

cgbad
cgbad
cggood 
good_cgs  3
Figure 127–7—Synchronization state diagram
LOSS_OF_SYNC
code_sync_status  FAIL
power_on=TRUE + mr_main_reset=TRUE +
(signal_detectOK mr_loopback=TRUE) 
PUDI([/COMMA/])
COMMA_DETECT_1
PUDI([/D/])
ACQUIRE_SYNC_1
PUDI(![/COMMA/]  [/INVALID/])
PUDI(![/D/])
(signal_detectCHANGETRUE 
rx_evenFALSE PUDI([/COMMA/])
COMMA_DETECT_2
SYNC_ACQUIRED_1
code_sync_status  OK
SYNC_ACQUIRED_2
rx_even   rx_even
cggood
rx_even   rx_even
rx_even  TRUE
rx_even   rx_even
rx_even   rx_even
rx_even  TRUE
SUDI
SUDI
SUDI
PUDI([/D/])
ACQUIRE_SYNC_2
rx_even   rx_even
SUDI
COMMA_DETECT_3
rx_even  TRUE
SUDI
PUDI([/D/])
SUDI
cgbad
good_cgs  0
SYNC_ACQUIRED_2A
rx_even   rx_even
SUDI
good_cgs  good_cgs + 1
cggood
SYNC_ACQUIRED_3
rx_even   rx_even
SUDI
good_cgs  0
SYNC_ACQUIRED_3A
rx_even   rx_even
SUDI
good_cgs  good_cgs + 1
cgbad
cgbad
good_cgs  3 cggood
SYNC_ACQUIRED_4
rx_even   rx_even
SUDI
good_cgs  0
SYNC_ACQUIRED_4A
rx_even   rx_even
SUDI
good_cgs  good_cgs + 1
cgbad
cgbad
SUDI
PUDI(![/D/])
PUDI(![/COMMA/]  [/INVALID/])
rx_evenFALSE PUDI([/COMMA/])
SUDI
cggood good_cgs  3
PUDI(![/D/])
(PUDI signal_detectFAIL 
mr_loopback=FALSE) 
PUDI(![/COMMA/])
cggood
cggood
cgbad
cgbad
cggood 
good_cgs  3
cggood 
good_cgs  3
3 cggood good_cgs  3
mr_loopback=FALSE PUDI)

Figure 127–8a—PCS receive state diagram, part a
NOTE 1 —Outgoing arcs leading to labeled polygons flow off page to corresponding incoming arcs 
leading from labeled circles on Figure 127–8b and Figure 127–8c, and vice versa.
NOTE 2—The transitions from the CARRIER_DETECT state is a test against the codegroup obtained 
from the SUDI that caused the transition to the CARRIER_DETECT state.
LINK_FAILED
B
0_CARRIER
rp_er 1
rpd<7:0> 0000 1110
CARRIER_DETECT
A
[/S/]
![/S/]
RX_K
SUDI/D6.5/] +
IDLE_D
rp_er 0 
rx_lpi_active FALSE
SUDI  
carrier_detectTRUE
SUDI([/K28.5/]  EVEN)
C
SUDI  
carrier_detectFALSE 
WAIT_FOR_K
SUDI([/K28.5/]  EVEN)
power_on=TRUE + mr_main_reset=TRUE
sync_status=FAIL SUDI
SUDI
rp_dv 0
IF check_end=/K28.5/W/don’t care/
rp_dv 0
rp_er 0
[/D26.4/])
G
rx_lpi_active FALSE
E
rp_dv 0
rp_er 0
idle_d
rpd<7:0> 1001 1100
IF [/x/] /W/
THEN rp_dv 1
rpd<7:0> DECODE([/x/])
ELSE rp_dv 0
ELSE IF (check_end=/K28.5/D6.5/ don’t care/ +
check_end=/K28.5/D26.4/don’t care/)
THEN rp_er <= 1
rpd<7:0> <= 0000 0001
ELSE rp_er <= 0
rp_er <= 1

Figure 127–8b—PCS receive state diagram, part b
START_OF_PACKET
rp_dv 1
rpd<7:0> 0101 0101
RECEIVE
RX_DATA_ERROR
RX_DATA
rp_er 0
[/D/] 
rp_er 1
check_end/T/R/R/
EPD2_CHECK_END
check_end/R/R/K28.5/  EVEN
TRIRRI
EXTEND_ERR
rp_dv 1
check_end/T/R/K28.5/ 
EARLY_END
rp_er 1
TRREXTEND
EVEN 
rp_dv 0
rp_er 1
rpd<7:0> 0000 1111
rp_dv 0
rp_er 0
SUDI([/S/])
rpd<7:0> DECODE([/x/])
rp_er 1
rp_er 0
A
B
SUDI([/K28.5/]  EVEN)
check_end/K28.5/D/K28.5/) *
EVEN
ELSE
EARLY_END_EXT
rp_er 1
SUDI(![/S/]  !([/K28.5/]  EVEN))
ELSE
SUDI
SUDI
B
SUDI([/K28.5/])
SUDI
SUDI
SUDI
check_end/R/R/R/
NOTE 1—Outgoing arcs leading to labeled polygons flow off page to corresponding incoming arcs leading from 
labeled circles on Figure 127–8a, and vice versa.
NOTE 2—In the transition from RECEIVE to RX_DATA state the transition condition is a test against the code-
group obtained from the SUDI that caused the transition to RECEIVE state.
C
SUDI([/D21.5/] 
[/D2.2/])

RX_SLEEP
rx_lpi_active  TRUE
rp_dv 
rp_er 
rpd<7:0> 0000 0001
RX_QUIET
rx_quiet  TRUE
RX_LINK_FAIL
rx_quiet  FALSE
rx_lpi_active  FALSE
RX_WAKE
rx_quiet  FALSE
Start rx_tw_timer
signal_detect=FAIL
signal_detect=OK
rx_tq_timer_done
rx_tw_timer_done
code_sync_status = OK *
RX_WTF
wake_error_counter++
Start rx_wf_timer
rx_wf_timer_done
SUDI
I
E
UCT
LP_IDLE_D
Start rx_tq_timer
LPI_K
IF (check_end=/K28.5/D5.6/don’t care/ +
J
rx_tq_timer_done
SUDI(![/D5.6/] * ![/D16.2/] * ![/D6.5/] * ![/D26.4/])
signal_detect=FAIL
C
SUDI([/D5.6/] + [/D16.2/])
signal_detect=FAIL
signal_detect=FAIL
signal_detect=FAIL *
SUDI( [/K28.5/]*EVEN )
I
code_sync_status = OK *
SUDI( [/K28.5/]*EVEN )
signal_detect=OK *
signal_detect=OK *
signal_detect=OK *
signal_detect=OK *
!rx_tw_timer_done *
signal_detect=OK *
signal_detect=OK *
!rx_wf_timer_done *
signal_detect=OK *
START_TQ_TIMER
Start rx_tq_timer
J
SUDI([/D6.5/] + [/D26.4/])
signal_detect=OK *
G
UCT
RX_WAKE_DONE
Start rx_tq_timer
UCT
H
H
NOTE—Outgoing arcs leading to labeled polygons flow off page to corresponding incoming arcs leading 
from labeled circles on Figure 127–8a, and vice versa.
Figure 127–8c—PCS Receive state diagram, part c 
(only required for the optional EEE capability)
SUDI([/K28.5/])
signal_detect=OK *
!rx_tq_timer_done *
check_end=/K28.5/D16.2/don’t care/)
rp_dv <= 0
rp_err <= 0

Figure 127–9—Octets-to-Word and Decode state diagram
RESET
RXC<3:0> 0x1
power_on=TRUE + 
UCT
RXD<31:0> 0x0100009C
plcnt 0
wdecode_state IDLE
mr_main_reset=TRUE +
sync_status=FAIL*SUDI
PRELOAD
SINSERT()
SINSERT(rp_dv, rp_er, rpd<7:0>)
plcnt plcnt + 1
SUDI * plcnt = PL_LIMIT
RX_2.5GPII_0
SINSERT(rp_dv, rp_er, rpd<7:0>)
SUDI
RX_2.5GPII_1
SINSERT(rp_dv, rp_er, rpd<7:0>)
SUDI
RX_2.5GPII_2
SINSERT(rp_dv, rp_er, rpd<7:0>)
SUDI
RX_2.5GPII_3
SINSERT(rp_dv, rp_er, rpd<7:0>)
SUDI
RX_XGMII
{RXC<3:0>,RXD<31:0>,wdecode_state}  
WDECODE(WALIGN, wdecode_state, NEXTSEQ)
SUDI * 
UCT
plcnt <PL_LIMIT

127.2.7.2.6 LPI state diagram
A PCS that supports the EEE capability shall implement the LPI transmit process as shown in 
Figure 127–10. The transmit LPI state diagram controls tx_quiet, which disables the transmitter when true.
The timer values for these state diagrams are shown in Table 127–6 for transmit and Table 127–7 for 
receive.
Table 127–6—Transmitter LPI timing parameters
Parameter
Description
Min
Max
Units
TSL
Local Sleep Time from entering the TX_SLEEP state to when tx_quiet is 
set to TRUE
19.9
20.1
µs
TQL
Local Quiet Time from when tx_quiet is set to TRUE to entry into the 
TX_REFRESH state
2.5
2.6
ms
TUL
Local Refresh Time from entry into the TX_REFRESH state to entry into 
the TX_QUIET state
19.9
20.1
µs
Figure 127–10—LPI Transmit state diagram
TX_ACTIVE
tx_quiet  FALSE
TX_SLEEP
Start tx_ts_timer
TX_QUIET
tx_quiet  TRUE
Start tx_tq_timer
TX_REFRESH
tx_quiet  FALSE
Start tx_tr_timer
power_on=TRUE + 
mr_main_reset=TRUE 
TX_OSET.indication * 
tx_oset  /LI/
TX_OSET.indication * 
tx_oset  /LI/
TX_OSET.indication * 
tx_oset  /LI/
TX_OSET.indication * 
tx_oset  /LI/
TX_OSET.indication * 
tx_oset  /LI/
TX_OSET.indication * tx_oset  /LI/ *
tx_ts_timer_done
TX_OSET.indication * tx_oset  /LI/ *
tx_tq_timer_done
TX_OSET.indication * tx_oset  /LI/ *
tx_tr_timer_done

127.2.7.2.7 LPI status and management
For EEE capability, the PCS indicates to the management system that LPI is currently active in the receive 
and transmit directions using the status variables shown in Table 36–10.
127.3 Physical Medium Attachment (PMA) sublayer
127.3.1 Service Interface
The PMA provides a Service Interface to the PCS. These services are described in an abstract manner and do 
not imply any particular implementation. The PMA Service Interface supports the exchange of code-groups 
between PCS entities. The PMA converts code-groups into bits and passes these to the PMD, and vice versa. 
It also generates an additional status indication for use by its client.
The following primitives are defined:
PMA_UNITDATA.request(tx_code-group<9:0>)
PMA_UNITDATA.indication(rx_code-group<9:0>)
127.3.1.1 PMA_UNITDATA.request
This primitive defines the transfer of data (in the form of code-groups) from the PCS to the PMA. 
PMA_UNITDATA.request is generated by the PCS Transmit process.
127.3.1.1.1 Semantics of the service primitive
PMA_UNITDATA.request(tx_code-group<9:0>)
The data conveyed by PMA_UNITDATA.request is the tx_code-group<9:0> parameter defined in 
127.2.7.1.3.
127.3.1.1.2 When generated
The PCS continuously sends, at a nominal rate of 312.5 MHz, tx_code-group<9:0> to the PMA.
127.3.1.1.3 Effect of receipt
Upon receipt of this primitive, the PMA generates a series of ten PMD_UNITDATA.request primitives, 
requesting transmission of the indicated tx_bit to the PMD.
Table 127–7—Receiver LPI timing parameters
Parameter
Description
Min
Max
Units
TQR
The time the receiver waits for signal detect to be set to OK while in the 
LP_IDLE_D, LPI_K and RX_QUIET states before asserting a rx_fault
ms
TWR
Time the receiver waits in the RX_WAKE state before indicating a wake 
time fault (WTF)
µs
TWTF
Wake time fault recovery time
ms

127.3.1.2 PMA_UNITDATA.indication
This primitive defines the transfer of data (in the form of code-groups) from the PMA to the PCS. 
PMA_UNITDATA.indication is used by the PCS Synchronization process.
127.3.1.2.1 Semantics of the service primitive
PMA_UNITDATA.indication(rx_code-group<9:0>)
The data conveyed by PMA_UNITDATA.indication is the rx_code-group<9:0> parameter defined in 
127.2.7.1.3.
127.3.1.2.2 When generated
The PMA continuously sends one rx_code-group<9:0> to the PCS corresponding to the receipt of each 
code-group aligned set of ten PMD_UNITDATA.indication primitives received from the PMD. The nominal 
rate of the PMA_UNITDATA.indication primitive is 312.5 MHz, as governed by the recovered bit clock.
127.3.1.2.3 Effect of receipt
The effect of receipt of this primitive by the client is unspecified by the PMA sublayer.
127.3.2 Functions within the PMA
Figure 127–2 and Figure 127–3 depict the mapping of the four octet-wide data path of the XGMII to the ten-
bit code-groups of the PMA Service Interface and on to the serial PMD Service Interface. The PMA 
comprises the PMA Transmit and PMA Receive processes for 2.5GBASE-X.
The PMA Transmit process serializes tx_code-groups into tx_bits and passes them to the PMD for 
transmission on the underlying medium, according to Figure 127–3. Similarly, the PMA Receive process 
deserializes rx_bits received from the PMD according to Figure 127–3. The PMA continuously conveys ten 
bit code-groups to the PCS, independent of code-group alignment. After code-group alignment is achieved, 
based on comma detection, the PCS converts code-groups into XGMII data octets, according to 127.2.7.2.4 
and 127.2.7.2.5.
The proper alignment of a comma used for code-group synchronization is depicted in Figure 127–3.
127.3.2.1 Data delay
The PMA maps a nonaligned one-bit data path from the PMD to an aligned, ten-bit-wide data path to the 
PCS, on the receive side. Logically, received bits have to be buffered to facilitate proper code-group 
alignment. These functions necessitate an internal PMA delay of at least ten bit times. In practice, code-
group alignment may necessitate even longer delays of the incoming rx_bit stream.
127.3.2.2 PMA transmit function
The PMA Transmit function passes data unaltered (except for serializing) from the PCS directly to the PMD. 
Upon receipt of a PMA_UNITDATA.request primitive, the PMA Transmit function shall serialize the ten 
bits of the tx_code-group<9:0> parameter and transmit them to the PMD in the form of ten successive 
PMD_UNITDATA.request primitives, with tx_code-group<0> transmitted first, and tx_code-group<9> 
transmitted last.

127.3.2.3 PMA receive function
The PMA Receive function passes data unaltered (except for deserializing and possible code-group slipping 
upon code-group alignment) from the PMD directly to the PCS. Upon receipt of ten successive 
PMD_UNITDATA.indication primitives, the PMA shall assemble the ten received rx_bits into a single ten-
bit value and pass that value to the PCS as the rx_code-group<9:0> parameter of the primitive 
PMA_UNITDATA.indication, with the first received bit installed in rx_code-group<0> and the last received 
bit installed in rx_code-group<9>. An exception to this operation is specified in 127.3.2.4.
127.3.2.4 Code-group alignment
In the event the PMA sublayer detects a comma+ within the incoming rx_bit stream, it may realign its 
current code-group boundary, if necessary, to that of the received comma+ as shown in Figure 36–3. This 
process is referred to in this document as code-group alignment. During the code-group alignment process, 
the PMA sublayer may delete or modify up to four, but shall delete or modify no more than four, ten-bit 
code-groups in order to align the correct receive clock and code-group containing the comma+. This process 
is referred to as code-group slipping.
In addition, the PMA sublayer is permitted to realign the current code-group boundary upon receipt of a 
comma-pattern.
127.3.3 Loopback mode
Loopback mode shall be provided, as specified in this subclause, by the transmitter and receiver of a device 
as a test function to the device. When Loopback mode is selected, transmission requests passed to the 
transmitter are shunted directly to the receiver, overriding any signal detected by the receiver on its attached 
link. A device is explicitly placed in Loopback mode (i.e., Loopback mode is not the normal mode of 
operation of a device). The method of implementing Loopback mode is not defined by this standard.
NOTE—Loopback mode may be implemented either in the parallel or the serial circuitry of a device.
127.3.3.1 Receiver considerations
A receiver may be placed in Loopback mode. Entry into or exit from Loopback mode may result in a 
temporary loss of synchronization.
127.3.3.2 Transmitter considerations
A transmitter may be placed in Loopback mode. While in Loopback mode, the transmitter output is not 
defined.
127.3.4 Test functions
A limited set of test functions may be provided as an implementation option for testing of the transmitter 
function or for testing of an attached receiver.
Some test functions that are not defined by this standard may be provided by certain implementations. 
Compliance with the standard is not affected by the provision or exclusion of such functions by an 
implementation. The patterns described in Annex 36A may be used for 2.5GBASE-X except the nominal bit 
rate is 2.5 times faster and any references to the GMII applies to the XGMII.
A typical test function is the ability to transmit invalid code-groups within an otherwise valid PHY bit 
stream. Certain invalid PHY bit streams may cause a receiver to lose word and/or bit synchronization. See 

ANSI INCITS 230-1994 (FC-PH), subclause 5.4, for a more detailed discussion of receiver and transmitter 
behavior under various test conditions.
127.3.4.1 PMA PRBS9 test pattern (optional)
The PMA may optionally generate a PRBS9 test pattern in the transmit direction.
The ability to generate the test pattern is indicated by the PRBS9_Tx_generator_ability status variable, 
which, if a Clause 45 MDIO is implemented, is accessible through bit 1.1500.5 (see 45.2.1.169).
If supported, when send Tx PRBS9 test-pattern mode is enabled by the PRBS9_enable and 
PRBS_Tx_gen_enable control variables, the PMA shall generate a PRBS9 pattern (as defined in footnote a 
of Table 68–6) toward the service interface below the PMA via the PMA_UNITDATA.request primitive. If a 
Clause 45 MDIO is implemented, the PRBS9_enable and PRBS_Tx_gen_enable control variables are 
accessible through bits 1.1501.6 and 1.1501.3 (see 45.2.1.170). When send Tx PRBS9 test-pattern mode is 
disabled, the PMA returns to normal operation.
Note that PRBS9 is intended to be checked by external test gear, and no PRBS9 checking function is 
provided within the PMA.
127.4 Compatibility considerations
There is no requirement for a compliant device to implement or expose any of the interfaces specified for the 
PCS or PMA. Implementations of a XGMII shall comply with the requirements as specified in Clause 46.
127.5 Delay constraints
Predictable operation of the MAC Control PAUSE operation (Clause 31, Annex 31B) also demands that 
there be an upper bound on the propagation delays through the network. This implies that MAC, MAC 
Control sublayer, and PHY implementations conform to certain delay maxima, and that network planners 
and administrators conform to constraints regarding the backplane channel and concatenation of devices.
The sum of transmit and receive delay contributed by the 2.5GBASE-X PCS and PMA shall be no more 
than 768 bit-times.
127.6 Environmental specifications
All equipment subject to this clause shall conform to the requirements of 71.9.
