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
    input wire [4:0] RsD, RtD, RdD, RsE, RtE, RdE,
    input wire [4:0] WriteRegE, WriteRegM, WriteRegW,
    input wire MemtoRegE, MemtoRegM,
    input wire RegWriteE, RegWriteM, RegWriteW,
    input wire writeHiLo_M, writeHiLo_W,
    input wire BranchD, jrD,
    input wire stall_div,
    input wire cp0WriteM,cp0WriteW,
    input wire ExcFlush,
    output reg [1:0] ForwardAE, ForwardBE,
    output reg ForwardAD, ForwardBD,
    output wire [1:0] fwdhiloE,
    output wire fwdCP0status, fwdCP0cause, fwdCP0epc,
    output wire STALLF, STALLD, STALLE, 
    output wire FLUSHPC, FLUSHD, FLUSHE, FLUSHM, FLUSHW
    );
    assign fwdhiloE = 	writeHiLo_M ? 2'b01:
    					writeHiLo_W ? 2'b10: 
    					/*else*/      2'b00;
    
    assign fwdCP0status = (WriteRegW == 5'd12) && cp0WriteW;
    assign fwdCP0cause = (WriteRegW == 5'd13) && cp0WriteW;
    assign fwdCP0epc = (WriteRegW == 5'd14) && cp0WriteW;
    				
    wire lwStall, branchStall, jrStall;
    assign lwStall = MemtoRegE && ((RsD == RtE) || (RtD == RtE));
	assign branchStall = (BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)) ||
					   (BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD));
	assign jrStall = (jrD && RegWriteE && (WriteRegE == RsD)) ||
					   (jrD && MemtoRegM && (WriteRegM == RsD));
	assign STALLF = (lwStall | branchStall) | stall_div | jrStall;
	assign STALLD = (lwStall | branchStall) | stall_div | jrStall;
	assign STALLE = stall_div;
	assign FLUSHPC = ExcFlush;
	assign FLUSHW = ExcFlush;
	assign FLUSHD = ExcFlush;
	assign FLUSHE = lwStall | branchStall | ExcFlush | jrStall;
	assign FLUSHM = ExcFlush;
	

    always @(*) begin 
    	if (((RsE != 0) && (RsE == WriteRegM) && RegWriteM) || ((RdE != 0) && (RdE == WriteRegM) && cp0WriteM))
    		ForwardAE <= 2'b10;
    	else if (((RsE != 0) && (RsE == WriteRegW) && RegWriteW) || ((RdE != 0) && (RdE == WriteRegW) && cp0WriteW) )
    		ForwardAE <= 2'b01;
    	else ForwardAE <= 2'b00;
    	
    	if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM)
    		ForwardBE <= 2'b10;
    	else if ((RtE != 0) && (RtE == WriteRegW) && RegWriteW)
    		ForwardBE <= 2'b01;
    	else ForwardBE <= 2'b00;
    	
    	ForwardAD <= ((RsD != 0) && (RsD == WriteRegM) && RegWriteM);
    	ForwardBD <= ((RtD != 0) && (RtD == WriteRegM) && RegWriteM);
    end
endmodule
