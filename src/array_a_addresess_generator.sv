module array_a_addresses_generator #(
    parameter   ARRAY_HEIGHT            =   4,
    parameter   ARRAY_WIDTH             =   4,
    parameter   BUFFER_ADDRESS_WIDTH    =   10
) (
    // generic signals
    input                                       clk,
    input                                       reset_n,
    // start signal from config module
    input                                       start_i,
    // arrays parameters
    input       [15 : 0]                        m,
    input       [15 : 0]                        n,
    input       [15 : 0]                        p,
    // interface for memory read interface
    output  reg [BUFFER_ADDRESS_WIDTH - 1 : 0]  a_addr,
    output                                      done
);

reg     [BUFFER_ADDRESS_WIDTH - 1 : 0]  start_addr;
wire    [BUFFER_ADDRESS_WIDTH - 1 : 0]  limit_addr, plus_1;
reg     [15 : 0]                        repeat_no, repeat_rows;
wire    [15 : 0]                        repeat_lines, repeat_1, rows_limit;
wire                                    col_limit, repeat_limit, next, work, start;
reg                                     work_reg;

assign repeat_lines = (p >> $clog2(ARRAY_WIDTH)) - 1'b1;
assign rows_limit   = m >> $clog2(ARRAY_HEIGHT);
assign limit_addr   = start_addr + n - 1'b1;
assign col_limit    = a_addr == limit_addr;
assign plus_1       = a_addr + 1'b1;
assign repeat_1     = repeat_no + 1'b1;
assign next         = (repeat_1 == repeat_lines) & col_limit;
assign done         = (repeat_rows == rows_limit - 1'b1) & next;
assign start        = ~work_reg & start_i;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             work_reg <= 1'b0;       else
    if ( start_i )                              work_reg <= 1'b1;       else
    if ( done )                                 work_reg <= 1'b0;    

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             repeat_no <= 'd0;       else
    if ( start )                                repeat_no <= 'd0;       else
    if ( next )                                 repeat_no <= 'd0;       else
    if ( col_limit )                            repeat_no <= repeat_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             start_addr <= 'd0;      else
    if ( start )                                start_addr <= 'd0;      else
    if ( next )                                 start_addr <= plus_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             repeat_rows <= 'd0;      else
    if ( start )                                repeat_rows <= 'd0;      else
    if ( next )                                 repeat_rows <= repeat_rows + 1'b1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             a_addr <= 'd0;          else
    if ( start )                                a_addr <= 'd0;          else
    if ( col_limit )                            a_addr <= start_addr;   else
    if ( work_reg )                             a_addr <= plus_1;


endmodule