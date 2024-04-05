`include "top.sv"

module tb
#(parameter width = 8);

logic clk;
logic rst;

//  MASTER
logic up_data;
logic [width - 1:0] data;
logic [        1:0] top_ss;
logic [width - 1:0] m_data;

//SLAVES
logic up_data1;
logic [width - 1:0] data1;

logic [width - 1:0] s_data1;

localparam CLK_PERIOD = 10;

top #(.width(width)) DUT
(
    .clk(clk),
    .rst(rst),

    .up_data (up_data),
    .data    (data   ),
    .top_ss  (top_ss ),
    .m_data  (m_data ),

    .up_data1(up_data1),
    .data1   (data1   ),

    .s_data1 (s_data1 )
);

initial
begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
end

//------------------------
// driving CLK
initial
begin
    clk <= 0;
    forever
        #(CLK_PERIOD/2) clk <= ~ clk;
end

initial
begin
    repeat (1000) @(posedge clk);
    $display("Timeout! \n");
    $finish;
end

//------------------------
// reset module
task reset;
    rst <= 'x;
    repeat (2) @(posedge clk);
    rst <= 'b1;
    repeat (2) @(posedge clk);
    rst <= 'b0;
endtask

//------------------------
// test DUT
initial
begin
    @(posedge clk);

    reset();
    @(posedge clk);

    up_data <= 'b1;
    data <= 'b10100101;
    top_ss <= 'b00;

    up_data1 <= 'b1;
    data1 <= 'b11001101;

    @(posedge clk);
    up_data  <= 'b0;
    up_data1 <= 'b0;

    repeat (12) @(posedge clk);
    $display("HERE!!\n");

end



endmodule