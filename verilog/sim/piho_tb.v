`timescale 1ns / 1ps

module piho_old_testbench();

// reg clk;
// reg [31:0]addr = 0;
// reg [63:0]din = 0;
// wire [63:0]dout;
// reg en = 1;
// reg rst = 0;
// reg [7:0]we = 0;

reg clk;
reg rst;
wire [31:0]data;
wire [31:0]data1;
wire [31:0]data2;
wire [31:0]bram_addr;
wire [63:0]bram_din;
wire bram_en;
wire bram_rst;
wire [7:0]bram_we;
wire finish;

wire [63:0]bram_dout;


blk_mem_gen_0 bram (
    .addra(bram_addr),
    .clka(clk),
    .dina(bram_din),
    .douta(bram_dout),
    .ena(bram_en),
    // .rsta(rst),
    .wea(bram_we)
);

piho_top ptop (
    .clk(clk),
    .rst(rst),
    .bram_dout(bram_dout),
    .data(data),

    .data1(data1),
    .data2(data2),
    .bram_din(bram_din),
    .bram_addr(bram_addr),
    .bram_en(bram_en),
    .bram_rst(bram_rst),
    .bram_we(bram_we),
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