`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2019 10:31:58 PM
// Design Name: 
// Module Name: Except
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


module Except(
	input  wire reset,
	input  wire [31:0] exceptType_i,
	input  wire [31:0] inst_addr,
	input  wire [31:0] cp0_status_i,
	input  wire [31:0] cp0_cause_i,
//	input  wire [31:0] cp0_epc_i,
//	output reg  [31:0] cp0_epc_o,
	output reg  [31:0] exceptType_o
//	output reg  [31:0]
	
    );
    always @(*) begin
//    	cp0_epc_o <= cp0_epc_i;
    	if (reset == `True_v) begin
    		exceptType_o <= `ZeroWord;
    	end else begin
    		exceptType_o <= `ZeroWord;
    		if (inst_addr != `ZeroWord) begin
    			if (((cp0_cause_i[15:8] & (cp0_status_i[15:8])) != 8'h00) &&
    				(cp0_status_i[1] == 1'b0) && (cp0_status_i[0] == 1'b1)) begin
    				exceptType_o <= 32'h00000001;	// interrupt
    			end else if (exceptType_i[8] == 1'b1) begin
    				exceptType_o <= 32'h00000008;	// syscall
    			end else if (exceptType_i[9] == 1'b1) begin
    				exceptType_o <= 32'h0000000a;	// inst_invalid
    			end else if (exceptType_i[10] == 1'b1) begin
    				exceptType_o <= 32'h00000009;	// break
    			end else if (exceptType_i[11] == 1'b1) begin
    				exceptType_o <= 32'h0000000c;	// overflow
    			end else if (exceptType_i[12] == 1'b1) begin
    				exceptType_o <= 32'h0000000e;	// eret
//    			end else if (exceptType_i[13] == 1'b1) begin
//    				exceptType_o <= 32'h0000000d;	// trap
    			end else if (exceptType_i[14] == 1'b1) begin
    				exceptType_o <= 32'h00000004;	// Load half word address not aligned
    			end else if (exceptType_i[15] == 1'b1) begin
    				exceptType_o <= 32'h00000004;	// Load word address not aligned
    			end else if (exceptType_i[16] == 1'b1) begin
    				exceptType_o <= 32'h00000005;	// Save half word address not aligned
    			end else if (exceptType_i[17] == 1'b1) begin
    				exceptType_o <= 32'h00000005;	// Save word address not aligned
    			end else begin
    				exceptType_o <= 32'h00000000;
    			end
    		end
    	end
    end 
endmodule
