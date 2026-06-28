//------------------------------------------------------------------------------
//                                     
//            CADENCE                    Copyright (c) 2001-2013
//                                       Cadence Design Systems, Inc.
//                                       All rights reserved.
//
//  This work may not be copied, modified, re-published, uploaded, executed, or
//  distributed in any way, in any medium, whether in whole or in part, without
//  prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
//
//    Primary Unit Name :      filters.do
//
//          Description :      Example script to define filters. 
//
//      Original Author :      Mark Lewis
//
//------------------------------------------------------------------------------

vpxmode
//#### Structural ####

// The logic in the sync path is the combination of all the sycnhronized resets which results in the soft reset acknowledgement which
// is then synchronized
add rule filter cdc_def_rs/cdc_checks/cdc_pixel_clk0->pclk/5a  -message  "Crossing GEN_STREAMS[*].u_protocol/genblk1.u_soft_rst_pixel_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_ctrl_reg/u_softreset_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_pixel_clk0->pclk
add rule filter cdc_def_rs/cdc_checks/cdc_pixel_clk1->pclk/5  -message  "Crossing GEN_STREAMS[*].u_protocol/genblk1.u_soft_rst_pixel_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_ctrl_reg/u_softreset_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_pixel_clk1->pclk 
add rule filter cdc_def_rs/cdc_checks/cdc_tx_byte_clk->pclk/13  -message  "Crossing u_lane_manager/u_soft_rst_2ff_byte_clk_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_ctrl_reg/u_softreset_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_tx_byte_clk->pclk 

// Frame/line start and Frame/line end signals converge before being re-synchronized so there is logic in the sync path. However, these signals are mutaually exclusive.

add rule filter cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk/1  -message  "Crossing u_ctrl_reg/TXCLK_IRQ_SYNC_GEN[*].u_fend_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_lane_manager/u_fse_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk
add rule filter cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk/2  -message  "Crossing u_ctrl_reg/TXCLK_IRQ_SYNC_GEN[*].u_fstart_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_lane_manager/u_fse_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk 
add rule filter cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk/3  -message  "Crossing u_ctrl_reg/TXCLK_IRQ_SYNC_GEN[*].u_lend_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_lane_manager/u_le_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk
add rule filter cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk/4  -message  "Crossing u_ctrl_reg/TXCLK_IRQ_SYNC_GEN[*].u_lstart_sync/cdn_syncflop_inst/meta_reg[*][*] -> u_lane_manager/u_ls_ack_2ff_sync/cdn_syncflop_inst/meta_reg[*][*]" -exact  -rule  cdc_def_rs/cdc_checks/cdc_pclk->tx_byte_clk 

tclmode
#### Convergence ####

# err_event indicates an error condition, hs_out indicates in HS mode (effectively static), soft_rest used as a consequence of error.
# Re-convergence is expected from these 3 registers and the timing of the reconvergence is not critical.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/hsa_out_r_reg u_ctrl_reg/softreset_request_n_r_reg}]]

# err_event indicates an error condition and a ulps request is unlikely during an error condition.  Error condtion will override request.
# Re-convergence is expected from these 2 registers and the timing of the reconvergence is not critical.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/ulps_req_r_reg}]]

# err_event indicates an error condition, dphy update (effectively static), soft_rest used as a consequence of error.
# DPhy update if effectively static in nature.
# Re-convergence is expected from these 4 registers and the timing of the reconvergence is not critical.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/dphy_cfg_update_r_reg u_ctrl_reg/softreset_request_n_r_reg}]]

# err_event indicates an error condition, dphy update (effectively static), hs_req indicates in HS mode (effectively static), soft_rest used as a consequence of error.
# DPhy update if effectively static in nature.
# Re-convergence is expected from these 4 registers and the timing of the reconvergence is not critical.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/dphy_cfg_update_r_reg u_ctrl_reg/softreset_request_n_r_reg u_ctrl_reg/hs_mode_req_r_reg}]]

