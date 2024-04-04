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
    input up_data2,
    input [width - 1:0] data2,
    input up_data2,
    input [width - 1:0] data2,

    output logic [width - 1:0] s_data1,
    output logic [width - 1:0] s_data2,
    output logic [width - 1:0] s_data3
);



endmodule