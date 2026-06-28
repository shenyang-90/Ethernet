//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the files that comprises the cdn_apb_vip UVC which wraps
// the Cadence APB VIP.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_top.sv
 * 
 * This file contains the `includes for the cdn_apb_vip UVC which wraps the
 * Cadence APB VIP.
 * This is done separately from the package as this gives customers the option
 * to avoid using packages.
 */

`ifndef _CDN_APB_UVM_USER_TOP
`define _CDN_APB_UVM_USER_TOP

`include "cdnApbUvmDefines.sv"

`include "cdn_apb_vip_master_agent.sv"
`include "cdn_apb_vip_slave_agent.sv"
`include "cdn_apb_vip_seq_lib.sv"
`include "cdn_apb_vip_driver.sv"
`include "cdn_apb_vip_monitor.sv"
`include "cdn_apb_vip_config.sv"
`include "cdn_apb_vip_env.sv"
`include "cdn_apb_vip_coverage.sv"
`include "cdn_apb_vip_instance.sv"
`include "cdn_apb_vip_sequencer.sv"

`endif // _CDN_APB_UVM_USER_TOP

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
