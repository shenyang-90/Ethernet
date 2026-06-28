# This file contains SDC Lint filters for the Conformal CCD tool.
# Generated for design configuration "pbuf_3qs_axi" on Mon Nov 20 09:34:29 GMT 2017


// Clock groups have multiple root clock sources just because this is an IP block. in reality, these clocks would be expected to come from the 
// same PLL source
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF5 -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF5

// An output port is in a timing path within a clock group for which it does not have output delay defined
// when the PCS is defined, or RMII, or loopback there is a mux on the TX outputs. The mux select is driven from a static APB timed register.
// Since that is pclk timed, paths exist from pclk to the TX outputs.  These are false, so we can disregard them
add_rule_filter ignore_pclk_to_tx_opsa -message "*output port \'tx_en\'*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_tx_opsb -message "*output port \'tx_er\'*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_tx_opsc -message "*output port \'*txd*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
// AXI interface has static sources from PCLK in the path, so there are some paths from pclk that can be ignored
add_rule_filter ignore_pclk_to_host_ops5 -message "*output port \'ar*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_host_ops6 -message "*output port \'aw*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
add_rule_filter ignore_pclk_to_host_ops7 -message "*output port \'w*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13
// When 64 bit addressing is enabled with DMA and AHB, there is a pclk timed mux causing haddr to be on the clock tree of pclk
add_rule_filter ignore_pclk_to_64bhaddr -message "*output port \'haddr*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL13

// The signal tx_clk_sig ends up in the fan-in of the main MII interface - When RGMII and RMII are included together,
// we see non-real paths between this signal and other clocks that are used in RMII mode . Since this signal is an RGMII timed signal
// we can just ignore that one
add_rule_filter ignore_tx_clk_sig_to_rmii_clks -message "*input port \'*tx_clk_sig*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL13

// Input delay constrained vs. wrong clock
// trigger_dma_tx_start is a truly asynchonous input that we tie to pclk so that some input delay is added. But that gives this dont care warning. Waived
add_rule_filter ignore_trigtx_start_async -message "*trigger_dma_tx_start*pclk*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL6

// Detected input delay vs. clock that is not virtual
// Intentional - waived
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7  -message "*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_IDL7

// Detected output delay vs. clock that is not virtual
// Intentional - waived
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL7  -message "*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL7

// Clocks and reset have no drive cell...should not be an issue since we put in our own clock and reset nets
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR8 -message "*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR8

// Hold time set to 0.1; this tool wants 0 or -
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL14 -message "*" -rule sdc_def_checks/sdc_iodelay_checks/CCD_IO_ODL14

// False path exception does not match any timing path
// We add some false paths across clock domains for readability(hold) - not actually any real paths in the design
// Not a real problem. Not fixing.
add_rule_filter sdc_def_checks/sdc_exception_checks/CCD_EXC_FLP1  -message "*" -rule  sdc_def_checks/sdc_exception_checks/CCD_EXC_FLP1

// Max delay exception does not match any timing path
// We add some max delays across clock domains for readability - not actually any real paths in the design
// Not a real problem. Not fixing.
add_rule_filter sdc_def_checks/sdc_exception_checks/CCD_EXC_SMD1  -message "*" -rule  sdc_def_checks/sdc_exception_checks/CCD_EXC_SMD1

// Outputs not registered
// Known about . waiving
add_rule_filter sdc_def_checks/sdc_design_checks/CCD_DGN_PRT4  -message "*" -rule  sdc_def_checks/sdc_design_checks/CCD_DGN_PRT4

// set_load and set_driving_cell/set_drive not used together
// Waived. set_load done seperately
add_rule_filter sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR10  -message "*" -rule  sdc_def_checks/sdc_iodelay_checks/CCD_IO_ITR10
add_rule_filter sdc_def_checks/sdc_iodelay_checks/SDC_LINT_CMD6  -message "*" -rule SDC_LINT_CMD6

// Clock not propagated (missing set_propagated_clock on a created clock)
// clocks are ideal for synthesis. Could maybe add this after ccopt if it was real silicon. clocks are propagated automatically by tool if it detects a clock tree
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF10  -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_DEF10

// Undefined clock latency for real clocks
// latency is 0 as its ideal. could set to 0.1 to get around this but not necessary
add_rule_filter sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT1  -message "*" -rule  sdc_def_checks/sdc_clock_checks/CCD_CLK_LAT1
