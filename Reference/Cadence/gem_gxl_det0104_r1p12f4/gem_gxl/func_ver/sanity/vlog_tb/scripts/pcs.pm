#########################################################################
#
# $Id: pcs.pm,v 1.1 2012-12-19 12:51:54 smckelvi Exp $
# Release : $Revision: 1.1 $
#
#            CADENCE                    Copyright (c) 2002
#            DESIGN                     Cadence Design Foundry, Inc.
#            FOUNDRY                    All rights reserved.
# 
#
# Description:       perl routines to help trans.pl script in 
#                    handling TBI frames.
# 
#
# Author:            Various  
#
#
# Revision history:
#
# $Log: not supported by cvs2svn $
# Revision 1.21  2009/10/14 10:40:22  ewanm
# Updated after rerun in giggle for release 1p21
#
# Revision 1.8  2006/08/06 11:14:17  martinj
# Updated to latest Giggle for packet buffer and script config changes
#
# Revision 1.20  2005/01/07 18:02:08  arthurm
# Changed 'and' to get rid of warnings
#
# Revision 1.19  2003/07/04 15:44:46  arthurm
# Checking in versions with the Mindspeed updates
#
# Revision 1.4  2003/04/24 14:50:35  martinj
# Copied over latest changes in source files from Giggle to Ipanema.
# For details of changes please refer to Giggle issue 194.
#
# Revision 1.18  2002/11/19 10:36:16  martinj
# Added revision header to file and copyright.
#
#
#
#
#########################################################################

package pcs;
require Exporter;

@pcs::ISA=qw(Exporter);
@pcs::EXPORT=qw();
@pcs::EXPORT_OK=qw(&pcs &stream_encode &sprintfdec2bin &samoct);

use strict;


