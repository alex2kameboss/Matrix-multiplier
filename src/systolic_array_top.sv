module systolic_array_top #(
    parameter   ARRAY_WIDTH         =   32,
    parameter   ARRAY_HEIGHT        =   4,
    parameter   DATA_WIDTH          =   8,
    parameter   BUS_WIDTH_BYTES     =   32,
    parameter   DATA_WIDTH_BYTES    =   1
) (
    // data interfaces
    memory_interface.master                 a_bus           ,
    memory_interface.master                 b_bus           ,
    memory_interface.master                 c_bus           ,
    // logic signals
    input                                   clk             ,
    input                                   reset_n         ,
    // start signal from config module
    input                                   start_i         ,
    // arrays paramaeters
    input   [15 : 0]                        m               ,
    input   [15 : 0]                        n               ,
    input   [15 : 0]                        p               ,
    input   [15 : 0]                        base_addr_a     ,
    input   [15 : 0]                        base_addr_b     ,
    input   [15 : 0]                        base_addr_c     ,
    // operation done
    output                                  operation_done  
);
    
`ifndef MEM_ADDR_WIDTH
    `define MEM_ADDR_WIDTH 16
`endif

localparam MEM_DATA_WIDTH_BYTES     = 32;
localparam BUFFER_ADDRESS_WIDTH     = 16;
localparam ADDRESS_WIDTH            = 16;
localparam MEM_FIFO_DEPTH           = 8192;
localparam MEM_ADDR_WIDTH           = `MEM_ADDR_WIDTH;
localparam MEM_SIZE                 = 1 << MEM_ADDR_WIDTH;
localparam A_MEM_BANK_DATA_WIDTH    = ARRAY_HEIGHT * DATA_WIDTH_BYTES * 8;

wire                                    start_i_c_bus, ooperation_done_c_bus;

wire                                    start_array;
wire                                    a_data_done, b_data_done;
wire                                    array_done;
reg start_array_d;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                     start_array_d <= 1'b0;      else
    if ( array_done )                   start_array_d <= 1'b0;      else
    if ( start_array )                  start_array_d <= 1'b1;            

wire start_data;
assign start_data = ~start_array_d & start_array;


// for A matrix
wire    [255 : 0]                       a_mem_data, a_fifo_data;
wire    [ADDRESS_WIDTH - 1 : 0]         a_addr_fifo_out, a_addr_fifo_in;
wire                                    a_addr_inc, a_addr_full, a_mem_done, a_addr_fifo_empty;
wire                                    a_data_full, a_data_empty, a_data_inc;
wire    [A_MEM_BANK_DATA_WIDTH - 1 : 0] a_mem_bank_input, a_mem_bank_output;  
wire                                    a_mem_bank_valid_data;
wire    [BUFFER_ADDRESS_WIDTH - 1 : 0]  a_w_mem_bank_address, a_r_mem_bank_address;

