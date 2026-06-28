create_library_set -name WC -timing $EDI_SLOWLIB  
create_library_set -name TYP -timing $EDI_TYPLIB  
create_library_set -name BC -timing $EDI_FASTLIB  

create_rc_corner -name rc_max -qrc_tech $WC_QRC_TECH 
create_rc_corner -name rc_typ -qrc_tech $TYP_QRC_TECH 
create_rc_corner -name rc_min -qrc_tech $BC_QRC_TECH 

create_timing_condition -name WC -library_sets WC 
create_timing_condition -name TYP -library_sets TYP 
create_timing_condition -name BC -library_sets BC 

create_delay_corner -name WC -timing_condition WC -rc_corner rc_max
create_delay_corner -name TYP -timing_condition TYP -rc_corner rc_typ
create_delay_corner -name BC -timing_condition BC -rc_corner rc_min


foreach mode $DESIGN_MODES {
	if {[info exists CONFIG] && ($CONFIG != "") } {
	create_constraint_mode -name ${mode}_mode -sdc_files $SDC_PATH/${DESIGN}_$CONFIG.$mode.sdc
	} else {
	create_constraint_mode -name ${mode}_mode -sdc_files $SDC_PATH/${DESIGN}.$mode.sdc
	}

create_analysis_view -name WC_${mode} -constraint_mode ${mode}_mode -delay_corner WC
create_analysis_view -name TYP_${mode} -constraint_mode ${mode}_mode -delay_corner TYP
create_analysis_view -name BC_${mode} -constraint_mode ${mode}_mode -delay_corner BC   
}

foreach mode $DESIGN_MODES { 
   lappend WC_analysis_views WC_$mode
   lappend BC_analysis_views BC_$mode
   lappend TYP_analysis_views TYP_$mode
}



set_analysis_view -setup ${WC_analysis_views} -hold ${BC_analysis_views} 


if {$DATASHEET_PPA} {
set_analysis_view -setup ${TYP_analysis_views} -hold ${TYP_analysis_views}

}


# Add 85C TYP library for power analysis
if {$TYP_85C_CORNER} {
   if [regsub -all "25c" $EDI_TYPLIB "85c" EDI_TYPLIB_85c] {
       create_library_set -name TYP_85C -timing $EDI_TYPLIB_85c  
       create_timing_condition -name TYP_85C -library_sets TYP_85C
       create_delay_corner -name TYP_85C -timing_condition TYP_85C -rc_corner rc_min
foreach mode $DESIGN_MODES {
	if {[info exists CONFIG] && ($CONFIG != "") } {
	create_constraint_mode -name ${mode}_mode -sdc_files $SDC_PATH/${DESIGN}_$CONFIG.$mode.sdc
	} else {
	create_constraint_mode -name ${mode}_mode -sdc_files $SDC_PATH/${DESIGN}.$mode.sdc
	}
      create_analysis_view -name TYP_85C_${mode} -constraint_mode ${mode}_mode -delay_corner TYP_85C
        }        
}} 


