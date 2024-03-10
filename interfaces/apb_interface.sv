interface apb_interface (
    input       pclk,
    input       preset_n
);
    
logic   [2 : 0]         paddr;

logic                   psel;
logic                   penable;

logic                   pwrite;
logic   [15 : 0]        pwdata;

logic                   pready;
logic   [15 : 0]        prdata;

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
        prdata
);

endinterface