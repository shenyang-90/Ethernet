//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This file contains the demo_tb protocol-specific UVM environment.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_env.sv
 *
 * This file contains the demo_tb protocol-specific UVM environment.
 */

`ifndef CDN_GEM_DEMO_ENV_SV
  `define CDN_GEM_DEMO_ENV_SV

/*
 * Class: cdn_gem_demo_env
 *
 * This is the demo_tb protocol-specific UVM environment.
 * It contains configurations and instances of:-
 * - GEM scoreboard (Tx and Rx).
 * - ENET VIP env (Tx and Rx).
 * - GEM UVC env.
 * - Protocol-specific system bus memory adapter.
 */
class cdn_gem_demo_env extends cdn_demo_env;

  //------------------------------------------------------------------------
  // MEMBER VARIABLES.
  //------------------------------------------------------------------------

  /*
   * Variable: p_config_object
   *
   * A pointer to the cdn_demo_config_object to enable hierarchical access.
   */
  cdn_gem_demo_config_object p_config_object;

  //------------------------------------------------------------------------
  // COMPONENTS.
  //------------------------------------------------------------------------

  /*
   * Variable: p_virtual_sequencer
   *
   * A pointer to the cdn_demo virtual sequencer to enable hierarchical access.
   */
  cdn_gem_demo_virtual_sequencer p_virtual_sequencer;

  /*
   * Variable: interface_adapter
   *
   * An instance of the interface adapter.
   */
  cdn_gem_demo_interface_adapter interface_adapter;

  `ifndef CDN_DEMO_C
    /*
     * Variable: gem_sb_rx
     *
     * An instance of the GEM Scoreboard for the Rx path.
     */
    cdn_gem_demo_sb gem_sb_rx;

    /*
     * Variable: gem_sb_tx
     *
     * An instance of the GEM Scoreboard for the Tx path.
     */
    cdn_gem_demo_sb gem_sb_tx;
  `endif

  //------------------------------------------------------------------------
  // UVC ENVS.
  //------------------------------------------------------------------------

  /*
   * Variable: enet_env_tx
   *
   * An instance of the cdn_enet_vip UVC env for the Tx path.
   */
  cdn_enet_vip_env enet_env_tx;

  /*
   * Variable: enet_env_rx
   *
   * An instance of the cdn_enet_vip UVC env for the Rx path.
   */
  cdn_enet_vip_env enet_env_rx;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  // The component utils macro provides base virtual methods like
  // get_type_name and create.
  `uvm_component_utils_begin(cdn_gem_demo_env)
    `uvm_field_object(p_config_object, UVM_DEFAULT)
  `uvm_component_utils_end

  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_gem_demo_env objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Method: build_phase
   *
   * This UVM phase is used for building the testbench component hierarchy.
   * For cdn_gem_demo_env, it applies configurations and creates needed
   * protocol-specific components and UVCs.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //----------------------------------
    // Cast Pointers to cdn_demo UVC
    //----------------------------------

    // Config Object
    if (!$cast(p_config_object, super.config_object))
      `uvm_fatal(get_type_name(), "Cast of p_config_object has not worked")
    // Virtual Sequencer
    if (!$cast(p_virtual_sequencer, uvm_top.find("*virtual_sequencer")))
      `uvm_fatal(get_type_name(), "Cast of p_virtual_sequencer has not worked")

    //----------------------------------
    // Clock UVCs
    //----------------------------------
    // NOTE: configuration here just extends that in the cdn_demo env. In
    // addition, the clk_ref is set in the cdn_gem_demo_config_object.
    //
    // The frequency of the clock is evaluated as:
    //
    //   f = (1000 ps / clk_ref) * 1 / clk_div
    //
    // There are 10 clock signals in each agent (env). Each one is associated
    // with the same clk_ref and has a specific clk_div (clk_div0-9). For each
    // clock signal the absolute delay (in ps) can be configured (clk_del0-9).
    // Default are:
    //
    //   clk_ref    = 1000 (ps)
    //   clk_del0-9 = 0    (ps)
    //   clk_div0-9 = 1000
    //
    // Override accordingly based on your needs as show below.
    // More than one agent (env) is provided to add support for different
    // reference periods (they are not necessarily used).
    //----------------------------------

    clock_env0.clk_div1 = 1;
    clock_env0.clk_div2 = 1;
    clock_env0.clk_div3 = 1;
    clock_env0.clk_div4 = 1;
    clock_env0.clk_div5 = 1;
    clock_env0.clk_del2 = 1000;
    clock_env0.clk_del3 = 1000;
    clock_env0.clk_del4 = 2000;
    clock_env0.clk_del5 = 2000;

    //----------------------------------
    // cdn_enet_vip UVC Tx env
    //----------------------------------

    // TODO: Config Env - check why the uvm_config_db doesn't work in this
    //       case. Setting config directly as a shorthand.
    //uvm_config_db#(enet_passive_active_enum)::set(this, "enet_env_tx", "env_mode", ENET_PASSIVE);
    //uvm_config_db#(enet_passive_phy_mac_enum)::set(this, "enet_env_tx", "passive_breed", ENET_PASSIVE_PHY);
    // Create Tx cdn_enet_vip UVC env
    enet_env_tx = cdn_enet_vip_env::type_id::create("enet_env_tx", this);
    // Applying configuration
    enet_env_tx.env_mode = ENET_PASSIVE;
    enet_env_tx.passive_breed = ENET_PASSIVE_PHY;
    `ifdef gem_use_rgmii
      enet_env_tx.interface_type = RGMII;
    `else
      enet_env_tx.interface_type = GMII;
    `endif

    //----------------------------------
    // cdn_enet_vip UVC Rx env
    //----------------------------------

    // TODO: Config Env - check why the uvm_config_db doesn't work in this
    //       case. Setting config directly as a shorthand.
    //uvm_config_db#(enet_passive_active_enum)::set(this, "enet_env_rx", "env_mode", ENET_ACTIVE);
    //uvm_config_db#(enet_passive_phy_mac_enum)::set(this, "enet_env_rx", "passive_breed", ENET_PASSIVE_MAC);
    //uvm_config_db#(enet_active_phy_mac_enum)::set(this, "enet_env_rx", "active_breed", ENET_ACTIVE_PHY);
    // Create Rx cdn_enet_vip UVC env
    enet_env_rx = cdn_enet_vip_env::type_id::create("enet_env_rx", this);
    // Applying configuration
    enet_env_rx.env_mode = ENET_ACTIVE;
    enet_env_rx.passive_breed = ENET_PASSIVE_MAC;
    enet_env_rx.active_breed = ENET_ACTIVE_PHY;
    `ifdef gem_use_rgmii
      enet_env_rx.interface_type = RGMII;
    `else
      enet_env_rx.interface_type = GMII;
    `endif

    //----------------------------------
    // Interface adapter
    //----------------------------------

    // Create the interface adapter
    interface_adapter = cdn_gem_demo_interface_adapter::type_id::create("interface_adapter", this);

    //----------------------------------
    // Scoreboards
    //----------------------------------

    // Creating scoreboards
    `ifndef CDN_DEMO_C
      gem_sb_tx = cdn_gem_demo_sb::type_id::create("gem_sb_tx", this);
      gem_sb_rx = cdn_gem_demo_sb::type_id::create("gem_sb_rx", this);
      gem_sb_rx.is_path_tx = 0;
    `endif
  endfunction : build_phase

  /*
   * Method: connect_phase
   *
   * This UVM phase is used for making connections between components in the
   * hierarchy.
   * For the cdn_gem_demo_env, it enables AXI VIP callbacks and connects the
   * virtual sequencer, adapters and scoreboards.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    `ifndef CDN_DEMO_C
      //----------------------------------
      // Scoreboard Tx
      //----------------------------------
      // PORT: AXI/ENET envs <--> IMP: Tx scoreboard
      //----------------------------------

      enet_env_rx.active_phy.monitor.TxUserQueueExitTransportPktCbPort.connect(gem_sb_tx.sb_enet_transport);
      enet_env_rx.active_phy.monitor.TxUserQueueExitNetworkPktCbPort.connect(gem_sb_tx.sb_enet_network);
      enet_env_tx.passive_phy.monitor.RxPktEndedPktCbPort.connect(gem_sb_tx.sb_interface);
      axi_env.active_slave.monitor.EndedTransferCbPort.connect(gem_sb_tx.sb_sys_bus_mem);

      //----------------------------------
      // Scoreboard Rx
      //----------------------------------
      // PORT: AXI/ENET envs <--> IMP: Rx scoreboard
      //----------------------------------

      enet_env_rx.active_phy.monitor.TxUserQueueExitTransportPktCbPort.connect(gem_sb_rx.sb_enet_transport);
      enet_env_rx.active_phy.monitor.TxUserQueueExitNetworkPktCbPort.connect(gem_sb_rx.sb_enet_network);
      enet_env_rx.active_phy.monitor.TxPktEndedPktCbPort.connect(gem_sb_rx.sb_interface);
      axi_env.active_slave.monitor.EndedTransferCbPort.connect(gem_sb_rx.sb_sys_bus_mem);
    `endif

    //----------------------------------
    // Virtual Sequencer
    //----------------------------------

    if(is_active == UVM_ACTIVE) begin
      // Connect cdn_enet_vip Rx active_phy sequencer
      if (!$cast(p_virtual_sequencer.enet_seqr, enet_env_rx.active_phy.sequencer))
        `uvm_fatal(get_type_name(), "Cast of p_virtual_sequencer.enet_seqr has not worked")
      // Connect env pointer
      if (!$cast(p_virtual_sequencer.p_env, this))
        `uvm_fatal(get_type_name(), "Cast of p_virtual_sequencer.p_env has not worked")
    end
  endfunction : connect_phase

  /*
   * Method: check_phase
   *
   * This UVM phase processes and checks the simulation results.
   * It converts PureSpec *Denali* Error into UVM_ERROR if enabled in the
   * configuration object.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void check_phase (uvm_phase phase);
    super.check_phase(phase);
    // Checks that there are no PureSuite Denali Errors
    `uvm_info(get_type_name(),
      $psprintf("ps_error_count = %0d", misc_signals_driver.misc_signals_if.ps_error_count),
      UVM_DEBUG)
    if (misc_signals_driver.misc_signals_if.ps_error_count != 0 && p_config_object.denali_error_check_en == 1) begin
      `uvm_error(get_type_name(),
        $sformatf("Occurred %0d *Denali* Errors", misc_signals_driver.misc_signals_if.ps_error_count))
    end
  endfunction : check_phase

endclass : cdn_gem_demo_env

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
