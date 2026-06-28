# Set skew within a clock tree
set INTRA_CLOCK_SKEW 0.1

# Input slew
set NOMINAL_SLEW 0.1

# Hold times relate to potential driving FF - worst case FF
set NOMINAL_HOLD 0.1

# Set the load on the outputs
set INVCAP 0.0023

set MAX_FANOUT  20 
set MAX_TRANS   0.3
set MAX_CAP     0.2

echo "#####################################################"
echo "Reading Design Constraints in /proj/giggle/work/fmalaspi/generated_cfgs_out/ip7014a/gem_gxl/synth/constraints/cfg/pbuf_3qs_axi//gem_gxl_pbuf_3qs_axi.func.sdc"
echo "#####################################################"

# Setting some absolute values for IEEE spec timings
set ABS_MAX_2N00 [ expr 2.00 ]
set ABS_MAX_2N50 [ expr 2.50 ]
set ABS_MAX_5N50 [ expr 5.5 ]
set ABS_MAX_6N00 [ expr 6.0 ]
set ABS_MIN_0N50 [ expr 0.5 ]
set ABS_MIN_1N00 [ expr 1.0 ]
set ABS_MIN_1N50 [ expr 1.50 ]

# The following allows you to overconstrain all clock frequencies 
# set to 1 for no overconstraint.  set to 0.5 for a 100% overconstraint etc 
set clk_overconstraint 1

##########################################################
# Clocks ...

# Clock aclk, constrained to 400Mhz
set aclk_period [expr 2.5 * $clk_overconstraint]
set aclk_generic_indel [expr $aclk_period * 0.5]
set aclk_generic_outdel [expr $aclk_period * 0.5]
create_clock [get_ports aclk] -name aclk -period $aclk_period -waveform "0 [expr $aclk_period * 0.50]"
set_clock_transition $NOMINAL_SLEW [get_clocks {aclk}]
# There is considerable logic on the following inputs for clock "aclk". As such a fixed low 500ps delay has been applied
# in order to meet the high frequencies required for this clock domain.
# In this case, if this causes a problem for a real SoC, an AXI register slice can be added to provide extra timing margin at the cost of cycle latency
set_input_delay -add_delay 0.5 -max -clock [get_clocks {aclk}]  [get_ports "awready wready bid bresp bvalid arready rid rdata rresp rlast rvalid"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {aclk}]  [get_ports " awready wready bid bresp bvalid arready rid rdata rresp rlast rvalid"]
# There is considerable logic on the SRAM data output before it is sampled by a flop. As such a fixed 1ns delay has been applied.
# On review of several RAM datasheets this is ample time.
set_input_delay -add_delay 1.0 -max -clock [get_clocks {aclk}]  [get_ports " rxdpram_dob emac_rxdpram_dob"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {aclk}]  [get_ports "  rxdpram_dob emac_rxdpram_dob"]
set_output_delay -add_delay $aclk_generic_outdel -max -clock [get_clocks {aclk}]  [get_ports " txdpram_wea txdpram_ena txdpram_addra txdpram_dia rxdpram_web rxdpram_enb rxdpram_addrb  emac_txdpram_wea emac_txdpram_ena emac_txdpram_addra emac_txdpram_dia emac_rxdpram_web emac_rxdpram_enb emac_rxdpram_addrb  rx_databuf_wr_q0 rx_databuf_wr_q1 rx_databuf_wr_q2"]
# There is considerable logic feeding some of the following outputs for clock "aclk". As such a fixed low 500ps delay has been applied
# in order to meet the high frequencies required for this clock domain.
# In this case, if this causes a problem for a real SoC, an AXI register slice can be added to provide extra timing margin at the cost of cycle latency
set_output_delay -add_delay 0.5 -max -clock [get_clocks {aclk}]  [get_ports "awid awaddr awlen awsize awburst awlock awcache awprot awqos awvalid wdata wstrb wlast wvalid wid bready rready arid araddr arlen arsize arburst arlock arcache arprot arqos arvalid"]
set_output_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {aclk}]  [get_ports "awid awaddr awlen awsize awburst awlock awcache awprot awqos awvalid wdata wstrb wlast wvalid wid bready rready arid araddr arlen arsize arburst arlock arcache arprot arqos arvalid  txdpram_wea txdpram_ena txdpram_addra txdpram_dia rxdpram_web rxdpram_enb rxdpram_addrb  emac_txdpram_wea emac_txdpram_ena emac_txdpram_addra emac_txdpram_dia emac_rxdpram_web emac_rxdpram_enb emac_rxdpram_addrb  rx_databuf_wr_q0 rx_databuf_wr_q1 rx_databuf_wr_q2"]

