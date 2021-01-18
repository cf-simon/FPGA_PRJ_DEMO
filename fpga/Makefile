
# FPGA settings
FPGA_PART = xc7k325t-fbg900-1
FPGA_TOP = prj_demo
FPGA_ARCH = spartan7
CFG_FLASH = s25fl256sxxxxxx0-spi-x1_x2_x4
ver = debug

PRJ_HEAD = 1054
VER_DIR = ./rev
# Files for synthesis
SYN_FILES = ../hdl/prj_demo.v
#SYN_FILES += ../hdl/prj_demo.v

INC_FILES = ../hdl/includes/parameter.h
# XDC files
XDC_FILES = ../xdc/prj_demo.xdc
# COE files
# COE_FILES = ../ip/ip_coe/log_12bits_lut.coe
# XCI files
XCI_FILES = ../ip/clk_wiz_0/clk_wiz_0.xci

include ../scripts//vivado.mk

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [current_hw_device]" >> program.tcl
	echo "program_hw_devices [current_hw_device]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -nojournal -nolog -mode batch -source program.tcl