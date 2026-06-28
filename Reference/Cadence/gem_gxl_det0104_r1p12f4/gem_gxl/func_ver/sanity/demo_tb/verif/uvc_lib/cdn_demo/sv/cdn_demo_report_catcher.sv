//----------------------------------------------------------------------------
// Company    : Cadence Design Systems
// Copyright (c) 2017 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------

`ifndef CDN_DEMO_REPORT_CATCHER_SV
`define CDN_DEMO_REPORT_CATCHER_SV

//------------------------------------------------------------------------
// Class: cdn_demo_report_catcher
// This report catcher extends the UVM default report catcher to enable 
// the TB to emit fail banners on errors or fatals that will or can stop
// the simulation without going through the check_phase or report_phase.
// This is important if the +UVM_MAX_QUIT_COUNT option is used.
// Also UVM_FATAL can lead to immediate stop of simulation and this gets
// trapped here and an error thrown with the fail banner printed.
// This class should be instanced inside the VE env and the 
// uvm_report_cb::add() function used to enable it. Please see the UVM 
// documentation around the uvm_report_catcher for more detailed info.
// NOTE this object does not use the uvm automation macros because the
//------------------------------------------------------------------------
class cdn_demo_report_catcher extends uvm_report_catcher;

  //------------------------------------------------------------------------
  // CONTROL MEMBER VARIABLES
  //------------------------------------------------------------------------

  // Variable: pass_fail_message_en
  // This control enables the fail message/banner to be disabled.
  bit pass_fail_message_en = 1;
 
  //------------------------------------------------------------------------
  // EXTEND OR OVERRIDE BASE METHODS
  //------------------------------------------------------------------------

  //------------------------------------------------------------------------
  // Function: new
  // Creates and initializes a new object for this class.
  //------------------------------------------------------------------------
  function new(string name="cdn_demo_report_catcher");
    super.new(name);
  endfunction : new  

  //------------------------------------------------------------------------
  // Function: catch
  // This function allows us to catch UVM_ERROR and UVM_FATAL calls before
  // they are processed fully and this we can add the FAIL message/banner
  // to the simulation logfile and screen via uvm_info with verbosity 
  // UVM_NONE so that it is always printed unless the pass_fail_message_en
  // control knob disables it.
  //------------------------------------------------------------------------
  function action_e catch();
    if(get_severity() == UVM_ERROR || get_severity() == UVM_FATAL) begin
      if(pass_fail_message_en) begin
        `uvm_info(get_type_name(),`CDN_DEMO_TB_FAIL_STRING,UVM_NONE)
      end
    end
    return THROW;
  endfunction : catch
  
endclass : cdn_demo_report_catcher

`endif
//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------