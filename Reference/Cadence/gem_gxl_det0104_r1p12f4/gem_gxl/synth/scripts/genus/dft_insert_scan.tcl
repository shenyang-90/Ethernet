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
#    Primary Unit Name :      dft_insert_scan.tcl
#
#          Description :      RC scan insertion script sourced by rc_flow.tcl
#
#      Original Author :      Anna Gilbert
#
#------------------------------------------------------------------------------

# Echo commands in RC log
set_db / .source_verbose true
set_db / .source_verbose_info false

#replace scan commands have been removed as now done during mapping

#Unset preserve on pre mapped netlists
if [info exists PRESERVE_PRE_MAPPED_SUB_LIST] {
    foreach gset $PRESERVE_PRE_MAPPED_SUB_LIST {
        set_db [get_db modules $gset] .preserve false
        set_db [get_db modules $gset] .dft_dont_scan false
    }
}

#Unset preserve on modules
if [info exists PRESERVE_LIST] {
    foreach gset $PRESERVE_LIST {
        set gsub [get_db modules $gset]
        if { [llength $gsub] > 0 } {
            set_db $gsub .preserve false
	    set_db $gsub .dft_dont_scan false
           } else {
            set gsub [get_lib_cells $gset]
            if { [llength $gsub] > 0 } {
                set_db $gsub .preserve false
		set_db $gsub .dft_dont_scan false
            } else {
                puts "Module $gset is not in design"
                suspend
            }
        }
    }
}

## Re-run shift-register identification to pickup the sync flops that have now been unpreserved ready for scan insertion 
if {[info exists PRESERVE_LIST] || [info exists PRESERVE_PRE_MAPPED_SUB_LIST]} {
set_db / .dft_prefix DFT_shiftreg_
# Identify pre-existing scan chain segments
identify_shift_register_scan_segments -incremental
set_db / .dft_prefix DFT_
}

# Run a final DFT rule check before connecting chains
check_dft_rules -advanced -max_print_violations -1 > $_REPORTS_PATH/${DESIGN}_check_dft_rules.dftInsertScan.rpt

report dft_registers -fail_tdrc > $_REPORTS_PATH/$DESIGN.dftInsertScan.dft_scanFailRegs

report dft_setup > $_REPORTS_PATH/$DESIGN.dftInsertScan.dftSetup


# Bit blast $HARD_MACRO_SCAN_INS
if [info exists HARD_MACRO_SCAN_INS] {
    foreach existing_scan_in $HARD_MACRO_SCAN_INS {
        set index [lsearch -exact $HARD_MACRO_SCAN_INS $existing_scan_in]
        if [regexp {(\S+)\[(\d+):?(\d*)\]$} $existing_scan_in dummy scan_in_port scan_in_range_left scan_in_range_right] {
            if { $scan_in_range_right == "" } { set scan_in_range_right $scan_in_range_left }
            for {set i $scan_in_range_left} {$i >= $scan_in_range_right} {incr i -1} {
                if { [set scan_in_port_bit [get_db ports ${scan_in_port}\[$i\] -if {.direction == in} ]] != "" } {
                    set HARD_MACRO_SCAN_INS [linsert $HARD_MACRO_SCAN_INS $index [vname $scan_in_port_bit]]
                }
            }
            set index [lsearch -exact $HARD_MACRO_SCAN_INS $existing_scan_in]
            set HARD_MACRO_SCAN_INS [lreplace $HARD_MACRO_SCAN_INS $index $index]
        } else {
            if { [set scan_in_port_bus [get_db port_busses $existing_scan_in -if { .direction == in }]] != "" } {
                foreach scan_in_port_bit [get_db $scan_in_port_bus .bits] {
                    set HARD_MACRO_SCAN_INS [linsert $HARD_MACRO_SCAN_INS $index [vname $scan_in_port_bit]]
                }
                set index [lsearch -exact $HARD_MACRO_SCAN_INS $existing_scan_in]
                set HARD_MACRO_SCAN_INS [lreplace $HARD_MACRO_SCAN_INS $index $index]
            }
        }
    }
}

