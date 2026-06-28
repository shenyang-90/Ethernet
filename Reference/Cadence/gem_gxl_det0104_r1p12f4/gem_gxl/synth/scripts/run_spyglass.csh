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
#    Primary Unit Name :      run_spyglass.csh
#
#          Description :      Spyglass runscript
#
#      Original Author :      Anna Gilbert 
#
#------------------------------------------------------------------------------
source ./setup_project.csh

# Prevents spyglass issue of duplicate SGDCs - checkCMD_duplicate03
#setenv SGS_REGR_AVOID_DUPL_READ yes


#----- DISPLAY HELP -----#

set HELPa   = "\n-----------------------------------------------------------------------------------------------------------------------"
set HELP1   = "\n There are 3 stages to running Spyglass for the first time:\n"
set HELP1a  = "\n --  1st stage) './run_spyglass -setup' Should be run first to generate the Spyglass setup files for necessary updates."
set HELP1b  = "\n     NOTE: This stage will be run automatically if no existing sg_setup directory exists in the selected run directory"
set HELP1bb = "\n     NOTE: The setup stage is not supported by the TSMC Kit so skip this step if running the TSMC Kit from scratch. \n"
set HELP1c  = "\n --  2nd stage) './run_spyglass -read' MUST be run after setup to read in the SDC and RTL."
set HELP1d  = "\n     Use this command to re-read any updates to the SDC or RTL \n"
set HELP1d  = "\n     This stage will run the design_audit, cdc_setup_check and sdc_audit goals\n"
set HELP1e  = "\n --  3rd stage) 'Select a run option from below to execute the required goals."
set HELP1f  = "\n     Run the initial goalset first to enure correct setup for the rest of the goals. \n"
set HELP1g  = "\n\n Usage: run_spyglass.csh [options] \n"
set HELP2   = "  Options are:\n"
set HELP3   = "\t-h[elp]            Print this message\n\n"

set HELP4   = "\t#### Setup ####\n"
set HELP4b  = "\t-setup                        AIPK Clean read of design and sdc to setup initial spyglass database\n"
set HELP4c  = "\t                              NOTE: This will also run 'clean all' which will clear out any existing sg_setup and results directories\n"
set HELP4d  = "\t-read                         Clean up existing database, re-read RTL and SDC\n"
set HELP4e  = "\t                              (Setup stage will run automatically if not already complete)\n"
set HELP4ee = "\t-nosv                         Don't enable SystemVerilog handling.  Default is to enabled it. -(This will update the options.tcl file)\n\n"
set HELP4f  = "\t-outdir <directory>           Specify an output directory for Spyglass\n"
set HELP4g  = "\t-activity_file <file.vd/saif> VCD or SAIF File for power related goals\n"
set HELP4h  = "\t-sgdc <file.sgdc>             Use existing SGDC File for setup\n"
set HELP4i  = "\t-waiver <file.swl>            Existing swl file to be added to a new setup \n"
set HELP4k  = "\t-power_file <file.cpf/upf>    CPF/UPF power intent file to include\n"
set HELP4l  = "\t-phy_target <library>         Library to be used for Physical Goals\n"
set HELP4o  = "\t-nolibs                       Don't read in libraries\n"

set HELP4m  = "\t-nostatics                    Don't apply statics as specified by STATICS_FILE variable in setup_project.csh\n"

set HELP5   = "\t#### Atrenta IPKit goals for RTLDesignFlow. Ensure Atrenta IPKit is loaded ####\n"
set HELP5a  = "\t-run_flow_initial             Runs a the setup goals.  IMPORTANT - Ensure these goals are clean before running further analysis.\n"
set HELP5b  = "\t-run_flow_signoff             Run the sign off goals\n\n"

set HELP6   = "\t#### TSMC Specific goal sets. Ensure TSMC Kit is loaded ####\n"
set HELP6a  = "\t-run_goal <TSMC goal>         Run TSMC goal/s. Run basic_check and then adv_check.   \n\n"

set HELP8   = "\t#### Miscellaneous ####\n"
set HELP8a  = "\t-showgoals                    List available goals\n"
set HELP8b  = "\t-run_goal <goal>              Run a specific goal \n"
set HELP8c  = "\t-gui                          Interactive debug\n"
set HELP8d  = "\t-pack                         Pack reports and spyglass constraints\n"

