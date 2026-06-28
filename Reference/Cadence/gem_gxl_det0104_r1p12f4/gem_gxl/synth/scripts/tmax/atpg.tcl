# Command script for Automatic Test Pattern Generation
#-------------------------------------------------------------------------------
# File                : atpg.tcl
# Purpose             : ATPG flow pipecleaning for strictly internal use, only 
# Developed with Tool : Synopsys Tmax J-2014.09-SP2
# Author	      : Vladimir Zivkovic, Livingston, UK
#-------------------------------------------------------------------------------

###########################################################################################
## The following tasks are performed:                                                     #
# - global settings                                                                       #
# - read_design and libraries:	Reads and build design                                    #
# - build models:		Build test model					  #
# - create patterns : 		Create ATPG patterns					  #
# - handoff_design:	Write result to verilog, db, and test model files             	  #
#                                                                                         #
# The user is expected to specify design dependent DfT settings, such as clocks, resets,  #
#  test control blocks , etc.                                                             #
###########################################################################################

puts "Hostname : [info hostname]"

# Create link to RDF setup_project.csh
if {![file exists "./setup_project.csh"]} {
  if [file exists "$env(IPF_DESIGN_FLOW_SCRIPTS)/setup_project.csh"] {
    exec ln -s $env(IPF_DESIGN_FLOW_SCRIPTS)/setup_project.csh .
  } elseif [file exists "$env(DUT_PATH)/setup_project.csh"] {
    exec ln -s $env(DUT_PATH)/setup_project.csh .
  } else {
      puts "ERROR:Can't find setup_project.csh in current working directory or in '$env(DUT_PATH)'."
      exit
  }    
}

# Read project.tcl from current directory if it exists, otherwise look for it in $DUT_PATH
if [file exists "$env(IPF_DESIGN_FLOW_SCRIPTS)/project.tcl"] {
    puts "Sourcing $env(IPF_DESIGN_FLOW_SCRIPTS)/project.tcl ..."
    source $env(IPF_DESIGN_FLOW_SCRIPTS)/project.tcl
} elseif [file exists "$env(DUT_PATH)/project.tcl"] {
    puts "Sourcing $env(DUT_PATH)/project.tcl ..."
    source $env(DUT_PATH)/project.tcl
} else {
    puts "ERROR:Can't find project.tcl in current working directory or in '$env(DUT_PATH)'."
    exit
}
puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
puts "  RDF SVN Revision Info: $RDF_SVN_INFO"

#source $IPF_DESIGN_FLOW_SCRIPTS/project.tcl
puts $TMAX_ROOT


#Global settings:
set commands noabort                                                           

#$NETLIST_PATH is the variable to point to the netlist that need to be checked against the integrity
# within Tetramax. It should be typically taken from the delivery area, not from the project area.
set NETLIST_PATH  < set path to the physical netlist from the release area>

  set USER_topmodule  <specify the top level design module>

# Initialize scan chain insertion procedure
# PROC_dft_insert_init
	# Enable dft_drc
    global test_enable_dft_drc
    set test_enable_dft_drc  true
    set hdlin_enable_rtldrc_info true
 
# read_design

# Enable clock gating
    set clock_gate true

# Specify input and output paths

   set MappedVerilogNetlists [list ${NETLIST_PATH}/${USER_topmodule}.v \
   			${NETLIST_PATH}/<list here any other verilog netlist modules from the release area> \
			]
			
   set OUT_DCDatabase $TMAX_ROOT/ddb/${USER_topmodule}.ddc
   set REPORTS_DIR $TMAX_ROOT/rpt
   set RESULTS_DIR $TMAX_ROOT/results

#-------------------------------------------------------------------------------
# Load Library information
#-------------------------------------------------------------------------------

if ![file exists .synopsys_dc.setup ] {
   puts "##########################SCRIPT WARNING########################"
   puts "Loading WC library setup because .synopsys_dc.setup link not set"
   puts "##########################SCRIPT WARNING########################"
#   source ./src/dc_SynopsysSetup.tcl
   }
puts ${search_path}
#puts ${target_library}
#puts ${link_library}
#-------------------------------------------------------------------------------
# Globals Set-up                                                        
#-------------------------------------------------------------------------------

