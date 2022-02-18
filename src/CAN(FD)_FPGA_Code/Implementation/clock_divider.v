`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:18:34 01/24/2022 
// Design Name: 
// Module Name:    clock_divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clock_divider
#(parameter N = 28'd40)(
    input clk_in,
    output clk_out
    );
	reg[27:0] counter=28'd0;
	parameter DIVISOR = N;
	reg temp;
	always @(posedge clk_in)
		begin
		 counter <= counter + 28'd1;
		 if(counter>=(DIVISOR-1))
			 counter <= 28'd0;
			 temp <= (counter<DIVISOR/2)?1'b1:1'b0;
		end
	assign clk_out = temp;
endmodule
