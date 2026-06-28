//------------------------------------------------------------------------------
// Copyright (c) 2012-2017 Cadence Design Systems, Inc.
//
// The information herein (Cadence IP) contains confidential and proprietary
// information of Cadence Design Systems, Inc. Cadence IP may not be modified,
// copied, reproduced, distributed, or disclosed to third parties in any manner,
// medium, or form, in whole or in part, without the prior written consent of
// Cadence Design Systems Inc. Cadence IP is for use by Cadence Design Systems,
// Inc. customers only. Cadence Design Systems, Inc. reserves the right to make
// changes to Cadence IP at any time and without notice.
//------------------------------------------------------------------------------
//
//   Filename:           tb_ext_tsu_timer.v
//   Module Name:        tb_ext_tsu_timer
//
//   Release Revision:   r1p12
//   Release SVN Tag:    gem_gxl_det0104_r1p12
//
//   IP Name:            GEM Gigabit Ethernet MAC
//   IP Part Number:     IP7014A
//
//   Product Type:       Off-the-shelf
//   IP Type:            Soft
//   IP Family:          Ethernet Controller
//   Technology:         N/A
//   Protocol:           Ethernet
//   Architecture:       N/A
//   Licensable IP:      SIP-Ethernet-MAC+DMA+1588+TSN+PCS+A-10M/100M/1G-IP7014A
//
//------------------------------------------------------------------------------
// Description : Test bench module to generate a somple incrementing external TSU
//              count to the external TSU port
//
//------------------------------------------------------------------------------


module tb_ext_tsu_timer(
                  // input clock and reset
                    tsu_clk,
                    n_tsureset,

                  // timer output
                    ext_tsu_timer_par,
                    ext_tsu_timer

                   );

    //Outputs
    output [11:0] ext_tsu_timer_par;
    output [93:0] ext_tsu_timer; //timestamp [93:46] = secs
                                 //          [45:16] = nsec
                                 //          [15:0]  = sub-nsec
    //Inputs
    input        tsu_clk;     //clock supplied by user for tsu
    input        n_tsureset; //Async active low reset

    reg   [93:0] ext_tsu_timer; //output parallelised data

    //generate an incrementing external tsu timer value
    always @(posedge tsu_clk or negedge n_tsureset)
      if (n_tsureset == 1'b0)
        ext_tsu_timer <= 94'd0;
      else
        ext_tsu_timer <= ext_tsu_timer + {48'd0, 30'd10, 16'd22};

    // Very crude parity generation
    assign ext_tsu_timer_par  = {^ext_tsu_timer[93:88],
                                  ^ext_tsu_timer[87:80],
                                  ^ext_tsu_timer[79:72],
                                  ^ext_tsu_timer[71:64],
                                  ^ext_tsu_timer[63:56],
                                  ^ext_tsu_timer[55:48],
                                  ^ext_tsu_timer[47:40],
                                  ^ext_tsu_timer[39:32],
                                  ^ext_tsu_timer[31:24],
                                  ^ext_tsu_timer[23:16],
                                  ^ext_tsu_timer[15:8],
                                  ^ext_tsu_timer[7:0]};

endmodule
