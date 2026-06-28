################################################################################
#                                                                              #
# COPYRIGHT (c) 2013 Cadence Design Systems, Inc.  All rights reserved.        #
# --------------------------------------------------------------               #
# This code is proprietary and confidential information of                     #
# Cadence Design Systems. It may not be reproduced, used or transmitted        #
# in any form whatsoever without the express and written                       #
# permission of Cadence Design Systems.                                        #
#                                                                              #
# This is a scan_shift ONLY mode example constraints file                      #
# NB, a dedicated scan mode and associated constraints file is ONLY required   #
# when there is scan muxing present in the RTL, controlled by a dedicated      #
# scanmode input.                                                              #
#                                                                              #
################################################################################

###############################################################################
# Set SDC Version
###############################################################################
set sdc_version 1.7

################################################################################
#  Specify CLK1 clock period and name 
################################################################################
#An expr of 1000/125 gives a period of 8ns, a frequency of 125MHz.
set CLK1_PERIOD   [expr (1000.00/125.00) ]


################################################################################
#  Specify CLK2 clock period and name 
################################################################################
set CLK2_PERIOD   [expr (1000.00/125.00)  ]
 

######################################################################################
#  Define Variables for Constraints
######################################################################################
#####################################################
#
#  Create variables for the external delay on 
#  each of the interfaced
#  By Default the logic under test gets 1/3 the timing
#  Budget.  Changing the vars will change the budget 
#  for the whole interface.
#
#####################################################
set CLK1_HALF         [expr 0.50 * $CLK1_PERIOD]
set CLK1_ONETHIRD     [expr 0.33 * $CLK1_PERIOD]
set CLK1_TWOTHIRD     [expr 0.67 * $CLK1_PERIOD]
set CLK1_TENTH        [expr 0.10 * $CLK1_PERIOD]

set CLK2_HALF        [expr 0.50 * $CLK2_PERIOD]
set CLK2_ONETHIRD    [expr 0.33 * $CLK2_PERIOD]
set CLK2_TWOTHIRD    [expr 0.67 * $CLK2_PERIOD]
set CLK2_TENTH       [expr 0.10 * $CLK2_PERIOD]


###############################################################################
# Set case analysis
###############################################################################
#Case analysis to be used to control design.
#Use a case analysis statement to switch between func mode and scan mode, or control clock muxes
set_case_analysis 1 [get_pins scanmode]
set_case_analysis 1 [get_pins scanen]
if { [get_ports -quiet scanen_cg] != "" } {
    set_case_analysis 1 [get_ports scanen_cg]
}

###############################################################################
# Source Clocks
###############################################################################   
#------------------------------------------------------------------------------
# CLK1 clock: scan_shift mode 
echo "# CLK1 clock: scan_shift mode" 
#------------------------------------------------------------------------------
#This is an example of a clock definition on a port (scan shift clocks should only be applied to ports)
create_clock -name CLK1 [get_ports <path_to_CLK1_port>]  -period $CLK1_PERIOD -waveform "0 $CLK1_HALF" 

#------------------------------------------------------------------------------
# CLK2 clock: scan_shift mode 
echo "# CLK2 clock: scan_shift mode" 
#------------------------------------------------------------------------------
#This is an example of a clock definition on a port (scan shift clocks should only be applied to ports)
create_clock -name CLK2 [get_ports <path_to_CLK2_port>]  -period $CLK2_PERIOD -waveform "0 $CLK2_HALF" 


#####################################################
# Design Rule constants. These values may be changed
# depending on design environment.  
#####################################################
set MAX_FANOUT  20 
set MAX_TRANS   0.3 
set MAX_CAP     0.2 
#
set OUTPUT_LOAD 0.1 

################################################## 
# Define design environments: 
echo "# Define design environments:" 
################################################## 

set_max_fanout $MAX_FANOUT [current_design]
set_max_transition $MAX_TRANS [current_design]
set_max_capacitance $MAX_CAP [current_design]


##################################################
#clock uncertainty
##################################################
set_clock_uncertainty 0.200 -setup [all_clocks]

#A hold uncertainty is applied for sign off - however for the purpose of proving our IP it's acceptable to apply a 0ps hold uncertainty.
#A large hold uncertainty in our RTL IP STA can often lead to false violations due solely to uncertainty and not design related. 
#So a 0ps uncertainty is suitable for our purposes.