# Clock rx_clk, constrained to 125Mhz
set rx_clk_period [expr 8 * $clk_overconstraint]
set rx_clk_generic_indel [expr $rx_clk_period * 0.6]
set rx_clk_generic_outdel [expr $rx_clk_period * 0.6]
create_clock [get_ports rx_clk] -name rx_clk -period $rx_clk_period -waveform "0 [expr $rx_clk_period * 0.50]"
set_clock_transition $NOMINAL_SLEW [get_clocks {rx_clk}]
set_input_delay -add_delay $rx_clk_generic_indel  -max -clock [get_clocks {rx_clk}]  [get_ports "ext_match1 ext_match2 ext_match3 ext_match4 rx_er rx_dv rxd"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {rx_clk}]  [get_ports "ext_match1 ext_match2 ext_match3 ext_match4 rx_er rx_dv rxd"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {rx_clk}]  [get_ports "ext_match1 ext_match2 ext_match3 ext_match4 rx_er rx_dv rxd"]
set_output_delay -add_delay $rx_clk_generic_outdel -max -clock [get_clocks {rx_clk}]  [get_ports "ext_da ext_da_stb ext_sa ext_sa_stb ext_type ext_type_stb ext_vlan_tag1 ext_vlan_tag1_stb ext_ip_sa ext_vlan_tag2 ext_vlan_tag2_stb ext_ip_sa_stb ext_ip_da ext_ip_da_stb wol ext_source_port ext_sp_stb ext_dest_port ext_dp_stb ext_ipv6 sof_rx sync_frame_rx delay_req_rx pdelay_req_rx pdelay_resp_rx rx_pfc_paused pfc_negotiate rxdpram_dia rxdpram_wea rxdpram_ena rxdpram_addra emac_rxdpram_dia emac_rxdpram_wea emac_rxdpram_ena emac_rxdpram_addra "]
set_output_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {rx_clk}]  [get_ports "ext_da ext_da_stb ext_sa ext_sa_stb ext_type ext_type_stb ext_vlan_tag1 ext_vlan_tag1_stb ext_ip_sa ext_vlan_tag2 ext_vlan_tag2_stb ext_ip_sa_stb ext_ip_da ext_ip_da_stb wol ext_source_port ext_sp_stb ext_dest_port ext_dp_stb ext_ipv6 sof_rx sync_frame_rx delay_req_rx pdelay_req_rx pdelay_resp_rx rx_pfc_paused pfc_negotiate rxdpram_dia rxdpram_wea rxdpram_ena rxdpram_addra emac_rxdpram_dia emac_rxdpram_wea emac_rxdpram_ena emac_rxdpram_addra "]

