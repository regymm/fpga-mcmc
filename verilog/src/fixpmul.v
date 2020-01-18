`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2020 02:20:12 PM
// Design Name: 
// Module Name: fixpmul
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


module fixpmul #(parameter IW = 8, parameter FW = 8)
(
input signed [IW+FW-1:0]a,
input signed [IW+FW-1:0]b,
output signed [IW+FW-1:0]o
);
// (* multstyle = “dsp” *)  wire signed [IW*2+FW*2-1 : 0] long;
wire signed [IW*2+FW*2-1:0] long;
assign long = a * b;
assign o = long >>> FW;
// always @ (*) begin
//     o <= long >>> FW;
// end
endmodule
