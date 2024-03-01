//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [1:0]
    {
        st_put_a    = 2'b00,
        st_put_b    = 2'b01,
        st_put_c    = 2'b10,
        st_wait_res = 2'b11
    } 
    state, next_state;

    always_comb
    begin
        next_state = state;

        isqrt_x_vld = 1'b0;
        isqrt_x = 'x;

        case(state)
        st_put_a:
        begin
            flag_res_vld = 'b1;

            if (arg_vld)    //a,b,c - valid
            begin
                isqrt_x = a;
                isqrt_x_vld = 'b1;
                next_state = st_put_b;
            end
        end

        st_put_b:
        begin
            isqrt_x = b;
            isqrt_x_vld = 'b1;
            next_state = st_put_c;
        end

        st_put_c:
        begin
            isqrt_x = c;
            isqrt_x_vld = 'b1;
            next_state = st_wait_res;
        end

        st_wait_res:
        begin
            isqrt_x = 'x;

            if (counter == 3)
            begin
                next_state   = st_put_a;
                flag_res_vld = 'b0;
            end 
        end

        endcase
    end

    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_put_a;
        else
            state <= next_state;
    
    //------------------------------------------------------------------------
    // Accumulating the result

    logic [31:0] sum;
    int counter;
    logic flag_res_vld;

    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (counter == 3 & state == st_wait_res & !flag_res_vld); //(state == st_wait_c_res & isqrt_y_vld);

    always_ff @ (posedge clk)
    begin
        if (!isqrt_y_vld)
        begin
            sum <= '0;
        end
        else
        begin
            sum <= sum + isqrt_y;
            counter++;
        end

        if (state == st_put_a)
            counter = 0;
    end
    
    always_ff @ (posedge clk)
        if (rst)
        begin
            sum <= '0;
            res <= '0;
        end
        else
            res <= sum;


endmodule
