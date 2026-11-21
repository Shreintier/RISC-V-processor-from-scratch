`timescale 1ns / 1ps
module alu #(
    parameter rl_var = 32
)(
    input [rl_var-1:0] a,
    input [rl_var-1:0] b,
    input [3:0] op,
    output reg [rl_var-1:0] y
);
    // Use only the low bits of b as the shift amount.
    localparam shift = $clog2(rl_var);
    // The control code selects the ALU result.
    always @(*) begin
        case(op)
            4'b0000: y = a & b; // AND
            4'b0001: y = a | b; // OR
            4'b0010: y = a + b; // ADD
            4'b0011: y = a ^ b; // XOR
            4'b0100: y = a << b[shift-1:0];
            4'b0101: y = a >> b[shift-1:0];
            4'b0110: y = a - b;
            4'b0111: y = $signed(a) >>> b[shift-1:0];
            4'b1000: y = ($signed(a) < $signed(b)) ? {{(rl_var-1){1'b0}}, 1'b1} : {rl_var{1'b0}};
            4'b1001: y = (a < b) ? {{(rl_var-1){1'b0}}, 1'b1} : {rl_var{1'b0}};
            default: y = {rl_var{1'b0}};
        endcase
    end
endmodule
