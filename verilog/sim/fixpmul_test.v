`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/17/2020 02:46:22 PM
// Design Name: 
// Module Name: fixpmul_test
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


module fixpmul_test();

reg clk = 0;
always @(*) #10 clk <= ~clk; 

reg [7:0]a = 8'b0000_0010;
reg [7:0]b = 8'b0000_0111;
wire [7:0]o;

reg [7:0]rega = 8'b0000_0010;
reg [7:0]regb = 8'b0000_0111;
reg [7:0]rego;

fixpmul #(.IW(8), .FW(0)) multest
(
    .a(rega),
    .b(regb),
    .o(o)
);

always @ (posedge clk) begin
    // a <= rega;
    // b <= regb;
    // #1
    rego <= o;
end

initial begin
    #105
    rega = 8'b0000_1111;
    #100
    regb = 8'b1110_1110;
end

endmodule
