//------------------------------------------------------------------------------
// Project    : cdn_gem_demo UVC
// Author     : bemanuel@cadence.com
// Company    : Cadence Design Systems
// Copyright (c) 2016 Cadence Design Systems, Inc. All rights reserved worldwide
// This work may not be copied, modified, re-published, uploaded, executed, or
// distributed in any way, in any medium, whether in whole or in part, without
// prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
// Description:
// See header file for full details.
//------------------------------------------------------------------------------

//------------------------------------
// Include Libraries
//------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
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
#include "emac_regs.h"

//------------------------------------
// Utility functions
//------------------------------------

uint32_t byte2word (uint8_t byte3, uint8_t byte2, uint8_t byte1, uint8_t byte0) {
  uint32_t sbyte0, sbyte1, sbyte2, sbyte3;

  sbyte0 = (byte0 <<  0) & 0x000000ff;
  sbyte1 = (byte1 <<  8) & 0x0000ff00;
  sbyte2 = (byte2 << 16) & 0x00ff0000;
  sbyte3 = (byte3 << 24) & 0xff000000;

  return sbyte0 + sbyte1 + sbyte2 + sbyte3;
}

//------------------

uint8_t get_random_byte () {
  uint8_t random_byte;

  random_byte = rand();

  return random_byte;
}

//------------------------------------
// Memory functions
//------------------------------------

void* alloc_mem_area (uint32_t size) {
  void* mem_area = malloc(size);

  if (mem_area == 0)
  {
    csp_printf_format_error("Heap size is too small!");
    return (void*)-1;
  }

  return (void*)mem_area;
}

//------------------

void free_mem_area (void* buff) {
  free(buff);
}

//------------------------------------
// Descriptor Table functions
//------------------------------------

void write_descriptor (unsigned char *mem_descr, int offset, uint32_t word1, uint32_t word0) {
  int i;

  csp_printf_format_debug("Writing Descriptor: Mem = 0x%x, offset = 0x%x", mem_descr, offset);

  // Writing Word 0
  for (i=0 ; i<4 ; i++) {
    mem_descr[offset+i] = (word0 >> i*8) & 0xff;
    csp_printf_format_debug("  byte = %d | value = 0x%02x - W0", i, mem_descr[offset+i]);
  }

  // Writing Word 1
  for (i=4 ; i<8 ; i++) {
    mem_descr[offset+i] = (word1 >> (i-4)*8) & 0xff;
    csp_printf_format_debug("  byte = %d | value = 0x%02x - W1", i, mem_descr[offset+i]);
  }
}

//------------------------------------
// Databuffer functions
//------------------------------------

