`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/11 15:32:27
// Design Name: 
// Module Name: spi_slave
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
module spi_slave(
    input clk,
    input reset,
    input cpol,
    input cpha,
    input sclk,
    input cs,
    input mosi,
    input [7:0] data2send,
    output reg miso,
    output reg [7:0] data_received
);

// internal signals
reg [1:0] sclkr;
reg [1:0] csr;

reg signed [4:0] bit4tx;

wire cs_fedge = (csr == 2'b10);
wire cs_redge = (csr == 2'b01);

wire time2sample = (cpha == 0) ? (sclkr == {cpol, !cpol}) : (sclkr == {!cpol, cpol});
wire time2send = (bit4tx != -1) && (cpha == 0 ? ((sclkr == {!cpol, cpol}) || cs_fedge) : (sclkr == {cpol, !cpol}));

// state variables
reg [3:0] state, next_state;

localparam IDLE = 2'd0;
localparam DATA_PHASE = 2'd1;

always @ (posedge clk or posedge reset)
begin : DETECT_CS
    if (reset) begin
        csr <= 2'b11;
    end else begin
        csr <= {csr[0], cs};
    end
end

always @ (posedge clk or posedge reset)
begin : DETECT_EDGE
    if (reset) begin
        sclkr <= {cpol, cpol};
    end else begin
        sclkr <= {sclkr[0], sclk};
    end
end

always @ (*)
begin : NEXT_STATE_TABLE
    case (state)
        IDLE : begin
            if (cs_fedge) begin
                next_state = DATA_PHASE;
            end else begin
                next_state = state;
            end
        end
        DATA_PHASE : begin
            if (cs_redge) begin
                next_state = IDLE;
            end else begin
                next_state = state;
            end
        end
        default : begin
            next_state = IDLE;
        end
        
    endcase
end

always @ (posedge clk or posedge reset)
begin : STATE_FF
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;        
    end
end

always @ (posedge clk or posedge reset)
begin : SLAVE_MOSI
    if (reset) begin
        data_received <= 0;
    end else begin
        if (state == DATA_PHASE) begin
            if (time2sample ) begin
                data_received <= {data_received[6:0], mosi};
            end
        end
    end
end

always @ (posedge clk or posedge reset)
begin : SLAVE_MISO
    if (reset) begin
        bit4tx <= 7;
    end else begin
        if (state == IDLE) begin
            if (time2send) begin
                miso <= data2send[bit4tx];
                bit4tx <= bit4tx - 1;
            end else begin
                miso <= 1'bz; 
                bit4tx <= 7;
            end       
        end else if (state == DATA_PHASE) begin
            if (time2send) begin
                miso <=  data2send[bit4tx];
                bit4tx <= bit4tx - 1;
            end
        end
    end
end
endmodule
