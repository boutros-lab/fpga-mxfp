onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tensor_all_ports_tb/clk
add wave -noupdate /tensor_all_ports_tb/load_bb_one
add wave -noupdate /tensor_all_ports_tb/load_bb_two
add wave -noupdate /tensor_all_ports_tb/load_buf_sel
add wave -noupdate /tensor_all_ports_tb/acc_en
add wave -noupdate /tensor_all_ports_tb/zero_en
add wave -noupdate /tensor_all_ports_tb/data_in
add wave -noupdate /tensor_all_ports_tb/shared_exp
add wave -noupdate /tensor_all_ports_tb/fp32_col_1
add wave -noupdate /tensor_all_ports_tb/fp32_col_2
add wave -noupdate /tensor_all_ports_tb/fp32_col_1_flag
add wave -noupdate /tensor_all_ports_tb/fp32_col_2_flag
add wave -noupdate /tensor_all_ports_tb/clr
add wave -noupdate /tensor_all_ports_tb/ena
add wave -noupdate /tensor_all_ports_tb/cascade_data_in_col_1
add wave -noupdate /tensor_all_ports_tb/cascade_data_out_col_1
add wave -noupdate /tensor_all_ports_tb/cascade_data_in_col_2
add wave -noupdate /tensor_all_ports_tb/cascade_data_out_col_2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {1 ns}
