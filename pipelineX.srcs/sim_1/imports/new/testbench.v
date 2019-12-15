`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:54:42
// Design Name: 
// Module Name: testbench
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


module testbench();
	reg CLK;
	reg RST;

//	wire[31:0] writedata,dataadr;
//	wire[4:0] memwrite;
//	wire[5:0] int_i;
//	wire timer_int_o;
//	assign int_i = 6'b000000;

	soc_lite_top dut(RST, CLK);

	initial begin
		RST <= 1;
		#200;
		RST <= 0;
	end

	always begin
		CLK <= 1;
		#10;
		CLK <= 0;
		#10;
	
	end

//	always @(negedge CLK) begin
//		if(memwrite) begin
//			/* code */
//			if(dataadr === 84 & writedata === 7) begin
//				/* code */
//				$display("Simulation succeeded");
//				$stop;
//			end else if(dataadr !== 80) begin
//				/* code */
//				$display("Simulation Failed");
//				$stop;
//			end
//		end
//	end
endmodule
