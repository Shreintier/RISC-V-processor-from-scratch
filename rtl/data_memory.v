module data_memory (input clk,input mem_read,input mem_write,input [31:0] addr,
            input [31:0] write_data,input [2:0] funct3,output reg [31:0] read_data
);

    reg [31:0] mem [0:255]; //1024 bytes of storage
    reg [31:0] shifted_data;

    //Asynchronous read
    always @(*) begin
        read_data = 32'b0;
        shifted_data = 32'b0;

        if(mem_read) begin
            // Select the addressed word and byte position
            shifted_data = mem[addr[9:2]] >> (8 * addr[1:0]);

            case(funct3)
                3'b000: // Load signed byte
                    read_data = {{24{shifted_data[7]}}, shifted_data[7:0]};
                3'b001: // Load signed halfword
                    read_data = {{16{shifted_data[15]}}, shifted_data[15:0]};
                3'b101: // Load unsigned halfword
                    read_data = {16'b0, shifted_data[15:0]};
                3'b010: // Load word
                    read_data = mem[addr[9:2]];
                3'b100: // Load unsigned byte
                    read_data = {24'b0, shifted_data[7:0]};
                default: read_data = 32'b0;
            endcase
        end
    end

    //Synchronous write
    always @(posedge clk) begin
        if(mem_write) begin

            case (funct3)
                3'b000: begin //Store byte
                    case(addr[1:0])
                        2'b00: mem[addr[9:2]][7:0] <= write_data[7:0];
                        2'b01: mem[addr[9:2]][15:8] <= write_data[7:0];
                        2'b10: mem[addr[9:2]][23:16] <= write_data[7:0];
                        2'b11: mem[addr[9:2]][31:24] <= write_data[7:0];
                    endcase
                end
                3'b001: begin //Store halfword
                    if(addr[1]==1'b0)
                        mem[addr[9:2]][15:0] <= write_data[15:0];
                    else
                        mem[addr[9:2]][31:16] <= write_data[15:0];
                end
                3'b010: begin // Store word
                    mem[addr[9:2]] <= write_data;
                end
                default: begin
                    //No write
                end
            endcase
        end
    end
endmodule
