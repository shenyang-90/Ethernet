//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description : This file contains the interface used for misc signals 
// that need to be driven or monitored but do not belong to their own UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_protocol_demo_misc_signals_if.sv
 * 
 * This files contains the protocol-speficic extension of the 
 * cdn_demo_misc_signals_if HDL interface, which contains miscellaneous signals 
 * that need to be driven or monitored in the testbench but do not belong to
 * their own interface UVC.
 */

`ifndef CDN_PROTOCOL_MISC_SIGNALS_IF_SV
  `define CDN_PROTOCOL_MISC_SIGNALS_IF_SV

//------------------------------------------------------------------------
// DUT MISC INTERFACE SIGNALS.
//------------------------------------------------------------------------

// Integer value used to convert PureSpec *Denali* Error into UVM_ERROR (count
// the number of the former and issue the latter).
integer ps_error_count;

//------------------------------------------------------------------------
// DUT MISC INTERFACE SIGNALS.
//------------------------------------------------------------------------

// Internal Loopback Signals
wire loopback_local;

// Ten Bit Interface (TBI)
wire          pcs_cal_bypass;
wire          pcs_cgalign_bypass;
`ifdef gem_pcs_20b_if
  wire [19:0] tx_group;
  wire [19:0] rx_group;
`else
  wire  [9:0] tx_group;
  wire  [9:0] rx_group;
`endif
wire          ewrap;
wire          en_cdet;
wire          signal_detect;

// MDIO Interface
wire mdc;
wire mdio_in;
wire mdio_out;
wire mdio_en;

// Control/Status Interface
wire       loopback;
wire       half_duplex;
wire [3:0] speed_mode;
wire       tx_pause;
wire       tx_pfc_sel;
wire       tx_pause_zero;
wire [7:0] tx_pfc_pause;
wire [7:0] tx_pfc_pause_zero;
wire       trigger_dma_tx_start;
wire [7:0] rx_pfc_paused;
wire       pfc_negotiate;
wire       rx_databuf_wr_q0;
wire       rx_databuf_wr_q1;
wire       rx_databuf_wr_q2;
wire       rx_databuf_wr_q3;
wire       rx_databuf_wr_q4;
wire       rx_databuf_wr_q5;
wire       rx_databuf_wr_q6;
wire       rx_databuf_wr_q7;
wire       rx_databuf_wr_q8;
wire       rx_databuf_wr_q9;
wire       rx_databuf_wr_q10;
wire       rx_databuf_wr_q11;
wire       rx_databuf_wr_q12;
wire       rx_databuf_wr_q13;
wire       rx_databuf_wr_q14;
wire       rx_databuf_wr_q15;
wire       halfduplex_flow_control_en;
wire [1:0] dma_bus_width;

// Time Stamp Unit (TSU)
wire  [1:0] gem_tsu_inc_ctrl;
wire        gem_tsu_ms;
wire [93:0] tsu_timer_cnt;
wire [11:0] tsu_timer_cnt_par;
wire        tsu_timer_cmp_val;
wire [93:0] ext_tsu_timer;
wire [11:0] ext_tsu_timer_par;

// External Filter Interface
wire         ext_match1;
wire         ext_match2;
wire         ext_match3;
wire         ext_match4;
wire  [47:0] ext_sa;
wire         ext_sa_stb;
wire  [47:0] ext_da;
wire         ext_da_stb;
wire  [15:0] ext_type;
wire         ext_type_stb;
wire  [31:0] ext_vlan_tag1;
wire         ext_vlan_tag1_stb;
wire  [31:0] ext_vlan_tag2;
wire         ext_vlan_tag2_stb;
wire [127:0] ext_ip_sa;
wire         ext_ip_sa_stb;
wire [127:0] ext_ip_da;
wire         ext_ip_da_stb;
wire  [15:0] ext_source_port;
wire         ext_sp_stb;
wire  [15:0] ext_dest_port;
wire         ext_dp_stb;
wire         ext_ipv6;
wire         wol;

// User IO Interface
`ifdef gem_user_io 
  wire [(`gem_user_out_width - 1):0] user_out;
  wire  [(`gem_user_in_width - 1):0] user_in;