sub pcs {

   my ($data, $running_disparity_in, $burst, $carrier_val, $mod_start,
       $auto_neg, $err_type, $err_locn, $err_posn, $replacement_pos,
       $pcs_err_trunc, $last_config_set, $debug) = @_; 

   my $preamble_cnt = 0;
   my $sym_err_cnt = 0;
   my ($crc, $new_data, $disparity, $enc_data, $full_packet);
   my ($last_code_even, $output_packet, $running_disparity_out, $data_codes);

   if ($auto_neg == 0) {
      ($new_data, $crc, $preamble_cnt, $sym_err_cnt) = gen_crc ($data, $debug);
   } else {
      $new_data = $data;    # skip crc generation for autonegotiation sequences
   }
   ($enc_data, $disparity) = encode ($new_data, $running_disparity_in, $sym_err_cnt, $auto_neg, $debug); 

   ($full_packet, $running_disparity_out, $last_code_even, $data_codes) = 
     gen_pkt ($disparity, $enc_data, $preamble_cnt, $burst, $carrier_val, 
              $auto_neg, $debug, $mod_start, $err_type, $last_config_set);
   
   if ($err_type != 0) {
      $output_packet = gen_err ($full_packet,$err_type, $err_locn, $err_posn, $replacement_pos, $pcs_err_trunc, $preamble_cnt, $data_codes, $debug);
      return ($output_packet, $running_disparity_out, $last_code_even);
   } else {
      return ($full_packet, $running_disparity_out, $last_code_even);
   }

   
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
   my $pre_is_smds = 0;
   my $pre_is_smdc = 0;

   # Removes the preamble and SFD from the data
   if ($data =~ /^(5+)(d5|e6|4c|7f|b3|61|52|9e|2a|07|19)(.*)$/ ) {
      $data = $3;
      $preamble_count = (length $1)/2;
      $preamble  = "$1"."$2";
   }
   if ($data =~ /^(5+)(e6|4c|7f|b3)(.*)$/ ) {
      $pre_is_smds = 1;
    }
   if ($data =~ /^(5+)(61|52|9e|2a)(.*)$/ ) {
      $pre_is_smdc = 1;
    }

   # Removes the CRC place holders if there are any
   if ($data =~ /^(.*)gggggggg$/ ) {
      $crc_en = 1;
      $data = $1;
   }
   elsif ($data =~ /^(.*)gg$/ ) {
      $crc_en = 0;
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




#############################################################


sub encode {
  
  #****************INPUTS*******************
  my ($current_frame_8_crc, $input_disparity, $number_error_symbols, $auto_neg, $debug) = @_;
  
  #***************OUTPUTS*******************
  my $enc_data = "";
  my $disparity = $input_disparity;
  #*****************************************
  
  my $frame_data = $current_frame_8_crc;
  my $frame_bytes = length $current_frame_8_crc;
  my $frame_length = ($frame_bytes/2);
  my $encoded_byte_hex = "";
  my $temp0 = "";
  my $temp1 = "";
  my $crc_bytes ="";
  my $ten_bit_code = "";
  my $hex_length = "";
  my $encoded_byte = "";
  my $i = "";
  my @crc_bytes = "";
  my $num_6 = "";
  my $crc_byte_bin = "";
  my $num_4 = "";
  my $num0 = "";
  my $num8 = "";
  my $num9 = "";
  my $flag = 1;
  my $j = 0;
  if ($debug >= 1) {printf "\n\n\nEncoder Summary\n------------------------------\n";}
  if ($debug > 1) {print "Frame octets (inc. preamble)  : $frame_length  \n";}
  if ($debug > 1) {    printf "Input disparity               : $input_disparity\n";}
  if ($debug > 1) {    printf "Input frame                   : $current_frame_8_crc\n";}
  for ($i = 0; $i < $frame_length; $i++) 
    {
      $temp0 = chop $frame_data;
      $temp1 = chop $frame_data;
      $crc_bytes[$frame_length-$i] = "$temp1"."$temp0";
    }
  
  for ($i = 1; $i <= $frame_length; $i++) 
    {
      my $crc_byte = "$crc_bytes[$i]";
       $j = $j + 1;
      if (($j == 5) and ($auto_neg == 1)) 
        {
          $j = 1;
          $flag = 1;
        } 
       if (($auto_neg == 1) and ($flag == 1) and ($crc_byte eq "bc")) 
        {
          if ($debug > 2) 
            {
              print "Auto negotiation packet ...";
            }
          if ($disparity == 1) 
            {
              $ten_bit_code = "305";
              $disparity = 0;
            }
          else 
            {
              $ten_bit_code = "0fa";
              $disparity = 1;
            }
	         $flag = 0;
        } 
      else 
        {
          if ($debug > 2)
            {
              print "OCTET $i \t\t      : $crc_bytes[$i]\n";
            }    
          
          if ($crc_byte eq "yy") 
            { #checks if error has to be inserted
              $encoded_byte_hex = "000";
            }
          else 
            {
              $crc_byte = oct("0x"."$crc_bytes[$i]"); #read input in the hex format
              #wrong sfd is transmitted if 55 or d5 is found at the start of normal frame
              #the first 55 in an eth frame is substituted with start_of_packet /S/ 
              if (($i == 1) and ($crc_byte == 0x55) and ($auto_neg == 0)) 
                {
                  if ($disparity) 
                    {
                      $encoded_byte_hex = "97";
                    }
                  else
                    { 
                      $encoded_byte_hex = "368";
                    }
                  
                }
              else
                {
                  if ($debug > 2) 
                    {
                      # $crc_byte_bin = sprintf ("%08b", $crc_byte);
                      $crc_byte_bin = sprintfdec2bin (8, $crc_byte);
		      printf "\tCRC byte\t      : %x ",$crc_byte;
                      printf "($crc_byte_bin)        \n";
                      printf "\tLast disparity\t      : $disparity\n";
                    }
                  # byte is passed on to 8b/10b encoder
                  $encoded_byte = encoder($crc_byte,$disparity);
                  $disparity = calc_disparity($encoded_byte,$disparity,$debug);
                  $encoded_byte_hex = sprintf "%x",$encoded_byte; 
#                  #splitt up 10 bits into 2 subgroups for calculating RD
#                  $temp0 = ($encoded_byte / 16);
#                  $temp1 = sprintf ("%04b", $temp0);
#                  $num_6 = oct("0b"."$temp1");
#                  $num_4 = ($encoded_byte & 15);
#                  if ($debug > 2) 
#                    {
#                      $num0 = sprintf ("%010b", $encoded_byte);
#                      printf "\tEncoded data:"; 
#                      printf " (0x%3x)  ",$encoded_byte; 
#                      printf " ($num0) \n"; 
#                      $num8 = sprintf ("%06b", $num_6);
#                      printf "\tUpper $num8 \t      :  ";
#                    }
#                  $disparity = disp_check6($num_6,$disparity);
#                  if ($debug > 2) 
#                    {
#                      printf "Disparity = %1b\n",$disparity;
#                      $num9 = sprintf ("%04b", $num_4);
#                      printf "\tLower $num9 \t      :  ";
#                    }
#                  $disparity = disp_check4($num_4,$disparity);
#                  if ($debug > 2) 
#                    {
#                      printf "Running disparity = %1b\n",$disparity;
#                    }
#                  #***********************************  
                }
              
            }
          
          
          #**********************************************
          #to convert data into  length of 3 digits
          #**********************************************
          $hex_length = length $encoded_byte_hex;
          if ($hex_length == 3) 
            {
              $ten_bit_code =  $encoded_byte_hex
            }
          elsif ($hex_length == 2) 
            {
              $ten_bit_code =  "0".$encoded_byte_hex
            }
          else 
            {
              $ten_bit_code =  "00".$encoded_byte_hex
            }
          #**********************************************
          #**********************************************
        }
      $enc_data = "$enc_data"."$ten_bit_code";    
      
    }

  # append symbol errors to end of frame for pcs_tx checking
  for ($i = 0; $i < $number_error_symbols; $i++) {
  ($ten_bit_code, $disparity) = stream_encode (" sfe", $disparity, $debug);
  $enc_data = "$enc_data"."$ten_bit_code";
  }

  if ($debug >= 1) 
    {
      if ($auto_neg) 
        {
          printf "8b/10b encoded auto neg frame : $enc_data\n"; 
        }
      else
        {
          printf "8b/10b encoded frame with sfd : $enc_data\n"; 
        }
      printf "final disparity               : $disparity\n\n"; 
    }  
  return ($enc_data,$disparity);
  
}



sub k_encoder {
  my ($octet_hex,$in_disp) = @_;
  my $encode = "";
  
  if ($in_disp) {   # positive input disparity

    if ($octet_hex == 0x1c) {
      $encode = sprintf("%03x", samoct("0b1100001011"));  # 30b
    } elsif ($octet_hex == 0x3c) {
      $encode = sprintf("%03x", samoct("0b1100000110"));  # 306
    } elsif ($octet_hex == 0x5c) {
      $encode = sprintf("%03x", samoct("0b1100001010"));  # 30a
    } elsif ($octet_hex == 0x7c) {
      $encode = sprintf("%03x", samoct("0b1100001100"));  # 30c
    } elsif ($octet_hex == 0x9c) {
      $encode = sprintf("%03x", samoct("0b1100001101"));  # 30d
    } elsif ($octet_hex == 0xbc) {
      $encode = sprintf("%03x", samoct("0b1100000101"));  # 305
    } elsif ($octet_hex == 0xdc) {
      $encode = sprintf("%03x", samoct("0b1100001001"));  # 309
    } elsif ($octet_hex == 0xfc) {
      $encode = sprintf("%03x", samoct("0b1100000111"));  # 307
    } elsif ($octet_hex == 0xf7) {
      $encode = sprintf("%03x", samoct("0b0001010111"));  # 057
    } elsif ($octet_hex == 0xfb) {
      $encode = sprintf("%03x", samoct("0b0010010111"));  # 097
    } elsif ($octet_hex == 0xfd) {
      $encode = sprintf("%03x", samoct("0b0100010111"));  # 117
    } elsif ($octet_hex == 0xfe) {
      $encode = sprintf("%03x", samoct("0b1000010111"));  # 217 
    } elsif ($octet_hex == 0x00) {
      $encode = sprintf("%03x", samoct("0b0110001011")); #this is an invalid special code group 
    } elsif ($octet_hex == 0x1f) {
      $encode = sprintf("%03x", samoct("0b0101111011")); #this is an invalid special code group with
                                                    #the positive disparity completely incorrect 
    } elsif ($octet_hex == 0x0a) {
      $encode = sprintf("%03x", samoct("0b0000000000")); #this is an invalid special code group 
                                                    #the positive disparity completely incorrect 
    } elsif ($octet_hex == 0xff) {
      $encode = sprintf("%03x", samoct("0b1111111111")); #this is an invalid special code group    
    } elsif ($octet_hex == 0x1a) {
      $encode = sprintf("%03x", samoct("0b1100000100")); #this is an invalid special code group  #304 
    } elsif ($octet_hex == 0x2a) {
      $encode = sprintf("%03x", samoct("0b1100000001")); #this is an invalid special code group  #301  
    } elsif ($octet_hex == 0x3a) {
      $encode = sprintf("%03x", samoct("0b1000000101")); #this is an invalid special code group  #205  
    } elsif ($octet_hex == 0x4a) {
      $encode = sprintf("%03x", samoct("0b0100000101")); #this is an invalid special code group  #105
    } elsif ($octet_hex == 0x5a) {
      $encode = sprintf("%03x", samoct("0b0011111011")); #this is an invalid special code group  #0FB 
    } elsif ($octet_hex == 0x6a) {
      $encode = sprintf("%03x", samoct("0b0011111110")); #this is an invalid special code group  #0FE  
    } elsif ($octet_hex == 0x7a) {
      $encode = sprintf("%03x", samoct("0b0111111010")); #this is an invalid special code group  #1FA  
    } elsif ($octet_hex == 0x8a) {
      $encode = sprintf("%03x", samoct("0b1011111010")); #this is an invalid special code group  #2FA 
    } elsif ($octet_hex == 0xaa) {
      $encode = sprintf("%03x", samoct("0b0000110011")); #this is an invalid special code group  #033  
    } elsif ($octet_hex == 0xba) {
      $encode = sprintf("%03x", samoct("0b1111000011")); #this is an invalid special code group  #3C3 
    } else {die print "\nError: Illegal special octet value: $octet_hex.\n\n";}
    
  } else {          # negative input disparity
  
    if ($octet_hex == 0x1c ) {
      $encode = sprintf("%03x", samoct("0b0011110100"));  # 0f4
    } elsif ($octet_hex == 0x3c) {
      $encode = sprintf("%03x", samoct("0b0011111001"));  # 0f9
    } elsif ($octet_hex == 0x5c) {
      $encode = sprintf("%03x", samoct("0b0011110101"));  # 0f5
    } elsif ($octet_hex == 0x7c) {
      $encode = sprintf("%03x", samoct("0b0011110011"));  # 0f3
    } elsif ($octet_hex == 0x9c) {
      $encode = sprintf("%03x", samoct("0b0011110010"));  # 0f2
    } elsif ($octet_hex == 0xbc) {
      $encode = sprintf("%03x", samoct("0b0011111010"));  # 0fa
    } elsif ($octet_hex == 0xdc) {
      $encode = sprintf("%03x", samoct("0b0011110110"));  # 0f6
    } elsif ($octet_hex == 0xfc) {
      $encode = sprintf("%03x", samoct("0b0011111000"));  # 0f8
    } elsif ($octet_hex == 0xf7) {
      $encode = sprintf("%03x", samoct("0b1110101000"));  # 3a8
    } elsif ($octet_hex == 0xfb) {
      $encode = sprintf("%03x", samoct("0b1101101000"));  # 368
    } elsif ($octet_hex == 0xfd) {
      $encode = sprintf("%03x", samoct("0b1011101000"));  # 2e8
    } elsif ($octet_hex == 0xfe) {
      $encode = sprintf("%03x", samoct("0b0111101000"));  # 1e8
    } elsif ($octet_hex == 0x00) {
      $encode = sprintf("%03x", samoct("0b1001110100")); #this is an invalid special code group 
    } elsif ($octet_hex == 0x1f) {
      $encode = sprintf("%03x", samoct("0b1010111111")); #this is an invalid special code group with
                                                    #the negative disparity completely incorrect 
    } elsif ($octet_hex == 0x0a) {
      $encode = sprintf("%03x", samoct("0b0000000000")); #this is an invalid special code group 
                                                    #the negative disparity completely incorrect 
    } elsif ($octet_hex == 0xff) {
      $encode = sprintf("%03x", samoct("0b1111111111")); #this is an invalid special code group 
                                                    #the negative disparity completely incorrect 
    } elsif ($octet_hex == 0x1a) {
      $encode = sprintf("%03x", samoct("0b1100000100")); #this is an invalid special code group  #304 
    } elsif ($octet_hex == 0x2a) {
      $encode = sprintf("%03x", samoct("0b1100000001")); #this is an invalid special code group  #301  
    } elsif ($octet_hex == 0x3a) {
      $encode = sprintf("%03x", samoct("0b1000000101")); #this is an invalid special code group  #205  
    } elsif ($octet_hex == 0x4a) {
      $encode = sprintf("%03x", samoct("0b0100000101")); #this is an invalid special code group  #105    
    } elsif ($octet_hex == 0x5a) {
      $encode = sprintf("%03x", samoct("0b0011111011")); #this is an invalid special code group  #0FB 
    } elsif ($octet_hex == 0x6a) {
      $encode = sprintf("%03x", samoct("0b0011111110")); #this is an invalid special code group  #0FE  
    } elsif ($octet_hex == 0x7a) {
      $encode = sprintf("%03x", samoct("0b0111111010")); #this is an invalid special code group  #1FA  
    } elsif ($octet_hex == 0x8a) {
      $encode = sprintf("%03x", samoct("0b1011111010")); #this is an invalid special code group  #2FA
    } elsif ($octet_hex == 0xaa) {
      $encode = sprintf("%03x", samoct("0b0000110011")); #this is an invalid special code group  #033  
    } elsif ($octet_hex == 0xba) {
      $encode = sprintf("%03x", samoct("0b1111000011")); #this is an invalid special code group  #3C3     
    } else {die print "\nError: Illegal special octet value: $octet_hex.\n\n";}
    
  }
  return ($encode)
}


sub encoder {
  my ($crc_code,$in_disp) = @_;
  my $encode = "";

  if ($in_disp) { #positive disparity
    if ($crc_code == 0x0) {
      $encode = 0x18b ;
    }elsif ($crc_code == 0x1) {
      $encode = 0x22b ;
    }elsif ($crc_code == 0x2) {
      $encode = 0x12b ;
    }elsif ($crc_code == 0x3) {
      $encode = 0x314 ;
    }elsif ($crc_code == 0x4) {
      $encode = 0xab ;
    }elsif ($crc_code == 0x5) {
      $encode = 0x294 ;
    }elsif ($crc_code == 0x6) {
      $encode = 0x194 ;
    }elsif ($crc_code == 0x7) {
      $encode = 0x74 ;
    }elsif ($crc_code == 0x8) {
      $encode = 0x6b ;
    }elsif ($crc_code == 0x9) {
      $encode = 0x254 ;
    }elsif ($crc_code == 0xa) {
      $encode = 0x154 ;
    }elsif ($crc_code == 0xb) {
      $encode = 0x344 ;
    }elsif ($crc_code == 0xc) {
      $encode = 0xd4 ;
    }elsif ($crc_code == 0xd) {
      $encode = 0x2c4 ;
    }elsif ($crc_code == 0xe) {
      $encode = 0x1c4 ;
    }elsif ($crc_code == 0xf) {
      $encode = 0x28b ;
    }elsif ($crc_code == 0x10) {
      $encode = 0x24b ;
    }elsif ($crc_code == 0x11) {
      $encode = 0x234 ;
    }elsif ($crc_code == 0x12) {
      $encode = 0x134 ;
    }elsif ($crc_code == 0x13) {
      $encode = 0x324 ;
    }elsif ($crc_code == 0x14) {
      $encode = 0xb4 ;
    }elsif ($crc_code == 0x15) {
      $encode = 0x2a4 ;
    }elsif ($crc_code == 0x16) {
      $encode = 0x1a4 ;
    }elsif ($crc_code == 0x17) {
      $encode = 0x5b ;
    }elsif ($crc_code == 0x18) {
      $encode = 0xcb ;
    }elsif ($crc_code == 0x19) {
      $encode = 0x264 ;
    }elsif ($crc_code == 0x1a) {
      $encode = 0x164 ;
    }elsif ($crc_code == 0x1b) {
      $encode = 0x9b ;
    }elsif ($crc_code == 0x1c) {
      $encode = 0xe4 ;
    }elsif ($crc_code == 0x1d) {
      $encode = 0x11b ;
    }elsif ($crc_code == 0x1e) {
      $encode = 0x21b ;
    }elsif ($crc_code == 0x1f) {
      $encode = 0x14b ;
    }elsif ($crc_code == 0x20) {
      $encode = 0x189 ;
    }elsif ($crc_code == 0x21) {
      $encode = 0x229 ;
    }elsif ($crc_code == 0x22) {
      $encode = 0x129 ;
    }elsif ($crc_code == 0x23) {
      $encode = 0x319 ;
    }elsif ($crc_code == 0x24) {
      $encode = 0xa9 ;
    }elsif ($crc_code == 0x25) {
      $encode = 0x299 ;
    }elsif ($crc_code == 0x26) {
      $encode = 0x199 ;
    }elsif ($crc_code == 0x27) {
      $encode = 0x79 ;
    }elsif ($crc_code == 0x28) {
      $encode = 0x69 ;
    }elsif ($crc_code == 0x29) {
      $encode = 0x259 ;
    }elsif ($crc_code == 0x2a) {
      $encode = 0x159 ;
    }elsif ($crc_code == 0x2b) {
      $encode = 0x349 ;
    }elsif ($crc_code == 0x2c) {
      $encode = 0xd9 ;
    }elsif ($crc_code == 0x2d) {
      $encode = 0x2c9 ;
    }elsif ($crc_code == 0x2e) {
      $encode = 0x1c9 ;
    }elsif ($crc_code == 0x2f) {
      $encode = 0x289 ;
    }elsif ($crc_code == 0x30) {
      $encode = 0x249 ;
    }elsif ($crc_code == 0x31) {
      $encode = 0x239 ;
    }elsif ($crc_code == 0x32) {
      $encode = 0x139 ;
    }elsif ($crc_code == 0x33) {
      $encode = 0x329 ;
    }elsif ($crc_code == 0x34) {
      $encode = 0xb9 ;
    }elsif ($crc_code == 0x35) {
      $encode = 0x2a9 ;
    }elsif ($crc_code == 0x36) {
      $encode = 0x1a9 ;
    }elsif ($crc_code == 0x37) {
      $encode = 0x59 ;
    }elsif ($crc_code == 0x38) {
      $encode = 0xc9 ;
    }elsif ($crc_code == 0x39) {
      $encode = 0x269 ;
    }elsif ($crc_code == 0x3a) {
      $encode = 0x169 ;
    }elsif ($crc_code == 0x3b) {
      $encode = 0x99 ;
    }elsif ($crc_code == 0x3c) {
      $encode = 0xe9 ;
    }elsif ($crc_code == 0x3d) {
      $encode = 0x119 ;
    }elsif ($crc_code == 0x3e) {
      $encode = 0x219 ;
    }elsif ($crc_code == 0x3f) {
      $encode = 0x149 ;
    }elsif ($crc_code == 0x40) {
      $encode = 0x185 ;
    }elsif ($crc_code == 0x41) {
      $encode = 0x225 ;
    }elsif ($crc_code == 0x42) {
      $encode = 0x125 ;
    }elsif ($crc_code == 0x43) {
      $encode = 0x315 ;
    }elsif ($crc_code == 0x44) {
      $encode = 0xa5 ;
    }elsif ($crc_code == 0x45) {
      $encode = 0x295 ;
    }elsif ($crc_code == 0x46) {
      $encode = 0x195 ;
    }elsif ($crc_code == 0x47) {
      $encode = 0x75 ;
    }elsif ($crc_code == 0x48) {
      $encode = 0x65 ;
    }elsif ($crc_code == 0x49) {
      $encode = 0x255 ;
    }elsif ($crc_code == 0x4a) {
      $encode = 0x155 ;
    }elsif ($crc_code == 0x4b) {
      $encode = 0x345 ;
    }elsif ($crc_code == 0x4c) {
      $encode = 0xd5 ;
    }elsif ($crc_code == 0x4d) {
      $encode = 0x2c5 ;
    }elsif ($crc_code == 0x4e) {
      $encode = 0x1c5 ;
    }elsif ($crc_code == 0x4f) {
      $encode = 0x285 ;
    }elsif ($crc_code == 0x50) {
      $encode = 0x245 ;
    }elsif ($crc_code == 0x51) {
      $encode = 0x235 ;
    }elsif ($crc_code == 0x52) {
      $encode = 0x135 ;
    }elsif ($crc_code == 0x53) {
      $encode = 0x325 ;
    }elsif ($crc_code == 0x54) {
      $encode = 0xb5 ;
    }elsif ($crc_code == 0x55) {
      $encode = 0x2a5 ;
    }elsif ($crc_code == 0x56) {
      $encode = 0x1a5 ;
    }elsif ($crc_code == 0x57) {
      $encode = 0x55 ;
    }elsif ($crc_code == 0x58) {
      $encode = 0xc5 ;
    }elsif ($crc_code == 0x59) {
      $encode = 0x265 ;
    }elsif ($crc_code == 0x5a) {
      $encode = 0x165 ;
    }elsif ($crc_code == 0x5b) {
      $encode = 0x95 ;
    }elsif ($crc_code == 0x5c) {
      $encode = 0xe5 ;
    }elsif ($crc_code == 0x5d) {
      $encode = 0x115 ;
    }elsif ($crc_code == 0x5e) {
      $encode = 0x215 ;
    }elsif ($crc_code == 0x5f) {
      $encode = 0x145 ;
    }elsif ($crc_code == 0x60) {
      $encode = 0x18c ;
    }elsif ($crc_code == 0x61) {
      $encode = 0x22c ;
    }elsif ($crc_code == 0x62) {
      $encode = 0x12c ;
    }elsif ($crc_code == 0x63) {
      $encode = 0x313 ;
    }elsif ($crc_code == 0x64) {
      $encode = 0xac ;
    }elsif ($crc_code == 0x65) {
      $encode = 0x293 ;
    }elsif ($crc_code == 0x66) {
      $encode = 0x193 ;
    }elsif ($crc_code == 0x67) {
      $encode = 0x73 ;
    }elsif ($crc_code == 0x68) {
      $encode = 0x6c ;
    }elsif ($crc_code == 0x69) {
      $encode = 0x253 ;
    }elsif ($crc_code == 0x6a) {
      $encode = 0x153 ;
    }elsif ($crc_code == 0x6b) {
      $encode = 0x343 ;
    }elsif ($crc_code == 0x6c) {
      $encode = 0xd3 ;
    }elsif ($crc_code == 0x6d) {
      $encode = 0x2c3 ;
    }elsif ($crc_code == 0x6e) {
      $encode = 0x1c3 ;
    }elsif ($crc_code == 0x6f) {
      $encode = 0x28c ;
    }elsif ($crc_code == 0x70) {
      $encode = 0x24c ;
    }elsif ($crc_code == 0x71) {
      $encode = 0x233 ;
    }elsif ($crc_code == 0x72) {
      $encode = 0x133 ;
    }elsif ($crc_code == 0x73) {
      $encode = 0x323 ;
    }elsif ($crc_code == 0x74) {
      $encode = 0xb3 ;
    }elsif ($crc_code == 0x75) {
      $encode = 0x2a3 ;
    }elsif ($crc_code == 0x76) {
      $encode = 0x1a3 ;
    }elsif ($crc_code == 0x77) {
      $encode = 0x5c ;
    }elsif ($crc_code == 0x78) {
      $encode = 0xcc ;
    }elsif ($crc_code == 0x79) {
      $encode = 0x263 ;
    }elsif ($crc_code == 0x7a) {
      $encode = 0x163 ;
    }elsif ($crc_code == 0x7b) {
      $encode = 0x9c ;
    }elsif ($crc_code == 0x7c) {
      $encode = 0xe3 ;
    }elsif ($crc_code == 0x7d) {
      $encode = 0x11c ;
    }elsif ($crc_code == 0x7e) {
      $encode = 0x21c ;
    }elsif ($crc_code == 0x7f) {
      $encode = 0x14c ;
    }elsif ($crc_code == 0x80) {
      $encode = 0x18d ;
    }elsif ($crc_code == 0x81) {
      $encode = 0x22d ;
    }elsif ($crc_code == 0x82) {
      $encode = 0x12d ;
    }elsif ($crc_code == 0x83) {
      $encode = 0x312 ;
    }elsif ($crc_code == 0x84) {
      $encode = 0xad ;
    }elsif ($crc_code == 0x85) {
      $encode = 0x292 ;
    }elsif ($crc_code == 0x86) {
      $encode = 0x192 ;
    }elsif ($crc_code == 0x87) {
      $encode = 0x72 ;
    }elsif ($crc_code == 0x88) {
      $encode = 0x6d ;
    }elsif ($crc_code == 0x89) {
      $encode = 0x252 ;
    }elsif ($crc_code == 0x8a) {
      $encode = 0x152 ;
    }elsif ($crc_code == 0x8b) {
      $encode = 0x342 ;
    }elsif ($crc_code == 0x8c) {
      $encode = 0xd2 ;
    }elsif ($crc_code == 0x8d) {
      $encode = 0x2c2 ;
    }elsif ($crc_code == 0x8e) {
      $encode = 0x1c2 ;
    }elsif ($crc_code == 0x8f) {
      $encode = 0x28d ;
    }elsif ($crc_code == 0x90) {
      $encode = 0x24d ;
    }elsif ($crc_code == 0x91) {
      $encode = 0x232 ;
    }elsif ($crc_code == 0x92) {
      $encode = 0x132 ;
    }elsif ($crc_code == 0x93) {
      $encode = 0x322 ;
    }elsif ($crc_code == 0x94) {
      $encode = 0xb2 ;
    }elsif ($crc_code == 0x95) {
      $encode = 0x2a2 ;
    }elsif ($crc_code == 0x96) {
      $encode = 0x1a2 ;
    }elsif ($crc_code == 0x97) {
      $encode = 0x5d ;
    }elsif ($crc_code == 0x98) {
      $encode = 0xcd ;
    }elsif ($crc_code == 0x99) {
      $encode = 0x262 ;
    }elsif ($crc_code == 0x9a) {
      $encode = 0x162 ;
    }elsif ($crc_code == 0x9b) {
      $encode = 0x9d ;
    }elsif ($crc_code == 0x9c) {
      $encode = 0xe2 ;
    }elsif ($crc_code == 0x9d) {
      $encode = 0x11d ;
    }elsif ($crc_code == 0x9e) {
      $encode = 0x21d ;
    }elsif ($crc_code == 0x9f) {
      $encode = 0x14d ;
    }elsif ($crc_code == 0xa0) {
      $encode = 0x18a ;
    }elsif ($crc_code == 0xa1) {
      $encode = 0x22a ;
    }elsif ($crc_code == 0xa2) {
      $encode = 0x12a ;
    }elsif ($crc_code == 0xa3) {
      $encode = 0x31a ;
    }elsif ($crc_code == 0xa4) {
      $encode = 0xaa ;
    }elsif ($crc_code == 0xa5) {
      $encode = 0x29a ;
    }elsif ($crc_code == 0xa6) {
      $encode = 0x19a ;
    }elsif ($crc_code == 0xa7) {
      $encode = 0x7a ;
    }elsif ($crc_code == 0xa8) {
      $encode = 0x6a ;
    }elsif ($crc_code == 0xa9) {
      $encode = 0x25a ;
    }elsif ($crc_code == 0xaa) {
      $encode = 0x15a ;
    }elsif ($crc_code == 0xab) {
      $encode = 0x34a ;
    }elsif ($crc_code == 0xac) {
      $encode = 0xda ;
    }elsif ($crc_code == 0xad) {
      $encode = 0x2ca ;
    }elsif ($crc_code == 0xae) {
      $encode = 0x1ca ;
    }elsif ($crc_code == 0xaf) {
      $encode = 0x28a ;
    }elsif ($crc_code == 0xb0) {
      $encode = 0x24a ;
    }elsif ($crc_code == 0xb1) {
      $encode = 0x23a ;
    }elsif ($crc_code == 0xb2) {
      $encode = 0x13a ;
    }elsif ($crc_code == 0xb3) {
      $encode = 0x32a ;
    }elsif ($crc_code == 0xb4) {
      $encode = 0xba ;
    }elsif ($crc_code == 0xb5) {
      $encode = 0x2aa ;
    }elsif ($crc_code == 0xb6) {
      $encode = 0x1aa ;
    }elsif ($crc_code == 0xb7) {
      $encode = 0x5a ;
    }elsif ($crc_code == 0xb8) {
      $encode = 0xca ;
    }elsif ($crc_code == 0xb9) {
      $encode = 0x26a ;
    }elsif ($crc_code == 0xba) {
      $encode = 0x16a ;
    }elsif ($crc_code == 0xbb) {
      $encode = 0x9a ;
    }elsif ($crc_code == 0xbc) {
      $encode = 0xea ;
    }elsif ($crc_code == 0xbd) {
      $encode = 0x11a ;
    }elsif ($crc_code == 0xbe) {
      $encode = 0x21a ;
    }elsif ($crc_code == 0xbf) {
      $encode = 0x14a ;
    }elsif ($crc_code == 0xc0) {
      $encode = 0x186 ;
    }elsif ($crc_code == 0xc1) {
      $encode = 0x226 ;
    }elsif ($crc_code == 0xc2) {
      $encode = 0x126 ;
    }elsif ($crc_code == 0xc3) {
      $encode = 0x316 ;
    }elsif ($crc_code == 0xc4) {
      $encode = 0xa6 ;
    }elsif ($crc_code == 0xc5) {
      $encode = 0x296 ;
    }elsif ($crc_code == 0xc6) {
      $encode = 0x196 ;
    }elsif ($crc_code == 0xc7) {
      $encode = 0x76 ;
    }elsif ($crc_code == 0xc8) {
      $encode = 0x66 ;
    }elsif ($crc_code == 0xc9) {
      $encode = 0x256 ;
    }elsif ($crc_code == 0xca) {
      $encode = 0x156 ;
    }elsif ($crc_code == 0xcb) {
      $encode = 0x346 ;
    }elsif ($crc_code == 0xcc) {
      $encode = 0xd6 ;
    }elsif ($crc_code == 0xcd) {
      $encode = 0x2c6 ;
    }elsif ($crc_code == 0xce) {
      $encode = 0x1c6 ;
    }elsif ($crc_code == 0xcf) {
      $encode = 0x286 ;
    }elsif ($crc_code == 0xd0) {
      $encode = 0x246 ;
    }elsif ($crc_code == 0xd1) {
      $encode = 0x236 ;
    }elsif ($crc_code == 0xd2) {
      $encode = 0x136 ;
    }elsif ($crc_code == 0xd3) {
      $encode = 0x326 ;
    }elsif ($crc_code == 0xd4) {
      $encode = 0xb6 ;
    }elsif ($crc_code == 0xd5) {
      $encode = 0x2a6 ;
    }elsif ($crc_code == 0xd6) {
      $encode = 0x1a6 ;
    }elsif ($crc_code == 0xd7) {
      $encode = 0x56 ;
    }elsif ($crc_code == 0xd8) {
      $encode = 0xc6 ;
    }elsif ($crc_code == 0xd9) {
      $encode = 0x266 ;
    }elsif ($crc_code == 0xda) {
      $encode = 0x166 ;
    }elsif ($crc_code == 0xdb) {
      $encode = 0x96 ;
    }elsif ($crc_code == 0xdc) {
      $encode = 0xe6 ;
    }elsif ($crc_code == 0xdd) {
      $encode = 0x116 ;
    }elsif ($crc_code == 0xde) {
      $encode = 0x216 ;
    }elsif ($crc_code == 0xdf) {
      $encode = 0x146 ;
    }elsif ($crc_code == 0xe0) {
      $encode = 0x18e ;
    }elsif ($crc_code == 0xe1) {
      $encode = 0x22e ;
    }elsif ($crc_code == 0xe2) {
      $encode = 0x12e ;
    }elsif ($crc_code == 0xe3) {
      $encode = 0x311 ;
    }elsif ($crc_code == 0xe4) {
      $encode = 0xae ;
    }elsif ($crc_code == 0xe5) {
      $encode = 0x291 ;
    }elsif ($crc_code == 0xe6) {
      $encode = 0x191 ;
    }elsif ($crc_code == 0xe7) {
      $encode = 0x71 ;
    }elsif ($crc_code == 0xe8) {
      $encode = 0x6e ;
    }elsif ($crc_code == 0xe9) {
      $encode = 0x251 ;
    }elsif ($crc_code == 0xea) {
      $encode = 0x151 ;
    }elsif ($crc_code == 0xeb) {
      $encode = 0x348 ;
    }elsif ($crc_code == 0xec) {
      $encode = 0xd1 ;
    }elsif ($crc_code == 0xed) {
      $encode = 0x2c8 ;
    }elsif ($crc_code == 0xee) {
      $encode = 0x1c8 ;
    }elsif ($crc_code == 0xef) {
      $encode = 0x28e ;
    }elsif ($crc_code == 0xf0) {
      $encode = 0x24e ;
    }elsif ($crc_code == 0xf1) {
      $encode = 0x231 ;
    }elsif ($crc_code == 0xf2) {
      $encode = 0x131 ;
    }elsif ($crc_code == 0xf3) {
      $encode = 0x321 ;
    }elsif ($crc_code == 0xf4) {
      $encode = 0xb1 ;
    }elsif ($crc_code == 0xf5) {
      $encode = 0x2a1 ;
    }elsif ($crc_code == 0xf6) {
      $encode = 0x1a1 ;
    }elsif ($crc_code == 0xf7) {
      $encode = 0x5e ;
    }elsif ($crc_code == 0xf8) {
      $encode = 0xce ;
    }elsif ($crc_code == 0xf9) {
      $encode = 0x261 ;
    }elsif ($crc_code == 0xfa) {
      $encode = 0x161 ;
    }elsif ($crc_code == 0xfb) {
      $encode = 0x9e ;
    }elsif ($crc_code == 0xfc) {
      $encode = 0xe1 ;
    }elsif ($crc_code == 0xfd) {
      $encode = 0x11e ;
    }elsif ($crc_code == 0xfe) {
      $encode = 0x21e ;
    }elsif ($crc_code == 0xff) {
      $encode = 0x14e ;
    }
  }else { # negative disparity
    if ($crc_code == 0x0) {
      $encode = 0x274 ;
    }elsif ($crc_code == 0x1) {
      $encode = 0x1d4 ;
    }elsif ($crc_code == 0x2) {
      $encode = 0x2d4 ;
    }elsif ($crc_code == 0x3) {
      $encode = 0x31b ;
    }elsif ($crc_code == 0x4) {
      $encode = 0x354 ;
    }elsif ($crc_code == 0x5) {
      $encode = 0x29b ;
    }elsif ($crc_code == 0x6) {
      $encode = 0x19b ;
    }elsif ($crc_code == 0x7) {
      $encode = 0x38b ;
    }elsif ($crc_code == 0x8) {
      $encode = 0x394 ;
    }elsif ($crc_code == 0x9) {
      $encode = 0x25b ;
    }elsif ($crc_code == 0xa) {
      $encode = 0x15b ;
    }elsif ($crc_code == 0xb) {
      $encode = 0x34b ;
    }elsif ($crc_code == 0xc) {
      $encode = 0xdb ;
    }elsif ($crc_code == 0xd) {
      $encode = 0x2cb ;
    }elsif ($crc_code == 0xe) {
      $encode = 0x1cb ;
    }elsif ($crc_code == 0xf) {
      $encode = 0x174 ;
    }elsif ($crc_code == 0x10) {
      $encode = 0x1b4 ;
    }elsif ($crc_code == 0x11) {
      $encode = 0x23b ;
    }elsif ($crc_code == 0x12) {
      $encode = 0x13b ;
    }elsif ($crc_code == 0x13) {
      $encode = 0x32b ;
    }elsif ($crc_code == 0x14) {
      $encode = 0xbb ;
    }elsif ($crc_code == 0x15) {
      $encode = 0x2ab ;
    }elsif ($crc_code == 0x16) {
      $encode = 0x1ab ;
    }elsif ($crc_code == 0x17) {
      $encode = 0x3a4 ;
    }elsif ($crc_code == 0x18) {
      $encode = 0x334 ;
    }elsif ($crc_code == 0x19) {
      $encode = 0x26b ;
    }elsif ($crc_code == 0x1a) {
      $encode = 0x16b ;
    }elsif ($crc_code == 0x1b) {
      $encode = 0x364 ;
    }elsif ($crc_code == 0x1c) {
      $encode = 0xeb ;
    }elsif ($crc_code == 0x1d) {
      $encode = 0x2e4 ;
    }elsif ($crc_code == 0x1e) {
      $encode = 0x1e4 ;
    }elsif ($crc_code == 0x1f) {
      $encode = 0x2b4 ;
    }elsif ($crc_code == 0x20) {
      $encode = 0x279 ;
    }elsif ($crc_code == 0x21) {
      $encode = 0x1d9 ;
    }elsif ($crc_code == 0x22) {
      $encode = 0x2d9 ;
    }elsif ($crc_code == 0x23) {
      $encode = 0x319 ;
    }elsif ($crc_code == 0x24) {
      $encode = 0x359 ;
    }elsif ($crc_code == 0x25) {
      $encode = 0x299 ;
    }elsif ($crc_code == 0x26) {
      $encode = 0x199 ;
    }elsif ($crc_code == 0x27) {
      $encode = 0x389 ;
    }elsif ($crc_code == 0x28) {
      $encode = 0x399 ;
    }elsif ($crc_code == 0x29) {
      $encode = 0x259 ;
    }elsif ($crc_code == 0x2a) {
      $encode = 0x159 ;
    }elsif ($crc_code == 0x2b) {
      $encode = 0x349 ;
    }elsif ($crc_code == 0x2c) {
      $encode = 0xd9 ;
    }elsif ($crc_code == 0x2d) {
      $encode = 0x2c9 ;
    }elsif ($crc_code == 0x2e) {
      $encode = 0x1c9 ;
    }elsif ($crc_code == 0x2f) {
      $encode = 0x179 ;
    }elsif ($crc_code == 0x30) {
      $encode = 0x1b9 ;
    }elsif ($crc_code == 0x31) {
      $encode = 0x239 ;
    }elsif ($crc_code == 0x32) {
      $encode = 0x139 ;
    }elsif ($crc_code == 0x33) {
      $encode = 0x329 ;
    }elsif ($crc_code == 0x34) {
      $encode = 0xb9 ;
    }elsif ($crc_code == 0x35) {
      $encode = 0x2a9 ;
    }elsif ($crc_code == 0x36) {
      $encode = 0x1a9 ;
    }elsif ($crc_code == 0x37) {
      $encode = 0x3a9 ;
    }elsif ($crc_code == 0x38) {
      $encode = 0x339 ;
    }elsif ($crc_code == 0x39) {
      $encode = 0x269 ;
    }elsif ($crc_code == 0x3a) {
      $encode = 0x169 ;
    }elsif ($crc_code == 0x3b) {
      $encode = 0x369 ;
    }elsif ($crc_code == 0x3c) {
      $encode = 0xe9 ;
    }elsif ($crc_code == 0x3d) {
      $encode = 0x2e9 ;
    }elsif ($crc_code == 0x3e) {
      $encode = 0x1e9 ;
    }elsif ($crc_code == 0x3f) {
      $encode = 0x2b9 ;
    }elsif ($crc_code == 0x40) {
      $encode = 0x275 ;
    }elsif ($crc_code == 0x41) {
      $encode = 0x1d5 ;
    }elsif ($crc_code == 0x42) {
      $encode = 0x2d5 ;
    }elsif ($crc_code == 0x43) {
      $encode = 0x315 ;
    }elsif ($crc_code == 0x44) {
      $encode = 0x355 ;
    }elsif ($crc_code == 0x45) {
      $encode = 0x295 ;
    }elsif ($crc_code == 0x46) {
      $encode = 0x195 ;
    }elsif ($crc_code == 0x47) {
      $encode = 0x385 ;
    }elsif ($crc_code == 0x48) {
      $encode = 0x395 ;
    }elsif ($crc_code == 0x49) {
      $encode = 0x255 ;
    }elsif ($crc_code == 0x4a) {
      $encode = 0x155 ;
    }elsif ($crc_code == 0x4b) {
      $encode = 0x345 ;
    }elsif ($crc_code == 0x4c) {
      $encode = 0xd5 ;
    }elsif ($crc_code == 0x4d) {
      $encode = 0x2c5 ;
    }elsif ($crc_code == 0x4e) {
      $encode = 0x1c5 ;
    }elsif ($crc_code == 0x4f) {
      $encode = 0x175 ;
    }elsif ($crc_code == 0x50) {
      $encode = 0x1b5 ;
    }elsif ($crc_code == 0x51) {
      $encode = 0x235 ;
    }elsif ($crc_code == 0x52) {
      $encode = 0x135 ;
    }elsif ($crc_code == 0x53) {
      $encode = 0x325 ;
    }elsif ($crc_code == 0x54) {
      $encode = 0xb5 ;
    }elsif ($crc_code == 0x55) {
      $encode = 0x2a5 ;
    }elsif ($crc_code == 0x56) {
      $encode = 0x1a5 ;
    }elsif ($crc_code == 0x57) {
      $encode = 0x3a5 ;
    }elsif ($crc_code == 0x58) {
      $encode = 0x335 ;
    }elsif ($crc_code == 0x59) {
      $encode = 0x265 ;
    }elsif ($crc_code == 0x5a) {
      $encode = 0x165 ;
    }elsif ($crc_code == 0x5b) {
      $encode = 0x365 ;
    }elsif ($crc_code == 0x5c) {
      $encode = 0xe5 ;
    }elsif ($crc_code == 0x5d) {
      $encode = 0x2e5 ;
    }elsif ($crc_code == 0x5e) {
      $encode = 0x1e5 ;
    }elsif ($crc_code == 0x5f) {
      $encode = 0x2b5 ;
    }elsif ($crc_code == 0x60) {
      $encode = 0x273 ;
    }elsif ($crc_code == 0x61) {
      $encode = 0x1d3 ;
    }elsif ($crc_code == 0x62) {
      $encode = 0x2d3 ;
    }elsif ($crc_code == 0x63) {
      $encode = 0x31c ;
    }elsif ($crc_code == 0x64) {
      $encode = 0x353 ;
    }elsif ($crc_code == 0x65) {
      $encode = 0x29c ;
    }elsif ($crc_code == 0x66) {
      $encode = 0x19c ;
    }elsif ($crc_code == 0x67) {
      $encode = 0x38c ;
    }elsif ($crc_code == 0x68) {
      $encode = 0x393 ;
    }elsif ($crc_code == 0x69) {
      $encode = 0x25c ;
    }elsif ($crc_code == 0x6a) {
      $encode = 0x15c ;
    }elsif ($crc_code == 0x6b) {
      $encode = 0x34c ;
    }elsif ($crc_code == 0x6c) {
      $encode = 0xdc ;
    }elsif ($crc_code == 0x6d) {
      $encode = 0x2cc ;
    }elsif ($crc_code == 0x6e) {
      $encode = 0x1cc ;
    }elsif ($crc_code == 0x6f) {
      $encode = 0x173 ;
    }elsif ($crc_code == 0x70) {
      $encode = 0x1b3 ;
    }elsif ($crc_code == 0x71) {
      $encode = 0x23c ;
    }elsif ($crc_code == 0x72) {
      $encode = 0x13c ;
    }elsif ($crc_code == 0x73) {
      $encode = 0x32c ;
    }elsif ($crc_code == 0x74) {
      $encode = 0xbc ;
    }elsif ($crc_code == 0x75) {
      $encode = 0x2ac ;
    }elsif ($crc_code == 0x76) {
      $encode = 0x1ac ;
    }elsif ($crc_code == 0x77) {
      $encode = 0x3a3 ;
    }elsif ($crc_code == 0x78) {
      $encode = 0x333 ;
    }elsif ($crc_code == 0x79) {
      $encode = 0x26c ;
    }elsif ($crc_code == 0x7a) {
      $encode = 0x16c ;
    }elsif ($crc_code == 0x7b) {
      $encode = 0x363 ;
    }elsif ($crc_code == 0x7c) {
      $encode = 0xec ;
    }elsif ($crc_code == 0x7d) {
      $encode = 0x2e3 ;
    }elsif ($crc_code == 0x7e) {
      $encode = 0x1e3 ;
    }elsif ($crc_code == 0x7f) {
      $encode = 0x2b3 ;
    }elsif ($crc_code == 0x80) {
      $encode = 0x272 ;
    }elsif ($crc_code == 0x81) {
      $encode = 0x1d2 ;
    }elsif ($crc_code == 0x82) {
      $encode = 0x2d2 ;
    }elsif ($crc_code == 0x83) {
      $encode = 0x31d ;
    }elsif ($crc_code == 0x84) {
      $encode = 0x352 ;
    }elsif ($crc_code == 0x85) {
      $encode = 0x29d ;
    }elsif ($crc_code == 0x86) {
      $encode = 0x19d ;
    }elsif ($crc_code == 0x87) {
      $encode = 0x38d ;
    }elsif ($crc_code == 0x88) {
      $encode = 0x392 ;
    }elsif ($crc_code == 0x89) {
      $encode = 0x25d ;
    }elsif ($crc_code == 0x8a) {
      $encode = 0x15d ;
    }elsif ($crc_code == 0x8b) {
      $encode = 0x34d ;
    }elsif ($crc_code == 0x8c) {
      $encode = 0xdd ;
    }elsif ($crc_code == 0x8d) {
      $encode = 0x2cd ;
    }elsif ($crc_code == 0x8e) {
      $encode = 0x1cd ;
    }elsif ($crc_code == 0x8f) {
      $encode = 0x172 ;
    }elsif ($crc_code == 0x90) {
      $encode = 0x1b2 ;
    }elsif ($crc_code == 0x91) {
      $encode = 0x23d ;
    }elsif ($crc_code == 0x92) {
      $encode = 0x13d ;
    }elsif ($crc_code == 0x93) {
      $encode = 0x32d ;
    }elsif ($crc_code == 0x94) {
      $encode = 0xbd ;
    }elsif ($crc_code == 0x95) {
      $encode = 0x2ad ;
    }elsif ($crc_code == 0x96) {
      $encode = 0x1ad ;
    }elsif ($crc_code == 0x97) {
      $encode = 0x3a2 ;
    }elsif ($crc_code == 0x98) {
      $encode = 0x332 ;
    }elsif ($crc_code == 0x99) {
      $encode = 0x26d ;
    }elsif ($crc_code == 0x9a) {
      $encode = 0x16d ;
    }elsif ($crc_code == 0x9b) {
      $encode = 0x362 ;
    }elsif ($crc_code == 0x9c) {
      $encode = 0xed ;
    }elsif ($crc_code == 0x9d) {
      $encode = 0x2e2 ;
    }elsif ($crc_code == 0x9e) {
      $encode = 0x1e2 ;
    }elsif ($crc_code == 0x9f) {
      $encode = 0x2b2 ;
    }elsif ($crc_code == 0xa0) {
      $encode = 0x27a ;
    }elsif ($crc_code == 0xa1) {
      $encode = 0x1da ;
    }elsif ($crc_code == 0xa2) {
      $encode = 0x2da ;
    }elsif ($crc_code == 0xa3) {
      $encode = 0x31a ;
    }elsif ($crc_code == 0xa4) {
      $encode = 0x35a ;
    }elsif ($crc_code == 0xa5) {
      $encode = 0x29a ;
    }elsif ($crc_code == 0xa6) {
      $encode = 0x19a ;
    }elsif ($crc_code == 0xa7) {
      $encode = 0x38a ;
    }elsif ($crc_code == 0xa8) {
      $encode = 0x39a ;
    }elsif ($crc_code == 0xa9) {
      $encode = 0x25a ;
    }elsif ($crc_code == 0xaa) {
      $encode = 0x15a ;
    }elsif ($crc_code == 0xab) {
      $encode = 0x34a ;
    }elsif ($crc_code == 0xac) {
      $encode = 0xda ;
    }elsif ($crc_code == 0xad) {
      $encode = 0x2ca ;
    }elsif ($crc_code == 0xae) {
      $encode = 0x1ca ;
    }elsif ($crc_code == 0xaf) {
      $encode = 0x17a ;
    }elsif ($crc_code == 0xb0) {
      $encode = 0x1ba ;
    }elsif ($crc_code == 0xb1) {
      $encode = 0x23a ;
    }elsif ($crc_code == 0xb2) {
      $encode = 0x13a ;
    }elsif ($crc_code == 0xb3) {
      $encode = 0x32a ;
    }elsif ($crc_code == 0xb4) {
      $encode = 0xba ;
    }elsif ($crc_code == 0xb5) {
      $encode = 0x2aa ;
    }elsif ($crc_code == 0xb6) {
      $encode = 0x1aa ;
    }elsif ($crc_code == 0xb7) {
      $encode = 0x3aa ;
    }elsif ($crc_code == 0xb8) {
      $encode = 0x33a ;
    }elsif ($crc_code == 0xb9) {
      $encode = 0x26a ;
    }elsif ($crc_code == 0xba) {
      $encode = 0x16a ;
    }elsif ($crc_code == 0xbb) {
      $encode = 0x36a ;
    }elsif ($crc_code == 0xbc) {
      $encode = 0xea ;
    }elsif ($crc_code == 0xbd) {
      $encode = 0x2ea ;
    }elsif ($crc_code == 0xbe) {
      $encode = 0x1ea ;
    }elsif ($crc_code == 0xbf) {
      $encode = 0x2ba ;
    }elsif ($crc_code == 0xc0) {
      $encode = 0x276 ;
    }elsif ($crc_code == 0xc1) {
      $encode = 0x1d6 ;
    }elsif ($crc_code == 0xc2) {
      $encode = 0x2d6 ;
    }elsif ($crc_code == 0xc3) {
      $encode = 0x316 ;
    }elsif ($crc_code == 0xc4) {
      $encode = 0x356 ;
    }elsif ($crc_code == 0xc5) {
      $encode = 0x296 ;
    }elsif ($crc_code == 0xc6) {
      $encode = 0x196 ;
    }elsif ($crc_code == 0xc7) {
      $encode = 0x386 ;
    }elsif ($crc_code == 0xc8) {
      $encode = 0x396 ;
    }elsif ($crc_code == 0xc9) {
      $encode = 0x256 ;
    }elsif ($crc_code == 0xca) {
      $encode = 0x156 ;
    }elsif ($crc_code == 0xcb) {
      $encode = 0x346 ;
    }elsif ($crc_code == 0xcc) {
      $encode = 0xd6 ;
    }elsif ($crc_code == 0xcd) {
      $encode = 0x2c6 ;
    }elsif ($crc_code == 0xce) {
      $encode = 0x1c6 ;
    }elsif ($crc_code == 0xcf) {
      $encode = 0x176 ;
    }elsif ($crc_code == 0xd0) {
      $encode = 0x1b6 ;
    }elsif ($crc_code == 0xd1) {
      $encode = 0x236 ;
    }elsif ($crc_code == 0xd2) {
      $encode = 0x136 ;
    }elsif ($crc_code == 0xd3) {
      $encode = 0x326 ;
    }elsif ($crc_code == 0xd4) {
      $encode = 0xb6 ;
    }elsif ($crc_code == 0xd5) {
      $encode = 0x2a6 ;
    }elsif ($crc_code == 0xd6) {
      $encode = 0x1a6 ;
    }elsif ($crc_code == 0xd7) {
      $encode = 0x3a6 ;
    }elsif ($crc_code == 0xd8) {
      $encode = 0x336 ;
    }elsif ($crc_code == 0xd9) {
      $encode = 0x266 ;
    }elsif ($crc_code == 0xda) {
      $encode = 0x166 ;
    }elsif ($crc_code == 0xdb) {
      $encode = 0x366 ;
    }elsif ($crc_code == 0xdc) {
      $encode = 0xe6 ;
    }elsif ($crc_code == 0xdd) {
      $encode = 0x2e6 ;
    }elsif ($crc_code == 0xde) {
      $encode = 0x1e6 ;
    }elsif ($crc_code == 0xdf) {
      $encode = 0x2b6 ;
    }elsif ($crc_code == 0xe0) {
      $encode = 0x271 ;
    }elsif ($crc_code == 0xe1) {
      $encode = 0x1d1 ;
    }elsif ($crc_code == 0xe2) {
      $encode = 0x2d1 ;
    }elsif ($crc_code == 0xe3) {
      $encode = 0x31e ;
    }elsif ($crc_code == 0xe4) {
      $encode = 0x351 ;
    }elsif ($crc_code == 0xe5) {
      $encode = 0x29e ;
    }elsif ($crc_code == 0xe6) {
      $encode = 0x19e ;
    }elsif ($crc_code == 0xe7) {
      $encode = 0x38e ;
    }elsif ($crc_code == 0xe8) {
      $encode = 0x391 ;
    }elsif ($crc_code == 0xe9) {
      $encode = 0x25e ;
    }elsif ($crc_code == 0xea) {
      $encode = 0x15e ;
    }elsif ($crc_code == 0xeb) {
      $encode = 0x34e ;
    }elsif ($crc_code == 0xec) {
      $encode = 0xde ;
    }elsif ($crc_code == 0xed) {
      $encode = 0x2ce ;
    }elsif ($crc_code == 0xee) {
      $encode = 0x1ce ;
    }elsif ($crc_code == 0xef) {
      $encode = 0x171 ;
    }elsif ($crc_code == 0xf0) {
      $encode = 0x1b1 ;
    }elsif ($crc_code == 0xf1) {
      $encode = 0x237 ;
    }elsif ($crc_code == 0xf2) {
      $encode = 0x137 ;
    }elsif ($crc_code == 0xf3) {
      $encode = 0x32e ;
    }elsif ($crc_code == 0xf4) {
      $encode = 0xb7 ;
    }elsif ($crc_code == 0xf5) {
      $encode = 0x2ae ;
    }elsif ($crc_code == 0xf6) {
      $encode = 0x1ae ;
    }elsif ($crc_code == 0xf7) {
      $encode = 0x3a1 ;
    }elsif ($crc_code == 0xf8) {
      $encode = 0x331 ;
    }elsif ($crc_code == 0xf9) {
      $encode = 0x26e ;
    }elsif ($crc_code == 0xfa) {
      $encode = 0x16e ;
    }elsif ($crc_code == 0xfb) {
      $encode = 0x361 ;
    }elsif ($crc_code == 0xfc) {
      $encode = 0xee ;
    }elsif ($crc_code == 0xfd) {
      $encode = 0x2e1 ;
    }elsif ($crc_code == 0xfe) {
      $encode = 0x1e1 ;
    }elsif ($crc_code == 0xff) {
      $encode = 0x2b1 ;
    }           
  }
  return $encode;
}

sub encoder_sync {
  my ($octet_hex,$in_disp) = @_;
  my $encode = "";
  
  if ($in_disp) {   # positive input disparity

    if ($octet_hex == 0x1f) {
      $encode = sprintf("%03x", samoct("0b0101111011")); #this is an invalid special code group with
                                                    #the positive disparity completely incorrect 
    } elsif ($octet_hex == 0x0a) {
      $encode = sprintf("%03x", samoct("0b0000000000")); #this is an invalid special code group 
                                                    #the positive disparity completely incorrect 
    } elsif ($octet_hex == 0xff) {
      $encode = sprintf("%03x", samoct("0b1111111111")); #this is an invalid special code group       
                                                    #the positive disparity completely incorrect 
    } elsif ($octet_hex == 0xbc) {
      $encode = sprintf("%03x", samoct("0b1100000101"));  # 305
      } else {die print "\nError: Illegal special octet value: $octet_hex.\n\n";}
    
  } else {          # negative input disparity
   
    if ($octet_hex == 0x1f) {
      $encode = sprintf("%03x", samoct("0b1010111111")); #this is an invalid special code group with
                                                    #the negative disparity completely incorrect 
    } elsif ($octet_hex == 0x0a) {
      $encode = sprintf("%03x", samoct("0b0000000000")); #this is an invalid special code group 
                                                    #the negative disparity completely incorrect 
    } elsif ($octet_hex == 0xff) {
      $encode = sprintf("%03x", samoct("0b1111111111")); #this is an invalid special code group 
                                                    #the negative disparity completely incorrect 
    } elsif ($octet_hex == 0xbc) {
      $encode = sprintf("%03x", samoct("0b0011111010"));  # 0fa
     } else {die print "\nError: Illegal special octet value: $octet_hex.\n\n";}
    
  }
  return ($encode)
}

#subroutines for running disparity calculation

sub disp_check4 {
  my ($num,$in_disp) = @_;
  my $ones = 0;
  my $zeroes = 0; 
  if ($num == 3) {
    return   1;
  }elsif ($num == 12) {
    return   0;
  }else {
    
    
    #counting zeroes and ones
    if ($num & 1) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 2) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 4) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 8) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    
    
    #checking disparity
    if ($zeroes > $ones) {
      return  (0);
    }elsif ($zeroes < $ones) {
      return  (1);
    }else {
      return  ($in_disp);
    }
  }
}

