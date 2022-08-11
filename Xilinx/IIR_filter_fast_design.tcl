
################################################################
# This is a generated script based on design: IIR_filter_fast_design
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source IIR_filter_fast_design_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# filter_FSM, filter_mem_block, filter_rom_block, reg_32

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

#set list_projs [get_projects -quiet]
#if { $list_projs eq "" } {
#   create_project project_1 myproj -part xc7a200tfbg676-2
#}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name IIR_filter_fast_design

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:c_accum:12.0\
xilinx.com:ip:mult_gen:12.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
filter_FSM\
filter_mem_block\
filter_rom_block\
reg_32\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: macc
proc create_hier_cell_macc { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_macc() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -from 31 -to 0 -type data A
  create_bd_pin -dir I -from 31 -to 0 -type data B
  create_bd_pin -dir I acc_enable
  create_bd_pin -dir O -from 47 -to 0 -type data acc_output
  create_bd_pin -dir I acc_reset
  create_bd_pin -dir I -from 31 -to 0 -type clk clk
  create_bd_pin -dir I mult_enable
  create_bd_pin -dir I mult_reset

  # Create instance: c_accum_0, and set properties
  set c_accum_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_accum:12.0 c_accum_0 ]
  set_property -dict [ list \
   CONFIG.Bypass {false} \
   CONFIG.CE {true} \
   CONFIG.Implementation {DSP48} \
   CONFIG.Input_Type {Signed} \
   CONFIG.Input_Width {48} \
   CONFIG.Latency {1} \
   CONFIG.Latency_Configuration {Manual} \
   CONFIG.Output_Width {48} \
   CONFIG.SCLR {true} \
 ] $c_accum_0

  # Create instance: mult_gen_0, and set properties
  set mult_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mult_gen:12.0 mult_gen_0 ]
  set_property -dict [ list \
   CONFIG.ClockEnable {true} \
   CONFIG.MultType {Parallel_Multiplier} \
   CONFIG.Multiplier_Construction {Use_Mults} \
   CONFIG.OptGoal {Speed} \
   CONFIG.OutputWidthHigh {47} \
   CONFIG.PortAWidth {32} \
   CONFIG.PortBWidth {32} \
   CONFIG.SyncClear {true} \
   CONFIG.Use_Custom_Output_Width {true} \
 ] $mult_gen_0

  # Create port connections
  connect_bd_net -net A_1 [get_bd_pins A] [get_bd_pins mult_gen_0/A]
  connect_bd_net -net B_1 [get_bd_pins B] [get_bd_pins mult_gen_0/B]
  connect_bd_net -net acc_enable_1 [get_bd_pins acc_enable] [get_bd_pins c_accum_0/CE]
  connect_bd_net -net acc_reset_1 [get_bd_pins acc_reset] [get_bd_pins c_accum_0/SCLR]
  connect_bd_net -net c_accum_0_Q [get_bd_pins acc_output] [get_bd_pins c_accum_0/Q]
  connect_bd_net -net clk_1 [get_bd_pins clk] [get_bd_pins c_accum_0/CLK] [get_bd_pins mult_gen_0/CLK]
  connect_bd_net -net mult_enable_1 [get_bd_pins mult_enable] [get_bd_pins mult_gen_0/CE]
  connect_bd_net -net mult_gen_0_P [get_bd_pins c_accum_0/B] [get_bd_pins mult_gen_0/P]
  connect_bd_net -net mult_reset_1 [get_bd_pins mult_reset] [get_bd_pins mult_gen_0/SCLR]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set clk [ create_bd_port -dir I clk ]
  set enable [ create_bd_port -dir I enable ]
  set reset [ create_bd_port -dir I reset ]
  set x [ create_bd_port -dir I -from 15 -to 0 -type data x ]
  set y [ create_bd_port -dir O -from 15 -to 0 -type data y ]

  # Create instance: filter_FSM_0, and set properties
  set block_name filter_FSM
  set block_cell_name filter_FSM_0
  if { [catch {set filter_FSM_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $filter_FSM_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /filter_FSM_0/acc_reset]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /filter_FSM_0/mult_reset]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /filter_FSM_0/reset]

  # Create instance: filter_mem_block_0, and set properties
  set block_name filter_mem_block
  set block_cell_name filter_mem_block_0
  if { [catch {set filter_mem_block_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $filter_mem_block_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /filter_mem_block_0/reset]

  # Create instance: filter_rom_block_0, and set properties
  set block_name filter_rom_block
  set block_cell_name filter_rom_block_0
  if { [catch {set filter_rom_block_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $filter_rom_block_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /filter_rom_block_0/reset]

  # Create instance: macc
  create_hier_cell_macc [current_bd_instance .] macc

  # Create instance: reg_32_0, and set properties
  set block_name reg_32
  set block_cell_name reg_32_0
  if { [catch {set reg_32_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $reg_32_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /reg_32_0/reset]

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $util_vector_logic_0

  # Create instance: util_vector_logic_1, and set properties
  set util_vector_logic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_1 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $util_vector_logic_1

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {16} \
   CONFIG.IN1_WIDTH {16} \
 ] $xlconcat_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {16} \
 ] $xlconstant_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {47} \
   CONFIG.DIN_TO {16} \
   CONFIG.DIN_WIDTH {48} \
   CONFIG.DOUT_WIDTH {32} \
 ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {31} \
   CONFIG.DIN_TO {16} \
   CONFIG.DOUT_WIDTH {16} \
 ] $xlslice_1

  # Create port connections
  connect_bd_net -net acc_reset_1 [get_bd_pins macc/acc_reset] [get_bd_pins util_vector_logic_1/Res]
  connect_bd_net -net clk_1 [get_bd_ports clk] [get_bd_pins filter_FSM_0/clk] [get_bd_pins filter_mem_block_0/clk] [get_bd_pins filter_rom_block_0/clk] [get_bd_pins macc/clk] [get_bd_pins reg_32_0/clk]
  connect_bd_net -net enable_1 [get_bd_ports enable] [get_bd_pins filter_FSM_0/enable]
  connect_bd_net -net filter_FSM_0_acc_enable [get_bd_pins filter_FSM_0/acc_enable] [get_bd_pins macc/acc_enable]
  connect_bd_net -net filter_FSM_0_acc_reset [get_bd_pins filter_FSM_0/acc_reset] [get_bd_pins util_vector_logic_1/Op2]
  connect_bd_net -net filter_FSM_0_macc_enable [get_bd_pins filter_FSM_0/mult_enable] [get_bd_pins filter_rom_block_0/enable] [get_bd_pins macc/mult_enable]
  connect_bd_net -net filter_FSM_0_mem_dir [get_bd_pins filter_FSM_0/mem_dir] [get_bd_pins filter_mem_block_0/dir]
  connect_bd_net -net filter_FSM_0_mult_reset [get_bd_pins filter_FSM_0/mult_reset] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net filter_FSM_0_output_reg_enable [get_bd_pins filter_FSM_0/output_reg_enable] [get_bd_pins reg_32_0/enable]
  connect_bd_net -net filter_FSM_0_x_mem_enable [get_bd_pins filter_FSM_0/x_mem_enable] [get_bd_pins filter_mem_block_0/x_enable]
  connect_bd_net -net filter_FSM_0_y_mem_enable [get_bd_pins filter_FSM_0/y_mem_enable] [get_bd_pins filter_mem_block_0/y_enable]
  connect_bd_net -net filter_mem_block_0_out [get_bd_pins filter_mem_block_0/out_mem] [get_bd_pins macc/A]
  connect_bd_net -net filter_rom_block_0_y [get_bd_pins filter_rom_block_0/y] [get_bd_pins macc/B]
  connect_bd_net -net macc_acc_output [get_bd_pins macc/acc_output] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net mult_reset_1 [get_bd_pins macc/mult_reset] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net reg_32_0_y [get_bd_pins filter_mem_block_0/y] [get_bd_pins reg_32_0/y] [get_bd_pins xlslice_1/Din]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins filter_FSM_0/reset] [get_bd_pins filter_mem_block_0/reset] [get_bd_pins filter_rom_block_0/reset] [get_bd_pins reg_32_0/reset] [get_bd_pins util_vector_logic_0/Op2] [get_bd_pins util_vector_logic_1/Op1]
  connect_bd_net -net x_1 [get_bd_ports x] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins filter_mem_block_0/x] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconcat_0/In0] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins reg_32_0/x] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_ports y] [get_bd_pins xlslice_1/Dout]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


