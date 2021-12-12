/*------------------------------------------------------------
 *  System clock constants
 *  CLOCK_NS : simulation clock period in nano seconds.
 *-------------------------------------------------------------*/
localparam[3:0] CLOCK_NS = 10;
localparam [2:0] CLOCK_HALF_PERIOD = CLOCK_NS / 2;
localparam [1:0] MINIMUM_PERIOD = CLOCK_NS / 10;


/*------------------------------------------------------------
 *  COMMON constants
 *  data : data used in testbench
 *-------------------------------------------------------------*/
localparam [7:0] data = 8'b10100011;

/*------------------------------------------------------------
 *  UART constants
 *  BAUD_RATE :
 * DATA_BIT :
 *  UART_CLOCK_NS : 
 *-------------------------------------------------------------*/
localparam BAUD_RATE = 921600;
localparam[3:0] DATA_BIT = 8;
localparam UART_CLOCK_NS = 1000_000_000/BAUD_RATE;
localparam UART_CLOCK_HALF_PERIOD = UART_CLOCK_NS / 2;
localparam [DATA_BIT:0] frame = {data, 1'b0};

/*------------------------------------------------------------
 *  SPI constants
 *  
 *-------------------------------------------------------------*/
localparam SPI_SPEED = 1_000_000;
localparam SPI_CLOCK_NS = 1000_000_000 / SPI_SPEED;
localparam SPI_CLOCK_HALF_PERIOD = SPI_CLOCK_NS / 2;


/*------------------------------------------------------------
 *  I2C constants
 *  
 *-------------------------------------------------------------*/
localparam I2C_SPEED = 100_000;
localparam I2C_CLOCK_NS = 1000_000_000 / I2C_SPEED;
localparam I2C_CLOCK_HALF_PERIOD = I2C_CLOCK_NS / 2;
localparam [6:0] ADDR2SEND = 7'h33;
localparam [1:0] NUM_OF_FRAMES = 2;
localparam [2:0] REPEAT = 2;

// 1 for read, 0 for write.
localparam R_OR_W = 1'b0;