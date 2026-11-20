`timescale 1ns / 1ps
module tb_data_memory;
    reg clk,mr,mw;
    reg [31:0] addr,wd;
    reg [2:0] f3;
    wire [31:0] rd;
    integer err=0;
    data_memory #(.rl_var(32),.bytes(64)) dut(
        .clk(clk),.mem_read(mr),.mem_write(mw),
        .addr(addr),.write_data(wd),.funct3(f3),.read_data(rd)
    );
    always #5 clk=~clk;
    initial begin
        clk=0; mr=0; mw=0; addr=0; wd=0; f3=0;
        addr=32'd4; wd=32'h89ab_cdef; f3=3'b010; mw=1;
        @(posedge clk); #1;
        mw=0; mr=1; #1;
        if(rd!==32'h89ab_cdef) err=err+1;
        f3=3'b000; #1;
        if(rd!==32'hffff_ffef) err=err+1;
        f3=3'b100; #1;
        if(rd!==32'h0000_00ef) err=err+1;
        f3=3'b001; #1;
        if(rd!==32'hffff_cdef) err=err+1;
        f3=3'b101; #1;
        if(rd!==32'h0000_cdef) err=err+1;
        if(err==0)
            $display("pass tb_data_memory");
        else
            $display("fail tb_data_memory (%0d)",err);
        $finish;
    end
endmodule