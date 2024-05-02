module mem_bank_address_generator #(
    parameter   ARRAY_WIDTH             =   4   ,
    parameter   BUS_WIDTH_BYTES         =   32  ,
    parameter   DATA_WIDTH_BYTES        =   1   ,
    parameter   BUFFER_ADDRESS_WIDTH    =   10
) (
    input                                       clk             ,
    input                                       reset_n         ,
    // controll signals
    input                                       start_i         ,
    // matrix parameters
    input       [15 : 0]                        n               ,
    input       [15 : 0]                        p               ,
    // sequencer input
    input                                       valid_i         ,
    // mem bank output
    output  reg [BUFFER_ADDRESS_WIDTH - 1 : 0]  addr_o          ,
    // internal control unit
    output  reg [15 : 0]                        global_counts   ,
    input                                       clear              
);

localparam BURST = BUS_WIDTH_BYTES / DATA_WIDTH_BYTES / ARRAY_WIDTH;

logic   [BUFFER_ADDRESS_WIDTH - 1 : 0]  addr_next, addr_base, addr_base_1;
logic   [$clog2(BURST) - 1 : 0]         burst, burst_1;
logic                                   burst_done, row_done;
logic   [15 : 0]                        row, row_1;

assign burst_1      =   burst + 1'b1;
assign burst_done   =   &burst & ~|burst_1;
assign addr_next    =   addr_o + p;
assign addr_base_1  =   addr_base + 1'b1;
assign row_1        =   row + 1'b1;
assign row_done     =   row == (n - 1'b1) & burst_done;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     addr_o <= 'd0;              else
    if ( start_i )                      addr_o <= 'd0;              else
    if ( row_done )                     addr_o <= addr_o + 1'b1;    else
    if ( burst_done )                   addr_o <= addr_base_1;      else
    if ( valid_i )                      addr_o <= addr_next;        

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     addr_base <= 'd0;           else
    if ( start_i )                      addr_base <= 'd0;           else
    if ( row_done )                     addr_base <= addr_o + 1'b1; else
    if ( burst_done )                   addr_base <= addr_base_1;   

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     burst <= 'd0;               else
    if ( start_i )                      burst <= 'd0;               else
    if ( valid_i )                      burst <= burst_1;           

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     row <= 'd0;                 else
    if ( start_i )                      row <= 'd0;                 else
    if ( row_done )                     row <= 'd0;                 else
    if ( burst_done )                   row <= row_1;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                     global_counts <= 'd0;                   else
    if ( valid_i )                      global_counts <= global_counts + 'd1;   else
    if ( start_i | clear)               global_counts <= 'd0;    

endmodule