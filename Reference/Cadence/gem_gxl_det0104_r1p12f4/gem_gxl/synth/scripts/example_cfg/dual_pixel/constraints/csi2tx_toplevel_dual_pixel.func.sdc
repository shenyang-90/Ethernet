#####################################################
set sdc_version 1.7


#######################################
# Clock definitions
#######################################

set pclk_period               2.000;  # 500MHz
set tx_byte_clk_hs_period     2.000;  # 500MHz
set pixel_clk_period          2.000;  # 500MHz
set esc_clk_period           50.000;  # 20MHz

#######################################
# Clocks
#######################################

create_clock -name pclk -p $pclk_period [ get_ports pclk ] \
             -waveform [ list 0 [ expr $pclk_period / 2 ] ]

create_clock -name virtual_clk -period $pclk_period -waveform [ list 0 [ expr $pclk_period / 2 ] ]

create_clock -name tx_byte_clk -p $tx_byte_clk_hs_period [ get_ports tx_byte_clk  ] \
             -waveform [ list 0 [ expr $tx_byte_clk_hs_period / 2 ] ]

create_clock -name pixel_clk0 -p $pixel_clk_period [ get_ports pixel_clk_if0 ] \
             -waveform [ list 0 [ expr $pixel_clk_period / 2 ] ]

create_clock -name pixel_clk1 -p $pixel_clk_period [ get_ports pixel_clk_if1 ] \
             -waveform [ list 0 [ expr $pixel_clk_period / 2 ] ]

create_clock -name esc_clk -p $esc_clk_period [ get_ports esc_clk ] \
             -waveform [ list 0 [ expr $esc_clk_period / 2 ] ]


#######################################
# Groups
#######################################

set reset_port_list { presetn tx_byte_reset_n pixel_reset_n_if0 pixel_reset_n_if1 esc_reset_n }
set clock_port_list { pclk tx_byte_clk pixel_clk_if0 pixel_clk_if1 esc_clk  }

set_clock_groups -asynchronous -name related_grp \
                                   -group {virtual_clk } \
                                   -group {pclk } \
                                   -group {tx_byte_clk} \
                                   -group {pixel_clk0} \
                                   -group {pixel_clk1} \
                                   -group {esc_clk}

############################################################
# Input & Output delays
############################################################
set output_delay_min -0.1

#####################################
## PCLK
#####################################
set pclk_input_delay  [ expr $pclk_period * 0.65 ]
set pclk_output_delay [ expr $pclk_period * 0.65 ]

set pclk_input_ports  [ list \
                        paddr \
                        pwrite \
                        pwdata \
                        penable \
                        psel \
                        tif_rda_cmn \
                        tif_rda_ctx \
                        tif_rda_tx* \
                      ]

set pclk_output_ports [ list \
                        prdata \
                        pready \
                        pslverr \
                        interrupt \
                        enable_ctx \
                        enable_tx0 \
                        enable_tx1 \
                        enable_tx2 \
                        enable_tx3 \
                        rstb_ctx \
                        rstb_tx0 \
                        rstb_tx1 \
                        rstb_tx2 \
                        rstb_tx3 \
                        pso_cmn \
                        pdn_cmn \
                        pdn_ctx \
                        pdn_tx0 \
                        pdn_tx1 \
                        pdn_tx2 \
                        pdn_tx3 \
                        force_stop_mode_tx0 \
                        force_stop_mode_tx1 \
                        force_stop_mode_tx2 \
                        force_stop_mode_tx3 \
                        swap_dp_dn_tx0 \
                        swap_dp_dn_tx1 \
                        swap_dp_dn_tx2 \
                        swap_dp_dn_tx3 \
                        swap_dp_dn_ctx \
                        tif_clk \
                        tif_reset_n \
                        tif_select_cmn \
                        tif_select_ctx \
                        tif_select_tx0 \
                        tif_select_tx1 \
                        tif_select_tx2 \
                        tif_select_tx3 \
                        tif_addr \
                        tif_w_rb \
                        tif_wda \
                        tif_forcewrite \
                        test_generic_ctrl \
                        dphy_test_bist_ctx_enable \
                        dphy_test_bist_tx*_enable \
                        dphy_test_pso_bypass_ctx_enable \
                        dphy_test_pso_bypass_tx*_enable \
                      ]

