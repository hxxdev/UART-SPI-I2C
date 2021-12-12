`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 19:51:45
// Design Name: 
// Module Name: uart_tx_tb
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
module uart_tx_tb;

`include "tbshare.v"

reg clk, reset;
reg pulse;
reg [4:0] i;
wire tx;


uart_byte_tx uart_byte_tx(.clk(clk), .reset(reset), .tx_data(data), .pulse(pulse), .tx(tx));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        #CLOCK_HALF_PERIOD clk = ~clk; 
end

initial
begin
    $display("simulation of uart_tx begins...");
    
    clk <= 1'b0;
    pulse <= 1'b0;
    reset <= 1'b0;
    i <= 0;
    
    /*--------------------------------------------------------
     * Initialization Test
     *--------------------------------------------------------*/
    #MINIMUM_PERIOD;
    reset <= 1'b1;
    #MINIMUM_PERIOD;
    reset <= 1'b0;
    #MINIMUM_PERIOD;
    if (tx !== 1'b1) begin
        $error("%t : check initialization", $time);        
    end
    @ (posedge clk);
    
    /*--------------------------------------------------------
     * Test1
     *--------------------------------------------------------*/
     pulse <= 1'b1;
     #CLOCK_NS;
     pulse <= 1'b0;
     #CLOCK_NS;
     #(UART_CLOCK_NS/2);  
     for(i = 0 ; i <= DATA_BIT ; i = i + 1)
     begin
         if (tx !== frame[i]) begin
            $error("%tus : %d bit does not match", $time/1000, DATA_BIT - i);
         end else begin
            $display("%tus : %d bit matches", $time/1000, DATA_BIT - i);
         end
         #UART_CLOCK_NS;
     end
     @ (posedge clk);

    /*--------------------------------------------------------
     * Test2
     *--------------------------------------------------------*/
     pulse <= 1'b1;
     #CLOCK_NS;
     pulse <= 1'b0;
     #CLOCK_NS;
     #(UART_CLOCK_NS/2);  
     for(i = 0 ; i <= DATA_BIT ; i = i + 1)
     begin
         if (tx !== frame[i]) begin
            $error("%tns : %d bit does not match", $time, DATA_BIT - i);
         end else begin
            $display("%tns : %d bit matches", $time, DATA_BIT - i);
         end
         #UART_CLOCK_NS;
     end
     @ (posedge clk);     
end
endmodule
