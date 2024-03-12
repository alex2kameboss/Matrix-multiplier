module memory_ctrl #(
    parameter DATA_WIDTH    =   256,
    parameter ADDR_WIDTH    =   16
) (
    memory_interface.master         bus,
    input                           do_tran_i,
    input                           w_en_i,
    input   [ADDR_WIDTH - 1 : 0]    addr_i,
    input   [DATA_WIDTH - 1 : 0]    w_data_i,
    output  [DATA_WIDTH - 1 : 0]    r_data_o,
    output                          tran_done_o
);

reg                             transaction, w_en_reg, req_reg, tran_done_reg, ack_reg;
reg     [DATA_WIDTH - 1 : 0]    w_data_reg, r_data_reg;
reg     [ADDR_WIDTH - 1 : 0]    addr_reg;

assign bus.data = transaction & w_en_reg ? w_data_reg : 'bz;
assign r_data_o = r_data_reg;
assign bus.w_en = w_en_reg;
assign bus.addr = addr_reg;
assign bus.req  = req_reg;
assign tran_done_o = tran_done_reg;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )             ack_reg <= 'd0;    else
                                    ack_reg <= bus.ack;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )             w_en_reg <= 'd0;    else
    if ( do_tran_i & ~transaction ) w_en_reg <= w_en_i;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )                     w_data_reg <= 'd0;      else
    if ( do_tran_i & ~transaction & w_en_i) w_data_reg <= w_data_i;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )             addr_reg <= 'd0;    else
    if ( do_tran_i & ~transaction ) addr_reg <= addr_i;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )                     r_data_reg <= 'd0;      else
    if ( transaction & ~w_en_reg & ack_reg) r_data_reg <= bus.data;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )             req_reg <= 'd0;     else
    if ( do_tran_i & ~transaction ) req_reg <= 1'b1;    else
    if ( transaction & ack_reg )    req_reg <= 1'b0;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )             transaction <= 'd0;  else
    if ( ack_reg )                  transaction <= 1'b0; else    
    if ( do_tran_i & ~transaction ) transaction <= 1'b1;

always_ff @( posedge bus.clk or negedge bus.reset_n )
    if ( ~bus.reset_n )             tran_done_reg <= 'd0; else
                                    tran_done_reg <= transaction & ack_reg;

endmodule