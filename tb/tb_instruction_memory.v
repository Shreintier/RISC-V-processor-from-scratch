`timescale 1ns / 1ps

module tb_instruction_memory();
    // Inputs
    reg [31:0] addr;

    // Outputs
    wire [31:0] inst;

    // Instantiate the Unit Under Test (UUT)
    instruction_memory uut (
        .addr(addr), 
        .inst(inst)
    );

    initial begin

        $dumpfile("waves/instruction_memory.vcd");
        $dumpvars(0,tb_instruction_memory);

        // Initialize Inputs
        addr = 0;

        #10;
        
        // Test Address 0x00000000 
        addr = 32'h0000_0000;
        #10;
        $display("Addr: %h | Inst: %h", addr, inst);

        // Test Address 0x00000004
        addr = 32'h0000_0004;
        #10;
        $display("Addr: %h | Inst: %h", addr, inst);

        // Test Address 0x00000008 
        addr = 32'h0000_0008;
        #10;
        $display("Addr: %h | Inst: %h", addr, inst);

        // Test Address 0x0000000C 
        addr = 32'h0000_000C;
        #10;
        $display("Addr: %h | Inst: %h", addr, inst);

        // Test Address 0x00000010 
        addr = 32'h0000_0010;
        #10;
        $display("Addr: %h | Inst: %h", addr, inst);


        $finish;
    end
      
endmodule

