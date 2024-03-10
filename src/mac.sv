module max #(
    parameter DATA_WIDTH = 8
) (
    input                               clk,
    input                               reset_n,
    input   [DATA_WIDTH - 1 : 0]        a_i,
    input   [DATA_WIDTH - 1 : 0]        b_i,
    output  [DATA_WIDTH - 1 : 0]        a_o,
    output  [DATA_WIDTH - 1 : 0]        b_o,
    output  [2 * DATA_WIDTH - 1 : 0]    c_o
);
    
logic [DATA_WIDTH - 1 : 0] a_reg, b_reg;
logic [2 * DATA_WIDTH - 1 : 0] c_reg;

assign a_o = a_reg;
assign b_o = b_reg;

always_ff @( posedge clk or negedge reset_n ) begin
   if ( ~reset_n )  a_reg <= 'd0;   else
                    a_reg <= a_i;
end

always_ff @( posedge clk or negedge reset_n ) begin
   if ( ~reset_n )  b_reg <= 'd0;   else
                    b_reg <= a_i;
end

endmodule