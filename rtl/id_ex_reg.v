`timescale 1ns / 1ps
module id_ex_reg #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    input id_ex_flush,
    input id_branch,
    input id_jump,
    input id_jalr,
    input id_mem_read,
    input [1:0] id_mem_to_reg,
    input [1:0] id_alu_op,
    input id_mem_write,
    input [1:0] id_alu_src_a,
    input id_alu_src,
    input id_reg_write,
    input [rl_var-1:0] id_pc,
    input [rl_var-1:0] id_pc_plus_4,
    input [rl_var-1:0] id_data_reg1,
    input [rl_var-1:0] id_data_reg2,
    input [rl_var-1:0] id_imm,
    input [4:0] id_rs1,
    input [4:0] id_rs2,
    input [4:0] id_rd,
    input [2:0] id_funct3,
    input id_funct7_5,
    output reg ex_branch,
    output reg ex_jump,
    output reg ex_jalr,
    output reg ex_mem_read,
    output reg [1:0] ex_mem_to_reg,
    output reg [1:0] ex_alu_op,
    output reg ex_mem_write,
    output reg [1:0] ex_alu_src_a,
    output reg ex_alu_src,
    output reg ex_reg_write,
    output reg [rl_var-1:0] ex_pc,
    output reg [rl_var-1:0] ex_pc_plus_4,
    output reg [rl_var-1:0] ex_data_reg1,
    output reg [rl_var-1:0] ex_data_reg2,
    output reg [rl_var-1:0] ex_imm,
    output reg [4:0] ex_rs1,
    output reg [4:0] ex_rs2,
    output reg [4:0] ex_rd,
    output reg [2:0] ex_funct3,
    output reg ex_funct7_5
);
    always@(posedge clk or posedge rst) begin
        if(rst || id_ex_flush) begin
            ex_branch <= 1'b0;
            ex_jump <= 1'b0;
            ex_jalr <= 1'b0;
            ex_mem_read <= 1'b0;
            ex_mem_to_reg <= 2'b00;
            ex_alu_op <= 2'b00;
            ex_mem_write <= 1'b0;
            ex_alu_src_a <= 2'b00;
            ex_alu_src <= 1'b0;
            ex_reg_write <= 1'b0;
            ex_pc <= {rl_var{1'b0}};
            ex_pc_plus_4 <= {rl_var{1'b0}};
            ex_data_reg1 <= {rl_var{1'b0}};
            ex_data_reg2 <= {rl_var{1'b0}};
            ex_imm <= {rl_var{1'b0}};
            ex_rs1 <= 5'd0;
            ex_rs2 <= 5'd0;
            ex_rd <= 5'd0;
            ex_funct3 <= 3'd0;
            ex_funct7_5 <= 1'b0;
        end else begin
            ex_branch <= id_branch;
            ex_jump <= id_jump;
            ex_jalr <= id_jalr;
            ex_mem_read <= id_mem_read;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_alu_op <= id_alu_op;
            ex_mem_write <= id_mem_write;
            ex_alu_src_a <= id_alu_src_a;
            ex_alu_src <= id_alu_src;
            ex_reg_write <= id_reg_write;
            ex_pc <= id_pc;
            ex_pc_plus_4 <= id_pc_plus_4;
            ex_data_reg1 <= id_data_reg1;
            ex_data_reg2 <= id_data_reg2;
            ex_imm <= id_imm;
            ex_rs1 <= id_rs1;
            ex_rs2 <= id_rs2;
            ex_rd <= id_rd;
            ex_funct3 <= id_funct3;
            ex_funct7_5 <= id_funct7_5;
        end
    end
endmodule