#set_clock_uncertainty 0.055 -hold  [all_clocks]
set_clock_uncertainty 0.0 -hold  [all_clocks]

##################################################
# Constraints for all generic ports
echo "# Constraints for all generic ports"
##################################################
       
### Group all inputs ###
### Remove clock ports from inputs ###
set clk1_input [get_ports <all_clk1_inputs_except_scanin_ports>]
set clk2_input [get_ports <all_clk2_inputs_except_scanin_ports>]


### Group all outputs ###
### Remove clock out ports from outputs ###
set clk1_output [get_ports <all_clk1_outputs_except_scanout_ports>] 
set clk2_output [get_ports <all_clk2_outputs_except_scanout_ports>] 

### Set scan I/Os on relevant clocks ###
set clk1_scan_input  [get_ports <all_clk1_scanin_ports>]
set clk1_scan_output [get_ports <all_clk1_scanout_ports>]
set clk2_scan_input  [get_ports <all_clk2_scanin_ports>]
set clk2_scan_output [get_ports <all_clk2_scanout_ports>]

##################################################
## set delays
##################################################
#Max and min values for setup and hold checks
#min could be a negative value to allow hold margin
#Recommended to time reset input ports relative the their applicable clock or if none a virtual clock

set_input_delay  -max $CLK1_TWOTHIRD $clk1_input  -clock CLK1
set_input_delay  -min 0 $clk1_input  -clock CLK1

set_output_delay -max $CLK1_TWOTHIRD $clk1_output -clock CLK1
  
set_input_delay  -max $CLK2_TWOTHIRD $clk2_input  -clock CLK2
set_input_delay  -min 0 $clk2_input  -clock CLK2

set_output_delay -max $CLK2_TWOTHIRD $clk2_output -clock CLK2

##################################################
## set delays on scan I/Os
##################################################
set_input_delay  -max $CLK1_TWOTHIRD $clk1_scan_input  -clock CLK1
set_input_delay  -min 0 $clk1_scan_input  -clock CLK1

set_output_delay -max $CLK1_TWOTHIRD $clk1_scan_output -clock CLK1

set_input_delay  -max $CLK2_TWOTHIRD $clk2_scan_input  -clock CLK2
set_input_delay  -min 0 $clk2_scan_input  -clock CLK2

set_output_delay -max $CLK2_TWOTHIRD $clk2_scan_output -clock CLK2

################################################## 
# Output constraints: output load  
echo "# Output constraints: output load" 
################################################## 
set_load $OUTPUT_LOAD $clk1_output
set_load $OUTPUT_LOAD $clk2_output


################################################## 
# Input constraints: input transition  
echo "# Input constraints: input transition" 
################################################## 
#CDC/spyglass report conflicting constraints between set_input_transition and set_driving cell
#We regard set_driving_cell as a more 'complete' constraint so favour it's use.
#set_input_transition 0.01 $clk1_input
#set_input_transition 0.01 $clk2_input

#It is not recommended to set the clock transition as it causes unrealistic delays through registers in ideal mode in EDI
#set_clock_transition 0.03      [all_clocks]

################################################## 
# Input constraints: drive cell  
#echo "# Input constraints: set drive cell" 
################################################## 
set_driving_cell -lib_cell $DRIVE_CELL -pin Z [remove_from_collection [all_inputs] \
                 [get_ports {clk1 clk2 }] ]


################################################################################
# False Paths
################################################################################
### Clock Example ###
set_false_path -from <CLK>  -to <CLK>


# Constant and aync signals
set_false_path -from [get_ports {constant_signal}]
set_false_path -from [get_ports {async_signal}]


# External boundary scan control interface example
set_false_path -from [get_ports {bscan_ext_*}]
set_false_path -from [get_ports {bscan_mode_en*}]


###############################################################################
# Don't optimise power nets
###############################################################################
#NB Do NOT set clock networks as dont_touch, this will cause confusion post CCOPT.
set_dont_touch_network [get_ports {gnd}]
set_dont_touch_network [get_ports {avdd}]
set_dont_touch_network [get_ports {vaux}]
