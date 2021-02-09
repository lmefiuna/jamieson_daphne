# KC705 constraints
# jamieson@fnal.gov
# 11 Sept 2018

# #############################################################################
# Timing constraints...
# Note: Xilinx IP core constraints will be applied automatically
# when the *.xcix file is added to the project

# Net sysclk is 200MHz clock, comes in on differential I/O
# Net oeiclk is 125 and is generated from the GTX transceiver, which it gets from the reference clock

create_clock -name sysclk -period 5.000  [get_ports sysclk_p]
create_clock -name oeiclk -period 8.000  [get_ports gtrefclk_p]

set_clock_groups -name async_groups -asynchronous \
-group [get_clocks -include_generated_clocks sysclk] \
-group [get_clocks -include_generated_clocks oeiclk] \

# tell vivado about places where signals cross clock domains so timing can be ignored here...
# comment out and worry about this later...

# set_false_path -from {bc_count_reg_reg[*]/C} -to {eth_int_inst/data_manager_blk/TX_CTRL_FIFO/FIFO_SYNC_MACRO_inst/bl.fifo_36_inst_bl_1.fifo_36_bl_1/DI[*]}
# set_false_path -from {eth_int_inst/*/*/tx_en_reg*/C} -to {eth_act_led_reg_reg[0]/D}
# set_false_path -from {*/*/*/gig_ethernet_pcs_pma_0_core/gpcs_pma_inst/RECEIVER/RX_DV_reg/C} -to {eth_act_led_reg_reg[0]/D}

# #############################################################################
# Pin LOCation and IOSTANDARD Constraints...

# Ethernet GTX is QUAD117-2 -> X1Y33 in XC7K325T -> X0Y10 (per UG476 fig A-6)
# refclk is 125MHz on MGTREFCLK0_117.  On KC705 rev 1.0 boards the SFP TX and RX diff pairs are inverted!

set_property LOC GTXE2_CHANNEL_X0Y10 [get_cells */*/*/transceiver_inst/gtwizard_inst/*/gtwizard_i/gt0_GTWIZARD_i/gtxe2_i]
set_property LOC G8 [get_ports gtrefclk_p]

# SFP module LOSS OF SIGNAL indicator IO bank VCCO=2.5V

set_property PACKAGE_PIN P19 [get_ports sfp_los]
set_property IOSTANDARD LVCMOS25 [get_ports {sfp_los}]

# SFP module TX DISABLE control, IO bank VCCO=VADJ_FPGA=2.5V

set_property PACKAGE_PIN Y20 [get_ports sfp_tx_dis]
set_property IOSTANDARD LVCMOS25 [get_ports {sfp_tx_dis}]

# reset pin is from pushbutton SW7, I/O bank 34 VCCO=1.5V

set_property PACKAGE_PIN AB7 [get_ports reset]
set_property IOSTANDARD LVCMOS15 [get_ports {reset}]

# SYSCLK is LVDS 200MHz comes in on bank 33, VCCO=1.5V. Normally LVDS requires VCCO=1.8V
# But LVDS input is OK in this bank if internal termination resistor is NOT used.

set_property PACKAGE_PIN  AD12 [get_ports sysclk_p]
set_property PACKAGE_PIN  AD11 [get_ports sysclk_n]
set_property IOSTANDARD LVDS [get_ports sysclk_p]
set_property IOSTANDARD LVDS [get_ports sysclk_n]
set_property DIFF_TERM FALSE [get_ports sysclk_p]
set_property DIFF_TERM FALSE [get_ports sysclk_n]


# User LEDs are driven by pins in several different banks, some with different I/O voltages
# external level converter chips are used to drive actual LEDs with 3.3V logic.
# Assume default value for VADJ_FPGA is 2.5V.

# User LED7 bank 18 VCCO=VADJ_FPGA=2.5V
set_property PACKAGE_PIN F16 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[7]}]

# User LED6..5 bank 17 VCCO=VADJ_FPGA=2.5V
set_property PACKAGE_PIN E18 [get_ports {led[6]}]
set_property PACKAGE_PIN G19 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[5]}]

# User LED4 bank 13 VCCO=VADJ_FPGA=2.5V
set_property PACKAGE_PIN AE26 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led[4]}]

# User LED3..0 bank 13 VCCO=1.5V
set_property PACKAGE_PIN AB9 [get_ports {led[3]}]
set_property PACKAGE_PIN AC9 [get_ports {led[2]}]
set_property PACKAGE_PIN AA8 [get_ports {led[1]}]
set_property PACKAGE_PIN AB8 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[0]}]

# #############################################################################
# General bitstream constraints...

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]

