`timescale 1ns/1ns
// property reg_check(logic ld_signal, logic[37:0] in_sig, logic[37:0] out_sig);
//    logic [37:0] reg_in;
//    @(posedge clk) (reg_in = in_sig) ld_signal |-> (out_sig === reg_in);
// endproperty

module fir
    #(  parameter DATA_WIDTH = 16,
        parameter OUT_WIDTH = 38,
        parameter COEFF_COUNT = 64)
    (clk, rst, in, input_valid, out, output_valid);
    input clk, rst, input_valid;
    input [DATA_WIDTH-1:0] in;
    output output_valid;
    output [OUT_WIDTH-1:0] out;

    wire [$clog2(COEFF_COUNT)-1:0] address;

    fir_dp #(DATA_WIDTH, OUT_WIDTH, COEFF_COUNT) datapath(
        clk, rst, dp_rst, in, ld_in, ld_prod, ld_out, address, out
        );

    fir_sm #(COEFF_COUNT) state_machine(
        clk, rst, input_valid, dp_rst, ld_in, ld_prod, ld_out, output_valid, address
    );


endmodule

module fir_tb();
    sequence mult_reg_loading;
        ##1 ut.datapath.ld_prod;
    endsequence

    sequence in_reg_loading;
        ##1 ut.datapath.ld_in;
    endsequence

    sequence out_reg_loading;
        ##1 ut.datapath.ld_out;
    endsequence

    sequence multipication;
        ut.datapath.mult_out == ut.datapath.coefficient * ut.datapath.shreg_out;
    endsequence

    sequence adding;
        ut.datapath.adder_out == ut.datapath.out + ut.datapath.prod;
    endsequence

    sequence output_val_generation;
        ##131 ut.state_machine.output_valid;
    endsequence

    sequence counting;
        ut.address == ($past(ut.address) + 1'b1);
    endsequence 

    sequence under_count_state_check;
        ut.state_machine.nstate == ut.state_machine.Multiply;
    endsequence

    property out_val_assertion;
        @(posedge ut.clk) ut.state_machine.input_valid |-> output_val_generation;
    endproperty

    property multiplier_assertion;
        @(posedge ut.clk) ut.datapath.ld_prod |-> multipication;
    endproperty

    property adder_assertion;
        @(posedge ut.clk) ut.datapath.ld_out |-> adding;
    endproperty

    property address_count_assertion;
        @(posedge ut.clk) ut.state_machine.cen |=> counting;
    endproperty

    property under_count_assertion;
        @(posedge ut.clk) ((ut.state_machine.pstate == ut.state_machine.Add) and (ut.state_machine.address_cnt < ut.COEFF_COUNT)) |-> under_count_state_check;
    endproperty


    logic input_valid, clk, rst;
    logic [15:0] in;
    wire [37:0] out;
    wire output_valid;


    fir #(16,38,64) ut (clk, rst, in, input_valid, out, output_valid);

    initial begin
        clk = 0;
        repeat (500000) #10 clk = ~clk;
    end

    initial begin
        in = 0;
        input_valid = 0;
        rst = 1;
        #25
        rst = 0;
        in = 16'b0000000100100101;
        input_valid = 1;
        #25 
        input_valid = 0;
        #10000
        in = 16'b0000111000010001;
        input_valid = 1;
        #25 
        input_valid = 0;
        #10000
        in = 16'b0000100010011101;
        input_valid = 1;
        #25 
        input_valid = 0;
        #10000 $stop;
    end

    assert property(out_val_assertion) $display($stime,"\t\tStateMachine: \t\t PASS");
    else $display($stime,"\t\tStateMachine: \t\t FAILED");

    assert property(multiplier_assertion) $display ($stime,"\t\tMultiplier: \t\t PASS");
    else $display($stime,"\t\tMultiplier: \t\t FAILED");

    assert property(adder_assertion) $display($stime,"\t\tAdder: \t\t PASS");
    else $display($stime,"\t\tAdder: \t\t FAILED");

    assert property(address_count_assertion) $display($stime,"\t\tCounter: \t\t PASS");
    else $display($stime,"\t\tCounter: \t\t FAILED\nCurrent Output: %b, Expected Output: %b", ut.address, $past(ut.address) + 1'b1);

    assert property(under_count_assertion) $display($stime,"\t\tAdd To Multiply State: \t\t PASS");
    else $display($stime,"\t\tAdd To Multiply State: \t\t FAILED");


endmodule