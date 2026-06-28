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
 * File: cdn_gem_demo_tests_virtual_seq_lib.sv
 *
 * This files defines the cdn_gem_demo virtual sequence library, in which each
 * sequence corresponds to a different test.
 * All the sequences defined here are children of the normal_operation_seq
 * sequence - as defined in the cdn_demo_sequence_lib.sv library - to correctly
 * exercise the DUT reset.
 * In order to do this, the super.body() function is called at the beginning of
 * each body function.
 */

`ifndef CDN_GEM_DEMO_TESTS_VIRTUAL_SEQ_LIB_SV
  `define CDN_GEM_DEMO_TESTS_VIRTUAL_SEQ_LIB_SV

/*
 * sequence_description: cdn_gem_demo_test_base_virtual_seq
 *
 * Just a convenience sequence to define in one place the setup for the AXI
 * memory (UVM) with respect to descriptor and databuffers.
 *
 * Class: cdn_gem_demo_test_base_virtual_seq
 *
 * Just a convenience sequence to define in one place the setup for the AXI
 * memory (UVM) with respect to descriptor and databuffers.
 */
class cdn_gem_demo_test_base_virtual_seq extends cdn_gem_demo_base_virtual_seq;

  //--------------------------------------------------
  // CONVENTIONS FOR THE ORGANIZATION OF AXI MEM     |
  //--------------------------------------------------
  //       | Descriptor         | Databuffer         |
  // Queue | Base Addr | Size   | Base Addr | Size   |
  //--------------------------------------------------
  //     0 |  0x0_0000 | 0xffff | 0x16_0000 | 0xffff |
  //     1 |  0x1_0000 | 0xffff | 0x17_0000 | 0xffff |
  //     2 |  0x2_0000 | 0xffff | 0x18_0000 | 0xffff |
  //     3 |  0x3_0000 | 0xffff | 0x19_0000 | 0xffff |
  //     4 |  0x4_0000 | 0xffff | 0x20_0000 | 0xffff |
  //     5 |  0x5_0000 | 0xffff | 0x21_0000 | 0xffff |
  //     6 |  0x6_0000 | 0xffff | 0x22_0000 | 0xffff |
  //     7 |  0x7_0000 | 0xffff | 0x23_0000 | 0xffff |
  //     8 |  0x8_0000 | 0xffff | 0x24_0000 | 0xffff |
  //     9 |  0x9_0000 | 0xffff | 0x25_0000 | 0xffff |
  //    10 | 0x10_0000 | 0xffff | 0x26_0000 | 0xffff |
  //    11 | 0x11_0000 | 0xffff | 0x27_0000 | 0xffff |
  //    12 | 0x12_0000 | 0xffff | 0x28_0000 | 0xffff |
  //    13 | 0x13_0000 | 0xffff | 0x29_0000 | 0xffff |
  //    14 | 0x14_0000 | 0xffff | 0x31_0000 | 0xffff |
  //    15 | 0x15_0000 | 0xffff | 0x32_0000 | 0xffff |
  //--------------------------------------------------

  //---------------------------------
  // MEMBER VARIABLES.
  //---------------------------------

  /*
   * Variable: descriptor_mem_base_addr
   *
   * An array to store descriptor memory base address (for each queue).
   */
  bit [31:0] descriptor_mem_base_addr[16];

  /*
   * Variable: descriptor_mem_size
   *
   * An array to store descriptor memory size (for each queue).
   */
  bit [31:0] descriptor_mem_size[16] = '{16{32'h0000_ffff}};

  /*
   * Variable: databuffer_mem_base_addr
   *
   * An array to store databuffer memory base address (for each queue).
   */
  bit [31:0] databuffer_mem_base_addr[16];

  /*
   * Variable: databuffer_mem_size
   *
   * An array to store databuffer memory size (for each queue).
   */
  bit [31:0] databuffer_mem_size[16] = '{16{32'h0000_ffff}};

  //---------------------------------
  // UVM AUTOMATION MACROS.
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_test_base_virtual_seq)

  //---------------------------------
  // CONSTRUCTOR.
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_test_base_virtual_seq objects.
   *
   * Parameters:
   *
   *    name - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_test_base_virtual_seq");
    super.new(name);
    for(int i=0; i<16; i++) begin
      descriptor_mem_base_addr[i] = 32'h0000_0000 + i*32'h0001_0000;
      databuffer_mem_base_addr[i] = 32'h0016_0000 + i*32'h0001_0000;
    end
  endfunction

endclass : cdn_gem_demo_test_base_virtual_seq


//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UC_ENET_RX_1PKT_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uc_enet_rx_1pkt_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_rx_1pkt_test test.
 *
 * Class: cdn_gem_demo_uc_enet_rx_1pkt_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_rx_1pkt_test test.
 */
