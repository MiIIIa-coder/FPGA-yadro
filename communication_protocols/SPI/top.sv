module top
#(parameter width = 8)
(
    input clk,
    input rst,
    
    //  MASTER
    input up_data,
    input [width - 1:0] data,
    input [1:0] top_ss,

    output logic [width - 1:0] m_data,

    //SLAVES
    input up_data1,
    input [width - 1:0] data1,
    // input up_data2,
    // input [width - 1:0] data2,
    // input up_data3,
    // input [width - 1:0] data3,

    output logic [width - 1:0] s_data1,
    // output logic [width - 1:0] s_data2,
    // output logic [width - 1:0] s_data3
);

//-------------------------------------------------
// MASTER
//

logic MISO_m;
logic MOSI_m;
logic SCLK_m;
logic   SS_m;

MASTER_SPI #(.width(width)) master
(
    .clk    (clk),
    .rst    (rst),

    .up_data(up_data),
    .data   (data   ),
    .top_ss (top_ss ),

    .m_data (m_data),

    .MISO   (MISO_m),
    .MOSI   (MOSI_m),
    .SCLK   (SCLK_m),
    .SS     (SS_m  )
);

//-------------------------------------------------
// SLAVE_1
//

logic MISO_s1;
logic MOSI_s1;
logic SCLK_s1;
logic   SS_s1;

SLAVE_SPI #(.width(width), .number_slave(2'b00)) slave_1
(
    .rst    (rst),

    .up_data(up_data1),
    .data   (data1   ),
    .s_data (s_data1 ),

    .MISO   (MISO_s1),
    .MOSI   (MOSI_s1),
    .SCLK   (SCLK_s1),
    .SS     (SS_s1  )
);

// connection SLAVE_1 and MASTER
assign MISO_m  = MISO_s1;

assign MOSI_s1 = MOSI_m;
assign SCLK_s1 = SCLK_m;
assign   SS_s1 =   SS_m;

endmodule