# Clock tsu_clk, constrained to 400Mhz
set tsu_clk_period [expr 2.5 * $clk_overconstraint]
set tsu_clk_generic_indel [expr $tsu_clk_period * 0.6]
set tsu_clk_generic_outdel [expr $tsu_clk_period * 0.6]
create_clock [get_ports tsu_clk] -name tsu_clk -period $tsu_clk_period -waveform "0 [expr $tsu_clk_period * 0.50]"
set_clock_transition $NOMINAL_SLEW [get_clocks {tsu_clk}]
set_input_delay -add_delay $tsu_clk_generic_indel  -max -clock [get_clocks {tsu_clk}]  [get_ports "gem_tsu_inc_ctrl gem_tsu_ms"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {tsu_clk}]  [get_ports "gem_tsu_inc_ctrl gem_tsu_ms"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {tsu_clk}]  [get_ports "gem_tsu_inc_ctrl gem_tsu_ms"]
set_output_delay -add_delay $tsu_clk_generic_outdel -max -clock [get_clocks {tsu_clk}]  [get_ports "tsu_timer_cnt tsu_timer_cmp_val tsu_timer_cnt_par"]
set_output_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {tsu_clk}]  [get_ports "tsu_timer_cnt tsu_timer_cmp_val tsu_timer_cnt_par"]

# Clock tx_clk, constrained to 125Mhz
set tx_clk_period [expr 8 * $clk_overconstraint]
set tx_clk_generic_indel [expr $tx_clk_period * 0.6]
set tx_clk_generic_outdel [expr $tx_clk_period * 0.6]
create_clock [get_ports tx_clk] -name tx_clk -period $tx_clk_period -waveform "0 [expr $tx_clk_period * 0.50]"
set_clock_transition $NOMINAL_SLEW [get_clocks {tx_clk}]
set_input_delay -add_delay $tx_clk_generic_indel  -max -clock [get_clocks {tx_clk}]  [get_ports "col crs tx_pause tx_pause_zero tx_pfc_sel tx_pfc_pause tx_pfc_pause_zero halfduplex_flow_control_en txdpram_dob emac_txdpram_dob"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {tx_clk}]  [get_ports "col crs tx_pause tx_pause_zero tx_pfc_sel tx_pfc_pause tx_pfc_pause_zero halfduplex_flow_control_en txdpram_dob emac_txdpram_dob"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {tx_clk}]  [get_ports "col crs tx_pause tx_pause_zero tx_pfc_sel tx_pfc_pause tx_pfc_pause_zero halfduplex_flow_control_en txdpram_dob emac_txdpram_dob"]
set_output_delay -add_delay $tx_clk_generic_outdel -max -clock [get_clocks {tx_clk}]  [get_ports "sof_tx sync_frame_tx delay_req_tx pdelay_resp_tx pdelay_req_tx txdpram_web txdpram_enb txdpram_addrb emac_txdpram_web emac_txdpram_enb emac_txdpram_addrb tx_er txd tx_en "]
set_output_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {tx_clk}]  [get_ports "sof_tx sync_frame_tx delay_req_tx pdelay_resp_tx pdelay_req_tx txdpram_web txdpram_enb txdpram_addrb emac_txdpram_web emac_txdpram_enb emac_txdpram_addrb tx_er txd tx_en "]

