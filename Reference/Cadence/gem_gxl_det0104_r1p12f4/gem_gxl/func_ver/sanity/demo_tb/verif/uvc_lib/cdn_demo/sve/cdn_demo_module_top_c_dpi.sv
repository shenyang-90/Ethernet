//----------------------------------------------------------------------------
// Project    : cdn_demo UVC
// Author     : smckelvi@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description :
// If we are using C based stimulus then include the C based DPI connections
//----------------------------------------------------------------------------


//------------------------------------------------------------------------
// C Based Stimulus
//------------------------------------------------------------------------

/** Class describing single string message (passed between C and SV parts of TB) */
class cdn_demo_string_msg;
  string    m_str;
  event     m_completed_evt;

  function new(input string str);
    m_str = str;
  endfunction //new

endclass : cdn_demo_string_msg


interface cdn_demo_module_top_c_dpi (input logic clk, input interrupt);

   `ifdef CDN_DEMO_C

   //------------------------------------------------------------------------
   // Imports/Exports
   //------------------------------------------------------------------------

   import "DPI-C" context task main(input int argc, input int _argv []);

   import "DPI-C" context function cdn_demo_write8 (input longint addr, input int unsigned val);
   import "DPI-C" context function int unsigned cdn_demo_read8(input longint addr);
   import "DPI-C" context function cdn_demo_write16 (input longint addr, input int unsigned val);
   import "DPI-C" context function int unsigned cdn_demo_read16(input longint addr);
   import "DPI-C" context function cdn_demo_write32 (input longint addr, input int unsigned val);
   import "DPI-C" context function int unsigned cdn_demo_read32(input longint addr);

   import "DPI-C" context task cdn_demo_irq_handler (input longint DeviceID);

   export "DPI" task csp_demo_write32;
   export "DPI" task csp_demo_read32;
   export "DPI" task csp_delay_us;
   export "DPI" task csp_printf_error;
   export "DPI" task csp_printf_warning;
   export "DPI" task csp_printf_debug;
   export "DPI" task csp_printf_info;
   export "DPI" task cdn_demo_get_gpio;
   export "DPI" task cdn_demo_set_gpio;
   export "DPI" function get_urandom;

  // ******** Threading ********

   export "DPI" task cdn_demo_spawn_thread;
   import "DPI-C" context task cdn_demo_launch_thread(input int id, input chandle param, input chandle proc);

  // ******** set_config call ********

   import "DPI-C" context function cdn_demo_set_config();

  // ******** String based communication ********

  /** C-side callback called when new string message arrives from UVM/SV
   * \param str String to be passed
   */
  import "DPI-C" context function cdn_demo_on_new_str_msg_to_c_cb(input string str);


  /** SV-side callback called when new string message arrives from C
   * \param str Passed string value
   */
  export "DPI" function cdn_demo_on_new_str_msg_to_sv_cb;


   //------------------------------------------------
   // INTERFACE SIGNALS.
   //------------------------------------------------------------------------

   // General purpose IO signals that can be driver or monitored by a UVC.
   logic [63:0] gpio;

   // ------------------------------------------------------------------------
   // Imports
   // ------------------------------------------------------------------------

   // UVM class library compiled in a package
   import uvm_pkg::*;

   // Bring in the rest of the library (macros)
   `include "uvm_macros.svh"

   //------------------------------------------------------------------------
   // CLOCKING BLOCKS
   //------------------------------------------------------------------------

   clocking cb @ (posedge clk);
     inout gpio;
   endclocking


   //------------------------------------------------------------------------
   // Internal Variables
   //------------------------------------------------------------------------

   /** Next free thread's ID */
   static int s_new_thread_id = 0;


   // ------------------------------------------------------------------------
   // Internal tasks and functions
   // ------------------------------------------------------------------------

   task csp_demo_write32 (input int _addr, input int _data);
      cdn_demo_pkg::cdn_demo_env env;
      $cast(env, uvm_top.find("*.demo_env"));
      env.reg_adapter.write(_addr,_data);
   endtask : csp_demo_write32

   task csp_demo_read32 (input int _addr, output int _data);
      cdn_demo_pkg::cdn_demo_env env;
      $cast(env, uvm_top.find("*.demo_env"));
      env.reg_adapter.read(_addr,_data);
   endtask : csp_demo_read32

   // ------------------------------------------------------------------------
   // Function: cdn_demo_set_gpio
   // Set a GPIO to a specific value when the mask bit is not set - e.g. the
   // out is set at the following:
   // gpio[n] = mask[n] ? noChange : newValue;

   task cdn_demo_set_gpio (input longint _gpio, input longint _mask);
      byte unsigned i;
      for (i=0; i<64; i++) begin
         if (~_mask[i]) begin
            cb.gpio[i] <= _gpio[i];
         end
      end
   endtask : cdn_demo_set_gpio

   task cdn_demo_get_gpio (output longint _gpio);
      _gpio = cb.gpio;
   endtask : cdn_demo_get_gpio

   // Initialize the gpio
   initial
     gpio = {64{1'bz}};

   task csp_delay_us (input int delay_us);
      `uvm_info("cdn_demo_module_top", $psprintf("Waiting for %0dus.", delay_us), UVM_LOW)
      repeat (delay_us)
         @(posedge clk);
   endtask : csp_delay_us

   task csp_printf_error(string _str);
      assert (0) begin : a_csf_print_error end
      else
         `uvm_error("cdn_demo_module_top", _str)
   endtask : csp_printf_error

   task csp_printf_warning(string _str);
      `uvm_warning("cdn_demo_module_top", _str)
   endtask : csp_printf_warning

   task csp_printf_debug(string _str);
      `uvm_info("cdn_demo_module_top", _str, UVM_DEBUG)
   endtask : csp_printf_debug

   task csp_printf_info(string _str);
      `uvm_info("cdn_demo_module_top", _str, UVM_LOW)
   endtask : csp_printf_info


  // ******** Threading ********

  /** Spawns new thread
   * \param param Parameter to be passed to the thread
   * \param proc Thread routine pointer
   * \param id Place where new thread's ID would be stored
   */
  task cdn_demo_spawn_thread(input chandle param, input chandle proc, output int id);

    fork
      id = s_new_thread_id++;
      cdn_demo_launch_thread(.id(id), .param(param), .proc(proc));
    join_none

  endtask : cdn_demo_spawn_thread


   //------------------------------------------------------------------------
   // C Based Interrupt DPI
   //------------------------------------------------------------------------

   // Call the external interrupt routine at an interrupt
   initial begin
     #10ns;
     forever begin
       if (~interrupt)
         @(posedge interrupt);
       cdn_demo_irq_handler(0);
       // Add a 10ns just in case of the risk of an infinite loop. Should
       // not be necessary so added as a safety precaution.
       #10ns;
     end
   end

   // ------------------------------------------------------------------------
   // External API
   // ------------------------------------------------------------------------

   // The c_dpi uses an interface and it is not possible to call tasks, such
   // as main directly from other parts of the hierarchy as the main task is
   // an import and for some reason system verilog does not like this. We
   // therefore wrap the DPI-C calls around standard system verilog calls.

   task c_api_main(input int argc, input int argv [3:0]);
      main(argc, argv);
   endtask : c_api_main

   function int unsigned c_api_demo_read8(input longint addr);
      return cdn_demo_read8(addr);
   endfunction : c_api_demo_read8

   function c_api_demo_write8 (input longint addr, input int unsigned val);
      void'(cdn_demo_write8(addr, val));
   endfunction : c_api_demo_write8


   function int unsigned c_api_demo_read16(input longint addr);
      return cdn_demo_read16(addr);
   endfunction : c_api_demo_read16

   function c_api_demo_write16 (input longint addr, input int unsigned val);
      void'(cdn_demo_write16(addr, val));
   endfunction : c_api_demo_write16

   function int unsigned c_api_demo_read32(input longint addr);
      return cdn_demo_read32(addr);
   endfunction : c_api_demo_read32

   function c_api_demo_write32 (input longint addr, input int unsigned val);
      void'(cdn_demo_write32(addr, val));
   endfunction : c_api_demo_write32

   function c_api_demo_set_config();
      void'(cdn_demo_set_config());
   endfunction : c_api_demo_set_config

  function int unsigned get_urandom();
    return $urandom();
  endfunction : get_urandom

  // ******** String based communication ********


  /* Communication protocol overview:
   *   - String starting with '@' and terminated with ';' characters is
   *       considered as a command / response and it is processed internally
   *       in SV, without being passed to listeners
   *   - String that starts with any other character is passed to listeners
   *   - Command / response syntax:
   *      @cmd_name,param0,param1,param2,...,paramN-1;
   *   - Predefined commands:
   *       * Utility routines:
   *
   *          @ECHO,value;                                    <- Sends string that should be returned back in ECHO_RESP
   *          @ECHO_RESP,value;                               <- Response for ECHO
   *
   *       * UVM utility routines:
   *
   *          @TOPO_DUMP;                                     <- Dumps UVM topology (call to uvm_top.print_topology())
   *
   *       * uvm_config_db access routines:
   *
   *          @CFG_DB_DUMP;                                   <- Dumps database (call to uvm_config_db::dump())
   *
   *
   *          @GET_CFG_DB_INT,ctx_comp_name,inst_name,name;               <- Reads uvm_config_db#(int)
   *          @GET_SET_CFG_DB_INT,ctx_comp_name,inst_name,name,new_value; <- Reads uvm_config_db#(int) and sets to new value (atomic operation)
   *          @CFG_DB_INT_VAL,name,status,value;                          <- Response for GET_CFG_DB_INT / GET_AND_SET_CFG_DB_INT
   *          @SET_CFG_DB_INT,ctx_comp_name,inst_name,name,value;         <- Sets uvm_config_db#(int)
   *          @CFG_DB_INT_SET,name,value;                                 <- Response for SET_CFG_DB_INT
   *
   *          @GET_CFG_DB_STR,ctx_comp_name,inst_name,name;               <- Reads uvm_config_db#(string)
   *          @GET_SET_CFG_DB_STR,ctx_comp_name,inst_name,name,new_value; <- Reads uvm_config_db#(string) and sets to new value (atomic operation)
   *          @CFG_DB_STR_VAL,name,status,value;                          <- Response for GET_CFG_DB_STRING /GET_SET_CFG_DB_STR
   *          @SET_CFG_DB_STR,ctx_comp_name,inst_name,name,value;         <- Sets uvm_config_db#(string)
   *          @CFG_DB_STR_SET,name,value;                                  <- Response for SET_CFG_DB_STRING
   *
   *          where:
   *            ctx_comp_name   - Context's component name (to be provided as first parameter
   *                              of uvm_config_db::get/set), starting point for searching;
   *                              Special values:
   *                                "-"     : In such case null is assumed in UVM get/set call
   *                                "$root" : In such case uvm_root::get() is assumed in UVM get/set call
   *            inst_name       - Path (pattern) to component that contains requested field
   *            name            - Name of field to be read/written
   *            status          - Operation status (1 for success, 0 for error)
   */



  // **** SV -> C ****


  /** Passes string value to the C part of TB
   * \param str String to be passed
   */
  function void cdn_demo_pass_str_to_c(input string str);

    void'(cdn_demo_on_new_str_msg_to_c_cb(str));

  endfunction : cdn_demo_pass_str_to_c


  // **** C -> SV ****


  /** SV-side callback called when new string message arrives from C
   * \param str Passed string value
   */
  function void cdn_demo_on_new_str_msg_to_sv_cb(input string str);

    cdn_demo_service_str_msg_from_c(str);

  endfunction : cdn_demo_on_new_str_msg_to_sv_cb



  /** Services string message received from C
   * \param str Passed string value
   */
  function void cdn_demo_service_str_msg_from_c(input string str);

    `uvm_info("cdn_demo_service_str_msg_from_c", $psprintf("Received from C: \"%s\"", str), UVM_LOW)

    // Is it a command string?
    if (str[0] == "@" && str[str.len()-1] == ";")
    begin
      string
        tokens[$];

      uvm_split_string(.str(str.substr(1, str.len()-2)), .sep(","), .values(tokens));

      if (tokens.size() > 0)
      begin

        string
          cmd_name;

        cmd_name = tokens.pop_front();

        //`uvm_info("cdn_demo_service_str_msg_from_c", $psprintf("Command \"%0s\"recognised, parameters:",
        //  cmd_name), UVM_LOW)
        //foreach (tokens[i])
        //  `uvm_info("cdn_demo_service_str_msg_from_c", $psprintf("  - param[%0d] = \"%0s\"",
        //      i, tokens[i]), UVM_LOW)

        cdn_demo_process_c_str_cmd(.cmd_name(cmd_name), .cmd_params(tokens));

      end //if (tokens.size() > 0)

    end //if (str[0] = "@" && str[str.len()-1] == ";")
    else begin
      `uvm_error("[cdn_demo_module_top_c_dpi]",$psprintf("Unrecognized string received: \"%s\"", str))
    end


    // For debug purpose - passing back to C
    //#(1us);
    //cdn_demo_pass_str_to_c(str);

  endfunction : cdn_demo_service_str_msg_from_c



  /** Parses UVM component string and tries to find corresponding uvm_component
   * \param comp_str Component string ($root and "-" characters are allowed)
   * \return UVM component
   */
  function uvm_component cdn_demo_parse_ctx_comp(string comp_str);

    uvm_component result;

    result = null;

    if (comp_str == "$root")
      result = uvm_root::get();
    else if (comp_str == "-")
      result = null; // Redundant, just to stay in "visual consistence"
    else
      result = uvm_root::get().find(comp_str);

    return result;

  endfunction : cdn_demo_parse_ctx_comp



  /** Processes C string command passed from C code
   * \param cmd_name Command name
   * \param cmd_params Command parameters
   */
  function void cdn_demo_process_c_str_cmd(input string cmd_name, input string cmd_params[$]);

    `uvm_info("cdn_demo_process_c_str_cmd", $psprintf("Command \"%0s\"recognised, parameters:",
      cmd_name), UVM_LOW)
    foreach (cmd_params[i])
      `uvm_info("cdn_demo_process_c_str_cmd", $psprintf("  - param[%0d] = \"%0s\"",
          i, cmd_params[i]), UVM_LOW)

    case (cmd_name)

      "ECHO":
        cdn_demo_pass_str_to_c({ "@ECHO_RESP,", cmd_params[0], ";" });


      "DUMP_TOPO":
        uvm_top.print_topology();


      "CFG_DB_DUMP":
        uvm_config_db#()::dump();


      "GET_CFG_DB_INT", "GET_CFG_DB_STR",
      "GET_SET_CFG_DB_INT", "GET_SET_CFG_DB_STR":
        begin

          uvm_component
            ctx;
          int
            result_int;
          string
            result_str, path_str, name, new_value_str, resp_str;
          bit
            status, is_int, do_set;

          is_int    = (cmd_name == "GET_CFG_DB_INT") || (cmd_name == "GET_SET_CFG_DB_INT");
          do_set    = cmd_name.substr(0, 6) == "GET_SET";

          ctx       = cdn_demo_parse_ctx_comp(cmd_params[0]);
          path_str  = cmd_params[1];
          name      = cmd_params[2];
          new_value_str = (do_set && cmd_params.size() > 3) ? cmd_params[3] : "";

          if (is_int)
            status = uvm_config_db#(int)::get(ctx, path_str, name, result_int);
          else
            status = uvm_config_db#(string)::get(ctx, path_str, name, result_str);

          if (do_set)
          begin
            if (is_int)
              uvm_config_db#(int)::set(ctx, path_str, name, new_value_str.atoi());
            else
              uvm_config_db#(string)::set(ctx, path_str, name, new_value_str);
          end

          resp_str = $psprintf("@CFG_DB_INT_VAL,%0s,", cmd_params[2]);


          resp_str =
            {
              (is_int ? "@CFG_DB_INT_VAL" : "@CFG_DB_STR_VAL"),
              ",", name,
              ",", $psprintf("%0d", status),
              ",", (is_int ? $psprintf("%0d", result_int) : result_str),
              ";"
            };

          cdn_demo_pass_str_to_c(resp_str);

        end


      "SET_CFG_DB_INT", "SET_CFG_DB_STR":
        begin
          uvm_component
            ctx;
          string
            path_str, name, value_str, resp_str;
          bit
            is_int;

          is_int = cmd_name == "SET_CFG_DB_INT";

          ctx       = cdn_demo_parse_ctx_comp(cmd_params[0]);
          path_str  = cmd_params[1];
          name      = cmd_params[2];
          value_str = (cmd_params.size() > 3) ? cmd_params[3] : 0;

          $display("[%0s] ctx=%0s path=%0s name=%0s value=\"%0s\"",
            cmd_name, (ctx == null ? "<null>" : ctx.get_full_name()), path_str, name, value_str);

          if (is_int)
            uvm_config_db#(int)::set(ctx, path_str, name, value_str.atoi());
          else
            uvm_config_db#(string)::set(ctx, path_str, name, value_str);

          resp_str =
            {
              (is_int ? "@CFG_DB_INT_SET" : "@CFG_DB_STR_SET"),
              ",", name,
              ",", value_str,
              ";"
            };

          cdn_demo_pass_str_to_c(resp_str);

        end


    endcase //case (cmd_name)

  endfunction : cdn_demo_process_c_str_cmd


   //------------------------------------------------------------------------
   // Protocol-Specific DPI-C
   //------------------------------------------------------------------------

   // Include the protocol-specific DPI-C top module
    `ifndef CDN_DEMO_RAM_INTEGRATION_TEST
   `include "cdn_protocol_demo_module_top_c_dpi.sv"
   `endif

   `endif


   `ifdef CDN_SD4HC_DEMO
   // ***********************************************************************
   // *************** TEMPORARY TEMPORARY TEMPORARY *************************
   // *************** TEMPORARY TEMPORARY TEMPORARY *************************
   // *************** TEMPORARY TEMPORARY TEMPORARY *************************
   // ***********************************************************************
   // NOTE. THE CODE BELOW IS TEMPORARY ONLY TO SAVE POINTLESS WORKAROUNDS AND
   // IS ONLY NEEDED UNTIL THE CDN_SD4HC_DEMO ALIGNS WITH THE BARE METAL
   // DRIVER.

   //------------------------------------------------------------------------
   // DPI-C SD Specific
   //------------------------------------------------------------------------

   // These functions implement SD specific DPI-C calls that are specific to SD
   // and that do not use the common demo DPI-C calls.

   export "DPI" task sv_wait;
   export "DPI-C" task sv_add_protect_area;
   export "DPI-C" task sv_remove_protect_area;
   export "DPI-C" task msg2sv;

   task sv_wait (input int wait_cnt);
      `uvm_info("cdn_demo_module_top", $psprintf("Waiting for %0d clock cycles.", wait_cnt), UVM_LOW)
      repeat (wait_cnt)
         @(posedge clk);
   endtask : sv_wait

   task sv_add_protect_area( longint base, int size);
      //$error("Not expecting to be in sv_add_protect_area");
      //$finish();
   endtask : sv_add_protect_area

   task sv_remove_protect_area( longint base);
      //$error("Not expecting to be in sv_remove_protect_area");
      //$finish();
   endtask : sv_remove_protect_area

   task msg2sv(string msg);
      automatic int sev = 0;
      automatic string str = msg.substr(0,3);
      if      (str == "ERRO") sev = 3;
      else if (str == "WARN") sev = 2;
      else if (str == "INFO") sev = 1;

      case (sev)
         2: msg_warn :
            csp_printf_warning(msg);
         3:   msg_err  :
            csp_printf_error(msg);
         default:
            csp_printf_info(msg);
    endcase
   endtask : msg2sv

   `endif

endinterface

