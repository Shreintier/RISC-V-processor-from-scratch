`timescale 1ns / 1ps

module tb_controlUnit;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg funct7_5;

    wire branch;
    wire jump;
    wire jalr;
    wire mem_read;
    wire [1:0] mem_to_reg;
    wire [1:0] alu_op;
    wire mem_write;
    wire [1:0] alu_src_a;
    wire alu_src;
    wire reg_write;
    wire [3:0] alu_control;

    control_a uut_control_a (
        .opcode(opcode),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src_a(alu_src_a),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    control_b uut_control_b (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .alu_control(alu_control)
    );

    task test_inst(
        input [8*10:1] inst_name,
        input [6:0] op,
        input [2:0] f3,
        input f75
    );
        begin
            opcode = op;
            funct3 = f3;
            funct7_5 = f75;
            #10;
            $display("%-10s | %b | %b %b | %b | %b %b %b %b %b %b | %b %b %b | %b",
                     inst_name, opcode, funct3, funct7_5, alu_op,
                     reg_write, alu_src, alu_src_a, mem_read, mem_write, mem_to_reg,
                     branch, jump, jalr, alu_control);
        end
    endtask

    initial begin
        
        $dumpfile("waves/control_Unit.vcd");
        $dumpvars(0, tb_controlUnit);

        $display("Inst       | Opcode  | f3 f75 | ALUOp| RegW ALUSrc SrcA MemR MemW Mem2Reg | Br Jmp JALR | ALU_Ctrl");
        test_inst("ADD",     7'b0110011, 3'b000, 1'b0);
        test_inst("SUB",     7'b0110011, 3'b000, 1'b1);
        test_inst("SLL",     7'b0110011, 3'b001, 1'b0);
        test_inst("SLT",     7'b0110011, 3'b010, 1'b0);
        test_inst("SLTU",    7'b0110011, 3'b011, 1'b0);
        test_inst("XOR",     7'b0110011, 3'b100, 1'b0);
        test_inst("SRL",     7'b0110011, 3'b101, 1'b0);
        test_inst("SRA",     7'b0110011, 3'b101, 1'b1);
        test_inst("OR",      7'b0110011, 3'b110, 1'b0);
        test_inst("AND",     7'b0110011, 3'b111, 1'b0);
        test_inst("ADDI",    7'b0010011, 3'b000, 1'b0);
        test_inst("XORI",    7'b0010011, 3'b100, 1'b0);
        test_inst("SRAI",    7'b0010011, 3'b101, 1'b1);
        test_inst("LW",      7'b0000011, 3'b010, 1'b0);
        test_inst("SW",      7'b0100011, 3'b010, 1'b0);
        test_inst("BEQ",     7'b1100011, 3'b000, 1'b0);
        test_inst("JAL",     7'b1101111, 3'b000, 1'b0);
        test_inst("JALR",    7'b1100111, 3'b000, 1'b0);
        test_inst("LUI",     7'b0110111, 3'b000, 1'b0);
        test_inst("AUIPC",   7'b0010111, 3'b000, 1'b0);
        test_inst("DEFAULT", 7'b0000000, 3'b000, 1'b0);
        $finish;
    end
endmodule
