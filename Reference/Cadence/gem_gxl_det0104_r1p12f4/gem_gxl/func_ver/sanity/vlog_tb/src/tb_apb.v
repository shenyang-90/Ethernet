//------------------------------------------------------------------------------
// Copyright (c) 2000-2017 Cadence Design Systems, Inc.
//
// The information herein (Cadence IP) contains confidential and proprietary
// information of Cadence Design Systems, Inc. Cadence IP may not be modified,
// copied, reproduced, distributed, or disclosed to third parties in any manner,
// medium, or form, in whole or in part, without the prior written consent of
// Cadence Design Systems Inc. Cadence IP is for use by Cadence Design Systems,
// Inc. customers only. Cadence Design Systems, Inc. reserves the right to make
// changes to Cadence IP at any time and without notice.
//------------------------------------------------------------------------------
//
//   Filename:           tb_apb.v
//   Module Name:        tb_apb
//
//   Release Revision:   r1p12
//   Release SVN Tag:    gem_gxl_det0104_r1p12
//
//   IP Name:            GEM Gigabit Ethernet MAC
//   IP Part Number:     IP7014A
//
//   Product Type:       Off-the-shelf
//   IP Type:            Soft
//   IP Family:          Ethernet Controller
//   Technology:         N/A
//   Protocol:           Ethernet
//   Architecture:       N/A
//   Licensable IP:      SIP-Ethernet-MAC+DMA+1588+TSN+PCS+A-10M/100M/1G-IP7014A
//
//------------------------------------------------------------------------------
//   Description : Test bench module to stimulate and check APB interface
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

module tb_apb (
  reset_tb,
  pclk,
  paddr,
  prdata,
  pwdata,
  pwdata_par,
  pwrite,
  penable,
  psel,
  perr,
  apb_trig,
  int_pulse,
  int_pulse_q1,
  int_pulse_q2,
  int_pulse_q3,
  int_pulse_q4,
  int_pulse_q5,
  int_pulse_q6,
  int_pulse_q7,
  int_pulse_q8,
  int_pulse_q9,
  int_pulse_q10,
  int_pulse_q11,
  int_pulse_q12,
  int_pulse_q13,
  int_pulse_q14,
  int_pulse_q15,
  int_pulse_emac,
  int_pulse_mmsl,
  int_pulse_asf_nonfatal,
  int_pulse_asf_fatal,
  int_pulse_emac_asf_nonfatal,
  int_pulse_emac_asf_fatal,
  trig_from_apb,
  apb_done,
  apb_fail,
  apb_int_status_read   ,
  apb_int_q1_status_read,
  apb_int_q2_status_read,
  apb_int_q3_status_read,
  apb_int_q4_status_read,
  apb_int_q5_status_read,
  apb_int_q6_status_read,
  apb_int_q7_status_read,
  apb_int_q8_status_read,
  apb_int_q9_status_read,
  apb_int_q10_status_read,
  apb_int_q11_status_read,
  apb_int_q12_status_read,
  apb_int_q13_status_read,
  apb_int_q14_status_read,
  apb_int_q15_status_read,
  apb_emac_int_status_read,
  apb_mmsl_int_status_read,
  apb_asf_int_nonfatal_status_read,
  apb_asf_int_fatal_status_read,
  apb_emac_asf_int_nonfatal_status_read,
  apb_emac_asf_int_fatal_status_read,
  apb_64b_addr_mode_en,
  apb_tx_ext_bd_mode_en,
  apb_qos_for_axi,
  link_fault_sig_en
);

// -----------------------------------------------------------------------------
// Define inputs and outputs
// -----------------------------------------------------------------------------
  input          reset_tb;                              // testbench reset
  input          pclk;                                  // peripherical clock bus
  output  [12:0] paddr;                                 // address bus of selected master
  input   [31:0] prdata;                                // read data
  output  [31:0] pwdata;                                // write data
  output  [3:0]  pwdata_par;
  output         pwrite;                                // peripheral write strobe
  output         penable;                               // peripheral enable
  output         psel;                                  // peripheral select
  input          perr;                                  // peripheral address decoding error

  input          apb_trig;                              // trigger from tb_event to start apb
  input          int_pulse;                             // pulse when interrupt occurs
  input          int_pulse_q1;                          // pulse when interrupt occurs
  input          int_pulse_q2;                          // pulse when interrupt occurs
  input          int_pulse_q3;                          // pulse when interrupt occurs
  input          int_pulse_q4;                          // pulse when interrupt occurs
  input          int_pulse_q5;                          // pulse when interrupt occurs
  input          int_pulse_q6;                          // pulse when interrupt occurs
  input          int_pulse_q7;                          // pulse when interrupt occurs
  input          int_pulse_q8;                          // pulse when interrupt occurs
  input          int_pulse_q9;                          // pulse when interrupt occurs
  input          int_pulse_q10;                         // pulse when interrupt occurs
  input          int_pulse_q11;                         // pulse when interrupt occurs
  input          int_pulse_q12;                         // pulse when interrupt occurs
  input          int_pulse_q13;                         // pulse when interrupt occurs
  input          int_pulse_q14;                         // pulse when interrupt occurs
  input          int_pulse_q15;                         // pulse when interrupt occurs
  input          int_pulse_emac;                        // pulse when new interrupt seen
  input          int_pulse_mmsl;                        // pulse when new interrupt seen
  input          int_pulse_asf_nonfatal;                // pulse when new interrupt seen
  input          int_pulse_asf_fatal;                   // pulse when new interrupt seen
  input          int_pulse_emac_asf_nonfatal;           // pulse when new interrupt seen
  input          int_pulse_emac_asf_fatal;              // pulse when new interrupt seen
  output         trig_from_apb;                         // this can start rxd or pins activity
  output         apb_done;                              // signals completion of all apb activity
  output         apb_fail;                              // pulsed when APBRD data is in error
  output         apb_int_status_read;                   // signals when an apb interrupt status
                                                        // read is done
  output         apb_int_q1_status_read;                // signals when an apb read is done
  output         apb_int_q2_status_read;                // signals when an apb read is done
  output         apb_int_q3_status_read;                // signals when an apb read is done
  output         apb_int_q4_status_read;                // signals when an apb read is done
  output         apb_int_q5_status_read;                // signals when an apb read is done
  output         apb_int_q6_status_read;                // signals when an apb read is done
  output         apb_int_q7_status_read;                // signals when an apb read is done
  output         apb_int_q8_status_read;                // signals when an apb read is done
  output         apb_int_q9_status_read;                // signals when an apb read is done
  output         apb_int_q10_status_read;               // signals when an apb read is done
  output         apb_int_q11_status_read;               // signals when an apb read is done
  output         apb_int_q12_status_read;               // signals when an apb read is done
  output         apb_int_q13_status_read;               // signals when an apb read is done
  output         apb_int_q14_status_read;               // signals when an apb read is done
  output         apb_int_q15_status_read;               // signals when an apb read is done
  output         apb_emac_int_status_read;              // signals when an apb read is done
  output         apb_mmsl_int_status_read;              // signals when an apb read is done
  output         apb_asf_int_nonfatal_status_read;      // signals when an apb read is done
  output         apb_asf_int_fatal_status_read;         // signals when an apb read is done
  output         apb_emac_asf_int_nonfatal_status_read; // signals when an apb read is done
  output         apb_emac_asf_int_fatal_status_read;    // signals when an apb read is done
  output         apb_64b_addr_mode_en;                  // indicates write to register
  output         apb_tx_ext_bd_mode_en;                 // indicates write to register
  output [127:0] apb_qos_for_axi;                       // indicates write to register
  output         link_fault_sig_en;                     // enable of the LFSM

