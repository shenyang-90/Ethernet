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
#    Primary Unit Name :      run_ccd.csh
#
#          Description :      Conformal Constraints Designer runscript
#
#      Original Author :      Mark Lewis 
#
#------------------------------------------------------------------------------
source ./setup_project.csh
if ($? != 0) then
  echo ""
  echo " ERRORS detected check setup_project.csh "
  exit 1
endif

set HELP1   = "\nUsage: run_ccd.csh [options] \n\n"
set HELP2   = "Options are:-\n"
set HELP3   = "\t-h[elp]             Print this message\n"
set HELP4   = "\t-sdc_multi_mode     Run Multi-mode SDC checks (no other checks wil be run)\n"
set HELP5   = "\t-exit               Force exit after run completes\n"
set HELP6   = "\t-cpt <filename.cpt> Restart from specified checkpoint file <file.cpt>\n"
set HELP6a  = "\t-chk                Enable checkpoint flow.  A checkpoint file will be created.\n"

set HELP7   = "\t-default            Runs: Structural CDC, LINT, SDC checks with refined rule decks\n"
set HELP8   = "\t-cdc_struct         Structrual CDC\n"
set HELP9   = "\t-sdc                SDC Lint and Policy checks\n"
set HELP10  = "\t-cdc_func           CDC Functional Checks\n"
set HELP11  = "\t-model              Modelling Checks\n"
set HELP12  = "\t-sr                 Structrual Set/Reset Checks\n"
set HELP13  = "\t-sr_sync            set/reset sync crossing checks\n"
set HELP14  = "\t-no_sdc_rules       Dont use refined SDC rules - Default is to use them\n"
set HELP15  = "\t-no_lint_rules      Dont use refined LINT rules - Default is to use them\n"
set HELP16  = "\t-nolibs             Dont read in libraries\n"

set HELP="${HELP1}$HELP2$HELP3$HELP4$HELP5$HELP6$HELP6a\n"
set HELP2="${HELP7}$HELP8$HELP9$HELP10$HELP11$HELP12\n$HELP14$HELP15$HELP16\n"

set ARGCOUNT       = 1
set ARGS           = $#argv
set cmd_args       = ""
set RESTORE_CPT    = 0
set CPT_FILE       = ""
set SDC_MULTI_MODE = 0

setenv EXIT_CCD_RUN                   0
setenv SDC_MULTI_MODE                 0 
setenv CCD_CDC_STRUCT                 0 
setenv CCD_SDC_CHECKS                 0 
setenv CCD_FUNCTIONAL_CHECKS          0 
setenv CCD_MODELLING_CHECKS           0 
setenv CCD_SETRESET_CHECKS            0 
setenv CCD_SETRESET_SYNC_CROSS_CHECKS 0 
setenv CCD_SAVE_CP                    0 
setenv USE_REFINED_CCD_LINT_RULES     1
setenv USE_REFINED_CCD_SDC_RULES      1
setenv CCD_NOLIBS                     0 

  while ($ARGCOUNT <= $ARGS)
  
    switch($argv[$ARGCOUNT])
          
      # print help information
      case "-h":
          printf "$HELP$HELP2"
          exit 0
      
      case "-help":
          printf "$HELP$HELP2"
          exit 0

      case "-sdc_multi_mode":
          setenv SDC_MULTI_MODE 1 
          setenv CCD_SDC_CHECKS 1 
          set    SDC_MULTI_MODE = 1 
          breaksw

      case "-exit":
          setenv EXIT_CCD_RUN 1 
          breaksw

      case "-cpt":
          @ ARGCOUNT = $ARGCOUNT + 1
          set RESTORE_CPT = 1
          set CPT_FILE = "$argv[$ARGCOUNT]"
          breaksw  

    # Enable Strutural CDC checks
     case "-cdc_struct":
          setenv CCD_CDC_STRUCT 1 
          breaksw

    # Enable SDC checks
      case "-sdc":
          setenv CCD_SDC_CHECKS 1 
          breaksw

    # Enable CDC Functional Checks on Strutural and convergence
      case "-cdc_func":
          setenv CCD_FUNCTIONAL_CHECKS 1 
          breaksw

    # Enable Modelling checks
      case "-model":
          setenv CCD_MODELLING_CHECKS 1 
          breaksw

    # Enable Set/reset checks
      case "-sr":
          setenv CCD_SETRESET_CHECKS 1 
          breaksw

    # Enable set/reset sync crossing checks
      case "-sr_sync":
          setenv CCD_SETRESET_SYNC_CROSS_CHECKS 1 
          breaksw

    # Enable checkpoint creation to review results offline
      case "-chk":
          setenv CCD_SAVE_CP 1 
          breaksw

    # Disable use of refined rule decks for SDC checks
      case "-no_sdc_rules":
          setenv USE_REFINED_CCD_SDC_RULES 0 
          breaksw

    # Disable use of refined rule decks for LINT checks
      case "-no_lint_rules":
          setenv USE_REFINED_CCD_LINT_RULES 0 
          breaksw

    # Dont read in libraries
      case "-nolibs":
          setenv CCD_NOLIBS 1 
          breaksw

    # Default selection
    #  All bar functional CDC, multi-SDC checks and modelling checks
    #  Uses refined lint and sdc rule decks
      case "-default":
          setenv CCD_CDC_STRUCT 1 
          setenv CCD_SDC_CHECKS 1 
          setenv CCD_SETRESET_CHECKS 0 
          setenv CCD_SETRESET_SYNC_CROSS_CHECKS 0 
          breaksw

      default:
          printf "\nError : Incorrect argument\n $HELP$HELP2"
          exit 1
      
    endsw
    @ ARGCOUNT = $ARGCOUNT + 1
  end
endif

 if ($ARGS == 0) then
          printf " \n **** Running LINT checks only as no other selections were provided on the command line **** \n"
 endif

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


# Restore checkpoint
if ($RESTORE_CPT) then
  printf "\n    Restoring checkpoint file $CPT_FILE"
  printf "\n    Use set_gui when in TCL mode to start the GUI\n"
  $LSF ccd -restart_checkpoint $CPT_FILE

# Run multi-mode SDC checks only
else if ($SDC_MULTI_MODE) then
  printf "\n    **** Running ONLY Multi-mode SDC checks\n\n"
  $LSF ccd -mcc -dofile $IPF_DESIGN_FLOW_SCRIPTS/ccd/cdc.do -nogui 

# Run full single mode flow, lint,SDC,CDC
else 
  printf "\n    **** NOTE: The run will NOT exit upon completion. Please use run_ccd.csh -exit to force an exit.\n\n"
  $LSF ccd -xl -dofile $IPF_DESIGN_FLOW_SCRIPTS/ccd/cdc.do -nogui 
endif

 
