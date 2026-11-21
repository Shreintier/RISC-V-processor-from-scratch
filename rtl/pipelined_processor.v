`timescale 1ns / 1ps
// 5-stage pipelined RV32IM processor (IF -> ID -> EX -> MEM -> WB)
module pipelined_processor #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    output [rl_var-1:0] pc_out,
    output [31:0] instruction_out
);
    // IF stage
    reg [rl_var-1:0] pc;
    wire [31:0] if_inst;
    wire pc_write, if_id_write, if_id_flush, id_ex_flush;
    wire ex_branch_taken;
    wire [rl_var-1:0] ex_target_pc;

    // Redirect the PC on a taken branch or jump. Hold it during a stall.
    always @(posedge clk or posedge rst) begin
        if(rst)
            pc <= {rl_var{1'b0}};
        else if(ex_branch_taken)
            pc <= ex_target_pc;
        else if(pc_write)
            pc <= pc + 32'd4;
    end

    instruction_memory #(
        .rl_var(rl_var),
        .addr_var(256)
    ) imem(
        .pc(pc),
        .instruction(if_inst)
    );

    assign pc_out = pc;
    assign instruction_out = if_inst;

    // IF/ID pipeline register
    wire [rl_var-1:0] id_pc, id_pc_plus_4;
    wire [31:0] id_inst;

    if_id_reg #(
        .rl_var(rl_var)
    ) u_if_id(
        .clk(clk),
        .rst(rst),
        .if_id_write(if_id_write),
        .if_id_flush(if_id_flush),
        .if_pc(pc),
        .if_pc_plus_4(pc + 32'd4),
        .if_inst(if_inst),
        .id_pc(id_pc),
        .id_pc_plus_4(id_pc_plus_4),
        .id_inst(id_inst)
    );

    // ID stage
    // Split the instruction into its register numbers and control fields.
    wire [6:0] id_opcode = id_inst[6:0];
    wire [4:0] id_rd = id_inst[11:7];
    wire [2:0] id_funct3 = id_inst[14:12];
    wire [4:0] id_rs1 = id_inst[19:15];
    wire [4:0] id_rs2 = id_inst[24:20];
    wire [6:0] id_funct7 = id_inst[31:25];

    wire id_reg_write, id_mem_read, id_mem_write;
    wire id_branch, id_jump, id_jalr, id_alu_src;
    wire [1:0] id_alu_op, id_mem_to_reg, id_alu_src_a;

    // This opcode and funct7 identify multiply and divide instructions.
    wire id_is_m_op = (id_opcode == 7'b0110011) && (id_funct7 == 7'b0000001);

    control_a u_ctrl_a(
        .opcode(id_opcode),
        .reg_write(id_reg_write),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .branch(id_branch),
        .jump(id_jump),
        .jalr(id_jalr),
        .alu_src(id_alu_src),
        .alu_src_a(id_alu_src_a),
        .alu_op(id_alu_op)
    );

    wire [rl_var-1:0] id_imm;
    imm_gen #(
        .rl_var(rl_var)
    ) u_imm_gen(
        .inst(id_inst),
        .imm(id_imm)
    );

    wire wb_reg_write;
    wire [4:0] wb_rd;
    wire [rl_var-1:0] wb_wdata;
    wire [rl_var-1:0] id_reg1, id_reg2;

    regfile #(
        .rl_var(rl_var)
    ) rf(
        .clk(clk),
        .rst(rst),
        .reg_write(wb_reg_write),
        .read_reg1(id_rs1),
        .read_reg2(id_rs2),
        .write_reg(wb_rd),
        .write_data(wb_wdata),
        .data_reg1(id_reg1),
        .data_reg2(id_reg2)
    );

    wire ex_mem_read;
    wire [4:0] ex_rd;

    hazard_detection_unit u_hdu(
        .id_ex_mem_read(ex_mem_read),
        .id_ex_rd(ex_rd),
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .if_id_opcode(id_opcode),
        .ex_pc_src(ex_branch_taken),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .if_id_flush(if_id_flush),
        .id_ex_flush(id_ex_flush)
    );

    // ID/EX pipeline register
    wire ex_reg_write, ex_mem_write;
    wire ex_branch, ex_jump, ex_jalr, ex_alu_src, ex_is_m_op;
    wire [3:0] ex_alu_ctrl;
    wire [1:0] ex_mem_to_reg, ex_alu_src_a, ex_alu_op;
    wire ex_funct7_5;
    wire [2:0] ex_funct3;
    wire [rl_var-1:0] ex_pc, ex_pc_plus_4, ex_reg1, ex_reg2, ex_imm;
    wire [4:0] ex_rs1, ex_rs2;

    id_ex_reg #(
        .rl_var(rl_var)
    ) u_id_ex(
        .clk(clk),
        .rst(rst),
        .id_ex_flush(id_ex_flush),
        .id_reg_write(id_reg_write),
        .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_jalr(id_jalr),
        .id_alu_src(id_alu_src),
        .id_alu_src_a(id_alu_src_a),
        .id_is_m_op(id_is_m_op),
        .id_alu_op(id_alu_op),
        .id_funct3(id_funct3),
        .id_funct7_5(id_funct7[5]),
        .id_pc(id_pc),
        .id_pc_plus_4(id_pc_plus_4),
        .id_data_reg1(id_reg1),
        .id_data_reg2(id_reg2),
        .id_imm(id_imm),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_rd),
        .ex_reg_write(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_jalr(ex_jalr),
        .ex_alu_src(ex_alu_src),
        .ex_alu_src_a(ex_alu_src_a),
        .ex_is_m_op(ex_is_m_op),
        .ex_alu_op(ex_alu_op),
        .ex_funct3(ex_funct3),
        .ex_funct7_5(ex_funct7_5),
        .ex_pc(ex_pc),
        .ex_pc_plus_4(ex_pc_plus_4),
        .ex_data_reg1(ex_reg1),
        .ex_data_reg2(ex_reg2),
        .ex_imm(ex_imm),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd)
    );

    // EX stage
    control_b u_ctrl_b(
        .alu_op(ex_alu_op),
        .funct3(ex_funct3),
        .funct7_5(ex_funct7_5),
        .alu_control(ex_alu_ctrl)
    );

    wire mem_reg_write;
    wire [4:0] mem_rd;
    wire [rl_var-1:0] mem_alu_result;
    wire [1:0] forward_a, forward_b;
    wire [rl_var-1:0] mem_forward_data;

    forwarding_unit u_fwd(
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd),
        .ex_mem_reg_write(mem_reg_write),
        .mem_wb_rd(wb_rd),
        .mem_wb_reg_write(wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // Use a newer result from MEM or WB when EX needs it.
    wire [rl_var-1:0] fwd_a = (forward_a == 2'b10) ? mem_forward_data :
                              ((forward_a == 2'b01) ? wb_wdata : ex_reg1);
    wire [rl_var-1:0] fwd_b = (forward_b == 2'b10) ? mem_forward_data :
                              ((forward_b == 2'b01) ? wb_wdata : ex_reg2);

    wire [rl_var-1:0] alu_in1 = (ex_alu_src_a == 2'b10) ? {rl_var{1'b0}} :
                                ((ex_alu_src_a == 2'b01) ? ex_pc : fwd_a);
    wire [rl_var-1:0] alu_in2 = ex_alu_src ? ex_imm : fwd_b;

    wire [rl_var-1:0] alu_result;

    alu #(
        .rl_var(rl_var)
    ) u_alu(
        .a(alu_in1),
        .b(alu_in2),
        .op(ex_alu_ctrl),
        .y(alu_result)
    );

    // Multiply and divide use the forwarded register values.
    wire [rl_var-1:0] m_result;

    mul_div_unit #(
        .rl_var(rl_var)
    ) u_mul_div(
        .a(fwd_a),
        .b(fwd_b),
        .funct3(ex_funct3),
        .result(m_result)
    );

    wire [rl_var-1:0] ex_result = ex_is_m_op ? m_result : alu_result;

    // Compare the forwarded values for a branch.
    reg branch_cond;
    always @(*) begin
        case(ex_funct3)
            3'b000: branch_cond = (fwd_a == fwd_b); // BEQ
            3'b001: branch_cond = (fwd_a != fwd_b); // BNE
            3'b100: branch_cond = ($signed(fwd_a) < $signed(fwd_b)); // BLT
            3'b101: branch_cond = ($signed(fwd_a) >= $signed(fwd_b)); // BGE
            3'b110: branch_cond = (fwd_a < fwd_b); // BLTU
            3'b111: branch_cond = (fwd_a >= fwd_b); // BGEU
            default: branch_cond = 1'b0;
        endcase
    end

    assign ex_branch_taken = ex_jump || ex_jalr || (ex_branch && branch_cond);
    assign ex_target_pc = ex_jalr ? ((fwd_a + ex_imm) & ~32'd1) : (ex_pc + ex_imm);

    // EX/MEM pipeline register
    wire mem_read, mem_write;
    wire [1:0] mem_to_reg;
    wire [rl_var-1:0] mem_pc_plus_4;
    assign mem_forward_data = (mem_to_reg == 2'b10) ? mem_pc_plus_4 : mem_alu_result;
    wire [2:0] mem_funct3;
    wire [rl_var-1:0] mem_write_data;

    ex_mem_reg #(
        .rl_var(rl_var)
    ) u_ex_mem(
        .clk(clk),
        .rst(rst),
        .ex_reg_write(ex_reg_write),
        .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_funct3(ex_funct3),
        .ex_alu_result(ex_result),
        .ex_pc_plus_4(ex_pc_plus_4),
        .ex_write_data(fwd_b),
        .ex_rd(ex_rd),
        .mem_reg_write(mem_reg_write),
        .mem_mem_read(mem_read),
        .mem_mem_write(mem_write),
        .mem_mem_to_reg(mem_to_reg),
        .mem_funct3(mem_funct3),
        .mem_alu_result(mem_alu_result),
        .mem_pc_plus_4(mem_pc_plus_4),
        .mem_write_data(mem_write_data),
        .mem_rd(mem_rd)
    );

    // MEM stage
    wire [rl_var-1:0] mem_read_data;

    data_memory #(
        .rl_var(rl_var),
        .bytes(4096)
    ) dmem(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(mem_funct3),
        .addr(mem_alu_result),
        .write_data(mem_write_data),
        .read_data(mem_read_data)
    );

    // MEM/WB pipeline register
    wire [1:0] wb_mem_to_reg;
    wire [rl_var-1:0] wb_alu_result, wb_pc_plus_4;

    mem_wb_reg #(
        .rl_var(rl_var)
    ) u_mem_wb(
        .clk(clk),
        .rst(rst),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_to_reg),
        .mem_alu_result(mem_alu_result),
        .mem_pc_plus_4(mem_pc_plus_4),
        .mem_read_data({rl_var{1'b0}}),
        .mem_rd(mem_rd),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_alu_result(wb_alu_result),
        .wb_read_data(),
        .wb_pc_plus_4(wb_pc_plus_4),
        .wb_rd(wb_rd)
    );

    // WB stage
    // Memory already saves the load result on the WB clock edge.
    assign wb_wdata = (wb_mem_to_reg == 2'b01) ? mem_read_data :
                      ((wb_mem_to_reg == 2'b10) ? wb_pc_plus_4 : wb_alu_result);
endmodule
