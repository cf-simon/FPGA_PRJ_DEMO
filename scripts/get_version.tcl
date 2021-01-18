
# set prj_head JBL_1054
set ver_file ../hdl/includes/parameter.h

set ver_fd [open "$ver_file" r]
set row 0
while {[gets $ver_fd line]>=0} {
	if { $row == 6 } {
		set fpga_ver [string range $line 45 48]
	}	
	if { $row == 9 } {
		set ver_year [string range $line 45 48]
	}	
	if { $row == 8 } {
		set ver_date [string range $line 45 48]
	}
	if { $row == 7 } {
		set ver_time [string range $line 45 48]
	}
	set row [expr $row+1]
}
close $ver_fd
set q _
set file_name "FPGA_v$fpga_ver$q$ver_year$q$ver_date$q$ver_time"
# puts $file_name

write_cfgmem -force -format bin -size 16 -interface SPIx4 -loadbit " up 0x0000000 $bit_name.bit " -file $ver_dir/$prj_head$q$file_name.bin