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
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jr,
	output wire equalD,
	output wire [5:0] opD,functD,
	output wire [4:0] rtD,
	output wire [7:0] alucontrolD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,
	input wire regdstE,
	input wire regwriteE,
	input wire[7:0] alucontrolE,
	output wire flushE, stallE,
	input wire jalE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM, writehiloM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	input wire writehiloW
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,PCJump;
	//decode stage
	wire [31:0] pcplus4D,instrD;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [4:0] saD;
	//execute stage
	wire [1:0] forwardaE,forwardbE, fwdhiloE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	wire [4:0] saE;
	//mem stage
	wire [4:0] writeregM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	
	wire [31:0] hiM, loM, hiW, loW;
	wire [31:0] hi_iE, lo_iE, hi_oE, lo_oE;
	wire stall_div;
	wire [31:0] pcplus4E;
	HazardUnit h(
		rsD, rtD, rsE, rtE,
		writeregE, writeregM, writeregW,
		memtoregE, memtoregM,
		regwriteE, regwriteM, regwriteW,
		writehiloM, writehiloW,
		branchD,
		stall_div,
		forwardaE, forwardbE,
		forwardaD, forwardbD,
		fwdhiloE,
		stallF, stallD, stallE, flushE
		);
	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);

	wire [31:0] PCJumpD, extpcjump;
	mux2 #(32) JrMux(PCJumpD, srcaD, jr, PCJump);
	mux2 #(32) pcmux(pcnextbrFD, PCJump, jumpD, pcnextFD);
	flopenr #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);


	//IF->ID
	assign flushD = /*jumpD |*/ pcsrcD;
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	
	// ID
	wire [31:0] hiD, loD, hiE, loE;
		// TODO: HILO
	hilo_reg rhl(clk, rst, writehiloW, hiW, loW, hiD, loD);
	Register rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	SignExtend se(instrD[15:0], instrD[29:28], signimmD);
	ShiftLeft2 immsh(signimmD,signimmshD);
	ShiftLeft2 pcjumpsh({6'b000000, instrD[25:0]}, extpcjump);
	assign PCJumpD = (pcplus4D & 32'hf0000000) | extpcjump[27:0];
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	comparator CMP(srca2D,srcb2D,alucontrolD,rtD,equalD);
	assign saD = instrD[10:6];
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];

// ID to EXE flip flops
	flopenrc #(32) r1E(clk, rst, ~stallE, flushE, srcaD,srcaE);
    flopenrc #(32) r2E(clk, rst, ~stallE, flushE, srcbD,srcbE);
    flopenrc #(32) r3E(clk, rst, ~stallE, flushE, signimmD,signimmE);
    flopenrc #(5)  r4E(clk, rst, ~stallE, flushE, rsD, rsE);
    flopenrc #(5)  r5E(clk, rst, ~stallE, flushE, rtD, rtE);
    flopenrc #(5)  r6E(clk, rst, ~stallE, flushE, rdD, rdE);
    flopenrc #(5)  r7E(clk, rst, ~stallE, flushE, saD, saE);
    flopenrc #(32) r8E(clk, rst, ~stallE, flushE, hiD, hiE);
    flopenrc #(32) r9E(clk, rst, ~stallE, flushE, loD, loE);
    flopenrc #(32) r10E(clk, rst, ~stallE, flushE, pcplus4D, pcplus4E);
	
	
	mux3 #(32) fwdAMux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	
// SRCB Multiplexier *******************************************
	// This multiplexier handles data hazard that might happen to srcB.
	mux3 #(32) fwdBMux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	// This multiplexier select immediate or register data for srcB.
	mux2 #(32) immeMux(srcb2E,signimmE,alusrcE,srcb3E);
//  ***************************************************************************

// hilo multiplexier *******************************************
	// These two multiplexiers handle data hazard that might happen to hilo register.
	mux3 #(32) fwdHiMux(hiE, hiM, hiW, fwdhiloE, hi_iE);
	mux3 #(32) fwdLoMux(loE, loM, loW, fwdhiloE, lo_iE);
//  ***************************************************************************
	ALU alu(clk,rst,srca2E,srcb3E,hi_iE,lo_iE,alucontrolE,saE,pcplus4E,aluoutE,hi_oE,lo_oE,stall_div);
	
	mux3 #(5) wrmux(rtE,rdE,5'b11111,{jalE, regdstE},writeregE);

	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(32) r3M(clk,rst,hi_oE,hiM);
	flopr #(32) r4M(clk,rst,lo_oE,loM);
	flopr #(5) r5M(clk,rst,writeregE,writeregM);

	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5)  r3W(clk,rst,writeregM,writeregW);
	flopr #(32) r4W(clk,rst,hiM,hiW);
	flopr #(32) r5W(clk,rst,loM,loW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
