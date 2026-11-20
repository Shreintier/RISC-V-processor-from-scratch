`timescale 1ns / 1ps
module imm_gen #(
    parameter rl_var = 32
)(
    input [31:0] inst,
    output reg [rl_var-1:0] imm
);
    always@(*) begin
        case(inst[6:0])
            7'b0010011,
            7'b0000011,
            7'b1100111: imm = {{(rl_var-12){inst[31]}}, inst[31:20]};
            7'b0100011: imm = {{(rl_var-12){inst[31]}}, inst[31:25], inst[11:7]};
            7'b1100011: imm = {{(rl_var-13){inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            7'b0110111,
            7'b0010111: imm = {{(rl_var-31){inst[31]}}, inst[30:12], 12'b0};
            7'b1101111: imm = {{(rl_var-21){inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
            default: imm = {rl_var{1'b0}};
        endcase
    end
endmodule
