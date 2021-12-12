`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 13:28:10
// Design Name: 
// Module Name: pulse_generator_tb
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


module pulse_generator_tb;

`include "tbshare.v"

// Input signals
reg clk, reset, sw;

// Output signals
wire pulse;

// Module instantiation
pulse_generator U1(.clk(clk), .reset(reset), .src(sw), .pulse(pulse));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        #CLOCK_HALF_PERIOD clk = ~clk;
end

initial
begin : TEST_PROGRAM
    $display("TB : simulation of pulse generator starts!");
    
    /*--------------------------------------------------------
     * Initialization Test
     *--------------------------------------------------------*/
    clk = 1'b0;
    reset = 1'b0;
    sw = 1'b0;
    
    # MINIMUM_PERIOD;
    reset = 1'b1;
    # MINIMUM_PERIOD;
    reset = 1'b0;
    if (pulse !== 0)
        $error("TB : check initialization!"); 
        
    /*--------------------------------------------------------
     * Pulse test 1
     *--------------------------------------------------------*/
    @ (posedge clk);
    # MINIMUM_PERIOD;
    sw = 1'b1;
    
    @ (posedge clk);
    # MINIMUM_PERIOD
    sw = 1'b0;
    # MINIMUM_PERIOD;
    if (pulse === 0)
        $error("%t : test1, pulse is not generated!", $time); 
    else
        $display("%t : test1, good, pulse is generated.", $time);
    @ (posedge clk);
    # MINIMUM_PERIOD;
    if (pulse === 1)
        $error("%t : test1, pulse is too long!", $time);
    else
         $display("%t : test1, good, pulse lasts for one clock.", $time);
         
    /*--------------------------------------------------------
     * Pulse test 2
     *--------------------------------------------------------*/
    @ (posedge clk);
    # MINIMUM_PERIOD;
    sw = 1'b1;
    @ (posedge clk); 
    # MINIMUM_PERIOD;
    if (pulse === 0)
        $error("%t : test2, pulse is not generated!", $time); 
    else
        $display("%t : test2, good, pulse is generated.", $time);
    @ (posedge clk);
    # MINIMUM_PERIOD;
    if (pulse === 1)
        $error("%t : test2, pulse is too long!", $time);
    else
         $display("%t : test2, good, pulse lasts for one clock.", $time);
    # (MINIMUM_PERIOD * 100);
    sw = 1'b0;
    # MINIMUM_PERIOD;
    /*--------------------------------------------------------
     * Pulse test 3
     *--------------------------------------------------------*/
    @ (posedge clk);
    sw = 1'b1;
    @ (posedge clk);
    # MINIMUM_PERIOD;
    if (pulse === 0)
        $error("%t : test3, pulse is not generated!", $time); 
    else
        $display("%t : test3, good, pulse is generated.", $time);
    @ (posedge clk);
    # MINIMUM_PERIOD;
    if (pulse === 1)
        $error("%t : test3, pulse is too long!", $time);
    else
         $display("%t : test3, good, pulse lasts for one clock.", $time);
    # (MINIMUM_PERIOD * 100);
    sw = 1'b0;
    # MINIMUM_PERIOD;
end
endmodule
