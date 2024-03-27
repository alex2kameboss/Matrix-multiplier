module mem_b_addresses_generator #(
    parameter   BUS_WIDTH_BYTES         =   32,
    parameter   DATA_WIDTH_BYTES        =   1,
    parameter   MEM_DATA_WIDTH_BYTES    =   32
) (
    // generic signals
    input                               clk,
    input                               reset_n,
    // start signal from config module
    input                               start_i,
    // arrays paramaeters
    input       [15 : 0]                n,
    input       [15 : 0]                p,
    input       [15 : 0]                base_addr_b,
    // interface for a addresses fifo
    output  reg [15 : 0]                b_fifo_addr,
    output  reg                         b_fifo_incr,
    input                               b_fifo_full
);

localparam ELEMENTS = MEM_DATA_WIDTH_BYTES / DATA_WIDTH_BYTES;

reg     [15 : 0]    b_start_index, b_next_addr, rows, cols;
wire    [15 : 0]    b_row_step;

logic   b_store_data, b_send_addr, b_skip_col, b_end, b_matrix_end, b_store_row;

enum bit[1 : 0] { IDL, PUT_ADDR, INCR_COL } b_state, b_next_state;

assign b_row_step = p << $clog2(DATA_WIDTH_BYTES);

// b output signals
// fifo addresses
always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_fifo_addr <= 'd0;                     else
    if ( b_send_addr )      b_fifo_addr <= b_next_addr;             

// incr
always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_fifo_incr <= 1'b0;                    else
                            b_fifo_incr <= b_send_addr;

// b fsm

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_state <= IDL;                         else
                            b_state <= b_next_state;

always_comb begin
    b_next_state = b_state;

    b_store_data = 1'b0;
    b_send_addr = 1'b0;
    b_skip_col = 1'b0;
    b_store_row = 1'b0;
    b_end = 1'b0;
    b_matrix_end = 1'b0;

    case (b_state)
        IDL : begin
            if ( start_i ) begin
                b_next_state = PUT_ADDR;
                b_store_data = 1'b1;
            end
        end 
        PUT_ADDR : begin
            if ( rows < n ) begin
                b_next_state = PUT_ADDR;
                b_send_addr = 1'b1;
            end else begin
                b_next_state = INCR_COL;
                b_skip_col = 1'b1;
            end
        end 
        INCR_COL : begin
            if ( cols == p ) begin
                b_next_state = IDL;
                b_end = 1'b1;
            end else begin
                b_next_state = PUT_ADDR;
                b_store_row = 1'b1;
            end
        end
    endcase
end

// counters

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_start_index <= 'd0;                   else
    if ( b_store_data )     b_start_index <= base_addr_b;           else
    if ( b_skip_col )       b_start_index <= b_start_index + ELEMENTS;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_next_addr <= 'd0;                     else
    if ( b_store_data )     b_next_addr <= base_addr_b;             else
    if ( b_store_row )      b_next_addr <= b_start_index;           else
    if ( b_send_addr )      b_next_addr <= b_next_addr + b_row_step; 

// indices counters

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         cols <= 'd0;                            else
    if ( b_store_data )     cols <= 'd0;                            else
    if ( b_skip_col )       cols <= cols + ELEMENTS;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         rows <= 'd0;                            else
    if ( b_store_data )     rows <= 'd0;                            else
    if ( b_send_addr )      rows <= rows + 'd1;                     else
    if ( b_skip_col )       rows <= 'd0;


endmodule