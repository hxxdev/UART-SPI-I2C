`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/13 15:50:19
// Design Name: 
// Module Name: i2c
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
module i2c(
    input clk,
    input reset,
    input [23:0] speed,
    input mode,
    input [6:0] addr2send,
    input [7:0] data2send,
    input send,
    input slave_scl,
    inout slave_sda,    
    output master_scl,
    inout master_sda,
    output [7:0] data_received
);

`include "i2cshare.v"

wire pulse;

pulse_generator pulse_generator1(.clk(clk), .reset(reset), .src(send), .pulse(pulse));

i2c_master i2c_master(.clk(clk), .reset(reset), .speed(speed), .addr2send(addr2send), .data2send(data2send), .pulse(pulse), .scl(master_scl), .sda(master_sda));
i2c_slave i2c_slave(.clk(clk), .reset(reset), .scl(slave_scl), .sda(slave_sda), .data_received(data_received));
    
endmodule
