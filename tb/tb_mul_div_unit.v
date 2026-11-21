`timescale 1ns / 1ps
// unit testbench for RV32M operations and corner cases
module tb_mul_div_unit;
    reg [31:0] a, b;
    reg [2:0] funct3;
    wire [31:0] result;
    integer err = 0;

    mul_div_unit #(
        .rl_var(32)
    ) dut(
        .a(a),
        .b(b),
        .funct3(funct3),
        .result(result)
    );

    initial begin
        a = -32'sd10;
        b = 32'd3;
        funct3 = 3'b000; #1; if(result !== -32'sd30) err = err + 1; // MUL
        funct3 = 3'b001; #1; if(result !== 32'hffff_ffff) err = err + 1; // MULH
        funct3 = 3'b010; #1; if(result !== 32'hffff_ffff) err = err + 1; // MULHSU
        funct3 = 3'b011; #1; if(result !== 32'd2) err = err + 1; // MULHU
        funct3 = 3'b100; #1; if(result !== -32'sd3) err = err + 1; // DIV
        funct3 = 3'b101; #1; if(result !== 32'h5555_5552) err = err + 1; // DIVU
        funct3 = 3'b110; #1; if(result !== -32'sd1) err = err + 1; // REM
        funct3 = 3'b111; #1; if(result !== 32'd0) err = err + 1; // REMU

        // divide by zero checks
        b = 32'd0;
        funct3 = 3'b100; #1; if(result !== 32'hffff_ffff) err = err + 1;
        funct3 = 3'b101; #1; if(result !== 32'hffff_ffff) err = err + 1;
        funct3 = 3'b110; #1; if(result !== -32'sd10) err = err + 1;
        funct3 = 3'b111; #1; if(result !== -32'sd10) err = err + 1;

        // signed overflow checks (-2^31 / -1)
        a = 32'h8000_0000;
        b = 32'hffff_ffff;
        funct3 = 3'b100; #1; if(result !== 32'h8000_0000) err = err + 1;
        funct3 = 3'b110; #1; if(result !== 32'd0) err = err + 1;

        if(err == 0)
            $display("pass tb_mul_div_unit");
        else
            $display("fail tb_mul_div_unit (%0d)", err);
        $finish;
    end
endmodule
