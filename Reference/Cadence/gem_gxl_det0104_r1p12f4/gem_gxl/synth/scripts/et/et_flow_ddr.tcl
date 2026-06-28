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
#    Primary Unit Name :      et_flow_ddr.tcl
#
#          Description :      Template Script for DDR ET DFT Flow
#
#      Original Author :      Vladimir Zivkovic
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

#clock constraints for ATPG now extracted from synthesis database
#VZ modification
source $IPF_DESIGN_FLOW_SCRIPTS/et/create_clock_constraints_for_atpg_ddr.tcl

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

#------------------------------------------------------------------------------
if [info exists env(DDR_WORKAREA)] {
    set DDR_WORKAREA $env(DDR_WORKAREA)
} else {
    puts "Environment ERROR: Please set DUT_WORKAREA\n"
    exit
}

if [info exists env(DDR_NETLIST)] {
    set DDR_NETLIST $env(DDR_NETLIST)
} else {
    puts "Environment ERROR: Please set DUT_NETLIST\n"
    exit
}

if [info exists env(DIVIDE_BY_FOUR)] {
    set DIVIDE_BY_4 $env(DIVIDE_BY_FOUR)
} else {
    puts "Environment ERROR: Please set DIVIDE_BY_FOUR\n"
    exit
}

if [info exists env(DDR_USER_SETUP)] {
    set DDR_USER_SETUP $env(DDR_USER_SETUP)
} else {
    puts "Environment ERROR: Please set DDR_USER_SETUP\n"
    exit
}


#source ./et/et_checks.tcl
#for now stick with bournshell checks
#exec ./et/et_checks.sh

regsub -all {[\s\t\n]+} $ATPGLIB {,} ATPGLIB

set workdir $_ATPGWORK_PATH
set WORKDIR $workdir
set testmode FULLSCAN
set LINEHOLD_FILE ${_ATPGWORK_PATH}/fullscan.test_cg_enable.linehold
set LINEHOLD_VALUE [list 1 0]
set ATPG_APPEND "no"

source ${DDR_USER_SETUP}

puts "setting the lineholds right"
if { $DIVIDE_BY_4 == "0"} {
    set lineholdfiles [list ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk2x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_slice_clk2x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_slice_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_top_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk2x_to_slice_clk1x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_to_slice_clk2x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_to_top_clk1x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_clk1x_to_slice_clk1x.linehold]
} else {
    set lineholdfiles [list ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk2x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_db4_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_db4_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_slice_clk2x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_slice_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_slice_db4_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_top_clk1x_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_2pulse_top_db4_only.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk2x_to_slice_clk1x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_to_slice_clk2x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_to_slice_db4.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_db4_to_slice_clk1x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_clk1x_to_top_clk1x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_clk1x_to_slice_clk1x.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_slice_db4_to_top_db4.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_db4_to_slice_db4.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_clk1x_to_top_db4.linehold \
                            ${DDR_WORKAREA}/${DESIGN}_dynamic_2pulse_top_db4_to_top_clk1x.linehold]
}

foreach lh $lineholdfiles {
    exec perl -p -i -e "s/.Q /.${FLOP_OUTPUT_PIN} /g" $lh
}

if [file exists ${DDR_WORKAREA}/${DESIGN}.faultrulefile] {
    set faultrulefile_arg "faultrulefile=${DDR_WORKAREA}/${DESIGN}.faultrulefile"
} else {
    set faultrulefile_arg ""
}

if [file exists ${DDR_WORKAREA}/${DESIGN}.ignoremeasures] {
    set ignoremeasures_arg "ignoremeasures=${DDR_WORKAREA}/${DESIGN}.ignoremeasures"
} else {
    set ignoremeasures_arg ""
}

puts "setting the netlist"
if [file exists ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v] {
    set netlist ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v
} elseif [file exists ${_OUTPUTS_PATH}/$testmode/${DESIGN}.et_netlist.v] {
    set netlist ${_OUTPUTS_PATH}/$testmode/${DESIGN}.et_netlist.v
} else {
    set netlist $DDR_NETLIST
}

