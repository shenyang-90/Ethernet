eval '(exit $?0)' &&
   eval 'exec perl -S $0 ${1+"$@"}' ||
   eval 'exec perl -S $0 $argv'
if 0;  # dynamic perl startup - finds path to where perl executable is.

use Tie::File;

#-------------------------------------------------------------------------------
# FILE NAME:sscheck_for_pass.pl
#-------------------------------------------------------------------------------
# DESCRIPTION:
# This program checks to see if the pass banner is present in the input log
# file.
# If it is then it reports pass, if not it reports fail.
#-------------------------------------------------------------------------------

my $TOOL_NAME = "check_for_pass.pl";
my $FAIL_TOKEN = "FAIL";
my $PASS_TOKEN = "PASS";
my $UNKNOWN_TOKEN = "UNKNOWN";

my $PASS_BANNER_START_END = "--------------------------------------------------------------";
my $PASS_BANNER_LINE1     = "-  _____  _____  _____  _____    _____  _____  _____  _____  -";
my $PASS_BANNER_LINE2     = "- |_   _||  ___||  ___||_   _|  |  _  ||  _  ||  ___||  ___| -";
my $PASS_BANNER_LINE3     = "-   | |  | |___ | |___   | |    | |_| || |_| || |___ | |___  -";
my $PASS_BANNER_LINE4     = "-   | |  |  ___||___  |  | |    |  ___||  _  ||___  ||___  | -";
my $PASS_BANNER_LINE5     = "-   | |  | |___  ___| |  | |    | |    | | | | ___| | ___| | -";
my $PASS_BANNER_LINE6     = "-   |_|  |_____||_____|  |_|    |_|    |_| |_||_____||_____| -";

my $FAIL_BANNER_START_END = "-----------------------------------------------------------";
my $FAIL_BANNER_LINE1     = "-  _____  _____  _____  _____    _____  _____  _   _      -";
my $FAIL_BANNER_LINE2     = "- |_   _||  ___||  ___||_   _|  |  ___||  _  || | | |     -";
my $FAIL_BANNER_LINE3     = "-   | |  | |___ | |___   | |    | |___ | |_| || | | |     -";
my $FAIL_BANNER_LINE4     = "-   | |  |  ___||___  |  | |    |  ___||  _  || | | |     -";
my $FAIL_BANNER_LINE5     = "-   | |  | |___  ___| |  | |    | |    | | | || | | |___  -";
my $FAIL_BANNER_LINE6     = "-   |_|  |_____||_____|  |_|    |_|    |_| |_||_| |_____| -";

my $seed_line   = "Using a fixed config";

my $ius_w_count = 0;
my $c_w_count   = 0;
my $den_w_count = 0;
my $uvm_w_count = 0;

my $ius_e_count = 0;
my $den_e_count = 0;
my $uvm_e_count = 0;

my $ius_f_count = 0;
my $uvm_f_count = 0;
  
my $pass_banner_count = 0;
my $fail_banner_count = 0;

#-------------------------------------------------------------------------------
# FUNCTION MAIN
#-------------------------------------------------------------------------------

(@ARGV >= 1) or die "\nUsage: $TOOL_NAME <test name>\n";

my $test_name    = $ARGV[0];
my $setup_file   = "$test_name.setup";
my $sim_log_file = "irun_$test_name.log";
my $result       = $UNKNOWN_TOKEN;

#-------------------------------------------------------------------------------
# PARSE SETUP FILE
#-------------------------------------------------------------------------------

#open ($FILE_HANDLE, "< $setup_file") or die "Cannot open $setup_file!\n";
tie my @file, 'Tie::File', "$setup_file" or die "Cannot open $setup_file!\n";

#while(<$FILE_HANDLE1>) {
for my $linenr (0 .. $#file) {

  # Get the current line from the vsif file handle
  my $Line = $file[$linenr];
  #print "Line: $Line\n";

  #-------------------------------
  # Extract the config seed
  #-------------------------------

  if($Line =~ /seed/) {
    #print "$Line";
    $seed_line = $Line;
  }
}

#close ($FILE_HANDLE) or die "Cannot close $sim_log_file!\n";
untie @file;

#-------------------------------------------------------------------------------
# PARSE LOG FILE
#-------------------------------------------------------------------------------

#open ($FILE_HANDLE1, "< $sim_log_file") or die "Cannot open $sim_log_file!\n";
tie my @file, 'Tie::File', "$sim_log_file" or die "Cannot open $sim_log_file!\n";

