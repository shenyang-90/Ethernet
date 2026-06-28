#####################################################################
## Design Compiler script to check the integrity of our deliverables
## within Synopsys DC flow. 
## Author; Vladimir Zivkovic
#####################################################################
puts "Hostname : [info hostname]"

##Cretae link to RDf setup_project.csh
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

######################################################################################
## For IPS or PHYs or any design containing hard PMA ,specify below 
## the base of the PMA module name, e.g. set PMA_BASE  sd0850_t7t_11_vc130_1xh1xav1yah4yvhvh2yy2z 
## as well as PMA or PHY stub file, including the location.
## If no macros are used, and/or no need to PMA or PHY stub, keep it as is: empty
#######################################################################################
set PMA_BASE ""
set PMA_DESIGN      cdn_${PMA_BASE}
set PMA_STUB_FILE  ""

###Change the value below to '1' if power and ground are incorporated into CTL
set POWER_AWARE     0

######################################################################################
## For IPS or PHYs or any design containing hard PMA ,specify below 
## the ctl file, including the location. The base CTL file includes power and ground ports
## If no macros are used, keep it as is - empty
#######################################################################################
set CTL_BASE_FILE  ""

############################################
## List the necessary macros in the variable below, e.g.:
## set VDEFINES "CDNS_PMA_PWR_AWARE CDNS_PHY_PWR_AWARE"
## If no macros are used, keep it as is - empty
#############################################
set VDEFINES ""


#Settings specific to Synopsys, not directly derived from RDF
#Only use when mapping through DC is for some reason required for flushing
#set DC_SLOWLIB     ""
#set target_library "$DC_SLOWLIB"
#set link_library   "* $target_library $synthetic_library"

set dc_output_path <specify here the directory to store the log files, e.g.  $DUT_PATH/DC/logs>

#PMA setting, can be potentially derived from RDF

set work_dir        "${dc_output_path}/work_dc"

if {[file exists $dc_output_path]} {
   file delete -force $dc_output_path
}
file mkdir $dc_output_path

set top $DESIGN
set lib_name ${top}_lib

define_design_lib $lib_name -path $work_dir

set search_path [list $RTL_PATH .]

if {$POWER_AWARE} {
   set CTL_FILE $CTL_BASE_FILE  
} else {
   set CTL_FILE ${CTL_BASE_FILE}.nopwrgnd
}

#######################################################################################
## Specify below the RDF expanded list after setup_project.csh
## e.g.
## set list_file [open $DUT_PATH/expanded.f RDONLY]
#######################################################################################
set list_file [open <expanded.f, including the absolute path> RDONLY]

set buffer [read -nonewline $list_file]
foreach entry $buffer {
   read_file -format verilog -define $VDEFINES $entry
   analyze -format verilog -define $VDEFINES -library $lib_name $entry
}

if [file exists  $PMA_STUB_FILE] {
  read_file -format verilog -define $VDEFINES $PMA_STUB_FILE
}
elaborate $top -lib $lib_name
link
uniquify

current_design $top

foreach mode $DESIGN_MODES {
 if {[info exists CONFIG] && ($CONFIG != "") } {
     source $SDC_PATH/${DESIGN}_$CONFIG.$mode.sdc
 } else {
     source $SDC_PATH/${DESIGN}.$mode.sdc
 }
}

write -f verilog -h -o ${dc_output_path}/${top}_gtech.v

if {$HARD_MACRO} {
  read_test_model -design $PMA_DESIGN -format ctl $CTL_FILE
}

file copy ./dc.log ${dc_output_path}
file copy ./default.svf ${dc_output_path}
file copy ./command.log ${dc_output_path}
exec rm -rf setup_project.csh
exec rm -rf command.log
exec rm -rf default.svf

exit