class cdn_gem_demo_uc_enet_rx_1pkt_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // SUB-SEQUENCES
  //---------------------------------

  /*
   * Variable: init_seq
   *
   * The sequence that initializes basic DUT registers.
   */
  cdn_gem_demo_prog_init_seq init_seq;

  /*
   * Variable: write_dtable
   *
   * The sequence that writes the descriptor table to the main memory.
   */
  cdn_gem_demo_host_wr_dtable_seq write_dtable;

  /*
   * Variable: prog_q
   *
   * The sequence that initializes the DUT queue pointers.
   */
  cdn_gem_demo_prog_q_seq prog_q;

  /*
   * Variable: start_op
   *
   * The sequence that starts Rx operations.
   */
  cdn_gem_demo_prog_start_seq start_op;

  /*
   * Variable: send_eth_pkt
   *
   * The sequence that sends an Ethernet packet from the line side.
   */
  cdn_gem_demo_line_1pkt_seq send_eth_pkt;

  /*
   * Variable: check
   *
   * The sequence that check the dpram_fill_dbg register to asses the end of
   * test.
   */
  cdn_gem_demo_prog_check_seq check;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_uc_enet_rx_1pkt_seq)
    `uvm_field_object(init_seq, UVM_DEFAULT)
    `uvm_field_object(write_dtable, UVM_DEFAULT)
    `uvm_field_object(prog_q, UVM_DEFAULT)
    `uvm_field_object(start_op, UVM_DEFAULT)
    `uvm_field_object(send_eth_pkt, UVM_DEFAULT)
    `uvm_field_object(check, UVM_DEFAULT)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uc_enet_rx_1pkt_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_uc_enet_rx_1pkt_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the cdn_gem_demo_uc_enet_rx_1pkt_seq sequence.
   * It initializes and nests the following sequences:-
   *
   * - cdn_gem_demo_prog_init_seq. Initializes basic registers in the DUT.
   * - cdn_gem_demo_host_wr_dtable_seq. Descriptor table initialization. First
   *   descriptor pointed to the databuffer location. Second descriptor has wrap
   *   bit set (last descriptor).
   * - cdn_gem_demo_prog_q_seq. Queue pointer registers initialization.
   * - cdn_gem_demo_prog_start_seq. Trigger Rx start.
   * - cdn_gem_demo_line_1pkt_seq. Inject a packet from line side.
   * - cdn_gem_demo_prog_check_seq. Check the DPRAM fill debug register to
   *   assert the Rx complete.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //---------------------------------
    // Initialize DUT
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 0 | Initializing DUT Basic Registers", UVM_NONE)

    `uvm_create(init_seq)
    `uvm_send(init_seq)

    //---------------------------------
    // Write descriptors to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 1 | Initializing Descriptor Table", UVM_NONE)

    // FIRST DESCRIPTOR
    `uvm_create(write_dtable)
      // Descriptor table base address
      write_dtable.addr = descriptor_mem_base_addr[0];
      // Databuffer base address
      write_dtable.w0   = databuffer_mem_base_addr[0];
    `uvm_send(write_dtable)

    // SECOND DESCRIPTOR
    `uvm_create(write_dtable)
      // Descriptor table base address
      write_dtable.addr = descriptor_mem_base_addr[0] + 32'h0000_0008;
      // Wrap bit is set - Last descriptor in the table
      write_dtable.w0   = 32'h0000_0002;
    `uvm_send(write_dtable)

    `ifndef CDN_DEMO_C
      //---------------------------------
      // Scoreboard Setup
      //---------------------------------

      // Disable Tx Scoreboard
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Configure Rx Scoreboard
      p_sequencer.p_env.gem_sb_rx.qptr_dbuff_mem_base_addr[0] = databuffer_mem_base_addr[0];
      p_sequencer.p_env.gem_sb_rx.qptr_dbuff_mem_size[0] = databuffer_mem_size[0];
    `endif

    //---------------------------------
    // Initialize Queue Pointers
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 2 | Initializing Queue Pointers", UVM_NONE)

    `uvm_create(prog_q)
      // Operating in Rx
      prog_q.mode_tx = 0;
      // Descriptor table base address to write the queue pointer
      prog_q.dtable_addr[0] = descriptor_mem_base_addr[0];
    `uvm_send(prog_q)

    //---------------------------------
    // Start the Rx
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Starting Rx", UVM_NONE)

    `uvm_create(start_op)
      // Operating in Rx
      start_op.mode_tx = 0;
    `uvm_send(start_op)

    //---------------------------------
    // Inject Packets
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 4 | Inject Packets From Line Side", UVM_NONE)

    // Wait some time before injecting
    #10;

    // Inject packets
    `uvm_create(send_eth_pkt)
    `uvm_send(send_eth_pkt)

    //---------------------------------
    // Check DPRAM Fill Debug register
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 5 | Checking Registers And Ending Test", UVM_NONE)

    `uvm_create(check)
      // Operating in Rx
      check.mode_tx = 0;
      // Setting the timeout event
      check.max_reads = 300;
    `uvm_send(check)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uc_enet_rx_1pkt_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UC_ENET_RX_3PKTS_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uc_enet_rx_3pkts_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_rx_3pkts_test test.
 *
 * Class: cdn_gem_demo_uc_enet_rx_3pkts_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_rx_3pkts_test test.
 */
