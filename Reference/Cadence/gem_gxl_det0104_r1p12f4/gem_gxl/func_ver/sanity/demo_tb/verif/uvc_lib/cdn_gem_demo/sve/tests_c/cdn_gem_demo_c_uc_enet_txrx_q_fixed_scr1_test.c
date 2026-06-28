//------------------------------------------------------------------------------
// File      : cdn_gem_demo_c_uc_enet_txrx_q_fixed_scr1_test.c
// Author    : bemanuel@cadence.com
// Date      : 11th May, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------
/*!
// @page cdn_gem_demo_c_uc_enet_txrx_q_fixed_scr1_test
// 
// Description
// ===========
//
// One packet per configured queue is transmitted and received using an external
// loopback connection in the testbench. Each received packet is routed to a
// particular priority queue using the screener type 1 mechanism.
//
// 0. Basic DUT initialization:
//    * Decode the design configuration.
//    * Write the `network_control`, `dma_config` and `network_config` regs to 
//      set basic properties (speed mode, buffer addressable space, etc).
// 1. System memory allocation (for each queue):
//    * Descriptor memory (Tx and Rx).
//    * Databuffer memory (Tx and Rx).
// 2. Setting the system memory (for each queue):
//    * Setting the Tx descriptor memory:
//      - The first descriptor is pointed to the Tx databuffer location.
//      - The second descriptor is marked with used and wrap bit set, i.e. last 
//        descriptor in the table.
//    * Setting the Tx databuffer memory:
//      - One IPoE IPv6/UDP databuffer is written. The UDP destination port is
//        set to match the queue number.
//    * Setting the Rx descriptor memory:
//      - The first descriptor is pointed to the Rx databuffer area.
//      - The second descriptor is marked with the wrap bits set, i.e. last
//        descriptor in the table.
//      - The default queue holds more than one valid descriptor to account for
//        design configuration corner cases.
// 3. Setting needed DUT registers:
//    * Store the Tx descriptor table base addresses in the Tx queue pointer
//      registers.
//    * Store the Rx descriptor table base addresses in the Rx queue pointer
//      registers.
//    * Program screener type 1 registers to screen an UDP destination port 
//      equal to the queue number. Note that register 'i' will screen on queue
//      'i'. Queue 0 is used as default, i.e. all the packets with non-matching 
//      UDP destination port will be routed to queue 0.
// 4. Tx-Rx transaction:
//    * Write the `network_control` reg for the Tx-Rx transaction to start.
//    * Wait until the packets have been transmitted and received.
//    * Compare the Tx-Rx databuffer memories to check for the transaction
//      correctness.
// 5. Test ends:
//    * For each queue, free memory areas allocated at the beginning.
*/
//------------------------------------------------------------------------------

/*! \file cdn_gem_demo_c_uc_enet_txrx_q_fixed_scr1_test.c
 *  \brief This file defines a Tx-Rx test.
 *         One packet per configured queue is transmitted and received using an
 *         external loopback connection in the testbench. Each recevived packet 
 *         is routed to a particular priority queue using the screener type 1 
 *         mechanism.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// If running over UVM-SV use cdn_demo.h and cdn_gem_demo.h libraries.
// If running over CSP use csp.h and cps.h libraries.
#ifdef CDN_DEMO_TB
  #include "cdn_demo.h"
  #include "cdn_gem_demo.h"
#else
  #include "csp.h"
  #include "cps.h"
#endif

#include "cdn_gem_demo_test_supp.h"
#include "map_system_memory.h"
#include "emac_regs.h"

/*! \var emac_regs *regs
 *  \brief A pointer to the register map.
 */
struct emac_regs *regs = (struct emac_regs*)EMAC0_REGS_BASE;

/*! \fn int main(int argc, char ** _argv)
 *  \brief Each C test is a main function.
 *         Multiple main functions are compatible since a test is compiled only 
 *         when it is called and only one test can be called at a time.
 *         Returns 0.
 *  \param argc The argument count.
 *  \param _argv The argument value. 
 */
