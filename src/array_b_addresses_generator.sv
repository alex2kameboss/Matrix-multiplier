module array_b_addresses_generator #(
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
    output  reg [BUFFER_ADDRESS_WIDTH - 1 : 0]  b_addr,
    output                                      done
);

wire    [15 : 0]    rows_limit, cols_limit, repeat_no;
wire    [15 : 0]    cols_1, rows_1, matrixes_1;
reg     [15 : 0]    rows, cols, matrixes;
reg                 work_reg;
wire                col_done, row_done, start, matrix_done;

assign rows_limit = n;
assign cols_limit = p >> $clog2(ARRAY_WIDTH);
assign repeat_no = m >> $clog2(ARRAY_HEIGHT);
assign cols_1 = cols + 1'b1;
assign rows_1 = rows + 1'b1;
assign matrixes_1 = matrixes + 1'b1;
assign row_done = rows_1 == rows_limit;
assign col_done = (cols_1 == cols_limit) & row_done;
assign matrix_done = row_done & col_done;
assign done = (matrixes_1 == repeat_no) & matrix_done;
assign start = ~work_reg & start_i;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             work_reg <= 1'b0;       else
    if ( start_i )                              work_reg <= 1'b1;       else
    if ( done )                                 work_reg <= 1'b0;   

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             rows <= 'd0;            else
    if ( start )                                rows <= 'd0;            else
    if ( row_done )                             rows <= 'd0;            else    
    if ( work_reg )                             rows <= rows_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             cols <= 'd0;            else
    if ( start )                                cols <= 'd0;            else
    if ( col_done )                             cols <= 'd0;            else
    if ( row_done )                             cols <= cols_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             matrixes <= 'd0;        else
    if ( start )                                matrixes <= 'd0;        else
    if ( matrix_done )                          matrixes <= matrixes_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             b_addr <= 'd0;          else
    if ( start )                                b_addr <= 'd0;          else
    if ( matrix_done )                          b_addr <= 'd0;          else
    if ( work_reg )                             b_addr <= b_addr + 1'b1;

endmodule