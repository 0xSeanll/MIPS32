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
    input wire [4:0] RsD, RtD, RsE, RtE,
    input wire [4:0] WriteRegE, WriteRegM, WriteRegW,
    input wire MemtoRegE, MemtoRegM,
    input wire RegWriteE, RegWriteM, RegWriteW,
    input wire writehiloM, writehiloW,
    input wire BranchD,
    output reg [1:0] ForwardAE, ForwardBE,
    output reg ForwardAD, ForwardBD,
    output wire [1:0] fwdhiloE,
    output wire STALLF, STALLD, FLUSHE
    );
    assign fwdhiloE = 	writehiloM ? 2'b01:
    					writehiloW ? 2'b10: 
    					/*else*/     2'b00;
    					
    wire lwStall, branchStall;
    assign lwStall = MemtoRegE && ((RsD == RtE) || (RtD == RtE));
	assign branchStall = (BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)) ||
					   (BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD));
	assign STALLF = (lwStall | branchStall);
	assign STALLD = (lwStall | branchStall);
	assign FLUSHE = (lwStall | branchStall);

    always @(*) begin 
    	if ((RsE != 0) && (RsE == WriteRegM) && RegWriteM)
    		ForwardAE <= 2'b10;
    	else if ((RsE != 0) && (RsE == WriteRegW) && RegWriteW)
    		ForwardAE <= 2'b01;
    	else ForwardAE <= 2'b00;
    	
    	if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM)
    		ForwardBE <= 2'b10;
    	else if ((RtE != 0) && (RtE == WriteRegW) && RegWriteW)
    		ForwardBE <= 2'b01;
    	else ForwardBE <= 2'b00;
    	
    	ForwardAD <= (RsD != 0) && (RsD == WriteRegM) && RegWriteM;
    	ForwardBD <= (RtD != 0) && (RtD == WriteRegM) && RegWriteM;
    end
endmodule
