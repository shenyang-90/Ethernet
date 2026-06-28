//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_virtual_seq_lib.sv
 *
 * This files defines the cdn_gem_demo virtual sequence library, in which simple
 * and reusable sequences are implemented.
 * Those are nested into virtual sequences that correspond to tests in the
 * cdn_gem_demo_tests_virtual_seq_lib.sv library.
 */

`ifndef CDN_GEM_DEMO_VIRTUAL_SEQ_LIB_SV
  `define CDN_GEM_DEMO_VIRTUAL_SEQ_LIB_SV

//----------------------------------------------------------------------------
// BASE VIRTUAL SEQUENCE
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_base_virtual_seq
 *
 * This is the cdn_gem_demo UVC base virtual sequence class.
 * When extending it, please be sure to call the super.body() in your body
 * function only to exploit a reset of the DUT.
 *
 * Class: cdn_gem_demo_base_virtual_seq
 *
 * This is the cdn_gem_demo UVC base virtual sequence class.
 * When extending it, please be sure to call the super.body() in your body
 * function only to exploit a reset of the DUT.
 */
class cdn_gem_demo_base_virtual_seq extends normal_operation_seq;

  //---------------------------------
  // MEMBER VARIABLES.
  //---------------------------------

  /*
   * Variable p_sequencer
   *
   * A pointer to the default virtual sequencer.
   * It overrides that in the base class.
   */
  `uvm_declare_p_sequencer(cdn_gem_demo_virtual_sequencer)

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_base_virtual_seq)

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_base_virtual_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_base_virtual_seq");
    super.new(name);
  endfunction

  /*
   * Method: pre_body
   *
   * Raise an objection to prevent premature simulation end.
   */
  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this,$psprintf("%s: vir: raise objection", get_sequence_path()));
    end
  endtask : pre_body

  /*
   * Method: post_body
   *
   * Drop the objection raised earlier.
   */
  virtual task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this,$psprintf("%s: vir: drop objection", get_sequence_path()));
    end
  endtask : post_body

  //---------------------------------
  // UTILITY FUNCTIONS
  //---------------------------------

  /*
   * Method: wait_for_reset_to_finish
   *
   * This task waits for the DUT Reset to finish.
   */
  virtual task wait_for_reset_to_finish();
    `uvm_info(get_type_name(),"Waiting for DUT Reset to finish", UVM_LOW)
    #1ns;
    fork
      begin
        #(500us);
        `uvm_error(get_type_name(), "Timeout waiting for DUT Reset to finish!")
      end
      begin
        @(posedge p_sequencer.p_env.reset_env0.agents[0].driver.reset_if.sig_reset);
      end
    join_any
    disable fork;
    #1us;
    `uvm_info(get_type_name(),"Reset finished", UVM_LOW)
  endtask : wait_for_reset_to_finish

endclass : cdn_gem_demo_base_virtual_seq

//----------------------------------------------------------------------------
// PROGRAMMING INTERFACE (DUT REGISTERS)
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_prog_init_seq
 *
 * This sequence initializes basic DUT registers.
 *
 * Class: cdn_gem_demo_prog_init_seq
 *
 * This sequence initializes basic DUT registers.
 */
