# For Basys 3 Artix-7 FPGA Trainer Board

# Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports Main_Clock]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports Main_Clock]

# Switch 1
set_property PACKAGE_PIN V17 [get_ports {Go}]
set_property IOSTANDARD LVCMOS33 [get_ports {Go}]

# Switch 2
set_property PACKAGE_PIN V16 [get_ports {Clock_Select}]
set_property IOSTANDARD LVCMOS33 [get_ports {Clock_Select}]

# Switch 3
set_property PACKAGE_PIN W16 [get_ports {Wave_Select}]
set_property IOSTANDARD LVCMOS33 [get_ports {Wave_Select}]

# Switch 16
set_property PACKAGE_PIN R2 [get_ports {Reset}]
set_property IOSTANDARD LVCMOS33 [get_ports {Reset}]

#7 Segment Display
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {Seg[0]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {Seg[1]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {Seg[2]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {Seg[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {Seg[4]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {Seg[5]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {Seg[6]}]

set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {AN[0]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {AN[1]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {AN[2]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {AN[3]}]