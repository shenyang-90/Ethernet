tclmode
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
#    Primary Unit Name :      create_tech_cpf.do
#
#          Description :      CLP tech cpf creation
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

#  // Create reports directories 
    if [file isdirectory $_CLP_RPT_PATH] {
      echo "Directory $_CLP_RPT_PATH already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CLP_RPT_PATH
    }



set_log_file $_CLP_RPT_PATH/clp_create_tech.log -replace
set_dofile_abort off
set_undefined_cell Black_box
set_lowpower_option -netlist_style logical
set_rule_handling RETRULE1.4 ISORULE1.4 LSH3 ISO7 -ignore

set_naming_rule %L_%s %L_%d_%s %s -instance

read_library -liberty -statetable -lp -all -file ./liblist.f

write_power_intent -library $IPF_DESIGN_FLOW_SCRIPTS/cpf/tech.cpf -replace

exit 
