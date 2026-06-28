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
}

#assume no memories

# file to get a list of parameters
set PARAMETERS    ""
set PARAMETERS [join $PARAMETERS]

##############################################################
## Set Netlist for Simulation
###############################################################
set netlist {}

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


###############################################################
## Compile Libraries
###############################################################
set libfiles $VFILE

foreach libfile $libfiles {
   if [file exists $libfile] {
      exec irun -c -64bit $libfile -update -define NTC -define RECREM -messages \
       -append_log -logfile $irun_logfile
   }
}


if [info exists SIM_OTHER_MODULES_LIBS] {
   foreach SIM_OTHER_MODULES_LIB $SIM_OTHER_MODULES_LIBS {
      exec irun -c -64bit $SIM_OTHER_MODULES_LIB -update -incdir $SIM_OTHER_MODULES_LIB:h/../incdir -define NTC -define RECREM -messages \
       -append_log -logfile $irun_logfile
   }
}

###############################################################
## Compile netlist
###############################################################

foreach netlist_file $netlist {
   if [file exists $netlist_file] {
      exec irun -compile -64bit ${netlist_file} -incdir [file dirname ${netlist_file}] -update -linedebug ${PARAMETERS} -messages -append_log -logfile $irun_logfile -timescale 1ns/1ps
   } else {
      puts "Can't find $netlist_file."
      exit
   }
}

if [info exists SIM_OTHER_MODULES_NETLISTS] {
  exec irun -compile -64bit -f ${SIM_OTHER_MODULES_NETLISTS} -ALLOWREDEFINITION -define NTC -define RECREM -update -linedebug -messages -append_log -logfile $irun_logfile -timescale 1ns/1ps  
}


exec irun -elaborate -64bit -top $DESIGN -update -messages -append_log -logfile $irun_logfile -timescale 1ns/1ps

if {$annotated_sim} {

   ##############################################################
   ## Compile SDF
   ###############################################################

   
   if {!$HARD_MACRO} {
     set sdf_name ${SDFNAME}_${ATPG_DESIGN_MODE} 
   } else {
     set sdf_name ${SDFNAME}.${ATPG_DESIGN_MODE}
   }
   set sdf_filename [file tail ${sdf_name}]
   if { [file exists ${sdf_name}.${corner}.sdf] } {
      exec ncsdfc -64bit ${sdf_name}.${corner}.sdf -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}.${corner}.sdf.gz] } {
      exec ncsdfc -64bit ${sdf_name}.${corner}.sdf.gz -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}_${corner}.sdf] } {
      exec ncsdfc -64bit ${sdf_name}_${corner}.sdf -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}_${corner}.sdf.gz] } {
      exec ncsdfc -64bit ${sdf_name}_${corner}.sdf.gz -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}.sdf] } {
      exec ncsdfc -64bit ${sdf_name}.sdf -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.sdf.X -logfile ${_SIMWORK_PATH}/ncsdfc.log
   } else {
      puts "Can't find ${sdf_name}.sdf"
      exit
   }

   ##############################################################
   # setup SDF file to ensure correct annotation
   ##############################################################
      
   set sdf_cmd_file_($ATPG_DESIGN_MODE) "${_SIMWORK_PATH}/support_files/${DESIGN}_${ATPG_DESIGN_MODE}_${pattern}_${corner}_sdfcmdfile.do"

   file copy -force "${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/template_sdfcmdfile.do" $sdf_cmd_file_($ATPG_DESIGN_MODE)

   if { [file exists ${sdf_name}.${corner}.sdf] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   } elseif { [file exists ${sdf_name}.${corner}.sdf.gz] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   } elseif { [file exists ${sdf_name}_${corner}.sdf.gz] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   } else {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   }

   exec perl -p -i -e "s#<compiled_sdf_path>#${_SIMWORK_PATH}/support_files#g" $sdf_cmd_file_($ATPG_DESIGN_MODE)

   exec perl -p -i -e "s/<top_path>/${DESIGN}_inst/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)

   set workdir [file tail ${_ATPGWORK_PATH}]

   exec perl -p -i -e "s/<tb_name>/${workdir}_${pattern}/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)

   exec perl -p -i -e "s/<design_logfile_name>/${DESIGN}_sdfcmdfile_${pattern}_${corner}/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)

   if {$corner == "wc"} {
      exec perl -p -i -e "s/<corner>/MAXIMUM/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   } elseif {$corner == "bc"} {
      exec perl -p -i -e "s/<corner>/MINIMUM/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   } else {
      exec perl -p -i -e "s/<corner>/TYPICAL/g" $sdf_cmd_file_($ATPG_DESIGN_MODE)
   }
}

