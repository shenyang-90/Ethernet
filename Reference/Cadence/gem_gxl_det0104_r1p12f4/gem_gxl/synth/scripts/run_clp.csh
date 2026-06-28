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
#    Primary Unit Name :      run_clp.do
#
#          Description :      Conformal Low Power Runscript
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
set HELP4   = "\t-create_tech_cpf   Runs tech cpf creation step\n"
set HELP5   = "\t-clp_presynth      Runs clp on rtl versus CPF/1801\n"
set HELP6   = "\t-clp_postsynth     Runs clp on synthe netlist versus CPF/1801\n"
set HELP6a  = "\t-clp_postccopt     Runs clp on pnr netlist\n"
set HELP7   = "By default clp_presynth is run\n"

set HELP="${HELP1}$HELP2$HELP3$HELP4$HELP5$HELP6$HELP6a$HELP7\n"

set ARGCOUNT   = 1
set ARGS       = $#argv

if ($ARGS == 0) then
  set RUN_TECH_CPF 	= 0
  set RUN_CLP_PRESYNTH  = 1
  set RUN_CLP_POSTSYNTH = 0
  set RUN_CLP_POSTCCOPT = 0
else
  set RUN_TECH_CPF 	= 0
  set RUN_CLP_PRESYNTH  = 0
  set RUN_CLP_POSTSYNTH = 0
  set RUN_CLP_POSTCCOPT = 0


  while ($ARGCOUNT <= $ARGS)
  
    switch($argv[$ARGCOUNT])
          
      # print help information
      case "-h":
          printf "$HELP"
          exit 0
      
      case "-help":
          printf "$HELP"
          exit 0

      case "-create_tech_cpf":
          set RUN_TECH_CPF = 1 
          breaksw

      case "-clp_presynth":
          set RUN_CLP_PRESYNTH = 1 
          breaksw

      case "-clp_postsynth":
          set RUN_CLP_POSTSYNTH = 1 
          breaksw

      case "-clp_postccopt":
          set RUN_CLP_POSTCCOPT = 1
          breaksw
	            
      default:
          printf "\nError : Incorrect argument\n $HELP"
          exit 1
      
    endsw
    @ ARGCOUNT = $ARGCOUNT + 1
  end
endif

printf "\n\tRUNNING the following steps:"
if ($RUN_TECH_CPF == 1) then 
  printf "\n\t\tRUN_TECH_CPF"
endif
if ($RUN_CLP_PRESYNTH == 1) then 
  printf "\n\t\tRUN_CLP_PRESYNTH"
endif
if ($RUN_CLP_POSTSYNTH == 1) then 
  printf "\n\t\tRUN_CLP_POSTSYNTH"
endif
if ($RUN_CLP_POSTCCOPT == 1) then 
  printf "\n\t\tRUN_CLP_POSTCCOPT"
endif
printf "\n\n"


  ## Generate new library list  if it doesnt exist
  if (!  -e ./liblist.f ) then 
    echo "Deleting local liblist "
  tclsh $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_libs.tcl
  endif  

  if ( -z ./liblist.f) then
    echo ""
    echo "ERROR ./liblist.f is EMPTY "
    echo ""
    exit 1
  endif  



if ($RUN_TECH_CPF == 1) then 
  $LSF lec -verify -lp -nogui -dofile $IPF_DESIGN_FLOW_SCRIPTS/clp/create_tech_cpf.do
endif

if ($RUN_CLP_PRESYNTH == 1) then 
  $LSF lec -verify -lp -nogui -dofile $IPF_DESIGN_FLOW_SCRIPTS/clp/clp_pre_synth.do
endif

if ($RUN_CLP_POSTSYNTH == 1) then 
  $LSF lec -verify -lp -nogui -dofile $IPF_DESIGN_FLOW_SCRIPTS/clp/clp_post_synth.do
endif

if ($RUN_CLP_POSTCCOPT == 1) then 
  $LSF lec -verify -lp -nogui -dofile $IPF_DESIGN_FLOW_SCRIPTS/clp/clp_post_ccopt.do
endif
