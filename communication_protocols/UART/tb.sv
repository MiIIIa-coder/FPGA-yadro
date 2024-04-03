//`timescale 1ns/1ps;
`include "UART_connect.sv"

module tb_
#(
    parameter width = 8
);

logic clk;
logic rst;

logic up_data1, up_data2;
logic [width - 1:0] data1;
logic [width - 1:0] data2;
logic [width - 1:0] RX_data1, RX_data2;

localparam CLK_PERIOD = 10;

UART_connect #(.N(width)) DUT(
    .clk(clk),
    .rst(rst),

    .data1(data1),
    .up_data1(up_data1),

    .data2(data2),
    .up_data2(up_data2),

    .RX_data1(RX_data1),
    .RX_data2(RX_data2)
);

initial begin
    $dumpfile("tb_.vcd");
    $dumpvars(0, tb_);
end

//-------------------------------
// driving CLK
initial 
begin
    clk <= 0;
    forever 
    begin
        #(CLK_PERIOD/2) clk = ~clk;
    end
end

initial
    begin
        repeat (10000) @ (posedge clk);
        $display ("Timeout!");
        $finish;
    end

//-------------------------------
// check
initial
begin
    repeat (2) @ (posedge clk);
    rst <= 'b0;
    repeat (2) @ (posedge clk);
    rst <= 'b1;
    repeat (2) @ (posedge clk);
    rst <= 'b0;

    @(posedge clk);
    up_data1 <= 'b1;
    data1 <= 'b10100101;

    up_data2 <= 'b1;
    data2 <= 'b00101011;

    @(posedge clk);
    up_data1 <= 'b0;
    up_data2 <= 'b0;

    repeat (12) @ (posedge clk);

    if (RX_data2 !== data1)
    begin
        $write("ERROR: UART2 got: %b, but expected: %b \n", RX_data2, data1);
        $error;
    end

    if (RX_data1 !== data2)
    begin
        $write("ERROR: UART1 got: %b, but expected: %b \n", RX_data1, data2);
        $error;
    end

    // $write("data1: %b \n", data1); 

    @(posedge clk);
    rst <= 'b1;
    @(posedge clk);
    rst <= 'b0;

    @(posedge clk);
    up_data1 <= 'b1;
    data1 <= 'b10110101;

    up_data2 <= 'b1;
    data2 <= 'b11000101;

    @(posedge clk);
    up_data1 <= 'b0;
    up_data2 <= 'b0;

    repeat (12) @ (posedge clk);

    if (RX_data2 !== data1)
    begin
        $write("ERROR: UART2 got: %b, but expected: %b \n", RX_data2, data1);
        $error;
    end

    //$write("RX_data1: %b \n", RX_data1); 
    if (RX_data1 !== data2)
    begin
        $write("ERROR: UART1 got: %b, but expected: %b \n", RX_data1, data2);
        $error;
    end

end

endmodule