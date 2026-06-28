//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains all the files that comprises the cdn_axi_vip UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_top.sv
 *
 * This file contains the `includes for the cdn_axi_vip UVC which wraps the
 * Cadence AXI VIP.
 * This is done separately from the package as this gives customers the option
 * to avoid using packages.
 */

`ifndef CDN_AXI_VIP_TOP_SV
`define CDN_AXI_VIP_TOP_SV

`include "cdn_axi_vip_config.sv"
`include "cdn_axi_vip_instance.sv"
`include "cdn_axi_vip_mem_instance.sv"
`include "cdn_axi_vip_coverage.sv"
`include "cdn_axi_vip_driver.sv"
`include "cdn_axi_vip_monitor.sv"
`include "cdn_axi_vip_sequencer.sv"
`include "cdn_axi_vip_agent.sv"
`include "cdn_axi_vip_env.sv"

`endif // CDN_AXI_VIP_TOP_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
