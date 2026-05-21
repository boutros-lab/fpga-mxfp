`define M 3
`define E 2

module mxfp_gen();

localparam int m = `M;
localparam int e = `E;
//localparam int N = 1 << (m+e+1);
localparam int BIAS = (1 << (e-1)) - 1;

localparam int L_VEC = 10;

shortreal vec1 [L_VEC];
shortreal vec2 [L_VEC];

int i;
int E_bits, M_bits;

initial begin
/*
  for (i = 0; i < N; i++) begin
	logic [m+e:0] bits;
	real sign, exp, mant;

	bits = i[m+e:0];
	sign = bits[m+e] ? -1.0 : 1.0;

	M_bits = bits[m-1:0];
	E_bits = bits[m+e-1:m];

	if (M_bits == 0 && E_bits == 0) begin // ZERO
		real_vals[i] = sign * 0.0;
	end
	else if (E_bits == 0) begin // SUBNORMALS
		real_vals[i] = sign * (2.0 ** (1 - BIAS)) * (M_bits / real'(1 << m));
	end
	else begin // NORMALs
		real_vals[i] = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / real'(1 << m));
	end

  end

for (i = '0; i < 2**(m+e+1); i++) begin
	$display("real_vals[%d] = %f\n", i, to_fp32(int'(i[m+e:0])));
end
*/

for (i = '0; i < 2**(m+e+1); i++) begin
	$display("real_vals[%d] = %f\n", i, to_fp32(int'(i[m+e:0])));
end

for (i = '0; i < 2**(m+e+1); i++) begin
	$display("real_vals[%d] = %f\n", i, to_fp32(int'(i[m+e:0])));
end


$finish;
end

function automatic shortreal dot (int vec1[], int vec2[], byte shared_exp1, byte shared_exp2);
	int dot = 0;
	foreach (vec1[i])
		dot += vec1[i] * vec2[i] * (2 ** (shared_exp1 - 127)) * (2 ** (shared_exp2 - 127)); // 127 is exponent bias from OCP-MX Standard
endfunction

function automatic shortreal to_fp32 (int fp_bits);

	localparam int M = `M;
	localparam int E = `E;

	int BIAS = (1 << (E-1)) - 1;
	//logic [M+E:0] fp_bits = bits[M+E:0];

	real sign = fp_bits[M+E] ? -1.0 : 1.0;
	int M_bits = fp_bits[M-1:0];
	int E_bits = fp_bits[M+E-1:M];



	if (M_bits == 0 && E_bits == 0) begin // ZERO
		to_fp32 = sign * 0.0;
	end
	else if (E_bits == 0) begin // SUBNORMALS
		to_fp32 = sign * (2.0 ** (1 - BIAS)) * (M_bits / real'(1 << M));
	end
	else begin // NORMALs
		to_fp32 = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / real'(1 << M));
	end

endfunction
/*
function automatic shortreal exmy_to_fp32 (int M, int E, int fp_bits);

	int BIAS = (1 << (E-1)) - 1;
	//logic [M+E:0] fp_bits = bits[M+E:0];

	real sign = fp_bits[M+E] ? -1.0 : 1.0;
	int M_bits = fp_bits[M-1:0];
	int E_bits = fp_bits[M+E-1:M];



	if (M_bits == 0 && E_bits == 0) begin // ZERO
		fp32_eq = sign * 0.0;
	end
	else if (E_bits == 0) begin // SUBNORMALS
		fp32_eq = sign * (2.0 ** (1 - BIAS)) * (M_bits / real'(1 << M));
	end
	else begin // NORMALs
		fp32_eq = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / real'(1 << M));
	end

endfunction
*/

endmodule

