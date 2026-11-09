module program_counter(
    input clk,
    input rst,
    input [31:0] imm,
    input [31:0] rs1_data,
    input branch,
    input branch_taken,
    input jump,
    input jalr,
    output reg [31:0] pc
);

    reg [31:0] next_pc;

    //next_pc selection logic
    always @(*) begin
        next_pc= pc+ 32'd4;

        // JALR
        if(jump && jalr)
            next_pc= (rs1_data+imm) & 32'hFFFFFFFE;

        // JAL
        else if(jump)
            next_pc= pc + imm;

        // Conditional branch
        else if(branch && branch_taken)
            next_pc= pc + imm;
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            pc<= 32'b0;
        else
            pc<= next_pc;
    end
endmodule