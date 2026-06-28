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
#    Primary Unit Name :      run_FULLSCAN_sdf_sim.tcl
#
#          Description :      Template Script for DFT simulations with back annotated timing (SDF)
#
#      Original Author :      Anna Gilbert
#	Modified by    :      Vladimir Zivkovic
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

set ATPG_DESIGN_MODES ""

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


set DESIGN_MODES [split $DESIGN_MODES " "]
   foreach DESIGN_MODE ${DESIGN_MODES} {
      if {$DESIGN_MODE == "scan"} {
         lappend ATPG_DESIGN_MODES scan
      }
      if {$DESIGN_MODE == "stuckat"} {
         lappend ATPG_DESIGN_MODES stuckat
      }
      if {$DESIGN_MODE == "stuck_at"} {
         lappend ATPG_DESIGN_MODES stuck_at
      }
      if {$DESIGN_MODE == "scan_shift"} {
     	 lappend ATPG_DESIGN_MODES scan_shift
      }
      if {$DESIGN_MODE == "shift"} {
     	 lappend ATPG_DESIGN_MODES shift
      }
      if {$DESIGN_MODE == "scan_capture"} {
     	 lappend ATPG_DESIGN_MODES scan_capture
      }
      if {$DESIGN_MODE == "capture"} {
     	 lappend ATPG_DESIGN_MODES capture
      }
      if {$DESIGN_MODE == "scan_atspeed"} {
     	 lappend ATPG_DESIGN_MODES scan_atspeed
      }
      if {$DESIGN_MODE == "atspeed"} {
     	 lappend ATPG_DESIGN_MODES atspeed
      }
      if {$DESIGN_MODE == "at_speed"} {
     	 lappend ATPG_DESIGN_MODES at_speed
      }
   }
   if {$ATPG_DESIGN_MODES == ""} {
      lappend ATPG_DESIGN_MODES func
   }
#exit

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

foreach ATPG_DESIGN_MODE $ATPG_DESIGN_MODES {

   foreach corner $corners {

   # purge irun log
   set irun_logfile_corner "${_NCWORK_PATH}/irun_${corner}.log"
   file delete $irun_logfile_corner
   
   if {![file exists ${_NCWORK_PATH}/$corner/]} {
     file mkdir ${_NCWORK_PATH}/${corner}/
     puts "Creating directory ${_NCWORK_PATH}/${corner}/"
   } else {
     foreach corfile [glob -nocomplain ${_NCWORK_PATH}/${corner}/*] {
     file delete $corfile
     }
  }

   source $IPF_DESIGN_FLOW_SCRIPTS/nc/annotate_sdf.tcl

      if {(($ATPG_DESIGN_MODE == "func")||($ATPG_DESIGN_MODE == "scan"))} {
      set datafiles [concat \
                    [glob ${tb_dir}/parallel/VER.${testmode}.data.scan.ex*.ts*.verilog] \
                    [glob ${tb_dir}/parallel/VER.${testmode}.data.logic.ex*.ts*.verilog] \
                    [glob ${tb_dir}/serial/VER.${testmode}.data.scan.ex*.ts*.verilog] \
                    [glob ${tb_dir}/serial/VER.${testmode}.data.logic.ex*.ts*.verilog]]
      }

      if {$ATPG_DESIGN_MODE == "shift"} {
      set datafiles [concat \
                    [glob ${tb_dir}/parallel/VER.${testmode}.data.scan.ex*.ts*.verilog] \
                    [glob ${tb_dir}/serial/VER.${testmode}.data.scan.ex*.ts*.verilog]]
      }
      
      if {$ATPG_DESIGN_MODE == "scan_shift"} {
      set datafiles [concat \
                    [glob ${tb_dir}/parallel/VER.${testmode}.data.scan.ex*.ts*.verilog] \
                    [glob ${tb_dir}/serial/VER.${testmode}.data.scan.ex*.ts*.verilog] \
		    [glob ${tb_dir}/parallel/VER.${testmode}.data.logic.ex2.ts*.verilog] \
		    [glob ${tb_dir}/serial/VER.${testmode}.data.logic.ex2.ts*.verilog]]
      }

      if {(($ATPG_DESIGN_MODE == "scan_capture") || ($ATPG_DESIGN_MODE == "capture") || ($ATPG_DESIGN_MODE == "stuckat") || ($ATPG_DESIGN_MODE == "stuck_at"))} {
      set datafiles [concat \
                    [glob ${tb_dir}/parallel/VER.${testmode}.data.logic.ex2.ts*.verilog] \
                    [glob ${tb_dir}/serial/VER.${testmode}.data.logic.ex2.ts*.verilog]]
      }
      
      if {(($ATPG_DESIGN_MODE == "scan_atspeed")||($ATPG_DESIGN_MODE == "at_speed") || ($ATPG_DESIGN_MODE == "atspeed"))} {
      set datafiles [concat \
                    [glob ${tb_dir}/parallel/VER.${testmode}.data.logic.ex3.ts*.verilog] \
                    [glob ${tb_dir}/serial/VER.${testmode}.data.logic.ex3.ts*.verilog]]
      }

      foreach datafile $datafiles {

      set testname [file tail $datafile]
      regsub -all {\.} $testname {_} testname
      regsub -all {VER\_} $testname {} testname
      
      
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
                   -sdf_cmd_file $sdf_cmd_file_($ATPG_DESIGN_MODE) \
                   -append_log -logfile $irun_logfile_corner \
                   -access +rwc \
                   -snapshot run_${testname}_${corner}_serial \
                   -warnmax 0 \
                   -timescale 1ns/1ps \
                   -log_ncvlog ${_NCWORK_PATH}/ncvlog_${testname}_${corner}_serial.log \
                   -log_ncelab ${_NCWORK_PATH}/ncelab_${testname}_${corner}_serial.log \
                   -log_ncsim ${_NCWORK_PATH}/ncsim_${testname}_${corner}_serial.log \
                   -ncsim_args \
                   +HEARTBEAT \
                   +TESTFILE1=$datafile \
                   $end_range \
                   +FAILSET

      } else {

         exec irun -64bit ${tb_dir}/parallel/VER.${testmode}.mainsim.v -update -linedebug -delay_trigger $other_args \
                   -sdf_cmd_file $sdf_cmd_file_($ATPG_DESIGN_MODE) \
                   -append_log -logfile $irun_logfile_corner \
                   -access +rwc \
                   -snapshot run_${testname}_${corner}_parallel \
                   -warnmax 0 \
                   -timescale 1ns/1ps \
                   -log_ncvlog ${_NCWORK_PATH}/ncvlog_${testname}_${corner}_parallel.log \
                   -log_ncelab ${_NCWORK_PATH}/ncelab_${testname}_${corner}_parallel.log \
                   -log_ncsim ${_NCWORK_PATH}/ncsim_${testname}_${corner}_parallel.log \
                   -ncsim_args \
                   +HEARTBEAT \
                   +TESTFILE1=$datafile \
                   +FAILSET

      }

   }

}
}


foreach gzipfile $datafiles {
   regsub {.gz$} $gzipfile {} unzippedfile
   exec gzip -f $unzippedfile
}

exit
