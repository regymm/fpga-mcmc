//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
//Date        : Sat Feb 15 17:57:02 2020
//Host        : petergu-dell running 64-bit Arch Linux
//Command     : generate_target bd_math_wrapper.bd
//Design      : bd_math_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_math_wrapper
   (a,
    arev,
    clk,
    inc,
    o,
    x,
    xm,
    xp);
  input [31:0]a;
  input [31:0]arev;
  input clk;
  input [31:0]inc;
  output [31:0]o;
  input [31:0]x;
  input [31:0]xm;
  input [31:0]xp;

  wire [31:0]a;
  wire [31:0]arev;
  wire clk;
  wire [31:0]inc;
  wire [31:0]o;
  wire [31:0]x;
  wire [31:0]xm;
  wire [31:0]xp;

  bd_math bd_math_i
       (.a(a),
        .arev(arev),
        .clk(clk),
        .inc(inc),
        .o(o),
        .x(x),
        .xm(xm),
        .xp(xp));
endmodule
