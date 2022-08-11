`timescale 1ns/10ps
module boxcar_filter(
	input wire clk,
	input wire reset, 
	input wire en, 
	input wire signed[15:0] x,
    output wire signed[15:0] y
);

    parameter s0 = 2'b00;
    parameter s1 = 2'b01;
    parameter s2 = 2'b10;
    parameter sx = 2'bxx;
     
	reg [47:0] acc1, acc2, counter;
	reg [15:0] output_latch;
	reg [2:0] state, nextstate;
	reg selector;
	
	wire [47:0] w1, w2, w3, w4, w5;
	wire [15:0] w6, w7, w8;
	wire counter_value;
	
	always @(posedge clk) begin 
	   if(reset) begin
	       state <= s0;
	       counter <= 48'b0;
	   end else begin
	       counter <= counter + 1'b1;
	       state <= nextstate;
	   end 
	end
	
	always @(*) begin 
	   case(state) 
	       s0: begin 
               acc1 <= 48'b0;
               acc2 <= 48'b0;
               output_latch <= 16'b0;
               selector <= 1'b0;
               nextstate <= s1;
	       end
	       s1: begin 
	           if (counter_value) begin
	               acc2 <= w2;
	               acc1 <= 48'b0;
	               output_latch <= 16'b0;
	               selector <= 1'b1;
	               nextstate <= s2;
	           end else begin
	               acc1 <= w1;
	               acc2 <= w2;
	               output_latch <= 16'b0; 
	               selector <= 1'b0;
	               nextstate <= s1;
	          end
	       end 
	       s2: begin 
	           acc1 <= w1;
	           acc2 <= w2;
	           output_latch <= w6;
	           selector <= 1'b0;
	           nextstate <= s2;
	       end
	       default: begin 
	           nextstate <= sx;
	           acc1 <= 48'bx;
	           acc2 <= 48'bx;
	           output_latch <= 16'bx;
	           selector <= 1'bx;
          end
	  endcase
   end
   
   assign w1 = x + w4;
   assign w2 = acc1;
   assign w3 = acc2;
   
   assign w4 = (selector==0) ?   w2 : 
               (selector==1) ?   w3 : 
                                 48'bx;   
   
   assign w5 = w2[39:24];
   assign w6 = w5;
   assign w7 = output_latch;
   assign w8 = 16'b0;
   
   assign y = (en==0) ?   w8 : 
              (en==1) ?   w7 : 
                          16'bx;  
   
   assign counter_value = counter[24];
            
endmodule
	

	  
