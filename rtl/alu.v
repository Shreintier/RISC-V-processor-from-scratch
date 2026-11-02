module alu(input [31:0] a,b,input [2:0] op,output reg [31:0] y);
    always @(*) begin
        case(op)
            3'b000: y = a + b;  // add
            3'b001: y = a - b;  // sub
            3'b010: y = a & b;  // bitwise AND
            3'b011: y = a | b;  // bitwise OR
            3'b100: y = a ^ b;  // bitwise XOR
            default: y = 32'b0;
        endcase
    end
endmodule