exec perl -p -i -e "s/set FLOP_OUTPUT Q /set FLOP_OUTPUT ${FLOP_OUTPUT_PIN} /g" ${ATPG_SDC_FILE}/${DESIGN}_static.sdc
exec perl -p -i -e "s/set FLOP_INPUT D /set FLOP_INPUT ${DATAPIN} /g" ${ATPG_SDC_FILE}/${DESIGN}_static.sdc

exec perl -p -i -e "s/set FLOP_OUTPUT Q /set FLOP_OUTPUT ${FLOP_OUTPUT_PIN} /g" ${ATPG_SDC_FILE}/${DESIGN}_dynamic_atspeed.sdc
exec perl -p -i -e "s/set FLOP_INPUT D /set FLOP_INPUT ${DATAPIN} /g" ${ATPG_SDC_FILE}/${DESIGN}_dynamic_atspeed.sdc

exec perl -p -i -e "s/set FLOP_OUTPUT Q /set FLOP_OUTPUT ${FLOP_OUTPUT_PIN} /g" ${ATPG_SDC_FILE}/${DESIGN}_dynamic.sdc
exec perl -p -i -e "s/set FLOP_INPUT D /set FLOP_INPUT ${DATAPIN} /g" ${ATPG_SDC_FILE}/${DESIGN}_dynamic.sdc


puts "Running build_model"
build_model \
    workdir=$workdir \
    cell=$DESIGN \
    DEFINEMACRO=$DEFINEMACRO \
    source=$netlist,$ATPG_OTHER_MODULES \
    techlib=$ATPGLIB \
    $black_box_args \
    industrycompatible=yes \
    teiperiod=_d0t_ \
    truetime=yes

#exec ./et/et_checks.sh; CheckLogs $workdir/testresults/logs/log_build_model
#####################################################
#  This is the normal scan test
#####################################################

puts "Running build_testmode $testmode "
build_testmode \
    workdir=$workdir \
    testmode=$testmode \
    modedef=FULLSCAN_TIMED \
    assignfile=${DDR_WORKAREA}/${DESIGN}_static.assignfile \
    allowflushedmeasures=yes \
    $et_tdrpath

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

#####################################################
#  This is the full dynamic test
#####################################################

puts "Running build_testmode fulldynamic "
build_testmode \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    modedef=FULLSCAN_TIMED \
    seqdef=${DDR_WORKAREA}/${DESIGN}_fulldynamic.seqdef \
    assignfile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.assignfile \
    allowflushedmeasures=yes \
    $et_tdrpath

puts "Running verify_test_structures $testmode "
verify_test_structures \
    workdir=$workdir \
    xclockanalysis=yes \
    testxsource=yes \
    testmode=FULLDYNAMIC

CheckTSVlog $workdir/testresults/logs/log_verify_test_structures_FULLDYNAMIC

puts "Running report_test_structures $testmode "
report_test_structures \
    workdir=${_ATPGWORK_PATH} \
    testmode=FULLDYNAMIC \
    reportscanchain=all \
    reportclockaffiliation=scan \
    reportregsinactive=yes \
    reportregsfloat=all \
    reportppicutpoints=yes \
    reportpi=yes \
    reportpo=yes \
    reportregscount=yes

#####################################################
#  This is the dynamic slow test
#####################################################

puts "Running build_testmode fulldynamic_slow "
build_testmode \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    modedef=FULLSCAN_TIMED \
    seqdef=${DDR_WORKAREA}/${DESIGN}_fulldynamic.seqdef \
    assignfile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.assignfile \
    allowflushedmeasures=yes \
    $et_tdrpath

puts "Running verify_test_structures fulldynamic "
verify_test_structures \
    workdir=$workdir \
    xclockanalysis=yes \
    testxsource=yes \
    testmode=FULLDYNAMIC_slow

CheckTSVlog $workdir/testresults/logs/log_verify_test_structures_FULLDYNAMIC_slow

puts "Running report_test_structures fulldynamic_slow "
report_test_structures \
    workdir=${_ATPGWORK_PATH} \
    testmode=FULLDYNAMIC_slow \
    reportscanchain=all \
    reportclockaffiliation=scan \
    reportregsinactive=yes \
    reportregsfloat=all \
    reportppicutpoints=yes \
    reportpi=yes \
    reportpo=yes \
    reportregscount=yes