class cdn_gem_demo_uc_enet_rx_3pkts_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // SUB-SEQUENCES
  //---------------------------------

  /*
   * Variable: init_seq
   *
   * The sequence that initializes basic DUT registers.
   */
  cdn_gem_demo_prog_init_seq init_seq;

  /*
   * Variable: write_dtable
   *
   * The sequence that writes the descriptor table to the main memory.
   */
  cdn_gem_demo_host_wr_dtable_seq write_dtable;

  /*
   * Variable: prog_q
   *
   * The sequence that initializes the DUT queue pointers.
   */
  cdn_gem_demo_prog_q_seq prog_q;

  /*
   * Variable: start_op
   *
   * The sequence that starts Rx operations.
   */
  cdn_gem_demo_prog_start_seq start_op;

  /*
   * Variable: send_eth_pkt
   *
   * The sequence that sends an Ethernet packet from the line side.
   */
  cdn_gem_demo_line_1pkt_seq send_eth_pkt;

  /*
   * Variable: check
   *
   * The sequence that check the dpram_fill_dbg register to asses the end of
   * test.
   */
  cdn_gem_demo_prog_check_seq check;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_uc_enet_rx_3pkts_seq)
    `uvm_field_object(init_seq, UVM_DEFAULT)
    `uvm_field_object(write_dtable, UVM_DEFAULT)
    `uvm_field_object(prog_q, UVM_DEFAULT)
    `uvm_field_object(start_op, UVM_DEFAULT)
    `uvm_field_object(send_eth_pkt, UVM_DEFAULT)
    `uvm_field_object(check, UVM_DEFAULT)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uc_enet_rx_3pkts_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_uc_enet_rx_3pkts_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the cdn_gem_demo_uc_enet_rx_3pkts_seq sequence.
   * It initializes and nests the following sequences:-
   *
   * - cdn_gem_demo_prog_init_seq. Initializes basic registers in the DUT.
   * - cdn_gem_demo_host_wr_dtable_seq. Descriptor table initialization.
   *   First, second and third descriptors pointed to databuffers locations.
   *   Fourth descriptor has wrap bit set (last descriptor).
   * - cdn_gem_demo_prog_q_seq. Queue pointer registers initialization.
   * - cdn_gem_demo_prog_start_seq. Trigger Rx start.
   * - cdn_gem_demo_line_1pkt_seq. Inject three packets from line side.
   * - cdn_gem_demo_prog_check_seq. Check the DPRAM fill debug register to
   *   assert the Rx complete.
   */
  virtual task body();
    int pkt_num = 3;
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //---------------------------------
    // Initialize DUT
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 0 | Initialization of DUT Basic Registers", UVM_NONE)

    `uvm_create(init_seq)
    `uvm_send(init_seq)

    //---------------------------------
    // Write descriptors to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 1 | Initializing Descriptor Table", UVM_NONE)

    // UNUSED DESCRIPTORS
    for (int i=0 ; i<pkt_num ; i++) begin
      `uvm_create(write_dtable)
        // Descriptor address
        write_dtable.addr = descriptor_mem_base_addr[0] + i*32'h0000_0008;
        // Databuffer address
        write_dtable.w0 = databuffer_mem_base_addr[0] + i*32'h000_0100;
      `uvm_send(write_dtable)
    end

    // LAST DESCRIPTOR
    `uvm_create(write_dtable)
      // Next descriptor address
      write_dtable.addr = descriptor_mem_base_addr[0] + pkt_num*32'h0000_0008;
      // Wrap bit is set - Last descriptor in the table
      write_dtable.w0 = 32'h0000_0002;
    `uvm_send(write_dtable)

    `ifndef CDN_DEMO_C
      //---------------------------------
      // Scoreboard Setup
      //---------------------------------

      // Disable Tx Scoreboard
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Configure Rx Scoreboard
      p_sequencer.p_env.gem_sb_rx.qptr_dbuff_mem_base_addr[0] = databuffer_mem_base_addr[0];
      p_sequencer.p_env.gem_sb_rx.qptr_dbuff_mem_size[0] = databuffer_mem_size[0];
    `endif

    //---------------------------------
    // Initialize Queue Pointers
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 2 | Initializing Queue Pointers", UVM_NONE)

    `uvm_create(prog_q)
      // Operating in Rx
      prog_q.mode_tx = 0;
      // Descriptor table base address to write the queue pointer
      prog_q.dtable_addr[0] = descriptor_mem_base_addr[0];
    `uvm_send(prog_q)

    //---------------------------------
    // Start the Rx
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Starting Rx", UVM_NONE)

    `uvm_create(start_op)
      // Operating in Rx
      start_op.mode_tx = 0;
    `uvm_send(start_op)

    //---------------------------------
    // Inject Packets
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 4 | Inject Packets From Line Side", UVM_NONE)

    // Wait some time before injecting
    #10;

    // Inject packets
    repeat(pkt_num) begin
      `uvm_create(send_eth_pkt)
      `uvm_send(send_eth_pkt)
    end

    //---------------------------------
    // Check DPRAM Fill Debug register
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 5 | Checking Registers And Ending Test", UVM_NONE)

    `uvm_create(check)
      // Operating in Rx
      check.mode_tx = 0;
      // Setting the timeout event
      check.max_reads = 300;
    `uvm_send(check)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uc_enet_rx_3pkts_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UC_ENET_TX_1PKT_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uc_enet_tx_1pkt_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_tx_1pkt_test test.
 *
 * Class: cdn_gem_demo_uc_enet_tx_1pkt_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_tx_1pkt_test test.
 */
