`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/13 16:08:30
// Design Name: 
// Module Name: i2c_slave
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
module i2c_slave(
    input clk,
    input reset,
    input scl,
    inout sda,
    output reg [7:0] data_received
);

`include "i2cshare.v"
localparam [3:0] MAX_BIT = 8;

// received data
reg [6:0] received_address;
reg r_or_w;

// internal variables
reg [1:0] sclr, sdar;
reg [3:0] state, next_state;
reg signed [4:0] bit_count;

wire scl_redge = (sclr == 2'b01);
wire scl_fedge = (sclr == 2'b10);
wire sda_redge = (sdar == 2'b01);
wire sda_fedge = (sdar == 2'b10);
wire addr_match = (received_address == SLAVE_ADDRESS);

// variables for tristate buffer
reg sda_driving;
wire sda_in;
reg sda_out;

assign sda = sda_driving ? sda_out : 1'bz;
assign sda_in = sda_driving ? 1'bz : sda;

task toIdleState;
begin
    bit_count <= 7;     
    sda_driving <= 0;
    sda_out <= 0;
    received_address <= 0;
    r_or_w <= 0;
end
endtask

// IDLE -> START -> ADDR -> ADDR_ACK -> DATA -> DATA_ACK -> IDLE
// See I2C specification for more.
always @ (*)
begin
    if (scl && sda_redge) begin
        next_state = IDLE;
    end else begin
        if (state == IDLE) begin
            if (scl && sda_fedge)
                next_state = START;
            else
                next_state = state;
        end else if (state == START) begin
            if (scl_redge)
                next_state = ADDR;
            else
                next_state = state;
        end else if (state == ADDR) begin
            if (scl_redge && bit_count == 0)
                next_state = RW;
            else 
                next_state = state;
        end else if (state == RW) begin
            if (scl_redge && bit_count == -1)
                next_state = ADDR_ACK;
            else 
                next_state = state;        
        end else if (state == ADDR_ACK) begin
            if (scl_redge)
                next_state = DATA1;
            else
                next_state = state;
        end else if (state == DATA1) begin
            if (scl_redge && bit_count == 0)
                next_state = DATA1_ACK;
            else
                next_state = state;
        end else if (state == DATA1_ACK) begin
            if (scl && sda_redge)
                next_state = IDLE;
            else
                next_state = state;
        end else begin
            next_state = IDLE;
        end
    end
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        sclr <= 2'b11;
        sdar <= 2'b11;
    end else begin
        sclr <= {sclr[0], scl};
        sdar <= {sdar[0], sda};
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

//always @ (posedge clk)
//begin
//    if (activate_counter50) begin
//        if (counter == 50) begin
//            counter <= 0;
//            sda_driving <= ~sda_driving;
//            sda_out <= ack_bit;
//            activate_counter50 <= 0;
//        end else begin
//            counter <= counter + 1;
//        end
//    end
//end

//always @ (posedge clk)
//begin
//    if (activate_counter250) begin
//        if (counter == 250) begin
//            counter <= 0;
//            sda_driving <= ~sda_driving;
//            sda_out <= ack_bit;
//            activate_counter250 <= 0;
//        end else begin
//            counter <= counter + 1;
//        end
//    end
//end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        toIdleState;
        data_received <= 0;    
    end else begin
    
        if (state == IDLE) begin
            toIdleState;
            
        end else if (state == ADDR) begin
            if (scl_fedge) begin
                if (bit_count >= 0) begin
                    if (bit_count > 0) begin
                        received_address <= {received_address[6:0], sda};
                    end
                    bit_count <= bit_count - 1;
                end
            end
            
        end else if (state == RW) begin
            if (scl_fedge) begin
                r_or_w <= sda_in;
                bit_count <= bit_count - 1;
                sda_driving <= 1;
                sda_out <= ~addr_match;
            end
            
        end else if (state == ADDR_ACK) begin
            bit_count <= 8;
            if (scl_fedge) begin
                sda_driving <= 0;        
            end
        end else if (state == DATA1) begin
            if (scl_fedge) begin
                if (bit_count > 0) begin
                    if (bit_count == 1) begin
                        sda_driving <= 1;
                        sda_out <= 0;
                    end
                    data_received <= {data_received[6:0], sda};                       
                    bit_count <= bit_count - 1;
                end
            end
            
        end else if (state == DATA1_ACK) begin
            if (scl_fedge) begin
                sda_driving <= 0;
            end
        end   
    end
end
endmodule