sub disp_check6 {
  my ($num,$in_disp) = @_;
  my $ones = 0;
  my $zeroes = 0; 
  if ($num == 7) {
    return   1;
  }elsif ($num == 56) {
    return   0;
  }else {
    
    
    #counting zeroes and ones
    if ($num & 1) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 2) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 4) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 8) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 16) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    }
    if ($num & 32) {
      $ones = $ones + 1;
    }else { 
      $zeroes = $zeroes +1;
    } 
    
    #checking disparity
    if ($zeroes > $ones) {
      return  (0);
    }elsif ($zeroes < $ones) {
      return  (1);
    }else {
      return  ($in_disp);
    }
  }
}









#############################################################

sub gen_pkt {

  my ($current_disparity, $current_frame_crc, $number_preamble,
      $burst, $carrier_val, $auto_active, $debug, $start_mod, $err_type,
      $last_config_set)  = @_;

  my $code_t_pos = "117";
  my $code_t_neg = "2e8";
  my $code_r_pos = "057";
  my $code_r_neg = "3a8";
  my $code_k285  = "305";
  my $code_d56   = "296";


  # Variables
  my $add_extra_r           = 0;
  my $current_frame_length  = 0;
  my $mod                   = 0;
  my $carrier_ext           = 0;
  my $i                     = 0;
  my $data_codes            = 0;
  my $mod_out               = 0;
  my $ipg                   = 10;


  if ($debug  >= "1"){printf "\nPacketiser Summary\n------------------------------\n";}
  if ($debug  >= "3"){print "The frame I see is $current_frame_crc\n";}


  # Calculate frame length and mod of current final posn
  $current_frame_length =  ((length $current_frame_crc) / 3) - $number_preamble - 1;
  if ($debug  >= "2"){print "There are $current_frame_length ten-bit data codes present in this frame, $number_preamble preamble and a start code\n";}

  $data_codes = $current_frame_length;

  if (($auto_active == 1) and ($debug  >= "2")){print "Performing Auto negotiation function ...";};
  if ($current_frame_length < 64 and $auto_active != 1)
  {
     print "WARNING : Frame length is less than 64 bytes!\n";
  }

  if ($auto_active == 0)
  {

  $mod =(($current_frame_length + $number_preamble + 1 + $start_mod) % 2) ;
  if ($mod == 1) 
  {
    if ($debug  >= "2"){print "There is a requirement for an extra \/R\/ code to be transmitted\n";}
    if ($err_type == 4)
    {$add_extra_r = 0;}
    else{$add_extra_r = 1;}
    
  }
  else
  {
    if ($err_type == 4)
    {$add_extra_r = 1;}
    else{$add_extra_r = 0;}
  }   


  # Add End of Packet

  $current_frame_length = $current_frame_length + 2;
  if ($current_disparity == 0)
  {$current_frame_crc = "$current_frame_crc$code_t_neg$code_r_neg";}
  else
  {$current_frame_crc = "$current_frame_crc$code_t_pos$code_r_pos";}

  # Move to Even Boundary
  
  if (($add_extra_r == 1) and ($burst == 0))
  {
    $current_frame_length = $current_frame_length + 1;
    if ($current_disparity == 0)
    {$current_frame_crc = "$current_frame_crc$code_r_neg";}
    else
    {$current_frame_crc = "$current_frame_crc$code_r_pos";}
  }

  if ($debug  >= "2"){print "Frame with added EPD = $current_frame_crc\n"; }     


  # Fill out to 512 ten-bit codes
  if ((($number_preamble % 2) == 1) or ($burst == 1))
  {$carrier_ext = 512 - $current_frame_length + 2;}  # add 2 for the epd
  else
  {$carrier_ext = 512 - $current_frame_length + 3;}  # add 3 for the epd + even align

  if (($burst == 1) and ($add_extra_r == 1)) {$mod_out = 1;}
  else {$mod_out = 0;}

  if (($carrier_val == 1) and ($current_frame_length < 512))
  {
    if ((($number_preamble % 2) == 1) and ($burst == 1))
    {$mod_out = 0;}
    elsif ((($number_preamble % 2) == 0) and ($burst == 1))
    {$mod_out = 1;}

    if ($debug  >= "2"){print "Carrier extension of $carrier_ext codes are required to make frame up to minimum of 512\n";}      
    for ($i = 1; $i <= $carrier_ext; $i++) 
    {
      $current_frame_length++;
      if ($current_disparity == 0)
      {$current_frame_crc = "$current_frame_crc$code_r_neg";}
      else
      {$current_frame_crc = "$current_frame_crc$code_r_pos";}
    }
    if ($debug  >= "2"){print "And packet with added Carrier Extension added is $current_frame_crc\n";}    
  }


  if ($burst == 1)
  {
    if ($err_type == 5)
    {$ipg = int (rand 10) +1;if ($debug  >= "1"){print "Adding random number of inter packet frames\n";}    }
    else{$ipg = 10;}
    
    # Add $ipg IPG codes
    if ($current_disparity == 0)
    {
      for ($i = 1; $i <= $ipg; $i++) 
      {$current_frame_crc = "$current_frame_crc$code_r_neg";}
    }
    else
    {
      for ($i = 1; $i <= $ipg; $i++) 
      {$current_frame_crc = "$current_frame_crc$code_r_pos";}
    }
    #print "And full packet, with added IPG is $current_frame_crc\n";      
  }
  else
  {
    # Append I1 if required
    if ($current_disparity == 1)
    {$current_frame_crc = "$current_frame_crc$code_k285$code_d56";$current_disparity = 0;    if ($debug  >= "2"){print "Appending I1 ... \n";}    }
  }

  if ($debug  >= "1"){print "Output Packet:\t\t\t  $current_frame_crc\n";}  
  
 } else {  #i.e. if $auto_active

    # Append I1 if required
    if ($current_disparity == 1 and $last_config_set == 1) {
       $current_frame_crc = "$current_frame_crc$code_k285$code_d56";
       $current_disparity = 0;
       if ($debug  >= "2"){print "Appending I1 ... \n";}
    }
 }

 return ($current_frame_crc, $current_disparity, $mod_out, $data_codes);
}







