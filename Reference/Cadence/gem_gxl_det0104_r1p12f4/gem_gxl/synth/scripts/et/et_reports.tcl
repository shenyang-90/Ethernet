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
#    Primary Unit Name :      et_reports.tcl
#
#          Description :      Coverage and Fault Reporting Script
#                             for ET DFT Flow
#
#      Original Author :      Colin Scott
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
set WORKDIR $workdir
set testmode FULLSCAN

puts "Running report_fault_statistics (Global Static TCov)"
set et_timecode [exec date +%m%d%y%H%M%S]
set et_logfile "$workdir/testresults/logs/log_report_fault_statistics_hier_static_tcov_global"
report_fault_statistics \
    workdir=$workdir \
    testmode=NONE \
    logfile=${et_logfile}_${et_timecode} \
    coveragecredit=tested \
    reporttype=static \
    hierstart=$DESIGN \
    hierend=6 \
    hierthreshold=100
file delete $et_logfile
file link $et_logfile [file tail ${et_logfile}]_${et_timecode}

puts "Running report_fault_statistics (Testmode Dynamic ATCov)"
set et_timecode [exec date +%m%d%y%H%M%S]
set et_logfile "$workdir/testresults/logs/log_report_fault_statistics_hier_dynamic_atcov_${testmode}"
report_fault_statistics \
    workdir=$workdir \
    testmode=$testmode \
    logfile=${et_logfile}_${et_timecode} \
    coveragecredit=tested,redundant \
    reporttype=dynamic \
    hierstart=$DESIGN \
    hierend=6 \
    hierthreshold=100
file delete $et_logfile
file link $et_logfile [file tail ${et_logfile}]_${et_timecode}

puts "Running report_faults (Global Static Untested)"
set et_timecode [exec date +%m%d%y%H%M%S]
set et_logfile "$workdir/testresults/logs/log_report_faults_static_untested_global"
report_faults \
    workdir=$workdir \
    logfile=${et_logfile}_${et_timecode} \
    statussummary=yes \
    nostdout=yes \
    reportkey=yes \
    faulttype=static \
    faultstatus=untested,untestable
file delete $et_logfile
file link $et_logfile [file tail ${et_logfile}]_${et_timecode}

puts "Running report_faults (Testmode Static Untested)"
set et_timecode [exec date +%m%d%y%H%M%S]
set et_logfile "$workdir/testresults/logs/log_report_faults_static_untested_${testmode}"
report_faults \
    workdir=$workdir \
    testmode=$testmode \
    logfile=${et_logfile}_${et_timecode} \
    statussummary=yes \
    nostdout=yes \
    reportkey=yes \
    faulttype=static \
    faultstatus=untested,untestable
file delete $et_logfile
file link $et_logfile [file tail ${et_logfile}]_${et_timecode}

puts "Running report_faults (Testmode Dynamic Untested)"
set et_timecode [exec date +%m%d%y%H%M%S]
set et_logfile "$workdir/testresults/logs/log_report_faults_dynamic_untested_${testmode}"
report_faults \
    workdir=$workdir \
    testmode=$testmode \
    inputcommitted=yes \
    logfile=${et_logfile}_${et_timecode} \
    statussummary=yes \
    nostdout=yes \
    reportkey=yes \
    faulttype=dynamic \
    faultstatus=untested,untestable
file delete $et_logfile
file link $et_logfile [file tail ${et_logfile}]_${et_timecode}


puts "Encounter Test Report Script Complete"
exit 0
