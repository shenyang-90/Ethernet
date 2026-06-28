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
#    Primary Unit Name :      report_cdc_check.tcl
#
#          Description :      Template Script for Reporting CDC checks
#
#      Original Author :      Mark Lewis
#
#------------------------------------------------------------------------------
##--------------------------------------------------------------------------
## Revision History
## Version  Date        Author
## 1.0      2010/11/19  Da-ching Chen (dachingc)
##          > Initial version
##          > Add report_cdc_check
## 1.1      2010-12-01  Da-ching Chen (dachingc)
##          > Update report_cdc_check on report format
##          > Add debugging mechanism
## 1.2      2012-06-08  Da-ching Chen (dachingc)
##          > Add report_cdc_check -path_based
##--------------------------------------------------------------------------

##--------------------------------------------------------------------------
## Procedure: report_cdc_check
## > Report CDC check
##--------------------------------------------------------------------------
proc report_cdc_check {args} {
    ## Initialize global variables
    global __dbg_lst__
    ## Initialize local variables as arguments
    if {[info exist _dump_fid_]} { unset _dump_fid_ }; set _dump_fid_ stdout
    if {[info exist _rinst_lst_]} { unset _rinst_lst_ }; set _rinst_lst_ *
    if {[info exist _clk_based_flg_]} { unset _clk_based_flg_ }; set _clk_based_flg_ 0
    if {[info exist _path_based_flg_]} { unset _path_based_flg_ }; set _path_based_flg_ 0
    ## Initialize local variables
    if {[info exist _dbg_flg_]} { unset _dbg_flg_ }; set _dbg_flg_ 0
    if {[info exist _dest_clk_]} { unset _dest_clk_ }; set _dest_clk_ ""
    if {[info exist _dest_obj_]} { unset _dest_obj_ }; set _dest_obj_ ""
    if {[info exist _fail_cnt_]} { unset _fail_cnt_ }; set _fail_cnt_ 0
    if {[info exist _fail_tcnt_]} { unset _fail_tcnt_ }; set _fail_tcnt_ 0
    if {[info exist _ic_cnt_]} { unset _ic_cnt_ }; set _ic_cnt_ 0
    if {[info exist _ic_tcnt_]} { unset _ic_tcnt_ }; set _ic_tcnt_ 0
    if {[info exist _info_]} { unset _info_ }; set _info_ ""
    if {[info exist _nr_cnt_]} { unset _nr_cnt_ }; set _nr_cnt_ 0
    if {[info exist _nr_tcnt_]} { unset _nr_tcnt_ }; set _nr_tcnt_ 0
    if {[info exist _occr_dsgnobjs_tbl_]} { array unset _occr_dsgnobjs_tbl_ }; array set _occr_dsgnobjs_tbl_ ""
    if {[info exist _occr_lst_]} { unset _occr_lst_ }; set _occr_lst_ ""
    if {[info exist _occr_sta_lst_]} { unset _occr_sta_lst_ }; set _occr_sta_lst_ ""
    if {[info exist _occr_sta_tbl_]} { array unset _occr_sta_tbl_ }; array set _occr_sta_tbl_ ""
    if {[info exist _pass_cnt_]} { unset _pass_cnt_ }; set _pass_cnt_ 0
    if {[info exist _pass_tcnt_]} { unset _pass_tcnt_ }; set _pass_tcnt_ 0
    if {[info exist _rinst_opt_tbl_]} { array unset _rinst_opt_tbl_ }; array set _rinst_opt_tbl_ ""
    if {[info exist _rpt_msg_]} { unset _rpt_msg_ }; set _rpt_msg_ ""
    if {[info exist _rsrc_lst_]} { unset _rsrc_lst_ }; set _rsrc_lst_ ""
    if {[info exist _rsrc_src_obj_dest_obj_cnt_]} { unset _rsrc_src_obj_dest_obj_cnt_ }; set _rsrc_src_obj_dest_obj_cnt_ 0
    if {[info exist _src_clk_]} { unset _src_clk_ }; set _src_clk_ ""
    if {[info exist _src_obj_]} { unset _src_obj_ }; set _src_obj_ ""

    ## Debug
    if {[info exist __dbg_lst__] && [lsearch -exact ${__dbg_lst__} ccd_pkg_common] != -1} {
        set _dbg_flg_ 1
    }

    ## Check license
    if {![string match ccd_l [get_attribute [find -conformal] license_mode]] && ![string match ccd_xl [get_attribute [find -conformal] license_mode]] && ![string match ccd_mcc [get_attribute [find -conformal] license_mode]]} { return -code error "Error: License check error: CCD L license or higher is required" }

    ## Parse arguments and open dump file
    switch -exact -- [parse_options [calling_proc] _dump_fid_ ${args} \
            "-rule_instances oom(ruleinst) Specify rule instances (Default: *)" _rinst_lst_ \
            {"-clock_based brs Clock based report" _clk_based_flg_ ||
             "-path_based brs Path based report" _path_based_flg_}] {
        -2 { return -code ok }
        0 { return -code error "Error: Command/Option syntax error in [calling_proc]" }
    }
    if {[string equal * ${_rinst_lst_}]} {
        set _rinst_lst_ [find -ruleinst]
    }

    ## Clock based report
    if {${_clk_based_flg_} == 1} {
        ## Collect occurrence information
        foreach _rsrc_ [find -nosensitive -rulesrc -filter {category == sdc_cdc}] {
            foreach _rinst_ [find -ruleinst ${_rinst_lst_} -filter "rulesrc == ${_rsrc_}"] {
                array unset _rinst_opt_tbl_; array set _rinst_opt_tbl_ [get_attribute ${_rinst_} options]

                ## Collect source and destination clocks
                set _src_clk_ [lindex [array get _rinst_opt_tbl_ source_clock] 1]
                set _dest_clk_ [lindex [array get _rinst_opt_tbl_ destination_clock] 1]

                ## Collect occurrence statuses
                set _occr_lst_ [get_attribute ${_rinst_} occrs]
                set _pass_cnt_ 0; set _fail_cnt_ 0; set _nr_cnt_ 0; set _ic_cnt_ 0
                if {[llength ${_occr_lst_}] != 0} {
                    set _occr_sta_lst_ [string tolower [get_attribute ${_occr_lst_} status]]
                    set _pass_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} pass]]
                    set _fail_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} fail]]
                    set _nr_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} not-run]]
                    set _ic_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} inconclusive]]
                }

                ## Debug
                if {${_dbg_flg_} == 1} {
                    puts "Debug: Occurrence status: ${_rinst_}: ${_src_clk_}|${_dest_clk_}|${_pass_cnt_}|${_fail_cnt_}|${_nr_cnt_}|${_ic_cnt_}"
                }

                lappend _occr_sta_tbl_(${_rsrc_}) ${_rinst_} [list ${_src_clk_} ${_dest_clk_} ${_pass_cnt_} ${_fail_cnt_} ${_nr_cnt_} ${_ic_cnt_}]
            }
        }

        ## Process report messages
        set _fmt_ "%-*s %-*s %-*s %-*s %-*s %-*s %-s"
        set _width_ 80

        foreach _rsrc_ [array names _occr_sta_tbl_] {
            append _rpt_msg_ "[string repeat = ${_width_}]\n"
            append _rpt_msg_ "[get_attribute [find -rulesrc ${_rsrc_}] desc]\n"
            append _rpt_msg_ "[string repeat = ${_width_}]\n"
            append _rpt_msg_ "[format ${_fmt_} 19 Source 19 Destination 7 Pass 7 Fail 7 Not-Run 7 Inconcl Information]\n"
            append _rpt_msg_ "[string repeat - ${_width_}]\n"

            set _pass_tcnt_ 0; set _fail_tcnt_ 0; set _nr_tcnt_ 0; set _ic_tcnt_ 0
            foreach {_rinst_ _occr_sta_} $_occr_sta_tbl_(${_rsrc_}) {
                set _src_clk_ [lindex ${_occr_sta_} 0]
                set _dest_clk_ [lindex ${_occr_sta_} 1]
                set _pass_cnt_ [lindex ${_occr_sta_} 2]
                set _fail_cnt_ [lindex ${_occr_sta_} 3]
                set _nr_cnt_ [lindex ${_occr_sta_} 4]
                set _ic_cnt_ [lindex ${_occr_sta_} 5]
                incr _pass_tcnt_ ${_pass_cnt_}
                incr _fail_tcnt_ ${_fail_cnt_}
                incr _nr_tcnt_ ${_nr_cnt_}
                incr _ic_tcnt_ ${_ic_cnt_}
                set _info_ "([get_attribute ${_rinst_} status]) ${_rinst_}"

                append _rpt_msg_ "[format ${_fmt_} 19 ${_src_clk_} 19 ${_dest_clk_} 7 ${_pass_cnt_} 7 ${_fail_cnt_} 7 ${_nr_cnt_} 7 ${_ic_cnt_} ${_info_}]\n"
            }

            append _rpt_msg_ "[string repeat - ${_width_}]\n"
            append _rpt_msg_ "[format ${_fmt_} 19 Total 19 {} 7 ${_pass_tcnt_} 7 ${_fail_tcnt_} 7 ${_nr_tcnt_} 7 ${_ic_tcnt_} {}]\n"
        }
        append _rpt_msg_ "[string repeat = ${_width_}]"
    }

    ## Path based report
    if {${_path_based_flg_} == 1} {
        ## Collect occurrence information
        foreach _rsrc_ [find -nosensitive -rulesrc -filter {category == sdc_cdc}] {
            foreach _rinst_ [find -ruleinst ${_rinst_lst_} -filter "rulesrc == ${_rsrc_}"] {
                ##foreach _occr_ [find -occr -filter "ruleinst == ${_rinst_}"]
                foreach _occr_ [find -occr ${_rinst_}/*] {
                    array unset _occr_dsgnobjs_tbl_; array set _occr_dsgnobjs_tbl_ [get_attribute ${_occr_} dsgnobjs]

                    ## Collect source and destination objects
                    set _src_obj_ [lindex [array get _occr_dsgnobjs_tbl_ source] 1]
                    set _dest_obj_ [lindex [array get _occr_dsgnobjs_tbl_ destination] 1]

                    ## Collect occurrence statuses
                    set _pass_cnt_ 0; set _fail_cnt_ 0; set _nr_cnt_ 0; set _ic_cnt_ 0
                    set _occr_lst_ ${_occr_}
                    set _occr_sta_lst_ [string tolower [get_attribute ${_occr_lst_} status]]
                    set _pass_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} pass]]
                    set _fail_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} fail]]
                    set _nr_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} not-run]]
                    set _ic_cnt_ [llength [lsearch -exact -all ${_occr_sta_lst_} inconclusive]]
                    set _rinst_lst_ ${_rinst_}

                    if {[info exist _occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_})]} {
                        set _pass_cnt_ [expr [lindex $_occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) 0] + ${_pass_cnt_}]
                        set _fail_cnt_ [expr [lindex $_occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) 1] + ${_fail_cnt_}]
                        set _nr_cnt_ [expr [lindex $_occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) 2] + ${_nr_cnt_}]
                        set _ic_cnt_ [expr [lindex $_occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) 3] + ${_ic_cnt_}]
                        set _rinst_lst_ [lrange $_occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) 4 end]
                        if {[lsearch -exact ${_rinst_lst_} ${_rinst_}] == -1} {
                            set _rinst_lst_ [linsert ${_rinst_lst_} end ${_rinst_}]
                        }
                    }

                    ## Debug
                    if {${_dbg_flg_} == 1} {
                        puts "Debug: Occurrence status: ${_rsrc_}: ${_src_obj_}|${_dest_obj_}|${_pass_cnt_}|${_fail_cnt_}|${_nr_cnt_}|${_ic_cnt_}|${_rinst_lst_}"
                    }

                    set _occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) [concat ${_pass_cnt_} ${_fail_cnt_} ${_nr_cnt_} ${_ic_cnt_}]
                    foreach i ${_rinst_lst_} {
                        lappend _occr_sta_tbl_(${_rsrc_}:${_src_obj_}:${_dest_obj_}) ${i}
                    }
                }
            }
        }

        ## Process report messages
        set _fmt_ "%-*s %-*s %-*s %-*s %-*s %-*s %-s"
        set _width_ 80

        foreach _rsrc_src_obj_dest_obj_ [array names _occr_sta_tbl_] {
            set _rsrc_ [lindex [split ${_rsrc_src_obj_dest_obj_} :] 0]
            set _src_obj_ [lindex [split ${_rsrc_src_obj_dest_obj_} :] 1]
            set _dest_obj_ [lindex [split ${_rsrc_src_obj_dest_obj_} :] 2]

            if {[lsearch ${_rsrc_lst_} ${_rsrc_}] == -1} {
                lappend _rsrc_lst_ ${_rsrc_}
                set _rsrc_src_obj_dest_obj_cnt_ 0
                append _rpt_msg_ "[string repeat = ${_width_}]\n"
                append _rpt_msg_ "[get_attribute [find -rulesrc ${_rsrc_}] desc]\n"
                append _rpt_msg_ "[string repeat = ${_width_}]\n"
                append _rpt_msg_ "[format ${_fmt_} 19 Source 19 Destination 7 Pass 7 Fail 7 Not-Run 7 Inconcl Information]\n"
                append _rpt_msg_ "[string repeat - ${_width_}]\n"
                set _pass_tcnt_ 0; set _fail_tcnt_ 0; set _nr_tcnt_ 0; set _ic_tcnt_ 0
            }

            set _occr_sta_ $_occr_sta_tbl_(${_rsrc_src_obj_dest_obj_})
            set _pass_cnt_ [lindex ${_occr_sta_} 0]
            set _fail_cnt_ [lindex ${_occr_sta_} 1]
            set _nr_cnt_ [lindex ${_occr_sta_} 2]
            set _ic_cnt_ [lindex ${_occr_sta_} 3]
            incr _pass_tcnt_ ${_pass_cnt_}
            incr _fail_tcnt_ ${_fail_cnt_}
            incr _nr_tcnt_ ${_nr_cnt_}
            incr _ic_tcnt_ ${_ic_cnt_}
            set _rinst_lst_ [lrange ${_occr_sta_} 4 end]
            set _info_ ""
            foreach _rinst_ ${_rinst_lst_} {
                if {![string match "" ${_info_}]} {
                    append _info_ "\n[string repeat { } 72]"
                }
                append _info_ "([get_attribute ${_rinst_} status]) ${_rinst_}"
            }

            append _rpt_msg_ "[format ${_fmt_} 19 ${_src_obj_} 19 ${_dest_obj_} 7 ${_pass_cnt_} 7 ${_fail_cnt_} 7 ${_nr_cnt_} 7 ${_ic_cnt_} ${_info_}]\n"

            incr _rsrc_src_obj_dest_obj_cnt_
            if {${_rsrc_src_obj_dest_obj_cnt_} == [llength [array names _occr_sta_tbl_ ${_rsrc_}*]]} {
                append _rpt_msg_ "[string repeat - ${_width_}]\n"
                append _rpt_msg_ "[format ${_fmt_} 19 Total 19 {} 7 ${_pass_tcnt_} 7 ${_fail_tcnt_} 7 ${_nr_tcnt_} 7 ${_ic_tcnt_} {}]\n"
            }
        }
        append _rpt_msg_ "[string repeat = ${_width_}]"
    }

    puts ${_dump_fid_} ${_rpt_msg_}

    ## Close dump file
    if {![string match stdout ${_dump_fid_}] && ![string match stderr ${_dump_fid_}]} { close ${_dump_fid_} }

    return -code ok
}
