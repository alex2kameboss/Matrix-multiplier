module mem_mock_gen (
    memory_interface.slave bus
);

reg             ack_reg;
assign bus.ack = ack_reg;

genvar i;
generate
    for ( i = 0; i < 32; i = i + 1) begin : assing_data
        //assign bus.data[(i + 1) * 8 - 1 : i * 8] = bus.addr + i;
        assign bus.data[(i + 1) * 8 - 1 : i * 8] = 'd1;
    end
endgenerate
            

always_ff @(posedge bus.clk or negedge bus.reset_n)
    if ( ~bus.reset_n )                     ack_reg <= 'd0;    else
    if ( bus.req )                          ack_reg <= ~ack_reg;

endmodule