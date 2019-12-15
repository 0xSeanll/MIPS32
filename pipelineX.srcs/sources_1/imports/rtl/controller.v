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

/*
Except Type Table
0~7 bit: software interruption
8 bit: syscall
9 bit: invalid instruction
10 bit: break
12 bit: eret  
*/

`include "defines.vh"

module controller(
	input wire CLK, RST,
	//decode stage
	input wire [5:0] inst_op_D, inst_funct_D,
	input wire [4:0] rsD,
	input wire [4:0] rtD,
//	input wire equal_D,
	output wire [1:0] pcsrcD,
	output wire branchD, jumpD,
	output wire jrD,
//	output wire [7:0] ALUControl_D,
	input wire [31:0] srca2D, srcb2D,	
	//execute stage
	input wire flush_E,stall_E,
	output wire jal_E,
	output wire memToReg_E,
	output wire ALUSrc_E,
	output wire regDst_E, regWrite_E,
	output wire [7:0] ALUctrl_E,
	output wire [31:0] exceptType_E,
	input wire stopRegWrite,
	input wire stopMemWrite,
	//mem stage
	input wire flush_M,
	output wire memEn_M,
	output wire memToReg_M, regWrite_M, writeHiLo_M,
	output wire [7:0] ALUControl_M,
	output wire isInDelayslot_M,
	//write back stage
	input wire flush_W,
	output wire memToReg_W, regWrite_W, writeHiLo_W,
    
    output wire fromCP0, writeCP0_M, writeCP0_W
    );
    wire regWrite_E_final;
    wire memEn_E_final;
	//decode stage
	wire memToReg_D, regdstD, regWrite_D_tmp;
	wire writehiloD, writehiloE;
	wire ALUSrc_D;
	wire [7:0] ALUControl_D;
	//execute stage
	wire jal_D;
	wire regWrite_B;
	wire regWrite_D_final;
	wire equal_D;
	wire memEn_D, memEn_E, bal;
	wire writeCP0_D, writeCP0_E;
	wire next_inst_in_delayslot_D, next_inst_in_delayslot_E;
	wire isInDelayslot_D, isInDelayslot_E;
	wire [31:0] exceptType_D;
	maindec md(
    	inst_op_D, inst_funct_D, rsD, rtD,
		memToReg_D, memEn_D,
		branchD, ALUSrc_D,
		regdstD, regWrite_D_tmp, writehiloD,
		jumpD, jal_D, jrD, bal,
		writeCP0_D, fromCP0,
		exceptType_D
	);
	aludec ad(inst_op_D,inst_funct_D,rsD,rtD,ALUControl_D);

	comparator CMP(srca2D,srcb2D,ALUControl_D,rtD,equal_D,regWrite_B);
	mux2 #(1) regWriteMux(regWrite_D_tmp, regWrite_B, bal, regWrite_D_final);
	 
	assign pcsrcD = {jumpD, branchD & equal_D};
	assign next_inst_in_delayslot_D = |pcsrcD;
	flopenrc #(1)  next_dsE(
		CLK, RST, ~stall_E, flush_E,
		next_inst_in_delayslot_D,
		next_inst_in_delayslot_E
	);
	flopenrc #(1)  dsE(
		CLK, RST, ~stall_E, flush_E,
		isInDelayslot_D,
		isInDelayslot_E
	);
	flopenrc #(32) exceptE(
		CLK, RST, ~stall_E, flush_E,
		exceptType_D,
		exceptType_E
	);
	assign isInDelayslot_D = next_inst_in_delayslot_E;
	flopenrc #(16) regE(
		CLK, RST, ~stall_E, flush_E,
		{memToReg_D,memEn_D,ALUSrc_D,regdstD,regWrite_D_final,writehiloD,jal_D,ALUControl_D,writeCP0_D},
		{memToReg_E,memEn_E,ALUSrc_E,regDst_E,regWrite_E,writehiloE ,jal_E,ALUctrl_E,writeCP0_E}
	);
	floprc #(1) dsM (
		CLK, RST, flush_M,
		isInDelayslot_E,
		isInDelayslot_M
	);
	mux2 #(1) stp1(regWrite_E, 1'b0, stopRegWrite, regWrite_E_final);
	mux2 #(1) stp2(memEn_E, 1'b0, stopMemWrite, memEn_E_final);
	floprc #(13) regM(
		CLK, RST, flush_M,
		{memToReg_E,memEn_E_final,regWrite_E_final,writehiloE,ALUctrl_E,writeCP0_E},
		{memToReg_M,memEn_M,regWrite_M,writeHiLo_M,ALUControl_M,writeCP0_M}
	);
	floprc #(4) regW(
		CLK, RST, flush_W,
		{memToReg_M,regWrite_M,writeHiLo_M,writeCP0_M},
		{memToReg_W,regWrite_W,writeHiLo_W,writeCP0_W}
	);
endmodule

module aludec (
	input [5:0] op, funct,
	input [4:0] rs,
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
				`CPO_COP0:begin
				    case(rs)
				        `CP0_MT:
				            alucontrol <= `EXE_MTC0_OP;
				        `CP0_MF:
				            alucontrol <= `EXE_MFC0_OP;
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
    input [4:0] rs,
    input [4:0] rt,
	output memtoreg, memen,
	output branch,
	output alusrc,
	output regdst, regwrite, writehilo,
	output jump, jal, jr, bal,
	output cp0write, fromCP0,
	output [31:0] exceptType
    );
    reg [12:0] controls;
    assign {memtoreg, memen, branch, alusrc, regdst, regwrite, writehilo, jump, jal, jr, bal, cp0write, fromCP0} = controls;
    reg excepttype_is_syscall, excepttype_is_eret, excepttype_is_break;
    reg invalid_inst;
    assign exceptType = {
    	19'b0,						// [31:13]
    	excepttype_is_eret,			// [12]
    	1'b0,						// [11]
    	excepttype_is_break,		// [10]
    	invalid_inst,				// [9]
    	excepttype_is_syscall,		// [8]
    	8'b00000000					// [7:0]
    };
    always @ (*) begin
    	excepttype_is_syscall = `False_v;
    	excepttype_is_eret = `False_v;
    	excepttype_is_break = `False_v;
    	invalid_inst = `False_v;
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
				`EXE_SB, `EXE_SH, `EXE_SW:
					controls <= `SAVE_CTRL;
				`EXE_LB, `EXE_LBU, `EXE_LH, `EXE_LHU, `EXE_LW:
					controls <= `LOAD_CTRL;
				`EXE_REGIMM_INST: begin
					case (rt)
						`EXE_BLTZ, `EXE_BGEZ:
							controls <= `BRANCH_CTRL;
						`EXE_BLTZAL, `EXE_BGEZAL:
							controls <= `BAL_CTRL;
						default:
				        	invalid_inst <= `True_v;
					endcase
				end
				`CPO_COP0: begin
				    case(rs)
				        `CP0_MT:
				            controls <= `CP0_MT_CTRL;
				        `CP0_MF:
				            controls <= `CP0_MF_CTRL;
				        `EXE_ERET:
				        	excepttype_is_eret <= `True_v;
				        default:
				        	invalid_inst <= `True_v;
				    endcase 
				end    
				default: begin
					invalid_inst <= `True_v;
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
				`EXE_BREAK:
					excepttype_is_break <= `True_v;
				`EXE_SYSCALL:
					excepttype_is_syscall <= `True_v;
				default: begin
					invalid_inst <= `True_v;
				end
			endcase 
	end
	
endmodule