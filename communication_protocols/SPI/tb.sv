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
    .top_s   (top_s  ),
    .m_data  (m_data ),

    .up_data1(up_data1),
    .data1   (data1   ),

    .s_data1 (s_data1 )
);

initial
begin
    $dumpfile(tv.vcd);
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
    
end



endmodule