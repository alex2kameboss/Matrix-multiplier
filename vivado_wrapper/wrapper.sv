module wrapper(
    input           clk             ,
    input           rst_n           ,
    input           bus_data_clk    ,
    input           bus_data_rst_n  ,
    input           config_clk      ,
    input           config_rst_n       
);

memory_interface    a_bus(bus_data_clk, bus_data_rst_n), b_bus(bus_data_clk, bus_data_rst_n), c_bus(bus_data_clk, bus_data_rst_n);
apb_interface       config_bus(config_clk, config_rst_n);   

mem_mock_gen gen_a(.bus(a_bus));
mem_mock_gen gen_b(.bus(b_bus));

always_ff @(posedge c_bus.clk or negedge c_bus.reset_n)
    if ( ~c_bus.reset_n )                     c_bus.ack <= 'd0;    else
    if ( c_bus.req )                          c_bus.ack <= ~c_bus.ack;

`ifndef A_WIDTH
    `define A_WIDTH 16
`endif

`ifndef A_HEIGHT
    `define A_HEIGHT 16
`endif

top #(
    .ARRAY_WIDTH  ( `A_WIDTH  ),
    .ARRAY_HEIGHT ( `A_HEIGHT )
) top_i (
    .config_bus ( config_bus) ,
    .a_bus      ( a_bus     ) ,
    .b_bus      ( b_bus     ) ,
    .c_bus      ( c_bus     ) ,
    .clk        ( clk       ) ,
    .reset_n    ( reset_n   ) 
);

endmodule