######## Add Error ########

sub gen_err {
  my ($full_packet, $err_type, $err_locn, $err_posn,  $replacement_pos, $pcs_err_trunc,
      $number_preamble, $data_codes, $debug)  = @_;

  my ($preamble, $spd, $data_part, $rest, $num_data, $num_rest,
      $code, $position, $field, $replacement);

  my $first_codegroup;
  my $first_codegroup_h;
  my $initial_disp;
  my $abs_position;
  my $pos_cnt;
  my $new_disp;

  if ($debug  >= "1"){printf "\n\nError Insertion Summary\n------------------------------\n";}

  # these error types already taken care of in gen_pkt
  if ($err_type == 4 or $err_type == 5 ) { return ($full_packet); }
  
  if ($full_packet =~ /^((...){$number_preamble})(...)((...){$data_codes})(.*)$/) {
     ($preamble, $spd,  $data_part, $rest) = ($1, $3, $4, $6);
     ($num_data, $num_rest) = ( (length $data_part)/3, (length $rest)/3 );

  # Get first codegroup to determine initial disparity of packet:
  # that can be either 368 (=> RD-), or 097 (RD+)
  $first_codegroup = substr($preamble,0,3);
  $first_codegroup_h = hex("0x".$first_codegroup);
  if ($first_codegroup == "368") {
	$initial_disp = 0;
  } else {
	$initial_disp = 1;
  }


#     if ($debug >= "2") {
#	print "First codegroup: $first_codegroup\n";
#	print "Initial disparity: $initial_disp\n";
#	printf "\n\nFirst codegroup hex: %x\n\n", $first_codegroup_h;
#	my $new_disp;
#	$new_disp = calc_disparity($first_codegroup_h,$initial_disp,$debug);
#	print "New disp: $new_disp\n\n";
#     }


     if ($debug  >= "2") {print "Preamble:\t$preamble\nSPD:\t\t$spd\nData:\t\t$data_part\nRest:\t\t$rest\n"};
  } 
  else {die print "\nError: packet was matched incorrectly.\n\n";}

  if ($err_locn == 1)  # Preamble
     {($code, $position, $field, $replacement) =  ($preamble, $number_preamble, "Preamble", "000");}
  elsif ($err_locn == 2)  # SPD
     {($code, $position, $field, $replacement) =  ($spd, "1", "SPD", "274");}
  elsif ($err_locn == 3)  # Data
     {($code, $position, $field, $replacement) =  ($data_part, $num_data , "Data", "000");}
  elsif ($err_locn == 4)  # Rest
     {($code, $position, $field, $replacement) =  ($rest, $num_rest, "Rest", "000");}
  elsif ($err_locn > 4)
     {die print "\nError: Error location code $err_locn unknown.\n\n";}

  if    ($err_posn == 1)  {$position = int (rand ($position)) + 1; }   # Random positional replacement
  elsif ($err_posn == 2)  {$position = $replacement_pos;}              # Specific positional replacement
  elsif ($err_posn > 2)
     {die print "\nError: Positional replacement $err_posn code unknown.\n\n";}

  # Determine the error position from the start of the packet
  if ($err_locn == 1) { # preamble
	if ($debug >= "2") {print "Replacing in Preamble at abs pos $abs_position (relative pos $position)\n";}
	$abs_position = $position;
  } elsif ($err_locn == 2) { # SPD
	$abs_position = $number_preamble + $position;
	if ($debug >= "2") {print "Replacing SPD at abs pos $abs_position (relative pos $position)\n";}
  } elsif ($err_locn == 3) { # Data
	$abs_position = $number_preamble + 1 + $position;
	if ($debug >= "2") {print "Replacing in Data at abs pos $abs_position (relative pos $position)\n";}
  } elsif ($err_locn == 4) { # Rest
	$abs_position = $number_preamble + 1 + $num_data + $position;
	if ($debug >= "2") {printf "Replacing in Rest at abs pos %d (relative pos %d)\n",$abs_position, $position;}
  } elsif ($err_locn > 4) {
	die print "\nError: Error location code $err_locn unknown.\n\n";
  }

  # Determine the disparity at the error position
  my $old_disp;
  $old_disp = $initial_disp;
  if ($debug >= "2") {print "Calculating disparity for position $abs_position\n";}
  for ($pos_cnt = 0; $pos_cnt < $abs_position - 1; $pos_cnt++) {
	my $curr_codegroup;
	my $curr_codegroup_s;
	$curr_codegroup_s = "0x".substr($full_packet,($pos_cnt*3),3);
	$curr_codegroup = hex($curr_codegroup_s);
	$new_disp = calc_disparity($curr_codegroup,$old_disp,$debug);
	if ($debug >= "2") {printf "Calculating disparity for position %d (codegroup %x, previous disp %d, new disp %d)\n",$pos_cnt, $curr_codegroup, $old_disp, $new_disp;}
	$old_disp = $new_disp;
  }

  if ($new_disp == 1) {
	  if ($debug >= "2") {print "Using replace_codeword\n";}
	  $code = replace_codeword ($code, $position, $debug, $field, $replacement, $err_type, $pcs_err_trunc);
  } else {
	  if ($debug >= "2") {print "Using replace_codeword_0\n";}
	  $code = replace_codeword_0 ($code, $position, $debug, $field, $replacement, $err_type, $pcs_err_trunc);
  }

  if ($pcs_err_trunc == 0) { # no truncation
     if    ($err_locn == 1)  {return ($code.$spd.$data_part.$rest);}
     elsif ($err_locn == 2)  {return ($preamble.$code.$data_part.$rest);}
     elsif ($err_locn == 3)  {return ($preamble.$spd.$code.$rest);}
     else                    {return ($preamble.$spd.$data_part.$code);}
  } else { #truncate after error
     if    ($err_locn == 1)  {return ($code);}
     elsif ($err_locn == 2)  {return ($preamble.$code);}
     elsif ($err_locn == 3)  {return ($preamble.$spd.$code);}
     else                    {return ($preamble.$spd.$data_part.$code);}
  }
}


