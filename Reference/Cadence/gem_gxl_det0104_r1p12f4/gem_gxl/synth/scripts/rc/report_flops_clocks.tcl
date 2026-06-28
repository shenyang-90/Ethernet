set fp [open flops w]
foreach cell [filter flop true [find / -instance *]] {
      set clock_pin [basename [get_attr clock [get_attr lib_cell $cell]]]
      array set info_array [lindex [get_attr propagated_clocks $cell/$clock_pin] 0]
      puts $fp "[vname $cell] [basename [get_attr libcell $cell]] [basename $info_array(clock)] [basename [get_attr non_inverted_sources $info_array(clock)]]" 
}
close $fp

#foreach cell [find / -instance *_sync_synth/instances_seq/*genblk1*] {
#   foreach clock_info [get_attr propagated_clocks $cell/CP] {
#      array set info_array $clock_info
#      puts $fp "[vname $cell] [basename [get_attr libcell $cell]] [basename $info_array(clock)] [basename [get_attr non_inverted_sources $info_array(clock)]]" 
#   }
#}
