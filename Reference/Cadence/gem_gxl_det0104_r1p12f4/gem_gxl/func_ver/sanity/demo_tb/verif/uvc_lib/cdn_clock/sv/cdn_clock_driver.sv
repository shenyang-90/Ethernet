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
// This file defines the driver for the cdn_clock UVC.
//----------------------------------------------------------------------------

`ifndef CDN_CLOCK_DRIVER_SV
`define CDN_CLOCK_DRIVER_SV

class cdn_clock_driver extends uvm_driver;

    //------------------------------------------------------------------------
    // COMPONENTS.
    //------------------------------------------------------------------------

    // Reference clock period in ps
    int  ref_period = 2000; // 1 GHz
    
    // Clock period multiplier (divider for the frequency)
    int  divider_0 = 8;   // 125 MHz
    int  divider_1 = 4;   // 250 Hz
    int  divider_2 = 2;   // 500 MHz
    int  divider_3 = 40;  //  25 MHz
    int  divider_4 = 400; // 2.5 MHz
    int  divider_5 = 6;   // 166 MHz
    int  divider_6 = 10;  // 100 MHz
    int  divider_7 = 8;   // 125 MHz
    int  divider_8 = 8;   // 120 MHz
    int  divider_9 = 4;   // 250 MHz

    // Clock delay in ps
    int clk0_delay = 0;
    int clk1_delay = 0;
    int clk2_delay = 0;
    int clk3_delay = 0;
    int clk4_delay = 0;
    int clk5_delay = 0;
    int clk6_delay = 0;
    int clk7_delay = 0;
    int clk8_delay = 0;
    int clk9_delay = 0;

    //---------------------
    // Auxiliaries
    //---------------------

    // Store clock emi-period
    real half_clk0_real;
    real half_clk1_real;
    real half_clk2_real;
    real half_clk3_real;
    real half_clk4_real;
    real half_clk5_real;
    real half_clk6_real;
    real half_clk7_real;
    real half_clk8_real;
    real half_clk9_real;

    // Used to add a random clock skew in [0:200] ps to the clock delay
    real clk0_skew;
    real clk1_skew;
    real clk2_skew;
    real clk3_skew;
    real clk4_skew;
    real clk5_skew;
    real clk6_skew;
    real clk7_skew;
    real clk8_skew;
    real clk9_skew;

    //------------------------------------------------------------------------
    // DUT INTERFACE
    //------------------------------------------------------------------------

    virtual interface cdn_clock_if clock_if;
   
    //------------------------------------------------------------------------
    // UVM AUTOMATION MACROS.
    //------------------------------------------------------------------------

    // The component utils marco provides base virtual methods like 
    // get_type_name and create.
    `uvm_component_utils_begin(cdn_clock_driver)
      `uvm_field_int(ref_period, UVM_ALL_ON)
      `uvm_field_int(divider_0, UVM_ALL_ON)
      `uvm_field_int(divider_1, UVM_ALL_ON)
      `uvm_field_int(divider_2, UVM_ALL_ON)
      `uvm_field_int(divider_3, UVM_ALL_ON)
      `uvm_field_int(divider_4, UVM_ALL_ON)
      `uvm_field_int(divider_5, UVM_ALL_ON)
      `uvm_field_int(divider_6, UVM_ALL_ON)
      `uvm_field_int(divider_7, UVM_ALL_ON)
      `uvm_field_int(divider_8, UVM_ALL_ON)
      `uvm_field_int(divider_9, UVM_ALL_ON)
      `uvm_field_int(clk0_delay, UVM_ALL_ON)
      `uvm_field_int(clk1_delay, UVM_ALL_ON)
      `uvm_field_int(clk2_delay, UVM_ALL_ON)
      `uvm_field_int(clk3_delay, UVM_ALL_ON)
      `uvm_field_int(clk4_delay, UVM_ALL_ON)
      `uvm_field_int(clk5_delay, UVM_ALL_ON)
      `uvm_field_int(clk6_delay, UVM_ALL_ON)
      `uvm_field_int(clk7_delay, UVM_ALL_ON)
      `uvm_field_int(clk8_delay, UVM_ALL_ON)
      `uvm_field_int(clk9_delay, UVM_ALL_ON)
    `uvm_component_utils_end
   
    //------------------------------------------------------------------------
    // EXTEND OR OVERRIDE BASE METHODS
    //------------------------------------------------------------------------

    /*
     * Constructor: new
     * 
     * The class constructor.
     * It is used to construct cdn_clock_driver objects.
     * 
     * Parameters:
     * 
     *    name   - The name of the object.
     *    parent - The parent class.
     */
    function new(string name = "cdn_clock_driver", uvm_component parent);
      super.new(name, parent);
    endfunction : new
   
    /*
     * Method: build_phase
     * 
     * This UVM phase is used for building the testbench component hierarchy.
     *  
     * Parameters:
     * 
     *    phase - The UVM phase object.
     */   
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual cdn_clock_if)::get(this, "", "clock_if", clock_if))
        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".clock_if"})
    endfunction: build_phase

    //------------------------------------------------------------------------
    // DEFINE TASKS
    //------------------------------------------------------------------------

    /*
     * Method: run_phase
     * 
     * This UVM phase performs the DUT simulation.
     * 
     * Parameters:
     * 
     *   phase - The UVM phase object. 
     */
    virtual task run_phase(uvm_phase phase);
      uvm_report_info(get_type_name(), "Starting the driver run task", UVM_HIGH);
      pre_calc();
      fork
        drive_clock_0();
        drive_clock_1();
        drive_clock_2();
        drive_clock_3();
        drive_clock_4();
        drive_clock_5();
        drive_clock_6();
        drive_clock_7();
        drive_clock_8();
        drive_clock_9();
      join
    endtask : run_phase

    /*
     * Function: pre_calc
     * 
     * This task calculate the period and the skew of each clock signal.
     */
    virtual task pre_calc();
      half_clk0_real = ref_period * real'(divider_0) / 2000.0;
      half_clk1_real = ref_period * real'(divider_1) / 2000.0;
      half_clk2_real = ref_period * real'(divider_2) / 2000.0;
      half_clk3_real = ref_period * real'(divider_3) / 2000.0;
      half_clk4_real = ref_period * real'(divider_4) / 2000.0;
      half_clk5_real = ref_period * real'(divider_5) / 2000.0;
      half_clk6_real = ref_period * real'(divider_6) / 2000.0;
      half_clk7_real = ref_period * real'(divider_7) / 2000.0;
      half_clk8_real = ref_period * real'(divider_8) / 2000.0;
      half_clk9_real = ref_period * real'(divider_9) / 2000.0;
 
      clk0_skew = real'(($urandom_range(0,200) + clk0_delay) / 1000.0);
      clk1_skew = real'(($urandom_range(0,200) + clk1_delay) / 1000.0);
      clk2_skew = real'(($urandom_range(0,200) + clk2_delay) / 1000.0);
      clk3_skew = real'(($urandom_range(0,200) + clk3_delay) / 1000.0);
      clk4_skew = real'(($urandom_range(0,200) + clk4_delay) / 1000.0);
      clk5_skew = real'(($urandom_range(0,200) + clk5_delay) / 1000.0);
      clk6_skew = real'(($urandom_range(0,200) + clk6_delay) / 1000.0);
      clk7_skew = real'(($urandom_range(0,200) + clk7_delay) / 1000.0);
      clk8_skew = real'(($urandom_range(0,200) + clk8_delay) / 1000.0);
      clk9_skew = real'(($urandom_range(0,200) + clk9_delay) / 1000.0);

      uvm_report_info(get_type_name(), $psprintf("CLK0 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk0_real), (ref_period*divider_0/100), clk0_delay, (1000*clk0_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK1 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk1_real), (ref_period*divider_1/100), clk1_delay, (1000*clk1_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK2 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk2_real), (ref_period*divider_2/100), clk2_delay, (1000*clk2_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK3 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk3_real), (ref_period*divider_3/100), clk3_delay, (1000*clk3_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK4 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk4_real), (ref_period*divider_4/100), clk4_delay, (1000*clk4_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK5 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk5_real), (ref_period*divider_5/100), clk5_delay, (1000*clk5_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK6 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk6_real), (ref_period*divider_6/100), clk6_delay, (1000*clk6_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK7 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk7_real), (ref_period*divider_7/100), clk7_delay, (1000*clk7_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK8 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk8_real), (ref_period*divider_8/100), clk8_delay, (1000*clk8_skew)), UVM_HIGH);
      uvm_report_info(get_type_name(), $psprintf("CLK9 | f = %7.3f (MHz) | T = %5d (ps) | delay = %5d (ps) | skew = %3.2f (ps)", (500.0/half_clk9_real), (ref_period*divider_9/100), clk9_delay, (1000*clk9_skew)), UVM_HIGH);
    endtask : pre_calc

    /*
     * Function: drive_clock_0
     * 
     * This task drives the clock 0 signal.
     */
    task drive_clock_0();
      clock_if.sig_clock_0 = 1'b1;
      #(clk0_skew) clock_if.sig_clock_0 = 1'b0;
      forever begin
        #(half_clk0_real);
        clock_if.sig_clock_0 = ~clock_if.sig_clock_0;
      end
    endtask : drive_clock_0
    
    /*
     * Function: drive_clock_1
     * 
     * This task drives the clock 1 signal.
     */
    task drive_clock_1();
      clock_if.sig_clock_1 = 1'b1;
      #(clk1_skew) clock_if.sig_clock_1 = 1'b0;
      forever begin
        #(half_clk1_real);
        clock_if.sig_clock_1 = ~clock_if.sig_clock_1;
      end
    endtask : drive_clock_1
    
    /*
     * Function: drive_clock_2
     * 
     * This task drives the clock 2 signal.
     */
    task drive_clock_2();
      clock_if.sig_clock_2 = 1'b1;
      #(clk2_skew) clock_if.sig_clock_2 = 1'b0;
      forever begin
        #(half_clk2_real);
        clock_if.sig_clock_2 = ~clock_if.sig_clock_2;
      end
    endtask : drive_clock_2
    
    /*
     * Function: drive_clock_3
     * 
     * This task drives the clock 3 signal.
     */
    task drive_clock_3();
      clock_if.sig_clock_3 = 1'b1;
      #(clk3_skew) clock_if.sig_clock_3 = 1'b0;
      forever begin
        #(half_clk3_real);
        clock_if.sig_clock_3 = ~clock_if.sig_clock_3;
      end
    endtask : drive_clock_3
    
    /*
     * Function: drive_clock_4
     * 
     * This task drives the clock 4 signal.
     */
    task drive_clock_4();
      clock_if.sig_clock_4 = 1'b1;
      #(clk4_skew) clock_if.sig_clock_4 = 1'b0;
      forever begin
        #(half_clk4_real);
        clock_if.sig_clock_4 = ~clock_if.sig_clock_4;
      end
    endtask : drive_clock_4
    
    /*
     * Function: drive_clock_5
     * 
     * This task drives the clock 5 signal.
     */
    task drive_clock_5();
      clock_if.sig_clock_5 = 1'b1;
      #(clk5_skew) clock_if.sig_clock_5 = 1'b0;
      forever begin
        #(half_clk5_real);
        clock_if.sig_clock_5 = ~clock_if.sig_clock_5;
      end
    endtask : drive_clock_5
    
    /*
     * Function: drive_clock_6
     * 
     * This task drives the clock 6 signal.
     */
    task drive_clock_6();
        clock_if.sig_clock_6 = 1'b1;
        #(clk6_skew) clock_if.sig_clock_6 = 1'b0;
        forever begin
            #(half_clk6_real);
            clock_if.sig_clock_6 = ~clock_if.sig_clock_6;
        end
    endtask : drive_clock_6
    
    /*
     * Function: drive_clock_7
     * 
     * This task drives the clock 7 signal.
     */
    task drive_clock_7();
      clock_if.sig_clock_7 = 1'b1;
      #(clk7_skew) clock_if.sig_clock_7 = 1'b0;
      forever begin
        #(half_clk7_real);
        clock_if.sig_clock_7 = ~clock_if.sig_clock_7;
      end
    endtask : drive_clock_7
    
    /*
     * Function: drive_clock_8
     * 
     * This task drives the clock 8 signal.
     */
    task drive_clock_8();
      clock_if.sig_clock_8 = 1'b1;
      #(clk8_skew) clock_if.sig_clock_8 = 1'b0;
      forever begin
        #(half_clk8_real);
        clock_if.sig_clock_8 = ~clock_if.sig_clock_8;
      end
    endtask : drive_clock_8
    
    /*
     * Function: drive_clock_9
     * 
     * This task drives the clock 9 signal.
     */
    task drive_clock_9();
      clock_if.sig_clock_9 = 1'b1;
      #(clk9_skew) clock_if.sig_clock_9 = 1'b0;
      forever begin
        #(half_clk9_real);
        clock_if.sig_clock_9 = ~clock_if.sig_clock_9;
      end
    endtask : drive_clock_9

endclass : cdn_clock_driver

`endif // CDN_CLOCK_DRIVER_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
