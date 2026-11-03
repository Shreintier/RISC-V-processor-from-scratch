module tb_imm_gen;
    reg  [31:0] inst;
    wire [31:0] imm;

    // Intermediate nets to hold complex expressions for $monitor compatibility
    wire [6:0]  opcode = inst[6:0];
    wire signed [31:0] signed_imm = imm;

    // Instantiate Unit Under Test (UUT)
    imm_gen ig (
        .inst(inst),
        .imm(imm)
    );

    initial begin
        $display("--- Starting RISC-V Imm Gen Testbench ---");
        
        // Passing only simple, pre-computed signal nets to $monitor
        $monitor("Time: %0t | Inst = 0x%h | Opcode = 7'b%b | Imm = 0x%h (Dec: %0d)", 
                 $time, inst, opcode, imm, signed_imm);

        // 1. I-type Test: addi x5, x5, -10
        inst = 32'h9f508293;
        #10;

        // 2. S-type Test: sw x6, 40(x5)
        inst = 32'h0262a423;
        #10;

        // 3. B-type Test: beq x5, x6, -16
        inst = 32'hfe6288e3;
        #10;

        // 4. U-type Test: lui x5, 0x12345
        inst = 32'h123452b7;
        #10;

        // 5. J-type Test: jal x1, +2048 (offset = 0x800)
        inst = 32'h800000ef;
        #10;

        // 6. Default / Unknown Opcode Test: r-type (add x5, x5, x5)
        inst = 32'h005282b3;
        #10;

        $display("--- Testbench Completed ---");
        $finish;
    end

endmodule
