`timescale 1ns / 1ps

// PIHO -- basic unit
module piho_unit
(
input clk,
input rst,
input [15:0]seed1,
input [13:0]seed2,
input [31:0]totallooptimes,
input [31:0]warmupskip,
input [31:0]a,
input [31:0]arev,
input [31:0]before,
input [31:0]after,
output reg [31:0]looptimes,
output reg [31:0]first,
output reg [31:0]last,
output reg [63:0]x2sum,
output reg [63:0]x2sum_real,
// output reg [63:0]x4sum,

output reg process_odd = 0,
output reg process_even = 0,
output reg writeback_odd = 0,
output reg writeback_even = 0,

output reg weo = 0,
output reg wee = 0,
output reg web = 0,
output reg [5:0]addro = 0,
output reg [5:0]addre = 0,
output reg [5:0]addrb = 0,
output reg [31:0]dino = 0,
output reg [31:0]dine = 0,
output reg [31:0]dinb = 0,
output wire [31:0]douto,
output wire [31:0]doute,
output wire [31:0]doutb,
output reg [31:0]douto_old,
output reg [31:0]doute_old,

output reg signed [31:0]inc,
output reg [31:0]x = 0,
output reg [31:0]xm = 0,
output reg [31:0]xp = 0,
output wire signed [31:0]o,

output wire signed [31:0]rnglog,
output reg accept,

output reg [5:0]addrxm = 0,
output reg [5:0]addrxp = 0,
output reg [5:0]addrx = 0,
output reg [31:0]xreal,
output reg [31:0]xmreal,
output reg [31:0]xpreal,

output reg [31:0]mul_in_a = 32'h0,
output wire [31:0]mul_o,

output reg finish = 0
);

reg process_odd_sig = 0;
reg process_even_sig = 0;

// o-odd, e-even, b-buffer
// three 32bit * 64 BRAM
// reg weo= 0;
// reg wee= 0;
// reg web= 0;
// reg [5:0]addro = 0;
// reg [5:0]addre = 0;
// reg [5:0]addrb = 0;
// reg [31:0]dino = 0;
// reg [31:0]dine = 0;
// reg [31:0]dinb = 0;
// wire [31:0]douto = 0;
// wire [31:0]doute = 0;
// wire [31:0]doutb = 0;
blk_mem_gen_small_0 bramo
(
    .addra(addro),
    .clka(clk),
    .dina(dino),
    .douta(douto),
    .wea(weo)
);
blk_mem_gen_small_0 brame
(
    .addra(addre),
    .clka(clk),
    .dina(dine),
    .douta(doute),
    .wea(wee)
);
blk_mem_gen_small_0 bramb
(
    .addra(addrb),
    .clka(clk),
    .dina(dinb),
    .douta(doutb),
    .wea(web)
);

// the random inc based on LFSR
// inc = 1/8 * rand(0,1)
wire [31:0]rng13;
LFSR #(.NUM_BITS(32)) lfsr_inst_14 
(
    .i_Clk(clk),
    .i_Rst(rst),
    .i_Seed_Data({18'b0, seed2}),
    .o_LFSR_Data(rng13)
);
// wire [31:0]inc;
wire [31:0]incabs;
assign incabs = {19'b0, rng13[12:0]};
always @ (*) begin
    if (rng13[13]) inc <= incabs;
    else inc <= -1 * incabs;
end

// assign inc = 32'h00010000;

// the log random generator
// wire [31:0]rnglog;
randlog randlog_inst
(
    .clk(clk),
    .rst(rst),
    .seed(seed1),
    .result(rnglog)
);
// the action calculator block design
// reg [31:0]inc = 0;
// reg [31:0]x = 0;
// reg [31:0]xm = 0;
// reg [31:0]xp = 0;
// wire [31:0]o;
// lattice size a = 1/8, 1/a = 8
// reg [31:0]a = 32'h00002000;
// reg [31:0]arev = 32'h00080000;
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

// reg [31:0]mul_in_a = 32'h0;
// wire [31:0]mul_o;
mult_gen_0 mult_inst
(
    .CLK(clk),
    .A(mul_in_a),
    .B(mul_in_a),
    .P(mul_o)
);

// reg [31:0]xreal;
// reg [31:0]xmreal;
// reg [31:0]xpreal;

always @ (*) begin
    x <= xreal;
    xm <= xmreal;
    xp <= xpreal;
end

// reg [5:0]addrxm = 0;
// reg [5:0]addrxp = 0;
// reg [5:0]addrx = 0;

reg [31:0]x_acc_1;
reg [31:0]x_rej_1;
reg [31:0]x_acc_2;
reg [31:0]x_rej_2;
reg [31:0]x_acc_3;
reg [31:0]x_rej_3;
reg [31:0]x_acc_4;
reg [31:0]x_rej_4;
reg [31:0]x_acc_5;
reg [31:0]x_rej_5;
reg [31:0]x_acc_6;
reg [31:0]x_rej_6;
reg web_old;
reg web_old_old;
always @ (posedge clk) begin
    x_acc_1 <= x + inc;
    x_rej_1 <= x;
    x_acc_2 <= x_acc_1;
    x_rej_2 <= x_rej_1;
    x_acc_3 <= x_acc_2;
    x_rej_3 <= x_rej_2;
    x_acc_4 <= x_acc_3;
    x_rej_4 <= x_rej_3;
    x_acc_5 <= x_acc_4;
    x_rej_5 <= x_rej_4;
    x_acc_6 <= x_acc_5;
    x_rej_6 <= x_rej_5;

    web_old <= web;
    web_old_old <= web_old;
end

reg updating = 0;
reg updating_old = 0;

always @ (posedge clk) begin
    douto_old <= douto;
    doute_old <= doute;
    updating_old <= updating;
    // if (process_odd) begin
    // end
end


// update first and last element
reg first_wait = 0;
reg last_wait = 0;
always @ (posedge clk) begin
    if (rst_flag) first_wait <= 0;
    else if (addro == 6'b000000) begin
        first_wait <= 1;
    end

    if (first_wait == 1) begin
        first_wait <= 0;
        first <= douto;
    end

    if (rst_flag) last_wait <= 0;
    else if (addre == 6'b111111) begin
        last_wait <= 1;
    end

    if (last_wait == 1) begin
        last_wait <= 0;
        last <= doute;
    end
end

/*
process odd bram
V
writeback odd
V
process even
V
writebak even
*/

reg [31:0]wait_cnt = 0;

// reg process_odd = 0;
// reg process_even = 0;
// reg writeback_odd = 0;
// reg writeback_even = 0;

// the reset preparation: begin from process_odd
reg rst_flag = 0;

reg in_odd = 0;
reg in_even = 0;
reg peven_ready = 0;
reg podd_ready = 0;

reg [15:0]write_wait = 0;
reg [15:0]write_cnt = 0;
reg do_write = 0;

reg recording = 0;

reg wodd_ready_n = 0;
reg weven_ready_n = 0;
 
always @ (posedge clk) begin
    if (rst) begin
        rst_flag <= 1;
    end
    else if (rst_flag) begin
        rst_flag <= 0;
        looptimes <= 1;
        addrxm <= 6'b111111 - 1;
        addrxp <= 6'b111111;
        addrx <= 6'b111111;

        process_odd <= 1;
        process_odd_sig <= 1;
        process_even <= 0;
        process_even_sig <= 0;
        // process_even_wait <= 0;
        writeback_odd <= 0;
        writeback_even <= 0;
        
        weo <= 0;
        wee <= 0;
        web <= 0;
        addro <= 0;
        addre <= 0;
        addrb <= 0;
        dino <= 0;
        dine <= 0;
        dinb <= 0;

        // x <= 0;
        // xm <= 0;
        // xp <= 0;

        wait_cnt <= 0;

        in_odd <= 0;
        in_even <= 0;
        peven_ready <= 0;
        podd_ready <= 0;

        write_wait <= 0;
        write_cnt <= 0;
        do_write <= 0;

        recording <= 0;

        wodd_ready_n <= 0;
        weven_ready_n <= 0;

        finish <= 0;
    end
    // writeback odd from brambuffer to bramodd
    else if (writeback_odd) begin
        if (write_cnt == 16'b1000000) begin
            write_cnt<= 0;
            writeback_odd <= 0;
            weo <= 0;
            // move on to process even
            process_even <= 1;
            process_even_sig <= 1;
            addrxm <= 6'b111111;
            addrxp <= 6'b000000;
            addrx <= 6'b111111;
        end
        else if (wodd_ready_n == 1) begin
            wodd_ready_n <= 0;
            addrb <= addrb + 1;
        end
        else begin
            weo <= 1;
            addro <= addro + 1;
            addrb <= addrb + 1;
            dino <= doutb;
            write_cnt <= write_cnt + 1;
        end
    end
    else if (writeback_even) begin
        if (write_cnt == 16'b1000000) begin
            // finished a loop
            if (looptimes == totallooptimes) begin
                finish <= 1;
            end
            else begin
                if (looptimes == warmupskip) recording <= 1;
                looptimes <= looptimes + 1;
                process_odd <= 1;
                process_odd_sig <= 1;
            end
            write_cnt <= 0;
            writeback_even <= 0;
            wee <= 0;
            addrxm <= 6'b111111 -  1;
            addrxp <= 6'b111111;
            addrx <= 6'b111111;
        end
        else if (weven_ready_n == 1) begin
            weven_ready_n <= 0;
            addrb <= addrb + 1;
        end
        else begin
            wee <= 1;
            addre <= addre + 1;
            addrb <= addrb + 1;
            dine <= doutb;
            write_cnt <= write_cnt + 1;
        end
    end
    else begin
        // read data and processing
        // odd case
        if (process_odd) begin
            process_odd_sig <= 0;
            in_odd <= 1;
            in_even <= 0;

            addro <= addrx;
            addre <= addrxp;

            // overflow is exploited
            addrxm <= addrxm + 1;
            addrxp <= addrxp + 1;
            addrx <= addrx + 1;

            // considering the latancy, use the boundary condition wisely
            if (in_odd & (addrx == 6'b000010)) xmreal <= before;
            else xmreal <= doute_old;
            xpreal <= doute;
            xreal <= douto;
            // move on to even elements when finished first scan, and wait for results
            if (in_odd & (addrx == 6'b111111)) begin
                wait_cnt <= 1;
            end
            if (wait_cnt) begin
                if (wait_cnt == 6 + 0) begin
                    process_odd <= 0;
                    wait_cnt <= 0;
                end
                else wait_cnt <= wait_cnt + 1;
            end
        end
        // the similar even case
        else if (process_even) begin
            process_even_sig <= 0;
            in_even <= 1;
            in_odd <= 0;

            addre <= addrx;
            addro <= addrxp;

            addrxm <= addrxm + 1;
            addrxp <= addrxp + 1;
            addrx <= addrx + 1;
            if (in_even & (addrb == 6'b111101 - 6)) xpreal <= after;
            else xpreal <= douto;
            xmreal <= douto_old;
            xreal <= doute;

            if (in_even & (addrx == 6'b111111)) begin
                wait_cnt <= 1;
            end
            if (wait_cnt) begin
                if (wait_cnt == 6 + 0) begin
                    process_even <= 0;
                    wait_cnt <= 0;
                end
                else wait_cnt <= wait_cnt + 1;
            end
        end

        if (process_odd_sig | process_even_sig) begin
            addrb <= 6'b111111;
            dinb <= 32'h0;
            web <= 0;
            // if (process_odd) write_wait <= 1;
            // if (process_even) write_wait <= 1;
            write_wait <= 1;
            write_cnt <= 0;
        end
        // else if (writeback_odd | writeback_even) begin
        // end
        // handle write to buffer
        else if (write_wait) begin
            if (write_wait == 6 + 3) begin
                write_wait <= 0;
                do_write <= 1;
            end
            else write_wait <= write_wait + 1;
        end
        else if (do_write) begin
            if (write_cnt == 16'b1000000) begin
                do_write <= 0;
                // move on to writeback_odd or writeback_even
                write_cnt <= 0;
                web <= 0;
                addrb <= 6'b000000;
                if (in_odd) begin
                    writeback_odd <= 1;
                    wodd_ready_n <= 1;
                    addro <= 6'b111111;
                end
                else if (in_even) begin
                    writeback_even <= 1;
                    weven_ready_n <= 1;
                    addre <= 6'b111111;
                end
            end
            else begin
                write_cnt <= write_cnt + 1;
                addrb <= addrb + 1;
                web <= 1;
                // use the log RNG to accept or reject
                // signed number comparison
                if (rnglog > o) begin
                    dinb <= x_acc_6;
                    mul_in_a <= x_acc_6;
                    accept <= 1;
                end
                else begin
                    dinb <= x_rej_6;
                    mul_in_a <= x_rej_6;
                    accept <= 0;
                end
            end
        end
    end
end

// always @ (*) begin
//     if (process_odd | process_even | writeback_even | writeback_odd) begin
//         // addro <= addro1;
//         // addre <= addre1;
//     end
//     else if (do_write) begin
//         // addro <= addro2;
//         // addre <= addre2;
//     end
// end

// always @ (*) begin
//     if (write_wait) begin
//     end
//     if (do_write) begin
//         // write_cnt <= write_cnt2;
//         // addrb <= addrb2;
//     end
//     else if (process_odd | process_even) begin
//         // addrb <= addrb3;
//         // write_cnt <= write_cnt3;
//     end
//     else if (writeback_even | writeback_odd) begin
//         // addrb <= addrb1;
//         // write_cnt <= write_cnt1;
//     end
// end

// always @ (posedge clk) begin
//     if (rst_flag) begin
//     end
// end


// always @ (posedge clk) begin
// end


// always @ (posedge clk) begin
//     if (finish) begin
//     end
//     else if (rst_flag) begin
//     end
// end

// update x2sum result while write to buffer(web)
always @ (posedge clk) begin
    if (rst_flag) begin
        x2sum <= 0;
        updating <= 0;
        // x4sum <= 0;
    end
    else if (recording) begin
        if (web_old_old) begin
            x2sum <= x2sum + mul_o;
        end
        // if (web) begin
        //     mul_in_a <= dinb;
        //     // mul_in_b <= dinb;
        //     updating <= 1;
        // end
        // else begin
        //     updating <= 0;
        // end
        // if (updating_old) begin
        //     x2sum <= x2sum + mul_o;
        // end
    end
end
always @ (posedge clk) begin
    x2sum_real <= x2sum;
end
endmodule