memory_ctrl a_data_ctrl (
    .bus        ( a_bus                 ),
    .do_tran_i  ( ~a_addr_fifo_empty & ~a_mem_done   ),
    .w_en_i     ( 1'b0                  ),
    .addr_i     ( a_addr_fifo_out       ),
    .w_data_i   (                       ), // nc, read only
    .r_data_o   ( a_mem_data            ),
    .tran_done_o( a_mem_done            )
);

`ifndef XILINX

async_fifo #(
    .DATA_WIDTH( ADDRESS_WIDTH ),
    .FIFO_DEPTH( 64 )
) a_address_fifo (
    .w_clk       ( clk                  ),
    .w_reset_n   ( reset_n              ),
    .w_incr_i    ( a_addr_inc           ),
    .w_full_o    ( a_addr_full          ),
    .w_data      ( a_addr_fifo_in       ),
    .r_clk       ( a_bus.clk            ),
    .r_reset_n   ( a_bus.reset_n        ),
    .r_incr_i    ( a_mem_done           ),
    .r_empty_o   ( a_addr_fifo_empty    ),
    .r_data      ( a_addr_fifo_out      ) 
);

async_fifo #(
    .DATA_WIDTH( 256 ),
    .FIFO_DEPTH( MEM_FIFO_DEPTH )
) a_data_fifo (
    .w_clk       ( a_bus.clk        ),
    .w_reset_n   ( a_bus.reset_n    ),
    .w_incr_i    ( a_mem_done       ),
    .w_full_o    ( a_data_full      ),
    .w_data      ( a_mem_data       ),
    .r_clk       ( clk              ),
    .r_reset_n   ( reset_n          ),
    .r_incr_i    ( a_data_inc       ),
    .r_empty_o   ( a_data_empty     ),
    .r_data      ( a_fifo_data      ) 
);

memory #(
    .DATA_SIZE  ( A_MEM_BANK_DATA_WIDTH ),
    .DEPTH      ( MEM_SIZE              )
) a_mem_bank (
    .w_clk   ( clk                  ),
    .w_addr_i( a_w_mem_bank_address ),
    .w_data_i( a_mem_bank_input     ),
    .w_en_i  ( a_mem_bank_valid_data),
    .r_addr_i( a_r_mem_bank_address ),
    .r_data_o( a_mem_bank_output    ) 
);

`else

addr_fifo a_address_fifo (
    .wr_clk ( clk               ),
    .wr_rst ( ~reset_n          ),
    .rd_clk ( a_bus.clk         ),
    .rd_rst ( ~a_bus.reset_n    ),
    .din    ( a_addr_fifo_in    ),
    .wr_en  ( a_addr_inc        ),
    .rd_en  ( a_mem_done        ),
    .dout   ( a_addr_fifo_out   ),
    .full   ( a_addr_full       ),
    .empty  ( a_addr_fifo_empty ) 
);


data_fifo a_data_fifo (
    .wr_clk ( a_bus.clk     ) ,
    .wr_rst ( ~a_bus.reset_n) ,
    .rd_clk ( clk           ) ,
    .rd_rst ( ~reset_n      ) ,
    .din    ( a_mem_data    ) ,
    .wr_en  ( a_mem_done    ) ,
    .rd_en  ( a_data_inc    ) ,
    .dout   ( a_fifo_data   ) ,
    .full   ( a_data_full   ) ,
    .empty  ( a_data_empty  ) 
);

mem_block a_mem_bank (
    .clka  ( clk                    ),
    .wea   ( a_mem_bank_valid_data  ),
    .addra ( a_w_mem_bank_address   ),
    .dina  ( a_mem_bank_input       ),
    .clkb  ( clk                    ),
    .addrb ( a_r_mem_bank_address   ),
    .doutb ( a_mem_bank_output      )
);

`endif

row_converter #(
    .BUS_WIDTH_BYTES ( BUS_WIDTH_BYTES  ),
    .DATA_WIDTH_BYTES( DATA_WIDTH_BYTES ),
    .ARRAY_HEIGHT    ( ARRAY_HEIGHT     )
) a_row_convertor (
    .clk     ( clk                      ),
    .reset_n ( reset_n                  ),
    .valid_i ( ~a_data_empty & ~a_data_inc),
    .data_i  ( a_fifo_data              ),
    .data_o  ( a_mem_bank_input         ),
    .valid_o ( a_mem_bank_valid_data    ),
    .accepted( a_data_inc               )
);

array_a_addresses_generator #(
    .ARRAY_HEIGHT        ( ARRAY_HEIGHT         ),
    .ARRAY_WIDTH         ( ARRAY_WIDTH          ),
    .BUFFER_ADDRESS_WIDTH( BUFFER_ADDRESS_WIDTH )
) a_array_address_generator (
    .clk    ( clk                   ),
    .reset_n( reset_n               ),
    .start_i( start_data            ),
    .m      ( m                     ),
    .n      ( n                     ),
    .p      ( p                     ),
    .a_addr ( a_r_mem_bank_address  ),
    .done   ( a_data_done           )
);

// end for A matrix


// for B matrix
wire    [255 : 0]                       b_mem_data, b_data_buffer_output;
wire    [ADDRESS_WIDTH - 1 : 0]         b_addr_fifo_out, b_addr_fifo_in;
wire                                    b_addr_inc, b_addr_full, b_mem_done, b_addr_fifo_empty;
wire                                    b_data_full, b_data_empty, b_data_inc, b_data_fifo_accepted;
wire                                    b_mem_bank_valid_data;
wire    [BUFFER_ADDRESS_WIDTH - 1 : 0]  b_w_mem_bank_address, b_r_mem_bank_address;
wire    [ARRAY_WIDTH * DATA_WIDTH_BYTES * 8 - 1 : 0]  b_mem_data_in, b_mem_bank_output;

memory_ctrl b_data_ctrl (
    .bus        ( b_bus                 ),
    .do_tran_i  ( ~b_addr_fifo_empty & ~b_mem_done   ),
    .w_en_i     ( 1'b0                  ),
    .addr_i     ( b_addr_fifo_out       ),
    .w_data_i   (                       ), // nc, read only
    .r_data_o   ( b_mem_data            ),
    .tran_done_o( b_mem_done            )
);

`ifndef XILINX

async_fifo #(
    .DATA_WIDTH( ADDRESS_WIDTH ),
    .FIFO_DEPTH( 64 )
) b_address_fifo (
    .w_clk       ( clk                  ),
    .w_reset_n   ( reset_n              ),
    .w_incr_i    ( b_addr_inc           ),
    .w_full_o    ( b_addr_full          ),
    .w_data      ( b_addr_fifo_in       ),
    .r_clk       ( b_bus.clk            ),
    .r_reset_n   ( b_bus.reset_n        ),
    .r_incr_i    ( b_mem_done           ),
    .r_empty_o   ( b_addr_fifo_empty    ),
    .r_data      ( b_addr_fifo_out      ) 
);

