tclmode


// Applied to structrual, set/reset and convergence checks
//add_rule_filter filter_apb_reads  -message  \
//                "* -> u_pcieg3_phy_rev/u_apb_top_wrapper/u_cdb_local_bridge_phy/cdb_prdata_reg*"  \
//		-rule  cdc_def_rs/*/cdc* \
//		-description "APB reads can be read twice if values are strange"



vpxmode
