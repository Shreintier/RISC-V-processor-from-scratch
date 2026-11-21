`timescale 1ns / 1ps
// RV32M unit: MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
module mul_div_unit #(
    parameter rl_var = 32
)(
    input [rl_var-1:0] a,
    input [rl_var-1:0] b,
    input [2:0] funct3,
    output reg [rl_var-1:0] result
);
    // Add one bit so the same multiplier can handle signed and unsigned inputs.
    wire a_signed = (funct3 == 3'b001) || (funct3 == 3'b010); // MULH, MULHSU
    wire b_signed = (funct3 == 3'b001); // MULH only

    wire signed [rl_var:0] mul_a = {a_signed ? a[rl_var-1] : 1'b0, a};
    wire signed [rl_var:0] mul_b = {b_signed ? b[rl_var-1] : 1'b0, b};
    wire signed [(2*rl_var)+1:0] mul_prod = mul_a * mul_b;

    // Handle division by zero and the smallest signed value divided by -1.
    wire div_by_zero = (b == {rl_var{1'b0}});
    wire div_overflow = (a == {1'b1, {(rl_var-1){1'b0}}}) && (b == {rl_var{1'b1}});
    wire [rl_var-1:0] safe_b = div_by_zero ? {{(rl_var-1){1'b0}}, 1'b1} : b;

    wire signed [rl_var-1:0] s_div = $signed(a) / $signed(safe_b);
    wire [rl_var-1:0] u_div = a / safe_b;
    wire signed [rl_var-1:0] s_rem = $signed(a) % $signed(safe_b);
    wire [rl_var-1:0] u_rem = a % safe_b;

    always @(*) begin
        case(funct3)
            3'b000: result = mul_prod[rl_var-1:0]; // MUL
            3'b001: result = mul_prod[(2*rl_var)-1:rl_var]; // MULH
            3'b010: result = mul_prod[(2*rl_var)-1:rl_var]; // MULHSU
            3'b011: result = mul_prod[(2*rl_var)-1:rl_var]; // MULHU
            3'b100: begin // DIV
                if(div_by_zero)
                    result = {rl_var{1'b1}};
                else if(div_overflow)
                    result = {1'b1, {(rl_var-1){1'b0}}};
                else
                    result = s_div;
            end
            3'b101: result = div_by_zero ? {rl_var{1'b1}} : u_div; // DIVU
            3'b110: begin // REM
                if(div_by_zero)
                    result = a;
                else if(div_overflow)
                    result = {rl_var{1'b0}};
                else
                    result = s_rem;
            end
            3'b111: result = div_by_zero ? a : u_rem; // REMU
            default: result = {rl_var{1'b0}};
        endcase
    end
endmodule
