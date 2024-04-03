module UART
#(parameter N = 8)
(
    input clk,
    input rst,
    input [N - 1:0] data,
    input up_data,

    input        RX,
    output logic TX,

    output logic [N - 1:0] RX_data
);

    localparam counter_width = $clog2 (N+2);

    logic [(N - 1)+3:0] q;  //q[N+2] - start_bit, q[0] - stop_bit, q[1] - parity_bit (нечётное кол-во единиц)
    logic [counter_width-1:0] counter;
    logic parity_bit;

    //--------------------------------------
    // Tranciever
    //

    always_ff @(posedge clk) 
    begin
        if (rst)
        begin
            q <= 'x;
            parity_bit <= 'b0;
        end
        else if (up_data)
        begin
            q <= {1'b0, data, 1'b0, 1'b1};
            parity_bit <= 'b0;
        end
        else 
        begin
            q <= {{q [N+1:0]}, {q [0]}};
            if (q[N+2] == 'b1 & counter <= N & counter > 0)
                parity_bit <= ~ parity_bit;
        end
    end

    always_ff @(posedge clk)
    begin
        if (rst | up_data | counter == N+2)
            counter <= 'b0;
        else
            counter <= counter + 'b1;
    end

    always_comb
    begin
        if (counter == N+1)
            TX = parity_bit;
        else
            TX = q[N+2];
    end

    //--------------------------------------
    // Receiver
    //

    logic [N - 1:0] r_data;           //receive data
    logic [N - 1:0] rc_data;          //saved receive data
    logic [counter_width-1:0] cnt_RX; //counter
    logic rc_par_bit;                 //parity bit (receive)

    enum logic [1:0]
    {
        wait_st = 'b00,
        rec_st  = 'b01,  //receive_sate - read data
        par_st  = 'b10,  //parity_state - read parity_bit 
        sp_st   = 'b11   //stop_state   - read stop_bit
    } 
    state, next_state;

    
    always_comb
    begin
        next_state = state;

        case(state)
            wait_st:
                if (RX == 'b0)
                begin
                    next_state = rec_st;
                    cnt_RX = 0;
                end
            
            rec_st:
            begin
                if (cnt_RX == N-1)
                    next_state = par_st;
            end

            par_st:
            begin
                next_state = sp_st;
            end
            
            sp_st:
                // if (RX == 'b1)
                    next_state = wait_st;  //stop_bit = 1 => end
                // else
                // begin
                //     next_state = rec_st;   //continue get data
                //     cnt_RX = 0;
                // end

        endcase
    end

    always_ff @(posedge clk)
        if (rst)
            state <= wait_st;
        else
            state <= next_state;

    always_ff @(posedge clk)
    begin
        if (state == wait_st)
            r_data <= 0;
        if (state == rec_st)
        begin
            cnt_RX <= cnt_RX + 'b1;
            r_data <= {r_data[N-2:0], RX};
        end
        if (state == par_st)
        begin
            rc_par_bit <= RX;
            if (cnt_RX == N)  
                rc_data <= r_data;
        end
    end

    always_ff @(posedge clk)
        RX_data <= rc_data;
    

endmodule