void write_databuffer (unsigned char *mem_dbuff, int offset, enet_header_t enet_fields, ip_header_t ip_fields, udp_header_t udp_fields, uint8_t *payload) {
  // i: byte index
  // j: fill index
  // k: a third index used for array fields
  // i_temp: a temporary byte index for when the header is of variable length
  int i, j, k, i_temp;

  // Placeholders to assure shift operations of <8 bits fields
  uint8_t dummy_byte_1, dummy_byte_2;

  csp_printf_format_debug("Writing Databuffer: Mem = 0x%x, offset = 0x%x",
    mem_dbuff, offset);

  // NOTE: MSBs of fields are to be written to lower memory positions.

  //-----------------
  // Ethernet Header
  //-----------------

  // Destination Address
  for (k=0; k<=2; k++) {
    j = 1;
    for (i=0+2*k; i<=1+2*k; i++) {
      mem_dbuff[offset+i] = (enet_fields.dst_addr[k] >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - ENET DST ADDR [%d:%d]",
        i, mem_dbuff[offset+i], 7+16*(2-k)+8*j, 16*(2-k)+8*j);
      j--;
    }
  }

  // Source Address
  for (k=0; k<=2; k++) {
    j = 1;
    for (i=6+2*k; i<=7+2*k; i++) {
      mem_dbuff[offset+i] = (enet_fields.src_addr[k] >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - ENET SRC ADDR [%d:%d]",
        i, mem_dbuff[offset+i], 7+16*(2-k)+8*j, 16*(2-k)+8*j);
      j--;
    }
  }

  // Type/Length
  j = 1;
  for (i=12; i<=13; i++) {
    mem_dbuff[offset+i] = (enet_fields.type_length >> j*8) & 0xff;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - ENET TYPE LENGTH [%d:%d]",
      i, mem_dbuff[offset+i], 7+8*j, 8*j);
    j--;
  }

  if (!ip_fields.mode) {

    //-----------------
    // IPv4 Header
    //-----------------

    // Version/IHL
    i=14;
    dummy_byte_1 = ip_fields.ipv4_version;
    mem_dbuff[offset+i] = ((dummy_byte_1 << 4) & 0xf0) + ip_fields.ipv4_ihl;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 VER/IHL",
      i, mem_dbuff[offset+i]);

    // Differentiated Services
    i=15;
    mem_dbuff[offset+i] = ip_fields.ipv4_dscp;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 DSCP",
      i, mem_dbuff[offset+i]);

    // Total Length
    j=1;
    for (i=16; i<=17; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv4_total_length >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 TOTAL LENGTH [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Identification
    j=1;
    for (i=18; i<=19; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv4_identification >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 ID [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Flags/Fragment Offset
    i=20;
    dummy_byte_1 = ip_fields.ipv4_flags;
    dummy_byte_2 = ip_fields.ipv4_frag_offset;
    mem_dbuff[offset+i] = ((dummy_byte_1 << 5) & 0xe0) + ((dummy_byte_2 >> 8) & 0x1f);
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 FLAGS/FRAG OFF [12:8]",
      i, mem_dbuff[offset+i]);

    i=21;
    mem_dbuff[offset+i] = ip_fields.ipv4_frag_offset;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 FRAG OFF [7:0]",
      i, mem_dbuff[offset+i]);

    // Time To Live
    i=22;
    mem_dbuff[offset+i] = ip_fields.ipv4_time_to_live;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 TTL",
      i, mem_dbuff[offset+i]);

    // Protocol
    i=23;
    mem_dbuff[offset+i] = ip_fields.ipv4_protocol;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 PROT",
      i, mem_dbuff[offset+i]);

    // Checksum
    j=1;
    for (i=24; i<=25; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv4_checksum >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 CHKSUM [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Source Address
    j=3;
    for (i=26; i<=29; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv4_src_addr >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 SRC ADDR [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Destination Address
    j=3;
    for (i=30; i<=33; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv4_dst_addr >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 DST ADDR [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Options
    if (ip_fields.ipv4_ihl>5) {
      for (k=0; k<ip_fields.ipv4_ihl-5; k++) {
        j = 3;
        for (i=34+4*k; i<=37+4*k; i++) {
          mem_dbuff[offset+i] = (ip_fields.ipv4_options[k] >> j*8) & 0xff;
          csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv4 OPTIONS [%d:%d]",
            i, mem_dbuff[offset+i], 7+64*(ip_fields.ipv4_ihl-6-k)+8*j, 64*(ip_fields.ipv4_ihl-6-k)+8*j);
          j--;
        }
      }
    }

  } else {

    //-----------------
    // IPv6 Header
    //-----------------

    // Version/Traffic Class/Flow Label
    i=14;
    dummy_byte_1 = ip_fields.ipv6_version;
    dummy_byte_2 = ip_fields.ipv6_traffic_class;
    mem_dbuff[offset+i] = ((dummy_byte_1 << 4) & 0xf0) + ((dummy_byte_2 >> 4) & 0x0f);
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 VERSION/TC [7:4]",
      i, mem_dbuff[offset+i]);

    i=15;
    dummy_byte_1 = ip_fields.ipv6_traffic_class;
    dummy_byte_2 = (ip_fields.ipv6_flow_label >> 16);
    mem_dbuff[offset+i] = ((dummy_byte_1 << 4) & 0xf0) + (dummy_byte_2 & 0x0f);
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 TC [3:0]/FLOW LBL [19:16]",
      i, mem_dbuff[offset+i]);

    j=1;
    for (i=16; i<=17; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv6_flow_label >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 FLOW LBL [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Payload Length
    j=1;
    for (i=18; i<=19; i++) {
      mem_dbuff[offset+i] = (ip_fields.ipv6_payload_length >> j*8) & 0xff;
      csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 PL LNGT [%d:%d]",
        i, mem_dbuff[offset+i], 7+8*j, 8*j);
      j--;
    }

    // Next Header
    i=20;
    mem_dbuff[offset+i] = ip_fields.ipv6_next_header;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 NXT HEAD",
      i, mem_dbuff[offset+i]);

    // Hop Limit
    i=21;
    mem_dbuff[offset+i] = ip_fields.ipv6_hop_limit;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 HOP LIM",
      i, mem_dbuff[offset+i]);

    // Source Address
    for (k=0; k<=3; k++) {
      j=3;
      for (i=22+4*k; i<=25+4*k; i++) {
        mem_dbuff[offset+i] = (ip_fields.ipv6_src_addr[k] >> j*8) & 0xff;
        csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 SRC ADDR [%d:%d]",
          i, mem_dbuff[offset+i], 7+32*(3-k)+8*j, 32*(3-k)+8*j);
        j--;
      }
    }

    // Destination Address
    for (k=0; k<=3; k++) {
      j=3;
      for (i=38+4*k; i<=41+4*k; i++) {
        mem_dbuff[offset+i] = (ip_fields.ipv6_dst_addr[k] >> j*8) & 0xff;
        csp_printf_format_debug("  byte = %04d | value = 0x%02x - IPv6 DST ADDR [%d:%d]",
          i, mem_dbuff[offset+i], 7+32*(3-k)+8*j, 32*(3-k)+8*j);
        j--;
      }
    }
  }

  //-----------------
  // UDP Header
  //-----------------

  // Since in the IPv4 case the byte index depends on IHL, store here the
  // current value of the byte index and carry on from that
  i_temp=i;

  // Source Port
  j=1;
  for (i=i_temp; i<=i_temp+1; i++) {
    mem_dbuff[offset+i] = (udp_fields.src_port >> j*8) & 0xff;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - UDP SRC PORT [%d:%d]",
      i, mem_dbuff[offset+i], 7+8*j, 8*j);
    j--;
  }

  // Destination Port
  j=1;
  for (i=i_temp+2; i<=i_temp+3; i++) {
    mem_dbuff[offset+i] = (udp_fields.dst_port >> j*8) & 0xff;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - UDP DST PORT [%d:%d]",
      i, mem_dbuff[offset+i], 7+8*j, 8*j);
    j--;
  }

  // Length
  j=1;
  for (i=i_temp+4; i<=i_temp+5; i++) {
    mem_dbuff[offset+i] = (udp_fields.length >> j*8) & 0xff;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - UDP LNGT [%d:%d]",
      i, mem_dbuff[offset+i], 7+8*j, 8*j);
    j--;
  }

  // Checksum
  j=1;
  for (i=i_temp+6; i<=i_temp+7; i++) {
    mem_dbuff[offset+i] = (udp_fields.checksum >> j*8) & 0xff;
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - UDP CHKSUM [%d:%d]",
      i, mem_dbuff[offset+i], 7+8*j, 8*j);
    j--;
  }

  //-----------------
  // Payload
  //-----------------

  // Do it again
  i_temp=i;

  // Fill with data content passed through function arguments
  for (i=i_temp; i<=i_temp+(udp_fields.length-8)-1; i++) {
    mem_dbuff[offset+i] = payload[i-i_temp];
    csp_printf_format_debug("  byte = %04d | value = 0x%02x - UDP PL [%d:%d]",
      i, mem_dbuff[offset+i], 7+8*(i_temp+(udp_fields.length-8)-1-i), 8*(i_temp+(udp_fields.length-8)-1-i));
  }
}

