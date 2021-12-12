`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/05 12:48:55
// Design Name: 
// Module Name: pulse_generator
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
module pulse_generator(
    input clk,
    input reset,
    input src,
    output pulse
);

parameter INIT = 2'b00,
            GEN = 2'b01,
            WAIT = 2'b11;

reg [1:0] current_state;
reg [1:0] next_state;

assign pulse = (current_state == GEN) ? 1'b1 : 1'b0;

always @ (*)
begin
    if (src == 1) begin
        case (current_state)
        INIT :
            next_state = GEN;
        GEN :
            next_state = WAIT;
        WAIT :
            next_state = WAIT;
        default :
            next_state = INIT;
        endcase
    end else begin
        next_state = INIT;
    end
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        current_state <= INIT;
    end else begin
        current_state <= next_state;
    end
end
endmodule
