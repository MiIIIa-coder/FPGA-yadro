//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
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
    // Implement a pipelined module formula_2_pipe that computes the result
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
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    logic [15:0] sqrt_a;  //sqrt(a)
    logic [15:0] sqrt_b;  //sqrt(b + sqrt(a))
    logic [15:0] sqrt_c;  //sqrt(c + sqrt(b + sqrt(a)))
    logic [31:0] sum1;    //b + sqrt(a)
    logic [31:0] sum2;    //c + sqrt(b + sqrt(a))

    logic [31:0] out_reg_s1;  //out of shift register 1
    logic [31:0] out_reg_s2;  //out of shift register 1

    logic vld_sqrt_a;
    logic vld_sqrt_b;
    logic vld_sqrt_c;
    logic vld_sqrt_reg1;  //valid register for isqrt1
    logic vld_sqrt_reg2;  //valid register for isqrt2
    logic vld_sh_r_reg1;  //valid register for shift register1
    logic vld_sh_r_reg2;  //valid register for shift register2

    logic vld_reg_s1;     //valid out_data of shift register1
    logic vld_reg_s2;     //valid out_data of shift register2

    //logic res_reg;  //register for res

    //-----------------------------------------------
    // ISQRT instances

    isqrt   isqrt1
    (
        .clk(clk),
        .rst(rst), 
        .x_vld(arg_vld), 
        .x(a),

        .y_vld(vld_sqrt_a), 
        .y(sqrt_a)
    );
    
    isqrt   isqrt2
    (
        .clk(clk),
        .rst(rst), 
        .x_vld(vld_sqrt_reg1 & vld_sh_r_reg1), 
        .x(sum1),

        .y_vld(vld_sqrt_b), 
        .y(sqrt_b)
    );

    isqrt   isqrt3
    (
        .clk(clk),
        .rst(rst), 
        .x_vld(vld_sqrt_reg2 & vld_sh_r_reg2), 
        .x(sum2),

        .y_vld(vld_sqrt_c), 
        .y(sqrt_c)
    );

    //-----------------------------------------------
    // shift register instances

    shift_register_with_valid #(32, 16) s_r_1
    (
        .clk(clk),
        .rst(rst),
        .in_vld(arg_vld),
        .in_data(b),

        .out_vld(vld_reg_s1),
        .out_data(out_reg_s1)
    );

    shift_register_with_valid #(32, 33) s_r_2
    (
        .clk(clk),
        .rst(rst),
        .in_vld(arg_vld),
        .in_data(c),

        .out_vld(vld_reg_s2),
        .out_data(out_reg_s2)
    );

    //-----------------------------------------------
    // LOGIC

    always_ff @ (posedge clk or posedge rst)
        if (rst)
            res_vld <= 'b0;
        else
            res_vld <= vld_sqrt_c;

    always_ff @ (posedge clk)
    begin
        //SUM1: b + sqrt(a)
        if (vld_sqrt_a & vld_reg_s1)
            sum1 <= sqrt_a + out_reg_s1;
        
        //SUM2: c + sqrt(b + sqrt(a))
        if (vld_sqrt_b & vld_reg_s2)
            sum2 <= sqrt_b + out_reg_s2;

        //RES: sqrt(c + sqrt(b + sqrt(a)))
        if (vld_sqrt_c)
            res <= sqrt_c;
    end

    //-----------------------------------------------
    // valid registers
    
    always_ff @ (posedge clk)
    begin
        vld_sqrt_reg1 <= vld_sqrt_a;
        vld_sqrt_reg2 <= vld_sqrt_b;

        vld_sh_r_reg1 <= vld_reg_s1;
        vld_sh_r_reg2 <= vld_reg_s2;
    end


endmodule
