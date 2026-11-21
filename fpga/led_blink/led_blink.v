`timescale 1ns / 1ps
module led_blink(input clk, output reg led = 1'b0);
    reg [25:0] count = 26'd0;
    // The board clock runs at 100 MHz. Toggle the LED every half second.
    always @(posedge clk) begin
        if (count == 26'd49999999) begin
            count <= 26'd0;
            led <= ~led;
        end else begin
            count <= count + 26'd1;
        end
    end
endmodule