class cdn_gem_demo_uc_enet_tx_1pkt_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // SUB-SEQUENCES
  //---------------------------------

  /*
   * Variable: init_seq
   *
   * The sequence that initializes basic DUT registers.
   */
  cdn_gem_demo_prog_init_seq init_seq;

  /*
   * Variable: write_dtable
   *
   * The sequence that writes the descriptor table to the main memory.
   */
  cdn_gem_demo_host_wr_dtable_seq write_dtable;

  /*
   * Variable: write_dbuff
   *
   * The sequence that writes the databuffer to the  main memory.
   */
  cdn_gem_demo_host_wr_dbuff_incr_seq write_dbuff;

  /*
   * Variable: prog_q
   *
   * The sequence that initializes the DUT queue pointers.
   */
  cdn_gem_demo_prog_q_seq prog_q;

  /*
   * Variable: start_op
   *
   * The sequence that starts Tx operations.
   */
  cdn_gem_demo_prog_start_seq start_op;

  /*
   * Variable: check
   *
   * The sequence that check the transmit_status register to asses the end of
   * test.
   */
  cdn_gem_demo_prog_check_seq check;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_uc_enet_tx_1pkt_seq)
    `uvm_field_object(init_seq, UVM_DEFAULT)
    `uvm_field_object(write_dtable, UVM_DEFAULT)
    `uvm_field_object(write_dbuff, UVM_DEFAULT)
    `uvm_field_object(prog_q, UVM_DEFAULT)
    `uvm_field_object(start_op, UVM_DEFAULT)
    `uvm_field_object(check, UVM_DEFAULT)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uc_enet_tx_1pkt_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_uc_enet_tx_1pkt_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the cdn_gem_demo_uc_enet_tx_1pkt_seq sequence.
   * It initializes and nests the following sequences:-
   *
   * - cdn_gem_demo_prog_init_seq. Initializes basic registers in the DUT.
   * - cdn_gem_demo_host_wr_dtable_seq. Descriptor table initialization.
   *   First descriptor pointed to the databuffer location.
   *   Second descriptor has used and wrap bit set (last descriptor).
   * - cdn_gem_demo_host_wr_dbuff_incr_seq. Databuffer initialization.
   * - cdn_gem_demo_prog_q_seq. Queue pointer registers initialization.
   * - cdn_gem_demo_prog_start_seq. Trigger Tx start.
   * - cdn_gem_demo_prog_check_seq. Check the transmit status register to
   *   assert the Tx complete.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //---------------------------------
    // Initialize DUT
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 0 | Initializing DUT Basic Registers", UVM_NONE)

    `uvm_create(init_seq)
    `uvm_send(init_seq)

    //---------------------------------
    // Write descriptors to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 1 | Initializing Descriptor Table", UVM_NONE)

    // FIRST DESCRIPTOR
    `uvm_create(write_dtable)
      // Descriptor table base address
      write_dtable.addr = descriptor_mem_base_addr[0];
      // Databuffer base address
      write_dtable.w0 = databuffer_mem_base_addr[0];
      // Last buffer + buffer length (64 bytes)
      write_dtable.w1 = 32'h0000_8040;
    `uvm_send(write_dtable)

    // SECOND DESCRIPTOR
    `uvm_create(write_dtable)
      // Next descriptor address
      write_dtable.addr = descriptor_mem_base_addr[0] + 64'h0000_0008;
      // Wrap and used bits set - Last descriptor in the table
      write_dtable.w1 = 32'hc000_0000;
    `uvm_send(write_dtable)

    //---------------------------------
    // Write the databuffer to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 2 | Initializing Databuffer", UVM_NONE)

    `uvm_create(write_dbuff)
      // Databuffer base address
      write_dbuff.addr = 64'h0000_0000_0016_0000;
      // The length of the databuffer in bytes as previously specified
      write_dbuff.length = 64;
    `uvm_send(write_dbuff)

    `ifndef CDN_DEMO_C
      //---------------------------------
      // Scoreboard Setup
      //---------------------------------

      // Configure Tx Scoreboard
      p_sequencer.p_env.gem_sb_tx.qptr_dbuff_mem_base_addr[0] = databuffer_mem_base_addr[0];
      p_sequencer.p_env.gem_sb_tx.qptr_dbuff_mem_size[0] = databuffer_mem_size[0];

      // Disable Rx Scoreboard
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    //---------------------------------
    // Initialize Queue Pointers
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Initializing Queue Pointers", UVM_NONE)

    `uvm_create(prog_q)
      // Descriptor table base address to write the queue pointer
      prog_q.dtable_addr[0] = descriptor_mem_base_addr[0];
    `uvm_send(prog_q)

    //---------------------------------
    // Start the Tx
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Starting Tx", UVM_NONE)

    `uvm_create(start_op)
      // Operating in Tx
      start_op.mode_tx = 1;
    `uvm_send(start_op)

    //---------------------------------
    // Check Transmit Status register
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 5 | Checking Registers And Ending Test", UVM_NONE)

    `uvm_create(check)
      // Operating in Tx
      check.mode_tx = 1;
      // Setting the timeout event
      check.max_reads = 300;
    `uvm_send(check)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uc_enet_tx_1pkt_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UC_ENET_TX_2PKTS_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uc_enet_tx_2pkts_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_tx_2pkts_test test.
 *
 * Class: cdn_gem_demo_uc_enet_tx_2pkts_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_tx_2pkts_test test.
 */
class cdn_gem_demo_uc_enet_tx_2pkts_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // SUB-SEQUENCES
  //---------------------------------

  /*
   * Variable: init_seq
   *
   * The sequence that initializes basic DUT registers.
   */
  cdn_gem_demo_prog_init_seq init_seq;

  /*
   * Variable: write_dtable
   *
   * The sequence that writes the descriptor table to the main memory.
   */
  cdn_gem_demo_host_wr_dtable_seq write_dtable;

  /*
   * Variable: write_dbuff
   *
   * The sequence that writes the databuffer to the  main memory.
   */
  cdn_gem_demo_host_wr_dbuff_incr_seq write_dbuff;

  /*
   * Variable: prog_q
   *
   * The sequence that initializes the DUT queue pointers.
   */
  cdn_gem_demo_prog_q_seq prog_q;

  /*
   * Variable: start_op
   *
   * The sequence that starts Tx operations.
   */
  cdn_gem_demo_prog_start_seq start_op;

  /*
   * Variable: check
   *
   * The sequence that check the transmit_status register to asses the end of
   * test.
   */
  cdn_gem_demo_prog_check_seq check;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_uc_enet_tx_2pkts_seq)
    `uvm_field_object(init_seq, UVM_DEFAULT)
    `uvm_field_object(write_dtable, UVM_DEFAULT)
    `uvm_field_object(write_dbuff, UVM_DEFAULT)
    `uvm_field_object(prog_q, UVM_DEFAULT)
    `uvm_field_object(start_op, UVM_DEFAULT)
    `uvm_field_object(check, UVM_DEFAULT)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uc_enet_tx_2pkts_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_uc_enet_tx_2pkts_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the cdn_gem_demo_uc_enet_tx_2pkts_seq sequence.
   * It initializes and nests the following sequences:-
   *
   * - cdn_gem_demo_prog_init_seq. Initializes basic registers in the DUT.
   * - cdn_gem_demo_host_wr_dtable_seq. Descriptor table initialization.
   *   First and second descriptors pointed to databuffers locations.
   *   Third descriptor has used and wrap bit set (last descriptor).
   * - cdn_gem_demo_host_wr_dbuff_incr_seq. Databuffers initialization.
   * - cdn_gem_demo_prog_q_seq. Queue pointer registers initialization.
   * - cdn_gem_demo_prog_start_seq. Trigger Tx start.
   * - cdn_gem_demo_prog_check_seq. Check the transmit status register to
   *   assert the Tx complete.
   */
  virtual task body();
    int pkt_num = 2;
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //---------------------------------
    // Initialize DUT
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 0 | Initializing DUT Basic Registers", UVM_NONE)

    `uvm_create(init_seq)
    `uvm_send(init_seq)

    //---------------------------------
    // Write descriptors to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 1 | Initializing Descriptor Table", UVM_NONE)

    // UNUSED DESCRIPTORS
    for (int i=0; i<pkt_num; i++) begin
      `uvm_create(write_dtable)
        // Descriptor address
        write_dtable.addr = descriptor_mem_base_addr[0] + i*32'h0000_0008;
        // Databuffer address
        write_dtable.w0 = databuffer_mem_base_addr[0] + i*32'h0000_0080;
        // Last buffer + buffer length
        write_dtable.w1 = 32'h0000_8040 + i*32'h0000_0040;
      `uvm_send(write_dtable)
    end

    // LAST DESCRIPTOR
    `uvm_create(write_dtable)
      // Next descriptor address
      write_dtable.addr = descriptor_mem_base_addr[0] + pkt_num*32'h0000_0008;
      // Wrap and used bits set - Last descriptor in the table
      write_dtable.w1 = 32'hc000_0000;
    `uvm_send(write_dtable)

    //---------------------------------
    // Write the databuffer to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 2 | Initializing Databuffer", UVM_NONE)

    for (int i=0; i<pkt_num; i++) begin
      `uvm_create(write_dbuff)
        // Databuffer base address
        write_dbuff.addr = databuffer_mem_base_addr[0] + i*32'h0000_0080;
        // The length of the databuffer in bytes as previously specified
        write_dbuff.length = 64 + i*64;
      `uvm_send(write_dbuff)
    end

    `ifndef CDN_DEMO_C
      //---------------------------------
      // Scoreboard Setup
      //---------------------------------

      // Configure Tx Scoreboard
      p_sequencer.p_env.gem_sb_tx.qptr_dbuff_mem_base_addr[0] = databuffer_mem_base_addr[0];
      p_sequencer.p_env.gem_sb_tx.qptr_dbuff_mem_size[0] = databuffer_mem_size[0];

      // Disable Rx Scoreboard
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    //---------------------------------
    // Initialize Queue Pointers
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Initializing Queue Pointers", UVM_NONE)

    `uvm_create(prog_q)
      // Descriptor table base address to write the queue pointer
      prog_q.dtable_addr[0] = descriptor_mem_base_addr[0];
    `uvm_send(prog_q)

    //---------------------------------
    // Start the Tx
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Starting Tx", UVM_NONE)

    `uvm_create(start_op)
      // Operating in Tx
      start_op.mode_tx = 1;
    `uvm_send(start_op)

    //---------------------------------
    // Check Transmit Status register
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 5 | Checking Registers And Ending Test", UVM_NONE)

    `uvm_create(check)
      // Operating in Tx
      check.mode_tx = 1;
      // Setting the timeout event
      check.max_reads = 300;
    `uvm_send(check)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uc_enet_tx_2pkts_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UC_ENET_TX_Q_FIXED_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uc_enet_tx_q_fixed_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_tx_q_fixed_test
 * test.
 *
 * Class: cdn_gem_demo_uc_enet_tx_q_fixed_seq
 *
 * This is the virtual sequence for the cdn_gem_demo_uc_enet_tx_q_fixed_test
 * test.
 */
