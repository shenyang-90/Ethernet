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

if { ![info exists corners] && [info exists corner] && ($corner != "") } {
   set corners [list $corner]
} elseif { ![info exists corners] || ($corners == {}) } {
   puts "No SDF corner specified, hence no annotated simulations will be performed"
   exit
}

set annotated_sim 1

 if { ( ($env(DM) == 'at_speed') || ($env(DM) == 'atspeed') || ($env(DM) == 'scan_atspeed') ) } {
   set testmode DELAY
 } else {
   set testmode FULLSCAN 
 }  

set tb_dir "${_ETWORK_PATH}"


# purge xrun log
set xrun_logfile "${_NCWORK_PATH}/xrun.log"
file delete $xrun_logfile

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
puts  "here $env(CORNER)\n"
puts  "here $env(datafile)\n"
set corner $env(CORNER)


   set xrun_logfile_corner "${_NCWORK_PATH}/xrun_${corner}.log"
   file delete $xrun_logfile_corner
   
   if {![file exists ${_NCWORK_PATH}/$corner/]} {
     file mkdir ${_NCWORK_PATH}/${corner}/
     puts "Creating directory ${_NCWORK_PATH}/${corner}/"
   }

   set ATPG_DESIGN_MODE $env(DM)
   
   source $IPF_DESIGN_FLOW_SCRIPTS/nc/annotate_sdf.tcl



   set testname [file tail $env(datafile)]
   regsub -all {\.} $testname {_} testname
   regsub -all {VER\_} $testname {} testname

   #for debugging creation of waves database
   #   perl -p -i -e "s/(?<=shm_)\S+/${testname}/g" support_files/create_shm.input

   if [string match *serial* $env(datafile)] {

      # define $end_range to constrain serial simulation to first five tests from ATPG datafile
      set f [open $env(datafile) r]
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
      if { ($i < 8) || [regexp {\.scan\.} $env(datafile)] } {
         set end_range ""
      } else {
         set end_range "+END_RANGE=$end_range_value"
      }
      close $f

         exec xrun -64bit ${tb_dir}/serial/VER.${testmode}.mainsim.v -update -linedebug -delay_trigger $other_args \
                   -sdf_cmd_file $sdf_cmd_file_($ATPG_DESIGN_MODE) \
                   -append_log -logfile $xrun_logfile_corner \
                   -access +rwc \
                   -snapshot run_${testname}_${corner}_serial \
                   -warnmax 0 \
                   -timescale 1ns/1ps \
                   -log_ncvlog ${_NCWORK_PATH}/${corner}/ncvlog_${testname}_${corner}_serial_$testname.log \
                   -log_ncelab ${_NCWORK_PATH}/${corner}/ncelab_${testname}_${corner}_serial_$testname.log \
                   -log_ncsim ${_NCWORK_PATH}/${corner}/ncsim_${testname}_${corner}_serial_$testname.log \
                   -ncsim_args \
                   +HEARTBEAT \
                   +TESTFILE1=$env(datafile) \
                   $end_range \
                   +FAILSET

      } else {

         exec xrun -64bit ${tb_dir}/parallel/VER.${testmode}.mainsim.v -update -linedebug -delay_trigger $other_args \
                   -sdf_cmd_file $sdf_cmd_file_($ATPG_DESIGN_MODE) \
                   -append_log -logfile $xrun_logfile_corner \
                   -access +rwc \
                   -snapshot run_${testname}_${corner}_parallel \
                   -warnmax 0 \
                   -timescale 1ns/1ps \
                   -log_ncvlog ${_NCWORK_PATH}/${corner}/ncvlog_${testname}_${corner}_parallel_$testname.log \
                   -log_ncelab ${_NCWORK_PATH}/${corner}/ncelab_${testname}_${corner}_parallel_$testname.log \
                   -log_ncsim ${_NCWORK_PATH}/${corner}/ncsim_${testname}_${corner}_parallel_$testname.log \
                   -ncsim_args \
                   +HEARTBEAT \
                   +TESTFILE1=$env(datafile) \
                   +FAILSET

   }



#for debugging creation of waves database
#            -input support_files/create_shm.input \


exit