int main(int argc, char ** _argv) {

  /* ----- Variables Declaration ----- */

  // General setup
  uint32_t cfg_decode[DESIGNCFG_REG_NUM];
  int is_q_cfgrd[MAX_Q_NUM];
  int is_scr1_cfgrd[MAX_SCR1_NUM];
  int scr1_num;
  int q_num;

  // Descriptor table variables
  unsigned char *mem_descr_tx[MAX_Q_NUM];
  unsigned char *mem_descr_rx[MAX_Q_NUM];
  uint32_t size_dtable = 0xffff;
  uint32_t word0, word1;

  // Databuffer variables
  unsigned char *mem_dbuff_tx[MAX_Q_NUM];
  unsigned char *mem_dbuff_rx[MAX_Q_NUM];
  uint32_t size_dbuff = 0xffff;
  enet_header_t enet_fields;
  ip_header_t ip_fields;
  udp_header_t udp_fields;
  uint8_t udp_payload[138];

  // Misc variables
  int i, j;

  /* ----- Test Setup ----- */

  csp_printf_format_info("TEST STEP 0  | Setting Up the Test");
  test_setup(regs, cfg_decode, is_q_cfgrd);

  // Get the queue number
  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i]) {
      q_num = i+1;
    }
  }
  csp_printf_format_debug("Queue number = 0x%x", q_num);

  // Get the screener type 1 number
  scr1_num = (cfg_decode[7] & 0xff000000) >> 24;
  csp_printf_format_debug("Screener number = 0x%x", scr1_num);
  for (i=0; i<MAX_SCR1_NUM; i++) {
    if (i<scr1_num)
      is_scr1_cfgrd[i] = 1;
    else
      is_scr1_cfgrd[i] = 0;
  }

  /* ----- System Memory Allocation ----- */

  // Descriptor Table Allocation
  csp_printf_format_info("TEST STEP 1  | Allocating Descriptor Table in System Memory");

  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i] == 1) {
      mem_descr_tx[i] = (unsigned char*)alloc_mem_area(size_dtable);
      mem_descr_rx[i] = (unsigned char*)alloc_mem_area(size_dtable);
      csp_printf_format_debug("Queue %2d | Descriptor Table base address | Tx: 0x%x | Rx: 0x%x",
        i, mem_descr_tx[i], mem_descr_rx[i]);
    }
  }

  // Databuffer Allocation
  csp_printf_format_info("TEST STEP 2  | Allocating Databuffer in System Memory");

  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i] == 1) {
      mem_dbuff_tx[i] = (unsigned char*)alloc_mem_area(size_dbuff);
      mem_dbuff_rx[i] = (unsigned char*)alloc_mem_area(size_dbuff);
      csp_printf_format_debug("Queue %2d | Databuffer Mem base address | Tx: 0x%x | Rx: 0x%x",
        i, mem_dbuff_tx[i], mem_dbuff_rx[i]);
    }
  }

  /* ----- Setting the Descriptors and Databuffers ----- */

  csp_printf_format_info("TEST STEP 3  | Setting Tx Descriptor Table");

  // For each queue
  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i] == 1) {
      // 1st descriptor
      word0 = (uintptr_t)mem_dbuff_tx[i];
      word1 = 0x00008040;
      write_descriptor(mem_descr_tx[i], 0x000, word1, word0);

      // 2nd descriptor (last)
      word0 = byte2word((uintptr_t)mem_descr_tx[i] + 0x0b, 
                        (uintptr_t)mem_descr_tx[i] + 0x0a, 
                        (uintptr_t)mem_descr_tx[i] + 0x09, 
                        (uintptr_t)mem_descr_tx[i] + 0x08);
      word1 = byte2word(0xc0                             , 
                        (uintptr_t)mem_descr_tx[i] + 0x0e, 
                        (uintptr_t)mem_descr_tx[i] + 0x0d, 
                        (uintptr_t)mem_descr_tx[i] + 0x0c);
      write_descriptor(mem_descr_tx[i], 0x008, word1, word0);
    }
  }

  csp_printf_format_info("TEST STEP 4  | Setting Tx Databuffer Memory");

  // For each queue
  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i] == 1) {
      // Initialize an IPv6/UDP IPoE databuffer (mode = 1)
      ip_fields.mode                = 1;
      for (j=0; j<3; j++) {
        enet_fields.dst_addr[j]     = 0x1111;                        // don't care
        enet_fields.src_addr[j]     = 0x2222;                        // don't care
      }
      enet_fields.type_length       = 0x86dd;                        // must be 0x86dd for IPv6
      ip_fields.ipv6_version        = 0x6;                           // must be 0x6 for IPv6
      ip_fields.ipv6_traffic_class  = 0x33;                          // don't care
      ip_fields.ipv6_flow_label     = 0x44444;                       // don't care
      ip_fields.ipv6_payload_length = 0x000a;                        // consitent with buffer length
      ip_fields.ipv6_next_header    = 0x11;                          // must be 0x11 (UDP)
      ip_fields.ipv6_hop_limit      = 0x55;                          // don't care
      for (j=0; j<4; j++) {
        ip_fields.ipv6_src_addr[j]  = 0x66666666;                    // don't care
        ip_fields.ipv6_dst_addr[j]  = 0x77777777;                    // don't care
      }
      udp_fields.src_port           = 0x8888;                        // don't care
      udp_fields.dst_port           = i;                             // initialize as the q number
      udp_fields.length             = ip_fields.ipv6_payload_length; // consistent with buffer length
      udp_fields.checksum           = 0xddb8 - i;                    // the value for this IPv6 pseudo header
      for (j=0; j<udp_fields.length-8; j++) {                        
        udp_payload[j]              = 0xaa;                          // don't care
      }
      write_databuffer(mem_dbuff_tx[i], 0x000, enet_fields, ip_fields, udp_fields, udp_payload);
    }
  }

  csp_printf_format_info("TEST STEP 5  | Setting Rx Descriptor Memory");

  // For each queue
  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i] == 1) {
      if(i == 0) {
        // 1st descriptor
        word0 = (uintptr_t)mem_dbuff_rx[0];
        word1 = byte2word((uintptr_t)mem_descr_rx[0] + 0x07,
                          (uintptr_t)mem_descr_rx[0] + 0x06,
                          (uintptr_t)mem_descr_rx[0] + 0x05,
                          (uintptr_t)mem_descr_rx[0] + 0x04);
        write_descriptor(mem_descr_rx[0], 0x000, word1, word0);

        // For queue 0 (default), write q_num-scr1_num+1 valid descriptors, to
        // cover for the case in which more queues than screeners are
        // configured.
        for (j=1; j<(q_num-scr1_num+1); j++) {
          // j-th descriptor
          word0 = (uintptr_t)mem_dbuff_rx[0] + (j*0x100);
          word1 = byte2word((uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x07,
                            (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x06,
                            (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x05,
                            (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x04);
          write_descriptor(mem_descr_rx[0], j*0x008, word1, word0);
        }

        // Last descriptor
        word0 = byte2word((uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x03,
                          (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x02,
                          (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x01,
                          0x02                                         );
        word1 = byte2word((uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x07,
                          (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x06,
                          (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x05,
                          (uintptr_t)mem_descr_rx[0] + (j*0x008) + 0x04);
        write_descriptor(mem_descr_rx[0], j*0x008, word1, word0);
      } else {
        // 1st descriptor
        word0 = (uintptr_t)mem_dbuff_rx[i];
        word1 = byte2word((uintptr_t)mem_descr_rx[i] + 0x07,
                          (uintptr_t)mem_descr_rx[i] + 0x06,
                          (uintptr_t)mem_descr_rx[i] + 0x05,
                          (uintptr_t)mem_descr_rx[i] + 0x04);
        write_descriptor(mem_descr_rx[i], 0x000, word1, word0);

        // 2nd descriptor (last)
        word0 = byte2word((uintptr_t)mem_descr_rx[i] + 0x0b,
                          (uintptr_t)mem_descr_rx[i] + 0x0a,
                          (uintptr_t)mem_descr_rx[i] + 0x09,
                          0x02                             );
        word1 = byte2word((uintptr_t)mem_descr_rx[i] + 0x0f,
                          (uintptr_t)mem_descr_rx[i] + 0x0e,
                          (uintptr_t)mem_descr_rx[i] + 0x0d,
                          (uintptr_t)mem_descr_rx[i] + 0x0c);
        write_descriptor(mem_descr_rx[i], 0x008, word1, word0);
      }
    }
  }

  /* ----- APB Programming ----- */

  csp_printf_format_info("TEST STEP 6  | Setting the Needed DUT Registers");

  // Program the Tx queue pointers
  write_q_ptr(&regs->transmit_q_ptr,   is_q_cfgrd[0],  1, (uintptr_t)mem_descr_tx[0]);
  write_q_ptr(&regs->transmit_q1_ptr,  is_q_cfgrd[1],  1, (uintptr_t)mem_descr_tx[1]);
  write_q_ptr(&regs->transmit_q2_ptr,  is_q_cfgrd[2],  1, (uintptr_t)mem_descr_tx[2]);
  write_q_ptr(&regs->transmit_q3_ptr,  is_q_cfgrd[3],  1, (uintptr_t)mem_descr_tx[3]);
  write_q_ptr(&regs->transmit_q4_ptr,  is_q_cfgrd[4],  1, (uintptr_t)mem_descr_tx[4]);
  write_q_ptr(&regs->transmit_q5_ptr,  is_q_cfgrd[5],  1, (uintptr_t)mem_descr_tx[5]);
  write_q_ptr(&regs->transmit_q6_ptr,  is_q_cfgrd[6],  1, (uintptr_t)mem_descr_tx[6]);
  write_q_ptr(&regs->transmit_q7_ptr,  is_q_cfgrd[7],  1, (uintptr_t)mem_descr_tx[7]);
  write_q_ptr(&regs->transmit_q8_ptr,  is_q_cfgrd[8],  1, (uintptr_t)mem_descr_tx[8]);
  write_q_ptr(&regs->transmit_q9_ptr,  is_q_cfgrd[9],  1, (uintptr_t)mem_descr_tx[9]);
  write_q_ptr(&regs->transmit_q10_ptr, is_q_cfgrd[10], 1, (uintptr_t)mem_descr_tx[10]);
  write_q_ptr(&regs->transmit_q11_ptr, is_q_cfgrd[11], 1, (uintptr_t)mem_descr_tx[11]);
  write_q_ptr(&regs->transmit_q12_ptr, is_q_cfgrd[12], 1, (uintptr_t)mem_descr_tx[12]);
  write_q_ptr(&regs->transmit_q13_ptr, is_q_cfgrd[13], 1, (uintptr_t)mem_descr_tx[13]);
  write_q_ptr(&regs->transmit_q14_ptr, is_q_cfgrd[14], 1, (uintptr_t)mem_descr_tx[14]);
  write_q_ptr(&regs->transmit_q15_ptr, is_q_cfgrd[15], 1, (uintptr_t)mem_descr_tx[15]);

  // Program the Rx queue pointers
  write_q_ptr(&regs->receive_q_ptr,   is_q_cfgrd[0],  1, (uintptr_t)mem_descr_rx[0]);
  write_q_ptr(&regs->receive_q1_ptr,  is_q_cfgrd[1],  1, (uintptr_t)mem_descr_rx[1]);
  write_q_ptr(&regs->receive_q2_ptr,  is_q_cfgrd[2],  1, (uintptr_t)mem_descr_rx[2]);
  write_q_ptr(&regs->receive_q3_ptr,  is_q_cfgrd[3],  1, (uintptr_t)mem_descr_rx[3]);
  write_q_ptr(&regs->receive_q4_ptr,  is_q_cfgrd[4],  1, (uintptr_t)mem_descr_rx[4]);
  write_q_ptr(&regs->receive_q5_ptr,  is_q_cfgrd[5],  1, (uintptr_t)mem_descr_rx[5]);
  write_q_ptr(&regs->receive_q6_ptr,  is_q_cfgrd[6],  1, (uintptr_t)mem_descr_rx[6]);
  write_q_ptr(&regs->receive_q7_ptr,  is_q_cfgrd[7],  1, (uintptr_t)mem_descr_rx[7]);
  write_q_ptr(&regs->receive_q8_ptr,  is_q_cfgrd[8],  1, (uintptr_t)mem_descr_rx[8]);
  write_q_ptr(&regs->receive_q9_ptr,  is_q_cfgrd[9],  1, (uintptr_t)mem_descr_rx[9]);
  write_q_ptr(&regs->receive_q10_ptr, is_q_cfgrd[10], 1, (uintptr_t)mem_descr_rx[10]);
  write_q_ptr(&regs->receive_q11_ptr, is_q_cfgrd[11], 1, (uintptr_t)mem_descr_rx[11]);
  write_q_ptr(&regs->receive_q12_ptr, is_q_cfgrd[12], 1, (uintptr_t)mem_descr_rx[12]);
  write_q_ptr(&regs->receive_q13_ptr, is_q_cfgrd[13], 1, (uintptr_t)mem_descr_rx[13]);
  write_q_ptr(&regs->receive_q14_ptr, is_q_cfgrd[14], 1, (uintptr_t)mem_descr_rx[14]);
  write_q_ptr(&regs->receive_q15_ptr, is_q_cfgrd[15], 1, (uintptr_t)mem_descr_rx[15]);

  // Write Screener Type 1 registers.
  // To ease understanding, it is assumed that screener register 'i' will screen
  // on queue 'i' (this is not the general case, since those registers are
  // configurable at will).
  // The default queue is used as a default case, i.e. all the packets with
  // non-matching UDP destination port will be routed to queue 0.
  write_scr1(&regs->screening_type_1_register_0,  is_scr1_cfgrd[0],  0);
  write_scr1(&regs->screening_type_1_register_1,  is_scr1_cfgrd[1],  is_q_cfgrd[1],  0x20001001);
  write_scr1(&regs->screening_type_1_register_2,  is_scr1_cfgrd[2],  is_q_cfgrd[2],  0x20002002);
  write_scr1(&regs->screening_type_1_register_3,  is_scr1_cfgrd[3],  is_q_cfgrd[3],  0x20003003);
  write_scr1(&regs->screening_type_1_register_4,  is_scr1_cfgrd[4],  is_q_cfgrd[4],  0x20004004);
  write_scr1(&regs->screening_type_1_register_5,  is_scr1_cfgrd[5],  is_q_cfgrd[5],  0x20005005);
  write_scr1(&regs->screening_type_1_register_6,  is_scr1_cfgrd[6],  is_q_cfgrd[6],  0x20006006);
  write_scr1(&regs->screening_type_1_register_7,  is_scr1_cfgrd[7],  is_q_cfgrd[7],  0x20007007);
  write_scr1(&regs->screening_type_1_register_8,  is_scr1_cfgrd[8],  is_q_cfgrd[8],  0x20008008);
  write_scr1(&regs->screening_type_1_register_9,  is_scr1_cfgrd[9],  is_q_cfgrd[9],  0x20009009);
  write_scr1(&regs->screening_type_1_register_10, is_scr1_cfgrd[10], is_q_cfgrd[10], 0x2000a00a);
  write_scr1(&regs->screening_type_1_register_11, is_scr1_cfgrd[11], is_q_cfgrd[11], 0x2000b00b);
  write_scr1(&regs->screening_type_1_register_12, is_scr1_cfgrd[12], is_q_cfgrd[12], 0x2000c00c);
  write_scr1(&regs->screening_type_1_register_13, is_scr1_cfgrd[13], is_q_cfgrd[13], 0x2000d00d);
  write_scr1(&regs->screening_type_1_register_14, is_scr1_cfgrd[14], is_q_cfgrd[14], 0x2000e00e);
  write_scr1(&regs->screening_type_1_register_15, is_scr1_cfgrd[15], is_q_cfgrd[15], 0x2000f00f);

  /* ----- Tx-Rx Transaction and Checks ----- */

  csp_printf_format_info("TEST STEP 7  | Starting Tx-Rx Transaction");

  // Program the network_control to enable Tx and Rx
  csp_write32(&regs->network_control, 0x20c);

  csp_printf_format_info("TEST STEP 8  | Waiting for Tx-Rx Transaction to End");

  // Wait until a packet has been transmitted and a descriptor with used bit set
  // has been read
  waitfor(&regs->transmit_status, 0xffffffff, 0x00000021, 100);
  
  // Wait until the Rx packet buffer is empty
  waitfor(&regs->dpram_fill_dbg, 0xffff0000, 0x00000000, 100);
  //waitfor(&regs->receive_status, 0xffffffff, 0x00000002, 100);

  csp_printf_format_info("TEST STEP 9  | Comparing Tx and Rx Databuffer Memories");
  
  // For each queue
  j = 0;
  for (i=MAX_Q_NUM-1; i>=0; i--) {
    if (is_q_cfgrd[i]) {
      // Compare on queue 0 (default) also to cover the case in which more
      // queues than screeners are configured.
      if ((i == 0) || (i >= scr1_num)) {
        compare_databuffers(mem_dbuff_rx[0], 0x000+j*0x100, mem_dbuff_tx[i], 0x000, 0x32+14);
        j++;
      } else {
        compare_databuffers(mem_dbuff_rx[i], 0x000, mem_dbuff_tx[i], 0x000, 0x32+14);      
      }
    }
  }

  /* ----- Ending test ----- */

  csp_printf_format_info("TEST STEP 10 | Freeing Memory and Ending Test");

  // Wait some time to avoid troubles
  csp_delay_us(3);

  // Free memory
  for (i=0; i<MAX_Q_NUM; i++) {
    if (is_q_cfgrd[i] == 1) {
      free_mem_area(mem_descr_tx[i]);
      free_mem_area(mem_descr_rx[i]);
      free_mem_area(mem_dbuff_tx[i]);
      free_mem_area(mem_dbuff_rx[i]);
    }
  }

  return 0;
}

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

