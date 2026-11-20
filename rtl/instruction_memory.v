`timescale 1ns / 1ps
module instruction_memory #(
    parameter rl_var = 32,
    parameter words = 1024
)(
    input [rl_var-1:0] addr,
    output [31:0] inst
);
    localparam idx_w = $clog2(words);
    reg [31:0] mem [0:words-1];
    integer i;
    initial begin
        for(i = 0; i < words; i = i + 1)
            mem[i] = 32'd0;
    end
    assign inst = mem[addr[idx_w+1:2]];
endmodule
