module coef_lut 
    #(parameter STACK_SIZE = 64,
      parameter DATA_WIDTH = 16)
    (addr, rom_out);
    input [$clog2(STACK_SIZE) - 1:0] addr;
    output [DATA_WIDTH - 1:0] rom_out;
    logic [DATA_WIDTH - 1:0] rom [STACK_SIZE - 1:0];
    
    assign rom_out = rom[addr];

    initial begin
        $readmemb("coeffs.txt",rom);
    end
endmodule

module ROM_TB();
    logic [5:0] addr;
    logic clk;
    wire [15:0] out;
    coef_lut #(64,16) ut (addr,out);
    initial begin
        clk = 0;
        repeat (1000) #10 clk = ~clk;
    end
    initial begin
        addr = 0;
        repeat(64) #15 addr = addr + 1;
        #20 $stop;
    end
endmodule