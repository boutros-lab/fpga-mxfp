package pkg_aitb;

	//---- timing ----//
	timeunit 1ns;
	timeprecision 1ps;

	//---- params ----//
	parameter FLAT_DATA_WIDTH  = 80;

	parameter FIXED_DATA_WIDTH = 8;
	parameter MXFP8_DATA_WIDTH = 8;
	parameter MXFP6_DATA_WIDTH = 6;
	parameter MXFP4_DATA_WIDTH = 4;

	parameter FIXED_ELEMENTS = 10;
	parameter MXFP8_ELEMENTS = 8;
	parameter MXFP6_ELEMENTS = 4;
	parameter MXFP4_ELEMENTS = 4;

	parameter SH_EXP_WIDTH  = 8;
	parameter DATA_WIDTH    = 8;
	parameter DOT_LENGTH    = 10;
	parameter DOT_OUT_WIDTH = 20;

	//  Widths
	//   EXP and MAN widths of largest formats for a given width
	parameter MXFP8_MAX_EXP = 5;
	parameter MXFP8_MAX_MAN = 3;
	parameter MXFP6_MAX_EXP = 3;
	parameter MXFP6_MAX_MAN = 3;
	parameter MXFP4_MAX_EXP = 2;
	parameter MXFP4_MAX_MAN = 1;

	// Encoding of fixed inputs on MXFP8/6 elements
	parameter FIXED_MAN_ENC = 4;
	parameter FIXED_EXP_ENC = 3;
	
	parameter MXFP8_PRODUCT_WIDTH = 2 * ((1 << MXFP8_MAX_EXP) + 2) - 1; // 67, E5M2
	parameter MXFP6_PRODUCT_WIDTH = 2 * ((1 << MXFP6_MAX_EXP) + 2) - 1; // 19, E3M2
	parameter MXFP4_PRODUCT_WIDTH = 2 * ((1 << MXFP4_MAX_EXP) + MXFP4_MAX_MAN) - 1; // 9, E2M1

	parameter FIXED_RESULT_WIDTH = MXFP8_PRODUCT_WIDTH + $clog2(MXFP8_ELEMENTS); // 70

	// Fix2Float Exponent Corrections
	parameter FP32_BIAS = 8'd127;

	// Point position after multiplication
	parameter POINT_POSITION_FIXED =  0;
	parameter POINT_POSITION_E5M2  = 32;
	parameter POINT_POSITION_E4M3  = 18;
	parameter POINT_POSITION_E3M2  =  8;
	parameter POINT_POSITION_E2M3  =  6;
	parameter POINT_POSITION_E2M1  =  2;

	//---- tasks ----//
	
	//---- enums ----//
	typedef enum logic [2:0] {MXFP4, MXFP6_23, MXFP6_32, MXFP8_43, MXFP8_52, FIXED} mxfp_mode_e;

endpackage
