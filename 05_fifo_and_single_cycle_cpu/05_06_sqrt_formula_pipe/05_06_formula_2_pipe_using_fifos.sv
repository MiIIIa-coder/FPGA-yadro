//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);
    // Task:
    //
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
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
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 04_10_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    logic [15:0] sqrt_a;  //sqrt(a + sqrt(b + sqrt(c)))
    logic [15:0] sqrt_b;  //sqrt(b + sqrt(c))
    logic [15:0] sqrt_c;  //sqrt(c)
    logic vld_sqrt_c;
    logic vld_sqrt_b;
    logic vld_sqrt_a;
    logic [31:0] sum1;    //b + sqrt(c)
    logic [31:0] sum2;    //a + sqrt(b + sqrt(c))

    logic vld_sqrt_reg_1;  //valid register for isqrt1
    logic vld_sqrt_reg_2;  //valid register for isqrt2

    logic [31:0] out_fifo_1; //data from FIFO1
    logic [31:0] out_fifo_2; //data from FIFO2

    logic empty_fifo_1;
    logic empty_fifo_2;

    logic full_fifo_1;
    logic full_fifo_2;

    //-------------------------------------------------
    // sqrt instances
    //

    isqrt   isqrt1
    (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld), 
        .x(c),

        .y_vld(vld_sqrt_c), 
        .y(sqrt_c)
    );
    
    isqrt   isqrt2
    (
        .clk(clk),
        .rst(rst), 
        .x_vld(vld_sqrt_reg_1), 
        .x(sum1),

        .y_vld(vld_sqrt_b), 
        .y(sqrt_b)
    );

    isqrt   isqrt3
    (
        .clk(clk),
        .rst(rst), 
        .x_vld(vld_sqrt_reg_2), 
        .x(sum2),

        .y_vld(vld_sqrt_a), 
        .y(sqrt_a)
    );

    //-------------------------------------------------
    // FIFO instances
    //

    flip_flop_fifo_with_counter #(32, 16) fifo_1
    (
        .clk(clk),
        .rst(rst),
        .push(arg_vld    & ~full_fifo_1 ),
        .pop (vld_sqrt_c & ~empty_fifo_1),

        .write_data(b),
        .read_data (out_fifo_1),

        .empty(empty_fifo_1),
        .full ( full_fifo_1)
    );

    flip_flop_fifo_with_counter #(32, 33) fifo_2
    (
        .clk(clk),
        .rst(rst),
        .push(arg_vld    & ~full_fifo_2 ),
        .pop (vld_sqrt_b & ~empty_fifo_2),

        .write_data(a),
        .read_data (out_fifo_2),

        .empty(empty_fifo_2),
        .full ( full_fifo_2)
    );

    //-------------------------------------------------

    always_ff @(posedge clk or posedge rst)
    if (rst)
        res_vld <= 'b0;
    else
        res_vld <= vld_sqrt_a;
    
    always_ff @(posedge clk)
    begin
        vld_sqrt_reg_1 <= vld_sqrt_c;
        vld_sqrt_reg_2 <= vld_sqrt_b;
    end

    always_ff @(posedge clk)
    begin
        if (vld_sqrt_c)
            sum1 = sqrt_c + out_fifo_1;

        if (vld_sqrt_b)
            sum2 = sqrt_b + out_fifo_2;

        if (vld_sqrt_a)
            res <= sqrt_a;
    end

    


endmodule
