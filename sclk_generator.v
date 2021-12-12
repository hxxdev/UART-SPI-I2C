`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 19:49:43
// Design Name: 
// Module Name: sclk_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module sclk_generator(
    input clk,
    input reset,
    input ntrigger,
    output sclk
);

`include "spishare.v"

parameter COUNT_VALUE = (100_000_000 / SPEED / 2) - 1;

reg reg_sclk;
reg [7:0] counter;

assign sclk = reg_sclk;

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        counter <= 0;
        reg_sclk <= CPOL;
    end else begin
        if (~ntrigger) begin          
            if (counter == 0) begin
                reg_sclk <= ~reg_sclk;
                counter <= counter + 1;
            end else if (counter == COUNT_VALUE) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end else begin
            counter <= 0;
            reg_sclk <= CPOL;
        end
    end
end

endmodule
