//**************************************************************************
//*
//* Copyright (C) 2012 Cadence Design Systems, Inc.
//* All rights reserved.
//*
//**************************************************************************

tclmode
source project.tcl

vpxmode

//**************************************************************************
//* Sets up the log file and instructs the tool to display usage information
//**************************************************************************

tclmode
set LCL_LOG_PATH ${_LEC_LOG_PATH}/lec_g2g_reports

  if {![file exists $LCL_LOG_PATH]} {
    mkdir $LCL_LOG_PATH
    puts "Creating directory $LCL_LOG_PATH"
  }

set_log_file ${LCL_LOG_PATH}/lec.flat.log -replace
vpxmode 

usage -auto -elapse


dofile $IPF_DESIGN_FLOW_SCRIPTS/rc/lec_pre_read.do
tclmode
if [info exists POWER_INTENT_FILE] {
	if { [ regexp {\.upf?$} ${POWER_INTENT_FILE} ] } {
	set_lowpower_option -analysis_style post_synthesis
	set_lowpower_option -native_1801
	} 
}

read_library -liberty -statetable -pg_pin -file ./liblist.f

read_design -verilog -replace -golden ${_OUTPUTS_PATH}/${DESIGN}.v.gz

read_design -verilog -replace -revised ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v

// Read power intent
if [info exists POWER_INTENT_FILE] {
	if { [ regexp {\.cpf?$} ${POWER_INTENT_FILE} ] } {
	read_power_intent -cpf post_synthesis  ${POWER_INTENT_FILE}  
	} else {
	read_power_intent -1801   ${POWER_INTENT_FILE}  
	} 
}


// Report blackboxes
report_black_box -nohier > ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_bbox.rpt

vpxmode
report design data
report black box -detail

//**************************************************************************
//* Specifies renaming rules
//**************************************************************************

// add renaming rule <rulename> <string><string>[-Golden |-Revised |-BOth]

//**************************************************************************
//* Specifies user constraints for test/dft/etc.
//**************************************************************************

add pin constraint 0 scanen  -both 
add ignore output  *scanout* -both

//**************************************************************************
//* Specifies the modeling directives for constant optimization 
//* or clock gating
//**************************************************************************

//set flatten model  -seq_constant 
//set flatten model  -gated_clock

//**************************************************************************
//* Specifies the number of threads to enable multithreading
//**************************************************************************

//set parallel option -threads 4 

//**************************************************************************
//* Flattens, remodels, and maps the design
//**************************************************************************

set system mode lec

//**************************************************************************
//* Enables auto analysis to help resolve issues from sequential 
//* redundancy, sequential constants, clock gating, or sequential merging
//**************************************************************************

analyze setup -verbose  

//**************************************************************************
//* Runs the comparison
//**************************************************************************

add compare point -all
compare 

//**************************************************************************
//* Automatically tries to resolve any remaining abort points
//**************************************************************************

//analyze abort -compare 

//**************************************************************************
//* Generates the compare reports 
//**************************************************************************

tclmode

// Report final result
report_compare_data -noneq >  ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_results.rpt
report_compare_data -abort >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_results.rpt
report_verification        >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_results.rpt

// Report unmapped points
report_unmapped_points -summary             > ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_unmapped.rpt
report_unmapped_points -extra -unreachable >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_unmapped.rpt
report_unmapped_points -notmapped           > ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_notmapped.rpt

// Report floating signals
report_floating_signals -all -both          > ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_floating.rpt

report_environment                      > ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
echo "Pin Constraints"                  >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
report_pin_constraints -both            >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
echo "Ignored Outputs"                  >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
report_ignored_outputs -both -all       >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
echo "Ignored Inputs"                   >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
report_ignored_inputs -both -all        >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
echo "Tied signals applied by the User" >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt
report_tied_signals -Class User -both   >> ${_LEC_LOG_PATH}/lec_g2g_reports/lec_g2g_environment.rpt



vpxmode
exit -force
