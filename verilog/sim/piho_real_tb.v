`timescale 1ns / 1ps

module piho_real_testbench();

// reg clk;
// reg [31:0]addr = 0;
// reg [63:0]din = 0;
// wire [63:0]dout;
// reg en = 1;
// reg rst = 0;
// reg [7:0]we = 0;

reg clk;
reg rst;
reg [119:0]seed = 120'h1234FF00EE_FF01234990_99FAAAB778;
reg [31:0]MCNconf = 3;
reg [31:0]MCNdump = 2;
wire [63:0]x2sum1;
wire [63:0]x2sum2;
wire [63:0]x2sum3;
wire [63:0]x2sum4;
wire [63:0]x2sumall;
wire finish;

wire [31:0]looptimes;
// wire [31:0]first1;
// wire [31:0]first2;
// wire [31:0]first3;
// wire [31:0]first4;
// wire [31:0]last1;
// wire [31:0]last2;
// wire [31:0]last3;
// wire [31:0]last4;
wire [31:0]o;

piho_top_real piho_top_real_inst
(
    .clk(clk),
    .rst(rst),
    .seed(120'h1234FF00EE_FF01234990_99FAAAB778),
    // .seed(seed),
    .MCNconf(MCNconf),
    .MCNdump(MCNdump),

    .looptimes(looptimes),
    // .first1(first1),
    // .first2(first2),
    // .first3(first3),
    // .first4(first4),
    // .last1(last1),
    // .last2(last2),
    // .last3(last3),
    // .last4(last4),
    // .o(o),

    .x2sum1(x2sum1),
    .x2sum2(x2sum2),
    .x2sum3(x2sum3),
    .x2sum4(x2sum4),
    .x2sumall(x2sumall),
    .finish(finish)
);


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    rst = 1;
    #80
    rst = 0;
    #80
    rst = 1;
    #80
    rst = 0;
end

endmodule