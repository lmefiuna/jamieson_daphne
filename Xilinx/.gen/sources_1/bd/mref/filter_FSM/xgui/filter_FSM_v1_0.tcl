# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "s0" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s1" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s2" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s3" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s4" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s5" -parent ${Page_0}
  ipgui::add_param $IPINST -name "s6" -parent ${Page_0}


}

proc update_PARAM_VALUE.s0 { PARAM_VALUE.s0 } {
	# Procedure called to update s0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s0 { PARAM_VALUE.s0 } {
	# Procedure called to validate s0
	return true
}

proc update_PARAM_VALUE.s1 { PARAM_VALUE.s1 } {
	# Procedure called to update s1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s1 { PARAM_VALUE.s1 } {
	# Procedure called to validate s1
	return true
}

proc update_PARAM_VALUE.s2 { PARAM_VALUE.s2 } {
	# Procedure called to update s2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s2 { PARAM_VALUE.s2 } {
	# Procedure called to validate s2
	return true
}

proc update_PARAM_VALUE.s3 { PARAM_VALUE.s3 } {
	# Procedure called to update s3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s3 { PARAM_VALUE.s3 } {
	# Procedure called to validate s3
	return true
}

proc update_PARAM_VALUE.s4 { PARAM_VALUE.s4 } {
	# Procedure called to update s4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s4 { PARAM_VALUE.s4 } {
	# Procedure called to validate s4
	return true
}

proc update_PARAM_VALUE.s5 { PARAM_VALUE.s5 } {
	# Procedure called to update s5 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s5 { PARAM_VALUE.s5 } {
	# Procedure called to validate s5
	return true
}

proc update_PARAM_VALUE.s6 { PARAM_VALUE.s6 } {
	# Procedure called to update s6 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.s6 { PARAM_VALUE.s6 } {
	# Procedure called to validate s6
	return true
}


proc update_MODELPARAM_VALUE.s0 { MODELPARAM_VALUE.s0 PARAM_VALUE.s0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s0}] ${MODELPARAM_VALUE.s0}
}

proc update_MODELPARAM_VALUE.s1 { MODELPARAM_VALUE.s1 PARAM_VALUE.s1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s1}] ${MODELPARAM_VALUE.s1}
}

proc update_MODELPARAM_VALUE.s2 { MODELPARAM_VALUE.s2 PARAM_VALUE.s2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s2}] ${MODELPARAM_VALUE.s2}
}

proc update_MODELPARAM_VALUE.s3 { MODELPARAM_VALUE.s3 PARAM_VALUE.s3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s3}] ${MODELPARAM_VALUE.s3}
}

proc update_MODELPARAM_VALUE.s4 { MODELPARAM_VALUE.s4 PARAM_VALUE.s4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s4}] ${MODELPARAM_VALUE.s4}
}

proc update_MODELPARAM_VALUE.s5 { MODELPARAM_VALUE.s5 PARAM_VALUE.s5 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s5}] ${MODELPARAM_VALUE.s5}
}

proc update_MODELPARAM_VALUE.s6 { MODELPARAM_VALUE.s6 PARAM_VALUE.s6 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.s6}] ${MODELPARAM_VALUE.s6}
}

