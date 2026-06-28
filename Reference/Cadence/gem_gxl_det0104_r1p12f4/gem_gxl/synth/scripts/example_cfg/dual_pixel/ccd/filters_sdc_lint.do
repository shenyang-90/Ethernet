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
//    Primary Unit Name :      filters_sdc.do
//
//          Description :      Example script to define filters. 
//
//      Original Author :      Mark Lewis
//
//------------------------------------------------------------------------------

// Add individual filters
//add rule filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7/1  -message  "In line 66, file /synth/sdc/t1xhi_sdi_top.sdc (set_input_delay): Object: sdi_bank_clk"  -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7

// Clock not propagated (missing set_propagated_clock on a created clock)
// clocks are ideal for synthesis. Could maybe add this after ccopt if it was real silicon. clocks are propagated automatically by tool if it detects a clock tree
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF10  -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF10


// Undefined clock latency for real clocks
// latency is 0 as its ideal. could set to 0.1 to get around this but not necessary
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT1  -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT1

// Undefined clock transition on real clock
// waived, set later in sdf file as a seperate line 
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_CTR6  -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_CTR6

// set_clock_transition is set on a clock in post-layout
// This is good for synthesis (good practice for ideal mode) but is not required for post layout as after the clock tree is inserted the transition will be caluclated by the tool
// ignored at post clock tree (will use real values instead). Waived
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_CTR8  -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_CTR8

//  Undefined input transition
//Only the clocks dont have it.  waive the clocks
//add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR1/1  -message "*aclk*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR1
//add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR1/2  -message "*pclk*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR1

// set_load and set_driving_cell/set_drive not used together
// Waived. set_load done seperately
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR10  -message "*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR10

// Undefined maximum dynamic power constraint
// waiving power checks. Not trying to constrain for power
add_rule_filter sdc_def_checks/sdc_design_checks/CCD_MISC_POW1 -message "*" -rule sdc_def_checks/sdc_design_checks/CCD_MISC_POW1
add_rule_filter sdc_def_checks/sdc_design_checks/CCD_MISC_POW2 -message "*" -rule sdc_def_checks/sdc_design_checks/CCD_MISC_POW2

// Clock is not set as dont_touch_network (pre-layout)
// Tool automatically sets dont touch on clock network
add_rule_filter sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1 -message "*" -rule  sdc_def_checks/sdc_design_checks/CCD_MISC_HFN1


add_rule_filter sdc_def_checks/sdc_exception_checks/CCD_EXC_FLP3/1  -description  "From/to not required."  -message  "In line *, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_*.func.sdc (set_false_path)"  -rule  sdc_def_checks/sdc_exception_checks/CCD_EXC_FLP3 

add_rule_filter SDC_LINT_REF7/1 -description  "virtual clk is grouped with all clocks" -message  "In line 319, file */sdc/csi2tx_toplevel_*.func.sdc (set_clock_transition): Using object 'virtual_clk' is not recommended"  -rule  SDC_LINT_REF7

add_rule_filter SDC_LINT_CMD6/1 -description  "Port variable is reused. " -message  "In line 233, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_input_delay): overwrites constraints set in line 213, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_input_delay)." -exact  -rule  SDC_LINT_CMD6 
add_rule_filter SDC_LINT_CMD6/2 -description  "Port variable is reused. " -message  "In line 236, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_output_delay): overwrites constraints set in line 216, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_output_delay)." -exact  -rule  SDC_LINT_CMD6
add_rule_filter SDC_LINT_CMD6/3 -description  "Port variable is reused. " -message  "In line 237, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_output_delay): overwrites constraints set in line 217, file */mipi_csi2tx_isp/cfg/*/constraints/csi2tx_toplevel_dual_pixel.func.sdc (set_output_delay)." -exact  -rule  SDC_LINT_CMD6

add_rule_filter SDC_LINT_CMD4/1 -description  "Command is supported by most tools "  -message  "In line 325, file */sdc/csi2tx_toplevel_*.func.sdc (remove_from_collection)"  -rule  SDC_LINT_CMD4
