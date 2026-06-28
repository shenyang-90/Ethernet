//------------------------------------------------------------------------------
// Copyright (c) 2001-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_top.v
//   Module Name:        tb_top
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
//   Description    :  Top level of level 0 (ie stand alone) test bench for GEM
//              This intances other testbench modules and provides
//              top level control and reporting of testbench activity
//
//------------------------------------------------------------------------------


`include "tb_defs.v"
`include "edma_defs.v"

module tb_top (

  // system interface (resets)
  n_txreset,
  n_gtxreset,
  n_ntxreset,
  n_nrxreset,
  n_rxreset,
  n_rbc0reset,
  n_rbc1reset,
  n_clk_ctl_rst,

  // ethernet signals
  col,
  crs,
  tx_er,
  txd,
  rxd,
  `ifdef xgm
  txc,
  rxc,
  `endif
  tx_en,
  tx_clk_from_phy,
  tx_clk_to_gem,
  n_rx_clk_to_gem,
  n_tx_clk_to_gem,
  rx_er,
  rx_clk_from_phy,
  rx_clk_to_gem,
  rx_dv,
  mdc,
  mdio_in,
  mdio_out,
  mdio_en,
  loopback,
  half_duplex,
  two_pt_five_gig,
  gigabit,
  tbi,
  speed,
  ext_interrupt_in,
  tx_pause,
  tx_pause_zero,
  tx_pfc_sel,
  tx_pfc_pause,
  tx_pfc_pause_zero,
  wol,
  tx_group,
  rx_group,
  ewrap,
  en_cdet,
  signal_detect,
  rbc0_from_phy,
  rbc1_from_phy,
  gtx_ref_clk,
  gtx20_ref_clk,
  n_gtx20reset,
  loop_clk_source,
  `ifdef edma_tx_pkt_buffer
  trigger_dma_tx_start,
  `endif
  pcs_cal_bypass,
  pcs_cgalign_bypass,

  // serdes signals
  pma_rx_clk,
  n_prxreset,
  pma_rx20_clk,
  n_pmarx20reset,

  // external filter interface
  ext_match1,
  ext_match2,
  ext_match3,
  ext_match4,
  ext_da,
  ext_da_stb,
  ext_sa,
  ext_sa_stb,
  ext_type,
  ext_type_stb,
  ext_vid,
  ext_vid_stb,
  ext_ip_sa,
  ext_ip_sa_stb,
  ext_ip_da,
  ext_ip_da_stb,
  ext_source_port,
  ext_sp_stb,
  ext_dest_port,
  ext_dp_stb,
  ext_ipv6,
  ext_vlan_tag1_stb,
  ext_vlan_tag1,
  ext_vlan_tag2_stb,
  ext_vlan_tag2,

  // precision time protocol signals for IEEE 1588 support
  sof_tx,
  sync_frame_tx,
  delay_req_tx,
  pdelay_req_tx,
  pdelay_resp_tx,
  sof_rx,
  sync_frame_rx,
  delay_req_rx,
  pdelay_req_rx,
  pdelay_resp_rx,
  `ifdef edma_tsu
  edma_tsu_inc_ctrl,
  edma_tsu_ms,
  tsu_timer_cmp_val,
  `endif // edma_tsu
  tsu_clk,
  n_tsureset,

  // APB interface signals
  pclk_source,
  n_preset,
  paddr,
  prdata,
  pwdata,
  pwdata_par,
  pwrite,
  penable,
  psel,
  perr,

  // AHB interface signals
  hclk_source,
  n_hreset,
  dma_bus_width,

  `ifdef edma_axi

  // Write Address Channel
  awid,
  awaddr,
  awlen,
  awsize,
  awburst,
  awlock,
  awcache,
  awprot,
  awqos,
  awvalid,
  awready,
  // Write Data Channel
  wdata,
  wstrb,
  wlast,
  wready,
  wvalid,

  // Response Channel
  bid,
  bresp,
  bvalid,
  bready,

  // Read Address Channel
  arid,
  araddr,
  arlen,
  arsize,
  arburst,
  arlock,
  arcache,
  arprot,
  arqos,
  arvalid,
  arready,
  // Read Data Channel
  rid,
  rdata,
  rresp,
  rlast,
  rvalid,
  rready,

  `else

  hgrantdma,
  hbusreqdma,
  hlockdma,
  hready,
  hresp,
  haddr,
  htrans,
  hwrite,
  hrdata,
  hsize,
  hburst,
  hprot,
  hwdata,
  `endif

  // external fifo interface.
  tx_r_data,
  tx_r_mod,
  tx_r_sop,
  tx_r_eop,
  tx_r_err,
  tx_r_valid,
  tx_r_data_rdy,
  tx_r_underflow,
  tx_r_rd,
  tx_r_flushed,
  tx_r_control,
  tx_r_status,
  `ifdef gem_fifo_8b_if
  tx_r_fixed_lat,
  `endif
  dma_tx_status_tog,
  dma_tx_end_tog,
  rx_w_wr,
  rx_w_data,
  rx_w_mod,
  rx_w_sop,
  rx_w_eop,
  rx_w_err,
  rx_w_flush,
  rx_w_status,
  rx_w_queue,
  rx_w_overflow,

  // PFC signals
  pfc_negotiate,
  rx_pfc_paused,

  // Other signals
  force_back_pressure,
  `ifdef gem_user_io
  user_out,
  user_in,
  `endif // gem_user_io
  ethernet_int,
  ethernet_int_q1,
  ethernet_int_q2,
  ethernet_int_q3,
  ethernet_int_q4,
  ethernet_int_q5,
  ethernet_int_q6,
  ethernet_int_q7,
  ethernet_int_q8,
  ethernet_int_q9,
  ethernet_int_q10,
  ethernet_int_q11,
  ethernet_int_q12,
  ethernet_int_q13,
  ethernet_int_q14,
  ethernet_int_q15,
  emac_ethernet_int,
  mmsl_int,

  dma_done,
  wr_tog_fail,
  flow_ctrl_done,
  min_toggle_time_fail,

  // mii select
  mii_select,
  rmii_ref_clk,
  n_rmii_ref_reset,
  txd_rmii,
  tx_en_rmii,
  rxd_rmii,
  rx_er_rmii,
  crs_dv_rmii,

  amba_par_err_inj,

  // ASF comman output error indications
`ifdef edma_tx_pkt_buffer
  `ifdef gem_asf_ecc_sram
  asf_sram_corr_err,
  `endif
  `ifdef gem_asf_dap_prot
  asf_sram_uncorr_err,
  `endif
`endif
  `ifdef gem_asf_integrity_prot
  asf_integrity_err,
  `endif
  `ifdef gem_asf_dap_prot
  asf_dap_err,
  `endif
  `ifdef gem_asf_csr_prot
  asf_csr_err,
  `endif
  asf_trans_to_err,
  asf_protocol_err,
  // ASF and fatal and non-fatal interrupts
  asf_int_nonfatal,
  asf_int_fatal,

  `ifdef gem_has_802p3_br
  // ASF comman output error indications for emac
`ifdef edma_tx_pkt_buffer
  `ifdef gem_asf_ecc_sram
  emac_asf_sram_corr_err,
  `endif
  `ifdef gem_asf_dap_prot
  emac_asf_sram_uncorr_err,
  `endif
`endif
  `ifdef gem_asf_integrity_prot
  emac_asf_integrity_err,
  `endif
  `ifdef gem_asf_dap_prot
  emac_asf_dap_err,
  `endif
  `ifdef gem_asf_csr_prot
  emac_asf_csr_err,
  `endif
  emac_asf_trans_to_err,
  emac_asf_protocol_err,
  // ASF and fatal and non-fatal interrupts for emac
  emac_asf_int_nonfatal,
  emac_asf_int_fatal,
  `endif


  // Double error injection to SRAM
  `ifdef edma_tx_pkt_buffer
  txsram_en,
  txsram_we,
  txsram_dob,
  txsram_dob_err_inj,
  `endif // edma_tx_pkt_buffer
  `ifdef edma_rx_pkt_buffer
  rxsram_en,
  rxsram_we,
  rxsram_dob,
  rxsram_dob_err_inj,
  `endif // edma_rx_pkt_buffer

  // SRAM READ Addresses (for checking ECC fault location)
  rx_sram_read_add,
  tx_sram_read_add,
  ifss_dis_x_drv,
  fault_sim_for_dc_en,
  double_error_injection,
  single_error_injection,
  num_sram_errors_to_inject,

  test_ending

  );

  parameter FILTER_CHECK_DELAY = 6;
`ifdef gem_pcs_20b_if
  parameter p_pcs_width = 20;
`else
  parameter p_pcs_width = 10;
`endif

  `include "edma_params.v"
  // --
  // UVM TB
  // --
  `ifdef CDN_LEGACY_UVM
    event legacy_tb_done;
  `endif
  // system interface (resets)
  output        n_txreset;            // tx_clk domain reset
  output        n_gtxreset;           // gtx_clk domain reset
  output        n_ntxreset;           // n_tx_clk domain reset
  output        n_nrxreset;           // n_rx_clk domain reset
  output        n_rxreset;            // rx_clk domain reset
  output        n_rbc0reset;          // rbc0 domain reset
  output        n_rbc1reset;          // rbc1 domain reset
  output        n_clk_ctl_rst;        // reset to clock control block

  // ethernet signals
  output        col;                  // collision detect signal from the PHY
  output        crs;                  // carrier sense signal from the PHY
  input         tx_er;                // transmit error signal to the PHY
  `ifdef xgm
  input  [31:0] txd;                  // transmit data to the PHY
  input   [3:0] txc;                  // transmit control to the PHY
  output [31:0] rxd;                  // receive data to the PHY
  output  [3:0] rxc;                  // receive control to the PHY
  `else
  input   [7:0] txd;                  // transmit data to the PHY
  output  [7:0] rxd;                  // transmit data to the PHY
  `endif
  input         tx_en;                // transmit enable signal to the PHY
  output        tx_clk_from_phy;      // transmit clock from the PHY
  input         tx_clk_to_gem;        // transmit clock to the MAC
  input         n_tx_clk_to_gem;      // inverted transmit clock to the MAC
  input         n_rx_clk_to_gem;      // inverted transmit clock to the MAC
  output        rx_er;                // receive error signal from the PHY
  output        rx_clk_from_phy;      // receive clock from the PHY
  input         rx_clk_to_gem;        // receive clock to the MAC
  output        rx_dv;                // receive data valid signal from the PHY
  input         mdc;                  // management data clock
  output        mdio_in;              // management data input
  input         mdio_out;             // management data input
  input         mdio_en;              // management data input  enable
  input         loopback;             // loopback signal to the PHY
  input         half_duplex;          // half duplex signal to the PHY
  input         two_pt_five_gig;      // indicates 2.5G operation
  input         gigabit;              // high for gigabit operation
  input         tbi;                  // high for ten bit operation
  input         speed;                // Speed pin to indicate 10/100.
  output        ext_interrupt_in;     // external interrupt input
  output        tx_pause;             // transmit pause frame. If toggled
                                      // causes a pause frame to be transmitted
  output        tx_pause_zero;        // use zero quantum in tx pause frame
  output        tx_pfc_sel;           // When set to 0, transmit 802.3
                                      // pause frame
                                      // When set to 1, transmit PFC
                                      // pause frame

  output    [7:0] tx_pfc_pause;       // priority enable vector of the
                                      // PFC pause frame
  output    [7:0] tx_pfc_pause_zero;  // When set to 1, PFC pause frame
                                      // has zero pause quantum
                                      // When set to 0, PFC pause frame
                                      // has the value of transmit pause
  input         wol;                  // Wake-on-LAN output
  input  [p_pcs_width-1:0] tx_group;  // TBI transmit data to the PHY
  output [p_pcs_width-1:0] rx_group;  // TBI receive data from the PHY
  input         ewrap;                // initiate loop back of phy.
  input         en_cdet;              // Enable comma alignment in PMA.
  output        signal_detect;        // Valid link detected from PMD.
  output        rbc0_from_phy;        // TBI receive clock from the PHY
  output        rbc1_from_phy;        // TBI receive clock from the PHY
  output        gtx_ref_clk;          // Reference clock for gtx_clk.
  output        gtx20_ref_clk;        // Reference clock for 20-bit interface
  output        n_gtx20reset;
  output        loop_clk_source;      // Clock used during internal loopback
  `ifdef edma_tx_pkt_buffer
  output        trigger_dma_tx_start; // triggers tx_start in DMA
  `endif
  output        pcs_cal_bypass;       // Bypass comma alignment function
  output        pcs_cgalign_bypass;   // Bypass codegroup alignment function
  output        pma_rx_clk;           // PMA recovered clock (125MHz)
  output        n_prxreset;           // Reset in pma_rx_clk domain.
  output        pma_rx20_clk;         // PMA 20-bit recovered clock.
  output        n_pmarx20reset;       // Reset in pma_rx20_clk domain

  // external filter interface
  output        ext_match1;           // external address match
  output        ext_match2;           // external address match
  output        ext_match3;           // external address match
  output        ext_match4;           // external address match
  input  [47:0] ext_da;               // stored destination address from the
                                      // receive data
  input         ext_da_stb;           // set when destination address valid
  input  [47:0] ext_sa;               // stored source address from the
                                      // receive data
  input         ext_sa_stb;           // set when source address valid
  input  [15:0] ext_type;             // stored length field from the
                                      // receive frame
  input         ext_type_stb;         // length/TypeID field valid
  input  [15:0] ext_vid;              // stored VLAN ID from the rxed frame
  input         ext_vid_stb;          // VLAN ID field valid strobe
  input [127:0] ext_ip_sa;            // IP source address
  input         ext_ip_sa_stb;        // IP source address valid strobe
  input [127:0] ext_ip_da;            // IP destination address
  input         ext_ip_da_stb;        // IP destination address valid strobe
  input  [15:0] ext_source_port;      // source port number
  input         ext_sp_stb;           // validates source port number
  input  [15:0] ext_dest_port;        // destination port number
  input         ext_dp_stb;           // validates destination port number
  input         ext_ipv6;             // high for ipv6

  input         ext_vlan_tag1_stb;    // VLAN tag (full 32 bits) - 1st if using stacked vlan
  input  [31:0] ext_vlan_tag1;        // VLAN tag (full 32 bits) - 1st if using stacked vlan
  input         ext_vlan_tag2_stb;    // VLAN tag (full 32 bits) - 2nd if using stacked vlan
  input  [31:0] ext_vlan_tag2;        // VLAN tag (full 32 bits) - 2nd if using stacked vlan

  // precision time protocol signals for IEEE 1588 support
  input         sof_tx;               // asserted on SFD deasserted at EOF
  input         sync_frame_tx;        // asserted if PTP sync frame is detected
  input         delay_req_tx;         // asserted if PTP delay_req is detected
  input         pdelay_req_tx;        // asserted if PTP pdelay_req is detected
  input         pdelay_resp_tx;       // asserted if PTP pdelay_resp is detected
  input         sof_rx;               // asserted on SFD deasserted at EOF
  input         sync_frame_rx;        // asserted if PTP sync frame is detected
  input         delay_req_rx;         // asserted if PTP delay_req is detected
  input         pdelay_req_rx;        // asserted if PTP pdelay_req is detected
  input         pdelay_resp_rx;       // asserted if PTP pdelay_resp is detected
  `ifdef edma_tsu
  output  [1:0] edma_tsu_inc_ctrl;    // controls TSU timer increment
  output        edma_tsu_ms;          // TSU master/slave select
  input         tsu_timer_cmp_val;    // TSU timer comparison valid
  `endif // edma_tsu
  output        tsu_clk;              // TSU clock, can be used instead of pclk
  output        n_tsureset;           // TSU clock reset

  // APB interface signals
  output        pclk_source;          // peripherical bus clock
  output        n_preset;             // Amba reset
  output [12:0] paddr;                // address bus of selected master
  input  [31:0] prdata;               // read data
  output [31:0] pwdata;               // write data
  output  [3:0] pwdata_par;
  output        pwrite;               // peripheral write strobe
  output        penable;              // peripheral enable
  output        psel;                 // peripheral select for GPIO
  input         perr;                 // peripheral address decoding error

  // AHB interface signals
  output        hclk_source;          // AHB clock
  output        n_hreset;             // AHB reset
  input   [1:0] dma_bus_width;        // encoding for DMA bus width

  `ifdef edma_axi

  // Write Address Channel
  input  [3:0]  awid;
  input  [`edma_addr_width-1:0] awaddr;
  input  [7:0]  awlen;
  input  [2:0]  awsize;
  input  [1:0]  awburst;
  input  [1:0]  awlock;
  input  [3:0]  awcache;
  input  [2:0]  awprot;
  input  [3:0]  awqos;
  input         awvalid;
  output        awready;
  // Write Data Channel
  input [127:0] wdata;
  input [15:0]  wstrb;
  input         wlast;
  output        wready;
  input         wvalid;

  // Response Channel
  output  [3:0] bid;
  output  [1:0] bresp;
  output        bvalid;
  input         bready;

  // Read Address Channel
  input  [3:0]  arid;
  input  [`edma_addr_width-1:0] araddr;
  input  [7:0]  arlen;
  input  [2:0]  arsize;
  input  [1:0]  arburst;
  input  [1:0]  arlock;
  input  [3:0]  arcache;
  input  [2:0]  arprot;
  input  [3:0]  arqos;
  input         arvalid;
  output        arready;
  // Read Data Channel
  output [3:0]  rid;
  output [127:0] rdata;
  output [1:0]  rresp;
  output        rlast;
  output        rvalid;
  input         rready;

  `else
  output        hgrantdma;            // AHB ARBITER control grant
  input         hbusreqdma;           // Bus request
  input         hlockdma;             // Lock bus - asserted with hbusreqdma
  output        hready;               // AHB Slave ready
  output  [1:0] hresp;                // AHB Slave response
                                      // (OK, error, retry or split)
  output[127:0] hrdata;               // AHB outputdata

  input  [`gem_dma_addr_width-1:0] haddr;                // address to be accessed
  input   [1:0] htrans;               // bus transfer type
                                      // (nonseq, seq, idle or busy)
  input         hwrite;               // write (active high)
  input   [2:0] hsize;                // transfer size -
                                      // set to 3'b010 for 32 bit words
                                      // set to 3'b011 for 64 bit words
                                      // set to 3'b100 for 128 bit words
  input   [2:0] hburst;               // burst type (single, incrementing etc)
  input   [3:0] hprot;                // Protection type - unused tied low
  input [127:0] hwdata;               // Write data
  `endif


  // external fifo interface.
  output[127:0] tx_r_data;            // output data from the transmit fifo
                                      // to the tx module.
  output  [3:0] tx_r_mod;             // tx number of valid bytes in last
                                      // transfer of the frame.
                                      // 0000 - tx_r_data[127:0] valid,
                                      // 0001 - tx_r_data[7:0] valid,
                                      // 0010 - tx_r_data[15:0] valid, until
                                      // 1111 - tx_r_data[119:0] valid.
  output        tx_r_sop;             // start of packet indicator.
  output        tx_r_eop;             // end of packet indicator.
  output        tx_r_err;             // packet in error indicator.
  input   [`edma_queues-1:0] tx_r_rd;              // request new data from fifo.
  output        tx_r_valid;           // new tx data available from fifo.
  output  [`edma_queues-1:0] tx_r_data_rdy;        // indicates either a complete packet
                                      // is present in the fifo or a certain
                                      // threshold of data has been crossed,
                                      // the mac uses this input to trigger
                                      // a frame transfer.
  output        tx_r_underflow;       // signals tx fifo underrun condition.
  output        tx_r_flushed;         // tx fifo has been flushed.
  output        tx_r_control;         // tx control from in-line FIFO word
  input   [3:0] tx_r_status;          // tx status written to in-line FIFO word
  `ifdef gem_fifo_8b_if
  input         tx_r_fixed_lat;
  `endif
  output        dma_tx_status_tog;    // toggle acknowledge for tx_r_status
  input         dma_tx_end_tog;       // toggle when tx_r_status is valid

  input         rx_w_wr;              // rx write output to the receive
                                      // fifo.
  input [127:0] rx_w_data;            // output data to the receive fifo.
  input   [3:0] rx_w_mod;             // rx number of valid bytes in last
                                      // transfer of the frame.
  input         rx_w_sop;             // rx start of packet indicator.
  input         rx_w_eop;             // rx end of packet indicator.
  input         rx_w_err;             // rx packet in error indicator.
  input         rx_w_flush;           // rx fifo flush from the mac
  input  [44:0] rx_w_status;          // rx status written to in-line FIFO word
  input  [3:0]  rx_w_queue;           // queue
  output        rx_w_overflow;        // rx FIFO overflow.

  // PFC signals
  input          pfc_negotiate;       // indicates a received PFC
                                      // pause frame

  input [7:0]    rx_pfc_paused;       // each bit is set when PFC frame has
                                      // been received and the associated
                                      // PFC counter != 0
  // Other signals
  output        force_back_pressure;  // External Back Pressure
  input         ethernet_int;         // interrupt signal from DUT
  input         ethernet_int_q1;      // interrupt signal from DUT
  input         ethernet_int_q2;      // interrupt signal from DUT
  input         ethernet_int_q3;      // interrupt signal from DUT
  input         ethernet_int_q4;      // interrupt signal from DUT
  input         ethernet_int_q5;      // interrupt signal from DUT
  input         ethernet_int_q6;      // interrupt signal from DUT
  input         ethernet_int_q7;      // interrupt signal from DUT
  input         ethernet_int_q8;      // interrupt signal from DUT
  input         ethernet_int_q9;      // interrupt signal from DUT
  input         ethernet_int_q10;     // interrupt signal from DUT
  input         ethernet_int_q11;     // interrupt signal from DUT
  input         ethernet_int_q12;     // interrupt signal from DUT
  input         ethernet_int_q13;     // interrupt signal from DUT
  input         ethernet_int_q14;     // interrupt signal from DUT
  input         ethernet_int_q15;     // interrupt signal from DUT
  input         emac_ethernet_int;    // ethernet mac interrupt signal.
  input         mmsl_int;             // MMSL interrupt pin
  output        dma_done;
  input         wr_tog_fail;
  input         flow_ctrl_done;
  input         min_toggle_time_fail;
  `ifdef gem_user_io
  input  [(`gem_user_out_width - 1):0]// programmable user outputs
                user_out;             // from top level
  output [(`gem_user_in_width - 1):0] // programmable user inputs
                user_in;              // to top level
  `endif // gem_user_io

  output        mii_select;           // selects mii (1) or rmii (0)
  output        rmii_ref_clk;         // 50MHz clock for the RMII interface
  output        n_rmii_ref_reset;     // reset for rmii_ref_clk
  input  [1:0]  txd_rmii;
  input         tx_en_rmii;
  output  [1:0] rxd_rmii;
  output        rx_er_rmii;
  output        crs_dv_rmii;

  output        amba_par_err_inj;

  // ASF comman output error indications
`ifdef edma_tx_pkt_buffer
  `ifdef gem_asf_ecc_sram
  input         asf_sram_corr_err;             // SRAM correctable error indication
  `endif
  `ifdef gem_asf_dap_prot
  input         asf_sram_uncorr_err;           // SRAM uncorrectable error indication
  `endif
`endif
  `ifdef gem_asf_integrity_prot
  input         asf_integrity_err;             // Integrity error indication
  `endif
  `ifdef gem_asf_dap_prot
  input         asf_dap_err;                   // Data and Address Paths error indication
  `endif
  `ifdef gem_asf_csr_prot
  input         asf_csr_err;                   // Configuration and Status Registers error indication
  `endif
  input         asf_trans_to_err;              // Transaction Timeouts indication
  input         asf_protocol_err;              // Protocol error indication
  // ASF and fatal and non-fatal interrupts
  input         asf_int_nonfatal;              // ASF non-fatal interrupt
  input         asf_int_fatal;                 // ASF fatal interrupt

  `ifdef gem_has_802p3_br
  // ASF comman output error indications for emac
`ifdef edma_tx_pkt_buffer
  `ifdef gem_asf_ecc_sram
  input         emac_asf_sram_corr_err;        // SRAM correctable error indication
  `endif
  `ifdef gem_asf_dap_prot
  input         emac_asf_sram_uncorr_err;      // SRAM uncorrectable error indication
  `endif
`endif
  `ifdef gem_asf_integrity_prot
  input         emac_asf_integrity_err;        // Integrity error indication
  `endif
  `ifdef gem_asf_dap_prot
  input         emac_asf_dap_err;              // Data and Address Paths error indication
  `endif
  `ifdef gem_asf_csr_prot
  input         emac_asf_csr_err;              // Configuration and Status Registers error indication
  `endif
  input         emac_asf_trans_to_err;         // Transaction Timeouts indication
  input         emac_asf_protocol_err;         // Protocol error indication
  // ASF and fatal and non-fatal interrupts for emac
  input         emac_asf_int_nonfatal;         // ASF non-fatal interrupt
  input         emac_asf_int_fatal;            // ASF fatal interrupt
  `endif


  // Double error injection to SRAM
  `ifdef edma_tx_pkt_buffer
  input          txsram_en;
  input          txsram_we;
  input   [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // RX DPSRAM port A...
                 txsram_dob;             //    write data bus.
  output    [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]       // RX DPSRAM port A...
                 txsram_dob_err_inj;       //    write data bus.
  `endif // edma_tx_pkt_buffer
  `ifdef edma_rx_pkt_buffer
  input          rxsram_en;
  input          rxsram_we;
  input   [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port A...
                 rxsram_dob;            //    write data bus.
  output    [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]       // RX DPSRAM port A...
                 rxsram_dob_err_inj;       //    write data bus.
  `endif // edma_rx_pkt_buffer

  // SRAM READ Addresses (for checking ECC fault location)
  input       [`edma_rx_pbuf_addr-1:0] rx_sram_read_add;
  input       [`edma_tx_pbuf_addr-1:0] tx_sram_read_add;

  input         ifss_dis_x_drv;
  output        fault_sim_for_dc_en;
  output        double_error_injection;
  output        single_error_injection;
  output [19:0] num_sram_errors_to_inject;
  output        test_ending;

// -----------------------------------------------------------------------------
//  Signal declarations
// -----------------------------------------------------------------------------

  // System interface (resets)
  reg           n_rmii_ref_reset;     // reset for rmii_ref_clk
  reg           n_txreset;            // tx_clk domain reset
  reg           n_gtxreset;           // gtx_clk domain reset
  reg           n_gtx20reset;
  reg           n_ntxreset;           // n_tx_clk domain reset
  reg           n_nrxreset;           // n_rx_clk domain reset
  reg           n_rxreset;            // rx_clk domain reset
  reg           n_rbc0reset;          // rbc0 domain reset
  reg           n_rbc1reset;          // rbc1 domain reset
  reg           n_clk_ctl_rst;        // reset to clock control block
  reg           n_prxreset;           // pma_rx_clk domain reset
  reg           n_pmarx20reset;

  // Ethernet signals
  wire          col;                  // collision detect signal from the PHY
  wire          crs;                  // carrier sense signal from the PHY
  wire          tx_clk_from_phy;      // transmit clock from the PHY
  wire          rx_er;                // receive error signal from the PHY
  wire          rx_clk_from_phy;      // receive clock from the PHY
  wire          rx_dv;                // receive data valid signal from the PHY
  wire          mdio_in;              // management data input
  reg           ext_interrupt_in;     // external interrupt input
  wire          ext_interrupt_int;    // external interrupt input
  wire          tx_pause;             // transmit pause frame. If toggled
                                      // causes a pause frame to be transmitted
  wire          tx_pause_zero;        // use zero quantum in tx pause frame
  wire          tx_pfc_sel;           // When set to 0, transmit 802.3
                                      // pause frame
                                      // When set to 1, transmit PFC
                                      // pause frame

  wire    [7:0] tx_pfc_pause;         // priority enable vector of the
                                      // PFC pause frame
  wire    [7:0] tx_pfc_pause_zero;    // When set to 1, PFC pause frame
                                      // has zero pause quantum
                                      // When set to 0, PFC pause frame
                                      // has the value of transmit pause
  wire          wol;                  // Wake-on-LAN output
  reg    [p_pcs_width-1:0]  rx_group_tb;   // TBI receive data from the PHY
  wire   [p_pcs_width-1:0]  rx_group_loop; // TBI receive data from the PHY
  wire   [p_pcs_width-1:0]  rx_group;      // TBI receive data from the PHY

  // APB interface signals
  wire          pclk_source;          // peripherical bus clock
  wire          n_preset;             // Amba reset
  reg    [12:0] paddr;                // address bus of selected master
  wire   [12:0] paddr_int;            // address bus of selected master
  wire   [12:0] paddr_ifss;           // address bus of selected master
  wire   [12:0] paddr_faultsim;       // address bus of selected master
  reg    [31:0] pwdata;               // write data
  reg     [3:0] pwdata_par;
  wire   [31:0] pwdata_int;           // write data
  wire    [3:0] pwdata_par_int;
  wire   [31:0] pwdata_ifss;          // write data
  wire    [3:0] pwdata_par_ifss;
  wire   [31:0] pwdata_faultsim;      // write data
  wire    [3:0] pwdata_par_faultsim;
  reg           pwrite;               // peripheral write strobe
  wire          pwrite_int;           // peripheral write strobe
  wire          pwrite_ifss;          // peripheral write strobe
  wire          pwrite_faultsim;      // peripheral write strobe
  reg           penable;              // peripheral enable
  wire          penable_int;          // peripheral enable
  wire          penable_ifss;         // peripheral enable
  wire          penable_faultsim;     // peripheral enable
  reg           psel;                 // peripheral select
  wire          psel_int;             // peripheral select
  wire          psel_ifss;            // peripheral select
  wire          psel_faultsim;        // peripheral select
  wire          perr;                 // peripheral address decoding error

  // AHB interface signals
  wire          hclk_source;          // AHB clock
  reg           n_hreset;             // AHB reset
  wire    [1:0] dma_bus_width;        // encoding for DMA bus width
  wire          hgrantdma;            // AHB ARBITER control grant
  wire          hready;               // AHB Slave ready
  wire    [1:0] hresp;                // AHB Slave response
                                      // (OK, error, retry or split)
  wire  [127:0] hrdata;               // AHB output data

  // FIFO interface signals
  reg   [127:0] tx_r_data;            // output data from the transmit fifo
  wire  [127:0] tx_r_data_int;        // output data from the transmit fifo
                                      // to the tx module.
  reg     [3:0] tx_r_mod;             // tx number of valid bytes in last
  wire    [3:0] tx_r_mod_int;         // tx number of valid bytes in last
  reg           tx_r_sop;             // start of packet indicator.
  reg           tx_r_eop;             // end of packet indicator.
  reg           tx_r_err;             // packet in error indicator.
  reg           tx_r_valid;           // new tx data available from fifo.
  wire [`edma_queues-1:0]  tx_r_data_rdy_int;
  reg  [`edma_queues-1:0]  tx_r_data_rdy; // indicates either a complete packet
                                      // is present in the fifo or a certain
                                      // threshold of data has been crossed,
                                      // the mac uses this input to trigger
                                      // a frame transfer.
  reg           tx_r_underflow;       // signals tx fifo underrun condition.
  reg           tx_r_flushed;         // tx fifo has been flushed.
  reg           tx_r_control;         // tx control from in-line FIFO word
  reg           dma_tx_status_tog;    // toggle acknowledge for tx_r_status

  `ifdef gem_fifo_8b_if
  wire  [7:0]   tx_r_data_loop;       // output data from the loopback fifo
  `else
  wire  [127:0] tx_r_data_loop;       // output data from the loopback fifo
  `endif
  wire    [3:0] tx_r_mod_loop;        // tx number of valid bytes in last (loopback)

  // Clocks
  wire          tsu_clk;              // TSU clock
  reg           n_tsureset;           // TSU clock reset
  reg           clk_2_5meg;           // 2.5 MHz clock
  reg           clk_10meg;            // 10 MHz clock
  reg           clk_25meg;            // 25 MHz clock
  reg           clk_25meg_shift;      // phase shift 25MHz for gate level sim
  reg           clk_33meg;            // 33 MHz clock
  reg           clk_50meg;            // 50 MHz clock
  reg           clk_62meg;            // 62.5 MHz clock
  reg           clk_66meg;            // 66 MHz clock
  reg           clk_100meg;           // 100 MHz clock
  reg           clk_125meg;           // 125 MHz clock
  reg           clk_156_25meg;        // 156.25 MHz clock
  reg           clk_15_625meg;        // 156.25 MHz clock
  reg           clk_312_5meg;         // 312.5 MHz clock
  reg           clk_200meg;           // 200 MHz clock
  reg           clk_250meg;           // 250 MHz clock
  reg           clk_500meg;           // 500 MHz clock
  reg           clk_1g25;             // 1.25 GHz clock
  reg           clk_5g;               // 5 GHz clock
  reg           clk_31_25meg;         // 31.25 MHz clock
  reg           pclk_spram;           // SPRAM Specific clock - various in frequency
  reg           aclk_spram;           // SPRAM Specific clock - various in frequency
  reg           gigabit_mclk;         // synchronise gigabit control to mac_clk
  reg           giga_change_blk_mclk; // prevent glitching mac_clk when switch
  wire          new_mclk_source;      // new mac_clk clock
  wire          mac_clk;              // clock used for TX and RX MAC
  reg           rbc0_from_phy;        // TBI receive clock from the PHY
  reg           rbc1_from_phy;        // TBI receive clock from the PHY
  reg           gigabit_pclk;         // synchronise gigabit control to PCLK
  reg           giga_change_blk_pclk; // prevent glitching of PCLK when switch
  wire          new_pclk_source;      // new PCLK clock
  reg           gigabit_hclk;         // synchronise gigabit control to HCLK
  reg           two_pt_five_gig_hclk; // synchronise control to HCLK
  reg           giga_change_blk_hclk; // prevent glitching of PCLK when switch
  reg           two_pt_five_change_blk_hclk; // prevent glitching of PCLK when switch
  wire          new_hclk_source;      // new HCLK clock

  reg           n_preset_control;     // Forces reset
  reg           reset_tb;             // reset for testbench
  wire          clk_tb;               // testbench clock used for main logic
  reg           tb_pcs_rx_clk;        // Recreated 125MHz clock for PCS tb.

  wire    [7:0] rxd_int;              // connection between external loopback
                                      // block and tb_rx block
  wire          rx_dv_int;            // connection between external loopback
                                      // block and tb_rx block

  wire          rx_done;              // transactor has finished all operations
  wire          pcs_rx_done;          // transactor has finished all operations
  wire          apb_done;             // transactor has finished all operations
  wire          mdio_done;            // transactor has finished all operations
  wire          tx_done;              // transactor has finished all operations
  wire          pcs_tx_done;          // transactor has finished all operations
  wire          dma_done;             // transactor has finished all operations
  wire          pins_done;            // transactor has finished all operations
  wire          filter_done;          // transactor has finished all operations
  wire          fifo_done;            // transactor has finished all operations
  reg           all_done;             // transactor has finished all operations

  wire          int_pulse;            // pulse when new interrupt seen
  wire          int_pulse_q1;         // pulse when new interrupt seen
  wire          int_pulse_q2;         // pulse when new interrupt seen
  wire          int_pulse_q3;         // pulse when new interrupt seen
  wire          int_pulse_q4;         // pulse when new interrupt seen
  wire          int_pulse_q5;         // pulse when new interrupt seen
  wire          int_pulse_q6;         // pulse when new interrupt seen
  wire          int_pulse_q7;         // pulse when new interrupt seen
  wire          int_pulse_q8;         // pulse when new interrupt seen
  wire          int_pulse_q9;         // pulse when new interrupt seen
  wire          int_pulse_q10;        // pulse when new interrupt seen
  wire          int_pulse_q11;        // pulse when new interrupt seen
  wire          int_pulse_q12;        // pulse when new interrupt seen
  wire          int_pulse_q13;        // pulse when new interrupt seen
  wire          int_pulse_q14;        // pulse when new interrupt seen
  wire          int_pulse_q15;        // pulse when new interrupt seen
  wire          int_pulse_emac;       // pulse when new interrupt seen
  wire          int_pulse_mmsl;       // pulse when new interrupt seen
  wire          int_pulse_asf_nonfatal;      // pulse when new interrupt seen
  wire          int_pulse_asf_fatal;         // pulse when new interrupt seen
  wire          int_pulse_emac_asf_nonfatal; // pulse when new interrupt seen
  wire          int_pulse_emac_asf_fatal;    // pulse when new interrupt seen
  wire          int_clock_pulse;      // pulse when new interrupt seen
  wire          int_clock_pulse_q1;   // pulse when new interrupt seen
  wire          int_clock_pulse_q2;   // pulse when new interrupt seen
  wire          int_clock_pulse_q3;   // pulse when new interrupt seen
  wire          int_clock_pulse_q4;   // pulse when new interrupt seen
  wire          int_clock_pulse_q5;   // pulse when new interrupt seen
  wire          int_clock_pulse_q6;   // pulse when new interrupt seen
  wire          int_clock_pulse_q7;   // pulse when new interrupt seen
  wire          int_clock_pulse_q8;   // pulse when new interrupt seen
  wire          int_clock_pulse_q9;   // pulse when new interrupt seen
  wire          int_clock_pulse_q10;  // pulse when new interrupt seen
  wire          int_clock_pulse_q11;  // pulse when new interrupt seen
  wire          int_clock_pulse_q12;  // pulse when new interrupt seen
  wire          int_clock_pulse_q13;  // pulse when new interrupt seen
  wire          int_clock_pulse_q14;  // pulse when new interrupt seen
  wire          int_clock_pulse_q15;  // pulse when new interrupt seen
  wire          int_clock_pulse_emac; // Single clock pulse when new interrupt seen
  wire          int_clock_pulse_mmsl; // Single clock pulse when new interrupt seen
  wire          int_clock_pulse_asf_nonfatal;      // Single clock pulse when new interrupt seen
  wire          int_clock_pulse_asf_fatal;         // Single clock pulse when new interrupt seen
  wire          int_clock_pulse_emac_asf_nonfatal; // Single clock pulse when new interrupt seen
  wire          int_clock_pulse_emac_asf_fatal;    // Single clock pulse when new interrupt seen
  wire          rx_trig;              // triggers transactor activity
  wire          pcs_rx_trig;          // triggers transactor activity
  wire          apb_trig;             // triggers transactor activity
  wire          pins_drive_trig;      // triggers transactor activity
  wire          pins_check_trig;      // triggers transactor activity
  wire          filter_drive_trig;    // triggers transactor activity
  wire          end_trig;             // forces end of test
  wire          apb_int_status_read;  // signals when an apb read is done
  wire          apb_int_q1_status_read; // signals when an apb read is done
  wire          apb_int_q2_status_read; // signals when an apb read is done
  wire          apb_int_q3_status_read; // signals when an apb read is done
  wire          apb_int_q4_status_read; // signals when an apb read is done
  wire          apb_int_q5_status_read; // signals when an apb read is done
  wire          apb_int_q6_status_read; // signals when an apb read is done
  wire          apb_int_q7_status_read; // signals when an apb read is done
  wire          apb_int_q8_status_read; // signals when an apb read is done
  wire          apb_int_q9_status_read; // signals when an apb read is done
  wire          apb_int_q10_status_read; // signals when an apb read is done
  wire          apb_int_q11_status_read; // signals when an apb read is done
  wire          apb_int_q12_status_read; // signals when an apb read is done
  wire          apb_int_q13_status_read; // signals when an apb read is done
  wire          apb_int_q14_status_read; // signals when an apb read is done
  wire          apb_int_q15_status_read; // signals when an apb read is done
  wire          apb_emac_int_status_read; // signals when an apb read is done
  wire          apb_mmsl_int_status_read; // signals when an apb read is done
  wire          apb_asf_int_nonfatal_status_read;      // signals when an apb read is done
  wire          apb_asf_int_fatal_status_read;         // signals when an apb read is done
  wire          apb_emac_asf_int_nonfatal_status_read; // signals when an apb read is done
  wire          apb_emac_asf_int_fatal_status_read;    // signals when an apb read is done

  wire          trig_from_apb;        // triggers transactor activity

  wire   [23:0] count;                // count of test bench clock cycles

  wire   [7:0]  tb_rx_bit_slip;       // RX bit slip control

  wire          apb_fail;             // asserted at time of failure
  wire          tx_fail;              // asserted at time of failure
  wire          pcs_tx_fail;          // asserted at time of failure
  wire          mdio_fail;            // asserted at time of failure
  wire          dma_fail;             // asserted at time of failure
  wire          pins_fail;            // asserted at time of failure
  wire          filter_fail;          // asserted at time of failure
  wire          fifo_fail;            // asserted at time of failure
  wire          xgmii2gmii_fail;      // asserted at time of failure

  reg           apb_fail_lat;         // latched failure condition
  reg           tx_fail_lat;          // latched failure condition
  reg           pcs_tx_fail_lat;      // latched failure condition
  reg           mdio_fail_lat;        // latched failure condition
  reg           dma_fail_lat;         // latched failure condition
  reg           pins_fail_lat;        // latched failure condition
  reg           filter_fail_lat;      // latched failure condition
  reg           fifo_fail_lat;        // latched failure condition
  reg           wr_tog_fail_lat;      // latched failure condition
  reg           xgmii2gmii_fail_lat;  // latched failure condition
  wire          fail;                 // Any of the latched fails high

  wire          rx_in_progress;       // flags reception in progress -
                                      // corresponds to synch_trig
  wire          idle_1_received;      // gem_gxl received EPD followed by I1
  wire          trig_from_pcs_rx;     // 1 cycle pulse enforced by pcs rx tb
  wire          trig_from_pcs_tx;     // 1 cycle pulse enforced by pcs tx tb

  reg    [31:0] results_file;         // file where results summary is written

  wire          drive_reset;          // forces reset from tb_pins
  wire          drive_crs;            // controls crs from tb_pins
  wire          tx_en_crs;            // enables driving of crs during tx,
                                      // from tb_pins
  reg           tx_en_next;           // used to generate crs during
                                      // carrier extension
  wire          carrier_ext;          // used to generate crs during
                                      // carrier extension

  reg   [399:0] test_case_var_reg[0:4];// array for reading files/tb_init.data
  reg   [399:0] test_case_name;       // ascii value of test case name
  reg   [399:0] date;                 // ascii value of date (ie string)
  reg   [399:0] test_case_var;        // used for general purpose config
  integer       seed;                 // Random seed
  integer       void_value;           // used for initial urandom function call
  reg  [1279:0] results_file_name;    // Stores the full path to the results file
  reg  [1279:0] power_file_name;      // Stores the full path to the results file
  integer       last_char_position;   // Points to the position of the last char in the file name
  reg           stop;                 // controls whether the tb executes
                                      // $stop or $finish at end of test
  reg           ten_meg_bit;          // selects 10Mbit clocking for the
                                      // ethernet MAC
  reg           check_txlinerate;     //
  reg           fifo_loopback_mode;   //
  reg  [3:0]    sel_ahb_freq;         //
  reg  [7:0] descr_min;               //
  reg  [7:0] descr_max;               //
  reg  [7:0] data_min;                //
  reg  [7:0] data_max;                //
  reg  [7:0] data_min_lock;           //
  reg  [7:0] data_max_lock;           //
  reg  [3:0] ten_gig_mode;            //
  reg        axi_perf_test;           //
  reg        incompatible_test;
  reg [15:0] fault_sim;               //
  reg        fault_sim_for_dc_en;     //
  reg        auto_fault_checker;      //
  reg        disable_txd_checking;    //
  reg        double_error_injection;  //
  reg        single_error_injection;
  reg [19:0] num_sram_errors_to_inject;
  wire       tx_all_errs_injected,rx_all_errs_injected;
  reg  [7:0] read_min;
  reg  [7:0] read_max;
  reg  [7:0] write_min;
  reg  [7:0] write_max;
  reg        randomize_hgrant;        // Randomizes hgrants
  reg        randomize_hready;        // Randomizes hready
  reg        fixed_latency_mode;      // Randomizes hready
  reg    [3:0]  amba_ready_delay;     // indicates the number of clocks hready
                                      // or bwait should be delayed
  reg    [3:0]  bus_grant_delay;      // indicates the number of clocks hgrant
                                      // or agnt should be delayed
  reg    [3:0]  fifo_latency;         // indicates the number of clocks
                                      // tx_r_valid should be delayed from
                                      // tx_r_rd by tb_fifo
  reg    [3:0]  fifo_under_delay;     // indicates the number of clocks
                                      // tx_r_undeflow should be delayed from
                                      // tx_r_rd by tb_fifo
  reg    [3:0]  fifo_status_delay;    // indicates the number of clocks * 10
                                      // dma_tx_status_tog should be delayed
                                      // from dma_tx_end_tog by tb_fifo
  reg    [3:0]  fifo_over_delay;      // indicates the number of clocks
                                      // rx_w_overflow should be delayed from
                                      // rx_w_wr by tb_fifo
  wire          external_fifo_if;     // indicates whether DMA or EXT FIFO IF
                                      // is active.
  wire          mii_select;           // not used (only used by rmiig)

  wire   [9:0]  tx_group_int;         // TBI transmit data to the PHY
  wire   [9:0]  rx_group_int;         // TBI receive data from the PHY
  wire   [9:0]  rx_group_slip;        // With bit slip applied
  wire          keep_idle_i1;         // Force use I1
  wire          tb_mode_2_5g;         // Setup to 2.5G mode.
  wire          amba_par_err_inj;     // Force parity error in amba host data (rdata for now)
  wire   [19:0] rx_group_20;          // After 10 to 20-bit conversion
  reg           tb_start;             // Initial delay for starting testbench, legacy to maintain timing
  wire          force_rx_er;          // force rx_er high
  wire          rx_er_int;            // rx_er internal
  wire          force_back_pressure;  // force external back pressure

  reg tx_linerate_fail,tx_linerate_warn,first_txd_started;
  reg [4:0] tx_linerate_cnt;

  integer spram_amba_period;          // AHB or AXI period for SPRAM testing
  integer spram_pclk_period;          // pclk period for SPRAM testing
  reg     cg_spram_system_sample;     // SPRAM Covergroup Sample
  integer spram_divisor;              // SPRAM Period Divisor
  wire  [127:0] apb_qos_for_axi;

  wire          crs_tb;
  wire    [1:0] rxd_rmii;
  wire    [1:0] txd_rmii;
  wire    [3:0] txd_rmii_tb;
  wire    [7:0] rxd_tb;
  wire          crs_rmii_tb;
  wire          rx_dv_tb;
  wire          rx_er_tb;
  wire          tx_en_tb;
 `ifdef xgm
  wire   [31:0] txd_tb;
 `else
  wire    [7:0] txd_tb;
 `endif
  wire          fail_ifss;

  // Some signals to support optional SerDes interop simulation
  wire          phy_ready;
  reg           tb_use_phy_model;

  // Link Fault Signaling (802.3bz/802.3cb)
  wire    [1:0] link_fault;           // The Fault Status indicator
  wire          link_fault_sig_en;    // Indicates LFSM enable

// -----------------------------------------------------------------------------
//  Beginning of main code
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
//  Initialise the testbench
// -----------------------------------------------------------------------------


  // Residual code from having serdes model built in this testbench
  // Needed to maintain timing of start of test
  initial
  begin
    tb_start        = 1'b0;
    #50060 tb_start = 1'b1;
  end

  // start testing off
  initial
    begin

      //`ifdef noshm
      //`else // if not noshm
      //$shm_open("tb_gem_gxl.shm");
      //$shm_probe(tb_gem,"AC");
      //`endif // noshm

      $readmemh("./files/tb_init.data",test_case_var_reg);
      // Set the seed for random number generation
      seed             = test_case_var_reg[0][31:0];
      test_case_name   = test_case_var_reg[1];
      date             = test_case_var_reg[2];
      test_case_var    = test_case_var_reg[3];
      stop             = test_case_var[0];
      ten_meg_bit      = test_case_var[4];
      sel_ahb_freq     = test_case_var[8:5];
      amba_ready_delay = {test_case_var[15],test_case_var[14],
                          test_case_var[13],test_case_var[12]};
      bus_grant_delay  = {test_case_var[19],test_case_var[18],
                          test_case_var[17],test_case_var[16]};
      fifo_latency     = {test_case_var[23],test_case_var[22],
                          test_case_var[21],test_case_var[20]};
      fifo_under_delay = {test_case_var[27],test_case_var[26],
                          test_case_var[25],test_case_var[24]};
      fifo_status_delay= {test_case_var[31],test_case_var[30],
                          test_case_var[29],test_case_var[28]};
      fifo_over_delay  = {test_case_var[35],test_case_var[34],
                          test_case_var[33],test_case_var[32]};
      randomize_hgrant = test_case_var[36];
      randomize_hready = test_case_var[37];
      check_txlinerate = test_case_var[38];
      fifo_loopback_mode = test_case_var[88];
      read_min  = test_case_var[171:164];
      read_max  = test_case_var[163:156];
      write_min = test_case_var[155:148];
      write_max = test_case_var[147:140];
      descr_min = test_case_var[139:132];
      descr_max = test_case_var[131:124];
      data_min  = test_case_var[123:116];
      data_max  = test_case_var[115:108];
      data_min_lock  = test_case_var[107:100];
      data_max_lock  = test_case_var[99:92];
      ten_gig_mode   = test_case_var[175:172];
      fixed_latency_mode = test_case_var[176];
      axi_perf_test   = test_case_var[180];
      auto_fault_checker   = test_case_var[184];
      disable_txd_checking   = !test_case_var[188];
      double_error_injection = test_case_var[192];
      single_error_injection = test_case_var[196];
      num_sram_errors_to_inject = test_case_var[219:200];
      fault_sim_for_dc_en   = test_case_var[220];
      fault_sim             = test_case_var[239:224];
      incompatible_test     = test_case_var[240];
      tb_use_phy_model      = test_case_var[244];

      // Bit messy this. In the latest version of incisive string handling is different
      // and we need to merge the strings (directory and test name) cleanly. We therefore
      // have to figure out where the last character is in the test name and then merge
      // the "results" directory after the test name.
      results_file_name = {1280{1'b0}};
      power_file_name   = {1280{1'b0}};
      results_file_name = test_case_name;
      // Find last character in test name
      last_char_position = 0;
      while (results_file_name[7:0] != 8'd0 && last_char_position<800) begin
         results_file_name = results_file_name >> 8;
         last_char_position = last_char_position + 8;
      end
      // Merge the directory with the test name.
      results_file_name = "./results/" << last_char_position+32; // Need to add 32 for ".res"
      power_file_name   = "./power/gem_gxl." << last_char_position+32; // Need to add 32 for ".tcf"
      results_file_name = results_file_name | {test_case_name,".res"};
      power_file_name = power_file_name | {test_case_name,".tcf"};

      results_file     = $fopen(results_file_name);
      $display("\n Running test case :- %s\n\n",test_case_name);
      // to use fast clock option execute: ../runscripts/compile.pl -define fast_clocks
      `ifdef fast_clocks
          $display("\n Selected 250MHz PCLK and HCLK (i.e. define fast_clocks)\n");
      `endif // fast_clocks
      n_preset_control = 1'b0;
      n_hreset         = 1'b0;
      n_tsureset       = 1'b0;
      reset_tb         = 1'b0;
      n_clk_ctl_rst    = 1'b0;

      #10060 n_clk_ctl_rst    = 1'b1;

      @(posedge tb_start);
      reset_tb         = 1'b1;
    end

always @(posedge tb_start)
begin
  // The extra toggle on reset isn't necessary, and has been added
  // to improve code coverage only.
  fork begin
    #1000;
    @(negedge pclk_source) n_preset_control = 1'b1;
    @(negedge pclk_source) n_preset_control = 1'b0;
  end
  begin
    #5000;
  end
  join
  @(negedge pclk_source) n_preset_control = 1'b1;
end

always @(posedge tb_start)
begin
  // The extra toggle on reset isn't necessary, and has been added
  // to improve code coverage only.
  fork begin
    #1000;
    @(negedge hclk_source) n_hreset = 1'b1;
    @(negedge hclk_source) n_hreset = 1'b0;
  end
  begin
    #5000;
  end
  join
  @(negedge hclk_source) n_hreset = 1'b1;
end

always @(posedge tb_start)
begin
  #5000
  n_tsureset = 1'b1;
end


// ref clock reset for RMII
initial
begin
   n_rmii_ref_reset  = 1'b0;
   #5000 n_rmii_ref_reset = 1'b1;
end


// -----------------------------------------------------------------------------
//  Testbench configuration reporting to simulation logfile
// -----------------------------------------------------------------------------

  // indicate which interface is being used for ethernet datapath.
  `ifdef gem_ext_fifo_interface
     assign external_fifo_if = 1'b1;
  `else // configured for AMBA DMA operation.
     assign external_fifo_if = 1'b0;
  `endif // gem_ext_fifo_interface

  // report whether external fifo interface or amba dma is being used.
  always @(external_fifo_if)
    if (external_fifo_if)
     begin
      $display(" Design configured for External Fifo Interface\n");
      $display(" TX FIFO configured for %d cycles delay from read to data valid\n",fifo_latency);
      $display(" TX FIFO configured for %d cycles delay from read to underflow\n",fifo_under_delay);
      $display(" TX FIFO configured for %d cycles delay on status update\n",(fifo_status_delay * 10));
      $display(" RX FIFO configured for %d cycles delay from write to overflow\n",(fifo_over_delay));
     end
    else
     begin
      $display(" Design configured for DMA operation (AMBA AHB)\n");
      $display(" AMBA bus configured for %d wait states\n",amba_ready_delay);
      $display(" AMBA bus configured for %d cycles delay in granting the AMBA bus\n\n\n",bus_grant_delay);
      end

  // report whether 10Mbit/s or 100Mbit/s operation
  always @(ten_meg_bit)
    if (ten_meg_bit)
      $display(" Testbench configured for 10Mbit/s operation (2.5MHz rx_clk and tx_clk; 50 Mhz pclk and hclk)\n");
    else
      $display(" Testbench configured for 100Mbit/s operation (25MHz rx_clk, tx_clk, pclk and hclk)\n");

  `ifdef xgm
  always @(ten_gig_mode)
    if (ten_gig_mode[0])
      $display(" Testbench configured for 10Gbit/s operation (using XGM MAC - 156.25MHz rx_clk and tx_clk)\n");
    else if (ten_gig_mode[1])
      $display(" Testbench configured for 40Gbit/s operation (using XGM MAC - 625MHz rx_clk and tx_clk)\n");
    else
      $display(" Testbench configured for 1Gbit/s operation (using XGM MAC - 15.625MHz rx_clk, tx_clk)\n");
  `else
  always @(ten_meg_bit)
    if (ten_meg_bit)
      $display(" Testbench configured for 10Mbit/s operation (2.5MHz rx_clk and tx_clk; 50 Mhz pclk and hclk)\n");
    else
      $display(" Testbench configured for 100Mbit/s operation (25MHz rx_clk, tx_clk, pclk and hclk)\n");
  `endif

  // report whether gigabit operation
  always @(gigabit)
    if (gigabit)
      $display(" Testbench configured for gigabit operation (125MHz tx_clk / rx_clk)\n");
    else
      $display(" Testbench configured for nibble operation, 10/100 mode\n");

  // report whether full or half duplex operation
  always @(half_duplex)
    if (half_duplex)
      $display(" Testbench configured for HALF duplex operation\n");
    else
      $display(" Testbench configured for FULL duplex operation\n");

  // report amba bus width.
  always @(dma_bus_width)
    if (dma_bus_width == 2'b00)
      $display(" bus configured for 32-bit operation\n");
    else if (dma_bus_width == 2'b01)
      $display(" bus configured for 64-bit operation\n");
    else
      $display(" bus configured for 128-bit operation\n");



// -----------------------------------------------------------------------------
//  Generate some standard speed clocks
// -----------------------------------------------------------------------------

  // generate  2.5MHz clock
  initial
    begin
      clk_2_5meg = 1'b0;
      forever
        begin
          #2000 clk_2_5meg = 1'b1;
          #2000 clk_2_5meg = 1'b0;
        end
    end

  // generate 10MHz clock
  initial
    begin
      clk_10meg = 1'b0;
      forever
        begin
          #500 clk_10meg = 1'b1;
          #500 clk_10meg = 1'b0;
        end
    end

  // generate  25MHz clock
  initial
    begin
      clk_25meg = 1'b0;
      forever
        begin
          #200 clk_25meg = 1'b1;
          #200 clk_25meg = 1'b0;
        end
    end

  // generate  25MHz clock for gate-level sim
  initial
    begin
      clk_25meg_shift = 1'b0;
      #90
      forever
        begin
          #200 clk_25meg_shift = 1'b1;
          #200 clk_25meg_shift = 1'b0;
        end
    end

  // generate  33.33MHz clock
  initial
    begin
      clk_33meg = 1'b0;
      forever
        begin
          #150 clk_33meg = 1'b1;
          #150 clk_33meg = 1'b0;
        end
    end

  // generate 50MHz clock
  initial
    begin
      clk_50meg = 1'b0;
      forever
        begin
          #100 clk_50meg = 1'b1;
          #100 clk_50meg = 1'b0;
        end
    end

  // generate 62.5MHz clock (note phase!)
  initial
    begin
          clk_62meg = 1'b0;
      #40 clk_62meg = 1'b1;
      forever
        begin
          #80 clk_62meg = 1'b0;
          #80 clk_62meg = 1'b1;
        end
    end

  // generate  66.67MHz clock
  initial
    begin
      clk_66meg = 1'b0;
      forever
        begin
          #75 clk_66meg = 1'b1;
          #75 clk_66meg = 1'b0;
        end
    end

  // generate 100MHz clock
  initial
    begin
      clk_100meg = 1'b0;
      forever
        begin
          #50 clk_100meg = 1'b1;
          #50 clk_100meg = 1'b0;
        end
    end

  // generate 125MHz clock
  initial
    begin
      clk_125meg = 1'b0;
      forever
        begin
          #40 clk_125meg = 1'b1;
          #40 clk_125meg = 1'b0;
        end
    end

  // generate 312.5MHz clock
  initial
    begin
      clk_312_5meg = 1'b0;
      forever
        begin
          #16 clk_312_5meg = 1'b1;
          #16 clk_312_5meg = 1'b0;
        end
    end

  // generate 156.25MHz clock   (50:50 ratio)
  initial
    begin
      clk_156_25meg = 1'b0;
      forever
        begin
          #32 clk_156_25meg = 1'b1;
          #32 clk_156_25meg = 1'b0;
        end
    end

  // generate 15.625MHz clock   (50:50 ratio)
  initial
    begin
      clk_15_625meg = 1'b0;
      forever
        begin
          #320 clk_15_625meg = 1'b1;
          #320 clk_15_625meg = 1'b0;
        end
    end

  // generate 200MHz clock
  initial
    begin
      clk_200meg = 1'b0;
      forever
        begin
          #25 clk_200meg = 1'b1;
          #25 clk_200meg = 1'b0;
        end
    end

  // generate 250MHz clock
  initial
    begin
      clk_250meg = 1'b0;
      forever
        begin
          #20 clk_250meg = 1'b1;
          #20 clk_250meg = 1'b0;
        end
    end

  // generate 500MHz clock
  initial
    begin
      clk_500meg = 1'b0;
      forever
        begin
          #10 clk_500meg = 1'b1;
          #10 clk_500meg = 1'b0;
        end
    end

  // generate 31.25MHz clock
  initial
    begin
      clk_31_25meg = 1'b0;
      forever
        begin
          #160 clk_31_25meg = 1'b1;
          #160 clk_31_25meg = 1'b0;
        end
    end

  // generate 1.25GHz clock
  initial
    begin
      clk_1g25 = 1'b0;
      forever
        begin
          #4 clk_1g25 = 1'b1;
          #4 clk_1g25 = 1'b0;
        end
    end

  // generate 5GHz clock
  initial
    begin
      clk_5g = 1'b0;
      forever
        begin
          #1 clk_5g = 1'b1;
          #1 clk_5g = 1'b0;
        end
    end

   // generate the axi/ahb spram clock
   initial
      begin
         aclk_spram = 1'b0;
         #1;
         forever
         begin
            #(spram_amba_period/2) aclk_spram = 1'b1;
            #(spram_amba_period/2) aclk_spram = 1'b0;
         end
      end

   // generate the axi/ahb spram clock
   initial
      begin
         pclk_spram = 1'b0;
         #1;
         forever
         begin
            #(spram_pclk_period/2) pclk_spram = 1'b1;
            #(spram_pclk_period/2) pclk_spram = 1'b0;
         end
      end


// -----------------------------------------------------------------------------
//  assign generated clocks to MAC clocks used in the design
// -----------------------------------------------------------------------------
reg two_pt_five_gig_mclk;
  initial
  begin
    gigabit_mclk  = 1'b0;
    two_pt_five_gig_mclk  = 1'b0;
    giga_change_blk_mclk  = 1'b0;
  end

  // Detect change in gigabit mode control and block further mac_clk changes
  // until sure we are not going to get a glitch
  // Use resynchronised version of gigabit signal (gigabit_pclk)
  always @(gigabit_pclk or tb_mode_2_5g or two_pt_five_gig)
     begin
        @(negedge mac_clk)
           giga_change_blk_mclk = 1'b1;
           gigabit_mclk = gigabit_pclk;
           two_pt_five_gig_mclk = (tb_mode_2_5g === 1'b1) || (two_pt_five_gig === 1'b1);
        @(negedge new_mclk_source)
           giga_change_blk_mclk = 1'b0;
     end

  // new mac_clk
  `ifdef xgm
  assign gmii_clk    = (ten_gig_mode[0])     ? clk_1g25 :       // 10G Operation
                       (ten_gig_mode[1])     ? clk_5g :         // 40G Operation
                                               clk_125meg;      // 1000Mbs
  reg [2:0] gmii_clk_cnt;
  initial gmii_clk_cnt = 0;
  always @(posedge gmii_clk)
  begin
    gmii_clk_cnt <= gmii_clk_cnt+1;
  end
  assign new_mclk_source = gmii_clk_cnt[2];  // Divide by 8
  `else
  assign new_mclk_source = (two_pt_five_gig_mclk) ? clk_312_5meg :   // 2500Mb/s
                           (gigabit_mclk) ? clk_125meg :     // 1000Mb/s
                           (ten_meg_bit)  ? clk_2_5meg :     // 10Mb/s
                                            clk_25meg_shift; // 100Mb/s
  `endif
  // drive ethernet MAC clocks
  // 10Mbs   2.5MHz
  // 100Mbs  25MHz
  // 1000Mbs 125MHz
  // Block whilst changing to prevent glitches
  wire  gtx_ref_clk_tb;
  assign mac_clk   = (giga_change_blk_mclk)? 1'b0 : new_mclk_source;
  assign tx_clk_from_phy  = mac_clk;
  assign rx_clk_from_phy  = mac_clk;
  assign gtx_ref_clk_tb = (two_pt_five_gig_mclk) ? clk_312_5meg & ~giga_change_blk_mclk
                                                 : clk_125meg; // always 125 MHz

  reg gtx20_ref_clk_tb;
  // Generate optional gtx20_ref_clk which is used for 20-bit PCS interface
  always@(posedge gtx_ref_clk or negedge reset_tb)
  begin
    if (~reset_tb)
      gtx20_ref_clk_tb <= 1'b0;
    else
      gtx20_ref_clk_tb <= ~gtx20_ref_clk_tb;
  end

  // drive PCS receive clocks
  // divide by 2 of gtx_ref_clk. This is 125 MHz, giving two
  // clock phases at 62.5MHz.
  always @(negedge gtx_ref_clk or negedge reset_tb)
     if (~reset_tb)
        begin
           rbc0_from_phy <= 1'b0;
           rbc1_from_phy <= 1'b0;
        end
     else
        begin
           rbc0_from_phy <= ~rbc0_from_phy;
           rbc1_from_phy <= rbc0_from_phy;
        end

  // If using 10-bit SerDes interface to GEM, then drive pma_rx_clk which
  // can then be connected to the pcs_rx_clk of GEM.
  // Note that this is driven by gtx_ref_clk as that is the source clock for the
  // PCS RX transactor as TX and RX clocks are synchronous in this environment.
  // Note that if using the PHY model, 10-bit mode is not supported!
  assign pma_rx_clk = tb_use_phy_model  ? gtx_ref_clk  : gtx_ref_clk;

  reg pma_rx20_clk_tb;
  // Divide pma_rx_clk by 2 to generate clock for 20-bit interface
  always@(posedge pma_rx_clk or negedge reset_tb)
  begin
    if (~reset_tb)
      pma_rx20_clk_tb  <= 1'b0;
    else
      pma_rx20_clk_tb  <= ~pma_rx20_clk_tb;
  end

// -----------------------------------------------------------------------------
//  assign generated clocks to AMBA clocks used in the design
// -----------------------------------------------------------------------------

  initial
  begin
    giga_change_blk_pclk  = 1'b0;
    gigabit_pclk          = 1'b0;
  end

  // Detect change in gigabit mode control and block further PCLK changes until
  // sure we are not going to get a glitch
  always @(gigabit)
     begin
        @(negedge pclk_source)
           giga_change_blk_pclk = 1'b1;
           gigabit_pclk <= gigabit;
        @(negedge new_pclk_source)
           giga_change_blk_pclk = 1'b0;
     end

  // new PCLK
  // to use fast clock option execute: ../runscripts/compile.pl -define fast_clocks
  assign new_pclk_source = sel_ahb_freq == 4'd7 ? pclk_spram :
                           sel_ahb_freq == 4'd6 ? pclk_spram :
                           sel_ahb_freq == 4'd5 ? pclk_spram :
  `ifdef xgm
                           sel_ahb_freq == 4'd4 ? clk_250meg :
  `else
                           sel_ahb_freq == 4'd4 ? clk_100meg :
  `endif
                           sel_ahb_freq == 4'd3 ? clk_100meg :
                           sel_ahb_freq == 4'd2 ? clk_100meg :
                           sel_ahb_freq == 4'd1 ? clk_50meg :

                            (gigabit_pclk)? clk_62meg :      // 1000Mbs
                         `ifdef fast_clocks
                            (ten_meg_bit)? clk_250meg :      // 10Mbs
                         `else
                            (ten_meg_bit)? clk_50meg :       // 10Mbs
                         `endif // fast_clocks
                                           clk_25meg;        // 100Mbs

  // Drive AMBA APB clock
  // 10Mbs   50MHz
  // 100Mbs  25MHz
  // 1000Mbs 62.5MHz
  // Block whilst changing to prevent glitches
  assign pclk_source = (giga_change_blk_pclk)? 1'b0 : new_pclk_source;


  initial
  begin
    giga_change_blk_hclk  = 1'b0;
    gigabit_hclk          = 1'b0;
  end

  // Detect change in gigabit mode control and block further HCLK changes until
  // sure we are not going to get a glitch
  // Use resynchronised version of gigabit signal (gigabit_pclk)
  always @(gigabit_pclk)
     begin
        @(negedge hclk_source)
           giga_change_blk_hclk = 1'b1;
           gigabit_hclk <= gigabit_pclk;
        @(negedge new_hclk_source)
           giga_change_blk_hclk = 1'b0;
     end

  initial
     begin
        two_pt_five_change_blk_hclk = 1'b0;
        two_pt_five_gig_hclk = 1'b0;
     end


  always @(two_pt_five_gig)
     begin
        @(negedge hclk_source)
           two_pt_five_change_blk_hclk = 1'b1;
           two_pt_five_gig_hclk = two_pt_five_gig;
        @(negedge new_hclk_source)
           two_pt_five_change_blk_hclk = 1'b0;
     end

  // new HCLK
  assign new_hclk_source = sel_ahb_freq == 4'd8 ? clk_2_5meg :
                           sel_ahb_freq == 4'd7 ? aclk_spram :
                           sel_ahb_freq == 4'd6 ? aclk_spram :
                           sel_ahb_freq == 4'd5 ? aclk_spram :
                           sel_ahb_freq == 4'd4 ? clk_500meg :
                           sel_ahb_freq == 4'd3 ? clk_250meg :
                           sel_ahb_freq == 4'd2 ? clk_100meg :
                           sel_ahb_freq == 4'd1 ? clk_50meg :

                            (two_pt_five_gig_hclk)? clk_250meg :   // 2500Mbs
                            (gigabit_hclk)? clk_100meg :     // 1000Mbs
                         `ifdef fast_clocks
                            (ten_meg_bit)? clk_250meg :      // 10Mbs
                         `else
                            (ten_meg_bit)? clk_50meg :       // 10Mbs
                         `endif // fast_clocks
                          `ifdef xgm
                                           clk_200meg;
                          `else
                                           clk_25meg;        // 100Mbs
                          `endif

  // Drive AMBA AHB clock
  // 10Mbs   50MHz
  // 100Mbs  25MHz
  // 1000Mbs 31.25MHz
  // Block whilst changing to prevent glitches
  assign hclk_source = (giga_change_blk_hclk | two_pt_five_change_blk_hclk)? 1'b0 : new_hclk_source;



// -----------------------------------------------------------------------------
//  assign generated clocks to loopback clock used in design
// -----------------------------------------------------------------------------

  // drive loopback clock at 50MHz
`ifdef TB_POWER
  assign loop_clk_source = clk_125meg;
`else // if not TB_POWER
  assign loop_clk_source  = clk_50meg;
`endif // TB_POWER

  assign rmii_ref_clk = clk_50meg;

// -----------------------------------------------------------------------------
//  assign generated clocks to TSU clock used in design
// -----------------------------------------------------------------------------

  // drive TSU clock at 10MHz
  // for XGM, It needs to be faster than tx_clk.
  `ifdef xgm
  assign tsu_clk = clk_200meg;
  `else
  assign tsu_clk = clk_10meg;
  `endif

// -----------------------------------------------------------------------------
//  assign generated clocks to testbench clocks
// -----------------------------------------------------------------------------

  // main testbench runs at 50MHz
  assign clk_tb    = clk_50meg;

  // create clock for PCS RX testbench.
  // Uses clock fed out of GEM (which will be the 62.5MHz RBC0 clock in
  // PCS mode) to create a 125 MHz clock with delay relative
  // to clock fed out of GEM (which will be the 62.5MHz RBC0 clock in PCS mode).
  always @(negedge reset_tb or posedge rx_clk_to_gem or
           negedge rx_clk_to_gem)
     if (~reset_tb)
        tb_pcs_rx_clk <= 1'b0;
     else
        begin
               tb_pcs_rx_clk <= 1'b1;
           #40 tb_pcs_rx_clk <= 1'b0;
        end


// -----------------------------------------------------------------------------
//  Generate resets for the design
// -----------------------------------------------------------------------------

  // drive n_preset under control of drive pins block or test bench
  // initial statement
  assign n_preset = drive_reset & n_preset_control;

  initial
  begin
    n_rbc0reset = 1'b0;
    n_rbc1reset = 1'b0;
  end

  // synchronise rbc0 reset to correct domains
  always@(negedge rbc0_from_phy or negedge n_preset)
     if (~n_preset)
//`ifdef rtl
//        n_rbc0reset <= 1'b0;
//`else
        #10 n_rbc0reset <= 1'b0;
//`endif
     else
        n_rbc0reset <= 1'b1;

  // synchronise rbc1 reset to correct domains
  always@(negedge rbc1_from_phy or negedge n_preset)
     if (~n_preset)
        n_rbc1reset <= 1'b0;
     else
        n_rbc1reset <= 1'b1;

  // synchronise tx_clk reset to correct domains
  always@(negedge tx_clk_to_gem or negedge n_preset)
     if (~n_preset)
        n_txreset <= 1'b0;
     else
        n_txreset <= 1'b1;

  // synchronise tx_clk reset to correct domains
  always@(negedge gtx_ref_clk or negedge n_preset)
     if (~n_preset)
        n_gtxreset <= 1'b0;
     else
        n_gtxreset <= 1'b1;

  // synchronise tx_clk reset to correct domains
  always@(negedge gtx20_ref_clk or negedge n_preset)
     if (~n_preset)
        n_gtx20reset <= 1'b0;
     else
        n_gtx20reset <= 1'b1;

  // synchronise n_tx_clk reset to correct domains
  always@(negedge n_tx_clk_to_gem or negedge n_preset)
     if (~n_preset)
        n_ntxreset <= 1'b0;
     else
        n_ntxreset <= 1'b1;

  // synchronise n_rx_clk reset to correct domains
  always@(negedge n_rx_clk_to_gem or negedge n_preset)
     if (~n_preset)
        n_nrxreset <= 1'b0;
     else
        n_nrxreset <= 1'b1;

  // synchronise rx_clk reset to correct domains
  always@(negedge rx_clk_to_gem or negedge n_preset)
     if (~n_preset)
        n_rxreset <= 1'b0;
     else
        n_rxreset <= 1'b1;

  // synchronise rx_clk reset to correct domains
  always@(negedge pma_rx_clk or negedge n_preset)
     if (~n_preset)
        n_prxreset <= 1'b0;
     else
        n_prxreset <= 1'b1;

  // Synchronise to pma_rx20_clk
  always@(negedge pma_rx20_clk or negedge n_preset)
     if (~n_preset)
        n_pmarx20reset <= 1'b0;
     else
        n_pmarx20reset <= 1'b1;


// -----------------------------------------------------------------------------
//  Generate resets for the design
// -----------------------------------------------------------------------------

   // tx_en_next is a registered version of tx_en and used for crs generation
   // during carrier extension.
   always@(posedge tx_clk_to_gem or negedge n_txreset)
   begin
      if(~n_txreset)
         tx_en_next <= 1'b0;
      else
         tx_en_next <= tx_en;
  end

  // generate carrier_ext signal for crs assertion during carrier extension.
  assign carrier_ext = ((tx_er & tx_en_next & gigabit & half_duplex) |
                                             (carrier_ext & tx_er & ~tx_en));

  // drive crs during transmit or under control of drive pins block
  assign crs_tb = ((tx_en | carrier_ext) & tx_en_crs) | drive_crs;

  assign crs_rmii_tb = (rx_dv | drive_crs) | ~tx_en_crs;


// -----------------------------------------------------------------------------
//  Delay ext_interrupt_int
// -----------------------------------------------------------------------------

  // delay ext_interrupt_int
  always @(*)
  begin
    if (tb_use_phy_model)
      ext_interrupt_in  = phy_ready & ext_interrupt_int;
    else
      ext_interrupt_in = #20 ext_interrupt_int;
  end


// -----------------------------------------------------------------------------
//  Detect failures in the testbench and report
// -----------------------------------------------------------------------------

  // latch failure conditions
  always @(*)
     if (~reset_tb)
        begin
           apb_fail_lat    = 0;
           tx_fail_lat     = 0;
           pcs_tx_fail_lat = 0;
           mdio_fail_lat   = 0;
           dma_fail_lat    = 0;
           pins_fail_lat   = 0;
           filter_fail_lat = 0;
           fifo_fail_lat   = 0;
           wr_tog_fail_lat = 0;
        end
     else
        begin
           if (apb_fail)
              apb_fail_lat    = 1'b1;
           if (tx_fail & ~double_error_injection)
              tx_fail_lat     = 1'b1;
           if (pcs_tx_fail & ~double_error_injection)
              pcs_tx_fail_lat = 1'b1;
           if (mdio_fail)
              mdio_fail_lat   = 1'b1;
           if (dma_fail & ~double_error_injection)
              dma_fail_lat    = 1'b1;
           if (pins_fail)
              pins_fail_lat   = 1'b1;
           if (filter_fail)
              filter_fail_lat = 1'b1;
           if (fifo_fail)
              fifo_fail_lat   = 1'b1;
           if (wr_tog_fail | min_toggle_time_fail)
              wr_tog_fail_lat = 1'b1;
           if (xgmii2gmii_fail)
              xgmii2gmii_fail_lat    = 1'b1;
        end

  assign fail = apb_fail_lat | tx_fail_lat | pcs_tx_fail_lat |
                mdio_fail_lat | dma_fail_lat | pins_fail_lat |
                filter_fail_lat | fifo_fail_lat | wr_tog_fail_lat |
                xgmii2gmii_fail_lat | fail_ifss;
  always@(*)
  begin
    if (double_error_injection)
    begin
      if (tx_fail)
        $display("**** INFO : Masking out TX error at %0dns due to error injection",$time);
      if (pcs_tx_fail)
        $display("**** INFO : Masking out PCS TX error at %0dns due to error injection",$time);
      if (dma_fail)
        $display("**** INFO : Masking out DMA error at %0dns due to error injection",$time);
    end
  end

wire  all_done_noifss;
wire  ifss_done;
wire  fault_sim_done;
initial    all_done =  1'b0;
`ifdef edma_tx_pkt_buffer
reg           dma_done_del;         // transactor has finished all operations
initial    dma_done_del =  1'b0;
always @(*)
begin
  if (dma_done | double_error_injection)
  begin
    if (speed | gigabit)
      dma_done_del  =  #100000 1'b1; // 10000ns - delay needed to ensure assertions that check SRAM levels have updated properly
    else
      dma_done_del  =  #200000 1'b1; // 20000ns - delay needed to ensure assertions that check SRAM levels have updated properly
  end
end
`else
wire dma_done_del;         // transactor has finished all operations
assign dma_done_del = dma_done | double_error_injection;
`endif

assign all_done_noifss = (pcs_rx_done & rx_done & apb_done & tx_done & mdio_done &
                          dma_done_del & pins_done & pcs_tx_done & filter_done & fifo_done & flow_ctrl_done);

wire all_done_comb;
assign all_done_comb  = fault_sim_for_dc_en ? fault_sim_done : (all_done_noifss & ifss_done);
always @(*)
begin
    all_done = #10 all_done_comb;
end

// Checking the queue-specific fill levels of the rx-packet buffer
`ifndef edma_ext_fifo_interface
`ifdef edma_rx_pkt_buffer
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q0;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q1;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q2;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q3;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q4;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q5;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q6;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q7;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q8;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q9;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q10;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q11;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q12;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q13;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q14;
   wire [`edma_rx_pbuf_addr-1:0] rx_dpram_fill_lvl_q15;
  `ifdef rtl
    `ifdef dma_priority_queue1
      assign rx_dpram_fill_lvl_q0 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[0].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue1
      assign rx_dpram_fill_lvl_q1 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[1].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue2
      assign rx_dpram_fill_lvl_q2 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[2].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue3
      assign rx_dpram_fill_lvl_q3 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[3].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue4
      assign rx_dpram_fill_lvl_q4 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[4].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue5
      assign rx_dpram_fill_lvl_q5 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[5].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue6
      assign rx_dpram_fill_lvl_q6 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[6].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue7
      assign rx_dpram_fill_lvl_q7 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[7].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue8
      assign rx_dpram_fill_lvl_q8 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[8].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue9
      assign rx_dpram_fill_lvl_q9 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[9].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue10
      assign rx_dpram_fill_lvl_q10 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[10].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue11
      assign rx_dpram_fill_lvl_q11 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[11].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue12
      assign rx_dpram_fill_lvl_q12 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[12].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue13
      assign rx_dpram_fill_lvl_q13 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[13].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue14
      assign rx_dpram_fill_lvl_q14 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[14].fill_lvl_q;
    `endif
    `ifdef dma_priority_queue15
      assign rx_dpram_fill_lvl_q15 = `hier_pbuf_rx.i_edma_pbuf_rx_rd.gen_fill_lvl_q[15].fill_lvl_q;
    `endif
  `else
  assign rx_dpram_fill_lvl_q0 = {`edma_rx_pbuf_addr{1'b0}};
  `endif
`endif

`ifdef edma_tx_pkt_buffer
   wire tx_dpram_fill_lvl;
   wire tx_dpram_fill_lvl_q1;
   wire tx_dpram_fill_lvl_q2;
   wire tx_dpram_fill_lvl_q3;
   wire tx_dpram_fill_lvl_q4;
   wire tx_dpram_fill_lvl_q5;
   wire tx_dpram_fill_lvl_q6;
   wire tx_dpram_fill_lvl_q7;
   wire tx_dpram_fill_lvl_q8;
   wire tx_dpram_fill_lvl_q9;
   wire tx_dpram_fill_lvl_q10;
   wire tx_dpram_fill_lvl_q11;
   wire tx_dpram_fill_lvl_q12;
   wire tx_dpram_fill_lvl_q13;
   wire tx_dpram_fill_lvl_q14;
   wire tx_dpram_fill_lvl_q15;
  `ifdef rtl
    `ifdef dma_priority_queue1
      assign tx_dpram_fill_lvl    = `hier_pbuf_tx_wr.dpram_fill_lvl_array[0] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*1)-1:`edma_tx_pbuf_addr*0];
    `endif
    `ifdef dma_priority_queue1
      assign tx_dpram_fill_lvl_q1 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[1] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*2)-1:`edma_tx_pbuf_addr*1];
    `endif
    `ifdef dma_priority_queue2
      assign tx_dpram_fill_lvl_q2 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[2] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*3)-1:`edma_tx_pbuf_addr*2];
    `endif
    `ifdef dma_priority_queue3
      assign tx_dpram_fill_lvl_q3 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[3] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*4)-1:`edma_tx_pbuf_addr*3];
    `endif
    `ifdef dma_priority_queue4
      assign tx_dpram_fill_lvl_q4 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[4] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*5)-1:`edma_tx_pbuf_addr*4];
    `endif
    `ifdef dma_priority_queue5
      assign tx_dpram_fill_lvl_q5 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[5] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*6)-1:`edma_tx_pbuf_addr*5];
    `endif
    `ifdef dma_priority_queue6
      assign tx_dpram_fill_lvl_q6 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[6] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*7)-1:`edma_tx_pbuf_addr*6];
    `endif
    `ifdef dma_priority_queue7
      assign tx_dpram_fill_lvl_q7 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[7] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*8)-1:`edma_tx_pbuf_addr*7];
    `endif
    `ifdef dma_priority_queue8
      assign tx_dpram_fill_lvl_q8 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[8] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*9)-1:`edma_tx_pbuf_addr*8];
    `endif
    `ifdef dma_priority_queue9
      assign tx_dpram_fill_lvl_q9 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[9] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*10)-1:`edma_tx_pbuf_addr*9];
    `endif
    `ifdef dma_priority_queue10
      assign tx_dpram_fill_lvl_q10 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[10] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*11)-1:`edma_tx_pbuf_addr*10];
    `endif
    `ifdef dma_priority_queue11
      assign tx_dpram_fill_lvl_q11 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[11] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*12)-1:`edma_tx_pbuf_addr*11];
    `endif
    `ifdef dma_priority_queue12
      assign tx_dpram_fill_lvl_q12 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[12] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*13)-1:`edma_tx_pbuf_addr*12];
    `endif
    `ifdef dma_priority_queue13
      assign tx_dpram_fill_lvl_q13 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[13] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*14)-1:`edma_tx_pbuf_addr*13];
    `endif
    `ifdef dma_priority_queue14
      assign tx_dpram_fill_lvl_q14 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[14] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*15)-1:`edma_tx_pbuf_addr*14];
    `endif
    `ifdef dma_priority_queue15
      assign tx_dpram_fill_lvl_q15 =`hier_pbuf_tx_wr.dpram_fill_lvl_array[15] ==
                                    `hier_pbuf_tx_wr.TX_PBUF_MAX_FILL_LVL[(`edma_tx_pbuf_addr*16)-1:`edma_tx_pbuf_addr*15];
    `endif
  `else
  assign tx_dpram_fill_lvl = 0;
  `endif
