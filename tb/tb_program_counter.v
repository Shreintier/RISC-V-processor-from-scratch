`timescale 1ns / 1ps
module tb_program_counter;

    reg clk;
    reg rst;
    reg [31:0] imm;
    reg [31:0] rs1_data;
    reg branch;
    reg branch_taken;
    reg jump;
    reg jalr;

    wire [31:0] pc;

    program_counter inst(
        .clk(clk),
        .rst(rst),
        .imm(imm),
        .rs1_data(rs1_data),
        .branch(branch),
        .branch_taken(branch_taken),
        .jump(jump),
        .jalr(jalr),
        .pc(pc)
    );

    // Clock period: 10 ns
    always #5 clk = ~clk;

    initial begin

        $dumpfile("waves/program_counter.vcd");
        $dumpvars(0, tb_program_counter);

        // initialize inputs
        clk = 0;
        rst = 0;
        imm = 0;
        rs1_data = 0;
        branch = 0;
        branch_taken = 0;
        jump = 0;
        jalr = 0;

        // TEST 1: Asynchronous reset
        #2 rst = 1;
        #2;
        $display("TEST 1 - Reset: PC = %h", pc);

        rst = 0;

        // TEST 2: Sequential execution (PC + 4)
        @(negedge clk);
        #1;
        $display("TEST 2 - Sequential: PC = %h", pc);

        // TEST 3: Taken branch
        // Current PC= 4, immediate = 32
        imm= 32'h00000020;
        branch = 1;
        branch_taken = 1;
        @(negedge clk);
        #1;
        $display("TEST 3 - Taken Branch: PC = %h", pc);

        // TEST 4: Not-taken branch
        branch_taken = 0;
        @(negedge clk);
        #1;
        $display("TEST 4 - Not Taken Branch: PC = %h", pc);

        // TEST 5: JAL
        branch = 0;
        jump = 1;
        jalr = 0;
        @(negedge clk);
        #1;
        $display("TEST 5 - JAL: PC = %h", pc);

        // TEST 6: JALR
        // Current PC is 60, but JALR uses rs1_data + imm
        rs1_data = 32'h00000101;
        imm = 32'h00000020;
        jalr = 1;
        @(negedge clk);
        #1;
        $display("TEST 6 - JALR: PC = %h", pc);

        $finish;
    end
endmodule