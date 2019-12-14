`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 02:54:13 PM
// Design Name: 
// Module Name: Register
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


module Register (
	input wire clk,
	input wire RegWrite,
	input wire [4:0] Rs, Rt, Rd,
	input wire [31:0] WriteData,
	output wire [31:0] RD1, RD2
//	output reg [31:0] RD1, RD2
    );
	reg [31:0] rf [31:0];
	always @(negedge clk) begin
//		#0.5;
		if (RegWrite) rf[Rd] <= WriteData;
//		RD1 <= (Rs != 0) ? rf[Rs] : 0;
//		RD2 <= (Rt != 0) ? rf[Rt] : 0;
	end
	assign RD1 = (Rs != 0) ? rf[Rs] : 0;
	assign RD2 = (Rt != 0) ? rf[Rt] : 0;
endmodule
