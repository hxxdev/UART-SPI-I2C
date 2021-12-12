parameter UART = 2'd0;
parameter SPI = 2'd1;
parameter I2C = 2'd2;

parameter [19:0] SERIAL_SPEED = 115200;

localparam STANDBY = 2'd0;
localparam RESPOND = 2'd1;
localparam WAIT = 2'd2;

localparam CR = 8'h0d;
localparam LF = 8'h0a;
localparam [31:0] OK_RESPONSE = {"ok", CR, LF};
localparam [55:0] ERROR_RESPONSE = {"error", CR, LF};

localparam MAX_CMD_BITS = 8*20;
