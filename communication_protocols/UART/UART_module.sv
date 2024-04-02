module UART
#(parameter N = 8)
(
    input clk,
    input [N - 1:0] data,
    input up_data,

    input        RX,
    output logic TX,

    output logic [N:0] RX_data
);

    localparam counter_width = $clog2 (N+2);

    logic [(N - 1)+3:0] q;  //q[N+2] - start_bit, q[0] - stop_bit, q[1] - parity_bit (нечётное кол-во единиц)
    logic [counter_width-1:0] counter;

    logic [N:0] r_data; //r_data[N:1] - data, r_data[0] - parity_bit

    //--------------------------------------
    // Tranciever
    //

    always_ff @(posedge clk) 
    begin
        if (up_data)
        begin
            // q[N+2] <= 'b0; //start_bit
            // q[N+1:2] <= data;
            // q[1:0] <= {'b0, 'b1};
            q <= {'b0, data, 'b0, 'b1};
        end
        else 
        begin
            q <= {{q [N+1:0]}, {'b1}};
            if (q[N+2] == 'b1 & counter <= N & counter > 0)
                q[1 + counter] <= ~ q[1 + counter];
        end
    end

    always_ff @(posedge clk)
    begin
        if (up_data | counter == N+2)
            counter <= 'b0;
        else
            counter <= counter + 'b1;
    end

    assign TX = q[N+2];

    //--------------------------------------
    // Receiver
    //

    logic [counter_width-1:0] cnt_RX;

    enum logic [1:0]
    {
        wait_st = 'b00,
        rec_st  = 'b01,
        sp_st  = 'b10   //stop_state - read stop_bit
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
                cnt_RX = cnt_RX + 'b1;
                if (cnt_RX == N)
                    next_state = sp_st;
            
            sp_st:
                if (RX == 'b1)
                    next_state = wait_st;  //stop_bit = 1 => end
                else
                begin
                    next_state = rec_st;   //continue get data
                    cnt_RX = 0;
                end;

        endcase
    end

    always_ff @(posedge clk)
    begin
        if (state == wait_st)
            r_data <= 0;
        if (state == rec_st)
            r_data <= {r_data[N-1:0], RX};
    end

    assign RX_data = r_data;
    

endmodule