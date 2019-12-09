`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 01:48:45 PM
// Design Name: 
// Module Name: mux2
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


module mux2 #(parameter N=32) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire s,
    output reg [N-1:0] y
    );
    always @(*) begin
    	if (s !== 1) y <= a;
    	else y <= b;
    end
endmodule


