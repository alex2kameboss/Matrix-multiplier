module row_crossbar #(
    parameter   DATA_WIDTH      =   8,
    parameter   ARRAY_HEIGHT    =   4
) (
    input                                           clk,
    input                                           reset_n,
    input                                           sync_reset,
    input                                           shift,
    input   [ARRAY_HEIGHT * DATA_WIDTH - 1 : 0]     data_i,
    output  [ARRAY_HEIGHT * DATA_WIDTH - 1 : 0]     data_o
);
    
genvar i;

generate
    for ( int i = 1; i < ARRAY_HEIGHT; i = i + 1) begin : shift_block
        auto_shift_register shifter #(
            .DATA_WIDTH(DATA_WIDTH)
            .STEPS(i)
        ) (
            .clk(clk),
            .reset_n(reset_n),
            .sync_reset(sync_reset),
            .shift(shift),
            .data_i(data_i[i * DATA_WIDTH - 1 : ( i - 1) * DATA_WIDTH]),
            .data_o(data_o[i * DATA_WIDTH - 1 : ( i - 1) * DATA_WIDTH])
        );
    end
endgenerate

endmodule