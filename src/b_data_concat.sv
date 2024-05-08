module b_data_concat # (
    parameter  DATA_INPUT_WIDTH     = 256   ,
    parameter  DATA_OUTPUT_WIDTH    = 512     
) (
    input                                   clk     ,
    input                                   reset_n ,
    input                                   valid_i ,
    input       [DATA_INPUT_WIDTH - 1 : 0]  data_i  ,
    output                                  accepted,
    output  reg [DATA_OUTPUT_WIDTH - 1 : 0] data_o  ,
    output  reg                             valid_o 
);

localparam COUNTER_LIMIT =  DATA_OUTPUT_WIDTH / DATA_INPUT_WIDTH;

assign accepted = valid_i;

logic   [$clog2(COUNTER_LIMIT) - 1 : 0] cnt;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     cnt <= 'd0;         else
    if ( valid_i )                      cnt <= cnt + 1'b1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     data_o <= 'd0;      else
    if ( valid_i )                      data_o <= {data_i, data_o[DATA_OUTPUT_WIDTH - 1 : DATA_INPUT_WIDTH]};

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     valid_o <= 1'b0;    else
                                        valid_o <= &cnt & valid_i;                  

endmodule