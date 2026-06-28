//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Class: customer_demo_sys_bus_reg_adapter
//
// Convert (adapt) between a UVM reg access and an APB access
// Additionally provide a high level API (basic read and write tasks) to
// allow this adapter class to be replaced with an non APB implementation.
// The read and write tasks use basic address and data inputs so can easily
// be adapted to a different bus solution.
//
//------------------------------------------------------------------------

`ifndef CUSTOMER_DEMO_SYS_BUS_REG_ADAPTER
`define CUSTOMER_DEMO_SYS_BUS_REG_ADAPTER

class customer_demo_sys_bus_reg_adapter extends cdn_demo_sys_bus_reg_adapter;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  `uvm_object_utils(customer_demo_sys_bus_reg_adapter)

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new(string name="customer_demo_sys_bus_reg_adapter");
    super.new(name);
  endfunction
  
  //------------------------------------------------------------------------
  // Function: reg2bus
  // Convert from uvm_reg_bus_op to config_bus
  //------------------------------------------------------------------------
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw );

    denaliCdn_apbTransaction tr;
    tr = denaliCdn_apbTransaction::type_id::create("tr");
    
    // For register acceses - do a single 32-bit burst, aligned
    tr.Addr = rw.addr;
    tr.Direction = (rw.kind == UVM_WRITE) ?
                  DENALI_CDN_APB_DIRECTION_WRITE : DENALI_CDN_APB_DIRECTION_READ;
    tr.Data[31:0] = rw.data[31:0];
    // Support all strobes active only.
    tr.Strobe = (rw.kind == UVM_WRITE) ?  4'hF :  4'h0;
    `uvm_info(get_type_name(), 
              $sformatf("reg2bus() APB access. kind=%s addr='h%8h data='h%8h status=%s",
                        rw.kind.name, rw.addr, rw.data, rw.status.name), UVM_FULL)
   
    return (tr);
  endfunction // reg2bus
  
  //------------------------------------------------------------------------
  // Function: bus2reg
  // Convert from config_bus to uvm_reg_bus_op
  //------------------------------------------------------------------------

  virtual function void bus2reg(uvm_sequence_item bus_item,
                               ref uvm_reg_bus_op rw );
    
    denaliCdn_apbTransaction tr;
    if ($cast(tr,bus_item)) begin
      rw.addr = tr.Addr;
      rw.kind = (tr.Direction == DENALI_CDN_APB_DIRECTION_WRITE) ?  UVM_WRITE : UVM_READ;
      rw.data[31:0] = tr.Data[31:0];
      `uvm_info(get_type_name(), 
                $sformatf("bus2reg() APB access. kind=%s addr='h%h data='h%h status=%s",
                          rw.kind.name, rw.addr, rw.data, rw.status.name), UVM_FULL)
    end
    else begin
      `uvm_fatal("NOT_REG_TYPE", "Provided bus_item is not correct type")
      return;
    end
    
  endfunction // bus2reg   

  //------------------------------------------------------------------------
  // Task: write
  // This utility task enables a user to start an APB write sequence easily.
  //------------------------------------------------------------------------
  task write(input int addr, input int data);
    cdn_apb_vip_driver _driver;
    $cast(_driver, driver);
    _driver.write(addr,data);
  endtask : write
  
  //------------------------------------------------------------------------
  // Task: read
  // This utility task enables a user to start an APB read sequence easily.
  //------------------------------------------------------------------------
  task read(input int addr, output int data);
    cdn_apb_vip_driver _driver;
    $cast(_driver, driver);
    _driver.read(addr,data);
  endtask : read

endclass // customer_demo_sys_bus_reg_adapter


`endif