# replace_codeword assuming codeword happens on disp = 0 (-)
sub replace_codeword_0 {
   my ($code, $position, $debug, $field, $replacement, $err_type, $pcs_err_trunc) = @_;
   my ($rand_pos, $new_codeword);

   if ($err_type == 1) {
      $new_codeword = substr($code, 3*($position - 1), 3);
      $new_codeword = inv_10bits($new_codeword);
   } elsif ($err_type == 2) {
      $new_codeword = $replacement;
   } elsif ($err_type == 3) {
      $new_codeword = substr($code, 3*($position - 1), 3);
      $new_codeword = inv_1bit($new_codeword);
   } elsif ($err_type == 6) {   # replace with nothing 
      $new_codeword = "";
   } elsif ($err_type == 7) {   # replace with D21.5 
      $new_codeword = "2aa";
   } elsif ($err_type == 8) {   # replace with D2.2 
      $new_codeword = "2d5";
   } elsif ($err_type == 9) {   # replace with D5.6 
      $new_codeword = "296";
   } elsif ($err_type == 10) {   # replace with D16.2 
      $new_codeword = "1b5";
   } elsif ($err_type == 11) {   # replace with K28.5 
      $new_codeword = "0fa";
   } elsif ($err_type == 12) {   # replace with K23.7 
      $new_codeword = "3a8";
   } elsif ($err_type == 13) {   # replace with K27.7 
      $new_codeword = "368";
   } elsif ($err_type == 14) {   # replace with K29.7 
      $new_codeword = "2e8";
   } elsif ($err_type == 15) {   # replace with K30.7 
      $new_codeword = "1e8";
   } elsif ($err_type == 16) {   # replace with random code
      $new_codeword = rand_10_bits();
   } else {die print "\nError: Error type code $err_type unknown.\n\n";}

   if ($pcs_err_trunc == "0") {
      substr($code, 3*($position - 1), 3, $new_codeword);
      if ($debug  >= "1") {print "No truncation after PCS error\n";}
   } else {
      substr($code, 3*($position - 1), 32768, $new_codeword); # replace to end of line
      if ($debug  >= "1") {print "Truncating after PCS error\n";}
   }

   if ($debug  >= "1") {print "Modified $field code number $position to \"$new_codeword\", New $field = $code\n\n";}

  return ($code);
}


