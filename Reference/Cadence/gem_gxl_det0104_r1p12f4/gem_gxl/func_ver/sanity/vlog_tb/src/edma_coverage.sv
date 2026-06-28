//------------------------------------------------------------------------------
// Copyright (c) 2013-2017 Cadence Design Systems, Inc.
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
//   Filename:           edma_coverage.sv
//   Module Name:        edma_coverage
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
//   Description :
//
// Functional coverage buckets and sampling for the edma design.
//
//------------------------------------------------------------------------------


`include "gem_gxl_defs.v"
`include "edma_defs.v"

module edma_coverage ();

`ifndef EDMA_TOP_HIERARCHY

  `ifdef edma_axi
    `define EDMA_TOP_HIERARCHY i_edma_pbuf_axi_top
  `else
    `define EDMA_TOP_HIERARCHY i_edma_pbuf_ahb_top
  `endif

  `ifdef gem_ext_fifo_interface
    `define MAC_TOP_HIERARCHY     i_gem_gxl.i_gem_ss.i_gem_top.i_gem_mac
  `else
    `define MAC_TOP_HIERARCHY     i_gem_mac
  `endif
`endif

`ifndef EDMA_UNDERFLOW_TOP_HIERARCHY
  `define EDMA_UNDERFLOW_TOP_HIERARCHY `EDMA_TOP_HIERARCHY
`endif