# Clock pclk, constrained to 100Mhz
set pclk_period [expr 10 * $clk_overconstraint]
set pclk_generic_indel [expr $pclk_period * 0.6]
set pclk_generic_outdel [expr $pclk_period * 0.6]
create_clock [get_ports pclk] -name pclk -period $pclk_period -waveform "0 [expr $pclk_period * 0.50]"
set_clock_transition $NOMINAL_SLEW [get_clocks {pclk}]
set_input_delay -add_delay $pclk_generic_indel  -max -clock [get_clocks {pclk}]  [get_ports "psel penable pwrite pwdata paddr mdio_in ext_interrupt_in  trigger_dma_tx_start"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {pclk}]  [get_ports "psel penable pwrite pwdata paddr mdio_in ext_interrupt_in  trigger_dma_tx_start"]
set_input_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {pclk}]  [get_ports "psel penable pwrite pwdata paddr mdio_in ext_interrupt_in  trigger_dma_tx_start"]
set_output_delay -add_delay $pclk_generic_outdel -max -clock [get_clocks {pclk}]  [get_ports "prdata perr dma_bus_width ethernet_int mdc mdio_out mdio_en loopback half_duplex speed_mode  emac_ethernet_int mmsl_int loopback_local ethernet_int_q1 ethernet_int_q2 asf_sram_corr_err emac_asf_sram_corr_err asf_sram_uncorr_err emac_asf_sram_uncorr_err asf_dap_err asf_csr_err asf_integrity_err emac_asf_dap_err emac_asf_csr_err emac_asf_integrity_err asf_trans_to_err asf_protocol_err asf_int_nonfatal asf_int_fatal emac_asf_trans_to_err emac_asf_protocol_err emac_asf_int_nonfatal emac_asf_int_fatal"]
set_output_delay -add_delay $NOMINAL_HOLD -min -clock [get_clocks {pclk}]  [get_ports "prdata perr dma_bus_width ethernet_int mdc mdio_out mdio_en loopback half_duplex speed_mode  emac_ethernet_int mmsl_int loopback_local ethernet_int_q1 ethernet_int_q2 asf_sram_corr_err emac_asf_sram_corr_err asf_sram_uncorr_err emac_asf_sram_uncorr_err asf_dap_err asf_csr_err asf_integrity_err emac_asf_dap_err emac_asf_csr_err emac_asf_integrity_err asf_trans_to_err asf_protocol_err asf_int_nonfatal asf_int_fatal emac_asf_trans_to_err emac_asf_protocol_err emac_asf_int_nonfatal emac_asf_int_fatal"]

# Clock n_tx_clk, constrained to 125Mhz
set n_tx_clk_period [expr 8 * $clk_overconstraint]
create_clock [get_ports n_tx_clk] -name n_tx_clk -period $n_tx_clk_period -waveform "[expr $n_tx_clk_period * 0.50] $n_tx_clk_period"
set_clock_transition $NOMINAL_SLEW [get_clocks {n_tx_clk}]

