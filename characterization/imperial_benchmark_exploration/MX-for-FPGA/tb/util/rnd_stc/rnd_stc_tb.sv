module rnd_stc_tb #(
    parameter width_i = 24,
    parameter width_o = 4
)();

    localparam width_diff  = width_i - width_o;

    import "DPI-C" pure function int rnd_stc_ref(input int unsigned i_num,
                                             input int unsigned width_diff,
                                             input int unsigned width_o,
                                             input int unsigned noise);


    // DUT
    logic [width_i-1:0] num;
    logic [6-1:0] noise;
    logic [width_o-1:0] man_out;
    logic ofl_out;

    rnd_stc # (
        .width_i(width_i),
        .width_o(width_o)
    ) u0_rnd_stc (
        .i_num(num),
        .i_noise(noise),
        .o_man(man_out),
        .o_ofl(ofl_out)
    );


    // Reference
    logic [width_i-1:0] ref_in;
    logic [6-1:0] ref_noise;
    int ref_out;

    real r_ref_in;
    real r_ref_out;
    real r_dut_out;

    int i;
    int j;

    initial begin
        #1;
        $display("Starting -----");
        $display("Width in:  %d", width_i);
        $display("Width out: %d", width_o);

        for(i=(1<<(width_i-1)); i<(1<<width_i); i++) begin
            for(j=0; j<(1<<6); j++) begin

                ref_in  = i;
                ref_noise = j;
                ref_out = rnd_stc_ref(ref_in, width_diff, width_o, ref_noise);

                r_ref_in  = $itor(ref_in);
                r_ref_out = $itor(ref_out);

                num = ref_in;
                noise = ref_noise;
                #10
                r_dut_out = $itor(man_out);

                if(r_ref_out >= (1<<width_o)) begin
                    if(~ofl_out) begin
                        $display("Ref in:  %d", ref_in);
                        $display("Ref in:  %f", r_ref_in);
                        $display("DUT out: %f", r_dut_out);
                        $display("Ref out: %f  <- Mismatch!", r_ref_out);
                        $display("FAILED");
                        $finish();
                    end
                end else if((r_ref_out != r_dut_out) || $isunknown(man_out)) begin
                    $display("Ref in:  %d", ref_in);
                    $display("Ref in:  %f", r_ref_in);
                    $display("DUT out: %f", r_dut_out);
                    $display("Ref out: %f  <- Mismatch!", r_ref_out);
                    $display("FAILED");
                    $finish();
                end
            end
        end

        $display("PASSED");
        $finish();
    end


endmodule
