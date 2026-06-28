eval '(exit $?0)' &&
   eval 'exec perl -S $0 ${1+"$@"}' ||
   eval 'exec perl -S $0 $argv'
if 0;  # dynamic perl startup - finds path to where perl executable is.

#----------------------------------------------------------------------------
# FILE NAME:		gen_standalone_regression_script.pl
#----------------------------------------------------------------------------
# DESCRIPTION:
# This program creates a stand alone regression script for regressions based
# on an input vsif. This is to help customers who do not use 
# eManager/vManager.
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Program Information Variables
#----------------------------------------------------------------------------
my $VERSION_NUMBER  = "1.3";
my $AUTHOR_NAME     = "Cadence Design Systems";
my $TOOL_NAME       = "gen_standalone_regression_script.pl";
my $REGRESSION_SCRIPT_NAME = "";
my $REGRESSION_RESULTS_FILE_NAME = "";
my $VSIF_FILE = "";
my @TEST_ARRAY = ();
my %DEFINES_HASH = ();
my $CURRENT_RUN_SCRIPT = "";
my $CHECK_FOR_PASS_SCRIPT_NAME = "check_for_pass.pl";
my $VSIF_PATH = "";
my $VSIF_INTERNAL_PATH_FOR_REPLACEMENT = "CDN_DEMO_PATH";
my @VSIF_FILES = ();
my $run_script_is_multi_line_arg = "FALSE";
my $pre_session_script_is_multi_line_arg = "FALSE";
my $pre_group_script_is_multi_line_arg = "FALSE";
my $full_line = "";
my $debug_mode = "FALSE";

#----------------------------------------------------------------
# FUNCTION PROTOTYPES
#----------------------------------------------------------------
sub remove_xml_text_tags($);
sub project_specific_run_script_clean($);
sub remove_env_token($);
sub process_command_switch($);
sub macro_define_substitution($);
sub parse_vsif_file_into_test_array($);

#----------------------------------------------------------------
# FUNCTION MAIN
#----------------------------------------------------------------
(@ARGV >= 1) or die "\nUsage: $TOOL_NAME <switches> <vsif_file>\n";

my $NumberOfInputParameters = scalar @ARGV;
#----------------------------------------------------------------
for ($i=0; $i != $NumberOfInputParameters; $i++){
    my $input_file = $ARGV[$i];
    if ($input_file =~ /^(-)+/o) {
        # Check for command line switches
        process_command_switch($input_file);
        # Remove the switch for other functions
        next;
    }
    chomp($input_file);
    push @VSIF_FILES, "$input_file";
}

my $CHECK_FOR_PASS_SCRIPT = "$VSIF_PATH$CHECK_FOR_PASS_SCRIPT_NAME";
my $CDN_DEMO_TB_PATH = $VSIF_PATH;
$CDN_DEMO_TB_PATH =~ s/\/verif\/uvc_lib\/cdn_demo\/vm\///;

foreach $VSIF_FILE (@VSIF_FILES) {

    # Reset ARRAYS and HASH for handling multiple VSIF inputs
    @TEST_ARRAY = ();
    %DEFINES_HASH = ();
# Change regression script name to match vsif naming.
# Create a regressions results file name.
    my $temp_script_name = "$VSIF_FILE";
    $temp_script_name =~ s/\.vsif/\.sh/;
    $REGRESSION_SCRIPT_NAME = "run_$temp_script_name";
    $REGRESSION_RESULTS_FILE_NAME = $REGRESSION_SCRIPT_NAME;
    $REGRESSION_RESULTS_FILE_NAME =~ s/\.sh/\.results/;
    
    parse_vsif_file_into_test_array($VSIF_FILE);
    
# Create and write the command script
    open (SCRIPT, "> $REGRESSION_SCRIPT_NAME") or die "Cannot open $REGRESSION_SCRIPT_NAME!\n";
    print SCRIPT "#!/bin/bash\n";
    print SCRIPT "rm -rf $REGRESSION_RESULTS_FILE_NAME\n";
    print SCRIPT "touch $REGRESSION_RESULTS_FILE_NAME\n";
    foreach $text_line (@TEST_ARRAY) {
        print SCRIPT "$text_line";
    }
# Make the script executable and close file then exit
    chmod 0755, $REGRESSION_SCRIPT_NAME;
    close (SCRIPT) or die "Cannot close $REGRESSION_SCRIPT_NAME!\n";
    
    print "\nFinished generation of stand alone regression script ($REGRESSION_SCRIPT_NAME).\n";
}
exit;

