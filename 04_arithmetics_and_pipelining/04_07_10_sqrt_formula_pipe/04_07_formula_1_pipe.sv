//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic    res_vld,
    output logic [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_1_pipe that computes the result
    // of the formula defined in the file formula_1_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_1_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    //'include "isqrt.sv";

    logic [15:0] sqrt_a;
    logic [15:0] sqrt_b;
    logic [15:0] sqrt_c;
    logic [31:0] sum;

    logic vld_a;
    logic vld_b;
    logic vld_c;

    logic sum_vld;

    isqrt   isqrt1
    (
        .clk (clk),
        .rst(rst), 
        .x_vld(arg_vld), 
        .x(a),

        .y_vld(vld_a), 
        .y(sqrt_a)
    );
    
    isqrt   isqrt2
    (
        .clk (clk),
        .rst(rst), 
        .x_vld(arg_vld), 
        .x(b),

        .y_vld(vld_b), 
        .y(sqrt_b)
    );

    isqrt   isqrt3
    (
        .clk (clk),
        .rst(rst), 
        .x_vld(arg_vld), 
        .x(c),

        .y_vld(vld_c), 
        .y(sqrt_c)
    );



    always_ff @ (posedge clk or posedge rst)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= vld_a & vld_b & vld_c; //valid from adder
    
    always_ff @ (posedge clk)
        res <= sqrt_a + sqrt_b + sqrt_c;

endmodule
