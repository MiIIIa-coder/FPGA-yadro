module MASTER_SPI
#(parameter width = 8)
{
    input clk,
    input rst,
    
    input up_data,
    input [width - 1:0] data,
    input [1:0] top_ss,

    output logic [width - 1:0] m_data,

    input MISO,

    output logic MOSI,
    output logic SCLK,
    output logic SS
};

localparam cnt_width = $clog2(width);

logic [width     - 1:0] master_data;
logic [cnt_width - 1:0] counter;

enum logic [1:0]
{
    IDLE         = 'b00,
    up_data_st   = 'b01,  //parallel loading data from bus
    tranc_rec_st = 'b10   //trancieve / receive state
}
state, next_state;

always_comb
begin
    state = next_state;

    case(state)

        IDLE:
            if (up_data)
                next_state = up_data_st;
            else 
                next_state = tranc_rec_st;
        
        up_data:
            next_state = tranc_rec_st;  //возможно нужно будет ждать SS
        
        tranc_rec_st:
            if (counter == width - 1)
                next_state = IDLE;    //byte has been sent => state->reset
    
    endcase
end

always_ff @(posedge clk)
begin
    if (rst)
        state <= IDLE;
    else
        state <= next_state;
end

always_ff @(posedge clk)
begin
    if (state == IDLE)
    begin
        //master_data <= 'x;
        counter <= '0;
        SS   <= 'x;
        MOSI <= 'x;
        SCLK <= 'x;
    end

    if (state == up_data)
    begin
        master_data <= data;
        //counter <= '0;
        SS   <= 'x;
        MOSI <= 'x;
        SCLK <= 'x;
    end

    if (state == tranc_rec_st)
    begin
        MOSI        <= master_data[width - 1];
        SCLK        <= clk;
        SS          <= top_ss;
        master_data <= {{master_data[width - 2:0]}, {MISO}};
        counter     <= counter + 'b1;

        if (counter == width - 1)
            m_data <= master_data;    
    end
end

endmodule