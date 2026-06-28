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
#    Primary Unit Name :      run_sims_atpg_DDR.csh.csh
#
#          Description :      Simulation runscript
#
#      Original Authors :      Anna Gilbert, Vladimir Zivkovic
#
#------------------------------------------------------------------------------
source ./setup_project.csh


set HELP0   = "\n-----------------------------------------------------------------------------------------------------------------------"
set HELP1   = "\n There are following options to run simulation:\n"
set HELP1a  = "\n\n Usage: run_sims_atpg_DDR.csh [options] \n"
set HELP2   = "  Options are:\n"
set HELP3   = "\t-h[elp]	Print this message\n"
set HELP4   = "\t-gui_p[arallel]		Interactive run with gui for parallel simulations.\n"
set HELP5   = "\t-waves_p[arallel]	Waveform input file will be created with all nets/pins included for parallel simulations.\n" 
set HELP5a  = "\t			The simulation can be time consuming, you may change the depth option.\n"
set HELP6   = "\t-gui_s[erial]		Interactive run with gui for serial simulations.\n"
set HELP7   = "\t-waves_s[erial]		Waveform input file will be created with all nets/pins included for serial simulations.\n"
set HELP7a  = "\t			The simulation can be time consuming, you may change the depth option.\n"
set HELP8   = "\t-gui_p[arallel]0	Interactive run with gui for parallel simulations with zero delay.\n"
set HELP9   = "\t-waves_p[arallel]0	Waveform input file will be created with all nets/pins included for parallel simulations with zero delay.\n" 
set HELP9a  = "\t			The simulation can be time consuming, you may change the depth option.\n"
set HELP10   = "\t-gui_s[erial]0		Interactive run with gui for serial simulations with zero delay.\n"
set HELP11   = "\t-waves_s[erial]0		Waveform input file will be created with all nets/pins included for serial simulations with zero delay.\n"
set HELP11a  = "\t			The simulation can be time consuming, you may change the depth option.\n"
set HELP12   = "\t-f[orces]		Force specific values to be applied on user specified nets/ports during all simulations.\n"
set HELP12a  = "\t			The input file is located at ./nc/support_files/force.inp and requires editing prior to simulation run.\n"
set HELP13   = "\t-zero_only		Only the zero delay simulation will be performed, in combination with other arguments, if given. \n"
set HELP14   = "\t-sdf_only		Only the sdf simulation will be performed, in combination with other arguments, if given. \n"
set HELP15  = "\t In case no options specified, the default simulation will run as in previous releases. \n"
set HELP16  = "\n\t WARNING: Switches should not be used unless necessary.\n"

set HELP="${HELP0}${HELP1}${HELP1a}\n"
set HELPEXT="$HELP2$HELP3$HELP4${HELP5}${HELP5a}${HELP6}${HELP7}${HELP7a}${HELP8}$HELP9${HELP9a}${HELP10}${HELP11}${HELP11a}${HELP12}${HELP12a}${HELP13}${HELP14}${HELP15}\n"
set HELPWARNING = "${HELP16}"

set ARGCOUNT   = 1
set ARGS       = $#argv

set GUI_S = 0
set WAVES_S = 0
set GUI_S0 = 0
set WAVES_S0 = 0
set FORCES = 0
set GUI_P = 0
set WAVES_P = 0
set GUI_P0 = 0
set WAVES_P0 = 0
set ZERO_SIM = 1
set SDF_SIM = 1

cp $IPF_DESIGN_FLOW_SCRIPTS/nc/run_FULLSCAN_sdf_sim.tcl $IPF_DESIGN_FLOW_SCRIPTS/nc/local_SDF.tcl
cp $IPF_DESIGN_FLOW_SCRIPTS/nc/run_FULLSCAN_sim.tcl $IPF_DESIGN_FLOW_SCRIPTS/nc/local.tcl
set RUNSIM_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/local_SDF.tcl
set RUNSIM = $IPF_DESIGN_FLOW_SCRIPTS/nc/local.tcl

set NCSIM_INPUT_PAR_SHIFT = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_parallel.inp
set NCSIM_INPUT_SER_SHIFT = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_serial.inp
set NCSIM_INPUT_PAR_SHIFT_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_parallel_sdf.inp
set NCSIM_INPUT_SER_SHIFT_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_serial_sdf.inp

