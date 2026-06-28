eval '(exit $?0)' &&
   eval 'exec perl -S $0 ${1+"$@"}' ||
   eval 'exec perl -S $0 $argv'
if 0;  # dynamic perl startup - finds path to where perl executable is.

use Tie::File;

#----------------------------------------------------------------------------
# FILE NAME:sscheck_for_pass.pl
#----------------------------------------------------------------------------
# DESCRIPTION:
# This program checks to see if the pass banner is present in the input log file.
# If it is then it reports pass, if not it reports fail.
#----------------------------------------------------------------------------
my $TOOL_NAME = "check_for_pass.pl";
my $FAIL_TOKEN = "FAIL";
my $PASS_TOKEN = "PASS";
my $UNKNOWN_TOKEN = "UNKNOWN";

my $BANNER_START_END = "--------------------------------------------------------------";
my $PASS_BANNER_LINE1= "-  _____  _____  _____  _____    _____  _____  _____  _____  -";
my $PASS_BANNER_LINE2= "- |_   _||  ___||  ___||_   _|  |  _  ||  _  ||  ___||  ___| -";
my $PASS_BANNER_LINE3= "-   | |  | |___ | |___   | |    | |_| || |_| || |___ | |___  -";
my $PASS_BANNER_LINE4= "-   | |  |  ___||___  |  | |    |  ___||  _  ||___  ||___  | -";
my $PASS_BANNER_LINE5= "-   | |  | |___  ___| |  | |    | |    | | | | ___| | ___| | -";
my $PASS_BANNER_LINE6= "-   |_|  |_____||_____|  |_|    |_|    |_| |_||_____||_____| -";

my $FAIL_BANNER_LINE1= "-  _____  _____  _____  _____    _____  _____  _   _      -";
my $FAIL_BANNER_LINE2= "- |_   _||  ___||  ___||_   _|  |  ___||  _  || | | |     -";
my $FAIL_BANNER_LINE3= "-   | |  | |___ | |___   | |    | |___ | |_| || | | |     -";
my $FAIL_BANNER_LINE4= "-   | |  |  ___||___  |  | |    |  ___||  _  || | | |     -";
my $FAIL_BANNER_LINE5= "-   | |  | |___  ___| |  | |    | |    | | | || | | |___  -";
my $FAIL_BANNER_LINE6= "-   |_|  |_____||_____|  |_|    |_|    |_| |_||_| |_____| -";

#----------------------------------------------------------------
# FUNCTION MAIN
#----------------------------------------------------------------
(@ARGV >= 1) or die "\nUsage: $TOOL_NAME <sim_log_file>\n";

my $sim_log_file = $ARGV[0];



print "Reading $sim_log_file to look for the pass banner.\n";

my $result = $UNKNOWN_TOKEN;

#open ($FILE_HANDLE, "< $sim_log_file") or die "Cannot open $sim_log_file!\n";
tie my @file, 'Tie::File', "$sim_log_file" or die "Cannot open $sim_log_file!\n";

#while(<$FILE_HANDLE>) {
for my $linenr (0 .. $#file) {
    my $Line = $file[$linenr];        # Get the current line from the vsif file handle
    if($Line =~ $BANNER_START_END) {
        #print "\nPotential Banner Start/End found\n";
        if($file[$linenr+1] =~ $PASS_BANNER_LINE1) {
            #print "\nPASS_BANNER_LINE1 found";
            if($file[$linenr+2] =~ $PASS_BANNER_LINE2) {
                #print "\nPASS_BANNER_LINE2 found";
                if($file[$linenr+3] =~ $PASS_BANNER_LINE3) {
                    #print "\nPASS_BANNER_LINE3 found";
                    if($file[$linenr+4] =~ $PASS_BANNER_LINE4) {
                        #print "\nPASS_BANNER_LINE4 found";
                        if($file[$linenr+5] =~ $PASS_BANNER_LINE5) {
                            #print "\nPASS_BANNER_LINE5 found";
                            if($file[$linenr+6] =~ $PASS_BANNER_LINE6) {
                                #print "\nPASS_BANNER_LINE6 found";
                                print "\nFULL PASS_BANNER FOUND!";
                                $result = $PASS_TOKEN;
                                last;
                            }
                        }
                    }
                }
            }
        }
        if($file[$linenr+1] =~ $FAIL_BANNER_LINE1) {
            #print "\nFAIL_BANNER_LINE1 found";
            if($file[$linenr+2] =~ $FAIL_BANNER_LINE2) {
                #print "\nFAIL_BANNER_LINE2 found";
                if($file[$linenr+3] =~ $FAIL_BANNER_LINE3) {
                    #print "\nFAIL_BANNER_LINE3 found";
                    if($file[$linenr+4] =~ $FAIL_BANNER_LINE4) {
                        #print "\nFAIL_BANNER_LINE4 found";
                        if($file[$linenr+5] =~ $FAIL_BANNER_LINE5) {
                            #print "\nFAIL_BANNER_LINE5 found";
                            if($file[$linenr+6] =~ $FAIL_BANNER_LINE6) {
                                #print "\nFAIL_BANNER_LINE6 found";
                                print "\nFULL FAIL_BANNER FOUND!";
                                $result = $FAIL_TOKEN;
                                last;
                            }
                        }
                    }
                }
            }
        }
    }
}

print "\nSimulation Result = $result\n";

#close ($FILE_HANDLE) or die "Cannot close $sim_log_file!\n";
untie @file;
# Return 1 for fail and 0 for pass.
if ($result == $PASS_TOKEN) {
    exit(0);
} else {
    exit(1);
}
