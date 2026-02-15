import pkg_aitb::*;

module fix2fp32 (
);

//---- logic to implement ----//
/*****

1. mag = Get magnitude of fix
2. sh = Get leading 0 position
3. exp_adj = sh + shared_exp
4. mant[22:0] = mag << (23 - sh )
5. pack fp32

 S    E                 M
|-|--------|-----------------------|
 1    8                 23

*****/


endmodule
