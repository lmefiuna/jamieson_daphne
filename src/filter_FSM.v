module filter_FSM(
    input wire clk,
	input wire reset, 
    input wire enable,
	output wire mult_reset,
    output wire mult_enable,
    output wire acc_reset,
    output wire acc_enable,
    output wire output_reg_enable,
    output wire x_mem_enable,
    output wire y_mem_enable,
    output wire [2:0] mem_dir
    );

    reg [2:0] state, nextstate;

    parameter s0 = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;
    parameter s5 = 3'b101;
    parameter s6 = 3'b110;
    //parameter s7 = 3'b111;
    //parameter sx = 3'bxxx;
    
    always @(posedge clk) begin
        if(reset) begin
            state <= s0;
        end else if (enable) begin
            state <= nextstate;
        end
    end

    always @(*) begin
        case(state)
            s0: begin
                nextstate <= s1;
                //reset accumulador
            end
            s1: begin
                nextstate <= s2;
            end
            s2: begin
                nextstate <= s3;
            end
            s3: begin
                nextstate <= s4;
            end
            s4: begin
                nextstate <= s5;
            end
            s5: begin
                nextstate <= s6;
            end
            s6: begin
            nextstate <= s0;
                end
            //s7: begin
            //nextstate <= s0;
            //end
            default: begin
                nextstate <= s0;
            end
        endcase
    end

    assign mult_reset = ((state == s5) || (state == s6)) && enable;
    assign acc_reset = (state == s0) && enable;
    assign x_mem_enable = (state == s0) && enable;
    assign y_mem_enable = (state == s3) && enable;
    assign output_reg_enable = (state == s0) && enable;
    assign mult_enable = ((state == s0) || (state == s1) || (state == s2) || (state == s3) || (state == s4)) && enable;
    assign acc_enable = ((state == s1) || (state == s2) || (state == s3) || (state == s4) || (state == s5)) && enable;
    
    assign mem_dir = ((state == s0) && enable) ? 3'b000 : // x[n] : reg <= x[n-1]
                              ((state == s1) && enable) ? 3'b010 : // x[n-1] : reg <= x[n-2]
                              ((state == s2) && enable) ? 3'b010 : // x[n-2]
                              ((state == s3) && enable) ? 3'b011 : // y[n-1] <= reg <= y[n-2]
                              ((state == s4) && enable) ? 3'b100 : // y[n-2]
                              3'bx;

endmodule