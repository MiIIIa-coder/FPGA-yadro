module MASTER_SPI
#(parameter width)
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

always_ff @(posedge clk)
begin
    if (rst)
    begin
        master_data <= 'x;
        counter <= '0;
        SS   <= 'x;
        MOSI <= 'x;
        SCLK <= 'x;
    end
    else if (up_data)  //parallel loading data from bus
    begin
        master_data <= data;
        counter <= '0;
        SS   <= 'x;
        MOSI <= 'x;
        SCLK <= 'x;
    end
    else              //serial sending (by bit) data from master_data
    begin
        MOSI        <= master_data[0];
        SCLK        <= clk;
        SS          <= top_ss;
        master_data <= {{MISO}, {master_data[width - 1:1]}};
        counter     <= counter + 'b1;
    end
end

assign m_data = master_data;

endmodule