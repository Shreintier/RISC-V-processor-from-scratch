`timescale 1ns / 1ps
module tb_instruction_memory;
    reg [31:0] addr;
    wire [31:0] inst;
    integer err = 0;
    instruction_memory #(.rl_var(32), .words(16)) dut(.addr(addr), .inst(inst));
    initial begin
        dut.mem[0] = 32'h0050_0093;
        dut.mem[1] = 32'h00a0_0113;
        addr = 32'd0; #1;
        if(inst !== 32'h0050_0093) err = err + 1;
        addr = 32'd4; #1;
        if(inst !== 32'h00a0_0113) err = err + 1;
        if(err == 0)
            $display("pass tb_instruction_memory");
        else
            $display("fail tb_instruction_memory (%0d)", err);
        $finish;
    end
endmodule
