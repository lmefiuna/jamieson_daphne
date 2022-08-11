module filter_state_machine(
    input wire clk,
	input wire reset, 
    input wire enable,
	output wire [1:0] w_x_mem_dir,
    output wire [1:0] w_y_mem_dir,
    output wire selector_x_y_mem,
    output wire [2:0] coefficients_dir,
    output wire acc_reset,
    output wire acc_enable,
    output wire mult_enable,
    output wire output_reg_enable
    );

    reg [2:0] state, nextstate;

    parameter s0 = 3'b000;
    parameter s1 = 3'b001;
    parameter s2 = 3'b010;
    parameter s3 = 3'b011;
    parameter s4 = 3'b100;
    parameter s5 = 3'b101;
    parameter s6 = 3'b110;
    parameter s7 = 3'b111;
    parameter sx = 3'bxxx;
    
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
                nextstate <= s7;
            end
            s7: begin
                nextstate <= s1;
            end
            default: begin
                nextstate <= sx;
            end
        endcase
    end

    assign acc_reset = (state == s7) || (state == s0);
    assign output_reg_enable = (state == s6);
    assign mult_enable = (state == s1) || (state == s2) || (state == s3) || (state == s4) || (state == s5);
    assign acc_enable = (state == s2) || (state == s3) || (state == s4) || (state == s5) || (state == s6);
    assign w_x_mem_dir = (state == s2) ? 2'b00 :
                         (state == s3) ? 2'b01 :
                         2'bx;
     assign w_y_mem_dir = (state == s4) ? 2'b00 :
                         (state == s5) ? 2'b01 :
                         2'bx;
    assign selector_x_y_mem = (state == s1) ? 2'b00 :
                              (state == s2) ? 2'b01 :
                              (state == s3) ? 2'b01 :
                              (state == s4) ? 2'b10 :
                              (state == s5) ? 2'b10 :
                              2'bx;
    assign coefficients_dir = (state == s1) ? 3'b000 :
                              (state == s2) ? 3'b001 :
                              (state == s3) ? 3'b010 :
                              (state == s4) ? 3'b011 :
                              (state == s5) ? 3'b100 :
                              3'bx;

endmodule