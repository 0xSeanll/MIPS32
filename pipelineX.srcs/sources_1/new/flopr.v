`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2019 08:01:29 PM
// Design Name: 
// Module Name: flopr
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


module flopr #(parameter N=32) (
	input CLK, RST,
	input [N-1:0] dataIn,
	output reg [N-1:0] dataOut
    );
    always @(posedge CLK) begin
    	if (RST != 1) begin 
    		dataOut <= dataIn;
    	end else begin
    		dataOut <= 0;
    	end
    end
endmodule