# err_event indicates an error condition, dphy update (effectively static), , soft_reset used as a consequence of error.
# line/frame start and line/frame end are mutually exclusive.
# Re-convergence of all of the above signals are ok.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/dphy_cfg_update_r_reg u_ctrl_reg/softreset_request_n_r_reg \
                        u_ctrl_reg/TXCLK_IRQ_SYNC_GEN*.u_lend_sync/cdn_syncflop_inst/meta_reg\[0\]\[0\] u_ctrl_reg/TXCLK_IRQ_SYNC_GEN*.u_lstart_sync/cdn_syncflop_inst/meta_reg\[0\]\[0\]}]]

 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/dphy_cfg_update_r_reg u_ctrl_reg/softreset_request_n_r_reg \
                        u_ctrl_reg/TXCLK_IRQ_SYNC_GEN*.u_fend_sync/cdn_syncflop_inst/meta_reg\[0\]\[0\] u_ctrl_reg/TXCLK_IRQ_SYNC_GEN*.u_fstart_sync/cdn_syncflop_inst/meta_reg\[0\]\[0\]}]]

 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/dphy_cfg_update_r_reg u_ctrl_reg/softreset_request_n_r_reg \
                        u_ctrl_reg/TXCLK_IRQ_SYNC_GEN\[0\].u_lend_sync/cdn_syncflop_inst/meta_reg\[0\]\[1\] u_ctrl_reg/TXCLK_IRQ_SYNC_GEN\[0\].u_lstart_sync/cdn_syncflop_inst/meta_reg\[0\]\[1\]}]]

 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_ctrl_reg/err_event_r_reg u_ctrl_reg/dphy_cfg_update_r_reg u_ctrl_reg/softreset_request_n_r_reg \
                        u_ctrl_reg/TXCLK_IRQ_SYNC_GEN\[0\].u_fend_sync/cdn_syncflop_inst/meta_reg\[0\]\[1\] u_ctrl_reg/TXCLK_IRQ_SYNC_GEN\[0\].u_fstart_sync/cdn_syncflop_inst/meta_reg\[0\]\[1\]}]]

# Re-convergence from gray coded registers is expected.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance GEN_STREAMS\[*\].u_protocol/u_packet_fifo0/push_cnt_gray_r_reg*]]
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance GEN_STREAMS\[*\].u_protocol/u_packet_fifo0/pop_cnt_gray_r_reg*]]

# Re-convergence from each data lane is ok.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -port {stop_state_tx* tx_ulps_active_n_tx*}]]

# Re-convergence to interrupt and error signals is ok.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list to [find -instance {u_ctrl_reg/all_irq_r_reg*}]]
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list to [find -instance {u_ctrl_reg/err_event_r_reg*}]]
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list to [find -instance {u_ctrl_reg/irq_r_reg*}]]

# Re-convergence to APB read bus is ok.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list to [find -instance prdata_reg*]]

# Re-convergence to the soft_reset is ok as this is only asserted following an error.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list to [find -instance u_ctrl_reg/softreset_active_r_reg]]

# frame start and end are mutually exclusive and hs_mode will be set up before these signals are active.
# transmission_active will be enabled with the frame_start 
# Re-convergence is expected from these 3 registers and the timing of the reconvergence is not critical.
 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg* u_lane_manager/all_frame_start_r_reg* u_lane_manager/transmission_active_r_reg}]]

# set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
#                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg\[1\] u_lane_manager/all_frame_start_r_reg\[1\] u_lane_manager/transmission_active_r_reg}]]

# set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
#                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg\[2\] u_lane_manager/all_frame_start_r_reg\[2\] u_lane_manager/transmission_active_r_reg}]]

# set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
#                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg\[3\] u_lane_manager/all_frame_start_r_reg\[3\] u_lane_manager/transmission_active_r_reg}]]

 set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg* u_lane_manager/all_frame_start_r_reg* u_lane_manager/hs_mode_active_r_reg}]]
# set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
#                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg\[1\] u_lane_manager/all_frame_start_r_reg\[1\] u_lane_manager/hs_mode_active_r_reg}]]
# set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
#                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg\[2\] u_lane_manager/all_frame_start_r_reg\[2\] u_lane_manager/hs_mode_active_r_reg}]]
# set_attribute -add_one [find -ruleinst cdc_def_rs/conv_checks/convergence_in_*clk*] filter_paths \
#                        [list from [find -instance {u_lane_manager/all_frame_end_r_reg\[3\] u_lane_manager/all_frame_start_r_reg\[3\] u_lane_manager/hs_mode_active_r_reg}]]

