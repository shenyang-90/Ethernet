################################################################
## Tmax setup file
## Author: Vladimir Zivkovic
## SIS, Livingston
################################################################

#Control Licenses
set hdl_keep_licenses false

# Set-up Cache
set cacheDir "./lib" 
set cache_read " $synopsys_root/libraries/syn $cacheDir " 
set cache_write $cacheDir 
set cache_file_chmod_octal "666" 
set cache_dir_chmod_octal "1777" 
set cache_write_info true 
set cache_read_info true 

# Set-up Check Poiniting if required
#set compile_checkpoint_filename ./ddb/checkpoint.db
#set compile_checkpoint_phases true 

# Control Optimsiation
set compile_delete_unloaded_sequential_cells false
set hdlin_preserve_sequential true
set compile_seqmap_propagate_constants false

# Control timing arc's
#set enable_recovery_removal_arcs true

# Control input reading
set hdlin_check_no_latch true 

# Control generate netlist
set verilogout_equation false 
set verilogout_show_unconnected_pins true
set verilogout_no_tri true 

#How to supress messages
#set suppress_errors [concat $suppress_errors [list VER-129 VER-130 VER-173 VER-976]]

# No internal wires with escape characters 
set bus_naming_style {%s[%d]} 
set bus_dimension_separator_style "\]\[" 
set bus_inference_style {%s[%d]}
set hdlout_internal_busses true

######################
#set the path to models in the delivery area
######################

 set MODEL_PATH <specify the path to models in the delivery area>
 
 set ATPGLIB      [list <specify this variable to match the same one from the tech file> ]

   
# Modules to replace by black boxes (default: none)
set MODULES_TO_BLACK_BOX   [list <specify al black box modules> ]
#############################################################
#e.g.
#set MODULES_TO_BLACK_BOX   [list  cmn_ana1_decap_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r \
#				  ln_ana_decap_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r \
#			]
############################################				

# Instances to replace by TIEX's (default: none)
set INSTANCES_TO_BLACK_BOX  [list <specify all modules whose ports will be replaced with TIEX's> ]
#############################################################
#e.g. set INSTANCES_TO_BLACK_BOX  [list atb1_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r \
#				  atb0_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r \
#				  rstgen_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r \
#			    ]
############################################

set BEHAVIORAL_MODULES [list $MODEL_PATH/<specify here the list of behavioural modules> ]
#############################################################
# e.g. set BEHAVIORAL_MODULES [list $MODEL_PATH/cmn_anax2_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r.vams \
#			     $MODEL_PATH/cmn_ana_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r.vams \
#			     $MODEL_PATH/cmn_ana1_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r.vams \
#			     $MODEL_PATH/ln_ana_sd0301m_t16ffp_44_vg162_2xa1xdh3xevhv2y2r.vams \
#			     ]
#############################################################

set EXCEPTION_FILE          "" ;# SDC file for timing exceptions (default: none)
set PROTOCOL_PATTERNEXEC    "" ;# PatternExec to execute for TD DRC (default: none)
set SA_CAPTURE_CYCLES       "2";
set TD_CAPTURE_CYCLES       "" ;# integer max ATPG capture cycles (default: 2)
set GLOBAL_SLACK_FILE       "" ;# Slack File for Small Delay Defect Testing (default: none)
set SDDT_MAX_TMGN           "" ;# Tmgn for Small Delay Defect Testing (default: 20%)
set SDDT_MAX_DELTA          "" ;# Delta for Small Delay Defect Testing (default: 20% of max_tmgn)
set POWER_BUDGET            "" ;# Power budget for ATPG (default: none - use DRC result)

