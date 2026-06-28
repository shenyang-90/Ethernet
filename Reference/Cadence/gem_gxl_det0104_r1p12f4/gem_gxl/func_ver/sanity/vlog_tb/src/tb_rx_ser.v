//------------------------------------------------------------------------------
// Copyright (c) 2004-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_rx_ser.v
//   Module Name:        tb_rx_ser
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
//   Description    :
//
//   This block takes 10 bit code groups from the GEM test bench and serialises
//   them to provide a serial stream of receive data to the SerDes model.
//
//   The serial data is clocked in at 1.25GHz. The clock is divided by a factor
//   of ten to provide a new ten bit code group every 8ns.
//
//------------------------------------------------------------------------------


module tb_rx_ser(
                  //Interface Outputs
                    rx_serial_n,
                    rx_serial_p,

                  //Interface Inputs
                    clk_1g25,
                    rst_n,
                    rx_parallel
                   );

    //Outputs
    output      rx_serial_n; //serial output to pex
    output      rx_serial_p; //serial output to pex

    //Inputs
    input       clk_1g25;    //1.25GHz clock (serial data rate)
    input       rst_n;       //Async active low reset
    input [9:0] rx_parallel; //parallel input from serdes model

    reg   [9:0] rx_reg;      //shift register, bit 0 used as serial output
    reg   [3:0] count;       //counter to keep track of bits sent
    reg   [9:0] rx_reg_pipe; //add pipe line for test bench timing


    assign rx_serial_p =  rx_reg[0];
    assign rx_serial_n = ~rx_reg[0];

    always @(posedge clk_1g25 or negedge rst_n)
    begin
      if (~rst_n)
        begin
          count  <= 4'b0000;
          rx_reg <= 10'b0000000000;
          rx_reg_pipe <= 10'b0000000000;
        end
      else
        begin
          if (count == 4'b1001)
            begin
              count  <= 4'b0000;
              rx_reg_pipe <= rx_parallel;
              rx_reg <= rx_reg_pipe;
            end
          else
            begin
              count  <= count + 1;
              rx_reg <= {1'b0,rx_reg[9:1]};
            end
        end
    end


endmodule
