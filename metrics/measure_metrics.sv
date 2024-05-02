module measure_metrics();

logic clk, reset_n, start;
memory_interface a_bus(clk, reset_n), b_bus(clk, reset_n), c_bus(clk, reset_n);
reg [15 : 0] m, n, p;

`ifndef A_WIDTH
    `define A_WIDTH 16
`endif

`ifndef A_HEIGHT
    `define A_HEIGHT 16
`endif

systolic_array_top #(
    .ARRAY_WIDTH     ( `A_WIDTH  ),
    .ARRAY_HEIGHT    ( `A_HEIGHT ),
    .DATA_WIDTH      ( 8         ),
    .BUS_WIDTH_BYTES ( 32        ),
    .DATA_WIDTH_BYTES( 1         )
) dut (
    .a_bus       ( a_bus   ),
    .b_bus       ( b_bus   ),
    .c_bus       ( c_bus   ),
    .clk         ( clk     ),
    .reset_n     ( reset_n ),
    .start_i     ( start   ),
    .m           ( m       ),
    .n           ( n       ),
    .p           ( p       ),
    .base_addr_a ( 16'd0   ),
    .base_addr_b ( 16'd0   ),
    .base_addr_c ( 16'd0   ),
    .operation_done(       )
);

mem_mock_gen gen_a(.bus(a_bus));
mem_mock_gen gen_b(.bus(b_bus));

always_ff @(posedge c_bus.clk or negedge c_bus.reset_n)
    if ( ~c_bus.reset_n )                     c_bus.ack <= 'd0;    else
    if ( c_bus.req )                          c_bus.ack <= ~c_bus.ack;

// metrics

int a_req, b_req, c_req, cycles;
logic count_cycles;

initial begin
    clk = 1'b1;
    forever begin
        #5 clk = ~clk;
    end
end

always @(posedge a_bus.req)
    a_req <= a_req + 1;

always @(posedge b_bus.req)
    b_req <= b_req + 1;

always @(posedge c_bus.req)
    c_req <= c_req + 1;

always @(posedge clk)
    if ( count_cycles ) cycles <= cycles + 1;

task measure_operation;
input   [15 : 0]    size;
begin
    m <= size;
    n <= size;
    p <= size;

    a_req <= 0;
    b_req <= 0;
    c_req <= 0;
    cycles <= 0;

    @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;

    @(posedge dut.start_array);
    count_cycles <= 1'b1;
    @(posedge dut.array_done);
    count_cycles <= 1'b0;

    @(posedge dut.ooperation_done_c_bus);
    @(posedge clk);
    @(posedge clk);

    $display("%0d,%0d,%0d,%0d,%0d", size, a_req, b_req, c_req, cycles);
end
endtask

initial begin
    $display("size,a_req,b_req,c_req,cycles");
    count_cycles = 1'b0;
    reset_n = 1'b0;
    start = 1'b0;
    @(posedge clk);
    @(posedge clk);
    reset_n = 1'b1;
    @(posedge clk);
    @(posedge clk);
    
    measure_operation('d64);
    measure_operation('d128);
    measure_operation('d256);
    measure_operation('d512);
    measure_operation('d1024);
    /*measure_operation('d2048);
    measure_operation('d4096);*/
    $stop();
end

endmodule