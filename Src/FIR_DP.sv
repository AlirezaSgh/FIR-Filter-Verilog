module fir_dp
    #(  parameter DATA_WIDTH = 16,
        parameter OUT_WIDTH = 38,
        parameter COEFF_COUNT = 64)
    (clk, rst, dp_rst, in, ld_in, ld_prod, ld_out, adr_cnt, out);
    input clk, rst, dp_rst, ld_in, ld_prod, ld_out;
    input [DATA_WIDTH-1:0] in;
    input [$clog2(COEFF_COUNT)-1:0] adr_cnt;
    output [OUT_WIDTH-1:0] out;

    wire [DATA_WIDTH-1:0] coefficient, shreg_out;

    wire [OUT_WIDTH-1:0] mult_out, prod, adder_out;

    coef_lut #(COEFF_COUNT,DATA_WIDTH) coeffs (adr_cnt,coefficient);

    shreg_stack #(COEFF_COUNT, DATA_WIDTH) in_shreg(clk, rst, in, adr_cnt, ld_in, shreg_out);

    mult_nbit #(DATA_WIDTH, OUT_WIDTH) multiplier(coefficient, shreg_out, mult_out);

    register #(OUT_WIDTH) 
            prod_reg    (mult_out, dp_rst, clk, ld_prod, prod),
            out_reg     (adder_out, dp_rst, clk, ld_out, out);
    
    adder #(OUT_WIDTH) adder (out, prod, adder_out);

endmodule