foreach Port $pclk_input_ports {
  set_input_delay  $pclk_input_delay -add -clock "pclk"  [ get_ports $Port ] }

foreach Port $pclk_output_ports {
  set_output_delay -max  $pclk_output_delay -add -clock "pclk" [ get_ports $Port ]
  set_output_delay -min  $output_delay_min  -add -clock "pclk" [ get_ports $Port ] }

#####################################
## PIXEL_CLK0
#####################################
set pixel_clk0_input_delay  [ expr $pixel_clk_period * 0.65 ]
set pixel_clk0_output_delay [ expr $pixel_clk_period * 0.65 ]

set pixel_clk0_input_ports  [ list \
                              frame_valid_if0 \
                              line_valid_if0 \
                              virtual_channel_if0 \
                              pixel_data_if0 \
                              pixel_da_vld_if0 \
                              pixel_dt_sel_if0 \
                            ]

set pixel_clk0_output_ports [ list \
                              frame_tx_ready_if0 \
                              pixel_ready_if0 \
                              fifo_push_ad_if0 \
                              fifo_push_da_if0 \
                              fifo_wren_if0 \
                            ]

foreach Port $pixel_clk0_input_ports {
  set_input_delay  $pixel_clk0_input_delay -add -clock "pixel_clk0" [ get_ports $Port ]  }

foreach Port $pixel_clk0_output_ports {
  set_output_delay -max  $pixel_clk0_output_delay -add -clock "pixel_clk0" [ get_ports $Port ]
  set_output_delay -min  $output_delay_min        -add -clock "pixel_clk0" [ get_ports $Port ] }


#####################################
## PIXEL_CLK1
#####################################
set pixel_clk1_input_delay  [ expr $pixel_clk_period * 0.65 ]
set pixel_clk1_output_delay [ expr $pixel_clk_period * 0.65 ]

set pixel_clk1_input_ports  [ list \
                              frame_valid_if1 \
                              line_valid_if1 \
                              virtual_channel_if1 \
                              pixel_data_if1 \
                              pixel_da_vld_if1 \
                              pixel_dt_sel_if1 \
                            ]

set pixel_clk1_output_ports [ list \
                              frame_tx_ready_if1 \
                              pixel_ready_if1 \
                              fifo_push_ad_if1 \
                              fifo_push_da_if1 \
                              fifo_wren_if1 \
                            ]

foreach Port $pixel_clk1_input_ports {
  set_input_delay  $pixel_clk1_input_delay -add -clock "pixel_clk1" [ get_ports $Port ]  }

foreach Port $pixel_clk1_output_ports {
  set_output_delay -max  $pixel_clk1_output_delay -add -clock "pixel_clk1" [ get_ports $Port ]
  set_output_delay -min  $output_delay_min        -add -clock "pixel_clk1" [ get_ports $Port ] }


#####################################
## TX_BYTE_CLK
#####################################
set tx_byte_clk_input_delay  [ expr $tx_byte_clk_hs_period * 0.65 ]
set tx_byte_clk_output_delay [ expr $tx_byte_clk_hs_period * 0.65 ]

set tx_byte_clk_input_ports   [ list \
                                tx_ready_hs_tx* \
                                tx_ready_hsclk \
                                stop_state_ctx \
                                fifo_pop_da_if* \
                              ]

set tx_byte_clk_output_ports  [ list \
                                tx_request_hs_tx* \
                                tx_data_hs_tx* \
                                tx_request_hsclk \
                                fifo_pop_ad_if* \
                              ]

foreach Port $tx_byte_clk_input_ports {
  set_input_delay  $tx_byte_clk_input_delay -add -clock "tx_byte_clk"  [ get_ports $Port ] }

foreach Port $tx_byte_clk_output_ports {
  set_output_delay -max  $tx_byte_clk_output_delay -add -clock "tx_byte_clk"  [ get_ports $Port ]
  set_output_delay -min  $output_delay_min         -add -clock "tx_byte_clk"  [ get_ports $Port ] }

# FIFO RAM timing is more agressive to make sure the async path from fifo_pop_ad_if to fifo_pop_da_if is clean
  
