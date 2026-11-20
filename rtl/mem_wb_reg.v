`timescale 1ns / 1ps
module mem_wb_reg #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    input [1:0] mem_mem_to_reg,
    input mem_reg_write,
    input [rl_var-1:0] mem_pc_plus_4,
    input [rl_var-1:0] mem_read_data,
    input [rl_var-1:0] mem_alu_result,
    input [4:0] mem_rd,
    output reg [1:0] wb_mem_to_reg,
    output reg wb_reg_write,
    output reg [rl_var-1:0] wb_pc_plus_4,
    output reg [rl_var-1:0] wb_read_data,
    output reg [rl_var-1:0] wb_alu_result,
    output reg [4:0] wb_rd
);
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            wb_mem_to_reg <= 2'b00;
            wb_reg_write <= 1'b0;
            wb_pc_plus_4 <= {rl_var{1'b0}};
            wb_read_data <= {rl_var{1'b0}};
            wb_alu_result <= {rl_var{1'b0}};
            wb_rd <= 5'd0;
        end else begin
            wb_mem_to_reg <= mem_mem_to_reg;
            wb_reg_write <= mem_reg_write;
            wb_pc_plus_4 <= mem_pc_plus_4;
            wb_read_data <= mem_read_data;
            wb_alu_result <= mem_alu_result;
            wb_rd <= mem_rd;
        end
    end
endmodule
