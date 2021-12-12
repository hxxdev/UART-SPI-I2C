`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 12:48:38
// Design Name: 
// Module Name: uart_rx
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
module uart_rx (
    input clk,
    input reset,
    input [19:0] speed,
    input rx,
    input clr_buffer,
    output [7:0] rx_data,
    output reg rx_busy
);

localparam DATA_BIT = 4'd8;

reg [DATA_BIT:0] frame;
reg [19:0] counter;
reg [4:0] i;
wire [19:0] COUNT_VALUE = 1000_000_00 / speed;

assign rx_data = frame[DATA_BIT:1];

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        frame <= 0;
        counter <= 0;
        i <= 0;
        rx_busy <= 1'b0;
    end else begin
        // clear buffer
        if (clr_buffer) begin
            frame <= 0;
            counter <= 0;
            i <= 0;
            rx_busy <= 0;
            
        // receive data into buffer    
        end else begin        
            if (rx_busy == 1'b0 && rx == 0) begin
                rx_busy <= 1'b1;
            end else if (rx_busy == 1'b1) begin
                if (counter == COUNT_VALUE / 2) begin
                    frame[i] <= rx;
                    i <= i + 1;
                    counter <= counter + 1;
                end else if (counter == COUNT_VALUE) begin
                    counter <= 0;
                    if (i == DATA_BIT + 1) begin
                        rx_busy <= 1'b0;
                        i <= 0;
                    end
                end else begin
                    counter <= counter + 1;
                end
            end
        end
    end
end
endmodule