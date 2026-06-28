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
#    Primary Unit Name :      et_flow.tcl
#
#          Description :      Template Script for ET DFT Flow
#
#      Original Author :      Anna Gilbert
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

#allow user to use local dummy.tdr if changes are required
if { [info exists TDRPATH] && ($TDRPATH != "") } {
   set et_tdrpath "TDRPATH=$TDRPATH"
} else {
   set et_tdrpath ""
}

if {$BLACK_BOX} {
   set black_box_args "allowincompletemodules=yes blackbox=yes"
} else {
   set black_box_args ""
}


source $IPF_DESIGN_FLOW_SCRIPTS/et/et_checks.tcl

###############################################################
## Create Output Directories
###############################################################
if {![file exists ${_ATPGWORK_PATH}]} {
   file mkdir ${_ATPGWORK_PATH}
   puts "Creating directory ${_ATPGWORK_PATH}"
}

if {![file exists ${_ATPGWORK_PATH}/serial]} {
   file mkdir ${_ATPGWORK_PATH}/serial
   puts "Creating directory ${_ATPGWORK_PATH}/serial"
}

if {![file exists ${_ATPGWORK_PATH}/parallel]} {
   file mkdir ${_ATPGWORK_PATH}/parallel
   puts "Creating directory ${_ATPGWORK_PATH}/parallel"
}

#source ./et/et_checks.tcl
#for now stick with bournshell checks
#exec ./et/et_checks.sh

regsub -all {[\s\t\n]+} $ATPGLIB {,} ATPGLIB

set workdir $_ATPGWORK_PATH
set WORKDIR $workdir
set LINEHOLD_FILE ${_ATPGWORK_PATH}/fullscan.test_cg_enable.linehold
set LINEHOLD_VALUE [list 1 0]
set ATPG_APPEND "no"

set testmodes {FULLSCAN DELAY}

