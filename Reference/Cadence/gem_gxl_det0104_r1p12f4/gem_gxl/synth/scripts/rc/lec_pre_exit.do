tclmode
// script to run additonal LEC commands prior to exiting the RC generated dofile
// Report design details
report_design_data

// Report lec environment setup
report_environment

// Report final result
report_compare_data -summary > ${_LEC_LOG_PATH}/rtl2mapped_result.rpt

// Report unmapped points
report_unmapped_points -summary             > ${_LEC_LOG_PATH}/rtl2mapped_unmapped.rpt
report_unmapped_points -extra -unreachable >> ${_LEC_LOG_PATH}/rtl2mapped_unmapped.rpt
report_unmapped_points -notmapped           > ${_LEC_LOG_PATH}/rtl2mapped_notmapped.rpt

// Report floating signals
report_floating_signals -all -both          > ${_LEC_LOG_PATH}/rtl2mapped_floating.rpt

// Report a the hierarchcial compare result
report_hier_compare_result -summary > ${_LEC_LOG_PATH}/rtl2mapped_hier_comp.rpt

if {$HTML_REPORT} {
rename source ""
rename _source source
set myCustom [list "result<SCALE(/1000)> result<LINK=${_LEC_LOG_PATH}/rtl2mapped_result.rpt>"]
lappend myCustom [list "unmapped" "unmapped<LINK=${_LEC_LOG_PATH}/rtl2mapped_unmapped.rpt>"]
lappend myCustom [list "notmapped" "notmapped<LINK=${_LEC_LOG_PATH}/rtl2mapped_notmapped.rpt>"]
lappend myCustom [list "floating" "floating<LINK=${_LEC_LOG_PATH}/rtl2mapped_floating.rpt>"]
lappend myCustom [list "verification" "hier compare<LINK=${_LEC_LOG_PATH}/rtl2mapped_hier_comp.rpt>"]

measure qor -custom ${myCustom} -name rtl2mapped_lec  ${DUT_PATH}/${DESIGN}_dashboard/qor.html  

}
vpxmode

