//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the cdn_apb_vip UVC driver user class.
//----------------------------------------------------------------------------

/*
 * File: cdn_apb_vip_driver.sv
 * 
 * This file contains the cdn_apb_vip UVC driver user class.
 */

`ifndef CDN_APB_VIP_DRIVER_SV
`define CDN_APB_VIP_DRIVER_SV

/*
 * Class: cdn_apb_vip_driver
 * 
 * This is the cdn_apb_vip UVC driver user class.
 * It adds two tasks for read/write which can be used simply by the C test layer
 * API.
 */
class cdn_apb_vip_driver extends cdnApbUvmDriver;

   //----------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //----------------------------------------------------------------------
   
   `uvm_component_utils(cdn_apb_vip_driver)

   //----------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS.
   //----------------------------------------------------------------------

   /*
    * Method: new
    * 
    * The class constructor.
    * It is used to construct cdn_apb_vip_driver objects.
    * 
    * Parameters:
    * 
    *    name   - The name of the class to construct.
    *    parent - The parent class.
    */
   function new(string name = "cdn_apb_vip_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction : new

   /*
    * Method: build_phase
    * 
    * This UVM phase is used for building the testbench component hierarchy.
    * 
    * Parameters:
    * 
    *    phase - The UVM phase object.
    */ 
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

   /*
    * Method: connect_phase
    * 
    * This UVM phase is used for making connections between components in the hierarchy.
    * 
    * Parameters:
    * 
    *    phase - The UVM phase object.
    */ 
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction : connect_phase

   //----------------------------------------------------------------------
   // OTHER METHODS.
   //----------------------------------------------------------------------

   /*
    * Method: write
    * 
    * This method is used in the DPI-C interface tasks
    * to write APB registers from the C environment.
    * 
    * Parameters:
    * 
    *    _addr - The address to write.
    *    _data - The data to write.
    */ 
   task write(input int _addr, input int _data);
      cdn_apb_vip_write_seq seq = cdn_apb_vip_write_seq::type_id::create();
      seq.addr = _addr;
      seq.data = _data;
      seq.start(pAgent.sequencer);
   endtask : write

   /*
    * Method: read
    * 
    * This method is used in the DPI-C interface tasks
    * to read APB registers from the C environment.
    * 
    * Parameters:
    * 
    *    _addr - The address to read.
    *    _data - The read data.
    */
   task read(input int _addr, output int _data);
      cdn_apb_vip_read_seq seq = cdn_apb_vip_read_seq::type_id::create();
      seq.addr = _addr;
      seq.start(pAgent.sequencer);
      _data = seq.data;
   endtask : read

   /*
    * Method: print
    * 
    * Used in the DPI-C interface tasks.
    * Equivalent to write method with no delay.
    * 
    * Parameters:
    * 
    *    _addr - The address to write.
    *    _data - The data to write.
    */
   task print(input int _addr, input int _data);
      cdn_apb_vip_write_no_delay_seq seq = cdn_apb_vip_write_no_delay_seq::type_id::create();
      seq.addr = _addr;
      seq.data = _data;
      seq.start(pAgent.sequencer);
   endtask : print

   /*
    * Method: driveTransaction
    * 
    * Overwrite the base implementation as the UVM_HIGH is used instead of
    * UVM_FULL and there is a lot of verbose messages that are not needed.
    * 
    * Parameters:
    * 
    *    tr - The APB transaction.
    */   
   virtual task driveTransaction (denaliCdn_apbTransaction tr);
      `uvm_info(get_type_name(), "Sending trans to bfm", UVM_DEBUG);
       void'(pInst.transAdd(tr, 0));
       waitForTransactionEnd(tr);
    endtask : driveTransaction

endclass : cdn_apb_vip_driver

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