# Bit blast $RTL_SCAN_INS
if [info exists RTL_SCAN_INS] {
    foreach existing_scan_in $RTL_SCAN_INS {
        set index [lsearch -exact $RTL_SCAN_INS $existing_scan_in]
        if [regexp {(\S+)\[(\d+):?(\d*)\]$} $existing_scan_in dummy scan_in_port scan_in_range_left scan_in_range_right] {
            if { $scan_in_range_right == "" } {
                set scan_in_range_right $scan_in_range_left
            }
            for {set i $scan_in_range_left} {$i >= $scan_in_range_right} {incr i -1} {
                if { [set scan_in_port_bit [get_db ports ${scan_in_port}\[$i\] -if { .direction == in }]] != "" } {
                    set RTL_SCAN_INS [linsert $RTL_SCAN_INS $index [vname $scan_in_port_bit]]
                }
            }
            set index [lsearch -exact $RTL_SCAN_INS $existing_scan_in]
            set RTL_SCAN_INS [lreplace $RTL_SCAN_INS $index $index]
        } else {
            if { [set scan_in_port_bus [get_db port_busses $existing_scan_in -if { .direction == in }]] != "" } {
                foreach scan_in_port_bit [get_db $scan_in_port_bus .bits] {
                    set RTL_SCAN_INS [linsert $RTL_SCAN_INS $index [vname $scan_in_port_bit]]
                }
                set index [lsearch -exact $RTL_SCAN_INS $existing_scan_in]
                set RTL_SCAN_INS [lreplace $RTL_SCAN_INS $index $index]
            }
        }
    }
}


if [info exists PRESERVE_LIST] {
    set gsub [get_db modules *]
    set_db $gsub .preserve false
}


