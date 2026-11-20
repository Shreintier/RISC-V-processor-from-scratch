`timescale 1ns / 1ps
module tb_pipeline_regs;
    reg clk, rst;
    reg if_id_write, if_id_flush;
    reg [31:0] if_pc, if_pc4, if_inst;
    wire [31:0] id_pc, id_pc4, id_inst;
    integer err = 0;
    if_id_reg #(.rl_var(32)) u_if_id(
        .clk(clk), .rst(rst), .if_id_write(if_id_write), .if_id_flush(if_id_flush),
        .if_pc(if_pc), .if_pc_plus_4(if_pc4), .if_inst(if_inst),
        .id_pc(id_pc), .id_pc_plus_4(id_pc4), .id_inst(id_inst)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0; rst = 1; if_id_write = 1; if_id_flush = 0;
        if_pc = 32'd8; if_pc4 = 32'd12; if_inst = 32'h0010_0093;
        #12 rst = 0;
        @(posedge clk); #1;
        if(id_pc !== 32'd8 || id_inst !== 32'h0010_0093) err = err + 1;
        if_id_write = 0; if_pc = 32'd16; if_inst = 32'h0020_0113;
        @(posedge clk); #1;
        if(id_pc !== 32'd8 || id_inst !== 32'h0010_0093) err = err + 1;
        if_id_write = 1; if_id_flush = 1;
        @(posedge clk); #1;
        if(id_pc !== 32'd0 || id_inst !== 32'd0) err = err + 1;
        if(err == 0)
            $display("pass tb_pipeline_regs");
        else
            $display("fail tb_pipeline_regs (%0d)", err);
        $finish;
    end
endmodule