# replace_codeword assuming codeword happens on disp = 1 (+)
sub replace_codeword {
   my ($code, $position, $debug, $field, $replacement, $err_type, $pcs_err_trunc) = @_;
   my ($rand_pos, $new_codeword);

   if ($err_type == 1) {
      $new_codeword = substr($code, 3*($position - 1), 3);
      $new_codeword = inv_10bits($new_codeword);
   } elsif ($err_type == 2) {
      $new_codeword = $replacement;
   } elsif ($err_type == 3) {
      $new_codeword = substr($code, 3*($position - 1), 3);
      $new_codeword = inv_1bit($new_codeword);
   } elsif ($err_type == 6) {   # replace with nothing 
      $new_codeword = "";
   } elsif ($err_type == 7) {   # replace with D21.5 
      $new_codeword = "2aa";
   } elsif ($err_type == 8) {   # replace with D2.2 
      $new_codeword = "125";
   } elsif ($err_type == 9) {   # replace with D5.6 
      $new_codeword = "296";
   } elsif ($err_type == 10) {   # replace with D16.2 
      $new_codeword = "245";
   } elsif ($err_type == 11) {   # replace with K28.5 
      $new_codeword = "305";
   } elsif ($err_type == 12) {   # replace with K23.7 
      $new_codeword = "057";
   } elsif ($err_type == 13) {   # replace with K27.7 
      $new_codeword = "097";
   } elsif ($err_type == 14) {   # replace with K29.7 
      $new_codeword = "117";
   } elsif ($err_type == 15) {   # replace with K30.7 
      $new_codeword = "217";
   } elsif ($err_type == 16) {   # replace with random code
      $new_codeword = rand_10_bits();
   } else {die print "\nError: Error type code $err_type unknown.\n\n";}

   if ($pcs_err_trunc == "0") {
      substr($code, 3*($position - 1), 3, $new_codeword);
      if ($debug  >= "1") {print "No truncation after PCS error\n";}
   } else {
      substr($code, 3*($position - 1), 32768, $new_codeword); # replace to end of line
      if ($debug  >= "1") {print "Truncating after PCS error\n";}
   }

   if ($debug  >= "1") {print "Modified $field code number $position to \"$new_codeword\", New $field = $code\n\n";}

  return ($code);
}


