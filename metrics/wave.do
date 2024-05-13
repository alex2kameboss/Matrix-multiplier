onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /measure_metrics/a_req
add wave -noupdate /measure_metrics/b_req
add wave -noupdate /measure_metrics/c_req
add wave -noupdate /measure_metrics/clk
add wave -noupdate /measure_metrics/count_cycles
add wave -noupdate /measure_metrics/cycles
add wave -noupdate /measure_metrics/m
add wave -noupdate /measure_metrics/n
add wave -noupdate /measure_metrics/p
add wave -noupdate /measure_metrics/reset_n
add wave -noupdate /measure_metrics/start
add wave -noupdate /measure_metrics/a_bus/ack
add wave -noupdate /measure_metrics/a_bus/addr
add wave -noupdate /measure_metrics/a_bus/clk
add wave -noupdate /measure_metrics/a_bus/data
add wave -noupdate /measure_metrics/a_bus/req
add wave -noupdate /measure_metrics/a_bus/reset_n
add wave -noupdate /measure_metrics/a_bus/w_en
add wave -noupdate /measure_metrics/b_bus/ack
add wave -noupdate /measure_metrics/b_bus/addr
add wave -noupdate /measure_metrics/b_bus/clk
add wave -noupdate /measure_metrics/b_bus/data
add wave -noupdate /measure_metrics/b_bus/req
add wave -noupdate /measure_metrics/b_bus/reset_n
add wave -noupdate /measure_metrics/b_bus/w_en
add wave -noupdate /measure_metrics/c_bus/ack
add wave -noupdate /measure_metrics/c_bus/addr
add wave -noupdate /measure_metrics/c_bus/clk
add wave -noupdate /measure_metrics/c_bus/data
add wave -noupdate /measure_metrics/c_bus/req
add wave -noupdate /measure_metrics/c_bus/reset_n
add wave -noupdate /measure_metrics/c_bus/w_en
add wave -noupdate -radix hexadecimal -childformat {{{/measure_metrics/dut/c_array_output[15]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[14]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[13]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[12]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[11]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[10]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[9]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[8]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[7]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[6]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[5]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[4]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[3]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[2]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[1]} -radix hexadecimal} {{/measure_metrics/dut/c_array_output[0]} -radix hexadecimal}} -expand -subitemconfig {{/measure_metrics/dut/c_array_output[15]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[14]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[13]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[12]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[11]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[10]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[9]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[8]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[7]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[6]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[5]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[4]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[3]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[2]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[1]} {-height 15 -radix hexadecimal} {/measure_metrics/dut/c_array_output[0]} {-height 15 -radix hexadecimal}} /measure_metrics/dut/c_array_output
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/DATA_SIZE
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/DEPTH
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/mem
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/r_addr_i
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/r_data_o
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/w_addr_i
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/w_clk
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/w_data_i
add wave -noupdate -expand -group a_mem_bank /measure_metrics/dut/a_mem_bank/w_en_i
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/DATA_SIZE
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/DEPTH
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/mem
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/r_addr_i
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/r_data_o
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/w_addr_i
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/w_clk
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/w_data_i
add wave -noupdate -expand -group b_mem_bank /measure_metrics/dut/b_mem_bank/w_en_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {403 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 360
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {27099 ps}
