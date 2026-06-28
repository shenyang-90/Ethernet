tclmode
# script to run additional LEC commands prior to exiting the RC generated dofile
# Report design details
report_design_data

# Report lec environment setup
report_environment

# Report final result
report_compare_data -summary > ${_LEC_LOG_PATH}/rtl2mapped_result.rpt

# Report unmapped points
report_unmapped_points -summary             > ${_LEC_LOG_PATH}/rtl2mapped_unmapped.rpt
report_unmapped_points -extra -unreachable >> ${_LEC_LOG_PATH}/rtl2mapped_unmapped.rpt
report_unmapped_points -notmapped           > ${_LEC_LOG_PATH}/rtl2mapped_notmapped.rpt

# Report floating signals
report_floating_signals -all -both          > ${_LEC_LOG_PATH}/rtl2mapped_floating.rpt

# Report a the hierarchcial compare result
report_hier_compare_result -summary > ${_LEC_LOG_PATH}/rtl2mapped_hier_comp.rpt


