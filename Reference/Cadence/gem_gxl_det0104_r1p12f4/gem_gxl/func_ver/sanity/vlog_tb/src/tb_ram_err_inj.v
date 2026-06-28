//------------------------------------------------------------------------------
// Copyright (c) 2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_ram_err_inj.v
//   Module Name:        tb_ram_err_inj
//
//   Release Revision:   r1p12
//   Release SVN Tag:    gem_gxl_det0105_r1p12
//
//   IP Name:            GEM Gigabit Ethernet MAC
//   IP Part Number:     IP7017A
//
//   Product Type:       Off-the-shelf
//   IP Type:            Soft
//   IP Family:          Ethernet Controller
//   Technology:         N/A
//   Protocol:           Ethernet
//   Architecture:       N/A
//   Licensable IP:      SIP-Ethernet-MAC+DMA+1588+TSN+PCS+A-2_5G-IP7017A
//
//------------------------------------------------------------------------------
//   Description    : Basic module to inject error into RAM write data.
//                    If enabled, will randomly inject 1-bit error when values
//                    change.
//                    If enabled and double_err_inj is on, it will inject a
//                    2-bit error.
//                    The number of errors to be injected in an input.
//
//------------------------------------------------------------------------------


`ifndef TB_DEFS
   `include "tb_defs.v"
   `include "edma_defs.v"
`endif

module tb_ram_err_inj #(
  parameter ram_width = 64
) (
  input                 ram_clk,
  input                 ram_rst_n,
  input                 err_inj_en,
  input                 double_err_inj,
  input                 dp_enable,
  input       [19:0]    num_errors,
  input                 ram_en,
  input                 ram_read_en,
  input       [ram_width-1:0]
                        ram_data,
  input       [23:0]    sram_read_add,
  output  reg [23:0]    sram_addr_err,
  output      [ram_width-1:0]
                        ram_data_err,
  output                all_errs_injected
);

  reg   [19:0]          err_count_int;
  wire                  err_inj_en_int;
  reg   [ram_width-1:0] ram_data_flip;
  integer               err_pos;
  reg                   inj_err_now;
  integer               loop_var;
  reg                   double_inj_wait_int;
  reg                   ram_read_en_d1;
  reg   [23:0]          sram_read_add_d1;
  integer               num_consec_errs;

  initial
    num_consec_errs = 0;

  always@(posedge ram_clk or negedge ram_rst_n)
  begin
    if (~ram_rst_n)
    begin
      ram_read_en_d1    <= 1'b0;
      sram_read_add_d1  <= 24'd0;
    end
    else
    begin
      ram_read_en_d1    <= ram_read_en & ram_en;
      sram_read_add_d1  <= sram_read_add;
    end
  end


  assign err_inj_en_int = err_inj_en & (err_count_int < num_errors) & !double_inj_wait_int;

  // This will be used to allow new injections ...
  always@(posedge ram_clk or negedge ram_rst_n)
  begin
    if (~ram_rst_n)
      double_inj_wait_int <= 1'b0;
    else
      if (!dp_enable)
        double_inj_wait_int <= 1'b0;
      else if (inj_err_now & err_inj_en_int & ram_read_en_d1 & double_err_inj)
        double_inj_wait_int <= 1'b1;
  end

  always@(posedge ram_clk or negedge ram_rst_n)
  begin
    if (~ram_rst_n)
    begin
      err_count_int <= 20'd0;
      sram_addr_err <= 24'd0;
    end
    else
      if (inj_err_now & err_inj_en_int & ram_read_en_d1 & dp_enable)
      begin
        err_count_int <= err_count_int + 20'd1;
        sram_addr_err <= sram_read_add_d1;
      end
  end

  assign all_errs_injected = err_count_int >= num_errors | !dp_enable;

  always@(dp_enable or ram_data)
  begin
    if (err_inj_en_int & ram_read_en_d1 & dp_enable)
    begin
      if (double_err_inj)
        inj_err_now = ($urandom_range(100,0) >= 90);
      else
      begin
        if (num_consec_errs > 0)
        begin
          inj_err_now = 1'b1;
          num_consec_errs = num_consec_errs -1;
        end
        else
        begin
          inj_err_now     = ($urandom_range(100,0) >= 10);
          if (inj_err_now)
            num_consec_errs = $urandom_range(9,1);
        end
      end
    end
    else
      inj_err_now = 1'b0;

    if (inj_err_now)
    begin
      if (double_err_inj)
`ifdef edma_asf_ecc_sram
        err_pos = $urandom_range(ram_width-2,0);
`else
        err_pos = $urandom_range(ram_width-3,0);
`endif
      else
        err_pos = $urandom_range(ram_width-1,0);
      for (loop_var=0;loop_var<ram_width;loop_var=loop_var+1)
      begin
        if ((loop_var == err_pos) ||
            (double_err_inj & (loop_var == err_pos+1))
`ifndef edma_asf_ecc_sram
            || (double_err_inj & (loop_var == err_pos+2))
`endif
            )
          ram_data_flip[loop_var]  = 1'b1;
        else
          ram_data_flip[loop_var]  = 1'b0;
      end
    end
    else
      ram_data_flip  = {ram_width{1'b0}};
  end

//  assign ram_data_err  = err_inj_en_int ? ram_data_flip ^ ram_data
//                                        : ram_data;
  assign ram_data_err  = ram_data_flip ^ ram_data;


endmodule
