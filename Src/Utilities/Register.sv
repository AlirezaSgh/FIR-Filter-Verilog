module register 
    #( parameter REG_WIDTH = 38)
    (din, rst, clk, en, dout);
    input rst, clk, en;
    input [REG_WIDTH - 1:0] din;
    output logic [REG_WIDTH - 1:0] dout;
    always @(posedge clk) begin
        if(rst)
            dout <= 0;
        else if(en)
            dout <= din;
    end
endmodule

module shregister
    #(  parameter REG_WIDTH = 38,
        parameter SHIFT_AMOUNT = 1)
    (din, rst, clk, en, shift, dout);
    input rst, clk, en, shift;
    input [REG_WIDTH - 1:0] din;
    output logic [REG_WIDTH - 1:0] dout;
    always @(posedge clk) begin
        if(rst)
            dout <= 0;
        else if(shift)
            dout <= dout >> SHIFT_AMOUNT;
        else if(en)
            dout <= din;
    end
endmodule

module reg_tb();
    logic rst, clk, en;
    logic [37:0] din;
    wire [37:0] dout;
    register #38 ut(din,rst,clk,dout);
    initial begin
        rst = 1;
        clk = 0;
        #100 
        rst = 0;
        en = 1;
        din = $random;
        #100 din = $random;
        en = 0;
        #100 $stop;
    end
    initial begin
        repeat(100) #10 clk = ~clk;
    end
endmodule