`endif

// IEEE 1588 PTP Frame Recognition
wire sof_tx;
wire sync_frame_tx;
wire delay_req_tx;
wire pdelay_req_tx;
wire pdelay_resp_tx;
wire sof_rx;
wire sync_frame_rx;
wire delay_req_rx;
wire pdelay_req_rx;
wire pdelay_resp_rx;

// Interrupt Controller Interface
wire ext_interrupt_in;
wire ethernet_int;
wire emac_ethernet_int;
wire mmsl_int;
wire ethernet_int_q1;
wire ethernet_int_q2;
wire ethernet_int_q3;
wire ethernet_int_q4;
wire ethernet_int_q5;
wire ethernet_int_q6;
wire ethernet_int_q7;
wire ethernet_int_q8;
wire ethernet_int_q9;
wire ethernet_int_q10;
wire ethernet_int_q11;
wire ethernet_int_q12;
wire ethernet_int_q13;
wire ethernet_int_q14;
wire ethernet_int_q15;

// External Transmit FIFO Interface
wire        [`edma_queues-1:0] tx_r_data_rdy;
wire                           tx_r_valid;
wire [`gem_emac_bus_width-1:0] tx_r_data;
wire                           tx_r_sop;
wire                           tx_r_eop;
wire                     [3:0] tx_r_mod;
wire                           tx_r_err;
wire                           tx_r_underflow;
wire                           tx_r_flushed;
wire                           tx_r_control;
wire   [(`edma_queues*14)-1:0] tx_r_frame_size;
wire        [`edma_queues-1:0] tx_r_frame_size_vld;
wire                           dma_tx_status_tog;
wire        [`edma_queues-1:0] tx_r_rd;
wire                           dma_tx_end_tog;
wire                     [3:0] tx_r_status;
wire                     [3:0] tx_r_queue;
wire                    [77:0] tx_r_timestamp;

// External Receive FIFO Interface
wire                             rx_w_overflow;
wire                             rx_w_wr;
wire   [`gem_emac_bus_width-1:0] rx_w_data;
wire                             rx_w_sop;      
wire                             rx_w_eop;  
wire                      [44:0] rx_w_status;
wire                       [3:0] rx_w_mod;
wire                             rx_w_err;
wire                             rx_w_flush;       
wire [`num_spec_add_filters-1:0] add_match_vec;     
wire                      [77:0] rx_w_timestamp;
wire                       [3:0] rx_w_queue;  

// ASF Signals
wire asf_trans_to_err;
wire asf_protocol_err;
wire asf_int_nonfatal;
wire asf_int_fatal;
wire asf_sram_corr_err;
wire asf_sram_uncorr_err;
wire asf_integrity_err;
wire asf_dap_err;
wire asf_csr_err;
wire emac_asf_trans_to_err;
wire emac_asf_protocol_err;
wire emac_asf_int_nonfatal;
wire emac_asf_int_fatal;
wire emac_asf_sram_corr_err;
wire emac_asf_sram_uncorr_err;
wire emac_asf_integrity_err;
wire emac_asf_dap_err;
wire emac_asf_csr_err;

//-------------------------------------
// 802.3br Signals
//-------------------------------------  

