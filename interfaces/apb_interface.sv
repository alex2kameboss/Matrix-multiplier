interface apb_interface #(
    parameter   ADDR_WIDTH  =   32,
    parameter   DATA_WIDTH  =   32
) (
    input       pclk,
    input       preset_n
);
    
logic   [ADDR_WIDTH - 1 : 0]        paddr;

logic                               psel;
logic                               penable;

logic                               pwrite;
logic   [DATA_WIDTH - 1 : 0]        pwdata;

logic                               pready;
logic   [DATA_WIDTH - 1 : 0]        prdata;

modport master (
input   pclk,
        preset_n,
        pready,
        prdata,
output  paddr,
        psel,
        penable,
        pwrite,
        pwdata
);

modport slave (
input   pclk,
        preset_n,
        paddr,
        psel,
        penable,
        pwrite,
        pwdata,
output  pready,
        prdata,
);

endinterface