#----------------------------------------------------------------
# END FUNCTION MAIN
#----------------------------------------------------------------

#----------------------------------------------------------------
# SUB FUNCTIONS
#----------------------------------------------------------------
# Function to remove project specific run or elab arguments.
sub project_specific_run_or_elab_clean($) {
    my ($text) = @_;
    # Project specific clean up - Remove any project specific defaults i.e. value that the makefile ignores - this just cleans things up a little.
    # Remove MTI=MTI_ENABLE if left to default value which is ignore by the makefile
    $text =~ s/MTI=MTI_ENABLE//gi;
    # Remove USB2PHY/USB3PHY if left to default value which is ignore by the makefile
    $text =~ s/USB2PHY_IF=USB_2_PHY_INTERFACE//gi;
    $text =~ s/USB3PHY_IF=USB_3_PHY_INTERFACE//gi;
    # Remove PHY_BYPASS if left to default value which is ignore by the makefile
    $text =~ s/PHY_BYPASS=PHY_BYPASS_ENABLE//gi;
    # Remove ENABLE_TOP_TOGGLE_COV if left to default value which is ignored by the makefile
    $text =~ s/ENABLE_TOP_TOGGLE_COV=ENABLE_TOP_TOGGLE_COVERAGE//gi;
    # Remove LEGACY_IRQ if left to default value which is ignored by the makefile
    $text =~ s/LEGACY_IRQ=ENABLE_LEGACY_IRQ//gi;
    # Remove DISABLE_USB3_VIP if left to default value which is ignored by the makefile
    $text =~ s/DISABLE_USB3_VIP=DISABLE_USB3//gi;
    return $text;
}
# Function to remove $ENV(xyz) tokens and replace path
sub remove_env_token($) {
    my ($text) = @_;
    # Remove ENV and add $ to the input var
    # replace path $VSIF_INTERNAL_PATH_FOR_REPLACEMENT
    $text =~ s/\$ENV\($VSIF_INTERNAL_PATH_FOR_REPLACEMENT\)/$CDN_DEMO_TB_PATH/gi;
    return $text;
}

# Function to remove vip lib path and use makefile default which should be local dir
sub remove_cdn_vip_lib_path($) {
    my ($text) = @_;
    $text =~ s/CDN_VIP_LIB_PATH(\S)+\s//gi;
    return $text;
}

# Function to remove anything with $DIR as part of the arguments and use makefile default which should be local dir
sub remove_dollar_dir_path($) {
    my ($text) = @_;
    $text =~ s/\s(.)+\$DIR(.)+\s//gi;
#    $text =~ s/(\S)+\=(\S)+\$DIR\((\S)+\)(\S)+\s//gi;
    return $text;
}

# Function to remove xml <text></text> tags
sub remove_xml_text_tags($) {
    my ($text) = @_;
# Remove xml text tags
    $text =~ s/^(.)*<text>//i;
    $text =~ s/<\/text>(.)*$//i;
    return $text;
}

# Function to remove token and quotes
sub remove_token_and_quotes_tags($) {
    my ($text) = @_;
# Remove quotes and token text
    $text =~ s/^(.)*\"//i;
    $text =~ s/\"(.)*$//i;
# Remove token and preprocess_multiline_string macro with opening ( and trailing )
    if ($text =~ /preprocess_multiline_string/) {
        $text =~ s/^(.)*preprocess_multiline_string(\s)*\(//i;
        $text =~ s/\)(\s)*$//i;
    }
    return $text;
}

# Function to perform macro define substitution using the DEFINES_HASH
sub macro_define_substitution($) {
    my ($text) = @_;
    foreach $define_to_replace (sort keys %DEFINES_HASH) {
        if ($text =~ /$define_to_replace/) {
            $text =~ s/$define_to_replace/$DEFINES_HASH{$define_to_replace}/g;
        }
    }
    return $text;
}

