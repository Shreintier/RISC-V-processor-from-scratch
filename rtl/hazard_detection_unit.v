`timescale 1ns / 1ps
module hazard_detection_unit(
    input id_ex_mem_read,
    input [4:0] id_ex_rd,
    input [6:0] if_id_opcode,
    input [4:0] if_id_rs1,
    input [4:0] if_id_rs2,
    input ex_pc_src,
    output reg pc_write,
    output reg if_id_write,
    output reg if_id_flush,
    output reg id_ex_flush
);
    reg uses_rs1;
    reg uses_rs2;
    always@(*) begin
        case(if_id_opcode)
            7'b0110011,
            7'b0100011,
            7'b1100011: begin
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b1;
            end
            7'b0010011,
            7'b0000011,
            7'b1100111: begin
                uses_rs1 = 1'b1;
                uses_rs2 = 1'b0;
            end
            default: begin
                uses_rs1 = 1'b0;
                uses_rs2 = 1'b0;
            end
        endcase
    end
    always@(*) begin
        pc_write = 1'b1;
        if_id_write = 1'b1;
        if_id_flush = 1'b0;
        id_ex_flush = 1'b0;
        if(ex_pc_src) begin
            if_id_flush = 1'b1;
            id_ex_flush = 1'b1;
        end else if(id_ex_mem_read && (id_ex_rd != 5'd0) &&
                    ((uses_rs1 && (id_ex_rd == if_id_rs1)) ||
                     (uses_rs2 && (id_ex_rd == if_id_rs2)))) begin
            pc_write = 1'b0;
            if_id_write = 1'b0;
            id_ex_flush = 1'b1;
        end
    end
endmodule
