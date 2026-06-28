/***********************************************************************
 * Copyright (C) 2014-2015 Cadence Design Systems
 * All rights reserved
 ***********************************************************************
 *
 * mac_diag diagnostic utility command for doing EMAC register and PHY
 * reads/writes from linux command line via the CDS-MAC reference driver
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 **********************************************************************/


#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <net/if.h>
#include "edd_ioctl.h"

/* struct to pass command function & data */
struct ifreq ifr;

uint32_t read_register(int skfd, uint32_t offset)
{
    struct emac_diag_d gd;

    gd.addr_offs = (uint32_t)offset;
    ifr.ifr_ifru.ifru_data = (void *)&gd;

    if (ioctl(skfd, CDSMAC_IOCTL_RD, &ifr) < 0)
    {
        perror("EMAC Register ioctl read");
    }
    else
    {
        printf("    Register value = 0x%08X\n", gd.reg_data);
    }

    return gd.reg_data;
}

void write_register(int skfd, uint32_t offset, uint32_t val)
{
    struct emac_diag_d gd;

    gd.addr_offs = (uint32_t)offset;
    gd.reg_data = val;
    ifr.ifr_ifru.ifru_data = (void *)&gd;

    if (ioctl(skfd, CDSMAC_IOCTL_WR, &ifr) < 0)
    {
        perror("EMAC Register ioctl write");
    }
    else
    {
    	printf("    Register written with 0x%08X\n", gd.reg_data);
    }
}


void dbg_dump(int skfd, uint32_t queue)
{
    struct emac_diag_d gd;

    gd.addr_offs = 0;
    gd.reg_data = queue;
    ifr.ifr_ifru.ifru_data = (void *)&gd;

    if (ioctl(skfd, CDSMAC_IOCTL_DBG_DUMP, &ifr) < 0)
    {
        perror("EMAC Debug dump queue");
    }
    else
    {
        printf("    Debug dump queue %u cmd sent\n", queue);
    }
}

void waitfor(int skfd, uint16_t offset, uint32_t mask, uint32_t value, uint16_t max_reads) {
  uint32_t data = 0, last_data = 0;
  uint16_t reads = 0;

  do {
    data = read_register(skfd, offset);
    if (data != last_data) {
      //printf("Read offset 0x%08X = 0x%08X (attempt %d)\n", offset, data, reads);
    }
    last_data = data;
    reads++;
  } while ((reads < max_reads) && ((data & mask) != value));

  if ((data & mask) != value) {
    printf("waitfor failed after %d reads from 0x%x: 0x%x & 0x%x != 0x%x\n",
           reads, offset, data, mask, value);
  }
}