set NCSIM_INPUT_PAR_STUCKAT = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_parallel.inp
set NCSIM_INPUT_SER_STUCKAT = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_serial.inp
set NCSIM_INPUT_PAR_STUCKAT_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_parallel_sdf.inp
set NCSIM_INPUT_SER_STUCKAT_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_serial_sdf.inp

set NCSIM_INPUT_PAR_ATSPEED = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_parallel.inp
set NCSIM_INPUT_SER_ATSPEED = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_serial.inp
set NCSIM_INPUT_PAR_ATSPEED_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_parallel_sdf.inp
set NCSIM_INPUT_SER_ATSPEED_SDF = $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_serial_sdf.inp


printf "" >> $NCSIM_INPUT_PAR_SHIFT
printf "" >> $NCSIM_INPUT_SER_SHIFT
printf "" >> $NCSIM_INPUT_PAR_SHIFT_SDF
printf "" >> $NCSIM_INPUT_SER_SHIFT_SDF

printf "" >> $NCSIM_INPUT_PAR_STUCKAT
printf "" >> $NCSIM_INPUT_SER_STUCKAT
printf "" >> $NCSIM_INPUT_PAR_STUCKAT_SDF
printf "" >> $NCSIM_INPUT_SER_STUCKAT_SDF

printf "" >> $NCSIM_INPUT_PAR_ATSPEED
printf "" >> $NCSIM_INPUT_SER_ATSPEED
printf "" >> $NCSIM_INPUT_PAR_ATSPEED_SDF
printf "" >> $NCSIM_INPUT_SER_ATSPEED_SDF


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

   case "-gui_s":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_S = 1 
       breaksw
       
   case "-gui_serial":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_S = 1 
       breaksw      
   
   case "-gui_p":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_P = 1 
       breaksw
       
   case "-gui_parallel":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_P = 1 
       breaksw
    
   case "-waves_s":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_S = 1
       breaksw  

   case "-waves_serial":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_S = 1
       breaksw

   case "-waves_p":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_P = 1
       breaksw  

   case "-waves_parallel":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_P = 1
       breaksw

   case "-gui_s0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_S0 = 1 
       breaksw
       
   case "-gui_serial0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_S0 = 1 
       breaksw      
   
   case "-gui_p0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_P0 = 1 
       breaksw
       
   case "-gui_parallel0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set GUI_P0 = 1 
       breaksw
    
   case "-waves_s0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_S0 = 1
       breaksw  

   case "-waves_serial0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_S0 = 1
       breaksw

   case "-waves_p0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_P0 = 1
       breaksw  

   case "-waves_parallel0":
       @ ARGCOUNT = $ARGCOUNT + 1
       set WAVES_P0 = 1
       breaksw

   case "-forces":
       @ ARGCOUNT = $ARGCOUNT + 1
       set FORCES = 1
       breaksw
       
   case "-f":
       @ ARGCOUNT = $ARGCOUNT + 1
       set FORCES = 1
       breaksw

   case "-zero_only":
       @ ARGCOUNT = $ARGCOUNT + 1
       set SDF_SIM = 0
       breaksw   

   case "-sdf_only":
       @ ARGCOUNT = $ARGCOUNT + 1
       set ZERO_SIM = 0
       breaksw   
       
   default:
       printf "\nError : Incorrect argument\n $HELPEXT"
       exit 1

   endsw
   
end         

printf "\nARGS : $ARGS\n" >> file
printf "GUI_P : $GUI_P\n"
printf "WAVES_P : $WAVES_P\n"
printf "GUI_S : $GUI_S\n"
printf "WAVES_S : $WAVES_S\n"
printf "FORCES : $FORCES\n"
printf "GUI_P0 : $GUI_P\n"
printf "WAVES_P0 : $WAVES_P0\n"
printf "GUI_S0 : $GUI_S0\n"
printf "WAVES_S0 : $WAVES_S0\n"
printf "ZERO_SIM : $ZERO_SIM\n"
printf "SDF_SIM : $SDF_SIM\n"


if ($GUI_P == 1) then
 perl -p -i -e "s/_parallel \\/_parallel \\\n\t\t-gui \\/g" $RUNSIM_SDF
endif

if ($GUI_S == 1) then  
 perl -p -i -e "s/_serial \\/_serial \\\n\t\t-gui \\/g" $RUNSIM_SDF
endif

if ($GUI_P0 == 1) then
 perl -p -i -e "s/_parallel -/_parallel -gui -/g" $RUNSIM
endif

if ($GUI_S0 == 1) then  
 perl -p -i -e "s/_serial -/_serial -gui -/g" $RUNSIM
