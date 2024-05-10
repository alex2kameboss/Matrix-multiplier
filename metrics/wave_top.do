onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group a_bus /top_tb/a_bus/clk
add wave -noupdate -group a_bus /top_tb/a_bus/req
add wave -noupdate -group a_bus /top_tb/a_bus/ack
add wave -noupdate -group a_bus -radix unsigned /top_tb/a_bus/addr
add wave -noupdate -group a_bus -radix hexadecimal /top_tb/a_bus/data
add wave -noupdate -group a_bus /top_tb/a_bus/reset_n
add wave -noupdate -group a_bus /top_tb/a_bus/w_en
add wave -noupdate -group b_bus /top_tb/b_bus/clk
add wave -noupdate -group b_bus /top_tb/b_bus/req
add wave -noupdate -group b_bus /top_tb/b_bus/ack
add wave -noupdate -group b_bus -radix unsigned /top_tb/b_bus/addr
add wave -noupdate -group b_bus -radix hexadecimal /top_tb/b_bus/data
add wave -noupdate -group b_bus /top_tb/b_bus/reset_n
add wave -noupdate -group b_bus /top_tb/b_bus/w_en
add wave -noupdate -expand -group c_bus /top_tb/c_bus/clk
add wave -noupdate -expand -group c_bus /top_tb/c_bus/req
add wave -noupdate -expand -group c_bus /top_tb/c_bus/ack
add wave -noupdate -expand -group c_bus -radix unsigned /top_tb/c_bus/addr
add wave -noupdate -expand -group c_bus -radix hexadecimal /top_tb/c_bus/data
add wave -noupdate -expand -group c_bus /top_tb/c_bus/reset_n
add wave -noupdate -expand -group c_bus /top_tb/c_bus/w_en
add wave -noupdate -group config_bus /top_tb/cfg/pclk
add wave -noupdate -group config_bus -radix unsigned -childformat {{{/top_tb/cfg/paddr[2]} -radix unsigned} {{/top_tb/cfg/paddr[1]} -radix unsigned} {{/top_tb/cfg/paddr[0]} -radix unsigned}} -subitemconfig {{/top_tb/cfg/paddr[2]} {-height 15 -radix unsigned} {/top_tb/cfg/paddr[1]} {-height 15 -radix unsigned} {/top_tb/cfg/paddr[0]} {-height 15 -radix unsigned}} /top_tb/cfg/paddr
add wave -noupdate -group config_bus /top_tb/cfg/pwrite
add wave -noupdate -group config_bus /top_tb/cfg/psel
add wave -noupdate -group config_bus /top_tb/cfg/penable
add wave -noupdate -group config_bus -radix unsigned -childformat {{{/top_tb/cfg/pwdata[15]} -radix unsigned} {{/top_tb/cfg/pwdata[14]} -radix unsigned} {{/top_tb/cfg/pwdata[13]} -radix unsigned} {{/top_tb/cfg/pwdata[12]} -radix unsigned} {{/top_tb/cfg/pwdata[11]} -radix unsigned} {{/top_tb/cfg/pwdata[10]} -radix unsigned} {{/top_tb/cfg/pwdata[9]} -radix unsigned} {{/top_tb/cfg/pwdata[8]} -radix unsigned} {{/top_tb/cfg/pwdata[7]} -radix unsigned} {{/top_tb/cfg/pwdata[6]} -radix unsigned} {{/top_tb/cfg/pwdata[5]} -radix unsigned} {{/top_tb/cfg/pwdata[4]} -radix unsigned} {{/top_tb/cfg/pwdata[3]} -radix unsigned} {{/top_tb/cfg/pwdata[2]} -radix unsigned} {{/top_tb/cfg/pwdata[1]} -radix unsigned} {{/top_tb/cfg/pwdata[0]} -radix unsigned}} -subitemconfig {{/top_tb/cfg/pwdata[15]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[14]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[13]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[12]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[11]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[10]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[9]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[8]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[7]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[6]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[5]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[4]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[3]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[2]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[1]} {-height 15 -radix unsigned} {/top_tb/cfg/pwdata[0]} {-height 15 -radix unsigned}} /top_tb/cfg/pwdata
add wave -noupdate -group config_bus /top_tb/cfg/pready
add wave -noupdate -group config_bus /top_tb/cfg/prdata
add wave -noupdate -group config_bus /top_tb/cfg/preset_n
add wave -noupdate -radix unsigned -childformat {{{/top_tb/dut/regfile_i/registers[7]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[6]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[5]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[4]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[3]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[2]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[1]} -radix unsigned} {{/top_tb/dut/regfile_i/registers[0]} -radix unsigned}} -subitemconfig {{/top_tb/dut/regfile_i/registers[7]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[6]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[5]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[4]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[3]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[2]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[1]} {-height 15 -radix unsigned} {/top_tb/dut/regfile_i/registers[0]} {-height 15 -radix unsigned}} /top_tb/dut/regfile_i/registers
add wave -noupdate /top_tb/dut/start_clk_pulse
add wave -noupdate /top_tb/dut/done_apb
add wave -noupdate /top_tb/dut/regfile_i/end_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7760 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 327
configure wave -valuecolwidth 210
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
WaveRestoreZoom {2753 ps} {8098 ps}
