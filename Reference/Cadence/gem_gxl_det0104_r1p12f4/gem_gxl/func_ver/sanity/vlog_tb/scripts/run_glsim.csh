#!/bin/csh

source ./setup_project.csh
setenv VFILE `echo 'source $env(IPF_DESIGN_FLOW_SCRIPTS)/tech_lib_setup.tcl; puts $VFILE' | tclsh`	
setenv pow_stat `perl -ne 'print $1 if /POWER_STATES\s{(.*)}/' ./project.tcl`

# replace ./$DESIGN.f with the netlist
rm -rf $DESIGN.f
echo "$MODULE_PATH/pnr/$STAMP/data_$CONFIG/$DESIGN.postccoptincr.v" >  $DESIGN.f

echo Compiling SDF ...
ncsdfc $MODULE_PATH/pnr/$STAMP/data_$CONFIG/$DESIGN.postccoptincr_func.sdf -output ./sdf.X -append_log -logfile ncsdfc.log

echo Creating SDF Commandfile ...
echo 'COMPILED_sdf_file = "sdf.X",LOG_FILE = "sdf.log", SCOPE = 'tb_${DESIGN}\:i_$DESIGN\; > sdf_cmd_file

set SYNTH_RPT_PATH = `echo 'source ./project.tcl; puts $_REPORTS_PATH' | tclsh`
grep "meta_reg" $SYNTH_RPT_PATH/{$DESIGN}.dft_chainRegs > {$DESIGN}_tfile.txt
perl -p -i -e 's/.*\sPASS\;.*\n//g' {$DESIGN}_tfile.txt
perl -p -i -e 's/\//\./g' {$DESIGN}_tfile.txt
perl -p -i -e "s/^\s+(i_.*\.)(.*meta_reg\[.*\])/PATH tb_$DESIGN\.i_$DESIGN\.\1\\\2 -tcheck/g" {$DESIGN}_tfile.txt

set EXTRA_ARGS = "-access +rwc -ALLOWREDEFINITION -nowarn RECOME -nowarn NTCNNC -nowarn SDFNCAP -define RECREM -define NTC -nontcglitch -tfile ./{$DESIGN}_tfile.txt -SDF_CMD_FILE sdf_cmd_file"
if ($WAVES == 0) then
  set POWER_START_TIME = 100
  #set POWER_STOP_TIME = 200000
  set POWER_STOP_TIME = 100000
  echo "database -default -shm $DESIGN -into waves.shm;" > saif_gen.tcl
  echo "probe tb_gem -all -depth all -shm;" >> saif_gen.tcl
  echo "probe tb_gem -ports -depth all -shm" >> saif_gen.tcl
  echo run $POWER_START_TIME ns >> saif_gen.tcl
  echo dumpsaif -hierarchy -overwrite -output $DESIGN.saif -scope i_$DESIGN >> saif_gen.tcl
  echo run -absolute $POWER_STOP_TIME ns >> saif_gen.tcl
  echo dumpsaif -end >> saif_gen.tcl
  echo run >> saif_gen.tcl
  echo database -close $DESIGN >> saif_gen.tcl
  set EXTRA_ARGS = "$EXTRA_ARGS -input saif_gen.tcl"
endif

echo Compiling Netlist and Testbench ...
set IRUN_CMD = "irun -F $DIRECTED_TB_PATH/src/tb_${DESIGN}.f $VFILE -incdir $DIRECTED_TB_PATH/src/ -define GLSIM $IRUN_ARGS $EXTRA_ARGS $DELAYS"
echo Running IRUN with command ...
echo $IRUN_CMD
$IRUN_CMD

if ($WAVES == 0) then
  echo Analyzing for Power ...
  rm -rf $NL_TOGGLE_FILE_DIR
  mkdir $NL_TOGGLE_FILE_DIR
  mkdir $NL_TOGGLE_FILE_DIR/$pow_stat
  cp ${DESIGN}.saif $NL_TOGGLE_FILE_DIR/$pow_stat/${DESIGN}.power_test.saif
  genus -legacy_ui -files $IPF_DESIGN_FLOW_SCRIPTS/rc/rc_power.tcl -post quit
  echo WC Power Report in $MODULE_PATH/pwr/$STAMP/reports_$CONFIG/${DESIGN}_${pow_stat}.nl.WC.power.rpt
  echo BC Power Report in $MODULE_PATH/pwr/$STAMP/reports_$CONFIG/${DESIGN}_${pow_stat}.nl.BC.power.rpt
  echo TYP Power Report in $MODULE_PATH/pwr/$STAMP/reports_$CONFIG/${DESIGN}_${pow_stat}.nl.TYP.power.rpt
endif
