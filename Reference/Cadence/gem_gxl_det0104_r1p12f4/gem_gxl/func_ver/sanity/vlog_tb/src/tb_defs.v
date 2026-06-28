//------------------------------------------------------------------------------
// Copyright (c) 2001-2017 Cadence Design Systems, Inc.
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
//   Filename:           tb_defs.v
//   Module Name:        tb_defs
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
//   Description :      Declares timescale, and other testbench paramters
//
//
//------------------------------------------------------------------------------


`define TB_DEFS

  `timescale 100ps / 1ps

   `include "gem_gxl_defs.v"
   `include "edma_defs.v"
   `ifdef xgm
     `define top tb_xgm
   `else
     `define top tb_gem_gxl
   `endif

 
   `ifdef CDN_UVM
   // --
   // Redefine hierarchy path!
   // --
     `define hier_gem_top cdn_tb.dut_i.i_gem.i_gem_ss
     `define fifo_path cdn_tb.dut_i.i_tb_fifo_loop
   `else
     `define hier_gem_top `top.i_gem_gxl.i_gem_ss
     `define fifo_path `top.i_tb_top.i_tb_fifo_loop
   `endif// CDN_UVM


   `ifdef CDN_UVM
     `define hier_gem_top cdn_tb.dut_i.i_gem.i_gem_ss
   `endif
   `define hierarchy `hier_gem_top.i_gem_top
   `define hierarchy_asf `hierarchy.i_gem_reg_top.i_gem_registers.i_reg_asf_fault_log_rpt
   `ifdef gem_has_802p3_br
     `ifdef rtl
       `define hier_emac `hier_gem_top.gen_has_802p3_br.i_gem_top
     `else
       `define hier_emac `hier_gem_top.gen_has_802p3_br_i_gem_top
     `endif
   `else
    `define hier_emac `hier_gem_top.i_gem_top   // This wont actually do anything but avoids compilation issues at GL ijn tb_dma_axi
   `endif

`ifdef gem_axi
  `ifdef rtl
    `define hier_pbuf_axi_top `hierarchy.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top
    `define hier_emac_pbuf_axi_top `hier_emac.gen_dma.gen_pbuf_axi_dma.i_edma_pbuf_axi_top
  `else
    `define hier_pbuf_axi_top `hierarchy.gen_dma_gen_pbuf_axi_dma_i_edma_pbuf_axi_top
    `define hier_emac_pbuf_axi_top `hier_emac.gen_dma_gen_pbuf_axi_dma_i_edma_pbuf_axi_top
  `endif
  `define hier_pbuf_tx    `hier_pbuf_axi_top.i_edma_pbuf_axi_tx
  `define hier_pbuf_tx_wr `hier_pbuf_tx.i_edma_pbuf_axi_tx_wr
  `define hier_pbuf_tx_rd `hier_pbuf_tx.i_edma_pbuf_axi_tx_rd
  `define hier_pbuf_rx    `hier_pbuf_axi_top.i_edma_pbuf_rx
`else
  `ifdef rtl
    `define hier_pbuf_ahb_top `hierarchy.gen_dma.gen_pbuf_ahb_dma.i_edma_pbuf_ahb_top
  `else
    `define hier_pbuf_ahb_top `hierarchy.gen_dma_gen_pbuf_ahb_dma_i_edma_pbuf_ahb_top
  `endif
  `define hier_pbuf_tx    `hier_pbuf_ahb_top.i_edma_pbuf_ahb_tx
  `define hier_pbuf_tx_wr `hier_pbuf_tx.i_edma_pbuf_ahb_tx_wr
  `define hier_pbuf_tx_rd `hier_pbuf_tx.i_edma_pbuf_ahb_tx_rd
  `define hier_pbuf_rx    `hier_pbuf_ahb_top.i_edma_pbuf_rx
`endif

`ifdef rtl
  `define hier_pbuf_lockup_det     `hierarchy.gen_dma.gen_pbuf_lockup_det.i_edma_lockup_detect
`else
  `define hier_pbuf_lockup_det     `hierarchy.gen_dma_gen_pbuf_lockup_det_i_edma_lockup_detect
`endif

