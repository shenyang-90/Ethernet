//----------------------------------------------------------------------------
// Project    : cdn_clock UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2015 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description: 
// This file defines the agent for the cdn_clock UVC.
//----------------------------------------------------------------------------

`ifndef CDN_CLOCK_AGENT_SV
`define CDN_CLOCK_AGENT_SV

class cdn_clock_agent extends uvm_agent;

    //------------------------------------------------------------------------
    // CONTROL MEMBER VARIABLES.
    //------------------------------------------------------------------------

    /*
     * Variable: is_active
     * 
     * This member variable controls if the Module UVC env is active or passive,
     * i.e. is it a stand alone module level env - UVM_ACTIVE or is it part of a
     * system/sub-system level env - UVM_PASSIVE.
     */
    protected uvm_active_passive_enum is_active = UVM_ACTIVE;
  
    //-----------------------
    // Reference
    //-----------------------

    /*
     * Variable: clk_ref
     * 
     * The reference clock period in ps.
     */
    rand int clk_ref  = 1000;

    //-----------------------
    // Frequency Divisions
    //-----------------------

    /*
     * Variable clk_div0
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_0 will be: clk_div0 * clk_ref.
     */
    rand int clk_div0 = 1000;
    
    /*
     * Variable clk_div1
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_1 will be: clk_div1 * clk_ref.
     */    
    rand int clk_div1 = 1000;
    
    /*
     * Variable clk_div2
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_2 will be: clk_div2 * clk_ref.
     */    
    rand int clk_div2 = 1000;
    
    /*
     * Variable clk_div3
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_3 will be: clk_div3 * clk_ref.
     */    
    rand int clk_div3 = 1000;
    
    /*
     * Variable clk_div4
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_4 will be: clk_div4 * clk_ref.
     */    
    rand int clk_div4 = 1000;
    
    /*
     * Variable clk_div5
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_5 will be: clk_div5 * clk_ref.
     */    
    rand int clk_div5 = 1000;
    
    /*
     * Variable clk_div6
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_6 will be: clk_div6 * clk_ref.
     */    
    rand int clk_div6 = 1000;
    
    /*
     * Variable clk_div7
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_7 will be: clk_div7 * clk_ref.
     */    
    rand int clk_div7 = 1000;
    
    /*
     * Variable clk_div8
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_8 will be: clk_div8 * clk_ref.
     */    
    rand int clk_div8 = 1000;
    
    /*
     * Variable clk_div9
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * The period of sig_clock_9 will be: clk_div9 * clk_ref.
     */    
    rand int clk_div9 = 1000;

    //-----------------------
    // Clock delays
    //-----------------------

    /*
     * Variable clk_del0
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_0.
     */
    rand int clk_del0 = 0;
    
    /*
     * Variable clk_del1
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_1.
     */    
    rand int clk_del1 = 0;
    
    /*
     * Variable clk_del2
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_2.
     */
    rand int clk_del2 = 0;
    
    /*
     * Variable clk_del3
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_3.
     */
    rand int clk_del3 = 0;
    
    /*
     * Variable clk_del4
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_4.
     */
    rand int clk_del4 = 0;
    
    /*
     * Variable clk_del5
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_5.
     */
    rand int clk_del5 = 0;
    
    /*
     * Variable clk_del6
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_6.
     */
    rand int clk_del6 = 0;
    
    /*
     * Variable clk_del7
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_7.
     */
    rand int clk_del7 = 0;
    
    /*
     * Variable clk_del8
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_8.
     */
    rand int clk_del8 = 0;
    
    /*
     * Variable clk_del9
     * 
     * This clock agent will drive/monitor 10 clock signals.
     * This is the absolute delay in ps associated with the sig_clock_9.
     */
    rand int clk_del9 = 0;
  
    //------------------------------------------------------------------------
    // COMPONENTS.
    //------------------------------------------------------------------------

    /*
     * Variable: driver
     * 
     * The driver of the cdn_clock UVC.
     */
    cdn_clock_driver driver;
    
    /*
     * Variable: monitor
     * 
     * The monitor of the cdn_clock UVC.
     */
    cdn_clock_monitor monitor;

    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_clock_agent)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
      `uvm_field_object(driver, UVM_REFERENCE)
      `uvm_field_int(clk_ref , UVM_ALL_ON)
      `uvm_field_int(clk_div0, UVM_ALL_ON)
      `uvm_field_int(clk_div1, UVM_ALL_ON)
      `uvm_field_int(clk_div2, UVM_ALL_ON)
      `uvm_field_int(clk_div3, UVM_ALL_ON)
      `uvm_field_int(clk_div4, UVM_ALL_ON)
      `uvm_field_int(clk_div5, UVM_ALL_ON)
      `uvm_field_int(clk_div6, UVM_ALL_ON)
      `uvm_field_int(clk_div7, UVM_ALL_ON)
      `uvm_field_int(clk_div8, UVM_ALL_ON)
      `uvm_field_int(clk_div9, UVM_ALL_ON)
      `uvm_field_int(clk_del0, UVM_ALL_ON)
      `uvm_field_int(clk_del1, UVM_ALL_ON)
      `uvm_field_int(clk_del2, UVM_ALL_ON)
      `uvm_field_int(clk_del3, UVM_ALL_ON)
      `uvm_field_int(clk_del4, UVM_ALL_ON)
      `uvm_field_int(clk_del5, UVM_ALL_ON)
      `uvm_field_int(clk_del6, UVM_ALL_ON)
      `uvm_field_int(clk_del7, UVM_ALL_ON)
      `uvm_field_int(clk_del8, UVM_ALL_ON)
      `uvm_field_int(clk_del9, UVM_ALL_ON)        
    `uvm_component_utils_end

    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    /*
     * Constructor: new
     * 
     * The class constructor.
     * It is used to construct cdn_clock_agent objects.
     * 
     * Parameters:
     * 
     *    name   - The name of the object.
     *    parent - The parent class.
     */
    function new (string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    /*
     * Method: build_phase
     * 
     * This UVM phase is used for building the testbench component hierarchy.
     * For cdn_clock_agent, it applies configurations and construct monitor
     * and/or driver.
     *  
     * Parameters:
     * 
     *    phase - The UVM phase object.
     */    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db #(int)::set(this, "driver", "ref_period", clk_ref );
      uvm_config_db #(int)::set(this, "driver", "divider_0", clk_div0);
      uvm_config_db #(int)::set(this, "driver", "divider_1", clk_div1);
      uvm_config_db #(int)::set(this, "driver", "divider_2", clk_div2);
      uvm_config_db #(int)::set(this, "driver", "divider_3", clk_div3);
      uvm_config_db #(int)::set(this, "driver", "divider_4", clk_div4);
      uvm_config_db #(int)::set(this, "driver", "divider_5", clk_div5);
      uvm_config_db #(int)::set(this, "driver", "divider_6", clk_div6);
      uvm_config_db #(int)::set(this, "driver", "divider_7", clk_div7);
      uvm_config_db #(int)::set(this, "driver", "divider_8", clk_div8);
      uvm_config_db #(int)::set(this, "driver", "divider_9", clk_div9);
      uvm_config_db #(int)::set(this, "driver", "clk0_delay", clk_del0);
      uvm_config_db #(int)::set(this, "driver", "clk1_delay", clk_del1);
      uvm_config_db #(int)::set(this, "driver", "clk2_delay", clk_del2);
      uvm_config_db #(int)::set(this, "driver", "clk3_delay", clk_del3);
      uvm_config_db #(int)::set(this, "driver", "clk4_delay", clk_del4);
      uvm_config_db #(int)::set(this, "driver", "clk5_delay", clk_del5);
      uvm_config_db #(int)::set(this, "driver", "clk6_delay", clk_del6);
      uvm_config_db #(int)::set(this, "driver", "clk7_delay", clk_del7);
      uvm_config_db #(int)::set(this, "driver", "clk8_delay", clk_del8);
      uvm_config_db #(int)::set(this, "driver", "clk9_delay", clk_del9);
      if(is_active == UVM_ACTIVE) begin
          driver = cdn_clock_driver::type_id::create("driver", this);
      end
      monitor = cdn_clock_monitor::type_id::create("monitor", this);
    endfunction : build_phase

endclass : cdn_clock_agent

`endif

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