//------------------

void compare_databuffers (unsigned char *mem_dbuff_a, int offset_a, unsigned char *mem_dbuff_b, int offset_b, int length) {
  int i;

  csp_printf_format_debug("Comparing Databuffers: Mem A = 0x%x, offset A = 0x%x - Mem B = 0x%x, offset B = 0x%x",
    mem_dbuff_a, offset_a, mem_dbuff_b, offset_b);
  for (i=0 ; i<length ; i++) {
    if(mem_dbuff_a[offset_a+i] != mem_dbuff_b[offset_b+i]) {
      csp_printf_format_error("*** Wrong Comparison ***  byte = %04d | mem_dbuff_a = 0x%02x | mem_dbuff_b = 0x%02x",
        i, mem_dbuff_a[offset_a+i], mem_dbuff_b[offset_b+i]);
    } else {
      csp_printf_format_debug("  byte = %04d | mem_dbuff_a = mem_dbuff_b = 0x%02x",
        i, mem_dbuff_b[offset_b+i]);
    }
  }
}

//------------------------------------
// Regs functions
//------------------------------------

void write_q_ptr(volatile uint32_t *address, int is_q_cfgrd, int enable, ...) {
  va_list args;
  va_start(args, enable);

  if (is_q_cfgrd) {
    if(enable)
      csp_write32(address, va_arg(args, uintptr_t));
    else
      csp_write32(address, 0x00000001);
  }

  va_end(args);
}

//------------------

void write_scr1(volatile uint32_t *address, int is_scr1_cfgrd, int enable, ...) {
  va_list args;
  va_start(args, enable);

  if (is_scr1_cfgrd) {
    if(enable)
      csp_write32(address, va_arg(args, uintptr_t));
    else
      csp_write32(address, 0x00000000);
  }

  va_end(args);
}

