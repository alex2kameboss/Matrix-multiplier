interface memory_interface (
    input   clk,
    input   reset_n
);
    
logic               req;
logic               ack;
logic               w_en;
logic   [15 : 0]    addr;
wire   [256 : 0]   data;

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