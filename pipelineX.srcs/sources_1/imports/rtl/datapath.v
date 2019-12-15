`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
//flush_E, flush_M, flush_W
	input wire CLK, RST,
	//fetch stage
	output wire[31:0] inst_addr_F,
	input wire [31:0] inst_F,
	//decode stage
	input wire [1:0] pcsrcD,
	input wire branchD, jumpD,jrD,
//	output wire equal_D,
	output wire [5:0] inst_op_D,inst_funct_D,
	output wire [4:0] rsD,
	output wire [4:0] rtD,
//	output wire [7:0] ALUControl_D,
	output wire [31:0] srca2D, srcb2D,
	//execute stage
	input wire memToReg_E,
	input wire ALUSrc_E,
	input wire regDst_E,
	input wire regWrite_E,
	input wire[7:0] ALUctrl_E,
	output wire flush_E, stall_E,
	input wire jal_E,
	input wire [31:0] exceptType_iE,
	output wire stopRegWrite,
	output wire stopMemWrite,
	//mem stage
	output wire flush_M,
	input wire memToReg_M,
	input wire regWrite_M, writeHiLo_M,
	output wire[31:0] ALUOut_M,writeData_M,
	input wire[31:0] readData_M,
	input wire isInDelayslot_M,
	//writeback stage
	output wire flush_W,
	input wire memToReg_W,
	input wire regWrite_W,
	input wire writeHiLo_W,
	// CP0
	input wire fromCP0,
	input wire writeCP0_M, writeCP0_W,
	input wire[5:0] int_i,
	output wire timer_int_o,
	// DEBUG
	output wire [31:0] inst_addr_W,
	output wire [4:0] writeregW,
	output wire [31:0] resultW
	// Exception
    );
	wire ExcFlush;
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcplus4F,pcbranchD,PCJump;
	//decode stage
	wire [31:0] pcplus4D,inst_D;
	wire forwardaD,forwardbD;
	wire [4:0] rdD;
	wire stall_D; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srcbD;
	wire [4:0] saD;
	//execute stage
	wire [1:0] forwardaE,forwardbE, fwdhiloE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] ALUOut_E;
	wire [4:0] saE;
	//mem stage
	wire [4:0] writeregM;
	//writeback stage
//	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW;
	
	wire [31:0] hiM, loM, hiW, loW;
	wire [31:0] hi_iE, lo_iE, hi_oE, lo_oE;
	wire stall_div;
	wire [31:0] pcplus4E;
	wire [31:0] hiD, loD, hiE, loE;
	wire[`RegBus] excepttype_i;
	wire[`RegBus] current_inst_addr_i;
	wire is_in_delayslot_i;
	wire[`RegBus] bad_addr_i;
	wire[`RegBus] data_o;
    wire[`RegBus] count_o;
    wire[`RegBus] compare_o;
    wire[`RegBus] status_o;
    wire[`RegBus] cause_o;
    wire[`RegBus] epc_o;
    wire[`RegBus] config_o;
    wire[`RegBus] prid_o;
    wire[`RegBus] badvaddr;
    wire [31:0] srcaD_final;
    wire [31:0] PCJumpD, extpcjump;
    wire [31:0] PC_Next_F;
    wire [31:0] exceptType_oE, exceptType_M;
    wire fwdCP0status, fwdCP0cause, fwdCP0epc;
    wire flush_PC, flush_W, flush_D, /*flush_E,*/ flush_M;
    wire [31:0] excPC;
  
//------------------------------SOC LITE Debug Signal-----------------------------
	wire [31:0] inst_addr_D, inst_addr_E, inst_addr_M;
	flopenrc #(32) debug_pc_1(CLK, RST, ~stall_D, flush_D, inst_addr_F, inst_addr_D);
	flopenrc #(32) debug_pc_2(CLK, RST, ~stall_E, flush_E, inst_addr_D, inst_addr_E);
	floprc   #(32) debug_pc_3(CLK, RST, flush_M, inst_addr_E, inst_addr_M);
	floprc   #(32) debug_pc_4(CLK, RST, flush_W, inst_addr_M, inst_addr_W);
   
   
//----------------------------------Hazard Unit-----------------------------------
	HazardUnit h(
		rsD, rtD, rdD, rsE, rtE, rdE,
		writeregE, writeregM, writeregW,
		memToReg_E, memToReg_M,
		regWrite_E, regWrite_M, regWrite_W,
		writeHiLo_M, writeHiLo_W,
		branchD, jrD,
		stall_div,
		writeCP0_M, writeCP0_W,
		ExcFlush,
		forwardaE, forwardbE,
		forwardaD, forwardbD,
		fwdhiloE,
		fwdCP0status, fwdCP0cause, fwdCP0epc,
		stallF, stall_D, stall_E,
		flush_PC, flush_D, flush_E, flush_M, flush_W
	);


//----------------------------------Fetch Stage-----------------------------------
// Select jump addresses from registers or immediate.
	mux2 #(32) JumpAdrMux(PCJumpD, srca2D, jrD, PCJump);
	
// Select next pc address (by checking branch and jump)
	mux3 #(32) PCMux(pcplus4F, pcbranchD, PCJump, pcsrcD, PC_Next_F);

// PC flip flop
	PC pc(
		CLK,RST,
		~stallF, flush_PC,
		excPC,
		PC_Next_F,
		inst_addr_F
	);
	
// Add 4 to pc
	adder PCAdd4(inst_addr_F,32'b100,pcplus4F);


//------------------Flip Flops between Fetch and Decode Stage---------------------
//	assign flush_D = 0/*jumpD | pcsrcD*/;
	flopenrc #(32) r1D(CLK,RST,~stall_D,flush_D,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(CLK,RST,~stall_D,flush_D,inst_F,inst_D);
	flopenrc #(32) r3D(CLK,RST,~stall_D,flush_D,inst_addr_F, inst_addr_D);
	
	
	
//----------------------------------Decode Stage----------------------------------
// Extend the 16-bits immediate to 32-bits
	SignExtend se(inst_D[15:0], inst_D[29:28], signimmD);
	
// Calculate the instruction addresses for branch.
	ShiftLeft2 immsh(signimmD,signimmshD);
	adder PCAddImm(pcplus4D,signimmshD,pcbranchD);

// Calculate the instruction addresses for jump 
	ShiftLeft2 pcjumpsh({6'b000000, inst_D[25:0]}, extpcjump);
	assign PCJumpD = (pcplus4D & 32'hf0000000) | extpcjump[27:0];
	
//	Forward data for comparison in branch instructions.
	mux2 #(32) fwdBrAMux(srcaD,ALUOut_M,forwardaD,srca2D);
	mux2 #(32) fwdBrBMux(srcbD,ALUOut_M,forwardbD,srcb2D);

// Common Registers
	Register rf(CLK,regWrite_W,rsD,rtD,writeregW,resultW,srcaD,srcbD);

// High & Low Registers
	hilo_reg HiLo(CLK, RST, writeHiLo_W, hiW, loW, hiD, loD);

// Co-Processor Zero
	cp0_reg CP0(
		CLK, RST,
		writeCP0_W, writeregW, rdD, resultW,
		int_i, excepttype_i, current_inst_addr_i, is_in_delayslot_i, bad_addr_i,
	    data_o, count_o, compare_o, status_o, cause_o, epc_o, config_o, prid_o, badvaddr, timer_int_o
	);

// Read from CP0 or Registers
	mux2 #(32) regOrCP0(srcaD, data_o, fromCP0, srcaD_final);
	
// Direct connection with wires.
	assign saD = inst_D[10:6];
	assign inst_op_D = inst_D[31:26];
	assign inst_funct_D = inst_D[5:0];
	assign rsD = inst_D[25:21];
	assign rtD = inst_D[20:16];
	assign rdD = inst_D[15:11];



//------------------Flip Flops between Decode and Execution Stage-------------------
	flopenrc #(32) r1E(CLK, RST, ~stall_E, flush_E, srcaD_final,srcaE);
    flopenrc #(32) r2E(CLK, RST, ~stall_E, flush_E, srcbD,srcbE);
    flopenrc #(32) r3E(CLK, RST, ~stall_E, flush_E, signimmD,signimmE);
    flopenrc #(5)  r4E(CLK, RST, ~stall_E, flush_E, rsD, rsE);
    flopenrc #(5)  r5E(CLK, RST, ~stall_E, flush_E, rtD, rtE);
    flopenrc #(5)  r6E(CLK, RST, ~stall_E, flush_E, rdD, rdE);
    flopenrc #(5)  r7E(CLK, RST, ~stall_E, flush_E, saD, saE);
    flopenrc #(32) r8E(CLK, RST, ~stall_E, flush_E, hiD, hiE);
    flopenrc #(32) r9E(CLK, RST, ~stall_E, flush_E, loD, loE);
    flopenrc #(32) r10E(CLK, RST, ~stall_E, flush_E, pcplus4D, pcplus4E);

	
	
	
//----------------------------------Execution Stage----------------------------------
// SRCA Multiplexier
	mux3 #(32) fwdSrcAMux(srcaE,resultW,ALUOut_M,forwardaE,srca2E);
	
// SRCB Multiplexier
	mux3 #(32) fwdSrcBMux(srcbE,resultW,ALUOut_M,forwardbE,srcb2E);
	mux2 #(32) immeMux(srcb2E,signimmE,ALUSrc_E,srcb3E);

// HiLo multiplexier
	mux3 #(32) fwdHiMux(hiE, hiM, hiW, fwdhiloE, hi_iE);
	mux3 #(32) fwdLoMux(loE, loM, loW, fwdhiloE, lo_iE);

// Arithmetic Logic Unit
	ALU alu(
		CLK,RST,
		srca2E,srcb3E,
		hi_iE,lo_iE,
		ALUctrl_E,saE,
		pcplus4E,
		exceptType_iE,
		ALUOut_E,
		hi_oE,lo_oE,
		exceptType_oE,
		stall_div
	);
	assign stopRegWrite = exceptType_oE[10] | (|exceptType_oE[14:13]);
	assign stopMemWrite = (|exceptType_oE[16:15]);
// Selection the register to be written
	mux3 #(5) wrmux(rtE,rdE,5'b11111,{jal_E, regDst_E},writeregE);
//


//-------------------Flip Flops between Execute and Memory Stage---------------------
	floprc #(32) r1M(CLK,RST,flush_M,srcb2E,writeData_M);
	floprc #(32) r2M(CLK,RST,flush_M,ALUOut_E,ALUOut_M);
	floprc #(32) r3M(CLK,RST,flush_M,hi_oE,hiM);
	floprc #(32) r4M(CLK,RST,flush_M,lo_oE,loM);
	floprc #(5)  r5M(CLK,RST,flush_M,writeregE,writeregM);
	floprc #(32) r6M(CLK,RST,flush_M,exceptType_oE, exceptType_M);



//----------------------------------Memory Stage-------------------------------------

//	cp0_reg CP0(
//		CLK, RST,
//		writeCP0_W, writeregW, rdD, resultW,
//		int_i, excepttype_i, current_inst_addr_i, is_in_delayslot_i, bad_addr_i,
//	    data_o, count_o, compare_o, status_o, cause_o, epc_o, config_o, prid_o, badvaddr, timer_int_o
//	);
	wire [31:0] status, cause, epc, epc_out;
	wire [31:0] ExcCode;
	mux2 #(32) statusMux(status_o, aluoutW, fwdCP0status, status);
	mux2 #(32) causeMux(cause_o, aluoutW, fwdCP0cause, cause);
	mux2 #(32) ecpMux(epc_o, aluoutW, fwdCP0epc, epc);
	Except exc(
		.reset(RST),
		.exceptType_i(exceptType_M),
		.inst_addr(inst_addr_M),
		.cp0_status_i(status),
		.cp0_cause_i(cause),
		.exceptType_o(ExcCode)
	);
	
	CTRL ctrl(
		.rst(RST),
		.cp0_epc(epc),
		.excepttype(ExcCode),
		.except_pc(excPC),
		.flush(ExcFlush)
	);
	assign excepttype_i = ExcCode;
	assign current_inst_addr_i = inst_addr_M;
	assign is_in_delayslot_i = isInDelayslot_M;


//---------------Flip Flops between Memory and Write Back Stage----------------------
	floprc #(32) r1W(CLK,RST,flush_W,ALUOut_M,aluoutW);
	floprc #(32) r2W(CLK,RST,flush_W,readData_M,readdataW);
	floprc #(5)  r3W(CLK,RST,flush_W,writeregM,writeregW);
	floprc #(32) r4W(CLK,RST,flush_W,hiM,hiW);
	floprc #(32) r5W(CLK,RST,flush_W,loM,loW);




//---------------------------------Write Back Stage----------------------------------
// Select the result of ALU or data read from memory to write (back) to registers.
	mux2 #(32) resmux(aluoutW,readdataW,memToReg_W,resultW);



endmodule
