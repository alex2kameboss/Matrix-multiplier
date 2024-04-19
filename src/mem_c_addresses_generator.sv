module mem_c_addresses_generator #(
    parameter   BUS_WIDTH_BYTES         =   32  ,
    parameter   DATA_WIDTH_BYTES        =   2   ,
    parameter   ARRAY_HEIGHT            =   4   ,
    parameter   ARRAY_WIDTH             =   32  
) (
    // generic signals
    input                               clk         ,
    input                               reset_n     ,
    // start signal from config module
    input                               start_i     ,
    // arrays parameters
    input       [15 : 0]                m           ,
    input       [15 : 0]                p           ,
    input       [15 : 0]                base_addr_c ,
    // interface to c mem ctrl
    output reg                          do_tran     ,
    output      [15 : 0]                addr        ,
    input                               tran_done   ,
    // interface to c data buffer
    input                               fifo_empty  ,
    output                              fifo_incr   ,
    // signal to system
    output                              op_done     
);

enum bit [1 : 0] { IDL, WAIT_DATA, WRITE_DATA, UPDATE_ADDR } state, next_state;

assign fifo_incr = state == UPDATE_ADDR;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         state <= IDL;           else
                                            state <= next_state;

always_comb begin
    next_state = state;
    unique case (state)
        IDL         :   next_state = start_i ? WAIT_DATA : IDL; 
        WAIT_DATA   :   next_state = ~fifo_empty ? WRITE_DATA : WAIT_DATA;
        WRITE_DATA  :   next_state = tran_done ? UPDATE_ADDR : WRITE_DATA;
        UPDATE_ADDR :   next_state = op_done ? IDL : WAIT_DATA;
    endcase
end

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         do_tran <= 1'b0;        else
    if ( tran_done )                        do_tran <= 1'b0;        else
    if ( state == WRITE_DATA )              do_tran <= 1'b1;        

logic   [15 : 0]                        relative_addr, row_m, row_m_1, col_m, col_m_1;
logic   [15 : 0]                        row_intrmediate, col_intermidiate;
logic   [31 : 0]                        row_base;
logic   [$clog2(ARRAY_HEIGHT) - 1 : 0]  row, row_1;
logic   [$clog2(ARRAY_WIDTH) - 1 : 0]   col, col_1;
logic                                   matrix_done, matrix_col_done, matrix_row_done;
logic                                   row_done, col_done;

localparam COL_STEP = BUS_WIDTH_BYTES / DATA_WIDTH_BYTES;

assign row_1            = row + 1'b1;
assign col_1            = col + COL_STEP;
assign matrix_row_done  = ~|row_1;
assign matrix_col_done  = ~|col_1;
assign matrix_done      = matrix_col_done & matrix_row_done;
assign row_m_1          = row_m + ARRAY_HEIGHT;
assign col_m_1          = col_m + ARRAY_WIDTH;
assign row_done         = row_m_1 == m;
assign col_done         = col_m_1 == p;
assign op_done          = row_done & col_done & matrix_done;


always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             row <= 'd0;             else
    if ( state == UPDATE_ADDR )                 row <= row_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             col <= 'd0;             else
    if ( state == UPDATE_ADDR & matrix_row_done)col <= col_1;           

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             row_m <= 'd0;            else
    if ( state == IDL )                         row_m <= 'd0;            else  
    if ( state == UPDATE_ADDR & matrix_done & col_done )      row_m <= row_m_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                             col_m <= 'd0;            else
    if ( state == IDL )                         col_m <= 'd0;            else
    if ( state == UPDATE_ADDR & col_done & matrix_done)      col_m <= 'd0;            else  
    if ( state == UPDATE_ADDR & matrix_done)    col_m <= col_m_1;

mult #(
    .DATA_WIDTH(16)
) base_addr_mult (
    .a( row_intrmediate ),
    .b( p               ),
    .c( row_base        )
);

add #(
    .DATA_WIDTH(16)
) relative_addr_add (
    .a( row_base[15 : 0] ),
    .b( col_intermidiate ),
    .c( relative_addr    )
);

wire [15 : 0] add_pos;
assign addr = add_pos << $clog2(DATA_WIDTH_BYTES);

add #(
    .DATA_WIDTH(16)
) addr_add (
    .a( base_addr_c   ),
    .b( relative_addr ),
    .c( add_pos       )
);

add #(
    .DATA_WIDTH(16)
) row_add (
    .a( row_m            ),
    .b( {{16 - $clog2(ARRAY_HEIGHT){1'b0}}, row}       ),
    .c( row_intrmediate  )
);

add #(
    .DATA_WIDTH(16)
) col_addr (
    .a( col_m            ),
    .b( {{16 - $clog2(ARRAY_WIDTH){1'b0}}, col}       ),
    .c( col_intermidiate )
);

endmodule