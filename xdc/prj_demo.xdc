set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]     
set_property CONFIG_MODE SPIx4 [current_design]                    
set_property BITSTREAM.CONFIG.CONFIGRATE 26 [current_design]

set_property PACKAGE_PIN AD12 [get_ports gclk]
set_property IOSTANDARD LVCMOS15 [get_ports gclk]

set_property PACKAGE_PIN H19 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
