`timescale 1ns / 1ps
module tb_regfile;
    reg clk, rst, reg_write;
    reg [4:0] r1, r2, wr;
    reg [31:0] wd;
    wire [31:0] d1, d2;
    integer err = 0;
    regfile #(.rl_var(32)) dut(
        .clk(clk), .rst(rst), .reg_write(reg_write),
        .read_reg1(r1), .read_reg2(r2), .write_reg(wr),
        .write_data(wd), .data_reg1(d1), .data_reg2(d2)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0; rst = 1; reg_write = 0; r1 = 0; r2 = 0; wr = 0; wd = 0;
        #12 rst = 0;
        reg_write = 1; wr = 5'd4; wd = 32'hdead_beef; r1 = 5'd4;
        #1;
        if(d1 !== 32'hdead_beef) err = err + 1;
        @(posedge clk); #1;
        reg_write = 0;
        if(d1 !== 32'hdead_beef) err = err + 1;
        reg_write = 1; wr = 5'd0; wd = 32'h1234_5678; r2 = 5'd0;
        @(posedge clk); #1;
        if(d2 !== 32'd0) err = err + 1;
        if(err == 0)
            $display("pass tb_regfile");
        else
            $display("fail tb_regfile (%0d)", err);
        $finish;
    end
endmodule
