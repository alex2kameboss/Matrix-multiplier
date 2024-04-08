module mac #(
    parameter DATA_WIDTH = 8
) (
    input                               clk,
    input                               reset_n,
    input                               soft_reset_n,
    input                               ld,
    input   [DATA_WIDTH - 1 : 0]        a_i,
    input   [DATA_WIDTH - 1 : 0]        b_i,
    output  [DATA_WIDTH - 1 : 0]        a_o,
    output  [DATA_WIDTH - 1 : 0]        b_o,
    output  [2 * DATA_WIDTH - 1 : 0]    c_o
);
    
logic [DATA_WIDTH - 1 : 0] a_reg, b_reg;
logic [2 * DATA_WIDTH - 1 : 0] c_reg, prod_result, add_result;

assign a_o = a_reg;
assign b_o = b_reg;

mult #(.DATA_WIDTH(DATA_WIDTH)) mult_i (
    .a(a_i),
    .b(b_i),
    .c(prod_result)
);

add #(.DATA_WIDTH(2 * DATA_WIDTH)) add_i (
    .a(c_reg),
    .b(prod_result),
    .c(add_result)
);

always_ff @( posedge clk or negedge reset_n ) begin
    if ( ~reset_n )         a_reg <= 'd0;   else
    if ( ~soft_reset_n )    a_reg <= 'd0;   else
    if ( ld )               a_reg <= a_i;
end

always_ff @( posedge clk or negedge reset_n ) begin
    if ( ~reset_n )         b_reg <= 'd0;   else
    if ( ~soft_reset_n )    b_reg <= 'd0;   else
    if ( ld )               b_reg <= b_i;
end

always_ff @( posedge clk or negedge reset_n ) begin
    if ( ~reset_n )         c_reg <= 'd0;   else
    if ( ~soft_reset_n )    c_reg <= 'd0;   else
    if ( ld )               c_reg <= prod_result;
end

endmodule