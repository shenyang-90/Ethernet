//----------------------------------------------------------------------------
// Project    : cdn_enet_vip UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains some type definition needed in the cdn_enet_vip UVC.
//----------------------------------------------------------------------------

/*
 * File: cdn_enet_vip_defines.svh
 * 
 * This file contains some type definition needed in the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_VIP_DEFINES_SV
`define CDN_ENET_VIP_DEFINES_SV

/*
 * Enum: enet_active_passive_enum
 * 
 * Convenience value to define whether the cdn_enet_vip env is passive (only
 * passive agent) or active (both passive and active agents).
 */
typedef enum bit { ENET_PASSIVE=0, ENET_ACTIVE=1 } enet_passive_active_enum;

/*
 * Enum: enet_passive_phy_mac_enum
 * 
 * Convenience value to define whether the passive agent in the cdn_enet_vip env
 * is PHY or MAC.
 */
typedef enum bit { ENET_PASSIVE_PHY=0, ENET_PASSIVE_MAC=1 } enet_passive_phy_mac_enum;

/*
 * Enum: enet_active_phy_mac_enum
 * 
 * Convenience value to define whether the active agent in the cdn_enet_vip env
 * is PHY or MAC.
 */
typedef enum bit { ENET_ACTIVE_PHY=0, ENET_ACTIVE_MAC=1 } enet_active_phy_mac_enum;

/*
 * Enum: enet_active_phy_mac_enum
 * 
 * Convenience value to define the interface type for the cdn_enet_vip agent.
 */
typedef enum bit { GMII=0, RGMII=1 } enet_interface_type_enum;

`endif

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