class cdn_gem_demo_uc_enet_tx_q_fixed_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // SUB-SEQUENCES
  //---------------------------------

  /*
   * Variable: init_seq
   *
   * The sequence that initializes basic DUT registers.
   */
  cdn_gem_demo_prog_init_seq init_seq;

  /*
   * Variable: write_dtable
   *
   * The sequence that writes the descriptor table to the main memory.
   */
  cdn_gem_demo_host_wr_dtable_seq write_dtable;

  /*
   * Variable: write_dbuff
   *
   * The sequence that writes the databuffer to the  main memory.
   */
  cdn_gem_demo_host_wr_dbuff_incr_seq write_dbuff;

  /*
   * Variable: prog_q
   *
   * The sequence that initializes the GEM queue pointers.
   */
  cdn_gem_demo_prog_q_seq prog_q;

  /*
   * Variable: start_op
   *
   * The sequence that starts Tx operations.
   */
  cdn_gem_demo_prog_start_seq start_op;

  /*
   * Variable: check
   *
   * The sequence that check the transmit_status register to asses the end of
   * test.
   */
  cdn_gem_demo_prog_check_seq check;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils_begin(cdn_gem_demo_uc_enet_tx_q_fixed_seq)
    `uvm_field_object(init_seq, UVM_DEFAULT)
    `uvm_field_object(write_dtable, UVM_DEFAULT)
    `uvm_field_object(write_dbuff, UVM_DEFAULT)
    `uvm_field_object(prog_q, UVM_DEFAULT)
    `uvm_field_object(start_op, UVM_DEFAULT)
    `uvm_field_object(check, UVM_DEFAULT)
  `uvm_object_utils_end

  //---------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uc_enet_tx_q_fixed_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new (string name = "cdn_gem_demo_uc_enet_tx_q_fixed_seq");
    super.new(name);
  endfunction : new

  /*
   * Method: body
   *
   * The body of the cdn_gem_demo_uc_enet_tx_q_fixed_seq sequence.
   * It initializes and nests the following sequences:-
   *
   * - cdn_gem_demo_prog_init_seq. Initializes basic registers in the DUT.
   * - cdn_gem_demo_host_wr_dtable_seq. Descriptor table initialization.
   *   First and second descriptors pointed to databuffers locations.
   *   Third descriptor has used and wrap bit set (last descriptor).
   * - cdn_gem_demo_host_wr_dbuff_incr_seq. Databuffers initialization.
   * - cdn_gem_demo_prog_q_seq. Queue pointer registers initialization.
   * - cdn_gem_demo_prog_start_seq. Trigger Tx start.
   * - cdn_gem_demo_prog_check_seq. Check the transmit status register to
   *   assert the Tx complete.
   */
  virtual task body();
    int pkt_num = 1;
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    //---------------------------------
    // Initialize DUT
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 0 | Initializing DUT Basic Registers", UVM_NONE)

    `uvm_create(init_seq)
    `uvm_send(init_seq)

    //---------------------------------
    // Write descriptors to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 1 | Initializing Descriptor Table", UVM_NONE)

    for (int q=0; q<16; q++) begin
      if(init_seq.is_q_cfgrd[q]) begin
        // UNUSED DESCRIPTOR
        for (int i=0; i<pkt_num; i++) begin
          `uvm_create(write_dtable)
            // Descriptor address
            write_dtable.addr = descriptor_mem_base_addr[q] + i*32'h0000_0008;
            // Databuffer address
            write_dtable.w0 = databuffer_mem_base_addr[q] + i*32'h0000_0080;
            // Last buffer + buffer length
            write_dtable.w1 = 32'h0000_8040;
          `uvm_send(write_dtable)
        end

        // LAST DESCRIPTOR
        `uvm_create(write_dtable)
          // Next descriptor address
          write_dtable.addr = descriptor_mem_base_addr[q] + pkt_num*32'h0000_0008;
          // Wrap and used bits set - Last descriptor in the table
          write_dtable.w1 = 32'hc000_0000;
        `uvm_send(write_dtable)
      end
    end

    //---------------------------------
    // Write the databuffer to mem
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 2 | Initializing Databuffer", UVM_NONE)

    for (int q=0; q<16; q++) begin
      if (init_seq.is_q_cfgrd[q]) begin
        for (int i=0; i<pkt_num; i++) begin
          `uvm_create(write_dbuff)
            // Databuffer base address
            write_dbuff.addr = databuffer_mem_base_addr[q] + i*32'h0000_0080;
            // The length of the databuffer in bytes as previously specified
            write_dbuff.length = 64;
          `uvm_send(write_dbuff)
        end
      end
    end

    `ifndef CDN_DEMO_C
      //---------------------------------
      // Scoreboard Setup
      //---------------------------------

      // Configure Tx Scoreboard
      p_sequencer.p_env.gem_sb_tx.enable_fixed_sched_checks = 1;
      p_sequencer.p_env.gem_sb_tx.fixed_sched_pkt_num = '{16{1}};
      for (int q=0; q<16; q++) begin
        p_sequencer.p_env.gem_sb_tx.qptr_dbuff_mem_base_addr[q] = databuffer_mem_base_addr[q];
        p_sequencer.p_env.gem_sb_tx.qptr_dbuff_mem_size[q] = databuffer_mem_size[q];
        p_sequencer.p_env.gem_sb_tx.is_q_cfgrd[q] = init_seq.is_q_cfgrd[q];
      end

      // Disable Rx Scoreboard
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    //---------------------------------
    // Initialize Queue Pointers
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 3 | Initializing Queue Pointers", UVM_NONE)

    `uvm_create(prog_q)
      for (int q=0; q<16; q++) begin
        // Enable Queue. Note that enabling a queue which is not configured in
        // the design doesn't cause issues since the operations is guarded with
        // `defines inside the sequence.
        prog_q.is_q_enabled[q] = 1'b1;
        // Descriptor table base address to write the queue pointer
        prog_q.dtable_addr[q] = descriptor_mem_base_addr[q];
      end
    `uvm_send(prog_q)

    //---------------------------------
    // Start the Tx
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 4 | Starting Tx", UVM_NONE)

    `uvm_create(start_op)
      // Operating in Tx
      start_op.mode_tx = 1;
    `uvm_send(start_op)

    //---------------------------------
    // Check Transmit Status register
    //---------------------------------

    `uvm_info(get_type_name(), "TEST STEP 5 | Checking Registers And Ending Test", UVM_NONE)

    `uvm_create(check)
      // Operating in Tx
      check.mode_tx = 1;
      // Setting the timeout event
      check.max_reads = 300;
    `uvm_send(check)

    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uc_enet_tx_q_fixed_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UVM_REG_ALIASING_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uvm_reg_aliasing_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_aliasing_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 *
 * Class: cdn_gem_demo_uvm_reg_aliasing_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_aliasing_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 */
