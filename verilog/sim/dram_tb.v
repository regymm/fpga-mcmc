`timescale 1ns / 1ps

module dram_testbench();

reg clk;
reg [31:0]addr = 0;
reg [63:0]din = 0;
wire [63:0]dout;
reg en = 1;
reg rst = 0;
reg [7:0]we = 0;


blk_mem_gen_0 bram (
    .addra(addr),
    .clka(clk),
    .dina(din),
    .douta(dout),
    .ena(en),
    // .rsta(rst),
    .wea(we)
);

// state machine control
// reg [3:0]phase = 4'b0000;

// always @ (posedge clk) begin
//     if (rst) begin
//         #2;
//         phase <= 4'b0000;
//     end
//     else if (phase == 4'b0000) begin
//         #2;
//         we <= 8'hFF;
//         addr <= 32'h0;
//         din <= 64'hDEAD00000000BEEF;
//         phase <= 4'b0001;
//     end
//     else if (phase == 4'b0001) begin
//         #2;
//         we <= 8'hFF;
//         addr <= 32'hF;
//         din <= 64'h1111000011110000;
//         phase <= 4'b0010;
//     end
//     else if (phase == 4'b0010) begin
//         #2;
//         we <= 8'h00;
//         addr <= 32'h0;
//         phase <= 4'b0011;
//     end
//     else if (phase == 4'b0011) begin
//         #2;
//         we <= 8'h00;
//         addr <= 32'hF;
//         phase <= 4'b0100;
//         // data1 <= dout;
//     end
//     else if (phase == 4'b0100) begin
//         #2;
//         we <= 8'h00;
//         addr <= 32'h0;
//         phase <= 4'b1111;
//         // data1 <= dout;
//         // phase <= 4'b1111;
//     end
// end

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    addr = 32'h0;
    rst = 1;
    #80;
    rst = 0;
    #10
    #2
    addr = 32'h8;
    #10
    addr = 32'h10;
    #10
    addr = 32'h18;
    #10
    addr = 32'h20;
    #10
    addr = 32'h28;
    #10
    addr = 32'h0;
    we = 8'hFF;
    din = 64'h1234;
    #10
    addr = 32'h8;
    din = 64'h1235;
    #10
    addr = 32'h10;
    din = 64'h1236;
    #10
    addr = 32'h18;
    din = 64'h1237;
    #10
    addr = 32'h20;
    din = 64'h1238;
    we = 8'h00;
    #10
    addr = 32'h0;
    #10
    addr = 32'h8;
    #10
    addr = 32'h10;
    #10
    addr = 32'h18;
    #10
    addr = 32'h20;
    #10
    addr = 32'h28;
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