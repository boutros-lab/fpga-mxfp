#!/bin/bash
# Generate table IV from ASIC reports (Genus+Innovus) and COFFE reports 
# for area and timing

output_file=$PROJ_ROOT/table_iv.csv

# Get COFFE Hard Block, Switch Block, Connection Block Area
coffe_rpts=($PROJ_ROOT/coffe_rpts/aitb_104_inputs/arch_out_dir/report.txt $PROJ_ROOT/coffe_rpts/aitb_96_inputs/arch_out_dir/report.txt)
coffe_area=()

for rpt in "${coffe_rpts[@]}"; do
	crossbar_area=`grep "Local mux area with sram:" $rpt | awk '{print $NF}'`
	chain_buffers=`grep "Dedicated output routing area:" $rpt | awk '{print $NF}'`
	switch_block=`grep "Switch block" $rpt | tail -n 1 | awk '{print $(NF-1)}'`
	connection_block=`grep "Connection block" $rpt | tail -n 1 | awk '{print $(NF-1)}'`
	
	coffe_area+=(`echo "scale=2; ($crossbar_area + $chain_buffers + $switch_block + $connection_block) / 1" | bc`)
done

# Get timing and scaled area of designs from ASIC (Genus+Innovus) reports
asic_rpts=($PROJ_ROOT/asic_rpts/0_base
	$PROJ_ROOT/asic_rpts/1_fixed_point_inputs
	$PROJ_ROOT/asic_rpts/2_mxfp_inputs_all
	$PROJ_ROOT/asic_rpts/3_1_mxfp_inputs_no_mxfp8/
	$PROJ_ROOT/asic_rpts/3_2_mxfp_inputs_no_e5m2/
	$PROJ_ROOT/asic_rpts/3_3_mxfp_inputs_reduce_e5m2/
	$PROJ_ROOT/asic_rpts/4_mxfp_inputs_no_e5m2_fixed8/)

asic_area=()
asic_fmax=()

for rpt in "${asic_rpts[@]}"; do
	area=`head -n3 $rpt/area.rpt | tail -n1 | awk '{print $NF}'`
	slack=`grep "Slack" $rpt/timing.rpt | awk '{print $NF}'`

	period=`echo "2000 - $slack" | bc`
	fmax=`echo "scale=2; 1000000 / $period" | bc`
	
	# ASAP7 requires a scaling factor of /16 for sub 20nm processes
	asic_area+=(`echo "scale=2; $area / 16" | bc`)
	asic_fmax+=($fmax)
done

combined_area=()
ratio=()

# Combine COFFE and ASIC results for area
for ((i=0; i<${#asic_area[@]}; i++)); do
	if [ $i -eq 6 ]; then
		# Use 96 Input COFFE results for fixed8 design
		combined_area+=(`echo "scale=2; ${asic_area[i]} + ${coffe_area[1]}" | bc`)
	else
		combined_area+=(`echo "scale=2; ${asic_area[i]} + ${coffe_area[0]}" | bc`)
	fi

	ratio+=(`echo "scale=2; ${combined_area[i]} / ${combined_area[0]}" | bc`)
done

description=("Baseline"
             "(1) Fixed-point inputs"
             "(2) MXFP inputs (all)"
             "(3.1) MXFP inputs (No MXFP8)"
             "(3.2) MXFP inputs (No E5M2)"
             "(3.3) MXFP inputs (reduce E5M2)"
             "(4) MXFP inputs (No E5M2)")

format_inputs=("10,10,10,X,X,X"
               "10,16,11,8,X,X"
               "10,16,12,12,8,8"
               "10,16,12,8,X,X"
               "10,16,12,8,8,X"
               "10,16,12,8,8,4"
               "8,16,12,8,8,X")

#Write to CSV
echo ",Dot Size per Format,,,,,,FMAX,Std. Cell,Interface,Total Tile,Area" > $output_file
echo "Design Iteration,INT8,E2M1,E2M3,E3M2,E4M3,E5M2,(MHz),Core (µm2),Area (µm2),Area (µm2),Ratio" >> $output_file

for ((i=0; i<${#asic_area[@]}; i++)); do
	if [ $i -eq 6 ]; then
		# Use 96 Input COFFE results for fixed8 design
		echo "${description[i]},${format_inputs[i]},${asic_fmax[i]},${asic_area[i]},${coffe_area[1]},${combined_area[i]},${ratio[i]}" >> $output_file
	else
		echo "${description[i]},${format_inputs[i]},${asic_fmax[i]},${asic_area[i]},${coffe_area[0]},${combined_area[i]},${ratio[i]}" >> $output_file
	fi
done

cat $output_file | column -t -s ,