set HELP="${HELPa}${HELP1}${HELP1a}${HELP1b}${HELP1bb}${HELP1c}${HELP1d}${HELP1e}${HELP1f}${HELP1g}\n"
set HELPEXT="${HELP2}${HELP3}${HELP4}${HELP4b}${HELP4c}${HELP4d}${HELP4e}${HELP4ee}${HELP4f}${HELP4g}${HELP4h}${HELP4i}${HELP4k}${HELP4l}${HELP4o}\n"
set HELPEXT2="${HELP5}${HELP5a}${HELP5b}${HELP6}${HELP6a}${HELP8}${HELP8a}${HELP8b}${HELP8c}${HELP8d}\n"

set ARGCOUNT   = 1
set ARGS       = $#argv
set AIPK_LOG_FILE = "run_spyglass_user_def.log"

set AIPK_NOSTATICS = 0
set AIPK_RUN_GOALS = 0
set AIPK_GOAL_LIST = ""
set AIPK_RUN_SIGNOFF = 0
set AIPK_ANALYZE = 0
set AIPK_PACK = 0
set AIPK_READ_CLEAN = 0
set AIPK_READ = 0
set AIPK_SINGLE_GOAL = ""
set AIPK_SELECTION = 0
set AIPK_SHOWGOALS = 0
set AIPK_OUTPUT_DIR = ""
set AIPK_OUTDIR_ARGS = ""
set AIPK_SET_OUTPUT_DIR = 0
set AIPK_WAIVER = 0
set AIPK_WAIVER_FILE = ""
set AIPK_ACTIVITY = 0
set AIPK_ACTIVITY_FILE = ""
set AIPK_SGDC = 0
set AIPK_SGDC_FILE = ""
set AIPK_POWER = 0
set AIPK_POWER_FILE = ""
set AIPK_CMN_CMD_ARGS="-top $DESIGN " 
set AIPK_SETUP_CMD_ARGS ="" 
set TSMC_KIT = 0
set AIPK_ENABLE_SV = 1
set AIPK_PHY_TARGET = 0
set AIPK_PHY_TARGET_SEL = ""
set AIPK_NO_LIBS = 0

# Select files based on configuration (if set)
if ( "x$CONFIG" == "x" || ! $?CONFIG) then
   set LOCAL_F_FILE       = "spg_${DESIGN}.f"
   set SDC_FILE           = "${DESIGN}.func.sdc"
else 
   set LOCAL_F_FILE       = "spg_${DESIGN}_${CONFIG}.f"
   set SDC_FILE           = "${DESIGN}_$CONFIG.func.sdc"
endif

set AIPK_READ_CMD_ARGS = "-sdcfile spg_${SDC_FILE}" 


while ($ARGCOUNT <= $ARGS)

   switch($argv[$ARGCOUNT])
        
   # print help information
   case "-h":
       printf "$HELP"
       printf "$HELPEXT"
       printf "$HELPEXT2"
       exit 0

   case "-help":
       printf "$HELP"
       printf "$HELPEXT"
       printf "$HELPEXT2"
       exit 0

   case "-waiver":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_WAIVER = 1
       set AIPK_WAIVER_FILE = "$argv[$ARGCOUNT]"
       breaksw  

   case "-activity_file":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_ACTIVITY = 1
       set AIPK_ACTIVITY_FILE = "$argv[$ARGCOUNT]"
       breaksw  

   case "-sgdc":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_SGDC = 1
       set AIPK_SGDC_FILE = "$argv[$ARGCOUNT]"
       breaksw  

   case "-power_file":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_POWER = 1
       set AIPK_POWER_FILE = "$argv[$ARGCOUNT]"
       breaksw  
                               
   case "-setup":
       set AIPK_READ_CLEAN = 1
       breaksw
       
   case "-read":
       set AIPK_READ = 1
       ## force a clean if its the first time aipk_read has been run
       if (! -d sg_setup) then
         set AIPK_READ_CLEAN = 1
       endif
       breaksw
       
   case "-showgoals":
       set AIPK_SHOWGOALS = 1
       breaksw
       
   case "-nostatics":
       set AIPK_NOSTATICS = 1
       breaksw
         
   case "-run_flow_signoff":
       set AIPK_RUN_GOALS = 1
       set AIPK_GOAL_LIST = (lint_rtl,lint_abstract,adv_lint_struct,adv_lint_verify,sdc_audit,sdc_check,sdc_exception_struct,sdc_redundancy,sdc_abstract,fp_mcp_verification,cdc_setup_check,clock_reset_integrity,cdc_verify_struct,cdc_verify,cdc_abstract,dft_scan_ready,dft_best_practice,dft_dsm_clocks,dft_dsm_best_practice,dft_abstract,power_est_average,power_verif_instr_rtl)
       breaksw
       
   case "-run_flow_initial":
       set AIPK_RUN_GOALS = 1
       set AIPK_GOAL_LIST = (cdc_setup_check,cdc_verify_struct,sdc_audit,sdc_check,sdc_exception_struct,sdc_redundancy)
       breaksw  
                               
   case "-gui":
       set AIPK_ANALYZE = 1
       breaksw  
                               
   case "-pack":
       set AIPK_PACK = 1
       breaksw  
                               
   case "-nosv":
       set AIPK_ENABLE_SV = 0
       breaksw  
                               
   case "-nolibs":
       set AIPK_NO_LIBS = 1
       breaksw  
                               
   case "-run_goal":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_RUN_GOALS = 1
       set AIPK_GOAL_LIST = "$argv[$ARGCOUNT]"
       set AIPK_LOG_FILE = "run_spyglass_user_def.log"
       breaksw  
                               
   case "-outdir":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_SET_OUTPUT_DIR = 1
       set AIPK_OUTPUT_DIR = "$argv[$ARGCOUNT]"
       breaksw  
                               
   case "-phy_target":
       @ ARGCOUNT = $ARGCOUNT + 1
       set AIPK_PHY_TARGET = 1
       set AIPK_PHY_TARGET_SEL = "$argv[$ARGCOUNT]"
       breaksw  
        
   default:
       printf "\nError : Incorrect command line argument: $argv[$ARGCOUNT] \n $HELP"
       printf "$HELP"
       printf "$HELPEXT"
       printf "$HELPEXT2"

       exit 1

   endsw

    @ ARGCOUNT = $ARGCOUNT + 1

