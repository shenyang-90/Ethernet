//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// test_description: cdn_demo_customer_dut_test
// The purpose of this test is identical to the cdn_demo_c_customer_dut_test
// where basic register read and write accesses are performed to ensure the
// customer dut layer is working correctly. The default register values of a
// register bank are checked at a read and a write/read transaction takes
// place to ensure data is written and read back successfully.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Class: cdn_demo_customer_dut_test
// See test description for details of this class.
//----------------------------------------------------------------------------

class cdn_demo_customer_dut_test extends cdn_demo_base_test;

   //------------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //------------------------------------------------------------------------

   // The component utils macro provides base virtual methods like 
   // get_type_name and create.
   `uvm_component_utils(cdn_demo_customer_dut_test)

   //------------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS
   //------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // Function: new
   // Creates and initializes a new object for this class.
   //------------------------------------------------------------------------
   function new (string name = "cdn_demo_customer_dut_test", uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   //------------------------------------------------------------------------
   // Function: run_phase
   //
   // The run_phase of this test is straightforward and contains the following:
   // 1. Read Accesses : read the SRAM parameters from the register bank and
   // ensure they are correct.
   // 2. Write Access : write to a writeable register and read back to ensure
   // writes are additionally working.
   //
   //------------------------------------------------------------------------

   task run_phase(uvm_phase phase);

      // Fields needed for UVM_REG accesses.
      bit[31:0]                  _data;
      uvm_status_e               _status;
      
      // Get reset config so that we can wait for the rising edge of reset
      if(!uvm_config_db#(virtual cdn_reset_if)::get(sve.demo_env.reset_env0.agents[0].driver, "", "reset_if", reset_if))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reset_if"})

      phase.raise_objection(this);
      #1ns;
      @(posedge reset_if.sig_reset);
      #1us;

      // Check the default of registers by performing a read access.
      regs1.get_reg_by_name("NUM_OF_SRAM").read(_status,_data);
      `uvm_info(get_type_name(), $psprintf("NUM_OF_SRAM : %d", _data), UVM_LOW);
      if (_data != 12) begin
         `uvm_error(get_type_name(),"NUM_OF_SRAM Incorrect. Expected 12");
      end
      regs1.get_reg_by_name("NUM_OF_DP1R1W").read(_status,_data);
      `uvm_info(get_type_name(), $psprintf("NUM_OF_DP1R1W : %d", _data), UVM_LOW);
      if (_data != 7) begin
         `uvm_error(get_type_name(),"NUM_OF_DP1R1W Incorrect. Expected 7");
      end
      regs1.get_reg_by_name("NUM_OF_DP2R2W").read(_status,_data);
      `uvm_info(get_type_name(), $psprintf("NUM_OF_DP2R2W       : %d", _data), UVM_LOW);
      if (_data != 4) begin
         `uvm_error(get_type_name(),"NUM_OF_DP2R2W Incorrect. Expected 4");
      end
      regs1.get_reg_by_name("NUM_OF_SRAM_BE").read(_status,_data);
      `uvm_info(get_type_name(), $psprintf("NUM_OF_SRAM_BE      : %d", _data), UVM_LOW);
      if (_data != 1) begin
         `uvm_error(get_type_name(),"NUM_OF_SRAM_BE Incorrect. Expected 1");
      end

      // Do a write/verify access
      // Do the write
      regs1.get_reg_by_name("MASTER_CTRL_REG").get_field_by_name("RAM_ALGORITHM_0").set(1);
      regs1.get_reg_by_name("MASTER_CTRL_REG").get_field_by_name("RAM_ALGORITHM_1").set(1);
      regs1.get_reg_by_name("MASTER_CTRL_REG").get_field_by_name("RAM_ALGORITHM_DATA").set(1);
      regs1.get_reg_by_name("MASTER_CTRL_REG").update(_status);

      // Do the read/verify
      regs1.get_reg_by_name("MASTER_CTRL_REG").read(_status,_data);
      `uvm_info(get_type_name(), $psprintf("MASTER_CTRL_REG      : 0x%0h", _data), UVM_LOW);
      if ( regs1.get_reg_by_name("MASTER_CTRL_REG").get_field_by_name("RAM_ALGORITHM_0").get() != 1 ||
           regs1.get_reg_by_name("MASTER_CTRL_REG").get_field_by_name("RAM_ALGORITHM_1").get() != 1 ||
           regs1.get_reg_by_name("MASTER_CTRL_REG").get_field_by_name("RAM_ALGORITHM_DATA").get() != 1) begin
         `uvm_error(get_type_name(),"MASTER_CTRL_REG read back incorrect");
      end
      else begin
         `uvm_info(get_type_name(), "MASTER_CTRL_REG write/verify correct", UVM_LOW);
      end

      phase.drop_objection(this);

   endtask : run_phase

endclass : cdn_demo_customer_dut_test

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------


