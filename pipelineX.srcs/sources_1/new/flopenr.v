`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2019 07:21:42 PM
// Design Name: 
// Module Name: flopenr
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


module flopenr #(parameter N=32) (
    input clk, reset, ena,
    input [N-1:0] d,
    output reg [N-1:0] q
    );
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else if (ena != 0) begin
            q <= d;
        end
    end
endmodule
