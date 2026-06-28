#------------------------------------------------------------------------------
#                                     
#            CADENCE                    Copyright (c) 2002-2015
#                                       Cadence Design Systems, Inc.
#                                       All rights reserved.
#
#  This work may not be copied, modified, re-published, uploaded, executed, or
#  distributed in any way, in any medium, whether in whole or in part, without
#  prior written permission from Cadence Design Systems, Inc.
#------------------------------------------------------------------------------
#
#    Primary Unit Name :      run_joules.tcl
#
#          Description :      Joules RTL Power Analysis Script
#
#      Original Author :      Patrick McKeever
#
#------------------------------------------------------------------------------
# Read project.tcl from current directory if it exists, otherwise look for it in $DUT_PATH
  if [file exists "./project.tcl"] {
     puts "Sourcing ./project.tcl ..."
     source ./project.tcl
  } else {
     puts "ERROR: Can't find project.tcl in current working directory."
     exit
  }
puts "RTL Design Flow Version: $RTLDesignFlow_VERSION"
puts "  RDF SVN Revision Info: $RDF_SVN_INFO"


###############################################################
## Create Output Directories
###############################################################
if {![file exists ${_JOULES_DATA_PATH}]} {
   file mkdir ${_JOULES_DATA_PATH}/rtl
   puts "Creating directory ${_JOULES_DATA_PATH}/rtl"
}

if {![file exists ${_JOULES_RPT_PATH}]} {
   file mkdir ${_JOULES_RPT_PATH}/rtl
   puts "Creating directory ${_JOULES_RPT_PATH}/rtl"
}

###############################################################
## Library setup
###############################################################

#set_attribute script_search_path <path> /
if [info exists HDL_SEARCH_PATH] {
   set_attribute hdl_search_path $HDL_SEARCH_PATH /
}


set_attribute information_level 9 /
set_attribute auto_super_thread false
# applet: timing and slack histograms
applet load report_histogram
# applet load report_timing_histogram

####################################################################
# Read in CPF Library Info
####################################################################
#set_attribute lib_search_path "$LIBLIB"
#create_library_domain {WC TYP BC}

# Read in library
read_libs $EDI_SLOWLIB -domain WC
read_libs $EDI_FASTLIB -domain BC
read_libs $EDI_TYPLIB -domain TYP


#Add 'HOT' TYP library for power analysis
if {$TYP_85C_CORNER} {
	if [regsub -all "25c" $TYPLIB "85c" TYPLIB_85c] {
		set HOTLIB 1
		read_libs $TYPLIB_85c -domain TYP_85C
		} else {
	      	set HOTLIB 0
	   	}
}
#set_attribute power_library TYP WC

set_attr default true WC

set_attribute lef_library "$LIBLEF" /

set_attribute qrc_tech_file $WC_QRC_TECH /

set_attribute interconnect_mode ple /

################################################################
# Select VT Library, Set Dont Use and Force Use (multibit cells)
################################################################
if [info exists LEAKAGE_LIB] {
if {$LEAKAGE_LIB == "LOW"} then {
	if {$PROCNODE == "16"||$PROCNODE == "10"} then {
		set_attribute avoid true [find . -libcell *LVT*]
		set_attribute avoid true [find . -libcell *ULVT*]
	}  else {
		set_attribute avoid true [find . -libcell *]
		set_attribute avoid false [find / -libcell *HVT* ] 
		}
} else { if {$LEAKAGE_LIB == "MID"} then {
		if {$PROCNODE == "16"||$PROCNODE == "10"} then {
		set_attribute avoid true [find . -libcell *ULVT*]
			}  else {
		set_attribute avoid true [find . -libcell *LVT*]
			} 
		}
	}
}


foreach cset $DONT_USE {
   set cells [find / -libcell $cset]
   if { [llength $cells] > 0 } {
      set_attribute avoid true $cells
   } else {
      puts "Dont Use $cset is not in library"
   }
}


if [info exists FORCE_USE] {
foreach cset $FORCE_USE {
   set cells [find / -libcell $cset]
   if { [llength $cells] > 0 } {
      set_attribute avoid false $cells
   } else {
      puts "Force Use $cset is not in library"
   }
}
}

###############################################################
## HDL Library setup
###############################################################
#set_attribute script_search_path <path> /
if [info exists HDL_SEARCH_PATH] {
   set_attribute hdl_search_path $HDL_SEARCH_PATH /
}


