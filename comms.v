`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 16:14:17
// Design Name: 
// Module Name: comms
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
module comms(
    input clk,
    input BTNC,
    input BTNU,
    input BTND,
    input BTNR,
    input BTNL,
    input[7:0] D_SW,
    output [7:0] LED,    
    output JA1,
    input JA2,
    output JA3,
    input JA4,
    output JB1,
    input JB2,
    output JB3,
    output JB7,
    output JB8,
    input JA7,
    output JA8,
    input JA9,
    input JA10,
    output JB9,
    inout JB10, 
    input JC1_N,
    inout JC1_P
);

`include "consoleshare.v"
`include "i2cshare.v"
/*
* mode : which data to monitor. uart or spi or i2c?
*/ 
wire [1:0] mode;

/*
* UART related variables
* uart_speed : baudrate of uart protocol.
*/
wire [7:0] uart_data_received;
wire [19:0] uart_speed;

/*
* SPI related variables
* spi_mode : slave or master?
* cpol : cpol of spi protocol. refer to spi documentation.
* cpha : cpha of spi protocol. refer to spi documentation.
*/
wire [7:0] spi_data_received;
wire spi_mode, cpol, spha;
wire [27:0] spi_speed;

/*
* I2C related variables
* i2c_mode : slave or master?
*
*/
wire [7:0] i2c_data_received;
wire i2c_mode;
wire [23:0] i2c_speed;

assign LED = (mode == UART ? uart_data_received : (mode == SPI ? spi_data_received : i2c_data_received));

 // console
console console(.clk(clk), .reset(BTNC), .tx(JA1), .rx(JA2), .mode(mode), .uart_speed(uart_speed), .spi_speed(spi_speed), 
                 .spi_mode(spi_mode), .spi_cpol(cpol), .spi_cpha(cpha),
                 .i2c_mode(i2c_mode), .i2c_speed(i2c_speed));   

//uart
uart uart(.clk(clk), .reset(BTNC), .speed(uart_speed), .send(BTND), .tx_data(D_SW), .rx(JA4), .tx(JA3), .rx_data(uart_data_received));

//spi
spi spi(.clk(clk), .reset(BTNC), .mode(spi_mode), .speed(spi_speed), .cpol(cpol), .cpha(cpha), .data2send(D_SW), .data_received(spi_data_received), 
        .send1(BTNR), .send2(BTNL), .master_sclk(JB1), .master_miso(JB2), .master_mosi(JB3), .master_cs1(JB7), .master_cs2(JB8),
         .slave_sclk(JA7), .slave_miso(JA8), .slave_mosi(JA9), .slave_cs(JA10));
          
//i2c
i2c i2c(.clk(clk), .reset(BTNC), .speed(i2c_speed), .mode(i2c_mode), .addr2send(D_SW[6:0]), .data2send(D_SW), .send(BTNU),
        .master_scl(JB9), .master_sda(JB10), .slave_scl(JC1_N), .slave_sda(JC1_P), .data_received(i2c_data_received));
        
endmodule
