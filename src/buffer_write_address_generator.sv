module buffer_write_address_generator #(
    parameter   BUFFER_ADDRESS_WIDTH    =   10
) (
    input                                       clk,
    input                                       reset_n,
    input                                       start_i,
    input                                       count_up,
    output  reg [15 : 0]                        global_counts,
    output      [BUFFER_ADDRESS_WIDTH - 1 : 0]  address,
    output                                      limit_pass,
    input                                       clear
);

assign address = global_counts[BUFFER_ADDRESS_WIDTH - 1 : 0];
assign limit_pass = global_counts[BUFFER_ADDRESS_WIDTH - 1];


always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )             global_counts <= 'd0;                   else
    if ( count_up )             global_counts <= global_counts + 'd1;   else
    if ( start_i | clear)       global_counts <= 'd0;             

endmodule