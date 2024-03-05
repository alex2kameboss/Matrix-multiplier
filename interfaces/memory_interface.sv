interface memory_interface #(
    parameter DATA_WIDTH = 256,
    parameter ADDR_WIDTH = 16
) (
    input   clk,
    input   reset_n
);
    
logic                           req;
logic                           ack;
logic                           w_en;
logic   [ADDR_WIDTH - 1 : 0]    addr;
logic   [DATA_WIDTH - 1 : 0]    data;

modport master (
input   clk,
        reset_n,
        ack,
output  req,
        addr,
        w_en,
inout   data
);

modport slave (
input   clk,
        reset_n,
        req,
        addr,
        w_en,
output  ack,
inout   data
);

endinterface