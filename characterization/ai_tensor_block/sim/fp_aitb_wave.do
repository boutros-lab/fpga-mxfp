onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fp_aitb_tb/clk
add wave -noupdate /fp_aitb_tb/rst
add wave -noupdate /fp_aitb_tb/i_load_en
add wave -noupdate /fp_aitb_tb/i_valid
add wave -noupdate /fp_aitb_tb/i_data
add wave -noupdate /fp_aitb_tb/o_result0
add wave -noupdate /fp_aitb_tb/o_result_cascade
add wave -noupdate /fp_aitb_tb/o_out_flags
add wave -noupdate /fp_aitb_tb/load0_data
add wave -noupdate /fp_aitb_tb/load1_data
add wave -noupdate /fp_aitb_tb/input_data
add wave -noupdate /fp_aitb_tb/golden_result0
add wave -noupdate /fp_aitb_tb/golden_result1
add wave -noupdate /fp_aitb_tb/dut/fp32_col_2_w
add wave -noupdate /fp_aitb_tb/dut/fp32_col_2_flag_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9598 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 158
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
WaveRestoreZoom {0 ps} {57914 ps}
