//----------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//----------------------------------------------------------------------------
// Description:
// This files defines the cdn_gem_demo UVC data scoreboard.
//----------------------------------------------------------------------------

/*
 * File: cdn_gem_demo_sb.sv
 * 
 * This files defines the cdn_gem_demo UVC data scoreboard.
 */

`ifndef CDN_GEM_DEMO_SB_SV
  `define CDN_GEM_DEMO_SB_SV

/*
 * Class: cdn_gem_demo_sb
 * 
 * This is the cdn_gem_demo UVC scoreboard class.
 * This scoreboard operates on a single queue, for multi-queue operations
 * multiple scoreboards have to be instanced and configured.
 */
class cdn_gem_demo_sb extends uvm_scoreboard;
 
  //------------------------------------------------------------------------
  // TLM PORTS.
  //------------------------------------------------------------------------

  // Ethernet Layers
  `uvm_analysis_imp_decl(_enet_transport)
  `uvm_analysis_imp_decl(_enet_network)

  // Main Imp Ports
  `uvm_analysis_imp_decl(_sys_bus_mem)
  `uvm_analysis_imp_decl(_interface)

  /*
   * Variable: sb_enet_transport
   * 
   * This analysis imp port is connected to the cdn_enet_vip UVC Rx env
   * TxUserQueueExitTransportPkt callback, which is employed to access the
   * transport layer of the packet.
   */
  uvm_analysis_imp_enet_transport#(denaliEnetTransaction, cdn_gem_demo_sb) sb_enet_transport;
  
  /*
   * Variable: sb_enet_network
   * 
   * This analysis imp port is connected to the cdn_enet_vip UVC Rx env
   * TxUserQueueExitNetworkPkt callback, which is employed to access the network 
   * layer of the packet.
   */
  uvm_analysis_imp_enet_network#(denaliEnetTransaction, cdn_gem_demo_sb) sb_enet_network;

  /*
   * Variable: sb_sys_bus_mem
   * 
   * This analysis imp port is used for connections to an cdn_axi_vip env.
   */
  uvm_analysis_imp_sys_bus_mem#(denaliCdn_axiTransaction, cdn_gem_demo_sb) sb_sys_bus_mem;

  /*
   * Variable: sb_interface
   * 
   * This analysis imp port is used for connections to an cdn_enet_vip env.
   */
  uvm_analysis_imp_interface#(denaliEnetTransaction, cdn_gem_demo_sb) sb_interface;

  //------------------------------------------------------------------------
  // CONTROL KNOBS.
  //------------------------------------------------------------------------

  /*
   * Variable: enable_checks
   * 
   * A control variable to enable (1) or disable (0) scoreboard checks.
   */
  int enable_checks = 1;

  /*
   * Variable: enable_fixed_sched_checks
   * 
   * A control variable to enable (1) or disable (0) scoreboard checks relative
   * to the fixed priority scheduler.
   */  
  int enable_fixed_sched_checks = 0;

  /*
   * Variable: enable_scr1_checks
   * 
   * A control variable to enable (1) or disable (0) scoreboard checks relative
   * to the screener (type 1) mechanism.
   */
  int enable_scr1_checks = 0;

  /*
   * Variable: is_path_tx
   * 
   * A control variable to operate the scoreboard in Tx (1) or Rx (0).
   */
  int is_path_tx = 1;

  /*
   * Variable: is_q_cfgrd
   * 
   * A control variable to store information about the queue configuration in 
   * the DUT.
   */
  int is_q_cfgrd[16] = '{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  //------------------------------------------------------------------------
  // CLASS MEMBERS.
  //------------------------------------------------------------------------

  /*
   * Variable: leading_queue
   * 
   * An array of queues in which leading side raw transaction data is stored.
   */
  bit [7:0] leading_queue[16][$];
  
  /*
   * Variable: enet_trans_num
   * 
   * Counts the total number of ENET transactions that are passed to the
   * scoreboard.
   */
  int enet_trans_num = 0;

  /*
   * Variable: enet_trans_num_filtered
   * 
   * Counts the number of ENET transactions that are filtered by the reference
   * model and compared with data from the system bus side (one per queue).
   */
  int enet_trans_num_filtered[16] = '{16{0}};
  
  /*
   * Variable: axi_trans_num
   * 
   * Counts the total number of AXI transactions that are passed to the
   * scoreboard.
   */
  int axi_trans_num = 0;
  
  /*
   * Variable: axi_trans_num_filtered
   * 
   * Counts the number of AXI transactions that are filtered by the reference
   * model and compared with data from the line side (one per queue).
   */
  int axi_trans_num_filtered[16] = '{16{0}};
  
  /*
   * Variable: b2b_comp_lead_num
   * 
   * Counts the number of bytes pushed in the leading queue during byte-to-byte
   * data comparison (one per queue).
   */  
  int b2b_comp_lead_num[16] = '{16{0}};
  
  /*
   * Variable: b2b_comp_trail_num
   * 
   * Counts the number of bytes trailed and compared during byte-to-byte data
   * comparison (one per queue).
   */
  int b2b_comp_trail_num[16] = '{16{0}};
  
  /*
   * Variable: b2b_comp_err_num
   * 
   * Counts the number of errors occurred during byte-to-byte data comparison 
   * (one per queue).
   */
  int b2b_comp_err_num[16] = '{16{0}};
  
  //------------------------------------------------------------------------
  // BASIC REF MODEL.
  //------------------------------------------------------------------------

  /*
   * Variable: qptr_dbuff_mem_base_addr
   * 
   * A variable to store the databuffer memory base addresses on a per queue
   * basis.
   * To be populated by the sequence.
   */  
  bit [31:0] qptr_dbuff_mem_base_addr[16] = '{16{31'h00000000}};
  
  /*
   * Variable: qptr_dbuff_mem_size
   * 
   * A variable to store the databuffer memory extension on a per queue basis.
   * To be populated by the sequence.
   */
  bit [31:0] qptr_dbuff_mem_size[16] = '{16{31'h00000000}};

  //------------------------------------------------------------------------
  // FIXED PRIORITY SCHEDULER REF MODEL.
  //------------------------------------------------------------------------

  /*
   * Variable: fixed_sched_pkt_num
   * 
   * Stores the number of packets queued in each priority queue that are
   * scheduled to be sent.
   */
  int fixed_sched_pkt_num[16] = '{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  //------------------------------------------------------------------------
  // SCREENERS (TYPE 1) REF MODEL.
  //------------------------------------------------------------------------

  /*
   * Variable: network_kind
   * 
   * This variable is used to store the IP network kind (v4 or v6) to enable
   * communication between the transport and network ENET VIP Rx env callbacks.
   */
  denaliEnetNetworkKind network_kind;

  /*
   * Variable: scr1_udp_enable
   * 
   * A variable to store screener type 1 programming information about the UDP
   * comparison enable.
   * To be populated by the sequence.
   * Note that in principle, up to 16 screeners can be associated with a queue.
   * The general case is covered here.
   */
  bit scr1_udp_enable[16] = '{16{1'b0}};

  /*
   * Variable: scr1_udp_match
   * 
   * A variable to store screener type 1 programming information about the UDP
   * match value.
   * To be populated by the sequence.
   * Note that in principle, up to 16 screeners can be associated with a queue.
   * The general case is covered here.
   */  
  bit [15:0] scr1_udp_match[16] = '{16{16'b0}};

  /*
   * Variable: scr1_dstc_enable
   * 
   * A variable to store screener type 1 programming information about the DS/TC
   * comparison enable.
   * To be populated by the sequence.
   * Note that in principle, up to 16 screeners can be associated with a queue.
   * The general case is covered here.
   */
  bit scr1_dstc_enable[16] = '{16{1'b0}};

  /*
   * Variable: scr1_dstc_match
   * 
   * A variable to store screener type 1 programming information about the DS/TC
   * match value.
   * To be populated by the sequence.
   * Note that in principle, up to 16 screeners can be associated with a queue.
   * The general case is covered here.
   */  
  bit [7:0] scr1_dstc_match[16] = '{16{8'b0}};

  /*
   * Variable: scr1_q_num
   * 
   * A variable to store screener type 1 programming information about the 
   * configured queue number.
   */  
  bit [3:0] scr1_q_num[16] = '{16{4'b0}};

  /*
   * Variable: has_udp_matched
   * 
   * This is 1 if a UDP Destination Port match against screener type 1 has
   * occurred.
   */
  bit has_udp_matched[16] = '{16{1'b0}};

  /*
   * Variable: has_dstc_matched
   * 
   * This is 1 if an IPv4 Differentiated Service or IPv6 Traffic Class match
   * against screener type 1 has occurred.
   */
  bit has_dstc_matched[16] = '{16{1'b0}};

  //------------------------------------------------------------------------
  // UVM AUTOMATION MACROS.
  //------------------------------------------------------------------------

  `uvm_component_utils_begin(cdn_gem_demo_sb)
    `uvm_field_int(enable_checks, UVM_DEFAULT)
    `uvm_field_int(enable_fixed_sched_checks, UVM_DEFAULT)
    `uvm_field_int(enable_scr1_checks, UVM_DEFAULT)
    `uvm_field_int(is_path_tx, UVM_DEFAULT)
    `uvm_field_sarray_int(is_q_cfgrd, UVM_DEFAULT)
  `uvm_component_utils_end

  //------------------------------------------------------------------------
  // CONSTRUCTOR.
  //------------------------------------------------------------------------

  /*
   * Constructor: new
   * 
   * The class constructor.
   * It also construct sb_leading and sb_trailing imports.
   * 
   * Parameters:
   * 
   *     name   - The name of the class to construct.
   *     parent - The parent class.
   */
  function new(string name="cdn_gem_demo_sb", uvm_component parent=null);
    super.new(name, parent);
    // Ethernet Layers
    sb_enet_transport = new("enet_transport", this);
    sb_enet_network   = new("enet_network", this);      
    // Main Imp Ports
    sb_sys_bus_mem  = new("sb_sys_bus_mem", this);
    sb_interface    = new("sb_interface", this);
  endfunction

  //------------------------------------------------------------------------
  // UVM PHASES.
  //------------------------------------------------------------------------

  /*
   * Method: check_phase
   * 
   * This UVM phase processes and checks the simulation results.
   * It is used to print the scoreboard report.
   *  
   * Parameters:
   * 
   *    phase - The UVM phase object.
   */
  virtual function void check_phase (uvm_phase phase);
    string msg, direction;
    super.check_phase(phase);
    if(enable_checks) begin
      // Build the report message
      msg =
        {
          $psprintf("/----------------------------------------------------\n"),
          $psprintf("| CDN_GEM_DEMO UVC SCOREBOARD - %s\n", get_name())
        };
      for(int q=0; q<16; q++) begin
        if(is_q_cfgrd[q]) begin
          msg =
            { msg,
              $psprintf("|----------------------------------------------------\n"),
              $psprintf("| QUEUE %0d\n", q),
              $psprintf("|----------------------------------------------------\n"),
              $psprintf("| PROBED MEMORY AREA\n"),
              $psprintf("| - Lowest address           : 0x%h\n", qptr_dbuff_mem_base_addr[q]),
              $psprintf("| - Highest address          : 0x%h\n", qptr_dbuff_mem_base_addr[q] + qptr_dbuff_mem_size[q]),
              $psprintf("|\n"),
              $psprintf("| TRANS SUMMARY\n"),
              $psprintf("| - ENET trans\n"),
              $psprintf("|   - Total                  : %0d\n", enet_trans_num),
              $psprintf("|   - Dropped                : %0d\n", enet_trans_num - enet_trans_num_filtered[q]),
              $psprintf("|   - To b2b comparison      : %0d\n", enet_trans_num_filtered[q]),
              $psprintf("| - AXI trans\n"),
              $psprintf("|   - Total                  : %0d\n", axi_trans_num),
              $psprintf("|   - Dropped                : %0d\n", axi_trans_num - axi_trans_num_filtered[q]),
              $psprintf("|   - To b2b comparison      : %0d\n", axi_trans_num_filtered[q]),
              $psprintf("|\n"),
              $psprintf("| BYTES SUMMARY\n"),
              $psprintf("| - Pushed                   : %0d\n", b2b_comp_lead_num[q]),
              $psprintf("| - Trailed and compared     : %0d\n", b2b_comp_trail_num[q]),
              $psprintf("| - Errors during comparison : %0d\n", b2b_comp_err_num[q]),          
              $psprintf("| - Final queue size         : %0d\n", leading_queue[q].size())
            };
        end
      end
      msg = {msg, $psprintf("\\----------------------------------------------------")};
      `uvm_info(get_type_name(), $psprintf("[check_phase]:\n%s", msg), UVM_LOW)
      
      // Look for errors
      for(int q=0; q<16; q++) begin
        if(is_q_cfgrd[q]) begin
          if(b2b_comp_err_num[q] > 0)
            `uvm_error(get_type_name(), $psprintf("[check_phase] Found errors in data comparison for queue %0d!", q))
          if(leading_queue[q].size != 0)
            `uvm_error(get_type_name(), $psprintf("[check_phase] leading_queue[%0d] not empty!", q))
        end
      end
    end
  endfunction : check_phase

  //------------------------------------------------------------------------
  // WRITE METHODS.
  //------------------------------------------------------------------------

  /*
   * Method: write_enet_transport
   * 
   * Access the cdn_enet_vip Rx env TxUserQueueExitTransportPkt callback in
   * order to match screener type 1 against the UDP destination port.
   * 
   * Parameters:
   * 
   *    trans - The Ethernet transaction.
   */
  virtual function void write_enet_transport(denaliEnetTransaction trans);
    string msg;
    if (enable_checks) begin
      if (enable_scr1_checks) begin
        has_udp_matched = '{16{1'b0}};
        msg = 
        {
          $psprintf("/----------------------------------------------------\n"),
          $psprintf("| Screeners Type 1 - UDP Summary - Packet %0d\n", enet_trans_num),
          $psprintf("|----------------------------------------------------\n")
        };
        network_kind = trans.NetworkKind;
        // Determine if a match occurs on UDP destination port
        for (int i=0 ; i<16 ; i++) begin
          if (scr1_udp_enable[i] && scr1_udp_match[i] == trans.UDPDestinationPort) begin
            has_udp_matched[i] = 1'b1;
          end
          msg =
            {
              msg,
              $psprintf("| Reg %2d | en = %0d | match = 0x%h | matched = %0d\n", 
                i, scr1_udp_enable[i], scr1_udp_match[i], has_udp_matched[i])
            };
        end
        msg = {msg, $psprintf("\\----------------------------------------------------")};
      end
      `uvm_info(get_type_name(), $psprintf("[write_enet_transport]:\n%s", msg), UVM_DEBUG)
    end
  endfunction : write_enet_transport

  /*
   * Method: write_enet_network
   * 
   * Access the cdn_enet_vip Rx env TxUserQueueExitNetworkPkt callback in order
   * to match screener type 1 against the IPv4 Differentiated Service (Type Of 
   * Service) or IPv6 Traffic Class.
   * 
   * Parameters:
   * 
   *    trans - The Ethernet transaction.
   */
  virtual function void write_enet_network(denaliEnetTransaction trans);
    string msg;
    int trans_field_to_match;
    if (enable_checks) begin
      if (enable_scr1_checks) begin
        has_dstc_matched = '{16{1'b0}};
        msg = 
        {
          $psprintf("/----------------------------------------------------\n"),
          $psprintf("| Screeners Type 1 - TCP Summary - Packet %0d\n", enet_trans_num),
          $psprintf("|----------------------------------------------------\n")
        };
        // Select network kind and associate proper field
        if (network_kind == DENALI_ENET_NETWORKKIND_IPV6) begin
          trans_field_to_match = trans.IPv6TrafficClass;
        end else begin
          trans_field_to_match = trans.IPv4TypeOfService;
        end
        // Determine if a match occurs on TCP DS/TC
        for (int i=0 ; i<16 ; i++) begin
          if (scr1_dstc_enable[i] && scr1_dstc_match[i] == trans_field_to_match) begin
            has_dstc_matched[i] = 1'b1;
          end
          msg =
            {
              msg,
              $psprintf("| Reg %2d | en = %0d | match = 0x%h | matched = %0d\n",
                i, scr1_dstc_enable[i], scr1_dstc_match[i], has_dstc_matched[i])
            };
        end
        msg = {msg, $psprintf("\\----------------------------------------------------")};
      end
      `uvm_info(get_type_name(), $psprintf("[write_enet_network]:\n%s", msg), UVM_DEBUG)
    end
  endfunction : write_enet_network

  /*
   * Method: write_sys_bus_mem
   * 
   * This method gets an AXI transaction from the cdn_axi_vip env and determine
   * whether this is inside the memory area, i.e. carries data useful for 
   * comparison with the line side.
   * If this is the case, the transaction is passed to the byte-to-byte
   * comparator (otherwise is dropped).
   * 
   * Parameters:
   * 
   *    trans - The AXI transaction.
   */
  virtual function void write_sys_bus_mem(denaliCdn_axiTransaction trans);
    if(enable_checks) begin
      // Increment the transaction count
      axi_trans_num++;
      // If the trans is in the databuffer memory, filter for comparison
      for (int q=0; q<16; q++) begin
        if(is_q_cfgrd[q]) begin
          if (is_trans_inside_sys_bus_mem_area(trans, q)) begin
            axi_trans_num_filtered[q]++;
            proc_sys_bus_mem_filtered(trans, q);
          end
        end
      end
    end
  endfunction : write_sys_bus_mem
  
  /*
   * Method: write_interface
   * 
   * This method gets an ENET transaction from the cdn_enet_vip env and
   * determines whether this has to be passed to the byte-to-byte comparator via
   * a reference model.
   * 
   * Parameters:
   * 
   *    trans - The Ethernet transaction.
   */
  virtual function void write_interface(denaliEnetTransaction trans);
    if(enable_checks) begin
      // Recover the queue number
      int q_num = 0;
      for (int q=0; q<16; q++) begin
        if (is_q_cfgrd[q]) begin
          q_num++;
        end
      end
      // Increment the transaction count
      enet_trans_num++;
      // Tx Fixed Priority Scheduler
      if (enable_fixed_sched_checks) begin
        int pkt_threshold = 0;
        int pushed = 0;
        for (int q=q_num-1; q>=0 && !pushed; q--) begin
          pkt_threshold = pkt_threshold + fixed_sched_pkt_num[q];
          `uvm_info(get_type_name(), 
            $psprintf("[write_interface] enable_fixed_sched_checks | q=%2d | pkt_threshold=%0d", q, pkt_threshold),
            UVM_DEBUG)
          if (enet_trans_num <= pkt_threshold) begin
            enet_trans_num_filtered[q]++;
            proc_interface_filtered(trans, q);
            pushed = 1;
          end
        end
      // Rx Screeners Type 1
      end else if (enable_scr1_checks) begin
        int is_scr1_matched = 0;
        for (int i=0; i<16; i++) begin
          if (has_udp_matched[i] || has_dstc_matched[i]) begin
            is_scr1_matched = 1;
            if (is_q_cfgrd[scr1_q_num[i]]) begin
              enet_trans_num_filtered[scr1_q_num[i]]++;
              proc_interface_filtered(trans, scr1_q_num[i]);
            end else begin
              `uvm_warning(get_type_name(), "[write_interface] enable_scr1_checks | Matched on a queue which is not configured!")
            end
          end
        end
        if (!is_scr1_matched) begin
          enet_trans_num_filtered[0]++;
          proc_interface_filtered(trans, 0);
        end
      // Basic Operation
      end else begin
        enet_trans_num_filtered[0]++;
        proc_interface_filtered(trans, 0);
      end
    end
  endfunction : write_interface

  //------------------------------------------------------------------------
  // B2B COMPARISON.
  //------------------------------------------------------------------------

  /*
   * Method: proc_interface_filtered
   * 
   * This is a convenience method that process a filtered ENET transaction, 
   * passing it to the byte-to-byte comparator.
   * 
   * Parameters:
   * 
   *     trans - The Ethernet transaction.
   *     q     - The queue number.
   */
  virtual function void proc_sys_bus_mem_filtered(denaliCdn_axiTransaction trans, int q);
    if(is_path_tx) begin
      if (trans.Direction == DENALI_CDN_AXI_DIRECTION_READ) begin
        `uvm_info(get_type_name(),
          $psprintf("[proc_sys_bus_mem_filtered] Push trans %0d (%0d filtered) on queue %0d:", axi_trans_num, axi_trans_num_filtered[q], q),
          UVM_DEBUG)
        for (int i = 0 ; i < trans.Data.size() ; i++) begin
          b2b_comp_lead_num[q]++;
          push_leading(trans.Data[i], q);
        end
      end
    end else begin
      if (trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE) begin
        `uvm_info(get_type_name(),
          $psprintf("[proc_sys_bus_mem_filtered] Compare trans %0d (%0d filtered) on queue %0d:", axi_trans_num, axi_trans_num_filtered[q], q),
          UVM_DEBUG)
        for (int i=0; i<trans.Data.size(); i++) begin
          b2b_comp_trail_num[q]++;
          trail_and_compare(trans.Data[i], q);
        end
      end
    end
  endfunction : proc_sys_bus_mem_filtered

  /*
   * Method: proc_interface_filtered
   * 
   * This is a convenience method that process a filtered ENET transaction, 
   * passing it to the byte-to-byte comparator.
   * 
   * Parameters:
   * 
   *     trans - The Ethernet transaction.
   *     q     - The queue number.
   */
  virtual function void proc_interface_filtered(denaliEnetTransaction trans, int q);
    if(is_path_tx) begin
      if (trans.DirectionKind == DENALI_ENET_DIRECTION_COLLECT) begin
        `uvm_info(get_type_name(),
          $psprintf("[proc_interface_filtered] Compare trans %0d (%0d filtered) on queue %0d:", enet_trans_num, enet_trans_num_filtered[q], q),
          UVM_DEBUG)
        // Skip the first 8 bytes (Preamble + SFD) and the last 4 bytes (CRC)
        for (int i=8; i<trans.EthernetPacketRawData.size()-4; i++) begin
          b2b_comp_trail_num[q]++;
          trail_and_compare(trans.EthernetPacketRawData[i], q);
        end
      end
    end else begin
      if (trans.DirectionKind == DENALI_ENET_DIRECTION_INJECT) begin
        int pad_length;
        `uvm_info(get_type_name(),
          $psprintf("[proc_interface_filtered] Push trans %0d (%0d filtered) on queue %0d:", enet_trans_num, enet_trans_num_filtered[q], q),
          UVM_DEBUG)
        // Skip the first 8 bytes (Preamble + SFD)
        for (int i=8; i<trans.EthernetPacketRawData.size() ; i++) begin
          b2b_comp_lead_num[q]++;
          push_leading(trans.EthernetPacketRawData[i], q);
        end
        // Add 0 padding
        pad_length = calc_pad_length(trans.EthernetPacketRawData.size()-8);
        `uvm_info(get_type_name(),
          $psprintf("[proc_interface_filtered] raw_length = %0d | pad_length = %0d", trans.EthernetPacketRawData.size(), pad_length), 
          UVM_DEBUG)
        for (int i=0; i<pad_length; i++) begin
          b2b_comp_lead_num[q]++;
          push_leading(8'h00, q);
        end
      end      
    end
  endfunction : proc_interface_filtered

  /*
   * Method: push_leading
   * 
   * Push raw data from the leading side to the front of the leading queue.
   * 
   * Parameters:
   * 
   *     leading_data - The byte to be pushed.
   *     q            - The queue index.
   */
  virtual function void push_leading(bit [7:0] leading_data, int q);
    leading_queue[q].push_front(leading_data);
    `uvm_info(get_type_name(),
      $psprintf("Push front in leading_queue[%0d] | Size = %0d | Data = %0h", q, leading_queue[q].size(), leading_data),
      UVM_DEBUG)
  endfunction : push_leading

  /*
   * Method: trail_and_compare
   * 
   * Compare data from the trailing side with data stored in the leading queue,
   * exploiting a simple byte to byte comparison.
   * If the comparison fails, this method displays a UVM error.
   * 
   * Parameters:
   * 
   *     trailing_data - The data to be trailed and compared.
   *     q             - The queue index.
   */
  virtual function void trail_and_compare(bit [7:0] trailing_data, int q);
    bit [7:0] leading_data = leading_queue[q].pop_back();
    `uvm_info(get_type_name(),
      $psprintf("Pop back from leading_queue[%0d] | Size = %0d | Data = %0h", q, leading_queue[q].size(), leading_data),
      UVM_DEBUG)
    if (leading_data != trailing_data) begin
      b2b_comp_err_num[q]++;
      `uvm_info(get_type_name(),
        $psprintf("ERROR in b2b comp | leading_data = 0x%0h | trailing_data = 0x%0h", leading_data, trailing_data),
        UVM_DEBUG)
    end
  endfunction : trail_and_compare

  //------------------------------------------------------------------------
  // UTILITIES.
  //------------------------------------------------------------------------

  /*
   * Method: is_trans_inside_sys_bus_mem_area
   * 
   * Check if an AXI transaction is inside the configured memory area for a 
   * certain queue.
   * 
   * Parameters:
   * 
   *    trans - The AXI transaction.
   *    q     - The queue number.
   */
  virtual function int is_trans_inside_sys_bus_mem_area(denaliCdn_axiTransaction trans, int q);
    if(trans.LowestAddress >= qptr_dbuff_mem_base_addr[q] && trans.HighestAddress <= qptr_dbuff_mem_base_addr[q] + qptr_dbuff_mem_size[q])
      is_trans_inside_sys_bus_mem_area = 1;
    else
      is_trans_inside_sys_bus_mem_area = 0;
  endfunction : is_trans_inside_sys_bus_mem_area

  /*
   * Method: calc_pad_length
   * 
   * Calculate the number of zero that would be padded at the end of an AXI
   * write transaction if the number of byte in the injected Ethernet
   * transaction is not integer multiple of that in the AXI burst. 
   * This is done in order to enable scoreboard comparison without taking out 
   * the zeroes padded at the end of the AXI write transaction at host side.
   * 
   * Parameters:
   * 
   *    data_length - The data length of the Ethernet transaction.
   */
  virtual function int calc_pad_length(int data_length);
    int axi_burst_length;
    int exceeding_bytes;
    // Set the correct number of bytes in a burst depending on AXI bus width:
    // - Datapath  32-bit:  4 bytes
    // - Datapath  64-bit:  8 bytes
    // - Datapath 128-bit: 16 bytes
    if (`gem_dma_bus_width == 32) begin
      `uvm_info(get_type_name(), "[calc_pad_length] Detected AXI 32 bit", UVM_DEBUG)
      axi_burst_length = 4; 
    end else if (`gem_dma_bus_width == 64) begin
      `uvm_info(get_type_name(), "[calc_pad_length] Detected AXI 64 bit", UVM_DEBUG)
      axi_burst_length = 8;
    end else begin
      `uvm_info(get_type_name(), "[calc_pad_length] Detected AXI 128 bit", UVM_DEBUG)
      axi_burst_length = 16;
    end
    // Calculating with how many zeros to pad
    exceeding_bytes = data_length - (data_length/axi_burst_length) * axi_burst_length;
    if (exceeding_bytes == 0) begin
      calc_pad_length = 0;
    end else begin
      calc_pad_length = axi_burst_length - exceeding_bytes;
    end
    `uvm_info(get_type_name(), 
      $psprintf("[calc_pad_length] axi_burst_length = %0d | data_length = %0d | pad_length = %0d", 
        axi_burst_length, 
        data_length, 
        calc_pad_length),
      UVM_DEBUG)
  endfunction : calc_pad_length

endclass : cdn_gem_demo_sb

`endif // CDN_GEM_DEMO_SB_SV

//----------------------------------------------------------------------------
// End of file
//----------------------------------------------------------------------------
