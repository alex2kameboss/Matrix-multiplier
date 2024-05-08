module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8
) (
    input                           clk,
    input                           reset_n,
    input   [DATA_WIDTH - 1 : 0]    data_i,
    output  [DATA_WIDTH - 1 : 0]    data_o,
    input                           shift_i
);
    
integer i, j;
reg [DATA_WIDTH - 1 : 0] memory [DEPTH - 1 : 0];

assign data_o = memory[0];

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )
        for (i = 0; i < DEPTH ; i = i + 1)
            memory[i] <= 'd0;
    else if ( shift_i ) begin
        memory[DEPTH - 1] <= data_i;
        for ( j = 0; j < DEPTH - 1; j = j + 1)
            memory[j] <= memory[j + 1];
    end
    
endmodule