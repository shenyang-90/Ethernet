/**************************************************************************
 File name    : cdn_enet_vip_conifg.sv
 Title        : Configuration
 Project      : Ethernet 
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This file contains classes for the ENET VIP configuration.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_config.sv
 * 
 * This file contains the ENET VIP configuration user class.
 */

`ifndef CDN_ENET_VIP_CFG_SV
`define CDN_ENET_VIP_CFG_SV

/*
 * Class: cdn_enet_vip_config
 * 
 * This is the ENET VIP configuration user class.
 */
class cdn_enet_vip_config extends cdnEnetUvmConfig;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  `uvm_object_utils(cdn_enet_vip_config)

  //------------------------------------------------------------------------
  // CONSTRUCTOR.
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_config objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   */
  function new(string name = "cdn_enet_vip_cfg");
    super.new(name);
    
    //--------------------
    // Set feature values
    //--------------------
    
    //is_active                                = UVM_ACTIVE;
    duplex_kind                              = CDN_ENET_CFG_DUPLEX_KIND_FULL;
    ptp_mode                                 = CDN_ENET_CFG_PTP_MODE_IEEE_1588;
    ptp_version                              = CDN_ENET_CFG_PTP_VERSION_PTP_V2;
    interface_kind                           = CDN_ENET_CFG_INTERFACE_KIND_GMII;
    speed_mode                               = CDN_ENET_CFG_SPEED_MODE_SPEED_MODE_1GBPS;
    agent_kind                               = CDN_ENET_CFG_AGENT_KIND_PHY;
    sub_layer_kind                           = CDN_ENET_CFG_SUB_LAYER_KIND_PMA_LAYER;
    station_kind                             = CDN_ENET_CFG_STATION_KIND_TX_STATION;
    interface_width                          = CDN_ENET_CFG_INTERFACE_WIDTH_SERIAL_BUS_WIDTH_INTERFACE;
    scbd_config                              = CDN_ENET_CFG_SCBD_CONFIG_SINGLE_OR_MULTI_PORT;
    mgmt_clk_mode                            = CDN_ENET_CFG_MGMT_CLK_MODE_EXTERNAL_MDC;
    reset_through_pin                        = 0;
    cl73_mr_adv_ability                      = 16811009;
    cl73_mr_autoneg_enable                   = 1;
    has_reset                                = 1;
    active_high_reset                        = 1;
    clear_pkts_on_reset                      = 1;
    has_alignment                            = 1;
    do_bit_reverse_clause_51                 = 0;
    has_fec_layer                            = 0;
    mr_unidirectional_enable                 = 0;
    stop_clock_en                            = 0;
    lpi_clk_stop_delay                       = 128;
    signal_order_set_pattern                 = 0;
    reserved_sequence_order_set_pattern      = 0;
    has_scramble                             = 1;
    prbs_data_0_l_f                          = 1;
    prbs_seed_A                              = 1;
    prbs_seed_B                              = 2;
    test_pattern_error_en                    = 0;
    test_pattern_num_error                   = 1;
    test_pattern_error_high_index_val        = 3;
    has_prbs31_test_pattern_ability          = 0;
    prbs31_transmit_test_pattern_enable      = 0;
    prbs31_receive_test_pattern_enable       = 0;
    has_prbs9_test_pattern_ability           = 0;
    prbs9_receive_test_pattern_enable        = 0;
    prbs9_transmit_test_pattern_enable       = 0;
    has_prbs_test_pattern_ability            = 0;
    prbs_transmit_test_pattern_enable        = 0;
    prbs_receive_test_pattern_enable         = 0;
    device_address                           = 0;
    assign_dynamic_addr                      = 0;
    station_address                          = 0;
    retry_limit                              = 16;
    stop_retransmit_on_late_col              = 0;
    jam_length                               = 8;
    crs_active_in_full_duplex                = 0;
    //pause_enable                             = 1;
    pfc_pause_enable                         = 0;
    burst_mode_on                            = 0;
    sync_drive_enable                        = 0;
    fault_signaling_enable                   = 0;
    retransmission_enable                    = 0;
    //link_timer_count                         = 100;
    min_tag_framesize_64                     = 1;
    //mr_adv_ability                           = 224;
    mr_an_enable                             = 0;
    lane_pattern[4]                          = 0;
    lane_pattern[5]                          = 0;
    lane_pattern[6]                          = 0;
    lane_pattern[7]                          = 0;
    lane_pattern[8]                          = 0;
    lane_pattern[9]                          = 0;
    lane_pattern[10]                         = 0;
    lane_pattern[11]                         = 0;
    lane_pattern[12]                         = 0;
    lane_pattern[13]                         = 0;
    lane_pattern[14]                         = 0;
    lane_pattern[15]                         = 0;
    lane_pattern[16]                         = 0;
    lane_pattern[17]                         = 0;
    lane_pattern[18]                         = 0;
    lane_pattern[19]                         = 0;
    am_count                                 = 1200;
    wait_for_monitor_status_ok               = 1;
    has_custom_preamble                      = 0;
    custom_preamble_size                     = 0;
    use_custom_preamble_in_crc               = 0;
    use_sop_in_crc                           = 0;
    scoreboard_custom_preamble               = 0;
    has_custom_message                       = 0;
    custom_message_start_character           = 0;
    custom_message_size                      = 0;
    inter_custom_message_gap                 = 0;
    T_w_sys_rx                               = 400;
    T_w_sys_tx                               = 400;
    T_sl                                     = 0;
    T_ql                                     = 0;
    T_ul                                     = 0;
    T_wl                                     = 0;
    T_wl2                                    = 200;
    T_wtf                                    = 0;
    T_qr                                     = 0;
    T_wr                                     = 0;
    disable_fcs                              = 0;
    lpi_rx_clk_stp                           = 0;
    lpi_rx_clk_stp_clk_offset                = 10;
    lpi_tx_clk_stp                           = 0;
    lpi_tx_clk_stp_clk_offset                = 10;
    lpi_rx_clk_resume_offset                 = 0;
    lpi_tx_clk_resume_offset                 = 0;
    fec_enable                               = 1;
    slack_counter                            = 1;
    clock_health_mon_cnt                     = 5;
    injection_enable                         = 0;
    ref_time_out                             = 5;
    continuous_mon_clk_health                = 0;
    magic_pattern_ieee_addr_enable           = 0;
    magic_pattern_ieee_addr                  = 0;
    rgmii_drive_bw_fall_rise                 = 0;
    rgmii_delayed_clock_data_collect         = 0;
    custom_crc_enable                        = 0;
    number_of_xmii_ports                     = 4;
    mac_sec_enable                           = 0;
    mac_sec_vlan_tag_enable                  = 0;
    mac_sec_icv_length                       = 8;
    crc_length                               = 4;
    no_preamble                              = 0;
    disable_upper_layer_extraction           = 0;
    mr_training_enable                       = 1;
    proprietary_header_enable                = 0;
    proprietary_header_size                  = 12;
    proprietary_header_location              = 12;
    use_proprietary_header_in_crc            = 0;
    packet_tracker_enable                    = 0;
    LPI_FW                                   = 1;
    custom_vlan_enable                       = 0;
    num_of_custom_vlan_tag                   = 4;
    custom_vlan_size[0]                      = 4;
    custom_vlan_size[1]                      = 4;
    custom_vlan_size[2]                      = 4;
    custom_vlan_size[3]                      = 4;
    custom_vlan_size[4]                      = 4;
    custom_vlan_size[5]                      = 4;
    custom_vlan_size[6]                      = 4;
    custom_vlan_size[7]                      = 4;
    custom_vlan_id[0]                        = 33024;
    custom_vlan_id[1]                        = 33024;
    custom_vlan_id[2]                        = 33024;
    custom_vlan_id[3]                        = 33024;
    custom_vlan_id[4]                        = 33024;
    custom_vlan_id[5]                        = 33024;
    custom_vlan_id[6]                        = 33024;
    custom_vlan_id[7]                        = 33024;
    lane_wise_clock                          = 0;
    max_wait_time_divide_by                  = 1;
    wait_time                                = 100;
    frame_count_train_local                  = 0;
    training_attempt                         = 3;
    cg_100gbaser_mr_training_enable[0]       = 1;
    cg_100gbaser_mr_training_enable[1]       = 1;
    cg_100gbaser_mr_training_enable[2]       = 1;
    cg_100gbaser_mr_training_enable[3]       = 1;
    cg_100gbaser_mr_training_enable[4]       = 1;
    cg_100gbaser_mr_training_enable[5]       = 1;
    cg_100gbaser_mr_training_enable[6]       = 1;
    cg_100gbaser_mr_training_enable[7]       = 1;
    cg_100gbaser_mr_training_enable[8]       = 1;
    cg_100gbaser_mr_training_enable[9]       = 1;
    cg_100gbaser_mr_training_enable[10]      = 1;
    cg_100gbaser_mr_training_enable[11]      = 1;
    cg_100gbaser_mr_training_enable[12]      = 1;
    cg_100gbaser_mr_training_enable[13]      = 1;
    cg_100gbaser_mr_training_enable[14]      = 1;
    cg_100gbaser_mr_training_enable[15]      = 1;
    cg_100gbaser_mr_training_enable[16]      = 1;
    cg_100gbaser_mr_training_enable[17]      = 1;
    cg_100gbaser_mr_training_enable[18]      = 1;
    cg_100gbaser_mr_training_enable[19]      = 1;
    cg_100gbaser_max_wait_time_divide_by[0]  = 1;
    cg_100gbaser_max_wait_time_divide_by[1]  = 1;
    cg_100gbaser_max_wait_time_divide_by[2]  = 1;
    cg_100gbaser_max_wait_time_divide_by[3]  = 1;
    cg_100gbaser_max_wait_time_divide_by[4]  = 1;
    cg_100gbaser_max_wait_time_divide_by[5]  = 1;
    cg_100gbaser_max_wait_time_divide_by[6]  = 1;
    cg_100gbaser_max_wait_time_divide_by[7]  = 1;
    cg_100gbaser_max_wait_time_divide_by[8]  = 1;
    cg_100gbaser_max_wait_time_divide_by[9]  = 1;
    cg_100gbaser_max_wait_time_divide_by[10] = 1;
    cg_100gbaser_max_wait_time_divide_by[11] = 1;
    cg_100gbaser_max_wait_time_divide_by[12] = 1;
    cg_100gbaser_max_wait_time_divide_by[13] = 1;
    cg_100gbaser_max_wait_time_divide_by[14] = 1;
    cg_100gbaser_max_wait_time_divide_by[15] = 1;
    cg_100gbaser_max_wait_time_divide_by[16] = 1;
    cg_100gbaser_max_wait_time_divide_by[17] = 1;
    cg_100gbaser_max_wait_time_divide_by[18] = 1;
    cg_100gbaser_max_wait_time_divide_by[19] = 1;
    cg_100gbaser_tx_coeff_update[0]          = 0;
    cg_100gbaser_tx_coeff_update[1]          = 0;
    cg_100gbaser_tx_coeff_update[2]          = 0;
    cg_100gbaser_tx_coeff_update[3]          = 0;
    cg_100gbaser_tx_coeff_update[4]          = 0;
    cg_100gbaser_tx_coeff_update[5]          = 0;
    cg_100gbaser_tx_coeff_update[6]          = 0;
    cg_100gbaser_tx_coeff_update[7]          = 0;
    cg_100gbaser_tx_coeff_update[8]          = 0;
    cg_100gbaser_tx_coeff_update[9]          = 0;
    cg_100gbaser_tx_coeff_update[10]         = 0;
    cg_100gbaser_tx_coeff_update[11]         = 0;
    cg_100gbaser_tx_coeff_update[12]         = 0;
    cg_100gbaser_tx_coeff_update[13]         = 0;
    cg_100gbaser_tx_coeff_update[14]         = 0;
    cg_100gbaser_tx_coeff_update[15]         = 0;
    cg_100gbaser_tx_coeff_update[16]         = 0;
    cg_100gbaser_tx_coeff_update[17]         = 0;
    cg_100gbaser_tx_coeff_update[18]         = 0;
    cg_100gbaser_tx_coeff_update[19]         = 0;
    cg_100gbaser_pmd_lane_tx_coeff[0]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[1]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[2]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[3]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[4]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[5]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[6]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[7]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[8]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[9]        = 1;
    cg_100gbaser_pmd_lane_tx_coeff[10]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[11]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[12]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[13]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[14]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[15]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[16]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[17]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[18]       = 1;
    cg_100gbaser_pmd_lane_tx_coeff[19]       = 1;
    cg_100gbaser_wait_time[0]                = 100;
    cg_100gbaser_wait_time[1]                = 100;
    cg_100gbaser_wait_time[2]                = 100;
    cg_100gbaser_wait_time[3]                = 100;
    cg_100gbaser_wait_time[4]                = 100;
    cg_100gbaser_wait_time[5]                = 100;
    cg_100gbaser_wait_time[6]                = 100;
    cg_100gbaser_wait_time[7]                = 100;
    cg_100gbaser_wait_time[8]                = 100;
    cg_100gbaser_wait_time[9]                = 100;
    cg_100gbaser_wait_time[10]               = 100;
    cg_100gbaser_wait_time[11]               = 100;
    cg_100gbaser_wait_time[12]               = 100;
    cg_100gbaser_wait_time[13]               = 100;
    cg_100gbaser_wait_time[14]               = 100;
    cg_100gbaser_wait_time[15]               = 100;
    cg_100gbaser_wait_time[16]               = 100;
    cg_100gbaser_wait_time[17]               = 100;
    cg_100gbaser_wait_time[18]               = 100;
    cg_100gbaser_wait_time[19]               = 100;
    cg_100gbaser_frame_count_train_local[0]  = 0;
    cg_100gbaser_frame_count_train_local[1]  = 0;
    cg_100gbaser_frame_count_train_local[2]  = 0;
    cg_100gbaser_frame_count_train_local[3]  = 0;
    cg_100gbaser_frame_count_train_local[4]  = 0;
    cg_100gbaser_frame_count_train_local[5]  = 0;
    cg_100gbaser_frame_count_train_local[6]  = 0;
    cg_100gbaser_frame_count_train_local[7]  = 0;
    cg_100gbaser_frame_count_train_local[8]  = 0;
    cg_100gbaser_frame_count_train_local[9]  = 0;
    cg_100gbaser_frame_count_train_local[10] = 0;
    cg_100gbaser_frame_count_train_local[11] = 0;
    cg_100gbaser_frame_count_train_local[12] = 0;
    cg_100gbaser_frame_count_train_local[13] = 0;
    cg_100gbaser_frame_count_train_local[14] = 0;
    cg_100gbaser_frame_count_train_local[15] = 0;
    cg_100gbaser_frame_count_train_local[16] = 0;
    cg_100gbaser_frame_count_train_local[17] = 0;
    cg_100gbaser_frame_count_train_local[18] = 0;
    cg_100gbaser_frame_count_train_local[19] = 0;
    //cg_100gbaser_training_attempt            = 3;
    jam_pattern[0]                           = 242;
    jam_pattern[1]                           = 242;
    jam_pattern[2]                           = 242;
    jam_pattern[3]                           = 242;
    jam_pattern[4]                           = 242;
    jam_pattern[5]                           = 242;
    has_scoreboard                           = 1;
    has_mgmt                                 = 1;
    //has_EEE                                  = 1;
    has_pmd_training                         = 0;
    has_clk_data_recovery                    = 0;
    has_clock_health_monitor                 = 1;
    half_cycle_clock                         = 0;
    am_lane_order[0]                         = 64'd13959058155914098320;
    am_lane_order[1]                         = 64'd11248086481621140720;
    am_lane_order[2]                         = 64'd14728066256172967365;
    am_lane_order[3]                         = 64'd2865000050579044770;
    am_lane_order[4]                         = 0;
    am_lane_order[5]                         = 0;
    am_lane_order[6]                         = 0;
    am_lane_order[7]                         = 0;
    am_lane_order[8]                         = 0;
    am_lane_order[9]                         = 0;
    am_lane_order[10]                        = 0;
    am_lane_order[11]                        = 0;
    am_lane_order[12]                        = 0;
    am_lane_order[13]                        = 0;
    am_lane_order[14]                        = 0;
    am_lane_order[15]                        = 0;
    am_lane_order[16]                        = 0;
    am_lane_order[17]                        = 0;
    am_lane_order[18]                        = 0;
    am_lane_order[19]                        = 0;
    inject_skew[0]                           = 0;
    inject_skew[1]                           = 0;
    inject_skew[2]                           = 0;
    inject_skew[3]                           = 0;
    inject_skew[4]                           = 0;
    inject_skew[5]                           = 0;
    inject_skew[6]                           = 0;
    inject_skew[7]                           = 0;
    inject_skew[8]                           = 0;
    inject_skew[9]                           = 0;
    inject_skew[10]                          = 0;
    inject_skew[11]                          = 0;
    inject_skew[12]                          = 0;
    inject_skew[13]                          = 0;
    inject_skew[14]                          = 0;
    inject_skew[15]                          = 0;
    inject_skew[16]                          = 0;
    inject_skew[17]                          = 0;
    inject_skew[18]                          = 0;
    inject_skew[19]                          = 0;
    internal_signal_detect_toggle            = 0;
    FEC_Enable_Error_to_PCS                  = 1;
    FEC_Error_Indication_ability             = 1;
    pma_bus_width_one                        = 0;
    debug_enable                             = 0;
    high_perf_mode                           = 0;
    pfc_transmitted_delay                    = 6144;
    pfc_received_delay                       = 6144;
    macsec                                   = 0;
    has_cl73_an                              = 0;
    perform_cl73_an                          = 0;
    cl73_an_physical_link_number             = 0;
    multi_phyad_support                      = 0;
    valid_phyad                              = 0;
    CONTINUOUS_MDC                           = 1;
    enable_run_time_speed_change             = 0;
    cg_100gbaser_pma_mux_lanes               = 4;
    pma_lane_bus_width                       = 66;
    lane_pattern[0]                          = 64'd13959058155914098320;
    lane_pattern[1]                          = 64'd11248086481621140720;
    lane_pattern[2]                          = 64'd14728066256172967365;
    lane_pattern[3]                          = 64'd2865000050579044770;
    //tx_collector_enable                      = 0;
    //rx_collector_enable                      = 1;
    
    //--------------------
    // Set timing values
    //--------------------
    
    timings.mgmt_half_clk_time.set(200, CDN_VIP_NS, 1);
    timings.max_wait_timer.set(500, CDN_VIP_MS, 1);
    timings.rx_resolved_timer.set(400, CDN_VIP_US, 1);
    timings.tx_resolved_timer.set(400, CDN_VIP_US, 1);
    timings.rgmii_link_down_to_speed_change_timer.set(0, CDN_VIP_NS, 1);
    timings.rgmii_speed_change_to_link_up_timer.set(0, CDN_VIP_NS, 1);
    timings.rgmii_data_delay.set(0, CDN_VIP_NS, 1);
    //timings.static_skew.set(180, CDN_VIP_NS, 1);
    //timings.dynamic_skew.set(4, CDN_VIP_NS, 1);
  endfunction : new

endclass : cdn_enet_vip_config

/*
 * Class: cdn_enet_vip_active_phy_config
 * 
 * This is the ENET VIP configuration class specific for the active PHY agent.
 */
class cdn_enet_vip_active_phy_config extends cdn_enet_vip_config;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  `uvm_object_utils(cdn_enet_vip_active_phy_config)

  //------------------------------------------------------------------------
  // CONSTRUCTOR.
  //------------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_active_phy_config objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   */
  function new(string name = "cdn_enet_vip_active_phy_config");
    super.new(name);

    //--------------------
    // Set feature values
    //--------------------
    
    is_active                                = UVM_ACTIVE;
    fec_type                                 = CDN_ENET_CFG_FEC_TYPE_CLAUSE_74;
    pmd_training_type                        = CDN_ENET_CFG_PMD_TRAINING_TYPE_CLAUSE_72;
    speed_25GBPS_interface_kind              = CDN_ENET_CFG_SPEED_25GBPS_INTERFACE_KIND_NONE;
    has_prbs31_test_pattern_ability          = 1;
    has_prbs9_test_pattern_ability           = 1;    
    pause_enable                             = 0;
    tx_pause_enable                          = 0;
    rx_pause_enable                          = 0;
    link_timer_count                         = 100;
    mr_adv_ability                           = 224;
    differential_io_mode                     = 0;
    lane_pattern[4]                          = 64'd17651568511543740405;
    lane_pattern[5]                          = 64'd12627507462833050845;
    lane_pattern[6]                          = 64'd16922756520572504730;
    lane_pattern[7]                          = 64'd403558721925825915;
    lane_pattern[8]                          = 64'd2344646285840491680;
    lane_pattern[9]                          = 64'd14340647136578488680;
    lane_pattern[10]                         = 64'd2406772691409923325;
    lane_pattern[11]                         = 64'd5164061172753076665;
    lane_pattern[12]                         = 64'd3624630944447773020;
    lane_pattern[13]                         = 64'd6071423930659108890;
    lane_pattern[14]                         = 64'd5347242240849397635;
    lane_pattern[15]                         = 64'd1455447502970762805;
    lane_pattern[16]                         = 64'd14966532740290982340;
    lane_pattern[17]                         = 64'd14575945627049907885;
    lane_pattern[18]                         = 64'd10436416625839859295;
    lane_pattern[19]                         = 64'd1592602185410408640;
    T_al                                     = 1000;
    T_byp                                    = 200;
    magic_pattern_ieee_addr                  = 64'd1;
    cg_100gbaser_training_attempt            = 3;
    has_scoreboard                           = 0;
    has_mgmt                                 = 0;
    has_EEE                                  = 0;
    am_lane_order[4]                         = 64'd17651568511543740405;
    am_lane_order[5]                         = 64'd12627507462833050845;
    am_lane_order[6]                         = 64'd16922756520572504730;
    am_lane_order[7]                         = 64'd403558721925825915;
    am_lane_order[8]                         = 64'd2344646285840491680;
    am_lane_order[9]                         = 64'd14340647136578488680;
    am_lane_order[10]                        = 64'd2406772691409923325;
    am_lane_order[11]                        = 64'd5164061172753076665;
    am_lane_order[12]                        = 64'd3624630944447773020;
    am_lane_order[13]                        = 64'd6071423930659108890;
    am_lane_order[14]                        = 64'd5347242240849397635;
    am_lane_order[15]                        = 64'd1455447502970762805;
    am_lane_order[16]                        = 64'd14966532740290982340;
    am_lane_order[17]                        = 64'd14575945627049907885;
    am_lane_order[18]                        = 64'd10436416625839859295;
    am_lane_order[19]                        = 64'd1592602185410408640;
    hasValVri                                = 0;
    tx_collector_enable                      = 1;
    rx_collector_enable                      = 0;

    //--------------------
    // Set pin values
    //--------------------
    
    pins.mdio_io.size                                = 1;
    pins.rx0_i.size                                  = 1;
    pins.rx1_i.size                                  = 1;
    pins.rx2_i.size                                  = 1;
    pins.rx3_i.size                                  = 1;
    pins.tx0_i.size                                  = 1;
    pins.tx1_i.size                                  = 1;
    pins.tx2_i.size                                  = 1;
    pins.tx3_i.size                                  = 1;
    pins.mdc_i.size                                  = 1;
    pins.tx_clk.size                                 = 1;
    pins.rx_clk.size                                 = 1;
    pins.rxclk.size                                  = 1;
    pins.txclk.size                                  = 1;
    pins.rxclk_i.size                                = 1;
    pins.txclk_i.size                                = 1;
    pins.txdp_i.size                                 = 1;
    pins.txdn_i.size                                 = 1;
    pins.rxdp_o.size                                 = 1;
    pins.rxdn_o.size                                 = 1;
    pins.txdp_o.size                                 = 1;
    pins.txdn_o.size                                 = 1;
    pins.rxdp_i.size                                 = 1;
    pins.rxdn_i.size                                 = 1;
    pins.txp0_o.size                                 = 1;
    pins.txn0_o.size                                 = 1;
    pins.txp1_o.size                                 = 1;
    pins.txn1_o.size                                 = 1;
    pins.rxp0_o.size                                 = 1;
    pins.rxn0_o.size                                 = 1;
    pins.rxp1_o.size                                 = 1;
    pins.rxn1_o.size                                 = 1;
    pins.rxp0_i.size                                 = 1;
    pins.rxn0_i.size                                 = 1;
    pins.rxp1_i.size                                 = 1;
    pins.rxn1_i.size                                 = 1;
    pins.txp0_i.size                                 = 1;
    pins.txn0_i.size                                 = 1;
    pins.txp1_i.size                                 = 1;
    pins.txn1_i.size                                 = 1;
    pins.txdp0_i.size                                = 1;
    pins.txdn0_i.size                                = 1;
    pins.txdp1_i.size                                = 1;
    pins.txdn1_i.size                                = 1;
    pins.txdp2_i.size                                = 1;
    pins.txdn2_i.size                                = 1;
    pins.txdp3_i.size                                = 1;
    pins.txdn3_i.size                                = 1;
    pins.rxdp0_i.size                                = 1;
    pins.rxdn0_i.size                                = 1;
    pins.rxdp1_i.size                                = 1;
    pins.rxdn1_i.size                                = 1;
    pins.rxdp2_i.size                                = 1;
    pins.rxdn2_i.size                                = 1;
    pins.rxdp3_i.size                                = 1;
    pins.rxdn3_i.size                                = 1;
    pins.sig_MII_CRS.size                            = 1;
    pins.sig_MII_RX_DV.size                          = 1;
    pins.sig_MII_TX_DATA.size                        = 4;
    pins.sig_MII_RX_DATA.size                        = 4;
    pins.sig_MII_RX_ER.size                          = 1;
    pins.sig_MII_TX_ER.size                          = 1;
    pins.sig_MII_COL.size                            = 1;
    pins.sig_MII_TX_EN.size                          = 1;
    pins.sig_MII_TX_CLK.size                         = 1;
    pins.sig_MII_RX_CLK.size                         = 1;
    pins.sig_MDIO.size                               = 1;
    pins.sig_MDCLK.size                              = 1;
    pins.sig_RMII_TX_EN.size                         = 1;
    pins.sig_RMII_TX_DATA.size                       = 2;
    pins.sig_RMII_CRS_DV.size                        = 1;
    pins.sig_RMII_RX_DATA.size                       = 2;
    pins.sig_RMII_RX_ER.size                         = 1;
    pins.sig_RMII_REF_CLK.size                       = 1;
    pins.sig_SMII_TX.size                            = 1;
    pins.sig_SMII_RX.size                            = 1;
    pins.sig_SMII_REF_CLK.size                       = 1;
    pins.sig_SMII_SYNC.size                          = 1;
    pins.sig_GMII_CRS.size                           = 1;
    pins.sig_GMII_RX_DV.size                         = 1;
    pins.sig_GMII_TX_DATA.size                       = 8;
    pins.sig_GMII_RX_DATA.size                       = 8;
    pins.sig_GMII_RX_ER.size                         = 1;
    pins.sig_GMII_TX_ER.size                         = 1;
    pins.sig_GMII_COL.size                           = 1;
    pins.sig_GMII_TX_EN.size                         = 1;
    pins.sig_GMII_TX_CLK.size                        = 1;
    pins.sig_GMII_RX_CLK.size                        = 1;
    pins.sig_TBI_PMA_TX_CLK.size                     = 1;
    pins.sig_TBI_RX_CODE.size                        = 10;
    pins.sig_TBI_TX_CODE.size                        = 10;
    pins.sig_TBI_EN_WRAP.size                        = 1;
    pins.sig_TBI_PMA_RX_CLK0.size                    = 1;
    pins.sig_TBI_PMA_RX_CLK1.size                    = 1;
    pins.sig_TBI_EN_CDET.size                        = 1;
    pins.sig_TBI_COM_DET.size                        = 1;
    pins.sig_TBI_LCK_REF.size                        = 1;
    pins.sig_TBI_SIGNAL_DETECT.size                  = 1;
    pins.sig_RTBI_TXC.size                           = 1;
    pins.sig_RTBI_RXC.size                           = 1;
    pins.sig_RTBI_TD.size                            = 4;
    pins.sig_RTBI_TX_CTL.size                        = 1;
    pins.sig_RTBI_RD.size                            = 4;
    pins.sig_RTBI_RX_CTL.size                        = 1;
    pins.sig_ONEGKX_TX_CLK.size                      = 1;
    pins.sig_ONEGKX_RX_CLK.size                      = 1;
    pins.sig_ONEGKX_RXD_P.size                       = 1;
    pins.sig_ONEGKX_RXD_N.size                       = 1;
    pins.sig_ONEGKX_TXD_P.size                       = 1;
    pins.sig_ONEGKX_TXD_N.size                       = 1;
    pins.sig_ONEGKX_PMD_SIGNAL_DETECT.size           = 1;
    pins.sig_SGMII_TXD_P.size                        = 1;
    pins.sig_SGMII_RXD_P.size                        = 1;
    pins.sig_SGMII_TXD_N.size                        = 1;
    pins.sig_SGMII_RXD_N.size                        = 1;
    pins.sig_SGMII_TXD.size                          = 1;
    pins.sig_SGMII_RXD.size                          = 1;
    pins.sig_SGMII_SERIAL_TX_CLK.size                = 1;
    pins.sig_SGMII_SERIAL_RX_CLK.size                = 1;
    pins.sig_SGMII_SIGNAL_DETECT.size                = 1;
    pins.sig_RGMII_TXC.size                          = 1;
    pins.sig_RGMII_TD.size                           = 4;
    pins.sig_RGMII_TX_CTL.size                       = 1;
    pins.sig_RGMII_RXC.size                          = 1;
    pins.sig_RGMII_RD.size                           = 4;
    pins.sig_RGMII_RX_CTL.size                       = 1;
    pins.sig_XGMII_TXC.size                          = 4;
    pins.sig_XGMII_TX_DATA.size                      = 32;
    pins.sig_XGMII_RXC.size                          = 4;
    pins.sig_XGMII_RX_DATA.size                      = 32;
    pins.sig_XGMII_TX_CLK.size                       = 1;
    pins.sig_XGMII_RX_CLK.size                       = 1;
    pins.sig_TENGKR_RX_CLK.size                      = 1;
    pins.sig_TENGKR_PARALLEL_RX_CLK.size             = 1;
    pins.sig_TENGKR_TX_CLK.size                      = 1;
    pins.sig_TENGKR_PARALLEL_TX_CLK.size             = 1;
    pins.sig_TENGKR_TXD_P.size                       = 1;
    pins.sig_TENGKR_TXD_N.size                       = 1;
    pins.sig_TENGKR_RXD_P.size                       = 1;
    pins.sig_TENGKR_RXD_N.size                       = 1;
    pins.sig_TENGKR_ENCODER_IN.size                  = 72;
    pins.sig_TENGKR_ENCODER_OUT.size                 = 66;
    pins.sig_TENGKR_DECODER_IN.size                  = 66;
    pins.sig_TENGKR_DECODER_NEXT_IN.size             = 66;
    pins.sig_TENGKR_DECODER_OUT.size                 = 72;
    pins.sig_TENGKR_PCS_PMA_TXD.size                 = 66;
    pins.sig_TENGKR_PCS_PMA_RXD.size                 = 66;
    pins.sig_TENGKR_PMD_SIGNAL_DETECT.size           = 1;
    pins.sig_CLK_GATING_TX.size                      = 1;
    pins.sig_CLK_GATING_RX.size                      = 1;
    pins.sig_TENGKR_ENERGY_DETECT.size               = 1;
    pins.sig_DISABLE_SERDES.size                     = 1;
    pins.sig_TENGKX4_TX_CLK.size                     = 1;
    pins.sig_TENGKX4_RX_CLK.size                     = 1;
    pins.sig_TENGKX4_TX_CLK_0.size                   = 1;
    pins.sig_TENGKX4_TX_CLK_1.size                   = 1;
    pins.sig_TENGKX4_TX_CLK_2.size                   = 1;
    pins.sig_TENGKX4_TX_CLK_3.size                   = 1;
    pins.sig_TENGKX4_RX_CLK_0.size                   = 1;
    pins.sig_TENGKX4_RX_CLK_1.size                   = 1;
    pins.sig_TENGKX4_RX_CLK_2.size                   = 1;
    pins.sig_TENGKX4_RX_CLK_3.size                   = 1;
    pins.sig_TENGKX4_TX0_P.size                      = 1;
    pins.sig_TENGKX4_TX0_N.size                      = 1;
    pins.sig_TENGKX4_TX1_P.size                      = 1;
    pins.sig_TENGKX4_TX1_N.size                      = 1;
    pins.sig_TENGKX4_TX2_P.size                      = 1;
    pins.sig_TENGKX4_TX2_N.size                      = 1;
    pins.sig_TENGKX4_TX3_P.size                      = 1;
    pins.sig_TENGKX4_TX3_N.size                      = 1;
    pins.sig_TENGKX4_RX0_P.size                      = 1;
    pins.sig_TENGKX4_RX0_N.size                      = 1;
    pins.sig_TENGKX4_RX1_P.size                      = 1;
    pins.sig_TENGKX4_RX1_N.size                      = 1;
    pins.sig_TENGKX4_RX2_P.size                      = 1;
    pins.sig_TENGKX4_RX2_N.size                      = 1;
    pins.sig_TENGKX4_RX3_P.size                      = 1;
    pins.sig_TENGKX4_RX3_N.size                      = 1;
    pins.sig_TENGKX4_TX0_CODE.size                   = 10;
    pins.sig_TENGKX4_TX1_CODE.size                   = 10;
    pins.sig_TENGKX4_TX2_CODE.size                   = 10;
    pins.sig_TENGKX4_TX3_CODE.size                   = 10;
    pins.sig_TENGKX4_RX0_CODE.size                   = 10;
    pins.sig_TENGKX4_RX1_CODE.size                   = 10;
    pins.sig_TENGKX4_RX2_CODE.size                   = 10;
    pins.sig_TENGKX4_RX3_CODE.size                   = 10;
    pins.sig_TENGKX4_PMD_SIGNAL_DETECT.size          = 1;
    pins.sig_XSBI_RXD.size                           = 16;
    pins.sig_XSBI_TXD.size                           = 16;
    pins.sig_XSBI_SIGNAL_INDICATE.size               = 1;
    pins.sig_XSBI_PCS_R_STATUS.size                  = 1;
    pins.sig_PMA_RX_CLK.size                         = 1;
    pins.sig_PMA_TX_CLK.size                         = 1;
    pins.sig_XSBI_ENCODER_IN.size                    = 72;
    pins.sig_XSBI_ENCODER_OUT.size                   = 66;
    pins.sig_XSBI_DECODER_IN.size                    = 66;
    pins.sig_XSBI_DECODER_NEXT_IN.size               = 66;
    pins.sig_XSBI_DECODER_OUT.size                   = 72;
    pins.sig_XSBI_ENERGY_DETECT.size                 = 1;
    pins.sig_XAUI_TX_CLK.size                        = 1;
    pins.sig_XAUI_RX_CLK.size                        = 1;
    pins.sig_XAUI_TX0.size                           = 1;
    pins.sig_XAUI_TX1.size                           = 1;
    pins.sig_XAUI_TX2.size                           = 1;
    pins.sig_XAUI_TX3.size                           = 1;
    pins.sig_XAUI_RX0.size                           = 1;
    pins.sig_XAUI_RX1.size                           = 1;
    pins.sig_XAUI_RX2.size                           = 1;
    pins.sig_XAUI_RX3.size                           = 1;
    pins.sig_XAUI_TX0_CODE.size                      = 10;
    pins.sig_XAUI_TX1_CODE.size                      = 10;
    pins.sig_XAUI_TX2_CODE.size                      = 10;
    pins.sig_XAUI_TX3_CODE.size                      = 10;
    pins.sig_XAUI_RX0_CODE.size                      = 10;
    pins.sig_XAUI_RX1_CODE.size                      = 10;
    pins.sig_XAUI_RX2_CODE.size                      = 10;
    pins.sig_XAUI_RX3_CODE.size                      = 10;
    pins.sig_XAUI_SIGNAL_DETECT.size                 = 1;
    pins.sig_RXAUI_TX_CLK.size                       = 1;
    pins.sig_RXAUI_RX_CLK.size                       = 1;
    pins.sig_RXAUI_TX0_P.size                        = 1;
    pins.sig_RXAUI_TX0_N.size                        = 1;
    pins.sig_RXAUI_TX1_P.size                        = 1;
    pins.sig_RXAUI_TX1_N.size                        = 1;
    pins.sig_RXAUI_RX0_P.size                        = 1;
    pins.sig_RXAUI_RX0_N.size                        = 1;
    pins.sig_RXAUI_RX1_P.size                        = 1;
    pins.sig_RXAUI_RX1_N.size                        = 1;
    pins.sig_RXAUI_TX0_CODE.size                     = 10;
    pins.sig_RXAUI_TX1_CODE.size                     = 10;
    pins.sig_RXAUI_RX0_CODE.size                     = 10;
    pins.sig_RXAUI_RX1_CODE.size                     = 10;
    pins.sig_RXAUI_TX0_CODE_20BIT.size               = 20;
    pins.sig_RXAUI_TX1_CODE_20BIT.size               = 20;
    pins.sig_RXAUI_RX0_CODE_20BIT.size               = 20;
    pins.sig_RXAUI_RX1_CODE_20BIT.size               = 20;
    pins.sig_RXAUI_SIGNAL_DETECT.size                = 1;
    pins.sig_CGMII_TXC.size                          = 8;
    pins.sig_CGMII_TX_DATA.size                      = 64;
    pins.sig_CGMII_RXC.size                          = 8;
    pins.sig_CGMII_RX_DATA.size                      = 64;
    pins.sig_CGMII_TX_CLK.size                       = 1;
    pins.sig_CGMII_RX_CLK.size                       = 1;
    pins.sig_100GBASER_RXD0.size                     = 66;
    pins.sig_100GBASER_RXD1.size                     = 66;
    pins.sig_100GBASER_RXD2.size                     = 66;
    pins.sig_100GBASER_RXD3.size                     = 66;
    pins.sig_100GBASER_RXD4.size                     = 66;
    pins.sig_100GBASER_RXD5.size                     = 66;
    pins.sig_100GBASER_RXD6.size                     = 66;
    pins.sig_100GBASER_RXD7.size                     = 66;
    pins.sig_100GBASER_RXD8.size                     = 66;
    pins.sig_100GBASER_RXD9.size                     = 66;
    pins.sig_100GBASER_RXD10.size                    = 66;
    pins.sig_100GBASER_RXD11.size                    = 66;
    pins.sig_100GBASER_RXD12.size                    = 66;
    pins.sig_100GBASER_RXD13.size                    = 66;
    pins.sig_100GBASER_RXD14.size                    = 66;
    pins.sig_100GBASER_RXD15.size                    = 66;
    pins.sig_100GBASER_RXD16.size                    = 66;
    pins.sig_100GBASER_RXD17.size                    = 66;
    pins.sig_100GBASER_RXD18.size                    = 66;
    pins.sig_100GBASER_RXD19.size                    = 66;
    pins.sig_100GBASER_TXD0.size                     = 66;
    pins.sig_100GBASER_TXD1.size                     = 66;
    pins.sig_100GBASER_TXD2.size                     = 66;
    pins.sig_100GBASER_TXD3.size                     = 66;
    pins.sig_100GBASER_TXD4.size                     = 66;
    pins.sig_100GBASER_TXD5.size                     = 66;
    pins.sig_100GBASER_TXD6.size                     = 66;
    pins.sig_100GBASER_TXD7.size                     = 66;
    pins.sig_100GBASER_TXD8.size                     = 66;
    pins.sig_100GBASER_TXD9.size                     = 66;
    pins.sig_100GBASER_TXD10.size                    = 66;
    pins.sig_100GBASER_TXD11.size                    = 66;
    pins.sig_100GBASER_TXD12.size                    = 66;
    pins.sig_100GBASER_TXD13.size                    = 66;
    pins.sig_100GBASER_TXD14.size                    = 66;
    pins.sig_100GBASER_TXD15.size                    = 66;
    pins.sig_100GBASER_TXD16.size                    = 66;
    pins.sig_100GBASER_TXD17.size                    = 66;
    pins.sig_100GBASER_TXD18.size                    = 66;
    pins.sig_100GBASER_TXD19.size                    = 66;
    pins.sig_100GBASER_RXD_P0.size                   = 1;
    pins.sig_100GBASER_RXD_P1.size                   = 1;
    pins.sig_100GBASER_RXD_P2.size                   = 1;
    pins.sig_100GBASER_RXD_P3.size                   = 1;
    pins.sig_100GBASER_RXD_P4.size                   = 1;
    pins.sig_100GBASER_RXD_P5.size                   = 1;
    pins.sig_100GBASER_RXD_P6.size                   = 1;
    pins.sig_100GBASER_RXD_P7.size                   = 1;
    pins.sig_100GBASER_RXD_P8.size                   = 1;
    pins.sig_100GBASER_RXD_P9.size                   = 1;
    pins.sig_100GBASER_RXD_N0.size                   = 1;
    pins.sig_100GBASER_RXD_N1.size                   = 1;
    pins.sig_100GBASER_RXD_N2.size                   = 1;
    pins.sig_100GBASER_RXD_N3.size                   = 1;
    pins.sig_100GBASER_RXD_N4.size                   = 1;
    pins.sig_100GBASER_RXD_N5.size                   = 1;
    pins.sig_100GBASER_RXD_N6.size                   = 1;
    pins.sig_100GBASER_RXD_N7.size                   = 1;
    pins.sig_100GBASER_RXD_N8.size                   = 1;
    pins.sig_100GBASER_RXD_N9.size                   = 1;
    pins.sig_100GBASER_TXD_P0.size                   = 1;
    pins.sig_100GBASER_TXD_P1.size                   = 1;
    pins.sig_100GBASER_TXD_P2.size                   = 1;
    pins.sig_100GBASER_TXD_P3.size                   = 1;
    pins.sig_100GBASER_TXD_P4.size                   = 1;
    pins.sig_100GBASER_TXD_P5.size                   = 1;
    pins.sig_100GBASER_TXD_P6.size                   = 1;
    pins.sig_100GBASER_TXD_P7.size                   = 1;
    pins.sig_100GBASER_TXD_P8.size                   = 1;
    pins.sig_100GBASER_TXD_P9.size                   = 1;
    pins.sig_100GBASER_TXD_N0.size                   = 1;
    pins.sig_100GBASER_TXD_N1.size                   = 1;
    pins.sig_100GBASER_TXD_N2.size                   = 1;
    pins.sig_100GBASER_TXD_N3.size                   = 1;
    pins.sig_100GBASER_TXD_N4.size                   = 1;
    pins.sig_100GBASER_TXD_N5.size                   = 1;
    pins.sig_100GBASER_TXD_N6.size                   = 1;
    pins.sig_100GBASER_TXD_N7.size                   = 1;
    pins.sig_100GBASER_TXD_N8.size                   = 1;
    pins.sig_100GBASER_TXD_N9.size                   = 1;
    pins.sig_100GBASER_SIGNAL_INDICATE.size          = 1;
    pins.sig_100GBASER_PCS_R_STATUS.size             = 1;
    pins.sig_PMA_RX_CLK0.size                        = 1;
    pins.sig_PMA_RX_CLK1.size                        = 1;
    pins.sig_PMA_RX_CLK2.size                        = 1;
    pins.sig_PMA_RX_CLK3.size                        = 1;
    pins.sig_PMA_RX_CLK4.size                        = 1;
    pins.sig_PMA_RX_CLK5.size                        = 1;
    pins.sig_PMA_RX_CLK6.size                        = 1;
    pins.sig_PMA_RX_CLK7.size                        = 1;
    pins.sig_PMA_RX_CLK8.size                        = 1;
    pins.sig_PMA_RX_CLK9.size                        = 1;
    pins.sig_PMA_RX_CLK10.size                       = 1;
    pins.sig_PMA_RX_CLK11.size                       = 1;
    pins.sig_PMA_RX_CLK12.size                       = 1;
    pins.sig_PMA_RX_CLK13.size                       = 1;
    pins.sig_PMA_RX_CLK14.size                       = 1;
    pins.sig_PMA_RX_CLK15.size                       = 1;
    pins.sig_PMA_RX_CLK16.size                       = 1;
    pins.sig_PMA_RX_CLK17.size                       = 1;
    pins.sig_PMA_RX_CLK18.size                       = 1;
    pins.sig_PMA_RX_CLK19.size                       = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK0.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK1.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK2.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK3.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK4.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK5.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK6.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK7.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK8.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK9.size         = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK10.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK11.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK12.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK13.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK14.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK15.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK16.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK17.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK18.size        = 1;
    pins.sig_100GBASER_PARALLEL_RX_CLK19.size        = 1;
    pins.sig_PMA_TX_CLK0.size                        = 1;
    pins.sig_PMA_TX_CLK1.size                        = 1;
    pins.sig_PMA_TX_CLK2.size                        = 1;
    pins.sig_PMA_TX_CLK3.size                        = 1;
    pins.sig_PMA_TX_CLK4.size                        = 1;
    pins.sig_PMA_TX_CLK5.size                        = 1;
    pins.sig_PMA_TX_CLK6.size                        = 1;
    pins.sig_PMA_TX_CLK7.size                        = 1;
    pins.sig_PMA_TX_CLK8.size                        = 1;
    pins.sig_PMA_TX_CLK9.size                        = 1;
    pins.sig_PMA_TX_CLK10.size                       = 1;
    pins.sig_PMA_TX_CLK11.size                       = 1;
    pins.sig_PMA_TX_CLK12.size                       = 1;
    pins.sig_PMA_TX_CLK13.size                       = 1;
    pins.sig_PMA_TX_CLK14.size                       = 1;
    pins.sig_PMA_TX_CLK15.size                       = 1;
    pins.sig_PMA_TX_CLK16.size                       = 1;
    pins.sig_PMA_TX_CLK17.size                       = 1;
    pins.sig_PMA_TX_CLK18.size                       = 1;
    pins.sig_PMA_TX_CLK19.size                       = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK0.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK1.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK2.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK3.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK4.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK5.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK6.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK7.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK8.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK9.size         = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK10.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK11.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK12.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK13.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK14.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK15.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK16.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK17.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK18.size        = 1;
    pins.sig_100GBASER_PARALLEL_TX_CLK19.size        = 1;
    pins.sig_SIGNAL_DETECT.size                      = 1;
    pins.sig_ENERGY_DETECT.size                      = 1;
    pins.sig_100GBASER_ENCODER_IN.size               = 72;
    pins.sig_100GBASER_ENCODER_OUT.size              = 66;
    pins.sig_100GBASER_DECODER_IN.size               = 66;
    pins.sig_100GBASER_DECODER_NEXT_IN.size          = 66;
    pins.sig_100GBASER_DECODER_OUT.size              = 72;
    pins.sig_100GBASER_lane_no.size                  = 20;
    pins.sig_100GBASER_TX_OR_RX.size                 = 1;
    pins.sig_100GBASER_start_forcing.size            = 1;
    pins.sig_100GBASER_DISABLE_SERDES0.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES1.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES2.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES3.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES4.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES5.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES6.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES7.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES8.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES9.size          = 1;
    pins.sig_100GBASER_DISABLE_SERDES10.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES11.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES12.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES13.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES14.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES15.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES16.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES17.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES18.size         = 1;
    pins.sig_100GBASER_DISABLE_SERDES19.size         = 1;
    pins.sig_QSGMII_TXD.size                         = 1;
    pins.sig_QSGMII_RXD.size                         = 1;
    pins.sig_QSGMII_TBI_TXD.size                     = 10;
    pins.sig_QSGMII_TBI_RXD.size                     = 10;
    pins.sig_QSGMII_SERIAL_TX_CLK.size               = 1;
    pins.sig_QSGMII_SERIAL_RX_CLK.size               = 1;
    pins.sig_QSGMII_SIGNAL_DETECT.size               = 1;
    pins.sig_CL46_TXC.size                           = 4;
    pins.sig_CL46_TX_DATA.size                       = 32;
    pins.sig_CL46_RXC.size                           = 4;
    pins.sig_CL46_RX_DATA.size                       = 32;
    pins.sig_CL46_TX_CLK.size                        = 1;
    pins.sig_CL46_RX_CLK.size                        = 1;
    pins.sig_CL49_RX_CLK.size                        = 1;
    pins.sig_CL49_PARALLEL_RX_CLK.size               = 1;
    pins.sig_CL49_TX_CLK.size                        = 1;
    pins.sig_CL49_PARALLEL_TX_CLK.size               = 1;
    pins.sig_CL49_TXD_P.size                         = 1;
    pins.sig_CL49_TXD_N.size                         = 1;
    pins.sig_CL49_RXD_P.size                         = 1;
    pins.sig_CL49_RXD_N.size                         = 1;
    pins.sig_CL49_PCS_PMA_TXD.size                   = 66;
    pins.sig_CL49_PCS_PMA_RXD.size                   = 66;
    pins.sig_CL49_PMD_SIGNAL_DETECT.size             = 1;
    pins.sig_CL49_PMA_PMD_TXD_P.size                 = 1;
    pins.sig_CL49_PMA_PMD_TXD_N.size                 = 1;
    pins.sig_CL49_PMA_PMD_RXD_P.size                 = 1;
    pins.sig_CL49_PMA_PMD_RXD_N.size                 = 1;
    pins.sig_CL49_ENERGY_DETECT.size                 = 1;
    pins.sig_CL81_TXC.size                           = 8;
    pins.sig_CL81_TX_DATA.size                       = 64;
    pins.sig_CL81_RXC.size                           = 8;
    pins.sig_CL81_RX_DATA.size                       = 64;
    pins.sig_CL81_TX_CLK.size                        = 1;
    pins.sig_CL81_RX_CLK.size                        = 1;
    pins.sig_CL82_RXD0.size                          = 66;
    pins.sig_CL82_RXD1.size                          = 66;
    pins.sig_CL82_TXD0.size                          = 66;
    pins.sig_CL82_TXD1.size                          = 66;
    pins.sig_CL82_RXD_P0.size                        = 1;
    pins.sig_CL82_RXD_P1.size                        = 1;
    pins.sig_CL82_RXD_N0.size                        = 1;
    pins.sig_CL82_RXD_N1.size                        = 1;
    pins.sig_CL82_TXD_P0.size                        = 1;
    pins.sig_CL82_TXD_P1.size                        = 1;
    pins.sig_CL82_TXD_N0.size                        = 1;
    pins.sig_CL82_TXD_N1.size                        = 1;
    pins.sig_CL82_SIGNAL_INDICATE.size               = 1;
    pins.sig_CL82_PARALLEL_RX_CLK0.size              = 1;
    pins.sig_CL82_PARALLEL_RX_CLK1.size              = 1;
    pins.sig_CL82_PARALLEL_TX_CLK0.size              = 1;
    pins.sig_CL82_PARALLEL_TX_CLK1.size              = 1;
    pins.sig_CL82_DISABLE_SERDES0.size               = 1;
    pins.sig_CL82_DISABLE_SERDES1.size               = 1;
  endfunction : new

endclass : cdn_enet_vip_active_phy_config

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
