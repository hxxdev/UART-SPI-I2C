`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 20:22:19
// Design Name: 
// Module Name: clock_generator_tb
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


module clock_generator_tb;

parameter BAUD_RATE = 9600;
parameter CLOCK_NS = 10;
localparam CLOCK_HALF_PERIOD = CLOCK_NS / 2;
localparam MINIMUM_PERIOD = CLOCK_NS / 10;

reg clk, reset;
wire new_clk;

clock_generator #(.FREQ(BAUD_RATE)) clock_generator (.clk(clk), .reset(reset), .new_clk(new_clk));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        #CLOCK_HALF_PERIOD clk = ~clk;
end

initial
begin
    reset = 1'b1;
    #MINIMUM_PERIOD;
    reset = 1'b0;
end
endmodule
