#!/bin/tclsh
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
#    Primary Unit Name :      et_checks.tcl
#
#          Description :      script to automatically check ATPG logfiles for serious issues
#
#      Original Author :      Anna Gilbert
#
#------------------------------------------------------------------------------

proc CheckTSVlog {args} {

    set logfile $args
    puts "checking logfile $logfile for serious errors"
    set CONTINUE_WITH_SEVERE "no"
    set err 0
    global CONTENTION
    global MULTICLOCK
    global KEEPERS

    #check for specific warning issues excluding INFO messages
    eval exec "egrep TSV-369|TSV-370|TSV-381|TSV-570" $logfile | grep -v "^INFO"

    #find the TSV-384 warnings in the logfile, exclude if the line starts with WARNING, displays the line at the end of the file
    #These warnings indicate broken scanchains
    if [catch {eval exec "egrep TSV-384" $logfile}] {
        set TSV_error ""
    } else {
        set TSV_error [exec grep "WARNING (TSV-384)" $logfile | grep -v "^WARNING" | tail -1]
        puts ${TSV_error}
    }

    if [catch {eval exec "egrep TSV-385" $logfile}] {
        set TSV_error ""
    } else {
        set TSV_error [exec grep "WARNING (TSV-385)" $logfile | grep -v "^WARNING" | tail -1]
        puts ${TSV_error}
    }

    if {${TSV_error} ne ""} {
        puts " "
        puts "${TSV_error} messages indicate the following scan chains are broken. "
        puts " "
        puts [eval exec "egrep TSV-385|TSV-384" $logfile | grep "^WARNING"]
        set err 1
    }

    if {$err eq 1} {
        if {$CONTINUE_WITH_SEVERE eq "yes"} {
            puts " "
            puts "Setup file specifies CONTINUE_WITH_SEVERE=yes."
            puts "Continuing. Please review details in log file:"
            puts "  $logfile "
        } else {
            puts " "
            puts "Exiting. Please review details in log file:"
            puts "  $logfile "
            puts " "
            exit
        }
    }

    # Check for contention issues and set contentionreport appropriately.
    if [catch {eval exec "egrep -c TSV-093|TSV-193" $logfile}] {
        set TSV_error ""
    } else {
        set TSV_error [eval exec "egrep TSV-093|TSV-193" $logfile | grep "^WARNING" | tail -1]
        puts $TSV_error
    }

    if {${TSV_error} ne ""} {
        puts " "
        puts "$TSV_error messages indicate possible contention (soft or hard).   "
        puts "ATPG will continue using contentionreport=hard to ignore potential "
        puts "soft contention due to black box outputs or other X-sources.       "
        puts "If this is not desired, set contentionreport=soft in ATPG.         "
        puts "Please review details in log file:                                 "
        puts "  $logfile "
        puts " "
#     if {${CONTENTION} ne ""} {
#         # do nothing
#         set z 1
#     } else {
##        set CONTENTION "hard"
##        set MULTICLOCK "yes"
##        export CONTENTION MULTICLOCK
#         puts "Need to work out if we can export variables from here for remaining ATPG run, perhaps namespace import/export?"
#     }
    }

    # Check for keeper issues and simulate keepers risky if necessary.
    if [catch {eval exec "egrep -c TSV-034|TSV-035" $logfile}] {
        set TSV_error ""
    } else {
        set TSV_error [eval exec "TSV-034|TSV-035" $logfile | grep "^WARNING" | tail -1]
        puts $TSV_error
    }

    if {${TSV_error} ne ""} {
        puts " "
        puts "$TSV_error messages indicate possible invalid keeper devices."
        puts "ATPG will continue using keepers=risky to simulate them for highest   "
        puts "coverage.  If this is not desired, set keepers=safe in ATPG           "
        puts "Please review details in log file:                                         "
        puts "  $logfile "
        puts " "
#     if {${KEEPERS} ne ""} {
#         # do nothing
#         set z 1
#     } else  {
#         set KEEPERS "risky"
#         export KEEPERS
#     }
    }

    # Check for infinitex issues and set infinitex=none if necessary.
    if [catch {eval exec "egrep -c TSV-059|TSV-310|TSV-008" $logfile}] {
        set TSV_error ""
    } else {
        set TSV_error [eval exec "TSV-059|TSV-310|TSV-008" $logfile | grep "^WARNING" | tail -1]
        puts $TSV_error
    }

    if {${TSV_error} ne ""} {
        puts " "
        puts "$TSV_error messages indicate design guideline violations.                  "
        puts "ATPG will continue using infinitex=none to simulate for highest          "
        puts "coverage.  If this is not desired, set infinitex appropriately in ATPG "
        puts "Please review details in log file:                                          "
        puts "  $logfile "
        puts " "
        if {${INFINITEX} ne ""} {
            # do nothing
            set z 1
        } else  {
            set INFINITEX "none"
            export INFINITEX
        }
    }

    if {$err eq 0} {
        puts "Step completed successfully. Continuing.."
    }

}

proc CheckTTUlog {args} {
  set logfile $args
    set CONTINUE_WITH_SEVERE "no"
    puts "checking logfile $logfile for serious errors"
    set err 0
    
     if [catch {eval exec "egrep TTU-403" $logfile}] {
        set TTU_error ""
    } else {
        set TTU_error [exec grep "ERROR (TTU-403)" $logfile | grep -v "^ERROR" | tail -1]
        puts ${TTU_error}
    }
    
    if [catch {eval exec "egrep TTU-405" $logfile}] {
        set TTU_error ""
    } else {
        set TTU_error [exec grep "ERROR (TTU-405)" $logfile | grep -v "^ERROR" | tail -1]
        puts ${TTU_error}
    }
    
    if {${TTU_error} ne ""} {
        puts " "
        puts "${TTU_error} messages indicate the tester descriptor rule file (TDR) does not sustain the clock frequencies in the design. "
        puts "Please modify the tdr file, reffer to Userguide for more information "
        set err 1
    }
    
    if {$err eq 1} {
        if {$CONTINUE_WITH_SEVERE eq "yes"} {
            puts " "
            puts "Setup file specifies CONTINUE_WITH_SEVERE=yes."
            puts "Continuing. Please review details in log file:"
            puts "  $logfile "
        } else {
            puts " "
            puts "Exiting. Please review details in log file:"
            puts "  $logfile "
            exit
        }
    }

}