# Accepts a 3 character hex value, inverts all bits apart from the first two,
# and outputs a 3 character hex value.
sub inv_10bits {
   my ($in) = @_;
   my $out = "";
   
   # my $code = sprintf ("%012b", oct("0x"."$in"));
   my $code = sprintfdec2bin (12, oct("0x"."$in"));
   
   for (my $i=2; $i <= length($code) - 1; $i++) {
      my $char = substr ($code, $i, 1);
      if ($char) { $out .= "0"; }
      else       { $out .= "1"; }
   }  

   return (sprintf ("%03x", samoct("0b00"."$out")));
}  

sub inv_1bit {
   my ($in) = @_;
   my $out = "";
   
   # my $code = sprintf ("%012b", oct("0x"."$in"));
   my $code = sprintfdec2bin (12, oct("0x"."$in"));
   
   my $bitchange = int (rand 10) + 2;

   for (my $i=2; $i <= length($code) - 1; $i++) {
      my $char = substr ($code, $i, 1);
      if ($i == $bitchange)
      {
      if ($char) { $out .= "0"; }
      else       { $out .= "1"; }
      }
      else {$out .= $char; }
   }  

   return (sprintf ("%03x", samoct("0b00"."$out")));
}  


sub rand_10_bits {
   my $out = "";
   for (1 .. 10) {$out .= int (rand 2);}  
   return (sprintf ("%03x", samoct("0b00"."$out")));
}  


