`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/23 18:01:29
// Design Name: 
// Module Name: console
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
module console(
    input clk,
    input reset,
    input rx,
    output tx,
    output reg [1:0] mode,
    output reg [19:0] uart_speed,
    output reg [27:0] spi_speed,
    output reg spi_mode,
    output reg spi_cpol,
    output reg spi_cpha,
    output reg i2c_mode,
    output reg [23:0] i2c_speed
);

`include "consoleshare.v"
`include "commshare.v"

/*
* Internal variable to clear the buffer of 'uart_rx' module.
* clear_buffer : When 1 is written the rx buffer of 'uart_rx' is cleared.
*/
reg clear_buffer;

/*
* Internal variables to save the output of 'uart_rx' module.
* rx_busy : 1 if 'uart_rx' module is receiving. 0 if not.
* rx_busy_r : register for rx_busy.
* rx_busy_fedge : 1 on falling edge of rx_busy.
* received_byte : every time 'uart_rx' module receives a byte, the byte is saved here.
*/
wire rx_busy;
reg [1:0] rx_busy_r; 
always @ (posedge clk or posedge reset) 
begin 
    if (reset) begin
        rx_busy_r <= 0; 
    end else begin 
        rx_busy_r <= {rx_busy_r[0], rx_busy}; 
    end
end
wire rx_busy_fedge = (rx_busy_r == 2'b10);
wire [7:0] received_byte;

/*
* Internal variables for controlling 'uart_8bytes_tx' module.
* send : When set to 1 for one cycle, 'uart_tx' sends the response.
* byte2send : Response to send after receipt of command
*/
reg send;
reg [63:0] response;
reg [3:0] response_chars_num;
wire tx_busy;
reg [1:0] tx_busy_r;
wire tx_busy_fedge = (tx_busy_r == 2'b10);

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        tx_busy_r <= 0;
    end else begin
        tx_busy_r <= {tx_busy_r[0], tx_busy};
    end
end

/*
* command : received_byte(s) are stacked here.
*/
reg [MAX_CMD_BITS:1] command;

/*
* Module instantiation
* uart_rx : module for receiving data by uart.
* uart_tx : module for transmitting data by uart.
*/
uart_rx console_rx(.clk(clk), .reset(reset), .speed(SERIAL_SPEED), .rx(rx), .rx_data(received_byte), .rx_busy(rx_busy), .clr_buffer(clear_buffer));
uart_8bytes_tx console_tx(.clk(clk), .reset(reset), .speed(SERIAL_SPEED), .bytes2send(response), .bytes_num(response_chars_num), .pulse(send), .tx(tx), .tx_busy_8bytes(tx_busy));

/*
* Internal variables
* state, next_state : indicates the state of Finite State Machine.
*/ 
reg [3:0] state, next_state;

//task RespondOK;
//begin
//    response <= OK_RESPONSE;
//    response_chars_num <= 4;
//end
//endtask

//task RespondError;
//begin
//    response <= ERROR_RESPONSE;
//    response_chars_num <= 7;
//end
//endtask

always @ (*)
begin
    if (state == STANDBY) begin
        if (rx_busy_fedge && (received_byte == "\n"))
            next_state = RESPOND;
        else
            next_state = state;
    end else if (state == RESPOND) begin
        next_state = WAIT;
    end else if (state == WAIT) begin
        if (tx_busy_fedge)
            next_state = STANDBY;
        else
            next_state = state;        
    end else begin
        next_state = STANDBY;
    end
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        state <= STANDBY;
    end else begin
        state <= next_state;
    end
end

always @ (posedge clk or posedge reset)
begin
    if (reset) begin
        response <= 0;
        command <= 0;
        send <= 0;
        mode <= SPI;
        uart_speed <= 9600;
        spi_speed <= 1_000_000;
        i2c_speed <= 100_000; 
        spi_mode <= SLAVE;
        spi_cpol <= 0;
        spi_cpha <= 0;
        i2c_mode <= SLAVE;        
        response_chars_num <= 0;
        clear_buffer <= 0;
    end else begin
        if (state == STANDBY) begin
            send <= 0;
            // hold speed values
            
            if (rx_busy_fedge) begin
                command <= {command, received_byte};   // concat strings
                clear_buffer <= 1;
            end else begin
                clear_buffer <= 0;
            end
        end else if (state == RESPOND) begin
            send <= 1;
            command <= 0;
            clear_buffer <= 0;            
            
            /*
            * Table of commands
            *
            * AT : responds "ok"
            * AT+MODE=UART : configure the LED so that it displays the received data of uart.
            * AT+MODE=SPI : configure the LED so that it displays the received data of spi bus.
            * AT+MODE=I2C : configure the LED so that it displays the received data of i2c bus.
            * AT+UARTSPEED=<1~5> : set the speed of uart comms.
            * AT+SPISPEED=<1~5> : set the speed of spi comms.
            * AT+I2CSPEED=<1~5> : set the speed of i2c comms.
            *
            * Refer to the manual for more details
            * http://......
            */
            if (command == {"AT", CR, LF}) begin
                response <= OK_RESPONSE;
                response_chars_num <= 4;
            end else if (command == {"AT+MODE=UART", CR, LF}) begin
                response <= OK_RESPONSE;
                response_chars_num <= 4;
                mode <= UART;
            end else if (command == {"AT+MODE=SPI", CR, LF}) begin
                response <= OK_RESPONSE;
                response_chars_num <= 4;
                mode <= SPI;                    
            end else if (command == {"AT+MODE=I2C", CR, LF}) begin
                response <= OK_RESPONSE;
                response_chars_num <= 4;
                mode <= I2C;                
            end else if (command == {"AT+SPI=MASTER", CR, LF}) begin
                spi_mode <= MASTER;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            end else if (command == {"AT+SPI=SLAVE", CR, LF}) begin
                spi_mode <= SLAVE;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            end else if (command == {"AT+CPOL=1", CR, LF}) begin
                spi_cpol <= 1;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            end else if (command == {"AT+CPOL=0", CR, LF}) begin
                spi_cpol <= 0;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            end else if (command == {"AT+CPHA=1", CR, LF}) begin
                spi_cpha <= 1;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            end else if (command == {"AT+CPHA=0", CR, LF}) begin
                spi_cpha <= 0;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                           
            end else if (command == {"AT+I2C=MASTER", CR, LF}) begin
                i2c_mode <= MASTER;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            end else if (command == {"AT+I2C=SLAVE", CR, LF}) begin
                i2c_mode <= SLAVE;
                response <= OK_RESPONSE;
                response_chars_num <= 4;                
            
            /*
            * table of speed of each mode
            * SPEED    1        2         3        4          5
            * UART : 1200Hz - 4800Hz - 9600Hz - 115200Hz - 921600Hz
            * SPI  : 100kHz - 500kHz -  1MHz  -   10MHz  -  50MHz
            * I2C  : 100kHz - 100kHz - 100kHz -  400kHz  -  3.4MHz
            */
            end else if (command[128 : 25] == "AT+UARTSPEED=") begin
                case (command[24 : 1])  
                    {"1", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        uart_speed <= 1200;     
                    end               
                    {"2", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        uart_speed <= 4800;
                    end
                    {"3", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        uart_speed <= 9600;                    
                    end
                    {"4", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        uart_speed <= 115200;                    
                    end
                    {"5", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        uart_speed <= 921600;
                    end
                    default : begin
                        response <= ERROR_RESPONSE;
                        response_chars_num <= 7;
                    end
                endcase
            end else if (command[120 : 25] == "AT+SPISPEED=") begin     
                case (command[24 : 1])  
                    {"1", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        spi_speed <= 100_000;
                    end
                    {"2", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;       
                        spi_speed <= 500_000;     
                    end               
                    {"3", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;   
                        spi_speed <= 1_000_000;                    
                    end
                    {"4", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;       
                        spi_speed <= 10_000_000;
                    end
                    {"5", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;   
                        spi_speed <= 50_000_000;
                    end
                    default : begin
                        response <= ERROR_RESPONSE;
                        response_chars_num <= 7;
                    end
                endcase                
            end else if (command[120 : 25] == "AT+I2CSPEED=") begin           
                case (command[24 : 1])  
                    {"1", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        i2c_speed <= 100_000;
                    end
                    {"2", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        i2c_speed <= 100_000;                    
                    end
                    {"3", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        i2c_speed <= 100_000;                    
                    end
                    {"4", CR, LF}: begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;
                        i2c_speed <= 400_000; 
                    end
                   {"5", CR, LF} : begin
                        response <= OK_RESPONSE;
                        response_chars_num <= 4;       
                        i2c_speed <= 3_400_000;
                    end
                    default : begin
                        response <= ERROR_RESPONSE;
                        response_chars_num <= 7;
                    end
                endcase  
            end else begin
                response <= ERROR_RESPONSE;
                response_chars_num <= 7;
            end
        end else if (state == WAIT) begin
            send <= 0;
        end
    end
end     
endmodule
