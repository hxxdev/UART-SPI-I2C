`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/13 16:08:16
// Design Name: 
// Module Name: i2c_master
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
module i2c_master #(parameter NUM_OF_FRAMES = 2) (
    input clk,
    input reset,
    input [23:0] speed,
    input [6:0] addr2send,
    input [7:0] data2send,
    input pulse,
    output scl,
    inout sda
);

`include "i2cshare.v"

wire [9:0] COUNT_VALUE = (100_000_000 / speed) - 1; 
wire [9:0] PERIOD_4Q = COUNT_VALUE;
wire [9:0] PERIOD_3Q =  3 * COUNT_VALUE / 4;
wire [8:0] PERIOD_2Q =   COUNT_VALUE / 2;
wire [7:0] PERIOD_1Q =  COUNT_VALUE / 4;

PULLUP i0 (.O(sda));
PULLUP i1 (.O(scl));

reg reg_sda;
reg reg_scl;
wire sda_in;

// internal variables
reg sda_driving;
reg scl_driving;
reg [11:0] counter;
reg [3:0] state, next_state;
reg signed [4:0] bit;
reg addr_acknowledged;
reg data_acknowledged;

assign sda = sda_driving ? reg_sda : 1'bz;
assign scl = scl_driving ? reg_scl : 1'bz;
assign sda_in = sda_driving ? 1'bz : sda;

always @ (*)
begin
    if (state == IDLE) begin
        if (pulse) begin
            next_state = START;
        end else begin
            next_state = state;
        end
        
    end else if (state == START) begin
        if (counter == PERIOD_4Q) begin
            next_state = ADDR;
        end else begin
            next_state = state;
        end
        
    end else if (state == ADDR) begin
        if (bit == -1 && counter == PERIOD_4Q) begin
            next_state = RW;
        end else begin
            next_state =  state;
        end
    end else if (state == RW) begin
        if (counter == PERIOD_4Q) begin
            next_state = ADDR_ACK;
        end else begin
            next_state = state;
        end    
    end else if (state == ADDR_ACK) begin
        if (counter == PERIOD_4Q) begin
            if (addr_acknowledged == 1 && (NUM_OF_FRAMES > 1)) begin
                next_state = DATA1;
            end else begin
                next_state = STOP;
            end
        end else begin
            next_state = state;
        end
    end else if (state == DATA1) begin
        if (bit == -1 && counter == PERIOD_4Q) begin
            next_state = DATA1_ACK;
        end else begin
            next_state = state;
        end    
    end else if (state == DATA1_ACK) begin
        if (counter == PERIOD_4Q) begin
            next_state = STOP;            
        end else begin
            next_state = state;
        end
    end else if (state == STOP) begin
        if (counter == PERIOD_4Q) begin
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

always @ (posedge clk or posedge reset)
begin : COUNTER
    if (reset) begin
        counter <= 0;    
    end else begin
        if (state != IDLE) begin
            if (counter == PERIOD_4Q) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
end

always @ (posedge clk or posedge reset)
begin : SCL_GENERATOR
    if (reset) begin
        reg_scl <= 0;
        scl_driving <= 0;
    end else begin
            if (state == IDLE) begin
                scl_driving <= 0;
            end else begin             
                if (state == START) begin
                    scl_driving <= 1;               
                    if (counter == 0) begin
                        reg_scl <= 1;
                    end else if (counter == PERIOD_2Q) begin
                        reg_scl <= 0;
                    end
                    
                end else if (state ==  STOP) begin
                    scl_driving <= 0;
                    
                end else begin
                    if (counter == PERIOD_1Q) begin
                        reg_scl <= 1;
                    end else if (counter == PERIOD_3Q) begin
                        reg_scl <= 0;
                    end
                end
            end
    end
end

always @ (posedge clk or posedge reset)
begin : SDA_GENERATOR
    if (reset) begin
        bit <= 6;
        addr_acknowledged <= 0;
        data_acknowledged <= 0;
        sda_driving <= 0;
        reg_sda <= 0;
        
    end else begin        
        if (state == IDLE) begin
            sda_driving <= 0;
            reg_sda <= 0;
            addr_acknowledged <= 0;
            data_acknowledged <= 0;            
            bit <= 6;
            
        end else if (state == START) begin
            sda_driving <= 1;
            if (counter == 0) begin
                reg_sda <= 0;
            end else if (counter == PERIOD_4Q) begin
                reg_sda <= addr2send[bit];
                bit <= bit - 1;
            end
            
        end else if (state == ADDR) begin
            if (counter == PERIOD_4Q) begin
                reg_sda <= (bit >= 0 ? addr2send[bit] : 1'b0); // address + write bit(0)
                bit <= bit - 1;    
            end
            
        end else if (state == RW) begin
            if (counter == PERIOD_4Q) begin
                sda_driving <= 0;            
            end
            
        end else if (state == ADDR_ACK) begin
            if (counter == PERIOD_1Q) begin
                bit <= 7;            
                if (sda_in == 0) begin
                    addr_acknowledged <= 1;
                end else begin
                    addr_acknowledged <= 0;
                end
            end else if (counter == PERIOD_4Q) begin
                sda_driving <= 1;
                reg_sda <= 1;
                reg_sda <= data2send[bit];
                bit <= bit - 1;                
            end
            
        end else if (state == DATA1) begin
            sda_driving <= 1;
            if (counter == PERIOD_4Q) begin
                if (bit >= 0) begin
                    reg_sda <= data2send[bit];
                    bit <= bit - 1;
                end else begin
                    sda_driving <= 0;
                end
            end
            
        end else if (state == DATA1_ACK) begin
            if (counter == PERIOD_1Q) begin
                if (sda_in == 0) begin
                    data_acknowledged <= 1;
                end else begin
                    data_acknowledged <= 0;
                end
            end else if (counter == PERIOD_3Q) begin
                sda_driving <= 1;
                reg_sda <= 0;
            end
            
        end else if (state == STOP) begin
            if (counter == 0) begin
                reg_sda <= 0;
            end else if (counter == PERIOD_4Q) begin
                sda_driving <= 0;
            end
        end
    end
end    
endmodule