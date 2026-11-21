`timescale 1ns / 1ps
module if_id_reg #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    input if_id_write,
    input if_id_flush,
    input [rl_var-1:0] if_pc,
    input [rl_var-1:0] if_pc_plus_4,
    input [31:0] if_inst,
    output reg [rl_var-1:0] id_pc,
    output reg [rl_var-1:0] id_pc_plus_4,
    output reg [31:0] id_inst
);
    // Keep the current instruction on a stall and clear it on a flush.
    always @(posedge clk or posedge rst) begin
        if(rst || if_id_flush) begin
            id_pc <= {rl_var{1'b0}};
            id_pc_plus_4 <= {rl_var{1'b0}};
            id_inst <= 32'd0;
        end else if(if_id_write) begin
            id_pc <= if_pc;
            id_pc_plus_4 <= if_pc_plus_4;
            id_inst <= if_inst;
        end
    end
endmodule