# Adding max delays or false paths between asynchronous clock domains
  set_max_delay [expr 0.45 * $rx_clk_period ] -from aclk -to rx_clk	 
  set_false_path -hold -from aclk -to rx_clk	
  set_max_delay [expr 0.45 * $tsu_clk_period ] -from aclk -to tsu_clk	 
  set_false_path -hold -from aclk -to tsu_clk	
  set_max_delay [expr 0.45 * $tx_clk_period ] -from aclk -to tx_clk	 
  set_false_path -hold -from aclk -to tx_clk	
  set_max_delay [expr 0.45 * $pclk_period ] -from aclk -to pclk	 
  set_false_path -hold -from aclk -to pclk	
  set_max_delay [expr 0.45 * $n_tx_clk_period ] -from aclk -to n_tx_clk	 
  set_false_path -hold -from aclk -to n_tx_clk	
  set_max_delay [expr 0.45 * $aclk_period ] -from rx_clk -to aclk	 
  set_false_path -hold -from rx_clk -to aclk	
  set_max_delay [expr 0.45 * $tsu_clk_period ] -from rx_clk -to tsu_clk	 
  set_false_path -hold -from rx_clk -to tsu_clk	
  set_max_delay [expr 0.45 * $tx_clk_period ] -from rx_clk -to tx_clk	 
  set_false_path -hold -from rx_clk -to tx_clk	
  set_max_delay [expr 0.45 * $pclk_period ] -from rx_clk -to pclk	 
  set_false_path -hold -from rx_clk -to pclk	
  set_max_delay [expr 0.45 * $n_tx_clk_period ] -from rx_clk -to n_tx_clk	 
  set_false_path -hold -from rx_clk -to n_tx_clk	
  set_max_delay [expr 0.45 * $aclk_period ] -from tsu_clk -to aclk	 
  set_false_path -hold -from tsu_clk -to aclk	
  set_max_delay [expr 0.45 * $rx_clk_period ] -from tsu_clk -to rx_clk	 
  set_false_path -hold -from tsu_clk -to rx_clk	
  set_max_delay [expr 0.45 * $tx_clk_period ] -from tsu_clk -to tx_clk	 
  set_false_path -hold -from tsu_clk -to tx_clk	
  set_max_delay [expr 0.45 * $pclk_period ] -from tsu_clk -to pclk	 
  set_false_path -hold -from tsu_clk -to pclk	
  set_max_delay [expr 0.45 * $n_tx_clk_period ] -from tsu_clk -to n_tx_clk	 
  set_false_path -hold -from tsu_clk -to n_tx_clk	
  set_max_delay [expr 0.45 * $aclk_period ] -from tx_clk -to aclk	 
  set_false_path -hold -from tx_clk -to aclk	
  set_max_delay [expr 0.45 * $rx_clk_period ] -from tx_clk -to rx_clk	 
  set_false_path -hold -from tx_clk -to rx_clk	
  set_max_delay [expr 0.45 * $tsu_clk_period ] -from tx_clk -to tsu_clk	 
  set_false_path -hold -from tx_clk -to tsu_clk	
  set_max_delay [expr 0.45 * $pclk_period ] -from tx_clk -to pclk	 
  set_false_path -hold -from tx_clk -to pclk	
  set_false_path  -from pclk -to aclk	
  set_false_path  -from pclk -to rx_clk	
  set_false_path  -from pclk -to tsu_clk	
  set_false_path  -from pclk -to tx_clk	
  set_false_path  -from pclk -to n_tx_clk	
  set_max_delay [expr 0.45 * $aclk_period ] -from n_tx_clk -to aclk	 
  set_false_path -hold -from n_tx_clk -to aclk	
  set_max_delay [expr 0.45 * $rx_clk_period ] -from n_tx_clk -to rx_clk	 
  set_false_path -hold -from n_tx_clk -to rx_clk	
  set_max_delay [expr 0.45 * $tsu_clk_period ] -from n_tx_clk -to tsu_clk	 
  set_false_path -hold -from n_tx_clk -to tsu_clk	
  set_max_delay [expr 0.45 * $pclk_period ] -from n_tx_clk -to pclk	 
  set_false_path -hold -from n_tx_clk -to pclk	

# Setting the clock groups
# Note that "-allow_paths" does not disable timing between them (we use max delays instead)
set_clock_groups -asynchronous -allow_paths -name gem_gxl_clock_groups  \
  -group  [get_clocks aclk]  \
  -group  [get_clocks rx_clk]  \
  -group  [get_clocks tsu_clk]  \
  -group [ list  [get_clocks tx_clk] [get_clocks n_tx_clk]  ] \
  -group  [get_clocks pclk] 

##########################################################
# Specific Constraints ...
# There is a combi path from txdpram_dob[31] to txdpram_enb. this is SRAM output to
# SRAM input. Need a specific constraint on this path to overwrite the input/output
# delay added
# Note, you need to add in the input delay and output delays to get the true path
# constraint
set_max_delay [ expr $tx_clk_generic_indel + $tx_clk_generic_outdel + 0.3 ] -from [get_ports {txdpram_dob} ]  -to [get_ports {txdpram_enb} ]
set_max_delay [ expr $tx_clk_generic_indel + $tx_clk_generic_outdel + 0.3 ] -from [get_ports {emac_txdpram_dob} ]  -to [get_ports {emac_txdpram_enb} ]

##########################################################
# Clock Uncertainty ...
# 100ps for SYNTH,100ps for PNR

if { [ regexp {genus} [ exec ps -o comm= -p [pid] ] ] } {
puts "This tool is Genus" 
  set_clock_uncertainty 0.100 -setup [ all_clocks ]
} else {
  set_clock_uncertainty 0.100 -setup [ all_clocks ]
}
#A hold uncertainty is applied for sign off - however for the purpose of proving our IP it's acceptable to apply a 0ps hold uncertainty.
#A large hold uncertainty in our RTL IP STA can often lead to false violations due solely to uncertainty and not design related. 
#So a 0ps uncertainty is suitable for our purposes.

