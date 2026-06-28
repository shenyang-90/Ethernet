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
#    Primary Unit Name :      compilation_check.csh
#
#          Description :      Script for checking compilation dependencies
#
#      Original Author :      Lukasz Kotynia
#
#------------------------------------------------------------------------------

source ./setup_project.csh

setenv RPT_PATH `echo "source ./project.tcl; source $IPF_DESIGN_FLOW_SCRIPTS/setup/setup_dirs.tcl;" 'puts $COMPILATION_CHECK_RPT' | tclsh`
set RTL_F_FILE_STUB=expanded_stub.f
set RTL_F_FILE_LOC=expanded_comp_check.f

if (! -d $RPT_PATH ) then
  mkdir -p $RPT_PATH
endif

set LOGFILE = $RPT_PATH/compilation_check.log

echo "INFO: Hostname : `hostname`" | tee $LOGFILE
echo "INFO: Run by : `whoami` " | tee -a $LOGFILE
echo "INFO: Date : `date`" | tee -a $LOGFILE 
echo "INFO: Check $LOGFILE."

set PARAMS_STRING=""

foreach param ( $* )
  set PARAMS_STRING="$PARAMS_STRING $param"
end

echo "INFO: User-defined command-line params : $PARAMS_STRING" | tee -a $LOGFILE

set OUTPUT_IRUN=ncdc_irun
set OUTPUT_3STEP=ncdc_3step
set COMPILE_SCRIPT=compile_3step.csh
set COMPILE_SCRIPT_IRUN=compile_irun.csh

if ( ! $?DESIGN ) then
  echo "ERROR: Variable DESIGN not set. Make sure the setup_project.csh has been sourced" | tee -a $LOGFILE
  exit 1
endif

echo "INFO: Desing name: $DESIGN" | tee -a $LOGFILE
echo "INFO: Cleaning up directory" | tee -a $LOGFILE
irun -cleanlib
rm -rf INCA_libs
rm -rf $OUTPUT_IRUN
rm -rf $OUTPUT_3STEP
rm -rf $COMPILE_SCRIPT_IRUN
rm -rf ncvlog.log
rm -rf ncelab.log
rm -rf compilation_compare.log
rm -rf worklib; mkdir worklib

if (! -f $RTL_F_FILE) then
  echo "ERROR: $RTL_F_FILE not found. Make sure the project is set up correctly" | tee -a $LOGFILE
  exit 1
endif

if ( -f $RTL_F_FILE_STUB ) then
  cat $RTL_F_FILE $RTL_F_FILE_STUB > $RTL_F_FILE_LOC
else
  cat $RTL_F_FILE  > $RTL_F_FILE_LOC
endif

set INC_LIST="+incdir+./"
set DEFINES=""
set FILE_LIST=""
foreach item ( "`cat $RTL_F_FILE_LOC`" )
  if ( `echo $item | grep "^[ ]*.incdir"` != "" ) then
    #get all incdir values
    set INC_LIST="$INC_LIST `echo $item`"
  else if (`echo $item | grep "^[ ]*.define"` != "" ) then
    #get all define statements
    set DEFINES="$DEFINES `echo $item`"
  else
    set FILE_LIST="$FILE_LIST `echo $item`"
  endif
end

foreach item ( $HDL_SEARCH_PATH )
  set INC_LIST="$INC_LIST +incdir+`echo $item`"
end

foreach item ( `echo $FILE_LIST` )
  if ( `echo $item | grep "incdir"` == "" ) then
    eval set aux = $item
    $LSF ncvlog -sv -append_log -NOSTDOUT -mess $aux $INC_LIST $DEFINES $PARAMS_STRING
    if ( $status != 0 ) then
      echo "ERROR: ncvlog compilation failed" | tee -a $LOGFILE
      echo "  Check `pwd`/ncvlog.log" | tee -a $LOGFILE
      exit 1
    endif 
  endif
end

$LSF ncelab $DESIGN -errormax 1 -timescale 1ns/1ns -mess -NOSTDOUT
if ( $status != 0 ) then
  echo "ERROR: ncelab elaboration failed" | tee -a $LOGFILE
  echo "  Check `pwd`/ncelab.log" | tee -a $LOGFILE
  exit 2
endif

$LSF ncdc -ORIGFILE $DESIGN
if ( $status != 0 ) then
  echo "ERROR: decompilation failed" | tee -a $LOGFILE
  echo "  Check `pwd`/ncdc.log" | tee -a $LOGFILE
  exit 3
endif

#remove headers of the files for comparision purposes
find ncdc -name "*.*v" -exec sed -i "s#^\/\/ \(Original Design File.*\)#/\/\/\/\ \1#" {} \;
find ncdc -name "*.*v" -exec sed -i "/^\/\/ /d" {} \;
rm -rf ncdc/worklib
rm -rf ncdc/ncdc.run
mv ncdc $OUTPUT_3STEP
echo "INFO: Elaboration with 3-step approach was successful"  | tee -a $LOGFILE
echo "INFO: Check the `pwd`/$OUTPUT_3STEP directory" | tee -a $LOGFILE
rm -rf worklib; mkdir worklib

irun -clean -elaborate -f $RTL_F_FILE_LOC $INC_LIST -top $DESIGN  -timescale 1ns/1ns $PARAMS_STRING -nostdout -sv
if ( $status != 0 ) then
  echo "ERROR: irun elaboration failed" | tee -a $LOGFILE
  echo "  Check `pwd`/irun.log" | tee -a $LOGFILE
  exit 4
endif

$LSF ncdc -ORIGFILE $DESIGN
if ( $status != 0 ) then
  echo "ERROR: decompilation failed" | tee -a $LOGFILE
  echo "  Check `pwd`/ncdc.log" | tee -a $LOGFILE
  exit 5
endif

#remove headers of the files for comparision purposes
find ncdc -name "*.*v" -exec sed -i "s#^\/\/ \(Original Design File.*\)#/\/\/\/\ \1#" {} \;
find ncdc -name "*.*v" -exec sed -i "/^\/\/ /d" {} \;
rm -rf ncdc/worklib
rm -rf ncdc/ncdc.run
mv ncdc $OUTPUT_IRUN
echo "INFO: Elaboration with irun approach was successful"  | tee -a $LOGFILE
echo "INFO: Check the `pwd`/$OUTPUT_IRUN directory" | tee -a $LOGFILE

if ( (! -d $OUTPUT_3STEP)  || ( ! -d $OUTPUT_IRUN ) ) then
  echo "ERROR: dir missing" | tee -a $LOGFILE
  exit 8
endif 

diff -qb $OUTPUT_3STEP $OUTPUT_IRUN > compilation_compare.log 
if ( $status == 1 ) then
  echo "ERROR: Files differ" | tee -a $LOGFILE
  echo "Total number of different files: `grep -c diff compilation_compare.log`" | tee -a $LOGFILE
  echo "Check `pwd`/compilation_compare.log for complete list" | tee -a $LOGFILE
  exit 6
else if ( $status > 1 ) then
  echo "ERROR: unknown diff error" | tee -a $LOGFILE
  exit 7
else 
  echo "INFO: No differences detected" | tee -a $LOGFILE
endif

rm -rf $RTL_F_FILE_LOC

