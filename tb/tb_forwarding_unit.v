`timescale 1ns / 1ps
module tb_forwarding_unit;
    reg [4:0] rs1, rs2, mem_rd, wb_rd;
    reg mem_we, wb_we;
    wire [1:0] fa, fb;
    integer err = 0;
    forwarding_unit dut(
        .id_ex_rs1(rs1), .id_ex_rs2(rs2),
        .ex_mem_rd(mem_rd), .ex_mem_reg_write(mem_we),
        .mem_wb_rd(wb_rd), .mem_wb_reg_write(wb_we),
        .forward_a(fa), .forward_b(fb)
    );
    initial begin
        rs1 = 5'd3; rs2 = 5'd4;
        mem_rd = 5'd3; mem_we = 1;
        wb_rd = 5'd3; wb_we = 1;
        #1;
        if(fa !== 2'b10 || fb !== 2'b00) err = err + 1;
        wb_rd = 5'd4; #1;
        if(fb !== 2'b01) err = err + 1;
        rs1 = 5'd0; mem_rd = 5'd0; wb_rd = 5'd0; #1;
        if(fa !== 2'b00) err = err + 1;
        if(err == 0)
            $display("pass tb_forwarding_unit");
        else
            $display("fail tb_forwarding_unit (%0d)", err);
        $finish;
    end
endmodule
