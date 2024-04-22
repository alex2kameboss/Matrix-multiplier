module row_converter #(
    parameter   BUS_WIDTH_BYTES         =   32,
    parameter   DATA_WIDTH_BYTES        =   1,
    parameter   ARRAY_HEIGHT            =   4
) (
    // generic signals
    input                                                       clk     ,
    input                                                       reset_n ,
    // inputs
    input                                                       valid_i ,
    input       [BUS_WIDTH_BYTES * 8 - 1: 0]                    data_i  ,
    // output
    output      [ARRAY_HEIGHT * DATA_WIDTH_BYTES * 8 - 1 : 0]   data_o  ,
    output  reg                                                 valid_o ,
    output  reg                                                 accepted
);

localparam SHIFT_BITES = DATA_WIDTH_BYTES * 8;
localparam NUMBER_OF_SHIFTS = BUS_WIDTH_BYTES / DATA_WIDTH_BYTES;

enum bit[1 : 0] { IDL, ACCEPT, VALID, SHIFT } state, next_state;

reg [BUS_WIDTH_BYTES * 8 - 1: 0]        buffer  [0 : ARRAY_HEIGHT - 1];
reg [$clog2(ARRAY_HEIGHT) : 0]      counter;
reg [$clog2(NUMBER_OF_SHIFTS) - 1 : 0]  shift_counter;
wire end_drop, shift;
wire accept_data;

assign accept_data = state == ACCEPT;
assign shift = state == SHIFT;
assign end_drop = state == SHIFT & next_state == IDL;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                         state <= IDL;               else
                                            state <= next_state;

always_comb begin
    next_state = state;
    unique case ( state )
        IDL: begin
            if ( counter[$clog2(ARRAY_HEIGHT)] ) begin
                next_state = VALID;
            end else if ( valid_i ) begin
                next_state = ACCEPT;
            end 
        end
        ACCEPT: next_state = IDL;
        VALID: next_state = SHIFT;
        SHIFT: begin
            if ( ~&shift_counter ) begin
                next_state = VALID;
            end else begin
                next_state = IDL;
            end
        end
    endcase
end

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                         counter <= 'd0;             else
    if ( end_drop )                         counter <= 'd0;             else
    if ( accept_data )                      counter <= counter + 1'b1;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                         accepted <= 'd0;            else
    if ( accept_data )                      accepted <= 'd1;            else
                                            accepted <= 'd0;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n ) begin
        for ( int i = 0; i < ARRAY_HEIGHT; i = i +1)
            buffer[i] <= 'd0;
    end else
    if ( accept_data )                      buffer[counter] <= data_i;  else
    if ( shift ) begin
        for (int i = 0; i < ARRAY_HEIGHT; i = i + 1)
            buffer[i] <= {{SHIFT_BITES{1'b0}}, buffer[i][BUS_WIDTH_BYTES * 8 - 1 : SHIFT_BITES]};
    end

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                         shift_counter <= 'd0;       else
    if ( end_drop )                         shift_counter <= 'd0;       else
    if ( shift )                            shift_counter <= shift_counter + 1'b1;

always_ff @(posedge clk or negedge reset_n)
    if ( ~reset_n )                         valid_o <= 'd0;             else
    if ( next_state == VALID )              valid_o <= 'd1;             else
                                            valid_o <= 'd0;

genvar j;
generate
    for ( j = 0; j < ARRAY_HEIGHT; j = j + 1) begin : assign_output
        assign data_o[ (j + 1) * SHIFT_BITES - 1 : j * SHIFT_BITES ] = buffer[j][SHIFT_BITES - 1 : 0];
    end
endgenerate

endmodule