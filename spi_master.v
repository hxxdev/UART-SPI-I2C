`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/09 15:32:02
// Design Name: 
// Module Name: spi_master
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
module spi_master(
    input clk,
    input reset,
    input pulse1,
    input pulse2,
    input [27:0] speed,
    input [7:0] data2send,
    input cpol,
    input cpha,
    input miso,
    output reg sclk,
    output reg cs1,
    output reg cs2,
    output reg mosi,
    output reg [7:0] data_received
);

localparam IDLE = 3'd0;
localparam CHIP1SELECT = 3'd1;
localparam CHIP2SELECT = 3'd2;
localparam CPHA0DELAY = 3'd3;
localparam CPHA1DELAY = 3'd4;
localparam CPHA0_DATA_PHASE = 3'd5;
localparam CPHA1_DATA_PHASE = 3'd6;

/*
*  Internal signals
*/
reg [7:0] counter;
reg signed [4:0] bit4tx;
reg signed [4:0] bit4rx;

reg [3:0] state, next_state;
reg activate_counter;

wire [11:0] COUNT_VALUE = (100_000_000 / speed) - 1;
wire [10:0] HALF_COUNT_VALUE = (COUNT_VALUE + 1) / 2 - 1;
wire full_counted = (counter == COUNT_VALUE);
wire half_counted = (counter == HALF_COUNT_VALUE);

always @ (*)
begin
    case (state)
        IDLE : begin
            if (pulse1)
                next_state = CHIP1SELECT;
            else if (pulse2)                
                next_state = CHIP2SELECT;                                      
            else
                next_state = state;
        end
        CHIP1SELECT, CHIP2SELECT : begin
            if (cpha == 0)
                next_state = CPHA0_DATA_PHASE;
            else
                next_state = CPHA1DELAY;
        end
        CPHA1DELAY : begin
            if (half_counted)
                next_state = CPHA1_DATA_PHASE;
            else 
                next_state = state;
        end
        CPHA0_DATA_PHASE, CPHA1_DATA_PHASE: begin
            if (bit4tx == -1) begin
                if (cpha == 0)
                    next_state = CPHA0DELAY;
                else if (cpha == 1)
                    next_state = IDLE;
                else
                    next_state = IDLE;
            end else begin
                next_state = state;
            end
        end
        CPHA0DELAY : begin
            if (half_counted)
                next_state = IDLE;
            else
                next_state = state;
        end
        default : begin
            next_state = IDLE;
        end
    endcase
end

always @ (posedge clk or posedge reset)
begin : COUNTING_PROGRAM
    if (reset) begin
        counter <= 0;
    end else begin
        if (activate_counter) begin
            if (counter == COUNT_VALUE)
                counter <= 0;
            else
                counter <= counter + 1;
         end else begin
            counter <= 0;
         end
    end
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
begin : SCLK_GENERATOR
    if (reset) begin
        sclk <= cpol;
    end else begin
        if (state == IDLE) begin
            sclk <= cpol;
        end else if (state == CPHA0_DATA_PHASE && bit4tx >=0) begin
            if(half_counted || full_counted) begin
                sclk <= ~sclk;
            end
        end else if (state == CPHA1_DATA_PHASE && bit4tx >= 0) begin
            if (counter == 0 || half_counted) begin
                sclk <= ~ sclk;
            end
        end else begin
            sclk <= 0;
        end
    end
end

always @ (posedge clk or posedge reset)
begin : CS_MOSI_GENERATOR
    if (reset) begin
        bit4tx <= 7;
        cs1 <= 1;
        cs2 <= 1;
        activate_counter <= 0;
        mosi <= 1'bz;
    end else begin
        if (state == IDLE) begin
            cs1 <= 1;
            cs2 <= 1;
            mosi <= 1'bz;
            bit4tx <= 7;           
            activate_counter <= 0;
        end else if (state == CHIP1SELECT) begin
            cs1 <= 0;        
        end else if (state == CHIP2SELECT) begin
            cs2 <= 0;           
        end else if (state == CPHA1DELAY) begin
            mosi <= 0;
            activate_counter <= 1;
            if (half_counted)
                activate_counter <= 0; 
        end else if (state == CPHA0_DATA_PHASE || state == CPHA1_DATA_PHASE) begin
            activate_counter <= 1;
            if (counter == 0) begin
                if (bit4tx >= 0) begin
                    mosi <= data2send[bit4tx];                    
                end 
            end else if (full_counted) begin
                bit4tx <= bit4tx - 1;
                if (bit4tx == -1)
                    activate_counter <= 0;
            end            
        end else if (state == CPHA0DELAY) begin
            mosi <= 1'bz;
            activate_counter <= 1;
        end
    end
end

/*
* receive data from MISO line
*/
always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        data_received <= 0;
        bit4rx <= 7;
    end else begin
        if (bit4rx != -1) begin
            if (state == CPHA0_DATA_PHASE || state == CPHA1_DATA_PHASE) begin
                if (half_counted) begin
                    data_received[bit4rx] <= miso;
                    bit4rx <= bit4rx - 1;
                end 
            end
        end else begin
            bit4rx <= 7;
        end         
    end
end
endmodule