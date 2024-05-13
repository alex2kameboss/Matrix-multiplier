# usage: vivado -mode tcl -source Matrix-multiplier/scripts/vivado_project.tcl -nojournal -nolog

set scriptPath      [file normalize [info script]]
set scriptDir       [file dirname $scriptPath]
set srcDir          $scriptDir/../src
set interfacesDir   $scriptDir/../interfaces

# project parameters
set useXilinx       1
set dataWidth       8
set arrayWidth      16
set memAddrWidth    16

# create project for VCU128
create_project Matrix-Multiplier-Vivado $scriptDir/../../Matrix-Multiplier-Vivado -part xcvu37p-fsvh2892-2L-e
set_property board_part xilinx.com:vcu128:part0:1.0 [current_project]

# list of sv files
set interfacesFiles [glob -directory $interfacesDir *.sv]
set srcFiles        [glob -directory $srcDir *.sv]
if { !$useXilinx } {
    set asyncFifoFiles  [glob -directory $srcDir/async_fifo *.sv]
    add_files -norecurse $asyncFifoFiles
}

add_files -norecurse $scriptDir/../vivado_wrapper/wrapper.sv
add_files -norecurse $scriptDir/../vivado_wrapper/mem_mock_gen.sv
add_files -norecurse $interfacesFiles
add_files -norecurse $srcFiles

update_compile_order -fileset sources_1

# add constraints file
add_files -fileset constrs_1 -norecurse $scriptDir/../constraints/constraints.xdc

# set define:  set_property verilog_define abc=def [current_fileset]
set_property verilog_define [list \
    XILINX=1  \
    "A_WIDTH=$arrayWidth" \
    "A_HEIGHT=$arrayWidth" \
    "MEM_ADDR_WIDTH=$memAddrWidth"
] [current_fileset]

# create xilinx IPs

# create MAC
create_ip -name dsp_macro -vendor xilinx.com -library ip -version 1.0 -module_name mac_dsp
set_property -dict [list \
  CONFIG.Component_Name {mac_dsp} \
  CONFIG.a_binarywidth {0} \
  CONFIG.a_width {8} \
  CONFIG.areg_3 {false} \
  CONFIG.areg_4 {false} \
  CONFIG.b_binarywidth {0} \
  CONFIG.b_width {8} \
  CONFIG.breg_3 {false} \
  CONFIG.breg_4 {false} \
  CONFIG.c_binarywidth {0} \
  CONFIG.c_width {16} \
  CONFIG.concat_binarywidth {0} \
  CONFIG.concat_width {48} \
  CONFIG.creg_3 {false} \
  CONFIG.creg_4 {false} \
  CONFIG.creg_5 {false} \
  CONFIG.d_width {18} \
  CONFIG.instruction2 {A*B} \
  CONFIG.mreg_5 {false} \
  CONFIG.opreg_3 {false} \
  CONFIG.opreg_4 {false} \
  CONFIG.opreg_5 {false} \
  CONFIG.output_properties {User_Defined} \
  CONFIG.p_binarywidth {16} \
  CONFIG.p_full_width {17} \
  CONFIG.p_width {16} \
  CONFIG.pcin_binarywidth {0} \
  CONFIG.pipeline_options {By_Tier} \
  CONFIG.preg_6 {true} \
  CONFIG.tier_6 {true} \
] [get_ips mac_dsp]

# create addr_fifo
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name addr_fifo
set_property -dict [list \
  CONFIG.Component_Name {addr_fifo} \
  CONFIG.Enable_Reset_Synchronization {false} \
  CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
  CONFIG.Input_Data_Width {16} \
  CONFIG.Input_Depth {256} \
  CONFIG.Reset_Pin {true} \
  CONFIG.Use_Embedded_Registers {false} \
] [get_ips addr_fifo]

# create data_fifo
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name data_fifo
set_property -dict [list \
  CONFIG.Component_Name {data_fifo} \
  CONFIG.Enable_Reset_Synchronization {false} \
  CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
  CONFIG.Input_Data_Width {256} \
  CONFIG.Input_Depth {256} \
  CONFIG.Reset_Pin {true} \
  CONFIG.Use_Embedded_Registers {false} \
] [get_ips data_fifo]

# create memory block
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name mem_block
set_property -dict [list \
  CONFIG.Component_Name {mem_block} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Enable_B {Always_Enabled} \
  CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
  CONFIG.Operating_Mode_A {READ_FIRST} \
  CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
  CONFIG.Write_Depth_A [list [expr int(pow($memAddrWidth, 2))]] \
  CONFIG.Write_Width_A [list [expr int($arrayWidth * $dataWidth)]] \
] [get_ips mem_block]

# create result_data_fifo
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name result_data_fifo
set_property -dict [list \
  CONFIG.Component_Name {result_data_fifo} \
  CONFIG.Enable_Reset_Synchronization {false} \
  CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
  CONFIG.Input_Data_Width {256} \
  CONFIG.Input_Depth {4096} \
  CONFIG.Reset_Pin {true} \
  CONFIG.Use_Embedded_Registers {false} \
] [get_ips result_data_fifo]

# generate IPs
generate_target all [get_ips]
synth_ip [get_ips]

# run synthesys
#launch_runs synth_1 -jobs 8; # 4 cores
set_param general.maxThreads 4
synth_design

start_gui

refresh_design
report_utilization -name utilization_1