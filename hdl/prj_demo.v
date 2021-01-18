`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Jibal AOC
// Engineer: Simon Cai
// 
// Create Date: 2020/12/11 07:15:28 PM
// Module Name: test
// Target Devices: 
// Tool Versions: Vivado 2018.2
// Description: 
// 
// Dependencies:   
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module prj_demo(
 gclk,
 // rst_n,
 led
);

input gclk;
// input rst_n;
output reg [0:0] led;

clk_wiz_0 gclk_pll
 (
  // Clock out ports
  .clk    ( clk      ),
  .clk_180( clk_180  ),
  .clk80m ( clk80m   ),
  .clk50m ( clk50m   ),
  .clk10m ( clk10m   ),
  // Status and control signals
  .reset  ( 1'b0     ),
  .locked (locked    ),
 // Clock in ports
  .gclk   ( gclk     )
 );


reg [15:0] cnt_100us;
always @ (posedge clk)
begin
	if(cnt_100us == 16'd4000)
		cnt_100us <= 16'd0;
	else
		cnt_100us <= cnt_100us + 1'b1;
end		

reg [15:0] cnt_led;
always @ (posedge clk)
begin
    if(cnt_led == 16'd5000)
		cnt_led <= 16'd0;
	else if(cnt_100us == 16'd4000)
		cnt_led <= cnt_led + 1'b1;
end	

always @ (posedge clk)
begin
	if(cnt_led == 16'd5000)
	led <= ~led;
end

endmodule

