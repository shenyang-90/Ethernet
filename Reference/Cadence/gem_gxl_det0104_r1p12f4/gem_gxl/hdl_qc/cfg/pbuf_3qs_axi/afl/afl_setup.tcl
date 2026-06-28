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
#    Primary Unit Name :      afl_setup.tcl
#
#          Description :      TCL script to execute Jasper AFL
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

if {![file exists ${_AFL_PATH}]} {
   file mkdir ${_AFL_PATH}
   puts "Creating directory ${_AFL_PATH}"
}

# Set any extra options here
#set HAL_EXTRA_OPTIONS "-check DFT_FUNCTIONALMODE:DFT_TESTMODE"
set HAL_EXTRA_OPTIONS "-check ALL_RTL_IPG"

# Ensure FSM verification is enabled
  set_extract_high_level_fsm false

# Introduces fairness constraint when inputs contributing to FSM check noise
# is reduced by allowing input to be set to 0 and 1 instead of being tied to
# a particular value for analysis
  set_afl_add_automatic_task_assumption true



## Configure checks to run
# Setup for advanced checks but user will select rules interactively
if {$env(AFL_SETUP_ADV)} {
  # Setup for advanced Lint
  check_afl -configure \
                     -disable all \
                     -disable hal_checks \
                     -hal_extra_options $HAL_EXTRA_OPTIONS 
		     
# Verbose mode with all adv checks enabled.
# Disable coverage based checks
} elseif {$env(AFL_RUN_ADV) && $env(AFL_RUN)} {
  # Advanced Lint
  check_afl -configure \
                       -enable all \
                       -disable AUTO_FORMAL_SIGNALS -category \
                       -hal_extra_options $HAL_EXTRA_OPTIONS
                     
} elseif {$env(AFL_RUN_ADV) && !($env(AFL_RUN))} {
  # Basic Lint
  check_afl -configure \
                       -enable all \
                       -disable AUTO_FORMAL_SIGNALS -category \
                       -disable hal_checks \
                       -hal_extra_options $HAL_EXTRA_OPTIONS


} elseif {!($env(AFL_RUN_ADV)) && $env(AFL_RUN)} {
  # Basic Lint
  check_afl -configure \
                     -disable all \
                     -enable hal_checks \
                     -hal_extra_options $HAL_EXTRA_OPTIONS 
}

elaborate -restore

## Setup global clocks and resets for AFL (advanced checks)
if {$env(AFL_RUN_ADV) || $env(AFL_SETUP_ADV)} {

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
  check_afl -extract

## Import existing waivers
  if [file exists ${_AFL_INPUT_PATH}/jlint_waivers.txt] {
    echo "Using existing waivers file: ${_AFL_INPUT_PATH}/jlint_waivers.txt.";
    check_afl -waiver -import -file_name ${_AFL_INPUT_PATH}/jlint_waivers.txt 
  }

## Execution advanced lint checks
if {$env(AFL_RUN_ADV) && !($env(AFL_SETUP_ADV))} {
  # export properties
  check_afl -export -silent -type assert -type assume -type cover -class unclassified

  # prove exported properties
#  autoprove -mode afl -time_limit 2h -suppress_traces -verbosity 1 -task {<AFL_arithmetic_overflow> <AFL_dead_code> <AFL_x_assignment> <AFL_default_case> <AFL_fsm> <AFL_signals>}
  autoprove -mode afl -time_limit 2h -suppress_traces -verbosity 1 -all
}


# tcl procs to write waivers, reports, etc
set INPUT_PATH  "${_AFL_INPUT_PATH}"

  ## Export waivers
  proc write_waivers {} {
    global INPUT_PATH
    check_afl -waiver -export -file_name $INPUT_PATH/jlint_waivers.txt
  }

set RPT_PATH  "${_AFL_PATH}"
  ## Save Text, XML and HTML violations report and waiver report
  proc write_reports {} {
    global RPT_PATH
    export -afl -to_html $RPT_PATH/jlint_violations.htm -silent -class unclassified -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type advance_lint -order category
    export -afl -to_text $RPT_PATH/jlint_violations.txt -silent -class unclassified -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type advance_lint -order category
    export -afl -to_xml  $RPT_PATH/jlint_violations.xml -silent -class unclassified -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type advance_lint -order category

   ## Write Waiver report
    export -afl -to_text $RPT_PATH/jlint_waiver_rpt.txt -silent -class waived -violation_report -severity error -severity warning -severity note -linting_type lint -linting_type advance_lint -order category

  }

# Jasper proc to define clocks
# Use the following command: set_clocks [clock_a clock_b clock_c] 
proc set_clocks { args } {
   clock -clear
   set ClkMain [lindex $args 0]
   puts "\"$ClkMain\""
   clock $ClkMain
   set ClkList [lrange $args 1 end]
    foreach ClkInList $ClkList {
      puts "\"$ClkInList\""
      set catchStat [catch {clock $ClkMain $ClkInList} msg]
      puts "status: $catchStat, msg: \"$msg\""
    }
} 


# Write out reports by default.  Backup existing reports 
  if [file exists $RPT_PATH/jlint_violations.txt] {
    echo "Moving existing reports to backup:$RPT_PATH/jlint_violations.<htm/txt/xml>.bak";
    cp $RPT_PATH/jlint_violations.htm $RPT_PATH/jlint_violations.htm.bak
    cp $RPT_PATH/jlint_violations.txt $RPT_PATH/jlint_violations.txt.bak
    cp $RPT_PATH/jlint_violations.xml $RPT_PATH/jlint_violations.xml.bak
  }
  
# Write out current reports
  write_reports



#exit
