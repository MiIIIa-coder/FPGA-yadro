`include "UART_module.sv"

module UART_connect
#(parameter N = 8)
(
    input clk,
    input rst,

    input [N - 1:0] data1,
    input up_data1,
    input [N - 1:0] data2,
    input up_data2,

    output logic [N - 1:0] RX_data1,
    output logic [N - 1:0] RX_data2

);

wire RX1, TX1;
wire RX2, TX2;

UART UART_1
(
    .clk(clk),
    .rst(rst),
    .data(data1),
    .up_data(up_data1),
    .RX(RX1),
    .TX(TX1),
    .RX_data(RX_data1)
);

UART UART_2
(
    .clk(clk),
    .rst(rst),
    .data(data2),
    .up_data(up_data2),
    .RX(RX2),
    .TX(TX2),
    .RX_data(RX_data2)
);

assign RX1 = TX2;
assign RX2 = TX1;

endmodule