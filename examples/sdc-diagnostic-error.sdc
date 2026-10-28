# 😀

create_clock -name c -period 2 [get_ports clk]
set_input_delay -clock c 0.2 [get_ports {数😀}]
	# tail
 	set_load -min 0.1 [get_ports y]
