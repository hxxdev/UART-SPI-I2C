`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/11 21:13:23
// Design Name: 
// Module Name: spi_slave_tb
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


module spi_slave_tb;

`include "tbshare.v"

// input registers
reg clk, reset;
reg sclk;
reg cs;
reg mosi;
reg cpol, cpha;

// output ports
wire miso;
wire [7:0] data_received;

// registers for test
reg expected;
reg [3:0] bit;
reg [3:0] laps;

spi_slave spi_slave(.clk(clk), .reset(reset), .cpol(cpol), .cpha(cpha), .sclk(sclk), .cs(cs), .mosi(mosi), 
                    .data2send(data), .miso(miso), .data_received(data_received));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        #CLOCK_HALF_PERIOD clk = ~clk;
end

/*********************
* Now the test begins.
**********************/
initial 
begin : TEST_PROGRAM
    $display("Now the simulation begins...");
    $timeformat(-9, 0, " ns", 5);
    
    cpol = 0;
    cpha = 0;    
    sclk = cpol;
    cs = 1'b1;
    mosi = 1'b0;
    expected = 1'b0;
    bit = 0;
    laps = 0;
    
    // Initialization Test
    reset = 1'b1;
    #MINIMUM_PERIOD;
    reset = 1'b0;
    #MINIMUM_PERIOD;
    expected = (miso === 1'b0);
    if (!expected)
        $error("%0t : check initialization of 'miso'.", $time);
    expected = (data_received === 0);
    if (!expected)
        $error("%0t : check initialization of 'data_received'.", $time);
    @ (posedge clk);
    
    for(laps = 0 ; laps < 4 ; laps = laps + 1)
    begin
        // MOSI test
        cs = 1'b0;
        
        // test for mode 1, mode 3
        if (cpha == 1) begin
            #SPI_CLOCK_HALF_PERIOD;
            for (bit = 0 ; bit <= 7 ; bit = bit + 1)
            begin
                sclk = ~sclk;
                mosi = data[7-bit];
                #SPI_CLOCK_HALF_PERIOD;
                sclk = ~sclk;
    
                expected = (miso === data[7 - bit]);        
                if (!expected) $error("%0t : error, %d bit of miso does not match.", $time, 7 - bit);
                else $display("%0t : good, %d bit of miso matches.", $time, 7 - bit);
                        
                #SPI_CLOCK_HALF_PERIOD;
                
                
            end 
            
            // timing : data bit ends
            cs = 1'b1;
            mosi = 1'b0;
            
        //test for mode 0 and mode 2 
        end else begin
            for(bit = 0 ; bit <= 7 ; bit = bit + 1) 
            begin
                mosi = data[7 - bit];
                #SPI_CLOCK_HALF_PERIOD;
                sclk = ~sclk;
        
                expected = (miso === data[7 - bit]);        
                if (!expected) $error("%0t : error, %d bit of miso does not match.", $time, 7 - bit);
                else $display("%0t : good, %d bit of miso matches.", $time, 7 - bit);
                
                #SPI_CLOCK_HALF_PERIOD;
                sclk = ~sclk;
            end
            
            // timing : data bit ends
            mosi = 1'b0;        
            #SPI_CLOCK_HALF_PERIOD;
            cs = 1'b1;
    
        end
        # 5000;
    end
    
    
            
end
endmodule
