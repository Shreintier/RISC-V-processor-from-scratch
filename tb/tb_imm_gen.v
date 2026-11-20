`timescale 1ns / 1ps
module tb_imm_gen;
    reg [31:0] inst;
    wire [31:0] imm;
    integer err = 0;
    imm_gen #(.rl_var(32)) dut(.inst(inst), .imm(imm));
    initial begin
        inst = 32'hff80_0093; #1;
        if(imm !== 32'hffff_fff8) err = err + 1;
        inst = 32'hfe00_0fa3; #1;
        if(imm !== 32'hffff_ffff) err = err + 1;
        inst = 32'h1234_50b7; #1;
        if(imm !== 32'h1234_5000) err = err + 1;
        if(err == 0)
            $display("pass tb_imm_gen");
        else
            $display("fail tb_imm_gen (%0d)", err);
        $finish;
    end
endmodule
