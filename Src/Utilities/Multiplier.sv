module mult_nbit
    #(  parameter IN_WIDTH = 8,
        parameter OUT_WIDTH = 19)
        (a, b, prod);
    input signed[IN_WIDTH-1:0] a, b;
    output signed[OUT_WIDTH-1:0] prod;
    assign prod = a * b;
endmodule

module mult_tb();
    logic [15:0] in1,in2;
    wire [37:0] out;
    multiplier #(16,38) ut (in1,in2,out);
    initial begin
        in1 = $random;
        in2 = $random;
        #200
        in1 = $random;
        in2 = $random;
        #100 $stop;
    end
endmodule