/*
  EMAC register 0x34:
  [31]    write0 "Must be written with 0."
  [30]    write1 "Must be written to 1 for Clause 22 operation."
  [29:28] operation "Operation. 10 is read. 01 is write."
  [27:23] phy_address
  [22:18] register_address
  [17:16] write10 "Must be written with 10."
  [15:0]  phy_write_read_data

  MDIO standard registers

  0 : Control
  [15] Reset - write 1 to reset, self clearing
  [14] Loopback Enable
  [13] Speed Selection (LSB) see [6] below
  [12] Auto-Negotiation Enable
  [11] Power Down
  [10] Isolate (1=isolated)
  [9]  Restart Auto-Negotiation, self clearing
  [8]  Duplex Mode (1=full)
  [7]  Collision Test (1=enable COL signal test)
  [6]  Speed Selection (MSB) 11= Reserved
       {[6],[13]} decode as: 10= 1000 Mb/s
                             01= 100 Mb/s
                             00= 10 Mb/s
  [5]  Unidirectional enable, valid only if [12]=0 and [8]=1.
       1=Enable tx from MII regardless of whether the PHY has determined that
         a valid link has been established
       0=Enable transmit from MII only when the PHY has determined that a
         valid link has been established
  [4:0] Reserved

  1 : Status
  [15] 100BASE-T4 supported
  [14] 100BASE-X Full Duplex supported
  [13] 100BASE-X Half Duplex supported
  [12] 10 Mb/s Full Duplex supported
  [11] 10 Mb/s Half Duplex supported
  [10] 100BASE-T2 Full Duplex supported
  [9]  100BASE-T2 Half Duplex supported
  [8]  Extended Status information in Register 15 present
  [7]  Unidirectional ability (ability per Control[5])
  [6]  MF Preamble Suppression
  [5]  Auto-Negotiation Complete
  [4]  Remote Fault
  [3]  Auto-Negotiation Ability
  [2]  Link Status (1=up)
  [1]  Jabber Detect
  [0]  Extended Capability (0=basic)
*/
void read_mdio(int skfd, uint16_t phy_addr, uint16_t reg_addr) {
  uint16_t pa = phy_addr & 0x1f;
  uint16_t ra = reg_addr & 0x1f;
  uint16_t value;
  write_register(skfd, 0x0, read_register(skfd, 0x0) | 0x10); // [4] man_port_en
  write_register(skfd, 0x34, 0x60020000 + (pa << 23) + (ra << 18));
  waitfor(skfd, 0x8, 4, 4, 1000);
  value = read_register(skfd, 0x34) & 0xffff;
  printf("MDIO addr 0x%x reg 0x%x = 0x%x\n", pa, ra, value);
  if (ra == 0) {
    printf("Control: Lpbk%s Speed=%s AutoNeg%s PwdDn%s Isolate%s FullDpx%s ColTst%s UniDir%s\n",
           (value & 0x4000) ? "+" : "-",
           (value & 0x40) ? "1000" : (value & 0x2000) ? "100" : "10",
           (value & 0x1000) ? "+" : "-",
           (value & 0x800) ? "+" : "-",
           (value & 0x400) ? "+" : "-",
           (value & 0x100) ? "+" : "-",
           (value & 0x80) ? "+" : "-",
           (value & 0x20) ? "+" : "-");
  } else if (ra == 1) {
    printf("Status: 100T4%s 100Xf%s 100Xh%s 10f%s 10h%s 100T2f%s 100T2h%s ExtStat%s UniDirAble%s MFPS%s AutoNegCompl%s RemFault%s AutoNegAble%s LinkUp%s JabberDet%s ExtCap%s\n",
           (value & 0x8000) ? "+" : "-",
           (value & 0x4000) ? "+" : "-",
           (value & 0x2000) ? "+" : "-",
           (value & 0x1000) ? "+" : "-",
           (value & 0x800) ? "+" : "-",
           (value & 0x400) ? "+" : "-",
           (value & 0x200) ? "+" : "-",
           (value & 0x100) ? "+" : "-",
           (value & 0x80) ? "+" : "-",
           (value & 0x40) ? "+" : "-",
           (value & 0x20) ? "+" : "-",
           (value & 0x10) ? "+" : "-",
           (value & 0x8) ? "+" : "-",
           (value & 0x4) ? "+" : "-",
           (value & 0x2) ? "+" : "-",
           (value & 0x1) ? "+" : "-");
  }
}

void write_mdio(int skfd, uint16_t phy_addr, uint16_t reg_addr, uint16_t value) {
  uint16_t pa = phy_addr & 0x1f;
  uint16_t ra = reg_addr & 0x1f;
  write_register(skfd, 0x0, read_register(skfd, 0x0) | 0x10); // [4] man_port_en
  write_register(skfd, 0x34, 0x50020000 + (pa << 23) + (ra << 18) + value);
  waitfor(skfd, 0x8, 4, 4, 1000);
}

int main(int argc, char *argv[])
{
    int skfd, arg_err = 0;
    uint32_t offset, w_data;

    if (( skfd = socket( AF_INET, SOCK_DGRAM, 0 )) < 0)
    {
        printf("socket error\n");
        return 1;
    }

    if ((argc<4) || (strlen(argv[2])!=1))
        arg_err = 1;
    else
    {
        strncpy(ifr.ifr_name, argv[1], IFNAMSIZ);

        offset = (uint32_t)(strtol(argv[3], NULL, 16) & 0xFFFFFFFF);
        switch(argv[2][0])
        {
         case 'r':
            read_register(skfd, offset);
            break;
         case 'w':
            if (argc<5)
                arg_err = 1;
            else {
                w_data = strtol(argv[4], NULL, 16);
                write_register(skfd, offset, w_data);
            }
            break;
         case 'm':
            read_mdio(skfd, 7, offset);
            break;
         case 'b':
            if (argc<5)
                arg_err = 1;
            else {
                w_data = strtol(argv[4], NULL, 16);
                write_mdio(skfd, 7, offset, w_data);
            }
            break;
         case 'n':
            read_mdio(skfd, 1, offset);
            break;
         case 'v':
            if (argc<5)
                arg_err = 1;
            else {
                w_data = strtol(argv[4], NULL, 16);
                write_mdio(skfd, 1, offset, w_data);
            }
            break;
         case 'd':  /* debug dump */
            dbg_dump(skfd, offset);
            break;

         default:
            arg_err = 1;
            break;
        }
    }

    if (arg_err) {
        printf( "Usage: %s dev r|w|m|b|n|v|d offset [write_data]\n", argv[0]);
        return 1;
    }

    return 0;
}
