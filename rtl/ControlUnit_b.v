module control_b(
    input [1:0] alu_op,
    input [2:0] funct3,
    input funct7_5,
    output reg [3:0] alu_control
);

    always @(*) begin
        alu_control = 4'b0000; 

        case(alu_op)
            // ALUOp = 2'b00: ADD for loads, stores, AUIPC, LUI, and JALR
            2'b00: alu_control = 4'b0000; 

            // ALUOp = 2'b01: Force SUB for conditional branch comparisons
            2'b01: alu_control = 4'b0001; 

            // ALUOp = 2'b10: R-Type arithmetic operations
            2'b10: begin
                case(funct3)
                    3'b000: alu_control = funct7_5 ? 4'b0001 : 4'b0000; // SUB or ADD
                    3'b001: alu_control = 4'b0101;                      // SLL
                    3'b010: alu_control = 4'b1000;                      // SLT
                    3'b011: alu_control = 4'b1001;                      // SLTU
                    3'b100: alu_control = 4'b0100;                      // XOR
                    3'b101: alu_control = funct7_5 ? 4'b0111 : 4'b0110; // SRA or SRL
                    3'b110: alu_control = 4'b0011;                      // OR
                    3'b111: alu_control = 4'b0010;                      // AND
                    default: alu_control = 4'b0000;                    
                endcase
            end

            // ALUOp = 2'b11: I-Type arithmetic operations (ADDI never subtracts!)
            2'b11: begin
                case(funct3)
                    3'b000: alu_control = 4'b0000;                      // ADDI (always ADD)
                    3'b001: alu_control = 4'b0101;                      // SLLI
                    3'b010: alu_control = 4'b1000;                      // SLTI
                    3'b011: alu_control = 4'b1001;                      // SLTIU
                    3'b100: alu_control = 4'b0100;                      // XORI
                    3'b101: alu_control = funct7_5 ? 4'b0111 : 4'b0110; // SRAI or SRLI
                    3'b110: alu_control = 4'b0011;                      // ORI
                    3'b111: alu_control = 4'b0010;                      // ANDI
                    default: alu_control = 4'b0000;                    
                endcase
            end

            default: alu_control = 4'b0000;
        endcase
    end
endmodule
