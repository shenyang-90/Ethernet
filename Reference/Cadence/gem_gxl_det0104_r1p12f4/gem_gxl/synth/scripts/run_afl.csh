#!/bin/csh -f
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
#    Primary Unit Name :      run_afl.csh
#
#          Description :      Jasper AFL runscript
#
#      Original Author :      Mark Lewis 
#
#------------------------------------------------------------------------------
  source ./setup_project.csh

      setenv AFL_INPUT_PATH `echo "source ./project.tcl; source $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_dirs.tcl;" 'puts $_AFL_INPUT_PATH' | tclsh`
      setenv AFL_RPTS_PATH `echo "source ./project.tcl; source $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_dirs.tcl;" 'puts $_AFL_PATH' | tclsh`

#----- DISPLAY HELP -----#

set HELP1   = "\nUsage: run_afl.csh [options] \n\n"
set HELP2   = "Options are:-\n"
set HELP3   = "\t-h[elp]               Print this message\n"
set HELP4   = "\t-clean                Clean up an exisiting database\n"
set HELP4a  = "\t-setup                Generate liblist.v, expanded.f and blackbox list if they dont already exist\n"
set HELP5   = "\t-run                  Run HAL checks\n"
set HELP5a  = "\t-run_adv              Run Advanced Lint (Formal) checks.   NOTE: This can be time consuming. \n\t\t\t      Recommendation is to use -setup_adv and select rules to run.\n"
set HELP5b  = "\t-setup_adv            Sets up the advanced checks but doesn't run any checks - \n\t\t\t      (use with -GUI and follow RDF user guide to select rules to be run) \n"
set HELP5c  = "\t-rulefile             New rulefile to overwrite RDF standard ruleset - \n\t\t\t      (use with -GUI and follow RDF user guide to select rules to be run) \n"
set HELP5d  = "\t-check                Selects the check category within the ruleset being used. - \n\t\t\t      (use with -GUI and follow RDF user guide to select rules to be run) \n"
set HELP6   = "\t-gui                  Open gui to debug (Use with -run and/or -run_adv)\n"
set HELP7   = "\t-compile_lib          Compile tech library, e.g. when a design has preserved standard cells, use with -run option\n"
set HELP8   = "\n\t  Any unrecognized command wil be passed directly to the IRUN command line\n"
set HELP="$HELP1$HELP2$HELP3$HELP4$HELP4a$HELP5$HELP5a$HELP5b$HELP5c$HELP5d$HELP6$HELP7$HELP8\n"

set ARGCOUNT   = 1
set ARGS       = $#argv

setenv AFL_CLEAN 0
setenv AFL_SETUP 0
setenv AFL_RUN 0
setenv AFL_RUN_ADV 0
setenv AFL_SETUP_ADV 0
setenv AFL_GUI 0
setenv AFL_COMPILELIB 0
setenv AFL_NEW_RULES  0
setenv AFL_NEW_CATEGORY  0

# Setup Rule file to use
set AFL_RULE_FILE      = "-rulelib ${IPF_DESIGN_FLOW_SCRIPTS}/afl/ipg_param_chk.so -rulefile ${IPF_DESIGN_FLOW_SCRIPTS}/afl/hal_important_rules_041016.def"
set AFL_CHECK_CATEGORY = "-check ALL_RTL_IPG"

set AFL_CMD_ARGS = ""
set HAL_DESIGN_INFO_FILE = "${AFL_INPUT_PATH}/hal_design_info"
set AFL_BBOX_LIST      = "${AFL_INPUT_PATH}/afl_bbox_list"
set AFL_TCL_FILE       = "${AFL_INPUT_PATH}/afl_setup.tcl"
set SWITCH_TO_IRUN = ""
set FINAL_RULE_FILE = ""

while ($ARGCOUNT <= $ARGS)

   switch($argv[$ARGCOUNT])
        
   # print help information
   case "-h":
       printf "$HELP"
       exit 0

   case "-help":
       printf "$HELP"
       exit 0
                               
   case "-clean":
       setenv AFL_CLEAN 1
       breaksw
       
   case "-setup":
       setenv AFL_SETUP 1
       breaksw
       
   case "-run":
       setenv AFL_RUN 1
       breaksw
       
   case "-run_adv":
       setenv AFL_RUN_ADV 1
       breaksw
   
    case "-setup_adv":
       setenv AFL_SETUP_ADV 1
       breaksw

   case "-rulefile":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AFL_NEW_RULES = 1
       set AFL_RULE_FILE = "-rulefile $argv[$ARGCOUNT]"
       breaksw  

   case "-check":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AFL_NEW_CATEGORY = 1
       set AFL_CHECK_CATEGORY = "-check $argv[$ARGCOUNT]"
       breaksw  
 
   case "-gui":
       setenv AFL_GUI 1
       breaksw
  
    case "-compile_lib"
      setenv AFL_COMPILELIB 1
      breaksw
                       
   default:
       set SWITCH_TO_IRUN = "$SWITCH_TO_IRUN $argv[$ARGCOUNT]"
       breaksw

   endsw

    @ ARGCOUNT = $ARGCOUNT + 1

