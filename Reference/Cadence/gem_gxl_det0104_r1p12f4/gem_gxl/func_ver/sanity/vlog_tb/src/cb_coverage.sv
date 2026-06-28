//------------------------------------------------------------------------------
// Copyright (c) 2016-2017 Cadence Design Systems, Inc.
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
//   Filename:           cb_coverage.sv
//   Module Name:        cb_coverage
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
// Description    :
//
// Functional coverage buckets and sampling for the 802.1CB features
//
//------------------------------------------------------------------------------


`include "gem_gxl_defs.v"
`include "edma_defs.v"

module cb_coverage();

`ifndef MAC_TOP_HIERARCHY
  `define MAC_TOP_HIERARCHY     `hierarchy.i_gem_mac
  `define GEM_REG_TOP_HIERARCHY `hierarchy.i_gem_reg_top
`endif

`ifndef gem_no_of_cb_streams
  logic [7:0] num_cb_streams = 0;
`else
  logic [7:0] num_cb_streams = `gem_no_of_cb_streams;
`endif
`ifndef gem_seq_history_len
  logic [7:0] cb_seq_history_len = 0;
`else
  logic [7:0] cb_seq_history_len = `gem_seq_history_len;
`endif

`ifndef num_type2_screeners
  logic [7:0] num_screeners_type2 = 0;
`else
  logic [7:0] num_screeners_type2 = `num_type2_screeners;
`endif

  logic [5:0] rx_dec_state;
  logic [5:0] rx_dec_state_last;
  logic [1:0] vlan_cnt;
  logic [1:0] rtag_pos;
  logic       rx_dec_ns;
  logic       frer_6b_tag;
  logic       rtag_state;
  logic       pkt_has_rtag;
  logic       rx_clk;
  logic       n_rxreset;

  // RX Decoder states (only ones relevant to this coverage)
  parameter RX_DEC_TYPE   = 6'h07;  // RX DEC TYPE state
  parameter RX_DEC_IDLE   = 6'h00;  // RX DEC IDLE state
  parameter RX_DEC_VLAN1  = 6'h08;  // RX DEC VLAN1 state
  parameter RX_DEC_VLAN2  = 6'h09;  // RX DEC VLAN2 state
  parameter CB_RTAG       = 6'h30;  // Detected 802.1CB RTag
  parameter CB_TAG_RSVD   = 6'h31;  // Reserved fields

  assign rx_clk       = `MAC_TOP_HIERARCHY.i_gem_rx.rx_clk;
  assign n_rxreset    = `MAC_TOP_HIERARCHY.i_gem_rx.n_rxreset;
  assign frer_6b_tag  = `MAC_TOP_HIERARCHY.i_gem_rx.i_rx_deco.frer_6b_tag;
  assign rx_dec_state = `MAC_TOP_HIERARCHY.i_gem_rx.i_rx_deco.rx_dec_state;
  assign rx_dec_ns    = rx_dec_state != rx_dec_state_last;
  assign rtag_state   = (rx_dec_state == CB_RTAG);

  // Delay rx_dec_state for state transition detection
  always@(posedge rx_clk or negedge n_rxreset)
  begin
    if (~n_rxreset)
      rx_dec_state_last <= RX_DEC_IDLE;
    else
      rx_dec_state_last <= rx_dec_state;
  end

  // Count the number of VLANs detected and capture the R-TAG positioning
  // wrt the VLANs
  always@(posedge rx_clk or negedge n_rxreset)
  begin
    if (~n_rxreset)
    begin
      vlan_cnt      <= 2'h0;
      rtag_pos      <= 2'h0;
      pkt_has_rtag  <= 1'b0;
    end
    else if (rx_dec_ns)
    begin
      if (rx_dec_state == RX_DEC_IDLE)
      begin
        vlan_cnt      <= 2'h0;
        rtag_pos      <= 2'h0;
        pkt_has_rtag  <= 1'b0;
      end
      else
        if (rx_dec_state == RX_DEC_VLAN1)
          vlan_cnt  <= vlan_cnt + 2'h1;
        else
          if (rx_dec_state == CB_RTAG)
          begin
            rtag_pos      <= vlan_cnt;
            pkt_has_rtag  <= 1'b1;
          end
    end
  end

  // Coverage of R-TAG positioning wrt VLANs.
  // 0 = After SA
  // 1 = After VLAN1
  // 2 = After VLAN2
  `define CP_RTAG_POS \
    cp_rtag_pos : coverpoint (rtag_pos) { \
      bins  after_sa    = {0}; \
      bins  after_vlan1 = {1}; \
      bins  after_vlan2 = {2}; \
    }

  // Coverage of detection of 4-byte vs 6-byte redundancy tag
  `define CP_CB_VERSION \
    cp_cb_6b_rtag : coverpoint (frer_6b_tag)  {}

  covergroup cg_cb_version @(posedge pkt_has_rtag);
    `CP_CB_VERSION
  endgroup
  cg_cb_version cg_cb_version_int = new();

  covergroup cg_rtag_pos @(posedge pkt_has_rtag);
    `CP_RTAG_POS
    `CP_CB_VERSION
    cross cp_cb_6b_rtag, cp_rtag_pos {}
  endgroup
  cg_rtag_pos cg_rtag_pos_inst = new();

  //sampling config condition
  logic sample_config = 1'b0;
  always @(posedge rx_clk)
    if (`MAC_TOP_HIERARCHY.i_gem_rx.enable_receive_rck)
      sample_config <= 1'b1;
    else
      sample_config <= 1'b0;


  `define CP_CB_STREAMS \
    cp_cb_disabled : coverpoint (num_cb_streams) { \
      bins cb_disabled = {0}; \
    } \
    cp_cb_streams : coverpoint (num_cb_streams) { \
      bins bin_1 = {1}; \
      bins bin_2to7 = {[2:7]}; \
      bins bin_8to16 = {[8:16]}; \
    }

  `define CP_NUM_SCREENERS_TYPE2 \
    cp_num_screeners_type2 : coverpoint (num_screeners_type2) { \
      bins screeners1 = {1}; \
      bins screeners4 = {4}; \
      bins screeners16 = {16}; \
    }

  `define CP_CB_SEQ_HISTORY_LEN \
    cp_cb_seq_history_len : coverpoint (cb_seq_history_len) { \
      bins hist_len16 = {16}; \
      bins hist_len32 = {32}; \
      bins hist_len64 = {64}; \
    }

  `define CP_CB_TIMEOUT_VALUE \
    cp_cb_timeout_val : coverpoint (`MAC_TOP_HIERARCHY.frer_to_cnt) { \
      ignore_bins cb_to_cnt_irrelevant = {0}; \
      bins cb_to_cnt_any = {[16'h1:16'hFFFF]}; \
      bins cb_to_cnt_max = {16'hFFFF}; \
    }

  // Create a sample pulse for the timeout register.
  // This is sampled whenever the timeout function is enabled.
  logic [16:0]  frer_en_to_sync;
  logic [16:0]  frer_en_to_sync_d;
  logic         frer_en_to_sample;
`ifdef gem_no_of_cb_streams
  `ifdef num_type2_screeners
    assign frer_en_to_sync  = {{(17-`gem_no_of_cb_streams){1'b0}},`MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.frer_en_to_sync};
  `else
    assign frer_en_to_sync  = 17'd0;
  `endif
`else
  assign frer_en_to_sync  = 17'd0;
`endif

  always@(posedge rx_clk)
    frer_en_to_sync_d <= frer_en_to_sync;

  assign frer_en_to_sample  = |(frer_en_to_sync & ~frer_en_to_sync_d);

  covergroup cg_cb_static_single_config @(posedge sample_config);
    `CP_CB_STREAMS
    `CP_NUM_SCREENERS_TYPE2
    `CP_CB_SEQ_HISTORY_LEN
  endgroup
  cg_cb_static_single_config cg_cb_static_single_config_inst = new();

  covergroup cg_cb_static_prg_config @(posedge frer_en_to_sample);
    `CP_CB_TIMEOUT_VALUE
  endgroup
  cg_cb_static_prg_config cg_cb_static_prg_config_inst = new();

//frer ctrl a/b

`ifdef gem_no_of_cb_streams
  `ifdef num_type2_screeners

    logic [8:0] frer_seqnum_oset [1:16];
    logic [4:0] frer_seqnum_len [1:16];
    logic [3:0] frer_scr_sel_1 [1:16];
    logic [3:0] frer_scr_sel_2 [1:16];
    logic [5:0] frer_vec_win_sz [1:16];
    logic frer_stream_matched [1:16];
    logic frer_seq_num_val_mux [1:16];
    logic frer_seq_ahead [1:16];
    logic frer_seq_behind [1:16];
    logic frer_update_enable [1:16];
    logic frer_rx_end_frame [1:16];
    logic [15:0] frer_delta_ahead [1:16];
    logic [15:0] frer_delta_behind [1:16];
    logic frer_bad_frame [1:16];

    logic [15:0] cb_cov_sample;
    logic [15:0] cb_eof_sample;
    logic cb_cov_sample_any;
    logic cb_end_frame_any;

    generate
      genvar j;
      for (j = 0; j < 16; j++) begin
        if (j < `gem_no_of_cb_streams) begin
          assign frer_seqnum_oset[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].frer_seqnum_oset;
          assign frer_seqnum_len[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].frer_seqnum_len;
          assign frer_scr_sel_1[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].frer_scr_sel_1;
          assign frer_scr_sel_2[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].frer_scr_sel_2;
          assign frer_vec_win_sz[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].frer_vec_win_sz;
          assign frer_stream_matched[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].stream_matched;
          assign frer_seq_num_val_mux[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].seq_num_val_mux;
          assign frer_seq_ahead[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].seq_ahead;
          assign frer_seq_behind[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].seq_behind;
          assign frer_delta_ahead[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].delta_ahead;
          assign frer_delta_behind[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].delta_behind;
          assign frer_bad_frame[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].bad_frame;
          assign frer_update_enable[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].update_enable;
          assign frer_rx_end_frame[j+1] = `MAC_TOP_HIERARCHY.i_gem_rx.gen_cb.i_frer_elim[j].rx_end_frame;
          //coverage sample
          assign cb_cov_sample[j] = frer_stream_matched[j+1] & frer_seq_num_val_mux[j+1] & ~frer_bad_frame[j+1] & frer_rx_end_frame[j+1];
          assign cb_eof_sample[j] = frer_rx_end_frame[j+1];
        end else begin
          assign cb_cov_sample[j] = 1'b0;
          assign cb_eof_sample[j] = 1'b0;
        end
      end
    endgenerate

    assign cb_cov_sample_any = |cb_cov_sample[(`gem_no_of_cb_streams-1):0];
    assign cb_end_frame_any = |cb_eof_sample[(`gem_no_of_cb_streams-1):0];

    `define CP_CB_SEQNUM_LENGTH(x) \
      cp_cb_seqnum_length : coverpoint (frer_seqnum_len[x]) { \
        bins cb_seqnum_len_8 = {8} iff cb_cov_sample[x-1]; \
        bins cb_seqnum_len_16 = {16} iff cb_cov_sample[x-1]; \
      }

    `define CP_CB_VEC_REC_WINDOW(x) \
      cp_cb_vec_rec_window : coverpoint (frer_vec_win_sz[x]) { \
        bins cb_vec_rec_win_max = {0} iff                (cb_cov_sample[x-1] & `MAC_TOP_HIERARCHY.frer_en_vec_alg[x-1]); \
        bins cb_vec_rec_win_1 = {1} iff                  (cb_cov_sample[x-1] & `MAC_TOP_HIERARCHY.frer_en_vec_alg[x-1]); \
        bins cb_vec_rec_win_less_than_8 = {[2:7]} iff    (cb_cov_sample[x-1] & `MAC_TOP_HIERARCHY.frer_en_vec_alg[x-1]); \
        bins cb_vec_rec_win_less_than_32 = {[8:31]} iff  (cb_cov_sample[x-1] & `MAC_TOP_HIERARCHY.frer_en_vec_alg[x-1]); \
        bins cb_vec_rec_win_more_than_32 = {[32:63]} iff (cb_cov_sample[x-1] & `MAC_TOP_HIERARCHY.frer_en_vec_alg[x-1]); \
      }

    `define CP_CB_USE_RTAG(x) \
      cp_cb_use_rtag : coverpoint (`MAC_TOP_HIERARCHY.frer_use_rtag[x-1]) { \
        bins cb_use_rtag_dis = {1'b0}; \
        bins cb_use_rtag_en = {1'b1}; \
      }

    `define CP_CB_SEQNUM_OFFSET(x) \
      cp_cb_seqnum_offset : coverpoint (frer_seqnum_oset[x]) { \
        bins cb_seqnum_offset_12_to_31_even = {[12:31]} iff      (~frer_seqnum_oset[x][0] & cb_cov_sample[x-1]); \
        bins cb_seqnum_offset_12_to_31_odd  = {[12:31]} iff       (frer_seqnum_oset[x][0] & cb_cov_sample[x-1]); \
        bins cb_seqnum_offset_32_to_127_even = {[32:127]} iff    (~frer_seqnum_oset[x][0] & cb_cov_sample[x-1]); \
        bins cb_seqnum_offset_32_to_127_odd  = {[32:127]} iff     (frer_seqnum_oset[x][0] & cb_cov_sample[x-1]); \
        bins cb_seqnum_offset_128_to_499_even = {[128:499]} iff  (~frer_seqnum_oset[x][0] & cb_cov_sample[x-1]); \
        bins cb_seqnum_offset_128_to_499_odd  = {[128:499]} iff   (frer_seqnum_oset[x][0] & cb_cov_sample[x-1]); \
        bins cb_seqnum_offset_500_plus  = {[500:510]}; \
        bins cb_seqnum_offset_max  = {511}; \
      }

    `define CP_CB_VEC_ENABLED(x) \
      cp_cb_elim_algorithm : coverpoint (`MAC_TOP_HIERARCHY.frer_en_vec_alg[x-1] & cb_cov_sample[x-1]) { \
        bins cb_match_elim_alg = {1'b0}; \
        bins cb_vector_elim_alg = {1'b1}; \
      }

    `define CP_CB_STREAM_ENABLED(x) \
      cp_cb_stream_enabled : coverpoint (`MAC_TOP_HIERARCHY.frer_en_elim[x-1] & cb_cov_sample[x-1]) { \
        bins cb_elim_dis = {1'b0}; \
        bins cb_elim_en = {1'b1}; \
      }

    covergroup cg_cb_per_stream_config (int stream) @(posedge cb_cov_sample_any);
      `CP_CB_SEQNUM_LENGTH(stream)
      `CP_CB_VEC_REC_WINDOW(stream)
      `CP_CB_USE_RTAG(stream)
      `CP_CB_SEQNUM_OFFSET(stream)
      `CP_CB_VEC_ENABLED(stream)
      `CP_CB_STREAM_ENABLED(stream)
       cross cp_cb_stream_enabled, cp_cb_elim_algorithm {
          ignore_bins ign  = binsof(cp_cb_stream_enabled.cb_elim_dis) && binsof(cp_cb_elim_algorithm.cb_vector_elim_alg);
       }
    endgroup

    covergroup cg_cb_screener_reg_map (int stream) @(posedge sample_config);
      cp_cb_screener_reg_map : coverpoint (frer_scr_sel_1[stream] == frer_scr_sel_2[stream]) {
        bins cb_cb_screener_reg_map_same = {1'b1};
        bins cb_cb_screener_reg_map_diff = {1'b0};
      }
    endgroup

    covergroup cg_cb_streams_enabled @(posedge sample_config);
      cp_cb_streams_enabled : coverpoint (`MAC_TOP_HIERARCHY.frer_en_elim[(`gem_no_of_cb_streams-1):0]) {
        bins cp_cb_streams_enabled_none = { {`gem_no_of_cb_streams{1'b0}} };
        bins cp_cb_streams_enabled_all = { {`gem_no_of_cb_streams{1'b1}} };
      }
    endgroup
    cg_cb_streams_enabled cg_cb_streams_enabled_inst = new();

    //packets match screener regs
    covergroup cg_cb_packet_match_screener (int stream) @(posedge cb_cov_sample_any);
      cp_cb_packet_match_screener : coverpoint (frer_stream_matched[stream] & cb_cov_sample[stream-1]) {
        bins cb_packet_match_screener_true = {1'b1};
        bins cb_packet_match_screener_false = {1'b0};
      }
    endgroup

    //vector elimination algorithm
    covergroup cg_cb_vector_elim (int stream) @(posedge cb_cov_sample_any);
      cp_cb_vector_elim_ahead : coverpoint (frer_delta_ahead[stream]) {
        bins cb_vector_elim_delta_ahead_1    = {16'd1} iff (frer_seq_ahead[stream]  & cb_cov_sample[stream-1]);
        bins cb_vector_elim_delta_ahead_2    = {16'd2} iff (frer_seq_ahead[stream]  & cb_cov_sample[stream-1]);
      }
      cp_cb_vector_elim_ahead_max : coverpoint
       (frer_delta_ahead[stream][5:0] == frer_vec_win_sz[stream]) {
        bins cb_vector_elim_delta_ahead_max  = {1'b1}  iff (frer_seq_ahead[stream]  & cb_cov_sample[stream-1]);
      }
      cp_cb_vector_elim_behind : coverpoint (frer_delta_behind[stream]) {
        bins cb_vector_elim_delta_behind_1   = {16'd1} iff (frer_seq_behind[stream] & cb_cov_sample[stream-1]);
        bins cb_vector_elim_delta_behind_2   = {16'd2} iff (frer_seq_behind[stream] & cb_cov_sample[stream-1]);
      }
      cp_cb_vector_elim_behind_max : coverpoint
       (frer_delta_behind[stream][5:0] == frer_vec_win_sz[stream]) {
        bins cb_vector_elim_delta_behind_max = {1'b1}  iff (frer_seq_behind[stream] & cb_cov_sample[stream-1]);
      }
    endgroup

    //CRC_error in first / duplicate
    covergroup cg_cb_crc_err (int stream) @(posedge cb_end_frame_any);
      cp_cb_crc_err : coverpoint (frer_bad_frame[stream] & frer_rx_end_frame[stream]) {
        bins cg_cb_crc_err_good_frame = {1'b0};
        bins cg_cb_crc_err_bad_frame = {1'b1};
      }
    endgroup

    //genereate could be used but its not supported by PD...
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst1 = new(1);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst1 = new(1);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst1 = new(1);
    cg_cb_vector_elim cg_cb_vector_elim_inst1 = new(1);
    cg_cb_crc_err cg_cb_crc_err_inst1 = new(1);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst2 = new(2);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst2 = new(2);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst2 = new(2);
    cg_cb_vector_elim cg_cb_vector_elim_inst2 = new(2);
    cg_cb_crc_err cg_cb_crc_err_inst2 = new(2);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst3 = new(3);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst3 = new(3);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst3 = new(3);
    cg_cb_vector_elim cg_cb_vector_elim_inst3 = new(3);
    cg_cb_crc_err cg_cb_crc_err_inst3 = new(3);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst4 = new(4);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst4 = new(4);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst4 = new(4);
    cg_cb_vector_elim cg_cb_vector_elim_inst4 = new(4);
    cg_cb_crc_err cg_cb_crc_err_inst4 = new(4);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst5 = new(5);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst5 = new(5);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst5 = new(5);
    cg_cb_vector_elim cg_cb_vector_elim_inst5 = new(5);
    cg_cb_crc_err cg_cb_crc_err_inst5 = new(5);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst6 = new(6);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst6 = new(6);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst6 = new(6);
    cg_cb_vector_elim cg_cb_vector_elim_inst6 = new(6);
    cg_cb_crc_err cg_cb_crc_err_inst6 = new(6);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst7 = new(7);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst7 = new(7);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst7 = new(7);
    cg_cb_vector_elim cg_cb_vector_elim_inst7 = new(7);
    cg_cb_crc_err cg_cb_crc_err_inst7 = new(7);
    cg_cb_screener_reg_map cg_cb_screener_reg_map_inst8 = new(8);
    cg_cb_per_stream_config cg_cb_per_stream_config_inst8 = new(8);
    cg_cb_packet_match_screener cg_cb_packet_match_screener_inst8 = new(8);
    cg_cb_vector_elim cg_cb_vector_elim_inst8 = new(8);
    cg_cb_crc_err cg_cb_crc_err_inst8 = new(8);

  `endif // num_type2_screeners
`endif // gem_no_of_cb_streams

endmodule



