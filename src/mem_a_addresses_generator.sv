module mem_a_addresses_generator #(
    parameter   BUS_WIDTH_BYTES         =   32,
    parameter   DATA_WIDTH_BYTES        =   1,
    parameter   ARRAY_HEIGHT            =   4
) (
    // generic signals
    input                               clk,
    input                               reset_n,
    // start signal from config module
    input                               start_i,
    // arrays parameters
    input       [15 : 0]                m,
    input       [15 : 0]                n,
    input       [15 : 0]                base_addr_a,
    // interface for a addresses fifo
    output  reg [15 : 0]                a_fifo_addr,
    output  reg                         a_fifo_incr,
    input                               a_fifo_full
);

localparam ELEMENTS = BUS_WIDTH_BYTES / DATA_WIDTH_BYTES;

reg     [15 : 0]    a_next_addr, a_start_row_index, a_column_index, rows, cols;
reg     [$clog2(ARRAY_HEIGHT) : 0] a_cycles;

enum bit[2: 0] { IDL, PUT_ADDR, WAIT_FULL, INCR_BASE, SKIP_ROWS } a_state, a_next_state;

wire     [15 : 0]    a_row_addr_step, a_rows_incr, column_step;

logic a_store_data, a_incr_col, a_incr_base, a_cycles_done, a_send_addr, a_store_new_col, a_store_new_row, a_end;

assign a_cycles_done = a_cycles == ARRAY_HEIGHT;
assign a_row_addr_step = n << $clog2(DATA_WIDTH_BYTES);
assign a_rows_incr = a_row_addr_step << $clog2(ARRAY_HEIGHT);

// a output signals
// fifo addresses
always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_fifo_addr <= 'd0;                     else
    if ( a_send_addr )      a_fifo_addr <= a_next_addr;             

// incr
always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_fifo_incr <= 1'b0;                    else
                            a_fifo_incr <= a_send_addr;

// a fsm

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_state <= IDL;                         else
                            a_state <= a_next_state;

always_comb begin
    a_next_state = a_state;

    a_store_data = 1'b0;
    a_send_addr = 1'b0;
    a_incr_col = 1'b0;
    a_incr_base = 1'b0;
    a_store_new_col = 1'b0;
    a_store_new_row = 1'b0;
    a_end = 1'b0;

    case (a_state)
        IDL : begin
            if ( start_i ) begin
                a_next_state = PUT_ADDR;
                a_store_data = 1'b1;
            end 
        end 
        PUT_ADDR : begin
            if ( a_cycles_done ) begin
                a_next_state = INCR_BASE;
                a_incr_col = 1'b1;
            end else if ( ~a_fifo_full ) begin
                a_next_state = WAIT_FULL;
                a_send_addr = 1'b1;
            end
        end
        WAIT_FULL : a_next_state = PUT_ADDR; 
        INCR_BASE : begin
            if ( cols < n ) begin
                a_next_state = PUT_ADDR;
                a_store_new_col = 1'b1;
            end else begin
                a_next_state = SKIP_ROWS;
                a_incr_base = 1'b1;
            end
        end
        SKIP_ROWS : begin
            if ( rows < m ) begin
                a_next_state = PUT_ADDR;
                a_store_new_row = 1'b1;
            end else begin
                a_next_state = IDL;
                a_end = 1'b1;
            end
        end
    endcase
end

// counters
always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_start_row_index <= 'd0;               else
    if ( a_store_data )     a_start_row_index <= base_addr_a;       else
    if ( a_incr_base )      a_start_row_index <= a_start_row_index + a_rows_incr;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_column_index <= 'd0;                  else
    if ( a_store_data )     a_column_index <= base_addr_a;          else
    if ( a_incr_col )       a_column_index <= a_column_index + ELEMENTS;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_cycles <= 'd0;                        else
    if ( a_send_addr )      a_cycles <= a_cycles + 'd1;             else
    if ( a_store_new_col )  a_cycles <= 'd0;                        else
    if ( a_store_new_row )  a_cycles <= 'd0;                        

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         a_next_addr <= 'd0;                     else
    if ( a_store_data )     a_next_addr <= base_addr_a;             else
    if ( a_store_new_col )  a_next_addr <= a_column_index;          else
    if ( a_store_new_row )  a_next_addr <= a_start_row_index;       else
    if ( a_send_addr )      a_next_addr <= a_next_addr + a_row_addr_step;

// indices counters

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         cols <= 'd0;                            else
    if ( a_store_data )     cols <= 'd0;                            else
    if ( a_incr_base )      cols <= 'd0;                            else
    if ( a_incr_col )       cols <= cols + ELEMENTS;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )         rows <= 'd0;                            else
    if ( a_store_data )     rows <= 'd0;                            else
    if ( a_incr_base )      rows <= rows + ARRAY_HEIGHT;

endmodule