`timescale 1ns / 1ps

module randlog_testbench();

reg clk;
reg rst = 0;
reg [15:0]seed;
wire [15:0]rng16;
wire [31:0]result;
wire [31:0]lutleft;
wire [31:0]lutright;

randlog randlog_inst
(
    .clk(clk),
    .rst(rst),
    .seed(seed),
    .lutleft(lutleft),
    .lutright(lutright),
    .rng16(rng16),
    .result(result)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    seed = 16'b1111;
    #80
    rst = 0;
end
// initial begin
    // rst = 1;
    // #12;
    // rst = 0;
    // #10;
    // we = 8'hFF;
    // addr = 32'h0;
    // din = 64'hdead00000000beef;
    // #10
    // we = 8'hFF;
    // addr = 32'hF;
    // din = 64'h1111111100001111;
    // #10
    // we = 8'h00;
    // addr = 32'h0;
    // #10
    // addr = 32'h1;
    // #10
    // addr = 32'h2;
    // #10
    // addr = 32'h3;
    // #10
    // addr = 32'h4;
    // #10
    // addr = 32'h5;
    // #10
    // addr = 32'h6;
    // #10
    // addr = 32'h1F;
    // #20
    // always @ (posedge clk) begin
    //     if (rst) begin
    //     end
    //     else begin
    //         #5;
    //         addr <= addr + 8;
    //     end
    // end
    // $stop;

// end

// reg [3:0]a, dpra;
// reg [2:0]d;
// wire [2:0]dpo;

// initial begin
//     clk = 0;
//     forever #5 clk = ~clk;
// end
// initial begin
//     a = 0;
//     dpra = 0;
//     d = 0;
//     we = 0;
//     #20
//     repeat(5) begin
//         @(posedge clk);
//         #1;
//         dpra = dpra + 1;
//     end
//     repeat(10) begin
//         @(posedge clk);
//         #1;
//         a = $random % 16;
//         dpra = $random % 16;
//         d = $random % 8;
//         we = $random % 2;
//     end
//     @(posedge clk);
//     #1;
//     a = 0;
//     dpra = 0;
//     d = 0;
//     we = 0;
//     #20 $stop;
// end

// dist_mem_gen_0 dist_mem_gen_simple(
// .a      (a),
// .d      (d),
// .dpra   (dpra),
// .clk    (clk),
// .we     (we),
// .dpo    (dpo)
// );

endmodule