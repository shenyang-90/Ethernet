#!/usr/bin/perl -w
#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2002-2014
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      spg_lib_file_list.pl
#
#          Description :      Perl script to automate pulling technology libraries in for Spyglass
#
#      Original Author :      Anna Gilbert 
#
#------------------------------------------------------------------------------	   
$found_lib_definition = 0;
$variable_definition_started = 0;
$var_name = "";
$var_value = "";
$kitslib = "";
$new_file_to_parse = 1;
$file_to_parse = "$ENV{IPF_DESIGN_FLOW_SCRIPTS}/tech_lib_setup.tcl";

while ($new_file_to_parse == 1) {
$new_file_to_parse = 0;
open (TECHLIBSETUP, $file_to_parse);
while ($line = <TECHLIBSETUP>) {

   if ($line =~ /^source\s+(.*)$/) {
     $file_to_parse = $1;
     $new_file_to_parse = 1;
   }
   
   if ($file_to_parse =~ /^\$/) {
      $file_to_parse =~ s/\$(\w+)/sprintf($ENV{$1})/eg;
   }
  
   if ($line =~ /\$env\(TECHNOLOGY\)\s+==/) {
      $found_lib_definition = 0;
   }

   if ($line =~ /\$env\(TECHNOLOGY\)\s+==\s+"$ENV{TECHNOLOGY}"/) {
      print "technology used is '$ENV{TECHNOLOGY}'\n";
      $found_lib_definition = 1;
   }

   if ($found_lib_definition == 1) {

      if ($line =~ /^\s*set\s+(\w+)\s+"?(\S+)/) {
	 $var_name  = $1;
	 $var_value = $2;
	 $var_value =~ s/\$KITSLIB/$kitslib/g;
	 @temp_store = ($var_value);
         $variable_definition_started = 1;
      } elsif (($variable_definition_started) && ($line =~ /^\s*([^\s"]+)/)) {
	$var_value = $1;
	$var_value =~ s/\$KITSLIB/$kitslib/g;
	push @temp_store, $var_value;	
        }
	
	

      if ($variable_definition_started && (($line !~ /\\$/) || ($line =~ /^\s*"\s*$/))) {
	 $variable_definition_started = 0;
	 if ($var_name eq "SLOWLIB") {
	   @libs = @temp_store;
	}

       if ($var_name eq "KITSLIB") {
	 $kitslib = $temp_store[0];
       }

	 if ($var_name eq "LIBLIB") {
	   @dirs = @temp_store;
	}
      }

   }

}
close TECHLIBSETUP
}

$spg_lib_file_list = "./spyglass/spg_lib_file_list";

open spg_lib_file_list,">".$spg_lib_file_list or die "Cannot create missing $spg_lib_file_list";
foreach $dirname (@dirs) {
   foreach $filename (@libs) {
      if (-e "$dirname/$filename") {
      use File::Find;
         find sub { print spg_lib_file_list "$File::Find::name\n" if ((/$filename/) && (!/.$filename/))}, $dirname;
      }
   }
}
close spg_lib_file_list;
