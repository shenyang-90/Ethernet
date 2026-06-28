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
#    Primary Unit Name :      run_phys.csh
#
#          Description :      Physical runscript
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

set HELP1   = "\nUsage: run_phys.csh [options] \n\n"
set HELP2   = "Options are:-\n"
set HELP3   = "\t-h[elp]            	Print this message\n"
set HELP4   = "\t-synth_genus       	Runs synth step using Genus\n"
set HELP4a  = "\t-synth_genus_legacy	Runs synth step using Genus in legacy mode\n"
set HELP5   = "\t-lec_1stage        	Runs 1 stage LEC step\n"
set HELP6   = "\t-lec_2stage        	Runs 2 stage LEC step\n"
set HELP6a  = "\t-lec_syn2pnr       	Runs synth to pnr netlist LEC check\n"
set HELP7   = "\t-pnr               	Runs PNR step\n"
set HELP8   = "By default only synthesis with Genus is run\n"

set HELP="${HELP1}$HELP2$HELP3$HELP4$HELP4a$HELP5$HELP6$HELP6a$HELP7$HELP8\n"

set ARGCOUNT   = 1
set ARGS       = $#argv

if ($ARGS == 0) then
  set RUN_SYNTH_GNS 	      = 1
  set RUN_SYNTH_GNS_LEGACY    = 0
  set RUN_LEC_1STAGE   	= 0
  set RUN_LEC_2STAGE   	= 0
  set RUN_PNR         	= 0
  set RUN_LEC_SYN2PNR  	= 0
else
  set RUN_SYNTH_GNS 	      = 0
  set RUN_SYNTH_GNS_LEGACY    = 0
   set RUN_LEC_1STAGE   	= 0
  set RUN_LEC_2STAGE   	= 0
  set RUN_PNR   	      = 0
  set RUN_LEC_SYN2PNR  	= 0

  while ($ARGCOUNT <= $ARGS)
  
    switch($argv[$ARGCOUNT])
          
      # print help information
      case "-h":
          printf "$HELP"
          exit 0
      
      case "-help":
          printf "$HELP"
          exit 0

      case "-synth_genus":
          set RUN_SYNTH_GNS = 1 
          breaksw

      case "-synth_genus_legacy":
          set RUN_SYNTH_GNS_LEGACY = 1 
          breaksw
	  
      case "-lec_1stage":
          set RUN_LEC_1STAGE = 1 
          breaksw

      case "-lec_2stage":
          set RUN_LEC_2STAGE = 1 
          breaksw

      case "-lec_syn2pnr":
          set RUN_LEC_SYN2PNR = 1
          breaksw
	            
      case "-pnr":
          set RUN_PNR = 1 
          breaksw

      default:
          printf "\nError : Incorrect argument\n $HELP"
          exit 1
      
    endsw
    @ ARGCOUNT = $ARGCOUNT + 1
  end
endif

printf "\n\tRUNNING the following steps:"
if ($RUN_SYNTH_GNS == 1) then 
  printf "\n\t\tSynth using Genus"
endif
if ($RUN_SYNTH_GNS_LEGACY == 1) then 
  printf "\n\t\tSynth using Genus in legacy mode"
endif
if ($RUN_LEC_1STAGE == 1) then 
  printf "\n\t\tLEC_1STAGE"
endif
if ($RUN_LEC_2STAGE == 1) then 
  printf "\n\t\tLEC_2STAGE"
endif
if ($RUN_PNR == 1) then 
  printf "\n\t\tPNR"
endif
if ($RUN_LEC_SYN2PNR == 1) then 
  printf "\n\t\tLEC_SYN2PNR"
endif
printf "\n\n"


# Need to know the path where the LEC dofiels where created (from setup_dirs.tcl)
 setenv OUTPUTS_PATH `echo "source ./project.tcl; source $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_dirs.tcl;" 'puts $_OUTPUTS_PATH' | tclsh`


  ## Generate new library list  if it doesnt exist - required for lec_g2g
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

