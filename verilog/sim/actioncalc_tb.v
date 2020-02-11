`timescale 1ns / 1ps

module actioncalc_testbench();

reg clk;
reg rst;


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end



reg [31:0]a;
reg [31:0]arev;
// wire clk;
reg [31:0]inc;
wire [31:0]o;
// wire [31:0]minus_inc;
// wire [31:0]test1;
// wire [31:0]test2;
reg [31:0]x;
reg [31:0]xm;
reg [31:0]xp;
bd_math bd_math_i
    (.a(a),
    .arev(arev),
    .clk(clk),
    .inc(inc),
    .o(o),
    // .minus_inc(minus_inc),
    // .test1(test1),
    // .test2(test2),
    .x(x),
    .xm(xm),
    .xp(xp));

// reg [31:0]exp_in;
// wire [31:0]exp_out;
// bd_exp bd_exp_i
//     (.clk(clk),
//     .exp_in(o),
//     .exp_out(exp_out));

initial begin
    #2
    a = 32'h0000_2000;
    arev = 32'h0008_0000;
    xp = 32'h0002_0000;
    xm = 32'h0002_0000;
    x = 32'h0003_0000;
    inc = 32'h0001_0000;
    // exp_in = 64'h00000000_12345678;
    inc = 32'h0000_8000;
    #10
    // exp_in = 64'h00000000_FFFF0000;
    inc = 32'h0000_4000;
    #10
    // exp_in = 64'h00000000_0FFF0000;
    inc = 32'h0000_2000;
    #10
    // exp_in = 64'h00000000_00FF0000;
    inc = 32'h0000_1000;
    #10
    // exp_in = 64'h00000000_00FF0000;
    xm = 32'h0000_0000;
    xp = 32'h0001_0000;
    x = 32'h0001_0000;
    inc = 32'h0001_0000;
end


// simulation of HLS generated action_calc

// reg ap_start;
// wire ap_done;
// wire ap_idle;
// wire ap_ready;
// wire [63:0]ap_return;
// reg [63:0]xm;
// reg [63:0]x;
// reg [63:0]xp;
// reg [63:0]xnew;
// reg [63:0]a;
// reg [63:0]a_rev;
// reg [63:0]inc;

// action_calc_0 action_calc_inst (
//     .ap_clk(clk),
//     .ap_rst(rst),
//     .ap_start(ap_start),
//     .ap_done(ap_done),
//     .ap_idle(ap_idle),
//     .ap_ready(ap_ready),
//     .ap_return(ap_return),
//     .xm(xm),
//     .x(x),
//     .xp(xp),
//     .xnew(xnew),
//     .a(a),
//     .a_rev(a_rev),
//     .inc(inc)
// );

// initial begin
//     rst = 1;
//     ap_start = 1;
//     xm = 64'hFFFFFFFF;
//     x = 64'hFFFFFFFF;
//     xp = 64'hFFFFFFFF;
//     xnew = 64'hFFFFFFFF;
//     inc = 64'hFFFF;
//     a = 64'hFFFF;
//     a_rev = 64'hFFFFF;
//     #80
//     rst = 0;
//     #13
//     xm = 64'hFFFFFFFFFFFF;
//     #10
//     xm = 64'h0;
//     #10
//     xm = 64'hFFFFFFFF0000;

// end

endmodule