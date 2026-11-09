module instruction_memory(input [31:0] addr,output [31:0] inst);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for(i=0; i<256; i=i+1)
            mem[i] = 32'b0;
        $readmemh("instructions.hex", mem);
    end
    assign inst = mem[addr[9:2]];
endmodule