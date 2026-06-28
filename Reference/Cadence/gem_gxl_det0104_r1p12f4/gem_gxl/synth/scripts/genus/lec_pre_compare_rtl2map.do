tclmode
# Report blackboxes
report_black_box -nohier > ${_LEC_LOG_PATH}/rtl2mapped_bbox.rpt

report_environment                      > ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
echo "Pin Constraints"                  >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
report_pin_constraints -both            >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
echo "Ignored Outputs"                  >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
report_ignored_outputs -both -all       >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
echo "Ignored Inputs"                   >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
report_ignored_inputs -both -all        >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
echo "Tied signals applied by the User" >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt
report_tied_signals -Class User -both   >> ${_LEC_LOG_PATH}/rtl2mapped_environment.rpt


