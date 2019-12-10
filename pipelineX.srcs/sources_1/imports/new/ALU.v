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
    input wire [31:0] hi, lo,
    input wire [7:0] aluop,
    input wire [4:0] sa,
    output reg [31:0] result,
    output reg [31:0] hi_o, lo_o
    );
    always @(*) begin
        case(aluop)
        	`EXE_AND_OP,
			`EXE_ANDI_OP:	result	<=	a & b;
        	`EXE_LUI_OP:	result	<=	(b << 16);
        	`EXE_NOR_OP:	result	<=	~ (a | b);
			`EXE_OR_OP,
			`EXE_ORI_OP:	result	<=	a | b;
			`EXE_XOR_OP,
			`EXE_XORI_OP:	result	<=	a ^ b;
			`EXE_SLLV_OP:	result	<=	b << a[4:0];
			`EXE_SRLV_OP:	result	<=	b >> a[4:0];
			`EXE_SRAV_OP:	result	<=	({32{b[31]}} << (6'd32-{1'b0, a[4:0]})) | b >> a[4:0];
			`EXE_SLL_OP:	result	<= 	b << sa;
			`EXE_SRL_OP:	result	<=	b >> sa;
			`EXE_SRA_OP:	result	<=	({32{b[31]}} << (6'd32 - {1'b0, sa})) | b >> sa;
			`EXE_SYNC_OP:	result	<=	0;
			`EXE_MFHI_OP:	result	<=	hi;
			`EXE_MFLO_OP:	result	<=	lo;
			`EXE_MTHI_OP: 	begin
				hi_o	<=	a;
				lo_o	<=	lo;
			end
			`EXE_MTLO_OP:begin
				hi_o	<= hi;
				lo_o	<= a;
			end
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
			
			`EXE_SLLV_OP:	$display("[ALU] Hit SLLV");
			`EXE_SRLV_OP:	$display("[ALU] Hit SRLV");
			`EXE_SRAV_OP:	$display("[ALU] Hit SRAV");
			`EXE_SLL_OP:	$display("[ALU] Hit SLL");
			`EXE_SRL_OP:	$display("[ALU] Hit SRL");
			`EXE_SRA_OP:	$display("[ALU] Hit SRA");
			
			`EXE_SYNC_OP:	$display("[ALU] Hit SYNC");	
			
			`EXE_MFHI_OP:	$display("[ALU] Hit MFHI");
			`EXE_MFLO_OP:	$display("[ALU] Hit MFLO");
			`EXE_MTHI_OP:	$display("[ALU] Hit MTHI");
			`EXE_MTLO_OP:	$display("[ALU] Hit MTLO");
			default: begin
				$display("[ALU] op = %2d", aluop);
//				$stop;
			end
        endcase
    end   
endmodule
