
cd %~dp0
del *.log
del *.jou
del *.dmp
del *.txt
del /f /s /q .Xil
rd /s /q .Xil
echo off
REM set goal_flash=mt25ql128-spi-x1_x2_x4
set goal_flash=s25fl256sxxxxxx0-spi-x1_x2_x4
REM 查找被下载文件
for /r %%i in (*.bin) do (set prj=%%~ni)
set bin_file=%prj%.bin

del load_bin.tcl
echo open_hw >> load_bin.tcl
echo connect_hw_server >> load_bin.tcl
echo open_hw_target >> load_bin.tcl
echo current_hw_device [lindex [get_hw_devices] 0] >> load_bin.tcl
echo refresh_hw_device -update_hw_probes false [current_hw_device] >> load_bin.tcl
echo create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {%goal_flash%}] 0] >> load_bin.tcl
echo set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.FILES [list "%bin_file%" ] [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.PRM_FILE {} [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo refresh_hw_device [current_hw_device] >> load_bin.tcl
echo startgroup >> load_bin.tcl
echo if {![string equal [get_property PROGRAM.HW_CFGMEM_TYPE  [current_hw_device]] [get_property MEM_TYPE [get_property CFGMEM_PART [ get_property PROGRAM.HW_CFGMEM [current_hw_device]]]]] }  { create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [ current_hw_device]]; program_hw_devices [current_hw_device]; }; >> load_bin.tcl
echo program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [current_hw_device]] >> load_bin.tcl
echo endgroup >> load_bin.tcl
echo boot_hw_device [current_hw_device] >> load_bin.tcl
echo disconnect_hw_server localhost:3121 >> load_bin.tcl
echo close_hw >> load_bin.tcl
echo exit >> load_bin.tcl

cmd /c \Xilinx\Vivado\2018.2\bin\vivado.bat -mode tcl -source load_bin.tcl

find "Operation successful" vivado.log >> prog_log.txt
notepad prog_log.txt

REM pause