`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:46:52 06/01/2014 
// Design Name: 
// Module Name:    clk_div 
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

	always@(posedge mclk or posedge rst)
	  if (rst)
	      clk <= 0;
	  else
	      clk <= ~clk;

endmodule

