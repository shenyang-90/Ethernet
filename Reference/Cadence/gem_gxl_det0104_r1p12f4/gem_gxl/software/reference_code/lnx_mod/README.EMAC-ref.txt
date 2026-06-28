README.EMAC-ref.txt

Copyright (C)2014-2017 Cadence Design Systems
All Rights Reserved


Contents
========

1. Overview
2. System Requirements
3. Files Included
4. Build Notes
5. Device Tree
6. How to Load and Run
7. Runtime configuration
8. Diagnostic utility
9. 64-bit compilation
10. Ethtool Offloads configuration
11. Rx Flow filter configuration

1. Overview
-----------
The EMAC Reference Driver provides an operating system adaptation layer between
the Linux kernel and the EMAC Core driver.  The EMAC Reference Driver is reference
code, intended as an example of how to write an adaptation layer between the
EMAC Core Driver and the customer's host operating system.

Features from 1p09 release:
Unsupported by Linux Framework/Driver:
 - Configuring number of priority queues in runtime
 - Changing memory allocation
 - CRC Error reporting in DMA descriptors
 - Single Step PTP sync correction field
 - MII operation on the RGMII interface
Features suported:
 - Traffic Tx priority scheduling enhancements
 - EnST Enhancement for Scheduled Traffic (802.1Qbv)
 - 2.5G operation

2. System Requirements
----------------------
The reference driver has been built and tested against Linux kernel 3.0 in both
built-in and loadable module configurations.

Kernel config requirements: the kernel must be built with the following
CONFIG settings in order to support all features of the EMAC Linux driver.
Others may also be required, or will be automatically enabled by "make
ARCH=arm menuconfig" when enabling these settings.

    CONFIG_NET
    CONFIG_NETDEVICES
    CONFIG_PHYLIB
    CONFIG_NET_ETHERNET
    CONFIG_NETDEV_1000

The minimal configuration flags for PTP include:
    CONFIG_PPS
    CONFIG_PPS_CLIENT_KTIMER
    CONFIG_PPS_CLIENT_LDISC
    CONFIG_PTP_1588_CLOCK

The minimal configuration flags for HW queuing and shaping include:
    CONFIG_NET_SCHED
    CONFIG_NET_SCH_MULTIQ
    CONFIG_NET_SCH_MQPRIO
    CONFIG_NET_SCH_FIFO
    CONFIG_NET_CLS_ACT
    CONFIG_NET_ACT_SKBEDIT
    CONFIG_NET_CLS_U32


3. Files Included
-----------------

3.1 (Linux) reference code files

    cdn_errno.h
    cdn_stdint.h
    cps_v2_linux.c
    log.h
    cds_eth.c
    edd_ioctl.h

3.2 Core driver files

    cedi.h
    edd_int.h
    emac_regs.h
    emac_regs_macro.h
    edd.c
    edd_rx.c
    edd_tx.c

3.3 Driver Makefile

    (renamed from Makefile.mac_builtin or Makefile.mac_mod)

3.4 Example scripts

    mac_load.sh
    mac_load2.sh
    mac_unload.sh
    mac_unload2.sh

3.5 Diagnostic utility

    mac_diag.c


4. Build Notes
--------------
To add the driver source to a kernel tree, copy the files into a new directory
<kernel>/drivers/net/cdsmac/ and add a line to drivers/net/Makefile like:
	obj-y += cdsmac/

Alternately, copy the source files to an external directory. After building
the kernel, make again with the arguments "M=<driver source dir> modules".

The TSU timer is clocked by either pclk or by tsu_clk if gem_tsu_clk
is defined the gem_gxl_defs.v file. The ns_increment value in the
Linux reference driver should define used clock's period.
Additionally, TSU clock frequency (in Hz) can be provided to driver, using
module parameter "tsu_freq". Increment calculated from supplied frequency
parameter will override value of ns_increment.

5. Device Tree
--------------
Device register base address, IRQ number, and MAC address are loaded from a
Device Tree file at boot time.

The following is a snippet from a .dts file defining two EMAC devices:

/dts-v1/;
/ {
        <other device tree entries>

        amba: amba@0 {

                <other amba bus device entries>

                emac0: ethernet@fff30000 {
                        compatible = "cdns,mac";
                        reg = <0xFFF30000 0x2000>;
                        interrupts = <77 0>;
                        mac-address = [ 00 47 45 4D 30 30 ];
                };
                emac1: ethernet@fff32000 {
                        compatible = "cdns,mac";
                        reg = <0xFFF32000 0x2000>;
                        interrupts = <78 0>;
                        mac-address = [ 00 47 45 4D 30 31 ];
                };
        };
};

