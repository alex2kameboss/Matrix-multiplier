module matrix_multiplier(
    input           clk     ,
    input           rst_n   
);

wrapper wrapper_i (
    .clk   ( clk    ),
    .rst_n ( rst_n  )
);

endmodule