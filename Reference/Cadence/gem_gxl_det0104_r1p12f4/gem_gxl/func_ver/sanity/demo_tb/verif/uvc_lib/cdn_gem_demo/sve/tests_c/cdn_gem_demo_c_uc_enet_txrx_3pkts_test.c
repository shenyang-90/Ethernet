//------------------------------------------------------------------------------
// File      : cdn_gem_demo_c_uc_enet_txrx_3pkts_test.c
// Author    : bemanuel@cadence.com
// Date      : 11th May, 2017
//------------------------------------------------------------------------------
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
//------------------------------------------------------------------------------
/*!
// @page cdn_gem_demo_c_uc_enet_txrx_3pkts_test
// 
// Description
// ===========
//
// Three packets are transmitted and received using an external loopback
// connection in the testbench.
//
// 0. Basic DUT initialization:
//    * Decode the design configuration.
//    * Write the `network_control`, `dma_config` and `network_config` regs to 
//      set basic properties (speed mode, buffer addressable space, etc).
// 1. System memory allocation:
//    * Descriptor memory (Tx and Rx).
//    * Databuffer memory (Tx and Rx).
// 2. Setting the system memory:
//    * Setting the Tx descriptor memory:
//      - The first through third descriptors are pointed to the Tx databuffer
//        locations in the relative memory area.
//      - The fourth descriptor is marked with used and wrap bits set, i.e. last 
//        descriptor in the table.
//    * Setting the Tx databuffer memory:
//      - Three IPoE databuffers (IPv6/UDP or IPv4/UDP) are written.
//    * Setting the Rx descriptor memory:
//      - The first through third descriptors are pointed to the Rx databuffer
//        locations in the relative area.
//      - The fourth descriptor is marked with the wrap bits set, i.e. last
//        descriptor in the table.
// 3. Setting needed DUT registers:
//    * Store the Tx descriptor table base address in `transmit_q_ptr` reg.
//    * Disable the other ques by writing a `1` in `transmit_q1_ptr` through
//      `transmit_q15_ptr` regs.
//    * Store the Rx descriptor table base address in the `receive_q_ptr` reg.
//    * Disable the other ques by writing a `1` in `receive_q1_ptr` through
//      `receive_q15_ptr` regs.
// 4. Tx-Rx transaction:
//    * Write the `network_control` reg for the Tx-Rx transaction to start.
//    * Wait until the packets have been transmitted and received.
//    * Compare the Tx-Rx databuffer memories to check for the transaction
//      correctness.
// 5. Test ends:
//    * Free memory areas allocated at the beginning.
*/
//------------------------------------------------------------------------------

