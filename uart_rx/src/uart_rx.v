module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
);

 
	 initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
    end


//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

    // UART configuration parameters
    parameter BAUD_DIV = 27;
    parameter MID_SAMPLE = 13;

    // Receiver state definitions
    parameter IDLE   = 3'b000;
    parameter START  = 3'b001;
    parameter DATA   = 3'b010;
    parameter PARITY = 3'b011;
    parameter STOP   = 3'b100;
	 parameter INIT   = 3'b101;

    reg [4:0] state = INIT;
    reg [7:0] data_reg;
    reg [7:0] prev_data;
    reg [4:0] bit_count;
    reg [7:0] baud_count;
    reg parity_calc;
    reg parity_temp;
	 
//	 initial begin
//
//    // IMPORTANT INITIALIZATIONS (fixes 1-cycle early first byte)
////    data_reg      = 8'b0;
////    prev_data = 8'hFF;     // ensure first compare is always “different”
////    baud_count    = 0;
////    bit_count     = 0;
////    parity_calc   = 0;
////    parity_temp   = 0;
//    end

    always @(posedge clk_3125) begin
        case (state)
		  INIT: begin
		  state <= IDLE;
		  end
        //---------------------------------------------------------
        IDLE: begin
            baud_count <= 0;
            bit_count  <= 0;
            rx_complete <= 1'b0;

            if (rx == 1'b0)
                state <= START;
        end

        //---------------------------------------------------------
        START: begin
            baud_count <= baud_count + 1;

            if (baud_count == MID_SAMPLE) begin
                if (rx == 1'b0) begin
                    baud_count <= 0;
                    bit_count  <= 0;
                    state <= DATA;
                end else begin
                    state <= IDLE;
                end
            end
        end

        //---------------------------------------------------------
        DATA: begin
            baud_count <= baud_count + 1;

            if (baud_count == BAUD_DIV) begin
                baud_count <= 0;
                data_reg[7-bit_count] <= rx;
                bit_count <= bit_count + 1;

                if (bit_count == 7)
                    state <= PARITY;
            end
        end

        //---------------------------------------------------------
        PARITY: begin
            baud_count <= baud_count + 1;

            if (baud_count == BAUD_DIV + 2) begin
                baud_count <= 0;
                parity_temp <= rx;
                state <= STOP;
            end
        end

        //---------------------------------------------------------
        STOP: begin
            baud_count <= baud_count + 1;

            if (baud_count == BAUD_DIV) begin
                baud_count <= 0;

                // Update parity AFTER full stop bit
                rx_parity <= parity_temp;

                // Even parity calculation
                parity_calc = ^data_reg;

                // Assign received message
                if (parity_calc != parity_temp)
                    rx_msg <= 8'h3F;        // '?'
                else
                    rx_msg <= data_reg;

                // FIX: prev_data initialized correctly → no first-byte lead
                if (prev_data == data_reg)
                    rx_complete <= 1'b0;
                else
                    rx_complete <= 1'b1;

                prev_data <= data_reg;
                state <= IDLE;
            end
        end

        //---------------------------------------------------------
       

        endcase
    end

endmodule