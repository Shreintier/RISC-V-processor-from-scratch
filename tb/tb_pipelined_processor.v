`timescale 1ns / 1ps

module tb_pipelined_processor #(
    parameter rl_var = 32
);
    reg clk;
    reg rst;
    wire [rl_var-1:0] pc_out;
    wire [31:0] instruction_out;

    reg [1023:0] dump_file;
    reg [rl_var-1:0] terminal_pc;
    reg finished;
    integer test_id;
    integer expected_width;

    integer fd;
    integer idx;
    integer cyc;
    integer err;
    integer max_cycles;
    integer loop_count;

    pipelined_processor #(.rl_var(rl_var)) dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    // 10 ns clock period (100 MHz)
    always #5 clk = ~clk;

    // Only count terminal jumps that reach EX. Fetch can see the halt
    // instruction on the wrong path before a loop branch redirects the PC.
    always @(posedge clk) begin
        if (!rst) begin
            $display("cycle=%0d pc=%h inst=%h", cyc, pc_out, instruction_out);
            cyc <= cyc + 1;

            if (dut.ex_jump && (dut.ex_rd == 5'd0) &&
                (dut.ex_imm == {rl_var{1'b0}})) begin
                if (dut.ex_pc == terminal_pc) begin
                    loop_count <= loop_count + 1;
                    if (loop_count == 3)
                        finished <= 1'b1;
                end else begin
                    terminal_pc <= dut.ex_pc;
                    loop_count <= 1;
                end
            end
        end
    end

    task chk_reg(input [4:0] r, input [rl_var-1:0] exp);
        begin
            if (dut.rf.regs[r] !== exp) begin
                $display("fail x%0d got=%h exp=%h", r, dut.rf.regs[r], exp);
                err = err + 1;
            end
        end
    endtask

    initial begin
        if ($value$plusargs("expect_width=%d", expected_width)) begin
            if (rl_var != expected_width)
                $fatal(1, "Test suite expects rl_var=%0d, testbench has %0d",
                       expected_width, rl_var);
        end
        if (dut.rl_var != rl_var)
            $fatal(1, "dut.rl_var=%0d, expected %0d", dut.rl_var, rl_var);
        if (dut.imem.rl_var != rl_var)
            $fatal(1, "dut.imem.rl_var=%0d, expected %0d", dut.imem.rl_var, rl_var);
        if (dut.u_if_id.rl_var != rl_var)
            $fatal(1, "dut.u_if_id.rl_var=%0d, expected %0d", dut.u_if_id.rl_var, rl_var);
        if (dut.u_imm_gen.rl_var != rl_var)
            $fatal(1, "dut.u_imm_gen.rl_var=%0d, expected %0d", dut.u_imm_gen.rl_var, rl_var);
        if (dut.rf.rl_var != rl_var)
            $fatal(1, "dut.rf.rl_var=%0d, expected %0d", dut.rf.rl_var, rl_var);
        if (dut.u_id_ex.rl_var != rl_var)
            $fatal(1, "dut.u_id_ex.rl_var=%0d, expected %0d", dut.u_id_ex.rl_var, rl_var);
        if (dut.u_alu.rl_var != rl_var)
            $fatal(1, "dut.u_alu.rl_var=%0d, expected %0d", dut.u_alu.rl_var, rl_var);
        if (dut.u_mul_div.rl_var != rl_var)
            $fatal(1, "dut.u_mul_div.rl_var=%0d, expected %0d", dut.u_mul_div.rl_var, rl_var);
        if (dut.u_ex_mem.rl_var != rl_var)
            $fatal(1, "dut.u_ex_mem.rl_var=%0d, expected %0d", dut.u_ex_mem.rl_var, rl_var);
        if (dut.dmem.rl_var != rl_var)
            $fatal(1, "dut.dmem.rl_var=%0d, expected %0d", dut.dmem.rl_var, rl_var);
        if (dut.u_mem_wb.rl_var != rl_var)
            $fatal(1, "dut.u_mem_wb.rl_var=%0d, expected %0d", dut.u_mem_wb.rl_var, rl_var);
        $display("Processor and datapath modules use rl_var=%0d", rl_var);

        clk = 0;
        rst = 1;
        cyc = 0;
        err = 0;
        loop_count = 0;
        terminal_pc = {rl_var{1'b1}};
        finished = 1'b0;
        if (!$value$plusargs("test=%d", test_id))
            test_id = 0;
        if (!$value$plusargs("dump=%s", dump_file))
            dump_file = "reg_dump.txt";

        if (!$value$plusargs("cycles=%d", max_cycles))
            max_cycles = 1000;

        $display("------------------------------------");
        $display("Cycle limit        : %0d", max_cycles);
        $display("------------------------------------");

        #12 rst = 0;

        for (idx = 0; idx < max_cycles; idx = idx + 1) begin
            @(posedge clk);
            #1;
            if (finished)
                idx = max_cycles;
        end

        if (!finished) begin
            $display("Simulation stopped: cycle limit reached (%0d).", max_cycles);
            if (test_id != 0)
                err = err + 1;
        end else
            $display("Terminal loop detected. Simulation completed.");

        fd = $fopen(dump_file, "w");
        if (fd == 0) begin
            $display("ERROR: Could not open register dump file.");
            err = err + 1;
        end else begin
            for (idx = 0; idx < 32; idx = idx + 1) begin
                $fdisplay(fd, "x%0d = 0x%h (%0d)",
                          idx, dut.rf.regs[idx], $signed(dut.rf.regs[idx]));
            end
            $fclose(fd);
            $display("Register dump saved to %0s", dump_file);
        end

        if (rl_var == 64) begin
            chk_reg(5'd0, 64'd0);
            case (test_id)
                1: begin
                    chk_reg(5'd10, 64'h00000002ee333961);
                    chk_reg(5'd11, 64'h00000004bdd96882);
                end
                2: begin
                    chk_reg(5'd10, 64'h0000000100000000);
                    chk_reg(5'd11, 64'h00000000ffffffff);
                    chk_reg(5'd12, 64'h0000000000000000);
                    chk_reg(5'd13, 64'hffffffffffffffff);
                    chk_reg(5'd14, 64'h8000000000000000);
                end
                3: begin
                    chk_reg(5'd10, 64'h8000000000000000);
                    chk_reg(5'd11, 64'h0000000000000001);
                    chk_reg(5'd12, 64'hffffffffffffffff);
                    chk_reg(5'd13, 64'hffffffffffffffff);
                    chk_reg(5'd14, 64'h0000000000000001);
                end
                4: begin
                    chk_reg(5'd10, 64'h0000000000000001);
                    chk_reg(5'd11, 64'h0000000000000000);
                    chk_reg(5'd12, 64'h0000000000000007);
                end
                5: begin
                    chk_reg(5'd10, 64'hffffffffffffffff);
                    chk_reg(5'd11, 64'hffffffffffffffff);
                    chk_reg(5'd12, 64'hffffffffffffffff);
                    chk_reg(5'd13, 64'h000000000000ffff);
                    chk_reg(5'd14, 64'h00000000000000ff);
                    chk_reg(5'd15, 64'h00000000000000fe);
                end
                6: begin
                    chk_reg(5'd10, 64'h7fffffff80000000);
                    chk_reg(5'd11, 64'hffffffff80000000);
                    chk_reg(5'd12, 64'h8000000000000000);
                    chk_reg(5'd13, 64'h0000000000000000);
                end
                7: begin
                    // 64-bit multiply, divide, and remainder.
                    chk_reg(5'd10, 64'hfffffcfffffffffd);
                    chk_reg(5'd11, 64'hffffffffffffffff);
                    chk_reg(5'd12, 64'hffffffffffffffff);
                    chk_reg(5'd13, 64'h0000000000000002);
                    chk_reg(5'd14, 64'hffffffaaaaaaaaab);
                    chk_reg(5'd15, 64'h555554ffffffffff);
                    chk_reg(5'd16, 64'hfffffffffffffffe);
                    chk_reg(5'd17, 64'h0000000000000002);
                end
                default: $fatal(1, "Unknown RV64I suite test %0d", test_id);
            endcase
            if (err != 0)
                $fatal(1, "FAIL: final_processor_rv64i_tb%0d (%0d errors)", test_id, err);
            $display("PASS: final_processor_rv64i_tb%0d", test_id);
            $finish;
        end else if (test_id != 0) begin
            chk_reg(5'd0, 32'd0);
            case (test_id)
                1: begin
                    // Fibonacci sequence, F(0) through F(11)
                    chk_reg(5'd10, 32'h00000000);
                    chk_reg(5'd11, 32'h00000001);
                    chk_reg(5'd12, 32'h00000005);
                    chk_reg(5'd13, 32'h00000037);
                    chk_reg(5'd14, 32'h00000059);
                    chk_reg(5'd15, 32'h00000090);
                end
                2: begin
                    // 2x2 matrix multiplication: [[1,2],[3,4]] times [[5,6],[7,8]]
                    chk_reg(5'd24, 32'h00000013);
                    chk_reg(5'd25, 32'h00000016);
                    chk_reg(5'd26, 32'h0000002b);
                    chk_reg(5'd27, 32'h00000032);
                end
                3: begin
                    // Factorial, 10!
                    chk_reg(5'd1, 32'h00000000);
                    chk_reg(5'd10, 32'h00375f00);
                    chk_reg(5'd11, 32'h00375f00);
                end
                4: begin
                    // Euclid GCD of 1071 and 462
                    chk_reg(5'd2, 32'h00000000);
                    chk_reg(5'd10, 32'h00000015);
                end
                5: begin
                    // LCM of 84 and 30 via Euclid
                    chk_reg(5'd3, 32'h00000006);
                    chk_reg(5'd10, 32'h000001a4);
                end
                6: begin
                    // Integer power, 3^13 by squaring
                    chk_reg(5'd2, 32'h00000000);
                    chk_reg(5'd10, 32'h001853d3);
                end
                7: begin
                    // Signed array sum, min, and max for [8,-3,12,-9,5]
                    chk_reg(5'd10, 32'h0000000d);
                    chk_reg(5'd11, 32'hfffffff7);
                    chk_reg(5'd12, 32'h0000000c);
                end
                8: begin
                    // Bubble sort of [7,-2,5,0,3]
                    chk_reg(5'd10, 32'hfffffffe);
                    chk_reg(5'd11, 32'h00000000);
                    chk_reg(5'd12, 32'h00000003);
                    chk_reg(5'd13, 32'h00000005);
                    chk_reg(5'd14, 32'h00000007);
                end
                9: begin
                    // Count primes up to 30 and sum them
                    chk_reg(5'd10, 32'h0000000a);
                    chk_reg(5'd11, 32'h00000081);
                end
                10: begin
                    // Popcount and bit reversal of 0xB2
                    chk_reg(5'd10, 32'h00000004);
                    chk_reg(5'd11, 32'h0000004d);
                end
                11: begin
                    // Dot product of [2,-3,4] with [5,6,-7]
                    chk_reg(5'd10, 32'hffffffdc);
                end
                12: begin
                    // Byte and halfword stores, signed and unsigned loads
                    chk_reg(5'd10, 32'hfffe8078);
                    chk_reg(5'd11, 32'hffffff80);
                    chk_reg(5'd12, 32'h00000080);
                    chk_reg(5'd13, 32'hfffffffe);
                    chk_reg(5'd14, 32'h0000fffe);
                    chk_reg(5'd15, 32'h00000078);
                end
                13: begin
                    // RV32M high products and signed, unsigned, zero and overflow division
                    chk_reg(5'd10, 32'hffffffe2);
                    chk_reg(5'd11, 32'hffffffff);
                    chk_reg(5'd12, 32'hffffffff);
                    chk_reg(5'd13, 32'h00000002);
                    chk_reg(5'd14, 32'hfffffffd);
                    chk_reg(5'd15, 32'h55555552);
                    chk_reg(5'd16, 32'hffffffff);
                    chk_reg(5'd17, 32'h00000000);
                    chk_reg(5'd18, 32'hffffffff);
                    chk_reg(5'd19, 32'hfffffff6);
                    chk_reg(5'd20, 32'hffffffff);
                    chk_reg(5'd21, 32'hfffffff6);
                    chk_reg(5'd22, 32'h80000000);
                    chk_reg(5'd23, 32'h00000000);
                end
                14: begin
                    // JAL/JALR link registers and wrong-path flush
                    chk_reg(5'd1, 32'h00000004);
                    chk_reg(5'd10, 32'h00000014);
                    chk_reg(5'd11, 32'h00000004);
                    chk_reg(5'd12, 32'h00000018);
                    chk_reg(5'd13, 32'h00000000);
                    chk_reg(5'd14, 32'h0000002a);
                end
                15: begin
                    // Forwarding priority, load-use, store-data forwarding and x0
                    chk_reg(5'd1, 32'h0000000c);
                    chk_reg(5'd10, 32'h00000018);
                    chk_reg(5'd11, 32'h00000030);
                    chk_reg(5'd12, 32'h00000030);
                    chk_reg(5'd13, 32'h00000030);
                    chk_reg(5'd14, 32'h00000030);
                end
                16: begin
                    // Signed and unsigned branches and bitwise shifts
                    chk_reg(5'd10, 32'h00000007);
                    chk_reg(5'd11, 32'hffffffff);
                    chk_reg(5'd12, 32'h00000001);
                    chk_reg(5'd13, 32'h7fffffff);
                    chk_reg(5'd14, 32'h00000001);
                    chk_reg(5'd15, 32'h00000001);
                    chk_reg(5'd16, 32'h00000000);
                end
                default: $fatal(1, "Unknown final processor test %0d", test_id);
            endcase
            if (err != 0)
                $fatal(1, "FAIL: final_processor_tb%0d (%0d errors)", test_id, err);
            $display("PASS: final_processor_tb%0d", test_id);
            $finish;
        end else begin
        // ----------------------------------------
        // Hazard test expected register values
        // ----------------------------------------
        /*
        chk_reg(5'd0,  32'd0);
        chk_reg(5'd1,  32'd5);
        chk_reg(5'd2,  32'd8);
        chk_reg(5'd3,  32'd13);
        chk_reg(5'd4,  32'd0);
        chk_reg(5'd5,  32'd13);
        chk_reg(5'd6,  32'd26);
        chk_reg(5'd7,  32'd27);
        chk_reg(5'd8,  32'd22);
        chk_reg(5'd9,  32'd23);
        chk_reg(5'd10, 32'hffff_ffff);
        chk_reg(5'd11, 32'd1);
        chk_reg(5'd12, 32'd12);
        chk_reg(5'd13, 32'd13);
        chk_reg(5'd14, 32'd80);
        chk_reg(5'd15, 32'd15);
        chk_reg(5'd16, 32'd81);
        chk_reg(5'd17, 32'd64);
        chk_reg(5'd18, 32'd27);
        chk_reg(5'd19, 32'd29);
        chk_reg(5'd20, 32'd0);
        chk_reg(5'd21, 32'd21);
        chk_reg(5'd22, 32'd132);
        chk_reg(5'd23, 32'd136);
        chk_reg(5'd24, 32'd24);
        chk_reg(5'd25, 32'd0);
        chk_reg(5'd26, 32'd0);
        chk_reg(5'd27, 32'd0);
        chk_reg(5'd28, 32'd0);
        chk_reg(5'd29, 32'd0);
        chk_reg(5'd30, 32'd0);
        chk_reg(5'd31, 32'd0);
        */

        // ----------------------------------------
        // Single-cycle test program 1
        // ----------------------------------------
        chk_reg(5'd0,  32'd0);
        chk_reg(5'd1,  32'd7);
        chk_reg(5'd2,  32'd7);
        chk_reg(5'd3,  32'd15);
        chk_reg(5'd4,  32'd11);
        chk_reg(5'd5,  32'hffff_ffff);
        chk_reg(5'd6,  32'd1);
        chk_reg(5'd7,  32'd32769);
        chk_reg(5'd8,  32'hffff_8001);
        chk_reg(5'd9,  32'd12);
        chk_reg(5'd10, 32'd4660);
        chk_reg(5'd11, 32'd280);
        chk_reg(5'd12, 32'd4660);
        chk_reg(5'd13, 32'd13);
        chk_reg(5'd14, 32'd300);
        chk_reg(5'd15, 32'd296);
        chk_reg(5'd16, 32'h0800_0000);
        chk_reg(5'd17, 32'd17);
        chk_reg(5'd18, 32'd1);
        chk_reg(5'd19, 32'd1);
        chk_reg(5'd20, 32'd0);
        chk_reg(5'd21, 32'd250);
        chk_reg(5'd22, 32'd261);
        chk_reg(5'd23, 32'd7);
        chk_reg(5'd24, 32'd20);
        chk_reg(5'd25, 32'h0800_0000);
        chk_reg(5'd26, 32'hf800_0000);
        chk_reg(5'd27, 32'h1234_5000);
        chk_reg(5'd28, 32'd108);
        chk_reg(5'd29, 32'd15);
        chk_reg(5'd30, 32'd128);
        chk_reg(5'd31, 32'hffff_ff80);

        // ----------------------------------------
        // Single-cycle test program 2
        // ----------------------------------------
        /*
        chk_reg(5'd0,  32'd0);
        chk_reg(5'd1,  32'd15);
        chk_reg(5'd2,  32'd7);
        chk_reg(5'd3,  32'd22);
        chk_reg(5'd4,  32'd15);
        chk_reg(5'd5,  32'd15);
        chk_reg(5'd6,  32'd15);
        chk_reg(5'd7,  32'd8);
        chk_reg(5'd8,  32'd56);
        chk_reg(5'd9,  32'd14);
        chk_reg(5'd10, 32'hffff_fff0);
        chk_reg(5'd11, 32'hffff_fffc);
        chk_reg(5'd12, 32'd1);
        chk_reg(5'd13, 32'd0);
        chk_reg(5'd14, 32'd99);
        chk_reg(5'd15, 32'd99);
        chk_reg(5'd16, 32'd30);
        chk_reg(5'd17, 32'd114);
        chk_reg(5'd18, 32'd99);
        chk_reg(5'd19, 32'd106);
        chk_reg(5'd20, 32'hffff_fffb);
        chk_reg(5'd21, 32'hffff_fffb);
        chk_reg(5'd22, 32'h0000_00fb);
        chk_reg(5'd23, 32'd0);
        chk_reg(5'd24, 32'd0);
        chk_reg(5'd25, 32'd42);
        chk_reg(5'd26, 32'h0000_2000);
        chk_reg(5'd27, 32'h0000_1078);
        chk_reg(5'd28, 32'h0000_0080);
        chk_reg(5'd29, 32'h0000_0098);
        chk_reg(5'd30, 32'h0000_0090);
        chk_reg(5'd31, 32'd77);
        */

        if (err == 0)
            $display("PASS: tb_pipelined_processor");
        else
            $display("FAIL: tb_pipelined_processor (%0d errors)", err);

        $finish;
        end
    end
endmodule
