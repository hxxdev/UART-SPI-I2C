`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/14 13:39:47
// Design Name: 
// Module Name: i2c_master_tb
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
module i2c_master_tb;

`include "tbshare.v"
`include "i2cshare.v"

// input signals for i2c_master.v
reg clk, reset;
wire pulse;
reg send;

// output signals for i2c_master.v
wire scl;
tri sda;
reg sda_in;
wire sda_out;

// output signals for i2c_slave.v
wire [7:0] data_received;

// internal variables for test
reg expected;
reg expected_bit;
reg [3:0] bit;
reg oe;
reg [1:0] nframe;
reg [1:0] nlap;

pulse_generator pulse_generator1(.clk(clk), .reset(reset), .src(send), .pulse(pulse));
i2c_master #(.NUM_OF_FRAMES(NUM_OF_FRAMES)) i2c_master(.clk(clk), .reset(reset), .addr2send(ADDR2SEND), 
                                                        .r_or_w(R_OR_W), .data2send(data), .pulse(pulse), .scl(scl), .sda(sda));
i2c_slave i2c_slave(.clk(clk), .reset(reset), .scl(scl), .sda(sda), .data_received(data_received));
//i2c_slave i2c_slave(.SCL(scl), .SDA(sda), .IOout(data_received));

initial
begin
    // initialize variables
    $timeformat(-9, 0, " ns", 5);
    expected = 1'b0;
    bit = 0;
    oe = 1;
    nframe = 0;
    reset = 1'b0;
    send = 1'b0;
    expected_bit = 0;
    nlap = 0;
    clk = 0;
end

initial
begin : CLOCK_GENERATOR
    forever
        # CLOCK_HALF_PERIOD clk = ~clk;
end

initial
begin    
    // give global reset
    # CLOCK_NS;
    reset = 1'b1;
    # CLOCK_NS;
    reset = 1'b0;

    // check reset
    expected = (scl === 1'b1);
    if (!expected) 
        $error("%0t : scl initialization error", $time);
    expected = (sda === 1'b1);
    if (!expected)
        $error("%0t : sda initialization error", $time);
    expected = (data_received === 0);
    if (!expected)
        $error("%0t : data_received initialization error", $time);


    # MINIMUM_PERIOD;
    for (nlap = 0 ; nlap < REPEAT ; nlap = nlap + 1)
    begin
        @ (posedge clk);
        // give pulse
        send = 1'b1;
        # (2*CLOCK_NS);
        send = 1'b0;
    
        # CLOCK_NS;
        # MINIMUM_PERIOD;
        
        // check pulse result        
        expected = (scl === 1'b1);
        $display("%0t : According to I2C spec, scl must maintain high for at least 400ns... let's check!", $time);
        
        if (!expected) 
            $error("%0t : scl is 0 after the pulse", $time);
        else
            $display("%0t : good, scl is high!", $time);
                     
        $display("%0t : According to I2C spec, sda must be low for a cycle... let's check!", $time);                        
        expected = (sda === 1'b0);
        if (!expected)
            $error("%0t : sda is 1 after the pulse", $time);      
        else
            $display("%0t : good, sda is low!", $time);
            
        for (nframe = 0 ; nframe < NUM_OF_FRAMES ; nframe = nframe + 1)
        begin
            if (nframe == 0)
                $display("%0t : now master is sending address frame... let's check!", $time);
            else
                $display("%0t : now master is sending data frame... let's check!", $time);
                
            for (bit = 0 ; bit < 8 ; bit = bit + 1)
            begin
                # I2C_CLOCK_NS;
                if (nframe == 0)
                    expected_bit = (bit == 7 ? R_OR_W : ADDR2SEND[6 - bit]);
                else
                    expected_bit = data[7 - bit];
                expected = (sda === expected_bit);                       
                if (!expected) $error("%0t : %0d bit does not match", $time, 7 - bit);
                else $display("%0t : %0d bit matches", $time, 7 - bit);
            end
            
            /*
            * send acknowledgement bit
            */      
            # I2C_CLOCK_NS;
            $display("%0t : now slave is sending acknowledgement bit... let's check!", $time);
            
            if (nframe == 0)
                expected = (sda === (ADDR2SEND == SLAVE_ADDRESS ? 0 : 1));
            else
                expected = (sda === 0);
            if (!expected) $error("%0t : slave acknowlege bit error!", $time);
            else $display("%0t : slave has acknowledged well!", $time);
                        
            if (nframe == 1) begin
                expected = (data_received === data);
                if (!expected) $error("%0t : received data does not match", $time);
            end
        end
        
        // delay before repeat
        # (2*I2C_CLOCK_NS);
        @ (posedge clk);      
    end    
end
endmodule
