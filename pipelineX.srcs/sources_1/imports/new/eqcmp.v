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
	output reg y, regWrite_B
    );
    always @(*) begin
    	case (aluop)
			`EXE_BEQ_OP:	begin
				y <= (a == b);
				regWrite_B <= 0;
			end
			`EXE_BGTZ_OP:	begin
				y <= (a != `ZeroWord && a[31] == 1'b0);
				regWrite_B <= 0;
			end
			`EXE_BLEZ_OP:	begin
				y <= (a == `ZeroWord || a[31] == 1'b1);
				regWrite_B <= 0;
			end
			`EXE_BNE_OP: 	begin
				y <= (a != b);
				regWrite_B <= 0;
			end
			`EXE_BLTZ_OP:	begin
				y <= (a[31] == 1'b1);
				regWrite_B <= 0;
			end
			`EXE_BGEZ_OP:	begin
				y <= (a[31] == 1'b0);
				regWrite_B <= 0;
			end
			`EXE_BGEZAL_OP:	begin
				y <= (a[31] == 1'b0);
				regWrite_B <= (a[31] == 1'b0);
			end
			`EXE_BLTZAL_OP:	begin
				y <= (a[31] == 1'b1);
				regWrite_B <= (a[31] == 1'b1);
			end
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
