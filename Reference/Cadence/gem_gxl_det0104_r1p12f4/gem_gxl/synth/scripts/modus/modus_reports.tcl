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
#    Primary Unit Name :      modus_reports.tcl
#
#          Description :      Coverage and Fault Reporting Script
#                             for Modus DFT Flow
#
#      Original Author :      Anna Gilbert / Vladimir Zivkovic
#
#------------------------------------------------------------------------------

puts "Hostname : [info hostname]"

# Read project.tcl from current directory if it exists, otherwise look for it in $DUT_PATH
if [file exists "./project.tcl"] {
    puts "Sourcing ./project.tcl ..."
    source ./project.tcl
} elseif [file exists "$env(DUT_PATH)/project.tcl"] {
    puts "Sourcing $env(DUT_PATH)/project.tcl ..."
    source $env(DUT_PATH)/project.tcl
} else {
    puts "ERROR: Can't find project.tcl in current working directory or in '$env(DUT_PATH)'."
    exit
}
puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
puts "  RDF SVN Revision Info: $RDF_SVN_INFO"

###############################################################
## Create Output Directories
###############################################################
if {![file exists ${_ATPGWORK_PATH}]} {
    file mkdir ${_ATPGWORK_PATH}
    puts "Creating directory ${_ATPGWORK_PATH}"
}

if {![file exists ${_ATPGWORK_PATH}/testresults/logs]} {
    file mkdir ${_ATPGWORK_PATH}/testresults/logs
    puts "Creating directory ${_ATPGWORK_PATH}/testresults/logs"
}

set workdir $_ATPGWORK_PATH
#set WORKDIR $workdir
#set testmode FULLSCAN

#setup global variables
set_db workdir $workdir

puts "Running report_fault_statistics (Global Static TCov)"
set modus_timecode [exec date +%m%d%y%H%M%S]
set modus_logfile "$workdir/testresults/logs/log_report_fault_statistics_hier_static_tcov_global"
report_fault_statistics \
    -testmode NONE \
    -logfile ${modus_logfile}_${modus_timecode} \
    -coveragecredit tested \
    -reporttype static \
    -hierstart $DESIGN \
    -hierend 6 \
    -hierthreshold 100
file delete $modus_logfile
file link $modus_logfile [file tail ${modus_logfile}]_${modus_timecode}

puts "Running report_fault_statistics (Testmode Dynamic ATCov)"
set modus_timecode [exec date +%m%d%y%H%M%S]
set modus_logfile "$workdir/testresults/logs/log_report_fault_statistics_hier_dynamic_atcov_DELAY"
report_fault_statistics \
    -testmode DELAY \
    -logfile ${modus_logfile}_${modus_timecode} \
    -coveragecredit tested,redundant \
    -reporttype dynamic \
    -hierstart $DESIGN \
    -hierend 6 \
    -hierthreshold 100
file delete $modus_logfile
file link $modus_logfile [file tail ${modus_logfile}]_${modus_timecode}

puts "Running report_faults (Global Static Untested)"
set modus_timecode [exec date +%m%d%y%H%M%S]
set modus_logfile "$workdir/testresults/logs/log_report_faults_static_untested_global"
report_faults \
    -logfile ${modus_logfile}_${modus_timecode} \
    -statussummary yes \
    -reportkey yes \
    -faulttype static \
    -faultstatus untested,untestable
file delete $modus_logfile
file link $modus_logfile [file tail ${modus_logfile}]_${modus_timecode}

puts "Running report_faults (Testmode Static Untested)"
set modus_timecode [exec date +%m%d%y%H%M%S]
set modus_logfile "$workdir/testresults/logs/log_report_faults_static_untested_FULLSCAN"
report_faults \
    -testmode FULLSCAN \
    -logfile ${modus_logfile}_${modus_timecode} \
    -statussummary yes \
    -reportkey yes \
    -faulttype static \
    -faultstatus untested,untestable
file delete $modus_logfile
file link $modus_logfile [file tail ${modus_logfile}]_${modus_timecode}

puts "Running report_faults (Testmode Dynamic Untested)"
set modus_timecode [exec date +%m%d%y%H%M%S]
set modus_logfile "$workdir/testresults/logs/log_report_faults_dynamic_untested_DELAY"
report_faults \
    -testmode DELAY \
    -inputcommitted yes \
    -logfile ${modus_logfile}_${modus_timecode} \
    -statussummary yes \
    -reportkey yes \
    -faulttype dynamic \
    -faultstatus untested,untestable
file delete $modus_logfile
file link $modus_logfile [file tail ${modus_logfile}]_${modus_timecode}


puts "Modus Report Script Complete"
exit 0