#define hard_macro scanchains
if {$CONNECT_CHAINS && $HARD_MACRO} {

    foreach HARD_MACRO_SCAN_IN_NAMES $HARD_MACRO_SCAN_INS {
        puts "name is $HARD_MACRO_SCAN_IN_NAMES"
        set HARD_MACRO_SCAN_IN_PORTS [get_db ports $HARD_MACRO_SCAN_IN_NAMES]
        foreach HARD_MACRO_SCAN_IN_NAME $HARD_MACRO_SCAN_IN_PORTS {
            puts "result is $HARD_MACRO_SCAN_IN_NAME"
            regsub -all {(scan_?)in} [vname $HARD_MACRO_SCAN_IN_NAME] {\1out} HARD_MACRO_SCAN_OUT_NAME
            puts "output is $HARD_MACRO_SCAN_OUT_NAME"
            regsub -all {scan_?in} [vname $HARD_MACRO_SCAN_IN_NAME] {chain} HARD_MACRO_SCAN_CHAIN_NAME
            puts "chain name $HARD_MACRO_SCAN_CHAIN_NAME input $HARD_MACRO_SCAN_IN_NAME output $HARD_MACRO_SCAN_OUT_NAME"
            define_dft scan_chain -name $HARD_MACRO_SCAN_CHAIN_NAME -sdo $HARD_MACRO_SCAN_OUT_NAME -sdi $HARD_MACRO_SCAN_IN_NAME -complete -analyze
        }
    }

    if { [ info exists MAX_SCAN_CHAIN_LENGTH ] && ( $MAX_SCAN_CHAIN_LENGTH > 0 ) } {
        set_db design:$DESIGN_FULL .dft_max_length_of_scan_chains $MAX_SCAN_CHAIN_LENGTH 
        set numScanChains [connect_scan_chains -incremental -preview -auto_create]
    } elseif { [ info exists NO_OF_SCAN_CHAINS ] && ( $NO_OF_SCAN_CHAINS > [llength $HARD_MACRO_SCAN_INS] ) } {
        set numScanChains [expr $NO_OF_SCAN_CHAINS - [llength $HARD_MACRO_SCAN_INS]]
        set_db design:$DESIGN_FULL .dft_min_number_of_scan_chains $numScanChains
    } else {
        puts "\n ############################################################################### \n"
        puts " # DFT ERROR: Neither MAX_SCAN_CHAIN_LENGTH or NO_OF_SCAN_CHAINS have been set # \n"
        puts " #            Please review project.tcl to correct this                        # \n"
        puts "\n ############################################################################### \n"
        exit 1
    }

    if { $numScanChains > 0 } {
        set suffix 1
        for {set i 1} {$i <= $numScanChains} {incr i 1} {
            if { [info exists RTL_SCAN_INS] && ([llength $RTL_SCAN_INS] >= $i) } {
                set scanin_port [lindex $RTL_SCAN_INS [expr $i - 1]]
                regsub {(scan_?)in} $scanin_port {\1out} scanout_port
                regsub {^i_} $scanout_port {o_} scanout_port
                puts "define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -non_shared_output -terminal_lockup level_sensitive"
                define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -non_shared_output -terminal_lockup level_sensitive
            } else {
                if { $numScanChains == 1 } {
                    set scanin_port  "${DESIGN}_scanin"
                    set scanout_port "${DESIGN}_scanout"
                } else {
                    set scanin_port  "${DESIGN}_scanin_$suffix"
                    set scanout_port "${DESIGN}_scanout_$suffix"
                    incr suffix
                }
                puts "define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -create_ports -terminal_lockup level_sensitive"
                define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -create_ports -terminal_lockup level_sensitive
            }
            set_db [get_db ports $scanin_port] .lp_asserted_toggle_rate 0
            set_db [get_db ports $scanin_port] .lp_asserted_probability 0
        }
    }

    if { [ info exists MAX_SCAN_CHAIN_LENGTH ] && ( $MAX_SCAN_CHAIN_LENGTH > 0 ) } {
        connect_scan_chains -incremental -chains [vfind / -scan_chain chain*]
    } else {
        connect_scan_chains -incremental -chains [vfind / -scan_chain chain*] -dont_exceed_min_number_of_scan_chains
    }

}

if {$CONNECT_CHAINS && !$HARD_MACRO} {

    if { [ info exists MAX_SCAN_CHAIN_LENGTH ] && ( $MAX_SCAN_CHAIN_LENGTH > 0 ) } {
        set_db design:$DESIGN_FULL .dft_max_length_of_scan_chains $MAX_SCAN_CHAIN_LENGTH
        set numScanChains [connect_scan_chains -preview -auto_create]
    } elseif { [ info exists NO_OF_SCAN_CHAINS ] && ( $NO_OF_SCAN_CHAINS > 0 ) } {
        set numScanChains $NO_OF_SCAN_CHAINS
        set_db design:$DESIGN_FULL .dft_min_number_of_scan_chains $numScanChains
    } else {
        puts "\n ############################################################################### \n"
        puts " # DFT ERROR: Neither MAX_SCAN_CHAIN_LENGTH or NO_OF_SCAN_CHAINS have been set # \n"
        puts " #            Please review project.tcl to correct this                        # \n"
        puts "\n ############################################################################### \n"
        exit 1
    }

    if { $numScanChains > 0 } {
        set suffix 1
        for {set i 1} {$i <= $numScanChains} {incr i 1} {
            if { [info exists RTL_SCAN_INS] && ([llength $RTL_SCAN_INS] >= $i) } {
                set scanin_port [lindex $RTL_SCAN_INS [expr $i - 1]]
                regsub {(scan_?)in} $scanin_port {\1out} scanout_port
                regsub {^i_} $scanout_port {o_} scanout_port
                puts "define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -non_shared_output -terminal_lockup level_sensitive"
                define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -non_shared_output -terminal_lockup level_sensitive
            } else {
                if { $numScanChains == 1 } {
                    set scanin_port  "${DESIGN}_scanin"
                    set scanout_port "${DESIGN}_scanout"
                } else {
                    set scanin_port  "${DESIGN}_scanin_$suffix"
                    set scanout_port "${DESIGN}_scanout_$suffix"
                    incr suffix
                }
                puts "define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -create_ports -terminal_lockup level_sensitive"
                define_dft scan_chain -name chain$i -sdi $scanin_port -sdo $scanout_port -create_ports -terminal_lockup level_sensitive
            }
            set_db [get_db ports $scanin_port] .lp_asserted_toggle_rate 0
            set_db [get_db ports $scanin_port] .lp_asserted_probability 0
        }
    }

    if { [ info exists MAX_SCAN_CHAIN_LENGTH ] && ( $MAX_SCAN_CHAIN_LENGTH > 0 ) } {
        connect_scan_chains
    } else {
        connect_scan_chains -dont_exceed_min_number_of_scan_chains
    }

}


