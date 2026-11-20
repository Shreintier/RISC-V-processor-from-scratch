`timescale 1ns / 1ps

module tb_pipelined_processor;
    reg clk;
    reg rst;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    reg [1023:0] hex_file;
    reg [1023:0] dump_file;
    reg [1023:0] line;
    reg [31:0] last_pc;
    reg finished;

    integer fd;
    integer file_count;
    integer idx;
    integer cyc;
    integer err;
    integer instr_count;
    integer max_cycles;
    integer loop_count;

    pipelined_processor #(.rl_var(32)) dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    // 10 ns clock period (100 MHz)
    always #5 clk = ~clk;

    // Log executed instructions and stop once terminal `jal x0, 0` loop stabilizes
    always @(posedge clk) begin
        if (!rst) begin
            $display("cycle=%0d pc=%h inst=%h", cyc, pc_out, instruction_out);
            cyc <= cyc + 1;

            if ((pc_out == last_pc) && (instruction_out == 32'h0000006f)) begin
                loop_count <= loop_count + 1;
                if (loop_count == 4)
                    finished <= 1'b1;
            end else begin
                loop_count <= 0;
            end

            last_pc <= pc_out;
        end
    end

    task chk_reg(input [4:0] r, input [31:0] exp);
        begin
            if (dut.rf.regs[r] !== exp) begin
                $display("fail x%0d got=%h exp=%h", r, dut.rf.regs[r], exp);
                err = err + 1;
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        cyc = 0;
        err = 0;
        instr_count = 0;
        max_cycles = 0;
        loop_count = 0;
        last_pc = 32'hffff_ffff;
        finished = 1'b0;

        if (!$value$plusargs("hex=%s", hex_file))
            hex_file = "program.hex";
        if (!$value$plusargs("dump=%s", dump_file))
            dump_file = "reg_dump.txt";

        $readmemh(hex_file, dut.imem.mem);

        file_count = $fopen(hex_file, "r");
        if (file_count == 0) begin
            $display("ERROR: Cannot open program file %0s", hex_file);
            $finish;
        end

        while ($fgets(line, file_count)) begin
            if (line != 0 && line != "\n" && line != "\r\n")
                instr_count = instr_count + 1;
        end
        $fclose(file_count);

        max_cycles = (instr_count * 10) + 30;
        if ($value$plusargs("cycles=%d", max_cycles))
            $display("Using custom cycle limit.");

        $display("------------------------------------");
        $display("Program file       : %0s", hex_file);
        $display("Instructions loaded: %0d", instr_count);
        $display("Cycle limit        : %0d", max_cycles);
        $display("------------------------------------");

        #12 rst = 0;

        for (idx = 0; idx < max_cycles; idx = idx + 1) begin
            @(posedge clk);
            #1;
            if (finished)
                idx = max_cycles;
        end

        if (!finished)
            $display("Simulation stopped: cycle limit reached (%0d).", max_cycles);
        else
            $display("Terminal loop detected. Simulation completed.");

        fd = $fopen(dump_file, "w");
        if (fd == 0) begin
            $display("ERROR: Could not open register dump file.");
            err = err + 1;
        end else begin
            for (idx = 0; idx < 32; idx = idx + 1) begin
                $fdisplay(fd, "x%0d = 0x%08h (%0d)",
                          idx, dut.rf.regs[idx], $signed(dut.rf.regs[idx]));
            end
            $fclose(fd);
            $display("Register dump saved to %0s", dump_file);
        end

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
endmodule