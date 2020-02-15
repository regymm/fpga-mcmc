`timescale 1ns / 1ps

module delaypass #(parameter W = 32)
(
input clk,
input [W-1:0]din,
output reg [W-1:0]dout
);
always @ (posedge clk) begin
    dout <= din;
end
endmodule
