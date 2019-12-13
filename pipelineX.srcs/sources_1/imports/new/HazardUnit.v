`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 03:13:37 PM
// Design Name: 
// Module Name: HazardUnit
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


module HazardUnit(
    input wire [4:0] RsD, RtD, RdD, RsE, RtE,
    input wire [4:0] WriteRegE, WriteRegM, WriteRegW,
    input wire MemtoRegE, MemtoRegM,
    input wire RegWriteE, RegWriteM, RegWriteW,
    input wire writehiloM, writehiloW,
    input wire BranchD,
    input wire stall_div,
    input wire cp0WriteM,cp0WriteW,
    output reg [1:0] ForwardAE, ForwardBE,
    output reg ForwardAD, ForwardBD,
    output wire [1:0] fwdhiloE,
    output wire STALLF, STALLD, STALLE, FLUSHE
    );
    assign fwdhiloE = 	writehiloM ? 2'b01:
    					writehiloW ? 2'b10: 
    					/*else*/     2'b00;
    					
    wire lwStall, branchStall;
    assign lwStall = MemtoRegE && ((RsD == RtE) || (RtD == RtE));
	assign branchStall = (BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)) ||
					   (BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD));
	assign STALLF = (lwStall | branchStall) | stall_div;
	assign STALLD = (lwStall | branchStall) | stall_div;
	assign FLUSHE = (lwStall | branchStall);
	assign STALLE = stall_div;

    always @(*) begin 
    	if ((RsE != 0) && (RsE == WriteRegM) && (RegWriteM || cp0WriteM))
    		ForwardAE <= 2'b10;
    	else if ((RsE != 0) && (RsE == WriteRegW) && (RegWriteW || cp0WriteW))
    		ForwardAE <= 2'b01;
    	else ForwardAE <= 2'b00;
    	
    	if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM)
    		ForwardBE <= 2'b10;
    	else if ((RtE != 0) && (RtE == WriteRegW) && RegWriteW)
    		ForwardBE <= 2'b01;
    	else ForwardBE <= 2'b00;
    	
    	ForwardAD <= ((RsD != 0) && (RsD == WriteRegM) && RegWriteM) || ((RdD != 0) && (RdD == WriteRegM) && cp0WriteM);
    	ForwardBD <= ((RtD != 0) && (RtD == WriteRegM) && RegWriteM) || ((RdD != 0) && (RdD == WriteRegM) && cp0WriteM);
    end
endmodule
