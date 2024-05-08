module data_sequencer # (
    parameter  DATA_INPUT_WIDTH     = 256   ,
    parameter  DATA_OUTPUT_WIDTH    = 32     
) (
    input                                   clk     ,
    input                                   reset_n ,
    input                                   valid_i ,
    input       [DATA_INPUT_WIDTH - 1 : 0]  data_i  ,
    output  reg                             accepted,
    output      [DATA_OUTPUT_WIDTH - 1 : 0] data_o  ,
    output  reg                             valid_o 
);

localparam COUNTER_LIMIT = DATA_INPUT_WIDTH / DATA_OUTPUT_WIDTH;

logic   [DATA_INPUT_WIDTH - 1 : 0]      data;
logic   [$clog2(COUNTER_LIMIT) - 1 : 0] counter;
logic                                   done;

assign done = counter == COUNTER_LIMIT - 1'b1;
assign data_o = data[DATA_OUTPUT_WIDTH - 1 : 0];

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     data <= 'd0;        else
    if ( valid_i & ~valid_o )           data <= data_i;     else
    if ( valid_o )                      data <= { {DATA_OUTPUT_WIDTH{1'b0}}, data[DATA_INPUT_WIDTH - 1 : DATA_OUTPUT_WIDTH] };

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     accepted <= 'd0;     else
    if ( valid_o )                      accepted <= 'd0;     else
    if ( valid_i & ~valid_o)            accepted <= 'd1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     valid_o <= 'd0;     else
    if ( done )                         valid_o <= 'd0;     else
    if ( valid_i )                      valid_o <= 'd1;     

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     counter <= 'd0;     else
    if ( done )                         counter <= 'd0;     else
    if ( valid_o )                      counter <= counter + 1'b1;
    
endmodule