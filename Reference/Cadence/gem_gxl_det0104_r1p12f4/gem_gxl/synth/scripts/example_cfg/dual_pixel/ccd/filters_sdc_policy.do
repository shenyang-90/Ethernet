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
//    Primary Unit Name :      filters_sdc_policy.do
//
//          Description :      Place SDC Filters in here. 
//
//      Original Author :      Mark Lewis
//
//------------------------------------------------------------------------------
vpxmode
// Output delay vs clock that is not virtual
 add rule filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL7/1    -message  "In line *, file */cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_output_delay): Object: *clk*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL7 

// Input delay vs clock that is not virtual
 add rule filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7/1a  -description  "Virtual clocks are only used for async IO as per IPG methodology."  -message  "In line *, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_input_delay): Object: *clk*"   -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7 

// Clock Naming in SDC
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_NAM1/1  -message  "In line 18, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (create_clock): The name pclk is also a port/pin name" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_NAM1 
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_NAM1/2  -message  "In line 21, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (create_clock): The name tx_byte_clk is also a port/pin name" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_NAM1 
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_NAM1/3  -message  "In line 30, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (create_clock): The name esc_clk is also a port/pin name" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_NAM1 

// Set Dont touch on Clock network
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b/1  -message  "Port 'esc_reset_n' does not have set_dont_touch_network" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b 
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b/2  -message  "Port 'pixel_reset_n_if0' does not have set_dont_touch_network" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b 
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b/3  -message  "Port 'pixel_reset_n_if1' does not have set_dont_touch_network" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b 
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b/4  -message  "Port 'presetn' does not have set_dont_touch_network" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b 
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b/5  -message  "Port 'tx_byte_reset_n' does not have set_dont_touch_network" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1b 

// Ideal Clock network
 add rule filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN10/1  -message  "In line 304, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_ideal_network)" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN10 

//Unbuffered net connection to output port (post-layout)
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/1a  -message  "Port 'dphy_test_*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/1b  -message  "Port 'tx_data_hs_tx*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/1c  -message  "Port 'tx_request*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/1d  -message  "Port 'tx_ulps*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/2a  -message  "Port 'enable_*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/2b  -message  "Port 'test_generic_ctrl*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/2c  -message  "Port 'tif_*' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/3a  -message  "Port 'fifo_pop_ad_if0[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/3b  -message  "Port 'fifo_push_ad_if0[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/3c  -message  "Port 'fifo_pop_da_if0[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/3d  -message  "Port 'fifo_push_da_if0[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/4a  -message  "Port 'fifo_pop_ad_if1[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/4b  -message  "Port 'fifo_push_ad_if1[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/4c  -message  "Port 'fifo_pop_da_if0[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/4d  -message  "Port 'fifo_push_da_if0[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6
add rule filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6/5  -message  "Port 'prdata[*]' is driven by a net which has other fanouts" -exact  -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT6

// Inputs are treated as asynchronous but constrained against a virtual clock
add rule filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL6/1 -description  "Inputs are treated as asynchronous but constrained against a virtual clock" -message  "In the combinational fanout of input port '*' there is no timing endpoint in any clock group containing clock 'virtual_clk', but an input delay is set in line *, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_input_delay)"  -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL6 -replace
add rule filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL13/1 -description  "Inputs are treated as asynchronous but constrained against a virtual clock" -message  "In the combinational fanout of input port '*' there is a sequential element in the clock tree of clock 'pclk' (clock group ccd_clk_group_2) but this port has no input delay vs. any clock in that clock group"  -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL13 -replace

add rule filter sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT12/1  -description  "Latency not required for virutal clocks at block level"  -message  "In line 21, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (create_clock): Object: virtual_clk"  -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT12 
add rule filter sdc_def_checks/sdc_clock_checks/CCD_CLK_CTR2/1  -description  "Clock transition not required on block level SDC"  -message  "In line 319, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_clock_transition): set_clock_transition used on virtual clock 'virtual_clk'."  -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_CTR2 
