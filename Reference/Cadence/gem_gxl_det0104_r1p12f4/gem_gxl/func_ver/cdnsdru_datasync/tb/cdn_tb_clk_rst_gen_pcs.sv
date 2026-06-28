`ifndef CDN_TB_CLKS_AND_RESETS_SV
`define CDN_TB_CLKS_AND_RESETS_SV
/**************************************************************************
 File name    : cdn_tb_clks_and_resets.sv

 Title        : Clocks and Resets

 Project      : Ethernet 

 Developers   : Cadence Design System.

 Description  : Source file for clocks and resets
 
 Notes        : Developed in compliance with UVM guidelines

***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/
`timescale `CDN_TIMESCALE

module cdn_tb_clk_rst_gen_pcs #(
  parameter SERDES_FACTOR   = 20,
  parameter NUMBER_OF_LANES = 4
) (
   clk_rst_gen_if if1
);

// -----------------------------------------------------------------------------
//  Paramters
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//  Signal declarations
// -----------------------------------------------------------------------------
   reg           serdes_initialised;
   reg           reset_tb;             // reset for testbench
   wire          pclk_source;          // peripherical bus clock  
   wire          n_preset;
   
   
   assign        if1.pclk          = pclk_source;
   assign        if1.hclk          = pclk_source;
   assign        if1.n_hreset      = n_preset;
   assign        if1.n_preset      = n_preset;
   assign        if1.serdes_ready  = serdes_initialised;

   
// -----------------------------------------------------------------------------
//  File order:
//  1.0 Declare all clock interfaces
//  2.0 Initial config of primary clocks
//  3.0 Generate VIP clock on the MAC side
//  4.0 Generate tx clocks (mac and serdes) from referance clock
//  5.0 Generate rx mac clocks from referance clock
//  6.0 Generate rx serdes clocks from referance_ppm clock
//  7.0 Start up control - reset generation
//  8.0 Config clocks depending on speed mode
//  9.0 Checking and coverage
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// 1.0 Generate Primary clocks
// -----------------------------------------------------------------------------
  logic reset_clock_if_n;
  logic reference_rst;
  logic reference_clk;
  logic reference_ppm_rst;
  logic reference_ppm_clk;
  logic master_clock_en;
  logic all_locked;
  logic all_reset_n;
  
  cdn_clk_rst_gen_block reference_clk_rst();                     // Refernce clk connected to tx mac, tx serdes and rx mac
  cdn_clk_rst_gen_block reference_ppm_clk_rst();                 // Refernce clk with ppm diff connected to rx serdes
  cdn_clk_rst_gen_block mdio_master_clk_rst();                   // mdio clock
  cdn_clk_rst_gen_block apb_master_clk_rst();                    // apb bus clock
  cdn_clk_rst_gen_block tx_mac_vip_clk_rst();                    // tx MAC side clock lane 0
`ifdef CDN_DUT_BASE_pcs25g
  cdn_clk_rst_gen_block ovrsmpl_clk_rst();                       // led clock (ppm diff)
  cdn_clk_rst_gen_block tx_mac_clk_rst();                        // TX MAC side clock 
  cdn_clk_rst_gen_block tx_serdes_clk_rst();                     // TX MAC side clock 
  cdn_clk_rst_gen_block rx_serdes_clk_rst();                     // RX SERDES side clock
`else
  cdn_clk_rst_gen_block led_toggle_clk_rst();                     // led toggle for activity light tick
  cdn_clk_rst_gen_block tx_mac_clk_rst[NUMBER_OF_LANES-1:0]();    // TX MAC side clock array
  cdn_clk_rst_gen_block tx_serdes_clk_rst[NUMBER_OF_LANES-1:0](); // TX SERDES side clock array
  cdn_clk_rst_gen_block rx_serdes_clk_rst[NUMBER_OF_LANES-1:0](); // RX SERDES side clock array
`endif
  
// -----------------------------------------------------------------------------
// 2.0 Setup Primary clocks
// -----------------------------------------------------------------------------
  // Set up primary clocks at time zero 
  // some of this will be over ridden when the speed mode is known see proccess at the 
  // bottom of the file
  initial begin
    reference_clk_rst.clock_name        = " Reference Clk ";
    reference_ppm_clk_rst.clock_name    = " Reference PPM Clk ";
    mdio_master_clk_rst.clock_name      = " MDIO Master Clk ";
    apb_master_clk_rst.clock_name       = " APB Master Clk ";
    
    reference_clk_rst.clk_freq          = (156.25*SERDES_FACTOR);   // default before speed mode is set
    reference_ppm_clk_rst.clk_freq      = (156.25*SERDES_FACTOR);   // default before speed mode is set
    
    mdio_master_clk_rst.clk_freq        = 62.5;
    
    reference_clk_rst.rst_slave           = 1;
    reference_ppm_clk_rst.rst_slave       = 1;
    mdio_master_clk_rst.rst_slave         = 1;
    apb_master_clk_rst.rst_slave          = 1;
    apb_master_clk_rst.reset_off_delay    = 4;
    
    reference_clk_rst.reset_off_delay     = 4;
    reference_ppm_clk_rst.reset_off_delay = 4;
    
  `ifdef CDN_DUT_BASE_pcs25g
    ovrsmpl_clk_rst.clock_name            = " Oversampled Clock ";
    ovrsmpl_clk_rst.rst_slave             = 1;
  `else // XAUI20
    led_toggle_clk_rst.clock_name         = " LED Toggle ";
    led_toggle_clk_rst.clk_freq           = 0.1;
    led_toggle_clk_rst.rst_slave          = 1;
  `endif
    
  end

  assign reference_clk_rst.sys_reset_n      = reset_clock_if_n;
  assign reference_ppm_clk_rst.sys_reset_n  = reset_clock_if_n;
  assign mdio_master_clk_rst.sys_reset_n    = reset_clock_if_n;
  assign apb_master_clk_rst.sys_reset_n     = reset_clock_if_n;
    
  assign reference_rst                      = reference_clk_rst.reset_out_n;
  assign reference_clk                      = reference_clk_rst.clk_out;

  assign reference_ppm_rst                  = reference_ppm_clk_rst.reset_out_n;
  assign reference_ppm_clk                  = reference_ppm_clk_rst.clk_out;

  assign if1.mdc_rst_n                      = mdio_master_clk_rst.reset_out_n;
  assign if1.mdc                            = mdio_master_clk_rst.clk_out;

  assign n_preset                           = apb_master_clk_rst.reset_out_n;
  assign pclk_source                        = apb_master_clk_rst.clk_out;
  
`ifdef CDN_DUT_BASE_pcs25g
  assign if1.ovrsmpl_rst_n                  = ovrsmpl_clk_rst.reset_out_n;
  assign if1.ovrsmpl_clk                    = ovrsmpl_clk_rst.clk_out;
  assign ovrsmpl_clk_rst.sys_reset_n        = reset_clock_if_n;
`else
  assign if1.led_tick_toggle                = led_toggle_clk_rst.clk_out;
  assign led_toggle_clk_rst.sys_reset_n     = reset_clock_if_n;
`endif

// -----------------------------------------------------------------------------
//  Generate slave clocks
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
//  3.0 MAC VIP CLOCKS
// -----------------------------------------------------------------------------
  // tx vip mac 
  // When in 10G mode this will be the same as the DUT MAC clk
  // When in 1G/100M/10M mode this will be 1/4 of the DUT MAC clk as the VIP only
  // drives XGMII at 4 time the data rate required for GMII
  // NOTE there is a 32to64 XGMII DDR to SDR adaptor on the output of the VIP
  // ------------------------------------
  logic tx_mac_vip_locked;

  assign tx_mac_vip_clk_rst.sys_reset_n = reference_rst;
  assign tx_mac_vip_clk_rst.ref_clk     = reference_clk;
  assign tx_mac_vip_clk_rst.en_clk      = master_clock_en;
  assign if1.tx_vip_mac_rst             = tx_mac_vip_clk_rst.reset_out_n;
  assign if1.tx_vip_mac_clk             = tx_mac_vip_clk_rst.clk_out;
  assign tx_mac_vip_locked              = tx_mac_vip_clk_rst.locked_out;
  
  initial begin
  
    tx_mac_vip_clk_rst.clock_name         = " TX/RX MAC VIP ";   // name used in the info messages
    tx_mac_vip_clk_rst.clk_slave          = 1;                   // Use TB ref clock as base
    tx_mac_vip_clk_rst.rst_slave          = 1;                   // Use TB ref clock as base

  end

  // rx vip mac - this is the same as the tx vip mac clk
  // ------------------------------------
  assign if1.rx_vip_mac_rst             = tx_mac_vip_clk_rst.reset_out_n;
  assign if1.rx_vip_mac_clk             = tx_mac_vip_clk_rst.clk_out;
  assign rx_mac_vip_locked              = tx_mac_vip_clk_rst.locked_out;
  
// -----------------------------------------------------------------------------
// 4.0 TX CLOCKS
// -----------------------------------------------------------------------------
  // TX MAC side clocks
  // When in 10G mode all lanes must recive the same clock so lane 0 is muxed to 1-3
  // When in 1G/100M/10M mode the lane clocks are independent, Also for 100M/10M the clock will
  // be divided by 10 and 100 respectivly
  // ------------------------------------
  // tx mac lanes
  // ------------------------------------
  generate
  genvar tmc_no;
  
    if (NUMBER_OF_LANES == 1) begin
    
    
      assign tx_mac_clk_rst.sys_reset_n    = reference_rst;
      assign tx_mac_clk_rst.ref_clk        = reference_clk;
      assign tx_mac_clk_rst.en_clk         = master_clock_en;
      assign if1.tx_lane_mac_rst           = tx_mac_clk_rst.reset_out_n;
      assign if1.tx_lane_mac_clk           = tx_mac_clk_rst.clk_out;
      
      initial begin
      
        tx_mac_clk_rst.clock_name         = " TX/RX L0 MAC ";   // name used in the info messages
        tx_mac_clk_rst.clk_slave          = 1;                  // Use TB ref clock as base
        tx_mac_clk_rst.rst_slave          = 1;                  // Use TB ref clock as base
    
      end
      
    end
    else begin
    
      
      for (tmc_no=0; tmc_no<NUMBER_OF_LANES; tmc_no=tmc_no+1) begin : GEN_TX_MAC_LANE_CLKS
        
        assign tx_mac_clk_rst[tmc_no].sys_reset_n = reference_rst;
        assign tx_mac_clk_rst[tmc_no].ref_clk     = reference_clk;
        assign if1.tx_lane_mac_rst[tmc_no]        = tx_mac_clk_rst[tmc_no].reset_out_n;
        assign if1.tx_lane_mac_clk[tmc_no]        = tx_mac_clk_rst[tmc_no].clk_out;
        
        
        initial begin
          $swrite(tx_mac_clk_rst[tmc_no].clock_name, " TX/RX L%0d MAC ",tmc_no); // name used in the info messages
          tx_mac_clk_rst[tmc_no].clk_slave            = 1;                     // Use TB ref clock as base
          tx_mac_clk_rst[tmc_no].rst_slave            = 1;                     // Use TB ref clock as base
          tx_mac_clk_rst[tmc_no].pll_factor           = SERDES_FACTOR;         // multiply the ref clock.
          //tx_mac_clk_rst[tmc_no].skew_offset          = 0.25;                  // fixed offset of rising edge
          //tx_mac_clk_rst[tmc_no].clk_startup_delay    = 1;                     // number of clock cyles before clock is seen externaly
        end
      end
      
    end
  endgenerate
  
  // TX serdes clocks - these clocks are always the same frequency as the reference but with a
  // randomised skew - NOTE this is controled in the uvm cfg (file ../sv/cdn_cfg.sv)
  // It should be noted that due to spec limitations the inter lane skew can not be that big, so
  // it is currently set to +/- 0.8 of a cycle. The MAC to SERDES skew can be 0.0 - 0.99 of a cycle
  // ------------------------------------
  generate
  genvar tsc_no;
  
    if (NUMBER_OF_LANES == 1) begin
    
    
      assign tx_serdes_clk_rst.sys_reset_n    = reference_rst;
      assign tx_serdes_clk_rst.ref_clk        = reference_clk;
      assign tx_serdes_clk_rst.en_clk         = master_clock_en;
      assign if1.tx_lane_serdes_rst           = tx_serdes_clk_rst.reset_out_n;
      assign if1.tx_lane_serdes_clk           = tx_serdes_clk_rst.clk_out;
      
      initial begin
      
        tx_serdes_clk_rst.clock_name         = " TX/RX L0 SERDES ";   // name used in the info messages
        tx_serdes_clk_rst.clk_slave          = 1;                  // Use TB ref clock as base
        tx_serdes_clk_rst.rst_slave          = 1;                  // Use TB ref clock as base
    
      end
      
    end
    else begin
    

      for (tsc_no=0; tsc_no<NUMBER_OF_LANES; tsc_no=tsc_no+1) begin : GEN_TX_SERDES_LANE_CLKS
        
        assign tx_serdes_clk_rst[tsc_no].sys_reset_n = reference_rst;
        assign tx_serdes_clk_rst[tsc_no].ref_clk     = reference_clk;
        //assign tx_serdes_clk_rst[tsc_no].en_clk      = master_clock_en;
        assign if1.tx_lane_serdes_rst[tsc_no]        = tx_serdes_clk_rst[tsc_no].reset_out_n;
        assign if1.tx_lane_serdes_clk[tsc_no]        = tx_serdes_clk_rst[tsc_no].clk_out;
        
        
        initial begin
          $swrite(tx_serdes_clk_rst[tsc_no].clock_name, " TX L%0d SERDES ",tsc_no); // name used in the info messages
          tx_serdes_clk_rst[tsc_no].clk_slave            = 1;                       // Use TB ref clock as base
          tx_serdes_clk_rst[tsc_no].rst_slave            = 1;                       // Use TB ref clock as base
          tx_serdes_clk_rst[tsc_no].pll_factor           = SERDES_FACTOR;           // multiply the ref clock.
          //tx_serdes_clk_rst[tsc_no].skew_offset          = 0.25;                  // fixed offset of rising edge
          //tx_serdes_clk_rst[tsc_no].clk_startup_delay    = 4;                       // number of clock cyles before clock is seen externaly
        end
      end
      
    end
  endgenerate

  // TX serdes bit clocks - these clock drive the VIP and VIP side of the SERDES model
  // Direct use of ref clock
  // ------------------------------------
  assign if1.tx_lane_serdes_bit_rst        = reference_rst;
  assign if1.tx_lane_serdes_bit_clk        = reference_clk;

// -----------------------------------------------------------------------------
//  5.0 RX MAC CLOCKS
// -----------------------------------------------------------------------------
  // rx lane0:3 mac - these clocks are identical to the tx clock
  // ------------------------------------
  generate
  genvar rmc_no;
    if (NUMBER_OF_LANES == 1) begin
    
      assign if1.rx_lane_mac_rst        = tx_mac_clk_rst.reset_out_n;
      assign if1.rx_lane_mac_clk        = tx_mac_clk_rst.clk_out;

    end
    else begin
      for (rmc_no=0; rmc_no<NUMBER_OF_LANES; rmc_no=rmc_no+1) begin : GEN_RX_MAC_LANE_CLKS
      
        assign if1.rx_lane_mac_rst[rmc_no]        = tx_mac_clk_rst[rmc_no].reset_out_n;
        assign if1.rx_lane_mac_clk[rmc_no]        = tx_mac_clk_rst[rmc_no].clk_out;
        
      end
    end
  endgenerate

// -----------------------------------------------------------------------------
//  6.0 RX SERDES CLOCKS
// -----------------------------------------------------------------------------
  // RX serdes clocks - clock are of the same form as the tx but driven from the PPM Ref clock
  // Also the tolerable inter lane skew is greater set with in +/-0.25 of a cycle
  // ------------------------------------
  generate
  genvar rsc_no;
    if ( NUMBER_OF_LANES == 1 ) begin
    
      
      assign rx_serdes_clk_rst.sys_reset_n = reference_ppm_rst;
      assign rx_serdes_clk_rst.ref_clk     = reference_ppm_clk;
      assign rx_serdes_clk_rst.en_clk      = master_clock_en;
      assign if1.rx_lane_serdes_rst        = rx_serdes_clk_rst.reset_out_n;
      assign if1.rx_lane_serdes_clk        = rx_serdes_clk_rst.clk_out;
      
      
      initial begin
        $swrite(rx_serdes_clk_rst.clock_name, " RX L0 SERDES ",); // name used in the info messages
        rx_serdes_clk_rst.clk_slave            = 1;                       // Use TB ref clock as base
        rx_serdes_clk_rst.rst_slave            = 1;                       // Use TB ref clock as base
        rx_serdes_clk_rst.pll_factor           = SERDES_FACTOR;           // multiply the ref clock.
        //rx_serdes_clk_rst.skew_offset          = 0.20;                  // fixed offset of rising edge
        //rx_serdes_clk_rst.clk_startup_delay    = 4;                       // number of clock cyles before clock is seen externaly
      end

    end
    else begin
    
      
      for (rsc_no=0; rsc_no<NUMBER_OF_LANES; rsc_no=rsc_no+1) begin : GEN_RX_SERDES_LANE_CLKS
      
        assign rx_serdes_clk_rst[rsc_no].sys_reset_n = reference_ppm_rst;
        assign rx_serdes_clk_rst[rsc_no].ref_clk     = reference_ppm_clk;
        //assign rx_serdes_clk_rst[rsc_no].en_clk      = master_clock_en;
        assign if1.rx_lane_serdes_rst[rsc_no]        = rx_serdes_clk_rst[rsc_no].reset_out_n;
        assign if1.rx_lane_serdes_clk[rsc_no]        = rx_serdes_clk_rst[rsc_no].clk_out;
        
        
        initial begin
          $swrite(rx_serdes_clk_rst[rsc_no].clock_name, " RX L%0d SERDES ",rsc_no); // name used in the info messages
          rx_serdes_clk_rst[rsc_no].clk_slave            = 1;                       // Use TB ref clock as base
          rx_serdes_clk_rst[rsc_no].rst_slave            = 1;                       // Use TB ref clock as base
          rx_serdes_clk_rst[rsc_no].pll_factor           = SERDES_FACTOR;           // multiply the ref clock.
          //rx_serdes_clk_rst[rsc_no].skew_offset          = 0.20;                  // fixed offset of rising edge
          //rx_serdes_clk_rst[rsc_no].clk_startup_delay    = 4;                       // number of clock cyles before clock is seen externaly
        end
      end
      
    end
  endgenerate

  // RX serdes bit clocks - same as for tx but driven from PPM Ref clock
  // ------------------------------------
  assign if1.rx_lane_serdes_bit_rst        = reference_ppm_rst;
  assign if1.rx_lane_serdes_bit_clk        = reference_ppm_clk;
      
// -----------------------------------------------------------------------------
//  7.0 Start up control
// -----------------------------------------------------------------------------
 
  // Look across all the clocks to control start up
  // generate a combined lock signal
  // just look at the slowest clock (always vip mac side);
  assign all_locked     = & { tx_mac_vip_locked, rx_mac_vip_locked };
  // generate a combined reset signal 
  assign all_reset_n    = & { if1.tx_vip_mac_rst,
                              if1.rx_vip_mac_rst,
                              if1.mdc_rst_n,
                              if1.tx_lane_mac_rst,
                              if1.tx_lane_serdes_rst,
                              if1.tx_lane_serdes_bit_rst,
                              if1.rx_lane_mac_rst,
                              if1.rx_lane_serdes_rst,
                              if1.rx_lane_serdes_bit_rst};

  initial begin
  
    // set all the clock control to zero at start of day
    serdes_initialised                    = 1'b0;
    reset_tb                              = 1'b0;
    reset_clock_if_n                      = 1'b0;
    master_clock_en                       = 1'b0;
    
    #10;
    // wait till all the clocks are stable
    @(posedge all_locked) 
    // enable clock out puts
    master_clock_en                       = 1'b1;
    
    // wait a few of the slowest clocks 
    @(posedge if1.tx_vip_mac_clk) 
    @(posedge if1.tx_vip_mac_clk) 
    @(posedge if1.tx_vip_mac_clk) 
    // now release the resets this will be resynced in the clock blocks
    reset_clock_if_n                      = 1'b1;
    
    // wait for all the resets to be free
    @(posedge all_reset_n)
    @(negedge reference_clk)
    // tell the rest of the TB that the dut is running
    // NOTE the simulation traffic is held off untill both the DUT and VIP have synchronised
    // This is controlled in the wrapper
    serdes_initialised                    = 1'b1;
    reset_tb                              = 1'b1;

  end

// -----------------------------------------------------------------------------
//  8.0 Speed mode config 
// -----------------------------------------------------------------------------
   `ifdef CDN_DUT_BASE_pcs25g
  
  initial begin 

    rx_serdes_clk_rst.pll_factor    = `PCS25G_PMA_WIDTH;   // multiply the ref clock.
    tx_serdes_clk_rst.pll_factor    = `PCS25G_PMA_WIDTH;   // multiply the ref clock.
    tx_mac_vip_clk_rst.pll_factor   =  SERDES_FACTOR;
    tx_mac_clk_rst.pll_factor       =  SERDES_FACTOR;
      
    forever begin

      // select the ref clock frequncy
      // not the PPM diff is selected randomly from the uvm cfg
      // NOTE the oversampled clock is randomised from cdn_cfg.sv
      if (if1.speed_mode == cdn_tb_types_pkg::CDN_25GBPS) begin             // 25G mode
      
        reference_clk_rst.clk_freq          = (390.625*SERDES_FACTOR);
        reference_ppm_clk_rst.clk_freq      = (390.625*SERDES_FACTOR);
        
      end
      else begin                                      // 10G
      
        reference_clk_rst.clk_freq          = (156.25*SERDES_FACTOR);
        reference_ppm_clk_rst.clk_freq      = (156.25*SERDES_FACTOR);
        
      end
      
      @(if1.speed_mode);
    
    end

  end
  
  `endif      

  `ifdef CDN_DUT_BASE_xaui
  initial begin 
  
    forever begin

      // select the ref clock frequncy
      // not the PPM diff is selected randomly from the uvm cfg
      if (if1.speed_mode == cdn_tb_types_pkg::CDN_10GBPS) begin             // 10G mode
      
        reference_clk_rst.clk_freq          = (156.25*SERDES_FACTOR);
        reference_ppm_clk_rst.clk_freq      = (156.25*SERDES_FACTOR);
        
      end
      else begin                                      // 1G/100M/10M 
      
        reference_clk_rst.clk_freq          = (62.5*SERDES_FACTOR);
        reference_ppm_clk_rst.clk_freq      = (62.5*SERDES_FACTOR);
        //reference_ppm_clk_rst.ppm_tol       = -200;
        
      end
      
      // configure the slave clocks
      if (if1.speed_mode == cdn_tb_types_pkg::CDN_10GBPS) begin            // 10G mode

        // VIP at the same frequency as the mac for 10G
        tx_mac_vip_clk_rst.pll_factor  = (SERDES_FACTOR);
        tx_mac_clk_rst[0].pll_factor   = (SERDES_FACTOR);
        tx_mac_clk_rst[1].pll_factor   = (SERDES_FACTOR);
        tx_mac_clk_rst[2].pll_factor   = (SERDES_FACTOR);
        tx_mac_clk_rst[3].pll_factor   = (SERDES_FACTOR);

      end
      else if (if1.speed_mode == cdn_tb_types_pkg::CDN_1GBPS) begin             // 1G mode
      
        // VIP clock 1/4 of the speed as VIP is driving data 4x per cycle to xg2g
        tx_mac_vip_clk_rst.pll_factor  = (4.0*SERDES_FACTOR);
        tx_mac_clk_rst[0].pll_factor   =     (SERDES_FACTOR);
        tx_mac_clk_rst[1].pll_factor   =     (SERDES_FACTOR);
        tx_mac_clk_rst[2].pll_factor   =     (SERDES_FACTOR);
        tx_mac_clk_rst[3].pll_factor   =     (SERDES_FACTOR);
        
      end
      else if (if1.speed_mode == cdn_tb_types_pkg::CDN_100MBPS) begin        // 100M mode
      
        // all mac side clocks 1/10 of ref
        // with VIP being 1/4 of DUT
        tx_mac_vip_clk_rst.pll_factor  = (40.0*SERDES_FACTOR);
        
        tx_mac_clk_rst[0].pll_factor   = (10.0*SERDES_FACTOR);
        tx_mac_clk_rst[1].pll_factor   = (10.0*SERDES_FACTOR);
        tx_mac_clk_rst[2].pll_factor   = (10.0*SERDES_FACTOR);
        tx_mac_clk_rst[3].pll_factor   = (10.0*SERDES_FACTOR);
      
      end
      else if (if1.speed_mode == cdn_tb_types_pkg::CDN_10MBPS) begin  // 10M mode 
      
        // all mac side clocks 1/100 of ref
        // with VIP being 1/4 of DUT
        tx_mac_vip_clk_rst.pll_factor  = (400.0*SERDES_FACTOR);
      
        tx_mac_clk_rst[0].pll_factor   = (100.0*SERDES_FACTOR);
        tx_mac_clk_rst[1].pll_factor   = (100.0*SERDES_FACTOR);
        tx_mac_clk_rst[2].pll_factor   = (100.0*SERDES_FACTOR);
        tx_mac_clk_rst[3].pll_factor   = (100.0*SERDES_FACTOR);
      
      end
  
      // wait on speed mode change
      @(if1.speed_mode);
    
    end

  end
  `endif
  
// -----------------------------------------------------------------------------
//  9.0 Clock Checkers and coverage
// -----------------------------------------------------------------------------

  `ifdef CDN_DUT_BASE_xaui

  // Check the data path clock ratios
  //-----------------------------------------------------
  bit     [3:0] tx_mac_clk_fail;
  bit     [3:0] tx_mac_clk_fault;
  bit     [3:0] tx_mac_gbs_rate;
  bit     [3:0] tx_mac_10mbs_rate;
  bit     [3:0] tx_mac_100mbs_rate;
  bit     [3:0] tx_mac_lane_clk_dis;
  bit     [3:0] tx_sd_gbs_rate;
  bit     [3:0] tx_sd_clk_fail;
  bit     [3:0] tx_sd_clk_fault;
  bit     [3:0] tx_sd_lane_clk_dis;
  bit     [3:0] rx_sd_gbs_rate;
  bit     [3:0] rx_sd_clk_fail;
  bit     [3:0] rx_sd_clk_fault;
  bit     [3:0] rx_sd_lane_clk_dis;
  
  // For loop to give a 1 checker per lane
  genvar i_c;
  for (i_c = 0; i_c < 4; i_c++) begin : RATIO_AUDIT
  
    // check the Tx MAC side
    // these clocks are used for both Rx and Tx 
    // These clocks are differnt from the serdes side as the ratio can change depending on mode
    // NOTE this is checked once after reset, if changing clock configs are required then this 
    // will need to be updated
    initial begin
      
      tx_mac_gbs_rate      [i_c] = 0;
      tx_mac_10mbs_rate    [i_c] = 0;
      tx_mac_100mbs_rate   [i_c] = 0;
      tx_mac_lane_clk_dis  [i_c] = 0;
      tx_mac_clk_fail      [i_c] = 0;
      
      @(all_reset_n);
      
      // check the clock is enabled in when not in 10G mode the lane clock may be disable 
      // if the lane is active
      if (tx_mac_clk_rst[i_c].en_clk) begin 
        
        if (tx_mac_clk_rst[i_c].clock_ratio == SERDES_FACTOR  && 
            (if1.speed_mode   == cdn_tb_types_pkg::CDN_10GBPS ||
             if1.speed_mode   == cdn_tb_types_pkg::CDN_1GBPS    ))  begin
          tx_mac_gbs_rate[i_c]      = 1; // flag 10/1G ratio seen
        end
        else if (tx_mac_clk_rst[i_c].clock_ratio == SERDES_FACTOR * 10            && 
                 if1.speed_mode    == cdn_tb_types_pkg::CDN_100MBPS   )  begin
          tx_mac_100mbs_rate[i_c]   = 1; // flag 100M raito seen
        end
        else if (tx_mac_clk_rst[i_c].clock_ratio == SERDES_FACTOR * 100           && 
                 if1.speed_mode    == cdn_tb_types_pkg::CDN_10MBPS   )  begin
          tx_mac_10mbs_rate[i_c]    = 1; // flag 10M ratio seen
        end
        else begin
          tx_mac_clk_fail[i_c]      = 1; // the ratio did not match flag error
        end
          
      end
      else begin  // the clock has been disable by the cdn_cfg
      
        if (if1.speed_mode == cdn_tb_types_pkg::CDN_10GBPS) begin
          tx_mac_clk_fail[i_c]          = 1'b1; // should not happen in 10G mode
        end
        else begin
          tx_mac_lane_clk_dis[i_c]      = 1'b1; // flag the lane has been disabled
        end
        
      end
    end

    assign tx_mac_clk_fault[i_c] = tx_mac_clk_rst[i_c].clock_fault;
    
    // check the Tx serdes this is mainly done to ensure consistancy in clock enables etc
    // form is a s a bove but with out the checking on the mode
    initial begin
      
      tx_sd_gbs_rate      [i_c] = 0;
      tx_sd_lane_clk_dis  [i_c] = 0;
      tx_sd_clk_fail      [i_c] = 0;
      
      @(all_reset_n);
      
      if (tx_serdes_clk_rst[i_c].en_clk) begin
        
        if (tx_serdes_clk_rst[i_c].clock_ratio == SERDES_FACTOR)  begin
          tx_sd_gbs_rate[i_c]      = 1;
        end
        else begin
          tx_sd_clk_fail[i_c]      = 1;
        end
        
      end
      else begin
      
        if (if1.speed_mode == cdn_tb_types_pkg::CDN_10GBPS) begin
          tx_sd_clk_fail[i_c]          = 1'b1;
        end
        else begin
          tx_sd_lane_clk_dis[i_c]      = 1'b1;
        end
        
      end
    end
        
    assign tx_sd_clk_fault[i_c] = tx_serdes_clk_rst[i_c].clock_fault;

    
    // same again for Rx SERDES this is on the ppm differnece 
    initial begin
      
      rx_sd_gbs_rate      [i_c] = 0;
      rx_sd_lane_clk_dis  [i_c] = 0;
      rx_sd_clk_fail      [i_c] = 0;
      
      @(all_reset_n);
      
      if (rx_serdes_clk_rst[i_c].en_clk) begin
      
        
        if (rx_serdes_clk_rst[i_c].clock_ratio == SERDES_FACTOR)  begin
          rx_sd_gbs_rate[i_c]      = 1;
        end
        else begin
          rx_sd_clk_fail[i_c]      = 1;
        end

      end
      else begin
      
        if (if1.speed_mode == cdn_tb_types_pkg::CDN_10GBPS) begin
          rx_sd_clk_fail[i_c]          = 1'b1;
        end
        else begin
          rx_sd_lane_clk_dis[i_c]      = 1'b1;
        end
        
      end
    end
    
    assign rx_sd_clk_fault[i_c] = rx_serdes_clk_rst[i_c].clock_fault;

  end
  
  // Build up the coverage
  //-----------------------------------------------------
  // use the slow clock to monitor all properties
  bit    clock_tick;
  assign clock_tick = if1.led_tick_toggle;

  // make sure that the clock enables have been driven correctly
  // if the lane clock is disabled it must be for the hole lane in both directions
  // e.g. lane 1 tx mac clock enable = lane 1 tx serdes clock enable = lane 1 rx serdes clock enable 
  // etc....
  property prop_lane_clock_disabled_valid_0;
    @(posedge serdes_initialised)
    disable iff (!all_reset_n)
    ( (( tx_mac_lane_clk_dis[0] && tx_sd_lane_clk_dis[0] && rx_sd_lane_clk_dis[0] ) ||
      !( tx_mac_lane_clk_dis[0] || tx_sd_lane_clk_dis[0] || rx_sd_lane_clk_dis[0] )) == 1'b1);
  endproperty
  ast_lane_clock_disabled_valid_0 : assert property (prop_lane_clock_disabled_valid_0);
  
  property prop_lane_clock_disabled_valid_1;
    @(posedge serdes_initialised)
    disable iff (!all_reset_n)
    ( (( tx_mac_lane_clk_dis[1] && tx_sd_lane_clk_dis[1] && rx_sd_lane_clk_dis[1] ) ||
      !( tx_mac_lane_clk_dis[1] || tx_sd_lane_clk_dis[1] || rx_sd_lane_clk_dis[1] )) == 1'b1);
  endproperty
  ast_lane_clock_disabled_valid_1 : assert property (prop_lane_clock_disabled_valid_1);
  
  property prop_lane_clock_disabled_valid_2;
    @(posedge serdes_initialised)
    disable iff (!all_reset_n)
    ( (( tx_mac_lane_clk_dis[2] && tx_sd_lane_clk_dis[2] && rx_sd_lane_clk_dis[2] ) ||
      !( tx_mac_lane_clk_dis[2] || tx_sd_lane_clk_dis[2] || rx_sd_lane_clk_dis[2] )) == 1'b1);
  endproperty
  ast_lane_clock_disabled_valid_2 : assert property (prop_lane_clock_disabled_valid_2);
  
  property prop_lane_clock_disabled_valid_3;
    @(posedge serdes_initialised)
    disable iff (!all_reset_n)
    ( (( tx_mac_lane_clk_dis[3] && tx_sd_lane_clk_dis[3] && rx_sd_lane_clk_dis[3] ) ||
      !( tx_mac_lane_clk_dis[3] || tx_sd_lane_clk_dis[3] || rx_sd_lane_clk_dis[3] )) == 1'b1);
  endproperty
  ast_lane_clock_disabled_valid_3 : assert property (prop_lane_clock_disabled_valid_3);
  
   // cross the ratio with the enable
  covergroup cg_clock_rate_vs_disabled @(posedge serdes_initialised);
    // 10M mode
    crs_lane0_10m_others_disabled :  coverpoint &{tx_mac_10mbs_rate[0], tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[1]};
    crs_lane1_10m_others_disabled :  coverpoint &{tx_mac_10mbs_rate[1], tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[0]};
    crs_lane2_10m_others_disabled :  coverpoint &{tx_mac_10mbs_rate[2], tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[0],tx_mac_lane_clk_dis[1]};
    crs_lane3_10m_others_disabled :  coverpoint &{tx_mac_10mbs_rate[3], tx_mac_lane_clk_dis[0],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[1]};
    // 100M mode 
    crs_lane0_100m_others_disabled : coverpoint &{tx_mac_100mbs_rate[0], tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[1]};
    crs_lane1_100m_others_disabled : coverpoint &{tx_mac_100mbs_rate[1], tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[0]};
    crs_lane2_100m_others_disabled : coverpoint &{tx_mac_100mbs_rate[2], tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[0],tx_mac_lane_clk_dis[1]};
    crs_lane3_100m_others_disabled : coverpoint &{tx_mac_100mbs_rate[3], tx_mac_lane_clk_dis[0],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[1]};
    // 1G mode (Note 10G all lanes always enable)
    crs_lane0_1g_others_disabled :   coverpoint &{tx_mac_gbs_rate[0],  tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[1]};
    crs_lane1_1g_others_disabled :   coverpoint &{tx_mac_gbs_rate[1],  tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[0]};
    crs_lane2_1g_others_disabled :   coverpoint &{tx_mac_gbs_rate[2],  tx_mac_lane_clk_dis[3],tx_mac_lane_clk_dis[0],tx_mac_lane_clk_dis[1]};
    crs_lane3_1g_others_disabled :   coverpoint &{tx_mac_gbs_rate[3],  tx_mac_lane_clk_dis[0],tx_mac_lane_clk_dis[2],tx_mac_lane_clk_dis[1]};
  endgroup
  
  // cover the APB frequency against the dut both the serdes side 
  // the above coverage checks for that the RX/TX mac/serdes clocking is correct, therefore 
  // just check APB against the tx.
  // Just mesure once at exit from reset
  //---------------------------------------------------------------------------------------
  // APB less than MAC side 
  real xaui_1g_clk_feq      = 62.5;
  real less_than_p          = 0.50;
  real grater_than_p        = 1.50;
  
  cov_apb_less_than_mac_10m : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_10MBPS)
      (apb_master_clk_rst.clk_freq < xaui_1g_clk_feq/100*less_than_p)
  );
  cov_apb_less_than_mac_100m : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_100MBPS)
      (apb_master_clk_rst.clk_freq < xaui_1g_clk_feq/10*less_than_p)
  );
  cov_apb_less_than_mac_1g : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_1GBPS)
      (apb_master_clk_rst.clk_freq < xaui_1g_clk_feq*less_than_p)
  );
  // APB grater than MAC side
  cov_apb_grater_than_mac_10m : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_10MBPS)
      (apb_master_clk_rst.clk_freq > xaui_1g_clk_feq/100*grater_than_p)
  );
  cov_apb_grater_than_mac_100m : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_100MBPS)
      (apb_master_clk_rst.clk_freq > xaui_1g_clk_feq/10*grater_than_p)
  );
  cov_apb_grater_than_mac_1g : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_1GBPS)
      (apb_master_clk_rst.clk_freq > xaui_1g_clk_feq*grater_than_p)
  );

  // check for the case were the APB clock could be grater than the mac and less than the serdes
  cov_apb_between_mac_serdes_10m : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_10MBPS)
      (apb_master_clk_rst.clk_freq > xaui_1g_clk_feq/100 && apb_master_clk_rst.clk_freq < xaui_1g_clk_feq)
  );
  cov_apb_between_mac_serdes_100m : cover  property (
    @(posedge serdes_initialised)
    disable iff(if1.speed_mode != cdn_tb_types_pkg::CDN_100MBPS)
      (apb_master_clk_rst.clk_freq > xaui_1g_clk_feq/10 && apb_master_clk_rst.clk_freq > xaui_1g_clk_feq)
  );

  
  // assert if the any clock fails it ratio - this checking the TB more than any thing
  // causing probelms commented out until fixed 
  ast_clock_count_fail : assert property (
    @(posedge clock_tick)
    disable iff (!all_reset_n)
      |{tx_mac_clk_fail, tx_sd_clk_fail, rx_sd_clk_fail,
        tx_mac_clk_fault,tx_sd_clk_fault,rx_sd_clk_fault} == 1'b0
  );
  
  
  `endif

endmodule
`endif