// External Transmit FIFO Interface
wire                           emac_tx_r_data_rdy;
wire                           emac_tx_r_valid;
wire [`gem_emac_bus_width-1:0] emac_tx_r_data;
wire                           emac_tx_r_sop;
wire                           emac_tx_r_eop;
wire                     [3:0] emac_tx_r_mod;
wire                           emac_tx_r_err;
wire                           emac_tx_r_underflow;
wire                           emac_tx_r_flushed;
wire                           emac_tx_r_control;
wire                    [13:0] emac_tx_r_frame_size;
wire                           emac_tx_r_frame_size_vld;
wire                           emac_dma_tx_status_tog;
wire                           emac_tx_r_rd;
wire                           emac_dma_tx_end_tog;
wire                     [3:0] emac_tx_r_status;
wire                     [3:0] emac_tx_r_queue;
wire                    [77:0] emac_tx_r_timestamp;

// External Receive FIFO Interface
wire                             emac_rx_w_overflow;
wire                             emac_rx_w_wr;
wire   [`gem_emac_bus_width-1:0] emac_rx_w_data;
wire                             emac_rx_w_sop;      
wire                             emac_rx_w_eop;  
wire                      [44:0] emac_rx_w_status;
wire                       [3:0] emac_rx_w_mod;
wire                             emac_rx_w_err;
wire                             emac_rx_w_flush;       
wire [`num_spec_add_filters-1:0] emac_add_match_vec;     
wire                      [77:0] emac_rx_w_timestamp;
wire                       [3:0] emac_rx_w_queue;  

//------------------------------------------------------------------------
// OTHER COMPONENTS INTERFACE SIGNALS.
//------------------------------------------------------------------------

// TX SRAM interface
wire                                               txsram_wea;   // port A write enable.
wire                                               txsram_ena;   //        chip enable.
wire                                               txsram_clka;  //        clock.
wire                       [`gem_tx_pbuf_addr-1:0] txsram_addra; //        address bus.
wire [`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] txsram_dia;   //        write data bus.
wire [`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] txsram_doa;   //        read data bus.
wire                                               txsram_web;   // port B write enable.
wire                                               txsram_enb;   //        chip enable.
wire                                               txsram_clkb;  //        clock.  
wire                       [`gem_tx_pbuf_addr-1:0] txsram_addrb; //        address bus.
wire [`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] txsram_dib;   //        write data bus.
wire [`edma_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] txsram_dob;   //        read data bus.

// RX SRAM interface
wire                                               rxsram_wea;   // port A write enable.
wire                                               rxsram_ena;   //        chip enable.
wire                                               rxsram_clka;  //        clock.  
wire                       [`gem_rx_pbuf_addr-1:0] rxsram_addra; //        address bus.
wire [`edma_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] rxsram_dia;   //        write data bus.
wire [`edma_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] rxsram_doa;   //        read data bus.
wire                                               rxsram_web;   // port B write enable.
wire                                               rxsram_enb;   //        chip enable.
wire                                               rxsram_clkb;  //        clock.  
wire                       [`gem_rx_pbuf_addr-1:0] rxsram_addrb; //        address bus.
wire [`edma_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] rxsram_dib;   //        write data bus.
wire [`edma_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] rxsram_dob;   //        read data bus.

//-------------------------------------
// 802.3br Signals
//-------------------------------------  

// TX SRAM interface
wire                                                    emac_txsram_wea;   // port A write enable.
wire                                                    emac_txsram_ena;   //        chip enable.
wire                                                    emac_txsram_clka;  //        clock.
wire                       [`gem_emac_tx_pbuf_addr-1:0] emac_txsram_addra; //        address bus.
wire [`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] emac_txsram_dia;   //        write data bus.
wire [`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] emac_txsram_doa;   //        read data bus.
wire                                                    emac_txsram_web;   // port B write enable.
wire                                                    emac_txsram_enb;   //        chip enable.
wire                                                    emac_txsram_clkb;  //        clock.
wire                       [`gem_emac_tx_pbuf_addr-1:0] emac_txsram_addrb; //        address bus.
wire [`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] emac_txsram_dib;   //        write data bus.
wire [`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0] emac_txsram_dob;   //        read data bus.

// RX SRAM interface
wire                                                    emac_rxsram_wea;   // port A write enable.
wire                                                    emac_rxsram_ena;   //        chip enable.
wire                                                    emac_rxsram_clka;  //        clock.
wire                       [`gem_emac_rx_pbuf_addr-1:0] emac_rxsram_addra; //        address bus.
wire [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] emac_rxsram_dia;   //        write data bus.
wire [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] emac_rxsram_doa;   //        read data bus.
wire                                                    emac_rxsram_web;   // port B write enable.
wire                                                    emac_rxsram_enb;   //        chip enable.
wire                                                    emac_rxsram_clkb;  //        clock.
wire                       [`gem_emac_rx_pbuf_addr-1:0] emac_rxsram_addrb; //        address bus.
wire [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] emac_rxsram_dib;   //        write data bus.
wire [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0] emac_rxsram_dob;   //        read data bus.

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
