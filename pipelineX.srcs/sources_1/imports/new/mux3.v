`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 01:49:45 PM
// Design Name: 
// Module Name: mux3
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


module mux3 #(parameter N=32) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire [N-1:0] c,
    input wire [1:0] s,
    output wire [N-1:0] y
    );
    assign y = (s == 0 ? a : (s == 1 ? b : c));
endmodule

