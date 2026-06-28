//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CUSTOMER_DEMO_SYS_BUS_MEMORY_ADAPTER_SV
`define CUSTOMER_DEMO_SYS_BUS_MEMORY_ADAPTER_SV

//------------------------------------------------------------------------
// Class: customer_demo_sys_bus_memory_adapter
//
// Adapter to/from AXI slave memory model and AXI VIP TLM port.
// The reason this is done as an adapter is to that customers can swap the
// system bus VIP to their own bus protocol UVC and bridge.
// Note that because inheritance is used the functions that implement
// read_mem, write_mem and the other write_* analysis port implementations 
// should NOT use/call super!
//
//------------------------------------------------------------------------

class customer_demo_sys_bus_memory_adapter extends cdn_demo_sys_bus_memory_adapter;

  //------------------------------------------------------------------------
  // TLM PORTS
  //------------------------------------------------------------------------
  // Analysis imports which connect to AXI analysis port
  `uvm_analysis_imp_decl(_customer_sys_bus_transfer_received)
  `uvm_analysis_imp_decl(_customer_sys_bus_uvm_driver_Ended)
  `uvm_analysis_imp_decl(_customer_sys_bus_uvm_driver_BeforeSendResponse)

  // Variable: customer_sys_bus_transfer_imp
  // Analysis import for AXI callbacks
  uvm_analysis_imp_customer_sys_bus_transfer_received #(denaliCdn_axiTransaction, customer_demo_sys_bus_memory_adapter) customer_sys_bus_transfer_imp;
  `ifdef CDN_DEMO_C
  uvm_analysis_imp_customer_sys_bus_uvm_driver_Ended #(denaliCdn_axiTransaction, customer_demo_sys_bus_memory_adapter) customer_sys_bus_DriverTransactionEnded;
  uvm_analysis_imp_customer_sys_bus_uvm_driver_BeforeSendResponse #(denaliCdn_axiTransaction, customer_demo_sys_bus_memory_adapter) customer_sys_bus_DriverTransactionBeforeSendResponse;
  `endif

  //------------------------------------------------------------------------
  // MEMBER VARIABLES
  //------------------------------------------------------------------------

  // Variable: p_customer_env 
  // Pointer to customer env object.
  // Used to prevent compilation errors when referencing additional
  // attributes defined in the customer env object override.
  customer_demo_env p_customer_env;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  `uvm_component_utils(customer_demo_sys_bus_memory_adapter)

  //------------------------------------------------------------------------
  // Function: write_customer_sys_bus_transfer_received
  // This function will be called when the uvm_analysis_imp
  // customer_sys_bus_transfer_imp
  // is being written.
  // It is used to detect MSI messages over AXI and then report an MSI event
  // to the system software layer.
  //------------------------------------------------------------------------
  virtual function void write_customer_sys_bus_transfer_received(denaliCdn_axiTransaction trans);

    if (trans != null) begin
      if (trans.Direction == DENALI_CDN_AXI_DIRECTION_READ) begin
        `uvm_info(get_type_name(), $psprintf("Received AXI READ Xfer: Address = 0x%0x\t  Data[0] = 0x%0x, Data[1] = 0x%0x",
            trans.Address,trans.Data[0],trans.Data[1]), UVM_MEDIUM)
      end else begin
        `uvm_info(get_type_name(), $psprintf("Received AXI WRITE Xfer: Address = 0x%0x\t  Data[0] = 0x%0x, Data[1] = 0x%0x",
            trans.Address,trans.Data[0],trans.Data[1]), UVM_MEDIUM)
      end
    end

  endfunction : write_customer_sys_bus_transfer_received

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new(string name="customer_demo_sys_bus_memory_adapter", uvm_component parent = null);
    super.new(name, parent);
    customer_sys_bus_transfer_imp = new("customer_sys_bus_transfer_imp", this);
    `ifdef CDN_DEMO_C
    customer_sys_bus_DriverTransactionEnded = new("customer_sys_bus_DriverTransactionEnded", this);
    customer_sys_bus_DriverTransactionBeforeSendResponse = new("customer_sys_bus_DriverTransactionBeforeSendResponse", this);
    `endif
  endfunction : new

  //------------------------------------------------------------------------
  // Function: read_mem
  // All test code should use this function for memory reads. It abstracts
  // the system bus side UVC away from the test so that AXI can be swapped
  // for another protocol UVC such as AHB if required.
  //------------------------------------------------------------------------
  virtual function void read_mem(reg[63:0] addr, ref reg[7:0] mem_rdata[]);
    p_customer_env.customer_sys_bus_env.active_slave.memoryInst.readMem(addr, mem_rdata);
  endfunction : read_mem

  //------------------------------------------------------------------------
  // Function: write_mem
  // All test code should use this function for memory writes. It abstracts
  // the system bus side UVC away from the test so that AXI can be swapped
  // for another protocol UVC such as AHB if required.
  //------------------------------------------------------------------------
  virtual function void write_mem(reg[63:0] addr, reg[7:0] mem_wdata[]);
    p_customer_env.customer_sys_bus_env.active_slave.memoryInst.writeMem(addr, mem_wdata);
  endfunction : write_mem


  `ifdef CDN_DEMO_C
  //------------------------------------------------------------------------
  // Function: write_customer_sys_bus_uvm_driver_BeforeSendResponse
  // If we are using the C environment then at a read transfer get the
  // memory contents from the C env and drive the read contents on the AXI
  // bus.
  //------------------------------------------------------------------------
  virtual function void write_customer_sys_bus_uvm_driver_BeforeSendResponse (denaliCdn_axiTransaction trans);
    int _data, i;
    longint _addr;
    // At a read, modify the data back over AXI to the contents of the C memory space.
    if (trans.Direction == DENALI_CDN_AXI_DIRECTION_READ) begin
      _addr = trans.LowestAddress;
      i=0;
      while (_addr <= trans.HighestAddress) begin
        _data = c_dpi.c_api_demo_read8(_addr);
        trans.Data[i] = _data[7:0];
        i+=1;
        _addr+=1;
      end
    end
    foreach (trans.TransfersResp[i])
      trans.TransfersResp[i]= DENALI_CDN_AXI_RESPONSE_OKAY;
    void'(trans.transSet());

  endfunction : write_customer_sys_bus_uvm_driver_BeforeSendResponse

  //------------------------------------------------------------------------
  // Function: write_customer_sys_bus_uvm_driver_Ended
  // If we are using the C environment then at a write transfer ending change the
  // C contents to reflect the AXI write
  //------------------------------------------------------------------------
  virtual function void write_customer_sys_bus_uvm_driver_Ended (denaliCdn_axiTransaction trans);

    int _data, i;
    longint _addr;

    // At a write, update the contents of the C memory space to match what
    // was written over AXI.
    if (trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE) begin
      _addr = trans.LowestAddress;
      i=0;
      while (_addr <= trans.HighestAddress) begin
        // At a read, read from the memory
        void'(c_dpi.c_api_demo_write8(_addr, trans.Data[i]));
        i+=1;
        _addr+=1;
      end

    end
  endfunction : write_customer_sys_bus_uvm_driver_Ended
  `endif

  //------------------------------------------------------------------------
  // Function: connect_phase
  // For the C env add the appropriate callback so that the AXI accesses can match
  // the contents of the C env.
  //------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Get the c_dpi when we are using C stimulus
    super.connect_phase(phase);
    `ifdef CDN_DEMO_C
    if (!uvm_config_db#(virtual cdn_demo_module_top_c_dpi)::get(null, "", "c_dpi", c_dpi))
     `uvm_fatal(get_type_name(), "c_dpi object not set")
    `endif

  endfunction : connect_phase

endclass : customer_demo_sys_bus_memory_adapter

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