endif


if ($WAVES_P == 1) then 

 perl -p -i -e 's#_parallel \\#_parallel \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_parallel_sdf.inp \\#g' $RUNSIM_SDF

 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_parallel_sdf.inp
 printf "database -open waves_parallel_shift_sdf -into waves_parallel_shift_sdf.shm -default\n" >> $NCSIM_INPUT_PAR_SHIFT_SDF
 printf "probe -create -shm -all -depth all -database waves_parallel_shift_sdf\n" >> $NCSIM_INPUT_PAR_SHIFT_SDF
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_parallel_sdf.inp
 printf "database -open waves_parallel_stuckat_sdf -into waves_parallel_stuckat_sdf.shm -default\n" >> $NCSIM_INPUT_PAR_STUCKAT_SDF
 printf "probe -create -shm -all -depth all -database waves_parallel_stuckat_sdf\n" >> $NCSIM_INPUT_PAR_STUCKAT_SDF
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_parallel_sdf.inp
 printf "database -open waves_parallel_atspeed_sdf -into waves_parallel_atspeed_sdf.shm -default\n" >> $NCSIM_INPUT_PAR_ATSPEED_SDF
 printf "probe -create -shm -all -depth all -database waves_parallel_atspeed_sdf\n" >> $NCSIM_INPUT_PAR_ATSPEED_SDF
 
endif

if ($WAVES_S == 1) then  
 perl -p -i -e 's#_serial \\#_serial \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_serial_sdf.inp \\#g' $RUNSIM_SDF

 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_serial_sdf.inp
 printf "database -open waves_serial_shift_sdf -into waves_serial_shift_sdf.shm -default\n" >> $NCSIM_INPUT_SER_SHIFT_SDF
 printf "probe -create -shm -all -depth all -database waves_serial_shift_sdf\n" >> $NCSIM_INPUT_SER_SHIFT_SDF
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_serial_sdf.inp
 printf "database -open waves_serial_stuckat_sdf -into waves_serial_stuckat_sdf.shm -default\n" >> $NCSIM_INPUT_SER_STUCKAT_SDF
 printf "probe -create -shm -all -depth all -database waves_serial_stuckat_sdf\n" >> $NCSIM_INPUT_SER_STUCKAT_SDF
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_serial_sdf.inp
 printf "database -open waves_serial_atspeed_sdf -into waves_serial_atspeed_sdf.shm -default\n" >> $NCSIM_INPUT_SER_ATSPEED_SDF
 printf "probe -create -shm -all -depth all -database waves_serial_atspeed_sdf\n" >> $NCSIM_INPUT_SER_ATSPEED_SDF

endif

if ($WAVES_P0 == 1) then 

 perl -p -i -e 's#_parallel -gateloopwarn \\#_parallel -gateloopwarn \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_parallel.inp \\#g' $RUNSIM

 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_parallel.inp
 printf "database -open waves_parallel_shift -into waves_parallel_shift.shm -default\n" >> $NCSIM_INPUT_PAR_SHIFT
 printf "probe -create -shm -all -depth all -database waves_parallel_shift\n" >> $NCSIM_INPUT_PAR_SHIFT
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_parallel.inp
 printf "database -open waves_parallel_stuckat -into waves_parallel_stuckat.shm -default\n" >> $NCSIM_INPUT_PAR_STUCKAT
 printf "probe -create -shm -all -depth all -database waves_parallel_stuckat\n" >> $NCSIM_INPUT_PAR_STUCKAT
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_parallel.inp
 printf "database -open waves_parallel_atspeed -into waves_parallel_atspeed.shm -default\n" >> $NCSIM_INPUT_PAR_ATSPEED
 printf "probe -create -shm -all -depth all -database waves_parallel_atspeed\n" >> $NCSIM_INPUT_PAR_ATSPEED
 
endif

