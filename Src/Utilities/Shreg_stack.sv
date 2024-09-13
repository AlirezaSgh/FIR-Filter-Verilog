module shreg_stack
    #(  parameter STACK_SIZE = 64,
        parameter DATA_WIDTH = 16)
        (clk, rst, in, adr, ld_in, out);
    input clk, rst, ld_in;
    input [$clog2(STACK_SIZE)-1:0] adr;
    input [DATA_WIDTH-1:0] in;
    output [DATA_WIDTH-1:0] out;
    logic [DATA_WIDTH-1:0] reg_out [STACK_SIZE:0];
    genvar i;
    generate
        for(i = 0; i < STACK_SIZE; i = i + 1) begin : reg_generation
            register #(.REG_WIDTH(DATA_WIDTH)) RXX (.clk(clk), .rst(rst), .din(reg_out[i]), .dout(reg_out[i+1]), .en(ld_in));
        end
    endgenerate
    
    assign reg_out[0] = in;
    assign out = reg_out[adr+1];
endmodule

module shreg_stack_tb();
    logic clk, rst, ld_in;
    logic [4:0] in;
    logic [3:0] adr;
    wire [4:0] out;
    shreg_stack #(.STACK_SIZE(8), .DATA_WIDTH(5)) UT (clk, rst,in,adr,ld_in,out);
    initial begin
        clk = 0;
        repeat (1000) #10 clk = ~clk;
    end
    initial begin
        rst = 1;
        in = 0;
        adr = 0;
        ld_in = 0;
        #50 rst = 0;
        in = $random;
        ld_in = 1;
        repeat(7) #15 in = $random;
        #20 ld_in = 0;
        repeat(7) #15 adr = adr + 1;
        #20 $stop;
    end
endmodule