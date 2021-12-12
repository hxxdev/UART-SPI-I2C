`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/18 18:46:44
// Design Name: 
// Module Name: i2c_slave_tb
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


module i2c_slave_tb;

`include "tbshare.v"

reg clk, reset;
reg scl, sda;
wire [7:0] data_received;

i2c_master i2c_master(.clk(clk), .reset(reset), .data2send(data), .pulse(pulse), .scl(scl), .sda(sda));
i2c_slave i2c_slave(.clk(clk), .reset(reset), .scl(scl), .sda(sda), .data_received(data_received));



initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # CLOCK_NS clk =  ~clk;
end

initial
begin
    reset = 1'b0;
    # MINIMUM_PERIOD;
    reset = 1'b1;
    @ (posedge clk);

    reset = 1'b0;

end
endmodule
