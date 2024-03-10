module regfile_tb ();
    
reg clk, reset_n;

apb_interface bus(.pclk(clk), .preset_n(reset_n));

wire [15 : 0]        matrix_a_addr_o;
wire [15 : 0]        matrix_b_addr_o;
wire [15 : 0]        matrix_c_addr_o;
wire [15 : 0]        m_o;
wire [15 : 0]        n_o;
wire [15 : 0]        p_o;
wire                 start_o;
wire                 end_i;

regfile dut (
    .bus,
    .matrix_a_addr_o,
    .matrix_b_addr_o,
    .matrix_c_addr_o,
    .m_o,
    .n_o,
    .p_o,
    .start_o,
    .end_i
);

initial begin
    clk = 'd1;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    reset_n = 'd0;
    bus.psel = 'd0;
    @(posedge clk);
    reset_n = 'd1;
    @(posedge clk);

    bus.paddr = 'd1;
    bus.pwdata = 'd10;
    bus.pwrite = 'd1;
    bus.psel = 'd1;
    @(posedge clk);
    @(posedge clk);
    bus.psel = 'd0;
    @(posedge clk);
    @(posedge clk);

    bus.pwrite = 'd0;
    bus.psel = 'd1;
    @(posedge clk);
    @(posedge clk);
    bus.psel = 'd0;
    @(posedge clk);
    @(posedge clk);
    $stop;
end

endmodule