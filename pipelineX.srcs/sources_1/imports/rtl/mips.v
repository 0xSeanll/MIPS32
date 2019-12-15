`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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

//	input wire CLK,RST,
//	output wire[31:0] pcF,
//	input wire[31:0] inst_F,
//	output wire[31:0] ALUOut_M,writeData_M,
//	input wire[31:0] readData_M,
//	output wire [7:0] ALUControl_M,
//	output wire memenM,
//	input wire [5:0] int_i,
//	output wire timer_int_o

`include "defines.vh"

module Nestor (
	input wire clk,
	input wire resetn,
	input wire [5:0] int_n_i,
	
	// Instruction Memory
	output wire inst_sram_en,
	output wire [3:0]  inst_sram_wen,
	output wire [31:0] inst_sram_addr,
	output wire [31:0] inst_sram_wdata,
	input  wire [31:0] inst_sram_rdata, 
	
	// Data Memory
	output wire data_sram_en,
	output wire [3:0]  data_sram_wen,
	output wire [31:0] data_sram_addr,
	output wire [31:0] data_sram_wdata,
	input  wire [31:0] data_sram_rdata,
	
	// Debug
	output wire [31:0] debug_wb_pc,
	output wire [3:0]  debug_wb_rf_wen,
	output wire [4:0]  debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
    );
	wire timer_int_o;
    wire [3:0] wEna;
    wire memEn_M;
    wire [31:0] pcF, inst_F;
    wire [31:0] addr, wData, rData; 
    wire flush_M, flush_W;
	wire[31:0] ALUOut_M,writeData_M;
	wire [7:0] ALUControl_M;
	wire [5:0] inst_op_D,inst_funct_D;
	wire [4:0] rsD, rtD;
	wire [31:0] readData_M;
	wire regDst_E,memToReg_E,memToReg_M,memToReg_W,regWrite_E,regWrite_M,regWrite_W;
	wire [1:0] pcsrcD;
	wire writeHiLo_M, writeHiLo_W;
	wire ALUSrc_E;
	wire [7:0] ALUctrl_E;
	wire flush_E, branchD, jumpD, ExcFlush;
    wire stall_E;
    wire jal_E, jr, bal, memen;
    wire [31:0] srca2D, srcb2D;
    wire fromCP0;
    wire writeCP0_M, writeCP0_W;
    wire [31:0] exceptType_E;
    wire stopRegWrite, stopMemWrite;
	wire isInDelayslot_M;
	
// SOC Lite port translator
    assign inst_sram_en = 2'b1;
    assign inst_sram_wen = 4'b0000;
    assign inst_sram_addr = pcF;
    assign inst_sram_wdata = `ZeroWord;
    assign inst_F = inst_sram_rdata;
    
    assign data_sram_en = memEn_M;
    assign data_sram_wen = wEna;
    assign data_sram_addr = addr;
    assign data_sram_wdata = wData;
    assign rData = data_sram_rdata;
// ----------------------SOC LITE Debug Signal----------------------
flopr    #(4) debug_wena_1(clk, resetn, wEna, debug_wb_rf_wen);
// -----------------------------------------------------------------

	controller c(
		clk,resetn,
		//decode stage
		inst_op_D,inst_funct_D,
		rsD,
		rtD,
//		equal_D,
		pcsrcD,branchD,jumpD,
		jr,
//		ALUControl_D,
		srca2D, srcb2D,
		//execute stage
		flush_E,stall_E,jal_E,
		memToReg_E,ALUSrc_E,
		regDst_E,regWrite_E,	
		ALUctrl_E,
		exceptType_E,
		stopRegWrite,
		stopMemWrite,
		//mem stage
		flush_M,
		memEn_M,
		memToReg_M,
		regWrite_M,writeHiLo_M,
		ALUControl_M,
		isInDelayslot_M,
		//write back stage
		flush_W,
		memToReg_W,regWrite_W,writeHiLo_W,
		fromCP0, writeCP0_M, writeCP0_W
	);
	datapath dp(
		clk,resetn,
		//fetch stage
		pcF,inst_F,
		//decode stage
		pcsrcD,branchD,jumpD,jr,
//		equal_D,
		inst_op_D,inst_funct_D,rsD, rtD,
//		ALUControl_D,
		srca2D, srcb2D,
		//execute stage
		memToReg_E,ALUSrc_E,regDst_E,regWrite_E,ALUctrl_E,flush_E,stall_E,jal_E,
		exceptType_E, stopRegWrite, stopMemWrite,
		//mem stage
		flush_M,
		memToReg_M,regWrite_M, writeHiLo_M,ALUOut_M,writeData_M,readData_M,
		isInDelayslot_M,
		//writeback stage
		flush_W,
		memToReg_W,regWrite_W,writeHiLo_W,
		fromCP0, writeCP0_M, writeCP0_W,
		int_n_i, timer_int_o,
		debug_wb_pc, debug_wb_rf_wnum,
		debug_wb_rf_wdata
	);
	
	Data_Memory_Controller dmc(
		.addr_i(ALUOut_M),
		.wData_i(writeData_M),
		.ALUControl(ALUControl_M),
		.addr(addr),
		.wData(wData),
		.wEna(wEna),
		.rdata(rData),
		.rdata_o(readData_M)
	);
endmodule
