module hpf_pedestal_recovery_filter_v4(
	input wire clk,
	input wire reset,
	input wire n_1_reset,
	input wire en,
	input wire signed [719:0] x,
	output wire signed [719:0] y
);
	//parameter afe_number = 5;
	//parameter afe_channel = 8;

	parameter s0 = 3'b000;
	parameter s1 = 3'b001;
	parameter s2 = 3'b010;
	parameter s3 = 3'b011;
	parameter s4 = 3'b100;
	parameter s5 = 3'b101;
	parameter s6 = 3'b110;
	parameter s7 = 3'b111;
	parameter sx = 3'bxxx;

	reg [2:0] state, nextstate;
	reg signed [31:0] fsm_hpf_coefficient_reg;
	//reg signed [47:0] fsm_lpf_coefficient_reg;
	reg [2:0] fsm_reg_select_reg;
	wire [2:0] fsm_reg_select;
    wire fsm_reset, fsm_n_1_reset, fsm_en, fsm_enable_reg_select;
	wire signed [31:0] fsm_hpf_coefficient;
	//wire signed [47:0] fsm_lpf_coefficient;

	wire signed [15:0] lpf_out [4:0][7:0];
	wire signed [15:0] hpf_out [4:0][7:0];
	wire signed [15:0] x_i [4:0][7:0];
    wire signed [15:0] w_resta_out [4:0][7:0];
	reg signed [15:0] resta_out [4:0][7:0];
	reg signed [15:0] suma_out [4:0][7:0];

	assign fsm_reset = (state == s0);
	assign fsm_n_1_reset = n_1_reset;
	assign fsm_reg_select = fsm_reg_select_reg;
	assign fsm_enable_reg_select = ((state == s1) || (state == s2) || (state == s3));
	assign fsm_en = ((state == s4) && (en == 1'b1));
	assign fsm_hpf_coefficient = fsm_hpf_coefficient_reg;
	//assign fsm_lpf_coefficient = fsm_lpf_coefficient_reg;
    
	generate genvar i,j;
		for(i=0; i<=4; i=i+1) begin : i_instance
		    assign y[((i*9 + 8)*16 + 15) : ((i*9 + 8)*16)] = x[((i*9 + 8)*16 + 15) : ((i*9 + 8)*16)]; // (i*9 + j)*16
            for(j=0; j<=7; j=j+1) begin : j_instance
                boxcar_filter lpf(
                    .clk(clk),
                    .reset(fsm_reset),
                    .en(fsm_en),
                    .x(x_i[i][j]),
                    .y(lpf_out[i][j])
                );

                filtroIIR_integrator hpf(
                    .clk(clk),
                    .reset(fsm_reset),
                    .n_1_reset(fsm_n_1_reset),
                    .reg_select(fsm_reg_select),
                    .enable_reg_select(fsm_enable_reg_select),
                    .en(fsm_en),
                    .coefficient(fsm_hpf_coefficient),
                    .x(w_resta_out[i][j]),
                    .y(hpf_out[i][j])
                );

                always @(*) begin
                    if(en) begin
                        suma_out[i][j] <= (hpf_out[i][j] + lpf_out[i][j]);
                        resta_out[i][j] <= (x_i[i][j] - lpf_out[i][j]);
                    end else begin
                        suma_out[i][j] <= hpf_out[i][j];
                        resta_out[i][j] <= x_i[i][j];
                    end
                end

                assign x_i[i][j] = x[((i*9 + j)*16 + 15) : ((i*9 + j)*16)];
                assign y[((i*9 + j)*16 + 15) : ((i*9 + j)*16)] = suma_out[i][j];
                assign w_resta_out[i][j] = resta_out[i][j];

            end
		end
	endgenerate
	

	always @(posedge clk) begin
		if(reset) begin
			state <= s0;
		end else begin
			state <= nextstate;
		end
 	end

	always @(*) begin
		case(state)
			s0: begin
				fsm_hpf_coefficient_reg <= 32'b0;
				//fsm_lpf_coefficient_reg <= 48'b0;
				fsm_reg_select_reg <= 3'b000;
				nextstate <= s1;
			end
			s1: begin // configuration of coefficients. Hard onfig for now
			    /**************** HPF************************************/
				fsm_hpf_coefficient_reg <= {16'b0,16'b1111111100000000}; 
				fsm_reg_select_reg <= 3'b000;
				nextstate <= s2;
			end
			s2: begin
				fsm_hpf_coefficient_reg <= {16'b1111111111111111,16'b0000000011111111 + 1'b1}; 
                fsm_reg_select_reg <= 3'b001;
				nextstate <= s3;
			end
			s3: begin
				fsm_hpf_coefficient_reg <= {16'b0,16'b1111111000000111}; 
                fsm_reg_select_reg <= 3'b010;
				nextstate <= s6;
			end
			s6: begin
				fsm_hpf_coefficient_reg <= {16'b0,16'b1111111000000111}; 
                fsm_reg_select_reg <= 3'b011;
				nextstate <= s7;
			end
			s7: begin
				fsm_hpf_coefficient_reg <= {16'b0,16'b1111111000000111}; 
                fsm_reg_select_reg <= 3'b100;
				nextstate <= s4;
			end
			s4: begin
				if(en) begin
					nextstate <= s4;
					fsm_hpf_coefficient_reg <= 32'b0;
				    //fsm_lpf_coefficient_reg <= 32'b0;
				    fsm_reg_select_reg <= 3'b000;
				end else begin
				    fsm_hpf_coefficient_reg <= 32'b0;
				    //fsm_lpf_coefficient_reg <= 32'b0;
				    fsm_reg_select_reg <= 3'b000;
					nextstate <= s5;
				end
			end
			s5: begin
				if(en) begin
                    fsm_hpf_coefficient_reg <= 32'b0;
                    //fsm_lpf_coefficient_reg <= 32'b0;
                    fsm_reg_select_reg <= 3'b000;
					nextstate <= s4;
				end else begin
                    fsm_hpf_coefficient_reg <= 32'b0;
                    //fsm_lpf_coefficient_reg <= 32'b0;
                    fsm_reg_select_reg <= 3'b000;
					nextstate <= s5;
				end
			end
			default: begin
				nextstate <= sx;
				fsm_hpf_coefficient_reg <= 32'b0;
				//fsm_lpf_coefficient_reg <= 32'b0;
				fsm_reg_select_reg <= 3'b000;
			end
		endcase
	end
endmodule
