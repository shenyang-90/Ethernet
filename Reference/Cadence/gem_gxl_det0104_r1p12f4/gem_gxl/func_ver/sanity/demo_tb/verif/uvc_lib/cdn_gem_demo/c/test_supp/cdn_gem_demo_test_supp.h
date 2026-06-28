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
// Common functions to be used in Ethernet C tests.
//------------------------------------------------------------------------------

/*! \file cdn_gem_demo_test_supp.h
 *  \brief Definition of GEM_GXL support functions and macros used within C
 *         tests.
 */

#ifndef _ENET_COMMON_H_
  #define _ENET_COMMON_H_

  #include <stdint.h>
  #include "emac_regs.h"

  //------------------------------------
  // Macros
  //------------------------------------

  /*! The maximum number of queues available in the design. */
  #define MAX_Q_NUM 16

  /*! The maximum number of screeners (type 1) registers available in the 
   *  design.
   */
  #define MAX_SCR1_NUM 16

  /*! The number of Design Configuration Registers in the design. */
  #define DESIGNCFG_REG_NUM 12

  /*! Wrap printf functions with demo TB or CSP implementation. */
  #ifdef CDN_DEMO_TB
    #define csp_printf_format_error   cdn_demo_printf_error
    #define csp_printf_format_warning cdn_demo_printf_warning
    #define csp_printf_format_info    cdn_demo_printf_info
    #define csp_printf_format_debug   cdn_demo_printf_debug
  #else
    #define csp_printf_format_error(format, ...)   csp_printf_error(format "\n", ##__VA_ARGS__)
    #define csp_printf_format_warning(format, ...) csp_printf_warning(format "\n", ##__VA_ARGS__)
    #define csp_printf_format_info(format, ...)    csp_printf_info(format "\n", ##__VA_ARGS__)
    #define csp_printf_format_debug(format, ...)   csp_printf_debug(format "\n", ##__VA_ARGS__)
  #endif

  //------------------------------------
  // Typedefs
  //------------------------------------  
  
  /*! A struct for the fields of the Ethernet header. */
  typedef struct enet_header {
    uint16_t dst_addr[3];         // 2 bytes per element (MSBs at low indexes)
    uint16_t src_addr[3];         // 2 bytes per element (MSBs at low indexes)
    uint16_t type_length;         // 2 bytes
  } enet_header_t;                // TOTAL: 14 bytes

  /*! A struct for the fields of IP headers (both IPv4 and IPv6). */
  typedef struct ip_header {
    int      mode;                // Select between IPv4 (0) and IPv6 (1)
    // IPv4
    uint8_t  ipv4_version:4;      // 1 nibble
    uint8_t  ipv4_ihl:4;          // 1 nibble
    uint8_t  ipv4_dscp;           // 1 byte
    uint16_t ipv4_total_length;   // 2 bytes
    uint16_t ipv4_identification; // 2 bytes
    uint8_t  ipv4_flags:3;        // 3 bits
    uint16_t ipv4_frag_offset:13; // 5 bits + 1 byte
    uint8_t  ipv4_time_to_live;   // 1 byte
    uint8_t  ipv4_protocol;       // 1 byte
    uint16_t ipv4_checksum;       // 2 bytes
    uint32_t ipv4_src_addr;       // 4 bytes
    uint32_t ipv4_dst_addr;       // 4 bytes
    uint32_t ipv4_options[10];    // 4 bytes per element (MSBs at low indexes)
    // IPv6                           
    uint8_t  ipv6_version:4;      // 1 nibble
    uint8_t  ipv6_traffic_class;  // 1 byte
    uint32_t ipv6_flow_label:20;  // 1 nibble + 2 bytes
    uint16_t ipv6_payload_length; // 2 bytes
    uint8_t  ipv6_next_header;    // 1 byte
    uint8_t  ipv6_hop_limit;      // 1 byte
    uint32_t ipv6_src_addr[4];    // 4 bytes per element (MSBs at low indexes)
    uint32_t ipv6_dst_addr[4];    // 4 bytes per element (MSBs at low indexes)
  } ip_header_t;                  // TOTAL IPv4: 20 bytes (min)/ 60 bytes (max)
                                  // TOTAL IPv6: 40 bytes

  /*! A struct for the fields of the UDP header. */
  typedef struct udp_header {
    uint16_t src_port;            // 2 bytes 
    uint16_t dst_port;            // 2 bytes
    uint16_t length;              // 2 bytes
    uint16_t checksum;            // 2 bytes
  } udp_header_t;                 // TOTAL: 8 bytes
  
  //------------------------------------
  // Utility functions
  //------------------------------------

  /*! \fn uint32_t byte2word (uint8_t byte3, uint8_t byte2, uint8_t byte1, uint8_t byte0)
   *  \brief This function takes four bytes and concatenates them into a 32 bit
   *         word.
   *  \param byte0 Less significant byte.
   *  \param byte1 Second byte.
   *  \param byte2 Third byte.
   *  \param byte3 Most significant byte.
   */
  uint32_t byte2word (uint8_t byte3, uint8_t byte2, uint8_t byte1, uint8_t byte0);

  /*! \fn uint8_t get_random_byte ()
   *  \brief This function returns a random byte.
   *  
   *  Note that the random generator should be seeded outside this function.
   */
  uint8_t get_random_byte ();

  //------------------------------------
  // Memory functions
  //------------------------------------

  /*! \fn void* alloc_mem_area (uint32_t size)
   *  \brief Allocates a memory area and return its base address pointer.
   *  \param size The size of the memory area.
   */
  void* alloc_mem_area (uint32_t size);

  /*! \fn void free_mem_area (void* buff)
   *  \brief Free a previously allocated memory area.
   *  \param buff The base address of the memory area to free.
   */
  void free_mem_area (void* buff);

  //------------------------------------
  // Descriptor Table functions
  //------------------------------------

  /*! \fn void write_descriptor (unsigned char *mem_descr, int offset, uint32_t word1, uint32_t word0)
   *  \brief This function writes the Word 0 and the Word 1 of a buffer
   *         descriptor.
   *  \param mem_descr The memory area allocated as descriptor table.
   *  \param offset The offset of the descriptor into memory.
   *  \param word0 The content of the Word 0.
   *  \param word1 The content of the Word 1.
   */
  void write_descriptor (unsigned char *mem_descr, int offset, uint32_t word1, uint32_t word0);

  //------------------------------------
  // Databuffer functions
  //------------------------------------

  /*! \fn void write_databuffer (unsigned char *mem_dbuff, int offset, enet_header_t enet_fields, ip_header_t ip_fields, udp_header_t udp_fields, uint8_t *payload)
   *  \brief This function initializes an IPoE databuffer with IPv4/IPv6 header
   *         as network layer and UDP header as transport layer.
   *  \param mem_dbuff The databuffer memory area base address.
   *  \param offset The offset of the databuffer into memory.
   *  \param enet_fields The Ethernet header fields.
   *  \param ip_fields The IPv4/IPv6 header fields.
   *  \param udp_fields The UDP header fields.
   *  \param payload The UDP payload in bytes.
   *
   *  Note: this function doesn't check for protocol errors, so be wary when
   *  initializing data.
   */
  void write_databuffer (unsigned char *mem_dbuff, int offset, enet_header_t enet_fields, ip_header_t ip_fields, udp_header_t udp_fields, uint8_t *payload);

  /*! \fn void compare_databuffers (unsigned char *mem_dbuff_a, int offset_a, unsigned char *mem_dbuff_b, int offset_b, int length)
   *  \brief This function compares two databuffers.
   *  \param mem_dbuff_a The databuffer memory A.
   *  \param offset_a The offset of databuffer into memory A.
   *  \param mem_dbuff_b The databuffer memory area B.
   *  \param offset_b The offset of databuffer memory B.
   *  \param length The length of the databuffer in bytes.
   */
  void compare_databuffers (unsigned char *mem_dbuff_a, int offset_a, unsigned char *mem_dbuff_b, int offset_b, int length);

  //------------------------------------
  // Regs functions
  //------------------------------------

  /*! \fn void write_q_ptr(volatile uint32_t *address, int is_q_cfgrd, int enable, ...);
   *  \brief A variadic function which is used to write into design queue
   *         pointers regs.
   *  \param address The address of the queue pointer reg.
   *  \param is_q_cfgrd Can be 0 or 1. If 0, the queue is not configured in
   *         hardware and the queue pointer is not written. If 1, the queue
   *         pointer is programmed as per `enable` value.
   *  \param enable Enable (1) or disable (0) the relative queue via APB
   *         programming. If the queue is enabled, the write_q_ptr function
   *         takes as additional argument the queue pointer value.
   */
  void write_q_ptr(volatile uint32_t *address, int is_q_cfgrd, int enable, ...);

  /*! \fn void write_scr1(volatile uint32_t *address, int is_scr1_cfgrd, int enable, ...);
   *  \brief A variadic function which is used to write into design screnners
   *         type 1 regs.
   *  \param address The address of the screeners type 1 reg.
   *  \param is_scr1_cfgrd Can be 0 or 1. If 0, the screnner is not configured
   *         in hardware and the register is not written. If 1, the screener is
   *         programmed as per `enable` value.
   *  \param enable Enable (1) or disable (0) the relative screeener via APB
   *         programming. If the screener is enabled, the write_scr1 function
   *         takes as additional argument the register value.
   */
  void write_scr1(volatile uint32_t *address, int is_scr1_cfgrd, int enable, ...);

  //------------------------------------
  // Check functions
  //------------------------------------

  /*! \fn void waitfor(volatile uint32_t *address, uint32_t mask, uint32_t value, uint16_t max_reads)
   *  \brief This function checks a register until its stored data match an
   *         expected value.
   *  \param address The address of the register to check.
   *  \param mask A mask for the data stored in the register.
   *  \param value The expected value.
   *  \param max_reads The maximum number of reads after which the check fails.
   *
   *  1. The register is read in a `do while` loop until
   *     `(data & mask) == value` or the number of reads exceeds `max_reads`.
   *  2. If the loop exit is due to the former condition, `waitfor` returns 0.
   *  3. Otherwise, it prints an error message and returns 1.
   */
  void waitfor (volatile uint32_t *address, uint32_t mask, uint32_t value, uint16_t max_reads);

  //------------------------------------
  // Setup functions
  //------------------------------------

  /*! \fn void test_setup(struct emac_regs *regs, uint32_t cfg_decode, int *is_q_cfgrd);
   *  \brief This functions initializes basic configuration registers.
   *  \param regs A pointer to the register map.
   *  \param cfg_decode Stores the values of `design_cfg_dbg` regs.
   *  \param is_q_cfgrd Stores information about a queue being configured or not
   *         in the design.
   *
   * 1. Read the `designcfg_debug` regs to decode the design configuration:
   * - Decode the number of queues present in the design.
   * 
   * 2. Setup the `dma_config` reg.
   * - Attempt to use AXI burst length up to 8.
   * - Rx packet buffer uses full configured addressable space (8 kb).
   * - Tx packet buffer uses full configured addressable space (4 kb).
   * - Set the databuffer size to be 256 bytes.
   * 
   * 3. Setup the `network_config` reg.
   * - Set 100 Mpbs operation.
   * - Set full duplex mode.
   * - Accept all valid frames.
   * - Configure the GEM for 1000 Mbps operation.
   * - Divide the pclk period by 32 (pclk up to 40 MHz).
   * - Set the AXI bus width depending on the decoded configuration.
   */
  void test_setup(struct emac_regs *regs, uint32_t *cfg_decode, int *is_q_cfgrd);

#endif

//------------------------------------------------------------------------------
// END OF FILE
//------------------------------------------------------------------------------

