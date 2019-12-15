`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2019 01:16:30 AM
// Design Name: 
// Module Name: PC
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


module PC(
    input wire CLK, RST,
    input wire ena, clear,
    input wire [31:0] PCExc,
    input wire [31:0] PCIn,
    output reg [31:0] PCOut
    );
    always @(posedge CLK) begin
    	if (RST == 1) PCOut <= 0;
		else if (clear != 1) begin 
			if (ena != 0) PCOut <= PCIn;
		end else PCOut <= PCExc;
    end
endmodule


//module flopenrc #(parameter N=32) (
//    input wire CLK, RST,
//    input wire ena, clear,
//    input wire [N-1:0] dataIn,
//    output reg [N-1:0] dataOut
//    );
//    always @(posedge CLK) begin
//    	if (RST == 1) dataOut <= 0;
//		else if (clear != 1) begin 
//			if (ena != 0) dataOut <= dataIn;
//		end else dataOut <= 0;
//    end
//endmodule

