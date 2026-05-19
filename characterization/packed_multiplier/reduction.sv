/* SOURCE_URL: https://github.com/intel/fpga-npu/blob/main/rtl/dpe.sv

Copyright 2022 Intel Corporation

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, 
this list of conditions and the following disclaimer in the documentation and/
or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors 
may be used to endorse or promote products derived from this software without 
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

module reduction #(
	parameter DW = 16,
	parameter L = 1,
	parameter N = 16
)(
	input  [DW*L*N-1:0] din,
	output reg [DW*L-1:0] dout,
	input  valid_in,
	output reg valid_out,
	input  clk, 
	input  rst
);

reg [(N/2)*DW*L-1:0] sum;
reg valid;

genvar i, j;
generate
    if (N == 1) begin
        always @(posedge clk) begin
            dout <= din;
        end
        always @(posedge clk) begin
            if (rst) valid_out <= 0;
            else valid_out <= valid_in;
        end
    end else if (N == 2) begin
        for (j = 0; j < L; j = j + 1) begin : gen_elements_w_two_vectors
            always @(posedge clk) begin
                dout[j*DW+:DW] <= din[j*DW+:DW] + din[DW*L+j*DW+:DW];
            end
        end	
        always @(posedge clk) begin
            if (rst) valid_out <= 0;
            else valid_out <= valid_in;
        end
    end else begin
        for (i = 0; i < N/2; i = i + 1) begin : gen_vectors
            for (j = 0; j < L; j = j + 1) begin : gen_elements_w_mul_vectors
                always @(posedge clk) begin
                    sum[i*DW*L+j*DW+:DW] <= 
                        din[(2*i)*DW*L+j*DW+:DW] + din[(2*i+1)*DW*L+j*DW+:DW];
                end
            end
        end
        always @(posedge clk) begin
            if (rst) valid <= 0;
            else valid <= valid_in;
        end

        reduction #(
            .DW(DW), .L(L), .N(N/2)
        ) red (
            .din(sum), 
            .dout(dout), 
            .valid_in(valid), 
            .valid_out(valid_out), 
            .clk(clk), 
            .rst(rst)
        );
    end
endgenerate

endmodule