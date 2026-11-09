`timescale 1ns / 1ps

module single_cycle_processor(input clk,input rst, output [31:0] pc_out,
    output [31:0] instruction_out);

    //Program Counter Registers and Wires
    reg  [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;

    assign pc_plus_4= pc + 32'd4;

    //Instruction field extraction
    wire [31:0] inst;
    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire funct7_5 = inst[30];

    assign pc_out = pc;
    assign instruction_out = inst;

    //Control Unit Signals
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

    //Internal datapath
    wire [31:0] imm;
    wire [31:0] data_reg1;
    wire [31:0] data_reg2;
    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] write_back_data;

    reg branch_taken;

    //Sequential program counter update
    always @(posedge clk or posedge rst) begin
        if(rst)
            pc<= 32'b0;
        else
            pc<= pc_next;
    end

    //Instruction Memory
    instruction_memory inst1(.addr(pc),.inst(inst));

    //Main Control Unit
    control_a inst2(
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

    //ALU Control Unit
    control_b inst3(.alu_op(alu_op),.funct3(funct3),.funct7_5(funct7_5),.alu_control(alu_control));

    //Imm_gen
    imm_gen inst4(.inst(inst),.imm(imm));

    //Reg_file
    regfile inst5(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(write_back_data),
        .data_reg1(data_reg1),
        .data_reg2(data_reg2)
    );

    //ALU Operand A-MUX
    // 00 = rs1, 01 = PC (AUIPC), 10 = Zero (LUI)
    assign alu_operand_a =(alu_src_a == 2'b01) ? pc :((alu_src_a == 2'b10) ? 32'b0 :data_reg1);

    //ALU Operand B-MUX
    // 0 = rs2, 1 = Immediate
    assign alu_operand_b = alu_src ? imm : data_reg2;

    //Arithmetic Logic Unit
    alu inst6(.a(alu_operand_a),.b(alu_operand_b),.op(alu_control),.y(alu_result));

    //Data_Memory
    data_memory inst7(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(data_reg2),
        .funct3(funct3),
        .read_data(mem_read_data)
    );

    //write_back-MUX
    // 00 = ALU, 01 = Memory, 10 = PC + 4
    assign write_back_data =(mem_to_reg == 2'b01) ? mem_read_data :((mem_to_reg == 2'b10) ? pc_plus_4 :alu_result);

    //Branch_cases
    always @(*) begin
        branch_taken = 1'b0;
        if(branch) begin
            case(funct3)
                3'b000: branch_taken = (data_reg1 == data_reg2);
                3'b001: branch_taken = (data_reg1 != data_reg2);
                3'b100: branch_taken = ($signed(data_reg1) < $signed(data_reg2));
                3'b101: branch_taken = ($signed(data_reg1) >= $signed(data_reg2));
                3'b110: branch_taken = (data_reg1 < data_reg2);
                3'b111: branch_taken = (data_reg1 >= data_reg2);
                default: branch_taken = 1'b0;
            endcase
        end
    end

    //PC_management
    //Priority: JALR > JAL / Taken Branch > Sequential
    assign pc_next = jalr ? ((data_reg1 + imm) & 32'hFFFFFFFE):(((branch && branch_taken) || jump) ? (pc + imm) :pc_plus_4);
    
endmodule
