module fir_sm
    #(  parameter COEFF_COUNT = 64)
    (clk, rst, input_valid, dp_rst, ld_in, ld_prod, ld_out, output_valid, address_cnt);
    input clk, rst, input_valid;
    output logic dp_rst, ld_in, ld_prod, ld_out, output_valid;
    output logic [$clog2(COEFF_COUNT):0] address_cnt;

    parameter[2:0] Idle = 0, Start = 1, LoadIn = 2, Multiply = 3, Add = 4, Done = 5;

    logic [2:0] pstate, nstate;
    logic cen;

    always @(posedge clk) begin
        if(rst)
            pstate <= Idle;
        else
            pstate <= nstate;
    end

    always @(posedge clk) begin
        if(dp_rst)
            address_cnt = 0;
        else if(cen)
            address_cnt = address_cnt + 1;
    end

    always @(pstate, input_valid,address_cnt) begin
        dp_rst = 0;
        ld_in = 0;
        ld_out = 0;
        ld_prod = 0;
        output_valid = 0;
        cen = 0;

        case (pstate)
            Idle: nstate = input_valid ? Start : Idle;
            Start: begin
                 nstate = input_valid ? Start : LoadIn; 
                 dp_rst = 1;
            end
            LoadIn: begin
                nstate = Multiply;
                ld_in = 1;
            end
            Multiply: begin
                nstate = Add;
                cen = 1;
                ld_prod = 1;
            end
            Add: begin
                ld_out = 1;
                if(address_cnt == COEFF_COUNT)
                    nstate = Done;
                else
                    nstate = Multiply;
            end
            Done: begin
                output_valid = 1;
                nstate = Idle;
            end
           
        endcase
    end
endmodule