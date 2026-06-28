/**************************************************************************
 File name    : cdn_enet_vip_top
 Title        : UVC top level
 Project      : Ethernet
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : Contains all the files that comprises the cdn_enet_vip UVC.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_top.sv
 *
 * This file contains the `includes for the cdn_enet_vip UVC which wraps the
 * Cadence Ethernet VIP.
 * This is done seperately from the package as this gives customers the option
 * to avoid using packages.
 */

`ifndef CDN_ENET_UVM_USER_TOP
  `define CDN_ENET_UVM_USER_TOP

  `include "cdn_enet_vip_config.sv"
  `include "cdn_enet_vip_cover.sv"
  `include "cdn_enet_vip_sequencer.sv"
  `include "cdn_enet_vip_monitor.sv"
  `include "cdn_enet_vip_agent.sv"
  `include "cdn_enet_vip_instance.sv"
  `include "cdn_enet_vip_driver.sv"
  `include "cdn_enet_vip_env.sv"

`endif // CDN_ENET_UVM_USER_TOP

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
