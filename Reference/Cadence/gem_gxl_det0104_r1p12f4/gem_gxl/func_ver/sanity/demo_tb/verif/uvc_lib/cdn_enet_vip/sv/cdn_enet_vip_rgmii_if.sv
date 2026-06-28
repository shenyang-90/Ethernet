/**************************************************************************
 File name    : cdn_enet_vip_rgmii_if.sv
 Title        : RGMII HDL Interface
 Project      : cdn_enet_vip UVC
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This file contains the RGMII HDL interface for the cdn_enet_vip 
                UVC.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_rgmii_if.sv
 * 
 * This file contains the RGMII HDL interface for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_VIP_RGMII_IF_SV
  `define CDN_ENET_VIP_RGMII_IF_SV

// PLEASE do not remove, modify or comment out the timescale declaration below.
// Doing so will cause the scheduling of the pins in VIP model to be
// inaccurate and cause simulation problems and possible undetected errors. 
`timescale 1ns/1ns

/*
 * Function: cdn_enet_vip_rgmii_if
 * 
 * This is the cdn_enet_vip UVC RGMII HDL interface.
 */
interface cdn_enet_vip_rgmii_if
(
  input sig_RGMII_TXC,
  input sig_RGMII_RXC,
  input sig_MDCLK
);

  //----------------------------------
  // SIGNALS
  //----------------------------------

  // Additional output signals from the DUT here to not left them unconnected
  wire       rgmii_link_status;
  wire [1:0] rgmii_speed;      
  wire       rgmii_duplex_out; 

  // These GMII signals are here because the DUT has a feature that allows to 
  // switch the RGMII interface to MII mode of operation. This is anyway not
  // demonstrated and they are used only to be tied off in testbench connection
  wire sig_GMII_COL;
  wire sig_GMII_CRS;
  wire sig_GMII_TX_ER;
  wire sig_GMII_RX_ER;

  // Interface Signals (to be used for DUT connection)
  wire [3:0] sig_RGMII_TD;
  wire       sig_RGMII_TX_CTL;
  wire [3:0] sig_RGMII_RD;
  wire       sig_RGMII_RX_CTL;
  wire       sig_MDIO;

  // Denali signals (the internal VIP interface variables)
  reg [3:0] den_sig_RGMII_TD;
  reg       den_sig_RGMII_TX_CTL;
  reg [3:0] den_sig_RGMII_RD;
  reg       den_sig_RGMII_RX_CTL;
  reg       den_sig_MDIO;
  reg       MDIO_Control;
  
  //----------------------------------
  // OUTPUT PINS
  //----------------------------------
  
  // Signals to be driven by the VIP are to be set with a continuous assignment.
  // The internal VIP signals are to be assigned to the interface signals.
  // In our case the DUT is a MAC controller, so the output pins from the VIP
  // are on the Rx path.

  //assign sig_RGMII_TD     = den_sig_RGMII_TD;
  //assign sig_RGMII_TX_CTL = den_sig_RGMII_TX_CTL;
  
  assign sig_RGMII_RD     = den_sig_RGMII_RD;
  assign sig_RGMII_RX_CTL = den_sig_RGMII_RX_CTL;

  //----------------------------------
  // INPUT PINS
  //----------------------------------  
  
  // Signals to be driven by the DUT are to be set with a procedural assignment.
  // Whenever the signal from the DUT changes state, the internal VIP signal
  // shall be updated.
  // In our case the DUT is a MAC controller, so the input pins to the VIP are
  // on the Tx path.

  always@(sig_RGMII_TD) den_sig_RGMII_TD         = sig_RGMII_TD;
  always@(sig_RGMII_TX_CTL) den_sig_RGMII_TX_CTL = sig_RGMII_TX_CTL;  
  
  //always@(sig_RGMII_RD) den_sig_RGMII_RD         = sig_RGMII_RD;
  //always@(sig_RGMII_RX_CTL) den_sig_RGMII_RX_CTL = sig_RGMII_RX_CTL;
  
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
      den_sig_RGMII_RD, 
      sig_RGMII_RXC, 
      den_sig_RGMII_RX_CTL, 
      den_sig_RGMII_TD, 
      sig_RGMII_TXC, 
      den_sig_RGMII_TX_CTL, 
      MDIO_Control, 
      sig_MDCLK, 
      den_sig_MDIO
    );
  end

endinterface : cdn_enet_vip_rgmii_if

`endif

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------
