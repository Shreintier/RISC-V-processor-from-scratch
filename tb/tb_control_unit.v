`timescale 1ns / 1ps
module tb_control_unit;
    reg [6:0] opcode;
    wire branch, jump, jalr, mem_read, mem_write, alu_src, reg_write;
    wire [1:0] mem_to_reg, alu_op, alu_src_a;
    reg [1:0] op_in;
    reg [2:0] funct3;
    reg funct7_5;
    wire [3:0] alu_ctrl;
    integer err = 0;
    control_a u_a(
        .opcode(opcode), .branch(branch), .jump(jump), .jalr(jalr),
        .mem_read(mem_read), .mem_to_reg(mem_to_reg), .alu_op(alu_op),
        .mem_write(mem_write), .alu_src_a(alu_src_a), .alu_src(alu_src),
        .reg_write(reg_write)
    );
    control_b u_b(
        .alu_op(op_in), .funct3(funct3), .funct7_5(funct7_5), .alu_control(alu_ctrl)
    );
    initial begin
        opcode = 7'b0110011; #1;
        if(!reg_write || alu_src || alu_op !== 2'b10) err = err + 1;
        opcode = 7'b0000011; #1;
        if(!mem_read || !reg_write || mem_to_reg !== 2'b01) err = err + 1;
        opcode = 7'b0100011; #1;
        if(!mem_write || reg_write) err = err + 1;
        opcode = 7'b1100011; #1;
        if(!branch || alu_op !== 2'b01) err = err + 1;
        opcode = 7'b1101111; #1;
        if(!jump || !reg_write || mem_to_reg !== 2'b10) err = err + 1;
        opcode = 7'b0110111; #1;
        if(!reg_write || alu_src_a !== 2'b10 || !alu_src) err = err + 1;
        op_in = 2'b10; funct3 = 3'b000; funct7_5 = 1'b1; #1;
        if(alu_ctrl !== 4'b0110) err = err + 1;
        op_in = 2'b11; funct3 = 3'b000; funct7_5 = 1'b1; #1;
        if(alu_ctrl !== 4'b0010) err = err + 1;
        if(err == 0)
            $display("pass tb_control_unit");
        else
            $display("fail tb_control_unit (%0d)", err);
        $finish;
    end
endmodule