end

#-------------------------------------------------------------------------------
# Set up the required input files
# Libraries, SDC, filelist, configuration file (if used)
#-------------------------------------------------------------------------------

if ($AIPK_READ_CLEAN == 1) then
  set AIPK_SETUP_CMD_ARGS = "$AIPK_SETUP_CMD_ARGS -exit setup -clean all" 
  if ( -e ./liblist.f ) then 
    echo "Deleting local liblist "
    rm ./liblist.f
  endif
  
  ## Generate new library list 
  tclsh $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_libs.tcl

  if ( -z ./liblist.f) then
    echo ""
    echo "ERROR ./liblist.f is EMPTY "
    echo ""
    exit 1
  endif  

  if ( -e ./spg_$SDC_FILE ) then 
    echo "Deleting local SDC constraints "
    rm ./spg*
  endif
  
  ## New SDC File
  # Copy sdc file locally and update to specify DRIVE_CELL from tech_lib_setup
    echo ""
    echo "NOTE: Copying the following SDC File locally to modify DRIVE_CELL:"
    echo "$SDC_PATH/$SDC_FILE"
    echo ""
      cp $SDC_PATH/$SDC_FILE  ./spg_$SDC_FILE
#      setenv DRIVE_CELL `echo "source $IPF_DESIGN_FLOW_SCRIPTS/tech_lib_setup.tcl;" 'puts $DRIVE_CELL' | tclsh`
      setenv DRIVE_CELL `echo "set IPF_DESIGN_FLOW_SCRIPTS $IPF_DESIGN_FLOW_SCRIPTS; source $IPF_DESIGN_FLOW_SCRIPTS/tech_lib_setup.tcl;" 'puts $DRIVE_CELL' | tclsh`
      perl -p -i -e 's/\$DRIVE_CELL/'"$DRIVE_CELL/g" ./spg_$SDC_FILE


  ## Copy filelist locally - Only reason for this is to add HDL_SEARCH_PATH in form of +incdir
    cp $RTL_F_FILE $LOCAL_F_FILE
  
    # Add include dirs if HDL_SEARCH_PATH has been defined
    if ($?HDL_SEARCH_PATH) then
      foreach hdl_path ($HDL_SEARCH_PATH)
        echo "+incdir+$hdl_path" >> $LOCAL_F_FILE
      end
    endif

    # Add src .f file 
    set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -srcfile $LOCAL_F_FILE"
  
    echo "Created local library list          -  ./liblist.f"
    echo "Created local SDC file              -  ./spg_$SDC_FILE"
    echo "Created local source filelist       -  ./$LOCAL_F_FILE"
     
  
else  
if ($AIPK_NO_LIBS == 1) then  
  printf "\n **** NO LIBRARIES ARE BEING READ IN DUE TO -nolibs switch on command line ****\n\n"
