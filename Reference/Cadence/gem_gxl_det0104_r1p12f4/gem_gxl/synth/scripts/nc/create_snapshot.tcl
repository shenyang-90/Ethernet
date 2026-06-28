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
#    Primary Unit Name :      compile_design.tcl
#
#          Description :      Template Script to compile the design for DFT simulations
#
#      Original Author :      Anna Gilbert, Vladimir Zivkovic
#
#------------------------------------------------------------------------------

#puts "Hostname : [info hostname]"

#source ./project.tcl

#file delete -force work/*

###############################################################
## Create Output Directories
###############################################################
if {![file exists ${_SIMWORK_PATH}]} {
   file mkdir ${_SIMWORK_PATH}
   puts "Creating directory ${_SIMWORK_PATH}"
}

if {![file exists ${_SIMWORK_PATH}/support_files/]} {
   file mkdir ${_SIMWORK_PATH}/support_files/
   puts "Creating directory ${_SIMWORK_PATH}/support_files/"
} else {
   foreach supfile [glob -nocomplain ${_SIMWORK_PATH}/support_files/*] {
    file delete $supfile
   }

}

#assume no memories

# file to get a list of parameters
set PARAMETERS    ""
set PARAMETERS [join $PARAMETERS]

##############################################################
## Set Netlist for Simulation
###############################################################
set netlist {}

if {$MLM_ATPG_SIM} {
  if [file exists ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.phys.v] {
     set netlist ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.phys.v
  } elseif [file exists ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.phys.v.gz] {
      set netlist ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.phys.v.gz
  } else {
     puts "ERROR: No netlist found for MLM simulations with power supply included. Check your netlist settings"
     exit
  }   
} else {
  if [file exists ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v.gz] {
      lappend netlist ${_PNR_DATA_PATH}/$DESIGN.postccoptincr.v.gz
  } elseif [file exists ${_PNR_DATA_PATH}/${DESIGN}.postccoptincr.v] {
      lappend netlist ${_PNR_DATA_PATH}/${DESIGN}.postccoptincr.v
  } elseif [file exists ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v.gz] {
      set netlist ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v.gz
  } elseif [file exists ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v] {
      set netlist ${PMA_NETLIST_RELEASE_PATH}/${DESIGN}.v
  } elseif [file exists ${_OUTPUTS_PATH}/${DESIGN}.v.gz] {
      lappend netlist ${_OUTPUTS_PATH}/${DESIGN}.v.gz
  } elseif [file exists ${_OUTPUTS_PATH}/${DESIGN}.v] {
      lappend netlist ${_OUTPUTS_PATH}/${DESIGN}.v
  } elseif [info exists DDR_NETLIST] {
      lappend netlist $env(DDR_NETLIST)
  } else {
       puts "ERROR: No netlist found. Check your netlist settings"
       exit
  }
}

###############################################################
## Compile Libraries
###############################################################
set libfiles $VFILE

foreach libfile $libfiles {
   if [file exists $libfile] {
      exec xrun -c -64bit $libfile -update -define NTC -define RECREM -messages \
       -append_log -logfile $xrun_logfile
   }
}


if [info exists SIM_OTHER_MODULES_LIBS] {
   foreach SIM_OTHER_MODULES_LIB $SIM_OTHER_MODULES_LIBS {
      exec xrun -c -64bit $SIM_OTHER_MODULES_LIB -update -incdir $SIM_OTHER_MODULES_LIB:h/../incdir -define NTC -define RECREM -messages \
       -append_log -logfile $xrun_logfile
   }
}

###############################################################
## Compile netlist
###############################################################

foreach netlist_file $netlist {
   if [file exists $netlist_file] {
      exec xrun -compile -64bit ${netlist_file} -incdir [file dirname ${netlist_file}] -update ${PARAMETERS} -messages -append_log -logfile $xrun_logfile -timescale 1ns/1ps $other_args
   } else {
      puts "Can't find $netlist_file."
      exit
   }
}

if [info exists SIM_OTHER_MODULES_NETLISTS] {
  exec xrun -compile -64bit -f ${SIM_OTHER_MODULES_NETLISTS} -ALLOWREDEFINITION -define NTC -define RECREM -update -messages -append_log -logfile $xrun_logfile -timescale 1ns/1ps $other_args  
}


exec xrun -elaborate -64bit -top $DESIGN -update -messages -append_log -logfile $xrun_logfile -timescale 1ns/1ps $other_args


