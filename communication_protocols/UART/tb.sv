`timescale 1ns/1ps;
`include "UART_connect.sv"

module tb_
#(
    parameter width = 8
);

logic clk;

logic up_data1, up_data2;
logic [N - 1:0] data1, data2;
logic [N:0] RX_data1, RX_data2;

localparam CLK_PERIOD = 10;

UART_connect #(.N(width)) DUT(
    .clk(clk),

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
    @(posedge clk);
    up_data1 <= 'b1;
    data1 <= 'b10100101;

    repeat (40) @ (posedge clk);

    $write("HERE \n");
    $write(" %b", RX_data2); 

end

endmodule