class cdn_gem_demo_prog_init_seq extends cdn_gem_demo_base_virtual_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: status
   *
   * This is the status of the modeled registers.
   */
  uvm_status_e status;

  /*
   * Variable: cfg_decode
   *
   * Store the value of designcfg_debug registers.
   */
  bit [31:0] cfg_decode[12];

  /*
   * Variable: is_q_cfgrd
   *
   * Store information about whether a priority queue is configured or not in
   * the deigns.
   */
  bit is_q_cfgrd[16];

  /*
   * Variable: q_num
   *
   * Counts the number of queues configured in the design.
   */
  int q_num = 1;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_prog_init_seq)

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_prog_init_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_prog_init_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence.
   *
   * It reads the Design Configuration Registers to decode the configuration.
   *
   * It initializes the DMA Configuration Register:-
   * - Attempt to use AXI burst length up to 8.
   * - Rx packet buffer uses full configured addressable space (8 kb).
   * - Tx packet buffer uses full configured addressable space (4 kb).
   * - Set the databuffer size to be 256 bytes.
   *
   * It initializes the Network Configuration Register:-
   * - Set 100 Mpbs operation.
   * - Set full duplex mode.
   * - Accept all valid frames.
   * - Configure the GEM for 1000 Mbps operation.
   * - Divide the pclk period by 32 (pclk up to 40 MHz).
   * - Set the AXI bus width depending on the decoded configuration.
   */
  virtual task body();
    string msg;
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //--------------------------------
    // Config Decode
    //--------------------------------

    // Read the designcfg_debug regs
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug1.read(status, cfg_decode[0]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug2.read(status, cfg_decode[1]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug3.read(status, cfg_decode[2]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug4.read(status, cfg_decode[3]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug5.read(status, cfg_decode[4]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug6.read(status, cfg_decode[5]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug7.read(status, cfg_decode[6]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug8.read(status, cfg_decode[7]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug9.read(status, cfg_decode[8]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug10.read(status, cfg_decode[9]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug11.read(status, cfg_decode[10]);
    p_sequencer.p_emac_regs0.__ALL__.designcfg_debug12.read(status, cfg_decode[11]);

    msg =
      {
        $psprintf("/----------------------------------------------------\n"),
        $psprintf("| designcfg_debug* Content\n"),
        $psprintf("|----------------------------------------------------\n"),
        $psprintf("| desingcfg_debug1  = 0x%h\n", cfg_decode[0]),
        $psprintf("| desingcfg_debug2  = 0x%h\n", cfg_decode[1]),
        $psprintf("| desingcfg_debug3  = 0x%h\n", cfg_decode[2]),
        $psprintf("| desingcfg_debug4  = 0x%h\n", cfg_decode[3]),
        $psprintf("| desingcfg_debug5  = 0x%h\n", cfg_decode[4]),
        $psprintf("| desingcfg_debug6  = 0x%h\n", cfg_decode[5]),
        $psprintf("| desingcfg_debug7  = 0x%h\n", cfg_decode[6]),
        $psprintf("| desingcfg_debug8  = 0x%h\n", cfg_decode[7]),
        $psprintf("| desingcfg_debug9  = 0x%h\n", cfg_decode[8]),
        $psprintf("| desingcfg_debug10 = 0x%h\n", cfg_decode[9]),
        $psprintf("| desingcfg_debug11 = 0x%h\n", cfg_decode[10]),
        $psprintf("| desingcfg_debug12 = 0x%h\n", cfg_decode[11]),
        $psprintf("\\----------------------------------------------------")
      };

    `uvm_info(get_type_name(), $psprintf("\n%s", msg), UVM_DEBUG)

    // Decode the number of queues configured in the design. Queue 0 is always
    // enabled by default.
    is_q_cfgrd[0] = 1;
    for (int i=1; i<16; i++) begin
      is_q_cfgrd[i] = cfg_decode[5][i];
      if (is_q_cfgrd[i]) begin
        q_num++;
      end
    end

    msg =
      { $psprintf("/----------------------------------------------------\n"),
        $psprintf("| Queue Decode\n"),
        $psprintf("|----------------------------------------------------\n"),
        $psprintf("| q_num = %d\n", q_num),
        $psprintf("| is_q_cfgrd[0]  = 0x%h\n", is_q_cfgrd[0]),
        $psprintf("| is_q_cfgrd[1]  = 0x%h\n", is_q_cfgrd[1]),
        $psprintf("| is_q_cfgrd[2]  = 0x%h\n", is_q_cfgrd[2]),
        $psprintf("| is_q_cfgrd[3]  = 0x%h\n", is_q_cfgrd[3]),
        $psprintf("| is_q_cfgrd[4]  = 0x%h\n", is_q_cfgrd[4]),
        $psprintf("| is_q_cfgrd[5]  = 0x%h\n", is_q_cfgrd[5]),
        $psprintf("| is_q_cfgrd[6]  = 0x%h\n", is_q_cfgrd[6]),
        $psprintf("| is_q_cfgrd[7]  = 0x%h\n", is_q_cfgrd[7]),
        $psprintf("| is_q_cfgrd[8]  = 0x%h\n", is_q_cfgrd[8]),
        $psprintf("| is_q_cfgrd[9]  = 0x%h\n", is_q_cfgrd[9]),
        $psprintf("| is_q_cfgrd[10] = 0x%h\n", is_q_cfgrd[10]),
        $psprintf("| is_q_cfgrd[11] = 0x%h\n", is_q_cfgrd[11]),
        $psprintf("| is_q_cfgrd[12] = 0x%h\n", is_q_cfgrd[12]),
        $psprintf("| is_q_cfgrd[13] = 0x%h\n", is_q_cfgrd[13]),
        $psprintf("| is_q_cfgrd[14] = 0x%h\n", is_q_cfgrd[14]),
        $psprintf("| is_q_cfgrd[15] = 0x%h\n", is_q_cfgrd[15]),
        $psprintf("\\----------------------------------------------------")
      };

    `uvm_info(get_type_name(), $psprintf("\n%s", msg), UVM_DEBUG)

    //--------------------------------
    // Network Control Register
    //--------------------------------

    // Initialize to zero, but this is already the case after reset

    //--------------------------------
    // DMA Configuration Register
    //--------------------------------

    `uvm_info(get_type_name(), "Configuring dma_config register", UVM_DEBUG)
    // Attempt to use bursts up to 8
    p_sequencer.p_emac_regs0.__ALL__.dma_config.amba_burst_length.set(5'b0100);
    // Use full configured addressable space (8 kb)
    p_sequencer.p_emac_regs0.__ALL__.dma_config.rx_pbuf_size.set(2'b11);
    // Use full configured addressable space (4 kb)
    p_sequencer.p_emac_regs0.__ALL__.dma_config.tx_pbuf_size.set(1'b1);
    // Set the databuffer size to be 256 bytes
    p_sequencer.p_emac_regs0.__ALL__.dma_config.rx_buf_size.set(8'b0000_0100);
    // Set the DMA addr width
    //p_sequencer.p_emac_regs0.__ALL__.dma_config.dma_addr_bus_width_1.set(cfg_decode[5][23]);
    // Update dma_config status
    p_sequencer.p_emac_regs0.__ALL__.dma_config.update(status);

    //--------------------------------
    // Network Configuration Register
    //--------------------------------

    `uvm_info(get_type_name(), "Configuring network_config register", UVM_DEBUG)
    // Set 100 Mbps operation
    p_sequencer.p_emac_regs0.__ALL__.network_config.speed.set(1'b1);
    // The GEM operates in full duplex mode
    p_sequencer.p_emac_regs0.__ALL__.network_config.full_duplex.set(1'b1);
    // All valid frames will be accepted
    p_sequencer.p_emac_regs0.__ALL__.network_config.copy_all_frames.set(1'b1);
    // Configures the GEM for 1000 Mbps
    p_sequencer.p_emac_regs0.__ALL__.network_config.gigabit_mode_enable.set(1'b1);
    // Divide the pclk period by 32 (pclk up to 40 MHz)
    p_sequencer.p_emac_regs0.__ALL__.network_config.mdc_clock_division.set(3'b010);
    // Set the AXI bus width
    p_sequencer.p_emac_regs0.__ALL__.network_config.data_bus_width.set(cfg_decode[0][27:26]);
    // Update network_config status
    p_sequencer.p_emac_regs0.__ALL__.network_config.update(status);

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_prog_init_seq

/*
 * sequence_description: cdn_gem_demo_prog_q_seq
 *
 * This sequence initializes queue pointers registers.
 *
 * Class: cdn_gem_demo_prog_q_seq
 *
 * This sequence initializes queue pointers registers.
 */
class cdn_gem_demo_prog_q_seq extends cdn_gem_demo_base_virtual_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: status
   *
   * This is the status of the modeled registers.
   */
  uvm_status_e status;

  /*
   * Variable: mode_tx
   *
   * If 1, GEM operates in Tx.
   * If 0, GEM operates in Rx.
   */
  bit mode_tx = 1;

  /*
   * Variable: dtable_addr
   *
   * In this variable is stored the descriptor tables base address for each
   * queue.
   */
  bit [31:0] dtable_addr[16] = '{16{32'h0000_0000}};

  /*
   * Variable: is_q_enabled
   *
   * This variables stores information about whether a queue is enabled or not
   * to be used.
   * If is_q_enabled[i] == 1, then the relative queue pointer stores the proper
   * descriptor table base address, otherwise the queue is disabled.
   *
   * NOTE: the above is only relevant to queues 1:15, since queue 0 must always
   * be enabled. By default, all other queues are disabled.
   */
  bit is_q_enabled[15] = '{15{1'b0}};

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_prog_q_seq)
    `uvm_field_int(mode_tx, UVM_ALL_ON)
    `uvm_field_sarray_int(dtable_addr, UVM_ALL_ON)
    `uvm_field_sarray_int(is_q_enabled, UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_prog_q_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_prog_q_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence.
   *
   * For each queue configured in the design, writes the descriptor table base
   * address (queue enabled) or 0x1 (queue disabled) to the relative Tx/Rx queue
   * pointer.
   */
  virtual task body();
    string msg;
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    msg =
      {
        $psprintf("/----------------------------------------------------\n"),
        $psprintf("| *_q*_ptr Programming\n"),
        $psprintf("|----------------------------------------------------\n")
      };

    if(mode_tx) begin
      p_sequencer.p_emac_regs0.__ALL__.transmit_q_ptr.dma_tx_q_ptr.set(dtable_addr[0][31:2]);
      p_sequencer.p_emac_regs0.__ALL__.transmit_q_ptr.reserved_1.set(dtable_addr[0][1]);
      p_sequencer.p_emac_regs0.__ALL__.transmit_q_ptr.dma_tx_dis_q.set(dtable_addr[0][0]);
      p_sequencer.p_emac_regs0.__ALL__.transmit_q_ptr.update(status);
      msg = {msg, $psprintf("| transmit_q_ptr   = 0x%h\n", dtable_addr[0])};

      `ifdef dma_priority_queue1
        if(is_q_enabled[0]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q1_ptr.dma_tx_q_ptr.set(dtable_addr[1][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q1_ptr.reserved_1.set(dtable_addr[1][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q1_ptr.dma_tx_dis_q.set(dtable_addr[1][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q1_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q1_ptr  = 0x%h\n", dtable_addr[1])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q1_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q1_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q1_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue2
        if(is_q_enabled[1]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q2_ptr.dma_tx_q_ptr.set(dtable_addr[2][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q2_ptr.reserved_1.set(dtable_addr[2][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q2_ptr.dma_tx_dis_q.set(dtable_addr[2][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q2_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q2_ptr  = 0x%h\n", dtable_addr[2])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q2_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q2_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q2_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue3
        if(is_q_enabled[2]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q3_ptr.dma_tx_q_ptr.set(dtable_addr[3][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q3_ptr.reserved_1.set(dtable_addr[3][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q3_ptr.dma_tx_dis_q.set(dtable_addr[3][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q3_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q3_ptr  = 0x%h\n", dtable_addr[3])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q3_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q3_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q3_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue4
        if(is_q_enabled[3]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q4_ptr.dma_tx_q_ptr.set(dtable_addr[4][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q4_ptr.reserved_1.set(dtable_addr[4][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q4_ptr.dma_tx_dis_q.set(dtable_addr[4][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q4_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q4_ptr  = 0x%h\n", dtable_addr[4])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q4_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q4_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q4_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue5
        if(is_q_enabled[4]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q5_ptr.dma_tx_q_ptr.set(dtable_addr[5][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q5_ptr.reserved_1.set(dtable_addr[5][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q5_ptr.dma_tx_dis_q.set(dtable_addr[5][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q5_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q5_ptr  = 0x%h\n", dtable_addr[5])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q5_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q5_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q5_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue6
        if(is_q_enabled[5]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q6_ptr.dma_tx_q_ptr.set(dtable_addr[6][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q6_ptr.reserved_1.set(dtable_addr[6][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q6_ptr.dma_tx_dis_q.set(dtable_addr[6][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q6_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q6_ptr  = 0x%h\n", dtable_addr[6])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q6_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q6_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q6_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue7
        if(is_q_enabled[6]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q7_ptr.dma_tx_q_ptr.set(dtable_addr[7][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q7_ptr.reserved_1.set(dtable_addr[7][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q7_ptr.dma_tx_dis_q.set(dtable_addr[7][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q7_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q7_ptr  = 0x%h\n", dtable_addr[7])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q7_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q7_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q7_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue8
        if(is_q_enabled[7]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q8_ptr.dma_tx_q_ptr.set(dtable_addr[8][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q8_ptr.reserved_1.set(dtable_addr[8][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q8_ptr.dma_tx_dis_q.set(dtable_addr[8][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q8_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q8_ptr  = 0x%h\n", dtable_addr[8])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q8_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q8_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q8_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue9
        if(is_q_enabled[8]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q9_ptr.dma_tx_q_ptr.set(dtable_addr[9][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q9_ptr.reserved_1.set(dtable_addr[9][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q9_ptr.dma_tx_dis_q.set(dtable_addr[9][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q9_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q9_ptr  = 0x%h\n", dtable_addr[9])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q9_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q9_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q9_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue10
        if(is_q_enabled[9]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q10_ptr.dma_tx_q_ptr.set(dtable_addr[10][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q10_ptr.reserved_1.set(dtable_addr[10][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q10_ptr.dma_tx_dis_q.set(dtable_addr[10][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q10_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q10_ptr = 0x%h\n", dtable_addr[10])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q10_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q10_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q10_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue11
        if(is_q_enabled[10]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q11_ptr.dma_tx_q_ptr.set(dtable_addr[11][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q11_ptr.reserved_1.set(dtable_addr[11][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q11_ptr.dma_tx_dis_q.set(dtable_addr[11][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q11_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q11_ptr = 0x%h\n", dtable_addr[11])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q11_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q11_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q11_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue12
        if(is_q_enabled[11]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q12_ptr.dma_tx_q_ptr.set(dtable_addr[12][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q12_ptr.reserved_1.set(dtable_addr[12][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q12_ptr.dma_tx_dis_q.set(dtable_addr[12][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q12_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q12_ptr = 0x%h\n", dtable_addr[12])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q12_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q12_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q12_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue13
        if(is_q_enabled[12]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q13_ptr.dma_tx_q_ptr.set(dtable_addr[13][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q13_ptr.reserved_1.set(dtable_addr[13][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q13_ptr.dma_tx_dis_q.set(dtable_addr[13][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q13_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q13_ptr = 0x%h\n", dtable_addr[13])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q13_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q13_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q13_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue14
        if(is_q_enabled[13]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q14_ptr.dma_tx_q_ptr.set(dtable_addr[14][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q14_ptr.reserved_1.set(dtable_addr[14][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q14_ptr.dma_tx_dis_q.set(dtable_addr[14][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q14_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q14_ptr = 0x%h\n", dtable_addr[14])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q14_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q14_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q14_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue15
        if(is_q_enabled[14]) begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q15_ptr.dma_tx_q_ptr.set(dtable_addr[15][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q15_ptr.reserved_1.set(dtable_addr[15][1]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q15_ptr.dma_tx_dis_q.set(dtable_addr[15][0]);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q15_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q15_ptr = 0x%h\n", dtable_addr[15])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.transmit_q15_ptr.dma_tx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.transmit_q15_ptr.update(status);
          msg = {msg, $psprintf("| transmit_q15_ptr = 0x00000001\n")};
        end
      `endif
    end else begin
      p_sequencer.p_emac_regs0.__ALL__.receive_q_ptr.dma_rx_q_ptr.set(dtable_addr[0][31:2]);
      p_sequencer.p_emac_regs0.__ALL__.receive_q_ptr.reserved_1.set(dtable_addr[0][1]);
      p_sequencer.p_emac_regs0.__ALL__.receive_q_ptr.dma_rx_dis_q.set(dtable_addr[0][0]);
      p_sequencer.p_emac_regs0.__ALL__.receive_q_ptr.update(status);
      msg = {msg, $psprintf("| receive_q_ptr   = 0x%h\n", dtable_addr[0])};

      `ifdef dma_priority_queue1
        if(is_q_enabled[0]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q1_ptr.dma_rx_q_ptr.set(dtable_addr[1][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q1_ptr.reserved_1.set(dtable_addr[1][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q1_ptr.dma_rx_dis_q.set(dtable_addr[1][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q1_ptr.update(status);
          msg = {msg, $psprintf("| receive_q1_ptr  = 0x%h\n", dtable_addr[1])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q1_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q1_ptr.update(status);
          msg = {msg, $psprintf("| receive_q1_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue2
        if(is_q_enabled[1]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q2_ptr.dma_rx_q_ptr.set(dtable_addr[2][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q2_ptr.reserved_1.set(dtable_addr[2][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q2_ptr.dma_rx_dis_q.set(dtable_addr[2][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q2_ptr.update(status);
          msg = {msg, $psprintf("| receive_q2_ptr  = 0x%h\n", dtable_addr[2])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q2_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q2_ptr.update(status);
          msg = {msg, $psprintf("| receive_q2_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue3
        if(is_q_enabled[2]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q3_ptr.dma_rx_q_ptr.set(dtable_addr[3][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q3_ptr.reserved_1.set(dtable_addr[3][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q3_ptr.dma_rx_dis_q.set(dtable_addr[3][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q3_ptr.update(status);
          msg = {msg, $psprintf("| receive_q3_ptr  = 0x%h\n", dtable_addr[3])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q3_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q3_ptr.update(status);
          msg = {msg, $psprintf("| receive_q3_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue4
        if(is_q_enabled[3]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q4_ptr.dma_rx_q_ptr.set(dtable_addr[4][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q4_ptr.reserved_1.set(dtable_addr[4][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q4_ptr.dma_rx_dis_q.set(dtable_addr[4][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q4_ptr.update(status);
          msg = {msg, $psprintf("| receive_q4_ptr  = 0x%h\n", dtable_addr[4])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q4_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q4_ptr.update(status);
          msg = {msg, $psprintf("| receive_q4_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue5
        if(is_q_enabled[4]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q5_ptr.dma_rx_q_ptr.set(dtable_addr[5][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q5_ptr.reserved_1.set(dtable_addr[5][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q5_ptr.dma_rx_dis_q.set(dtable_addr[5][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q5_ptr.update(status);
          msg = {msg, $psprintf("| receive_q5_ptr  = 0x%h\n", dtable_addr[5])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q5_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q5_ptr.update(status);
          msg = {msg, $psprintf("| receive_q5_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue6
        if(is_q_enabled[5]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q6_ptr.dma_rx_q_ptr.set(dtable_addr[6][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q6_ptr.reserved_1.set(dtable_addr[6][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q6_ptr.dma_rx_dis_q.set(dtable_addr[6][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q6_ptr.update(status);
          msg = {msg, $psprintf("| receive_q6_ptr  = 0x%h\n", dtable_addr[6])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q6_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q6_ptr.update(status);
          msg = {msg, $psprintf("| receive_q6_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue7
        if(is_q_enabled[6]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q7_ptr.dma_rx_q_ptr.set(dtable_addr[7][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q7_ptr.reserved_1.set(dtable_addr[7][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q7_ptr.dma_rx_dis_q.set(dtable_addr[7][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q7_ptr.update(status);
          msg = {msg, $psprintf("| receive_q7_ptr  = 0x%h\n", dtable_addr[7])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q7_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q7_ptr.update(status);
          msg = {msg, $psprintf("| receive_q7_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue8
        if(is_q_enabled[7]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q8_ptr.dma_rx_q_ptr.set(dtable_addr[8][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q8_ptr.reserved_1.set(dtable_addr[8][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q8_ptr.dma_rx_dis_q.set(dtable_addr[8][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q8_ptr.update(status);
          msg = {msg, $psprintf("| receive_q8_ptr  = 0x%h\n", dtable_addr[8])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q8_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q8_ptr.update(status);
          msg = {msg, $psprintf("| receive_q8_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue9
        if(is_q_enabled[8]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q9_ptr.dma_rx_q_ptr.set(dtable_addr[9][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q9_ptr.reserved_1.set(dtable_addr[9][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q9_ptr.dma_rx_dis_q.set(dtable_addr[9][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q9_ptr.update(status);
          msg = {msg, $psprintf("| receive_q9_ptr  = 0x%h\n", dtable_addr[9])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q9_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q9_ptr.update(status);
          msg = {msg, $psprintf("| receive_q9_ptr  = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue10
        if(is_q_enabled[9]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q10_ptr.dma_rx_q_ptr.set(dtable_addr[10][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q10_ptr.reserved_1.set(dtable_addr[10][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q10_ptr.dma_rx_dis_q.set(dtable_addr[10][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q10_ptr.update(status);
          msg = {msg, $psprintf("| receive_q10_ptr = 0x%h\n", dtable_addr[10])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q10_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q10_ptr.update(status);
          msg = {msg, $psprintf("| receive_q10_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue11
        if(is_q_enabled[10]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q11_ptr.dma_rx_q_ptr.set(dtable_addr[11][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q11_ptr.reserved_1.set(dtable_addr[11][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q11_ptr.dma_rx_dis_q.set(dtable_addr[11][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q11_ptr.update(status);
          msg = {msg, $psprintf("| receive_q11_ptr = 0x%h\n", dtable_addr[11])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q11_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q11_ptr.update(status);
          msg = {msg, $psprintf("| receive_q11_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue12
        if(is_q_enabled[11]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q12_ptr.dma_rx_q_ptr.set(dtable_addr[12][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q12_ptr.reserved_1.set(dtable_addr[12][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q12_ptr.dma_rx_dis_q.set(dtable_addr[12][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q12_ptr.update(status);
          msg = {msg, $psprintf("| receive_q12_ptr = 0x%h\n", dtable_addr[12])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q12_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q12_ptr.update(status);
          msg = {msg, $psprintf("| receive_q12_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue13
        if(is_q_enabled[12]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q13_ptr.dma_rx_q_ptr.set(dtable_addr[13][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q13_ptr.reserved_1.set(dtable_addr[13][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q13_ptr.dma_rx_dis_q.set(dtable_addr[13][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q13_ptr.update(status);
          msg = {msg, $psprintf("| receive_q13_ptr = 0x%h\n", dtable_addr[13])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q13_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q13_ptr.update(status);
          msg = {msg, $psprintf("| receive_q13_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue14
        if(is_q_enabled[13]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q14_ptr.dma_rx_q_ptr.set(dtable_addr[14][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q14_ptr.reserved_1.set(dtable_addr[14][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q14_ptr.dma_rx_dis_q.set(dtable_addr[14][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q14_ptr.update(status);
          msg = {msg, $psprintf("| receive_q14_ptr = 0x%h\n", dtable_addr[14])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q14_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q14_ptr.update(status);
          msg = {msg, $psprintf("| receive_q14_ptr = 0x00000001\n")};
        end
      `endif

      `ifdef dma_priority_queue15
        if(is_q_enabled[14]) begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q15_ptr.dma_rx_q_ptr.set(dtable_addr[15][31:2]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q15_ptr.reserved_1.set(dtable_addr[15][1]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q15_ptr.dma_rx_dis_q.set(dtable_addr[15][0]);
          p_sequencer.p_emac_regs0.__ALL__.receive_q15_ptr.update(status);
          msg = {msg, $psprintf("| receive_q15_ptr = 0x%h\n", dtable_addr[15])};
        end else begin
          p_sequencer.p_emac_regs0.__ALL__.receive_q15_ptr.dma_rx_dis_q.set(1'b1);
          p_sequencer.p_emac_regs0.__ALL__.receive_q15_ptr.update(status);
          msg = {msg, $psprintf("| receive_q15_ptr = 0x00000001\n")};
        end
      `endif
    end
    msg = {msg, $psprintf("\\----------------------------------------------------")};
    `uvm_info(get_type_name(), $psprintf("\n%s",msg), UVM_DEBUG)
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_prog_q_seq

/*
 * sequence_description: cdn_gem_demo_prog_dpram_dbg_tx_seq
 *
 * This sequence configures the DPRAM fill level debug register to Tx
 * operations.
 *
 * Class: cdn_gem_demo_prog_dpram_dbg_tx_seq
 *
 * This sequence configures the DPRAM fill level debug register to Tx
 * operations.
 */
class cdn_gem_demo_prog_dpram_dbg_tx_seq extends cdn_gem_demo_base_virtual_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: status
   *
   * This is the status of the modeled registers.
   */
  uvm_status_e status;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_prog_dpram_dbg_tx_seq)

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_prog_dpram_dbg_tx_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_prog_dpram_dbg_tx_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence.
   *
   * It configures the dpram_fill_bdg register to Tx operations.
   */
  virtual task body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //--------------------------------
    // Network Control Register
    //--------------------------------

    `uvm_info(get_type_name(), "Configuring dpram_fill_bdg_to Tx", UVM_LOW)
    // Select Tx
    p_sequencer.p_emac_regs0.__ALL__.dpram_fill_dbg.dma_tx_rx_fill_level_select.set(1'b1);
    // Update status
    p_sequencer.p_emac_regs0.__ALL__.dpram_fill_dbg.update(status);

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_prog_dpram_dbg_tx_seq

/*
 * sequence_description: cdn_gem_demo_prog_start_seq
 *
 * This sequence start Tx/Rx operations writing to the Network Control Register.
 * It is assumed that this registers is in its reset status.
 *
 * Class: cdn_gem_demo_prog_start_seq
 *
 * This sequence start Tx/Rx operations writing to the Network Control Register.
 * It is assumed that this registers is in its reset status.
 */
class cdn_gem_demo_prog_start_seq extends cdn_gem_demo_base_virtual_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: status
   *
   * This is the status of the modeled registers.
   */
  uvm_status_e status;

  /*
   * Variable: mode_tx
   *
   * If 1, GEM operates in Tx.
   * If 0, GEM operates in Rx.
   */
  bit mode_tx = 1;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_prog_start_seq)
    `uvm_field_int(mode_tx, UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_prog_start_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_prog_start_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence.
   *
   * It writes the Network Control Register:-
   * - Enable the Tx/Rx operations.
   * - Start the transmission if mode_tx = 1.
   */
  virtual task body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //--------------------------------
    // Network Control Register
    //--------------------------------

    if(mode_tx) begin
      `uvm_info(get_type_name(), "Writing to network_control to start Tx", UVM_LOW)
      // Enable the transmit
      p_sequencer.p_emac_regs0.__ALL__.network_control.enable_transmit.set(1'b1);
      // Start the transmit
      p_sequencer.p_emac_regs0.__ALL__.network_control.transmit_start.set(1'b1);
      // Update status
      p_sequencer.p_emac_regs0.__ALL__.network_control.update(status);
    end else begin
      `uvm_info(get_type_name(), "Writing to network_control to start Rx", UVM_LOW)
      // Enable the receive
      p_sequencer.p_emac_regs0.__ALL__.network_control.enable_receive.set(1'b1);
      // Update status
      p_sequencer.p_emac_regs0.__ALL__.network_control.update(status);
    end

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_prog_start_seq

/*
 * sequence_description: cdn_gem_demo_prog_check_seq
 *
 * This sequence performs a periodic check of:-
 * - Tx operation, the transmit_status register.
 * - Rx operation, the dpram_fill_debug register.
 *
 * Class: cdn_gem_demo_prog_check_seq
 *
 * This sequence performs a periodic check of:-
 * - Tx operation, the transmit_status register.
 * - Rx operation, the dpram_fill_debug register.
 */
class cdn_gem_demo_prog_check_seq extends cdn_gem_demo_base_virtual_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: status
   *
   * This is the status of the modeled registers.
   */
  uvm_status_e status;

  /*
   * Variable: mode_tx
   *
   * If 1, GEM operates in Tx.
   * If 0, GEM operates in Rx.
   */
  bit mode_tx = 1;

  /*
   * Variable: max_reads
   *
   * This periodic check sequence has a timeout
   * event based on the maximum number of reads.
   */
  int max_reads = 100;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_prog_check_seq)
    `uvm_field_int(mode_tx, UVM_ALL_ON)
    `uvm_field_int(max_reads, UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_prog_check_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_prog_check_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence, which periodically checks
   * the transmit_status (Tx) or the dpram_fill_debug (Rx) registers.
   * It has a timeout event based on the maximum number of reads.
   */
  virtual task body();
    string msg;
    bit [31:0] data_tx;
    bit [31:0] data_rx;
    int reads = 0;

    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    if(mode_tx) begin
      // Periodic check
      do begin
        p_sequencer.p_emac_regs0.__ALL__.transmit_status.read(status, data_tx);
        p_sequencer.p_emac_regs0.__ALL__.transmit_status.update(status);
        reads++;
        msg =
          {
            $psprintf("/----------------------------------------------------\n"),
            $psprintf("| Checking transmit_status regsiter: \n"),
            $psprintf("| - reads             : %0d \n", reads),
            $psprintf("| - used_bit_read     : %1b \n", data_tx[0]),
            $psprintf("| - transmit_complete : %1b \n", data_tx[5]),
            $psprintf("\\----------------------------------------------------")
          };
        `uvm_info(get_type_name(), $psprintf("\n%s", msg), UVM_DEBUG)
      end while(({data_tx[5],data_tx[0]} != 2'b11) && (reads < max_reads));

      // Check status
      if ({data_tx[5],data_tx[0]} != 2'b11) begin
        `uvm_error(get_type_name(), "CHECK transmit_status | max_reads exceeded without seeing expected value");
      end
    end else begin
      // Periodic check
      do begin
        p_sequencer.p_emac_regs0.__ALL__.dpram_fill_dbg.read(status, data_rx);
        p_sequencer.p_emac_regs0.__ALL__.dpram_fill_dbg.update(status);
        reads++;
        msg =
          {
            $psprintf("/----------------------------------------------------\n"),
            $psprintf("| Checking dpram_fill_dbg regsiter: \n"),
            $psprintf("| - reads                : %0d \n", reads),
            $psprintf("| - dma_tx_rx_fill_level : 0x%4h \n", data_rx[31:16]),
            $psprintf("\\----------------------------------------------------")
          };
        `uvm_info(get_type_name(), $psprintf("\n%s", msg), UVM_DEBUG)
      end while((data_rx[31:16] != 32'h0000_0000) && (reads < max_reads));

      // Check status
      if (data_rx[31:16] != 32'h0000_0000) begin
        `uvm_error(get_type_name(), "CHECK dpram_fill_dbg | max_reads exceeded without seeing expected value");
      end
    end

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_prog_check_seq

//----------------------------------------------------------------------------
// HOST SIDE
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_host_base_seq
 *
 * This is the UVM base sequence class for the use cases test case. It casts an
 * handle back to the memory adapter instance to access functions to read/write
 * the main memory.
 *
 * Class: cdn_gem_demo_host_base_seq
 *
 * This is the UVM base sequence class for the use cases test case.
 * It casts an handle back to the memory adapter instance to access functions to
 * read/write the main memory.
 */
class cdn_gem_demo_host_base_seq extends cdn_gem_demo_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: p_memory_adapter
   *
   * An handle to the GEM memory adapter.
   */
  cdn_demo_sys_bus_memory_adapter p_memory_adapter;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_host_base_seq)

  //---------------------------------
  // CONSTRAINTS
  //---------------------------------

  //---------------------------------
  // REQUIRED SUBSEQUENCES
  //---------------------------------

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_host_base_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_host_base_seq");
      super.new(name);
  endfunction

  /*
   * Function: pre_start
   *
   * The memory adapter handle is casted upon the
   * memory adapter in the demo_env.
   */
  task pre_start();
    int check;
    super.pre_start();
    check = $cast(p_memory_adapter,uvm_top.find("*demo_env.memory_adapter"));
    if (!check) begin
      `uvm_fatal(get_type_name(), "Casting of GEM memory adapter failed");
    end else begin
      `uvm_info(get_type_name(), "Casting of GEM memory adapter succeeded", UVM_DEBUG)
    end
  endtask : pre_start

  //---------------------------------
  // SEQUENCE BODY TCM
  //---------------------------------

  /*
   * Function: body
   *
   * Empty task.
   */
  virtual task body();
    //do nothing
  endtask

endclass : cdn_gem_demo_host_base_seq

/*
 * sequence_description: cdn_gem_demo_host_wr_dtable_seq
 *
 * This sequence writes a descriptor to the AXI VIP memory model.
 *
 * Class: cdn_gem_demo_host_wr_dtable_seq
 *
 * This sequence writes a descriptor to the AXI VIP memory model.
 */
class cdn_gem_demo_host_wr_dtable_seq extends cdn_gem_demo_host_base_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: addr
   *
   * The base address of the descriptor.
   */
  reg [31:0] addr = 32'h0000_0000;

  /*
   * Variable: w0
   *
   * The word 0 of the descriptor.
   */
  reg [31:0] w0 = 32'h0000_0000;

  /*
   * Variable: w1
   *
   * The word 1 of the descriptor.
   */
  reg [31:0] w1 = 32'h0000_0000;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_host_wr_dtable_seq)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(w0, UVM_ALL_ON)
    `uvm_field_int(w1, UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_host_wr_dtable_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_host_wr_dtable_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence.
   *
   */
  virtual task body();
    string msg;
    reg [7:0] wr_data [0:0];
    reg [7:0] rd_data [];
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    // Write Word 0
    msg =
      {
        $psprintf("/-------------------------------------------\n"),
        $psprintf("| Writing Word 0\n"),
        $psprintf("|-------------------------------------------\n")
      };
    for(int i=0; i<4; i++) begin
      wr_data[0] = w0[8*i +: 8];
      msg = {msg, $psprintf("|  byte %0d | addr = 0x%4h | data = 0x%2h\n", i, addr+i, wr_data[0])};
      p_memory_adapter.write_mem(addr+i, wr_data);
      // Read back
      p_memory_adapter.read_mem(addr+i, rd_data);
      if(wr_data[0] != rd_data[0])
        `uvm_error(get_type_name(), "While setting Descriptor Table | Word 0 | rd_data != wr_data");
    end

    // Write Word 1
    msg =
      {
        msg,
        $psprintf("|-------------------------------------------\n"),
        $psprintf("| Writing Word 1\n"),
        $psprintf("|-------------------------------------------\n")
      };
    for(int i=4; i<8; i++) begin
      wr_data[0] = w1[8*(i-4) +: 8];
      msg = {msg, $psprintf("|  byte %0d | addr = 0x%4h | data = 0x%2h\n", i, addr+i, wr_data[0])};
      p_memory_adapter.write_mem(addr+i, wr_data);
      // Read back
      p_memory_adapter.read_mem(addr+i, rd_data);
      if(wr_data[0] != rd_data[0])
        `uvm_error(get_type_name(), "While setting Descriptor Table | Word 1 | rd_data != wr_data");
    end

    // Print for debug
    msg = {msg, $psprintf("\\-------------------------------------------")};
    `uvm_info(get_type_name(), $psprintf("\n%s", msg), UVM_DEBUG)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_host_wr_dtable_seq

/*
 * sequence_description: cdn_gem_demo_host_wr_dbuff_incr_seq
 *
 * This sequence writes an incremental databuffer to the AXI VIP memory model.
 *
 * Class: cdn_gem_demo_host_wr_dbuff_incr_seq
 *
 * This sequence writes an incremental databuffer to the AXI VIP memory model.
 */
class cdn_gem_demo_host_wr_dbuff_incr_seq extends cdn_gem_demo_host_base_seq;

  //---------------------------------
  // MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: addr
   *
   * The base address of the databuffer.
   */
  bit [31:0] addr = 32'h0000_0000;

  /*
   * Variable: length
   *
   * The length of the databuffer in bytes.
   */
  int length = 46;

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_host_wr_dbuff_incr_seq)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(length, UVM_ALL_ON)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_host_wr_dbuff_incr_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_host_wr_dbuff_incr_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the sequence.
   *
   * It writes a databuffer with incremental index into
   * the AXI VIP memory.
   */
  virtual task body();
    string msg;
    reg [7:0] wr_data [0:0];
    reg [7:0] rd_data [];
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    msg =
      {
        $psprintf("/-------------------------------------------\n"),
        $psprintf("| Writing Databuffer\n"),
        $psprintf("|-------------------------------------------\n")
      };
    for(int i = 0 ; i < length ; i++) begin
      wr_data[0] = i;
      msg = {msg, $psprintf("|  byte %0d | addr = 0x%4h | data = 0x%2h\n", i, addr+i, wr_data[0])};
      p_memory_adapter.write_mem(addr+i, wr_data);
      // Read back
      p_memory_adapter.read_mem(addr+i, rd_data);
      if(wr_data[0] != rd_data[0])
        `uvm_error(get_type_name(), "While setting Databuffer | rd_data data is different from wr_data");
    end

    // Print for debug
    msg = {msg, $psprintf("\\-------------------------------------------\n")};
    `uvm_info(get_type_name(), $psprintf("\n%s", msg), UVM_DEBUG)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_host_wr_dbuff_incr_seq

//----------------------------------------------------------------------------
// LINE SIDE
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_line_base_seq
 *
 * User base sequence which includes the functionality of drain time management.
 * Drain time management logic will be executed only if DRAIN_TIME_CONTROL is
 * defined in the Tb.
 *
 * Class: cdn_gem_demo_line_base_seq
 *
 * User base sequence which includes the functionality of drain time management.
 * Drain time management logic will be executed only if DRAIN_TIME_CONTROL is
 * defined in the Tb.
 */
class cdn_gem_demo_line_base_seq extends cdn_gem_demo_base_virtual_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_base_seq)

  //----------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------

  /*
   * Variable: req
   *
   * The Ethernet transaction.
   */
  denaliEnetTransaction req;

  /*
   * Variable: transaction_credit
   *
   * The transaction credit.
   */
  int transaction_credit;

  /*
   * Variable: bypass_trans_counter
   *
   * Bypass the transaction counter method if true.
   */
  static bit bypass_trans_counter;

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_base_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_base_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: trans_counter
   *
   * The transaction counter method.
   */
  virtual task trans_counter();
    cdn_enet_vip_agent pAgent;
    $cast(pAgent,p_sequencer.enet_seqr.pAgent);
    fork
      forever begin
        p_sequencer.enet_seqr.pAgent.monitor.TxPktEndedPktCbEvent.wait_trigger();
        transaction_credit++;
      end
      forever begin
        pAgent.PartnerRxPacketEndedEvent.wait_trigger();
        transaction_credit--;
      end
    join_none
  endtask

  /*
   * Method: pre_body
   *
   * The pre_body method.
   */
  virtual task pre_body();
    //Raise objection is used to control the finish of test
    //Unless this objection is dropped test will not end.
    `ifdef UVM_POST_VERSION_1_1
    var uvm_phase starting_phase = get_starting_phase();
    `endif
    if (starting_phase != null) begin
      starting_phase.raise_objection(this);
      `ifdef DRAIN_TIME_CONTROL
      if(!bypass_trans_counter)
        trans_counter();
      `endif
    end
  endtask

  /*
   * Method: post_body
   *
   * The post_body method.
   */
  virtual task post_body();
    `ifdef UVM_POST_VERSION_1_1
    var uvm_phase starting_phase = get_starting_phase();
    `endif
    if (starting_phase != null) begin
      `ifdef DRAIN_TIME_CONTROL
      wait(transaction_credit <= 0);
      @(tb_clk_event);
      `endif
      starting_phase.drop_objection(this);
    end
  endtask

endclass : cdn_gem_demo_line_base_seq

/*
 * sequence_description: cdn_gem_demo_line_enet_layer_seq
 *
 * This sequence constrains the Ethernet layer of a single Ethernet packet.
 *
 * Class: cdn_gem_demo_line_enet_layer_seq
 *
 * This sequence constrains the Ethernet layer of a single Ethernet packet.
 */
class cdn_gem_demo_line_enet_layer_seq extends cdn_gem_demo_line_base_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_enet_layer_seq)

  //----------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_enet_layer_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_enet_layer_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the sequence.
   * In here, the ethernet packet layer is constrained.
   * The base packet is an 802.3 untagged frame.
   * The upper layer is set to be IPoE (Internet Protocol over Ethernet).
   */
  virtual task body();
    `uvm_info(get_type_name(), "Sequence started", UVM_LOW);
    `uvm_do_on_with(req, p_sequencer.enet_seqr, { TagKind        == DENALI_ENET_TAGKIND_UNTAGGED;
                                                  Type           == DENALI_ENET_TR_pkt;
                                                  PacketKind     == DENALI_ENET_PACKETKIND_ETHERNET_802_3;
                                                  UpperLayerKind == DENALI_ENET_UPPERLAYERKIND_IPoE;
                                                  LenErr == 0;
                                                  // Constrainint IPG to be legal (i.e. not less than 64 byte time)
                                                  Ipg        inside {[64:88]};
                                                  DataLength inside {[120:140]}; })
    `uvm_info(get_type_name(), "Sequence ended", UVM_LOW);
  endtask : body

endclass : cdn_gem_demo_line_enet_layer_seq

/*
 * sequence_description: cdn_gem_demo_line_network_layer_seq
 *
 * This sequence constrains the network layer of a single Ethernet packet to
 * match IPv4 type of service or IPv6 traffic class against screeners type 1 in
 * the DUT.
 *
 * Class: cdn_gem_demo_line_network_layer_seq
 *
 * This sequence constrains the network layer of a single Ethernet packet to
 * match IPv4 type of service or IPv6 traffic class against screeners type 1 in
 * the DUT.
 */
class cdn_gem_demo_line_network_layer_seq extends cdn_gem_demo_line_base_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_network_layer_seq)

  //----------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_network_layer_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_network_layer_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the sequence.
   * In here, the network packet layer is constrained.
   * The IPv4 Flags and Fragment Offset fields are constrained to enable
   * UDP decoding in the GEM Rx FSM.
   * To enable screener type 1 testing, the IPv4 Differentiated Service
   * (Type of Service) and the IPv6 Traffic Class are constrained to be
   * one of the GEM queue numbers (0-15).
   */
  virtual task body();
    `uvm_info(get_type_name(), "Sequence started", UVM_LOW);
    `uvm_do_on_with(req, p_sequencer.enet_seqr, { Type == DENALI_ENET_TR_networkPkt;
                                                  // These should be constrained because Rx decode FSM
                                                  // doesn't work with fragmented IPv4
                                                  IPv4Flags inside {3'b000 , 3'b010};
                                                  IPv4FragmentOffset == 13'b0_0000_0000_0000;
                                                  // These two fields are matched against screener type1
                                                  IPv4TypeOfService inside {[8'h00:8'h0f]};
                                                  IPv6TrafficClass  inside {[8'h00:8'h0f]}; })
    `uvm_info(get_type_name(), "Sequence ended", UVM_LOW);
  endtask : body

endclass : cdn_gem_demo_line_network_layer_seq

/*
 * sequence_description: cdn_gem_demo_line_transport_layer_seq
 *
 * This sequence constrains the transport layer of a single Ethernet packet to
 * carry UDP over IPv4 or IPv6.
 *
 * Class: cdn_gem_demo_line_transport_layer_seq
 *
 * This sequence constrains the transport layer of a single Ethernet packet to
 * carry UDP over IPv4 or IPv6.
 */
class cdn_gem_demo_line_transport_layer_seq extends cdn_gem_demo_line_base_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_transport_layer_seq)

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_transport_layer_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_transport_layer_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the sequence.
   * In here, the transport packet layer is constrained.
   * The transport protocol is set to UDP.
   * The network protocol can be either IPv4 or IPv6.
   * To enable screener type 1 testing, the UDP destination port is
   * constrained to be one of the GEM queue numbers (0-15).
   */
  virtual task body();
    `uvm_info(get_type_name(), "Sequence started", UVM_LOW);
    `uvm_do_on_with(req, p_sequencer.enet_seqr, { Type          == DENALI_ENET_TR_transportPkt;
                                                  TransportKind == DENALI_ENET_TRANSPORTKIND_UDP;
                                                  NetworkKind inside {DENALI_ENET_NETWORKKIND_IPV4, DENALI_ENET_NETWORKKIND_IPV6};
                                                  UDPDestinationPort inside {[16'h0000:16'h000f]}; });
    `uvm_info(get_type_name(), "Sequence ended", UVM_LOW);
  endtask : body

endclass : cdn_gem_demo_line_transport_layer_seq

/*
 * sequence_description: cdn_gem_demo_line_snap_layer_seq
 *
 * This sequence constrains the SNAP layer of a single Ethernet packet.
 *
 * Class: cdn_gem_demo_line_snap_layer_seq
 *
 * This sequence constrains the SNAP layer of a single Ethernet packet.
 */
class cdn_gem_demo_line_snap_layer_seq extends cdn_gem_demo_line_base_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_snap_layer_seq)

  //----------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_snap_layer_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_snap_layer_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the sequence.
   * In here, the SNAP packet layer is constrained.
   * No SNAP is present in the packet.
   */
  virtual task body();
    `uvm_info(get_type_name(), "Sequence started", UVM_LOW);
    `uvm_do_on_with(req, p_sequencer.enet_seqr, { Type     == DENALI_ENET_TR_snapPkt;
                                                  SnapKind == DENALI_ENET_SNAPKIND_NO_SNAP; })
    `uvm_info(get_type_name(), "Sequence ended", UVM_LOW);
  endtask : body

endclass : cdn_gem_demo_line_snap_layer_seq

/*
 * sequence_description: cdn_gem_demo_line_mpls_layer_seq
 *
 * This sequence constrains the MPLS layer of a single Ethernet packet.
 *
 * Class: cdn_gem_demo_line_mpls_layer_seq
 *
 * This sequence constrains the MPLS layer of a single Ethernet packet.
 */
class cdn_gem_demo_line_mpls_layer_seq extends cdn_gem_demo_line_base_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_mpls_layer_seq)

  //----------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_mpls_layer_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_mpls_layer_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the sequence.
   * In here, the MPLS packet layer is constrained.
   * No MPLS is present in the packet.
   */
  virtual task body();
    `uvm_info(get_type_name(), "Sequence started", UVM_LOW);
    `uvm_do_on_with(req, p_sequencer.enet_seqr, { Type     == DENALI_ENET_TR_mplsPkt;
                                                  MplsKind == DENALI_ENET_MPLSKIND_NO_MPLS; })
    `uvm_info(get_type_name(), "Sequence ended", UVM_LOW);
  endtask : body

endclass : cdn_gem_demo_line_mpls_layer_seq

/*
 * sequence_description: cdn_gem_demo_line_1pkt_seq
 *
 * This sequence generates a single Ethernet packet constraining each layer to
 * match specific functionalities shown in the tests.
 *
 * Class: cdn_gem_demo_line_1pkt_seq
 *
 * This sequence generates a single Ethernet packet constraining each layer to
 * match specific functionalities shown in the tests.
 */
class cdn_gem_demo_line_1pkt_seq extends cdn_gem_demo_line_base_seq;

  //----------------------------------------
  // UVM AUTOMATION MACROS
  //----------------------------------------

  `uvm_object_utils(cdn_gem_demo_line_1pkt_seq)

  //----------------------------------------
  // MEMBER VARIABLES
  //----------------------------------------

  /*
   * Variable: DRAIN_TIME
   *
   * Sets the drain time.
   */
  static time DRAIN_TIME = 500000fs;

  /*
   * Variable: eth_pkt
   *
   * A sequence of the cdn_gem_demo_line_enet_layer_seq type.
   */
  cdn_gem_demo_line_enet_layer_seq eth_pkt;

  /*
   * Variable: network_pkt
   *
   * A sequence of the cdn_gem_demo_line_network_layer_seq type.
   */
  cdn_gem_demo_line_network_layer_seq network_pkt;

  /*
   * Variable: transport_pkt
   *
   * A sequence of the cdn_gem_demo_line_transport_layer_seq type.
   */
  cdn_gem_demo_line_transport_layer_seq transport_pkt;

  /*
   * Variable: mpls_pkt
   *
   * A sequence of the cdn_gem_demo_line_mpls_layer_seq type.
   */
  cdn_gem_demo_line_mpls_layer_seq mpls_pkt;

  /*
   * Variable: snap_pkt
   *
   * A sequence of the cdn_gem_demo_line_snap_layer_seq type.
   */
  cdn_gem_demo_line_snap_layer_seq snap_pkt;

  //----------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //----------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_line_1pkt_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_line_1pkt_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the sequence.
   */
  virtual task body();
    // Setting Messsage verbosity
    p_sequencer.enet_seqr.pAgent.regInst.writeReg(DENALI_ENET_REG_Verbosity, DENALI_ENET_MESSAGEVERBOSITY_NONE);

    `uvm_info(get_type_name(), "Sequence started", UVM_LOW);
    fork
      // begin-end #1
      begin
        `uvm_info(get_type_name(), "Fork begin sequence 1", UVM_DEBUG);
        #1;

        // Ethernet Packet Stage
        `uvm_do(eth_pkt)
        // Transport Packet Stage
        `uvm_do(transport_pkt)
        // Network Packet Stage
        `uvm_do(network_pkt)
        // MPLS Packet Stage
        `uvm_do(mpls_pkt)
        // SNAP Packet Stage
        `uvm_do(snap_pkt)

        `uvm_info(get_type_name(), "Fork begin sequence 1 ends", UVM_DEBUG);
      end
      // begin-end #2
      begin
        `uvm_info(get_type_name(), "Fork begin sequence 2", UVM_DEBUG);
        // Waiting for TxPktEndedPktCbEvent.
        // This event is triggered once BFM end-up the current packet transmission.
        p_sequencer.enet_seqr.pAgent.monitor.TxPktEndedPktCbEvent.wait_trigger();
        `uvm_info(get_type_name(), "Fork begin sequence 2 ends", UVM_DEBUG);
      end
    join
    `uvm_info(get_type_name(), "Sequence ended", UVM_LOW);
    #DRAIN_TIME;
  endtask : body

endclass : cdn_gem_demo_line_1pkt_seq

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
