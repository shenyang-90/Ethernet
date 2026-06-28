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
#    Primary Unit Name :      rc_power.tcl
#
#          Description :      RC power analysis script using toggle file
#
#      Original Author :      Colin Scott
#
#------------------------------------------------------------------------------

#### Gate level power analysis using TCF file

puts "Hostname : [info hostname]"

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

if {$APPLET} {
set_attri applet_mode remote /
applet load  measure_snapshot
} 

#Super Threading
if {$THREADING} {
set_attribute super_thread_servers 		      {batch batch} 
set_attribute super_thread_batch_command $LSF 
set_attribute super_thread_kill_command {bkill}
} 

# Global attributes
set_attribute hdl_language v2001 /
set_attribute information_level                        9

if {$BLACK_BOX} {
    set_attribute hdl_error_on_blackbox false
} else {
    set_attribute hdl_error_on_blackbox true
}



# LPS attributes
set_attribute hdl_track_filename_row_col	       true
set_attribute lp_power_unit 		               $POWER_UNIT

###############################################################
## Message Suppression
###############################################################

# These are the default message suppresions. If further message
# suppression is needed then this can be added to project.tcl
# file.

# Warning : Using default parameter value for module elaboration. [CDFG-818]
suppress_messages CDFG-818
# Warning : Removing unused register. [CDFG-508]
suppress_messages CDFG-508
# Warning : Cannot set probability or toggle rate on a constant net. [TUI-92]
suppress_messages TUI-92
# Warning : Unusable clock gating integrated cell. [LBR-101]
suppress_messages LBR-101
# Warning : Multiply-defined library cell. [LBR-22]
suppress_messages LBR-22
# Warning : Site already defined before, duplicated site will be ignored. [PHYS-106]
suppress_messages PHYS-106
# Warning : Macro already defined before, the previous macro will be overridden. [PHYS-107]
suppress_messages PHYS-107
# Warning : Data from existing 'cap_table_file' is overwritten by technology file. [PHYS-601]
suppress_messages PHYS-601
# Warning : Routing layers are defined in previous LEF file already. [PHYS-109]
suppress_messages PHYS-109
# Warning : The variant range of wire parameters is too large. [PHYS-12]
suppress_messages PHYS-12
# Warning : MASTERSLICE layer found after ROUTING or CUT layer. [PHYS-120]
suppress_messages PHYS-120
# Warning : Wire parameter is missing. [PHYS-15]
suppress_messages PHYS-15

## Limit messages from library to max count of 5 for each type
##  Improperly defined 'leakage_power' group. [LBR-150]
set_attribute max_print 5 /messages/*/LBR-150
##  An unsupported construct was detected in this library. [LBR-40]
set_attribute max_print 5 /messages/*/LBR-40
##  Found 'statetable' group in cell. [LBR-83]
set_attribute max_print 5 /messages/*/LBR-83
##  An output library pin lacks a function attribute. [LBR-41]
set_attribute max_print 5 /messages/*/LBR-41
##  Ignoring specified timing sense. [LBR-170]
set_attribute max_print 5 /messages/*/LBR-170
##  Both 'pos_unate' and 'neg_unate' timing_sense arcs have been processed. [LBR-162]
set_attribute max_print 5 /messages/*/LBR-162
##  Mismatch in unateness between 'timing_sense' attribute and the function. [LBR-155]
set_attribute max_print 5 /messages/*/LBR-155
##  Detected an unsupported timing arc type. [LBR-72]
set_attribute max_print 5 /messages/*/LBR-72
##  Promoting a setup arc to recovery. [LBR-30]
set_attribute max_print 5 /messages/*/LBR-30
##  Promoting a hold arc to removal. [LBR-31]
set_attribute max_print 5 /messages/*/LBR-31

###############################################################
## Create Output Directories
###############################################################
if {![file exists ${_PWR_RPTS_PATH}]} {
   file mkdir ${_PWR_RPTS_PATH}
   puts "Creating directory ${_PWR_RPTS_PATH}"
}


####################################################################
## Library setup
####################################################################
#set_attribute lib_search_path "$LIBLIB"
create_library_domain {WC BC TYP}
set domains {WC BC TYP}

# Read in library
# Optimise for timing in WC corner and power in BC corner
set_attribute library $EDI_SLOWLIB [find /libraries -library_domain WC]
set_attribute library $EDI_TYPLIB [find /libraries -library_domain TYP]
set_attribute library $EDI_FASTLIB [find /libraries -library_domain BC]

# Add 85C TYP library for power analysis
if {$TYP_85C_CORNER} {
   if [regsub -all "25c" $EDI_TYPLIB "85c" EDI_TYPLIB_85c] {
       set HOTLIB 1
       create_library_domain {TYP_85C}
       lappend domains TYP_85C
       set_attribute library $EDI_TYPLIB_85c [find /libraries -library_domain TYP_85C]
   } else {
       set HOTLIB 0
   }
}

set_attribute power_library TYP WC

set_attribute default true WC

## PLE
set_attribute lef_library "$LIBLEF" /
set_attribute qrc_tech_file $WC_QRC_TECH /

set_attribute interconnect_mode ple /

####################################################################
## Load Design
####################################################################
# Read and elaborate netlist
read_netlist ${NL_FOR_POWER_ANALYSIS}

