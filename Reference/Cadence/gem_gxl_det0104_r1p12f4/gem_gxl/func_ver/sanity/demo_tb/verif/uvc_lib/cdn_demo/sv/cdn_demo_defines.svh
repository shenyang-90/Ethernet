//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2013 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file contains all of the defines required by the 
// cdn_demo UVC.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_DEFINES_SVH
`define CDN_DEMO_DEFINES_SVH


// Define the data width of the push pop evc items for each env.
`define CDN_DEMO_PP_DW 64

// Reset sense define for the module.
`define CDN_DEMO_ACTIVE_RESET_VALUE 0

// Reset value of misc signals.
`define CDN_DEMO_DUT_ENABLE_RESET_VALUE 0

`define CDN_DEMO_TB_PASS_STRING "\n\
--------------------------------------------------------------\n\
-  _____  _____  _____  _____    _____  _____  _____  _____  -\n\
- |_   _||  ___||  ___||_   _|  |  _  ||  _  ||  ___||  ___| -\n\
-   | |  | |___ | |___   | |    | |_| || |_| || |___ | |___  -\n\
-   | |  |  ___||___  |  | |    |  ___||  _  ||___  ||___  | -\n\
-   | |  | |___  ___| |  | |    | |    | | | | ___| | ___| | -\n\
-   |_|  |_____||_____|  |_|    |_|    |_| |_||_____||_____| -\n\
--------------------------------------------------------------\n"
`define CDN_DEMO_TB_FAIL_STRING "\n\
-----------------------------------------------------------\n\
-  _____  _____  _____  _____    _____  _____  _   _      -\n\
- |_   _||  ___||  ___||_   _|  |  ___||  _  || | | |     -\n\
-   | |  | |___ | |___   | |    | |___ | |_| || | | |     -\n\
-   | |  |  ___||___  |  | |    |  ___||  _  || | | |     -\n\
-   | |  | |___  ___| |  | |    | |    | | | || | | |___  -\n\
-   |_|  |_____||_____|  |_|    |_|    |_| |_||_| |_____| -\n\
-----------------------------------------------------------\n"


// Define the APB address width.
`define CDN_DEMO_APB_ADDRESS_WIDTH 32

// Define the number of APB slaves.
`define CDN_DEMO_APB_NUM_OF_SLAVES 2

`endif 

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
