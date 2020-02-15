`timescale 1ns / 1ps

module piho_unit_0_testbench();


reg clk;
reg rst;
wire finish;
reg [31:0]before = 32'h000000;
reg [31:0]after = 32'h0000000;
reg [15:0]seed1 = 16'b1100011011100011;
reg [13:0]seed2 = 14'b10101101111011;
reg [31:0]totallooptimes = 700;
reg [31:0]warmupskip = 1;
reg [31:0]a = 32'h00002000;
reg [31:0]arev = 32'h00080000;
wire [31:0]looptimes;
wire [31:0]first;
wire [31:0]last;
wire [63:0]x2sum;
// wire [31:0]x4sum;

wire process_odd;
wire process_odd_wait;
wire process_even;
wire writeback_odd;
wire writeback_even;

wire weo;
wire wee;
wire web;
wire [5:0]addro;
wire [5:0]addre;
wire [5:0]addrb;
wire [31:0]dino;
wire [31:0]dine;
wire [31:0]dinb;
wire [31:0]douto;
wire [31:0]doute;
wire [31:0]doutb;
wire [31:0]douto_old;
wire [31:0]doute_old;

wire [31:0]inc;
wire [31:0]x;
wire [31:0]xm;
wire [31:0]xp;
wire [31:0]o;

wire [31:0]rnglog;
wire accept;

wire [5:0]addrxm;
wire [5:0]addrxp;
wire [5:0]addrx;
wire [31:0]xreal;
wire [31:0]xmreal;
wire [31:0]xpreal;

// piho_unit_0 pu_inst
piho_unit_0 pu_inst
(
    .clk(clk),
    .rst(rst),
    // .before(before),
    // .after(after),
    .before(last),
    .after(first),
    .seed1(seed1),
    .seed2(seed2),
    .a(a),
    .arev(arev),

    .totallooptimes(totallooptimes),
    .warmupskip(warmupskip),

    .looptimes(looptimes),
    .first(first),
    .last(last),
    .x2sum(x2sum),

    .process_odd(process_odd),
    .process_even(process_even),
    .process_odd_wait(process_odd_wait),
    // .process_even_wait(process_even_wait),
    .writeback_odd(writeback_odd),
    .writeback_even(writeback_even),

    .weo(weo),
    .wee(wee),
    .web(web),
    .addro(addro),
    .addre(addre),
    .addrb(addrb),
    .dino(dino),
    .dine(dine),
    .dinb(dinb),
    .douto(douto),
    .doute(doute),
    .doutb(doutb),
    .douto_old(douto_old),
    .doute_old(doute_old),
    
    .inc(inc),
    .x(x),
    .xm(xm),
    .xp(xp),
    .o(o),

    .rnglog(rnglog),
    .accept(accept),

    .addrxm(addrxm),
    .addrxp(addrxp),
    .addrx(addrx),
    // .xmreal(xmreal),
    // .xpreal(xpreal),
    // .xreal(xreal),

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
end

endmodule