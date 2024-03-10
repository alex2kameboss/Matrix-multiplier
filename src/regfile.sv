// addr             comment
// 0x00             matrix A start address (op1)
// 0x01             matrix B start address (op2)
// 0x02             matrix C start address (result)
// 0x03             M paramter (A is M x N, B is N x P, C is M x P)
// 0x04             N paramter (A is M x N, B is N x P, C is M x P)
// 0x05             P paramter (A is M x N, B is N x P, C is M x P)
// 0x06             state register (0: start flag, 1: end flag)

module regfile (
    apb_interface.slave     bus,
    output  [15 : 0]        matrix_a_addr_o,
    output  [15 : 0]        matrix_b_addr_o,
    output  [15 : 0]        matrix_c_addr_o,
    output  [15 : 0]        m_o,
    output  [15 : 0]        n_o,
    output  [15 : 0]        p_o,
    output                  start_o,
    input                   end_i
);
    
reg [15 : 0] registers [7 : 0];
reg [15 : 0] prdata_reg;
reg penable_reg, pready_reg;
reg psel_reg;
integer i;

always_ff @( posedge bus.pclk or negedge bus.preset_n )
    if ( ~bus.preset_n )
        for (i = 0; i < 8 ; i = i + 1)
            registers[i] <= 'd0;
    else if ( bus.psel & bus.pwrite)    registers[bus.paddr] <= bus.pwdata;
    else if ( end_i )                   registers[3'd6]['d1] <= 1'b1;

always_ff @( posedge bus.pclk or negedge bus.preset_n )
    if ( ~bus.preset_n )        psel_reg <= 'd0;    else
                                psel_reg <= bus.psel;

always_ff @( posedge bus.pclk or negedge bus.preset_n )
    if ( ~bus.preset_n )    penable_reg <= 'd0;     else
    if ( psel_reg )         penable_reg <= ~penable_reg;

always_ff @( posedge bus.pclk or negedge bus.preset_n )
    if ( ~bus.preset_n )    pready_reg <= 'd0;     else
    if ( psel_reg )         pready_reg <= ~pready_reg;

always_ff @( posedge bus.pclk or negedge bus.preset_n )
    if ( ~bus.preset_n )            prdata_reg <= 'd0;  else
    if ( bus.psel & ~bus.pwrite )   prdata_reg <= registers[bus.paddr];

assign bus.penable = penable_reg;
assign bus.pready = pready_reg;
assign bus.prdata = prdata_reg;

assign matrix_a_addr_o  = registers[3'd0];
assign matrix_b_addr_o  = registers[3'd1];
assign matrix_c_addr_o  = registers[3'd2];
assign m_o              = registers[3'd3];
assign n_o              = registers[3'd4];
assign p_o              = registers[3'd5];
assign start_o          = registers[3'd6]['d0];

endmodule