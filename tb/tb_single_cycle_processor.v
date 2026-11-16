`timescale 1ns / 1ps

module tb_single_cycle_processor;
    reg clk;
    reg rst;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    integer i;

    single_cycle_processor dut(.clk(clk),.rst(rst),.pc_out(pc_out),.instruction_out(instruction_out));

    // 10 ns clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("waves_single_cycle.vcd");
        $dumpvars(0, tb_single_cycle_processor);

        //Hold reset, then release it
        #12;
        rst = 0;

        // Instruction execution trace
        fork

            begin
    forever begin
        @(negedge clk);

        if (dut.branch) begin
            $display(
                "BRANCH DEBUG | PC=%h | funct3=%b | rs1_data=%h | rs2_data=%h | imm=%h | taken=%b",
                pc_out,
                dut.funct3,
                dut.data_reg1,
                dut.data_reg2,
                dut.imm,
                dut.branch_taken
            );
        end
    end
end

            begin
                forever begin
                    @(negedge clk);
                    $display(
                        "TIME=%0t | PC=%h | INST=%h",
                        $time,
                        pc_out,
                        instruction_out
                    );
                end
            end
        join_none

        //Allow the 80 executed instructions to complete
        repeat (80) @(posedge clk);
        #1;

        $display("\n----- FINAL REGISTER VALUES -----");

        for(i = 0; i < 32; i = i + 1) begin
            $display("x%0d = %h", i, dut.inst5.registers[i]);
        end

        $display("\n----- DATA MEMORY -----");

        for(i = 0; i < 8; i = i + 1) begin
            $display("mem[%0d] = %h", i, dut.inst7.mem[i]);
        end

        //Verification
        if(pc_out == 32'h00000138 &&
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
            dut.inst7.mem[2] == 32'h12348001) begin
                $display("ALL EXTENDED PROCESSOR TESTS PASSED!");
            end
        else begin
                $display("EXTENDED PROCESSOR TEST FAILED!");
                $fatal(1);
        end

        $finish;
    end
endmodule
