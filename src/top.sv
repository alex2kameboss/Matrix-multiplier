module top #(
    parameter   ARRAY_WIDTH         =   16  ,
    parameter   ARRAY_HEIGHT        =   16     
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
    
logic   [15 : 0]            a_addr_apb, b_addr_apb, c_addr_apb, m_apb, n_apb, p_apb;
logic   [15 : 0]            a_addr_clk, b_addr_clk, c_addr_clk, m_clk, n_clk, p_clk;
logic   [6 * 16 - 1 : 0]    data_syncronizer [1 : 0];
logic                       start_apb, start_clk, done_apb, done_clk;
logic   [1 : 0]             start_sync, done_sync;
logic                       start_clk_pulse, start_clk_d;

regfile #(
    .ARRAY_HEIGHT( ARRAY_HEIGHT )
) regfile_i (
    .bus(config_bus),
    .matrix_a_addr_o( a_addr_apb ),
    .matrix_b_addr_o( b_addr_apb ),
    .matrix_c_addr_o( c_addr_apb ),
    .m_o            ( m_apb      ),
    .n_o            ( n_apb      ),
    .p_o            ( p_apb      ),
    .start_o        ( start_apb  ),
    .end_i          ( done_apb   )                    
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
    .m             ( m_clk              ),
    .n             ( n_clk              ),
    .p             ( p_clk              ),
    .base_addr_a   ( a_addr_clk         ),
    .base_addr_b   ( b_addr_clk         ),
    .base_addr_c   ( c_addr_clk         ),
    .operation_done( done_clk           )
);

// syncronizers
// start apb.clk -> clk
// done  clk -> apb.clk

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                 start_sync <= 'd0;          else
                                    start_sync <= { start_apb, start_sync[1] };
assign start_clk = start_sync[0];                                    

always_ff @( posedge config_bus.pclk or negedge config_bus.preset_n )
    if ( ~config_bus.preset_n )     done_sync <= 'd0;           else
                                    done_sync <= { done_clk, done_sync[1] };
assign done_apb = done_sync[0];       

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n ) begin
        data_syncronizer[0] <= 'd0;
        data_syncronizer[1] <= 'd0;
    end else begin
        data_syncronizer[1] <= {a_addr_apb, b_addr_apb, c_addr_apb, m_apb, n_apb, p_apb};
        data_syncronizer[0] <= data_syncronizer[1];
    end

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                 {a_addr_clk, b_addr_clk, c_addr_clk, m_clk, n_clk, p_clk} <= 'd0;       else
    if ( start_clk & ~start_clk_d ) {a_addr_clk, b_addr_clk, c_addr_clk, m_clk, n_clk, p_clk} = data_syncronizer[0];

// start pulse generator
always_ff @( posedge clk )
    start_clk_pulse = start_clk & ~start_clk_d;
always_ff @( posedge clk )
    start_clk_d <= start_clk;                

endmodule