class cdn_gem_demo_uvm_reg_aliasing_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: aliasing_seq
   *
   * The Cadence UVM_REG built-in aliasing sequence.
   */
  uvm_reg_built_in_aliasing_seq aliasing_seq;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_uvm_reg_aliasing_seq)

  //---------------------------------
  // METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_aliasing_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_uvm_reg_aliasing_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the virtual sequence.
   * It just creates and sends the Cadence UVM_REG built-in aliasing sequence.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    `ifndef CDN_DEMO_C
      // Disable Tx Scoreboards
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Disable Rx Scoreboards
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    // Creating and starting reset sequence
    `uvm_info(get_type_name(), "TEST STEP 0 | Starting Registers Aliasing", UVM_LOW)
    aliasing_seq = new();
    aliasing_seq.model = p_sequencer.p_emac_regs0;
    aliasing_seq.start(p_sequencer.apb_reg_sequencer);

    #10us;
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uvm_reg_aliasing_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UVM_REG_BIT_BASH_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uvm_reg_bit_bash_seq
 *
 * This is the cdn_gem_demo_uvm_reg_bit_bash_seq sequence.
 * It extends from a default UVM_REG sequence.
 *
 * Class: cdn_gem_demo_uvm_reg_bit_bash_seq
 *
 * This is the cdn_gem_demo_uvm_reg_bit_bash_seq sequence.
 * It extends from a default UVM_REG sequence.
 */
