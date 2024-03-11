# Simple TCL script for Vivado builds
# Jamieson Olsen <jamieson@fnal.gov>
#
# vivado -mode tcl -source vivado_batch.tcl

# general setup stuff...

create_project -force jamieson-vivado ./jamieson-vivado -part xc7a200t-fbg676-2

set_param general.maxThreads 8
set outputDir ./output
file mkdir $outputDir
# set_part xc7a200t-fbg676-2
set_property source_mgmt_mode All [current_project]

# load the sources and constraints...

read_vhdl ../src/daphne_package.vhd
read_vhdl ../src/febit.vhd
read_vhdl ../src/fe.vhd
read_vhdl ../src/spy.vhd
# read_vhdl ../src/sync.vhd
read_vhdl ../src/top_level.vhd
# read_verilog ../src/filtroIIR.sv
read_verilog ../src/filtroIIR_v2.sv
# read_verilog ../src/hpf_pedestal_recovery_filter.sv
# read_verilog ../src/hpf_pedestal_recovery_filter_v2.sv
# read_verilog ../src/hpf_pedestal_recovery_filter_v3.v
# read_verilog ../src/hpf_pedestal_recovery_filter_v4.sv
read_verilog ../src/hpf_pedestal_recovery_filter_v5.sv
# read_verilog ../src/DAPHNE_Integrator_Filter_TF5.v
# read_verilog ../src/boxcar_filter.v
# read_verilog ../src/filtroIIR_integrator.v
read_verilog ../src/filtroIIR_integrator_optimized.v
read_verilog ../src/filtroIIR_movmean40.v
read_verilog ../src/filtroIIR_movmean40_cfd.v
#read_verilog ../src/filtroIIR_integrator_fast.sv
#read_verilog ../src/accumulator.sv
#read_verilog ../src/reg_32.sv
#read_verilog ../src/filter_mem_block.sv
#read_verilog ../src/filter_rom_block.sv
#read_verilog ../src/filter_state_machine.sv
#read_verilog ../src/multiplier.sv
#read_verilog ../src/mult_and_acc.sv
#read_verilog ../src/filter_FSM.v
#read_verilog ../src/filter_mem_block.v
#read_verilog ../src/filter_rom_block.v 
#read_verilog ../src/reg_32.v 

read_vhdl ../src/oei/hdl/burst_traffic_controller.vhd
read_vhdl ../src/oei/hdl/ethernet_interface.vhd
read_vhdl ../src/oei/hdl/params_package.vhd

read_vhdl ../src/oei/data_manager/burst_controller_sm.vhd
read_vhdl ../src/oei/data_manager/data_manager.vhd
read_vhdl ../src/oei/data_manager/ram_comm_dec.vhd
read_vhdl ../src/oei/data_manager/rx_ctl.vhd
read_vhdl ../src/oei/data_manager/tx_seq_ctl.vhd

read_vhdl ../src/oei/ethernet_controller/address_container.vhd
read_vhdl ../src/oei/ethernet_controller/crc_splice.vhd
read_vhdl ../src/oei/ethernet_controller/ethernet_controller.vhd
read_vhdl ../src/oei/ethernet_controller/icmp_ping_checksum_calc.vhd
read_vhdl ../src/oei/ethernet_controller/reset_mgr.vhd
read_vhdl ../src/oei/ethernet_controller/arp_reply.vhd
read_vhdl ../src/oei/ethernet_controller/create_packet.vhd
read_vhdl ../src/oei/ethernet_controller/ethernet_controller_wrapper.vhd
read_vhdl ../src/oei/ethernet_controller/icmp_ping_shift_reg.vhd
read_vhdl ../src/oei/ethernet_controller/udp_data_splicer.vhd
read_verilog ../src/oei/ethernet_controller/crc_chk.v
read_vhdl ../src/oei/ethernet_controller/dataout_mux.vhd
read_vhdl ../src/oei/ethernet_controller/fifo.vhd
read_vhdl ../src/oei/ethernet_controller/ip_checksum_calc.vhd
read_vhdl ../src/oei/ethernet_controller/user_addrs_mux.vhd
read_verilog ../src/oei/ethernet_controller/crc_gen.v
read_vhdl ../src/oei/ethernet_controller/decipherer.vhd
read_vhdl ../src/oei/ethernet_controller/filter_data_out.vhd
read_vhdl ../src/oei/ethernet_controller/or33.vhd
read_vhdl ../src/oei/ethernet_controller/xmii_handler.vhd

# Load IP core container file should be *.XCIX container
# which includes the output products.  XCIX does not
# require synth_ip and generate_target commands
read_ip ../src/ip/gig_ethernet_pcs_pma_0.xcix

#source ./IIR_filter_fast_design.tcl
#generate_target all [get_files  .srcs/sources_1/bd/IIR_filter_fast_design/IIR_filter_fast_design.bd]

# Load IP module as *.xci
#read_ip ../src/ip/gig_ethernet_pcs_pma_0.xci
#set_property target_language VHDL [current_project]
#generate_target all [get_files ../src/ip/gig_ethernet_pcs_pma_0.xci]

# Load general constraints...

read_xdc -verbose ./constraints.xdc

# get the git SHA hash (commit id) and pass it to the top level source
# keep it simple just use the short form of the long SHA-1 number.
# Note this is a 7 character HEX string, e.g. 28 bits, but Vivado requires 
# this number to be in Verilog notation, even if the top level source is VHDL.

set git_sha [exec git rev-parse --short=7 HEAD]
set v_git_sha "28'h$git_sha"
puts "INFO: passing git commit number $v_git_sha to top level generic"

# synth design...

synth_design -top top_level -generic version=$v_git_sha
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_power -file $outputDir/post_synth_power.rpt
report_utilization -file $outputDir/post_synth_util.rpt

# place...

opt_design
place_design
phys_opt_design -directive AggressiveFanoutOpt
write_checkpoint -force $outputDir/post_place
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_place_timing.rpt

# route...

route_design
phys_opt_design -directive AggressiveExplore
write_checkpoint -force $outputDir/post_route

# generate reports...

report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
report_io -file $outputDir/io.rpt

# write out VHDL and constraints for timing sim...

#write_vhdl -force $outputDir/vivpram_impl_netlist.v
#write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc

# generate bitstream...

write_bitstream -force $outputDir/daphne_$git_sha.bit

# write out ILA debug probes file
# write_debug_probes -force $outputDir/probes.ltx

