tclmode
// script to run additonal LEC commands prior to exiting the RC generated dofile

// Report design details
report_design_data

// Report lec environment setup
report_environment

// Report final result
report_compare_data -summary                > ${_LEC_LOG_PATH}/rtl2final_result.rpt

// Report unmapped points
report_unmapped_points -summary             > ${_LEC_LOG_PATH}/rtl2final_unmapped.rpt
report_unmapped_points -extra -unreachable >> ${_LEC_LOG_PATH}/rtl2final_unmapped.rpt
report_unmapped_points -notmapped           > ${_LEC_LOG_PATH}/rtl2final_notmapped.rpt

// Report floating signals
report_floating_signals -all -both          > ${_LEC_LOG_PATH}/rtl2final_floating.rpt

// Report a humanly readable result for top level only
 report_verification                        > ${_LEC_LOG_PATH}/rtl2final_verification.rpt
 
// Generate html report
tclmode
if {$HTML_REPORT} {
rename source ""
rename _source source
set myCustom [list "result<SCALE(/1000)> result<LINK=${_LEC_LOG_PATH}/rtl2final_result.rpt>"]
lappend myCustom [list "unmapped" "unmapped<LINK=${_LEC_LOG_PATH}/rtl2final_unmapped.rpt>"]
lappend myCustom [list "notmapped" "notmapped<LINK=${_LEC_LOG_PATH}/rtl2final_notmapped.rpt>"]
lappend myCustom [list "floating" "floating<LINK=${_LEC_LOG_PATH}/rtl2final_floating.rpt>"]
lappend myCustom [list "verification" "verification<LINK=${_LEC_LOG_PATH}/rtl2final_verification.rpt>"]

measure qor -custom ${myCustom} -name map2final  ${DUT_PATH}/${DESIGN}_dashboard/qor.html  

}

vpxmode