`endif
`ifdef edma_rx_pkt_buffer
wire rx_dpram_fill_lvl;
  `ifdef rtl
  assign rx_dpram_fill_lvl = ~(|`hier_pbuf_rx.i_edma_pbuf_rx_wr.dpram_fill_lvl[`edma_rx_pbuf_addr-1:0]);
  `else
  assign rx_dpram_fill_lvl = 0;
  `endif
`endif
`endif // edma_ext_fifo_interface

  // report results and end test
  always @(*)
     if ((all_done | end_trig))
        begin
`ifndef edma_ext_fifo_interface
`ifdef edma_tx_pkt_buffer
`ifdef rtl
           if  (!fault_sim_for_dc_en &&
                !double_error_injection &&
               (~tx_dpram_fill_lvl
              `ifdef dma_priority_queue1
                | ~tx_dpram_fill_lvl_q1
              `endif
              `ifdef dma_priority_queue2
                | ~tx_dpram_fill_lvl_q2
              `endif
              `ifdef dma_priority_queue3
                | ~tx_dpram_fill_lvl_q3
              `endif
              `ifdef dma_priority_queue4
                | ~tx_dpram_fill_lvl_q4
              `endif
              `ifdef dma_priority_queue5
                | ~tx_dpram_fill_lvl_q5
              `endif
              `ifdef dma_priority_queue6
                | ~tx_dpram_fill_lvl_q6
              `endif
              `ifdef dma_priority_queue7
                | ~tx_dpram_fill_lvl_q7
              `endif
              `ifdef dma_priority_queue8
                | ~tx_dpram_fill_lvl_q8
              `endif
              `ifdef dma_priority_queue9
                | ~tx_dpram_fill_lvl_q9
              `endif
              `ifdef dma_priority_queue10
                | ~tx_dpram_fill_lvl_q10
              `endif
              `ifdef dma_priority_queue11
                | ~tx_dpram_fill_lvl_q11
              `endif
              `ifdef dma_priority_queue12
                | ~tx_dpram_fill_lvl_q12
              `endif
              `ifdef dma_priority_queue13
                | ~tx_dpram_fill_lvl_q13
              `endif
              `ifdef dma_priority_queue14
                | ~tx_dpram_fill_lvl_q14
              `endif
              `ifdef dma_priority_queue15
                | ~tx_dpram_fill_lvl_q15
              `endif
              ))
              begin
                #50
                 $display("    **** DPRAM FILL LEVEL OF TX PBUF IS INCORRECT (NOT EMPTY AT END OF TEST)");
                 $display("\n%s    **** FAILED **** \n\n",test_case_name);
                 $fdisplay(results_file,"DPRAM FILL OF TX PBUF IS INCORRECT (NOT EMPTY AT END OF TEST)");
                 $fdisplay(results_file,"%s    **** FAILED **** %s",test_case_name,date);
                 `ifdef CDN_LEGACY_UVM
                    ->legacy_tb_done;
                 `else
                    $finish;
                 `endif
              end
            else
              $display("\nNOTE : TX DPRAM fill level was successfully validated at end of test ");
`endif
`endif

`ifdef edma_rx_pkt_buffer
`ifdef rtl
           if (!fault_sim_for_dc_en && !double_error_injection && !rx_dpram_fill_lvl)
              begin
                #50
                 $display("    **** DPRAM FILL LEVEL OF RX PBUF IS INCORRECT (NOT EMPTY AT END OF TEST)");
                 $display("\n%s    **** FAILED **** \n\n",test_case_name);
                 $fdisplay(results_file,"DPRAM FILL OF RX PBUF IS INCORRECT (NOT EMPTY AT END OF TEST)");
                 $fdisplay(results_file,"%s    **** FAILED **** %s",test_case_name,date);
                 `ifdef CDN_LEGACY_UVM
                    ->legacy_tb_done;
                 `else
                    $finish;
                 `endif
              end
            else
              $display("\nNOTE : RX DPRAM fill level was successfully validated at end of test ");
`endif
`endif

          if ((single_error_injection | double_error_injection) && (!tx_all_errs_injected || !rx_all_errs_injected))
          begin
            $display("    **** The number of errors injected was fewer than the test sought to inject ... expected %0d",num_sram_errors_to_inject);
            $display("\n%s    **** FAILED **** \n\n",test_case_name);
            $finish;
          end

`ifdef edma_rx_pkt_buffer
`ifdef rtl
           if (!fault_sim_for_dc_en &&
                !double_error_injection &&
              (rx_dpram_fill_lvl_q0 != {`edma_rx_pbuf_addr{1'b0}}
              `ifdef dma_priority_queue1
                | rx_dpram_fill_lvl_q1 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue2
                | rx_dpram_fill_lvl_q2 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue3
                | rx_dpram_fill_lvl_q3 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue4
                | rx_dpram_fill_lvl_q4 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue5
                | rx_dpram_fill_lvl_q5 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue6
                | rx_dpram_fill_lvl_q6 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue7
                | rx_dpram_fill_lvl_q7 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue8
                | rx_dpram_fill_lvl_q8 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue9
                | rx_dpram_fill_lvl_q9 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue10
                | rx_dpram_fill_lvl_q10 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue11
                | rx_dpram_fill_lvl_q11 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue12
                | rx_dpram_fill_lvl_q12 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue13
                | rx_dpram_fill_lvl_q13 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue14
                | rx_dpram_fill_lvl_q14 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              `ifdef dma_priority_queue15
                | rx_dpram_fill_lvl_q15 != {`edma_rx_pbuf_addr{1'b0}}
              `endif
              ))
              begin
                #50
                 $display("    **** QUEUE-SPECIFIC DPRAM FILL LEVEL OF RX PBUF IS INCORRECT (AT LEAST ONE OF THE QUEUES IS NOT EMPTY AT END OF TEST)");
                 $display("\n%s    **** FAILED **** \n\n",test_case_name);
                 $fdisplay(results_file,"**** QUEUE-SPECIFIC DPRAM FILL LEVEL OF RX PBUF IS INCORRECT (AT LEAST ONE OF THE QUEUES IS NOT EMPTY AT END OF TEST)");
                 $fdisplay(results_file,"%s    **** FAILED **** %s",test_case_name,date);
                 `ifdef CDN_LEGACY_UVM
                    ->legacy_tb_done;
                 `else
                    $finish;
                 `endif
              end
           else
             $display("\nNOTE : QUEUE-SPECIFIC RX DPRAM FILL LEVEL WAS SUCCESSFULLY VALIDATED AT THE END OF THE TEST \n");
`endif
`endif
`endif // edma_ext_fifo_interface

           if (tx_linerate_fail)
           begin
             $display("\n%s    **** FAILED **** \n\n",test_case_name);
             $fdisplay(results_file,"%s    **** FAILED **** %s",test_case_name,date);
              `ifdef CDN_LEGACY_UVM
                 ->legacy_tb_done;
              `else
                $finish;
             `endif
           end
           if (end_trig)
              begin
                 $display("\n\n");
                 if (~rx_done)
                    begin
                       $display("%s RXD not done",test_case_name);
                       $fdisplay(results_file,"%s RXD not done",test_case_name);
                    end
                 if (~pcs_rx_done)
                    begin
                       $display("%s PCS_RXD not done",test_case_name);
                       $fdisplay(results_file,"%s PCS_RXD not done",test_case_name);
                    end
                 if (~apb_done)
                    begin
                       $display("%s APB not done",test_case_name);
                       $fdisplay(results_file,"%s APB not done",test_case_name);
                    end
                 if (~tx_done)
                    begin
                       $display("%s TXD not done",test_case_name);
                       $fdisplay(results_file,"%s TXD not done",test_case_name);
                    end
                 if (~pcs_tx_done)
                    begin
                       $display("%s PCS_TXD not done",test_case_name);
                       $fdisplay(results_file,"%s PCS_TXD not done",test_case_name);
                    end
                 if (~mdio_done)
                    begin
                       $display("%s MDIO not done",test_case_name);
                       $fdisplay(results_file,"%s MDIO not done",test_case_name);
                    end
                 if (~dma_done)
                    begin
                       $display("%s DMA not done",test_case_name);
                       $fdisplay(results_file,"%s DMA not done",test_case_name);
                    end
                 if (~pins_done)
                    begin
                       $display("%s PINS not done",test_case_name);
                       $fdisplay(results_file,"%s PINS not done",test_case_name);
                    end
                 if (~filter_done)
                    begin
                       $display("%s FILTER not done",test_case_name);
                       $fdisplay(results_file,"%s FILTER not done",test_case_name);
                    end
                 if (~fifo_done)
                    begin
                       $display("%s FIFO not done",test_case_name);
                       $fdisplay(results_file,"%s FIFO not done",test_case_name);
                    end
                 if (~phy_ready)
                    begin
                       $display("%s PHY did not indicate phy_ready",test_case_name);
                       $fdisplay(results_file,"%s PHY did not indicate phy_ready",test_case_name);
                    end
                 $display("\n%s    **** ENDED BEFORE ALL ACTIVITY COMPLETE **** \n\n",test_case_name);
                 $fdisplay(results_file,"%s    **** ENDED BEFORE ALL ACTIVITY COMPLETE **** %s",test_case_name,date);
              end
           if (fail)
              begin
                 $display("\n\n");
                 if (fail_ifss)
                    begin
                       $display("%s FAILED IFSS AUTO CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED IFSS AUTO CHECKING",test_case_name);
                    end
                 if (apb_fail_lat)
                    begin
                       $display("%s FAILED APB  CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED APB  CHECKING",test_case_name);
                    end
                 if (tx_fail_lat)
                    begin
                       $display("%s FAILED TX   CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED TX   CHECKING",test_case_name);
                    end
                 if (pcs_tx_fail_lat)
                    begin
                       $display("%s FAILED PCS_TX   CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED PCS_TX   CHECKING",test_case_name);
                    end
                 if (mdio_fail_lat)
                    begin
                       $display("%s FAILED MDIO CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED MDIO CHECKING",test_case_name);
                    end
                 if (dma_fail_lat)
                    begin
                       $display("%s FAILED DMA  CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED DMA  CHECKING",test_case_name);
                    end
                 if (pins_fail_lat)
                    begin
                       $display("%s FAILED PINS CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED PINS CHECKING",test_case_name);
                    end
                 if (filter_fail_lat)
                    begin
                       $display("%s FAILED FILTER CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED FILTER CHECKING",test_case_name);
                    end
                 if (fifo_fail_lat)
                    begin
                       $display("%s FAILED FIFO CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED FIFO CHECKING",test_case_name);
                    end
                 if (wr_tog_fail_lat)
                    begin
                       $display("%s FAILED WR DATABUF TOGGLE COUNT", test_case_name);
                       $fdisplay(results_file,"%s FAILED WR DATABUF TOGGLE COUNT",test_case_name);
                    end
                 if (xgmii2gmii_fail_lat)
                    begin
                       $display("%s FAILED XGMII2GMII  CHECKING",test_case_name);
                       $fdisplay(results_file,"%s FAILED XGMII2GMII  CHECKING",test_case_name);
                    end
                 $display("\n%s    **** FAILED **** \n\n",test_case_name);
                 $fdisplay(results_file,"%s    **** FAILED **** %s",test_case_name,date);
              end
           else if (~end_trig)
              begin
                 if (incompatible_test)
                    $display("\n\n%s    Test not compatible with this configuration.\n",test_case_name);
                 else
                    $display("\n\n");
                 $display("%s    **** PASSED **** \n\n",test_case_name);
                 $fdisplay(results_file,"%s    **** PASSED **** %s",test_case_name,date);
              end

           `ifdef CDN_LEGACY_UVM
              ->legacy_tb_done;
           `else
              if (stop)
                    #600 $stop;    // wait a bit then stop
              else
                    #600 $finish;  // wait a bit then finish
           `endif
        end

// Power toggle capture
`ifdef TB_POWER
initial
  $toggle_count(`hierarchy);

always @ ( all_done or end_trig )
begin

  if ( all_done | end_trig )
  begin
    $toggle_count_report_hier(power_file_name);
  end
end
`endif

// -----------------------------------------------------------------------------
// Activate XGM External Loopback
// -----------------------------------------------------------------------------

// XGM doesn't have internal loopback, so some sims that use internal loopback
// - i.e. lpi tests don't operate and we need a loopback for these test to function.
// This code therefore detects an internal loopback write and activates
// external loopack.

`ifdef xgm
   reg xgm_loopback;
   initial begin
      xgm_loopback = 0;
      forever begin
         @(posedge pclk_source);
         if (psel_int && pwrite_int && penable_int && paddr_int == 13'd0)
            xgm_loopback = pwdata_int[1];
      end
   end
`endif


// -----------------------------------------------------------------------------
// test bench lower level instances follow
// -----------------------------------------------------------------------------

`ifdef xgm

 wire [7:0] gmii_rxd, gmii_rxd_int;
 wire [7:0] gmii_txd;

 gmii2xgmii i_gmii2xgmii (

  .xgmii_clk(rx_clk_to_gem),
  .xgmii_rxc(rxc),
  .xgmii_rxd(rxd),

  .gmii_rx_clk(gmii_clk),
  .gmii_rx_er(gmii_rx_er),
  .gmii_rxd(gmii_rxd),
  .gmii_rx_dv(gmii_rx_dv),

  .fail()

);

 tb_rx i_tb_rx (
   .reset_tb(reset_tb),
   .rx_clk(gmii_clk),
   .rxd(gmii_rxd_int),
   .rx_dv(gmii_rx_dv_int),
   .rx_er(gmii_rx_er_int),
   .gigabit(1'b1),
   .tbi(1'b0),
   .rx_trig(rx_trig),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15|
              int_clock_pulse_emac|int_clock_pulse_mmsl|int_clock_pulse_asf_nonfatal|int_clock_pulse_asf_fatal|int_clock_pulse_emac_asf_nonfatal|int_clock_pulse_emac_asf_fatal),
   .trig_from_apb(trig_from_apb),
   .rx_done(rx_done));

  // delay the rx_dv a bit so the filter checks work correctly.the filter outputs
  // are pipelined from the actual gmii signalling a bit
  reg [FILTER_CHECK_DELAY:0] gmii_rx_dv_del;
  always @( posedge (rx_clk_to_gem) )
    gmii_rx_dv_del  <= {gmii_rx_dv_del[FILTER_CHECK_DELAY-1:0],gmii_rx_dv};

`else
 tb_rx i_tb_rx (
   .reset_tb (reset_tb),
   .rx_clk   (rx_clk_to_gem),
   .rxd      (rxd_tb),
   .rx_dv    (rx_dv_tb),
   .rx_er    (rx_er_int),
   .gigabit  (gigabit),
   .tbi      (tbi),
   .rx_trig  (rx_trig),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15|
              int_clock_pulse_emac|int_clock_pulse_mmsl|int_clock_pulse_asf_nonfatal|int_clock_pulse_asf_fatal|int_clock_pulse_emac_asf_nonfatal|int_clock_pulse_emac_asf_fatal),
   .trig_from_apb(trig_from_apb),
   .rx_done  (rx_done));

   assign rx_er_tb = rx_er_int | force_rx_er;

 wire lpbk_clk;
`ifdef gem_pcs_20b_if
   assign lpbk_clk  = tbi ? gtx20_ref_clk : tx_clk_to_gem;
`else
   assign lpbk_clk  = tbi ? gtx_ref_clk   : tx_clk_to_gem;
`endif
 wire rx_er_from_loop;

 tb_ext_loop i_tb_ext_loop(
   .reset_tb(reset_tb),
   .tx_clk  (lpbk_clk),
   .loopback(loopback),
   .tbi     (tbi),

   // Testbench drivers of RX traffic ..
   .rxd_int     (rxd_tb),
   .rx_dv_int   (rx_dv_tb),
   .rx_er_int   (rx_er_tb),
   .rx_group_int(rx_group_tb),

   // DUT drivers of TX traffic
   .txd     (txd_tb[7:0]),
   .tx_en   (tx_en_tb),
   .tx_er   (tx_er),
   .tx_group(tx_group),

   // Output driver for DUT
   .rxd     (rxd),
   .rx_dv   (rx_dv),
   .rx_er   (rx_er_from_loop),
   .rx_group(rx_group_loop));

`endif


 tb_pcs_rx i_tb_pcs_rx (
   .reset_tb(reset_tb),
   .rx_clk(gtx_ref_clk),

   .pcs_rx_trig(pcs_rx_trig),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15|
              int_clock_pulse_emac|int_clock_pulse_mmsl|int_clock_pulse_asf_nonfatal|int_clock_pulse_asf_fatal|int_clock_pulse_emac_asf_nonfatal|int_clock_pulse_emac_asf_fatal),
   .trig_from_apb(trig_from_apb),
   .trig_from_pcs_tx(trig_from_pcs_tx),
   .ewrap(ewrap),
   .tx_group(tx_group_int),
   .keep_idle_i1(keep_idle_i1),
   .rx_in_progress(rx_in_progress),
   .idle_1_received(idle_1_received),

   .rx_group(rx_group_int),

   .pcs_rx_done(pcs_rx_done),
   .trig_from_pcs_rx(trig_from_pcs_rx),

   .link_fault(link_fault));

`ifdef xgm

 // Set 40G sample rate if in 40G mode
 initial begin
   #1;
   if (ten_gig_mode[1])
      i_xgmii2gmii.set_40g_mode();
 end


 xgmii2gmii i_xgmii2gmii (

  .xgmii_tx_clk(tx_clk_to_gem),
  .xgmii_txc(txc),
  .xgmii_txd(txd),

  .gmii_tx_clk(gmii_clk),
  .gmii_tx_er(gmii_tx_er),
  .gmii_txd(gmii_txd),
  .gmii_tx_en(gmii_tx_en),

  .fail(xgmii2gmii_fail)

);

 tb_tx i_tb_tx(
   .reset_tb(reset_tb),
   .tx_clk(gmii_clk),
   .apb_cbs_ctrl_wr(1'b0),
   .apb_idleslope_a_wr(1'b0),
   .apb_idleslope_b_wr(1'b0),
   .speed(1'b0),
   .pwdata(32'd0),
   .col(),
   .half_duplex(1'b0),
   .gigabit(1'b1),
   .tbi(1'b1),
   .txd(gmii_txd),
   .tx_en(gmii_tx_en),
   .tx_er(gmii_tx_er),
   .tx_done(tx_done),
   .tx_fail(tx_fail));

   // xgm external loopback
   assign gmii_rxd   = (xgm_loopback) ? gmii_txd   : gmii_rxd_int;
   assign gmii_rx_dv = (xgm_loopback) ? gmii_tx_en : gmii_rx_dv_int;
   assign gmii_rx_er = (xgm_loopback) ? gmii_tx_er : gmii_rx_er_int;

`else
 tb_tx i_tb_tx(
   .reset_tb          (reset_tb && !fault_sim_for_dc_en),
   .tx_clk            (tx_clk_to_gem),
   .apb_cbs_ctrl_wr   (psel_int & pwrite_int & penable_int & (paddr_int == `gem_cbs_control)),
   .apb_idleslope_a_wr(psel_int & pwrite_int & penable_int & (paddr_int == `gem_cbs_idleslope_q_a)),
   .apb_idleslope_b_wr(psel_int & pwrite_int & penable_int & (paddr_int == `gem_cbs_idleslope_q_b)),
   .speed             (speed),
   .pwdata            (pwdata_int),
   .col               (col_tb),
   .half_duplex       (half_duplex),
   .gigabit           (gigabit),
   .tbi               (tbi),
   .txd               (txd_tb),
   .tx_en             (tx_en_tb & !disable_txd_checking),
   .tx_er             (tx_er),
   .tx_done           (tx_done),
   .tx_fail           (tx_fail));

   assign xgmii2gmii_fail = 1'b0;

`endif


 tb_pcs_tx i_tb_pcs_tx(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .gtx_clk(gtx_ref_clk),
   .tx_group(tx_group_int),
   .tbi(tbi & !disable_txd_checking),
   .rx_in_progress(rx_in_progress),
   .idle_1_received(idle_1_received),
   .apb_trig(apb_trig),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15|
              int_clock_pulse_emac|int_clock_pulse_mmsl|int_clock_pulse_asf_nonfatal|int_clock_pulse_asf_fatal|int_clock_pulse_emac_asf_nonfatal|int_clock_pulse_emac_asf_fatal),

   .pcs_tx_done(pcs_tx_done),
   .pcs_tx_fail(pcs_tx_fail),
   .trig_from_pcs_tx(trig_from_pcs_tx),
   .link_fault_sig_en(link_fault_sig_en),
   .link_fault(link_fault));


 tb_event i_tb_event (
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .clk_tb(clk_tb),
   .pclk(pclk_source),
   .ethernet_int(ethernet_int),
   .ethernet_int_q1(ethernet_int_q1),
   .ethernet_int_q2(ethernet_int_q2),
   .ethernet_int_q3(ethernet_int_q3),
   .ethernet_int_q4(ethernet_int_q4),
   .ethernet_int_q5(ethernet_int_q5),
   .ethernet_int_q6(ethernet_int_q6),
   .ethernet_int_q7(ethernet_int_q7),
   .ethernet_int_q8(ethernet_int_q8),
   .ethernet_int_q9(ethernet_int_q9),
   .ethernet_int_q10(ethernet_int_q10),
   .ethernet_int_q11(ethernet_int_q11),
   .ethernet_int_q12(ethernet_int_q12),
   .ethernet_int_q13(ethernet_int_q13),
   .ethernet_int_q14(ethernet_int_q14),
   .ethernet_int_q15(ethernet_int_q15),
   .emac_ethernet_int(emac_ethernet_int),
   .mmsl_int(mmsl_int),
   .asf_int_nonfatal(asf_int_nonfatal),
   .asf_int_fatal(asf_int_fatal),
`ifdef gem_has_802p3_br
   .emac_asf_int_nonfatal(emac_asf_int_nonfatal),
   .emac_asf_int_fatal(emac_asf_int_fatal),
`else
   .emac_asf_int_nonfatal(1'b0),
   .emac_asf_int_fatal(1'b0),
`endif
   .int_pulse(int_pulse),
   .int_pulse_q1(int_pulse_q1),
   .int_pulse_q2(int_pulse_q2),
   .int_pulse_q3(int_pulse_q3),
   .int_pulse_q4(int_pulse_q4),
   .int_pulse_q5(int_pulse_q5),
   .int_pulse_q6(int_pulse_q6),
   .int_pulse_q7(int_pulse_q7),
   .int_pulse_q8(int_pulse_q8),
   .int_pulse_q9(int_pulse_q9),
   .int_pulse_q10(int_pulse_q10),
   .int_pulse_q11(int_pulse_q11),
   .int_pulse_q12(int_pulse_q12),
   .int_pulse_q13(int_pulse_q13),
   .int_pulse_q14(int_pulse_q14),
   .int_pulse_q15(int_pulse_q15),
   .int_pulse_emac(int_pulse_emac),
   .int_pulse_mmsl(int_pulse_mmsl),
   .int_pulse_asf_nonfatal(int_pulse_asf_nonfatal),
   .int_pulse_asf_fatal(int_pulse_asf_fatal),
   .int_pulse_emac_asf_nonfatal(int_pulse_emac_asf_nonfatal),
   .int_pulse_emac_asf_fatal(int_pulse_emac_asf_fatal),
   .int_clock_pulse(int_clock_pulse),
   .int_clock_pulse_q1(int_clock_pulse_q1),
   .int_clock_pulse_q2(int_clock_pulse_q2),
   .int_clock_pulse_q3(int_clock_pulse_q3),
   .int_clock_pulse_q4(int_clock_pulse_q4),
   .int_clock_pulse_q5(int_clock_pulse_q5),
   .int_clock_pulse_q6(int_clock_pulse_q6),
   .int_clock_pulse_q7(int_clock_pulse_q7),
   .int_clock_pulse_q8(int_clock_pulse_q8),
   .int_clock_pulse_q9(int_clock_pulse_q9),
   .int_clock_pulse_q10(int_clock_pulse_q10),
   .int_clock_pulse_q11(int_clock_pulse_q11),
   .int_clock_pulse_q12(int_clock_pulse_q12),
   .int_clock_pulse_q13(int_clock_pulse_q13),
   .int_clock_pulse_q14(int_clock_pulse_q14),
   .int_clock_pulse_q15(int_clock_pulse_q15),
   .int_clock_pulse_emac(int_clock_pulse_emac),
   .int_clock_pulse_mmsl(int_clock_pulse_mmsl),
   .int_clock_pulse_asf_nonfatal(int_clock_pulse_asf_nonfatal),
   .int_clock_pulse_asf_fatal(int_clock_pulse_asf_fatal),
   .int_clock_pulse_emac_asf_nonfatal(int_clock_pulse_emac_asf_nonfatal),
   .int_clock_pulse_emac_asf_fatal(int_clock_pulse_emac_asf_fatal),
   .count(count),
   .rx_trig(rx_trig),
   .pcs_rx_trig(pcs_rx_trig),
   .apb_trig(apb_trig),
   .apb_int_status_read(apb_int_status_read),
   .apb_int_q1_status_read(apb_int_q1_status_read),
   .apb_int_q2_status_read(apb_int_q2_status_read),
   .apb_int_q3_status_read(apb_int_q3_status_read),
   .apb_int_q4_status_read(apb_int_q4_status_read),
   .apb_int_q5_status_read(apb_int_q5_status_read),
   .apb_int_q6_status_read(apb_int_q6_status_read),
   .apb_int_q7_status_read(apb_int_q7_status_read),
   .apb_int_q8_status_read(apb_int_q8_status_read),
   .apb_int_q9_status_read(apb_int_q9_status_read),
   .apb_int_q10_status_read(apb_int_q10_status_read),
   .apb_int_q11_status_read(apb_int_q11_status_read),
   .apb_int_q12_status_read(apb_int_q12_status_read),
   .apb_int_q13_status_read(apb_int_q13_status_read),
   .apb_int_q14_status_read(apb_int_q14_status_read),
   .apb_int_q15_status_read(apb_int_q15_status_read),
   .apb_emac_int_status_read(apb_emac_int_status_read),
   .apb_mmsl_int_status_read(apb_mmsl_int_status_read),
   .apb_asf_int_nonfatal_status_read(apb_asf_int_nonfatal_status_read),
   .apb_asf_int_fatal_status_read(apb_asf_int_fatal_status_read),
   .apb_emac_asf_int_nonfatal_status_read(apb_emac_asf_int_nonfatal_status_read),
   .apb_emac_asf_int_fatal_status_read(apb_emac_asf_int_fatal_status_read),
   .pins_drive_trig(pins_drive_trig),
   .pins_check_trig(pins_check_trig),
   .filter_drive_trig(filter_drive_trig),
   .end_trig(end_trig));


 tb_apb i_tb_apb(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .pclk(pclk_source),
   .paddr(paddr_int),
   .prdata(prdata),
   .pwdata(pwdata_int),
   .pwdata_par(pwdata_par_int),
   .pwrite(pwrite_int),
   .penable(penable_int),
   .psel(psel_int),
   .perr(perr),
   .apb_trig(apb_trig),
   .int_pulse(int_pulse),
   .int_pulse_asf_nonfatal(int_pulse_asf_nonfatal),
   .int_pulse_asf_fatal(int_pulse_asf_fatal),
   .int_pulse_emac_asf_nonfatal(int_pulse_emac_asf_nonfatal),
   .int_pulse_emac_asf_fatal(int_pulse_emac_asf_fatal),
   .int_pulse_emac(int_pulse_emac),
   .int_pulse_mmsl(int_pulse_mmsl),
   .int_pulse_q15(int_pulse_q15),
   .int_pulse_q14(int_pulse_q14),
   .int_pulse_q13(int_pulse_q13),
   .int_pulse_q12(int_pulse_q12),
   .int_pulse_q11(int_pulse_q11),
   .int_pulse_q10(int_pulse_q10),
   .int_pulse_q9(int_pulse_q9),
   .int_pulse_q8(int_pulse_q8),
   .int_pulse_q7(int_pulse_q7),
   .int_pulse_q6(int_pulse_q6),
   .int_pulse_q5(int_pulse_q5),
   .int_pulse_q4(int_pulse_q4),
   .int_pulse_q3(int_pulse_q3),
   .int_pulse_q2(int_pulse_q2),
   .int_pulse_q1(int_pulse_q1),
   .apb_int_status_read(apb_int_status_read),
   .apb_int_q1_status_read(apb_int_q1_status_read),
   .apb_int_q2_status_read(apb_int_q2_status_read),
   .apb_int_q3_status_read(apb_int_q3_status_read),
   .apb_int_q4_status_read(apb_int_q4_status_read),
   .apb_int_q5_status_read(apb_int_q5_status_read),
   .apb_int_q6_status_read(apb_int_q6_status_read),
   .apb_int_q7_status_read(apb_int_q7_status_read),
   .apb_int_q8_status_read(apb_int_q8_status_read),
   .apb_int_q9_status_read(apb_int_q9_status_read),
   .apb_int_q10_status_read(apb_int_q10_status_read),
   .apb_int_q11_status_read(apb_int_q11_status_read),
   .apb_int_q12_status_read(apb_int_q12_status_read),
   .apb_int_q13_status_read(apb_int_q13_status_read),
   .apb_int_q14_status_read(apb_int_q14_status_read),
   .apb_int_q15_status_read(apb_int_q15_status_read),
   .apb_emac_int_status_read(apb_emac_int_status_read),
   .apb_mmsl_int_status_read(apb_mmsl_int_status_read),
   .apb_asf_int_nonfatal_status_read(apb_asf_int_nonfatal_status_read),
   .apb_asf_int_fatal_status_read(apb_asf_int_fatal_status_read),
   .apb_emac_asf_int_nonfatal_status_read(apb_emac_asf_int_nonfatal_status_read),
   .apb_emac_asf_int_fatal_status_read(apb_emac_asf_int_fatal_status_read),
   .trig_from_apb(trig_from_apb),
   .apb_done(apb_done),
   .apb_fail(apb_fail),
   .apb_64b_addr_mode_en(apb_64b_addr_mode_en),
   .apb_qos_for_axi(apb_qos_for_axi),
   .apb_tx_ext_bd_mode_en(apb_tx_ext_bd_mode_en),
   .link_fault_sig_en(link_fault_sig_en));


 tb_mdio i_tb_mdio(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .mdc(mdc),
   .mdio_in(mdio_in),
   .mdio_out(mdio_out),
   .mdio_en(mdio_en),
   .mdio_done(mdio_done),
   .mdio_fail(mdio_fail));


`ifdef gem_ext_fifo_interface
assign dma_done = 1'b1;
`else

`ifdef edma_axi
 tb_dma_axi i_tb_dma(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .hclk(hclk_source),
   .fault_sim(ifss_dis_x_drv),
   .double_error_injection(double_error_injection),
   .dma_bus_width(dma_bus_width),
   .amba_ready_delay(amba_ready_delay),
   .bus_grant_delay(bus_grant_delay),
   .apb_endian_wr(psel_int & pwrite_int & penable_int & (paddr_int == 13'h0010)),
   .apb_endian_val(pwdata_int[7:6]),
   .axi_perf_test(axi_perf_test),

   .awqos                   (awqos),
   .awid                    (awid),
   .awaddr                  (awaddr),
   .awlen                   (awlen),
   .awsize                  (awsize),
   .awburst                 (awburst),
   .awlock                  (awlock),
   .awcache                 (awcache),
   .awprot                  (awprot),
   .awvalid                 (awvalid),
   .awready                 (awready),
   .wdata                   (wdata),
   .wstrb                   (wstrb),
   .wlast                   (wlast),
   .wready                  (wready),
   .wvalid                  (wvalid),
   .bid                     (bid),
   .bresp                   (bresp),
   .bvalid                  (bvalid),
   .bready                  (bready),
   .arqos                   (arqos),
   .arid                    (arid),
   .araddr                  (araddr),
   .arlen                   (arlen),
   .arsize                  (arsize),
   .arburst                 (arburst),
   .arlock                  (arlock),
   .arcache                 (arcache),
   .arprot                  (arprot),
   .arvalid                 (arvalid),
   .arready                 (arready),
   .rid                     (rid),
   .rdata                   (rdata),
   .rresp                   (rresp),
   .rlast                   (rlast),
   .rvalid                  (rvalid),
   .rready                  (rready),
   .randomize_hgrant(randomize_hgrant),
   .randomize_hready(randomize_hready),
   .fixed_latency_mode(fixed_latency_mode),
   .descr_min(descr_min),
   .descr_max(descr_max),
   .data_min (data_min ),
   .data_max (data_max ),
   .data_min_lock (data_min_lock ),
   .data_max_lock (data_max_lock ),
   .read_min  (read_min  ),
   .read_max  (read_max  ),
   .write_min (write_min ),
   .write_max (write_max ),
   .dma_done(dma_done),
   .dma_fail(dma_fail),
   .apb_64b_addr_mode_en(apb_64b_addr_mode_en),
   .apb_qos_for_axi(apb_qos_for_axi),
   .apb_tx_ext_bd_mode_en(apb_tx_ext_bd_mode_en));
`else
 tb_dma i_tb_dma(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .hclk(hclk_source),
   .fault_sim(ifss_dis_x_drv),
   .double_error_injection(double_error_injection),
   .dma_bus_width(dma_bus_width),
   .amba_ready_delay(amba_ready_delay),
   .bus_grant_delay(bus_grant_delay),
   .apb_endian_wr(psel_int & pwrite_int & penable_int & (paddr_int == 13'h0010)),
   .apb_endian_val(pwdata_int[7:6]),
   .haddr(haddr),
   .htrans(htrans),
   .hwrite(hwrite),
   .hsize(hsize),
   .hburst(hburst),
   .hprot(hprot),
   .hwdata(hwdata),
   .hrdata(hrdata),
   .hready(hready),
   .hresp(hresp),
   .randomize_hgrant(randomize_hgrant),
   .randomize_hready(randomize_hready),
   .descr_min(descr_min),
   .descr_max(descr_max),
   .data_min (data_min ),
   .data_max (data_max ),
   .data_min_lock (data_min_lock ),
   .data_max_lock (data_max_lock ),
   .read_min  (read_min  ),
   .read_max  (read_max  ),
   .write_min (write_min ),
   .write_max (write_max ),
   .hbusreqdma(hbusreqdma),
   .hlockdma(hlockdma),
   .hgrantdma(hgrantdma),
   .dma_done(dma_done),
   .dma_fail(dma_fail),
   .apb_64b_addr_mode_en(apb_64b_addr_mode_en));
`endif
`endif

tb_fifo i_tb_fifo (
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .dma_bus_width(dma_bus_width),
   .fifo_latency(fifo_latency),
   .fifo_under_delay(fifo_under_delay),
   .fifo_status_delay(fifo_status_delay),
   .fifo_over_delay(fifo_over_delay),
   .tx_clk(tx_clk_to_gem),
   .tx_r_rd(tx_r_rd),
   .tx_r_data(tx_r_data_int),
   .tx_r_mod(tx_r_mod_int),
   .tx_r_eop(tx_r_eop_int),
   .tx_r_sop(tx_r_sop_int),
   .tx_r_err(tx_r_err_int),
   .tx_r_valid(tx_r_valid_int),
   .tx_r_data_rdy(tx_r_data_rdy_int),
   .tx_r_control(tx_r_control_int),
   .tx_r_underflow(tx_r_underflow_int),
   .tx_r_flushed(tx_r_flushed_int),
   .tx_r_status(tx_r_status),
   .dma_tx_status_tog(dma_tx_status_tog_int),
   .dma_tx_end_tog(dma_tx_end_tog),
   `ifdef gem_fifo_8b_if
    `ifdef gem_no_pcs
    .rx_clk(rx_clk_to_gem),
    `else // if not gem_no_pcs
    .rx_clk(~rx_clk_from_phy),
    `endif
   `else
   .rx_clk(rx_clk_to_gem),
   `endif
   .rx_w_data(rx_w_data),
   .rx_w_mod(rx_w_mod),
   .rx_w_eop(rx_w_eop),
   .rx_w_sop(rx_w_sop),
   .rx_w_err(rx_w_err),
   .rx_w_flush(rx_w_flush),
   .rx_w_wr(rx_w_wr),
   .rx_status(rx_w_status),
   .rx_w_queue(rx_w_queue),
   .rx_w_overflow(rx_w_overflow),
   .trig_from_apb(trig_from_apb),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15),
   .fifo_done(fifo_done),
   .fifo_fail(fifo_fail));

 tb_fifo_loop i_tb_fifo_loop (

   .loopback(fifo_loopback_mode),
   .tx_clk(tx_clk_to_gem),
   .tx_r_data(tx_r_data_loop),
   .tx_r_mod(tx_r_mod_loop),
   .tx_r_sop(tx_r_sop_loop),
   .tx_r_eop(tx_r_eop_loop),
   .tx_r_err(tx_r_err_loop),
   .tx_r_rd(tx_r_rd[0]),
   .tx_r_valid(tx_r_valid_loop),
   .tx_r_data_rdy(tx_r_data_rdy_loop),
   .tx_r_underflow(tx_r_underflow_loop),
   .tx_r_flushed(tx_r_flushed_loop),
   .tx_r_control(tx_r_control_loop),
   .tx_r_status(tx_r_status),
   .rx_clk(rx_clk_to_gem),
   .rx_w_wr(rx_w_wr),
  `ifdef gem_fifo_8b_if
   .tx_r_fixed_lat(tx_r_fixed_lat),
   .tx_enet_data(txd[7:0]),
   .rx_w_data(rx_w_data[7:0]),
  `else
   .rx_w_data(rx_w_data),
  `endif
   .rx_w_mod(rx_w_mod),
   .rx_w_sop(rx_w_sop),
   .rx_w_eop(rx_w_eop),
   .rx_w_err(rx_w_err),
   .rx_w_flush(rx_w_flush),
   .rx_w_status(rx_w_status),
   .rx_w_overflow(),
   .dma_tx_end_tog(dma_tx_end_tog),
   .dma_tx_status_tog(dma_tx_status_tog_loop));

 wire signal_detect_pins;
 tb_pins i_tb_pins(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .clk_tb(clk_tb),
   .loopback(loopback),
   .half_duplex(half_duplex),
   .ethernet_int(ethernet_int),
   .speed(speed),
   .mii_select(mii_select),
   `ifdef gem_user_io
   .user_out(user_out),
   .user_in(user_in),
   `endif // gem_user_io
   .ext_interrupt_int(ext_interrupt_int),
   .eam(),
   .drive_reset(drive_reset),
   .drive_crs(drive_crs),
   .tx_en_crs(tx_en_crs),
   .col_sqe_en(),
   .tx_pause(tx_pause),
   .tx_pause_zero(tx_pause_zero),
   .tx_pfc_sel(tx_pfc_sel),
   .tx_pfc_pause(tx_pfc_pause),
   .tx_pfc_pause_zero(tx_pfc_pause_zero),
   .trigger_dma_tx_start(trigger_dma_tx_start),
   .pcs_cal_bypass(pcs_cal_bypass),
   .pcs_cgalign_bypass(pcs_cgalign_bypass),
   .wol(wol),
   .en_cdet(en_cdet),
   .ewrap(ewrap),
   .signal_detect(signal_detect_pins),
   .force_rx_er(force_rx_er),
   .force_back_pressure(force_back_pressure),
   .sof_tx(sof_tx),
   .sync_frame_tx(sync_frame_tx),
   .delay_req_tx(delay_req_tx),
   .pdelay_req_tx(pdelay_req_tx),
   .pdelay_resp_tx(pdelay_resp_tx),
   .sof_rx(sof_rx),
   .sync_frame_rx(sync_frame_rx),
   .delay_req_rx(delay_req_rx),
   .pdelay_req_rx(pdelay_req_rx),
   .pdelay_resp_rx(pdelay_resp_rx),
   .pfc_negotiate(pfc_negotiate),
   .rx_pfc_paused(rx_pfc_paused),
   `ifdef edma_tsu
   .edma_tsu_inc_ctrl(edma_tsu_inc_ctrl),
   .edma_tsu_ms(edma_tsu_ms),
   .tsu_timer_cmp_val(tsu_timer_cmp_val),
   `endif // edma_tsu
   .tb_rx_bit_slip(tb_rx_bit_slip),
   .keep_idle_i1(keep_idle_i1),
   .tb_mode_2_5g(tb_mode_2_5g),
   .amba_par_err_inj(amba_par_err_inj),
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   .asf_sram_corr_err  (asf_sram_corr_err),
   `endif
   `ifdef gem_asf_dap_prot
   .asf_sram_uncorr_err(asf_sram_uncorr_err),
   `endif
`endif
   `ifdef gem_asf_integrity_prot
   .asf_integrity_err  (asf_integrity_err),
   `endif
   `ifdef gem_asf_dap_prot
   .asf_dap_err        (asf_dap_err),
   `endif
   `ifdef gem_asf_csr_prot
   .asf_csr_err        (asf_csr_err),
   `endif
   .asf_trans_to_err   (asf_trans_to_err),
   .asf_protocol_err   (asf_protocol_err),
   .asf_int_nonfatal   (asf_int_nonfatal),
   .asf_int_fatal      (asf_int_fatal),

   `ifdef gem_has_802p3_br
`ifdef edma_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   .emac_asf_sram_corr_err   (emac_asf_sram_corr_err),
   `endif
   `ifdef gem_asf_dap_prot
   .emac_asf_sram_uncorr_err (emac_asf_sram_uncorr_err),
   `endif
`endif
   `ifdef gem_asf_integrity_prot
   .emac_asf_integrity_err   (emac_asf_integrity_err),
   `endif
   `ifdef gem_asf_dap_prot
   .emac_asf_dap_err         (emac_asf_dap_err),
   `endif
   `ifdef gem_asf_csr_prot
   .emac_asf_csr_err         (emac_asf_csr_err),
   `endif
   .emac_asf_trans_to_err    (emac_asf_trans_to_err),
   .emac_asf_protocol_err    (emac_asf_protocol_err),
   .emac_asf_int_nonfatal    (emac_asf_int_nonfatal),
   .emac_asf_int_fatal       (emac_asf_int_fatal),
   `endif
   .count(count),
   .trig_from_apb(trig_from_apb),
   .pins_check_trig(pins_check_trig),
   .pins_drive_trig(pins_drive_trig),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15),
   .pins_done(pins_done),
   .pins_fail(pins_fail));

 tb_filter i_tb_filter(
   .reset_tb(reset_tb && !fault_sim_for_dc_en),
   .mac_rx_clk(rx_clk_to_gem),
   .tbi_rx_clk(gtx_ref_clk),
   .count(count),
   .trig_from_apb(trig_from_apb),
   .int_pulse(int_clock_pulse|int_clock_pulse_q1|int_clock_pulse_q2|int_clock_pulse_q3|int_clock_pulse_q4|int_clock_pulse_q5|int_clock_pulse_q6|int_clock_pulse_q7|
              int_clock_pulse_q8|int_clock_pulse_q9|int_clock_pulse_q10|int_clock_pulse_q11|int_clock_pulse_q12|int_clock_pulse_q13|int_clock_pulse_q14|int_clock_pulse_q15),
   .filter_drive_trig(filter_drive_trig),
   .rx_group(rx_group_int),
   .tbi(tbi),
   .filter_done(filter_done),
   .filter_fail(filter_fail),
`ifdef xgm
   .rx_dv(gmii_rx_dv_del[FILTER_CHECK_DELAY]),
`else
   .rx_dv(rx_dv),
`endif
   .ext_da(ext_da),
   .ext_da_stb(ext_da_stb),
   .ext_sa(ext_sa),
   .ext_sa_stb(ext_sa_stb),
   .ext_type(ext_type),
   .ext_type_stb(ext_type_stb),
   .ext_vid(ext_vid),
   .ext_vid_stb(ext_vid_stb),
   .ext_ip_sa(ext_ip_sa),
   .ext_ip_sa_stb(ext_ip_sa_stb),
   .ext_ip_da(ext_ip_da),
   .ext_ip_da_stb(ext_ip_da_stb),
   .ext_source_port(ext_source_port),
   .ext_sp_stb(ext_sp_stb),
   .ext_dest_port(ext_dest_port),
   .ext_dp_stb(ext_dp_stb),
   .ext_ipv6(ext_ipv6),
   .ext_vlan_tag1_stb(ext_vlan_tag1_stb),
   .ext_vlan_tag1(ext_vlan_tag1),
   .ext_vlan_tag2_stb(ext_vlan_tag2_stb),
   .ext_vlan_tag2(ext_vlan_tag2),
   .sync_frame_rx(sync_frame_rx),
   .delay_req_rx(delay_req_rx),
   .pdelay_req_rx(pdelay_req_rx),
   .pdelay_resp_rx(pdelay_resp_rx),
   .ext_match1(ext_match1),
   .ext_match2(ext_match2),
   .ext_match3(ext_match3),
   .ext_match4(ext_match4));


  // Bit slipping module with 0 latency.
  tb_rx_bit_slip i_bit_slip (
    .clk(gtx_ref_clk),
    .reset_n(reset_tb),
    .slip_sel(tb_rx_bit_slip[4:0]),
    .in_data(rx_group_int),
    .out_data(rx_group_slip)
  );

`ifdef gem_pcs_20b_if
  // optional 20 to 10 gearbox for TX checker
  tb_20_10_grbx i_tx_grbx (
    .in_clk(gtx20_ref_clk),
    .in_rst_n(n_gtx20reset),
    .out_clk(gtx_ref_clk),
    .out_rst_n(n_gtxreset),
    .in_data(tx_group),
    .out_data(tx_group_int)
  );

  // optional 10 to 20 gearbox for RX stimulus
  // Generate rx_group_20 from rx_group_slip
  tb_10_20_grbx i_rx_grbx (
    .in_clk(pma_rx_clk),
    .in_rst_n(n_prxreset),
    .out_clk(pma_rx20_clk),
    .out_rst_n(n_pmarx20reset),
    .in_data(rx_group_slip),
    .out_data(rx_group_20)
  );

  // delay rx_group for gate-level simulation
  always @(*)
  begin
    #10;
    rx_group_tb = rx_group_20;
  end
`else
  assign tx_group_int = tx_group;

  initial
    rx_group_tb = 0;

  // delay rx_group for gate-level simulation
  always @(*)
  begin
    #10;
    rx_group_tb = rx_group_slip;
  end
`endif

`ifdef gem_phy_interop_sim
  // Instantiate wrapper for PHY, this also does all the necessary initialisation
  // and assert phy_ready when ready to accept data. Transmit data is looped back
  // to rx.
  // Currently only 20-bit interface is supported in this environment.
  `ifdef gem_pcs_20b_if
    wire  [19:0]  rx_group_from_phy;
    wire          rx_sigdet_from_phy;
    wire          gtx_clk_from_phy;
    wire          gtx20_clk_from_phy;
    wire          pcs_rx_clk_from_phy;
    wire          phy_ready_int;
    wire  [3:0]   phy_lane_sel;
    assign phy_lane_sel = 4'h3; // TODO
    gem_phy_init_wrap i_phy_init_wrap (
      .phy_lane_sel     (phy_lane_sel),
      .tx_data          (tx_group),
      .rx_data          (rx_group_from_phy),
      .rx_sigdet        (rx_sigdet_from_phy),
      .gtx_clk          (gtx_clk_from_phy),
      .gtx20_clk        (gtx20_clk_from_phy),
      .pcs_rx_clk       (pcs_rx_clk_from_phy),
      .phy_ready        (phy_ready_int)
    );
    assign rx_group       = tb_use_phy_model  ? rx_group_from_phy[p_pcs_width-1:0]
                                              : rx_group_loop;
    assign signal_detect  = tb_use_phy_model  ? rx_sigdet_from_phy
                                              : signal_detect_pins;
    assign gtx_ref_clk    = tb_use_phy_model  ? gtx_clk_from_phy
                                              : gtx_ref_clk_tb;
    assign gtx20_ref_clk  = tb_use_phy_model  ? gtx20_clk_from_phy
                                              : gtx20_ref_clk_tb;
    assign pma_rx20_clk   = tb_use_phy_model  ? pcs_rx_clk_from_phy
                                              : pma_rx20_clk_tb;
    assign phy_ready      = tb_use_phy_model  ? phy_ready_int : 1'b1;
  `else
    // No actual PHY available here, so just pass through as before, this should
    // be configured in the testcase to signal incompatible test.
    assign rx_group       = rx_group_loop;
    assign signal_detect  = signal_detect_pins;
    assign gtx_ref_clk    = gtx_ref_clk_tb;
    assign gtx20_ref_clk  = gtx20_ref_clk_tb;
    assign pma_rx20_clk   = pma_rx20_clk_tb;
    assign phy_ready      = tb_start;
  `endif
`else
  assign rx_group           = rx_group_loop;
  assign signal_detect      = signal_detect_pins;
  assign gtx_ref_clk        = gtx_ref_clk_tb;
  assign gtx20_ref_clk      = gtx20_ref_clk_tb;
  assign pma_rx20_clk       = pma_rx20_clk_tb;
  assign phy_ready          = tb_start;
`endif


`ifdef xgm
 assign txd_tb = txd;
`else
  wire          crs_dv_rmii_int;
  wire    [1:0] rxd_rmii_int;

 tb_rmii_phy i_tb_rmii(
   // system signals
   .reset_tb(reset_tb),
   .ten_meg_bit(~speed),

   // MII signals
   .txd(txd_rmii_tb),
   .tx_en(tx_en_rmii_tb),

   .col(col_tb & !loopback),
   .crs(crs_rmii_tb),
   .rxd(rxd[3:0]),    // after the ext loopback
   .rx_dv(rx_dv),
   .rx_er(rx_er_from_loop),

   // RMII signals
   .txd_rmii(txd_rmii),
   .tx_en_rmii(tx_en_rmii),
   .ref_clk(tb_rmii_ref_clk),
   .rxd_rmii(rxd_rmii_int),
   .rx_er_rmii(rx_er_rmii),
   .crs_dv(crs_dv_rmii_int));

   assign #5 tb_rmii_ref_clk = rmii_ref_clk;

   // RMII/MII ethernet signals to MACB/RMIIB
   assign col         = (mii_select) ? col_tb      : 1'b0;
   assign crs         = (mii_select) ? crs_tb      : 1'b0;
   assign rx_er       = (mii_select) ? rx_er_from_loop    : 1'b0;

   assign rxd_rmii    = (loopback) ? txd_rmii   : rxd_rmii_int;
   assign crs_dv_rmii = (loopback) ? tx_en_rmii : crs_dv_rmii_int;


   // RMII/MII ethernet signals from MACB/RMIIB
   assign txd_tb      = (mii_select)? txd      : txd_rmii_tb;
   assign tx_en_tb    = (mii_select)? tx_en    : tx_en_rmii_tb;
`endif

   // apb delays for gate-level sims
   always @(*)
   begin
     #20
     paddr      = psel_int ? paddr_int   : psel_faultsim ? paddr_faultsim   : paddr_ifss;
     pwdata     = psel_int ? pwdata_int  : psel_faultsim ? pwdata_faultsim  : pwdata_ifss;
     pwdata_par = psel_int ? pwdata_par_int  : psel_faultsim ? pwdata_par_faultsim  : pwdata_par_ifss;
     pwrite     = psel_int ? pwrite_int  : psel_faultsim ? pwrite_faultsim  : pwrite_ifss;
     penable    = psel_int ? penable_int : psel_faultsim ? penable_faultsim : penable_ifss;
     psel       = psel_int | psel_ifss | psel_faultsim;
   end

   // fifo delays for gate-level sims
   always @(tx_clk_to_gem)
   begin
     #10
     if (fifo_loopback_mode) begin
       tx_r_data = tx_r_data_loop;
       tx_r_mod = tx_r_mod_loop;
       tx_r_eop = tx_r_eop_loop;
       tx_r_sop = tx_r_sop_loop;
       tx_r_err = tx_r_err_loop;
       tx_r_valid = tx_r_valid_loop;
       tx_r_data_rdy[0] = tx_r_data_rdy_loop;
       tx_r_control = tx_r_control_loop;
       tx_r_underflow = tx_r_underflow_loop;
       tx_r_flushed = tx_r_flushed_loop;
       dma_tx_status_tog = dma_tx_status_tog_loop;
     end
     else begin
       tx_r_data = tx_r_data_int;
       tx_r_mod = tx_r_mod_int;
       tx_r_eop = tx_r_eop_int;
       tx_r_sop = tx_r_sop_int;
       tx_r_err = tx_r_err_int;
       tx_r_valid = tx_r_valid_int;
       tx_r_data_rdy = tx_r_data_rdy_int;
       tx_r_control = tx_r_control_int;
       tx_r_underflow = tx_r_underflow_int;
       tx_r_flushed = tx_r_flushed_int;
       dma_tx_status_tog = dma_tx_status_tog_int;
     end
   end


  // CHECK TX LINE RATE
  always @(posedge tx_clk_to_gem or negedge n_txreset)
  begin
    // Only enable this mode for full duplex tests
    //
    // IPG lasts for around 12 cycles and will be followed by 7 cycles
    // of preamble
    //
    // Check that if we see the line inactive for more than 4 cycles and we
    // are not in IPG, then fail test
    if (~n_txreset)
    begin
      tx_linerate_fail <= 1'b0;
      tx_linerate_cnt <= 0;
      first_txd_started<= 0;
      tx_linerate_warn <= 1'b0;
    end
    else
    begin
      tx_linerate_warn <= 1'b0;
      if ((txd_tb != 0))
        first_txd_started <= 1;
      if (txd_tb == 0 & first_txd_started & check_txlinerate & ~tx_done)
      begin
        tx_linerate_cnt <= tx_linerate_cnt+1;
        if ((gigabit & tx_linerate_cnt == 15) |
            (~gigabit & tx_linerate_cnt == 30))
        begin
          if ($time < 2000000)
          begin
            tx_linerate_warn <= 1'b1;
            $display("WARNING :- TX LINERATE FAIL DROPPED (But is at start of test, so prob okay) at time = %0dns",$time);
            $fdisplay(results_file,("WARNING :- TX LINERATE FAIL DROPPED (But is at start of test, so prob okay) at time = %0dns"),$time);
          end
          else
          begin
            tx_linerate_fail <= 1'b1;
            $display("**** ERROR :- TX LINERATE FAIL DROPPED UNEXPECTEDLY at time = %0dns",$time);
            $fdisplay(results_file,("**** ERROR :-TX LINERATE FAIL DROPPED UNEXPECTEDLY at time = %0dns"),$time);
          end
        end
      end
      else
        tx_linerate_cnt <= 0;
    end
  end


   // -----------------------------------------------------------------------------
   //
   //              SPRAM Specific function to calculate the AHB/AXI Frequency
   //
   // -----------------------------------------------------------------------------

   // This function is used for SPRAM operation, where the higher sel_ahb_freq
   // values are used for SPRAM operations to select frequencies that are
   // similar to the Data rates that the MAC is running at. The purpose of
   // this is to test the SPRAM at minimum clock frequencies. The sel_ahb_freq
   // settings give the following frequencies:

   // sel_ahb_freq = 5  : AHB/AXI Clock 1.6-1.8x faster than MAC data rate
   // sel_ahb_freq = 6  : AHB/AXI Clock 2x       faster than MAC data rate
   // sel_ahb_freq = 7  : AHB/AXI Clock 2-2.5x   faster than MAC data rate
   // sel_ahb_freq = 8  : AHB/AXI Clock 2.5-3x   faster than MAC data rate
   // sel_ahb_freq = 9  : AHB/AXI Clock 3-4x     faster than MAC data rate
   // sel_ahb_freq = 10 : AHB/AXI Clock 8x       faster than MAC data rate
   // sel_ahb_freq = 11 : AHB/AXI Clock randomx  faster than MAC data rate

   // Note. XGM obviously has a much faster MAC rate, so having the AHB/AXI
   // clock running up to 8x faster is not realistic as the frequency would
   // be GHx, so XGM is limited up to 3x faster. 3x faster with a 32b bus width
   // is still pretty fast mind you - ~930MHz!
   function integer calc_spram_amba_period;
      input [1:0] ten_gig_mode;
      input gigabit;
      input speed;
      input [1:0] dma_bus_width;
      input [2:0] sel_ahb_freq;

      real base_period, mac_rate;
      integer bus_width;
      begin
      // Calculte the base period for the mode of operation
      casex ({ten_gig_mode, gigabit, speed})
         4'b0000 : base_period = 1e3;  // 10M
         4'b0001 : base_period = 1e2;  // 100M
         4'b001x : base_period = 1e1;  // 1G
         4'b01xx : base_period = 1;    // 10G
         4'b1xxx : base_period = 0.25; // 40G
      endcase

      // Calcualte the DMA bus width
      case (dma_bus_width)
         2'b00   : bus_width = 32;
         2'b01   : bus_width = 64;
         default : bus_width = 128;
      endcase

      // mac_rate
      mac_rate = bus_width * base_period;
      // Scale the period based on the sel_ahb_freq setting
      case (sel_ahb_freq)
         5 : spram_divisor = $urandom_range(20,18); // divided by 1.8 to 2.0
         6       : spram_divisor = 20;                    // divided by 2.0
         `ifdef xgm
         default : spram_divisor = $urandom_range(30,18); // divided by 1.8 to 3.0
         `else
         default : spram_divisor = $urandom_range(80,20); // divided by 2.0 to 8.0
         `endif
      endcase
      calc_spram_amba_period = mac_rate/spram_divisor;

      // If we are not using AXI then the bus is shared between read and write so
      // we need to multiply the frequency by 2 to get proper throughput.
      `ifndef edma_axi
         calc_spram_amba_period = calc_spram_amba_period/2;
      `endif

      // Adjust the period to match the timescale setting
      calc_spram_amba_period = calc_spram_amba_period*10;
     // $display ("TB_TOP : SPRAM AXI clock setting function called : gigabit = %0d, mac_rate = %0d, spram_divisor = %0d",gigabit, mac_rate,spram_divisor);
      $display ("TB_TOP : spram_amba_period : %0d",calc_spram_amba_period);
      end
   endfunction


   // -----------------------------------------------------------------------------
   //
   //              Function to calculate the pclk frequency
   //
   // -----------------------------------------------------------------------------


   // Ensure the pclk frequency is always less than the amba frequency.
   // A division between 1.1 and 4 is acceptable

   function integer calc_spram_pclk_period;
      input spram_amba_period;

      calc_spram_pclk_period = $urandom_range(spram_amba_period*4,spram_amba_period+1);

   endfunction




   // -----------------------------------------------------------------------------
   //
   //             IFSS Auto Validate Code
   //
   // -----------------------------------------------------------------------------

   wire [23:0]  tx_sram_read_add_int, tx_sram_read_add_err;
   wire [23:0]  rx_sram_read_add_int, rx_sram_read_add_err;
   tb_ifss_checker i_tb_ifss_checker (
     .rx_sram_read_clk    (hclk_source),
   `ifdef edma_spram
     .tx_sram_read_clk    (hclk_source),
   `else
     .tx_sram_read_clk    (tx_clk_to_gem),
   `endif
     .auto_fault_checker  (auto_fault_checker),
     .auto_restart_after_fatal  (double_error_injection),
     .pclk                (pclk_source),
     .n_preset            (n_preset),
     .psel                (psel),
     .psel_int            (psel_int),
     .prdata              (prdata),
     .paddr_ifss          (paddr_ifss),
     .pwdata_ifss         (pwdata_ifss),
     .pwdata_par_ifss     (pwdata_par_ifss),
     .pwrite_ifss         (pwrite_ifss),
     .penable_ifss        (penable_ifss),
     .psel_ifss           (psel_ifss),
     .all_done            (all_done_noifss),
     .end_trig            (end_trig),
     .rx_sram_read_add    (rx_sram_read_add_err),
     .tx_sram_read_add    (tx_sram_read_add_err),
     .fail_ifss           (fail_ifss),
     .ifss_done           (ifss_done)
   );

   // -----------------------------------------------------------------------------
   //
   //             Fault Sim TB
   //
   // -----------------------------------------------------------------------------

   tb_faultsim i_tb_faultsim (
     .fault_sim           (fault_sim),
     .fault_sim_trig      (fault_sim_for_dc_en),
     .pclk                (pclk_source),
     .n_preset            (n_preset),
     .psel                (psel),
     .psel_int            (psel_int),
 //    .prdata              (prdata),
     .paddr_faultsim      (paddr_faultsim),
     .pwdata_faultsim     (pwdata_faultsim),
     .pwdata_par_faultsim (pwdata_par_faultsim),
     .pwrite_faultsim     (pwrite_faultsim),
     .penable_faultsim    (penable_faultsim),
     .psel_faultsim       (psel_faultsim),
     .fault_sim_done      (fault_sim_done)
   );

   // -----------------------------------------------------------------------------
   //
   //             SRAM Direct Error Injection
   //
   // -----------------------------------------------------------------------------
   `ifdef edma_tx_pkt_buffer
   assign tx_sram_read_add_int  = {{(24-`edma_tx_pbuf_addr){1'b0}},tx_sram_read_add};
   parameter tx_ram_width  = `edma_tx_pbuf_reduncy+`edma_tx_pbuf_data;
   tb_ram_err_inj #(.ram_width(tx_ram_width)) i_tx_ram_err_inj (
   `ifdef edma_spram
     .ram_clk           (hclk_source),
     .ram_rst_n         (n_hreset),
   `else
     .ram_clk           (tx_clk_to_gem),
     .ram_rst_n         (n_txreset),
   `endif
     .err_inj_en    (single_error_injection | double_error_injection),
     .double_err_inj(double_error_injection),
     .dp_enable     (`hierarchy.i_gem_reg_top.enable_transmit),
     .num_errors    (num_sram_errors_to_inject),
     .ram_en        (txsram_en),
     .ram_read_en   (!txsram_we),
     .ram_data      (txsram_dob),
     .sram_read_add (tx_sram_read_add_int),
     .sram_addr_err (tx_sram_read_add_err),
     .ram_data_err  (txsram_dob_err_inj),
     .all_errs_injected (tx_all_errs_injected)
   );
   `endif
   `ifdef edma_rx_pkt_buffer
   assign rx_sram_read_add_int  = {{(24-`edma_rx_pbuf_addr){1'b0}},rx_sram_read_add};
   parameter rx_ram_width  = `edma_rx_pbuf_reduncy+`edma_rx_pbuf_data;
   tb_ram_err_inj #(.ram_width(rx_ram_width)) i_rx_ram_err_inj (
     .ram_clk       (hclk_source),
     .ram_rst_n     (n_hreset),
     .err_inj_en    (single_error_injection | double_error_injection),
     .double_err_inj(double_error_injection),
     .dp_enable     (`hierarchy.i_gem_reg_top.enable_receive),
     .num_errors    (num_sram_errors_to_inject),
     .ram_en        (rxsram_en),
     .ram_read_en   (!rxsram_we),
     .ram_data      (rxsram_dob),
     .sram_read_add (rx_sram_read_add_int),
     .sram_addr_err (rx_sram_read_add_err),
     .ram_data_err  (rxsram_dob_err_inj),
     .all_errs_injected (rx_all_errs_injected)
   );
   `endif

   // -----------------------------------------------------------------------------
   //
   //        Configure the spram frequencies at a change of configuration
   //
   // -----------------------------------------------------------------------------


   // Monitor changes on dma_bus_width and speeds to determine the
   // system frequency to use.
   initial begin

      // Default to 1G mode
      spram_amba_period = 80;
      spram_pclk_period = 200;
      cg_spram_system_sample = 1'b0;
      #1;

      // Set the random generator from the seed
      void_value = $urandom(seed);

      // stevenh, adding some delay here to allow DUT outputs to settle in the case
      // of doing gate level sims, this probably needs more work and should take into
      // account APB reset probably...
      #20;
      // Monitor the speed and bus widths and at a change calculate
      // the frequency.
      /// GMORRIS: changing to allow sampling ov coveregroup
      fork
         forever begin
            @(dma_bus_width or ten_gig_mode or gigabit or speed);
            #10;
            spram_amba_period = (calc_spram_amba_period(ten_gig_mode[1:0], gigabit, speed, dma_bus_width, sel_ahb_freq));
            spram_pclk_period = $urandom_range(spram_amba_period*4,spram_amba_period+1);
            #1;
            `ifndef xgm
              if (sel_ahb_freq >= 5)
            `endif
               cg_spram_system_sample = ~cg_spram_system_sample;
         end
         forever begin
         @((all_done | end_trig));
         `ifndef xgm
            if (sel_ahb_freq >= 5)
         `endif
               cg_spram_system_sample = ~cg_spram_system_sample;
         end
      join

   end


   assign test_ending = all_done | end_trig;

endmodule

