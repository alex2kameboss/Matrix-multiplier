module top_tb();

logic clk, reset_n;
memory_interface a_bus(clk, reset_n), b_bus(clk, reset_n), c_bus(clk, reset_n);
apb_interface cfg(clk, reset_n);

// clock
initial begin
    clk = 1'b1;
    forever begin
        #5 clk = ~clk;
    end
end

// mem loops
mem_mock_gen gen_a(.bus(a_bus));
mem_mock_gen gen_b(.bus(b_bus));

always_ff @(posedge c_bus.clk or negedge c_bus.reset_n)
    if ( ~c_bus.reset_n )                     c_bus.ack <= 'd0;    else
    if ( c_bus.req )                          c_bus.ack <= ~c_bus.ack;

// dut
top #(
    .ARRAY_WIDTH ( 16 ) ,
    .ARRAY_HEIGHT( 16 )     
) dut (
    .config_bus ( cfg       ) ,
    .a_bus      ( a_bus     ) ,
    .b_bus      ( b_bus     ) ,
    .c_bus      ( c_bus     ) ,
    .clk        ( clk       ) ,
    .reset_n    ( reset_n   ) 
);

task apb_write_tran;
input   [2 : 0]     addr;
input   [15 : 0]    wdata;
begin
    @(posedge clk);
    cfg.paddr   = addr;
    cfg.pwdata  = wdata;
    cfg.pwrite  = 1'b1;
    cfg.psel    = 1'b1;
    @(posedge clk);
    @(posedge clk);
    cfg.psel    = 1'b0;
    cfg.pwdata  = 'dx;
    cfg.paddr   = 'dx;
end
endtask

task transaction;
input   [15 : 0]    size;
begin

    // config dut
    apb_write_tran(3'd0, 'd0);      // a start addr
    apb_write_tran(3'd1, 'd0);      // b start addr
    apb_write_tran(3'd2, 'd0);      // c start addr
    apb_write_tran(3'd3, size);     // m
    apb_write_tran(3'd4, size);     // n
    apb_write_tran(3'd5, size);     // p

    // start tran
    apb_write_tran(3'd6, 'd1);

    @(posedge dut.done_apb);
    @(posedge clk);
    @(posedge clk);
end
endtask

initial begin
    reset_n = 1'b0;

    cfg.paddr    = 'dx;
    cfg.psel     = 'd0;
    cfg.pwrite   = 'd0;
    cfg.pwdata   = 'dx;

    @(posedge clk);
    @(posedge clk);
    reset_n = 1'b1;
    @(posedge clk);
    @(posedge clk);
    
    transaction('d32);
    $stop();
end

endmodule