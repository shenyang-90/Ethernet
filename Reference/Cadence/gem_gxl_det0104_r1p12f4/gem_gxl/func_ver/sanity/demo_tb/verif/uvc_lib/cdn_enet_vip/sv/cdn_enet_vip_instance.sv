/**************************************************************************
 File name    : cdn_enet_vip_instance.sv
 Title        : User Instance
 Project      : Ethernet
 Developers   : Cadence Design System.
 Notes        : Developed in compliance with UVM guidelines
 Description  : This class is a derived class of cdnEnetUvmInstance.
                cdnEnetUvmInstance class holds all the callback definition.
                So user can use this class to add on functionality in
                callback functions
***************************************************************************
 Copyright 2008-2010 Cadence Design Systems, Inc.
 All rights reserved worldwide.
***************************************************************************/

/*
 * File: cdn_enet_vip_instance.sv
 * 
 * This file contains the Instance class for the cdn_enet_vip UVC.
 */

`ifndef CDN_ENET_UVM_USER_INSTANCE_SV
`define CDN_ENET_UVM_USER_INSTANCE_SV

/*
 * Typedef: bytelist
 * 
 * Type byte list declaration.
 */
typedef bit [7:0] bytelist [$];

/*
 * File: cdn_enet_vip_instance
 * 
 * This class is a derived class of cdnEnetUvmInstance.
 * The cdnEnetUvmInstance class holds all the callback definition, so user can 
 * use this class to add on functionality in callback functions.
 */
class cdn_enet_vip_instance extends cdnEnetUvmInstance;

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------
  
  `uvm_component_utils(cdn_enet_vip_instance)

  //------------------------------------------------------------------------
  // CONSTRUCTOR.
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   * 
   * The class constructor.
   * It is used to construct cdn_enet_vip_instance objects.
   * 
   * Parameters:
   * 
   *     name   - The name of the class to construct.
   *     parent - The parent class.
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //------------------------------------------------------------------------
  // CALLBACKS.
  //------------------------------------------------------------------------

  virtual function int RxPktEndedPktCbF(ref denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function RxPktEndedPktCbF triggered",UVM_DEBUG);
    return super.RxPktEndedPktCbF(trans);
  endfunction

  virtual function int RxPktStartedPktCbF(ref denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function RxPktStartedPktCbF triggered",UVM_DEBUG);
    return super.RxPktStartedPktCbF(trans);
  endfunction

  virtual function int TxPktEndedPktCbF(ref denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function TxPktEndedPktCbF triggered",UVM_DEBUG);
    return super.TxPktEndedPktCbF(trans);
  endfunction

  virtual function int TxPktStartedPktCbF(ref denaliEnetTransaction trans);
    `uvm_info(get_type_name(), "Callback function TxPktStartedPktCbF triggered",UVM_DEBUG);
    return super.TxPktStartedPktCbF(trans);
  endfunction

  //------------------------------------------------------------------------
  // METHODS.
  //------------------------------------------------------------------------

  /*
   * Method: packfunc
   * 
   * Pack the TX and RX fields in a byte array.
   * 
   * Parameters:
   * 
   *     trans - The ENET transaction.
   */
  virtual function bytelist packfunc(ref denaliEnetTransaction trans);
    bit [7:0] bytestream [$];
    //Global Index
    int j;
    
    //Data preamble
    for(int i=0; i<trans.PreambleDataPreamble.size();i = i+8) begin
      bytestream.push_back( { trans.PreambleDataPreamble[i]   , trans.PreambleDataPreamble[i+1],
                              trans.PreambleDataPreamble[i+2] , trans.PreambleDataPreamble[i+3],
                              trans.PreambleDataPreamble[i+4] , trans.PreambleDataPreamble[i+5],
                              trans.PreambleDataPreamble[i+6] , trans.PreambleDataPreamble[i+7] } );
    end
    
    //SFD
    for(int i=0; i<trans.PreambleSfd.size();i = i+8) begin
      bytestream.push_back( { trans.PreambleSfd[i]   , trans.PreambleSfd[i+1],
                              trans.PreambleSfd[i+2] , trans.PreambleSfd[i+3],
                              trans.PreambleSfd[i+4] , trans.PreambleSfd[i+5],
                              trans.PreambleSfd[i+6] , trans.PreambleSfd[i+7] } );
    end
    
    //Destination Address High
    bytestream.push_back( trans.DestAddrHigh[15:8] );
    bytestream.push_back( trans.DestAddrHigh[ 7:0] );
    //Destination Address Low
    bytestream.push_back( trans.DestAddrLow[31:24] );
    bytestream.push_back( trans.DestAddrLow[23:16] );
    bytestream.push_back( trans.DestAddrLow[15:8]  );
    bytestream.push_back( trans.DestAddrLow[ 7:0]  );
    //Source Address High
    bytestream.push_back( trans.SrcAddrHigh[15:8] );
    bytestream.push_back( trans.SrcAddrHigh[ 7:0] );
    //Source Address Low
    bytestream.push_back( trans.SrcAddrLow[31:24] );
    bytestream.push_back( trans.SrcAddrLow[23:16] );
    bytestream.push_back( trans.SrcAddrLow[15:8]  );
    bytestream.push_back( trans.SrcAddrLow[ 7:0]  );
    
    //Logic to pack VLAN Tagged and Double
    //Tagged Frames
    if(trans.TagKind ==  DENALI_ENET_TAGKIND_VLAN_TAG) begin
      //TagPrefix Q-Tag
      bytestream.push_back(trans.TagPrefixTag[15:8]);
      bytestream.push_back(trans.TagPrefixTag[ 7:0]);
      //Tag Control Information Word Q-Tag
      bytestream.push_back({trans.TagPrefixUserPriority, trans.TagPrefixCfi, trans.TagPrefixVlanId[11:8]} );
      bytestream.push_back(trans.TagPrefixVlanId[7:0]);
    end else if(trans.TagKind == DENALI_ENET_TAGKIND_VLAN_DOUBLE_TAG) begin
      //SVlanTagPrefix
      bytestream.push_back(trans.SVlanTagPrefixTag[15:8]);
      bytestream.push_back(trans.SVlanTagPrefixTag[ 7:0]);
      //SVlanTag Control Information Word SVlanTag
      bytestream.push_back({trans.SVlanTagPrefixUserPriority, trans.TagPrefixCfi, trans.TagPrefixVlanId[11:8]} );
      bytestream.push_back(trans.SVlanTagPrefixVlanId[7:0]);
      //TagPrefix Q-Tag
      bytestream.push_back(trans.TagPrefixTag[15:8]);
      bytestream.push_back(trans.TagPrefixTag[ 7:0]);
      //Tag Control Information Word Q-Tag
      bytestream.push_back({trans.TagPrefixUserPriority, trans.TagPrefixCfi, trans.TagPrefixVlanId[11:8]} );
      bytestream.push_back(trans.TagPrefixVlanId[7:0]);
    end
    
    //Length Type
    bytestream.push_back(trans.LengthType[15:8]);
    bytestream.push_back(trans.LengthType[ 7:0]);
    
    //DataPayload
    foreach(trans.DataPayload[i]) begin
      bytestream.push_back(trans.DataPayload[i]);
    end
    
    //Crc field
    bytestream.push_back(trans.Crc[31:24]);
    bytestream.push_back(trans.Crc[23:16]);
    bytestream.push_back(trans.Crc[15:8]);
    bytestream.push_back(trans.Crc[ 7:0]);
    
    return(bytestream);
  endfunction  : packfunc

endclass : cdn_enet_vip_instance

`endif // CDN_ENET_UVM_USER_INSTANCE_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------