####################################################################
## Load Design
####################################################################

# If the parameters are coming from a .f file then parse the .f
# file to get a list of parameters
set PARAMETERS    ""
set VDEFINES    ""
set INCDIRS    ""
set CONFIGURATION ""

## Read in $DESIGN.f list of RTL files (may be Verilog, SV or VHDL)
set files_vh ""
set files_vl ""
set files_sv ""
set list_file [open $RTL_F_FILE RDONLY]
set buffer [read -nonewline $list_file]
foreach entry $buffer {
   regsub -all {\$([0-9a-zA-Z_]*)(\/.*)} $entry {$::env(\1)\2} myline
   set entry [subst -nocommand -nobackslashes $myline]
   
   if { [ regexp {\+define\+} $entry ] } {
      puts "DEFINE $entry"
      set p_name [regsub -- {(\+define\+)([A-Z_0-9]*)=[0-9]*} $entry {\2}]
      set p_value [regsub -- {(\+define\+)[A-Z_0-9]*=([0-9]*)} $entry {\3}]
      lappend VDEFINES " $p_name " 
# OR set hdl_verilog_defines attribute           
   } elseif { [ regexp {\+incdir\+} $entry ] } {
      puts "INCDIR $entry"
      set incdir_name [regsub -- {(\+incdir\+)(.*)} $entry {\2}]
      lappend INCDIRS " $incdir_name "     
   } elseif { [ regexp {\.vhdl?$} $entry ] } {
      set files_vh "$files_vh $entry"
   } else {
      if { [ regexp {\.svh?$} $entry ] } {
         set files_sv "$files_sv $entry"
      } else {
         set files_vl "$files_vl $entry"
      }
   }
}
close $list_file

#set_attribute script_search_path <path> /
if [info exists HDL_SEARCH_PATH] {
  lappend $HDL_SEARCH_PATH "$INCDIRS"
}


if [info exists HDL_SEARCH_PATH] {
   set_attribute hdl_search_path $HDL_SEARCH_PATH /
}

# Read VHDL files
if { $files_vh != "" } {
   echo $files_vh
   read_hdl -vhdl $files_vh
}

# Read Verilog files
if { $files_vl != "" } {
   # If the defines are in a .v file then prepend the defines file to the
   # verilog list, otherwise set the parameters on the command line.
   if { ${VDEFINES} == "" } {
      echo $files_vl
      read_hdl -define RTL_BEHV -define NO_SVA -v2001 $files_vl
   } else {
      echo $files_vl
      read_hdl -define RTL_BEHV -define NO_SVA -define ${VDEFINES} -v2001 $files_vl
   }
}

# Read System Verilog files
if { $files_sv != "" } {
   echo $files_sv
   read_hdl -define RTL_BEHV -sv $files_sv
}


####################################################################
# Read power intent pre elaboration
####################################################################
if [file exists $POWER_INTENT_FILE] {
if { [ regexp {\.cpf?$} ${POWER_INTENT_FILE} ] } {
read_power_intent -module ${DESIGN} -cpf ${POWER_INTENT_FILE}
} else {
read_power_intent -module ${DESIGN} -1801 ${POWER_INTENT_FILE}
}
}


####################################################################
# Elaborate and check signals/black boxes
####################################################################

if {$PARAMETERS == ""} {
   elaborate ${DESIGN}
} else {
   elaborate -parameters ${PARAMETERS} ${DESIGN}
}


####################################################################
# Apply power intent post elaboration
####################################################################
if [file exists $POWER_INTENT_FILE] {
apply_power_intent
}


# save elab DB
write_db -all -to_file $_JOULES_DATA_PATH/rtl/${DESIGN}_elab.db

##############################
# Read SDC and mode creation
###############################
create_mode -name "$DESIGN_MODES" -design $DESIGN

foreach mode $DESIGN_MODES {
	if {[info exists CONFIG] && ($CONFIG != "") } {
	read_sdc -stop_on_errors -mode ${mode} $SDC_PATH/${DESIGN}_$CONFIG.$mode.sdc
	} else {
	read_sdc -stop_on_errors -mode ${mode} $SDC_PATH/${DESIGN}.$mode.sdc
	}
}


