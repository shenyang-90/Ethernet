/**************************************************************************
 File name    : cdn_enet_vip_cover.sv
 Title        : Coverage
 Project      : Ethernet 
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This class shows how coverage groups and bins can be created
                to sample various scenario coverage.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_cover.sv
 *
 * This file contains the coverage class for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_UVM_USER_COVER_SV
`define CDN_ENET_UVM_USER_COVER_SV

/*
 * Class: cdn_enet_vip_cover
 *
 * This class shows how coverage groups and bins can be created to sample 
 * various scenario coverage.
 */  
class cdn_enet_vip_cover extends uvm_component;

  //-----------------------------------------------------------------------
  // TLM PORTS.
  //-----------------------------------------------------------------------

  // Imp object declaration
  `uvm_analysis_imp_decl(_cdn_enet_rxframe_ended)
  
  /*
   * Variable: CoverRxFrameEndedImp
   * 
   * Analysis imp object which connect to analysis ports ultimately connected 
   * to UVC callbacks.
   */
  uvm_analysis_imp_cdn_enet_rxframe_ended #(denaliEnetTransaction, cdn_enet_vip_cover) CoverRxFrameEndedImp;
  
  // Pointer to the transaction(Packet class) to be covered
  denaliEnetTransaction coverTrans;

  //-----------------------------------------------------------------------
  // COVERGROUPS.
  //-----------------------------------------------------------------------

  // Example covergroup
  covergroup covRxFrameEndedTrans; 
    option.per_instance = 1;
    PacketKind : coverpoint coverTrans.PacketKind
    {
      bins Ethernet_802_3 = {DENALI_ENET_PACKETKIND_ETHERNET_802_3};
      bins Ethernet_VII   = {DENALI_ENET_PACKETKIND_ETHERNET_VII};
      bins Ethernet_Pause = {DENALI_ENET_PACKETKIND_ETHERNET_PAUSE};
      bins Ethernet_Jumbo = {DENALI_ENET_PACKETKIND_ETHERNET_JUMBO};
      bins Ethernet_Snap  = {DENALI_ENET_PACKETKIND_ETHERNET_SNAP};
      bins Ethernet_Magic = {DENALI_ENET_PACKETKIND_ETHERNET_MAGIC};
    }
    DataLength : coverpoint coverTrans.DataLength
    {
      bins Small  = {[46:500]};
      bins Medium = {[501:1000]};
      bins Large  = {[1001:1500]};
      bins Jumbo  = {[1535:9000]};
    }
    // Cross Coverage          
    PacketKindXDataLength : cross PacketKind,DataLength;
  endgroup : covRxFrameEndedTrans

  //-----------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //-----------------------------------------------------------------------

  `uvm_component_utils(cdn_enet_vip_cover)

  //-----------------------------------------------------------------------
  // CONSTRUCTOR.
  //-----------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_cover objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_enet_vip_cover", uvm_component parent = null);
    super.new(name, parent);
    // Creating instance for covRxFrameEndedTrans covergroup.
    covRxFrameEndedTrans = new();
    covRxFrameEndedTrans.set_inst_name({get_full_name(), ".covRxFrameEndedTrans"});
    // Creating object for CoverRxFrameEndedImp.
    CoverRxFrameEndedImp = new("CoverRxFrameEndedImp", this);
  endfunction : new

  //-----------------------------------------------------------------------
  // METHODS.
  //-----------------------------------------------------------------------

  /*
   * Method: write_cdn_enet_rxframe_ended
   * 
   * This function gets triggered by imp port CoverRxFrameEndedImp.
   */
  virtual function void write_cdn_enet_rxframe_ended(denaliEnetTransaction trans);
    $cast(coverTrans, trans);
    //Calling this method by which the coverage sample will be triggered.   
    collectRxFrameEndedCoverage();
  endfunction : write_cdn_enet_rxframe_ended

  /*
   * Method: write_cdn_enet_rxframe_ended
   * 
   * This function gets triggered by import port.
   */  
  virtual function void collectRxFrameEndedCoverage();
    //This will invoke coverage sampling in various coverpoint of respective covergroup.  
    covRxFrameEndedTrans.sample();
    `uvm_info(get_type_name(), {"Transaction Coverage Collected For Rx Frame Ended:\n"}, UVM_DEBUG);
  endfunction : collectRxFrameEndedCoverage 

endclass : cdn_enet_vip_cover

`endif // CDN_ENET_UVM_USER_COVER_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
