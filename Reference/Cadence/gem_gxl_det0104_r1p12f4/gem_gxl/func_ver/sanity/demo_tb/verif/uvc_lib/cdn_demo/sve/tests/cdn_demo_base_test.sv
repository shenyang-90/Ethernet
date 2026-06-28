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
// test_description: cdn_demo_base_test
// This test should not be run and is expected to be extended with protocol specific
// testing, assuming the test is not a C test. If the test is a C test then 
// this test has the hooks to call the "main" C test function.
//
// The purpose of this base test is to provide the base functionality for the
// demoTB. Protocol specific tests should extend from this base test to create
// protocol specific tests. This base tests performs the following functions:
// - Creates a default config_object with randomized clock frequencies. Note.
//   If this base randomization is not sufficient then a base test can
//   randomize the config_object and can re-add to the config_db. This
//   "re-add" will overwrite the default config_object provided by this class.
//   The derived test should call super.build_phase and after this the
//   config_object can be changed and added to the config_db.
// - Provides the "C" hooks to call the "main" C function when a C test is being
//   run rather than an SV test. Full details of this functionality can
//   be found in the run_phase task.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Class: cdn_demo_base_test
// See test description for details of this class.
//----------------------------------------------------------------------------

class cdn_demo_base_test extends uvm_test;

   //------------------------------------------------------------------------
   // UVM AUTOMATION MACROS.
   //------------------------------------------------------------------------

   // The component utils macro provides base virtual methods like 
   // get_type_name and create.
   `uvm_component_utils(cdn_demo_base_test)

   //------------------------------------------------------------------------
   // INTERFACE
   //------------------------------------------------------------------------

   // The - the c DPI virtual interface
   protected virtual cdn_demo_module_top_c_dpi c_dpi;

   // The reset interface
   protected virtual cdn_reset_if reset_if;

   //------------------------------------------------------------------------
   // Internal Classes
   //------------------------------------------------------------------------

   // uvm_reg register bank
   cdn_ram_stub_addr_map_type regs1;

   //------------------------------------------------------------------------
   // COMPONENTS
   //------------------------------------------------------------------------

   // Add an instance of the cdn_demo_module_env
   cdn_demo_module_env sve;

   // Add a printer for logging.
   uvm_table_printer printer;

   //------------------------------------------------------------------------
   // CONFIGURATION OBJECTS
   //------------------------------------------------------------------------

   cdn_demo_config_object config_object;

   //------------------------------------------------------------------------
   // EXTEND OR OVERRIDE BASE METHODS
   //------------------------------------------------------------------------

   //------------------------------------------------------------------------
   // Function: new
   // Creates and initializes a new object for this class.
   //------------------------------------------------------------------------
   function new (string name = "cdn_demo_base_test", uvm_component parent=null);
      super.new(name, parent);
   endfunction : new

   //------------------------------------------------------------------------
   // Function: build_phase
   // Perform the following 
   // - Randomize and set the config object
   // - Enable transaction recording
   // - Set the default sequence to the normal_operation_seqA
   // - Create the sve
   //------------------------------------------------------------------------
   virtual function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      // Create the config for this test and pass it to the env
      config_object = cdn_demo_config_object::type_id::create("config_object", this);
      assert(config_object.randomize());
      uvm_config_db#(cdn_demo_config_object)::set(this, "sve.demo_env", "config_object", config_object);

      // Enable transaction recording for everything.
      uvm_config_db #(int)::set(this,"*","recording_detail", UVM_FULL);

      // Ensure that only the normal operation sequence from the UVCs 
      // sequence lib is used as the default.
      uvm_config_db#(uvm_object_wrapper)::set(this,"*.virtual_sequencer.run_phase","default_sequence",normal_operation_seq::type_id::get());

      // Create the sve
      sve = cdn_demo_module_env::type_id::create("sve", this);

      // Create a specific depth printer for printing the created topology
      printer = new();
      printer.knobs.depth = 2;

      `ifdef CDN_DEMO_RAM_INTEGRATION_TEST
      // We create the regs class here and then pass it down to the env, for the env
      // to hook it up to the adapter, apb call backks, etc
      regs1 = cdn_ram_stub_addr_map_type::type_id::create("regs1", this);
      regs1.build();
      uvm_config_db#(uvm_reg_block)::set(this,"sve.demo_env","regs1",regs1);
      `endif


   endfunction : build_phase

   //------------------------------------------------------------------------
   // Function: connect_phase
   // Creates and initializes a new object for this class.
   //------------------------------------------------------------------------
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      if (!uvm_config_db#(virtual cdn_demo_module_top_c_dpi)::get(null, "", "c_dpi", c_dpi))
         `uvm_fatal(get_type_name(), "c_dpi object not set")

      `ifdef CDN_DEMO_RAM_INTEGRATION_TEST
      // Set the default map for the ram integration block
      sve.demo_env.regs1.default_map.set_base_addr(32'h1000_0000);
      `endif

      // When the customer_demo_env is instantiated regs1 can be manipulated
      // if the customer is adding an additional reg layer. If that is the
      // case then we want to update the test regs1 reference with the env
      // regs1 reference.
      $cast(regs1, sve.demo_env.regs1);

   endfunction : connect_phase

   //---------------------------------------------------------------------------
   // Function: check_phase
   // Dummy function, currently providing no implementation and simply
   // extending the base check_phase.
   //---------------------------------------------------------------------------
   virtual function void check_phase(uvm_phase phase);
      super.check_phase(phase);
   endfunction : check_phase

   //---------------------------------------------------------------------------
   // Function: end_of_elaboration_phase
   // Print the topology at the end of elaboration.
   //---------------------------------------------------------------------------
   virtual function void end_of_elaboration_phase(uvm_phase phase);
      uvm_top.print_topology(); 
   endfunction : end_of_elaboration_phase

   //---------------------------------------------------------------------------
   // Function: start_of_simulation_phase
   // Set the drain time at 200ns.
   //---------------------------------------------------------------------------
   virtual function void start_of_simulation_phase(uvm_phase phase);
      uvm_test_done.set_drain_time(this, 200ns);
   endfunction : start_of_simulation_phase

   //------------------------------------------------------------------------
   // Function: run_phase
   //
   // This run phase is currently only used when the CDN_DEMO_C define is set.
   // The run_phase does very little and simply calls the "main" function of the
   // c test. At each simulation run only one C test is compiled and the "main"
   // call is therefore only to the compiled C test only. See the actual C tests
   // for full details of the testing for the particular test.
   //
   // Contrary to the above paragraph, if we are doing a self test for the
   // demoTB template only then map the second APB slave (for RAM integration)
   // at a specific APB address.
   //
   //------------------------------------------------------------------------

   `ifdef CDN_DEMO_C
   task run_phase(uvm_phase phase);

      int argv[3:0];  // argument to the 'main' C function

      super.run_phase(phase);

      // Get reset config so that we can wait for the rising edge of reset
      if(!uvm_config_db#(virtual cdn_reset_if)::get(sve.demo_env.reset_env0.agents[0].driver, "", "reset_if", reset_if))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".reset_if"})

      phase.raise_objection(this);
      #1ns;
      @(posedge reset_if.sig_reset);
      #1us;

      // Call the main c tests with the corresponding arguments.
      c_dpi.c_api_main(0, argv);
      phase.drop_objection(this);

   endtask : run_phase
   `endif

endclass : cdn_demo_base_test

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------