/*! \file cdn_gem_demo_c_uc_enet_txrx_3pkts_test.c
 *  \brief This file defines a Tx-Rx test.
 *         Three packets is transmitted and received using an external loopback
 *         connection in the testbench.
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
  
  // Descriptor table variables
  unsigned char *mem_descr_tx;
  unsigned char *mem_descr_rx;
  uint32_t size_dtable = 0xffff;
  uint32_t word0, word1;

  // Databuffer variables
  unsigned char *mem_dbuff_tx;
  unsigned char *mem_dbuff_rx;
  uint32_t size_dbuff = 0xffff;
  enet_header_t enet_fields;
  ip_header_t ip_fields;
  udp_header_t udp_fields;
  uint8_t udp_payload[138];

  // Misc variables
  int i;

  /* ----- Test Setup ----- */

  csp_printf_format_info("TEST STEP 0  | Setting Up the Test");
  test_setup(regs, cfg_decode, is_q_cfgrd);

  /* ----- System Memory Allocation ----- */

  // Descriptor Table Allocation
  csp_printf_format_info("TEST STEP 1  | Allocating Descriptor Memory");

  mem_descr_tx = (unsigned char*)alloc_mem_area(size_dtable);
  mem_descr_rx = (unsigned char*)alloc_mem_area(size_dtable);
  csp_printf_format_debug("Descriptor Table base address | Tx: 0x%x | Rx: 0x%x",
    mem_descr_tx, mem_descr_rx);

  // Databuffer Allocation
  csp_printf_format_info("TEST STEP 2  | Allocating Databuffer Memory");

  mem_dbuff_tx = (unsigned char*)alloc_mem_area(size_dbuff);
  mem_dbuff_rx = (unsigned char*)alloc_mem_area(size_dbuff);
  csp_printf_format_debug("Databuffer Mem base address | Tx: 0x%x | Rx: 0x%x",
    mem_dbuff_tx, mem_dbuff_rx);

  /* ----- Setting the Descriptors and Databuffres ----- */

  csp_printf_format_info("TEST STEP 3  | Setting Tx Descriptor Memory");

  // 1st descriptor
  word0 = (uintptr_t)mem_dbuff_tx;
  word1 = 0x00008040;
  write_descriptor(mem_descr_tx, 0x000, word1, word0);

  // 2nd descriptor
  word0 = (uintptr_t)mem_dbuff_tx + 0x100;
  word1 = 0x00008040;
  write_descriptor(mem_descr_tx, 0x008, word1, word0);

  // 3nd descriptor
  word0 = (uintptr_t)mem_dbuff_tx + 0x200;
  word1 = 0x00008040;
  write_descriptor(mem_descr_tx, 0x010, word1, word0);

  // 4th descriptor (last)
  word0 = byte2word((uintptr_t)mem_descr_tx[0x1b],
                    (uintptr_t)mem_descr_tx[0x1a],
                    (uintptr_t)mem_descr_tx[0x19],
                    (uintptr_t)mem_descr_tx[0x18]);
  word1 = byte2word(0xc0                         ,
                    (uintptr_t)mem_descr_tx[0x1e],
                    (uintptr_t)mem_descr_tx[0x1d],
                    (uintptr_t)mem_descr_tx[0x1c]);
  write_descriptor(mem_descr_tx, 0x018, word1, word0);

  csp_printf_format_info("TEST STEP 4  | Setting Tx Databuffer Memory");

  // Initialize an IPv6/UDP IPoE databuffer (mode = 1)
  ip_fields.mode                = 1;
  for (i=0; i<3; i++) {
    enet_fields.dst_addr[i]     = 0x1111;                         // don't care
    enet_fields.src_addr[i]     = 0x2222;                         // don't care
  }
  enet_fields.type_length       = 0x86dd;                         // must be 0x86dd for IPv6
  ip_fields.ipv6_version        = 0x6;                            // must be 0x6 for IPv6
  ip_fields.ipv6_traffic_class  = 0x33;                           // don't care
  ip_fields.ipv6_flow_label     = 0x44444;                        // don't care
  ip_fields.ipv6_payload_length = 0x000a;                         // consitent with buffer length
  ip_fields.ipv6_next_header    = 0x11;                           // must be 0x11 (UDP)
  ip_fields.ipv6_hop_limit      = 0x55;                           // don't care
  for (i=0; i<4; i++) {
    ip_fields.ipv6_src_addr[i]  = 0x66666666;                     // don't care
    ip_fields.ipv6_dst_addr[i]  = 0x77777777;                     // don't care
  }
  udp_fields.src_port           = 0x8888;                         // don't care
  udp_fields.dst_port           = 0x9999;                         // don't care
  udp_fields.length             = ip_fields.ipv6_payload_length;  // consistent with buffer length
  udp_fields.checksum           = 0x441f;                         // the value for this IPv6 pseudo header
  for (i=0; i<udp_fields.length-8; i++) {
    udp_payload[i]              = 0xaa;                           // don't care
  }
  write_databuffer(mem_dbuff_tx, 0x000, enet_fields, ip_fields, udp_fields, udp_payload);

  // Initialize an IPv4/UDP IPoE databuffer (mode = 0)
  ip_fields.mode                = 0;
  for (i=0; i<3; i++) {
    enet_fields.dst_addr[i]     = 0x1111;                         // don't care
    enet_fields.src_addr[i]     = 0x2222;                         // don't care
  }
  enet_fields.type_length       = 0x0800;                         // must be 0x0800 for IPv4
  ip_fields.ipv4_version        = 0x4;                            // must be 0x4 for IPv4
  ip_fields.ipv4_ihl            = 0x5;                            // don't use options
  ip_fields.ipv4_dscp           = 0x33;                           // don't care
  ip_fields.ipv4_total_length   = 0x0032;                         // consitent with buffer length
  ip_fields.ipv4_identification = 0x4444;                         // don't care
  ip_fields.ipv4_flags          = 0x0;                            // fragmentation is not supported
  ip_fields.ipv4_frag_offset    = 0x0000;                         // fragmentation is not supported
  ip_fields.ipv4_time_to_live   = 0x55;                           // don't care
  ip_fields.ipv4_protocol       = 0x11;                           // must be 0x11 (UDP)
  ip_fields.ipv4_checksum       = 0x6549;                         // the value for this IPv4 header
  ip_fields.ipv4_src_addr       = 0x66666666;                     // don't care
  ip_fields.ipv4_dst_addr       = 0x77777777;                     // don't care
  udp_fields.src_port           = 0x8888;                         // don't care
  udp_fields.dst_port           = 0x9999;                         // don't care
  udp_fields.length             = ip_fields.ipv4_total_length-20; // consistent with buffer length
  udp_fields.checksum           = 0x0000;                         // unused
  for (i=0; i<udp_fields.length-8; i++) {
    udp_payload[i]              = 0xaa;                           // don't care
  }
  write_databuffer(mem_dbuff_tx, 0x100, enet_fields, ip_fields, udp_fields, udp_payload);
  
  // Initialize an IPv4/UDP IPoE databuffer (mode = 0)
  ip_fields.mode                = 0;
  for (i=0; i<3; i++) {
    enet_fields.dst_addr[i]     = 0x1111;                         // don't care
    enet_fields.src_addr[i]     = 0x2222;                         // don't care
  }
  enet_fields.type_length       = 0x0800;                         // must be 0x0800 for IPv4
  ip_fields.ipv4_version        = 0x4;                            // must be 0x4 for IPv4
  ip_fields.ipv4_ihl            = 0x7;                            // use 8 bytes of options
  ip_fields.ipv4_dscp           = 0x33;                           // don't care
  ip_fields.ipv4_total_length   = 0x0032;                         // consitent with buffer length
  ip_fields.ipv4_identification = 0x4444;                         // don't care
  ip_fields.ipv4_flags          = 0x0;                            // fragmentation is not supported
  ip_fields.ipv4_frag_offset    = 0x0000;                         // fragmentation is not supported
  ip_fields.ipv4_time_to_live   = 0x55;                           // don't care
  ip_fields.ipv4_protocol       = 0x11;                           // must be 0x11 (UDP)
  ip_fields.ipv4_checksum       = 0xc86f;                         // the value for this IPv4 header
  ip_fields.ipv4_src_addr       = 0x66666666;                     // don't care
  ip_fields.ipv4_dst_addr       = 0x77777777;                     // don't care
  ip_fields.ipv4_options[0]     = 0x88888888;                     // don't care
  ip_fields.ipv4_options[1]     = 0x99999999;                     // don't care
  udp_fields.src_port           = 0xaaaa;                         // don't care
  udp_fields.dst_port           = 0xbbbb;                         // don't care
  udp_fields.length             = ip_fields.ipv4_total_length-28; // consistent with buffer length
  udp_fields.checksum           = 0x0000;                         // unused
  for (i=0; i<udp_fields.length-8; i++) {
    udp_payload[i]              = 0xcc;                           // don't care
  }
  write_databuffer(mem_dbuff_tx, 0x200, enet_fields, ip_fields, udp_fields, udp_payload);

  csp_printf_format_info("TEST STEP 5  | Setting Rx Descriptor Memory");

  // 1st descriptor
  word0 = (uintptr_t)mem_dbuff_rx;
  word1 = byte2word((uintptr_t)mem_descr_rx[0x07], 
                    (uintptr_t)mem_descr_rx[0x06], 
                    (uintptr_t)mem_descr_rx[0x05], 
                    (uintptr_t)mem_descr_rx[0x04]);
  write_descriptor(mem_descr_rx, 0x000, word1, word0);

  // 2nd descriptor
  word0 = (uintptr_t)mem_dbuff_rx + 0x100;
  word1 = byte2word((uintptr_t)mem_descr_rx[0x0f], 
                    (uintptr_t)mem_descr_rx[0x0e], 
                    (uintptr_t)mem_descr_rx[0x0d], 
                    (uintptr_t)mem_descr_rx[0x0c]);
  write_descriptor(mem_descr_rx, 0x008, word1, word0);

  // 3rd descriptor
  word0 = (uintptr_t)mem_dbuff_rx + 0x200;
  word1 = byte2word((uintptr_t)mem_descr_rx[0x17], 
                    (uintptr_t)mem_descr_rx[0x16], 
                    (uintptr_t)mem_descr_rx[0x15], 
                    (uintptr_t)mem_descr_rx[0x14]);
  write_descriptor(mem_descr_rx, 0x010, word1, word0);

  // 4th descriptor
  word0 = byte2word((uintptr_t)mem_descr_rx[0x1b], 
                    (uintptr_t)mem_descr_rx[0x1a], 
                    (uintptr_t)mem_descr_rx[0x19], 
                    (uintptr_t)0x02              );
  word1 = byte2word((uintptr_t)mem_descr_rx[0x1f], 
                    (uintptr_t)mem_descr_rx[0x1e], 
                    (uintptr_t)mem_descr_rx[0x1d], 
                    (uintptr_t)mem_descr_rx[0x1c]);
  write_descriptor(mem_descr_rx, 0x018, word1, word0);

  /* ----- APB Programming ----- */

  csp_printf_format_info("TEST STEP 6  | Setting the Needed DUT Registers");

  // Program the Tx queue pointers
  write_q_ptr(&regs->transmit_q_ptr,   is_q_cfgrd[0],  1, (uintptr_t)mem_descr_tx);
  write_q_ptr(&regs->transmit_q1_ptr,  is_q_cfgrd[1],  0);
  write_q_ptr(&regs->transmit_q2_ptr,  is_q_cfgrd[2],  0);
  write_q_ptr(&regs->transmit_q3_ptr,  is_q_cfgrd[3],  0);
  write_q_ptr(&regs->transmit_q4_ptr,  is_q_cfgrd[4],  0);
  write_q_ptr(&regs->transmit_q5_ptr,  is_q_cfgrd[5],  0);
  write_q_ptr(&regs->transmit_q6_ptr,  is_q_cfgrd[6],  0);
  write_q_ptr(&regs->transmit_q7_ptr,  is_q_cfgrd[7],  0);
  write_q_ptr(&regs->transmit_q8_ptr,  is_q_cfgrd[8],  0);
  write_q_ptr(&regs->transmit_q9_ptr,  is_q_cfgrd[9],  0);
  write_q_ptr(&regs->transmit_q10_ptr, is_q_cfgrd[10], 0);
  write_q_ptr(&regs->transmit_q11_ptr, is_q_cfgrd[11], 0);
  write_q_ptr(&regs->transmit_q12_ptr, is_q_cfgrd[12], 0);
  write_q_ptr(&regs->transmit_q13_ptr, is_q_cfgrd[13], 0);
  write_q_ptr(&regs->transmit_q14_ptr, is_q_cfgrd[14], 0);
  write_q_ptr(&regs->transmit_q15_ptr, is_q_cfgrd[15], 0);

  // Program the Rx queue pointers
  write_q_ptr(&regs->receive_q_ptr,   is_q_cfgrd[0],  1, (uintptr_t)mem_descr_rx);
  write_q_ptr(&regs->receive_q1_ptr,  is_q_cfgrd[1],  0);
  write_q_ptr(&regs->receive_q2_ptr,  is_q_cfgrd[2],  0);
  write_q_ptr(&regs->receive_q3_ptr,  is_q_cfgrd[3],  0);
  write_q_ptr(&regs->receive_q4_ptr,  is_q_cfgrd[4],  0);
  write_q_ptr(&regs->receive_q5_ptr,  is_q_cfgrd[5],  0);
  write_q_ptr(&regs->receive_q6_ptr,  is_q_cfgrd[6],  0);
  write_q_ptr(&regs->receive_q7_ptr,  is_q_cfgrd[7],  0);
  write_q_ptr(&regs->receive_q8_ptr,  is_q_cfgrd[8],  0);
  write_q_ptr(&regs->receive_q9_ptr,  is_q_cfgrd[9],  0);
  write_q_ptr(&regs->receive_q10_ptr, is_q_cfgrd[10], 0);
  write_q_ptr(&regs->receive_q11_ptr, is_q_cfgrd[11], 0);
  write_q_ptr(&regs->receive_q12_ptr, is_q_cfgrd[12], 0);
  write_q_ptr(&regs->receive_q13_ptr, is_q_cfgrd[13], 0);
  write_q_ptr(&regs->receive_q14_ptr, is_q_cfgrd[14], 0);
  write_q_ptr(&regs->receive_q15_ptr, is_q_cfgrd[15], 0);

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

  compare_databuffers(mem_dbuff_rx, 0x000, mem_dbuff_tx, 0x000, 0x32+14);
  compare_databuffers(mem_dbuff_rx, 0x100, mem_dbuff_tx, 0x100, 0x32+14);
  compare_databuffers(mem_dbuff_rx, 0x200, mem_dbuff_tx, 0x200, 0x32+14);

  /* ----- Ending test ----- */

  csp_printf_format_info("TEST STEP 10 | Freeing Memories and Ending Test");

  // Wait some time to avoid troubles
  csp_delay_us(3);

  // Free memory
  free_mem_area(mem_descr_tx);
  free_mem_area(mem_descr_rx);
  free_mem_area(mem_dbuff_tx);
  free_mem_area(mem_dbuff_rx);

  return 0;
}

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

