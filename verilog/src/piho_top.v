`timescale 1ns / 1ps

// Path Integral Harmonic Oscillator
module piho_top
(
input clk,
input rst,
// BRAM communication ports
input [63:0]bram_dout,
input [31:0]data,
input [15:0]rngseed,
output reg [31:0]data1,
output reg [31:0]data2,
output reg [31:0]bram_addr,
output reg [63:0]bram_din,
output reg bram_en,
output bram_rst,
output reg [7:0]bram_we,
// finish notification
output reg finish
);

// number of points per configuration
parameter path_N = 5;
// total configuration number
parameter MCNconf = 130000;
// dump first configs before reaching equalibrium
parameter MCNdump = 10000;
// sample stepsize to avoid high correlation
parameter MCNskip = 600;
// turbulance size on the elements on the chain
reg [31:0]delta = 32'h00010000;
// lattice size a = 1/8, 1/a = 8
reg [32:0]a = 32'h00002000;
reg [31:0]arev = 32'h00080000;
reg [15999:0]pool = 16000'hFFFF0000FFFF;

// size of one configuration (64bit * path_N) is stored in BRAM, 
// from addr 8 * 1 to 8 * path_N, with addr 0 unused
// and updated dynamically, final results are calculated serially

// pass rst to BRAM
assign bram_rst = rst;

// the log random generator
wire [31:0]rnglog;
randlog randlog_inst
(
    .clk(clk),
    .rst(rst),
    .seed(rngseed),
    .result(rnglog)
);
// the action calculator block design
reg [31:0]inc = 0;
reg [31:0]x = 0;
reg [31:0]xm = 0;
reg [31:0]xp = 0;
wire [31:0]o;
bd_math bd_math_inst
(
    .clk(clk),
    .a(a),
    .arev(arev),
    .inc(inc),
    .x(x),
    .xm(xm),
    .xp(xp),
    .o(o)
);

// state machine control
// global phase
reg [3:0]phase;
// in-path phase
reg [3:0]ppath;
// per-point phase
reg [3:0]ppoint;

reg [31:0]init_i;
reg [31:0]main_i;
reg [31:0]chain_i;

always @ (posedge clk) begin
    if (rst) begin
        bram_addr <= 32'h0;
        bram_we <= 8'h00;
        bram_din <= 0;
        bram_en <= 1'b1;
        finish <= 0;
        phase <= 4'b0000;
        ppath <= 4'b0000;
        ppoint <= 4'b0000;
        init_i <= 0;
        main_i <= 0;
        chain_i <= 0;
    end
    else if (phase == 4'b0000) begin
        // perform a cold start: set memory to 0
        if (init_i == path_N) begin
            // move on to next phase
            phase <= 4'b0001;
            bram_addr <= 32'h0;
            bram_din <= 0;
            bram_we <= 8'h00;
            init_i <= 0;
        end
        else begin
            phase <= 4'b0000;
            bram_we <= 8'hFF;
            bram_addr <= bram_addr + 8;
            bram_din <= 0;
            init_i <= init_i + 1;
        end
    end
    else if (phase == 4'b0001) begin
        // MCSweeps: outer loop
        if (main_i == MCNconf) begin
            main_i <= 0;
            phase <= 4'b0010;
        end
        else begin
            if (ppath == 0) begin
                ppath <= ppath + 1;
            end
            else if (ppath == 1) begin
                // in one sweep: inner loop
                if (chain_i == path_N) begin
                    ppath <= 0;
                    ppoint <= 0;
                    main_i <= main_i + 1;
                    chain_i <= 0;
                end
                else begin
                    if (ppoint == 0) begin
                        // read the three relevent value from the chain
                        // initialize random inc
                        ppoint <= ppoint + 1;
                    end
                    else if (ppoint == 1) begin
                        // wait for the calculation of action
                        // compare with logRNG, prepare new write result
                        // prepare BRAM for writing
                        ppoint <= ppoint + 1;
                    end
                    else begin
                        // writing done, move on to next point
                        ppoint <= 0;
                        chain_i <= chain_i + 1;
                    end
                end
            end
            else if (ppath == 2) begin
                ppath <= ppath + 1;
            end
            else begin
            end
        end
        // bram_we <= 8'hFF;
        // bram_addr <= 32'hF;
        // bram_din <= 64'h1111000011110000;
        // phase <= 4'b0010;
    end
    else if (phase == 4'b0010) begin
        
    end
    else if (phase == 4'b1110) begin
        // bram_we <= 8'h00;
        // bram_addr <= 32'h0;
        // bram_en <= 1'b0;
        // data1 <= bram_dout;
        phase <= 4'b1111;
    end
    else if (phase == 4'b1111) begin
        finish <= 1'b1;
        // phase <= 4'b1111;
    end
end

// wire [31:0]rng_seed_1 = RNG_SEED_1;
// wire [31:0]rand_1;
// wire [31:0]rng_seed_2 = RNG_SEED_2;
// wire [31:0]rand_2;
// // reg [63:0]corx;
// // reg [63:0]cory;
// wire [64:0]corr2;
// // reg [63:0]corx2;
// // reg [63:0]cory2;
// reg [3:0]phase;
// reg [3:0]phase_rst;

// // reg [3:0]phase_rst = 4'b0000;

// // parameter c_NUM_BITS = 32;

// // assign rng_seed_1 = 32'hBEEFBEEF;
// wire LFSR_Done_1;
// // assign rng_seed_2 = 32'h9F00BA29;
// wire LFSR_Done_2;

// // reg data_valid_1;
// // reg data_valid_2;

// always @ (posedge clk or posedge rst)
// begin
//     if (rst) rng_exhaust <= 1'b0;
//     else if (rng_exhaust == 1'b0)
//         if (LFSR_Done_1 | LFSR_Done_1)
//             rng_exhaust <= 1'b1;
// end

// LFSR #(.NUM_BITS(32)) RNG1
// (
//     .i_Clk(clk),
//     .i_Rst(rst),
//     // .i_Enable(1'b1),
//     // .i_Seed_DV(data_valid_1),
//     .i_Seed_Data(rng_seed_1),
//     .o_LFSR_Data(rand_1),
//     .o_LFSR_Done(LFSR_Done_1)
// );
// LFSR #(.NUM_BITS(32)) RNG2
// (
//     .i_Clk(clk),
//     .i_Rst(rst),
//     // .i_Enable(1'b1),
//     // .i_Seed_DV(data_valid_2),
//     .i_Seed_Data(rng_seed_2),
//     .o_LFSR_Data(rand_2),
//     .o_LFSR_Done(LFSR_Done_2)
// );

// wire [63:0]corx;
// wire [63:0]cory;
// assign corx = rand_1;
// assign cory = rand_2;

// wire [63:0]mulo1;
// fixpmul #(.IW(64), .FW(0)) mul64_1
// (
//     .a(corx),
//     .b(corx),
//     .o(mulo1)
// );
// wire [63:0]mulo2;
// fixpmul #(.IW(64), .FW(0)) mul64_2
// (
//     .a(cory),
//     .b(cory),
//     .o(mulo2)
// );

// wire [63:0]corr2;
// assign corr2 = mulo1 + mulo2;

// always @ (posedge clk)
// begin
//     if (rst) begin
//         is_reseting <= 1'b1;
//         // data_valid_1 <= 1'b1;
//         // data_valid_2 <= 1'b1;
//         pi_yes <= 32'b0;
//         pi_no <= 32'b0;
//         finish <= 1'b0;
//         count <= 32'b0;
//         phase_rst <= 4'b0010;
//     end
//     else if (phase_rst == 4'b0010) begin
//         is_reseting <= 1'b0;
//         phase_rst <= 4'b0011;
//     end
//     else if (phase_rst == 4'b0011) begin
//         // data_valid_1 <= 1'b0;
//         // data_valid_2 <= 1'b0;
//         phase_rst <= 4'b0000;
//         phase <= 4'b0000;
//     end
//     else begin
//         // data_valid_1 <= 1'b0;
//         // data_valid_2 <= 1'b0;
//         if (phase == 4'b0000) begin
//             if (count == points_num) begin
//                 // finish and stop processing when reached POINTS_NUM
//                 phase <= 4'b1111;
//             end
//             else begin
//                 // // coerce random number into range [0,1)
//                 // // corx <= rand_1 & 64'hFFFFFF_FFFFFF_FFF;
//                 // // cory <= rand_2 & 64'hFFFFFF_FFFFFF_FFF;
//                 // corx <= rand_1 & 64'hFFFFFF;
//                 // cory <= rand_2 & 64'hFFFFFF;
//                 // phase <= 4'b0001;
//                 if (corr2 < 64'hFFFFFFFF * 64'hFFFFFFFF) pi_yes <= pi_yes + 1;
//                 else pi_no <= pi_no + 1;
//                 phase <= 4'b0000;
//                 count <= count + 1;
//             end
//         end
//         // else if (phase == 4'b0001) begin
//         //     corx2 <= mulo1;
//         //     cory2 <= mulo2;
//         //     // corx2 <= corx * corx;
//         //     // cory2 <= cory * cory;
//         //     phase <= 4'b0010;
//         // end
//         // else if (phase == 4'b0010) begin
//         //     // corr2 <= corx2 + cory2;
//         //     // if (corx2 + cory2 < 64'h100000000) pi_yes <= pi_yes + 1;
//         //     if (corx2 + cory2 < 64'hFFFFFF * 64'hFFFFFF) pi_yes <= pi_yes + 1;
//         //     else pi_no <= pi_no + 1;
//         //     count <= count + 1;
//         //     phase <= 4'b0000;
//         // end
//         else if (phase == 4'b1111) begin
//             finish <= 1;
//             phase <= 4'b1111;
//         end
//         // if ((corx * corx + cory * cory) >> 24)) begin
//         // end
//     end
// end

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
