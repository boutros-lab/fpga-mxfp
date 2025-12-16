onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mxfp_dot_tb/clk
add wave -noupdate /mxfp_dot_tb/rst
add wave -noupdate /mxfp_dot_tb/load_en
add wave -noupdate /mxfp_dot_tb/valid_in
add wave -noupdate /mxfp_dot_tb/dut_data_in
add wave -noupdate /mxfp_dot_tb/dut_shared_exponent
add wave -noupdate -radix float32 -childformat {{{/mxfp_dot_tb/result[31]} -radix float32} {{/mxfp_dot_tb/result[30]} -radix float32} {{/mxfp_dot_tb/result[29]} -radix float32} {{/mxfp_dot_tb/result[28]} -radix float32} {{/mxfp_dot_tb/result[27]} -radix float32} {{/mxfp_dot_tb/result[26]} -radix float32} {{/mxfp_dot_tb/result[25]} -radix float32} {{/mxfp_dot_tb/result[24]} -radix float32} {{/mxfp_dot_tb/result[23]} -radix float32} {{/mxfp_dot_tb/result[22]} -radix float32} {{/mxfp_dot_tb/result[21]} -radix float32} {{/mxfp_dot_tb/result[20]} -radix float32} {{/mxfp_dot_tb/result[19]} -radix float32} {{/mxfp_dot_tb/result[18]} -radix float32} {{/mxfp_dot_tb/result[17]} -radix float32} {{/mxfp_dot_tb/result[16]} -radix float32} {{/mxfp_dot_tb/result[15]} -radix float32} {{/mxfp_dot_tb/result[14]} -radix float32} {{/mxfp_dot_tb/result[13]} -radix float32} {{/mxfp_dot_tb/result[12]} -radix float32} {{/mxfp_dot_tb/result[11]} -radix float32} {{/mxfp_dot_tb/result[10]} -radix float32} {{/mxfp_dot_tb/result[9]} -radix float32} {{/mxfp_dot_tb/result[8]} -radix float32} {{/mxfp_dot_tb/result[7]} -radix float32} {{/mxfp_dot_tb/result[6]} -radix float32} {{/mxfp_dot_tb/result[5]} -radix float32} {{/mxfp_dot_tb/result[4]} -radix float32} {{/mxfp_dot_tb/result[3]} -radix float32} {{/mxfp_dot_tb/result[2]} -radix float32} {{/mxfp_dot_tb/result[1]} -radix float32} {{/mxfp_dot_tb/result[0]} -radix float32}} -subitemconfig {{/mxfp_dot_tb/result[31]} {-height 14 -radix float32} {/mxfp_dot_tb/result[30]} {-height 14 -radix float32} {/mxfp_dot_tb/result[29]} {-height 14 -radix float32} {/mxfp_dot_tb/result[28]} {-height 14 -radix float32} {/mxfp_dot_tb/result[27]} {-height 14 -radix float32} {/mxfp_dot_tb/result[26]} {-height 14 -radix float32} {/mxfp_dot_tb/result[25]} {-height 14 -radix float32} {/mxfp_dot_tb/result[24]} {-height 14 -radix float32} {/mxfp_dot_tb/result[23]} {-height 14 -radix float32} {/mxfp_dot_tb/result[22]} {-height 14 -radix float32} {/mxfp_dot_tb/result[21]} {-height 14 -radix float32} {/mxfp_dot_tb/result[20]} {-height 14 -radix float32} {/mxfp_dot_tb/result[19]} {-height 14 -radix float32} {/mxfp_dot_tb/result[18]} {-height 14 -radix float32} {/mxfp_dot_tb/result[17]} {-height 14 -radix float32} {/mxfp_dot_tb/result[16]} {-height 14 -radix float32} {/mxfp_dot_tb/result[15]} {-height 14 -radix float32} {/mxfp_dot_tb/result[14]} {-height 14 -radix float32} {/mxfp_dot_tb/result[13]} {-height 14 -radix float32} {/mxfp_dot_tb/result[12]} {-height 14 -radix float32} {/mxfp_dot_tb/result[11]} {-height 14 -radix float32} {/mxfp_dot_tb/result[10]} {-height 14 -radix float32} {/mxfp_dot_tb/result[9]} {-height 14 -radix float32} {/mxfp_dot_tb/result[8]} {-height 14 -radix float32} {/mxfp_dot_tb/result[7]} {-height 14 -radix float32} {/mxfp_dot_tb/result[6]} {-height 14 -radix float32} {/mxfp_dot_tb/result[5]} {-height 14 -radix float32} {/mxfp_dot_tb/result[4]} {-height 14 -radix float32} {/mxfp_dot_tb/result[3]} {-height 14 -radix float32} {/mxfp_dot_tb/result[2]} {-height 14 -radix float32} {/mxfp_dot_tb/result[1]} {-height 14 -radix float32} {/mxfp_dot_tb/result[0]} {-height 14 -radix float32}} /mxfp_dot_tb/result
add wave -noupdate /mxfp_dot_tb/valid_out
add wave -noupdate /mxfp_dot_tb/result_flags
add wave -noupdate /mxfp_dot_tb/golden_dot
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6977 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {38850 ps}