####################################################################
# Commit CPF 
####################################################################
if [file exists $POWER_INTENT_FILE] {
commit_power_intent
}

report timing -lint > $_JOULES_RPT_PATH/rtl/${DESIGN}_check_timing.rpt


#-------------------------------------------------------------------------------
# Turn on TNS, affects global and incr opto (doesn't do much w/ global map)
#-------------------------------------------------------------------------------
set_attribute tns_opto true /
set_attribute lp_insert_clock_gating true /
set_attribute lp_clock_gating_min_flops  2 /$DESIGN
set_attribute lp_clock_gating_max_flops  6 /$DESIGN ;# try 6|9|12|18

# turn off sequential merging
set_attribute optimize_merge_flops false /
set_attribute optimize_merge_latches false /


#-------------------------------------------------------------------------------
# Synthesize to Generic Gates
#-------------------------------------------------------------------------------
puts stdout "synthesize -to_generic -effort $SYN_EFF"
synthesize -to_generic -effort $SYN_EFF
puts "Runtime & Memory after 'synthesize -to_generic'"
timestat GENERIC


report datapath > $_JOULES_RPT_PATH/rtl/${DESIGN}_datapath_generic.rpt
generate_reports -outdir $_JOULES_RPT_PATH/rtl -tag generic
summary_table -outdir $_JOULES_RPT_PATH/rtl


#-------------------------------------------------------------------------------
# Synthesizing to Gates
#-------------------------------------------------------------------------------
# Add '-auto_identify_shift_registers' to 'synthesize -to_map' to automatically 
# identify functional shift register segments.

# set_attribute dump_stack_trace 10 /
synthesize -to_proto -effort $SYN_EFF  ;

# save proto db
write_db -all -to_file $_JOULES_DATA_PATH/rtl/${DESIGN}_proto.db


#foreach cg [find / -cost_group *] {
#    set bname [basename $cg]
#    set f_rpt $_JOULES_DATA_PATH/rtl/${DESIGN}_${bname}_post_map.rpt
#    report timing -cost_group [list $cg] > $f_rpt
#}


#-------------------------------------------------------------------------------
# Clock Tree
#-------------------------------------------------------------------------------

if {$JLS_CLOCK} {
set root_fanout 3 ; set branch_fanout 3 ; set leaf_fanout 4

gen_clock_tree -name CT1 \
    -fanout root=$root_fanout branch=$branch_fanout leaf=$leaf_fanout \
    -root_buffers $CLK_BUFFERS -branch_buffers $CLK_BUFFERS -leaf_buffers $CLK_BUFFERS \
    -max_tree_depth 5

report_clock_tree -name CT1 -out $_JOULES_RPT_PATH/rtl/clk.rpt
}


#-------------------------------------------------------------------------------
# Read Stimulus 
#-------------------------------------------------------------------------------
if { [info exists VCD_FILE] && ($VCD_FILE != "") } { 

	if [info exists FRAME_COUNT] {
		read_stimulus -file $VCD_FILE -frame_count $FRAME_COUNT -top_instance ${ACTIVITY_DUT}
	}

	if [info exists VCD_TIMESTAMPS] {
		read_stimulus -file $VCD_FILE -interval_list $VCD_TIMESTAMPS -top_instance ${ACTIVITY_DUT}
	}
	
write_sdb -out  $_JOULES_DATA_PATH/rtl/${DESIGN}_vcd.sdb

    	foreach corner [get_lib_domains] { 
    		set_attr power_library [find /libraries -library_domain $corner] [find /libraries -library_domain WC]
    		set_attr default true [find /libraries -library_domain WC]
    		rtls_init
		plot_power_profile -unit $POWER_UNIT -png $_JOULES_RPT_PATH/rtl/vcd_power_plot_$corner.png
    		compute_power -out  $_JOULES_RPT_PATH/rtl/vcd_compute_power_$corner.rpt
    		report_power  -by_hierarchy -levels 1 -sort_by total -out $_JOULES_RPT_PATH/rtl/vcd_report_power_$corner.rpt -unit $POWER_UNIT
		foreach frame [get_sdb_frames] {
		report_power -frames $frame -by_hierarchy -levels 1 -sort_by total -append -out $_JOULES_RPT_PATH/rtl/vcd_report_power_$corner.rpt -unit $POWER_UNIT
		}
	} 
}



