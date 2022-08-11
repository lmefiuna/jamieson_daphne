`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Esteban Cristaldo
//
// Create Date: 07/05/2022 02:54:52 PM
// Design Name:
// Module Name: filtroIIR_integrator
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module filtroIIR_integrator_fast(
    input wire fclk,
	input wire reset,
    input wire enable,
    input wire signed[15:0] x,
    output wire signed[15:0] y
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

    wire signed [31:0] w_x, w_x_mem_output;
    wire signed [31:0] w_y, w_y_mem_output;
    wire signed [31:0] x_y_selector_output;
    wire signed [31:0] coeff_rom_output;
    wire signed [63:0] macc_output;
    wire [1:0] w_x_mem_dir, w_y_mem_dir, selector_x_y_mem;
    wire [2:0] coefficients_dir;
    wire macc_reset, macc_enable;

    assign w_x = {x,16'b0};

    /*filter_mem_block x_mem(
    	.clk(fclk),
      .enable(x_mem_enable),
    	.reset(reset),
    	.dir(w_x_mem_dir),
    	.x(w_x),
    	.y(w_x_mem_output)
    );

    filter_mem_block y_mem(
    	.clk(fclk),
      .enable(y_mem_enable),
    	.reset(reset),
    	.dir(w_y_mem_dir),
    	.x(w_y),
    	.y(w_y_mem_output)
    );*/
    
    filter_mem_block mem_blk(
        .clk(fclk),
        .reset(reset),
        .x_enable(x_mem_enable),
        .y_enable(y_mem_enable),
        .dir(mem_dir),
        .x(w_x),
        .y(w_y),
        .out(x_y_selector_output)
    );

    /*assign x_y_selector_output = (selector_x_y_mem == 2'b00) ? w_x :
                   (selector_x_y_mem == 2'b01) ? w_x_mem_output :
    							 (selector_x_y_mem == 2'b10) ? w_y_mem_output :
    							 32'bx;*/

    filter_rom_block coefficients_rom(
    	.clk(fclk),
    	.reset(reset),
    	.dir(mem_dir),
    	.y(coeff_rom_output)
    );

    mult_and_acc macc(
      .clk(fclk),
      .reset(macc_reset),
      .enable(macc_enable),
      .a(coeff_rom_output),
      .b(x_y_selector_output),
      .c(macc_output),
      .p(macc_output)
      );

    //assign w_y = macc_output[47:16];

    reg_32 reg_output(
    	.clk(fclk),
    	.reset(reset),
    	.enable(output_reg_enable),
    	.x(macc_output[47:16]),
    	.y(w_y)
    );

    assign y = w_y[31:16];

 	always @(posedge fclk) begin
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

    assign macc_reset = (state == s7) || (state == s0);
    assign x_mem_enable = (state == s3);
    assign y_mem_enable = (state == s1);
    assign output_reg_enable = (state == s7);
    assign macc_enable = (state == s1) || (state == s2) || (state == s3) || (state == s4) || (state == s5) || (state == s6);
    /*assign w_x_mem_dir = (state == s2) ? 2'b00 :
					     (state == s3) ? 2'b01 :
					     2'bx;*/
	/*assign w_y_mem_dir = (state == s4) ? 2'b00 :
					     (state == s5) ? 2'b01 :
					     2'bx;*/
    /*assign selector_x_y_mem = (state == s1) ? 2'b00 :
    						  (state == s2) ? 2'b01 :
    						  (state == s3) ? 2'b01 :
    						  (state == s4) ? 2'b10 :
    						  (state == s5) ? 2'b10 :
    						  2'bx;*/
    assign mem_dir = (state == s1) ? 3'b000 :
    						  (state == s2) ? 3'b001 :
    						  (state == s3) ? 3'b010 :
    						  (state == s4) ? 3'b011 :
    						  (state == s5) ? 3'b100 :
    						  3'bx;

endmodule

