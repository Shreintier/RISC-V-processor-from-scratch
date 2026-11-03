module regfile( input clk,rst,reg_write, 
                input [4:0] read_reg1,read_reg2,write_reg,
                input [31:0] write_data,
                output [31:0] data_reg1,data_reg2);
    reg [31:0] registers[0:31];
    integer i;
    always @(posedge clk or posedge rst) begin //Asynchronus reset
        if(rst) begin
            for(i=0; i<32; i=i+1) begin
                registers[i]<=0;
            end
        end
        else begin
            if(reg_write==1 && write_reg!=0) begin
                registers[write_reg]<= write_data;
            end
        end
    end
    //Asynchronous read or assign
    assign data_reg1 = registers[read_reg1];
    assign data_reg2 = registers[read_reg2];
    // x0 is always zero according to the procedural logic above, no need for distinction in assigning here
endmodule; 