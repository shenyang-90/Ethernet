/**************************************************************************
 File name    : cdn_enet_vip_monitor.sv
 Title        : User Monitor
 Project      : Ethernet
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This class shows how user can add object for coverage class
                and connect ports. Same way use can added
                his/her specific class object and do the connection.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_monitor.sv
 * 
 * This file contains the ENET VIP env monitor that wraps around the ENET VIP
 * base monitor class.
 */

`ifndef CDN_ENET_UVM_USER_MONITOR_SV
`define CDN_ENET_UVM_USER_MONITOR_SV

/*
 * Class: cdn_enet_vip_monitor
 * 
 * This is the ENET VIP env UVM monitor wrapper class.
 */
class cdn_enet_vip_monitor extends cdnEnetUvmMonitor;

  //------------------------------------------------------------------------
  // MEMBER VARIABLES
  //------------------------------------------------------------------------
  
  /*
   * Variable: coverageEnable
   * 
   * This variable is used to control the creation of coverage object.
   * By default its value is one, means coverage object will be created.
   * User can control or set this value from test and enable, disable
   * coverage class object creation.
   */
  //bit coverageEnable = 1;

  // Coverage model
  //cdn_enet_vip_cover coverModel;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS
  //------------------------------------------------------------------------

  `uvm_component_utils_begin(cdn_enet_vip_monitor)
    //`uvm_field_int(coverageEnable, UVM_ALL_ON)
  `uvm_component_utils_end

  //------------------------------------------------------------------------
  // CONSTRUCTOR
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_monitor objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name = "cdn_enet_vip_monitor", uvm_component parent);
      super.new(name, parent);
  endfunction : new

  //------------------------------------------------------------------------
  // UVM PHASE METHODS
  //------------------------------------------------------------------------

  /*
   * Method: build_phase
   * 
   * This UVM phase is used for building the testbench component hierarchy.
   * For cdn_enet_vip_monitor, it creates object for coverage.
   * 
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   //Condition to control the creation of coverage object.
   //if (coverageEnable == 1) begin
   //  coverModel = cdnEnetUvmUserCover::type_id::create("coverModel", this);
   //end
  endfunction : build_phase

  /*
   * Method: connect_phase
   * 
   * This UVM phase is used for making connections between components in the hierarchy.
   * For the cdn_enet_vip_monitor, it connects analysis ports to imports in Coverage
   * and Events model.
   *
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //Connecting RxPktEndedPktCbPort of monitor to CoverRxFrameEndedImp imp
    //port of covearge class.
    //if (coverageEnable == 1) begin
    //this.RxPktEndedPktCbPort.connect();
    //end
  endfunction

  //------------------------------------------------------------------------
  // CALLBACK METHODS
  //------------------------------------------------------------------------

  /*
   * Method: RxPktEndedPktCbF
   * 
   * This implementation is used to monitor the RxPktEndedPkt callback function.
   */
  virtual function void RxPktEndedPktCbF(denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function RxPktEndedPktCbF triggered", UVM_DEBUG);
  endfunction

  /*
   * Method: RxPktStartedPktCbF
   * 
   * This implementation is used to monitor the RxPktStartedPkt callback 
   * function.
   */
  virtual function void RxPktStartedPktCbF(denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function RxPktStartedPktCbF triggered", UVM_DEBUG);
  endfunction

  /*
   * Method: TxPktEndedPktCbF
   * 
   * This implementation is used to monitor the TxPktEndedPkt callback function.
   */
  virtual function void TxPktEndedPktCbF(denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function TxPktEndedPktCbF triggered", UVM_DEBUG);
  endfunction

  /*
   * Method: TxPktStartedPktCbF
   * 
   * This implementation is used to monitor the TxPktStartedPkt callback 
   * function.
   */
  virtual function void TxPktStartedPktCbF(denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function TxPktStartedPktCbF triggered", UVM_DEBUG);
  endfunction

  /*
   * Method: TxUserQueueExitTransportPktCbF
   * 
   * This implementation is used to monitor the TxUserQueueExitTransportPkt 
   * callback function.
   */
  virtual function void TxUserQueueExitTransportPktCbF(denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function TxUserQueueExitTransportPktCbF triggered", UVM_DEBUG);
  endfunction

  /*
   * Method: TxUserQueueExitNetworkPktCbF
   * 
   * This implementation is used to monitor the TxUserQueueExitNetworkPkt 
   * callback function.
   */
  virtual function void TxUserQueueExitNetworkPktCbF(denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function TxUserQueueExitNetworkPktCbF triggered", UVM_DEBUG);
  endfunction

endclass : cdn_enet_vip_monitor

`endif // CDN_ENET_UVM_USER_MONITOR_SV

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