//------------------------------------
// Check functions
//------------------------------------

void waitfor (volatile uint32_t *address, uint32_t mask, uint32_t value, uint16_t max_reads) {
  uint32_t data  = 0;
  uint16_t reads = 0;

  // Continuous check. Reads the register pointed by address and increment the
  // reads count.
  do {
    data = csp_read32(address);
    reads++;
  }
  while ((reads < max_reads) && ((data & mask) != value));

  // If the continuous checks failed, print an error.
  if ((data & mask) != value) {
    csp_printf_format_error("Function waitfor FAILED!");
    csp_printf_format_debug("  After %d reads from 0x%x: (data & mask) != 0x%x", reads, address, value);
    csp_printf_format_debug("  Instead, (data & mask) = 0x%x", data & mask);
  }
}

//------------------------------------
// Setup functions
//------------------------------------

void test_setup(struct emac_regs *regs, uint32_t *cfg_decode, int *is_q_cfgrd) {
  int i = 0;
  int q_num = 1;
  uint32_t mask = 0x2;

  // Read the designcfg_debug regs
  cfg_decode[0]  = csp_read32(&regs->designcfg_debug1);
  cfg_decode[1]  = csp_read32(&regs->designcfg_debug2);
  cfg_decode[2]  = csp_read32(&regs->designcfg_debug3);
  cfg_decode[3]  = csp_read32(&regs->designcfg_debug4);
  cfg_decode[4]  = csp_read32(&regs->designcfg_debug5);
  cfg_decode[5]  = csp_read32(&regs->designcfg_debug6);
  cfg_decode[6]  = csp_read32(&regs->designcfg_debug7);
  cfg_decode[7]  = csp_read32(&regs->designcfg_debug8);
  cfg_decode[8]  = csp_read32(&regs->designcfg_debug9);
  cfg_decode[9]  = csp_read32(&regs->designcfg_debug10);
  cfg_decode[10] = csp_read32(&regs->designcfg_debug11);
  cfg_decode[11] = csp_read32(&regs->designcfg_debug12);

  // Print designcfg_debug regs content
  csp_printf_format_debug("designcfg_debug1  = 0x%x", cfg_decode[0]);
  csp_printf_format_debug("designcfg_debug2  = 0x%x", cfg_decode[1]);
  csp_printf_format_debug("designcfg_debug3  = 0x%x", cfg_decode[2]);
  csp_printf_format_debug("designcfg_debug4  = 0x%x", cfg_decode[3]);
  csp_printf_format_debug("designcfg_debug5  = 0x%x", cfg_decode[4]);
  csp_printf_format_debug("designcfg_debug6  = 0x%x", cfg_decode[5]);
  csp_printf_format_debug("designcfg_debug7  = 0x%x", cfg_decode[6]);
  csp_printf_format_debug("designcfg_debug8  = 0x%x", cfg_decode[7]);
  csp_printf_format_debug("designcfg_debug9  = 0x%x", cfg_decode[8]);
  csp_printf_format_debug("designcfg_debug10 = 0x%x", cfg_decode[9]);
  csp_printf_format_debug("designcfg_debug11 = 0x%x", cfg_decode[10]);
  csp_printf_format_debug("designcfg_debug12 = 0x%x", cfg_decode[11]);

  // Decode the number of queues configured in the design. Queue 0 is always
  // enabled by default.
  csp_printf_format_debug("designcfg_debug6[15:1] = 0x%x", cfg_decode[5] & 0xfffe);
  is_q_cfgrd[0] = 1;
  for (i=1; i<MAX_Q_NUM; i++) {
    is_q_cfgrd[i] = (mask & cfg_decode[5]) >> i;
    if (is_q_cfgrd[i]) {
      q_num++;
    }
    csp_printf_format_debug("Decode q %2d | mask = 0x%4x | mask & cfg_decode[5] = 0x%4x | is_q_cfgrd[i] = %d",
      i, mask, mask & cfg_decode[5], is_q_cfgrd[i]);
    mask = mask << 1;
  }
  csp_printf_format_debug("Total number of queues detected | q_num = %d", q_num);

  // Setup the network_control
  csp_write32(&regs->network_control, 0x00000000);

  // Setup the dma_config
  csp_write32(&regs->dma_config, 0x00040704);

  // Setup the network_config
  csp_write32(&regs->network_config, ((cfg_decode[0] & 0x0c000000) >> 5) + 0x0080413);
}

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