`ifdef edma_axi
  `define EDMA_TX_WR_HIERARCHY `EDMA_TOP_HIERARCHY.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_wr
  `define EDMA_TX_RD_HIERARCHY `EDMA_TOP_HIERARCHY.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd
  `define EDMA_TX_RD_UNDERFLOW_TOP_HIERARCHY `EDMA_UNDERFLOW_TOP_HIERARCHY.i_edma_pbuf_axi_tx.i_edma_pbuf_axi_tx_rd
`else
  `define EDMA_TOP_HIERARCHY i_edma_pbuf_ahb_top
  `define EDMA_TX_WR_HIERARCHY `EDMA_TOP_HIERARCHY.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_wr
  `define EDMA_TX_RD_HIERARCHY `EDMA_TOP_HIERARCHY.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_rd
  `define EDMA_TX_RD_UNDERFLOW_TOP_HIERARCHY `EDMA_UNDERFLOW_TOP_HIERARCHY.i_edma_pbuf_ahb_tx.i_edma_pbuf_ahb_tx_rd
`endif


  `ifdef MDV

    // -----------------------------------------------------------------------
    //
    //                          Internal Signals
    //
    // -----------------------------------------------------------------------



    logic sampled_config;
    logic axi_mode;
    integer unsigned tx_frame_size = 0, tx_frame_size_underflow = 0, rx_frame_size = 0;
    integer unsigned frame_count = 0;
    integer unsigned rx_overflow_count = 0;
    integer unsigned tx_underflow_count = 0;
    integer unsigned tx_queue, tx_buffers_per_frame, tx_buffer_size;
    integer host_period;

    logic m_cg_tx_good_frames_sample = 1'b0, m_cg_tx_bad_frames_sample = 1'b0, m_cg_test_frame_count_sample = 1'b0;
    logic m_cg_rx_bad_frames_sample = 1'b0, m_cg_rx_good_frames_sample = 1'b0;
    logic m_cg_rx_overflows_sample = 1'b0, m_cg_rx_overflow_frames_sample = 1'b0;
    logic m_cg_multi_buffer_buffers_per_frame_sample = 1'b0, m_cg_multi_buffer_sizes_sample = 1'b0;
    logic m_cg_tx_underflows_sample = 1'b0, m_cg_tx_underflow_frames_sample = 1'b0;
    logic sample_host_period = 1'b0;

    logic m_cg_tx_good_frames_sample_p = 1'b0, m_cg_tx_bad_frames_sample_p = 1'b0, m_cg_test_frame_count_sample_p = 1'b0;
    logic m_cg_rx_bad_frames_sample_p = 1'b0, m_cg_rx_good_frames_sample_p = 1'b0;
    logic m_cg_rx_overflows_sample_p = 1'b0, m_cg_rx_overflow_frames_sample_p = 1'b0;
    logic m_cg_multi_buffer_buffers_per_frame_sample_p = 1'b0, m_cg_multi_buffer_sizes_sample_p = 1'b0;
    logic m_cg_tx_underflows_sample_p = 1'b0, m_cg_tx_underflow_frames_sample_p = 1'b0;
    logic sample_host_period_p = 1'b0;


    // -----------------------------------------------------------------------
    //
    //                      Cover Points and Groups
    //
    // -----------------------------------------------------------------------

    `ifdef edma_axi
      assign axi_mode = 1;
    `else
      assign axi_mode = 0;
    `endif

    // -----------------AXI -----------------

    `define CP_AXI_MODE \
      cp_axi_mode : coverpoint (axi_mode) { \
        bins axi = {1}; \
      }

    covergroup cg_axi_mode @(posedge sampled_config);
      `CP_AXI_MODE
    endgroup
    cg_axi_mode m_cg_axi_mode = new();

    // ----------------- AHB Mode -----------------

    `define CP_AHB_MODE \
      cp_ahb_mode : coverpoint (axi_mode) { \
        bins ahb = {0}; \
      }

    covergroup cg_ahb_mode @(posedge sampled_config);
      `CP_AHB_MODE
    endgroup
    cg_ahb_mode m_cg_ahb_mode = new();

    // ----------------- DMA Bus Width -----------------

    `define CP_DMA_BUS_WIDTH \
      cp_dma_bus_width : coverpoint (`EDMA_TOP_HIERARCHY.dma_bus_width) { \
        bins dma_bus_width_32b  = {0}; \
        bins dma_bus_width_64b  = {1}; \
        bins dma_bus_width_128b = {2}; \
      }
    // ----------------- DMA Address Bus Width -----------------

    `define CP_DMA_ADDR_BUS_WIDTH \
      cp_addr_bus_width : coverpoint (`EDMA_TOP_HIERARCHY.dma_addr_bus_width) { \
        bins dma_addr_bus_width_32b  = {0}; \
        bins dma_addr_bus_width_64b  = {1}; \
      }

    covergroup cg_dma_bus_width @(posedge sampled_config);
      `CP_DMA_BUS_WIDTH
    endgroup
    cg_dma_bus_width m_cg_dma_bus_width = new();


    // ----------------- AXI AR2R/AW2W Pipeline Depth -----------------

    // Note that the SoC testbench does not support more than 4 outstanding
    `define CP_AXI_PIPELINE_DEPTH \
        bins bin_1 = {1}; \
        bins bin_2 = {2}; \
        bins bin_3 = {3}; \
        bins bin_4 = {4}; \
        bins bin_5_to_255 = {[5:255]};

    logic [7:0] max_num_axi_ar2r;
    `ifdef edma_axi
      assign max_num_axi_ar2r = `EDMA_TOP_HIERARCHY.max_num_axi_ar2r;
    `else
      assign max_num_axi_ar2r = 8'd0;
    `endif
    covergroup cg_axi_ar2r_max_pipeline @(posedge sampled_config);
      cp_ar2r_max_pipeline : coverpoint (max_num_axi_ar2r) {
        `CP_AXI_PIPELINE_DEPTH
      }
    endgroup
    cg_axi_ar2r_max_pipeline m_cg_axi_ar2r_max_pipeline = new();

    logic [7:0] max_num_axi_aw2w;
    `ifdef edma_axi
      assign max_num_axi_aw2w = `EDMA_TOP_HIERARCHY.max_num_axi_aw2w;
    `else
      assign max_num_axi_aw2w = 8'd0;
    `endif
    covergroup cg_axi_aw2w_max_pipeline @(posedge sampled_config);
      cp_aw2w_max_pipeline : coverpoint (max_num_axi_aw2w) {
        `CP_AXI_PIPELINE_DEPTH
      }
    endgroup
    cg_axi_aw2w_max_pipeline m_cg_axi_aw2w_max_pipeline = new();

    // ----------------- Burst Length -----------------

    `define CP_DMA_BURST_LENGTH \
      cp_dma_burst_length : coverpoint (`EDMA_TOP_HIERARCHY.ahb_burst_length) { \
        bins dma_burst_length_1 = {1}; \
        bins dma_burst_length_2 = {2}; \
        bins dma_burst_length_4 = {4}; \
        bins dma_burst_length_8 = {8}; \
        bins dma_burst_length_16 = {16}; \
      }
    covergroup cg_dma_burst_length @(posedge sampled_config);
      `CP_DMA_BURST_LENGTH
    endgroup
    cg_dma_burst_length m_cg_dma_burst_length = new();

    // ----------------- SRAM Mode ---------------

    logic sram_mode;
    `ifdef edma_spram
      assign spram_mode = 1;
    `else
      assign spram_mode = 0;
    `endif

    wire [31:0] tx_pbuf_addr_cp;
    wire [31:0] rx_pbuf_addr_cp;
    wire [31:0] tx_pbuf_data_cp;
    wire [31:0] rx_pbuf_data_cp;

    // We want to collect the following coverage only in spram mode
    // so we will just consider the following 4 wires tied to zero
    // otherwise. This will avoid using the construct iff spram_mode
    // on the sample point which looks like giving us merge problems
    assign tx_pbuf_addr_cp = spram_mode? `edma_tx_pbuf_addr: 32'd0;
    assign rx_pbuf_addr_cp = spram_mode? `edma_rx_pbuf_addr: 32'd0;
    assign tx_pbuf_data_cp = spram_mode? `edma_tx_pbuf_data: 32'd0;
    assign rx_pbuf_data_cp = spram_mode? `edma_rx_pbuf_data: 32'd0;

    `define CP_SRAM_MODE \
      cp_sram_mode : coverpoint (spram_mode) { \
        bins spram = {1}; \
        bins dpram = {0}; \
      }
    covergroup cg_sram_mode @(posedge sampled_config);
      `CP_SRAM_MODE

      tx_sram_addr_size: coverpoint (tx_pbuf_addr_cp) {
        ignore_bins invalid_sizes_lo = {[0:8]};
        ignore_bins invalid_sizes_hi = {[17:$]};
        bins        two_pwr_9        = {9};
        bins        two_pwr_10       = {10};
        bins        two_pwr_11       = {11};
        bins        two_pwr_12       = {12};
        bins        two_pwr_13       = {13};
        bins        two_pwr_14       = {14};
        bins        two_pwr_15       = {15};
        bins        two_pwr_16       = {16};
      }

      rx_sram_addr_size: coverpoint (rx_pbuf_addr_cp) {
        ignore_bins intwo_pwr_id_sizes_lo = {[0:8]};
        ignore_bins intwo_pwr_id_sizes_hi = {[17:$]};
        bins        two_pwr_9             = {9};
        bins        two_pwr_10            = {10};
        bins        two_pwr_11            = {11};
        bins        two_pwr_12            = {12};
        bins        two_pwr_13            = {13};
        bins        two_pwr_14            = {14};
        bins        two_pwr_15            = {15};
        bins        two_pwr_16            = {16};
      }

      tx_sram_data_size: coverpoint (tx_pbuf_data_cp) {
        ignore_bins invalid_tx_sram_setting_32 = {32};
        ignore_bins invalid_tx_sram_setting_64 = {64};
        bins data_width_128b = {128};
      }
      rx_sram_data_size: coverpoint (rx_pbuf_data_cp) {
        ignore_bins invalid_rx_sram_setting_32 = {32};
        ignore_bins invalid_rx_sram_setting_64 = {64};
        bins data_width_128b = {128};
      }
    endgroup
    cg_sram_mode m_cg_sram_mode = new();

    // ----------------- AXI Functional Cross coverage ---------------

    covergroup cg_cross_axi_interface @(posedge sampled_config);
      `CP_AXI_MODE
      `CP_SRAM_MODE
      `CP_DMA_BUS_WIDTH
      `CP_DMA_BURST_LENGTH
      cross cp_axi_mode, cp_sram_mode, cp_dma_bus_width, cp_dma_burst_length {
        // SPRAM does not support 128b on the dma bus width.
        ignore_bins x = binsof(cp_dma_bus_width.dma_bus_width_128b) && binsof(cp_sram_mode.spram);
      }
    endgroup
    cg_cross_axi_interface m_cg_cross_axi_interface = new();

    // ----------------- AHB Functional Cross coverage ---------------

    covergroup cg_cross_ahb_interface @(posedge sampled_config);
      `CP_AHB_MODE
      `CP_SRAM_MODE
      `CP_DMA_BUS_WIDTH
      `CP_DMA_BURST_LENGTH
      cross cp_ahb_mode, cp_sram_mode, cp_dma_bus_width, cp_dma_burst_length {
        // 128b bus width is not supported in ahb mode
        ignore_bins x = binsof(cp_dma_bus_width.dma_bus_width_128b);
      }
    endgroup
    cg_cross_ahb_interface m_cg_cross_ahb_interface = new();

    // ----------------- Priority Queues ---------------

    logic [4:0] edma_queues;
    assign edma_queues = `edma_queues;
    `define CP_PRIORITY_QUEUES \
      cp_priority_queues : coverpoint (edma_queues) { \
        bins bin_1 = {1}; \
        bins bin_2to7 = {[2:7]}; \
        bins bin_8to16 = {[8:16]}; \
      }
    `define CP_PRIORITY_QUEUES_SMPL \
      cp_priority_queues_smpl : coverpoint (edma_queues) { \
        bins bin_single = {1}; \
        bins bin_multi  = {[2:16]}; \
      }
    covergroup cg_priority_queues @(posedge sampled_config);
      `CP_PRIORITY_QUEUES
      `CP_PRIORITY_QUEUES_SMPL
    endgroup
    cg_priority_queues m_cg_priority_queues = new();

    // ------------ TX Store and Forward ----------

    `define CP_TX_FORWARD_MODE \
      cp_tx_forward_mode : coverpoint (`EDMA_TOP_HIERARCHY.tx_cutthru) { \
        bins full_store_and_forward = {0}; \
        bins partial_store_and_forward = {1}; \
      }
    covergroup cg_tx_forward_mode @(posedge sampled_config);
      `CP_TX_FORWARD_MODE
    endgroup
    cg_tx_forward_mode m_cg_tx_forward_mode = new();

    // ------------ RX Store and Forward ----------

    `define CP_RX_FORWARD_MODE \
      cp_rx_forward_mode : coverpoint (`EDMA_TOP_HIERARCHY.rx_cutthru) { \
        bins full_store_and_forward = {0}; \
        bins partial_store_and_forward = {1}; \
      }
    covergroup cg_rx_forward_mode @(posedge sampled_config);
      `CP_RX_FORWARD_MODE
    endgroup
    cg_rx_forward_mode m_cg_rx_forward_mode = new();

    // ------------ TX Extended Buffer Descriptor ----------

    `define CP_TX_EXTENDED_BUFFER_DESCRIPTOR_MODE \
      cp_tx_extended_buffer_descriptor_mode : coverpoint (`EDMA_TOP_HIERARCHY.tx_bd_extended_mode_en) { \
        bins inactive = {0}; \
        bins active = {1}; \
      }
    covergroup cg_tx_extended_buffer_descriptor_mode @(posedge sampled_config);
      `CP_TX_EXTENDED_BUFFER_DESCRIPTOR_MODE
    endgroup
    cg_tx_extended_buffer_descriptor_mode m_cg_tx_extended_buffer_descriptor_mode = new();

    // ------------ RX Extended Buffer Descriptor ----------

    `define CP_RX_EXTENDED_BUFFER_DESCRIPTOR_MODE \
      cp_rx_extended_buffer_descriptor_mode : coverpoint (`EDMA_TOP_HIERARCHY.rx_bd_extended_mode_en) { \
        bins inactive = {0}; \
        bins active = {1}; \
      }
    covergroup cg_rx_extended_buffer_descriptor_mode @(posedge sampled_config);
      `CP_RX_EXTENDED_BUFFER_DESCRIPTOR_MODE
    endgroup
    cg_rx_extended_buffer_descriptor_mode m_cg_rx_extended_buffer_descriptor_mode = new();

    // ------------ Credit Based Shaping ----------

    `define CP_CREDIT_BASED_SHAPING \
      cp_credit_based_shaping : coverpoint (`MAC_TOP_HIERARCHY.cbs_enable) { \
        bins inactive = {0}; \
        bins queue_a = {1}; \
        bins queue_a_and_b = {3}; \
      }
    covergroup cg_credit_based_shaping @(posedge sampled_config);
      `CP_CREDIT_BASED_SHAPING
    endgroup
    cg_credit_based_shaping m_cg_credit_based_shaping = new();

    // ------------ Test Number of Frames  ----------

    covergroup cg_test_frame_count @(posedge m_cg_test_frame_count_sample_p);
      cp_test_frame_count : coverpoint (frame_count) {
        bins bin_1to1000 = {[1:1000]};
        bins bin_1001to5000 = {[1001:5000]};
        bins bin_5001to10000 = {[5001:10000]};
        //bins bin_10001to20000 = {[10001:20000]};
        //bins bin_20001to50000 = {[20001:50000]};
      }
    endgroup
    cg_test_frame_count m_cg_test_frame_count = new();

    // ------------ RX Resource Error Discard  ----------

    covergroup cg_rx_resource_error_discard @(posedge sampled_config);
      cp_rx_resource_error_discard : coverpoint (`EDMA_TOP_HIERARCHY.force_discard_on_err) {
        bins enabled  = {1};
        bins disabled = {0};
      }
    endgroup
    cg_rx_resource_error_discard m_cg_rx_resource_error_discard = new();


    // ------------  Frame Size Buckets ----------

    `define CP_FRAME_SIZES \
        bins bin_1to63 = {[1:63]}; \
        bins bin_64 = {64}; \
        bins bin_65 = {65}; \
        bins bin_66 = {66}; \
        bins bin_67 = {67}; \
        bins bin_68 = {68}; \
        bins bin_69to127 = {[69:127]}; \
        bins bin_128to255 = {[128:255]}; \
        bins bin_256to511 = {[256:511]}; \
        bins bin_512to1023 = {[512:1023]}; \
        bins bin_1024to2047 = {[1024:2047]}; \
        bins bin_gt2048 = {[2048:$]}; \

    // ------------  TX Frame Size Buckets ----------

    covergroup cg_tx_good_frames @(posedge m_cg_tx_good_frames_sample_p);
      cp_frame_sizes : coverpoint (tx_frame_size) {
        `CP_FRAME_SIZES
      }
    endgroup
    cg_tx_good_frames m_cg_tx_good_frames = new();

    covergroup cg_tx_bad_frames @(posedge m_cg_tx_bad_frames_sample_p);
      cp_frame_sizes : coverpoint (tx_frame_size) {
        bins bin_1to127 = {[1:127]};
        bins bin_128to2047 = {[128:2047]};
        bins bin_gt2048 = {[2048:$]};
      }
    endgroup
    cg_tx_bad_frames m_cg_tx_bad_frames = new();

    // ------------  RX Frame Size Buckets ----------

    covergroup cg_rx_good_frames @(posedge m_cg_rx_good_frames_sample_p);
      cp_frame_sizes : coverpoint (rx_frame_size) {
        `CP_FRAME_SIZES
      }
    endgroup
    cg_rx_good_frames m_cg_rx_good_frames = new();

    covergroup cg_rx_bad_frames @(posedge m_cg_rx_bad_frames_sample_p);
      cp_frame_sizes : coverpoint (rx_frame_size) {
        `CP_FRAME_SIZES
      }
    endgroup
    cg_rx_bad_frames m_cg_rx_bad_frames = new();

    // ------------  RX Overflow ----------

    covergroup cg_rx_overflows @(posedge m_cg_rx_overflows_sample_p);
      cp_rx_overflows : coverpoint (rx_overflow_count) {
        bins bin_1to1000 = {[1:1000]};
        bins bin_1001to2000 = {[1001:2000]};
        bins bin_2001to5000 = {[2001:5000 ]};
      }
    endgroup
    cg_rx_overflows m_cg_rx_overflows = new();

    // ------------  TX Underflow ----------

    covergroup cg_tx_underflows @(posedge m_cg_tx_underflows_sample_p);
      cp_tx_underflows : coverpoint (tx_underflow_count) {
        bins bin_1to5 = {[1:5]};
        bins bin_more = {[6:$]};
      }
      `CP_SRAM_MODE
      cross cp_tx_underflows, cp_sram_mode;
    endgroup
    cg_tx_underflows m_cg_tx_underflows = new();

    // ------------  RX Overflow Frames ----------

    covergroup cg_rx_overflow_frames @(posedge m_cg_rx_overflow_frames_sample_p);
      cp_frame_sizes : coverpoint (rx_frame_size) {
        `CP_FRAME_SIZES
      }
    endgroup
    cg_rx_overflow_frames m_cg_rx_overflow_frames = new();

    // ------------  TX Underflow Frames ----------

    covergroup cg_tx_underflow_frames @(posedge m_cg_tx_underflow_frames_sample_p);
      cp_frame_sizes : coverpoint (tx_frame_size_underflow) {
        bins bin_1to127 = {[1:127]};
        bins bin_128to2047 = {[128:2047]};
      }
    endgroup
    cg_tx_underflow_frames m_cg_tx_underflow_frames = new();


    // ------------  Multi Buffer Frames ----------

    `define CP_QUEUE \
      cp_queue : coverpoint (tx_queue) { \
        bins q0 = {0}; \
        bins q1 = {1}; \
        bins q2 = {2}; \
        bins q3 = {3}; \
        bins q4 = {4}; \
        bins q5 = {5}; \
        bins q6 = {6}; \
        bins q7 = {7}; \
      }

    covergroup cg_multi_buffer_sizes @(posedge m_cg_multi_buffer_sizes_sample_p);
      `CP_QUEUE
      cp_frame_size : coverpoint (tx_buffer_size) {
        bins bin_64 = {64};
        bins bin_67to127 = {[67:127]};
        bins bin_128to255 = {[128:255]};
        bins bin_256to511 = {[256:511]};
        bins bin_512to1023 = {[512:1023]};
      }
      cp_cross_multi_buffer_sizes : cross cp_queue, cp_frame_size;
    endgroup
    cg_multi_buffer_sizes m_cg_multi_buffer_sizes = new();


    // ------------  Multi Buffer - Buffers per frame ----------

    covergroup cg_multi_buffer_buffers_per_frame @(posedge m_cg_multi_buffer_buffers_per_frame_sample_p);
      `CP_QUEUE
      cp_buffers_per_frame : coverpoint (tx_buffers_per_frame) {
        bins one_buffer = {1};
        bins two_buffers = {2};
        bins three_buffers = {3};
        bins four_buffers = {4};
      }
      cp_cross_multi_buffer_buffers_per_frame : cross cp_queue, cp_buffers_per_frame;
    endgroup
    cg_multi_buffer_buffers_per_frame m_cg_multi_buffer_buffers_per_frame = new();


    // ------------  Host Frequency ----------
    `define CP_HOST_FREQ \
      cp_host_frequency : coverpoint (host_period) {  \
        bins mhz_100    = {1};  \
        bins mhz_125    = {2};  \
        bins mhz_156p25 = {3};  \
        bins mhz_200    = {4};  \
        bins mhz_250    = {5};  \
        bins mhz_500    = {6};  \
      }

    covergroup cg_host_frequency @(posedge sample_host_period_p);
      `CP_HOST_FREQ
    endgroup
    cg_host_frequency m_cg_host_frequency = new();


    // ------------ AXI Cross Coverage Core Features ----------

    // Cross a number of the functional modes in AXI to ensure we are getting
    // adequate coverage

    covergroup cg_cross_axi_core_features @(posedge sampled_config);
      `CP_AXI_MODE
      `CP_SRAM_MODE
      `CP_PRIORITY_QUEUES_SMPL
      `CP_TX_FORWARD_MODE
      `CP_TX_EXTENDED_BUFFER_DESCRIPTOR_MODE
      `CP_RX_FORWARD_MODE
      `CP_RX_EXTENDED_BUFFER_DESCRIPTOR_MODE
      `CP_HOST_FREQ
      cp_cross_axi_tx_core_features : cross
        cp_axi_mode,
        cp_sram_mode,
        cp_priority_queues_smpl,
        cp_tx_forward_mode,
        cp_tx_extended_buffer_descriptor_mode;
      cp_cross_axi_rx_core_features : cross
        cp_axi_mode,
        cp_sram_mode,
        cp_priority_queues_smpl,
        cp_rx_forward_mode,
        cp_rx_extended_buffer_descriptor_mode;
      cp_axi_freq : cross
        cp_axi_mode,
        cp_host_frequency;
    endgroup
    cg_cross_axi_core_features m_cg_cross_axi_core_features = new();

    // ------------ AHB Cross Coverage Core Features ----------

    // Cross a number of the functional modes in AHB to ensure we are getting
    // adequate coverage. Note removed partial store and forward here

    covergroup cg_cross_ahb_core_features @(posedge sampled_config);
      `CP_AHB_MODE
      `CP_SRAM_MODE
      `CP_PRIORITY_QUEUES_SMPL
      `CP_TX_FORWARD_MODE
      `CP_TX_EXTENDED_BUFFER_DESCRIPTOR_MODE
      `CP_RX_FORWARD_MODE
      `CP_RX_EXTENDED_BUFFER_DESCRIPTOR_MODE
      `CP_HOST_FREQ
      cp_cross_ahb_tx_core_features : cross
        cp_ahb_mode,
        cp_sram_mode,
        cp_priority_queues_smpl,
        cp_tx_forward_mode,
        cp_tx_extended_buffer_descriptor_mode;
      cp_cross_ahb_rx_core_features : cross
        cp_ahb_mode,
        cp_sram_mode,
        cp_priority_queues_smpl,
        cp_rx_forward_mode,
        cp_rx_extended_buffer_descriptor_mode;
      cp_ahb_freq : cross
        cp_ahb_mode,
        cp_host_frequency;
    endgroup
    cg_cross_ahb_core_features m_cg_cross_ahb_core_features = new();


    // -----------------------------------------------------------------------
    //
    //               Generate Sampling points and data
    //
    // -----------------------------------------------------------------------

    logic sampled_config_prev = 1'b0;
    // -----------------------------------------------------------------------
    // Sample the config at the first frame
    //
    always @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk)
    begin
      if (sampled_config)
        sampled_config_prev = 1'b1;
      if (`EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_state_man_rd)
        sampled_config = 1'b1;
      if (sampled_config & ~sampled_config_prev)
        $display("Sampled Config");
    end


    // -----------------------------------------------------------------------
    // Sample the TX Frames sizes and count the total number of frames applied.
    // Simple counter to count the TX Frame sizes going to the MAC

    logic frame_good = 0;
    always @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk)
      begin
        if (`EDMA_TOP_HIERARCHY.tx_r_valid) begin
          if (`EDMA_TOP_HIERARCHY.tx_r_sop) begin
            tx_frame_size <= (`emac_bus_width/8);
            frame_good <= ~`EDMA_TOP_HIERARCHY.tx_r_control;
          end
          else if (`EDMA_TOP_HIERARCHY.tx_r_eop) begin
            if (`EDMA_TOP_HIERARCHY.tx_r_mod==0)
              tx_frame_size <= tx_frame_size + (`emac_bus_width/8);
            else
              tx_frame_size <= tx_frame_size + `EDMA_TOP_HIERARCHY.tx_r_mod;

            if (frame_good)
              m_cg_tx_good_frames_sample <= 1'b1;
            else
              m_cg_tx_bad_frames_sample <= 1'b1;
            // Count the total number of frames
            frame_count <= frame_count + 1;
            m_cg_test_frame_count_sample <= 1'b1;
          end else
            tx_frame_size <= tx_frame_size + (`emac_bus_width/8);
        end
        if (m_cg_tx_good_frames_sample) m_cg_tx_good_frames_sample <= 1'b0;
        if (m_cg_tx_bad_frames_sample) m_cg_tx_bad_frames_sample <= 1'b0;
        if (m_cg_test_frame_count_sample) m_cg_test_frame_count_sample <= 1'b0;
        m_cg_tx_good_frames_sample_p <= m_cg_tx_good_frames_sample;
        m_cg_tx_bad_frames_sample_p <=  m_cg_tx_bad_frames_sample;
        m_cg_test_frame_count_sample_p <= m_cg_test_frame_count_sample;
      end

    always @(posedge `EDMA_UNDERFLOW_TOP_HIERARCHY.tx_r_clk)
      begin
        if (`EDMA_UNDERFLOW_TOP_HIERARCHY.tx_r_valid) begin
          if (`EDMA_UNDERFLOW_TOP_HIERARCHY.tx_r_sop) begin
            tx_frame_size_underflow <= `emac_bus_width/8;
          end
          else if (`EDMA_UNDERFLOW_TOP_HIERARCHY.tx_r_eop) begin
            if (`EDMA_UNDERFLOW_TOP_HIERARCHY.tx_r_mod==0)
              tx_frame_size_underflow <= tx_frame_size_underflow + (`emac_bus_width/8);
            else
              tx_frame_size_underflow <= tx_frame_size_underflow + `EDMA_UNDERFLOW_TOP_HIERARCHY.tx_r_mod;
          end
          else
            tx_frame_size_underflow <= tx_frame_size_underflow + (`emac_bus_width/8);
        end
      end

    // -----------------------------------------------------------------------
    // Sample the RX Frames sizes
    // Simple counter to count the RX Frame sizes going to the MAC
    integer rx_w_mod;

    always @(posedge `EDMA_TOP_HIERARCHY.rx_w_clk)
      begin
        if (`EDMA_TOP_HIERARCHY.rx_w_wr) begin

          if (`EDMA_TOP_HIERARCHY.rx_w_sop)
            rx_frame_size <= `emac_bus_width/8;
          else if (`EDMA_TOP_HIERARCHY.rx_w_eop) begin
            rx_w_mod <= ((`EDMA_TOP_HIERARCHY.rx_w_frame_length & ((`emac_bus_width/8)-1)) == 0)
                       ? `emac_bus_width/8
                       : `EDMA_TOP_HIERARCHY.rx_w_frame_length & ((`emac_bus_width/8)-1);
            rx_frame_size <= rx_frame_size + rx_w_mod;
            if (`EDMA_TOP_HIERARCHY.rx_w_err)
              m_cg_rx_bad_frames_sample <= 1'b1;
            else
              m_cg_rx_good_frames_sample <= 1'b1;
          end
          else
            rx_frame_size <= rx_frame_size + (`emac_bus_width/8);
        end
        if (m_cg_rx_bad_frames_sample) m_cg_rx_bad_frames_sample <= 1'b0;
        if (m_cg_rx_good_frames_sample) m_cg_rx_good_frames_sample <= 1'b0;
        m_cg_rx_bad_frames_sample_p <= m_cg_rx_bad_frames_sample;
        m_cg_rx_good_frames_sample_p <= m_cg_rx_good_frames_sample;
      end

    // -----------------------------------------------------------------------
    // Simple Counter to count the number of RX overflows
    //
    logic dbuff_full_previous = 0;

    always @(posedge `EDMA_TOP_HIERARCHY.rx_w_clk)
      begin
        // If we have just hit overflow, increment the count
        if (`EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.rx_w_wr &&
            `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.dbuff_full &&
            !dbuff_full_previous) begin
          rx_overflow_count <= rx_overflow_count + 1'b1;
          m_cg_rx_overflows_sample <= 1'b1;
          m_cg_rx_overflow_frames_sample <= 1'b1;
        end
        // Alternatively, if we are already full and a new frame comes in,
        // include that as an overflow.
        else if (`EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.rx_w_wr &&
                 `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.dbuff_full &&
                 `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.rx_w_sop) begin
          rx_overflow_count <= rx_overflow_count + 1'b1;
          m_cg_rx_overflows_sample <= 1'b1;
        end

        if (`EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.rx_w_wr)
          dbuff_full_previous <= `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_wr.dbuff_full;

        if (m_cg_rx_overflows_sample) m_cg_rx_overflows_sample <= 1'b0;
        if (m_cg_rx_overflow_frames_sample) m_cg_rx_overflow_frames_sample <= 1'b0;
        m_cg_rx_overflows_sample_p <= m_cg_rx_overflows_sample;
        m_cg_rx_overflow_frames_sample_p <= m_cg_rx_overflow_frames_sample;
      end

    // -----------------------------------------------------------------------
    // Multi Buffer Monitor
    // Monitor the buffer sizes and the number of buffers per frame

    integer buffers_per_frame [`edma_queues-1:0] = '{`edma_queues{0}};
    logic [31:0] descriptor_data;
    integer shift;
    assign shift = (`emac_bus_width == 64) ? 32 : 0;
    bit ahb_phase_data = 1'b0;
    always @(posedge `EDMA_TX_WR_HIERARCHY.hclk)
      begin
    `ifdef edma_axi
        if (`EDMA_TX_WR_HIERARCHY.cur_descr_rd_valid && `EDMA_TX_WR_HIERARCHY.cur_descr_rd_rdy) begin
          tx_queue = `EDMA_TX_WR_HIERARCHY.cur_descr_rd_queue;
          tx_buffer_size <= `EDMA_TX_WR_HIERARCHY.cur_descr_rd[45:32];
          m_cg_multi_buffer_sizes_sample <= 1'b1;
          buffers_per_frame[tx_queue] <= buffers_per_frame[tx_queue] + 1'b1;
          if (`EDMA_TX_WR_HIERARCHY.cur_descr_rd[47]) begin
            tx_buffers_per_frame <= buffers_per_frame[tx_queue];
            m_cg_multi_buffer_buffers_per_frame_sample <= 1'b1;
            buffers_per_frame[tx_queue] <= 0;
          end
        end

    `else
        if (`EDMA_TX_WR_HIERARCHY.hready) begin
          // If we are in the data phase of a descriptor read, decode the data
          // and update the appropriate cover groups, including the buffer
          // size and the number of buffers per frame.
          if (ahb_phase_data) begin
            descriptor_data <= (`EDMA_TX_WR_HIERARCHY.hrdata >> shift);
            tx_buffer_size <= descriptor_data & 32'h0000_3fff;
            m_cg_multi_buffer_sizes_sample <= 1'b1;
            buffers_per_frame[tx_queue] <= buffers_per_frame[tx_queue] + 1'b1;
            // If this buffer contains the last buffer for this frame then
            // st the buffers per frame back to 0.
            if (descriptor_data[15]) begin
              tx_buffers_per_frame <= buffers_per_frame[tx_queue];
              m_cg_multi_buffer_buffers_per_frame_sample <= 1'b1;
              buffers_per_frame[tx_queue] <= 0;
            end
          end

          // Detect if we are in the address phase of a descriptor read. If so
          // then the data phase is next, so we need to flag to check the data.
          if (`EDMA_TX_WR_HIERARCHY.htrans_descr != 0 &&
              `EDMA_TX_WR_HIERARCHY.descr_rd_done_dph &&
              `EDMA_TX_WR_HIERARCHY.dma_state_man_rd )begin
            ahb_phase_data <= 1;
            tx_queue <= tx_queue - 1'b1;
          end
          else
            ahb_phase_data <= 0;

          // When we are not in the DMA_MANRD state then reset the queue
          // counter to `edma_queues. We then decrement tx_queue each time we see
          // a descriptor access.
          if (!`EDMA_TX_WR_HIERARCHY.dma_state_man_rd)
            tx_queue <= `edma_queues;
        end
      `endif
        if (m_cg_multi_buffer_buffers_per_frame_sample) m_cg_multi_buffer_buffers_per_frame_sample <= 1'b0;
        if (m_cg_multi_buffer_sizes_sample) m_cg_multi_buffer_sizes_sample <= 1'b0;
        m_cg_multi_buffer_buffers_per_frame_sample_p <= m_cg_multi_buffer_buffers_per_frame_sample;
        m_cg_multi_buffer_sizes_sample_p <= m_cg_multi_buffer_sizes_sample;
      end

    // -----------------------------------------------------------------------
    // Count the number of underflows that occur
    // -----------------------------------------------------------------------

    logic underflow_tog_prev = 1'b0;

    always @(posedge `EDMA_TX_RD_UNDERFLOW_TOP_HIERARCHY.tx_r_clk)
      begin
        underflow_tog_prev <= `EDMA_TX_RD_UNDERFLOW_TOP_HIERARCHY.underflow_tog;
        if (`EDMA_TX_RD_UNDERFLOW_TOP_HIERARCHY.underflow_tog != underflow_tog_prev)
        begin
          tx_underflow_count <= tx_underflow_count + 1'b1;
          m_cg_tx_underflows_sample <= 1'b1;
          m_cg_tx_underflow_frames_sample <= 1'b1;
        end
        if (m_cg_tx_underflows_sample) m_cg_tx_underflows_sample <= 1'b0;
        if (m_cg_tx_underflow_frames_sample) m_cg_tx_underflow_frames_sample <= 1'b0;
        m_cg_tx_underflows_sample_p <= m_cg_tx_underflows_sample;
        m_cg_tx_underflow_frames_sample_p <=  m_cg_tx_underflow_frames_sample;
      end

    //------------------------------------------------------------------------------
    //
    //                      Use and Corner Cases
    //
    //------------------------------------------------------------------------------



    //------------------------------------------------------------------------------
    // RX Excessive Overflows
    //
    // Xilinx encountered an issue in approximately 2012, where an excessive number
    // of overflows caused a lock-up in the RX path. At an overflow, assuming full store and
    // forward mode, a full frame will be dropped and status words only will be
    // written to the FIFO. The frame counter will also be incremented. If there are continuous
    // overflows then the frame counter will keep incrementing, and in the case of the
    // Xilinx issue, when it hit 255 it would wrap back round to 0. A fix has been
    // put in for this condition but we want to ensure we are testing it, hence the
    // cover point, ensuring we have hit 256 frames in the RX FIFO.


    `ifndef GEM_LEGACY

      cp_rx_overflow_excessive : cover property (
        @(posedge `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hclk)
          `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.num_pkts_needing_read == 255 |=>
          `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.num_pkts_needing_read == 256)
            $display("Info - cp_rx_overflow_excessive");

    `endif



    //------------------------------------------------------------------------------
    // TX touches empty
    //
    // A main point of the tx reduce bd availability functionality is to just hit empty
    // on the read side, as it's a classic case for bugs and also where GEM/XGM has had
    // bugs in the past. We therefore have cover points to ensure the read side is
    // just touching empty.

    `ifndef GEM_LEGACY

      cp_tx_rd_empty_touched_for_one_clock_cycle : cover property (
        @(posedge `EDMA_TX_RD_HIERARCHY.tx_r_clk)
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 1 |=>
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 0 ##1
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 1)
            $display("Info : cp_tx_rd_empty_touched_for_one_clock_cycle");

      cp_tx_rd_empty_touched_for_two_clock_cycle : cover property (
        @(posedge `EDMA_TX_RD_HIERARCHY.tx_r_clk)
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 1 |=>
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 0 ##1
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 0 ##1
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 1)
            $display("Info : cp_tx_rd_empty_touched_for_two_clock_cycle");

      cp_tx_rd_empty_touched_for_three_clock_cycle : cover property (
        @(posedge `EDMA_TX_RD_HIERARCHY.tx_r_clk)
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 1 |=>
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 0 ##1
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 0 ##1
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 0 ##1
          `EDMA_TX_RD_HIERARCHY.num_pkts_needing_read[0] == 1)
            $display("Info : cp_tx_rd_empty_touched_for_three_clock_cycle");

    `endif



/*
    logic [4:0] num_queues_has_pkts;
    always@(*)
    begin
      num_queues_has_pkts = packets_in_q[0] + packets_in_q[1] + packets_in_q[2] + packets_in_q[3] +
                            packets_in_q[4] + packets_in_q[5] + packets_in_q[6] + packets_in_q[7] +
                            packets_in_q[8] + packets_in_q[9] + packets_in_q[10] + packets_in_q[11] +
                            packets_in_q[12] + packets_in_q[13] + packets_in_q[14] + packets_in_q[15];
    end
    covergroup cg_num_queues_has_pkts @(posedge reschedule_now);
      num_queues  : coverpoint (num_queues_has_pkts) {
        bins bin_1  = {1};
        bins bin_2  = {2};
        bins bin_3  = {3};
        bins bin_4  = {4};
        bins bin_5  = {5};
        bins bin_6  = {6};
        bins bin_7  = {7};
        bins bin_8  = {8};
        bins bin_9  = {9};
        bins bin_10 = {10};
        bins bin_11 = {11};
        bins bin_12 = {12};
        bins bin_13 = {13};
        bins bin_14 = {14};
        bins bin_15 = {15};
        bins bin_16 = {16};
      }
    endgroup
    cg_num_queues_has_pkts m_cg_num_queues_has_pkts = new();


    covergroup cg_tx_underflows @(posedge m_cg_tx_underflows_sample_p);
      cp_tx_underflows : coverpoint (tx_underflow_count) {
        bins bin_1to5 = {[1:5]};
        bins bin_more = {[6:$]};
      }
      `CP_SRAM_MODE
      cross cp_tx_underflows, cp_sram_mode;
    endgroup
    cg_tx_underflows m_cg_tx_underflows = new();


    // Collect coverage for the injected launch time ..
    always @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk)
      begin
