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
#    Primary Unit Name :      modus_clock_checks.tcl
#
#          Description :      script to automatically check ATPG logfiles for clock constraints consistency
#
#      Original Author :      Vladimir Zivkovic
#
#------------------------------------------------------------------------------

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