async_fifo #(
    .DATA_WIDTH( BUS_WIDTH_BYTES * 8 ),
    .FIFO_DEPTH( MEM_FIFO_DEPTH )
) b_data_fifo (
    .w_clk       ( b_bus.clk            ),
    .w_reset_n   ( b_bus.reset_n        ),
    .w_incr_i    ( b_mem_done           ),
    .w_full_o    ( b_data_full          ),
    .w_data      ( b_mem_data           ),
    .r_clk       ( clk                  ),
    .r_reset_n   ( reset_n              ),
    .r_incr_i    ( b_data_fifo_accepted ),
    .r_empty_o   ( b_data_empty         ),
    .r_data      ( b_data_buffer_output ) 
);

memory #(
    .DATA_SIZE  ( ARRAY_WIDTH * DATA_WIDTH_BYTES * 8 ),
    .DEPTH      ( MEM_SIZE                           )
) b_mem_bank (
    .w_clk   ( clk                  ),
    .w_addr_i( b_w_mem_bank_address ),
    .w_data_i( b_mem_data_in        ),
    .w_en_i  ( b_mem_bank_valid_data),
    .r_addr_i( b_r_mem_bank_address ),
    .r_data_o( b_mem_bank_output    ) 
);

`else

addr_fifo b_address_fifo (
    .wr_clk ( clk               ),
    .wr_rst ( ~reset_n          ),
    .rd_clk ( b_bus.clk         ),
    .rd_rst ( ~b_bus.reset_n    ),
    .din    ( b_addr_fifo_in    ),
    .wr_en  ( b_addr_inc        ),
    .rd_en  ( b_mem_done        ),
    .dout   ( b_addr_fifo_out   ),
    .full   ( b_addr_full       ),
    .empty  ( b_addr_fifo_empty ) 
);

data_fifo b_data_fifo (
    .wr_clk ( b_bus.clk             ) ,
    .wr_rst ( ~b_bus.reset_n        ) ,
    .rd_clk ( clk                   ) ,
    .rd_rst ( ~reset_n              ) ,
    .din    ( b_mem_data            ) ,
    .wr_en  ( b_mem_done            ) ,
    .rd_en  ( b_data_fifo_accepted  ) ,
    .dout   ( b_data_buffer_output  ) ,
    .full   ( b_data_full           ) ,
    .empty  ( b_data_empty          ) 
);

mem_block b_mem_bank (
    .clka  ( clk                    ),
    .wea   ( b_mem_bank_valid_data  ),
    .addra ( b_w_mem_bank_address   ),
    .dina  ( b_mem_data_in          ),
    .clkb  ( clk                    ),
    .addrb ( b_r_mem_bank_address   ),
    .doutb ( b_mem_bank_output      )
);

`endif
generate
    if ( ARRAY_WIDTH * DATA_WIDTH_BYTES < BUS_WIDTH_BYTES ) begin
data_sequencer # (
    .DATA_INPUT_WIDTH  ( BUS_WIDTH_BYTES * 8 ) ,
    .DATA_OUTPUT_WIDTH ( ARRAY_WIDTH * DATA_WIDTH_BYTES * 8 )  
) b_data_sequncer (
    .clk      ( clk                     ),
    .reset_n  ( reset_n                 ),
    .valid_i  ( ~b_data_empty           ),
    .data_i   ( b_data_buffer_output    ),
    .accepted ( b_data_fifo_accepted    ),
    .data_o   ( b_mem_data_in           ),
    .valid_o  ( b_mem_bank_valid_data   ) 
);    
    end else if ( ARRAY_WIDTH * DATA_WIDTH_BYTES > BUS_WIDTH_BYTES ) begin
