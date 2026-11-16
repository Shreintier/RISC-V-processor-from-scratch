`timescale 1ns / 1ps

module tb_single_cycle_processor;
    reg clk;
    reg rst;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    single_cycle_processor dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    // 10 ns clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves_single_cycle.vcd");
        $dumpvars(0, tb_single_cycle_processor);

        // Hold reset then release it
        rst = 1;
        #12 rst = 0;

        // Allow the executed instructions to complete
        repeat (80) @(posedge clk);
        #1;

        $display("\n--- PROCESSOR RESULTS ---");
        $display("PC:       %h", pc_out);
        $display("x1:       %h", dut.inst5.registers[1]);
        $display("x2:       %h", dut.inst5.registers[2]);
        $display("x3:       %h", dut.inst5.registers[3]);
        $display("x4:       %h", dut.inst5.registers[4]);
        $display("x5:       %h", dut.inst5.registers[5]);
        $display("x6:       %h", dut.inst5.registers[6]);
        $display("x7:       %h", dut.inst5.registers[7]);
        $display("x8:       %h", dut.inst5.registers[8]);
        $display("x9:       %h", dut.inst5.registers[9]);
        $display("x10:      %h", dut.inst5.registers[10]);
        $display("x11:      %h", dut.inst5.registers[11]);
        $display("x12:      %h", dut.inst5.registers[12]);
        $display("x13:      %h", dut.inst5.registers[13]);
        $display("x14:      %h", dut.inst5.registers[14]);
        $display("x15:      %h", dut.inst5.registers[15]);
        $display("x17:      %h", dut.inst5.registers[17]);
        $display("x18:      %h", dut.inst5.registers[18]);
        $display("x28:      %h", dut.inst5.registers[28]);
        $display("x29:      %h", dut.inst5.registers[29]);
        $display("x31:      %h", dut.inst5.registers[31]);
        $display("Memory 0: %h", dut.inst7.mem[0]);
        $display("Memory 1: %h", dut.inst7.mem[1]);
        $display("Memory 2: %h", dut.inst7.mem[2]);

        // Verification checks
        if (
    pc_out == 32'h00000138 &&
    dut.inst5.registers[3] == 32'h0000000F &&
    dut.inst5.registers[4] == 32'h0000000B &&
    dut.inst5.registers[7] == 32'h00008001 &&
    dut.inst5.registers[8] == 32'hFFFF8001 &&
    dut.inst5.registers[9] == 32'h0000000C &&
    dut.inst5.registers[10] == 32'h00001234 &&
    dut.inst5.registers[11] == 32'h00000118 &&
    dut.inst5.registers[12] == 32'h00000055 &&
    dut.inst5.registers[13] == 32'h0000000D &&
    dut.inst5.registers[14] == 32'h0000012C &&
    dut.inst5.registers[15] == 32'h00000128 &&
    dut.inst5.registers[17] == 32'h00000011 &&
    dut.inst5.registers[18] == 32'h00000001 &&
    dut.inst5.registers[28] == 32'h0000006C &&
    dut.inst5.registers[29] == 32'h0000000F &&
    dut.inst5.registers[31] == 32'hFFFFFF80 &&
    dut.inst7.mem[0] == 32'h0000000F &&
    dut.inst7.mem[1] == 32'h55555580 &&
    dut.inst7.mem[2] == 32'h12348001
) begin
            $display("ALL EXTENDED PROCESSOR TESTS PASSED");
        end else begin
            $display("EXTENDED PROCESSOR TEST FAILED");
            $fatal(1);
        end

        $finish;
    end
endmodule
