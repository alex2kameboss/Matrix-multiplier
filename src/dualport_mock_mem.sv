module dualport_mock_mem #(
    parameter   DATA_WIDTH      =   256,
    parameter   ADDR_WIDTH      =   10
) (
    input                           clk,
    // write interface
    input                           w_en,
    input   [ADDR_WIDTH - 1 : 0]    w_addr,
    inout   [DATA_WIDTH - 1 : 0]    w_data,
    // read interface
    input   [ADDR_WIDTH - 1 : 0]    r_addr,
    output  [DATA_WIDTH - 1 : 0]    r_data
);
    
reg [DATA_WIDTH - 1: 0] mem [ADDR_WIDTH - 1 : 0];

assign  r_data = mem[w_data];

always_ff @(posedge clk)
    if ( w_en )     mem[w_addr] <= w_data;

endmodule