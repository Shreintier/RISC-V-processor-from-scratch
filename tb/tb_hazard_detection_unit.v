`timescale 1ns / 1ps
module tb_hazard_detection_unit;
    reg ex_mr, ex_pc_src;
    reg [4:0] ex_rd, id_rs1, id_rs2;
    reg [6:0] id_op;
    wire pc_w, if_id_w, if_id_f, id_ex_f;
    integer err = 0;
    hazard_detection_unit dut(
        .id_ex_mem_read(ex_mr), .id_ex_rd(ex_rd),
        .if_id_opcode(id_op), .if_id_rs1(id_rs1), .if_id_rs2(id_rs2),
        .ex_pc_src(ex_pc_src),
        .pc_write(pc_w), .if_id_write(if_id_w),
        .if_id_flush(if_id_f), .id_ex_flush(id_ex_f)
    );
    initial begin
        ex_mr = 1; ex_rd = 5'd5; id_op = 7'b0110011; id_rs1 = 5'd1; id_rs2 = 5'd5; ex_pc_src = 0;
        #1;
        if(pc_w !== 0 || if_id_w !== 0 || id_ex_f !== 1 || if_id_f !== 0) err = err + 1;
        id_op = 7'b0010011; #1;
        if(pc_w !== 1 || if_id_w !== 1 || id_ex_f !== 0) err = err + 1;
        id_op = 7'b0110011; ex_pc_src = 1; #1;
        if(pc_w !== 1 || if_id_f !== 1 || id_ex_f !== 1) err = err + 1;
        if(err == 0)
            $display("pass tb_hazard_detection_unit");
        else
            $display("fail tb_hazard_detection_unit (%0d)", err);
        $finish;
    end
endmodule
