module top (
    apb_interface.slave         config_bus,
    memory_interface.master     a_bus,
    memory_interface.master     b_bus,
    memory_interface.master     c_bus
);
    
wire    [15 : 0]    a_addr, b_addr, c_addr, m, n, p;

regfile regfile_i (
    .bus(config_bus),
    .matrix_a_addr_o(a_addr),
    .matrix_b_addr_o(b_addr),
    .matrix_c_addr_o(c_addr),
    .m_o(m),
    .n_o(n),
    .p_o(p),
    .start_o(),
    .end_i()
);

endmodule