####################################################################
# $DESIGN will be different as a result of elaboration with parameter
####################################################################
set DESIGN_FULL [basename [find / -design ${DESIGN}*]]


####################################################################
# Read in Power Intent 
####################################################################
if [info exists POWER_INTENT_FILE] {
if { [ regexp {\.cpf?$} ${POWER_INTENT_FILE} ] } {
read_power_intent -module ${DESIGN} -cpf ${POWER_INTENT_FILE}
} else {
read_power_intent -module ${DESIGN} -1801 ${POWER_INTENT_FILE}
}

verify_power_structure -all -detail -pre_synthesis > $_PWR_RPTS_PATH/${DESIGN}_verify_power_structure.rpt
}


####################################################################
## Constraints setup and mode creation
####################################################################

create_mode -name "$DESIGN_MODES" -design $DESIGN_FULL

foreach mode $DESIGN_MODES {
	if {[info exists CONFIG] && ($CONFIG != "") } {
	read_sdc -stop_on_errors -mode ${mode} $SDC_PATH/${DESIGN}_$CONFIG.$mode.sdc
	} else {
	read_sdc -stop_on_errors -mode ${mode} $SDC_PATH/${DESIGN}.$mode.sdc
	}
}


#######################################################
# Power Analysis and Reporting
#######################################################
set first_file 1
if { [ file exists ${NL_TOGGLE_FILE_DIR} ] } {
  puts "\n Processing toggle files\n"
  foreach power_state $POWER_STATES {
    set tcf_files  [glob -nocomplain ${NL_TOGGLE_FILE_DIR}/*${power_state}*/*.tcf] 
    set saif_files [glob -nocomplain ${NL_TOGGLE_FILE_DIR}/*${power_state}*/*.saif] 
    set_attr lp_default_toggle_rate 0.02 $DESIGN_FULL
    set_attr lp_default_probability 0.50 $DESIGN_FULL   
    regsub -all {[\[\]\*\?]} $power_state {} power_state_clean
    if { ${tcf_files} != "" } {
      set max_sample_time  0
      foreach tcf_file ${tcf_files} {
        # extract the mesurment period, output later into the power report
        set f [open ${tcf_file} r]
        puts "${tcf_file}"
        while { [gets ${f} line] } {
          if {[regexp {duration\s*:\s*\"([0-9.]+)} $line dummy sample_time]} {
            if {$sample_time > $max_sample_time } {
              set max_sample_time  $sample_time
            }
            break
          }
        }
        close $f
        if { $first_file == 1 } {
          # if its the first file of the group clear the old numbers
          read_tcf ${tcf_file}
          set first_file 0
        } else {
          read_tcf -update ${tcf_file}
        }
      }
      # time is in fs make it ms
      set max_sample_time [expr $max_sample_time/1000000000]
      set f [open ${_PWR_RPTS_PATH}/${DESIGN}_${power_state_clean}.nl.power.rpt w]
      puts $f "\nMeasurement interval for ${power_state_clean} is ${max_sample_time}ms \n\n\t---*---\n\n" 
      close $f
    } elseif { ${saif_files} != "" } {
      foreach saif_file ${saif_files} {
        if { $first_file == 1 } {
          # if its the first file of the group clear the old numbers
          read_saif ${saif_file} -instance ${SAIF_DUT}
          set first_file 0
        } else {
          read_saif -update ${saif_file} -instance ${SAIF_DUT}
        }
      }
    } else {
      puts "\nError: no toggle files in ${NL_TOGGLE_FILE_DIR}"
      exit 1
    }
    puts "Generating report for power state ${power_state_clean}"
    report power -verbose -full_instance_names -sort dynamic -depth 1 >> ${_PWR_RPTS_PATH}/${DESIGN}_${power_state_clean}.nl.power.rpt    
    #######################################################    
    # Produce Power reports in BC/TYP/WC corners
    #######################################################   
	if {$APPLET} {
		foreach corner $domains {
			set_attr power_library [find /libraries -library_domain $corner] [find /libraries -library_domain WC]
			set_attr default true [find /libraries -library_domain WC]
			compare_power -leakage -dynamic -total -name $corner -module ${DESIGN} ${_PWR_RPTS_PATH}/${DESIGN}_${power_state_clean}.nl.power.html -depth 1
			report power -verbose -full_instance_names  -sort dynamic  -depth 1  > ${_PWR_RPTS_PATH}/${DESIGN}_${power_state_clean}.nl.$corner.power.rpt
		}

	} else {
	foreach corner $domains {
		set_attr power_library [find /libraries -library_domain $corner] [find /libraries -library_domain WC]
		set_attr default true [find /libraries -library_domain WC]
		report power -verbose -full_instance_names  -sort dynamic  -depth 1  > ${_PWR_RPTS_PATH}/${DESIGN}_${power_state_clean}.nl.$corner.power.rpt
	}
}

    set first_file 1
  }
} else {
  puts "\n ERROR: Toggle directory not found - $NL_TOGGLE_FILE_DIR \n"
  exit 1
}





puts "Final Runtime & Memory."
timestat FINAL
puts "============================"
puts "Power Analysis Finished ...."
puts "============================"

set log_file [get_attr stdout_log /]
file copy -force $log_file ${_PWR_RPTS_PATH}/rc_power.log
file delete $log_file

quit
