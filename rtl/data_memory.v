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
    localparam WORDS = bytes / 4;
    localparam WORD_ADDR_W = $clog2(WORDS);

    // Store four bytes in each word.
    (* ram_style = "block" *) reg [31:0] mem [0:WORDS-1];

    // The low address bits select a byte inside the word.
    wire [WORD_ADDR_W-1:0] word_addr = addr[WORD_ADDR_W+1:2];
    wire [1:0] byte_offset = addr[1:0];

    reg [3:0] byte_we;
    reg [31:0] aligned_wdata;

    // Pick which bytes a store will update.
    always @(*) begin
        byte_we = 4'b0000;
        aligned_wdata = 32'd0;
        if (mem_write) begin
            case (funct3)
                3'b000: begin // SB
                    byte_we[byte_offset] = 1'b1;
                    case (byte_offset)
                        2'd0: aligned_wdata[7:0]   = write_data[7:0];
                        2'd1: aligned_wdata[15:8]  = write_data[7:0];
                        2'd2: aligned_wdata[23:16] = write_data[7:0];
                        2'd3: aligned_wdata[31:24] = write_data[7:0];
                    endcase
                end
                3'b001: begin // SH (aligned halfwords: offset 0 or 2)
                    if (byte_offset[1] == 1'b0) begin
                        byte_we = 4'b0011;
                        aligned_wdata[15:0] = write_data[15:0];
                    end else begin
                        byte_we = 4'b1100;
                        aligned_wdata[31:16] = write_data[15:0];
                    end
                end
                3'b010: begin // SW
                    byte_we = 4'b1111;
                    aligned_wdata = write_data[31:0];
                end
                default: byte_we = 4'b0000;
            endcase
        end
    end

    // Reads and writes use the rising clock edge.
    reg [31:0] rdata_word;
    reg [1:0]  rdata_offset;
    reg [2:0]  rdata_funct3;
    reg        rdata_valid;

    integer i;
    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            mem[i] = 32'd0;
    end

    always @(posedge clk) begin
        // Update only the bytes selected by the store.
        if (byte_we[0]) mem[word_addr][7:0]   <= aligned_wdata[7:0];
        if (byte_we[1]) mem[word_addr][15:8]  <= aligned_wdata[15:8];
        if (byte_we[2]) mem[word_addr][23:16] <= aligned_wdata[23:16];
        if (byte_we[3]) mem[word_addr][31:24] <= aligned_wdata[31:24];

        // Save the word and the details needed to read it.
        rdata_word   <= mem[word_addr];
        rdata_offset <= byte_offset;
        rdata_funct3 <= funct3;
        rdata_valid  <= mem_read;
    end

    // Pick the requested bytes and extend them for signed or unsigned loads.
    reg [7:0]  sel_byte;
    reg [15:0] sel_half;

    always @(*) begin
        case (rdata_offset)
            2'd0: sel_byte = rdata_word[7:0];
            2'd1: sel_byte = rdata_word[15:8];
            2'd2: sel_byte = rdata_word[23:16];
            2'd3: sel_byte = rdata_word[31:24];
        endcase

        case (rdata_offset[1])
            1'b0: sel_half = rdata_word[15:0];
            1'b1: sel_half = rdata_word[31:16];
        endcase

        if (!rdata_valid) begin
            read_data = {rl_var{1'b0}};
        end else begin
            case (rdata_funct3)
                3'b000: read_data = {{(rl_var-8){sel_byte[7]}}, sel_byte};   // LB
                3'b001: read_data = {{(rl_var-16){sel_half[15]}}, sel_half}; // LH
                3'b010: read_data = {{(rl_var-32){rdata_word[31]}}, rdata_word}; // LW
                3'b100: read_data = {{(rl_var-8){1'b0}}, sel_byte};            // LBU
                3'b101: read_data = {{(rl_var-16){1'b0}}, sel_half};           // LHU
                default: read_data = {rl_var{1'b0}};
            endcase
        end
    end
endmodule
