`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/26 23:10:53
// Design Name: 
// Module Name: uart_8bytes_tx_tb
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
module uart_8bytes_tx_tb;

`include "tbshare.v"

// input output ports for module under test
reg clk, reset;
reg [63:0] bytes2send;
reg [3:0] bytes_num;
reg pulse;
wire tx;

// variables for test 
reg expected;

uart_8bytes_tx uart_8bytes_tx (.clk(clk), .reset(reset), .bytes2send(bytes2send), .bytes_num(bytes_num), .pulse(pulse), .tx(tx));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # CLOCK_HALF_PERIOD clk = ~clk;
end

initial
begin : INITIALIZATION
    $timeformat(-9, 0, "ns", 5);
    $display("%0t : now the simulation starts...", $time);
    
    // initialize variables
    reset = 0;
    bytes2send = 0;
    pulse = 0;
    expected = 0;
    bytes_num = 0;
end

initial
begin : TEST_PROGRAM
    // global reset
    # CLOCK_NS;
    reset = 1;
    # CLOCK_NS;
    reset = 0;
    # MINIMUM_PERIOD;
    expected = (tx === 0);
    if (!expected) $error("%0t : tx line reset error", $time);
    
    // delay before test
    @(posedge clk);
    # CLOCK_NS;
    
    // input test1
    bytes2send = {'haaaaaaaaaa, "\n"};
    bytes_num = 2;
    pulse = 1;
    # CLOCK_NS;
    pulse = 0;
    
    // delay before test
    @(posedge clk);
    # (UART_CLOCK_NS * 80);
        
    // input test2
    bytes2send = "ABCDEFG\n";
    bytes_num = 8;
    pulse  = 1;
    # CLOCK_NS;
    pulse = 0;
    
    // delay before test
    @(posedge clk);
    # (UART_CLOCK_NS * 10);    
    
end
endmodule
