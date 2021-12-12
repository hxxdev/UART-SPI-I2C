`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/06 13:38:11
// Design Name: 
// Module Name: uart_rx_tb
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
module uart_rx_tb;

`include "tbshare.v"


reg clk, reset;
reg rx;
reg [3:0] i;
wire [DATA_BIT - 1:0] rx_data;

uart_rx uart_rx(.clk(clk), .reset(reset), .rx(rx), .rx_data(rx_data));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        #CLOCK_HALF_PERIOD clk = ~clk;
end

initial
begin
    $display("simulation of uart_rx begins...");

    i = 0;
    clk = 1'b0;
    reset = 1'b0;
    rx = 1'b1;
    
    /*--------------------------------------------------------
     * Initialization Test
     *--------------------------------------------------------*/
    #MINIMUM_PERIOD;
    reset = 1'b1;
    #MINIMUM_PERIOD;
    reset = 1'b0;
    #MINIMUM_PERIOD;
    if (rx_data !== 8'b0) begin
        $error("%t : check initialization", $time);        
    end
    @ (posedge clk);

    
    /*--------------------------------------------------------
     * Test1
     *--------------------------------------------------------*/
     for(i = 0 ; i <= DATA_BIT ; i = i + 1)
     begin
        rx = frame[i];
         #UART_CLOCK_NS;
     end
     rx = 1'b1;
     #MINIMUM_PERIOD;
     if (rx_data !== data) begin
        $error("%t : data does not match", $time);
     end else begin
        $display("%t : data matches", $time);
     end
     #UART_CLOCK_NS;
     @ (posedge clk);
     
     /*--------------------------------------------------------
     * Test2
     *--------------------------------------------------------*/
     for(i = 0 ; i <= DATA_BIT ; i = i + 1)
     begin
        rx = frame[i];
         #UART_CLOCK_NS;
     end
     rx = 1'b1;
     #MINIMUM_PERIOD;
     if (rx_data !== data) begin
        $error("%t : data does not match", $time);
     end else begin
        $display("%t : data matches", $time);
     end
     @ (posedge clk);
end
endmodule