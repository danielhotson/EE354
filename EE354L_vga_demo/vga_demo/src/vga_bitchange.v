`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:38 12/14/2017 
// Design Name: 
// Module Name:    vgaBitChange 
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
// Date: 04/04/2020
// Author: Yue (Julien) Niu
// Description: Port from NEXYS3 to NEXYS4
//////////////////////////////////////////////////////////////////////////////////
module vga_bitchange(
	input clk,
	input bright,
	input buttonU,
	input buttonL,
	input buttonR,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [15:0] score
   );
	
	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter ORANGE = 12'b1111_1001_0011;
	parameter PINK = 12'b1110_0011_1101;
	parameter BLUE = 12'b0000_0000_1111;
	parameter TAN = 12'b1111_1011_0101;

	wire whiteZone;
	wire greenMiddleSquare;
	reg reset;
	reg[9:0] greenMiddleSquareY;
	reg[9:0] marioX;
	reg[9:0] marioY;
	reg[9:0] princessX;
	reg[9:0] princessY;

    reg[1:0] marioAnimation;

	reg[49:0] greenMiddleSquareSpeed; 
	reg[49:0] marioSpeed;

	initial begin
		greenMiddleSquareY = 10'd320;
		marioX = 10'd200;
		marioY = 10'd450;
		princessX = 10'd326;
		princessY = 10'd70;
		score = 15'd0;
		reset = 1'b0;
	end
	
	
	always@ (*) // paint a white box on a red background
    	if (~bright)
		   rgb = GREEN; // force black if not bright
		else if (princess == 1)
	 	   rgb = WHITE;
	    else if (princessOD == 1)
		   rgb = ORANGE;
	    else if (princessPD == 1)
		   rgb = PINK;
	    else if (princessBD == 1)
		   rgb = BLUE;
		else if (marioStandBD == 1)
		      rgb = BLUE;
	    else if (marioStandRD == 1)
		   rgb = RED;
	    else if (marioStand == 1)
		   rgb = TAN;
	    else
		   rgb = BLACK; // background color

	
	always@ (posedge clk)
		begin
		greenMiddleSquareSpeed = greenMiddleSquareSpeed + 50'd1;
		if (greenMiddleSquareSpeed >= 50'd500000) //500 thousand
			begin
			greenMiddleSquareY = greenMiddleSquareY + 10'd1;
			greenMiddleSquareSpeed = 50'd0;
			if (greenMiddleSquareY == 10'd779)
				begin
				greenMiddleSquareY = 10'd0;
				end
			end
		end

	always@ (posedge clk)
		if ((reset == 1'b0) && (buttonU == 1'b1) && (hCount >= 10'd144) && (hCount <= 10'd784) && (greenMiddleSquareY >= 10'd400) && (greenMiddleSquareY <= 10'd475))
			begin
			score = score + 16'd1;
			reset = 1'b1;
			end
		else if (greenMiddleSquareY <= 10'd20)
			begin
			reset = 1'b0;
			end
	
	always@ (posedge clk)
	   if (buttonR == 1'b1)
	       begin
	       marioAnimation = 2'b01;
	       marioSpeed = marioSpeed + 50'd1;
	       if (marioSpeed >= 50'd500000)
	           begin
	           marioX = marioX + 10'd1;
	           marioSpeed = 50'd0;
	           end
	           marioAnimation = 2'b00;
	       end
	       
	   else if (buttonL == 1'b1)
	       begin
	       marioAnimation = 2'b01;
	       marioSpeed = marioSpeed + 50'd1;
	       if (marioSpeed >= 50'd500000)
	           begin
	           marioX = marioX - 10'd1;
	           marioSpeed = 50'd0;
	           marioAnimation = 2'b00;
	           end
	       end
	   else if (buttonU == 1'b1)
	       begin
	       marioSpeed = marioSpeed + 50'd1;
	       if (marioSpeed >= 50'd500000)
	           begin
	           marioY = marioY - 10'd1;
	           marioSpeed = 50'd0;
	           end
	       end

	assign whiteZone = ((hCount >= 10'd144) && (hCount <= 10'd784)) && ((vCount >= 10'd400) && (vCount <= 10'd475)) ? 1 : 0;

	assign greenMiddleSquare = ((hCount >= 10'd340) && (hCount < 10'd380)) &&
				   ((vCount >= greenMiddleSquareY) && (vCount <= greenMiddleSquareY + 10'd40)) ? 1 : 0;

	assign marioJump = (((hCount >= marioX - 2) && (hCount < marioX +6)) && ((vCount >= marioY -16) && (vCount < marioY -14)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +8)) && ((vCount >= marioY -14) && (vCount < marioY -12)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +8)) && ((vCount >= marioY -12) && (vCount < marioY -10)))
					|| (((hCount >= marioX - 10) && (hCount < marioX +10)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX - 12) && (hCount < marioX +10)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX - 10) && (hCount < marioX +12)) && ((vCount >= marioY -6) && (vCount < marioY -4)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +6)) && ((vCount >= marioY -4) && (vCount < marioY -2)))
					|| (((hCount >= marioX - 14) && (hCount < marioX -10)) && ((vCount >= marioY -2 ) && (vCount < marioY)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +12)) && ((vCount >= marioY -2 ) && (vCount < marioY)))
					|| (((hCount >= marioX - 14) && (hCount < marioX +16)) && ((vCount >= marioY) && (vCount < marioY +2)))
					|| (((hCount >= marioX - 14) && (hCount < marioX -10)) && ((vCount >= marioY +2) && (vCount < marioY +4)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +8)) && ((vCount >= marioY+2) && (vCount < marioY+4)))
					|| (((hCount >= marioX + 10) && (hCount < marioX +16)) && ((vCount >= marioY+2) && (vCount < marioY+4)))
					|| (((hCount >= marioX - 12) && (hCount < marioX -10)) && ((vCount >= marioY+4) && (vCount < marioY+6)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +8)) && ((vCount >= marioY+4) && (vCount < marioY+6)))
					|| (((hCount >= marioX - 12) && (hCount < marioX +10)) && ((vCount >= marioY+6) && (vCount < marioY+8)))
					|| (((hCount >= marioX - 12) && (hCount < marioX +12)) && ((vCount >= marioY+8) && (vCount < marioY+10)))
					|| (((hCount >= marioX - 12) && (hCount < marioX -2)) && ((vCount >= marioY+10) && (vCount < marioY+12)))
					|| (((hCount >= marioX + 4) && (hCount < marioX +14)) && ((vCount >= marioY+10) && (vCount < marioY+12)))
					|| (((hCount >= marioX + 8) && (hCount < marioX +14)) && ((vCount >= marioY+12) && (vCount < marioY+14)))
					|| (((hCount >= marioX + 6) && (hCount < marioX +12)) && ((vCount >= marioY+14) && (vCount < marioY+16))) ? 1 : 0;

	assign marioJumpBD =  (((hCount >= marioX) && (hCount < marioX +8)) && ((vCount >= marioY -12) && (vCount < marioY -10)))
					|| (((hCount >= marioX - 4) && (hCount < marioX -2)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX + 2) && (hCount < marioX +4)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX + 8) && (hCount < marioX +10)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX - 6) && (hCount < marioX -4)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX) && (hCount < marioX +4)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX + 10) && (hCount < marioX +12)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX - 10) && (hCount < marioX -2)) && ((vCount >= marioY -6) && (vCount < marioY -4)))
					|| (((hCount >= marioX + 6) && (hCount < marioX +12)) && ((vCount >= marioY -6) && (vCount < marioY -4)))
					|| (((hCount >= marioX - 4) && (hCount < marioX)) && ((vCount >= marioY-2) && (vCount < marioY)))
					|| (((hCount >= marioX + 4) && (hCount < marioX +12)) && ((vCount >= marioY-2) && (vCount < marioY +2)))
					|| (((hCount >= marioX - 8) && (hCount < marioX -2)) && ((vCount >= marioY) && (vCount < marioY+2)))
					|| (((hCount >= marioX + 4) && (hCount < marioX +8)) && ((vCount >= marioY+2) && (vCount < marioY+4)))
					|| (((hCount >= marioX - 12) && (hCount < marioX -10)) && ((vCount >= marioY+4) && (vCount < marioY+6)))
					|| (((hCount >= marioX - 12) && (hCount < marioX -8)) && ((vCount >= marioY+6) && (vCount < marioY+12)))
					|| (((hCount >= marioX + 8) && (hCount < marioX +14)) && ((vCount >= marioY+10) && (vCount < marioY+14)))
					|| (((hCount >= marioX + 6) && (hCount < marioX +12)) && ((vCount >= marioY+14) && (vCount < marioY+16))) ? 1 : 0;
	
	assign marioJumpRD = (((hCount >= marioX - 2) && (hCount < marioX +6)) && ((vCount >= marioY -16) && (vCount < marioY -14)))
					|| (((hCount >= marioX -8) && (hCount < marioX +8)) && ((vCount >= marioY-14) && (vCount < marioY -12)))
					|| (((hCount >= marioX - 2) && (hCount < marioX +4)) && ((vCount >= marioY-2) && (vCount < marioY)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +4)) && ((vCount >= marioY) && (vCount < marioY+2)))
					|| (((hCount >= marioX - 6) && (hCount < marioX +4)) && ((vCount >= marioY+2) && (vCount < marioY+4)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +8)) && ((vCount >= marioY+4) && (vCount < marioY+6)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +10)) && ((vCount >= marioY+6) && (vCount < marioY+8)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +12)) && ((vCount >= marioY+8) && (vCount < marioY+10)))
					|| (((hCount >= marioX - 8) && (hCount < marioX -2)) && ((vCount >= marioY+10) && (vCount < marioY+12)))
					|| (((hCount >= marioX + 4) && (hCount < marioX +8)) && ((vCount >= marioY+10) && (vCount < marioY+12))) ? 1 : 0;

	assign marioStand = (((hCount >= marioX - 2) && (hCount < marioX +6)) && ((vCount >= marioY-16) && (vCount < marioY-14)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +8)) && ((vCount >= marioY-14) && (vCount < marioY-12)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +8)) && ((vCount >= marioY-12) && (vCount < marioY-10)))
					|| (((hCount >= marioX - 10) && (hCount < marioX +10)) && ((vCount >= marioY-10) && (vCount < marioY-8)))
					|| (((hCount >= marioX - 12) && (hCount < marioX +10)) && ((vCount >= marioY-8) && (vCount < marioY-6)))
					|| (((hCount >= marioX - 10) && (hCount < marioX +12)) && ((vCount >= marioY-6) && (vCount < marioY-4)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +6)) && ((vCount >= marioY-4) && (vCount < marioY-2)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +8)) && ((vCount >= marioY-2) && (vCount < marioY)))
					|| (((hCount >= marioX - 6) && (hCount < marioX +10)) && ((vCount >= marioY) && (vCount < marioY+4)))
					|| (((hCount >= marioX - 8) && (hCount < marioX +10)) && ((vCount >= marioY+4) && (vCount < marioY+10)))
					|| (((hCount >= marioX - 6) && (hCount < marioX)) && ((vCount >= marioY+10) && (vCount < marioY+12)))
					|| (((hCount >= marioX + 2) && (hCount < marioX +10)) && ((vCount >= marioY+10) && (vCount < marioY+12)))
					|| (((hCount >= marioX - 6) && (hCount < marioX)) && ((vCount >= marioY+12) && (vCount < marioY+14)))
					|| (((hCount >= marioX + 4) && (hCount < marioX + 10)) && ((vCount >= marioY+12) && (vCount < marioY+14)))
					|| (((hCount >= marioX - 8) && (hCount < marioX)) && ((vCount >= marioY+14) && (vCount < marioY+16)))
					|| (((hCount >= marioX + 2) && (hCount < marioX +10)) && ((vCount >= marioY+14) && (vCount < marioY+16))) ? 1 : 0;

	assign marioStandBD = (((hCount >= marioX) && (hCount < marioX +8)) && ((vCount >= marioY -12) && (vCount < marioY -10)))
					|| (((hCount >= marioX - 4) && (hCount < marioX -2)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX + 2) && (hCount < marioX +4)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX + 8) && (hCount < marioX +10)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX - 6) && (hCount < marioX -4)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX) && (hCount < marioX +4)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX + 8) && (hCount < marioX +10)) && ((vCount >= marioY -8) && (vCount < marioY -6)))
					|| (((hCount >= marioX - 10) && (hCount < marioX -2)) && ((vCount >= marioY -6) && (vCount < marioY -4)))
					|| (((hCount >= marioX + 6) && (hCount < marioX +12)) && ((vCount >= marioY -6) && (vCount < marioY -4)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +8)) && ((vCount >= marioY-2) && (vCount < marioY)))
					|| (((hCount >= marioX - 6) && (hCount < marioX +10)) && ((vCount >= marioY) && (vCount < marioY +2 )))
					|| (((hCount >= marioX + 2) && (hCount < marioX +10)) && ((vCount >= marioY +2) && (vCount < marioY +6)))
					|| (((hCount >= marioX + 6) && (hCount < marioX +8)) && ((vCount >= marioY +6) && (vCount < marioY +8)))
					|| (((hCount >= marioX - 6) && (hCount < marioX)) && ((vCount >= marioY+12) && (vCount < marioY+14)))
					|| (((hCount >= marioX + 4) && (hCount < marioX + 10)) && ((vCount >= marioY+12) && (vCount < marioY+14)))
					|| (((hCount >= marioX - 8) && (hCount < marioX)) && ((vCount >= marioY+14) && (vCount < marioY+16)))
					|| (((hCount >= marioX + 2) && (hCount < marioX +10)) && ((vCount >= marioY+14) && (vCount < marioY+16))) ? 1 : 0;

	assign marioStandRD = (((hCount >= marioX - 2) && (hCount < marioX +6)) && ((vCount >= marioY -16) && (vCount < marioY -14)))
					|| (((hCount >= marioX -8) && (hCount < marioX +8)) && ((vCount >= marioY -14) && (vCount < marioY -12)))
					|| (((hCount >= marioX -2) && (hCount < marioX +2)) && ((vCount >= marioY) && (vCount < marioY +2)))
					|| (((hCount >= marioX -6) && (hCount < marioX -2)) && ((vCount >= marioY +2) && (vCount < marioY +4)))
					|| (((hCount >= marioX) && (hCount < marioX +4)) && ((vCount >= marioY +2) && (vCount < marioY +4)))
					|| (((hCount >= marioX -8) && (hCount < marioX +2)) && ((vCount >= marioY +4) && (vCount < marioY +6)))
					|| (((hCount >= marioX -8) && (hCount < marioX)) && ((vCount >= marioY +6) && (vCount < marioY +8)))
					|| (((hCount >= marioX +8) && (hCount < marioX +10)) && ((vCount >= marioY +6) && (vCount < marioY +8)))
					|| (((hCount >= marioX -8) && (hCount < marioX +2)) && ((vCount >= marioY +8) && (vCount < marioY +10)))
					|| (((hCount >= marioX +6) && (hCount < marioX +10)) && ((vCount >= marioY +8) && (vCount < marioY +10)))
					|| (((hCount >= marioX -6) && (hCount < marioX)) && ((vCount >= marioY +10) && (vCount < marioY +12)))
					|| (((hCount >= marioX +2) && (hCount < marioX +10)) && ((vCount >= marioY +10) && (vCount < marioY +12))) ? 1 : 0;

	assign marioClimb = (((hCount >= marioX - 12) && (hCount < marioX -6)) && ((vCount >= marioY -18) && (vCount < marioY -12)))
					|| (((hCount >= marioX -6) && (hCount < marioX +8)) && ((vCount >= marioY -4) && (vCount < marioY -2))) ? 1 : 0;

	assign marioClimbBD = (((hCount >= marioX - 12) && (hCount < marioX -6)) && ((vCount >= marioY -12) && (vCount < marioY -10)))
					|| (((hCount >= marioX +8) && (hCount < marioX +10)) && ((vCount >= marioY -12) && (vCount < marioY -10)))
					|| (((hCount >= marioX -12) && (hCount < marioX -4)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX +6) && (hCount < marioX +10)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX -14) && (hCount < marioX +12)) && ((vCount >= marioY -8) && (vCount < marioY -4)))
					|| (((hCount >= marioX -14) && (hCount < marioX -6)) && ((vCount >= marioY -4) && (vCount < marioY -2)))
					|| (((hCount >= marioX +8) && (hCount < marioX +16)) && ((vCount >= marioY -4) && (vCount < marioY -2)))
					|| (((hCount >= marioX -12) && (hCount < marioX -6)) && ((vCount >= marioY -2) && (vCount < marioY +2)))
					|| (((hCount >= marioX -4) && (hCount < marioX +6)) && ((vCount >= marioY -2) && (vCount < marioY +2)))
					|| (((hCount >= marioX +8) && (hCount < marioX +18)) && ((vCount >= marioY -2) && (vCount < marioY +2)))
					|| (((hCount >= marioX -2) && (hCount < marioX +4)) && ((vCount >= marioY +2) && (vCount < marioY +4)))
					|| (((hCount >= marioX -12) && (hCount < marioX -2)) && ((vCount >= marioY +12) && (vCount < marioY +14)))
					|| (((hCount >= marioX +2) && (hCount < marioX +8)) && ((vCount >= marioY +14) && (vCount < marioY +16)))
					|| (((hCount >= marioX) && (hCount < marioX +12)) && ((vCount >= marioY +16) && (vCount < marioY +18)))
					|| (((hCount >= marioX) && (hCount < marioX +10)) && ((vCount >= marioY +18) && (vCount < marioY +20))) ? 1 : 0;

	assign marioClimbRD = (((hCount >= marioX - 6) && (hCount < marioX +8)) && ((vCount >= marioY -14) && (vCount < marioY -10)))
					|| (((hCount >= marioX - 4) && (hCount < marioX +6)) && ((vCount >= marioY -10) && (vCount < marioY -8)))
					|| (((hCount >= marioX -6) && (hCount < marioX -4)) && ((vCount >= marioY -2) && (vCount < marioY +2)))
					|| (((hCount >= marioX +6) && (hCount < marioX +8)) && ((vCount >= marioY -2) && (vCount < marioY +2)))
					|| (((hCount >= marioX -12) && (hCount < marioX +14)) && ((vCount >= marioY +2) && (vCount < marioY +10)))
					|| (((hCount >= marioX -14) && (hCount < marioX -12)) && ((vCount >= marioY +4) && (vCount < marioY +10)))
					|| (((hCount >= marioX -12) && (hCount < marioX +12)) && ((vCount >= marioY +10) && (vCount < marioY +12)))
					|| (((hCount >= marioX +2) && (hCount < marioX +12)) && ((vCount >= marioY +12) && (vCount < marioY +14)))
					|| (((hCount >= marioX +8) && (hCount < marioX +12)) && ((vCount >= marioY +14) && (vCount < marioY +16))) ? 1: 0;

	assign princessOD = (((hCount >= princessX - 2) && (hCount < princessX +10)) && ((vCount >= princessY -24) && (vCount < princessY -22)))
					|| (((hCount >= princessX - 4) && (hCount < princessX +12)) && ((vCount >= princessY -22) && (vCount < princessY -20)))
					|| (((hCount >= princessX - 6) && (hCount < princessX +2)) && ((vCount >= princessY -20) && (vCount < princessY -18)))
					|| (((hCount >= princessX - 16) && (hCount < princessX -12)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX - 6) && (hCount < princessX -2)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX) && (hCount < princessX +2)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX + 6) && (hCount < princessX + 8)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX - 14) && (hCount < princessX -10)) && ((vCount >= princessY -16) && (vCount < princessY -14)))
					|| (((hCount >= princessX - 4) && (hCount < princessX)) && ((vCount >= princessY -16) && (vCount < princessY -14)))
					|| (((hCount >= princessX - 12) && (hCount < princessX -2)) && ((vCount >= princessY -14) && (vCount < princessY -12)))
					|| (((hCount >= princessX - 16) && (hCount < princessX -6)) && ((vCount >= princessY -12) && (vCount < princessY -10)))
					|| (((hCount >= princessX - 14) && (hCount < princessX -6)) && ((vCount >= princessY -10) && (vCount < princessY -8)))
					|| (((hCount >= princessX - 16) && (hCount < princessX -14)) && ((vCount >= princessY -8) && (vCount < princessY -6)))
					|| (((hCount >= princessX - 12) && (hCount < princessX -10)) && ((vCount >= princessY -8) && (vCount < princessY -6))) ? 1 : 0;

	assign princess = (((hCount >= princessX + 2) && (hCount < princessX +10)) && ((vCount >= princessY -20) && (vCount < princessY -18)))
					|| (((hCount >= princessX - 2) && (hCount < princessX)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX + 2) && (hCount < princessX +6)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX + 8) && (hCount < princessX +12)) && ((vCount >= princessY -18) && (vCount < princessY -16)))
					|| (((hCount >= princessX) && (hCount < princessX +10)) && ((vCount >= princessY -16) && (vCount < princessY -14)))
					|| (((hCount >= princessX - 2) && (hCount < princessX +8)) && ((vCount >= princessY -14) && (vCount < princessY -12)))
					|| (((hCount >= princessX - 2) && (hCount < princessX +6)) && ((vCount >= princessY -12) && (vCount < princessY -10)))
					|| (((hCount >= princessX) && (hCount < princessX +4)) && ((vCount >= princessY -10) && (vCount < princessY -8)))
					|| (((hCount >= princessX + 10) && (hCount < princessX +12)) && ((vCount >= princessY -6) && (vCount < princessY -4)))
					|| (((hCount >= princessX + 10) && (hCount < princessX +14)) && ((vCount >= princessY -4) && (vCount < princessY -2)))
					|| (((hCount >= princessX + 10) && (hCount < princessX +12)) && ((vCount >= princessY - 2) && (vCount < princessY)))
					|| (((hCount >= princessX + 8) && (hCount < princessX +10)) && ((vCount >= princessY) && (vCount < princessY +2)))
					|| (((hCount >= princessX - 14) && (hCount < princessX -12)) && ((vCount >= princessY +2) && (vCount < princessY +4)))
					|| (((hCount >= princessX + 6) && (hCount < princessX +12)) && ((vCount >= princessY +2) && (vCount < princessY +4)))
					|| (((hCount >= princessX - 14) && (hCount < princessX -10)) && ((vCount >= princessY +4) && (vCount < princessY +6)))
					|| (((hCount >= princessX + 8) && (hCount < princessX +10)) && ((vCount >= princessY +4) && (vCount < princessY +6)))
					|| (((hCount >= princessX - 12) && (hCount < princessX -10)) && ((vCount >= princessY +6) && (vCount < princessY +8)))
					|| (((hCount >= princessX - 12) && (hCount < princessX -6)) && ((vCount >= princessY +8) && (vCount < princessY +10)))
					|| (((hCount >= princessX - 8) && (hCount < princessX -4)) && ((vCount >= princessY +10) && (vCount < princessY +12)))
					|| (((hCount >= princessX - 4) && (hCount < princessX +2)) && ((vCount >= princessY +12) && (vCount < princessY +14)))
					|| (((hCount >= princessX) && (hCount < princessX +8)) && ((vCount >= princessY +14) && (vCount < princessY +16))) ? 1 : 0;

	assign princessPD = (((hCount >= princessX - 6) && (hCount < princessX +6)) && ((vCount >= princessY -12) && (vCount < princessY -6)))
					|| (((hCount >= princessX - 6) && (hCount < princessX +4)) && ((vCount >= princessY -6) && (vCount < princessY -4)))
					|| (((hCount >= princessX - 4) && (hCount < princessX +10)) && ((vCount >= princessY-4) && (vCount < princessY)))
					|| (((hCount >= princessX - 8) && (hCount < princessX +8)) && ((vCount >= princessY) && (vCount < princessY+2)))
					|| (((hCount >= princessX - 12) && (hCount < princessX +6)) && ((vCount >= princessY +2) && (vCount < princessY +4)))
					|| (((hCount >= princessX - 14) && (hCount < princessX +8)) && ((vCount >= princessY +4) && (vCount < princessY +14)))
					|| (((hCount >= princessX - 18) && (hCount < princessX -14)) && ((vCount >= princessY +4) && (vCount < princessY +6)))
					|| (((hCount >= princessX - 16) && (hCount < princessX -14)) && ((vCount >= princessY +6) && (vCount < princessY +8)))
					|| (((hCount >= princessX - 6) && (hCount < princessX +8)) && ((vCount >= princessY +14) && (vCount < princessY +16)))
					|| (((hCount >= princessX - 2) && (hCount < princessX +8)) && ((vCount >= princessY +16) && (vCount < princessY +18))) ? 1 : 0;
	
	assign princessBD = (((hCount >= princessX - 4) && (hCount < princessX +2)) && ((vCount >= princessY - 2) && (vCount < princessY)))
					|| (((hCount >= princessX - 12) && (hCount < princessX -8)) && ((vCount >= princessY +12) && (vCount < princessY +14)))
					|| (((hCount >= princessX - 14) && (hCount < princessX -6)) && ((vCount >= princessY +14) && (vCount < princessY +16)))
					|| (((hCount >= princessX - 12) && (hCount < princessX -8)) && ((vCount >= princessY +16) && (vCount < princessY +18)))
					|| (((hCount >= princessX - 10) && (hCount < princessX -6)) && ((vCount >= princessY +18) && (vCount < princessY +20)))
					|| (((hCount >= princessX) && (hCount < princessX +6)) && ((vCount >= princessY +18) && (vCount < princessY +20)))
					|| (((hCount >= princessX) && (hCount < princessX +2)) && ((vCount >= princessY +20) && (vCount < princessY +22 )))
					|| (((hCount >= princessX + 4) && (hCount < princessX +10)) && ((vCount >= princessY +20) && (vCount < princessY +22))) ? 1 : 0;

endmodule