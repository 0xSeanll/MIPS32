`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 06:06:19 PM
// Design Name: 
// Module Name: ALU
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

module ALU(
    input wire [31:0] a, b,
    input wire [7:0] aluop,
    input wire [4:0] sa,
    output reg [31:0] result
    );
    always @(*) begin
        case(aluop)
        	`EXE_AND_OP:	result	<=	a & b;
			`EXE_ANDI_OP:	result	<=	a & b;
        	`EXE_LUI_OP:	result	<=	(b << 16);
        	`EXE_NOR_OP:	result	<=	~ (a | b);
			`EXE_OR_OP:		result	<=	a | b;
			`EXE_ORI_OP:	result	<=	a | b;
			`EXE_XOR_OP:	result	<=	a ^ b;
			`EXE_XORI_OP:	result	<=	a ^ b;
			default: begin
				$display("[ALU] op = %2d", aluop);
//				$stop;
			end
        endcase
    end
    
    
    // DEBUGGER
    always @(*) begin
        case(aluop)
			`EXE_AND_OP:	$display("[ALU] Hit AND");
			`EXE_ANDI_OP:	$display("[ALU] Hit ANDI");
			`EXE_LUI_OP:	$display("[ALU] Hit LUI");
			`EXE_NOR_OP:	$display("[ALU] Hit NOR");
			`EXE_OR_OP:		$display("[ALU] Hit OR");
			`EXE_ORI_OP:	$display("[ALU] Hit ORI");
			`EXE_XOR_OP:	$display("[ALU] Hit XOR");
			`EXE_XORI_OP:	$display("[ALU] Hit XORI");
			default: begin
				$display("[ALU] op = %2d", aluop);
//				$stop;
			end
        endcase
    end   
endmodule
