`timescale 1ns / 1ps
module tb_alu;
    reg [31:0] a, b;
    reg [3:0] op;
    wire [31:0] y;
    integer err = 0;
    alu #(.rl_var(32)) dut(.a(a), .b(b), .op(op), .y(y));
    task check(input [31:0] exp);
        begin
            #1;
            if(y !== exp) begin
                $display("fail alu op=%b a=%h b=%h got=%h exp=%h", op, a, b, y, exp);
                err = err + 1;
            end
        end
    endtask
    initial begin
        a = 32'd15; b = 32'd10;
        op = 4'b0010; check(32'd25);
        op = 4'b0110; check(32'd5);
        op = 4'b0000; check(32'd10);
        op = 4'b0001; check(32'd15);
        op = 4'b0011; check(32'd5);
        a = 32'h8000_0008; b = 32'd2;
        op = 4'b0100; check(32'h0000_0020);
        op = 4'b0101; check(32'h2000_0002);
        op = 4'b0111; check(32'he000_0002);
        a = -32'sd5; b = 32'sd3;
        op = 4'b1000; check(32'd1);
        op = 4'b1001; check(32'd0);
        if(err == 0)
            $display("pass tb_alu");
        else
            $display("fail tb_alu (%0d)", err);
        $finish;
    end
endmodule
