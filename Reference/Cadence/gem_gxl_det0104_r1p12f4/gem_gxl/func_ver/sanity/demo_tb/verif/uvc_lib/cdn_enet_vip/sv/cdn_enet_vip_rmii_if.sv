/**************************************************************************
 File name    : cdn_enet_vip_rmii_if.sv
 Title        : RMII HDL Interface
 Project      : cdn_enet_vip UVC
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This file contains the RMII HDL interface for the cdn_enet_vip 
                UVC.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_rmii_if.sv
 * 
 * This file contains the RMII HDL interface for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_VIP_RMII_IF_SV
  `define CDN_ENET_VIP_RMII_IF_SV

// PLEASE do not remove, modify or comment out the timescale declaration below.
// Doing so will cause the scheduling of the pins in VIP model to be
// inaccurate and cause simulation problems and possible undetected errors. 
`timescale 1ns/1ns

/*
 * Function: cdn_enet_vip_rmii_if
 * 
 * This is the cdn_enet_vip UVC RMII HDL interface.
 */
interface cdn_enet_vip_rmii_if
(
  input sig_RMII_REF_CLK, 
  input sig_MDCLK
);

  //----------------------------------
  // SIGNALS
  //----------------------------------

  // Additional input signals from the DUT here to be tied off in the testbench
  wire mii_select;

  // Additional output signals from the DUT here to not left them unconnected
  wire rmii_rx_clk;
  wire rmii_tx_clk;

  // Interface Signals (to be used for DUT connection)
  wire       sig_RMII_CRS_DV;
  wire [1:0] sig_RMII_TX_DATA;
  wire [1:0] sig_RMII_RX_DATA;
  wire       sig_RMII_RX_ER;
  wire       sig_RMII_TX_EN;
  wire       sig_MDIO;

  // Denali signals (the internal VIP interface variables)
  reg       den_sig_RMII_CRS_DV;
  reg [1:0] den_sig_RMII_TX_DATA;
  reg [1:0] den_sig_RMII_RX_DATA;
  reg       den_sig_RMII_RX_ER;
  reg       den_sig_RMII_TX_EN;
  reg       den_sig_MDIO;
  reg       MDIO_Control;

  //----------------------------------
  // OUTPUT PINS
  //----------------------------------
  
  // Signals to be driven by the VIP are to be set with a continuous assignment.
  // The internal VIP signals are to be assigned to the interface signals.
  // In our case the DUT is a MAC controller, so the output pins from the VIP
  // are on the Rx path.
  
  //assign sig_RMII_TX_DATA = den_sig_RMII_TX_DATA;
  //assign sig_RMII_TX_EN   = den_sig_RMII_TX_EN;
  
  //assign sig_RMII_CRS_DV  = den_sig_RMII_CRS_DV;
  //assign sig_RMII_RX_DATA = den_sig_RMII_RX_DATA;
  //assign sig_RMII_RX_ER   = den_sig_RMII_RX_ER;
  
  //----------------------------------
  // INPUT PINS
  //----------------------------------  
  
  // Signals to be driven by the DUT are to be set with a procedural assignment.
  // Whenever the signal from the DUT changes state, the internal VIP signal
  // shall be updated.
  // In our case the DUT is a MAC controller, so the input pins to the VIP are
  // on the Tx path. 
  
  always@(sig_RMII_TX_DATA) den_sig_RMII_TX_DATA = sig_RMII_TX_DATA;
  always@(sig_RMII_TX_EN) den_sig_RMII_TX_EN     = sig_RMII_TX_EN;
  
  //always@(sig_RMII_CRS_DV) den_sig_RMII_CRS_DV   = sig_RMII_CRS_DV;
  //always@(sig_RMII_RX_DATA) den_sig_RMII_RX_DATA = sig_RMII_RX_DATA;
  //always@(sig_RMII_RX_ER) den_sig_RMII_RX_ER     = sig_RMII_RX_ER;

  //----------------------------------
  // INOUT PINS
  //----------------------------------   

  // Inout pins can be either driven by the VIP or DUT, so they are set with
  // both continuous and procedural assignments.

  assign sig_MDIO = (MDIO_Control) ? den_sig_MDIO : 1'bz;

  always@(sig_MDIO) begin
    if (MDIO_Control == 1'b0)
       den_sig_MDIO <= sig_MDIO;
  end

  //----------------------------------
  // VIP ACCESS
  //----------------------------------

  // Get the interface HDL path
  function automatic string getPath();
    string getDutInterfacePath;
    int length;    
    $sformat(getDutInterfacePath,"%m");
    length = getDutInterfacePath.len() - 9;
    $sformat(getPath,"%s",getDutInterfacePath.substr(0,length));           
  endfunction : getPath

  // Connect the signals internally to the VIP
  //initial begin
  //  $__internal__vip_set_access
  //  (
  //    MDIO_Control, 
  //    sig_MDCLK, 
  //    den_sig_MDIO, 
  //    den_sig_RMII_CRS_DV, 
  //    sig_RMII_REF_CLK, 
  //    den_sig_RMII_RX_DATA, 
  //    den_sig_RMII_RX_ER, 
  //    den_sig_RMII_TX_DATA, 
  //    den_sig_RMII_TX_EN
  //  );
  //end

`endif

endinterface : cdn_enet_vip_rmii_if

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------
