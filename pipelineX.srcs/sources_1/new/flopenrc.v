`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2019 07:31:40 PM
// Design Name: 
// Module Name: flopenrc
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


module flopenrc #(parameter N=32) (
    input wire clk, rst,
    input wire ena, clear,
    input wire [N-1:0] dataIn,
    output reg [N-1:0] dataOut
    );
    always @(posedge clk) begin
    	if (rst == 1) dataOut <= 0;
		else if (clear != 1) begin 
			if (ena != 0) dataOut <= dataIn;
		end else dataOut <= 0;
    end
endmodule

