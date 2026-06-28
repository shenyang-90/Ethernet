/**************************************************************************
 File name    : cdn_enet_vip_env.sv
 Title        : User Env
 Project      : Ethernet
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This class is extended from uvm_env.
                Purpose of this class is to create required agent instance 
                (active or passive).
                As well it set callback for respective agents.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_env.sv
 * 
 * This file contains the ENET VIP UVM environment.
 */

`ifndef CDN_ENET_UVM_USER_ENV_SV
`define CDN_ENET_UVM_USER_ENV_SV

/*
 * Class: cdn_enet_vip_env
 * 
 * This is the ENET VIP UVM environment.
 * It can instantiate active/passive PHY/MAC upon proper settings of the
 * configuration fields.
 * Details in the build_phase description.
 */
class cdn_enet_vip_env extends uvm_env;

  // ***************************************************************
  // CONTROL FIELDS
  // ***************************************************************

  /*
   * Variable: env_mode
   * 
   * Controls if the ENET ENV has an active agent in addition to the
   * passive one (default).
   */
  enet_passive_active_enum env_mode = ENET_PASSIVE;

  /*
   * Variable: passive_breed
   * 
   * Controls if the passive agent is PHY or MAC.
   */
  enet_passive_phy_mac_enum passive_breed = ENET_PASSIVE_MAC;

  /*
   * Variable: active_breed
   * 
   * Controls if the active agent is PHY or MAC.
   */
  enet_active_phy_mac_enum active_breed = ENET_ACTIVE_PHY;

  /*
   * Variable: interface_type
   * 
   * Controls the interface type.
   */
  enet_interface_type_enum interface_type = GMII;

  // ***************************************************************
  // UVM AGENTS
  // ***************************************************************

  /*
   * Variable: active_phy
   * 
   * An instance of the active PHY agent.
   */
  cdn_enet_vip_agent active_phy;
  
  /*
   * Variable: active_mac
   * 
   * An instance of the active MAC agent.
   */    
  cdn_enet_vip_agent active_mac;

  /*
   * Variable: passive_phy
   * 
   * An instance of the passive PHY agent.
   */
  cdn_enet_vip_agent passive_phy;
  
  /*
   * Variable: passive_MAC
   * 
   * An instance of the passive MAC agent.
   */
  cdn_enet_vip_agent passive_mac;

  // ***************************************************************
  // UVM AUTOMATION MACROS
  // ***************************************************************

  // TODO check why there are problems in the uvm_conifg_db for these fields in 
  // the cdn_gem_module_tb
  `uvm_component_utils_begin(cdn_enet_vip_env)
    `uvm_field_enum(enet_passive_active_enum, env_mode, UVM_ALL_ON)
    `uvm_field_enum(enet_passive_phy_mac_enum, passive_breed, UVM_ALL_ON)
    `uvm_field_enum(enet_active_phy_mac_enum, active_breed, UVM_ALL_ON)
  `uvm_component_utils_end

  // ***************************************************************
  // EXTEND OR OVERRIDE BASE METHODS
  // ***************************************************************

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_env objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_enet_vip_env", uvm_component parent = null);
    super.new(name, parent);
    set_type_override_by_type(cdnEnetUvmSequencer::get_type(),cdn_enet_vip_sequencer::get_type());
    set_type_override_by_type(cdnEnetUvmDriver::get_type(),cdn_enet_vip_driver::get_type());
    set_type_override_by_type(cdnEnetUvmInstance::get_type(),cdn_enet_vip_instance::get_type());
    set_type_override_by_type(cdnEnetUvmMonitor::get_type(),cdn_enet_vip_monitor::get_type());    
  endfunction : new

  /*
   * Method: build_phase
   * 
   * This UVM phase is used for building the testbench component hierarchy.
   * For the cdn_enet_vip_env, it creates agents and applies configuration
   * for each.
   * By default a passive agent is created (env_mode = ENET_PASSIVE).
   * Its type (MAC or PHY) is configured by the passive_breed control.
   * If the env_mode is ENET_ACTIVE, then also an active agent is created.
   * Its type (MAC or PHY) is configured by the active_breed control.
   *  
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), $psprintf("env_mode      | %s", env_mode.name()), UVM_DEBUG);
    `uvm_info(get_type_name(), $psprintf("passive_breed | %s", passive_breed.name()), UVM_DEBUG);
    `uvm_info(get_type_name(), $psprintf("active_breed  | %s", active_breed.name()), UVM_DEBUG);
    // Default is passive agent
    if (passive_breed == ENET_PASSIVE_MAC) begin // PASSIVE MAC
      `uvm_info(get_type_name(), $psprintf("I'm inside ENET_PASSIVE_MAC"), UVM_DEBUG);
      passive_mac = cdn_enet_vip_agent::type_id::create("passive_mac", this);
      begin
        cdn_enet_vip_config cfg = cdn_enet_vip_config::type_id::create("passive_macCfg");
        cfg.is_active = UVM_PASSIVE;
        cfg.agent_kind = CDN_ENET_CFG_AGENT_KIND_MAC;
        cfg.pause_enable = 0;
        cfg.link_timer_count = 0;
        cfg.mr_adv_ability = 0;
        cfg.cg_100gbaser_training_attempt = 0;
        cfg.tx_collector_enable = 1;
        cfg.rx_collector_enable = 1;
        if (interface_type == GMII) begin
          cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_GMII;
        end else begin
          cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_RGMII;
        end        
        set_config_object("passive_mac","cfg",cfg);
      end          
    end else begin // PASSIVE PHY
      `uvm_info(get_type_name(), $psprintf("I'm inside ENET_PASSIVE_PHY"), UVM_DEBUG);
      passive_phy = cdn_enet_vip_agent::type_id::create("passive_phy", this);
      begin
        cdn_enet_vip_config cfg = cdn_enet_vip_config::type_id::create("passive_phyCfg");
        cfg.is_active = UVM_PASSIVE;
        cfg.agent_kind = CDN_ENET_CFG_AGENT_KIND_PHY;
        cfg.pause_enable = 0;
        cfg.link_timer_count = 0;
        cfg.mr_adv_ability = 0;
        cfg.cg_100gbaser_training_attempt = 0;
        cfg.tx_collector_enable = 1;
        cfg.rx_collector_enable = 0;
        if (interface_type == GMII) begin
          cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_GMII;
        end else begin
          cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_RGMII;
          // Make it read on posedge of the provided clock
          cfg.rgmii_delayed_clock_data_collect = 1;
        end        
        set_config_object("passive_phy","cfg",cfg);
      end          
    end
    // Add active agent in the case
    if (env_mode == ENET_ACTIVE) begin
      `uvm_info(get_type_name(), $psprintf("I'm inside ENET_ACTIVE"), UVM_DEBUG);
      if (active_breed == ENET_ACTIVE_MAC) begin // ACTIVE MAC
        `uvm_info(get_type_name(), $psprintf("I'm inside ENET_ACTIVE_MAC"), UVM_DEBUG);
        active_mac = cdn_enet_vip_agent::type_id::create("active_mac", this);
        begin
          cdn_enet_vip_config cfg = cdn_enet_vip_config::type_id::create("active_macCfg");
          cfg.is_active = UVM_ACTIVE;
          cfg.agent_kind = CDN_ENET_CFG_AGENT_KIND_MAC;
          cfg.pause_enable = 1;
          cfg.link_timer_count = 100;
          cfg.mr_adv_ability = 224;
          cfg.cg_100gbaser_training_attempt = 3;
          cfg.tx_collector_enable = 0;
          cfg.rx_collector_enable = 1;
          if (interface_type == GMII) begin
            cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_GMII;
          end else begin
            cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_RGMII;
          end          
          set_config_object("active_mac","cfg",cfg);
        end            
      end else begin // ACTIVE PHY
        `uvm_info(get_type_name(), $psprintf("I'm inside ENET_ACTIVE_PHY"), UVM_DEBUG);
        active_phy = cdn_enet_vip_agent::type_id::create("active_phy", this);
        begin
          cdn_enet_vip_active_phy_config cfg = cdn_enet_vip_active_phy_config::type_id::create("active_phyCfg");
          cfg.is_active = UVM_ACTIVE;
          cfg.agent_kind = CDN_ENET_CFG_AGENT_KIND_PHY;
          cfg.pause_enable = 1;
          cfg.link_timer_count = 100;
          cfg.mr_adv_ability = 224;
          cfg.cg_100gbaser_training_attempt = 3;
          cfg.tx_collector_enable = 1;
          cfg.rx_collector_enable = 0;
          if (interface_type == GMII) begin
            cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_GMII;
          end else begin
            cfg.interface_kind = CDN_ENET_CFG_INTERFACE_KIND_RGMII;
            // Make it drive on posedge of the provided clock
            cfg.rgmii_drive_bw_fall_rise = 0;
            // Make it read on posedge of the provided clock
            cfg.rgmii_delayed_clock_data_collect = 1;
          end             
          set_config_object("active_phy","cfg",cfg);
        end            
      end
    end
  endfunction : build_phase

  /*
   * Method: connect_phase
   * 
   * This UVM phase is used for making connections between components in the
   * hierarchy.
   * 
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  function void connect_phase(uvm_phase phase);
    // Call the corrsponding method in the parent class.
    super.connect_phase(phase);
    //active_mac.PartnerRxPacketEndedEvent = active_phy.monitor.RxPktEndedPktCbEvent;
    //active_phy.PartnerRxPacketEndedEvent = active_mac.monitor.RxPktEndedPktCbEvent;
  endfunction : connect_phase

  /*
   * Method: end_of_elaboration_phase
   * 
   * This UVM phase is related to post-elaboration activities.
   * For the cdn_enet_vip_env, it enables all required callbacks on a 
   * per-instance basis.
   * 
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "Setting callbacks", UVM_DEBUG);
    // Enable PureSpec callbacks. Comment / Uncomment as necessary
    if (passive_breed == ENET_PASSIVE_MAC) begin // PASSIVE MAC
      //void'(passive_mac.inst.setCallback( DENALI_ENET_CB_Error));
      void'(passive_mac.inst.setCallback( DENALI_ENET_CB_RxPktEndedPkt));
      //void'(passive_mac.inst.setCallback( DENALI_ENET_CB_RxPktEndedMgmtPkt));
      void'(passive_mac.inst.setCallback( DENALI_ENET_CB_ResetAsserted));
      void'(passive_mac.inst.setCallback( DENALI_ENET_CB_ResetDeasserted));
      //void'(passive_mac.inst.setCallback( DENALI_ENET_CB_AlignStatusUp));
      //void'(passive_mac.inst.setCallback(DENALI_ENET_CB_AlignStatusDown));
    end else begin // PASSIVE PHY
      //void'(passive_phy.inst.setCallback( DENALI_ENET_CB_Error));
      void'(passive_phy.inst.setCallback( DENALI_ENET_CB_RxPktEndedPkt));
      //void'(passive_phy.inst.setCallback( DENALI_ENET_CB_RxPktEndedMgmtPkt));
      void'(passive_phy.inst.setCallback( DENALI_ENET_CB_ResetAsserted));
      void'(passive_phy.inst.setCallback( DENALI_ENET_CB_ResetDeasserted));
      //void'(passive_phy.inst.setCallback( DENALI_ENET_CB_AlignStatusUp));
      //void'(passive_phy.inst.setCallback(DENALI_ENET_CB_AlignStatusDown));
    end
    if (env_mode == ENET_ACTIVE) begin
      if (active_breed == ENET_ACTIVE_MAC) begin // ACTIVE MAC
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_Error));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitPkt));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxPktStartedPkt));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxPktEndedPkt));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_RxPktEndedPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitMgmtPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxPktStartedMgmtPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitMgmtPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxPktStartedMgmtPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxPktEndedMgmtPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_RxPktEndedMgmtPkt));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitTransportPkt));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitNetworkPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitMplsPkt));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitSnapPkt));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_ResetAsserted));
        void'(active_mac.inst.setCallback( DENALI_ENET_CB_ResetDeasserted));
        //void'(active_mac.inst.setCallback( DENALI_ENET_CB_AlignStatusUp));
        //void'(active_mac.inst.setCallback(DENALI_ENET_CB_AlignStatusDown));
      end else begin // ACTIVE PHY
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_Error));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitPkt));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxPktStartedPkt));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxPktEndedPkt));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_RxPktEndedPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitMgmtPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxPktStartedMgmtPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitMgmtPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxPktStartedMgmtPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxPktEndedMgmtPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_RxPktEndedMgmtPkt));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitTransportPkt));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitNetworkPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitMplsPkt));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_TxUserQueueExitSnapPkt));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_ResetAsserted));
        void'(active_phy.inst.setCallback( DENALI_ENET_CB_ResetDeasserted));
        //void'(active_phy.inst.setCallback( DENALI_ENET_CB_AlignStatusUp));
        //void'(active_phy.inst.setCallback(DENALI_ENET_CB_AlignStatusDown));
      end
    end
    `uvm_info(get_type_name(), "Setting callbacks ... DONE", UVM_DEBUG);
  endfunction : end_of_elaboration_phase

endclass : cdn_enet_vip_env

`endif // `ifndef CDN_ENET_UVM_USER_ENV_SV

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