end


if ($ARGS == 0) then
   printf "$HELP"
   exit 1
endif


#-------------------------------------------------------------------------------
# Clean up
#-------------------------------------------------------------------------------
if ($AFL_CLEAN == 1) then
  if ( -e ./liblist.v ) then 
    echo "Deleting local liblist "
    rm ./liblist.f
    rm ./liblist.v
  endif
     
  echo "Cleaning up..."
  rm -rf INCA_libs *.log ./jgproject ./hal.design_facts .rtlchecks.log

endif


#-------------------------------------------------------------------------------
# Create input files
#-------------------------------------------------------------------------------
if ($AFL_SETUP == 1) then

  ## Generate new library list 
  tclsh $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_libs.tcl

  if ( -z ./liblist.v) then
    echo ""
    echo "ERROR ./liblist.v is EMPTY "
    echo ""
    exit 1
  endif  

    echo ""
  #  tcl control file
  # If it doesnt exist then copy a default version to update
  if ( ! -e $AFL_TCL_FILE ) then
    mkdir -p ${AFL_INPUT_PATH}
    cp $IPF_DESIGN_FLOW_SCRIPTS/afl/afl_setup.tcl $AFL_TCL_FILE
    echo " Created default setup file.  Modify here:"
    echo " $AFL_TCL_FILE"
    echo ""
  else 
    echo " Using existing setup file:"
    echo " $AFL_TCL_FILE"
    echo ""
  endif
    
  # Create a list of modules blackbox files
    if ( -e $AFL_BBOX_LIST ) then
      echo " Using existing blackbox list file:"
      echo " $AFL_BBOX_LIST"
      echo " - Remove this a blackbox list file is to be generated based on setup_project contents"
      echo ""
    else
      if ($?BLACKBOXES) then
        echo " Creating blackbox list file : $AFL_BBOX_LIST"
        echo ""
        foreach bbox ($BLACKBOXES)
          echo "$bbox" >> $AFL_BBOX_LIST
        end
      endif    
  endif
      
endif

#-------------------------------------------------------------------------------
# Prepare to Execute
#-------------------------------------------------------------------------------

if ($AFL_RUN  || $AFL_RUN_ADV || $AFL_SETUP_ADV) then


  if ("$SWITCH_TO_IRUN" != "") then
    printf "\nPassing these commands directly to the IRUN:\n  $SWITCH_TO_IRUN\n\n"
    set AFL_CMD_ARGS = "$AFL_CMD_ARGS $SWITCH_TO_IRUN"  
  endif

  if ( ! -e $AFL_TCL_FILE ) then
        echo " No afl_setup.tcl file has been found here:" 
        echo "  ${AFL_INPUT_PATH}" 
        echo " Use run_afl.csh -setup to get a template version to update" 
        echo ""
        exit
  else
    echo " Using existing setup file:" 
    echo "   $AFL_TCL_FILE" 
  endif

  ## Include any include directories
  if ($?HDL_SEARCH_PATH) then
   foreach incdir ($HDL_SEARCH_PATH)
    set AFL_CMD_ARGS = "$AFL_CMD_ARGS -incdir $incdir"
   end
  endif

  ## Compile verilog libraries if required
  if ($AFL_COMPILELIB) then
    set AFL_CMD_ARGS = "$AFL_CMD_ARGS -f ./liblist.v"
  endif

echo "\nUsing Check Category: $AFL_CHECK_CATEGORY \n"
echo "with Rule File: Command line specified $AFL_RULE_FILE"

  ## IRUN specific switches
  set AFL_CMD_ARGS = "${AFL_CMD_ARGS} \
                        -64bit \
                        -ALLOWREDEFINITION \
                        -bb_nonsynth \
                        -sv \
                        -top ${DESIGN} \
                        -access +rwc \
                        -F ${RTL_F_FILE} \
                        -input ${AFL_TCL_FILE} \
                        -races \
                        -BB_NONSYNTH \
                        ${AFL_RULE_FILE} \
                        ${AFL_CHECK_CATEGORY} \
                        "
  
#                        -rulefile /projects/kessel/work/mlewis/trunk/mipi_csi2rx/cfg/TI_AFL_RULES/hal.def \

#-------------------------------------------------------------------------------
# Prepare to Execute
#-------------------------------------------------------------------------------

echo ""
echo "Running with these options"
echo ""
  if ($AFL_GUI) then
#    echo "$LSF irun -jg -afl $AFL_CMD_ARGS -gui"
    $LSF irun -jg -afl -jgargs "-proj ${AFL_RPTS_PATH}" $AFL_CMD_ARGS -gui 
  else
#    echo "$LSF irun -jg -afl $AFL_CMD_ARGS"
    $LSF irun -jg -afl -jgargs "-proj ${AFL_RPTS_PATH}" $AFL_CMD_ARGS     
  endif
endif
