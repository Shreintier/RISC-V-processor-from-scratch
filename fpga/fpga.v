`timescale 1ns / 1ps
module fpga_top(
    input clk,
    input [15:0] sw,
    input [3:0] btn,
    output [15:0] led,
    output [2:0] RGB0,
    output [2:0] RGB1,
    output [3:0] D0_AN,
    output [7:0] D0_SEG,
    output [3:0] D1_AN,
    output [7:0] D1_SEG
);
    reg [25:0] cnt = 26'd0;
    reg [19:0] db_cnt = 20'd0;
    reg btn1_sync = 1'b0;
    reg btn1_stable = 1'b0;
    reg btn1_prev = 1'b0;
    reg cpu_clk_reg = 1'b0;
    wire cpu_clk;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;
    wire [31:0] dbg_data;
    always@(posedge clk) begin
        cnt <= cnt + 26'd1;
        btn1_sync <= btn[1];
        if(btn1_sync != btn1_stable) begin
            db_cnt <= db_cnt + 20'd1;
            if(db_cnt == 20'hfffff) begin
                btn1_stable <= btn1_sync;
                db_cnt <= 20'd0;
            end
        end else begin
            db_cnt <= 20'd0;
        end
        btn1_prev <= btn1_stable;
        if(sw[15])
            cpu_clk_reg <= cnt[25];
        else
            cpu_clk_reg <= (btn1_stable && !btn1_prev);
    end
    BUFG u_clk_buf(.I(cpu_clk_reg), .O(cpu_clk));
    pipelined_processor #(.rl_var(32)) cpu(
        .clk(cpu_clk),
        .rst(btn[0]),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );
    assign dbg_data = sw[13] ? instruction_out : pc_out;
    assign led = sw[14] ? instruction_out[15:0] : pc_out[15:0];
    assign RGB0 = btn[0] ? 3'b001 : (sw[15] ? 3'b010 : 3'b100);
    assign RGB1 = {1'b0, cpu_clk_reg, 1'b0};
    function [7:0] hex_to_seg(input [3:0] val);
        case(val)
            4'h0: hex_to_seg = 8'hc0;
            4'h1: hex_to_seg = 8'hf9;
            4'h2: hex_to_seg = 8'ha4;
            4'h3: hex_to_seg = 8'hb0;
            4'h4: hex_to_seg = 8'h99;
            4'h5: hex_to_seg = 8'h92;
            4'h6: hex_to_seg = 8'h82;
            4'h7: hex_to_seg = 8'hf8;
            4'h8: hex_to_seg = 8'h80;
            4'h9: hex_to_seg = 8'h90;
            4'ha: hex_to_seg = 8'h88;
            4'hb: hex_to_seg = 8'h83;
            4'hc: hex_to_seg = 8'hc6;
            4'hd: hex_to_seg = 8'ha1;
            4'he: hex_to_seg = 8'h86;
            4'hf: hex_to_seg = 8'h8e;
        endcase
    endfunction
    wire [1:0] digit_sel = cnt[17:16];
    reg [3:0] an_mask;
    reg [3:0] nib_d0;
    reg [3:0] nib_d1;
    always@(*) begin
        case(digit_sel)
            2'd0: begin
                an_mask = 4'b1110;
                nib_d0 = dbg_data[3:0];
                nib_d1 = dbg_data[19:16];
            end
            2'd1: begin
                an_mask = 4'b1101;
                nib_d0 = dbg_data[7:4];
                nib_d1 = dbg_data[23:20];
            end
            2'd2: begin
                an_mask = 4'b1011;
                nib_d0 = dbg_data[11:8];
                nib_d1 = dbg_data[27:24];
            end
            2'd3: begin
                an_mask = 4'b0111;
                nib_d0 = dbg_data[15:12];
                nib_d1 = dbg_data[31:28];
            end
        endcase
    end
    assign D0_AN = an_mask;
    assign D1_AN = an_mask;
    assign D0_SEG = hex_to_seg(nib_d0);
    assign D1_SEG = hex_to_seg(nib_d1);
endmodule