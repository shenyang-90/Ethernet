# This file contains CDC filters for the Conformal CCD tool.
# Generated for design configuration "pbuf_3qs_axi" on Mon Nov 20 09:34:29 GMT 2017



// -- Statistics/Status xfer from RX and TX to the APB register block 
//
// These paths from TX CLK to PCLK are all safe by design. they are stats and all qualified by tx_end_frame_pulse
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

// -- Extra status signalling xfer from TX MAC to the APB register block 
//
// These CDC paths are safe by design, only sampled when stable
// In the legacy FIFO based DMA, these signals are routed from the MAC, into the AHB DMA (hclk), and then onto pclk 
//
// In the PBUF FIFO based DMA (non SPRAM config), these signals are also routed from the MAC into the DMA, but just on the tx_clk side of it, and then onto the registers
//
// In the PBUF FIFO based DMA (SPRAM config), these signals are routed in the same way as above, but since the DMA is completely hclk timed, it first goes into hclk, and then onto pclk
//
add_rule_filter tx_stats_dma1 -message {Crossing *i_gem_tx/late_coll_occured* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats_dma2 -message {Crossing *i_gem_tx/too_many_retries* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk
add_rule_filter tx_stats_dma3 -message {Crossing *i_gem_tx/underflow_frame* -> *i_gem_top/i_gem_reg_top*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->pclk

// -- DMA 
//
// These paths from DMA clock to PCLK are all safe by design. The qualifier is update_rx_dma_status. 
add_rule_filter rx_dma_complete_ok  -message {Crossing */rx_dma_complete_ok*}   -replace -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_hresp_notok  -message {Crossing */rx_dma_hresp_notok*}   -replace -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_int_queue    -message {Crossing */rx_dma_int_queue*}     -replace -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_dma_resource_err -message {Crossing */rx_dma_resource_err*}  -replace -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
// And this is the equivalent for the TX status. 
add_rule_filter tx_dma_status2apb -message {Crossing */tx_status2apb*} -replace -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
// txrx fill level debug FIFO 
// safe by design. Only samples when not empty and can only be written to when not full 
add_rule_filter rx_dma_fill_level_debug_fifo -message {Crossing */mem_reg*} -replace -rule  cdc_def_rs/cdc_checks/cdc_rx_clk->pclk 
add_rule_filter tx_dma_fill_level_debug_fifo -message {Crossing */mem_reg*} -replace -rule  cdc_def_rs/cdc_checks/cdc_tx_clk->pclk 
// This could be recoded in the RTL to remove this. However, the descriptor pointers are only read in debug, and at a time when the
// pointers themselves are not changing. This means there wont be a real CDC issue and is waived
add_rule_filter tx_queue_descr_ptr_to_pclk   -message {Crossing */i_edma_pbuf_axi_fe/i_edma_pbuf_axi_fe_tx/db2_descr_ptr*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
add_rule_filter rx_queue_descr_ptr_to_pclk   -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_rd/nxt_descr_ptr*} -rule cdc_def_rs/cdc_checks/cdc_aclk->pclk
// host_if_soft_select .. 
// When gem_host_if_soft_select is defined, a lot of signals are from the DMA-REG interface are multiplexed with the equivalents from the external FIFO interface
// Some of these signals are synchronized into pclk for updating status and stats.
// The mux select is a static signal (soft_config_fifo_en) from the registers block.  The presence of the MUX causes CDC violations as there is
// a gate between the two domains. It is waived as the extra delay through the mux will not cause any real issues (the sampling point of the signal
// is delayed from the point the source changes, and there is a full handshake protocol in place.
add_rule_filter dma_fifo_static_select_regtorx -message {Crossing */i_gem_reg_top/i_gem_pclk_syncs/rx_status_wr_tog*} -rule cdc_def_rs/cdc_checks/cdc_pclk->rx_clk
// tx_start comes from the registers and is sent to multiple destinations, where is is synchronized separately. 
// These destinations are independent and it is safe to do this. 
add_rule_filter tx_start_multiple -message {Crossing */i_gem_registers/i_network_control_reg/tx_start_pclk*} -rule cdc_def_rs/cdc_checks/cdc_pclk->aclk
// The fill level for the RX SRAM is physically located in rx_clk domain. When the DMA reads from the SRAM (in hclk/aclk domain), updates are 
// passed to the rx_clk domain via pkt_done_dplocns. A full handshake CDC protocol is used, and the bus is sampled safely. No CDC issue. Waived 
add_rule_filter rx_sram_fill_lvl_hs -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_rd/pkt_done_dplocns*} -rule cdc_def_rs/cdc_checks/cdc_aclk->rx_clk
// To free up part of the packet (Fixed at partpkt_threshold), we can just send the toggle directly
// without any accompanying information (other than the queue), since the AHB/AXI side can assume
// the number of locations is partpkt_threshold.
// Note that we assume the AXI/AHB clock frequency is at least 1/4 of the tx_clk frequency for this
// to sample correctly.
add_rule_filter tx_sram_fill_lvl_hs1 -message {Crossing */i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/part_pkt_queue*} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->aclk
// The following is used for status writes passed from tx_clk to aclk/hclk.  These are safe and sampled using a safe
// sample point (xfer_status_captured)
add_rule_filter wb_status_to_tx_wr -message {Crossing */i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_rd/i_wb_status_to_tx_wr_fifo/cmd_fifo_reg* -> *} -rule cdc_def_rs/cdc_checks/cdc_tx_clk->aclk
// The mechanism used to pass details of the number of packets and part-packets from the rx_clk domain to the hclk/aclk domain is through
// num_pkts_xfer and other sideband signals. A full handshake CDC protocol is used, and the bus is sampled safely. No CDC issue. Waived
add_rule_filter rx_num_pkts_xfer1 -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_wr/num_pkts_xfer*} -replace -rule cdc_def_rs/cdc_checks/cdc_rx_clk->aclk
add_rule_filter rx_num_pkts_xfer2 -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_fld_offsets*} -replace -rule cdc_def_rs/cdc_checks/cdc_rx_clk->aclk
add_rule_filter rx_num_pkts_xfer3 -message {Crossing */i_edma_pbuf_rx/i_edma_pbuf_rx_wr/part_of_packet_queue_ptr*} -replace -rule cdc_def_rs/cdc_checks/cdc_rx_clk->aclk
// Same as above, but for TX. This time it is from hclk/aclk to tx_clk
add_rule_filter tx_num_pkts_xfer1 -message {Crossing */i_edma_pbuf_axi_tx/i_edma_pbuf_axi_tx_wr/num_pkts_xfer*} -replace -rule cdc_def_rs/cdc_checks/cdc_aclk->tx_clk

