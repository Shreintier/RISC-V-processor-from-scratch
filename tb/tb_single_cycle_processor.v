`timescale 1ns / 1ps
module tb_single_cycle_processor;
    reg clk;
    reg rst;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    single_cycle_processor dut(.clk(clk),.rst(rst),.pc_out(pc_out),.instruction_out(instruction_out));

    //clock period: 10 ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves/single_cycle.vcd");
        $dumpvars(0, tb_single_cycle_processor);

        rst = 1;

        //Hold reset, then release it
        #12;
        rst = 0;

        //Allow the 9 executed instructions to complete
        repeat (9) @(posedge clk);
        #1;

        $display("\n----- PROCESSOR RESULTS -----");

        $display("PC       = %h", pc_out);
        $display("x1       = %h", dut.inst5.registers[1]);
        $display("x2       = %h", dut.inst5.registers[2]);
        $display("x3       = %h", dut.inst5.registers[3]);
        $display("x4       = %h", dut.inst5.registers[4]);
        $display("x5       = %h", dut.inst5.registers[5]);
        $display("x6       = %h", dut.inst5.registers[6]);
        $display("x7       = %h", dut.inst5.registers[7]);
        $display("Memory[0] = %h", dut.inst7.mem[0]);

        //Verification
        if(pc_out == 32'h0000002C && dut.inst5.registers[1] == 32'd5 &&
            dut.inst5.registers[2] == 32'd10 && dut.inst5.registers[3] == 32'd15 &&
            dut.inst5.registers[4] == 32'd15 && dut.inst5.registers[5] == 32'd42 &&
            dut.inst5.registers[6] == 32'd36 && dut.inst5.registers[7] == 32'd7 &&
            dut.inst7.mem[0] == 32'd15
        ) begin
            $display("\nALL PROCESSOR TESTS PASSED!");
        end
        else begin
            $display("\nPROCESSOR TEST FAILED!");
            $fatal(1);
        end
        $finish;
    end

endmodule