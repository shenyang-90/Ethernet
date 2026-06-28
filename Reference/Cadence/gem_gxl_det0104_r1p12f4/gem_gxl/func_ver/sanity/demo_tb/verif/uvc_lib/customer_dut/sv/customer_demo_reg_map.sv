//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CUSTOMER_DEMO_REG_MAP_SV
`define CUSTOMER_DEMO_REG_MAP_SV

class customer_demo_reg_map extends uvm_reg_block;

  rand USBSSP_addr_map_type USBSSP_addr_map;
  rand cdn_ram_stub_addr_map_type cdn_ram_stub_addr_map;

  virtual function void build();
    // Now define address mappings
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);
    USBSSP_addr_map = USBSSP_addr_map_type::type_id::create("USBSSP_addr_map", , get_full_name());
    USBSSP_addr_map.configure(this, "");
    USBSSP_addr_map.build();
    USBSSP_addr_map.lock_model();
    default_map.add_submap(USBSSP_addr_map.default_map, `UVM_REG_ADDR_WIDTH'h0);
    cdn_ram_stub_addr_map = cdn_ram_stub_addr_map_type::type_id::create("cdn_ram_stub_addr_map", , get_full_name());
    cdn_ram_stub_addr_map.configure(this, "");
    cdn_ram_stub_addr_map.build();
    cdn_ram_stub_addr_map.lock_model();
    default_map.add_submap(cdn_ram_stub_addr_map.default_map, `UVM_REG_ADDR_WIDTH'h1000_0000);
    this.lock_model();
    default_map.set_check_on_read();
  endfunction
  `uvm_object_utils(customer_demo_reg_map)
  function new(input string name="customer_demo_reg_map");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
endclass

`endif
