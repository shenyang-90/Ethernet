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
//   Filename:           tb_gem_gxl.v
//   Module Name:        tb_gem_gxl
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
// Description : This is the top level instatiation of the Gigabit Ethernet MAC
//               (GEM) module with its level 0 (ie stand alone) test bench
//
//------------------------------------------------------------------------------


`include "tb_defs.v"

`ifdef xgm
module tb_xgm ();
`else
module tb_gem_gxl ();
`endif

`ifdef rtl
parameter p_rtl_sim = 1'b1;
`else
parameter p_rtl_sim = 1'b0;
`endif

   // GMII / MII ethernet interface
   wire          gtx_ref_clk;             // reference GMII clock
   wire          gtx20_ref_clk;           // 20-bit reference GMII clock
   wire          n_gtx20reset;
   wire          tx_er;                   // transmit error signal to the PHY
   wire          tx_er_tb2;               // transmit error signal to the PHY
   wire   [31:0] txd;                     // transmit data to the PHY
   wire    [3:0] txc;                     // transmit control to the PHY
   wire          tx_en;                   // transmit enable signal to the PHY
   wire          tx_clk_from_phy;         // transmit clock from the PHY
   wire   [31:0] rxd;                     // receive data from the PHY
   wire    [3:0] rxc;                     // receive control to the PHY
   wire          rx_er;                   // receive error signal from the PHY
   wire          rx_clk_from_phy;         // receive clock from the PHY
   wire          rx_dv;                   // receive data valid signal from PHY
`ifdef NOXGMII
   wire   [63:0] xgm_txd;                 // transmit data to the PHY
   wire    [7:0] xgm_txc;                 // transmit control to the PHY
   wire   [63:0] xgm_rxd;                 // receive data from the PHY
   wire    [7:0] xgm_rxc;                 // receive control to the PHY
`else
   wire   [31:0] xgm_txd;                 // transmit data to the PHY
   wire    [3:0] xgm_txc;                 // transmit control to the PHY
   wire   [31:0] xgm_rxd;                 // receive data from the PHY
   wire    [3:0] xgm_rxc;                 // receive control to the PHY
`endif
   // other ethernet signals
   wire          col_tb;                  // collision detect from the PHY
   wire          crs_tb;                  // carrier sense signal from the PHY
   wire          col;                     // collision detect from the PHY
   wire          crs;                     // carrier sense signal from the PHY
   wire          mdc;                     // management data clock
   wire          mdio_in;                 // management data input
   wire          mdio_out;                // management data input
   wire          mdio_en;                 // management data input  enable
   wire          loopback;                // loopback signal to the PHY
   wire          loopback_local;          // Indicates MAC is in local loopback.
   wire          half_duplex;             // half duplex signal to the PHY
   wire    [3:0] speed_mode;              // indicates speed and interface used.
   wire          two_pt_five_gig;         // indicates 2.5G operation
   wire          gigabit;                 // high for gigabit operation
   wire          tbi;                     // high for ten bit operation
   wire          speed;                   // state of speed pin in config high
                                          // for 100 Meg operation
   wire          ext_interrupt_in;        // external interrupt input
   wire          ext_match1;              // external address match
   wire          ext_match2;              // external address match
   wire          ext_match3;              // external address match
   wire          ext_match4;              // external address match
   wire   [47:0] ext_da;                  // stored destination address from the
                                          // receive data
   wire          ext_da_stb;              // set when destination address valid
   wire   [47:0] ext_sa;                  // stored source address from the
                                          // receive data
   wire          ext_sa_stb;              // set when source address valid
   wire   [15:0] ext_type;                // stored length field from the
                                          // receive frame
   wire          ext_type_stb;            // length/TypeID field valid
   wire   [31:0] ext_vlan_tag1;           // stored VLAN ID from the rxed frame
   wire          ext_vlan_tag1_stb;       // VLAN ID field valid strobe
   wire   [31:0] ext_vlan_tag2;           // stored VLAN ID from the rxed frame
   wire          ext_vlan_tag2_stb;       // VLAN ID field valid strobe
   wire  [127:0] ext_ip_sa;               // IP source address
   wire          ext_ip_sa_stb;           // IP source address valid strobe
   wire  [127:0] ext_ip_da;               // IP destination address
   wire          ext_ip_da_stb;           // IP destination address valid strobe
   wire   [15:0] ext_source_port;         // source port number
   wire          ext_sp_stb;              // validates source port number
   wire   [15:0] ext_dest_port;           // destination port number
   wire          ext_dp_stb;              // validates destination port number
   wire          ext_ipv6;                // high for ipv6

   // precision time protocol signals for IEEE 1588 support
   wire          sof_tx;            // asserted on SFD deasserted at EOF
   wire          sync_frame_tx;     // asserted if PTP sync frame is detected
   wire          delay_req_tx;      // asserted if PTP delay_req is detected
   wire          pdelay_req_tx;     // asserted if PTP pdelay_req is detected
   wire          pdelay_resp_tx;    // asserted if PTP pdelay_resp is detected
   wire          sof_rx;            // asserted on SFD deasserted at EOF
   wire          sync_frame_rx;     // asserted if PTP sync frame is detected
   wire          delay_req_rx;      // asserted if PTP delay_req is detected
   wire          pdelay_req_rx;     // asserted if PTP pdelay_req is detected
   wire          pdelay_resp_rx;    // asserted if PTP pdelay_resp is detected
   `ifdef edma_tsu
   wire    [1:0] edma_tsu_inc_ctrl; // controls TSU timer increment
   wire          edma_tsu_ms;       // TSU master/slave select
   wire   [93:0] tsu_timer_cnt;     // TSU timer count value
   wire          tsu_timer_cmp_val; // TSU timer comparison valid
   `endif // edma_tsu
   `ifdef edma_ext_tsu_timer
   wire   [93:0] ext_tsu_timer;     // external tsu timer port
   `endif
   wire          tsu_clk;           // TSU clock can be used instead of pclk
   wire          n_tsureset;        // reset for TSU clock

   wire          tx_pause;          // transmit pause frame. If toggled
                                    // causes a pause frame to be txed
   wire          tx_pause_zero;     // Use zero quantum in tx pause frame
   wire          tx_pfc_sel;        // When set to 0, transmit 802.3
                                    // pause frame
                                    // When set to 1, transmit PFC
                                    // pause frame
   wire          pfc_negotiate;     // indicates a received PFC
                                    // pause frame

   wire [7:0]    rx_pfc_paused;     // each bit is set when PFC frame has
                                    // been received and the associated
                                    // PFC counter != 0

   wire    [7:0] tx_pfc_pause;      // priority enable vector of the
                                    // PFC pause frame
   wire    [7:0] tx_pfc_pause_zero; // When set to 1, PFC pause frame
                                    // has zero pause quantum
                                    // When set to 0, PFC pause frame
                                    // has the value of transmit pause
   wire          wol;               // Wake-on-LAN output
   wire          trigger_dma_tx_start; // Trigger TX_DMA_START
   wire          pcs_cal_bypass;      // Bypass comma alignment function
   wire          pcs_cgalign_bypass;  // Bypass codegroup alignment function

`ifdef gem_pcs_20b_if
   wire   [19:0] tx_group;                // TBI transmit data to the PHY
   wire   [19:0] rx_group;                // TBI receive data from the PHY
`else
   wire    [9:0] tx_group;                // TBI transmit data to the PHY
   wire    [9:0] rx_group;                // TBI receive data from the PHY
