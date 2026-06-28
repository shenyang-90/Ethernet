//----------------------------------------------------------------------------
// Project    : cdn_reset UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// This file contains all of the defines required by the cdn_reset OVC.
//----------------------------------------------------------------------------

// This define is required for the insertion of multiple clock cycle delays 
// inbetween transfers.
`define CLOCK_PERIOD 20ns

// The following defines control the reset polarity i.e. active low or 
// active high.
`define ASSERTED_RESET_VALUE   0
`define DEASSERTED_RESET_VALUE 1

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