write_hdl > $_OUTPUTS_PATH/$DESIGN.dftInsertScan.v


if {$CONNECT_CHAINS} {

    #######################################################
    # Final DfT Reports
    #######################################################

    report dft_registers  -fail_tdrc > $_DFT_REPORTS_PATH/$DESIGN.dft_scanFailRegs
    report dft_registers  -dont_scan > $_DFT_REPORTS_PATH/$DESIGN.dft_dontScanRegs
    report dft_registers             > $_DFT_REPORTS_PATH/$DESIGN.dft_chainRegs
    report dft_chains                > $_DFT_REPORTS_PATH/$DESIGN.dft_chains
    write_atpg -cadence              > $_OUTPUTS_PATH/$DESIGN.assignfile

    ###did we want to setup to write out ATPG scripts?
    #write_dft_atpg -libraries -dft_configuration_mode -directory $dft_dir

    write_dft_atpg \
        -directory $_GENUSMODUS_PATH/FULLSCAN \
        -library "$ATPGLIB"
    #######################################################

    #report area              > $_REPORTS_PATH/${DESIGN}_area.rpt
    #report gates             > $_REPORTS_PATH/${DESIGN}_gates.rpt
    #report timing -worst 100 > $_REPORTS_PATH/${DESIGN}_timing.rpt


    # Write template ET scripts


    set_db / .dft_true_time_flow true

    write_dft_atpg \
        -directory $_GENUSMODUS_PATH/DELAY \
        -library "$ATPGLIB" \
        -delay \
	-tcl

    # Write scan absstracts in CTL and native RC format

      write_dft_abstract_model -ctl > $_OUTPUTS_PATH/$DESIGN.ctl
      write_dft_abstract_model > $_OUTPUTS_PATH/$DESIGN.scan_abstract

      file copy -force ${_GENUSMODUS_PATH}/DELAY/$DESIGN.FULLSCAN.pinassign ${_GENUSMODUS_PATH}/DELAY/$DESIGN.DELAY.pinassign
      
}


# Disable commands in RC log
set_db / .source_verbose false

#Preserve pre mapped netlists - suitable for hierarchichal synthesis
if [info exists PRESERVE_PRE_MAPPED_SUB_LIST] {
    foreach gset $PRESERVE_PRE_MAPPED_SUB_LIST {
        set_db [get_db modules $gset] .preserve true
    }
}

if [info exists PRESERVE_LIST] {
    foreach gset $PRESERVE_LIST {
        set gsub [get_db modules $gset]
        if { [llength $gsub] > 0 } {
            set_db $gsub .preserve true } else {
            set gsub [get_db libcells $gset]
            if { [llength $gsub] > 0 } {
                set_db $gsub .preserve true 
            } else {
                puts "Module $gset is not in design"
                suspend
            }
        }
    }
}
