# DAPHNE constraints
# jamieson@fnal.gov
# 11 October 2021 

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

# Ethernet MGT is "TX1" is QUAD216-1 -> X0Y5 in XC7A200T FBG676
# refclk is 125MHz on MGTREFCLK0_216 pins F11/E11.  No inversion on DAPHNE board.

set_property LOC GTPE2_CHANNEL_X0Y5 [get_cells */*/*/transceiver_inst/gtwizard_inst/*/gtwizard_i/gt0_GTWIZARD_i/gtpe2_i]
set_property LOC F11 [get_ports gtrefclk_p]

# SFP module LOSS OF SIGNAL indicator IO bank VCCO=3.3V

set_property PACKAGE_PIN L8 [get_ports sfp_los]
set_property IOSTANDARD LVTTL [get_ports {sfp_los}]

# SFP module TX DISABLE control, IO bank 35, VCCO=3.3V

set_property PACKAGE_PIN K8 [get_ports sfp_tx_dis]
set_property IOSTANDARD LVTTL [get_ports {sfp_tx_dis}]

# reset pin is from uC, I/O bank 35, VCCO=3.3V note ACTIVE LOW on DAPHNE

set_property PACKAGE_PIN J8 [get_ports reset_n]
set_property IOSTANDARD LVTTL [get_ports {reset_n}]

# SYSCLK is LVDS 200MHz comes in on bank 33, VCCO=2.5V.
# Use internal LVDS 100 ohm termination

set_property PACKAGE_PIN  AA4 [get_ports sysclk_p]
set_property PACKAGE_PIN  AB4 [get_ports sysclk_n]
set_property IOSTANDARD LVDS_25 [get_ports sysclk_p]
set_property IOSTANDARD LVDS_25 [get_ports sysclk_n]
set_property DIFF_TERM TRUE [get_ports sysclk_p]
set_property DIFF_TERM TRUE [get_ports sysclk_n]

# All 6 user LEDS are in bank 35, VCCO=3.3V, all LEDs Active High

# Assign LED7 to debug header pin 1
set_property PACKAGE_PIN C3 [get_ports {led[7]}]

# Assign LED6 to debug header pin 2
set_property PACKAGE_PIN F3 [get_ports {led[6]}]

# LED[5..0] map to user StatLED[5..0] on DAPHNE
set_property PACKAGE_PIN D3 [get_ports {led[5]}]
set_property PACKAGE_PIN A4 [get_ports {led[4]}]
set_property PACKAGE_PIN B4 [get_ports {led[3]}]
set_property PACKAGE_PIN A5 [get_ports {led[2]}]
set_property PACKAGE_PIN B5 [get_ports {led[1]}]
set_property PACKAGE_PIN C4 [get_ports {led[0]}]

set_property IOSTANDARD LVTTL [get_ports {led[7]}]
set_property IOSTANDARD LVTTL [get_ports {led[6]}]
set_property IOSTANDARD LVTTL [get_ports {led[5]}]
set_property IOSTANDARD LVTTL [get_ports {led[4]}]
set_property IOSTANDARD LVTTL [get_ports {led[3]}]
set_property IOSTANDARD LVTTL [get_ports {led[2]}]
set_property IOSTANDARD LVTTL [get_ports {led[1]}]
set_property IOSTANDARD LVTTL [get_ports {led[0]}]

# #############################################################################
# General bitstream constraints...

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

