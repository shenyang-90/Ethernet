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
#    Primary Unit Name :      create_clock_constraints_for_atpg_ddr.tcl
#
#          Description :      script to automatically create ATPG constraints from user input
#
#      Original Author :      Vladimir Zivkovic
#
#------------------------------------------------------------------------------
if [info exists env(SCANCLOCKNAME)] {
    set SCANCLOCKNAME $env(SCANCLOCKNAME)
} else {
    puts "Environment ERROR: Please set SCANCLOCKNAME\n"
    exit
}

if [info exists env(SCANCLOCKFREQUENCY)] {
    set SCANCLOCKFREQUENCY $env(SCANCLOCKFREQUENCY)
} else {
    puts "Environment ERROR: Please set SCANCLOCKFREQUENCY\n"
    exit
}

if [file exists $ATPG_CLOCK_CONSTRAINTS_FILE] {
    file delete -force $ATPG_CLOCK_CONSTRAINTS_FILE
}

file mkdir [file dirname $ATPG_CLOCK_CONSTRAINTS_FILE]
set CLOCKSF [open ${ATPG_CLOCK_CONSTRAINTS_FILE} w]

set clk_frequency [expr $SCANCLOCKFREQUENCY / 1E6 ]
set half_clk_periodps [expr (1/($SCANCLOCKFREQUENCY * 2) * 1E9)]
puts $CLOCKSF [format "%-12s {posedge, %8.3f ns} {%8.3f MHz};" $SCANCLOCKNAME $half_clk_periodps $clk_frequency]

close $CLOCKSF
