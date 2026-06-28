#!/grid/common/bin/perl -w

#////////////////////////////////////////////////////////////////////////
#
# $Id: trans.pl,v 1.57 2014-11-12 16:23:27 arthurm Exp $
# Release : $Revision: 1.57 $
#
#            CADENCE                    Copyright (c) 2002
#            DESIGN                     Cadence Design Foundry, Inc.
#            FOUNDRY                    All rights reserved.
#
#
# Description
#
# perl program to translate ethernet MAC level 0 tests to
# verilog stimulus and checking files for each of the MAC's
# bus functional models.
#
# Author: Arthur Marris
#
#////////////////////////////////////////////////////////////////////////

# Packages containing the following functions:-
#use lib "../sim/stand_alone";
use FindBin qw($Bin); #Bin has path to trans.pl
use lib "$Bin";
use pcs     qw(&pcs &stream_encode &sprintfdec2bin &samoct);
#use strict;
#use diagnostics;
use English;
use Getopt::Long;

my $DESIGN = "gem_gxl";

my @DMAWR_RXDESCR_FH;
my @DMARD_RXDESCR_FH;
my @DMAWR_RXDATA_FH;
my @DMARD_TXDATA_FH;
my @DMARD_TXDESCR_FH;
my @DMAWR_TXDESCR_FH;

# assign some default values to various variables
$incompatible_test = 0;
$total_buffer_count = 0;
$total_buffer_countq1 = 0;
$total_buffer_countq2 = 0;
$total_buffer_countq3 = 0;
$total_buffer_countq4 = 0;
$total_buffer_countq5 = 0;
$total_buffer_countq6 = 0;
$total_buffer_countq7 = 0;
$total_buffer_countq8 = 0;
$total_buffer_countq9 = 0;
$total_buffer_countq10 = 0;
$total_buffer_countq11 = 0;
$total_buffer_countq12 = 0;
$total_buffer_countq13 = 0;
$total_buffer_countq14 = 0;
$total_buffer_countq15 = 0;
$eth_txd_index = 0;
$eth_rxd_index = 0;
$max_event = 0;
$stop = 0;
$ten_meg_bit = 0;
$ten_gig_mode = 0;
$axi_perf_test = 0;
$fourty_gig_mode = 0;
$fifo_loopback_mode = 0;
$wait_states = 4;
$fault_point = "";
$detect_point = "";
$bus_grant_delay = 4;
$fifo_latency = 2;
$fifo_under_delay = 2;
$fifo_status_delay = 0;
$fifo_over_delay = 0;
$randomize_hgrant = 0;
$randomize_hready = 0;
$fixed_latency_mode = 0;
$check_txlinerate = 0;
$mdio_index = 0;
$byte_index = 0;
# for pcs stuff
$rx_pcs_index = 0;
$tx_pcs_index = 0;
$repeatvar = 0;
$set_used = 0;
$set_used_cnt = 0;
$restart_type = 0;
$last_frame = 0;

my @cfg_tx_num_segments;


$tx_gen_int_in = 0;
$rx_gen_int_in = 1;
   my $resource_err      = 0;

$pcs_config_set = 0; # convert Configuration order set
$eth_frame_status = "complete"; # this indicates no part of frame is being processed
$pcs_debug = 0; # no debug info (pcs conversion transparent)
                # 1 - debug on - some pcs conversion info
                # 2 - debug on - full pcs conversion info
$pcs_err_field = 0;
$pcs_err_type = 0;
$pcs_err_position = 0;
$pcs_repl_position = 0;
$pcs_err_trunc = 0;
my $width32 = 0;
my $width64 = 1;
my $width128 = 0;

$rx_pcs_disparity = 0; # assume negative running disparity at the start;
$tx_pcs_disparity = 0; # assume negative running disparity at the start;

$tx_burst_mode = 0;    # initialize burst mode to 0 once in a test case
$rx_burst_mode = 0;    # same

$rx_pcs_odd_aligned = 0; # rx frame start from odd aligned group number
$tx_pcs_odd_aligned = 0; # tx frame start from odd aligned group number

# The following are used for automatic tx/rx frame and dma generation
my %address;  # Hash to hold the specific address
my $init_address  = "";  # Initial location pointer to by the dma read
$cur_rx_ptr     = "";  # current rx queue pointer
#$rx_q_ptr_index = 0;   # rx queue pointer index
$tx_pointer     = "";  # current tx queue pointer
#$tx_q_ptr_index = 0;   # tx queue pointer index
$tx_q_ptr_index_q0 = 0;
$tx_q_ptr_index_q1 = 0;
$tx_q_ptr_index_q2 = 0;
$tx_q_ptr_index_q3 = 0;
$tx_q_ptr_index_q4 = 0;
$tx_q_ptr_index_q5 = 0;
$tx_q_ptr_index_q6 = 0;
$tx_q_ptr_index_q7 = 0;
$tx_q_ptr_index_q8 = 0;
$tx_q_ptr_index_q9 = 0;
$tx_q_ptr_index_q10 = 0;
$tx_q_ptr_index_q11 = 0;
$tx_q_ptr_index_q12 = 0;
$tx_q_ptr_index_q13 = 0;
$tx_q_ptr_index_q14 = 0;
$tx_q_ptr_index_q15 = 0;
$tx_status      = 0;   # indicates whether tx status or pointer read
@tx_buffer_sizes = "";  # The array of buffer sizes for the frame
my $num_collisions = 0;
my $too_many_col = 0;

my $arready_min = 0;
my $arready_max = 0;
my $rvalid_min = 0;
my $rvalid_max = 0;
my $awready_min = 0;
my $awready_max = 0;
my $wready_min = 0;
my $wready_max = 0;
my $bvalid_min = 0;
my $bvalid_max = 0;

my $read_min = 0x00;
my $read_max = 0xff;
my $write_min = 0x00;
my $write_max = 0xff;
my $descr_min = 0x00;
my $descr_max = 0x07;
my $data_min  = 0x00;
my $data_max  = 0x07;
my $data_min_lock  = 0x00;
my $data_max_lock  = 0x07;
my $total_num_rx_frames =0;
my $total_num_tx_frames =0;
my $first_frame;
my $buffer_size = 128;
my $buffer_size_q1 = 128;
my $buffer_size_q2 = 128;
my $buffer_size_q3 = 128;
my $buffer_size_q4 = 128;
my $buffer_size_q5 = 128;
my $buffer_size_q6 = 128;
my $buffer_size_q7 = 128;
my $buffer_size_q8 = 128;
my $buffer_size_q9 = 128;
my $buffer_size_q10 = 128;
my $buffer_size_q11 = 128;
my $buffer_size_q12 = 128;
my $buffer_size_q13 = 128;
my $buffer_size_q14 = 128;
my $buffer_size_q15 = 128;
my @rx_q_pointer;
my $strip_fcs = 0;
my $strip_rtag = 0;
my $frer_6b_tag = 1;
my $en_rx_cutthru = 0;
my $rx_auto_discard_pkts = 0;
my $force_max_burst_rx = 0;
my $force_max_burst_tx = 0;
my $tx_csum_offload = 0;
my $ahb_burst_size = 1;
my $addr64 = 0;
my $ext_bd_tx = 0;
my $ext_bd_rx = 0;
my $ts_mode_tx = 0;
my $ts_mode_rx = 0;
my $tx_ext_bd_written = 0;
my $data_addr_upper_32 = 0;
my $descr_addr_upper_32 = 0;
my $data_check = 1;
my $includerxdma = 1;
my $i_think_rx_frame_is_dropped = 0;
my @drop_rx_frame_on_len_en;
my @drop_rx_frame_on_len;
my $rx_do_descr_acc = 1;
my $rx_data_start_add = "";
my $includerxd = 1;
my $tx_data_check = 1;
my $double_error_injection = 0;
my $single_error_injection = 0;
my $num_sram_errors_to_inject = 0;
my $tb_use_phy_model  = 0;
my $pcs_loopback = 0;
my $ext_loopback = 0;
my @tx_loopbacked_frame;
my $num_dma_queues = 1;
my $queue_to_use   = 0;
my $random_seed;
my $rx_queue_to_use   = 0;
my $rx_queue_to_use_t   = 0;
my $debug_print_frame = 0;
my @rx_pointer=0;
my $start_scale = 0;
my $num_32bit_accesses = 0;
my $enforce_data_width = 0;
my $auto_descriptor_swap = 0;
my $this_is_first_descr_wr = 0;
my $this_is_first_descr_rd = 0;
my $last_was_data_wr = 0;
my $last_was_data_rd = 0;
my $last_dma_rd_add = "00000000";
my $last_dma_wr_add = "00000000";
my $last_queue = 0;
my $lastupperadd = 0;
my $start_scale_pre = 0;
my $start_scale_post = 0;
my $test_catering_for_carrier_extension = 0;
my $descr_cnt = 0;

my $stacked_vlan_en=0;
my $stacked_vlan_tag=0;
my $vlan1_frame = "";
my $vlan1_field;
my @vlan1_field_array;
my @vlan1_type_array;
my $vlan2_frame = "";
my $vlan2_field = "";
my @vlan2_field_array;
my @vlan2_type_array;
my $frer_rtag_type = "f1c1";
my $frer_rtag_seqnum;
my $frer_rtag_seqnum_last = 0xffff;

my @type1_screener_reg;
my @type2_screener_reg;
my @type2_ethtype_reg = (0,0,0,0,0,0,0,0);
my @type2_compare0_reg;
my @type2_compare1_reg;
my @ipv4_tos_array;
my @ipv6_tc_array;
my @comp_field;
my $num_forced_pad_tx = 0;

# IPv4 variables ...
my $ipv4_frame  = 0;
my $ipv4_frame_local  = 0;
my $ipv4_ver  = 4;
my $ipv4_ihl  = 5; # Internet header length
my $ipv4_tos  = 0;
my $ipv4_len  = 0;
my $ipv4_id   = 0;
my $ipv4_frg  = 0;
my $ipv4_ttl  = 0;
my $ipv4_prt  = 0;
my $ipv4_csum = 0;
my $ipv4_sadd = 0;
my $ipv4_dadd = 0;
my $num_ipv4_options = 0;
my $bad_ip_csum;

# IPv6 variables ...
my $ipv6_frame  = 0;
my $ipv6_frame_local  = 0;
my $num_ipv6_hdrs = 0;
my $use_dest_hdrs = 1;
my $use_hop_hdrs = 1;
my $use_route_hdrs = 1;
my $use_frag_hdrs = 0;
my @ipv6_tc;

# UDP variables ...
my $udp_frame  = 0;
my $udp_frame_local  = 0;
my @udp_sport_array;
my @udp_dport_array;
my $bad_udp_csum;

# TCP variables ...
my $tcp_frame  = 0;
my $tcp_frame_local  = 0;
my $bad_tcp_csum;

# ICMP variables ...
my $icmp_frame  = 0;
my $icmp_frame_local  = 0;
my $txwrapbit = 0;
my $txwrapbit1st = 0;

my $tog_cnt_enable = 0;
my $auto_fault_checker = 0;
my $fault_sim_en = 0;
my $fault_sim = 0;
my $axi_test = 0;
my $extra_spec_adds_en = 0;

my $dont_care = "zzzzzzzz";
#my $dont_care = "56565656";

my $current_tx_pkt_num = 0;
my $tx_type_len_field;
my $tx_udp_dport;
my $tx_ipv4_tos;
my $tx_ipv6_tc;
my $tx_l3_hdr_index;
my $tx_l4_hdr_index;

my $rx_max_size_frame;
my @tx_max_size_frame;

my @tx_q_pointer;

my $args = "";    

my @pinsd = (0,0,0,0,
              0,0,0,0,
              0,0,0,0,
              0,0,0,0,
              0,0,0,0,0,0,0,0,0,
              0,0,0,0,
              0,0,0,
              0,0,0,0,
              0,0,0,0,
              0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,
              0,0,0,0,
              0,0,
              0,0,0,0,0,0,0,0,0,
              0,0,0,0,
              0,0,
              1,0,0);

my $gigabit = 0;
my $speed_mode = 0;

# NCR defaults ..
my $retry_test   = "random";
my $rxoffset     = 0;
my $pause_en     = "random";
my $unicast_hash = 0;
my $multicast_hash = 0;
my $speed        = "random";
my $jumbo        = 0;
my $copy_all     = "random";
my $databus      = "random";
my $duplex       = "random";
my $dont_copy_pause = 0;
my $length_err_discard = 0;
my $pcs_en       = 0;
my $sgmii_en     = 0;
my $rx_toe       = 0;
my $eam          = 0;
my $rx_jumbo_max_len_reg = 1500;

# Read command line (and previously written command file
&read_arguments( );

# check for existence of files directory
if (! -e "files") {
   print "Directory 'files' does not exist - so create it\n";
   mkdir ('files', 0777);
}

# open the testcase file and the various output files
open (TESTCASE,    $full_testcase_path);
open (TXDFILE,     ">files/tb_txd.data");            # stores transmitted ethernet frame
open (TXDFILE1,     ">files/tb_txd1.data");          # stores transmitted ethernet frame
open (TXDFILE2,     ">files/tb_txd2.data");          # stores transmitted ethernet frame
open (TXDFILE3,     ">files/tb_txd3.data");          # stores transmitted ethernet frame
open (TXDFILE4,     ">files/tb_txd4.data");          # stores transmitted ethernet frame
open (TXDFILE5,     ">files/tb_txd5.data");          # stores transmitted ethernet frame
open (TXDFILE6,     ">files/tb_txd6.data");          # stores transmitted ethernet frame
open (TXDFILE7,     ">files/tb_txd7.data");          # stores transmitted ethernet frame
open (TXDFILE8,     ">files/tb_txd8.data");          # stores transmitted ethernet frame
open (TXDFILE9,     ">files/tb_txd9.data");          # stores transmitted ethernet frame
open (TXDFILE10,     ">files/tb_txd10.data");          # stores transmitted ethernet frame
open (TXDFILE11,     ">files/tb_txd11.data");          # stores transmitted ethernet frame
open (TXDFILE12,     ">files/tb_txd12.data");          # stores transmitted ethernet frame
open (TXDFILE13,     ">files/tb_txd13.data");          # stores transmitted ethernet frame
open (TXDFILE14,     ">files/tb_txd14.data");          # stores transmitted ethernet frame
open (TXDFILE15,     ">files/tb_txd15.data");          # stores transmitted ethernet frame
open (RXDFILE,     ">files/tb_rxd.data");          # stores received ethernet frame
open (APBFILE,     ">files/tb_apb.data");          # stores ABP data
open (COMMENTFILE, ">files/tb_apb_comment.data");  # stores ABP comment
open (EVENTFILE,   ">files/tb_event.data");        # stores event triggerss
open (INITFILE,    ">files/tb_init.data");
open (AXI_LATENCY_FILE,    ">files/tb_axi_latency_file.data");
open (PINSDFILE,   ">files/tb_drive_pins.data");
open (PINSCFILE,   ">files/tb_check_pins.data");
open (FILTERDFILE, ">files/tb_drive_filter.data");
open (FILTERCFILE, ">files/tb_check_filter.data");
for($i=0; $i<16; $i++)
{
    $drop_rx_frame_on_len_en[$i] = 0;
    $drop_rx_frame_on_len[$i] = 0;
    $drop_rx_all_frames_en[$i] = 0;
    #localize the file glob, so FILE is unique to
    #    the inner loop.
    local *FILE;
    open(FILE, ">files/tb_dma_rd_rx_descr_q$i.data") || die;
    push(@DMARD_RXDESCR_FH, *FILE);
    local *FILE;
    open(FILE, ">files/tb_dma_wr_rx_descr_q$i.data") || die;
    push(@DMAWR_RXDESCR_FH, *FILE);
    local *FILE;
    open(FILE, ">files/tb_dma_wr_rx_data_q$i.data") || die;
    push(@DMAWR_RXDATA_FH, *FILE);

    local *FILE;
    open(FILE, ">files/tb_dma_rd_tx_data_q$i.data") || die;
    push(@DMARD_TXDATA_FH, *FILE);
    local *FILE;
    open(FILE, ">files/tb_dma_rd_tx_descr_q$i.data") || die;
    push(@DMARD_TXDESCR_FH, *FILE);
    local *FILE;
    open(FILE, ">files/tb_dma_wr_tx_descr_q$i.data") || die;
    push(@DMAWR_TXDESCR_FH, *FILE);
}
open (DMAHRDYFILE, ">files/tb_dma_hrdy.data");
open (FIFORDFILE,  ">files/tb_fifo_rd.data");
open (FIFOWRFILE,  ">files/tb_fifo_wr.data");
open (MDIOFILE,    ">files/tb_mdio.data");
open (RXPCSFILE,   ">files/tb_pcs_rx.data");          # stores rx PCS vectors
open (TXPCSFILE,   ">files/tb_pcs_tx.data");          # stores tx PCS vectors
open (BUFCNTFILE,  ">files/tb_buf_cntq0.data");         # Total Number of buffers for Q0
open (BUFCNTFILE1,  ">files/tb_buf_cntq1.data");      # Total Number of buffers for Q1
open (BUFCNTFILE2,  ">files/tb_buf_cntq2.data");      # Total Number of buffers for Q2
open (BUFCNTFILE3,  ">files/tb_buf_cntq3.data");      # Total Number of buffers for Q2
open (BUFCNTFILE4,  ">files/tb_buf_cntq4.data");      # Total Number of buffers for Q2
open (BUFCNTFILE5,  ">files/tb_buf_cntq5.data");      # Total Number of buffers for Q2
open (BUFCNTFILE6,  ">files/tb_buf_cntq6.data");      # Total Number of buffers for Q2
open (BUFCNTFILE7,  ">files/tb_buf_cntq7.data");      # Total Number of buffers for Q2
open (BUFCNTFILE8,  ">files/tb_buf_cntq8.data");      # Total Number of buffers for Q2
open (BUFCNTFILE9,  ">files/tb_buf_cntq9.data");      # Total Number of buffers for Q2
open (BUFCNTFILE10,  ">files/tb_buf_cntq10.data");      # Total Number of buffers for Q2
open (BUFCNTFILE11,  ">files/tb_buf_cntq11.data");      # Total Number of buffers for Q2
open (BUFCNTFILE12,  ">files/tb_buf_cntq12.data");      # Total Number of buffers for Q2
open (BUFCNTFILE13,  ">files/tb_buf_cntq13.data");      # Total Number of buffers for Q2
open (BUFCNTFILE14,  ">files/tb_buf_cntq14.data");      # Total Number of buffers for Q2
open (BUFCNTFILE15,  ">files/tb_buf_cntq15.data");      # Total Number of buffers for Q2


my $num_data_nibbles = 0;
my $datafilename = \$DMARD_TXDESCR_FH[0];
my $cur_frame_idx = 0;

if (! -f "$full_testcase_path") {
   print "** ERROR ** can't find any testcase at location $full_testcase_path\n";
   exit;
}

$temp2 = $full_testcase_path;
$temp = chop ($temp2);
$testcase_name = "";
while ($temp ne '/' and $temp ne '') {
   $testcase_name = $temp . $testcase_name;   # remove any directory reference
   $temp = chop ($temp2);
}


# Put some comments into the APB file
print APBFILE "// APB control stuff\n";
print APBFILE "// MSB gives queue ptr for determining which interrupt to trigger\n";
print APBFILE "// Next hex value is 1 if there is a comment to write out\n";
print APBFILE "// Next hex value has MSB = 1 for read and 0 for write \n";
print APBFILE "// remaining bits are:-\n";
print APBFILE "// 0  end-stop\n";
print APBFILE "// 1  wait for trigger\n";
print APBFILE "// 2  wait for interrupt\n";
print APBFILE "// 3  generate APB trigger\n";
print APBFILE "// 4  keep going\n";

printf COMMENTFILE "// Contains APB comments in ASCII format\n",;

print "Translating test case $testcase_name\n";


# control triggers are usually as follows
# 0  end-stop
# 1  wait for trigger
# 2  wait for interrupt
# 3  wait for APB trigger (or force trigger if APB)
# 4  keep going
# 5  use testbench to generate CRC
# 6  wait a gap after last transmission and then send another - for RXD
# 7  force collision - for TXD

# process the testcase line by line
while ($command = <TESTCASE>) {
   chop($command);             # remove carriage return
   $command =~ s/--.*//;       # ignore comments
   $command =~ tr/A-Z/a-z/;    # make all lower case
   #print "$command\n";

   my @requires;
   if ($command =~ /^\s*requires/) {
      # look for any arguments 
      my $tmp = 0;
      while ($command =~ /^\s*(requires\s+)(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))((\s+.*)||$)/) {
        $requires[$tmp] = $3;
        $tmp++;
        $requires[$tmp] = $5;
        $tmp++;
        $command = $1.$6;
      }
      $command = "";
      validate_test(\@requires);
    }

   if ($command =~ /^\s*init_q_ptr/) {
      my @spec_ptrs;
      # look for any arguments 
      $num_tx_queues = $cfg_num_dma_queues;
      $num_rx_queues = $cfg_num_dma_queues;
      while ($command =~ /^\s*(init_q_ptr\s+)-(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))?((\s+.*)||$)/) {
        $argval = $5;
        $arg = $3;
        $command = $1.$6;
        if ($arg eq "num_tx_queues") {if ($argval eq "take_from_cfg") {$num_tx_queues = $cfg_num_dma_queues;} else {$num_tx_queues = $argval;}}
        if ($arg eq "num_rx_queues") {if ($argval eq "take_from_cfg") {$num_rx_queues = $cfg_num_dma_queues;} else {$num_rx_queues = $argval;}}
        if ($arg =~ /tx_ptr_q(\d+)/) {$spec_ptrs[$1] = $argval;}
        if ($arg =~ /rx_ptr_q(\d+)/) {$spec_ptrs[$1+16] = $argval;}
      }
      $command = "";
      init_q_ptr($cfg_num_dma_queues,$num_tx_queues,$num_rx_queues,@spec_ptrs);
    }

   if ($command =~ /^\s*init_screener_type1/) {
      # look for any arguments 
      $num_type1_screeners = $cfg_num_type1_screeners;
      $num_rx_queues = $cfg_num_dma_queues;;
      while ($command =~ /^\s*(init_screener_type1\s+)-(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))?((\s+.*)||$)/) {
        if ($3 eq "num_type1_screeners") {if ($5 eq "take_from_cfg") {$num_type1_screeners = $cfg_num_type1_screeners;} else {$num_type1_screeners = $5;}}
        if ($3 eq "num_rx_queues") {if ($5 eq "take_from_cfg") {$num_rx_queues = $cfg_num_dma_queues;} else {$num_rx_queues = $5;}}
        $command = $1.$6;
      }
      $command = "";
      init_screener_type1($num_type1_screeners,$num_rx_queues);
    }

   if ($command =~ /^\s*init_dma/) {
      # look for any arguments 
      $min_buf_size = 64;
      $max_buf_size = 16384;
      $burst        = "random";
      $addr_bus     = "random";
      $ext_bd       = "random";
      while ($command =~ /^\s*(init_dma\s+)-(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))?((\s+.*)||$)/) {
        if ($3 eq "max_buf_size") {$max_buf_size = $5;}
        if ($3 eq "min_buf_size") {$min_buf_size = $5;}
        if ($3 eq "burst") {$burst = $5;}
        if ($3 eq "addr_bus") {if ($5 eq "take_from_cfg") {$addr_bus = $cfg_addrbus;} else {$addr_bus = $5;}}
        if ($3 eq "ext_bd") {$ext_bd = $5;}
        if ($3 eq "force_max_burst_tx") {$force_max_burst_tx = $5;}
        if ($3 eq "force_max_burst_rx") {$force_max_burst_rx = $5;}
        if ($3 eq "tx_csum_offload") {$tx_csum_offload = $5;}
        $command = $1.$6;
      }
      $command = "";
      init_dma($force_max_burst_tx,$force_max_burst_rx,$max_buf_size,$min_buf_size,$burst,$addr_bus,$ext_bd,$tx_csum_offload);
    }

   if ($command =~ /^\s*init_ncr/) {
      # look for any arguments 
      while ($command =~ /^\s*(init_ncr\s+)-(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))?((\s+.*)||$)/) {
        if ($3 eq "rx_buf_offset") {$rxoffset = $5;}
        if ($3 eq "retry_test") {$retry_test = $5;}
        if ($3 eq "pause_en") {$pause_en = $5;}
        if ($3 eq "unicast_hash") {$unicast_hash = $5;}
        if ($3 eq "multicast_hash") {$multicast_hash = $5;}
        if ($3 eq "dont_copy_pause") {$dont_copy_pause = $5;}
        if ($3 eq "length_err_discard") {$length_err_discard = $5;}
        if ($3 eq "eam") {$eam = $5;}
        if ($3 eq "duplex") {$duplex = $5;}
        if ($3 eq "speed") {$speed = $5;}
        if ($3 eq "jumbo") {$jumbo = $5;}
        if ($3 eq "copy_all") {$copy_all = $5;}
        if ($3 eq "pcs_en") {$pcs_en = $5;}
        if ($3 eq "sgmii_en") {$sgmii_en = $5;}
        if ($3 eq "rx_toe") {$rx_toe = $5;}
        if ($3 eq "databus") {if ($5 eq "take_from_cfg") {$databus = $cfg_dma_bus_width;} else {$databus = $5;}}
        $command = $1.$6;
      }
      $command = "";
      init_ncr();
    }

   if ($command =~ /^\s*enable_ints/) {
      # look for any arguments 
      $num_queues   = $cfg_num_dma_queues;;
      $vector       = sprintf "%08x",0;
      while ($command =~ /^\s*(enable_ints\s+)-(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))?((\s+.*)||$)/) {
        if ($3 eq "num_queues") {if ($5 eq "take_from_cfg") {$num_queues = $cfg_num_dma_queues;} else {$num_queues = $5;}}
        if ($3 eq "vector") {$vector = $5;}
        $command = $1.$6;
      }
      $command = "";
      enable_ints($num_queues,$vector);
    }

   if ($command =~ /^\s*disable_ints/) {
      # look for any arguments 
      $num_queues   = $cfg_num_dma_queues;;
      $vector       = sprintf "%08x",0;
      while ($command =~ /^\s*(disable_ints\s+)-(([a-zA-Z0-9_]+)(\s+([a-zA-Z0-9_]+)))?((\s+.*)||$)/) {
        if ($3 eq "num_queues") {if ($5 eq "take_from_cfg") {$num_queues = $cfg_num_dma_queues;} else {$num_queues = $5;}}
        if ($3 eq "vector") {$vector = $5;}
        $command = $1.$6;
      }
      $command = "";
      disable_ints($num_queues,$vector);
    }



  while ($command =~ /^\s*set_random_seed\s+([0-9]+)\s*.*$/s) {
    $random_seed = $1;
    srand($random_seed);
    $command =~ s/^\s*set_random_seed\s+([0-9]+)\s*.*$//s;
    print "Random Seed was overwritten in this test to $random_seed\n";
  }

  while ($command =~ /^\s*set_auto_fault_checker\s+([0-9]+)\s*.*$/s) {
    $auto_fault_checker = $1;
    $command =~ s/^\s*set_auto_fault_checker\s+([0-9]+)\s*.*$//s;
    print "Enabling auto-fault checker for IFSS testing ..\n";
  }

  while ($command =~ /^\s*set_double_error_injection\s+([0-9]+)\s*.*$/s) {
    $double_error_injection = $1;
    $command =~ s/^\s*set_double_error_injection\s+([0-9]+)\s*.*$//s;
    print "Double error injection to sram ..\n";
  }

  while ($command =~ /^\s*set_single_error_injection\s+([0-9]+)\s*.*$/s) {
    $single_error_injection = $1;
    $command =~ s/^\s*set_single_error_injection\s+([0-9]+)\s*.*$//s;
    print "Single error injection to sram ..\n";
  }
  
  while ($command =~ /^\s*set_num_sram_errors_to_inject\s+([0-9]+)\s*.*$/s) {
    $num_sram_errors_to_inject = $1;
    $command =~ s/^\s*set_num_sram_errors_to_inject\s+([0-9]+)\s*.*$//s;
    print "Number of SRAM errors to inject in this test set to $num_sram_errors_to_inject\n";
  }

  while ($command =~ /^\s*set_tx_data_check\s+([0-9]+)\s*.*$/s) {
    $tx_data_check = $1;
    $command =~ s/^\s*set_tx_data_check\s+([0-9]+)\s*.*$//s;
    print "Setting tx_data_check to $tx_data_check ..\n";
  }

  while ($command =~ /^\s*set_fault_sim\s+([0-9]+)\s*.*$/s) {
    $fault_sim_en = 1;
    $fault_sim = $1;
    $command =~ s/^\s*set_fault_sim\s+([0-9]+)\s*.*$//s;
    print "This test is running fault_sim $fault_sim ..\n";
  }

  while ($command =~ /^\s*set_tb_use_phy_model\s+([0-9]+)\s*.*$/s) {
    $tb_use_phy_model = $1;
    $command =~ s/^\s*set_tb_use_phy_model\s+([0-9]+)\s*.*$//s;
    print "This test is running tb_use_phy_model $tb_use_phy_model ..\n";
  }


#-----------------------------------------------------------
   # pcs_rxd command
   # control triggers
   # 0  end-stop - this one will automatically be appended
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   # 5  keep going and enforce trigger
   #    (xx must be inserted prior to the octet on which trigger should occur
   # 6  wait a gap after last transmission and then send another
   # 7  wait for trigger from pcs_tx transactor

   if ($command =~ /^pcs_rxd/) { #if command starts with pcs_rxd

      $temp = chop ($command);                       # temp <= last character from command
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n frame and comments

   # check for error insertion arguments; must be in the following format:
   # txxfx<pxxx> where x is hex digit and <>indicates optional error argument
   # t is for type of error:
   #   0  - no error (same as ommitting the error arguments)
   #   1  - replace with the codegroup corresp for opposite disparity
   #   2  - replace with invalid codegroup (not existing)
   #   3  - corrupt single bit
   #   4  - finish on even codegroup for non bursting packets
   #   5  - reduce IFG
   #   6  - remove codegroup
   #   7  - replace with D21.5
   #   8  - replace with D2.2
   #   9  - replace with D5.6
   #  10  - replace with D16.2
   #  11  - replace with K28.5
   #  12  - replace with K23.7 (/R/)
   #  13  - replace with K27.7 (/S/)
   #  14  - replace with K29.7 (/T/)
   #  15  - replace with K30.7 (/V/)
   #  16  - random type of error
   # f is for packet field to be corrupted:
   #   1  - preamble; 2  - SFD; 3  - DATA; 4  - rest (i.e. EPD, /R/, IFG etc).
   # p is for the exact position within F: if number is specified, then this is the location within
   #   the field specified by F; if this argument is ommitted, then random location within the F is
   #   corrupted.
      if ($temp ne 'g' and ($command =~ /gggggggg/ or $command =~/gg/)) {
         $pcs_err_args = "";
         while ($temp ne ' ') {
            $pcs_err_args = $pcs_err_args . $temp;
            $temp = chop ($command);
         } # now pcs_err_args is <xxxp>xfxxt
         $temp = chop ($command);         # temp was ' ' before this command

         #process the error args
         chop ($pcs_err_args);   #remove the t
         $other_temp = chop ($pcs_err_args);
         $pcs_err_type = '';
         while ($other_temp ne 'f') {
            $pcs_err_type = $pcs_err_type . $other_temp;
            $other_temp = chop($pcs_err_args);
         } # now pcs_err_type is xx in the correct order (b/n t and f)
           # and other_temp is 'f'

         $pcs_err_field = chop ($pcs_err_args);   # now pcs_err_field is the x b/n f and p (if p present)

         # process P arg if present
         $other_temp = chop ($pcs_err_args);
         if ($other_temp eq 'p') {
            $other_temp = chop ($pcs_err_args);   # remove the p & get the LS digit of replacement position
            $pcs_err_position = 2;     # specific replacement position
            while ($other_temp ne '') {
               $pcs_repl_position = $pcs_repl_position . $other_temp;
               $other_temp = chop($pcs_err_args);
            }
         } else {
            $pcs_err_position = 1;     # random replacement position
            $pcs_repl_position = 0;
         }
      } else {
         $pcs_err_type = 0;
         $pcs_err_field = 0;
         $pcs_err_position = 0;     # random replacement position
         $pcs_repl_position = 0;
      }


      # now the last char of the frame itself is in temp
      if ($temp eq 'g') {$last_frame_part='1'} # set flag this is last pcs_rxd command
      else {$last_frame_part='0'}              # composing the current frame

   # process the ethernet frame part of the command to build a whole frame
   #-----------------
      # separate the frame_part from the command
      $reversed_frame_part = '';
      while ($temp ne ' ' and $temp ne '') {
         $reversed_frame_part = $reversed_frame_part . $temp; # last char goes first here
         $temp = chop ($command);                             # get new char
      } # now reversed_frame_part contains the part of frame within the current command
        # but in reverse order

      # build a whole frame out of several commands containing parts of frames
      if ($eth_frame_status eq "complete") {
         $eth_frame = "";               # clear eth_frame as it is a start of new frame
      }
      $other_temp = chop ($reversed_frame_part);    # get last char
      while ($other_temp ne '') {
         $eth_frame = $eth_frame . $other_temp;     # append to the end of eth_frame
         $other_temp = chop ($reversed_frame_part); # get last char
      }  # now eth_frame contains one more part of the frame in correct order

      # if the last frame part has just been appended => change frame status to complete
      if ($last_frame_part eq '1') {
         $eth_frame_status = "complete";
      }

   # process control field to derive trigger info and beginning of a new frame
   #-----------------
      # $command contains pcs_rxd(trigger) and gaps between this and the
      # frame which already has been processed
      # $temp contains a blank here
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks

      if ($temp eq ')') {             # if there is trigger event this must be in ()
         $temp = chop ($command);     # if there is trigger event => this is the first
         $eth_frame_status = "partial";   # part of a new frame

      # only if trigger other than "keep going" do evaluate the trigger itself!
         if ($temp eq 'x') {
            $rx_carrier_ext = 1;
            $rx_burst_mode = 0;
            $temp = chop ($command); # now it becomes "-"
            $temp = chop ($command); # now get next control
         }
         elsif ($temp eq 'r') {
            if ($rx_burst_mode eq 0) {
               $rx_carrier_ext = 1;        # needed only for 1st
            }
            else {
               $rx_carrier_ext = 0;      # frame in a burst
               $control = '4';               # during burst, the gap is filled with /R/ by the script
            }                                # so tb must continue to read the vectors
            $rx_burst_mode = 1;
            $temp = chop ($command); # now it becomes "-"
            $temp = chop ($command); # now get next control
         }
         else {
            $rx_carrier_ext = 0;
            $rx_burst_mode = 0;
         }

      # detect trigger event only if it is not a burst frame or it is the first frame in a burst
       if ($temp ne '(') {
         if ($rx_burst_mode == 0 or $rx_burst_mode == 1 and $rx_carrier_ext == 1) {
            if ($temp eq 't') {
               $control = "2";
               $comment = "  // wait for interrupt";
            } elsif ($temp eq 'b') {
               $control = "3";
               $comment = "  // wait for APB trigger";
            } elsif ($temp eq 'p') {
               $control = "6";
               $comment = "  // wait gap time";
            } elsif ($temp eq 's') {
               $control = "7";
               $comment = "  // wait for pulse from pcs_tx time";
            } else {
               $control = "1";
               $comment = "  // wait for trig"; # cycle count event
               $out3 = "";
               if (($command.$temp) =~ /\((scale (\d+))/) {
                  $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
                  $max_event_pre = $2;
               } elsif (($command.$temp) =~ /\((\d+)/) { 
                  $out3 = $1;
                  $max_event_pre = $out3;
               }
               if ($events{$out3}) {
                  $events{$out3} = 32+$events{$out3};
               } else {
                  $events{$out3} = 32;
               }
               if ($out3 >$max_event) {
                  $max_event = $out3;
               }
            }
         }
        }
      }

   # When the whole frame is received, do the crc, 10bit encoding and form the packet
      print "\nFrame: $eth_frame" if ($pcs_debug);
      if ($eth_frame_status eq "complete") {

         # @ this point extract if any xx indicating trigger enforcement and get its position
         if ($eth_frame =~ /xx/g) {
            $trigger_position = (pos($eth_frame))/2;
            $eth_frame =~ s/xx//;         # remove the enforce trigger flag from the frame
         } else {
            $trigger_position = 0;
         }

         ($rx_pcs_packet,$rx_pcs_disparity,$rx_pcs_odd_aligned) =
                          pcs($eth_frame,$rx_pcs_disparity,             # frame and input disparity
                              $rx_burst_mode,$rx_carrier_ext,           # burst condition
                              $rx_pcs_odd_aligned,                      # starting byte alignment
                              $pcs_config_set,                          # configuration ordered set
                              $pcs_err_type,$pcs_err_field,             # error condition to be implied
                              $pcs_err_position,$pcs_repl_position,     # corrupted byte number within field
                              $pcs_err_trunc,                           # truncate rest of frame after error
                              $last_config_set,                         # last autoneg. config set
                              $pcs_debug);                              # debug mode

      # now have to split the packet in multiple vectors
      # the first vector within a packet must be prepend by control field
      # according to the trigger for the frame
      # consequtive vectors must be prepend by "keep going"
      # use the present concept - one 10bit codegroup per vector
      # create an array of 10bit groups incrementing an index after each assignment
      # the index shold not be changed in any other part of the script so the array will
      # contain all the frames in the end and these will be written @ once to the file

         $new_frame = '1';
         $position_cnt = 1;   # this counts the codegroups, to determine where to put ctrl field 5
         while ($rx_pcs_packet ne '') {
            $rx_pcs_packet =~ s/.{3}//;   # pop first 10bit code-group from the packet
            if ($new_frame eq '1') {
               $rx_pcs_vector[($rx_pcs_index)] = $control . $& . $comment; # start of frame trigger
               $new_frame = '0';
            } elsif ($position_cnt == $trigger_position) {
               $rx_pcs_vector[($rx_pcs_index)] = '5' . $& . $comment;      # enforce trigger while keep going
            } else {
               $rx_pcs_vector[($rx_pcs_index)] = '4' . $& . $comment;      # keep going trigger
            }
            $rx_pcs_index = $rx_pcs_index + 1;
            $position_cnt = $position_cnt + 1;
         }
      }
   }
   # end pcs_rxd command
#-----------------------------------------------------------


#-----------------------------------------------------------
   # pcs_an_rx command (autonegotiation)
   # control triggers
   # 0  end-stop - this one will automatically be appended
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   #6   wait for gap time
   #7   wait for trigger from tb_pcs_tx
   if ($command =~ /^pcs_an_rx/) {   # if command starts with pcs_an_rx
                                     # command should look like that:
                                     # pcs_an_rx c1ddddc2dddd <8r>
                                     # c1/c2 must be substituted with corresponding ordered sets
                                     # dddd is 16bit configuration data
                                     # 8r is optional to denote the number of times these ordered sets
                                     # to be transmitted (between 0 and 9!)

      $temp = chop ($command);                       # temp <= last character from command
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n frame and comments

      # now the last char of the frame itself is in temp
      $cfg_set_repetitions = 0;
      if ($temp eq 'r') {           # check if the set must be repeated
         $cfg_set_repetitions = chop ($command);   # now cfg_set_repetitions has the number
                                                   # of times the set must be repeated
         $temp = chop ($command);                  # temp <= last character from command
      }

      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n repetitions number and config sets

      # now derive the config sets; the last 'd' is in temp now
      #-----------------
      $reversed_frame_part = "";
      while ($temp ne ' ') {  # process the configuration sequence of ordered sets

      #process one /c/ group which is e.g. c1dddd
         $i = 1;
         for ($i=1; $i<5; $i++) {
            $reversed_frame_part = $reversed_frame_part . $temp;
            $temp = chop ($command);
         }    # now reversed_frame_part contains the 16bit config data of one more /C/ orderred set
              # end temp contains the type of /C/ identificatior (i.e. 1 or 2)
         if ($temp eq '1') {
            $reversed_frame_part = $reversed_frame_part . "5bcb";   # append reversed k285,d21.5 - bc,b5
         } else {   # assume it is '2'
            $reversed_frame_part = $reversed_frame_part . "24cb";   # append reversed k285,d2.2 - bc,42
         }
         $temp = chop ($command);   # now temp is 'c'
         $temp = chop ($command);   # now temp is another 'd' or space
      } # when out of the while loop, reversed frame contains all the 8bit groups to be encoded for
        # the particular configuration sequence depicted on the current command line
        # temp must be space now

      #multiply the configuration sequence by the number of repetitions required
         if ($cfg_set_repetitions != 0) {
            $i = 1;
            $other_temp = $reversed_frame_part;
            for ($i=1; $i<$cfg_set_repetitions; $i++) {
               $reversed_frame_part = $reversed_frame_part . $other_temp;
         }
      }

      # now revert the frame back to normal order
      $temp = chop ($reversed_frame_part);
      $cfg_frame = '';
      while ($temp ne '') {
         $cfg_frame = $cfg_frame . $temp;     # append to the end of cfg_frame
         $temp = chop ($reversed_frame_part); # get last char
      }  # now cfg_frame contains one more part of the frame in correct order
         # temp is now ''


      # now proceed with the triggers to form the control field
      #-----------------
      $temp = chop ($command);
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n first 'c' and triggers or command

      $last_config_set = 0;           # assume this command is not the last in the config sequence
      if ($temp eq ')') {             # if there is trigger event this must be in ()
         $temp = chop ($command);     # if there is trigger event => this is the first part of a sequence

      # only if trigger other than "keep going" do evaluate the trigger itself!

        # first check if this is the last sequence of /C/ orderred sets for autonegotiation
         if ($temp eq 'l') {          # if command is e.g. pcs_an_rx (apbl) c1ddddc2dddd
            $last_config_set = 1;     # set flag to notify packetizer to bring ending disparity to negative
            $temp = chop ($command);  # then check actual trigger in front of the 'l'
         }
        # now evaluate the actual trigger event for the current sequence of /C/ orderred sets
         if ($temp eq 't') {
            $control = "2";
            $comment = "  // wait for interrupt";
         } elsif ($temp eq 'b') {
            $control = "3";
            $comment = "  // wait for APB trigger";
         } elsif ($temp eq 'p') {
            $control = "6";
            $comment = "  // wait gap time";
         } elsif ($temp eq 'x') {
            $control = "7";
            $comment = "  // wait for pulse from pcs_tx";
         } elsif ($temp eq '(') {
            $control = "4";
            $comment = "  // No trigger, keep going";
         } else {
            $control = "1";
            $comment = "  // wait for trig"; # cycle count event
            $out3 = "";
            if (($command.$temp) =~ /\((scale (\d+))/) {
               $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
               $max_event_pre = $2;
            } elsif (($command.$temp) =~ /\((\d+)/) { 
               $out3 = $1;
               $max_event_pre = $out3;
            }
            if ($events{$out3}) {
               $events{$out3} = 32+$events{$out3};
            } else {
               $events{$out3} = 32;
            }
            if ($out3 >$max_event) {
               $max_event = $out3;
            }
         }

      } else {
         $control = '4';              # keep going
      }

      # form the config packet by doing 10bit encoding and adding /I1/ @ end if necessary
      ($rx_pcs_packet,$rx_pcs_disparity,$rx_pcs_odd_aligned) =
                       pcs($cfg_frame,$rx_pcs_disparity,             # frame and input disparity
                           0,0,                  # burst condition
                           0,                    # starting byte alignment
                           1,                    # configuration ordered set
                           0,0,                  # error condition to be implied
                           0,0,0,                # corrupted byte number within field
                           $last_config_set,     # last configuration set for auton negotiation sequence
                           $pcs_debug);          # debug mode

      # now form an array of test vectors (one ctrl.rx_group per line/element) for write in data file later
      $new_packet = '1';
      while ($rx_pcs_packet ne '') {
         $rx_pcs_packet =~ s/.{3}//;    #pop first 10bit code_group from the packet
         if ($new_packet eq '1') {
            $rx_pcs_vector[($rx_pcs_index)] = $control . $&;   # this is the very first vector with
                                                               # particular trigger event
            $new_packet = '0';
         } else {
            $rx_pcs_vector[($rx_pcs_index)] = '4' . $&;        # any consecutive tx_group is prepend by
                                                               # "keep going" trigger
         }
         $rx_pcs_index = $rx_pcs_index + 1;
      }
   }
   # end pcs_an_rx command
#-----------------------------------------------------------

#-----------------------------------------------------------
   # pcs_an_err_rx command (auto-negotiation)
   # control triggers
   # 0  end-stop - this one will automatically be appended
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   # 6  wait for gap time
   # 7  wait for pulse from pcs_tx

   if ($command =~ /^pcs_an_err_rx/) {  # if command starts with pcs_an_err_rx
                                     # command should look like that:
                                     # pcs_an_err_rx <(trigger)> cdd(d) <cdd(d)>
                                     # where c indicates a code group and should
                                     # be substituted with either (o) for an
                                     # ordinary code group or (c) for a special
                                     # code group
                                     # <> indicates optional
                                     # dd is octet value encoded as special (s) or ordinary data (o) codegroup
                                     # (d) is the running disparity value of the code group
                                     # and should be substituted with either a (p) for positive
                                     # disparity or (n) for negative disparity or do not specify
                                     # disparity at all
      $temp = chop ($command);                       # temp <= last character from command
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n frame and comments

      # now derive the octets and their flags in a separate variable
      #-----------------

      # restore the last char in the command, which is currently in temp
      $command = $command . $temp;
      if ($command =~ /\)\s{1,}s/){
        $command =~ s/ s.*//;   # strip off anything after the first s group
        $octet_stream = $&;     # assign the actual match to this variable and process it
      } elsif ($command =~ /x\s{1,}s/){
        $command =~ s/ s.*//;   # strip off anything after the first s group
        $octet_stream = $&;     # assign the actual match to this variable and process it
      }
      else {
        $command =~ s/ o.*//;   # strip off anything after the first o group
                              # !!! the ' ' before 'o' is to avoid matching with s from the command name
        $octet_stream = $&;     # assign the actual match to this variable and process it
      }


      ($encoded_stream,$rx_pcs_disparity) = stream_encode ($octet_stream,$rx_pcs_disparity,$pcs_debug);

      # $command now has the cmd name and triggers + one space
      # process the triggers for the command
      $temp = chop ($command);
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks after triggers (if any)
      if ($temp eq ')') {             # if there is trigger event this must be in ()
         $temp = chop ($command);     #

      # only if trigger other than "keep going" do evaluate the trigger itself!

         if ($temp eq 't') {
            $control = "2";
            $comment = "  // wait for interrupt";
         } elsif ($temp eq 'b') {
            $control = "3";
            $comment = "  // wait for APB trigger";
         } elsif ($temp eq 'p') {
            $control = "6";
            $comment = "  // wait gap time";
         } elsif ($temp eq 'x') {
            $control = "7";
            $comment = "  // wait for pulse from pcs_tx";
         } else {
            $control = "1";
            $comment = "  // wait for trig"; # cycle count event
            $out3 = "";
            if (($command.$temp) =~ /\((scale (\d+))/) {
               $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
               $max_event_pre = $2;
            } elsif (($command.$temp) =~ /\((\d+)/) { 
               $out3 = $1;
               $max_event_pre = $out3;
            }
            if ($events{$out3}) {
               $events{$out3} = 32+$events{$out3};
            } else {
               $events{$out3} = 32;
            }
            if ($out3 >$max_event) {
               $max_event = $out3;
            }
         }

      } else {
         $control = '4';              # keep going
      }

      # now form an array of test vectors (one ctrl.rx_group per line/element) for write in data file later
      $new_packet = '1';
      while ($encoded_stream ne '') {
         $encoded_stream =~ s/.{3}//;    #pop first 10bit code_group from the packet
         if ($new_packet eq '1') {
            $rx_pcs_vector[($rx_pcs_index)] = $control . $&;   # this is the very first vector with
                                                               # particular trigger event
            $new_packet = '0';
         } else {
            $rx_pcs_vector[($rx_pcs_index)] = '4' . $&;        # any consecutive tx_group is prepend by
                                                               # "keep going" trigger
         }
         $rx_pcs_index = $rx_pcs_index + 1;
      }
   }
   # end pcs_synch_rx command
#-----------------------------------------------------------

#-----------------------------------------------------------
   # pcs_synch_rx command (synchronization)
   # control triggers
   # 0  end-stop - this one will automatically be appended
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going

   if ($command =~ /^pcs_synch_rx/) {   # if command starts with pcs_synch_rx
                                     # command should look like that:
                                     # pcs_synch_rx <(trigger)> sdd <sdd> <odd>
                                     # !!!always start with sgroup!!!
                                     # <> indicates optional
                                     # dd is octet value encoded as special (s) or ordinary data (o) codegroup
                                     # always start with s group and don't finish with sbc
                                     # arbitrary order and number of s and o groups

      $temp = chop ($command);                       # temp <= last character from command
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n frame and comments

      # now derive the octets and their flags in a separate variable
      #-----------------

      # restore the last char in the command, which is currently in temp
      $command = $command . $temp;
      $command =~ s/ s.*//;   # strip off anything after the first s group
                              # !!! the ' ' before 's' is to avoid matching with s from the command name
      $octet_stream = $&;     # assign the actual match to this variable and process it

      ($encoded_stream,$rx_pcs_disparity) = stream_encode ($octet_stream,$rx_pcs_disparity,$pcs_debug);

      # $command now has the cmd name and triggers + one space
      # process the triggers for the command

      $temp = chop ($command);
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks after triggers (if any)

      if ($temp eq ')') {             # if there is trigger event this must be in ()
         $temp = chop ($command);     #

      # only if trigger other than "keep going" do evaluate the trigger itself!

         if ($temp eq 't') {
            $control = "2";
            $comment = "  // wait for interrupt";
         } elsif ($temp eq 'b') {
            $control = "3";
            $comment = "  // wait for APB trigger";
         } elsif ($temp eq 'p') {
            $control = "6";
            $comment = "  // wait gap time";
         } else {
            $control = "1";
            $comment = "  // wait for trig"; # cycle count event
            $out3 = "";
            if (($command.$temp) =~ /\((scale (\d+))/) {
               $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
               $max_event_pre = $2;
            } elsif (($command.$temp) =~ /\((\d+)/) { 
               $out3 = $1;
               $max_event_pre = $out3;
            }
            if ($events{$out3}) {
               $events{$out3} = 32+$events{$out3};
            } else {
               $events{$out3} = 32;
            }
            if ($out3 >$max_event) {
               $max_event = $out3;
            }
         }

      } else {
         $control = '4';              # keep going
      }

      # now form an array of test vectors (one ctrl.rx_group per line/element) for write in data file later
      $new_packet = '1';
      while ($encoded_stream ne '') {
         $encoded_stream =~ s/.{3}//;    #pop first 10bit code_group from the packet
         if ($new_packet eq '1') {
            $rx_pcs_vector[($rx_pcs_index)] = $control . $&;   # this is the very first vector with
                                                               # particular trigger event
            $new_packet = '0';
         } else {
            $rx_pcs_vector[($rx_pcs_index)] = '4' . $&;        # any consecutive tx_group is prepend by
                                                               # "keep going" trigger
         }
         $rx_pcs_index = $rx_pcs_index + 1;
      }
   }
   # end pcs_synch_rx command
#-----------------------------------------------------------


#-----------------------------------------------------------
   # pcs_an_tx command (autonegotiation)
   # control triggers
   # [0] Keep Going - automatically appended (Set to zero after last pcs_an_tx command read from test case)
   # [1] Wait for Start of Packet - s
   # [2] Auto Negotiation - automatically appended
   # [3] Trigger generated from tb_pcs_tx to tb_pcs_rx - trx
   # [4] Wait for apb command interrupt - apb
   # [5] Wait for interrupt pulse - int
   # [6] PCS software reset - re

   if ($command =~ /^pcs_an_tx/) {   # if command starts with pcs_an_tx
                                     # command should look like this:
                                     # pcs_an_tx(<trigger>)  dddd
                                     # trigger is the 4 possible triggers outlined above - OPTIONAL FIELD
                                     # dddd is 16bit configuration data- Configuration Register [7-0],[15-8]

      $temp = chop ($command);                       # temp <= last character from command
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n frame and comments

       $reversed_frame_part = "";
      for ($i=1; $i<5; $i++) {
         $reversed_frame_part = $reversed_frame_part . $temp;
         $temp = chop ($command);
      }    # now reversed_frame_part contains the 16bit config data

      # now revert the Config_Reg back to normal order
      $temp = chop ($reversed_frame_part);
      $cfg_register = '';
      while ($temp ne '') {
         $cfg_register = $cfg_register . $temp;     # append to the end of cfg_register
         $temp = chop ($reversed_frame_part); # get last char
      }  # now cfg_register contains the config reg values in the correct order
         # temp is now ''

      # now proceed with the triggers to form the control field
      #-----------------
      $temp = chop ($command);
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks first 'c' and triggers or command

        #assign defaults
           $pcs_an_tx_control = 0;
           $pcs_an_tx_control += 1; #keep going bit [0] is always set high
           $pcs_an_tx_control += 4; #auto-negotiation bit [2] is always set high for this command

      if ($temp eq ')') {

         # loop while still in control/trigger list
         while ($temp ne '(') {
            $temp = chop ($command);
            #wait for start of packet
            if ($temp eq 's') {
               $pcs_an_tx_control += 2;
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)};
            #trigger generated from tb_pcs_tx to tb_pcs_rx
            } elsif ($temp eq 'x') {
               $pcs_an_tx_control += 8;
               $temp = chop ($command);
               $temp = chop ($command);
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)};
            #trigger generated from interrput pulse
            } elsif ($temp eq 't') {
               $pcs_an_tx_control += 32;
               $temp = chop ($command);
               $temp = chop ($command);
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)};
            #trigger generated from apb command
            } elsif ($temp eq 'b') {
               $pcs_an_tx_control += 16;
               $temp = chop ($command);
               $temp = chop ($command);
               $temp = chop ($command);
              while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)};
            #trigger generated from PCS software reset
            } elsif ($temp eq 'e') {
               $pcs_an_tx_control += 64;
               $temp = chop ($command);
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)};
            } else {
               print "** ERROR ** Invalid trigger for pcs_an_tx command\n";
               exit;
            }
         }
      }
      $pcs_an_tx_control_hex = sprintf "%02x",$pcs_an_tx_control;
      $tx_pcs_vector[($tx_pcs_index)] = $pcs_an_tx_control_hex . $cfg_register;
      $tx_pcs_index = $tx_pcs_index + 1;
   }
   # end pcs_an_tx command
#-----------------------------------------------------------


#-----------------------------------------------------------
   # pcs_tx command
   # control triggers
   # [0] Keep Going - automatically appended (Set to zero after last pcs_tx command read from test case)
   # [1] Wait for Start of Packet - s
   # [2] Auto Negotiation - always set to zero for this command
   # [3] Trigger generated from tb_pcs_tx to tb_pcs_rx - only used in data field to create a trigger (use 'xx')
   # [4] Wait for apb command interrupt - apb  (NOT CURRENTLY IMPLEMENTED)
   # [5] Wait for interrupt pulse - int (NOT CURRENTLY IMPLEMENTED)

   if ($command =~ /^pcs_txd/) { #if command starts with pcs_txd
      $temp = chop ($command);                       # temp <= last character from command
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks b/n frame and comments


   # check for error insertion arguments; must be in the following format:
   # txxfx<pxxx> where x is hex digit and <>indicates optional error argument
   # t is for type of error:
   #   0  - no error (same as ommitting the error arguments)
   #   1  - replace with the codegroup corresp for opposite disparity
   #   2  - replace with invalid codegroup (not existing)
   #   3  - corrupt single bit
   #   4  - finish on even codegroup for non bursting packets
   #   5  - reduce IFG
   #   6  - remove codegroup
   #   7  - replace with D21.5
   #   8  - replace with D2.2
   #   9  - replace with D5.6
   #  10  - replace with D16.2
   #  11  - replace with K28.5
   #  12  - replace with K23.7 (/R/)
   #  13  - replace with K27.7 (/S/)
   #  14  - replace with K29.7 (/T/)
   #  15  - replace with K30.7 (/V/)
   #  16  - random type of error
   # f is for packet field to be corrupted:
   #   1  - preamble; 2  - SFD; 3  - DATA; 4  - rest (i.e. EPD, /R/, IFG etc).
   # p is for the exact position within F: if number is specified, then this is the location within
   #   the field specified by F; if this argument is ommitted, then random location within the F is
   #   corrupted.
      if ($temp ne 'g' and $command =~ /gggggggg/) {
         $pcs_err_args = "";
         while ($temp ne ' ') {
            $pcs_err_args = $pcs_err_args . $temp;
            $temp = chop ($command);
         } # now pcs_err_args is <xxxp>xfxxt
         $temp = chop ($command);         # temp was ' ' before this command

         #process the error args
         chop ($pcs_err_args);   #remove the t
         $other_temp = chop ($pcs_err_args);
         $pcs_err_type = '';
         while ($other_temp ne 'f') {
            $pcs_err_type = $pcs_err_type . $other_temp;
            $other_temp = chop($pcs_err_args);
         } # now pcs_err_type is xx in the correct order (b/n t and f)
           # and other_temp is 'f'

         $pcs_err_field = chop ($pcs_err_args);   # now pcs_err_field is the x b/n f and p (if p present)

         # process P arg if present
         $other_temp = chop ($pcs_err_args);
         if ($other_temp eq 'p') {
            $other_temp = chop ($pcs_err_args);   # remove the p & get the LS digit of replacement position
            $pcs_err_position = 2;     # specific replacement position
            while (($other_temp ne '') and ($other_temp ne 't')) {
               $pcs_repl_position = $pcs_repl_position . $other_temp;
               $other_temp = chop($pcs_err_args);
            }
         } else {
            $pcs_err_position = 1;     # random replacement position
            $pcs_repl_position = 0;
         }

         # process t(runcate) arg if present
         if ($other_temp eq 't') {
            #$other_temp = chop ($pcs_err_args);   # remove the t & get the LS digit of replacement position
            $pcs_err_trunc = 1;
         } else {
            $pcs_err_trunc = 0;
         }
      } else {
         $pcs_err_type = 0;
         $pcs_err_field = 0;
         $pcs_err_position = 0;     # random replacement position
         $pcs_repl_position = 0;
         $pcs_err_trunc = 0;
      }




      # now the last char of the frame itself is in temp
      if (($temp eq 'g') or ($temp eq 'v') or ($temp eq 'j')) {$last_frame_part='1'} # set flag this is last pcs_txd command
      else {$last_frame_part='0'}              # composing the current frame

   # process the ethernet frame part of the command to build a whole frame
   #-----------------
      # separate the frame_part from the command
      $reversed_frame_part = "";
      while ($temp ne ' ' and $temp ne '') {
         $reversed_frame_part = $reversed_frame_part . $temp; # last char goes first here
         $temp = chop ($command);                             # get new char
      } # now reversed_frame_part contains the part of frame within the current command
        # but in reverse order

      # build a whole frame out of several commands containing parts of frames
      if ($eth_frame_status eq "complete") {
         $eth_frame = '';               # clear pcs_frame as it is a start of new frame
      }
      $other_temp = chop ($reversed_frame_part);    # get last char
      while ($other_temp ne '') {
         $eth_frame = $eth_frame . $other_temp;     # append to the end of pcs_frame
         $other_temp = chop ($reversed_frame_part); # get last char
      }  # now eth_frame contains one more part of the frame in correct order


      # if the last frame part has just been appended => change frame status to complete
      if ($last_frame_part eq '1') {$eth_frame_status = "complete"}

   # process control field to derive trigger info and beginning of a new frame
   #-----------------
      # $command contains pcs_txd(trigger) and gaps between this and the
      # frame which already has been processed
      # $temp contains a blank here
      while ($temp eq ' ') {$temp = chop ($command)} # remove blanks
      #assign defaults
      $trigger_pcs_tx = 0;
      $trigger_pcs_tx += 1; #keep going bit [0] is always set high

      if ($temp eq ')') {                 # if there is trigger event this must be in ()
         $temp = chop ($command);         # if there is trigger event => this is the first
         $eth_frame_status = "partial";   # part of a new frame

      # only if trigger other than "keep going" do evaluate the trigger itself!
         if ($temp eq 'x') {
            $tx_carrier_ext = 1;
            $tx_burst_mode = 0;
            $temp = chop ($command);      # now temp is "_"
            $temp = chop ($command);      # now it is the next control symbol
         }
         elsif ($temp eq 'r') {
            if ($tx_burst_mode eq 0) {
               $tx_carrier_ext = 1;       # needed only for 1st
               $tx_burst_mode = 1;
            }
            else {
               $tx_carrier_ext = 0;       # frame in a burst
               $tx_burst_mode = 1;
            }                             # so tb must continue to read the vectors
            $tx_burst_mode = 1;
            $temp = chop ($command);      # now temp is "_"
            $temp = chop ($command);      # now it is the next control symbol
         }
         else {
            $tx_carrier_ext = 0;
            $tx_burst_mode = 0;
         }

      # detect trigger event only if it is not a burst frame or it is the first frame in a burst
         if ($tx_burst_mode eq 0 or $tx_burst_mode eq 1 and $tx_carrier_ext eq 1) {
            if ($temp eq 's') {
               $trigger_pcs_tx += 2;
            } elsif ($temp eq 'l') {
              $trigger_pcs_tx += 0;
            } elsif ($tx_burst_mode eq 1) {
              $trigger_pcs_tx += 0;
            } else {
               print "** ERROR ** Invalid trigger for pcs_txd command\n";
               exit;
            }
         }
         $trigger_pcs_tx_hex = sprintf "%02x",$trigger_pcs_tx;
      }

   # do the crc, 10bit encoding and form the packet
      print "\nFrame: $eth_frame" if ($pcs_debug);
      if ($eth_frame_status eq "complete") {

         # @ this point extract if any T indicating trigger enforcement and get its position
         if ($eth_frame =~ /xx/g) {
            $trigger_position = (pos($eth_frame))/2;
            $eth_frame =~ s/xx//;         # remove the enforce trigger flag from the frame
         } else {
            $trigger_position = 0;
         }
         print "\ntrigpos: $trigger_position" if ($pcs_debug);

         # remove JAM flag from frame
         if ($eth_frame =~ /j/g) {$eth_frame =~ s/j//;}          # remove JAM flag from frame


         if ($tx_carrier_ext ne 0 and $tx_carrier_ext ne 1) {
               print "\n\n***************\n\n********** ERROR ERROR ERROR ERROR ERROR ERROR ********** missing trigger for pcs_txd command\n\n try pcs_txd(s)  555555555555d5\n\n***************\n\n\n";
               exit;
            }

         ($tx_pcs_packet,$tx_pcs_disparity,$tx_pcs_odd_aligned) =
                          pcs($eth_frame,$tx_pcs_disparity,             # frame and input disparity
                              $tx_burst_mode,$tx_carrier_ext,           # burst condition
                              $tx_pcs_odd_aligned,                      # starting byte alignment
                              $pcs_config_set,                          # configuration ordered set
                              $pcs_err_type,$pcs_err_field,             # error condition to be implied
                              $pcs_err_position,$pcs_repl_position,     # corrupted byte number within field
                              $pcs_err_trunc,                           # truncate rest of frame after error
                              $last_config_set,                         # last autoneg. config set
                              $pcs_debug);                              # debug mode

         print "\ntx_frame: $tx_pcs_packet" if ($pcs_debug);

   # now have to split the packet in multiple vectors
   # the first vector within a packet must be prepend by control field
   # according to the trigger for the frame
   # consequtive vectors must be prepend by "keep going"
   # use the present concept - one 10bit codegroup per vector
   # create an array of 10bit groups incrementing an index after each assignment
   # the index shold not be changed in any other part of the script so the array will
   # contain all the frames in the end and these will be written @ once to the file

         $new_frame = '1';
         $position_cnt = 1;   # this counts the codegroups, to determine where to put ctrl field 5
         while ($tx_pcs_packet ne '') {
            $tx_pcs_packet =~ s/.{3}//;   # pop first 10bit code-group from the packet
            if ($new_frame eq '1') {
                $tx_pcs_vector[($tx_pcs_index)] = $trigger_pcs_tx_hex . 0 .$&; # start of frame trigger+ 1st group
               $new_frame = '0';
            } elsif ($position_cnt == $trigger_position) {
               $trigger_pcs_tx = 9; # Need bits [0] Keep going and trigger from tb_pcs_tx to tb_pcs_rx set
               $trigger_pcs_tx_hex = sprintf "%02x",$trigger_pcs_tx;
               $tx_pcs_vector[($tx_pcs_index)] = $trigger_pcs_tx_hex . 0 . $&;      # enforce trigger while keep going
            } else {
               $trigger_pcs_tx = 1; # Need bit [0] Keep going
               $trigger_pcs_tx_hex = sprintf "%02x",$trigger_pcs_tx;
               $tx_pcs_vector[($tx_pcs_index)] = $trigger_pcs_tx_hex . 0 . $&;      # keep going trigger + the rest code groups
            }
               $tx_pcs_index = $tx_pcs_index + 1;
               $position_cnt = $position_cnt + 1;
         }
      }
   }
   # end pcs_txd command
#-----------------------------------------------------------



   # ***************************************************************************
   # ENHANCED TX FRAME VERSION
   # ***************************************************************************
   if ($command =~ /^tx_frame\s+(\d+)(\s+([a-zA-Z0-9_]+))?/) {
      my $num_frames = $1;
      my $speed_scale = 0;
      if (defined ($3)) {
      if ($3 eq "speed_scale") {
        if ($speed_mode == 1) {$num_frames = $num_frames/5;}
        if ($speed_mode == 0) {$num_frames = $num_frames/20;}
        if ($speed_mode != 2) { print "scaling number of TX frames down to $num_frames due to speed mode ($speed_mode)\n"; }
      }}
      read_tx_frame ($num_frames);
   }

   # txd stuff
   # control triggers
   # 0  end-stop
   # 1  wait for tx_en
   # 2  expecting as part of a burst
   # 4  keep going
   # 5  use testbench to generate CRC
   # 7  force collision - for TXD
   # 8  force timed collision - for TXD
   # 9  expect a fragment
   # b  estimate
   if ($command =~ /^txd/) {
    $slot_time = "0000";
    $control = "4";
    $comment = " // carry on";
    # if we add an estargument, we allow the tb to estimate the data. Bottom byte is ignored
    # only works when no brackets on txd line
    if ($command =~ /^txd\s+(est\s+)/) {
      $command =~ s/$1//g;
      $control = "b";
      $comment = "  // estimating - only [31:8] needs to match";
    }
    # If we add a fragment argument, the TB will just check for the presence of a fragment of any size on txd (no data checking)
    if ($command =~ /^txd\s+fragment/) {
      $command = "";
      $control = "9";
      $comment = "  // expect a fragment of any size (no data checking)..";
      $eth_txd[$eth_txd_index] = $control . "000000" . $comment;  # load up $eth_txd in correct order
      $eth_txd_index = $eth_txd_index + 1;
    } else {  
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $eth_txd_temp = "S";  # mark end of string
      while ($temp ne ' ' and $temp ne '') {
         $eth_txd_temp = $eth_txd_temp . $temp;   # reverse order of txd
         $temp = chop ($command);
      }
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      if ($temp eq ')') {
         #decode command
         $control = "4";
         $comment = "";
         $slot_time = "0000";

         while ($temp ne '(' and $temp ne '') {
            $temp = chop ($command);

            if ($temp eq 'x') {
               $comment = "  // forcing timed collision";
               $temp = chop ($command);
               $control = "8";
               #get slot time number
               $slot_time_temp = "";
               while ($temp ne '(' and $temp ne '') {
                  $slot_time_temp = $temp . $slot_time_temp;
                  $temp = chop ($command);
               }
               $slot_time = sprintf "%04x",$slot_time_temp;  # get hex value
            }
            elsif ($temp eq 'r') {
               $comment = "  // expecting burst";
               $temp = chop ($command);
               $control = "2";
               if ($temp eq 'x') {
                  $comment = "  // forcing timed collision and expecting burst";
                  $temp = chop ($command);
                  $control = "a";
                  #get slot time number
                  $slot_time_temp = "";
                  while ($temp ne '(' and $temp ne '') {
                     $slot_time_temp = $temp . $slot_time_temp;
                     $temp = chop ($command);
                  }
                  $slot_time = sprintf "%04x",$slot_time_temp;  # get hex value
               }
            }
         }
      }
      $temp = chop ($eth_txd_temp);
      while ($temp ne 'S') {
         $temp2 =$temp;
         if ($temp2 eq 'x') {
            $temp2 = chop ($eth_txd_temp);
            $control = "7";
            $comment = "  // forcing collision";
            }
         $temp = chop ($eth_txd_temp);
         if ($temp eq 'x') {
            $temp = chop ($eth_txd_temp);
            $control = "7";
            $comment = "  // forcing collision";
            }
         if ($temp ne 'S') {
            if ($temp2 eq 'g' or $temp eq 'g') {
               if ($temp2 eq 'g' and $temp eq 'g') {
                  $temp2 = '0';
                  $temp  = '0';
                  $control = "5";
                  $comment = "   // use testbench to generate CRC";
               } else {
                  print "** ERROR ** must have an integral number of bytes for TXD on each line\n";
                  exit;
               }
            }
            $eth_txd[$eth_txd_index] = $control . $slot_time . $temp2 . $temp . $comment;  # load up $eth_txd in correct order
            $eth_txd_index = $eth_txd_index + 1;
            $temp = chop ($eth_txd_temp);
            if ($control ne '5') {
               $control = "4";
               $comment = "";
            }
         } else {
            print "** ERROR ** must have an integral number of bytes for TXD on each line\n";
            exit;
        }
      }
    }
   }




   # rxd stuff
   # control triggers
   # 0  end-stop
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   # 5  use testbench to generate CRC
   # 6  wait a gap after last transmission and then send another
   # 7  force rx_er in low nibble
   # 8  force rx_er in high nibble
   # 9  nibble dribble
   # a  nibble dribble with rx_er high
   #
   # gigabit extension
   # 0  no additional change
   # 1  carrier extend (default)
   # 2  burst data
   # 3  carrier extension specified by user
   # 4  carrier extension specified by user: burst mode

   # ***************************************************************************
   # ENHANCED RX FRAME VERSION
   # ***************************************************************************
   if ($command =~ /^rx_frame/) {
      read_rx_frame ();
   }

   # ***************************************************************************
   # STANDARD RX FRAME VERSION
   # ***************************************************************************
   if ($command =~ /^rxd/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $eth_rxd_temp = "S";  # mark end of string
      while ($temp ne ' ' and $temp ne '') {
         $eth_rxd_temp = $eth_rxd_temp . $temp;   # reverse order of rxd
         $temp = chop ($command);
      }

      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks

      # If  next character is something in brackets then we've found a control/trigger
      # Each separate control/trigger command will be separated by an '_'.
      if ($temp eq ')') {

         #assign defaults
         $control = "4";
         $comment = "";
         $gigabit_control = 0;
         $user_def_carrier_extend = 0;
         $user_def_ext_err = 0;
         
         # loop while still in control/trigger list
         while ($temp ne '(') {

            $temp = chop ($command); # get next character

            #detect gigabit carrier extension or burst mode
            if ($temp eq 'x') {
               $gigabit_control += 1;
               $comment = $comment."  // carrier extend";
               while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)}; # get next control
            } elsif ($temp eq 'r') {
               $gigabit_control += 2;
               $comment = $comment."  // burst mode";
               while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)}; # get next control
            } elsif ($temp eq 'u') {
               $gigabit_control += 4;
               $user_def_carrier_extend = "";
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {
                 $user_def_carrier_extend = $temp.$user_def_carrier_extend;
                 $temp = chop ($command);
               }
               $comment = $comment."  // carrier extension specified";
            } elsif ($temp eq 'v') {
               $gigabit_control += 8;
               $user_def_carrier_extend = "";
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {
                 $user_def_carrier_extend = $temp.$user_def_carrier_extend;
                 $temp = chop ($command);
               }
               $comment = $comment."  // carrier extension specified: burst mode";
            } elsif ($temp eq 'y') {
               $gigabit_control += 16;
               $user_def_ext_err = "";
               $temp = chop ($command);
               while ($temp ne '_' and $temp ne '(') {
                 $user_def_ext_err = $temp.$user_def_ext_err;
                 $temp = chop ($command);
               }
               $comment = $comment."  // carrier extension error";

            #detect trigger
            } else { 
              if ($temp eq 't') {
                 $control = "2";
                 $comment = $comment."  // wait for interrupt";
                 while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)}; # get next control
              } elsif ($temp eq 'b') {
                 $control = "3";
                 $comment = $comment."  // wait for APB trigger";
                 while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)}; # get next control
              } elsif ($temp eq 'p') {
                 $control = "6";
                 $comment = $comment."  // wait gap time";
                 while ($temp ne '_' and $temp ne '(') {$temp = chop ($command)}; # get next control
              } else {
                 $control = "1";
                 $comment = $comment."  // wait for trig";
                 $out3 = "";
                 if (($command.$temp) =~ /\((scale (\d+))/) {
                    $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
                    $max_event_pre = $2;
                 } elsif (($command.$temp) =~ /\((\d+)/) { 
                   $out3 = $1;
                   $max_event_pre = $out3;
                 }
                 if ($events{$out3}) {
                    $events{$out3} = 1+$events{$out3};
                 } else {
                    $events{$out3} = 1;
                 }
                 if ($out3 > $max_event) {
                    $max_event = $out3;
                 }
                 $temp = "(";
              }
            }
            if ($gigabit_control != 0) {$test_catering_for_carrier_extension = 1;}
         }
         # Automatically add carrier extension if we are running a common test and gigabit half duplex is detected
         if ($speed eq "1g" && $duplex eq "half" && $test_catering_for_carrier_extension == 0) {$gigabit_control += 1; $comment = $comment." + carrier extend";}
              

      } else {
         $control = "4";
         $comment = "";
         $gigabit_control = 0;
         $user_def_carrier_extend = 0;
         $user_def_ext_err = 0;
      }

      # convert counts to hex string for file I/O
      $gigabit_control_hex = sprintf "%02x",$gigabit_control;
      $gigabit_carrier_extend = sprintf "%03x",$user_def_carrier_extend;
      $gigabit_ext_err = sprintf "%03x",$user_def_ext_err;

      $temp = chop ($eth_rxd_temp); # get next data
      while ($temp ne 'S') {
         $temp2 =$temp;
         if ($temp2 eq 'x') {
            $temp2 = chop ($eth_rxd_temp);
            $control = "7";
            $comment = $comment."  // forcing rx_er";
            }
         $temp = chop ($eth_rxd_temp);
         if ($temp eq 'x') {
            $temp = chop ($eth_rxd_temp);
            $control = "8";
            $comment = $comment."  // forcing rx_er";
            }
         if ($temp ne 'S') {
            if ($temp2 eq 'g' or $temp eq 'g') {
               if ($temp2 eq 'g' and $temp eq 'g') {
                  $temp2 = '0';
                  $temp  = '0';
                  $control = "5";
                  $comment = $comment."   // use testbench to generate CRC";
            } elsif ($temp2 eq 'g' and $temp eq '_') {
               $temp2 = '0';
               $temp  = '0';
               $control = "8";
               $comment = "   // use testbench to generate CRC with bad terminate";
            } elsif ($temp2 eq '_' and $temp eq 'g') {
               $temp2 = '0';
               $temp  = '0';
               $control = "8";
               $comment = "   // use testbench to generate CRC with bad terminate";
               } else {
                  print "** ERROR ** must have an integral number of bytes for CRC generation\n";
                  exit;
               }
            }
            $eth_rxd[$eth_rxd_index] = $gigabit_ext_err . $gigabit_carrier_extend . $gigabit_control_hex . $control . $temp2 . $temp . $comment;  # load up $eth_rxd in correct order
            $eth_rxd_index = $eth_rxd_index + 1;
            $temp = chop ($eth_rxd_temp);
            if ($control ne '5') {
               $control = "4";
               $comment = "";
               $gigabit_control = 0;
               $user_def_carrier_extend = 0;
               $user_def_ext_err = 0;
            }
         } else {
            print "Inserting nibble dribble as there is not an intregal number of rxd bytes on a line\n";
            if ($control eq '7' or $control eq '8') {
               $control = "a";
            } else {
               $control = "9";
            }
            $comment = $comment."   // nibble dribble";
            $eth_rxd[$eth_rxd_index] = $gigabit_ext_err . $gigabit_carrier_extend . $gigabit_control_hex . $control . $temp2 . '0' . $comment;  # load up $eth_rxd in correct order
            $eth_rxd_index = $eth_rxd_index + 1;
        }
      }
   }

  # ASsume at this point there are no more rx frames or tx frames
  # This of course means you need to be careful in the testcase that you have the rx frames and tx frames
  # together with no other commands inbetween
  # There will be an interrupt for every frame.  However, on the last one
  # there will be an additional interrupt with used bit set
  while ($total_num_tx_frames != 0) {
    if ($total_num_tx_frames == 1) { # Last Frame
      # Read Used bit read to stop the transmitter from reading anything else ...
      for (my $queue_cnt=($num_dma_queues-1);$queue_cnt>=0;$queue_cnt--) {
        if    ($queue_cnt == 0) {$tx_pointer = hex ($tx_q_pointer[0]) + $tx_q_ptr_index_q0;}
        elsif ($queue_cnt == 1) {$tx_pointer = hex ($tx_q_pointer[1]) + $tx_q_ptr_index_q1;}
        elsif ($queue_cnt == 2) {$tx_pointer = hex ($tx_q_pointer[2]) + $tx_q_ptr_index_q2;}
        elsif ($queue_cnt == 3) {$tx_pointer = hex ($tx_q_pointer[3]) + $tx_q_ptr_index_q3;}
        elsif ($queue_cnt == 4) {$tx_pointer = hex ($tx_q_pointer[4]) + $tx_q_ptr_index_q4;}
        elsif ($queue_cnt == 5) {$tx_pointer = hex ($tx_q_pointer[5]) + $tx_q_ptr_index_q5;}
        elsif ($queue_cnt == 6) {$tx_pointer = hex ($tx_q_pointer[6]) + $tx_q_ptr_index_q6;}
        elsif ($queue_cnt == 7) {$tx_pointer = hex ($tx_q_pointer[7]) + $tx_q_ptr_index_q7;}
        elsif ($queue_cnt == 8) {$tx_pointer = hex ($tx_q_pointer[8]) + $tx_q_ptr_index_q8;}
        elsif ($queue_cnt == 9) {$tx_pointer = hex ($tx_q_pointer[9]) + $tx_q_ptr_index_q9;}
        elsif ($queue_cnt == 10) {$tx_pointer = hex ($tx_q_pointer[10]) + $tx_q_ptr_index_q10;}
        elsif ($queue_cnt == 11) {$tx_pointer = hex ($tx_q_pointer[11]) + $tx_q_ptr_index_q11;}
        elsif ($queue_cnt == 12) {$tx_pointer = hex ($tx_q_pointer[12]) + $tx_q_ptr_index_q12;}
        elsif ($queue_cnt == 13) {$tx_pointer = hex ($tx_q_pointer[13]) + $tx_q_ptr_index_q13;}
        elsif ($queue_cnt == 14) {$tx_pointer = hex ($tx_q_pointer[14]) + $tx_q_ptr_index_q14;}
        elsif ($queue_cnt == 15) {$tx_pointer = hex ($tx_q_pointer[15]) + $tx_q_ptr_index_q15;}

        if ($axi_test) {
          $datafilename = \$DMARD_TXDESCR_FH[$queue_cnt];
        } else {
          $datafilename = \$DMARD_TXDESCR_FH[0];
        }
        # Set the used bit - dont do this if we are already setting the used bit as part of the testing.
        if ($set_used_cnt == 0) {
          $control = 8;
          if ($width32 == 1) {
            printf $datafilename "$control%08x%08x80000000\n", $descr_addr_upper_32,$tx_pointer+4;
            $control = 0;
          }
          printf $datafilename "$control%08x%08x%08x\n",$descr_addr_upper_32, $tx_pointer, int(rand(2**32));
          $control = 0;
          if ($width32 == 0) {
            printf $datafilename "0%08x%08x80000000\n",$descr_addr_upper_32, $tx_pointer+4;
          }
          if ($addr64) {
            $data_addr_upper_32 = int(rand(2**32));
            printf $datafilename "0%08x%08x%08x\n",$descr_addr_upper_32, $tx_pointer+8, $data_addr_upper_32;
            if ($width32 == 0) {
              printf $datafilename "0%08x%08x%08x\n",$descr_addr_upper_32, $tx_pointer+12, int(rand(2**32));
            }
          }
        }
      }

      # If we are generating interrupts, then last interrupt should be here
      # Unfortunately, there are actually 2 interrupts here, one for TX complete
      # and the other for used bit read - we dont know if they will come
      # together or will be separate ...
##      if ($tx_gen_int_in == 1) {
##        print APBFILE "0a02400000088   // Packet transmitted & Used bit read Interrupt\n";
##        print APBFILE "0402400000088   // Write to clear\n";
##      }
#    } elsif ($tx_gen_int_in == 1) {
#        print APBFILE "0000000a002400000080   // Packet transmitted Interrupt\n";
#        print APBFILE "00000004002400000080   // Write to clear\n";
    }
    $total_num_tx_frames--;
  }
  while ($total_num_rx_frames != 0) {
    $total_num_rx_frames--;
  }

   # APB stuff
   # control triggers
   # 0  end-stop
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  generate APB trigger
   # 4  keep going
   # 5  force psel low for access
   if ($command =~ /^apbwr/ or $command =~ /^apbrd/ or $command =~ /^apbpoll/) {
      if ($command =~ /^apbwr/) {$read = "0";$comment = "   // write "}
      if ($command =~ /^apbrd/) {$read = "1";$comment = "   // read  "}

      $temp = chop ($command);

      # APB comment
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      if ($temp eq '"') {
         $apb_comment = "";
         $temp = chop ($command);
         while ($temp ne '"' and $temp ne '') {
            $apb_comment = $temp . $apb_comment;
            $temp = chop ($command);
         }
      } else {
         $apb_comment = '';
      }
      if ($temp eq '"') {$temp = chop ($command)}

      # look for any arguments 
      $maxarg = 0;
      $maxarg_hex = 0;
      if (($command.$temp) =~ /^(.*\s+)([a-zA-Z]+)(\s*\=\s*)(\d+)((\s+.*)||$)/) {
        if ($2 eq "max" || $2 eq "range" || $2 eq "num") {$maxarg = $4;}
        $command = $1.$5;
        $temp = chop ($command);
      }
      $maxarg_hex = sprintf "%04x",$maxarg;

      # look for perr or par
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      if ($temp eq 'r') {
         $temp = chop ($command);
         if ($temp eq 'a') {
           $err = '2';  # Parity error to inject
         } else {
           $err = '1';  # Expect perr to be asserted
         }
         while ($temp ne 'p' and $temp ne '') {
            $temp = chop ($command);
         }
         if ($temp eq 'p') {$temp = chop ($command);}
      } else {
         $err = '0';
      }
      
      # APB data
      if (($command.$temp) =~ /(apb.*)rand_msb(\d+)_to_lsb(\d+)(\s*(.)\s*([0-9a-fA-F]+)(\s|$))?/) {
        $command = $1;$temp = " ";
        my $msbit = $2;my $lsbit = $3;my $ormask = 0;my $andmask = hex("ffffffff");
        if (defined $5 && ($5 eq "or"  || $5 eq "|" || $5 eq "||")) {$ormask = hex($6);}
        if (defined $5 && ($5 eq "and" || $5 eq "&" || $5 eq "&&")) {$andmask = hex($6);}
        if ($msbit > 31 || $lsbit > 31) {print "TEST TRANSLATION ERROR : use bits in the apb rand command. max = 31.\n";exit;}
        $out = "";
        $msbit = $msbit;
        
        # if selecting msbit = 31 and lsbt = 16 we will generate a random value on the top 16 bits 
        # while we will generate a random value on bit 3. This is used in the 
        # testcase testing rx_drop_on_length functionality. The top 16 bits represent the maximum frame length
        # over which the frame will be dropped and the bit 3 is the enable bit of this feature. Otherwise it will
        # just generate a random value between the boundaries selected. A mask can be applied in both cases.
        if (($msbit == 31) && ($lsbit == 16)) {
          
          # We need to calculate here the maximum frame size we are going to receive 
          # so we can generate an appropriate value for the APB register to write
          my $ram_size;
          my $max_frame_length;
          if ($width32)  {$ram_size = (2**$cfg_rx_sram_depth) * 4;}
          if ($width64)  {$ram_size = (2**$cfg_rx_sram_depth) * 8;}
          if ($width128) {$ram_size = (2**$cfg_rx_sram_depth) * 16;}
          $max_frame_length = ($ram_size / 2) - 100;
          
          # Leave enough space for IP/UDP - just 200 bytes should be enough
          if    ($jumbo == 1 && ($max_frame_length > $rx_jumbo_max_len_reg)) {$max_frame_length = ($rx_jumbo_max_len_reg - (200*int ($udp_frame | $ipv4_frame | $ipv6_frame)));}
          elsif ($jumbo == 0 && ($max_frame_length > 1500))                  {$max_frame_length = (1500                  - (200*int ($udp_frame | $ipv4_frame | $ipv6_frame)));}
          
          # We want to generate a maximum value which is at least 100 bytes and the maximum value has to be max_frame_length
          $out = $out. (sprintf "%04x", int(rand($max_frame_length -100)) + 100);
          for(my $ind = 3; $ind >=0; $ind--) {
            if($ind == 0) { 
              my $enable_bit = int(rand(2));
              if($enable_bit == 1) {$out = $out. "8";} 
              else                 {$out = $out. "0";}  
            }
            else {$out = $out. "0";}
          }
        } else {
          for (my $zar = 7;$zar>=0;$zar--) {
            if   (($zar>($msbit/4))||($zar<($lsbit/4))){$out = $out."0";}
            else {$out = $out.(sprintf "%1x",int(rand(16)));}
          }        
        }
        
        $out = sprintf "%08x",(hex($out) & $andmask);
        $out = sprintf "%08x",(hex($out) | $ormask);

      } else {
        while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
        $out = "";
        while ($temp ne ' ' and $temp ne '	') {
          $out = $temp . $out;
          $temp = chop ($command);
        }

        if ($out eq "random") {$out = (sprintf "%08x",int(rand(2**32)));}
      }

      # APB address
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $addr_index = 0;
      while ($temp ne ' ' and $temp ne '	' and $addr_index ne 4) {
        $out = $temp . $out;
        $temp = chop ($command);
        $addr_index = $addr_index + 1;
      }
      #pad out address to 4 if neccessary
      while ($addr_index < 4) {
        $out = '0' . $out;
        $addr_index = $addr_index + 1;
      }
      # store addresses for address filtering for automatic rx frame generation
      my $apb_addr = substr("$out", 0, 4);
      my $addr_3bit = substr("$out", 1, 11);
      store_addresses("$addr_3bit");
      #print "addr index = $addr_index, OUT = $out, apb_addr = $apb_addr\n";


      # Also set perr if the address was to a GEM stat, but there are no stats in the configuration ...
      if ($cfg_no_stats && (hex($apb_addr) >= hex("0100") && hex($apb_addr) <= hex("01b4"))) {
        print "Test is reading a statistic, but there are no stats included in this configuration. Ignoring ... apb_addr = $apb_addr\n";
        $err = '1';
        $out = $apb_addr."zzzzzzzz";
      }


      # APB command
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      my $out5 = "0";
      $out6 = "0";
      if ($command =~ /^(\s*apb(rd|wr))(\s*\()([a-zA-Z0-9 _]+)(.*)$/) {
        $command = $1;
        $brackets = $4;
        if ($brackets =~ /asf_efint/) {
          $out2 = $read . "010";  # wait for asf int
          $out6 = "6";
          $comment = $comment . " wait for asf emac fatal int";
        } elsif ($brackets =~ /asf_eint/) {
          $out2 = $read . "010";  # wait for asf int
          $out6 = "5";
          $comment = $comment . " wait for asf emac non-fatal int";
        } elsif ($brackets =~ /asf_fint/) {
          $out2 = $read . "010";  # wait for asf int
          $out6 = "4";
          $comment = $comment . " wait for asf fatal int";
        } elsif ($brackets =~ /asf_int/) {
          $out2 = $read . "010";  # wait for asf int
          $out6 = "3";
          $comment = $comment . " wait for asf non-fatal int";
        } elsif ($brackets =~ /mmsl_int/) {
          $out2 = $read . "010";  # wait for int
          $out6 = "2";
          $comment = $comment . " wait for mmsl int";
        } elsif ($brackets =~ /eint([0-9abcdef])?/) {
          $out2 = $read . "010";  # wait for int
          $out6 = "1";
          if (defined($1)) {$out5 = $1;}
          $comment = $comment . " wait for int (queue = $out5)";
        } elsif ($brackets =~ /int([0-9abcdef])?/) {
          $out2 = $read . "010";  # wait for int
          $out6 = "0";
          if (defined($1)) {$out5 = $1;}
          $comment = $comment . " wait for int (queue = $out5)";
        } elsif ($brackets =~ /(scale )?(\d+)/) {
          $out3 = $2;#print "apb event : orig event time = $out3, ";
          $max_event_pre = $2;
          if (defined($1) && $1 =~ /scale /) {
            $out3 = int((($out3-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
            #print "scale_event_factor = $scale_event_factor, start_scale_pre = $start_scale_pre, start_scale_post = $start_scale_post, final time = $out3\n";
          } 
          $out2 = $read . "001";  # wait for trig
          $comment = $comment . " wait for trig (event time = $out3)";
          if ($events{$out3}) {
             $events{$out3} = 2+$events{$out3};
          } else {
             $events{$out3} = 2;
          }
          if ($out3 >$max_event) {
             $max_event = $out3;
          }
        } elsif ($brackets =~ /poll/) {
          $out2 = $read . "110";  # polling ...
          $comment = $comment . " polling for max $maxarg apb reads...";
        } elsif ($brackets =~ /est/) {
          $out2 = $read . "111";  # the read value is just an esimate and can be +- the value ...
          $comment = $comment . " the read value is just an esimate and can be +- 0x$maxarg_hex ...";
        }
      } else {
         $out2 = $read . "100";
         $comment = $comment . "and keep going";
      }

      while ($temp eq ' ' or $temp eq '	' or $temp eq '(') {$temp = chop ($command)}
      if ($temp eq 'f') {
         if ($out2 ne $read . "100") {
            print "** ERROR ** can't have APB forcing trigger combined with an APB wait\n";
            exit;
         }
         $out2 = $read . "011";  # force APB trigger
         $comment = $comment . " force APB trigger";
      }
      elsif ($temp eq 'o') {
         if ($out2 ne $read . "100") {
            print "** ERROR ** can't have APB other slave combined with an APB wait\n";
            exit;
         }
         $out2 = $read . "101";  # force psel low for access
         $comment = $comment . " force psel low";
      }

      if ($out2 eq '0000') {$out2 = "0";}
      if ($out2 eq '0001') {$out2 = "1";}
      if ($out2 eq '0010') {$out2 = "2";}
      if ($out2 eq '0011') {$out2 = "3";}
      if ($out2 eq '0100') {$out2 = "4";}
      if ($out2 eq '0101') {$out2 = "5";}
      if ($out2 eq '0110') {$out2 = "6";}
      if ($out2 eq '0111') {$out2 = "7";}
      if ($out2 eq '1000') {$out2 = "8";}
      if ($out2 eq '1001') {$out2 = "9";}
      if ($out2 eq '1010') {$out2 = "a";}
      if ($out2 eq '1011') {$out2 = "b";}
      if ($out2 eq '1100') {$out2 = "c";}
      if ($out2 eq '1101') {$out2 = "d";}
      if ($out2 eq '1110') {$out2 = "e";}
      if ($out2 eq '1111') {$out2 = "f";}

      # write apb comment file if necessary
      if ($apb_comment ne '') {
         $out3 = "1";
         # convert apb comment to number format
         $temp2 = $apb_comment;
         #$temp2 =~ tr/A-Z/a-z/;    # make all lower case
         $temp = chop ($temp2);
         $apb_comment2 = "";
         for ($i = 1; $i <= 64; $i++) {
            $out4 = sprintf "%02x",ord($temp);
            $apb_comment2 = $out4 . $apb_comment2;
            $temp = chop ($temp2);
         }
         printf COMMENTFILE "$apb_comment2  // $apb_comment\n",;
      } else {
         $out3 = "0";
      }
      my $add_tmp = substr("$out", 0, 4);
      my $data_tmp = substr("$out", 4, 8);
      $comment = $comment . ", add = $add_tmp, data = $data_tmp";
      if ($out2 eq '4' || $out2 eq 'c') { 
         for ($i = 0; $i <= $maxarg; $i++) {
            printf APBFILE "$out6" . "0000$err$out5$out3$out2$out$comment";
            if ($maxarg > 0) {print APBFILE " part of a repeat cmd (total = $maxarg)\n";}else{print APBFILE "\n";};
         }
      } else {
        printf APBFILE "$out6$maxarg_hex$err$out5$out3$out2$out$comment\n";
      }
   }


   # pins driving stuff
   # control triggers
   # 0  end-stop
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   if ($command =~ /^pinsd/) {
      $comment = "   // drive";
      @pinsd = (0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,0,0,0,0,0,
                0,0,0,0,
                0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,0,
                0,0,0,0,
                0,0,
                0,0,0,0,0,0,0,0,0,
                0,0,0,0,
                0,0,
                1,0,0);
      @byte = (0,0,0,0,0,0,0,0);
      # pinsd data
      $temp = chop ($command);
      while ($temp ne ')' and $temp ne '') {
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find data
         $byte = "00000000";
         $byte_index = 0;
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $data = $temp;
            $byte[$byte_index] = $temp;
            $byte_index = $byte_index + 1;
            $temp = chop ($command)
         }
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find pin
         $pin = "";
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $pin = $temp . $pin;
            $temp = chop ($command)
         }
         if ($pin eq "external_int") {
            $pinsd[0] = '1';
            $pinsd[1] = $data;
            $comment = $comment . " external_int ";
         }
         if ($pin eq "eam") {
            $pinsd[2] = '1';
            $pinsd[3] = $data;
            $comment = $comment . " eam ";
         }
         if ($pin eq "preset_n") {
            $pinsd[4] = '1';
            $pinsd[5] = $data;
            $comment = $comment . " Preset_n ";
         }
         if ($pin eq "crs") {
            $pinsd[6] = '1';
            $pinsd[7] = $data;
            $comment = $comment . " crs ";
         }
         if ($pin eq "tx_en_crs") {
            $pinsd[8] = '1';
            $pinsd[9] = $data;
            $comment = $comment . " tx_en_crs ";
         }
         if ($pin eq "col_sqe_en") {
            $pinsd[10] = '1';
            $pinsd[11] = $data;
            $comment = $comment . " col_sqe_en ";
         }
         if ($pin eq "tx_pause") {
            $pinsd[12] = '1';
            $pinsd[13] = $data;
            $comment = $comment . " tx_pause ";
         }
         if ($pin eq "tx_pause_zero") {
            $pinsd[14] = '1';
            $pinsd[15] = $data;
            $comment = $comment . " tx_pause_zero ";
         }
         if ($pin eq "user_in") {
            $pinsd[16] = '1';
            $pinsd[17] = $byte[0];
            $pinsd[18] = $byte[1];
            $pinsd[19] = $byte[2];
            $pinsd[20] = $byte[3];
            $pinsd[21] = $byte[4];
            $pinsd[22] = $byte[5];
            $pinsd[23] = $byte[6];
            $pinsd[24] = $byte[7];
            $comment = $comment . " user_in ";
         }
         if ($pin eq "signal_detect") {
            $pinsd[25] = '1';
            $pinsd[26] = $data;
            $comment = $comment . " signal_detect ";
         }
         if ($pin eq "mii_select") {
            $pinsd[27] = '1';
            $pinsd[28] = $data;
            $comment = $comment . " mii_select ";
         }
         if ($pin eq "tsu_inc_ctrl") {
            $pinsd[29] = '1';
            $pinsd[30] = $byte[0];
            $pinsd[31] = $byte[1];
            $comment = $comment . " gem_tsu_inc_ctrl ";
         }
         if ($pin eq "tsu_ms") {
            $pinsd[32] = '1';
            $pinsd[33] = $data;
            $comment = $comment . " gem_tsu_ms ";
         }
         if ($pin eq "rx_er") {
            $pinsd[34] = '1';
            $pinsd[35] = $data;
            $comment = $comment . " rx_er ";
         }
         if ($pin eq "back_pressure") {
            $pinsd[36] = '1';
            $pinsd[37] = $data;
            $comment = $comment . " back_pressure ";
         }
         if ($pin eq "tx_pfc_sel") {
            $pinsd[38] = '1';
            $pinsd[39] = $data;
            $comment = $comment . " tx_pfc_sel ";
         }
         if ($pin eq "tx_pfc_pause") {
            $pinsd[40] = '1';
            $pinsd[41] = $byte[0];
            $pinsd[42] = $byte[1];
            $pinsd[43] = $byte[2];
            $pinsd[44] = $byte[3];
            $pinsd[45] = $byte[4];
            $pinsd[46] = $byte[5];
            $pinsd[47] = $byte[6];
            $pinsd[48] = $byte[7];
            $comment = $comment . " tx_pfc_pause ";
         }
         if ($pin eq "tx_pfc_pause_zero") {
            $pinsd[49] = '1';
            $pinsd[50] = $byte[0];
            $pinsd[51] = $byte[1];
            $pinsd[52] = $byte[2];
            $pinsd[53] = $byte[3];
            $pinsd[54] = $byte[4];
            $pinsd[55] = $byte[5];
            $pinsd[56] = $byte[6];
            $pinsd[57] = $byte[7];
            $comment = $comment . " tx_pfc_pause_zero ";
         }
         if ($pin eq "trigger_dma_tx_start") {
            $pinsd[58] = '1';
            $pinsd[59] = $data;
            $comment = $comment . " trigger_dma_tx_start ";
         }
         if ($pin eq "pcs_cal_bypass") {
            $pinsd[60] = '1';
            $pinsd[61] = $data;
            $comment = $comment . " pcs_cal_bypass ";
         }
         if ($pin eq "pcs_cgalign_bypass") {
            $pinsd[62] = '1';
            $pinsd[63] = $data;
            $comment = $comment . " pcs_cgalign_bypass ";
         }
         if ($pin eq "tb_rx_bit_slip") {
            $pinsd[64] = '1';
            $pinsd[65] = $byte[0];
            $pinsd[66] = $byte[1];
            $pinsd[67] = $byte[2];
            $pinsd[68] = $byte[3];
            $pinsd[69] = $byte[4];
            $pinsd[70] = $byte[5];
            $pinsd[71] = $byte[6];
            $pinsd[72] = $byte[7];
            $comment = $comment . " tb_rx_bit_slip ";
         }
         if ($pin eq "keep_idle_i1") {
            $pinsd[73] = '1';
            $pinsd[74] = $data;
            $comment = $comment . " keep_idle_i1 ";
         }
         if ($pin eq "tb_mode_2_5g") {
            $pinsd[75] = '1';
            $pinsd[76] = $data;
            $comment = $comment . " tb_mode_2_5g ";
         }
         if ($pin eq "amba_par_err_inj") {
            $pinsd[77] = '1';
            $pinsd[78] = $data;
            $comment = $comment . " amba_par_err_inj ";
         }
         
      }
      if ($temp eq ')') {
         $temp = chop ($command);
         if ($temp eq 't') {
            $pinsd[79] = '0';
            $pinsd[80] = '1';
            $pinsd[81] = '0';
            $comment = $comment . "- wait for interrupt";
         } elsif ($temp eq 'b') {
            $pinsd[79] = '1';  # wait for apb
            $pinsd[80] = '1';  # wait for apb
            $pinsd[81] = '0';
            $comment = $comment . "- wait for apb";
         } else {
            $comment = $comment . "- wait for trig";
            $out3 = "";
            if (($command.$temp) =~ /\((scale (\d+))/) {
               $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
               $max_event_pre = $2;
            } elsif (($command.$temp) =~ /\((\d+)/) { 
               $out3 = $1;
               $max_event_pre = $out3;
            }
            if ($events{$out3}) {
               $events{$out3} = 4+$events{$out3};
            } else {
               $events{$out3} = 4;
            }
            if ($out3 >$max_event) {
               $max_event = $out3;
            }
         }
      } else {
         $pinsd[79] = '0';
         $pinsd[80] = '0';
         $pinsd[81] = '1';
         $comment = $comment . "- keep going";
      }

      for ($i = 81; $i >= 0; $i--) {
         #print  "$i $pinsd[$i]\n";
         print PINSDFILE "$pinsd[$i]";
      }
      print PINSDFILE "$comment\n";
   }



   # pins checking stuff
   # control triggers
   # 0  end-stop
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   if ($command =~ /^pinsc/) {
      $comment = "   // check";
      @pinsc = (0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                0,0,0,0,
                1,0,0);
      @byte = (0,0,0,0,0,0,0,0);
      # pinsc data
      $temp = chop ($command);
      while ($temp ne ')' and $temp ne '') {
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find data
         $byte = "00000000";
         $byte_index = 0;
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $data = $temp;
            $byte[$byte_index] = $temp;
            $byte_index = $byte_index + 1;
            $temp = chop ($command)
         }
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find pin
         $pin = "";
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $pin = $temp . $pin;
            $temp = chop ($command)
         }
         if ($pin eq "loopback") {
            $pinsc[0] = '1';
            $pinsc[1] = $data;
            $comment = $comment . " loopback ";
         }
         if ($pin eq "half_duplex") {
            $pinsc[2] = '1';
            $pinsc[3] = $data;
            $comment = $comment . " half_duplex ";
         }
         if ($pin eq "ethernet_int") {
            $pinsc[4] = '1';
            $pinsc[5] = $data;
            $comment = $comment . " ethernet_int ";
         }
         if ($pin eq "speed") {
            $pinsc[6] = '1';
            $pinsc[7] = $data;
            $comment = $comment . " speed ";
         }
         if ($pin eq "user_out") {
            $pinsc[8] = '1';
            $pinsc[9]  = $byte[0];
            $pinsc[10] = $byte[1];
            $pinsc[11] = $byte[2];
            $pinsc[12] = $byte[3];
            $pinsc[13] = $byte[4];
            $pinsc[14] = $byte[5];
            $pinsc[15] = $byte[6];
            $pinsc[16] = $byte[7];
            $comment = $comment . " user_out ";
         }
         if ($pin eq "wol") {
            $pinsc[17] = '1';
            $pinsc[18] = $data;
            $comment = $comment . " wol ";
         }
         if ($pin eq "en_cdet") {
            $pinsc[19] = '1';
            $pinsc[20] = $data;
            $comment = $comment . " en_cdet ";
         }
         if ($pin eq "sof_tx") {
            $pinsc[21] = '1';
            $pinsc[22] = $data;
            $comment = $comment . " sof_tx ";
         }
         if ($pin eq "sync_frame_tx") {
            $pinsc[23] = '1';
            $pinsc[24] = $data;
            $comment = $comment . " sync_frame_tx ";
         }
         if ($pin eq "delay_req_tx") {
            $pinsc[25] = '1';
            $pinsc[26] = $data;
            $comment = $comment . " delay_req_tx ";
         }
         if ($pin eq "sof_rx") {
            $pinsc[27] = '1';
            $pinsc[28] = $data;
            $comment = $comment . " sof_rx ";
         }
         if ($pin eq "sync_frame_rx") {
            $pinsc[29] = '1';
            $pinsc[30] = $data;
            $comment = $comment . " sync_frame_rx ";
         }
         if ($pin eq "delay_req_rx") {
            $pinsc[31] = '1';
            $pinsc[32] = $data;
            $comment = $comment . " delay_req_rx ";
         }
         if ($pin eq "pfc_negotiate") {
            $pinsc[33] = '1';
            $pinsc[34] = $data;
            $comment = $comment . " pfc_negotiate ";
         }
         if ($pin eq "rx_pfc_paused") {
            $pinsc[35] = '1';
            $pinsc[36]  = $byte[0];
            $pinsc[37] = $byte[1];
            $pinsc[38] = $byte[2];
            $pinsc[39] = $byte[3];
            $pinsc[40] = $byte[4];
            $pinsc[41] = $byte[5];
            $pinsc[42] = $byte[6];
            $pinsc[43] = $byte[7];
            $comment = $comment . " rx_pfc_paused ";
         }
         if ($pin eq "pdelay_req_tx") {
            $pinsc[44] = '1';
            $pinsc[45] = $data;
            $comment = $comment . " pdelay_req_tx ";
         }
         if ($pin eq "pdelay_resp_tx") {
            $pinsc[46] = '1';
            $pinsc[47] = $data;
            $comment = $comment . " pdelay_resp_tx ";
         }
         if ($pin eq "pdelay_req_rx") {
            $pinsc[48] = '1';
            $pinsc[49] = $data;
            $comment = $comment . " pdelay_req_rx ";
         }
         if ($pin eq "pdelay_resp_rx") {
            $pinsc[50] = '1';
            $pinsc[51] = $data;
            $comment = $comment . " pdelay_resp_rx ";
         }
         if ($pin eq "tsu_timer_cmp_val") {
            $pinsc[52] = '1';
            $pinsc[53] = $data;
            $comment = $comment . " tsu_timer_cmp_val ";
         }
         if ($pin eq "ewrap") {
            $pinsc[54] = '1';
            $pinsc[55] = $data;
            $comment = $comment . " ewrap ";
         }
         if ($pin eq "asf_sram_corr_err") {
            $pinsc[56] = '1';
            $pinsc[57] = $data;
            $comment = $comment . " asf_sram_corr_err ";
         }
         if ($pin eq "asf_sram_uncorr_err") {
            $pinsc[58] = '1';
            $pinsc[59] = $data;
            $comment = $comment . " asf_sram_uncorr_err ";
         }
         if ($pin eq "asf_dap_err") {
            $pinsc[60] = '1';
            $pinsc[61] = $data;
            $comment = $comment . " asf_dap_err ";
         }
         if ($pin eq "asf_csr_err") {
            $pinsc[62] = '1';
            $pinsc[63] = $data;
            $comment = $comment . " asf_csr_err ";
         }
         if ($pin eq "asf_trans_to_err") {
            $pinsc[64] = '1';
            $pinsc[65] = $data;
            $comment = $comment . " asf_trans_to_err ";
         }
         if ($pin eq "asf_protocol_err") {
            $pinsc[66] = '1';
            $pinsc[67] = $data;
            $comment = $comment . " asf_protocol_err ";
         }
         if ($pin eq "asf_integrity_err") {
            $pinsc[68] = '1';
            $pinsc[69] = $data;
            $comment = $comment . " asf_integrity_err ";
         }
         if ($pin eq "asf_int_nonfatal") {
            $pinsc[70] = '1';
            $pinsc[71] = $data;
            $comment = $comment . " asf_int_nonfatal ";
         }
         if ($pin eq "asf_int_fatal") {
            $pinsc[72] = '1';
            $pinsc[73] = $data;
            $comment = $comment . " asf_int_fatal ";
         }
         if ($pin eq "emac_asf_sram_corr_err") {
            $pinsc[74] = '1';
            $pinsc[75] = $data;
            $comment = $comment . " emac_asf_sram_corr_err ";
         }
         if ($pin eq "emac_asf_sram_uncorr_err") {
            $pinsc[76] = '1';
            $pinsc[77] = $data;
            $comment = $comment . " emac_asf_sram_uncorr_err ";
         }
         if ($pin eq "emac_asf_dap_err") {
            $pinsc[78] = '1';
            $pinsc[79] = $data;
            $comment = $comment . " emac_asf_dap_err ";
         }
         if ($pin eq "emac_asf_csr_err") {
            $pinsc[80] = '1';
            $pinsc[81] = $data;
            $comment = $comment . " emac_asf_csr_err ";
         }
         if ($pin eq "emac_asf_trans_to_err") {
            $pinsc[82] = '1';
            $pinsc[83] = $data;
            $comment = $comment . " emac_asf_trans_to_err ";
         }
         if ($pin eq "emac_asf_protocol_err") {
            $pinsc[84] = '1';
            $pinsc[85] = $data;
            $comment = $comment . " emac_asf_protocol_err ";
         }
         if ($pin eq "emac_asf_integrity_err") {
            $pinsc[86] = '1';
            $pinsc[87] = $data;
            $comment = $comment . " emac_asf_integrity_err ";
         }
         if ($pin eq "emac_asf_int_nonfatal") {
            $pinsc[88] = '1';
            $pinsc[89] = $data;
            $comment = $comment . " emac_asf_int_nonfatal ";
         }
         if ($pin eq "emac_asf_int_fatal") {
            $pinsc[90] = '1';
            $pinsc[91] = $data;
            $comment = $comment . " emac_asf_int_fatal ";
         }
         #print  "$pin $data\n";
      }
      if ($temp eq ')') {
         $temp = chop ($command);
         if ($temp eq 't') {
            $pinsc[92] = '0';
            $pinsc[93] = '1';
            $comment = $comment . "- wait for interrupt";
         } elsif ($temp eq 'b') {
            $pinsc[92] = '1';  # wait for apb
            $pinsc[93] = '1';  # wait for apb
            $comment = $comment . "- wait for apb";
         } else {
            $comment = $comment . "- wait for trig";
            $out3 = "";
            if (($command.$temp) =~ /\((scale (\d+))/) {
               $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
               $max_event_pre = $2;
               print "pinsc orig time = $2, scale_event_factor = $scale_event_factor, start_scale_pre = $start_scale_pre,start_scale_post = $start_scale_post, final time = $out3\n";
            } elsif (($command.$temp) =~ /\((\d+)/) { 
               $out3 = $1;
               $max_event_pre = $out3;
            }
            if ($events{$out3}) {
               $events{$out3} = 8+$events{$out3};
            } else {
               $events{$out3} = 8;
            }
            if ($out3 >$max_event) {
               $max_event = $out3;
            }
         }
      } else {
         $pinsc[92] = '0';
         $pinsc[93] = '0';
         $pinsc[94] = '1';
         $comment = $comment . "- keep going";
      }

      for ($i = 94; $i >= 0; $i--) {
         print PINSCFILE "$pinsc[$i]";
      }
      print PINSCFILE "$comment\n";
   }





   # filter driving stuff
   # control triggers
   # 0  end-stop
   # 1  wait for trigger
   # 2  wait for interrupt
   # 3  wait for APB trigger
   # 4  keep going
   if ($command =~ /^filterd/) {
      $comment = "   // drive";
      @filterd = (0,0,0,0,0,0,0,0,1,0,0);
      @byte = (0,0,0,0,0,0,0,0);
      # filterd data
      $temp = chop ($command);
      while ($temp ne ')' and $temp ne '') {
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find data
         $byte = "00000000";
         $byte_index = 0;
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $data = $temp;
            $byte[$byte_index] = $temp;
            $byte_index = $byte_index + 1;
            $temp = chop ($command)
         }
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find filter pin to drive
         $filterpin = "";
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $filterpin = $temp . $filterpin;
            $temp = chop ($command)
         }
         if ($filterpin eq "ext_match1") {
            $filterd[0] = '1';
            $filterd[1] = $data;
            $comment = $comment . " ext_match1 ";
         }
         if ($filterpin eq "ext_match2") {
            $filterd[2] = '1';
            $filterd[3] = $data;
            $comment = $comment . " ext_match2 ";
         }
         if ($filterpin eq "ext_match3") {
            $filterd[4] = '1';
            $filterd[5] = $data;
            $comment = $comment . " ext_match3 ";
         }
         if ($filterpin eq "ext_match4") {
            $filterd[6] = '1';
            $filterd[7] = $data;
            $comment = $comment . " ext_match4 ";
         }
      }
      if ($temp eq ')') {
         $temp = chop ($command);
         if ($temp eq 't') {
            $filterd[8] = '0';
            $filterd[9] = '1';
            $comment = $comment . "- wait for interrupt";
         } elsif ($temp eq 'b') {
            $filterd[8] = '1';  # wait for apb
            $filterd[9] = '1';  # wait for apb
            $comment = $comment . "- wait for apb";
         } else {
            $comment = $comment . "- wait for trig";
            $out3 = "";
            if (($command.$temp) =~ /\((scale (\d+))/) {
               $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
               $max_event_pre = $2;
            } elsif (($command.$temp) =~ /\((\d+)/) { 
               $out3 = $1;
               $max_event_pre = $out3;
            }
            if ($events{$out3}) {
               $events{$out3} = 64+$events{$out3};
            } else {
               $events{$out3} = 64;
            }
            if ($out3 >$max_event) {
               $max_event = $out3;
            }
         }
      } else {
         $filterd[8]  = '0';
         $filterd[9]  = '0';
         $filterd[10] = '1';
         $comment = $comment . "- keep going";
      }

      for ($i = 10; $i >= 0; $i--) {
         #print  "$i $filterd[$i]\n";
         print FILTERDFILE "$filterd[$i]";
      }
      print FILTERDFILE "$comment\n";
   }



   # filter checking stuff
   # control triggers
   # 000000  end-stop
   # xxxxxxxxxxxxx1  check da
   # xxxxxxxxxxxx1x  check sa
   # xxxxxxxxxxx1xx  check typeID
   # xxxxxxxxxx1xxx  check VID
   # xxxxxxxxx1xxxx  check IP sa
   # xxxxxxxx1xxxxx  check IP da
   # xxxxxxx1xxxxxx  check rx PTP sync frame
   # xxxxxx1xxxxxxx  check rx PTP delay request frame
   # xxxxx1xxxxxxxx  check IPv6 sa
   # xxxx1xxxxxxxxx  check IPv6 da
   # xxx1xxxxxxxxxx  check VLAN 1 tag
   # xx1xxxxxxxxxxx  check VLAN 2 tag
   # x1xxxxxxxxxxxx  check source port
   # 1xxxxxxxxxxxxx  check destination port
   if ($command =~ /^filterc/) {
      $filtercontrol = 0;
      $comment = "   // check";
      @filterc = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
      @word = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
      # filterc data
      $temp = chop ($command);
      while ($temp ne ')' and $temp ne '') {
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find data
         $word_index = 0;
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $word = $temp;
            $word[$word_index] = $temp;
            $word_index = $word_index + 1;
            $temp = chop ($command)
         }
         while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
         # find filter pin
         $filterpin = "";
         while ($temp ne ')' and $temp ne '' and $temp ne ' ' and $temp ne '	') {
            $filterpin = $temp . $filterpin;
            $temp = chop ($command)
         }
         if ($filterpin eq "da") {
            $filtercontrol += 1;
            $comment = $comment ." da";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index] = $word[$word_index];
            }
         }
         if ($filterpin eq "sa") {
            $filtercontrol += 2;
            $comment = $comment ." sa";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 12] = $word[$word_index];
            }
         }
         if ($filterpin eq "type") {
            $filtercontrol += 4;
            $comment = $comment ." type";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 24] = $word[$word_index];
            }
         }
         if ($filterpin eq "vid") {
            $filtercontrol += 8;
            $comment = $comment ." vid";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 28] = $word[$word_index];
           }
         }
         if ($filterpin eq "ipsa") {
            $filtercontrol += 16;
            $comment = $comment ." ipsa";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 32] = $word[$word_index];
           }
         }
         if ($filterpin eq "ipda") {
            $filtercontrol += 32;
            $comment = $comment ." ipda";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 40] = $word[$word_index];
           }
         }
         if ($filterpin eq "ptp_sync") {
            $filtercontrol += 64;
         }
         if ($filterpin eq "ptp_delay_req") {
            $filtercontrol += 128;
         }
         if ($filterpin eq "ipv6sa") {
            $filtercontrol += 256;
            $comment = $comment ." ipv6sa";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 48] = $word[$word_index];
           }
         }
         if ($filterpin eq "ipv6da") {
            $filtercontrol += 512;
            $comment = $comment ." ipv6da";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 80] = $word[$word_index];
           }
         }
         if ($filterpin eq "vlan1") {
            $filtercontrol += 1024;
            $comment = $comment ." vlan1";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 112] = $word[$word_index];
           }
         }
         if ($filterpin eq "vlan2") {
            $filtercontrol += 2048;
            $comment = $comment ." vlan2";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 120] = $word[$word_index];
           }
         }
         if ($filterpin eq "sp") {
            $filtercontrol += 4096;
            $comment = $comment ." sp";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 128] = $word[$word_index];
           }
         }
         if ($filterpin eq "dp") {
            $filtercontrol += 8192;
            $comment = $comment ." dp";
            while ($word_index ne '0') {
               $word_index = $word_index - 1;
               $filterc[$word_index + 132] = $word[$word_index];
           }
         }
      }
      #form hexadecimal control word
      $filterc[136] = sprintf ("%04x", $filtercontrol);

      for ($i = 136; $i >= 0; $i--) {
         #print "$filterc[$i]";
         print FILTERCFILE "$filterc[$i]";
      }
      print FILTERCFILE "$comment\n";
   }





   # DMA READ stuff
   # put 1 in first nibble position to indicate end stop
   if ($command =~ /^dma_rd/) {

      if ($command =~ /^dma_rd\s+rx_descr_q(\d+)/) {
        $this_is_rx_descr_rd = $1 + 1;}
      elsif ($command =~ /^dma_rd\s+rx_descr/) {
        $this_is_rx_descr_rd = 1;}
      else {$this_is_rx_descr_rd = 0;}

      if ($command =~ /^dma_rd\s+tx_descr/) {
        $this_is_tx_descr_rd = 1;} else {$this_is_tx_descr_rd = 0;}
      # DMA data
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      if ($temp eq 'k') {
         $control = "1"; # not OK signal
         $comment = "  // HRESP not OK";
         $command =~ s/not_o//;       # remove not_ok
         $temp = chop ($command);
      } elsif ($temp eq 'p') {
         $control = "2"; # Endian swap
         $comment = "  // Endian Swap";
         $command =~ s/endian_swa//;       # remove endian_swap
         $temp = chop ($command);
      } else {
         $control = "0"; # put 0 in first nibble position to indicate valid data
         $comment = "  // dma read data";
      }
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $data = "";
      $add = "";
      $upperadd = "";
      # store data
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
        $data = $temp . $data;
        $temp = chop ($command);
      }
      $out = $add.$data;

      # skip blanks
      while ($temp =~ '\s') {$temp = chop ($command)}
      # store address
      if ($temp ne "r") { # if rx_q_ptr use $cur_rx_ptr instead
         $varcnt = 0;
         while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
            $varcnt++;
            if ($varcnt > 8) {
              if ($addr64 == 1) {$upperadd = $temp . $upperadd;} else {
                print ("********ERROR : >32bit ADDRESS found in dma_rd command, but 64bit addressing is not enabled\n");
                exit;
              }
            } else {
              $add = $temp . $add;
            }
            $temp = chop ($command);
         }
         if ($addr64 == 1 && $varcnt != 16) {
           print ("********ERROR : 64 bit addressing was enabled, but 64bit address was not in the testcase\n");
           exit;
         } elsif ($addr64 == 0) {$upperadd = "00000000";}
      }
      
      # Adding a specific number in the dma_rd command allows us to repeat a DMA command in trans.pl
      # The replication of the dma_rd is performed locally here so the TB knows nothing about it
      if ($command =~ /^dma_rd\s*\((\d+)\)/) {
        $repeatvar = $1;
      # If there is the word "maxrpt" in the brackets, then it will repeat
      # he dma_rd specified by auto-incrementing the address
      } elsif ($command =~ /^dma_rd\s*\(repeat\)/) {
        $repeatvar = 0;$control = 9;
         $comment = "  // repeating this line automatically in TB (infinite times ..)";
      } else {$repeatvar = 0;}


      if ($temp eq "r") { # This is set if tx_q_ptr or rx_q_ptr is set in place of the address !
         if ($repeatvar != 0) { print "Cant repeat here\n";}

         # use pointer value if required
         chop ($command);chop ($command);chop ($command);chop ($command);
         chop ($command);chop ($command);
         $temp = chop ($command);
         if ($temp eq "r") { # This is set if rx_q_ptr is set in place of the address !
            #supply last dma rx buffer pointer read - RX descriptors always uses original datafile
           if (($addr64 == 1) && ($ext_bd_rx == 1)) {
             $rx_ptr_inc = 24;         # +24 is equivalent to 6 BD WORDS
           }
           elsif (($addr64 == 1) || ($ext_bd_rx == 1))  {
             $rx_ptr_inc = 16;
           } else {
             $rx_ptr_inc = 8;          ## default is +8 ie 2 BD WORDS
           }
           if ($num_dma_queues != 1) {
              for (my $qcnt=($num_dma_queues-1);$qcnt >= 0;$qcnt--) {
                 printf {$DMARD_RXDESCR_FH[$qcnt]}  "0%08x%08x$out  // DMA read, address automatically entered\n",$descr_addr_upper_32, $rx_pointer[$qcnt];
                 if ($addr64 == 1) {
                   printf {$DMARD_RXDESCR_FH[$qcnt]}    "0%08x%08x%08x  // (Upper Address)\n",$descr_addr_upper_32 , $rx_pointer[$qcnt]+8,  (int(rand(2^32)));;
                 }
                 $rx_pointer[$qcnt] = $rx_pointer[$qcnt] + $rx_ptr_inc;
              }
           } else {
             printf {$DMARD_RXDESCR_FH[0]} "$control%08x%08x$out$comment A \n", $descr_addr_upper_32 , $cur_rx_ptr;
             if ($addr64 == 1) {
               printf {$DMARD_RXDESCR_FH[0]} "$control%08x%08x%08x // Upper Add \n", $descr_addr_upper_32 , $cur_rx_ptr+8, (int(rand(2^32)));
             }
             $cur_rx_ptr = $cur_rx_ptr + $rx_ptr_inc;
           }

         } elsif ($tx_status == 0) { # This is set if tx_q_ptr is set in place of the address !
            #supply last dma tx buffer pointer read
            $tx_status = 1;
            if ($width32) {
              printf {$DMARD_TXDESCR_FH[0]} "$control%08x%08x$out$comment B\n", $descr_addr_upper_32 , $tx_pointer +4;
            } else {
              printf {$DMARD_TXDESCR_FH[0]} "$control%08x%08x$out$comment B\n", $descr_addr_upper_32 , $tx_pointer;
            }
         } else {
            #supply last dma tx buffer status read
            if ($width32) {
              printf {$DMARD_TXDESCR_FH[0]} "$control%08x%08x$out$comment C\n", $descr_addr_upper_32 , $tx_pointer;
            } else {
              printf {$DMARD_TXDESCR_FH[0]} "$control%08x%08x$out$comment C\n", $descr_addr_upper_32 , $tx_pointer +4;
            }
            $tx_status = 0;
         }
      } else {
        # For 64bit and 128 bit datapaths, we want to ensure the data accesses are always done in full stripes
        # so we enforce that here even if the test doesnt
        # We do this by looking at the current address and the last dma_wr address. If they are not just 4 out, then we can assume the
        # last data buffer has completed. we then check we had the correct multiple of bytes to fill the programmed databus.
        if ($width64 == 1) {$need_32bit_accesses=2;} elsif ($width128 == 1) {$need_32bit_accesses=4;} else {$need_32bit_accesses=1;}
        if ($enforce_data_width && $last_was_data_rd && ((hex($last_dma_rd_add) + 4) != hex($add)))  {
          while ($num_32bit_accesses != 0) {
            $last_dma_rd_add = (hex($last_dma_rd_add) + 4);
            $last_dma_rd_add = sprintf("%08x",($last_dma_rd_add));
            printf {$DMARD_TXDATA_FH[$last_queue]} "$control${lastupperadd}${last_dma_rd_add}00000000 // $num_32bit_accesses, add = $add, last_dma_rd_add = $last_dma_rd_add, enforcing number of 32bit accesses\n";
            $num_32bit_accesses=($num_32bit_accesses+1)%$need_32bit_accesses;
          }
        }
         for (my $z=0;$z <= $repeatvar; $z++) {
           $add = hex $add;
           if ($this_is_rx_descr_rd != 0) {
             $num_32bit_accesses=0;
             printf {$DMARD_RXDESCR_FH[$this_is_rx_descr_rd-1]} "$control$upperadd%08x$data$comment D1\n",$add;
           } elsif ($this_is_tx_descr_rd == 1) {
             $add = sprintf("%08x",$add);
             $tmp = "$control$upperadd$add$data$comment D $num_32bit_accesses\n";
             $add = hex($add);
             $num_32bit_accesses=0;
             if ($descr_cnt == 0) {
               $this_is_first_descr_rd = 1;
               if ($width32 == 1 && $auto_descriptor_swap) {
                 $hold_32bit_descr = $tmp;
                 $descr_cnt++;
               } else {
                 printf {$DMARD_TXDESCR_FH[0]} $tmp;
               }
             } elsif ($descr_cnt == 1) {
               printf {$DMARD_TXDESCR_FH[0]} $tmp;
               printf {$DMARD_TXDESCR_FH[0]} $hold_32bit_descr;
               $this_is_first_descr_rd = 0;
               if ($ext_bd_tx) {
                 $descr_cnt++;
               } else {
                 $descr_cnt = 0;
               }
             } else {
               if ($descr_cnt == 3) {$descr_cnt = 0;} else {$descr_cnt++;}
               $this_is_first_descr_rd = 0;
               printf {$DMARD_TXDESCR_FH[0]} $tmp;
             }
           } else {
             $num_32bit_accesses=($num_32bit_accesses+1)%$need_32bit_accesses;
             printf {$DMARD_TXDATA_FH[0]} "$control$upperadd%08x$data$comment D $num_32bit_accesses\n",$add;
           }
           $last_dma_rd_add = sprintf("%08x",$add);
           $lastupperadd = $upperadd;
           $last_was_data_rd = $this_is_tx_descr_rd == 0 && $this_is_rx_descr_rd == 0;
           $add = $add +4;
           $add = sprintf("%08x",$add);
         }
         $repeatvar = 0;
      }
   }


   # DMA WRITE stuff
   # put 1 in first nibble position to indicate end stop
   if ($command =~ /^dma_wr/) {
      if ($command =~ /^dma_wr\s*\((\d+)\)/) {
        $repeatvar = $1;} else {$repeatvar = 0;}

      if ($command =~ /^dma_wr\s+rx_descr/) {$this_is_rx_descr_wr = 1;} else {$this_is_rx_descr_wr = 0;}
      if ($command =~ /^dma_wr\s+tx_descr/) {$this_is_tx_descr_wr = 1;} else {$this_is_tx_descr_wr = 0;}

      # DMA data
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      if ($temp eq 'k') {
         $control = "1"; # not OK signal
         $comment = "  // HRESP not OK";
         $command =~ s/not_o//;       # remove not_ok
         $temp = chop ($command);
      } elsif ($temp eq 'p') {
         $control = "2"; # Endian swap
         $comment = "  // Endian Swap";
         $command =~ s/endian_swa//;       # remove endian_swap
         $temp = chop ($command);
      } else {
         $control = "0"; # put 0 in first nibble position to indicate valid data
         $comment = "  // dma write data";
      }
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $data = "";
      $add = "";
      # store data
      $num_data_nibbles = 0;
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
        $data = $temp . $data;
        $temp = chop ($command);
        $num_data_nibbles++;
      }
      # If the data was exactly 4 bytes (8 nibbles), then this is definately write data
      # If it was 1 nibble, then it is byte enables, and the data will isntead come next
      # Adding byte enables are optional in the testcase. Without it, byte enables are assumed to be
      # all set.
      if ($num_data_nibbles == 1) {
        $byte_en = $data.$data;
        while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
        $data = "";
        $add = "";
        # store data
        while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
          $data = $temp . $data;
          $temp = chop ($command);
        }
      } else {$byte_en = "ff"};

      # skip blanks
      while ($temp =~ '\s') {$temp = chop ($command)}
      # store address
      $varcnt = 0;
      $upperadd="";
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
        $varcnt++;
        if ($varcnt > 8) {
          if ($addr64 == 1) {$upperadd = $temp . $upperadd;} else {
            print ("********ERROR : >32bit ADDRESS found in dma_wr command, but 64bit addressing is not enabled\n");
            exit;
          }
        } else {$add = $temp . $add;}
        $temp = chop ($command);
      }
      
      # As per the userguide ...
      # if the packet buffer mode and the number of
      # configured specific address filters is greater than four then
      # external address matching is not reported in bit 28 of the RX descriptor write (word 1) and instead it is set if
      # there has been a match in the first eight specific address registers. Bit 27 is
      # then used along with bits 26:25 to indicate which register matched.      
      if ($cfg_num_spec_add_filters > 4 && $this_is_rx_descr_wr && ((hex($add) & hex('4')) == 4)) { 
        # First clear bit 28 as the bit is no longer external address match 
        $data = sprintf("%08x",(hex($data) & hex('efffffff'))); 
        # Then if bit 27 of the RX descriptor is set (spec add reg match), then Clear bit 27 and set bit 28
        if ((hex(substr("$data" ,1,1)) & hex('8')) == 8) {
          print "remapping RX descr write to cater for the fact there are more than 4 spec add filters in this configuration.\n";
          $data = sprintf("%08x",(hex($data) & hex('f7ffffff') | hex('10000000'))); 
        }
      }
      
      if ($addr64 == 1 && $varcnt != 16) {   # where $varcnt is number of hex characters in address. 64b needs 16 characters
        print ("********ERROR : 64 bit addressing was enabled, but 64bit address was not in the testcase\n");
        exit;
      } elsif ($addr64 == 0) {$upperadd = "00000000";}
      
      # For 64bit and 128 bit datapaths, we want to ensure the data accesses are always done in full stripes
      # so we enforce that here even if the test doesnt
      # We do this by looking at the current address and the last dma_wr address. If they are not just 4 out, then we can assume the
      # last data buffer has completed. we then check we had the correct multiple of bytes to fill the programmed databus.
      if ($width64 == 1) {$need_32bit_accesses=2;} elsif ($width128 == 1) {$need_32bit_accesses=4;} else {$need_32bit_accesses=1;}
      if ($enforce_data_width && $last_was_data_wr && ((hex($last_dma_wr_add) + 4) != hex($add)))  {
        while ($num_32bit_accesses != 0) {
          $comment = " // add = $add, last_dma_wr_add = $last_dma_wr_add, enforcing number of 32bit accesses";
          $num_32bit_accesses=($num_32bit_accesses+1)%$need_32bit_accesses;
          #print "last_dma_wr_add is $last_dma_wr_add\n";
          $last_dma_wr_add = (hex($last_dma_wr_add) + 4);
          $last_dma_wr_add = sprintf("%08x",($last_dma_wr_add));
          printf {$DMAWR_RXDATA_FH[$last_queue]} "$control${lastupperadd}${last_dma_wr_add}00000000ff$comment\n";
        }
      }
      if ($enforce_data_width && $last_was_data_rd)  {
        while ($num_32bit_accesses != 0) {
          $last_dma_rd_add = (hex($last_dma_rd_add) + 4);
          $last_dma_rd_add = sprintf("%08x",($last_dma_rd_add));
          printf {$DMARD_TXDATA_FH[$last_queue]} "$control${lastupperadd}${last_dma_rd_add}00000000 // $num_32bit_accesses, enforcing number of 32bit accesses\n";
          $num_32bit_accesses=($num_32bit_accesses+1)%$need_32bit_accesses;
        }
      }
      
      for (my $z=0;$z <= $repeatvar; $z++) {
        if ($this_is_tx_descr_wr) {
          $tmp = "$control$upperadd$add$data$byte_en // TX descriptor write\n";
          $num_32bit_accesses=0;
          if ($descr_cnt == 0) {
            if ($auto_descriptor_swap && $width32 && $ext_bd_tx) {
              $hold_32bit_descr = $tmp;
              $descr_cnt++;
            } else {
              printf {$DMAWR_TXDESCR_FH[0]} $tmp;
            }
          } elsif ($descr_cnt == 2) {
            printf {$DMAWR_TXDESCR_FH[0]} $tmp;
            $descr_cnt = 0;
          } else {
            printf {$DMAWR_TXDESCR_FH[0]} $tmp;
            printf {$DMAWR_TXDESCR_FH[0]} $hold_32bit_descr;
            $descr_cnt++;
          }
          $last_queue = 0;
        } elsif ($this_is_rx_descr_wr) {
          $num_32bit_accesses=0;
          $this_is_first_descr_wr = !$this_is_first_descr_wr;
          $tmp = "$control$upperadd$add$data$byte_en // RX descriptor write\n";
          if ($this_is_first_descr_wr && $width32 == 1 && $auto_descriptor_swap) {
            $hold_32bit_descr = $tmp;
            $last_queue = $rx_queue_to_use;
          } elsif ($axi_test) {
            printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use]} $tmp;
            if ($auto_descriptor_swap && $width32 == 1) {printf {$DMAWR_RXDESCR_FH[$last_queue]} $hold_32bit_descr};
            $last_queue = $rx_queue_to_use;
          } else {
            printf {$DMAWR_RXDESCR_FH[0]} $tmp;
            if ($auto_descriptor_swap && $width32 == 1) {printf {$DMAWR_RXDESCR_FH[$last_queue]} $hold_32bit_descr};
            $last_queue = 0;
          }
        } elsif ($axi_test) {
          $num_32bit_accesses=($num_32bit_accesses+1)%$need_32bit_accesses;
          $last_queue = $rx_queue_to_use;
          printf {$DMAWR_RXDATA_FH[$rx_queue_to_use]} "$control$upperadd$add$data$byte_en$comment $last_dma_wr_add $num_32bit_accesses\n";
        } else {
          $num_32bit_accesses=($num_32bit_accesses+1)%$need_32bit_accesses;
          $last_queue = 0;
          printf {$DMAWR_RXDATA_FH[0]} "$control$upperadd$add$data$byte_en$comment\n";
        }
        $last_dma_wr_add = $add;
        $lastupperadd = $upperadd;
        $last_was_data_wr = $this_is_rx_descr_wr == 0 && $this_is_tx_descr_wr == 0;
        $last_was_data_rd = 0;
        $add = hex $add;
        $add = $add +4;
        $add = sprintf("%08x",$add);
      }
      $repeatvar = 0;
   }


   # FIFO Tx READ stuff
   # Tx read data is 32 bit hex
   # fifo_code[7:0] is a byte of binary as follows:
   #   [0] : tx_r_eop
   #   [1] : tx_r_sop
   #   [2] : tx_r_err
   #   [3] : tx_r_data_rdy
   #   [4] : tx_r_underflow
   #   [5] : tx_r_flushed
   #   [6] : tx_r_control
   #   [7] : RESERVED
   # control[3:0] is trigger control of value...
   #   1   : fifo_rd_not_ok
   #   2   : wait for interrupt trigger
   #   3   : wait for apb trigger
   #   4   : wait for status write trigger
   #   5-e : reserved
   #   f   : end of data

   if ($command =~ /^fifo_rd/) {

      $comment = "";
      if ($command =~ /\s+q\d+/ ) {$has_q = 1;} else {$has_q = 0;}
      $temp = chop ($command);
      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get read queue, if there is any
      if ($has_q == 1) {
        #print "$command\n";
        $fifo_rd_queue  = "";
        while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
          if ($temp =~ 'q') {
            $temp = chop ($command);
          } else {
            $fifo_rd_queue = $temp.$fifo_rd_queue;
            $temp = chop ($command);
          }
        }
        #form hexadecimal status byte
      } else {
        $fifo_rd_queue = 0;
      }
      $fifo_rd_queue = sprintf ("%01x", $fifo_rd_queue);
      
      #print "Queue = $fifo_rd_queue\n";

      # get read data
      while ($temp =~ '\s') {$temp = chop ($command)}
      $fifo_rd_data  = "";
      $fifo_rd_data2 = "";
      $fifo_rd_data3 = "";
      $fifo_rd_data4 = "";
      $nibble_count  = 0;
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {

         #assign nibbles to correct range of 32 bits
         if ($nibble_count < 8) {
            $fifo_rd_data = $temp.$fifo_rd_data;
         } elsif ($nibble_count < 16) {
            $fifo_rd_data2 = $temp.$fifo_rd_data2;
         } elsif ($nibble_count < 24) {
            $fifo_rd_data3 = $temp.$fifo_rd_data3;
         } else {
            $fifo_rd_data4 = $temp.$fifo_rd_data4;
         }
         $nibble_count = $nibble_count + 1;
         $temp         = chop ($command);
      }

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get fifo status[7:0]
      $byte_code = 0;
      $bit_index = 1;
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
         if ($temp eq '1') {
            $byte_code =  $byte_code + $bit_index;
         }
         $bit_index = $bit_index * 2;
         $temp      = chop ($command);
      }
            #form hexadecimal status byte
      $fifo_status = sprintf ("%02x", $byte_code);

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get fifo mod[3:0]
      $fifo_rd_mod = "";
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
         $fifo_rd_mod = $temp.$fifo_rd_mod;
         $temp      = chop ($command);
      }

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get fifo control[7:0]
      $byte_code = 0;
      $bit_index = 1;
      while ($temp ne ' ' and $temp ne '	' and $temp ne '' and $temp ne ')') {
         if ($temp eq '1') {
            $byte_code =  $byte_code + $bit_index;
         }
         $bit_index = $bit_index * 2;
         $temp      = chop ($command);
      }
      #form hexadecimal control byte
      $fifo_code = sprintf ("%02x", $byte_code);

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      #form control word for triggers
      $control = "0";
      if ($temp eq ')') {
         $temp = chop ($command);
         if ($temp eq 't') {
            $control = "2";
            $comment = "  // wait for interrupt";
         } elsif ($temp eq 'b') {
            $control = "3";
            $comment = "  // wait for APB trigger";
         } elsif ($temp eq 'a') {
            $control = "4";
            $comment = "  // wait for status writeback trigger";
         }
         $temp = chop ($command);
      }


      # write out decoded stuff to file
      printf FIFORDFILE "$fifo_rd_queue$control$fifo_status$fifo_code$fifo_rd_mod$fifo_rd_data$comment\n";
      if ($nibble_count >= 16) {
         printf FIFORDFILE "$fifo_rd_queue$control$fifo_status$fifo_code$fifo_rd_mod$fifo_rd_data2$comment\n";
      }
      if ($nibble_count == 32) {
         printf FIFORDFILE "$fifo_rd_queue$control$fifo_status$fifo_code$fifo_rd_mod$fifo_rd_data3$comment\n";
         printf FIFORDFILE "$fifo_rd_queue$control$fifo_status$fifo_code$fifo_rd_mod$fifo_rd_data4$comment\n";
      }
   }



   # FIFO Rx WRITE stuff
   # Rx write data is 32 bit hex
   # control[3:0] is trigger control of value...
   #   0   : carry on
   #   1   : wait for interrupt trigger
   #   2   : wait for apb trigger
   #   3-e : reserved
   #   f   : end of data
   if ($command =~ /^fifo_wr/) {

      $comment = "";
      $temp = chop ($command);
      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get write data
      $fifo_wr_data  = "";
      $fifo_wr_data2 = "";
      $fifo_wr_data3 = "";
      $fifo_wr_data4 = "";
      $nibble_count  = 0;
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {

         #assign nibbles to correct range of 32 bits
         if ($nibble_count < 8) {
            $fifo_wr_data = $temp.$fifo_wr_data;
         } elsif ($nibble_count < 16) {
            $fifo_wr_data2 = $temp.$fifo_wr_data2;
         } elsif ($nibble_count < 24) {
            $fifo_wr_data3 = $temp.$fifo_wr_data3;
         } else {
            $fifo_wr_data4 = $temp.$fifo_wr_data4;
         }
         $nibble_count = $nibble_count + 1;
         $temp         = chop ($command);
      }

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get fifo status[39:0]
      $fifo_wr_status = "";
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
         $fifo_wr_status = $temp.$fifo_wr_status;
         $temp        = chop ($command);
      }
      if (length ($fifo_wr_status) == 10) {$fifo_wr_status = "xx".$fifo_wr_status}
      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get fifo mod[3:0]
      $fifo_wr_mod = "";
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
         $fifo_wr_mod = $temp.$fifo_wr_mod;
         $temp      = chop ($command);
      }

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}

      # get fifo control[7:0]
      $byte_code = 0;
      $bit_index = 1;
      while ($temp ne ' ' and $temp ne '	' and $temp ne '') {
         if ($temp eq '1') {
            $byte_code =  $byte_code + $bit_index;
         }
         $bit_index = $bit_index * 2;
         $temp      = chop ($command);
      }
      #form hexadecimal control byte
      $fifo_code = sprintf ("%02x", $byte_code);

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}
      
      # check if there is a Queue ID ...
      my $rx_queue = 0;
      while ($temp =~ '\d') {$temp = chop ($command);$rx_queue = $temp.$rx_queue;}
      $rx_queue  = sprintf "%01x", $rx_queue ;

      # remove blanks
      while ($temp =~ '\s') {$temp = chop ($command)}
      
      #form control word for triggers
      $control = "0";
      if ($temp eq ')') {
         $temp = chop ($command);
         if ($temp eq 't') {
            $control = "1";
            $comment = "  // wait for interrupt";
         } elsif ($temp eq 'b') {
            $control = "2";
            $comment = "  // wait for APB trigger";
         $temp = chop ($command);
         }
      }

      $fifo_code2 = $fifo_code;
      $fifo_code3 = $fifo_code;
      $fifo_code4 = $fifo_code;
      $fifo_wr_status2 = $fifo_wr_status;
      $fifo_wr_status3 = $fifo_wr_status;
      $fifo_wr_status4 = $fifo_wr_status;

      # SOP cant be set twice!
      if ($cfg_emac_bus_width < 128) {
        $fifo_code2 = sprintf "%02x",(hex($fifo_code) & hex("1d"));
      }
      if ($cfg_emac_bus_width < 128) {
        $fifo_code3 = sprintf "%02x",(hex($fifo_code) & hex("1d"));
        $fifo_code4 = sprintf "%02x",(hex($fifo_code) & hex("1d"));
      }

      # EOP cant be set twice too!
      if (($nibble_count >  8 && ($cfg_emac_bus_width == 32 && (hex($fifo_wr_mod) == 0 || hex($fifo_wr_mod) > 4))) || 
          ($nibble_count > 16 && ($cfg_emac_bus_width == 64 && (hex($fifo_wr_mod) == 0 || hex($fifo_wr_mod) > 8)))) {
        $fifo_code = sprintf "%02x",(hex($fifo_code) & hex("1e"));
        $fifo_wr_status = "000000000000";
      }
      if ($nibble_count > 16 && ($cfg_emac_bus_width != 128 && (hex($fifo_wr_mod) == 0 || hex($fifo_wr_mod) > 8))) {
        $fifo_code2 = sprintf "%02x",(hex($fifo_code2) & hex("1e"));
        $fifo_wr_status2 = "000000000000";
      }
      if ($nibble_count > 16 && ($cfg_emac_bus_width == 32 && (hex($fifo_wr_mod) == 0 || hex($fifo_wr_mod) > 12))) {
        $fifo_code3 = sprintf "%02x",(hex($fifo_code3) & hex("1e"));
        $fifo_wr_status3 = "000000000000";
      }
      if ($fifo_wr_mod eq "x") {
        $fifo_wr_mod_cor = "x";
      } else {
        $fifo_wr_mod_cor = sprintf "%01x",(hex($fifo_wr_mod) % ($cfg_emac_bus_width/8));
      }

      # write out decoded stuff to file
      printf FIFOWRFILE "$control$rx_queue$fifo_code$fifo_wr_mod_cor$fifo_wr_status$fifo_wr_data$comment\n";
      if ($nibble_count > 8  && ($cfg_emac_bus_width == 128 || hex($fifo_wr_mod) == 0 ||
                                ($cfg_emac_bus_width == 64) ||
                                ($cfg_emac_bus_width == 32  && hex($fifo_wr_mod) > 4))) {
         printf FIFOWRFILE "$control$rx_queue$fifo_code2$fifo_wr_mod_cor$fifo_wr_status2$fifo_wr_data2$comment\n";
      }
      if ($nibble_count > 16 && ($cfg_emac_bus_width == 128 || hex($fifo_wr_mod) == 0 || hex($fifo_wr_mod) > 8)) {
         printf FIFOWRFILE "$control$rx_queue$fifo_code3$fifo_wr_mod_cor$fifo_wr_status3$fifo_wr_data3$comment\n";
      }
      if ($nibble_count > 16 && ($cfg_emac_bus_width == 128 || hex($fifo_wr_mod) == 0 ||
                                ($cfg_emac_bus_width == 64  && hex($fifo_wr_mod) > 8) ||
                                ($cfg_emac_bus_width == 32  && hex($fifo_wr_mod) > 12))) {
         printf FIFOWRFILE "$control$rx_queue$fifo_code4$fifo_wr_mod_cor$fifo_wr_status4$fifo_wr_data4$comment\n";
      }
   }



   # mdio stuff
   # first bit is for end - 1 indicates stop
   if ($command =~ /^mdio/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $mdio_temp = "S";  # mark end of string
      while ($temp ne ' ' and $temp ne '') {
         $mdio_temp = $mdio_temp . $temp;   # reverse order of mdio
         $temp = chop ($command);
      }

      $temp = chop ($mdio_temp);
      while ($temp ne 'S') {
         if ($temp ne 'S') {
            $mdio[$mdio_index] = '0' . $temp;  # load up $mdio in correct order
            $mdio_index = $mdio_index + 1;
            $temp = chop ($mdio_temp);
         }
      }

   }



   # end stuff - the end command forces the test to stop
   if ($command =~ /^end/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      if ($temp eq ')') {
         $temp = chop ($command);
         $out3 = "";
         if (($command.$temp) =~ /\((scale (\d+))/) {
           $out3 = int((($2-$start_scale_pre) * $scale_event_factor)+$start_scale_post);
           $max_event_pre = $2;
         } elsif (($command.$temp) =~ /\((\d+)/) { 
           $out3 = $1;
           $max_event_pre = $out3;
         }
         if ($events{$out3}) {
            $events{$out3} = 16+$events{$out3};
         } else {
            $events{$out3} = 16;
         }
         if ($out3 >$max_event) {
            $max_event = $out3;
         }
      }
   }




   # stop stuff - use if want $stop instead of $finish in the test cases
   if ($command =~ /^stop/) {
      $stop = 1;
   }

   # randomization of hgrant
   if ($command =~ /^randomize_hgrant/) {
      $randomize_hgrant = 1;
   }

   if ($command =~ /^check_txlinerate/) {
      $check_txlinerate = 1;
   }

   if ($command =~ /^\s*tog_cnt_en/) {
      $tog_cnt_enable = 1;
   }

   if ($command =~ /^fixed_latency_mode/) {
    $fixed_latency_mode = 1;
   }

   if ($command =~ /^randomize_hready/) {
      $read_min = 0x00;
      $read_max = 0xff;
      $write_min = 0x00;
      $write_max = 0xff;
      $descr_min = 0x00;
      $descr_max = 0x07;
      $data_min  = 0x00;
      $data_max  = 0x07;
      $data_min_lock  = 0x00;
      $data_max_lock  = 0x07;
      $command =~ s/randomize_hready\s*//;
      while ($command =~ /^-/)
      {
        if ($command =~ /-write_min\s*(\d+)\s*/)
        {
          $write_min  = $1;
          $command =~ s/-write_min\s+(\d+)\s*//;
        }
        if ($command =~ /-write_max\s*(\d+)\s*/)
        {
          $write_max  = $1;
          $command =~ s/-write_max\s+(\d+)\s*//;
        }
        if ($command =~ /-read_min\s*(\d+)\s*/)
        {
          $read_min  = $1;
          $command =~ s/-read_min\s+(\d+)\s*//;
        }
        if ($command =~ /-read_max\s*(\d+)\s*/)
        {
          $read_max  = $1;
          $command =~ s/-read_max\s+(\d+)\s*//;
        }
        if ($command =~ /-descr_min\s*(\d+)\s*/)
        {
          $descr_min  = $1;
          $command =~ s/-descr_min\s+(\d+)\s*//;
        }
        if ($command =~ /-descr_max\s*(\d+)\s*/)
        {
          $descr_max  = $1;
          $command =~ s/-descr_max\s+(\d+)\s*//;
        }
        if ($command =~ /-data_min\s+(\d+)\s*/)
        {
          $data_min  = $1;
          $command =~ s/-data_min\s+(\d+)\s*//;
        }
        if ($command =~ /-data_max\s+(\d+)\s*/)
        {
          $data_max  = $1;
          $command =~ s/-data_max\s+(\d+)\s*//;
        }
        if ($command =~ /-data_min_lock\s+(\d+)\s*/)
        {
          $data_min_lock  = $1;
          $command =~ s/-data_min_lock\s+(\d+)\s*//;
        }
        if ($command =~ /-data_max_lock\s+(\d+)\s*/)
        {
          $data_max_lock  = $1;
          $command =~ s/-data_max_lock\s+(\d+)\s*//;
        }
      }
      $randomize_hready = 1;
   }

   if ($command =~ /^set_arready_delay/) {
      $command =~ s/set_arready_delay\s*//;
      while ($command =~ /^-/)
      {
        if ($command =~ /-min\s*(\d+)\s*/)
        {
          $arready_min  = $1;
          $command =~ s/-min\s+(\d+)\s*//;
        }
        if ($command =~ /-max\s*(\d+)\s*/)
        {
          $arready_max  = $1;
          $command =~ s/-max\s+(\d+)\s*//;
        }
      }
   }
   if ($command =~ /^set_awready_delay/) {
      $command =~ s/set_awready_delay\s*//;
      while ($command =~ /^-/)
      {
        if ($command =~ /-min\s*(\d+)\s*/)
        {
          $awready_min  = $1;
          $command =~ s/-min\s+(\d+)\s*//;
        }
        if ($command =~ /-max\s*(\d+)\s*/)
        {
          $awready_max  = $1;
          $command =~ s/-max\s+(\d+)\s*//;
        }
      }
   }
   if ($command =~ /^set_wready_delay/) {
      $command =~ s/set_wready_delay\s*//;
      while ($command =~ /^-/)
      {
        if ($command =~ /-min\s*(\d+)\s*/)
        {
          $wready_min  = $1;
          $command =~ s/-min\s+(\d+)\s*//;
        }
        if ($command =~ /-max\s*(\d+)\s*/)
        {
          $wready_max  = $1;
          $command =~ s/-max\s+(\d+)\s*//;
        }
      }
   }
   if ($command =~ /^set_rvalid_resp_latency/) {
      $command =~ s/set_rvalid_resp_latency\s*//;
      while ($command =~ /^-/)
      {
        if ($command =~ /-min\s*(\d+)\s*/)
        {
          $rvalid_min  = $1;
          $command =~ s/-min\s+(\d+)\s*//;
        }
        if ($command =~ /-max\s*(\d+)\s*/)
        {
          $rvalid_max  = $1;
          $command =~ s/-max\s+(\d+)\s*//;
        }
      }
   }
   if ($command =~ /^set_bvalid_resp_latency/) {
      $command =~ s/set_bvalid_resp_latency\s*//;
      while ($command =~ /^-/)
      {
        if ($command =~ /-min\s*(\d+)\s*/)
        {
          $bvalid_min  = $1;
          $command =~ s/-min\s+(\d+)\s*//;
        }
        if ($command =~ /-max\s*(\d+)\s*/)
        {
          $bvalid_max  = $1;
          $command =~ s/-max\s+(\d+)\s*//;
        }
      }
   }

   # ten_meg_bit stuff - use if want mac clocks going at 2.5MHz
   if ($command =~ /^ten_meg_bit/) {
      $ten_meg_bit = $ten_meg_bit+1;
   }
   # ten_meg_bit stuff - use if want mac clocks going at 2.5MHz
   if ($command =~ /^set_10G_mode/i) {
      $ten_gig_mode = 1;
   }
   if ($command =~ /^set_axi_perf_test/i) {
      $axi_perf_test = 1;
   }
   if ($command =~ /^set_40G_mode/i) {
      $fourty_gig_mode = 1;
   }
   if ($command =~ /^fifo_loopback_mode/i) {
      $fifo_loopback_mode = 1;
   }
   if ($command =~ /^sel_ahb_freq/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $sel_ahb_freq = $temp;
      $ten_meg_bit = ($ten_meg_bit + 2*$sel_ahb_freq);
   }

   # wait_states stuff - use to change the number of wait states
   # on AMBA bus
   if ($command =~ /^wait_states/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $wait_states = $temp;
      $temp = chop ($command);
      if ($temp ne ' '){$wait_states = $temp.$wait_states;$temp = chop ($command);};
      if (($wait_states ne '0' and $wait_states ne '1' and $wait_states ne '2' and
           $wait_states ne '3' and $wait_states ne '4' and $wait_states ne '5' and
           $wait_states ne '6' and $wait_states ne '7' and $wait_states ne '8' and
           $wait_states ne '9' and $wait_states ne '10' and $wait_states ne '11' and
           $wait_states ne '12' and $wait_states ne '13' and $wait_states ne '14' and
           $wait_states ne '15') or $temp ne ' ') {
         die "\n\n**** wait_states value can only be set to 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 or 11 ****   - not $wait_states -\n\n\n";
      }
   }

   # bus_grant_delay stuff - use to change the delay in granting the amba bus
   # on AMBA bus
   if ($command =~ /^bus_grant_delay/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $bus_grant_delay = $temp;
      $temp = chop ($command);
      if (($bus_grant_delay ne '0' and $bus_grant_delay ne '1' and $bus_grant_delay ne '2' and
           $bus_grant_delay ne '3' and $bus_grant_delay ne '4' and $bus_grant_delay ne '5' and
           $bus_grant_delay ne '6' and $bus_grant_delay ne '7') or $temp ne ' ') {
         die "\n\n**** bus_grant_delay value can only be set to 0, 1, 2, 3, 4, 5, 6 or 7 ****   - not $temp$bus_grant_delay -\n\n\n";
      }
   }

   # The following ensures that whatever datawidth is selected for this test, the 
   # translator will pass through correct multiples of 32bit words for data transfers
   # (not descriptors). This relies on the test writer using the rx_descr and tx_descr to
   # differentiate between the DMA accesses.
   if ($command =~ /^enforce_data_width/) {$enforce_data_width = 1;};

  # In 32b datapaths, the 64bit descriptors are accessed not in incrementing order
  # The used bit is always read first, and written last.
  # For TX since the used bit is bit 63, the 2nd 32bit word is always read first
  # For RX since the used bit is bit 0, the 2nd 32bit word is always written first
  # This ordering is only there for 32bit modes
  # To simplify writing testcases and ensure the same test can operate on different datawidths
  # we can automatically reverse the order ...
   if ($command =~ /^auto_descriptor_swap/) {$auto_descriptor_swap = 1;};

   # this is the event count that will initialize the scaler for event counts. any number less than this is not scaled
   # you should use it when receive or transmit traffic starts ...
   if ($command =~ /^start_scale/) {$start_scale_pre = $max_event_pre;$start_scale_post = $max_event;}

   # $hready_stop - used for long waits on AHB
   if ($command =~ /^hready_stop/) {
      # get stop time
      $hready_stop_active = '';
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      while ($temp =~ '\d') {
         $hready_stop_active = $temp . $hready_stop_active;
         $temp = chop ($command);
      }
      if ($hready_stop_active > '65535') {
         die "\n\n**** hready_stop value must be less than 65536 ****   - not $hready_stop_active -\n\n\n";
      }

      # get delay
      $hready_stop_delay = '';
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      while ($temp =~ '\d') {
         $hready_stop_delay = $temp . $hready_stop_delay;
         $temp = chop ($command);
      }
      if ($hready_stop_delay > '65535') {
         die "\n\n**** hready_stop value must be less than 65536 ****   - not $hready_stop_delay -\n\n\n";
      }

      printf DMAHRDYFILE "%04x%04x\n", $hready_stop_active, $hready_stop_delay;
   }

   # fifo latency - set delay between FIFO read and valid data output in tb_fifo
   if ($command =~ /^fifo_latency/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $fifo_latency = $temp;
      $temp = chop ($command);
      if (($fifo_latency ne '0' and $fifo_latency ne '1' and $fifo_latency ne '2' and
           $fifo_latency ne '3' and $fifo_latency ne '4' and $fifo_latency ne '5' and
           $fifo_latency ne '6' and $fifo_latency ne '7') or $temp ne ' ') {
         die "\n\n**** fifo_latency value can only be set to 0, 1, 2, 3, 4, 5, 6 or 7 ****   - not $temp$fifo_latency -\n\n\n";
      }
   }

   # fifo undeflow latency - set delay between FIFO read and undeflow output in tb_fifo
   if ($command =~ /^fifo_under_delay/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $fifo_under_delay = $temp;
      $temp = chop ($command);
      if (($fifo_under_delay ne '0' and $fifo_under_delay ne '1' and $fifo_under_delay ne '2' and
           $fifo_under_delay ne '3' and $fifo_under_delay ne '4' and $fifo_under_delay ne '5' and
           $fifo_under_delay ne '6' and $fifo_under_delay ne '7') or $temp ne ' ') {
         die "\n\n**** fifo_under_delay value can only be set to 0, 1, 2, 3, 4, 5, 6 or 7 ****   - not $temp$fifo_under_delay -\n\n\n";
      }
   }

   # fifo status delay - set delay between FIFO receiving handshake at end of frame and sending back status handshake
   if ($command =~ /^fifo_status_delay/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $fifo_status_delay = $temp;
      $temp = chop ($command);
      if (($fifo_status_delay ne '0' and $fifo_status_delay ne '1' and $fifo_status_delay ne '2' and
           $fifo_status_delay ne '3' and $fifo_status_delay ne '4' and $fifo_status_delay ne '5' and
           $fifo_status_delay ne '6' and $fifo_status_delay ne '7') or $temp ne ' ') {
         die "\n\n**** fifo_status_delay value can only be set to 0, 1, 2, 3, 4, 5, 6 or 7 ****   - not $temp$fifo_status_delay -\n\n\n";
      }
   }

   # fifo overflow delay - set delay between FIFO write and overflow
   if ($command =~ /^fifo_over_delay/) {
      $temp = chop ($command);
      while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks
      $fifo_over_delay = $temp;
      $temp = chop ($command);
      if (($fifo_over_delay ne '0' and $fifo_over_delay ne '1' and $fifo_over_delay ne '2' and
           $fifo_over_delay ne '3' and $fifo_over_delay ne '4' and $fifo_over_delay ne '5' and
           $fifo_over_delay ne '6' and $fifo_over_delay ne '7') or $temp ne ' ') {
         die "\n\n**** fifo_over_delay value can only be set to 0, 1, 2, 3, 4, 5, 6 or 7 ****   - not $temp$fifo_over_delay -\n\n\n";
      }
   }



}

if ($tx_data_check == 0) { print "Warning ...Disabling TX Link side checking ... ..\n"; }


# now write out the pcs_tx data file
for ($i = 0; $i < $tx_pcs_index; $i++) {
   print TXPCSFILE "$tx_pcs_vector[$i]\n";
}

# now write out the pcs_rx data file
for ($i = 0; $i < $rx_pcs_index; $i++) {
   print RXPCSFILE "$rx_pcs_vector[$i]\n";
}

# now write out the tx data file
#for ($i = 0; $i < $eth_txd_index; $i++) {
#   print TXDFILE "$eth_txd[$i]\n";
#}
#print TXDFILE "0000000  // end-stop\n";
write_txd_file();
write_txd1_file();
write_txd2_file();
write_txd3_file();
write_txd4_file();
write_txd5_file();
write_txd6_file();
write_txd7_file();
write_txd8_file();
write_txd9_file();
write_txd10_file();
write_txd11_file();
write_txd12_file();
write_txd13_file();
write_txd14_file();
write_txd15_file();


# now write out the rx data file
#for ($i = 0; $i < $eth_rxd_index; $i++) {
#   print RXDFILE "$eth_rxd[$i]\n";
#}
#print RXDFILE "00000000000  // end-stop\n";
write_rxd_file();

# now write out the mdio data file
for ($i = 0; $i < $mdio_index; $i++) {
   print MDIOFILE "$mdio[$i]\n";
}

# write out event file file
print EVENTFILE "// rx_trig           = event_vector[24]\n";
print EVENTFILE "// pcs_rx_trig       = event_vector[29]\n";
print EVENTFILE "// apb_trig          = event_vector[25]\n";
print EVENTFILE "// pins_drive_trig   = event_vector[26]\n";
print EVENTFILE "// pins_check_trig   = event_vector[27]\n";
print EVENTFILE "// filter_drive_trig = event_vector[30]\n";
print EVENTFILE "// end_trig          = event_vector[28]\n";

if ($max_event > 4000000) {
   print "** ERROR ** $max_event is too big\n";
}

for ($i = 0; $i <= $max_event; $i++) {
   if ($events{$i}) {
      printf EVENTFILE "%02x%06x\n",$events{$i},$i;
   }
}

print_initfile ();

printf AXI_LATENCY_FILE "// Contains wait state and latency info for the 5 AXI channels\n",;
printf AXI_LATENCY_FILE "%04x%04x%04x%04x%04x%04x%04x%04x%04x%04x\n",$arready_min,$arready_max,$rvalid_min,$rvalid_max,$awready_min,$awready_max,$wready_min,$wready_max,$bvalid_min,$bvalid_max;
printf AXI_LATENCY_FILE "// arready_min = $arready_min\n";
printf AXI_LATENCY_FILE "// arready_max = $arready_max\n";
printf AXI_LATENCY_FILE "// rvalid_min  = $rvalid_min\n";
printf AXI_LATENCY_FILE "// rvalid_max  = $rvalid_max\n";
printf AXI_LATENCY_FILE "// awready_min = $awready_min\n";
printf AXI_LATENCY_FILE "// awready_max = $awready_max\n";
printf AXI_LATENCY_FILE "// wready_min  = $wready_min\n";
printf AXI_LATENCY_FILE "// wready_max  = $wready_max\n";
printf AXI_LATENCY_FILE "// bvalid_min  = $bvalid_min\n";
printf AXI_LATENCY_FILE "// bvalid_max  = $bvalid_max\n";

print_file_ends ();


################################################################################
# read_rx_frame
#
# - Subroutine to read the current testcase for Rx frame data
################################################################################
sub read_rx_frame {

   my $num_of_frames = "";
   my $temp          = "";
   my $control       = "";

   $temp = chop ($command);  # $temp takes the value of the last letter in
                             # $command

   while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks

   # Work through the testcase line from right to left.  This first while
   # loop determines the number of frames that are to be received
   while ($temp ne 'e' and $temp ne ')' and $temp ne ' ' and $temp ne  '	') {
      $num_of_frames = $temp.$num_of_frames;
      $temp = chop ($command);
   }

   while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks

   ###############################################
   # Determine the control trigger for the frame #
   ###############################################
   if ($temp eq ')') {

     $temp = chop ($command);

     #assign default control to "keep going" i.e. 4
     $control = '4';

     if ($temp eq 't') {
        $control = "2";  # Wait for interrupt
        while ($temp ne '(') {$temp = chop ($command)}
     }

     elsif ($temp eq 'b') {
        $control = "3";  # Wait for APB trigger
        while ($temp ne '(') {$temp = chop ($command)}
     }

     elsif ($temp eq 'p') {
        $control = "6";  # Wait gap time
        while ($temp ne '(') {$temp = chop ($command)}
     }

     else {
        $control = "1";  # Wait for trig
        print "WAIT FOR TRIG NOT SUPORTED YET!!!\n";
        while ($temp ne '(') {$temp = chop ($command)}
     }
   }
   $first_frame = 1;
   generate_rx_frames ($num_of_frames, $control);
}




################################################################################
# generate_rx_frames
#
# - Subroutine to generate the required Rx frames
################################################################################
sub generate_rx_frames {
   my ($num_of_frames, $control) = @_;

   my @command        = ""; # The array that the frame information is stored in
   my $i              = 0;
   my $frame_valid    = ""; # Flag indicating if a frame is valid or not

   my $min_size       = "";
   my $max_size       = "";
   my $min_data_size  = "";
   my $max_data_size  = "";

   my $addr_size      = "12"; # Size of dest_addr and src_addr (in nibbles)
   my $tlf_size       =  "4"; # Size of the type_len_field (in nibbles)
   my $fcs_size       =  "8"; # Size of the FCS field (in nibbles)

   # Strings to hold the frame information
   my $fcs_data       = "";
   my $frame          = "";
   my $frame_dma      = "";
   my $frame_temp     = "";
   my $frame_temp_dma = "";
   my $preamble_size  = "";
   my $preamble       = "";
   my $sfd            = "";
   my $specific_addr  = ""; # Holds the destination address (not reordered)
   my $dest_addr      = ""; # Holds the destination address (reordered)
   my $dest_addr_type = ""; # Holds the type of destination address
   my $src_addr       = "";
   my $type_len_field = "";
   my $data_field     = "";
   my $data_size      = "";
   my $pad_size       = "";
   my $pad            = "";
   my $fcs            = "";
   my $do_fcs         = "";
   my $frer_discard   = "false";
   my $frer_rtag_id   = "";
   my $frer_auto_dup  = 0;
   my $frer_inc_val   = 1;
   my $frer_loc       = 0;  # 0 = before vlan1, 1 = after vlan1, 2 = after vlan2
   
   $#type_len_field_arr=-1;
   %datamod_sofarr=();
   %datamod_typearr=();
   %datamod_l3arr=();
   %datamod_l4arr=();
   #print "New rx_frame command detected, so clearing down all arrays holding data associated with previous...\n";


   # This while statement stores all the lines referring to the Rx frame in an
   # array @command.
   while (!($command[$i - 1] =~ /^\s*fcs/)) {
      $command[$i] = <TESTCASE>;
      chop($command[$i]);             # remove carriage return
      $command[$i] =~ s/--.*//;       # ignore comments
      $command[$i] =~ tr/A-Z/a-z/;    # make all lower case
      ++$i;
   }


   # This first for-loop cycles through each frame that is to be generated
   for ($cur_frame_idx = 0; $cur_frame_idx < $num_of_frames; ++$cur_frame_idx) {
   
      my @src_addr_array;       # Hold collection of addresses for randomisation.
          $#src_addr_array=-1;  # Zero it
      my $min_payload_sz = 92;
      my $frame_header   = "";
      $#vlan1_field_array= -1;# empty array
      $#vlan2_field_array= -1;# empty array
      $#vlan1_type_array= -1;# empty array
      $#vlan2_type_array= -1;# empty array

      $rx_data_start_add = "";
      $rx_do_descr_acc = 1;
      # The next for-loop cycles through each testcase line of the Rx frame
      for (my $j = 0; $j < ($#command + 1); ++$j) {


         # PREAMBLE and SFD
         ###################
         if ($command[$j] =~ /^\s*preamble_size/) {

            $preamble_size = get_line_data($command[$j]);

            # If $preamble_size contains an "-", then the size is to be a random
            # number within that range
            if ($preamble_size =~ /^\s*\w*\d*-/) {
               ($min_size, $max_size) = get_range($preamble_size);
            }

            else {
               $min_size = $preamble_size;
               $max_size = $preamble_size;
            }

            # Call function to generate a preamble field
            $preamble = generate_field($min_size, $max_size, 5, "byte");

            # Set the SFD value
            $sfd = "d5";
         }

         # Choose whether to have occasional resource errors
         elsif ($command[$j] =~ /^\s*resource_err/) {
            $resource_err = get_line_data($command[$j]);
            if ($resource_err =~ /^\s*\w*(\d)/) {
              $resource_err = $1;}
         }

         # Generate interrupts, or not
         elsif ($command[$j] =~ /^\s*auto_gen_int/) {
           $rx_gen_int_in = get_line_data($command[$j]);
           if ($rx_gen_int_in =~ /^\s*\w*(\d)/) {
              $rx_gen_int_in = $1;}
         }

         # Generate Descriptor accesses
         # Set this low to avoid generating any descriptor accesses
         elsif ($command[$j] =~ /^\s*do_descr_acc/) {
           $rx_do_descr_acc = get_line_data($command[$j]);
           if ($rx_do_descr_acc =~ /^\s*\w*(\d)/) {
              $rx_do_descr_acc = $1;}
         }

         # Set this to define explicitly where the start address of the data buffer should be
         # Dont add this if you want it to be randomly generated in descriptor rd's
         elsif ($command[$j] =~ /^\s*data_start_add/) {
           $rx_data_start_add = get_line_data($command[$j]);
           if ($rx_data_start_add =~ /^\s*\w*(\d\d\d\d\d\d\d\d)/) {
              $rx_data_start_add = $1;}
         }

         elsif ($command[$j] =~ /^\s*reset_descr_to_base\s+1/ && $first_frame) {
           $rx_pointer[0] = hex ($rx_q_pointer[0]);
           $rx_pointer[1] = hex ($rx_q_pointer[1]);
           $rx_pointer[2] = hex ($rx_q_pointer[2]);
           $rx_pointer[3] = hex ($rx_q_pointer[3]);
           $rx_pointer[4] = hex ($rx_q_pointer[4]);
           $rx_pointer[5] = hex ($rx_q_pointer[5]);
           $rx_pointer[6] = hex ($rx_q_pointer[6]);
           $rx_pointer[7] = hex ($rx_q_pointer[7]);
           $rx_pointer[8] = hex ($rx_q_pointer[8]);
           $rx_pointer[9] = hex ($rx_q_pointer[9]);
           $rx_pointer[10] = hex ($rx_q_pointer[10]);
           $rx_pointer[11] = hex ($rx_q_pointer[11]);
           $rx_pointer[12] = hex ($rx_q_pointer[12]);
           $rx_pointer[13] = hex ($rx_q_pointer[13]);
           $rx_pointer[14] = hex ($rx_q_pointer[14]);
           $rx_pointer[15] = hex ($rx_q_pointer[15]);
         }


         # DEST_ADDR
         ############
         elsif ($command[$j] =~ /^\s*dest_addr/) {

            $dest_addr = get_line_data($command[$j]);

            # If $dest_addr contains the word "random", then change its
            # contents to a random string generated by "generate_field"
            if ($dest_addr =~ /^\s*\w*\d*random/) {
               $dest_addr_type = "random";
               $dest_addr = generate_field($addr_size, $addr_size,
                                           "random", "nibble");
               $frame_valid = "false";
            }
            elsif ($dest_addr =~ /^\s*\w*\d*unicast/) {
               $dest_addr_type = "unicast";
               $specific_addr = get_random_address("unicast");
               $dest_addr = reorder_string($specific_addr);
               $frame_valid = "true";
            }
            elsif ($dest_addr =~ /^\s*\w*\d*multicast/) {
               $dest_addr_type = "multicast";
               $specific_addr  = get_random_address("multicast");
               $dest_addr      = reorder_string($specific_addr);
               $frame_valid = "true";
            }
            elsif ($dest_addr =~ /^\s*\w*\d*broadcast/) {
               $dest_addr_type = "broadcast";
               $dest_addr = "ffffffffffff";
               $frame_valid = "true";
            }
            elsif ($dest_addr =~ /^\s*\w*\d*copy_all/) {
               $dest_addr_type = "random";
               $dest_addr = generate_field($addr_size, $addr_size,
                                           "random", "nibble");
               $frame_valid = "true";
            }
         }


         # SRC_ADDR
         ###########
         elsif ($command[$j] =~ /^\s*src_addr/) {

            $src_addr = get_line_data($command[$j]);

            # If $src_addr contains the word "random", then change its
            # contents to a random string generated by "generate_field"
            if ($src_addr =~ /^\s*\w*\d*random/) {
               $src_addr = generate_field($addr_size, $addr_size,
                                          "random", "nibble")
            }
            push (@src_addr_array,$src_addr);
         }


         # TYPE_LEN_FIELD
         ################
         elsif ($command[$j] =~ /^\s*type_len_field/) {

            $temp = get_line_data($command[$j]);


            # If $type_len_field contains the word "random", then change its
            # contents to a random string generated by "generate_field"
            if ($temp =~ /^\s*\w*\d*random/) {
               $temp = generate_field($tlf_size, $tlf_size,
                                      "random", "nibble")
            }

            if ($temp !~ /^\s*\w*[,\w]+/) {
              print "\n\nTEST TRANSLATION ERROR : every type you want randomly selected needs to be specified using the `type_len_field` command sepearated by commas, not \"$temp\"\n\n\n";
              exit;
            }
            @type_len_field_arr = split(/,/,$temp); #Extract the data fields


         }

         # BUFFER_SIZE_FIELD
         ################
         elsif ($command[$j] =~ /^\s*buffer_size/) {

            $buffer_size = get_line_data($command[$j]);

         }


         # NUM OF DMA QUEUES
         ###################
         elsif ($command[$j] =~ /^\s*num_dma_queues/) {
            $num_dma_queues = get_line_data($command[$j]);
            if ($num_dma_queues =~ /^\s*take_from_cfg\s*/) {
              $num_dma_queues = $cfg_num_dma_queues; 
            }
            if (($num_dma_queues > 16)|($num_dma_queues == 0)){ print "\n\nnum_dma_queues must be <=16 and >0\n\n";exit}
         }

         # Data Validation
         ################
         elsif ($command[$j] =~ /^\s*data_check/) {

            $data_check = get_line_data($command[$j]);

         }

         # Include DMA data in traffic
         ################
         elsif ($command[$j] =~ /^\s*includerxdma/) {

            $includerxdma = get_line_data($command[$j]);

         }

         # Include RXD data in traffic
         ################
         elsif ($command[$j] =~ /^\s*includerxd/) {

            $includerxd = get_line_data($command[$j]);

         }
         # FRER Redundancy Tag FIELD
         elsif ($command[$j] =~ /^\s*frer_rtag_en/) {

            $frer_rtag_id = get_line_data($command[$j]);
            if ($frer_rtag_id =~ /^\s*\w*\d*random/) {$frer_rtag_id = sprintf "%01x", (int(rand(2)));}
            if ($frer_rtag_id == 1) {
              $frer_rtag_id = $frer_rtag_type;
            }
            else {
              $frer_rtag_id = "";
            }
         }
         elsif ($command[$j] =~ /^\s*frer_rtag_seqnum/) {
           $frer_rtag_seqnum  = get_line_data($command[$j]);
           if ($frer_rtag_seqnum eq "random") { 
            # If we are randomising, we want to make sure that it isn't equal to the last 
            # or one more than previous just to help with stats.
            my $loop_done   = 0;
            my $prev_seq_p1 = sprintf "%04x",(((hex $frer_rtag_seqnum_last) + 1) & 0xffff);
            while ($loop_done == 0) {
              $frer_rtag_seqnum = sprintf "%04x", (int(rand(2**16)));
              if (($frer_rtag_seqnum ne $frer_rtag_seqnum_last) and ($frer_rtag_seqnum ne $prev_seq_p1)) {
                $loop_done   = 1;
              }
            }
           } elsif ($frer_rtag_seqnum eq "dup") { $frer_rtag_seqnum = $frer_rtag_seqnum_last; }
           elsif ($frer_rtag_seqnum eq "inc") { 
#            print "Incrementing seqnum from $frer_rtag_seqnum_last\n";
            $frer_rtag_seqnum = sprintf "%04x",(((hex $frer_rtag_seqnum_last) + $frer_inc_val) & 0xffff);
#            print "New seq num is $frer_rtag_seqnum\n";
          }
        }
         elsif ($command[$j] =~ /^\s*frer_rtag_type/) {
              $frer_rtag_type = get_line_data($command[$j]);
              if ($frer_rtag_type eq "random") {$frer_rtag_type = sprintf "%04x", (int(rand(2**16)));}
        }
         elsif ($command[$j] =~ /^\s*frer_strip_rtag/) {
              $strip_rtag = get_line_data($command[$j]);
        }
         elsif ($command[$j] =~ /^\s*frer_discard/) {
              $frer_discard = get_line_data($command[$j]);
#              print "Setting frer_discard to $frer_discard\n";
        }
         elsif ($command[$j] =~ /^\s*frer_auto_dup/) {
              $frer_auto_dup = get_line_data($command[$j]);
        }
         elsif ($command[$j] =~ /^\s*frer_inc_val/) {
              $frer_inc_val = get_line_data($command[$j]);
        }
        elsif ($command[$j] =~ /^\s*frer_loc/) {
           $frer_loc  = get_line_data($command[$j]);
        }
         
         # VLAN1 FIELD
         ################
         elsif ($command[$j] =~ /^\s*vlan1_en/) {
           $vlan1_frame = get_line_data($command[$j]);
           if ($vlan1_frame =~ /^\s*\w*\d*random/) {$vlan1_frame = sprintf "%01x", (int(rand(2)));}
           if ($vlan1_frame == 1) {$vlan1_frame = 8100;}
           if ($vlan1_frame == 0) {$vlan1_frame = "";}
           #print "setting vlan1_frame to $vlan1_frame\n";
         }
         elsif ($command[$j] =~ /^\s*vlan1_field/) {
           push (@vlan1_field_array,get_line_data($command[$j]));
         }
         elsif ($command[$j] =~ /^\s*vlan1_type/) {
           push (@vlan1_type_array,get_line_data($command[$j]));
           if ($vlan1_frame eq "random") {push (@vlan1_type_array, sprintf "%04x", (int(rand(2**16))));}
           $vlan1_frame = $vlan1_type_array[int(rand($#vlan1_type_array+1))];
         }

         # VLAN2 FIELD
         ################
         elsif ($command[$j] =~ /^\s*vlan2_en/) {

            $vlan2_frame = get_line_data($command[$j]);
            if ($vlan2_frame =~ /^\s*\w*\d*random/) {$vlan2_frame = sprintf "%01x", (int(rand(2)));}
            if ($vlan2_frame == 1) {$vlan2_frame = 8100;}
            if ($vlan2_frame == 0) {$vlan2_frame = "";}
         }
         elsif ($command[$j] =~ /^\s*vlan2_field/) {
           push (@vlan2_field_array,get_line_data($command[$j]));
         }
         elsif ($command[$j] =~ /^\s*vlan2_type/) {
           push (@vlan2_type_array,get_line_data($command[$j]));
           if ($vlan2_frame eq "random") {push (@vlan2_type_array, sprintf "%04x", (int(rand(2**16))));}
           $vlan2_frame = $vlan2_type_array[int(rand($#vlan2_type_array+1))];
         }

         # Debug info for L3L4 packet generation
         #########################
         elsif ($command[$j] =~ /^\s*debug_print_frame/) {
            $debug_print_frame = get_line_data($command[$j]);
         }

         # Generation of level3 fields (IPv4 / IPv6)
         #########################
         elsif ($command[$j] =~ /^\s*ipv4_en/) {
            $ipv4_frame = get_line_data($command[$j]);
            if ($ipv4_frame =~ /^\s*\w*\d*random/) {$ipv4_frame = int(rand(2));}
         }
         elsif ($command[$j] =~ /^\s*ipv6_en/) {
            $ipv6_frame = get_line_data($command[$j]);
            if ($ipv6_frame =~ /^\s*\w*\d*random/) {$ipv6_frame = int(rand(2));}
         }

         # IPv4 Specifics
         elsif ($command[$j] =~ /^\s*num_ipv4_options/) {
          #Maximum number of options = 10
            $num_ipv4_options = get_line_data($command[$j]);
            if ($num_ipv4_options =~ /^\s*\w*\d*random/) {$num_ipv4_options = int(rand(11));}
            if ($num_ipv4_options>10) {print "\n\nCannot have >10 IPv4 options. The testcase has a value of $num_ipv4_options\n";exit;}
         }
         elsif ($command[$j] =~ /^\s*bad_ip_csum/) {
          #Maximum number of options = 10
            $bad_ip_csum = get_line_data($command[$j]);
            if ($bad_ip_csum =~ /^\s*\w*\d*random/) {$bad_ip_csum = int(rand(2));}
            if ($bad_ip_csum>1) {print "\n\nbad_ip_csum must be 0 or 1(BOOLEAN)\n";exit;}
         }

         # IPv6 Specifics
         elsif ($command[$j] =~ /^\s*num_ipv6_hdrs/) {
            $num_ipv6_hdrs = get_line_data($command[$j]);
            if ($num_ipv6_hdrs =~ /^\s*\w*\d*random/) {$num_ipv6_hdrs = int(rand(11));}
            if ($num_ipv6_hdrs>16) {print "\n\nCannot have >16 IPv4 options. The testcase has a value of $num_ipv6_hdrs\n";exit;}
         }

         elsif ($command[$j] =~ /^\s*use_dest_hdrs/) {
            $use_dest_hdrs = get_line_data($command[$j]);
            if ($use_dest_hdrs =~ /^\s*\w*\d*random/) {$use_dest_hdrs = int(rand(2));}
            if ($use_dest_hdrs>1) {print "\n\nuse_dest_hdrs must be a value of either 0 or 1 (BOOLEAN)\n";exit;}
         }

         elsif ($command[$j] =~ /^\s*use_hop_hdrs/) {
            $use_hop_hdrs = get_line_data($command[$j]);
            if ($use_hop_hdrs =~ /^\s*\w*\d*random/) {$use_hop_hdrs = int(rand(2));}
            if ($use_hop_hdrs>1) {print "\n\nuse_hop_hdrs must be a value of either 0 or 1 (BOOLEAN)\n";exit;}
         }

         elsif ($command[$j] =~ /^\s*use_route_hdrs/) {
            $use_route_hdrs = get_line_data($command[$j]);
            if ($use_route_hdrs =~ /^\s*\w*\d*random/) {$use_route_hdrs = int(rand(2));}
            if ($use_route_hdrs>1) {print "\n\nuse_route_hdrs must be a value of either 0 or 1 (BOOLEAN)\n";exit;}
         }

         elsif ($command[$j] =~ /^\s*use_frag_hdrs/) {
            $use_frag_hdrs = get_line_data($command[$j]);
            if ($use_frag_hdrs =~ /^\s*\w*\d*random/) {$use_frag_hdrs = int(rand(2));}
            if ($use_frag_hdrs>1) {print "\n\nuse_frag_hdrs must be a value of either 0 or 1 (BOOLEAN)\n";exit;}
         }
         elsif ($command[$j] =~ /^\s*ipv6_tc/) {
            push (@ipv6_tc_array,get_line_data($command[$j]));
         }



         # Generation of level4 fields (UDP / TCP)
         #########################
         elsif ($command[$j] =~ /^\s*udp_en/) {
            $udp_frame = get_line_data($command[$j]);
            if ($udp_frame =~ /^\s*\w*\d*random/) {$udp_frame = int(rand(2));}
            if ($udp_frame>1) {print "\n\nudp_frame must be a value of either 0 or 1 (BOOLEAN)\n";exit;}
         }
         elsif ($command[$j] =~ /^\s*tcp_en/) {
            $tcp_frame = get_line_data($command[$j]);
            if ($tcp_frame =~ /^\s*\w*\d*random/) {$tcp_frame = int(rand(2));}
            if ($tcp_frame>1) {print "\n\ntcp_en must be a value of either 0 or 1 (BOOLEAN)\n";exit;}
         }
         elsif ($command[$j] =~ /^\s*ipv4_tos/) {
            push (@ipv4_tos_array,get_line_data($command[$j]))
         }

         # UDP Field Definition
         #########################
         elsif ($command[$j] =~ /^\s*udp_sport/) {
            push (@udp_sport_array,get_line_data($command[$j]));
         }
         elsif ($command[$j] =~ /^\s*udp_dport/) {
            push (@udp_dport_array,get_line_data($command[$j]));
         }

         # Datafield overwrite
         #########################
         elsif ($command[$j] =~ /^\s*data_byte_sofind/) {
            $datamod = get_line_data($command[$j]);
            #print "\n\ndata_byte_sofind $datamod\n";
            if ($datamod !~ /^\s*\w*[,\w]+@/) {
              print "\n\nTEST TRANSLATION ERROR : `data_byte_sofind` command needs to be in the format DATA_TO_MOD,DATA_TO_MOD,DATA_TO_MOD\@INDEX, not \"$datamod\"\n\n\n";
              exit;
            }
            @temp_array = split(/@/,$datamod);
            $index  = $temp_array[1]; #Extract the index
            @temp_array = split(/\,/,$temp_array[0]); #Extract the data fields

            foreach (@temp_array) {$datamod_sofarr{$index} = $_;}
         }

         elsif ($command[$j] =~ /^\s*data_byte_typeind/) {
            $datamod = get_line_data($command[$j]);
            if ($datamod !~ /^\s*\w*[,\w]+@/) {
              print "\n\nTEST TRANSLATION ERROR : `data_byte_typeind` command needs to be in the format DATA_TO_MOD,DATA_TO_MOD,DATA_TO_MOD\@INDEX, not \"$datamod\"\n\n\n";
              exit;
            }
            @temp_array = split(/@/,$datamod);
            $index  = $temp_array[1]; #Extract the index
            @temp_array = split(/\,/,$temp_array[0]); #Extract the data fields

            foreach (@temp_array) {$datamod_typearr{$index} = $_;}
         }

         elsif ($command[$j] =~ /^\s*data_byte_l3ind/) {
            $datamod = get_line_data($command[$j]);
            if ($datamod !~ /^\s*\w*[,\w]+@/) {
              print "\n\nTEST TRANSLATION ERROR : `data_byte_l3ind` command needs to be in the format DATA_TO_MOD,DATA_TO_MOD,DATA_TO_MOD\@INDEX, not \"$datamod\"\n\n\n";
              exit;
            }
            @temp_array = split(/@/,$datamod);
            $index  = $temp_array[1]; #Extract the index
            @temp_array = split(/\,/,$temp_array[0]); #Extract the data fields

            foreach (@temp_array) {$datamod_l3arr{$index} = $_;}
         }

         elsif ($command[$j] =~ /^\s*data_byte_l4ind/) {
            $datamod = get_line_data($command[$j]);
            if ($datamod !~ /^\s*\w*[,\w]+@/) {
              print "\n\nTEST TRANSLATION ERROR : `data_byte_l4ind` command needs to be in the format DATA_TO_MOD,DATA_TO_MOD,DATA_TO_MOD\@INDEX, not \"$datamod\"\n\n\n";
              exit;
            }
            @temp_array = split(/@/,$datamod);
            $index  = $temp_array[1]; #Extract the index
            @temp_array = split(/\,/,$temp_array[0]); #Extract the data fields

            foreach (@temp_array) {$datamod_l4arr{$index} = $_;}
         }


         # DATA_SIZE (in Bytes - SRC ADD, DEST ADD, TYPE, IPV4/IPV6, UDP, VLAN headers are all in addition to this"
         #############
         elsif ($command[$j] =~ /^\s*data_size/) {

            $data_size = get_line_data($command[$j]);

            my $rx_sram_size;
            
            if ($width32)  {$rx_sram_size = (2**$cfg_rx_sram_depth) * 4;}
            if ($width64)  {$rx_sram_size = (2**$cfg_rx_sram_depth) * 8;}
            if ($width128) {$rx_sram_size = (2**$cfg_rx_sram_depth) * 16;}
            
            if ($en_rx_cutthru) {
              $rx_max_size_frame = 2*($rx_sram_size / 3);
            } else {
              $rx_max_size_frame = ($rx_sram_size / 2) - 100;
            }
            
            # Leave enough space for IP/UDP - just 200 bytes should be enough
            if    ($jumbo == 1 && ($rx_max_size_frame > $rx_jumbo_max_len_reg)) {$rx_max_size_frame = ($rx_jumbo_max_len_reg - (200*int ($udp_frame | $ipv4_frame | $ipv6_frame)));}
            elsif ($jumbo == 0 && ($rx_max_size_frame > 1500))                  {$rx_max_size_frame = (1500                  - (200*int ($udp_frame | $ipv4_frame | $ipv6_frame)));}

            # If $data_size contains an "-", then the size is to be a random
            # number within that range
            if ($data_size =~ /^\s*(\d+)-([a-zA-Z0-9_]+)/) {
               $min_data_size = $1;
               if ($2 ne "take_from_cfg") {
                 $max_data_size = $2;
               } else {
                 $max_data_size = $rx_max_size_frame;
               }
            }
            # If $data_size contains an "x", then the size is to be a multiple
            # number within that range
            elsif ($data_size =~ /^\s*(\d+)x([a-zA-Z0-9_]+)/) {
               $min_data_size = $1;
               if ($2 ne "take_from_cfg") {
                 $max_data_size = $2;
               } else {
                 $max_data_size = $rx_max_size_frame;
               }
               $min_data_size = $min_data_size*$max_data_size;
               $max_data_size = $min_data_size;
#               print "\n\nSetting datasize to $min_data_size\n";
            }
            else {
               if ($data_size ne "take_from_cfg") {
                 $min_data_size = $data_size;
                 $max_data_size = $data_size;
               } else {
                 $min_data_size = $rx_max_size_frame;
                 $max_data_size = $rx_max_size_frame;
               }
            }
            if ($max_data_size < $min_data_size) {$min_data_size = $max_data_size;}
#            print "\nSetting frame size to $min_data_size $max_data_size\n";
         }


         # DATA and PAD
         ###############
         elsif ($command[$j] =~ /^\s*data\s+/) {

            # If the previous line was data_size, reset $data_field
            if ( $command[$j - 1] =~ /^\s*data_size/ ) {
               $data_field = "";
            }

            # Data can be entered on one or more lines.  Collect all the
            # data_field together, before dealing with it.
            $data_field = $data_field.get_line_data($command[$j]);


            # Only process data field if the field size has been received
            if ($max_data_size ne '' or $min_data_size ne '') {

               # If there are no more command lines with data from the data field
               if ( !($command[$j + 1] =~ /^\s*data\s+/) ) {

                  # If $data_field contains the word "random", then change its
                  # contents to a random string generated by "generate_field".
                  if ($data_field =~ /^\s*\w*\d*random/) {
                     $data_field = generate_field($min_data_size,
                                                  $max_data_size,
                                                  "random",
                                                  "byte");
                    $data_size = (length $data_field) /2 ;
                    #printf ("actual_data_size = %s\n", length $data_field);
                  }
               }

            }

            else {
               print "ERROR:  No frame_size received\n";
            }

         }


         # FCS
         ######
         elsif ($command[$j] =~ /^\s*fcs/) {

        #    printf "Payload (size %0d) is %s\n",$data_size,$data_field;
            $fcs = get_line_data($command[$j]);
            # If $fcs field contains the word "bad", then change its
            # contents to a random string generated by "generate_field".


            # For IP type frames, we can only have IPv4 OR IPv6, not both!
            ################
            $ipv4_frame_local = $ipv4_frame;
            if ($ipv6_frame == 1 && $ipv4_frame == 1) {$ipv6_frame_local = int(rand(2));} else {$ipv6_frame_local = $ipv6_frame;}
            if ($ipv6_frame_local == 1) {$ipv4_frame_local = 0;}

            # For level4 frames, we can only have icmp, tcp or udp
            ################
            $udp_frame_local = $udp_frame;
            if ($tcp_frame == 1 && $udp_frame == 1) {$tcp_frame_local = int(rand(2));} else {$tcp_frame_local = $tcp_frame;}
            if ($tcp_frame_local == 1) {$udp_frame_local = 0;}
            if (($tcp_frame_local == 1 || $udp_frame_local == 1) && $icmp_frame == 1) {$icmp_frame_local = int(rand(2));} else {$icmp_frame_local = $icmp_frame};
            if ($icmp_frame_local == 1) {$tcp_frame_local = 0;$udp_frame_local = 0;} 

            if ($udp_frame_local == 1) {
              if ($udp_sport_array[0] =~ /^\s*\w*\d*random/) {$udp_sport_array[0] = sprintf "%04x", int(rand(2**16));}
              if (hex($udp_sport_array[0])>(2**16)) {print "\n\nudp_sport must be a 4 digit hex value\n";exit;}
              if ($udp_dport_array[0] =~ /^\s*\w*\d*random/) {$udp_dport_array[0] = sprintf "%04x", int(rand(2**16));}
              if (hex($udp_dport_array[0])>(2**16)) {print "\n\nudp_dport must be a 4 digit hex value\n";exit;}
            }

            my $udp_dport;
            my $ipv4_tos;
            my $ipv6_tc;

            # Choose a type_len_field
            $type_len_field = $type_len_field_arr[int(rand($#type_len_field_arr+1))];

            ($data_field,$type_len_field,$udp_dport,$ipv4_tos,$ipv6_tc,$l3_hdr_index,$l4_hdr_index) = gen_l3l4_frames (
              $debug_print_frame,
              $data_field,
              $data_size,
              $cur_frame_idx,
              $type_len_field,

              $ipv4_frame_local,
                $num_ipv4_options,
                $bad_ip_csum,
                # All other IPv4 fields are randomized(if possible)

              $ipv6_frame_local,
                $num_ipv6_hdrs,
                $use_dest_hdrs,
                $use_hop_hdrs,
                $use_route_hdrs,
                $use_frag_hdrs,
                # All other IPv6 fields are randomized(if possible)

              $udp_frame_local,
                $bad_udp_csum,
                # All other UDP fields are randomized(if possible)

              $tcp_frame_local,
                $bad_tcp_csum,
                # All other TCP fields are randomized(if possible)

              $icmp_frame_local
            );

        #    printf "Data Field is %s\n",$data_field;

            # Insert zero padding to make the frame at least 128 nibbles
            if ($frer_rtag_id eq "") {
              $frer_rtag_seqnum = "";
            } else {
#              print "Using sequence number $frer_rtag_seqnum\n";
              $frer_rtag_seqnum_last = $frer_rtag_seqnum;
              if ($frer_6b_tag == 1) {
                # Pad 2-byte sequence number with a random value.
                my $frer_rtag_seqnum_pad = sprintf "%04x", (int(rand(2**16)));
                $frer_rtag_seqnum = $frer_rtag_seqnum_pad . $frer_rtag_seqnum;
                $min_payload_sz -= 8; # Take 4-bytes off the minimum payload size
              }
            }
            
            if ($vlan1_frame eq "") {
              $vlan1_field = "";
            } else {
              if ($#vlan1_field_array == -1) {$vlan1_field = "random";} # randomize vlan fields if empty ...
              else                           {$vlan1_field = $vlan1_field_array[int(rand($#vlan1_field_array+1))];}
              if ($vlan1_field eq "random")  {$vlan1_field = sprintf "%04x", int(rand(2**16));}

              # Ensure the CFI bit of the VLAN field is LOW - The GEM does not support CFI bit = 1
              #print "VLAN Field is $vlan1_field\n\n";
              $vlan1_field =  sprintf "%04x", (hex($vlan1_field) & hex('efff'));
            }

            if ($vlan2_frame eq "") {
              $vlan2_field = "";
            } else {
              if ($#vlan2_field_array == -1) {$vlan2_field = "random";} # randomize vlan fields if empty ...
              else                           {$vlan2_field = $vlan2_field_array[int(rand($#vlan2_field_array+1))];}
              if ($vlan2_field eq "random")  {$vlan2_field = sprintf "%04x", int(rand(2**16));}
              $vlan2_field =  sprintf "%04x", (hex($vlan2_field) & hex('efff'));
            }

            # Select source address
            if ($#src_addr_array ==-1) {
               $src_addr = generate_field($addr_size, $addr_size,
                                          "random", "nibble");
            } else {
#               print "Randomising source address from @src_addr_array\n";
               $src_addr = $src_addr_array[int(rand($#src_addr_array+1))];
#               print "Using src_addr $src_addr\n";
#               print "Out of $src_addr_array[0] and $src_addr_array[1] array length is $#src_addr_array\n";
            }
            
            # TODO - if 802.1Q tagged, payload can reduce by 4 bytes...
#            if ($vlan1_frame ne "") { $min_payload_sz -= 8; }
            
            my $data_len = length($data_field);
            if ($data_len < $min_payload_sz) {
              $pad = ("0" x ($min_payload_sz - $data_len));
#              print "Min payload size is $min_payload_sz and data length is $data_len using pad 1 $pad\n";
            } else {
              $pad = "";
            }
            
            if ($fcs  =~ /^\s*\w*\d*random/) {
              $do_fcs = int(rand(2));
              if ($do_fcs == 0) {$do_fcs = "bad";} else {$do_fcs = "good";}
            } elsif ($fcs  =~ /^\s*\w*\d*bad/) {
              $do_fcs = "bad";
            } else {$do_fcs = "good";}

            if ($frer_loc eq "random") {
              if ( $vlan2_frame ne "" ) {
                $frer_loc = int(rand(3)); # Has vlan1 and vlan2 so random 0-2
              } else {
                $frer_loc = int(rand(2)); # Has vlan1 only so random 0-1
              }
            }
            $frame_header = $preamble
                        .$sfd
                        .$dest_addr
                        .$src_addr;
            if ( $frer_loc == 0 ) {
              $frame_header = $frame_header
                        .$frer_rtag_id
                        .$frer_rtag_seqnum
                        .$vlan1_frame
                        .$vlan1_field
                        .$vlan2_frame
                        .$vlan2_field
                        .$type_len_field;
            } elsif ( $frer_loc == 1 ) {
              $frame_header = $frame_header
                        .$vlan1_frame
                        .$vlan1_field
                        .$frer_rtag_id
                        .$frer_rtag_seqnum
                        .$vlan2_frame
                        .$vlan2_field
                        .$type_len_field;
            } else {
              $frame_header = $frame_header
                        .$vlan1_frame
                        .$vlan1_field
                        .$vlan2_frame
                        .$vlan2_field
                        .$frer_rtag_id
                        .$frer_rtag_seqnum
                        .$type_len_field;
            }
            

            if ($do_fcs =~ /^\s*\w*\d*bad/) {
               $frame_valid = "false";
               $do_fcs = generate_field($fcs_size, $fcs_size, "random", "nibble");
               $frame =  $frame_header
                        .$data_field
                        .$pad
                        .$do_fcs;
            }

            # If a good FCS is wanted, then call a subroutine to calculate it
            # "gen_crc" should be passed the full frame minus the crc.  It will
            # then return the frame, with the FCS field and necessary padding.
            else {
              #print "Premable is $preamble, sfd is $sfd\n";
               $frame =  $frame_header
                        .$data_field
                        .$pad
                        ."gggggggg";

                #print "Old Frame is  $frame\n";

                # The frame can be edited using the command data_byte_*_ind, where * can be sof (start of frame), type (byte after ethertype), l3 (byte after L3 header) or l4
                # I dont think L4 works for TCP frames yet ...

                #while (my ($key, $value) = each(%datamod_sofarr)){ print "$key => $value";}
                $last_index = -1;
                $newval = 0;
                $data_to_mod = 0;
                $repeatcnt = 2;
                foreach $value (sort {$datamod_sofarr{$a} cmp $datamod_sofarr{$b} } # sort the values
                        keys %datamod_sofarr)
                {
                  #print "offset = $value, data to replace =$datamod_sofarr{$value}\n";
                  if ($newval == 0){$data_to_mod = $datamod_sofarr{$value};}
                  elsif ($last_index == $value) { # If the last index is the same as this index
                    if (int(rand($repeatcnt)) == 0) {
                      #print "Was going to use $data_to_mod, but will use $value instead ...";
                      $data_to_mod = $datamod_sofarr{$value};
                    }
                    $repeatcnt++;
                  } elsif ($newval == 1) {
                    $repeatcnt = 2;
                    #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble) + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + 4));
                    #print "new frame is  $frame\n\n";
                    $data_to_mod = $datamod_sofarr{$value};
                  }
                  $newval = 1;
                  $last_index =$value;
                }
                if ($newval == 1) {
                  #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                  $frame = substr("$frame",0,($last_index*2 + length($preamble) + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + 4));
                  #print "new frame is  $frame\n\n";
                }

                # Repeat for index starting after ethertype ...
                $last_index = -1;
                $newval = 0;
                $data_to_mod = 0;
                $repeatcnt = 2;
                $indextotype = 28;
                if ($vlan1_frame ne "") {
                  if (hex($vlan1_frame) == hex(8100)) {$indextotype += 8}; # Add 4 bytes if the frame is VLAN tagged, so that the index is correctly mapped
                }
                if ($vlan2_frame ne "") {
                  $indextotype += 8; # Add 4 bytes if the frame is VLAN tagged, so that the index is correctly mapped
                }
                if ($frer_rtag_id ne "") {
                  $indextotype += 8; # Add 4 bytes if the frame has redundancy tag, so that the index is correctly mapped
                }
                foreach $value (sort {$datamod_typearr{$a} cmp $datamod_typearr{$b} } # sort the values
                        keys %datamod_typearr)
                {
                  if ($newval == 0){$data_to_mod = $datamod_typearr{$value};}
                  elsif ($last_index == $value) { # If the last index is the same as this index
                    if (int(rand($repeatcnt)) == 0) {$data_to_mod = $datamod_typearr{$value};}
                    $repeatcnt++;
                  } elsif ($newval == 1) {
                    $repeatcnt = 2;
                   # print "adding $data_to_mod to index $last_index $preamble $indextotype\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble)+$indextotype + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + $indextotype + 4));
                   # print "new frame is  $frame\n\n";
                    $data_to_mod = $datamod_typearr{$value};
                  }
                  $newval = 1;
                  $last_index =$value;
                }
                if ($newval == 1) {
                  #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble)+$indextotype + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + $indextotype + 4));
                  #print "new frame is  $frame\n\n";
                }

                # Repeat for index starting after L3 header ...
                $last_index = -1;
                $newval = 0;
                $data_to_mod = 0;
                $repeatcnt = 2;
                foreach $value (sort {$datamod_l3arr{$a} cmp $datamod_l3arr{$b} } # sort the values
                        keys %datamod_l3arr)
                {
                  if ($newval == 0){$data_to_mod = $datamod_l3arr{$value};}
                  elsif ($last_index == $value) { # If the last index is the same as this index
                    if (int(rand($repeatcnt)) == 0) {$data_to_mod = $datamod_l3arr{$value};}
                    $repeatcnt++;
                  } elsif ($newval == 1) {
                    $repeatcnt = 2;
                  #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble)+$indextotype + $l3_hdr_index + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + $indextotype + $l3_hdr_index + 4));
                  #print "new frame is  $frame\n\n";
                    $data_to_mod = $datamod_l3arr{$value};
                  }
                  $newval = 1;
                  $last_index = $value;
                }
                if ($newval == 1) {
                  #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble)+$indextotype + $l3_hdr_index + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + $indextotype + $l3_hdr_index + 4));
                  #print "new frame is  $frame\n\n";
                }

                # Repeat for index starting after L4 header ...
                $last_index = -1;
                $newval = 0;
                $data_to_mod = 0;
                $repeatcnt = 2;
                foreach $value (sort {$datamod_l4arr{$a} cmp $datamod_l4arr{$b} } # sort the values
                        keys %datamod_l4arr)
                {
                  if ($newval == 0){$data_to_mod = $datamod_l4arr{$value};}
                  elsif ($last_index == $value) { # If the last index is the same as this index
                    if (int(rand($repeatcnt)) == 0) {$data_to_mod = $datamod_l4arr{$value};}
                    $repeatcnt++;
                  } elsif ($newval == 1) {
                    $repeatcnt = 2;
                  #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble)+$indextotype + $l4_hdr_index + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + $indextotype + $l4_hdr_index + 4));
                  #print "new frame is  $frame\n\n";
                    $data_to_mod = $datamod_l4arr{$value};
                  }
                  $newval = 1;
                  $last_index = $value;
                }
                if ($newval == 1) {
                  #print "adding $data_to_mod to index $last_index\nold frame was $frame\n";
                    $frame = substr("$frame",0,($last_index*2 + length($preamble)+$indextotype + $l4_hdr_index + 2)) . $data_to_mod . substr("$frame",($last_index*2 + length($preamble) + $indextotype + $l4_hdr_index + 4));
                  #print "new frame is  $frame\n\n";
                }


               # Finally add the CRC ...
               ($frame,,) = gen_crc("$frame","0");
            }
            #print "new frame is  $frame\n\n";

            if ($pcs_loopback == 1 || $ext_loopback == 1) {
              $frame = shift (@tx_loopbacked_frame);  # Overwrite RX $frame
            }


            # Compare registers - extract the fields for comparing later on ...
            if ($#type2_compare0_reg >= 0) {
            for (my $num_type2_compare_regs = 0;$num_type2_compare_regs <= $#type2_compare0_reg; $num_type2_compare_regs++) {

              # Extract the fields from the screener reg ...
              my $comp_vlan_id_en    = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,5,1)) & hex('4')) >> 2; # bit 10 - compare_vlan_id
              my $comp_vlan_id_stag  = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,6,1)) & hex('8')) >> 3; # bit 7  - compare_vlan_id (ctag/stag select)
              my $comp_dont_use_mask = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,5,1)) & hex('2')) >> 1; # bit 9
              my $off_type           = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,5,2)) & hex('18')) >> 3; # bits 8:7
              my $off_val            = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,6,2)) & hex('7f')); # bits 6:0
              my $compare_val;
              my $mask_val;
              if ($comp_dont_use_mask) {
                 $compare_val = hex(substr("$type2_compare0_reg[$num_type2_compare_regs]" ,0,8)); # bits 31:0
              } else {
                 $compare_val = hex(substr("$type2_compare0_reg[$num_type2_compare_regs]" ,0,4)); # bits 31:16
                 $mask_val    = hex(substr("$type2_compare0_reg[$num_type2_compare_regs]" ,4,4)); # bits 15:0
                 $mask_val    = sprintf "%01x", $mask_val;
              }
              $compare_val = sprintf "%01x", $compare_val;
              #print "Comp Reg $num_type2_compare_regs, compare_val is $compare_val, mask_val is $mask_val, off type is $off_type, offset is $off_val";
              $off_val     = $off_val*2 + 2 + length($preamble);
              if ($comp_vlan_id_en) {
                # offset should be pointing to the first vlan if comparing against vlan
                # This is 14 bytes from the start - which is 28 nibbles
                 $off_val     = 2 + length($preamble) + 28;
              } else {    
                if ($off_type == 0) {
                   $off_val     = $off_val;
                } elsif ($off_type == 1) {
                   $off_val     = $off_val+$indextotype;
                } elsif ($off_type == 2) {
                   $off_val     = $off_val+$l3_hdr_index+$indextotype;
                } else {
                   #printf ",L3 index is $l3_hdr_index,L4 index is $l4_hdr_index";
                   $off_val     = $off_val+$l4_hdr_index+$indextotype;
                }
              }
              #printf ",%0d bytes of preamble, frame index = %0d\n",int(length($preamble)/2),$off_val;

              #print "Comp1 reg is $type2_compare1_reg[$num_type2_compare_regs],\n";
              #print "Frame is $frame\n";
              # Only check the frame if the offset is indexing a field within the frame *i.e. ignore an index that is out of range
              if (length($frame) >= $off_val) {
                if ($comp_dont_use_mask) {
                  $comp_field[$num_type2_compare_regs] = substr("$frame", $off_val, 8);
                } else {
                  $comp_field[$num_type2_compare_regs] = substr("$frame", $off_val, 4);
                }
                #print "Comp Field [$num_type2_compare_regs] for this frame is $comp_field[$num_type2_compare_regs]\n";
                #printf "premable is $preamble, length is %0d, comp_vlan_id_en is $comp_vlan_id_en, offset type $off_type, offset is %0d\n",(hex(length($preamble) / 2)), $off_val;
                # Switch the bytes of the extracted compare field.  This is because we want the bits [15:8] to be the byte that follows the byte in [7:0].
                my $temp_byte = substr("$comp_field[$num_type2_compare_regs]", 0, 2);
                if ($comp_dont_use_mask) {
                  my $temp_byte2 = substr("$comp_field[$num_type2_compare_regs]", 2, 2);
                  my $temp_byte3 = substr("$comp_field[$num_type2_compare_regs]", 4, 2);
                  $comp_field[$num_type2_compare_regs] = substr("$comp_field[$num_type2_compare_regs]", 6, 2) . $temp_byte3 . $temp_byte2 . $temp_byte;
                } else {
                  $comp_field[$num_type2_compare_regs] = substr("$comp_field[$num_type2_compare_regs]", 2, 2) . $temp_byte;
                }
                #print "Comp Field [$num_type2_compare_regs] for this frame is $comp_field[$num_type2_compare_regs]\n";
              } else {
                $comp_field[$num_type2_compare_regs] = "xx";
              }
            }
            }

            #printf "\nFrame(length = %0d) is $frame\n",int(length($frame)/2);
         }
      }


      # printf "\n\npreamble length = %d\n\n", length $preamble;

      # Store frame data for dma separately so we can strip the fcs for
      # strip fcs tests
      $frame_dma = $frame;
      
      # Strip RTag if necessary from DMA data
      if (($strip_rtag == 1) && ($frer_rtag_id ne "")) {
#        print "Frame is $frame\n";
        my $preamble_length = length $preamble;
#        print "Preamble length is $preamble_length\n";
        my $frer_rtag_start = $preamble_length + 2 + 12 + 12;
        if ( ($frer_loc > 0) and ($vlan1_frame ne "") ) {
          $frer_rtag_start += 8;
          if ( ($frer_loc == 2) and ($vlan2_frame ne "") ) {
            $frer_rtag_start += 8;
          }
        }
        
#        print "Extract from $frer_rtag_start\n";
        if ($frer_6b_tag == 1) {
          $frame_dma = substr($frame,0,$frer_rtag_start) . substr($frame,$frer_rtag_start+12);
        } else {
          $frame_dma = substr($frame,0,$frer_rtag_start) . substr($frame,$frer_rtag_start+8);
        }
#        print "New frame is $frame_dma\n";
      }
      
      if ($strip_fcs == 1) { # strip fcs
         for (my $i = 0; $i < 8; ++$i) {
            $fcs_data = $fcs_data . chop ($frame_dma)};
      }
      
      # Reverse the order of $frame, by transfering it to $frame_temp.
      my $temp = chop ($frame);
      while ($temp ne ' ' and $temp ne '') {
         $frame_temp = $frame_temp . $temp;
         $temp = chop ($frame);
      }

      # Reverse the order of $frame_dma, by transfering it to $frame_temp_dma.
      my $temp_dma = chop ($frame_dma);
      while ($temp_dma ne ' ' and $temp_dma ne '') {
         $frame_temp_dma = $frame_temp_dma . $temp_dma;
         $temp_dma = chop ($frame_dma);
      }

      if (($pcs_loopback == 0) && ($ext_loopback == 0)) {
        if ($first_frame == 1) {
          copy_to_rx_array ($control, $frame_temp);
        } else {
          copy_to_rx_array (6, $frame_temp); # Always add a small gap between packets
        }
        if ($frer_auto_dup  == 1) {
          copy_to_rx_array (6, $frame_temp); # Always add a small gap between packets
        }
      }


      my $replay_packet = 1;
      my $take_snapshot_frame = $frame_temp_dma;
      $first_frame = 0;
      $cnt_4byteword = 0;
      
      if (($frame_valid eq "true") and ($frer_discard eq "false")) {
#        print "\n\nGenerating frame DMA data\n\n";
         while ($replay_packet == 1) {
      #   print "replay_packet = $replay_packet\n";
         $frame_temp_dma =$take_snapshot_frame ;
         $replay_packet = rx_dma_activity($num_of_frames,
                         $frame_temp_dma,
                         $specific_addr,
                         length $preamble,
                         $dest_addr_type,
                         $fcs_data,
                         $dest_addr,
                         $src_addr,
                         $type_len_field,
                         $num_dma_queues, # TODO expect FRER R-TAG to be stripped out for now...
                         $vlan1_frame,
                         $vlan1_field,
                         $vlan2_frame,
                         $vlan2_field,
                         $udp_dport,
                         $ipv4_tos,
                         $ipv6_tc,
                         $ipv4_frame_local,
                         $ipv6_frame_local,
                         $udp_frame_local,
                         $tcp_frame_local,
                         $icmp_frame_local,
                         @comp_field,
                        )
         }
      } else { 
#        print "\n\nFrame will be dropped\n\n";
      }

      # need to reset these for multiple frame generation
      $frame_temp = "";
      $frame_temp_dma = "";
      $fcs_data = "";
   }
}


################################################################################
# copy_to_rx_array
#
# - Subroutine to add a frame to the array "eth_rxd" in the same format as
#   will be written to the data file "tb_rxd.data"
################################################################################
sub copy_to_rx_array {
   my ($control, $frame) = @_;

   my $nibble2           = "";
   my $nibble1           = "";

   my $temp              = "";
   my $first_byte        = "";

   my $frame_length      = "";
   my $even_frame_length = "";
   my $index_ref         = "";

   $index_ref = int @eth_rxd;



   # $even_frame_length will have a different value to (length $frame), if
   # $frame is an odd number of nibbles long.
   $frame_length = length $frame;
   $even_frame_length = int($frame_length / 2) * 2;

   $first_byte = "true";   # Set flag for the first byte of frame data

   for (my $i = 0; $i < ($frame_length / 2); ++$i) {
      if ($first_byte eq "true") {
         # If the first byte is to be padded
         if ($even_frame_length ne $frame_length) {
            $nibble2 = "0  // New Frame";  # Pads the 1st byte of preamble
            $nibble1 = chop ($frame);      # The 1st nibble of preamble
            $first_byte = "false";         # Cancel flag
         }
         else {
            $nibble1 = chop ($frame);
            $nibble2 = (chop ($frame))."  // New Frame";
         }
         $first_byte = "false";
      }

      else {
         $control = "4";
         $nibble1 = chop ($frame);
         $nibble2 = chop ($frame);
      }

      $eth_rxd[$i + $index_ref] = $control.$nibble1.$nibble2;
   }
}



################################################################################
# write_rxd_file
#
# - Subroutine to write all the rx frames to the file "tb_rxd.data"
################################################################################
sub write_rxd_file {

   my $array_size = "";

   $array_size = int (@eth_rxd);

   for (my $i = 0; $i < $array_size; ++$i) {

      print RXDFILE "$eth_rxd[$i]\n";
   }
}


################################################################################
# store_addresses
#
# - Subroutine to store the most up-to-date specific addresses to hash %address
################################################################################
sub store_addresses {
   my ($apb_line) = @_;
   ##########################################
   # Write specific address 1 to address hash
   #   print "\n  apb_line $apb_line";
#   print "\n$apb_line";
   if ($apb_line =~ /^088/) {
      # If address register top has not been called, put in dummy values for it
      if (!exists $address{"1"}) {
         $address{"1"} = "0000".substr("$apb_line", 3, 8);
      }
      # If address register top has been called, don't over write the values
      else {
         substr($address{"1"}, 4, 8) = substr("$apb_line", 3, 8);
      }
   }
   elsif ($apb_line =~ /^08c/) {
      $address{"1"} .= "";
      substr($address{"1"}, 0, 4) = substr("$apb_line", 7, 4);
   }

   ##########################################
   # Write specific address 2 to address hash
   elsif ($apb_line =~ /^090/) {
      if (!exists $address{"2"}) {
         $address{"2"} = "0000".substr("$apb_line", 3, 8);
      }
      else {
         substr($address{"1"}, 4, 8) = substr("$apb_line", 3, 8);
      }
   }
   elsif ($apb_line =~ /^094/) {
      $address{"2"} .= "";
      substr($address{"2"}, 0, 4) = substr("$apb_line", 7, 4);
   }

   ##########################################
   # Write specific address 3 to address hash
   elsif ($apb_line =~ /^098/) {
      if (!exists $address{"3"}) {
         $address{"3"} = "0000".substr("$apb_line", 3, 8);
      }
      else {
         substr($address{"1"}, 4, 8) = substr("$apb_line", 3, 8);
      }
   }
   elsif ($apb_line =~ /^09c/) {
      $address{"3"} .= "";
      substr($address{"3"}, 0, 4) = substr("$apb_line", 7, 4);
   }

   ##########################################
   # Write specific address 4 to address hash
   elsif ($apb_line =~ /^0a0/) {
      if (!exists $address{"4"}) {
         $address{"4"} = "0000".substr("$apb_line", 3, 8);
      }
      else {
         substr($address{"1"}, 4, 8) = substr("$apb_line", 3, 8);
      }
   }
   elsif ($apb_line =~ /^0a4/) {
      $address{"4"} .= "";
      substr($address{"4"}, 0, 4) = substr("$apb_line", 7, 4);
   }

   ##########################################
   # Get Buffer Size
   elsif ($apb_line =~ /^010/) {
      $buffer_size          = ((hex(substr("$apb_line", 3, 8)) & 16711680) >> 16) * 64;
      $rx_auto_discard_pkts = ((hex(substr("$apb_line", 3, 8)) & 16777216) >> 24);
      $force_max_burst_rx   = ((hex(substr("$apb_line", 3, 8)) & hex("02000000")) >> 25);
      $force_max_burst_tx   = ((hex(substr("$apb_line", 3, 8)) & hex("04000000")) >> 26);
      $ahb_burst_size       = ((hex(substr("$apb_line", 9, 2)) & hex("1f")));
      $addr64               = ((hex(substr("$apb_line", 3, 8)) & hex("40000000")) >> 30);
      $ext_bd_tx            = ((hex(substr("$apb_line", 3, 8)) & hex("20000000")) >> 29);
      $ext_bd_rx            = ((hex(substr("$apb_line", 3, 8)) & hex("10000000")) >> 28);

   }
   # Getting the bit 1 in the per queue rx flush registers
   elsif ($apb_line =~ /^b00/) {
      $rx_auto_discard_pkts_q0 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b04/) {
      $rx_auto_discard_pkts_q1 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b08/) {
      $rx_auto_discard_pkts_q2 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b0c/) {
      $rx_auto_discard_pkts_q3 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b10/) {
      $rx_auto_discard_pkts_q4 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b14/) {
      $rx_auto_discard_pkts_q5 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b18/) {
      $rx_auto_discard_pkts_q6 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b1c/) {
      $rx_auto_discard_pkts_q7 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b20/) {
      $rx_auto_discard_pkts_q8 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b24/) {
      $rx_auto_discard_pkts_q9 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b28/) {
      $rx_auto_discard_pkts_q10 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b2c/) {
      $rx_auto_discard_pkts_q11 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b30/) {
      $rx_auto_discard_pkts_q12 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b34/) {
      $rx_auto_discard_pkts_q13 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b38/) {
      $rx_auto_discard_pkts_q14 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }
   elsif ($apb_line =~ /^b3c/) {
      $rx_auto_discard_pkts_q15 = ((hex(substr("$apb_line", 3, 8)) & 00000002) >> 1);
   }

   elsif ($apb_line =~ /^4a0/) {
      $buffer_size_q1 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4a4/) {
      $buffer_size_q2 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4a8/) {
      $buffer_size_q3 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4ac/) {
      $buffer_size_q4 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4b0/) {
      $buffer_size_q5 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4b4/) {
      $buffer_size_q6 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4b8/) {
      $buffer_size_q7 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5e0/) {
      $buffer_size_q8 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5e4/) {
      $buffer_size_q9 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5e8/) {
      $buffer_size_q10 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5ec/) {
      $buffer_size_q11 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5f0/) {
      $buffer_size_q12 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5f4/) {
      $buffer_size_q13 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5f8/) {
      $buffer_size_q14 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^5fc/) {
      $buffer_size_q15 = ((hex(substr("$apb_line", 3, 8)))) * 64;
   }
   elsif ($apb_line =~ /^4cc/) {
      $ts_mode_tx = ((hex(substr("$apb_line", 3, 8)) & hex("00000030")) >> 4);
   }
   elsif ($apb_line =~ /^4d0/) {
      $ts_mode_rx = ((hex(substr("$apb_line", 3, 8)) & hex("00000030")) >> 4);
   }

   elsif ($apb_line =~ /^048/)  {
      $rx_jumbo_max_len_reg  = hex(substr("$apb_line", 3, 8));
      print "\nSetting Jumbo to $rx_jumbo_max_len_reg\n";
   }

   ##########################################
   # Write rx_q_ptr location to $rx_q_pointer
   elsif (($apb_line =~ /^018/) && ($apb_line !~ /^1018/))  {
      $rx_q_pointer[0] = substr("$apb_line", 3, 8);
      $rx_pointer[0] = hex ($rx_q_pointer[0]);
  #    print "\n setting rx_q_pointer $rx_q_pointer\n";
   }
   elsif ($apb_line =~ /^480/) {
     $rx_q_pointer[1] = substr("$apb_line", 3, 8);
     $rx_pointer[1] = hex ($rx_q_pointer[1]);
   }
   elsif ($apb_line =~ /^484/) {
     $rx_q_pointer[2] = substr("$apb_line", 3, 8);
     $rx_pointer[2] = hex ($rx_q_pointer[2]);
   }
   elsif ($apb_line =~ /^488/) {
     $rx_q_pointer[3] = substr("$apb_line", 3, 8);
     $rx_pointer[3] = hex ($rx_q_pointer[3]);
   }
   elsif ($apb_line =~ /^48c/) {
     $rx_q_pointer[4] = substr("$apb_line", 3, 8);
     $rx_pointer[4] = hex ($rx_q_pointer[4]);
   }
   elsif ($apb_line =~ /^490/) {
     $rx_q_pointer[5] = substr("$apb_line", 3, 8);
     $rx_pointer[5] = hex ($rx_q_pointer[5]);
   }
   elsif ($apb_line =~ /^494/) {
     $rx_q_pointer[6] = substr("$apb_line", 3, 8);
     $rx_pointer[6] = hex ($rx_q_pointer[6]);
   }
   elsif ($apb_line =~ /^498/) {
     $rx_q_pointer[7] = substr("$apb_line", 3, 8);
     $rx_pointer[7] = hex ($rx_q_pointer[7]);
   }
   elsif ($apb_line =~ /^5c0/) {
     $rx_q_pointer[8] = substr("$apb_line", 3, 8);
     $rx_pointer[8] = hex ($rx_q_pointer[8]);
   }
   elsif ($apb_line =~ /^5c4/) {
     $rx_q_pointer[9] = substr("$apb_line", 3, 8);
     $rx_pointer[9] = hex ($rx_q_pointer[9]);
   }
   elsif ($apb_line =~ /^5c8/) {
     $rx_q_pointer[10] = substr("$apb_line", 3, 8);
     $rx_pointer[10] = hex ($rx_q_pointer[10]);
   }
   elsif ($apb_line =~ /^5cc/) {
     $rx_q_pointer[11] = substr("$apb_line", 3, 8);
     $rx_pointer[11] = hex ($rx_q_pointer[11]);
   }
   elsif ($apb_line =~ /^5d0/) {
     $rx_q_pointer[12] = substr("$apb_line", 3, 8);
     $rx_pointer[12] = hex ($rx_q_pointer[12]);
   }
   elsif ($apb_line =~ /^5d4/) {
     $rx_q_pointer[13] = substr("$apb_line", 3, 8);
     $rx_pointer[13] = hex ($rx_q_pointer[13]);
   }
   elsif ($apb_line =~ /^5d8/) {
     $rx_q_pointer[14] = substr("$apb_line", 3, 8);
     $rx_pointer[14] = hex ($rx_q_pointer[14]);
   }
   elsif ($apb_line =~ /^5dc/) {
     $rx_q_pointer[15] = substr("$apb_line", 3, 8);
     $rx_pointer[15] = hex ($rx_q_pointer[15]);
   }


   ##########################################
   #screener match registers
   elsif ($apb_line =~ /^5/) {
     if ($apb_line =~ /^500/) {$#type1_screener_reg = -1};  # reset the array if a write to base is detected
     if ($apb_line =~ /^540/) {$#type2_screener_reg = -1};  # reset the array if a write to base is detected
     my $temp_add = substr("$apb_line", 0, 3);


     if (hex($temp_add) < hex(540)) { push (@type1_screener_reg,substr("$apb_line", 3, 8)); }
     if (hex($temp_add) >= hex(540) and hex($temp_add) < hex(600)) { push (@type2_screener_reg,substr("$apb_line", 3, 8)); }

  }

   ##########################################
   # ethertype match registers
   elsif (($apb_line =~ /^6e/) ||($apb_line =~ /^6f/)) {
     if ($apb_line =~ /^6e0/) {$#type2_ethtype_reg = -1};  # reset the array if a write to base is detected
     my $temp_index = ((hex(substr("$apb_line", 0, 3)) - hex('6e0')) /4);
     $type2_ethtype_reg[$temp_index] = substr("$apb_line", 7, 4);
     #print "Index is $temp_index , register is $type2_ethtype_reg[$temp_index]\n";
     #push (@type2_ethtype_reg,substr("$apb_line", 3, 8));
   }

   ##########################################
   # compare match registers
   elsif (($apb_line =~ /^7.0/) ||($apb_line =~ /^7.8/)) {
     if ($apb_line =~ /^700/) {$#type2_compare0_reg = -1};  # reset the array if a write to base is detected
     push (@type2_compare0_reg,substr("$apb_line", 3, 8));
   }
   elsif (($apb_line =~ /^7.4/) ||($apb_line =~ /^7.c/)) {
     if ($apb_line =~ /^704/) {$#type2_compare1_reg = -1};  # reset the array if a write to base is detected
     push (@type2_compare1_reg,substr("$apb_line", 3, 8));
   }

   ##########################################
   # stacked vlan reg
   elsif (($apb_line =~ /^0c0/)) {
      $stacked_vlan_tag  = ((hex(substr("$apb_line", 3, 8)) & hex("0000ffff")));
      $stacked_vlan_en  = ((hex(substr("$apb_line", 3, 8)) & hex("80000000")) >> 31);
   }

   ##########################################
   # Write tx_q_ptr location to $rx_q_pointer
   elsif (($apb_line =~ /^01c/) && ($apb_line !~ /^101c/)) {
      $tx_q_pointer[0] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^440/) {
      $tx_q_pointer[1] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^444/) {
      $tx_q_pointer[2] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^448/) {
      $tx_q_pointer[3] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^44c/) {
      $tx_q_pointer[4] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^450/) {
      $tx_q_pointer[5] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^454/) {
      $tx_q_pointer[6] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^458/) {
      $tx_q_pointer[7] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^45c/) {
      $tx_q_pointer[8] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^460/) {
      $tx_q_pointer[9] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^464/) {
      $tx_q_pointer[10] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^468/) {
      $tx_q_pointer[11] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^46c/) {
      $tx_q_pointer[12] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^470/) {
      $tx_q_pointer[13] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^474/) {
      $tx_q_pointer[14] = substr("$apb_line", 3, 8);
   }
   elsif ($apb_line =~ /^478/) {
      $tx_q_pointer[15] = substr("$apb_line", 3, 8);
   }

   ##########################################
   # Write whether fcs is stripped to $strip_fcs
   elsif ($apb_line =~ /^004/) {
      # Detect bus width
      $width64 = ((hex(substr("$apb_line", 3, 8)) & hex(200000)) >> 21);
      $width128 = ((hex(substr("$apb_line", 3, 8)) & hex(400000)) >> 22);
      if ($width64 == 1 || $width128 == 1) {$width32 = 0;} else {$width32 = 1;}

      $rxoffset = ((hex(substr("$apb_line", 3, 8)) & 49152) >> 14);
      $rx_toe = ((hex(substr("$apb_line", 3, 8)) & hex('01000000')) > 24);
      $gigabit = ((hex(substr("$apb_line", 3, 8)) & hex('00000400')) > 10);
      $speed_mode = ((hex(substr("$apb_line", 3, 8)) & hex('00000003')));
      if ($gigabit) {$speed_mode = 2;}
      $scale_event_factor = 1;
      if ($speed_mode == 0) {$scale_event_factor = 10;}
      if ($speed_mode == 2) {$scale_event_factor = "0.1";}
#      print "\nWrite to Address 0x04 detected\n\t rxoffset??? -> $rxoffset\n";
      my $strip_fcs_temp = substr("$apb_line", 6, 1);
      if ($strip_fcs_temp eq "2" or $strip_fcs_temp eq "3" or
          $strip_fcs_temp eq "6" or $strip_fcs_temp eq "7" or
          $strip_fcs_temp eq "a" or $strip_fcs_temp eq "b" or
          $strip_fcs_temp eq "e" or $strip_fcs_temp eq "f") {
       #  print "\n rx fcs stripped $strip_fcs_temp\n";
         $strip_fcs = 1;
      } else {
         $strip_fcs = 0;
       #  print "\n rx fcs not stripped $strip_fcs_temp $apb_line\n";
      }
   }

   elsif ($apb_line =~ /^8a4/) {
      $strip_rtag   = ((hex(substr("$apb_line", 3, 1)) & 8) >> 3);
      $frer_6b_tag  = ((hex(substr("$apb_line", 3, 1)) & 4) >> 2);
      if ($strip_rtag == 1) { print "Auto-stripping redundancy tags\n"; }
      if ($frer_6b_tag == 1) { print "Using 6-byte R-Tag\n"; }
      $frer_rtag_type = substr("$apb_line", 7, 4);
      print "Redundancy Tag ID set to $frer_rtag_type\n";
#      print "APB line was $apb_line\n";
   }

   # Enable RX cutthru 
   elsif ($apb_line =~ /^044/) {
      $en_rx_cutthru  = ((hex(substr("$apb_line", 3, 1)) & 8) >> 3);
      if ($en_rx_cutthru == 1) { print "Enabling RX Cutthru\n"; }
#      print "APB line was $apb_line\n";
   }
   
   ##########################################
   # Get upper 32 bits of address
   elsif ($apb_line =~ /^4c8/) {
      # Detect bus width
     if ($addr64 == 1) {
      $descr_addr_upper_32 = (hex(substr("$apb_line", 3, 8)));
     } else {
      $descr_addr_upper_32 = (hex(0));
     }
   }


   ##########################################
   # Is this an AXI test - find out if the test reads the design cfg reg #2 bit 30
   elsif ($apb_line =~ /^284/) {
      # Detect bus width
      $axi_test = ((hex(substr("$apb_line", 3, 8)) & hex(40000000)) >> 30);
#      print "This is an AXI test ...\n";
   }


   ##########################################
   # Are there more than 4 specific address filters defined in the defines ?  If so, the trans.pl needs to know so it can
   # set the appropriate dma descriptors p[roperly (it alters the status if there are >4). test should read the appropriate
   # design cfg reg so trans.pl can identify it here ...
   elsif ($apb_line =~ /^288/) {
      $extra_spec_adds_en = (((hex(substr("$apb_line", 3, 8)) & hex('3f000000')) >> 24) > 4); # bits 29:24 > 4
   }

   ##########################################
   # have we enabled drop_on_frame_length per queue flush or drop_all_frames? if so check for it and remove any RX DMA for that frame ...
   if ($apb_line =~ /^b([0123])([048c])(....)...(.)/) {
     my $temp_q = (int($1)*4) + (hex($2)/4); 
     $drop_rx_frame_on_len_en[$temp_q] = $4 & 8;
     $drop_rx_frame_on_len[$temp_q] = hex($3);
     $drop_rx_all_frames_en[$temp_q] = $4 & 1;
     if ($drop_rx_all_frames_en[$temp_q]) {print "Enabling drop_rx_all_frames for queue $temp_q ... \n";}
     if ($drop_rx_frame_on_len_en[$temp_q]) {print "Enabling drop_on_frame_length for queue $temp_q (max len = $drop_rx_frame_on_len[$temp_q]) ...\n";}
   }

}


################################################################################
# get_random_address
#
# - Subroutine to return a random valid address of specified type
################################################################################
sub get_random_address {
   my ($type) = @_;

   my @uni_addr;
   my @multi_addr;
   my $index1 = "0";
   my $index2 = "0";

   # Go through the hash %address and sort it into arrays @uni_addr and
   # @multi_addr
   for (my $i = "1"; $i < "5"; ++$i) {
      if (!exists $address{$i}) {
         # Do nothing
      }
      # If the specific address is unicast
      elsif ($address{$i} =~ /[02468ace]$/) {
         $uni_addr[$index1] = $address{$i};
         ++$index1;
      }
      # If the specific address is multicast
      else {
         $multi_addr[$index2] = $address{$i};
         ++$index2;
      }
   }

   # Return a random unicast address
   if ($type eq "unicast") {
      return $uni_addr[rand @uni_addr];
   }
   # Return a random multicast address
   else {
      return $multi_addr[rand @multi_addr];
   }
}



################################################################################
# rx_dma_activity
#
# - Subroutine to define the expected write activity on the DMA interface
################################################################################
sub rx_dma_activity {
  my (  $num_of_frames,
        $frame,
        $specific_addr,
        $preamble_size,
        $dest_addr_type,
        $fcs_data,
        $mac_dest_addr,
        $mac_src_addr,
        $ethertype_len_field,
        $num_dma_queues,
        $vlan1_frame,
        $vlan1_field,
        $vlan2_frame,
        $vlan2_field,
        $udp_dport,
        $ipv4_tos,
        $ipv6_tc,
        $ipv4_frame,
        $ipv6_frame,
        $udp_frame,
        $tcp_frame,
        $icmp_frame,
        @comp_field,
      ) = @_;



   my $control       = "0"; # Control nibble (default 0, means data is valid)
   my $address       = "";  # Address of the current rx buffer
   my $sfd_size      = "2"; # Size of SFD (in nibbles)
   my $byte_count    = "0";
   my $buffer_count  = "0";
   my $rxusedbit     = "0";
   my $rxwrapbit     = "0";
   my $num_ahb_words_to_write = 0;

   #print "RX auto-frame generation is Processing frame $cur_frame_idx of $num_of_frames\n";

   # Remove the preamble and SFD from the frame
   for (my $i = 0; $i < $preamble_size + $sfd_size; ++$i) {
      chop $frame;
   }

   # Work out which queue the packet is destined for ...

   $rx_queue_to_use = 0;
#   if ($vlan1_frame ne "") {
      for ($num_screener_type2_regs = 0;$num_screener_type2_regs <= $#type2_screener_reg; $num_screener_type2_regs++) {

        # extract the fields from the screener reg ...
        my $screener_type2_queue_num = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,7,1)); # bits 3:0

        my $screener_type2_vlan_pri  = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,6,1)); # bits 7:4
        my $screener_type2_vlan_en   = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,5,1)) & hex('1'); # bit  8

        my $screener_type2_ethtype_ind= hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,5,1)) & hex('e'); # bits 11:9
           $screener_type2_ethtype_ind= $screener_type2_ethtype_ind >> 1;
        my $screener_type2_ethtype_en= hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,4,1)) & hex('1'); # bits 12

        my $screener_type2_compa_ind = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,3,2)) & hex('3e'); # bits 17:13
           $screener_type2_compa_ind = $screener_type2_compa_ind >> 1;
        my $screener_type2_compa_en  = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,3,1)) & hex('4');  # bit 18
           $screener_type2_compa_en  = $screener_type2_compa_en >> 2;

        my $screener_type2_compb_ind = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,2,2)) & hex('f8'); # bits 23:19
           $screener_type2_compb_ind = $screener_type2_compb_ind >> 3;
        my $screener_type2_compb_en  = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,1,1)) & hex('1');   # bit 24

        my $screener_type2_compc_ind = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,0,2)) & hex('3e');  # bits 29:25
           $screener_type2_compc_ind = $screener_type2_compc_ind >> 1;
        my $screener_type2_compc_en  = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,0,1)) & hex('4');   # bit 30
           $screener_type2_compc_en  = $screener_type2_compc_en >> 2;


        $match_vlan = 0;
        if ($vlan1_frame ne "") {
        if (hex($vlan1_frame) == hex(8100)) {
          my $vlan_field_priorty = substr(($vlan1_field) ,0,1);  # Get bits [15:13] from the VLAN Field
             $vlan_field_priorty = sprintf "%01x", (hex($vlan_field_priorty) >>1);

          # Compare the VLAN priority extracted from the frame against bits 7:4 of the type 2 screener reg ...
          if (hex($vlan_field_priorty) == $screener_type2_vlan_pri) {$match_vlan = 1;}
        }
        }

        my $match_ethertype = 0;
        my @match_ethtype;
        my $last_ethertype;
        if ($vlan1_frame ne "" && hex($vlan1_frame) != hex(8100)) {$last_ethertype = $vlan1_frame;} else {$last_ethertype = $ethertype_len_field;}  
        if ($#type2_ethtype_reg >= 0) {
          for (my $num_type2_ethtype_regs = 0;$num_type2_ethtype_regs <= $#type2_ethtype_reg; $num_type2_ethtype_regs++) {
            # Extract the fields from the screener reg ...
            my $compare_val = $type2_ethtype_reg[$num_type2_ethtype_regs]; # bits 15:16

            $match_ethtype[$num_type2_ethtype_regs] = 0;
            print "compare_val = $compare_val, last_ethertype is $last_ethertype, vlan1_frame is $vlan1_frame, ethertype_len_field = $ethertype_len_field\n";
            if (hex($compare_val) == hex($last_ethertype)) {
              $match_ethtype[$num_type2_ethtype_regs] = 1;
            }
          }
          $match_ethertype = $match_ethtype[$screener_type2_ethtype_ind];
        }

        my @match_comp;
        my $match_compa;
        my $match_compb;
        my $match_compc;
        if ($#type2_compare0_reg >= 0) {
          for (my $num_type2_compare_regs = 0;$num_type2_compare_regs <= $#type2_compare0_reg; $num_type2_compare_regs++) {
            # Extract the fields from the compare reg ...
            my $comp_vlan_id_en    = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,5,1)) & hex('4')) >> 2; # bit 10 - compare_vlan_id
            my $comp_vlan_id_stag  = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,6,1)) & hex('8')) >> 3; # bit 7  - compare_vlan_id (ctag/stag select)
            my $comp_dont_use_mask = (hex(substr("$type2_compare1_reg[$num_type2_compare_regs]" ,5,1)) & hex('2')) >> 1; # bit 9  - disable_mask
            my $compare_val;
            my $mask_val;
            if ($comp_dont_use_mask) {
               $compare_val = (substr("$type2_compare0_reg[$num_type2_compare_regs]" ,0,8)); # bits 31:0
            } else {
               $compare_val = (substr("$type2_compare0_reg[$num_type2_compare_regs]" ,0,4)); # bits 31:16
               $mask_val    = (substr("$type2_compare0_reg[$num_type2_compare_regs]" ,4,4)); # bits 15:0
            }

            $match_comp[$num_type2_compare_regs] = 0;
            #print "comp_dont_use_mask = $comp_dont_use_mask, compare_val = $compare_val, mask_val = $mask_val";
            #my $ewan = $comp_field[$num_type2_compare_regs];
            #print "comp_field = $ewan\n\n\n";
            #print "COMPA index is $screener_type2_compa_ind, for comp reg $num_type2_compare_regs, compare_val is $compare_val and mask is $mask_val, extracted field from frame at index is $comp_field[$num_type2_compare_regs]\n";
            if ($comp_vlan_id_en) {
              # ctag is the 1st if there is only 1 tag and it is 8100
              # stag is the 1st if it is stacked vlan tag
              # ctag is the 2nd if there is are 2 tags and the 2nd is 8100 (and either first is stacked vlan or 8100)
              $match_comp[$num_type2_compare_regs] = 0;
              print "COMPARE REG $num_type2_compare_regs: comp_vlan_id_stag = $comp_vlan_id_stag, vlan1_frame = $vlan1_frame, vlan1_field = $vlan1_field, vlan2_frame = $vlan2_frame, vlan2_field = $vlan2_field, compare_val = $compare_val, mask_val = $mask_val\n";
              # If there are 2 VLAN's, the first should always be the STAG, and the 2nd should be the CTAG
              # The design is quite simple - if the first vlan is the CTAG and we are comparing against CTAG, then the 2nd is not compared at all
              if    (!$comp_vlan_id_stag  && hex($vlan2_frame) == hex(8100) && ((hex($vlan1_frame) == $stacked_vlan_tag && $stacked_vlan_en) || hex($vlan1_frame) == hex(8100))) {
                if  ((hex($compare_val) & hex($mask_val)) == (hex($vlan2_field) & hex($mask_val)))                                                                                           {$match_comp[$num_type2_compare_regs] = 1;print "Matched on CTAG (2 VLANs)!\n";}}
              elsif (!$comp_vlan_id_stag  && hex($vlan1_frame) == hex(8100) && (hex($compare_val) & hex($mask_val)) == (hex($vlan1_field) & hex($mask_val)))                                 {$match_comp[$num_type2_compare_regs] = 1;print "Matched on CTAG (1 VLAN)!\n";}
              elsif ($comp_vlan_id_stag   && hex($vlan1_frame) == $stacked_vlan_tag && $stacked_vlan_en && (hex($compare_val) & hex($mask_val)) == (hex($vlan1_field) & hex($mask_val)))     {$match_comp[$num_type2_compare_regs] = 1;print "Matched on STAG!\n";}
            }
            elsif ($comp_field[$num_type2_compare_regs] eq "xx") {$match_comp[$num_type2_compare_regs] = 0;}
            elsif (($comp_dont_use_mask == 1) && (hex($compare_val)  == (hex($comp_field[$num_type2_compare_regs])))) {$match_comp[$num_type2_compare_regs] = 1;}
            elsif (($comp_dont_use_mask == 0) && (hex($compare_val) & hex($mask_val)) == (hex($comp_field[$num_type2_compare_regs]) & hex($mask_val))) {$match_comp[$num_type2_compare_regs] = 1;}
            #print "mask val = $mask_val, compare_val  = $compare_val, comp_field = $comp_field[$num_type2_compare_regs]\n";
            #if ((hex($compare_val)) == (hex($comp_field[$num_type2_compare_regs]) & hex($mask_val))) {$match_comp[$num_type2_compare_regs] = 1;}
          }
          $match_compa = $match_comp[$screener_type2_compa_ind];
          $match_compb = $match_comp[$screener_type2_compb_ind];
          $match_compc = $match_comp[$screener_type2_compc_ind];
        }
        #print "For screener register $num_screener_type2_regs, \n\tMapped Queue = $screener_type2_queue_num\n\tvlan enable = $screener_type2_vlan_en\n\tethtype enable = $screener_type2_ethtype_en\n\tcompa enable = $screener_type2_compa_en\n\tcompb enable = $screener_type2_compb_en\n\tcompc enable = $screener_type2_compc_en\n";
        print "\t->  Match results for Screener2 #$num_screener_type2_regs\n";
        if ( $screener_type2_vlan_en == 1) {
          if ($match_vlan == 1) { print "\t    -> VLAN match enabled and matched on screener2 #$num_screener_type2_regs (VLAN = $vlan1_frame$vlan1_field) \n"}else{print "\t    -> FAILED VLAN match on screener2 #$num_screener_type2_regs (got $vlan1_frame$vlan1_field)\n"};
        } else {print "\t    -> VLAN match disabled\n";}
        if ( $screener_type2_ethtype_en == 1) {
          if ($match_ethtype[$screener_type2_ethtype_ind] == 1) { print "\t    -> ETHTYPE enabled and matched on screener2 #$num_screener_type2_regs - uses ethtype register $screener_type2_ethtype_ind \n"}else{print "\t    -> FAILED Ethertype match on screener2 #$num_screener_type2_regs (got $last_ethertype)\n"};
        } else {print "\t    -> ETHTYPE match disabled\n";}
        if ( $screener_type2_compa_en == 1) {
          if ($match_comp[$screener_type2_compa_ind] == 1) { print "\t    -> COMPA enabled and matched on screener2 #$num_screener_type2_regs - uses compare register $screener_type2_compa_ind\n"}else{print "\t    -> FAILED COMPA match on screener2 #$num_screener_type2_regs ($type2_compare0_reg[$screener_type2_compa_ind] vs $comp_field[$screener_type2_compa_ind])\n"};
        } else {print "\t    -> COMPA match disabled\n";};
        if ( $screener_type2_compb_en == 1) {
          if ($match_comp[$screener_type2_compb_ind] == 1) { print "\t    -> COMPB enabled and matched on screener2 #$num_screener_type2_regs - uses compare register $screener_type2_compb_ind\n"}else{print "\t    -> FAILED COMPB match on screener2 #$num_screener_type2_regs ($type2_compare0_reg[$screener_type2_compb_ind] vs $comp_field[$screener_type2_compb_ind])\n"};
        } else {print "\t    -> COMPB match disabled\n";};
        if ( $screener_type2_compc_en == 1) {
          if ($match_comp[$screener_type2_compc_ind] == 1) { print "\t    -> COMPC enabled and matched on screener2 #$num_screener_type2_regs - uses compare register $screener_type2_compc_ind\n"}else{print "\t    -> FAILED COMPC match on screener2 #$num_screener_type2_regs ($type2_compare0_reg[$screener_type2_compc_ind] vs $comp_field[$screener_type2_compc_ind])\n"};
        } else {print "\t    -> COMPC match disabled\n";};

        # Now check against the enables  ...
        if (  ((($screener_type2_vlan_en == 1)    && ($match_vlan == 1))      || ($screener_type2_vlan_en == 0))    &&
              ((($screener_type2_ethtype_en == 1) && ($match_ethertype == 1)) || ($screener_type2_ethtype_en == 0)) &&
              ((($screener_type2_compa_en == 1)   && ($match_compa == 1))     || ($screener_type2_compa_en == 0))   &&
              ((($screener_type2_compb_en == 1)   && ($match_compb == 1))     || ($screener_type2_compb_en == 0))   &&
              ((($screener_type2_compc_en == 1)   && ($match_compc == 1))     || ($screener_type2_compc_en == 0))   &&

              # At least 1 enable must be set for the queue to match(if no enables are set, then we dont want to perform the 'last' command ...
              (($screener_type2_vlan_en == 1) || ($screener_type2_ethtype_en == 1) || ($screener_type2_compa_en == 1) || ($screener_type2_compb_en == 1)  || ($screener_type2_compc_en == 1)))
         {
           $rx_queue_to_use = hex(substr("$type2_screener_reg[($num_screener_type2_regs)]" ,7,1));
           print "\t    -> RESULT - MATCH, routing frame to queue $rx_queue_to_use!\n";
           last;
         }
         else {print "\t    -> RESULT - NO MATCH\n";}
      }
  # }

   for ($num_screener_type1_regs = 0;$num_screener_type1_regs <= $#type1_screener_reg; $num_screener_type1_regs++) {
      $match_udp = 0;
      $match_tostc = 0;
      if ($udp_frame == 1) {
        if (hex($udp_dport) == hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,1,4))) {
          $match_udp = 1;
        }
      }
      if ($ipv4_frame == 1) {
        if (hex($ipv4_tos) == hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,5,2))) {$match_tostc = 1;}
      }
      if ($ipv6_frame == 1) {
        if (hex($ipv6_tc) == hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,5,2))) {$match_tostc = 1;}
      }
     # printf "Trying to match register %0d, Actual received TOS = $ipv4_tos expected = %x, TC = $ipv6_tc, UDP DEST = $udp_dport expected = %x\n",$num_screener_type1_regs,hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,5,2)),hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,1,4));

        if ((substr("$type1_screener_reg[$num_screener_type1_regs]",0,1) == 3) && ($match_udp == 1) && ($match_tostc == 1) && ($udp_frame == 1) && (($ipv4_frame == 1) || ($ipv6_frame == 1))) {
            printf "Frame $cur_frame_idx : Screener Type1 (#%0d) : matched udp(%0x) and tos/tc(%0x) on queue %0d\n",($num_screener_type1_regs), hex($udp_dport),hex($ipv4_tos), hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,7,1));
            $rx_queue_to_use = hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,7,1));
            last;
        } elsif ((substr("$type1_screener_reg[$num_screener_type1_regs]",0,1) == 2) && ($match_udp == 1) && ($udp_frame == 1)) {
            printf "Frame $cur_frame_idx : screener Type1 (#%0d) : matched udp only on queue %0d\n",($num_screener_type1_regs), hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,7,1));
            $rx_queue_to_use = hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,7,1));
            last;
        } elsif ((substr("$type1_screener_reg[$num_screener_type1_regs]",0,1) == 1) && ($match_tostc == 1) && (($ipv4_frame == 1) || ($ipv6_frame == 1))) {
         #   printf "Frame $cur_frame_idx : screener type1 (#%0d) : matched tos/tc only only on queue %0d\n",($num_screener_type1_regs), hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,7,1));
            $rx_queue_to_use = hex(substr("$type1_screener_reg[($num_screener_type1_regs)]" ,7,1));
            last;
        }

    }

#   printf "ADDRESS is %08x, Frame is $frame\n",$address;
   # Work out the frame_size in bytes
   my $frame_size = (length ($frame) / 2);

   if (($drop_rx_frame_on_len_en[$rx_queue_to_use] &&  $drop_rx_frame_on_len[$rx_queue_to_use] < $frame_size) | ($drop_rx_all_frames_en[$rx_queue_to_use])) {
     #print "Shoud RX frame  be dropped? Q=$rx_queue_to_use, drop_rx_all_frames_en=$drop_rx_all_frames_en[$rx_queue_to_use], drop_rx_frame_on_len_en=$drop_rx_frame_on_len_en[$rx_queue_to_use], drop_rx_frame_on_len=$drop_rx_frame_on_len[$rx_queue_to_use], frame len=$frame_size\n";
     $i_think_rx_frame_is_dropped = 1;
   } else {
     $i_think_rx_frame_is_dropped = 0;
   }
   

#   if ($i_think_rx_frame_is_dropped == 1) {$init_address = sprintf "%08x", (hex($init_address) & hex('fffffffd'));} #  cancel wrap if the frame is being dropped ..
   if ($i_think_rx_frame_is_dropped == 0) {

     if ($debug_print_frame == 1) {print "Using Queue $rx_queue_to_use ...\n";}

     # work out pointer position from $rx_q_pointer from apb write and $rx_q_ptr_index
     #if ($num_dma_queues == 8) {$cur_rx_ptr = hex ($rx_q_pointer);}

     $cur_rx_ptr = $rx_pointer[$rx_queue_to_use];

     # For the filehandles ..  tb_dma for AHB only uses Q0 ..
     if ($axi_test) {
       $rx_queue_to_use_t = $rx_queue_to_use;
     } else {
       $rx_queue_to_use_t = 0;
     }

     # Generate rx buffer location and make sure the used bit
     # is not set and only allow the wrap bit to be set occasionally
     $wrap_offset =0;
     if ($rx_data_start_add eq "") {
       $init_address = generate_field(4,4,"random","byte");
     } else {
       $init_address = $rx_data_start_add;
     }

     my $firstrxaccess = 1;

     $rxusedbit = 1;
     while ($rxusedbit == 1) {
       if ($resource_err eq "random") {$rxusedbit = int(rand(4));if ($rxusedbit != 1) {$rxusedbit=0};}
       else {$rxusedbit = $resource_err;}

#       print "\n\t$includerxdma\t$rx_do_descr_acc\t$rx_data_start_add\t$init_address\n";

       if (($includerxdma == 1) && ($rx_do_descr_acc == 1) && (!$i_think_rx_frame_is_dropped))
       {
          if ($rxusedbit == 1) {
            if ($ext_bd_rx == 0) {
               $init_address = (sprintf "%08x", (hex($init_address) | hex('00000001')));
             } else {
               $init_address = (sprintf "%08x", ((hex($init_address) | hex('00000001')) & hex('fffffffb')));
             }
          } else {

            if ($axi_perf_test) {
              if ($ext_bd_rx == 0) {
               $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffc')));
              } else {
               $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffff8')));
              }
            } elsif ($ext_bd_rx == 0) {
               $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffe')));
             } else {
               $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffa')));
             }
          }

          # In force_max_burst_rx mode, make sure we always start buffers on a nice 64byte or 128byte boundary depending on databus width
          if ($force_max_burst_rx) {
            if ($width64 == 1) {
              $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffb')));
            } elsif ($width128 == 1) {
              $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffff3')));
            }
          }

          $rxwrapbit = (hex($init_address) & hex('00000002')) >> 1;
          
          my $data_addr_upper_32_str = 0;
          for (my $queue_cnt=($num_dma_queues-1);$queue_cnt>=0;$queue_cnt--) {
            if (defined $rx_pointer[$queue_cnt]) {$curr_q_ptr = $rx_pointer[$queue_cnt];} else {$curr_q_ptr = 0;}

            $line_to_write = "0".(sprintf "%08x", ($descr_addr_upper_32)).(sprintf "%08x", ($curr_q_ptr)).$init_address."  // Descriptor Read (1st buffer for frame $cur_frame_idx, queue = $queue_cnt) - used = $rxusedbit, wrap = $rxwrapbit\n";

            if ($addr64) {
              $data_addr_upper_32 = int(rand(2**32));
              if ($queue_cnt == $rx_queue_to_use) {
                $data_addr_upper_32_str = $data_addr_upper_32;
              }
              # always does 32b reads
              $line_to_write = $line_to_write . "0".(sprintf "%08x", ($descr_addr_upper_32)).(sprintf "%08x", ($curr_q_ptr+8)).(sprintf "%08x", $data_addr_upper_32)."  // Descriptor Read (1st buffer for frame $cur_frame_idx) - upper address\n";
            }
            if ($rx_queue_to_use == $queue_cnt) {
              $write_line_en = 1;
            } else {
              $write_line_en = 0;
            }
            if ($write_line_en) {
              if ($axi_test == 0) {
                printf {$DMARD_RXDESCR_FH[0]} $line_to_write;
              } else {
                printf {$DMARD_RXDESCR_FH[$queue_cnt]} $line_to_write;
              }
            }
         }
         $data_addr_upper_32 = $data_addr_upper_32_str;
       }

  # generate data for rx dma buffer manager

       if ($rxusedbit == 1) {
        if ($rx_gen_int_in == 1) {
          if ($rx_queue_to_use == 0) {
            print APBFILE "00000000a002400000004   // Resource Error Interrupt Q0\n";
            print APBFILE "000000004002400000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 1) {
            print APBFILE "00000010a040000000004   // Resource Error Interrupt Q1\n";
            print APBFILE "000000104040000000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 2) {
            print APBFILE "00000020a040400000004   // Resource Error Interrupt Q2\n";
            print APBFILE "000000204040400000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 3) {
            print APBFILE "00000030a040800000004   // Resource Error Interrupt Q3\n";
            print APBFILE "000000304040800000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 4) {
            print APBFILE "00000040a040c00000004   // Resource Error Interrupt Q4\n";
            print APBFILE "000000404040c00000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 5) {
            print APBFILE "00000050a041000000004   // Resource Error Interrupt Q5\n";
            print APBFILE "000000504041000000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 6) {
            print APBFILE "00000060a041400000004   // Resource Error Interrupt Q6\n";
            print APBFILE "000000604041400000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 7) {
            print APBFILE "00000070a041800000004   // Resource Error Interrupt Q7\n";
            print APBFILE "000000704041800000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 8) {
            print APBFILE "00000080a041c00000004   // Resource Error Interrupt Q8\n";
            print APBFILE "000000804041c00000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 9) {
            print APBFILE "00000090a042000000004   // Resource Error Interrupt Q9\n";
            print APBFILE "000000904042000000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 10) {
            print APBFILE "000000a0a042400000004   // Resource Error Interrupt Q10\n";
            print APBFILE "000000a04042400000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 11) {
            print APBFILE "000000b0a042800000004   // Resource Error Interrupt Q11\n";
            print APBFILE "000000b04042800000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 12) {
            print APBFILE "000000c0a042c00000004   // Resource Error Interrupt Q12\n";
            print APBFILE "000000c04042c00000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 13) {
            print APBFILE "000000d0a043000000004   // Resource Error Interrupt Q13\n";
            print APBFILE "000000d04043000000004   // Write to clear\n";
          } elsif ($rx_queue_to_use == 14) {
            print APBFILE "000000e0a043400000004   // Resource Error Interrupt Q14\n";
            print APBFILE "000000e04043400000004   // Write to clear\n";
          } else {
            print APBFILE "000000f0a043800000004   // Resource Error Interrupt Q15\n";
            print APBFILE "000000f04043800000004   // Write to clear\n";
          }
        }
       }

      if ($rx_auto_discard_pkts     or $rx_auto_discard_pkts_q0  or $rx_auto_discard_pkts_q1  or $rx_auto_discard_pkts_q2  or
          $rx_auto_discard_pkts_q3  or $rx_auto_discard_pkts_q4  or $rx_auto_discard_pkts_q5  or $rx_auto_discard_pkts_q6  or
          $rx_auto_discard_pkts_q7  or $rx_auto_discard_pkts_q8  or $rx_auto_discard_pkts_q9  or $rx_auto_discard_pkts_q10 or
          $rx_auto_discard_pkts_q11 or $rx_auto_discard_pkts_q12 or $rx_auto_discard_pkts_q13 or $rx_auto_discard_pkts_q14 or $rx_auto_discard_pkts_q15) {last;}

     } # while rxusedbit

     $rxwrapbit = (hex($init_address) & hex('00000002')) >> 1 ; # Extract wrap bit
     # print "Wrap bit extracted was $rxwrapbit\n";
     if ($rxusedbit == 1) {$rxwrapbit = 0;} # cancel wrap if used bit is still set

     my $addbit2 = (hex($init_address) & hex('00000004')) >> 2 ; # Extract bit 2
     my $addbit3 = (hex($init_address) & hex('00000008')) >> 3 ; # Extract bit 3
     if ($rxwrapbit == 1) {
       $wrap_offset = 2;
     }

     $init_address = hex ($init_address);

     # assign base address of rx buffer
     $address = $init_address - $wrap_offset; # need to subtract 2 if the wrap bit is set
     #printf "ADDRESS is %08x\n",$address;
     if ($width64 == 1) {
      $address = ($address & hex('fffffffb')); # ensure the address is 64bit aligned
     }
     if ($width128 == 1) {
      $address = ($address & hex('fffffff3')); # ensure the address is 128bit aligned
     }
     #printf "ADDRESS is %08x\n",$address;
     $wrap_offset =0;

     # Calculate the number of bytes that will be written out
     # this is different to the frame size as we have offset to take into account ...
     # First add the offset bytes to $frame
     if     ($rxoffset == 1 && $firstrxaccess == 1) {$frame = $frame . "00";}
     elsif  ($rxoffset == 2 && $firstrxaccess == 1) {$frame = $frame . "0000";}
     elsif  ($rxoffset == 3 && $firstrxaccess == 1) {$frame = $frame . "000000";}
     if     ($addbit2 == 1  && $width32 == 0)       {$frame = $frame . "00000000";}
     if     ($addbit3 == 1  && $width128 == 1)      {$frame = $frame . "0000000000000000";}

     # If force_max_burst_rx is set, then the number of bytes in the last buffer must be a multiple of the burst size
     # Except when we are crossing a 1k boundary, or there has been an AHB error.  We dont model AHB errors in here yet
     # so just take into account the 1k boundary ...
     # First ensure the number of bytes is a multiple of burst_length bytes
     my $num_bytes_to_write     = (length ($frame) / 2);


     if    ($rx_queue_to_use == 0) {$rx_buffer_size = $buffer_size;}
     elsif ($rx_queue_to_use == 1) {$rx_buffer_size = $buffer_size_q1;}
     elsif ($rx_queue_to_use == 2) {$rx_buffer_size = $buffer_size_q2;}
     elsif ($rx_queue_to_use == 3) {$rx_buffer_size = $buffer_size_q3;}
     elsif ($rx_queue_to_use == 4) {$rx_buffer_size = $buffer_size_q4;}
     elsif ($rx_queue_to_use == 5) {$rx_buffer_size = $buffer_size_q5;}
     elsif ($rx_queue_to_use == 6) {$rx_buffer_size = $buffer_size_q6;}
     elsif ($rx_queue_to_use == 7) {$rx_buffer_size = $buffer_size_q7;}
     elsif ($rx_queue_to_use == 8) {$rx_buffer_size = $buffer_size_q8;}
     elsif ($rx_queue_to_use == 9) {$rx_buffer_size = $buffer_size_q9;}
     elsif ($rx_queue_to_use == 10) {$rx_buffer_size = $buffer_size_q10;}
     elsif ($rx_queue_to_use == 11) {$rx_buffer_size = $buffer_size_q11;}
     elsif ($rx_queue_to_use == 12) {$rx_buffer_size = $buffer_size_q12;}
     elsif ($rx_queue_to_use == 13) {$rx_buffer_size = $buffer_size_q13;}
     elsif ($rx_queue_to_use == 14) {$rx_buffer_size = $buffer_size_q14;}
     else                       {$rx_buffer_size = $buffer_size_q15;}

#     print "rx_buffer_size is $rx_buffer_size \n\n\n";
     my $num_of_buffers = int (($num_bytes_to_write - 1) / $rx_buffer_size) + 1;
     if ($tog_cnt_enable == 1) {
       if ($rx_queue_to_use == 1) {
         $total_buffer_countq1 = $total_buffer_countq1 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 2) {
         $total_buffer_countq2 = $total_buffer_countq2 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 3) {
         $total_buffer_countq3 = $total_buffer_countq3 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 4) {
         $total_buffer_countq4 = $total_buffer_countq4 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 5) {
         $total_buffer_countq5 = $total_buffer_countq5 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 6) {
         $total_buffer_countq6 = $total_buffer_countq6 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 7) {
         $total_buffer_countq7 = $total_buffer_countq7 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 8) {
         $total_buffer_countq8 = $total_buffer_countq8 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 9) {
         $total_buffer_countq9 = $total_buffer_countq9 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 10) {
         $total_buffer_countq10 = $total_buffer_countq10 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 11) {
         $total_buffer_countq11 = $total_buffer_countq11 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 12) {
         $total_buffer_countq12 = $total_buffer_countq12 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 13) {
         $total_buffer_countq13 = $total_buffer_countq13 + $num_of_buffers;
         }
       elsif ($rx_queue_to_use == 14) {
         $total_buffer_countq14 = $total_buffer_countq14 + $num_of_buffers;
         }
       else {
         $total_buffer_count = $total_buffer_count + $num_of_buffers;
         }
     }

  $num_ahb_words_to_write = 0;

  while ($frame ne "") {
      my $temp1 = "";
      my $temp2 = "";
      my $data  = "";
      my $z = 4;

      for (my $i = 0; $i < $z; ++$i) {
        if ($frame ne "") {
           $temp1 = chop $frame;
           $temp2 = chop $frame;
        }
        else {
           $temp1 = "0"; # for gem
           $temp2 = "0"; # for gem
        }
        $data = $temp1.$temp2.$data;
      }
      $byte_count = $byte_count + 4;

      $firstrxaccess = 0;
      # $address is an integer, but can be expressed in hexadecimal format
      if (($includerxdma == 1) && ($rxusedbit == 0) && !$i_think_rx_frame_is_dropped)
      {
        if ($data_check == 0) {
          printf {$DMAWR_RXDATA_FH[$rx_queue_to_use_t]} "$control%08x%08xzzzzzzzzff  // Data (not checking), num ahb words = $num_ahb_words_to_write\n", $data_addr_upper_32,$address;
        } else {
          printf {$DMAWR_RXDATA_FH[$rx_queue_to_use_t]} "$control%08x%08x${data}ff  // Data, num ahb words = $num_ahb_words_to_write \n",$data_addr_upper_32, $address;
        }
        $num_ahb_words_to_write = $num_ahb_words_to_write + 1;
      }

      # Incrementing $address here is easier in integer format than hexadecimal
      $address = $address + 4;
      if ($cnt_4byteword == 3) {$cnt_4byteword = 0;}else{$cnt_4byteword++;}

      # Keep a note of how many buffers have been dealt with
      if ($byte_count == $rx_buffer_size or $frame eq "") {
         $buffer_count = $buffer_count + 1;
         $byte_count = 0;
         if (($cnt_4byteword == 1 || $cnt_4byteword == 3) && $width64 == 1 && $includerxdma == 1 && $rxusedbit == 0 && (!$i_think_rx_frame_is_dropped)) {
           $num_ahb_words_to_write = $num_ahb_words_to_write + 1;
           printf {$DMAWR_RXDATA_FH[$rx_queue_to_use_t]} "$control%08x%08x00000000ff  // Padding to 64 bit boundary, $buffer_count, $num_of_buffers, $byte_count, $frame\n", $data_addr_upper_32,$address;
           $address = $address + 4;
         }
         if ($width128 == 1 && $includerxdma == 1 && $rxusedbit == 0 && (!$i_think_rx_frame_is_dropped)) {
           while ($cnt_4byteword != 0) {
              $num_ahb_words_to_write = $num_ahb_words_to_write + 1;
              printf {$DMAWR_RXDATA_FH[$rx_queue_to_use_t]} "$control%08x%08x00000000ff  // Padding to 64 bit boundary, $buffer_count, $num_of_buffers, $byte_count, $frame\n", $data_addr_upper_32,$address;
              $address = $address + 4;
              if ($cnt_4byteword == 3) {$cnt_4byteword = 0;}else{$cnt_4byteword++;}
           }
         }
      }

      # If the address gets to a 1K boundary, then reset the num_ahb_words_to_write
      if ((((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('400')) && $axi_test == 0) ||
           ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('800')) && $axi_test == 0) ||
           ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('c00')) && $axi_test == 0) ||
            (hex(substr((sprintf "%08x", ($address)),5,3)) == hex('000'))) &
           (not ($byte_count == 0))) {$num_ahb_words_to_write = 0};

      # Pad AHB accesses to burst boundary if force_max_burst_rx is set ...
      $num_forced_pad = 0;
      if ($byte_count == 0) {
         if ($width64 == 1) {
            $burst_length = $ahb_burst_size * 2; # double up for 64bit
         } elsif ($width128 == 1) {
            $burst_length = $ahb_burst_size * 4;
         } else {
            $burst_length = $ahb_burst_size;
         }

         if (($force_max_burst_rx == 1) && ($ahb_burst_size != 1)) {
           if  (((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('400')) && $axi_test == 0) ||
                ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('800')) && $axi_test == 0) ||
                ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('c00')) && $axi_test == 0) ||
                 (hex(substr((sprintf "%08x", ($address)),5,3)) == hex('000'))) {
             # If the next address is on a 1k boundary, then definately dont do any pad!
             $num_forced_pad = 0;
           } else {

             $num_forced_pad = int(($burst_length - int ($num_ahb_words_to_write % $burst_length)) % $burst_length) ;
             # check if after padding, the increased accesses will cause the 1k boundary to be broken ...
             print "\n // Padding frame by $num_forced_pad due to config bit to force max burst length ($num_ahb_words_to_write words)";

            if ($axi_test == 1) {
            # in AXI mode, the RX will just do single beat bursts if a max burst will break the 4k boundary rule.
            # This means there wont actually be any pad at all in those cases.
              if (((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('fff')) + (4*$num_forced_pad)) > 4096) {
                 $num_forced_pad = 0;
                 # Uncomment the following if the DUT changes and pads to the 4K boundary
                 #printf {$DMAWR_RXDATA_FH[0]} "// num forced pad(first) = 0x$num_forced_pad\n";
                 #$lower_12_bits_addr = (hex(substr((sprintf "%08x", ($address)),5,3)) & hex('fff'));
                 #printf {$DMAWR_RXDATA_FH[0]} "// addr(lower 12 bits) = 0x%03x\n",$lower_12_bits_addr;
                 #$addr_after_padding = ((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('fff')) + (4*$num_forced_pad));
                 #printf {$DMAWR_RXDATA_FH[0]} "// addr after padding would have been 0x%04x\n",$addr_after_padding;
                 #$num_forced_pad = (4096 - $lower_12_bits_addr) / 4;
                 #printf {$DMAWR_RXDATA_FH[0]} "// num forced pad (final) to take it up to 4K boundary= $num_forced_pad\n";
              }
            } else {


             # If the pad will cause the burst to break the 1k boundary ...
             if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('3ff')) + (4*$num_forced_pad)) <= 1024))
             {
               # the previous burst would have broken the 1k boundary, in this case, the RTL will try to
               # burst to the next biggest burst, but only if we are not on a burst boundary
               if ($ahb_burst_size == 16) {
                 # Try a burst of 8 ...
                 $num_forced_pad = int((($burst_length/2) - int ($num_ahb_words_to_write % ($burst_length/2))) % ($burst_length/2)) ;
                 if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('3ff')) + (4*$num_forced_pad)) <= 1024)) {
                 # No ? then try 4
                   $num_forced_pad = int((($burst_length/4) - int ($num_ahb_words_to_write % ($burst_length/4))) % ($burst_length/4)) ;
                   if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('3ff')) + (4*$num_forced_pad)) <= 1024)) {
                   # No ? then clear num_forced_pad completely
                     $num_forced_pad = 0;
                   }
                 }
               } elsif ($ahb_burst_size == 8) {
                 # Try a burst of 4 ...
                 $num_forced_pad = int((($burst_length/2) - int ($num_ahb_words_to_write % ($burst_length/2))) % ($burst_length/2)) ;
                 if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('3ff')) + (4*$num_forced_pad)) <= 1024)) {
                   # No ? then clear num_forced_pad completely
                   $num_forced_pad = 0;
                 }
               } else {
                # No ? then clear num_forced_pad completely
                $num_forced_pad = 0;
               }
#               } else {$num_forced_pad = 0;}
             }
            }
           }
         }
         if ($num_forced_pad != 0) {
          for (my $a1 = 0;$a1<$num_forced_pad;$a1=$a1+1){
           if ($axi_test) {
             printf {$DMAWR_RXDATA_FH[$rx_queue_to_use]} "$control%08x%08x00000000ff  // Padding to AHB burst boundary\n",$data_addr_upper_32, $address;
           } else {
             printf {$DMAWR_RXDATA_FH[0]} "$control%08x%08x00000000ff  // Padding to AHB burst boundary\n",$data_addr_upper_32, $address;
           }
           $address = $address + 4;
          }
         }
         $num_ahb_words_to_write = 0;
      }

      ###################################################
      # Status and ownership for last buffer in the frame
      if ($buffer_count == $num_of_buffers and $byte_count == 0) {


         my $rx_status = "";

         $vlan_tag_to_dma_descr = "0000";
         $vlan_field_to_dma_descr = $vlan1_field;
         if ($vlan1_frame ne "") {
         # The following masks a minor issue in the RTL - basically if we get an S-TAG without a C-TAG, we still report
         # the VLAN information from STAG through the descriptor. 
         if ((hex($vlan1_frame) == hex("8100")) || (hex($vlan1_frame) == $stacked_vlan_tag)) {
           $vlan_tag_to_dma_descr = "8100";
           $vlan_field_to_dma_descr = $vlan1_field;
         }
         if (hex($vlan2_frame) == hex("8100")) {
           $vlan_tag_to_dma_descr = $vlan2_frame;
           $vlan_field_to_dma_descr = $vlan2_field;
         }
         }
         # If this buffer is the first of the frame
         if ($buffer_count == 1) {
            $rx_status = dma_rx_status(($frame_size), $specific_addr,
                                       $dest_addr_type, "first",
                                       $ipv4_frame,$udp_frame,$tcp_frame,$vlan_tag_to_dma_descr,$vlan_field_to_dma_descr);
         }
         # If this buffer is not the first of the frame
         else {
            $rx_status = dma_rx_status(($frame_size), $specific_addr,
                                       $dest_addr_type, "not_first",
                                       $ipv4_frame,$udp_frame,$tcp_frame,$vlan_tag_to_dma_descr,$vlan_field_to_dma_descr);
         }

         # Write status
         if ($includerxdma == 1 && $rx_do_descr_acc == 1 && ($rxusedbit == 0) && (!$i_think_rx_frame_is_dropped))
         {
           if ($width32 == 1) {
             if ($ext_bd_rx == 1) {  # write timestamp in extended bd mode
                if ($addr64 == 0) {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 3)\n", $descr_addr_upper_32,$cur_rx_ptr + 12;  # WORD 3
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 2)\n", $descr_addr_upper_32,$cur_rx_ptr + 8;   # WORD 2
                } else {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 5)\n", $descr_addr_upper_32,$cur_rx_ptr + 20;  # WORD 5
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 4)\n", $descr_addr_upper_32,$cur_rx_ptr + 16;  # WORD 4
                }
             }
             # WORD 1 followed by WORD 0 always written
             printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for last buffer word 1\n", $descr_addr_upper_32,$cur_rx_ptr + 4, $rx_status;     # WORD 1
             if (($ext_bd_rx == 1) && ($ts_mode_rx == 3)) {
               printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for last buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 5;  # +5 sets extension bit + ownership bit
             } else {
               printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for last buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +1 ownership bit
             }
           }

           else  {
             if ($ext_bd_rx == 1) {  # write timestamp in extended bd mode
                if ($addr64 == 0) {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 2)\n", $descr_addr_upper_32,$cur_rx_ptr + 8;  # WORD 2
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 3)\n", $descr_addr_upper_32,$cur_rx_ptr + 12;  # WORD 3
                } else {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 4)\n", $descr_addr_upper_32,$cur_rx_ptr + 16;  # WORD 4
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 5)\n", $descr_addr_upper_32,$cur_rx_ptr + 20;  # WORD 5
                }
             }
             # WORD 0 and WORD 1 written
             if (($ext_bd_rx == 1) && ($ts_mode_rx == 3)) {
               printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for last buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 5;  # +5 sets extension bit + sets ownership bit
             } else {
               printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for last buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +1 sets ownership bit
             }
             printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for last buffer word 1\n", $descr_addr_upper_32,$cur_rx_ptr + 4, $rx_status;     # WORD 1
           }
         }

         #printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "// cur_rx_ptr before addition was %0x\n",$cur_rx_ptr;
         if ($rxwrapbit == 1 && ($rxusedbit == 0)) {
           $cur_rx_ptr = hex ($rx_q_pointer[$rx_queue_to_use]);
         } elsif ($rxusedbit == 0) {
           $cur_rx_ptr = $cur_rx_ptr + 8 + 8*$addr64 + 8*$ext_bd_rx;
         }
         #printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "// cur_rx_ptr is now %0x, wrap bit was $rxwrapbit, used was $rxusedbit\n",$cur_rx_ptr;
         $rx_pointer[$rx_queue_to_use] = $cur_rx_ptr;

         if ($rx_gen_int_in == 1 && $rxusedbit == 0) {
           $total_num_rx_frames++;
           if ($rx_queue_to_use == 0) {
             print APBFILE "00000000a002400000002   // Packet received Interrupt Q0\n";
             print APBFILE "000000004002400000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 1) {
             print APBFILE "00000010a040000000002   // Packet received Interrupt Q1\n";
             print APBFILE "000000104040000000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 2) {
             print APBFILE "00000020a040400000002   // Packet received Interrupt Q2\n";
             print APBFILE "000000204040400000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 3) {
             print APBFILE "00000030a040800000002   // Packet received Interrupt Q3\n";
             print APBFILE "000000304040800000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 4) {
             print APBFILE "00000040a040c00000002   // Packet received Interrupt Q4\n";
             print APBFILE "000000404040c00000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 5) {
             print APBFILE "00000050a041000000002   // Packet received Interrupt Q5\n";
             print APBFILE "000000504041000000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 6) {
             print APBFILE "00000060a041400000002   // Packet received Interrupt Q6\n";
             print APBFILE "000000604041400000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 7) {
             print APBFILE "00000070a041800000002   // Packet received Interrupt Q7\n";
             print APBFILE "000000704041800000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 8) {
             print APBFILE "00000080a041c00000002   // Packet received Interrupt Q8\n";
             print APBFILE "000000804041c00000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 9) {
             print APBFILE "00000090a042000000002   // Packet received Interrupt Q9\n";
             print APBFILE "000000904042000000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 10) {
             print APBFILE "000000a0a042400000002   // Packet received Interrupt Q10\n";
             print APBFILE "000000a04042400000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 11) {
             print APBFILE "000000b0a042800000002   // Packet received Interrupt Q11\n";
             print APBFILE "000000b04042800000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 12) {
             print APBFILE "000000c0a042c00000002   // Packet received Interrupt Q12\n";
             print APBFILE "000000c04042c00000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 13) {
             print APBFILE "000000d0a043000000002   // Packet received Interrupt Q13\n";
             print APBFILE "000000d04043000000002   // Write to clear\n";
           } elsif ($rx_queue_to_use == 14) {
             print APBFILE "000000e0a043400000002   // Packet received Interrupt Q14\n";
             print APBFILE "000000e04043400000002   // Write to clear\n";
           } else {
             print APBFILE "000000f0a043800000002   // Packet received Interrupt Q15\n";
             print APBFILE "000000f04043800000002   // Write to clear\n";
           }
           return (0);
         }
      }


      ##########################################################################
      # Status and ownership for end of 1st buffer (that is not the last buffer)
      elsif ($buffer_count == 1 and $frame ne "" and $byte_count == 0) {
         if ($includerxdma == 1 && $rx_do_descr_acc == 1 && ($rxusedbit == 0) && (!$i_think_rx_frame_is_dropped))
         {
           if ($width32 == 1) {
             if ($ext_bd_rx == 1) {  # write timestamp in extended bd mode
                if ($addr64 == 0) {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 3)\n", $descr_addr_upper_32,$cur_rx_ptr + 12;  # WORD 3
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 2)\n", $descr_addr_upper_32,$cur_rx_ptr + 8;  # WORD 2
                } else {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 5)\n", $descr_addr_upper_32,$cur_rx_ptr + 20;  # WORD 5
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 4)\n", $descr_addr_upper_32,$cur_rx_ptr + 16;  # WORD 4
                }
             }
             # WORD 1 followed by WORD 0 always written
             printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x00004000ff  // Writeback for 1st buffer word 1\n", $descr_addr_upper_32,$cur_rx_ptr + 4;     # WORD 1
             if (($ext_bd_rx == 1) && ($ts_mode_rx == 3)) {
               printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for 1st buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +5 sets extension bit + ownership bit
             }
             else {
               printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for 1st buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +1 ownership bit
             }
           }

           else {
             if ($ext_bd_rx == 1) {  # write timestamp in extended bd mode
                if ($addr64 == 0) {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 2)\n", $descr_addr_upper_32,$cur_rx_ptr + 8;  # WORD 2
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 3)\n", $descr_addr_upper_32,$cur_rx_ptr + 12;  # WORD 3
                } else {
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 4)\n", $descr_addr_upper_32,$cur_rx_ptr + 16;  # WORD 4
                  printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 5)\n", $descr_addr_upper_32,$cur_rx_ptr + 20;  # WORD 5
                }
             }
             # WORD 0 and WORD 1 written
             printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff       // Writeback for 1st buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +1 sets ownership bit
             printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x00004000ff   // Writeback for 1st buffer word 1\n", $descr_addr_upper_32,$cur_rx_ptr + 4;     # WORD 1
           }
         }

         if ($rxwrapbit == 1 && ($rxusedbit == 0)) {
           $cur_rx_ptr = hex ($rx_q_pointer[$rx_queue_to_use]);
         } elsif ($rxusedbit == 0) {
           $cur_rx_ptr = $cur_rx_ptr + 8 + 8*$addr64 + 8*$ext_bd_rx;
         }
         $rx_pointer[$rx_queue_to_use] = $cur_rx_ptr;

         # Generate rx buffer location and make sure the used bit
         # is not set and only allow the wrap bit to be set occasionally
         $wrap_offset =0;
         $init_address = generate_field(4,4,"random","byte");

         if ($rxusedbit == 0) {
           $rxusedbit = 1;
           while ($rxusedbit == 1) {
             if ($resource_err eq "random") {$rxusedbit = int(rand(2));}
             else {$rxusedbit = $resource_err;}

             if ($rxusedbit == 1) {
               if ($ext_bd_rx == 0) {
                  $init_address = (sprintf "%08x", (hex($init_address) | hex('00000001')));
                } else {
                  $init_address = (sprintf "%08x", ((hex($init_address) | hex('00000001')) & hex('fffffffb'))); # set bit[2] = 0
                }
             } else {

               if ($ext_bd_rx == 0) {
                  $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffe')));
                } else {
                  $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffa'))); # set bit[2] = 0
                }
             }
             
             # generate data for rx dma buffer manager
             if (($includerxdma == 1) && ($rx_do_descr_acc == 1) && (!$i_think_rx_frame_is_dropped))
             {
               my $data_addr_upper_32_str = 0;
               for (my $queue_cnt=($num_dma_queues-1);$queue_cnt>=0;$queue_cnt--) {
                 $curr_q_ptr =$rx_pointer[$queue_cnt];

                 $line_to_write = "0".(sprintf "%08x", ($descr_addr_upper_32)).(sprintf "%08x", ($curr_q_ptr)).$init_address."  // Descriptor Read (This is the 2nd buffer of frame $cur_frame_idx) - used = $rxusedbit\n";

                 if ($addr64) {
                   $data_addr_upper_32 = int(rand(2**32));
                   if ($queue_cnt == $rx_queue_to_use) {
                     $data_addr_upper_32_str = $data_addr_upper_32;
                   }
                   # always does 32b reads
                   $line_to_write = $line_to_write . "0".(sprintf "%08x", ($descr_addr_upper_32)).(sprintf "%08x", ($curr_q_ptr+8)).(sprintf "%08x", $data_addr_upper_32)."  // Descriptor Read (2nd buffer, frame  $cur_frame_idx) - upper address\n";
                 }
                 if ($rx_queue_to_use == $queue_cnt) {
                   $write_line_en = 1;
                 } else {
                   $write_line_en = 0;
                 }
                 if ($write_line_en) {
                   if ($axi_test == 0) {
                     printf {$DMARD_RXDESCR_FH[0]} $line_to_write;
                   } else {
                     printf {$DMARD_RXDESCR_FH[$queue_cnt]} $line_to_write;
                   }
                 }
               }
               $data_addr_upper_32 = $data_addr_upper_32_str;
             }
             if ($rxusedbit == 1) {
               if ($rx_gen_int_in == 1) {
                 if ($rx_queue_to_use == 0) {
                   print APBFILE "00000000a002400000004   // Resource Error Interrupt (on 2nd buffer) Q0\n";
                   print APBFILE "000000004002400000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 1) {
                   print APBFILE "00000010a040000000004   // Resource Error Interrupt (on 2nd buffer) Q1\n";
                   print APBFILE "000000104040000000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 2) {
                   print APBFILE "00000020a040400000004   // Resource Error Interrupt (on 2nd buffer) Q2\n";
                   print APBFILE "000000204040400000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 3) {
                   print APBFILE "00000030a040800000004   // Resource Error Interrupt (on 2nd buffer) Q3\n";
                   print APBFILE "000000304040800000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 4) {
                   print APBFILE "00000040a040c00000004   // Resource Error Interrupt (on 2nd buffer) Q4\n";
                   print APBFILE "000000404040c00000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 5) {
                   print APBFILE "00000050a041000000004   // Resource Error Interrupt (on 2nd buffer) Q5\n";
                   print APBFILE "000000504041000000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 6) {
                   print APBFILE "00000060a041400000004   // Resource Error Interrupt (on 2nd buffer) Q6\n";
                   print APBFILE "000000604041400000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 7) {
                   print APBFILE "00000070a041800000004   // Resource Error Interrupt (on 2nd buffer) Q7\n";
                   print APBFILE "000000704041800000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 8) {
                   print APBFILE "00000080a041c00000004   // Resource Error Interrupt (on 2nd buffer) Q8\n";
                   print APBFILE "000000804041c00000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 9) {
                   print APBFILE "00000090a042000000004   // Resource Error Interrupt (on 2nd buffer) Q9\n";
                   print APBFILE "000000904042000000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 10) {
                   print APBFILE "000000a0a042400000004   // Resource Error Interrupt (on 2nd buffer) Q10\n";
                   print APBFILE "000000a04042400000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 11) {
                   print APBFILE "000000b0a042800000004   // Resource Error Interrupt (on 2nd buffer) Q11\n";
                   print APBFILE "000000b04042800000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 12) {
                   print APBFILE "000000c0a042c00000004   // Resource Error Interrupt (on 2nd buffer) Q12\n";
                   print APBFILE "000000c04042c00000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 13) {
                   print APBFILE "000000d0a043000000004   // Resource Error Interrupt (on 2nd buffer) Q13\n";
                   print APBFILE "000000d04043000000004   // Write to clear\n";
                 } elsif ($rx_queue_to_use == 14) {
                   print APBFILE "000000e0a043400000004   // Resource Error Interrupt (on 2nd buffer) Q14\n";
                   print APBFILE "000000e04043400000004   // Write to clear\n";
                 } else {
                   print APBFILE "000000f0a043800000004   // Resource Error Interrupt (on 2nd buffer) Q15\n";
                   print APBFILE "000000f04043800000004   // Write to clear\n";
                 }
               }
              if ($rx_auto_discard_pkts     or $rx_auto_discard_pkts_q0  or $rx_auto_discard_pkts_q1  or $rx_auto_discard_pkts_q2  or                            
                  $rx_auto_discard_pkts_q3  or $rx_auto_discard_pkts_q4  or $rx_auto_discard_pkts_q5  or $rx_auto_discard_pkts_q6  or
                  $rx_auto_discard_pkts_q7  or $rx_auto_discard_pkts_q8  or $rx_auto_discard_pkts_q9  or $rx_auto_discard_pkts_q10 or
                  $rx_auto_discard_pkts_q11 or $rx_auto_discard_pkts_q12 or $rx_auto_discard_pkts_q13 or $rx_auto_discard_pkts_q14 or $rx_auto_discard_pkts_q15) {last;}
             }
           }
         }

         $rxwrapbit = (hex($init_address) & hex('00000002')) >> 1 ; # Extract wrap bit
         if ($rxwrapbit == 1) {
           $wrap_offset = 2;
         }

         # assign base address of rx buffer
         $address = hex($init_address) - $wrap_offset; # need to subtract 2 if the wrap bit is set
         if ($width64 == 1) {
           $address = ($address & hex('fffffffb')); # ensure the address is 64bit aligned
         }
         if ($width128 == 1) {
           $address = ($address & hex('fffffff3')); # ensure the address is 128bit aligned
         }
         $wrap_offset =0;

         $init_address = hex ($init_address);

      }

      ##################################################################
      # Status and ownership for buffer which is neither the 1st or last
      elsif ($buffer_count > 1 and $frame ne "" and $byte_count == 0) {
        if ($includerxdma == 1 && $rx_do_descr_acc == 1 && ($rxusedbit == 0) && (!$i_think_rx_frame_is_dropped)) {
          if ($width32 == 1) {
            if ($ext_bd_rx == 1) {  # write timestamp in extended bd mode
               if ($addr64 == 0) {
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 3)\n", $descr_addr_upper_32,$cur_rx_ptr + 12;  # WORD 3
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 2)\n", $descr_addr_upper_32,$cur_rx_ptr + 8;  # WORD 2
               } else {
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 5)\n", $descr_addr_upper_32,$cur_rx_ptr + 20;  # WORD 5
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 4)\n", $descr_addr_upper_32,$cur_rx_ptr + 16;  # WORD 4
               }
            }
            # WORD 1 followed by WORD 0 always written
            # Write null status
            printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x00000000ff  // Writeback for mid buffer word 1\n", $descr_addr_upper_32,$cur_rx_ptr + 4;     # WORD 1
            printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for mid buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +1 ownership bit
          } else {
            if ($ext_bd_rx == 1) {  # write timestamp in extended bd mode
               if ($addr64 == 0) {
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 2)\n", $descr_addr_upper_32,$cur_rx_ptr + 8;  # WORD 2
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 3)\n", $descr_addr_upper_32,$cur_rx_ptr + 12;  # WORD 3
               } else {
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 4)\n", $descr_addr_upper_32,$cur_rx_ptr + 16;  # WORD 4
                 printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x${dont_care}ff  // Writeback for TS status (Descriptor word 5)\n", $descr_addr_upper_32,$cur_rx_ptr + 20;  # WORD 5
               }
            }
            # WORD 0 and WORD 1 written
            printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x%08xff  // Writeback for mid buffer word 0\n", $descr_addr_upper_32,$cur_rx_ptr, $init_address + 1;  # +1 sets ownership bit
            printf {$DMAWR_RXDESCR_FH[$rx_queue_to_use_t]} "$control%08x%08x00000000ff  // Writeback for mid buffer word 1\n", $descr_addr_upper_32,$cur_rx_ptr + 4;     # WORD 1
          }
        }

        if ($rxwrapbit == 1 && ($rxusedbit == 0)) {
          $cur_rx_ptr = hex ($rx_q_pointer[$rx_queue_to_use]);
        } elsif ($rxusedbit == 0) {
          $cur_rx_ptr = $cur_rx_ptr + 8 + 8*$addr64 + 8*$ext_bd_rx;
        }
        $rx_pointer[$rx_queue_to_use] = $cur_rx_ptr;

        $init_address = generate_field(4,4,"random","byte");
        if ($rxusedbit == 0) {
          $rxusedbit = 1;
          while ($rxusedbit == 1) {

            if ($resource_err eq "random") {$rxusedbit = int(rand(2));}
            else {$rxusedbit = $resource_err;}
            if ($rxusedbit == 1) {
              if ($ext_bd_rx == 0) {
                 $init_address = (sprintf "%08x", (hex($init_address) | hex('00000001')));
               } else {
                 $init_address = (sprintf "%08x", ((hex($init_address) | hex('00000001')) & hex('fffffffb'))); # set bit[2] = 0
               }
            } else {

              if ($ext_bd_rx == 0) {
                 $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffe')));
               } else {
                 $init_address = (sprintf "%08x", (hex($init_address) & hex('fffffffa'))); # set bit[2] = 0
               }
            }

            # generate data for rx dma buffer manager
            if (($includerxdma == 1) && ($rx_do_descr_acc == 1) && (!$i_think_rx_frame_is_dropped)) {
              my $data_addr_upper_32_str = 0;
              for (my $queue_cnt=($num_dma_queues-1);$queue_cnt>=0;$queue_cnt--) {
                $curr_q_ptr =$rx_pointer[$queue_cnt];

                $line_to_write = "0".(sprintf "%08x", ($descr_addr_upper_32)).(sprintf "%08x", ($curr_q_ptr)).$init_address."  // Descriptor Read (This is the >2nd buffer of frame $cur_frame_idx) - used = $rxusedbit\n";

                if ($addr64) {
                  $data_addr_upper_32 = int(rand(2**32));
                  if ($queue_cnt == $rx_queue_to_use) {
                    $data_addr_upper_32_str = $data_addr_upper_32;
                  }
                  # always does 32b reads
                  $line_to_write = $line_to_write . "0".(sprintf "%08x", ($descr_addr_upper_32)).(sprintf "%08x", ($curr_q_ptr+8)).(sprintf "%08x", $data_addr_upper_32)."  // Descriptor Read (>2nd buffer for frame $cur_frame_idx) - upper address\n";
                }
                if ($rx_queue_to_use == $queue_cnt) {
                  $write_line_en = 1;
                } else {
                  $write_line_en = 0;
                }
                if ($write_line_en) {
                  if ($axi_test == 0) {
                    printf {$DMARD_RXDESCR_FH[0]} $line_to_write;
                  } else {
                    printf {$DMARD_RXDESCR_FH[$queue_cnt]} $line_to_write;
                  }
                }
              }
              $data_addr_upper_32 = $data_addr_upper_32_str;
            }

            if ($rxusedbit == 1) {
              if ($rx_gen_int_in == 1) {
                if ($rx_queue_to_use == 0) {
                  print APBFILE "0000000a0002400000004   // Resource Error Interrupt (on >2nd buffer) Q0\n";
                  print APBFILE "000000040002400000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 1) {
                  print APBFILE "00000010a040000000004   // Resource Error Interrupt (on >2nd buffer) Q1\n";
                  print APBFILE "000000104040000000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 2) {
                  print APBFILE "00000020a040400000004   // Resource Error Interrupt (on >2nd buffer) Q2\n";
                  print APBFILE "000000204040400000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 3) {
                  print APBFILE "00000030a040800000004   // Resource Error Interrupt (on >2nd buffer) Q3\n";
                  print APBFILE "000000304040800000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 4) {
                  print APBFILE "00000040a040c00000004   // Resource Error Interrupt (on >2nd buffer) Q4\n";
                  print APBFILE "000000404040c00000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 5) {
                  print APBFILE "00000050a041000000004   // Resource Error Interrupt (on >2nd buffer) Q5\n";
                  print APBFILE "000000504041000000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 6) {
                  print APBFILE "00000060a041400000004   // Resource Error Interrupt (on >2nd buffer) Q6\n";
                  print APBFILE "000000604041400000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 7) {
                  print APBFILE "00000070a041800000004   // Resource Error Interrupt (on >2nd buffer) Q7\n";
                  print APBFILE "000000704041800000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 8) {
                  print APBFILE "00000080a041c00000004   // Resource Error Interrupt (on >2nd buffer) Q8\n";
                  print APBFILE "000000804041c00000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 9) {
                  print APBFILE "00000090a042000000004   // Resource Error Interrupt (on >2nd buffer) Q9\n";
                  print APBFILE "000000904042000000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 10) {
                  print APBFILE "000000a0a042400000004   // Resource Error Interrupt (on >2nd buffer) Q10\n";
                  print APBFILE "000000a04042400000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 11) {
                  print APBFILE "000000b0a042800000004   // Resource Error Interrupt (on >2nd buffer) Q11\n";
                  print APBFILE "000000b04042800000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 12) {
                  print APBFILE "000000c0a042c00000004   // Resource Error Interrupt (on >2nd buffer) Q12\n";
                  print APBFILE "000000c04042c00000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 13) {
                  print APBFILE "000000d0a043000000004   // Resource Error Interrupt (on >2nd buffer) Q13\n";
                  print APBFILE "000000d04043000000004   // Write to clear\n";
                } elsif ($rx_queue_to_use == 14) {
                  print APBFILE "000000e0a043400000004   // Resource Error Interrupt (on >2nd buffer) Q14\n";
                  print APBFILE "000000e04043400000004   // Write to clear\n";
                } else {
                  print APBFILE "000000f0a043800000004   // Resource Error Interrupt (on >2nd buffer) Q15\n";
                  print APBFILE "000000f04043800000004   // Write to clear\n";
                }
              }
              if ($rx_auto_discard_pkts     or $rx_auto_discard_pkts_q0  or $rx_auto_discard_pkts_q1  or $rx_auto_discard_pkts_q2  or
                  $rx_auto_discard_pkts_q3  or $rx_auto_discard_pkts_q4  or $rx_auto_discard_pkts_q5  or $rx_auto_discard_pkts_q6  or
                  $rx_auto_discard_pkts_q7  or $rx_auto_discard_pkts_q8  or $rx_auto_discard_pkts_q9  or $rx_auto_discard_pkts_q10 or
                  $rx_auto_discard_pkts_q11 or $rx_auto_discard_pkts_q12 or $rx_auto_discard_pkts_q13 or $rx_auto_discard_pkts_q14 or $rx_auto_discard_pkts_q15) {last;}
            }
          }
        }

        # Generate rx buffer location and make sure the used bit
        # is not set and only allow the wrap bit to be set occasionally
        $wrap_offset =0;
        $rxwrapbit = (hex($init_address) & hex('00000002')) >> 1 ; # Extract wrap bit
        if ($rxwrapbit == 1) {
           $wrap_offset = 2;
        }
        # assign base address of rx buffer
        $address = hex($init_address) - $wrap_offset; # need to subtract 2 if the wrap bit is set
        if ($width64 == 1) {
          $address = ($address & hex('fffffffb')); # ensure the address is 64bit aligned
        }
        if ($width128 == 1) {
          $address = ($address & hex('fffffff3')); # ensure the address is 128bit aligned
        }

        $wrap_offset =0;
        $init_address = hex ($init_address);

      }
    }
  } # End of main while loop
}

################################################################################
# dma_rx_status
#
# - Subroutine to determine the rx status of the last buffer in a frame
################################################################################
sub dma_rx_status {
   my ($frame_size, $specific_addr, $dest_addr_type, $buffer_order,$ipv4_frame,$udp_frame,$tcp_frame,$vlan1_frame,$vlan1_field) = @_;

   my $rx_status  = 0;  #"0x00000000";

   if (($pcs_loopback == 0) && ($ext_loopback == 0)) {  # For the PCS loopback tests, we will be copying all frames, so wont be writing anything here
     if ($dest_addr_type eq "broadcast") {
        # Assert bit 31
        $rx_status = $rx_status + 0x80000000;
     }
     elsif ($dest_addr_type eq "unicast" or $dest_addr_type eq "multicast") {
        # Assert bit 27 or 28
        if ($extra_spec_adds_en == 1) {
          $rx_status = $rx_status + 0x10000000;
        } else {
          $rx_status = $rx_status + 0x08000000;
        }
        # Reverse the hash to get the original "key" from the "value".
        my %address_temp = reverse %address;
        my $key = $address_temp {$specific_addr};

        # Change this variable to become the hexadecimal equivalent for the values
        # of bits 26 and 25
        $key = ("01000000" * (($key - 1) * 2));

        $key = hex $key;
        $rx_status = $rx_status + $key;
     }
   }

   # If the buffer is the only buffer for the frame, assert bits 15 and 14
   if ($buffer_order eq "first") {
      $rx_status = $rx_status + 0x0000c000;
   }
   # If the buffer is not the 1st in the frame, assert bit 15
   else {
      $rx_status = $rx_status + 0x00008000;
   }

   if ($rx_toe == 1) {
     if ($tcp_frame == 1)  {
       $rx_status = $rx_status + 0x00800000;
     } elsif  ($udp_frame == 1)  {
       $rx_status = $rx_status + 0x00c00000;
     } elsif  ($ipv4_frame == 1)  {
       $rx_status = $rx_status + 0x00400000;
     }
   }

   if (hex($vlan1_frame) == hex(8100))  {
     $rx_status = $rx_status + 0x00200000;
     # Extract PCP - Priority Code Point
     $pcp = sprintf "%01x", ((hex($vlan1_field) & hex("e000")) >> 12);
     $pcp = "000".$pcp."0000";
     $rx_status = $rx_status + hex($pcp);
     $cfi = sprintf "%01x", ((hex($vlan1_field) & hex("1000")) >> 12);
     $cfi = "000".$cfi. "0000";
     $rx_status = $rx_status + hex($cfi);
     #print "FIELD is $vlan1_field, PCP is $pcp, CFI is $cfi\n";
     $vid = sprintf "%03x", (hex($vlan1_field) & hex("0fff"));
     if (hex($vid) == 0) {$rx_status = $rx_status + 0x00100000;}
   }

   return $rx_status = $rx_status + $frame_size;
}



################################################################################
# reorder_string
#
# - Subroutine to change the nibble order of a string.  E.g. changes 12345678
#   into 78563412.
################################################################################
sub reorder_string {
   my ($string) = @_;

   my $new_string = "";
   my $string_length = length ($string);

   for (my $i = 0; $i < $string_length; ++$i) {
      my $temp = chop $string;
      $temp = (chop $string).$temp;
      $new_string = $new_string.$temp;
   }
   return $new_string;
}



################################################################################
# get_line_data
#
# - Subroutine to read the data from a testcase line
# Removes comments (anything with # or --)
################################################################################
sub get_line_data {
   my ($line) = @_;

   my $line_data = "";         # Will hold the data on the current command line
   if ($line =~ /\s*[a-zA-Z0-9_]+\s+(.+)$/) {$line_data = $1; $line_data =~ s/(\s+|\r|\n)//g;}
   return ($line_data);         # Return the data on the current command line
}


################################################################################
# get_range
#
# - Subroutine to take a string in the format "$num1-$num2", and output the max
#   and min numbers
################################################################################
sub get_range {
   my ($data) = @_;

   my $num1     = "";
   my $num2     = "";

   my $max_size = "";
   my $min_size = "";

   my $temp = chop ($data);

   $data = "S".$data;  # Mark the start of $data

   while ($temp =~ '\s') {  # remove blanks
      $temp = chop ($data);
   }

   # Get the max size (the data to the right of the "-")
   while ($temp ne '-' and $temp ne ' ' and $temp ne '	') {
      $num1 = $temp.$num1;
      $temp = chop ($data);
   }

   $temp = chop ($data);  # Lose the "-"

   # Get the min size (the data to the left of the "-")
   while ($temp ne 'S') {
      $num2 = $temp.$num2;
      $temp = chop ($data);
   }

   # Determine which number is the max, and which is the min, size in the range
   if ($num1 > $num2) {
      $max_size = $num1;
      $min_size = $num2;
   }
   else {
      $max_size = $num2;
      $min_size = $num1;
   }

   return ($min_size, $max_size);
}



################################################################################
# generate_field
#
# - Subroutine to generate a field of a random size (within a boundary) and of
#   either specfic or random data
################################################################################
sub generate_field {
   my ($min_size, $max_size, $value, $format) = @_;

   # Calculate a random size for the field within the given range
   my $random_size = int(rand($max_size - $min_size + 1) + $min_size);
   my $field = "";

   if ($format eq "byte") {
      $random_size = $random_size * 2;
   }

   for (my $i = 0; $i < $random_size; ++$i) {

      # If a random field data is required
      if ($value eq "random") {
         $field = $field.random_hex();
      }

      # If a specific value of field data is required
      else {
         $field = $field.$value;
      }
   }

   return ($field);
}


################################################################################
# random_hex
#
# - Subroutine to return a single random hexadecimal number
################################################################################
sub random_hex {

   my $temp = int( rand(16) );

   # Convert to hexadecimal
   if ($temp eq "10") {$temp = "a"}
   if ($temp eq "11") {$temp = "b"}
   if ($temp eq "12") {$temp = "c"}
   if ($temp eq "13") {$temp = "d"}
   if ($temp eq "14") {$temp = "e"}
   if ($temp eq "15") {$temp = "f"}

   return ($temp);
}





################################################################################
#
# sub gen_crc()
#   parameters: arg0 - string containing hex data field
#               arg1 - if 1 prints out debug info
#   returns:    1) a string containing the hexidecimal data value including CRC
#               2) a string containing the hexidecimal crc value
#               3) a string containing the number of bytes of preamble detected
#
################################################################################
# Currently assume data = 6bytes Dest Addr, 6bytes Source Addr, 2bytes length,
# at least 46-1500 bytes of data.
# If the data is less than 46 bytes then it will be padded to 46 bytes with
# extra 0's
################################################################################

sub gen_crc {
   my ($data, $debug)  = @_;
   #print "** @_\n\n\n\n";

   my ($in, $length_data, $temp);

   # initial value is 11.. as spec requires first 32 bits of input data to be
   # inverted.
   #               MSB         ->              LSB.
   my $crc      = "11111111111111111111111111111111";
   my $gen_poly = "100000100110000010001110110110111";
   my $preamble_count = "0";
   my $sym_err_count = "0";
   my $preamble = "";
   my $crc_en = 0;

   # Removes the preamble and SFD from the data
   if ($data =~ /^(5+)d5(.*)$/ ) {
      $data = $2;
      $preamble_count = (length $1)/2;
      $preamble  = "$1"."d5";
   }

   # Removes the CRC place holders if there are any
   if ($data =~ /^(.*)gggggggg$/ ) {
      $crc_en = 1;
      $data = $1;
   }
   # Removes error symbol place holders if there are any
   elsif ($data =~ /^(.*?)(v+)$/ ) {
      $data = $1;
      $sym_err_count = (length $2)/2;
   }

   # Add padding if required to take data to minimum of 46 bytes
   # if (length $data < 120) { $data .= "0" x (120 - length $data); }

   if (!$crc_en) {
      return ("$preamble"."$data", "", $preamble_count, $sym_err_count);
   }
   if ($debug >= 1) {printf "\n\nCRC Summary\n------------------------------";}

   print "\nInitial $crc\n" if ($debug >= "3");


   my $crc_data = $data;
   # Replaces error markers with 0's for purpose of CRC calculation
   #$crc_data =~ s/(xx|yy|zz)/00/g;

   $length_data = (length ($crc_data))/2;

   for (1 .. $length_data) {
      my $byte;
      if ($crc_data =~ /^(..)(.*)$/ ) {
         # $byte = sprintf ("%08b", oct("0x"."$1"));
         $byte = sprintfdec2bin (8, oct("0x"."$1"));
         print "$1 $byte\n" if ($debug >= "3");
         $crc_data   = $2;
      } else {
         print "\nError: There is a length mismatch with the data input.\n";
      }

      for (my $i=7; $i >= 0; $i--) {
         $in = substr ($byte, $i, 1);
         $crc = inc_crc ($in, $crc, $gen_poly);
         if ($debug >= "3") {
            $temp = sprintf ("%08x", samoct("0b"."$crc"));
            print "$crc  $temp\n";
         }
      }
   }

   print "\n\nFinal CRC:\t\t$crc\n" if ($debug >= "2");
   $crc = reverse_inverse($crc);
   print "RevInv:\t\t\t$crc\n" if ($debug >= "2");
   $crc = reorder_msb2lsb($crc);
   print "Byte Reordered\t\t$crc" if ($debug >= "2");
   $crc = samoct("0b"."$crc");
   $crc = sprintf ("%08x", $crc);

   print "\nCalculated CRC:\t\t$crc" if ($debug >= "1");
   print "\nOutput data:\t\t$preamble$data$crc\n" if ($debug >= "2");
   print "Preamble count:\t\t$preamble_count\n" if ($debug >= "2");

   return ("$preamble"."$data"."$crc", $crc, $preamble_count, $sym_err_count);
}



sub inc_crc {
   my ($in, $res, $poly)  = @_;
   my ($msb, $fb, $new_res, $length, $new_val);

   if ($res =~ /^(.)/) { $msb = $1; }
   $fb = 0+$in ^ 0+$msb;

   if ($fb) {
      $new_res = "1";
      chop $poly;   # dont need the x^0 tap.
      $length = length($res) - 1;

      for (1 .. $length) {
         $new_val = 0+(chop $poly) ^ 0+(chop $res);
         $new_res = "$new_val" . "$new_res";
      }

   } else {
      $new_res = reg_sl($res, "0");
   }

   return ($new_res);
}


sub reg_sl {
   my ($reg, $in)  = @_;
   if ($reg =~ /^.(.*)$/) { $reg = "$1"."$in"; }
   else { print "\nError: function reg_sl did not match $reg properly.\n";}
   return ($reg);
}

sub reverse_inverse {
   my ($in)  = @_;
   my ($char);
   my $out = "";
   for (my $i=0; $i <= length($in) - 1; $i++) {
      $char = substr ($in, $i, 1);
      if ($char) { $out = "0"."$out"; }
      else       { $out = "1"."$out"; }
   }
   return ($out);
}

sub reorder_msb2lsb {
   my ($in)  = @_;
   my ($byte);
   my $out = "";
   for (my $i=0; $i <= 3; $i++) {
      $byte = substr ($in, 8*$i, 8);
      $out = "$byte"."$out";
   }
   return ($out);
}




################################################################################
# read_tx_frame
#
# - Subroutine to read the current testcase for Rx frame data
################################################################################
sub read_tx_frame {

   my ($num_of_frames) = @_;

   my $temp          = "";
   my $control       = "";

   $temp = chop ($command);  # $temp takes the value of the last letter in
                             # $command

   while ($temp =~ '\s') {$temp = chop ($command)} # remove blanks

   generate_tx_frames ($num_of_frames);
}



################################################################################
# generate_tx_frames
#
# - Subroutine to generate the required tx frames
################################################################################
sub generate_tx_frames {
   my ($num_of_frames) = @_;

   my @command        = ""; # The array that the frame information is stored in
   my $i              = 0;

   my $min_size       = "";
   my $max_size       = "";
   my $min_buffer_size = "";
   my $max_buffer_size = "";
   my $min_no_bufs    = "";
   my $max_no_bufs    = "";
   my $no_of_bufs     = "";

   my $fcs_size       =  "8"; # Size of the FCS field (in nibbles)

   # Strings to hold the frame information
   my $frame          = "";
   my $frame_temp     = "";
   my $preamble_size  = "7";
   my $preamble       = "";
   my $sfd            = "d5";
   my $data_field     = "";
   my $new_data_field = "";
   my $buffer_size    = "";
   my $pad_size       = "";
   my $pad            = "";
   my $fcs            = "";
   my $fcs_no_append_by_mac = 0;
   my $fix_wrap       = 0;
   my $q0_size_fixed     = 0;
   my $q0_buffer_size    = "";
   my $q1_size_fixed     = 0;
   my $q1_buffer_size    = "";
   my $q2_size_fixed     = 0;
   my $q2_buffer_size    = "";
   my @queue_distribution ;
   my @q_dist_fixed;
   my $queue_has_been_fixed     = 0;


   # This while statement stores all the lines referring to the tx frame in an
   # array @command.
   while (!($command[$i - 1] =~ /^\s*fcs/)) {
      $command[$i] = <TESTCASE>;
      chop($command[$i]);             # remove carriage return
      $command[$i] =~ s/--.*//;       # ignore comments
      $command[$i] =~ tr/A-Z/a-z/;    # make all lower case
      ++$i;
   }

  $num_collisions = 0;
  $too_many_col = 0;

   # This first for-loop cycles through each frame that is to be generated
   for ($i = 0; $i < $num_of_frames; ++$i) {

      for ($reset_gen = 0; $reset_gen <16;$reset_gen++) {
        $queue_distribution[$reset_gen] = 0;
        $q_dist_fixed[$reset_gen] = 0;
      }
      # The next for-loop cycles through each testcase line of the tx frame
      for (my $j = 0; $j < ($#command + 1); ++$j) {


         # PREAMBLE and SFD
         ###################
         # Call function to generate a preamble field
         $preamble = generate_field($preamble_size, $preamble_size, 5, "byte");


         # NUMBER OF BUFS
         ################
         if ($command[$j] =~ /^\s*number_of_bufs/) {

            $no_of_bufs = get_line_data($command[$j]);

            # If $no_of_bufs contains an "-", then the size is to be a random
            # number within that range
            if ($no_of_bufs =~ /^\s*\w*\d*-/) {
               ($min_no_bufs, $max_no_bufs) = get_range($no_of_bufs);
            }

            else {
               $min_no_bufs = $no_of_bufs;
               $max_no_bufs = $no_of_bufs;
            }

            # determine the number of buffers in each frame
            if ($max_no_bufs ne '' or $min_no_bufs ne '') {
               $no_of_bufs  = int(rand($max_no_bufs - $min_no_bufs + 1) + $min_no_bufs);
            } else {
               $no_of_bufs  = 1;
            }

         }


         elsif ($command[$j] =~ /^\s*auto_gen_int/) {
           $tx_gen_int_in = get_line_data($command[$j]);
         }

         elsif ($command[$j] =~ /^\s*set_used_after_every_buffer/) {
           $set_used = get_line_data($command[$j]);
           if ($set_used =~ /none/) {
             # No used bits - set count to one more than num of frames
             $set_used = $num_of_frames + 1;
           }
           if ($set_used =~ /last/) {
             # Only set used after last frame - can set to 0
             $set_used = 0;
           }
         }

         elsif ($command[$j] =~ /^\s*restart_type/) {
           $restart_type = get_line_data($command[$j]);
         }

         elsif ($command[$j] =~ /^\s*fix_wrap/) {
           $fix_wrap = 1;
           $fix_wrap_val = get_line_data($command[$j]);
           #print "Fixing Wrap to $fix_wrap_val\n";
         }

         # BUFFER_SIZE
         #############
         elsif ($command[$j] =~ /^\s*fix_q2_buffer_size/) {
           $q2_size_fixed = 1;
           $q2_buffer_size = get_line_data($command[$j]);
         }
         elsif ($command[$j] =~ /^\s*fix_q1_buffer_size/) {
           $q1_size_fixed = 1;
           $q1_buffer_size = get_line_data($command[$j]);
         }
         elsif ($command[$j] =~ /^\s*fix_q0_buffer_size/) {
           $q0_size_fixed = 1;
           $q0_buffer_size = get_line_data($command[$j]);
         }
         elsif ($command[$j] =~ /^\s*buffer_size/) {

          if ($queue_has_been_fixed == 0) {
            $queue_to_use = int(rand(100));
            $remaining_bw = 100 - $queue_distribution[0] -
                                  $queue_distribution[1] -
                                  $queue_distribution[2] -
                                  $queue_distribution[3] -
                                  $queue_distribution[4] -
                                  $queue_distribution[5] -
                                  $queue_distribution[6] -
                                  $queue_distribution[7] -
                                  $queue_distribution[8] -
                                  $queue_distribution[9] -
                                  $queue_distribution[10] -
                                  $queue_distribution[11] -
                                  $queue_distribution[12] -
                                  $queue_distribution[13] -
                                  $queue_distribution[14] -
                                  $queue_distribution[15]  ;


            for (my $tmp_queue_num = 0; $tmp_queue_num <$num_dma_queues;$tmp_queue_num++) {
              if ($q_dist_fixed[$tmp_queue_num] == 0) { $queue_distribution[$tmp_queue_num] = $remaining_bw / $num_dma_queues;}
            }
            for (my $tmp_queue_num = 1; $tmp_queue_num <$num_dma_queues;$tmp_queue_num++) {
              $queue_distribution[$tmp_queue_num] = $queue_distribution[$tmp_queue_num] + $queue_distribution[$tmp_queue_num-1];
            }
            if    ($queue_to_use < $queue_distribution[0]) {$queue_to_use = 0;}
            elsif ($queue_to_use < $queue_distribution[1]) {$queue_to_use = 1;}
            elsif ($queue_to_use < $queue_distribution[2]) {$queue_to_use = 2;}
            elsif ($queue_to_use < $queue_distribution[3]) {$queue_to_use = 3;}
            elsif ($queue_to_use < $queue_distribution[4]) {$queue_to_use = 4;}
            elsif ($queue_to_use < $queue_distribution[5]) {$queue_to_use = 5;}
            elsif ($queue_to_use < $queue_distribution[6]) {$queue_to_use = 6;}
            elsif ($queue_to_use < $queue_distribution[7]) {$queue_to_use = 7;}
            elsif ($queue_to_use < $queue_distribution[8]) {$queue_to_use = 8;}
            elsif ($queue_to_use < $queue_distribution[9]) {$queue_to_use = 9;}
            elsif ($queue_to_use < $queue_distribution[10]) {$queue_to_use = 10;}
            elsif ($queue_to_use < $queue_distribution[11]) {$queue_to_use = 11;}
            elsif ($queue_to_use < $queue_distribution[12]) {$queue_to_use = 12;}
            elsif ($queue_to_use < $queue_distribution[13]) {$queue_to_use = 13;}
            elsif ($queue_to_use < $queue_distribution[14]) {$queue_to_use = 14;}
            else  {$queue_to_use = 15;}
          }

          if ($queue_to_use == 0 && $q0_size_fixed == 1) {
            $buffer_size = $q0_buffer_size;
          } elsif ($queue_to_use == 1 && $q1_size_fixed == 1) {
            $buffer_size = $q1_buffer_size;
          } elsif ($queue_to_use == 2 && $q2_size_fixed == 1) {
            $buffer_size = $q2_buffer_size;
          } else {
            $buffer_size = get_line_data($command[$j]);
          }


          #print "Using queue $queue_to_use - length = $buffer_size\n";
          
          # Calculate max allowable lengths ...
          my $tx_sram_size;
          if ($width32)  {$tx_sram_size = (2**$cfg_tx_sram_depth) * 4;}
          if ($width64)  {$tx_sram_size = (2**$cfg_tx_sram_depth) * 8;}
          if (($width128 == 1) || ($cfg_tx_sram_width == 128)) {$tx_sram_size = (2**$cfg_tx_sram_depth) * 16;}  # It will upsize if necessary !
          #print "TX SRAM depth = $cfg_tx_sram_depth\n";
          #print "Configured TX SRAM width = $cfg_tx_sram_width \n";
          #print "Programmed TX SRAM width = 32:$width32 64:$width64 128:$width128 \n";
          #print "Calculated TX SRAM size = $tx_sram_size \n";
          my $tx_sram_size_per_segment = $tx_sram_size / $cfg_num_segments_total;
          #print "Num segments = $cfg_num_segments_total \n";
          #print "TX sram_size_per_segment = $tx_sram_size_per_segment \n";
          my @tx_sram_size_q;
          for my $queue (0 ..  $cfg_num_dma_queues-1) {
            $tx_sram_size_q[$queue] = $tx_sram_size_per_segment * $cfg_tx_num_segments[$queue];
            #print "num segments for Q$queue = $cfg_tx_num_segments[$queue] \n";
            # Use max of full SRAM space minus loads of overhead (24 locns worth) ..
            $tx_max_size_frame[$queue] =  $tx_sram_size_q[$queue] - (($cfg_tx_sram_width/8) * 24)-14; # the eth hdr is added after this calc, so leave enough space for it
            if ($tx_sram_size_q[$queue] <= 180) {
              print "** MAJOR WARNING. TX SRAM SPACE IS TINY FOR QUEUE $queue] AT ONLY $tx_sram_size_q[$queue] bytes. Probably wont work\n";
              $tx_max_size_frame[$queue] =  $tx_sram_size_q[$queue] / 2;
            }
            if ($tx_max_size_frame[$queue] > 16000) {$tx_max_size_frame[$queue] = 16000;} # Limit frame size
          }

          # If $buffer_size contains an "-", then the size is to be a random
          # number within that range
          if ($buffer_size =~ /^\s*(\d+)-([a-zA-Z0-9_]+)/) {
             $min_buffer_size = $1;
             if ($2 ne "take_from_cfg") {
               $max_buffer_size = $2;
             } else {
               $max_buffer_size = $tx_max_size_frame[$queue_to_use] / $no_of_bufs;
               if ($min_buffer_size > $max_buffer_size) {$min_buffer_size = $max_buffer_size;}  # Special case do not exceed the maximum
               if ($max_buffer_size > 16383) {$max_buffer_size = 16383;}  # buffers max at this number
               print "For random TX frame generator, tx_max_size_frame for Q$queue_to_use set to ".$tx_max_size_frame[$queue_to_use].", num bufs = $no_of_bufs\n";
             }
          } else {
            $min_buffer_size = $buffer_size;
            $max_buffer_size = $buffer_size;
          }
          #print "min_buffer_size = $min_buffer_size, max_buffer_size = $max_buffer_size\n";
         }

         # NUM OF DMA QUEUES
         ###################
         elsif ($command[$j] =~ /^\s*set_queue(\d)_distribution/) {
          $q_dist_fixed[$1] = 1;
          $queue_distribution[$1] = get_line_data($command[$j]);
         }
         elsif ($command[$j] =~ /^\s*num_dma_queues/) {
            $num_dma_queues = get_line_data($command[$j]);
            if ($num_dma_queues =~ /^\s*take_from_cfg\s*/) {
              $num_dma_queues = $cfg_num_dma_queues; 
            }
            if (($num_dma_queues > 16)|($num_dma_queues == 0)){ print "\n\nnum_dma_queues must be <=16 and >0\n\n";exit}
         }
         elsif ($command[$j] =~ /^\s*fix_queue_num/) {
            $queue_to_use = int(get_line_data($command[$j]));
            $queue_has_been_fixed = 1;
         }
#         elsif ($command[$j] =~ /^\s*set_used_on_last/) {
#            $set_used_on_last = int(get_line_data($command[$j]));
#         }

         # PCS loopback - automatically loops back data at PCS TBI
         #              - Doesnt create or drive rxd
         #              - Doesnt check txd
         #              - check data for RX DMA = stim data for TX DMA

         ################
         elsif ($command[$j] =~ /^\s*pcs_loopback/) {
            $pcs_loopback = get_line_data($command[$j]);
         }

         # ext loopback - same as pcs_loopback but applies to all modes and does check txd
         elsif ($command[$j] =~ /^\s*ext_loopback/) {
            $ext_loopback = get_line_data($command[$j]);
         }

         elsif ($command[$j] =~ /^\s*no_txd_check/) {
            $tx_data_check = 0;
         }


         # DATA and PAD
         ###############
         elsif ($command[$j] =~ /^\s*data/) {

            # If the previous line was buffer_size, reset $data_field
            if ( $command[$j - 1] =~ /^\s*buffer_size/ ) {
               $data_field = "";
            }

            # Data can be entered on one or more lines.  Collect all the
            # data_field together, before dealing with it.
            $data_field = $data_field.get_line_data($command[$j]);

            # Only process data field if the field size has been received
            if ($max_buffer_size ne '' or $min_buffer_size ne '') {

               #print "\n no_of_bufs = $no_of_bufs, min_buffer_size = $min_buffer_size, max_buffer_size = $max_buffer_size";
               for (my $k = 0; $k < $no_of_bufs; ++$k) {
                 $tx_buffer_sizes[$k] = 0;

                 # If there are no more command lines with data from the data field
                 if ($k == 0 && $data_field =~ /^\s*\w*\d*add_queue_id/) {
                   $data_field = $data_field . (sprintf "%02x", ($queue_to_use));
                   $tx_buffer_sizes[$k] = 1;
                 }
                 if ( !($command[$j + 1] =~ /^\s*data/) ) {

                    # If $data_field contains the word "random", then change its
                    # contents to a random string generated by "generate_field".
                    #printf ("max buffer_size = %s\n", $max_buffer_size);
                    if ($data_field =~ /^\s*\w*\d*random/) {
                       $new_data_field = generate_field($min_buffer_size,
                                                    $max_buffer_size,
                                                    "random",
                                                    "byte");
                       $data_field = $data_field . $new_data_field;
                       #printf ("buf $k, full frm size so far (nibbles) = %s\n", length $data_field);
                    }
                 }
                 $tx_buffer_sizes[$k] = $tx_buffer_sizes[$k] + length($new_data_field)/2;
                 #printf ("buf $k,  = %s\n", $tx_buffer_sizes[$k]);
               }
               # remove the word random from the start of the data field
               $data_field =~ s/^\s*\w*\d*random//;
               # Insert zero padding to make the frame at least 120 nibbles
               $pad = ("0" x (120 - length($data_field)));
################
################              $udp_sport_array[0] = sprintf "%04x", int(rand(2**16));
################              $udp_dport_array[0] = sprintf "%04x", int(rand(2**16));
################      $current_tx_pkt_num++;
################      ($data_field,$tx_type_len_field,$tx_udp_dport,$tx_ipv4_tos,$tx_ipv6_tc,$tx_l3_hdr_index,$tx_l4_hdr_index) = gen_l3l4_frames (
################        1,
################        $data_field,
################        $tx_buffer_sizes[0],
################        $current_tx_pkt_num,
################        $tx_type_len_field,
################
################        1,
################          0,
################          0,
################          # All other IPv4 fields are randomized(if possible)
################
################        0,
################          0,
################          0,
################          0,
################          0,
################          0,
################          # All other IPv6 fields are randomized(if possible)
################
################        1,
################          0,
################          # All other UDP fields are randomized(if possible)
################
################        0,
################          0,
################          # All other TCP fields are randomized(if possible)
################
################        0
################      );
################      $data_field = "112233445566112233445566$tx_type_len_field$data_field";
################    $tx_buffer_sizes[0] = length($data_field)/2;
################    $pad = ("0" x (120 - length($data_field)));
################


            }

            else {
               print "ERROR:  No frame_size received\n";
            }
         }


         # FCS
         ######
         elsif ($command[$j] =~ /^\s*fcs/) {

            $fcs = get_line_data($command[$j]);
            # If $fcs field contains the word "bad", then change its
            # contents to a random string generated by "generate_field".
            if ($fcs =~ /^\s*\w*\d*bad/) {

               $fcs = generate_field($fcs_size, $fcs_size, "random", "nibble");

               $frame =  $preamble
                        .$sfd
                        .$data_field
                        .$pad
                        .$fcs;
            }

            # If a good FCS is wanted, then call a subroutine to calculate it
            # "gen_crc" should be passed the full frame minus the crc.  It will
            # then return the frame, with the FCS field and necessary padding.
            else {
               # Does the MAC or the TB insert the CRC
               if ($fcs =~ /^\s*\w*\d*no/) {
                  # Remove the last 4 bytes from the frame as trans.pl will add
                  # the crc
                  for (my $i = 0; $i < 8; ++$i) {
                     chop($data_field);
                  }
                 ($frame,,) = gen_crc("$preamble"."$sfd"
                                     ."$data_field"."$pad"."gggggggg","0");
                  $fcs_no_append_by_mac = 1;
               } else {
                 ($frame,,) = gen_crc("$preamble"."$sfd"
                                     ."$data_field"."$pad"."gggggggg","0");
               }
            }

           # push the frame generated into @tx_loopbacked_frame
           if ($pcs_loopback == 1 || $ext_loopback == 1) {
             push @tx_loopbacked_frame, $frame;
           }
         }

         elsif ($command[$j] =~ /^\s*num_collisions/) {
            $num_collisions = get_line_data($command[$j]); # This will repeat the frame a random number of times up to the value put in here - pbuf mode only
         }
         elsif ($command[$j] =~ /^\s*too_many_col/) {
            $too_many_col = get_line_data($command[$j]); # This will force the number of retries to be 16 always - forces too many retries all the time
         }


      }
      # printf "\n\npreamble length = %d\n\n", length $preamble;
      # Reverse the order of $frame, by transfering it to $frame_temp.
      my $temp = chop ($frame);
      while ($temp ne ' ' and $temp ne '') {
         $frame_temp = $frame_temp . $temp;
         $temp = chop ($frame);
      }
      if ($num_collisions != 0) {# number between 0 and $do_collisions
        $num_collisions = int(rand($num_collisions));
      }


      if ($pcs_loopback == 0 && $tx_data_check == 1) {
        copy_to_tx_array (  $queue_to_use,
                            $frame_temp,
                            $num_collisions,
                            $too_many_col
                         );
        #print "\nCreating TXD data for frame associated with queue $queue_to_use";
      }
      if ($num_collisions >15) {$too_many_col = 1;}

      $txoddnumbytes = 0;
      if ($i == ($num_of_frames - 1)) {
        $last_frame = 1;
      }
      if ($i == 0 || $set_used == 0){$set_used_cnt = $set_used;}

      tx_dma_activity ( $queue_to_use,
                        $num_dma_queues,
                        $frame_temp,
                        length $preamble,
                        $no_of_bufs,
                        $too_many_col,
                        $set_used_cnt,
                        $last_frame,
                        $restart_type,
                        $fix_wrap,
                        $fix_wrap_val,
                        $fcs_no_append_by_mac
                      );

      if ($set_used_cnt < 2) {$set_used_cnt = $set_used} else {$set_used_cnt = $set_used_cnt-1};
      $frame_temp = "";
      $total_num_tx_frames++;
   }

}


################################################################################
# copy_to_tx_array
#
# - Subroutine to add a frame to the array "eth_txd" in the same format as
#   will be written to the data file "tb_txd.data"
################################################################################
sub copy_to_tx_array {
   my ($queue_to_use,$frame,$col,$tmc) = @_;

   my $nibble2           = "";
   my $nibble1           = "";

   my $temp              = "";
   my $first_byte        = "";

   my $frame_length      = "";
   my $even_frame_length = "";
   my $numcol = 0;
   my $collocn = 0;
   my $collocn_hits_mac = 0;
   my $frmlocn = 0;
   my $retry_bytes = "";
   my $ltemp = "";
   my $i = 0;
   my $j = 0;
   my $reset_i = 0;
   my $index_ref         = "";
   my $index1_ref        = "";
   my $index2_ref        = "";
   my $index3_ref        = "";
   my $index4_ref        = "";
   my $index5_ref        = "";
   my $index6_ref        = "";
   my $index7_ref        = "";
   my $index8_ref        = "";
   my $index9_ref        = "";
   my $index10_ref        = "";
   my $index11_ref        = "";
   my $index12_ref        = "";
   my $index13_ref        = "";
   my $index14_ref        = "";
   my $index15_ref        = "";
   my $drop_pkt = 0;

   $index_ref  = int @eth_txd;
   $index1_ref = int @eth_txd1;
   $index2_ref = int @eth_txd2;
   $index3_ref = int @eth_txd3;
   $index4_ref = int @eth_txd4;
   $index5_ref = int @eth_txd5;
   $index6_ref = int @eth_txd6;
   $index7_ref = int @eth_txd7;
   $index8_ref = int @eth_txd8;
   $index9_ref = int @eth_txd9;
   $index10_ref = int @eth_txd10;
   $index11_ref = int @eth_txd11;
   $index12_ref = int @eth_txd12;
   $index13_ref = int @eth_txd13;
   $index14_ref = int @eth_txd14;
   $index15_ref = int @eth_txd15;

   # txd stuff
   # control triggers
   # 0  end-stop
   # 1  wait for tx_en
   # 4  keep going
   # 5  use testbench to generate CRC
   # 7  force collision - for TXD (even nibble)
   # 8  force collision - for TXD (odd nibble)


   # $even_frame_length will have a different value to (length $frame), if
   # $frame is an odd number of nibbles long.
   $frame_length = length $frame;
   $even_frame_length = int($frame_length / 2) * 2;
   if ($tmc == 1) {$numcol = 16}; # always do too many retries
   $numcol = $col;
   if ($col != 0) {$col = 1;}
    # Note that in gigabit half duplex, we cant inject collisions on frames that might be in if we are bursting - that would cause a late collision

   if ($numcol > 15) { $numcol = 16;$drop_pkt = 1;} # too many retries

   $first_byte = "true";   # Set flag for the first byte of frame data

   for (my $i = 0; $i < ($frame_length / 2); ++$i) {
      if ($reset_i == 1) {$i = 0;$reset_i=0;} #nned to do this to do the restart properly for collisions
      if ($first_byte eq "true") {
         # Place the collision anywhere, other than byte 0 just now- avoid late collisions in gigabit as that is considered a major error.
         if ($numcol != 0) {
           
           $col_locn_nearend    = (int($frame_length / 2) - 12) + int(rand(8));
           $col_locn_nearstart  = (9 + int(rand(8)));
           $col_locn_mid        = int(rand(($frame_length / 2) - 22)) + 9;
           $col_locn_preamble   = int(rand(7)) + 1;
           if ($queue_to_use != 0) {
              $col_locn_sel        = int(rand(3));  # Dont allow collisions in preamble on non Q0. This is a TB issue - it cant tell the difference between preamble across the queues
           } else {
              $col_locn_sel        = int(rand(4));
           }
           if     ($col_locn_sel == 0) {$collocn = $col_locn_nearend;}
           elsif  ($col_locn_sel == 1) {$collocn = $col_locn_nearstart;}
           elsif  ($col_locn_sel == 2) {$collocn = $col_locn_mid;}
           else                        {$collocn = $col_locn_preamble;}
           # avoid late collisions 
           if ($gigabit && $collocn > 512) {
             $collocn = 512;
           }
         }
         # If the first byte is to be padded
         if ($even_frame_length ne $frame_length) {
            $ltemp = "0";  # Pads the 1st byte of preamble
            $nibble1 = chop ($frame);      # The 1st nibble of preamble
            $first_byte = "false";         # Cancel flag
         }
         else {
            $nibble1 = chop ($frame);
            $ltemp = chop ($frame);
         }
         $nibble2 = $ltemp."  // New Frame ($frame_length nibbles)";
         $control = "10000";
         $comment = "  // wait for tx_en";
         $first_byte = "false";
         $frmlocn++;
         if ($numcol != 0) {$nibble2 = $nibble2 . " Doing $numcol collisions, this one on locn $collocn.";}
         $retry_bytes = $ltemp.$nibble1;
      }

      else {
         $comment = "";
         $nibble1 = chop ($frame);
         $ltemp = chop ($frame);
         $nibble2 = $ltemp."  //            Byte $frmlocn";
         if ($numcol != 0) {
           #print "\n Doing $numcol collisions on locn $collocn, $frmlocn";
           $retry_bytes = $ltemp.$nibble1.$retry_bytes;
           if ($collocn == $frmlocn) {
             # If the collision occured in the preamble, then the DUT always finished the preamble before sengin the JAM
             $nibble2 = $nibble2.", Collision here - selected by col_locn_sel $col_locn_sel";
             $control = "70000";
           } else {
             $control = "40000";
           }
           # In RGMII modes, the collision is manufactured by the RGMII wrapper and  takes an extra 2 clocks to hit the RX MAC ..
           $collocn_hits_mac = ($collocn+$cfg_use_rgmii*2);
           if (($collocn_hits_mac == $frmlocn && $collocn_hits_mac >=6) || ($collocn_hits_mac < 6 && $frmlocn == 6)) {
             if ($speed_mode == 2 && $collocn_hits_mac == 5) {$nibble2 = $nibble2."\n40000zz"}; # special case for gigabit collisions when it happens on the 5th byte !
             $nibble2 = $nibble2."\n40000zz \n40000zz \n40000zz \n40000zz \n40000zz";
             if ($speed_mode == 2 && $collocn_hits_mac >=6) {$nibble2 = $nibble2."\n40000zz \n40000zz"}; # special case for gigabit collisions outside of preamble
             $first_byte = "true";
             $frame = $frame . $retry_bytes;
             $retry_bytes = "";
             if (($drop_pkt == 1) && ($numcol == 1))
             {
               for (my $k = 0; $k < (($frame_length / 2) - $frmlocn);$k++) {
                 $ltemp = chop ($frame);
                 $ltemp = chop ($frame);
               }
               $i = ($frame_length / 2);
               $drop_pkt = 0;
             }
             $numcol--;
             $reset_i = 1;
             $frmlocn = 0;
           } else {
             $frmlocn++;
           }
         } else {$control = "40000";$frmlocn++;}
      }

      if    ($queue_to_use == 0) {$eth_txd [$j + $index_ref]  = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 1) {$eth_txd1[$j + $index1_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 2) {$eth_txd2[$j + $index2_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 3) {$eth_txd3[$j + $index3_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 4) {$eth_txd4[$j + $index4_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 5) {$eth_txd5[$j + $index5_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 6) {$eth_txd6[$j + $index6_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 7) {$eth_txd7[$j + $index7_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 8) {$eth_txd8[$j + $index8_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 9) {$eth_txd9[$j + $index9_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 10) {$eth_txd10[$j + $index10_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 11) {$eth_txd11[$j + $index11_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 12) {$eth_txd12[$j + $index12_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 13) {$eth_txd13[$j + $index13_ref] = $control.$nibble1.$nibble2.$comment;}
      elsif ($queue_to_use == 14) {$eth_txd14[$j + $index14_ref] = $control.$nibble1.$nibble2.$comment;}
      else                       {$eth_txd15[$j + $index15_ref] = $control.$nibble1.$nibble2.$comment;}
      $j++;
   }
}



################################################################################
# write_txd_file
#
# - Subroutine to write all the tx frames to the file "tb_txd.data"
################################################################################
sub write_txd_file {
   my $array_size = "";
   $array_size = int (@eth_txd);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE "$eth_txd[$i]\n";
   }
}
sub write_txd1_file {
   my $array_size = "";
   $array_size = int (@eth_txd1);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE1 "$eth_txd1[$i]\n";
   }
}
sub write_txd2_file {
   my $array_size = "";
   $array_size = int (@eth_txd2);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE2 "$eth_txd2[$i]\n";
   }
}
sub write_txd3_file {
   my $array_size = "";
   $array_size = int (@eth_txd3);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE3 "$eth_txd3[$i]\n";
   }
}
sub write_txd4_file {
   my $array_size = "";
   $array_size = int (@eth_txd4);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE4 "$eth_txd4[$i]\n";
   }
}
sub write_txd5_file {
   my $array_size = "";
   $array_size = int (@eth_txd5);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE5 "$eth_txd5[$i]\n";
   }
}
sub write_txd6_file {
   my $array_size = "";
   $array_size = int (@eth_txd6);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE6 "$eth_txd6[$i]\n";
   }
}
sub write_txd7_file {
   my $array_size = "";
   $array_size = int (@eth_txd7);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE7 "$eth_txd7[$i]\n";
   }
}
sub write_txd8_file {
   my $array_size = "";
   $array_size = int (@eth_txd8);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE8 "$eth_txd8[$i]\n";
   }
}
sub write_txd9_file {
   my $array_size = "";
   $array_size = int (@eth_txd9);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE9 "$eth_txd9[$i]\n";
   }
}
sub write_txd10_file {
   my $array_size = "";
   $array_size = int (@eth_txd10);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE10 "$eth_txd10[$i]\n";
   }
}
sub write_txd11_file {
   my $array_size = "";
   $array_size = int (@eth_txd11);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE11 "$eth_txd11[$i]\n";
   }
}
sub write_txd12_file {
   my $array_size = "";
   $array_size = int (@eth_txd12);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE12 "$eth_txd12[$i]\n";
   }
}
sub write_txd13_file {
   my $array_size = "";
   $array_size = int (@eth_txd13);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE13 "$eth_txd13[$i]\n";
   }
}
sub write_txd14_file {
   my $array_size = "";
   $array_size = int (@eth_txd14);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE14 "$eth_txd14[$i]\n";
   }
}
sub write_txd15_file {
   my $array_size = "";
   $array_size = int (@eth_txd15);
   for (my $i = 0; $i < $array_size; ++$i) {
      print TXDFILE15 "$eth_txd15[$i]\n";
   }
}


################################################################################
# tx_dma_activity
#
# - Subroutine to define the expected write activity on the DMA interface
################################################################################
sub tx_dma_activity {
   my ($queue_to_use, $num_dma_queues,$frame, $preamble_size, $no_of_bufs, $too_many_col,$set_used_cnt,$last_frame,$restart_type,$fix_wrap,$fix_wrap_val,$fcs_no_append_by_mac) = @_;

   my $control       = "0"; # Control nibble (default 0, means data is valid)
   my $address       = "";  # Address of the current tx buffer
   my $init_address  = "";  # Initial location pointer to by the dma read
   my $sfd_size      = "2"; # Size of SFD (in nibbles)
   my $tx_buffer_size   = 0;
   my $j = 0;
   my $not_first_buffer = 0;

   # Remove the preamble and SFD from the frame
   for (my $i = 0; $i < $preamble_size + $sfd_size; ++$i) {
      chop $frame;
   }

   # generate dma activity for all the buffers in the frame
   for (my $k = 0; $k < $no_of_bufs; ++$k) {

   $tx_buffer_size = int ($tx_buffer_sizes[$k]);

   my $num_ahb_words_to_read = 0;

   # work out pointer position from $tx_q_pointer from apb write and $tx_q_ptr_index
   if ($num_dma_queues >= 1) {$tx_pointer_q0 = hex ($tx_q_pointer[0])    + $tx_q_ptr_index_q0;}
   if ($num_dma_queues >= 2) {$tx_pointer_q1 = hex ($tx_q_pointer[1]) + $tx_q_ptr_index_q1;}
   if ($num_dma_queues >= 3) {$tx_pointer_q2 = hex ($tx_q_pointer[2]) + $tx_q_ptr_index_q2;}
   if ($num_dma_queues >= 4) {$tx_pointer_q3 = hex ($tx_q_pointer[3]) + $tx_q_ptr_index_q3;}
   if ($num_dma_queues >= 5) {$tx_pointer_q4 = hex ($tx_q_pointer[4]) + $tx_q_ptr_index_q4;}
   if ($num_dma_queues >= 6) {$tx_pointer_q5 = hex ($tx_q_pointer[5]) + $tx_q_ptr_index_q5;}
   if ($num_dma_queues >= 7) {$tx_pointer_q6 = hex ($tx_q_pointer[6]) + $tx_q_ptr_index_q6;}
   if ($num_dma_queues >= 8) {$tx_pointer_q7 = hex ($tx_q_pointer[7]) + $tx_q_ptr_index_q7;}
   if ($num_dma_queues >= 9) {$tx_pointer_q8 = hex ($tx_q_pointer[8]) + $tx_q_ptr_index_q8;}
   if ($num_dma_queues >= 10) {$tx_pointer_q9 = hex ($tx_q_pointer[9]) + $tx_q_ptr_index_q9;}
   if ($num_dma_queues >= 11) {$tx_pointer_q10 = hex ($tx_q_pointer[10]) + $tx_q_ptr_index_q10;}
   if ($num_dma_queues >= 12) {$tx_pointer_q11 = hex ($tx_q_pointer[11]) + $tx_q_ptr_index_q11;}
   if ($num_dma_queues >= 13) {$tx_pointer_q12 = hex ($tx_q_pointer[12]) + $tx_q_ptr_index_q12;}
   if ($num_dma_queues >= 14) {$tx_pointer_q13 = hex ($tx_q_pointer[13]) + $tx_q_ptr_index_q13;}
   if ($num_dma_queues >= 15) {$tx_pointer_q14 = hex ($tx_q_pointer[14]) + $tx_q_ptr_index_q14;}
   if ($num_dma_queues >= 16) {$tx_pointer_q15 = hex ($tx_q_pointer[15]) + $tx_q_ptr_index_q15;}
   if ($queue_to_use == 0)   {$tx_q_ptr_index_q0 = $tx_q_ptr_index_q0 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 1)   {$tx_q_ptr_index_q1 = $tx_q_ptr_index_q1 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 2)   {$tx_q_ptr_index_q2 = $tx_q_ptr_index_q2 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 3)   {$tx_q_ptr_index_q3 = $tx_q_ptr_index_q3 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 4)   {$tx_q_ptr_index_q4 = $tx_q_ptr_index_q4 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 5)   {$tx_q_ptr_index_q5 = $tx_q_ptr_index_q5 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 6)   {$tx_q_ptr_index_q6 = $tx_q_ptr_index_q6 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 7)   {$tx_q_ptr_index_q7 = $tx_q_ptr_index_q7 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 8)   {$tx_q_ptr_index_q8 = $tx_q_ptr_index_q8 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 9)   {$tx_q_ptr_index_q9 = $tx_q_ptr_index_q9 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 10)   {$tx_q_ptr_index_q10 = $tx_q_ptr_index_q10 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 11)   {$tx_q_ptr_index_q11 = $tx_q_ptr_index_q11 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 12)   {$tx_q_ptr_index_q12 = $tx_q_ptr_index_q12 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 13)   {$tx_q_ptr_index_q13 = $tx_q_ptr_index_q13 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 14)   {$tx_q_ptr_index_q14 = $tx_q_ptr_index_q14 + 8 + 8*$addr64+ 8*$ext_bd_tx;}
   if ($queue_to_use == 15)   {$tx_q_ptr_index_q15 = $tx_q_ptr_index_q15 + 8 + 8*$addr64+ 8*$ext_bd_tx;}

   if ($txwrapbit == 1) {
     $txwrapbit = 4;
     if ($queue_to_use == 0)   {$tx_q_ptr_index_q0 = 0;}
     if ($queue_to_use == 1)   {$tx_q_ptr_index_q1 = 0;}
     if ($queue_to_use == 2)   {$tx_q_ptr_index_q2 = 0;}
     if ($queue_to_use == 3)   {$tx_q_ptr_index_q3 = 0;}
     if ($queue_to_use == 4)   {$tx_q_ptr_index_q4 = 0;}
     if ($queue_to_use == 5)   {$tx_q_ptr_index_q5 = 0;}
     if ($queue_to_use == 6)   {$tx_q_ptr_index_q6 = 0;}
     if ($queue_to_use == 7)   {$tx_q_ptr_index_q7 = 0;}
     if ($queue_to_use == 8)   {$tx_q_ptr_index_q8 = 0;}
     if ($queue_to_use == 9)   {$tx_q_ptr_index_q9 = 0;}
     if ($queue_to_use == 10)   {$tx_q_ptr_index_q10 = 0;}
     if ($queue_to_use == 11)   {$tx_q_ptr_index_q11 = 0;}
     if ($queue_to_use == 12)   {$tx_q_ptr_index_q12 = 0;}
     if ($queue_to_use == 13)   {$tx_q_ptr_index_q13 = 0;}
     if ($queue_to_use == 14)   {$tx_q_ptr_index_q14 = 0;}
     if ($queue_to_use == 15)   {$tx_q_ptr_index_q15 = 0;}
   } elsif ($txwrapbit < 3) {$txwrapbit = 0;}

   if ($k == 0) {$txwrapbit1st = $txwrapbit;}

   # Generate tx buffer location
   $init_address = generate_field(4,4,"random","byte");
   $lsb_address = substr($init_address, 7, 1);
   if ($width128 == 1) {
    $lsb_address = hex ($lsb_address) % 16;
    #print "LSB ADDRESS = $lsb_address\n";
   } elsif ($width64 == 1) {
    $lsb_address = hex ($lsb_address) % 8;
   } else {
    $lsb_address = hex ($lsb_address) % 4;
   }
   #print "\n *** init_address $init_address       lsb_address $lsb_address ****\n";

   # This line makes a hexadecimal number into an integer.  Perl assumes the
   # value in brackets to be hexadecimal (which is what we want in this case).
   # $init_address will be held as an integer, making numeric operations easier.
   # The same applies for $tx_pointer.
   $init_address = hex ($init_address);

   # generate buffer address and size for tx dma buffer manager reads
   # Queue 7 ...
   my $next_break = 0;
   my $next_break64 = 0;
#   print "\nCreating DMA data for frame associated with queue $queue_to_use";
   for (my $queue_cnt=($num_dma_queues-1);$queue_cnt>=0;$queue_cnt--) {
     $datafilename = \$DMARD_TXDESCR_FH[0];
     #if (($not_first_buffer == 0 || $axi_test == 1) || ($next_break == 1)) {
     if (($not_first_buffer == 0 ) || ($next_break == 1)) {
       if ($axi_test) {
         $datafilename = \$DMARD_TXDESCR_FH[$queue_cnt];
       } else {
         $datafilename = \$DMARD_TXDESCR_FH[0];
       }
       if    ($queue_cnt == 0)  {$tx_pointer = $tx_pointer_q0;}
       elsif ($queue_cnt == 1)  {$tx_pointer = $tx_pointer_q1;}
       elsif ($queue_cnt == 2)  {$tx_pointer = $tx_pointer_q2;}
       elsif ($queue_cnt == 3)  {$tx_pointer = $tx_pointer_q3;}
       elsif ($queue_cnt == 4)  {$tx_pointer = $tx_pointer_q4;}
       elsif ($queue_cnt == 5)  {$tx_pointer = $tx_pointer_q5;}
       elsif ($queue_cnt == 6)  {$tx_pointer = $tx_pointer_q6;}
       elsif ($queue_cnt == 7)  {$tx_pointer = $tx_pointer_q7;}
       elsif ($queue_cnt == 8)  {$tx_pointer = $tx_pointer_q8;}
       elsif ($queue_cnt == 9)  {$tx_pointer = $tx_pointer_q9;}
       elsif ($queue_cnt == 10) {$tx_pointer = $tx_pointer_q10;}
       elsif ($queue_cnt == 11) {$tx_pointer = $tx_pointer_q11;}
       elsif ($queue_cnt == 12) {$tx_pointer = $tx_pointer_q12;}
       elsif ($queue_cnt == 13) {$tx_pointer = $tx_pointer_q13;}
       elsif ($queue_cnt == 14) {$tx_pointer = $tx_pointer_q14;}
       elsif ($queue_cnt == 15) {$tx_pointer = $tx_pointer_q15;}
     } else {
       if ($axi_test) {
         $datafilename = \$DMARD_TXDESCR_FH[$queue_to_use];
       } else {
         $datafilename = \$DMARD_TXDESCR_FH[0];
       }
       if    ($queue_to_use == 0)  {$tx_pointer = $tx_pointer_q0;}
       elsif ($queue_to_use == 1)  {$tx_pointer = $tx_pointer_q1;}
       elsif ($queue_to_use == 2)  {$tx_pointer = $tx_pointer_q2;}
       elsif ($queue_to_use == 3)  {$tx_pointer = $tx_pointer_q3;}
       elsif ($queue_to_use == 4)  {$tx_pointer = $tx_pointer_q4;}
       elsif ($queue_to_use == 5)  {$tx_pointer = $tx_pointer_q5;}
       elsif ($queue_to_use == 6)  {$tx_pointer = $tx_pointer_q6;}
       elsif ($queue_to_use == 7)  {$tx_pointer = $tx_pointer_q7;}
       elsif ($queue_to_use == 8)  {$tx_pointer = $tx_pointer_q8;}
       elsif ($queue_to_use == 9)  {$tx_pointer = $tx_pointer_q9;}
       elsif ($queue_to_use == 10) {$tx_pointer = $tx_pointer_q10;}
       elsif ($queue_to_use == 11) {$tx_pointer = $tx_pointer_q11;}
       elsif ($queue_to_use == 12) {$tx_pointer = $tx_pointer_q12;}
       elsif ($queue_to_use == 13) {$tx_pointer = $tx_pointer_q13;}
       elsif ($queue_to_use == 14) {$tx_pointer = $tx_pointer_q14;}
       elsif ($queue_to_use == 15) {$tx_pointer = $tx_pointer_q15;}
     }
     # write the real descriptor out for the queue we want to transmit from
     # The DUT in AHB mode will read descriptors for the other queues ..
     # Only need to do this for the first buffer of a frame ..
     # If this is not the first buffer of a frame, then we will only need 1
     # descriptor read (we already know the queue) 
     if (($next_break == 1) || ($next_break64 == 1)) {
       if ($width64) {
         printf $datafilename "8%08x%08x5a5a5a5a // Dummy DATA - this is not used by the DMA\n",$descr_addr_upper_32,$tx_pointer;
         printf $datafilename "0%08x%08x00000000 // Dummy DATA - this is not used by the DMA\n",$descr_addr_upper_32,$tx_pointer+4;
         if (($queue_cnt == 0) || ($addr64 == 1) || ($next_break64 == 1))  {last;}
         $next_break64 = 1;
       } elsif ($width32 && ($addr64 == 0)) {
         printf $datafilename "8%08x%08x5a5a5a5a // Dummy DATA - this is not used in the DMA\n", $descr_addr_upper_32,$tx_pointer+4;
         last;
       }

     } elsif (($queue_to_use == $queue_cnt) || ($not_first_buffer == 1)) {
       $control = 8;
       if ($width32 == 0) {
         printf $datafilename "$control%08x%08x%08x // WORD 0 \n", $descr_addr_upper_32,$tx_pointer, $init_address;
         $control = 0;
       }
       if ($k < $no_of_bufs -1) {
          printf $datafilename "$control%08x%08x%01x00%01x%04x // WORD 1 DESCRIPTOR READ for Queue $queue_to_use, txwrapbit is $txwrapbit \n", $descr_addr_upper_32,$tx_pointer+4,$txwrapbit, $fcs_no_append_by_mac, $tx_buffer_size;
       } else { # set end of frame indication
          $conv_temp = hex(8000) + $tx_buffer_size;
          printf $datafilename "$control%08x%08x%01x00%01x%04x // WORD 1 DESCRIPTOR READ for Queue $queue_to_use txwrapbit is $txwrapbit \n", $descr_addr_upper_32,$tx_pointer+4,$txwrapbit, $fcs_no_append_by_mac, $conv_temp;
       }
       $control = 0;
       if ($width32 == 1) {
          printf $datafilename "0%08x%08x%08x // WORD 0\n", $descr_addr_upper_32,$tx_pointer, $init_address;
       }
       if ($addr64 == 1) {
         $data_addr_upper_32 = int(rand(2**32));
         printf $datafilename "0%08x%08x%08x // WORD 2 Upper 32 bits of 64b address \n", $descr_addr_upper_32,$tx_pointer+8, $data_addr_upper_32;
         if (($width128 == 1) || ($width64 == 1)) {
           printf $datafilename "0%08x%08x%08x // WORD 3 Currently unused -putting in random data\n", $descr_addr_upper_32,$tx_pointer+12,(int(rand(2**32)));
         }
         if ($ext_bd_tx == 1 && $axi_test == 1) {
            printf $datafilename "0%08x%08x00000000 // WORD 4 Launch Time \n", $descr_addr_upper_32,$tx_pointer+16;
            printf $datafilename "0%08x%08x00000000 // WORD 5 Launch Time enable (bit 31)\n", $descr_addr_upper_32,$tx_pointer+20;
         }
       } elsif ($ext_bd_tx == 1 && $axi_test == 1) {
         printf $datafilename "0%08x%08x00000000 // WORD 2 Launch Time \n", $descr_addr_upper_32,$tx_pointer+8;
         printf $datafilename "0%08x%08x00000000 // WORD 3 Launch Time enable (bit 31)\n", $descr_addr_upper_32,$tx_pointer+12;
       }

       if ($not_first_buffer == 0) {# First Buffer of frame
         $next_break = $axi_test == 0;
       }
     }

     # Just set used bit of other queues
     elsif (($width32 == 0) & ($axi_test == 0)) {
       printf $datafilename "8%08x%08x5a5a5a5a // Packet is generated for queue $queue_to_use, this is the \n", $descr_addr_upper_32,$tx_pointer;
       printf $datafilename "0%08x%08x80000000 // descr rd for queue $queue_cnt - setting used bit\n", $descr_addr_upper_32, $tx_pointer+4;
       if ($addr64 == 1) {
          printf $datafilename "0%08x%08x%08x\n", $descr_addr_upper_32, $tx_pointer+8,(int(rand(2**32)));
          printf $datafilename "0%08x%08x%08x\n", $descr_addr_upper_32, $tx_pointer+12,(int(rand(2**32)));
       }
     } elsif ($axi_test == 0)  {
       printf $datafilename "8%08x%08x80000000 // Packet is generated for queue $queue_to_use, this is the \n",$descr_addr_upper_32,  $tx_pointer+4;
       printf $datafilename "0%08x%08x5a5a5a5a // descr rd for queue $queue_cnt - setting used bit\n",$descr_addr_upper_32,  $tx_pointer;
       if ($addr64 == 1) {
          printf $datafilename "0%08x%08x%08x\n",$descr_addr_upper_32, $tx_pointer+8,(int(rand(2**32)));
       }
     }

     if ($not_first_buffer == 0&& $next_break64 == 0) {# First Buffer of frame
       if ((($axi_test == 1) && ($queue_cnt == 0)) || (($axi_test == 0) && ($queue_cnt == $queue_to_use))) {
        if ($k < $no_of_bufs -1) { # More than 1 buffer in packet, and this is not the last
          $not_first_buffer = 1;
          } else {                   # Only 1 buffer in frame
           $not_first_buffer = 0;
         }
       }
     } elsif ($next_break64 == 0) {                     # Not the first buffer of frame
#       if ($axi_test == 0) {last;}                      # Break out of FOR loop NOW
        last;
        if ((($axi_test == 1) && ($queue_cnt == 0)) || (($axi_test == 0) && ($queue_cnt == $queue_to_use))) {
         if ($k < $no_of_bufs -1) { # More than 1 buffer in packet, and this is not the last
           $not_first_buffer = 1;
         } else {                   # More than 1 buffer in packet, and this is the last
           $not_first_buffer = 0;
         }
       }
     }


   }

   # reset tx_pointer back to the correct descriptor address associated with the queue we are using
   if ($axi_test) {
      $datafilename = \$DMARD_TXDATA_FH[$queue_to_use];
   } else {
      $datafilename = \$DMARD_TXDATA_FH[0];
   };
   
   if    ($queue_to_use == 0)  {$tx_pointer = $tx_pointer_q0; }
   elsif ($queue_to_use == 1)  {$tx_pointer = $tx_pointer_q1; }
   elsif ($queue_to_use == 2)  {$tx_pointer = $tx_pointer_q2; }
   elsif ($queue_to_use == 3)  {$tx_pointer = $tx_pointer_q3; }
   elsif ($queue_to_use == 4)  {$tx_pointer = $tx_pointer_q4; }
   elsif ($queue_to_use == 5)  {$tx_pointer = $tx_pointer_q5; }
   elsif ($queue_to_use == 6)  {$tx_pointer = $tx_pointer_q6; }
   elsif ($queue_to_use == 7)  {$tx_pointer = $tx_pointer_q7; }
   elsif ($queue_to_use == 8)  {$tx_pointer = $tx_pointer_q8; }
   elsif ($queue_to_use == 9)  {$tx_pointer = $tx_pointer_q9; }
   elsif ($queue_to_use == 10) {$tx_pointer = $tx_pointer_q10;}
   elsif ($queue_to_use == 11) {$tx_pointer = $tx_pointer_q11;}
   elsif ($queue_to_use == 12) {$tx_pointer = $tx_pointer_q12;}
   elsif ($queue_to_use == 13) {$tx_pointer = $tx_pointer_q13;}
   elsif ($queue_to_use == 14) {$tx_pointer = $tx_pointer_q14;}
   elsif ($queue_to_use == 15) {$tx_pointer = $tx_pointer_q15;}

   # store location and status of first frame descriptor so the used bit may
   # be set at the end of the frame
   if ($k == 0) {
      $first_buffer_pointer_address = $tx_pointer+4;
      $first_buffer_size = $tx_buffer_size;
   }

   $num_ahb_words_to_read = 0;

   # If the datapath is 64 bit, then it is possible the data will start in
   # the upper 32 bits of the 64 bit word. In this case, we need dummy data to insert
   # in the lower half ...
   # similar story for 128bit
   $address = $init_address - $lsb_address;
   if ($lsb_address > 3 && $width32 == 0) {
        printf $datafilename "$control%08x%08x00000000 // Dummy bytes - 64 or 128bit access sent, but bottom 4 bytes are not part of payload - lsb_address was %0d\n", $data_addr_upper_32,$address,$lsb_address;
        $txoddnumbytes = 1;
        $lsb_address = $lsb_address - 4;
        $address = $address + 4;
        $num_ahb_words_to_read = $num_ahb_words_to_read +1;
        if ($lsb_address > 3 && $width128 == 1) {
          printf $datafilename "$control%08x%08x00000000 // Dummy bytes - next 4 bytes are also not part of payload\n", $data_addr_upper_32,$address;
          $txoddnumbytes = 2;
          $lsb_address = $lsb_address - 4;
          $address = $address + 4;
          $num_ahb_words_to_read = $num_ahb_words_to_read +1;
        }
        if ($lsb_address > 3 && $width128 == 1) {
          printf $datafilename "$control%08x%08x00000000 // Dummy bytes - next 4 bytes are also not part of payload\n", $data_addr_upper_32,$address;
          $txoddnumbytes = 3;
          $lsb_address = $lsb_address - 4;
          $address = $address + 4;
          $num_ahb_words_to_read = $num_ahb_words_to_read +1;
        }
   } else {$txoddnumbytes = 0;}

   # extract each byte in the buffer from the frame and write to dma read data file
   $j = 0;
   while ($j < $tx_buffer_size) {
      my $temp1 = "";
      my $temp2 = "";
      my $data  = "";

      for (my $i = 0; $i < 4; ++$i) {
         if ($lsb_address != 0) {
            $temp1 = "0";
            $temp2 = "0";
            $lsb_address = $lsb_address -1;
         }
         elsif ($j < $tx_buffer_size) {
            $temp1 = chop $frame;
            $temp2 = chop $frame;
            ++$j;
         }
         else {
            $temp1 = "0";
            $temp2 = "0";
         }
         $data = $temp1.$temp2.$data;
      }

      # write tx dma read data to file
      printf $datafilename "$control%08x%08x$data // PKT data (init add was was %08x), EVEN = $txoddnumbytes, word count = $num_ahb_words_to_read\n", $data_addr_upper_32,$address,$init_address;
      $num_ahb_words_to_read = int ($num_ahb_words_to_read) + 1;

      # increment address after writing dma read data
      $address = $address + 4;
      if ($txoddnumbytes == 3) {$txoddnumbytes = 0;} else {$txoddnumbytes++;}

      # Pad DMARD_TX_DATA_Q0_FILE at end of buffer since there must be a multiple of 2 commands when in 64 bit mode
      if ($j == $tx_buffer_size && ($txoddnumbytes == 1 || $txoddnumbytes == 3) && $width64 == 1) {
        printf $datafilename "$control%08x%08x00000000 // Adding 32'd0 to maintain 64bit alignment, word count = $num_ahb_words_to_read\n", $data_addr_upper_32,$address;
        $num_ahb_words_to_read = $num_ahb_words_to_read+1;
        $address = $address + 4;
      }
      # Pad DMARD_TX_DATA_Q0_FILE at end of buffer since there must be a multiple of 4 commands when in 128 bit mode
      if ($j == $tx_buffer_size && $width128 == 1) {
        while ($txoddnumbytes != 0) {
          printf $datafilename "$control%08x%08x00000000 // Adding 32'd0 to maintain 64bit alignment, word count = $num_ahb_words_to_read\n", $data_addr_upper_32,$address;
          $num_ahb_words_to_read = $num_ahb_words_to_read+1;
          $address = $address + 4;
          if ($txoddnumbytes == 3) {$txoddnumbytes = 0;} else {$txoddnumbytes++;}
        }
      }

      # Pad AHB accesses to burst boundary if force_max_burst_tx is set ...
      # If the address gets to a 1K boundary, then reset the num_ahb_words_to_read
      if ((((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('400')) && $axi_test == 0) ||
           ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('800')) && $axi_test == 0) ||
           ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('c00')) && $axi_test == 0) ||
            (hex(substr((sprintf "%08x", ($address)),5,3)) == hex('000'))) & ($j != $tx_buffer_size)) {$num_ahb_words_to_read = 0};

      if ($j == $tx_buffer_size) {
         if ($width64 == 1) {
            $burst_length = $ahb_burst_size * 2; # double up for 64bit
         } elsif ($width128 == 1) {
            $burst_length = $ahb_burst_size * 4;
         } else {
            $burst_length = $ahb_burst_size;
         }
         if (($force_max_burst_tx == 1) && ($ahb_burst_size != 1)) {
           if  (((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('400')) && $axi_test == 0) ||
                ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('800')) && $axi_test == 0) ||
                ((hex(substr((sprintf "%08x", ($address)),5,3)) == hex('c00')) && $axi_test == 0) ||
                 (hex(substr((sprintf "%08x", ($address)),5,3)) == hex('000'))) {
             # If the next address is on a 1k boundary, then definately dont do any pad!
             $num_forced_pad_tx = 0;
             print "not forcing due to 1k boundary\n";
           } else {

             $num_forced_pad_tx = int(($burst_length - int ($num_ahb_words_to_read % $burst_length)) % $burst_length) ;
             #print "num_forced_pad_tx = $num_forced_pad_tx, progammed burst len = $ahb_burst_size, burst_length(32-bit words) = $burst_length, add = ".(sprintf "%08x", ($address))."\n";
             # in AXI mode, the TX will just do single beat bursts if a max burst will break the 4k boundary rule.
             # This means there wont actually be any pad at all in those cases.
             if ($axi_test == 1) {
               if (((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('fff')) + (4*$num_forced_pad_tx)) > 4096) {
                 $num_forced_pad_tx = 0;
                 # Uncomment the following if the DUT changes and pads to the 4K boundary
                 #printf $datafilename "// num forced pad(first) = 0x$num_forced_pad_tx\n";
                 #$lower_12_bits_addr = (hex(substr((sprintf "%08x", ($address)),5,3)) & hex('fff'));
                 #printf $datafilename "// addr(lower 12 bits) = 0x%03x\n",$lower_12_bits_addr;
                 #$addr_after_padding = ((hex(substr((sprintf "%08x", ($address)),5,3)) & hex('fff')) + (4*$num_forced_pad_tx));
                 #printf $datafilename "// addr after padding would have been 0x%04x\n",$addr_after_padding;
                 #$num_forced_pad_tx = (4096 - $lower_12_bits_addr) / 4;
                 #printf $datafilename "// num forced pad (final) to take it up to 4K boundary= $num_forced_pad_tx\n";
               }
             } else {

               # check if after padding, the increased accesses will cause the 1k boundary to be broken ...
               #print "\n Padding frame by $num_forced_pad_tx due to config bit to force max burst length ($num_ahb_words_to_read words)";
               #printf "\naddress = %08x", $address;
               #printf "\n Bottom 10 bits of address = %03x", (hex(substr((sprintf "%08x", ($address)),5,3)) & hex ('3ff'));
               # If the pad will cause the burst to break the 1k boundary (or 4k for AXI) ...
               if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex ('3ff')) + (4*$num_forced_pad_tx)) <= 1024))
               {
                 # the previous burst would have broken the 1k boundary, in this case, the RTL will try to burst to ($ahb_burst_size >> 1)
                 #printf "\n Cannot send a full burst as it will break 1K boundary.  Try reducing to ($ahb_burst_size /2)\n" ;
                 if ($ahb_burst_size == 16) {
                  # Try a burst of 8 ...
                   $num_forced_pad_tx = int((($burst_length/2) - int ($num_ahb_words_to_read % ($burst_length/2))) % ($burst_length/2)) ;
                   if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex ('3ff')) + (4*$num_forced_pad_tx)) <= 1024)) {
                   # No ? then try 4
                    #printf "\n Nope. cant do 8.  Try reducing to 4\n" ;
                     $num_forced_pad_tx = int((($burst_length/4) - int ($num_ahb_words_to_read % ($burst_length/4))) % ($burst_length/4)) ;
                     if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex ('3ff')) + (4*$num_forced_pad_tx)) <= 1024)) {
                     # No ? then clear num_forced_pad_tx completely
                       $num_forced_pad_tx = 0;
                       #printf "\n Nope. cant do 4.  Not doing any!\n" ;
                     }
                   }
                 } elsif ($ahb_burst_size == 8) {
                   # Try a burst of 4 ...
                   $num_forced_pad_tx = int((($burst_length/2) - int ($num_ahb_words_to_read % ($burst_length/2))) % ($burst_length/2)) ;
                   if (!(((hex(substr((sprintf "%08x", ($address)),5,3)) & hex ('3ff')) + (4*$num_forced_pad_tx)) <= 1024)) {
                     # No ? then clear num_forced_pad_tx completely
                     $num_forced_pad_tx = 0;
                   }
                 } else {
                  # No ? then clear num_forced_pad_tx completely
                  $num_forced_pad_tx = 0;
                 }
               }
             }
           }
         }

         if ($num_forced_pad_tx != 0) {
          for (my $a1 = 0;$a1<$num_forced_pad_tx;$a1=$a1+1){
           printf $datafilename "$control%08x%08x00000000  // Padding to AHB burst boundary\n", $data_addr_upper_32,$address;
           $address = $address + 4;
          }
         }

       # There is a spcial mode that will cause the used bit to be read after a number of good frames have been read.
       # this is defined by the set_used_after_every_buffer argument to the test. After a used bit has been set, the GEM
       # will read it, and will generate a used bit read interrupt.  We need to wait for that interrupt, then restart
       # transmission by setting the start bit.
        if ($k == $no_of_bufs -1) { # last buffer of frame
          if ($tx_gen_int_in == 1 && $last_frame == 1) {
            if ($queue_to_use == 0) {
              print APBFILE "00000000a002400000088   // Packet transmitted & Used Interrupt (Q0)\n";
              print APBFILE "000000004002400000088   // Write to clear\n";
            } else {
              print APBFILE "000000".(sprintf "%1x",$queue_to_use)."0a".(sprintf "%04x",(hex("3fc")+4*$queue_to_use))."00000080   // Packet transmitted Interrupt (Q$queue_to_use)\n";
              print APBFILE "000000".(sprintf "%1x",$queue_to_use)."04".(sprintf "%04x",(hex("3fc")+4*$queue_to_use))."00000080   // Write to clear\n";
              print APBFILE "00000000a002400000008   // Used bit read Interrupt, last_frame = $last_frame\n";
              print APBFILE "000000004002400000008   // Write to clear\n";
            }
          } elsif ($tx_gen_int_in == 1) {
            if ($queue_to_use == 0) {
              print APBFILE "00000000a002400000080   // Packet transmitted Interrupt (Q0)\n";
              print APBFILE "000000004002400000080   // Write to clear\n";
            } else {
              print APBFILE "000000".(sprintf "%1x",$queue_to_use)."0a".(sprintf "%04x",(hex("3fc")+4*$queue_to_use))."00000080   // Packet transmitted Interrupt (Q$queue_to_use)\n";
              print APBFILE "000000".(sprintf "%1x",$queue_to_use)."04".(sprintf "%04x",(hex("3fc")+4*$queue_to_use))."00000080   // Write to clear\n";
            }
          }
          if ($set_used_cnt == 1 ) {
            my $tmp_q0 = $tx_pointer_q0;
            my $tmp_q1 = $tx_pointer_q1;
            my $tmp_q2 = $tx_pointer_q2;
            my $tmp_q3 = $tx_pointer_q3;
            my $tmp_q4 = $tx_pointer_q4;
            my $tmp_q5 = $tx_pointer_q5;
            my $tmp_q6 = $tx_pointer_q6;
            my $tmp_q7 = $tx_pointer_q7;
            my $tmp_q8 = $tx_pointer_q8;
            my $tmp_q9 = $tx_pointer_q9;
            my $tmp_q10 = $tx_pointer_q10;
            my $tmp_q11 = $tx_pointer_q11;
            my $tmp_q12 = $tx_pointer_q12;
            my $tmp_q13 = $tx_pointer_q13;
            my $tmp_q14 = $tx_pointer_q14;
            my $tmp_q15 = $tx_pointer_q15;
            if ($queue_to_use == 0)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[0]);} else {$tmp = $tx_pointer_q0 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 1)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[1]);} else {$tmp = $tx_pointer_q1 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 2)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[2]);} else {$tmp = $tx_pointer_q2 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 3)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[3]);} else {$tmp = $tx_pointer_q3 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 4)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[4]);} else {$tmp = $tx_pointer_q4 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 5)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[5]);} else {$tmp = $tx_pointer_q5 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 6)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[6]);} else {$tmp = $tx_pointer_q6 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 7)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[7]);} else {$tmp = $tx_pointer_q7 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 8)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[8]);} else {$tmp = $tx_pointer_q8 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 9)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[9]);} else {$tmp = $tx_pointer_q9 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 10)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[10]);} else {$tmp = $tx_pointer_q10 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 11)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[11]);} else {$tmp = $tx_pointer_q11 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 12)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[12]);} else {$tmp = $tx_pointer_q12 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 13)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[13]);} else {$tmp = $tx_pointer_q13 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 14)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[14]);} else {$tmp = $tx_pointer_q14 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}
            if ($queue_to_use == 15)   {if ($txwrapbit == 4) {$tmp = hex ($tx_q_pointer[15]);} else {$tmp = $tx_pointer_q15 + 8 + 8*$addr64 + 8*$ext_bd_tx;}}

            if ($axi_test){$datafilename = \$DMARD_TXDESCR_FH[$queue_to_use];}else{$datafilename = \$DMARD_TXDESCR_FH[0];}
            if ($width32) {
              printf $datafilename "0%08x%08x80000000 // Word 1 Auto setting used bit after frame as per testcase\n",$descr_addr_upper_32,$tmp+4;
              printf $datafilename "8%08x%08x00000000 // Word 0 - ignored by design\n",$descr_addr_upper_32,$tmp;
              if ($addr64) {
                printf $datafilename "8%08x%08x00000000 //Word 2 - ignored by design, extra word for 64 bit addressing\n",$descr_addr_upper_32,$tmp+8;
                if ($ext_bd_tx == 1 && $axi_test == 1) {
                   printf $datafilename "0%08x%08x00000000 // WORD 4 Launch Time \n", $descr_addr_upper_32,$tmp+16;
                   printf $datafilename "0%08x%08x00000000 // WORD 5 Launch Time enable (bit 31)\n", $descr_addr_upper_32,$tmp+20;
                }
              } elsif ($ext_bd_tx == 1 && $axi_test == 1) {
                printf $datafilename "0%08x%08x00000000 // WORD 2 Launch Time \n", $descr_addr_upper_32,$tmp+8;
                printf $datafilename "0%08x%08x00000000 // WORD 3 Launch Time enable (bit 31)\n", $descr_addr_upper_32,$tmp+12;
              }
            } else {
              printf $datafilename "8%08x%08x00000000 // Word 0 - ignored by design\n",$descr_addr_upper_32,$tmp;
              printf $datafilename "0%08x%08x80000000 // Word 1 Auto setting used bit after frame as per testcase\n",$descr_addr_upper_32,$tmp+4;
              if ($addr64) {
                printf $datafilename "8%08x%08x00000000 //Word 2 - ignored by design, extra word for 64 bit addressing\n",$descr_addr_upper_32,$tmp+8;
                printf $datafilename "8%08x%08x00000000 //Word 3 - ignored by design \n",$descr_addr_upper_32,$tmp+12;
                if ($ext_bd_tx == 1 && $axi_test == 1) {
                   printf $datafilename "0%08x%08x00000000 // WORD 4 Launch Time \n", $descr_addr_upper_32,$tmp+16;
                   printf $datafilename "0%08x%08x00000000 // WORD 5 Launch Time enable (bit 31)\n", $descr_addr_upper_32,$tmp+20;
                }
              } elsif ($ext_bd_tx == 1 && $axi_test == 1) {
                printf $datafilename "0%08x%08x00000000 // WORD 2 Launch Time \n", $descr_addr_upper_32,$tmp+8;
                printf $datafilename "0%08x%08x00000000 // WORD 3 Launch Time enable (bit 31)\n", $descr_addr_upper_32,$tmp+12;
              }
            }
            
            if ($restart_type == 0 && $last_frame == 0) {
              print APBFILE "00000000a002400000008   // Poll for used bit read Interrupt\n";
              print APBFILE "000000004002400000008   // Write to clear\n";
              print APBFILE "000000004000000000208   // Restart Transmission\n";
            } elsif ($last_frame == 0) {
            # Instead of polling, lets wait for a random delay before restarting ...
              $rand_wait_delay = int(rand(100))+100;
              for ($gf =0;$gf<$rand_wait_delay;$gf=$gf+1) {print APBFILE "000000000c00800000006   // Simple delay\n";}
              print APBFILE "000000004000000000208   // Restart Transmission\n";
            }
          }
        }

      }
      ###################################################
      # Status at end of frame

      if ($ts_mode_tx == 3) {$tx_ext_bd_written = 1;}

      if (($j == $tx_buffer_size) and ($no_of_bufs == $k + 1))
      {
         # Write EOP and Length bits
         if ($no_of_bufs == 1) {$conv_temp = hex(8000) + $first_buffer_size;} else {$conv_temp = $first_buffer_size;}

         my $tx_descr_wb_word0 = sprintf "0%08x%08x${dont_care}ff // Should be MASKED\n", $descr_addr_upper_32,$first_buffer_pointer_address-4;
         my $tx_descr_wb_word1 = sprintf "0%08x%08x%01x0%01x%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$tx_ext_bd_written*8,$fcs_no_append_by_mac,$conv_temp;
         my $tx_descr_wb_word2 = sprintf "0%08x%08x${dont_care}ff // Writeback TS for ext bd\n", $descr_addr_upper_32,$first_buffer_pointer_address +8*$addr64 + 4;
         my $tx_descr_wb_word3 = sprintf "0%08x%08x${dont_care}ff // Writeback TS for ext bd\n", $descr_addr_upper_32,$first_buffer_pointer_address +8*$addr64 + 8;

         if    ($queue_to_use == 0) {
                                     if ($ext_bd_tx == 1) {
                                        if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[0]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[0]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[0]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[0]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 1) {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[1]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[1]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[1]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[1]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 2) {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[2]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[2]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[2]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[2]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 3) {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[3]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[3]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[3]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[3]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 4) {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[4]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[4]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[4]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[4]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 5) {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[5]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[5]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[5]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[5]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 6) {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[6]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[6]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[6]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                      }
                                      else {printf {$DMAWR_TXDESCR_FH[6]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 7)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[7]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[7]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[7]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[7]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 8)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[8]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[8]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[8]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[8]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 9)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[9]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[9]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[9]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[9]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 10)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[10]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[10]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[10]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[10]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 11)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[11]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[11]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[11]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[11]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 12)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[12]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[12]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[12]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[12]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 13)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[13]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[13]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[13]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[13]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 14)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[14]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[14]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[14]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[14]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }
         elsif ($queue_to_use == 15)  {
                                     if ($ext_bd_tx == 1) {
                                       if ($addr64 == 0 && $width128 == 1 && $axi_test == 1) {
                                          printf {$DMAWR_TXDESCR_FH[15]} $tx_descr_wb_word0.$tx_descr_wb_word1.$tx_descr_wb_word2.$tx_descr_wb_word3;
                                        } elsif (($width64 == 1 && $axi_test == 1) || ($addr64 == 1 && $width128 == 1 && $axi_test == 1)) {
                                          printf {$DMAWR_TXDESCR_FH[15]} $tx_descr_wb_word2.$tx_descr_wb_word3.$tx_descr_wb_word1;
                                        } else {
                                          printf {$DMAWR_TXDESCR_FH[15]} $tx_descr_wb_word3.$tx_descr_wb_word2.$tx_descr_wb_word1;
                                        }
                                     }
                                      else {printf {$DMAWR_TXDESCR_FH[15]} "0%08x%08x%01x00%01x%04xff\n", $descr_addr_upper_32,$first_buffer_pointer_address,(hex($txwrapbit1st) + 8 + $too_many_col + $too_many_col),$fcs_no_append_by_mac,$conv_temp;
                                      }
                                    }

      }
      if ($j == $tx_buffer_size) {

        if ($fix_wrap == 1) {$txwrapbit = $fix_wrap_val;} else {$txwrapbit = int(rand(3));}
      }
    }
  }
}


#############################################################


sub gen_l3l4_frames
{
  my (
              $debug_print_frame,
              $data_field,
              $data_size,
              $current_packet_num,
              $type_len_field,

              $ipv4_frame,
                $num_ipv4_options,
                $bad_ip_csum,
                # All other IPv4 fields are randomized(if possible)

              $ipv6_frame,
                $num_ipv6_hdrs,
                $use_dest_hdrs,
                $use_hop_hdrs,
                $use_route_hdrs,
                $use_frag_hdrs,
                # All other IPv6 fields are randomized(if possible)

              $udp_frame,
                $bad_udp_csum,
                # All other UDP fields are randomized(if possible)

              $tcp_frame,
                $bad_tcp_csum,
                # All other TCP fields are randomized(if possible)

              $icmp_frame
    ) = @_;


  my $opts = "";
  $l3_hdr_index = 0;
  $l4_hdr_index = 0;
#  print "The data field is $data_field\n";


  # IPv4 Header Field
  ################
  if ($ipv4_frame == 1) {
    # Overwrite ethernet type field with IPv4 specific
    $type_len_field = "0800";
    $ipv4_ver  = 4;
    $ipv4_ihl  =  sprintf "%01x", (5 + $num_ipv4_options);

    # TOS can be defined directly, if wanted
    if (!defined($ipv4_tos_array[0])) {$ipv4_tos = sprintf "%02x", int(rand(2**8));}
    else {$ipv4_tos = $ipv4_tos_array[int(rand($#ipv4_tos_array+1))];}

    $ipv4_len  =  sprintf "%04x",($data_size + 20 + (4*$num_ipv4_options));   # Total Length = data size + 20bytes for Ipv4 base header, + 4x number of options
    $ipv4_id   =  sprintf "%04x", int(rand(2**16));
    $ipv4_frg  =  int(rand(2));   # Flags and Fragment Offset
    if ($ipv4_frg == 0) {$ipv4_frg = "4000"} else {$ipv4_frg = "0000"};   # Flags and Fragment Offset  (we dont support fragmentation, so has to be 00 or 40
    $ipv4_ttl  =  sprintf "%02x", int(rand(2**8));    # Time to live
    if    ($udp_frame == 1) {$ipv4_prt  = "11";}
    elsif ($tcp_frame == 1) {$ipv4_prt  = "06";}
    elsif ($icmp_frame == 1) {$ipv4_prt  = "01";}
    else  {
      $ipv4_prt  =  sprintf "%02x", int(rand(2**8));
      while (($ipv4_prt eq "11") || ($ipv4_prt eq "06") || ($ipv4_prt eq "01")) {
        $ipv4_prt  =  sprintf "%02x", int(rand(2**8));
      }    # Protocol
    }
    $ipv4_sadd =  sprintf "%04x", int(rand(2**16));
    $ipv4_sadd =  $ipv4_sadd . (sprintf "%04x", int(rand(2**16)));
    $ipv4_dadd =  sprintf "%04x", int(rand(2**16));
    $ipv4_dadd =  $ipv4_dadd . (sprintf "%04x", int(rand(2**16)));
    for ($ipv4_opt_cnt = 1; $ipv4_opt_cnt <= $num_ipv4_options; $ipv4_opt_cnt++) {
      $ipv4_opt[$ipv4_opt_cnt] =  sprintf "%08x", int(rand(2**32));
    }

    if ($num_ipv4_options > 0) {
      for ($ipv4_opt_cnt = 1; $ipv4_opt_cnt <= $num_ipv4_options; $ipv4_opt_cnt++) {
        $opts = $opts.$ipv4_opt[$ipv4_opt_cnt];
      }
    }
  }



  # IPv6 Header Field
  ################
  if ($ipv6_frame == 1) {
    # Overwrite type field with IPv6 specific
    $type_len_field = "86dd";
    $ipv6_ver   = 6;

    # Traffic class can be defined directly, if wanted
    if (!defined($ipv6_tc_array[0])) {$ipv6_tc = sprintf "%02x", int(rand(2**8));}
    else {$ipv6_tc = $ipv6_tc_array[int(rand($#ipv6_tc_array+1))];}

    $ipv6_flow  = sprintf "%05x", int(rand(2**20));
    $ipv6_len  = sprintf "%04x", $data_size;
    $ipv6_nxthdr_base = "3b";
    if ($num_ipv6_hdrs == 0) {
      if    ($udp_frame == 1)  {$ipv6_nxthdr_base  = "11";}
      elsif ($tcp_frame == 1)  {$ipv6_nxthdr_base  = "06";}
      elsif ($icmp_frame == 1) {$ipv6_nxthdr_base  = "01";}
      else  {
        $ipv6_nxthdr_base  =  sprintf "%02x", int(rand(2**8));
        while (($ipv6_nxthdr_base eq "2c") || ($ipv6_nxthdr_base eq "11") || ($ipv6_nxthdr_base eq "06") || ($ipv6_nxthdr_base eq "01") || ($ipv6_nxthdr_base eq "2b") || ($ipv6_nxthdr_base eq "00") || ($ipv6_nxthdr_base eq "3c") || ($ipv6_nxthdr_base eq "3b") ) {
          $ipv6_nxthdr_base  =  sprintf "%02x", int(rand(2**8));
        }    # Protocol
      }

    } else {
      # Choose at random the type of IPv6 HDRs
      $ipv6_nxthdr_base = int(rand(4));
      if    (($ipv6_nxthdr_base  == 0) && ($use_route_hdrs == 1)) {$ipv6_nxthdr_base  = "2b";} # Routing HDR
      elsif (($ipv6_nxthdr_base  == 1) && ($use_hop_hdrs == 1))   {$ipv6_nxthdr_base  = "00";} # Hop by Hop HDR
      elsif (($ipv6_nxthdr_base  == 2) && ($use_dest_hdrs == 1))  {$ipv6_nxthdr_base  = "3c";} # Destination HDR
      else                                                        {$ipv6_nxthdr_base  = "3b";} # No next header
#       if (($ipv6_nxthdr_base  == 4) && ($use_frag_hdrs == 1)) {$ipv6_nxthdr_base  = "2c";} # Fragment HDR
    }

    $ipv6_ttl  = sprintf "%02x", int(rand(2**8));
    $ipv6_sadd = sprintf "%08x", (int(rand(2**32)));
    $ipv6_sadd = $ipv6_sadd.sprintf "%08x", (int(rand(2**32)));
    $ipv6_sadd = $ipv6_sadd.sprintf "%08x", (int(rand(2**32)));
    $ipv6_sadd = $ipv6_sadd.sprintf "%08x", (int(rand(2**32)));
    $ipv6_dadd = sprintf "%08x", (int(rand(2**32)));
    $ipv6_dadd = $ipv6_dadd.sprintf "%08x", (int(rand(2**32)));
    $ipv6_dadd = $ipv6_dadd.sprintf "%08x", (int(rand(2**32)));
    $ipv6_dadd = $ipv6_dadd.sprintf "%08x", (int(rand(2**32)));
  }


  # UDP Header Field
  ################
  if ($udp_frame == 1) {
    $udp_len   = sprintf "%04x",($data_size + 8);   # Total Length = data size + 8bytes for UDP header

    # Choose one of the entries in udp_dport or udp_sport arrays
    if ($udp_dport_array[0] eq "") {$udp_dport[0] = sprintf "%04x", int(rand(2**16));}
    else {$udp_dport = $udp_dport_array[int(rand($#udp_dport_array))];}
    if ($udp_sport_array[0] eq "") {$udp_sport[0] = sprintf "%04x", int(rand(2**16));}
    else {$udp_sport = $udp_sport_array[int(rand($#udp_sport_array))];}

    # Checksum is different for IPv4 and IPv6
    # In ones-complement arithmetic the result of overflow in addition in the most significant bit
    # is carried over to the least significant bit.
    if ($ipv4_frame == 1) {
      $ipv4_len =  sprintf "%04x",(hex($ipv4_len) + 8);
      $udp_csum =  substr($ipv4_sadd,0,4);
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv4_sadd,4,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv4_dadd,0,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv4_dadd,4,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(11)); # Add protocol
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex($udp_len)); # Add the length
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($udp_sport,0,4))); # Add the UDP source port
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($udp_dport,0,4))); # Add the UDP destination port
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex($udp_len)); # Add the length (again!)
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
      for (my $cntr_csum = 0; $cntr_csum < (($data_size/2)-($data_size % 2)); $cntr_csum++) {
        $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($data_field,($cntr_csum*4),4))); # take 2 bytes of data at a time
        $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
#        printf "CSUM(data %0d of %0d = 0x%x) = $udp_csum\n", $cntr_csum,($data_size/2),hex(substr($data_field,($cntr_csum*4),4));
      }
      # And for last byte (if length was odd number of bytes)
      if (($data_size % 2) == 1) {
        $udp_csum =  sprintf "%05x",hex($udp_csum) + (hex(substr($data_field,-2,2) . "00")); # take last 2 bytes of data
        $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
#        printf "CSUM(last byte = 0x%x) = $udp_csum\n",(hex(substr($data_field,-2,2) . "00"));
      }

      $udp_csum =  sprintf "%04x",(hex("ffff") - hex($udp_csum));

    } elsif ($ipv6_frame == 1) {
      $ipv6_len =  sprintf "%04x",(hex($ipv6_len) + 8);

      $udp_csum =  substr($ipv6_sadd,0,4);
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,4,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,8,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
 #      printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,12,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
 #      printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,16,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
 #      printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,20,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,24,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_sadd,28,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";

      ## Destination is the FINAL address
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,0,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,4,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,8,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,12,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,16,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,20,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,24,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($ipv6_dadd,28,4)));
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
    #   printf "CSUM = $udp_csum\n";

      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex($udp_len)); # Add the length
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";

      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(11)); # Add protocol
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";

      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($udp_sport,0,4))); # Add the UDP source port
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($udp_dport,0,4))); # Add the UDP destination port
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
  #     printf "CSUM = $udp_csum\n";
      $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex($udp_len)); # Add the length (again!)
      $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #    printf "CSUM = $udp_csum\n";
      for (my $cntr_csum = 0; $cntr_csum < (($data_size/2)-($data_size % 2)); $cntr_csum++) {
        $udp_csum =  sprintf "%05x",(hex($udp_csum) + hex(substr($data_field,($cntr_csum*4),4))); # take 2 bytes of data at a time
        $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
   #     printf "CSUM(data %0d of %4x) = $udp_csum\n",$cntr_csum,hex(substr($data_field,($cntr_csum*4),4));
      }
      if (($data_size % 2) == 1) {
        $udp_csum =  sprintf "%05x",hex($udp_csum) + (hex(substr($data_field,-2,2) . "00")); # take last 2 bytes of data
        $udp_csum =  sprintf "%04x",(hex(substr($udp_csum,0,1)) + hex(substr($udp_csum,1,4))); # Add the carry
    #    printf "CSUM(last byte = 0x%x) = $udp_csum\n",(hex(substr($data_field,-2,2) . "00"));
      }
      $udp_csum =  sprintf "%04x",(hex("ffff") - hex($udp_csum));
    }
  }




  # Calculate IPv4 Checksum
  if ($ipv4_frame == 1) {
    $ipv4_csum =  $ipv4_ver.$ipv4_ihl.$ipv4_tos;
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + (hex($ipv4_len)));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex($ipv4_id));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex($ipv4_frg));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex($ipv4_ttl.$ipv4_prt));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex(substr($ipv4_sadd,0,4)));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex(substr($ipv4_sadd,4,4)));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex(substr($ipv4_dadd,0,4)));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex(substr($ipv4_dadd,4,4)));
    $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    for ($ipv4_opt_cnt = 1; $ipv4_opt_cnt <= $num_ipv4_options; $ipv4_opt_cnt++) {
      $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex(substr($ipv4_opt[$ipv4_opt_cnt],0,4)));
      $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
      $ipv4_csum =  sprintf "%05x",(hex($ipv4_csum) + hex(substr($ipv4_opt[$ipv4_opt_cnt],4,4)));
      $ipv4_csum =  sprintf "%04x",(hex(substr($ipv4_csum,0,1)) + hex(substr($ipv4_csum,1,4))); # Add the carry
    }
    $ipv4_csum =  sprintf "%04x",(hex("ffff") - hex($ipv4_csum));
  }

  if ($udp_frame == 1) {
    $data_field = $udp_sport.$udp_dport.$udp_len.$udp_csum.$data_field;
    if ($debug_print_frame == 1) {
      if    ($ipv4_frame == 1) {printf "\nPacket %0d is an IPv4/UDP Frame with the following fields ...\n",($current_packet_num+1);}
      elsif ($ipv6_frame == 1) {printf "\nPacket %0d is an IPv6/UDP Frame with the following fields ...\n",($current_packet_num+1);}
      print "  udp_sport    = $udp_sport\n";
      print "  udp_dport    = $udp_dport\n";
      print "  udp_len      = $udp_len\n";
      print "  udp_csum     = $udp_csum\n";
    }
    $l4_hdr_index = length($udp_sport.$udp_dport.$udp_len.$udp_csum);
  }

  if ($ipv4_frame == 1) {
    if ($debug_print_frame == 1) {
      if ($udp_frame == 0 && $tcp_frame == 0 && $icmp_frame == 0) {
        printf "\nPacket %0d is an IPv4 Frame with the following fields ...\n",($current_packet_num+1);}
      print "  ipv4_ver     = $ipv4_ver  \n";
      print "  ipv4_ihl     = $ipv4_ihl \n";
      print "  ipv4_tos     = $ipv4_tos \n";
      print "  ipv4_len     = $ipv4_len \n";
      print "  ipv4_id      = $ipv4_id  \n";
      print "  ipv4_frg     = $ipv4_frg \n";
      print "  ipv4_ttl     = $ipv4_ttl \n";
      print "  ipv4_prt     = $ipv4_prt \n";
      print "  ipv4_csum    = $ipv4_csum\n";
      print "  ipv4_sadd    = $ipv4_sadd\n";
      print "  ipv4_dadd    = $ipv4_dadd\n";
      if ($num_ipv4_options > 0) {
        for ($ipv4_opt_cnt = 1; $ipv4_opt_cnt <= $num_ipv4_options; $ipv4_opt_cnt++) {
          if ($debug_print_frame == 1) {
            print "  ipv4_option$ipv4_opt_cnt = $ipv4_opt[$ipv4_opt_cnt]\n";
          }
        }
      }
    }
    $data_field   = $ipv4_ver.$ipv4_ihl.$ipv4_tos.$ipv4_len.$ipv4_id.$ipv4_frg.$ipv4_ttl.$ipv4_prt.$ipv4_csum.$ipv4_sadd.$ipv4_dadd.$opts.$data_field;
    $l3_hdr_index = length($ipv4_ver.$ipv4_ihl.$ipv4_tos.$ipv4_len.$ipv4_id.$ipv4_frg.$ipv4_ttl.$ipv4_prt.$ipv4_csum.$ipv4_sadd.$ipv4_dadd.$opts);

  } elsif ($ipv6_frame == 1) {
    if ($debug_print_frame == 1) {
      if ($udp_frame == 0 && $tcp_frame == 0 && $icmp_frame == 0) {
        printf "\nPacket %0d is an IPv6 Frame with the following fields ...\n",($current_packet_num+1);}
      print "  ipv6_ver     = $ipv6_ver\n";
      print "  ipv6_tc      = $ipv6_tc\n";
      print "  ipv6_flow    = $ipv6_flow\n";
      print "  ipv6_len     = $ipv6_len\n";
      print "  ipv6_nxthdr0 = $ipv6_nxthdr_base\n";
      print "  ipv6_ttl     = $ipv6_ttl \n";
      print "  ipv6_sadd    = $ipv6_sadd\n";
      print "  ipv6_dadd    = $ipv6_dadd\n";
    }
    $data_field   = $ipv6_ver.$ipv6_tc.$ipv6_flow.$ipv6_len.$ipv6_nxthdr_base.$ipv6_ttl.$ipv6_sadd.$ipv6_dadd.$data_field;
    $l3_hdr_index = length($ipv6_ver.$ipv6_tc.$ipv6_flow.$ipv6_len.$ipv6_nxthdr_base.$ipv6_ttl.$ipv6_sadd.$ipv6_dadd);
  } elsif ($debug_print_frame == 1) {

  if (hex($vlan1_frame) == hex(8100)) {
    printf "\nPacket %0d is bog standard ethernet frame with VLAN - not IP, UDP, TCP, etc\n",($current_packet_num+1);}
  else {
    printf "\nPacket %0d is bog standard ethernet frame - not IP, UDP, TCP or VLAN etc $vlan1_frame...\n",($current_packet_num+1);}
  }

  $l4_hdr_index = $l3_hdr_index + $l4_hdr_index;
  return ($data_field,$type_len_field,$udp_dport,$ipv4_tos,$ipv6_tc,$l3_hdr_index,$l4_hdr_index);
}

sub read_arguments {
  Getopt::Long::Configure ("pass_through");
  if ($#ARGV < 0) {
    print "Please give testcase name as argument\n";
    exit;
  }
  $full_testcase_path = $ARGV[0];
  $sel_ahb_freq = 0;  # Default same as most legacy tests expect. can override
  $cfg_num_dma_queues = 1;
  $cfg_num_type1_screeners = 1;
  $cfg_num_type2_screeners = 1;
  $cfg_num_scr2_ethtype_regs = 1;
  $cfg_num_scr2_compare_regs = 1;
  $cfg_num_segments_total = 1;
  $cfg_tx_num_segments[0] = 1;
  $cfg_no_stats = 0;
  $cfg_no_pcs   = 1;
  $cfg_num_spec_add_filters = 0;
  $cfg_pcs_legacy_if  = 0;
  $cfg_pcs_10b_if     = 0;
  $cfg_pcs_20b_if     = 0;
  $cfg_ext_fifo_interface = 0;
  $cfg_rx_pkt_buffer = 0;
  $cfg_tx_pkt_buffer = 0;
  $cfg_emac_bus_width = 32;
  $cfg_dma_bus_width = 32;
  $cfg_addrbus = 32;
  $cfg_rx_sram_depth = 32;
  $cfg_tx_sram_depth = 32;
  $cfg_rx_sram_width = 32;
  $cfg_tx_sram_width = 32;
  $cfg_jumbo_max_length = 1500;
  $cfg_tx_sram_size_total = 0;
  $cfg_pbuf_rsc = 0;
  $cfg_pbuf_lso = 0;
  $axi_test = 0;
  $cfg_tsu = 0;
  $cfg_cutthru = 0;
  $cfg_tsu_clk = 0;
  $cfg_use_rgmii = 0;
  $cfg_include_rmii = 0;
  $cfg_has_802p3_br = 0;
  $cfg_asf_enable = 0; 
  $cfg_asf_ecc_sram = 0;
  $cfg_asf_prot_tsu = 0;
  $cfg_asf_prot_tx_sched = 0;
  $cfg_asf_host_par = 0;
  my %opthash = (
                 'seed=s' => \$random_seed,
                 'host_clk_freq=s' => \$sel_ahb_freq,
                 'wait_states=s' => \$wait_states,
                 'fault_point=s' => \$fault_point,
                 'detect_point=s' => \$detect_point,
                 );
  
  GetOptions (%opthash);
  # All other arguments are passed on
  $args = join(' ', @ARGV) ;
  if ($fault_point ne "") {
    open (FAULT_TCL_FILE, ">fault_inj.tcl");
    print FAULT_TCL_FILE "set fault_point   $fault_point;\n";
    print FAULT_TCL_FILE "set detect_point  $detect_point;\n";
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "force tb_gem.double_error_injection = 'b1;\n";
    print FAULT_TCL_FILE "force tb_gem.i_tb_top.auto_fault_checker  = 'b0;\n";
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "run 1.5us;\n";
    print FAULT_TCL_FILE 'if ([value $fault_point]) {';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE '  force $fault_point = 0;';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "} else {\n";
    print FAULT_TCL_FILE '  force $fault_point = 1;';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "}\n";
    print FAULT_TCL_FILE 'stop -create -object $detect_point -name fault_detect_strobe;';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "run;\n";
    print FAULT_TCL_FILE 'set det_val [value $detect_point];';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE 'if ($det_val) {';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "  run 1us;\n";
    print FAULT_TCL_FILE '  echo "                                          TEST PASSED";';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE '} else {';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE '  echo "                            **** FAULT INJECTION CHECK FAILED ****";';
    print FAULT_TCL_FILE "\n";
    print FAULT_TCL_FILE "}\n";
    print FAULT_TCL_FILE "exit";
    close FAULT_TCL_FILE;
  }
  
  $ten_meg_bit = ($ten_meg_bit + 2*$sel_ahb_freq);
#  if (-e "$ENV{RTL_PATH}example_configs/$ENV{DESIGN}_defs_$ENV{CFG}.v") {
#    open CFGFILE , "$ENV{RTL_PATH}example_configs/$ENV{DESIGN}_defs_$ENV{CFG}.v"; 
#  } elsif (-e "./${DESIGN}_defs.v") {
  if (-e "./${DESIGN}_defs.v") {
    open CFGFILE , "./${DESIGN}_defs.v"; 
  } else {
    print "** ERROR ** can't find the design configuration file \n";
    exit;
  }
  
  while (<CFGFILE>) {
    my $line = $_;
    my $commented;
    my $tmpa;
    my $tmpb;
    my $defname;
    my $defvalue;
    my $linecopy = $line;
    $linecopy =~ s/\n//g;
    if ($linecopy =~ /^(\s*\/\/)?(\s*\`define\s+([a-zA-Z0123456789_]+))(\s+[0123456789]*\'[hbd])?(\s*([a-zA-Z0123456789]*)\s*)/) {
      $commented = $1;
      $tmpa = $2;
      $defname = $3;
      if (defined($5)) {$tmpb = $5} else {$tmpb = "undefined"};
      if (defined($6)) {$defvalue = $6} else {$defvalue = "undefined"};
      if (defined($commented) && $commented =~ /\s*\/\//) {$commented = 1;} else {$commented = 0;};      
      if    ($defname eq "dma_priority_queue1")                   {if ($commented != 1) { $cfg_num_dma_queues = 2; }}
      if    ($defname eq "dma_priority_queue2")                   {if ($commented != 1) { $cfg_num_dma_queues = 3; }}
      if    ($defname eq "dma_priority_queue3")                   {if ($commented != 1) { $cfg_num_dma_queues = 4; }}
      if    ($defname eq "dma_priority_queue4")                   {if ($commented != 1) { $cfg_num_dma_queues = 5; }}
      if    ($defname eq "dma_priority_queue5")                   {if ($commented != 1) { $cfg_num_dma_queues = 6; }}
      if    ($defname eq "dma_priority_queue6")                   {if ($commented != 1) { $cfg_num_dma_queues = 7; }}
      if    ($defname eq "dma_priority_queue7")                   {if ($commented != 1) { $cfg_num_dma_queues = 8; }}
      if    ($defname eq "dma_priority_queue8")                   {if ($commented != 1) { $cfg_num_dma_queues = 9; }}
      if    ($defname eq "dma_priority_queue9")                   {if ($commented != 1) { $cfg_num_dma_queues = 10; }}
      if    ($defname eq "dma_priority_queue10")                  {if ($commented != 1) { $cfg_num_dma_queues = 11; }}
      if    ($defname eq "dma_priority_queue11")                  {if ($commented != 1) { $cfg_num_dma_queues = 12; }}
      if    ($defname eq "dma_priority_queue12")                  {if ($commented != 1) { $cfg_num_dma_queues = 13; }}
      if    ($defname eq "dma_priority_queue13")                  {if ($commented != 1) { $cfg_num_dma_queues = 14; }}
      if    ($defname eq "dma_priority_queue14")                  {if ($commented != 1) { $cfg_num_dma_queues = 15; }}
      if    ($defname eq "dma_priority_queue15")                  {if ($commented != 1) { $cfg_num_dma_queues = 16; }}
      if    ($defname eq "gem_axi")                               {if ($commented == 1) { $axi_test = 0; } else { $axi_test = 1; }}
      if    ($defname eq "num_type1_screeners")                   {if ($commented != 1) { $cfg_num_type1_screeners = $defvalue;} else {$cfg_num_type1_screeners = 0;}};
      if    ($defname eq "num_type2_screeners")                   {if ($commented != 1) { $cfg_num_type2_screeners = $defvalue;} else {$cfg_num_type2_screeners = 0;}};
      if    ($defname eq "num_scr2_ethtype_regs")                 {if ($commented != 1) { $cfg_num_scr2_ethtype_regs = $defvalue;} else {$cfg_num_scr2_ethtype_regs = 0;}}
      if    ($defname eq "num_scr2_compare_regs")                 {if ($commented != 1) { $cfg_num_scr2_compare_regs = $defvalue;} else {$cfg_num_scr2_compare_regs = 0;}}
      if    ($defname eq "gem_ext_fifo_interface")                {if ($commented != 1) { $cfg_ext_fifo_interface = 1;} else {$cfg_ext_fifo_interface = 0;}}
      if    ($defname eq "gem_rx_pkt_buffer")                     {if ($commented != 1) { $cfg_rx_pkt_buffer = 1;} else {$cfg_rx_pkt_buffer = 0;}}
      if    ($defname eq "gem_tx_pkt_buffer")                     {if ($commented != 1) { $cfg_tx_pkt_buffer = 1;} else {$cfg_tx_pkt_buffer = 0;}}
      if    ($defname eq "gem_no_stats")                          {if ($commented != 1) { $cfg_no_stats = 1;} else {$cfg_no_stats = 0;}}
      if    ($defname eq "num_spec_add_filters")                  {if ($commented != 1) { $cfg_num_spec_add_filters = $defvalue;} else {$cfg_num_spec_add_filters = 0;}}
      if    ($defname eq "gem_no_pcs")                            {if ($commented != 1) { $cfg_no_pcs = 1;} else {$cfg_no_pcs = 0;}}
      if    ($defname eq "gem_pcs_legacy_if")                     {if ($commented != 1) { $cfg_pcs_legacy_if = 1;} else {$cfg_pcs_legacy_if = 0;}}
      if    ($defname eq "gem_pcs_10b_if")                        {if ($commented != 1) { $cfg_pcs_10b_if = 1;} else {$cfg_pcs_10b_if = 0;}}
      if    ($defname eq "gem_pcs_20b_if")                        {if ($commented != 1) { $cfg_pcs_20b_if = 1;} else {$cfg_pcs_20b_if = 0;}}
      if    ($defname eq "gem_use_rgmii")                         {if ($commented != 1) { $cfg_use_rgmii = 1;} else {$cfg_use_rgmii = 0;}}
      if    ($defname eq "gem_include_rmii")                      {if ($commented != 1) { $cfg_include_rmii = 1;} else {$cfg_include_rmii = 0;}}
      if    ($defname eq "gem_emac_bus_width")                    {$cfg_emac_bus_width = $defvalue; }
      if    ($defname eq "gem_dma_bus_width")                     {$cfg_dma_bus_width = $defvalue; }
      if    ($defname eq "gem_dma_addr_width")                    {$cfg_addrbus = $defvalue; }
      if    ($defname eq "gem_rx_pbuf_addr")                      {$cfg_rx_sram_depth = $defvalue; }
      if    ($defname eq "gem_tx_pbuf_addr")                      {$cfg_tx_sram_depth = $defvalue; }
      if    ($defname eq "gem_rx_pbuf_data")                      {$cfg_rx_sram_width = $defvalue; }
      if    ($defname eq "gem_tx_pbuf_data")                      {$cfg_tx_sram_width = $defvalue; }
      if    ($defname eq "gem_tx_pbuf_queue_segment_size")        {$cfg_num_segments_total = 2**$defvalue; }
      if    ($defname =~ /gem_tx_pbuf_num_segments_q(\d+)/)       {$q = $1; if ($commented != 1) { $cfg_tx_num_segments[$q] = 2**$defvalue; } else {$cfg_tx_num_segments[$q]  = 1;}}
      if    ($defname eq "gem_jumbo_max_length")                  {$cfg_jumbo_max_length = $defvalue; }
      if    ($defname eq "gem_pbuf_cutthru")                      {if ($commented == 1) { $cfg_cutthru = 0; } else { $cfg_cutthru = 1; }}
      if    ($defname eq "gem_tsu")                               {if ($commented == 1) { $cfg_tsu = 0; } else { $cfg_tsu = 1; }}
      if    ($defname eq "gem_tsu_clk")                           {if ($commented == 1) { $cfg_tsu_clk = 0; } else { $cfg_tsu_clk = 1; }}
      if    ($defname eq "gem_asf_enable")                        {if ($commented == 1) { $cfg_asf_enable = 0; } else { $cfg_asf_enable = 1; }}
      if    ($defname eq "gem_asf_ecc_sram")                      {if ($commented == 1) { $cfg_asf_ecc_sram = 0; } else { $cfg_asf_ecc_sram = 1; }}
      if    ($defname eq "gem_asf_prot_tsu")                      {if ($commented == 1) { $cfg_asf_prot_tsu = 0; } else { $cfg_asf_prot_tsu = 1; }}
      if    ($defname eq "gem_asf_prot_tx_sched")                 {if ($commented == 1) { $cfg_asf_prot_tx_sched = 0; } else { $cfg_asf_prot_tx_sched = 1; }}
      if    ($defname eq "gem_asf_host_par")                      {if ($commented == 1) { $cfg_asf_host_par = 0; } else { $cfg_asf_host_par = 1; }}
      if    ($defname eq "gem_pbuf_rsc")                          {if ($commented == 1) { $cfg_pbuf_rsc = 0; } else { $cfg_pbuf_rsc = 1; }}
      if    ($defname eq "gem_pbuf_lso")                          {if ($commented == 1) { $cfg_pbuf_lso = 0; } else { $cfg_pbuf_lso = 1; }}
      if    ($defname eq "gem_has_802p3_br")                          {if ($commented == 1) { $cfg_has_802p3_br = 0; } else { $cfg_has_802p3_br = 1; }}
      #if    ($defname eq "gem_axi_access_pipeline_bits")          {$axi_access_pipeline_bits = $defvalue; }
      #if    ($defname eq "gem_axi_tx_descr_rd_buff_bits")         {$axi_tx_descr_rd_buff_bits = $defvalue; }
      #if    ($defname eq "gem_axi_tx_descr_wr_buff_bits")         {$axi_tx_descr_wr_buff_bits = $defvalue; }
      #if    ($defname eq "gem_axi_rx_descr_rd_buff_bits")         {$axi_rx_descr_rd_buff_bits = $defvalue; }
      #if    ($defname eq "gem_axi_rx_descr_wr_buff_bits")         {$axi_rx_descr_wr_buff_bits = $defvalue; }
    }
  }

  close CFGFILE;
  print "Read params from config file ...\n";
  if ($cfg_ext_fifo_interface) {
    print "\t Host interface = Streaming FIFO\n";
  } else {
    if ($cfg_rx_pkt_buffer) {
      print "\t Host interface = Packet Buffer DMA\n";
    } else {
      print "\t Host interface = Legacy AHB DMA\n";
    }
  }
  print "\t num_queues = $cfg_num_dma_queues\n";
  print "\t axi_test = $axi_test\n";
  print "\t num_type1_screeners = $cfg_num_dma_queues\n";
  print "\t num_type2_screeners = $cfg_num_type2_screeners\n";
  print "\t num_scr2_ethtype_regs = $cfg_num_scr2_ethtype_regs\n";
  print "\t num_scr2_compare_regs = $cfg_num_scr2_compare_regs\n";
  print "\t data_bus_width = $cfg_dma_bus_width\n";
  print "\t addr_bus_width = $cfg_addrbus\n";
  printf "\t rx_sram_size = %0d Bytes\n",2**$cfg_rx_sram_depth * ($cfg_rx_sram_width/8);
  $cfg_tx_sram_size_total = 2**$cfg_tx_sram_depth * ($cfg_tx_sram_width/8);
  printf "\t tx_sram_size(total) = %0d Bytes\n",$cfg_tx_sram_size_total;
  for (my $qw=0;$qw<$cfg_num_dma_queues;$qw++) {
    printf "\t tx_sram_size(q$qw) = %0d Bytes\n",(($cfg_tx_sram_size_total/$cfg_num_segments_total)*$cfg_tx_num_segments[$qw]);
  }
  print "\t num_tx_segments = $cfg_num_segments_total\n";
  
  # If undefined, then randomize the seed .. Note this can be overwritten in the test itself
  if (!defined($random_seed)) {
    $random_seed = int(rand(10000));
    print "Randomizing seed for this test to $random_seed\n";
  } elsif ($random_seed eq "random") {
    $random_seed = int(rand(10000));
    print "Randomizing seed for this test to $random_seed\n";
  } else {
    print "Random Seed for this test was set by calling script to $random_seed\n";
  }
  srand($random_seed);
}

# Check the test is compatible with the configuration ...
sub validate_test {
  system ("rm -rf ./test_translation_failed");	
  my (@requires) = @{$_[0]};
  #print "Validating the test against the configuration ...\n";
  for (my $option = 0; $option <= $#requires; $option = $option+2) {
    if ($requires[$option*2] eq "no_pcs" && $requires[$option*2+1] != $cfg_no_pcs) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "pcs_legacy_if" && $requires[$option*2+1] != $cfg_pcs_legacy_if) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "pcs_10b_if" && $requires[$option*2+1] != $cfg_pcs_10b_if) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "pcs_20b_if" && $requires[$option*2+1] != $cfg_pcs_20b_if) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "no_stats" && $requires[$option*2+1] != $cfg_no_stats) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "num_spec_add_filters" && $requires[$option*2+1] > $cfg_num_spec_add_filters) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "axi" && $requires[$option*2+1] != $axi_test) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "ext_fifo_interface" && $requires[$option*2+1] != $cfg_ext_fifo_interface) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "rx_pkt_buffer" && $requires[$option*2+1] != $cfg_rx_pkt_buffer) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "tx_pkt_buffer" && $requires[$option*2+1] != $cfg_tx_pkt_buffer) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "emac_bus_width" && $requires[$option*2+1] > $cfg_emac_bus_width) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "dma_bus_width" && $requires[$option*2+1] > $cfg_dma_bus_width) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "tx_sram_depth" && $requires[$option*2+1] > $cfg_tx_sram_depth) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "rx_sram_depth" && $requires[$option*2+1] > $cfg_rx_sram_depth) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "rx_sram_size" && $requires[$option*2+1] > (2**$cfg_rx_sram_depth * ($cfg_rx_sram_width/8))) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "cutthru" && $requires[$option*2+1] != $cfg_cutthru) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "tsu" && $requires[$option*2+1] != $cfg_tsu) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "tsu_clk" && $requires[$option*2+1] != $cfg_tsu_clk) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "use_rgmii" && $requires[$option*2+1] != $cfg_use_rgmii) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "include_rmii" && $requires[$option*2+1] != $cfg_include_rmii) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "asf_enable" && $requires[$option*2+1] != $cfg_asf_enable) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "asf_ecc_sram" && $requires[$option*2+1] != $cfg_asf_ecc_sram) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "asf_prot_tsu" && $requires[$option*2+1] != $cfg_asf_prot_tsu) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "asf_asf_prot_tx_sched" && $requires[$option*2+1] != $cfg_asf_prot_tx_sched) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "asf_asf_host_par" && $requires[$option*2+1] != $cfg_asf_host_par) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "pbuf_rsc" && $requires[$option*2+1] != $cfg_pbuf_rsc) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "pbuf_lso" && $requires[$option*2+1] != $cfg_pbuf_lso) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "num_dma_queues" && $requires[$option*2+1] > $cfg_num_dma_queues) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "num_type2_screeners" && $requires[$option*2+1] > $cfg_num_type2_screeners) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "num_scr2_compare_regs" && $requires[$option*2+1] > $cfg_num_scr2_compare_regs) {$incompatible_test = 1;}
    if ($requires[$option*2] =~ /tx_sram_q(\d+)_size/ && $requires[$option*2+1] > (($cfg_tx_sram_size_total/$cfg_num_segments_total)*$cfg_tx_num_segments[$1])) {$incompatible_test = 1;}
    if ($requires[$option*2] eq "has_802p3_br" && $requires[$option*2+1] != $cfg_has_802p3_br) {$incompatible_test = 1;}
    if ($incompatible_test) {
      print "*** Compatibility error : This test cannot be run on this configuration\n";
      print "*** Exiting ...\n";
      system ("touch ./test_translation_failed");
      print_initfile ();	
      print_file_ends ();
      exit;
    }
  }
}
  

sub init_q_ptr {
  my ($cfg_num_dma_queues,$num_tx_queues,$num_rx_queues,@spec_ptrs) = @_;
  my  $tmp_add;
  my  $ptr;

  for (my $tx_queue = 0; $tx_queue < $cfg_num_dma_queues; $tx_queue++) {
    if ($tx_queue < $num_tx_queues) {
      if (!defined($spec_ptrs[$tx_queue])) {$ptr = sprintf "%08x",(int(rand(2**32)) & 0xfffffff0);} # Currently all tx ptrs are 128bit aligned
      else                             {$ptr = $spec_ptrs[$tx_queue];}
      $tx_q_pointer[$tx_queue] = $ptr;
      if    ($tx_queue == 0) {$tmp_add = "001c";}
      else  {                 $tmp_add = sprintf "%04x",(hex(440)+4*($tx_queue-1));}
      print APBFILE ("000000004$tmp_add$ptr   // write tx_q_ptr for Q$tx_queue and keep going, add = $tmp_add, data = $ptr\n");
    } else { # simply disable other queues ...
      $tmp_add = sprintf "%04x",(hex(440)+4*($tx_queue-1));
      print APBFILE ("000000004${tmp_add}ffffffff   // Disable TX Q$tx_queue and keep going, add = $tmp_add\n");
    }
  }
  for (my $rx_queue = 0; $rx_queue < $cfg_num_dma_queues; $rx_queue++) {
    if ($rx_queue < $num_rx_queues) {
      if (!defined($spec_ptrs[$rx_queue+16])) {$ptr = sprintf "%08x",(int(rand(2**32)) & 0xfffffff0);} # Currently all rx ptrs are 128bit aligned
      else                               {$ptr = $spec_ptrs[$rx_queue+16];}
      $rx_q_pointer[$rx_queue] = $ptr;
      $rx_pointer[$rx_queue] = hex ($ptr);
      if    ($rx_queue == 0) {$tmp_add = "0018";}
      elsif ($rx_queue < 8) {$tmp_add = sprintf "%04x",(hex(480)+4*($rx_queue-1));}
      else  {$tmp_add = sprintf "%04x",(hex('5c0')+4*($rx_queue-8));}
      print APBFILE ("000000004$tmp_add$ptr   // write rx_q_ptr for Q$rx_queue and keep going, add = $tmp_add, data = $ptr\n");
    } else { # simply disable other queues ...
      if ($rx_queue < 8) {$tmp_add = sprintf "%04x",(hex(480)+4*($rx_queue-1));}
      else  {$tmp_add = sprintf "%04x",(hex('5c0')+4*($rx_queue-8));}
      print APBFILE ("000000004${tmp_add}ffffffff   // Disable RX Q$rx_queue and keep going, add = $tmp_add\n");
    }
  }
}

# setting screener_type1 randomly will also update the array used by the rx_frame
sub init_screener_type1 {
  my ($num_type1_screeners,$num_rx_queues) = @_;
  my  $tmp_add;
  my  $queue_id = 16;
  my  $dstc_match;
  my  $udp_dport_match;
  my  $en_bits;
  # Setup the screeners to select between 1 of 2 IPv4 TOS or IPv6 TC fields
  $dstc_match = sprintf "%02x",int(rand(2**8));
  push (@ipv4_tos_array,$dstc_match);
  push (@ipv6_tc_array,$dstc_match);
  $dstc_match = sprintf "%02x",int(rand(2**8));
  push (@ipv4_tos_array,$dstc_match);
  push (@ipv6_tc_array,$dstc_match);
  
  # And a different UDP port for each screener
  # also randomize the enable bits and the queue ID
  # This will produce a match probability of 25% (50% for enable, and 50% due to the 2 TOS/TC fields above
  for (my $screener = 0; $screener < $num_type1_screeners; $screener++) {
    $queue_id = sprintf "%01x",int(rand($num_rx_queues));
    $udp_dport_match = sprintf "%04x",int(rand(2**16));
    $dstc_match = $ipv4_tos_array[int(rand($#ipv4_tos_array+1))]; # randomly select one of the TOS/TC fields
    $en_bits = sprintf "%01x",int(rand(2**1)); # Always enable UDP and TC/DSTC match (or neither), otherwise we could get false matching due to randomization ..
    if ($en_bits == 1) {$en_bits = 3;}

    $tmp_add = sprintf "%04x",(hex(500)+4*$screener);
    print APBFILE ("000000004$tmp_add$en_bits$udp_dport_match$dstc_match$queue_id   // write screener type1 #$screener and keep going, add = $tmp_add, dstc_match = $dstc_match, queue = $queue_id\n");

    # set variables for random transactor ..
    push (@type1_screener_reg,"$en_bits$udp_dport_match$dstc_match$queue_id"); 
    push (@udp_dport_array,$udp_dport_match);
    push (@udp_sport_array,sprintf "%04x",int(rand(2**16))); # Always use the same UDP source port .. These arent used in the screeners
    $udp_frame = 1;
    $ipv4_frame = 1;
    $ipv6_frame = 0;
    $num_ipv4_options = int(rand(11));
    $use_dest_hdrs = 1;
    $use_hop_hdrs = 1;
    $use_route_hdrs = 1;
    $use_frag_hdrs = 0;
  }
}
  
sub init_dma {
  my ($force_max_burst_tx,$force_max_burst_rx,$max_buf_size,$min_buf_size,$burst,$addr_bus,$ext_bd,$tx_csum_offload) = @_;
  my  $tmp_add;
  my $buf_size = sprintf "%02x",int(rand((($max_buf_size/64)-($min_buf_size/64))) + ($min_buf_size/64));
  if ($burst eq "random") {
    $burst = sprintf "%01x",int(rand(5));
    if ($burst == 0) {$burst = sprintf "%02x",1}
    elsif ($burst == 1) {$burst = sprintf "%02x",4}
    elsif ($burst == 2) {$burst = sprintf "%02x",4}
    elsif ($burst == 3) {$burst = sprintf "%02x",8}
    elsif ($burst == 4) {$burst = sprintf "%02x",16}
  } else {$burst = sprintf "%02x",$burst}
  if ($addr_bus eq "random") {if ($cfg_addrbus == 32) { $addr_bus = 0;} else {$addr_bus = sprintf "%01x",int(rand(2));}}
  elsif ($addr_bus == 32) {$addr_bus = 0;}
  elsif ($addr_bus == 64) {$addr_bus = 1;}
  if ($ext_bd eq "random")   {$ext_bd = sprintf "%01x",int(rand(2));}
  if ($force_max_burst_tx eq "random")   {$force_max_burst_tx = sprintf "%01x",int(rand(2));}
  if ($force_max_burst_rx eq "random")   {$force_max_burst_rx = sprintf "%01x",int(rand(2));}
  if ($tx_csum_offload eq "random")   {$tx_csum_offload = sprintf "%01x",int(rand(2));}
  
  $addr_bus = 4*int($addr_bus) + 3*int($ext_bd);
  if ($addr64 == 1) {
    $descr_addr_upper_32 = sprintf "%08x",int(rand(2**32));
    print APBFILE ("00000000404d4",$descr_addr_upper_32,"   // write MSB BD base addr \n");
  }

  $tmp_add = sprintf "%04x",(hex(10));

  # set variables for random transactor ..
  $buffer_size          = hex($buf_size) * 64;
  $rx_auto_discard_pkts = 0;
  $rx_auto_discard_pkts_q0 = 0;
  $rx_auto_discard_pkts_q1 = 0;
  $rx_auto_discard_pkts_q2 = 0;
  $rx_auto_discard_pkts_q3 = 0;
  $rx_auto_discard_pkts_q4 = 0;
  $rx_auto_discard_pkts_q5 = 0;
  $rx_auto_discard_pkts_q6 = 0;
  $rx_auto_discard_pkts_q7 = 0;
  $rx_auto_discard_pkts_q8 = 0;
  $rx_auto_discard_pkts_q9 = 0;
  $rx_auto_discard_pkts_q10 = 0;
  $rx_auto_discard_pkts_q11 = 0;
  $rx_auto_discard_pkts_q12 = 0;
  $rx_auto_discard_pkts_q13 = 0;
  $rx_auto_discard_pkts_q14 = 0;
  $rx_auto_discard_pkts_q15 = 0;
  $ahb_burst_size       = hex($burst);
  $addr64               = ($addr_bus & 4) >> 2;
  $ext_bd_tx            = ($addr_bus & 2) >> 1;
  $ext_bd_rx            = $addr_bus & 1;
  $nib7                 = $rx_auto_discard_pkts + 2*$force_max_burst_rx + 4*$force_max_burst_tx;
  $nib3                 = sprintf "%01x",(7+8*$tx_csum_offload);

  print APBFILE ("000000004$tmp_add",$addr_bus,$nib7,$buf_size,"0",$nib3,$burst,"   // write dma configuration register (offset 0x$tmp_add), burst = 0x$burst, rxbuf size = $buffer_size, 64bit addressing = $addr64, extbd = $ext_bd_tx\n");
  print "DMA config register initialized to burst = 0x$burst, rxbuf size = $buffer_size, 64bit addressing = $addr64, extbd = $ext_bd_tx\n";
}
  
sub init_ncr {
  my  $tmp_add;
  my $nib0 ;
  my $nib5 ;
  my $nib6 ;
  my $dma_bus_width = 0;
  if ($databus eq "random") {
    if ($cfg_dma_bus_width == "32")     {$databus = 32;} 
    elsif ($cfg_dma_bus_width == "64")  {$databus = int(1<<((rand(2)+5)));}
    else                          {$databus = int(1<<((rand(3)+5)));}
  } 
  if ($databus == 32)     {$dma_bus_width = 0;}
  elsif ($databus == 64)  {$dma_bus_width = 1;}
  elsif ($databus == 128) {$dma_bus_width = 2;}
  if ($copy_all eq "random") {
    $copy_all = int(rand(2));
  }
  if ($jumbo eq "random") {
    $jumbo = int(rand(2));
  }
  if ($rxoffset eq "random") {
    $rxoffset = int(rand(4));
  }
  
  if ($speed eq "random") {
    if ($pinsd[27] == 1 && $pinsd[28] == 0) {  #pinsd[28] and [27] represents RMII select pin - if bit 27=1 and bit 28=0 we are RMII and can only support 10/100 speeds
      $speed = int(rand(2));
      if ($speed == 0) {$speed = "10m";} else {$speed = "100m";}
    } else {
      $speed = int(rand(3));
      if ($speed == 0) {$speed = "10m";} elsif ($speed == 1) {$speed = "100m";} elsif ($speed == 2) {$speed = "1g";}
    } 
  } 
  if ($speed eq "1g") {
    $speed_local = 2;
  } elsif ($speed eq "100m") {
    $speed_local = 1;
  } else {
    $speed_local = 0;
  }
  if ($speed_local == 0 && ($ten_meg_bit%2)==0) {$ten_meg_bit = $ten_meg_bit + 1;}
  if ($jumbo == 0 && $cfg_jumbo_max_length > 1500) {$rx_jumbo_max_len_reg = 1500;} else {$rx_jumbo_max_len_reg = $cfg_jumbo_max_length;}
  if ($duplex eq "random") {
    $duplex_local = int(rand(2))*2; 
    if ($duplex_local == 2) {$duplex = "full";} else {$duplex = "half";}
  }
  elsif ($duplex eq "full") {$duplex_local = 2;}
  else {$duplex_local = 0;}
  if ($eam eq "random") {$eam = int(rand(2));}
  if ($retry_test eq "random") {$retry_test = int(rand(2));}
  if ($pause_en eq "random") {$pause_en = int(rand(2));}
  if ($multicast_hash eq "random") {$multicast_hash = int(rand(2));}
  if ($unicast_hash eq "random") {$unicast_hash = int(rand(2));}
  if ($dont_copy_pause eq "random") {$dont_copy_pause = int(rand(2));}
  if ($length_err_discard eq "random") {$length_err_discard = int(rand(2));}
  if ($pcs_en eq "random") {$pcs_en = int(rand(2));}
  if ($sgmii_en eq "random") {$sgmii_en = int(rand(2));}
  if ($rx_toe eq "random") {$rx_toe = int(rand(2));}

  $tmp_add = sprintf "%04x",(hex(04));
  $nib0 = sprintf "%01x", ($jumbo*8 + $duplex_local + ($speed_local >= 1));
  $nib1 = sprintf "%01x", ($unicast_hash*8 + $multicast_hash*4 + $copy_all);
  $nib2 = sprintf "%01x",((($speed_local == 2) << 2) + $eam*2 +$pcs_en*8);
  $nib3 = sprintf "%01x", ($retry_test + 2*$pause_en + 4*$rxoffset); 
  $nib4 = sprintf "%01x", $length_err_discard; 
  $nib5 = sprintf "%01x", (($dma_bus_width << 1) + (8*$dont_copy_pause)); 
  $nib6 = sprintf "%01x", $rx_toe + 8*$sgmii_en; 
  print APBFILE ("000000004".$tmp_add."0".$nib6.${nib5}.$nib4.$nib3.$nib2.$nib1.$nib0."   // Write network config register (speed = $speed, databus = $databus, jumbo = $jumbo, copyall = $copy_all)\n");

  # set variables for random transactor ..
  if ($databus == 32){$width32=1;$width64=0;$width128=0;};
  if ($databus == 64){$width32=0;$width64=1;$width128=0;};
  if ($databus == 128){$width32=0;$width64=0;$width128=1;};
  $strip_fcs  = 0;
  if ($speed_local == 2) {$gigabit = 1;}else {$gigabit=0;}
  $speed_mode = $speed_local;
  $scale_event_factor = 1;
  if ($speed_mode == 0) {$scale_event_factor = 10;}
  if ($speed_mode == 2) {$scale_event_factor = "0.1";}
  
  print "Network config register initialized to (duplex = $duplex, rx_buf_offset = $rxoffset, speed = $speed, databus = $databus, jumbo = $jumbo, copyall = $copy_all)\n";

  if ($rxoffset != 0 && $cfg_pbuf_rsc) {
    print "\tWarning... rxoffset was resolved to something other than 0, but since RSC is enabled in this config, it will have no effect ..\n";
    $rxoffset = 0;
  }

}
  
sub enable_ints {
  my ($num_queues,$vector) = @_;
  my  $tmp_add;

  for (my $queue = 0; $queue < $num_queues; $queue++) {
    if ($queue == 0) {
      $tmp_add = sprintf "%04x",(hex(28));
    } elsif ($queue < 8) {
      $tmp_add = sprintf "%04x",(hex(600) + 4*($queue-1));
    } else {
      $tmp_add = sprintf "%04x",(hex(660) + 4*($queue-8));
    }
    print APBFILE ("000000004".$tmp_add.$vector."   // Write interrupt enable reg for queue $queue\n");
  }
}
  
sub disable_ints {
  my ($num_queues,$vector) = @_;
  my  $tmp_add;

  for (my $queue = 0; $queue < $num_queues; $queue++) {
    if ($queue == 0) {
      $tmp_add = sprintf "%04x",(hex('2c'));
    } elsif ($queue < 8) {
      $tmp_add = sprintf "%04x",(hex(620) + 4*($queue-1));
    } else {
      $tmp_add = sprintf "%04x",(hex(680) + 4*($queue-8));
    }
    print APBFILE ("000000004".$tmp_add.$vector."   // Write interrupt disable reg for queue $queue\n");
  }
}
  
sub print_initfile {
  # write out init file
  # convert testcase name to number format
  $temp2 = $testcase_name;
  $temp2 =~ tr/A-Z/a-z/;    # make all lower case
  $temp = chop ($temp2);
  $testcase_name2 = "";
  for ($i = 1; $i <= 50; $i++) {
     $out = sprintf "%02x",ord($temp);  # returns ascii value
     $testcase_name2 = $out . $testcase_name2;
     $temp = chop ($temp2);
  }
  
  $date_time = `date +'%e %b %Y'`;
  chop ($date_time);
  
  # convert date  to number format
  $temp2 = $date_time;
  $temp2 =~ tr/A-Z/a-z/;    # make all lower case
  $temp = chop ($temp2);
  $date_time2 = "";
  for ($i = 1; $i <= 50; $i++) {
     $out = sprintf "%02x",ord($temp);
     $date_time2 = $out . $date_time2;
     $temp = chop ($temp2);
  }
  printf INITFILE "// Contains testcase name and date in ASCII format\n",;
  printf INITFILE "// this testbench can read this and write the appropriately named\n",;
  printf INITFILE "// results file and include the testcase name in its reports\n",;
  $random_seed  = sprintf "%0100x", $random_seed ;
  printf INITFILE "$random_seed  // Seed\n",;
  printf INITFILE "$testcase_name2  // $testcase_name\n",;
  printf INITFILE "$date_time2  // $date_time\n",;
  $read_min  = sprintf "%02x", $read_min ;
  $read_max  = sprintf "%02x", $read_max ;
  $write_min = sprintf "%02x", $write_min;
  $write_max = sprintf "%02x", $write_max;
  $descr_min = sprintf "%02x", $descr_min;
  $descr_max = sprintf "%02x", $descr_max;
  $data_min  = sprintf "%02x", $data_min ;
  $data_max  = sprintf "%02x", $data_max ;
  $data_min_lock  = sprintf "%02x", $data_min_lock ;
  $data_max_lock  = sprintf "%02x", $data_max_lock ;
  $ten_gig_mode  = sprintf "%01x", ($ten_gig_mode + 2*$fourty_gig_mode) ;
  $fifo_loopback_mode  = sprintf "%01x", $fifo_loopback_mode ;
  $axi_perf_test  = sprintf "%01x", $axi_perf_test ;
  $ten_meg_bit = sprintf("%02x", $ten_meg_bit);
  $auto_fault_checker  = sprintf "%01x", $auto_fault_checker ; 
  $disable_txd_checking  = sprintf "%01x", $tx_data_check ;
  $double_error_injection  = sprintf "%01x", $double_error_injection ;
  $fault_sim_en  = sprintf "%01x", $fault_sim_en ; 
  $fault_sim  = sprintf "%04x", $fault_sim ; 
  $tb_use_phy_model  = sprintf "%01x", $tb_use_phy_model ; 
  $single_error_injection = sprintf "%01x", $single_error_injection ;
  $num_sram_errors_to_inject = sprintf "%05x", $num_sram_errors_to_inject ;

  if ($stop ==0) {
     printf INITFILE "%038x$tb_use_phy_model$incompatible_test$fault_sim$fault_sim_en$num_sram_errors_to_inject$single_error_injection$double_error_injection$disable_txd_checking$auto_fault_checker$axi_perf_test$fixed_latency_mode$ten_gig_mode$read_min$read_max$write_min$write_max$descr_min$descr_max$data_min$data_max$data_min_lock$data_max_lock$fifo_loopback_mode%013x$fifo_over_delay$fifo_status_delay$fifo_under_delay$fifo_latency$bus_grant_delay$wait_states$ten_meg_bit$stop  // use \$finish to end test\n",0,($randomize_hgrant+(2*$randomize_hready)+(4*$check_txlinerate));
  } else {
     printf INITFILE "%038x$tb_use_phy_model$incompatible_test$fault_sim$fault_sim_en$num_sram_errors_to_inject$single_error_injection$double_error_injection$disable_txd_checking$auto_fault_checker$axi_perf_test$fixed_latency_mode$ten_gig_mode$read_min$read_max$write_min$write_max$descr_min$descr_max$data_min$data_max$data_min_lock$data_max_lock$fifo_loopback_mode%013x$fifo_over_delay$fifo_status_delay$fifo_under_delay$fifo_latency$bus_grant_delay$wait_states$ten_meg_bit$stop  // use \$stop to end test\n",0,($randomize_hgrant+(2*$randomize_hready)+(4*$check_txlinerate));
  }
  if ($fourty_gig_mode ==1) {
     printf INITFILE "// tx_clk and rx_clk will be driven at 625 MHz\n";
  } elsif ($ten_gig_mode ==1) {
     printf INITFILE "// tx_clk and rx_clk will be driven at 156.25 MHz\n";
  }
  if (hex($ten_meg_bit)%2==1) {
     printf INITFILE "// tx_clk and rx_clk will be driven at 2.5 MHz\n";
  }
  if ($fifo_loopback_mode==1) {
     printf INITFILE "// Using External FIFO Loopback mode\n";
  }
  if ($randomize_hgrant ==1) {
     printf INITFILE "// Randomizing hgrant in this test\n";
  }
  if ($randomize_hready ==1) {
     printf INITFILE "// Randomizing hready in this test\n";
  }
  if ($check_txlinerate ==1) {
     printf INITFILE "// Checking that TX Line rate is not dropped in this test\n";
  }
  printf INITFILE "// AMBA bus configured for $wait_states wait states\n";
  printf INITFILE "// AMBA bus configured for $bus_grant_delay cycle delay in granting the bus\n";
  printf INITFILE "// TX FIFO configured for $fifo_latency data valid latency\n";
  printf INITFILE "// TX FIFO configured for $fifo_under_delay data underflow latency\n";
  printf INITFILE "// TX FIFO configured for $fifo_status_delay status update delay\n";
  printf INITFILE "// RX FIFO configured for $fifo_over_delay overflow delay\n";
  printf INITFILE "// read_min      = $read_min \n";
  printf INITFILE "// read_max      = $read_max \n";
  printf INITFILE "// write_min     = $write_min\n";
  printf INITFILE "// write_max     = $write_max\n";
  printf INITFILE "// descr_min     = $descr_min\n";
  printf INITFILE "// descr_max     = $descr_max\n";
  printf INITFILE "// data_min      = $data_min \n";
  printf INITFILE "// data_max      = $data_max \n";
  printf INITFILE "// data_min_lock = $data_min_lock\n";
  printf INITFILE "// data_max_lock = $data_max_lock\n";
  printf INITFILE "// auto_fault_checker = $auto_fault_checker\n";
  printf INITFILE "// tx_data_check = $tx_data_check\n";
  printf INITFILE "// double_error_injection = $double_error_injection\n";
  printf INITFILE "// single_error_injection = $single_error_injection\n";
  printf INITFILE "// num_sram_errors_to_inject = $num_sram_errors_to_inject\n";
  printf INITFILE "// fault_sim_en     = $fault_sim_en\n";
  printf INITFILE "// fault_sim     = $fault_sim\n";
  printf INITFILE "// incompatible_test = $incompatible_test\n";
  printf INITFILE "// tb_use_phy_model = $tb_use_phy_model\n";
}  

sub print_file_ends {
  print APBFILE "000000000000000000000   //        end-stop\n";
  print PINSDFILE "0000000000000000000000000000000000000000000000000000000000000000000000000000000000   //        end-stop\n";
  print PINSCFILE "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000   //        end-stop\n";
  print FILTERDFILE "00000000000   //        end-stop\n";
  print FILTERCFILE "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000   // end-stop\n";
  for($i=0; $i<16; $i++) {
    print {$DMARD_RXDESCR_FH[$i]} "400000000fedcba9800000000  // stop\n";
    print {$DMAWR_RXDESCR_FH[$i]} "400000000fedcba9800000000ff  // stop\n";
    print {$DMAWR_RXDATA_FH[$i]}  "400000000fedcba9800000000ff  // stop\n";
    print {$DMARD_TXDESCR_FH[$i]} "400000000fedcba9800000000  // stop\n";
    print {$DMAWR_TXDESCR_FH[$i]} "400000000fedcba9800000000ff  // stop\n";
    print {$DMARD_TXDATA_FH[$i]}  "400000000fedcba9800000000  // stop\n";
  }
  print DMAHRDYFILE "00000000  // stop\n";
  print FIFORDFILE "0f0000000000000  // stop\n";
  print FIFOWRFILE "f000000000000000000000000  // stop\n";
  print COMMENTFILE "0000000000000000  // stop\n";
  print TXDFILE "0000000  // end-stop\n";
  print TXDFILE1 "0000000  // end-stop\n";
  print TXDFILE2 "0000000  // end-stop\n";
  print TXDFILE3 "0000000  // end-stop\n";
  print TXDFILE4 "0000000  // end-stop\n";
  print TXDFILE5 "0000000  // end-stop\n";
  print TXDFILE6 "0000000  // end-stop\n";
  print TXDFILE7 "0000000  // end-stop\n";
  print TXDFILE8 "0000000  // end-stop\n";
  print TXDFILE9 "0000000  // end-stop\n";
  print TXDFILE10 "0000000  // end-stop\n";
  print TXDFILE11 "0000000  // end-stop\n";
  print TXDFILE12 "0000000  // end-stop\n";
  print TXDFILE13 "0000000  // end-stop\n";
  print TXDFILE14 "0000000  // end-stop\n";
  print TXDFILE15 "0000000  // end-stop\n";
  print RXDFILE "00000000000  // end-stop\n";
  print TXPCSFILE "000000  // end-stop\n";
  print RXPCSFILE "0000  // end-stop\n";
  print MDIOFILE "10  // stop\n";
  print EVENTFILE "00000000    // end-stop\n";
  printf BUFCNTFILE "%x\n", $total_buffer_count;
  printf BUFCNTFILE1 "%x\n", $total_buffer_countq1;
  printf BUFCNTFILE2 "%x\n", $total_buffer_countq2;
  printf BUFCNTFILE3 "%x\n", $total_buffer_countq3;
  printf BUFCNTFILE4 "%x\n", $total_buffer_countq4;
  printf BUFCNTFILE5 "%x\n", $total_buffer_countq5;
  printf BUFCNTFILE6 "%x\n", $total_buffer_countq6;
  printf BUFCNTFILE7 "%x\n", $total_buffer_countq7;
  printf BUFCNTFILE8 "%x\n", $total_buffer_countq8;
  printf BUFCNTFILE9 "%x\n", $total_buffer_countq9;
  printf BUFCNTFILE10 "%x\n", $total_buffer_countq10;
  printf BUFCNTFILE11 "%x\n", $total_buffer_countq11;
  printf BUFCNTFILE12 "%x\n", $total_buffer_countq12;
  printf BUFCNTFILE13 "%x\n", $total_buffer_countq13;
  printf BUFCNTFILE14 "%x\n", $total_buffer_countq14;
  printf BUFCNTFILE15 "%x\n", $total_buffer_countq15;
}

