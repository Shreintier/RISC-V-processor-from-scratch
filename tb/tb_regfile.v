`timescale 1ns/1ps
module tb_regfile;
    reg clk, rst, reg_write;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [31:0] write_data;
    wire [31:0] data_reg1, data_reg2;
    reg [4:0] test_regs [0:9];
    regfile inst(
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .data_reg1(data_reg1),
        .data_reg2(data_reg2)
    );

    //clock period: 10ns
    always #5 clk = ~clk;

    integer i;

    initial begin
        //initialization
        clk = 0;
        rst = 0;
        reg_write = 0;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;

        $dumpfile("waves/regfile.vcd");
        $dumpvars(0, tb_regfile);
        
        //register addresses to test
        test_regs[0] = 3;
        test_regs[1] = 7;
        test_regs[2] = 10;
        test_regs[3] = 13;
        test_regs[4] = 16;
        test_regs[5] = 19;
        test_regs[6] = 22;
        test_regs[7] = 24;
        test_regs[8] = 29;
        test_regs[9] = 31;

        // TEST 1: Reset
        #2;
        rst = 1;
        #2;
        rst = 0;
        $display("TEST 1 PASSED: Reset applied");

        // TEST 2: Write different values into selected registers
        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);
            reg_write = 1;
            write_reg = test_regs[i];
            write_data = 32'd100 + (i * 50);

            @(posedge clk);
            #1;
            reg_write = 0;
            $display("Written x%0d = %0d",test_regs[i], write_data);
        end
        $display("--------------------------------");

        // TEST 3: Read back and verify every register
        for (i = 0; i < 10; i = i + 1) begin
            read_reg1 = test_regs[i];
            #1;
            if (data_reg1 !== (32'd100 + (i * 50))) begin
                $display("FAILED: x%0d expected %0d, got %0d",
                         test_regs[i],
                         (32'd100 + (i * 50)),
                         data_reg1);
                $fatal(1);
            end
            else begin
                $display("PASSED: x%0d = %0d",test_regs[i], data_reg1);
            end
        end
        $display("--------------------------------");

        // TEST 4: Simultaneous reads using both read ports

        read_reg1 = 3;
        read_reg2 = 31;
        #1;
        if (data_reg1 !== 32'd100 ||
            data_reg2 !== 32'd550)
            $fatal(1, "FAILED: Simultaneous read");
        $display("TEST 4 PASSED: Both read ports work");

        // TEST 5: Attempt to write into x0

        @(negedge clk);
        reg_write = 1;
        write_reg = 0;
        write_data = 999;

        @(posedge clk);
        #1;
        reg_write = 0;
        read_reg1 = 0;
        #1;
        if (data_reg1 !== 32'd0)
            $fatal(1, "FAILED: x0 was modified");
        $display("TEST 5 PASSED: x0 protection");

        $display("--------------------------------");
        $display("ALL REGISTER FILE TESTS PASSED");

        $finish;
    end
endmodule
