module systolic_array_ctrl #(
    parameter   BUS_WIDTH_BYTES         =   32,
    parameter   DATA_WIDTH_BYTES        =   1,
    parameter   MEM_DATA_WIDTH_BYTES    =   32,
    parameter   BUFFER_ADDRESS_WIDTH    =   10,
    parameter   ARRAY_HEIGHT            =   4,
    parameter   ARRAY_WIDTH             =   4
) (
    // generic signals
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
    // interface for a addresses fifo
    output  [15 : 0]                        a_mem_fifo_addr ,
    output                                  a_mem_fifo_incr ,
    input                                   a_mem_fifo_full ,
    // interface for b addresses fifo
    output  [15 : 0]                        b_mem_fifo_addr ,
    output                                  b_mem_fifo_incr ,
    input                                   b_mem_fifo_full ,
    // interface for a buffer
    input                                   a_valid_data    ,
    output  [BUFFER_ADDRESS_WIDTH - 1 : 0]  a_buffer_addr   ,
    // interface for b buffer
    input                                   b_valid_data    ,
    output  [BUFFER_ADDRESS_WIDTH - 1 : 0]  b_buffer_addr   ,
    // systolic_array_start
    output  reg                             array_start     ,
    input                                   data_done       
);
    
wire b_matrix_done;

mem_a_addresses_generator #(.BUS_WIDTH_BYTES(BUS_WIDTH_BYTES),
                            .DATA_WIDTH_BYTES(DATA_WIDTH_BYTES),
                            .ARRAY_HEIGHT(ARRAY_HEIGHT)) a_adrrs_gen_i (
    .clk(clk),
    .reset_n(reset_n),
    .start_i(start_i),
    .m(m),
    .n(n),
    .base_addr_a(base_addr_a),
    .a_fifo_addr(a_mem_fifo_addr),
    .a_fifo_incr(a_mem_fifo_incr),
    .a_fifo_full(a_mem_fifo_full)
);

mem_b_addresses_generator #(.BUS_WIDTH_BYTES(BUS_WIDTH_BYTES),
                            .DATA_WIDTH_BYTES(DATA_WIDTH_BYTES),
                            .MEM_DATA_WIDTH_BYTES(MEM_DATA_WIDTH_BYTES)) b_addrs_gen_i (
    .clk(clk),
    .reset_n(reset_n),
    .start_i(start_i),
    .n(n),
    .p(p),
    .base_addr_b(base_addr_b),
    .b_fifo_addr(b_mem_fifo_addr),
    .b_fifo_incr(b_mem_fifo_incr),
    .b_fifo_full(b_mem_fifo_full)
);

wire a_half_mem, b_half_mem;
wire a_half_addr, b_half_addr;
wire [31 : 0] mxn_result, nxp_result;
wire [15 : 0] a_count_addr, b_count_addr;

wire [15 : 0] a_half_addr_value, b_half_addr_value;
assign a_half_addr_value = mxn_result[15 + $clog2(ARRAY_HEIGHT):$clog2(ARRAY_HEIGHT)]; // div ARRAY_HEIGHT * DATA_WIDTH_BYTES * 2 => $clog2(ARRAY_HEIGHT * DATA_WIDTH_BYTES) + 1
assign b_half_addr_value = nxp_result[15 + $clog2(ARRAY_WIDTH):$clog2(ARRAY_WIDTH)]; // div 32 * 2 => 2^6


assign a_half_addr = a_count_addr == a_half_addr_value;
assign b_half_addr = b_count_addr == b_half_addr_value;

buffer_write_address_generator #(.BUFFER_ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH)) a_buf_addr_i (
    .clk(clk),
    .reset_n(reset_n),
    .start_i(start_i),
    .count_up(a_valid_data),
    .global_counts(a_count_addr),
    .address(a_buffer_addr),
    .limit_pass(a_half_mem),
    .clear(data_done)
);

generate
    if ( ARRAY_WIDTH * DATA_WIDTH_BYTES < BUS_WIDTH_BYTES ) begin
mem_bank_address_generator #(
    .ARRAY_WIDTH         ( ARRAY_WIDTH          ),
    .DATA_WIDTH_BYTES    ( DATA_WIDTH_BYTES     ),
    .BUS_WIDTH_BYTES     ( MEM_DATA_WIDTH_BYTES ),
    .BUFFER_ADDRESS_WIDTH( BUFFER_ADDRESS_WIDTH )
) b_buf_addr_i (
    .clk            ( clk              ),
    .reset_n        ( reset_n          ),
    .start_i        ( start_i          ),
    .n              ( n                ),
    .p              ( p                ),
    .valid_i        ( b_valid_data     ),
    .addr_o         ( b_buffer_addr    ),
    .global_counts  ( b_count_addr     ),
    .limit_pass     ( b_half_mem       ),
    .clear          ( data_done        )

);
    end else begin
buffer_write_address_generator #(.BUFFER_ADDRESS_WIDTH(BUFFER_ADDRESS_WIDTH)) b_buf_addr_i (
    .clk(clk),
    .reset_n(reset_n),
    .start_i(start_i),
    .count_up(b_valid_data),
    .global_counts(b_count_addr),
    .address(b_buffer_addr),
    .limit_pass(b_half_mem),
    .clear(data_done)
);
end
endgenerate

logic b_start_reg, a_start_reg;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                 a_start_reg <= 1'b0;        else
    if ( data_done )                a_start_reg <= 1'b0;        else
    if ( (a_half_mem | a_half_addr) & |mxn_result) a_start_reg <= 1'b1;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                 b_start_reg <= 1'b0;        else
    if ( data_done )                b_start_reg <= 1'b0;        else
    if ( (b_half_mem | b_half_addr) & |nxp_result ) b_start_reg <= 1'b1;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                                                         array_start <= 1'b0;            else
    if ( data_done )                                                        array_start <= 1'b0;            else
    if ( a_start_reg & b_start_reg )                                        array_start <= 1'b1;            

mult #(.DATA_WIDTH(16)) mxn_mult (
    .a(m),
    .b(n),
    .c(mxn_result)
);

mult #(.DATA_WIDTH(16)) nxp_mult (
    .a(n),
    .b(p),
    .c(nxp_result)
);

endmodule