# Subroutine stream_encode:
# Does 10 bit encoding of codegroups presented as octet values and 
# control flag to choose a value either from data or from special
# codegroups tables. No concept of packet, frame or whatsoever.
# Just raw octet stream converted into 10bit codegroups according
# to the current disparity
# -------------------------------

sub stream_encode {
   my ($data, $running_disparity, $debug) = @_;
   
   my ($ctrl_flag,$current_octet, $forced_disparity, $forced_disparity_val, $temp);
   my $current_codegroup;
   my $encoded_data = '';
   my @code_group;
   my $code_group;
   my $index = 1;
   @code_group = split(/\s{1,}/, $data);
   shift(@code_group); 
   foreach $code_group (@code_group){
      $code_group =~ s/.{1}//;
      $ctrl_flag = $&;
      $code_group =~ s/.{2}//;
      $current_octet = oct("0x".$&);
      $code_group =~ s/[n,p]{1}//;
      $forced_disparity = $&;
      if ($ctrl_flag eq 's') {
         if ($forced_disparity =~ /n/) {
           $forced_disparity_val = 0;
           $current_codegroup = k_encoder ($current_octet, $forced_disparity_val);
         } elsif ($forced_disparity =~ /p/) {
           $forced_disparity_val = 1;
           $current_codegroup = k_encoder ($current_octet, $forced_disparity_val);
         } else {
           $current_codegroup = k_encoder ($current_octet, $running_disparity);
         }
      } elsif ($ctrl_flag eq 'i') {
         $current_codegroup = encoder_sync ($current_octet, $running_disparity);
      } elsif ($ctrl_flag eq 'o') {
         if ($forced_disparity =~ /n/) {
           $forced_disparity_val = 0;
           $current_codegroup = encoder ($current_octet, $forced_disparity_val);
           $current_codegroup = sprintf ("%03x",$current_codegroup);  
         } elsif ($forced_disparity =~ /p/) {
           $forced_disparity_val = 1;
           $current_codegroup = encoder ($current_octet, $forced_disparity_val);
           $current_codegroup = sprintf ("%03x",$current_codegroup); 
         } else {
           $current_codegroup = encoder ($current_octet, $running_disparity);
           $current_codegroup = sprintf ("%03x",$current_codegroup); 
         }
      } else {
         die print "\nError: Illegal pcs_synch_rx command arguments: $current_octet.\n\n";
      }
      $encoded_data = $encoded_data . $current_codegroup;
      $running_disparity = calc_disparity (oct("0x".$current_codegroup), $running_disparity,$debug);
  }   
   
   return ($encoded_data,$running_disparity)
}
# -------------------------------


# Subroutine for calculating disparity
# calc_disparity
#
# -------------------------------

sub calc_disparity {
   my ($codegroup,$running_disparity,$debug) = @_;
   
   my $temp0;
   my $temp1;
   my $num0;
   my $num_4;
   my $num_6;
   my $num8;
   my $num9;

   #splitt up 10 bits into 2 subgroups for calculating RD
   # $temp0 = ($codegroup / 16);
   $temp0 = ($codegroup & 1008);
   $temp0 = ($temp0 / 16);
   # $temp1 = sprintf ("%04b", $temp0);
   $temp1 = sprintfdec2bin (4, $temp0);
   $num_6 = samoct("0b"."$temp1");
   $num_4 = ($codegroup & 15);
   if ($debug > 2) 
     {
       # $num0 = sprintf ("%010b", $codegroup);
       $num0 = sprintfdec2bin (10, $codegroup);
       printf "\tEncoded data:"; 
       printf " (0x%3x)  ",$codegroup ; 
       printf " ($num0) \n"; 
       # $num8 = sprintf ("%06b", $num_6);
       $num8 = sprintfdec2bin (6, $num_6);
       printf "\tUpper $num8 -$temp0- -$temp1- -$num_6-\t      :  " ;
     }
   $running_disparity = disp_check6($num_6,$running_disparity);
   if ($debug > 2) 
     {
       printf "Disparity = %d\n",$running_disparity;
       # $num9 = sprintf ("%04b", $num_4);
       $num9 = sprintfdec2bin (4, $num_4);
       printf "\tLower $num9 \t      :  " ;
     }
   $running_disparity = disp_check4($num_4,$running_disparity);
   if ($debug > 2) 
     {
       printf "Running disparity = %d\n",$running_disparity;
     }
    
   return ($running_disparity);
}


sub sprintfdec2bin {
  my ($length,$number) = @_;
  my $count;
  my $reminder;
  my $temp;
  my $concat = "";
  my $diff;
  my $zeros;
  my $file_line;

  
	$count = 0;
	
	while($number >1)
	{
		$temp = 0;
		$reminder = $number%2;
		while($number >1)
		{
			$number = $number -2;
			$temp++;
		}
		$number = $temp;
		$count++;
		$concat = $reminder . $concat;
	}
	$count++;
	$concat = $number . $concat;
	$diff = $length - $count;
	$zeros = "0" x $diff;
	$file_line = $zeros . $concat;
	return ($file_line);
}

sub samoct {
  my ($binline) = @_;
  my $intnum;
  my $linebit;
  my $valueofbit;
  my $rev_count;	

	$intnum = 0;
	$valueofbit = 1;
	
	$rev_count = length($binline) - 1;
	$linebit = substr ($binline, $rev_count, 1);
	while ($linebit ne "b") {
		if ($linebit eq "0") {	
		}
		elsif ($linebit eq "1") {
			$intnum = $intnum + $valueofbit;
		}
		else {
			printf "\n\nError in binary string";
			exit;
		}
		# printf "\nsub samoct -$linebit- -$binline-\n";
		$valueofbit = $valueofbit * 2;
		$rev_count--;
		$linebit = substr ($binline, $rev_count, 1);
	}
  

	return ($intnum);
}

1;
