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

`ifdef ENABLE_ASSERTIONS
//Checkers for req-ack protocol

property ack_pulse; // Checks that ack is a pulse
    @(posedge clk) disable iff (~rst_n)
    $rose(ack) |=> ##1 $fell(ack);
  endproperty
  
  property req_without_ack; // Request had no response from server side
    @(posedge clk) disable iff (~rst_n)
    (req & ~ack) |=> ~req;
  endproperty
  
  property ack_without_req; // Ack without an active request 
    @(posedge clk) disable iff (~rst_n)
    (ack & ~req) |=> ~ack;
  endproperty
  
  property ack_after_one_req_cc; //Acknowledge comes after one request HIGH clock cycle time
    @(posedge clk) disable iff (~rst_n)
    req & $changed(req) |-> ##1 ack;
  endproperty
  //Checkers for design specific
  
  // Assertion 1: The request activates correctly after a specific number of clock cycles
  property req_dist_diff_than_constrained;
    @(posedge clk) disable iff (~rst_n)
    $fell(req) |-> ##REQ_DIST req;
  endproperty
  
  always @(posedge clk) 
    //REQ-ACK PROTOCOL CHECKERS
    assert property (ack_pulse) else
      $error("PROTOCOL VIOLATION: ack_pulse assertion failed! Acknowledgement signal isn't a pulse");
    assert property (req_without_ack) else
      $error("PROTOCOL VIOLATION: Next request came without an acknowledgement from server!");
    assert property (ack_without_req) else
      $error("PROTOCOL VIOLATION: Acknowledgement came without a request from client!");
    assert property (ack_after_one_req_cc) else
      $error("PROTOCOL VIOLATION: Acknowledge came the same time as request was asserted!");
    //DESIGN FEATURES CHECKERS
    assert property (req_dist_diff_than_constrained) else
      $error("DESIGN SPECIFICATION MISMATCH: REQ_DIST is different than constrained distance!");
  `endif

endinterface