module mxfp_gen();

localparam int m = 3;
localparam int e = 2;
//localparam int N = 1 << (m+e+1);
localparam int BIAS = (1 << (e-1)) - 1;

localparam int L_VEC = 10;

shortreal real_vals [1 << (m+e+1)];
shortreal vec1 [L_VEC];
shortreal vec2 [L_VEC];

int i;
int E_bits, M_bits;

initial begin
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
	else if (E_bits == 0) begin //CURSED SUBNORMALS
		real_vals[i] = sign * (2.0 ** (1 - BIAS)) * (M_bits / real'(1 << m));
	end
	else begin // NORMALs
		real_vals[i] = sign * (2.0 ** (E_bits - BIAS)) * (1.0 + M_bits / real'(1 << m));
	end

end
for (i = '0; i < 2**(m+e+1); i++) begin
	$display("real_vals[%d] = %f\n", i, real_vals[i]);
end

$finish;
end



endmodule

