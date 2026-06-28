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
#    Primary Unit Name :      rc_flow.tcl
#
#          Description :      RC synthesis script
#
#      Original Author :      Patrick McKeever
#
#------------------------------------------------------------------------------

puts "Hostname : [info hostname]"

# Read project.tcl from current directory if it exists
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
    set_attribute applet_mode remote
    applet load measure_snapshot
}

if {$DATASHEET_PPA} {
    set INSERT_SCAN 0
    set CONNECT_CHAINS 0
    set LEAKAGE_LIB LOW
    set TYP_85C_CORNER 1
}

# Copy env variables into log file
parray ::env

# Super Threading
if {$THREADING} {
    set_attribute super_thread_servers       {batch batch}
    set_attribute super_thread_batch_command "bsub -q $MTHREAD_QUEUE"
    set_attribute super_thread_kill_command  {bkill}
}

# Global attributes
set_attribute hdl_language      v2001
set_attribute information_level 9
set_attribute gen_module_prefix RC_DP_
set_attribute inst_prefix       RC_i_
set_attribute use_scan_seqs_for_non_dft  $SCAN_SEQ_MODE
# Leave these as default - any unconnected signals/module ports should be resolved in RTL
#set_attribute hdl_unconnected_input_port_value 0
#set_attribute hdl_undriven_output_port_value   0
#set_attribute hdl_preserve_unused_registers    false

# Attributes to prevent non-alphanumeric characters in instance names
set_attribute hdl_generate_index_style %s_%d
set_attribute hdl_generate_separator _
set_attribute hdl_instance_array_naming_style %s_%d

if {$BLACK_BOX} {
    set_attribute hdl_error_on_blackbox false
} else {
    set_attribute hdl_error_on_blackbox true
}

if {$LATCHES} {
    set_attribute hdl_error_on_latch false
} else {
    set_attribute hdl_error_on_latch true
}

if {$SET_RESET_LATCHES} {
    set_attribute hdl_auto_async_set_reset true
}

if {$PRESERVE_HIERARCHY} {
    set_attribute auto_ungroup none
}


# Synthesis attributes
set_attribute tns_opto       true
set_attribute remove_assigns true

# LPS attributes
if {$CLOCK_GATING} {
set_attribute lp_insert_clock_gating                   true
}
set_attribute hdl_track_filename_row_col true
#:# Commented out due to unreliability
#:#set_attribute lp_insert_operand_isolation true
set_attribute leakage_power_effort low
set_attribute lp_power_unit        $POWER_UNIT

# Allow multibit technology library cells
# NB These cells may be set to dont_use as default in the .lib file
set_attribute use_multibit_cells true
set report_mbci_inferencing 0


####################################################################
## Custom Messages
####################################################################

# Message warning of failure to read a scan abstract for a timing model instance
mesg_make -group RDF -id 1 -short_description "CTL" -long_description "CTL/dft.abstract was not loaded" -warning


####################################################################
## Message Suppression
####################################################################

# These are the default message suppression settings. If further message
# suppression is needed then this can be added to project.tcl file.

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
#Warning : Library cell has no output pins defined. [LBR-9]
suppress_messages LBR-9
#Warning : Ignoring unsupported lu_table_template. [LBR-403]
suppress_messages LBR-403
#Warning : The Parallel Incremental Optimization failed. [MAP-136]
suppress_messages MAP-136
#Warning : Message truncated because it exceeds the maximum length of 4096 characters. [MESG-6]
suppress_messages MESG-6
#Warning : Expected data not found. [PHYS-61]
suppress_messages PHYS-61
#Warning : The 'lp_insert_clock_gating' attribute should be set before elaboration. [POPT-104]
suppress_messages POPT-104
#Warning : Test pin of clock-gating instance is already connected. [POPT-24]
suppress_messages POPT-24
#Warning : Clock period mismatch between synthesis(SDC) and simulation(VCD/TCF/SAIF) values. [RPT-13]
suppress_messages RPT-13
#Warning : Possible timing problems have been detected in this design. [TIM-11]
suppress_messages TIM-11
#Warning : Timing analysis will be done by mode. [TUI-738]
suppress_messages TUI-738
#Warning : Multiple LEC pin constraints. [WDO-209]
suppress_messages WDO-209
#Warning : - Warning : In future releases setting max_leakage_power attribute will not enable leakage power optimization on its own
suppress_messages ENV_PA-36
#Warning : - Warning : This attribute will be obsolete in a next major release
suppress_messages TUI-32
#Warning : - Warning : Tcl variable that controls the behavior of the tool is set instead of a root level attribute
suppress_messages TUI-666