`endif
   wire          rbc0_from_phy;           // TBI receive clock from the PHY
   wire          rbc1_from_phy;           // TBI receive clock from the PHY
   wire          ewrap;                   // initiate loop back of phy.
   wire          en_cdet;                 // Enable comma alignment in PMA.
   wire          signal_detect;           // Valid link detected from PMD.

   wire          pma_rx_clk;              // PMA recovered clock (125MHz)
   wire          n_prxreset;              // Reset in pma_rx_clk domain.
   wire          pma_rx20_clk;            // PMA 20-bit recovered clock
   wire          n_pmarx20reset;          // Reset
   wire          rbc_align;               // For rbc alignment

   // APB interface signals
   wire          pclk_source;             // AHB clock from tb_top
   wire          pclk_to_gem;             // AHB clock from clk_cntrl
   wire          n_preset;                // Amba reset
   wire   [12:0] paddr;                   // address bus of selected master
   wire   [31:0] prdata;                  // read data
   wire   [31:0] pwdata;                  // write data
   wire    [3:0] pwdata_par;
   wire          pwrite;                  // peripheral write strobe
   wire          penable;                 // peripheral enable
   wire          psel;                    // peripheral select for GPIO
   wire          perr;                    // not a standard APB signal, driven
                                          // high when psel is asserted if
                                          // address is not known
   `ifdef CDN_LEGACY_UVM
      // --
      // UVM related
      // --
      wire          apb_mux;                 // 0 = normal TB, 1 = APB UVC
      wire          enet_mux;                // 0 = normal TB, 1 = APB UVC
      `ifndef CDN_LEGACY_UVM
         assign apb_mux    = 1'b0;
         assign enet_mux   = 1'b0;
      `endif
      wire   [12:0] tb_mstr_paddr;                   // APB VIP signals
      wire          tb_mstr_penable;                 // APB VIP signals
      wire          tb_mstr_pwrite;                  // APB VIP signals
      wire   [31:0] tb_mstr_pwdata;                  // APB VIP signals
      wire          tb_mstr_psel;                    // APB VIP signals

      wire   [12:0] paddr_int    = apb_mux ? tb_mstr_paddr   : paddr;
      wire          penable_int  = apb_mux ? tb_mstr_penable : penable;
      wire          pwrite_int   = apb_mux ? tb_mstr_pwrite  : pwrite;
      wire   [31:0] pwdata_int   = apb_mux ? tb_mstr_pwdata  : pwdata;
      wire    [3:0] pwdata_par_int  = apb_mux ? {^tb_mstr_pwdata[31:24],
                                                  ^tb_mstr_pwdata[23:16],
                                                  ^tb_mstr_pwdata[15:8],
                                                  ^tb_mstr_pwdata[7:0]}  : pwdata_par;
      wire          psel_int     = apb_mux ? tb_mstr_psel    : psel;

      wire        tb_mstr_crs;                        // ENET VIP signals
      wire        tb_mstr_rx_dv;                      // ENET VIP signals
      wire [7:0]  tb_mstr_rxd;                        // ENET VIP signals
      wire        tb_mstr_rx_er;                      // ENET VIP signals
      wire        tb_mstr_col;                        // ENET VIP signals

      wire        crs_int        = enet_mux ? tb_mstr_crs      : crs_tb;
      wire        rx_dv_int      = enet_mux ? tb_mstr_rx_dv    : rx_dv;
      wire [7:0]  rxd_int        = enet_mux ? tb_mstr_rxd      : rxd;
      wire        rx_er_int      = enet_mux ? tb_mstr_rx_er    : rx_er;
      wire        col_int        = enet_mux ? tb_mstr_col      : col_tb;
   `else
      wire   [12:0] paddr_int    = paddr;
      wire          penable_int  = penable;
      wire          pwrite_int   = pwrite;
      wire   [31:0] pwdata_int   = pwdata;
      wire    [3:0] pwdata_par_int = pwdata_par;
      wire          psel_int     = psel;
   `endif



   // AHB interface signals
   wire          hclk_source;             // AHB clock from tb_top
   wire          hclk_to_gem;             // AHB clock from clk_cntrl
   wire          n_hreset;                // AHB reset
   wire    [1:0] dma_bus_width;           // encoding for DMA bus width

   `ifdef edma_axi


   // Write Address Channel
   wire  [3:0]  awid;
   wire  [`edma_addr_width-1:0]     awaddr;
   wire  [7:0]  awlen;
   wire  [2:0]  awsize;
   wire  [1:0]  awburst;
   wire  [1:0]  awlock;
   wire  [3:0]  awcache;
   wire  [2:0]  awprot;
   wire  [3:0]  awqos;
   wire         awvalid;
   wire           awready;
   // Write Data Channel
   wire  [`edma_bus_width-1:0]      wdata;
   wire  [(`edma_bus_width/8)-1:0]  wstrb;
   wire         wlast;
   wire  [3:0]  wid;
   wire         wready;
   wire         wvalid;

   // Response Channel
   wire  [3:0]  bid;
   wire  [1:0]  bresp;
   wire         bvalid;
   wire         bready;

   // Read Address Channel
   wire  [3:0]  arid;
   wire  [`edma_addr_width-1:0]     araddr;
   wire  [7:0]  arlen;
   wire  [2:0]  arsize;
   wire  [1:0]  arburst;
   wire  [1:0]  arlock;
   wire  [3:0]  arcache;
   wire  [2:0]  arprot;
   wire  [3:0]  arqos;
   wire         arvalid;
   wire         arready;
   // Read Data Channel
   wire  [3:0]  rid;
   wire [127:0] rdata;
   wire  [1:0]  rresp;
   wire         rlast;
   wire         rvalid;
   wire         rready;
  `else
   wire          hready;                  // AHB Slave ready
   wire    [1:0] hresp;                   // AHB Slave response
   wire          hgrantdma;               // AHB ARBITER control grant
   wire  [127:0] hrdata;                  // AHB input data

   wire   [`gem_dma_addr_width-1:0] haddr;                   // address to write to
   wire    [1:0] htrans;                  // transfer method
   wire          hwrite;                  // read/write
   wire    [2:0] hsize;                   // transfer size -
                                          // set to 3'b010 for 32 bit words
                                          // set to 3'b011 for 64 bit words
                                          // set to 3'b100 for 128 bit words
   wire    [2:0] hburst;                  // burst mode
   wire    [3:0] hprot;                   // protection mode of AHB.
   wire  [`edma_bus_width-1:0]            //
                 hwdata;                  // Write data
   wire          hbusreqdma;              // Bus request
   wire          hlockdma;                // Lock the bus
   `endif


   // external fifo interface.
  `ifdef gem_fifo_8b_if
   wire  [7:0]   tx_r_data;
  `else
   wire  [`emac_bus_width-1:0] tx_r_data;
  `endif
   wire    [3:0] tx_r_mod;                // tx number of valid bytes in last
                                          // transfer of the frame.
                                          // 0000 - tx_r_data[127:0] valid,
                                          // 0001 - tx_r_data[7:0] valid,
                                          // 0010 - tx_r_data[15:0] valid, until
                                          // 1111 - tx_r_data[119:0] valid.
   wire          tx_r_sop;                // start of packet indicator.
   wire          tx_r_eop;                // end of packet indicator.
   wire          tx_r_err;                // packet in error indicator.
   wire [`edma_queues-1:0] tx_r_rd;       // request new data from fifo.
   wire   [3:0]  tx_r_queue;              // Queue ID, timed with tx_r_rd
   wire          tx_r_valid;              // new tx data available from fifo.
   wire [`edma_queues-1:0] tx_r_data_rdy; // indicates either a complete packet
                                          // is present in the fifo or a certain
                                          // threshold of data has been crossed,
                                          // the mac uses this input to trigger
                                          // a frame transfer.
   wire          tx_r_underflow;          // signals tx fifo underrun condition.
   wire          tx_r_flushed;            // tx fifo has been flushed.
   wire          tx_r_control;            // tx control from in-line FIFO word
   wire    [3:0] tx_r_status;             // tx status written to in-line FIFO
   wire    [`edma_queues-1:0]
                 tx_r_frame_size_vld;     // We have the frame size.
   wire    [(`edma_queues*14)-1:0]
                 tx_r_frame_size;         // Frame Length, 1 per queue
   wire          dma_tx_status_tog;       // toggle acknowledge for tx_r_status
   wire          dma_tx_end_tog;          // toggle when tx_r_status is valid

   wire          rx_w_wr;                 // rx write output to the receive
                                          // fifo.
   `ifdef gem_fifo_8b_if
   wire   [7:0]  rx_w_data;               // output data to the receive fifo.
   wire          tx_r_fixed_lat;          // latency has become fixed
   `else
   wire  [`emac_bus_width-1:0]            //
                 rx_w_data;               // output data to the receive fifo.
   `endif
   wire   [3:0]  rx_w_mod;                // rx number of valid bytes in last
                                          // transfer of the frame.
   wire          rx_w_sop;                // rx start of packet indicator.
   wire          rx_w_eop;                // rx end of packet indicator.
   wire          rx_w_err;                // rx packet in error indicator.
   wire          rx_w_flush;              // rx fifo flush from the mac
   wire   [44:0] rx_w_status;             // rx status written to in-line FIFO
   wire   [3:0]  rx_w_queue;
   `ifdef num_spec_add_filters
      wire   [`num_spec_add_filters-1:0] add_match_vec;           // indicates specific address match
   `endif
                                          // status 3 to 0 are returned by
                                          // rx_w_status
   wire          rx_w_overflow;           // rx FIFO overflow.

   // external fifo interface.
  `ifdef gem_has_802p3_br
    `ifdef gem_fifo_8b_if
    wire                  [7:0] emac_tx_r_data;
    `else
    wire  [`emac_bus_width-1:0] emac_tx_r_data;
    `endif
  `endif
   wire    [3:0] emac_tx_r_mod;                // tx number of valid bytes in last
                                               // transfer of the frame.
                                               // 0000 - tx_r_data[127:0] valid,
                                               // 0001 - tx_r_data[7:0] valid,
                                               // 0010 - tx_r_data[15:0] valid, until
                                               // 1111 - tx_r_data[119:0] valid.
   wire          emac_tx_r_sop;                // start of packet indicator.
   wire          emac_tx_r_eop;                // end of packet indicator.
   wire          emac_tx_r_err;                // packet in error indicator.
   wire          emac_tx_r_rd;       // request new data from fifo.
   wire   [3:0]  emac_tx_r_queue;              // Queue ID, timed with tx_r_rd
   wire          emac_tx_r_valid;              // new tx data available from fifo.
   wire          emac_tx_r_data_rdy; // indicates either a complete packet
                                               // is present in the fifo or a certain
                                               // threshold of data has been crossed,
                                               // the mac uses this input to trigger
                                               // a frame transfer.
   wire          emac_tx_r_underflow;          // signals tx fifo underrun condition.
   wire          emac_tx_r_flushed;            // tx fifo has been flushed.
   wire          emac_tx_r_control;            // tx control from in-line FIFO word
   wire    [3:0] emac_tx_r_status;             // tx status written to in-line FIFO
   wire          emac_tx_r_frame_size_vld;     // We have the frame size.
   wire    [13:0]
                 emac_tx_r_frame_size;         // Frame Length, 1 per queue
   wire          emac_dma_tx_status_tog;       // toggle acknowledge for tx_r_status
   wire          emac_dma_tx_end_tog;          // toggle when tx_r_status is valid

   wire          emac_rx_w_wr;                 // rx write output to the receive fifo

   `ifdef gem_has_802p3_br
     `ifdef gem_fifo_8b_if
     wire   [7:0]  emac_rx_w_data;               // output data to the receive fifo.
     wire          emac_tx_r_fixed_lat;          // latency has become fixed
     `else
     wire  [`emac_bus_width-1:0] emac_rx_w_data; // output data to the receive fifo.
     `endif
   `endif
   wire   [3:0]  emac_rx_w_mod;                // rx number of valid bytes in last
                                               // transfer of the frame.
   wire          emac_rx_w_sop;                // rx start of packet indicator.
   wire          emac_rx_w_eop;                // rx end of packet indicator.
   wire          emac_rx_w_err;                // rx packet in error indicator.
   wire          emac_rx_w_flush;              // rx fifo flush from the mac
   wire   [44:0] emac_rx_w_status;             // rx status written to in-line FIFO
   wire   [3:0]  emac_rx_w_queue;
   `ifdef gem_has_802p3_br
     `ifdef num_spec_add_filters
      wire   [`num_spec_add_filters-1:0] emac_add_match_vec; // indicates specific address match
     `endif
   `endif
                                          // status 3 to 0 are returned by
                                          // rx_w_status
   wire          emac_rx_w_overflow;      // rx FIFO overflow.

   wire          force_back_pressure;     // External Back pressure



   // Packet buffer external DPSRAM connections
   `ifdef edma_rx_pkt_buffer
   `ifdef edma_spram
   wire           rxspram_we;             // RX SPRAM write enable
   wire           rxspram_en;             // RX SPRAM chip enable
   wire   [`edma_rx_pbuf_addr-1:0]        // RX SPRAM address bus
                  rxspram_addr;
   wire   [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX SPRAM write data bus
                  rxspram_di;
   wire   [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX SPRAM read data bus
                  rxspram_do;
   `else
   wire           rxdpram_wea;            // RX DPSRAM port A write enable.
   wire           rxdpram_ena;            // RX DPSRAM port A chip enable.
   wire   [`edma_rx_pbuf_addr-1:0]        // RX DPSRAM port A...
                  rxdpram_addra;          //    address bus.
   wire   [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port A...
                  rxdpram_dia;            //    write data bus.
   wire   [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port A...
                  rxdpram_doa;            //    read data bus.
   wire           rxdpram_web;            // RX DPSRAM port B write enable.
   wire           rxdpram_enb;            // RX DPSRAM port B chip enable.
   wire   [`edma_rx_pbuf_addr-1:0]        // RX DPSRAM port B...
                  rxdpram_addrb;          //    address bus.
   wire   [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port B...
                  rxdpram_dib;            //    write data bus.
   reg    [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port B...
                  rxdpram_dob;            //    read data bus.
   `endif
   wire    [`edma_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]       // SRAM data out with error injection
                  rxsram_dob_err_inj;       //    write data bus.
   `endif // edma_rx_pkt_buffer

   `ifdef edma_tx_pkt_buffer
   `ifdef edma_spram
   wire           txspram_we;             // TX SPRAM write enable
   wire           txspram_en;             // TX SPRAM chip enable
   wire   [`edma_tx_pbuf_addr-1:0]        // TX SPRAM address bus
                  txspram_addr;
   wire   [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // TX SPRAM write data bus
                  txspram_di;
   wire   [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // TX SPRAM read data bus
                  txspram_do;
   `else
   wire           txdpram_wea;            // TX DPSRAM port A write enable.
   wire           txdpram_ena;            // TX DPSRAM port A chip enable.
   wire   [`edma_tx_pbuf_addr-1:0]        // TX DPSRAM port A...
                  txdpram_addra;          //    address bus.
   wire   [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // TX DPSRAM port A...
                  txdpram_dia;            //    write data bus.
   wire           txdpram_web;            // TX DPSRAM port B write enable.
   wire           txdpram_enb;            // TX DPSRAM port B chip enable.
   wire   [`edma_tx_pbuf_addr-1:0]        // TX DPSRAM port B...
                  txdpram_addrb;          //    address bus.
   wire   [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // TX DPSRAM port B...
                  txdpram_dob;            //    read data bus.
   `endif
   wire   [`edma_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // SRAM data out with error injection
                  txsram_dob_err_inj;       //    write data bus.
   `endif // edma_tx_pkt_buffer

   `ifdef gem_has_802p3_br
   `ifdef edma_rx_pkt_buffer
   `ifdef edma_spram
   wire           emac_rxspram_we;             // RX SPRAM write enable
   wire           emac_rxspram_en;             // RX SPRAM chip enable
   wire   [`gem_emac_rx_pbuf_addr-1:0]         // RX SPRAM address bus
                  emac_rxspram_addr;
   wire   [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0]        // RX SPRAM write data bus
                  emac_rxspram_di;
   wire   [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0]        // RX SPRAM read data bus
                  emac_rxspram_do;
   `else
   wire           emac_rxdpram_wea;            // RX DPSRAM port A write enable.
   wire           emac_rxdpram_ena;            // RX DPSRAM port A chip enable.
   wire   [`gem_emac_rx_pbuf_addr-1:0]         // RX DPSRAM port A...
                  emac_rxdpram_addra;          //    address bus.
   wire   [`edma_emac_rx_pbuf_reduncy+`gem_rx_pbuf_data-1:0]        // RX DPSRAM port A...
                  emac_rxdpram_dia;            //    write data bus.
   wire   [`edma_emac_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port A...
                  emac_rxdpram_doa;            //    read data bus.
   wire           emac_rxdpram_web;            // RX DPSRAM port B write enable.
   wire           emac_rxdpram_enb;            // RX DPSRAM port B chip enable.
   wire   [`gem_emac_rx_pbuf_addr-1:0]        // RX DPSRAM port B...
                  emac_rxdpram_addrb;          //    address bus.
   wire   [`edma_emac_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port B...
                  emac_rxdpram_dib;            //    write data bus.
   reg    [`edma_emac_rx_pbuf_reduncy+`edma_rx_pbuf_data-1:0]        // RX DPSRAM port B...
                  emac_rxdpram_dob;            //    read data bus.
   `endif
   `endif // edma_rx_pkt_buffer

   `ifdef edma_tx_pkt_buffer
   `ifdef edma_spram
   wire           emac_txspram_we;             // TX SPRAM write enable
   wire           emac_txspram_en;             // TX SPRAM chip enable
   wire   [`gem_emac_tx_pbuf_addr-1:0]        // TX SPRAM address bus
                  emac_txspram_addr;
   wire   [`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0]        // TX SPRAM write data bus
                  emac_txspram_di;
   wire   [`edma_emac_tx_pbuf_reduncy+`gem_tx_pbuf_data-1:0]        // TX SPRAM read data bus
                  emac_txspram_do;
   `else
   wire           emac_txdpram_wea;            // TX DPSRAM port A write enable.
   wire           emac_txdpram_ena;            // TX DPSRAM port A chip enable.
   wire   [`gem_emac_tx_pbuf_addr-1:0]        // TX DPSRAM port A...
                  emac_txdpram_addra;          //    address bus.
   wire   [`edma_emac_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // TX DPSRAM port A...
                  emac_txdpram_dia;            //    write data bus.
   wire           emac_txdpram_web;            // TX DPSRAM port B write enable.
   wire           emac_txdpram_enb;            // TX DPSRAM port B chip enable.
   wire   [`gem_emac_tx_pbuf_addr-1:0]         // TX DPSRAM port B...
                  emac_txdpram_addrb;          //    address bus.
   wire   [`edma_emac_tx_pbuf_reduncy+`edma_tx_pbuf_data-1:0]        // TX DPSRAM port B...
                  emac_txdpram_dob;            //    read data bus.
   `endif
   `endif // edma_tx_pkt_buffer
   `endif

   // ASF comman output error indications
`ifndef gem_ext_fifo_interface
`ifdef gem_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   wire         asf_sram_corr_err;             // SRAM correctable error indication
   `endif
   `ifdef gem_asf_dap_prot
   wire         asf_sram_uncorr_err;           // SRAM uncorrectable error indication
   `endif
`endif
`endif
   `ifdef gem_asf_integrity_prot
   wire         asf_integrity_err;             // Integrity error indication
   `endif
   `ifdef gem_asf_dap_prot
   wire         asf_dap_err;                   // Data and Address Paths error indication
   `endif
   `ifdef gem_asf_csr_prot
   wire         asf_csr_err;                   // Configuration and Status Registers error indication
   `endif
   wire         asf_trans_to_err;              // Transaction Timeouts indication
   wire         asf_protocol_err;              // Protocol error indication
   // ASF and fatal and non-fatal interrupts
   wire         asf_int_nonfatal;              // ASF non-fatal interrupt
   wire         asf_int_fatal;                 // ASF fatal interrupt

   `ifdef gem_has_802p3_br
   // ASF comman output error indications for emac
`ifndef gem_ext_fifo_interface
`ifdef gem_tx_pkt_buffer
   `ifdef gem_asf_ecc_sram
   wire         emac_asf_sram_corr_err;        // SRAM correctable error indication
   `endif
   `ifdef gem_asf_dap_prot
   wire         emac_asf_sram_uncorr_err;      // SRAM uncorrectable error indication
   `endif
`endif
`endif
   `ifdef gem_asf_integrity_prot
   wire         emac_asf_integrity_err;        // Integrity error indication
   `endif
   `ifdef gem_asf_dap_prot
   wire         emac_asf_dap_err;              // Data and Address Paths error indication
   `endif
   `ifdef gem_asf_csr_prot
   wire         emac_asf_csr_err;              // Configuration and Status Registers error indication
   `endif
   wire         emac_asf_trans_to_err;         // Transaction Timeouts indication
   wire         emac_asf_protocol_err;         // Protocol error indication
   `endif
   // ASF and fatal and non-fatal interrupts for emac
   wire         emac_asf_int_nonfatal;         // ASF non-fatal interrupt
   wire         emac_asf_int_fatal;            // ASF fatal interrupt


   // Other signals
   wire          hold;                    // signal to the MMSL that PMAC has to stop
   wire          ethernet_int;            // interrupt signal from DUT
   wire          ethernet_int_q1;         // interrupt signal from DUT
   wire          ethernet_int_q2;         // interrupt signal from DUT
   wire          ethernet_int_q3;         // interrupt signal from DUT
   wire          ethernet_int_q4;         // interrupt signal from DUT
   wire          ethernet_int_q5;         // interrupt signal from DUT
   wire          ethernet_int_q6;         // interrupt signal from DUT
   wire          ethernet_int_q7;         // interrupt signal from DUT
   wire          ethernet_int_q8;         // interrupt signal from DUT
   wire          ethernet_int_q9;         // interrupt signal from DUT
   wire          ethernet_int_q10;        // interrupt signal from DUT
   wire          ethernet_int_q11;        // interrupt signal from DUT
   wire          ethernet_int_q12;        // interrupt signal from DUT
   wire          ethernet_int_q13;        // interrupt signal from DUT
   wire          ethernet_int_q14;        // interrupt signal from DUT
   wire          ethernet_int_q15;        // interrupt signal from DUT
   wire          emac_ethernet_int;       // ethernet mac interrupt signal.
   wire          mmsl_int;                // MMSL interrupt pin
   `ifdef gem_user_io
   wire  [(`gem_user_out_width - 1):0]    // programmable user outputs to
                 user_out;                // top level
   wire  [(`gem_user_in_width - 1):0]     // programmable user inputs from
                 user_in;                 // top level
   `endif // gem_user_io
   wire          loop_clk_source;         // loopback clock
   wire          rx_clk_to_gem_c;
   wire          n_rx_clk_to_gem_c;
   wire          rx_clk_to_gem;           // rx clock into design
   wire          tx_clk_to_gem;           // tx clock into design
   wire          n_tx_clk_to_gem;         // inverted tx clock for loopback
   wire          gtx_clk_to_gem;          // pcs tx clk
   wire          gtx20_clk_to_gem;        // pcs tx clk
   wire          rbc0_to_gem;             // TBI receive clock from the PHY
   wire          rbc1_to_gem;             // TBI receive clock from the PHY
   wire          pcs_rx_clk_to_gem;       // 125MHz TBI receive clock
   wire          pcs_rx20_clk_to_gem;     // 62.5MHz TBI receive clock
   wire          n_txreset;               // tx_clk domain reset
   wire          n_gtxreset;              // gtx_clk domain reset
   wire          n_ntxreset;              // n_tx_clk domain reset
   wire          n_nrxreset;              // n_rx_clk domain reset
   wire          n_rxreset;               // rx_clk domain reset
   wire          n_rbc0reset;             // rbc0 domain reset
   wire          n_rbc1reset;             // rbc1 domain reset
   wire          n_clk_ctl_rst;           // reset to clock control block

   //Dummy stuff for Specman AHB eVC
   //master signals
   reg     [3:0] hmaster;                 // hmaster
   reg           hmastlock;               // current master has locked access
   wire   [15:0] hsplit;                  // split from each slave

   //slave signals
   wire          hsel;                    // tb slave select line

   //dummy master
   wire          hgrantdummy;             // grant for dummy master
   wire   [31:0] haddrdummy;              // address to write to
   wire    [1:0] htransdummy;             // transfer method
   wire          hwritedummy;             // read/write
   wire    [2:0] hsizedummy;              // transfer size
   wire    [2:0] hburstdummy;             // burst mode
   wire    [3:0] hprotdummy;              // Protection type - unused tied low
   wire   [31:0] hwdatadummy;             // Write data
   wire          hbusreqdummy;            // Bus request
   wire          hlockdummy;              // Lock the bus

   // Padded busses for 128-bit selection (129-bit avoids 0 length concat)
   wire  [128:0] hwdata_pad,wdata_pad;
   wire  [16:0] wstrb_pad;
   wire  [128:0] rx_w_data_pad;
   wire  [`edma_bus_width-1:0] hrdata_pad,rdata_pad;
   wire  [127:0] tx_r_data_pad;

   wire  dma_done;

  // Keep track of buffers writes
  integer rx_databuf_wr_q0_cnt;
  wire  [31:0] q0_data_val;
  reg     rx_databuf_wr_q0_str;
  wire    rx_databuf_wr_q0;
  wire    rx_databuf_wr_q0_edge;
 `ifdef dma_priority_queue1
  integer rx_databuf_wr_q1_cnt;
  wire  [31:0] q1_data_val;
  reg     rx_databuf_wr_q1_str;
  wire    rx_databuf_wr_q1_edge;
  wire    rx_databuf_wr_q1;
 `endif
 `ifdef dma_priority_queue2
  integer rx_databuf_wr_q2_cnt;
  wire  [31:0] q2_data_val;
  reg     rx_databuf_wr_q2_str;
  wire    rx_databuf_wr_q2_edge;
  wire    rx_databuf_wr_q2;
 `endif
 `ifdef dma_priority_queue3
  integer rx_databuf_wr_q3_cnt;
  wire  [31:0] q3_data_val;
  reg     rx_databuf_wr_q3_str;
  wire    rx_databuf_wr_q3_edge;
  wire    rx_databuf_wr_q3;
 `endif
 `ifdef dma_priority_queue4
  integer rx_databuf_wr_q4_cnt;
  wire  [31:0] q4_data_val;
  reg     rx_databuf_wr_q4_str;
  wire    rx_databuf_wr_q4_edge;
  wire    rx_databuf_wr_q4;
 `endif
 `ifdef dma_priority_queue5
  integer rx_databuf_wr_q5_cnt;
  wire  [31:0] q5_data_val;
  reg     rx_databuf_wr_q5_str;
  wire    rx_databuf_wr_q5_edge;
  wire    rx_databuf_wr_q5;
 `endif
 `ifdef dma_priority_queue6
  integer rx_databuf_wr_q6_cnt;
  wire  [31:0] q6_data_val;
  reg     rx_databuf_wr_q6_str;
  wire    rx_databuf_wr_q6_edge;
  wire    rx_databuf_wr_q6;
 `endif
 `ifdef dma_priority_queue7
  integer rx_databuf_wr_q7_cnt;
  wire  [31:0] q7_data_val;
  reg     rx_databuf_wr_q7_str;
  wire    rx_databuf_wr_q7_edge;
  wire    rx_databuf_wr_q7;
 `endif
 `ifdef dma_priority_queue8
  integer rx_databuf_wr_q8_cnt;
  wire  [31:0] q8_data_val;
  reg     rx_databuf_wr_q8_str;
  wire    rx_databuf_wr_q8_edge;
  wire    rx_databuf_wr_q8;
 `endif
 `ifdef dma_priority_queue9
  integer rx_databuf_wr_q9_cnt;
  wire  [31:0] q9_data_val;
  reg     rx_databuf_wr_q9_str;
  wire    rx_databuf_wr_q9_edge;
  wire    rx_databuf_wr_q9;
 `endif
 `ifdef dma_priority_queue10
  integer rx_databuf_wr_q10_cnt;
  wire  [31:0] q10_data_val;
  reg     rx_databuf_wr_q10_str;
  wire    rx_databuf_wr_q10_edge;
  wire    rx_databuf_wr_q10;
 `endif
 `ifdef dma_priority_queue11
  integer rx_databuf_wr_q11_cnt;
  wire  [31:0] q11_data_val;
  reg     rx_databuf_wr_q11_str;
  wire    rx_databuf_wr_q11_edge;
  wire    rx_databuf_wr_q11;
 `endif
 `ifdef dma_priority_queue12
  integer rx_databuf_wr_q12_cnt;
  wire  [31:0] q12_data_val;
  reg     rx_databuf_wr_q12_str;
  wire    rx_databuf_wr_q12_edge;
  wire    rx_databuf_wr_q12;
 `endif
 `ifdef dma_priority_queue13
  integer rx_databuf_wr_q13_cnt;
  wire  [31:0] q13_data_val;
  reg     rx_databuf_wr_q13_str;
  wire    rx_databuf_wr_q13_edge;
  wire    rx_databuf_wr_q13;
 `endif
 `ifdef dma_priority_queue14
  integer rx_databuf_wr_q14_cnt;
  wire  [31:0] q14_data_val;
  reg     rx_databuf_wr_q14_str;
  wire    rx_databuf_wr_q14_edge;
  wire    rx_databuf_wr_q14;
 `endif
 `ifdef dma_priority_queue15
  integer rx_databuf_wr_q15_cnt;
  wire  [31:0] q15_data_val;
  reg     rx_databuf_wr_q15_str;
  wire    rx_databuf_wr_q15_edge;
  wire    rx_databuf_wr_q15;
 `endif

  reg        rgmii_tx_clk_sig_to_dut;
  wire       n_rx_clk_to_gem;
  wire [3:0] rgmii_txd;
  wire       rgmii_tx_ctl;
  wire [3:0] rgmii_rxd;
  wire       rgmii_rx_ctl;
  wire       rgmii_link_status;     // rgmii extracted link status
  wire [1:0] rgmii_speed;           // rgmii extracted speed status
  wire       rgmii_duplex_out;      // rgmii extracted duplex status

  reg wr_tog_fail;
  reg flow_ctrl_done;

  reg    [31:0] q0_data [0:0];     // define maximum size of the command file
  reg    [31:0] q1_data [0:0];     // define maximum size of the command file
  reg    [31:0] q2_data [0:0];     // define maximum size of the command file
  reg    [31:0] q3_data [0:0];     // define maximum size of the command file
  reg    [31:0] q4_data [0:0];     // define maximum size of the command file
  reg    [31:0] q5_data [0:0];     // define maximum size of the command file
  reg    [31:0] q6_data [0:0];     // define maximum size of the command file
  reg    [31:0] q7_data [0:0];     // define maximum size of the command file
  reg    [31:0] q8_data [0:0];     // define maximum size of the command file
  reg    [31:0] q9_data [0:0];     // define maximum size of the command file
  reg    [31:0] q10_data [0:0];     // define maximum size of the command file
  reg    [31:0] q11_data [0:0];     // define maximum size of the command file
  reg    [31:0] q12_data [0:0];     // define maximum size of the command file
  reg    [31:0] q13_data [0:0];     // define maximum size of the command file
  reg    [31:0] q14_data [0:0];     // define maximum size of the command file
  reg    [31:0] q15_data [0:0];     // define maximum size of the command file

  integer q0_cycle_cnt;
  integer q1_cycle_cnt;
  integer q2_cycle_cnt;
  integer q3_cycle_cnt;
  integer q4_cycle_cnt;
  integer q5_cycle_cnt;
  integer q6_cycle_cnt;
  integer q7_cycle_cnt;
  integer q8_cycle_cnt;
  integer q9_cycle_cnt;
  integer q10_cycle_cnt;
  integer q11_cycle_cnt;
  integer q12_cycle_cnt;
  integer q13_cycle_cnt;
  integer q14_cycle_cnt;
  integer q15_cycle_cnt;
  reg    min_toggle_time_fail;
  reg     q0_first_tog;
  reg     q1_first_tog;
  reg     q2_first_tog;
  reg     q3_first_tog;
  reg     q4_first_tog;
  reg     q5_first_tog;
  reg     q6_first_tog;
  reg     q7_first_tog;
  reg     q8_first_tog;
  reg     q9_first_tog;
  reg     q10_first_tog;
  reg     q11_first_tog;
  reg     q12_first_tog;
  reg     q13_first_tog;
  reg     q14_first_tog;
  reg     q15_first_tog;

  parameter MIN_TOGGLE_TIME_FAIL = 7;

   initial
      begin                                    // read text file cmd_data
         $readmemh("./files/tb_buf_cntq0.data", q0_data);
         $readmemh("./files/tb_buf_cntq1.data", q1_data);
         $readmemh("./files/tb_buf_cntq2.data", q2_data);
         $readmemh("./files/tb_buf_cntq3.data", q3_data);
         $readmemh("./files/tb_buf_cntq4.data", q4_data);
         $readmemh("./files/tb_buf_cntq5.data", q5_data);
         $readmemh("./files/tb_buf_cntq6.data", q6_data);
         $readmemh("./files/tb_buf_cntq7.data", q7_data);
         $readmemh("./files/tb_buf_cntq8.data", q8_data);
         $readmemh("./files/tb_buf_cntq9.data", q9_data);
         $readmemh("./files/tb_buf_cntq10.data", q10_data);
         $readmemh("./files/tb_buf_cntq11.data", q11_data);
         $readmemh("./files/tb_buf_cntq12.data", q12_data);
         $readmemh("./files/tb_buf_cntq13.data", q13_data);
         $readmemh("./files/tb_buf_cntq14.data", q14_data);
         $readmemh("./files/tb_buf_cntq15.data", q15_data);
      end

   // RMII signals
   wire          mii_select;           // selects mii (1) or rmii (0)
   wire    [1:0] txd_rmii;
   wire    [1:0] rxd_rmii;
   wire          rmii_ref_clk;
   wire          n_rmii_ref_reset;
   wire          tx_en_rmii;
   wire          rx_er_rmii;
   wire          crs_dv_rmii;

   // SRAM READ Addresses (for checking ECC fault location)
   wire       [`edma_rx_pbuf_addr-1:0] rx_sram_read_add;
   wire       [`edma_tx_pbuf_addr-1:0] tx_sram_read_add;

   wire          fault_sim_for_dc_en;
   wire          double_error_injection;
   wire          single_error_injection;
   wire [19:0]   num_sram_errors_to_inject;
   wire          test_ending;

   wire          amba_par_err_inj;

//------------------------------------------------------------------------------
// test bench assignments
//------------------------------------------------------------------------------

   // Dummy stuff for Specman
   assign hsplit = 16'h0000;
   assign hsel   = 1'b1;

   // Decode speed and interface currently being used
   `ifdef xgm
      assign {two_pt_five_gig, tbi, gigabit, speed} = 4'b0000;
   `else
      assign {two_pt_five_gig, tbi, gigabit, speed} = speed_mode;
   `endif

   // If using external FIFO, tie off unused pins to safe level for testbench
   `ifdef gem_ext_fifo_interface
   assign htrans     = 2'b0;
   assign hbusreqdma = 1'b0;
   assign hlockdma   = 1'b0;
   assign hburst     = 3'b000;
   assign hprot      = `edma_hprot_value;
   assign hwdata     = {`edma_bus_width{1'b0}};
   assign haddr      = 32'b0;
   assign hwrite     = 1'b0;
   assign hsize      = 3'b010;
   `endif // gem_ext_fifo_interface

   // If PCS is removed from design then tie off outputs from GEM
   `ifdef gem_no_pcs
   assign tx_group   = 10'h000;
   assign ewrap      = 1'b0;
   assign en_cdet    = 1'b0;
   `endif // gem_no_pcs

   // If loopback mode is not being used then tie loopback_local low.
   `ifdef gem_int_loopback
   `else // if not gem_int_loopback
   assign loopback_local = 1'b0;
   `endif // gem_int_loopback


   // Padded busses
   `ifdef edma_axi
   assign wdata_pad    = {{129-`edma_bus_width{1'b0}}, wdata};
   assign wstrb_pad    = {{17-(`edma_bus_width/8){1'b0}}, wstrb};
   assign rdata_pad    = rdata[`edma_bus_width-1:0];
   `else
   assign hwdata_pad    = {{129-`edma_bus_width{1'b0}}, hwdata};
   assign hrdata_pad    = hrdata[`edma_bus_width-1:0];
   `endif
   assign rx_w_data_pad = {{129-`emac_bus_width{1'b0}}, rx_w_data};
   `ifdef gem_fifo_8b_if
   assign tx_r_data = tx_r_data_pad[7:0];
   `else
   assign tx_r_data = tx_r_data_pad[`emac_bus_width-1:0];
   `endif


   // XGM doesn't have the dma_bus_width output so probe down
   // into the hierarchy to get it.
   `ifdef xgm
      assign dma_bus_width = i_xgm.i_xgm_edma_wrapper.i_edma_top.dma_bus_width;
   `endif

   // The xgm design doesn't use these pins so simpy tie them off to a default
   // level.
   `ifdef xgm
      assign loopback = 1'b0;
      assign half_duplex = 1'b0;
   `endif


//------------------------------------------------------------------------------
// ASF Specific
//------------------------------------------------------------------------------
`ifdef gem_tsu
  `ifdef gem_asf_dap_prot
    wire  [11:0]  tsu_timer_cnt_par;  // Optional parity  TODO check
    wire  [11:0]  ext_tsu_timer_par;  // Optional parity input
  `endif
`endif

`ifdef edma_asf_host_par
  wire  [1:0]   paddr_int_par;
  wire  [3:0]   prdata_par;       // TODO check

  `ifdef gem_has_802p3_br
  assign paddr_int_par  = {^{3'h0,paddr_int[12:8]},^{paddr_int[7:2],2'h0}};
  `else
  assign paddr_int_par  = {^{4'h0,paddr_int[11:8]},^{paddr_int[7:2],2'h0}};
  `endif

  `ifdef edma_axi
  wire  [(`edma_addr_width/8)-1:0]  awaddr_par; // TODO check
  wire  [(`edma_bus_width/8)-1:0]   wdata_par;  // TODO check
  wire  [(`edma_addr_width/8)-1:0]  araddr_par; // TODO check
  wire  [15:0]                      rdata_par;

  assign rdata_par  = {^rdata[127:120],^rdata[119:112],
                        ^rdata[111:104],^rdata[103:96],
                        ^rdata[95:88],^rdata[87:80],
                        ^rdata[79:72],^rdata[71:64],
                        ^rdata[63:56],^rdata[55:48],
                        ^rdata[47:40],^rdata[39:32],
                        ^rdata[31:24],^rdata[23:16],
                        ^rdata[15:8],^rdata[7:0]} ^ {16{amba_par_err_inj}};
  `endif

`endif

  // Probe some internal signals that we will use for assertion checking
  // to make sure the internal ASF errors do not trigger unless we are
  // doing some form of fault testing.
  wire  asf_pclk;
  wire  asf_n_preset;
  wire  pmac_asf_csr_pcs_err;             // There was a parity error in PCS reg
  wire  pmac_asf_csr_mmsl_err;            // There was a parity error in MMSL reg
  wire  pmac_asf_dap_paddr_err;           // Parity check error on paddr
  wire  pmac_asf_dap_pcs_tx_err;          // Fault in PCS TX datapath
  wire  pmac_asf_dap_pcs_rx_err;          // Fault in PCS RX datapath

  wire  asf_tx_clk;
  wire  asf_n_txreset;
  wire  pmac_asf_dap_mmsl_tx_err;         // Fault in MMSL TX datapath
  wire  pmac_asf_dap_txclk_err;           // Parity error in tx clock domain

  wire  asf_rx_clk;
  wire  asf_n_rxreset;
  wire  pmac_asf_dap_mmsl_rx_err;         // Fault in MMSL RX datapath
  wire  pmac_asf_dap_rxclk_err;           // Parity error in rx clock domain

  wire  asf_tx_r_clk;
  wire  asf_n_tx_r_reset;
  reg   pmac_asf_sram_tx_corr_err;        // Correctable error for TX SRAM
  reg   pmac_asf_sram_tx_uncorr_err;      // Uncorrectable error for TX SRAM
  wire  pmac_asf_integrity_tx_sched_err;  // Fault detected in Transmit Scheduling

  wire  asf_dma_clk;
  wire  asf_n_dma_reset;
  reg   pmac_asf_sram_rx_corr_err;        // Correctable error for RX SRAM
  reg   pmac_asf_sram_rx_uncorr_err;      // Uncorrectable error for RX SRAM
  wire  pmac_asf_dap_dma_err;             // Parity error in DMA domain
  wire  pmac_asf_integrity_dma_err;       // Integrity fault detected in DMA
  wire  pmac_asf_host_trans_to_err;       // Host transaction timeout

  wire  asf_tsu_clk;
  wire  asf_n_tsureset;
  wire  pmac_asf_integrity_tsu_err;       // Fault detected in TSU protection

  // Probe into the design for these signals
  // Note that the probes point to the gem_reg_top hierarchy as all the
  // I/O are always present and tied off appropriately if not supported.

  // Only looking at ASF signals in RTL simulations (not GL)
`ifdef rtl
  `define PMAC_REG_TOP  i_gem_gxl.i_gem_ss.i_gem_top.i_gem_reg_top
  assign asf_pclk                         = `PMAC_REG_TOP.pclk;
  assign asf_n_preset                     = `PMAC_REG_TOP.n_preset;

// synthesis cut those wires off if they are connected to zero i.e. when features not available
`ifdef gem_no_pcs
  assign pmac_asf_csr_pcs_err             = 1'b0;
  assign pmac_asf_dap_pcs_tx_err          = 1'b0;
  assign pmac_asf_dap_pcs_rx_err          = 1'b0;
`else
  assign pmac_asf_csr_pcs_err             = `PMAC_REG_TOP.asf_csr_pcs_err;
  assign pmac_asf_dap_pcs_tx_err          = `PMAC_REG_TOP.asf_dap_pcs_tx_err;
  assign pmac_asf_dap_pcs_rx_err          = `PMAC_REG_TOP.asf_dap_pcs_rx_err;
`endif
`ifdef gem_has_802p3_br
  assign pmac_asf_csr_mmsl_err            = `PMAC_REG_TOP.asf_csr_mmsl_err;
`else
  assign pmac_asf_csr_mmsl_err            = 1'b0;
`endif
`ifdef gem_asf_host_par
  assign pmac_asf_dap_paddr_err           = `PMAC_REG_TOP.asf_dap_paddr_err;
`else
  assign pmac_asf_dap_paddr_err           = 1'b0;
`endif



  assign asf_tx_clk                       = `PMAC_REG_TOP.tx_clk;
  assign asf_n_txreset                    = `PMAC_REG_TOP.n_txreset;
  assign pmac_asf_dap_mmsl_tx_err         = `PMAC_REG_TOP.asf_dap_mmsl_tx_err;
  assign pmac_asf_dap_txclk_err           = `PMAC_REG_TOP.asf_dap_txclk_err;

  assign asf_rx_clk                       = `PMAC_REG_TOP.rx_clk;
  assign asf_n_rxreset                    = `PMAC_REG_TOP.n_rxreset;
  assign pmac_asf_dap_mmsl_rx_err         = `PMAC_REG_TOP.asf_dap_mmsl_rx_err;
  assign pmac_asf_dap_rxclk_err           = `PMAC_REG_TOP.asf_dap_rxclk_err;

`ifdef edma_spram
  assign asf_tx_r_clk                     = `PMAC_REG_TOP.hclk;
  assign asf_n_tx_r_reset                 = `PMAC_REG_TOP.n_hreset;
`else
  assign asf_tx_r_clk                     = `PMAC_REG_TOP.tx_clk;
  assign asf_n_tx_r_reset                 = `PMAC_REG_TOP.n_txreset;
`endif
  always@(posedge asf_tx_r_clk)
    pmac_asf_sram_tx_corr_err             = `PMAC_REG_TOP.tx_corr_err;
  always@(posedge asf_tx_r_clk)
    pmac_asf_sram_tx_uncorr_err    = `PMAC_REG_TOP.tx_uncorr_err;
// synthesis cut those wires off if they are connected to zero i.e. when features not available
`ifdef gem_asf_prot_tx_sched
  assign pmac_asf_integrity_tx_sched_err  = `PMAC_REG_TOP.asf_integrity_tx_sched_err;
`else
  assign pmac_asf_integrity_tx_sched_err  = 1'b0;
`endif


  assign asf_dma_clk                      = `PMAC_REG_TOP.hclk;
  assign asf_n_dma_reset                  = `PMAC_REG_TOP.n_hreset;
  always@(posedge asf_dma_clk)
    pmac_asf_sram_rx_corr_err      = `PMAC_REG_TOP.rx_corr_err;
  always@(posedge asf_dma_clk)
    pmac_asf_sram_rx_uncorr_err    = `PMAC_REG_TOP.rx_uncorr_err;
  assign pmac_asf_dap_dma_err             = `PMAC_REG_TOP.asf_dap_dma_err;
  assign pmac_asf_integrity_dma_err       = `PMAC_REG_TOP.asf_integrity_dma_err;
  assign pmac_asf_host_trans_to_err       = `PMAC_REG_TOP.asf_host_trans_to_err;

`ifdef edma_tsu_clk
  assign asf_tsu_clk                      = `PMAC_REG_TOP.tsu_clk;
  assign asf_n_tsureset                   = `PMAC_REG_TOP.n_tsureset;
`else
  assign asf_tsu_clk                      = `PMAC_REG_TOP.pclk;
  assign asf_n_tsureset                   = `PMAC_REG_TOP.n_preset;
`endif
  assign pmac_asf_integrity_tsu_err       = `PMAC_REG_TOP.asf_integrity_tsu_err;

// Similarly for checking the internal transaction and lockup detect counters which
// we should check are 0 at the end of test...
  wire  [4:0] pmac_axi_trans_rcnt;
  wire  [4:0] pmac_axi_trans_wcnt;
  wire  [4:0] emac_axi_trans_rcnt;
  wire  [4:0] emac_axi_trans_wcnt;
  wire        pmac_ahb_xfer_in_prg;
  wire        emac_ahb_xfer_in_prg;
  wire  [7:0] pmac_dma_rx_lu_pkt_cnt;
  wire [15:0] pmac_dma_tx_lu1_in_prg;
  wire  [7:0] pmac_dma_tx_lu_pkt_cnt[15:0];

  // Pull in some useful parameters
  parameter p_edma_queues = `edma_queues;
`ifdef gem_asf_trans_to_prot
  parameter p_edma_asf_trans_to_prot  = 1'b1;
`else
  parameter p_edma_asf_trans_to_prot  = 1'b0;
`endif
`ifdef edma_tx_pkt_buffer
  parameter p_edma_tx_pkt_buffer   = 1'b1;
`else
  parameter p_edma_tx_pkt_buffer   = 1'b0;
`endif
`ifdef edma_has_802p3_br
  parameter p_edma_has_br          = 1'b1;
`else
  parameter p_edma_has_br          = 1'b0;
`endif
`ifdef edma_axi
  parameter p_edma_axi = 1'b1;
`else
  parameter p_edma_axi = 1'b0;
`endif

generate if ((p_edma_asf_trans_to_prot == 1'b1) && (p_edma_tx_pkt_buffer == 1'b1)) begin : gen_con_trans_to
`ifdef rtl
  initial
  begin
    force i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.trans_to_en_s     = 1'b1;
    force i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.trans_to_timeval  = 16'd3000;
    @(posedge i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.trans_to_en);
    release i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.trans_to_en_s;
    release i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.trans_to_timeval;
  end
  if (p_edma_axi == 1'b1) begin : gen_axi
    assign pmac_axi_trans_rcnt  = i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.gen_axi.i_r_to.count;
    assign pmac_axi_trans_wcnt  = i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.gen_axi.i_w_to.count;
    assign pmac_ahb_xfer_in_prg = 1'b0;
  end else begin : gen_ahb
    assign pmac_axi_trans_rcnt  = 5'h0;
    assign pmac_axi_trans_wcnt  = 5'h0;
    assign pmac_ahb_xfer_in_prg = i_gem_gxl.i_gem_ss.gen_trans_to_prot.i_trans_to.gen_ahb.xfer_in_prg;
  end
  if (p_edma_has_br == 1'b1) begin : gen_br
    initial
    begin
      force i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.trans_to_en_s    = 1'b1;
      force i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.trans_to_timeval = 16'd3000;
      @(posedge i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.trans_to_en);
      release i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.trans_to_en_s;
      release i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.trans_to_timeval;
    end
    if (p_edma_axi == 1'b1) begin : gen_axi
      assign emac_axi_trans_rcnt  = i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.gen_axi.i_r_to.count;
      assign emac_axi_trans_wcnt  = i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.gen_axi.i_w_to.count;
      assign emac_ahb_xfer_in_prg = 1'b0;
    end else begin : gen_ahb
      assign emac_axi_trans_rcnt  = 5'h0;
      assign emac_axi_trans_wcnt  = 5'h0;
      assign emac_ahb_xfer_in_prg = i_gem_gxl.i_gem_ss.gen_has_802p3_br.gen_trans_to_prot.i_trans_to.gen_ahb.xfer_in_prg;
    end
  end else begin : gen_no_br
    assign emac_axi_trans_rcnt  = 5'h0;
    assign emac_axi_trans_wcnt  = 5'h0;
    assign emac_ahb_xfer_in_prg = 1'b0;
  end
`else
  assign pmac_axi_trans_rcnt  = 5'h0;
  assign pmac_axi_trans_wcnt  = 5'h0;
  assign pmac_ahb_xfer_in_prg = 1'b0;
  assign emac_axi_trans_rcnt  = 5'h0;
  assign emac_axi_trans_wcnt  = 5'h0;
  assign emac_ahb_xfer_in_prg = 1'b0;
`endif
end else begin : gen_no_con_trans_to
  assign pmac_axi_trans_rcnt  = 5'h0;
  assign pmac_axi_trans_wcnt  = 5'h0;
  assign pmac_ahb_xfer_in_prg = 1'b0;
  assign emac_axi_trans_rcnt  = 5'h0;
  assign emac_axi_trans_wcnt  = 5'h0;
  assign emac_ahb_xfer_in_prg = 1'b0;
end
endgenerate


// Similarly for lockup detect
genvar gen_loop1;
generate if (p_edma_tx_pkt_buffer == 1'b1 && p_rtl_sim == 1'b1) begin : gen_con_lockup_det
  // Must be careful of various corner case tests which are technically illegal but causes problems
  // for the packet counting. When these features are enabled, the packet counting must be disabled.
  initial
  begin
    force `hier_pbuf_lockup_det.tx_lockup_mon_en_s = 1'b1;
    @(posedge `hier_pbuf_lockup_det.tx_cutthru);
    release `hier_pbuf_lockup_det.tx_lockup_mon_en_s;
  end
  initial
  begin
    force `hier_pbuf_lockup_det.rx_lockup_mon_en_s = 1'b1;
    @(posedge (`hier_pbuf_lockup_det.rsc_en |
                `hier_pbuf_lockup_det.rx_cutthru));
    release `hier_pbuf_lockup_det.rx_lockup_mon_en_s;
  end
  assign pmac_dma_rx_lu_pkt_cnt     = `hier_pbuf_lockup_det.i_rx_lockup_det.i_lu2_timer.count;
  for (gen_loop1 = 0; gen_loop1<16; gen_loop1=gen_loop1+1) begin : gen_misc1
    if (gen_loop1 < p_edma_queues) begin : gen_exist
      assign pmac_dma_tx_lu_pkt_cnt[gen_loop1]  = `hier_pbuf_lockup_det.i_tx_lockup_det[gen_loop1].i_lu2_timer.count;
      assign pmac_dma_tx_lu1_in_prg[gen_loop1]  = `hier_pbuf_lockup_det.i_tx_lockup_det[gen_loop1].i_lu1_timer.timer_active;
    end else begin : gen_no_exist
      assign pmac_dma_tx_lu_pkt_cnt[gen_loop1]  = 8'h00;
      assign pmac_dma_tx_lu1_in_prg[gen_loop1]  = 1'b0;
    end
  end
end else begin : gen_no_con_lockup_det
  assign pmac_dma_rx_lu_pkt_cnt     = 8'h00;
  for (gen_loop1 = 0; gen_loop1<16; gen_loop1=gen_loop1+1) begin : gen_misc1
    assign pmac_dma_tx_lu_pkt_cnt[gen_loop1]  = 8'h00;
    assign pmac_dma_tx_lu1_in_prg[gen_loop1]  = 1'b0;
  end
end
endgenerate


  // Make sure everything is empty at end of test for transaction/lockup detection
  wire  trans_to_idle;
  wire  lu_det_idle;
  assign trans_to_idle  = (pmac_axi_trans_rcnt == 5'd0) && (pmac_axi_trans_wcnt == 5'd0) &&
                          (emac_axi_trans_rcnt == 5'd0) && (emac_axi_trans_wcnt == 5'd0) &&
                          ~pmac_ahb_xfer_in_prg && ~emac_ahb_xfer_in_prg;
  assign lu_det_idle    = (pmac_dma_rx_lu_pkt_cnt == 8'd0) && (pmac_dma_tx_lu1_in_prg == 16'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[0] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[1] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[2] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[3] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[4] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[5] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[6] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[7] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[8] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[9] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[10] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[11] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[12] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[13] == 8'd0) &&
                          (pmac_dma_tx_lu_pkt_cnt[14] == 8'd0) && (pmac_dma_tx_lu_pkt_cnt[15] == 8'd0);

//  `define IFSS_FAULT_SIM_DIS_ASF_ASSERTIONS
`ifdef ABV_ON
  `ifndef IFSS_FAULT_SIM_DIS_ASF_ASSERTIONS
  wire  disable_asf_assert;
  assign disable_asf_assert = double_error_injection | fault_sim_for_dc_en;

  // Assertion to make sure the lockup and transaction counters are ok at end of test.
  property end_of_test_idle_chk;
    @(posedge test_ending)
      (trans_to_idle & lu_det_idle);
  endproperty
  AP_end_of_test_idle_chk : assert property (end_of_test_idle_chk);

  // Some assertions to make sure the raw ASF triggers are never set to anything
  // other than zero. All assertions disabled based on n_preset.

  // pclk domain
  property asf_no_err_pclk;
    @(posedge asf_pclk) disable iff ((asf_n_preset != 1'b1) || (disable_asf_assert == 1'b1))
      (pmac_asf_csr_pcs_err     === 1'b0) &&
      (pmac_asf_csr_mmsl_err    === 1'b0) &&
      (pmac_asf_dap_paddr_err   === 1'b0) &&
      (pmac_asf_dap_pcs_tx_err  === 1'b0) &&
      (pmac_asf_dap_pcs_rx_err  === 1'b0);
  endproperty
  AP_asf_no_err_pclk : assert property (asf_no_err_pclk);

  // tx_clk domain
  property asf_no_err_tx_clk;
    @(posedge asf_tx_clk) disable iff ((asf_n_txreset != 1'b1) || (disable_asf_assert == 1'b1))
      (pmac_asf_dap_mmsl_tx_err === 1'b0) &&
      (pmac_asf_dap_txclk_err   === 1'b0);
  endproperty
  AP_asf_no_err_tx_clk : assert property (asf_no_err_tx_clk);

  // rx_clk domain
  property asf_no_err_rx_clk;
    @(posedge asf_rx_clk) disable iff ((asf_n_rxreset != 1'b1) || (disable_asf_assert == 1'b1))
      (pmac_asf_dap_mmsl_rx_err === 1'b0) &&
      (pmac_asf_dap_rxclk_err   === 1'b0);
  endproperty
  AP_asf_no_err_rx_clk : assert property (asf_no_err_rx_clk);

  // tx_r_clk domain
  property asf_no_err_tx_r_clk;
    @(posedge asf_tx_r_clk) disable iff ((asf_n_tx_r_reset != 1'b1) || (disable_asf_assert == 1'b1))
      (pmac_asf_sram_tx_uncorr_err      === 1'b0) &&
      (pmac_asf_integrity_tx_sched_err  === 1'b0);
  endproperty
  AP_asf_no_err_tx_r_clk : assert property (asf_no_err_tx_r_clk);

  property asf_no_corr_err_tx_r_clk;
    @(posedge asf_tx_r_clk) disable iff ((asf_n_tx_r_reset != 1'b1) || (disable_asf_assert == 1'b1) || (single_error_injection == 1'b1))
      (pmac_asf_sram_tx_corr_err        === 1'b0);
  endproperty
  AP_asf_no_corr_err_tx_r_clk : assert property (asf_no_corr_err_tx_r_clk);

  // DMA domain
  property asf_no_err_dma_clk;
    @(posedge asf_dma_clk) disable iff ((asf_n_dma_reset != 1'b1) || (disable_asf_assert == 1'b1))
      (pmac_asf_sram_rx_uncorr_err  === 1'b0) &&
      (pmac_asf_dap_dma_err         === 1'b0) &&
      (pmac_asf_integrity_dma_err   === 1'b0);
  endproperty
  AP_asf_no_err_dma_clk : assert property (asf_no_err_dma_clk);

  property asf_no_corr_err_dma_clk;
    @(posedge asf_dma_clk) disable iff ((asf_n_dma_reset != 1'b1) || (disable_asf_assert == 1'b1) || (single_error_injection == 1'b1))
      (pmac_asf_sram_rx_corr_err    === 1'b0);
  endproperty
  AP_asf_no_corr_err_dma_clk : assert property (asf_no_corr_err_dma_clk);

  // TSU domain
  property asf_no_err_tsu_clk;
    @(posedge asf_tsu_clk) disable iff ((asf_n_tsureset != 1'b1) || (disable_asf_assert == 1'b1))
      (pmac_asf_integrity_tsu_err === 1'b0);
  endproperty
  AP_asf_no_err_tsu_clk : assert property (asf_no_err_tsu_clk);

  `endif  // IFSS_FAULT_SIM_DIS_ASF_ASSERTIONS
`endif  // ABV_ON

`endif // ignore all of above for GL sims

wire  ifss_dis_x_drv;
`ifdef IFSS_FAULT_SIM_DIS_ASF_ASSERTIONS
  parameter p_ram_inactive_val  = 1'b0;
  assign ifss_dis_x_drv = 1'b1;
`else
  parameter p_ram_inactive_val  = 1'bx;
  assign ifss_dis_x_drv = 1'b0;
`endif


//------------------------------------------------------------------------------
// test bench instance
//------------------------------------------------------------------------------


   tb_top i_tb_top(

   // reset signals
   .n_txreset(n_txreset),
   .n_gtxreset(n_gtxreset),
   .n_ntxreset(n_ntxreset),
   .n_nrxreset(n_nrxreset),
//   .n_ntxreset(n_ntxreset_int),
//   .n_nrxreset(n_nrxreset_int),
   .n_rxreset(n_rxreset),
   .n_rbc0reset(n_rbc0reset),
   .n_rbc1reset(n_rbc1reset),
   .n_clk_ctl_rst(n_clk_ctl_rst),

   // ethernet signals
   .col(col_tb),
   .crs(crs_tb),
   .tx_er(tx_er_tb2),
   `ifdef xgm
   .txd(txd),
   .txc(txc),
   .rxd(rxd),
   .rxc(rxc),
   `else
   .txd(txd[7:0]),
   .rxd(rxd[7:0]),
   `endif
   .tx_en(tx_en),
   .tx_clk_from_phy(tx_clk_from_phy),
   .tx_clk_to_gem(tx_clk_to_gem),
   .n_tx_clk_to_gem(n_tx_clk_to_gem),
   .n_rx_clk_to_gem(n_rx_clk_to_gem),
   .rx_er(rx_er),
   .rx_clk_from_phy(rx_clk_from_phy),
   .rx_clk_to_gem(rx_clk_to_gem),
   .rx_dv(rx_dv),
   .mdc(mdc),
   .mdio_in(mdio_in),
   .mdio_out(mdio_out),
   .mdio_en(mdio_en),
   .loopback(loopback),
   .half_duplex(half_duplex),
   .two_pt_five_gig(two_pt_five_gig),
   .gigabit(gigabit),
   .tbi(tbi),
   .speed(speed),
   .ext_interrupt_in(ext_interrupt_in),
   .tx_pause(tx_pause),
   .tx_pause_zero(tx_pause_zero),
   .tx_pfc_sel(tx_pfc_sel),
   .tx_pfc_pause(tx_pfc_pause),
   .tx_pfc_pause_zero(tx_pfc_pause_zero),
   .wol(wol),
   .tx_group(tx_group),
   .rx_group(rx_group),
   .ewrap(ewrap),
   .en_cdet(en_cdet),
   .signal_detect(signal_detect),
   .rbc0_from_phy(rbc0_from_phy),
   .rbc1_from_phy(rbc1_from_phy),
   .gtx_ref_clk(gtx_ref_clk),
   .gtx20_ref_clk(gtx20_ref_clk),
   .n_gtx20reset(n_gtx20reset),
   .loop_clk_source(loop_clk_source),

   `ifdef edma_tx_pkt_buffer
   .trigger_dma_tx_start(trigger_dma_tx_start),
   `endif
   .pcs_cal_bypass(pcs_cal_bypass),
   .pcs_cgalign_bypass(pcs_cgalign_bypass),

   // serdes signals
   .pma_rx_clk(pma_rx_clk),
   .n_prxreset(n_prxreset),
   .pma_rx20_clk(pma_rx20_clk),
   .n_pmarx20reset(n_pmarx20reset),

   // external filter interface
   .ext_match1(ext_match1),
   .ext_match2(ext_match2),
   .ext_match3(ext_match3),
   .ext_match4(ext_match4),
   .ext_da(ext_da),
   .ext_da_stb(ext_da_stb),
   .ext_sa(ext_sa),
   .ext_sa_stb(ext_sa_stb),
   .ext_type(ext_type),
   .ext_type_stb(ext_type_stb),
   .ext_vid(ext_vlan_tag1[15:0]),
   .ext_vid_stb(ext_vlan_tag1_stb),
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

   // precision time protocol signals for IEEE 1588 support
   .sof_tx         (sof_tx),
   .sync_frame_tx  (sync_frame_tx),
   .delay_req_tx   (delay_req_tx),
   .pdelay_req_tx  (pdelay_req_tx),
   .pdelay_resp_tx (pdelay_resp_tx),
   .sof_rx         (sof_rx),
   .sync_frame_rx  (sync_frame_rx),
   .delay_req_rx   (delay_req_rx),
   .pdelay_req_rx  (pdelay_req_rx),
   .pdelay_resp_rx (pdelay_resp_rx),
   `ifdef edma_tsu
   .edma_tsu_inc_ctrl(edma_tsu_inc_ctrl),
   .edma_tsu_ms(edma_tsu_ms),
   .tsu_timer_cmp_val(tsu_timer_cmp_val),
   `endif // edma_tsu
   .tsu_clk(tsu_clk),
   .n_tsureset(n_tsureset),

   // APB interface signals
   .pclk_source(pclk_source),
   .n_preset(n_preset),
   .paddr(paddr),
   .prdata(prdata),
   .pwdata(pwdata),
   .pwdata_par(pwdata_par),
   .pwrite(pwrite),
   .penable(penable),
   .psel(psel),
   .perr(perr),

   // AHB interface signals
   .hclk_source(hclk_source),
   .n_hreset(n_hreset),
   .dma_bus_width(dma_bus_width),


   `ifdef edma_axi
   .awid                    (awid),
   .awaddr                  (awaddr),
   .awlen                   (awlen),
   .awsize                  (awsize),
   .awburst                 (awburst),
   .awlock                  (awlock),
   .awcache                 (awcache),
   .awprot                  (awprot),
   .awqos                   (awqos),
   .awvalid                 (awvalid),
   .awready                 (awready),
   .wdata                   (wdata_pad[127:0]),
   .wstrb                   (wstrb_pad[15:0]),
   .wlast                   (wlast),
   .wready                  (wready),
   .wvalid                  (wvalid),
   .bid                     (bid),
   .bresp                   (bresp),
   .bvalid                  (bvalid),
   .bready                  (bready),
   .arid                    (arid),
   .araddr                  (araddr),
   .arlen                   (arlen),
   .arsize                  (arsize),
   .arburst                 (arburst),
   .arlock                  (arlock),
   .arcache                 (arcache),
   .arprot                  (arprot),
   .arqos                   (arqos),
   .arvalid                 (arvalid),
   .arready                 (arready),
   .rid                     (rid),
   .rdata                   (rdata),
   .rresp                   (rresp),
   .rlast                   (rlast),
   .rvalid                  (rvalid),
   .rready                  (rready),

   `else
   .hgrantdma(hgrantdma),
   .hbusreqdma(hbusreqdma),
   .hlockdma(hlockdma),
   .hready(hready),
   .hresp(hresp),
   .haddr(haddr),
   .htrans(htrans),
   .hwrite(hwrite),
   .hrdata(hrdata),
   .hsize(hsize),
   .hburst(hburst),
   .hprot(hprot),
   .hwdata(hwdata_pad[127:0]),
   `endif

   // external fifo interface.
   .tx_r_data(tx_r_data_pad),
   .tx_r_mod(tx_r_mod),
   .tx_r_sop(tx_r_sop),
   .tx_r_eop(tx_r_eop),
   .tx_r_err(tx_r_err),
   .tx_r_valid(tx_r_valid),
   .tx_r_data_rdy(tx_r_data_rdy),
   .tx_r_underflow(tx_r_underflow),
   .tx_r_rd(tx_r_rd),
   .tx_r_flushed(tx_r_flushed),
   .tx_r_control(tx_r_control),
   .tx_r_status(tx_r_status),
   `ifdef gem_fifo_8b_if
   .tx_r_fixed_lat(tx_r_fixed_lat),
   `endif
   .dma_tx_status_tog(dma_tx_status_tog),
   .dma_tx_end_tog(dma_tx_end_tog),
   .rx_w_wr(rx_w_wr),
   .rx_w_data(rx_w_data_pad[127:0]),
   `ifndef gem_fifo_8b_if
   .rx_w_mod(rx_w_mod),
   `else
   .rx_w_mod(4'h0),
   `endif
   .rx_w_sop(rx_w_sop),
   .rx_w_eop(rx_w_eop),
   .rx_w_err(rx_w_err),
   .rx_w_flush(rx_w_flush),
   .rx_w_status(rx_w_status),
   `ifdef dma_priority_queue1
   .rx_w_queue(rx_w_queue),
   `else
   .rx_w_queue(4'h0),
   `endif

   .rx_w_overflow(rx_w_overflow),

   // PFC signals
   .pfc_negotiate(pfc_negotiate),
   .rx_pfc_paused(rx_pfc_paused),

   // Other signals
   .force_back_pressure(force_back_pressure),
   `ifdef gem_user_io
   .user_out(user_out),
   .user_in(user_in),
   `endif // gem_user_io
   .ethernet_int(ethernet_int),
   .ethernet_int_q15(ethernet_int_q15),
   .ethernet_int_q14(ethernet_int_q14),
   .ethernet_int_q13(ethernet_int_q13),
   .ethernet_int_q12(ethernet_int_q12),
   .ethernet_int_q11(ethernet_int_q11),
   .ethernet_int_q10(ethernet_int_q10),
   .ethernet_int_q9(ethernet_int_q9),
   .ethernet_int_q8(ethernet_int_q8),
   .ethernet_int_q7(ethernet_int_q7),
   .ethernet_int_q6(ethernet_int_q6),
   .ethernet_int_q5(ethernet_int_q5),
   .ethernet_int_q4(ethernet_int_q4),
   .ethernet_int_q3(ethernet_int_q3),
   .ethernet_int_q2(ethernet_int_q2),
   .ethernet_int_q1(ethernet_int_q1),
   .emac_ethernet_int(emac_ethernet_int),
   .mmsl_int(mmsl_int),
   .dma_done(dma_done),
   .wr_tog_fail(wr_tog_fail),
   .flow_ctrl_done(flow_ctrl_done),
   .min_toggle_time_fail(min_toggle_time_fail),

   .rmii_ref_clk(rmii_ref_clk),
   .n_rmii_ref_reset(n_rmii_ref_reset),
   .mii_select (mii_select),// selects mii (1) or rmii (0)
   .txd_rmii   (txd_rmii),
   .rxd_rmii   (rxd_rmii),
   .tx_en_rmii (tx_en_rmii),
   .rx_er_rmii (rx_er_rmii),
   .crs_dv_rmii(crs_dv_rmii),

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

   `ifdef edma_tx_pkt_buffer
   `ifdef edma_spram
   .txsram_en(txspram_en),
   .txsram_we(txspram_we),
   .txsram_dob(txspram_do),
   `else
   .txsram_en(txdpram_enb),
   .txsram_we(txdpram_web),
   .txsram_dob(txdpram_dob),
   `endif
   .txsram_dob_err_inj(txsram_dob_err_inj),
   `endif // edma_tx_pkt_buffer
   `ifdef edma_rx_pkt_buffer
   `ifdef edma_spram
   .rxsram_en(rxspram_en),
   .rxsram_we(rxspram_we),
   .rxsram_dob(rxspram_do),
   `else
   .rxsram_en(rxdpram_enb),
   .rxsram_we(rxdpram_web),
   .rxsram_dob(rxdpram_dob),
   `endif
   .rxsram_dob_err_inj(rxsram_dob_err_inj),
   `endif // edma_rx_pkt_buffer

   .rx_sram_read_add(rx_sram_read_add),
   .tx_sram_read_add(tx_sram_read_add),
   .ifss_dis_x_drv(ifss_dis_x_drv),
   .fault_sim_for_dc_en(fault_sim_for_dc_en),
   .double_error_injection(double_error_injection),
   .single_error_injection(single_error_injection),
   .num_sram_errors_to_inject(num_sram_errors_to_inject),
   .test_ending(test_ending)

);

integer ethernet_int_cnt = 0;
always @(posedge ethernet_int)
ethernet_int_cnt = ethernet_int_cnt+1;


`ifdef gem_tsu
`ifdef edma_ext_tsu_timer
//------------------------------------------------------------------------------
// generate an incrementing external tsu timer value
//------------------------------------------------------------------------------

   tb_ext_tsu_timer i_tb_ext_tsu_timer(
      .tsu_clk (tsu_clk),
      .n_tsureset(n_tsureset),
      `ifdef edma_asf_dap_prot
      .ext_tsu_timer_par(ext_tsu_timer_par),
      `else
      .ext_tsu_timer_par(),
      `endif
      .ext_tsu_timer(ext_tsu_timer)

    );

`endif // edma_ext_tsu_timer
`endif




//------------------------------------------------------------------------------
// Gigabit Ethernet MAC instance
//------------------------------------------------------------------------------

   `ifdef xgm

      xgm i_xgm (

         // System Interface
         // Test interface

         `ifdef gem_ext_fifo_interface
         .scan_en(1'b0),
         .scan_in_1(1'b0),
         .scan_in_2(1'b0),
         .scan_in_3(1'b0),
         .scan_in_4(1'b0),
         .scan_out_1(scan_out[0]),
         .scan_out_2(scan_out[1]),
         .scan_out_3(scan_out[2]),
         .scan_out_4(scan_out[3]),

         `ifdef NOXGMII
         `else
         .scan_in_5(1'b0),
         .scan_in_6(1'b0),
         .scan_in_7(1'b0),
         .scan_out_5(scan_out[4]),
         .scan_out_6(scan_out[5]),
         .scan_out_7(scan_out[6]),
         `endif
         `else
         `ifdef GLSIM
         .scanen(1'b0),
         .scanen_cg(1'b0),
         `endif
         `endif


         // Clocks & Reset
         .rx_clk_int(rx_clk_to_gem),
         .n_rxi_reset(n_rxreset),
         .tx_clk(tx_clk_to_gem),
         .n_tx_reset(n_txreset),
         `ifdef NOXGMII
         `else
         .rx_clk(rx_clk_to_gem),
         .n_rx_reset(n_rxreset),
         .rx_clk_n(n_rx_clk_to_gem),
         .n_rxn_reset(n_nrxreset),
         .tx_clk_n(n_tx_clk_to_gem),
         .n_txn_reset(n_ntxreset),
         .xg_op_mux_sel(tx_clk_to_gem),
         `endif


         // tsu timer
         `ifdef edma_tsu
         .xgm_tsu_inc_ctrl(edma_tsu_inc_ctrl),
         .xgm_tsu_ms(edma_tsu_ms),
         .tsu_timer_cnt(tsu_timer_cnt),
         .tsu_timer_cmp_val(tsu_timer_cmp_val),

         // tsu clock
         `ifdef edma_tsu_clk
         .tsu_clk(tsu_clk),
         .n_tsureset(n_tsureset),
         `endif // edma_tsu_clk
         `ifdef edma_ext_tsu_timer
         .ext_tsu_timer(ext_tsu_timer),
         `endif
         `endif // edma_tsu

         .mac_int(ethernet_int),
         `ifdef interrupt_pulses_top_level
         .ints(),
         `endif

         `ifdef dma_priority_queue15
         .mac_int_q15      (ethernet_int_q15),
         `endif
         `ifdef dma_priority_queue14
         .mac_int_q14      (ethernet_int_q14),
         `endif
         `ifdef dma_priority_queue13
         .mac_int_q13      (ethernet_int_q13),
         `endif
         `ifdef dma_priority_queue12
         .mac_int_q12      (ethernet_int_q12),
         `endif
         `ifdef dma_priority_queue11
         .mac_int_q11      (ethernet_int_q11),
         `endif
         `ifdef dma_priority_queue10
         .mac_int_q10      (ethernet_int_q10),
         `endif
         `ifdef dma_priority_queue9
         .mac_int_q9      (ethernet_int_q9),
         `endif
         `ifdef dma_priority_queue8
         .mac_int_q8      (ethernet_int_q8),
         `endif
         `ifdef dma_priority_queue7
         .mac_int_q7      (ethernet_int_q7),
         `endif
         `ifdef dma_priority_queue6
         .mac_int_q6      (ethernet_int_q6),
         `endif
         `ifdef dma_priority_queue5
         .mac_int_q5      (ethernet_int_q5),
         `endif
         `ifdef dma_priority_queue4
         .mac_int_q4      (ethernet_int_q4),
         `endif
         `ifdef dma_priority_queue3
         .mac_int_q3      (ethernet_int_q3),
         `endif
         `ifdef dma_priority_queue2
         .mac_int_q2      (ethernet_int_q2),
         `endif
         `ifdef dma_priority_queue1
         .mac_int_q1      (ethernet_int_q1),
         `endif

         // XGMII
         .txd(xgm_txd),
         .txc(xgm_txc),
         .rxd(xgm_rxd),
         .rxc(xgm_rxc),

         // Register interface signals
         .pclk(pclk_to_gem),
         .n_preset(n_preset),
         .perr(perr),
          `ifdef gem_has_802p3_br
          .paddr(paddr_int[12:2]),
          `else
          .paddr(paddr_int[11:2]),
          `endif
          .prdata(prdata),
          .pwdata(pwdata_int),
          .pwrite(pwrite_int),
          .penable(penable_int),
          .psel(psel_int),

         // MDIO
         .mdio_in(mdio_in),
         .mdio_out(mdio_out),
         .mdio_oe(mdio_en),
         .mdc(mdc),

         // Packet buffer external DPSRAM connections
        `ifdef edma_rx_pkt_buffer
        `ifdef edma_spram
        .rxspram_we(rxspram_we),
        .rxspram_en(rxspram_en),
        .rxspram_addr(rxspram_addr),
        .rxspram_di(rxspram_di),
        .rxspram_do(rxspram_do),
        `else
        .rxdpram_wea(rxdpram_wea),
        .rxdpram_ena(rxdpram_ena),
        .rxdpram_addra(rxdpram_addra),
        .rxdpram_dia(rxdpram_dia),
        .rxdpram_web(rxdpram_web),
        .rxdpram_enb(rxdpram_enb),
        .rxdpram_addrb(rxdpram_addrb),
        .rxdpram_dob(rxdpram_dob),
        `endif
        `endif // edma_rx_pkt_buffer

        `ifdef edma_tx_pkt_buffer
        `ifdef edma_spram
        .txspram_we(txspram_we),
        .txspram_en(txspram_en),
        .txspram_addr(txspram_addr),
        .txspram_di(txspram_di),
        .txspram_do(txspram_do),
        `else
        .txdpram_wea(txdpram_wea),
        .txdpram_ena(txdpram_ena),
        .txdpram_addra(txdpram_addra),
        .txdpram_dia(txdpram_dia),
        .txdpram_web(txdpram_web),
        .txdpram_enb(txdpram_enb),
        .txdpram_addrb(txdpram_addrb),
        .txdpram_dob(txdpram_dob),
        `endif
        `endif // edma_tx_pkt_buffer

         `ifdef edma_axi

         .aclk(hclk_to_gem),
         .n_areset(n_hreset),
         .awid(awid),
         .awaddr(awaddr),
         .awlen(awlen),
         .awsize(awsize),
         .awburst(awburst),
         .awlock(awlock),
         .awcache(awcache),
         .awprot(awprot),
         .awvalid(awvalid),
         .awready(awready),
         .wdata(wdata),
         .wstrb(wstrb),
         .wlast(wlast),
         .wready(wready),
         .wvalid(wvalid),
         .bid(bid),
         .bresp(bresp),
         .bvalid(bvalid),
         .bready(bready),
         .arid(arid),
         .araddr(araddr),
         .arlen(arlen),
         .arsize(arsize),
         .arburst(arburst),
         .arlock(arlock),
         .arcache(arcache),
         .arprot(arprot),
         .arvalid(arvalid),
         .arready(arready),
         .rid(rid),
         .rdata(rdata_pad),
         .rresp(rresp),
         .rlast(rlast),
         .rvalid(rvalid),
         .rready(rready),

         `else

         .hclk(hclk_to_gem),
         .n_hreset(n_hreset),
         .hgrant(hgrantdma),
         .hbusreq(hbusreqdma),
         .hlock(hlockdma),
         .hready(hready),
         .hresp(hresp),
         .haddr(haddr),
         .htrans(htrans),
         .hwrite(hwrite),
         .hrdata(hrdata),
         .hsize(hsize),
         .hburst(hburst),
         .hprot(hprot),
         .hwdata(hwdata_pad[127:0]),

         `endif

         .trigger_dma_tx_start(trigger_dma_tx_start),

         `ifdef gem_ext_fifo_interface
         `else
         .rx_databuf_wr_q0(rx_databuf_wr_q0),
         `endif
         `ifdef dma_priority_queue1
          .rx_databuf_wr_q1(rx_databuf_wr_q1),
         `endif
         `ifdef dma_priority_queue2
          .rx_databuf_wr_q2(rx_databuf_wr_q2),
         `endif
         `ifdef dma_priority_queue3
          .rx_databuf_wr_q3(rx_databuf_wr_q3),
         `endif
         `ifdef dma_priority_queue4
          .rx_databuf_wr_q4(rx_databuf_wr_q4),
         `endif
         `ifdef dma_priority_queue5
          .rx_databuf_wr_q5(rx_databuf_wr_q5),
         `endif
         `ifdef dma_priority_queue6
          .rx_databuf_wr_q6(rx_databuf_wr_q6),
         `endif
         `ifdef dma_priority_queue7
          .rx_databuf_wr_q7(rx_databuf_wr_q7),
         `endif
         `ifdef dma_priority_queue8
          .rx_databuf_wr_q8(rx_databuf_wr_q8),
         `endif
         `ifdef dma_priority_queue9
          .rx_databuf_wr_q9(rx_databuf_wr_q9),
         `endif
         `ifdef dma_priority_queue10
          .rx_databuf_wr_q10(rx_databuf_wr_q10),
         `endif
         `ifdef dma_priority_queue11
          .rx_databuf_wr_q11(rx_databuf_wr_q11),
         `endif
         `ifdef dma_priority_queue12
          .rx_databuf_wr_q12(rx_databuf_wr_q12),
         `endif
         `ifdef dma_priority_queue13
          .rx_databuf_wr_q13(rx_databuf_wr_q13),
         `endif
         `ifdef dma_priority_queue14
          .rx_databuf_wr_q14(rx_databuf_wr_q14),
         `endif
         `ifdef dma_priority_queue15
          .rx_databuf_wr_q15(rx_databuf_wr_q15),
         `endif

         .wol(wol),
         .tx_pause_frame(tx_pause),
         .tx_pause_size(tx_pause_zero),
         .tx_pfc_sel(tx_pfc_sel),
         .tx_pfc_pause(tx_pfc_pause),
         .tx_pfc_pause_zero(tx_pfc_pause_zero),
         .pfc_negotiate(pfc_negotiate),
         .rx_pfc_paused(rx_pfc_paused),
         .rx_paused(),

   `ifdef xgm_ext_fifo_interface
         .ext_da(ext_da),
         .ext_sa(ext_sa),
         .ext_type(ext_type),
         .ext_vid(ext_vlan_tag1[15:0]),
         .ext_stb(ext_stb),
         .ext_da_stb(ext_da_stb),
   `else
         .ext_da(ext_da),
         .ext_da_stb(ext_da_stb),
         .ext_sa(ext_sa),
         .ext_sa_stb(ext_sa_stb),
         .ext_type(ext_type),
         .ext_type_stb(ext_type_stb),
         .ext_ip_sa(ext_ip_sa),
         .ext_ip_sa_stb(ext_ip_sa_stb),
         .ext_ip_da(ext_ip_da),
         .ext_ip_da_stb(ext_ip_da_stb),
         .ext_vlan_tag1(ext_vlan_tag1),
         .ext_vlan_tag1_stb(ext_vlan_tag1_stb),
         .ext_vlan_tag2(ext_vlan_tag2),
         .ext_vlan_tag2_stb(ext_vlan_tag2_stb),
   `endif

         .ex_match({ext_match4,ext_match3,ext_match2,ext_match1}),

         .ext_interrupt_in(ext_interrupt_in),

         .receive_en(1'b1),
         .transmit_en(1'b1),

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

         .local_fault(),
         .remote_fault(),
         .link_interruption() );

   `else
      gem_gxl i_gem_gxl(
      // test
      `ifdef GLSIM
      .scanen(1'b0),
      .scanen_cg(1'b0),
      `endif

      // system interface (resets)
      .n_txreset(n_txreset),
      .n_rxreset(n_rxreset),

      // tsu timer
      `ifdef edma_tsu
      .gem_tsu_inc_ctrl(edma_tsu_inc_ctrl),
      .gem_tsu_ms(edma_tsu_ms),
      .tsu_timer_cnt(tsu_timer_cnt),
      `ifdef edma_asf_dap_prot
      .tsu_timer_cnt_par(tsu_timer_cnt_par),
      `endif
      .tsu_timer_cmp_val(tsu_timer_cmp_val),

      `ifdef edma_ext_tsu_timer
      .ext_tsu_timer(ext_tsu_timer),
      `ifdef edma_asf_dap_prot
      .ext_tsu_timer_par(ext_tsu_timer_par),
      `endif
      `endif
      // tsu clock
      `ifdef edma_tsu_clk
      .tsu_clk(tsu_clk),
      .n_tsureset(n_tsureset),
      `endif // edma_tsu_clk
      `endif // edma_tsu

      // Internal loopback signals
      `ifdef gem_int_loopback
      .n_ntxreset(n_ntxreset),
      .n_tx_clk(n_tx_clk_to_gem),
      .loopback_local(loopback_local),
      `else
      `ifdef gem_use_rgmii
      .n_ntxreset(n_ntxreset),
      .n_tx_clk(n_tx_clk_to_gem),
      `endif
      `endif // gem_int_loopback

      // GMII / MII ethernet interface
      .tx_clk(tx_clk_to_gem),
      .rx_clk(rx_clk_to_gem),
      `ifdef gem_use_rgmii
      .tx_clk_sig(rgmii_tx_clk_sig_to_dut),
      .n_nrxreset(n_nrxreset),
      .n_rx_clk(n_rx_clk_to_gem),
      .rgmii_txd(rgmii_txd),
      .rgmii_tx_ctl(rgmii_tx_ctl),
      .rgmii_rxd(rgmii_rxd),
      .rgmii_rx_ctl(rgmii_rx_ctl),
      .rgmii_link_status(rgmii_link_status),
      .rgmii_speed(rgmii_speed),
      .rgmii_duplex_out(rgmii_duplex_out),
      `else
      .txd(txd[7:0]),
      .tx_en(tx_en),
      `ifdef CDN_LEGACY_UVM
         .rxd(rxd_int[7:0]),
         .rx_dv(rx_dv_int),
      `else
         .rxd(rxd[7:0]),
         .rx_dv(rx_dv),
      `endif
      `endif

      .tx_er(tx_er),
      `ifdef CDN_LEGACY_UVM
         .rx_er(rx_er_int),
         .col(col_int),
         .crs(crs_int),
      `else
         .rx_er(rx_er),
         .col(col),
         .crs(crs),
      `endif

      `ifdef gem_include_rmii
         .ref_clk    (rmii_ref_clk),
         .n_ref_reset(n_rmii_ref_reset),
         .mii_select (mii_select),// selects mii (1) or rmii (0)
         .rmii_txd   (txd_rmii),
         .rmii_rxd   (rxd_rmii),
         .rmii_tx_en (tx_en_rmii),
         .rmii_rx_er (rx_er_rmii),
         .rmii_crs_dv(crs_dv_rmii),
         .rmii_rx_clk(rmii_rx_clk),
         .rmii_tx_clk(rmii_tx_clk),
      `endif

      // Ten bit interface
      `ifdef gem_no_pcs
      `else // if not gem_no_pcs
      .gtx_clk(gtx_clk_to_gem),
      .n_gtxreset(n_gtxreset),

   `ifdef gem_pcs_20b_if
      .gtx20_clk(gtx20_clk_to_gem),
      .n_gtx20reset(n_gtx20reset),
   `endif
   `ifdef gem_pcs_legacy_if
      .rbc0(rbc0_to_gem),
      .rbc1(rbc1_to_gem),
      .n_rbc0reset(n_rbc0reset),
      .n_rbc1reset(n_rbc1reset),
   `else
      .pcs_rx_clk(pcs_rx20_clk_to_gem),
      .n_pcs_rxreset(n_pmarx20reset),
      .pcs_cal_bypass(pcs_cal_bypass),
      .pcs_cgalign_bypass(pcs_cgalign_bypass),
   `endif
   `ifdef gem_pcs_10b_if
      .pcs_rx10_clk(pcs_rx_clk_to_gem),
      .n_pcs_rx10reset(n_prxreset),
   `endif

      .tx_group(tx_group),
      .rx_group(rx_group),
      .ewrap(ewrap),
      .en_cdet(en_cdet),
      .signal_detect(signal_detect),

      // serdes signals
      `endif // gem_no_pcs

      // other ethernet signals
      .mdc(mdc),
      .mdio_in(mdio_in),
      .mdio_out(mdio_out),
      .mdio_en(mdio_en),
      .loopback(loopback),
      .half_duplex(half_duplex),
      .speed_mode(speed_mode),
      .ext_interrupt_in(ext_interrupt_in),
      .tx_pause(tx_pause),
      .tx_pause_zero(tx_pause_zero),
      .tx_pfc_sel(tx_pfc_sel),
      .tx_pfc_pause(tx_pfc_pause),
      .tx_pfc_pause_zero(tx_pfc_pause_zero),
      .pfc_negotiate(pfc_negotiate),
      .rx_pfc_paused(rx_pfc_paused),
      .wol(wol),

      `ifdef edma_ext_fifo_interface
      `else
      `ifdef edma_tx_pkt_buffer
      .trigger_dma_tx_start(trigger_dma_tx_start),
      `endif
      `endif

      // external filter interface
      .ext_match1(ext_match1),
      .ext_match2(ext_match2),
      .ext_match3(ext_match3),
      .ext_match4(ext_match4),
      .ext_da(ext_da),
      .ext_da_stb(ext_da_stb),
      .ext_sa(ext_sa),
      .ext_sa_stb(ext_sa_stb),
      .ext_type(ext_type),
      .ext_type_stb(ext_type_stb),
      .ext_ip_sa(ext_ip_sa),
      .ext_ip_sa_stb(ext_ip_sa_stb),
      .ext_ip_da(ext_ip_da),
      .ext_ip_da_stb(ext_ip_da_stb),
      .ext_source_port(ext_source_port),
      .ext_sp_stb(ext_sp_stb),
      .ext_dest_port(ext_dest_port),
      .ext_dp_stb(ext_dp_stb),
      .ext_ipv6(ext_ipv6),
      .ext_vlan_tag1(ext_vlan_tag1),
      .ext_vlan_tag1_stb(ext_vlan_tag1_stb),
      .ext_vlan_tag2(ext_vlan_tag2),
      .ext_vlan_tag2_stb(ext_vlan_tag2_stb),

      // precision time protocol signals for IEEE 1588 support
      .sof_tx         (sof_tx),
      .sync_frame_tx  (sync_frame_tx),
      .delay_req_tx   (delay_req_tx),
      .pdelay_req_tx  (pdelay_req_tx),
      .pdelay_resp_tx (pdelay_resp_tx),
      .sof_rx         (sof_rx),
      .sync_frame_rx  (sync_frame_rx),
      .delay_req_rx   (delay_req_rx),
      .pdelay_req_rx  (pdelay_req_rx),
      .pdelay_resp_rx (pdelay_resp_rx),

      // APB interface signals
      .pclk(pclk_to_gem),
      .n_preset(n_preset),
      .prdata(prdata),
      .perr(perr),
      `ifdef edma_asf_host_par
        .paddr_par(paddr_int_par),
        `ifdef gem_has_802p3_br
          .paddr({3'h0,paddr_int[12:2],2'h0}),
        `else
          .paddr({4'h0,paddr_int[11:2],2'h0}),
        `endif
      `else
        `ifdef gem_has_802p3_br
          .paddr(paddr_int[12:2]),
        `else
          .paddr(paddr_int[11:2]),
        `endif
      `endif

       .pwdata(pwdata_int),
       .pwrite(pwrite_int),
       .penable(penable_int),
       .psel(psel_int),
       `ifdef edma_asf_host_par
       .pwdata_par(pwdata_par_int),
       .prdata_par(prdata_par),
       `endif
      `ifdef gem_add_tx_external_fifo_if
      // low latency tx interface.
      // pmac connections
      .tx_r_data          (tx_r_data),

      `ifdef gem_fifo_8b_if
      `else
      .tx_r_mod           (tx_r_mod),
      `endif
      .tx_r_sop           (tx_r_sop),
      .tx_r_eop           (tx_r_eop),
      .tx_r_err           (tx_r_err),
      `ifdef dma_priority_queue1
      .tx_r_queue         (tx_r_queue),
      `endif
      .tx_r_valid         (tx_r_valid),
      .tx_r_data_rdy      (tx_r_data_rdy),
      .tx_r_underflow     (tx_r_underflow),
      .tx_r_rd            (tx_r_rd),
      .tx_r_flushed       (tx_r_flushed),
      .tx_r_control       (tx_r_control),
      .tx_r_status        (tx_r_status),
      .tx_r_frame_size    (tx_r_frame_size),
      .tx_r_frame_size_vld(tx_r_frame_size_vld),
      `ifdef gem_fifo_8b_if
      .tx_r_fixed_lat     (tx_r_fixed_lat),
      `endif
      .dma_tx_status_tog  (dma_tx_status_tog),
      .dma_tx_end_tog     (dma_tx_end_tog),
      `ifdef edma_tsu
      .tx_r_timestamp     (),
      `endif
      `endif // gem_add_tx_external_fifo_if


      `ifdef gem_add_rx_external_fifo_if
      .rx_w_wr            (rx_w_wr),
      .rx_w_data          (rx_w_data),
      `ifndef gem_fifo_8b_if
      .rx_w_mod           (rx_w_mod),
      `else
        `ifdef gem_no_pcs
        `else // if not gem_no_pcs
        .rx_clk_from_phy  (~rx_clk_from_phy),
        `endif
      `endif
      .rx_w_sop           (rx_w_sop),
      .rx_w_eop           (rx_w_eop),
      .rx_w_err           (rx_w_err),
      .rx_w_flush         (rx_w_flush),
      .rx_w_status        (rx_w_status),
      `ifdef dma_priority_queue1
      .rx_w_queue         (rx_w_queue),
      `endif
      `ifdef num_spec_add_filters
         .add_match_vec   (add_match_vec),
      `endif
      .rx_w_overflow      (rx_w_overflow),
      `ifdef edma_tsu
      .rx_w_timestamp     (),
      `endif
      `endif // gem_add_rx_external_fifo_if

      `ifdef gem_has_802p3_br
        `ifdef gem_add_tx_external_fifo_if
        // low latency tx interface.
        // emac connections
        .emac_tx_r_data          (emac_tx_r_data),

        `ifdef gem_fifo_8b_if
        `else
        .emac_tx_r_mod           (emac_tx_r_mod),
        `endif
        .emac_tx_r_sop           (emac_tx_r_sop),
        .emac_tx_r_eop           (emac_tx_r_eop),
        .emac_tx_r_err           (emac_tx_r_err),
        `ifdef dma_priority_queue1
        .emac_tx_r_queue         (emac_tx_r_queue),
        `endif
        .emac_tx_r_valid         (emac_tx_r_valid),
        .emac_tx_r_data_rdy      (emac_tx_r_data_rdy),
        .emac_tx_r_underflow     (emac_tx_r_underflow),
        .emac_tx_r_rd            (emac_tx_r_rd),
        .emac_tx_r_flushed       (emac_tx_r_flushed),
        .emac_tx_r_control       (emac_tx_r_control),
        .emac_tx_r_status        (emac_tx_r_status),
        .emac_tx_r_frame_size    (emac_tx_r_frame_size),
        .emac_tx_r_frame_size_vld(emac_tx_r_frame_size_vld),
        `ifdef gem_fifo_8b_if
        .emac_tx_r_fixed_lat     (emac_tx_r_fixed_lat),
        `endif
        .emac_dma_tx_status_tog  (emac_dma_tx_status_tog),
        .emac_dma_tx_end_tog     (emac_dma_tx_end_tog),
        `ifdef edma_tsu
        .emac_tx_r_timestamp     (),
        `endif
        `endif // gem_add_tx_external_fifo_if


        `ifdef gem_add_rx_external_fifo_if
        .emac_rx_w_wr            (emac_rx_w_wr),
        .emac_rx_w_data          (emac_rx_w_data),
        `ifndef gem_fifo_8b_if
        .emac_rx_w_mod           (emac_rx_w_mod),
        `else
        `endif
        .emac_rx_w_sop           (emac_rx_w_sop),
        .emac_rx_w_eop           (emac_rx_w_eop),
        .emac_rx_w_err           (emac_rx_w_err),
        .emac_rx_w_flush         (emac_rx_w_flush),
        .emac_rx_w_status        (emac_rx_w_status),
        `ifdef dma_priority_queue1
        .emac_rx_w_queue         (emac_rx_w_queue),
        `endif
        `ifdef num_spec_add_filters
           .emac_add_match_vec   (emac_add_match_vec),
        `endif
        .emac_rx_w_overflow      (emac_rx_w_overflow),
        `ifdef edma_tsu
        .emac_rx_w_timestamp     (),
        `endif
        `endif // gem_add_rx_external_fifo_if
      `endif // gem_has_802p3_br


      `ifdef gem_ext_fifo_interface
      `else

      // AHB interface signals
         `ifdef edma_axi
         .aclk                    (hclk_to_gem),
         .n_areset                (n_hreset),
         .awid                    (awid),
         .awaddr                  (awaddr),
         .awlen                   (awlen),
         .awsize                  (awsize),
         .awburst                 (awburst),
         .awlock                  (awlock),
         .awcache                 (awcache),
         .awprot                  (awprot),
         .awqos                   (awqos),
         .awvalid                 (awvalid),
         .awready                 (awready),
         .wdata                   (wdata),
         .wstrb                   (wstrb),
         .wlast                   (wlast),
         .wid                     (wid),
         .wready                  (wready),
         .wvalid                  (wvalid),
         .bid                     (bid),
         .bresp                   (bresp),
         .bvalid                  (bvalid),
         .bready                  (bready),
         .arid                    (arid),
         .araddr                  (araddr),
         .arlen                   (arlen),
         .arsize                  (arsize),
         .arburst                 (arburst),
         .arlock                  (arlock),
         .arcache                 (arcache),
         .arprot                  (arprot),
         .arqos                   (arqos),
         .arvalid                 (arvalid),
         .arready                 (arready),
         .rid                     (rid),
         .rdata                   (rdata_pad),
         .rresp                   (rresp),
         .rlast                   (rlast),
         .rvalid                  (rvalid),
         .rready                  (rready),

         `ifdef edma_asf_host_par
         .awaddr_par              (awaddr_par),
         .wdata_par               (wdata_par),
         .araddr_par              (araddr_par),
         .rdata_par               (rdata_par[(`edma_bus_width/8)-1:0]),
         `endif

         `else

         .hclk(hclk_to_gem),
         .n_hreset(n_hreset),
         .hgrant(hgrantdma),
         .hready(hready),
         .hresp(hresp),
         .hrdata(hrdata_pad),
         .hbusreq(hbusreqdma),
         .hlock(hlockdma),
         .haddr(haddr),
         .htrans(htrans),
         .hwrite(hwrite),
         .hsize(hsize),
         .hburst(hburst),
         .hprot(hprot),
         .hwdata(hwdata),
         `endif

      `endif //gem_ext_fifo_interface

      // Other signals
      .dma_bus_width(dma_bus_width),

      // Packet buffer external DPSRAM connections
      `ifdef edma_ext_fifo_interface
      `else
      `ifdef edma_rx_pkt_buffer
      `ifdef edma_spram
      .rxspram_we(rxspram_we),
      .rxspram_en(rxspram_en),
      .rxspram_addr(rxspram_addr),
      .rxspram_di(rxspram_di),
      .rxspram_do(rxsram_dob_err_inj),
      `else
      .rxdpram_wea(rxdpram_wea),
      .rxdpram_ena(rxdpram_ena),
      .rxdpram_addra(rxdpram_addra),
      .rxdpram_dia(rxdpram_dia),
      .rxdpram_web(rxdpram_web),
      .rxdpram_enb(rxdpram_enb),
      .rxdpram_addrb(rxdpram_addrb),
      .rxdpram_dob(rxsram_dob_err_inj),
      `endif
      `endif // edma_rx_pkt_buffer

      `ifdef gem_has_802p3_br
      `ifdef edma_rx_pkt_buffer
      `ifdef edma_spram
      .emac_rxspram_we(emac_rxspram_we),
      .emac_rxspram_en(emac_rxspram_en),
      .emac_rxspram_addr(emac_rxspram_addr),
      .emac_rxspram_di(emac_rxspram_di),
      .emac_rxspram_do(emac_rxspram_do),
      `else
      .emac_rxdpram_wea(emac_rxdpram_wea),
      .emac_rxdpram_ena(emac_rxdpram_ena),
      .emac_rxdpram_addra(emac_rxdpram_addra),
      .emac_rxdpram_dia(emac_rxdpram_dia),
      .emac_rxdpram_web(emac_rxdpram_web),
      .emac_rxdpram_enb(emac_rxdpram_enb),
      .emac_rxdpram_addrb(emac_rxdpram_addrb),
      .emac_rxdpram_dob(emac_rxdpram_dob),
      `endif
      `endif // edma_rx_pkt_buffer
      `endif


      `ifdef edma_tx_pkt_buffer
      `ifdef edma_spram
      .txspram_we(txspram_we),
      .txspram_en(txspram_en),
      .txspram_addr(txspram_addr),
      .txspram_di(txspram_di),
      .txspram_do(txsram_dob_err_inj),
      `else
      .txdpram_wea(txdpram_wea),
      .txdpram_ena(txdpram_ena),
      .txdpram_addra(txdpram_addra),
      .txdpram_dia(txdpram_dia),
      .txdpram_web(txdpram_web),
      .txdpram_enb(txdpram_enb),
      .txdpram_addrb(txdpram_addrb),
      .txdpram_dob(txsram_dob_err_inj),
      `endif
      `endif // edma_tx_pkt_buffer

      `ifdef gem_has_802p3_br
      `ifdef edma_tx_pkt_buffer
      `ifdef edma_spram
      .emac_txspram_we(emac_txspram_we),
      .emac_txspram_en(emac_txspram_en),
      .emac_txspram_addr(emac_txspram_addr),
      .emac_txspram_di(emac_txspram_di),
      .emac_txspram_do(emac_txspram_do),
      `else
      .emac_txdpram_wea(emac_txdpram_wea),
      .emac_txdpram_ena(emac_txdpram_ena),
      .emac_txdpram_addra(emac_txdpram_addra),
      .emac_txdpram_dia(emac_txdpram_dia),
      .emac_txdpram_web(emac_txdpram_web),
      .emac_txdpram_enb(emac_txdpram_enb),
      .emac_txdpram_addrb(emac_txdpram_addrb),
      .emac_txdpram_dob(emac_txdpram_dob),
      `endif
      `endif // edma_tx_pkt_buffer
      `endif
      `endif //edma_ext_fifo_interface


      // User I/O interface.
      `ifdef gem_user_io
      .user_out(user_out),
      .user_in(user_in),
      `endif // gem_user_io

     // Specific outputs to support Priority Queues
      `ifdef gem_ext_fifo_interface
      `else
      .rx_databuf_wr_q0(rx_databuf_wr_q0),
     `ifdef dma_priority_queue1
      .rx_databuf_wr_q1(rx_databuf_wr_q1),
     `endif
     `ifdef dma_priority_queue2
      .rx_databuf_wr_q2(rx_databuf_wr_q2),
     `endif
     `ifdef dma_priority_queue3
      .rx_databuf_wr_q3(rx_databuf_wr_q3),
     `endif
     `ifdef dma_priority_queue4
      .rx_databuf_wr_q4(rx_databuf_wr_q4),
     `endif
     `ifdef dma_priority_queue5
      .rx_databuf_wr_q5(rx_databuf_wr_q5),
     `endif
     `ifdef dma_priority_queue6
      .rx_databuf_wr_q6(rx_databuf_wr_q6),
     `endif
     `ifdef dma_priority_queue7
      .rx_databuf_wr_q7(rx_databuf_wr_q7),
     `endif
     `ifdef dma_priority_queue8
      .rx_databuf_wr_q8(rx_databuf_wr_q8),
     `endif
     `ifdef dma_priority_queue9
      .rx_databuf_wr_q9(rx_databuf_wr_q9),
     `endif
     `ifdef dma_priority_queue10
      .rx_databuf_wr_q10(rx_databuf_wr_q10),
     `endif
     `ifdef dma_priority_queue11
      .rx_databuf_wr_q11(rx_databuf_wr_q11),
     `endif
     `ifdef dma_priority_queue12
      .rx_databuf_wr_q12(rx_databuf_wr_q12),
     `endif
     `ifdef dma_priority_queue13
      .rx_databuf_wr_q13(rx_databuf_wr_q13),
     `endif
     `ifdef dma_priority_queue14
      .rx_databuf_wr_q14(rx_databuf_wr_q14),
     `endif
     `ifdef dma_priority_queue15
      .rx_databuf_wr_q15(rx_databuf_wr_q15),
     `endif
      `endif

     // Specific Gemstone outputs to support half duplex flow control
      .halfduplex_flow_control_en(force_back_pressure),

      // Interrupt controller interface.
       `ifndef gem_ext_fifo_interface
       `ifdef dma_priority_queue15
       .ethernet_int_q15      (ethernet_int_q15),
       `endif
       `ifdef dma_priority_queue14
       .ethernet_int_q14      (ethernet_int_q14),
       `endif
       `ifdef dma_priority_queue13
       .ethernet_int_q13      (ethernet_int_q13),
       `endif
       `ifdef dma_priority_queue12
       .ethernet_int_q12      (ethernet_int_q12),
       `endif
       `ifdef dma_priority_queue11
       .ethernet_int_q11      (ethernet_int_q11),
       `endif
       `ifdef dma_priority_queue10
       .ethernet_int_q10      (ethernet_int_q10),
       `endif
       `ifdef dma_priority_queue9
       .ethernet_int_q9      (ethernet_int_q9),
       `endif
       `ifdef dma_priority_queue8
       .ethernet_int_q8      (ethernet_int_q8),
       `endif
       `ifdef dma_priority_queue7
       .ethernet_int_q7      (ethernet_int_q7),
       `endif
       `ifdef dma_priority_queue6
       .ethernet_int_q6      (ethernet_int_q6),
       `endif
       `ifdef dma_priority_queue5
       .ethernet_int_q5      (ethernet_int_q5),
       `endif
       `ifdef dma_priority_queue4
       .ethernet_int_q4      (ethernet_int_q4),
       `endif
       `ifdef dma_priority_queue3
       .ethernet_int_q3      (ethernet_int_q3),
       `endif
       `ifdef dma_priority_queue2
       .ethernet_int_q2      (ethernet_int_q2),
       `endif
       `ifdef dma_priority_queue1
       .ethernet_int_q1      (ethernet_int_q1),
       `endif
      `endif

`ifndef gem_ext_fifo_interface
`ifdef gem_tx_pkt_buffer
      `ifdef gem_asf_ecc_sram
       .asf_sram_corr_err  (asf_sram_corr_err),
      `endif
      `ifdef gem_asf_dap_prot
       .asf_sram_uncorr_err(asf_sram_uncorr_err),
      `endif
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
`ifndef gem_ext_fifo_interface
`ifdef gem_tx_pkt_buffer
       `ifdef gem_asf_ecc_sram
       .emac_asf_sram_corr_err   (emac_asf_sram_corr_err),
       `endif
       `ifdef gem_asf_dap_prot
       .emac_asf_sram_uncorr_err (emac_asf_sram_uncorr_err),
       `endif
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

      `ifdef gem_has_802p3_br
      .emac_ethernet_int  (emac_ethernet_int),
      .mmsl_int           (mmsl_int),
      `endif
       .ethernet_int      (ethernet_int)
      );

   `endif

    `ifdef gem_has_802p3_br
    `else
    assign emac_ethernet_int = 1'b0;
    assign mmsl_int = 1'b0;
    assign emac_asf_int_nonfatal = 1'b0;
    assign emac_asf_int_fatal = 1'b0;
    `endif

    assign tx_r_frame_size_vld  = {`edma_queues{1'b1}};
    assign tx_r_frame_size      = {`edma_queues*14{1'b1}};

    `ifdef dma_priority_queue15
    `else
    assign ethernet_int_q15 = 1'b0;
    `endif
    `ifdef dma_priority_queue14
    `else
    assign ethernet_int_q14 = 1'b0;
    `endif
    `ifdef dma_priority_queue13
    `else
    assign ethernet_int_q13 = 1'b0;
    `endif
    `ifdef dma_priority_queue12
    `else
    assign ethernet_int_q12 = 1'b0;
    `endif
    `ifdef dma_priority_queue11
    `else
    assign ethernet_int_q11 = 1'b0;
    `endif
    `ifdef dma_priority_queue10
    `else
    assign ethernet_int_q10 = 1'b0;
    `endif
    `ifdef dma_priority_queue9
    `else
    assign ethernet_int_q9 = 1'b0;
    `endif
    `ifdef dma_priority_queue8
    `else
    assign ethernet_int_q8 = 1'b0;
    `endif
    `ifdef dma_priority_queue7
    `else
    assign ethernet_int_q7 = 1'b0;
    `endif
    `ifdef dma_priority_queue6
    `else
    assign ethernet_int_q6 = 1'b0;
    `endif
    `ifdef dma_priority_queue5
    `else
    assign ethernet_int_q5 = 1'b0;
    `endif
    `ifdef dma_priority_queue4
    `else
    assign ethernet_int_q4 = 1'b0;
    `endif
    `ifdef dma_priority_queue3
    `else
    assign ethernet_int_q3 = 1'b0;
    `endif
    `ifdef dma_priority_queue2
    `else
    assign ethernet_int_q2 = 1'b0;
    `endif
    `ifdef dma_priority_queue1
    `else
    assign ethernet_int_q1 = 1'b0;
    `endif

// Convert the XGMII to DDR
`ifdef xgm
`ifdef NOXGMII
  // drive DDR tx signals
  reg [31:0] xg_txd_2_n;
  reg [3:0] xg_txc_2_n;
  reg [63:0] xgm_rxd_re;
  reg [7:0] xgm_rxc_re;
  reg [63:0] xgm_rxd_fe;
  reg [7:0] xgm_rxc_fe;
  always @(posedge n_tx_clk_to_gem or negedge n_ntxreset)
    begin
      if (n_ntxreset == 1'b0)
        begin
          xg_txd_2_n <= 32'h07070707;
          xg_txc_2_n <=  4'b1111;
        end
      else
        begin
          xg_txd_2_n <= xgm_txd[63:32];
          xg_txc_2_n <= xgm_txc[7:4];
        end
    end
  assign txd = tx_clk_to_gem ? xgm_txd[31:0] : xg_txd_2_n;
  assign txc = tx_clk_to_gem ? xgm_txc[3:0]  : xg_txc_2_n;
xgm_xgmii_rx i_xgmii_rx(
   .rx_clk_int     (rx_clk_to_gem),
   .rst_n          (n_rxreset),
   .rx_clk         (rx_clk_to_gem),
   .rx_rst_n       (n_rxreset),
   .rx_clk_n       (n_rx_clk_to_gem),
   .rx_n_rst_n     (n_nrxreset),
   .rx_enable      (1'b1),
   .xg_rxd         (rxd),
   .xg_rxc         (rxc),
   .rxd            (xgm_rxd_re),
   .rxc            (xgm_rxc_re)
);
  always @(negedge rx_clk_to_gem)
    begin
      xgm_rxd_fe <= xgm_rxd_re;
      xgm_rxc_fe <= xgm_rxc_re;
    end
  assign xgm_rxd = xgm_rxd_fe;
  assign xgm_rxc = xgm_rxc_fe;

`else
  assign txd = xgm_txd;
  assign txc = xgm_txc;
  assign xgm_rxd = rxd;
  assign xgm_rxc = rxc;
`endif
`endif

//------------------------------------------------------------------------------
// RX Dual Port Memory Instantiation
//------------------------------------------------------------------------------
`ifdef gem_has_802p3_br
`ifdef edma_rx_pkt_buffer
   `ifdef edma_spram
      tb_dpram #( .p_data_width(`edma_rx_pbuf_data+`edma_emac_rx_pbuf_reduncy),
                  .p_depth(2**`gem_emac_rx_pbuf_addr),
                  .p_addr_width(`gem_emac_rx_pbuf_addr),
                  .p_ram_inactive_val(p_ram_inactive_val))

         i_emac_rxspram (
            .a_we    (emac_rxspram_we),
            .a_cs    (emac_rxspram_en),
            .a_clk   (hclk_to_gem),
            .a_addr  (emac_rxspram_addr),
            .a_wdata (emac_rxspram_di),
            .a_rdata (emac_rxspram_do),
            .b_we    (1'b0),
            .b_cs    (1'b0),
            .b_clk   (1'b0),
            .b_addr  ({`gem_emac_rx_pbuf_addr{1'b0}}),
            .b_wdata ({(`edma_rx_pbuf_data+`edma_emac_rx_pbuf_reduncy){1'b0}}),
            .b_rdata ()
            );
   `else
      tb_dpram #(.p_data_width(`edma_rx_pbuf_data+`edma_emac_rx_pbuf_reduncy),
                 .p_depth(2**`gem_emac_rx_pbuf_addr),
                 .p_addr_width(`gem_emac_rx_pbuf_addr),
                 .p_ram_inactive_val(p_ram_inactive_val))
         i_emac_rxdpram (
            .a_we    (emac_rxdpram_wea),
            .a_cs    (emac_rxdpram_ena),
            .a_clk   (rx_clk_to_gem),
            .a_addr  (emac_rxdpram_addra),
            .a_wdata (emac_rxdpram_dia),
            .a_rdata (emac_rxdpram_doa),
            .b_we    (emac_rxdpram_web),
            .b_cs    (emac_rxdpram_enb),
            .b_clk   (hclk_to_gem),
            .b_addr  (emac_rxdpram_addrb),
            .b_wdata (emac_rxdpram_dib),
            .b_rdata (emac_rxdpram_dob)
            );
        // Detect a clash where both PORT A and PORT B access the same location.
        wire emac_sram_rx_clash;
        assign emac_sram_rx_clash = (emac_rxdpram_ena & emac_rxdpram_enb & emac_rxdpram_addra == emac_rxdpram_addrb) &
                                  ~(double_error_injection | fault_sim_for_dc_en);
        always @(posedge emac_sram_rx_clash)
        begin
          // Check its not a glitch
          #8;
          if (emac_sram_rx_clash)
          begin
            $display ("**** WARNING: TB_DPRAM: EMAC RX Clash of write/read addresses");
            $display ("**** FAILED ****");
            $finish;
          end
        end

   `endif
`endif // edma_rx_pkt_buffer
`endif

`ifdef edma_rx_pkt_buffer

   `ifdef edma_spram


/*
      genvar R;
      generate for (R=0; R<4; R=R+1) begin : gen_rx_spram

         // Instanstiate the RX SPRAM - the default size is 64kB, so tie
         // off the upper address bits if we are not using them.
         TS1N28HPMB4096X32M8SWASO i_TS1N28HPMB4096X32M8SWASO_rx (
            .SLP(1'b0),
            .SD(1'b0),
            .CLK(hclk_to_gem),
            .CEB(~rxspram_en),
            .WEB(~rxspram_we),
            .AWT(1'b0),
            .A({{(12-`edma_rx_pbuf_addr){1'b0}}, rxspram_addr}),
            .D(rxspram_di[(R*32)+31:R*32]),
            .BWEB({32{1'b0}}),
            .RTSEL(2'b01),
            .WTSEL(3'b000),
            .Q(rxspram_do[(R*32)+31:R*32]));

      end
      endgenerate

*/
      tb_dpram #( .p_data_width(`edma_rx_pbuf_data+`edma_rx_pbuf_reduncy),
                  .p_depth(2**`edma_rx_pbuf_addr),
                  .p_addr_width(`edma_rx_pbuf_addr),
                  .p_ram_inactive_val(p_ram_inactive_val))

         i_rxspram (
            .a_we    (rxspram_we),
            .a_cs    (rxspram_en),
            .a_clk   (hclk_to_gem),
            .a_addr  (rxspram_addr),
            .a_wdata (rxspram_di),
            .a_rdata (rxspram_do),
            .b_we    (1'b0),
            .b_cs    (1'b0),
            .b_clk   (1'b0),
            .b_addr  ({`edma_rx_pbuf_addr{1'b0}}),
            .b_wdata ({(`edma_rx_pbuf_data+`edma_rx_pbuf_reduncy){1'b0}}),
            .b_rdata ()
            );


  assign rx_sram_read_add = rxspram_addr;

   `else

      tb_dpram #(.p_data_width(`edma_rx_pbuf_data+`edma_rx_pbuf_reduncy),
                 .p_depth(2**`edma_rx_pbuf_addr),
                 .p_addr_width(`edma_rx_pbuf_addr),
                 .p_ram_inactive_val(p_ram_inactive_val))
         i_rxdpram (
            .a_we    (rxdpram_wea),
            .a_cs    (rxdpram_ena),
            .a_clk   (rx_clk_to_gem),
            .a_addr  (rxdpram_addra),
            .a_wdata (rxdpram_dia),
            .a_rdata (rxdpram_doa),
            .b_we    (rxdpram_web),
            .b_cs    (rxdpram_enb),
            .b_clk   (hclk_to_gem),
            .b_addr  (rxdpram_addrb),
            .b_wdata (rxdpram_dib),
            .b_rdata (rxdpram_dob)
            );

        // Detect a clash where both PORT A and PORT B access the same location.
        wire sram_rx_clash;
        assign sram_rx_clash = (rxdpram_ena & rxdpram_enb & rxdpram_addra == rxdpram_addrb) &
                                  ~(double_error_injection | fault_sim_for_dc_en);
        always @(posedge sram_rx_clash)
        begin
          // Check its not a glitch
          #8;
          if (sram_rx_clash)
          begin
            $display ("**** WARNING: TB_DPRAM: RX Clash of write/read addresses");
            $display ("**** FAILED ****");
            $finish;
          end
        end

        assign rx_sram_read_add = rxdpram_addrb;
   `endif

`else
  assign rx_sram_read_add = {`edma_rx_pbuf_addr{1'b0}};
`endif // edma_rx_pkt_buffer



//------------------------------------------------------------------------------
// TX Dual Port Memory Instantiation
//------------------------------------------------------------------------------
`ifdef gem_has_802p3_br
`ifdef edma_tx_pkt_buffer
   `ifdef edma_spram
          tb_dpram #( .p_data_width(`edma_tx_pbuf_data+`edma_emac_tx_pbuf_reduncy),
                      .p_depth(2**`gem_emac_tx_pbuf_addr),
                      .p_addr_width(`gem_emac_tx_pbuf_addr),
                      .p_ram_inactive_val(p_ram_inactive_val))

         i_emac_txspram (
            .a_we    (emac_txspram_we),
            .a_cs    (emac_txspram_en),
            .a_clk   (hclk_to_gem),
            .a_addr  (emac_txspram_addr),
            .a_wdata (emac_txspram_di),
            .a_rdata (emac_txspram_do),
            .b_we    (1'b0),
            .b_cs    (1'b0),
            .b_clk   (1'b0),
            .b_addr  ({`gem_emac_tx_pbuf_addr{1'b0}}),
            .b_wdata ({(`edma_tx_pbuf_data+`edma_emac_tx_pbuf_reduncy){1'b0}}),
            .b_rdata ()
            );
   `else
      tb_dpram #(.p_data_width(`edma_tx_pbuf_data+`edma_emac_tx_pbuf_reduncy),
                 .p_depth(2**`gem_emac_tx_pbuf_addr),
                 .p_addr_width(`gem_emac_tx_pbuf_addr),
                 .p_ram_inactive_val(p_ram_inactive_val))

         i_emac_txdpram (
            .a_we    (emac_txdpram_wea),
            .a_cs    (emac_txdpram_ena),
            .a_clk   (hclk_to_gem),
            .a_addr  (emac_txdpram_addra),
            .a_wdata (emac_txdpram_dia),
            .a_rdata (),
            .b_we    (emac_txdpram_web),
            .b_cs    (emac_txdpram_enb),
            .b_clk   (tx_clk_to_gem),
            .b_addr  (emac_txdpram_addrb),
            .b_wdata ({(`edma_tx_pbuf_data+`edma_emac_tx_pbuf_reduncy){1'b0}}),
            .b_rdata (emac_txdpram_dob)
         );

        // Detect a clash where both PORT A and PORT B access the same location.
        wire emac_sram_tx_clash;
        assign emac_sram_tx_clash = (emac_txdpram_ena & emac_txdpram_enb & emac_txdpram_addra == emac_txdpram_addrb) &
                                  ~(double_error_injection | fault_sim_for_dc_en);
        always @(posedge emac_sram_tx_clash)
        begin
          // Check its not a glitch
          #8;
          if (emac_sram_tx_clash)
          begin
            $display ("**** WARNING: TB_DPRAM: EMAC RX Clash of write/read addresses");
            $display ("**** FAILED ****");
            $finish;
          end
        end

   `endif
`endif // edma_tx_pkt_buffer
`endif

`ifdef edma_tx_pkt_buffer


   `ifdef edma_spram

/*

      genvar T;
      generate for (T=0; T<4; T=T+1) begin : gen_tx_spram
         // Instanstiate the TX SPRAM - the default size is 64kB, so tie
         // off the upper address bits if we are not using them.

        // This SRAM model is real, and is located in Cadence internal environments
        // under
        // /process/tsmc/TSMC28HPM/TSMCHOME/sram/Compiler/ts1n28hpmb4096x32m8swaso_100c/VERILOG/ts1n28hpmb4096x32m8swaso_100c_ss0p81vm40c.v
         TS1N28HPMB4096X32M8SWASO i_TS1N28HPMB4096X32M8SWASO_tx (
            .SLP(1'b0),
            .SD(1'b0),
            .CLK(hclk_to_gem),
            .CEB(~txspram_en),
            .WEB(~txspram_we),
            .AWT(1'b0),
            .A({{(12-`edma_tx_pbuf_addr){1'b0}}, txspram_addr}),
            .D(txspram_di[(T*32)+31:T*32]),
            .BWEB({32{1'b0}}),
            .RTSEL(2'b01),
            .WTSEL(3'b000),
            .Q(txspram_do[(T*32)+31:T*32]));

      end
      endgenerate
*/

          tb_dpram #( .p_data_width(`edma_tx_pbuf_data+`edma_tx_pbuf_reduncy),
                      .p_depth(2**`edma_tx_pbuf_addr),
                      .p_addr_width(`edma_tx_pbuf_addr),
                      .p_ram_inactive_val(p_ram_inactive_val))

         i_txspram (
            .a_we    (txspram_we),
            .a_cs    (txspram_en),
            .a_clk   (hclk_to_gem),
            .a_addr  (txspram_addr),
            .a_wdata (txspram_di),
            .a_rdata (txspram_do),
            .b_we    (1'b0),
            .b_cs    (1'b0),
            .b_clk   (1'b0),
            .b_addr  ({`edma_tx_pbuf_addr{1'b0}}),
            .b_wdata ({(`edma_tx_pbuf_data+`edma_tx_pbuf_reduncy){1'b0}}),
            .b_rdata ()
            );


  assign tx_sram_read_add = txspram_addr;


   `else

      tb_dpram #(.p_data_width(`edma_tx_pbuf_data+`edma_tx_pbuf_reduncy),
                 .p_depth(2**`edma_tx_pbuf_addr),
                 .p_addr_width(`edma_tx_pbuf_addr),
                 .p_ram_inactive_val(p_ram_inactive_val))

         i_txdpram (
            .a_we    (txdpram_wea),
            .a_cs    (txdpram_ena),
            .a_clk   (hclk_to_gem),
            .a_addr  (txdpram_addra),
            .a_wdata (txdpram_dia),
            .a_rdata (),
            .b_we    (txdpram_web),
            .b_cs    (txdpram_enb),
            .b_clk   (tx_clk_to_gem),
            .b_addr  (txdpram_addrb),
            .b_wdata ({(`edma_tx_pbuf_data+`edma_tx_pbuf_reduncy){1'b0}}),
            .b_rdata (txdpram_dob)
            );

        // Detect a clash where both PORT A and PORT B access the same location.
        wire sram_tx_clash;
        assign sram_tx_clash = (txdpram_ena & txdpram_enb & txdpram_addra == txdpram_addrb) &
                                  ~(double_error_injection | fault_sim_for_dc_en);
        always @(posedge sram_tx_clash)
        begin
          // Check its not a glitch
          #8;
          if (sram_tx_clash)
          begin
            $display ("**** WARNING: TB_DPRAM: TX Clash of write/read addresses");
            $display ("**** FAILED ****");
            $finish;
          end
        end

  assign tx_sram_read_add = txdpram_addrb;
   `endif

`else
  assign tx_sram_read_add = {`edma_tx_pbuf_addr{1'b0}};
`endif // edma_tx_pkt_buffer


//------------------------------------------------------------------------------
// instantiate the clock/reset module.
//------------------------------------------------------------------------------

   gem_clk_cntrl i_clk_cntrl (

   // inputs.
   .n_reset(n_clk_ctl_rst),
   .pclk_source(pclk_source),
   .hclk_source(hclk_source),
   .rx_clk_from_phy(rx_clk_from_phy),
   .tx_clk_from_phy(tx_clk_from_phy),
   .gtx_ref_clk(gtx_ref_clk),
   .gtx20_ref_clk(gtx20_ref_clk),
  `ifdef gem_include_rmii
   .rmii_tx_clk(rmii_tx_clk),
   .rmii_rx_clk(rmii_rx_clk),
  `else
   .rmii_tx_clk(),
   .rmii_rx_clk(),
  `endif
   .rbc0_from_phy(rbc0_from_phy),
   .rbc1_from_phy(rbc1_from_phy),
   .pcs_rx_clk_from_phy(pma_rx_clk),
   .pcs_rx20_clk_from_phy(pma_rx20_clk),
   .mii_select(mii_select),
   .gigabit(gigabit),
   .tbi(tbi),
   .speed(speed),
   .loopback_local(loopback_local),
   .scan_clk(11'h000),
   .scan_test_mode(1'b0),

   // loopback clocks
   .loop_clk_source(loop_clk_source),
   .n_tx_clk_to_gem(n_tx_clk_to_gem),
//   .n_tx_clk_to_gem(n_tx_clk_to_gem_c),
   .n_rx_clk_to_gem(n_rx_clk_to_gem_c),


   // outputs
   .pclk_to_gem(pclk_to_gem),
   .hclk_to_gem(hclk_to_gem),
   .gtx_clk_to_gem(gtx_clk_to_gem),
   .gtx20_clk_to_gem(gtx20_clk_to_gem),
   .rbc0_to_gem(rbc0_to_gem),
   .rbc1_to_gem(rbc1_to_gem),
   .pcs_rx_clk_to_gem(pcs_rx_clk_to_gem),
   .pcs_rx20_clk_to_gem(pcs_rx20_clk_to_gem),
   .rx_clk_to_gem(rx_clk_to_gem_c),
   .tx_clk_to_gem(tx_clk_to_gem)
   );

// In RGMII mode, the clock must be delayed slightly with respect to the data. This is
// as per the RGMII spec
`ifdef gem_use_rgmii
  reg rx_clk_to_gem_del;
  reg n_rx_clk_to_gem_del;
  always@(rx_clk_to_gem_c) //was(rgmii_tx_clk_to_dut)
    rx_clk_to_gem_del = #4 rx_clk_to_gem_c;
  always@(n_rx_clk_to_gem_c) //was(rgmii_tx_clk_to_dut)
    n_rx_clk_to_gem_del = #4 n_rx_clk_to_gem_c;
  assign rx_clk_to_gem = rx_clk_to_gem_del;
  assign n_rx_clk_to_gem = n_rx_clk_to_gem_del;

  reg tx_clk_to_gem_del;     // used by tb_rgmii to sample tx data from gem_gxl
  reg n_tx_clk_to_gem_del;   // used by tb_rgmii to sample tx data from gem_gxl
  always@(tx_clk_to_gem)
    tx_clk_to_gem_del = #10 tx_clk_to_gem;  // Delay enough to guarantee TB will see GL variants
  always@(n_tx_clk_to_gem)
    n_tx_clk_to_gem_del = #10 n_tx_clk_to_gem;
`else
  assign rx_clk_to_gem = rx_clk_to_gem_c;
  assign n_rx_clk_to_gem = n_rx_clk_to_gem_c;
`endif



//------------------------------------------------------------------------------
// Flow Control toggle counters and checks
//------------------------------------------------------------------------------

assign q0_data_val = q0_data[0];
assign q1_data_val = q1_data[0];
assign q2_data_val = q2_data[0];
assign q3_data_val = q3_data[0];
assign q4_data_val = q4_data[0];
assign q5_data_val = q5_data[0];
assign q6_data_val = q6_data[0];
assign q7_data_val = q7_data[0];
assign q8_data_val = q8_data[0];
assign q9_data_val = q9_data[0];
assign q10_data_val = q10_data[0];
assign q11_data_val = q11_data[0];
assign q12_data_val = q12_data[0];
assign q13_data_val = q13_data[0];
assign q14_data_val = q14_data[0];
assign q15_data_val = q15_data[0];


  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      begin
      wr_tog_fail <= 0;
      end
    `ifdef dma_priority_queue15
    else
       wr_tog_fail <= 0;
    `else
    else if (dma_done & (q0_data_val !== 0)) // check toggle counts if
      begin                                  // random test
      if ((q0_data_val !== rx_databuf_wr_q0_cnt)
    `ifdef dma_priority_queue1
      | (q1_data_val !== rx_databuf_wr_q1_cnt)
    `endif
    `ifdef dma_priority_queue2
      | (q2_data_val !== rx_databuf_wr_q2_cnt)
    `endif
    `ifdef dma_priority_queue3
      | (q3_data_val !== rx_databuf_wr_q3_cnt)
    `endif
    `ifdef dma_priority_queue4
      | (q4_data_val !== rx_databuf_wr_q4_cnt)
    `endif
    `ifdef dma_priority_queue5
      | (q5_data_val !== rx_databuf_wr_q5_cnt)
    `endif
    `ifdef dma_priority_queue6
      | (q6_data_val !== rx_databuf_wr_q6_cnt)
    `endif
    `ifdef dma_priority_queue7
      | (q7_data_val !== rx_databuf_wr_q7_cnt)
    `endif
    `ifdef dma_priority_queue8
      | (q8_data_val !== rx_databuf_wr_q8_cnt)
    `endif
    `ifdef dma_priority_queue9
      | (q9_data_val !== rx_databuf_wr_q9_cnt)
    `endif
    `ifdef dma_priority_queue10
      | (q10_data_val !== rx_databuf_wr_q10_cnt)
    `endif
    `ifdef dma_priority_queue11
      | (q11_data_val !== rx_databuf_wr_q11_cnt)
    `endif
    `ifdef dma_priority_queue12
      | (q12_data_val !== rx_databuf_wr_q12_cnt)
    `endif
    `ifdef dma_priority_queue13
      | (q13_data_val !== rx_databuf_wr_q13_cnt)
    `endif
    `ifdef dma_priority_queue14
      | (q14_data_val !== rx_databuf_wr_q14_cnt)
    `endif
     )
       wr_tog_fail <= 1;
     else
       wr_tog_fail <= 0;
     end
    `endif
  end
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      begin
      flow_ctrl_done <= 0;
      end
    else
      flow_ctrl_done <= dma_done | double_error_injection;
  end

  `ifdef gem_ext_fifo_interface
  assign rx_databuf_wr_q0 = 1'b0;
  `endif

  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      begin
      rx_databuf_wr_q0_str <= 0;
 `ifdef dma_priority_queue1
      rx_databuf_wr_q1_str <= 0;
 `endif
 `ifdef dma_priority_queue2
      rx_databuf_wr_q2_str <= 0;
 `endif
 `ifdef dma_priority_queue3
      rx_databuf_wr_q3_str <= 0;
 `endif
 `ifdef dma_priority_queue4
      rx_databuf_wr_q4_str <= 0;
 `endif
 `ifdef dma_priority_queue5
      rx_databuf_wr_q5_str <= 0;
 `endif
 `ifdef dma_priority_queue6
      rx_databuf_wr_q6_str <= 0;
 `endif
 `ifdef dma_priority_queue7
      rx_databuf_wr_q7_str <= 0;
 `endif
 `ifdef dma_priority_queue8
      rx_databuf_wr_q8_str <= 0;
 `endif
 `ifdef dma_priority_queue9
      rx_databuf_wr_q9_str <= 0;
 `endif
 `ifdef dma_priority_queue10
      rx_databuf_wr_q10_str <= 0;
 `endif
 `ifdef dma_priority_queue11
      rx_databuf_wr_q11_str <= 0;
 `endif
 `ifdef dma_priority_queue12
      rx_databuf_wr_q12_str <= 0;
 `endif
 `ifdef dma_priority_queue13
      rx_databuf_wr_q13_str <= 0;
 `endif
 `ifdef dma_priority_queue14
      rx_databuf_wr_q14_str <= 0;
 `endif
 `ifdef dma_priority_queue15
      rx_databuf_wr_q15_str <= 0;
 `endif
      end
    else
      begin
      rx_databuf_wr_q0_str <= rx_databuf_wr_q0;
 `ifdef dma_priority_queue1
      rx_databuf_wr_q1_str <= rx_databuf_wr_q1;
 `endif
 `ifdef dma_priority_queue2
      rx_databuf_wr_q2_str <= rx_databuf_wr_q2;
 `endif
 `ifdef dma_priority_queue3
      rx_databuf_wr_q3_str <= rx_databuf_wr_q3;
 `endif
 `ifdef dma_priority_queue4
      rx_databuf_wr_q4_str <= rx_databuf_wr_q4;
 `endif
 `ifdef dma_priority_queue5
      rx_databuf_wr_q5_str <= rx_databuf_wr_q5;
 `endif
 `ifdef dma_priority_queue6
      rx_databuf_wr_q6_str <= rx_databuf_wr_q6;
 `endif
 `ifdef dma_priority_queue7
      rx_databuf_wr_q7_str <= rx_databuf_wr_q7;
 `endif
 `ifdef dma_priority_queue8
      rx_databuf_wr_q8_str <= rx_databuf_wr_q8;
 `endif
 `ifdef dma_priority_queue9
      rx_databuf_wr_q9_str <= rx_databuf_wr_q9;
 `endif
 `ifdef dma_priority_queue10
      rx_databuf_wr_q10_str <= rx_databuf_wr_q10;
 `endif
 `ifdef dma_priority_queue11
      rx_databuf_wr_q11_str <= rx_databuf_wr_q11;
 `endif
 `ifdef dma_priority_queue12
      rx_databuf_wr_q12_str <= rx_databuf_wr_q12;
 `endif
 `ifdef dma_priority_queue13
      rx_databuf_wr_q13_str <= rx_databuf_wr_q13;
 `endif
 `ifdef dma_priority_queue14
      rx_databuf_wr_q14_str <= rx_databuf_wr_q14;
 `endif
 `ifdef dma_priority_queue15
      rx_databuf_wr_q15_str <= rx_databuf_wr_q15;
 `endif
      end
  end


  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q0_cnt <= 0;
    else if (rx_databuf_wr_q0_edge)
      rx_databuf_wr_q0_cnt <= rx_databuf_wr_q0_cnt + 1;
  end
assign rx_databuf_wr_q0_edge = ((~rx_databuf_wr_q0_str & rx_databuf_wr_q0) ||
                                (rx_databuf_wr_q0_str & ~rx_databuf_wr_q0));

  `ifdef dma_priority_queue1
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q1_cnt <= 0;
    else if (rx_databuf_wr_q1_edge)
      rx_databuf_wr_q1_cnt <= rx_databuf_wr_q1_cnt + 1;
  end
assign rx_databuf_wr_q1_edge = ((~rx_databuf_wr_q1_str & rx_databuf_wr_q1) ||
                                (rx_databuf_wr_q1_str & ~rx_databuf_wr_q1));
  `endif

  `ifdef dma_priority_queue2
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q2_cnt <= 0;
    else if (rx_databuf_wr_q2_edge)
      rx_databuf_wr_q2_cnt <= rx_databuf_wr_q2_cnt + 1;
  end
assign rx_databuf_wr_q2_edge = ((~rx_databuf_wr_q2_str & rx_databuf_wr_q2) ||
                                (rx_databuf_wr_q2_str & ~rx_databuf_wr_q2));
  `endif
  `ifdef dma_priority_queue3
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q3_cnt <= 0;
    else if (rx_databuf_wr_q3_edge)
      rx_databuf_wr_q3_cnt <= rx_databuf_wr_q3_cnt + 1;
  end
assign rx_databuf_wr_q3_edge = ((~rx_databuf_wr_q3_str & rx_databuf_wr_q3) ||
                                (rx_databuf_wr_q3_str & ~rx_databuf_wr_q3));
  `endif
  `ifdef dma_priority_queue4
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q4_cnt <= 0;
    else if (rx_databuf_wr_q4_edge)
      rx_databuf_wr_q4_cnt <= rx_databuf_wr_q4_cnt + 1;
  end
assign rx_databuf_wr_q4_edge = ((~rx_databuf_wr_q4_str & rx_databuf_wr_q4) ||
                                (rx_databuf_wr_q4_str & ~rx_databuf_wr_q4));
  `endif
  `ifdef dma_priority_queue5
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q5_cnt <= 0;
    else if (rx_databuf_wr_q5_edge)
      rx_databuf_wr_q5_cnt <= rx_databuf_wr_q5_cnt + 1;
  end
assign rx_databuf_wr_q5_edge = ((~rx_databuf_wr_q5_str & rx_databuf_wr_q5) ||
                                (rx_databuf_wr_q5_str & ~rx_databuf_wr_q5));
  `endif
  `ifdef dma_priority_queue6
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q6_cnt <= 0;
    else if (rx_databuf_wr_q6_edge)
      rx_databuf_wr_q6_cnt <= rx_databuf_wr_q6_cnt + 1;
  end
assign rx_databuf_wr_q6_edge = ((~rx_databuf_wr_q6_str & rx_databuf_wr_q6) ||
                                (rx_databuf_wr_q6_str & ~rx_databuf_wr_q6));
  `endif
  `ifdef dma_priority_queue7
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q7_cnt <= 0;
    else if (rx_databuf_wr_q7_edge)
      rx_databuf_wr_q7_cnt <= rx_databuf_wr_q7_cnt + 1;
  end
assign rx_databuf_wr_q7_edge = ((~rx_databuf_wr_q7_str & rx_databuf_wr_q7) ||
                                (rx_databuf_wr_q7_str & ~rx_databuf_wr_q7));
  `endif
  `ifdef dma_priority_queue8
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q8_cnt <= 0;
    else if (rx_databuf_wr_q8_edge)
      rx_databuf_wr_q8_cnt <= rx_databuf_wr_q8_cnt + 1;
  end
assign rx_databuf_wr_q8_edge = ((~rx_databuf_wr_q8_str & rx_databuf_wr_q8) ||
                                (rx_databuf_wr_q8_str & ~rx_databuf_wr_q8));
  `endif
  `ifdef dma_priority_queue9
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q9_cnt <= 0;
    else if (rx_databuf_wr_q9_edge)
      rx_databuf_wr_q9_cnt <= rx_databuf_wr_q9_cnt + 1;
  end
assign rx_databuf_wr_q9_edge = ((~rx_databuf_wr_q9_str & rx_databuf_wr_q9) ||
                                (rx_databuf_wr_q9_str & ~rx_databuf_wr_q9));
  `endif
  `ifdef dma_priority_queue10
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q10_cnt <= 0;
    else if (rx_databuf_wr_q10_edge)
      rx_databuf_wr_q10_cnt <= rx_databuf_wr_q10_cnt + 1;
  end
assign rx_databuf_wr_q10_edge = ((~rx_databuf_wr_q10_str & rx_databuf_wr_q10) ||
                                (rx_databuf_wr_q10_str & ~rx_databuf_wr_q10));
  `endif
  `ifdef dma_priority_queue11
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q11_cnt <= 0;
    else if (rx_databuf_wr_q11_edge)
      rx_databuf_wr_q11_cnt <= rx_databuf_wr_q11_cnt + 1;
  end
assign rx_databuf_wr_q11_edge = ((~rx_databuf_wr_q11_str & rx_databuf_wr_q11) ||
                                (rx_databuf_wr_q11_str & ~rx_databuf_wr_q11));
  `endif
  `ifdef dma_priority_queue12
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q12_cnt <= 0;
    else if (rx_databuf_wr_q12_edge)
      rx_databuf_wr_q12_cnt <= rx_databuf_wr_q12_cnt + 1;
  end
assign rx_databuf_wr_q12_edge = ((~rx_databuf_wr_q12_str & rx_databuf_wr_q12) ||
                                (rx_databuf_wr_q12_str & ~rx_databuf_wr_q12));
  `endif
  `ifdef dma_priority_queue13
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q13_cnt <= 0;
    else if (rx_databuf_wr_q13_edge)
      rx_databuf_wr_q13_cnt <= rx_databuf_wr_q13_cnt + 1;
  end
assign rx_databuf_wr_q13_edge = ((~rx_databuf_wr_q13_str & rx_databuf_wr_q13) ||
                                (rx_databuf_wr_q13_str & ~rx_databuf_wr_q13));
  `endif
  `ifdef dma_priority_queue14
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q14_cnt <= 0;
    else if (rx_databuf_wr_q14_edge)
      rx_databuf_wr_q14_cnt <= rx_databuf_wr_q14_cnt + 1;
  end
assign rx_databuf_wr_q14_edge = ((~rx_databuf_wr_q14_str & rx_databuf_wr_q14) ||
                                (rx_databuf_wr_q14_str & ~rx_databuf_wr_q14));
  `endif
  `ifdef dma_priority_queue15
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      rx_databuf_wr_q15_cnt <= 0;
    else if (rx_databuf_wr_q15_edge)
      rx_databuf_wr_q15_cnt <= rx_databuf_wr_q15_cnt + 1;
  end
assign rx_databuf_wr_q15_edge = ((~rx_databuf_wr_q15_str & rx_databuf_wr_q15) ||
                                (rx_databuf_wr_q15_str & ~rx_databuf_wr_q15));
  `endif

// Check that the minimum time between toggles is at least 12 hclk cycles
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q0_first_tog <= 0;
    else if (rx_databuf_wr_q0_edge)
      q0_first_tog <= 1;
  end
  `ifdef dma_priority_queue1
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q1_first_tog <= 0;
    else if (rx_databuf_wr_q1_edge)
      q1_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue2
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q2_first_tog <= 0;
    else if (rx_databuf_wr_q2_edge)
      q2_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue3
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q3_first_tog <= 0;
    else if (rx_databuf_wr_q3_edge)
      q3_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue4
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q4_first_tog <= 0;
    else if (rx_databuf_wr_q4_edge)
      q4_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue5
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q5_first_tog <= 0;
    else if (rx_databuf_wr_q5_edge)
      q5_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue6
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q6_first_tog <= 0;
    else if (rx_databuf_wr_q6_edge)
      q6_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue7
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q7_first_tog <= 0;
    else if (rx_databuf_wr_q7_edge)
      q7_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue8
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q8_first_tog <= 0;
    else if (rx_databuf_wr_q8_edge)
      q8_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue9
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q9_first_tog <= 0;
    else if (rx_databuf_wr_q9_edge)
      q9_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue10
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q10_first_tog <= 0;
    else if (rx_databuf_wr_q10_edge)
      q10_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue11
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q11_first_tog <= 0;
    else if (rx_databuf_wr_q11_edge)
      q11_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue12
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q12_first_tog <= 0;
    else if (rx_databuf_wr_q12_edge)
      q12_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue13
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q13_first_tog <= 0;
    else if (rx_databuf_wr_q13_edge)
      q13_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue14
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q14_first_tog <= 0;
    else if (rx_databuf_wr_q14_edge)
      q14_first_tog <= 1;
  end
  `endif
  `ifdef dma_priority_queue15
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q15_first_tog <= 0;
    else if (rx_databuf_wr_q15_edge)
      q15_first_tog <= 1;
  end
  `endif

  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q0_cycle_cnt <= 0;
    else if (rx_databuf_wr_q0_edge)
    begin
      q0_cycle_cnt <= 0;
     // $display("Time between q0 toggles = %d",q0_cycle_cnt);
    end
    else if (~dma_done & q0_first_tog)
      q0_cycle_cnt <= q0_cycle_cnt + 1;
  end

  `ifdef dma_priority_queue1
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q1_cycle_cnt <= 0;
    else if (rx_databuf_wr_q1_edge)
    begin
      q1_cycle_cnt <= 0;
    //  $display(" Time between q1 toggles = %d",q1_cycle_cnt);
    end
    else if (~dma_done & q1_first_tog)
      q1_cycle_cnt <= q1_cycle_cnt + 1;
  end
  `endif

  `ifdef dma_priority_queue2
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q2_cycle_cnt <= 0;
    else if (rx_databuf_wr_q2_edge)
    begin
      q2_cycle_cnt <= 0;
    //  $display("Time between q2 toggles = %d",q2_cycle_cnt);
    end

    else if (~dma_done & q2_first_tog)
      q2_cycle_cnt <= q2_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue3
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q3_cycle_cnt <= 0;
    else if (rx_databuf_wr_q3_edge)
    begin
      q3_cycle_cnt <= 0;
    //  $display("Time between q3 toggles = %d",q3_cycle_cnt);
    end

    else if (~dma_done & q3_first_tog)
      q3_cycle_cnt <= q3_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue4
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q4_cycle_cnt <= 0;
    else if (rx_databuf_wr_q4_edge)
    begin
      q4_cycle_cnt <= 0;
    //  $display("Time between q4 toggles = %d",q4_cycle_cnt);
    end

    else if (~dma_done & q4_first_tog)
      q4_cycle_cnt <= q4_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue5
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q5_cycle_cnt <= 0;
    else if (rx_databuf_wr_q5_edge)
    begin
      q5_cycle_cnt <= 0;
    //  $display("Time between q5 toggles = %d",q5_cycle_cnt);
    end

    else if (~dma_done & q5_first_tog)
      q5_cycle_cnt <= q5_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue6
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q6_cycle_cnt <= 0;
    else if (rx_databuf_wr_q6_edge)
    begin
      q6_cycle_cnt <= 0;
    //  $display("Time between q6 toggles = %d",q6_cycle_cnt);
    end

    else if (~dma_done & q6_first_tog)
      q6_cycle_cnt <= q6_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue7
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q7_cycle_cnt <= 0;
    else if (rx_databuf_wr_q7_edge)
    begin
      q7_cycle_cnt <= 0;
    //  $display("Time between q7 toggles = %d",q7_cycle_cnt);
    end

    else if (~dma_done & q7_first_tog)
      q7_cycle_cnt <= q7_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue8
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q8_cycle_cnt <= 0;
    else if (rx_databuf_wr_q8_edge)
    begin
      q8_cycle_cnt <= 0;
    //  $display("Time between q8 toggles = %d",q8_cycle_cnt);
    end

    else if (~dma_done & q8_first_tog)
      q8_cycle_cnt <= q8_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue9
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q9_cycle_cnt <= 0;
    else if (rx_databuf_wr_q9_edge)
    begin
      q9_cycle_cnt <= 0;
    //  $display("Time between q9 toggles = %d",q9_cycle_cnt);
    end

    else if (~dma_done & q9_first_tog)
      q9_cycle_cnt <= q9_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue10
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q10_cycle_cnt <= 0;
    else if (rx_databuf_wr_q10_edge)
    begin
      q10_cycle_cnt <= 0;
    //  $display("Time between q10 toggles = %d",q10_cycle_cnt);
    end

    else if (~dma_done & q10_first_tog)
      q10_cycle_cnt <= q10_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue11
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q11_cycle_cnt <= 0;
    else if (rx_databuf_wr_q11_edge)
    begin
      q11_cycle_cnt <= 0;
    //  $display("Time between q11 toggles = %d",q11_cycle_cnt);
    end

    else if (~dma_done & q11_first_tog)
      q11_cycle_cnt <= q11_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue12
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q12_cycle_cnt <= 0;
    else if (rx_databuf_wr_q12_edge)
    begin
      q12_cycle_cnt <= 0;
    //  $display("Time between q12 toggles = %d",q12_cycle_cnt);
    end

    else if (~dma_done & q12_first_tog)
      q12_cycle_cnt <= q12_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue13
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q13_cycle_cnt <= 0;
    else if (rx_databuf_wr_q13_edge)
    begin
      q13_cycle_cnt <= 0;
    //  $display("Time between q13 toggles = %d",q13_cycle_cnt);
    end

    else if (~dma_done & q13_first_tog)
      q13_cycle_cnt <= q13_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue14
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q14_cycle_cnt <= 0;
    else if (rx_databuf_wr_q14_edge)
    begin
      q14_cycle_cnt <= 0;
    //  $display("Time between q14 toggles = %d",q14_cycle_cnt);
    end

    else if (~dma_done & q14_first_tog)
      q14_cycle_cnt <= q14_cycle_cnt + 1;
  end
  `endif
  `ifdef dma_priority_queue15
  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      q15_cycle_cnt <= 0;
    else if (rx_databuf_wr_q15_edge)
    begin
      q15_cycle_cnt <= 0;
    //  $display("Time between q15 toggles = %d",q15_cycle_cnt);
    end

    else if (~dma_done & q15_first_tog)
      q15_cycle_cnt <= q15_cycle_cnt + 1;
  end
  `endif

  always@(posedge hclk_to_gem or n_rxreset)
  begin
    if (~n_rxreset)
      min_toggle_time_fail <= 0;
    else if (                    ((rx_databuf_wr_q0_edge & q0_first_tog & (q0_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `ifdef dma_priority_queue1
                                  (rx_databuf_wr_q1_edge & q1_first_tog & (q1_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue2
                                  (rx_databuf_wr_q2_edge & q2_first_tog & (q2_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue3
                                  (rx_databuf_wr_q3_edge & q3_first_tog & (q3_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue4
                                  (rx_databuf_wr_q4_edge & q4_first_tog & (q4_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue5
                                  (rx_databuf_wr_q5_edge & q5_first_tog & (q5_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue6
                                  (rx_databuf_wr_q6_edge & q6_first_tog & (q6_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue7
                                  (rx_databuf_wr_q7_edge & q7_first_tog & (q7_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue8
                                  (rx_databuf_wr_q8_edge & q8_first_tog & (q8_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue9
                                  (rx_databuf_wr_q9_edge & q9_first_tog & (q9_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue10
                                  (rx_databuf_wr_q10_edge & q10_first_tog & (q10_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue11
                                  (rx_databuf_wr_q11_edge & q11_first_tog & (q11_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue12
                                  (rx_databuf_wr_q12_edge & q12_first_tog & (q12_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue13
                                  (rx_databuf_wr_q13_edge & q13_first_tog & (q13_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue14
                                  (rx_databuf_wr_q14_edge & q14_first_tog & (q14_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  `ifdef dma_priority_queue15
                                  (rx_databuf_wr_q15_edge & q15_first_tog & (q15_cycle_cnt < MIN_TOGGLE_TIME_FAIL)) |
  `endif
  1'b0 ))
      min_toggle_time_fail <= 1;
  end

// -----------------------------------------------------------------
// RGMII Integration ...
// -----------------------------------------------------------------
`ifdef gem_use_rgmii

  wire       rgmii_rx_ctl_tb;
  wire [3:0] rgmii_rxd_tb;
  wire [7:0] txd_tb;
  wire       tx_er_tb;
  wire       tx_en_tb;

  assign sel_mii_on_rgmii =`hierarchy.sel_mii_on_rgmii;

  assign rgmii_rxd    = (sel_mii_on_rgmii)? rxd[3:0] : rgmii_rxd_tb;
  assign rgmii_rx_ctl = (sel_mii_on_rgmii)? rx_dv    : rgmii_rx_ctl_tb;

  assign txd   = (sel_mii_on_rgmii)? {4'h0, rgmii_txd} : txd_tb;
  assign tx_en = (sel_mii_on_rgmii)? rgmii_tx_ctl      : tx_en_tb;
  assign tx_er_tb2 = (sel_mii_on_rgmii)? tx_er         : tx_er_tb;

//  assign n_rx_clk_to_gem = n_rx_clk_to_gem_del & ~sel_mii_on_rgmii;
//  assign n_ntxreset = n_ntxreset_int & ~sel_mii_on_rgmii;
//  assign n_nrxreset = n_nrxreset_int & ~sel_mii_on_rgmii;
//  assign n_tx_clk_to_gem = n_tx_clk_to_gem_c;

    tb_rgmii i_tb_rgmii(

      // RX clocks and resets
      .n_rgmii_rxreset         (n_rxreset),
      .n_rgmii_rx_n_reset      (n_nrxreset),
      .rgmii_rx_clk            (tx_clk_to_gem_del),
      .rgmii_rx_n_clk          (n_tx_clk_to_gem_del),
      .rbc1_sig                (1'b0),

      // TX clocks and resets
      .rgmii_tx_clk_sig        (rgmii_tx_clk_sig_to_dut),
      .n_rgmii_txreset         (n_txreset),
      .n_rgmii_tx_n_reset      (n_ntxreset),
      .rgmii_tx_clk            (rx_clk_to_gem_c),
      .rgmii_tx_n_clk          (n_rx_clk_to_gem_c),

      // RGMII signals
      .rgmii_txd               (rgmii_rxd_tb),
      .rgmii_tx_ctl            (rgmii_rx_ctl_tb),
      .rgmii_rxd               (rgmii_txd),
      .rgmii_rx_ctl            (rgmii_tx_ctl),

      // gmii / mii ethernet interface.
      .gmii_col                (col),
      .gmii_crs                (crs),
      .gmii_tx_er              (rx_er),
      .gmii_txd                (rxd[7:0]),
      .gmii_tx_en              (rx_dv | col_tb | (crs_tb & ~tx_en)),
      .gmii_rxd                (txd_tb[7:0]),
      .gmii_rx_er              (tx_er_tb),
      .gmii_rx_dv              (tx_en_tb),
      .gmii_gigabit            (speed_mode[1]),
      .gmii_link_status        (),
      .gmii_speed              (),
      .gmii_duplex_out         (),
      .gmii_duplex_in          (!half_duplex),

      // ten bit interface signals.
      .tbi_tx_group            (10'h000),
      .tbi_rx_group            (),
      .tbi                     (1'b0)

      );
   parameter   TX_CLK_SIG_DEL   = 1;   // RGMII TX clock to data signal delay (0.1ns)

   // RGMII transmit interface clock data supplied to the DUT
   // The RGMII module also uses the transmit clock as a select for an
   // output mux (only if not using the X2 clock), so thtis must be
   // supplied as data, before the start of the clock tree. As such an
   // arbitary delay is added to prevent timing violations.
   always@(tx_clk_to_gem)
      begin
         rgmii_tx_clk_sig_to_dut = #(TX_CLK_SIG_DEL) tx_clk_to_gem | sel_mii_on_rgmii;
      end

`else
assign col = col_tb;
assign crs = crs_tb;
assign tx_er_tb2 = tx_er;
`endif


// only do coverage for rtl
`ifdef rtl
  wire disable_asf_assertions;
  assign disable_asf_assertions = double_error_injection | fault_sim_for_dc_en;
sv_coverage sv_coverage (
  .disable_asf_assertions(disable_asf_assertions)
);
`else
`endif

endmodule

