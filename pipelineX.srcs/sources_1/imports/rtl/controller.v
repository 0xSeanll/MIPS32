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
	input wire [4:0] rtD,
//	input wire equalD,
	output wire pcsrcD, branchD, jumpD,
	output wire jalE, jr, bal,
	output wire memen,
//	output wire [7:0] alucontrolD,
	input wire [31:0] srca2D, srcb2D,	
	//execute stage
	input wire flushE,stallE,
	output wire memtoregE,
	output wire alusrcE,
	output wire regdstE, regwriteE,
	output wire [7:0] alucontrolE,

	//mem stage
	output wire memtoregM, memwriteM, regwriteM, writehiloM,
	//write back stage
	output wire memtoregW, regwriteW, writehiloW

    );
	//decode stage
	wire memtoregD, memwriteD, regdstD, regwriteD;
	wire writehiloD, writehiloE;
	wire alusrcD;
	wire [7:0] alucontrolD;
	//execute stage
	wire memwriteE;
	wire jalD;
	wire regwriteB;
	wire regwrite2D;
	wire equalD;
	maindec md(
    	opD, functD, rtD,
		memtoregD, memen, memwriteD,
		branchD, alusrcD,
		regdstD, regwriteD, writehiloD,
		jumpD, jalD, jr, bal
	);
	aludec ad(opD,functD,rtD,alucontrolD);

	comparator CMP(srca2D,srcb2D,alucontrolD,rtD,equalD,regwriteB);
	mux2 #(1) regWriteMux(regwriteD, regwriteB, bal, regwrite2D);
	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(15) regE(
		clk, rst, ~stallE, flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwrite2D,writehiloD,jalD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,writehiloE,jalE,alucontrolE}
	);
	flopr #(4) regM(
		clk, rst,
		{memtoregE,memwriteE,regwriteE,writehiloE},
		{memtoregM,memwriteM,regwriteM,writehiloM}
	);
	flopr #(3) regW(
		clk, rst,
		{memtoregM,regwriteM,writehiloM},
		{memtoregW,regwriteW,writehiloW}
	);
endmodule

module aludec (
	input [5:0] op, funct,
	input [4:0] rt,
	output reg [7:0] alucontrol
	);
	always @ (*)
		if (op != 0)
			case (op) 
				`EXE_ADDI:		alucontrol	<=	`EXE_ADDI_OP;
				`EXE_ADDIU:		alucontrol	<=	`EXE_ADDIU_OP;
				`EXE_ANDI:		alucontrol	<=	`EXE_ANDI_OP;
				`EXE_BEQ:		alucontrol	<=	`EXE_BEQ_OP;
				`EXE_BGTZ:		alucontrol	<=	`EXE_BGTZ_OP;
				`EXE_BLEZ:		alucontrol	<=	`EXE_BLEZ_OP;
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
				`EXE_REGIMM_INST: begin
					case (rt)
						`EXE_BLTZ:		alucontrol	<=	`EXE_BLTZ_OP;
						`EXE_BLTZAL:	alucontrol	<=	`EXE_BLTZAL_OP;
						`EXE_BGEZ:		alucontrol	<=	`EXE_BGEZ_OP;
						`EXE_BGEZAL:	alucontrol	<=	`EXE_BGEZAL_OP;
					endcase
				end
				default: begin
					$display("[ALUDEC] op = %2d", op);
					$stop;
				end
			endcase
		else
			case(funct) // RTYPE
				`EXE_JR:		alucontrol	<=	`EXE_JR_OP;
				`EXE_JALR:		alucontrol	<=	`EXE_JALR_OP;
				`EXE_SLT:		alucontrol	<=	`EXE_SLT_OP;
				`EXE_SLTU:		alucontrol	<=	`EXE_SLTU_OP;
				`EXE_ADD:		alucontrol	<=	`EXE_ADD_OP;
				`EXE_ADDU:		alucontrol	<=	`EXE_ADDU_OP;
				`EXE_SUB:		alucontrol	<=	`EXE_SUB_OP;
				`EXE_SUBU:		alucontrol	<=	`EXE_SUBU_OP;
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
				`EXE_JALR:		alucontrol	<=	`EXE_JALR_OP;
				`EXE_JR:		alucontrol	<=	`EXE_JR_OP;
				`EXE_SYNC:		alucontrol	<=	`EXE_SYNC_OP;
				`EXE_MULT:		alucontrol	<=	`EXE_MULT_OP;
				`EXE_MULTU:		alucontrol	<=	`EXE_MULTU_OP;
				`EXE_DIV:       alucontrol  <=  `EXE_DIV_OP;
				`EXE_DIVU:      alucontrol  <=  `EXE_DIVU_OP;
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
	output branch,
	output alusrc,
	output regdst, regwrite, writehilo,
	output jump, jal, jr, bal
    );
    reg [11:0] controls;
    assign {memtoreg, memen, memwrite, branch, alusrc, regdst, regwrite, writehilo, jump, jal, jr, bal} = controls;
    always @ (*)
    	if (op != 0)
			case (op)
				`EXE_ADDI, `EXE_ADDIU, `EXE_SLTI, `EXE_SLTIU:
					controls <= `ARITH_IMME_CTRL;
				`EXE_ORI, `EXE_LUI, `EXE_ANDI, `EXE_XORI:
					controls <= `LOGIC_IMME_CTRL;
				`EXE_J:
					controls <= `EXE_J_CTRL;
				`EXE_JAL:
					controls <= `EXE_JAL_CTRL;
				`EXE_BEQ, `EXE_BGTZ, `EXE_BLEZ, `EXE_BNE:
					controls <= `BRANCH_CTRL;
				`EXE_REGIMM_INST: begin
					case (rt)
						`EXE_BLTZ, `EXE_BGEZ:
							controls <= `BRANCH_CTRL;
						`EXE_BLTZAL, `EXE_BGEZAL:
							controls <= `BAL_CTRL;
					endcase
				end
				default: begin
					$display("[MAINDEC] OP = %2d", op);
					$stop;
				end
			endcase
		else
			case (funct)
				`EXE_ADD, `EXE_ADDU, `EXE_SUB, `EXE_SUBU, `EXE_SLT, `EXE_SLTU:
					controls <= `ARITH_R_CTRL;
				`EXE_OR, `EXE_AND, `EXE_XOR, `EXE_NOR:
					controls <= `LOGIC_R_CTRL;
				`EXE_SLL, `EXE_SRL, `EXE_SRA, `EXE_SLLV, `EXE_SRLV, `EXE_SRAV:
					controls <= `SHIFT_CTRL;
				`EXE_SYNC:
					controls <= `SYNC_CTRL;
				`EXE_MTHI, `EXE_MTLO:
					controls <= `MT_CTRL;
				`EXE_MFHI, `EXE_MFLO:
					controls <= `MF_CTRL;
				`EXE_MULT, `EXE_MULTU:
					controls <= `MULT_CTRL;
				`EXE_DIV, `EXE_DIVU:
				    controls <= `DIV_CTRL;
				`EXE_JR:
					controls <= `EXE_JR_CTRL;
				`EXE_JALR:
					controls <= `EXE_JALR_CTRL;
				default: begin
					$display("[MAINDEC] funct = %2d", funct);
//					$stop;
				end
			endcase 
//		controls <= `ARITH_R_CTRL;
				
endmodule