endif
    echo "Using existing library list          -  ./liblist.f"
    echo "Using existing SDC file              -  ./spg_$SDC_FILE"
    echo "Using existing source filelist       -  ./$LOCAL_F_FILE"
     
endif 


#-------------------------------------------------------------------------------
# Check for the type of Kit being used - TSMC or Atrenta
#-------------------------------------------------------------------------------
if ( $ATRENTA_IPKIT_DIR =~ *"tsmc"* ) then
       printf "\n  **** RUNNING WITH TSMC KIT ****\n\n " |tee ./run_spyglass_read.log
 set TSMC_KIT = 1
else
       printf "\n **** RUNNING WITH ATRENTA KIT ****\n\n " |tee ./run_spyglass_read.log
 set TSMC_KIT = 0
endif


#-------------------------------------------------------------------------------
# Set the output directory
# defaults to local directory based on "DESIGN, STAMP and CONFIG" variables
#-------------------------------------------------------------------------------
if ($AIPK_SET_OUTPUT_DIR == 1) then
 set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -outdir $AIPK_OUTPUT_DIR"
else
 set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -outdir ${DESIGN}_${STAMP}_${CONFIG}"
endif

#-------------------------------------------------------------------------------
# Add user specified SGDC file
#-------------------------------------------------------------------------------
if ( $AIPK_SGDC == 1 ) then
  if ( -e $AIPK_SGDC_FILE ) then
    set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -sgdc $AIPK_SGDC_FILE"
      # Backup SGDC if user is using an SGDC with issues
      if (-e sg_setup/$DESIGN/${DESIGN}.sgdc) then
            cp sg_setup/$DESIGN/${DESIGN}.sgdc sg_setup/$DESIGN/${DESIGN}.sgdc.bak
      endif

  else
    echo ""  
    echo "  WARNING: The specified SGDC file does not exist where specified: $AIPK_SGDC_FILE"
    echo ""
    exit
  endif
endif

#-------------------------------------------------------------------------------
# Add activity data
#-------------------------------------------------------------------------------
if ( $AIPK_ACTIVITY == 1 ) then
  if ( -e $AIPK_ACTIVITY_FILE ) then
    set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -activity_file $AIPK_ACTIVITY_FILE"
  else
    echo ""
    echo "  WARNING: The specified activity file does not exist where specified: $AIPK_ACTIVITY_FILE"
    echo ""
    exit
  endif
endif

#-------------------------------------------------------------------------------
# Add power data (CPF/UPF)
#-------------------------------------------------------------------------------
if ( $AIPK_POWER == 1 ) then
  if ( -e $AIPK_POWER_FILE ) then
    set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -power_file $AIPK_POWER_FILE"
  else
    echo ""
    echo "  WARNING: The specified CPF/UPF file does not exist where specified: $AIPK_POWER_FILE"
    echo ""
    exit
  endif
endif

#-------------------------------------------------------------------------------
# Add existing waiver file
#-------------------------------------------------------------------------------

if ( $AIPK_WAIVER == 1 ) then
  if ( -e $AIPK_WAIVER_FILE ) then
    set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -waiver $AIPK_WAIVER_FILE"
  else
    echo ""
    echo "  WARNING: The specified waiver file does not exist where specified: $AIPK_WAIVER_FILE"
    echo ""
    exit
  endif
endif


  # Need to update the methodology if running TSMC goals
#  if ($AIPK_RUN_GOALS == 1) then
#    if ($TSMC_KIT == 1) then
#      grep "current_methodology" sg_setup/${DESIGN}/${DESIGN}_options.tcl
#      if ($?) then
#        echo 'set_option   current_methodology $env(ATRENTA_IPKIT_DIR)/methodology' >> ./sg_setup/${DESIGN}/${DESIGN}_options.tcl
#      endif
#    endif
#  endif     



#-------------------------------------------------------------------------------
# Add SDC and libs to command line
#-------------------------------------------------------------------------------

  if (($AIPK_READ_CLEAN == 1)||($AIPK_READ == 1)) then

  if ($AIPK_NO_LIBS == 0) then
  set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -libfile ./liblist.f"
  endif
  
    # Select library for physical goals either on command line or select first library
    # in liblist
      # Find the first library name for physical analysis
      set phy_target = `perl -ne 'print $1 if /(\w*).lib/; exit' ./liblist.f`
      
    if ($AIPK_NO_LIBS == 0) then
    if ($AIPK_PHY_TARGET == 1) then
      set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -phy_target $AIPK_PHY_TARGET_SEL"
    else  
      set AIPK_CMN_CMD_ARGS = "$AIPK_CMN_CMD_ARGS -phy_target $phy_target"
    endif  
    endif  
  endif
    
