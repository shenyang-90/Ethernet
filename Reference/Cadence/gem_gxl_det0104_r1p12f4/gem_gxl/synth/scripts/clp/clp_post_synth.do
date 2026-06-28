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
#    Primary Unit Name :      clp_post_synth.do
#
#          Description :      CLP post synth check
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

set_log_file $_CLP_RPT_PATH/clp_postsynth.log -replace

vpxmode
set dofile abort off
set undefined cell Black_box
set lowpower option -netlist_style logical
set lowpower option -analysis_style post_synthesis

tclmode
if { [ regexp {\.upf?$} ${POWER_INTENT_FILE} ] } {
set_lowpower_option -native_1801  
}


read_library -liberty -statetable -lp -all -file ./liblist.f 

//analyze library -lowpower


read_design  -noelab ${_OUTPUTS_PATH}/${DESIGN}.v.gz  


elaborate_design -root ${DESIGN}

if { [ regexp {\.cpf?$} ${POWER_INTENT_FILE} ] } {
read_power_intent -cpf post_synthesis  ${POWER_INTENT_FILE}  
} else {
set_lowpower_option -analysis_style post_synthesis
read_power_intent -1801   ${POWER_INTENT_FILE}  
}

vpxmode
//write power intent -library power_intent.rpt
analyze library -lowpower
commit power intent
analyze power domain 
tclmode
report_rule_check -LP -verbose > $_CLP_RPT_PATH/clp_postsynth.rpt
exit 
