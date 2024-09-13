module adder
    #(parameter DATA_WIDTH = 38)
    (a, b, out);
    input signed [DATA_WIDTH - 1:0] a,b;
    output signed [DATA_WIDTH - 1:0] out;
    assign out = a + b;
endmodule

module adder_tb();
    logic [37:0] a,b;
    wire [37:0] out;
    adder #(38) ut(a,b,out);
    initial begin
        a = $random;
        b = $random;
        #200
        a = $random;
        b = $random;
        #100 $stop;
    end
endmodule