//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
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
    // Implement a module that calculates the folmula from the `formula_2_fn.svh` file
    // using only one instance of the isrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value

    //------------------------------------------------------------------------
    // States

    enum logic [1:0]
    {
        st_idle       = 2'b00,
        st_wait_a_res = 2'b01,
        st_wait_b_res = 2'b10,
        st_wait_c_res = 2'b11
    }
    state, next_state;

    //------------------------------------------------------------------------
    // Next state and isqrt interface

    logic [31:0] local_res = 32'b0; 
    logic        answer_vld;

    always_comb
    begin
        next_state  = state;

        isqrt_x_vld = '0;
        isqrt_x     = 'x;  // Don't care
        answer_vld  = '0;

        case (state)
        st_idle:
        begin
            isqrt_x = c;

            if (arg_vld)
            begin
                isqrt_x_vld = '1;
                next_state  = st_wait_c_res;
            end
        end

        st_wait_c_res:
        begin

            if (isqrt_y_vld)
            begin
                local_res = isqrt_y;  //sqrt(c)
                isqrt_x = isqrt_y + b;
                isqrt_x_vld = '1;
                next_state  = st_wait_b_res;
            end
        end

        st_wait_b_res:
        begin

            if (isqrt_y_vld)
            begin
                local_res = isqrt_y;  //sqrt(b + sqrt(c))  
                isqrt_x = local_res + a;
                isqrt_x_vld = '1;
                next_state  = st_wait_a_res;
            end
        end

        st_wait_a_res:
        begin
            if (isqrt_y_vld)
            begin
                local_res = isqrt_y;  //sqrt(a + sqrt(b + sqrt(c)))
                next_state = st_idle;
                answer_vld = 'b1;
            end
        end
        endcase
    end

    //------------------------------------------------------------------------
    // Assigning next state

    always_ff @ (posedge clk)
        if (rst)
            state <= st_idle;
        else
            state <= next_state;

    //------------------------------------------------------------------------
    // Accumulating the result

    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (state == st_wait_a_res & isqrt_y_vld);

    always_ff @ (posedge clk)
        if (state == st_idle)
            res <= '0;
        else if (answer_vld)
            res <= local_res;



endmodule
