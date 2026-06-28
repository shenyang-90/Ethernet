#=================================================================================
# This proc will take a list of directories and a list of files and then check to see if 
# the files exist in the directories. This is like a search path function where 
# we are interested in the files only in the directories specified.
# echos a warning is more than one file with same name is found or if the file is 
# not found at all.
# returns a list of the files that were found 
#=================================================================================

source ./project.tcl

proc findFiles { filelist } {
  set return_list {}
  array unset found
    foreach elem $filelist {
      set thisfile $elem
      if { [file exists $thisfile] > 0 } {
        lappend return_list $thisfile
        lappend found($elem) $thisfile
      }
    }
  
#=========================================================================
# implements some simple error checks to see if file was found more than 
# once, or if it is not found at all.
#=========================================================================

  foreach elem $filelist {
    if { [info exists found($elem) ] } {
      if { [llength $found($elem)] > 1 } {
        puts "Warning: found more than 1 file named: $elem"
        foreach name $found($elem) {
          puts "Warning: $name"
        }
      }
    } else {
      puts "Warning: could not find: $elem"
    }
  }
  return $return_list
}

set LibFiles [findFiles $EDI_SLOWLIB]
set libfile [open ./liblist.f "w"]
foreach libname $LibFiles {
puts $libfile "$libname"
}
close $libfile

if {[file exists ./liblist.f]} {
  if {[file size ./liblist.f] == 0} {
    puts "Warning: Local library list file ./liblist.f is empty!\n"
  } else {
    puts " Created local Library file listing   - ./liblist.f"
  }
} else {
    puts "Warning: Local library list file ./liblist.f does not exist!"
    puts "         No Library data will be read in.\n"
  }
  
  
# Write out list of verlog libs for Superlint
set vLibFiles $VFILE
set vlibfile [open ./liblist.v "w"]
foreach vlibname $vLibFiles {
puts $vlibfile "$vlibname"
}

close $vlibfile




if {[file exists ./liblist.v]} {
  if {[file size ./liblist.v] == 0} {
    puts "Warning: Local verilog library list file ./liblist.v is empty!\n"
  } else {
    puts " Created local verilog Library file    - ./liblist.v"
  }
} else {
    puts "Warning: Local verilog library list file ./liblist.v does not exist!"
    puts "         No Library data will be read in.\n"
  }

