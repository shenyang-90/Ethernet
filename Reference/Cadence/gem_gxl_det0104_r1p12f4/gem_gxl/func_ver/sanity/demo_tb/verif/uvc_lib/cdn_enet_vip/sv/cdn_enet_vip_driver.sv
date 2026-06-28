/**************************************************************************
 File name    : cdn_enet_vip_driver.sv
 Title        : User Driver
 Project      : Ethernet
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This class is a derived class of cdnEnetUvmDriver.
                This user driver shows how user can use this class to sample
                and modify transaction on callbacks.
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_driver.sv
 *
 * This file contains the driver class for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_UVM_USER_DRIVER_SV
`define CDN_ENET_UVM_USER_DRIVER_SV

/*
 * Typedef: typeOfErr
 *
 * Type definition to declare various types of errors.
 */
typedef enum {PREAMBLE_ERR, SFD_ERR, TYPE_ERR, CRC_ERR} typeOfErr;

/*
 * Class: cdn_enet_vip_driver
 *
 * This class is a derived class of cdnEnetUvmDriver.
 * This user driver shows how user can use this class to sample and modify
 * transaction on callbacks.
 */
class cdn_enet_vip_driver extends cdnEnetUvmDriver;

  //-----------------------------------------------------------------------
  // TLM PORTS.
  //-----------------------------------------------------------------------

  // Imp object declaration
  `uvm_analysis_imp_decl(_cdn_enet_TxUser_QueueExit)

  /*
   * Variable: TxUserQueueExitImp
   *
   * Using specific named imp port to declare CoverTxUserQueueExitImp.
   */
  uvm_analysis_imp_cdn_enet_TxUser_QueueExit #(denaliEnetTransaction, cdn_enet_vip_driver) TxUserQueueExitImp;

  //-----------------------------------------------------------------------
  // CONTROL KNOBS.
  //-----------------------------------------------------------------------

  /*
   * Variable: errorInjectionEnabled
   *
   * A field that will is used to decide if errors will be injected.
   */
  bit errorInjectionEnabled = 0;

  /*
   * Variable: errorInjectionEnabled
   *
   * A field that will is used to decide on which transaction field error will
   * be injected.
   */
  typeOfErr errorKind;

  //-----------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //-----------------------------------------------------------------------

  `uvm_component_utils_begin(cdn_enet_vip_driver)
    `uvm_field_int(errorInjectionEnabled, UVM_ALL_ON)
    `uvm_field_enum(typeOfErr, errorKind, UVM_ALL_ON)
  `uvm_component_utils_end

  //-----------------------------------------------------------------------
  // CONSTRUCTOR.
  //-----------------------------------------------------------------------

  /*
   * Method: new
   *
   * The class constructor.
   * It is used to construct cdn_enet_vip_driver objects.
   *
   * Parameters:
   *
   *    name   - The name of the class to construct.
   *    parent - The parent class.
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //-----------------------------------------------------------------------
  // UVM PHASES.
  //-----------------------------------------------------------------------

  /*
   * Method: build_phase
   *
   * This UVM phase is used for building the testbench component hierarchy.
   *
   * Parameters:
   *
   *    phase - The UVM phase object.
   */
  virtual function void build_phase(uvm_phase phase);
    int get_value;
    super.build_phase(phase);
    // If err flag is set then only TxUserQueueExitImp Imp port is created.
    if(errorInjectionEnabled == 1) begin
      TxUserQueueExitImp = new ("TxUserQueueExitImp", this);
    end
  endfunction: build_phase

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
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // If err flag is set then only port is connected.
    if(errorInjectionEnabled == 1) begin
       //Connecting monitor TxUserQueueExitPktCbPort to driver TxUserQueueExitImp imp port.
       pAgent.monitor.TxUserQueueExitPktCbPort.connect(TxUserQueueExitImp);
    end
  endfunction : connect_phase

  //-----------------------------------------------------------------------
  // OTHER FUNCTIONS.
  //-----------------------------------------------------------------------

  /*
   * Method: write_cdn_enet_TxUser_QueueExit
   *
   * This function gets triggered by imp port TxUserQueueExitImp.
   * On the basis of errorKind value, which can be set from test, one case will
   * be selected and error will be introduced.
   * You can refer test test_driver_error_injection_demo of mii in test_mii.
   *
   * Parameters:
   *
   *    trans - The ENET transaction.
   */
  virtual function void write_cdn_enet_TxUser_QueueExit(denaliEnetTransaction trans);
    $display("\n##############################################");
    $display("write_cdn_enet_TxUser_QueueExit");
    $display("\n##############################################");
     //Introducing error on respective enum value "errorKind"
     case (errorKind)
       PREAMBLE_ERR: begin
         `uvm_info(get_type_name(),"Inject Preamble error",UVM_DEBUG);
         trans.PreambleDataPreamble[1] = ~trans.PreambleDataPreamble[1] ;
         trans.PreambleDataPreamble[3] = ~trans.PreambleDataPreamble[3] ;
         void'(trans.transSet());
       end
       SFD_ERR: begin
         `uvm_info(get_type_name(), "Inject Sfd error", UVM_DEBUG);
         trans.PreambleSfd[5] = ~trans.PreambleSfd[5];
         void'(trans.transSet());
       end
       TYPE_ERR: begin
         `uvm_info(get_type_name(), "Inject Type error", UVM_DEBUG);
         trans.LengthType = $urandom % 1400;
         void'(trans.transSet());
       end
       CRC_ERR: begin
         `uvm_info(get_type_name(), "Inject Crc error", UVM_DEBUG);
         trans.Crc = $urandom;
         void'(trans.transSet());
       end
     endcase
  endfunction : write_cdn_enet_TxUser_QueueExit

  /*
   * Method: driveTransaction
   *
   * Used to drive the transaction.
   *
   * Parameters:
   *
   *    tr - The ENET transaction.
   */
  virtual task driveTransaction (denaliEnetTransaction tr);
    `uvm_info(get_type_name(), "Sending trans to bfm", UVM_DEBUG);
    void'(pInst.transAdd(tr, 0));
    `uvm_info(get_type_name(), "Transaction add", UVM_DEBUG);
    waitForTransactionEnd(tr);
    `uvm_info(get_type_name(), "Transaction end", UVM_DEBUG);
  endtask

endclass : cdn_enet_vip_driver

`endif // CDN_ENET_UVM_USER_DRIVER_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
