# usage: vivado -mode tcl -source Matrix-multiplier/scripts/vivado_project.tcl -nojournal -nolog

set scriptPath      [file normalize [info script]]
set scriptDir       [file dirname $scriptPath]
set srcDir          $scriptDir/../src
set interfacesDir   $scriptDir/../interfaces

# create project for VCU128
create_project Matrix-Multiplier-Vivado $scriptDir/../../Matrix-Multiplier-Vivado -part xcvu37p-fsvh2892-2L-e
set_property board_part xilinx.com:vcu128:part0:1.0 [current_project]

# list of sv files
set interfacesFiles [glob -directory $interfacesDir *.sv]
set srcFiles        [glob -directory $srcDir *.sv]
set asyncFifoFiles  [glob -directory $srcDir/async_fifo *.sv]

add_files -norecurse $interfacesFiles
add_files -norecurse $asyncFifoFiles
add_files -norecurse $srcFiles

update_compile_order -fileset sources_1

# add constraints file
add_files -fileset constrs_1 -norecurse $scriptDir/../constraints/constraints.xdc

# run synthesys
#launch_runs synth_1 -jobs 8; # 4 cores

# set define:  set_property verilog_define abc=def [current_fileset]
set_property verilog_define XILINX=1 [current_fileset]

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

start_gui