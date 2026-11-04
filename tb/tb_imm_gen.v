`timescale 1ns/1ps
module tb_imm_gen;
    reg  [31:0] inst;
    wire [31:0] imm;
    wire [6:0]  opcode = inst[6:0];
    wire signed [31:0] signed_imm = imm;
    imm_gen ig(
        .inst(inst),
        .imm(imm)
    );

    task check_imm;
    input [31:0] expected;
        begin
        if (imm !== expected) begin
                $display("FAILED: Expected = 0x%h, Got = 0x%h",
                     expected, imm);
                $fatal(1);
            end
            else begin
                $display("PASSED: Immediate = 0x%h", imm);
            end
        end
    endtask

    initial begin

        inst=32'b0;
        $display("--- Starting RISC-V Imm Gen Testbench ---");
        
        $dumpfile("waves/imm_gen.vcd");
        $dumpvars(0, tb_imm_gen);

        // Passing only simple, pre-computed signal nets to $monitor
        $monitor("Time: %0t | Inst = 0x%h | Opcode = 7'b%b | Imm = 0x%h (Dec: %0d)", 
                 $time, inst, opcode, imm, signed_imm);

        // Test 1 - addi x5, x5, -10
        inst = 32'hff628293;
        #10;
        check_imm(32'hFFFFFFF6);

        // Test 2 - sw x6, 40(x5)
        inst = 32'h0262a423;
        #10;
        check_imm(32'h00000028);

        // Test 3 - beq x5, x6, -16
        inst = 32'hfe6288e3;
        #10;
        check_imm(32'hFFFFFFF0);

        // Test 4 - lui x5, 0x12345
        inst = 32'h123452b7;
        #10;
        check_imm(32'h12345000);

        // Test 5 - jal x1, +2048
        inst = 32'h001000ef;
        #10;
        check_imm(32'h00000800);

        // Test 6 - add x5, x5, x5
        inst = 32'h005282b3;
        #10;
        check_imm(32'h00000000);

        $display("--- Testbench Completed ---");
        $finish;
    end
endmodule
