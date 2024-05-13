set scriptPath      [file normalize [info script]]
set scriptDir       [file dirname $scriptPath]

vlib work
source $scriptDir/compile_systolic_array_top.tcl
vlog ../vivado_wrapper/mem_mock_gen.sv
vlog ../metrics/measure_metrics.sv