class cdn_gem_demo_uvm_reg_bit_bash_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: bit_bash_seq
   *
   * The default UVM_REG bit-bash sequence.
   */
  uvm_reg_bit_bash_seq bit_bash_seq;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_uvm_reg_bit_bash_seq)

  //---------------------------------
  // METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_bit_bash_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_uvm_reg_bit_bash_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the virtual sequence.
   * It just creates and sends the default UVM_REG bit-bash sequence.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    `ifndef CDN_DEMO_C
      // Disable Tx Scoreboards
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Disable Rx Scoreboards
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    // These registers are excluded as they are known to cross clock domains -
    // this means that the register value is not stored quickly enough to be
    // read back.
    `ifdef gem_tsu
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.tsu_timer_msb_sec.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.tsu_timer_sec.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.tsu_timer_nsec.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
    `endif
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.tx_lpi_time.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.tx_lpi.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      `ifndef gem_no_pcs
        uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.pcs_control.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      `endif
    `ifdef gem_has_802p3_br
      `ifdef gem_tsu
        uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.emac_tsu_timer_msb_sec.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
        uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.emac_tsu_timer_sec.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
        uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.emac_tsu_timer_nsec.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      `endif
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.emac_tx_lpi.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.emac_tx_lpi_time.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);

      // Writes to other register bits in the test will cause the status
      // register to change value - this reports the status of an internal state
      // machine. Excluded from test.
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.mmsl_status.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);

      // This causes verif packets to be transmitted from the DUT. This is well
      // used within the env, so low risk to remove from the bit bash test
      // (reset value test still performed). Some progress has been made in
      // disabling VIP checks, but not quite ready.
      uvm_resource_db#(bit)::set({"REG::", p_sequencer.p_emac_regs0.__ALL__.mmsl_control.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
    `endif

    // Creating and starting reset sequence
    `uvm_info(get_type_name(), "TEST STEP 0 | Starting Registers Bit-Bash", UVM_LOW)
    bit_bash_seq = new();
    bit_bash_seq.model = p_sequencer.p_emac_regs0;
    bit_bash_seq.start(p_sequencer.apb_reg_sequencer);

    #10us;
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uvm_reg_bit_bash_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UVM_REG_READ_ALL_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uvm_reg_read_all_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_read_all_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 *
 * Class: cdn_gem_demo_uvm_reg_read_all_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_read_all_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 */
