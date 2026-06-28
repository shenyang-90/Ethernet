//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_axi_vip_monitor class.
//----------------------------------------------------------------------------

/*
 * File: cdn_axi_vip_monitor.sv
 * 
 * This file contains the cdn_axi_vip_monitor class.
 */

`ifndef CDN_AXI_VIP_MONITOR_SV
`define CDN_AXI_VIP_MONITOR_SV

/*
 * Class: cdn_axi_vip_monitor
 * 
 * This class does nothing extra other than printing the needed field of the 
 * AXI transaction for debug purposes.
 */
class cdn_axi_vip_monitor extends cdnAxiUvmMonitor;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_component_utils(cdn_axi_vip_monitor)

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_axi_vip_monitor objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_axi_vip_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  /*
   * Method: EndedTransferCbF
   * 
   * Extends the base method and it is used to print needed fields of the AXI
   * transaction for debug purposes.
   */
  virtual function void EndedTransferCbF(denaliCdn_axiTransaction trans);
    string msg;
    super.EndedTransferCbF(trans);
    msg =
      {
        $psprintf("/----------------------------------------------------\n"),
        $psprintf("| Displaying AXI trans: \n"),
        $psprintf("| - Direction      : %s \n", trans.Direction.name()),
        $psprintf("| - LowestAddress  : 0x%0h \n", trans.LowestAddress),
        $psprintf("| - HighestAddress : 0x%0h \n", trans.HighestAddress)
      };
    for (int i=0; i<trans.Data.size(); i=i+4) begin
      msg =
        {
          msg,
          $psprintf("| - Data           : 0x%h [%0d:%0d]\n", {trans.Data[i], trans.Data[i+1], trans.Data[i+2], trans.Data[i+3]}, i+3, i)
        };
    end
    msg = 
      { 
        msg,
        $psprintf("\\----------------------------------------------------")
      };
    `uvm_info(get_type_name(), $psprintf("[write_cdn_axi_transfer_received]:\n%s", msg), UVM_DEBUG);
  endfunction : EndedTransferCbF

endclass : cdn_axi_vip_monitor

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