If a standard embedded bootloader is used, it may be possible
to have the bootloader substitute a flash-stored MAC address for
the one in the device tree.

6. How to Load and Run
----------------------
If built as a loadable module, the module can be loaded as usual
using insmod or modprobe. The module currently doesn't require
any arguments.

For example,
    > insmod /lib/modules/3.0.0/cds_mac.ko

If the module is installed in the /lib/modules/<kernel ver>/
directory, you can use modprobe to load with module without the
.ko prefix:
	> modprobe cds_mac

----------------------
Alternatively, from the lnx_mod/ directory you can use GNUmakefile
make targets to load & unload:

    > make clean
 - cleans the build from any previous objects

    > make
 - makes the driver as module cds_mac.ko

    > make modp
 - loads the module into the kernel. The driver will then appear
in an 'lsmod' listing as 'cds_mac', along with the ptp & pps_core drivers
loaded by cds_mac

    > make modpr
 - to unload the module

----------------------

To see if the module was installed successfully, enter lsmod:
	> lsmod
	cds_mac 77622 0 - Live 0xbf01a000

To enable debug output, use the following:
	> echo 8 > /proc/sys/kernel/printk

To open the driver, try:
	> ifconfig eth0 192.168.0.1
(presuming this is the first interface on this system -> eth0)


For further examples, please examine the shell scripts supplied
with the reference driver:
	mac_load.sh       Load and configure using legacy commands
	mac_load2.sh      Equivalent using iproute2 commands
	mac_unload.sh     Unload the driver module.
	mac_unload2.sh

Note that the load scripts use NAT configuration to allow the use
of two back-to-back devices installed on the same host.


7. Runtime configuration
------------------------
Most driver actions are non-proprietary, and are controlled by
the usual networking utilities.  For example, you can open and
close the driver via ifconfig or ip link commands.

An exception to this is configuring hardware traffic shaping.
If EMAC hardware device has two or more transmit queues, traffic shaping
algorithm(s) can be enabled, with following limitations:
 - 802.1Qav (Credit Based Shaping) can only be enabled on two highest queues.
 - 802.1Qbv (EnST) can only be enabled on two highest queues in hardware.
Because of lack of support from Linux framework, this configuration is done
manually, through sysfs.

For each queue <x>, there exist two files, called "queue_<x>_sched_type" and
"queue_<x>_sched_value". "queue_<x>_sched_type" is used for setting algorithm
type and can have following values:
 - 0: Fixed Priority (default)
 - 1: 802.1Qav (Credit Based Shaping, CBS)
 - 2: Deficit Weighted Round Robin (DWRR)
 - 3: Enhanced Transmission Selection (ETS)
After setting algorithm type, a value can be set (except for Fixed Priority),
using "queue_<x>_sched_value" file. Maximum values are:
100 for CBS and ETS, 255 for DWRR.
Higher value provides more bandwidth for given queue.

Also, for 8 highest hardware queues (if they are not disabled), there are files
for controlling EnST algorithm, which works independently from previous four.
Details about it can be found in design specification.
These files are:
 - "queue_<x>_enst_enable": 1 for enabled, 0 for disabled.
 - "queue_<x>_on_time": open window width, in bytes.
 - "queue_<x>_off_time": closed window width, in bytes.
 - "queue_<x>_start_time_ns": Start time for queue, nanoseconds part (max 999999999)
 - "queue_<x>_start_time_s": Start time for queue, whole seconds part (max 3)
Changes in these 5 files are not reflected immediately in registers. Instead,
all changes are done at once, by writing "1" to "enst_apply_settings".
Reading "enst_apply_settings" returns 1, if there are unapplied changes, 0 otherwise.
Writing 1 to "enst_read_settings" overrides values in those files by current values
in device's registers.

Since EnST relies on TSU (time Stamp Unit), there is a mean to read and,
in a limited way, control its value, through file "tsu_value".
Reading this file returns current value of TSU in format "seconds : nanoseconds".
Writing "1" to this file stops that timer and clears it (sets to "0 : 0")
writing "2" to this file starts the timer again.

Other commands use normal network tools.  For example, to change
MTU to 3000 you can enter:
	> ifconfig eth0 mtu 3000
or
	> ip link set dev eth0 mtu 3000

To assign default traffic to the highest-priority
transmit queue on a four-queue system, you can enter:
	tc qdisc add dev eth0 root handle 1: mqprio map 3 1 2 3


8. Diagnostic utility
------------------------

The mac_diag.c file provides some basic register read/write commands to
access the EMAC and/or a connected PHY, and can be made from the lnx_mod/
directory with

    > make macdiag

