################################################################################
#                                                                              #
# COPYRIGHT (c) 2013 Cadence Design Systems, Inc.  All rights reserved.        #
# --------------------------------------------------------------               #
# This code is proprietary and confidential information of                     #
# Cadence Design Systems. It may not be reproduced, used or transmitted        #
# in any form whatsoever without the express and written                       #
# permission of Cadence Design Systems.                                        #
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
#if { [get_ports -quiet scanmode] != "" } {
#                set_case_analysis 0  [get_ports scanmode]
#                }

#set_case_analysis 0 [get_pins -regexp -hier -nocase <clock_mux/S>]

###############################################################################
# Source Clocks
###############################################################################   
#------------------------------------------------------------------------------
# Controller CLK1 clock: regular mode 
echo "# Controller CLK1 clock: regular mode" 
#------------------------------------------------------------------------------
#This is an example of a clock definition on a port
create_clock -name CLK1 [get_ports <path_to_CLK1_port>]  -period $CLK1_PERIOD -waveform "0 $CLK1_HALF" 

#------------------------------------------------------------------------------
# CLK2 clock: regular mode 
echo "# CLK2 clock: regular mode" 
#------------------------------------------------------------------------------
#This is an example of a clock definition on an internal pin
create_clock -name CLK2 [get_pins -regexp -hier -nocase <path_to_CLK2_pin>]  -period $CLK2_PERIOD -waveform "0 $CLK2_HALF" 


###############################################################################
# Generated Clocks
###############################################################################   
create_generated_clock -name CLK1_GENERATED_CLK -divide_by 1 -add -master_clock [get_clocks CLK1] \
		       -source [get_ports <path_to_CLK1_port>] \
		       [get_pins -regexp -hier -nocase <path_to_CLK1_GENERATED_CLK_PIN>]	 
    				       

create_generated_clock -name CLK2_GENERATED_CLK -divide_by 2 -add -master_clock [get_clocks CLK2] \
		       -source [get_pins -regexp -hier -nocase <path_to_CLK2_pin>] \
		       [get_pins -regexp -hier -nocase <path_to_CLK2_GENERATED_CLK_PIN>]	 


###############################################################################
# Clock groups
###############################################################################
#Use -physically_exclusive option for clocks that share the same pin (cannot physically exist together) 
set_clock_groups -async -name grp1 -group {CLK1 CLK1_GENERATED_CLK} \
-group {CLK2 CLK2_GENERATED_CLK}    
 
set_clock_groups -physically_exclusive -name gen_grp  -group {CLK1 CLK1_GENERATED_CLK} \
 -group {CLK2 CLK2_GENERATED_CLK } 


#####################################################
# Design Rule constants. These values may be changed
# depending on design environment.  
#####################################################
set MAX_FANOUT  20 
set MAX_TRANS   0.3 
set MAX_CAP     0.2 
#
set OUTPUT_LOAD [expr 3 x [get_attr [get_lib_pins $DRIVE_CELL/A] pin_capacitance]] 

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
set clk1_input [all_clk1_inputs]
set clk2_input [all_clk2_inputs]


### Group all outputs ###
### Remove clock out ports from outputs ###
set clk1_output [all_clk1_outputs] 
set clk2_output [all_clk2_outputs] 


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

#I2O delay example
#Max delay takes into account the external delay of the IO's and will override the normal setup I2O check.
#So setting a max delay of (combined IO delay) + (max internal combinational delay) will check any combinatorial paths your design has correctly.
#Where $MAX_DELAY = input delay + output delay + I2O COMBINATORIAL DELAY

set_max_delay $MAX DELAY Åfrom [get_ports PORTS_IN] Åto [get_ports PORTS_OUT]

# If you have an aynchronous boundary then the set_clock_groups commands results in the paths between these clocks being treated as a false.
# If you wish to constrain the async boundary then youn can do so by using the following
set_max_delay -from CLK1 -to CLK2 $CLK2_HALF


################################################## 
# Input constraints: input transition  
echo "# Input constraints: input transition" 
################################################## 
#CDC/spyglass report conflicting constraints between set_input_transition and set_driving cell
#We regard set_driving_cell as a more 'complete' constraint so favour it's use.
#set_input_transition 0.01 $clk1_input
#set_input_transition 0.01 $clk2_input

#It is not recommended to set the clock transition as it causes unrealistic delays through registers in ideal mode in EDI
#set_clock_transition 0.1      [all_clocks]

################################################## 
# Input constraints: drive cell  
echo "# Input constraints: set drive cell" 
################################################## 
set_driving_cell -lib_cell $DRIVE_CELL -pin Z [remove_from_collection [all_inputs] \
                 [get_ports {clk1 clk2 }] ]

################################################## 
# Output constraints: output load  
echo "# Output constraints: output load" 
################################################## 
set_load $OUTPUT_LOAD [all_outputs]

#Alternatively use the cap of the driving cell as the output load
#set pin_cap [get_attr [get_lib_pins $DRIVE_CELL/A] pin_capacitance]
#set_load [expr (3 * $pin_cap)] [all_outputs]

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

###############################################################################
# Preserve modules e.g. sync modules
###############################################################################
set_dont_touch [get_cell -hier *u_phy_reset_sync*] true

###############################################################################
# Additional false paths as agreed by designer
###############################################################################
set_false_path -through [get_pins -regexp -hier -nocase {*/flop_reg/D} ]

###############################################################################
# MultiCycle paths as agreed by designer
###############################################################################
#Must be defined for setup and hold
set_multicycle_path 2 -setup -from CLK1 -through  <pin>
set_multicycle_path 1 -hold -from CLK1 -through  <pin>

###############################################################################
# Max Delay paths as agreed by designer
###############################################################################
set_max_delay  5 -from CLK1 -through  <pin>

###############################################################################
# Min Delay paths as agreed by designer
###############################################################################
set_min_delay  3 -from CLK1 -through  <pin>

