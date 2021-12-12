//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 21:26:03
// Design Name: 
// Module Name: sclk_generator_tb
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
`timescale 1ns / 1ps
module spi_master_tb;

`include "tbshare.v"

reg clk, reset;
reg pulse1, pulse2;
reg miso;
reg [3:0] bit;
reg [3:0] bit2;
wire sclk;
wire cs1, cs2;
wire mosi;
wire [7:0] data_received;
reg cpol;
reg cpha;
spi_master spi_master(.clk(clk), .reset(reset), .pulse1(pulse1), .pulse2(pulse2), .speed(1_000_000), .cpol(0), .cpha(cpha),
              .data2send(data), .miso(miso), .sclk(sclk), .cs1(cs1), .cs2(cs2), .mosi(mosi), .data_received(data_received));

initial
begin : CLOCK_GENERATOR
    clk = 1'b0;
    forever
        # CLOCK_HALF_PERIOD clk = ~clk;
end

initial
begin
    bit2 = 1'b0;
    miso = 1'b0;

    @(posedge clk);
    @(posedge clk);
    if (cpha == 1)
        #SPI_CLOCK_HALF_PERIOD;
           
    for (bit2 = 0 ; bit2 <= 7 ; bit2 = bit2 + 1)
    begin
        miso = data[7 - bit2];
        #SPI_CLOCK_NS;
    end
    #MINIMUM_PERIOD;
    for (bit2 = 0 ; bit2 <= 7 ; bit2 = bit2 + 1)
    begin
        if(data_received[bit2] !== data[bit2]) 
            $error("%0t : %d bit of received data does not match", $time, 7 - bit2);
        else
            $display("%0t : %d bit of received data matches", $time, 7 - bit2);
    end
end

initial
begin
    $timeformat(-9, 0, " ns", 5);
    reset = 1'b1;
    pulse1 = 1'b0;
    pulse2 = 1'b0;
    cpol = 0;
    cpha = 0;
    bit = 0;
    #MINIMUM_PERIOD;
    reset = 1'b0;
    #MINIMUM_PERIOD;
    if (sclk === cpol) begin
        $display("%0t : ok, initialization success", $time);
    end else begin
        $display("%0t : error, initialization failed", $time);
    end
    @(posedge clk);
    
    /*
    * pulse1
    */
    pulse1 = 1'b1;
    @(posedge clk);
    pulse1 = 1'b0;    
    #MINIMUM_PERIOD;
    
    /*
    * first test
    * check SCLK
    */       
    if (sclk === cpol) begin
        $display("%0t : ok, SCLK start!", $time);
    end else begin
        $display("%0t : error, SCLK has not started", $time);
    end

    #(3*SPI_CLOCK_HALF_PERIOD/2);
    if (sclk === ~cpol) begin
        $display("%0t : ok, SCLK works well!", $time);
    end else begin
        $display("%0t : error, SCLK error", $time);
    end
    
    /*
    * second test
    * observe the output bits.
    */
    for (bit = 0 ; bit <= 7 ; bit = bit + 1)
    begin
        if (mosi == data[7-bit]) begin
            $display("%0t : ok, %dbit matches", $time, 7 - bit);            
        end else begin
            $display("%0t : error, %dbit does not match", $time, 7 - bit);
        end
        

        #SPI_CLOCK_NS;
    end
    
    /*
    * third test
    * end transmission
    */
    @(posedge clk);
    #MINIMUM_PERIOD;
    if (sclk === cpol) begin
        $display("%0t : ok, SCLK is idle", $time);
    end else begin
        $display("%0t : error, SCLK is not idle!", $time);
    end
    if (cs1 === 1) begin
        $display("%0t : ok, cs1 is idle", $time);
    end else begin
        $display("%0t : error, cs1 is not idle!", $time);    
    end
    if (cs2 === 1) begin
        $display("%0t : ok, cs2 is idle", $time);
    end else begin
        $display("%0t : error, cs2 is not idle!", $time);    
    end 
    #SPI_CLOCK_NS;
    
    /*
    * REPEAT :
    * first test
    */       
    @(posedge clk);
    cpha = 1;
    # 5;
    pulse2 = 1'b1;
    @(posedge clk);
    pulse2 = 1'b0;    
    #MINIMUM_PERIOD;
    if (sclk === cpol) begin
        $display("%0t : ok, SCLK start!", $time);
    end else begin
        $display("%0t : error, SCLK has not started", $time);
    end

    # (3*SPI_CLOCK_HALF_PERIOD/2);
    if (sclk === ~cpol) begin
        $display("%0t : ok, SCLK works well!", $time);
    end else begin
        $display("%0t : error, SCLK error", $time);
    end

   /*
    * Test2
    * Observe the output bits.
    */    
    for (bit = 0 ; bit <= 7 ; bit = bit + 1)
    begin
        if (mosi == data[7-bit]) begin
            $display("%0t : ok, %dbit matches", $time, 7 - bit);            
        end else begin
            $display("%0t : error, %dbit does not match", $time, 7 - bit);
        end
        #SPI_CLOCK_NS;
    end

    @(posedge clk);
    #MINIMUM_PERIOD;
    if (sclk === cpol) begin
        $display("%0t : ok, SCLK is idle", $time);
    end else begin
        $display("%0t : error, SCLK is not idle!", $time);
    end
    if (cs1 === 1) begin
        $display("%0t : ok, cs1 is idle", $time);
    end else begin
        $display("%0t : error, cs1 is not idle!", $time);    
    end
    if (cs2 === 1) begin
        $display("%0t : ok, cs2 is idle", $time);
    end else begin
        $display("%0t : error, cs2 is not idle!", $time);    
    end      
end
endmodule