#####################################################
#  This is the OPCG Bypass test
#####################################################

puts "Running build_testmode opcg bypass "
build_testmode \
    workdir=$workdir \
    testmode=opcgbypass \
    modedef=FULLSCAN_TIMED \
    seqdef=${DDR_WORKAREA}/${DESIGN}_opcgbypass.seqdef \
    assignfile=${DDR_WORKAREA}/${DESIGN}_opcgbypass.assignfile \
    allowflushedmeasures=yes \
    $et_tdrpath

puts "Running verify_test_structures opcg bypass "
verify_test_structures \
    workdir=$workdir \
    xclockanalysis=yes \
    testxsource=yes \
    testmode=opcgbypass

CheckTSVlog $workdir/testresults/logs/log_verify_test_structures_opcgbypass

puts "Running report_test_structures opcgbypass "
report_test_structures \
    workdir=${_ATPGWORK_PATH} \
    testmode=opcgbypass \
    reportscanchain=all \
    reportclockaffiliation=scan \
    reportregsinactive=yes \
    reportregsfloat=all \
    reportppicutpoints=yes \
    reportpi=yes \
    reportpo=yes \
    reportregscount=yes


#CheckLogs $? "$workdir/testresults/logs/log_report_test_structures_$testmode"

puts "Running build_faultmodel "
build_faultmodel \
    workdir=$workdir \
    $faultrulefile_arg \
    overwrite=yes

#CheckLogs $? "$workdir/testresults/logs/log_build_faultmodel"

if [info exists ATPG_SDC_FILE] {
    puts "Reading scanmode SDC"
    read_sdc \
        workdir=$workdir \
        testmode=$testmode \
        sdcpath=${ATPG_SDC_FILE} \
        sdc=${DESIGN}_static.sdc
}

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

#puts "Running create_logic_tests $testmode logic "
create_logic_tests \
    workdir=$workdir \
    testmode=$testmode \
    experiment=logic \
    usesdc=yes \
    testreset=yes \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

#CheckLogs $? "$workdir/testresults/logs/log_create_logic_tests_$testmode_$DESIGN_atpg"

puts "Running compact Stuckat vectors"
compact_vectors \
    workdir=$workdir \
    testmode=$testmode \
    reorder=coverage \
    inexperiment=logic \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic patterns "
commit_tests \
    workdir=$workdir \
    testmode=$testmode \
    inexperiment=logic


##########################################
#AT_SPEED PATTERNS (no PI transitions) for FULLDYNAMIC Test Mode
##########################################
puts "Running create_scanchain_delay_tests fulldynamic scan "
create_scanchain_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    experiment=scan

puts "Running commit_tests fulldynamic scan "
commit_tests \
    testmode=FULLDYNAMIC \
    inexperiment=scan


if [info exists ATPG_SDC_FILE] {
    puts "Removing scanmode SDC"
    remove_sdc \
        workdir=$workdir \
        testmode=FULLDYNAMIC
    puts "Reading fulldynamic and fulldynamic_atspeed SDC"
    read_sdc \
        workdir=$workdir \
        testmode=FULLDYNAMIC \
        sdcpath=${ATPG_SDC_FILE} \
        sdc=${DESIGN}_dynamic.sdc,${DESIGN}_dynamic_atspeed.sdc
}


set test_sequence "2pulse_slice_clk2x_only"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    inexperiment=logic_delay_$test_sequence

set test_sequence "2pulse_slice_clk1x_only"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    inexperiment=logic_delay_$test_sequence

set test_sequence "2pulse_top_clk1x_only"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC \
    inexperiment=logic_delay_$test_sequence


##########################################
#AT_SPEED PATTERNS (no PI transitions) for FULLDYNAMIC_SLOW Test Mode CLOCK Divided by 4
##########################################
if { $DIVIDE_BY_4 } {
    set test_sequence "2pulse_slice_db4_only"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"

    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC \
        append=no \
        experiment=logic_delay_$test_sequence \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC \
        inexperiment=logic_delay_$test_sequence

    set test_sequence "2pulse_top_db4_only"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"

    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC \
        append=no \
        experiment=logic_delay_$test_sequence \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC \
        inexperiment=logic_delay_$test_sequence
}


