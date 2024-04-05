module SLAVE_SPI
#(parameter width = 8, number_slave = 0)
(
    input  rst,

    input  up_data,
    input  [width - 1:0] data,

    output logic [width - 1:0] s_data,

    output logic MISO,
    input        MOSI,
    input        SCLK,
    input        SS
);

logic [width - 1:0] slave_data;
logic clk;

assign clk = SCLK & (SS == number_slave);

enum logic [1:0]
{
    IDLE         = 'b00,
    up_data_st   = 'b01,  //parallel loading data from bus
    tranc_rec_st = 'b10   //trancieve / receive state
}
state, next_state;

always_comb
begin
    next_state = state;

    case(state)

    IDLE:
        if (up_data & ~(SS == number_slave))  //go to loading state
            next_state = up_data_st;
        else if (SS == number_slave)          //communication with master
            next_state = tranc_rec_st;
    
    up_data_st:
        if (SS == number_slave)
            next_state = tranc_rec_st;
    
    tranc_rec_st:
        if (SS != number_slave)
        begin
            s_data = slave_data;
            next_state = IDLE;
        end

    endcase
end

always_ff @(posedge clk)
    if (rst)
        state <= IDLE;
    else
        state <= next_state;

always_ff @(posedge clk)
begin
    if (state == rst)
    begin
        slave_data <= 'x;
        MISO       <= 'x;
    end

    if (state == up_data_st) 
        slave_data <= data;

    if (state == tranc_rec_st)
    begin
        MISO       <= slave_data[width - 1];
        slave_data <= {{slave_data[width - 2:1]}, {MOSI}};
    end
end

endmodule