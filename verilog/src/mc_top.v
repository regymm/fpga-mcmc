`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2020 12:32:45 PM
// Design Name: 
// Module Name: mc_top
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


// a try of calculating Pi using Monte Carlo
module mc_top(
input clk,
input rst,
output reg [31:0]pi,
// fixed point real number convention: *2^-60, first 4 bits are integer part
output wire [31:0]rand_1,
output wire [31:0]rand_2,
output reg [63:0]corx,
output reg [63:0]cory,
output reg [63:0]corx2,
output reg [63:0]cory2,
output reg [63:0]corr2,
output reg [31:0]pi_yes,
output reg [31:0]pi_no,
// output reg data_valid_1,
output reg finish
);


// state machine control
reg [3:0]phase = 4'b0000;
reg [3:0]phase_rst = 4'b0000;

// cycle count
reg [31:0]count = 32'b0;
parameter N = 10;


parameter c_NUM_BITS = 32;
reg data_valid_1 = 1'b0;
reg [31:0]rng_seed_1 = 32'hDEADBEEF;
// wire [c_NUM_BITS-1:0]rand_1;
wire LFSR_Done_1;
reg data_valid_2 = 1'b0;
reg [31:0]rng_seed_2 = 32'h0F00BA20;
// wire [c_NUM_BITS-1:0]rand_2;
wire LFSR_Done_2;
LFSR #(.NUM_BITS(32)) RNG1
(
    .i_Clk(clk),
    .i_Enable(1'b1),
    .i_Seed_DV(data_valid_1),
    .i_Seed_Data(rng_seed_1),
    .o_LFSR_Data(rand_1),
    .o_LFSR_Done(LFSR_Done_1)
);
LFSR #(.NUM_BITS(32)) RNG2
(
    .i_Clk(clk),
    .i_Enable(1'b1),
    .i_Seed_DV(data_valid_2),
    .i_Seed_Data(rng_seed_2),
    .o_LFSR_Data(rand_2),
    .o_LFSR_Done(LFSR_Done_2)
);

wire [63:0]mulo1;
fixpmul #(.IW(64), .FW(0)) mul64_1
(
    .a(corx),
    .b(corx),
    .o(mulo1)
);
wire [63:0]mulo2;
fixpmul #(.IW(64), .FW(0)) mul64_2
(
    .a(cory),
    .b(cory),
    .o(mulo2)
);

always @ (posedge clk)
begin
    if (rst) begin
        data_valid_1 <= 1'b1;
        data_valid_2 <= 1'b1;
        pi_yes <= 32'b0;
        pi_no <= 32'b0;
        finish <= 1'b0;
        phase_rst <= 4'b0010;
    end
    else if (phase_rst == 4'b0010) begin
        data_valid_1 <= 1'b0;
        data_valid_2 <= 1'b0;
        phase_rst <= 4'b0000;
        phase <= 4'b0000;
    end
    else begin
        // data_valid_1 <= 1'b0;
        // data_valid_2 <= 1'b0;
        if (phase == 4'b0000) begin
            if (count == N) begin
                phase <= 4'b1111;
            end
            else begin
                // coerce into range [0,1)
                // corx <= rand_1 & 64'hFFFFFF_FFFFFF_FFF;
                // cory <= rand_2 & 64'hFFFFFF_FFFFFF_FFF;
                corx <= rand_1 & 64'hFFFFFF;
                cory <= rand_2 & 64'hFFFFFF;
                phase <= 4'b0001;
            end
        end
        else if (phase == 4'b0001) begin
            corx2 <= mulo1;
            cory2 <= mulo2;
            // corx2 <= corx * corx;
            // cory2 <= cory * cory;
            phase <= 4'b0010;
        end
        else if (phase == 4'b0010) begin
            // corr2 <= corx2 + cory2;
            // if (corx2 + cory2 < 64'h100000000) pi_yes <= pi_yes + 1;
            if (corx2 + cory2 < 64'hFFFFFF * 64'hFFFFFF) pi_yes <= pi_yes + 1;
            else pi_no <= pi_no + 1;
            phase <= 4'b0000;
        end
        else if (phase == 4'b1111) begin
            finish <= 1'b1;
            phase <= 4'b1111;
        end
        // if ((corx * corx + cory * cory) >> 24)) begin
        // end
    end
end

// reg [63:0]mula3;
// reg [63:0]mulb3;
// wire [63:0]mulo3;
// fixpmul #(.IW(4), .FW(60)) mul64_3
// (
//     .a(mula3),
//     .b(mulb3),
//     .o(mulo3)
// );
// always @ (posedge clk) begin

// end

endmodule
