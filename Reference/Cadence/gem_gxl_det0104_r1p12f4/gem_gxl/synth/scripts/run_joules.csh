#!/bin/csh
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
#    Primary Unit Name :      run_joules.csh
#
#          Description :      Joules Run Script 
#
#      Original Author :      Patrick McKeever 
#
#------------------------------------------------------------------------------
source ./setup_project.csh
if ($? != 0) then
  echo ""
  echo " ERRORS detected check setup_project.csh "
  exit 1
endif

set HELP1   = "\nUsage: run_clp.csh [options] \n\n"
set HELP2   = "Options are:-\n"
set HELP3   = "\t-h[elp]            Print this message\n"
set HELP4   = "\t-joules_rtl        Joules using RTL (joules runs it's own synthesis) and activity from RTL Sims\n"
set HELP5   = "\t-joules_post_synth Joules using post synthesis netlist from RC/Genus and activity from RTL Sims \n"
set HELP6   = "\t-joules_gls        Joules using post layout netlist and activity from GLS \n"
set HELP7   = "By default joules_rtl is run\n"

set HELP="${HELP1}$HELP2$HELP3$HELP4$HELP5$HELP6$HELP7\n"


set ARGCOUNT   = 1
set ARGS       = $#argv

if ($ARGS == 0) then
  set RUN_JOULES_RTL 	= 1
  set RUN_JOULES_NETLIST  = 0
  set RUN_JOULES_GLS = 0

else
  set RUN_JOULES_RTL 	= 0
  set RUN_JOULES_NETLIST  = 0
  set RUN_JOULES_GLS = 0

  while ($ARGCOUNT <= $ARGS)
  
    switch($argv[$ARGCOUNT])
          
      # print help information
      case "-h":
          printf "$HELP"
          exit 0
      
      case "-help":
          printf "$HELP"
          exit 0

      case "-joules_rtl":
          set RUN_JOULES_RTL = 1 
          breaksw

      case "-joules_post_synth":
          set RUN_JOULES_NETLIST = 1 
          breaksw
	  
      case "-joules_gls":
          set RUN_JOULES_GLS = 1 
          breaksw
	  	            
      default:
          printf "\nError : Incorrect argument\n $HELP"
          exit 1
      
    endsw
    @ ARGCOUNT = $ARGCOUNT + 1
  end
endif

printf "\n\tRUNNING the following steps:"
if ($RUN_JOULES_RTL == 1) then 
  printf "\n\t\tRUN_JOULES_RTL"
endif
if ($RUN_JOULES_NETLIST == 1) then 
  printf "\n\t\tRUN_JOULES_NETLIST"
endif
if ($RUN_JOULES_GLS == 1) then 
  printf "\n\t\tRUN_JOULES_GLS"
endif
printf "\n\n"

if ($RUN_JOULES_RTL == 1) then 
  $LSF joules -files $IPF_DESIGN_FLOW_SCRIPTS/joules/joules_rtl.tcl
endif

if ($RUN_JOULES_NETLIST == 1) then 
  $LSF joules -files $IPF_DESIGN_FLOW_SCRIPTS/joules/joules_post_synth.tcl
endif

if ($RUN_JOULES_GLS == 1) then 
  $LSF joules -files $IPF_DESIGN_FLOW_SCRIPTS/joules/joules_gls.tcl
endif

