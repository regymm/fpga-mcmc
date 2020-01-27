`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2020 03:56:58 PM
// Design Name: 
// Module Name: hello
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


module hello(
input wire sysclk,
input wire [1:0]sw,
output reg [3:0]led
    );
always @ (*) begin
    led[0] <= sw[0];
    led[1] <= sw[1];
    led[2] <= sw[0];
    led[3] <= sw[1];
end
endmodule
