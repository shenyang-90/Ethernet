//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// 
// cdn_demo_params for the RAM integration dummy top level. Note. This file
// currently only contains AXI and APB params.
//------------------------------------------------------------------------------

//--------------------------------------------------------------------
//                     P A R A M E T E R S
//--------------------------------------------------------------------

// Fixed AXI parameters:
localparam AXI_ADDR_WD    = 32'd32;  // Width of AXI address
localparam AXI_DATA_WD    = 32'd32;  // Width of AXI data
localparam AXI_SLV_ID_WD  = 32'd2;   // Width of internal AXI ID tag (Arbiter SLAVE IF)
localparam AXI_ID_WD      = 32'd5;  // Width of external AXI ID tag (Arbiter MASTER IF)
localparam AXI_LEN_WD     = 32'd4;   // Width of AXI burst length. 8 (AXI4), 4 (AXI3)
localparam AXI_LOCK_WD    = 32'd1;   // Width of AXI lock type.    1 (AXI4), 2 (AXI3)
localparam AXI_STRB_WD    = 32'd4;   // Width of AXI strobe
localparam AXI_SIZE_WD    = 32'd3;   // Width of burst size
localparam AXI_BURST_WD   = 32'd2;   // Width of burst type
localparam AXI_CACHE_WD   = 32'd4;   // Width of memory type
localparam AXI_PROT_WD    = 32'd3;   // Width of protection type
localparam AXI_QOS_WD     = 32'd4;   // Width of Quality of Service, QoS
localparam AXI_REGION_WD  = 32'd4;   // Width of Region field
localparam AXI_RESP_WD    = 32'd2;   // Width of response
localparam AXI_USER_WD    = 32'd32;   // Width of AXI USER (MASTER IF)

// Fixed APB parameters:
localparam APB_PADDR_WD = 13;
localparam APB_PPROT_WD = 3;


