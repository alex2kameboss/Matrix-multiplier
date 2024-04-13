module array_results_controller #(
    parameter   ARRAY_HEIGHT        =   4   ,
    parameter   ARRAY_WIDTH         =   32  ,
    parameter   DATA_WIDTH          =   16  ,
    parameter   BUS_WIDTH           =   256 
) (
    input                               clk                                                         ,
    input                               reset_n                                                     ,
    input       [15 : 0]                m                                                           ,
    input       [15 : 0]                n                                                           ,
    input       [15 : 0]                p                                                           ,
    input                               array_start                                                 ,
    input       [DATA_WIDTH - 1 : 0]    array_results   [ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH - 1 : 0] ,
    output                              array_reset_n   [ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH - 1 : 0] ,
    output  reg [BUS_WIDTH - 1 : 0]     data_o                                                      ,
    output  reg                         valid_o                                                     ,
    output                              done                                                                                  
);
    
localparam DIAGONAL_COUNTS  =   ARRAY_HEIGHT + ARRAY_WIDTH - 2;

logic   [$clog2(DIAGONAL_COUNTS) - 1 : 0]   diagonal_counter, diagonal_counter_1;
logic   [DATA_WIDTH - 1 : 0]                array_results_clone [ARRAY_HEIGHT - 1 : 0][ARRAY_WIDTH - 1 : 0];

genvar i, j;
generate
    for ( i = 0; i < ARRAY_HEIGHT; i = i + 1 ) begin : reset_generator
        for ( j = 0; j < ARRAY_WIDTH; j = j + 1)
            assign array_reset_n[i][j] = ~( diagonal_counter == i + j + 1 );
    end
endgenerate

generate
    for ( i = 0; i < ARRAY_HEIGHT; i = i + 1 ) begin : load_generator
        for ( j = 0; j < ARRAY_WIDTH; j = j + 1)
            always_ff @( posedge clk or negedge reset_n )
                if ( ~reset_n )                     array_results_clone[i][j] <= 'd0;           else
                if ( ~array_reset_n[i][j] )         array_results_clone[i][j] <= array_results[i][j];
    end
endgenerate

logic   [15 : 0]                            row_counter, row_counter_1, col_counter, col_counter_1, loop_counter, loop_counter_1;
logic                                       row_done, col_done, loop_done, diagonal_done, work;
logic                                       array_start_d;

assign row_counter_1    =   row_counter + ARRAY_HEIGHT;
assign col_counter_1    =   col_counter + ARRAY_WIDTH; 
assign loop_counter_1   =   loop_counter + 1'b1;
assign diagonal_counter_1 = diagonal_counter + 1'b1;
assign row_done         =   row_counter == m & col_done;
assign col_done         =   col_counter_1 == p & loop_done;
assign loop_done        =   loop_counter_1 == n;
assign diagonal_done    =   diagonal_counter == DIAGONAL_COUNTS;
assign done             =   col_done & row_done;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         array_start_d <= 'd0;    else
                                            array_start_d <= array_start;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         work <= 'd0;             else
    if ( done )                             work <= 'd0;             else
    if ( array_start_d )                    work <= 'd1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         row_counter <= 'd0;             else
    if ( row_done )                         row_counter <= 'd0;             else
    if ( col_done )                         row_counter <= row_counter_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         col_counter <= 'd0;             else
    if ( col_done )                         col_counter <= 'd0;             else
    if ( loop_done )                        col_counter <= col_counter_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         loop_counter <= 'd0;            else
    if ( loop_done )                        loop_counter <= 'd0;            else
    if ( work )                             loop_counter <= loop_counter_1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                         diagonal_counter <= 'd0;        else
    if ( diagonal_done )                    diagonal_counter <= 'd0;        else
    if ( loop_done & ~done | |diagonal_counter)     diagonal_counter <= diagonal_counter_1;

endmodule