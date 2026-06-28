//------------------------------------------------------------------------------
//                                     
//            CADENCE                    Copyright (c) 2001-2013
//                                       Cadence Design Systems, Inc.
//                                       All rights reserved.
//
//  This work may not be copied, modified, re-published, uploaded, executed, or
//  distributed in any way, in any medium, whether in whole or in part, without
//  prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
//
//    Primary Unit Name :      filters.do
//
//          Description :      Example script to define filters. 
//
//      Original Author :      Mark Lewis
//
//------------------------------------------------------------------------------
tclmode


// Applied to structrual, set/reset and convergence checks

//add_rule_filter filter_apb_reads  -message  \
//                "* -> u_pcieg3_phy_rev/u_apb_top_wrapper/u_cdb_local_bridge_phy/cdb_prdata_reg*"  \
//		-rule  cdc_def_rs/*/cdc* \
//		-description "APB reads can be read twice if values are strange"


///-----------------------------------------------------------------------------
// Filter paths - Put a list of from and to instance paths into an array
//                to allow application to filter_paths attribute as it is 
//                not aditive in nature so need to specify a single list
///-----------------------------------------------------------------------------

//tclmode
//
//  set filtered_from_paths [find -instance -hierarchical "*pbmx* *debug_probe_mux* \
//                               glb_ecc_chk_dis* *gen_async_que* lue/mc_cpu_req_in_ff/rgfile_reg* \
//			       *i_di_port_ff/rgfile_reg* *i_sl_port_ff/rgfile_reg* \
//			       *i_hr_port_ff/rgfile_reg* *i_pd_smc_resp_sync/rgfile_reg* \
//			       
//			       *i_pac_buffer/mem_reg*"]                          
//  set filtered_to_paths   [find -instance -hierarchical "*pbmx* *debug_probe_mux* \
//                               *sync_1stg_reg*  *gen_async_que* *rmon_cntr_eng/agg_in_ff/* \
//			       *rmon_cntr_eng/mc_in_ff/* *rmon_cntr_eng/rsp_ff/*"]
//
//  set _path_spec_tbl_(1) [list from $filtered_from_paths]
//  set _path_spec_tbl_(2) [list to   $filtered_to_paths]
//
//  set _filter_paths_ ""
//    foreach {_idx_ _path_spec_} [array get _path_spec_tbl_] {
//      lappend _filter_paths_ ${_path_spec_}
//    }
//
//  foreach filters1 [find -ruleinst cdc_def_rs/cdc_checks/cdc_*] {
//    set_attribute $filters1 \
//     filter_paths ${_filter_paths_}
//  }
//
//vpxmode


//tclmode

//  set filtered_from_paths [find -pin -hierarchical "u_pcieg3_phy_rev/u_pcieg3_pma/*"]
  			       
//  set filtered_to_paths   [find -pin -hierarchical "u_pcieg3_phy_rev/u_pcieg3_pma/*"]

//  set _path_spec_tbl_(1) [list from $filtered_from_paths]
//  set _path_spec_tbl_(2) [list to   $filtered_to_paths]

//  set _filter_paths_ ""
//    foreach {_idx_ _path_spec_} [array get _path_spec_tbl_] {
//      lappend _filter_paths_ ${_path_spec_}
//    }

//  foreach filters1 [find -ruleinst cdc_def_rs/cdc_checks/*] {
//    set_attribute $filters1 \
//     filter_paths ${_filter_paths_}
//  }


vpxmode
