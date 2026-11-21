`timescale 1ns / 1ps
module regfile #(
    parameter rl_var = 32
)(
    input clk,
    input rst,
    input reg_write,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [rl_var-1:0] write_data,
    output [rl_var-1:0] data_reg1,
    output [rl_var-1:0] data_reg2
);
    reg [rl_var-1:0] regs [0:31];
    integer i;
    // Clear the registers on reset. Writes to x0 are ignored.
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i = 0; i < 32; i = i + 1)
                regs[i] <= {rl_var{1'b0}};
        end else if(reg_write && (write_reg != 5'd0)) begin
            regs[write_reg] <= write_data;
        end
    end
    // Read x0 as zero and use WB data if it is writing the same register.
    assign data_reg1 = (read_reg1 == 5'd0) ? {rl_var{1'b0}} :
                       ((reg_write && (write_reg == read_reg1)) ? write_data : regs[read_reg1]);
    assign data_reg2 = (read_reg2 == 5'd0) ? {rl_var{1'b0}} :
                       ((reg_write && (write_reg == read_reg2)) ? write_data : regs[read_reg2]);
endmodule
