/**************************************************************************
 File name    : cdn_enet_vip_gmii_if.sv
 Title        : GMII HDL Interface
 Project      : cdn_enet_vip UVC
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This file contains the GMII HDL interface for the cdn_enet_vip 
                UVC.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_gmii_if.sv
 * 
 * This file contains the GMII HDL interface for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_VIP_GMII_IF_SV
  `define CDN_ENET_VIP_GMII_IF_SV

// PLEASE do not remove, modify or comment out the timescale declaration below.
// Doing so will cause the scheduling of the pins in VIP model to be
// inaccurate and cause simulation problems and possible undetected errors. 
`timescale 1ns/1ns

/*
 * Function: cdn_enet_vip_gmii_if
 * 
 * This is the cdn_enet_vip UVC GMII HDL interface.
 */
interface cdn_enet_vip_gmii_if
(
  input sig_GMII_TX_CLK, 
  input sig_GMII_RX_CLK, 
  input sig_MDCLK
);

  //----------------------------------
  // SIGNALS
  //----------------------------------

  // Interface Signals (to be used for DUT connection)
  wire       sig_GMII_CRS;
  wire       sig_GMII_RX_DV;
  wire [7:0] sig_GMII_TX_DATA;
  wire [7:0] sig_GMII_RX_DATA;
  wire       sig_GMII_RX_ER;
  wire       sig_GMII_TX_ER;
  wire       sig_GMII_COL;
  wire       sig_GMII_TX_EN;
  wire       sig_MDIO;

  // Denali signals (the internal VIP interface variables)
  reg       den_sig_GMII_CRS;
  reg       den_sig_GMII_RX_DV;
  reg [7:0] den_sig_GMII_TX_DATA;
  reg [7:0] den_sig_GMII_RX_DATA;
  reg       den_sig_GMII_RX_ER;
  reg       den_sig_GMII_TX_ER;
  reg       den_sig_GMII_COL;
  reg       den_sig_GMII_TX_EN;
  reg       den_sig_MDIO;
  reg       MDIO_Control;

  //----------------------------------
  // OUTPUT PINS
  //----------------------------------
  
  // Signals to be driven by the VIP are to be set with a continuous assignment.
  // The internal VIP signals are to be assigned to the interface signals.
  // In our case the DUT is a MAC controller, so the output pins from the VIP
  // are on the Rx path.

  // Tx
  //assign sig_GMII_TX_DATA = den_sig_GMII_TX_DATA;
  //assign sig_GMII_TX_ER   = den_sig_GMII_TX_ER;
  //assign sig_GMII_TX_EN   = den_sig_GMII_TX_EN;

  // Rx
  assign sig_GMII_CRS     = den_sig_GMII_CRS;
  assign sig_GMII_RX_DV   = den_sig_GMII_RX_DV;
  assign sig_GMII_RX_DATA = den_sig_GMII_RX_DATA;
  assign sig_GMII_RX_ER   = den_sig_GMII_RX_ER;
  assign sig_GMII_COL     = den_sig_GMII_COL;

  //----------------------------------
  // INPUT PINS
  //----------------------------------  
  
  // Signals to be driven by the DUT are to be set with a procedural assignment.
  // Whenever the signal from the DUT changes state, the internal VIP signal
  // shall be updated.
  // In our case the DUT is a MAC controller, so the input pins to the VIP are
  // on the Tx path.

  // Tx
  always@(sig_GMII_TX_EN) den_sig_GMII_TX_EN     = sig_GMII_TX_EN;
  always@(sig_GMII_TX_DATA) den_sig_GMII_TX_DATA = sig_GMII_TX_DATA;
  always@(sig_GMII_TX_ER) den_sig_GMII_TX_ER     = sig_GMII_TX_ER;

  // Rx
  //always@(sig_GMII_CRS) den_sig_GMII_CRS         = sig_GMII_CRS;
  //always@(sig_GMII_RX_DV) den_sig_GMII_RX_DV     = sig_GMII_RX_DV;
  //always@(sig_GMII_RX_ER) den_sig_GMII_RX_ER     = sig_GMII_RX_ER;
  //always@(sig_GMII_RX_DATA) den_sig_GMII_RX_DATA = sig_GMII_RX_DATA;
  //always@(sig_GMII_COL) den_sig_GMII_COL         = sig_GMII_COL;

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
  initial begin
    $__internal__vip_set_access
    (
      MDIO_Control, 
      den_sig_GMII_COL, 
      den_sig_GMII_CRS, 
      sig_GMII_RX_CLK, 
      den_sig_GMII_RX_DATA,
      den_sig_GMII_RX_DV, 
      den_sig_GMII_RX_ER, 
      sig_GMII_TX_CLK, 
      den_sig_GMII_TX_DATA, 
      den_sig_GMII_TX_EN, 
      den_sig_GMII_TX_ER,
      sig_MDCLK,
      den_sig_MDIO
    );
  end
  
endinterface : cdn_enet_vip_gmii_if

`endif

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------