b_data_concat # (
    .DATA_INPUT_WIDTH  ( BUS_WIDTH_BYTES * 8 ) ,
    .DATA_OUTPUT_WIDTH ( ARRAY_WIDTH * DATA_WIDTH_BYTES * 8 )  
) b_data_concat (
    .clk      ( clk                     ),
    .reset_n  ( reset_n                 ),
    .valid_i  ( ~b_data_empty           ),
    .data_i   ( b_data_buffer_output    ),
    .accepted ( b_data_fifo_accepted    ),
    .data_o   ( b_mem_data_in           ),
    .valid_o  ( b_mem_bank_valid_data   ) 
);    
    end else begin
assign b_mem_data_in = b_data_buffer_output;
assign b_mem_bank_valid_data = ~b_data_empty;
assign b_data_fifo_accepted = b_mem_bank_valid_data;
    end
endgenerate

array_b_addresses_generator #(
    .ARRAY_HEIGHT        ( ARRAY_HEIGHT         ),
    .ARRAY_WIDTH         ( ARRAY_WIDTH          ),
    .BUFFER_ADDRESS_WIDTH( BUFFER_ADDRESS_WIDTH )
) b_array_address_generator (
    .clk    ( clk                   ),
    .reset_n( reset_n               ),
    .start_i( start_data            ),
    .m      ( m                     ),
    .n      ( n                     ),
    .p      ( p                     ),
    .b_addr ( b_r_mem_bank_address  ),
    .done   ( b_data_done           )
);

// end for B matrix

logic data_done;
assign data_done = a_data_done & b_data_done;


systolic_array_ctrl #(
    .BUS_WIDTH_BYTES     ( BUS_WIDTH_BYTES      ),
    .DATA_WIDTH_BYTES    ( DATA_WIDTH_BYTES     ),
    .MEM_DATA_WIDTH_BYTES( MEM_DATA_WIDTH_BYTES ),
    .BUFFER_ADDRESS_WIDTH( BUFFER_ADDRESS_WIDTH ),
    .ARRAY_HEIGHT        ( ARRAY_HEIGHT         ),
    .ARRAY_WIDTH         ( ARRAY_WIDTH          )
) contorller (
    .clk             ( clk                      ),
    .reset_n         ( reset_n                  ),
    .start_i         ( start_i                  ),
    .m               ( m                        ),
    .n               ( n                        ),
    .p               ( p                        ),
    .base_addr_a     ( base_addr_a              ),
    .base_addr_b     ( base_addr_b              ),
    .a_mem_fifo_addr ( a_addr_fifo_in           ),
    .a_mem_fifo_incr ( a_addr_inc               ),
    .a_mem_fifo_full ( a_addr_full | a_data_full),
    .b_mem_fifo_addr ( b_addr_fifo_in           ),
    .b_mem_fifo_incr ( b_addr_inc               ),
    .b_mem_fifo_full ( b_addr_full | b_data_full),
    .a_valid_data    ( a_mem_bank_valid_data    ),
    .a_buffer_addr   ( a_w_mem_bank_address     ),
    .b_valid_data    ( b_mem_bank_valid_data    ),
    .b_buffer_addr   ( b_w_mem_bank_address     ),
    .array_start     ( start_array              ),
    .data_done       ( data_done                )
);

// systolic array

wire    [ARRAY_HEIGHT * DATA_WIDTH_BYTES * 8 - 1 : 0] row_array_input;
wire    [ARRAY_WIDTH * DATA_WIDTH_BYTES * 8 - 1 : 0]                       col_array_input;
wire                                    array_reset_n [ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH - 1 : 0];
wire    [2 * DATA_WIDTH - 1 : 0]        c_array_output[ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH - 1 : 0];

genvar i, j;

crossbar #(
    .DATA_WIDTH     ( DATA_WIDTH_BYTES * 8 ),
    .ARRAY_ELLEMENTS( ARRAY_HEIGHT         )
) row_crossbar (
    .clk            ( clk               ) ,
    .reset_n        ( reset_n           ) ,
    .sync_reset_n   ( 1'b1              ) ,
    .shift          ( start_array_d     ) ,
    .data_i         ( a_mem_bank_output ) ,
    .data_o         ( row_array_input   ) 
);

crossbar #(
    .DATA_WIDTH     ( DATA_WIDTH_BYTES * 8 ),
    .ARRAY_ELLEMENTS( ARRAY_WIDTH          )
) col_crossbar (
    .clk            ( clk               ) ,
    .reset_n        ( reset_n           ) ,
    .sync_reset_n   ( 1'b1              ) ,
    .shift          ( start_array_d     ) ,
    .data_i         ( b_mem_bank_output ) ,
    .data_o         ( col_array_input   ) 
);

systolic_array #(
    .ARRAY_WIDTH ( ARRAY_WIDTH          ),
    .ARRAY_HEIGHT( ARRAY_HEIGHT         ),
    .DATA_WIDTH  ( DATA_WIDTH_BYTES * 8 )
) array (
    .clk            ( clk               ),
    .reset_n        ( reset_n           ),
    .array_reset_n  ( array_reset_n     ),
    .work           ( start_array_d     ),
    .a_array_input  ( row_array_input   ),
    .b_array_input  ( col_array_input   ),
    .c_array_output ( c_array_output    )
);

