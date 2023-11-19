//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
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

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the folmula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value

    logic [31:0] local_res;
    logic local_res_vld = '0;

    //logic [31:0] tmp_local_res;
    //logic tmp_local_res_vld = '0;

    //States
    enum logic[1:0]
    {
        IDLE     = 2'b00,
        WAIT_A_B = 2'b01,
        WAIT_C   = 2'b10
    }
    state, next_state;

    //State transition logic and results from sqrt
    always_comb
    begin
        next_state = state;

        isqrt_1_x_vld = '0;
        isqrt_2_x_vld = '0;
        isqrt_1_x     = 'x;  //?
        isqrt_2_x     = 'x;  //?

        case (state)
        IDLE:
        begin
            //push a and b
            isqrt_1_x = a;
            isqrt_2_x = b;

            if (arg_vld)
            begin
                isqrt_1_x_vld = '1;
                isqrt_2_x_vld = '1;
                next_state = WAIT_A_B;
            end
        end

        WAIT_A_B:
        begin
            isqrt_1_x = c;

            if (isqrt_1_y_vld & isqrt_2_y_vld) //if got results from sqrt(a) and sqrt(b)
            begin
                isqrt_1_x_vld = '1;
                local_res  = isqrt_1_y + isqrt_2_y;
                local_res_vld = '1;
                next_state = WAIT_C;
            end
        end

        WAIT_C:
        begin
            if (isqrt_1_y_vld) //if got result from sqrt(c)
            begin
                next_state = IDLE;
                local_res  = isqrt_1_y;
                local_res_vld = '1;
            end
        end
        endcase
    end

    //Assigning next state
    always_ff @ (posedge clk)
        if (rst)
            state <= IDLE;
        else 
            state <= next_state;
    
    //Accumulating the result
    always_ff @ (posedge clk)
        if (rst)
            res_vld <= '0;
        else
            res_vld <= (state == WAIT_C & isqrt_1_y_vld);

    always_ff @ (posedge clk)
        if (state == IDLE)
            res <= '0;
        else if (state == WAIT_A_B & isqrt_1_y_vld & isqrt_2_y_vld |
                 state == WAIT_C   & isqrt_1_y_vld) 
            begin
            res <= res + local_res;
            end


endmodule