if ($AIPK_NO_LIBS == 1) then  
  printf "\n **** NO LIBRARIES ARE BEING READ IN DUE TO -nolibs switch on command line ****\n"
  endif


#-------------------------------------------------------------------------------
# SPYGLASS - control parameters
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# STAGE 1) SETUP STAGE - Create Spyglass run directories and setup files
#                - Modify project.tcl as required
#-------------------------------------------------------------------------------

if ($AIPK_READ_CLEAN == 1) then

  echo ""
  echo "NOTE: Running a clean aipk_read with the following arguments:"
  echo "$AIPK_CMN_CMD_ARGS $AIPK_SETUP_CMD_ARGS"
  echo ""
    $LSF aipk_read $AIPK_CMN_CMD_ARGS $AIPK_SETUP_CMD_ARGS  |tee ./run_spyglass_read.log
    
  # Need to remove this initial sgdc as it blocks constraints updates that will follow with the design read
     rm -rf ./sg_setup/$DESIGN/${DESIGN}.sgdc
     chmod 777 ./sg_setup/$DESIGN/*

  echo ""
  echo "NOTE: Completed setup phase "
  echo ""

endif   

if ($AIPK_READ == 1) then

 # Append required updates to options.tcl
  grep "#IPG autoadd" sg_setup/${DESIGN}/${DESIGN}_options.tcl
  if ($?) then
  echo "#IPG autoadd - Updating sg_setup/${DESIGN}/${DESIGN}_options.tcl"
    echo "#IPG autoadd"                      >> ./sg_setup/${DESIGN}/${DESIGN}_options.tcl
    echo "source ./project.tcl"              >> ./sg_setup/${DESIGN}/${DESIGN}_options.tcl
    echo "set_option enable_save_restore no" >> ./sg_setup/${DESIGN}/${DESIGN}_options.tcl

    # Enable SV if selected on the command line
    if ($AIPK_ENABLE_SV) then
      perl -p -i -e 's/#  set_option enableSV yes/  set_option enableSV yes/g' ./sg_setup/${DESIGN}/${DESIGN}_options.tcl
    endif 
    
    if ($AIPK_SGDC == 1) then
      echo "set_option sdc2sgdc no" >> ./sg_setup/${DESIGN}/${DESIGN}_options.tcl
    endif
  endif
  
  # Update project file
  grep "#IPG autoadd" sg_setup/${DESIGN}/${DESIGN}.prj
  if ($?) then
    echo "#IPG autoadd"                      >> ./sg_setup/${DESIGN}/${DESIGN}.prj
    if ($?BLACKBOXES) then
      echo "set_option stop {$BLACKBOXES}" >> ./sg_setup/${DESIGN}/${DESIGN}.prj
    endif  
  endif
    
  # Update goals_setup
  grep "#IPG autoadd" sg_setup/${DESIGN}/${DESIGN}_goals_setup.tcl
  if ($?) then
  echo "#IPG autoadd - Updating sg_setup/${DESIGN}/${DESIGN}_goals_setup.tcl" >> sg_setup/${DESIGN}/${DESIGN}_goals_setup.tcl
    perl -pi -le 'print "#IPG autoadd \
      ## Goal:cdc/cdc_setup_check #################### \
        current_goal cdc/cdc_setup_check \
        set_goal_option report {cdc_matrix} \
        set_goal_option report {Ac_sync_group_detail moresimple} \n" if $. ==10'  sg_setup/${DESIGN}/${DESIGN}_goals_setup.tcl
        
    # Only copy in updated rules for Atrenta IPKIt.  The TSMC Kit must not be changed
    if ($TSMC_KIT == 0) then
      cat  sg_setup/${DESIGN}/${DESIGN}_goals_setup.tcl $IPF_DESIGN_FLOW_SCRIPTS/spyglass/update_rules.tcl > ./temp_goals_setup.tcl
      mv ./temp_goals_setup.tcl sg_setup/${DESIGN}/${DESIGN}_goals_setup.tcl
    endif   
  endif
endif 


#-------------------------------------------------------------------------------
# STAGE 2) DESIGN and SDC READ STAGE - Creates sgdc for review
#-------------------------------------------------------------------------------

if ($AIPK_READ == 1) then
    echo ""
    echo "  Running aipk_read with the following argumants:"
    echo "   $AIPK_READ_CMD_ARGS  $AIPK_CMN_CMD_ARGS"
    echo ""
  
  $LSF aipk_read  $AIPK_READ_CMD_ARGS  $AIPK_CMN_CMD_ARGS |tee ./run_spyglass_read.log

  ##Required to append static register and ports to the SGDC
  # statics should be stored in $STATICS_FILE unless an existing SGDC is supplied
  if ($AIPK_NOSTATICS) then
      echo ""
      echo "  WARNING: Application of statics as specified by STATICS_FILE variable in setup_project.csh will not be applied "
      echo ""
  else if ($?STATICS_FILE && ($AIPK_SGDC == 1)) then
      echo ""
      echo "  WARNING: A statics file has been defined but will not be used as an existing SGDC is specified on the command line "
      echo ""
  else if ($?STATICS_FILE) then
    if (! -e $STATICS_FILE) then
      echo ""
      echo "  WARNING: A statics file has been defined but does not exist.  Please check 'STATICS_FILE' in setup_project.csh"
      echo "           Adding statics is imperative for CDC analysis and performance!"
      echo ""
    else
      if (-e sg_setup/$DESIGN/${DESIGN}.sgdc) then
          grep "#IPG autoadd" sg_setup/$DESIGN/${DESIGN}.sgdc
          if ($?) then
            echo ""
            echo "  NOTE: Using statics defined in: $STATICS_FILE"
            echo "  Adding IPG statics to sg_setup/$DESIGN/${DESIGN}.sgdc"
            echo ""
            echo "#IPG autoadd - Adding IPG statics to sg_setup/$DESIGN/${DESIGN}.sgdc" >> sg_setup/$DESIGN/${DESIGN}.sgdc
            cp sg_setup/$DESIGN/${DESIGN}.sgdc sg_setup/$DESIGN/${DESIGN}.sgdc.bak
            # Now take the statics from the statics file
            cp -r $STATICS_FILE ./static_regs_sg
            perl -p -i -e 's/^(.*)\n/quasi_static -name \"$1\"\n/g' ./static_regs_sg
            
            # Specific Ethernet hacks for statics generation in spyglass friendly format...
            perl -p -i -e 's/\//./g' ./static_regs_sg                                                 # this transforms / to .
            perl -p -i -e 's/\.(gen_[A-Za-z0-9_]+\.[A-Za-z0-9_]+)\./.\\$1 ./ig' ./static_regs_sg      # this transforms gen_{string}.{string}. to .\gen_{string}.{string} .
            perl -p -i -e 's/\.gen_/.\\gen_/ig' ./static_regs_sg                                      # this transforms .gen_ to .\gen_
            perl -p -i -e 's/(.\\gen_[A-Za-z0-9_]+).\\(gen_[A-Za-z0-9_]+)/$1.$2/ig' ./static_regs_sg  # this transforms .\gen_{string}.\gen_{string} to .\gen_{string}.gen_{string}
            
            cat  sg_setup/${DESIGN}/${DESIGN}.sgdc.bak ./static_regs_sg > ./sg_setup/${DESIGN}/${DESIGN}.sgdc.new
            rm -rf ./static_regs_sg
            mv sg_setup/$DESIGN/${DESIGN}.sgdc.new sg_setup/$DESIGN/${DESIGN}.sgdc
          endif          
      endif
    endif
  else 
    echo ""
    echo "  WARNING: No static registers defined. "
    echo "           Adding statics is imperative for CDC analysis and performance!"
    echo ""
  endif


endif 
 
 
#-------------------------------------------------------------------------------
# Stage 3) Run Spyglass 
#-------------------------------------------------------------------------------

if ($AIPK_SHOWGOALS == 1) then
  $LSF aipk_run -showgoals
else if ($AIPK_ANALYZE == 1) then
  $LSF aipk_run -top $DESIGN -gui
else if ($AIPK_RUN_GOALS == 1) then
# STAGE 3) RUN stage
  $LSF aipk_run -top $DESIGN -goal $AIPK_GOAL_LIST |tee ./${AIPK_LOG_FILE}
endif

# Pack after run completes
if ($AIPK_PACK == 1) then
  $LSF aipk_pack -top $DESIGN -report_only
  
      echo "Moving localally generated tarball to $SPYGLASS_PACK_LOCATION"
      mv *.tar.gz $SPYGLASS_PACK_LOCATION/
  
endif
