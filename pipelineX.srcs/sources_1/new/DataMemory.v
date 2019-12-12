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


module DataMemory(
	input wire CLK,
	input wire [31:0] addr_i, wdata_i,
	input wire [7:0] ALUControl,
	input wire memEn,
	output reg [31:0] rdata_o
    );
    reg [3:0] wEna;
    reg [31:0] wdata;
    wire [31:0] rdata;
    always @(*) begin
    	case (ALUControl)
    		`EXE_LB_OP, `EXE_LBU_OP, `EXE_LH_OP, `EXE_LHU_OP, `EXE_LW_OP: begin
    			wEna <= 4'b0000;
    			wdata <= `ZeroWord;
    		end
    		`EXE_SW_OP: begin
    			wEna <= 4'b1111;
    			wdata <= wdata_i;
    		end
    		`EXE_SH_OP:	begin
    			wdata <= {wdata_i[15:0], wdata_i[15:0]};
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
    			wdata <= {wdata_i[7:0], wdata_i[7:0], wdata_i[7:0], wdata_i[7:0]};
    			case (addr_i[1:0])
    				2'b00:	wEna <= 4'b1000;
    				2'b01:	wEna <= 4'b0100;
    				2'b10:	wEna <= 4'b0010;
    				2'b11:	wEna <= 4'b0001;
    			endcase
    		end
    	endcase
    end
    
    data_mem D_MEM(CLK,memEn,wEna,{addr_i[31:2], 2'b00},wdata,rdata);
    
    always @(*) begin
    	case (ALUControl)
    		`EXE_LW_OP:	rdata_o <= rdata;
    		`EXE_LH_OP: begin
    			case (addr_i[1:0])
    				2'b00:	rdata_o <= { {16{rdata[31]}}, rdata[31:16] };
    				2'b10:	rdata_o <= { {16{rdata[31]}}, rdata[15: 0] };
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
