//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_SYS_BUS_MEMORY_ADAPTER_SV
`define CDN_DEMO_SYS_BUS_MEMORY_ADAPTER_SV

//------------------------------------------------------------------------
// Class: cdn_demo_sys_bus_memory_adapter
// Adapter to/from AXI slave memory model and AXI VIP TLM port.
// The reason this is done as an adapter is to that customers can swap the
// system bus VIP to their own bus protocol UVC and bridge.
//------------------------------------------------------------------------
class cdn_demo_sys_bus_memory_adapter extends uvm_component;

  //------------------------------------------------------------------------
  // MEMBER VARIABLES
  //------------------------------------------------------------------------
  // Variable: p_env
  // Pointer to VE for access to UVC that contains the bus memory model
  cdn_demo_env p_env;


  //------------------------------------------------------------------------
  // TLM PORTS
  //------------------------------------------------------------------------
  // The virtual interface used to drive and view the misc HDL signals.

  //------------------------------------------------------------------------
  // INTERFACES
  //------------------------------------------------------------------------

  `ifdef CDN_DEMO_C
  // If we are using the C environment then at a read modify the contents sent
  // back over AXI to what is in the C memory space.
  virtual cdn_demo_module_top_c_dpi c_dpi;
  `endif

  //------------------------------------------------------------------------
  // TLM PORTS
  //------------------------------------------------------------------------
  // Analysis imports which connect to AXI analysis port
  `uvm_analysis_imp_decl(_cdn_axi_transfer_received)
  `uvm_analysis_imp_decl(_cdn_axi_uvm_driver_Ended)
  `uvm_analysis_imp_decl(_cdn_axi_uvm_driver_BeforeSendResponse)

  // Variable: axi_transfer_imp
  // Analysis import for AXI callbacks
  uvm_analysis_imp_cdn_axi_transfer_received #(denaliCdn_axiTransaction, cdn_demo_sys_bus_memory_adapter) axi_transfer_imp;
  `ifdef CDN_DEMO_C
  uvm_analysis_imp_cdn_axi_uvm_driver_Ended #(denaliCdn_axiTransaction, cdn_demo_sys_bus_memory_adapter) DriverTransactionEnded;
  uvm_analysis_imp_cdn_axi_uvm_driver_BeforeSendResponse #(denaliCdn_axiTransaction, cdn_demo_sys_bus_memory_adapter) DriverTransactionBeforeSendResponse;
  `endif

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------
  `uvm_component_utils_begin(cdn_demo_sys_bus_memory_adapter)
    `uvm_field_object(p_env, UVM_DEFAULT|UVM_REFERENCE)
  `uvm_component_utils_end

  //------------------------------------------------------------------------
  // Function: write_cdn_axi_transfer_received
  // This function will be called when the uvm_analysis_imp axi_transfer_imp
  // is being written.
  // It is used to detect MSI messages over AXI and then report an MSI event
  // to the system software layer.
  //------------------------------------------------------------------------
  virtual function void write_cdn_axi_transfer_received(denaliCdn_axiTransaction trans);

    if (trans != null) begin
      if (trans.Direction == DENALI_CDN_AXI_DIRECTION_READ) begin
        `uvm_info(get_type_name(), $psprintf("Received AXI READ Xfer: Address = 0x%0x\t  Data[0] = 0x%0x, Data[1] = 0x%0x",
            trans.Address,trans.Data[0],trans.Data[1]), UVM_MEDIUM)
      end else begin
        `uvm_info(get_type_name(), $psprintf("Received AXI WRITE Xfer: Address = 0x%0x\t  Data[0] = 0x%0x, Data[1] = 0x%0x",
            trans.Address,trans.Data[0],trans.Data[1]), UVM_MEDIUM)
      end
    end

  endfunction : write_cdn_axi_transfer_received

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new(string name="cdn_demo_sys_bus_memory_adapter", uvm_component parent = null);
    super.new(name, parent);
    axi_transfer_imp = new("axi_transfer_imp", this);
    `ifdef CDN_DEMO_C
    DriverTransactionEnded = new("DriverTransactionEnded", this);
    DriverTransactionBeforeSendResponse = new("DriverTransactionBeforeSendResponse", this);
    `endif
  endfunction : new

  //------------------------------------------------------------------------
  // Function: read_mem
  // All test code should use this function for memory reads. It abstracts
  // the system bus side UVC away from the test so that AXI can be swapped
  // for another protocol UVC such as AHB if required.
  //------------------------------------------------------------------------
  virtual function void read_mem(reg[63:0] addr, ref reg[7:0] mem_rdata[]);
    p_env.axi_env.active_slave.memoryInst.readMem(addr, mem_rdata);
  endfunction : read_mem

  //------------------------------------------------------------------------
  // Function: write_mem
  // All test code should use this function for memory writes. It abstracts
  // the system bus side UVC away from the test so that AXI can be swapped
  // for another protocol UVC such as AHB if required.
  //------------------------------------------------------------------------
  virtual function void write_mem(reg[63:0] addr, reg[7:0] mem_wdata[]);
    p_env.axi_env.active_slave.memoryInst.writeMem(addr, mem_wdata);
  endfunction : write_mem


  `ifdef CDN_DEMO_C
  //------------------------------------------------------------------------
  // Function: write_cdn_axi_uvm_driver_BeforeSendResponse
  // If we are using the C environment then at a read transfer get the
  // memory contents from the C env and drive the read contents on the AXI
  // bus.
  //------------------------------------------------------------------------
  virtual function void write_cdn_axi_uvm_driver_BeforeSendResponse (denaliCdn_axiTransaction trans);
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

  endfunction : write_cdn_axi_uvm_driver_BeforeSendResponse

  //------------------------------------------------------------------------
  // Function: write_cdn_axi_uvm_driver_Ended
  // If we are using the C environment then at a write transfer ending change the
  // C contents to reflect the AXI write
  //------------------------------------------------------------------------
  virtual function void write_cdn_axi_uvm_driver_Ended (denaliCdn_axiTransaction trans);

    int _data, i, j;
    longint _addr;
    reg [31:0] _strobe;

    // At a write, update the contents of the C memory space to match what
    // was written over AXI.
    if (trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE) begin
      _addr = trans.LowestAddress;
      // Get the first byte write position, by getting the bus width modulus
      // of the LowestAddress
      j=trans.LowestAddress % (p_env.axi_env.active_slave.cfg.write_data_width/8);
      i=0;
      while (_addr <= trans.HighestAddress) begin
        _strobe = trans.StrobeArray[j/(p_env.axi_env.active_slave.cfg.write_data_width/8)];
        // At a write, write to the memory, assuming strobe is active
        if (_strobe[j%(p_env.axi_env.active_slave.cfg.write_data_width/8)]) begin
          void'(c_dpi.c_api_demo_write8(_addr, trans.Data[i]));
        end
        i+=1;
        j+=1;
        _addr+=1;
      end

    end
  endfunction : write_cdn_axi_uvm_driver_Ended
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

endclass : cdn_demo_sys_bus_memory_adapter

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
