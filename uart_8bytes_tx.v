`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/26 22:25:57
// Design Name: 
// Module Name: uart_8bytes_tx
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
module uart_8bytes_tx(
    input clk,
    input reset,
    input [19:0] speed,
    input [63:0] bytes2send,
    input [3:0] bytes_num,
    input pulse,
    output tx,
    output reg tx_busy_8bytes
);

localparam IDLE = 3'd0;
localparam READY = 3'd1;
localparam TRIGGER = 3'd2;
localparam XMIT = 3'd3;

reg send_byte;
reg [2:0] state, next_state;
reg [63:0] fifo;
reg signed [7:0] ptr;
reg [7:0] byte2send;

wire tx_busy_1byte;
reg [1:0] tx_busy_r;

uart_byte_tx uart_byte_tx(.clk(clk), .reset(reset), .speed(speed), .tx_data(byte2send), .pulse(send_byte), .tx(tx), .tx_busy(tx_busy_1byte));

always @ (*)
begin
    if (state == IDLE) begin
        if (pulse) begin
            next_state = READY;
        end else begin
            next_state = state;
        end
    end else if (state == READY) begin
        next_state = TRIGGER;
    end else if (state == TRIGGER) begin
        next_state = XMIT;
    end else if (state == XMIT) begin                
        if (tx_busy_r == 2'b10 && ptr > 0) begin
            next_state = TRIGGER;
        end else if (ptr == -1) begin
            next_state = IDLE;
        end else begin
            next_state = state;
        end
    end else begin
        next_state = IDLE;
    end
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @ (posedge clk)
begin
    tx_busy_r <= {tx_busy_r[0], tx_busy_1byte};
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        send_byte <= 0;
        fifo <= 0;
        ptr <= 63;
        tx_busy_8bytes <= 0;
        byte2send <= 0;
    end else begin
        if (state == IDLE) begin
            send_byte <= 0;
            fifo <= 0;
            ptr <= 8 * bytes_num - 1;
            if (pulse) 
                tx_busy_8bytes <= 1;
            else
                tx_busy_8bytes <= 0;
        end else if (state == READY) begin
            fifo <= bytes2send;
        end else if (state == TRIGGER) begin
            if (ptr >= 7) 
                byte2send <= fifo[ptr -: 8];
            send_byte <= 1;
            ptr <= ptr - 8;
        end else if (state == XMIT) begin
            send_byte <= 0;
        end
    end
end
endmodule
