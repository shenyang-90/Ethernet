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


###############################################################
## Create Output Directories
###############################################################
if {![file exists ${_SIMWORK_PATH}/support_files/]} {
   file mkdir ${_SIMWORK_PATH}/support_files/
   puts "Creating directory ${_SIMWORK_PATH}/support_files/"
} else {
   foreach supfile [glob -nocomplain ${_SIMWORK_PATH}/support_files/*] {
    file delete $supfile
   }
}

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
      exec ncsdfc -64bit ${sdf_name}.${corner}.sdf -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/${corner}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}.${corner}.sdf.gz] } {
      exec ncsdfc -64bit ${sdf_name}.${corner}.sdf.gz -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/${corner}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}_${corner}.sdf] } {
      exec ncsdfc -64bit ${sdf_name}_${corner}.sdf -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/${corner}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}_${corner}.sdf.gz] } {
      exec ncsdfc -64bit ${sdf_name}_${corner}.sdf.gz -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.${corner}.sdf.X -logfile ${_SIMWORK_PATH}/${corner}/ncsdfc_${corner}.log
   } elseif { [file exists ${sdf_name}.sdf] } {
      exec ncsdfc -64bit ${sdf_name}.sdf -update -output ${_SIMWORK_PATH}/support_files/${sdf_filename}.sdf.X -logfile ${_SIMWORK_PATH}/ncsdfc.log
   } else {
      puts "Can't find ${sdf_name}.sdf"
      exit
   }
   
   #########################################################################################################################
   ## When necessary, replicate the part above for multiple sdfs
   #########################################################################################################################
   
   #########################################################################################################################
   # setup SDF file to ensure correct annotation
   # Also, when necessary replicatethis part for the case with multiple sdfs.
   #########################################################################################################################
   set sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode}) "${_SIMWORK_PATH}/support_files/${DESIGN}_${ATPG_DESIGN_MODE}_${testmode}_${corner}_sdfcmdfile.do"

   file copy -force "${IPF_DESIGN_FLOW_SCRIPTS}/nc/support_files/template_sdfcmdfile.do" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})

   if { [file exists ${sdf_name}.${corner}.sdf] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   } elseif { [file exists ${sdf_name}.${corner}.sdf.gz] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   } elseif { [file exists ${sdf_name}_${corner}.sdf] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   } elseif { [file exists ${sdf_name}_${corner}.sdf.gz] } {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}.${corner}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   } else {
      exec perl -p -i -e "s/<top_name>/${sdf_filename}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   }
   
  
   exec perl -p -i -e "s#<compiled_sdf_path>#${_SIMWORK_PATH}/support_files#g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})

   exec perl -p -i -e "s/<top_path>/${DESIGN}_inst/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})

   set workdir [file tail ${_ATPGWORK_PATH}]

   exec perl -p -i -e "s/<tb_name>/${workdir}_${testmode}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})

   exec perl -p -i -e "s/<design_logfile_name>/${DESIGN}_sdfcmdfile_${testmode}_${corner}/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})

####################################################################################
## When necessary, replace #wc and #bc# with actual corner names in the code below
########################################################################################

   if {$corner == "wc"} {
      exec perl -p -i -e "s/<corner>/MAXIMUM/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   } elseif {$corner == "bc"} {
      exec perl -p -i -e "s/<corner>/MINIMUM/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   } else {
      exec perl -p -i -e "s/<corner>/TYPICAL/g" $sdf_cmd_file_(${ATPG_DESIGN_MODE}_${testmode})
   }
