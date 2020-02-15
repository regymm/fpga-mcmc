`timescale 1ns / 1ps

// Path Integral Harmonic Oscillator
module piho_top_real //#(parameter seed = 120'h0F0F0F0F0F_0F0F0F0F0F_0F0F0F0F0F)
(
input clk,
input rst,
input [239:0]seed,
// total configuration number
input [31:0]MCNconf,
// dump first configs before reaching equalibrium
input [31:0]MCNdump,
// output reg [63:0]x2sum,
// output wire [31:0]first1,
// output wire [31:0]first2,
// output wire [31:0]first3,
// output wire [31:0]first4,
// output wire [31:0]last1,
// output wire [31:0]last2,
// output wire [31:0]last3,
// output wire [31:0]last4,
output wire [63:0]x2sum1,
output wire [63:0]x2sum2,
output wire [63:0]x2sum3,
output wire [63:0]x2sum4,
output wire [63:0]x2sum5,
output wire [63:0]x2sum6,
output wire [63:0]x2sum7,
output wire [63:0]x2sum8,
output reg [63:0]x2sumall,
output wire [31:0]looptimes,
// output wire [31:0]o,
// finish notification
output wire finish
);

reg [32:0]a = 32'h00002000;
reg [31:0]arev = 32'h00080000;
wire [31:0]first1;
wire [31:0]first2;
wire [31:0]first3;
wire [31:0]first4;
wire [31:0]first5;
wire [31:0]first6;
wire [31:0]first7;
wire [31:0]first8;
wire [31:0]last1;
wire [31:0]last2;
wire [31:0]last3;
wire [31:0]last4;
wire [31:0]last5;
wire [31:0]last6;
wire [31:0]last7;
wire [31:0]last8;
reg [63:0]x2sumt1;
reg [63:0]x2sumt2;
reg [63:0]x2sumt3;
reg [63:0]x2sumt4;
reg [63:0]x2sumt11;
reg [63:0]x2sumt12;
// wire [63:0]x2sum1;
// wire [63:0]x2sum2;
// wire [63:0]x2sum3;
// wire [63:0]x2sum4;
piho_unit pu1
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[15:0]),
    .seed2(seed[29:16]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last8),
    .after(first2),

    .looptimes(looptimes),
    // .dinb(o),

    .first(first1),
    .last(last1),
    .x2sum_real(x2sum1),

    .finish(finish)
);
piho_unit pu2
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[45:30]),
    .seed2(seed[59:46]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last1),
    .after(first3),

    .first(first2),
    .last(last2),
    .x2sum_real(x2sum2)
);
piho_unit pu3
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[75:60]),
    .seed2(seed[89:76]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last2),
    .after(first4),

    .first(first3),
    .last(last3),
    .x2sum_real(x2sum3)
);
piho_unit pu4
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[105:90]),
    .seed2(seed[119:106]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last3),
    .after(first5),

    .first(first4),
    .last(last4),
    .x2sum_real(x2sum4)
);
piho_unit pu5
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[135:120]),
    .seed2(seed[149:136]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last4),
    .after(first6),

    .first(first5),
    .last(last5),
    .x2sum_real(x2sum5)
);
piho_unit pu6
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[165:150]),
    .seed2(seed[179:166]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last5),
    .after(first7),

    .first(first6),
    .last(last6),
    .x2sum_real(x2sum6)
);
piho_unit pu7
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[195:180]),
    .seed2(seed[209:196]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last6),
    .after(first8),

    .first(first7),
    .last(last7),
    .x2sum_real(x2sum7)
);
piho_unit pu8
(
    .clk(clk),
    .rst(rst),
    .seed1(seed[225:210]),
    .seed2(seed[239:226]),
    .totallooptimes(MCNconf),
    .warmupskip(MCNdump),
    .a(a),
    .arev(arev),
    .before(last7),
    .after(first1),

    .first(first8),
    .last(last8),
    .x2sum_real(x2sum8)
);

reg [63:0]x2sumall_t;
always @ (posedge clk) begin
    x2sumt1 <= x2sum1 + x2sum2;
    x2sumt2 <= x2sum3 + x2sum4;
    x2sumt3 <= x2sum5 + x2sum6;
    x2sumt4 <= x2sum7 + x2sum8;
    x2sumt11 <= x2sumt1 + x2sumt2;
    x2sumt12 <= x2sumt3 + x2sumt4;
    x2sumall_t <= x2sumt11 + x2sumt12;
    x2sumall <= x2sumall_t;
end

// number of points per configuration
// parameter path_N = 5;
// sample stepsize to avoid high correlation
// parameter MCNskip = 600;
// turbulance size on the elements on the chain
// reg [31:0]delta = 32'h00010000;
// lattice size a = 1/8, 1/a = 8



endmodule
