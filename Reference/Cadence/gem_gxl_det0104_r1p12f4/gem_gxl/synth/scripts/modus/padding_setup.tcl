#------------------------------------------------------------------------------
#
#            CADENCE                    Copyright (c) 2002-2017
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      padding_setup.tcl
#
#          Description :      Padding setup for write_vectors command
#                             of Modus tool
#
#      Original Author :      Vladimir Zivkovic
#
#------------------------------------------------------------------------------

set tmpfile [open $env(IPF_DESIGN_FLOW_SCRIPTS)/modus/modus.tmp.tcl {WRONLY CREAT}]
set f [open "$env(IPF_DESIGN_FLOW_SCRIPTS)/modus/modus_flow.tcl"]
set contents [read $f]
set list_of_originals [split $contents \n]
set empty ""
set pattern_s "scanformat serial"
set pattern_p "scanformat parallel"
 
if [file exists "$env(PADDING_SERIAL_FILE)"] {
  set fs [open "$env(PADDING_SERIAL_FILE)"]
  set contents_s [read $fs]
  set list_of_lines_s [split $contents_s \n]
  set pattern_s "scanformat serial"
}
if [file exists "$env(PADDING_PARALLEL_FILE)"] {
  set fp [open $env(PADDING_PARALLEL_FILE)]
  set contents_p [read $fp]
  set list_of_lines_p [split $contents_p \n]
}
  

foreach line $list_of_originals {
  if { [regexp $pattern_s $line] &&  [file exists "$env(PADDING_SERIAL_FILE)"] } {
    foreach linen $list_of_lines_s {
      if {($linen != "") && ([string index $linen 0] !=  "#") } {
	regsub \\- $linen $empty linen
	puts $tmpfile "\t-$linen \\"
      }
    }
    unset linen
  }
  if { [regexp $pattern_p $line] && [file exists "$env(PADDING_PARALLEL_FILE)"] } {
      foreach linen $list_of_lines_p {
        if {($linen != "") && ([string index $linen 0] !=  "#") } {
	  regsub \\- $linen $empty linen
	  puts $tmpfile "\t-$linen \\"
        }
      }
  }
  puts $tmpfile $line
}
close $tmpfile
close $f

if [file exists "$env(PADDING_SERIAL_FILE)"] {
  close $fs
}

if [file exists "$env(PADDING_PARALLEL_FILE)"] {
  close $fp
}

exec rm -rf $env(IPF_DESIGN_FLOW_SCRIPTS)/modus/modus.tmp.tcl
