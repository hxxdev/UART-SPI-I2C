`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 14:21:25
// Design Name: 
// Module Name: spi
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
module spi(
    input clk, //
    input reset, //
    input mode, // master or slave?
    input [27:0] speed,
    input cpol,
    input cpha,
    input [7:0] data2send, //
    input send1, //
    input send2, //
    input master_miso, // 
    input slave_mosi, //
    input slave_sclk, //
    input slave_cs, //
    output [7:0] data_received, //
    output master_sclk, //
    output master_mosi, //
    output slave_miso, //
    output master_cs1, //
    output master_cs2 //
);

`include "commshare.v"

wire [7:0] slave_data_received, master_data_received;
wire pulse1, pulse2;

assign data_received = (mode == SLAVE ? slave_data_received : master_data_received);
 
pulse_generator pulse_generator1(.clk(clk), .reset(reset), .src(send1), .pulse(pulse1));
pulse_generator pulse_generator2(.clk(clk), .reset(reset), .src(send2), .pulse(pulse2));

spi_master spi_master(.clk(clk), .reset(reset), .pulse1(pulse1), .pulse2(pulse2), .data2send(data2send), .speed(speed), .cpol(cpol), .cpha(cpha),
                      .sclk(master_sclk), .cs1(master_cs1), .cs2(master_cs2), .mosi(master_mosi), .miso(master_miso), .data_received(master_data_received));
spi_slave spi_slave(.clk(clk), .reset(reset), .cpol(cpol), .cpha(cpha), .sclk(slave_sclk), .cs(slave_cs), .mosi(slave_mosi),
                    .miso(slave_miso), .data2send(data2send), .data_received(slave_data_received));
endmodule
