`timescale 1ns / 1ps
module ex_mem_reg #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    input ex_mem_read,
    input [1:0] ex_mem_to_reg,
    input ex_mem_write,
    input ex_reg_write,
    input [rl_var-1:0] ex_pc_plus_4,
    input [rl_var-1:0] ex_alu_result,
    input [rl_var-1:0] ex_write_data,
    input [4:0] ex_rd,
    input [2:0] ex_funct3,
    output reg mem_mem_read,
    output reg [1:0] mem_mem_to_reg,
    output reg mem_mem_write,
    output reg mem_reg_write,
    output reg [rl_var-1:0] mem_pc_plus_4,
    output reg [rl_var-1:0] mem_alu_result,
    output reg [rl_var-1:0] mem_write_data,
    output reg [4:0] mem_rd,
    output reg [2:0] mem_funct3
);
    // Pass the result and memory controls from EX to MEM.
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mem_mem_read <= 1'b0;
            mem_mem_to_reg <= 2'b00;
            mem_mem_write <= 1'b0;
            mem_reg_write <= 1'b0;
            mem_pc_plus_4 <= {rl_var{1'b0}};
            mem_alu_result <= {rl_var{1'b0}};
            mem_write_data <= {rl_var{1'b0}};
            mem_rd <= 5'd0;
            mem_funct3 <= 3'd0;
        end else begin
            mem_mem_read <= ex_mem_read;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_mem_write <= ex_mem_write;
            mem_reg_write <= ex_reg_write;
            mem_pc_plus_4 <= ex_pc_plus_4;
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_write_data;
            mem_rd <= ex_rd;
            mem_funct3 <= ex_funct3;
        end
    end
endmodule
