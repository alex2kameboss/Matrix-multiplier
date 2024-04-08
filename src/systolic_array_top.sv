module systolic_array_top #(
    parameter   ARRAY_WIDTH         =   4,
    parameter   ARRAY_HEIGHT        =   32,
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
    input   [15 : 0]                        base_addr_b     
);
    
localparam MEM_DATA_WIDTH_BYTES     = 32;
localparam BUFFER_ADDRESS_WIDTH     = 10;
localparam ADDRESS_WIDTH            = 16;
localparam MEM_FIFO_DEPTH           = 128;
localparam MEM_ADD_WIRDTH           = 10;
localparam MEM_SIZE                 = 1 << MEM_ADD_WIRDTH;
localparam A_MEM_BANK_DATA_WIDTH    = ARRAY_HEIGHT * DATA_WIDTH_BYTES * 8;

wire                                    start_array;
wire                                    a_data_done, b_data_done;
reg start_array_d;
always_ff @(posedge clk)
    start_array_d <= start_array;

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

async_fifo #(
    .DATA_WIDTH( ADDRESS_WIDTH ),
    .FIFO_DEPTH( MEM_FIFO_DEPTH )
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


// for A matrix
wire    [255 : 0]                       b_mem_data, b_fifo_data, b_mem_bank_output;
wire    [ADDRESS_WIDTH - 1 : 0]         b_addr_fifo_out, b_addr_fifo_in;
wire                                    b_addr_inc, b_addr_full, b_mem_done, b_addr_fifo_empty;
wire                                    b_data_full, b_data_empty, b_data_inc;
wire                                    b_mem_bank_valid_data;
wire    [BUFFER_ADDRESS_WIDTH - 1 : 0]  b_w_mem_bank_address, b_r_mem_bank_address;

assign b_mem_bank_valid_data = ~b_data_empty;

memory_ctrl b_data_ctrl (
    .bus        ( b_bus                 ),
    .do_tran_i  ( ~b_addr_fifo_empty & ~b_mem_done   ),
    .w_en_i     ( 1'b0                  ),
    .addr_i     ( b_addr_fifo_out       ),
    .w_data_i   (                       ), // nc, read only
    .r_data_o   ( b_mem_data            ),
    .tran_done_o( b_mem_done            )
);

async_fifo #(
    .DATA_WIDTH( ADDRESS_WIDTH ),
    .FIFO_DEPTH( MEM_FIFO_DEPTH )
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
    .r_incr_i    ( b_mem_bank_valid_data),
    .r_empty_o   ( b_data_empty         ),
    .r_data      ( b_fifo_data          ) 
);

memory #(
    .DATA_SIZE  ( BUS_WIDTH_BYTES * 8   ),
    .DEPTH      ( MEM_SIZE              )
) b_mem_bank (
    .w_clk   ( clk                  ),
    .w_addr_i( b_w_mem_bank_address ),
    .w_data_i( b_fifo_data          ),
    .w_en_i  ( b_mem_bank_valid_data),
    .r_addr_i( b_r_mem_bank_address ),
    .r_data_o( b_mem_bank_output    ) 
);

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

// end for A matrix

logic data_done;
assign data_done = a_data_done & b_data_done;


systolic_array_ctrl #(
    .BUS_WIDTH_BYTES     ( BUS_WIDTH_BYTES      ),
    .DATA_WIDTH_BYTES    ( DATA_WIDTH_BYTES     ),
    .MEM_DATA_WIDTH_BYTES( MEM_DATA_WIDTH_BYTES ),
    .BUFFER_ADDRESS_WIDTH( BUFFER_ADDRESS_WIDTH ),
    .ARRAY_HEIGHT        ( ARRAY_HEIGHT         )
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
    .a_mem_fifo_full ( a_addr_full              ),
    .b_mem_fifo_addr ( b_addr_fifo_in           ),
    .b_mem_fifo_incr ( b_addr_inc               ),
    .b_mem_fifo_full ( b_addr_full              ),
    .a_valid_data    ( a_mem_bank_valid_data    ),
    .a_buffer_addr   ( a_w_mem_bank_address     ),
    .b_valid_data    ( b_mem_bank_valid_data    ),
    .b_buffer_addr   ( b_w_mem_bank_address     ),
    .array_start     ( start_array              ),
    .data_done       ( data_done                )
);

endmodule