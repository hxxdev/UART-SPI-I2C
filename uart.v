`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 12:47:58
// Design Name: 
// Module Name: uart
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
module uart(
    input clk,
    input reset,
    input send,
    input [19:0] speed, // BAUD_RATE = 110, 300, 600, 1200, 2400, 4800, 9600, 14400, 19200,
                        //             38400, 57600, 115200, 230400,460800, 921600
    input [7:0] tx_data,
    input rx,
    output tx,
    output [7:0] rx_data
);
    
wire pulse;

pulse_generator pulse_generator(.clk(clk), .reset(reset), .src(send), .pulse(pulse));
//clock_generator #(.FREQ(BAUD_RATE)) clock_generator(.clk(clk), .reset(reset), .new_clk(new_clk));
uart_rx uart_rx(.clk(clk), .reset(reset), .speed(speed), .rx(rx), .rx_data(rx_data), .rx_busy(), .clr_buffer());
uart_byte_tx uart_byte_tx(.clk(clk), .reset(reset), .speed(speed), .tx_data(tx_data), .pulse(pulse), .tx(tx));

endmodule
