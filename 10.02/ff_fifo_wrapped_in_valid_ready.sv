// Asynchronous reset here is needed for one of FPGA boards we use

`include "config.svh"

module ff_fifo_wrapped_in_valid_ready
# (
    parameter width = 8, depth = 10
)
(
    input                clk,
    input                rst,

    input                up_valid,    // upstream
    output               up_ready,
    input  [width - 1:0] up_data,

    output               down_valid,  // downstream
    input                down_ready,
    output [width - 1:0] down_data
);

    wire fifo_push;
    wire fifo_pop;
    wire fifo_empty;
    wire fifo_full;

    logic PSEL;
    logic PENABLE;

    assign up_ready   = ~ fifo_full;
    assign fifo_push  = up_valid & up_ready;

    assign down_valid = ~ fifo_empty;
    assign fifo_pop   = down_valid & down_ready;

    //PENABLE = '0;

          // States
  enum logic[1:0]
  {
     IDLE   = 2'b00,
     SETUP  = 2'b01,
     ACCESS = 2'b10
  }
  state, new_state;

//___________APB___________
    always_comb
    begin
        new_state = state;

        case(state)
            IDLE:
            begin
                if (up_valid)  //transfer
                begin
                    PSEL = '1;
                    new_state = SETUP;
                end 
                else new_state = IDLE;
            end

            SETUP: 
            begin
                PENABLE = '1;
                new_state = ACCESS;
            end

            ACCESS: 
            begin
                if (up_ready)
                begin
                    if (up_valid) //next transfer immediately
                    begin
                        new_state = SETUP;
                    end
                    else
                    begin         //no next transfer
                        PSEL    = '0;
                        PENABLE = '0;
                        new_state = IDLE;
                    end
                end
                else new_state = ACCESS; //transfer did not end

            end
        endcase

    end

    // State update
    always_ff @ (posedge clk)
        if (rst)
        begin
            state <= IDLE;
            PSEL    = '0;
            PENABLE = '0;
        end
        else
            state <= new_state;

    flip_flop_fifo_empty_full_optimized
    # (.width (width), .depth (depth))
    fifo
    (
        .clk        ( clk        ),
        .rst        ( rst        ),
        .push       ( fifo_push  ),
        .pop        ( fifo_pop   ),
        .write_data ( up_data    ),
        .read_data  ( down_data  ),
        .empty      ( fifo_empty ),
        .full       ( fifo_full  ),
        .penable    ( PENABLE    )
    );


endmodule
