tclmode
#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2002-2015
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      clp_pre_synth.do
#
#          Description :      CLP pre synth check
#
#      Original Author :      Patrick McKeever
#
#------------------------------------------------------------------------------

# Read project.tcl from current directory if it exists, otherwise look for it in $DUT_PATH
  if [file exists "./project.tcl"] {
     puts "Sourcing ./project.tcl ..."
     source ./project.tcl
  } else {
     puts "ERROR: Can't find project.tcl in current working directory."
     exit
  }

  // Create reports directories 
    if [file isdirectory $_CLP_RPT_PATH] {
      echo "Directory $_CLP_RPT_PATH already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CLP_RPT_PATH
    }

set_log_file $_CLP_RPT_PATH/clp_presynth.log -replace

vpxmode
set dofile abort off
set undefined cell Black_box
set lowpower option -netlist_style logical

tclmode
if { [ regexp {\.upf?$} ${POWER_INTENT_FILE} ] } {
set_lowpower_option -native_1801  
}


 
# Add RTL search Path
  if [info exists HDL_SEARCH_PATH] {   
    foreach paths $HDL_SEARCH_PATH {
      add_search_path -design $paths 
    }     
  }  

tclmode
read_library -liberty -statetable -lp -all -file ./liblist.f 

//analyze library -lowpower


//*********************************************************************************
// Read Design
//*********************************************************************************
tclmode

eval read_design  -define RTL_BEHV -define NO_SVA -define -verilog2k -noelab -file $RTL_F_FILE

elaborate_design -root ${DESIGN}

if { [ regexp {\.cpf?$} ${POWER_INTENT_FILE} ] } {
read_power_intent -cpf pre_synthesis  ${POWER_INTENT_FILE}  
} else {
set_lowpower_option -analysis_style pre_synthesis
read_power_intent -1801   ${POWER_INTENT_FILE}  
}

vpxmode
//write power intent -library power_intent.rpt
analyze library -lowpower
tclmode
report_rule_check -LP -verbose > $_CLP_RPT_PATH/clp_presynth.rpt
exit 
