`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/26 19:50:47
// Design Name: 
// Module Name: console_tb
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


module console_tb;

`include "tbshare.v"
`include "consoleshare.v"
// input, output port of 'console' module
reg clk, reset;
wire rx, tx;
wire [1:0] mode;
wire [19:0] uart_speed;
wire [27:0] spi_speed;
wire [23:0] i2c_speed;

// input port of 'uart_8bytes_tx' module
reg [63:0] command2send;
reg [3:0] bytes_num;
reg send;

// ports of 'uart_rx' module
wire [7:0] received_data;

// internal variables
reg expected;

// module under test.
console console(.clk(clk), .reset(reset), .rx(rx), .tx(tx), .mode(mode), .uart_speed(uart_speed), .spi_speed(spi_speed), .i2c_speed(i2c_speed));

// controller
uart_8bytes_tx controller_tx(.clk(clk), .reset(reset), .speed(SERIAL_SPEED), .bytes2send(command2send), .bytes_num(bytes_num), .pulse(send), .tx(rx));
uart_rx controller_rx(.clk(clk), .reset(reset), .speed(SERIAL_SPEED), .rx(tx), .rx_data(received_data), .rx_busy());

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
    # (CLOCK_HALF_PERIOD) clk = ~clk;
end

initial
begin : TEST_PROGRAM
    $timeformat(-9, 0, " ns", 5);
    $display("%0t : now the simulation starts...", $time);

    // initialize
    reset = 0;
    expected = 0;
    command2send = 0;
    send = 0;
    # CLOCK_NS;

    // global reset
    // time : 1 cycle
    reset = 1;
    # MINIMUM_PERIOD;
    reset = 0;
    # MINIMUM_PERIOD;

    // reset test
    // time : 1.2 cycle
    expected = (mode === UART);
    if (!expected) $error("%0t : mode reset error", $time);
    expected = (tx === 0);
    if (!expected) $error("%0t : tx line reset error", $time);
    expected = (uart_speed === 9600);
    if (!expected) $error("%0t : uart speed reset error", $time);
    expected = (spi_speed === 1_000_000);
    if (!expected) $error("%0t : spi speed reset error", $time);
    expected = (i2c_speed === 100_000);
    if (!expected) $error("%0t : i2c speedreset error", $time);

    @(posedge clk);
    # CLOCK_NS;

    // give pulse
    // time : 3rd cycle
    command2send = {"AT", CR, "\n"};
    bytes_num = 4;
    send = 1;
    # CLOCK_NS;
    send = 0;

    // huge delay
    @(posedge clk);
    # 900000;

    command2send = {"ABCDE", CR, "\n"};
    bytes_num = 4;
    send = 1;
    # CLOCK_NS;
    send = 0;
    
    // huge delay
    @(posedge clk);
    # 1200000;

    command2send = {"AT", CR, "\n"};
    bytes_num = 4;
    send = 1;
    # CLOCK_NS;
    send = 0;    
    
end
endmodule
