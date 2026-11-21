`timescale 1ns / 1ps
module instruction_memory #(
    parameter rl_var = 32,
    parameter addr_var = 1024
)(
    input [rl_var-1:0] pc,
    output [31:0] instruction
);
    localparam idx_w = $clog2(addr_var);
    reg [31:0] mem [0:addr_var-1];
    integer i;
    // Clear unused entries before loading the program.
    initial begin
        for(i = 0; i < addr_var; i = i + 1)
            mem[i] = 32'd0;
        $readmemh("program.mem", mem);
    end
    // Each instruction takes four bytes, so skip the low two PC bits.
    assign instruction = mem[pc[idx_w+1:2]];
endmodule