source ./src/tmax_Setup.tcl

# These settings allow more flexible use of fault lists.
#set_faults -summary verbose -noequiv_code

#If you have modules with no TMAX models, add them to the variable definition in tmax_setup.tcl.
# The -empty_box switch may be better if tristate buses are involved.
if { $MODULES_TO_BLACK_BOX != "" } {
   foreach module $MODULES_TO_BLACK_BOX {
      set_build -black_box $module
   }
}

if { $INSTANCES_TO_BLACK_BOX != "" } {
   foreach module $INSTANCES_TO_BLACK_BOX {
      set_build -empty_box $module
   }
}

# Load the library of the non-faulted elements.
#  read_netlist $VFILE
foreach tmax_library_files $ATPGLIB {
   read_netlist $tmax_library_files -library
}

#-------------------------------------------------------------------------------
# Load the Design
#-------------------------------------------------------------------------------

#Read the netlist
  foreach module ${MappedVerilogNetlists} {
    read_netlist $module
  }

#Read other modules
  foreach module $BEHAVIORAL_MODULES {
    read_netlist $module
   } 

# Build the model
  
  run_build_model $USER_topmodule

##################################################################
#    SA_ATPG: Create Patterns for Stuck-At Fault Test            #
##################################################################

drc -force
remove_atpg_constraints -all
remove_capture_masks -all
remove_cell_constraints -all
remove_clocks -all
remove_compressors -all
remove_pi_constraints -all
remove_po_masks -all
remove_scan_chains -all
remove_scan_enables -all
remove_slow_bidis -all
remove_slow_cells -all

set_faults -model stuck
add_slow_bidis -all

###################################################################
#  Constraints on the primary pins				  #
###################################################################
#Normally scan enables and test mode signals need following constraints when testing stuck-at faults.

#test constraints in the separate files
source ./src/pinassign_chains.tcl
source ./src/test_control_signals.tcl
source ./src/test_clocks.tcl

#set_drc -nodslave_remodel -noreclassify_invalid_dslaves
 set_simulation -shift_cycles 1
 set_drc -load_nonscan_cells
write_drc ./rpt/test.spf -replace
run_drc ./rpt/test.spf

report_scan_chains


system "gunzip -c ${RESULTS_DIR}/${USER_topmodule}_trans_post.faults.gz | sed 's/^str/sa0/' | sed 's/^stf/sa1/' | gzip > ${RESULTS_DIR}/${USER_topmodule}_stuck_pre.faults.gz"
read_faults ${RESULTS_DIR}/${USER_topmodule}_stuck_pre.faults.gz -retain_code
#reset_au_faults
report_summaries faults

if { ${SA_CAPTURE_CYCLES} != ""} {
   set_atpg -capture_cycles ${SA_CAPTURE_CYCLES}
} else {
   set_atpg -capture_cycles 4
}
# Uncomment to save shift power at expense of pattern count.
#set_atpg -fill adjacent
# Uncomment and modify to control the chain test pattern.
#set_atpg -chain_test 00101C

run_atpg -auto

write_patterns ${RESULTS_DIR}/${USER_topmodule}_stuck.bin.gz -format binary -replace -compress gzip
write_patterns ${RESULTS_DIR}/${USER_topmodule}_stuck_ser.stil99.gz -format stil99 -serial -replace -compress gzip
write_patterns ${RESULTS_DIR}/${USER_topmodule}_stuck_par.stil99.gz -format stil99 -parallel -replace -compress gzip
write_faults ${RESULTS_DIR}/${USER_topmodule}_stuck_post.faults.gz -all -replace -compress gzip

report_clocks -verbose > ${REPORTS_DIR}/${USER_topmodule}_stuck_clocks.rpt
report_patterns -all -types > ${REPORTS_DIR}/${USER_topmodule}_stuck_pat_types.rpt
report_summaries faults patterns cpu mem > ${REPORTS_DIR}/${USER_topmodule}_stuck_summaries.rpt

##################################################################
#    End of TetraMAX RM main script                              #
##################################################################

exit -force

