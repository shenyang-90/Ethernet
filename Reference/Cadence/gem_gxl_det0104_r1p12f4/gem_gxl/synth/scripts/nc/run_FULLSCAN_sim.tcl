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
#    Primary Unit Name :      run_FULLSCAN_sim.tcl
#
#          Description :      Template Script for DFT simulations zero delay
#
#      Original Author :      Anna Gilbert
#
#------------------------------------------------------------------------------

puts "Hostname : [info hostname]"

source ./project.tcl
puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
puts "  RDF SVN Revision Info: $RDF_SVN_INFO"

set annotated_sim 0

set testmode FULLSCAN
set tb_dir "${_ETWORK_PATH}"

set pattern $testmode
regsub -all {\.} $pattern {_} pattern

if [string match *.gz [glob ${tb_dir}/parallel/VER.${testmode}.*]] {
  set gzipfiles_parallel [concat \
           [glob ${tb_dir}/parallel/VER.${testmode}.*.gz]]

  foreach gzipfile $gzipfiles_parallel {
     exec gunzip -f $gzipfile
  }
}

if [string match *.gz [glob ${tb_dir}/serial/VER.${testmode}.*]] {
  set gzipfiles_serial [concat \
           [glob ${tb_dir}/serial/VER.${testmode}.*.gz]]

  foreach gzipfile $gzipfiles_serial {
     exec gunzip -f $gzipfile
  }
}

set datafiles [concat \
           [glob ${tb_dir}/parallel/VER.${testmode}.data.scan.ex*.ts*.verilog] \
           [glob ${tb_dir}/parallel/VER.${testmode}.data.logic.ex*.ts*.verilog] \
           [glob ${tb_dir}/serial/VER.${testmode}.data.scan.ex*.ts*.verilog] \
           [glob ${tb_dir}/serial/VER.${testmode}.data.logic.ex*.ts*.verilog]]

# purge irun log
set irun_logfile "${_NCWORK_PATH}/irun.log"
file delete $irun_logfile

set other_args ""
if [file exists  $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/other_arguments] {
  set file [open $IPF_DESIGN_FLOW_SCRIPTS/nc/support_files/other_arguments r]
  while { ![eof $file] } {
    set entry [gets $file]
    append other_args $entry
  }
  close $file
}
puts $other_args


source $IPF_DESIGN_FLOW_SCRIPTS/nc/create_snapshot.tcl

foreach datafile $datafiles {

   set testname [file tail $datafile]
   regsub -all {\.} $testname {_} testname
   regsub -all {VER\_} $testname {} testname

   #for debugging creation of waves database
   #   perl -p -i -e "s/(?<=shm_)\S+/${testname}/g" support_files/create_shm.input

   if [string match *serial* $datafile] {

      # define $end_range to constrain serial simulation to first five tests from ATPG datafile
      set f [open $datafile r]
      set i 0
      while { ([gets $f line] >= 0) && ($i < 8) } {
         if [regexp {^900\s+([\d\.]+)} $line dummy odo_value] {
            if [regexp {\.1$} $odo_value] {
               incr i
            } else {
               set end_range_value $odo_value
            }
         }
      }
      if { ($i < 8) || [regexp {\.scan\.} $datafile] } {
         set end_range ""
      } else {
         set end_range "+END_RANGE=$end_range_value"
      }
      close $f

      exec irun -64bit ${tb_dir}/serial/VER.${testmode}.mainsim.v -update -linedebug -delay_trigger $other_args \
                -append_log -logfile $irun_logfile \
                -access +rwc -ntcnotchks -delay_mode zero -seq_udp_delay 50ps \
                -snapshot run_${testname}_serial -gateloopwarn \
                -timescale 1ns/1ps \
                -log_ncvlog ${_NCWORK_PATH}/ncvlog_${testname}_serial.log \
                -log_ncelab ${_NCWORK_PATH}/ncelab_${testname}_serial.log \
                -log_ncsim ${_NCWORK_PATH}/ncsim_${testname}_serial.log \
                -ncsim_args \
                +HEARTBEAT \
                +TESTFILE1=$datafile \
                $end_range \
                +FAILSET

   } else {

      exec irun -64bit ${tb_dir}/parallel/VER.${testmode}.mainsim.v -update -linedebug -delay_trigger $other_args \
                -append_log -logfile $irun_logfile \
                -access +rwc -ntcnotchks -delay_mode zero -seq_udp_delay 50ps \
                -snapshot run_${testname}_parallel -gateloopwarn \
                -timescale 1ns/1ps \
                -log_ncvlog ${_NCWORK_PATH}/ncvlog_${testname}_parallel.log \
                -log_ncelab ${_NCWORK_PATH}/ncelab_${testname}_parallel.log \
                -log_ncsim ${_NCWORK_PATH}/ncsim_${testname}_parallel.log \
                -ncsim_args \
                +HEARTBEAT \
                +TESTFILE1=$datafile \
                +FAILSET

   }

}

#for debugging creation of waves database
#            -input support_files/create_shm.input \

foreach gzipfile $datafiles {
   regsub {.gz$} $gzipfile {} unzippedfile
   exec gzip -f $unzippedfile
}

exit