# Function to parse the vsif files recursively into a TEST ARRAY for printing to the script file.
sub parse_vsif_file_into_test_array($) {
    my ($vsif) = @_;
    print "\nOpening $vsif for parsing and generation of stand alone regression script.\n";
    my $VSIF_HANDLE;
    my $group_seed_value = "1";
    my $group_count_value = 1;
    # Prepend path unless the full path has already been given.
    if ($vsif !~ /$VSIF_PATH/) {
    $vsif = $VSIF_PATH.$vsif;
    }
    open ($VSIF_HANDLE, "< $vsif") or die "Cannot open $vsif!\n";
    while(<$VSIF_HANDLE>) {
        my $Line = $_;        # Get the current line from the vsif file handle
        # Ignore commented lines
        next if ($Line =~ /^(\s)*\/\//);
        # If the line contains a #define then parse it
        if ($Line =~ /\#define/) {
            next if ($Line =~ /\(/); # Skip complex define macros.
            my ($define,$name,$value) = split(/\s/,$Line,3);
            chomp($name);
            chomp($value);
            $DEFINES_HASH{$name} = $value;
            next;
        }
        # If the line contains a #include then parse that vsif with the info we have
        if ($Line =~ /\#include/) {
            # Ignore farm vsif include
            next if ($Line =~ /FARM_VSIF/);
            my ($include,$vsif_file_name) = split(/include/i,$Line,2);
            $vsif_file_name =~ s/\s//g;
            chomp($vsif_file_name);
            # Remove quotes
            $vsif_file_name =~ s/\"//gi;
            # If the line contains an env var then use unix ls to get correct path otherwise assume local to PWD.
            if ($vsif_file_name =~ /\$/) {
                my $vsif_file_name_full_path = `ls $vsif_file_name`;
                parse_vsif_file_into_test_array($vsif_file_name_full_path);
            } else {
                parse_vsif_file_into_test_array($vsif_file_name);
            }
            next;
        }
        # Extract the pre_session_script line and search and replace defines
        if ($Line =~ /pre_session_script/ || $pre_session_script_is_multi_line_arg eq "TRUE") {
            my $session_compile = "";
            if($debug_mode eq "TRUE") {print("\nDEBUG - Line = ", $Line);}
            # Detect if the pre_session_script is spread over multiple lines (detect \ char)
            if ($Line =~ /\\/) {
                $pre_session_script_is_multi_line_arg = "TRUE";
                # Remove the multi line char and accumulate into $full_line assembly buffer.
                $Line =~ s/\\//;
                $full_line .= $Line;
                # Get next line of the multi-line
                next;
            } else {
                # Check if we have just ended a multi-line parse
                if ($pre_session_script_is_multi_line_arg eq "TRUE") {
                    # Assemble the last line
                    $full_line .= $Line;
                    # Remove xml text tags
                    $session_compile = remove_xml_text_tags($full_line);
                    # Reset multi line flag and $full_line assembly buffer
                    $full_line = "";
                    $pre_session_script_is_multi_line_arg = "FALSE";
                } else {
                    # Just handle the line
                    # Remove xml text tags
                    $session_compile = remove_xml_text_tags($Line);
                }
            }
            # Remove token and quotes
            $session_compile = remove_token_and_quotes_tags($session_compile);
            # If the line finishes with a ; remove it
            $session_compile =~ s/\;(\s)+$//gi;
            # Perform macro substitution
            my $expanded_line = macro_define_substitution($session_compile);
            # Remove ENV token
            $expanded_line = remove_env_token($expanded_line);
            # remove CDN_VIP_LIB_PATH
            $expanded_line = remove_cdn_vip_lib_path($expanded_line);
            # remove anything with $DIR as part of the arguments
            $expanded_line = remove_dollar_dir_path($expanded_line);
            # Project specific clean up - Remove any project specific defaults i.e. value that the makefile ignores - this just cleans things up a little.
            $expanded_line = project_specific_run_or_elab_clean($expanded_line);
            # Remove MTI=MTI_ENABLE switch
            $expanded_line =~ s/MTI=MTI_ENABLE//gi;
            # Clean up runs of multiple whitespace
            $expanded_line =~ s/\s{2,}/ /g;
            push @TEST_ARRAY, "\n# Session compile script - normally used to build run dependancies like vip libs.\n";
            if($debug_mode eq "TRUE") {print("\nDEBUG - Pushing expanded pre_session_script line into TEST_ARRAY = ", $expanded_line);}
            push @TEST_ARRAY, "\n$expanded_line\n";
            next;
        }        
        # Extract the pre_group_script line and search and replace defines
        if ($Line =~ /pre_group_script/ || $pre_group_script_is_multi_line_arg eq "TRUE") {
            my $group_compile = "";
            if($debug_mode eq "TRUE") {print("\nDEBUG - Line = ", $Line);}
            # Detect if the pre_group_script is spread over multiple lines (detect \ char)
            if ($Line =~ /\\/) {
                $pre_group_script_is_multi_line_arg = "TRUE";
                # Remove the multi line char and accumulate into $full_line assembly buffer.
                $Line =~ s/\\//;
                $full_line .= $Line;
                # Get next line of the multi-line
                next;
            } else {
                # Check if we have just ended a multi-line parse
                if ($pre_group_script_is_multi_line_arg eq "TRUE") {
                    # Assemble the last line
                    $full_line .= $Line;
                    # Remove xml text tags
                    $group_compile = remove_xml_text_tags($full_line);
                    # Reset multi line flag and $full_line assembly buffer
                    $full_line = "";
                    $pre_group_script_is_multi_line_arg = "FALSE";
                } else {
                    # Just handle the line
                    # Remove xml text tags
                    $group_compile = remove_xml_text_tags($Line);
                }
            }
            # Remove token and quotes
            $group_compile = remove_token_and_quotes_tags($group_compile);
            # If the line finishes with a ; remove it
            $group_compile =~ s/\;(\s)+$//gi;
            # Perform macro substitution
            my $expanded_line = macro_define_substitution($group_compile);
            # Remove ENV token
            $expanded_line = remove_env_token($expanded_line);
            # remove CDN_VIP_LIB_PATH
            $expanded_line = remove_cdn_vip_lib_path($expanded_line);
            # remove anything with $DIR as part of the arguments
            $expanded_line = remove_dollar_dir_path($expanded_line);
            # Project specific clean up - Remove any project specific defaults i.e. value that the makefile ignores - this just cleans things up a little.
            $expanded_line = project_specific_run_or_elab_clean($expanded_line);
            # Remove MTI=MTI_ENABLE switch
            $expanded_line =~ s/MTI=MTI_ENABLE//gi;
            # Clean up runs of multiple whitespace
            $expanded_line =~ s/\s{2,}/ /g;
            push @TEST_ARRAY, "\n# Group compile script - normally used to build run dependancies like elab snapshot and other required libs.\n";
            if($debug_mode eq "TRUE") {print("\nDEBUG - Pushing expanded pre_group_script line into TEST_ARRAY = ", $expanded_line);}
            push @TEST_ARRAY, "\n$expanded_line\n";
            next;
        }        
        # Extract the run_script line and search and replace defines
        if ($Line =~ /(\s)+run_script/ || $run_script_is_multi_line_arg eq "TRUE") {
            my $test_run_script = "";
            if($debug_mode eq "TRUE") {print("\nDEBUG - Line = ", $Line);}
            # NOTE: run_script can appear inside a test group line and should be skipped here is that is the case as it will be processed elsewhere.
            if ($Line =~ /test(.)*\{(.)*\}/) {
                # Do nothing but allow processing to continue as the test needs to be processed
                # within this loop.
            } else {
                # Detect if the run_script is spread over multiple lines (detect \ char)
                if ($Line =~ /\\/) {
                    $run_script_is_multi_line_arg = "TRUE";
                    # Remove the multi line char and accumulate into $full_line assembly buffer.
                    $Line =~ s/\\//;
                    $full_line .= $Line;
                    # Get next line of the multi-line
                    next;
                } else {
                    # Check if we have just ended a multi-line parse
                    if ($run_script_is_multi_line_arg eq "TRUE") {
                        # Assemble the last line
                        $full_line .= $Line;
                        # Remove xml text tags
                        $test_run_script = remove_xml_text_tags($full_line);
                        # Reset multi line flag and $full_line assembly buffer
                        $full_line = "";
                        $run_script_is_multi_line_arg = "FALSE";
                    } else {
                        # Just handle the line
                        # Remove xml text tags
                        $test_run_script = remove_xml_text_tags($Line);
                    }
                }
                # Remove token and quotes
                $test_run_script = remove_token_and_quotes_tags($test_run_script);
                # If the line finishes with a ; remove it
                $test_run_script =~ s/\;(\s)+$//gi;
                # Remove BRUN_TOP_FILES switch
                $test_run_script =~ s/BRUN\_TOP\_FILES(.)+\'//gi;
                # Perform macro substitution
                my $expanded_line = macro_define_substitution($test_run_script);
                # Remove ENV token
                $expanded_line = remove_env_token($expanded_line);
                # remove CDN_VIP_LIB_PATH
                $expanded_line = remove_cdn_vip_lib_path($expanded_line);
                # remove anything with $DIR as part of the arguments
                $expanded_line = remove_dollar_dir_path($expanded_line);
                # Project specific clean up - Remove any project specific defaults i.e. value that the makefile ignores - this just cleans things up a little.
                $expanded_line = project_specific_run_or_elab_clean($expanded_line);
                # Set current run script global for test list creation
                # Clean up runs of multiple whitespace
                $expanded_line =~ s/\s{2,}/ /g;
                $CURRENT_RUN_SCRIPT = $expanded_line;
                # Add comment to specify format of run script for the current group
                if($debug_mode eq "TRUE") {print("\nDEBUG - Pushing expanded run_script line into TEST_ARRAY = ", $expanded_line);}
                push @TEST_ARRAY, "\n# Run script format for current test group -: $expanded_line\n";
                next;
            }
        }
        # Convert group container into a comment to show the test clustering
        if ($Line =~ /(\s)*group(\s)+/) {
            # Reset group globals for seed and count
            $group_count_value = 1;
            $group_seed_value = "1";
            # Replace GENERATE_NAME with TESTS_GROUP_NAME
            $Line =~ s/GENERATE_NAME/TESTS_GROUP_NAME/;
            # Perform macro substitution
            my $expanded_line = macro_define_substitution($Line);
            # Remove ENV token
            $expanded_line = remove_env_token($expanded_line);
            # Push as a comment to the script via the TEST_ARRAY
            push @TEST_ARRAY, "\n# Test $expanded_line\n";
            next;
        }
        # Find and record group global seed 
        if ($Line =~ /^(\s)*seed(\s|\:)+/) {
            # Perform macro substitution
            my $expanded_line = macro_define_substitution($Line);
            my ($seed, $seed_value) = split(/:/,$expanded_line,2);
            # Remove whitespace and termination char (;)
            $seed_value =~ s/(\s)*//g;
            $seed_value =~ s/\;//g;
            chomp($seed_value);
            $group_seed_value = $seed_value;
            #push @TEST_ARRAY, "\n# DEBUG: Group seed value = \"$group_seed_value\"\n";
            next;
        }
        # Find and record group global count
        if ($Line =~ /^(\s)*count(\s|\:)+/) {
            # Perform macro substitution
            my $expanded_line = macro_define_substitution($Line);
            my ($count, $count_value) = split(/:/,$expanded_line,2);
            # Remove whitespace and termination char (;)
            $count_value =~ s/(\s)*//g;
            $count_value =~ s/\;//g;
            chomp($count_value);
            $group_count_value = $count_value;
            #push @TEST_ARRAY, "\n# DEBUG: Group count value = \"$group_count_value\"\n";
            if ($group_count_value eq "0") {
                push @TEST_ARRAY, "\n# Group count value = \"$group_count_value\" - thus the tests in this group are currently disabled.\n";
            }
            next;
        }
        # Convert each test into a test run for the script
        if ($Line =~ /(\s)*test(\s)+/ & $group_count_value eq "1") {
            if($debug_mode eq "TRUE") {print("\nDEBUG - Line = ", $Line);}
            # Perform macro substitution
            my $expanded_line = macro_define_substitution($Line);
            # Check to see value of count (if applicable)
            next if ($expanded_line =~ /count(\s)*:(\s)*0/i);
            # Get test name
            my ($test_name, $options) = split(/\{/,$expanded_line,2);
            $test_name =~ s/^(\s)*test(\s)*//;
            # Remove whitespace
            $test_name =~ s/(\s)*//g;
            chomp($test_name);
            # Get number of options for splitting/processing
            my $num_options = $options =~ tr/;//;
            my @OPTS = split(/;/,$options,$num_options);

            my $seed, $seed_value = "";
            my $top_files, $arg_value = "";
            my $run_script, $run_script_arg_value = "";
            foreach $option (@OPTS) {
                # Remove } chars
                $option =~ s/}//g;
                # Ignore count
                next if ($option =~ /count/i);
                # Get seed
                if ($option =~ /seed/i) {
                    ($seed, $seed_value) = split(/:/,$option,2);
                    # Remove whitespace and termination char (;)
                    $seed_value =~ s/(\s)*//g;
                    $seed_value =~ s/\;//g;
                    chomp($seed_value);
                }
                # Get args
                if ($option =~ /top_files/i) {
                    ($top_files, $arg_value) = split(/:/,$option,2);
                    # Remove whitespace
                    $arg_value =~ s/(\s)*//g;
                    $arg_value =~ s/\;//g;
                    chomp($arg_value);
                }
                # Get run_script inside test
                if ($option =~ /run_script/i) {
                    ($run_script, $run_script_arg_value) = split(/:/,$option,2);
                    # Remove $ATTR(run_script) which works like an append
                    $run_script_arg_value =~ s/\$ATTR\((\s)*run_script(\s)*\)//g;
                    # Remove whitespace
                    $run_script_arg_value =~ s/(\s)*//g;
                    $run_script_arg_value =~ s/\;//g;
                    chomp($run_script_arg_value);
                }
            }

            # Get the run script command and replace the following:
            # $BRUN_SEED with seed or $ATTR(seed) with seed
            # $BRUN_TEST_NAME with test name or $ATTR(test_name) with test_name
            # Add ARGS= if needed.
            my $test_run_command = $CURRENT_RUN_SCRIPT;
            $test_run_command =~ s/\$BRUN_TEST_NAME/$test_name/g;
            $test_run_command =~ s/\$ATTR\(test_name\)/$test_name/g;
            # If the seed value is not set in the test but set globally in the group then use the global value.
            if ($seed_value eq "") {
                $seed_value = $group_seed_value;
            }
            $test_run_command =~ s/\$BRUN_SEED/$seed_value/g;
            $test_run_command =~ s/\$ATTR\(seed\)/$seed_value/g;
            # Append ARGS if needed.
            if ($arg_value ne "") {
                $test_run_command =~ s/$/ ARGS=$arg_value/;
            }
            # Append run_script ARGS if needed.
            if ($run_script_arg_value ne "") {
                $test_run_command =~ s/$/ $run_script_arg_value/;
            }
            chomp($test_run_command);
            # Clean up runs of multiple whitespace
            $test_run_command =~ s/\s{2,}/ /g;
            # Push test command into results file via echo
            push @TEST_ARRAY, "\necho \"TEST RUN: $test_run_command\" >> $REGRESSION_RESULTS_FILE_NAME\n";
            # Add the ability to tee out std out for log checking (trying to be simulator independant)
            $test_run_command =~ s/$/ | tee sim_file.log/;
            # Push finished command to test array.
            push @TEST_ARRAY, "\n$test_run_command\n";
            # Add something to determine pass or fail.
            push @TEST_ARRAY, "$CHECK_FOR_PASS_SCRIPT sim_file.log >> $REGRESSION_RESULTS_FILE_NAME\n";
            next;
        }

        #print $Line;
    }
    close ($VSIF_HANDLE) or die "Cannot close $vsif!\n";
    return;
}

# Function to process command line options
sub process_command_switch($) {

    my ($Switch) = @_;
    
    my $ValidSwitch = FALSE;
    
    if ($Switch =~ /^(-)+help$/o ) {
        $ValidSwitch = TRUE;
        print "-----------------------------------------------------------------\n"; 
        print "-                     $TOOL_NAME help\n"; 
        print "-----------------------------------------------------------------\n"; 
        print "Command line switches:\n"; 
        print " -help           This help screen.\n"; 
        print " -ver            Displays the version number of $TOOL_NAME.\n";
        print " -about          Displays the information about $TOOL_NAME.\n";
        print " -vm_path=<VM_PATH> Used to specify the vm path when running from elsewhere.\n";
        print " -d              Debug mode. Prints out the parsing info.\n";
        print "-----------------------------------------------------------------\n"; 
        print "\n";
        exit;
    }
    if ($Switch =~ /^(-)+about$/o ) {
        $ValidSwitch = TRUE;
        print "$TOOL_NAME was written by $AUTHOR_NAME.\n";
    }
    
    if ($Switch =~ /^(-)+ver$/o ) {
        $ValidSwitch = TRUE;
        print "Version $VERSION_NUMBER of $TOOL_NAME written by $AUTHOR_NAME.\n";
    }
    if ($Switch =~ /^(-)+vm_path=/o ) {
        $ValidSwitch = TRUE;
        my ($opt, $value) = split(/=/,$Switch,2);
        chomp($value);
        $VSIF_PATH = $value;
        print "Setting VSIF_PATH to $VSIF_PATH based on command line input via switch vm_path.\n";
    }
    if ($Switch =~ /^(-)+d$/o ) {
        $ValidSwitch = TRUE;
        print "Enabling Debug Mode.\n";
        $debug_mode = "TRUE";
    }
    if ($ValidSwitch eq FALSE) {
        print "ERROR: Invalid command switch detected \"$Switch\".\n";
    }
    
    return;
}








