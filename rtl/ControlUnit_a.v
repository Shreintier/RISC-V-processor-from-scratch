
// Description: Main Control Unit for RISC-V Core. Decodes the opcode to generate general datapath, memory, and high-level ALU control signals.


module control_a (
    input [6:0] opcode,          // Instruction opcode field (inst[6:0])

    output reg branch,           // high for conditional branches
    output reg jump,             // high for unconditional jumps (JAL/JALR)
    output reg jalr,             // high ONLY for JALR
    output reg mem_read,         // Data Memory Read Enable
    output reg [1:0] mem_to_reg, // RegFile Write-Data MUX: 00 = ALU, 01 = Mem, 10 = PC+4
    output reg [1:0] alu_op,     // ALU operation code sent to Control B
    output reg mem_write,        // Data Memory Write Enable
    output reg [1:0] alu_src_a,  // ALU Operand A MUX: 00 = rs1, 01 = PC, 10 = Zero
    output reg alu_src,          // ALU Operand B MUX: 0 = rs2, 1 = Immediate
    output reg reg_write         // Register File Write Enable
);

    always @(*) begin        
        // Default initializations
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        alu_src_a  = 2'b00;
        mem_to_reg = 2'b00;
        alu_op     = 2'b00;  

        case (opcode)
            // R-TYPE INSTRUCTIONS (ADD, SUB, SLL, SLT, etc.)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_op    = 2'b10; // R-type arithmetic
            end

            // I-TYPE ALU INSTRUCTIONS (ADDI, SLLI, SLTI, etc.)
            7'b0010011: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b10; // I-type arithmetic
            end

            // LOAD INSTRUCTIONS (LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                alu_src    = 1'b1;
                mem_to_reg = 2'b01;
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                alu_op     = 2'b00; // ADD (rs1 + immediate)
            end

            // STORE INSTRUCTIONS (SB, SH, SW)
            7'b0100011: begin
                alu_src    = 1'b1;
                mem_write  = 1'b1;
                alu_op     = 2'b00; // ADD (rs1 + immediate)
            end

            // BRANCH INSTRUCTIONS (BEQ, BNE, BLT, etc.)
            7'b1100011: begin
                branch = 1'b1;
                alu_op = 2'b01; // Branch evaluation (SUB)
            end

            // JAL INSTRUCTION (Jump and Link)
            7'b1101111: begin
                jump       = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 2'b10; // Return address PC + 4
            end

            // JALR INSTRUCTION (Jump and Link Register)
            7'b1100111: begin
                jump       = 1'b1;
                jalr       = 1'b1;
                alu_src    = 1'b1;
                reg_write  = 1'b1;
                mem_to_reg = 2'b10;
                alu_op     = 2'b00; // ADD (rs1 + immediate)
            end

            // LUI INSTRUCTION (Load Upper Immediate)
            7'b0110111: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_src_a  = 2'b10; // Zero (32'b0)
                alu_op     = 2'b00; // ADD (0 + immediate)
            end

            // AUIPC INSTRUCTION (Add Upper Immediate to PC)
            7'b0010111: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_src_a  = 2'b01; // PC value
                alu_op     = 2'b00; // ADD (PC + immediate)
            end

            default: begin
            end
        endcase
    end
endmodule
