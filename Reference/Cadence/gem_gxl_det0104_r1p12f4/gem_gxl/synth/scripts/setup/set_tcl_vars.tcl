###############################################################################
# Extract the environment form the setup_project.csh
###############################################################################

if [file exists "./setup_project.csh"] {
   set csh_file ./setup_project.csh
} elseif [file exists "$env(DUT_PATH)/setup_project.csh"] {
   set csh_file $env(DUT_PATH)/setup_project.csh
} else {
   puts "ERROR: Can't find setup_project.csh in current working directory or in '$env(DUT_PATH)'."
   exit 1
}
#puts "\nExtracting envronment from $csh_file\n" 
set cshfh [open $csh_file r]
while {[gets $cshfh line] >= 0} {
  if [regexp {^\s*setenv\s+(\w+)\s+.*} $line all_line env_name ] {
    if [info exists env($env_name)] {
      set new_env_name "${env_name}"
      set ${new_env_name} "$env($env_name)"
#      puts "\tSetting ${new_env_name} to \{$env($env_name)\}"
    } else {
      puts "\nEnvironment ERROR: $env_name missing, Check setup_project.csh\n"
      exit 1
    }
  }
}
close $cshfh
unset new_env_name
unset env_name
#puts "Extraction complete\n"


# Check a few key variables have been set

# Set DESIGN to the top level name of the target design
#set DESIGN "$env(DESIGN)"
set key_env_list [ list CONFIG \
                        DUT_PATH \
                        RTL_PATH \
                        SDC_PATH \
                        IPF_DESIGN_FLOW_SCRIPTS \
                        RTLDesignFlow_VERSION \
                        RDF_SVN_INFO \
                 ]
              
foreach key_var $key_env_list {
  if (![info exists $key_var]) {
    puts "Environment ERROR: Please set $key_var\n"
    exit 1
  }
}

#puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
#puts "  RDF SVN Revision Info: $RDF_SVN_INFO"