// -----------------------------------------------------------------------------
// Define internal signals
// -----------------------------------------------------------------------------

   // APB outputs
   reg     [12:0] paddr;                // address bus of selected master
   reg     [31:0] pwdata;               // write data
   reg      [3:0] pwdata_par;
   reg            pwrite;               // peripheral write strobe
   reg            penable;              // peripheral enable
   reg            psel;                 // peripheral select

   // Testbench control
   reg            trig_from_apb;        // trigger to other testbenches
   reg            apb_trig_sync;        // stays active until seen in pclk
   reg            apb_trig_ack;         // clears apb_trig_sync
   reg            apb_trig_stored;      // another apb trigger is pending
   reg            int_pulse_stored;     // another interrupt is pending
   reg            int_pulse_q1_stored;  // another interrupt is pending
   reg            int_pulse_q2_stored;  // another interrupt is pending
   reg            int_pulse_q3_stored;  // another interrupt is pending
   reg            int_pulse_q4_stored;  // another interrupt is pending
   reg            int_pulse_q5_stored;  // another interrupt is pending
   reg            int_pulse_q6_stored;  // another interrupt is pending
   reg            int_pulse_q7_stored;  // another interrupt is pending
   reg            int_pulse_q8_stored;  // another interrupt is pending
   reg            int_pulse_q9_stored;  // another interrupt is pending
   reg            int_pulse_q10_stored; // another interrupt is pending
   reg            int_pulse_q11_stored; // another interrupt is pending
   reg            int_pulse_q12_stored; // another interrupt is pending
   reg            int_pulse_q13_stored; // another interrupt is pending
   reg            int_pulse_q14_stored; // another interrupt is pending
   reg            int_pulse_q15_stored; // another interrupt is pending
   reg            int_emac_pulse_stored; // another interrupt is pending
   reg            int_mmsl_pulse_stored; // another interrupt is pending
   reg            int_asf_nonfatal_pulse_stored;      // another interrupt is pending
   reg            int_asf_fatal_pulse_stored;         // another interrupt is pending
   reg            int_emac_asf_nonfatal_pulse_stored; // another interrupt is pending
   reg            int_emac_asf_fatal_pulse_stored;    // another interrupt is pending
   wire           apb_done;             // signals completion of all apb activity
   reg            apb_fail;             // pulsed when error in checks

   // test file arrays
   integer        j;                    // index for loops in array initialising
   reg     [83:0] apb_vector_reg[1:65536];
                                        // array initialised with test file data
   integer        apb_index;            // array index for apb_vector_reg
   integer        apb_index_store;      // array index for apb_vector_reg stored for comment reporting
   wire    [83:0] apb_vector;           // current word pointed to by apb_index.
   wire    [83:0] apb_vector_next;      // current word pointed to by apb_index+1
   wire    [83:0] apb_vector_next2;     // current word pointed to by apb_index+1
   reg    [511:0] apb_comment_reg[1:128];
                                        // array of strings to write to
                                        // screen/test log
   integer        comment_index;        // array index for apb_comment_reg
   wire   [511:0] apb_comment;          // comment pointed to by comment_index
   wire           comment;              // active when a comment needs reporting
   reg    [175:0] register_names[0:337];
                                        // array containing register names, for
                                        // use in reporting.

   // decodes of array words for checking and driving
   wire    [12:2] apb_address;          // address to read/write
   wire    [31:0] apb_data;             // data to be written
   reg     [31:0] apb_data_store;       // store expected data for comparison
   wire           apb_read;             // high if a read is being performed
   wire     [3:0] apb_queue;
   wire     [2:0] apb_control;          // current testbench control word
   wire     [2:0] apb_control_next;     // next testbench control word
   wire     [2:0] apb_control_next2;    // next testbench control word
   wire           perr_expected;        // used for controlling perr indication
   wire           inj_par_err;
   wire     [2:0] int_expected;         // interrupt type (standard/ASF/MMSL)

   wire    [12:2] apb_address_nxt;      // address to read/write
   wire    [31:0] apb_data_nxt;         // data to be written
   wire           apb_read_nxt;         // high if a read is being performed
   wire     [3:0] apb_queue_nxt;
   wire           perr_expected_nxt;    // used for controlling perr indication
   wire     [1:0] int_expected_nxt;     // interrupt type (standard/ASF/MMSL)

   wire    [12:2] apb_address_nxt2;     // address to read/write
   wire    [31:0] apb_data_nxt2;        // data to be written
   wire           apb_read_nxt2;        // high if a read is being performed
   wire     [3:0] apb_queue_nxt2;
   wire           perr_expected_nxt2;   // used for controlling perr indication
   wire     [1:0] int_expected_nxt2;    // interrupt type (standard/ASF/MMSL)

   // cycle control signals
   reg            check_data;           // controls checking of APB data
   reg            first_half;           // indicate current phase of APB cycle
   reg            perr_expected_del;    // used for controlling perr indication


   wire           apb_64b_addr_mode_en_pulse; // pulse when write to 64b addr enable
   reg            apb_64b_addr_mode_en;       // latched verion of _pulse
   wire           apb_tx_ext_bd_mode_en_pulse; // pulse when write to 64b addr enable
   reg            apb_tx_ext_bd_mode_en;       // latched verion of _pulse
   reg            reading_int_status;
   reg            less_than_expected_ints_seen;
   reg            more_than_expected_ints_seen;
   reg            ints_were_expected_over_1;
   reg            ints_were_expected_over_2;
   reg      [7:0] wait_remaining_ints;
   reg     [31:0] interrupts_seen;

   reg     [15:0] poll_count;
   reg     [15:0] est_range;
   reg    [127:0] apb_qos_for_axi;

   // Link Fault Signaling
   reg      [3:0] condition_buffer;

// -----------------------------------------------------------------------------
// Initialise arrays from test files
// -----------------------------------------------------------------------------

