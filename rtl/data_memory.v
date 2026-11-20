`timescale 1ns / 1ps
module data_memory #(
    parameter rl_var = 32,
    parameter bytes = 4096
)(
    input clk,
    input mem_read,
    input mem_write,
    input [rl_var-1:0] addr,
    input [rl_var-1:0] write_data,
    input [2:0] funct3,
    output reg [rl_var-1:0] read_data
);
    localparam idx_w = $clog2(bytes);
    reg [7:0] mem [0:bytes-1];
    wire [idx_w-1:0] idx = addr[idx_w-1:0];
    integer i;
    initial begin
        for(i = 0; i < bytes; i = i + 1)
            mem[i] = 8'd0;
    end
    always@(posedge clk) begin
        if(mem_write) begin
            case(funct3)
                3'b000: mem[idx] <= write_data[7:0];
                3'b001: begin
                    mem[idx] <= write_data[7:0];
                    mem[idx+1] <= write_data[15:8];
                end
                3'b010: begin
                    mem[idx] <= write_data[7:0];
                    mem[idx+1] <= write_data[15:8];
                    mem[idx+2] <= write_data[23:16];
                    mem[idx+3] <= write_data[31:24];
                end
                default: begin
                end
            endcase
        end
    end
    generate
        if(rl_var >= 64) begin : wide_store
            always@(posedge clk) begin
                if(mem_write && (funct3 == 3'b011)) begin
                    mem[idx] <= write_data[7:0];
                    mem[idx+1] <= write_data[15:8];
                    mem[idx+2] <= write_data[23:16];
                    mem[idx+3] <= write_data[31:24];
                    mem[idx+4] <= write_data[39:32];
                    mem[idx+5] <= write_data[47:40];
                    mem[idx+6] <= write_data[55:48];
                    mem[idx+7] <= write_data[63:56];
                end
            end
        end
    endgenerate
    wire [31:0] word_val = {mem[idx+3], mem[idx+2], mem[idx+1], mem[idx]};
    wire [15:0] half_val = {mem[idx+1], mem[idx]};
    wire [7:0] byte_val = mem[idx];
    always@(*) begin
        if(!mem_read) begin
            read_data = {rl_var{1'b0}};
        end else begin
            case(funct3)
                3'b000: read_data = {{(rl_var-8){byte_val[7]}}, byte_val};
                3'b001: read_data = {{(rl_var-16){half_val[15]}}, half_val};
                3'b010: read_data = {{(rl_var-31){word_val[31]}}, word_val[30:0]};
                3'b100: read_data = {{(rl_var-8){1'b0}}, byte_val};
                3'b101: read_data = {{(rl_var-16){1'b0}}, half_val};
                default: read_data = {rl_var{1'b0}};
            endcase
            if(rl_var >= 64) begin
                if(funct3 == 3'b110)
                    read_data = {{(rl_var-32){1'b0}}, word_val};
                else if(funct3 == 3'b011)
                    read_data = {{(rl_var-63){mem[idx+7][7]}}, mem[idx+7][6:0], mem[idx+6], mem[idx+5], mem[idx+4], word_val};
            end
        end
    end
endmodule
