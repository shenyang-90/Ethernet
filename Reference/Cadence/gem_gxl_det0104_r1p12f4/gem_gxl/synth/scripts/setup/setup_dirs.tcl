# The directories can be updated to suit the project setup.
# However, The directory listing below is the IP Factory recommendation.
set _SYNTH_PATH       $LOG_PATH/synth
set _PnR_PATH         $LOG_PATH/pnr
set _DFT_PATH         $LOG_PATH/dft
set _CCD_PATH         $LOG_PATH/ccd
set _SIM_PATH         $LOG_PATH/nc
set _PWR_PATH         $LOG_PATH/pwr
set _JOULES_PATH      $LOG_PATH/joules
set _CLP_PATH         $LOG_PATH/clp

set _CCD_INPUT_PATH   $CFG_DIR/${CONFIG}/ccd
set _CCD_RPT_PATH     $LOG_PATH/ccd/${STAMP}/reports_${CONFIG}

set SPYGLASS_PACK_LOCATION $SPYGLASS_PACK_LOCATION

set COMPILATION_CHECK_RPT $LOG_PATH/compilation_check/${STAMP}/${CONFIG}

set _SUPERLINT_INPUT_PATH   $CFG_DIR/${CONFIG}/superlint
set _SUPERLINT_PATH         $LOG_PATH/superlint/${STAMP}/reports_${CONFIG}

set _AFL_INPUT_PATH   $CFG_DIR/${CONFIG}/afl
set _AFL_PATH         $LOG_PATH/afl/${STAMP}/reports_${CONFIG}

set _OUTPUTS_PATH     ${_SYNTH_PATH}/${STAMP}/data_${CONFIG}
set _REPORTS_PATH     ${_SYNTH_PATH}/${STAMP}/reports_${CONFIG}
set _DFT_REPORTS_PATH ${_SYNTH_PATH}/${STAMP}/reports_${CONFIG}
set _LEC_LOG_PATH     ${_SYNTH_PATH}/${STAMP}/reports_${CONFIG}
set _SYNTH_LOG_PATH   ${_SYNTH_PATH}/${STAMP}/reports_${CONFIG}
set _RCENC_PATH       ${_SYNTH_PATH}/${STAMP}/data_${CONFIG}
set _GENUSMODUS_PATH  ${_SYNTH_PATH}/${STAMP}/data_${CONFIG}
set _RCET_PATH        ${_SYNTH_PATH}/${STAMP}/data_${CONFIG}

set _PNR_DATA_PATH    ${_PnR_PATH}/${STAMP}/data_${CONFIG}
set _PNR_RPTS_PATH    ${_PnR_PATH}/${STAMP}/reports_${CONFIG}
set _PNR_RVW_PATH     ${_PnR_PATH}/${STAMP}/review_${CONFIG}

set _ATPGWORK_PATH      ${_DFT_PATH}/${STAMP}/data_${CONFIG}

set _SIMWORK_PATH      ${_SIM_PATH}/${STAMP}/reports_${CONFIG}

set _PWR_RPTS_PATH    ${_PWR_PATH}/${STAMP}/reports_${CONFIG}

set _JOULES_DATA_PATH ${_JOULES_PATH}/${STAMP}/reports_${CONFIG}
set _JOULES_RPT_PATH  ${_JOULES_PATH}/${STAMP}/reports_${CONFIG}
set _CLP_RPT_PATH     ${_CLP_PATH}/${STAMP}/reports_${CONFIG}
set TMAX_ROOT 	      $IPF_DESIGN_FLOW_SCRIPTS/tmax
