`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2019 12:01:28 AM
// Design Name: 
// Module Name: CTRL
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


module CTRL(
	input wire rst,
	input wire [31:0] cp0_epc,
	input wire [31:0] excepttype,
	output reg [31:0] except_pc,
	output reg flush
    );
    
    always @ (*) begin
    	if (rst == 1'b1) begin
    		flush <= 1'b0;
    		except_pc <= `ZeroWord;
    	end else if (excepttype != `ZeroWord) begin
    		flush <= 1'b1;
    		case (excepttype)
    			32'h0000_0001: begin	// interrupt
    				except_pc <= 32'h0000_0020;
    			end
    			32'h0000_0008: begin	// syscall
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_000a: begin	// invalid inst
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_0009: begin	// break
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_000c: begin	// overflow
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_000e: begin	// eret
    				except_pc <= cp0_epc;
    			end
//    			32'h0000_000d: begin	// trap
//    				except_pc <= 32'h0000_0040;
//    			end	
    			32'h0000_0004: begin	// LH, LHU not aligned
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_0004: begin	// LW not aligned
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_0005: begin	// SH not aligned
    				except_pc <= 32'h0000_0040;
    			end
    			32'h0000_0005: begin	// SW not aligned
    				except_pc <= 32'h0000_0040;
    			end
    			default: begin
    				$stop;
    			end
    		endcase
    	end else begin
    		flush <= `False_v;
    		except_pc = `ZeroWord;
    	end
    end
    
    
    
    
    
endmodule
