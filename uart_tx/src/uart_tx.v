// MazeSolver Bot: Task 2B - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag


        Baudrate : 115200 bps
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
 
// FSM states
    localparam IDLE       = 3'd0;
    localparam START_BIT  = 3'd1;
    localparam DATA_BITS  = 3'd2;
    localparam PARITY_BIT = 3'd3;
    localparam STOP_BIT   = 3'd4;


    reg [2:0] state = IDLE;
    reg [2:0] bit_index = 0;           // For data bits
    reg parity_bit;
    reg [4:0] clk_count = 0;           // To count 27 clocks per bit
    localparam BIT_TICKS = 27;         // 3.125MHz / 115200 ≈ 27 clocks per bit

    


    // FSM
    always @(posedge clk_3125) begin
	    
        case (state)
            IDLE: begin
                if (state == IDLE)
                    tx_done <= 1'b0;
                    clk_count = 0;
                    bit_index = 0;
                if (tx_start) begin
//                    tx_data <= data;
                    parity_bit <= ^data ^ parity_type; // Compute parity (even or odd)
                    tx = 1'b0;           // immediately start transmission
                          
                    state <= START_BIT;   // move to start bit state
						  clk_count <= 1;
                end else begin
                    tx = 1'b1;           // idle when not transmitting
                end
				end


            START_BIT: begin
                tx = 1'b0; // Start bit
                if (clk_count < BIT_TICKS-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    state <= DATA_BITS;
                end
            end

            DATA_BITS: begin
                tx = data[7 - bit_index]; // MSB first
                if (clk_count < BIT_TICKS-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    if (bit_index < 7)
                        bit_index <= bit_index + 1;
                    else begin
                        bit_index <= 0;
                        state <= PARITY_BIT;
                    end
                end
            end

            PARITY_BIT: begin
                tx = parity_bit;
                if (clk_count < BIT_TICKS-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    state <= STOP_BIT;
                end
            end

            STOP_BIT: begin
                tx = 1'b1; // Stop bit
                if (clk_count < BIT_TICKS-1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    state <= IDLE;
						  tx_done <= 1'b1;
                end
            end

				    

            default: state <= IDLE;
        endcase
    end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule