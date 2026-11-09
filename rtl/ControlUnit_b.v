// ALU Control Unit.Decodes  alu_op from control a, along with funct3 and funct7_5, to generate the 4-bit control signal for the ALU.

module control_b(input [1:0] alu_op,input [2:0] funct3,input funct7_5,
            output reg [3:0] alu_control);

    always @(*) begin

        alu_control = 4'b0000; 

        case(alu_op)
            // ALUOp = 2'b00:  ADD for loads, stores, AUIPC, LUI, and JALR base address calculation
            2'b00: alu_control = 4'b0000; 

            // ALUOp = 2'b01: Force SUB for conditional branch comparisons (rs1 - rs2)
            2'b01: alu_control = 4'b0001; 

            // ALUOp = 2'b10: R-Type or I-Type arithmetic operations decoded via funct3 & funct7[5]
            2'b10: begin
                case(funct3)
                    3'b000: alu_control = funct7_5 ? 4'b0001 : 4'b0000; // SUB (if bit30=1) or ADD (if bit30=0)
                    3'b001: alu_control = 4'b0101;                      // SLL (Shift Left Logical)
                    3'b010: alu_control = 4'b1000;                      // SLT (Set Less Than Signed)
                    3'b011: alu_control = 4'b1001;                      // SLTU (Set Less Than Unsigned)
                    3'b100: alu_control = 4'b0100;                      // XOR (Bitwise Exclusive OR)
                    3'b101: alu_control = funct7_5 ? 4'b0111 : 4'b0110; // SRA (if bit30=1) or SRL (if bit30=0)
                    3'b110: alu_control = 4'b0011;                      // OR (Bitwise Logical OR)
                    3'b111: alu_control = 4'b0010;                      // AND (Bitwise Logical AND)
                    default: alu_control = 4'b0000;                    
                endcase
            end

            default: alu_control = 4'b0000;
        endcase
    end
endmodule