#set_clock_uncertainty 0.055 -hold [ all_clocks ]
set_clock_uncertainty 0.000 -hold [ all_clocks ]

##########################################################
# Ideal nets ...
# False path reset
if {[ info vars rc_mode ] eq "rc_mode" } {
  ### only for initial synth do not apply for PNR
  ### dont touch the resets   ###
  puts "This tool is Genus (reading the ideal nets constraints for synthesis)" 
  set_false_path -from n_areset
  set_dont_touch_network [get_ports {n_areset}]
  set_false_path -from n_rxreset
  set_dont_touch_network [get_ports {n_rxreset}]
  set_false_path -from n_tsureset
  set_dont_touch_network [get_ports {n_tsureset}]
  set_false_path -from n_txreset
  set_dont_touch_network [get_ports {n_txreset}]
  set_false_path -from n_preset
  set_dont_touch_network [get_ports {n_preset}]
  set_false_path -from n_ntxreset
  set_dont_touch_network [get_ports {n_ntxreset}]
} else {
  set_input_delay  [expr $aclk_period / 2] [ get_ports {n_areset} ] -clock [get_clocks { aclk}]
  set_input_delay  [expr $rx_clk_period / 2] [ get_ports {n_rxreset} ] -clock [get_clocks { rx_clk}]
  set_input_delay  [expr $tsu_clk_period / 2] [ get_ports {n_tsureset} ] -clock [get_clocks { tsu_clk}]
  set_input_delay  [expr $tx_clk_period / 2] [ get_ports {n_txreset} ] -clock [get_clocks { tx_clk}]
  set_input_delay  [expr $pclk_period / 2] [ get_ports {n_preset} ] -clock [get_clocks { pclk}]
  set_input_delay  [expr $n_tx_clk_period / 2] [ get_ports {n_ntxreset} ] -clock [get_clocks { n_tx_clk}]
}
# For Innovus, false path the scan input to SI pins both for setup and for hold
if { [ regexp {innovus} [ exec ps -o comm= -p [pid] ] ] } {
  puts "This tool is Innovus"
  set_false_path -from       [get_ports {*scanin*}]  
  set_false_path -from       [get_ports {scanen*}]   
  set_false_path -from       [get_ports {scanen_cg*}]
  set_false_path -to         [get_ports {*scanout*}] 
  set_false_path -hold -from [get_ports {*scanin*}]  
  set_false_path -hold -from [get_ports {scanen*}]   
  set_false_path -hold -from [get_ports {scanen_cg*}]
  set_false_path -hold -to   [get_ports {*scanout*}] 
  # Also we need to set the set_case_analysis to zero for the scan chain enable
  # This is for the tool to understand to not consider any of the internal scan input ports
  set_case_analysis 0        [get_ports {scanen*}]   
  set_case_analysis 0        [get_ports {scanen_cg*}]
} 

##########################################################
# Input drivers/output load and slew ...
# signals that are driving inside the ASIC
set EXT_DRIVERS    { \
			mdio_out mdio_en mdc tx_er txd tx_en\
                   }
