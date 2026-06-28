#write_db -all_root_attributes -to_file final.db
set fp [open io_clocks w]
foreach input_pin [remove_from_collection [all_inputs] [clock_ports]] {
   foreach end_point [fanout -endpoints -vname $input_pin] {
      if { [get_attr flop [dirname $end_point]] == true } { 
         set clock_pin [basename [get_attr clock [dirname [get_attr lib_pin $end_point]]]]
         array set info_array [lindex [get_attr propagated_clocks [dirname $end_point]/$clock_pin] 0]
         puts $fp "[vname $input_pin] [vname $end_point] [basename $info_array(clock)] [basename [get_attr non_inverted_sources $info_array(clock)]]" 
      }
   }
}
close $fp
