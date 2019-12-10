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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM 
    );
	
	wire [5:0] opD,functD;
	wire [4:0] rtD;
	wire regdstE,pcsrcD,memtoregE,memtoregM,memtoregW,regwriteE,regwriteM,regwriteW;
	wire writehiloM, writehiloW;
	wire alusrcE;
	wire [7:0] alucontrolE;
	wire flushE,equalD, branchD, jumpD;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,
//		rtD,
		equalD,
		pcsrcD,branchD,jumpD,
		
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,

		//mem stage
		memtoregM,memwriteM,
		regwriteM,writehiloM,
		//write back stage
		memtoregW,regwriteW,writehiloW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,instrF,
		//decode stage
		pcsrcD,branchD,jumpD,equalD,opD,functD,
		//execute stage
		memtoregE,alusrcE,regdstE,regwriteE,alucontrolE,flushE,
		//mem stage
		memtoregM,regwriteM, writehiloM,aluoutM,writedataM,readdataM,
		//writeback stage
		memtoregW,regwriteW,writehiloW
	    );
	
endmodule