foreach testmode $testmodes {

set assignfile ${_OUTPUTS_PATH}/$testmode/$DESIGN.$testmode.pinassign
#  set assignfile ${IPF_DESIGN_FLOW_SCRIPTS}/et/${DESIGN}.pinassign
  puts $assignfile

  if { $testmode == "DELAY" } {
    if [file exists $AT_SPEED_PINASSIGNMENT_FILE ] {
      if {[catch { exec diff $AT_SPEED_PINASSIGNMENT_FILE $assignfile }]} {
        puts "Using  $AT_SPEED_PINASSIGNMENT_FILE for DELAY test mode" 
      } else {puts "Warning: Pin assignment files for FULLSCAN and DELAY test modes specified at different locations, but with the same contents,"}
        set assignfile $AT_SPEED_PINASSIGNMENT_FILE
    }
  }

  # comment out cutpoints and assignments to PPIs
  set file [open $assignfile RDONLY]
  set tmpfile [open ${assignfile}.tmp {WRONLY CREAT}]
  set commenting_out_lines 0
  set separator ""
  while { ![eof $file] } {
      set entry [gets $file]
      if [regexp -nocase {^\s*(cutpoint|assign\s+ppi)} $entry] {
          set commenting_out_lines 1
      }
      if {$commenting_out_lines} {
        puts $entry
        regsub {^} $entry {#} entry
        puts $entry
      }
      if [regexp {;\s*$} $entry] {
        set commenting_out_lines 0
      }
      puts -nonewline $tmpfile $separator$entry
      set separator "\n"
  }
  close $tmpfile
  close $file

#rename the files!
  file copy -force $assignfile ${assignfile}.bak
  file rename -force ${assignfile}.tmp $assignfile
}

puts "Running build_model"
if [file exists ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v] {
    set netlist ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v
} elseif [file exists ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v.gz] {
    set netlist ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v.gz
} elseif [file exists ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v.gz] {
    set netlist ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v.gz
} elseif [file exists ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v] {
    set netlist ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v
} elseif [file exists ${_OUTPUTS_PATH}/${DESIGN}.v.gz] {
    set netlist ${_OUTPUTS_PATH}/${DESIGN}.v.gz
} elseif [file exists ${_OUTPUTS_PATH}/${DESIGN}.v] {
    set netlist ${_OUTPUTS_PATH}/${DESIGN}.v
} else {    
    puts "ERROR: No netlist found"
}

# Purge log files from previous runs
if { [info exists $workdir/testresults/logs/*] } {
  rm [glob $workdir/testresults/logs/*]
}

build_model \
  workdir=$workdir \
  cell=$DESIGN \
  DEFINEMACRO=$DEFINEMACRO \
  source=$netlist,$ATPG_OTHER_MODULES \
  techlib=$ATPGLIB \
  industrycompatible=yes \
  $black_box_args

#exec ./et/et_checks.sh; CheckLogs $workdir/testresults/logs/log_build_model
unset testmode

foreach testmode $testmodes {

  set assignf ${_OUTPUTS_PATH}/$testmode/$DESIGN.$testmode.pinassign
#  set assignfile ${IPF_DESIGN_FLOW_SCRIPTS}/et/${DESIGN}.pinassign

  if { $testmode == "DELAY" } {
    if [file exists $AT_SPEED_PINASSIGNMENT_FILE ] {
        set assignf $AT_SPEED_PINASSIGNMENT_FILE
    }
  }

puts "Running build_testmode $testmode "
build_testmode \
  workdir=$workdir \
  testmode=$testmode \
  assignfile=$assignf \
  allowflushedmeasures=yes \
  MODEDEF=FULLSCAN \
  $et_tdrpath


#CheckLogs $? "$workdir/testresults/logs/log_build_testmode_$testmode"

puts "Running verify_test_structures $testmode "
verify_test_structures \
  workdir=$workdir \
  xclockanalysis=yes \
  testxsource=yes \
  testmode=$testmode

CheckTSVlog $workdir/testresults/logs/log_verify_test_structures_${testmode}

puts "Running report_test_structures $testmode "
report_test_structures \
  workdir=${_ATPGWORK_PATH} \
  testmode=$testmode \
  reportscanchain=all \
  reportclockaffiliation=scan \
  reportregsinactive=yes \
  reportregsfloat=all \
  reportppicutpoints=yes \
  reportpi=yes \
  reportpo=yes \
  reportregscount=yes

}
#CheckLogs $? "$workdir/testresults/logs/log_report_test_structures_$testmode"

  verify_clock_constraints \
    workdir=$workdir \
    testmode=$testmode \
    clockconstraints=${ATPG_CLOCK_CONSTRAINTS_FILE}

  CheckTTUlog $workdir/testresults/logs/log_verify_clock_constraints_DELAY

unset testmode

puts "Running build_faultmodel "
build_faultmodel \
  workdir=$workdir

#CheckLogs $? "$workdir/testresults/logs/log_build_faultmodel"

foreach testmode $testmodes {

##########################################
#STUCKAT PATTERNS
########################################## 

#does both scan and delay chain test
puts "Running create_scanchain_tests $testmode scan "
create_scanchain_delay_tests \
  workdir=$workdir \
  testmode=$testmode \
  experiment=scan

#CheckLogs $? "$workdir/testresults/logs/log_create_scanchain_tests_$testmode_$DESIGN_atpg"
  
puts "Running commit_tests $testmode scan "
commit_tests \
  testmode=$testmode \
  inexperiment=scan


if { $testmode == "FULLSCAN" } {

  puts "Running create_logic_tests $testmode logic "
  create_logic_tests \
    workdir=$workdir \
    testmode=$stuckat_testmode \
    experiment=logic \
    latchsimulation=pessimistic \
    propxignore=yes \
    globalterm=none \
    testreset=yes

#CheckLogs $? "$workdir/testresults/logs/log_create_logic_tests_$testmode_$DESIGN_atpg"

  puts "Running compact Stuckat vectors"
  compact_vectors \
    workdir=$workdir \
    testmode=$stuckat_testmode \
    reorder=coverage \
    latchsimulation=pessimistic \
    propxignore=yes \
    inexperiment=logic \
    globalterm=none
   
  puts "Running commit_tests logic - to save logic patterns "
  commit_tests \
    workdir=$workdir \
    testmode=$stuckat_testmode \
    inexperiment=logic

} else {
##########################################
#AT_SPEED PATTERNS (no PI transitions)
##########################################
   if [info exists ATPG_SDC_FILE] {
     puts "Reading scanmode SDC"  
     read_sdc \
       workdir=$workdir \
       testmode=$testmode \
       sdcpath=[file dirname ${ATPG_SDC_FILE}] \
       sdc=[file tail ${ATPG_SDC_FILE}]
   }


   puts "Running create_logic_tests $testmode logic at_speed"
   create_logic_delay_tests \
     workdir=$workdir \
     testmode=$atspeed_testmode \
     experiment=logic_delay \
     append=no \
     latchsimulation=pessimistic \
     propxignore=yes \
     globalterm=none \
     domaincutoffpercentage=0.001 \
     clockconstraints=${ATPG_CLOCK_CONSTRAINTS_FILE}

   puts "Running compact At-Speed vectors"
   compact_vectors \
     workdir=$workdir \
     testmode=$atspeed_testmode \
     reordercoverage=both \
     reorder=coverage \
     latchsimulation=pessimistic \
     propxignore=yes \
     globalterm=none  \
     inexperiment=logic_delay

   puts "Running commit_tests logic - to save logic_delay patterns "
   commit_tests \
    workdir=$workdir \
    testmode=$atspeed_testmode \
    inexperiment=logic_delay

}
##########################################
#Write Vectors
##########################################  

puts "Running write_vectors Verilog "

write_vectors \
  workdir=$workdir \
  exportdir=${_ATPGWORK_PATH}/serial \
  testmode=$testmode \
  language=verilog \
  compressfiles=yes \
  scanformat=serial

write_vectors \
  workdir=$workdir \
  exportdir=${_ATPGWORK_PATH}/parallel/ \
  testmode=$testmode \
  language=verilog \
  compressfiles=yes \
  maxvectorsperfile=$MAXVECTORS \
  scanformat=parallel

#CheckLogs $? "$workdir/testresults/logs/log_write_vectors_$testmode_$DESIGN_atpg"
}
 
##########################################
#AT_SPEED PATTERNS (with PI transitions)
##########################################

if { ($TEST_CG_ENABLE_PORT == "") || ($TEST_CG_ENABLE_PORT != $SHIFT_ENABLE_PORT) } {

   if { $TEST_CG_ENABLE_PORT != "" } {
      set ATPG_CG_ENABLE_PORT $TEST_CG_ENABLE_PORT
   } else {
      set ATPG_CG_ENABLE_PORT "scanen_cg"
   }

   foreach LINEHOLD $LINEHOLD_VALUE {

      # create linehold file
      file mkdir [file dirname $LINEHOLD_FILE]
      file delete $LINEHOLD_FILE
      set LINEHOLDSF [open ${LINEHOLD_FILE} w]
      puts $LINEHOLDSF "HOLD $ATPG_CG_ENABLE_PORT = $LINEHOLD;"
      close $LINEHOLDSF

      puts "Running create_logic_tests $testmode logic at_speed with PI transitions ($ATPG_CG_ENABLE_PORT = $LINEHOLD)"
      create_logic_delay_tests \
        workdir=$workdir \
        testmode=$atspeed_testmode \
        experiment=logic_delay_pi_trans \
        append=$ATPG_APPEND \
        allowedpitransitions=999 \
        clockconstraints=${ATPG_CLOCK_CONSTRAINTS_FILE} \
        latchsimulation=pessimistic \
        propxignore=yes \
        globalterm=none \
	domaincutoffpercentage=0.001 \
        linehold=$LINEHOLD_FILE

      set ATPG_APPEND "yes"

   }

} else {
      
   puts "Running create_logic_tests $testmode logic at_speed with PI transitions"
   create_logic_delay_tests \
     workdir=$workdir \
     testmode=$atspeed_testmode \
     experiment=logic_delay_pi_trans \
     append=$ATPG_APPEND \
     allowedpitransitions=999 \
     latchsimulation=pessimistic \
     propxignore=yes \
     globalterm=none \
     domaincutoffpercentage=0.001 \
     clockconstraints=${ATPG_CLOCK_CONSTRAINTS_FILE}

   set ATPG_APPEND "yes"

}  

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
  workdir=$workdir \
  testmode=$atspeed_testmode \
  inexperiment=logic_delay_pi_trans


puts "Encounter Test Use Model Script Complete"
exit 0
