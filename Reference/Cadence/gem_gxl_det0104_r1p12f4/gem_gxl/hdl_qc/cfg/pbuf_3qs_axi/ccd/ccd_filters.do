// Existing filters:
add_rule_filter tech_specific -message */process/tsmc* -description {Technologyu specific fails. not design related - Waived.} -rule hdl_default_checks/directive_checks -rule hdl_default_checks/file_checks -rule hdl_default_checks/hierarchy_checks -rule hdl_default_checks/ignored_checks -rule hdl_default_checks/lef_checks -rule hdl_default_checks/misc_checks -rule hdl_default_checks/rtl_checks -rule hdl_default_checks/spice_checks -rule hdl_default_checks/systemverilog_checks -rule hdl_default_checks/udp_checks -rule hdl_default_checks/verilog_checks
add_rule_filter hdl_default_checks/rtl_checks/RTL14/1 -message * -description {Signal was driven but not sampled - config specific and no issue. Waived.} -rule hdl_default_checks/rtl_checks/RTL14
add_rule_filter hdl_default_checks/rtl_checks/RTL14.1/1 -message * -description {Fanout load of the signal is removed - Waived.} -rule hdl_default_checks/rtl_checks/RTL14.1
add_rule_filter hdl_default_checks/rtl_checks/RTL7.11b -message * -description {using an index on for loop count variable is fine. Waived.} -rule hdl_default_checks/rtl_checks/RTL7.11b
add_rule_filter hdl_default_checks/rtl_checks/RTL7.10 -message * -description {genvars and integers are initialized as signed variables. being compared to unsigned integers. No real issue and waived.} -rule hdl_default_checks/rtl_checks/RTL7.10
add_rule_filter hdl_default_checks/rtl_checks/RTL7.11 -message * -description {Notification that signed number is being converted to unsigned - this is as expected as everything in the design is coded as unsigned .} -rule hdl_default_checks/rtl_checks/RTL7.11
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF5 -message * -rule sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF5
add_rule_filter ignore_pclk_to_tx_opsa -message {*output port 'tx_en'*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_tx_opsb -message {*output port 'tx_er'*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_tx_opsc -message {*output port '*txd*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_host_ops5 -message {*output port 'ar*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_host_ops6 -message {*output port 'aw*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_host_ops7 -message {*output port 'w*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_64bhaddr -message {*output port 'haddr*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_tx_clk_sig_to_rmii_clks -message {*input port '*tx_clk_sig*} -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL13
add_rule_filter ignore_trigtx_start_async -message *trigger_dma_tx_start*pclk* -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL6
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7 -message * -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL7 -message * -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL7
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR8 -message * -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR8
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL14 -message * -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL14
add_rule_filter sdc_def_checks/sdc_exception_checks/CCD_EXC_FLP1 -message * -rule sdc_def_checks/sdc_exception_checks/CCD_EXC_FLP1
add_rule_filter sdc_def_checks/sdc_exception_checks/CCD_EXC_SMD1 -message * -rule sdc_def_checks/sdc_exception_checks/CCD_EXC_SMD1
add_rule_filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT4 -message * -rule sdc_def_checks/sdc_design_checks/CCD_DGN_PRT4
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR10 -message * -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR10
add_rule_filter sdc_def_checks/sdc_iodelay_checks/SDC_LINT_CMD6 -message * -rule SDC_LINT_CMD6
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF10 -message * -rule sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF10
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT1 -message * -rule sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT1
add_rule_filter tx_stats1 -message {Crossing *i_gem_tx/tx_broadcast_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats2 -message {Crossing *i_gem_tx/tx_bytes_in_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats3 -message {Crossing *i_gem_tx/tx_crs_error_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats4 -message {Crossing *i_gem_tx/tx_deferred_tx_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats5 -message {Crossing *i_gem_tx/tx_frame_txed_ok* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats6 -message {Crossing *i_gem_tx/tx_late_coll_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats7 -message {Crossing *i_gem_tx/tx_multi_coll_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats8 -message {Crossing *i_gem_tx/tx_multicast_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats9 -message {Crossing *i_gem_tx/tx_pause_frame_txed* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats10 -message {Crossing *i_gem_tx/tx_pause_time* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats11 -message {Crossing *i_gem_tx/tx_pfc_pause_frame_txed* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats12 -message {Crossing *i_gem_tx/tx_single_coll_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats13 -message {Crossing *i_gem_tx/tx_underflow_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats14 -message {Crossing *i_gem_tx/tx_too_many_retries* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter rx_stats1 -message {Crossing *i_gem_rx/rx_align_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats2 -message {Crossing *i_gem_rx/rx_broadcast_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats3 -message {Crossing *i_gem_rx/rx_bytes_in_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats4 -message {Crossing *i_gem_rx/rx_crc_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats5 -message {Crossing *i_gem_rx/rx_frame_rxed_ok* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats6 -message {Crossing *i_gem_rx/rx_ip_ck_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats7 -message {Crossing *i_gem_rx/rx_jabber_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats8 -message {Crossing *i_gem_rx/rx_length_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats9 -message {Crossing *i_gem_rx/rx_long_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats10 -message {Crossing *i_gem_rx/rx_multicast_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats11 -message {Crossing *i_gem_rx/rx_overflow* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats12 -message {Crossing *i_gem_rx/rx_pause_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats13 -message {Crossing *i_gem_rx/rx_pause_nonzero* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats14 -message {Crossing *i_gem_rx/rx_pfc_pause_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats19 -message {Crossing *i_gem_rx/rx_pfc_pause_nonzero* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats15 -message {Crossing *i_gem_rx/rx_short_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats16 -message {Crossing *i_gem_rx/rx_symbol_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats17 -message {Crossing *i_gem_rx/rx_tcp_ck_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter rx_stats18 -message {Crossing *i_gem_rx/rx_udp_ck_error* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter tx_stats19 -message {Crossing */rx_frame_rxed_ok* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk
add_rule_filter tx_stats_dma1 -message {Crossing *i_gem_tx/late_coll_occured* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats_dma2 -message {Crossing *i_gem_tx/too_many_retries* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats_dma3 -message {Crossing *i_gem_tx/underflow_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter rx_dma_complete_ok -message {Crossing */rx_dma_complete_ok*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_hresp_notok -message {Crossing */rx_dma_hresp_notok*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_int_queue -message {Crossing */rx_dma_int_queue*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_resource_err -message {Crossing */rx_dma_resource_err*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter tx_dma_status2apb -message {Crossing */tx_status2apb*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_fill_level_debug_fifo -message {Crossing */mem_reg*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter tx_dma_fill_level_debug_fifo -message {Crossing */mem_reg*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_queue_descr_ptr_to_pclk -message {Crossing */i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_tx/db2_descr_ptr*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_queue_descr_ptr_to_pclk -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_rd/nxt_descr_ptr*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter dma_fifo_static_select_regtorx -message {Crossing */i_gem_reg_top/i_gem_pclk_syncs/rx_status_wr_tog*} -rule cdc_def_rs/cdc_checks/cdc_pclk->rx_clk
add_rule_filter tx_start_multiple -message {Crossing */i_gem_registers/i_network_control_reg/tx_start_pclk*} -rule cdc_def_rs/cdc_checks/cdc_pclk->aclk
add_rule_filter rx_sram_fill_lvl_hs -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_rd/pkt_done_dplocns*} -rule cdc_def_rs/cdc_checks/cdc_aclk->rx_clk
add_rule_filter tx_sram_fill_lvl_hs1 -message {Crossing */i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_queue*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->aclk
add_rule_filter wb_status_to_tx_wr -message {Crossing */i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg* -> *} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->aclk
add_rule_filter rx_num_pkts_xfer1 -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->aclk
add_rule_filter rx_num_pkts_xfer2 -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_fld_offsets*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->aclk
add_rule_filter rx_num_pkts_xfer3 -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_queue_ptr*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->aclk
add_rule_filter tx_num_pkts_xfer1 -message {Crossing */i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer*} -rule cdc_def_rs/cdc_checks/cdc_aclk->tx_clk
add_rule_filter loopback_path1 -message {Crossing */rx_dv_looped_reg*} -rule cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk
add_rule_filter loopback_path2 -message {Crossing */rx_er_looped_reg*} -rule cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk
add_rule_filter loopback_path3 -message {Crossing */rxd_looped*} -rule cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk
add_rule_filter capt_pause_rx_to_tx -message {Crossing */new_pause_time* -> */i_gem_tx/*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk
add_rule_filter tsu_timer_sync1 -message {Crossing *i_gem_tx/*tsu_timer_sampled_on_sof* -> *i_gem_tx*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk
add_rule_filter tsu_timer_sync2 -message {Crossing *i_gem_tx/*tsu_timer_par_sampled_on_sof_r* -> *i_gem_tx*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk
add_rule_filter tsu_timer_sync3 -message {Crossing *i_gem_rx/gen_tsu.tsu_timer_sampled_on_sof* -> *i_gem_rx/gen_tsu.rx_w_timestamp*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk
add_rule_filter tsu_timer_sync4 -message {Crossing *i_gem_rx/gen_tsu.tsu_timer_prty_sampled_on_sof* -> *i_gem_rx/gen_tsu.rx_w_timestamp*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk
add_rule_filter tsu_timer_adj1 -message {Crossing *i_gem_reg_top/i_gem_registers/tsu_timer_adj_reg* -> *i_gem_top/i_gem_tsu/int_timer_nsec_calc_val_reg*} -rule cdc_def_rs/cdc_checks/cdc_pclk->tsu_clk
add_rule_filter tsu_timer_adj2 -message {Crossing *i_gem_reg_top/i_gem_registers/tsu_timer_adj_reg* -> *i_gem_top/i_gem_tsu/int_timer_sec_calc_val_reg*} -rule cdc_def_rs/cdc_checks/cdc_pclk->tsu_clk
add_rule_filter tsu_timer_adj3 -message {Crossing *i_gem_reg_top/i_gem_registers/tsu_timer_adj_reg* -> *i_gem_top/i_gem_tsu/tsu_sec_incr_reg} -rule cdc_def_rs/cdc_checks/cdc_pclk->tsu_clk
add_rule_filter cb_1 -message {Crossing *i_gem_mac/i_gem_rx/gen_cb.i_frer_elim*/frer_err_upd_val*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk
add_rule_filter hdfc -message {Crossing *halfduplex_flow_control_en*} -rule cdc_def_rs/cdc_checks/cdc_pclk->tx_clk

// Filters for waived occurrences:

// Pre-filters

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_ok_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_resource_err_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/i_edma_sync_toggle_detect_rx_dma_buff_not_rdy/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_resource_err_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_resource_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_tx/db2_descr_ptr_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/tx_dma_descr_ptr_pclk_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_dma_tx_sts.tx_buff_exh_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_dma_tx_sts.tx_buff_exh_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_dma_tx_sts.tx_buf_ex_mid_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_nwc.i_nwc_asf_duplc/enable_transmit_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_dma_tx_sts.tx_buf_ex_mid_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_dma_tx_sts.tx_hresp_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_dma_tx_sts.tx_hresp_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/excessive_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/late_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/tx_underruns_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/nxt_descr_ptr_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/rx_dma_descr_ptr_pclk_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_ok_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_complete_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_int_queue_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_int_queue_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_int_queue_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_int_queue_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_resource_err_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/i_edma_sync_toggle_detect_rx_dma_buff_not_rdy/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_rx/rx_dma_resource_err_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_resource_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_tx/db2_descr_ptr_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/tx_dma_descr_ptr_pclk_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_tx/db2_descr_ptr_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/prdata_i_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_dma_tx_sts.tx_buff_exh_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_dma_tx_sts.tx_buff_exh_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_dma_tx_sts.tx_buf_ex_mid_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_nwc.i_nwc_asf_duplc/enable_transmit_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_dma_tx_sts.tx_buf_ex_mid_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_dma_tx_sts.tx_hresp_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_dma_tx_sts.tx_hresp_status_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/excessive_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/late_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/tx_underruns_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_status2apb_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/nxt_descr_ptr_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/rx_dma_descr_ptr_pclk_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/nxt_descr_ptr_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/prdata_i_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_network_control_reg/tx_start_pclk_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_hclk_syncs/i_edma_sync_toggle_detect_tx_start_pclk/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_pclk->aclk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_network_control_reg/tx_start_pclk_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_lockup_det.i_edma_lockup_detect/i_edma_sync_toggle_detect_tx_start/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_pclk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_network_control_reg/tx_start_pclk_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_hclk_syncs/i_edma_sync_toggle_detect_tx_start_pclk/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_pclk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_network_control_reg/tx_start_pclk_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_lockup_det.i_edma_lockup_detect/i_edma_sync_toggle_detect_tx_start/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_pclk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/pkt_done_dplocns_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/dpram_fill_lvl_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->rx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/pkt_done_dplocns_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/dpram_fill_lvl_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/num_parts_needing_read_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/num_pkts_needing_read_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_fld_offsets_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/early_fld_offset_info_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_fld_offsets_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/part_of_packet_fld_offsets_pending_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/num_parts_needing_read_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/num_pkts_needing_read_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/rxdpram_enb_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_fld_offsets_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/early_fld_offset_info_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_fld_offsets_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/part_of_packet_fld_offsets_pending_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_queue_ptr_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/early_queue_info_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_queue_ptr_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_rx/i_edma_pbuf_rx_rd/gen_set_early_queue_id.part_of_packet_queue_ptr_pending_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/clr_dplocns_val_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/got_sw0_nxt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/got_sw1_nxt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/cmd_fifo_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/fifo_level_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/qempty_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/qfull_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/wr_ptr_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/cmd_fifo_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/fifo_level_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/qempty_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/qfull_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/wr_ptr_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/need_sw0_nxt_req_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/need_sw1_nxt_req_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/num_pkts_in_mac_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/num_pkts_needing_read_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_queue_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_read_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/pkt_data_sram_addr_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/pkt_dplocns_cnt_part_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/pkt_dplocns_cnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/queue_dma_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/queue_mac_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/read_state_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/reading_pkt_last_word_add_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/sram_add_gnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word0_add_int_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word0_nxt_add_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word0_obtained_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word2_obtained_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word3_obtained_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word_0_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/store_1st_sw0_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/store_2nd_sw0_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/store_mac_sw0_en_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/tx_r_data_rdy_aph_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/tx_r_sop_aph_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/gen_tx_fifo_interface.i_gem_tx_fifo_if/dma_is_busy_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/clr_dplocns_val_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/got_sw0_nxt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/got_sw1_nxt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/cmd_fifo_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/fifo_level_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/qempty_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/qfull_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word0_mac/wr_ptr_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/cmd_fifo_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/fifo_level_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/qempty_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/qfull_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_status_word23_mac/wr_ptr_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/need_sw0_nxt_req_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/need_sw1_nxt_req_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/num_pkts_in_mac_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/num_pkts_needing_read_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_queue_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_read_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/pkt_data_sram_addr_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/pkt_dplocns_cnt_part_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/pkt_dplocns_cnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/queue_dma_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/queue_mac_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/read_state_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/reading_pkt_last_word_add_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/sram_add_gnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word0_add_int_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word0_nxt_add_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word0_obtained_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word2_obtained_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word3_obtained_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/status_word_0_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/store_1st_sw0_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/store_2nd_sw0_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/store_mac_sw0_en_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/tx_r_data_rdy_aph_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/tx_r_sop_aph_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/gen_tx_fifo_interface.i_gem_tx_fifo_if/dma_is_busy_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_aclk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/gen_dap.tx_descr_wr_data_par_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_descr_wr_data_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_descr_wr_sts_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/gen_tx_pkt_buffer.gen_tx_dp_parity.i_psync_asf_dap_dma_err/tog_src2dest_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/dpram_fill_lvl_array_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/gen_ts_store.tx_descr_wr_ts_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/gen_dap.gen_ts_par_store.tx_descr_wr_ts_par_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_queue_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/dpram_fill_lvl_array_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/gen_dap.tx_descr_wr_data_par_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_descr_wr_data_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/tx_descr_wr_sts_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/gen_tx_pkt_buffer.gen_tx_dp_parity.i_psync_asf_dap_dma_err/tog_src2dest_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/dpram_fill_lvl_array_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_in_buf_q_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/gen_ts_store.tx_descr_wr_ts_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg\[*\]\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/gen_dap.gen_ts_par_store.tx_descr_wr_ts_par_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_queue_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top/i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/dpram_fill_lvl_array_reg\[*\]\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->aclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rx_dv_looped_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_dv_gmii_sync_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rx_er_looped_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_er_gmii_sync_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rxd_looped_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rxd_gmii_sync_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rxd_looped_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/gen_dp_parity.rxd_par_prev_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rx_dv_looped_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_dv_gmii_sync_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rx_er_looped_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_er_gmii_sync_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rxd_looped_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rxd_gmii_sync_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/gen_int_loopback.i_gem_loop/rxd_looped_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/gen_dp_parity.rxd_par_prev_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/rx_status_wr_tog_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/i_edma_sync_toggle_detect_rx_status_wr_tog/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_pclk->rx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/rx_status_wr_tog_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/i_edma_sync_toggle_detect_rx_status_wr_tog/i_cdnsdru_datasync_v1/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_pclk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/gen_cb.i_frer_elim\[*\]/frer_err_upd_val_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_cb.i_reg_cb/gen_stream_func\[*\].gen_func.latent_cnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_align_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/alignment_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_broadcast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/fcs_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_ok_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_ip_ck_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_jabber_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_jabbers_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_length_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/excessive_rx_length_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_multicast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/rx_overrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_overruns_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/rx_overrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_pause_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_pfc_pause_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_pfc_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_pfc_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/undersize_frames_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_symbol_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_tcp_ck_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_udp_ck_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/gen_cb.i_frer_elim\[*\]/frer_err_upd_val_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_cb.i_reg_cb/gen_stream_func\[*\].gen_func.latent_cnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_align_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/alignment_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_broadcast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/fcs_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_crc_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_rxed_ok_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_rxed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_frame_rxed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/rx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_ip_ck_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_ip_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_jabber_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_jabbers_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_length_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_length_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/excessive_rx_length_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_long_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_multicast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/rx_overrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_overruns_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_overflow_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/rx_overrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_pause_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_pfc_pause_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_rxed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_pfc_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_pfc_pause_nonzero_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/undersize_frames_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_short_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_symbol_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_symbol_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_tcp_ck_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_tcp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/rx_udp_ck_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/rx_udp_ck_error_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_broadcast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_crs_error_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/crs_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_deferred_tx_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/deferred_frames_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_ok_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multiple_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/single_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/late_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_multi_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multiple_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_multicast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/tx_pause_time_pclk_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_tog_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/i_cdnsdru_datasync_v1_tx_pause_time_tog/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pfc_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pfc_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pfc_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_single_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/single_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/excessive_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/tx_underruns_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_broadcast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_bytes_in_frame_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_crs_error_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/crs_errors_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_deferred_tx_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/deferred_frames_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/broadcast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_64_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_65_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_128_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_256_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_512_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1024_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_1519_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/frames_txed_ok_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multiple_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_bottom_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/octets_txed_top_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/single_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_frame_txed_ok_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_frm_comp_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/late_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_late_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/late_coll_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_multi_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multiple_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_multicast_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/multicast_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/tx_pause_time_pclk_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_tog_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_pclk_syncs/i_cdnsdru_datasync_v1_tx_pause_time_tog/meta_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pfc_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pfc_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/pause_frames_txed_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pfc_pause_frame_txed_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_single_coll_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/single_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/excessive_collisions_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_remaining_queues.gen_int_q\[*\].gen_int_q\[*\].gen_int.i_int_q/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_too_many_retries_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/too_many_ret_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_duplc_int_sts.i_reg_int_sts_asf_duplc/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/gen_stats_reg.i_gem_reg_stats/tx_underruns_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/gen_asf_fault_csr_protect.i_asf_fault_log_rpt_csr_duplc/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.asf_int_raw_status_r5_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_asf_fault_log_rpt/i_asf_fault_log_rpt_csr/gen_protocol_check_added.gen_asf_protocol_fault_status\[*\].gen_asf_protocol_fault_status_exists.asf_protocol_fault_status_rn_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/gen_int_q0\[*\].gen_int.i_int/int_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_underflow_frame_reg]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_reg_top/i_gem_registers/i_reg_int_sts/tx_underrun_status_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tx_clk->pclk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.tsu_timer_prty_sampled_on_sof_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.rx_w_timestamp_prty_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.tsu_timer_sampled_on_sof_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.rx_w_timestamp_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.tsu_timer_prty_sampled_on_sof_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.rx_w_timestamp_prty_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.tsu_timer_sampled_on_sof_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/gen_tsu.rx_w_timestamp_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/new_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_cnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_rx/new_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/new_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_cnt_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_rx/new_pause_time_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/tx_pause_time_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.gen_tsu_par.tsu_timer_par_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.gen_tsu_par.tx_r_timestamp_par_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] filter_paths [list $fp]

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.gen_tsu_par.tsu_timer_par_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_txd_par.txd_par_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/crc_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tx_r_timestamp_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_txd_par.txd_par_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/gen_has_802p3_br.i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/txd_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.gen_tsu_par.tsu_timer_par_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.gen_tsu_par.tx_r_timestamp_par_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.gen_tsu_par.tsu_timer_par_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_txd_par.txd_par_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/crc_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tx_r_timestamp_r_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_txd_par.txd_par_r_reg]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp

#
set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/gen_tsu.tsu_timer_sampled_on_sof_r_reg\[*\]]
set from [list $fp]

set fp [find -instance i_gem_ss/i_gem_top/i_gem_mac/i_gem_tx_wrap/i_gem_tx/txd_reg\[*\]]
set to [list $fp]

set fp [list from $from to $to]
set_attribute [find -ruleinst cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk] -add_one filter_paths $fp