// -- Internal Loopback 
//
// In near end loopback mode (TX to RX), TX clk and RX clk will be synchonous so the paths are irrelevant for CDC
add_rule_filter loopback_path1 -message {Crossing */rx_dv_looped_reg*} -rule cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk
add_rule_filter loopback_path2 -message {Crossing */rx_er_looped_reg*} -rule cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk
add_rule_filter loopback_path3 -message {Crossing */rxd_looped*}       -rule cdc_def_rs/cdc_checks/cdc_n_tx_clk->rx_clk

// -- 802.3 Pause
//
// The pause time sampled from the RX frame is passed to the TX and loaded into tx_clk so that transmission can halt.
//Qualified safely by load_new_pause_time
add_rule_filter capt_pause_rx_to_tx -message {Crossing */new_pause_time* -> */i_gem_tx/*} -rule cdc_def_rs/cdc_checks/cdc_rx_clk->tx_clk

// -- TSU Static CDC waivers 
//
// tsu timer sampled in tx/rx clock domains for timestamping.
//These are safe by design. tsu_timer_sampled_on_sof is designed to stay stable before and after the sample point
add_rule_filter tsu_timer_sync1 -message {Crossing *i_gem_tx/*tsu_timer_sampled_on_sof* -> *i_gem_tx*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk
add_rule_filter tsu_timer_sync2 -message {Crossing *i_gem_tx/*tsu_timer_par_sampled_on_sof_r* -> *i_gem_tx*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->tx_clk
add_rule_filter tsu_timer_sync3 -message {Crossing *i_gem_rx/gen_tsu.tsu_timer_sampled_on_sof* -> *i_gem_rx/gen_tsu.rx_w_timestamp*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk
add_rule_filter tsu_timer_sync4 -message {Crossing *i_gem_rx/gen_tsu.tsu_timer_prty_sampled_on_sof* -> *i_gem_rx/gen_tsu.rx_w_timestamp*} -rule cdc_def_rs/cdc_checks/cdc_tsu_clk->rx_clk
// timer adjust programmable registers (not static) are sent from pclk domain to tsu clk domain.
// These are safe as they are sampled after the register has stabilized (using tsu_timer_adj_wr)
add_rule_filter tsu_timer_adj1 -message {Crossing *i_gem_reg_top/i_gem_registers/tsu_timer_adj_reg* -> *i_gem_top/i_gem_tsu/int_timer_nsec_calc_val_reg*} -rule cdc_def_rs/cdc_checks/cdc_pclk->tsu_clk
add_rule_filter tsu_timer_adj2 -message {Crossing *i_gem_reg_top/i_gem_registers/tsu_timer_adj_reg* -> *i_gem_top/i_gem_tsu/int_timer_sec_calc_val_reg*} -rule cdc_def_rs/cdc_checks/cdc_pclk->tsu_clk
add_rule_filter tsu_timer_adj3 -message {Crossing *i_gem_reg_top/i_gem_registers/tsu_timer_adj_reg* -> *i_gem_top/i_gem_tsu/tsu_sec_incr_reg} -rule cdc_def_rs/cdc_checks/cdc_pclk->tsu_clk

// -- 802.1CB Static CDC waivers 
//
// Synchronizing multiple toggle signals for each stream. Each stream is completely independent, and the signal in dest clk is gated by a toggle syncced to it.
add_rule_filter cb_1 -message {Crossing *i_gem_mac/i_gem_rx/gen_cb.i_frer_elim*/frer_err_upd_val*}   -rule cdc_def_rs/cdc_checks/cdc_rx_clk->pclk

// -- Miscellaneous 
//
// The following are all actually static sources, but the statics file wasnt understood properly by CCD. Waived.
add_rule_filter hdfc -message {Crossing *halfduplex_flow_control_en*}   -rule cdc_def_rs/cdc_checks/cdc_pclk->tx_clk
