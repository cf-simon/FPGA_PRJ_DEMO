set ver_file ../hdl/includes/parameter.h
set ver_file_tmp ../fpga/ver_file.tmp

set fd [open "$ver_file" r+]
set newfd [open "$ver_file_tmp" w]
set row 0
while {[gets $fd line] >= 0} {
set newline [string map {a a} $line]
if { $row == 4 } {
	set b0 [string range $line 45 45]
	set b1 [string range $line 46 46]
	set b2 [string range $line 47 47]
	set b3 [string range $line 48 48]
	set bb [expr $b0*1000+$b1*100+$b2*10+$b3]	
	set cc [format "%04d" [expr $bb+1]]
	set dd [string replace $line 45 48 $cc]
	puts $newfd $dd
} elseif {$row == 6} {
	puts $newfd "`define FPGA_VERSION                     16'd$cc"
} elseif {$row == 7} {
	puts $newfd [clock format [clock seconds] -gmt 0 -format "`define FPGA_DEBUG_TIME                  16'd%H%M"]
} elseif {$row == 8} {
	puts $newfd [clock format [clock seconds] -gmt 0 -format "`define FPGA_DEBUG_DATE                  16'd%m%d"]
} elseif {$row == 9} {
	puts $newfd [clock format [clock seconds] -gmt 0 -format "`define FPGA_DEBUG_YEAR                  16'd%Y"]
} else {
puts $newfd $newline
}
set row [expr $row+1]
}
close $fd
close $newfd

set fd [open "$ver_file" w]
set newfd [open "$ver_file_tmp" r+]
while {[gets $newfd line] >= 0} {
set newline [string map {a a} $line]
puts $fd $newline
}
close $fd
close $newfd

# file delete -force ./parameter.h.tmp 

# file rename -force "parameter.h.tmp" "parameter.h"