set first_file 1
if { [ file exists ${RTL_TOGGLE_FILE_DIR} ] } {
  puts "\n Processing toggle files\n"
  foreach power_state $POWER_STATES {
    set tcf_files  [glob -nocomplain ${RTL_TOGGLE_FILE_DIR}/*${power_state}*/*.tcf] 
    set saif_files [glob -nocomplain ${RTL_TOGGLE_FILE_DIR}/*${power_state}*/*.saif] 
    regsub -all {[\[\]\*\?]} $power_state {} power_state_clean
    if { ${tcf_files} != "" } {
      foreach tcf_file ${tcf_files} {
        if { $first_file == 1 } {
          # if its the first file of the group clear the old numbers
          eval read_stimulus -file ${tcf_file} -top_instance ${ACTIVITY_DUT}
          set first_file 0
        } else {
          eval read_stimulus -file -append ${tcf_file} -top_instance ${ACTIVITY_DUT}
        }
      }
    } elseif { ${saif_files} != "" } {
      foreach saif_file ${saif_files} {
        if { $first_file == 1 } {
          # if its the first file of the group clear the old numbers
          eval read_stimulus -file ${saif_file} -top_instance ${ACTIVITY_DUT}
          set first_file 0
        } else {
          eval read_stimulus -file -append ${saif_file} -top_instance ${ACTIVITY_DUT}
        }
      }
    } else {
      puts "\nError: no toggle files in ${RTL_TOGGLE_FILE_DIR}"
      exit 1
    }
    puts "Generating report for power state ${power_state_clean}"
    #######################################################    
    # Produce Power reports in BC/TYP/WC corners
    #######################################################   
    write_sdb -out  $_JOULES_DATA_PATH/rtl/${DESIGN}_${power_state_clean}.sdb
      
	foreach corner [get_lib_domains] { 
    		set_attr power_library [find /libraries -library_domain $corner] [find /libraries -library_domain WC]
    		set_attr default true [find /libraries -library_domain WC]
    		rtls_init
    		compute_power -out  $_JOULES_RPT_PATH/rtl/compute_power_${power_state_clean}_$corner.rpt
    		report_power  -by_hierarchy -levels 1 -sort_by total -out $_JOULES_RPT_PATH/rtl/power_${power_state_clean}_$corner.rpt -unit $POWER_UNIT
		foreach stim [get_sdb_stims] {
		report_power -stim $stim -by_hierarchy -levels 1 -sort_by total -append -out $_JOULES_RPT_PATH/rtl/power_${power_state_clean}_$corner.rpt -unit $POWER_UNIT
		}
	} 
    set first_file 1
  }
} else {
  puts "\n ERROR: Toggle directory not found - $RTL_TOGGLE_FILE_DIR \n"
  exit 1
}


  


#-------------------------------------------------------------------------------
# Report
#-------------------------------------------------------------------------------

report_activity  -out $_JOULES_RPT_PATH/rtl/activity.rpt
report_ppa	 -out $_JOULES_RPT_PATH/rtl/ppa.rpt 
#report_power	 -out $_JOULES_RPT_PATH/rtl/power.rpt -append
#plot_power_profile -frame {/stim#1/frame#[1:47]} -category memory register logic clock
#plot_power_profile -frame {/stim#2/frame#[1:33]} -category memory register logic clock
report_icgc_efficiency -out $_JOULES_RPT_PATH/rtl/icgc_efficiency.rpt 



#-------------------------------------------------------------------------------
# voltus_compare
#-------------------------------------------------------------------------------

#if { $voltus_compare } {
#    if { [catch { exec which $voltus_exe } err_msg] } {
#        puts stdout "$err_msg"
#        puts stdout "'${voltus_exe}' executable not found!"
#        set voltus_compare 0
#    }
#}
#if { $voltus_compare } {
#    foreach stim [get_sdb_stims] {
#        set f_stim [get_stim_info $stim -src_file]
#        set bname [lindex [split [file tail $f_stim] "."] 0]
#        voltus_compare -stim $stim -bname $bname -generate script -pin_dir out
#        voltus_compare -stim $stim -bname $bname -generate data
#        exec $voltus_exe -64 -nowin -init voltus_work/${bname}_run_voltus.tcl
#        voltus_compare -bname $bname -plot both
#        voltus_compare -bname $bname -compute_stats
#    }
#}


exit
