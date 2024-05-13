module result_shift_lane #(
    parameter   ARRAY_WIDTH         =   4   ,
    parameter   DATA_WIDTH          =   16  ,
    parameter   BUS_WIDTH           =   256 
) (
    input                               clk                                     ,
    input                               reset_n                                 ,
    input                               array_reset_n   [ARRAY_WIDTH - 1 : 0]   ,
    input       [DATA_WIDTH - 1 : 0]    array_results   [ARRAY_WIDTH - 1 : 0]   ,
    output      [BUS_WIDTH - 1 : 0]     data_o                                  ,
    output                              valid_o                                 ,
    input                               accepted_i                              
);

localparam COUNTER = BUS_WIDTH / DATA_WIDTH;
//localparam REPLICATION = $rtoi(ARRAY_WIDTH * 1.0 / (BUS_WIDTH / DATA_WIDTH));
localparam REPLICATION = 16;

logic                                       valid_i;
logic   [DATA_WIDTH - 1 : 0]                data_i;
logic   [$clog2(COUNTER) - 1 : 0]           cnt;
logic   [ARRAY_WIDTH - 1 : 0]               packed_reset_n;
logic   [BUS_WIDTH - 1  : 0]                data [REPLICATION - 1 : 0];
logic                                       delay;
logic   [$clog2(REPLICATION) - 1 : 0]       w_ptr, r_ptr;
logic   [REPLICATION - 1 : 0]               valid;

assign  valid_i     = ~&packed_reset_n;
assign  data_o      = data[r_ptr];
assign  valid_o     = valid[r_ptr];

genvar i;
generate
    for ( i = 0; i < ARRAY_WIDTH; i = i + 1 ) begin : packed_conversion
        assign packed_reset_n[i] = array_reset_n[i];
    end
endgenerate

always_comb
    for ( int i = 0; i < ARRAY_WIDTH; i = i + 1 )
        if ( ~array_reset_n[i] )
            data_i = array_results[i];

genvar j;
generate
    for ( j = 0; j < REPLICATION; j = j + 1 ) begin : shit_register
always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     data[j] <= 'd0;            else
    if ( valid_i & w_ptr == j )         data[j] <= {data_i, data[j][BUS_WIDTH - 1 : DATA_WIDTH]};

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     valid[j] <= 1'b0;           else
    if ( w_ptr == j & &cnt )            valid[j] <= 1'b1;           else
    if ( r_ptr == j & accepted_i )      valid[j] <= 1'b0;
    end
endgenerate

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     cnt <= 'd0;             else
    if ( valid_i )                      cnt <= cnt + 1'b1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     w_ptr <= 'd0;            else
    if ( &cnt )                         w_ptr <= w_ptr + 1'b1;

always_ff @( posedge clk or negedge reset_n )
    if ( ~reset_n )                     r_ptr <= 'd0;            else
    if ( accepted_i )                   r_ptr <= r_ptr + 1'b1;

endmodule