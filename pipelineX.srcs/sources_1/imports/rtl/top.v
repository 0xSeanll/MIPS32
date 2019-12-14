`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 13:50:53
// Design Name: 
// Module Name: top
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


module top(
	input wire CLK,rst,
	output wire [31:0] writedata,dataadr,
	output wire [3:0] memwrite,
	input wire [5:0] int_i,
	output wire timer_int_o
    );
	reg clkIM = 0;
	always @(CLK) begin
		#1 clkIM <= CLK;
	end
	
	wire[31:0] pc,instr,readdata;
	wire [7:0] alucontrolM;
	wire memenM;
	mips mips(CLK,rst,pc,instr,dataadr,writedata,readdata,alucontrolM,memenM,int_i,timer_int_o);
	inst_mem instMemory(clkIM,pc[31:0],instr);
	DataMemory dataMemory(CLK, dataadr, writedata, alucontrolM, memenM, readdata);
//	data_mem dmem(clk,{4{memwrite}},dataadr,writedata,readdata);
endmodule
