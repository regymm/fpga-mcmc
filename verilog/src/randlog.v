`timescale 1ns / 1ps

// RNG: log(x) in which x is uniformly distributed on (0,1)
// one result per clock
// 16+16 fixed point number
module randlog
(
input clk,
input rst,
input [15:0]seed,
output wire [31:0]lutleft,
output wire [31:0]lutright,
output wire [15:0]rng16,
output reg [31:0]result
);

LFSR #(.NUM_BITS(32)) LFSR_inst
(
    .i_Clk(clk),
    .i_Rst(rst),
    .i_Seed_Data({16'b0, seed}), // Replication
    .o_LFSR_Data(rng16)
    // .o_LFSR_Done(w_LFSR_Done)
);

// in bram: 0x0.001 per point, from 0x0000.0000 to 0x0000.FFF0
// 0x0000.000? part is done by interpolation
// wire [31:0]lutleft;
// wire [31:0]lutright;
// reg [31:0]lutright_real;
reg [11:0]addrleft;
// reg [11:0]addrright;
blk_mem_gen_1 bram_log
(
    .clka(clk),
    .addra(addrleft),
    .douta(lutleft)
    // .clkb(clk),
    // .addrb(addrright),
    // .doutb(lutright)
);
assign lutleft[31:19] = 13'b0;
// assign lutright[31:19] = 13'b0;

// wire [31:0]multo;
// wire [31:0]diff;
// assign diff = lutright_real - 
// mult_gen_0 mult_inst
// (
//     .CLK(clk),
//     .A(),
//     .B({16'b0, rng16[3:0], 12'b0}),
//     .P(multo)
// );

// wire [63:0]multmp;
// the /0x0.0010 is contained in the shifted {16,4,12}
// assign multmp = (lutright - lutleft) * ;

// wire [15:0]resultlow;
always @ (posedge clk) begin
    addrleft <= rng16[15:4];
    // addrright <= rng16[15:4] + 1;
    // if (addrleft == 12'hFFF)
    //     // log(1) = 0
    //     lutright_real <= 32'h0;
    // else
    //     lutright_real <= lutright;
    // result <= lutleft + multo;
    result <= lutleft;
end
endmodule
