`timescale 1ns/1ps
module tb_alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] op;
    wire [31:0] y;
    alu uut(
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );
    initial begin

        $dumpfile("waves/alu.vcd");
        $dumpvars(0, tb_alu);

        // TEST 1: ADD
        a = 10;
        b = 5;
        op = 4'b0000;
        #10;
        if(y !== 15)
            $fatal(1, "ADD failed");
        $display("ADD PASSED");

        // TEST 2: SUB
        op = 4'b0001;
        #10;
        if(y !== 5)
            $fatal(1, "SUB failed");
        $display("SUB PASSED");

        // TEST 3: AND
        a = 12;
        b = 10;
        op = 4'b0010;
        #10;
        if(y !== 8)
            $fatal(1, "AND failed");
        $display("AND PASSED");

        // TEST 4: OR
        op = 4'b0011;
        #10;
        if(y !== 14)
            $fatal(1, "OR failed");
        $display("OR PASSED");

        // TEST 5: XOR
        op = 4'b0100;
        #10;
        if(y !== 6)
            $fatal(1, "XOR failed");
        $display("XOR PASSED");

        // TEST 6: SLL
        a = 3;
        b = 2;
        op = 4'b0101;
        #10;
        if(y !== 12)
            $fatal(1, "SLL failed");
        $display("SLL PASSED");

        // TEST 7: SRL
        a = 32'h80000000;
        b = 4;
        op = 4'b0110;
        #10;
        if(y !== 32'h08000000)
            $fatal(1, "SRL failed");
        $display("SRL PASSED");

        // TEST 8: SRA
        op = 4'b0111;
        #10;
        if(y !== 32'hF8000000)
            $fatal(1, "SRA failed");
        $display("SRA PASSED");

        // TEST 9: SLT (signed)
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        op = 4'b1000;
        #10;
        if(y !== 1)
            $fatal(1, "SLT failed");
        $display("SLT PASSED");

        // TEST 10: SLTU (unsigned)
        op = 4'b1001;
        #10;
        if(y !== 0)
            $fatal(1, "SLTU failed");
        $display("SLTU PASSED");

        $display("-----------------------------");
        $display("All 10 ALU tests passed!");
        $finish;
    end
endmodule