set INT_DRIVERS    { \
			emac_asf_int_fatal emac_asf_int_nonfatal emac_asf_protocol_err emac_asf_trans_to_err asf_int_fatal asf_int_nonfatal asf_protocol_err asf_trans_to_err emac_asf_integrity_err emac_asf_csr_err emac_asf_dap_err asf_integrity_err asf_csr_err asf_dap_err emac_asf_sram_uncorr_err asf_sram_uncorr_err emac_asf_sram_corr_err asf_sram_corr_err ethernet_int_q2 ethernet_int_q1 loopback_local mmsl_int emac_ethernet_int speed_mode half_duplex loopback ethernet_int dma_bus_width perr prdata tx_en emac_txdpram_addrb emac_txdpram_enb emac_txdpram_web txdpram_addrb txdpram_enb txdpram_web pdelay_req_tx pdelay_resp_tx delay_req_tx sync_frame_tx sof_tx tsu_timer_cnt_par tsu_timer_cmp_val tsu_timer_cnt emac_rxdpram_addra emac_rxdpram_ena emac_rxdpram_wea emac_rxdpram_dia rxdpram_addra rxdpram_ena rxdpram_wea rxdpram_dia pfc_negotiate rx_pfc_paused pdelay_resp_rx pdelay_req_rx delay_req_rx sync_frame_rx sof_rx ext_ipv6 ext_dp_stb ext_dest_port ext_sp_stb ext_source_port wol ext_ip_da_stb ext_ip_da ext_ip_sa_stb ext_vlan_tag2_stb ext_vlan_tag2 ext_ip_sa ext_vlan_tag1_stb ext_vlan_tag1 ext_type_stb ext_type ext_sa_stb ext_sa ext_da_stb ext_da arvalid arqos arprot arcache arlock arburst arsize arlen araddr arid rready bready wid wvalid wlast wstrb wdata awvalid awqos awprot awcache awlock awburst awsize awlen awaddr awid rx_databuf_wr_q2 rx_databuf_wr_q1 rx_databuf_wr_q0 emac_rxdpram_addrb emac_rxdpram_enb emac_rxdpram_web emac_txdpram_dia emac_txdpram_addra emac_txdpram_ena emac_txdpram_wea rxdpram_addrb rxdpram_enb rxdpram_web txdpram_dia txdpram_addra txdpram_ena txdpram_wea \
                   }
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {n_areset}]
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {n_rxreset}]
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {n_tsureset}]
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {n_txreset}]
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {n_preset}]
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {n_ntxreset}]
set_driving_cell -lib_cell $DRIVE_CELL [get_ports {psel penable pwrite pwdata paddr mdio_in ext_interrupt_in  trigger_dma_tx_start col crs tx_pause tx_pause_zero tx_pfc_sel tx_pfc_pause tx_pfc_pause_zero halfduplex_flow_control_en txdpram_dob emac_txdpram_dob gem_tsu_inc_ctrl gem_tsu_ms ext_match1 ext_match2 ext_match3 ext_match4 rx_er rx_dv rxd  rxdpram_dob emac_rxdpram_dob awready wready bid bresp bvalid arready rid rdata rresp rlast rvalid  }]
set_load [expr "5 * $INVCAP"] [get_ports $INT_DRIVERS] 
set_load [expr "20 * $INVCAP"] [get_ports $EXT_DRIVERS]  
set_fanout_load 0.0 [get_ports $INT_DRIVERS] 
set_fanout_load 0.0 [get_ports $EXT_DRIVERS] 

# Define design environments: 
set_max_fanout $MAX_FANOUT [current_design]
set_max_transition $MAX_TRANS [current_design]
set_max_transition $MAX_TRANS [all_outputs]
set_max_capacitance $MAX_CAP [current_design]
set_max_capacitance $MAX_CAP [all_inputs]
set_max_capacitance $MAX_CAP [all_outputs]
set_drive 0 [ get_ports {n_areset}]
set_drive 0 [ get_ports {aclk}]
set_drive 0 [ get_ports {n_rxreset}]
set_drive 0 [ get_ports {rx_clk}]
set_drive 0 [ get_ports {n_tsureset}]
set_drive 0 [ get_ports {tsu_clk}]
set_drive 0 [ get_ports {n_txreset}]
set_drive 0 [ get_ports {tx_clk}]
set_drive 0 [ get_ports {n_preset}]
set_drive 0 [ get_ports {pclk}]
set_drive 0 [ get_ports {n_ntxreset}]
set_drive 0 [ get_ports {n_tx_clk}]
