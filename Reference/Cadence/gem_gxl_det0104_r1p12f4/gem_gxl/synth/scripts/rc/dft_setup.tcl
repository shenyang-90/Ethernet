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
#    Primary Unit Name :      dft_setup.tcl
#
#          Description :      RC scan setup script sourced by rc_flow.tcl
#
#      Original Author :      Anna Gilbert
#
#------------------------------------------------------------------------------

######################################################################
# START DFT Configuration
######################################################################

set_attribute dft_scan_output_preference non_inverted /designs/$DESIGN_FULL

if {$DEBUG_PHASE} {
    set_attribute dft_identify_test_signals          true
    set_attribute dft_identify_top_level_test_clocks true
} else {
    set_attribute dft_identify_test_signals          false
    set_attribute dft_identify_top_level_test_clocks false
}
set_attribute dft_identify_internal_test_clocks no_cgic_hier

if {$INSERT_SCAN && !$CONNECT_CHAINS} {
    set_attribute dft_scan_map_mode force_all /designs/*
}


######################################################################
# User Design Setting
# Assumptions for IP
# No local TAP
# No compression or OPCGS required
######################################################################

if {$HARD_MACRO} {
    puts "before $DFT_ABSTRACT_MODEL"
    set L [list $DFT_ABSTRACT_MODEL]
    set sublist [lindex $L 0]
    if [regsub abstract, $sublist abstract sublist] {
        puts "Substitution made: $DFT_ABSTRACT_MODEL";
    }
    if [regsub ctl, $sublist abstract sublist] {
        puts "Substitution made: $DFT_ABSTRACT_MODEL";
    }
    puts "after $sublist"
    foreach hard_scan_block_abstract_file $sublist {
        puts "hard macro abstract file $hard_scan_block_abstract_file"
        set ASSOCIATED_HARD_MACRO_FILE_NAME [file tail $hard_scan_block_abstract_file]
        puts "hard macro file $ASSOCIATED_HARD_MACRO_FILE_NAME"
        regexp {^[^.]+} $ASSOCIATED_HARD_MACRO_FILE_NAME ASSOCIATED_HARD_MACRO_MODULE_NAME
        puts "hard macro module $ASSOCIATED_HARD_MACRO_MODULE_NAME"
        set hard_macro_instances {}
        foreach inst_name [find / -instance *] {
            if { [get_attribute hierarchical $inst_name] == "true" && $BLACK_BOX } {
	        if { [vfind $ASSOCIATED_HARD_MACRO_MODULE_NAME] == [get_attribute subdesign $inst_name] } {
	            lappend hard_macro_instances $inst_name
	        }
	    }
            if { [basename [get_attribute libcell $inst_name]] == "$ASSOCIATED_HARD_MACRO_MODULE_NAME" } {
                lappend hard_macro_instances $inst_name
            }
        }
        if { $hard_macro_instances == {} } {
            puts " $ASSOCIATED_HARD_MACRO_MODULE_NAME : No subdesign or libcell found with this name, check that scan abstract file name complies with required syntax: '<module_name>.ctl' or '<module_name>.scan_abstract'"
            exit
        }
        puts "hard macro instances $hard_macro_instances"
        foreach MACRO_NAME [file tail $hard_macro_instances] {
            puts "macro name $MACRO_NAME"
            puts "file $ASSOCIATED_HARD_MACRO_FILE_NAME"
            puts "full path to file $hard_scan_block_abstract_file"
            set file_type [file extension $hard_scan_block_abstract_file]
	    set i 0
	    foreach MACRO_INST [find / -instance $MACRO_NAME] {
              if { $file_type == ".ctl"} {
                  read_dft_abstract_model -advanced -ctl $hard_scan_block_abstract_file \
                                        -instance $MACRO_INST \
                                        -segment_prefix ${MACRO_NAME}_${i}_
              } elseif { $file_type == ".scan_abstract" || $file_type == ".abstract" } {
                  read_dft_abstract_model $hard_scan_block_abstract_file \
                                        -instance $MACRO_INST \
                                        -segment_prefix ${MACRO_NAME}_${i}_
              } else {
	        puts " $file_type : Invalid type for scan abstraction files: it should be either '.ctl' or '.scan_abstract'"
	        exit
	      }
	      incr i
	   }
        }
    }
}

if {$INSERT_SCAN || $RC_CLK_GATING} {

    #master shift enable pin, create scanen port if $SHIFT_ENABLE_PORT empty
    if { $SHIFT_ENABLE_PORT != "" } {
        if { [set shift_enable_port_name [find / -port ports_in/$SHIFT_ENABLE_PORT]] != "" } {
            define_dft shift_enable -name RC_SHIFT_ENABLE0 -active high $shift_enable_port_name
        } else {
            puts "Error: input port '$SHIFT_ENABLE_PORT' not found, check assignment to \$SHIFT_ENABLE_PORT in project.tcl."
            suspend
        }
    } else {
        define_dft shift_enable -name RC_SHIFT_ENABLE0 -active high scanen -create_port
        set_attr lp_asserted_toggle_rate 0 scanen
        set_attr lp_asserted_probability 0 scanen
    }


    #include separate shift enable for clock gate control, create scanen_cg port if $TEST_CG_ENABLE_PORT empty
    if { ($TEST_CG_ENABLE_PORT != "") && ($TEST_CG_ENABLE_PORT == $SHIFT_ENABLE_PORT) } {
        set test_cg_enable [find / -test_signal RC_SHIFT_ENABLE0]
    } else {
        if { $TEST_CG_ENABLE_PORT != "" } {
            if { [set test_cg_enable_port_name [find / -port ports_in/$TEST_CG_ENABLE_PORT]] != "" } {
                define_dft shift_enable -name RC_SHIFT_ENABLE1 -active high $test_cg_enable_port_name
            } else {
                puts "Error: input port '$TEST_CG_ENABLE_PORT' not found, check assignment to \$TEST_CG_ENABLE_PORT in project.tcl."
                suspend
            }
        } else {
            define_dft shift_enable -name RC_SHIFT_ENABLE1 -active high scanen_cg -create_port
            set_attr lp_asserted_toggle_rate 0 scanen_cg
            set_attr lp_asserted_probability 0 scanen_cg
        }
        set test_cg_enable [find / -test_signal RC_SHIFT_ENABLE1]
    }

    set_attribute lp_clock_gating_test_signal $test_cg_enable /designs/$DESIGN_FULL

}

if {$INSERT_SCAN} {
    #master test control pin(s)
    set test_mode_ports {}
    foreach test_mode_pin $TEST_MODE_PORTS {
        if { [set test_mode_port_name [find / -port ports_in/$test_mode_pin]] != "" } {
            lappend test_mode_ports $test_mode_port_name
        } else {
            puts "Error: input port '$test_mode_pin' not found, check assignment to \$TEST_MODE_PORTS in project.tcl."
            suspend
        }
    }
    puts "$test_mode_ports"

    for { set i 0 } { $i < [llength $test_mode_ports] } { incr i } {
        set test_mode_port [lindex $test_mode_ports $i]
        define_dft test_mode -name RC_SCAN_MODE$i \
                             -active high $test_mode_port
    }

    set test_moden_ports {}
    foreach test_moden_pin $TEST_MODEN_PORTS {
        if { [set test_moden_port_name [find / -port ports_in/$test_moden_pin]] != "" } {
            lappend test_moden_ports $test_moden_port_name
        } else {
            puts "Error: input port '$test_moden_pin' not found, check assignment to \$TEST_MODEN_PORTS in project.tcl."
            suspend
        }
    }
    puts "$test_moden_ports"

    for { set i 0 } { $i < [llength $test_moden_ports] } { incr i } {
        set test_moden_port [lindex $test_moden_ports $i]
        define_dft test_mode -name RC_SCAN_MODEN$i \
                             -active low $test_moden_port
    }


    #define active high resets as test mode inputs constrained low
    set reset_ports {}
    foreach reset_pin $TEST_RST_PORTS {
        if { [set reset_port_name [find / -port ports_in/$reset_pin]] != "" } {
            lappend reset_ports $reset_port_name
        } else {
            puts "Error: input port '$reset_pin' not found, check assignment to \$TEST_RST_PORTS in project.tcl."
            suspend
        }
    }
    puts "$reset_ports"

    for { set i 0 } { $i < [llength $reset_ports] } { incr i } {
        set reset_port [lindex $reset_ports $i]
        define_dft test_mode -name RC_SCAN_RST$i \
                             -active low $reset_port \
                             -scan_shift
    }


    #define active low resets as test mode inputs constrained high
    set resetn_ports {}
    foreach resetn_pin $TEST_RSTN_PORTS {
        if { [set resetn_port_name [find / -port ports_in/$resetn_pin]] != "" } {
            lappend resetn_ports $resetn_port_name
        } else {
            puts "Error: input port '$resetn_pin' not found, check assignment to \$TEST_RSTN_PORTS in project.tcl."
            suspend
        }
    }
    puts "$resetn_ports"

    for { set i 0 } { $i < [llength $resetn_ports] } { incr i } {
        set resetn_port [lindex $resetn_ports $i]
        define_dft test_mode -name RC_SCAN_RSTN$i \
                             -active high $resetn_port \
                             -scan_shift
    }


    #define scan clocks
    set clock_ports {}
    foreach clock_pin $TEST_CLK_PORTS {
        if { [set clock_port_name [find / -port ports_in/$clock_pin]] != "" } {
            lappend clock_ports $clock_port_name
        } else {
            puts "Error: input port '$clock_pin' not found, check assignment to \$TEST_CLK_PORTS in project.tcl."
            suspend
        }
    }
    puts "$clock_ports"

    for { set i 0 } { $i < [llength $clock_ports] } { incr i } {
        set clock_port [lindex $clock_ports $i]
        define_dft test_clock -name RC_SCAN_CLK$i \
                              $clock_port
    }

    #define don't scan blocks
    set dont_scan_blocks {}
    foreach dont_scan_block $DONT_SCAN {
        if { [set dont_scan_block_name [find / -subdesign $dont_scan_block]] != "" } {
            lappend dont_scan_blocks $dont_scan_block_name
            set_attribute boundary_opto false $dont_scan_blocks
            set_attribute lp_clock_gating_exclude true $dont_scan_blocks
            set_attribute dft_dont_scan true $dont_scan_blocks
        }
    }

    #define don't scan instance
    set dont_scan_instances {}
    foreach dont_scan_instance $DONT_SCAN_INSTANCE {
        if { [set dont_scan_instance_name [find / -instance $dont_scan_instance]] != "" } {
            lappend dont_scan_instances $dont_scan_instance_name
            set_attribute lp_clock_gating_exclude true $dont_scan_instances
            set_attribute dft_dont_scan true $dont_scan_instances
        }
    }

    ######################################################
    # Set up for scan insertion and run DFT rule checker##
    ######################################################
    set_attribute max_print 1 [find / -message POPT-24] ;# avoid repetition of clock gating test signal info message
    set_attribute max_print 1 [find / -message POPT-29] ;# avoid repetition of clock gating test signal info message

    check_dft_rules -max_print_violations -1 > $_REPORTS_PATH/${DESIGN}_check_dft_rules.rpt

    #best practice allow mixed clock edges in a scanchain
    set_attr dft_mix_clock_edges_in_scan_chains true /designs/$DESIGN_FULL

    #best practice put a +ve edge flop at start of chain to keep the scan chain interfaces uniform and easier to interface to
    set_attr dft_clock_edge_for_head_of_scan_chains leading /designs/$DESIGN_FULL

    #best practice put a -ve edge latch at end of chain to keep the scan chain interfaces uniform and easier to interface to
    set_attr dft_clock_edge_for_tail_of_scan_chains trailing /designs/$DESIGN_FULL

    set toolIdentifiedTestSignals [filter user_defined_signal false [find /designs/* -test_signal *]]
    set toolIdentifiedTestClocks [filter user_defined_signal false [find /designs/* -test_clock *]]

    if {[llength $toolIdentifiedTestSignals] > 0 && [llength $toolIdentifiedTestClocks] > 0} {
        puts "Warning: there are tool identified test signals/clocks, for signoff runs, all signals should be specified by the user"
    }
}


####################################
# Extract Clock Constraints for ATPG
####################################

proc extract_clock_constraints_for_atpg {} {

    global ATPG_CLOCK_CONSTRAINTS_FILE
    global DESIGN_MODES

    puts "\n DFT clock constraints extraction starting \n"

    if [file exists $ATPG_CLOCK_CONSTRAINTS_FILE] {
        file delete -force $ATPG_CLOCK_CONSTRAINTS_FILE
    }
    set accfh [open $ATPG_CLOCK_CONSTRAINTS_FILE w]

    if { [ lsearch -inline $DESIGN_MODES "*atspeed*" ] != "" } {
	set position [lsearch $DESIGN_MODES "*atspeed*" ]
	set ATPG_MODE [lindex $DESIGN_MODES $position]
    } elseif { [ lsearch -inline $DESIGN_MODES "*at_speed*" ] != "" } {
	set position [lsearch $DESIGN_MODES "*at_speed*" ]
	set ATPG_MODE [lindex $DESIGN_MODES $position]
    } elseif { [ lsearch -inline $DESIGN_MODES "*capture*" ] != "" } {
	set position [lsearch $DESIGN_MODES "*capture*" ]
	set ATPG_MODE [lindex $DESIGN_MODES $position]
    } elseif { [ lsearch -inline $DESIGN_MODES "*stuckat*" ] != "" } {
	set position [lsearch $DESIGN_MODES "*stuckat*" ]
	set ATPG_MODE [lindex $DESIGN_MODES $position]
    } elseif { [ lsearch -inline $DESIGN_MODES "*stuck_at*" ] != "" } {
	set position [lsearch $DESIGN_MODES "*stuck_at*" ]
	set ATPG_MODE [lindex $DESIGN_MODES $position]
    } elseif { [ lsearch -exact $DESIGN_MODES "scan" ] != -1 } {
	set ATPG_MODE "scan"
    } elseif { [ lsearch -exact $DESIGN_MODES "func" ] != -1 } {
        set ATPG_MODE "func"
    } else {
        set ATPG_MODE ""
        puts "No Valid constraints for scan found"
    }

    if { $ATPG_MODE != "" } {

        set all_clock_ports {}
        foreach clock_name [find / -clock *] {
            set clock_sources [ concat [ get_attribute non_inverted_sources $clock_name ] \
                                       [ get_attribute inverted_sources     $clock_name ] ]
            foreach clock_source $clock_sources {
                if [regexp {/ports_in/} $clock_source] {
                    if { [lsearch -exact $all_clock_ports $clock_source] == -1 } {
                        lappend all_clock_ports $clock_source
                    }
                }
            }
        }

        array unset atpg_clocks
        array unset atpg_ports

        foreach dft_cp $all_clock_ports {
            # extract just the port name without the hierarchy
            set dft_cp_base [ basename $dft_cp ]
            # get the clock sources for the current port
            set dft_cp_sources [ concat [ get_attribute clock_sources_non_inverted $dft_cp ] \
                                        [ get_attribute clock_sources_inverted     $dft_cp ] ]
            if { $dft_cp_sources == "" } {
                puts "        DFT Extraction error, no clock source found for clock port $dft_cp_base"
            } else {
                if [info exists dft_cp_period] { unset dft_cp_period }
                # support multiple waveforms per port
                foreach dft_cp_source $dft_cp_sources {
                    # only proceed for a waveform defined in the identified ATPG mode
                    if [regexp "/modes/$ATPG_MODE/" $dft_cp_source] {
                        set dft_cp_source_period [ get_attribute period $dft_cp_source ]
                        # extract clock waveform info only if it is a higher frequency
                        # than any previously identified waveform on this port
                        if { (! [info exists dft_cp_period]) || ($dft_cp_source_period < $dft_cp_period) } {
                            # get the period for the currect source and try to avoid rounding errors
                            set dft_cp_period  [ expr [ get_attribute period $dft_cp_source] / [ get_attribute divide_period $dft_cp_source] ]
                            set dft_cp_rise_pc [ expr 1.0 * [ get_attribute rise $dft_cp_source ] / [ get_attribute divide_rise $dft_cp_source ] ]
                            set dft_cp_fall_pc [ expr 1.0 * [ get_attribute fall $dft_cp_source ] / [ get_attribute divide_fall $dft_cp_source ] ]
                            set dft_cp_rise    [ expr $dft_cp_period * $dft_cp_rise_pc ]
                            set dft_cp_fall    [ expr $dft_cp_period * $dft_cp_fall_pc ]
                            set dft_cp_width   [ expr abs(int($dft_cp_rise - $dft_cp_fall)) ]
                            # calulate the frequency from ps to MHz so just * 1E6
                            set dft_cp_freq    [ expr 1.0 / $dft_cp_period * 1E6 ]
                            # store waveform info in atpg_clocks array
                            set atpg_clocks($dft_cp_base) [ list $dft_cp_width $dft_cp_freq ]
                            set atpg_ports($dft_cp_source) $dft_cp_base
                        }
                    }
                }
            }
        }

        array unset disabled_paths

        # identify clock-to-clock paths that have been disabled
        foreach path_disable [ find / -exception path_disables/* ] {
            if { [ get_attribute through_points $path_disable ] != "" } { continue }
            foreach from_point [ get_attribute from_points $path_disable ] {
                foreach to_point [ get_attribute to_points $path_disable ] {
                    if { [ info exists atpg_ports($from_point) ] && [ info exists atpg_ports($to_point) ] } {
                        set from_clock_pin $atpg_ports($from_point)
                        set to_clock_pin   $atpg_ports($to_point)
                        set disabled_paths($from_clock_pin)($to_clock_pin) 1
                    }
                }
            }
        }

        # now output what we have learned in the form
        #   <clock_name> {posedge,<pulse_width>ps} {<clock_freq>MHz};
        foreach dft_cp_base [array names atpg_clocks] {
            set dft_cp_width [ lindex $atpg_clocks($dft_cp_base) 0 ]
            set dft_cp_freq  [ lindex $atpg_clocks($dft_cp_base) 1 ]
            puts $accfh [format "%-12s {posedge, %5dps} {%7.3fMHz};" $dft_cp_base $dft_cp_width $dft_cp_freq]
            puts "        Found clock ${dft_cp_base} with frequency ${dft_cp_freq}MHz\n"
        }
        # add any clock-to-clock checks that have not been disabled
        foreach dft_cp_base1 [array names atpg_clocks] {
            foreach dft_cp_base2 [array names atpg_clocks] {
                if { $dft_cp_base1 == $dft_cp_base2 } { continue }
                if [ info exists disabled_paths($dft_cp_base1)($dft_cp_base2) ] { continue }
                set dft_cp_width1 [ lindex $atpg_clocks($dft_cp_base1) 0 ]
                set dft_cp_freq1  [ lindex $atpg_clocks($dft_cp_base1) 1 ]
                set dft_cp_width2 [ lindex $atpg_clocks($dft_cp_base2) 0 ]
                set dft_cp_freq2  [ lindex $atpg_clocks($dft_cp_base2) 1 ]
                if { $dft_cp_freq2 > $dft_cp_freq1 } {
                    set dft_cp_freq $dft_cp_freq2
                } else {
                    set dft_cp_freq $dft_cp_freq1
                }
                puts $accfh [format "%-12s {posedge, %5dps} %-12s {posedge, %5dps} {%7.3fMHz};" $dft_cp_base1 $dft_cp_width1 $dft_cp_base2 $dft_cp_width2 $dft_cp_freq]
                puts "        Inferring valid clock-to-clock relationship from ${dft_cp_base1} to ${dft_cp_base2}\n"
            }
        }

    }

    close $accfh

    puts "\n DFT clock constraints extraction complete \n"

}
