module b_addresses_generator #(
    parameter ARRAY_HEIGHT   = 4,
    parameter ARRAY_WIDTH    = 32
) (
    // generic signals
    input                               clk,
    input                               reset_n,
    // start signal from config module
    input                               start_i,
    // arrays paramaeters
    input       [15 : 0]                m,
    input       [15 : 0]                n,
    input       [15 : 0]                p,
    input       [15 : 0]                base_addr_b,
    // interface for a addresses fifo
    output  reg [15 : 0]                b_fifo_addr,
    output  reg                         b_fifo_incr,
    input                               b_fifo_full
);

localparam BUS_WIDTH = 15'd256;
localparam ELEMENT_WIDTH = 1; // in bytes
localparam BUS_DATA = BUS_WIDTH / (ELEMENT_WIDTH * 8);

reg     [15 : 0]    b_start_index, b_next_addr, rows, cols, b_cycles;
wire    [15 : 0]    b_row_step, b_array_repeat;

logic   b_store_data, b_send_addr, b_skip_col, b_end, b_matrix_end, b_store_row, b_repeat;

enum bit[1 : 0] { IDL, PUT_ADDR, INCR_COL, REPEAT } b_state, b_next_state;

assign b_row_step = p * ELEMENT_WIDTH;
assign b_array_repeat = m >> $clog2(ARRAY_HEIGHT);

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
    b_repeat = 1'b0;

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
            if ( cols < p ) begin
                b_next_state = PUT_ADDR;
                b_store_row = 1'b1;
            end else begin
                b_next_state = REPEAT;
                b_matrix_end = 1'b1;
            end
        end
        REPEAT : begin
            if ( b_cycles < b_array_repeat ) begin
                b_next_state = PUT_ADDR;
                b_repeat = 1'b1;
            end else begin
                b_next_state = IDL;
                b_end = 1'b1;
            end
        end
    endcase
end

// counters

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_cycles <= 'd0;                        else
    if ( b_store_data )     b_cycles <= 'd0;                        else
    if ( b_repeat )         b_cycles <= b_cycles + 'd1;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_start_index <= 'd0;                   else
    if ( b_repeat )         b_start_index <= base_addr_b;           else
    if ( b_store_data )     b_start_index <= base_addr_b;           else
    if ( b_skip_col )       b_start_index <= b_start_index + BUS_DATA;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         b_next_addr <= 'd0;                     else
    if ( b_repeat )         b_next_addr <= base_addr_b;             else
    if ( b_store_data )     b_next_addr <= base_addr_b;             else
    if ( b_store_row )      b_next_addr <= b_start_index;           else
    if ( b_send_addr )      b_next_addr <= b_next_addr + b_row_step; 

// indices counters

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         cols <= 'd0;                            else
    if ( b_repeat )         cols <= 'd0;                            else
    if ( b_store_data )     cols <= 'd0;                            else
    if ( b_skip_col )       cols <= cols + BUS_DATA;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         rows <= 'd0;                            else
    if ( b_repeat )         rows <= 'd0;                            else
    if ( b_store_data )     rows <= 'd0;                            else
    if ( b_send_addr )      rows <= rows + 'd1;                     else
    if ( b_skip_col )       rows <= 'd0;


endmodule