`timescale 1ns / 1ps
module pipelined_processor #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    output [rl_var-1:0] pc_out,
    output [31:0] instruction_out
);
    reg [rl_var-1:0] pc;
    wire [rl_var-1:0] pc_next;
    wire [rl_var-1:0] if_pc4;
    wire [31:0] if_inst;
    wire pc_write;
    wire if_id_write;
    wire if_id_flush;
    wire id_ex_flush;
    assign if_pc4 = pc + {{(rl_var-3){1'b0}}, 3'd4};
    assign pc_out = pc;
    assign instruction_out = if_inst;
    always@(posedge clk or posedge rst) begin
        if(rst)
            pc <= {rl_var{1'b0}};
        else if(pc_write)
            pc <= pc_next;
    end
    instruction_memory #(
        .rl_var(rl_var)
    ) imem(
        .addr(pc),
        .inst(if_inst)
    );
    wire [rl_var-1:0] id_pc;
    wire [rl_var-1:0] id_pc4;
    wire [31:0] id_inst;
    if_id_reg #(
        .rl_var(rl_var)
    ) pipe_if_id(
        .clk(clk),
        .rst(rst),
        .if_id_write(if_id_write),
        .if_id_flush(if_id_flush),
        .if_pc(pc),
        .if_pc_plus_4(if_pc4),
        .if_inst(if_inst),
        .id_pc(id_pc),
        .id_pc_plus_4(id_pc4),
        .id_inst(id_inst)
    );
    wire [6:0] id_opcode = id_inst[6:0];
    wire [4:0] id_rs1 = id_inst[19:15];
    wire [4:0] id_rs2 = id_inst[24:20];
    wire id_branch;
    wire id_jump;
    wire id_jalr;
    wire id_mem_read;
    wire [1:0] id_mem_to_reg;
    wire [1:0] id_alu_op;
    wire id_mem_write;
    wire [1:0] id_alu_src_a;
    wire id_alu_src;
    wire id_reg_write;
    wire [rl_var-1:0] id_imm;
    wire [rl_var-1:0] id_reg1;
    wire [rl_var-1:0] id_reg2;
    wire [4:0] wb_rd;
    wire [rl_var-1:0] wb_wdata;
    wire wb_reg_write;
    control_a ctrl_main(
        .opcode(id_opcode),
        .branch(id_branch),
        .jump(id_jump),
        .jalr(id_jalr),
        .mem_read(id_mem_read),
        .mem_to_reg(id_mem_to_reg),
        .alu_op(id_alu_op),
        .mem_write(id_mem_write),
        .alu_src_a(id_alu_src_a),
        .alu_src(id_alu_src),
        .reg_write(id_reg_write)
    );
    imm_gen #(
        .rl_var(rl_var)
    ) ig(
        .inst(id_inst),
        .imm(id_imm)
    );
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
    wire ex_branch;
    wire ex_jump;
    wire ex_jalr;
    wire ex_mem_read;
    wire [1:0] ex_mem_to_reg;
    wire [1:0] ex_alu_op;
    wire ex_mem_write;
    wire [1:0] ex_alu_src_a;
    wire ex_alu_src;
    wire ex_reg_write;
    wire [rl_var-1:0] ex_pc;
    wire [rl_var-1:0] ex_pc4;
    wire [rl_var-1:0] ex_reg1;
    wire [rl_var-1:0] ex_reg2;
    wire [rl_var-1:0] ex_imm;
    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;
    wire [4:0] ex_rd;
    wire [2:0] ex_funct3;
    wire ex_funct7_5;
    id_ex_reg #(
        .rl_var(rl_var)
    ) pipe_id_ex(
        .clk(clk),
        .rst(rst),
        .id_ex_flush(id_ex_flush),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_jalr(id_jalr),
        .id_mem_read(id_mem_read),
        .id_mem_to_reg(id_mem_to_reg),
        .id_alu_op(id_alu_op),
        .id_mem_write(id_mem_write),
        .id_alu_src_a(id_alu_src_a),
        .id_alu_src(id_alu_src),
        .id_reg_write(id_reg_write),
        .id_pc(id_pc),
        .id_pc_plus_4(id_pc4),
        .id_data_reg1(id_reg1),
        .id_data_reg2(id_reg2),
        .id_imm(id_imm),
        .id_rs1(id_rs1),
        .id_rs2(id_rs2),
        .id_rd(id_inst[11:7]),
        .id_funct3(id_inst[14:12]),
        .id_funct7_5(id_inst[30]),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_jalr(ex_jalr),
        .ex_mem_read(ex_mem_read),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_alu_op(ex_alu_op),
        .ex_mem_write(ex_mem_write),
        .ex_alu_src_a(ex_alu_src_a),
        .ex_alu_src(ex_alu_src),
        .ex_reg_write(ex_reg_write),
        .ex_pc(ex_pc),
        .ex_pc_plus_4(ex_pc4),
        .ex_data_reg1(ex_reg1),
        .ex_data_reg2(ex_reg2),
        .ex_imm(ex_imm),
        .ex_rs1(ex_rs1),
        .ex_rs2(ex_rs2),
        .ex_rd(ex_rd),
        .ex_funct3(ex_funct3),
        .ex_funct7_5(ex_funct7_5)
    );
    wire [1:0] forward_a;
    wire [1:0] forward_b;
    wire [3:0] ex_alu_ctrl;
    wire [rl_var-1:0] mux_rs1;
    wire [rl_var-1:0] mux_rs2;
    wire [rl_var-1:0] alu_in_a;
    wire [rl_var-1:0] alu_in_b;
    wire [rl_var-1:0] ex_alu_res;
    wire mem_mem_read;
    wire [1:0] mem_mem_to_reg;
    wire mem_mem_write;
    wire mem_reg_write;
    wire [rl_var-1:0] mem_pc4;
    wire [rl_var-1:0] mem_alu_res;
    wire [rl_var-1:0] mem_wdata;
    wire [4:0] mem_rd;
    wire [2:0] mem_funct3;
    forwarding_unit fwd(
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd),
        .ex_mem_reg_write(mem_reg_write),
        .mem_wb_rd(wb_rd),
        .mem_wb_reg_write(wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    assign mux_rs1 = (forward_a == 2'b10) ? mem_alu_res :
                     ((forward_a == 2'b01) ? wb_wdata : ex_reg1);
    assign mux_rs2 = (forward_b == 2'b10) ? mem_alu_res :
                     ((forward_b == 2'b01) ? wb_wdata : ex_reg2);
    assign alu_in_a = (ex_alu_src_a == 2'b01) ? ex_pc :
                      ((ex_alu_src_a == 2'b10) ? {rl_var{1'b0}} : mux_rs1);
    assign alu_in_b = ex_alu_src ? ex_imm : mux_rs2;
    control_b ctrl_alu(
        .alu_op(ex_alu_op),
        .funct3(ex_funct3),
        .funct7_5(ex_funct7_5),
        .alu_control(ex_alu_ctrl)
    );
    alu #(
        .rl_var(rl_var)
    ) alu_core(
        .a(alu_in_a),
        .b(alu_in_b),
        .op(ex_alu_ctrl),
        .y(ex_alu_res)
    );
    reg br_taken;
    always@(*) begin
        br_taken = 1'b0;
        if(ex_branch) begin
            case(ex_funct3)
                3'b000: br_taken = (mux_rs1 == mux_rs2);
                3'b001: br_taken = (mux_rs1 != mux_rs2);
                3'b100: br_taken = ($signed(mux_rs1) < $signed(mux_rs2));
                3'b101: br_taken = ($signed(mux_rs1) >= $signed(mux_rs2));
                3'b110: br_taken = (mux_rs1 < mux_rs2);
                3'b111: br_taken = (mux_rs1 >= mux_rs2);
                default: br_taken = 1'b0;
            endcase
        end
    end
    wire pc_sel = (ex_branch && br_taken) || ex_jump || ex_jalr;
    assign pc_next = ex_jalr ? ((mux_rs1 + ex_imm) & {{(rl_var-1){1'b1}}, 1'b0}) :
                     (pc_sel ? (ex_pc + ex_imm) : if_pc4);
    hazard_detection_unit hdu(
        .id_ex_mem_read(ex_mem_read),
        .id_ex_rd(ex_rd),
        .if_id_opcode(id_opcode),
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .ex_pc_src(pc_sel),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .if_id_flush(if_id_flush),
        .id_ex_flush(id_ex_flush)
    );
    ex_mem_reg #(
        .rl_var(rl_var)
    ) pipe_ex_mem(
        .clk(clk),
        .rst(rst),
        .ex_mem_read(ex_mem_read),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_write(ex_mem_write),
        .ex_reg_write(ex_reg_write),
        .ex_pc_plus_4(ex_pc4),
        .ex_alu_result(ex_alu_res),
        .ex_write_data(mux_rs2),
        .ex_rd(ex_rd),
        .ex_funct3(ex_funct3),
        .mem_mem_read(mem_mem_read),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_mem_write(mem_mem_write),
        .mem_reg_write(mem_reg_write),
        .mem_pc_plus_4(mem_pc4),
        .mem_alu_result(mem_alu_res),
        .mem_write_data(mem_wdata),
        .mem_rd(mem_rd),
        .mem_funct3(mem_funct3)
    );
    wire [rl_var-1:0] mem_rdata;
    data_memory #(
        .rl_var(rl_var)
    ) dmem(
        .clk(clk),
        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),
        .addr(mem_alu_res),
        .write_data(mem_wdata),
        .funct3(mem_funct3),
        .read_data(mem_rdata)
    );
    wire [1:0] wb_mem_to_reg;
    wire [rl_var-1:0] wb_pc4;
    wire [rl_var-1:0] wb_rdata;
    wire [rl_var-1:0] wb_alu_res;
    mem_wb_reg #(
        .rl_var(rl_var)
    ) pipe_mem_wb(
        .clk(clk),
        .rst(rst),
        .mem_mem_to_reg(mem_mem_to_reg),
        .mem_reg_write(mem_reg_write),
        .mem_pc_plus_4(mem_pc4),
        .mem_read_data(mem_rdata),
        .mem_alu_result(mem_alu_res),
        .mem_rd(mem_rd),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_reg_write(wb_reg_write),
        .wb_pc_plus_4(wb_pc4),
        .wb_read_data(wb_rdata),
        .wb_alu_result(wb_alu_res),
        .wb_rd(wb_rd)
    );
    assign wb_wdata = (wb_mem_to_reg == 2'b01) ? wb_rdata :
                      ((wb_mem_to_reg == 2'b10) ? wb_pc4 : wb_alu_res);
endmodule
