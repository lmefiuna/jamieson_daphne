`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/04/2022 07:30:06 PM
// Design Name:
// Module Name: DAPHNE_Integrator_Filter_tb
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


module DAPHNE_integrator_filter_fast_tb();
  reg   clk;
  reg   fclk;
  reg   reset;
  reg   enable;
  reg  signed [15:0] x;
  wire  signed [15:0] y;

  parameter CYCLE = 16.0;
  parameter HALF_CYCLE = 8.0;

  parameter FCYCLE = 16.0/7.0;
  parameter FHALF_CYCLE = 8.0/7.0;

  integer i,p;
  integer waveform_length;
  integer waveform_number;
  integer increment;
  integer f;

  reg signed [15:0] waveforms [(10000*1024 -1) : 0];

  filtroIIR_integrator_fast filtro(
		.clk(clk),
		.fclk(fclk),
		.reset(reset),
		.enable(enable),
		.x(x),
		.y(y)
	);

	always begin
		clk = 1; #(HALF_CYCLE);
		clk = 0; #(HALF_CYCLE);
	end

  always @(posedge clk, negedge clk) begin

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);

    fclk = 0; #(FHALF_CYCLE);
    fclk = 1; #(FHALF_CYCLE);
  end

    initial begin

		$dumpfile("filtroIIR_integrator.vcd");
		$dumpvars(0,filtro);
    $display("reading data ...");
		$readmemb("C:\\Users\\e_cri\\OneDrive\\Documents\\PhD\\Investigacion\\Electronica\\DAPHNE test\\test_coldamp\\test_01072022\\1st_run\\fbk_31_6_vgain_089_fpgafilter_off\\fbk_31_6_vgain_089_fpgafilter_off_binary.dat",waveforms);
    $display("finished reading data ...\n Starting simulation ...");
		f = $fopen("C:\\Users\\e_cri\\OneDrive\\Documents\\PhD\\Investigacion\\Electronica\\DAPHNE test\\test_coldamp\\test_01072022\\1st_run\\fbk_31_6_vgain_089_fpgafilter_off\\fbk_31_6_vgain_089_fpgafilter_off_behavioral_filtered_fast.dat","w");
		waveform_length = 1024;
		waveform_number = 3;
		increment = 0;

		x <= 0;
    reset <= 1;enable <=0; #(10*CYCLE);
		enable <= 0; reset <=0; #(10*CYCLE);
		enable <= 1;  #(CYCLE);

    for(i = 0; i<waveform_number; i = i+1) begin
        $display("waveform number: %d",i);
        for(p = 0; p < waveform_length; p = p + 1) begin
            x <= waveforms[increment];
            increment = increment + 1;
            #(CYCLE);
            $fwrite(f,"%d\n",y);
        end
    reset <= 1;enable <=0; #(5*CYCLE);
    enable <= 0; reset <=0; #(5*CYCLE);
    enable <= 1; #(CYCLE);
    end

		$fclose(f);
		$finish;
	end
endmodule