This builds as mac_diag, in the lnx_mod/ directory.
The syntax for mac_diag is as follows:

    > mac_diag <devname> r|w|m|b|n|v <register_offset_hex> [<data_to_write_hex>]

e.g. to read from revision register:

    > ./mac_diag eth1 r 0FC

or to write 0x00001240 to PCS control register (restart auto-negotiation):

    > ./mac_diag eth1 w 200 00001240


The m and b commands work like the r and w commands, except they address PHY
registers via MDIO, assuming that the PHY ID is set to 7.

The n and v commands work like the r and w commands, except they address PHY
registers vio MDIO, assuming that the PHY ID is set to 1.

For other PHY IDs, the source code for mac_diag.c needs to be modified.


A debug command "d" is available which will dump EMAC registers and Rx queue
descriptor listing, to the system log if DEBUG option is selected in Makefile.mac_mod:

    > ./mac_diag eth1 d 0

where 0 is the rx queue number.


9. 64-bit compilation
----------------------

To compile the linux driver for use with 64-bit DMA addressing, uncomment the
following line in the module makefile Makefile.mac_mod -

EXTRA_CFLAGS += -DCEDI_64B_COMPILE


10. Ethtool Offloads configuration
---------------------------------

The linux driver includes support for TCP Segmentation Offload (TSO),
UDP Fragmentation Offload (UFO), Receive Side Coalescing (RSC, referred to as
LRO in ethtool) and interrupt moderation features.

TSO and UFO
-----------

These features allow the stack to send down large frames which are packaged
into MSS-sized (or MFS for UFO) frames by the hardware.

To see the current offload settings use:

    > ethtool -k <dev>

The features are enabled by default with the inclusion of NETIF_F_TSO and
NETIF_F_UFO in the netdevice features field during the probe function
execution.

The support can be disabled/enabled on an active driver by the following
ethtool command:

    > ethtool -K <dev> tso off|on ufo off|on

where <dev> is the ethernet device, e.g. eth0
This command will usually require root privilege, e.g. sudo <cmd>

Note that the TSO and UFO offloads depend on Tx checksum (tx on) and scatter-
gather (sg on) features also being enabled.

RSC Offload
-----------

Receive side coalescing is a means of merging consecutive frames in a TCP
stream into larger frames for the stack to process.

This functionality is enabled by using a receive flow filter (see section
below) to define a stream by a 4-tuple combination of source and destination
IP addresses and ports.

In addition to defining a flow filter, this function must be enabled by the
ntuple offload.  To enable coalescing on any priority queue receiving a TCP
stream the LRO (Large Receive Offload) must also be enabled:

    > ethtool -K <dev> lro on

When using RSC with a standard TCP transfer, it is important not to enable it
before the three-way handshake (ie. tx SYN, rx SYN/ACK tx ACK) has completed,
otherwise the ACK tx can be coalesced as the start of a stream (following on
from the initial SYN frame)

Interrupt Moderation
--------------------

Interrupts can be reduced by two ways. In first way interrupts can be reduced 
by delaying the assertion of an interrupt by a fixed time period. In second way,
interrupts can be reduced by setting maximum number of packets to be
sent/received to assert an interrupt. This feature can be enabled/disabled by
the ethtool -C command, e.g.

    > ethtool -C eth1 rx-usecs 200 tx-usecs 100

specifies an interrupt-generation delay for the eth1 interface of 200us after
receiving and 100us after completing transmission.  The maximum delay
available is 204us.

    > ethtool -C eth1 rx-frames 20 tx-frames 10

specifies an interrupt-generation delay for the eth1 interface of 20 packets
to be received and 10 packets to be sent.


11. Rx Flow filter configuration
--------------------------------

The driver supports flow filtering by ethtool flow definition for TCP over
IPv4.  The fields supported are the four parameters required by RSC - source IP
address, destination IP address, source port and destination port, although not
all four are required to define a filter.

E.g. to define a flow filter for directing a stream to priority queue 1:

    > ethtool -U <dev> flow-type tcp4 src-ip 192.168.0.1 dst-ip 192.168.0.5
      src-port 11020 dst-port 5800 action 1 loc 0

where "action" means direct to queue 1, and "loc" is the filter location to
use.

The number of filter locations depends on the numbers of type2 screener
and compare registers in the EMAC.  Each filter requires 1 type2 screener
register and 3 type2 compare registers.

The RSC function also requires a type2 ethertype register, which is used to
match the ethertype field as IPv4 (0800).

To enable the flow filter you also need to enable the ntuple offload:

    > ethtool -K <dev> ntuple on