##########################################
#AT_SPEED PATTERNS (no PI transitions) for FULLDYNAMIC_SLOW Test Mode Clock halfrate
##########################################

if [info exists ATPG_SDC_FILE] {
    puts "Removing dynamic and dynamic_atspeed sdc"
    remove_sdc \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow
    puts "Reading fulldynamic and fulldynamic_atspeed SDC"
    read_sdc \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        sdcpath=${ATPG_SDC_FILE} \
        sdc=${DESIGN}_dynamic.sdc
}


set test_sequence "2pulse_slice_clk2x_only"
puts "Running create_logic_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_halfrate_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_halfrate_$test_sequence

set test_sequence "2pulse_slice_clk1x_only"
puts "Running create_logic_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_halfrate_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_halfrate_$test_sequence

set test_sequence "2pulse_top_clk1x_only"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_halfrate_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_halfrate_$test_sequence

if { $DIVIDE_BY_4 } {
    set test_sequence "2pulse_slice_db4_only"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"

    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_halfrate_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_halfrate_$test_sequence

    set test_sequence "2pulse_top_db4_only"
    puts "Running create_logic_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"

    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_halfrate_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_halfrate_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_halfrate_$test_sequence
}


##########################################
#AT_SPEED PATTERNS (no PI transitions) for FULLDYNAMIC_SLOW Test Mode, interclocks flavour
##########################################

set test_sequence "2pulse_slice_clk2x_to_slice_clk1x"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_$test_sequence

set test_sequence "2pulse_slice_clk1x_to_slice_clk2x"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_$test_sequence

set test_sequence "2pulse_slice_clk1x_to_top_clk1x"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_$test_sequence

set test_sequence "2pulse_top_clk1x_to_slice_clk1x"
puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
create_logic_delay_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    experiment=logic_delay_$test_sequence \
    append=no \
    usesdc=yes \
    sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
    testsequence=$test_sequence \
    linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
    latchsimulation=pessimistic \
    $ignoremeasures_arg \
    propxignore=yes \
    globalterm=none

puts "Running commit_tests logic - to save logic_delay patterns "
commit_tests \
    workdir=$workdir \
    testmode=FULLDYNAMIC_slow \
    inexperiment=logic_delay_$test_sequence

if { $DIVIDE_BY_4 } {
    set test_sequence "2pulse_top_clk1x_to_top_db4"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    puts "Running commit_tests logic - to save logic_delay patterns "
    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_$test_sequence

    set test_sequence "2pulse_top_db4_to_top_clk1x"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    puts "Running commit_tests logic - to save logic_delay patterns "
    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_$test_sequence

    set test_sequence "2pulse_slice_db4_to_top_db4"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    puts "Running commit_tests logic - to save logic_delay patterns "
    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_$test_sequence

    set test_sequence "2pulse_top_db4_to_slice_db4"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    puts "Running commit_tests logic - to save logic_delay patterns "
    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_$test_sequence

    set test_sequence "2pulse_slice_clk1x_to_slice_db4"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    puts "Running commit_tests logic - to save logic_delay patterns "
    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_$test_sequence

    set test_sequence "2pulse_slice_db4_to_slice_clk1x"
    puts "Running create_logic_delay_tests testmode=FULLDYNAMIC_slow logic at_speed, testsequence=$test_sequence"
    create_logic_delay_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        experiment=logic_delay_$test_sequence \
        append=no \
        usesdc=yes \
        sequencefile=${DDR_WORKAREA}/${DESIGN}_fulldynamic.testseq \
        testsequence=$test_sequence \
        linehold=${DDR_WORKAREA}/${DESIGN}_dynamic_$test_sequence.linehold \
        latchsimulation=pessimistic \
        $ignoremeasures_arg \
        propxignore=yes \
        globalterm=none

    puts "Running commit_tests logic - to save logic_delay patterns "
    commit_tests \
        workdir=$workdir \
        testmode=FULLDYNAMIC_slow \
        inexperiment=logic_delay_$test_sequence
}


