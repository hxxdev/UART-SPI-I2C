`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 12:48:23
// Design Name: 
// Module Name: uart_tx
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
module uart_byte_tx (
    input clk,
    input reset,
    input [19:0] speed,
    input [7:0] tx_data,
    input pulse,
    output reg tx,
    output reg tx_busy
);

localparam DATA_BIT = 4'd8;

reg [3:0] i;
reg [19:0] counter;
reg [DATA_BIT + 1:0] frame;
wire [19:0] COUNT_VALUE = 1000_000_00 / speed;

always @ (*)
begin
    frame = {1'b1, tx_data, 1'b0};
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        counter <= 1'b0;
        tx <= 1'b1;
        i <= 0;
        tx_busy <= 0;        
    end else begin
        if (pulse) begin
            tx_busy <= 1'b1;
        end else if (i == DATA_BIT + 3) begin
           tx_busy <= 1'b0;
           tx <= 1'b1;
           counter <= 0;
        end    
        
        if (tx_busy) begin
            if (counter == 0) begin
                if (i <= DATA_BIT + 1) begin
                    tx <= frame[i];
                end
                i <= i + 1;
                counter <= counter + 1;
            end else if (counter == COUNT_VALUE) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end else begin
            i <= 0;
        end
    end
end
endmodule
