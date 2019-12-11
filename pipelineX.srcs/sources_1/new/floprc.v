`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2019 07:52:28 PM
// Design Name: 
// Module Name: floprc
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


module floprc #(parameter N=32) (
	input clk, reset, clear,
	input [N-1:0] dataIn,
	output reg [N-1:0] dataOut
    );
    always @(posedge clk) begin
    	if (reset == 1) begin
    		dataOut <= 0; 
    	end else if (clear != 1) begin
    		dataOut <= dataIn;
    	end else begin
    		dataOut <= 0;
    	end
    end
endmodule
