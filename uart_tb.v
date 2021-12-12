`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/06 21:38:59
// Design Name: 
// Module Name: uart_tb
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


module uart_tb;

`include "commsshare.v"
`include "uartshare.v"

reg clk, reset;
reg send;
reg [7:0] tx_data;
reg rx;
wire tx;
wire [7:0] rx_data;
reg [3:0] i;

uart uart(.clk(clk), .reset(reset), .send(send), .tx_data(tx_data), .rx(rx), .tx(tx), .rx_data(rx_data));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        #CLOCK_HALF_PERIOD clk = ~clk;
end


initial
begin
    $display("simulation of uart_rx begins...");
    i <= DATA_BIT;
    clk <= 1'b0;
    reset <= 1'b0;
    rx <= 1'b1;
    
    /*--------------------------------------------------------
     * Initialization Test
     *--------------------------------------------------------*/
    #MINIMUM_PERIOD;
    reset <= 1'b1;
    #MINIMUM_PERIOD;
    reset <= 1'b0;
    #MINIMUM_PERIOD;
    if (rx_data !== 8'b0) begin
        $error("%t : check initialization", $time);        
    end
    @ (posedge clk);

    
    /*--------------------------------------------------------
     * Test1
     *--------------------------------------------------------*/
     for(i = DATA_BIT ; i >= 0 ; i = i - 1)
     begin
        rx = frame[i];
         #UART_CLOCK_NS;
     end
     rx = 1'b1;
     #MINIMUM_PERIOD;
     if (rx_data !== reversed) begin
        $error("%t : data does not match", $time);
     end else begin
        $display("%t : data matches", $time);
     end
     #UART_CLOCK_NS;
     @ (posedge clk);
     
     /*--------------------------------------------------------
     * Test2
     *--------------------------------------------------------*/
     for(i = DATA_BIT ; i >= 0 ; i = i - 1)
     begin
        rx = frame[i];
         #UART_CLOCK_NS;
     end
     rx = 1'b1;
     #MINIMUM_PERIOD;
     if (rx_data !== reversed) begin
        $error("%t : data does not match", $time);
     end else begin
        $display("%t : data matches", $time);
     end
     @ (posedge clk);
end

endmodule
