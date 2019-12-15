`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/12/2019 11:57:11 PM
// Design Name: 
// Module Name: DataMemory
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


module Data_Memory_Controller (
	input wire [31:0] addr_i, wData_i,
	input wire [7:0] ALUControl,
	
	output wire [31:0] addr,
	output reg [31:0] wData,
	output reg [3:0] wEna,
	
	input wire [31:0] rdata,
	output reg [31:0] rdata_o
    );
    assign addr = {addr_i[31:2], 2'b00};
    always @(*) begin
    	case (ALUControl)
    		`EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP: begin
    			wEna <= 4'b0000;
    			wData <= `ZeroWord;
    		end
    		`EXE_SW_OP: begin
    			wEna <= 4'b1111;
    			wData <= wData_i;
    		end
    		`EXE_SH_OP:	begin
    			wData <= {wData_i[15:0], wData_i[15:0]};
    			case (addr_i[1:0])
    				2'b00:	wEna <= 4'b1100;
    				2'b10:	wEna <= 4'b0011;
    				default: begin
    					$display("[DATA MEMORY] Invalid Address.");
    					$stop;
    				end
    			endcase
    		end
    		`EXE_SB_OP: begin
    			wData <= {wData_i[7:0], wData_i[7:0], wData_i[7:0], wData_i[7:0]};
    			case (addr_i[1:0])
    				2'b00:	wEna <= 4'b1000;
    				2'b01:	wEna <= 4'b0100;
    				2'b10:	wEna <= 4'b0010;
    				2'b11:	wEna <= 4'b0001;
    			endcase
    		end
    	endcase
    end
    
//    data_mem D_MEM(CLK,memEn,wEna,{addr_i[31:2], 2'b00},wData,rdata);
    
    always @(*) begin
    	case (ALUControl)
    		`EXE_LW_OP:	rdata_o <= rdata;
    		`EXE_LH_OP: begin
    			case (addr_i[1:0])
    				2'b00:	rdata_o <= { {16{rdata[31]}}, rdata[31:16] };
    				2'b10:	rdata_o <= { {16{rdata[15]}}, rdata[15: 0] };
    				default: begin
    					$display("[DATA MEMORY] Invalid Address.");
    					$stop;
    				end
    			endcase
    		end
    		`EXE_LHU_OP: begin
    			case (addr_i[1:0])
    				2'b00:	rdata_o <= { {16{1'b0}}, rdata[31:16] };
    				2'b10:	rdata_o <= { {16{1'b0}}, rdata[15: 0] };
    				default: begin
    					$display("[DATA MEMORY] Invalid Address.");
    					$stop;
    				end
    			endcase
    		end
    		`EXE_LB_OP:	begin
    			case (addr_i[1:0])
    				2'b00:	rdata_o <= { {24{rdata[31]}}, rdata[31:24] };
    				2'b01:	rdata_o <= { {24{rdata[23]}}, rdata[23:16] };
    				2'b10:	rdata_o <= { {24{rdata[15]}}, rdata[15: 8] };
    				2'b11:	rdata_o <= { {24{rdata[ 7]}}, rdata[ 7: 0] };
    			endcase
    		end
    		`EXE_LBU_OP:	begin
    			case (addr_i[1:0])
    				2'b00:	rdata_o <= { {24{1'b0}}, rdata[31:24] };
    				2'b01:	rdata_o <= { {24{1'b0}}, rdata[23:16] };
    				2'b10:	rdata_o <= { {24{1'b0}}, rdata[15: 8] };
    				2'b11:	rdata_o <= { {24{1'b0}}, rdata[ 7: 0] };
    			endcase
    		end
    	endcase
    end
endmodule