// read apb data, comments and initialise register_names
initial
  begin
    for (j=1; j<=2048; j=j+1)
      apb_vector_reg[j] = 84'b0;

    $readmemh("./files/tb_apb.data",apb_vector_reg);
    if (apb_vector_reg[1] === 84'hx)
      begin
        $display("\n No apb data file read \n");
      end

    $readmemh("./files/tb_apb_comment.data",apb_comment_reg);
    if (apb_comment_reg[1] === 512'hx)
      begin
        $display("\n No apb comments file read \n");
      end

     register_names[0]  = "network control";
     register_names[1]  = "network config";
     register_names[2]  = "network status";
     register_names[3]  = "user io register";
     register_names[4]  = "dma configuration";
     register_names[5]  = "transmit status";
     register_names[6]  = "receive q ptr";
     register_names[7]  = "transmit q ptr";
     register_names[8]  = "receive status";
     register_names[9]  = "Int status";
     register_names[10] = "Int enable";
     register_names[11] = "Int disable";
     register_names[12] = "Int mask";
     register_names[13] = "phy management";
     register_names[14] = "pause time";
     register_names[15] = "tx pause quantum";
     register_names[16] = "Tx cut-thru en";
     register_names[17] = "Rx cut-thru en";
     register_names[18] = "Jumbo Max Length";
     register_names[19] = "Soft cfg, FIFO en";
     register_names[20] = "** reserved **";
     register_names[21] = "axi max pipeline";
     register_names[22] = "rsc control";
     register_names[23] = "interrupt moderation";
     register_names[24] = "EEE system wake time";
     register_names[25] = "fatal/non-fatal int";
     register_names[26] = "lockup config";
     register_names[27] = "rx mac lockup time";
     register_names[28] = "tx dma lockup control";
     register_names[29] = "** reserved **";
     register_names[30] = "** reserved **";
     register_names[31] = "rx watermark";
     register_names[32] = "hash bottom";
     register_names[33] = "hash top";
     register_names[34] = "spec add1 bottom";
     register_names[35] = "spec add1 top";
     register_names[36] = "spec add2 bottom";
     register_names[37] = "spec add2 top";
     register_names[38] = "spec add3 bottom";
     register_names[39] = "spec add3 top";
     register_names[40] = "spec add4 bottom";
     register_names[41] = "spec add4 top";
     register_names[42] = "spec type1";
     register_names[43] = "spec type2";
     register_names[44] = "spec type3";
     register_names[45] = "spec type4";
     register_names[46] = "Wake on LAN";
     register_names[47] = "stretch ratio";
     register_names[48] = "stacked VLAN";
     register_names[49] = "transmit PFC";
     register_names[50] = "add 1 mask bottom";
     register_names[51] = "add 1 mask top";
     register_names[52] = "rx data buf addr mask";
     register_names[53] = "ptp unicast rx";
     register_names[54] = "ptp unicast tx";
     register_names[55] = "tsu timer comp nsec";
     register_names[56] = "tsu timer comp sec";
     register_names[57] = "tsu timer comp msb sec";
     register_names[58] = "tsu ptp tx msb sec";
     register_names[59] = "tsu ptp rx msb sec";
     register_names[60] = "tsu peer tx msb sec";
     register_names[61] = "tsu peer rx msb sec";
     register_names[62] = "dpram fill debug";
     register_names[63] = "revision reg";
     register_names[64] = "octets txed bot";
     register_names[65] = "octets txed top";
     register_names[66] = "frames txed ok";
     register_names[67] = "broadcast txed";
     register_names[68] = "multicast txed";
     register_names[69] = "pause frames txed";
     register_names[70] = "frames txed 64";
     register_names[71] = "frames txed 65";
     register_names[72] = "frames txed 128";
     register_names[73] = "frames txed 256";
     register_names[74] = "frames txed 512";
     register_names[75] = "frames txed 1024";
     register_names[76] = "frames txed 1519";
     register_names[77] = "tx underruns";
     register_names[78] = "single cols";
     register_names[79] = "multiple cols";
     register_names[80] = "excessive cols";
     register_names[81] = "late collisions";
     register_names[82] = "deferred frames";
     register_names[83] = "crs errors";
     register_names[84] = "octets rxed bot";
     register_names[85] = "octets rxed top";
     register_names[86] = "frames rxed ok";
     register_names[87] = "broadcast rxed";
     register_names[88] = "multicast rxed";
     register_names[89] = "pause frames rxed";
     register_names[90] = "frames rxed 64";
     register_names[91] = "frames rxed 65";
     register_names[92] = "frames rxed 128";
     register_names[93] = "frames rxed 256";
     register_names[94] = "frames rxed 512";
     register_names[95] = "frames rxed 1024";
     register_names[96] = "frames rxed 1519";
     register_names[97] = "undersize frames";
     register_names[98] = "excess rx length";
     register_names[99] = "rx jabbers";
     register_names[100]= "fcs errors";
     register_names[101]= "rx length errors";
     register_names[102]= "rx symbol errors";
     register_names[103]= "alignment errors";
     register_names[104]= "rx resource errs";
     register_names[105]= "rx overruns";
     register_names[106]= "rx IP cksum errs";
     register_names[107]= "rx TCP cksum errs";
     register_names[108]= "rx UDP cksum errs";
     register_names[109]= "auto flushed packets";
     register_names[110]= "** reserved **";
     register_names[111]= "TSU timer sub nsec incr";
     register_names[112]= "TSU timer msb sec";
     register_names[113]= "timer strobe msb sec";
     `ifdef gem_tsu
       register_names[114]= "timer strobe sec";
       register_names[115]= "timer strobe nsec";
       register_names[116]= "TSU timer sec";
       register_names[117]= "TSU timer nsec";
       register_names[118]= "TSU timer adjust";
       register_names[119]= "TSU timer incr";
       register_names[120]= "PTP tx sec";
       register_names[121]= "PTP tx nsec";
       register_names[122]= "PTP rx sec";
       register_names[123]= "PTP rx nsec";
       register_names[124]= "peer tx sec";
       register_names[125]= "peer tx nsec";
       register_names[126]= "peer rx sec";
       register_names[127]= "peer rx nsec";
     `else
       register_names[114]= "** reserved **";
       register_names[115]= "** reserved **";
       register_names[116]= "** reserved **";
       register_names[117]= "** reserved **";
       register_names[118]= "** reserved **";
       register_names[119]= "** reserved **";
       register_names[120]= "** reserved **";
       register_names[121]= "** reserved **";
       register_names[122]= "** reserved **";
       register_names[123]= "** reserved **";
       register_names[124]= "** reserved **";
       register_names[125]= "** reserved **";
       register_names[126]= "** reserved **";
       register_names[127]= "** reserved **";
     `endif
     register_names[128]= "PCS control";
     register_names[129]= "PCS status";
     register_names[130]= "PCS PHY top id";
     register_names[131]= "PCS PHY bot id";
     register_names[132]= "PCS an adv";
     register_names[133]= "PCS an lp base";
     register_names[134]= "PCS an exp";
     register_names[135]= "PCS an np tx";
     register_names[136]= "PCS an lp np";
     register_names[137]= "** reserved **";
     register_names[138]= "** reserved **";
     register_names[139]= "** reserved **";
     register_names[140]= "** reserved **";
     register_names[141]= "** reserved **";
     register_names[142]= "** reserved **";
     register_names[143]= "PCS an ext status";
     register_names[144]= "** reserved **";
     register_names[145]= "** reserved **";
     register_names[146]= "** reserved **";
     register_names[147]= "** reserved **";
     register_names[148]= "** reserved **";
     register_names[149]= "** reserved **";
     register_names[150]= "** reserved **";
     register_names[151]= "** reserved **";
     `ifdef gem_pfc_multi_quantum
       register_names[152]= "PFC Pause Quantum p2/p3";
       register_names[153]= "PFC Pause Quantum p4/p5";
       register_names[154]= "PFC Pause Quantum p6/p7";
     `else
       register_names[152]= "** reserved **";
       register_names[153]= "** reserved **";
       register_names[154]= "** reserved **";
     `endif
     register_names[155]= "PFC status";
     register_names[156]= "LPI rx count";
     register_names[157]= "LPI rx time";
     register_names[158]= "LPI tx count";
     register_names[159]= "LPI tx time";
     register_names[160]= "Design Config 1";
     register_names[161]= "Design Config 2";
     register_names[162]= "Design Config 3";
     register_names[163]= "Design Config 4";
     register_names[164]= "Design Config 5";
     register_names[165]= "Design Config 6";
     register_names[166]= "Design Config 7";
     register_names[167]= "Design Config 8";
     register_names[168]= "Design Config 9";
     register_names[169]= "Design Config 10";
     register_names[170]= "Design Config 11";
     register_names[171]= "Design Config 12";
     register_names[172]= "** reserved **";
     register_names[173]= "** reserved **";
     register_names[174]= "** reserved **";
     register_names[175]= "** reserved **";
     register_names[176]= "** reserved **";
     register_names[177]= "** reserved **";
     register_names[178]= "** reserved **";
     register_names[179]= "** reserved **";
     register_names[180]= "** reserved **";
     register_names[181]= "** reserved **";
     register_names[182]= "** reserved **";
     register_names[183]= "** reserved **";
     register_names[184]= "AXI QOS cfg 0";
     register_names[185]= "AXI QOS cfg 1";
     register_names[186]= "AXI QOS cfg 2";
     register_names[187]= "AXI QOS cfg 3";
     register_names[188]= "** reserved **";
     register_names[189]= "** reserved **";
     register_names[190]= "** reserved **";
     register_names[191]= "** reserved **";
     register_names[192]= "spec add5 bottom";
     register_names[193]= "spec add5 top";
     register_names[194]= "spec add6 bottom";
     register_names[195]= "spec add6 top";
     register_names[196]= "spec add7 bottom";
     register_names[197]= "spec add7 top";
     register_names[198]= "spec add8 bottom";
     register_names[199]= "spec add8 top";
     register_names[200]= "spec add9 bottom";
     register_names[201]= "spec add9 top";
     register_names[202]= "spec add10 bottom";
     register_names[203]= "spec add10 top";
     register_names[204]= "spec add11 bottom";
     register_names[205]= "spec add11 top";
     register_names[206]= "spec add12 bottom";
     register_names[207]= "spec add12 top";
     register_names[208]= "spec add13 bottom";
     register_names[209]= "spec add13 top";
     register_names[210]= "spec add14 bottom";
     register_names[211]= "spec add14 top";
     register_names[212]= "spec add15 bottom";
     register_names[213]= "spec add15 top";
     register_names[214]= "spec add16 bottom";
     register_names[215]= "spec add16 top";
     register_names[216]= "spec add17 bottom";
     register_names[217]= "spec add17 top";
     register_names[218]= "spec add18 bottom";
     register_names[219]= "spec add18 top";
     register_names[220]= "spec add19 bottom";
     register_names[221]= "spec add19 top";
     register_names[222]= "spec add20 bottom";
     register_names[223]= "spec add20 top";
     register_names[224]= "spec add21 bottom";
     register_names[225]= "spec add21 top";
     register_names[226]= "spec add22 bottom";
     register_names[227]= "spec add22 top";
     register_names[228]= "spec add23 bottom";
     register_names[229]= "spec add23 top";
     register_names[230]= "spec add24 bottom";
     register_names[231]= "spec add24 top";
     register_names[232]= "spec add25 bottom";
     register_names[233]= "spec add25 top";
     register_names[234]= "spec add26 bottom";
     register_names[235]= "spec add26 top";
     register_names[236]= "spec add27 bottom";
     register_names[237]= "spec add27 top";
     register_names[238]= "spec add28 bottom";
     register_names[239]= "spec add28 top";
     register_names[240]= "spec add29 bottom";
     register_names[241]= "spec add29 top";
     register_names[242]= "spec add30 bottom";
     register_names[243]= "spec add30 top";
     register_names[244]= "spec add31 bottom";
     register_names[245]= "spec add31 top";
     register_names[246]= "spec add32 bottom";
     register_names[247]= "spec add32 top";
     register_names[248]= "spec add33 bottom";
     register_names[249]= "spec add33 top";
     register_names[250]= "spec add34 bottom";
     register_names[251]= "spec add34 top";
     register_names[252]= "spec add35 bottom";
     register_names[253]= "spec add35 top";
     register_names[254]= "spec add36 bottom";
     register_names[255]= "spec add36 top";
     register_names[256]= "int q1 status";
     register_names[257]= "int q2 status";
     register_names[258]= "int q3 status";
     register_names[259]= "int q4 status";
     register_names[260]= "int q5 status";
     register_names[261]= "int q6 status";
     register_names[262]= "int q7 status";
     register_names[263]= "int q8 status";
     register_names[264]= "int q9 status";
     register_names[265]= "int q10 status";
     register_names[266]= "int q11 status";
     register_names[267]= "int q12 status";
     register_names[268]= "int q13 status";
     register_names[269]= "int q14 status";
     register_names[270]= "int q15 status";
     register_names[271]= "** reserved **";
     register_names[272]= "transmit q1 pointer";
     register_names[273]= "transmit q2 pointer";
     register_names[274]= "transmit q3 pointer";
     register_names[275]= "transmit q4 pointer";
     register_names[276]= "transmit q5 pointer";
     register_names[277]= "transmit q6 pointer";
     register_names[278]= "transmit q7 pointer";
     register_names[279]= "transmit q8 pointer";
     register_names[280]= "transmit q9 pointer";
     register_names[281]= "transmit q10 pointer";
     register_names[282]= "transmit q11 pointer";
     register_names[283]= "transmit q12 pointer";
     register_names[284]= "transmit q13 pointer";
     register_names[285]= "transmit q14 pointer";
     register_names[286]= "transmit q15 pointer";
     register_names[287]= "** reserved **";
     register_names[288]= "receive q1 pointer";
     register_names[289]= "receive q2 pointer";
     register_names[290]= "receive q3 pointer";
     register_names[291]= "receive q4 pointer";
     register_names[292]= "receive q5 pointer";
     register_names[293]= "receive q6 pointer";
     register_names[294]= "receive q7 pointer";
     register_names[295]= "** reserved **";
     register_names[296]= "dma rxbuf size q1";
     register_names[297]= "dma rxbuf size q2";
     register_names[298]= "dma rxbuf size q3";
     register_names[299]= "dma rxbuf size q4";
     register_names[300]= "dma rxbuf size q5";
     register_names[301]= "dma rxbuf size q6";
     register_names[302]= "dma rxbuf size q7";
     register_names[303]= "cbs control";
     register_names[304]= "cbs idleslope q a";
     register_names[305]= "cbs idleslope q a";
     register_names[306]= "upper tx q base addr";
     register_names[307]= "tx bd control";
     register_names[308]= "tx bd control";
     register_names[309]= "upper rx q base addr";
     register_names[310]= "** reserved **";
     register_names[311]= "** reserved **";
     register_names[312]= "10M Port TX Rate";
     register_names[313]= "100M Port TX Rate";
     register_names[314]= "1G Port TX Rate";
     register_names[315]= "wd counter";
     register_names[316]= "** reserved **";
     register_names[317]= "** reserved **";
     register_names[318]= "axi tx full thresh0";
     register_names[319]= "axi tx full thresh1";
     register_names[320] = "screening type 1 reg 0";
     register_names[321] = "screening type 1 reg 1";
     register_names[322] = "screening type 1 reg 2";
     register_names[323] = "screening type 1 reg 3";
     register_names[324] = "screening type 1 reg 4";
     register_names[325] = "screening type 1 reg 5";
     register_names[326] = "screening type 1 reg 6";
     register_names[327] = "screening type 1 reg 7";
     register_names[328] = "screening type 1 reg 8";
     register_names[329] = "screening type 1 reg 9";
     register_names[330] = "screening type 1 reg 10";
     register_names[331] = "screening type 1 reg 11";
     register_names[332] = "screening type 1 reg 12";
     register_names[333] = "screening type 1 reg 13";
  end

// -----------------------------------------------------------------------------
// decode from arrays using current indices
// -----------------------------------------------------------------------------

// get current and next vectors for APB data
assign apb_vector         = apb_vector_reg[apb_index];
assign apb_vector_next    = apb_vector_reg[apb_index+1];
assign apb_vector_next2   = apb_vector_reg[apb_index+2];

// decode APB data
assign apb_data           = apb_vector[31:0];        // 32 bit data
assign apb_address        = apb_vector[44:34];       // use top 11 bits of 13 bit addr
assign apb_read           = apb_vector[51];          // high for read
assign apb_queue          = apb_vector[59:56];       // high for read
assign perr_expected      = apb_vector[63:60] == 4'h1;
assign inj_par_err        = apb_vector[63:60] == 4'h2;

assign apb_data_nxt       = apb_vector_next[31:0];   // 32 bit data
assign apb_address_nxt    = apb_vector_next[44:34];  // use top 11 bits of 13 bit addr
assign apb_read_nxt       = apb_vector_next[51];     // high for read
assign apb_queue_nxt      = apb_vector_next[59:56];  // high for read
assign perr_expected_nxt  = apb_vector_next[63:60] == 4'h1;

assign apb_data_nxt2      = apb_vector_next2[31:0];  // 32 bit data
assign apb_address_nxt2   = apb_vector_next2[44:34]; // use top 11 bits of 13 bit addr
assign apb_read_nxt2      = apb_vector_next2[51];    // high for read
assign apb_queue_nxt2     = apb_vector_next2[59:56]; // high for read
assign perr_expected_nxt2 = apb_vector_next2[63:60] == 4'h1;

// control triggers (current and next)
// 0  end-stop
// 1  wait for trigger
// 2  wait for interrupt
// 3  generate APB trigger
// 4  keep going
// 5  force no access
// 6  poll
assign apb_control        = apb_vector[50:48];
assign apb_control_next   = apb_vector_next[50:48];
assign apb_control_next2  = apb_vector_next2[50:48];

// Interrupt expected
// 0  standard (ethernet queues 0-15)   e.g. apbrd(int*)
// 1  emac queue 0                      e.g. apbrd(eint)
// 2  mmsl interrupt                    e.g. apbrd(mmsl_int)
// 3  asf interrupt non-fatal           e.g. apbrd(asf_int_nonfatal)
// 4  asf interrupt fatal               e.g. apbrd(asf_int_fatal)
// 5  asf emac interrupt non-fatal      e.g. apbrd(emac_asf_int_nonfatal)
// 6  asf emac interrupt fatal          e.g. apbrd(emac_asf_int_fatal)

assign int_expected       = apb_vector[82:80];
assign int_expected_next  = apb_vector_next[82:80];
assign int_expected_next2 = apb_vector_next2[82:80];

// get comment from arrays
assign apb_comment        = apb_comment_reg[comment_index];
assign comment            = apb_vector[52];

// -----------------------------------------------------------------------------
// Report comments to screen and test log
// -----------------------------------------------------------------------------

// Report comments on second half of register access
always @( negedge (reset_tb) or negedge (first_half) )
  if (~reset_tb)
    begin
      comment_index <= 1;
      apb_index_store <= 0;
    end
  else if (comment)
    begin
      if (apb_index != apb_index_store)   // this mitigates occasions when apb_index is rolled back
        begin
          $display("%s",apb_comment);
	  comment_index <= comment_index + 1;
	end
      apb_index_store <= apb_index;
    end
  else
    comment_index <= comment_index;

// -----------------------------------------------------------------------------
// Latch triggers to ensure they are seen in pclk domain
// -----------------------------------------------------------------------------

// First, create an event on apb_trig, to avoid signal width issues ...
reg apb_trig_event;
initial
  begin
    forever
    @(posedge apb_trig)
    begin
      apb_trig_event = 1;
      #1 apb_trig_event = 0;
    end
  end

// synchronise apb_trig signal pulse
always @(*)
  if (~reset_tb)
    begin
      apb_trig_sync    = 1'b0;
      apb_trig_stored  = 1'b0;
      int_pulse_stored = 1'b1;
      int_pulse_q1_stored = 1'b1;
      int_pulse_q2_stored = 1'b1;
      int_pulse_q3_stored = 1'b1;
      int_pulse_q4_stored = 1'b1;
      int_pulse_q5_stored = 1'b1;
      int_pulse_q6_stored = 1'b1;
      int_pulse_q7_stored = 1'b1;
      int_pulse_q8_stored = 1'b1;
      int_pulse_q9_stored = 1'b1;
      int_pulse_q10_stored = 1'b1;
      int_pulse_q11_stored = 1'b1;
      int_pulse_q12_stored = 1'b1;
      int_pulse_q13_stored = 1'b1;
      int_pulse_q14_stored = 1'b1;
      int_pulse_q15_stored = 1'b1;
      int_emac_pulse_stored = 1'b1;
      int_mmsl_pulse_stored = 1'b1;
      int_asf_nonfatal_pulse_stored = 1'b1;
      int_asf_fatal_pulse_stored = 1'b1;
      int_emac_asf_nonfatal_pulse_stored = 1'b1;
      int_emac_asf_fatal_pulse_stored = 1'b1;
    end
  else if (apb_trig_ack)
    begin
      apb_trig_sync = 1'b0;
      if (apb_trig_event)
        apb_trig_stored  = 1'b1;
      if (int_pulse)
        int_pulse_stored = 1'b1;
      if (int_pulse_q1)
        int_pulse_q1_stored = 1'b1;
      if (int_pulse_q2)
        int_pulse_q2_stored = 1'b1;
      if (int_pulse_q3)
        int_pulse_q3_stored = 1'b1;
      if (int_pulse_q4)
        int_pulse_q4_stored = 1'b1;
      if (int_pulse_q5)
        int_pulse_q5_stored = 1'b1;
      if (int_pulse_q6)
        int_pulse_q6_stored = 1'b1;
      if (int_pulse_q7)
        int_pulse_q7_stored = 1'b1;
      if (int_pulse_q8)
        int_pulse_q8_stored = 1'b1;
      if (int_pulse_q9)
        int_pulse_q9_stored = 1'b1;
      if (int_pulse_q10)
        int_pulse_q10_stored = 1'b1;
      if (int_pulse_q11)
        int_pulse_q11_stored = 1'b1;
      if (int_pulse_q12)
        int_pulse_q12_stored = 1'b1;
      if (int_pulse_q13)
        int_pulse_q13_stored = 1'b1;
      if (int_pulse_q14)
        int_pulse_q14_stored = 1'b1;
      if (int_pulse_q15)
        int_pulse_q15_stored = 1'b1;
      if (int_pulse_emac)
        int_emac_pulse_stored = 1'b1;
      if (int_pulse_mmsl)
        int_mmsl_pulse_stored = 1'b1;
      if (int_pulse_asf_nonfatal)
        int_asf_nonfatal_pulse_stored = 1'b1;
      if (int_pulse_asf_fatal)
        int_asf_fatal_pulse_stored = 1'b1;
      if (int_pulse_emac_asf_nonfatal)
        int_emac_asf_nonfatal_pulse_stored = 1'b1;
      if (int_pulse_emac_asf_fatal)
        int_emac_asf_fatal_pulse_stored = 1'b1;
    end
  else if (apb_trig_sync)
    begin
      if (apb_trig_event & (apb_control != 3'b001))
        apb_trig_stored  = 1'b1;
      if (int_pulse & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_stored = 1'b1;
      if (int_pulse_q1 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q1_stored = 1'b1;
      if (int_pulse_q2 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q2_stored = 1'b1;
      if (int_pulse_q3 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q3_stored = 1'b1;
      if (int_pulse_q4 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q4_stored = 1'b1;
      if (int_pulse_q5 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q5_stored = 1'b1;
      if (int_pulse_q6 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q6_stored = 1'b1;
      if (int_pulse_q7 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q7_stored = 1'b1;
      if (int_pulse_q8 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q8_stored = 1'b1;
      if (int_pulse_q9 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q9_stored = 1'b1;
      if (int_pulse_q10 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q10_stored = 1'b1;
      if (int_pulse_q11 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q11_stored = 1'b1;
      if (int_pulse_q12 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q12_stored = 1'b1;
      if (int_pulse_q13 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q13_stored = 1'b1;
      if (int_pulse_q14 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q14_stored = 1'b1;
      if (int_pulse_q15 & (apb_control != 3'b010) & (int_expected == 3'b000))
        int_pulse_q15_stored = 1'b1;
      if (int_pulse_emac & (apb_control != 3'b010) & (int_expected == 3'b001))
        int_emac_pulse_stored = 1'b1;
      if (int_pulse_mmsl & (apb_control != 3'b010) & (int_expected == 3'b010))
        int_mmsl_pulse_stored = 1'b1;
      if (int_pulse_asf_nonfatal & (apb_control != 3'b010) & (int_expected == 3'b011))
        int_asf_nonfatal_pulse_stored = 1'b1;
      if (int_pulse_asf_fatal & (apb_control != 3'b010) & (int_expected == 3'b100))
        int_asf_fatal_pulse_stored = 1'b1;
      if (int_pulse_emac_asf_nonfatal & (apb_control != 3'b010) & (int_expected == 3'b101))
        int_emac_asf_nonfatal_pulse_stored = 1'b1;
      if (int_pulse_asf_fatal & (apb_control != 3'b010) & (int_expected == 3'b110))
        int_emac_asf_fatal_pulse_stored = 1'b1;
    end
  else if (((apb_trig_event | apb_trig_stored) & (apb_control == 3'b001)) |
          ((int_pulse    | int_pulse_stored   ) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 0) |
          ((int_pulse_q1 | int_pulse_q1_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 1) |
          ((int_pulse_q2 | int_pulse_q2_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 2) |
          ((int_pulse_q3 | int_pulse_q3_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 3) |
          ((int_pulse_q4 | int_pulse_q4_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 4) |
          ((int_pulse_q5 | int_pulse_q5_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 5) |
          ((int_pulse_q6 | int_pulse_q6_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 6) |
          ((int_pulse_q7 | int_pulse_q7_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 7) |
          ((int_pulse_q8 | int_pulse_q8_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 8) |
          ((int_pulse_q9 | int_pulse_q9_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 9) |
          ((int_pulse_q10 | int_pulse_q10_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 10) |
          ((int_pulse_q11 | int_pulse_q11_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 11) |
          ((int_pulse_q12 | int_pulse_q12_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 12) |
          ((int_pulse_q13 | int_pulse_q13_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 13) |
          ((int_pulse_q14 | int_pulse_q14_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 14) |
          ((int_pulse_q15 | int_pulse_q15_stored) & (apb_control == 3'b010) & (int_expected == 3'b000) & apb_queue == 15) |
          ((int_pulse_emac | int_emac_pulse_stored) & (apb_control == 3'b010) & (int_expected == 3'b001) & apb_queue == 0) |
          ((int_pulse_mmsl | int_mmsl_pulse_stored) & (apb_control == 3'b010) & (int_expected == 3'b010) & apb_queue == 0) |
          ((int_pulse_asf_nonfatal      | int_asf_nonfatal_pulse_stored)      & (apb_control == 3'b010) & (int_expected == 3'b011)) |
          ((int_pulse_asf_fatal         | int_asf_fatal_pulse_stored)         & (apb_control == 3'b010) & (int_expected == 3'b100)) |
          ((int_pulse_emac_asf_nonfatal | int_emac_asf_nonfatal_pulse_stored) & (apb_control == 3'b010) & (int_expected == 3'b101)) |
          ((int_pulse_emac_asf_fatal    | int_emac_asf_fatal_pulse_stored)    & (apb_control == 3'b010) & (int_expected == 3'b110)))
    begin
      apb_trig_sync    = 1'b1;
      apb_trig_stored  = 1'b0;
      int_pulse_stored = 1'b0;
      int_pulse_q1_stored = 1'b0;
      int_pulse_q2_stored = 1'b0;
      int_pulse_q3_stored = 1'b0;
      int_pulse_q4_stored = 1'b0;
      int_pulse_q5_stored = 1'b0;
      int_pulse_q6_stored = 1'b0;
      int_pulse_q7_stored = 1'b0;
      int_pulse_q8_stored = 1'b0;
      int_pulse_q9_stored = 1'b0;
      int_pulse_q10_stored = 1'b0;
      int_pulse_q11_stored = 1'b0;
      int_pulse_q12_stored = 1'b0;
      int_pulse_q13_stored = 1'b0;
      int_pulse_q14_stored = 1'b0;
      int_pulse_q15_stored = 1'b0;
      int_emac_pulse_stored = 1'b0;
      int_mmsl_pulse_stored = 1'b0;
      int_asf_nonfatal_pulse_stored      = 1'b0;
      int_asf_fatal_pulse_stored         = 1'b0;
      int_emac_asf_nonfatal_pulse_stored = 1'b0;
      int_emac_asf_fatal_pulse_stored    = 1'b0;
    end

// -----------------------------------------------------------------------------
// Drive APB signals and check read data
// -----------------------------------------------------------------------------

// Delay perr_expected
always @( negedge (reset_tb) or posedge (pclk) )
begin
  if (~reset_tb)
    perr_expected_del <= 1'b0;
  else
    perr_expected_del <= perr_expected;
end

//  Check if the expected data is an interrupt
integer num_expected_ints;
integer num_actual_ints;
always @(*)
  begin
    num_expected_ints = 0;
    num_actual_ints = 0;
    for (int a = 0;a<32;a++)
      begin
        num_expected_ints = num_expected_ints + apb_data_store[a];
        num_actual_ints = num_actual_ints + prdata[a];
      end
    reading_int_status = (paddr == 13'h0024 & psel & ~pwrite);
    if (check_data & reading_int_status & apb_data_store !== prdata & ((apb_data_store & prdata) != 32'h00000000) & wait_remaining_ints == 8'd0)
      begin
        if (num_actual_ints > num_expected_ints)
          more_than_expected_ints_seen = 1'b1;
        else
          less_than_expected_ints_seen = 1'b1;
      end
    else
      begin
        more_than_expected_ints_seen = 1'b0;
        less_than_expected_ints_seen = 1'b0;
      end
    ints_were_expected_over_1 = more_than_expected_ints_seen & ({apb_address_nxt,2'b00} == 10'h024 & apb_read_nxt & apb_control_next == 3'b010 & ((apb_data_nxt | apb_data_store) == prdata));
    ints_were_expected_over_2 = more_than_expected_ints_seen & ({apb_address_nxt2,2'b00} == 10'h024 & apb_read_nxt2 & apb_control_next2 == 3'b010 & ((apb_data_nxt2 | apb_data_store) == prdata));
  end

// Check read data
always @( negedge (reset_tb) or posedge (pclk) )
  begin
    if (~reset_tb)
      begin
        apb_fail <= 1'b0;
        wait_remaining_ints <= 8'h00;
        interrupts_seen <= 32'h00000000;
      end
    else
      begin
        if (|wait_remaining_ints)
          begin
            wait_remaining_ints <= wait_remaining_ints - 8'd1;
            if (wait_remaining_ints == 8'd1)
              begin
                $display("\n **** ERROR not all expected interrupts were seen within time limit :- %h  got :- %h  address :- %h  %s %0dns",
                  apb_data_store,interrupts_seen,paddr,register_names[paddr[11:2]], $time);
                apb_fail <= 1'b1;
              end
          end
        if (check_data)
          begin
            if ((((prdata|interrupts_seen) > apb_data_store) &&  ((prdata|interrupts_seen) > (apb_data_store + est_range))) ||
                (((prdata|interrupts_seen) < apb_data_store) && (((prdata|interrupts_seen) + est_range) < apb_data_store))  ||
                (perr !== perr_expected_del))
              begin
                if (apb_data_store !== (prdata|interrupts_seen)) // & ~perr_expected_del)
                  begin
                    if (less_than_expected_ints_seen)
                      begin
                        `ifndef debugmsglvl0
                          $display("TB_APB : WARNING : Some, but not all expected interrupts were seen. Waiting 100 cycles for rest ... %0dns", $time);
                        `endif
                        wait_remaining_ints <= 8'd100;
                        interrupts_seen <= prdata;
                      end
                    else if (more_than_expected_ints_seen)
                      begin
                        interrupts_seen <= 32'd0;
                        if (ints_were_expected_over_2 | ints_were_expected_over_1)
                          begin
                            `ifndef debugmsglvl0
                              $display("TB_APB : NOTE : More interrupts than expected were observed. However, they were expected soon after so ok ... %0dns",$time);
                            `endif
                          end
                        else
                          begin
                            $display("\n **** ERROR : More interrupts than expected were observed. Expected :- %h, %0dns",apb_data_store,$time);
                            apb_fail <= 1'b1;
                          end
                      end
                    else if (wait_remaining_ints == 8'd0)
                      begin
                        interrupts_seen <= 32'd0;
                        if (poll_count == 0)
                          begin
                            if (|est_range)
                              $display("\n **** ERROR read APB data expected(+-%0d) :- %h  got :- %h  address :- %h  %s %0dns",est_range,apb_data_store,(prdata|interrupts_seen),paddr,register_names[paddr[12:2]], $time);
                            else
                              $display("\n **** ERROR read APB data expected :- %h  got :- %h  address :- %h  %s %0dns",apb_data_store,(prdata|interrupts_seen),paddr,register_names[paddr[12:2]], $time);
                            apb_fail <= 1'b1;
                          end
                      end
                  end
                else
                  begin
                    interrupts_seen <= 32'd0;
                    `ifndef debugmsglvl0
                    $display("       good read APB data expected :- %h  got :- %h  address :- %h  %s",
                          apb_data_store,(prdata|interrupts_seen),paddr,register_names[paddr[12:2]]);
                    `endif
                  end
                if (perr !== perr_expected_del)
                  begin
                    $display(" **** ERROR on APB read - expected perr to be :- %h  got perr of :- %h\n",perr_expected_del,perr);
                      apb_fail <= 1'b1;
                  end
              end
            else
              begin
                if (|wait_remaining_ints) // We have obtained all the ints we need now ..
                  begin
                    interrupts_seen <= interrupts_seen | prdata;  // There will be one more apb read after this - have to do this due to the way the TB is pipelined (legacy code)
                    wait_remaining_ints <= 8'h00;
                    `ifndef debugmsglvl0
                      $display("TB_APB : OK, got the rest of the interrupts, continuing test ... :- %h  got :- %h  address :- %h  %s",
                        apb_data_store, (prdata|interrupts_seen), paddr,register_names[paddr[12:2]]);
                    `endif
                  end
                else
                  begin
                    interrupts_seen <= 32'd0;
                    `ifndef debugmsglvl0
                      if (|est_range)
                        $display("       estimated read APB data expected :- %h  got :- %h  address :- %h  %s",
                          apb_data_store, (prdata|interrupts_seen), paddr, register_names[paddr[12:2]]);
                      else
                        $display("       good read APB data expected :- %h  got :- %h  address :- %h  %s",
                          apb_data_store, (prdata|interrupts_seen), paddr, register_names[paddr[12:2]]);
                    `endif
                  end
                apb_fail <= 1'b0;
              end
          end
        else
          apb_fail <= 1'b0;
      end
  end

// drive APB outputs
always @( negedge (reset_tb) or posedge (pclk) )
  begin
    if (~reset_tb)
      begin
        first_half   <= 1'b1;
        check_data   <= 1'b0;
        apb_trig_ack <= 1'b0;
        apb_index    <= 1;
        paddr        <= 13'b0;
        pwdata       <= 32'b0;
        pwdata_par   <= 4'h0;
        pwrite       <= 1'b0;
        penable      <= 1'b0;
        psel         <= 1'b0;
        poll_count   <= 16'd0;
      end
    else if (apb_done | ~apb_trig_sync) // If all done or waiting for trigger keep all idle
      begin
        first_half   <= 1'b1;
        check_data   <= 1'b0;
        apb_trig_ack <= 1'b0;
        paddr        <= 13'b0;
        pwdata       <= 32'b0;
        pwdata_par   <= 4'h0;
        pwrite       <= 1'b0;
        penable      <= 1'b0;
        psel         <= 1'b0;
        poll_count   <= 16'd0;
        est_range    <= 16'h0 ;
      end
    else // receive a trigger so do a read or write
      begin
        // always selected whilst doing something unless control = 5
        psel <= (apb_control != 3'b101) & ~(less_than_expected_ints_seen & wait_remaining_ints == 8'd0);
        // determine if a write or read
        pwrite <= ~apb_read;
        // assign paddr output
        paddr[12:0] <= {apb_address[12:2],2'b00};
        if (apb_read) // drive write data if a write is required
          begin
            pwdata <=  32'b0;
            pwdata_par <= 4'h0;
          end
        else
          begin
            pwdata <= apb_data;
            pwdata_par <= {^apb_data[31:24],^apb_data[23:16],^apb_data[15:8],^apb_data[7:0]} ^ {4{inj_par_err}};
          end
        check_data  <= 1'b0;
        if (first_half) // first half of 2 phase APB cycle (psel high, penable low)
          begin
            est_range <= apb_control == 3'b111 ? apb_vector[79:64] : 16'h0 ;
            penable    <= 1'b0;
            if (less_than_expected_ints_seen & wait_remaining_ints == 8'd0)
              begin
                apb_index <= apb_index - 1;
                //apb_trig_ack <= 1'b1;
              end
            else if (check_data && poll_count != 0 && apb_read)
              begin
                if (poll_count == apb_vector[79:64])
                  $display("TB_APB : NOTE : Polling address 0x%h for data 0x%h ... %0dns", paddr, apb_data_store, $time);
                if (apb_data_store == (prdata|interrupts_seen))
                  begin
                    poll_count <= apb_control_next == 3'b110 ? apb_vector_next[79:64] : 4'h0 ;
                    apb_index  <= apb_index + 1;
                    // If next testbench control requires a wait then trigger
                    // acknowledge to ensure we halt until next trigger.
                    if ((apb_control_next == 3'b000) |
                        (apb_control_next == 3'b001) |
                        (apb_control_next == 3'b010))
                      apb_trig_ack <= 1'b1;
                  end
                else
                  begin
                    first_half <= 0;   // next phase will be second one
                    poll_count <= poll_count - 1;
                  end
              end
            else
              begin
                first_half <= 0;   // next phase will be second one
                poll_count <= apb_control == 3'b110 ? apb_vector[79:64] : 4'h0 ;
                if (wait_remaining_ints == 8'd1)
                  apb_index <= apb_index + 1;
              end
          end
        else // second phase of 2 phase APB cycle (psel high, penable high)
          begin
            first_half <= 1'b1; // next must be phase 1
            penable    <= 1'b1; // drive penable high for phase 2
            // if doing a read then check data at next pclk rising edge
            // load expected data in apb_data_store for comparison
            if (apb_read & psel)
              begin
                check_data     <= 1'b1;
                apb_data_store <= apb_data;
              end
            else if (psel) // otherwise must be a write if psel is selected
              begin
                $display("       write APB                               data :- %h  address :- %h  %s",
                  apb_data,paddr,register_names[paddr[12:2]]);
              end
            else // else must be a dummy read or write
              begin
                $display("       dummy APB access                        data :- %h  address :- %h",
                  apb_data,paddr);
              end
            // If next testbench control requires a wait then trigger
            // acknowledge to ensure we halt until next trigger.
            if (poll_count == 16'd0 &&
                (apb_control_next == 3'b000) |
                (apb_control_next == 3'b001) |
                (apb_control_next == 3'b010))
               apb_trig_ack <= 1'b1;
            // advance array pointer to get next data
            // hold index if still waiting for interrupts
            if (|wait_remaining_ints || (|poll_count))
              apb_index <= apb_index;
            else
              apb_index <= apb_index + 1;
          end
      end
  end

// -----------------------------------------------------------------------------
// APB testbench control outputs to rest of testbench
// -----------------------------------------------------------------------------

// drive trig_from_apb to trigger other testbench activity
always @(apb_control or reset_tb)
if (~reset_tb )
  trig_from_apb = 1'b0;
else if (apb_control == 3'b011)
  begin
    trig_from_apb = 1'b1;
    #100 trig_from_apb = 1'b0;
  end

// decide when all APB activity complete
assign apb_done = (apb_control == 3'b000) & ~check_data;

// indicate when the interrupt status register is read
`ifdef gem_irq_read_clear
  assign apb_int_status_read     = (check_data) & (paddr == 13'h0024);
  assign apb_int_q1_status_read  = (check_data) & (paddr == 13'h0400);
  assign apb_int_q2_status_read  = (check_data) & (paddr == 13'h0404);
  assign apb_int_q3_status_read  = (check_data) & (paddr == 13'h0408);
  assign apb_int_q4_status_read  = (check_data) & (paddr == 13'h040c);
  assign apb_int_q5_status_read  = (check_data) & (paddr == 13'h0410);
  assign apb_int_q6_status_read  = (check_data) & (paddr == 13'h0414);
  assign apb_int_q7_status_read  = (check_data) & (paddr == 13'h0418);
  assign apb_int_q8_status_read  = (check_data) & (paddr == 13'h041c);
  assign apb_int_q9_status_read  = (check_data) & (paddr == 13'h0420);
  assign apb_int_q10_status_read = (check_data) & (paddr == 13'h0424);
  assign apb_int_q11_status_read = (check_data) & (paddr == 13'h0428);
  assign apb_int_q12_status_read = (check_data) & (paddr == 13'h042c);
  assign apb_int_q13_status_read = (check_data) & (paddr == 13'h0430);
  assign apb_int_q14_status_read = (check_data) & (paddr == 13'h0434);
  assign apb_int_q15_status_read = (check_data) & (paddr == 13'h0438);
  assign apb_emac_int_status_read = (check_data) & (paddr == 13'h1024);
  assign apb_mmsl_int_status_read = (check_data) & (paddr == 13'h0f18);
  assign apb_emac_int_status_read = (check_data) & (paddr == 13'h1024);
  assign apb_asf_int_nonfatal_status_read      = (check_data) & ((paddr == 13'h0e00) | (paddr == 13'h0e04));
  assign apb_asf_int_fatal_status_read         = (check_data) & ((paddr == 13'h0e00) | (paddr == 13'h0e04));
  assign apb_emac_asf_int_nonfatal_status_read = (check_data) & ((paddr == 13'h1e00) | (paddr == 13'h1e04));
  assign apb_emac_asf_int_fatal_status_read    = (check_data) & ((paddr == 13'h1e00) | (paddr == 13'h1e04));
`else // if not gem_irq_read_clear
  assign apb_int_status_read     = (psel & pwrite & penable) & (paddr == 13'h0024);
  assign apb_int_q1_status_read  = (psel & pwrite & penable) & (paddr == 13'h0400);
  assign apb_int_q2_status_read  = (psel & pwrite & penable) & (paddr == 13'h0404);
  assign apb_int_q3_status_read  = (psel & pwrite & penable) & (paddr == 13'h0408);
  assign apb_int_q4_status_read  = (psel & pwrite & penable) & (paddr == 13'h040c);
  assign apb_int_q5_status_read  = (psel & pwrite & penable) & (paddr == 13'h0410);
  assign apb_int_q6_status_read  = (psel & pwrite & penable) & (paddr == 13'h0414);
  assign apb_int_q7_status_read  = (psel & pwrite & penable) & (paddr == 13'h0418);
  assign apb_int_q8_status_read  = (psel & pwrite & penable) & (paddr == 13'h041c);
  assign apb_int_q9_status_read  = (psel & pwrite & penable) & (paddr == 13'h0420);
  assign apb_int_q10_status_read = (psel & pwrite & penable) & (paddr == 13'h0424);
  assign apb_int_q11_status_read = (psel & pwrite & penable) & (paddr == 13'h0428);
  assign apb_int_q12_status_read = (psel & pwrite & penable) & (paddr == 13'h042c);
  assign apb_int_q13_status_read = (psel & pwrite & penable) & (paddr == 13'h0430);
  assign apb_int_q14_status_read = (psel & pwrite & penable) & (paddr == 13'h0434);
  assign apb_int_q15_status_read = (psel & pwrite & penable) & (paddr == 13'h0438);
  assign apb_emac_int_status_read = (psel & pwrite & penable) & (paddr == 13'h1024);
  assign apb_mmsl_int_status_read = (psel & pwrite & penable) & (paddr == 13'h0f18);
  assign apb_asf_int_nonfatal_status_read      = (psel & pwrite & penable) & ((paddr == 13'h0e00) | (paddr == 13'h0e04));
  assign apb_asf_int_fatal_status_read         = (psel & pwrite & penable) & ((paddr == 13'h0e00) | (paddr == 13'h0e04));
  assign apb_emac_asf_int_nonfatal_status_read = (psel & pwrite & penable) & ((paddr == 13'h1e00) | (paddr == 13'h1e04));
  assign apb_emac_asf_int_fatal_status_read    = (psel & pwrite & penable) & ((paddr == 13'h1e00) | (paddr == 13'h1e04));
`endif // gem_irq_read_clear

// indicate a write to enable 64b ahb addressing mode
assign apb_64b_addr_mode_en_pulse = (psel & pwrite & penable) & (paddr == 13'h0010) & (pwdata[30] == 1'b1);
assign apb_tx_ext_bd_mode = (psel & pwrite & penable) & (paddr == 13'h0010) & (pwdata[29] == 1'b1);

// drive APB outputs
always @( negedge (reset_tb) or posedge (pclk) )
begin
  if (~reset_tb)
    begin
      apb_64b_addr_mode_en   <= 1'b0;
      apb_tx_ext_bd_mode_en <= 1'b0;
      apb_qos_for_axi <= {128{1'b0}};
    end
  else if ((psel & pwrite & penable) & (paddr == 13'h0010))
    begin
      apb_64b_addr_mode_en   <= pwdata[30];
      apb_tx_ext_bd_mode_en  <= pwdata[29];
    end
  else if ((psel & pwrite & penable) & (paddr == {1'b0,`gem_axi_qos_cfg0}))
    for (int j=0;j<32;j++) apb_qos_for_axi[j] <= pwdata[j];
  else if ((psel & pwrite & penable) & (paddr == {1'b0,`gem_axi_qos_cfg1}))
    for (int j=0;j<32;j++) apb_qos_for_axi[32+j] <= pwdata[j];
  else if ((psel & pwrite & penable) & (paddr == {1'b0,`gem_axi_qos_cfg2}))
    for (int j=0;j<32;j++) apb_qos_for_axi[64+j] <= pwdata[j];
  else if ((psel & pwrite & penable) & (paddr == {1'b0,`gem_axi_qos_cfg3}))
    for (int j=0;j<32;j++) apb_qos_for_axi[96+j] <= pwdata[j];
end

// -----------------------------------------------------------------------------
// Determine if the LFSM is enabled by looking at APB write transactions
// -----------------------------------------------------------------------------

assign link_fault_sig_en = &condition_buffer;

always@(posedge pclk or negedge reset_tb) begin
  if (~reset_tb) begin
    condition_buffer <= 4'b0000;
  end else begin
    if (psel & penable & pwrite & (paddr == 13'h000)) begin // network_control
      // bit: two_pt_five_gig
      condition_buffer[0] <= pwdata[29];
    end else if (psel & penable & pwrite & (paddr == 13'h200)) begin // pcs_control
      // bit: enable_auto_neg
      condition_buffer[1] <= !pwdata[12];
    end else if (psel & penable & pwrite & (paddr == 13'h004)) begin // network_config
      // bit: uni_direction_enable
      condition_buffer[2] <= !pwdata[31];
      // bit: pcs_select
      condition_buffer[3] <= pwdata[11];
    end
  end
end

endmodule

