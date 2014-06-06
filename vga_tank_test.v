`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:18:56 09/14/2013
// Design Name:   vga_tank
// Module Name:   E:/verilog/VGA/vga_tank/vga_tank_test.v
// Project Name:  vga_tank
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_tank
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vga_tank_test;

	// Inputs
	reg clk_100M;
	reg rst;

	// Outputs
	wire [7:0] rgb_8bits;
	wire hsync;
	wire vsync;

	// Instantiate the Unit Under Test (UUT)
	vga_tank uut (
		.clk_100M(clk_100M), 
		.rst(rst), 
		.rgb_8bits(rgb_8bits), 
		.hsync(hsync), 
		.vsync(vsync)
	);
	
	always #5 clk_100M<=~clk_100M;

	initial begin
		// Initialize Inputs
		clk_100M = 0;
		rst = 0;
		
		#5 rst=1;
		#5 rst=0;

		// Wait 100 ns for global reset to finish
		#1000 $stop;
        
		// Add stimulus here

	end
      
endmodule

