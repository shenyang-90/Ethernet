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
#    Primary Unit Name :      run_sims_atpg.csh
#
#          Description :      Simulation runscript
#
#      Original Authors :      Vladimir Zivkovic
#
#
#------------------------------------------------------------------------------
source ./setup_project.csh


set HELP0   = "\n-----------------------------------------------------------------------------------------------------------------------"
set HELP1   = "\n There are following options to run distributed simulation:\n"
set HELP1a  = "\n\n Usage: run_sims_atpg.csh [options] \n"
set HELP2   = "  Options are:\n"
set HELP3   = "\t-h[elp]	Print this message\n"
set HELP12   = "\t-f[orces]		Force specific values to be applied on user specified nets/ports during all simulations.\n"
set HELP12a  = "\t			The input file is located at ./nc/support_files/force.inp and requires editing prior to simulation run.\n"
set HELP14   = "\t-sdf_only		Only the sdf simulation will be performed, in combination with other arguments, if given. \n"
set HELP15   = "\t-other_args <filename>  An option to give additional arguments to irun, captured in <filename> file. \n"
set HELP15a  = "\t			The format must conform to irun syntax. ONLY FOR ADVANCED USERS! \n\n"
set HELP16  = "\t In case no options specified, the default simulation will run as in previous releases."
set HELP17  = "\n\t WARNING: Switches should not be used unless necessary.\n"

set HELP="${HELP0}${HELP1}${HELP1a}\n"
set HELPEXT="$HELP2${HELP12}${HELP12a}${HELP13}${HELP14}${HELP15}${HELP15a}${HELP16}\n"
set HELPWARNING = "${HELP17}"

set ARGCOUNT   = 1
set ARGS       = $#argv

set ZERO_SIM = 1
set SDF_SIM = 1
set OTHER_ARGUMENTS = 0


cp $IPF_DESIGN_FLOW_SCRIPTS/nc/run_sdf_sim.tcl $IPF_DESIGN_FLOW_SCRIPTS/nc/local_SDF.tcl
set RUNSIM_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/local_SDF.tcl

set FORCEFILE = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/force.inp

while ($ARGCOUNT <= $ARGS)

   switch($argv[$ARGCOUNT])
        
   # print help information
   case "-h":
       printf "$HELP"
       printf "$HELPEXT"
       printf "$HELPWARNING"
       exit 0

   case "-help":
       printf "$HELP"
       printf "$HELPEXT"
       printf "$HELPWARNING"
       exit 0

   case "-sdf_only":
       @ ARGCOUNT = $ARGCOUNT + 1
       set ZERO_SIM = 0
       breaksw   
       
   case "-forces":
       @ ARGCOUNT = $ARGCOUNT + 1
       set FORCES = 1
       breaksw
       
   case "-f":
       @ ARGCOUNT = $ARGCOUNT + 1
       set FORCES = 1
       breaksw

    case "-other_args":
       @ ARGCOUNT = $ARGCOUNT + 1
       set OTHER_ARGUMENTS = 1
       set OTHER_ARGUMENTS_FILE = "$argv[$ARGCOUNT]"
       @ ARGCOUNT = $ARGCOUNT + 1
       breaksw   

       
   default:
       printf "\nError : Incorrect argument\n $HELPEXT"
       exit 1

   endsw
   
end         

printf "ZERO_SIM : $ZERO_SIM\n"
printf "SDF_SIM : $SDF_SIM\n"
printf "FORCES : $FORCES\n"
\rm -rf local_parallel
\rm -rf local_serial
\rm -rf corner.tmp
\rm -rf $LOG_PATH/nc/$STAMP/data_${CONFIG}/*

 
if ($OTHER_ARGUMENTS == 1) then
   cp $OTHER_ARGUMENTS_FILE $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/other_arguments
endif
 
 
 $LSF wish $IPF_DESIGN_FLOW_SCRIPTS/nc/create_snapshot.tcl
 mkdir local_parallel
 mkdir local_serial
 echo $LOG_PATH/dft/${STAMP}/data_${CONFIG}/
 cp $LOG_PATH/dft/${STAMP}/data_${CONFIG}/parallel/*.gz local_parallel/
 gunzip local_parallel/*.gz
 cp $LOG_PATH/dft/${STAMP}/data_${CONFIG}/serial/*.gz local_serial/
 gunzip local_serial/*.gz
  
 setenv CORNER ""
 foreach line (`cat corners.tmp`)
   unsetenv CORNER
   setenv CORNER $line
   printf "Corner = $CORNER\n"
   setenv datafile ""
   setenv DM ""
   if ($SDF_SIM == 1) then
      echo "running sdf simulation without arguments\n" 
      foreach mode ($DESIGN_MODES)
        unsetenv DM
        setenv DM $mode
        echo "          $DM"   
	foreach file (local_serial/*.verilog)
          unsetenv datafile
          setenv datafile $file
          echo "          $datafile"
	  if ( ($DM == 'scan') || ($DM == 'func') ) then
          $LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	  else
	    if ( ($DM == 'shift') || ($DM == 'scan_shift') ) then
	      if ($datafile =~ *scan.ex1*) then
		$LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	      endif
	    endif
	    if ( ($DM == 'stuck_at') || ($DM == 'stuckat') || ($DM == 'capture') || ($DM == 'scan_capture') || ($DM == 'scan_shift') ) then
	      if ($datafile =~ *FULLSCAN*logic.ex2*) then
		$LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	      endif
	    endif
	    if ( ($DM == 'at_speed') || ($DM == 'atspeed') || ($DM == 'scan_atspeed') ) then
	      if ($datafile =~ *DELAY*logic.ex2*) then
		$LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	      endif
	    endif
	  endif  
        end
      
	foreach file (local_parallel/*.verilog)
          unsetenv datafile
          setenv datafile $file
          echo "          $datafile"
	  if ( ($DM == 'scan') || ($DM == 'func') ) then
          $LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	  else
	    if ( ($DM == 'shift') || ($DM == 'scan_shift') ) then
	      if ($datafile =~ *scan.ex1*) then
		$LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	      endif
	    endif
	    if ( ($DM == 'stuck_at') || ($DM == 'stuckat') || ($DM == 'capture') || ($DM == 'scan_capture') || ($DM == 'scan_shift') ) then
	      if ($datafile =~ *logic.ex2*) then
		$LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	      endif
	    endif
	    if ( ($DM == 'at_speed') || ($DM == 'atspeed') || ($DM == 'scan_atspeed') ) then
	      if ($datafile =~ *logic.ex3*) then
		$LSF_DIST wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_distributed_FULLSCAN_sim.tcl
	      endif
	    endif
	  endif  
        end
	
      end
   endif
 end
  

if ($OTHER_ARGUMENTS == 1) then
  rm  $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/other_arguments
endif

\rm -rf local_parallel
\rm -rf local_serial
\rm -rf corner.tmp
unset CORNER
unset datafile
unset DM