#while(<$FILE_HANDLE2>) {
for my $linenr (0 .. $#file) {

  # Get the current line from the vsif file handle
  my $Line = $file[$linenr];
  #print "Line: $Line\n";

  #-------------------------------
  # Count Warnings
  #-------------------------------

  # Look for *W
  if($Line =~ /\*W/) {
    #print "\*W found";
    $ius_w_count = $ius_w_count + 1;
  }
    
  # Look for C compile warnings
  if($Line =~ /warning:/) {
    #print "\*W found";
    $c_w_count = $c_w_count + 1;
  }

  # Look for Denali warnings
  if($Line =~ /\*Denali\* Warning/) {
    #print "Denali warning found";
    $den_w_count = $den_w_count + 1;
  }  
    
  # Look for UVM_WARNING
  if($Line =~ /UVM_WARNING \//) {
    #print "UVM_WARNING found";
    $uvm_w_count = $uvm_w_count + 1;
  }
  
  #-------------------------------
  # Errors
  #-------------------------------

  # Look for *E
  if($Line =~ /\*E/) {
    #print "\*E found\n";
    $ius_e_count = $ius_e_count + 1;
    $result = $FAIL_TOKEN;
  }

  # Look for Denali errors
  if($Line =~ /\*Denali\* Error/) {
    #print "Denali error found";
    $den_e_count = $den_e_count + 1;
    $result = $FAIL_TOKEN;
  } 
  
  # Look for UVM_ERROR
  if($Line =~ /UVM_ERROR \//) {
    #print "UVM_ERROR found";
    $uvm_e_count = $uvm_e_count + 1;
    $result = $FAIL_TOKEN;
  }
  
  #-------------------------------
  # Fatal
  #-------------------------------  
  
  # Look for *F
  if($Line =~ /\*F/) {
    #print "\*F found\n";
    $ius_f_count = $ius_f_count + 1;
    $result = $FAIL_TOKEN;
  }
  
  # Look for UVM_FATAL
  if ($Line =~ /UVM_FATAL \//) {
    #print "UVM_ERROR found\n";
    $uvm_f_count = $uvm_f_count + 1;
    $result = $FAIL_TOKEN;
  } 
  
  #-------------------------------
  # Banners
  #-------------------------------  
    
  # Look for PASS banner
  if($Line =~ $PASS_BANNER_START_END) {
    #print "Potential Pass Banner Start/End found\n";
    if($file[$linenr+1] =~ $PASS_BANNER_LINE1) {
      #print "PASS_BANNER_LINE1 found\n";
      if($file[$linenr+2] =~ $PASS_BANNER_LINE2) {
        #print "PASS_BANNER_LINE2 found\n";
        if($file[$linenr+3] =~ $PASS_BANNER_LINE3) {
          #print "PASS_BANNER_LINE3 found\n";
          if($file[$linenr+4] =~ $PASS_BANNER_LINE4) {
            #print "PASS_BANNER_LINE4 found\n";
            if($file[$linenr+5] =~ $PASS_BANNER_LINE5) {
              #print "PASS_BANNER_LINE5 found\n";
              if($file[$linenr+6] =~ $PASS_BANNER_LINE6) {
                #print "PASS_BANNER_LINE6 found\n";
                #print "PASS banner found\n";
                $pass_banner_count = $pass_banner_found + 1;
                $result = $PASS_TOKEN;
              }
            }
          }
        }
      }
    }
  }
  
  # Look for FAIL banner
  if($Line =~ $FAIL_BANNER_START_END) {
    #print "Potential Fail Banner Start/End found\n";
    if($file[$linenr+1] =~ $FAIL_BANNER_LINE1) {
      #print "FAIL_BANNER_LINE1 found\n";
      if($file[$linenr+2] =~ $FAIL_BANNER_LINE2) {
        #print "FAIL_BANNER_LINE2 found\n";
        if($file[$linenr+3] =~ $FAIL_BANNER_LINE3) {
          #print "FAIL_BANNER_LINE3 found\n";
          if($file[$linenr+4] =~ $FAIL_BANNER_LINE4) {
            #print "FAIL_BANNER_LINE4 found\n";
            if($file[$linenr+5] =~ $FAIL_BANNER_LINE5) {
              #print "FAIL_BANNER_LINE5 found\n";
              if($file[$linenr+6] =~ $FAIL_BANNER_LINE6) {
                #print "FAIL_BANNER_LINE6 found\n";
                #print "FAIL banner FOUND\n";
                $fail_banner_count = $fail_banner_found + 1;                
                $result = $FAIL_TOKEN;
              }
            }
          }
        }
      }
    }
  }
}

#close ($FILE_HANDLE) or die "Cannot close $sim_log_file!\n";
untie @file;

#-------------------------------------------------------------------------------
# PRINT REPORT
#-------------------------------------------------------------------------------

print "--------------------------------------------------------------------------------\n";
print "Test name  : $test_name\n";
print "\n";
print "Setup file : $setup_file\n";
print "Log file   : $sim_log_file\n";
print "\n";
print "$seed_line\n";
print "\n";
print "WARNING REPORT\n";
print "- IUS warnings (*W)    : $ius_w_count\n";
print "- C compile warnings   : $c_w_count\n";
print "- Denali warnings      : $den_w_count\n";
print "- UVM_WARNING warnings : $uvm_w_count\n";
print "\n";
print "ERROR REPORT\n";
print "- IUS error (*E)       : $ius_e_count\n";
print "- Denali errors        : $den_e_count\n";
print "- UVM_ERROR errors     : $uvm_e_count\n";
print "\n";
print "FATAL REPORT\n";
print "- IUS fatal (*F)       : $ius_f_count\n";
print "- UVM_FATAL errors     : $uvm_f_count\n";
print "\n";
print "BANNER REPORT\n";
print "- FAIL banner          : $fail_banner_count\n";
print "- PASS banner          : $pass_banner_count\n";
print "\n";
print "Simulation result : $result\n";
print "--------------------------------------------------------------------------------\n";

#-------------------------------------------------------------------------------
# CLOSE FILES AND EXIT
#-------------------------------------------------------------------------------

# Return 1 for fail and 0 for pass.
if ($result == $PASS_TOKEN) {
    exit(0);
} else {
    exit(1);
}

#-------------------------------------------------------------------------------
# END OF FILE
#-------------------------------------------------------------------------------