##########################################
#Write Vectors
##########################################

puts "Running write_vectors Verilog "

foreach tbfile [glob -nocomplain ${_ATPGWORK_PATH}/serial/*] {
    file delete $tbfile
}

write_vectors \
    workdir=$workdir \
    exportdir=${_ATPGWORK_PATH}/serial \
    testmode=$testmode \
    language=verilog \
    compressfiles=yes \
    scanformat=serial

write_vectors \
    workdir=$workdir \
    exportdir=${_ATPGWORK_PATH}/serial \
    testmode=FULLDYNAMIC \
    language=verilog \
    compressfiles=yes \
    scanformat=serial

write_vectors \
    workdir=$workdir \
    exportdir=${_ATPGWORK_PATH}/serial \
    testmode=FULLDYNAMIC_slow \
    language=verilog \
    compressfiles=yes \
    scanformat=serial

foreach tbfile [glob -nocomplain ${_ATPGWORK_PATH}/parallel/*] {
    file delete $tbfile
}

write_vectors \
    workdir=$workdir \
    exportdir=${_ATPGWORK_PATH}/parallel \
    testmode=$testmode \
    language=verilog \
    compressfiles=yes \
    scanformat=parallel

write_vectors \
    workdir=$workdir \
    exportdir=${_ATPGWORK_PATH}/parallel \
    testmode=FULLDYNAMIC \
    language=verilog \
    compressfiles=yes \
    scanformat=parallel

write_vectors \
    workdir=$workdir \
    exportdir=${_ATPGWORK_PATH}/parallel \
    testmode=FULLDYNAMIC_slow \
    language=verilog \
    compressfiles=yes \
    scanformat=parallel

#CheckLogs $? "$workdir/testresults/logs/log_write_vectors_$testmode_$DESIGN_atpg"


##########################################
#AT_SPEED PATTERNS (with PI transitions) a  placeholder for possible  future development
##########################################

#if { ($TEST_CG_ENABLE_PORT == "") || ($TEST_CG_ENABLE_PORT != $SHIFT_ENABLE_PORT) } {

 #  if { $TEST_CG_ENABLE_PORT != "" } {
 #     set ATPG_CG_ENABLE_PORT $TEST_CG_ENABLE_PORT
 #  } else {
  #    set ATPG_CG_ENABLE_PORT "scanen_cg"
  # }

#   foreach LINEHOLD $LINEHOLD_VALUE {

      # create linehold file
#      file mkdir [file dirname $LINEHOLD_FILE]
#      file delete $LINEHOLD_FILE
#      set LINEHOLDSF [open ${LINEHOLD_FILE} w]
#      puts $LINEHOLDSF "HOLD $ATPG_CG_ENABLE_PORT = $LINEHOLD;"
#      close $LINEHOLDSF

#      puts "Running create_logic_tests $testmode logic at_speed with PI transitions ($ATPG_CG_ENABLE_PORT = $LINEHOLD)"
#      create_logic_delay_tests \
#         workdir=$workdir \
#         testmode=$testmode \
#         experiment=logic_delay_pi_trans \
#         append=$ATPG_APPEND \
#         allowedpitransitions=999 \
#         clockconstraints=${ATPG_CLOCK_CONSTRAINTS_FILE} \
#         linehold=$LINEHOLD_FILE
#
#      set ATPG_APPEND "yes"

#   }
#
#} else {
#
#   puts "Running create_logic_tests $testmode logic at_speed with PI transitions"
#   create_logic_delay_tests \
#     workdir=$workdir \
#     testmode=$testmode \
#     experiment=logic_delay_pi_trans \
#     append=$ATPG_APPEND \
#     allowedpitransitions=999 \
#     clockconstraints=${ATPG_CLOCK_CONSTRAINTS_FILE}
#
#   set ATPG_APPEND "yes"
#
#}

#puts "Running commit_tests logic - to save logic_delay patterns "
#commit_tests \
#  workdir=$workdir \
#  testmode=$testmode \
#  inexperiment=logic_delay_pi_trans


puts "Encounter Test Use Model Script Complete"
exit 0