# Limit messages from library to max count of 5 for each type
# Improperly defined 'leakage_power' group. [LBR-150]
set_attribute max_print 5 /messages/*/LBR-150
# An unsupported construct was detected in this library. [LBR-40]
set_attribute max_print 5 /messages/*/LBR-40
# Found 'statetable' group in cell. [LBR-83]
set_attribute max_print 5 /messages/*/LBR-83
# An output library pin lacks a function attribute. [LBR-41]
set_attribute max_print 5 /messages/*/LBR-41
# Ignoring specified timing sense. [LBR-170]
set_attribute max_print 5 /messages/*/LBR-170
# Both 'pos_unate' and 'neg_unate' timing_sense arcs have been processed. [LBR-162]
set_attribute max_print 5 /messages/*/LBR-162
# Mismatch in unateness between 'timing_sense' attribute and the function. [LBR-155]
set_attribute max_print 5 /messages/*/LBR-155
# Detected an unsupported timing arc type. [LBR-72]
set_attribute max_print 5 /messages/*/LBR-72
# Promoting a setup arc to recovery. [LBR-30]
set_attribute max_print 5 /messages/*/LBR-30
# Promoting a hold arc to removal. [LBR-31]
set_attribute max_print 5 /messages/*/LBR-31


####################################################################
## Create Output Directories
####################################################################

if {![file exists ${_SYNTH_LOG_PATH}]} {
    file mkdir ${_SYNTH_LOG_PATH}
    puts "Creating directory ${_SYNTH_LOG_PATH}"
}

if {![file exists ${_OUTPUTS_PATH}]} {
    file mkdir ${_OUTPUTS_PATH}
    puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
    file mkdir ${_REPORTS_PATH}
    puts "Creating directory ${_REPORTS_PATH}"
}

if {![file exists ${_DFT_REPORTS_PATH}]} {
    file mkdir ${_DFT_REPORTS_PATH}
    puts "Creating directory ${_DFT_REPORTS_PATH}"
}

if {![file exists ${_RCENC_PATH}]} {
    file mkdir ${_RCENC_PATH}
    puts "Creating directory ${_RCENC_PATH}"
}

if {![file exists ${_RCET_PATH}]} {
    file mkdir ${_RCET_PATH}
    puts "Creating directory ${_RCET_PATH}"
}

