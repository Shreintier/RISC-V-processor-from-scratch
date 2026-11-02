`timescale 1ns/1ps
module tb_alu;
reg  [31:0] a;
reg  [31:0] b;
reg  [2:0]  op;
wire [31:0] y;
alu uut(.a(a),.b(b),.op(op),.y(y));
    initial begin
        $dumpfile("waves/alu.vcd");
        $dumpvars(0, tb_alu);
        
        // Addition test: 10+5=15
        a = 10;
        b = 5;
        op = 3'b000;
        #10;
        if(y !== 15)
            $fatal(1, "Addition failed");
        $display("ADD: %0d + %0d = %0d", a, b, y);
        
        // Subtraction test: 10-5=5
        op = 3'b001;
        #10;
        if(y !== 5)
            $fatal(1, "Subtraction failed");
        $display("SUB: %0d - %0d = %0d", a, b, y);
        
        // Test AND
        a = 12;  // 1100
        b = 10;  // 1010
        op = 3'b010;
        #10;
        if(y !== 8)
            $fatal(1, "AND failed");
        $display("AND: %0d", y);

        // Test OR
        op = 3'b011;
        #10;
        if(y !== 14)
            $fatal(1, "OR failed");
        $display("OR: %0d", y);
        
        // Test XOR
        op = 3'b100;
        #10;
        if(y !== 6)
            $fatal(1, "XOR failed");
        $display("XOR: %0d", y);

        $display("All ALU tests passed.");
        $finish;
    end
endmodule