if ($RUN_SYNTH_GNS == 1 ) then 
	if (( $?LSF ))  then
		if( "$LSF" != "") then
  			set tds = `date +"%Y%m%d_%H%M%S"`
  			$LSF -J "synth_$tds" genus -files $IPF_DESIGN_FLOW_SCRIPTS/genus/genus_synth.tcl -no_gui
  			$LSF -w "synth_$tds" source $IPF_DESIGN_FLOW_SCRIPTS/genus/lec_replace_dofile.csh
  			if ($? != 0) then
   				echo ""
    			echo " ERRORS detected review logs and rerun "
    			exit 1
			endif
		else
			genus -files $IPF_DESIGN_FLOW_SCRIPTS/genus/genus_synth.tcl -no_gui
  			source $IPF_DESIGN_FLOW_SCRIPTS/genus/lec_replace_dofile.csh
  			if ($? != 0) then
    				echo ""
    				echo " ERRORS detected review logs and rerun "
    				exit 1
  			endif
		endif
	else 
 		genus -files $IPF_DESIGN_FLOW_SCRIPTS/genus/genus_synth.tcl -no_gui
  		source $IPF_DESIGN_FLOW_SCRIPTS/genus/lec_replace_dofile.csh
  		if ($? != 0) then
    			echo ""
    			echo " ERRORS detected review logs and rerun "
    			exit 1
  		endif
	endif 
endif

if ($RUN_SYNTH_GNS_LEGACY == 1 ) then 
	if (( $?LSF ))  then
		if( "$LSF" != "") then
  			set tds = `date +"%Y%m%d_%H%M%S"`
  			$LSF -J "synth_$tds" genus -legacy_ui -files $IPF_DESIGN_FLOW_SCRIPTS/rc/rc_flow.tcl -nogui
  			$LSF -w "synth_$tds" source $IPF_DESIGN_FLOW_SCRIPTS/rc/lec_replace_dofile.csh
  			if ($? != 0) then
   				echo ""
    			echo " ERRORS detected review logs and rerun "
    			exit 1
			endif
		else
			genus -legacy_ui -files $IPF_DESIGN_FLOW_SCRIPTS/rc/rc_flow.tcl -nogui
  			source $IPF_DESIGN_FLOW_SCRIPTS/rc/lec_replace_dofile.csh
  			if ($? != 0) then
    				echo ""
    				echo " ERRORS detected review logs and rerun "
    				exit 1
  			endif
		endif
	else 
 		genus -legacy_ui -files $IPF_DESIGN_FLOW_SCRIPTS/rc/rc_flow.tcl -nogui
  		source $IPF_DESIGN_FLOW_SCRIPTS/rc/lec_replace_dofile.csh
  		if ($? != 0) then
    			echo ""
    			echo " ERRORS detected review logs and rerun "
    			exit 1
  		endif
	endif 
endif


if ($RUN_LEC_1STAGE == 1) then 
  $LSF lec -lpxl -dofile $OUTPUTS_PATH/rtl2final.lec.do -nogui
endif

if ($RUN_LEC_2STAGE == 1) then 
  $LSF lec -lpxl -dofile $OUTPUTS_PATH/rtl2mapped.lec.do -nogui

  $LSF lec -lpxl -dofile $OUTPUTS_PATH/map2final.lec.do -nogui
endif

if ($RUN_PNR == 1) then 
	if (( $?LSF )) then
		if ( "$LSF" != "") then 
  			set tds = `date +"%Y%m%d_%H%M%S"`
  			$LSF -J "place_$tds" innovus -common_ui -init $IPF_DESIGN_FLOW_SCRIPTS/innovus/innovus_place.tcl -no_gui -no_logv
  			$LSF -J "ccopt_$tds" -w "done(place_$tds)" innovus -common_ui -init $IPF_DESIGN_FLOW_SCRIPTS/innovus/innovus_ccopt.tcl -no_gui -no_logv    
  			if ($? != 0) then
    				echo ""
    				echo " ERRORS detected review logs and rerun "
    				exit 1
  			endif
		else
			innovus -common_ui -init $IPF_DESIGN_FLOW_SCRIPTS/innovus/innovus_place.tcl -no_gui -no_logv
  			innovus -common_ui -init $IPF_DESIGN_FLOW_SCRIPTS/innovus/innovus_ccopt.tcl -no_gui -no_logv    
  			if ($? != 0) then
    				echo ""
    				echo " ERRORS detected review logs and rerun "
    				exit 1
			endif
		endif
	else
  		innovus -common_ui -init $IPF_DESIGN_FLOW_SCRIPTS/innovus/innovus_place.tcl -no_gui -no_logv
  		innovus -common_ui -init $IPF_DESIGN_FLOW_SCRIPTS/innovus/innovus_ccopt.tcl -no_gui -no_logv    
  		if ($? != 0) then
    			echo ""
    			echo " ERRORS detected review logs and rerun "
    			exit 1
		endif
	endif		
endif

if ($RUN_LEC_SYN2PNR == 1) then 
  $LSF lec -lpxl -dofile $IPF_DESIGN_FLOW_SCRIPTS/lec/lec_gate2gate.do -nogui
  if ($? != 0) then
    echo ""
    echo " ERRORS detected review logs and rerun "
    exit 1
  endif
endif