if {![file exists ${ATPG_CLOCK_CONSTRAINTS_FILE}]} {
    set ATPG_CONSTRAINTS_PATH [file dirname $ATPG_CLOCK_CONSTRAINTS_FILE]
    file mkdir $ATPG_CONSTRAINTS_PATH
    puts "Creating directory ${ATPG_CONSTRAINTS_PATH}"
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

if {$DATASHEET_PPA} {
	set_attribute default true TYP
} else {
	set_attribute power_library TYP WC
	set_attribute default true WC
}

####################################################################
## Select VT Library
####################################################################

if [info exists LEAKAGE_LIB] {
    if {$LEAKAGE_LIB == "LOW"} {
        if {$PROCNODE == "16" || $PROCNODE == "10" || $PROCNODE == "7"} {
            set_attribute avoid true [find / -libcell *LVT*]
            set_attribute avoid true [find / -libcell *ULVT*]
        } else {
            set_attribute avoid true [find / -libcell *]
            set_attribute avoid false [find / -libcell *HVT*]
        }
    } elseif {$LEAKAGE_LIB == "MID"} {
        if {$PROCNODE == "16" || $PROCNODE == "10" || $PROCNODE == "7"} {
            set_attribute avoid true [find / -libcell *ULVT*]
        }  else {
            set_attribute avoid true [find / -libcell *LVT*]
        }
    }
}


####################################################################
## Set Don't Use and Force Use (multibit cells)
####################################################################

foreach cset $DONT_USE {
    set cells [find / -libcell $cset]
    if { [llength $cells] > 0 } {
        set_attribute avoid true $cells
    } else {
        puts "Error in DONT_USE variable, $cset is not in library."
    }
}

if [info exists FORCE_USE] {
    foreach cset $FORCE_USE {
        set cells [find / -libcell $cset]
        if { [llength $cells] > 0 } {
            set_attribute avoid false $cells
        } else {
            puts "Error in FORCE_USE variable, $cset is not in library."
        }
    }
}


####################################################################
## PLE
####################################################################

set_attribute lef_library "$LIBLEF"

set_attribute qrc_tech_file $WC_QRC_TECH

set_attribute interconnect_mode ple

####################################################################
## Read power intent pre-elaboration
####################################################################

if [info exists POWER_INTENT_FILE] {
    if { [ regexp {\.cpf?$} ${POWER_INTENT_FILE} ] } {
        read_power_intent -module ${DESIGN} -cpf ${POWER_INTENT_FILE}
    } else {
        read_power_intent -module ${DESIGN} -1801 ${POWER_INTENT_FILE}
    }
}


####################################################################
## Load Design
####################################################################

# If the parameters are coming from a .f file then parse the .f
# file to get a list of parameters
set PARAMETERS ""
set VDEFINES ""
set INCDIRS ""
set CONFIGURATION ""

# Read in $DESIGN.f list of RTL files (may be Verilog, SV or VHDL)
set files_vh ""
set files_vl ""
set files_sv ""
set list_file [open $RTL_F_FILE RDONLY]
set buffer [read -nonewline $list_file]
foreach entry $buffer {
    regsub -all {\$([0-9a-zA-Z_]*)(\/.*)} $entry {$::env(\1)\2} myline
    set entry [subst -nocommand -nobackslashes $myline]
    if [ regexp {\+define\+} $entry ] {
        puts "DEFINE $entry"
        if {[regexp {(\+define\+)([A-Z_0-9]*=[0-9]*)} $entry P1 P2 p_name ]} {puts "$P1 $P2 $p_name"} else {
        regexp {(\+define\+)([A-Z_0-9]*)} $entry P1 P2 p_name }
        set VDEFINES "$VDEFINES $p_name "
    } elseif [ regexp {\+incdir\+} $entry ] {
        puts "INCDIR $entry"
        set incdir_name [regsub -- {(\+incdir\+)(.*)} $entry {\2}]
        lappend INCDIRS " $incdir_name "
    } elseif [ regexp {\.vhdl?$} $entry ] {
        set files_vh "$files_vh $entry"
    } elseif [ regexp {\.svh?$} $entry ] {
        set files_sv "$files_sv $entry"
    } else {
        set files_vl "$files_vl $entry"
    }
}
close $list_file

# Remove list curly brackets so that the string can be used on the read_hdl command line
set VDEFS [join $VDEFINES " "] 

if { ${VDEFS} != ""} {
    set_attribute hdl_verilog_defines "$VDEFS"
}


#Search paths can come from HDL_SEARCH_PATH defined in setup_project.csh
# Or from the verilog command file (.f) via +incdir+
set SEARCH_PATHS ""
  if [info exists HDL_SEARCH_PATH] { 
    lappend SEARCH_PATHS "$HDL_SEARCH_PATH"
  }    
  if {${INCDIRS} != ""} {
    lappend SEARCH_PATHS "$INCDIRS"
  }

# Workaround to remove lists
set SRCS [join $SEARCH_PATHS " "]
set SRCS2 [join $SRCS " "]
  if { ${SEARCH_PATHS} != ""} {
    set_attribute hdl_search_path "$SRCS2"
  }

# Read VHDL files
if { $files_vh != "" } {
    echo $files_vh
    read_hdl -vhdl $files_vh
}

# Read Verilog files
if { $files_vl != "" } {
        echo $files_vl
        read_hdl -define RTL_BEHV -define NO_SVA -v2001 $files_vl
}

# Read System Verilog files
if { $files_sv != "" } {
    echo $files_sv
    read_hdl -define RTL_BEHV -sv $files_sv
}


####################################################################
## Elaborate and check signals/black boxes
####################################################################

if { $PARAMETERS == "" } {
    elaborate ${DESIGN}
} else {
    elaborate -parameters ${PARAMETERS} ${DESIGN}
}

puts "Runtime & Memory after 'read_hdl'"
time_info Elaboration

check_design -unresolved  > $_REPORTS_PATH/${DESIGN}_check_design.unresolved.rpt
check_design -undriven    > $_REPORTS_PATH/${DESIGN}_check_design.undriven.rpt
check_design -multidriven > $_REPORTS_PATH/${DESIGN}_check_design.multidriven.rpt


####################################################################
## Remove backslash in instance names
####################################################################

if {$REMOVE_BACKSLASH} {
    change_names -instance -restricted {[ ] .} -replace_str "_" -force
}


####################################################################
## Apply power intent post-elaboration
####################################################################

if [info exists POWER_INTENT_FILE] {
    apply_power_intent
}


####################################################################
## Write post-elaboration netlist
####################################################################

write_hdl ${DESIGN} > ${_OUTPUTS_PATH}/${DESIGN}.elab.v

#Preserve hierarchy of submodules
if [info exists NO_UNGROUP] {
    set_attribute auto_ungroup none
    foreach gset $NO_UNGROUP {
        set ginst [find / -subd $gset]
        if { [llength $ginst] > 0 } {
            set_attribute ungroup_ok false $ginst
        } else {
            puts "Error in NO_UNGROUP variable, $gset is not found in design."
        }
    }
}


####################################################################
## Preserve any modules listed in project.tcl
####################################################################

#Preserve specific pre mapped instances e.g. sync flops
if [info exists PRESERVE_PRE_MAPPED_INST_LIST] {
  foreach gset $PRESERVE_PRE_MAPPED_INST_LIST {
set_attribute preserve true [find /designs/* -instance $gset]
  }
}
#Preserve pre mapped netlists - suitable for hierarchichal synthesis
if [info exists PRESERVE_PRE_MAPPED_SUB_LIST] {
  foreach gset $PRESERVE_PRE_MAPPED_SUB_LIST {
set_attribute preserve true [find / -subdesign $gset]
  }
}



####################################################################
## Create Test Case if needed
####################################################################

if {$CREATE_TCASE} {
    applet load create_tcase
    create_tcase -mode save -overwrite -no_lib -archive ${DESIGN}_tcase
}


####################################################################
## Design name will be changed as a result of elaboration with
## parameters
####################################################################

set DESIGN_FULL "${DESIGN}${CONFIGURATION}"


####################################################################
## DFT Setup 
####################################################################

#:# DFT setup needs to be run prior to reading SDC since scan ports don't exist for case analysis
source $IPF_DESIGN_FLOW_SCRIPTS/rc/dft_setup.tcl
set_attr dft_auto_identify_shift_register true /

if [info exists PRESERVE_LIST] {
    foreach gset $PRESERVE_LIST {
        set gsub [find / -subdesign $gset]
        if { [llength $gsub] > 0 } {
            set_attribute preserve true $gsub } else {
            set gsub [find / -libcell $gset]
            if { [llength $gsub] > 0 } {
                set_attribute preserve true $gsub
            } else {
                puts "Module $gset is not in design"
                suspend
            }
        }
    }
}
if [info exists PRESERVE_NET] {
    foreach gset $PRESERVE_NET {
        set gsub [find / -net $gset]
        if { [llength $gsub] > 0 } {
            set_attribute preserve true $gsub
        } else {
            puts "Net $gset is not in design"
            suspend
        }
    }
}

####################################################################
## Commit CPF, verify using clp as part of synthesis
####################################################################

if [info exists POWER_INTENT_FILE] {
    commit_power_intent
    if {$RC_USE_CONFORMAL} {
    verify_power_structure -all -lp_only -detail -pre_synthesis > $_REPORTS_PATH/${DESIGN}_verify_power_structure_pre_synth.rpt
    }
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


report timing -lint -verbose >  $_REPORTS_PATH/${DESIGN}_check_timing.rpt
report clocks                >  $_REPORTS_PATH/report_clocks.${DESIGN}.rpt
report clocks -generated     >> $_REPORTS_PATH/report_clocks.${DESIGN}.rpt


####################################################################
## Extract clock constraints for ATPG
####################################################################

extract_clock_constraints_for_atpg


####################################################################
## Define cost groups
## (clock-clock, clock-output, input-clock, input-output)
####################################################################
rm [find /designs/* -cost_group *]

if {[llength [all::all_seqs]] > 0} {
    define_cost_group -name in2reg  -design $DESIGN_FULL
    define_cost_group -name reg2out -design $DESIGN_FULL
    define_cost_group -name reg2reg -design $DESIGN_FULL

    foreach mode $DESIGN_MODES {
        path_group -from [all::all_seqs] -to [all::all_seqs] -group reg2reg -name reg2reg -mode ${mode}
        if {[llength [all::all_outs]] > 0} {
            path_group -from [all::all_seqs] -to [all::all_outs] -group reg2out -name reg2out -mode ${mode}
        }
        if {[llength [all::all_inps]] > 0} {
            path_group -from [all::all_inps] -to [all::all_seqs] -group in2reg -name in2reg -mode ${mode}
        }
    }
}

foreach mode $DESIGN_MODES {
    if {[llength [all::all_inps]] > 0 && [llength [all::all_outs]] > 0} {
        define_cost_group -name in2out -design $DESIGN_FULL
        path_group -from [all::all_inps]  -to [all::all_outs] -group in2out -name in2out -mode ${mode}
    }
}


#:# Clock gating attribute = 3 flops minimum, following recommendation from AE
set_attribute lp_clock_gating_min_flops 3 /designs/${DESIGN_FULL}


####################################################################
## Power Analysis
####################################################################

#Choosing not to optimise for dynamic power due to area increase trade off
set_attribute max_leakage_power             0 ${DESIGN_FULL}
#set_attribute max_dynamic_power            50 ${DESIGN_FULL}
#force tool to optimise leakage only, optimising for dynamic power had little effect and increases area
#set_attribute lp_power_optimization_weight  1 ${DESIGN_FULL}


# Are we doing a Stochastic power analysis or analysis from
# a toggle file.
if { [info exists RTL_TOGGLE_FILE] && ($RTL_TOGGLE_FILE != "") } {
    if [file exists $RTL_TOGGLE_FILE] {
        set file_type [file extension $RTL_TOGGLE_FILE]
        if { $file_type == ".tcf" } {
            read_tcf -verbose ${RTL_TOGGLE_FILE}
        } elseif { $file_type == ".saif" } {
            read_saif -verbose ${RTL_TOGGLE_FILE} -instance ${SAIF_DUT}
        }
    } else {
        puts "Error: Either toggle file '$RTL_TOGGLE_FILE' not found or it does not have the correct naming convention (*.tcf or *.saif)."
        suspend
    }
} else {
    set_attribute lp_default_probability 0.50 $DESIGN_FULL
    set_attribute lp_default_toggle_rate 0.01 $DESIGN_FULL
}


####################################################################
## Synthesizing to generic
####################################################################

if {[get_attr program_short_name] eq "genus"} {
   set_attr syn_generic_effort $SYN_EFF
   syn_generic
} else {
   synthesize -to_generic -effort $SYN_EFF
}
puts "Runtime & Memory after 'synthesize -to_generic'"
time_info GENERIC
report datapath > $_REPORTS_PATH/${DESIGN}_datapath_generic.rpt


####################################################################
## Synthesizing to gates
####################################################################

if [info exists FP_DEF] {
    read_def -ignore_errors $FP_DEF
} 

if {[get_attr program_short_name] eq "genus"} {
   set_attr syn_map_effort $SYN_EFF
   syn_map
} else {
   synthesize -to_mapped -effort $SYN_EFF -no_incremental
}
puts "Runtime & Memory after 'synthesize -to_map -no_incr'"
time_info MAPPED

# Intermediate netlist for LEC verification
write_hdl -lec > ${_OUTPUTS_PATH}/${DESIGN}_mapped.vg


####################################################################
## Save a mapped DB
####################################################################

write_db -all_root_attributes -to_file ${_OUTPUTS_PATH}/${DESIGN}_mapped.db -quiet



####################################################################
## Generate LEC script
####################################################################

write_do_lec -top $DESIGN_FULL -revised_design ${_OUTPUTS_PATH}/${DESIGN}_mapped.vg -pre_read ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_read.do -pre_compare ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_compare_rtl2map.do -pre_exit ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_exit.do -logfile ${_LEC_LOG_PATH}/rtl2mapped.lec.log > ${_OUTPUTS_PATH}/rtl2mapped.lec.do


####################################################################
## Insert scan
####################################################################

if {$INSERT_SCAN} {
    source $IPF_DESIGN_FLOW_SCRIPTS/rc/dft_insert_scan.tcl
}


####################################################################
## Re-commit CPF after design has changed
####################################################################

if [info exists POWER_INTENT_FILE] {
    commit_power_intent
    if {$RC_USE_CONFORMAL} {
        verify_power_structure -all -lp_only -detail -post_synthesis > $_REPORTS_PATH/${DESIGN}_verify_power_structure_post_dft.rpt
    }
}


####################################################################
## Incremental Synthesis
####################################################################

if {[get_attr program_short_name] eq "genus"} {
   set_attr syn_opt_effort $SYN_EFF
   if [info exists FP_DEF] {
       syn_opt -physical
   } else {
       syn_opt
   }
} else {
   if [info exists FP_DEF] {
       synthesize -to_placed -effort $SYN_EFF -incremental
   } else {
       synthesize -effort $SYN_EFF -incremental
   }
}

####################################################################
## Give all modules unique name.
## This is to support gate level simulations and make sure we
## do not have module name collisions.
####################################################################

uniquify $DESIGN_FULL

if {$UNIQUIFY_MODULES} {
    set modules [find / -vname -subdesign *]
    foreach module $modules {
        mv -flexible $module ${DESIGN}_$module
    }
}


####################################################################
## Write timing data
####################################################################

report datapath > $_REPORTS_PATH/${DESIGN}_datapath_map.rpt

foreach mode $DESIGN_MODES {

    # Report results for the clock groups that have been created
    if {[llength [all::all_seqs]] > 0} {
        foreach cg {in2reg reg2out reg2reg in2out} {
            report timing -mode ${mode} -worst 1000 -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_${cg}_post_map_$mode.rpt
            report timing -mode ${mode} -endpoints  -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_${cg}_post_map_ep_$mode.rpt
        }
    }

}

# Report results for each clock
foreach cg [find / -clock *] {
    report timing -worst 1000 -to [list $cg] > $_REPORTS_PATH/${DESIGN}_[basename $cg]_post_map.rpt
    report timing -endpoints  -to [list $cg] > $_REPORTS_PATH/${DESIGN}_[basename $cg]_post_map_ep.rpt
}


####################################################################
## Write design data
####################################################################

report gates $DESIGN_FULL > $_REPORTS_PATH/${DESIGN}_gates.rpt
report area  $DESIGN_FULL > $_REPORTS_PATH/${DESIGN}_area.rpt
report qor   $DESIGN_FULL > $_REPORTS_PATH/${DESIGN}_qor.rpt

write_design -encounter -gzip_files -tcf -basename ${_RCENC_PATH}/${DESIGN}
write_db -all_root_attributes -to_file ${_RCENC_PATH}/${DESIGN}_final.db

#######################################################################
## Create reports detailing flop and clock relationships and sync flops
#######################################################################

if { [info exists PRINT_SYNC_FLOPS] && ($PRINT_SYNC_FLOPS == 1) } {
   source $IPF_DESIGN_FLOW_SCRIPTS/rc/report_sync_clocks.tcl
}
if { [info exists PRINT_FLOPS] && ($PRINT_FLOPS == 1) } {
   source $IPF_DESIGN_FLOW_SCRIPTS/rc/report_flops_clocks.tcl
}
if { [info exists PRINT_IO_CLOCKS] && ($PRINT_IO_CLOCKS == 1) } {
   source $IPF_DESIGN_FLOW_SCRIPTS/rc/report_io_clocks.tcl
}
####################################################################
## Generate LEC scripts
####################################################################

write_do_lec -top $DESIGN_FULL -revised_design ${_OUTPUTS_PATH}/${DESIGN}.v.gz -pre_read ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_read.do -pre_compare ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_compare.do  -pre_exit ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_exit_r2f.do -logfile ${_LEC_LOG_PATH}/rtl2final.lec.log > ${_OUTPUTS_PATH}/rtl2final.lec.do
write_do_lec -top $DESIGN_FULL -golden_design ${_OUTPUTS_PATH}/${DESIGN}_mapped.vg -pre_read ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_read.do -pre_compare ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_compare_map2final.do  -revised_design ${_OUTPUTS_PATH}/${DESIGN}.v.gz -pre_exit ${IPF_DESIGN_FLOW_SCRIPTS}/rc/lec_pre_exit_m2f.do -logfile ${_LEC_LOG_PATH}/map2final.lec.log > ${_OUTPUTS_PATH}/map2final.lec.do


####################################################################
## Report clock gating
####################################################################

if {[get_attribute lp_insert_clock_gating] == "true"} {
    report clock_gating  > ${_REPORTS_PATH}/${DESIGN}_clock_gating.rpt
    report clock_gating -gated_ff >> ${_REPORTS_PATH}/${DESIGN}_clock_gating.rpt
    report clock_gating -ungated_ff -detail >> ${_REPORTS_PATH}/${DESIGN}_clock_gating.rpt
}


# Write messages summary
report messages > ${_REPORTS_PATH}/${DESIGN}_message_summary.rpt

# Report units used
redirect ${_REPORTS_PATH}/${DESIGN}_units_summary.rpt "report units"


####################################################################
## Report power and produce HTML snapshot
####################################################################

if [file exists ${DUT_PATH}/${DESIGN}_dashboard] {
    file delete -force ${DUT_PATH}/${DESIGN}_dashboard
}

if [file exists ${_REPORTS_PATH}/${DESIGN}_power.html] {
    file delete -force ${_REPORTS_PATH}/${DESIGN}_power.html
}


if { [info exists RTL_TOGGLE_FILE] && ($RTL_TOGGLE_FILE != "") } {
    if [regexp {\.tcf$} $RTL_TOGGLE_FILE] {
        set activity tcf
    } elseif [regexp {\.saif$} $RTL_TOGGLE_FILE] {
        set activity saif
    }
} else {
    set activity default
}

if {$APPLET} {
	foreach corner $domains {
		set_attr power_library [find /libraries -library_domain $corner] [find /libraries -library_domain WC]
		set_attr default true [find /libraries -library_domain WC]
		compare_power -leakage -dynamic -total -name $corner -module ${DESIGN} ${_REPORTS_PATH}/${DESIGN}_power.html -depth 1
		report power -verbose -full_instance_names  -sort dynamic  -depth 1  > ${_REPORTS_PATH}/${DESIGN}_${activity}_$corner.power.rpt
	}


	if {$HTML_REPORT} {
		measure snapshot -depth 2 -exclude power -name ${DESIGN}_Synth -report_dir ${DUT_PATH}/${DESIGN}_dashboard -overwrite -notify ${DESIGN}_WC_qor
		set myCustom [list "Logfile<SCALE(/1000)> rc.log<LINK=${_SYNTH_LOG_PATH}/rc.log>"]
		lappend myCustom [list "Power" "power reports<LINK=${_REPORTS_PATH}/${DESIGN}_power.html>"]
		lappend myCustom [list "Clock Gating" "Clock Gating report<LINK=${_REPORTS_PATH}/${DESIGN}_clock_gating.rpt>"]
		lappend myCustom [list "Message Summary" "Message Summary<LINK=${_REPORTS_PATH}/${DESIGN}_message_summary.rpt>"]
		lappend myCustom [list "Units Summary" "Units Summary<LINK=${_REPORTS_PATH}/${DESIGN}_units_summary.rpt>"]
		lappend myCustom [list "Gates/VT Mix Report" "Gates/VTMix<LINK=$_REPORTS_PATH/${DESIGN}_gates.rpt>"]
		lappend myCustom [list "DFT Report" "DFT report<LINK=$_REPORTS_PATH/${DESIGN}.dft_chainRegs>"]
		lappend myCustom [list "DFT Don't Scan" "DFT don't scan<LINK=$_REPORTS_PATH/${DESIGN}.dft_dontScanRegs>"]
		lappend myCustom [list "DFT Scan Fail" "DFT scan fail<LINK=$_REPORTS_PATH/${DESIGN}.dft_scanFailRegs>"]
		measure custom -name ${DESIGN}_Synth -custom ${myCustom} ${DUT_PATH}/${DESIGN}_dashboard/qor.html  -update 1
	}

} else {
	foreach corner $domains {
		set_attr power_library [find /libraries -library_domain $corner] [find /libraries -library_domain WC]
		set_attr default true [find /libraries -library_domain WC]
		report power -verbose -full_instance_names  -sort dynamic  -depth 1  > ${_REPORTS_PATH}/${DESIGN}_${activity}_$corner.power.rpt
	}
}



puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

set log_file [get_attribute stdout_log]
file copy -force $log_file ${_SYNTH_LOG_PATH}/rc.log
file delete $log_file


quit
