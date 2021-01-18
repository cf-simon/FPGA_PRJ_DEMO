
# phony targets
.PHONY: clean

# prevent make from deleting intermediate files and reports
.PRECIOUS: $(FPGA_TOP).xpr $(FPGA_TOP).bit
.SECONDARY:

CONFIG ?= config.mk
-include ../$(CONFIG)

SYN_FILES_REL = $(patsubst %, ./%, $(SYN_FILES))
INC_FILES_REL = $(patsubst %, ./%, $(INC_FILES))
XCI_FILES_REL = $(patsubst %, ./%, $(XCI_FILES))
COE_FILES_REL = $(patsubst %, ./%, $(COE_FILES))
XDC_FILES_REL = $(patsubst %, ./%, $(XDC_FILES))

UPDATE_VER_TCL_RELEASE = ../scripts/update_verison.tcl
UPDATE_VER_TCL_DEBUG = ../scripts/update_verison_debug.tcl

ifeq ($(ver), release)
    UPDATE_VER_TCL = $(UPDATE_VER_TCL_RELEASE)
else
    UPDATE_VER_TCL = $(UPDATE_VER_TCL_DEBUG)
endif

###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and project files
###################################################################

all: create synthesis implementation generate

clean:
	-rm -rf *.log *.jou *.cache *.hw *.ip_user_files *.runs *.xpr *.html *.xml *.sim *.srcs *.str .Xil *.tmp *.tcl *.bit *.bin *.prm
	-rm -rf .creat.done .gen.done .impl.done .synth.done
	# find . -not -name "Makefile" -not -name "." -not -name "vivado.mk" -not -name "rev" | xargs rm -rf

distclean: clean
	-rm -rf rev

###################################################################
# Target implementations
###################################################################

# Vivado project file
create: .creat.done 
.creat.done: $(XCI_FILES_REL) $(COE_FILES_REL)
	# rm -rf defines.v
	# touch defines.v
	# for x in $(DEFS); do echo '`define' $$x >> defines.v; done
	echo "create_project -force -part $(FPGA_PART) $(FPGA_TOP)" > create_project.tcl
	echo "set_property "target_language" "Verilog" [get_projects $(FPGA_TOP)]" >> create_project.tcl
	# echo "add_files -fileset sources_1 defines.v" >> create_project.tcl
	for x in $(SYN_FILES_REL); do echo "add_files -fileset sources_1 $$x" >> create_project.tcl; done
	for x in $(COE_FILES_REL); do echo "add_files -fileset sources_1 $$x" >> create_project.tcl; done
	for x in $(INC_FILES_REL); do echo "add_files -fileset sources_1 $$x" >> create_project.tcl; done
	for x in $(XDC_FILES_REL); do echo "add_files -fileset constrs_1 $$x" >> create_project.tcl; done
	for x in $(XCI_FILES_REL); do echo "import_ip $$x" >> create_project.tcl; done
	echo "set obj_file [get_filesets sources_1]" >> create_project.tcl
	echo "set_property -name "top" -value "$(FPGA_TOP)" -objects [get_filesets sources_1]" >> create_project.tcl
	echo "set_property -name "top_auto_set" -value "0" -objects [get_filesets sources_1]" >> create_project.tcl
	# echo "set_property STEPS.SYNTH_DESIGN.TCL.PRE C:/Work/EDFA/prj_demo/scripts/set_version.tcl [get_runs synth_1]" >> create_project.tcl
	# echo "set_property STEPS.INIT_DESIGN.TCL.PRE C:/Work/EDFA/prj_demo/scripts/get_version.tcl [get_runs impl_1]">>create_project.tcl
	echo "source -notrace ../scripts/utils.tcl" >> create_project.tcl
	echo "touch {.creat.done}" >> create_project.tcl
	echo "exit" >> create_project.tcl
	vivado -mode batch -source create_project.tcl	

SETUPDEPS = $(SYN_FILES_REL) $(INC_FILES_REL) $(XDC_FILES_REL)
# synthesis run
synthesis: .synth.done
.synth.done: .creat.done $(SETUPDEPS)
	echo "open_project $(FPGA_TOP).xpr" > run_synth.tcl
	echo "source $(UPDATE_VER_TCL)" >> run_synth.tcl
	echo "reset_run synth_1" >> run_synth.tcl
	echo "launch_runs synth_1 -jobs 8" >> run_synth.tcl
	echo "wait_on_run synth_1" >> run_synth.tcl
	echo "source -notrace ../scripts/utils.tcl" >> run_synth.tcl
	echo "touch {.synth.done}" >> run_synth.tcl
	echo "exit" >> run_synth.tcl
	vivado -mode batch -source run_synth.tcl

# implementation run
implementation: .impl.done
.impl.done: .synth.done
	echo "open_project $(FPGA_TOP).xpr" > run_impl.tcl
	echo "reset_run impl_1" >> run_impl.tcl
	echo "launch_runs impl_1 -jobs 8" >> run_impl.tcl
	echo "wait_on_run impl_1" >> run_impl.tcl
	echo "source -notrace ../scripts/utils.tcl" >> run_impl.tcl
	echo "touch {.impl.done}" >> run_impl.tcl
	echo "exit" >> run_impl.tcl
	vivado -mode batch -source run_impl.tcl

# bit file
generate: .gen.done
.gen.done: .impl.done
	echo "open_project $(FPGA_TOP).xpr" > generate_bit.tcl
	echo "open_run impl_1" >> generate_bit.tcl
	echo "write_bitstream -force $(FPGA_TOP).bit" >> generate_bit.tcl
	echo "source -notrace ../scripts/utils.tcl" >> generate_bit.tcl
	echo "write_cfgmem -force -format bin -size 16 -interface SPIx4 -loadbit {up 0x0000000 $(FPGA_TOP).bit} -file $(FPGA_TOP).bin" >> generate_bit.tcl
	echo "touch {.gen.done}" >> generate_bit.tcl
	echo "exit" >> generate_bit.tcl
	vivado -mode batch -source generate_bit.tcl	

release: .gen.done
	mkdir -p rev
	echo "set bit_name $(FPGA_TOP)" > release_bin.tcl
	echo "set prj_head $(PRJ_HEAD)" >> release_bin.tcl
	echo "set ver_dir $(VER_DIR)" >> release_bin.tcl
	echo "source -notrace ../scripts/get_version.tcl" >> release_bin.tcl
	echo "exit" >> release_bin.tcl
	vivado -mode batch -source release_bin.tcl

flash: $(FPGA_TOP).bin $(FPGA_TOP).prm
	echo "open_hw" > flash.tcl
	echo "connect_hw_server" >> flash.tcl
	echo "open_hw_target" >> flash.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> flash.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> flash.tcl
	echo "create_hw_cfgmem -hw_device [current_hw_device] [lindex [get_cfgmem_parts {$(CFG_FLASH)}] 0]" >> flash.tcl
	echo "current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]" >> flash.tcl
	echo "set_property PROGRAM.FILES [list \"$(FPGA_TOP).bin\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.PRM_FILES [list \"$(FPGA_TOP).prm\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ERASE 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]" >> flash.tcl
	echo "create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]" >> flash.tcl
	echo "program_hw_devices [current_hw_device]" >> flash.tcl
	echo "refresh_hw_device [current_hw_device]" >> flash.tcl
	echo "program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]" >> flash.tcl
	echo "boot_hw_device [current_hw_device]" >> flash.tcl
	echo "exit" >> flash.tcl
	vivado -nojournal -nolog -mode batch -source flash.tcl