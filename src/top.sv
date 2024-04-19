module top #(
    parameter   ARRAY_WIDTH         =   32  ,
    parameter   ARRAY_HEIGHT        =   4   
) (
    // control interface
    apb_interface.slave         config_bus  ,
    // data interfaces
    memory_interface.master     a_bus       ,
    memory_interface.master     b_bus       ,
    memory_interface.master     c_bus       ,
    // core logic signals
    input                       clk         ,
    input                       reset_n     
);
    
wire    [15 : 0]    a_addr, b_addr, c_addr, m, n, p;
wire                start_apb, start_clk, done_apb, done_clk;
logic   [1 : 0]     start_sync, done_sync;
logic               start_clk_pulse, start_clk_d;

regfile regfile_i (
    .bus(config_bus),
    .matrix_a_addr_o( a_addr    ),
    .matrix_b_addr_o( b_addr    ),
    .matrix_c_addr_o( c_addr    ),
    .m_o            ( m         ),
    .n_o            ( n         ),
    .p_o            ( p         ),
    .start_o        ( start_apb ),
    .end_i          ( done_apb  )                    
);

systolic_array_top #(
    .ARRAY_WIDTH     ( ARRAY_WIDTH  ),
    .ARRAY_HEIGHT    ( ARRAY_HEIGHT ),
    .DATA_WIDTH      ( 8            ),
    .BUS_WIDTH_BYTES ( 32           ),
    .DATA_WIDTH_BYTES( 1            )
) systolic_array (
    .a_bus         ( a_bus              ),
    .b_bus         ( b_bus              ),
    .c_bus         ( c_bus              ),
    .clk           ( clk                ),
    .reset_n       ( reset_n            ),
    .start_i       ( start_clk_pulse    ),
    .m             ( m                  ),
    .n             ( n                  ),
    .p             ( p                  ),
    .base_addr_a   ( a_addr             ),
    .base_addr_b   ( b_addr             ),
    .base_addr_c   ( c_addr             ),
    .operation_done( done_clk           )
);

// syncronizers
// start apb.clk -> clk
// done  clk -> apb.clk

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                 start_sync <= 'd0;          else
                                    start_sync <= { start_apb, start_sync[1] };
assign start_clk = start_sync[0];                                    

always_ff @( posedge apb.clk or negedge apb.reset_n )
    if ( ~reset_n )                 done_sync <= 'd0;           else
                                    done_sync <= { done_clk, done_sync[1] };
assign done_apb = done_sync[0];       

// start pulse generator
assign start_clk_pulse = start_clk & ~start_clk_d;
always_ff @( posedge clk )
    start_clk_d <= start_clk;                

endmodule