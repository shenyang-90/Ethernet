#!/bin/csh
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
#    Primary Unit Name :      run_atpg.csh
#
#          Description :      ATPG runscript
#
#      Original Author :      Anna Gilbert 
#
#------------------------------------------------------------------------------
source ./setup_project.csh

set HELP1   = "\nUsage: run_atpg.csh [options] \n\n"
set HELP2   = "Options are:-\n"
set HELP3   = "\t-h[elp]            Print this message\n"
set HELP4   = "\t-atpg_legacy       		Runs atpg step using Encounter Test\n"
set HELP4a  = "\t-atpg              		Runs atpg step using Modus\n"
set HELP5   = "\t-lbist_sig         		Runs LBIST first step to generate signature\n"
set HELP6   = "\t-lbist_vec         		Runs LBIST second step to generate vectors\n"
set HELP6a  = "\t-lbist_rrfa        		Runs RRFA to identify testpoints used for increasing LBIST coverage\n"
set HELP7   = "\t-padding_parallel <filename>    Option to control timing relationship between test control signals for parallel simulations\n"
set HELP7a  = "\t 		    		specified in file <filename>. Use only with Modus! \n"
set HELP8   = "\t-padding_serial  <filename>     Option to control timing relationship between test control signals for serial simulations\n"
set HELP8a  = "\t 		    		specified in file <filename>. Use only with Modus! \n"
set HELP9   = "\tBy default only atpg with Modus is run\n"

set HELP="${HELP1}$HELP2$HELP3$HELP4$HELP4a$HELP5$HELP6$HELP6a$HELP7$HELP7a$HELP8$HELP8a$HELP9\n"

set ARGCOUNT   = 1
set ARGS       = $#argv


if ($ARGS == 0) then
  set RUN_ATPG_MODUS 	      	= 1
  set RUN_ATPG_ET 	      	= 0
  set RUN_LBIST_SIG   		= 0
  set RUN_LBIST_VEC   		= 0
  set RUN_LBIST_RRFA         	= 0
  set PADDING_PARALLEL          = 0
  set PADDING_SERIAL            = 0
else
  set RUN_ATPG_MODUS 	      	= 0
  set RUN_ATPG_ET 	      	= 0
  set RUN_LBIST_SIG   		= 0
  set RUN_LBIST_VEC   		= 0
  set RUN_LBIST_RRFA         	= 0
  set PADDING_PARALLEL          = 0
  set PADDING_SERIAL            = 0
  
  setenv PADDING_SERIAL_FILE ""
  setenv PADDING_PARALLEL_FILE ""
  
  while ($ARGCOUNT <= $ARGS)
  
    switch($argv[$ARGCOUNT])
          
      # print help information
      case "-h":
          printf "$HELP"
          exit 0
      
      case "-help":
          printf "$HELP"
          exit 0

      case "-atpg_legacy":
          set RUN_ATPG_ET = 1 
          breaksw

      case "-atpg":
          set RUN_ATPG_MODUS = 1 
          breaksw

      case "-lbist_sig":
          set RUN_LBIST_SIG = 1 
          breaksw

      case "-lbist_vec":
          set RUN_LBIST_VEC = 1 
          breaksw

      case "-lbist_rrfa":
          set RUN_LBIST_RRFA = 1
          breaksw
	
      case "-padding_parallel":
          @ ARGCOUNT = $ARGCOUNT + 1
          set PADDING_PARALLEL = 1
          setenv PADDING_PARALLEL_FILE "$argv[$ARGCOUNT]"
          breaksw   

      case "-padding_serial":
          @ ARGCOUNT = $ARGCOUNT + 1
          set PADDING_SERIAL = 1
          setenv PADDING_SERIAL_FILE  "$argv[$ARGCOUNT]"
          breaksw   
	

      default:
          printf "\nError : Incorrect argument\n $HELP"
          exit 1
      
    endsw
    @ ARGCOUNT = $ARGCOUNT + 1
  end
endif

printf "\n\tRUNNING the following steps:"
if ($RUN_ATPG_MODUS == 1) then 
  printf "\n\t\tATPG using Modus\n"
endif
if ($RUN_ATPG_ET == 1) then 
  printf "\n\t\tATPG using ET\n"
endif
if ($RUN_LBIST_SIG == 1) then 
  printf "\n\t\tgenerate LBIST signature\n"
endif
if ($RUN_LBIST_VEC == 1) then 
  printf "\n\t\tgenerate LBIST vectors\n"
endif
if ($RUN_LBIST_RRFA == 1) then 
  printf "\n\t\tRRFA"
endif
if ($PADDING_SERIAL == 1) then 
  if (-e $PADDING_SERIAL_FILE ) then
    printf "\t\tPadding option for serial simulation will be used with $PADDING_SERIAL_FILE\n" 
  else
    printf "\t\t$PADDING_SERIAL_FILE does not exist\n"
    exit 1
  endif  
endif
if ($PADDING_PARALLEL == 1) then
  if (-e $PADDING_PARALLEL_FILE) then   
    printf "\t\tPadding option for parallel simulation will be used with $PADDING_PARALLEL_FILE\n"   
  else
    printf "\t\t$PADDING_PARALLEL_FILE does not exist\n"
    exit 1
  endif  
endif

printf "\n"


if ($RUN_ATPG_ET == 1 ) then
   $LSF et -source $IPF_DESIGN_FLOW_SCRIPTS/et/et_flow.tcl
   $LSF et -source $IPF_DESIGN_FLOW_SCRIPTS/et/et_reports.tcl
endif

if ($RUN_ATPG_MODUS == 1 ) then
  if ( ($PADDING_PARALLEL == 1) || ($PADDING_SERIAL == 1) )then
    rm -rf $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_tmp.tcl
    cp $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_flow.tcl $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_tmp.tcl
    tclsh $IPF_DESIGN_FLOW_SCRIPTS/modus/padding_setup.tcl
  endif
  $LSF modus -file $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_flow.tcl
  $LSF modus -file $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_reports.tcl
endif

if ($RUN_LBIST_SIG == 1 ) then
   $LSF modus -file $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_flow_lbist_sig.tcl
   $LSF modus -file $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_lbist_reports.tcl
   endif

if ($RUN_LBIST_VEC == 1 ) then
   $LSF modus -file $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_flow_lbist_vec.tcl
endif

if ($RUN_LBIST_RRFA == 1 ) then
   $LSF modus -file $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_flow_lbist_rrfa.tcl
endif

if ( ($PADDING_PARALLEL == 1) || ($PADDING_SERIAL == 1) )then
 cp $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_tmp.tcl $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_flow.tcl
 rm -rf $IPF_DESIGN_FLOW_SCRIPTS/modus/modus_tmp.tcl
endif 
