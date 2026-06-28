#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2002-2014
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      slint_setup.tcl
#
#          Description :      TCL script to execute Jasper Superlint
#                             Modify to add clocks/resets, adjust checks, etc
#
#      Original Author :      Mark Lewis 
#
#------------------------------------------------------------------------------

# Clear the DB
analyze -clear

# Get applicable path variables from RDF setup files
source ./project.tcl
puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
puts "  RDF SVN Revision Info: $RDF_SVN_INFO"

if {![file exists ${_SUPERLINT_PATH}]} {
   file mkdir ${_SUPERLINT_PATH}
   puts "Creating directory ${_SUPERLINT_PATH}"
}

# Set any extra options here
#set HAL_EXTRA_OPTIONS "-advance_dft"
set HAL_EXTRA_OPTIONS ""


# Ensure FSM verification is enabled
  set_extract_high_level_fsm false

## Grab the install path of Incisive
set INCSIVE_INSTALL [exec irun -location]
regexp {(/.*)} $INCSIVE_INSTALL INCSIVE_INSTALL_PATH


## Configure checks to run

# Verbose mode with all adv checks enabled.
# Disable coverage based checks
if {$env(SLINT_RUN_ADV) && $env(SLINT_RUN)} {
  # Advanced Lint
  check_sps_configure -enable all \
                      -disable stuckat_signals \
                      -disable toggle_rise_signals \
                      -disable toggle_fall_signals \
                      -disable toggle_stable_signals \
                      -hal_extra_options $HAL_EXTRA_OPTIONS \
                      -hal_incisiv_path ${INCSIVE_INSTALL_PATH} \
                     
} elseif {$env(SLINT_RUN_ADV) && !($env(SLINT_RUN))} {
  # Basic Lint
  check_sps_configure \
                     -enable all \
                     -disable hal_checks \
                     -hal_extra_options $HAL_EXTRA_OPTIONS \
                     -hal_incisiv_path ${INCSIVE_INSTALL_PATH}


} elseif {!($env(SLINT_RUN_ADV)) && $env(SLINT_RUN)} {
  # Basic Lint
  check_sps_configure \
                     -disable all \
                     -enable hal_checks \
                     -hal_incisiv_path ${INCSIVE_INSTALL_PATH}
}

elaborate -restore

## Setup global clocks and resets for AFL (advanced checks)
if {$env(SLINT_RUN_ADV) == 1} {

  ## Setup global clocks and resets
    #<clock clk1>
    #<clock clk2 >

  # E.g. 
  #clock sink_pclk -both_edges
  #clock sink_core_clk -both_edges
  #clock sink_sclk -both_edges

  ## Define resets and active ("~" == active low)
  ## (NOTE: Only one reset command is allowed so put in all resets here 
    #<reset rst1 rst2>

  # E.g.
  #reset ~sink_i2s_clk_rstn ~sink_spdif_mclk_rstn ~sink_ref_clk_rstn \
  #      ~sink_phy_data_clk_rstn 

}



## Execute the basic Lint (HAL) checks
  check_sps -extract

## Import existing waivers
  if [file exists ${_SUPERLINT_INPUT_PATH}/jlint_waivers.txt] {
    echo "Using existing waivers file: ${_SUPERLINT_INPUT_PATH}/jlint_waivers.txt.";
    check_sps_waiver -import -file_name ${_SUPERLINT_INPUT_PATH}/jlint_waivers.txt 
  }

## Execution advanced lint checks
if {$env(SLINT_RUN_ADV) == 1} {
  # export properties
  check_sps -export -silent -type assert -type assume -type cover -class unclassified

  # prove exported properties
#  autoprove -mode sps -time_limit 2h -suppress_traces -verbosity 1 -task {<SPS_arithmetic_overflow> <SPS_dead_code> <SPS_x_assignment> <SPS_default_case> <SPS_fsm> <SPS_signals>}
  autoprove -mode sps -time_limit 2h -suppress_traces -verbosity 1 -all
}


# tcl procs to write waivers, reports, etc
set INPUT_PATH  "${_SUPERLINT_INPUT_PATH}"

  ## Export waivers
  proc write_waivers {} {
    global INPUT_PATH
    check_sps_waiver -export -file_name $INPUT_PATH/jlint_waivers.txt
  }

set RPT_PATH  "${_SUPERLINT_PATH}"
  ## Save Text, XML and HTML violations report and waiver report
  proc write_reports {} {
    global RPT_PATH
    export -sps -to_html $RPT_PATH/jlint_violations.htm -silent -class unclassified -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type superlint -order category
    export -sps -to_text $RPT_PATH/jlint_violations.txt -silent -class unclassified -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type superlint -order category
    export -sps -to_xml  $RPT_PATH/jlint_violations.xml -silent -class unclassified -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type superlint -order category

   ## Write Waiver report
    export -sps -to_text $RPT_PATH/jlint_waiver_rpt.txt -silent -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type superlint -order category

  }

#exit
