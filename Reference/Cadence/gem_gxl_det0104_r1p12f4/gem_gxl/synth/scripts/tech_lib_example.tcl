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
#    Primary Unit Name :      tech_lib_setup.tcl
#
#          Description :      Library setup script called by project.tcl
#                             Example with dummy names to illustrate required variables
#
#------------------------------------------------------------------------------

if {$env(TECHNOLOGY) == "CUSTOM_TECH"} then {

   set KITSLIB       /process/CUSTOMER/CUSTOM_TECH/digital

   set VFILE        "$KITSLIB/Front_End/verilog/TECH1_VERSION/TECH1.v \
                     $KITSLIB/Front_End/verilog/TECH2_VERSION/TECH2.v \
                     $KITSLIB/Front_End/verilog/TECH3_VERSION/TECH3.v \
                     "
   set ATPGLIB      "$KITSLIB/Front_End/mentor_dft/TECH1_VERSION/TECH1.mdt \
	             $KITSLIB/Front_End/mentor_dft/TECH2_VERSION/TECH2.mdt \
	             $KITSLIB/Front_End/mentor_dft/TECH3_VERSION/TECH3.mdt \
	             "		     
   set LIBLEF       "$KITSLIB/Back_End/lef/TECH1_VERSION/lef/*/TECH1.lef \
                     $KITSLIB/Back_End/lef/TECH2_VERSION/lef/*/TECH2.lef \
                     $KITSLIB/Back_End/lef/TECH3_VERSION/lef/*/TECH3.lef \
                     "		     
   set LIBLIB       "$KITSLIB/Front_End/timing_power_noise/NLDM/TECH1 \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH2 \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH3 \
                     "		     
   set SLOWLIB      "TECH1_SLOW_CORNER1.lib \
                     TECH1_SLOW_CORNER2.lib \
                     TECH1_SLOW_CORNER3.lib \
		     TECH2_SLOW_CORNER1.lib \
                     TECH2_SLOW_CORNER2.lib \
                     TECH2_SLOW_CORNER3.lib \
		     TECH3_SLOW_CORNER1.lib \
                     TECH3_SLOW_CORNER2.lib \
                     TECH3_SLOW_CORNER3.lib \
                     "		     
   set TYPLIB       "TECH1_TYP_CORNER1.lib \
                     TECH1_TYP_CORNER2.lib \
                     TECH1_TYP_CORNER3.lib \
		     TECH2_TYP_CORNER1.lib \
                     TECH2_TYP_CORNER2.lib \
                     TECH2_TYP_CORNER3.lib \
		     TECH3_TYP_CORNER1.lib \
                     TECH3_TYP_CORNER2.lib \
                     TECH3_TYP_CORNER3.lib \
                     "		     	
   set FASTLIB      "TECH1_SLOW_CORNER1.lib \
                     TECH1_FAST_CORNER2.lib \
                     TECH1_FAST_CORNER3.lib \
		     TECH2_FAST_CORNER1.lib \
                     TECH2_FAST_CORNER2.lib \
                     TECH2_FAST_CORNER3.lib \
		     TECH3_FAST_CORNER1.lib \
                     TECH3_FAST_CORNER2.lib \
                     TECH3_FAST_CORNER3.lib \
                     "		     
   set EDI_SLOWLIB  "$KITSLIB/Front_End/timing_power_noise/NLDM/TECH1/TECH1_PHYS_SLOW.lib \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH2/TECH2_PHYS_SLOW.lib \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH3/TECH3_PHYS_SLOW.lib \
                     "		     
   set EDI_TYPLIB   "$KITSLIB/Front_End/timing_power_noise/NLDM/TECH1/TECH1_PHYS_TYP.lib \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH2/TECH2_PHYS_TYP.lib \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH3/TECH3_PHYS_TYP.lib \
                     "			     	     		     
   set EDI_FASTLIB  "$KITSLIB/Front_End/timing_power_noise/NLDM/TECH1/TECH1_PHYS_FAST.lib \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH2/TECH2_PHYS_FAST.lib \
                     $KITSLIB/Front_End/timing_power_noise/NLDM/TECH3/TECH3_PHYS_FAST.lib \
                     "		     
   set WC_DB        "$KITSLIB/Back_End/celtic/TECH1/TECH1_WC.cdb \
                     $KITSLIB/Back_End/celtic/TECH2/TECH2_WC.cdb \
                     $KITSLIB/Back_End/celtic/TECH3/TECH3_WC.cdb \
                     "		     
   set TYP_DB       "$KITSLIB/Back_End/celtic/TECH1/TECH1_TYP.cdb \
                     $KITSLIB/Back_End/celtic/TECH2/TECH2_TYP.cdb \
                     $KITSLIB/Back_End/celtic/TECH3/TECH3_TYP.cdb \
                     "		     		     		     
   set BC_DB        "$KITSLIB/Back_End/celtic/TECH1/TECH1_BC.cdb \
                     $KITSLIB/Back_End/celtic/TECH2/TECH2_BC.cdb \
                     $KITSLIB/Back_End/celtic/TECH3/TECH3_BC.cdb \
                     "		     

   set VDD_values    "0.81 0.99 0.90"
   set TEMP_values   "125 0 25"
   set ss_setup_derate_factor 0.095
   set ss_hold_derate_factor 0.12
   set ff_hold_derate_factor 0.15
   set PROCNODE      28
   set max_route_layer 9
   set DRIVE_CELL    DEFAULT_DRIVE_CELLNAME
   set WC_CAP_TABLE  $KITSLIB/EXTRACTION/cworst/TECH_cworst.captable
   set WC_QRC_TECH   $KITSLIB/EXTRACTION/cworst/qrcTechFile
   set TYP_CAP_TABLE $KITSLIB/EXTRACTION/typical/TECH_typical.captable
   set TYP_QRC_TECH  $KITSLIB/EXTRACTION/typical/qrcTechFile   
   set BC_CAP_TABLE  $KITSLIB/EXTRACTION/cbest/TECH_cbest.captable
   set BC_QRC_TECH   $KITSLIB/EXTRACTION/cbest/qrcTechFile

   set TIELIST [list \
      "TIEH" \
      "TIEL" \
   ]
   set DONT_USE [list \
      "DONT_USE1*" \
      "DONT_USE2*" \
      "DONT_USE3*" \
   ]
   set CLK_BUFFERS [list \
      "CLKBUFF1" \
      "CLKBUFF2" \
      "CLKBUFF3" \
      "CLKBUFF4" \
   ]
      
   set CLK_INVERTERS [list \
      "CLKINV1" \
      "CLKINV2" \
      "CLKINV3" \
      "CLKINV4" \
   ]

}
