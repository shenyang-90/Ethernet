/**************************************************************************
 File name    : cdn_enet_vip_agent.sv
 Title        : User Agent
 Project      : Ethernet 
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This is extended user agent which can be used to override 
                function and task or to added more instance to the base agent
                class.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_agent.sv
 *
 * This file contains the agent class for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_UVM_USER_AGENT_SV
`define CDN_ENET_UVM_USER_AGENT_SV

/*
 * Class: cdn_enet_vip_agent
 *
 * This is extended user agent which can be used to override function and task 
 * or to added more instance to the base agent class.
 */ 
class cdn_enet_vip_agent extends cdnEnetUvmAgent;

  //-----------------------------------------------------------------------
  // INTERFACES.
  //-----------------------------------------------------------------------

  /*
   * Variable: vif
   * 
   * The virtual interface used to connect with the ENET interface in the DUT.
   */
  `ifdef gem_use_rgmii
    `cdnEnetDeclareVif(virtual interface cdn_enet_vip_rgmii_if)
  `else
    `cdnEnetDeclareVif(virtual interface cdn_enet_vip_gmii_if)
  `endif

  //-----------------------------------------------------------------------
  // MEMBER VARIABLES.
  //-----------------------------------------------------------------------

  /*
   * Variable: PartnerRxPacketEndedEvent
   * 
   * In case of VIP Back to Back examples, this event needs to be bound with
   * Partner's RxPktEndedPktCbEvent.
   */
  uvm_event PartnerRxPacketEndedEvent;

  //-----------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //-----------------------------------------------------------------------

  `uvm_component_utils(cdn_enet_vip_agent)
  
  //-----------------------------------------------------------------------
  // CONSTRUCTOR.
  //-----------------------------------------------------------------------

  /*
   * Method: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_agent objects.
   * 
   * Parameters:
   * 
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */  
  function new (string name, uvm_component parent);
    super.new(name, parent);
    PartnerRxPacketEndedEvent = new("PartnerRxPacketEndedEvent");
  endfunction : new

  //-----------------------------------------------------------------------
  // UVM PHASES.
  //-----------------------------------------------------------------------

  /*
   * Method: build_phase
   * 
   * This UVM phase is used for building the testbench component hierarchy.
   * For cdn_enet_vip_agent, disable the coverage for the passive agents.
   * 
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */     
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `ifndef CDN_ENET_ENABLE_COVERAGE
      // Re-setting the coverageEnable default for all agents to '0'
  	  // Done for ENET specifically to improve performance
      uvm_config_int::set(this,"monitor","coverageEnable",0);
    `endif
  endfunction : build_phase

  /*
   * Method: check_phase
   * 
   * This UVM phase processes and checks the simulation results.
   * 
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  virtual function void check_phase (uvm_phase phase);
    super.check_phase(phase);
    regInst.writeReg(DENALI_ENET_REG_TransactionsEnded,1);
  endfunction : check_phase

  //-----------------------------------------------------------------------
  // METHODS.
  //-----------------------------------------------------------------------

  /*
   * Method: macSecSAKey128
   * 
   * This function is for writing the 128 bit MacSec KEY recursively in the
   * SAKEY config through DENALI_ENET_REG_MacSecKeyPsui register.
   * 
   * Parameters:
   * 
   *    SAKey - The SAKEY for the MacSec.
   */
  virtual function void macSecSAKey128(bit [127:0] SAKey);
    int regValue;
    // For active MAC 
    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[31:0]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value  = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[63:32]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[95:64]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[127:96]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);
  endfunction

  /*
   * Method: macSecSAKey256
   * 
   * This function is for writing the 256 bit macsec KEY recursively in the 
   * SAKEY config through DENALI_ENET_REG_MacSecKeyPsui register.
   * 
   * Parameters:
   * 
   *    SAKey - The SAKEY for the MacSec.
   */  
  virtual function void macSecSAKey256(bit [0:255] SAKey);
    int regValue;
    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[0:31]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[32:63]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);
 
    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[64:95]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[96:127]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);
 
      // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[128:159]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[160:191]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[192:223]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);

    // Writing Macsec register to write user macsec secure association key
    regInst.writeReg(DENALI_ENET_REG_MacSecKeyPsui, SAKey[224:255]);
    regValue = regInst.readReg(DENALI_ENET_REG_MacSecKeyPsui);
    `uvm_info(get_type_name(), $psprintf("Reading DENALI_ENET_REG_MacSecKeyPsui value = %x",regValue), UVM_HIGH);
  endfunction

endclass : cdn_enet_vip_agent

`endif // CDN_ENET_UVM_USER_AGENT_SV

//----------------------------------------------------------------------------
// END OF FILE
//----------------------------------------------------------------------------
