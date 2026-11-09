`timescale 1ns/1ps
module tb_data_memory;
    reg clk;
    reg mem_read;
    reg mem_write;
    reg [31:0] addr;
    reg [31:0] write_data;
    reg [2:0] funct3;
    wire [31:0] read_data;

    data_memory inst(
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr(addr),
        .write_data(write_data),
        .funct3(funct3),
        .read_data(read_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to check load results
    task check_load;
        input [31:0] expected;
        input [8*30:1] test_name;
        begin
            #1;
            $display("%0s | Expected = %08h | Actual = %08h",
                     test_name, expected, read_data);
            if (read_data !== expected)
                $display("FAILED");
            else
                $display("PASSED");
        end
    endtask

    initial begin

        $dumpfile("waves/data_memory.vcd");
        $dumpvars(0, tb_data_memory);

        clk = 0;
        mem_read = 0;
        mem_write = 0;
        addr = 0;
        write_data = 0;
        funct3 = 0;

        $display("\n--- Starting Data Memory Testbench ---");

        // TEST 1: SW - Store a complete word
        @(negedge clk);
        addr = 32'h00000000;
        write_data = 32'h80FF7F01;
        funct3 = 3'b010;
        mem_write = 1;

        @(negedge clk);
        mem_write = 0;
        $display("TEST 1 - SW completed");

        // TEST 2: LW - Load the complete word
        mem_read = 1;
        funct3 = 3'b010;
        addr = 32'h00000000;
        check_load(32'h80FF7F01, "TEST 2 - LW");

        // TEST 3: LB - Load signed byte at address 0
        funct3 = 3'b000;
        addr = 32'h00000000;
        check_load(32'h00000001, "TEST 3 - LB");

        // TEST 4: LB - Load signed byte at address 3
        addr = 32'h00000003;
        check_load(32'hFFFFFF80, "TEST 4 - LB signed");

        // TEST 5: LBU - Load unsigned byte at address 3
        funct3 = 3'b100;
        addr = 32'h00000003;
        check_load(32'h00000080, "TEST 5 - LBU");

        // TEST 6: LH - Load signed halfword at address 2
        funct3 = 3'b001;
        addr = 32'h00000002;
        check_load(32'hFFFF80FF, "TEST 6 - LH");

        // TEST 7: LHU - Load unsigned halfword at address 2
        funct3 = 3'b101;
        addr = 32'h00000002;
        check_load(32'h000080FF, "TEST 7 - LHU");

        // TEST 8: SB - Store byte at address 1
        @(negedge clk);
        mem_read = 0;
        mem_write = 1;
        funct3 = 3'b000;
        addr = 32'h00000001;
        write_data = 32'h000000AA;
        @(posedge clk);
        #1;
        mem_write = 0;
        $display("TEST 8 - SB completed");

        // TEST 9: LW - Check byte update and preservation
        mem_read = 1;
        funct3 = 3'b010;
        addr = 32'h00000000;
        check_load(32'h80FFAA01, "TEST 9 - SB verification");

        // TEST 10: SH - Store halfword at address 2
        @(negedge clk);
        mem_read = 0;
        mem_write = 1;
        funct3 = 3'b001;
        addr = 32'h00000002;
        write_data = 32'h00001234;
        @(posedge clk);
        #1;
        mem_write = 0;
        $display("TEST 10 - SH completed");

        // TEST 11: LW - Check halfword update
        mem_read = 1;
        funct3 = 3'b010;
        addr = 32'h00000000;
        check_load(32'h1234AA01, "TEST 11 - SH verification");

        // TEST 12: SW - Store another word at address 4
        @(negedge clk);
        mem_read = 0;
        mem_write = 1;
        funct3 = 3'b010;
        addr = 32'h00000004;
        write_data = 32'h12345678;
        @(posedge clk);
        #1;
        mem_write = 0;

        // TEST 13: LW - Load second word
        mem_read = 1;
        funct3 = 3'b010;
        addr = 32'h00000004;
        check_load(32'h12345678, "TEST 13 - LW second word");

        $display("\n--- Data Memory Testbench Completed ---");
        #10;
        $finish;
    end
endmodule
