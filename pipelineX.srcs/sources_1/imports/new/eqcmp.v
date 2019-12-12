`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2019 03:15:24 AM
// Design Name: 
// Module Name: eqcmp
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

`include "defines.vh"
module comparator (
	input wire [31:0] a, b,
	input wire [7:0] aluop,
	input wire [4:0] rt,
	output reg y
    );
    always @(*) begin
    	case (aluop)
    		`EXE_BEQ:	y <= (a == b);
   			`EXE_BGTZ:	y <= (a != `ZeroWord && a[31] == 1'b0);
   			`EXE_BLEZ:	y <= (a == `ZeroWord || a[31] == 1'b1);
   			`EXE_BNE: 	y <= (a != b);
//   			`EXE_BLTZ:	y <= (a[31] == 1'b1);
//   			`EXE_BGEZ:	y <= (a[31] == 1'b0);
   			default: begin
   				$display("[CMP] Unknown aluop %5d", aluop);
   				y <= 0;
//   				$stop;
   			end
    	endcase
    end
//    assign y =	(aluop == `EXE_BEQ)  ? (a == b) :
//    			(aluop == `EXE_BGTZ) ? (a != `ZeroWord && a[31] == 1'b0) :
//    			(aluop == `EXE_BLEZ) ? (a == `ZeroWord || a[31] == 1'b1) :
//    			(aluop == `EXE_BNE)  ? (a != b) :
//    			(aluop == `EXE_BLTZ) ? (a[31] == 1'b1) :
//    			(aluop == `EXE_BGEZ) ? (a[31] == 1'b0);
//    always @(*) begin
//    	if (a == b) y <= 1;
//    	else y <= 0;
//    end
endmodule
