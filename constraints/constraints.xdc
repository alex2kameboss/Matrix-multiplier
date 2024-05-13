create_clock -period 10.000 -name data_clk -waveform {0.000 5.000} [get_ports {bus_data_clk}]
create_clock -period 20.000 -name config_clk -waveform {0.000 10.000} [get_ports {config_clk}]
create_clock -period 2.500 -name cllogic_clk -waveform {0.000 1.250} [get_ports clk]