set tx_byte_clk_ram_input_delay  [expr $tx_byte_clk_hs_period * 0.80]
set tx_byte_clk_ram_output_delay [expr $tx_byte_clk_hs_period * 0.80]

set tx_byte_clk_ram_input_ports  [ list \
                                   fifo_pop_da_if* \
                                 ]

set tx_byte_clk_ram_output_ports [ list \
                                   fifo_pop_ad_if* \
                                 ]

foreach Port $tx_byte_clk_ram_input_ports {
  set_input_delay  $tx_byte_clk_ram_input_delay -add -clock "tx_byte_clk"  [ get_ports $Port ] }

foreach Port $tx_byte_clk_ram_output_ports {
  set_output_delay -max  $tx_byte_clk_ram_output_delay -add -clock "tx_byte_clk"  [ get_ports $Port ]
  set_output_delay -min  $output_delay_min             -add -clock "tx_byte_clk"  [ get_ports $Port ] }

#####################################
## ESC_CLK
#####################################
set esc_clk_input_delay  [ expr $esc_clk_period * 0.65 ]
set esc_clk_output_delay [ expr $esc_clk_period * 0.65 ]

set esc_clk_input_ports  [ list \
                           stop_state_ctx \
                           stop_state_tx* \
                           tx_ulps_active_clk_n \
                           tx_ulps_active_n_tx* \
                         ]

set esc_clk_output_ports [ list \
                           tx_ulps_clk \
                           tx_ulps_exit_clk \
                           tx_request_esc \
                           tx_ulps_esc \
                           tx_ulps_exit_esc \
                         ]

foreach Port $esc_clk_input_ports {
  set_input_delay  $esc_clk_input_delay -add -clock "esc_clk"  [ get_ports $Port ] }

foreach Port $esc_clk_output_ports {
  set_output_delay -max  $esc_clk_output_delay -add -clock "esc_clk"  [ get_ports $Port ]
  set_output_delay -min  $output_delay_min     -add -clock "esc_clk"  [ get_ports $Port ] }

############################################################
# Asynchronous IO
############################################################

set virtual_input_delay  [ expr $pclk_period * 0.65 ]
set virtual_output_delay [ expr $pclk_period * 0.65 ]

set virtual_input_ports  [ list  \
                           direction_tx* \
                           err_contention_lp0_tx* \
                           err_contention_lp1_tx* \
                           err_control_tx* \
                           err_esc_tx* \
                           err_sync_esc_tx* \
                           test_generic_status \
                           tx_ulps_active_clk_n \
                           tx_ulps_active_n_tx* \
                           stop_state_ctx \
                           stop_state_tx* \
                         ]

foreach Port $virtual_input_ports {
  set_input_delay  $virtual_input_delay -add -clock "virtual_clk"  [ get_ports $Port ] }

#foreach Port $virtual_output_ports {
#  set_output_delay -max  $virtual_output_delay  -clock "virtual_clk"  [ get_ports $Port ]
#  set_output_delay -min  $output_delay_min      -clock "virtual_clk"  [ get_ports $Port ]


###############################################################################
# False Paths to Reset and static data inputs
###############################################################################

set_false_path -from [ get_ports $reset_port_list ]


############################################################
# Ideal networks creation
############################################################

set_ideal_network -no_propagate [ get_ports $reset_port_list ]

###############################################################################
# Clock uncertainty
###############################################################################

set_clock_uncertainty 0.200 -setup [ all_clocks ]
set_clock_uncertainty 0.055 -hold  [ all_clocks ]

###############################################################################
# Transitions
###############################################################################
set_clock_transition 0.03      [ all_clocks ]

###############################################################################
## Input Driving Cell
###############################################################################

set_driving_cell -lib_cell BUFFD4BWP35 -pin Z [ remove_from_collection [ all_inputs ] \
                 [ get_ports $clock_port_list ] ]

###############################################################################
# output loads in pF -- previously 0.05
###############################################################################
set_load             0.15      [ all_outputs ]

###############################################################################
# Inputs loads in pF -- Is this required??
###############################################################################
set_load             0.05      [ all_inputs ]

#########################
## Input Max Capacitance
#########################
set_max_capacitance 0.050      [ all_inputs ]

#########################
## Output Max Capacitance
#########################
set_max_capacitance 0.050      [ all_outputs ]
