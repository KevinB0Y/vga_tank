`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:54:47 06/01/2014 
// Design Name: 
// Module Name:    vga_setup 
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
module vga_setup
   (
    input clk,
	 input rst,
	 output [10:0]count_h,
	 output [ 9:0]count_v
    );
	 
reg [10:0] count_h;// count for the horizotal sync
reg [9:0]  count_v;  //count for the vertical sync

always@(posedge clk or posedge rst)
	if(rst)
		count_h <= 11'd0;
   else if(count_h == 11'd1055)
      count_h <= 11'd0;	
	else 
		count_h <= count_h + 11'd1;
		
always@(posedge clk or posedge rst)
	if(rst)
		count_v <= 10'd0;
	else if (count_h == 11'd1055) 
		count_v <= count_v + 10'd1;
	else if (count_v == 10'd627)
		count_v <= 10'd0;
   else 
	   count_v <= count_v;

endmodule