if ($WAVES_S0 == 1) then  
 perl -p -i -e 's#_serial -gateloopwarn \\#_serial -gateloopwarn \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_serial.inp \\#g' $RUNSIM
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_scan_ex1_ts1_verilog_serial.inp
 printf "database -open waves_serial_shift -into waves_serial_shift.shm -default\n" >> $NCSIM_INPUT_SER_SHIFT
 printf "probe -create -shm -all -depth all -database waves_serial_shift\n" >> $NCSIM_INPUT_SER_SHIFT
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex2_ts1_verilog_serial.inp
 printf "database -open waves_serial_stuckat -into waves_serial_stuckat.shm -default\n" >> $NCSIM_INPUT_SER_STUCKAT
 printf "probe -create -shm -all -depth all -database waves_serial_stuckat\n" >> $NCSIM_INPUT_SER_STUCKAT
 
 printf "#Specify here the database creation\n" >> ${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/FULLSCAN_data_logic_ex3_ts1_verilog_serial.inp
 printf "database -open waves_serial_atspeed -into waves_serial_atspeed.shm -default\n" >> $NCSIM_INPUT_SER_ATSPEED
 printf "probe -create -shm -all -depth all -database waves_serial_atspeed\n" >> $NCSIM_INPUT_SER_ATSPEED

endif


if ($FORCES == 1) then  
  if($WAVES_P == 0) then 
    perl -p -i -e 's#_parallel \\#_parallel \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_parallel_sdf.inp \\#g' $RUNSIM_SDF
  endif
  if($WAVES_P0 == 0) then
    perl -p -i -e 's#_parallel -gateloopwarn \\#_parallel -gateloopwarn \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_parallel.inp \\#g' $RUNSIM
  endif

  if($SDF_SIM == 1) then
    cat $NCSIM_INPUT_PAR_SHIFT_SDF $FORCEFILE > $NCSIM_INPUT_PAR_SHIFT_SDF.new
    mv  $NCSIM_INPUT_PAR_SHIFT_SDF.new $NCSIM_INPUT_PAR_SHIFT_SDF
    cat $NCSIM_INPUT_PAR_STUCKAT_SDF $FORCEFILE > $NCSIM_INPUT_PAR_STUCKAT_SDF.new
    mv  $NCSIM_INPUT_PAR_STUCKAT_SDF.new $NCSIM_INPUT_PAR_STUCKAT_SDF
    cat $NCSIM_INPUT_PAR_ATSPEED_SDF $FORCEFILE > $NCSIM_INPUT_PAR_ATSPEED_SDF.new
    mv  $NCSIM_INPUT_PAR_ATSPEED_SDF.new $NCSIM_INPUT_PAR_ATSPEED_SDF
  endif
  
  if($ZERO_SIM == 1) then 
    cat $NCSIM_INPUT_PAR_SHIFT $FORCEFILE > $NCSIM_INPUT_PAR_SHIFT.new
    mv  $NCSIM_INPUT_PAR_SHIFT.new $NCSIM_INPUT_PAR_SHIFT  
    cat $NCSIM_INPUT_PAR_STUCKAT $FORCEFILE > $NCSIM_INPUT_PAR_STUCKAT.new
    mv  $NCSIM_INPUT_PAR_STUCKAT.new $NCSIM_INPUT_PAR_STUCKAT  
    cat $NCSIM_INPUT_PAR_ATSPEED $FORCEFILE > $NCSIM_INPUT_PAR_ATSPEED.new
    mv  $NCSIM_INPUT_PAR_ATSPEED.new $NCSIM_INPUT_PAR_ATSPEED
  endif

endif

if ($FORCES == 1) then
  if($WAVES_S == 0) then  
    perl -p -i -e 's#_serial \\#_serial \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_serial_sdf.inp \\#g' $RUNSIM_SDF
  endif
  if($WAVES_S0 == 0) then  
    perl -p -i -e 's#_serial -gateloopwarn \\#_serial -gateloopwarn \\\n\t\t -input \${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/\${testname}_serial.inp \\#g' $RUNSIM
  endif
  
  if($SDF_SIM == 1) then
    cat $NCSIM_INPUT_SER_SHIFT_SDF $FORCEFILE > $NCSIM_INPUT_SER_SHIFT_SDF.new
    mv  $NCSIM_INPUT_SER_SHIFT_SDF.new $NCSIM_INPUT_SER_SHIFT_SDF
    cat $NCSIM_INPUT_SER_STUCKAT_SDF $FORCEFILE > $NCSIM_INPUT_SER_STUCKAT_SDF.new
    mv  $NCSIM_INPUT_SER_STUCKAT_SDF.new $NCSIM_INPUT_SER_STUCKAT_SDF
    cat $NCSIM_INPUT_SER_ATSPEED_SDF $FORCEFILE > $NCSIM_INPUT_SER_ATSPEED_SDF.new
    mv  $NCSIM_INPUT_SER_ATSPEED_SDF.new $NCSIM_INPUT_SER_ATSPEED_SDF
  endif
  
  if($ZERO_SIM == 1) then
    cat $NCSIM_INPUT_SER_SHIFT $FORCEFILE > $NCSIM_INPUT_SER_SHIFT.new
    mv  $NCSIM_INPUT_SER_SHIFT.new $NCSIM_INPUT_SER_SHIFT
    cat $NCSIM_INPUT_SER_STUCKAT $FORCEFILE > $NCSIM_INPUT_SER_STUCKAT.new
    mv  $NCSIM_INPUT_SER_STUCKAT.new $NCSIM_INPUT_SER_STUCKAT 
    cat $NCSIM_INPUT_SER_ATSPEED $FORCEFILE > $NCSIM_INPUT_SER_ATSPEED.new
    mv  $NCSIM_INPUT_SER_ATSPEED.new $NCSIM_INPUT_SER_ATSPEED
  endif
  
endif

if ( ($FORCES == 1) || ($WAVES_S == 1) )then
 printf "run" >>  $NCSIM_INPUT_SER_SHIFT_SDF
 printf "run" >>  $NCSIM_INPUT_SER_STUCKAT_SDF
 printf "run" >>  $NCSIM_INPUT_SER_ATSPEED_SDF
endif 

if ( ($FORCES == 1) || ($WAVES_S0 == 1) )then
 printf "run" >>  $NCSIM_INPUT_SER_SHIFT
 printf "run" >>  $NCSIM_INPUT_SER_STUCKAT
 printf "run" >>  $NCSIM_INPUT_SER_ATSPEED

endif 

if ( ($FORCES == 1) || ($WAVES_P == 1) )then
 printf "run" >>  $NCSIM_INPUT_PAR_SHIFT_SDF
 printf "run" >>  $NCSIM_INPUT_PAR_STUCKAT_SDF
 printf "run" >>  $NCSIM_INPUT_PAR_ATSPEED_SDF

endif 

if ( ($FORCES == 1) || ($WAVES_P0 == 1) )then
 printf "run" >>  $NCSIM_INPUT_PAR_SHIFT
 printf "run" >>  $NCSIM_INPUT_PAR_STUCKAT
 printf "run" >>  $NCSIM_INPUT_PAR_ATSPEED

endif 
 
if ( (($FORCES == 1) || ($WAVES_P0 == 1) || ($WAVES_S0 == 1) || ($GUI_S0 == 1) || ($GUI_P0 == 1)) && ($ZERO_SIM == 1) )then
    echo "running zero delay simulation with arguments"
    $LSF wish $RUNSIM
else
  if ($ZERO_SIM == 1) then
    echo "running zero delay simulation without arguments"
    echo "here\n"
    printf "ZERO_SIM second time : $ZERO_SIM\n"
    $LSF wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_FULLSCAN_sim.tcl 
  endif   
endif
 
if ( (($FORCES == 1) || ($WAVES_P == 1) || ($WAVES_S == 1) || ($GUI_S == 1) || ($GUI_P == 1)) && ($SDF_SIM == 1) )then
    echo "running sdf simulation with arguments"
    $LSF wish $RUNSIM_SDF
else
  if ($SDF_SIM == 1) then
    echo "running sdf simulation without arguments"
    $LSF wish $IPF_DESIGN_FLOW_SCRIPTS/nc/run_FULLSCAN_sdf_sim.tcl 
  endif
endif


rm -rf $IPF_DESIGN_FLOW_SCRIPTS/nc/local_SDF.tcl
rm -rf $IPF_DESIGN_FLOW_SCRIPTS/nc/local.tcl

rm -rf $NCSIM_INPUT_PAR_SHIFT
rm -rf $NCSIM_INPUT_SER_SHIFT
rm -rf $NCSIM_INPUT_PAR_SHIFT_SDF
rm -rf $NCSIM_INPUT_SER_SHIFT_SDF

rm -rf $NCSIM_INPUT_PAR_STUCKAT
rm -rf $NCSIM_INPUT_SER_STUCKAT
rm -rf $NCSIM_INPUT_PAR_STUCKAT_SDF
rm -rf $NCSIM_INPUT_SER_STUCKAT_SDF

rm -rf $NCSIM_INPUT_PAR_ATSPEED
rm -rf $NCSIM_INPUT_SER_ATSPEED
rm -rf $NCSIM_INPUT_PAR_ATSPEED_SDF
rm -rf $NCSIM_INPUT_SER_ATSPEED_SDF
