//------------------------------------------------------------------------------
//                                     
//            CADENCE                    Copyright (c) 2001-2013
//                                       Cadence Design Systems, Inc.
//                                       All rights reserved.
//
//  This work may not be copied, modified, re-published, uploaded, executed, or
//  distributed in any way, in any medium, whether in whole or in part, without
//  prior written permission from Cadence Design Systems, Inc.
//------------------------------------------------------------------------------
//
//    Primary Unit Name :      cdc.do
//
//          Description :      Example script clock domain checks. 
//
//      Original Author :      Mark Lewis
//
//------------------------------------------------------------------------------
//*********************************************************************************
// Setup
//*********************************************************************************
tclmode
  
  // Project specific variables
  // Read project.tcl from current directory if it exists, otherwise ERROR
  if [file exists "./project.tcl"] {
     puts "Sourcing ./project.tcl ..."
     source ./project.tcl
  } else {
     puts "ERROR: Can't find project.tcl in current working directory."
     exit
  }

  // Create reports directories 
    if [file isdirectory $_CCD_RPT_PATH] {
      echo "Directory $_CCD_RPT_PATH already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH
    }
    
    if [file isdirectory $_CCD_RPT_PATH/cdc] {
      echo "Directory $_CCD_RPT_PATH/cdc already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/cdc
    }
    
    if [file isdirectory $_CCD_RPT_PATH/cdc/raw] {
      echo "Directory $_CCD_RPT_PATH/cdc/raw already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/cdc/raw
    }

    if [file isdirectory $_CCD_RPT_PATH/general] {
      echo "Directory $_CCD_RPT_PATH/general already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/general
    }

    if [file isdirectory $_CCD_RPT_PATH/lint] {
      echo "Directory $_CCD_RPT_PATH/lint already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/lint
    }
    
    if [file isdirectory $_CCD_RPT_PATH/lint/raw] {
      echo "Directory $_CCD_RPT_PATH/lint/raw already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/lint/raw
    }

    if [file isdirectory $_CCD_RPT_PATH/modelling] {
      echo "Directory $_CCD_RPT_PATH/modelling already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/modelling
    }

    if [file isdirectory $_CCD_RPT_PATH/sdc] {
      echo "Directory $_CCD_RPT_PATH/sdc already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/sdc
    }
    
    if [file isdirectory $_CCD_RPT_PATH/sdc/raw] {
      echo "Directory $_CCD_RPT_PATH/sdc/raw already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/sdc/raw
    }
    
    if [file isdirectory $_CCD_RPT_PATH/sdc_multimode] {
      echo "Directory $_CCD_RPT_PATH/sdc_multimode already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/sdc_multimode
    }
    
    if [file isdirectory $_CCD_RPT_PATH/sdc_multimode/raw] {
      echo "Directory $_CCD_RPT_PATH/sdc_multimode/raw already exists. Existing reports will be overwritten";
    } else {
      mkdir -p $_CCD_RPT_PATH/sdc_multimode/raw
    }

    if [file isdirectory $_CCD_INPUT_PATH] {
      echo "Directory $_CCD_INPUT_PATH already exists. Check to make sure filters from this directory are correct for this configuration";
    } else {
      mkdir -p $_CCD_INPUT_PATH
      foreach i [glob $IPF_DESIGN_FLOW_SCRIPTS/ccd/example_filters/*] {
      cp $i $_CCD_INPUT_PATH/
      }
    }
    
  // Load up DaChings report script to beautify results
  package require cdc_check_app

  // Group related bit violations into single word violation
  // Remove to debug at bit-level. This can be helpful in reducing the number
  // of violations to debug by grouping buses.
    set_attribute [find -conformal] cdc_word_level  1
    
  // This attribute is currently under verification by R&D and can be used as trial to
  // reduce convergence issues.  NOTE: Please only use as a trial to reduce fails and then once
  // these fails have been filtered/fixed then remove this for final checks prior to sign off 
  // until such times as the command has been formally released.
  //  set_attribute [find -conformal ] cdc_convergence_report_style merged

  // Undock rulmanager/Schematic windows for debug
    set_attribute [find -conformal] undock_rulemgr_notebook 1
    set_attribute [find -conformal] undock_rulemgr_notepage 1
 
  // Set logfile - existing file is replaced
    set_log_file $_CCD_RPT_PATH/general/${DESIGN}.log -replace

  // Setup a global varable to be used in procs for filterreport
    set ::filter_rpt $_CCD_INPUT_PATH/ccd_filters.do

  //TCL proc to write filter. Simply use "write_filters" on the command line
  // to write filters to the file specified by filter_rpt above
  proc write_filters {} {  
      if [file exists $::filter_rpt] {
        exec cp $::filter_rpt $::filter_rpt.bak
        write_rule_filter $::filter_rpt -word_level -replace -tcl -all 
      } else {
        write_rule_filter $::filter_rpt -tcl -word_level -all      
      } 
  }  

vpxmode

  usage -auto

//*********************************************************************************
// Blackbox components
//*********************************************************************************

  
  /// Macros, FC blocks and memories
  tclmode
  # Add Notranslate modules
    if {[info exists BLACKBOXES]}  {
      foreach bbname $BLACKBOXES {
        add_notranslate_modules -design "$bbname"
        puts "$bbname being added to the notranslate list"
      }
    }

  /// Memories
    // add notranslate filepathnames $LEC_tmp_proj_dir/syn/memories/*.lib
    // NOTE: .lib should automatically be blackboxed
    // add notranslate filepathnames $LEC_tmp_proj_dir/lib/memory/*.v


//*********************************************************************************
// Read Librarys
//*********************************************************************************

tclmode
  if { $env(CCD_NOLIBS) == 0 } {
    set list_file [open ./liblist.f RDONLY]
    set buffer [read -nonewline $list_file]
    foreach entry $buffer {
       read_library -append -liberty -statetable -pg_pin "$entry"
    }
  }

	
//*********************************************************************************
// Load Lint Setup
//*********************************************************************************
 
tclmode
  dofile  $IPF_DESIGN_FLOW_SCRIPTS/ccd/ccd_lint.setup
vpxmode


//*********************************************************************************
// HDL Search Paths
//*********************************************************************************


tclmode 
# Add RTL search Path
  if [info exists HDL_SEARCH_PATH] {   
    foreach paths $HDL_SEARCH_PATH {
      add_search_path -design $paths 
    }     
  }  
vpxmode

//*********************************************************************************
// Read Design
//*********************************************************************************
tclmode

eval read_design  -define RTL_BEHV -define NO_SVA -Systemverilog -noelab -File $RTL_F_FILE

   elaborate design -root ${DESIGN}


vpxmode
report rule check -category library_design -status fail -verbose


//*********************************************************************************
// Reporting 
//*********************************************************************************

tclmode
    report_design_data ${DESIGN} -summary > $_CCD_RPT_PATH/general/report.design_summary
    report_design_data ${DESIGN} -verbose  >> $_CCD_RPT_PATH/general/report.design_summary

    echo "Floating Signals" > $_CCD_RPT_PATH/general/report.floating_signals
    report_floating_signal  >> $_CCD_RPT_PATH/general/report.floating_signals

    echo "Black Box Report"            >  $_CCD_RPT_PATH/general/report.bbox
    report_black_box -module   -detail >> $_CCD_RPT_PATH/general/report.bbox
    report_black_box -instance -detail >> $_CCD_RPT_PATH/general/report.bbox

    echo "Undefined Black Box Report"                   >  $_CCD_RPT_PATH/general/report.bbox.undefined
    report_black_box -module   -detail -class undefined >> $_CCD_RPT_PATH/general/report.bbox.undefined
    report_black_box -instance -detail -class undefined >> $_CCD_RPT_PATH/general/report.bbox.undefined
    
    echo "Empty Black Box Report"                   >  $_CCD_RPT_PATH/general/report.bbox.empty
    report_black_box -module   -detail -class empty >> $_CCD_RPT_PATH/general/report.bbox.empty
    report_black_box -instance -detail -class empty >> $_CCD_RPT_PATH/general/report.bbox.empty
vpxmode

 
//*********************************************************************************
// Initialise resets
// Only required for functional checks
//*********************************************************************************
tclmode
    if [file exists $_CCD_INPUT_PATH/init.seq] {
        read_initial_state $_CCD_INPUT_PATH/init.seq -seq
    }  
vpxmode


//*********************************************************************************
//* Loads the SDC rule set. 
//* SDC rules must be loaded before reading in the SDC file(s).
//*********************************************************************************

  add rule set -file ccd_default_sdc_ruleset.tcl

//*********************************************************************************
// Read in Constraints
//*********************************************************************************


tclmode
set num_modes [llength ($DESIGN_MODES)]
if { ($num_modes > 1) && $env(SDC_MULTI_MODE)} {
        puts "The following modes have been defined for MULTI MODE checks: $DESIGN_MODES"
      
        
  # Read in each SDC
  foreach entry $DESIGN_MODES {

  add_sdc_mode ${entry}
  
  	if {[info exists CONFIG] && ($CONFIG != "") } {
      eval read_sdc -mode ${entry} -nosensitive $SDC_PATH/${DESIGN}_${CONFIG}.$entry.sdc -Replace
	  } else {
      eval read_sdc -mode ${entry} -nosensitive $SDC_PATH/${DESIGN}.$entry.sdc -Replace
	  }
  }
  
} else {

# Single functional mode
  if {[info exists CONFIG] && ($CONFIG != "") } {
    eval read_sdc -nosensitive $SDC_PATH/${DESIGN}_${CONFIG}.func.sdc -Replace
  } else {
    eval read_sdc -nosensitive $SDC_PATH/${DESIGN}.func.sdc -Replace
  }
}
   
 //*********************************************************************************
/// SDC LINT checks
//*********************************************************************************

// Apply the refined SDC rules
tclmode
  if {$env(USE_REFINED_CCD_SDC_RULES)} {
    dofile $IPF_DESIGN_FLOW_SCRIPTS/ccd/ccd_sdc_refined_rules.txt \
  } 
vpxmode
 
//*********************************************************************************
/// Instrument design
//*********************************************************************************
vpxmode
    set system mode verify

//*********************************************************************************
/// Check clocks
//*********************************************************************************

tclmode
    report_clock_group > $_CCD_RPT_PATH/general/report.clocks
vpxmode  
    report clock group

  // Once clocks have been reviewed, commit them
    commit clock
   

//*********************************************************************************
/// Define ruleset
//*********************************************************************************

  // Default rule set for CDC

tclmode
  if { $env(SDC_MULTI_MODE) == 0 } {
      add_rule_set -file ccd_default_cdc_ruleset.tcl

  # Read in collated Filters file - New for 15.1
#      if [file exists $_CCD_INPUT_PATH/ccd_filters.do] {
#        echo "$_CCD_INPUT_PATH/ccd_filters.do - Adding filters";
#        tclmode
#        dofile $_CCD_INPUT_PATH/ccd_filters.do
#    }  
  } 

vpxmode

//*********************************************************************************
// Add filters for LINT Checks
// All rule filters should be added to this file with sufficient explanations
//*********************************************************************************
tclmode  
  // Read in Design/Library Filters
      if [file exists $_CCD_INPUT_PATH/filters_hdl_checks.do] {
        echo "$_CCD_INPUT_PATH/filters_hdl_checks.do - Adding filters";
        dofile $_CCD_INPUT_PATH/filters_hdl_checks.do
        report_rule_filter > $_CCD_RPT_PATH/lint/report.filters_hdl_checks
    }  

vpxmode


//*********************************************************************************
// LINT Checks Reports
//*********************************************************************************
tclmode

  // All checks
    report_rule_check -nofiltered hdl_default_checks/* -summary > $_CCD_RPT_PATH/lint/report.lint.all
    report_rule_check -nofiltered hdl_default_checks/* -verbose >> $_CCD_RPT_PATH/lint/report.lint.all

  // Checks with only Errors and Warnings
    report_rule_check -nofiltered hdl_default_checks/* -severity error -severity warning -status fail            > $_CCD_RPT_PATH/lint/report_lint.nofiltered.fail
    report_rule_check -nofiltered hdl_default_checks/* -severity error -severity warning -status fail -verbose  >> $_CCD_RPT_PATH/lint/report_lint.nofiltered.fail
    report_rule_check -complete   hdl_default_checks/* -severity error -severity warning -status fail            > $_CCD_RPT_PATH/lint/raw/report_lint.raw.lint.fail
    report_rule_check -complete   hdl_default_checks/* -severity error -severity warning -status fail -verbose  >> $_CCD_RPT_PATH/lint/raw/report_lint.raw.lint.fail
    report_rule_check -nofiltered hdl_default_checks/* -severity note                    -status fail            > $_CCD_RPT_PATH/lint/report_lint.nofiltered.note
    report_rule_check -nofiltered hdl_default_checks/* -severity note                    -status fail -verbose  >> $_CCD_RPT_PATH/lint/report_lint.nofiltered.note

vpxmode


tclmode    
if {$env(CCD_SDC_CHECKS)} {        
    // Apply SDC Lint Filters if they exist
      if [file exists $_CCD_INPUT_PATH/filters_sdc_lint.do] {
        echo "$_CCD_INPUT_PATH/filters_sdc_lint.do - Adding filters";
        dofile $_CCD_INPUT_PATH/filters_sdc_lint.do
    }  
  if { ($num_modes > 1) && $env(SDC_MULTI_MODE)} {
    foreach entry $DESIGN_MODES {
    echo ${entry}
      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_report.nofiltered.${entry}.summary
      report_rule_check -nofiltered            -sdc_mode ${entry} -sdc_lint *                             >> $_CCD_RPT_PATH/sdc_multimode/sdc_report.nofiltered.${entry}.summary

      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_report.nofiltered.${entry}.verbose
      report_rule_check -nofiltered            -sdc_mode ${entry} -sdc_lint *       -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_report.nofiltered.${entry}.verbose

      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_report.${entry}.raw.verbose
      report_rule_check -complete              -sdc_mode ${entry} -sdc_lint *       -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_report.${entry}.raw.verbose

      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_lint_checks.nofiltered.${entry}.error
      report_rule_check -nofiltered SDC_LINT_* -sdc_mode ${entry} -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_lint_checks.nofiltered.${entry}.error

      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_lint_checks.nofiltered.${entry}.warning
      report_rule_check -nofiltered SDC_LINT_* -sdc_mode ${entry} -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_lint_checks.nofiltered.${entry}.warning

      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_lint_checks.${entry}.raw.error
      report_rule_check -complete   SDC_LINT_* -sdc_mode ${entry} -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_lint_checks.${entry}.raw.error

      echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_lint_checks.${entry}.raw.warning
      report_rule_check -complete   SDC_LINT_* -sdc_mode ${entry} -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_lint_checks.${entry}.raw.warning
      } 
  } else {

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/sdc_report.nofiltered.summary
      report_rule_check -nofiltered             -sdc_lint *                             >> $_CCD_RPT_PATH/sdc/sdc_report.nofiltered.summary

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/sdc_report.nofiltered.verbose
      report_rule_check -nofiltered             -sdc_lint *       -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_report.nofiltered.verbose

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/raw/sdc_report.raw.verbose
      report_rule_check -complete               -sdc_lint *       -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_report.raw.verbose

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/sdc_lint_checks.nofiltered.error
      report_rule_check -nofiltered SDC_LINT_*  -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_lint_checks.nofiltered.error

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/sdc_lint_checks.nofiltered.warning
      report_rule_check -nofiltered SDC_LINT_*  -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_lint_checks.nofiltered.warning

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/raw/sdc_lint_checks.raw.error
      report_rule_check -complete   SDC_LINT_*  -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_lint_checks.raw.error

      echo "SDC Report" > $_CCD_RPT_PATH/sdc/raw/sdc_lint_checks.raw.warning
      report_rule_check -complete   SDC_LINT_*  -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_lint_checks.raw.warning
      }  
}
      
//*********************************************************************************
// Running Policy Checks on SDC CLOCKS and SDC Constraints
//*********************************************************************************
  
tclmode
if {$env(CCD_SDC_CHECKS)} {
    // Apply SDC Policy Check Filters if required
      if [file exists $_CCD_INPUT_PATH/filters_sdc_policy.do] {
        echo "$_CCD_INPUT_PATH/filters_sdc_policy.do - Adding filters";
        dofile $_CCD_INPUT_PATH/filters_sdc_policy.do
    } 
  if { ($num_modes > 1) && $env(SDC_MULTI_MODE)} {
 
    // Running Policy Checks on SDC CLOCKS
    #run_rule_check sdc_def_checks/sdc_clock_checks/CCD_CLK*
    
    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_clk_checks.nofiltered.error
    report_rule_check -nofiltered sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_clk_checks.nofiltered.error

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_clk_checks.nofiltered.warning
    report_rule_check -nofiltered sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_clk_checks.nofiltered.warning

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_clk_checks.raw.error
    report_rule_check -complete   sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_clk_checks.raw.error

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_clk_checks.raw.warning
    report_rule_check -complete   sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_clk_checks.raw.warning

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_clk_checks.nofiltered.note
    report_rule_check -nofiltered sdc_def_checks -severity note    -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_clk_checks.nofiltered.note

   // Running Policy Checks on SDC Constraints
    run_rule_check sdc_def_checks
    
    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_policy_checks.nofiltered.error
    report_rule_check -nofiltered sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_policy_checks.nofiltered.error

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_policy_checks.nofiltered.warning
    report_rule_check -nofiltered sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_policy_checks.nofiltered.warning

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_policy_checks.raw.error
    report_rule_check -complete   sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_policy_checks.raw.error

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/raw/sdc_policy_checks.raw.warning
    report_rule_check -complete   sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/raw/sdc_policy_checks.raw.warning

    echo "SDC Report" > $_CCD_RPT_PATH/sdc_multimode/sdc_policy_checks.nofiltered.note
    report_rule_check -nofiltered sdc_def_checks -severity note    -status fail -verbose >> $_CCD_RPT_PATH/sdc_multimode/sdc_policy_checks.nofiltered.note

  } else {
  

    // Running Policy Checks on SDC CLOCKS
    run_rule_check sdc_def_checks/sdc_clock_checks/CCD_CLK*

    echo "SDC Clock Report" > $_CCD_RPT_PATH/sdc/sdc_clk_checks.nofiltered.error    
    report_rule_check -nofiltered sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_clk_checks.nofiltered.error

    echo "SDC Clock Report" > $_CCD_RPT_PATH/sdc/sdc_clk_checks.nofiltered.warning
    report_rule_check -nofiltered sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_clk_checks.nofiltered.warning

    echo "SDC Clock Report" > $_CCD_RPT_PATH/sdc/raw/sdc_clk_checks.raw.error    
    report_rule_check -complete   sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_clk_checks.raw.error

    echo "SDC Clock Report" > $_CCD_RPT_PATH/sdc/raw/sdc_clk_checks.raw.warning   
    report_rule_check -complete   sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_clk_checks.raw.warning

    echo "SDC Clock Report" > $_CCD_RPT_PATH/sdc/sdc_clk_checks.nofiltered.note    
    report_rule_check -nofiltered sdc_def_checks -severity note    -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_clk_checks.nofiltered.note

   // Running Policy Checks on SDC Constraints
    run_rule_check sdc_def_checks
    
    echo "SDC Policy Report" > $_CCD_RPT_PATH/sdc/sdc_policy_checks.nofiltered.error
    report_rule_check -nofiltered sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_policy_checks.nofiltered.error

    echo "SDC Policy Report" > $_CCD_RPT_PATH/sdc/sdc_policy_checks.nofiltered.warning
    report_rule_check -nofiltered sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_policy_checks.nofiltered.warning

    echo "SDC Policy Report" > $_CCD_RPT_PATH/sdc/raw/sdc_policy_checks.raw.error
    report_rule_check -complete   sdc_def_checks -severity error   -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_policy_checks.raw.error

    echo "SDC Policy Report" > $_CCD_RPT_PATH/sdc/raw/sdc_policy_checks.raw.warning
    report_rule_check -complete   sdc_def_checks -severity warning -status fail -verbose >> $_CCD_RPT_PATH/sdc/raw/sdc_policy_checks.raw.warning

    echo "SDC Policy Report" > $_CCD_RPT_PATH/sdc/sdc_policy_checks.nofiltered.note
    report_rule_check -nofiltered sdc_def_checks -severity note    -status fail -verbose >> $_CCD_RPT_PATH/sdc/sdc_policy_checks.nofiltered.note

  }
    
   //Report SDC filters 
    echo "SDC Filters Report" > $_CCD_RPT_PATH/sdc/sdc_report.filters
    report_rule_filter -rule sdc_def_checks/*/* >> $_CCD_RPT_PATH/sdc/sdc_report.filters

}   

tclmode
if { ($num_modes > 1) && $env(SDC_MULTI_MODE)} {
    printf "\n\n    Multi-Mode SDC checks are complete.\n"
    printf "    Review results in the reports directory or use set_gui to view results in GUI\n\n"
  if ($env(EXIT_CCD_RUN)) {
    exit
  } else {
   break
  }
}

vpxmode

//*********************************************************************************
/// Fifo Handling
//
//  There are various methods available for handling FIFOs.  The automatic
//  detection method can be used to discover the FIFOs in the design and the tool
//  will validate those which meet certain criteria. Any FIFOs which do not pass
//  will not be considered during structural checks so if there is failing FIFOs 
//  which should meet the standard valid FIFO criteria then these must be fixed
//  before running structural checks.  If the FIFO is expected to fail, for
//  example, it does not have gray code pointers, then it ca  be left as a 
//  failing FIFO but this must be documented at sign-off.
//
//  1) Run auto detection,  and save all PASSING files to a file
//    - add fifo instance -default
//  2) Commit the FIFOs to the database
//    - Commit fifo
//
//
//*********************************************************************************

  // (1) Detect FIFOs and report automatic FIFO detection
     add fifo instance -default
     report fifo instance -all -verb
        
  // (2) Commit all passing FIFOs 
    commit fifo

tclmode
    report_fifo_instance -all > $_CCD_RPT_PATH/general/report.fifo
    report_fifo_instance -fail -verbose >> $_CCD_RPT_PATH/general/report.fifo
vpxmode

//*********************************************************************************
// Add user defined sync modules
// If you have pre-verified synchronizers then they can be added using
// the user_sync_modules command
// There are two methods to do this as described below
//*********************************************************************************

// (1) Rule Instance Method when you want to apply only to specific clock crossings
 
  //tclmode
  //foreach rins_id_1 [find -ruleinst cdc_def_rs/cdc_checks/cdc*] {
  //  set_attribute $rins_id_1 \
  //     user_sync_modules [find -design "*clkmux_gl* syncr tgl_syncr bus_syncr \
  //                                       reg_bus_syncr gen_async_que \
  //                                       gen_async_que_brt gen_async_que_bwt \
  //                                      *gen_async_que*"]
  //}
    
// (1 )Rule Instance Method - Applied to set/reset checks 

  //tclmode
  //foreach rins_id_2 [find -ruleinst cdc_def_rs/setrst_checks/*] {
  //  set_attribute $rins_id_2 \
  //     user_sync_modules [find -design "*create_rst_bp*"]
  //}    

// (2) ROOT attribute method

  //set sync_mods [find -design "syncr tgl_syncr bus_syncr reg_bus_syncr \
  //                              gen_async_que gen_async_que_brt \
                                  gen_async_que_bwt *gen_async_que*"]
				
  //set_attribute [find -conformal] cdc_user_sync_modules $sync_mods
  //set ccd_user_syncs [get_attribute [find -conformal] cdc_user_sync_modules] 
  //echo $ccd_user_syncs > $_CCD_RPT_PATH/general/report.user_sync_modules

vpxmode

      
//*********************************************************************************
/// Add Static registers
/// Any register within the design that is considered static can make CDC
/// checks run more efficiently. 
//*********************************************************************************

tclmode
 // Get static registers add input ports from file
if {[info exists STATICS_FILE ] && [file exists "$STATICS_FILE"]} {
  puts "Using static registers from $STATICS_FILE"

  set list_file [open $STATICS_FILE RDONLY]
  set buffer [read -nonewline $list_file]
  puts $buffer
  set statics_list ""

  foreach entry $buffer {
      set statics_list [concat [find -instance ${entry}] $statics_list]; set statics_list [concat [find -port ${entry}] $statics_list]
  }
  
  foreach entry $buffer {
    set_attribute -add_one [find -conformal] cdc_config_objects [find -port ${entry}]
  }
 
  foreach entry $buffer {
    set_attribute -add_one [find -conformal] cdc_config_objects [find -instance ${entry}]
  }

  
  close $list_file

  if [expr {$statics_list ne ""}] {   
  // Report all statics that have ben accepted by the tool 
   if [file exists ${_CCD_RPT_PATH}/general/report.statics] {
      file delete -force ${_CCD_RPT_PATH}/general/report.statics
   }

  echo "List of Statics" > ${_CCD_RPT_PATH}/general/report.statics
    set all_statics_accepted [get_attribute [find -conformal] cdc_config_objects]
      foreach statics $all_statics_accepted {
        echo $statics >> ${_CCD_RPT_PATH}/general/report.statics
      }     
    }   
} else {
  puts "No static registers or ports defined. NOTE: adding statics can improve CDC performance!"
}
vpxmode



//*********************************************************************************
// Delete checks on clocks that are not to be verified
//*********************************************************************************

tclmode
  // virtual clocks? 
  //delete_rule_instance cdc_def_rs/cdc_checks/*vir*

  // Ignore JTAG clock
  //delete_rule_instance cdc_def_rs/cdc_checks/*JTAG_CLK*

  // Ignore overclocking clocks
  //delete_rule_instance cdc_def_rs/cdc_checks/*clkpll_625*
vpxmode

//*********************************************************************************
// Rule manipulation
// Change certain design rules based on design methodology
//*********************************************************************************

tclmode
  /// Allow cdc path to have logic
  // set r1 [find -ruleinst cdc_def_rs/cdc_checks/cdc_*] 
  // set_attribute $r1 cdc_path_logic { dff logic mux wire user wire }

  // Allow cdc path to fanout to multiple destinations
  // set r2 [find -ruleinst cdc_def_rs/cdc_checks/cdc_*] 
  // set_attribute $r2 cdc_path_fanout { dff multiple mux wire user wire }
vpxmode

//*********************************************************************************
/// Skip Instances
/// Use this to check up to the first DFF inside a module with the rest of
/// that module is blackboxed.  Use root attribute or rule instance.
//*********************************************************************************

tclmode
  # (1) Root atttribute Method
  #  set skips [find -instance "u_pcieg3_phy_rev/u_pcieg3_pma"]
  #  set_attribute [find -conformal] cdc_skip_instances $skips 
    
  # (2) Rule Instance Method
  #  foreach runs_id_1 [find -ruleinst cdc_def_rs/cdc_checks/cdc*] {
  #    set_attribute $runs_id_1 \
  #      skip_instances [find -instance "u_pcieg3_phy_rev/u_pcieg3_pma"]
  #      }  
  
    set ccd_skips [get_attribute [find -conformal] cdc_skip_instances] 
    echo $ccd_skips > $_CCD_RPT_PATH/general/report.skip_instances

  
vpxmode

//*********************************************************************************
// Add filters
// There are two ways to handle this:
// (1) Via a text file
// (2) Via the GUI during interactive debug
//
// Filters_cdc.do shows how to add some more elaborate types of filters
//
// All rule filters should be added to this file with sufficient explanations
//*********************************************************************************

tclmode  
  # Read in Design/Library Filters
      if [file exists $_CCD_INPUT_PATH/filters_cdc.do] {
        echo "$_CCD_INPUT_PATH/filters_cdc.do - Adding filters";
        dofile $_CCD_INPUT_PATH/filters_cdc.do
        report_rule_filter -rule  cdc_def_rs/*/* > $_CCD_RPT_PATH/cdc/report.filters
    } 

vpxmode

//*********************************************************************************
// Read in rule check file with waived/filtered occurences
//*********************************************************************************

//  read rule check filtered_rule_checks.txt -exclude


//*********************************************************************************
// run CDC checks DFF/MUX
//*********************************************************************************

tclmode
  if {$env(CCD_CDC_STRUCT)} {
    run_rule_check cdc_def_rs/cdc*

    #// Check convergence from different clock groups (diff_clock_groups_conv) or the same clock group (same_clock_groups_conv)
    #// INVECTOR is default
    #// set_attribute [find -ruleinst cdc_def_rs/conv_checks/*] check_vector_conv all
    #// set_attribute [find -ruleinst cdc_def_rs/conv_checks/*] check_vector_conv invector
    #// set_attribute [find -ruleinst cdc_def_rs/conv_checks/*] check_vector_conv outvector

    #// Check convergence from the bits of same multibit registers (invector) or from different singleot multi-bit registers (outvector)
    #//  set_attribute [find -ruleinst cdc_def_rs/conv_checks/*] check_conv_type diff_clock_groups_conv
  
      run_rule_check cdc_def_rs/conv*
  
  }

//*********************************************************************************
// run CDC set/reset synchronization check
//*********************************************************************************
tclmode
  if {$env(CCD_SETRESET_CHECKS)} {

    run_rule_check cdc_def_rs/setrst*
  
    report_rule_check -nofiltered  cdc_def_rs/setrst* -summary                      >  $_CCD_RPT_PATH/cdc/report.nofiltered.set_reset
    report_rule_check -nofiltered  cdc_def_rs/setrst* -status fail         -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.set_reset
    report_rule_check -nofiltered  cdc_def_rs/setrst* -status inconclusive -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.set_reset
    report_rule_check -nofiltered  cdc_def_rs/setrst* -status not-run      -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.set_reset
    report_rule_check -complete    cdc_def_rs/setrst* -summary                      >  $_CCD_RPT_PATH/cdc/raw/report.raw.set_reset
    report_rule_check -complete    cdc_def_rs/setrst* -status fail         -verbose >> $_CCD_RPT_PATH/cdc/raw/report.raw.set_reset
    report_rule_check -complete    cdc_def_rs/setrst* -status inconclusive -verbose >> $_CCD_RPT_PATH/cdc/raw/report.raw.set_reset
    report_rule_check -complete    cdc_def_rs/setrst* -status not-run      -verbose >> $_CCD_RPT_PATH/cdc/raw/report.raw.set_reset
  }
vpxmode

//*********************************************************************************
// run CDC set/reset Sync Crossing check
//*********************************************************************************

tclmode
  if {$env(CCD_SETRESET_SYNC_CROSS_CHECKS)} {

    run_rule_check cdc_def_rs/sr_sync*
  
    report_rule_check -nofiltered  cdc_def_rs/sr_sync* -summary                      >  $_CCD_RPT_PATH/cdc/report.nofiltered.sr_sync_cross
    report_rule_check -nofiltered  cdc_def_rs/sr_sync* -status fail         -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.sr_sync_cross
    report_rule_check -nofiltered  cdc_def_rs/sr_sync* -status inconclusive -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.sr_sync_cross
    report_rule_check -nofiltered  cdc_def_rs/sr_sync* -status not-run      -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.sr_sync_cross
    report_rule_check -complete    cdc_def_rs/sr_sync* -summary                      >  $_CCD_RPT_PATH/cdc/raw/report.raw.sr_sync_cross
    report_rule_check -complete    cdc_def_rs/sr_sync* -status fail         -verbose >> $_CCD_RPT_PATH/cdc/raw/report.raw.sr_sync_cross
    report_rule_check -complete    cdc_def_rs/sr_sync* -status inconclusive -verbose >> $_CCD_RPT_PATH/cdc/raw/report.raw.sr_sync_cross
    report_rule_check -complete    cdc_def_rs/sr_sync* -status not-run      -verbose >> $_CCD_RPT_PATH/cdc/raw/report.raw.sr_sync_cross
  }
vpxmode


//*********************************************************************************
// run Modelling checks
//*********************************************************************************
tclmode
  if {$env(CCD_MODELLING_CHECKS)} {

    add_rule_set -file cfm_default_modeling_ruleset.vpx
    run_rule_check modeling_def_rs/*
    
    report_rule_check -nofiltered  modeling_def_rs/* -summary               > $_CCD_RPT_PATH/modelling/report.nofiltered.modeling
    report_rule_check -nofiltered  modeling_def_rs/* -status fail -verbose >> $_CCD_RPT_PATH/modelling/report.nofiltered.modeling
    report_rule_check -complete    modeling_def_rs/* -summary               > $_CCD_RPT_PATH/modelling/raw/report.raw.modeling
    report_rule_check -complete    modeling_def_rs/* -status fail -verbose >> $_CCD_RPT_PATH/modelling/raw/report.raw.modeling
  }   
vpxmode


//*********************************************************************************
// Enable and run Functional Checks
//*********************************************************************************
tclmode
  if {$env(CCD_FUNCTIONAL_CHECKS)} {
    set_attribute [find -ruleinst cdc_def_rs/cdc*] analysis_mode "functional"
    set_attribute [find -ruleinst cdc_def_rs/conv*] analysis_mode "functional"
    
    run_rule_check cdc_def_rs/cdc*
    run_rule_check cdc_def_rs/conv*
    
    
  }   
vpxmode


//*********************************************************************************
// Generate CDC reports
//*********************************************************************************

tclmode
  if {$env(CCD_CDC_STRUCT) || $env(CCD_FUNCTIONAL_CHECKS)} {

    report_rule_check -complete    cdc_def_rs/cdc* -status fail         -verbose >  $_CCD_RPT_PATH/cdc/raw/report.raw.cdc
    echo "CDC Report"                                                            >  $_CCD_RPT_PATH/cdc/report.nofiltered.cdc
    report_rule_check -nofiltered  cdc_def_rs/cdc* -summary                      >> $_CCD_RPT_PATH/cdc/report.nofiltered.cdc
    report_rule_check -nofiltered  cdc_def_rs/cdc* -status fail         -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.cdc
    report_rule_check -nofiltered  cdc_def_rs/cdc* -status inconclusive -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.cdc
    report_rule_check -nofiltered  cdc_def_rs/cdc* -status not-run      -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.cdc

    report_rule_check -complete    cdc_def_rs/conv* -status fail         -verbose >  $_CCD_RPT_PATH/cdc/raw/report.raw.convergence
    report_rule_check -nofiltered  cdc_def_rs/conv* -summary                      >  $_CCD_RPT_PATH/cdc/report.nofiltered.convergence
    report_rule_check -nofiltered  cdc_def_rs/conv* -status fail         -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.convergence
    report_rule_check -nofiltered  cdc_def_rs/conv* -status inconclusive -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.convergence
    report_rule_check -nofiltered  cdc_def_rs/conv* -status not-run      -verbose >> $_CCD_RPT_PATH/cdc/report.nofiltered.convergence
    vpxmode
  }


  usage -auto
  
//*********************************************************************************
// Write out rule check file with waived/filtered occurences
//*********************************************************************************

//  write rule check filtered_rule_checks.txt -filtered_out -design 
tclmode
  write_filters
vpxmode

//*********************************************************************************
//* Creates a checkpoint file of this Conformal run
//*********************************************************************************
tclmode
  if {$env(CCD_SAVE_CP)} {
  puts "\n\nSaving Checkpoint file here: $_CCD_RPT_PATH/${DESIGN}_${CONFIG}.cpt\n\n";
  checkpoint $_CCD_RPT_PATH/${DESIGN}_${CONFIG}.cpt -replace
}

//*********************************************************************************
// Generate all CDC checks in Table format
//*********************************************************************************
    report_cdc_check -clock_based > $_CCD_RPT_PATH/cdc/report_cdc_summary.final

//*********************************************************************************
//* CCD environment report
//*********************************************************************************
tclmode
    report_environment > $_CCD_RPT_PATH/general/report.environment

if ($env(EXIT_CCD_RUN)) {
  exit
}

printf "\n    Use 'set_gui' to start GUI or 'exit' to quit\n\n"
