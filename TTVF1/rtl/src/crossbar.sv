module crossbar #(
    parameter   DATA_WIDTH      =   8,
    parameter   ARRAY_ELLEMENTS =   4
) (
    input                                           clk         ,
    input                                           reset_n     ,
    input                                           sync_reset_n,
    input                                           shift       ,
    input   [ARRAY_ELLEMENTS * DATA_WIDTH - 1 : 0]  data_i      ,
    output  [ARRAY_ELLEMENTS * DATA_WIDTH - 1 : 0]  data_o      
);
    
genvar i;

generate
    for ( i = 1; i <= ARRAY_ELLEMENTS; i = i + 1) begin : shift_block
        auto_shift_register #(
            .DATA_WIDTH(DATA_WIDTH),
            .STEPS(i)
        ) shifter (
            .clk(clk),
            .reset_n(reset_n),
            .sync_reset_n(sync_reset_n),
            .shift(shift),
            .data_i(data_i[i * DATA_WIDTH - 1 : ( i - 1) * DATA_WIDTH]),
            .data_o(data_o[i * DATA_WIDTH - 1 : ( i - 1) * DATA_WIDTH])
        );
    end
endgenerate

endmodule