*/


    // -----------------------------------------------------------------------
    //
    //                      Measure the host clock frequency
    //
    // -----------------------------------------------------------------------

    // In the covergroups it's not possible to have bins on time variables,
    // so we instead decode the actual period. Note. The decoded value uses
    // the numbering scheme used in the SOC/tb_rse

    logic [15:0] p_clk_count = 0;
    logic [15:0] sys_clk_count = 0;
    logic period_4us = 1'b0;
    logic [15:0] p_clk_count_limit;

    assign p_clk_count_limit =
      (`MAC_TOP_HIERARCHY.gigabit) ? 500 :
      (`MAC_TOP_HIERARCHY.bit_rate) ? 100 : 10;

    always @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk)
      begin
        if (sampled_config & (p_clk_count < p_clk_count_limit)) begin
          period_4us <= 1'b1;
          p_clk_count <= p_clk_count + 1'b1;
        end else
          period_4us <= 1'b0;
      end

    always @(posedge `EDMA_TOP_HIERARCHY.hclk)
      begin
        sample_host_period_p <= sample_host_period;
        if (period_4us) begin
          sys_clk_count <= sys_clk_count + 1'b1;
        end
        else if (sys_clk_count > 0) begin
          sample_host_period <= 1'b1;
          case (sys_clk_count >> 2) //how many ticks counted in 1 us?
            100     : host_period <= 1; //100MHz
            125     : host_period <= 2; //125MHz
            156     : host_period <= 3; //156.25MHz
            200     : host_period <= 4; //200MHz
            250     : host_period <= 5; //250MHz
            500     : host_period <= 6; //500MHz
            default : host_period <= 0;
          endcase
        end
      end

    // Coverage for the TX Scheduler
    wire  [3:0]   speed_mode;
    wire  [3:0]   tx_top_queue;
    wire          tx_top_is_fp;
    wire          tx_top_is_dwrr;
    wire          tx_top_is_ets;
    wire          tx_top_is_cbs;
    wire          tx_bot_is_fp;
    wire          tx_bot_is_ets;
    wire          tx_bot_is_cbs;
    wire          tx_bot_is_dwrr;
    wire          tx_has_ets;
    wire          tx_has_cbs;
    wire          tx_has_dwrr;
    wire  [15:0]  tx_sched_cbs_en_pad;
    wire  [15:0]  tx_sched_ets_en_pad;
    wire  [15:0]  tx_sched_dwrr_en_pad;
    wire  [1:0]   cbs_enable_act;
    wire  [127:0] bw_rate_limit;
    wire  [3:0]   scheduled_queue;
    wire          reschedule_now;
    wire          reschedule_now_underflow;

    assign speed_mode = { `MAC_TOP_HIERARCHY.two_pt_five_gig,
                          `MAC_TOP_HIERARCHY.tbi,
                          `MAC_TOP_HIERARCHY.gigabit,
                          `MAC_TOP_HIERARCHY.bit_rate };

    `define CP_SPEED_MODE_NO_TBI \
      cp_speed_mode_no_tbi  : coverpoint  (speed_mode)  { \
        bins SP_10M   = {4'b0000};  \
        bins SP_100M  = {4'b0001};  \
        bins SP_1G    = {4'b0010};  \
      }

    // Number of physical queues vs active queues
    `define CP_PRIORITY_QUEUES_PHYS \
      cp_pri_queues_phys : coverpoint (edma_queues) { \
        bins bin_1    = {1}; \
        bins bin_2_3  = {[2:3]}; \
        bins bin_4_7  = {[4:7]}; \
        bins bin_8_16 = {[8:16]}; \
      }

    logic [4:0] edma_queues_active;
    logic queues_disabled;
    assign edma_queues_active = tx_top_queue + 1;
    assign queues_disabled = (edma_queues_active < edma_queues);

    `define CP_PRIORITY_QUEUES_DIS \
      cp_pri_queues_dis : coverpoint (queues_disabled) { \
        bins yes      = {1}; \
        bins no       = {0}; \
      }

    `define CP_PRIORITY_QUEUES_ACT \
      cp_pri_queues_act : coverpoint (edma_queues_active) { \
        bins bin_1    = {1}; \
        bins bin_2_3  = {[2:3]}; \
        bins bin_4_7  = {[4:7]}; \
        bins bin_8_16 = {[8:16]}; \
      }

    covergroup cg_cross_queues_act @(posedge sampled_config);
      `CP_PRIORITY_QUEUES_PHYS
      `CP_PRIORITY_QUEUES_ACT
      `CP_PRIORITY_QUEUES_DIS
      cross cp_pri_queues_phys, cp_pri_queues_act {
        // Ignore cases buckets where more queues are active than available physical
        ignore_bins x1  = binsof(cp_pri_queues_act.bin_8_16);
        ignore_bins x2  = binsof(cp_pri_queues_phys.bin_2_3) && binsof(cp_pri_queues_act.bin_4_7);
        ignore_bins x3  = binsof(cp_pri_queues_phys.bin_1) && binsof(cp_pri_queues_act.bin_2_3);
        ignore_bins x4  = binsof(cp_pri_queues_phys.bin_1) && binsof(cp_pri_queues_act.bin_4_7);
      }
      cross cp_pri_queues_dis, cp_pri_queues_act;
    endgroup
    cg_cross_queues_act m_cg_cross_queues_act = new();

    logic [31:0]  port_tx_rate;
    logic [31:0]  idle_slope_a;
    logic [31:0]  idle_slope_b;
    logic [13:0]  nxt_frame_size_q0;
    logic [15:0]  packets_in_q;
    logic         complete_flush;
    logic         scheduler_flushed = 1'b0;

`ifdef gem_tx_pkt_buffer
    reg   [1:0]   tx_top_q_type;
    reg   [1:0]   tx_nxt_q_type;
    `define GEM_TX_SCHED_HIERARCHY            `MAC_TOP_HIERARCHY.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.i_edma_tx_sched
    `define GEM_TX_SCHED_UNDERFLOW_HIERARCHY  `MAC_TOP_UNDERFLOW_HIERARCHY.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if.i_edma_tx_sched

    assign tx_top_queue           = `GEM_TX_SCHED_HIERARCHY.cbs_q_a_id;
    assign tx_sched_cbs_en_pad    = `GEM_TX_SCHED_HIERARCHY.cbs_en_pad;
    assign tx_sched_ets_en_pad    = `GEM_TX_SCHED_HIERARCHY.ets_en_pad;
    assign tx_sched_dwrr_en_pad   = `GEM_TX_SCHED_HIERARCHY.dwrr_en_pad;

    assign tx_top_is_fp   = (tx_top_queue > 0)  ? ~tx_sched_cbs_en_pad[tx_top_queue]  & ~tx_sched_ets_en_pad[tx_top_queue] & ~tx_sched_dwrr_en_pad[tx_top_queue]
                                                : 1'b0;
    assign tx_top_is_cbs  = (tx_top_queue > 0)  ? tx_sched_cbs_en_pad[tx_top_queue]   : 1'b0;
    assign tx_top_is_ets  = (tx_top_queue > 0)  ? tx_sched_ets_en_pad[tx_top_queue]   : 1'b0;
    assign tx_top_is_dwrr = (tx_top_queue > 0)  ? tx_sched_dwrr_en_pad[tx_top_queue]  : 1'b0;
    assign tx_bot_is_fp   = ~tx_sched_cbs_en_pad[0]  & ~tx_sched_ets_en_pad[0] & ~tx_sched_dwrr_en_pad[0];
    assign tx_bot_is_cbs  = tx_sched_cbs_en_pad[0]; // Special case only for 2 queue system.
    assign tx_bot_is_ets  = tx_sched_ets_en_pad[0];
    assign tx_bot_is_dwrr = tx_sched_dwrr_en_pad[0];
    assign tx_has_cbs     = |tx_sched_cbs_en_pad;
    assign tx_has_ets     = |tx_sched_ets_en_pad;
    assign tx_has_dwrr    = |tx_sched_dwrr_en_pad;

    assign cbs_enable_act[0]  = (tx_top_queue > 0)  ? tx_sched_cbs_en_pad[tx_top_queue-1]
                                                    : 1'b0;
    assign cbs_enable_act[1]  = tx_sched_cbs_en_pad[tx_top_queue];

    assign bw_rate_limit  = `GEM_TX_SCHED_HIERARCHY.bw_rate_limit;

    assign port_tx_rate   = `GEM_TX_SCHED_HIERARCHY.port_tx_rate;
    assign idle_slope_a   = `GEM_TX_SCHED_HIERARCHY.idleslope_q_a;
    assign idle_slope_b   = `GEM_TX_SCHED_HIERARCHY.idleslope_q_b;

    assign scheduled_queue          = `GEM_TX_SCHED_HIERARCHY.scheduled_queue;
    assign reschedule_now           = `GEM_TX_SCHED_HIERARCHY.reschedule_now;
    assign reschedule_now_underflow = `GEM_TX_SCHED_UNDERFLOW_HIERARCHY.reschedule_now;
    assign nxt_frame_size_q0        = `GEM_TX_SCHED_HIERARCHY.nxt_frame_size[0];

    assign packets_in_q             = `GEM_TX_SCHED_HIERARCHY.packets_in_q;

    assign complete_flush           = `GEM_TX_SCHED_UNDERFLOW_HIERARCHY.complete_flush;

    integer loop_i;


    always@(*)
    begin
      // Initialise based on top queue...
      if (tx_top_is_cbs)
        tx_top_q_type = 2'b01;
      else if (tx_top_is_dwrr)
        tx_top_q_type = 2'b10;
      else if (tx_top_is_ets)
        tx_top_q_type = 2'b11;
      else
        tx_top_q_type = 2'b00;
      tx_nxt_q_type = tx_top_q_type;
      loop_i  = tx_top_queue;
      for (loop_i = tx_top_queue; loop_i > 0; loop_i = loop_i - 1)
      begin
        if (tx_nxt_q_type == tx_top_q_type)
        begin
          if (tx_sched_cbs_en_pad[loop_i])
            tx_nxt_q_type = 2'b01;
          else if (tx_sched_dwrr_en_pad[loop_i])
            tx_nxt_q_type = 2'b10;
          else if (tx_sched_ets_en_pad[loop_i])
            tx_nxt_q_type = 2'b11;
          else
            tx_nxt_q_type = 2'b00;
        end
      end
    end

    logic complete_flush_prev;

    // Want coverage to show that new packet has been scheduled after
    // a flush has happened.
    // complete_flush is only used here and
    // reschedule_now_underflow will be used as it will probe
    // inside gem_0 in CSP, not gem_1, as for the tx_underflow tests
    // that is the GEM used for TX
    always @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk)
      begin
        complete_flush_prev <= complete_flush;
        if (complete_flush & ~complete_flush_prev)
          scheduler_flushed <= 1'b1;
        else if (scheduler_flushed & reschedule_now_underflow)
          scheduler_flushed <= 1'b0;
      end


`else
    wire  [1:0]   tx_top_q_type;
    wire  [1:0]   tx_nxt_q_type;
    assign tx_top_queue             = 0;
    assign tx_top_q_type            = 2'b00;
    assign tx_nxt_q_type            = 2'b00;
    assign cbs_enable_act           = 2'b00;
    assign bw_rate_limit            = {128{1'b0}};
    assign port_tx_rate             = 125000000;
    assign idle_slope_a             = 0;
    assign idle_slope_b             = 0;
    assign reschedule_now           = 0;
    assign reschedule_now_underflow = 0;
    assign scheduled_queue          = 0;
    assign nxt_frame_size_q0        = 0;
    assign packets_in_q             = 0;
    assign complete_flush           = 0;
    assign scheduler_flushed        = 0;

`endif

    `define CP_TX_HAS_CBS \
      cp_tx_has_cbs : coverpoint (tx_has_cbs) { \
        bins  on  = {1};  \
      }
    `define CP_TX_HAS_DWRR \
      cp_tx_has_dwrr : coverpoint (tx_has_dwrr) { \
        bins  on  = {1};  \
      }
    `define CP_TX_HAS_ETS \
      cp_tx_has_ets : coverpoint (tx_has_ets) { \
        bins  on  = {1};  \
      }

    `define CP_TX_TOP_SCHED \
      cp_tx_top_sched : coverpoint (tx_top_q_type) { \
        bins  Fixed_Pri = {0};  \
        bins  CBS       = {1};  \
        bins  DWRR      = {2};  \
        bins  ETS       = {3};  \
      }
    covergroup  cg_tx_top_sched @(posedge sampled_config);
      `CP_TX_TOP_SCHED
    endgroup
    cg_tx_top_sched m_cg_tx_top_sched = new();

    `define CP_TX_NXT_SCHED \
      cp_tx_nxt_sched : coverpoint (tx_nxt_q_type) { \
        bins  Fixed_Pri = {0};  \
        bins  CBS       = {1};  \
        bins  DWRR      = {2};  \
        bins  ETS       = {3};  \
      }
    covergroup  cg_tx_nxt_sched @(posedge sampled_config);
      `CP_TX_NXT_SCHED
    endgroup
    cg_tx_nxt_sched m_cg_tx_nxt_sched = new();

    covergroup cg_cross_tx_sched_modes @(posedge sampled_config);
      `CP_TX_TOP_SCHED
      `CP_TX_NXT_SCHED
      cross cp_tx_top_sched, cp_tx_nxt_sched {
        // Ignore if illegal cases
        ignore_bins x1  = binsof(cp_tx_top_sched.DWRR) && binsof(cp_tx_nxt_sched.CBS);
        ignore_bins x2  = binsof(cp_tx_top_sched.ETS) && binsof(cp_tx_nxt_sched.CBS);
        ignore_bins x3  = binsof(cp_tx_top_sched.DWRR) && binsof(cp_tx_nxt_sched.Fixed_Pri);
        ignore_bins x4  = binsof(cp_tx_top_sched.DWRR) && binsof(cp_tx_nxt_sched.ETS);
        ignore_bins x5  = binsof(cp_tx_top_sched.ETS) && binsof(cp_tx_nxt_sched.DWRR);
        // The following is covered in a separate covergroup
        ignore_bins x6  = binsof(cp_tx_top_sched.CBS) && binsof(cp_tx_nxt_sched.CBS);
      }
    endgroup
    cg_cross_tx_sched_modes m_cg_cross_tx_sched_modes = new();

    covergroup cg_cross_spram_tx_sched @(posedge sampled_config);
      `CP_SRAM_MODE
      `CP_TX_HAS_CBS
      `CP_TX_HAS_ETS
      `CP_SPEED_MODE_NO_TBI
      cross cp_tx_has_ets, cp_speed_mode_no_tbi;
      cross cp_tx_has_cbs, cp_speed_mode_no_tbi;
      cross cp_sram_mode, cp_tx_has_ets, cp_speed_mode_no_tbi;
      cross cp_sram_mode, cp_tx_has_cbs, cp_speed_mode_no_tbi;
    endgroup
    cg_cross_spram_tx_sched m_cg_cross_spram_tx_sched = new();

    // Cross CBS enabled with active queues
    covergroup cg_cross_queues_act_cbs @(posedge sampled_config);
      `CP_PRIORITY_QUEUES_ACT
      `CP_TX_HAS_CBS
      cross cp_tx_has_cbs, cp_pri_queues_act {
        ignore_bins x1  = binsof(cp_pri_queues_act.bin_1);
      }
    endgroup
    cg_cross_queues_act_cbs m_cg_cross_queues_act_cbs = new();

    // Cross DWRR enabled with active queues
    covergroup cg_cross_queues_act_dwrr @(posedge sampled_config);
      `CP_PRIORITY_QUEUES_ACT
      `CP_TX_HAS_DWRR
      cross cp_tx_has_dwrr, cp_pri_queues_act {
        ignore_bins x1  = binsof(cp_pri_queues_act.bin_1);
      }
    endgroup
    cg_cross_queues_act_dwrr m_cg_cross_queues_act_dwrr = new();

    // Cross ETS enabled with active queues
    covergroup cg_cross_queues_act_ets @(posedge sampled_config);
      `CP_PRIORITY_QUEUES_ACT
      `CP_TX_HAS_ETS
      cross cp_tx_has_ets, cp_pri_queues_act;
    endgroup
    cg_cross_queues_act_ets m_cg_cross_queues_act_ets = new();

    // CBS coverage of top two active queues
    covergroup cg_cbs_en @(posedge sampled_config);
      cp_cbs_en : coverpoint (cbs_enable_act) {
        bins  NONE  = {0};
        bins  SCND  = {1};
        bins  TOP   = {2};
        bins  BOTH  = {3};
      }
    endgroup
    cg_cbs_en m_cg_cbs_en = new();

    // Need to sample across all active lanes so use internal sample signalling and trigger on
    // something like @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk);
    // but wait for sampled_config to be set, then loop across active queues and set a sample trigger
    // every cycle.
    logic sample_config_int = 1'b0;
    logic [7:0]   bw_rate_limit_ets_cur;
    logic [7:0]   bw_rate_limit_dwrr_cur;
    logic [127:0] bw_rate_limit_shift;
    integer     loop_j;

    always @(posedge `EDMA_TOP_HIERARCHY.tx_r_clk)
    begin
      if (sampled_config & ~sampled_config_prev) begin
        bw_rate_limit_shift = bw_rate_limit;
        for (loop_j = 0; loop_j < edma_queues_active; loop_j = loop_j + 1)
        begin
          bw_rate_limit_ets_cur   = 8'h00;
          bw_rate_limit_dwrr_cur  = 8'h00;
          if (tx_sched_ets_en_pad[loop_j])
            bw_rate_limit_ets_cur = bw_rate_limit_shift[7:0];
          else
            if (tx_sched_dwrr_en_pad[loop_j])
              bw_rate_limit_dwrr_cur = bw_rate_limit_shift[7:0];
          bw_rate_limit_shift = bw_rate_limit_shift >> 8;
          sample_config_int = 1'b1;
        end
      end
    end

    // Coverage of DWRR bins
    `define CP_TX_DWRR_WEIGHT \
      cp_tx_dwrr_weight : coverpoint (bw_rate_limit_dwrr_cur) { \
        bins bin_31_0   = {[0:31]}; \
        bins bin_63_32  = {[32:63]}; \
        bins bin_95_64  = {[64:95]}; \
        bins bin_127_96 = {[96:127]}; \
        bins bin_159_128  = {[128:159]}; \
        bins bin_191_160  = {[160:191]}; \
        bins bin_223_192  = {[192:223]}; \
        bins bin_255_224  = {[224:255]}; \
      }
    covergroup cg_tx_dwrr_weight @(posedge sample_config_int);
      `CP_TX_DWRR_WEIGHT
    endgroup
    cg_tx_dwrr_weight m_cg_tx_dwrr_weight = new();

    // Coverage of ETS bins
    `define CP_TX_ETS_PERCENT \
      cp_tx_ets_percent : coverpoint (bw_rate_limit_ets_cur) { \
        bins bin_19_0   = {[0:19]}; \
        bins bin_39_20  = {[20:39]}; \
        bins bin_59_40  = {[40:59]}; \
        bins bin_79_60  = {[60:79]}; \
        bins bin_100_80 = {[80:100]}; \
      }
    covergroup cg_tx_ets_weight @(posedge sample_config_int);
      `CP_TX_ETS_PERCENT
    endgroup
    cg_tx_ets_weight m_cg_tx_ets_weight = new();


    // Coverage of CBS percentage.
    logic [6:0] cbs_percent_a;
    logic [6:0] cbs_percent_b;
    always@(*)
    begin
      cbs_percent_a = (idle_slope_a * 100 / port_tx_rate);
      cbs_percent_b = (idle_slope_b * 100 / port_tx_rate);
    end

    covergroup cg_cbs_a_bw_setting @(posedge sampled_config);
      cbs_a_bw_setting  : coverpoint (cbs_percent_a) {
        bins bin_9_0    = {[0:9]};
        bins bin_19_10  = {[10:19]};
        bins bin_39_20  = {[30:39]};
        bins bin_100_40 = {[40:100]};
      }
    endgroup
    cg_cbs_a_bw_setting m_cg_cbs_a_bw_setting = new();

    covergroup cg_cbs_b_bw_setting @(posedge sampled_config);
      cbs_b_bw_setting  : coverpoint (cbs_percent_b) {
        bins bin_9_0    = {[0:9]};
        bins bin_19_10  = {[10:19]};
        bins bin_39_20  = {[30:39]};
        bins bin_100_40 = {[40:100]};
      }
    endgroup
    cg_cbs_b_bw_setting m_cg_cbs_b_bw_setting = new();

    covergroup cg_sched_flush @(posedge reschedule_now_underflow);
      scheduler_flushed : coverpoint (scheduler_flushed);
    endgroup
    cg_sched_flush m_cg_sched_flush = new();

    // Coverage of the actual selected queue.
    `define CP_SCHEDULED_QUEUE cp_sched_queue : coverpoint (scheduled_queue);

    covergroup cg_sched_queue @(negedge reschedule_now);
      `CP_SCHEDULED_QUEUE
    endgroup
    cg_sched_queue  m_cg_sched_queue = new();

    // Coverage of next frame size at head of Q0
    covergroup cg_sched_frame_size_q0 @(posedge reschedule_now);
      frame_size_q0 : coverpoint (nxt_frame_size_q0) {
        bins bin_0_511      = {[0:511]};
        bins bin_511_1023   = {[512:1023]};
        bins bin_1024_2047  = {[1024:2047]};
        bins bin_2048_4095  = {[2048:4095]};
        bins bin_4096_8191  = {[4096:8191]};
        bins bin_8192_16383 = {[8192:16383]};
      }
    endgroup
    cg_sched_frame_size_q0  m_cg_sched_frame_size_q0 = new();


    // Coverage of the number of queues that can transmit
    logic [4:0] num_queues_has_pkts;
    always@(*)
    begin
      num_queues_has_pkts = packets_in_q[0] + packets_in_q[1] + packets_in_q[2] + packets_in_q[3] +
                            packets_in_q[4] + packets_in_q[5] + packets_in_q[6] + packets_in_q[7] +
                            packets_in_q[8] + packets_in_q[9] + packets_in_q[10] + packets_in_q[11] +
                            packets_in_q[12] + packets_in_q[13] + packets_in_q[14] + packets_in_q[15];
    end
    covergroup cg_num_queues_has_pkts @(posedge reschedule_now);
      num_queues  : coverpoint (num_queues_has_pkts) {
        bins bin_1  = {1};
        bins bin_2  = {2};
        bins bin_3  = {3};
        bins bin_4  = {4};
        bins bin_5  = {5};
        bins bin_6  = {6};
        bins bin_7  = {7};
        bins bin_8  = {8};
        bins bin_9  = {9};
        bins bin_10 = {10};
        bins bin_11 = {11};
        bins bin_12 = {12};
        bins bin_13 = {13};
        bins bin_14 = {14};
        bins bin_15 = {15};
        bins bin_16 = {16};
      }
    endgroup
    cg_num_queues_has_pkts m_cg_num_queues_has_pkts = new();

  wire rx_clk;
  wire n_rxreset;
  wire rx_w_eop;
  wire rx_w_err;

  assign rx_w_eop  = `MAC_TOP_HIERARCHY.i_gem_rx.rx_w_eop;
  assign rx_w_err  = `MAC_TOP_HIERARCHY.i_gem_rx.rx_w_err;
  assign rx_clk    = `MAC_TOP_HIERARCHY.i_gem_rx.rx_clk;
  assign n_rxreset = `MAC_TOP_HIERARCHY.i_gem_rx.n_rxreset;

  // -----------------------------------------------------------------------
  //
  //           Assertion proving the screeners independence for the
  //           per-scrn traffic policing
  //
  // -----------------------------------------------------------------------
  // This is very similar to the assertion above, just applied to the screeners
  // The only difference is they are statics and in the same clock domain
  // and then the check must be done only when the configuration is sampled
  // as those registers are not going to change anymore after that.
  `ifdef num_type2_screeners

    wire [512:0] scrn_traf_pol_pclk;
    wire [512:0] scrn_traf_pol_core;

    assign scrn_traf_pol_pclk = {{(513-(32*`num_type2_screeners)){1'b0}},`GEM_REG_TOP_HIERARCHY.scr2_rate_lim[(32*`num_type2_screeners):1]};
    assign scrn_traf_pol_core = {{(513-(32*`num_type2_screeners)){1'b0}},`MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.scr2_rate_lim_regs};

    always @(posedge sampled_config) check_scrns_independent0 : assert (scrn_traf_pol_core[31:0]    == scrn_traf_pol_pclk[31:0]);
    always @(posedge sampled_config) check_scrns_independent1 : assert (scrn_traf_pol_core[63:32]   == scrn_traf_pol_pclk[63:32]);
    always @(posedge sampled_config) check_scrns_independent2 : assert (scrn_traf_pol_core[95:64]   == scrn_traf_pol_pclk[95:64]);
    always @(posedge sampled_config) check_scrns_independent3 : assert (scrn_traf_pol_core[127:96]  == scrn_traf_pol_pclk[127:96]);
    always @(posedge sampled_config) check_scrns_independent4 : assert (scrn_traf_pol_core[159:128] == scrn_traf_pol_pclk[159:128]);
    always @(posedge sampled_config) check_scrns_independent5 : assert (scrn_traf_pol_core[191:160] == scrn_traf_pol_pclk[191:160]);
    always @(posedge sampled_config) check_scrns_independent6 : assert (scrn_traf_pol_core[223:192] == scrn_traf_pol_pclk[223:192]);
    always @(posedge sampled_config) check_scrns_independent7 : assert (scrn_traf_pol_core[255:224] == scrn_traf_pol_pclk[255:224]);
    always @(posedge sampled_config) check_scrns_independent8 : assert (scrn_traf_pol_core[287:256] == scrn_traf_pol_pclk[287:256]);
    always @(posedge sampled_config) check_scrns_independent9 : assert (scrn_traf_pol_core[319:288] == scrn_traf_pol_pclk[319:288]);
    always @(posedge sampled_config) check_scrns_independent10: assert (scrn_traf_pol_core[351:320] == scrn_traf_pol_pclk[351:320]);
    always @(posedge sampled_config) check_scrns_independent11: assert (scrn_traf_pol_core[383:352] == scrn_traf_pol_pclk[383:352]);
    always @(posedge sampled_config) check_scrns_independent12: assert (scrn_traf_pol_core[415:384] == scrn_traf_pol_pclk[415:384]);
    always @(posedge sampled_config) check_scrns_independent13: assert (scrn_traf_pol_core[447:416] == scrn_traf_pol_pclk[447:416]);
    always @(posedge sampled_config) check_scrns_independent14: assert (scrn_traf_pol_core[479:448] == scrn_traf_pol_pclk[479:448]);
    always @(posedge sampled_config) check_scrns_independent15: assert (scrn_traf_pol_core[511:480] == scrn_traf_pol_pclk[511:480]);

  `endif

  // -----------------------------------------------------------------------
  //
  //           Assertion for per-queue rx flush Mode2
  //
  // -----------------------------------------------------------------------
  `ifdef gem_rx_pkt_buffer
    wire                    final_eop_push;
    wire              [3:0] queue_ptr_rx;
    wire [`edma_queues-1:0] fill_lvl_breached;
    wire             [15:0] fill_lvl_breached_rx;

    assign final_eop_push     = `MAC_TOP_HIERARCHY.i_gem_rx.final_eop_push;
    assign queue_ptr_rx       = `MAC_TOP_HIERARCHY.i_gem_rx.queue_ptr_rx;
    assign fill_lvl_breached  = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.fill_lvl_breached;

    genvar s;
    genvar ns;
    generate for(s=0; s<`edma_queues; s=s+1) begin: gen_ass_mode2_build
      cdnsdru_datasync_v1 i_limit_num_bytes_reached_rx_sync (
        .clk    (rx_clk),
        .reset_n(n_rxreset),
        .din    (fill_lvl_breached[s]),
        .dout   (fill_lvl_breached_rx[s])
      );
    end
    if(`edma_queues<16) begin: gen_remain_ass_mode2_build
      for(ns=`edma_queues; ns<16; ns=ns+1) begin: gen_loop
        assign fill_lvl_breached_rx[ns] = 1'b0;
      end
    end
    endgenerate

    property check_mode2_q0;  @(posedge rx_clk) (final_eop_push && (queue_ptr_rx == 0 ) && fill_lvl_breached_rx[0 ]) |-> (##[0:1] rx_w_err == 1); endproperty assert_check_mode2_q0 : assert property (check_mode2_q0 );
    property check_mode2_q1;  @(posedge rx_clk) (final_eop_push && (queue_ptr_rx == 1 ) && fill_lvl_breached_rx[1 ]) |-> (##[0:1] rx_w_err == 1); endproperty assert_check_mode2_q1 : assert property (check_mode2_q1 );

  `endif // gem_rx_pkt_buffer

  // -----------------------------------------------------------------------
  //
  //           Assertion for per-screener traffic policing
  //
  // -----------------------------------------------------------------------
  `ifdef num_type2_screeners
    genvar h;
    genvar nh;
    wire   [15:0] update_rate_val;
    wire  [255:0] rate_val_next;
    wire  [255:0] max_rate_val;
    wire  [255:0] interval_time;
    reg    [31:0] count_tw_ends;

    generate for (h=0; h<`num_type2_screeners; h=h+1) begin: gen_rate_lim_check_build
      wire      time_window_end;

      // Statics signals mapping
      assign time_window_end                 = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.gen_rate_val_scr2[h].time_window_end;
      assign update_rate_val[h]              = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.gen_rate_val_scr2[h].update_rate_val;
      assign rate_val_next[15+(16*h):(16*h)] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.gen_rate_val_scr2[h].rate_val_next;
      assign max_rate_val [15+(16*h):(16*h)] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.gen_rate_val_scr2[h].max_rate_val;
      assign interval_time[15+(16*h):(16*h)] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.gen_rate_val_scr2[h].interval_time;

      always @ (posedge rx_clk or negedge n_rxreset)
      begin
        if(~n_rxreset)
          count_tw_ends[1+(2*h):(2*h)] <= 2'd0;
        else
          begin
            if(interval_time[15+(16*h):(16*h)] == 16'd0)
              count_tw_ends[1+(2*h):(2*h)] <= 2'd0;
            else
              begin
                if((rate_val_next[15+(16*h):(16*h)] > max_rate_val[15+(16*h):(16*h)]) && update_rate_val[h])
                  begin
                    if(~time_window_end)
                      count_tw_ends[1+(2*h):(2*h)] <= 2'd1;
                    else
                      count_tw_ends[1+(2*h):(2*h)] <= 2'd2;
                  end
                else
                  begin
                    if(time_window_end)
                      begin
                        if(count_tw_ends[1+(2*h):(2*h)] == 2'd1)
                          count_tw_ends[1+(2*h):(2*h)] <= count_tw_ends[1+(2*h):(2*h)] + 2'd1;
                        else
                          count_tw_ends[1+(2*h):(2*h)] <= 2'd0;
                      end
                  end
              end
          end
      end

    end

    if(`num_type2_screeners<16) begin: gen_rem_rate_lim_check_build
      for(nh=`num_type2_screeners; nh<16; nh=nh+1) begin: gen_loop
        assign update_rate_val[nh]                 = 1'b0;
        assign rate_val_next  [15+(16*nh):(16*nh)] = 16'd0;
        assign max_rate_val   [15+(16*nh):(16*nh)] = 16'd0;
        assign interval_time  [15+(16*nh):(16*nh)] = 16'd0;
        assign count_tw_ends  [1+(2*nh):(2*nh)]    = 2'b00;
      end
    end
    endgenerate

    property check_rate_lim0;  @(posedge rx_clk) (((update_rate_val[0] && (rate_val_next[15:0]  > max_rate_val[15:0] )) || ((count_tw_ends[1:0] != 2'd0) && update_rate_val[0 ])) && (interval_time[15:0]  != 16'd0)) |-> (##[0:1] rx_w_err == 1); endproperty assert_check_rate_lim0 : assert property (check_rate_lim0);
    property check_rate_lim1;  @(posedge rx_clk) (((update_rate_val[1] && (rate_val_next[31:16] > max_rate_val[31:16])) || ((count_tw_ends[3:2] != 2'd0) && update_rate_val[1 ])) && (interval_time[31:16] != 16'd0)) |-> (##[0:1] rx_w_err == 1); endproperty assert_check_rate_lim1 : assert property (check_rate_lim1);

  `endif // num_type2_screeners

  // -----------------------------------------------------------------------
  //
  //           FC and assertions for per-queue rx flush functionality
  //
  // -----------------------------------------------------------------------
  wire                   [3:0] queue_pointer;
  wire                   [3:0] queue_pointer_rx_rd;
  wire                         ahb_sf_err;
  wire                  [16:0] n_memory_words_in_frame;
  wire                   [1:0] dma_bus_width_apb;
  wire                   [1:0] dma_bus_width;
  wire                  [16:0] drop_all_frames_rx_clk_pad;
  wire                  [16:0] force_discard_on_err_q_ambaclk_pad;
  reg       [`edma_queues-1:0] frame_rxd_q_int;
  wire                  [16:0] frame_rxd_q;
  wire [(16*`edma_queues)-1:0] max_val_pclk;
  wire                 [256:0] max_val_pclk_pad;
  wire                  [16:0] limit_num_bytes_allowed_ambaclk_pad;
  reg       [`edma_queues-1:0] lack_res_q_int;
  wire                  [16:0] lack_res_q;
  reg                   [16:0] pkt_length_head;

  assign queue_pointer           = `MAC_TOP_HIERARCHY.i_gem_rx.queue_ptr_rx;
  assign queue_pointer_rx_rd     = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.queue_ptr_rx_rph;
  assign ahb_sf_err              = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.ahb_sf_err;
  assign n_memory_words_in_frame = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.pkt_length_corrected;
  assign max_val_pclk            = `MAC_TOP_HIERARCHY.i_gem_rx.i_gem_rx_per_queue_flush.max_val_pclk;
  assign dma_bus_width_apb       = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.dma_bus_width;

  // The UserGuide says that:
  // The current bus width can be programmed through the network configuration register but will be forced
  // to a value no greater than the configured width.
  // Hence:
  `ifdef gem_rx_pkt_buffer
    assign dma_bus_width = (dma_bus_width_apb > `gem_dma_bus_width)? `gem_dma_bus_width: dma_bus_width_apb;
    `else
    assign dma_bus_width = 2'b00;
  `endif

  // pkt_length_head will be expressed in bytes
  // according to the dma_bus_width value
  always @ *
  begin
    case(dma_bus_width)
      2'b00  : pkt_length_head = n_memory_words_in_frame * 4;  // 32bits
      2'b01  : pkt_length_head = n_memory_words_in_frame * 8;  // 64 bits
      default: pkt_length_head = n_memory_words_in_frame * 16; // 128 bits
    endcase
  end

  // -----------------------------------------------------------------------
  //
  //           Assertions for per-queue rx flush Mode1
  //
  // -----------------------------------------------------------------------
  // All these assertions and coverage items will be generated only for the first 2 queues of the design.

  `ifdef gem_rx_pkt_buffer
    wire   pkt_flushed_ambaclk;
    reg    pkt_flushed_ambaclk_del;
    wire   ambaclk;
    wire   ambareset;
    wire   force_discard_on_error_global;

    assign force_discard_on_err_global = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.force_discard_on_err;
    assign ambaclk                     = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.hclk;
    assign ambareset                   = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.n_hreset;
    assign pkt_flushed_ambaclk         = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.rx_dma_pkt_flushed; // that is a toggle

    always @ (posedge ambaclk or negedge ambareset)
    begin
      if(~ambareset)
        pkt_flushed_ambaclk_del <= 1'b0;
      else
        pkt_flushed_ambaclk_del <= pkt_flushed_ambaclk;
    end

    property check_mode1_q0;  @(posedge ambaclk) (ahb_sf_err && force_discard_on_err_q_ambaclk_pad[0] && (queue_pointer_rx_rd == 0)) |-> (##[0:1] pkt_flushed_ambaclk != pkt_flushed_ambaclk_del); endproperty assert_check_mode1_q0  : assert property (check_mode1_q0);
    property check_mode1_q1;  @(posedge ambaclk) (ahb_sf_err && force_discard_on_err_q_ambaclk_pad[1] && (queue_pointer_rx_rd == 1)) |-> (##[0:1] pkt_flushed_ambaclk != pkt_flushed_ambaclk_del); endproperty assert_check_mode1_q1  : assert property (check_mode1_q1);

    property dma_config_24_unset; @(posedge ambaclk) (|force_discard_on_err_q_ambaclk_pad) |-> (~force_discard_on_err_global); endproperty assert_dma_config_24_unset : assert property (dma_config_24_unset);

  `endif // gem_rx_pkt_buffer

  wire   [`edma_queues-1:0] force_discard_on_err_q_ambaclk;  // Mode1 enable vector at core level
  wire   [`edma_queues-1:0] limit_num_bytes_allowed_ambaclk; // Mode2 enable vector at core level Gated with Mode3 enable signal

  genvar a;
  generate for(a=0; a<`edma_queues; a=a+1) begin: gen_frame_rxd_q
    always @ (*)
    begin
      if((queue_pointer == a) && rx_w_eop)
        frame_rxd_q_int[a] = 1'b1;
      else
        frame_rxd_q_int[a] = 1'b0;

      if((queue_pointer_rx_rd == a) && ahb_sf_err)
        lack_res_q_int[a] = 1'b1;
      else
        lack_res_q_int[a] = 1'b0;
    end
    assign force_discard_on_err_q_ambaclk[a] = `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.force_discard_on_err_q[a];
    assign limit_num_bytes_allowed_ambaclk[a]= `EDMA_TOP_HIERARCHY.i_edma_pbuf_rx.i_edma_pbuf_rx_rd.limit_num_bytes_allowed_ambaclk[a];
  end
  endgenerate

  assign force_discard_on_err_q_ambaclk_pad  = {{(17-`edma_queues){1'b0}},force_discard_on_err_q_ambaclk};
  assign limit_num_bytes_allowed_ambaclk_pad = {{(17-`edma_queues){1'b0}},limit_num_bytes_allowed_ambaclk};
  assign max_val_pclk_pad                    = {{(257-(16*`edma_queues)){1'b0}},max_val_pclk};
  assign frame_rxd_q                         = {{(17-`edma_queues){1'b0}},frame_rxd_q_int};
  assign lack_res_q                          = {{(17-`edma_queues){1'b0}},lack_res_q_int};

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// Mode 1 queue-specific FC ///////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  `define CP_MODE1_Q0  cp_mode1_q0:  coverpoint force_discard_on_err_q_ambaclk_pad[0]  {bins mode1_off = {0}; bins mode1_on = {1};}
  `define CP_MODE1_Q1  cp_mode1_q1:  coverpoint force_discard_on_err_q_ambaclk_pad[1]  {bins mode1_off = {0}; bins mode1_on = {1};}

  `define CP_PKT_LENGTH_HEAD cp_pkt_length_head: coverpoint pkt_length_head {bins len_1_749={[1:749]}; bins len_750_1k5={[750:1499]};bins len_great_1k5={[1500:$]};}

  // Cover Mode1 set/unset on lack of resources for each queue
  covergroup cg_mode1_q0  @(posedge lack_res_q[0]);  `CP_MODE1_Q0  endgroup cg_mode1_q0  i_cg_mode1_q0  = new();
  covergroup cg_mode1_q1  @(posedge lack_res_q[1]);  `CP_MODE1_Q1  endgroup cg_mode1_q1  i_cg_mode1_q1  = new();

  // Cover Mode1 set with spram mode
  covergroup cg_mode1_spram_q0  @(posedge lack_res_q[0]  && force_discard_on_err_q_ambaclk_pad[0] ); `CP_SRAM_MODE endgroup cg_mode1_spram_q0  i_cg_mode1_spram_q0  = new();
  covergroup cg_mode1_spram_q1  @(posedge lack_res_q[1]  && force_discard_on_err_q_ambaclk_pad[1] ); `CP_SRAM_MODE endgroup cg_mode1_spram_q1  i_cg_mode1_spram_q1  = new();

  // Cover Mode1 set with packet length size at the head of the sram
  covergroup cg_mode1_pkt_len_q0  @(posedge lack_res_q[0]  && force_discard_on_err_q_ambaclk_pad[0] ); `CP_PKT_LENGTH_HEAD endgroup cg_mode1_pkt_len_q0  i_cg_mode1_pkt_len_q0  = new();
  covergroup cg_mode1_pkt_len_q1  @(posedge lack_res_q[1]  && force_discard_on_err_q_ambaclk_pad[1] ); `CP_PKT_LENGTH_HEAD endgroup cg_mode1_pkt_len_q1  i_cg_mode1_pkt_len_q1  = new();

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////// Mode 2 queue-specific FC ///////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  `define CP_MODE2_Q0  cp_mode2_q0:  coverpoint limit_num_bytes_allowed_ambaclk_pad[0]  {bins mode2_off = {0}; bins mode2_on = {1};}
  `define CP_MODE2_Q1  cp_mode2_q1:  coverpoint limit_num_bytes_allowed_ambaclk_pad[1]  {bins mode2_off = {0}; bins mode2_on = {1};}

   // The maximum value for Mode2 is set according to the configuration but we can take the worst case along all the configs which is 11 bits of width for the address and a ram word size of
   // 128 bits. This means that in the worst case, ram_size = 2^11 * 128/8 [bytes] But then this number we are setting in the register is expressed in 128 bytes unit then we need to divide it by 128.
   // Finally the maximum value we can set this register to is 256.
  `define CP_MODE2_MAX_VAL_Q0  cp_mode2_max_val_q0:  coverpoint max_val_pclk_pad[15:0]    {bins max_val_1_82={[1:82]};bins max_val_83_169={[83:169]};bins max_val_170_256={[170:256]};}
  `define CP_MODE2_MAX_VAL_Q1  cp_mode2_max_val_q1:  coverpoint max_val_pclk_pad[31:16]   {bins max_val_1_82={[1:82]};bins max_val_83_169={[83:169]};bins max_val_170_256={[170:256]};}

  // Cover Mode2 set/unset on a frame rcvd for that queue
  covergroup cg_mode2_q0  @(posedge frame_rxd_q[0]);  `CP_MODE2_Q0  endgroup cg_mode2_q0  i_cg_mode2_q0  = new();
  covergroup cg_mode2_q1  @(posedge frame_rxd_q[1]);  `CP_MODE2_Q1  endgroup cg_mode2_q1  i_cg_mode2_q1  = new();

  // Cover Mode2 set with cutthru mode
  covergroup cg_mode2_cutthru_q0  @(posedge frame_rxd_q[0]  && limit_num_bytes_allowed_ambaclk_pad[0] ); `CP_RX_FORWARD_MODE endgroup cg_mode2_cutthru_q0  i_cg_mode2_cutthru_q0  = new();
  covergroup cg_mode2_cutthru_q1  @(posedge frame_rxd_q[1]  && limit_num_bytes_allowed_ambaclk_pad[1] ); `CP_RX_FORWARD_MODE endgroup cg_mode2_cutthru_q1  i_cg_mode2_cutthru_q1  = new();

  // Cover Mode2 set with spram mode
  covergroup cg_mode2_spram_q0  @(posedge frame_rxd_q[0]  && limit_num_bytes_allowed_ambaclk_pad[0] ); `CP_SRAM_MODE endgroup cg_mode2_spram_q0  i_cg_mode2_spram_q0  = new();
  covergroup cg_mode2_spram_q1  @(posedge frame_rxd_q[1]  && limit_num_bytes_allowed_ambaclk_pad[1] ); `CP_SRAM_MODE endgroup cg_mode2_spram_q1  i_cg_mode2_spram_q1  = new();

  // Cover mode2 set with the range of max_val
  covergroup cg_mode2_max_val_q0  @(posedge frame_rxd_q[0]  && limit_num_bytes_allowed_ambaclk_pad[0] ); `CP_MODE2_MAX_VAL_Q0  endgroup cg_mode2_max_val_q0  i_cg_mode2_max_val_q0  = new();
  covergroup cg_mode2_max_val_q1  @(posedge frame_rxd_q[1]  && limit_num_bytes_allowed_ambaclk_pad[1] ); `CP_MODE2_MAX_VAL_Q1  endgroup cg_mode2_max_val_q1  i_cg_mode2_max_val_q1  = new();

  // -----------------------------------------------------------------------
  //
  //           FC for per-screener traffic policing
  //
  // -----------------------------------------------------------------------
  `ifdef num_type2_screeners
    wire [(16*`num_type2_screeners)-1:0] max_rate_val_q;
    wire [(16*`num_type2_screeners)-1:0] interval_time_q;
    wire      [`num_type2_screeners-1:0] feature_active_q;
    wire [256:0] max_rate_val_q_pad;
    wire [256:0] interval_time_q_pad;
    wire  [16:0] feature_active_q_pad;

    genvar i;
    generate for (i=0; i<`num_type2_screeners; i=i+1) begin: gen_fc_scrn_traf_pol

      assign max_rate_val_q  [(16*i)+15:(16*i)]  = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.scr2_rate_lim_regs[(32*i)+31:(32*i)+16];
      assign interval_time_q [(16*i)+15:(16*i)]  = `MAC_TOP_HIERARCHY.i_gem_rx.gen_per_scr2_rate_lim.i_gem_rx_per_scr2_rate_lim.scr2_rate_lim_regs[(32*i)+15:(32*i)];
      assign feature_active_q[i]                 = (interval_time_q[(16*i)+15:(16*i)] != 16'd0);

    end
    endgenerate

    assign max_rate_val_q_pad   = {{(257-(16*`num_type2_screeners)){1'b0}},max_rate_val_q};
    assign interval_time_q_pad  = {{(257-(16*`num_type2_screeners)){1'b0}},interval_time_q};
    assign feature_active_q_pad = {{(257-(16*`num_type2_screeners)){1'b0}},feature_active_q};

    `define CP_TRAF_POL_ACTIVE_REG0  cp_traf_pol_active_reg0 : coverpoint feature_active_q_pad[0 ] {bins traf_pol_active_true={1}; bins traf_pol_active_false={0};}
    `define CP_TRAF_POL_ACTIVE_REG1  cp_traf_pol_active_reg1 : coverpoint feature_active_q_pad[1 ] {bins traf_pol_active_true={1}; bins traf_pol_active_false={0};}

    `define CP_TRAF_POL_MAX_RATE_Q0  cp_traf_pol_max_rate_q0:  coverpoint max_rate_val_q_pad[15:0]    {bins max_val_1_21k={[1:21844]};bins max_val_21k_43k={[21845:43689]};bins max_val_43k_65k={[43689:65535]};}
    `define CP_TRAF_POL_MAX_RATE_Q1  cp_traf_pol_max_rate_q1:  coverpoint max_rate_val_q_pad[31:16]   {bins max_val_1_21k={[1:21844]};bins max_val_21k_43k={[21845:43689]};bins max_val_43k_65k={[43689:65535]};}

    `define CP_TRAF_POL_INT_TIME_Q0  cp_traf_pol_int_time_q0:  coverpoint interval_time_q_pad[15:0]    {bins max_val_1_21k={[1:21844]};bins max_val_21k_43k={[21845:43689]};bins max_val_43k_65k={[43689:65535]};}
    `define CP_TRAF_POL_INT_TIME_Q1  cp_traf_pol_int_time_q1:  coverpoint interval_time_q_pad[31:16]   {bins max_val_1_21k={[1:21844]};bins max_val_21k_43k={[21845:43689]};bins max_val_43k_65k={[43689:65535]};}

    // Note: we are sampling on frame_rxd_q because in CSP the type2 screeners are mapped to the queues 1 to 1, so that's the same.
    // Cover scrn-traf_pol active on a frame rcvd for that queue
    covergroup cg_traf_pol_active0   @(posedge frame_rxd_q[0]);  `CP_TRAF_POL_ACTIVE_REG0  endgroup cg_traf_pol_active0  i_cg_traf_pol_active0  = new();
    covergroup cg_traf_pol_active1   @(posedge frame_rxd_q[1]);  `CP_TRAF_POL_ACTIVE_REG1  endgroup cg_traf_pol_active1  i_cg_traf_pol_active1  = new();

    // Cover scrn-traf_pol active with max_rate range
    covergroup cg_traf_pol_max_rate0   @(posedge frame_rxd_q[0]  && feature_active_q_pad[0] ); `CP_TRAF_POL_MAX_RATE_Q0  endgroup cg_traf_pol_max_rate0  i_cg_traf_pol_max_rate0  = new();
    covergroup cg_traf_pol_max_rate1   @(posedge frame_rxd_q[1]  && feature_active_q_pad[1] ); `CP_TRAF_POL_MAX_RATE_Q1  endgroup cg_traf_pol_max_rate1  i_cg_traf_pol_max_rate1  = new();

    // Cover scrn-traf_pol active with interval_time range
    covergroup cg_traf_pol_int_time0   @(posedge frame_rxd_q[0]  && feature_active_q_pad[0] ); `CP_TRAF_POL_INT_TIME_Q0  endgroup cg_traf_pol_int_time0  i_cg_traf_pol_int_time0  = new();
    covergroup cg_traf_pol_int_time1   @(posedge frame_rxd_q[1]  && feature_active_q_pad[1] ); `CP_TRAF_POL_INT_TIME_Q1  endgroup cg_traf_pol_int_time1  i_cg_traf_pol_int_time1  = new();

    // Cover interval_time range crossed with max_rate range
    covergroup cg_max_rate_x_int_time0   @(posedge frame_rxd_q[0]  && feature_active_q_pad[0] ); `CP_TRAF_POL_INT_TIME_Q0  `CP_TRAF_POL_MAX_RATE_Q0  cp_max_rate_x_int_time_reg0:  cross cp_traf_pol_int_time_q0,  cp_traf_pol_max_rate_q0 ; endgroup cg_max_rate_x_int_time0  i_cg_max_rate_x_int_time0  = new();
    covergroup cg_max_rate_x_int_time1   @(posedge frame_rxd_q[1]  && feature_active_q_pad[1] ); `CP_TRAF_POL_INT_TIME_Q1  `CP_TRAF_POL_MAX_RATE_Q1  cp_max_rate_x_int_time_reg1:  cross cp_traf_pol_int_time_q1,  cp_traf_pol_max_rate_q1 ; endgroup cg_max_rate_x_int_time1  i_cg_max_rate_x_int_time1  = new();

  `endif // num_type2_screeners

    // -----------------------------------------------------------------------
    //
    //                      Coverage for Transmit Launch Time
    //
    // -----------------------------------------------------------------------

    // Coverage of having the TSU available or not ..
    wire has_tsu;
    wire launch_capable;
    logic [31:0] launch_time_q[0:15];
    wire [16:0] launch_enable;
    wire [31:0] current_time;
    wire        sample_launch;
    logic [31:0] launch_time_vs_current_time[0:15];
    logic  [15:0] launch_time_needs_timer_rollover;
    `ifdef gem_tsu
    assign has_tsu = 1'b1;
    `else
    assign has_tsu = 1'b0;
    `endif

    always @(*)
    begin
      for (loop_i = 15; loop_i >0; loop_i = loop_i - 1)
      begin
        launch_time_q[loop_i] = 0;
        launch_time_vs_current_time[loop_i] = 0;
        launch_time_needs_timer_rollover[loop_i] = 0;
      end
    end

    `ifdef gem_tx_pkt_buffer
      assign launch_capable = has_tsu;
      `define GEM_TX_LAUNCH_HIERARCHY  `MAC_TOP_HIERARCHY.i_gem_tx_wrap.gen_tx_fifo_interface.i_gem_tx_fifo_if
      wire [`edma_queues-1:0] launch_enable_q;
      assign launch_enable_q = `GEM_TX_LAUNCH_HIERARCHY.tx_r_launch_time_vld;
      assign launch_enable[16:`edma_queues] = {17-`edma_queues{1'b0}};
      assign current_time     = `GEM_TX_LAUNCH_HIERARCHY.tsu_timer_cnt[47:16];
      always @(*)
      begin
        for (loop_i = tx_top_queue-1; loop_i >= 0; loop_i = loop_i - 1)
          for (loop_j = 31; loop_j >= 0; loop_j = loop_j - 1)
            launch_time_q[loop_i][loop_j] = `GEM_TX_LAUNCH_HIERARCHY.tx_r_launch_time[32*loop_i+loop_j];
        for (loop_i = tx_top_queue-1; loop_i >= 0; loop_i = loop_i - 1)
        begin
          if (launch_time_q[loop_i][31] && !current_time[31]) // Time has rolled over ..
          begin
            launch_time_vs_current_time[loop_i] = 33'h100000000 - ((33'h100000000 - launch_time_q[loop_i][31]) + current_time); // Creates a negative number as time > launch time
            launch_time_needs_timer_rollover[loop_i] = 1'b0;
          end
          else if (!launch_time_q[loop_i][31] && current_time[31]) // Time will have to rollover before launch
          begin
            launch_time_vs_current_time[loop_i] = (33'h100000000 - current_time) + launch_time_q[loop_i];
            launch_time_needs_timer_rollover[loop_i] = 1'b1;
          end
          else
          begin
            launch_time_vs_current_time[loop_i] = launch_time_q[loop_i] - current_time;
            launch_time_needs_timer_rollover[loop_i] = 1'b0;
          end
        end
      end
      assign sample_launch    = `GEM_TX_LAUNCH_HIERARCHY.nothing_to_xmit || `GEM_TX_LAUNCH_HIERARCHY.reschedule_now;
    `else
      assign launch_capable = 1'b0;
      assign current_time   = 32'd0;
      assign launch_enable  = 17'd0000;
      assign sample_launch  = 1'b0;
    `endif

    `define CP_TX_HAS_LAUNCH \
      cp_tx_has_launch : coverpoint (launch_capable) { \
        bins  cfg_has_launch_capability  = {1};  \
      }

    `define CP_TSU_TIME \
      cp_tsu_time : coverpoint (current_time) { \
        bins  low_value  = {[0:32'h10000000]};  \
        bins  med_value  = {[32'h10000001:32'hefffffff]};  \
        bins  high_value  = {[32'hf0000000:32'hffffffff]};  \
      }

    // Configuration Cross
    covergroup cg_cross_launch_capable_queue @(posedge sampled_config);
      `CP_TX_HAS_LAUNCH
      `CP_PRIORITY_QUEUES_ACT
      `CP_AHB_MODE
      `CP_DMA_BUS_WIDTH
      `CP_DMA_ADDR_BUS_WIDTH
      cp_buffers_per_frame : coverpoint (tx_buffers_per_frame) {
        bins one_buffer = {1};
        bins more_than_one_buffers = {[2:$]};
      }
      cp_launch_config_cross : cross cp_tx_has_launch, cp_ahb_mode, cp_pri_queues_act,cp_dma_bus_width,cp_addr_bus_width;
      cp_num_bufs_with_launch : cross cp_tx_has_launch, cp_buffers_per_frame;
    endgroup
    cg_cross_launch_capable_queue m_cg_cross_launch_capable_queue = new();

    // Sample the launch time at the point the scheduler sees it first, and the distance from the current time..
    covergroup cg_launch_queue @(negedge sample_launch);
      cp_launch_time_needs_timer_rollover  : coverpoint (launch_time_needs_timer_rollover[0]);
      cp_launch_en_q0  : coverpoint (launch_enable[0 ]) { bins  frm_launch_en_q0  = {1}; }
      cp_launch_en_q1  : coverpoint (launch_enable[1 ]) { bins  frm_launch_en_q1  = {1}; }
      cp_launch_en_q2  : coverpoint (launch_enable[2 ]) { bins  frm_launch_en_q2  = {1}; }
      cp_launch_en_q3  : coverpoint (launch_enable[3 ]) { bins  frm_launch_en_q3  = {1}; }
      cp_launch_en_q4  : coverpoint (launch_enable[4 ]) { bins  frm_launch_en_q4  = {1}; }
      cp_launch_en_q5  : coverpoint (launch_enable[5 ]) { bins  frm_launch_en_q5  = {1}; }
      cp_launch_en_q6  : coverpoint (launch_enable[6 ]) { bins  frm_launch_en_q6  = {1}; }
      cp_launch_en_q7  : coverpoint (launch_enable[7 ]) { bins  frm_launch_en_q7  = {1}; }
      cp_launch_en_q8  : coverpoint (launch_enable[8 ]) { bins  frm_launch_en_q8  = {1}; }
      cp_launch_en_q9  : coverpoint (launch_enable[9 ]) { bins  frm_launch_en_q9  = {1}; }
      cp_launch_en_q10 : coverpoint (launch_enable[10]) { bins  frm_launch_en_q10 = {1}; }
      cp_launch_en_q11 : coverpoint (launch_enable[11]) { bins  frm_launch_en_q11 = {1}; }
      cp_launch_en_q12 : coverpoint (launch_enable[12]) { bins  frm_launch_en_q12 = {1}; }
      cp_launch_en_q13 : coverpoint (launch_enable[13]) { bins  frm_launch_en_q13 = {1}; }
      cp_launch_en_q14 : coverpoint (launch_enable[14]) { bins  frm_launch_en_q14 = {1}; }
      cp_launch_en_q15 : coverpoint (launch_enable[15]) { bins  frm_launch_en_q15 = {1}; }
      cp_launch_time_q0  : coverpoint (launch_time_vs_current_time[0]) {
        bins launch_vs_current_time_2000_q0     = {[0:2000]};
        bins launch_vs_current_time_10000_q0    = {[2001:10000]};
        bins launch_vs_current_time_100000_q0   = {[10001:100000]};
        bins launch_vs_current_time_massive_q0  = {[100001:(2**31-1)]};
        bins launch_b4_current_time_q0          = {[(2**31):$]};
      }
      cp_launch_time_q1  : coverpoint (launch_time_vs_current_time[1 ]) { bins  launch_b4_current_time_q1  = {[(2**31):$]}; bins launch_vs_current_time_2000_q1  = {[0:2000]}; bins launch_vs_current_time_10000_q1  = {[2001:10000]};  bins launch_vs_current_time_100000_q1  = {[10001:100000]};   bins launch_vs_current_time_massive_q1  = {[100001:(2**31-1)]}; }
      cp_launch_time_q2  : coverpoint (launch_time_vs_current_time[2 ]) { bins  launch_b4_current_time_q2  = {[(2**31):$]}; bins launch_vs_current_time_2000_q2  = {[0:2000]}; bins launch_vs_current_time_10000_q2  = {[2001:10000]};  bins launch_vs_current_time_100000_q2  = {[10001:100000]};   bins launch_vs_current_time_massive_q2  = {[100001:(2**31-1)]}; }
      cp_launch_time_q3  : coverpoint (launch_time_vs_current_time[3 ]) { bins  launch_b4_current_time_q3  = {[(2**31):$]}; bins launch_vs_current_time_2000_q3  = {[0:2000]}; bins launch_vs_current_time_10000_q3  = {[2001:10000]};  bins launch_vs_current_time_100000_q3  = {[10001:100000]};   bins launch_vs_current_time_massive_q3  = {[100001:(2**31-1)]}; }
      cp_launch_time_q4  : coverpoint (launch_time_vs_current_time[4 ]) { bins  launch_b4_current_time_q4  = {[(2**31):$]}; bins launch_vs_current_time_2000_q4  = {[0:2000]}; bins launch_vs_current_time_10000_q4  = {[2001:10000]};  bins launch_vs_current_time_100000_q4  = {[10001:100000]};   bins launch_vs_current_time_massive_q4  = {[100001:(2**31-1)]}; }
      cp_launch_time_q5  : coverpoint (launch_time_vs_current_time[5 ]) { bins  launch_b4_current_time_q5  = {[(2**31):$]}; bins launch_vs_current_time_2000_q5  = {[0:2000]}; bins launch_vs_current_time_10000_q5  = {[2001:10000]};  bins launch_vs_current_time_100000_q5  = {[10001:100000]};   bins launch_vs_current_time_massive_q5  = {[100001:(2**31-1)]}; }
      cp_launch_time_q6  : coverpoint (launch_time_vs_current_time[6 ]) { bins  launch_b4_current_time_q6  = {[(2**31):$]}; bins launch_vs_current_time_2000_q6  = {[0:2000]}; bins launch_vs_current_time_10000_q6  = {[2001:10000]};  bins launch_vs_current_time_100000_q6  = {[10001:100000]};   bins launch_vs_current_time_massive_q6  = {[100001:(2**31-1)]}; }
      cp_launch_time_q7  : coverpoint (launch_time_vs_current_time[7 ]) { bins  launch_b4_current_time_q7  = {[(2**31):$]}; bins launch_vs_current_time_2000_q7  = {[0:2000]}; bins launch_vs_current_time_10000_q7  = {[2001:10000]};  bins launch_vs_current_time_100000_q7  = {[10001:100000]};   bins launch_vs_current_time_massive_q7  = {[100001:(2**31-1)]}; }
      cp_launch_time_q8  : coverpoint (launch_time_vs_current_time[8 ]) { bins  launch_b4_current_time_q8  = {[(2**31):$]}; bins launch_vs_current_time_2000_q8  = {[0:2000]}; bins launch_vs_current_time_10000_q8  = {[2001:10000]};  bins launch_vs_current_time_100000_q8  = {[10001:100000]};   bins launch_vs_current_time_massive_q8  = {[100001:(2**31-1)]}; }
      cp_launch_time_q9  : coverpoint (launch_time_vs_current_time[9 ]) { bins  launch_b4_current_time_q9  = {[(2**31):$]}; bins launch_vs_current_time_2000_q9  = {[0:2000]}; bins launch_vs_current_time_10000_q9  = {[2001:10000]};  bins launch_vs_current_time_100000_q9  = {[10001:100000]};   bins launch_vs_current_time_massive_q9  = {[100001:(2**31-1)]}; }
      cp_launch_time_q10 : coverpoint (launch_time_vs_current_time[10]) { bins  launch_b4_current_time_q10 = {[(2**31):$]}; bins launch_vs_current_time_2000_q10 = {[0:2000]}; bins launch_vs_current_time_10000_q10 = {[2001:10000]};  bins launch_vs_current_time_100000_q10 = {[10001:100000]};   bins launch_vs_current_time_massive_q10 = {[100001:(2**31-1)]}; }
      cp_launch_time_q11 : coverpoint (launch_time_vs_current_time[11]) { bins  launch_b4_current_time_q11 = {[(2**31):$]}; bins launch_vs_current_time_2000_q11 = {[0:2000]}; bins launch_vs_current_time_10000_q11 = {[2001:10000]};  bins launch_vs_current_time_100000_q11 = {[10001:100000]};   bins launch_vs_current_time_massive_q11 = {[100001:(2**31-1)]}; }
      cp_launch_time_q12 : coverpoint (launch_time_vs_current_time[12]) { bins  launch_b4_current_time_q12 = {[(2**31):$]}; bins launch_vs_current_time_2000_q12 = {[0:2000]}; bins launch_vs_current_time_10000_q12 = {[2001:10000]};  bins launch_vs_current_time_100000_q12 = {[10001:100000]};   bins launch_vs_current_time_massive_q12 = {[100001:(2**31-1)]}; }
      cp_launch_time_q13 : coverpoint (launch_time_vs_current_time[13]) { bins  launch_b4_current_time_q13 = {[(2**31):$]}; bins launch_vs_current_time_2000_q13 = {[0:2000]}; bins launch_vs_current_time_10000_q13 = {[2001:10000]};  bins launch_vs_current_time_100000_q13 = {[10001:100000]};   bins launch_vs_current_time_massive_q13 = {[100001:(2**31-1)]}; }
      cp_launch_time_q14 : coverpoint (launch_time_vs_current_time[14]) { bins  launch_b4_current_time_q14 = {[(2**31):$]}; bins launch_vs_current_time_2000_q14 = {[0:2000]}; bins launch_vs_current_time_10000_q14 = {[2001:10000]};  bins launch_vs_current_time_100000_q14 = {[10001:100000]};   bins launch_vs_current_time_massive_q14 = {[100001:(2**31-1)]}; }
      cp_launch_time_q15 : coverpoint (launch_time_vs_current_time[15]) { bins  launch_b4_current_time_q15 = {[(2**31):$]}; bins launch_vs_current_time_2000_q15 = {[0:2000]}; bins launch_vs_current_time_10000_q15 = {[2001:10000]};  bins launch_vs_current_time_100000_q15 = {[10001:100000]};   bins launch_vs_current_time_massive_q15 = {[100001:(2**31-1)]}; }
    endgroup
    cg_launch_queue m_cg_launch_queue = new();

    // TSU Initialization
    covergroup cg_tsu_initialization @(posedge sampled_config);
      `CP_TSU_TIME
    endgroup
    cg_tsu_initialization m_cg_tsu_initialization = new();

  `endif  // MDV

endmodule
