//////////////////////////////////////////////////////////////////////////////////
// Module Name: control
// Description: Main Control Unit for a Single-Cycle/Pipelined RISC-V Core.
//              Decodes the 7-bit opcode, 3-bit funct3, and bit 30 of funct7 
//              to generate all necessary datapath execution control signals.
//////////////////////////////////////////////////////////////////////////////////

module control (
    // Instruction Fields (Inputs)
    input [6:0] opcode,       // Instruction opcode field (inst[6:0]) - determines instruction class
    input [2:0] funct3,       // Instruction funct3 field (inst[14:12]) - qualifies specific operations
    input funct7_5,           // Bit 30 of the instruction (inst[30]) - distinguishes ADD/SUB and SRL/SRA

    // Datapath Control Signals (Outputs)
    output reg branch,        // Asserted high for conditional branch instructions (e.g., BEQ, BNE)
    output reg jump,          // Asserted high for unconditional jump instructions (JAL and JALR)
    output reg jalr,          // Asserted high ONLY for JALR instruction to handle target mechanics
    output reg mem_read,      // Data Memory Read Enable - asserted high for Load instructions
    output reg [1:0] mem_to_reg, // RegFile Write-Data MUX: 00 = ALU Result, 01 = Memory Data, 10 = PC + 4
    output reg [3:0] alu_op,     // 4-bit operational code routed to the execution ALU
    output reg mem_write,     // Data Memory Write Enable - asserted high for Store instructions
    output reg [1:0] alu_src_a,  // ALU Operand A MUX: 00 = rs1 register, 01 = PC value, 10 = Zero (32'b0)
    output reg alu_src,       // ALU Operand B MUX: 0 = rs2 register, 1 = Immediate value
    output reg reg_write      // Register File Write Enable - asserted high if writing back to destination (rd)
);

    // Combinational evaluation block: re-triggers anytime any instruction input changes
    always @(*) begin 
        
        // ====================================================================
        // DEFAULT INITIALIZATIONS
        // ====================================================================
        // Setting every control output to a default state at the start prevents 
        // Verilog from inferring unintended transparent hardware latches.
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        reg_write  = 1'b0;
        alu_src    = 1'b0;     // Default: Route Register rs2 to ALU input B
        alu_src_a  = 2'b00;    // Default: Route Register rs1 to ALU input A
        mem_to_reg = 2'b00;    // Default: Route ALU output data back to Register File
        alu_op     = 4'b0000;  // Default: Force ALU to perform an ADD operation

        // ====================================================================
        // MAIN OPCODE DECODING CASE STATEMENT
        // ====================================================================
        case (opcode)

            // ----------------------------------------------------------------
            // R-TYPE INSTRUCTIONS (Register-to-Register Arithmetic/Logic)
            // Opcodes covered: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            // ----------------------------------------------------------------
            7'b0110011: begin
                reg_write = 1'b1;  // Calculation result must be stored back into register 'rd'
                
                case (funct3)
                    // Differentiate between ADD and SUB using instruction bit 30
                    3'b000: alu_op = funct7_5 ? 4'b0001 : 4'b0000; // 4'b0001 = SUB, 4'b0000 = ADD
                    3'b001: alu_op = 4'b0101;                       // SLL  (Shift Left Logical)
                    3'b010: alu_op = 4'b1000;                       // SLT  (Set Less Than - Signed)
                    3'b011: alu_op = 4'b1001;                       // SLTU (Set Less Than - Unsigned)
                    3'b100: alu_op = 4'b0100;                       // XOR  (Bitwise Exclusive OR)
                    // Differentiate between SRL and SRA using instruction bit 30
                    3'b101: alu_op = funct7_5 ? 4'b0111 : 4'b0110; // 4'b0111 = SRA, 4'b0110 = SRL
                    3'b110: alu_op = 4'b0011;                       // OR   (Bitwise Logical OR)
                    3'b111: alu_op = 4'b0010;                       // AND  (Bitwise Logical AND)
                    default: alu_op = 4'b0000;                      // Safe fallback to ADD
                endcase
            end

            // ----------------------------------------------------------------
            // I-TYPE ALU INSTRUCTIONS (Register-Immediate Arithmetic/Logic)
            // Opcodes covered: ADDI, SLLI, SLTI, SLTIU, XORI, SRLI, SRAI, ORI, ANDI
            // ----------------------------------------------------------------
            7'b0010011: begin
                alu_src   = 1'b1;  // Override MUX: Use the decoded immediate payload as ALU Input B
                reg_write = 1'b1;  // Save immediate execution result back into register 'rd'
                
                case (funct3)
                    3'b000: alu_op = 4'b0000;                       // ADDI
                    3'b001: alu_op = 4'b0101;                       // SLLI
                    3'b010: alu_op = 4'b1000;                       // SLTI
                    3'b011: alu_op = 4'b1001;                       // SLTIU
                    3'b100: alu_op = 4'b0100;                       // XORI
                    // Differentiate between SRLI and SRAI using instruction bit 30
                    3'b101: alu_op = funct7_5 ? 4'b0111 : 4'b0110; // 4'b0111 = SRAI, 4'b0110 = SRLI
                    3'b110: alu_op = 4'b0011;                       // ORI
                    3'b111: alu_op = 4'b0010;                       // ANDI
                    default: alu_op = 4'b0000;                      // Safe fallback to ADD
                endcase
            end

            // ----------------------------------------------------------------
            // LOAD INSTRUCTIONS (Data Memory Fetches)
            // Opcodes covered: LB, LH, LW, LBU, LHU
            // ----------------------------------------------------------------
            7'b0000011: begin
                alu_src    = 1'b1;  // ALU Input B = Immediate offset
                mem_to_reg = 2'b01; // Override MUX: Select RAM data stream to write to the Register File
                reg_write  = 1'b1;  // Enable target register write capability
                mem_read   = 1'b1;  // Assert data memory read signal line
                alu_op     = 4'b0000; // ALU performs ADD to compute target: Address = rs1 + Immediate
            end

            // ----------------------------------------------------------------
            // STORE INSTRUCTIONS (Data Memory Writes)
            // Opcodes covered: SB, SH, SW
            // ----------------------------------------------------------------
            7'b0100011: begin
                alu_src    = 1'b1;  // ALU Input B = Immediate offset
                mem_write  = 1'b1;  // Assert data memory write strobe line to save values to RAM
                alu_op     = 4'b0000; // ALU performs ADD to compute target: Address = rs1 + Immediate
            end

            // ----------------------------------------------------------------
            // BRANCH INSTRUCTIONS (Conditional Control Flow Transfers)
            // Opcodes covered: BEQ, BNE, BLT, BGE, BLTU, BGEU
            // ----------------------------------------------------------------
            7'b1100011: begin
                branch = 1'b1;      // Tells branch evaluation module to check state
                alu_op = 4'b0001;   // Force ALU to SUB (rs1 - rs2) to generate comparison flags (Zero/Sign)
            end

            // ----------------------------------------------------------------
            // JAL INSTRUCTION (Jump and Link - Unconditional PC Relative Jump)
            // ----------------------------------------------------------------
            7'b1101111: begin
                jump       = 1'b1;  // Signals control logic to change program execution counter stream
                reg_write  = 1'b1;  // Save linking address to the destination file
                mem_to_reg = 2'b10; // Override MUX: Direct PC+4 return address link to the Register File
            end

            // ----------------------------------------------------------------
            // JALR INSTRUCTION (Jump and Link Register - Absolute Target Jump)
            // ----------------------------------------------------------------
            7'b1100111: begin
                jump       = 1'b1;  // Flags an unconditional program flow leap
                jalr       = 1'b1;  // Flags JALR context to handle target boundary adjustments
                alu_src    = 1'b1;  // ALU Input B = Immediate offset
                reg_write  = 1'b1;  // Save linking address to the destination file
                mem_to_reg = 2'b10; // Override MUX: Direct PC+4 return address link to the Register File
                alu_op     = 4'b0000; // ALU performs ADD to determine target location: Target = rs1 + Immediate
            end

            // ----------------------------------------------------------------
            // LUI INSTRUCTION (Load Upper Immediate)
            // ----------------------------------------------------------------
            7'b0110111: begin
                reg_write  = 1'b1;  // Enable target register update
                alu_src    = 1'b1;  // ALU Input B = Shifted Upper Immediate payload
                alu_src_a  = 2'b10; // Override MUX: Send hardcoded zero value (32'b0) to ALU Input A
                alu_op     = 4'b0000; // ALU performs ADD (0 + Immediate) to cleanly pass value to 'rd'
            end
         // ----------------------------------------------------------------
	// AUIPC INSTRUCTION (Add Upper Immediate to PC)
	// ----------------------------------------------------------------
	7'b0010111: begin
	reg_write  = 1'b1;  // Enable target register update
	alu_src    = 1'b1;  // ALU Input B = Shifted Upper Immediate payload
	alu_src_a  = 2'b01; // Override MUX: Pass current PC instruction pointer to ALU Input A
	alu_op     = 4'b0000; // ALU performs ADD (PC + Immediate) to establish a base pointer
	end
	// Fallback safety case block
	default: begin
	// Retains default structural safety initializations defined above
		end
	endcase
	end
endmodule

