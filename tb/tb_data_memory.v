`timescale 1ns / 1ps
module tb_data_memory;
    reg clk,mr,mw;
    reg [31:0] addr,wd;
    reg [2:0] f3;
    wire [31:0] rd;
    integer err=0;
    data_memory #(.rl_var(32),.bytes(64)) dut(
        .clk(clk),.mem_read(mr),.mem_write(mw),
        .addr(addr),.write_data(wd),.funct3(f3),.read_data(rd)
    );
    always #5 clk=~clk;

    task check_read(input [2:0] funct3, input [31:0] expected);
        begin
            @(negedge clk);
            mw = 0;
            mr = 1;
            f3 = funct3;
            @(posedge clk); #1;
            if (rd !== expected) begin
                $display("funct3=%b got=%h expected=%h", funct3, rd, expected);
                err = err + 1;
            end
        end
    endtask

    initial begin
        clk=0; mr=0; mw=1; addr=32'd4; wd=32'h89ab_cdef; f3=3'b010;
        // The first rising edge writes the word. Reads start on the next cycle.
        check_read(3'b010, 32'h89ab_cdef); // LW
        check_read(3'b000, 32'hffff_ffef); // LB
        check_read(3'b100, 32'h0000_00ef); // LBU
        check_read(3'b001, 32'hffff_cdef); // LH
        check_read(3'b101, 32'h0000_cdef); // LHU
        if(err==0)
            $display("pass tb_data_memory");
        else
            $display("fail tb_data_memory (%0d)",err);
        $finish;
    end
endmodule