// result array

wire [BUS_WIDTH_BYTES * 8 - 1 : 0]  w_result_data, r_result_data_fifo;
wire [15 : 0]                       c_addr;
wire                                c_do_tran, c_tran_done, c_data_fifo_incr;
wire                                w_result_valid, r_result_empty, r_result_incr;


array_results_controller #(
    .ARRAY_HEIGHT( ARRAY_HEIGHT         ),
    .ARRAY_WIDTH ( ARRAY_WIDTH          ),
    .DATA_WIDTH  ( DATA_WIDTH_BYTES * 16),
    .BUS_WIDTH   ( BUS_WIDTH_BYTES * 8  )
) array_results_controller (
    .clk          ( clk             ),
    .reset_n      ( reset_n         ),
    .m            ( m               ),
    .n            ( n               ),
    .p            ( p               ),
    .array_start  ( start_array     ),
    .array_results( c_array_output  ),
    .array_reset_n( array_reset_n   ),
    .data_o       ( w_result_data   ),
    .valid_o      ( w_result_valid  ),
    .done         ( array_done      )                            
);

async_fifo #(
    .DATA_WIDTH( BUS_WIDTH_BYTES * 8 ),
    .FIFO_DEPTH( MEM_SIZE )
) c_data_fifo (
    .w_clk       ( clk                  ),
    .w_reset_n   ( reset_n              ),
    .w_incr_i    ( w_result_valid       ),
    .w_full_o    (                      ), // nc, to not write data is not an option
    .w_data      ( w_result_data        ),
    .r_clk       ( c_bus.clk            ),
    .r_reset_n   ( c_bus.reset_n        ),
    .r_incr_i    ( c_data_fifo_incr     ),
    .r_empty_o   ( r_result_empty       ),
    .r_data      ( r_result_data_fifo   ) 
);

mem_c_addresses_generator #(
    .BUS_WIDTH_BYTES ( BUS_WIDTH_BYTES  ),
    .DATA_WIDTH_BYTES( DATA_WIDTH_BYTES * 2 ),
    .ARRAY_HEIGHT    ( ARRAY_HEIGHT     ),
    .ARRAY_WIDTH     ( BUS_WIDTH_BYTES / DATA_WIDTH_BYTES / 2 )
) c_addr_gen (
    .clk        ( c_bus.clk             ),
    .reset_n    ( c_bus.reset_n         ),
    .start_i    ( start_i_c_bus         ),
    .m          ( m                     ),
    .p          ( p                     ),
    .base_addr_c( base_addr_c           ),
    .do_tran    ( c_do_tran             ),
    .addr       ( c_addr                ),
    .tran_done  ( c_tran_done           ),
    .fifo_empty ( r_result_empty        ),
    .fifo_incr  ( c_data_fifo_incr      ),
    .op_done    ( ooperation_done_c_bus )
);

memory_ctrl c_data_ctrl (
    .bus        ( c_bus                 ),
    .do_tran_i  ( c_do_tran             ),
    .w_en_i     ( 1'b1                  ),
    .addr_i     ( c_addr                ),
    .w_data_i   ( r_result_data_fifo    ),
    .r_data_o   (                       ), // nc, write only
    .tran_done_o( c_tran_done           )
);

// syncronizers
// for start_i (clk -> c_bus.clk)
// for op_done (c_bus.clk -> clk)

logic [1 : 0] start_i_c_bus_clk, op_done_clk;
assign start_i_c_bus    = start_i_c_bus_clk[0];
assign operation_done   = op_done_clk[0];

always_ff @( posedge c_bus.clk or negedge c_bus.reset_n )
    if ( ~c_bus.reset_n )                       start_i_c_bus_clk <= 'd0;   else
                                                start_i_c_bus_clk <= { start_i, start_i_c_bus_clk[1] };

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             op_done_clk <= 'd0;         else
                                                op_done_clk <= { ooperation_done_c_bus, op_done_clk[1] };

endmodule