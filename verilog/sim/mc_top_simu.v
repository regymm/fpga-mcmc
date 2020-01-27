`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2020 10:49:06 PM
// Design Name: 
// Module Name: mc_top_simu
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


module mc_top_simu();

wire [31:0]rand_1;
wire [31:0]rand_2;
wire [31:0]pi_yes;
wire [31:0]pi_no;
wire [64:0]corr2;
wire [63:0]corx2;
wire [63:0]cory2;
wire [63:0]corx;
wire [63:0]cory;
wire data_valid_1;
wire [31:0]rng_seed_1;
wire rng_exhaust;
wire [3:0]phase;
wire [3:0]phase_rst;
wire finish;

reg rst = 0;
reg clk = 0;
reg [31:0]points_num = 32'hffff;

mc_top #(.POINTS_NUM(999)) mc_top_test 
(
    .clk(clk),
    .rst(rst),
    .points_num(points_num),
    .rand_1(rand_1),
    // .rand_2(rand_2),
    // .corx(corx),
    // .cory(cory),
    // .corx2(corx2),
    // .cory2(cory2),
    .corr2(corr2),
    .pi_yes(pi_yes),
    .pi_no(pi_no),
    // .data_valid_1(data_valid_1),
    // .rng_seed_1(rng_seed_1),
    .rng_exhaust(rng_exhaust),
    // .phase(phase),
    // .phase_rst(phase_rst),
    .finish(finish)
);


always @(*) #20 clk <= ~clk; 
initial begin
    rst = 0;
    #15
    rst = 1;
    #500;
    rst = 0;

end

endmodule
