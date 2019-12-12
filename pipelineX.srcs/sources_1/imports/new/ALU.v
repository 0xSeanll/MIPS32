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
    input wire clk, rst,
    input wire [31:0] a, b,
    input wire [31:0] hi, lo,
    input wire [7:0] aluop,
    input wire [4:0] sa,
    input wire [31:0] pcplus4,
    output reg [31:0] result,
    output reg [31:0] hi_o, lo_o,
    output reg stall_div
    );
    reg [63:0] tmp;
    reg [31:0] mult_a, mult_b;
    reg start_i, signed_div_i;
    wire ready_o;
    wire [31:0] rst_hi, rst_lo;
    wire annul_i;
    assign annul_i = 0;
    div my_div(clk, rst, signed_div_i, a, b, start_i, annul_i, {rst_hi, rst_lo}, ready_o);
    always @(posedge clk) begin
        if (rst) begin
            stall_div <= 0;
        end
    end
    always @(posedge ready_o) begin
        hi_o <= rst_hi;
        lo_o <= rst_lo;
        stall_div <= 0;
        start_i <= 0;
    end
    always @(*) begin
        case(aluop)
        	`EXE_JAL_OP,
        	`EXE_JALR_OP,
        	`EXE_BGEZAL_OP,
        	`EXE_BLTZAL_OP:	result	<= pcplus4 + 32'd4; 
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
			`EXE_SB_OP,
			`EXE_SH_OP,
			`EXE_SW_OP,
			`EXE_LB_OP,
			`EXE_LBU_OP,
			`EXE_LH_OP,
			`EXE_LHU_OP,
			`EXE_LW_OP:		result	<= a + b;
			`EXE_MTHI_OP: 	begin
				hi_o	<=	a;
				lo_o	<=	lo;
			end
			`EXE_MTLO_OP:	begin
				hi_o	<= hi;
				lo_o	<= a;
			end
			`EXE_ADD_OP,
			`EXE_ADDI_OP:	begin
				tmp = a + b;
				result <= (tmp[32] == 1'b1) ? 0 : tmp;
			end
			`EXE_ADDU_OP,
			`EXE_ADDIU_OP:	result	<=	a + b;
			`EXE_SUB_OP,
			`EXE_SUBU_OP:	result	<=	a - b;
			`EXE_SLT_OP,
			`EXE_SLTI_OP:	begin
				tmp = a - b;
				result <= tmp[31];
			end
			`EXE_SLTU_OP,
			`EXE_SLTIU_OP:	result	<=	(a < b ? 1 : 0);
			`EXE_MULT_OP:	begin
				mult_a = (a[31] == 1'b1) ? (~a + 1) : a;
				mult_b = (b[31] == 1'b1) ? (~b + 1) : b;
				tmp = (a[31] ^ b[31] == 1'b1) ?  ~(mult_a * mult_b) + 1 : mult_a * mult_b;
				hi_o <= tmp[63:32];
				lo_o <= tmp[31:0];
			end
			`EXE_MULTU_OP:	begin
				tmp = a * b;
				hi_o <= tmp[63:32];
				lo_o <= tmp[31:0];
			end
			`EXE_DIV_OP: begin
			     start_i <= 1;
			     stall_div <= 1;
			     signed_div_i <= 1;
			end
			`EXE_DIVU_OP: begin
			     start_i <= 1;
			     stall_div <= 1;
			     signed_div_i <= 0;
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
			
			`EXE_ADD_OP:	$display("[ALU] Hit ADD");
			`EXE_ADDI_OP:	$display("[ALU] Hit ADDI");
			`EXE_ADDU_OP:	$display("[ALU] Hit ADDU");
			`EXE_ADDIU_OP:	$display("[ALU] Hit ADDIU");
			`EXE_SUB_OP:	$display("[ALU] Hit SUB");
			`EXE_SUBU_OP:	$display("[ALU] Hit SUBU");
			`EXE_SLT_OP:	$display("[ALU] Hit SLT");
			`EXE_SLTI_OP:	$display("[ALU] Hit SLTI");
			`EXE_SLTU_OP:	$display("[ALU] Hit SLTU");
			`EXE_SLTIU_OP:	$display("[ALU] Hit SLTIU");
			`EXE_MULT_OP:	$display("[ALU] Hit MULT");
			`EXE_MULTU_OP:	$display("[ALU] Hit MULTU");
			default: begin
				$display("[ALU] op = %2d", aluop);
//				$stop;
			end
        endcase
    end   
endmodule
