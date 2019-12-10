`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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

module controller(
	input wire clk, rst,
	//decode stage
	input wire [5:0] opD, functD,
//	input wire [4:0] rt,
	input wire equalD,
	output wire pcsrcD, branchD, jumpD,
	
	//execute stage
	input wire flushE,
	output wire memtoregE, alusrcE,
	output wire regdstE, regwriteE,	
	output wire [7:0] alucontrolE,

	//mem stage
	output wire memtoregM, memwriteM, regwriteM,
	//write back stage
	output wire memtoregW, regwriteW

    );
	//decode stage
	wire [1:0] aluopD;
	wire memtoregD, memwriteD, alusrcD, regdstD, regwriteD;
	wire [7:0] alucontrolD;

	//execute stage
	wire memwriteE;
	wire [4:0] rt;
	wire memen, jr, jal, bal;
	maindec md(
    	opD, functD, rt,
		memtoregD, memen, memwriteD,
		branchD, alusrcD,
		regdstD, regwriteD,
		jumpD, jal, jr, bal
	);
	aludec ad(opD,functD,alucontrolD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	floprc #(13) regE(
		clk, rst, flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
	);
	flopr #(3) regM(
		clk, rst,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
	);
	flopr #(2) regW(
		clk, rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
	);
endmodule

module aludec (
	input [5:0] op, funct,
	output reg [7:0] alucontrol
	);
	always @ (*)
		if (op != 0)
			case (op) 
				`EXE_ADDI:		alucontrol	<=	`EXE_ADDI_OP;
				`EXE_ADDU:		alucontrol	<=	`EXE_ADDU_OP;
				`EXE_ANDI:		alucontrol	<=	`EXE_ANDI_OP;
				`EXE_BEQ:		alucontrol	<=	`EXE_BEQ_OP;
				`EXE_BGEZ:		alucontrol	<=	`EXE_BGEZ_OP;
				`EXE_BGEZAL:	alucontrol	<=	`EXE_BGEZAL_OP;
				`EXE_BGTZ:		alucontrol	<=	`EXE_BGTZ_OP;
				`EXE_BLEZ:		alucontrol	<=	`EXE_BLEZ_OP;
				`EXE_BLTZ:		alucontrol	<=	`EXE_BLTZ_OP;
				`EXE_BLTZAL:	alucontrol	<=	`EXE_BLTZAL_OP;
				`EXE_BNE:		alucontrol	<=	`EXE_BNE_OP;
				`EXE_J:			alucontrol	<=	`EXE_J_OP;
				`EXE_JAL:		alucontrol	<=	`EXE_JAL_OP;
				`EXE_LB:		alucontrol	<=	`EXE_LB_OP;
				`EXE_LBU:		alucontrol	<=	`EXE_LBU_OP;
				`EXE_LH:		alucontrol	<=	`EXE_LH_OP;
				`EXE_LHU:		alucontrol	<=	`EXE_LHU_OP;
				`EXE_LL:		alucontrol	<=	`EXE_LL_OP;
				`EXE_LUI:		alucontrol	<=	`EXE_LUI_OP;
				`EXE_LW:		alucontrol	<=	`EXE_LW_OP;
				`EXE_LWL:		alucontrol	<=	`EXE_LWL_OP;
				`EXE_LWR:		alucontrol	<=	`EXE_LWR_OP;
				`EXE_ORI:		alucontrol	<=	`EXE_ORI_OP;
				`EXE_PREF:		alucontrol	<=	`EXE_PREF_OP;
				`EXE_SB:		alucontrol	<=	`EXE_SB_OP;
				`EXE_SC:		alucontrol	<=	`EXE_SC_OP;
				`EXE_SH:		alucontrol	<=	`EXE_SH_OP;
				`EXE_SLTI:		alucontrol	<=	`EXE_SLTI_OP;
				`EXE_SLTIU:		alucontrol	<=	`EXE_SLTIU_OP;
				`EXE_SW:		alucontrol	<=	`EXE_SW_OP;
				`EXE_SWL:		alucontrol	<=	`EXE_SWL_OP;
				`EXE_SWR:		alucontrol	<=	`EXE_SWR_OP;
				`EXE_XORI:		alucontrol	<=	`EXE_XORI_OP;
				default: begin
					$display("[ALUDEC] op = %2d", op);
					$stop;
				end
			endcase
		else
			case(funct) // RTYPE
				`EXE_AND:		alucontrol	<=	`EXE_AND_OP;
				`EXE_NOR:		alucontrol	<=	`EXE_NOR_OP;
				`EXE_OR:		alucontrol	<=	`EXE_OR_OP;
				`EXE_XOR:		alucontrol	<=	`EXE_XOR_OP;
				`EXE_SLL:		alucontrol	<=	`EXE_SLL_OP;
				`EXE_SLLV:		alucontrol	<=	`EXE_SLLV_OP;
				`EXE_SRA:		alucontrol	<=	`EXE_SRA_OP;
				`EXE_SRAV:		alucontrol	<=	`EXE_SRAV_OP;
				`EXE_SRL:		alucontrol	<=	`EXE_SRL_OP;
				`EXE_SRLV:		alucontrol	<=	`EXE_SRLV_OP;
				`EXE_MFHI:		alucontrol	<=	`EXE_MFHI_OP;
				`EXE_MFLO:		alucontrol	<=	`EXE_MFLO_OP;
				`EXE_MTHI:		alucontrol	<=	`EXE_MTHI_OP;
				`EXE_MTLO:		alucontrol	<=	`EXE_MTLO_OP;
				`EXE_MFHI:		alucontrol	<=	`EXE_MFHI_OP;
				`EXE_MFLO:		alucontrol	<=	`EXE_MFLO_OP;
				`EXE_MTHI:		alucontrol	<=	`EXE_MTHI_OP;
				`EXE_MTLO:		alucontrol	<=	`EXE_MTLO_OP;
				`EXE_JALR:		alucontrol	<=	`EXE_JALR_OP;
				`EXE_JR:		alucontrol	<=	`EXE_JR_OP;
				`EXE_SYNC:		alucontrol	<=	`EXE_SYNC_OP;				
				default: begin
					$display("[ALUDEC] funct = %2d", funct);
//                	$stop;
				end
			endcase
endmodule


module maindec(
    input [5:0] op, funct,
    input [4:0] rt,
	output memtoreg, memen, memwrite,
	output branch, alusrc,
	output regdst, regwrite,
	output jump, jal, jr, bal
    );
    reg [10:0] controls;
    assign {memtoreg, memen, memwrite, branch, alusrc, regdst, regwrite, jump, jal, jr, bal} = controls;
    always @ (*)
    	if (op != 0)
			case (op)
				`EXE_ORI, `EXE_LUI, `EXE_ANDI, `EXE_XORI:
					controls <= `LOGIC_IMME_CTRL;

				default: begin
					$display("[MAINDEC] OP = %2d", op);
//					$stop;
				end
			endcase
		else
			case (funct)
				`EXE_OR, `EXE_AND, `EXE_XOR, `EXE_NOR:
					controls <= `LOGIC_R_CTRL;
				`EXE_SLL, `EXE_SRL, `EXE_SRA, `EXE_SLLV, `EXE_SRLV, `EXE_SRAV:
					controls <= `SHIFT_CTRL;
				`EXE_SYNC:
					controls <= `SYNC_CTRL;
				default: begin
					$display("[MAINDEC] funct = %2d", funct);
//					$stop;
				end
			endcase 
//		controls <= `ARITH_R_CTRL;
				
endmodule