class cdn_gem_demo_uvm_reg_read_all_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: read_all_seq
   *
   * The Cadence UVM_REG built-in read all sequence.
   */
  uvm_reg_built_in_read_all_regs_seq read_all_seq;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_uvm_reg_read_all_seq)

  //---------------------------------
  // METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_read_all_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_uvm_reg_read_all_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the virtual sequence.
   * It just creates and sends the Cadence UVM_REG built-in read all sequence.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    `ifndef CDN_DEMO_C
      // Disable Tx Scoreboards
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Disable Rx Scoreboards
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    // Creating and starting reset sequence
    `uvm_info(get_type_name(), "TEST STEP 0 | Starting Registers Read All", UVM_LOW)
    read_all_seq = new();
    read_all_seq.model = p_sequencer.p_emac_regs0;
    read_all_seq.start(p_sequencer.apb_reg_sequencer);

    #10us;
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uvm_reg_read_all_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UVM_REG_RESET_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uvm_reg_reset_seq
 *
 * This is the cdn_gem_demo_uvm_reg_reset_seq sequence.
 * It extends from a default UVM_REG sequence.
 *
 * Class: cdn_gem_demo_uvm_reg_reset_seq
 *
 * This is the cdn_gem_demo_uvm_reg_reset_seq sequence.
 * It extends from a default UVM_REG sequence.
 */
class cdn_gem_demo_uvm_reg_reset_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * reset_seq
   *
   * The default UVM_REG reset sequence.
   */
  uvm_reg_hw_reset_seq reset_seq;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_uvm_reg_reset_seq)

  //---------------------------------
  // METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_reset_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_uvm_reg_reset_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the virtual sequence.
   * It just creates and sends the default UVM_REG reset sequence.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    `ifndef CDN_DEMO_C
      // Disable Tx Scoreboards
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Disable Rx Scoreboards
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    // Creating and starting reset sequence
    `uvm_info(get_type_name(), "TEST STEP 0 | Starting Registers Reset", UVM_LOW)
    reset_seq = new();
    reset_seq.model = p_sequencer.p_emac_regs0;
    reset_seq.start(p_sequencer.apb_reg_sequencer);

    #10us;
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uvm_reg_reset_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UVM_REG_WRITE_ALL_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uvm_reg_write_all_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_write_all_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 *
 * Class: cdn_gem_demo_uvm_reg_write_all_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_write_all_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 */
class cdn_gem_demo_uvm_reg_write_all_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: write_all_seq
   *
   * The Cadence UVM_REG built-in write all sequence.
   */
  uvm_reg_built_in_write_all_regs_seq write_all_seq;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_uvm_reg_write_all_seq)

  //---------------------------------
  // METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_write_all_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_uvm_reg_write_all_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the virtual sequence.
   * It just creates and sends the Cadence UVM_REG built-in write all sequence.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    `ifndef CDN_DEMO_C
      // Disable Tx Scoreboards
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Disable Rx Scoreboards
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    // Creating and starting reset sequence
    `uvm_info(get_type_name(), "TEST STEP 0 | Starting Registers Write All", UVM_LOW)
    write_all_seq = new();
    write_all_seq.model = p_sequencer.p_emac_regs0;
    write_all_seq.start(p_sequencer.apb_reg_sequencer);

    #10us;
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uvm_reg_write_all_seq

//----------------------------------------------------------------------------
// CDN_GEM_DEMO_UVM_REG_WRITE_FOLLOW_READ_SEQ
//----------------------------------------------------------------------------

/*
 * sequence_description: cdn_gem_demo_uvm_reg_write_follow_read_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_write_follow_read_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 *
 * Class: cdn_gem_demo_uvm_reg_write_follow_read_seq
 *
 * This is the the cdn_gem_demo_uvm_reg_write_follow_read_seq sequence.
 * It extends from a Cadence UVM_REG built-in sequence.
 */
class cdn_gem_demo_uvm_reg_write_follow_read_seq extends cdn_gem_demo_test_base_virtual_seq;

  //---------------------------------
  // CONTROL MEMBER VARIABLES
  //---------------------------------

  /*
   * Variable: wr_follow_rd_seq
   *
   * The Cadence UVM_REG built-in write follow read sequence.
   */
  uvm_reg_built_in_wr_follow_rd_seq wr_follow_rd_seq;

  //---------------------------------
  // UVM AUTOMATION MACROS
  //---------------------------------

  `uvm_object_utils(cdn_gem_demo_uvm_reg_write_follow_read_seq)

  //---------------------------------
  // METHODS
  //---------------------------------

  /*
   * Constructor: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_uvm_reg_write_follow_read_seq objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   */
  function new(string name="cdn_gem_demo_uvm_reg_write_follow_read_seq");
    super.new(name);
  endfunction

  /*
   * Method: body
   *
   * The body of the virtual sequence.
   * It just creates and sends the Cadence UVM_REG buil-in write follow read
   * sequence.
   */
  virtual task body();
    super.body();
    `uvm_info(get_type_name(), $psprintf("Starting %s sequence", get_type_name()), UVM_LOW)

    `ifndef CDN_DEMO_C
      // Disable Tx Scoreboards
      p_sequencer.p_env.gem_sb_tx.enable_checks = 0;

      // Disable Rx Scoreboards
      p_sequencer.p_env.gem_sb_rx.enable_checks = 0;
    `endif

    // Creating and starting reset sequence
    `uvm_info(get_type_name(), "TEST STEP 0 | Starting Registers Write Follow Read", UVM_LOW)
    wr_follow_rd_seq = new();
    wr_follow_rd_seq.model = p_sequencer.p_emac_regs0;
    wr_follow_rd_seq.start(p_sequencer.apb_reg_sequencer);

    #10us;
    `uvm_info(get_type_name(), $psprintf("Ending %s sequence", get_type_name()), UVM_LOW)
  endtask : body

endclass : cdn_gem_demo_uvm_reg_write_follow_read_seq

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
